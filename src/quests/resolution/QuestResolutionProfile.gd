# res://src/quests/resolution/QuestResolutionProfile.gd
extends Resource
class_name QuestResolutionProfile

@export var id: String

@export var loyal_effects: Array[QuestEffect] = []
@export var neutral_effects: Array[QuestEffect] = []
@export var traitor_effects: Array[QuestEffect] = []

func get_effects(choice: String) -> Array[QuestEffect]:
    match choice:
        "LOYAL": return loyal_effects
        "NEUTRAL": return neutral_effects
        "TRAITOR": return traitor_effects
        _: return []
