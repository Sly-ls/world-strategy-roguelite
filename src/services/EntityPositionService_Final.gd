## EntityPositionService.gd - VERSION FINALE (INDEX SPATIAL)
## Service qui fonctionne comme un INDEX SPATIAL pour recherche rapide
## La position RÉELLE est dans ArmyData.runtime_position
## Le service maintient juste un index pour requêtes spatiales optimisées
class_name EntityPositionService
extends RefCounted

## ===== SIGNAUX =====
signal entity_moved(entity_id: String, old_pos: Vector2i, new_pos: Vector2i)
signal entity_entered_cell(entity_id: String, cell_pos: Vector2i, cell_type: int)
signal entities_at_same_position(entity_ids: Array[String], pos: Vector2i)

## ===== STRUCTURE ENTITÉ =====
class EntityEntry:
    var entity_id: String
    var entity_type: String  # "player_army", "enemy_army", "npc", "caravan"
    var army_data: ArmyData  # Référence vers l'armée (qui contient la position)
    
    func _init(id: String, type: String, data: ArmyData):
        entity_id = id
        entity_type = type
        army_data = data
    
    func get_position() -> Vector2i:
        """Lit la position depuis ArmyData (source unique de vérité)"""
        return army_data.get_position()

## ===== STOCKAGE =====
var entities: Dictionary = {}  # {entity_id: EntityEntry}
var grid_occupancy: Dictionary = {}  # {Vector2i: Array[entity_id]} - INDEX SPATIAL

## ===== RÉFÉRENCE GRILLE =====
var world_grid: Array = []
var grid_width: int = 0
var grid_height: int = 0

const TILE_SIZE: int = 64

## ===== INITIALISATION =====

func initialize(p_world_grid: Array, p_width: int, p_height: int) -> void:
    world_grid = p_world_grid
    grid_width = p_width
    grid_height = p_height
    entities.clear()
    grid_occupancy.clear()
    print("[EntityPositionService] Initialisé %dx%d (mode index spatial)" % [grid_width, grid_height])

## ===== GESTION ENTITÉS =====

func register_entity(entity_id: String, entity_type: String, army_data: ArmyData) -> bool:
    """
    Enregistre une entité dans l'index spatial.
    La position est lue depuis army_data.get_position()
    """
    if entities.has(entity_id):
        print("[EntityPositionService] WARN: Entité %s déjà enregistrée" % entity_id)
        return false
    
    if not army_data.has_valid_position():
        print("[EntityPositionService] ERROR: Armée %s n'a pas de position valide" % entity_id)
        print("  → Appelle army_data.set_position() d'abord !")
        return false
    
    var entry = EntityEntry.new(entity_id, entity_type, army_data)
    entities[entity_id] = entry
    
    # Ajoute à l'index spatial
    var pos = entry.get_position()
    _add_to_grid_occupancy(pos, entity_id)
    
    print("[EntityPositionService] Enregistré: %s (%s) à %s" % [entity_id, entity_type, pos])
    return true

func unregister_entity(entity_id: String) -> bool:
    """Supprime une entité de l'index"""
    if not entities.has(entity_id):
        return false
    
    var entry = entities[entity_id]
    var pos = entry.get_position()
    
    _remove_from_grid_occupancy(pos, entity_id)
    entities.erase(entity_id)
    
    print("[EntityPositionService] Désenregistré: %s" % entity_id)
    return true

## ===== SYNCHRONISATION POSITION =====

