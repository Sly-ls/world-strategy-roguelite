extends Resource
class_name ArmyData

const ARMY_COLS := 3   # colonnes (gauche→droite) sur le champ de bataille
const ARMY_ROWS := 5   # lignes (0 = front)
const ARMY_SIZE := ARMY_COLS * ARMY_ROWS
const BASE_SPEED_PX := 50.0  # vitesse "de référence" en pixels/s

@export var id: String = ""
@export var units: Array[UnitData] = []
var player: bool = false


func _init(_player: bool = false) -> void:
    player = _player
    if units.size() != ARMY_SIZE:
        units.resize(ARMY_SIZE)
        
func clone_runtime(_player: bool = false) -> ArmyData:
    var a := ArmyData.new(_player)
    a.id = id
    a.units.resize(ARMY_SIZE)

    for i in units.size():
        var u := units[i]
        if u != null:
            # très important : on clone aussi les unités
            a.units[i] = u.clone_runtime(_player)
        else:
            a.units[i] = null

    return a

func describe():
        for unit in units:
            print(unit.describe())



# Getter methods
func rc_from_index(idx: int) -> Vector2:
    # Convertit un index linéaire (0..ARMY_SIZE-1) en (col, row)
    # col = x, row = y
    return Vector2(idx % ARMY_COLS, idx / ARMY_COLS) # row, col
    
func index_from_rc(row: int, col: int) -> int:
    # row = 0..4, col = 0..2
    return row * ARMY_COLS + col
    
func get_unit_at_index(idx: int) -> UnitData:
    if idx < 0 or idx >= units.size():
        return null
    return units[idx]
    
func get_unit_at_position(row: int, col: int) -> UnitData:
    return get_unit_at_index(index_from_rc(row, col))
    
func set_unit_at_position(row: int, col: int, unit: UnitData) -> void:
    # Helper pratique pour travailler en (col = x, row = y)
    set_unit_rc(row, col, unit)
    
    

#Setting Methods
func set_unit_at_index(idx: int, unit: UnitData) -> void:
    if idx < 0 or idx >= units.size():
        return
    units[idx] = unit
    
func set_unit_rc(row: int, col: int, unit: UnitData) -> void:
    set_unit_at_index(index_from_rc(row, col), unit)



# test methods
func is_dead() -> bool:
    for unit in units:
        if unit != null and unit.hp > 0:
            return false
    return true
    
func get_all_ready_units(action :PowerEnums.PowerType, phase: PowerEnums.PowerType) -> Array[UnitData] :
        var readyUnits: Array[UnitData] = []
        for col in range(ARMY_COLS):
            var unit :UnitData = get_unit_at_position(0,col)
            if unit != null:
                if unit.is_ready_for(action, phase):
                    readyUnits.append(unit)
        return readyUnits;
        
        
        
#Organization methods
func compact_columns() -> void:
    # "Puissance 4" : on fait tomber les unités vers row 0 dans chaque colonne
    for col in range(ARMY_COLS):
        compact_column(col)

func compact_column(col :int) -> void:
    # "Puissance 4" : on fait tomber les unités vers row 0 dans chaque colonne
    var stack: Array[UnitData] = []

    for row in range(ARMY_ROWS):
        var u := get_unit_at_position(row, col)
        if u != null and u.hp > 0:
            stack.append(u)

    var row_index := 0
    for u in stack:
        set_unit_rc(row_index, col, u)
        row_index += 1

    while row_index < ARMY_ROWS:
        set_unit_rc(row_index, col, null)
        row_index += 1
                 
func swap_units(from_col: int, from_row : int, to_col: int, to_row : int) -> void:
        var from_unit = get_unit_at_position(from_row, from_col)
        var to_unit = get_unit_at_position(to_row, to_col)

        # Échanger les unités (row, col)
        set_unit_rc(to_row, to_col, from_unit)
        set_unit_rc(from_row, from_col, to_unit)       
            
# combat methods
func apply_reinforcements() -> void:
    # units = array 1D de taille GRID_COLS * GRID_ROWS
    for col in ARMY_COLS:
        var unit :UnitData = get_unit_at_position(0, col)
        if unit == null || unit.hp <= 0:
            units[index_from_rc(0, col)] = null
            for row in range(1,ARMY_ROWS):
                var reinforcmeent:UnitData = get_unit_at_position(row, col)
                if reinforcmeent != null && reinforcmeent.hp >= 0:
                    set_unit_at_position(0, col, reinforcmeent)
                    units[index_from_rc(row, col)] = null
                    compact_columns()
                    break
      
func get_attacks(defenders : ArmyData, action: PowerEnums.PowerType, phase: PowerEnums.PowerType) -> Array[AttackData] :
        var attacks: Array[AttackData] = []
        var readyUnits: Array[UnitData] = get_all_ready_units(action, phase)
        if !readyUnits.is_empty():
            for attacker :UnitData in readyUnits:
                var targets = attacker.get_targets(defenders)
                if !targets.is_empty():
                    var power:int = attacker.get_score(action)
                    var attack :AttackData = AttackData.new(attacker, targets, action,  phase, power)
                    attacks.append(attack)
                       
        return attacks;
        
func reatreat_front_unit(col) -> void:
    var retreating_unit = get_unit_at_position(0, col)
    var last_row = 0
    var last_unit = null
    for row in range (1, ARMY_ROWS):
        last_row=row
        var current_unit = get_unit_at_position(row, col)
        if current_unit != null || last_unit == current_unit:
            set_unit_rc(row-1, col, current_unit)
        else:
            break
    set_unit_rc(last_row, col, retreating_unit)
    compact_column(col)
    
