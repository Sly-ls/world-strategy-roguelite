## WorldMapController.gd - VERSION FINALE OPTIMALE
## Contrôleur principal de la carte du monde
## 
## ARCHITECTURE:
## - Position de TOUTES les armées dans ArmyData.runtime_position
## - EntityPositionService = INDEX SPATIAL pour recherche rapide
##
extends Node2D

## ===== CONSTANTES =====
var world_grid: Array = []

## ===== SERVICES =====
var movement_controller: MovementController
var camera_controller: CameraController
var entity_position_service: EntityPositionService

## ===== RÉFÉRENCES DE SCÈNE =====
@onready var background: Sprite2D = $Background
@onready var camera: Camera2D = $Camera2D
@onready var army_marker: Node2D = $ArmyMarker

## UI
@onready var date_label: Label = $UI_Layer/DateLabel
@onready var rest_label: Label = $UI_Layer/RestLabel
@onready var event_panel: EventPanel = $UI_Layer/EventPanel

## ===== ÉTAT DU MOUVEMENT =====
var is_moving: bool = false
var move_target: Vector2 = Vector2.ZERO

## ===== ÉTAT DES ÉVÉNEMENTS =====
var event_open: bool = false
var current_event: WorldEvent = null
var current_event_handler: WorldEventHandler = null

## ===== INITIALISATION =====

func _ready() -> void:
    _init_grid_dimensions()
    _init_services()
    _init_world_grid()
    _init_ui()
    _init_journal()
    _init_player_army()
    _init_enemies()
    _init_quests()

func _init_grid_dimensions() -> void:
    var tex := background.texture
    WorldConstants.GRID_WIDTH = int(tex.get_width() / WorldConstants.TILE_SIZE)
    WorldConstants.GRID_HEIGHT = int(tex.get_height() / WorldConstants.TILE_SIZE)
    print("[WorldMap] Dimensions: %dx%d" % [WorldConstants.GRID_WIDTH, WorldConstants.GRID_HEIGHT])

func _init_services() -> void:
    # MovementController
    movement_controller = MovementController.new()
    movement_controller.movement_completed.connect(_on_movement_completed)
    movement_controller.movement_blocked.connect(_on_movement_blocked)
    movement_controller.movement_step.connect(_on_movement_step)
    
    # CameraController
    camera_controller = CameraController.new()
    var world_bounds = Rect2(0, 0, WorldConstants.GRID_WIDTH * WorldConstants.TILE_SIZE, WorldConstants.GRID_HEIGHT * WorldConstants.TILE_SIZE)
    camera_controller.initialize(camera, world_bounds)
    camera_controller.set_zoom_limits(0.3, 2.0)
    camera_controller.set_follow_speed(5.0)
    
    # EntityPositionService (INDEX SPATIAL)
    entity_position_service = EntityPositionService.new()
    entity_position_service.entities_at_same_position.connect(_on_entities_collision)
    
    print("[WorldMap] Services initialisés")

func _init_world_grid() -> void:
    world_grid.clear()
    
    for y in WorldConstants.GRID_HEIGHT:
        var row: Array[GameEnums.CellType] = []
        for x in WorldConstants.GRID_WIDTH:
            row.append(GameEnums.CellType.PLAINE)
        world_grid.append(row)
    
    # POIs
    world_grid[5][5] = GameEnums.CellType.TOWN
    world_grid[6][8] = GameEnums.CellType.RUINS
    world_grid[4][10] = GameEnums.CellType.FOREST_SHRINE
    world_grid[7][7] = GameEnums.CellType.WATER
    world_grid[7][8] = GameEnums.CellType.WATER
    world_grid[7][9] = GameEnums.CellType.WATER
    world_grid[7][10] = GameEnums.CellType.WATER
    
    # Passe la grille aux services
    movement_controller.initialize(world_grid, WorldConstants.GRID_WIDTH, WorldConstants.GRID_HEIGHT)
    entity_position_service.initialize(world_grid, WorldConstants.GRID_WIDTH, WorldConstants.GRID_HEIGHT)
    
    print("[WorldMap] Grille initialisée")

func _init_ui() -> void:
    if event_panel:
        event_panel.choice_made.connect(_on_event_choice_made)
    
    if rest_label:
        rest_label.visible = false
    
    _update_date_ui()

