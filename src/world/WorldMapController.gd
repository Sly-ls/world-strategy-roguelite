extends Node2D

const TILE_SIZE := 64
var GRID_WIDTH: int
var GRID_HEIGHT: int
@onready var background: Sprite2D = $Background

@onready var camera: Camera2D = $Camera2D
@onready var army_marker: Node2D = $ArmyMarker

var army_grid_pos: Vector2i = Vector2i(10, 6)
var zoom_level: float = 1.0

enum CellType { EMPTY, TOWN, RUINS, FOREST_SHRINE }
var world_grid: Array = []

@onready var event_ui: ColorRect = $UI_Layer/EventOverlay
@onready var date_label: Label = $UI_Layer/DateLabel
@onready var rest_label: Label = $UI_Layer/RestLabel
func _ready() -> void:
    if camera:
        camera.make_current()

    # Calcule la taille de la grille à partir de l'image
    var tex := background.texture
    GRID_WIDTH  = int(tex.get_width()  / TILE_SIZE)
    GRID_HEIGHT = int(tex.get_height() / TILE_SIZE)

    _init_world_grid()
    _update_army_world_position()
    _update_camera()
    
func _process(delta: float) -> void:
    # Avance le temps global
    WorldState.advance_time(delta)
    _update_date_ui()
    if WorldState.resting:
        _update_rest_timer(delta)
        
func _update_rest_timer(delta: float) -> void:
    WorldState.rest_seconds_remaining -= delta

    if WorldState.rest_seconds_remaining <= 0.0:
        _finish_rest()  
    else :
        print("Repos commencé pour %.1f secondes" % WorldState.rest_seconds_remaining)
            
func _finish_rest() -> void:
    WorldState.resting = false
    WorldState.rest_seconds_remaining = 0.0

    # Masquer le label "Zzz"
    if rest_label:
        rest_label.visible = false

    # Appliquer les effets de repos à l'armée
    var cell_type := _get_current_cell_type()
    _apply_rest_to_army(cell_type)

    print("Repos terminé !")
    print("Armée soignée et moral restauré.")


func _update_date_ui() -> void:
    if date_label:
        date_label.text = WorldState.get_formatted_date()
        
func _init_world_grid() -> void:
 world_grid.clear()

 for y in GRID_HEIGHT:
  var row: Array[CellType] = []
  for x in GRID_WIDTH:
   row.append(CellType.EMPTY)
  world_grid.append(row)

 world_grid[5][5] = CellType.TOWN
 world_grid[6][8] = CellType.RUINS
 world_grid[4][10] = CellType.FOREST_SHRINE

func _draw() -> void:
 # armée (cercle rouge)
 var pos = grid_to_world(army_grid_pos)
 draw_circle(pos, 8.0, Color(1, 0, 0))

 # POI
 for y in GRID_HEIGHT:
  for x in GRID_WIDTH:
   var cell: CellType = world_grid[y][x]
   if cell == CellType.EMPTY:
    continue

   var cell_pos = grid_to_world(Vector2i(x, y))
   match cell:
    CellType.TOWN:
     draw_circle(cell_pos, 6.0, Color(0, 1, 0))
    CellType.RUINS:
     draw_circle(cell_pos, 6.0, Color(1.0, 1.0, 1.0, 1.0))
    CellType.FOREST_SHRINE:
     draw_circle(cell_pos, 6.0, Color(0.852, 0.121, 0.654, 1.0))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
 return Vector2(
  float(grid_pos.x) * TILE_SIZE + TILE_SIZE * 0.5,
  float(grid_pos.y) * TILE_SIZE + TILE_SIZE * 0.5
 )
 
func _update_army_world_position() -> void:
 if army_marker:
  army_marker.position = grid_to_world(army_grid_pos)
  print("Army position:", army_marker.position)
  print("x", army_marker.position, army_marker.position.x / TILE_SIZE)
  print("y",  army_marker.position.y / TILE_SIZE, )
 else:
  print("Army marker is NULL!")
 queue_redraw()


func _update_camera() -> void:
 if camera:
  camera.position = army_marker.position
  _clamp_camera_to_world()


