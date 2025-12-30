extends Resource
class_name ArmyData

## ===== CONSTANTES =====
const ARMY_COLS := 3   # colonnes (gauche→droite) sur le champ de bataille
const ARMY_ROWS := 5   # lignes (0 = front)
const ARMY_SIZE := ARMY_COLS * ARMY_ROWS
const BASE_SPEED_PX := 50.0  # vitesse "de référence" en pixels/s

## ===== TEMPLATE DATA (sauvegardé dans .tres) =====
@export var id: String = ""
@export var units: Array[UnitData] = []

## ===== RUNTIME DATA (pas sauvegardé, seulement en mémoire) =====
var runtime_position: Vector2i = Vector2i(-1, -1)  # Position sur la carte monde
var player: bool = false
var morale: int = 0
var max_morale: int = 0
var inventory: Inventory = Inventory.new()
## ===== INITIALISATION =====

func _init(_player: bool = false) -> void:
    player = _player
    if units.size() != ARMY_SIZE:
        units.resize(ARMY_SIZE)

## ===== CLONAGE RUNTIME =====

func clone_runtime(_player: bool = false) -> ArmyData:
    """Crée une copie runtime de l'armée (pour instanciation depuis template)"""
    var a := ArmyData.new(_player)
    a.id = id
    a.runtime_position = Vector2i(-1, -1)  # Position sera définie après
    a.units.resize(ARMY_SIZE)
    
    var total_morale: int = 0
    for i in units.size():
        var u := units[i]
        if u != null:
            # Clone aussi les unités
            a.units[i] = u.clone_runtime(_player)
            total_morale += u.morale
        else:
            a.units[i] = null
    
    a.morale = total_morale
    a.max_morale = total_morale
    return a

func describe():
    for unit in units:
        if unit:
            myLogger.debug(unit.describe(), LogTypes.Domain.ARMY)

## ===== GESTION DE POSITION =====

func set_position(pos: Vector2i) -> void:
    """Définit la position runtime de l'armée sur la carte"""
    runtime_position = pos

func get_position() -> Vector2i:
    """Récupère la position runtime de l'armée"""
    return runtime_position

func has_valid_position() -> bool:
    """Vérifie si l'armée a une position valide"""
    return runtime_position != Vector2i(-1, -1)

## ===== GETTER METHODS (organisation sur grille de combat) =====

func rc_from_index(idx: int) -> Vector2:
    """Convertit un index linéaire (0..ARMY_SIZE-1) en (col, row)"""
                      
    return Vector2(idx % ARMY_COLS, idx / ARMY_COLS)

func index_from_rc(row: int, col: int) -> int:
    """Convertit (row, col) en index linéaire"""
    return row * ARMY_COLS + col

func get_unit_at_index(idx: int) -> UnitData:
    if idx < 0 or idx >= units.size():
        return null
    return units[idx]

func get_unit_at_position(row: int, col: int) -> UnitData:
    return get_unit_at_index(index_from_rc(row, col))
    
                                                                      
                                                           
                               
    
    

## ===== SETTER METHODS =====

func set_unit_at_index(idx: int, unit: UnitData) -> void:
    if idx < 0 or idx >= units.size():
        return
    units[idx] = unit

func set_unit_rc(row: int, col: int, unit: UnitData) -> void:
    set_unit_at_index(index_from_rc(row, col), unit)

func set_unit_at_position(row: int, col: int, unit: UnitData) -> void:
    set_unit_rc(row, col, unit)

## ===== TEST METHODS =====

              
func is_dead() -> bool:
    """Vérifie si toutes les unités sont mortes"""
    for unit in units:
        if unit != null and unit.hp > 0:
            return false
    return true

func get_all_ready_units(action: PowerEnums.PowerType, phase: PowerEnums.PowerType) -> Array[UnitData]:
    """Récupère toutes les unités prêtes pour une action donnée"""
    var readyUnits: Array[UnitData] = []
    for col in range(ARMY_COLS):
        var unit: UnitData = get_unit_at_position(0, col)
        if unit != null:
            if unit.is_ready_for(action, phase):
                readyUnits.append(unit)
    return readyUnits

## ===== ORGANIZATION METHODS =====

                     
func compact_columns() -> void:
    """Fait tomber les unités vers le front (row 0) comme dans Puissance 4"""
    for col in range(ARMY_COLS):
        compact_column(col)

func compact_column(col: int) -> void:
    """Fait tomber les unités d'une colonne vers le front"""
    var stack: Array[UnitData] = []
    
    # Collecte les unités vivantes
    for row in range(ARMY_ROWS):
        var u := get_unit_at_position(row, col)
        if u != null and u.hp > 0:
            stack.append(u)
    
    # Replace depuis row 0
    var row_index := 0
    for u in stack:
        set_unit_rc(row_index, col, u)
        row_index += 1
    
    # Vide le reste
    while row_index < ARMY_ROWS:
        set_unit_rc(row_index, col, null)
        row_index += 1
                 
                                                                                  
                                                                
                                                          
func swap_units(from_col: int, from_row: int, to_col: int, to_row: int) -> void:
    """Échange deux unités de position"""
    var from_unit = get_unit_at_position(from_row, from_col)
    var to_unit = get_unit_at_position(to_row, to_col)
    
    set_unit_rc(to_row, to_col, from_unit)
    set_unit_rc(from_row, from_col, to_unit)

