## ArmyService.gd
## Service centralisé pour la gestion des armées (joueur et ennemies)
class_name ArmyService
extends RefCounted

## Signaux pour communiquer les changements
signal army_updated(army: ArmyData)
signal unit_added(army: ArmyData, unit: UnitData)
signal unit_removed(army: ArmyData, unit: UnitData)
signal unit_died(army: ArmyData, unit: UnitData)
signal army_position_changed(new_position: Vector2i)
signal army_defeated(army: ArmyData)

## Armée du joueur (référence)
var player_army: ArmyData = null
var player_position: Vector2i = Vector2i.ZERO

## Armées ennemies actives (pour les combats)
var active_enemy_armies: Array[ArmyData] = []

## Initialise le service avec l'armée du joueur
func initialize(p_player_army: ArmyData, initial_position: Vector2i) -> void:
    player_army = p_player_army
    player_position = initial_position
    print("[ArmyService] Initialisé avec armée: %d unités à %s" % [get_unit_count(player_army), initial_position])

## Met à jour la position de l'armée du joueur
func set_army_position(new_pos: Vector2i) -> void:
    if new_pos != player_position:
        player_position = new_pos
        army_position_changed.emit(new_pos)

## Récupère la position actuelle
func get_army_position() -> Vector2i:
    return player_position

## Ajoute une unité à l'armée du joueur
func add_unit_to_player(unit: UnitData) -> bool:
    if not player_army:
        print("[ArmyService] ERREUR: Pas d'armée joueur")
        return false
    var max_army_units = player_army.ARMY_COLS * player_army.ARMY_ROWS
    # Vérifie qu'il y a de la place
    if get_unit_count(player_army) >= max_army_units:
        print("[ArmyService] Armée pleine (%d/%d)" % [get_unit_count(player_army), player_army.max_units])
        return false
    
    # Trouve un slot libre
    for i in range(max_army_units):
        if player_army.units[i] == null:
            player_army.units[i] = unit
            unit_added.emit(player_army, unit)
            army_updated.emit(player_army)
            print("[ArmyService] Unité ajoutée: %s au slot %d" % [unit.name, i])
            return true
    
    return false

## Retire une unité de l'armée du joueur
func remove_unit_from_player(unit: UnitData) -> bool:
    if not player_army:
        return false
    
    for i in range(player_army.units.size()):
        if player_army.units[i] == unit:
            player_army.units[i] = null
            unit_removed.emit(player_army, unit)
            army_updated.emit(player_army)
            print("[ArmyService] Unité retirée: %s du slot %d" % [unit.name, i])
            return true
    
    return false

## Soigne toutes les unités de l'armée du joueur
func heal_player_army(heal_amount: int) -> void:
    if not player_army:
        return
    
    var healed_count = 0
    for unit in player_army.units:
        if unit != null and unit.hp < unit.max_hp:
            var old_hp = unit.hp
            unit.hp = min(unit.hp + heal_amount, unit.max_hp)
            if unit.hp != old_hp:
                healed_count += 1
    
    if healed_count > 0:
        army_updated.emit(player_army)
        print("[ArmyService] %d unités soignées (+%d HP)" % [healed_count, heal_amount])

## Applique des dégâts à l'armée du joueur
func damage_player_army(damage: int, target_unit: UnitData = null) -> void:
    if not player_army:
        return
    
    if target_unit:
        # Dégâts ciblés
        _apply_damage_to_unit(player_army, target_unit, damage)
    else:
        # Dégâts aléatoires sur une unité vivante
        var alive_units = get_alive_units(player_army)
        if not alive_units.is_empty():
            var random_unit = alive_units.pick_random()
            _apply_damage_to_unit(player_army, random_unit, damage)
    
    army_updated.emit(player_army)
    
    # Vérifie si l'armée est défaite
    if is_army_defeated(player_army):
        army_defeated.emit(player_army)

## Applique des dégâts à une unité spécifique
func _apply_damage_to_unit(army: ArmyData, unit: UnitData, damage: int) -> void:
    if unit.hp <= 0:
        return
    
    unit.hp = max(0, unit.hp - damage)
    print("[ArmyService] %s prend %d dégâts (HP: %d/%d)" % [unit.name, damage, unit.hp, unit.max_hp])
    
    if unit.hp == 0:
        unit_died.emit(army, unit)
        print("[ArmyService] %s est mort !" % unit.name)

## Compte le nombre d'unités vivantes dans l'armée
func get_alive_unit_count(army: ArmyData = null) -> int:
    if army == null:
        army = player_army
    
    if not army:
        return 0
    
    var count = 0
    for unit in army.units:
        if unit != null and unit.hp > 0:
            count += 1
    return count

