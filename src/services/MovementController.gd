## MovementController.gd - VERSION PIXEL-BASED
## Mouvement basé sur pixels exacts, pas sur grille
class_name MovementController
extends RefCounted

## Signaux
signal movement_started(from_pos: Vector2, to_pos: Vector2)
signal movement_step(current_pos: Vector2)
signal movement_completed(final_pos: Vector2)
signal movement_blocked(pos: Vector2, reason: String)

## Référence à la grille du monde (pour détecter obstacles)
var world_grid: Array = []
var grid_width: int = 0
var grid_height: int = 0

## État du mouvement
var is_moving: bool = false
var current_path: Array[Vector2] = []  # ⭐ PIXELS, pas grille !
var current_step: int = 0
var movement_progress: float = 0.0
var current_world_pos: Vector2 = Vector2.ZERO
var target_world_pos: Vector2 = Vector2.ZERO

## Configuration
var movement_speed: float = 200.0

## Initialise le contrôleur
func initialize(p_world_grid: Array, p_grid_width: int, p_grid_height: int) -> void:
    world_grid = p_world_grid
    grid_width = p_grid_width
    grid_height = p_grid_height
    print("[MovementController] Initialisé (mode pixel-based)")

## ⭐ NOUVEAU: Démarre mouvement vers position PIXEL exacte
func start_movement_to_pixel(from_pixel: Vector2, to_pixel: Vector2, speed: float = 200.0) -> bool:
    if is_moving:
        print("[MovementController] Mouvement déjà en cours")
        return false
    
    # Vérifie que destination est dans la carte
    var to_grid = world_to_grid(to_pixel)
    if not is_valid_grid_position(to_grid):
        movement_blocked.emit(to_pixel, "Destination hors carte")
        return false
    
    # Vérifie que la case de destination est walkable
    if not is_walkable(to_grid):
        movement_blocked.emit(to_pixel, "Destination non accessible")
        return false
    
    # ⭐ Calcule chemin pixel-based
    current_path = calculate_pixel_path(from_pixel, to_pixel)
    
    if current_path.is_empty():
        movement_blocked.emit(to_pixel, "Aucun chemin trouvé")
        return false
    
    # Initialise mouvement
    is_moving = true
    current_step = 0
    movement_progress = 0.0
    movement_speed = speed
    current_world_pos = from_pixel
    target_world_pos = current_path[0]
    
    movement_started.emit(from_pixel, to_pixel)
    print("[MovementController] Mouvement pixel: %s -> %s (%d waypoints)" % [from_pixel, to_pixel, current_path.size()])
    
    return true

## ⭐ NOUVEAU: Calcule chemin en PIXELS avec A* hybride
func calculate_pixel_path(from_pixel: Vector2, to_pixel: Vector2) -> Array[Vector2]:
    """
    Utilise A* sur grille pour éviter obstacles,
    puis convertit en waypoints pixel + simplifie.
    """
    var from_grid = world_to_grid(from_pixel)
    var to_grid = world_to_grid(to_pixel)
    
    # 1. A* trouve cases sûres
    var grid_path = calculate_path_astar(from_grid, to_grid)
    
    if grid_path.is_empty():
        return []
    
    # 2. Simplifie (lignes droites)
    var simplified_grid = simplify_path(grid_path)
    
    # 3. ⭐ Convertit en PIXELS (pas centres de cases)
    var pixel_path: Array[Vector2] = []
    
    # Premier point = position départ exacte
    pixel_path.append(from_pixel)
    
    # Points intermédiaires = centres de cases clés
    for i in range(1, simplified_grid.size() - 1):
        pixel_path.append(grid_to_world_center(simplified_grid[i]))
    
    # ⭐ Dernier point = destination EXACTE
    pixel_path.append(to_pixel)
    
    print("   📍 Before pixel simplify: %d waypoints" % pixel_path.size())
    
    # 4. ⭐ Vérifie CHAQUE segment du chemin
    # Si un segment traverse obstacle, le subdivise
    pixel_path = validate_and_fix_pixel_path(pixel_path, grid_path)
    
    print("   📍 Final pixel path: %d waypoints (from grid: %d)" % [pixel_path.size(), simplified_grid.size()])
    
    return pixel_path