## ===== WORLD METHODS (repos, soins) =====
func on_army_destroyed(army_id: String, pos: Vector2i) -> void:
    var army = ArmyManagerRunner.get_army(army_id)
    if army == null:
        return

    # 1) spawn loot site avec inventory de l'armée
    if LootSiteManagerRunner:
        LootSiteManagerRunner.spawn_site(pos, army.inventory, 20)

    # 2) vider inventaire si tu gardes army object en mémoire
    army.inventory = Inventory.new()

func rest(cell_type: TilesEnums.CellType) -> void:
    """Applique les soins de repos selon le type de terrain"""
    var cellInfo: TilesEnums.CellInfo = TilesEnums.CELL_ENUM[cell_type]
    var heal_ratio_hp = cellInfo.rest_hp_ratio
    var heal_ratio_morale = cellInfo.rest_morale_ratio
    
    # Soin des unités
    for i in ARMY_SIZE:
        var unit := get_unit_at_index(i)
        if unit == null:
            continue
        if unit.hp <= 0:
            continue  # unité morte : pas de miracle
        
        # Soin des PV
        var missing_hp := unit.max_hp - unit.hp
        if missing_hp > 0:
            var heal_hp := int(unit.max_hp * heal_ratio_hp)
            if heal_hp < 1 and missing_hp > 0:
                heal_hp = 1
            unit.hp = clamp(unit.hp + heal_hp, 0, unit.max_hp)
            myLogger.debug("%s soigne %d HP → %d/%d" % [unit.name, heal_hp, unit.hp, unit.max_hp], LogTypes.Domain.ARMY)
    
    # Soin du moral
    var missing_morale := max_morale - morale
    if missing_morale > 0:
        var heal_morale := int(missing_morale * heal_ratio_morale)
        if heal_morale < 1 and missing_morale > 0:
            heal_morale = 1
        morale = clamp(morale + heal_morale, 0, max_morale)
        myLogger.debug("Moral restauré: +%d → %d/%d" % [heal_morale, morale, max_morale], LogTypes.Domain.ARMY)

## ===== COMBAT METHODS =====

func apply_reinforcements() -> void:
    """Fait avancer les renforts après la mort d'une unité en front"""
    for col in ARMY_COLS:
        var unit: UnitData = get_unit_at_position(0, col)
        if unit == null or unit.hp <= 0:
            units[index_from_rc(0, col)] = null
            for row in range(1, ARMY_ROWS):
                var reinforcement: UnitData = get_unit_at_position(row, col)
                if reinforcement != null and reinforcement.hp >= 0:
                    set_unit_at_position(0, col, reinforcement)
                    units[index_from_rc(row, col)] = null
                    compact_columns()
                    break

func get_attacks(defenders: ArmyData, action: PowerEnums.PowerType, phase: PowerEnums.PowerType) -> Array[AttackData]:
    """Génère les attaques pour un tour de combat"""
    var attacks: Array[AttackData] = []
    var readyUnits: Array[UnitData] = get_all_ready_units(action, phase)
    
    if not readyUnits.is_empty():
        for attacker: UnitData in readyUnits:
            var targets = attacker.get_targets(defenders)
            if not targets.is_empty():
                var power: int = attacker.get_score(action)
                var attack: AttackData = AttackData.new(attacker, targets, action, phase, power)
                attacks.append(attack)
    
    return attacks

func retreat_front_unit(col: int) -> void:
    """Fait reculer l'unité en front vers l'arrière"""
    var retreating_unit = get_unit_at_position(0, col)
    var last_row = 0
    var last_unit = null
    
    for row in range(1, ARMY_ROWS):
        last_row = row
        var current_unit = get_unit_at_position(row, col)
        if current_unit != null or last_unit == current_unit:
            set_unit_rc(row - 1, col, current_unit)
        else:
            break
    
    set_unit_rc(last_row, col, retreating_unit)
    compact_column(col)

## ===== UTILITY METHODS =====

func get_alive_count() -> int:
    """Compte le nombre d'unités vivantes"""
    var count = 0
    for unit in units:
        if unit != null and unit.hp > 0:
            count += 1
    return count

func get_total_hp() -> int:
    """Calcule les HP totaux de l'armée"""
    var total = 0
    for unit in units:
        if unit != null:
            total += unit.hp
    return total

func get_max_hp() -> int:
    """Calcule les HP max totaux de l'armée"""
    var total = 0
    for unit in units:
        if unit != null:
            total += unit.max_hp
    return total

## ===== DEBUG =====

func debug_print() -> void:
    myLogger.debug("\n=== ARMÉE: %s ===" % id, LogTypes.Domain.ARMY)
    myLogger.debug("Position: %s" % runtime_position, LogTypes.Domain.ARMY)
    myLogger.debug("Unités vivantes: %d/%d" % [get_alive_count(), ARMY_SIZE], LogTypes.Domain.ARMY)
    myLogger.debug("HP: %d/%d" % [get_total_hp(), get_max_hp()], LogTypes.Domain.ARMY)
    myLogger.debug("Moral: %d/%d" % [morale, max_morale], LogTypes.Domain.ARMY)
    myLogger.debug("\nFormation:", LogTypes.Domain.ARMY)
    for row in range(ARMY_ROWS):
        var line = "  Row %d: " % row
        for col in range(ARMY_COLS):
            var unit = get_unit_at_position(row, col)
            if unit:
                line += "[%s %dHP] " % [unit.name, unit.hp]
            else:
                line += "[----] "
        myLogger.debug(line, LogTypes.Domain.ARMY)
    myLogger.debug("================\n", LogTypes.Domain.ARMY)
