# res://src/quests/world_events/CrisisManager.gd
extends Node

## Gestionnaire de crises mondiales
## PALIER 4 : Événements Tier 4-5 qui affectent tout le monde

# ========================================
# PROPRIÉTÉS
# ========================================

var active_crisis: WorldCrisis = null  ## Crise en cours (1 seule à la fois)
var crisis_history: Array[String] = []  ## IDs des crises passées

var available_crises: Dictionary = {}  ## crisis_id -> WorldCrisis (catalogue)

# ========================================
# SIGNAUX
# ========================================

signal crisis_started(crisis: WorldCrisis)
signal crisis_phase_changed(crisis: WorldCrisis, phase: int)
signal crisis_warning(days_remaining: int)
signal crisis_completed(crisis: WorldCrisis)
signal crisis_failed(crisis: WorldCrisis)

# ========================================
# LIFECYCLE
# ========================================

func _ready() -> void:
    _load_crises()
    print("✓ CrisisManager initialisé (%d crises disponibles)" % available_crises.size())

func _load_crises() -> void:
    """Charge les crises depuis les fichiers .tres"""
    var dir := DirAccess.open("res://data/crises/")
    if not dir:
        print("Crises directory not found: res://data/crises/")
        return
    
    dir.list_dir_begin()
    var file_name := dir.get_next()
    
    while file_name != "":
        if file_name.ends_with(".tres"):
            var path := "res://data/crises/%s" % file_name
            var crisis := load(path) as WorldCrisis
            
            if crisis:
                available_crises[crisis.id] = crisis
                print("  → Crise chargée : %s" % crisis.title)
        
        file_name = dir.get_next()
    
    dir.list_dir_end()

# ========================================
# GESTION DES CRISES
# ========================================

func start_crisis(crisis_id: String) -> bool:
    """Démarre une crise"""
    
    # Vérifier qu'il n'y a pas déjà une crise
    if active_crisis:
        print("Cannot start crisis: another crisis is already active")
        return false
    
    var crisis := available_crises.get(crisis_id) as WorldCrisis
    if not crisis:
        push_error("Crisis not found: %s" % crisis_id)
        return false
    
    active_crisis = crisis
    crisis.start_crisis()
    
    crisis_started.emit(crisis)
    
    return true

func update_crisis() -> void:
    """Met à jour la crise active (appelé chaque jour)"""
    if not active_crisis:
        return
    
    # Check phases
    active_crisis.check_phase_triggers()
    
    # Check deadline
    if active_crisis.check_deadline():
        _on_crisis_deadline_reached()
        return
    
    # Check warning period
    if active_crisis.is_warning_period():
        var days := active_crisis.get_days_remaining()
        crisis_warning.emit(days)
        print("⚠️ ALERTE : %d jours restants pour la crise !" % days)
    
    # Apply daily effects
    _apply_daily_effects()

func _apply_daily_effects() -> void:
    """Applique les effets quotidiens de la crise"""
    if not active_crisis:
        return
    
    var effects: Dictionary = active_crisis.global_effects
    
    # Drain quotidien de ressources
    if effects.has("daily_resource_drain"):
        var drains: Dictionary = effects["daily_resource_drain"]
        for resource_id in drains:
            var amount: int = drains[resource_id]
            ResourceManager.remove_resource(resource_id, amount)

func complete_crisis() -> void:
    """Complète la crise active"""
    if not active_crisis:
        return
    
    print("\n🏆 CRISE RÉSOLUE : %s" % active_crisis.title)
    
    crisis_history.append(active_crisis.id)
    crisis_completed.emit(active_crisis)
    
    # Tags mondiaux
    QuestManager.add_world_tag("crisis_survived_%s" % active_crisis.id)
    
    active_crisis = null

func fail_crisis() -> void:
    """Fait échouer la crise active"""
    if not active_crisis:
        return
    
    print("\n💀 CRISE ÉCHOUÉE : %s" % active_crisis.title)
    
    # Appliquer conséquences
    active_crisis.apply_failure_consequences()
    
    crisis_history.append(active_crisis.id)
    crisis_failed.emit(active_crisis)
    
    active_crisis = null

