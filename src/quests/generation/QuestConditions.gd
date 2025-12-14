# res://src/quests/generation/QuestConditions.gd
extends RefCounted
class_name QuestConditions

## Système de conditions avancées pour l'apparition de quêtes
## PALIER 2 : Conditions basées sur distance, contexte, état du monde

# ========================================
# TYPES DE CONDITIONS
# ========================================

enum ConditionType {
    DISTANCE_TO_POI,          ## Distance min/max à un type de POI
    FACTION_RELATION_RANGE,   ## Relation dans une fourchette
    PLAYER_HAS_TAGS_ANY,      ## A au moins un des tags
    PLAYER_HAS_TAGS_ALL,      ## A tous les tags
    PLAYER_LACKS_TAGS,        ## N'a aucun des tags
    WORLD_HAS_TAGS,           ## Le monde a ces tags
    WORLD_LACKS_TAGS,         ## Le monde n'a pas ces tags
    RESOURCE_MIN,             ## Ressource >= X
    RESOURCE_MAX,             ## Ressource <= X
    DAY_RANGE,                ## Jour entre X et Y
    ACTIVE_QUESTS_COUNT,      ## Nombre de quêtes actives
    COMPLETED_QUEST,          ## A complété une quête spécifique
    RANDOM_CHANCE             ## Probabilité % d'apparition
}

# ========================================
# VÉRIFICATION DE CONDITIONS
# ========================================

static func check_all_conditions(conditions: Array[Dictionary]) -> bool:
    """Vérifie que toutes les conditions sont remplies"""
    for condition in conditions:
        if not check_condition(condition):
            return false
    return true

static func check_any_conditions(conditions: Array[Dictionary]) -> bool:
    """Vérifie qu'au moins une condition est remplie"""
    for condition in conditions:
        if check_condition(condition):
            return true
    return false

static func check_condition(condition: Dictionary) -> bool:
    """Vérifie une condition unique"""
    var type: ConditionType = condition.get("type", ConditionType.RANDOM_CHANCE)
    
    match type:
        ConditionType.DISTANCE_TO_POI:
            return _check_distance_to_poi(condition)
        
        ConditionType.FACTION_RELATION_RANGE:
            return _check_faction_relation_range(condition)
        
        ConditionType.PLAYER_HAS_TAGS_ANY:
            return _check_player_has_tags_any(condition)
        
        ConditionType.PLAYER_HAS_TAGS_ALL:
            return _check_player_has_tags_all(condition)
        
        ConditionType.PLAYER_LACKS_TAGS:
            return _check_player_lacks_tags(condition)
        
        ConditionType.WORLD_HAS_TAGS:
            return _check_world_has_tags(condition)
        
        ConditionType.WORLD_LACKS_TAGS:
            return _check_world_lacks_tags(condition)
        
        ConditionType.RESOURCE_MIN:
            return _check_resource_min(condition)
        
        ConditionType.RESOURCE_MAX:
            return _check_resource_max(condition)
        
        ConditionType.DAY_RANGE:
            return _check_day_range(condition)
        
        ConditionType.ACTIVE_QUESTS_COUNT:
            return _check_active_quests_count(condition)
        
        ConditionType.COMPLETED_QUEST:
            return _check_completed_quest(condition)
        
        ConditionType.RANDOM_CHANCE:
            return _check_random_chance(condition)
        
        _:
            return true

# ========================================
# IMPLÉMENTATION DES CONDITIONS
# ========================================

static func _check_distance_to_poi(condition: Dictionary) -> bool:
    """Vérifie la distance à un type de POI"""
    var poi_type: TilesEnums.CellType = condition.get("poi_type", TilesEnums.CellType.PLAINE)
    var min_distance: int = condition.get("min_distance", 0)
    var max_distance: int = condition.get("max_distance", 9999)
    
    var player_pos := WorldState.army_grid_pos
    
    # TODO: Trouver le POI du type le plus proche
    # Pour l'instant, simplifié
    return true

static func _check_faction_relation_range(condition: Dictionary) -> bool:
    """Vérifie que la relation avec une faction est dans une fourchette"""
    var faction_id: String = condition.get("faction_id", "")
    var min_relation: int = condition.get("min_relation", -100)
    var max_relation: int = condition.get("max_relation", 100)
    
    if not FactionManager.has_faction(faction_id):
        return false
    
    var relation := FactionManager.get_relation(faction_id)
    return relation >= min_relation and relation <= max_relation

static func _check_player_has_tags_any(condition: Dictionary) -> bool:
    """Vérifie que le joueur a au moins un des tags"""
    var tags: Array = condition.get("tags", [])
    
    for tag in tags:
        if QuestManager.has_player_tag(tag):
            return true
    
    return false

static func _check_player_has_tags_all(condition: Dictionary) -> bool:
    """Vérifie que le joueur a tous les tags"""
    var tags: Array = condition.get("tags", [])
    
    for tag in tags:
        if not QuestManager.has_player_tag(tag):
            return false
    
    return true

