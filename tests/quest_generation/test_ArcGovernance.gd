extends BaseTest
class_name ArcGovernanceTest

var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.seed = 12345

    _test_notebook_refresh_cooldown_and_attempts()
    _test_policy_allowed_actions_and_caps()
    _test_budget_points_caps()
    _test_tick_day_for_pair_stability_counters()
    _test_fallback_action_tier_with_stub()

    pass_test("\n✅ ArcGovernanceTest: OK\n")
    


# -------------------------
# 1) ArcNotebook cooldown + attempts
# -------------------------
func _test_notebook_refresh_cooldown_and_attempts() -> void:
    var nb := ArcNotebook.new()
    var pair := &"a|b"

    _assert(nb.can_refresh_offer_for_pair(pair, 10, 5), "should refresh at day 10")
    _assert(nb.mark_refresh_attempt_for_pair(pair) == 1, "attempts should be 1")
    nb.mark_offer_refreshed_for_pair(pair, 10)

    _assert(not nb.can_refresh_offer_for_pair(pair, 14, 5), "should NOT refresh at day 14 (cooldown=5)")
    _assert(nb.can_refresh_offer_for_pair(pair, 15, 5), "should refresh at day 15")

    _assert(nb.mark_refresh_attempt_for_pair(pair) == 2, "attempts should be 2")


# -------------------------
# 2) ArcPolicy allowed actions + bundle cap (concurrent cap)
# -------------------------
func _test_policy_allowed_actions_and_caps() -> void:
    _assert(ArcPolicy.bundle_cap_for_state(&"RIVALRY") == 1, "RIVALRY cap should be 1")
    _assert(ArcPolicy.bundle_cap_for_state(&"WAR") == 3, "WAR cap should be 3")

    var proposed := ArcDecisionUtil.ARC_ALLIANCE_OFFER
    var filtered := ArcPolicy.filter_action_for_state(&"WAR", proposed, rng)

    var allowed: Array = ArcPolicy.ALLOWED_BY_STATE[&"WAR"]
    _assert(allowed.has(filtered), "filtered action must be allowed in WAR")


# -------------------------
# 3) FactionOfferBudget caps (global + per pair) + points reserve/release
# -------------------------
func _test_budget_points_caps() -> void:
    var b := FactionOfferBudget.new(&"A")
    b.points_per_week = 70
    b.points = 20
    b.max_active_offers = 2
    b.max_active_offers_per_pair = 1

    var p1 := &"a|x"
    var p2 := &"a|y"

    _assert(b.reserve_for_offer(&"q1", p1, 10.0), "reserve q1 should succeed")
    _assert(not b.reserve_for_offer(&"q2", p1, 5.0), "reserve q2 should fail (per-pair cap)")

    _assert(b.reserve_for_offer(&"q2", p2, 10.0), "reserve q2 should succeed on other pair")
    _assert(not b.reserve_for_offer(&"q3", p2, 1.0), "reserve q3 should fail (max_active_offers=2)")

    # release with refund (listing fee)
    var before := b.points
    b.release_offer(&"q1", p1, 0.80)
    _assert(b.active_offer_ids.size() == 1, "one active offer should remain after release")
    _assert(b.points > before, "refund should increase points")


# -------------------------
# 4) tick_day_for_pair stability counters
# -------------------------
func _test_tick_day_for_pair_stability_counters() -> void:
    var arc_state := ArcState.new()
    arc_state.stable_low_tension_days = 0
    arc_state.stable_high_trust_days = 0

    var ab := FactionRelationScore.new()
    var ba := FactionRelationScore.new()

    # Low tension + high trust
    ab.set_score(FactionRelationScore.REL_TENSION, 10); 
    ba.set_score(FactionRelationScore.REL_TENSION, 12); 
    ab.set_score(FactionRelationScore.REL_RELATION, 40); 
    ba.set_score(FactionRelationScore.REL_RELATION, 38); 
    ab.set_score(FactionRelationScore.REL_TRUST, 60); 
    ba.set_score(FactionRelationScore.REL_TRUST, 58); 

    for i in range(7):
        ArcStateMachine.tick_day_for_pair(arc_state, ab, ba)

    _assert(arc_state.stable_low_tension_days == 7, "stable_low_tension_days should count up")
    _assert(arc_state.stable_high_trust_days == 7, "stable_high_trust_days should count up")

    # Break condition
    ab.set_score(FactionRelationScore.REL_TRUST, 60); 
    ba.set_score(FactionRelationScore.REL_TRUST, 60); 
    ArcStateMachine.tick_day_for_pair(arc_state, ab, ba)
    _assert(arc_state.stable_low_tension_days == 0, "stable_low_tension_days should reset when tension high")


