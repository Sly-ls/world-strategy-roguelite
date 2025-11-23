extends Control

const COLS := 3
const ROWS := 5
const GRID_SIZE := COLS * ROWS

@onready var grid_allies: GridContainer = $GridAllies
@onready var grid_enemies: GridContainer = $GridEnemies
var turn_counter:int = 0;
var battle_over: bool = false
var ally_slots: Array = []
var enemy_slots: Array = []

# Chaque entrée sera un dictionnaire { unit_data: UnitData, hp: int, attack_cd: float }
var allies: Array = []
var enemies: Array = []

var tick_timer: float = 0.0
const TICK_INTERVAL := 0.2  # secondes entre deux ticks de combat


func _ready() -> void:
    ally_slots = grid_allies.get_children()
    enemy_slots = grid_enemies.get_children()
    #_init_test_armies()
    _init_from_game_state()
    _refresh_all_slots()
    
func _init_from_game_state() -> void:
    allies.clear()
    enemies.clear()

    allies.resize(GRID_SIZE)
    enemies.resize(GRID_SIZE)

    for i in GRID_SIZE:
        allies[i] = null
        enemies[i] = null

    if WorldState.player_army != null:
        for i in min(WorldState.player_army.units.size(), GRID_SIZE):
            var unit: UnitData = WorldState.player_army.units[i]
            if unit != null:
                allies[i] = _make_combat_unit(unit)

    if WorldState.enemy_army != null:
        for i in min(WorldState.enemy_army.units.size(), GRID_SIZE):
            var unit_e: UnitData = WorldState.enemy_army.units[i]
            if unit_e != null:
                enemies[i] = _make_combat_unit(unit_e)
                

func _process(delta: float) -> void:
    tick_timer += delta
    if tick_timer >= TICK_INTERVAL:
        tick_timer -= TICK_INTERVAL
        turn_counter += 1
        _combat_tick()

func _refresh_all_slots() -> void:
    _refresh_slots_for_side(ally_slots, allies, true)
    _refresh_slots_for_side(enemy_slots, enemies, false)


func _refresh_slots_for_side(slots: Array, units: Array, is_ally: bool) -> void:
    for i in slots.size():
        var slot := slots[i] as TextureRect
        slot.mouse_filter = Control.MOUSE_FILTER_IGNORE

        var u = units[i]
        if u == null:
            slot.modulate = Color(0.2, 0.2, 0.2)
            slot.tooltip_text = ""
        else:
            slot.modulate = Color(0.6, 0.6, 1.0) if is_ally else Color(1.0, 0.6, 0.6)
            var data: UnitData = u["unit_data"]
            var hp: int = u["hp"]
            slot.tooltip_text = "%s\nPV: %d / %d" % [data.name, hp, data.max_hp]
            
func _combat_tick() -> void:
    if battle_over:
        return
    print("Tour %d" % turn_counter)

    # 1. Phase distance
    _phase_attack(allies, enemies, "ranged")
    _phase_attack(enemies, allies, "ranged")

    # 2. Phase CàC
    _phase_attack(allies, enemies, "melee")
    _phase_attack(enemies, allies, "melee")

    # 3. Phase magie
    _phase_attack(allies, enemies, "magic")
    _phase_attack(enemies, allies, "magic")

    # 4. Renforts
    _apply_reinforcements_for_both()

    # 5. UI + fin
    _refresh_all_slots()
    _check_end_of_combat()

    
func _phase_attack(attacking_side: Array, defending_side: Array, phase: String) -> void:
    # On regarde d'abord s'il y a au moins une cible sur la ligne de front adverse
    if get_front_target_index_for_side(defending_side) == -1:
        return

    var front_row := 0

    for col in COLS:
        # Attaquant = unité sur la ligne de front, dans cette colonne
        var attacker_idx := index_from_rc(front_row, col)
        var attacker = attacking_side[attacker_idx]
        if attacker == null or attacker["hp"] <= 0:
            continue

        var data: UnitData = attacker["unit_data"]

        var power := 0
        match phase:
            "ranged":
                power = data.ranged_power
            "melee":
                power = data.melee_power
            "magic":
                power = data.magic_power

        if power <= 0:
            continue

        # Cible : toujours la première unité vivante de la ligne adverse (colonne 0 → 1 → 2)
        var target_idx := get_front_target_index_for_side(defending_side)
        if target_idx == -1:
            break  # plus personne à frapper

        var target = defending_side[target_idx]
        if target == null or target["hp"] <= 0:
            continue

        var target_data: UnitData = target["unit_data"]
        var target_hp: int = target["hp"]

        target_hp -= power
        target["hp"] = target_hp

        print("%s (%s) frappe %s pour %d dégâts (PV restants: %d)" % [
            data.name, phase, target_data.name, power, target_hp
        ])

        if target_hp <= 0:
            print("%s meurt" % target_data.name)
            defending_side[target_idx] = null

        # si plus aucune cible vivante après ce coup, on s'arrête pour cette phase
        if get_front_target_index_for_side(defending_side) == -1:
            break



