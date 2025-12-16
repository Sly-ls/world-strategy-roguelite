# res://src/arcs/FactionRivalryArc.gd
extends RefCounted
class_name FactionRivalryArc

enum Stage { PROVOCATION = 1, ESCALATION = 2, DECISIVE = 3, RESOLVED = 4 }

var id: String = ""
var attacker_id: String = ""
var defender_id: String = ""

var stage: int = Stage.PROVOCATION
var started_day: int = 0
var last_event_day: int = 0

var pending_retaliation: bool = false

func pair_key() -> String:
    return "%s|%s" % [attacker_id, defender_id]

func is_active() -> bool:
    return stage < Stage.RESOLVED

func stage_name() -> String:
    match stage:
        Stage.PROVOCATION: return "PROVOCATION"
        Stage.ESCALATION: return "ESCALATION"
        Stage.DECISIVE: return "DECISIVE"
        Stage.RESOLVED: return "RESOLVED"
        _: return "UNKNOWN"