static func _check_player_lacks_tags(condition: Dictionary) -> bool:
    """Vérifie que le joueur n'a aucun des tags"""
    var tags: Array = condition.get("tags", [])
    
    for tag in tags:
        if QuestManager.has_player_tag(tag):
            return false
    
    return true

static func _check_world_has_tags(condition: Dictionary) -> bool:
    """Vérifie que le monde a les tags"""
    var tags: Array = condition.get("tags", [])
    
    for tag in tags:
        if not QuestManager.has_world_tag(tag):
            return false
    
    return true

static func _check_world_lacks_tags(condition: Dictionary) -> bool:
    """Vérifie que le monde n'a pas les tags"""
    var tags: Array = condition.get("tags", [])
    
    for tag in tags:
        if QuestManager.has_world_tag(tag):
            return false
    
    return true

static func _check_resource_min(condition: Dictionary) -> bool:
    """Vérifie qu'une ressource >= min"""
    var resource_id: String = condition.get("resource_id", "gold")
    var min_amount: int = condition.get("min_amount", 0)
    
    return ResourceManager.get_resource(resource_id) >= min_amount

static func _check_resource_max(condition: Dictionary) -> bool:
    """Vérifie qu'une ressource <= max"""
    var resource_id: String = condition.get("resource_id", "gold")
    var max_amount: int = condition.get("max_amount", 9999)
    
    return ResourceManager.get_resource(resource_id) <= max_amount

static func _check_day_range(condition: Dictionary) -> bool:
    """Vérifie que le jour est dans une fourchette"""
    var min_day: int = condition.get("min_day", 0)
    var max_day: int = condition.get("max_day", 9999)
    
    var current_day := WorldState.current_day
    return current_day >= min_day and current_day <= max_day

static func _check_active_quests_count(condition: Dictionary) -> bool:
    """Vérifie le nombre de quêtes actives"""
    var min_count: int = condition.get("min_count", 0)
    var max_count: int = condition.get("max_count", 9999)
    
    var count := QuestManager.get_active_quests().size()
    return count >= min_count and count <= max_count

static func _check_completed_quest(condition: Dictionary) -> bool:
    """Vérifie qu'une quête spécifique a été complétée"""
    var quest_id: String = condition.get("quest_id", "")
    
    for quest in QuestManager.completed_quests:
        if quest.template_id == quest_id:
            return true
    
    return false

static func _check_random_chance(condition: Dictionary) -> bool:
    """Vérifie une probabilité aléatoire"""
    var chance: float = condition.get("chance", 1.0)  # 0.0 à 1.0
    
    return randf() <= chance

# ========================================
# BUILDERS DE CONDITIONS
# ========================================

static func distance_to_poi(poi_type: TilesEnums.CellType, min_dist: int = 0, max_dist: int = 9999) -> Dictionary:
    """Crée une condition de distance à un POI"""
    return {
        "type": ConditionType.DISTANCE_TO_POI,
        "poi_type": poi_type,
        "min_distance": min_dist,
        "max_distance": max_dist
    }

static func faction_relation(faction_id: String, min_rel: int, max_rel: int = 100) -> Dictionary:
    """Crée une condition de relation faction"""
    return {
        "type": ConditionType.FACTION_RELATION_RANGE,
        "faction_id": faction_id,
        "min_relation": min_rel,
        "max_relation": max_rel
    }

static func has_player_tags(tags: Array, require_all: bool = false) -> Dictionary:
    """Crée une condition de tags joueur"""
    return {
        "type": ConditionType.PLAYER_HAS_TAGS_ALL if require_all else ConditionType.PLAYER_HAS_TAGS_ANY,
        "tags": tags
    }

static func lacks_player_tags(tags: Array) -> Dictionary:
    """Crée une condition d'absence de tags joueur"""
    return {
        "type": ConditionType.PLAYER_LACKS_TAGS,
        "tags": tags
    }

static func has_world_tags(tags: Array) -> Dictionary:
    """Crée une condition de tags monde"""
    return {
        "type": ConditionType.WORLD_HAS_TAGS,
        "tags": tags
    }

static func resource_min(resource_id: String, min_amount: int) -> Dictionary:
    """Crée une condition de ressource minimale"""
    return {
        "type": ConditionType.RESOURCE_MIN,
        "resource_id": resource_id,
        "min_amount": min_amount
    }

static func day_between(min_day: int, max_day: int) -> Dictionary:
    """Crée une condition de jour"""
    return {
        "type": ConditionType.DAY_RANGE,
        "min_day": min_day,
        "max_day": max_day
    }

static func random_chance(probability: float) -> Dictionary:
    """Crée une condition de probabilité"""
    return {
        "type": ConditionType.RANDOM_CHANCE,
        "chance": clamp(probability, 0.0, 1.0)
    }

static func completed_quest(quest_id: String) -> Dictionary:
    """Crée une condition de quête complétée"""
    return {
        "type": ConditionType.COMPLETED_QUEST,
        "quest_id": quest_id
    }
