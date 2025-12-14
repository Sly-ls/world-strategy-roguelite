# res://src/sim/QuestOfferSim.gd
extends Node
class_name QuestOfferSim

var offers: Array[QuestInstance] = []
@export var max_offers: int = 10
var offer_created_day: Dictionary = {} # runtime_id -> day

func generate_offers(n: int) -> void:
    if QuestGenerator == null:
        return

    for i in range(n):
        var q: QuestInstance = QuestGenerator.generate_random_quest(QuestTypes.QuestTier.TIER_1)
        if q == null ||  offer_created_day.has(q.runtime_id):
            continue
        offers.append(q)


func take_offer(index: int) -> QuestInstance:
    if index < 0 or index >= offers.size():
        return null
    var q := offers[index]
    offers.remove_at(index)
    return q

func tick_day() -> void:
    # 1) Expire offers
    var day := WorldState.current_day
    var to_remove: Array[int] = []

    for i in range(offers.size()):
        var q: QuestInstance = offers[i]
        var created := int(offer_created_day.get(q.runtime_id, day))

        var expires_in := q.template.expires_in_days
        if expires_in > 0 and day >= created + expires_in:
            to_remove.append(i)

    # remove from end to start
    for j in range(to_remove.size() - 1, -1, -1):
        var idx := to_remove[j]
        var q := offers[idx]
        offer_created_day.erase(q.runtime_id)
        offers.remove_at(idx)

    # 2) Cap
    while offers.size() > max_offers:
        var removed :QuestInstance = offers.pop_front()
        offer_created_day.erase(removed.runtime_id)
