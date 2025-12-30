extends BaseTest
class_name ThirdPartyOpportunismSideEffectsTest

func _ready() -> void:
    _test_opportunism_improves_A_C_and_does_not_touch_A_B()
    pass_test("✅ ThirdPartyOpportunismSideEffectsTest: OK")


func _test_opportunism_improves_A_C_and_does_not_touch_A_B() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 919191

    # -----------------------------
    # Relations world
    # -----------------------------
    
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
    
    # A<->B : conflict hot, but should NOT be modified by opportunism effects
    rel_ab.set_score(FactionRelationScore.REL_RELATION, -65)
    rel_ab.set_score(FactionRelationScore.REL_TRUST, 18)
    rel_ab.set_score(FactionRelationScore.REL_TENSION, 75)
    rel_ab.set_score(FactionRelationScore.REL_GRIEVANCE, 55)
    rel_ab.set_score(FactionRelationScore.REL_WEARINESS, 25)
    
    rel_ba.set_score(FactionRelationScore.REL_RELATION, -60)
    rel_ba.set_score(FactionRelationScore.REL_TRUST, 22)
    rel_ba.set_score(FactionRelationScore.REL_TENSION, 70)
    rel_ba.set_score(FactionRelationScore.REL_GRIEVANCE, 50)
    rel_ba.set_score(FactionRelationScore.REL_WEARINESS, 22)


    # A<->C : already friendly, should improve a bit (beneficiary likes C)
    rel_ac.set_score(FactionRelationScore.REL_RELATION, 20)
    rel_ac.set_score(FactionRelationScore.REL_TRUST, 45)
    rel_ac.set_score(FactionRelationScore.REL_TENSION, 10)
    rel_ac.set_score(FactionRelationScore.REL_GRIEVANCE, 5)
    
    rel_ca.set_score(FactionRelationScore.REL_RELATION, 18)
    rel_ca.set_score(FactionRelationScore.REL_TRUST, 40)
    rel_ca.set_score(FactionRelationScore.REL_TENSION, 10)
    rel_ca.set_score(FactionRelationScore.REL_GRIEVANCE, 5)

    
    # C<->B : neutral-ish, will escalate
    rel_cb.set_score(FactionRelationScore.REL_RELATION, -10)
    rel_cb.set_score(FactionRelationScore.REL_TRUST, 35)
    rel_cb.set_score(FactionRelationScore.REL_TENSION, 20)
    rel_cb.set_score(FactionRelationScore.REL_GRIEVANCE, 18)
    rel_cb.set_score(FactionRelationScore.REL_WEARINESS, 10)
    
    rel_bc.set_score(FactionRelationScore.REL_RELATION, -8)
    rel_bc.set_score(FactionRelationScore.REL_TRUST, 38)
    rel_bc.set_score(FactionRelationScore.REL_TENSION, 22)
    rel_bc.set_score(FactionRelationScore.REL_GRIEVANCE, 16)
    rel_bc.set_score(FactionRelationScore.REL_WEARINESS, 10)


    # Baselines to compare
    var ab_before := _snapshot(rel_ab, rel_ba)
    var ac_before := _snapshot(rel_ac, rel_ca)

    # Arc C<->B (target of opportunism)
    var arc_cb := ArcState.new()
    arc_cb.state = &"NEUTRAL"

    # Events: C raids B (beneficiary=A)
    var opportunism_days := {2:true, 4:true, 6:true}

    for day in range(1, 21):
        ArcStateMachine.tick_day_for_pair(arc_cb, C, B)

        if opportunism_days.has(day):
            ThirdPartyEffectTable.apply_for_opportunist(
                A, B, C,
                &"OPPORTUNIST",
                &"tp.opportunist.raid",
                ThirdPartyEffectTable.CHOICE_LOYAL,
                0.80
            )

            ArcStateMachine.update_arc_state(
                arc_cb, rel_bc, rel_cb,
                day, rng,
                ArcDecisionUtil.ARC_RAID,
                ThirdPartyEffectTable.CHOICE_LOYAL
            )
        else:
            ArcStateMachine.update_arc_state(
                arc_cb, rel_bc, rel_cb,
                day, rng,
                &"", &""
            )

    # After
    var ab_after := _snapshot(rel_ab, rel_ba)
    var ac_after := _snapshot(rel_ac, rel_ca)

    # -----------------------------
    # Assertions 1) A<->C improves
    # -----------------------------
    _assert(ac_after["rel_mean"] > ac_before["rel_mean"], "A<->C relation should improve (%.1f -> %.1f)" % [ac_before["rel_mean"], ac_after["rel_mean"]])

    # Optionnel: trust peut rester stable, mais tu peux aussi le booster si tu veux.
    # _assert(ac_after["trust_mean"] >= ac_before["trust_mean"], "A<->C trust should not decrease")

    # -----------------------------
    # Assertions 2) A<->B not modified by opportunism table
    # -----------------------------
    # On attend 0 variation, mais on tolère +/-1 en cas d'arrondi/clamp
    var eps := 1.0

    _assert(abs(ab_after["rel_mean"] - ab_before["rel_mean"]) <= eps, "A<->B relation should not change (%.1f -> %.1f)" % [ab_before["rel_mean"], ab_after["rel_mean"]])
    _assert(abs(ab_after["trust_mean"] - ab_before["trust_mean"]) <= eps, "A<->B trust should not change (%.1f -> %.1f)" % [ab_before["trust_mean"], ab_after["trust_mean"]])
    _assert(abs(ab_after["tension_mean"] - ab_before["tension_mean"]) <= eps, "A<->B tension should not change (%.1f -> %.1f)" % [ab_before["tension_mean"], ab_after["tension_mean"]])
    _assert(abs(ab_after["griev_mean"] - ab_before["griev_mean"]) <= eps, "A<->B grievance should not change (%.1f -> %.1f)" % [ab_before["griev_mean"], ab_after["griev_mean"]])

    # Sanity: C<->B should have escalated
    _assert(arc_cb.state != &"NEUTRAL", "C<->B arc should no longer be NEUTRAL after opportunism (got %s)" % String(arc_cb.state))


func _snapshot(rel_ab: FactionRelationScore, rel_ba: FactionRelationScore) -> Dictionary:
    return {
        "rel_mean": 0.5 * (rel_ab.get_score(FactionRelationScore.REL_TENSION) + rel_ba.get_score(FactionRelationScore.REL_TENSION)),
        "trust_mean": 0.5 * (rel_ab.get_score(FactionRelationScore.REL_TRUST) + rel_ba.get_score(FactionRelationScore.REL_TRUST)),
        "tension_mean": 0.5 * (rel_ab.get_score(FactionRelationScore.REL_TENSION) + rel_ba.get_score(FactionRelationScore.REL_TENSION)),
        "griev_mean": 0.5 * (rel_ab.get_score(FactionRelationScore.REL_GRIEVANCE) + rel_ba.get_score(FactionRelationScore.REL_GRIEVANCE)),
    }
