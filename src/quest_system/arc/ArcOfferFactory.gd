class_name ArcOfferFactory
extends RefCounted

# --------------------------------------------
# Catalogue : arc_action_type -> bundles
# Chaque bundle peut produire 1..N offers (primary + optional secondary)
# --------------------------------------------
const CATALOG: Dictionary = {
    &"arc.raid": {
        "count_min": 1,
        "count_max": 2,
        "variants": [
            {"tag":"combat.raid_camp",      "w":45, "domain":"combat",    "needs_poi":true,  "poi_types":[&"CAMP",&"OUTPOST"], "deadline":[5,8]},
            {"tag":"stealth.burn_supplies", "w":30, "domain":"stealth",   "needs_poi":true,  "poi_types":[&"DEPOT",&"WORKSHOP"], "deadline":[4,7]},
            {"tag":"logistics.intercept",   "w":25, "domain":"logistics", "needs_poi":false, "deadline":[6,9]},
        ]
    },

    &"arc.ultimatum": {
        "count_min": 1,
        "count_max": 2,
        "variants": [
            {"tag":"diplo.deliver_terms",   "w":45, "domain":"diplo",     "needs_poi":true,  "poi_types":[&"CITY",&"CAPITAL"], "deadline":[4,6]},
            {"tag":"combat.show_of_force",  "w":30, "domain":"combat",    "needs_poi":true,  "poi_types":[&"BORDER",&"OUTPOST"], "deadline":[5,7]},
            {"tag":"diplo.retrieve_proof",  "w":25, "domain":"diplo",     "needs_poi":true,  "poi_types":[&"RUINS",&"LIBRARY"], "deadline":[6,9],
             "ctx":{"target_item_tag":&"PROOF_DOSSIER"}}
        ]
    },

    &"arc.truce_talks": {
        "count_min": 1,
        "count_max": 2,
        "variants": [
            {"tag":"diplo.secure_venue",    "w":40, "domain":"diplo",     "needs_poi":true, "poi_types":[&"CITY",&"SANCTUARY"], "deadline":[5,7]},
            {"tag":"combat.protect_envoy",  "w":35, "domain":"combat",    "needs_poi":true, "poi_types":[&"ROAD",&"CITY"], "deadline":[5,7],
             "ctx":{"target_character_id":&"ENVOY"}},
            {"tag":"stealth.remove_spoiler","w":25, "domain":"stealth",   "needs_poi":true, "poi_types":[&"CITY",&"CAMP"], "deadline":[6,9]}
        ]
    },

    &"arc.alliance_offer": {
        "count_min": 1,
        "count_max": 2,
        "variants": [
            {"tag":"combat.joint_operation","w":35, "domain":"combat",    "needs_poi":true, "poi_types":[&"RUINS",&"OUTPOST"], "deadline":[7,10]},
            {"tag":"diplo.exchange_hostages","w":35,"domain":"diplo",     "needs_poi":true, "poi_types":[&"CITY",&"CAPITAL"], "deadline":[6,9],
             "ctx":{"target_character_id":&"HOSTAGE"}},
            {"tag":"diplo.oath_ritual",     "w":30, "domain":"diplo",     "needs_poi":true, "poi_types":[&"SANCTUARY",&"TEMPLE"], "deadline":[7,10],
             "ctx":{"ritual":true}}
        ]
    },

    &"arc.sabotage": {
        "count_min": 1,
        "count_max": 2,
        "variants": [
            {"tag":"stealth.sabotage_site", "w":55, "domain":"stealth",   "needs_poi":true,  "poi_types":[&"WORKSHOP",&"DEPOT"], "deadline":[6,9]},
            {"tag":"combat.assassinate",    "w":25, "domain":"combat",    "needs_poi":false, "deadline":[7,10]},
            {"tag":"diplo.frame_agent",     "w":20, "domain":"diplo",     "needs_poi":true,  "poi_types":[&"CITY"], "deadline":[6,8]},
        ]
    },

    &"arc.declare_war": {
        "count_min": 2,   # guerre => souvent 2 offers (mobilisation + objectif)
        "count_max": 3,
        "variants": [
            {"tag":"logistics.mobilize",     "w":40, "domain":"logistics", "needs_poi":false, "deadline":[7,10]},
            {"tag":"combat.capture_outpost", "w":40, "domain":"combat",    "needs_poi":true,  "poi_types":[&"OUTPOST",&"BORDER"], "deadline":[8,12]},
            {"tag":"stealth.break_alliance", "w":20, "domain":"stealth",   "needs_poi":false, "deadline":[7,11]},
        ]
    },

    &"arc.reparations": {
        "count_min": 1,
        "count_max": 2,
        "variants": [
            {"tag":"logistics.deliver_goods","w":45,"domain":"logistics", "needs_poi":true,  "poi_types":[&"CITY",&"CAPITAL"], "deadline":[7,11]},
            {"tag":"combat.guard_caravan",   "w":25,"domain":"combat",    "needs_poi":true,  "poi_types":[&"ROAD",&"CITY"], "deadline":[6,10]},
            {"tag":"diplo.audit_treaty",     "w":30,"domain":"diplo",     "needs_poi":true,  "poi_types":[&"CITY"], "deadline":[6,9]},
        ]
    },
}

