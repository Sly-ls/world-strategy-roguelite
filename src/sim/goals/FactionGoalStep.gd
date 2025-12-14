extends Resource
class_name FactionGoalStep

@export var id: String = ""
@export var title: String = ""
@export var required_amount: int = 1

var current_amount: int = 0

func is_done() -> bool:
    return current_amount >= required_amount

func add_progress(delta: int) -> void:
    current_amount = min(required_amount, current_amount + delta)
