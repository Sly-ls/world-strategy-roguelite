extends Node

class_name UnitCatalog

# id -> UnitData (TEMPLATE)
var templates: Dictionary = {}


func _ready() -> void:
    _load_unit_templates()


func _load_unit_templates() -> void:
    templates.clear()

    var base_path := "res://data/units"
    var dir := DirAccess.open(base_path)
    if dir == null:
        push_error("UnitCatalog: impossible d'ouvrir %s" % base_path)
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
        if res is UnitData:
            var unit_res := res as UnitData
            if unit_res.id == "":
                myLogger.debug("UnitCatalog: UnitData sans id dans %s" % full_path, LogTypes.Domain.SYSTEM)
                continue
            if templates.has(unit_res.id):
                myLogger.debug("UnitCatalog: id dupliqué '%s' (%s)" % [unit_res.id, full_path], LogTypes.Domain.SYSTEM)
            templates[unit_res.id] = unit_res
        else:
            myLogger.debug("UnitCatalog: %s n'est pas un UnitData" % full_path, LogTypes.Domain.SYSTEM)

    dir.list_dir_end()

    myLogger.debug("UnitCatalog: %d templates chargés." % templates.size(), LogTypes.Domain.SYSTEM)


func create_unit(id: String) -> UnitData:
    if not templates.has(id):
        push_error("UnitCatalog: aucun template pour id '%s'" % id)
        return null

    var template := templates[id] as UnitData
    return template.clone_runtime()
