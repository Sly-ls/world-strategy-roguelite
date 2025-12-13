# res://scripts/events/WorldEvent.gd
extends Resource
class_name WorldEvent

@export var id: String = ""           # ex: "town_arrival"
@export var title: String = ""        # ex: "Ville"
@export var body: String = ""         # texte affiché
@export var choices: Array[WorldEventChoice] = []  # la liste des boutons

# Script qui contiendra la logique de cet event
@export var logic_script: Script      # ex: res://scripts/events/TownArrivalHandler.gd
