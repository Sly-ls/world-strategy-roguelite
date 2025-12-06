extends WorldEventHandler
class_name RuinsQuestStartHandler

func execute_choice(choice_id: String, world_controller: Node) -> void:
    match choice_id:
        "take_quest":
            var poi_pos :Vector2 = WorldState.army_grid_pos
            QuestManager.start_quest("ruins_artifact_1", {
                "poi_pos": poi_pos
            })
            print("✓ Quête 'L'Artefact des Ruines Anciennes' acceptée !")
