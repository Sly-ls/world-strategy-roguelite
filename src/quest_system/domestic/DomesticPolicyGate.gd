# DomesticPolicyGate.gd
class_name DomesticPolicyGate
extends RefCounted

static func apply(
    faction_id: StringName,
    goal: Dictionary,              # ton goal courant (ou un objet)
    ctx: Dictionary,               # world sim ctx / planner ctx
    domestic_state,                # FactionDomesticState
    params: Dictionary = {}
) -> Dictionary:
    var p := float(domestic_state.pressure())
    var threshold := float(params.get("pressure_threshold", 0.7))

    # Nothing to do
    if p < threshold:
        return goal

    # 1) Force goal TRUCE/REPARATIONS (mais réversible)
    # On met en "suspended_goal" l'objectif précédent pour y revenir plus tard.
    if not goal.has("suspended_goal"):
        goal["suspended_goal"] = goal.duplicate(true)

    goal["type"] = &"TRUCE"  # ou &"REPARATIONS"
    goal["reason"] = &"DOMESTIC_PRESSURE"
    goal["until_day"] = int(ctx.get("day", 0)) + int(params.get("force_days", 7))

    # 2) Réduire budgets offensifs (0..1 multiplier)
    var min_mult := float(params.get("min_offensive_budget_mult", 0.25))
    var mult := clampf(1.0 - 0.85*(p - threshold)/(1.0 - threshold), min_mult, 1.0)

    # exemple : on stocke des multiplicateurs que le planner utilisera
    ctx["budget_mult_offensive"] = mult
    ctx["budget_mult_defensive"] = max(0.8, mult + 0.35)  # on garde de la défense
    ctx["prefer_actions"] = [&"arc.truce_talks", &"arc.reparations", &"domestic.maintain_order", &"domestic.appease_nobles"]

    return goal
