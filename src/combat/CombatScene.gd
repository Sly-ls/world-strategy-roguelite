extends Control

@onready var grid_allies: GridContainer = $GridAllies
@onready var grid_enemies: GridContainer = $GridEnemies
var turn_counter:int = 0;
var battle_over: bool = false
var ally_slots: Array = []
var enemy_slots: Array = []

# Chaque entrée sera un dictionnaire { unit_data: UnitData, hp: int, attack_cd: float }
# var allies: Array = []
# var enemies: Array = []
var allies: ArmyData = null
var enemies: ArmyData = null

var tick_timer: float = 0.0
const TICK_INTERVAL := 0.2  # secondes entre deux ticks de combat


func _ready() -> void:
    ally_slots = grid_allies.get_children()
    enemy_slots = grid_enemies.get_children()
    _init_from_game_state()
    _refresh_all_slots()
    
func _init_from_game_state() -> void:
    allies = WorldState.player_army
    enemies = WorldState.enemy_army
               

func _process(delta: float) -> void:
    tick_timer += delta
    if tick_timer >= TICK_INTERVAL:
        tick_timer -= TICK_INTERVAL
        turn_counter += 1
        _combat_tick()

func _refresh_all_slots() -> void:
    _refresh_slots_for_side(ally_slots, allies.units, true)
    _refresh_slots_for_side(enemy_slots, enemies.units, false)


func _refresh_slots_for_side(slots: Array, units: Array, is_ally: bool) -> void:
    print("size:", units.size())
    for i in slots.size():
        if i >= units.size():
            break
        var slot := slots[i] as TextureRect
        slot.mouse_filter = Control.MOUSE_FILTER_IGNORE

        var u = units[i]
        if u == null:
            slot.modulate = Color(0.2, 0.2, 0.2)
            slot.tooltip_text = ""
        else:
            slot.modulate = Color(0.6, 0.6, 1.0) if is_ally else Color(1.0, 0.6, 0.6)
            var data: UnitData = u
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

    
func _phase_attack(attacking_side: ArmyData, defending_side: ArmyData, phase: String) -> void:
    # On regarde d'abord s'il y a au moins une cible sur la ligne de front adverse
    if defending_side.get_front_target_index_for_side() == -1:
        return

    var front_row := 0

    for col in attacking_side.ARMY_COLS:
        # Attaquant = unité sur la ligne de front, dans cette colonne
        var attacker_idx := attacking_side.index_from_rc(front_row, col)
        var attacker = attacking_side.units[attacker_idx]
        if attacker == null or attacker.hp <= 0:
            continue

        var power := 0
        match phase:
            "ranged":
                power = attacker.ranged_power
            "melee":
                power = attacker.melee_power
            "magic":
                power = attacker.magic_power

        if power <= 0:
            continue

        # Cible : toujours la première unité vivante de la ligne adverse (colonne 0 → 1 → 2)
        var target_idx := defending_side.get_front_target_index_for_side()
        if target_idx == -1:
            break  # plus personne à frapper

        var target = defending_side.units[target_idx]
        if target == null or target.hp <= 0:
            continue

        target.hp = -power

        print("%s (%s) frappe %s pour %d dégâts (PV restants: %d)" % [
            attacker.name, phase, target.name, power, target.hp
        ])

        if target.hp <= 0:
            print("%s meurt" % target.name)
            defending_side.units[target_idx] = null

        # si plus aucune cible vivante après ce coup, on s'arrête pour cette phase
        if defending_side.get_front_target_index_for_side() == -1:
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

func _make_combat_unit(data: UnitData) -> Dictionary:
    return {
        "unit_data": data,
        "hp": data.hp,
        "attack_cd": 0.0  # prêt à frapper immédiatement
    }
    
func get_front_index_for_col(side: ArmyData, col: int) -> int:
    for row in side.ARMY_ROWS:
        var idx = side.index_from_rc(row, col)
        var u = side.units[idx]
        if u != null and u["hp"] > 0:
            return idx
    return -1
    
func _apply_reinforcements_for_both() -> void:
    allies.apply_reinforcements()
    enemies.apply_reinforcements()

                
func _check_end_of_combat() -> void:
    var allies_dead := allies.is_dead()
    var enemies_dead := enemies.is_dead()

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



func _on_QuitButton_pressed() -> void:
    print("Quit combat requested (retreat)")
    if not battle_over:
        _apply_results_to_player_army("retreat")
        WorldState.last_battle_result = "retreat"
    _end_battle()

func _apply_results_to_player_army(result: String) -> void:
    if WorldState.player_army == null:
        return
    _apply_reinforcements_for_both


    # moral en bonus/malus, comme on avait fait
    match result:
        "victory":
            pass
        "defeat", "retreat":
            pass
        "draw":
            pass

                 
func _end_battle() -> void:
    if battle_over:
        return
    battle_over = true
    set_process(false)
    # tu as déjà mis à jour WorldState.player_army depuis le combat
    var army := WorldState.player_army
    if army != null:
        army.compact_columns()
    # Retour à la world map
    get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")
