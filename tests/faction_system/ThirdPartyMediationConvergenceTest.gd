extends BaseTest
class_name ThirdPartyMediationConvergenceTest

func _ready() -> void:
    _test_repeated_mediation_converges()
    print("\n✅ ThirdPartyMediationConvergenceTest: OK\n")
    get_tree().quit()

func _test_repeated_mediation_converges() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 202501

    # ids
    var A := &"A"
    var B := &"B"
    var C := &"C"

    # relations dict
    var relations := {}
    relations[A] = {}; relations[B] = {}; relations[C] = {}

    relations[A][B] = FactionRelationScore.new()
    relations[B][A] = FactionRelationScore.new()
    relations[A][C] = FactionRelationScore.new()
    relations[C][A] = FactionRelationScore.new()
    relations[B][C] = FactionRelationScore.new()
    relations[C][B] = FactionRelationScore.new()

    # init A<->B hostile conflict
    relations[A][B].relation = -50; relations[B][A].relation = -52
    relations[A][B].trust = 20;     relations[B][A].trust = 18
    relations[A][B].tension = 70;   relations[B][A].tension = 72
    relations[A][B].grievance = 60; relations[B][A].grievance = 58
    relations[A][B].weariness = 30; relations[B][A].weariness = 28

    # init C neutral/good with both
    relations[A][C].relation = 10; relations[C][A].relation = 8
    relations[B][C].relation = 5;  relations[C][B].relation = 6
    relations[A][C].trust = 35;    relations[C][A].trust = 30
    relations[B][C].trust = 30;    relations[C][B].trust = 32

    # arc state A<->B
    var arc := ArcState.new()
    arc.state = &"CONFLICT"
    arc.lock_until_day = 0
    arc.phase_events = 0
    arc.phase_hostile = 0
    arc.phase_peace = 0
    arc.stable_low_tension_days = 0
    arc.stable_high_trust_days = 0

    var initial_tension :float = 0.5 * (relations[A][B].tension + relations[B][A].tension)
    var initial_rel :float = 0.5 * (relations[A][B].relation + relations[B][A].relation)

    var mediation_days := {2:true, 4:true, 6:true}

    for day in range(1, 31):
        # daily stability counters
        ArcStateMachine.tick_day_for_pair(arc, relations[A][B], relations[B][A])

        # Apply mediated event on some days
        if mediation_days.has(day):
            ThirdPartyEffectTable.apply(
                relations,
                A, B, C,
                &"MEDIATOR",
                &"tp.mediation.truce",
                ThirdPartyEffectTable.CHOICE_LOYAL,
                0.30 # max_change_ratio (plutôt permissif pour ce test)
            )

            # Feed arc state machine with canonical peace action
            ArcStateMachine.update_arc_state(
                arc, relations[A][B], relations[B][A],
                day, rng,
                ArcDecisionUtil.ARC_TRUCE_TALKS,
                ThirdPartyEffectTable.CHOICE_LOYAL
            )
        else:
            # passive update to allow transitions “après Y jours”
            ArcStateMachine.update_arc_state(
                arc, relations[A][B], relations[B][A],
                day, rng,
                &"", &""
            )

    # Final metrics
    var final_tension :float = 0.5 * (relations[A][B].tension + relations[B][A].tension)
    var final_rel :float = 0.5 * (relations[A][B].relation + relations[B][A].relation)
    var final_trust :float = 0.5 * (relations[A][B].trust + relations[B][A].trust)

    # Convergence checks (no escalation)
    _assert(final_tension < initial_tension, "tension should decrease (%.1f -> %.1f)" % [initial_tension, final_tension])
    _assert(final_rel > initial_rel, "relation should increase (%.1f -> %.1f)" % [initial_rel, final_rel])

    # Outcome: TRUCE or ALLIANCE (ALLIANCE expected often)
    _assert(arc.state == &"TRUCE" or arc.state == &"ALLIANCE",
        "arc should converge to TRUCE/ALLIANCE, got: %s" % [String(arc.state)]
    )

    # If ALLIANCE, it must satisfy the stability intent
    if arc.state == &"ALLIANCE":
        _assert(final_tension <= 25.0, "ALLIANCE implies low tension (<=25)")
        _assert(final_trust >= 55.0, "ALLIANCE implies trust >=55")
        _assert(final_rel >= 35.0, "ALLIANCE implies relation >=35")


func _assert(cond: bool, msg: String) -> void:
    if not cond:
        push_error("TEST FAIL: " + msg)
        assert(false)
