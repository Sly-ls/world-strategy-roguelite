class_name ArcState
extends RefCounted

var a_id: StringName
var b_id: StringName
var state: StringName = &"NEUTRAL"   # see enum above

var entered_day: int = 0
var last_event_day: int = -999999
var lock_until_day: int = -999999     # empêche re-trigger trop vite

# compteurs “phase” (réinitialisés à chaque changement d’état)
var phase_hostile: int = 0
var phase_peace: int = 0
var phase_events: int = 0

# optionnel: dernier arc_action_type utile pour debug
var last_action: StringName = &""

var treaty:Treaty = null

func is_locked(day: int) -> bool:
    return day < lock_until_day
