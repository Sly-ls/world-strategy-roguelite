# res://scripts/events/WorldEventHandler.gd
extends RefCounted
class_name WorldEventHandler

# world_controller = WorldMapController (ou ce qui gère la world map)
func execute_choice(choice_id: String, world_controller: Node) -> void:
    # Par défaut ne fait rien
    pass
