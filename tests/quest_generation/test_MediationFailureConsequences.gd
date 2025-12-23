# tests/MediationFailureConsequencesTest.gd
extends BaseTest
class_name MediationFailureConsequencesTest
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

    var faction_a :Faction = Faction.new()
    faction_a.id = A
    faction_a.name = "Faction " + A
    FactionManager.register_faction(faction_a)
    
    var faction_b :Faction = Faction.new()
    faction_b.id = B
    faction_b.name = "Faction " + B
    FactionManager.register_faction(faction_b)
    
    var faction_c :Faction = Faction.new()
    faction_c.id = C
    faction_c.name = "Faction " + C
    FactionManager.register_faction(faction_c)

    # create mediation quest context (3 participants)
    var inst := TestInst.new()
    inst.context = {
        "action_type": &"tp.mediation",
        "giver_faction_id": A,        
        "antagonist_faction_id": B,
        "third_party_id": C,        # mediator "actor"
        "roll": 0.95                # force failure with low p
    }

    # mediator profile for faction C: mediocre diplomacy => low success chance
    var mediator_profile := FactionProfile.from_profile_and_axis(
    {FactionProfile.PERS_DIPLOMACY: 0.2, 
    FactionProfile.PERS_HONOR: 0.4, 
    FactionProfile.PERS_DISCIPLINE: 0.4, 
    FactionProfile.PERS_OPPORTUNISM: 0.6, 
    FactionProfile.PERS_AGGRESSION: 0.4})
    faction_c.profile = mediator_profile
    
    # mediator: trust for C
    faction_a.get_relation_to(C).set_score(FactionRelationScore.REL_TRUST, 50)
    faction_b.get_relation_to(C).set_score(FactionRelationScore.REL_TRUST, 50)
    
    # opposition: high heat between A and B
    var relation_ab :FactionRelationScore = FactionManager.get_relation(A,B)
    relation_ab.set_score(FactionRelationScore.REL_TENSION, 85)
    relation_ab.set_score(FactionRelationScore.REL_GRIEVANCE, 70)
    relation_ab.set_score(FactionRelationScore.REL_FRICTION, 0.3)
    relation_ab.set_score(FactionRelationScore.REL_RESISTANCE, 0.7)
    var relation_ba :FactionRelationScore = FactionManager.get_relation(B,A)
    relation_ba.set_score(FactionRelationScore.REL_TENSION, 85)
    relation_ba.set_score(FactionRelationScore.REL_GRIEVANCE, 70)
    relation_ba.set_score(FactionRelationScore.REL_FRICTION, 0.3)
    relation_ba.set_score(FactionRelationScore.REL_RESISTANCE, 0.7)
   # var opposition := FactionManager.get_relation(){"tension_mean": 85, "grievance_mean": 70, "friction": 0.3, "resistance": 0.7}

    var success := QuestOutcomeUtil.compute_outcome_success(inst, 3, null)
    _assert(not success, "precondition: mediation should FAIL in this setup (chance=%.3f roll=%.3f)" % [float(inst.context.get("last_success_chance", 0.0)), float(inst.context.get("last_roll", 0.0))])

    var tension_before :float = relation_ab.get_score(FactionRelationScore.REL_TENSION)
    var relation_ac :FactionRelationScore = FactionManager.get_relation(A,C)
    var trust_a_c_before :float = relation_ac.get_score(FactionRelationScore.REL_TRUST)

    # apply failure consequences (LOYAL attempt but failure)
    ArcFailureConsequences.apply(inst.context, &"LOYAL", &"FAILURE", {}, null, 10)

    var tension_after :float = relation_ab.get_score(FactionRelationScore.REL_TENSION)
    var trust_a_c_after :float = relation_ac.get_score(FactionRelationScore.REL_TRUST)
    _assert(tension_after > tension_before, "tension(A→B) should increase after failed mediation (before=%d after=%d)" % [tension_before, tension_after])
    _assert(trust_a_c_after < trust_a_c_before, "trust(A→C) should decrease after failed mediation (before=%d after=%d)" % [trust_a_c_before, trust_a_c_after])

    # optional extra: B also distrusts mediator
    var relation_bc :FactionRelationScore = FactionManager.get_relation(B,C)
    var trust_b_c_before :float = relation_ac.get_score(FactionRelationScore.REL_TRUST)
    _assert(trust_b_c_before < 50, "trust(B→C) should also decrease after failed mediation (after=%d)" % trust_b_c_before)
