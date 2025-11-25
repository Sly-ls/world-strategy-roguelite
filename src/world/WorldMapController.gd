extends Node2D

#world map part
const TILE_SIZE := 64
var GRID_WIDTH: int
var GRID_HEIGHT: int
const CellType = GameEnums.CellType
var world_grid: Array = []
var zoom_level: float = 1.0
@onready var background: Sprite2D = $Background
@onready var camera: Camera2D = $Camera2D

#Army Part
@onready var army_marker: Node2D = $ArmyMarker
var army_grid_pos: Vector2i = Vector2i(10, 6)

#UI part
@onready var event_ui: ColorRect = $UI_Layer/EventOverlay
@onready var date_label: Label = $UI_Layer/DateLabel
@onready var rest_label: Label = $UI_Layer/RestLabel

#move part
var move_queue: Array[Vector2i] = []
var is_auto_moving: bool = false
var move_target: Vector2 = Vector2.ZERO
var is_moving: bool = false
const BASE_SPEED_PX := 30.0  # vitesse "de référence" en pixels/s

#event part
@onready var event_panel: EventPanel = $UI_Layer/EventPanel
var event_open: bool = false
var current_event: WorldEvent = null
var current_event_handler: WorldEventHandler = null

func _ready() -> void:
    if event_panel:
        event_panel.choice_made.connect(_on_event_choice_made)
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
    
    # Mouvement auto
    if not WorldState.resting and is_moving:
        _update_army_movement(delta)

func _update_army_movement(delta: float) -> void:
    if not is_instance_valid(army_marker):
        return

    var pos: Vector2 = army_marker.position
    var to_target: Vector2 = move_target - pos
    var dist_to_target := to_target.length()

    if dist_to_target < 1.0:
        army_marker.position = move_target
        is_moving = false
        _update_army_grid_pos_from_world()
        _update_camera()
        return

    var dir: Vector2 = to_target.normalized()

    # Biome actuel = cell logique actuelle
    var cell_type_current := _get_current_cell_type()
    var speed_mul :float = GameEnums.CELL_ENUM[cell_type_current].move_cost
    var effective_speed := BASE_SPEED_PX * speed_mul

    var step := effective_speed * delta

    # Position candidate
    var new_pos: Vector2
    if step >= dist_to_target:
        new_pos = move_target
    else:
        new_pos = pos + dir * step

    # On regarde dans quelle cell tomberait le nouveau point
    var gx := int(floor(new_pos.x / TILE_SIZE))
    var gy := int(floor(new_pos.y / TILE_SIZE))

    if gx < 0 or gx >= GRID_WIDTH or gy < 0 or gy >= GRID_HEIGHT:
        # Hors carte -> on stoppe
        is_moving = false
        return

    var next_cell_type :CellType = world_grid[gy][gx]
    if not GameEnums.CELL_ENUM[next_cell_type].walkable:
        # On ne franchit pas la case non walkable → on s'arrête au bord
        print("Obstacle infranchissable détecté, arrêt du mouvement.")
        is_moving = false
        return

    # Mouvement accepté
    army_marker.position = new_pos
    _update_army_grid_pos_from_world()
    _update_camera()


func _update_army_grid_pos_from_world() -> void:
    var pos: Vector2 = army_marker.position
    var gx := int(floor(pos.x / TILE_SIZE))
    var gy := int(floor(pos.y / TILE_SIZE))

    gx = clamp(gx, 0, GRID_WIDTH - 1)
    gy = clamp(gy, 0, GRID_HEIGHT - 1)

    var old_pos := army_grid_pos
    var new_pos := Vector2i(gx, gy)

    if new_pos != old_pos:
        army_grid_pos = new_pos
        #_on_enter_cell(new_pos) # si tu as déjà une logique de POI / combat ici
    _check_enter_poi()

func _check_enter_poi() -> void:
    if event_open:
        return

    var cell_type := _get_current_cell_type()

    var event_id: String = GameEnums.CELL_ENUM[cell_type].event_id
    if event_id:
        _start_world_event(event_id)

