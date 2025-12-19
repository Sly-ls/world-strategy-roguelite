class_name ArcPairHistory
extends RefCounted

var total_count: int = 0
var count_by_type: Dictionary[StringName, int] = {}
var last_day_by_type: Dictionary[StringName, int] = {}

var last_event_day: int = -999999

# Mémoire courte (pour détecter spam récent)
var recent_events: Array = [] # [{day:int, type:StringName}]
var max_recent: int = 64

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

func get_total_count() -> int:
    return total_count

func get_days_since(arc_type: StringName, current_day: int) -> int:
    var last := int(last_day_by_type.get(arc_type, -999999))
    return current_day - last

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
