# res://src/quests/core/QuestTemplateAdvanced.gd
extends QuestTemplate
class_name QuestTemplateAdvanced

## Template de quête avancé avec objectifs multiples et branches
## PALIER 3 : Quêtes complexes, non-linéaires

# ========================================
# OBJECTIFS MULTIPLES
# ========================================

@export var objectives: Array[QuestObjective] = []  ## Liste d'objectifs

@export var completion_mode: CompletionMode = CompletionMode.ALL_OBJECTIVES

enum CompletionMode {
    ALL_OBJECTIVES,        ## Tous les objectifs requis
    ANY_OBJECTIVE,         ## Au moins un objectif
    MAIN_OBJECTIVES_ONLY,  ## Seulement les objectifs non-optionnels
    PERCENTAGE_BASED       ## X% des objectifs (utiliser completion_threshold)
}

@export var completion_threshold: float = 0.75  ## % requis si PERCENTAGE_BASED (0.0-1.0)

# ========================================
# BRANCHES
# ========================================

@export var branches: Array[QuestBranch] = []  ## Branches de la quête

@export var has_branches: bool = false  ## Cette quête a-t-elle des branches ?

# ========================================
# IMPACT MONDE
# ========================================

@export var world_impact: Dictionary = {}  ## Impact sur le monde
# Ex: {
#   "unlocks_poi": [{"type": TOWN, "pos": Vector2i(10, 10)}],
#   "removes_poi": [Vector2i(5, 5)],
#   "changes_faction_ownership": {"poi_id": "town_1", "new_owner": "elves"}
# }

@export var unlocks_poi_types: Array[TilesEnums.CellType] = []  ## Débloque ces types de POI
@export var removes_poi_at: Array[Vector2i] = []  ## Supprime POI à ces positions

# ========================================
# TIMER URGENT
# ========================================

@export var is_urgent: bool = false  ## Quête urgente avec timer
@export var urgent_hours: int = 0  ## Heures avant expiration (si urgent)
@export var urgent_penalty: Dictionary = {}  ## Pénalités si temps écoulé
# Ex: {"gold": -100, "faction_relation": {"humans": -25}}

# ========================================
# MÉTHODES - OBJECTIFS
# ========================================

func get_objective_by_id(objective_id: String) -> QuestObjective:
    """Récupère un objectif par son ID"""
    for obj in objectives:
        if obj.id == objective_id:
            return obj
    return null

func get_all_objectives() -> Array[QuestObjective]:
    """Retourne tous les objectifs"""
    return objectives.duplicate()

func get_active_objectives() -> Array[QuestObjective]:
    """Retourne les objectifs actifs"""
    var active: Array[QuestObjective] = []
    for obj in objectives:
        if obj.is_active():
            active.append(obj)
    return active

func get_completed_objectives() -> Array[QuestObjective]:
    """Retourne les objectifs complétés"""
    var completed: Array[QuestObjective] = []
    for obj in objectives:
        if obj.is_completed():
            completed.append(obj)
    return completed

func get_main_objectives() -> Array[QuestObjective]:
    """Retourne les objectifs principaux (non-optionnels)"""
    var main: Array[QuestObjective] = []
    for obj in objectives:
        if not obj.is_optional:
            main.append(obj)
    return main

func get_optional_objectives() -> Array[QuestObjective]:
    """Retourne les objectifs optionnels"""
    var optional: Array[QuestObjective] = []
    for obj in objectives:
        if obj.is_optional:
            optional.append(obj)
    return optional

func is_quest_complete() -> bool:
    """Vérifie si la quête est complétée selon completion_mode"""
    match completion_mode:
        CompletionMode.ALL_OBJECTIVES:
            return _check_all_objectives_complete()
        
        CompletionMode.ANY_OBJECTIVE:
            return _check_any_objective_complete()
        
        CompletionMode.MAIN_OBJECTIVES_ONLY:
            return _check_main_objectives_complete()
        
        CompletionMode.PERCENTAGE_BASED:
            return _check_percentage_complete()
    
    return false

func _check_all_objectives_complete() -> bool:
    for obj in objectives:
        if not obj.is_optional and not obj.is_completed():
            return false
    return true

func _check_any_objective_complete() -> bool:
    for obj in objectives:
        if obj.is_completed():
            return true
    return false

func _check_main_objectives_complete() -> bool:
    var main := get_main_objectives()
    for obj in main:
        if not obj.is_completed():
            return false
    return true

func _check_percentage_complete() -> bool:
    var total := objectives.size()
    if total == 0:
        return true
    
    var completed := get_completed_objectives().size()
    var percentage := float(completed) / float(total)
    
    return percentage >= completion_threshold

# ========================================
# MÉTHODES - BRANCHES
# ========================================

