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
var pending_attacks : Array[AttackData]= []

var tick_timer: float = 0.0
const TICK_INTERVAL := 0.2  # secondes entre deux ticks de combat
var combat_phases: Array[String] = ["Initiative", "", "Lent"]


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

        var unit = units[i]
        if unit == null:
            slot.modulate = Color(0.2, 0.2, 0.2)
            slot.tooltip_text = ""
            slot.texture = null
        else:
            slot.modulate = Color(0.6, 0.6, 1.0) if is_ally else Color(1.0, 0.6, 0.6)
            slot.texture = unit.icon
            slot.tooltip_text = "%s\nPV: %d / %d" % [unit.name, unit.hp, unit.max_hp]
            
func _combat_tick() -> void:
    if battle_over:
        return
    print("Tour %d" % turn_counter)
    
    # 1. Phase distance
    for phase :String in combat_phases:
        do_attack("ranged", phase)
    
    # 2. Phase CàC
    for phase :String in combat_phases:
        do_attack("melee", phase)
    
    # 3. Phase magie
    for phase :String in combat_phases:
        do_attack("magic", phase)
        
    # 4. Renforts
    allies.apply_reinforcements()
    enemies.apply_reinforcements()

    # 5. UI + fin
    _refresh_all_slots()
    _check_end_of_combat()
    
func do_attack(action: String, phase :String) -> void :
    pending_attacks.clear()
    var attacks : Array[AttackData]= allies.get_attacks(enemies, action, phase)
    pending_attacks.append_array(attacks)
    var attacks_2 : Array[AttackData]= enemies.get_attacks(allies, action, phase)
    pending_attacks.append_array(attacks_2)
    for attack :AttackData in pending_attacks:
        attack.apply()
    
        
func get_front_index_for_col(side: ArmyData, col: int) -> int:
    for row in side.ARMY_ROWS:
        var idx = side.index_from_rc(row, col)
        var u = side.units[idx]
        if u != null and u["hp"] > 0:
            return idx
    return -1
    
                
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
    allies.apply_reinforcements()
    enemies.apply_reinforcements()


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
