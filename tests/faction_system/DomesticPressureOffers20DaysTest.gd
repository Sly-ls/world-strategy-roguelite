extends Node
class_name DomesticPressureOffers20DaysTest

class TestQuestPool:
    var offers: Array = []
    func try_add_offer(inst) -> bool:
        offers.append(inst)
        return true

class TestArcNotebook:
    var last_domestic: Dictionary = {}
    var last_truce: Dictionary = {}
    var faction_counters: Dictionary = {}

    func can_spawn_domestic_offer(faction_id: StringName, day: int, cooldown: int) -> bool:
        return (day - int(last_domestic.get(faction_id, -999999))) >= cooldown
    func mark_domestic_offer_spawned(faction_id: StringName, day: int) -> void:
        last_domestic[faction_id] = day

    func can_spawn_truce_offer(a: StringName, b: StringName, day: int, cooldown: int) -> bool:
        var k := StringName(String(a) + "|" + String(b))
        return (day - int(last_truce.get(k, -999999))) >= cooldown
    func mark_truce_offer_spawned(a: StringName, b: StringName, day: int) -> void:
        var k := StringName(String(a) + "|" + String(b))
        last_truce[k] = day

    func set_faction_counter(fid: StringName, name: StringName, val: int) -> void:
        if not faction_counters.has(fid):
            faction_counters[fid] = {}
        faction_counters[fid][name] = val
    func get_faction_counter(fid: StringName, name: StringName, default_val: int = 0) -> int:
        if not faction_counters.has(fid): return default_val
        return int(faction_counters[fid].get(name, default_val))


func _ready() -> void:
    _test_20_days_war_support_drops_and_spawns_truce_and_domestic()
    print("\n✅ DomesticPressureOffers20DaysTest: OK\n")
    get_tree().quit()


func _test_20_days_war_support_drops_and_spawns_truce_and_domestic() -> void:
    var A := &"A"
    var B := &"B"

    var dom := FactionDomesticState.new(70,75,10)
    var eco := FactionEconomy.new(120)
    var pool := TestQuestPool.new()
    var nb := TestArcNotebook.new()

    # simulate "20 days of war" via war_days_rolling_30 counter + tick_domestic
    var relations := {A: {B: FactionRelationScore.new()}} # minimal (not used by tick in this test)
    var profile := {"personality": {&"diplomacy": 0.3, &"honor": 0.5, &"belligerence": 0.7, &"fear": 0.6}}
    var world := {"crisis_active": false}

    var saw_domestic := false
    var saw_truce := false

    for day in range(1, 21):
        # “guerre continue” : 1..20
        nb.set_faction_counter(A, &"war_days_rolling_30", day)

        # tick domestic pressure
        DomesticPressureUtil.tick_domestic(day, A, dom, profile, eco, nb, relations, world)

        # spawn domestic offer if needed
        var inst_dom = DomesticOfferFactory.spawn_offer_if_needed(A, dom, day, pool, nb, eco, {"cooldown_days": 3})
        if inst_dom != null:
            saw_domestic = true

        # spawn truce if needed (linked to domestic pressure/war_support)
        var inst_truce = ArcTruceOfferFactory.spawn_truce_offer_if_needed(A, B, dom, day, pool, nb)
        if inst_truce != null:
            saw_truce = true

    # Assertions
    _assert(dom.war_support <= 35, "war_support should drop significantly after 20 war days (got %d)" % dom.war_support)
    _assert(saw_domestic, "should spawn at least one domestic offer within 20 war days")
    _assert(saw_truce, "should spawn at least one TRUCE offer when pressure high / war_support low")

    # Bonus: ensure we really have both types in pool
    var dom_count := 0
    var truce_count := 0
    for inst in pool.offers:
        if bool(inst.context.get("is_domestic_offer", false)): dom_count += 1
        if StringName(inst.context.get("arc_action_type", &"")) == &"arc.truce_talks": truce_count += 1

    _assert(dom_count >= 1, "pool should contain domestic offers")
    _assert(truce_count >= 1, "pool should contain truce offers")


func _assert(cond: bool, msg: String) -> void:
    if not cond:
        push_error("TEST FAIL: " + msg)
        assert(false)
