# res://src/quests/QuestReward.gd
extends Resource
class_name QuestReward

## Représente une récompense de quête
## Fusion : ChatGPT (concept) + Claude (implémentation simple)

# ========================================
# PROPRIÉTÉS EXPORTÉES
# ========================================

@export var type: QuestTypes.RewardType = QuestTypes.RewardType.GOLD
@export var amount: int = 0
@export var target_id: String = ""  ## ID faction, unit, item, etc.
@export var description: String = ""

# ========================================
# MÉTHODES
# ========================================

## Obtenir une description lisible de la récompense
func get_readable_description() -> String:
    if description != "":
        return description
    
    match type:
        QuestTypes.RewardType.GOLD:
            return "+%d Or" % amount
        QuestTypes.RewardType.FOOD:
            return "+%d Nourriture" % amount
        QuestTypes.RewardType.FACTION_REP:
            var faction_name := _get_faction_name(target_id)
            var sign := "+" if amount >= 0 else ""
            return "%s%d réputation avec %s" % [sign, amount, faction_name]
        QuestTypes.RewardType.TAG_PLAYER:
            return "Tag joueur : %s" % target_id
        QuestTypes.RewardType.TAG_WORLD:
            return "Tag monde : %s" % target_id
        QuestTypes.RewardType.UNIT:
            return "Nouvelle unité : %s" % target_id
        QuestTypes.RewardType.UNLOCK_POI:
            return "Débloque : %s" % target_id
        _:
            return "Récompense inconnue"

func _get_faction_name(faction_id: String) -> String:
    """Helper pour obtenir le nom d'une faction"""
    if FactionManager.has_faction(faction_id):
        return FactionManager.get_faction(faction_id).name
    return faction_id.capitalize()

## Sauvegarder l'état
func save_state() -> Dictionary:
    return {
        "type": type,
        "amount": amount,
        "target_id": target_id,
        "description": description
    }

## Charger depuis un Dictionary
static func load_from_state(data: Dictionary) -> QuestReward:
    var reward := QuestReward.new()
    reward.type = data.get("type", QuestTypes.RewardType.GOLD)
    reward.amount = data.get("amount", 0)
    reward.target_id = data.get("target_id", "")
    reward.description = data.get("description", "")
    return reward
