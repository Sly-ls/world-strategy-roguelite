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
    pass_test("✅ IntegrationRealRunnersGoalStackTest: OK")


func _test_real_runners_goal_stack_restore() -> void:
    var A := &"A"
    var B := &"B"

    # --- récupérer ou instancier le FactionGoalManager ---
    var manager: FactionGoalManager = get_node_or_null("/root/FactionGoalManager")
    if manager == null:
        manager = FactionGoalManager.new()
        add_child(manager)

    # --- init goal WAR avec FactionGoalState ---
    var war_goal := FactionGoal.new()
    war_goal.id = "war_A_B"
    war_goal.type = FactionGoal.GoalType.START_WAR
    war_goal.title = "Guerre contre B"
    war_goal.actor_faction_id = String(A)
    war_goal.target_faction_id = String(B)
    
    # Ajouter une step pour que is_completed() retourne false
    var step := FactionGoalStep.new()
    step.id = "mobilize"
    step.title = "Mobiliser"
    step.required_amount = 10
    war_goal.steps = [step]
    
    # Utiliser set_goal au lieu de set_goal_state
    manager.set_goal(String(A), war_goal)

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
            dom.war_support = clampi(dom.war_support - 4, 0, 100)
            dom.unrest = clampi(dom.unrest + 4, 0, 100)
        else:
            dom.war_support = clampi(dom.war_support + 5, 0, 100)
            dom.unrest = clampi(dom.unrest - 6, 0, 100)

        var ctx := {
            "day": day,
            "current_day": day,
            "faction_id": A,
            "domestic_state": dom,
            "budget_points": 10
        }

        # ensure_goal retourne maintenant FactionGoalState
        var goal_state: FactionGoalState = manager.ensure_goal(String(A), ctx)
        
        # Déterminer le type de goal
        var goal_type: StringName
        if goal_state.is_forced():
            goal_type = &"TRUCE"
        elif goal_state.goal != null and goal_state.goal.type == FactionGoal.GoalType.START_WAR:
            goal_type = &"WAR"
        else:
            goal_type = &"IDLE"

        # Action basée sur le goal state
        var action_type: StringName
        if goal_type == &"TRUCE":
            action_type = &"arc.truce_talks"
        elif goal_type == &"WAR":
            # Vérifier si on peut afford un raid
            var mult := goal_state.budget_mult_offensive
            var raid_cost := int(ceil(10.0 / max(0.01, mult)))
            if 10 >= raid_cost:  # budget_points >= cost
                action_type = &"arc.raid"
            else:
                action_type = &"arc.defend"
        else:
            action_type = &"arc.idle"

        # offers (comme ta boucle monde le ferait)
        if DomesticOfferFactory != null:
            DomesticOfferFactory.spawn_offer_if_needed(A, dom, day, pool, nb, null, {"cooldown_days": 3})
        if ArcTruceOfferFactory != null:
            ArcTruceOfferFactory.spawn_truce_offer_if_needed(A, B, dom, day, pool, nb)

        if goal_type == &"TRUCE" and first_truce_day < 0:
            first_truce_day = day
            until_day = goal_state.forced_until_day if goal_state.forced_until_day > 0 else (day + 7)

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
        var started_day: int = int(inst.get("started_on_day", 0)) if inst is Dictionary else (inst.started_on_day if "started_on_day" in inst else 0)
        if started_day < 15:
            continue
        var ctx_dict: Dictionary = inst.get("context", {}) if inst is Dictionary else (inst.context if "context" in inst else {})
        if StringName(ctx_dict.get("arc_action_type", &"")) == &"arc.truce_talks":
            truce_offers += 1
        if bool(ctx_dict.get("is_domestic_offer", false)):
            domestic_offers += 1

    _assert(truce_offers >= 1, "expected >=1 TRUCE offer after day 15")
    _assert(domestic_offers >= 1, "expected >=1 DOMESTIC offer after day 15")
