extends Resource
class_name ArmyData

# Taille fixe de l'armée (20 slots pour ton UI 5x4)
const ARMY_SIZE := 20

# Tableau des unités (UnitData ou null)
@export var units: Array = []


func _init() -> void:
    # S'assurer qu'on a toujours ARMY_SIZE slots
    if units.is_empty():
        units.resize(ARMY_SIZE)
        for i in ARMY_SIZE:
            units[i] = null


func get_unit_at(index: int) -> UnitData:
    if index < 0 or index >= units.size():
        return null
    var u = units[index]
    if u == null:
        return null
    return u as UnitData


func set_unit_at(index: int, unit: UnitData) -> void:
    if index < 0 or index >= ARMY_SIZE:
        return

    # S'assurer que le tableau est à la bonne taille
    if units.size() < ARMY_SIZE:
        var old_size := units.size()
        units.resize(ARMY_SIZE)
        for i in range(old_size, ARMY_SIZE):
            if units[i] == null:
                units[i] = null

    units[index] = unit


func clear_unit_at(index: int) -> void:
    if index < 0 or index >= units.size():
        return
    units[index] = null


func get_units_count() -> int:
    return units.size()
