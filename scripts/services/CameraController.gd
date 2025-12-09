## CameraController.gd
## Service responsable de la gestion de la caméra
class_name CameraController
extends RefCounted

## Signaux
signal zoom_changed(new_zoom: float)
signal camera_moved(new_position: Vector2)

## Référence à la caméra (stockée comme référence faible)
var camera_ref: WeakRef = null
var world_bounds: Rect2 = Rect2(0, 0, 0, 0)

## Configuration du zoom
var min_zoom: float = 0.5
var max_zoom: float = 2.0
var zoom_speed: float = 0.1
var current_zoom: float = 1.0

## Configuration du mouvement
var follow_speed: float = 5.0
var target_position: Vector2 = Vector2.ZERO
var camera_offset: Vector2 = Vector2.ZERO

## État
var is_following: bool = true
var is_dragging: bool = false
var drag_start_pos: Vector2 = Vector2.ZERO

## Initialise le contrôleur
func initialize(camera: Camera2D, p_world_bounds: Rect2) -> void:
    camera_ref = weakref(camera)
    world_bounds = p_world_bounds
    
    if camera:
        current_zoom = camera.zoom.x
        target_position = camera.global_position
    
    print("[CameraController] Initialisé avec bounds: %s" % world_bounds)

## Définit la position cible (pour suivre le joueur)
func set_target_position(pos: Vector2) -> void:
    target_position = pos + camera_offset

## Définit un offset pour la caméra
func set_camera_offset(offset: Vector2) -> void:
    camera_offset = offset
    target_position = target_position + offset

## Active/désactive le suivi automatique
func set_following(enabled: bool) -> void:
    is_following = enabled
    print("[CameraController] Suivi: %s" % ("activé" if enabled else "désactivé"))

## Met à jour la position de la caméra (à appeler dans _process)
func update_camera(delta: float) -> void:
    var camera = _get_camera()
    if not camera:
        return
    
    # Suivi du joueur si activé
    if is_following and not is_dragging:
        var new_pos = camera.global_position.lerp(target_position, follow_speed * delta)
        new_pos = _clamp_to_bounds(new_pos)
        camera.global_position = new_pos
        camera_moved.emit(new_pos)

## Centre immédiatement la caméra sur une position
func center_on(pos: Vector2) -> void:
    var camera = _get_camera()
    if not camera:
        return
    
    var clamped_pos = _clamp_to_bounds(pos)
    camera.global_position = clamped_pos
    target_position = clamped_pos
    camera_moved.emit(clamped_pos)
    print("[CameraController] Centré sur: %s" % pos)

## Ajuste le zoom
func adjust_zoom(delta_zoom: float) -> void:
    var camera = _get_camera()
    if not camera:
        return
    
    var new_zoom = clamp(current_zoom + delta_zoom, min_zoom, max_zoom)
    
    if new_zoom != current_zoom:
        current_zoom = new_zoom
        camera.zoom = Vector2(new_zoom, new_zoom)
        zoom_changed.emit(new_zoom)
        print("[CameraController] Zoom: %.2f" % new_zoom)

## Définit le zoom directement
func set_zoom(zoom_value: float) -> void:
    var camera = _get_camera()
    if not camera:
        return
    
    current_zoom = clamp(zoom_value, min_zoom, max_zoom)
    camera.zoom = Vector2(current_zoom, current_zoom)
    zoom_changed.emit(current_zoom)

## Démarre le drag de la caméra
func start_drag(mouse_pos: Vector2) -> void:
    var camera = _get_camera()
    if not camera:
        return
    
    is_dragging = true
    drag_start_pos = mouse_pos
    is_following = false
    print("[CameraController] Début drag")

## Met à jour le drag de la caméra
func update_drag(mouse_pos: Vector2) -> void:
    var camera = _get_camera()
    if not camera or not is_dragging:
        return
    
    var delta_pos = (drag_start_pos - mouse_pos) / current_zoom
    var new_pos = camera.global_position + delta_pos
    new_pos = _clamp_to_bounds(new_pos)
    
    camera.global_position = new_pos
    drag_start_pos = mouse_pos
    camera_moved.emit(new_pos)

## Arrête le drag de la caméra
func stop_drag() -> void:
    if is_dragging:
        is_dragging = false
        print("[CameraController] Fin drag")

## Définit les limites du monde
func set_world_bounds(bounds: Rect2) -> void:
    world_bounds = bounds
    print("[CameraController] Nouvelles bounds: %s" % bounds)

## Définit les limites de zoom
func set_zoom_limits(p_min: float, p_max: float) -> void:
    min_zoom = p_min
    max_zoom = p_max
    current_zoom = clamp(current_zoom, min_zoom, max_zoom)
    print("[CameraController] Limites zoom: %.2f - %.2f" % [min_zoom, max_zoom])

## Définit la vitesse de suivi
func set_follow_speed(speed: float) -> void:
    follow_speed = speed

## Secoue la caméra (pour les impacts, etc.)
func shake(intensity: float, duration: float) -> void:
    var camera = _get_camera()
    if not camera:
        return
    
    # Note: Nécessite un Tween, à implémenter si besoin
    print("[CameraController] Shake: intensité=%.2f, durée=%.2f" % [intensity, duration])

## Récupère la caméra depuis la WeakRef
func _get_camera() -> Camera2D:
    if camera_ref:
        var cam = camera_ref.get_ref()
        if cam and is_instance_valid(cam):
            return cam
    return null

## Limite la position de la caméra aux bounds du monde
func _clamp_to_bounds(pos: Vector2) -> Vector2:
    if world_bounds.has_area():
        return Vector2(
            clamp(pos.x, world_bounds.position.x, world_bounds.end.x),
            clamp(pos.y, world_bounds.position.y, world_bounds.end.y)
        )
    return pos

## Getters
func get_current_zoom() -> float:
    return current_zoom

func get_camera_position() -> Vector2:
    var camera = _get_camera()
    if camera:
        return camera.global_position
    return Vector2.ZERO

func is_camera_following() -> bool:
    return is_following

func is_camera_dragging() -> bool:
    return is_dragging