func _init_journal() -> void:
    var journal_scene := preload("res://scenes/QuestJournalAdvancedUI.tscn")
    var journal := journal_scene.instantiate()
    
    var canvas_layer := CanvasLayer.new()
    canvas_layer.layer = 100
    add_child(canvas_layer)
    canvas_layer.add_child(journal)
    
    journal.hide()
    print("[WorldMap] Journal initialisé")

func _init_player_army() -> void:
    """Initialise l'armée du joueur"""
    
    # Si WorldState.player_army n'existe pas, crée-le avec ArmyFactory
    if not WorldState.player_army:
        WorldState.player_army = ArmyFactory.create_player_army("starter")
    
    # Position initiale
    var start_pos = WorldState.army_grid_pos
    if start_pos == Vector2i.ZERO or start_pos == Vector2i(-1, -1):
        start_pos = Vector2i(10, 10)
    
    # Position dans ArmyData
    WorldState.player_army.set_position(start_pos)
    WorldState.army_grid_pos = start_pos  # Sync
    
    # Enregistre dans le service
    entity_position_service.register_entity(
        "player",
        "player_army",
        WorldState.player_army
    )
    
    _update_army_marker_position()
    
    var player_world_pos = _grid_to_world(start_pos)
    camera_controller.center_on(player_world_pos)
    
    print("[WorldMap] Joueur initialisé à %s" % start_pos)

func _init_enemies() -> void:
    """Initialise les armées ennemies"""
    
    # Exemple 1 : Ennemis fixes (comme avant)
    var orc_army = ArmyFactory.create_enemy_army("orc_patrol")
    orc_army.set_position(Vector2i(15, 12))
    entity_position_service.register_entity("orc_patrol_1", "enemy_army", orc_army)
    
    var bandit_army = ArmyFactory.create_enemy_army("bandit_group")
    bandit_army.set_position(Vector2i(8, 20))
    entity_position_service.register_entity("bandit_group_1", "enemy_army", bandit_army)
    
    # ⭐ Exemple 2 : Génération aléatoire par difficulté
    var random_enemy = ArmyFactory.create_random_enemy(2)  # Difficulté moyenne
    random_enemy.set_position(Vector2i(20, 15))
    entity_position_service.register_entity("random_encounter_1", "enemy_army", random_enemy)
    
    # ⭐ Exemple 3 : Patrouilles procédurales par faction
    var undead_patrol = ArmyFactory.create_procedural_patrol("undead", 3)
    undead_patrol.set_position(Vector2i(12, 25))
    entity_position_service.register_entity("undead_patrol_1", "enemy_army", undead_patrol)
    
    # Garde les références pour l'IA
    WorldState.enemy_armies["orc_patrol_1"] = orc_army
    WorldState.enemy_armies["bandit_group_1"] = bandit_army
    WorldState.enemy_armies["random_encounter_1"] = random_enemy
    WorldState.enemy_armies["undead_patrol_1"] = undead_patrol
    
    print("[WorldMap] %d ennemis initialisés" % entity_position_service.get_entity_count_by_type("enemy_army"))

func _init_quests() -> void:
    if QuestManager.get_active_quests().is_empty():
        _start_initial_quests()

func spawn_faction_patrols(faction: String, count: int) -> void:
    """
    Spawn plusieurs patrouilles d'une faction
    
    Args:
        faction: "orc", "bandit", "undead", "goblin"
        count: Nombre de patrouilles
    """
    for i in range(count):
        var strength = randi_range(2, 5)
        var patrol = ArmyFactory.create_procedural_patrol(faction, strength)
        
        # Position aléatoire sur la carte
        var pos = Vector2i(
            randi_range(0, WorldConstants.GRID_WIDTH - 1),
            randi_range(0, WorldConstants.GRID_HEIGHT - 1)
        )
        
        patrol.set_position(pos)
        
        var patrol_id = "%s_patrol_%d" % [faction, i]
        entity_position_service.register_entity(patrol_id, "enemy_army", patrol)
        
        WorldState.enemy_armies[patrol_id] = patrol
    
    print("[WorldMap] %d patrouilles %s générées" % [count, faction])

## ===== PROCESS =====

