# tests/IntegrationRealWorldLoopTickDayTest.gd
extends BaseTest
class_name IntegrationRealWorldLoopTickDayTest

## Test d'intégration du cycle complet:
## - FactionGoalManager.ensure_goal() avec domestic pressure
## - Cycle WAR → TRUCE → WAR
## - Vérification des actions (pas de raids pendant TRUCE)

func _ready() -> void:
    _test_tick_day_loop_goal_stack_and_offers()
    pass_test("✅ IntegrationRealWorldLoopTickDayTest: OK")


func _test_tick_day_loop_goal_stack_and_offers() -> void:
    var A := &"A"
    var B := &"B"

    # --- Créer le FactionGoalManager ---
    var manager := FactionGoalManager.new()
    add_child(manager)

    # --- Init goal WAR avec FactionGoal ---
    var war_goal := FactionGoal.new()
    war_goal.id = "war_A_B"
    war_goal.type = FactionGoal.GoalType.START_WAR
    war_goal.title = "Guerre contre B"
    war_goal.actor_faction_id = String(A)
    war_goal.target_faction_id = String(B)
    
    # Ajouter une step pour que is_completed() = false
    var step := FactionGoalStep.new()
    step.id = "mobilize"
    step.title = "Mobiliser les troupes"
    step.required_amount = 10
    war_goal.steps = [step]
    
    manager.set_goal(String(A), war_goal)

    # --- État domestique ---
    var dom := FactionDomesticState.new(60, 75, 10)
    
    var first_truce_day := -1
    var until_day := -1
    var saw_restore_war := false

    # Log des actions par jour
    var actions: Dictionary = {}
    var goal_types: Dictionary = {}

    for day in range(1, 31):
        # --- Simuler la dynamique domestique ---
        # Phase 1 (jours 1-17): fatigue de guerre monte
        if day <= 17:
            dom.war_support = clampi(dom.war_support - 4, 0, 100)
            dom.unrest = clampi(dom.unrest + 4, 0, 100)
        # Phase 2 (jours 18-30): récupération
        else:
            dom.war_support = clampi(dom.war_support + 5, 0, 100)
            dom.unrest = clampi(dom.unrest - 6, 0, 100)

        var ctx := {
            "day": day,
            "current_day": day,
            "domestic_state": dom,
            "budget_points": 10
        }

        # --- Appel principal: ensure_goal avec domestic pressure ---
        var goal_state: FactionGoalState = manager.ensure_goal(String(A), ctx)

        # --- Déterminer le type de goal ---
        var gt: StringName
        if goal_state.is_forced():
            gt = &"TRUCE"
        elif goal_state.goal != null and goal_state.goal.type == FactionGoal.GoalType.START_WAR:
            gt = &"WAR"
        else:
            gt = &"IDLE"
        goal_types[day] = gt

        # --- Déterminer l'action basée sur le goal ---
        var at: StringName
        if gt == &"TRUCE":
            at = &"arc.truce_talks"
        elif gt == &"WAR":
            # Vérifier si on peut afford un raid avec le budget multiplier
            var mult := goal_state.budget_mult_offensive
            var raid_cost := int(ceil(10.0 / max(0.01, mult)))
            var budget := 10
            if budget >= raid_cost:
                at = &"arc.raid"
            else:
                at = &"arc.defend"
        else:
            at = &"arc.idle"
        actions[day] = at

        # --- Tracking pour assertions ---
        if gt == &"TRUCE" and first_truce_day < 0:
            first_truce_day = day
            until_day = goal_state.forced_until_day if goal_state.forced_until_day > 0 else (day + 7)

        if first_truce_day > 0 and day > until_day and gt == &"WAR":
            saw_restore_war = true

    # --- Assertions ---
    
    # 1) Doit entrer en TRUCE au moins une fois
    _assert(first_truce_day > 0, "should enter TRUCE at least once (pressure rises during phase 1)")
    
    # 2) Pas de raids pendant la fenêtre de TRUCE forcée
    for d in range(first_truce_day, mini(until_day + 1, 31)):
        _assert(actions[d] != &"arc.raid", "no raids during forced TRUCE (day %d had %s)" % [d, actions[d]])
        _assert(goal_types[d] == &"TRUCE", "goal should be TRUCE during forced window (day %d had %s)" % [d, goal_types[d]])

    # 3) Doit restaurer WAR après que la pression redescend
    _assert(saw_restore_war, "should restore WAR after TRUCE window when pressure drops")

    # 4) Après restoration, les raids doivent reprendre
    var raids_after_restore := 0
    for d in range(until_day + 1, 31):
        if goal_types[d] == &"WAR" and actions[d] == &"arc.raid":
            raids_after_restore += 1
    _assert(raids_after_restore >= 1, "should see raids again after WAR restore (got %d)" % raids_after_restore)

    # 5) La pression finale doit être basse
    var final_pressure := dom.pressure()
    _assert(final_pressure < 0.5, "pressure should end low after recovery phase (got %.3f)" % final_pressure)

    # --- Debug output ---
    print("  [DEBUG] first_truce_day=%d, until_day=%d, final_pressure=%.3f" % [first_truce_day, until_day, final_pressure])
    print("  [DEBUG] raids_after_restore=%d" % raids_after_restore)
    
    # Cleanup
    manager.queue_free()