# -------------------------
# 5) Fallback action/tier (test fiable via stub spawn callable)
# -------------------------
# Pour tester sans dépendre du hasard/POI, on utilise un stub spawn.
#
# ⚠️ Reco mini-changement: ajoute un param optionnel spawn_fn: Callable
# à ta fonction _try_spawn_offer_with_fallback_and_tier() (sinon copie la logique ici).
func _test_fallback_action_tier_with_stub() -> void:
    var arc_id := &"arc_test"
    var st := ArcState.new()
    st.a_id = &"A"; st.b_id = &"B"; st.state = &"WAR"

    # stub: échoue si tier > 1, réussit seulement pour action RAID au tier 1
    var spawn_fn := func(action: StringName, t: int) -> QuestInstance:
        if action != ArcDecisionUtil.ARC_RAID:
            return null
        if t != 1:
            return null
        var qt := QuestTemplate.new()
        qt.tier = t
        var ctx := {"is_arc_rivalry": true, "arc_action_type": action, "stakes": {"gold": 50, "difficulty": 0.3}, "deadline_days": 7}
        return QuestInstance.new(qt, ctx)

    # On simule une chaîne: DECLARE_WAR -> ULTIMATUM -> RAID
    var initial_action := ArcDecisionUtil.ARC_DECLARE_WAR
    var tier := 3

    # Cette fonction de test reproduit EXACTEMENT ta logique de fallback,
    # mais en utilisant spawn_fn(action,tier) au lieu d’ArcOfferFactory.
    var inst := _fallback_with_injected_spawn(initial_action, tier, 1, 2, 2, spawn_fn)
    _assert(inst != null, "fallback should eventually succeed via RAID tier 1")
    _assert(StringName(inst.context["arc_action_type"]) == ArcDecisionUtil.ARC_RAID, "action should downgrade to RAID")
    _assert(int(inst.template.tier) == 1, "tier should downgrade to 1")


func _fallback_with_injected_spawn(
    initial_action: StringName,
    tier: int,
    min_tier: int,
    max_action_degrades: int,
    max_tier_degrades: int,
    spawn_fn: Callable
) -> QuestInstance:
    var chain := _fallback_chain_for(initial_action)
    var max_actions :int = min(chain.size(), 1 + max_action_degrades)

    for ai in range(max_actions):
        var action: StringName = chain[ai]
        if action == ArcDecisionUtil.ARC_IGNORE:
            return null

        var tries := 1 + max_tier_degrades
        for k in range(tries):
            var t := tier - k
            if t < min_tier:
                break
            var inst: QuestInstance = spawn_fn.call(action, t)
            if inst != null:
                inst.context["arc_action_type"] = action
                inst.context["arc_action_type_initial"] = initial_action
                inst.context["arc_tier_initial"] = tier
                inst.context["arc_tier_final"] = t
                inst.context["arc_fallback_action_steps"] = ai
                inst.context["arc_fallback_tier_steps"] = k
                return inst
    return null


func _fallback_chain_for(action: StringName) -> Array[StringName]:
    match action:
        ArcDecisionUtil.ARC_DECLARE_WAR:
            return [ArcDecisionUtil.ARC_DECLARE_WAR, ArcDecisionUtil.ARC_ULTIMATUM, ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_IGNORE]
        ArcDecisionUtil.ARC_SABOTAGE:
            return [ArcDecisionUtil.ARC_SABOTAGE, ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_IGNORE]
        ArcDecisionUtil.ARC_ULTIMATUM:
            return [ArcDecisionUtil.ARC_ULTIMATUM, ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_IGNORE]
        _:
            return [action, ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_IGNORE]
