## MovementController.gd
## Service responsable de la gestion des mouvements sur la carte
## ⭐ CORRIGÉ: Utilise WorldConstants.TILE_SIZE partout
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

## Initialise le contrôleur avec la grille du monde
func initialize(p_world_grid: Array, p_grid_width: int, p_grid_height: int) -> void:
    world_grid = p_world_grid
    grid_width = p_grid_width
    grid_height = p_grid_height
    print("[MovementController] Initialisé avec grille %dx%d, TILE_SIZE=%d" % [grid_width, grid_height, WorldConstants.TILE_SIZE])

## Démarre un mouvement de from_pos vers to_pos
func start_movement(from_pos: Vector2i, to_pos: Vector2i, speed: float = 200.0) -> bool:
    if is_moving:
        print("[MovementController] Mouvement déjà en cours")
        return false
    
    # Vérifie que la position de départ et d'arrivée sont valides
    if not is_valid_grid_position(from_pos) or not is_valid_grid_position(to_pos):
        movement_blocked.emit(to_pos, "Position invalide")
        return false
    
    # Vérifie que la destination est walkable
    if not is_walkable(to_pos):
        movement_blocked.emit(to_pos, "Destination non accessible")
        return false
    
    # ⭐ Calcule le chemin avec A*
    current_path = calculate_path_astar(from_pos, to_pos)
    
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
    
    # ⭐ Utilise WorldConstants.TILE_SIZE pour la distance
    var step_distance = float(WorldConstants.TILE_SIZE)
    
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

## ⭐ NOUVEAU: Recalcule le chemin pendant le mouvement
func recalculate_path(new_target: Vector2i) -> bool:
    """
    Recalcule le chemin vers une nouvelle destination pendant le mouvement.
    Retourne true si le nouveau chemin est valide.
    """
    if not is_moving:
        # Si on ne bouge pas, démarre un nouveau mouvement
        var current_grid = world_to_grid(current_world_pos)
        return start_movement(current_grid, new_target, movement_speed)
    
    # Vérifie destination valide
    if not is_valid_grid_position(new_target) or not is_walkable(new_target):
        print("[MovementController] Nouvelle destination invalide: %s" % new_target)
        return false
    
    # Position actuelle (case en cours)
    var from_pos = world_to_grid(current_world_pos)
    
    # Si on est au milieu d'une case, on part de la case cible actuelle
    if movement_progress > 0.0 and current_step < current_path.size():
        from_pos = current_path[current_step]
    
    # Calcule nouveau chemin
    var new_path = calculate_path_astar(from_pos, new_target)
    
    if new_path.is_empty():
        print("[MovementController] Impossible de recalculer vers %s" % new_target)
        return false
    
    # ⭐ Remplace le chemin actuel
    current_path = new_path
    current_step = 0
    movement_progress = 0.0
    current_world_pos = grid_to_world(from_pos)
    target_world_pos = grid_to_world(current_path[0])
    
    print("[MovementController] Chemin recalculé: %s -> %s (%d étapes)" % [from_pos, new_target, new_path.size()])
    
    # Émet signal pour mettre à jour la visualisation
    movement_started.emit(from_pos, new_target)
    
    return true

## ⭐ NOUVEAU: Retourne le chemin restant (pour visualisation)
func get_remaining_path() -> Array[Vector2i]:
    """Retourne le chemin restant à parcourir (incluant case actuelle)"""
    if not is_moving or current_path.is_empty():
        return []
    
    # Retourne les cases restantes depuis current_step
    var remaining: Array[Vector2i] = []
    for i in range(current_step, current_path.size()):
        remaining.append(current_path[i])
    
    return remaining

## Arrête le mouvement en cours
func stop_movement() -> void:
    if is_moving:
        is_moving = false
        var final_pos = world_to_grid(current_world_pos)
        movement_completed.emit(final_pos)
        print("[MovementController] Mouvement interrompu à %s" % final_pos)

## ===== PATHFINDING A* =====

