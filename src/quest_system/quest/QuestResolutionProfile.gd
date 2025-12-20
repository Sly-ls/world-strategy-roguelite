# QuestResolutionProfile.gd
class_name QuestResolutionProfile
extends Resource

@export var id: StringName

@export var success_loyal_effects: Array[QuestEffect] = []
@export var success_neutral_effects: Array[QuestEffect] = []
@export var success_traitor_effects: Array[QuestEffect] = []

@export var failure_loyal_effects: Array[QuestEffect] = []
@export var failure_neutral_effects: Array[QuestEffect] = []
@export var failure_traitor_effects: Array[QuestEffect] = []

func get_effects(choice: String) -> Array[QuestEffect]:
    match choice:
        "LOYAL": return success_loyal_effects
        "NEUTRAL": return success_neutral_effects
        "TRAITOR": return success_traitor_effects
        _: return []


func get_failure_effects(choice: String) -> Array[QuestEffect]:
    match choice:
        "LOYAL": return failure_loyal_effects
        "NEUTRAL": return failure_neutral_effects
        "TRAITOR": return failure_traitor_effects
        _: return []
