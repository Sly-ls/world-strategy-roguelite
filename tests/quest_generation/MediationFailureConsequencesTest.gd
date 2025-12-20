# tests/MediationFailureConsequencesTest.gd
extends BaseTest
class_name MediationFailureConsequencesTest

# fallback minimal if your real class isn't available
class TestRelationScore:
    var relation := 0
    var trust := 50
    var tension := 10
    var grievance := 10
    var weariness := 0

# minimal inst
class TestInst:
    var context := {}

func _ready() -> void:
    _test_mediation_failure_increases_tension_and_decreases_trust_to_mediator()
    pass_test("\n✅ MediationFailureConsequencesTest: OK\n")

func _test_mediation_failure_increases_tension_and_decreases_trust_to_mediator() -> void:
    var A := &"A"
    var B := &"B"
    var C := &"C" # mediator

    # relations dict: relations[x][y] = score
    var relations := {}
    relations[A] = {}
    relations[B] = {}
    relations[C] = {}

    var ScoreClass = FactionRelationScore if ClassDB.class_exists("FactionRelationScore") else TestRelationScore

    relations[A][B] = ScoreClass.new()
    relations[B][A] = ScoreClass.new()
    relations[A][C] = ScoreClass.new()
    relations[B][C] = ScoreClass.new()
    relations[C][A] = ScoreClass.new()
    relations[C][B] = ScoreClass.new()

    # baseline
    relations[A][B].tension = 70
    relations[B][A].tension = 70
    relations[A][C].trust = 50
    relations[B][C].trust = 50

    # create mediation quest context (3 participants)
    var inst := TestInst.new()
    inst.context = {
        "tp_action": &"tp.mediation",
        "giver_faction_id": C,        # mediator "actor"
        "antagonist_faction_id": A,
        "third_party_id": B,
        "actor_faction_id": C,
        "roll": 0.95                  # force failure with low p
    }

    # mediator profile: mediocre diplomacy => low success chance
    var mediator_profile := {"personality": {&"diplomacy": 0.2, &"honor": 0.4, &"discipline": 0.4, &"opportunism": 0.6, &"aggression": 0.4}}

    # opposition: high heat between A and B
    var opposition := {"tension_mean": 85, "grievance_mean": 70, "friction": 0.3, "resistance": 0.7}

    var success := QuestOutcomeUtil.compute_outcome_success(inst, mediator_profile, opposition, 3, null)
    _assert(not success, "precondition: mediation should FAIL in this setup (chance=%.3f roll=%.3f)" % [float(inst.context.get("last_success_chance", 0.0)), float(inst.context.get("last_roll", 0.0))])

    var tension_before :float = relations[A][B].tension
    var trust_a_c_before :float = relations[A][C].trust

    # apply failure consequences (LOYAL attempt but failure)
    ArcFailureConsequences.apply(inst.context, &"LOYAL", &"FAILURE", relations, {}, null, 10)

    _assert(relations[A][B].tension > tension_before, "tension(A→B) should increase after failed mediation (before=%d after=%d)" % [tension_before, relations[A][B].tension])
    _assert(relations[A][C].trust < trust_a_c_before, "trust(A→C) should decrease after failed mediation (before=%d after=%d)" % [trust_a_c_before, relations[A][C].trust])

    # optional extra: B also distrusts mediator
    _assert(relations[B][C].trust < 50, "trust(B→C) should also decrease after failed mediation (after=%d)" % relations[B][C].trust)
