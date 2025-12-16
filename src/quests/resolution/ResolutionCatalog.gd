extends Node
class_name ResolutionCatalog

var profiles: Dictionary = {}

func _ready() -> void:
    _load_profiles()
    print("✓ ResolutionCatalog initialisé (%d profils)" % profiles.size())

func _load_profiles() -> void:
    var dir := DirAccess.open("res://data/quest_resolutions/")
    if dir == null:
        print("ResolutionCatalog: dossier introuvable")
        return

    dir.list_dir_begin()
    var file := dir.get_next()
    while file != "":
        if file.ends_with(".tres"):
            var p := load("res://data/quest_resolutions/" + file)
            if p is QuestResolutionProfile:
                profiles[p.id] = p
        file = dir.get_next()
    dir.list_dir_end()

func get_profile(id: String) -> QuestResolutionProfile:
    return profiles.get(id)