func _process(delta: float) -> void:
    WorldState.advance_time(delta)
    _update_date_ui()
    
    if WorldState.resting:
        _update_rest_timer(delta)
        return
    
    if is_moving:
        _update_army_movement(delta)
    
    if camera_controller:
        var player_pos = WorldState.player_army.get_position()
        var player_world_pos = _grid_to_world(player_pos)
        camera_controller.set_target_position(player_world_pos)
        camera_controller.update_camera(delta)
    
    _update_enemy_ai(delta)

## ===== MOUVEMENT JOUEUR =====

func _update_army_movement(delta: float) -> void:
    if not movement_controller.get_is_moving():
        return
    
    var new_world_pos = movement_controller.update_movement(delta)
    
    if army_marker:
        army_marker.position = new_world_pos

func _on_movement_completed(final_grid_pos: Vector2i) -> void:
    print("[WorldMap] Mouvement terminé à %s" % final_grid_pos)
    
    is_moving = false
    
    # ✅ Met à jour position dans ArmyData
    var old_pos = WorldState.player_army.get_position()
    WorldState.player_army.set_position(final_grid_pos)
    WorldState.army_grid_pos = final_grid_pos
    
    # ✅ Synchronise l'index spatial
    entity_position_service.update_entity_position("player", old_pos)
    
    _check_enter_poi(final_grid_pos)

func _on_movement_blocked(pos: Vector2i, reason: String) -> void:
    print("[WorldMap] Mouvement bloqué à %s: %s" % [pos, reason])
    is_moving = false

func _on_movement_step(current_world_pos: Vector2) -> void:
    var grid_pos = movement_controller.world_to_grid(current_world_pos)
    WorldState.army_grid_pos = grid_pos

## ===== COLLISION / RENCONTRE =====

func _on_entities_collision(entity_ids: Array[String], pos: Vector2i) -> void:
    """Signal du service quand plusieurs entités à même position"""
    print("[WorldMap] Collision détectée: %s à %s" % [entity_ids, pos])
    
    # Vérifie si le joueur est impliqué
    if "player" not in entity_ids:
        return
    
    # Trouve l'autre entité
    for entity_id in entity_ids:
        if entity_id == "player":
            continue
        
        var entity_type = entity_position_service.get_entity_type(entity_id)
        
        match entity_type:
            "enemy_army":
                _trigger_combat_with_entity(entity_id)
            "npc":
                _trigger_npc_dialogue(entity_id)
            "caravan":
                _trigger_caravan_interaction(entity_id)

## ===== ENTRÉE DANS UNE CELLULE =====

func _check_enter_poi(cell_pos: Vector2i) -> void:
    if event_open:
        return
    
    var cell_type = _get_cell_type(cell_pos)
    
    print("[WorldMap] Entrée dans cellule %s (type: %d)" % [cell_pos, cell_type])
    
    _check_reach_poi_quests(cell_type)
    
    var event_id: String = GameEnums.CELL_ENUM[cell_type].event_id
    if event_id:
        _start_world_event(event_id)
    
    var quest = QuestGenerator.generate_advanced_quest_for_poi(cell_pos, cell_type)

## ===== IA ENNEMIS =====

var enemy_ai_timer: float = 0.0
const ENEMY_AI_UPDATE_INTERVAL: float = 1.0

func _update_enemy_ai(delta: float) -> void:
    """Met à jour l'IA de tous les ennemis"""
    enemy_ai_timer += delta
    
    if enemy_ai_timer < ENEMY_AI_UPDATE_INTERVAL:
        return
    
    enemy_ai_timer = 0.0
    
    var player_pos = WorldState.player_army.get_position()
    var enemies = entity_position_service.get_entities_by_type("enemy_army")
    
    for enemy_id in enemies:
        _update_enemy_patrol(enemy_id, player_pos)

func _update_enemy_patrol(enemy_id: String, player_pos: Vector2i) -> void:
    """IA simple: poursuite ou patrouille"""
    var enemy_army = entity_position_service.get_entity_data(enemy_id)
    var enemy_pos = enemy_army.get_position()  # ✅ Lit depuis ArmyData
    var distance = _calculate_distance(player_pos, enemy_pos)
    
    # Poursuite si proche
    if distance <= 10:
        var direction = _get_direction_towards(enemy_pos, player_pos)
        var new_pos = enemy_pos + direction
        
        # Tente de se déplacer
        if _is_valid_move(new_pos):
            var old_pos = enemy_pos
            enemy_army.set_position(new_pos)  # ✅ Met à jour ArmyData
            entity_position_service.update_entity_position(enemy_id, old_pos)  # ✅ Synchronise index
    else:
        # Patrouille aléatoire
        if randf() < 0.3:
            var random_dir = [
                Vector2i(1, 0), Vector2i(-1, 0),
                Vector2i(0, 1), Vector2i(0, -1)
            ].pick_random()
            var new_pos = enemy_pos + random_dir
            
            if _is_valid_move(new_pos):
                var old_pos = enemy_pos
                enemy_army.set_position(new_pos)
                entity_position_service.update_entity_position(enemy_id, old_pos)

