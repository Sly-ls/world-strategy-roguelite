# res://src/quests/core/QuestObjective.gd
class_name QuestObjective extends Resource

## Objectif de quête avec progression individuelle
## PALIER 3 : Support objectifs multiples, optionnels, parallèles

# ========================================
# ENUMS
# ========================================

enum ObjectiveStatus {
    LOCKED,      ## Pas encore disponible
    ACTIVE,      ## En cours
    COMPLETED,   ## Complété
    FAILED,      ## Échoué
    OPTIONAL     ## Optionnel (peut être ignoré)
}

# ========================================
# PROPRIÉTÉS DE BASE
# ========================================

@export var id: String = ""  ## ID unique dans la quête
@export var title: String = ""  ## Ex: "Vaincre le boss"
@export var description: String = ""  ## Description complète

@export var objective_type: QuestTypes.ObjectiveType = QuestTypes.ObjectiveType.REACH_POI
@export var target: String = ""  ## Cible (POI type, resource, faction, etc.)
@export var count: int = 1  ## Quantité requise

# ========================================
# ÉTAT & PROGRESSION
# ========================================

@export var is_optional: bool = false  ## Peut être ignoré sans échec
@export var is_hidden: bool = false  ## Caché jusqu'à déverrouillage
@export var is_parallel: bool = true  ## Peut être fait en parallèle (vs séquentiel)

var status: ObjectiveStatus = ObjectiveStatus.LOCKED
var current_progress: int = 0  ## Progression actuelle
var completed_on_day: int = -1  ## Jour de complétion

# ========================================
# CONDITIONS DE DÉVERROUILLAGE
# ========================================

@export var unlock_conditions: Array[Dictionary] = []  ## Conditions pour débloquer cet objectif
# Ex: [{"type": "objective_completed", "objective_id": "obj1"}]
#     [{"type": "day_min", "day": 5}]

@export var required_objectives: Array[String] = []  ## IDs d'objectifs à compléter avant
@export var unlock_on_day: int = -1  ## Jour de déverrouillage automatique (-1 = immédiat)

# ========================================
# RÉCOMPENSES
# ========================================

@export var rewards: Array[QuestReward] = []  ## Récompenses pour cet objectif spécifique

# ========================================
# ÉCHEC
# ========================================

@export var can_fail: bool = false  ## Cet objectif peut-il échouer ?
@export var fail_on_day: int = -1  ## Jour limite (-1 = pas de limite)
@export var fail_conditions: Array[Dictionary] = []  ## Conditions d'échec

# ========================================
# MÉTHODES DE PROGRESSION
# ========================================

func start() -> void:
    """Démarre l'objectif"""
    status = ObjectiveStatus.ACTIVE
    current_progress = 0
    print("▸ Objectif démarré : %s" % title)

func update_progress(delta: int = 1) -> bool:
    """Met à jour la progression, retourne true si complété"""
    if status != ObjectiveStatus.ACTIVE:
        return false
    
    current_progress = mini(current_progress + delta, count)
    
    if current_progress >= count:
        complete()
        return true
    
    return false

func complete() -> void:
    """Complète l'objectif"""
    if status == ObjectiveStatus.COMPLETED:
        return
    
    status = ObjectiveStatus.COMPLETED
    current_progress = count
    completed_on_day = WorldState.current_day
    
    print("✓ Objectif complété : %s (%d/%d)" % [title, current_progress, count])

func fail() -> void:
    """Fait échouer l'objectif"""
    if not can_fail or status == ObjectiveStatus.FAILED:
        return
    
    status = ObjectiveStatus.FAILED
    print("✗ Objectif échoué : %s" % title)

func unlock() -> void:
    """Déverrouille l'objectif"""
    if status == ObjectiveStatus.LOCKED:
        status = ObjectiveStatus.ACTIVE
        print("🔓 Objectif déverrouillé : %s" % title)

# ========================================
# CHECKS
# ========================================

func check_unlock_conditions(quest_context: Dictionary) -> bool:
    """Vérifie si les conditions de déverrouillage sont remplies"""
    
    # Check jour
    if unlock_on_day > 0 and WorldState.current_day < unlock_on_day:
        return false
    
    # Check objectifs requis
    for req_id in required_objectives:
        var req_obj: QuestObjective = quest_context.get("objectives", {}).get(req_id)
        if not req_obj or req_obj.status != ObjectiveStatus.COMPLETED:
            return false
    
    # Check conditions customs
    if not unlock_conditions.is_empty():
        if not QuestConditions.check_all_conditions(unlock_conditions):
            return false
    
    return true

func check_fail_conditions() -> bool:
    """Vérifie si les conditions d'échec sont remplies"""
    if not can_fail:
        return false
    
    # Check jour limite
    if fail_on_day > 0 and WorldState.current_day >= fail_on_day:
        return true
    
    # Check conditions customs
    if not fail_conditions.is_empty():
        return QuestConditions.check_all_conditions(fail_conditions)
    
    return false

# ========================================
# QUERIES
# ========================================

func is_locked() -> bool:
    return status == ObjectiveStatus.LOCKED

func is_active() -> bool:
    return status == ObjectiveStatus.ACTIVE

func is_completed() -> bool:
    return status == ObjectiveStatus.COMPLETED

func is_failed() -> bool:
    return status == ObjectiveStatus.FAILED

func is_finished() -> bool:
    return status == ObjectiveStatus.COMPLETED or status == ObjectiveStatus.FAILED

func get_progress_percent() -> float:
    if count == 0:
        return 0.0
    return (float(current_progress) / float(count)) * 100.0

func get_progress_text() -> String:
    return "%d / %d" % [current_progress, count]

func get_days_until_fail() -> int:
    if fail_on_day < 0:
        return -1
    return fail_on_day - WorldState.current_day

# ========================================
# PERSISTANCE
# ========================================

func save_state() -> Dictionary:
    """Sauvegarde l'état de l'objectif"""
    return {
        "id": id,
        "status": status,
        "current_progress": current_progress,
        "completed_on_day": completed_on_day
    }

static func load_from_state(objective: QuestObjective, data: Dictionary) -> void:
    """Restaure l'état de l'objectif"""
    objective.status = data.get("status", ObjectiveStatus.LOCKED)
    objective.current_progress = data.get("current_progress", 0)
    objective.completed_on_day = data.get("completed_on_day", -1)

# ========================================
# DESCRIPTION LISIBLE
# ========================================

func get_readable_description() -> String:
    """Génère une description lisible de l'objectif"""
    var desc := title
    
    if is_hidden and status == ObjectiveStatus.LOCKED:
        return "???"
    
    match status:
        ObjectiveStatus.LOCKED:
            desc += " (🔒 Verrouillé)"
        ObjectiveStatus.ACTIVE:
            desc += " (%s)" % get_progress_text()
        ObjectiveStatus.COMPLETED:
            desc += " (✓ Complété)"
        ObjectiveStatus.FAILED:
            desc += " (✗ Échoué)"
    
    if is_optional:
        desc += " [Optionnel]"
    
    if can_fail and fail_on_day > 0 and status == ObjectiveStatus.ACTIVE:
        var days_left := get_days_until_fail()
        if days_left > 0:
            desc += " (%d jours restants)" % days_left
    
    return desc

func get_objective_type_name() -> String:
    """Retourne le nom du type d'objectif"""
    return QuestTypes.get_objective_name(objective_type)
