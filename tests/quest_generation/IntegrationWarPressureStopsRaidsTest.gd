# tests/IntegrationWarPressureStopsRaidsTest.gd
extends BaseTest
class_name IntegrationWarPressureStopsRaidsTest

## Test d'intégration: la pression de guerre stoppe les raids après J15
## et génère des offres de trêve/domestique

class TestQuestPool:
    var offers: Array = []
    func try_add_offer(inst) -> bool:
        offers.append(inst)
        return true


class TestArcNotebook:
    var last_domestic: Dictionary = {}
    var last_truce: Dictionary = {}

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


# Planner mini (intégration du gate + budget inflation)
class PlannerSim:
    func _is_offensive(action: StringName) -> bool:
        return action == &"arc.raid" or action == &"arc.declare_war" or action == &"arc.sabotage"

    func _can_afford(action: StringName, base_cost: int, goal_state: FactionGoalState) -> bool:
        var budget := 10  # Budget fixe pour le test
        var mult := goal_state.budget_mult_offensive
        var cost := base_cost
        if _is_offensive(action):
            cost = int(ceil(float(base_cost) / max(0.01, mult)))
        return budget >= cost

    func plan_action(goal_state: FactionGoalState, ctx: Dictionary) -> StringName:
        var fid: StringName = ctx["faction_id"]
        var dom = ctx.get("domestic_state", null)
        
        # Appliquer DomesticPolicyGate si domestic_state fourni
        if dom != null:
            goal_state = DomesticPolicyGate.apply(fid, goal_state, ctx, dom, {
                "pressure_threshold": 0.7,
                "force_days": 7,
                "min_offensive_budget_mult": 0.25
            })

        # TRUCE (goal forcé) => truce talks
        if goal_state.is_forced():
            return &"arc.truce_talks"

        # WAR => préfère raid si possible
        if goal_state.goal != null and goal_state.goal.type == FactionGoal.GoalType.START_WAR:
            if _can_afford(&"arc.raid", 10, goal_state):
                return &"arc.raid"
            return &"arc.defend"

        return &"arc.idle"


func _ready() -> void:
    _test_20_days_war_pressure_stops_raids_after_day15_and_spawns_truce_domestic()
    pass_test("\n✅ IntegrationWarPressureStopsRaidsTest: OK\n")


func _test_20_days_war_pressure_stops_raids_after_day15_and_spawns_truce_domestic() -> void:
    var A := &"A"
    var B := &"B"

    var pool := TestQuestPool.new()
    var nb := TestArcNotebook.new()
    var planner := PlannerSim.new()

    # Domestic state
    var dom := FactionDomesticState.new(60, 75, 10)

    # Economy (optionnel - vérifier si la classe existe)
    var economy = null
    if ClassDB.class_exists("FactionEconomy"):
        economy = FactionEconomy.new(20)

    # Créer un goal WAR avec FactionGoalState
    var war_goal := FactionGoal.new()
    war_goal.id = "war_A_B"
    war_goal.type = FactionGoal.GoalType.START_WAR
    war_goal.title = "Guerre contre B"
    war_goal.actor_faction_id = String(A)
    war_goal.target_faction_id = String(B)
    
    # Ajouter une step pour que is_completed() = false
    var step := FactionGoalStep.new()
    step.id = "mobilize"
    step.title = "Mobiliser"
    step.required_amount = 10
    war_goal.steps = [step]
    
    var goal_state := FactionGoalState.new(war_goal)

    # Sim config
    var actions_by_day: Dictionary = {}

    # On force une montée déterministe de la pression (sim "guerre longue")
    # => à J15 on passe typiquement > 0.7
    for day in range(1, 21):
        # Approx: chaque jour de guerre, support↓ et unrest↑
        dom.war_support = clampi(dom.war_support - 4, 0, 100)
        dom.unrest = clampi(dom.unrest + 4, 0, 100)

        var ctx := {
            "day": day,
            "current_day": day,
            "faction_id": A,
            "domestic_state": dom,
            "budget_points": 10
        }

        # 1) plan action (gate intégré dans planner)
        var act: StringName = planner.plan_action(goal_state, ctx)
        actions_by_day[day] = act

        # 2) spawn offers : domestic + truce (comme en prod)
        if DomesticOfferFactory != null:
            DomesticOfferFactory.spawn_offer_if_needed(A, dom, day, pool, nb, economy, {"cooldown_days": 3})
        if ArcTruceOfferFactory != null:
            ArcTruceOfferFactory.spawn_truce_offer_if_needed(A, B, dom, day, pool, nb)

    # ---- Assertions ----

    # A) Il y a des raids avant J15 (sinon le test ne prouve rien)
    var raids_pre := 0
    for day in range(1, 15):
        if actions_by_day[day] == &"arc.raid":
            raids_pre += 1
    _assert(raids_pre >= 1, "should have at least one raid before day 15 (got %d)" % raids_pre)

    # B) Plus aucun raid à partir de J15
    for day in range(15, 21):
        _assert(actions_by_day[day] != &"arc.raid", "no raids expected from day 15 (day %d had %s)" % [day, String(actions_by_day[day])])

    # C) On a au moins une offre TRUCE à partir de J15
    var truce_offer_post := 0
    var domestic_offer_post := 0
    for inst in pool.offers:
        var sd: int
        if inst is Dictionary:
            sd = int(inst.get("started_on_day", inst.get("context", {}).get("day", 0)))
        elif "started_on_day" in inst:
            sd = int(inst.started_on_day)
        elif "context" in inst:
            sd = int(inst.context.get("day", 0))
        else:
            sd = 0
        
        if sd < 15:
            continue
        
        var ctx_dict: Dictionary
        if inst is Dictionary:
            ctx_dict = inst.get("context", {})
        elif "context" in inst:
            ctx_dict = inst.context
        else:
            ctx_dict = {}
        
        if StringName(ctx_dict.get("arc_action_type", &"")) == &"arc.truce_talks":
            truce_offer_post += 1
        if bool(ctx_dict.get("is_domestic_offer", false)):
            domestic_offer_post += 1

    _assert(truce_offer_post >= 1, "expected at least one TRUCE offer from day 15+")
    _assert(domestic_offer_post >= 1, "expected at least one DOMESTIC offer from day 15+")

    # D) Bonus : pression bien élevée
    _assert(dom.pressure() > 0.7, "pressure should end above 0.7 (got %.3f)" % dom.pressure())