func _is_valid_move(pos: Vector2i) -> bool:
    """Vérifie si une position est valide pour mouvement"""
    if pos.x < 0 or pos.x >= WorldConstants.GRID_WIDTH or pos.y < 0 or pos.y >= WorldConstants.GRID_HEIGHT:
        return false
    
    var cell_type = world_grid[pos.y][pos.x]
    return GameEnums.CELL_ENUM[cell_type].walkable

func _get_direction_towards(from: Vector2i, to: Vector2i) -> Vector2i:
    """Direction unitaire vers la cible"""
    var diff = to - from
    
    if abs(diff.x) > abs(diff.y):
        return Vector2i(sign(diff.x), 0)
    else:
        return Vector2i(0, sign(diff.y))

## ===== COMBAT =====

func _trigger_combat_with_entity(entity_id: String) -> void:
    """Déclenche combat avec une entité"""
    var enemy_army = entity_position_service.get_entity_data(entity_id)
    
    if not enemy_army is ArmyData:
        print("[WorldMap] ERROR: %s n'est pas une armée" % entity_id)
        return
    
    print("[WorldMap] Combat: joueur vs %s" % entity_id)
    
    WorldState.enemy_army = enemy_army
    WorldState.current_enemy_id = entity_id
    
    get_tree().change_scene_to_file("res://scenes/combat/combat_scene.tscn")

func _on_combat_return() -> void:
    """Appelé au retour du combat"""
    if WorldState.last_battle_result == "victory":
        if WorldState.current_enemy_id != "":
            var enemy_id = WorldState.current_enemy_id
            entity_position_service.unregister_entity(enemy_id)
            WorldState.enemy_armies.erase(enemy_id)
            WorldState.current_enemy_id = ""  # Reset
            
            print("[WorldMap] Ennemi %s vaincu et supprimé" % enemy_id)
    
    _check_battle_result()

func _trigger_npc_dialogue(entity_id: String) -> void:
    print("[WorldMap] Dialogue avec %s" % entity_id)
    # TODO: Système de dialogue

func _trigger_caravan_interaction(entity_id: String) -> void:
    print("[WorldMap] Commerce avec %s" % entity_id)
    # TODO: Système de commerce

## ===== ÉVÉNEMENTS MONDIAUX =====

func _start_world_event(event_id: String) -> void:
    var evt := WorldEventFactory.get_event(event_id)
    if evt == null:
        return
    
    event_open = true
    is_moving = false
    current_event = evt
    
    # Instancier le handler si présent (RefCounted, PAS Node)
    current_event_handler = null
    if evt.logic_script != null:
        var obj: Variant = evt.logic_script.new()
        if obj is WorldEventHandler:
            current_event_handler = obj
        else:
            push_warning("World event %s: logic_script doesn't extend WorldEventHandler" % evt.id)
    
        var ui_choices: Array[Dictionary] = []
        for c in evt.choices:
            if c == null:
                continue
            ui_choices.append({
            "text": c.text,
            "choice_id": c.choice_id
            })

        event_panel.show_event(evt.title, evt.body, ui_choices)

func _on_event_choice_made(choice_idx: int) -> void:
    if current_event == null:
        return
    
    event_open = false
    
    # Récupérer le choice_id depuis l'événement
    var choice_id: String = ""
    if current_event.has("choices") and choice_idx < current_event.choices.size():
        var choice = current_event.choices[choice_idx]
        if choice.has("choice_id"):
            choice_id = choice.choice_id
        elif choice.has("id"):
            choice_id = choice.id
        else:
            choice_id = str(choice_idx)
    
    print("[WorldMap] Choix %d (%s) sélectionné" % [choice_idx, choice_id])
    
    if current_event_handler:
        current_event_handler.execute_choice(choice_id, self)
    
    # Nettoyer
    current_event = null
    current_event_handler = null
    
    if event_panel:
        event_panel.hide()

