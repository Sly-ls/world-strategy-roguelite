# res://scripts/events/ForestShrineHandler.gd
extends WorldEventHandler

func execute_choice(choice_id: String, world_controller: Node) -> void:
    match choice_id:
        "shrine_rest":
            _do_shrine_rest(world_controller)
        "hunt_goblins":
            _do_hunt_goblins(world_controller)
        "close":
            pass
        _:
            print("ForestShrineHandler: choix inconnu :", choice_id)



func _do_shrine_rest( world_controller: Node) -> void:
    print("Repos spécial au sanctuaire")
    world_controller._apply_rest_to_army(GameEnums.CellType.FOREST_SHRINE)



func _do_hunt_goblins(world_controller: Node) -> void:
    print("Exploration des ruines → combat")

    # 1) Récupérer l'armée du joueur
    var player_army := WorldState.player_army

    # 2) Fabriquer une armée ennemie simple
    var enemy_army :ArmyData = ArmyFactory.create_army("goblinScouts_army")

    # 3) Stocker dans GlobalState
    WorldState.player_army = player_army
    WorldState.enemy_army = enemy_army
    WorldState.last_battle_result = ""

    # 4) Lancer la scène de combat
    var tree := world_controller.get_tree()
    tree.change_scene_to_file("res://scenes/CombatScene.tscn")
