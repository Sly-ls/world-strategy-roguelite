# res://src/quests/QuestTemplate.gd
extends Resource
class_name QuestTemplate

## Template de quête (archétype)
## FUSION : Structure simple (Claude) + Tiers/Tags (ChatGPT)

# ========================================
# IDENTIFICATION
# ========================================

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

# ========================================
# CLASSIFICATION (de ChatGPT)
# ========================================

@export var category: QuestTypes.QuestCategory = QuestTypes.QuestCategory.LOCAL_POI
@export var tier: QuestTypes.QuestTier = QuestTypes.QuestTier.TIER_1

# ========================================
# CONDITIONS D'APPARITION
# ========================================

@export_group("Conditions")
@export var required_day: int = 0                      ## Jour minimum
@export var required_poi_type: GameEnums.CellType = GameEnums.CellType.PLAINE
@export var required_player_tags: Array[String] = []   ## Tags joueur requis (de ChatGPT)
@export var required_world_tags: Array[String] = []    ## Tags monde requis (de ChatGPT)
@export var forbidden_player_tags: Array[String] = []  ## Tags joueur interdits
@export var min_faction_relation: Dictionary = {}      ## { "faction_id": min_value }

# ========================================
# OBJECTIF (Palier 1 : un seul objectif simple)
# ========================================

@export_group("Objectif")
@export var objective_type: QuestTypes.ObjectiveType = QuestTypes.ObjectiveType.REACH_POI
@export var objective_target: String = ""              ## ID du POI, faction, etc.
@export var objective_count: int = 1                   ## Nombre requis
@export_multiline var objective_description: String = ""

# ========================================
# RÉCOMPENSES
# ========================================

@export_group("Récompenses")
@export var rewards: Array[QuestReward] = []

# ========================================
# TAGS (de ChatGPT)
# ========================================

@export_group("Tags")
@export var adds_player_tags: Array[String] = []       ## Tags ajoutés au joueur
@export var adds_world_tags: Array[String] = []        ## Tags ajoutés au monde

# ========================================
# EXPIRATION
# ========================================

@export_group("Expiration")
@export var expires_in_days: int = -1                  ## -1 = jamais

# ========================================
# CHAÎNAGE (de ChatGPT - pour Palier 2+)
# ========================================

@export_group("Chaînage")
@export var completion_event_id: String = ""           ## Event déclenché à la fin
@export var next_quest_id: String = ""                 ## Quête suivante (chaîne)

# ========================================
# MÉTHODES
# ========================================

## Vérifie si la quête peut apparaître
func can_appear() -> bool:
    # Jour minimum
    if WorldState.current_day < required_day:
        return false
    
    # Tags joueur requis
    for tag in required_player_tags:
        if not QuestManager.has_player_tag(tag):
            return false
    
    # Tags joueur interdits
    for tag in forbidden_player_tags:
        if QuestManager.has_player_tag(tag):
            return false
    
    # Tags monde requis
    for tag in required_world_tags:
        if not QuestManager.has_world_tag(tag):
            return false
    
    # Relations faction minimales
    for faction_id in min_faction_relation:
        var min_rel: int = min_faction_relation[faction_id]
        if FactionManager.get_relation(faction_id) < min_rel:
            return false
    
    return true

## Obtenir la description complète de l'objectif
func get_objective_description() -> String:
    if objective_description != "":
        return objective_description
    
    match objective_type:
        QuestTypes.ObjectiveType.REACH_POI:
            return "Atteindre : %s" % objective_target
        QuestTypes.ObjectiveType.CLEAR_COMBAT:
            return "Gagner un combat"
        QuestTypes.ObjectiveType.SURVIVE_DAYS:
            return "Survivre %d jours" % objective_count
        QuestTypes.ObjectiveType.MAKE_CHOICE:
            return "Faire un choix"
        QuestTypes.ObjectiveType.COLLECT_RESOURCE:
            return "Collecter %d %s" % [objective_count, objective_target]
        QuestTypes.ObjectiveType.FACTION_RELATION:
            return "Atteindre %d de relation avec %s" % [objective_count, objective_target]
        QuestTypes.ObjectiveType.DELIVER_ITEM:
            return "Livrer %s" % objective_target
        _:
            return "Objectif inconnu"
