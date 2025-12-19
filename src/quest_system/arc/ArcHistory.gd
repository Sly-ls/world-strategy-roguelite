class_name ArcHistory
extends RefCounted

var owner_id: StringName

# Global metadata (comme tu as déjà)
var total_count: int = 0
var count_by_type: Dictionary[StringName, int] = {}
var last_day_by_type: Dictionary[StringName, int] = {}

# Index par cible (B) -> meta “A envers B”
var meta_by_target: Dictionary[StringName, ArcTargetMeta] = {}

# Historique détaillé (tes rivalités / dates / résolutions / choix etc.)
var rivalry_records: Array = [] # à toi: records/objects existants

func _init(id: StringName = &"") -> void:
    owner_id = id

func get_target_meta(target_id: StringName) -> ArcTargetMeta:
    if not meta_by_target.has(target_id):
        meta_by_target[target_id] = ArcTargetMeta.new(target_id)
    return meta_by_target[target_id]

func register_event(target_id: StringName, arc_type: StringName, day: int) -> void:
    total_count += 1
    count_by_type[arc_type] = int(count_by_type.get(arc_type, 0)) + 1
    last_day_by_type[arc_type] = day

    get_target_meta(target_id).register(arc_type, day)
