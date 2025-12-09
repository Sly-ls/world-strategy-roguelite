## MovementController.gd
## Service responsable de la gestion des mouvements sur la carte
class_name MovementController
extends RefCounted

## Signaux pour communiquer les événements de mouvement
signal movement_started(from_pos: Vector2i, to_pos: Vector2i)
signal movement_step(current_pos: Vector2)
signal movement_completed(final_pos: Vector2i)
signal movement_blocked(pos: Vector2i, reason: String)

## Référence à la grille du monde
var world_grid: Array = []
var grid_width: int = 0
var grid_height: int = 0

## État du mouvement en cours
var is_moving: bool = false
var current_path: Array[Vector2i] = []
var current_step: int = 0
var movement_progress: float = 0.0
var current_world_pos: Vector2 = Vector2.ZERO
var target_world_pos: Vector2 = Vector2.ZERO

## Configuration
var movement_speed: float = 200.0  # pixels par seconde
var step_distance: float = 64.0     # distance d'une case en pixels

## Initialise le contrôleur avec la grille du monde
func initialize(p_world_grid: Array, p_grid_width: int, p_grid_height: int) -> void:
    world_grid = p_world_grid
    grid_width = p_grid_width
    grid_height = p_grid_height
    print("[MovementController] Initialisé avec grille %dx%d" % [grid_width, grid_height])

## Démarre un mouvement de from_pos vers to_pos
func start_movement(from_pos: Vector2i, to_pos: Vector2i, speed: float = 200.0) -> bool:
    if is_moving:
        print("[MovementController] Mouvement déjà en cours")
        return false
    
    # Vérifie que la position de départ et d'arrivée sont valides
    if not is_valid_grid_position(from_pos) or not is_valid_grid_position(to_pos):
        movement_blocked.emit(to_pos, "Position invalide")
        return false
    
    # Calcule le chemin
    current_path = calculate_path(from_pos, to_pos)
    
    if current_path.is_empty():
        movement_blocked.emit(to_pos, "Aucun chemin trouvé")
        return false
    
    # Initialise le mouvement
    is_moving = true
    current_step = 0
    movement_progress = 0.0
    movement_speed = speed
    current_world_pos = grid_to_world(from_pos)
    target_world_pos = grid_to_world(current_path[0])
    
    movement_started.emit(from_pos, to_pos)
    print("[MovementController] Démarrage mouvement: %s -> %s (%d étapes)" % [from_pos, to_pos, current_path.size()])
    
    return true

## Met à jour le mouvement (à appeler dans _process)
func update_movement(delta: float) -> Vector2:
    if not is_moving:
        return current_world_pos
    
    # Calcule la distance à parcourir ce frame
    var distance_this_frame = movement_speed * delta
    movement_progress += distance_this_frame
    
    # Interpole la position
    var direction = (target_world_pos - current_world_pos).normalized()
    var new_pos = current_world_pos + direction * distance_this_frame
    
    # Vérifie si on a atteint l'étape actuelle
    if movement_progress >= step_distance:
        # Passe à l'étape suivante
        current_step += 1
        movement_progress = 0.0
        current_world_pos = target_world_pos
        
        movement_step.emit(current_world_pos)
        
        # Vérifie si le mouvement est terminé
        if current_step >= current_path.size():
            is_moving = false
            var final_grid_pos = current_path[current_path.size() - 1]
            movement_completed.emit(final_grid_pos)
            print("[MovementController] Mouvement terminé à %s" % final_grid_pos)
        else:
            # Prépare la prochaine étape
            target_world_pos = grid_to_world(current_path[current_step])
    else:
        current_world_pos = new_pos
    
    return current_world_pos

## Arrête le mouvement en cours
func stop_movement() -> void:
    if is_moving:
        is_moving = false
        var final_pos = world_to_grid(current_world_pos)
        movement_completed.emit(final_pos)
        print("[MovementController] Mouvement interrompu à %s" % final_pos)

