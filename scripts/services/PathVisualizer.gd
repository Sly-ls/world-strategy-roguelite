## PathVisualizer.gd - VERSION PIXEL-BASED
## Affiche chemin en positions pixel exactes
extends Node2D
class_name PathVisualizer

## Configuration visuelle
@export var path_color: Color = Color(1.0, 1.0, 0.3, 0.8)
@export var path_width: float = 4.0
@export var arrow_color: Color = Color(1.0, 1.0, 0.3, 1.0)
@export var arrow_size: float = 12.0

## État
var current_path: Array[Vector2] = []  # ⭐ Positions PIXEL, pas grille !
var is_visible: bool = false


func _ready() -> void:
    z_index = 100
    visible = false


## ⭐ Affiche chemin pixel
func show_pixel_path(pixel_path: Array[Vector2]) -> void:
    """Affiche chemin en positions pixel exactes"""
    current_path = pixel_path.duplicate()
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
    if not is_visible or current_path.size() < 2:
        return
    
    # ⭐ current_path contient déjà positions pixel exactes
    var world_points = current_path
    
    # Dessine lignes
    for i in range(world_points.size() - 1):
        draw_line(world_points[i], world_points[i + 1], path_color, path_width, true)
    
    # Dessine flèches
    _draw_arrows(world_points)
    
    # Cercle à la destination
    draw_circle(world_points[world_points.size() - 1], 8.0, arrow_color)


## Dessine flèches le long du chemin
func _draw_arrows(points: Array[Vector2]) -> void:
    var arrow_interval = 3
    
    for i in range(0, points.size() - 1, arrow_interval):
        var from = points[i]
        var to = points[i + 1]
        var direction = (to - from).normalized()
        var arrow_pos = from + direction * (to - from).length() * 0.5
        _draw_arrow_head(arrow_pos, direction)


## Dessine une flèche
func _draw_arrow_head(pos: Vector2, direction: Vector2) -> void:
    var angle = direction.angle()
    var tip = pos
    var left = pos + Vector2(
        -arrow_size * cos(angle - PI * 0.75),
        -arrow_size * sin(angle - PI * 0.75)
    )
    var right = pos + Vector2(
        -arrow_size * cos(angle + PI * 0.75),
        -arrow_size * sin(angle + PI * 0.75)
    )
    
    var arrow_points = PackedVector2Array([tip, left, right])
    var colors = PackedColorArray([arrow_color, arrow_color, arrow_color])
    draw_polygon(arrow_points, colors)