func _side_attack(attacking_side: Array, defending_side: Array) -> void:
    for i in attacking_side.size():
        var u = attacking_side[i]
        if u == null:
            continue

        var data: UnitData = u["unit_data"]
        var hp: int = u["hp"]

        if hp <= 0:
            continue

        # réduire cooldown
        u["attack_cd"] -= TICK_INTERVAL
        if u["attack_cd"] > 0:
            continue

        # trouver une cible en face : même index pour ce proto
        var target_index := i
        if target_index < 0 or target_index >= defending_side.size():
            continue

        var target = defending_side[target_index]
        if target == null:
            continue

        var target_data: UnitData = target["unit_data"]
        var target_hp: int = target["hp"]

        # dégâts = melee_power pour ce proto
        var dmg: int = max(data.melee_power, max(data.ranged_power, data.magic_power))
        if dmg <= 0:
            dmg = 5  # fallback

        target_hp -= dmg
        target["hp"] = target_hp

        print("%s frappe %s pour %d dégâts (PV restants: %d)" % [
            data.name, target_data.name, dmg, target_hp
        ])

        # reset cooldown
        u["attack_cd"] = data.attack_interval

        # si la cible meurt
        if target_hp <= 0:
            print("%s est éliminé !" % target_data.name)
            defending_side[target_index] = null


func _is_side_dead(side: Array) -> bool:
    for u in side:
        if u != null and u["hp"] > 0:
            return false
    return true
    
func _init_test_armies() -> void:
    allies.clear()
    enemies.clear()

    # Fabriquer 3 unités côté joueur
    var knight := UnitData.new()
    knight.name = "Chevaliers"
    knight.max_hp = 600
    knight.hp = 600
    knight.melee_power = 25
    knight.attack_interval = 1.5
    knight.count = 6

    var archer := UnitData.new()
    archer.name = "Archers"
    archer.max_hp = 300
    archer.hp = 300
    archer.melee_power = 8
    archer.ranged_power = 18
    archer.attack_interval = 1.2
    archer.count = 10

    var mage := UnitData.new()
    mage.name = "Mage"
    mage.max_hp = 200
    mage.hp = 200
    mage.magic_power = 30
    mage.attack_interval = 2.0
    mage.count = 4

    # On ne gère que 3 unités pour ce proto, on les met devant (ligne 0)
    allies.resize(GRID_SIZE)
    for i in GRID_SIZE:
        allies[i] = null

    var knight_2 := knight.duplicate()
    knight_2.name = "Chevaliers 2"
    var archer_2 := archer.duplicate()
    archer_2.name = "Archers 2"
    var mage_2 := mage.duplicate()
    mage_2.name = "Mage 2"
    allies[0] = _make_combat_unit(knight)
    allies[1] = _make_combat_unit(archer)
    allies[2] = _make_combat_unit(mage)
    allies[3] = _make_combat_unit(knight_2)
    allies[4] = _make_combat_unit(archer_2)
    allies[5] = _make_combat_unit(mage_2)

    # Côté ennemi, clones simplifiés
    var e_knight := knight.duplicate()
    e_knight.name = "Chevaliers ennemis"
    var e_archer := archer.duplicate()
    e_archer.name = "Archers ennemis"
    var e_mage := mage.duplicate()
    e_mage.name = "Mage ennemi"
    var e_knight_2 := knight.duplicate()
    e_knight_2.name = "Chevaliers 2 ennemis"
    var e_archer_2 := archer.duplicate()
    e_archer_2.name = "Archers 2 ennemis"
    var e_mage_2 := mage.duplicate()
    e_mage_2.name = "Mage 2 ennemi"
    enemies.resize(GRID_SIZE)
    for i in GRID_SIZE:
        enemies[i] = null

    enemies[0] = _make_combat_unit(e_knight)
    enemies[1] = _make_combat_unit(e_archer)
    enemies[2] = _make_combat_unit(e_mage)
    enemies[3] = _make_combat_unit(e_knight_2)
    enemies[4] = _make_combat_unit(e_archer_2)
    enemies[5] = _make_combat_unit(e_mage_2)


