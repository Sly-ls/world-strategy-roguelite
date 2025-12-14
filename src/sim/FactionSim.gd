# res://src/sim/FactionSim.gd
extends Node
class_name FactionSim

func run_day(actions_per_day: int) -> void:
    var factions := FactionManager.get_all_factions()
    if factions.is_empty():
        return

    for i in range(actions_per_day):
        var f = factions.pick_random()

        var st := FactionGoalManagerRunner.ensure_goal(f.id)
        var action := FactionGoalPlanner.plan_action(st.goal)
        if action == null:
            continue

        FactionActionResolverRunner.apply(action)
        
func _execute_action_for_faction(faction_id: String) -> void:
    var action := FactionActionFactoryRunner.pick_action(faction_id)
    if action == null:
        return
    FactionActionResolverRunner.apply(action)
