extends BaseTest
class_name IntegrationGoalStackRestoreTest

static func maybe_restore_suspended_goal(goal: Dictionary, ctx: Dictionary, domestic_state) -> Dictionary:
    if not goal.has("suspended_goal"):
        return goal
    var day := int(ctx.get("day", 0))
    var until := int(goal.get("until_day", 0))
    var p := float(domestic_state.pressure())
    if day >= until and p < 0.62:
        return goal["suspended_goal"]
    return goal


# --- Planner sim using goal stack ---
class PlannerSim:
    func _is_offensive(action: StringName) -> bool:
        return action == &"arc.raid"

    func _can_afford(action: StringName, base_cost: int, ctx: Dictionary) -> bool:
        var budget := int(ctx.get("budget_points", 0))
        var mult := float(ctx.get("budget_mult_offensive", 1.0))
        var cost := base_cost
        if _is_offensive(action):
            cost = int(ceil(float(base_cost) / max(0.01, mult)))
        return budget >= cost

    func plan_action(goal: Dictionary, ctx: Dictionary) -> StringName:
        # WAR => raid if can
        if StringName(goal.get("type", &"")) == &"WAR":
            return &"arc.raid" if _can_afford(&"arc.raid", 10, ctx) else &"arc.defend"
        # TRUCE => talks
        if StringName(goal.get("type", &"")) == &"TRUCE":
            return &"arc.truce_talks"
        return &"arc.idle"


func _ready() -> void:
    _test_goal_stack_war_to_truce_7_days_then_restore_war()
    print("\n✅ IntegrationGoalStackRestoreTest: OK\n")
    get_tree().quit()


func _test_goal_stack_war_to_truce_7_days_then_restore_war() -> void:
    var A := &"A"
    var B := &"B"

    var dom := FactionDomesticState.new(60, 75, 10)
    var planner := PlannerSim.new()

    var goal := {"type": &"WAR", "target_id": B}
    var actions_by_day: Dictionary = {}
    var goal_type_by_day: Dictionary = {}

    var saw_truce := false
    var saw_restore_war := false
    var first_truce_day := -1

    for day in range(1, 31):
        # --- simulate domestic dynamics ---
        # Phase 1: war fatigue rises until ~day 15
        if day <= 17:
            dom.war_support = int(clampi(dom.war_support - 4, 0, 100))
            dom.unrest = int(clampi(dom.unrest + 4, 0, 100))
        # Phase 2: after some days of truce + “domestic work”, pressure drops
        else:
            dom.war_support = int(clampi(dom.war_support + 5, 0, 100))
            dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

        var ctx := {"day": day, "faction_id": A, "domestic_state": dom, "budget_points": 10}

        # --- restore step (goal stack) ---
        goal = maybe_restore_suspended_goal(goal, ctx, dom)

        # --- apply gate (may force TRUCE and attach suspended_goal) ---
        goal = DomesticPolicyGate.apply(A, goal, ctx, dom, {
            "pressure_threshold": 0.7,
            "force_days": 7,
            "min_offensive_budget_mult": 0.25
        })

        goal_type_by_day[day] = StringName(goal.get("type", &""))
        var act: StringName = planner.plan_action(goal, ctx)
        actions_by_day[day] = act

        # record first TRUCE day
        if goal_type_by_day[day] == &"TRUCE" and not saw_truce:
            saw_truce = true
            first_truce_day = day

        # detect restore WAR after having had TRUCE
        if saw_truce and goal_type_by_day[day] == &"WAR":
            saw_restore_war = true

    # ---- Assertions ----
    _assert(saw_truce, "should enter TRUCE at least once due to pressure > 0.7")
    _assert(first_truce_day > 0, "first_truce_day should be set")

    # A) during forced TRUCE window, actions should be truce talks (not raids)
    var until_day := first_truce_day + 7
    for d in range(first_truce_day, min(until_day + 1, 31)):
        _assert(goal_type_by_day[d] == &"TRUCE", "goal should stay TRUCE during forced window (day %d)" % d)
        _assert(actions_by_day[d] == &"arc.truce_talks", "action should be truce talks during TRUCE (day %d)" % d)

    # B) after window + pressure drop, we restore WAR
    _assert(saw_restore_war, "should restore suspended WAR after forced TRUCE window if pressure drops")

    # C) after restore, raids can happen again (at least once) if budget allows
    var raids_after_restore := 0
    for d in range(until_day + 1, 31):
        if goal_type_by_day[d] == &"WAR" and actions_by_day[d] == &"arc.raid":
            raids_after_restore += 1
    _assert(raids_after_restore >= 1, "should see raids again after WAR restore (got %d)" % raids_after_restore)

    # D) pressure should end lower
    _assert(float(dom.pressure()) < 0.62, "pressure should end below restore threshold (got %.3f)" % float(dom.pressure()))


func _assert(cond: bool, msg: String) -> void:
    if not cond:
        push_error("TEST FAIL: " + msg)
        assert(false)