func update_entity_position(entity_id: String, old_pos: Vector2i) -> bool:
    """
    Met à jour l'index spatial après qu'une entité a bougé.
    La position est lue depuis army_data.get_position()

    Usage:
        var old_pos = army.get_position()
        army.set_position(new_pos)
        entity_position_service.update_entity_position("player", old_pos)
    """
    if not entities.has(entity_id):
        print("[EntityPositionService] ERROR: Entité %s inconnue" % entity_id)
        return false
    
    var entry = entities[entity_id]
    var new_pos = entry.get_position()  # Lit depuis ArmyData
    
    if old_pos == new_pos:
        return true  # Pas de mouvement
    
    # Met à jour l'index spatial
    _remove_from_grid_occupancy(old_pos, entity_id)
    _add_to_grid_occupancy(new_pos, entity_id)
    
    # Signaux
    entity_moved.emit(entity_id, old_pos, new_pos)
    
    var cell_type = _get_cell_type(new_pos)
    entity_entered_cell.emit(entity_id, new_pos, cell_type)
    
    # Vérifie si plusieurs entités à la même position
    _check_collisions(new_pos)
    
    return true

func refresh_all_positions() -> void:
    """
    Reconstruit l'index spatial complet depuis les positions dans ArmyData.
    Utile après chargement de sauvegarde.
    """
    grid_occupancy.clear()
    
    for entity_id in entities:
        var entry = entities[entity_id]
        var pos = entry.get_position()
        _add_to_grid_occupancy(pos, entity_id)
    
    print("[EntityPositionService] Index spatial reconstruit")

## ===== REQUÊTES POSITION =====

func get_entity_position(entity_id: String) -> Vector2i:
    """Récupère la position d'une entité (depuis ArmyData)"""
    if entities.has(entity_id):
        return entities[entity_id].get_position()
    return Vector2i(-1, -1)

func get_entity_data(entity_id: String) -> ArmyData:
    """Récupère l'ArmyData d'une entité"""
    if entities.has(entity_id):
        return entities[entity_id].army_data
    return null

func get_entity_type(entity_id: String) -> String:
    """Récupère le type d'une entité"""
    if entities.has(entity_id):
        return entities[entity_id].entity_type
    return ""

func get_entities_at(grid_pos: Vector2i) -> Array:
    """Récupère toutes les entités à une position (RAPIDE - utilise l'index)"""
    if grid_occupancy.has(grid_pos):
        var truc =grid_occupancy[grid_pos].duplicate()
        return truc
    return [""]

func get_entities_by_type(entity_type: String) -> Array[String]:
    """Récupère toutes les entités d'un certain type"""
    var result: Array[String] = []
    for entity_id in entities:
        if entities[entity_id].entity_type == entity_type:
            result.append(entity_id)
    return result

func get_all_entity_ids() -> Array[String]:
    """Récupère tous les IDs d'entités"""
    var result: Array[String] = []
    for entity_id in entities:
        result.append(entity_id)
    return result

func entity_exists(entity_id: String) -> bool:
    """Vérifie si une entité existe"""
    return entities.has(entity_id)

## ===== RECHERCHE SPATIALE (OPTIMISÉE) =====

func find_entities_in_radius(center: Vector2i, radius: int, filter_type: String = "") -> Array[Dictionary]:
    """
    Trouve les entités dans un rayon (utilise l'index spatial pour optimisation)
    Returns: Array of {entity_id, position, distance, type, data}
    """
    var found: Array[Dictionary] = []
    
    # Optimisation: parcourt seulement les cases dans le rayon
    var min_x = max(0, center.x - radius)
    var max_x = min(grid_width - 1, center.x + radius)
    var min_y = max(0, center.y - radius)
    var max_y = min(grid_height - 1, center.y + radius)
    
    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            var pos = Vector2i(x, y)
            var distance = _calculate_distance(center, pos)
            
            if distance > radius:
                continue
            
            # Récupère les entités à cette position (RAPIDE - index)
            var entities_here = get_entities_at(pos)
            
            for entity_id in entities_here:
                var entry = entities[entity_id]
                
                # Filtre par type
                if filter_type != "" and entry.entity_type != filter_type:
                    continue
                
                found.append({
                    "entity_id": entity_id,
                    "position": pos,
                    "distance": distance,
                    "type": entry.entity_type,
                    "data": entry.army_data
                })
    
    # Trie par distance
    found.sort_custom(func(a, b): return a["distance"] < b["distance"])
    
    return found