## ⭐ NOUVEAU: Valide et corrige chemin pixel
func validate_and_fix_pixel_path(pixel_path: Array[Vector2], grid_path: Array[Vector2i]) -> Array[Vector2]:
    """
    Vérifie chaque segment du chemin pixel.
    Si un segment traverse un obstacle, le remplace par chemin grille.
    """
    if pixel_path.size() < 2:
        return pixel_path
    
    var fixed_path: Array[Vector2] = []
    fixed_path.append(pixel_path[0])
    
    for i in range(1, pixel_path.size()):
        var from_pixel = pixel_path[i - 1]
        var to_pixel = pixel_path[i]
        
        # Vérifie segment
        if has_pixel_line_of_sight(from_pixel, to_pixel):
            # Segment OK, garde-le
            fixed_path.append(to_pixel)
        else:
            # ❌ Segment traverse obstacle !
            print("   ⚠️ Segment %d→%d blocked, subdividing" % [i-1, i])
            
            # Trouve cases grille du segment bloqué
            var from_grid = world_to_grid(from_pixel)
            var to_grid = world_to_grid(to_pixel)
            
            # Calcule sous-chemin A* entre from_grid et to_grid
            var sub_path = calculate_path_astar(from_grid, to_grid)
            
            if sub_path.is_empty():
                # Pas de chemin trouvé, garde segment direct (fallback)
                print("      ⚠️ No A* path found, keeping segment")
                fixed_path.append(to_pixel)
            else:
                # Insère waypoints du sous-chemin
                print("      ✅ Inserting %d grid waypoints" % sub_path.size())
                for grid_pos in sub_path:
                    fixed_path.append(grid_to_world_center(grid_pos))
                fixed_path.append(to_pixel)
    
    print("   📍 After validation: %d waypoints (was %d)" % [fixed_path.size(), pixel_path.size()])
    return fixed_path

## ⭐ NOUVEAU: Simplifie chemin pixel avec line-of-sight pixel
func simplify_pixel_path(path: Array[Vector2]) -> Array[Vector2]:
    """Simplifie chemin pixel en vérifiant ligne de vue pixel par pixel"""
    if path.size() <= 1:
        return path
    
    # ⭐ Même avec 2 points, vérifie ligne droite !
    # Si bloquée, garde chemin original
    if path.size() == 2:
        if has_pixel_line_of_sight(path[0], path[1]):
            return path  # OK, ligne droite valide
        else:
            # Ligne droite traverse obstacle !
            # Garde chemin original (déjà optimal via A*)
            print("   ⚠️ Cannot simplify: direct line blocked")
            return path
    
    var simplified: Array[Vector2] = []
    simplified.append(path[0])
    
    var current_index = 0
    
    while current_index < path.size() - 1:
        var farthest_visible = current_index + 1
        
        for i in range(current_index + 2, path.size()):
            if has_pixel_line_of_sight(path[current_index], path[i]):
                farthest_visible = i
            else:
                break
        
        simplified.append(path[farthest_visible])
        current_index = farthest_visible
    
    return simplified

## ⭐ NOUVEAU: Vérifie ligne de vue entre 2 pixels avec Bresenham
func has_pixel_line_of_sight(from_pixel: Vector2, to_pixel: Vector2) -> bool:
    """
    Trace ligne droite entre 2 positions pixel avec algorithme Bresenham.
    Vérifie TOUTES les cases traversées (garantit aucun obstacle manqué).
    """
    var from_grid = world_to_grid(from_pixel)
    var to_grid = world_to_grid(to_pixel)
    
    print("🔍 LOS: %s → %s" % [from_grid, to_grid])
    
    # Bresenham sur les cases
    var dx = abs(to_grid.x - from_grid.x)
    var dy = abs(to_grid.y - from_grid.y)
    var sx = 1 if to_grid.x > from_grid.x else -1
    var sy = 1 if to_grid.y > from_grid.y else -1
    var err = dx - dy
    
    var current = from_grid
    var cells_checked = 0
    var first_cell = true  # ⭐ Flag pour ignorer case de départ
    
    print("   ⭐ START Bresenham (dx=%d, dy=%d)" % [dx, dy])
    
    while true:
        cells_checked += 1
        
        # ⭐ Ignore la case de départ (on y est déjà)
        if not first_cell:
            # Vérifie case actuelle
            var cell_walkable = is_walkable(current)
            var cell_type = world_grid[current.y][current.x] if is_valid_grid_position(current) else -1
            
            print("   [%d] Case %s: type=%s, walkable=%s" % [cells_checked, current, cell_type, cell_walkable])
            
            if not is_valid_grid_position(current) or not cell_walkable:
                print("   ❌ BLOCKED at case %d!" % cells_checked)
                return false
        else:
            print("   [%d] Case %s: SKIPPED (start position)" % [cells_checked, current])
            first_cell = false
        
        # Arrivé à destination
        if current == to_grid:
            print("   ✅ REACHED destination after %d cells" % cells_checked)
            break
        
        var e2 = 2 * err
        
        # Déplacement horizontal
        if e2 > -dy:
            err -= dy
            current.x += sx
        
        # Déplacement vertical
        if e2 < dx:
            err += dx
            current.y += sy
    
    print("   ✅ CLEAR (total: %d cells checked)" % cells_checked)
    return true

