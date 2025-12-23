# res://src/quests/campaigns/FactionCampaign.gd
class_name FactionCampaign extends Resource

## Campagne de quêtes liée à une faction
## PALIER 4 : Chaînes de quêtes longues avec arc narratif

# ========================================
# PROPRIÉTÉS DE BASE
# ========================================

@export var id: String = ""  ## ID unique de la campagne
@export var title: String = ""  ## Ex: "Campagne du Royaume Humain"
@export var description: String = ""  ## Description de l'arc narratif
@export var lore: String = ""  ## Background et contexte

@export var faction_id: String = ""  ## Faction liée
@export var tier: QuestTypes.QuestTier = QuestTypes.QuestTier.TIER_4

# ========================================
# CHAÎNE DE QUÊTES
# ========================================

@export var quest_chain: Array[String] = []  ## IDs de quêtes dans l'ordre
# Ex: ["campaign_humans_1", "campaign_humans_2", "campaign_humans_3"]

@export var current_chapter: int = 0  ## Chapitre actuel (0 = pas commencé)
@export var max_chapters: int = 5  ## Nombre total de chapitres

# ========================================
# CONDITIONS DE DÉPART
# ========================================

@export var required_faction_relation: int = 50  ## Relation min pour démarrer
@export var required_player_tags: Array[String] = []  ## Tags requis
@export var required_world_tags: Array[String] = []  ## Tags monde requis
@export var required_day: int = 1  ## Jour minimum

# ========================================
# ÉTATS
# ========================================

enum CampaignStatus {
    LOCKED,      ## Pas encore disponible
    AVAILABLE,   ## Disponible mais pas démarrée
    IN_PROGRESS, ## En cours
    COMPLETED,   ## Complétée
    FAILED       ## Échouée
}

var status: CampaignStatus = CampaignStatus.LOCKED
var started_on_day: int = -1
var completed_on_day: int = -1

# ========================================
# RÉCOMPENSES FINALES
# ========================================

@export var final_rewards: Array[QuestReward] = []  ## Récompenses à la fin de la campagne
@export var chapter_rewards: Dictionary = {}  ## Récompenses par chapitre (chapter_num: [rewards])

# ========================================
# IMPACT MONDE FINAL
# ========================================

@export var final_world_impact: Dictionary = {}  ## Impact majeur à la fin
# Ex: {
#   "faction_becomes_ally": "humans",
#   "unlocks_region": "kingdom_capital",
#   "changes_world_state": "peace_established"
# }

# ========================================
# NARRATIF
# ========================================

@export var chapter_titles: Dictionary = {}  ## Titres de chapitres (chapter_num: title)
@export var chapter_descriptions: Dictionary = {}  ## Descriptions de chapitres

# Personnages récurrents
@export var key_characters: Array[Dictionary] = []
# Ex: [
#   {"id": "king_aldric", "name": "Roi Aldric", "role": "Dirigeant"},
#   {"id": "captain_elena", "name": "Capitaine Elena", "role": "Commandante"}
# ]

# ========================================
# MÉTHODES
# ========================================

func can_start() -> bool:
    """Vérifie si la campagne peut démarrer"""
    
    # Check status
    if status != CampaignStatus.LOCKED and status != CampaignStatus.AVAILABLE:
        return false
    
    # Check jour
    if WorldState.current_day < required_day:
        return false
    
    # Check relation faction
    # TODO may be use it later
    #if FactionManager.has_faction(faction_id):
    #    var relation := FactionManager.get_relation(faction_id)
    #    if relation < required_faction_relation:
    #        return false
    
    # Check tags joueur
    for tag in required_player_tags:
        if not QuestManager.has_player_tag(tag):
            return false
    
    # Check tags monde
    for tag in required_world_tags:
        if not QuestManager.has_world_tag(tag):
            return false
    
    return true

func start() -> void:
    """Démarre la campagne"""
    if not can_start():
        push_error("Cannot start campaign: conditions not met")
        return
    
    status = CampaignStatus.IN_PROGRESS
    started_on_day = WorldState.current_day
    current_chapter = 1
    
    print("🎬 Campagne démarrée : %s (Chapitre 1/%d)" % [title, max_chapters])
    
    # Démarrer première quête
    if not quest_chain.is_empty():
        _start_chapter_quest(0)

func _start_chapter_quest(index: int) -> void:
    """Démarre la quête d'un chapitre"""
    if index >= quest_chain.size():
        return
    
    var quest_id := quest_chain[index]
    QuestManager.start_quest(quest_id, {"campaign_id": id, "chapter": current_chapter})