func find_nearest_entity(from_pos: Vector2i, entity_type: String = "", max_distance: int = 999) -> String:
    """Trouve l'entité la plus proche"""
    var nearest_id = ""
    var nearest_dist = max_distance + 1
    
    for entity_id in entities:
        var entry = entities[entity_id]
        
        if entity_type != "" and entry.entity_type != entity_type:
            continue
        
        var distance = _calculate_distance(from_pos, entry.get_position())
        if distance < nearest_dist:
            nearest_dist = distance
            nearest_id = entity_id
    
    return nearest_id

func find_nearest_enemy_to_player(player_id: String, max_distance: int = 20) -> String:
    """Trouve l'ennemi le plus proche d'un joueur"""
    if not entities.has(player_id):
        return ""
    
    var player_pos = get_entity_position(player_id)
    return find_nearest_entity(player_pos, "enemy_army", max_distance)

func get_entities_on_path(from: Vector2i, to: Vector2i) -> Array[String]:
    """Trouve toutes les entités sur un chemin (ligne droite)"""
    var entities_found: Array[String] = []
    
    # Calcul simple ligne par ligne (Manhattan path)
    var current = from
    
    while current != to:
        var entities_here = get_entities_at(current)
        for entity_id in entities_here:
            if entity_id not in entities_found:
                entities_found.append(entity_id)
        
        # Avance vers la cible
        if current.x < to.x:
            current.x += 1
        elif current.x > to.x:
            current.x -= 1
        elif current.y < to.y:
            current.y += 1
        elif current.y > to.y:
            current.y -= 1
    
    return entities_found

## ===== DÉTECTION COLLISION =====

func _check_collisions(pos: Vector2i) -> void:
    """Vérifie si plusieurs entités sont à la même position"""
    var occupants = get_entities_at(pos)
    
    if occupants.size() > 1:
        entities_at_same_position.emit(occupants, pos)
        print("[EntityPositionService] Collision: %s à %s" % [occupants, pos])

func check_collision_at(pos: Vector2i) -> bool:
    """Vérifie s'il y a collision à une position"""
    return get_entities_at(pos).size() > 1

func get_collision_groups(pos: Vector2i) -> Dictionary:
    """Retourne les groupes d'entités en collision par type"""
    var groups = {}
    var occupants = get_entities_at(pos)
    
    for entity_id in occupants:
        var entity_type = get_entity_type(entity_id)
        if not groups.has(entity_type):
            groups[entity_type] = []
        groups[entity_type].append(entity_id)
    
    return groups

## ===== OCCUPATION GRILLE (INDEX SPATIAL) =====

func _add_to_grid_occupancy(pos: Vector2i, entity_id: String) -> void:
    if not grid_occupancy.has(pos):
        grid_occupancy[pos] = []
    grid_occupancy[pos].append(entity_id)

func _remove_from_grid_occupancy(pos: Vector2i, entity_id: String) -> void:
    if grid_occupancy.has(pos):
        grid_occupancy[pos].erase(entity_id)
        if grid_occupancy[pos].is_empty():
            grid_occupancy.erase(pos)

## ===== VALIDATIONS =====

func _is_valid_position(pos: Vector2i) -> bool:
    return pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height

func _is_walkable(pos: Vector2i) -> bool:
    if not _is_valid_position(pos):
        return false
    
    var cell_type = world_grid[pos.y][pos.x]
    return GameEnums.CELL_ENUM[cell_type].walkable

func _get_cell_type(pos: Vector2i) -> int:
    if not _is_valid_position(pos):
        return GameEnums.CellType.PLAINE
    return world_grid[pos.y][pos.x]

## ===== UTILITAIRES =====

func _calculate_distance(from: Vector2i, to: Vector2i) -> float:
    """Distance Manhattan"""
    return abs(to.x - from.x) + abs(to.y - from.y)

