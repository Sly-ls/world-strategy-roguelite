# tests/IntegrationRealRunnersGoalStackTest.gd
extends BaseTest
class_name IntegrationRealRunnersGoalStackTest

class TestQuestPool:
    var offers: Array = []
    func try_add_offer(inst) -> bool:
        offers.append(inst)
        return true

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
    _test_real_runners_goal_stack_restore()
    print("\n✅ IntegrationRealRunnersGoalStackTest: OK\n")

func _test_real_runners_goal_stack_restore() -> void:
    var A := &"A"
    var B := &"B"

    # --- récupérer ou instancier les vrais runners ---
    var runner = get_node_or_null("/root/FactionGoalManagerRunner")
    if runner == null:
        runner = FactionGoalManagerRunner.new()
        add_child(runner)

    var planner = get_node_or_null("/root/FactionGoalPlanner")
    if planner == null:
        planner = FactionGoalPlanner.new()
        add_child(planner)

    # --- init goal WAR ---
    runner.set_goal_state(A, {"type": &"WAR", "target_id": B})

    var dom := FactionDomesticState.new(60, 75, 10)
    var pool := TestQuestPool.new()
    var nb := TestArcNotebook.new()

    var first_truce_day := -1
    var until_day := -1
    var saw_restore_war := false
    var raids_after_restore := 0

    for day in range(1, 31):
        # domestic dynamics
        if day <= 17:
            dom.war_support = int(clampi(dom.war_support - 4, 0, 100))
            dom.unrest = int(clampi(dom.unrest + 4, 0, 100))
        else:
            dom.war_support = int(clampi(dom.war_support + 5, 0, 100))
            dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

        var ctx := {
            "day": day,
            "faction_id": A,
            "domestic_state": dom,
            "budget_points": 10
        }

        var goal :FactionGoalState = runner.ensure_goal(A, ctx)
        var goal_type: StringName = StringName(goal["type"] if "type" in goal else (&""))

        # action via vrai planner
        var act_v = planner.plan_action(goal, ctx)
        var action_type: StringName = act_v if act_v is StringName else StringName(act_v.get("type", &""))

        # offers (comme ta boucle monde le ferait)
        DomesticOfferFactory.spawn_offer_if_needed(A, dom, day, pool, nb, null, {"cooldown_days": 3})
        ArcTruceOfferFactory.spawn_truce_offer_if_needed(A, B, dom, day, pool, nb)

        if goal_type == &"TRUCE" and first_truce_day < 0:
            first_truce_day = day
            until_day = int(goal["until_day"] if "until_day" in goal else (day + 7))

        if first_truce_day > 0 and day >= first_truce_day and day <= until_day:
            _assert(goal_type == &"TRUCE", "goal must stay TRUCE during forced window (day %d)" % day)
            _assert(action_type == &"arc.truce_talks", "no raids during TRUCE (day %d had %s)" % [day, String(action_type)])

        if first_truce_day > 0 and day > until_day and goal_type == &"WAR":
            saw_restore_war = true
            if action_type == &"arc.raid":
                raids_after_restore += 1

    # --- asserts ---
    _assert(first_truce_day > 0, "should enter TRUCE at least once")
    _assert(saw_restore_war, "should restore WAR after TRUCE window when pressure drops")
    _assert(raids_after_restore >= 1, "should see raids again after restore (got %d)" % raids_after_restore)

    # offers post J15
    var truce_offers := 0
    var domestic_offers := 0
    for inst in pool.offers:
        if int(inst.started_on_day) < 15:
            continue
        if StringName(inst.context.get("arc_action_type", &"")) == &"arc.truce_talks":
            truce_offers += 1
        if bool(inst.context.get("is_domestic_offer", false)):
            domestic_offers += 1

    _assert(truce_offers >= 1, "expected >=1 TRUCE offer after day 15")
    _assert(domestic_offers >= 1, "expected >=1 DOMESTIC offer after day 15")
