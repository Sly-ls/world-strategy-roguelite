class_name KnowledgeEvent
extends RefCounted

var id: StringName
var day: int
var type: StringName            # RAID/SABOTAGE/TRIBUTE_MISS/TREATY_BREACH/...
var true_actor: StringName      # qui a vraiment fait l’action
var true_target: StringName
var severity: float = 1.0       # 0.5..2.0
var pair_key: StringName        # "A|B" (actor/target)
var meta: Dictionary = {}       # poi_id, arc_id, etc.
