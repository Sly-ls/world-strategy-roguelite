extends BaseTest
class_name DomesticPressureGateTest

func _is_offensive(action: StringName) -> bool:
    return action == &"arc.raid" or action == &"arc.declare_war" or action == &"arc.sabotage"

func _can_afford_action(action: StringName, base_cost: int, ctx: Dictionary) -> bool:
    var budget := int(ctx.get("budget_points", 0))
    var off_mult := float(ctx.get("budget_mult_offensive", 1.0))
    var cost := base_cost
    if _is_offensive(action):
        cost = int(ceil(float(base_cost) / max(0.01, off_mult)))
    return budget >= cost


func _ready() -> void:
    _test_pressure_gate_forces_truce_and_inflates_offensive_cost()
    print("\n✅ DomesticPressureGateTest: OK\n")


func _test_pressure_gate_forces_truce_and_inflates_offensive_cost() -> void:
    var domestic := FactionDomesticState.new(40, 15, 85)
    var ctx := {"day": 10, "faction_id": &"A", "budget_points": 10, "domestic_state": domestic}
    var goal := {"type": &"WAR", "target_id": &"B"}

    var p := domestic.pressure()
    _assert(p > 0.7, "precondition: pressure must be > 0.7 (got %.3f)" % p)

    goal = DomesticPolicyGate.apply(&"A", goal, ctx, domestic, {
        "pressure_threshold": 0.7,
        "force_days": 7,
        "min_offensive_budget_mult": 0.25
    })

    # 1) goal forced to TRUCE
    _assert(StringName(goal.get("type", &"")) == &"TRUCE", "goal.type should be forced to TRUCE under high pressure")
    _assert(goal.has("suspended_goal"), "goal should keep suspended_goal for later restore")

    # 2) offensive budget multiplier reduced
    var mult := float(ctx.get("budget_mult_offensive", 1.0))
    _assert(mult < 1.0, "budget_mult_offensive should be < 1.0 under high pressure (got %.3f)" % mult)

    # 3) offensive cost inflation makes a previously affordable offensive action unaffordable
    # base_cost 10, budget 10:
    # without gate => affordable
    var ctx_no_gate := {"budget_points": 10} # no budget_mult_offensive => 1.0
    _assert(_can_afford_action(&"arc.raid", 10, ctx_no_gate), "without gate, arc.raid base_cost=10 should be affordable")

    # with gate => cost becomes ceil(10 / mult) >= 11 if mult <= 0.91
    var can_after := _can_afford_action(&"arc.raid", 10, ctx)
    _assert(not can_after, "with gate, arc.raid should become unaffordable due to inflated cost (mult=%.3f)" % mult)

    # non-offensive action should remain affordable
    _assert(_can_afford_action(&"arc.truce_talks", 4, ctx), "non-offensive action should remain affordable")
