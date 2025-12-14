# res://src/sim/WorldSim.gd
extends Node
class_name WorldSim

signal day_advanced(day: int)

@export var actions_per_day: int = 3
@export var quest_offers_per_day: int = 2

func advance_day() -> void:
    WorldState.current_day += 1
    var day := WorldState.current_day
    print("\n=== DAY %d ===" % day)

    # 1) Expirations quêtes joueur
    if QuestManager:
        QuestManager.check_expirations()

    # 2) Actions factions (monde)
    FactionSimRunner.run_day(actions_per_day)

    # 3) Générer des offres de quêtes “disponibles”
    QuestOfferSimRunner.generate_offers(quest_offers_per_day)
    QuestOfferSimRunner.tick_day()
    
    # 4) Crises / événements globaux
    if CrisisManager:
        if CrisisManager.has_method("check_auto_trigger_crises"):
            CrisisManager.check_auto_trigger_crises()
        if CrisisManager.has_method("update_crisis"):
            CrisisManager.update_crisis()

    day_advanced.emit(day)

func simulate_days(n: int) -> void:
    for i in range(n):
        advance_day()
