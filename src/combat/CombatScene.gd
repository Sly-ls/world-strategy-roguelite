extends Control

# MODIFICATION: GridAllies et GridEnemies sont maintenant des UnitGridDisplay
@onready var grid_allies: UnitGridDisplay = $GridAllies
@onready var grid_enemies: UnitGridDisplay = $GridEnemies

var turn_counter:int = 1;
var battle_over: bool = false

# SUPPRIMÉ: ally_slots et enemy_slots ne sont plus nécessaires
# var ally_slots: Array = []
# var enemy_slots: Array = []

var allies: ArmyData = null
var enemies: ArmyData = null
var pending_attacks : Array[AttackData]= []

var tick_timer: float = 0.0
const TICK_INTERVAL := 0.2  # secondes entre deux ticks de combat
var is_resolving_round := false

var combat_phases: Array[PowerEnums.PowerType] = [PowerEnums.PowerType.INITIATIVE, PowerEnums.PowerType.NORMAL, PowerEnums.PowerType.SLOW]
var combat_actions: Array[PowerEnums.PowerType] = [PowerEnums.PowerType.RANGED, PowerEnums.PowerType.MELEE, PowerEnums.PowerType.MAGIC]
@onready var result_panel: BattleResultPanel = $BattleResultPanel

@onready var phase_label: Label = $TopInfo/ActionInfo/PhaseLabel
@onready var round_label: Label = $TopInfo/ActionInfo/RoundLabel
@onready var combat_log: RichTextLabel = $TopInfo/CombatLog
@onready var next_turn_button: Button = $NextTurnButton
@onready var retreat_buttons: Array[Button] = [
    $RetreatButtons/RetreatButtonCol0,
    $RetreatButtons/RetreatButtonCol1,
    $RetreatButtons/RetreatButtonCol2,
]

@onready var retreat_status: Array[bool] = [true,true,true]

func _ready() -> void:
    # SUPPRIMÉ: Récupération des slots (maintenant géré par UnitGridDisplay)
    # ally_slots = grid_allies.get_children()
    # enemy_slots = grid_enemies.get_children()
    
    round_label.text = "Round : %d" % turn_counter
    log_message("Debut du combat")
    _init_from_game_state()
    
    # MODIFICATION: Utiliser set_army() au lieu de _refresh_all_slots()
    _refresh_all_grids()
    
    update_buttons_status()
    result_panel.result_closed.connect(_on_battle_result_closed)
    next_turn_button.pressed.connect(_on_next_turn_button_pressed)
    for col in retreat_buttons.size():
        retreat_buttons[col].pressed.connect(_on_retreat_button_pressed.bind(col))
    
func _init_from_game_state() -> void:
    allies = WorldState.player_army
    enemies = WorldState.enemy_army
               

func _process(delta: float) -> void:
    tick_timer += delta
    if tick_timer >= TICK_INTERVAL:
        tick_timer -= TICK_INTERVAL

func update_buttons_status() -> void:
    _update_next_button_label()
    _update_retreat_buttons()
    
func _update_retreat_buttons() -> void:
    var show_retreat :bool = !battle_over && !is_resolving_round
    var idx: int = 0
    for btn:Button  in retreat_buttons:
        btn.visible = show_retreat && retreat_status[idx]
        idx += 1
        
func _run_one_round() -> void:
    is_resolving_round = true
    _combat_tick()
    is_resolving_round = false
    refresh_retreat_status()
    update_buttons_status()
    turn_counter += 1

func refresh_retreat_status() -> void:
    retreat_status = [true,true,true]

# NOUVEAU: Méthode pour rafraîchir les deux grilles
func _refresh_all_grids() -> void:
    """Met à jour l'affichage des deux grilles UnitGridDisplay"""
    if grid_allies:
        grid_allies.set_army(allies)
    if grid_enemies:
        grid_enemies.set_army(enemies)


# SUPPRIMÉ: _refresh_all_slots() et _refresh_slots_for_side() ne sont plus nécessaires
# Ces méthodes sont maintenant gérées par UnitGridDisplay._refresh_display()