func _start_world_event(event_id: String) -> void:
    var evt := WorldEventFactory.get_event(event_id)
    if evt == null:
        return

    event_open = true
    is_moving = false
    current_event = evt

    # instancier le handler si présent
    current_event_handler = null
    if evt.logic_script != null:
        var obj :Variant = evt.logic_script.new()
        if obj is WorldEventHandler:
            current_event_handler = obj
        else:
            push_warning("World event %s: logic_script n'étend pas WorldEventHandler" % evt.id)

    # convertir les choices en format compris par EventPanel
    var ui_choices: Array[Dictionary] = []
    for c in evt.choices:
        if c == null:
            continue
        ui_choices.append({
            "text": c.text,
            "choice_id": c.choice_id
        })

    event_panel.show_event(evt.title, evt.body, ui_choices)

func _on_event_choice_made(choice_id: String) -> void:
       event_open = false

       if current_event_handler != null:
              current_event_handler.execute_choice(choice_id, self)

       # On peut remettre current_event à null si on veut
       current_event = null
       current_event_handler = null

func _process_auto_move() -> void: 
    if move_queue.is_empty():
        is_auto_moving = false
        return

    var step: Vector2i = move_queue[0]

    # On essaie de bouger d'une case
    _try_move_army(step)

    # On enlève ce mouvement de la file
    move_queue.remove_at(0)

    # Si le mouvement a été bloqué (par les bords / futur obstacles),
    # army_grid_pos sera restée la même, mais on ne s'en occupe pas encore ici.
    if move_queue.is_empty():
        is_auto_moving = false   
func _update_rest_timer(delta: float) -> void:
    WorldState.rest_seconds_remaining -= delta

    if WorldState.rest_seconds_remaining <= 0.0:
        _finish_rest()  
            
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

func _start_auto_move_to(target_grid: Vector2i) -> void:
    move_queue.clear()
    is_auto_moving = false

    var start := army_grid_pos
    var end := target_grid

    var dx :int = abs(end.x - start.x)
    var dy :int = abs(end.y - start.y)
    var sx := 1 if start.x < end.x else -1
    var sy := 1 if start.y < end.y else -1

    var err := dx - dy
    var current := start

    while current != end:
        var e2 := err * 2

        if e2 > -dy:
            err -= dy
            current.x += sx
            move_queue.append(Vector2i(sx, 0))  # on avance d'une case en X

        if current == end:
            break

        if e2 < dx:
            err += dx
            current.y += sy
            move_queue.append(Vector2i(0, sy))  # on avance d'une case en Y

    if move_queue.size() > 0:
        is_auto_moving = true
        print("Chemin (ligne) généré, longueur:", move_queue.size())





func _update_date_ui() -> void:
    if date_label:
        date_label.text = WorldState.get_formatted_date()
        
func _init_world_grid() -> void:
 world_grid.clear()

 for y in GRID_HEIGHT:
  var row: Array[CellType] = []
  for x in GRID_WIDTH:
   row.append(CellType.PLAINE)
  world_grid.append(row)

 world_grid[5][5] = CellType.TOWN
 world_grid[6][8] = CellType.RUINS
 world_grid[4][10] = CellType.FOREST_SHRINE
 world_grid[7][7] = CellType.WATER
 world_grid[7][8] = CellType.WATER
 world_grid[7][9] = CellType.WATER
 world_grid[7][10] = CellType.WATER

func _draw() -> void:
 # armée (cercle rouge)
 var pos = grid_to_world(army_grid_pos)
 draw_circle(pos, 8.0, Color(1, 0, 0))

 # POI
 for y in GRID_HEIGHT:
  for x in GRID_WIDTH:
   var cell: CellType = world_grid[y][x]
   var cell_pos = grid_to_world(Vector2i(x, y))
   draw_circle(cell_pos, 10.0, GameEnums.CELL_ENUM[cell].color)

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
    if WorldState.resting && event != null:
        print("Impossible d'agir : repos en cours.")
        return
    if WorldState.resting:
        return
    if event_open:
          # On ignore les déplacements tant qu'une fenêtre d'événement est ouverte
          return
    # Clic gauche sur la carte
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        _on_world_click(event.position)
        return

    # Si on a une file de mouvements en cours, on ignore les touches pour l'instant (optionnel)
    if is_auto_moving:
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
            
