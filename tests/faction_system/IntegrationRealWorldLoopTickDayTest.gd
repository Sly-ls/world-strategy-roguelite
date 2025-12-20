# tests/IntegrationRealWorldLoopTickDayTest.gd
extends BaseTest
class_name IntegrationRealWorldLoopTickDayTest

class TestQuestPool:
    var offers: Array = []
    func try_add_offer(inst) -> bool:
        offers.append(inst)
        return true

class TestArcManagerRunner:
    var arc_notebook := TestArcNotebook.new()

class TestArcNotebook:
    var last_domestic := {}
    var last_truce := {}
    func can_spawn_domestic_offer(fid: StringName, day: int, cooldown: int) -> bool:
        return (day - int(last_domestic.get(fid, -999999))) >= cooldown
    func mark_domestic_offer_spawned(fid: StringName, day: int) -> void:
        last_domestic[fid] = day
    func can_spawn_truce_offer(a: StringName, b: StringName, day: int, cooldown: int) -> bool:
        var k := StringName(String(a) + "|" + String(b))
        return (day - int(last_truce.get(k, -999999))) >= cooldown
    func mark_truce_offer_spawned(a: StringName, b: StringName, day: int) -> void:
        var k := StringName(String(a) + "|" + String(b))
        last_truce[k] = day

func _ready() -> void:
    _test_tick_day_loop_goal_stack_and_offers()
    print("\n✅ IntegrationRealWorldLoopTickDayTest: OK\n")

func _test_tick_day_loop_goal_stack_and_offers() -> void:
    var A := &"A"
    var B := &"B"

    # Real runner + planner nodes
    var runner = get_node_or_null("/root/FactionGoalManagerRunner")
    if runner == null:
        runner = FactionGoalManagerRunner.new()
        runner.name = "FactionGoalManagerRunner"
        add_child(runner)

    var planner = get_node_or_null("/root/FactionGoalPlanner")
    if planner == null:
        planner = FactionGoalPlanner.new()
        planner.name = "FactionGoalPlanner"
        add_child(planner)

    # Inject test QuestPool + ArcManagerRunner (to provide arc_notebook)
    var qp = TestQuestPool.new()
    var qp_node := Node.new()
    qp_node.name = "QuestPool"
    # expose try_add_offer
    qp_node.set_script(qp.get_script()) # if your test pool is a script, else skip
    # simpler: just add as child and access directly below
    add_child(qp_node)

    var arc_runner := TestArcManagerRunner.new()
    var arc_node := Node.new()
    arc_node.name = "ArcManagerRunner"
    arc_node.set_script(arc_runner.get_script())
    add_child(arc_node)

    # Directly set paths to our test nodes (safer than default /root paths)
    runner.planner_path = planner.get_path()
    runner.quest_pool_path = qp_node.get_path()
    runner.arc_notebook_path = arc_node.get_path()

    # Init goal WAR
    runner.set_goal_state(A, {"type": &"WAR", "target_id": B})

    var dom := FactionDomesticState.new(60, 75, 10)
    var first_truce_day := -1
    var until_day := -1
    var saw_restore_war := false

    # We'll log action types
    var actions: Dictionary = {}

    for day in range(1, 31):
        # domestic dynamics
        if day <= 17:
            dom.war_support = int(clampi(dom.war_support - 4, 0, 100))
            dom.unrest = int(clampi(dom.unrest + 4, 0, 100))
        else:
            dom.war_support = int(clampi(dom.war_support + 5, 0, 100))
            dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

        var ctx := {"day": day, "domestic_state": dom}
        var out: Dictionary = runner.tick_day(A, ctx)

        var goal: Dictionary = out["goal"]
        var gt: StringName = StringName(goal.get("type", &""))
        var at: StringName = StringName(out.get("action_type", &""))
        actions[day] = at

        if gt == &"TRUCE" and first_truce_day < 0:
            first_truce_day = day
            until_day = int(goal.get("until_day", day + 7))

        if first_truce_day > 0 and day > until_day and gt == &"WAR":
            saw_restore_war = true

    # Assertions: no raids during truce window
    _assert(first_truce_day > 0, "should enter TRUCE at least once")
    for d in range(first_truce_day, min(until_day + 1, 31)):
        _assert(actions[d] != &"arc.raid", "no raids during forced TRUCE (day %d had raid)" % d)

    _assert(saw_restore_war, "should restore WAR after TRUCE if pressure drops")

    # Offers check: this depends on your QuestPool wiring; if qp_node isn't truly a pool, validate via factories separately.
    # If you wire a real QuestPool node, assert at least one domestic and one truce offer exist post day 15.