## Récupère toutes les unités vivantes
func get_alive_units(army: ArmyData = null) -> Array[UnitData]:
    if army == null:
        army = player_army
    
    var alive: Array[UnitData] = []
    if army:
        for unit in army.units:
            if unit != null and unit.hp > 0:
                alive.append(unit)
    return alive

## Compte le nombre total d'unités (vivantes + mortes)
func get_unit_count(army: ArmyData = null) -> int:
    if army == null:
        army = player_army
    
    if not army:
        return 0
    
    var count = 0
    for unit in army.units:
        if unit != null:
            count += 1
    return count

## Vérifie si l'armée est défaite
func is_army_defeated(army: ArmyData = null) -> bool:
    return get_alive_unit_count(army) == 0

## Compacte l'armée (retire les trous dans la formation)
func compact_player_army() -> void:
    if not player_army:
        return
    
    var compacted: Array = []
    for unit in player_army.units:
        if unit != null:
            compacted.append(unit)
    
    # Remplit avec des nulls
    while compacted.size() < player_army.max_units:
        compacted.append(null)
    
    player_army.units = compacted
    army_updated.emit(player_army)
    print("[ArmyService] Armée compactée")

## Crée une copie d'une armée ennemie pour le combat
func create_enemy_army(army_data: ArmyData) -> ArmyData:
    var enemy_army = ArmyData.new()
    enemy_army.faction_id = army_data.faction_id
    enemy_army.max_units = army_data.max_units
    
    # Copie les unités
    enemy_army.units = []
    for unit in army_data.units:
        if unit != null:
            var unit_copy = UnitData.new()
            unit_copy.unit_name = unit.unit_name
            unit_copy.unit_type = unit.unit_type
            unit_copy.max_hp = unit.max_hp
            unit_copy.current_hp = unit.current_hp
            unit_copy.attack = unit.attack
            unit_copy.defense = unit.defense
            unit_copy.speed = unit.speed
            enemy_army.units.append(unit_copy)
        else:
            enemy_army.units.append(null)
    
    active_enemy_armies.append(enemy_army)
    print("[ArmyService] Armée ennemie créée: %d unités" % get_unit_count(enemy_army))
    return enemy_army

## Nettoie les armées ennemies actives
func clear_enemy_armies() -> void:
    active_enemy_armies.clear()
    print("[ArmyService] Armées ennemies nettoyées")

## Restaure toute l'armée du joueur après le repos
func rest_player_army() -> void:
    if not player_army:
        return
    
    for unit in player_army.units:
        if unit != null:
            unit.current_hp = unit.max_hp
    
    army_updated.emit(player_army)
    print("[ArmyService] Armée du joueur reposée (HP restaurés)")

## Calcule les statistiques de l'armée
func get_army_stats(army: ArmyData = null) -> Dictionary:
    if army == null:
        army = player_army
    
    if not army:
        return {}
    
    var stats = {
        "total_units": get_unit_count(army),
        "alive_units": get_alive_unit_count(army),
        "total_hp": 0,
        "max_hp": 0,
        "total_attack": 0,
        "total_defense": 0,
        "average_speed": 0.0
    }
    
    var speed_sum = 0
    var alive_count = 0
    
    for unit in army.units:
        if unit != null:
            stats["total_hp"] += unit.hp
            stats["max_hp"] += unit.max_hp
            stats["total_attack"] += unit.get_score(PowerEnums.PowerType.MELEE)
   
    return stats

## Applique un effet à toute l'armée
func apply_army_effect(effect_type: String, value: int, army: ArmyData = null) -> void:
    if army == null:
        army = player_army
    
    if not army:
        return
    
    match effect_type:
        "heal":
            heal_player_army(value)
        "buff_attack":
            for unit in army.units:
                if unit != null:
                    unit.attack += value
            army_updated.emit(army)
        "buff_defense":
            for unit in army.units:
                if unit != null:
                    unit.defense += value
            army_updated.emit(army)
        "damage":
            damage_player_army(value)
    
    print("[ArmyService] Effet appliqué: %s (%d)" % [effect_type, value])

## Debug: affiche les infos de l'armée
func debug_print_army(army: ArmyData = null) -> void:
    if army == null:
        army = player_army
    
    if not army:
        print("[ArmyService] Aucune armée")
        return
    
    print("=== ARMÉE ===")
    print("Position: %s" % player_position)
    print("Unités: %d/%d (vivantes: %d)" % [get_unit_count(army), army.max_units, get_alive_unit_count(army)])
    
    for i in range(army.units.size()):
        var unit = army.units[i]
        if unit != null:
            var status = "vivante" if unit.current_hp > 0 else "morte"
            print("  [%d] %s - HP: %d/%d (%s)" % [i, unit.unit_name, unit.current_hp, unit.max_hp, status])
