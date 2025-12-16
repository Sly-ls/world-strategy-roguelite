# res://src/arcs/FactionRivalryHistoryEntry.gd
extends RefCounted
class_name FactionRivalryHistoryEntry

var id: String
var attacker_id: String
var defender_id: String

var started_day: int
var ended_day: int = -1

var trigger_action_id: String = ""     # "RAID" etc
var trigger_reason: String = ""        # "hostile_action"
var resolution_choice: String = ""     # LOYAL/NEUTRAL/TRAITOR
var final_stage: int = 1

var events: Array[Dictionary] = []     # [{day, type, meta}]

func duration_days() -> int:
    if ended_day < 0:
        return 0
    return max(0, ended_day - started_day)