func _close_event() -> void:
    event_open = false
    current_event = null
    current_event_handler = null  # RefCounted auto-libéré
    
    if event_panel:
        event_panel.hide()

## ===== QUÊTES =====

func _start_initial_quests() -> void:
    QuestManager.start_quest("survival_5days")
    
    var player_pos = WorldState.player_army.get_position()
    var nearby_ruins = _find_nearby_poi(GameEnums.CellType.RUINS, 10)
    if nearby_ruins != Vector2i(-1, -1):
        QuestManager.start_quest("ruins_artifact_1", {"poi_pos": nearby_ruins})

func _check_reach_poi_quests(cell_type: int) -> void:
    match cell_type:
        GameEnums.CellType.RUINS:
            QuestManager.update_quest_progress("ruins_artifact_1", 1)
        GameEnums.CellType.TOWN:
            QuestManager.update_quest_progress("reach_town", 1)
        GameEnums.CellType.FOREST_SHRINE:
            QuestManager.update_quest_progress("find_shrine", 1)

func _check_battle_result() -> void:
    if WorldState.last_battle_result == "victory":
        var cell_type = _get_cell_type(WorldState.player_army.get_position())
        
        if cell_type == GameEnums.CellType.RUINS:
            QuestManager.update_quest_progress("ruins_artifact_1", 1)

## ===== REPOS =====

func start_rest() -> void:
    if WorldState.resting:
        return
    
    is_moving = false
    movement_controller.stop_movement()
    
    WorldState.resting = true
    WorldState.rest_seconds_remaining = WorldState.REST_DURATION_SECONDS
    
    if rest_label:
        rest_label.visible = true
    
    print("[WorldMap] Repos commencé")

func _update_rest_timer(delta: float) -> void:
    WorldState.rest_seconds_remaining -= delta
    
    if rest_label:
        rest_label.text = "Repos: %.1fs" % WorldState.rest_seconds_remaining
    
    if WorldState.rest_seconds_remaining <= 0:
        _finish_rest()

func _finish_rest() -> void:
    WorldState.resting = false
    
    if rest_label:
        rest_label.visible = false
    
    # ✅ Délègue à ArmyData (pas de duplication)
    var cell_type = _get_cell_type(WorldState.player_army.get_position())
    WorldState.player_army.rest(cell_type)
    
    print("[WorldMap] Repos terminé")

## ===== INPUT =====

func _unhandled_input(event: InputEvent) -> void:
    if WorldState.resting or event_open:
        return
    
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        _on_world_click(event.position)
        return
    
    if event.is_action_pressed("move_up"):
        _try_move_army(Vector2i(0, -1))
    elif event.is_action_pressed("move_down"):
        _try_move_army(Vector2i(0, 1))
    elif event.is_action_pressed("move_left"):
        _try_move_army(Vector2i(-1, 0))
    elif event.is_action_pressed("move_right"):
        _try_move_army(Vector2i(1, 0))
    
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            camera_controller.adjust_zoom(0.1)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            camera_controller.adjust_zoom(-0.1)

func _on_world_click(screen_pos: Vector2) -> void:
    var world_pos: Vector2 = get_global_mouse_position()
    
    var target_grid := Vector2i(
        int(floor(world_pos.x / WorldConstants.TILE_SIZE)),
        int(floor(world_pos.y / WorldConstants.TILE_SIZE))
    )
    
    if target_grid.x < 0 or target_grid.x >= WorldConstants.GRID_WIDTH:
        return
    if target_grid.y < 0 or target_grid.y >= WorldConstants.GRID_HEIGHT:
        return
    
    var target_cell_type = world_grid[target_grid.y][target_grid.x]
    if not GameEnums.CELL_ENUM[target_cell_type].walkable:
        print("[WorldMap] Cible non praticable")
        return
    
    var current_pos = WorldState.player_army.get_position()
    var speed = WorldState.player_army.BASE_SPEED_PX
    
    if movement_controller.start_movement(current_pos, target_grid, speed):
        is_moving = true
        move_target = world_pos
        print("[WorldMap] Mouvement vers %s" % target_grid)