func get_branch_by_id(branch_id: String) -> QuestBranch:
    """Récupère une branche par son ID"""
    for branch in branches:
        if branch.id == branch_id:
            return branch
    return null

func get_active_branch() -> QuestBranch:
    """Retourne la branche active (déclenchée mais pas encore choisie)"""
    for branch in branches:
        if branch.is_triggered and branch.chosen_option == -1:
            return branch
    return null

func get_available_branches() -> Array[QuestBranch]:
    """Retourne les branches prêtes à être déclenchées"""
    var available: Array[QuestBranch] = []
    for branch in branches:
        if not branch.is_triggered and branch.check_trigger_conditions():
            available.append(branch)
    return available

# ========================================
# IMPACT MONDE
# ========================================

func apply_world_impact() -> void:
    """Applique l'impact sur le monde"""
    if world_impact.is_empty():
        return
    
    # Débloquer POI
    if world_impact.has("unlocks_poi"):
        var unlocks: Array = world_impact["unlocks_poi"]
        for unlock_data in unlocks:
            _unlock_poi(unlock_data)
    
    # Supprimer POI
    if world_impact.has("removes_poi"):
        var removes: Array = world_impact["removes_poi"]
        for pos in removes:
            _remove_poi(pos)
    
    # Changer ownership
    if world_impact.has("changes_faction_ownership"):
        var changes: Dictionary = world_impact["changes_faction_ownership"]
        _change_faction_ownership(changes)
    
    print("🌍 Impact monde appliqué pour quête : %s" % title)

func _unlock_poi(data: Dictionary) -> void:
    """Débloque un POI"""
    # TODO: Intégration avec WorldMapController
    print("  → POI débloqué : %s à %s" % [data.get("type"), data.get("pos")])

func _remove_poi(pos: Vector2i) -> void:
    """Supprime un POI"""
    # TODO: Intégration avec WorldMapController
    print("  → POI supprimé à : %s" % pos)

func _change_faction_ownership(changes: Dictionary) -> void:
    """Change l'ownership d'un POI"""
    # TODO: Intégration avec WorldMapController
    print("  → Ownership changé : %s → %s" % [changes.get("poi_id"), changes.get("new_owner")])

# ========================================
# TIMER URGENT
# ========================================

func get_urgent_deadline() -> int:
    """Retourne le timestamp de deadline si urgent"""
    if not is_urgent or urgent_hours <= 0:
        return -1
    
    # TODO: Implémenter système d'heures si nécessaire
    # Pour l'instant, convertir en jours
    var urgent_days := int(ceil(float(urgent_hours) / 24.0))
    return WorldState.current_day + urgent_days

func apply_urgent_penalty() -> void:
    """Applique la pénalité si temps écoulé"""
    if urgent_penalty.is_empty():
        return
    
    if urgent_penalty.has("gold"):
        var gold_loss: int = urgent_penalty["gold"]
        ResourceManager.remove_resource("gold", abs(gold_loss))
    
    if urgent_penalty.has("faction_relation"):
        var relations: Dictionary = urgent_penalty["faction_relation"]
        for faction_id in relations:
            var change: int = relations[faction_id]
            FactionManager.adjust_relation(faction_id, change)
    
    print("⚠️ Pénalité appliquée pour quête urgente échouée : %s" % title)

# ========================================
# VALIDATION
# ========================================

func validate() -> bool:
    """Vérifie que le template est valide"""
    if objectives.is_empty():
        push_error("QuestTemplateAdvanced: No objectives defined")
        return false
    
    # Vérifier IDs uniques
    var obj_ids := {}
    for obj in objectives:
        if obj.id.is_empty():
            push_error("QuestTemplateAdvanced: Objective without ID")
            return false
        if obj_ids.has(obj.id):
            push_error("QuestTemplateAdvanced: Duplicate objective ID: %s" % obj.id)
            return false
        obj_ids[obj.id] = true
    
    # Vérifier branches
    if has_branches:
        var branch_ids := {}
        for branch in branches:
            if branch.id.is_empty():
                push_error("QuestTemplateAdvanced: Branch without ID")
                return false
            if branch_ids.has(branch.id):
                push_error("QuestTemplateAdvanced: Duplicate branch ID: %s" % branch.id)
                return false
            branch_ids[branch.id] = true
    
    return true

# ========================================
# DESCRIPTION
# ========================================

func get_full_description() -> String:
    """Génère une description complète avec objectifs"""
    var desc := description + "\n\n"
    
    desc += "Objectifs :\n"
    for obj in objectives:
        var icon := "  •"
        if obj.is_optional:
            icon = "  ◦"
        desc += "%s %s\n" % [icon, obj.title]
    
    return desc