# func _refresh_all_slots() -> void:
#     _refresh_slots_for_side(ally_slots, allies.units, true)
#     _refresh_slots_for_side(enemy_slots, enemies.units, false)
#
# func _refresh_slots_for_side(slots: Array, units: Array, is_ally: bool) -> void:
#     for i in slots.size():
#         if i >= units.size():
#             break
#         var slot := slots[i] as TextureRect
#         slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
#
#         var unit = units[i]
#         if unit == null:
#             slot.modulate = Color(0.2, 0.2, 0.2)
#             slot.tooltip_text = ""
#             slot.texture = null
#         else:
#             slot.modulate = Color(0.6, 0.6, 1.0) if is_ally else Color(1.0, 0.6, 0.6)
#             slot.texture = unit.icon
#             slot.tooltip_text = "%s\nPV: %d / %d" % [unit.name, unit.hp, unit.max_hp]
         
func _combat_tick() -> void:
    if battle_over:
        return
    print("Tour %d" % turn_counter)
    
    for action :PowerEnums.PowerType in  combat_actions:
        for phase :PowerEnums.PowerType in combat_phases:
            _update_round_phase_ui(action, phase)
            do_attack(action, phase)
        
    # 4. Renforts
    allies.apply_reinforcements()
    enemies.apply_reinforcements()

    # 5. UI + fin
    # MODIFICATION: Utiliser _refresh_all_grids() au lieu de _refresh_all_slots()
    _refresh_all_grids()
    _check_end_of_combat()

func log_messages(messages: Array[String]) -> void:
    for message in messages:
        log_message(message)
    
func log_message(message: String) -> void:
    if combat_log == null:
        print("ERROR : %s" % message)
        return
    combat_log.append_text(message + "\n")
    combat_log.scroll_to_line(combat_log.get_line_count() - 1)
    print(message)
    
func _update_round_phase_ui(action: PowerEnums.PowerType, phase :PowerEnums.PowerType) -> void:
    var action_name :String = PowerEnums.POWER_ENUM[action].name
    var phase_name :String = PowerEnums.POWER_ENUM[phase].name
    print("Phase : %s - %s (%d-%d)" % [action_name, phase_name,action,phase])
    phase_label.text = "Phase : %s - %s (%d-%d)" % [action_name, phase_name,action,phase]
    round_label.text = "Round : %d" % turn_counter
    
func do_attack(action: PowerEnums.PowerType, phase :PowerEnums.PowerType) -> void :
    pending_attacks.clear()
    var attacks : Array[AttackData]= allies.get_attacks(enemies, action, phase)
    pending_attacks.append_array(attacks)
    var attacks_2 : Array[AttackData]= enemies.get_attacks(allies, action, phase)
    pending_attacks.append_array(attacks_2)
    for attack :AttackData in pending_attacks:
        var messages : Array[String]= attack.apply()
        log_messages(messages)
   
                
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
    update_buttons_status()
    
func _update_next_button_label() -> void:
    if battle_over:
        next_turn_button.text = "Rapport de bataille"
    else:
        next_turn_button.text = "Jouer le tour %d" % (turn_counter + 1)
          

func _show_battle_result() -> void:
    # tu as déjà mis à jour WorldState.player_army depuis le combat
    var army := WorldState.player_army
    if army != null:
        army.compact_columns()
    var result = WorldState.last_battle_result
    var player_army = WorldState.allies_death
    var enemy_army = WorldState.ennemies_death

    # Optionnel : récupérer quelques lignes du combat_log si tu as un RichTextLabel,je ne l'utilise pas,je ne sais pas quoi en faire pour l'instant
    var extra_text := ""
    if combat_log != null && false:
        extra_text = combat_log.text

    # Afficher le panneau
    result_panel.show_result(result, player_army, enemy_army, extra_text)

func _on_next_turn_button_pressed() -> void:
    if is_resolving_round:
        return
    if battle_over:
        _show_battle_result()
        next_turn_button.visible = false
    else:
    # await _run_one_round_async() a utiliser quand il y aura mles animation
        _run_one_round()

func _on_battle_result_closed() -> void:
    # Ici, le résultat est déjà dans WorldGameState.last_battle_result
    # Tu peux retourner à la worldmap
    print("go to world map")
    get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")

func _on_retreat_button_pressed(col: int) -> void:
    print("Retreat col ", col)
    allies.reatreat_front_unit(col)
    retreat_status[col] = false
    
    # MODIFICATION: Utiliser update_display() au lieu de _refresh_slots_for_side()
    grid_allies.update_display()
    _update_retreat_buttons()
