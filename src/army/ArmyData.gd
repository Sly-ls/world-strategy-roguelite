extends Resource
class_name ArmyData

const ARMY_COLS := 4
const ARMY_ROWS := 5
const ARMY_SIZE := ARMY_COLS * ARMY_ROWS

@export var units: Array[UnitData] = []

func _init() -> void:
    # s'assurer qu'on a toujours ARMY_SIZE slots
    if units.size() == 0:
        for i in ARMY_SIZE:
            units.append(null)


func set_unit_at(index: int, unit: UnitData) -> void:
    if index < 0 or index >= ARMY_SIZE:
        return
    units[index] = unit


func get_unit_at(index: int) -> UnitData:
    if index < 0 or index >= ARMY_SIZE:
        return null
    return units[index]



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
