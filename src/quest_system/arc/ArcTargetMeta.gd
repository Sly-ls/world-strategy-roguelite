# ArcTargetMeta.gd
# Métadonnées d'une faction (owner) envers une cible (target)
# Fusionné avec RivalryHistory et FactionRivalryHistoryEntry
class_name ArcTargetMeta
extends RefCounted

const CHAIN_GAP_DAYS: int = 2

# =============================================================================
# Identifiants
# =============================================================================
var target_id: StringName
var target_label: String = ""  # pour debug/UI

# =============================================================================
# Stats agrégées (original ArcTargetMeta)
# =============================================================================
var total_count: int = 0
var count_by_type: Dictionary = {}      # StringName -> int
var last_day_by_type: Dictionary = {}   # StringName -> int
var last_event_day: int = -999999

# Mémoire courte "anti-spam"
var recent_events: Array = []  # [{day: int, type: StringName}]
var max_recent: int = 64

# =============================================================================
# Historique des entrées/conflits (de FactionRivalryHistoryEntry)
# =============================================================================
# Chaque entrée représente UN conflit/arc spécifique
var entries: Array = []  # Array of Dictionary avec structure:
# {
#   "id": String,
#   "attacker_id": StringName,
#   "defender_id": StringName,
#   "started_day": int,
#   "ended_day": int,  # -1 si en cours
#   "trigger_action_id": StringName,
#   "trigger_reason": StringName,
#   "resolution_choice": StringName,  # LOYAL/NEUTRAL/TRAITOR
#   "final_stage": int,
#   "events": Array[Dictionary]  # [{day, type, meta}]
# }

# =============================================================================
# Stats dérivées (de RivalryHistory)
# =============================================================================
var day_since_beginning_of_last_rivalry: int = -1
var day_since_end_of_last_rivalry: int = -1

var best_relation: int = 0
var worst_relation: int = 0
var longest_rivalry_in_days: int = 0
var longest_chain_length: int = 0  # taille max d'une chaîne d'arcs consécutifs

# Logique de chaîne interne
var _current_chain_len: int = 0
var _last_arc_end_day: int = -999999


# =============================================================================
# Initialisation
# =============================================================================
func _init(id: StringName = &"") -> void:
    target_id = id


# =============================================================================
# Méthodes originales de ArcTargetMeta
# =============================================================================
func register(arc_type: StringName, day: int) -> void:
    total_count += 1
    count_by_type[arc_type] = int(count_by_type.get(arc_type, 0)) + 1
    last_day_by_type[arc_type] = day
    last_event_day = max(last_event_day, day)

    recent_events.append({"day": day, "type": arc_type})
    if recent_events.size() > max_recent:
        recent_events.pop_front()

func get_count(arc_type: StringName) -> int:
    return int(count_by_type.get(arc_type, 0))

func get_days_since_type(arc_type: StringName, current_day: int) -> int:
    return current_day - int(last_day_by_type.get(arc_type, -999999))

func get_days_since_any(current_day: int) -> int:
    return current_day - last_event_day

func count_in_last_days(current_day: int, days: int, arc_type: StringName = &"") -> int:
    var c := 0
    for e in recent_events:
        var d := int(e["day"])
        if current_day - d > days:
            continue
        if arc_type == &"" or StringName(e["type"]) == arc_type:
            c += 1
    return c


# =============================================================================
# Méthodes de gestion des entrées (de RivalryHistory/FactionRivalryHistoryEntry)
# =============================================================================

## Crée une nouvelle entrée de rivalité/conflit
func create_entry(
    entry_id: String,
    attacker_id: StringName,
    defender_id: StringName,
    started_day: int,
    trigger_action_id: StringName = &"",
    trigger_reason: StringName = &""
) -> Dictionary:
    var entry := {
        "id": entry_id,
        "attacker_id": attacker_id,
        "defender_id": defender_id,
        "started_day": started_day,
        "ended_day": -1,
        "trigger_action_id": trigger_action_id,
        "trigger_reason": trigger_reason,
        "resolution_choice": &"",
        "final_stage": 1,
        "events": []
    }
    return entry

