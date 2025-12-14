# res://src/quests/effects/QuestEffect.gd
extends Resource
class_name QuestEffect

enum EffectType {
    GOLD,
    PLAYER_TAG,
    WORLD_TAG,
    FACTION_RELATION
}

@export var type: EffectType
@export var amount: int = 0
@export var tag: String = ""
@export var faction_role: String = "" # "giver" | "antagonist"
