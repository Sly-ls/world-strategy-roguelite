# tests/Integration_WarPressureGate_Autoloads.gd
extends BaseTest
class_name Integration_WarPressureGate_Autoloads

class DomesticState:
    var war_support := 75
    var unrest := 10
    func pressure() -> float:
        # même formule que ce qu’on a discuté : simple, stable
        return clampf(0.55 * (1.0 - war_support / 100.0) + 0.45 * (unrest / 100.0), 0.0, 1.0)

func _ready() -> void:
    _test_world_loop_uses_real_autoloads()
    print("\n✅ Integration_WarPressureGate_Autoloads: OK\n")

func _test_world_loop_uses_real_autoloads() -> void:
    var runner = get_node_or_null("/root/FactionGoalManagerRunner")
    _assert(runner != null, "Missing autoload /root/FactionGoalManagerRunner")

    # Offer sink réel (celui qui a try_add_offer)
    var offer_sink: Node = null
    for n in ["QuestPool", "QuestOfferSimRunner", "QuestOfferPool", "QuestOffers"]:
        var cand = get_node_or_null("/root/" + n)
        if cand != null and cand.has_method("try_add_offer"):
            offer_sink = cand
            break
    _assert(offer_sink != null, "No offer sink autoload found (need try_add_offer)")

    var world = get_node_or_null("/root/WorldGameState") # si tu l’as
    var A := &"A"
    var B := &"B"

    # --- SNAPSHOT minimal ---
    var snap := {}

    # World day
    if world != null and world.has_variable("current_day"):
        snap["prev_day"] = int(world.current_day)

    # Offers
    snap["offers_prev"] = _snapshot_offers(offer_sink)
    _clear_offers(offer_sink)

    # Goal state A (on snapshot ce qu’on peut)
    snap["goal_prev"] = _snapshot_goal_state(runner, A)
    _set_goal_state(runner, A, {"type": &"WAR", "target_id": B})

    # --- Simulation ---
    var dom := DomesticState.new()

    var first_truce_day := -1
    var truce_until := -1
    var saw_restore_war := false

    var offensive_actions_during_truce := 0

    for day in range(1, 31):
        # Pilote la pression :
        # J1..J17 -> pression monte (support↓, unrest↑)
        # J18..J30 -> pression baisse (support↑, unrest↓)
        if day <= 17:
            dom.war_support = int(clampi(dom.war_support - 4, 0, 100))
            dom.unrest = int(clampi(dom.unrest + 4, 0, 100))
        else:
            dom.war_support = int(clampi(dom.war_support + 5, 0, 100))
            dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

        if world != null and world.has_variable("current_day"):
            world.current_day = day

        var out: Dictionary = runner.tick_day(A, {"day": day, "domestic_state": dom})
        var goal: Dictionary = out.get("goal", {})
        var gt: StringName = StringName(goal.get("type", &""))
        var at: StringName = StringName(out.get("action_type", &"arc.idle"))

        # détecter entrée en TRUCE
        if gt == &"TRUCE" and first_truce_day < 0:
            first_truce_day = day
            truce_until = int(goal.get("until_day", day + 7))

        # compter offensives pendant TRUCE (liste simple, adapte si tu as d’autres types)
        if first_truce_day > 0 and day >= first_truce_day and day <= truce_until:
            if at in [&"arc.raid", &"arc.sabotage", &"arc.attack", &"arc.declare_war"]:
                offensive_actions_during_truce += 1

        # vérifier restore WAR après TRUCE
        if first_truce_day > 0 and day > truce_until and gt == &"WAR":
            saw_restore_war = true

    # --- Assertions ---
    _assert(first_truce_day > 0, "Should enter TRUCE at least once (pressure gate)")
    _assert(truce_until >= first_truce_day, "TRUCE until_day invalid")
    _assert(offensive_actions_during_truce == 0, "No offensive actions allowed during TRUCE window")
    _assert(saw_restore_war, "Should restore WAR after TRUCE when pressure drops")

    # Offers spawned check (simple : au moins 1 offer en période de pression haute)
    var offers_after = _snapshot_offers(offer_sink)
    _assert(offers_after.size() >= 1, "Expected at least 1 offer spawned during loop")

    # --- RESTORE ---
    _restore_goal_state(runner, A, snap["goal_prev"])
    _restore_offers(offer_sink, snap["offers_prev"])
    if world != null and snap.has("prev_day"):
        world.current_day = snap["prev_day"]

func _snapshot_offers(offer_sink: Node) -> Array:
    # essaye plusieurs layouts
    if offer_sink.has_variable("offers") and offer_sink.offers is Array:
        return offer_sink.offers.duplicate(true)
    if offer_sink.has_method("get_offers"):
        var arr = offer_sink.get_offers()
        return arr.duplicate(true) if (arr is Array) else []
    return []

func _clear_offers(offer_sink: Node) -> void:
    if offer_sink.has_method("_test_clear_offers"):
        offer_sink._test_clear_offers()
        return
    if offer_sink.has_variable("offers") and offer_sink.offers is Array:
        offer_sink.offers.clear()

func _restore_offers(offer_sink: Node, prev: Array) -> void:
    _clear_offers(offer_sink)
    if offer_sink.has_variable("offers") and offer_sink.offers is Array:
        for o in prev:
            offer_sink.offers.append(o)

func _snapshot_goal_state(runner: Node, faction_id: StringName) -> Variant:
    if runner.has_method("get_goal_state"):
        return runner.get_goal_state(faction_id)
    if runner.has_variable("goals_by_faction"):
        return runner.goals_by_faction.get(faction_id, null)
    return null

func _set_goal_state(runner: Node, faction_id: StringName, goal: Dictionary) -> void:
    if runner.has_method("set_goal_state"):
        runner.set_goal_state(faction_id, goal)
        return
    if runner.has_variable("goals_by_faction"):
        runner.goals_by_faction[faction_id] = goal

func _restore_goal_state(runner: Node, faction_id: StringName, prev: Variant) -> void:
    if prev == null:
        # clear
        if runner.has_variable("goals_by_faction"):
            runner.goals_by_faction.erase(faction_id)
        return
    _set_goal_state(runner, faction_id, prev)