## Ajoute une entrée à l'historique (équivalent de RivalryHistory.add_entry)
func add_entry(entry: Dictionary, current_day: int, relation_snapshot: int = 0) -> void:
    # 1) Append
    entries.append(entry)

    # 2) Day counters (début)
    var started := int(entry.get("started_day", current_day))
    day_since_beginning_of_last_rivalry = max(0, current_day - started)

    # 3) Chain logic
    var gap: int = started - _last_arc_end_day
    if _current_chain_len == 0:
        _current_chain_len = 1
    elif gap <= CHAIN_GAP_DAYS:
        _current_chain_len += 1
    else:
        _current_chain_len = 1

    longest_chain_length = max(longest_chain_length, _current_chain_len)

    # 4) Best/worst relation (snapshot)
    if entries.size() == 1:
        worst_relation = relation_snapshot
        best_relation = relation_snapshot
    else:
        worst_relation = min(worst_relation, relation_snapshot)
        best_relation = max(best_relation, relation_snapshot)

    # 5) Si l'entrée est déjà terminée
    var ended := int(entry.get("ended_day", -1))
    if ended >= 0:
        _on_entry_closed(entry, current_day)

## Appelé quand une entrée est fermée
func _on_entry_closed(entry: Dictionary, current_day: int) -> void:
    var duration := entry_duration_days(entry)
    longest_rivalry_in_days = max(longest_rivalry_in_days, duration)
    
    var ended := int(entry.get("ended_day", current_day))
    day_since_end_of_last_rivalry = max(0, current_day - ended)
    _last_arc_end_day = ended

## Ferme une entrée existante
func close_entry(entry_id: String, current_day: int, end_reason: StringName = &"", resolution_choice: StringName = &"", final_stage: int = -1) -> bool:
    for entry in entries:
        if entry.get("id", "") == entry_id:
            if int(entry.get("ended_day", -1)) >= 0:
                return false  # Déjà fermée
            
            entry["ended_day"] = current_day
            if end_reason != &"":
                entry["end_reason"] = end_reason
            if resolution_choice != &"":
                entry["resolution_choice"] = resolution_choice
            if final_stage >= 0:
                entry["final_stage"] = final_stage
            
            _on_entry_closed(entry, current_day)
            return true
    return false

## Trouve une entrée par ID
func get_entry(entry_id: String) -> Dictionary:
    for entry in entries:
        if entry.get("id", "") == entry_id:
            return entry
    return {}

## Trouve la dernière entrée
func get_last_entry() -> Dictionary:
    if entries.is_empty():
        return {}
    return entries.back()

## Trouve une entrée ouverte (ended_day == -1)
func get_open_entry() -> Dictionary:
    for entry in entries:
        if int(entry.get("ended_day", -1)) < 0:
            return entry
    return {}

## Ajoute un event à une entrée
func add_event_to_entry(entry_id: String, day: int, event_type: StringName, meta: Dictionary = {}) -> bool:
    for entry in entries:
        if entry.get("id", "") == entry_id:
            var events_array: Array = entry.get("events", [])
            events_array.append({"day": day, "type": event_type, "meta": meta})
            entry["events"] = events_array
            return true
    return false

## Calcule la durée d'une entrée
static func entry_duration_days(entry: Dictionary) -> int:
    var ended := int(entry.get("ended_day", -1))
    if ended < 0:
        return 0
    var started := int(entry.get("started_day", 0))
    return max(0, ended - started)

## Rafraîchit les compteurs (équivalent de RivalryHistory.refresh_counters)
func refresh_counters(current_day: int) -> void:
    if entries.is_empty():
        day_since_beginning_of_last_rivalry = -1
        day_since_end_of_last_rivalry = -1
        return

    var last: Dictionary = entries.back()
    var started := int(last.get("started_day", 0))
    var ended := int(last.get("ended_day", -1))
    
    day_since_beginning_of_last_rivalry = max(0, current_day - started)
    if ended >= 0:
        day_since_end_of_last_rivalry = max(0, current_day - ended)
    else:
        day_since_end_of_last_rivalry = -1


# =============================================================================
# Queries
# =============================================================================

## Nombre d'entrées total
func get_entry_count() -> int:
    return entries.size()

## Nombre d'entrées ouvertes
func get_open_entry_count() -> int:
    var count := 0
    for entry in entries:
        if int(entry.get("ended_day", -1)) < 0:
            count += 1
    return count

## Nombre d'entrées fermées
func get_closed_entry_count() -> int:
    var count := 0
    for entry in entries:
        if int(entry.get("ended_day", -1)) >= 0:
            count += 1
    return count

## Durée totale de toutes les rivalités
func get_total_rivalry_days() -> int:
    var total := 0
    for entry in entries:
        total += entry_duration_days(entry)
    return total

## Compte les entrées par resolution_choice
func count_by_resolution(choice: StringName) -> int:
    var count := 0
    for entry in entries:
        if StringName(entry.get("resolution_choice", &"")) == choice:
            count += 1
    return count

## Retourne le total_count (pour compatibilité avec ArcPairHistory)
func get_total_count() -> int:
    return total_count
