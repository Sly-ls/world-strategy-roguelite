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
            myLogger.debug("ForestShrineHandler: choix inconnu : %s" % choice_id, LogTypes.Domain.WORLD)

    
func _do_town_rest(world_controller: Node) -> void:
    myLogger.debug("Repos spécial en ville", LogTypes.Domain.WORLD)
    world_controller._apply_rest_to_army(TilesEnums.CellType.TOWN)

func execute_choice_new(choice_id: String, world_controller: Node) -> void:
    """Gère les choix de l'événement d'arrivée en ville"""

    myLogger.debug("[TownArrivalHandler] Choix: %s" % choice_id, LogTypes.Domain.WORLD)
    
    match choice_id:
        "enter_town":
            # Le joueur entre en ville
            WorldState.add_gold(50)
            QuestManager.add_player_tag("visited_town")
            myLogger.debug("  → Entrée en ville. +50 gold", LogTypes.Domain.WORLD)
            
            # Déclenche quête si première visite
            if not QuestManager.has_player_tag("first_town_visited"):
                QuestManager.add_player_tag("first_town_visited")
                QuestManager.start_quest("tutorial_town")
                myLogger.debug("  → Quête tutoriel démarrée", LogTypes.Domain.WORLD)
        
        "rest_outside":
            # Le joueur campe à l'extérieur
            var player_army = WorldState.player_army
            if player_army:
                player_army.rest(TilesEnums.CellType.PLAINE)
                myLogger.debug("  → Repos à l'extérieur", LogTypes.Domain.WORLD)
        
        "trade":
            # Le joueur veut commercer
            if WorldState.gold >= 10:
                WorldState.add_gold(-10)
                WorldState.add_food(30)
                myLogger.debug("  → Commerce: -10 gold, +30 nourriture", LogTypes.Domain.WORLD)
            else:
                myLogger.debug("  → Pas assez d'or pour commercer", LogTypes.Domain.WORLD)
        
        "recruit":
            # Le joueur recrute des unités
            if WorldState.gold >= 100:
                WorldState.add_gold(-100)
                _recruit_unit(world_controller)
                myLogger.debug("  → Recrutement: -100 gold, +1 unité", LogTypes.Domain.WORLD)
            else:
                myLogger.debug("  → Pas assez d'or pour recruter", LogTypes.Domain.WORLD)
        
        "leave":
            # Le joueur part sans rien faire
            myLogger.debug("  → Départ sans interaction", LogTypes.Domain.WORLD)

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
