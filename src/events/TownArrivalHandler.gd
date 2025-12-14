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
    world_controller._apply_rest_to_army(TilesEnums.CellType.TOWN)

func execute_choice_new(choice_id: String, world_controller: Node) -> void:
    """Gère les choix de l'événement d'arrivée en ville"""

    print("[TownArrivalHandler] Choix: %s" % choice_id)
    
    match choice_id:
        "enter_town":
            # Le joueur entre en ville
            WorldState.add_gold(50)
            QuestManager.add_player_tag("visited_town")
            print("  → Entrée en ville. +50 gold")
            
            # Déclenche quête si première visite
            if not QuestManager.has_player_tag("first_town_visited"):
                QuestManager.add_player_tag("first_town_visited")
                QuestManager.start_quest("tutorial_town")
                print("  → Quête tutoriel démarrée")
        
        "rest_outside":
            # Le joueur campe à l'extérieur
            var player_army = WorldState.player_army
            if player_army:
                player_army.rest(TilesEnums.CellType.PLAINE)
                print("  → Repos à l'extérieur")
        
        "trade":
            # Le joueur veut commercer
            if WorldState.gold >= 10:
                WorldState.add_gold(-10)
                WorldState.add_food(30)
                print("  → Commerce: -10 gold, +30 nourriture")
            else:
                print("  → Pas assez d'or pour commercer")
        
        "recruit":
            # Le joueur recrute des unités
            if WorldState.gold >= 100:
                WorldState.add_gold(-100)
                _recruit_unit(world_controller)
                print("  → Recrutement: -100 gold, +1 unité")
            else:
                print("  → Pas assez d'or pour recruter")
        
        "leave":
            # Le joueur part sans rien faire
            print("  → Départ sans interaction")

func _recruit_unit(world_controller: Node) -> void:
    """Recrute une unité dans l'armée du joueur"""
    var player_army = WorldState.player_army
    if not player_army:
        return
    
    # Trouve un slot vide
    for i in range(player_army.ARMY_SIZE):
        if player_army.get_unit_at_index(i) == null:
            # Crée nouvelle unité
            var new_unit = UnitData.new()
            new_unit.unit_name = "Recrue"
            new_unit.max_hp = 50
            new_unit.current_hp = 50
            new_unit.attack = 5
            new_unit.defense = 3
            player_army.set_unit_at_index(i, new_unit)
            break
