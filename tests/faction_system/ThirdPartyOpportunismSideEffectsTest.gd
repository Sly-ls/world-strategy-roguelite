extends BaseTest
class_name ThirdPartyOpportunismSideEffectsTest

func _ready() -> void:
    _test_opportunism_improves_A_C_and_does_not_touch_A_B()
    pass_test("\n✅ ThirdPartyOpportunismSideEffectsTest: OK\n")


func _test_opportunism_improves_A_C_and_does_not_touch_A_B() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 919191

    var A := &"A"
    var B := &"B"
    var C := &"C"

    # -----------------------------
    # Relations world
    # -----------------------------
    var relations := {}
    relations[A] = {}; relations[B] = {}; relations[C] = {}

    relations[A][B] = FactionRelationScore.new()
    relations[B][A] = FactionRelationScore.new()
    relations[A][C] = FactionRelationScore.new()
    relations[C][A] = FactionRelationScore.new()
    relations[B][C] = FactionRelationScore.new()
    relations[C][B] = FactionRelationScore.new()

    # A<->B : conflict hot, but should NOT be modified by opportunism effects
    relations[A][B].relation = -65; relations[B][A].relation = -60
    relations[A][B].trust = 18;     relations[B][A].trust = 22
    relations[A][B].tension = 75;   relations[B][A].tension = 70
    relations[A][B].grievance = 55; relations[B][A].grievance = 50
    relations[A][B].weariness = 25; relations[B][A].weariness = 22

    # A<->C : already friendly, should improve a bit (beneficiary likes C)
    relations[A][C].relation = 20; relations[C][A].relation = 18
    relations[A][C].trust = 45;    relations[C][A].trust = 40
    relations[A][C].tension = 10;  relations[C][A].tension = 10
    relations[A][C].grievance = 5; relations[C][A].grievance = 5

    # C<->B : neutral-ish, will escalate
    relations[C][B].relation = -10; relations[B][C].relation = -8
    relations[C][B].trust = 35;     relations[B][C].trust = 38
    relations[C][B].tension = 20;   relations[B][C].tension = 22
    relations[C][B].grievance = 18; relations[B][C].grievance = 16
    relations[C][B].weariness = 10; relations[B][C].weariness = 10

    # Baselines to compare
    var ab_before := _snapshot(relations[A][B], relations[B][A])
    var ac_before := _snapshot(relations[A][C], relations[C][A])

    # Arc C<->B (target of opportunism)
    var arc_cb := ArcState.new()
    arc_cb.state = &"NEUTRAL"

    # Events: C raids B (beneficiary=A)
    var opportunism_days := {2:true, 4:true, 6:true}

    for day in range(1, 21):
        ArcStateMachine.tick_day_for_pair(arc_cb, relations[C][B], relations[B][C])

        if opportunism_days.has(day):
            ThirdPartyEffectTable.apply_for_opportunist(
                relations,
                A, B, C,
                &"OPPORTUNIST",
                &"tp.opportunist.raid",
                ThirdPartyEffectTable.CHOICE_LOYAL,
                0.80
            )

            ArcStateMachine.update_arc_state(
                arc_cb, relations[C][B], relations[B][C],
                day, rng,
                ArcDecisionUtil.ARC_RAID,
                ThirdPartyEffectTable.CHOICE_LOYAL
            )
        else:
            ArcStateMachine.update_arc_state(
                arc_cb, relations[C][B], relations[B][C],
                day, rng,
                &"", &""
            )

    # After
    var ab_after := _snapshot(relations[A][B], relations[B][A])
    var ac_after := _snapshot(relations[A][C], relations[C][A])

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


func _snapshot(xy: FactionRelationScore, yx: FactionRelationScore) -> Dictionary:
    return {
        "rel_mean": 0.5 * (xy.relation + yx.relation),
        "trust_mean": 0.5 * (xy.trust + yx.trust),
        "tension_mean": 0.5 * (xy.tension + yx.tension),
        "griev_mean": 0.5 * (xy.grievance + yx.grievance),
    }