# -------------------------------------------------
# Utilities
# -------------------------------------------------
static func _weighted_pick(variants: Array, rng: RandomNumberGenerator) -> Dictionary:
    var sum := 0
    for v in variants:
        sum += int(v.get("w", 1))
    var r := rng.randi_range(1, max(1, sum))
    var acc := 0
    for v in variants:
        acc += int(v.get("w", 1))
        if r <= acc:
            return v
    return variants.back()

static func _roll_deadline_days(v: Dictionary, rng: RandomNumberGenerator) -> int:
    var d := v.get("deadline", [6, 9])
    return rng.randi_range(int(d[0]), int(d[1]))

static func _roll_count(bundle: Dictionary, rng: RandomNumberGenerator) -> int:
    return rng.randi_range(int(bundle.get("count_min", 1)), int(bundle.get("count_max", 1)))

static func _pair_key(a: StringName, b: StringName) -> StringName:
    return StringName((String(a) <= String(b)) ? (String(a) + "|" + String(b)) : (String(b) + "|" + String(a)))

# -------------------------------------------------
# Target POI resolution (stub + autoload-friendly)
# -------------------------------------------------
static func _pick_target_poi(poi_types: Array, rng: RandomNumberGenerator) -> Dictionary:
    # Attendu: { "id": StringName, "type": StringName, "pos": Vector2i }
    # Branche ton POIManager/WorldMap ici.
    if Engine.has_singleton("POIManagerRunner"):
        var pm = Engine.get_singleton("POIManagerRunner")
        if pm != null and pm.has_method("pick_random_poi"):
            return pm.pick_random_poi(poi_types, rng) # à adapter à ton API
    # fallback : aucun poi
    return {}

# -------------------------------------------------
# Template builder (fallback). Remplace par ton QuestGenerator si dispo.
# -------------------------------------------------
static func _build_template_fallback(tag: String, tier: int, deadline_days: int) -> QuestTemplate:
    var t := QuestTemplate.new()
    t.id = StringName("arc_" + tag)
    t.title = "Arc: " + tag
    t.description = "Arc offer: " + tag
    t.category = "ARC"
    t.tier = tier
    t.objective_type = "GENERIC"
    t.objective_target = tag
    t.objective_count = 1
    t.expires_in_days = deadline_days
    return t

# -------------------------------------------------
# Public API: spawn 1..N offers for a pair
# -------------------------------------------------
static func spawn_offers_for_pair(
    arc_id: StringName,
    arc_state: ArcState,
    giver_id: StringName,
    ant_id: StringName,
    action: StringName,
    rel_ab: FactionRelationScore,
    faction_profiles: Dictionary,
    faction_economies: Dictionary,
    budget_mgr: ArcOfferBudgetManager,
    rng: RandomNumberGenerator,
    day: int,
    tier: int,
    params: Dictionary = {}
) -> Array[QuestInstance]:
    var bundle: Dictionary = CATALOG.get(action, {})
    if bundle.is_empty():
        return []

    var variants: Array = bundle.get("variants", [])
    if variants.is_empty():
        return []

    var count := _roll_count(bundle, rng)
    var out: Array[QuestInstance] = []
    var used_tags := {}

    # on essaie de varier les offers (pas 2 fois le même tag)
    for idx in range(count):
        var tries := 0
        var v := {}
        while tries < 5:
            v = _weighted_pick(variants, rng)
            var tag := String(v.get("tag", ""))
            if tag != "" and not used_tags.has(tag):
                used_tags[tag] = true
                break
            tries += 1

        var offer := _spawn_single_offer_from_variant(
            arc_id, arc_state,
            giver_id, ant_id,
            StringName(action),
            rel_ab,
            faction_profiles,
            faction_economies,
            budget_mgr,
            rng, day,
            tier,
            v,
            "ARC_PRIMARY" if (idx==0) else "ARC_SECONDARY"
        )

        if offer != null:
            out.append(offer)

    return out


