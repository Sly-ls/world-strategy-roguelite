extends BaseTest
class_name Integration_WarPressureGate_Autoloads_QuestPool

# Domestic state minimal compatible avec DomesticPolicyGate (pressure())
class DomesticState:
    var war_support := 75
    var unrest := 10
    func pressure() -> float:
        return clampf(0.55 * (1.0 - war_support / 100.0) + 0.45 * (unrest / 100.0), 0.0, 1.0)

func _ready() -> void:
    _test_real_autoload_loop_with_goal_stack_and_offers()
    print("\n✅ Integration_WarPressureGate_Autoloads_QuestPool: OK\n")

func _test_real_autoload_loop_with_goal_stack_and_offers() -> void:
    var runner = get_node_or_null("/root/FactionGoalManagerRunner")
    _assert(runner != null, "Missing autoload /root/FactionGoalManagerRunner")

    var planner = get_node_or_null("/root/FactionGoalPlanner")
    _assert(planner != null, "Missing autoload /root/FactionGoalPlanner")

    var quest_pool = get_node_or_null("/root/QuestPool")
    _assert(quest_pool != null, "Missing autoload /root/QuestPool")
    _assert(quest_pool.has_method("try_add_offer"), "QuestPool must expose try_add_offer(inst)")

    # test helpers in QuestPool
    _assert(quest_pool.has_method("_test_snapshot_offers"), "QuestPool needs _test_snapshot_offers() for this test")
    _assert(quest_pool.has_method("_test_clear_offers"), "QuestPool needs _test_clear_offers() for this test")
    _assert(quest_pool.has_method("_test_restore_offers"), "QuestPool needs _test_restore_offers(prev) for this test")

    # goal state API in runner
    _assert(runner.has_method("get_goal_state") and runner.has_method("set_goal_state"),
        "FactionGoalManagerRunner must expose get_goal_state/set_goal_state for clean restore")

    var A := &"A"
    var B := &"B"

    # ---------------- SNAPSHOT & RESET ----------------
    var prev_offers: Array = quest_pool._test_snapshot_offers()
    quest_pool._test_clear_offers()

    var prev_goal = runner.get_goal_state(A)
    runner.set_goal_state(A, {"type": &"WAR", "target_id": B})

    # ---------------- SIM LOOP ----------------
    var dom := DomesticState.new()

    var first_truce_day := -1
    var truce_until := -1
    var saw_restore_war := false

    var raids_pre_15 := 0
    var raids_during_truce := 0

    for day in range(1, 31):
        # pression monte jusqu'à ~J17, puis redescend franchement
        if day <= 17:
            dom.war_support = int(clampi(dom.war_support - 4, 0, 100))
            dom.unrest = int(clampi(dom.unrest + 4, 0, 100))
        else:
            dom.war_support = int(clampi(dom.war_support + 5, 0, 100))
            dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

        var out: Dictionary = runner.tick_day(A, {"day": day, "domestic_state": dom})
        var goal: Dictionary = out.get("goal", {})
        var gt: StringName = StringName(goal.get("type", &""))
        var at: StringName = StringName(out.get("action_type", &"arc.idle"))

        if day < 15 and at == &"arc.raid":
            raids_pre_15 += 1

        if gt == &"TRUCE" and first_truce_day < 0:
            first_truce_day = day
            truce_until = int(goal.get("until_day", day + 7))

        if first_truce_day > 0 and day >= first_truce_day and day <= truce_until:
            if at == &"arc.raid":
                raids_during_truce += 1

        if first_truce_day > 0 and day > truce_until and gt == &"WAR":
            saw_restore_war = true

    # ---------------- ASSERTIONS ----------------
    _assert(raids_pre_15 >= 1, "Expected at least one raid before day 15 (else test doesn't prove gating)")
    _assert(first_truce_day > 0, "Should enter TRUCE at least once (pressure gate)")
    _assert(raids_during_truce == 0, "No raids allowed during forced TRUCE window")
    _assert(saw_restore_war, "Should restore WAR after TRUCE window when pressure drops")

    # Offers spawned (post J15): au moins 1 domestic + 1 truce
    var offers_after: Array = quest_pool._test_snapshot_offers()

    var domestic_post := 0
    var truce_post := 0
    for inst in offers_after:
        # started_on_day existe dans ton modèle (sinon fallback context)
        var sd := 0
        if inst != null and inst.has_method("get"):
            # pas fiable; on préfère accès direct si champ
            pass
        if "started_on_day" in inst:
            sd = int(inst.started_on_day)
        else:
            sd = int(inst.context.get("started_on_day", inst.context.get("day", 0)))

        if sd < 15:
            continue

        if bool(inst.context.get("is_domestic_offer", false)):
            domestic_post += 1
        if StringName(inst.context.get("arc_action_type", &"")) == &"arc.truce_talks":
            truce_post += 1

    _assert(domestic_post >= 1, "Expected >= 1 DOMESTIC offer after day 15")
    _assert(truce_post >= 1, "Expected >= 1 TRUCE offer after day 15")

    # ---------------- RESTORE ----------------
    runner.set_goal_state(A, prev_goal)
    quest_pool._test_restore_offers(prev_offers)
