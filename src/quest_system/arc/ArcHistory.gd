# ArcHistory.gd
# Historique d'une faction envers toutes ses cibles
# Délègue la plupart du travail à ArcTargetMeta
class_name ArcHistory
extends RefCounted

var owner_id: StringName
var owner_label: String = ""  # pour debug/UI

# Global metadata
var total_count: int = 0
var count_by_type: Dictionary = {}      # StringName -> int
var last_day_by_type: Dictionary = {}   # StringName -> int

# Index par cible (target_id) -> ArcTargetMeta
var meta_by_target: Dictionary = {}     # StringName -> ArcTargetMeta


# =============================================================================
# Initialisation
# =============================================================================
func _init(id: StringName = &"") -> void:
    owner_id = id


# =============================================================================
# Accès aux métadonnées par cible
# =============================================================================
func get_target_meta(target_id: StringName) -> ArcTargetMeta:
    if not meta_by_target.has(target_id):
        meta_by_target[target_id] = ArcTargetMeta.new(target_id)
    return meta_by_target[target_id]

func has_target(target_id: StringName) -> bool:
    return meta_by_target.has(target_id)

func get_all_targets() -> Array[StringName]:
    var result: Array[StringName] = []
    for k in meta_by_target.keys():
        result.append(k)
    return result


# =============================================================================
# Enregistrement d'événements
# =============================================================================
func register_event(target_id: StringName, arc_type: StringName, day: int) -> void:
    total_count += 1
    count_by_type[arc_type] = int(count_by_type.get(arc_type, 0)) + 1
    last_day_by_type[arc_type] = day

    get_target_meta(target_id).register(arc_type, day)


# =============================================================================
# Gestion des entrées de rivalité (délégué à ArcTargetMeta)
# =============================================================================

## Crée et ajoute une nouvelle entrée de rivalité
func add_rivalry_entry(
    target_id: StringName,
    entry_id: String,
    attacker_id: StringName,
    defender_id: StringName,
    started_day: int,
    current_day: int,
    relation_snapshot: int = 0,
    trigger_action_id: StringName = &"",
    trigger_reason: StringName = &""
) -> Dictionary:
    var meta := get_target_meta(target_id)
    var entry := meta.create_entry(entry_id, attacker_id, defender_id, started_day, trigger_action_id, trigger_reason)
    meta.add_entry(entry, current_day, relation_snapshot)
    return entry

## Ferme une entrée de rivalité
func close_rivalry_entry(
    target_id: StringName,
    entry_id: String,
    current_day: int,
    end_reason: StringName = &"",
    resolution_choice: StringName = &"",
    final_stage: int = -1
) -> bool:
    if not meta_by_target.has(target_id):
        return false
    return meta_by_target[target_id].close_entry(entry_id, current_day, end_reason, resolution_choice, final_stage)

## Trouve une entrée par ID dans toutes les cibles
func find_entry(entry_id: String) -> Dictionary:
    for target_id in meta_by_target.keys():
        var entry :Dictionary = meta_by_target[target_id].get_entry(entry_id)
        if not entry.is_empty():
            return entry
    return {}

## Trouve une entrée ouverte pour une cible
func get_open_entry_for_target(target_id: StringName) -> Dictionary:
    if not meta_by_target.has(target_id):
        return {}
    return meta_by_target[target_id].get_open_entry()

## Ajoute un event à une entrée
func add_event_to_entry(target_id: StringName, entry_id: String, day: int, event_type: StringName, meta: Dictionary = {}) -> bool:
    if not meta_by_target.has(target_id):
        return false
    return meta_by_target[target_id].add_event_to_entry(entry_id, day, event_type, meta)


# =============================================================================
# Rafraîchissement des compteurs
# =============================================================================
func refresh_all_counters(current_day: int) -> void:
    for target_id in meta_by_target.keys():
        meta_by_target[target_id].refresh_counters(current_day)


# =============================================================================
# Queries globales
# =============================================================================

## Nombre total d'événements
func get_total_count() -> int:
    return total_count

## Nombre d'événements par type
func get_count_by_type(arc_type: StringName) -> int:
    return int(count_by_type.get(arc_type, 0))

## Jours depuis un type d'événement
func get_days_since_type(arc_type: StringName, current_day: int) -> int:
    return current_day - int(last_day_by_type.get(arc_type, -999999))

## Nombre total d'entrées de rivalité (toutes cibles)
func get_total_entry_count() -> int:
    var count := 0
    for target_id in meta_by_target.keys():
        count += meta_by_target[target_id].get_entry_count()
    return count

## Nombre d'entrées ouvertes (toutes cibles)
func get_total_open_entry_count() -> int:
    var count := 0
    for target_id in meta_by_target.keys():
        count += meta_by_target[target_id].get_open_entry_count()
    return count

## Pire relation enregistrée (toutes cibles)
func get_worst_relation_ever() -> int:
    var worst := 0
    var first := true
    for target_id in meta_by_target.keys():
        var meta: ArcTargetMeta = meta_by_target[target_id]
        if first:
            worst = meta.worst_relation
            first = false
        else:
            worst = min(worst, meta.worst_relation)
    return worst

## Meilleure relation enregistrée (toutes cibles)
func get_best_relation_ever() -> int:
    var best := 0
    var first := true
    for target_id in meta_by_target.keys():
        var meta: ArcTargetMeta = meta_by_target[target_id]
        if first:
            best = meta.best_relation
            first = false
        else:
            best = max(best, meta.best_relation)
    return best

## Plus longue rivalité en jours (toutes cibles)
func get_longest_rivalry_in_days() -> int:
    var longest := 0
    for target_id in meta_by_target.keys():
        var meta: ArcTargetMeta = meta_by_target[target_id]
        longest = max(longest, meta.longest_rivalry_in_days)
    return longest

## Plus longue chaîne (toutes cibles)
func get_longest_chain_length() -> int:
    var longest := 0
    for target_id in meta_by_target.keys():
        var meta: ArcTargetMeta = meta_by_target[target_id]
        longest = max(longest, meta.longest_chain_length)
    return longest
