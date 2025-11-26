extends WorldEventHandler

func execute_choice(choice_id: String, world_controller: Node) -> void:
    match choice_id:
        "shrine_rest":
            _do_town_rest(world_controller)
            if world_controller.has_method("_do_shrine_rest"):
                world_controller._do_shrine_rest()
        "close":
            pass
        _:
            print("ForestShrineHandler: choix inconnu :", choice_id)

    
func _do_town_rest(world_controller: Node) -> void:
    print("Repos spécial en ville")
    world_controller._apply_rest_to_army(GameEnums.CellType.TOWN)
