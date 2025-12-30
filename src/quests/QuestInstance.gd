# res://src/quests/QuestInstance.gd
extends RefCounted
class_name QuestInstance

## Instance runtime d'une quête active
## FUSION : Runtime de Claude + Tags de ChatGPT

# ========================================
# PROPRIÉTÉS
# ========================================

var runtime_id: String = ""                           ## UUID unique
var template_id: String = ""                          ## ID du template
var template: QuestTemplate = null                    ## Référence au template

var status: QuestTypes.QuestStatus = QuestTypes.QuestStatus.AVAILABLE
var progress: int = 0                                 ## Progression de l'objectif
var started_on_day: int = 0                           ## Jour de démarrage
var expires_on_day: int = -1                          ## Jour d'expiration (-1 = jamais)

var context: Dictionary = {}                          ## Données contextuelles

var needs_resolution: bool = false
var resolution_choice: String = "" # "LOYAL" | "NEUTRAL" | "TRAITOR"

var giver_faction_id: String = ""
var antagonist_faction_id: String = ""
var resolution_profile_id: String = ""

var owner_type: String = "PLAYER"  # "PLAYER" | "HERO" | "ARMY"
var owner_id: String = ""          # id hero/army si besoin

# ========================================
# CONSTRUCTEUR
# ========================================

func _init(_template: QuestTemplate, _context: Dictionary = {}) -> void:
    runtime_id = _generate_uuid()
    template = _template
    template_id = _template.id
    context = _context
    started_on_day = WorldState.current_day
    giver_faction_id = str(context.get("giver_faction_id", ""))
    antagonist_faction_id = str(context.get("antagonist_faction_id", ""))
    # Calculer l'expiration
    started_on_day = -1
    expires_on_day = -1
        
func _generate_uuid() -> String:
    return "quest_%d_%d" % [Time.get_ticks_msec(), randi()]

# ========================================
# GESTION DU STATUT
# ========================================
func start() -> void:
    """Démarre la quête"""
    if template.expires_in_days > 0:
        expires_on_day = started_on_day + template.expires_in_days
    status = QuestTypes.QuestStatus.ACTIVE
    myLogger.debug("✓ Quête démarrée : %s (%s)" % [template.title, QuestTypes.get_tier_name(template.tier)], LogTypes.Domain.QUEST)

func complete() -> void:
    """Termine la quête avec succès"""
    status = QuestTypes.QuestStatus.COMPLETED
    needs_resolution = true
    myLogger.debug("✓ Objectif atteint : %s (résolution requise)" % template.title, LogTypes.Domain.QUEST)

func fail() -> void:
    """Échoue la quête"""
    status = QuestTypes.QuestStatus.FAILED
    myLogger.debug("✗ Quête échouée : %s" % template.title, LogTypes.Domain.QUEST)

func expire() -> void:
    """Expire la quête"""
    status = QuestTypes.QuestStatus.EXPIRED
    myLogger.debug("⏰ Quête expirée : %s" % template.title, LogTypes.Domain.QUEST)

# ========================================
# PROGRESSION
# ========================================

func update_progress(delta: int) -> void:
    """Met à jour la progression"""
    progress = clamp(progress + delta, 0, template.objective_count)
    
    myLogger.debug("→ Progression : %d / %d" % [progress, template.objective_count], LogTypes.Domain.QUEST)
    
    # Vérifier la complétion
    if progress >= template.objective_count:
        complete()

func get_progress_percent() -> float:
    """Obtient le pourcentage de progression"""
    if template.objective_count == 0:
        return 100.0
    return (float(progress) / float(template.objective_count)) * 100.0

# ========================================
# VÉRIFICATIONS
# ========================================

func check_expiration(current_day: int) -> bool:
    """Vérifie si la quête est expirée"""
    if expires_on_day > 0 and current_day >= expires_on_day:
        expire()
        return true
    return false

func is_active() -> bool:
    return status == QuestTypes.QuestStatus.ACTIVE

func is_completed() -> bool:
    return status == QuestTypes.QuestStatus.COMPLETED

func is_failed() -> bool:
    return status == QuestTypes.QuestStatus.FAILED

func is_expired() -> bool:
    return status == QuestTypes.QuestStatus.EXPIRED

func is_finished() -> bool:
    """Vérifie si la quête est terminée (succès, échec ou expirée)"""
    return is_completed() or is_failed() or is_expired()

