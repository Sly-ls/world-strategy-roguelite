# res://src/sim/actions/FactionAction.gd
extends Resource
class_name FactionAction

enum ActionType { BUILD_DOMAIN, RAID, DIPLOMACY, EXPLORE, CORRUPT, DEFEND }

@export var type: ActionType
@export var actor_faction_id: String = ""
@export var target_faction_id: String = ""
@export var poi_id: String = ""
@export var domain: String = ""        # "divine","tech","nature","magic","corruption"
@export var intensity: int = 1
@export var tags_to_add_world: Array[String] = []
@export var relation_delta_actor_target: int = 0
