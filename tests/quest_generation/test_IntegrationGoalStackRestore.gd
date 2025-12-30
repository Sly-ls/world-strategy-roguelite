# res://tests/factions/IntegrationGoalStackRestoreTest.gd
extends BaseTest
class_name IntegrationGoalStackRestoreTest

## Test d'intégration: WAR → TRUCE (pression haute) → WAR (pression basse)
## Vérifie le cycle complet de suspension/restoration des goals

# --- Planner sim using goal state ---
class PlannerSim:
    func _is_offensive(action: StringName) -> bool:
        return action == &"arc.raid"

    func _can_afford(action: StringName, base_cost: int, goal_state: FactionGoalState) -> bool:
        var budget := 10  # Budget fixe pour le test
        var mult := goal_state.budget_mult_offensive
        var cost := base_cost
        if _is_offensive(action):
            cost = int(ceil(float(base_cost) / max(0.01, mult)))
        return budget >= cost

    func plan_action(goal_state: FactionGoalState) -> StringName:
        if goal_state.goal == null:
            return &"arc.idle"
        
        # WAR => raid if can afford
        if goal_state.goal.type == FactionGoal.GoalType.START_WAR:
            return &"arc.raid" if _can_afford(&"arc.raid", 10, goal_state) else &"arc.defend"
        
        # TRUCE (goal forcé) => talks
        if goal_state.is_forced():
            return &"arc.truce_talks"
        
        # GAIN_ALLY utilisé comme TRUCE dans notre implémentation
        if goal_state.goal.type == FactionGoal.GoalType.GAIN_ALLY and goal_state.goal.title.begins_with("Trêve"):
            return &"arc.truce_talks"
        
        return &"arc.idle"


func _ready() -> void:
    _test_goal_stack_war_to_truce_7_days_then_restore_war()
    pass_test("✅ IntegrationGoalStackRestoreTest: OK")


func _test_goal_stack_war_to_truce_7_days_then_restore_war() -> void:
    var A := &"A"
    var B := &"B"

    var dom := FactionDomesticState.new(60, 75, 10)
    var planner := PlannerSim.new()

    # Créer un goal WAR avec des steps
    var war_goal := FactionGoal.new()
    war_goal.id = "war_A_B"
    war_goal.type = FactionGoal.GoalType.START_WAR
    war_goal.title = "Guerre contre B"
    war_goal.actor_faction_id = "A"
    war_goal.target_faction_id = "B"
    
    # Ajouter une step pour que is_completed() retourne false
    var step := FactionGoalStep.new()
    step.id = "mobilize"
    step.title = "Mobiliser"
    step.required_amount = 10
    war_goal.steps = [step]
    
    # Créer le FactionGoalState
    var goal_state := FactionGoalState.new(war_goal)

    var actions_by_day: Dictionary = {}
    var goal_type_by_day: Dictionary = {}

    var saw_truce := false
    var saw_restore_war := false
    var first_truce_day := -1

    for day in range(1, 31):
        # --- simulate domestic dynamics ---
        # Phase 1: war fatigue rises until ~day 17
        if day <= 17:
            dom.war_support = clampi(dom.war_support - 4, 0, 100)
            dom.unrest = clampi(dom.unrest + 4, 0, 100)
        # Phase 2: after some days of truce + "domestic work", pressure drops
        else:
            dom.war_support = clampi(dom.war_support + 5, 0, 100)
            dom.unrest = clampi(dom.unrest - 6, 0, 100)

        var ctx := {"day": day, "current_day": day, "faction_id": A, "budget_points": 10}

        # --- restore step (si pression basse et période forcée expirée) ---
        goal_state = DomesticPolicyGate.maybe_restore_suspended_goal(goal_state, ctx, dom)

        # --- apply gate (may force TRUCE and attach suspended_goal) ---
        goal_state = DomesticPolicyGate.apply(A, goal_state, ctx, dom, {
            "pressure_threshold": 0.7,
            "force_days": 7,
            "min_offensive_budget_mult": 0.25
        })

        # Déterminer le type de goal pour les assertions
        var current_type: String
        if goal_state.is_forced():
            current_type = "TRUCE"
        elif goal_state.goal != null:
            current_type = "WAR" if goal_state.goal.type == FactionGoal.GoalType.START_WAR else "OTHER"
        else:
            current_type = "NONE"
        
        goal_type_by_day[day] = current_type
        var act: StringName = planner.plan_action(goal_state)
        actions_by_day[day] = act

        # record first TRUCE day
        if current_type == "TRUCE" and not saw_truce:
            saw_truce = true
            first_truce_day = day

        # detect restore WAR after having had TRUCE
        if saw_truce and current_type == "WAR":
            saw_restore_war = true

    # ---- Assertions ----
    _assert(saw_truce, "should enter TRUCE at least once due to pressure > 0.7")
    _assert(first_truce_day > 0, "first_truce_day should be set")

    # A) during forced TRUCE window, actions should be truce talks (not raids)
    var until_day := first_truce_day + 7
    for d in range(first_truce_day, min(until_day + 1, 31)):
        _assert(goal_type_by_day[d] == "TRUCE", "goal should stay TRUCE during forced window (day %d, got %s)" % [d, goal_type_by_day[d]])
        _assert(actions_by_day[d] == &"arc.truce_talks", "action should be truce talks during TRUCE (day %d, got %s)" % [d, actions_by_day[d]])

    # B) after window + pressure drop, we restore WAR
    _assert(saw_restore_war, "should restore suspended WAR after forced TRUCE window if pressure drops")

    # C) after restore, raids can happen again (at least once) if budget allows
    var raids_after_restore := 0
    for d in range(until_day + 1, 31):
        if goal_type_by_day[d] == "WAR" and actions_by_day[d] == &"arc.raid":
            raids_after_restore += 1
    _assert(raids_after_restore >= 1, "should see raids again after WAR restore (got %d)" % raids_after_restore)

    # D) pressure should end lower
    _assert(dom.pressure() < 0.62, "pressure should end below restore threshold (got %.3f)" % dom.pressure())