func _clamp_camera_to_world() -> void:
 var world_width  = GRID_WIDTH * TILE_SIZE
 var world_height = GRID_HEIGHT * TILE_SIZE

 var viewport_size: Vector2 = get_viewport_rect().size
 var half_view: Vector2 = viewport_size * 0.5

 var min_x = half_view.x
 var max_x = max(world_width - half_view.x, min_x)
 var min_y = half_view.y
 var max_y = max(world_height - half_view.y, min_y)

 camera.position.x = clamp(camera.position.x, min_x, max_x)
 camera.position.y = clamp(camera.position.y, min_y, max_y)


func _unhandled_input(event: InputEvent) -> void:
 if WorldState.resting:
  print("Impossible d'agir : repos en cours.")
  return

 if event.is_pressed():
  print("Unhanded input:", event)
 # Mouvements
 if event.is_action_pressed("move_up"):
  _try_move_army(Vector2i(0, -1))
 elif event.is_action_pressed("move_down"):
  _try_move_army(Vector2i(0, 1))
 elif event.is_action_pressed("move_left"):
  _try_move_army(Vector2i(-1, 0))
 elif event.is_action_pressed("move_right"):
  _try_move_army(Vector2i(1, 0))

 # Zoom via actions
 if event.is_action_pressed("zoom_in"):
  _change_zoom(0.1)
 elif event.is_action_pressed("zoom_out"):
  _change_zoom(-0.1)

 # Zoom via molette
 if event is InputEventMouseButton and event.pressed:
  if event.button_index == MOUSE_BUTTON_WHEEL_UP:
   _change_zoom(0.1)
  elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
   _change_zoom(-0.1)

func _try_move_army(delta_grid: Vector2i) -> void:
 var new_pos = army_grid_pos + delta_grid

 if new_pos.x < 0 or new_pos.x >= GRID_WIDTH:
  return
 if new_pos.y < 0 or new_pos.y >= GRID_HEIGHT:
  return

 army_grid_pos = new_pos
 _update_army_world_position()
 _update_camera()
 _on_enter_cell(army_grid_pos)

func _on_enter_cell(grid_pos: Vector2i) -> void:
    var cell: int = world_grid[grid_pos.y][grid_pos.x]

    match cell:
        CellType.EMPTY:
            return
        CellType.TOWN:
            print("Vous entrez dans une ville à", grid_pos)
            var ev := EventData.new()
            ev.id = "town_intro"
            ev.title = "Ville frontalière"
            ev.description = "Vous arrivez dans une petite ville en bordure du royaume. Les habitants semblent tendus."
            ev.choice_a_text = "Entrer en ville"
            ev.choice_b_text = "Continuer la route"
            event_ui.show_event(ev)
        CellType.RUINS:
            print("Vous découvrez des ruines à", grid_pos)
            _start_battle_from_ruins()
            # pour l'instant : ruines = combat
            #var ev := EventData.new()
            #ev.id = "ruins_intro"
            #ev.title = "Ruines anciennes"
            #ev.description = "Les pierres portent des inscriptions oubliées. Une aura de magie plane dans l'air."
            #ev.choice_a_text = "Explorer rapidement"
            #ev.choice_b_text = "Passer votre chemin"
            #event_ui.show_event(ev)
        CellType.FOREST_SHRINE:
            print("Sanctuaire forestier trouvé à", grid_pos)
            var ev := EventData.new()
            ev.id = "forest_shrine"
            ev.title = "Sanctuaire forestier"
            ev.description = "La végétation se fait dense et silencieuse. Devant vous, un autel recouvert de mousse."
            ev.choice_a_text = "Prier"
            ev.choice_b_text = "Ne pas déranger le lieu"
            event_ui.show_event(ev)

func _change_zoom(delta: float) -> void:
 zoom_level = clamp(zoom_level + delta, 0.5, 2.5)
 if camera:
  camera.zoom = Vector2(zoom_level, zoom_level)
  _clamp_camera_to_world()

