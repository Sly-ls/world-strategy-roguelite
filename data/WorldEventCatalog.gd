# res://scripts/events/WorldEventCatalog.gd
extends Node
class_name WorldEventCatalog

var events: Dictionary = {}  # id -> WorldEvent

func _ready() -> void:
    _load_events()


func _load_events() -> void:
    events.clear()

    var base_path := "res://data/events"
    var dir := DirAccess.open(base_path)
    if dir == null:
        push_error("WorldEventCatalog: impossible d'ouvrir %s" % base_path)
        return

    dir.list_dir_begin()
    while true:
        var file_name := dir.get_next()
        if file_name == "":
            break
        if dir.current_is_dir():
            continue
        if not file_name.ends_with(".tres"):
            continue

        var full_path := base_path + "/" + file_name
        var res := load(full_path)
        if res is WorldEvent:
            var evt := res as WorldEvent
            if evt.id == "":
                myLogger.debug("WorldEventCatalog: event sans id (%s)" % full_path, LogTypes.Domain.SYSTEM)
                continue
            if events.has(evt.id):
                myLogger.debug("WorldEventCatalog: id d'event dupliqué '%s'" % evt.id, LogTypes.Domain.SYSTEM)
            events[evt.id] = evt
        else:
            myLogger.debug("WorldEventCatalog: %s n'est pas un WorldEvent" % full_path, LogTypes.Domain.SYSTEM)

    dir.list_dir_end()
    myLogger.debug("WorldEventCatalog: %d events chargés." % events.size(), LogTypes.Domain.SYSTEM)


func get_event(id: String) -> WorldEvent:
    if not events.has(id):
        push_error("WorldEventCatalog: event '%s' introuvable" % id)
        return null
    return events[id]
