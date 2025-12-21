# res://tests/factions/DomesticPressureGateTest.gd
extends BaseTest
class_name DomesticPressureGateTest

func _is_offensive(action: StringName) -> bool:
    return action == &"arc.raid" or action == &"arc.declare_war" or action == &"arc.sabotage"


func _can_afford_action(action: StringName, base_cost: int, goal_state: FactionGoalState) -> bool:
    var budget := 10  # Budget fixe pour le test
    var off_mult := goal_state.budget_mult_offensive
    var cost := base_cost
    if _is_offensive(action):
        cost = int(ceil(float(base_cost) / max(0.01, off_mult)))
    return budget >= cost


func _ready() -> void:
    _test_pressure_gate_forces_truce_and_inflates_offensive_cost()
    pass_test("\n✅ DomesticPressureGateTest: OK\n")


func _test_pressure_gate_forces_truce_and_inflates_offensive_cost() -> void:
    # Créer un état domestique avec pression haute
    var domestic := FactionDomesticState.new(40, 15, 85)
    var ctx := {"day": 10, "faction_id": &"A", "budget_points": 10}
    
    # Créer un FactionGoal de guerre avec des steps (sinon is_completed() = true)
    var war_goal := FactionGoal.new()
    war_goal.id = "war_A_B"
    war_goal.type = FactionGoal.GoalType.START_WAR
    war_goal.title = "Guerre contre B"
    war_goal.actor_faction_id = "A"
    war_goal.target_faction_id = "B"
    
    # Ajouter au moins une step pour que is_completed() retourne false
    var step := FactionGoalStep.new()
    step.id = "mobilize"
    step.title = "Mobiliser les troupes"
    step.required_amount = 1
    war_goal.steps = [step]
    
    # Créer le FactionGoalState
    var goal_state := FactionGoalState.new(war_goal)
    
    # Vérifier précondition
    var p := domestic.pressure()
    _assert(p > 0.7, "precondition: pressure must be > 0.7 (got %.3f)" % p)
    
    # Appliquer DomesticPolicyGate
    goal_state = DomesticPolicyGate.apply(&"A", goal_state, ctx, domestic, {
        "pressure_threshold": 0.7,
        "force_days": 7,
        "min_offensive_budget_mult": 0.25
    })
    
    # 1) goal forced to TRUCE (suspended_goal contient l'ancien goal)
    _assert(goal_state.is_forced(), "goal_state should be forced under high pressure")
    _assert(goal_state.has_suspended_goal(), "goal_state should have suspended_goal for later restore")
    _assert(goal_state.suspended_goal.type == FactionGoal.GoalType.START_WAR, "suspended_goal should be the original WAR goal")
    _assert(goal_state.force_reason == &"DOMESTIC_PRESSURE", "force_reason should be DOMESTIC_PRESSURE")
    
    # 2) offensive budget multiplier reduced
    var mult := goal_state.budget_mult_offensive
    _assert(mult < 1.0, "budget_mult_offensive should be < 1.0 under high pressure (got %.3f)" % mult)
    _assert(mult <= 0.5, "budget_mult_offensive should be significantly reduced (got %.3f)" % mult)
    
    # 3) offensive cost inflation makes a previously affordable offensive action unaffordable
    # Créer un goal_state sans pression pour comparaison
    var goal_state_no_gate := FactionGoalState.new(war_goal)
    # budget_mult_offensive = 1.0 par défaut
    _assert(_can_afford_action(&"arc.raid", 10, goal_state_no_gate), "without gate, arc.raid base_cost=10 should be affordable")
    
    # with gate => cost becomes ceil(10 / mult) >= 11 if mult <= 0.91
    var can_after := _can_afford_action(&"arc.raid", 10, goal_state)
    _assert(not can_after, "with gate, arc.raid should become unaffordable due to inflated cost (mult=%.3f)" % mult)
    
    # non-offensive action should remain affordable
    _assert(_can_afford_action(&"arc.truce_talks", 4, goal_state), "non-offensive action should remain affordable")
    
    # 4) Test restoration quand pression redescend
    var domestic_low := FactionDomesticState.new(80, 10, 20)  # Pression basse
    var ctx_later := {"day": 20}  # Après forced_until_day (10 + 7 = 17)
    
    var p_low := domestic_low.pressure()
    _assert(p_low < 0.4, "precondition for restore: pressure must be < 0.4 (got %.3f)" % p_low)
    
    goal_state = DomesticPolicyGate.maybe_restore_suspended_goal(goal_state, ctx_later, domestic_low)
    
    _assert(not goal_state.is_forced(), "goal_state should no longer be forced after restore")
    _assert(not goal_state.has_suspended_goal(), "suspended_goal should be cleared after restore")
    _assert(goal_state.goal.type == FactionGoal.GoalType.START_WAR, "original WAR goal should be restored")
    _assert(goal_state.budget_mult_offensive == 1.0, "budget_mult_offensive should be reset to 1.0")
