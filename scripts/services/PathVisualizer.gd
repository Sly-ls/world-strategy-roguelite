## PathVisualizer.gd
## Affiche visuellement le chemin que l'armée va emprunter
extends Node2D
class_name PathVisualizer

## Configuration visuelle
@export var path_color: Color = Color(1.0, 1.0, 0.3, 0.8)  # Jaune translucide
@export var path_width: float = 4.0
@export var arrow_color: Color = Color(1.0, 1.0, 0.3, 1.0)
@export var arrow_size: float = 12.0

## État
var current_path: Array[Vector2i] = []
var is_visible: bool = false


func _ready() -> void:
    z_index = 100  # Au-dessus de la carte
    visible = false


## Affiche un chemin
func show_path(path: Array[Vector2i]) -> void:
    current_path = path.duplicate()
    is_visible = true
    visible = true
    queue_redraw()


## Cache le chemin
func hide_path() -> void:
    is_visible = false
    visible = false
    current_path.clear()
    queue_redraw()


## Dessine le chemin
func _draw() -> void:
    if not is_visible or current_path.is_empty():
        return
    
    # Convertit les positions grille en positions monde
    var world_points: Array[Vector2] = []
    for grid_pos in current_path:
        var world_pos = _grid_to_world(grid_pos)
        world_points.append(world_pos)
    
    # Dessine les lignes entre les points
    for i in range(world_points.size() - 1):
        var from = world_points[i]
        var to = world_points[i + 1]
        draw_line(from, to, path_color, path_width, true)
    
    # Dessine des flèches aux points intermédiaires
    _draw_arrows(world_points)
    
    # Dessine un cercle à la destination finale
    if world_points.size() > 0:
        var final_pos = world_points[world_points.size() - 1]
        draw_circle(final_pos, 8.0, arrow_color)


## Dessine des flèches le long du chemin
func _draw_arrows(points: Array[Vector2]) -> void:
    # Dessine une flèche tous les 2-3 points
    var arrow_interval = 3
    
    for i in range(0, points.size() - 1, arrow_interval):
        var from = points[i]
        var to = points[i + 1]
        var direction = (to - from).normalized()
        
        # Point de la flèche (au milieu du segment)
        var arrow_pos = from + direction * (to - from).length() * 0.5
        
        # Dessine triangle de flèche
        _draw_arrow_head(arrow_pos, direction)


## Dessine une tête de flèche
func _draw_arrow_head(pos: Vector2, direction: Vector2) -> void:
    var angle = direction.angle()
    
    # Points du triangle
    var tip = pos
    var left = pos + Vector2(
        -arrow_size * cos(angle - PI * 0.75),
        -arrow_size * sin(angle - PI * 0.75)
    )
    var right = pos + Vector2(
        -arrow_size * cos(angle + PI * 0.75),
        -arrow_size * sin(angle + PI * 0.75)
    )
    
    # Dessine triangle rempli
    var points = PackedVector2Array([tip, left, right])
    var colors = PackedColorArray([arrow_color, arrow_color, arrow_color])
    draw_polygon(points, colors)


## ⭐ CORRIGÉ: Conversion grille → monde utilisant WorldConstants
func _grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(
        float(grid_pos.x) * WorldConstants.TILE_SIZE + WorldConstants.TILE_SIZE * 0.5,
        float(grid_pos.y) * WorldConstants.TILE_SIZE + WorldConstants.TILE_SIZE * 0.5
    )


## Met à jour le chemin (pour animation progressive si besoin)
func update_path(remaining_path: Array[Vector2i]) -> void:
    if remaining_path != current_path:
        show_path(remaining_path)
