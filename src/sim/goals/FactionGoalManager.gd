extends Node
class_name FactionGoalManager

# faction_id -> FactionGoalState
var active_goals: Dictionary = {}

func ensure_goal(faction_id: StringName, ctx: Dictionary = {}) -> Dictionary:
    var goal := get_goal_state(faction_id)
    if goal.is_empty():
        goal = {"type": &"IDLE"} # remplace par ton défaut

    # --- HOOK DOMESTIC PRESSURE (non invasif) ---
    var dom = ctx.get("domestic_state", null)
    if dom != null:
        # 1) restore (si TRUCE forcée passée et pressure basse)
        goal = DomesticPolicyGate.maybe_restore_suspended_goal(goal, ctx, dom)

        # 2) force TRUCE + budget_mult_offensive
        goal = DomesticPolicyGate.apply(faction_id, goal, ctx, dom, {
            "pressure_threshold": 0.7,
            "force_days": 7,
            "min_offensive_budget_mult": 0.25
        })

    set_goal_state(faction_id, goal)
    return goal
    
func ensure_goal(faction_id: String) -> FactionGoalState:
    if not active_goals.has(faction_id) or active_goals[faction_id].goal.is_completed():
        var g := FactionGoalFactory.create_goal(faction_id)
        active_goals[faction_id] = FactionGoalState.new(g)
        print("🎯 New goal for %s: %s" % [faction_id, g.title])
    return active_goals[faction_id]

func get_goal_state(faction_id: String) -> FactionGoalState:
    return active_goals.get(faction_id, null)

func complete_goal(faction_id: String) -> void:
    var st: FactionGoalState = active_goals.get(faction_id, null)
    if st == null:
        return
    var g := st.goal

    print("🏁 Goal completed for %s: %s" % [faction_id, g.title])

    # Impact monde
    for t in g.on_complete_world_tags:
        QuestManager.add_world_tag(t)

    # Impact relations (si cible)
    if g.target_faction_id != "" and g.on_complete_relation_delta != 0:
        var new_rel := FactionManager.get_relation_between(g.actor_faction_id, g.target_faction_id) + g.on_complete_relation_delta
        FactionManager.set_relation_between(g.actor_faction_id, g.target_faction_id, new_rel)

    # On force un nouveau goal au prochain tick
    active_goals.erase(faction_id)
    
func set_goal_state(faction_id: StringName, goal: Dictionary) -> void:
    active_goals[faction_id] = goal
