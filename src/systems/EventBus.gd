extends Node

signal world_updated
signal army_updated
signal resources_changed(resource_name, new_value)
signal combat_started(enemy_data)
signal combat_ended(result_data)

func emit_world_updated():
    world_updated.emit()

func emit_army_updated():
    army_updated.emit()

func emit_resources_changed(resource_name: String, new_value: int):
    resources_changed.emit(resource_name, new_value)

func emit_combat_started(enemy_data):
    combat_started.emit(enemy_data)

func emit_combat_ended(result_data):
    combat_ended.emit(result_data)