## Calcule le chemin optimal avec A* (contourne obstacles, privilégie ligne droite)
func calculate_path_astar(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
    # Structures de données A*
    var open_set: Array[Vector2i] = [from]  # Nœuds à explorer
    var came_from: Dictionary = {}          # Pour reconstruire le chemin
    var g_score: Dictionary = {from: 0}    # Coût depuis le départ
    var f_score: Dictionary = {from: _heuristic(from, to)}  # Coût estimé total
    
    while not open_set.is_empty():
        # Trouve le nœud avec le plus petit f_score
        var current = _get_lowest_f_score(open_set, f_score)
        
        # Arrivé à destination
        if current == to:
            return _reconstruct_path(came_from, current)
        
        open_set.erase(current)
        
        # Explore les voisins
        for neighbor in _get_neighbors(current):
            if not is_walkable(neighbor):
                continue
            
            # Calcule le coût pour atteindre ce voisin
            var tentative_g_score = g_score[current] + _get_movement_cost(current, neighbor)
            
            # Si ce chemin est meilleur que celui connu
            if not g_score.has(neighbor) or tentative_g_score < g_score[neighbor]:
                came_from[neighbor] = current
                g_score[neighbor] = tentative_g_score
                f_score[neighbor] = tentative_g_score + _heuristic(neighbor, to)
                
                if neighbor not in open_set:
                    open_set.append(neighbor)
    
    # Aucun chemin trouvé
    print("[MovementController] A*: Aucun chemin de %s vers %s" % [from, to])
    return []

## Heuristique pour A* - Distance euclidienne (privilégie ligne droite)
func _heuristic(from: Vector2i, to: Vector2i) -> float:
    # Distance euclidienne pour privilégier les chemins droits
    var dx = to.x - from.x
    var dy = to.y - from.y
    return sqrt(dx * dx + dy * dy)

## Coût de déplacement entre deux cases adjacentes
func _get_movement_cost(from: Vector2i, to: Vector2i) -> float:
    # Coût diagonal légèrement supérieur
    var dx = abs(to.x - from.x)
    var dy = abs(to.y - from.y)
    
    if dx + dy == 2:  # Diagonale
        return 1.414  # sqrt(2)
    else:  # Horizontal ou vertical
        return 1.0

## Trouve le nœud avec le plus petit f_score
func _get_lowest_f_score(nodes: Array[Vector2i], f_scores: Dictionary) -> Vector2i:
    var lowest_node = nodes[0]
    var lowest_score = f_scores.get(lowest_node, INF)
    
    for node in nodes:
        var score = f_scores.get(node, INF)
        if score < lowest_score:
            lowest_score = score
            lowest_node = node
    
    return lowest_node

## Retourne les voisins d'une position (8 directions)
func _get_neighbors(pos: Vector2i) -> Array[Vector2i]:
    var neighbors: Array[Vector2i] = []
    
    # 8 directions (incluant diagonales pour mouvement fluide)
    var directions = [
        Vector2i(-1, 0),   # Gauche
        Vector2i(1, 0),    # Droite
        Vector2i(0, -1),   # Haut
        Vector2i(0, 1),    # Bas
        Vector2i(-1, -1),  # Haut-gauche
        Vector2i(1, -1),   # Haut-droite
        Vector2i(-1, 1),   # Bas-gauche
        Vector2i(1, 1)     # Bas-droite
    ]
    
    for dir in directions:
        var neighbor = pos + dir
        if is_valid_grid_position(neighbor):
            neighbors.append(neighbor)
    
    return neighbors

## Reconstruit le chemin depuis came_from
func _reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
    var path: Array[Vector2i] = [current]
    
    while came_from.has(current):
        current = came_from[current]
        path.push_front(current)
    
    # Retire la position de départ (on y est déjà)
    if path.size() > 0:
        path.remove_at(0)
    
    return path

## ===== UTILITAIRES =====

## Vérifie si une position de grille est valide
func is_valid_grid_position(pos: Vector2i) -> bool:
    return pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height

## Vérifie si une case est praticable
func is_walkable(pos: Vector2i) -> bool:
    if not is_valid_grid_position(pos):
        return false
    
    # Vérifie le terrain dans la grille
    var tile_type: GameEnums.CellType = world_grid[pos.y][pos.x]
    return GameEnums.CELL_ENUM[tile_type].walkable

## Calcule la distance Manhattan entre deux positions
func calculate_distance(from: Vector2i, to: Vector2i) -> float:
    return abs(to.x - from.x) + abs(to.y - from.y)

## ⭐ CORRIGÉ: Conversion grille → monde utilisant WorldConstants
func grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(
        float(grid_pos.x) * WorldConstants.TILE_SIZE + WorldConstants.TILE_SIZE * 0.5,
        float(grid_pos.y) * WorldConstants.TILE_SIZE + WorldConstants.TILE_SIZE * 0.5
    )

## ⭐ CORRIGÉ: Conversion monde → grille utilisant WorldConstants
func world_to_grid(world_pos: Vector2) -> Vector2i:
    return Vector2i(
        int(world_pos.x / WorldConstants.TILE_SIZE),
        int(world_pos.y / WorldConstants.TILE_SIZE)
    )

## Getters
func get_current_grid_position() -> Vector2i:
    return world_to_grid(current_world_pos)

func get_is_moving() -> bool:
    return is_moving

func get_movement_progress() -> float:
    if not is_moving:
        return 0.0
    return movement_progress / float(WorldConstants.TILE_SIZE)
