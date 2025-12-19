class_name ThirdPartyOfferFactory
extends RefCounted

const TP_CATALOG := {
    &"tp.mediation.truce": [
        {"tag":"diplo.mediation_escort_envoys", "w":40, "domain":"diplo", "needs_poi":true, "poi_types":[&"CITY",&"SANCTUARY"], "deadline":[5,7]},
        {"tag":"diplo.mediation_secure_venue",  "w":35, "domain":"diplo", "needs_poi":true, "poi_types":[&"CITY",&"TEMPLE"], "deadline":[5,7]},
        {"tag":"stealth.mediation_find_spoiler","w":25, "domain":"stealth","needs_poi":true, "poi_types":[&"CITY",&"CAMP"], "deadline":[6,9]},
    ],
    &"tp.opportunist.raid": [
        {"tag":"combat.opportunist_raid",       "w":45, "domain":"combat", "needs_poi":true, "poi_types":[&"DEPOT",&"OUTPOST"], "deadline":[5,8]},
        {"tag":"stealth.opportunist_sabotage",  "w":35, "domain":"stealth","needs_poi":true, "poi_types":[&"WORKSHOP",&"DEPOT"], "deadline":[6,9]},
        {"tag":"logistics.opportunist_intercept","w":20, "domain":"logistics","needs_poi":false,"deadline":[6,9]},
    ],
}

static func spawn_third_party_offer(
    primary_arc_id: StringName,
    primary_arc_state: ArcState,
    a_id: StringName,
    b_id: StringName,
    c_id: StringName,
    role: StringName,
    tp_action: StringName,
    rel_ca: FactionRelationScore, # C -> A (juste pour difficulty/risk si tu veux)
    profiles: Dictionary,
    economies: Dictionary,
    budget_mgr: ArcOfferBudgetManager,
    notebook: ArcNotebook,
    rng: RandomNumberGenerator,
    day: int,
    tier: int
) -> QuestInstance:
    var primary_pair_key := StringName((String(a_id)+"|"+String(b_id)) if (String(a_id) <= String(b_id)) else (String(b_id)+"|"+String(a_id)))
    if not notebook.can_spawn_third_party(primary_pair_key, day, 7):
        return null

    var variants: Array = TP_CATALOG.get(tp_action, [])
    if variants.is_empty():
        return null

    # pick variant
    var v := ArcOfferFactory._weighted_pick(variants, rng) # si _weighted_pick est static/public, sinon recopie
    var domain := String(v.get("domain","diplo"))
    var deadline_days := rng.randi_range(int(v["deadline"][0]), int(v["deadline"][1]))

    # build a normal arc context first (giver=C, antagonist = "victim" selon rôle)
    # MEDIATOR: antagonist = none logique -> on met B par défaut, mais on stocke A/B dans context
    var antagonist := b_id
    if role == &"OPPORTUNIST":
        antagonist = b_id # victim (choisi par le caller)
    # stakes (réutilise tes compute_* si tu veux)
    var risk := 0.35
    var difficulty := 0.35
    var reward_gold := ArcOfferFactoryEconomy.compute_reward_gold(tier, difficulty, domain)
    var cost_points := ArcOfferFactoryEconomy.compute_action_cost_points(tp_action, primary_arc_state.state, difficulty, tier, profiles[c_id])

    var econ: FactionEconomy = economies.get(c_id, null)
    if econ == null or not econ.can_reserve(reward_gold):
        return null
    var budget := budget_mgr.get_budget(c_id)
    var pair_key_cx := StringName((String(c_id)+"|"+String(antagonist)) if (String(c_id) <= String(antagonist)) else (String(antagonist)+"|"+String(c_id)))
    if not budget.can_open_offer(pair_key_cx, cost_points):
        return null

    var stakes := {"gold":reward_gold, "risk":risk, "difficulty":difficulty, "cost_points":cost_points, "domain":domain}

    var ctx := ArcStateMachine.build_arc_context(primary_arc_id, primary_arc_state, c_id, antagonist, tp_action, day, deadline_days, stakes, rng.randi())
    ctx["is_third_party"] = true
    ctx["third_party_faction_id"] = c_id
    ctx["third_party_role"] = role
    ctx["primary_pair_key"] = primary_pair_key
    ctx["side_a_faction_id"] = a_id
    ctx["side_b_faction_id"] = b_id
    ctx["involved_factions"] = [a_id, b_id, c_id]
    ctx["offer_tag"] = String(v.get("tag",""))
    ctx["offer_domain"] = domain

    # create template (fallback)
    var template := ArcOfferFactory._build_template_fallback(String(ctx["offer_tag"]), tier, deadline_days)
    var inst := QuestInstance.new(template, ctx)
    inst.status = "AVAILABLE"
    inst.started_on_day = day
    inst.expires_on_day = day + deadline_days

    # reserve
    var qid := StringName(inst.runtime_id)
    if not econ.reserve_for_quest(qid, reward_gold):
        return null
    if not budget.reserve_for_offer(qid, pair_key_cx, cost_points):
        econ.release_reservation(qid)
        return null

    inst.context["escrow_faction_id"] = c_id
    inst.context["escrow_gold"] = reward_gold
    inst.context["escrow_points"] = cost_points
    notebook.mark_third_party_spawned(primary_pair_key, day)

    return inst
