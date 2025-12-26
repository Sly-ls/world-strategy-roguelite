extends BaseTest
class_name ThirdPartyOpportunismCreatesArcTest

func _ready() -> void:
    _test_opportunism_creates_new_arc_between_C_and_victim()
    pass_test("\n✅ ThirdPartyOpportunismCreatesArcTest: OK\n")


func _test_opportunism_creates_new_arc_between_C_and_victim() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 909090

    # -----------------------------
    # Relations world: relations[X][Y] -> FactionRelationScore
    # -----------------------------
   
    # ids
    FactionManager.generate_factions(3)
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

    # A<->B : conflit "chaud" (contexte qui motive l'opportunisme)
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

    # A<->C : plutôt positif (C "profite" pour aider A implicitement)
    rel_ac.set_score(FactionRelationScore.REL_RELATION, 20)
    rel_ac.set_score(FactionRelationScore.REL_TRUST, 45)
    rel_ac.set_score(FactionRelationScore.REL_TENSION, 10)
    rel_ac.set_score(FactionRelationScore.REL_GRIEVANCE, 5)
    
    rel_ca.set_score(FactionRelationScore.REL_RELATION, 18)
    rel_ca.set_score(FactionRelationScore.REL_TRUST, 40)
    rel_ca.set_score(FactionRelationScore.REL_TENSION, 10)
    rel_ca.set_score(FactionRelationScore.REL_GRIEVANCE, 5)

    # C<->B : NEUTRAL au départ (cible = victim)
    # Important: tension/grievance pas trop bas sinon ta limite "max_change_ratio" bride trop.
    rel_bc.set_score(FactionRelationScore.REL_RELATION, -8)
    rel_bc.set_score(FactionRelationScore.REL_TRUST, 38)
    rel_bc.set_score(FactionRelationScore.REL_TENSION, 22)
    rel_bc.set_score(FactionRelationScore.REL_GRIEVANCE, 16)
    rel_bc.set_score(FactionRelationScore.REL_WEARINESS, 10)
    
    rel_cb.set_score(FactionRelationScore.REL_RELATION, -10)
    rel_cb.set_score(FactionRelationScore.REL_TRUST, 35)
    rel_cb.set_score(FactionRelationScore.REL_TENSION, 20)
    rel_cb.set_score(FactionRelationScore.REL_GRIEVANCE, 18)
    rel_cb.set_score(FactionRelationScore.REL_WEARINESS, 10)

    var initial_cb_tension :float = 0.5 * (rel_cb.get_score(FactionRelationScore.REL_TENSION) + rel_bc.get_score(FactionRelationScore.REL_TENSION))
    var initial_cb_rel :float = 0.5 * (rel_cb.get_score(FactionRelationScore.REL_RELATION) + rel_bc.get_score(FactionRelationScore.REL_RELATION))

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
        ArcStateMachine.tick_day_for_pair(arc_cb, B, C)

        if opportunism_days.has(day):
            ThirdPartyEffectTable.apply_for_opportunist(
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
                rel_cb,
                rel_bc,
                day,
                rng,
                ArcDecisionUtil.ARC_RAID,
                ThirdPartyEffectTable.CHOICE_LOYAL
            )
        else:
            ArcStateMachine.update_arc_state(
                arc_cb,
                rel_cb,
                rel_bc,
                day,
                rng,
                &"", &""
            )

    # -----------------------------
    # Assertions: C<->B should have escalated to at least RIVALRY/CONFLICT
    # -----------------------------
    var final_cb_tension :float = 0.5 * (rel_cb.get_score(FactionRelationScore.REL_TENSION) + rel_bc.get_score(FactionRelationScore.REL_TENSION))
    var final_cb_rel :float = 0.5 * (rel_cb.get_score(FactionRelationScore.REL_RELATION) + rel_bc.get_score(FactionRelationScore.REL_RELATION))

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
