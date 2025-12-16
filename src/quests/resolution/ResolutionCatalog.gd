extends Node
class_name ResolutionCatalog

var profiles: Dictionary = {}

func _ready() -> void:
    _load_profiles()
    print("✓ ResolutionCatalog initialisé (%d profils)" % profiles.size())

func _load_profiles() -> void:
    var dir := DirAccess.open("res://data/resolution_profiles/")
    if dir == null:
        print("ResolutionCatalog: dossier introuvable")
        return

    dir.list_dir_begin()
    var file := dir.get_next()
    while file != "":
        if file.ends_with(".tres"):
            var p := load("res://data/resolution_profiles/" + file)
            if p is QuestResolutionProfile:
                profiles[p.id] = p
        file = dir.get_next()
    dir.list_dir_end()
    
static func _make_default_simple() -> Dictionary:
    # 4 types max: GOLD, REL_GIVER, REL_ANT, TAG_PLAYER
    return {
        "id": "default_simple",
        "effects": {
            "LOYAL": [
                {"type":"GOLD", "amount": 100},
                {"type":"REL_GIVER", "delta": 10},
                {"type":"REL_ANT", "delta": -10},
            ],
            "NEUTRAL": [
                {"type":"GOLD", "amount": 25},
                {"type":"TAG_PLAYER", "tag":"INDEPENDENT"},
            ],
            "TRAITOR": [
                {"type":"TAG_PLAYER", "tag":"TRAITOR"},
                {"type":"REL_GIVER", "delta": -25},
                {"type":"REL_ANT", "delta": 15},
            ],
        }
    }

func get_profile(id: String) -> QuestResolutionProfile:
    return profiles.get(id)
    
func get_all_profile_ids() -> Array:
    return profiles.keys()
