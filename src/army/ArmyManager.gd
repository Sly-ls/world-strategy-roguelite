extends Node
class_name ArmyManager

var armies: Dictionary = {} # String -> Army

func register_army(a: ArmyData) -> void:
    if a == null or a.id == "":
        return
    armies[a.id] = a

func has_army(army_id: String) -> bool:
    return armies.has(army_id)

func get_army(army_id: String) -> ArmyData:
    return armies.get(army_id, null)

func remove_army(army_id: String) -> void:
    armies.erase(army_id)

func destroy_army(army_id: String) -> void:
    var a: ArmyData = get_army(army_id)
    if a == null:
        return

    # spawn loot
    if LootSiteManagerRunner != null:
        LootSiteManagerRunner.spawn_site(a.runtime_position, a.inventory, 20)

    # remove
    remove_army(army_id)
    print("💥 Army destroyed:", army_id)
