extends Node
class_name ResolutionRuleCatalog

var rules: Array[QuestResolutionRule] = []

func _ready() -> void:
    _load_rules()
    myLogger.debug("✓ ResolutionRuleCatalog initialisé (%d règles)" % rules.size(), LogTypes.Domain.QUEST)

func _load_rules() -> void:
    var dir := DirAccess.open("res://data/quest_resolution_rules/")
    if dir == null:
        return

    dir.list_dir_begin()
    var f := dir.get_next()
    while f != "":
        if f.ends_with(".tres"):
            var r := load("res://data/quest_resolution_rules/" + f)
            if r is QuestResolutionRule:
                rules.append(r)
        f = dir.get_next()
    dir.list_dir_end()

func pick_profile(context: Dictionary) -> String:
    var candidates: Array[QuestResolutionRule] = []

    for rule in rules:
        if rule.matches(context):
            candidates.append(rule)

    if candidates.is_empty():
        return "default_simple"

    return candidates.pick_random().resolution_profile_id