func _make_combat_unit(data: UnitData) -> Dictionary:
    return {
        "unit_data": data,
        "hp": data.hp,
        "attack_cd": 0.0  # prêt à frapper immédiatement
    }
    
func get_front_index_for_col(side: Array, col: int) -> int:
    for row in ROWS:
        var idx = index_from_rc(row, col)
        var u = side[idx]
        if u != null and u["hp"] > 0:
            return idx
    return -1
    
func _apply_reinforcements_for_both() -> void:
    apply_reinforcements(allies)
    apply_reinforcements(enemies)


func apply_reinforcements(side: Array) -> void:
    # Idée simple : pour chaque colonne, on "tasse" les unités vivantes vers la ligne 0
    for col in COLS:
        var write_row := 0

        for row in ROWS:
            var idx := index_from_rc(row, col)
            var unit = side[idx]

            if unit != null and unit["hp"] > 0:
                var target_idx := index_from_rc(write_row, col)
                if target_idx != idx:
                    # on déplace l'unité vers la première ligne libre
                    side[target_idx] = unit
                    side[idx] = null
                write_row += 1
                
func _check_end_of_combat() -> void:
    var allies_dead := _is_side_dead(allies)
    var enemies_dead := _is_side_dead(enemies)

    if allies_dead and enemies_dead:
        print("Match nul : les deux camps sont morts.")
        _apply_results_to_player_army("draw")
        WorldState.last_battle_result = "draw"
        _end_battle()
    elif allies_dead:
        print("Défaite !")
        _apply_results_to_player_army("defeat")
        WorldState.last_battle_result = "defeat"
        _end_battle()
    elif enemies_dead:
        print("Victoire !")
        _apply_results_to_player_army("victory")
        WorldState.last_battle_result = "victory"
        _end_battle()

func get_front_target_index_for_side(side: Array) -> int:
    var front_row := 0
    for col in COLS:
        var idx := index_from_rc(front_row, col)
        var u = side[idx]
        if u != null and u["hp"] > 0:
            return idx
    return -1


func index_from_rc(row: int, col: int) -> int:
    return row * COLS + col

func rc_from_index(index: int) -> Vector2i:
    return Vector2i(index / COLS, index % COLS) # row, col

func _on_QuitButton_pressed() -> void:
    print("Quit combat requested (retreat)")
    if not battle_over:
        _apply_results_to_player_army("retreat")
        WorldState.last_battle_result = "retreat"
    _end_battle()

func _apply_results_to_player_army(result: String) -> void:
    if WorldState.player_army == null:
        return

    var army := WorldState.player_army

    for i in GRID_SIZE:
        var combat_unit = allies[i]
        var data: UnitData = army.get_unit_at(i)

        if data == null:
            continue
        
        if combat_unit == null or combat_unit["hp"] <= 0:
            # L'unité est détruite → on libère le slot dans l'armée
            army.set_unit_at(i, null)
            continue
        else:
            var hp_after := int(combat_unit["hp"])
            data.hp = clamp(hp_after, 0, data.max_hp)


    # moral en bonus/malus, comme on avait fait
    match result:
        "victory":
            for i in GRID_SIZE:
                var u := army.get_unit_at(i)
                if u != null:
                    u.morale = clamp(u.morale + 10, 0, u.max_morale)
        "defeat", "retreat":
            for i in GRID_SIZE:
                var u := army.get_unit_at(i)
                if u != null:
                    u.morale = clamp(u.morale - 15, 0, u.max_morale)
        "draw":
            for i in GRID_SIZE:
                var u := army.get_unit_at(i)
                if u != null:
                    u.morale = clamp(u.morale - 5, 0, u.max_morale)

                 
func _end_battle() -> void:
    if battle_over:
        return
    battle_over = true
    set_process(false)
    # Retour à la world map
    get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")