func _grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(
        float(grid_pos.x) * TILE_SIZE + TILE_SIZE * 0.5,
        float(grid_pos.y) * TILE_SIZE + TILE_SIZE * 0.5
    )

func _world_to_grid(world_pos: Vector2) -> Vector2i:
    return Vector2i(
        int(floor(world_pos.x / TILE_SIZE)),
        int(floor(world_pos.y / TILE_SIZE))
    )

## ===== STATISTIQUES =====

func get_entity_count() -> int:
    """Nombre total d'entités enregistrées"""
    return entities.size()

func get_entity_count_by_type(entity_type: String) -> int:
    """Nombre d'entités d'un type donné"""
    return get_entities_by_type(entity_type).size()

func get_occupied_cells_count() -> int:
    """Nombre de cases occupées"""
    return grid_occupancy.size()

func get_stats() -> Dictionary:
    """Statistiques globales du service"""
    return {
        "total_entities": get_entity_count(),
        "player_armies": get_entity_count_by_type("player_army"),
        "enemy_armies": get_entity_count_by_type("enemy_army"),
        "npcs": get_entity_count_by_type("npc"),
        "caravans": get_entity_count_by_type("caravan"),
        "occupied_cells": get_occupied_cells_count()
    }

## ===== DEBUG =====

func debug_print_entities() -> void:
    print("\n=== ENTITÉS ENREGISTRÉES ===")
    for entity_id in entities:
        var entry = entities[entity_id]
        print("  [%s] %s à %s" % [entry.entity_type, entity_id, entry.get_position()])
    print("Total: %d entités\n" % entities.size())

func debug_print_occupancy() -> void:
    print("\n=== OCCUPATION GRILLE (INDEX) ===")
    var sorted_positions = grid_occupancy.keys()
    sorted_positions.sort()
    
    for pos in sorted_positions:
        var occupants = grid_occupancy[pos]
        print("  %s: %s" % [pos, occupants])
    print("Total: %d cases occupées\n" % grid_occupancy.size())

func debug_print_entities_near(center: Vector2i, radius: int = 5) -> void:
    print("\n=== ENTITÉS PROCHES DE %s (rayon %d) ===" % [center, radius])
    var nearby = find_entities_in_radius(center, radius)
    
    for info in nearby:
        print("  [%s] %s à %s (distance: %.0f)" % [
            info["type"],
            info["entity_id"],
            info["position"],
            info["distance"]
        ])
    
    print("Total: %d entités\n" % nearby.size())

func debug_print_stats() -> void:
    print("\n=== STATISTIQUES SERVICE ===")
    var stats = get_stats()
    print("  Total entités: %d" % stats["total_entities"])
    print("  Joueurs: %d" % stats["player_armies"])
    print("  Ennemis: %d" % stats["enemy_armies"])
    print("  PNJs: %d" % stats["npcs"])
    print("  Caravanes: %d" % stats["caravans"])
    print("  Cases occupées: %d" % stats["occupied_cells"])
    print("========================\n")

func debug_validate_consistency() -> bool:
    """Vérifie la cohérence entre ArmyData.position et l'index"""
    var errors = 0
    
    print("\n=== VALIDATION COHÉRENCE ===")
    
    for entity_id in entities:
        var entry = entities[entity_id]
        var pos_from_army = entry.army_data.get_position()
        
        # Vérifie que l'index contient bien cette entité à cette position
        var entities_at_pos = get_entities_at(pos_from_army)
        
        if entity_id not in entities_at_pos:
            print("  ERROR: %s devrait être à %s mais n'est pas dans l'index !" % [entity_id, pos_from_army])
            errors += 1
    
    if errors == 0:
        print("  ✅ Index cohérent avec ArmyData.position")
    else:
        print("  ❌ %d erreurs détectées !" % errors)
    
    print("============================\n")
    return errors == 0