# ========================================
# INFORMATIONS
# ========================================
func is_offer_valid(current_day: int) -> bool:
    if template == null:
        return false

    # Expiration “offer”
    if expires_on_day > 0 and current_day >= expires_on_day:
        return false

    # Si offer liée à un LootSite (artefact perdu)
    var owner_type := String(context.get("owner_type", "")) # ex: "LOOT_SITE"
    if owner_type == "LOOT_SITE":
        var owner_id := String(context.get("owner_id", ""))
        if owner_id == "":
            return false
        # LootSiteManagerRunner.sites doit exister, sinon on considère invalide
        if LootSiteManagerRunner == null:
            return false
        if not LootSiteManagerRunner.has_method("get") and not LootSiteManagerRunner.has_method("get_property_list"):
            return false
        var sites: Dictionary = LootSiteManagerRunner.sites
        if not sites.has(owner_id):
            return false
    # Si giver faction n’existe pas
    var giver := String(context.get("giver_faction_id", ""))
    if giver != "":
        if FactionManager == null or not FactionManager.has_method("has_faction"):
            return false
        if not FactionManager.has_faction(giver):
            return false

    return true

func get_offer_signature() -> String:
    # Signature “fonctionnelle”, indépendante du runtime_id
    # Important: on prend ce qui rend l'offre unique pour le joueur.
    var qt := ""
    if template != null:
        qt = template.id  # si template “generated_*” c’est ok, mais mieux : quest_type dans context
    var quest_type := String(context.get("quest_type", qt)) # si tu l'as
    var giver := String(context.get("giver_faction_id", ""))
    var ant := String(context.get("antagonist_faction_id", ""))
    var step := String(context.get("goal_step_id", "")) # si offers liées aux goals
    var domain := String(context.get("domain", ""))
    var artifact_id := String(context.get("artifact_id", ""))

    # POI si tu en as (pour “ruins at x,y”)
    var poi_id := String(context.get("poi_id", ""))

    return "%s|giver=%s|ant=%s|step=%s|domain=%s|artifact=%s|poi=%s" % [
        quest_type, giver, ant, step, domain, artifact_id, poi_id
    ]

func get_days_remaining() -> int:
    """Obtient les jours restants avant expiration"""
    if expires_on_day < 0:
        return -1
    return max(0, expires_on_day - WorldState.current_day)

func get_status_text() -> String:
    """Obtient le texte du statut"""
    match status:
        QuestTypes.QuestStatus.AVAILABLE:
            return "Disponible"
        QuestTypes.QuestStatus.ACTIVE:
            return "En cours"
        QuestTypes.QuestStatus.COMPLETED:
            return "Terminée"
        QuestTypes.QuestStatus.FAILED:
            return "Échouée"
        QuestTypes.QuestStatus.EXPIRED:
            return "Expirée"
        _:
            return "Inconnu"

func get_status_color() -> Color:
    """Obtient la couleur du statut"""
    match status:
        QuestTypes.QuestStatus.AVAILABLE:
            return Color(0.8, 0.8, 0.8)  # Gris
        QuestTypes.QuestStatus.ACTIVE:
            return Color(0.3, 0.8, 1.0)  # Bleu
        QuestTypes.QuestStatus.COMPLETED:
            return Color(0.3, 0.8, 0.3)  # Vert
        QuestTypes.QuestStatus.FAILED:
            return Color(1.0, 0.3, 0.3)  # Rouge
        QuestTypes.QuestStatus.EXPIRED:
            return Color(0.5, 0.5, 0.5)  # Gris foncé
        _:
            return Color.WHITE

# ========================================
# PERSISTANCE
# ========================================

func save_state() -> Dictionary:
    """Sauvegarde l'état de la quête"""
    return {
        "runtime_id": runtime_id,
        "template_id": template_id,
        "status": status,
        "progress": progress,
        "started_on_day": started_on_day,
        "expires_on_day": expires_on_day,
        "context": context
    }

static func load_from_state(data: Dictionary, templates: Dictionary) -> QuestInstance:
    """Charge une quête depuis un Dictionary"""
    var template: QuestTemplate = templates.get(data["template_id"], null)
    if template == null:
        push_error("Impossible de charger la quête : template %s introuvable" % data["template_id"])
        return null
    
    var inst := QuestInstance.new(template, data.get("context", {}))
    inst.runtime_id = data["runtime_id"]
    inst.status = data["status"]
    inst.progress = data["progress"]
    inst.started_on_day = data["started_on_day"]
    inst.expires_on_day = data["expires_on_day"]
    return inst
