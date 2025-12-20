# res://src/quests/QuestTypes.gd
extends Resource
class_name QuestTypes

## Enums centralisés pour le système de quêtes
## Fusion ChatGPT (Tiers, Tags) + Claude (simplicité)

# ========================================
# CATÉGORIES DE QUÊTES
# ========================================

enum QuestCategory {
    LOCAL_POI,      ## Quête liée à un POI spécifique
    EXPLORATION,    ## Quête d'exploration
    COMBAT,         ## Quête de combat
    SURVIVAL,       ## Quête de survie
    DIPLOMATIC,     ## Quête diplomatique (relations factions)
    DELIVERY,       ## Quête de livraison
    WORLD_EVENT,     ## Quête liée à un événement mondial
    COALITION,
    DOMESTIC,
    ARC
}

# ========================================
# TIERS DE QUÊTES (de ChatGPT)
# ========================================

enum QuestTier {
    TIER_1 = 1,  ## Quête simple locale
    TIER_2 = 2,  ## Quête régionale
    TIER_3 = 3,  ## Quête importante
    TIER_4 = 4,  ## Crise majeure
    TIER_5 = 5   ## Apocalypse
}

# ========================================
# STATUTS DE QUÊTES
# ========================================

enum QuestStatus {
    AVAILABLE,   ## Peut être démarrée
    ACTIVE,      ## En cours
    COMPLETED,   ## Terminée avec succès
    FAILED,      ## Échouée
    EXPIRED      ## Expirée (temps écoulé)
}

# ========================================
# TYPES D'OBJECTIFS
# ========================================

enum ObjectiveType {
    CUSTOM,
    REACH_POI,          ## Aller à un POI spécifique
    CLEAR_COMBAT,       ## Gagner un combat
    SURVIVE_DAYS,       ## Survivre X jours
    MAKE_CHOICE,        ## Faire un choix dans un event
    COLLECT_RESOURCE,   ## Collecter X ressources
    FACTION_RELATION,   ## Atteindre relation X avec faction
    DELIVER_ITEM,       ## Livrer un objet à un POI
    EXPLORE_AREA,       ## Explorer une zone
    LOOT_ITEM,
    EXPLORE_POI,
    TALK_TO_NPC,
    DELIVER_RESOURCES,
    COLLECT_RESOURCES,
    REACH_LOCATION,
    DEFEAT_ENEMIES,
    COALITION,
    GENERIC
    
}

# ========================================
# TYPES DE RÉCOMPENSES
# ========================================

enum RewardType {
    GOLD,           ## Or
    FOOD,           ## Nourriture
    UNIT,           ## Nouvelle unité
    ITEM,           ## Objet (futur)
    FACTION_REP,    ## Réputation faction
    UNLOCK_POI,     ## Débloque un POI
    TAG_PLAYER,     ## Ajoute un tag au joueur
    TAG_WORLD,      ## Ajoute un tag au monde
    BUFF,           ## Buff temporaire (futur)
    XP              ## Expérience (futur)
}

# ========================================
# HELPER FUNCTIONS
# ========================================

## Obtenir le nom d'un tier
static func get_tier_name(tier: QuestTier) -> String:
    match tier:
        QuestTier.TIER_1: return "Simple"
        QuestTier.TIER_2: return "Régionale"
        QuestTier.TIER_3: return "Importante"
        QuestTier.TIER_4: return "Crise Majeure"
        QuestTier.TIER_5: return "Apocalypse"
        _: return "Inconnue"

## Obtenir la couleur d'un tier
static func get_tier_color(tier: QuestTier) -> Color:
    match tier:
        QuestTier.TIER_1: return Color(0.7, 0.7, 0.7)  # Gris
        QuestTier.TIER_2: return Color(0.3, 0.8, 0.3)  # Vert
        QuestTier.TIER_3: return Color(0.3, 0.5, 1.0)  # Bleu
        QuestTier.TIER_4: return Color(0.8, 0.3, 0.8)  # Violet
        QuestTier.TIER_5: return Color(1.0, 0.3, 0.3)  # Rouge
        _: return Color.WHITE

## Obtenir le nom d'une catégorie
static func get_category_name(category: QuestCategory) -> String:
    match category:
        QuestCategory.LOCAL_POI: return "POI Local"
        QuestCategory.EXPLORATION: return "Exploration"
        QuestCategory.COMBAT: return "Combat"
        QuestCategory.SURVIVAL: return "Survie"
        QuestCategory.DIPLOMATIC: return "Diplomatique"
        QuestCategory.DELIVERY: return "Livraison"
        QuestCategory.WORLD_EVENT: return "Événement Mondial"
        _: return "Inconnue"

## Obtenir le nom d'un objectif
static func get_objective_name(obj_type: ObjectiveType) -> String:
    match obj_type:
        ObjectiveType.REACH_POI: return "Atteindre un lieu"
        ObjectiveType.CLEAR_COMBAT: return "Gagner un combat"
        ObjectiveType.SURVIVE_DAYS: return "Survivre"
        ObjectiveType.MAKE_CHOICE: return "Faire un choix"
        ObjectiveType.COLLECT_RESOURCE: return "Collecter"
        ObjectiveType.FACTION_RELATION: return "Relation faction"
        ObjectiveType.DELIVER_ITEM: return "Livrer"
        ObjectiveType.EXPLORE_AREA: return "Explorer"
        _: return "Inconnu"
