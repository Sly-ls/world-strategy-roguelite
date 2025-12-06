# res://scripts/events/RuinsExploreHandler.gd
extends WorldEventHandler

func execute_choice(choice_id: String, world_controller: Node) -> void:
    match choice_id:
        "ruins_explore":
            if not QuestManager.has_active_quest("ruins_artifact_1"):
                var poi_pos :Vector2 = world_controller.army_grid_pos  # ou autre méthode pour avoir la position
                QuestManager.start_quest("ruins_artifact_1", {
                    "poi_pos": poi_pos,
                    "poi_id": "ruins_%d_%d" % [poi_pos.x, poi_pos.y]
                })
            _do_ruins_explore(world_controller)
        "close":
            pass
        _:
            print("RuinsExploreHandler: choix inconnu :", choice_id)



func _do_ruins_explore(world_controller: Node) -> void:
    print("Exploration des ruines → combat")

    # 1) Récupérer l'armée du joueur
    var player_army := WorldState.player_army

    # 2) Fabriquer une armée ennemie simple
    var enemy_army :ArmyData = ArmyFactory.create_army("ruinsGuardianArmy")

    # 3) Stocker dans GlobalState
    WorldState.player_army = player_army
    WorldState.enemy_army = enemy_army
    WorldState.last_battle_result = ""

    # 4) Lancer la scène de combat
    var tree := world_controller.get_tree()
    tree.change_scene_to_file("res://scenes/CombatScene.tscn")
