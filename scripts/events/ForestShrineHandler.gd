# res://scripts/events/ForestShrineHandler.gd
extends WorldEventHandler

func execute_choice(choice_id: String, world_controller: Node) -> void:
    match choice_id:
        "shrine_rest":
            _do_shrine_rest(world_controller)
        "close":
            pass
        _:
            print("ForestShrineHandler: choix inconnu :", choice_id)



func _do_shrine_rest( world_controller: Node) -> void:
    print("Repos spécial au sanctuaire")
    world_controller._apply_rest_to_army(GameEnums.CellType.FOREST_SHRINE)