func _try_move_army(delta_grid: Vector2i) -> void:
    var current_pos = WorldState.player_army.get_position()
    var new_pos = current_pos + delta_grid
    
    if new_pos.x < 0 or new_pos.x >= WorldConstants.GRID_WIDTH:
        return
    if new_pos.y < 0 or new_pos.y >= WorldConstants.GRID_HEIGHT:
        return
    
    var cell_type = world_grid[new_pos.y][new_pos.x]
    if not GameEnums.CELL_ENUM[cell_type].walkable:
        return
    
    var move_cost = GameEnums.CELL_ENUM[cell_type].move_cost
    WorldState.advance_time(move_cost)
    
    # ✅ Met à jour position dans ArmyData
    var old_pos = current_pos
    WorldState.player_army.set_position(new_pos)
    WorldState.army_grid_pos = new_pos
    
    # ✅ Synchronise l'index
    entity_position_service.update_entity_position("player", old_pos)
    
    _update_army_marker_position()
    _check_enter_poi(new_pos)

## ===== UI ET AFFICHAGE =====

func _update_date_ui() -> void:
    if date_label:
        date_label.text = WorldState.get_formatted_date()

func _update_army_marker_position() -> void:
    if army_marker:
        var player_pos = WorldState.player_army.get_position()
        army_marker.position = _grid_to_world(player_pos)
    queue_redraw()

func _draw() -> void:
    # Joueur (rouge)
    var player_pos = WorldState.player_army.get_position()
    var pos = _grid_to_world(player_pos)
    draw_circle(pos, 8.0, Color(1, 0, 0))
    
    # POIs
    for y in WorldConstants.GRID_HEIGHT:
        for x in WorldConstants.GRID_WIDTH:
            var cell: GameEnums.CellType = world_grid[y][x]
            var cell_pos = _grid_to_world(Vector2i(x, y))
            draw_circle(cell_pos, 10.0, GameEnums.CELL_ENUM[cell].color)
    
    # Ennemis (orange)
    var enemies = entity_position_service.get_entities_by_type("enemy_army")
    for enemy_id in enemies:
        var enemy_army = entity_position_service.get_entity_data(enemy_id)
        var enemy_pos = enemy_army.get_position()  # ✅ Lit depuis ArmyData
        var world_pos = _grid_to_world(enemy_pos)
        draw_circle(world_pos, 8.0, Color(1, 0.5, 0))

## ===== UTILITAIRES =====

func _grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(
        float(grid_pos.x) * WorldConstants.TILE_SIZE + WorldConstants.TILE_SIZE * 0.5,
        float(grid_pos.y) * WorldConstants.TILE_SIZE + WorldConstants.TILE_SIZE * 0.5
    )

func _calculate_distance(from: Vector2i, to: Vector2i) -> float:
    return abs(to.x - from.x) + abs(to.y - from.y)

func _find_nearby_poi(poi_type: GameEnums.CellType, max_distance: int) -> Vector2i:
    var player_pos = WorldState.player_army.get_position()
    var closest_poi := Vector2i(-1, -1)
    var min_distance := 999999.0
    
    for y in range(max(0, player_pos.y - max_distance), min(WorldConstants.GRID_HEIGHT, player_pos.y + max_distance + 1)):
        for x in range(max(0, player_pos.x - max_distance), min(WorldConstants.GRID_WIDTH, player_pos.x + max_distance + 1)):
            if world_grid[y][x] == poi_type:
                var poi_pos := Vector2i(x, y)
                var distance := _calculate_distance(player_pos, poi_pos)
                
                if distance <= max_distance and distance < min_distance:
                    min_distance = distance
                    closest_poi = poi_pos
    
    return closest_poi

func _get_cell_type(pos: Vector2i) -> int:
    if pos.x < 0 or pos.x >= WorldConstants.GRID_WIDTH or pos.y < 0 or pos.y >= WorldConstants.GRID_HEIGHT:
        return GameEnums.CellType.PLAINE
    return world_grid[pos.y][pos.x]

func change_scene(path: String) -> void:
    get_tree().change_scene_to_file(path)

## ===== CALLBACKS UI =====

func _on_rest_button_pressed() -> void:
    start_rest()

## ===== DEBUG =====

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_page_down"):
        var player_pos = WorldState.player_army.get_position()
        entity_position_service.debug_print_entities_near(player_pos, 10)
    
    if event.is_action_pressed("ui_page_up"):
        entity_position_service.debug_print_stats()
    
    if event.is_action_pressed("ui_home"):
        entity_position_service.debug_validate_consistency()