func _on_crisis_deadline_reached() -> void:
    """Appelé quand la deadline est atteinte"""
    print("\n⏰ DEADLINE ATTEINTE")
    
    if not active_crisis:
        return
    
    # Vérifier si objectifs globaux atteints
    if active_crisis.contribution_tracking:
        if active_crisis.check_contribution_goals():
            complete_crisis()
            return
    
    # Sinon, échec
    fail_crisis()

# ========================================
# CONTRIBUTIONS
# ========================================

func add_contribution(contribution_type: String, amount: int) -> void:
    """Ajoute une contribution à la crise active"""
    if not active_crisis:
        return
    
    active_crisis.add_contribution(contribution_type, amount)

func get_contribution_progress(contribution_type: String) -> float:
    """Retourne la progression d'un objectif de contribution (0.0-1.0)"""
    if not active_crisis:
        return 0.0
    
    if not active_crisis.contribution_goals.has(contribution_type):
        return 0.0
    
    var required: int = active_crisis.contribution_goals[contribution_type]
    var current: int = active_crisis.global_contributions.get(contribution_type, 0)
    
    return clampf(float(current) / float(required), 0.0, 1.0)

# ========================================
# QUERIES
# ========================================

func has_active_crisis() -> bool:
    """Vérifie s'il y a une crise active"""
    return active_crisis != null

func get_active_crisis() -> WorldCrisis:
    """Retourne la crise active"""
    return active_crisis

func is_crisis_completed(crisis_id: String) -> bool:
    """Vérifie si une crise a été complétée"""
    return crisis_id in crisis_history

func get_crisis_severity() -> int:
    """Retourne la gravité de la crise active (0 si aucune)"""
    if not active_crisis:
        return 0
    return active_crisis.severity

# ========================================
# DÉCLENCHEMENT AUTO
# ========================================

func check_auto_trigger_crises() -> void:
    """Vérifie et déclenche automatiquement les crises dont les conditions sont remplies"""
    
    if active_crisis:
        return  # Déjà une crise active
    
    for crisis_id in available_crises:
        var crisis := available_crises[crisis_id] as WorldCrisis
        
        # Skip si déjà complétée
        if is_crisis_completed(crisis_id):
            continue
        
        # Check conditions
        if crisis.can_appear():
            print("🔥 Déclenchement automatique de crise : %s" % crisis.title)
            start_crisis(crisis_id)
            break

# ========================================
# PERSISTANCE
# ========================================

func save_state() -> Dictionary:
    """Sauvegarde l'état du gestionnaire"""
    var active_crisis_state: Dictionary = {}
    if active_crisis:
        active_crisis_state = {
            "id": active_crisis.id,
            "timer_started": active_crisis.timer_started,
            "deadline_day": active_crisis.deadline_day,
            "current_phase": active_crisis.current_phase,
            "global_contributions": active_crisis.global_contributions
        }
    
    return {
        "active_crisis": active_crisis_state,
        "crisis_history": crisis_history
    }

func load_state(data: Dictionary) -> void:
    """Charge l'état du gestionnaire"""
    crisis_history = data.get("crisis_history", [])
    
    var active_crisis_state: Dictionary = data.get("active_crisis", {})
    if not active_crisis_state.is_empty():
        var crisis_id: String = active_crisis_state.get("id", "")
        var crisis := available_crises.get(crisis_id) as WorldCrisis
        
        if crisis:
            active_crisis = crisis
            active_crisis.timer_started = active_crisis_state.get("timer_started", false)
            active_crisis.deadline_day = active_crisis_state.get("deadline_day", -1)
            active_crisis.current_phase = active_crisis_state.get("current_phase", 0)
            active_crisis.global_contributions = active_crisis_state.get("global_contributions", {})

# ========================================
# DEBUG
# ========================================

func print_crisis_status() -> void:
    """Affiche le statut de la crise active (debug)"""
    if not active_crisis:
        print("Aucune crise active")
        return
    
    print("\n" + active_crisis.get_crisis_description())
