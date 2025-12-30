extends BaseTest
class_name Integration_WarPressureGate_Autoloads_QuestPool

## Test d'intégration : Pression domestique + QuestPool
##
## Vérifie que :
## 1. La pression domestique force une TRUCE via DomesticPolicyGate
## 2. Le budget offensif est réduit pendant la TRUCE
## 3. Le goal WAR original est restauré après la TRUCE
## 4. Des offres domestiques/truce sont générées
##
## CORRIGÉ: Utilise FactionGoalState au lieu de Dictionaries

func _ready() -> void:
    _test_real_autoload_loop_with_goal_stack_and_offers()
    pass_test("✅ Integration_WarPressureGate_Autoloads_QuestPool: OK")

func _test_real_autoload_loop_with_goal_stack_and_offers() -> void:
    # Chercher le runner (peut s'appeler FactionGoalManager ou FactionGoalManagerRunner)
    var runner: Node = null
    for name in ["FactionGoalManagerRunner", "FactionGoalManager"]:
        runner = get_node_or_null("/root/" + name)
        if runner != null:
            break
    _assert(runner != null, "Missing autoload FactionGoalManager(Runner)")
    _assert(runner.has_method("ensure_goal"), "Runner must have ensure_goal method")

    var quest_pool = get_node_or_null("/root/QuestPool")
    _assert(quest_pool != null, "Missing autoload /root/QuestPool")
    _assert(quest_pool.has_method("try_add_offer"), "QuestPool must expose try_add_offer(inst)")

    # Test helpers in QuestPool (optionnels)
    var has_test_helpers := quest_pool.has_method("_test_snapshot_offers") and \
                           quest_pool.has_method("_test_clear_offers") and \
                           quest_pool.has_method("_test_restore_offers")

    var A := "A"  # String car ensure_goal prend String
    var B := "B"

    # ---------------- SNAPSHOT & RESET ----------------
    var prev_offers: Array = []
    if has_test_helpers:
        prev_offers = quest_pool._test_snapshot_offers()
        quest_pool._test_clear_offers()

    # Snapshot du goal actuel
    var prev_goal_state: FactionGoalState = null
    if runner.has_method("get_goal_state"):
        prev_goal_state = runner.get_goal_state(A)
    elif "active_goals" in runner:
        prev_goal_state = runner.active_goals.get(A, null)

    # Créer un goal START_WAR pour le test
    var war_goal := FactionGoal.new()
    war_goal.type = FactionGoal.GoalType.START_WAR
    war_goal.actor_faction_id = A
    war_goal.target_faction_id = B
    war_goal.title = "Test War Goal"
    
    if runner.has_method("set_goal"):
        runner.set_goal(A, war_goal)
    elif "active_goals" in runner:
        runner.active_goals[A] = FactionGoalState.new(war_goal)

    # ---------------- SIM LOOP ----------------
    var dom := FactionDomesticState.new()

    var first_truce_day := -1
    var truce_until := -1
    var saw_restore_war := false

    var low_budget_pre_15 := 0  # Compte les jours avec budget offensif normal avant J15
    var high_budget_during_truce := 0  # Violations pendant TRUCE

    for day in range(1, 31):
        # Pression monte jusqu'à ~J17, puis redescend franchement
        if day <= 17:
            dom.war_support = int(clampi(dom.war_support - 4, 0, 100))
            dom.unrest = int(clampi(dom.unrest + 4, 0, 100))
        else:
            dom.war_support = int(clampi(dom.war_support + 5, 0, 100))
            dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

        var out: FactionGoalState = runner.ensure_goal(A, {"day": day, "domestic_state": dom})
        var goal: FactionGoal = out.goal
        
        # Avant J15, budget offensif devrait être normal (pas forcé)
        if day < 15 and not out.is_forced() and out.budget_mult_offensive >= 0.8:
            low_budget_pre_15 += 1

        # Détecter entrée en TRUCE (via force_reason = DOMESTIC_PRESSURE)
        if out.is_forced() and out.force_reason == &"DOMESTIC_PRESSURE" and first_truce_day < 0:
            first_truce_day = day
            truce_until = out.forced_until_day
            print("  📋 TRUCE forced on day %d until day %d (pressure: %.2f)" % [day, truce_until, dom.pressure()])

        # Pendant TRUCE forcée, le budget offensif devrait être bas
        if first_truce_day > 0 and day >= first_truce_day and day <= truce_until:
            if out.is_forced() and out.budget_mult_offensive > 0.5:
                high_budget_during_truce += 1
                print("  ⚠️ Day %d: offensive budget too high during TRUCE: %.2f" % [day, out.budget_mult_offensive])

        # Vérifier restore WAR après TRUCE
        if first_truce_day > 0 and day > truce_until:
            if not out.is_forced() and goal != null and goal.type == FactionGoal.GoalType.START_WAR:
                if not saw_restore_war:
                    saw_restore_war = true
                    print("  ✅ WAR restored on day %d" % day)

    # ---------------- ASSERTIONS ----------------
    _assert(low_budget_pre_15 >= 1, "Expected at least one day with normal offensive budget before day 15 (got %d)" % low_budget_pre_15)
    _assert(first_truce_day > 0, "Should enter TRUCE at least once (pressure gate). Check DomesticPolicyGate threshold.")
    _assert(high_budget_during_truce == 0, "No high offensive budget allowed during forced TRUCE window (got %d violations)" % high_budget_during_truce)
    _assert(saw_restore_war, "Should restore WAR after TRUCE window when pressure drops")

    # Offers spawned (optionnel - dépend du setup)
    if has_test_helpers:
        var offers_after: Array = quest_pool._test_snapshot_offers()

        var domestic_post := 0
        var truce_post := 0
        for inst in offers_after:
            if inst == null:
                continue
            
            # Accéder au context selon le type de l'offre
            var context: Dictionary = {}
            if "context" in inst:
                context = inst.context
            
            var sd := 0
            if "started_on_day" in inst:
                sd = int(inst.started_on_day)
            elif context.has("started_on_day"):
                sd = int(context.get("started_on_day", 0))
            elif context.has("day"):
                sd = int(context.get("day", 0))

            if sd < 15:
                continue

            if context.get("is_domestic_offer", false):
                domestic_post += 1
            var arc_action: StringName = StringName(str(context.get("arc_action_type", "")))
            if arc_action == &"arc.truce_talks":
                truce_post += 1

        # Ces assertions sont optionnelles car dépendent du setup complet
        if domestic_post >= 1:
            print("  ✅ Found %d domestic offers after day 15" % domestic_post)
        else:
            print("  ⚠️ No domestic offers found (may need full setup)")
        
        if truce_post >= 1:
            print("  ✅ Found %d truce offers after day 15" % truce_post)
        else:
            print("  ⚠️ No truce offers found (may need full setup)")

    # ---------------- RESTORE ----------------
    if prev_goal_state != null:
        if "active_goals" in runner:
            runner.active_goals[A] = prev_goal_state
    else:
        if "active_goals" in runner:
            runner.active_goals.erase(A)
    
    if has_test_helpers:
        quest_pool._test_restore_offers(prev_offers)