## Calcule un chemin entre deux positions (simple ligne droite pour l'instant)
func calculate_path(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
    var path: Array[Vector2i] = []
    
    # Pour l'instant, on utilise un chemin en ligne droite (Manhattan)
    # Tu peux remplacer par A* plus tard si nécessaire
    var current = from
    
    while current != to:
        # Déplacement horizontal d'abord
        if current.x < to.x:
            current.x += 1
        elif current.x > to.x:
            current.x -= 1
        # Puis vertical
        elif current.y < to.y:
            current.y += 1
        elif current.y > to.y:
            current.y -= 1
        
        # Vérifie que la case est praticable
        if is_walkable(current):
            path.append(current)
        else:
            print("[MovementController] Obstacle détecté à %s" % current)
            return []  # Chemin bloqué
    
    return path

## Vérifie si une position de grille est valide
func is_valid_grid_position(pos: Vector2i) -> bool:
    return pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height

## Vérifie si une case est praticable
func is_walkable(pos: Vector2i) -> bool:
    if not is_valid_grid_position(pos):
        return false
    
    # Vérifie le terrain dans la grille
    var tile_data = world_grid[pos.y][pos.x]
    if tile_data.has("terrain_type"):
        var terrain = tile_data["terrain_type"]
        # Les montagnes et l'eau ne sont pas praticables
        if terrain == GameEnums.CellType.MONTAGNE or terrain == GameEnums.CellType.WATER:
            return false
    
    return true

## Calcule la distance Manhattan entre deux positions
func calculate_distance(from: Vector2i, to: Vector2i) -> float:
    return abs(to.x - from.x) + abs(to.y - from.y)

## Trouve le POI le plus proche d'un certain type
func find_nearest_poi(from_pos: Vector2i, poi_type: int, max_distance: int = 999) -> Vector2i:
    var nearest_pos = Vector2i(-1, -1)
    var nearest_distance = max_distance + 1
    
    # Parcourt la grille pour trouver les POIs
    for y in range(grid_height):
        for x in range(grid_width):
            var tile_data = world_grid[y][x]
            if tile_data.has("poi_type") and tile_data["poi_type"] == poi_type:
                var distance = calculate_distance(from_pos, Vector2i(x, y))
                if distance < nearest_distance:
                    nearest_distance = distance
                    nearest_pos = Vector2i(x, y)
    
    if nearest_pos.x == -1:
        print("[MovementController] Aucun POI de type %d trouvé" % poi_type)
    
    return nearest_pos

## Trouve tous les POIs dans un rayon donné
func find_pois_in_radius(from_pos: Vector2i, radius: int) -> Array[Dictionary]:
    var pois: Array[Dictionary] = []
    
    for y in range(max(0, from_pos.y - radius), min(grid_height, from_pos.y + radius + 1)):
        for x in range(max(0, from_pos.x - radius), min(grid_width, from_pos.x + radius + 1)):
            var pos = Vector2i(x, y)
            var distance = calculate_distance(from_pos, pos)
            
            if distance <= radius:
                var tile_data = world_grid[y][x]
                if tile_data.has("poi_type"):
                    pois.append({
                        "position": pos,
                        "type": tile_data["poi_type"],
                        "distance": distance,
                        "data": tile_data
                    })
    
    # Trie par distance
    pois.sort_custom(func(a, b): return a["distance"] < b["distance"])
    
    return pois

## Conversion grille -> monde
func grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(grid_pos.x * step_distance, grid_pos.y * step_distance)

## Conversion monde -> grille
func world_to_grid(world_pos: Vector2) -> Vector2i:
    return Vector2i(
        int(world_pos.x / step_distance),
        int(world_pos.y / step_distance)
    )

## Getters
func get_current_grid_position() -> Vector2i:
    return world_to_grid(current_world_pos)

func get_is_moving() -> bool:
    return is_moving

func get_movement_progress() -> float:
    if not is_moving:
        return 0.0
    return movement_progress / step_distance
