# DomesticOfferFactory.gd
class_name DomesticOfferFactory
extends RefCounted

const DEFAULT_COOLDOWN_DAYS := 5

# choix d'action (MVP)
const ACTION_MAINTAIN_ORDER := &"domestic.maintain_order"
const ACTION_PROPAGANDA     := &"domestic.propaganda"
const ACTION_APPEASE_NOBLES  := &"domestic.appease_nobles"
const ACTION_REPARATIONS     := &"domestic.reparations_push"

static func spawn_offer_if_needed(
    faction_id: StringName,
    domestic_state,                 # FactionDomesticState
    day: int,
    quest_pool,                     # QuestPool.try_add_offer(inst)
    arc_notebook = null,
    economy = null,                 # optional (gold)
    params: Dictionary = {}
):
    var pressure := float(domestic_state.pressure())
    var unrest := int(domestic_state.unrest)
    var war_support := int(domestic_state.war_support)
    var stability := int(domestic_state.stability)

    # conditions d’apparition (MVP)
    if pressure < 0.55 and unrest < 55 and war_support > 35:
        return null

    var cooldown := int(params.get("cooldown_days", DEFAULT_COOLDOWN_DAYS))

    # cooldown anti-spam (si ArcNotebook le supporte)
    if arc_notebook != null and arc_notebook.has_method("can_spawn_domestic_offer"):
        if not arc_notebook.can_spawn_domestic_offer(faction_id, day, cooldown):
            return null

    # choisir action
    var action: StringName
    if war_support <= 25:
        action = ACTION_REPARATIONS
    elif unrest >= 70:
        action = ACTION_MAINTAIN_ORDER
    elif stability <= 40:
        action = ACTION_APPEASE_NOBLES
    else:
        action = ACTION_PROPAGANDA

    # coût politique/éco (MVP) + fallback
    var cost_gold := 0
    if action == ACTION_APPEASE_NOBLES:
        cost_gold = 60
    if action == ACTION_REPARATIONS:
        cost_gold = 30

    if economy != null and cost_gold > 0 and int(economy.gold) < cost_gold:
        # pas assez d’or => fallback vers propaganda (toujours faisable)
        action = ACTION_PROPAGANDA
        cost_gold = 0

    # tier/deadline
    var unrest_ratio = 0
    if unrest >= 70:
        unrest_ratio = 1
    var tier := clampi(1 + int(floor(pressure * 4.0)) + unrest_ratio, 1, 5)
    var deadline := clampi(9 - int(floor(pressure * 5.0)), 4, 9)

    var template := _build_template_fallback(action, tier, deadline)

    var ctx := {
        "is_domestic_offer": true,
        "domestic_action": action,
        "giver_faction_id": faction_id,
        "tier": tier,
        "expires_in_days": deadline,
        "stake": {"pressure": pressure, "unrest": unrest, "war_support": war_support, "stability": stability},
        "domestic_cost_gold": cost_gold,
        "resolution_profile_id": &"domestic_default"
    }

    var inst := QuestInstance.new(template, ctx)
    inst.status = QuestTypes.QuestStatus.AVAILABLE
    inst.started_on_day = day
    inst.expires_on_day = day + deadline

    if quest_pool != null and quest_pool.has_method("try_add_offer"):
        if not quest_pool.try_add_offer(inst):
            return null

    if arc_notebook != null and arc_notebook.has_method("mark_domestic_offer_spawned"):
        arc_notebook.mark_domestic_offer_spawned(faction_id, day)

    return inst


static func apply_domestic_resolution(
    context: Dictionary,
    choice: StringName,             # LOYAL/NEUTRAL/TRAITOR
    domestic_state,                 # FactionDomesticState
    economy = null
) -> void:
    if not bool(context.get("is_domestic_offer", false)):
        return

    var action: StringName = StringName(context.get("domestic_action", &""))
    var cost_gold := int(context.get("domestic_cost_gold", 0))

    # payer si nécessaire (LOYAL/NEUTRAL seulement)
    if economy != null and cost_gold > 0 and (choice == &"LOYAL" or choice == &"NEUTRAL"):
        var pay := cost_gold if choice == &"LOYAL" else int(ceil(cost_gold * 0.5))
        economy.gold = max(0, int(economy.gold) - pay)

    # effets (MVP)
    var du := 0
    var ds := 0
    var dw := 0

    match action:
        ACTION_MAINTAIN_ORDER:
            if choice == &"LOYAL":    du = -18; ds = +6;  dw = +0
            elif choice == &"NEUTRAL":du = -9;  ds = +3;  dw = +0
            else:                    du = +10; ds = -6;  dw = -3
        ACTION_PROPAGANDA:
            if choice == &"LOYAL":    du = -8;  ds = +3;  dw = +10
            elif choice == &"NEUTRAL":du = -4;  ds = +1;  dw = +5
            else:                    du = +8;  ds = -4;  dw = -6
        ACTION_APPEASE_NOBLES:
            if choice == &"LOYAL":    du = -10; ds = +10; dw = +4
            elif choice == &"NEUTRAL":du = -5;  ds = +5;  dw = +2
            else:                    du = +12; ds = -10; dw = -4
        ACTION_REPARATIONS:
            # pousse la sortie de guerre
            if choice == &"LOYAL":    du = -6;  ds = +4;  dw = +12
            elif choice == &"NEUTRAL":du = -3;  ds = +2;  dw = +6
            else:                    du = +6;  ds = -5;  dw = -6
        _:
            pass

    domestic_state.unrest = int(clampi(domestic_state.unrest + du, 0, 100))
    domestic_state.stability = int(clampi(domestic_state.stability + ds, 0, 100))
    domestic_state.war_support = int(clampi(domestic_state.war_support + dw, 0, 100))


static func _build_template_fallback(id: StringName, tier: int, expires_in_days: int) -> QuestTemplate:
    var t := QuestTemplate.new()
    t.id = id
    t.title = String(id)
    t.description = "Domestic offer: %s" % String(id)
    t.category =QuestTypes.QuestCategory.DOMESTIC
    t.tier = tier
    t.objective_type = QuestTypes.ObjectiveType.GENERIC
    t.objective_target = &""
    t.objective_count = 1
    t.expires_in_days = expires_in_days
    return t