static func _spawn_single_offer_from_variant(
    arc_id: StringName,
    arc_state: ArcState,
    giver_id: StringName,
    ant_id: StringName,
    action: StringName,
    rel_ab: FactionRelationScore,
    faction_profiles: Dictionary,
    faction_economies: Dictionary,
    budget_mgr: ArcOfferBudgetManager,
    rng: RandomNumberGenerator,
    day: int,
    tier: int,
    variant: Dictionary,
    offer_kind: String
) -> QuestInstance:
    var econ: FactionEconomy = faction_economies.get(giver_id, null)
    var giver_prof: FactionProfile = faction_profiles.get(giver_id, null)
    if econ == null or giver_prof == null:
        return null

    var tag := String(variant.get("tag", ""))
    if tag == "":
        return null

    var domain := String(variant.get("domain", "combat"))
    var deadline_days := _roll_deadline_days(variant, rng)
    var pair_key := _pair_key(giver_id, ant_id)

    # --- cible POI si demandée ---
    var target_poi := {}
    if bool(variant.get("needs_poi", false)):
        target_poi = _pick_target_poi(variant.get("poi_types", []), rng)
        if target_poi.is_empty():
            return null # pas de cible => pas d’offre

    # --- stakes/risk/difficulty/reward ---
    var risk := clampf(0.25 + 0.007 * rel_ab.tension + 0.006 * rel_ab.grievance, 0.1, 0.95)
    var difficulty := ArcOfferFactoryEconomy.compute_difficulty(arc_state.state, rel_ab, risk, tier)
    var reward_gold := ArcOfferFactoryEconomy.compute_reward_gold(tier, difficulty, domain)

    # --- coût capacité ---
    var cost_points := ArcOfferFactoryEconomy.compute_action_cost_points(action, arc_state.state, difficulty, tier, giver_prof)
    var budget := budget_mgr.get_budget(giver_id)

    # --- checks ---
    if not econ.can_reserve(reward_gold):
        return null
    if not budget.can_open_offer(pair_key, cost_points):
        return null

    var stakes := {"gold": reward_gold, "risk": risk, "domain": domain, "difficulty": difficulty, "cost_points": cost_points}

    # context standard + patch variant ctx + target poi
    var ctx := ArcStateMachine.build_arc_context(arc_id, arc_state, giver_id, ant_id, action, day, deadline_days, stakes, rng.randi())
    ctx["offer_tag"] = tag
    ctx["offer_domain"] = domain
    ctx["offer_kind"] = offer_kind
    ctx["pair_key"] = pair_key

    var patch: Dictionary = variant.get("ctx", {})
    for k in patch.keys():
        ctx[k] = patch[k]

    if not target_poi.is_empty():
        ctx["target_poi_id"] = target_poi.get("id", &"")
        ctx["target_poi_type"] = target_poi.get("type", &"")
        ctx["target_poi_pos"] = target_poi.get("pos", Vector2i.ZERO)

    # template via QuestGenerator si dispo, sinon fallback
    var template: QuestTemplate = null
    if Engine.has_singleton("QuestGeneratorRunner"):
        var qg = Engine.get_singleton("QuestGeneratorRunner")
        if qg != null and qg.has_method("create_dynamic_template_from_tag"):
            template = qg.create_dynamic_template_from_tag(tag, tier, ctx)
    if template == null:
        template = _build_template_fallback(tag, tier, deadline_days)

    var inst := QuestInstance.new(template, ctx)
    inst.status = "AVAILABLE"
    inst.started_on_day = day
    inst.expires_on_day = day + deadline_days
    inst.progress = 0

    # reserve gold + points AFTER runtime_id exists
    var qid := StringName(inst.runtime_id)
    if not econ.reserve_for_quest(qid, reward_gold):
        return null
    if not budget.reserve_for_offer(qid, pair_key, cost_points):
        econ.release_reservation(qid)
        return null

    inst.context["escrow_faction_id"] = giver_id
    inst.context["escrow_gold"] = reward_gold
    inst.context["escrow_points"] = cost_points

    return inst
