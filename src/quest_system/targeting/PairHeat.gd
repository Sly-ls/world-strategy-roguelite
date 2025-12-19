class_name PairHeat
extends RefCounted

var last_day: int = -999999

var hostile_ab: float = 0.0
var friendly_ab: float = 0.0
var hostile_ba: float = 0.0
var friendly_ba: float = 0.0


func decay_to(day: int, decay_per_day: float = 0.93) -> void:
    var dt :int = max(0, day - last_day)
    if dt == 0:
        return
    var f := pow(decay_per_day, float(dt))
    hostile_ab *= f
    friendly_ab *= f
    hostile_ba *= f
    friendly_ba *= f
    last_day = day

func add_contribution(actor: StringName, delta: int, day: int) -> void:
    # actor is the one DOING the action
    # Positive delta = hostile, negative = friendly
    decay_to(day)
    
    # We assume actor is "A" in the A→B direction
    # If delta > 0 (hostile), add to hostile_ab
    # If delta < 0 (friendly), add to friendly_ab
    if delta > 0:
        hostile_ab += float(delta)
    else:
        friendly_ab += float(-delta)

func add_contribution_directional(a: StringName, b: StringName, delta: int, day: int) -> void:
    decay_to(day)
    if delta > 0:
        hostile_ab += float(delta)
    else:
        friendly_ab += float(-delta)

func get_net_heat_ab() -> float:
    return hostile_ab - friendly_ab

func get_net_heat_ba() -> float:
    return hostile_ba - friendly_ba

func get_total_heat() -> float:
    return hostile_ab + hostile_ba - friendly_ab - friendly_ba