## Met à jour le mouvement
func update_movement(delta: float) -> Vector2:
    if not is_moving:
        return current_world_pos
    
    # Distance de ce frame
    var distance_this_frame = movement_speed * delta
    var distance_to_target = current_world_pos.distance_to(target_world_pos)
    
    # Arrivé à la cible actuelle ?
    if distance_this_frame >= distance_to_target:
        # Atteint la cible
        current_world_pos = target_world_pos
        current_step += 1
        
        movement_step.emit(current_world_pos)
        
        # Mouvement terminé ?
        if current_step >= current_path.size():
            is_moving = false
            movement_completed.emit(current_world_pos)
            print("[MovementController] Mouvement terminé à %s" % current_world_pos)
        else:
            # Prochaine cible
            target_world_pos = current_path[current_step]
    else:
        # Continue vers cible
        var direction = (target_world_pos - current_world_pos).normalized()
        current_world_pos += direction * distance_this_frame
    
    return current_world_pos

## ⭐ NOUVEAU: Recalcule vers nouvelle position pixel
func recalculate_path_to_pixel(new_target_pixel: Vector2) -> bool:
    """Recalcule chemin vers nouvelle position pixel pendant mouvement"""
    if not is_moving:
        return start_movement_to_pixel(current_world_pos, new_target_pixel, movement_speed)
    
    var new_path = calculate_pixel_path(current_world_pos, new_target_pixel)
    
    if new_path.is_empty():
        print("[MovementController] Impossible de recalculer vers %s" % new_target_pixel)
        return false
    
    current_path = new_path
    current_step = 0
    target_world_pos = current_path[0]
    
    print("[MovementController] Chemin recalculé vers %s (%d waypoints)" % [new_target_pixel, new_path.size()])
    movement_started.emit(current_world_pos, new_target_pixel)
    
    return true

## Retourne chemin restant (waypoints pixel)
func get_remaining_path() -> Array[Vector2]:
    if not is_moving or current_path.is_empty():
        return []
    
    var remaining: Array[Vector2] = []
    for i in range(current_step, current_path.size()):
        remaining.append(current_path[i])
    
    return remaining

## Retourne cible actuelle + reste
func get_target_and_remaining() -> Dictionary:
    if not is_moving or current_path.is_empty():
        return {"target_pos": Vector2.ZERO, "remaining_path": []}
    
    var target_pos = target_world_pos
    var remaining: Array[Vector2] = []
    
    for i in range(current_step + 1, current_path.size()):
        remaining.append(current_path[i])
    
    return {
        "target_pos": target_pos,
        "remaining_path": remaining
    }

## Arrête mouvement
func stop_movement() -> void:
    if is_moving:
        is_moving = false
        movement_completed.emit(current_world_pos)

## ===== A* SUR GRILLE (pour éviter obstacles) =====

