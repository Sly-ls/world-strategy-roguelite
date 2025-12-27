extends BaseTest
class_name ThirdPartyMediationConvergenceTest

func _ready() -> void:
    _test_repeated_mediation_converges()
    pass_test("\n✅ ThirdPartyMediationConvergenceTest: OK\n")

func _test_repeated_mediation_converges() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 202501

    # ids
    FactionManager.generate_world(3)
    var ids :Array[String]= FactionManager.get_all_faction_ids()
    var A = ids[0]
    var B = ids[1]
    var C = ids[2]
    
    var rel_ab = FactionManager.get_relation(A,B)
    var rel_ba = FactionManager.get_relation(B,A)
    var rel_ac = FactionManager.get_relation(A,C)
    var rel_bc = FactionManager.get_relation(B,C)
    var rel_ca = FactionManager.get_relation(C,A)
    var rel_cb = FactionManager.get_relation(C,B)
    # init A<->B hostile conflict
    rel_ab.set_score(FactionRelationScore.REL_RELATION, -50)
    rel_ab.set_score(FactionRelationScore.REL_TRUST, 20)
    rel_ab.set_score(FactionRelationScore.REL_TENSION, 70)
    rel_ab.set_score(FactionRelationScore.REL_GRIEVANCE, 60)
    rel_ab.set_score(FactionRelationScore.REL_WEARINESS, 30)
    
    rel_ba.set_score(FactionRelationScore.REL_RELATION, -52)
    rel_ba.set_score(FactionRelationScore.REL_TRUST, 18)
    rel_ba.set_score(FactionRelationScore.REL_TENSION, 72)
    rel_ba.set_score(FactionRelationScore.REL_GRIEVANCE, 58)
    rel_ba.set_score(FactionRelationScore.REL_WEARINESS, 28)

    # init C neutral/good with both
    rel_ac.set_score(FactionRelationScore.REL_RELATION, 10)
    rel_bc.set_score(FactionRelationScore.REL_RELATION, 5)
    rel_ca.set_score(FactionRelationScore.REL_RELATION, 8)
    rel_cb.set_score(FactionRelationScore.REL_RELATION, 6)
    
    rel_ac.set_score(FactionRelationScore.REL_TRUST, 35)
    rel_bc.set_score(FactionRelationScore.REL_TRUST, 30)
    rel_ca.set_score(FactionRelationScore.REL_TRUST, 30)
    rel_cb.set_score(FactionRelationScore.REL_TRUST, 32)
    
    # arc state A<->B
    var arc := ArcState.new()
    arc.state = &"CONFLICT"
    arc.lock_until_day = 0
    arc.phase_events = 0
    arc.phase_hostile = 0
    arc.phase_peace = 0
    arc.stable_low_tension_days = 0
    arc.stable_high_trust_days = 0

    rel_ab.get_score(FactionRelationScore.REL_RELATION)
    var initial_tension :float = 0.5 * (rel_ab.get_score(FactionRelationScore.REL_TENSION) + rel_ba.get_score(FactionRelationScore.REL_TENSION))
    var initial_rel :float = 0.5 * (rel_ab.get_score(FactionRelationScore.REL_RELATION) + rel_ba.get_score(FactionRelationScore.REL_RELATION))
    var initial_trust :float = 0.5 * (rel_ab.get_score(FactionRelationScore.REL_TRUST) + rel_ba.get_score(FactionRelationScore.REL_TRUST))

    var mediation_days := {2:true, 4:true, 6:true}

    for day in range(1, 31):
        # daily stability counters
        
        ArcStateMachine.tick_day_for_pair(arc, A, B)

        # Apply mediated event on some days
        if mediation_days.has(day):
            ThirdPartyEffectTable.apply(
                A, B, C,
                &"MEDIATOR",
                &"tp.mediation.truce",
                ThirdPartyEffectTable.CHOICE_LOYAL,
                0.30 # max_change_ratio (plutôt permissif pour ce test)
            )

            # Feed arc state machine with canonical peace action
            ArcStateMachine.update_arc_state(
                arc, rel_ab, rel_ba,
                day, rng,
                ArcDecisionUtil.ARC_TRUCE_TALKS,
                ThirdPartyEffectTable.CHOICE_LOYAL
            )
        else:
            # passive update to allow transitions “après Y jours”
            ArcStateMachine.update_arc_state(
                arc, rel_ab, rel_ba,
                day, rng,
                &"", &""
            )

    # Final metrics
    var final_tension :float = 0.5 * (rel_ab.get_score(FactionRelationScore.REL_TENSION) + rel_ba.get_score(FactionRelationScore.REL_TENSION))
    var final_rel :float = 0.5 * (rel_ab.get_score(FactionRelationScore.REL_RELATION) + rel_ba.get_score(FactionRelationScore.REL_RELATION))
    var final_trust :float = 0.5 * (rel_ab.get_score(FactionRelationScore.REL_TRUST) + rel_ba.get_score(FactionRelationScore.REL_TRUST))

    # Convergence checks (no escalation)
    _assert(final_tension < initial_tension, "tension should decrease (%.1f -> %.1f)" % [initial_tension, final_tension])
    _assert(final_rel > initial_rel, "relation should increase (%.1f -> %.1f)" % [initial_rel, final_rel])
    _assert(final_trust > initial_trust, "trust should increase (%.1f -> %.1f)" % [initial_trust, final_trust])

    # Outcome: TRUCE or ALLIANCE (ALLIANCE expected often)
    _assert(arc.state == &"TRUCE" or arc.state == &"ALLIANCE",
        "arc should converge to TRUCE/ALLIANCE, got: %s" % [String(arc.state)]
    )

    # If ALLIANCE, it must satisfy the stability intent
    if arc.state == &"ALLIANCE":
        _assert(final_tension <= 25.0, "ALLIANCE implies low tension (<=25)")
        _assert(final_trust >= 55.0, "ALLIANCE implies trust >=55")
        _assert(final_rel >= 35.0, "ALLIANCE implies relation >=35")
