# res://scripts/events/WorldEventHandler.gd
extends RefCounted
class_name WorldEventHandler

func initialize(event: WorldEvent, world_controller: Node) -> void:
    """
    Appelé quand l'événement démarre
    Override dans handlers spécifiques pour setup initial
    """
    pass

func execute_choice(choice_id: String, world_controller: Node) -> void:
    """
    Appelé quand le joueur fait un choix
    Override dans handlers spécifiques pour logique de choix

    Args:
    choice_id: ID du choix fait par le joueur
    world_controller: Référence au WorldMapController
    """
    pass

func cleanup() -> void:
    """
    Appelé à la fin de l'événement
    Override pour cleanup si nécessaire
    """
    pass

# ========================================
# EXEMPLES D'UTILISATION
# ========================================

# OPTION 1 : Handler Simple (RefCounted)
# ---------------------------------------
# class TownArrivalHandler extends WorldEventHandler:
#     func execute_choice(choice_id: String, world_controller: Node):
#         match choice_id:
#             "enter_town":
#                 WorldState.add_gold(50)
#                 print("Bienvenue en ville!")
#             "pass_by":
#                 print("Vous passez votre chemin")

# OPTION 2 : Handler avec Node
# ---------------------------------------
# Crée une classe héritant de Node au lieu de WorldEventHandler
# class ComplexEventHandler extends Node:
#     func initialize(event, world_controller):
#         # Setup UI, animations, etc.
#     func handle_choice(choice_idx: int):
#         # Logique complexe
