# res://scripts/ArmyCatalog.gd
extends Node
class_name ArmyCatalog

# key -> ArmyData TEMPLATE
var templates: Dictionary = {}


func _ready() -> void:
    _load_army_templates()


func _load_army_templates() -> void:
    templates.clear()

    var base_path := "res://data/armies"
    var dir := DirAccess.open(base_path)
    if dir == null:
        push_error("ArmyCatalog: impossible d'ouvrir %s" % base_path)
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
        if res is ArmyData:
            var army_res := res as ArmyData

            var key := army_res.id
            if key == "":
                # fallback: nom de fichier sans extension
                key = file_name.trim_suffix(".tres")

            if templates.has(key):
                push_warning("ArmyCatalog: id d'armée dupliqué '%s' (%s)" % [key, full_path])

            templates[key] = army_res
        else:
            push_warning("ArmyCatalog: %s n'est pas un ArmyData" % full_path)

    dir.list_dir_end()

    print("ArmyCatalog: %d templates d'armées chargés." % templates.size())


func create_army(id: String) -> ArmyData:
    if not templates.has(id):
        push_error("ArmyCatalog: aucun template pour l'armée id '%s'" % id)
        return null

    var template := templates[id] as ArmyData
    return template.clone_runtime()