func _on_world_click(screen_pos: Vector2) -> void:
    var world_pos: Vector2 = get_global_mouse_position()

    move_target = world_pos

    # On regarde le type de cell de la case cible
    var target_grid := Vector2i(
        int(floor(world_pos.x / TILE_SIZE)),
        int(floor(world_pos.y / TILE_SIZE))
    )

    if target_grid.x < 0 or target_grid.x >= GRID_WIDTH:
        return
    if target_grid.y < 0 or target_grid.y >= GRID_HEIGHT:
        return

    var target_cell_type :CellType = world_grid[target_grid.y][target_grid.x]
    if not GameEnums.CELL_ENUM[target_cell_type].walkable:
        print("Cible sur une case non franchissable, on refuse le déplacement.")
        return

    is_moving = true
    print("Nouvelle destination :", move_target, " grid=", target_grid)


func _try_move_army(delta_grid: Vector2i) -> void:
    if WorldState.resting:
        return

    var new_pos := army_grid_pos + delta_grid

    # 1) limites de la carte
    if new_pos.x < 0 or new_pos.x >= GRID_WIDTH:
        return
    if new_pos.y < 0 or new_pos.y >= GRID_HEIGHT:
        return

    # 2) récupérer le biome de la case d'arrivée
    var cell_type :GameEnums.CellType = world_grid[new_pos.y][new_pos.x]
    var move_cost : float = GameEnums.CELL_ENUM[cell_type].move_cost

    if WorldState.MOVE_COST.has(cell_type):
        move_cost = WorldState.MOVE_COST[cell_type]

    # 3) Avancer le temps
    print("Déplacement → coût : ", move_cost, " secondes")
    WorldState.advance_time(move_cost)

    # 4) Déplacer l’armée
    army_grid_pos = new_pos
    _update_army_world_position()
    _update_camera()

func _change_zoom(delta: float) -> void:
 zoom_level = clamp(zoom_level + delta, 0.5, 2.5)
 if camera:
  camera.zoom = Vector2(zoom_level, zoom_level)
  _clamp_camera_to_world()

func start_rest() -> void:
    if WorldState.resting:
        return
    move_queue.clear()
    is_auto_moving = false

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
        return CellType.PLAINE
    if army_grid_pos.x < 0 or army_grid_pos.x >= GRID_WIDTH:
        return CellType.PLAINE
    return world_grid[army_grid_pos.y][army_grid_pos.x]

func change_scene(path: String) -> void:
    get_tree().change_scene_to_file(path)
    
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
        var unit := army.get_unit_at_index(i)
        if unit == null:
            continue
        if unit.hp <= 0:
            continue  # unité morte : pas de miracle ici pour l'instant

        # Soin des PV : on rend une fraction des PV manquants
        var missing_hp := unit.max_hp - unit.hp
        if missing_hp > 0:
            var heal_hp := int(unit.max_hp * heal_ratio_hp)
            if heal_hp < 1 and missing_hp > 0:
                heal_hp = 1  # au moins 1 PV si il manque quelque chose
            unit.hp = clamp(unit.hp + heal_hp, 0, unit.max_hp)
            print(unit.name, " soigne ", heal_hp, " ses pv sont maintenant de ", unit.hp,"/",unit.max_hp)

        # Soin du moral : idem
        var missing_morale := unit.max_morale - unit.morale
        if missing_morale > 0:
            var heal_morale := int(missing_morale * heal_ratio_morale)
            if heal_morale < 1 and missing_morale > 0:
                heal_morale = 1
            unit.morale = clamp(unit.morale + heal_morale, 0, unit.max_morale)
