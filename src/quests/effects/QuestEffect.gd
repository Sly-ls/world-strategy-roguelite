# res://src/quests/effects/QuestEffect.gd
extends Resource
class_name QuestEffect

enum EffectType {
    GOLD,
TAG_PLAYER, 
REL_GIVER, 
REL_ANT, 
TAG_WORLD
}

@export var type: EffectType
@export var amount: int = 0
@export var tag: String = ""
