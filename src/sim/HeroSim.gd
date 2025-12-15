extends Node
class_name HeroSim

@export var heroes: Array[HeroAgent] = []
@export var max_offers_taken_per_day: int = 2
@export var take_chance: float = 0.35 # chance qu'un héro prenne une offer donnée

func tick_day() -> void:
    if heroes.is_empty():
        return
    if QuestOfferSim == null:
        return

    # On ne travaille que sur des offers "disponibles"
    var available :Array[QuestInstance] = QuestOfferSimRunner.get_available_offers()
    if available.is_empty():
        return

    var taken := 0
    available.shuffle()

    for offer in available:
        if QuestOfferSimRunner.is_consumed(offer.runtime_id):
            continue
        if taken >= max_offers_taken_per_day:
            break
        if randf() > take_chance:
            continue

        var hero :HeroAgent = heroes.pick_random()
        if hero == null:
            continue

        _take_offer(hero, offer)
        taken += 1

func _take_offer(hero: HeroAgent, q: QuestInstance) -> void:
    # marque l'offer comme prise + retire du pool
    QuestOfferSimRunner.consume_offer(q.runtime_id, hero.id)

    # simule résultat
    var ok := hero.roll_success(q)

    if not ok:
        print("🗡️ Hero %s échoue: %s" % [hero.name, q.template.title])
        # tu peux appliquer des effets d'échec plus tard
        return

    # succès → résolution
    var choice := hero.pick_resolution_choice(q)

    print("🏇 Hero %s prend '%s' → %s" % [hero.name, q.template.title, choice])

    # On veut appliquer le même pipeline que le joueur :
    QuestManager.start_runtime_quest(q)     # met dans active_quests
    QuestManager.resolve_quest(q.runtime_id, choice) # applique tags/relations/rewards selon palier2
