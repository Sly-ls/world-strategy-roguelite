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