func _start_battle_from_ruins() -> void:
    # 1) récupérer l'armée du joueur depuis l'UI
    var army_ui := $UI_Layer/ArmyPanel/HBoxContainer/VBoxContainer_Army as VBoxContainer
    var army_controller := army_ui as ArmyUIController
    var player_army := army_controller.get_army_data()

    # 2) fabriquer une armée ennemie temporaire
    var enemy_army := ArmyData.new()

    enemy_army.units.resize(ArmyData.ARMY_SIZE)
    for i in enemy_army.units.size():
        enemy_army.units[i] = null

    var enemy_knight := UnitData.new()
    enemy_knight.name = "Gobelins"
    enemy_knight.max_hp = 100
    enemy_knight.hp = 100
    enemy_knight.ranged_power = 0
    enemy_knight.melee_power = 40
    enemy_knight.magic_power = 0
    enemy_knight.count = 5

    var enemy_archer := UnitData.new()
    enemy_archer.name = "Archers Gobelins"
    enemy_archer.max_hp = 250
    enemy_archer.hp = 250
    enemy_archer.ranged_power = 50
    enemy_archer.melee_power = 0
    enemy_archer.magic_power = 0
    enemy_archer.count = 8

    enemy_army.set_unit_at(0, enemy_knight)
    enemy_army.set_unit_at(1, enemy_archer)

    # 3) stocker dans GameState
    WorldState.player_army = player_army
    WorldState.enemy_army = enemy_army
    # WorldGameState.player_army = player_army
    # WorldGameState.enemy_army = enemy_army

    # 4) changer de scène
    get_tree().change_scene_to_file("res://scenes/CombatScene.tscn")

func start_rest() -> void:
    if WorldState.resting:
        return

    WorldState.resting = true
    WorldState.rest_seconds_remaining = WorldState.REST_DURATION_SECONDS
    if rest_label:
        rest_label.visible = true

    print("Repos commencé pour %.1f secondes" % WorldState.rest_seconds_remaining)

func _on_rest_button_pressed() -> void:
    print("Signal RestButton reçu")
    start_rest()
    
func _get_current_cell_type() -> int:
    if army_grid_pos.y < 0 or army_grid_pos.y >= GRID_HEIGHT:
        return CellType.EMPTY
    if army_grid_pos.x < 0 or army_grid_pos.x >= GRID_WIDTH:
        return CellType.EMPTY
    return world_grid[army_grid_pos.y][army_grid_pos.x]

func _apply_rest_to_army(cell_type: int) -> void:
    if WorldState.player_army == null:
        return

    var army := WorldState.player_army

    var heal_ratio_hp := 0.25   # proportion de PV manquants rendus
    var heal_ratio_morale := 0.25

    # Modificateur selon la zone
    match cell_type:
        CellType.TOWN:
            # En ville : très bon repos
            heal_ratio_hp = 0.8
            heal_ratio_morale = 0.8
        CellType.FOREST_SHRINE:
            # Sanctuaire forestier : bon moral, soin correct
            heal_ratio_hp = 0.5
            heal_ratio_morale = 0.9
        CellType.RUINS:
            # Ruines : repos bof, peu rassurant
            heal_ratio_hp = 0.2
            heal_ratio_morale = 0.1
        _:
            # Plein air standard
            heal_ratio_hp = 0.3
            heal_ratio_morale = 0.3

    for i in army.ARMY_SIZE:
        var unit := army.get_unit_at(i)
        if unit == null:
            continue
        if unit.hp <= 0:
            continue  # unité morte : pas de miracle ici pour l'instant

        # Soin des PV : on rend une fraction des PV manquants
        var missing_hp := unit.max_hp - unit.hp
        if missing_hp > 0:
            var heal_hp := int(missing_hp * heal_ratio_hp)
            if heal_hp < 1 and missing_hp > 0:
                heal_hp = 1  # au moins 1 PV si il manque quelque chose
            unit.hp = clamp(unit.hp + heal_hp, 0, unit.max_hp)

        # Soin du moral : idem
        var missing_morale := unit.max_morale - unit.morale
        if missing_morale > 0:
            var heal_morale := int(missing_morale * heal_ratio_morale)
            if heal_morale < 1 and missing_morale > 0:
                heal_morale = 1
            unit.morale = clamp(unit.morale + heal_morale, 0, unit.max_morale)
