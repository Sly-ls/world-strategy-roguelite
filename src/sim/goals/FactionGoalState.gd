extends RefCounted
class_name FactionGoalState

var goal: FactionGoal
var last_action: String = ""
var started_day: int = 0

func _init(g: FactionGoal) -> void:
    goal = g
    started_day = WorldState.current_day
