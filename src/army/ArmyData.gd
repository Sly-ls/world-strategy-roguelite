# res://scripts/ArmyData.gd
extends Resource
class_name ArmyData

const ARMY_SIZE := 20

@export var id: String = ""              # pour les templates (optionnel mais utile)
@export var units: Array[UnitData] = []  # taille = ARMY_SIZE


func _init() -> void:
    if units.is_empty():
        units.resize(ARMY_SIZE)


func set_unit_at(index: int, unit: UnitData) -> void:
    if index < 0 or index >= units.size():
        return
    units[index] = unit


func get_unit_at(index: int) -> UnitData:
    if index < 0 or index >= units.size():
        return null
    return units[index]


func clone_runtime() -> ArmyData:
    var a := ArmyData.new()
    a.id = id
    a.units.resize(units.size())

    for i in units.size():
        var u := units[i]
        if u != null:
            # très important : on clone aussi les unités
            a.units[i] = u.clone_runtime()
        else:
            a.units[i] = null

    return a


func clear_unit_at(index: int) -> void:
    if index < 0 or index >= units.size():
        return
    units[index] = null


func get_units_count() -> int:
    return units.size()
