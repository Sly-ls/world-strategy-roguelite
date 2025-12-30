# res://src/quests/campaigns/QuestChain.gd
class_name QuestChain
extends Resource

## Chaîne de quêtes liées (Campagne)
## PALIER 3 : Progression narrative avec quêtes enchaînées

# ========================================
# PROPRIÉTÉS DE BASE
# ========================================

@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var icon: Texture2D = null

# ========================================
# RÈGLES DE GÉNÉRATION DES QUÊTES
# ========================================

## Définit comment chaque quête de la campagne est créée
## Format : Array[Dictionary] avec :
##   - "type": "manual" ou "generated"
##   - Si "manual": "template": QuestTemplate
##   - Si "generated": "poi_type": GameEnums.CellType, "complexity": "simple"|"advanced"
@export var quest_generation_rules: Array[Dictionary] = []

# Exemple :
# [
#   {"type": "manual", "template": preload("quest1.tres")},
#   {"type": "generated", "poi_type": 3, "complexity": "advanced"},
#   {"type": "manual", "template": preload("quest3.tres")}
# ]

# ========================================
# PROGRESSION
# ========================================

var current_quest_index: int = 0
var completed_quest_ids: Array[String] = []
var started_at_day: int = 0

# ========================================
# RÉCOMPENSES DE CAMPAGNE
# ========================================

@export var campaign_rewards: Array[QuestReward] = []  ## Récompenses à la fin de toute la campagne

# ========================================
# TAGS & CONDITIONS
# ========================================

@export var required_player_tags: Array[String] = []  ## Tags requis pour démarrer
@export var adds_player_tags: Array[String] = []  ## Tags ajoutés à la fin

# ========================================
# MÉTHODES PRINCIPALES
# ========================================

func get_total_quests() -> int:
    """Nombre total de quêtes dans la campagne"""
    return quest_generation_rules.size()

func get_current_quest_rule() -> Dictionary:
    """Règle de génération de la quête actuelle"""
    if current_quest_index >= quest_generation_rules.size():
        return {}
    return quest_generation_rules[current_quest_index]

func advance_to_next_quest(completed_quest_id: String) -> void:
    """Passe à la quête suivante"""
    completed_quest_ids.append(completed_quest_id)
    current_quest_index += 1
    myLogger.debug("📖 Campagne '%s': %d/%d quêtes complétées" % [title, current_quest_index, quest_generation_rules.size()], LogTypes.Domain.QUEST)

func is_complete() -> bool:
    """La campagne est-elle terminée ?"""
    return current_quest_index >= quest_generation_rules.size()

func get_progress() -> float:
    """Progression en % (0.0 à 1.0)"""
    if quest_generation_rules.size() == 0:
        return 1.0
    return float(current_quest_index) / float(quest_generation_rules.size())

func can_start() -> bool:
    """Peut-on démarrer cette campagne ?"""
    # Vérifier les tags requis
    for tag in required_player_tags:
        if not tag in QuestManager.player_tags:
            return false
    return true

func reset() -> void:
    """Réinitialise la campagne"""
    current_quest_index = 0
    completed_quest_ids.clear()
    started_at_day = 0
