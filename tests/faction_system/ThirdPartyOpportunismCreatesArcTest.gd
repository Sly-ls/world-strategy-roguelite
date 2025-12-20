extends BaseTest
class_name ThirdPartyOpportunismCreatesArcTest

func _ready() -> void:
    _test_opportunism_creates_new_arc_between_C_and_victim()
    pass_test("\n✅ ThirdPartyOpportunismCreatesArcTest: OK\n")


func _test_opportunism_creates_new_arc_between_C_and_victim() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 909090

    var A := &"A"
    var B := &"B"
    var C := &"C"

    # -----------------------------
    # Relations world: relations[X][Y] -> FactionRelationScore
    # -----------------------------
    var relations := {}
    relations[A] = {}; relations[B] = {}; relations[C] = {}

    relations[A][B] = FactionRelationScore.new()
    relations[B][A] = FactionRelationScore.new()
    relations[A][C] = FactionRelationScore.new()
    relations[C][A] = FactionRelationScore.new()
    relations[B][C] = FactionRelationScore.new()
    relations[C][B] = FactionRelationScore.new()

    # A<->B : conflit "chaud" (contexte qui motive l'opportunisme)
    relations[A][B].relation = -65; relations[B][A].relation = -60
    relations[A][B].trust = 18;     relations[B][A].trust = 22
    relations[A][B].tension = 75;   relations[B][A].tension = 70
    relations[A][B].grievance = 55; relations[B][A].grievance = 50
    relations[A][B].weariness = 25; relations[B][A].weariness = 22

    # A<->C : plutôt positif (C "profite" pour aider A implicitement)
    relations[A][C].relation = 20; relations[C][A].relation = 18
    relations[A][C].trust = 45;    relations[C][A].trust = 40
    relations[A][C].tension = 10;  relations[C][A].tension = 10
    relations[A][C].grievance = 5; relations[C][A].grievance = 5

    # C<->B : NEUTRAL au départ (cible = victim)
    # Important: tension/grievance pas trop bas sinon ta limite "max_change_ratio" bride trop.
    relations[C][B].relation = -10; relations[B][C].relation = -8
    relations[C][B].trust = 35;     relations[B][C].trust = 38
    relations[C][B].tension = 20;   relations[B][C].tension = 22
    relations[C][B].grievance = 18; relations[B][C].grievance = 16
    relations[C][B].weariness = 10; relations[B][C].weariness = 10

    var initial_cb_tension :float = 0.5 * (relations[C][B].tension + relations[B][C].tension)
    var initial_cb_rel :float = 0.5 * (relations[C][B].relation + relations[B][C].relation)

    # -----------------------------
    # Arc states
    # -----------------------------
    var arc_cb := ArcState.new()
    arc_cb.state = &"NEUTRAL"
    arc_cb.lock_until_day = 0
    arc_cb.phase_events = 0
    arc_cb.phase_hostile = 0
    arc_cb.phase_peace = 0
    arc_cb.stable_low_tension_days = 0
    arc_cb.stable_high_trust_days = 0

    # -----------------------------
    # Opportunist events: C raids B (beneficiary = A, victim = B)
    # -----------------------------
    var opportunism_days := {2:true, 4:true, 6:true}

    for day in range(1, 21):
        # counters (même les jours sans event)
        ArcStateMachine.tick_day_for_pair(arc_cb, relations[C][B], relations[B][C])

        if opportunism_days.has(day):
            ThirdPartyEffectTable.apply_for_opportunist(
                relations,
                A,  # beneficiary
                B,  # victim
                C,  # third party
                &"OPPORTUNIST",
                &"tp.opportunist.raid",
                ThirdPartyEffectTable.CHOICE_LOYAL,
                0.80  # max_change_ratio (volontairement permissif pour franchir le seuil)
            )

            # Feed the state machine with a canonical hostile action
            ArcStateMachine.update_arc_state(
                arc_cb,
                relations[C][B],
                relations[B][C],
                day,
                rng,
                ArcDecisionUtil.ARC_RAID,
                ThirdPartyEffectTable.CHOICE_LOYAL
            )
        else:
            ArcStateMachine.update_arc_state(
                arc_cb,
                relations[C][B],
                relations[B][C],
                day,
                rng,
                &"", &""
            )

    # -----------------------------
    # Assertions: C<->B should have escalated to at least RIVALRY/CONFLICT
    # -----------------------------
    var final_cb_tension :float = 0.5 * (relations[C][B].tension + relations[B][C].tension)
    var final_cb_rel :float = 0.5 * (relations[C][B].relation + relations[B][C].relation)

    _assert(final_cb_tension > initial_cb_tension, "C<->B tension should increase (%.1f -> %.1f)" % [initial_cb_tension, final_cb_tension])
    _assert(final_cb_rel < initial_cb_rel, "C<->B relation should decrease (%.1f -> %.1f)" % [initial_cb_rel, final_cb_rel])

    _assert(
        arc_cb.state != &"NEUTRAL" and arc_cb.state != &"ALLIANCE" and arc_cb.state != &"TRUCE",
        "opportunism should create a hostile arc state for C<->B (got %s)" % [String(arc_cb.state)]
    )

    # Optionnel: si tu veux être plus strict (selon tes seuils)
    # _assert(arc_cb.state == &"RIVALRY" or arc_cb.state == &"CONFLICT" or arc_cb.state == &"WAR",
    #   "expected RIVALRY/CONFLICT/WAR for C<->B, got %s" % [String(arc_cb.state)]
    # )