func advance_chapter() -> void:
    """Passe au chapitre suivant"""
    if current_chapter >= max_chapters:
        complete()
        return
    
    # Appliquer récompenses du chapitre
    if chapter_rewards.has(current_chapter):
        var rewards: Array = chapter_rewards[current_chapter]
        for reward in rewards:
            _apply_reward(reward)
    
    current_chapter += 1
    
    if current_chapter <= max_chapters:
        print("📖 Chapitre %d/%d : %s" % [
            current_chapter,
            max_chapters,
            get_chapter_title(current_chapter)
        ])
        
        # Démarrer quête suivante
        _start_chapter_quest(current_chapter - 1)
    else:
        complete()

func complete() -> void:
    """Complète la campagne"""
    status = CampaignStatus.COMPLETED
    completed_on_day = WorldState.current_day
    
    print("🏆 Campagne complétée : %s" % title)
    
    # Appliquer récompenses finales
    for reward in final_rewards:
        _apply_reward(reward)
    
    # Appliquer impact monde
    _apply_final_world_impact()

func fail() -> void:
    """Fait échouer la campagne"""
    status = CampaignStatus.FAILED
    print("✗ Campagne échouée : %s" % title)

func _apply_reward(reward: QuestReward) -> void:
    """Applique une récompense"""
    match reward.type:
        QuestTypes.RewardType.GOLD:
            ResourceManager.add_resource("gold", reward.amount)
        QuestTypes.RewardType.FOOD:
            ResourceManager.add_resource("food", reward.amount)
        QuestTypes.RewardType.FACTION_REP:
            if reward.target_id:
                FactionManager.adjust_relation(reward.target_id, reward.amount)
        QuestTypes.RewardType.TAG_PLAYER:
            QuestManager.add_player_tag(reward.target_id)
        QuestTypes.RewardType.TAG_WORLD:
            QuestManager.add_world_tag(reward.target_id)

func _apply_final_world_impact() -> void:
    """Applique l'impact monde final"""
    if final_world_impact.is_empty():
        return
    
    print("🌍 Impact monde de la campagne appliqué")
    
    # Alliance faction
    if final_world_impact.has("faction_becomes_ally"):
        var faction_id_str: String = final_world_impact["faction_becomes_ally"]
        FactionManager.adjust_relation(faction_id_str, 100)  # Relation maximale
        QuestManager.add_world_tag("allied_with_%s" % faction_id_str)
    
    # Débloquer région
    if final_world_impact.has("unlocks_region"):
        var region: String = final_world_impact["unlocks_region"]
        QuestManager.add_world_tag("region_unlocked_%s" % region)
    
    # Changer état monde
    if final_world_impact.has("changes_world_state"):
        var state: String = final_world_impact["changes_world_state"]
        QuestManager.add_world_tag(state)

# ========================================
# QUERIES
# ========================================

func is_locked() -> bool:
    return status == CampaignStatus.LOCKED

func is_available() -> bool:
    return status == CampaignStatus.AVAILABLE

func is_in_progress() -> bool:
    return status == CampaignStatus.IN_PROGRESS

func is_completed() -> bool:
    return status == CampaignStatus.COMPLETED

func is_failed() -> bool:
    return status == CampaignStatus.FAILED

func get_progress_percent() -> float:
    if max_chapters == 0:
        return 0.0
    return (float(current_chapter) / float(max_chapters)) * 100.0

func get_chapter_title(chapter: int) -> String:
    return chapter_titles.get(chapter, "Chapitre %d" % chapter)

func get_chapter_description(chapter: int) -> String:
    return chapter_descriptions.get(chapter, "")

func get_current_quest_id() -> String:
    """Retourne l'ID de la quête du chapitre actuel"""
    if current_chapter <= 0 or current_chapter > quest_chain.size():
        return ""
    return quest_chain[current_chapter - 1]

func get_character_info(character_id: String) -> Dictionary:
    """Retourne les infos d'un personnage"""
    for character in key_characters:
        if character.get("id") == character_id:
            return character
    return {}

# ========================================
# PERSISTANCE
# ========================================

func save_state() -> Dictionary:
    return {
        "id": id,
        "status": status,
        "current_chapter": current_chapter,
        "started_on_day": started_on_day,
        "completed_on_day": completed_on_day
    }

static func load_from_state(campaign: FactionCampaign, data: Dictionary) -> void:
    campaign.status = data.get("status", CampaignStatus.LOCKED)
    campaign.current_chapter = data.get("current_chapter", 0)
    campaign.started_on_day = data.get("started_on_day", -1)
    campaign.completed_on_day = data.get("completed_on_day", -1)
