extends Resource
class_name ArmyData

const ARMY_COLS := 3
const ARMY_ROWS := 5
const ARMY_SIZE := ARMY_COLS * ARMY_ROWS

@export var id: String = ""              # pour les templates (optionnel mais utile)
@export var units: Array[UnitData] = []  # taille = ARMY_SIZE


func _init() -> void:
    if units.is_empty():
        units.resize(ARMY_SIZE)


func rc_from_index(index: int) -> Vector2i:
    return Vector2i(index / ARMY_COLS, index % ARMY_COLS) # row, col
    
func index_from_rc(col: int, row: int) -> int:
    # row = 0 = ligne de front
    return row * ARMY_COLS + col
    
func set_unit_at_index(col: int, row: int, unit: UnitData) -> void:
    var idx := index_from_rc(col, row)
    if idx < 0 or idx >= units.size():
        return
    units[idx] = unit


func get_unit_at_position(col: int, row: int) -> UnitData:
    var index := index_from_rc(col, row)
    return get_unit_at_index(index)

func get_unit_at_index(index: int) -> UnitData:
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

func is_dead() -> bool:
    for unit in units:
        if unit != null and unit.hp > 0:
            return false
    return true

func get_units_count() -> int:
    return units.size()


func get_front_target_index_for_side() -> int:
    var front_row := 0
    for col in ARMY_COLS:
        var idx := index_from_rc(front_row, col)
        if idx >= units.size():
            return -1
        var u = units[idx]
        if u != null and u.hp > 0:
            return idx
    return -1
    
func get_front_index_for_col(side: ArmyData, col: int) -> int:
    for row in range(side.ARMY_ROWS):
        var idx := side.index_from_rc(row, col)
        if idx < 0 or idx >= side.units.size():
            continue
        var u: UnitData = side.units[idx]
        if u != null and u.hp > 0:
            return idx
    return -1


func apply_reinforcements() -> void:
    # units = array 1D de taille GRID_COLS * GRID_ROWS
    for col in ARMY_COLS:
        # si la case de front est vide
        var front_index := col  # si row 0 = front : index = row*cols + col = 0*cols + col
        if front_index >= units.size():
            break
        if units[front_index] != null and units[front_index].hp > 0:
            continue

        # cherche la première unité vivante plus loin dans la colonne
        var found_idx := -1
        for row in range(1, ARMY_ROWS):
            var idx := row * ARMY_COLS + col
            if idx >= units.size():
                break
            var cu := units[idx]
            if cu != null and cu.hp > 0:
                found_idx = idx
                break

        if found_idx != -1:
            units[front_index] = units[found_idx]
            units[found_idx] = null
            
func compact_columns() -> void:
    # Pour chaque colonne, on fait tomber les unités vers row 0
    for col in ARMY_COLS:
        var stack: Array[UnitData] = []

        # On parcourt les rows de front (0) vers fond (rows-1)
        for row in ARMY_ROWS:
            var u := get_unit_at_position(col, row)
            if u != null and u.hp > 0:
                stack.append(u)

        # On remplit depuis row 0 avec ce qu'on a trouvé
        var row_index := 0
        for u in stack:
            set_unit_at_index(col, row_index, u)
            row_index += 1

        # Les lignes restantes deviennent vides
        while row_index < ARMY_ROWS:
            set_unit_at_index(col, row_index, null)
            row_index += 1

func describe():
        for unit in units:
            print(unit.describe())
