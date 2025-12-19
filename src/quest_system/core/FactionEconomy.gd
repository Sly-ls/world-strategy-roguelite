# FactionEconomy.gd
class_name FactionEconomy
extends RefCounted

var gold: int = 0
var reserved_by_quest: Dictionary[StringName, int] = {} # runtime_id -> amount

func _init(p_gold: int = 100):
    gold = p_gold
    
func available_gold() -> int:
    var reserved := 0
    for k in reserved_by_quest.keys():
        reserved += int(reserved_by_quest[k])
    return gold - reserved

func can_reserve(amount: int) -> bool:
    return amount > 0 and available_gold() >= amount

func reserve_for_quest(quest_runtime_id: StringName, amount: int) -> bool:
    if not can_reserve(amount):
        return false
    reserved_by_quest[quest_runtime_id] = amount
    return true

func release_reservation(quest_runtime_id: StringName) -> void:
    reserved_by_quest.erase(quest_runtime_id)

func payout_reserved(quest_runtime_id: StringName, amount_override: int = -1) -> int:
    # Déduit réellement l’or du trésor, en consommant la réservation.
    var reserved := int(reserved_by_quest.get(quest_runtime_id, 0))
    var amount :int = reserved if amount_override < 0 else min(reserved, amount_override)
    if amount <= 0:
        return 0
    gold -= amount
    reserved_by_quest.erase(quest_runtime_id)
    return amount
