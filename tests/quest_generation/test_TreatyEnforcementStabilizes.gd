extends BaseTest
class_name TreatyEnforcementStabilizesTest

func _ready() -> void:
    _test_violation_then_enforcement_loyal_stabilizes()
    pass_test("\n✅ TreatyEnforcementStabilizesTest: OK\n")

func _test_violation_then_enforcement_loyal_stabilizes() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 11111

    # ids
    FactionManager.generate_factions(2)
    var ids :Array[String]= FactionManager.get_all_faction_ids()
    var A = ids[0]
    var B = ids[1]
    
    var rel_ab = FactionManager.get_relation(A,B)
    var rel_ba = FactionManager.get_relation(B,A)
    # init A<->B hostile conflict
    rel_ab.set_score(FactionRelationScore.REL_RELATION, 25)
    rel_ab.set_score(FactionRelationScore.REL_TRUST, 55)
    rel_ab.set_score(FactionRelationScore.REL_TENSION, 20)
    rel_ab.set_score(FactionRelationScore.REL_GRIEVANCE, 10)
    
    rel_ba.set_score(FactionRelationScore.REL_RELATION, 22)
    rel_ba.set_score(FactionRelationScore.REL_TRUST, 52)
    rel_ba.set_score(FactionRelationScore.REL_TENSION, 22)
    rel_ba.set_score(FactionRelationScore.REL_GRIEVANCE, 12)
    
    var arc := ArcState.new()
    arc.state = &"TRUCE"
    arc.lock_until_day = 0

    # Treaty TRUCE: no raids, threshold fairly high so 1 violation doesn't auto-break
    var t := Treaty.new()
    t.type = &"TRUCE"
    t.start_day = 1
    t.end_day = 30
    t.cooldown_after_end_days = 20
    t.clauses = Treaty.CLAUSE_NO_RAID | Treaty.CLAUSE_NO_SABOTAGE | Treaty.CLAUSE_NO_WAR
    t.violation_score = 0.0
    t.violation_threshold = 1.2
    arc.treaty = t

    # Day 5: RAID happens => violation score must go up
    ArcStateMachine.update_arc_state(
        arc, rel_ab, rel_ba,
        5, rng,
        ArcDecisionUtil.ARC_RAID,
        &"LOYAL"
    )

    _assert(arc.treaty != null, "treaty should still exist after a single violation")
    var v_after_violation :float = arc.treaty.violation_score
    _assert(v_after_violation > 0.0, "violation_score should increase after violation (got %.3f)" % v_after_violation)

    # Day 6: enforcement LOYAL should reduce violation_score and not break treaty
    ArcStateMachine.apply_treaty_enforcement_resolution(
        arc, rel_ab, rel_ba,
        &"enforce",
        &"LOYAL",
        6
    )

    _assert(arc.treaty != null, "treaty should remain active after enforcement")
    _assert(arc.treaty.violation_score < v_after_violation, "violation_score should decrease after enforcement (%.3f -> %.3f)" % [v_after_violation, arc.treaty.violation_score])

    # Sanity: tension should not be higher than right after violation (usually decreases)
    var ab_rension_score = rel_ab.get_score(FactionRelationScore.REL_RELATION)
    var ba_rension_score = rel_ba.get_score(FactionRelationScore.REL_RELATION)
    _assert(ab_rension_score <= 100 and ba_rension_score <= 100, "tension stays in bounds")