func calculate_path_astar(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
    var open_set: Array[Vector2i] = [from]
    var came_from: Dictionary = {}
    var g_score: Dictionary = {from: 0}
    var f_score: Dictionary = {from: _heuristic(from, to)}
    
    while not open_set.is_empty():
        var current = _get_lowest_f_score(open_set, f_score)
        
        if current == to:
            return _reconstruct_path(came_from, current)
        
        open_set.erase(current)
        
        for neighbor in _get_neighbors(current):
            if not is_walkable(neighbor):
                continue
            
            var tentative_g_score = g_score[current] + _get_movement_cost(current, neighbor)
            
            if not g_score.has(neighbor) or tentative_g_score < g_score[neighbor]:
                came_from[neighbor] = current
                g_score[neighbor] = tentative_g_score
                f_score[neighbor] = tentative_g_score + _heuristic(neighbor, to)
                
                if neighbor not in open_set:
                    open_set.append(neighbor)
    
    return []

func _heuristic(from: Vector2i, to: Vector2i) -> float:
    var dx = to.x - from.x
    var dy = to.y - from.y
    return sqrt(dx * dx + dy * dy)

func _get_movement_cost(from: Vector2i, to: Vector2i) -> float:
    var dx = abs(to.x - from.x)
    var dy = abs(to.y - from.y)
    return 1.414 if (dx + dy == 2) else 1.0

func _get_lowest_f_score(nodes: Array[Vector2i], f_scores: Dictionary) -> Vector2i:
    var lowest_node = nodes[0]
    var lowest_score = f_scores.get(lowest_node, INF)
    
    for node in nodes:
        var score = f_scores.get(node, INF)
        if score < lowest_score:
            lowest_score = score
            lowest_node = node
    
    return lowest_node

func _get_neighbors(pos: Vector2i) -> Array[Vector2i]:
    var neighbors: Array[Vector2i] = []
    var directions = [
        Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1),
        Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)
    ]
    
    for dir in directions:
        var neighbor = pos + dir
        if is_valid_grid_position(neighbor):
            neighbors.append(neighbor)
    
    return neighbors

func _reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
    var path: Array[Vector2i] = [current]
    
    while came_from.has(current):
        current = came_from[current]
        path.push_front(current)
    
    if path.size() > 0:
        path.remove_at(0)
    
    return path

## ===== SIMPLIFICATION GRILLE =====

func simplify_path(path: Array[Vector2i]) -> Array[Vector2i]:
    if path.size() <= 2:
        return path
    
    var simplified: Array[Vector2i] = []
    simplified.append(path[0])
    
    var current_index = 0
    
    while current_index < path.size() - 1:
        var farthest_visible = current_index + 1
        
        for i in range(current_index + 2, path.size()):
            if has_line_of_sight(path[current_index], path[i]):
                farthest_visible = i
            else:
                break
        
        simplified.append(path[farthest_visible])
        current_index = farthest_visible
    
    return simplified

func has_line_of_sight(from: Vector2i, to: Vector2i) -> bool:
    print("   🔍 Grid LOS: %s → %s" % [from, to])
    
    var dx = abs(to.x - from.x)
    var dy = abs(to.y - from.y)
    var sx = 1 if to.x > from.x else -1
    var sy = 1 if to.y > from.y else -1
    var err = dx - dy
    
    var current = from
    var first_cell = true  # ⭐ Skip case de départ
    var cells_checked = 0
    
    while current != to:
        cells_checked += 1
        
        # ⭐ Ignore case de départ
        if not first_cell:
            var walkable = is_walkable(current)
            var cell_type = world_grid[current.y][current.x]
            print("      [%d] %s: type=%s, walkable=%s" % [cells_checked, current, cell_type, walkable])
            
            if not walkable:
                print("      ❌ Grid LOS BLOCKED at %s" % current)
                return false
        else:
            print("      [%d] %s: SKIPPED (start)" % [cells_checked, current])
            first_cell = false
        
        var e2 = 2 * err
        
        if e2 > -dy:
            err -= dy
            current.x += sx
        
        if e2 < dx:
            err += dx
            current.y += sy
    
    var final_walkable = is_walkable(to)
    print("      Final %s: walkable=%s" % [to, final_walkable])
    
    if final_walkable:
        print("      ✅ Grid LOS CLEAR")
    else:
        print("      ❌ Grid LOS BLOCKED at destination")
    
    return final_walkable

## ===== UTILITAIRES =====

func is_valid_grid_position(pos: Vector2i) -> bool:
    return pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height

func is_walkable(pos: Vector2i) -> bool:
    if not is_valid_grid_position(pos):
        return false
    var tile_type: GameEnums.CellType = world_grid[pos.y][pos.x]
    return GameEnums.CELL_ENUM[tile_type].walkable

func world_to_grid(world_pos: Vector2) -> Vector2i:
    return Vector2i(
        int(world_pos.x / WorldConstants.TILE_SIZE),
        int(world_pos.y / WorldConstants.TILE_SIZE)
    )

func grid_to_world_center(grid_pos: Vector2i) -> Vector2:
    return Vector2(
        float(grid_pos.x) * WorldConstants.TILE_SIZE + WorldConstants.TILE_SIZE * 0.5,
        float(grid_pos.y) * WorldConstants.TILE_SIZE + WorldConstants.TILE_SIZE * 0.5
    )

func get_current_grid_position() -> Vector2i:
    return world_to_grid(current_world_pos)

func get_is_moving() -> bool:
    return is_moving
