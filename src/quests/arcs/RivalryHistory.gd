# res://src/arcs/RivalryHistory.gd
extends RefCounted
class_name RivalryHistory

const CHAIN_GAP_DAYS: int = 2

var faction_id: String = ""
var rival_id: String = ""
var faction_label: String = ""  # juste pour debug/recherche UI

var history: Array[FactionRivalryHistoryEntry] = []

# Stats “dérivées”
var day_since_beginning_of_last_rivalry: int = -1
var day_since_end_of_last_rivalry: int = -1

var best_relation: int = 0
var worst_relation: int = 0
var longest_rivalry_in_day: int = 0
var longest_history_in_arc: int = 0  # taille max d’une chaine d’arcs

# interne (chaînes)
var _current_chain_len: int = 0
var _last_arc_end_day: int = -999999

func add_entry_OLD(entry: FactionRivalryHistoryEntry, current_day: int, relation_snapshot: int = 0) -> void:
    # 1) append
    history.append(entry)

    # 2) day counters (début)
    day_since_beginning_of_last_rivalry = max(0, current_day - entry.started_day)

    # 3) chain logic
    var gap := entry.started_day - _last_arc_end_day
    if _current_chain_len == 0:
        _current_chain_len = 1
    elif gap <= CHAIN_GAP_DAYS:
        _current_chain_len += 1
    else:
        _current_chain_len = 1

    longest_history_in_arc = max(longest_history_in_arc, _current_chain_len)

    # 4) worst relation (si tu passes un snapshot)
    if history.size() == 1:
        worst_relation = relation_snapshot
    else:
        worst_relation = min(worst_relation, relation_snapshot)

    # 5) si l’entrée est déjà terminée, mettre à jour durée + end counters + chain end
    if entry.ended_day >= 0:
        _on_entry_closed(entry, current_day)
func add_entry(entry: FactionRivalryHistoryEntry, current_day: int, relation_snapshot: int = 0) -> void:
    # 1) append
    history.append(entry)

    # 2) day counters (début)
    day_since_beginning_of_last_rivalry = max(0, current_day - entry.started_day)

    # 3) chain logic
    var gap: int = entry.started_day - _last_arc_end_day
    if _current_chain_len == 0:
        _current_chain_len = 1
    elif gap <= CHAIN_GAP_DAYS:
        _current_chain_len += 1
    else:
        _current_chain_len = 1

    longest_history_in_arc = max(longest_history_in_arc, _current_chain_len)

    # 4) best/worst relation (snapshot)
    if history.size() == 1:
        worst_relation = relation_snapshot
        best_relation = relation_snapshot
    else:
        worst_relation = min(worst_relation, relation_snapshot)
        best_relation = max(best_relation, relation_snapshot)

    # 5) si l’entrée est déjà terminée
    if entry.ended_day >= 0:
        _on_entry_closed(entry, current_day)



func _on_entry_closed(entry: FactionRivalryHistoryEntry, current_day: int) -> void:
    longest_rivalry_in_day = max(longest_rivalry_in_day, entry.duration_days())
    day_since_end_of_last_rivalry = max(0, current_day - entry.ended_day)
    _last_arc_end_day = entry.ended_day

func refresh_counters(current_day: int) -> void:
    # utile dans tick_day() pour garder des compteurs exacts sans recalcul lourd
    if history.is_empty():
        day_since_beginning_of_last_rivalry = -1
        day_since_end_of_last_rivalry = -1
        return

    var last :FactionRivalryHistoryEntry = history.back()
    day_since_beginning_of_last_rivalry = max(0, current_day - last.started_day)
    if last.ended_day >= 0:
        day_since_end_of_last_rivalry = max(0, current_day - last.ended_day)
    else:
        day_since_end_of_last_rivalry = -1
