extends Resource
class_name FactionGoal

enum GoalType { BUILD_DOMAIN, START_WAR, PURIFY, SPREAD_CORRUPTION, GAIN_ALLY }

@export var id: String = ""
@export var type: GoalType
@export var title: String = ""
@export var actor_faction_id: String = ""
@export var target_faction_id: String = ""
@export var domain: String = ""  # "divine/tech/nature/magic/corruption"
@export var steps: Array[FactionGoalStep] = []
@export var on_complete_world_tags: Array[String] = []
@export var on_complete_relation_delta: int = 0

var current_step_index: int = 0

func get_current_step() -> FactionGoalStep:
    if current_step_index < 0 or current_step_index >= steps.size():
        return null
    return steps[current_step_index]

func is_completed() -> bool:
    return current_step_index >= steps.size()

func advance_if_step_done() -> void:
    var step := get_current_step()
    if step != null and step.is_done():
        current_step_index += 1
