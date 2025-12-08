# res://src/quests/world_events/WorldCrisis.gd
class_name WorldCrisis extends QuestTemplateAdvanced

## Crise mondiale (Tier 4-5) affectant tout le monde
## PALIER 4 : Événements majeurs avec impact global

# ========================================
# PROPRIÉTÉS CRISE
# ========================================

@export var crisis_type: CrisisType = CrisisType.INVASION

enum CrisisType {
    INVASION,        ## Invasion massive (orcs, démons, etc.)
    PLAGUE,          ## Épidémie/maladie
    FAMINE,          ## Famine généralisée
    CIVIL_WAR,       ## Guerre civile
    NATURAL_DISASTER,## Catastrophe naturelle
    CORRUPTION,      ## Corruption magique
    APOCALYPSE       ## Fin du monde imminente
}

@export var severity: int = 5  ## Gravité (1-10, Tier 4 = 7-8, Tier 5 = 9-10)
@export var affected_factions: Array[String] = []  ## Factions affectées (vide = toutes)

# ========================================
# TIMER CRITIQUE
# ========================================

@export var critical_timer_days: int = 10  ## Jours avant catastrophe
@export var warning_days: int = 3  ## Jours d'avertissement avant timer

var timer_started: bool = false
var deadline_day: int = -1

# ========================================
# PHASES
# ========================================

@export var phases: Array[CrisisPhase] = []  ## Phases de la crise
var current_phase: int = 0

class CrisisPhase extends Resource:
    """Phase d'une crise"""
    
    @export var phase_number: int = 1
    @export var title: String = ""
    @export var description: String = ""
    
    @export var triggers_on_day: int = -1  ## Jour de déclenchement
    @export var trigger_conditions: Array[Dictionary] = []
    
    @export var world_effects: Dictionary = {}
    # Ex: {
    #   "all_factions_lose_relation": -10,
    #   "resource_drain": {"food": 50, "gold": 100},
    #   "spawns_enemies": {"type": "orcs", "count": 5}
    # }
    
    @export var new_objectives: Array[String] = []  ## IDs d'objectifs ajoutés

# ========================================
# IMPACT GLOBAL
# ========================================

@export var global_effects: Dictionary = {}
# Ex: {
#   "blocks_travel": true,  # Empêche voyages
#   "increases_prices": 2.0,  # Prix x2
#   "faction_relations_frozen": true,  # Relations gelées
#   "daily_resource_drain": {"food": 10}  # Drain quotidien
# }

@export var failure_consequences: Dictionary = {}
# Ex: {
#   "world_destroyed": true,
#   "all_factions_hostile": true,
#   "game_over": true
# }

# ========================================
# PARTICIPATION MONDIALE
# ========================================

@export var requires_multiple_players: bool = false  ## Mode multi (futur)
@export var contribution_tracking: bool = true  ## Tracker contributions

var global_contributions: Dictionary = {}  ## Type de contribution -> montant
# Ex: {"gold_donated": 5000, "enemies_defeated": 150, "resources_gathered": 200}

@export var contribution_goals: Dictionary = {}  ## Objectifs globaux
# Ex: {"gold_donated": 10000, "enemies_defeated": 500}

# ========================================
# MÉTHODES
# ========================================

func start_crisis() -> void:
    """Démarre la crise"""
    timer_started = true
    deadline_day = WorldState.current_day + critical_timer_days
    current_phase = 1
    
    print("\n🔥 CRISE MONDIALE DÉCLENCHÉE 🔥")
    print("Type : %s" % CrisisType.keys()[crisis_type])
    print("Gravité : %d/10" % severity)
    print("Délai critique : %d jours" % critical_timer_days)
    print("Date limite : Jour %d" % deadline_day)
    
    _apply_global_effects()
    _start_phase(1)

func _start_phase(phase_num: int) -> void:
    """Démarre une phase"""
    if phase_num > phases.size():
        return
    
    var phase := phases[phase_num - 1]
    current_phase = phase_num
    
    print("\n📍 Phase %d : %s" % [phase_num, phase.title])
    print(phase.description)
    
    _apply_phase_effects(phase)

func _apply_global_effects() -> void:
    """Applique les effets globaux de la crise"""
    if global_effects.is_empty():
        return
    
    print("\n🌍 Effets globaux appliqués :")
    
    # Prix augmentés
    if global_effects.has("increases_prices"):
        var multiplier: float = global_effects["increases_prices"]
        print("  → Prix des ressources x%.1f" % multiplier)
        # TODO: Implémenter système de prix
    
    # Relations gelées
    if global_effects.get("faction_relations_frozen", false):
        print("  → Relations avec factions gelées")
        # TODO: Implémenter gel relations
    
    # Voyages bloqués
    if global_effects.get("blocks_travel", false):
        print("  → Voyages bloqués dans certaines zones")
        QuestManager.add_world_tag("travel_restricted")

func _apply_phase_effects(phase: CrisisPhase) -> void:
    """Applique les effets d'une phase"""
    if phase.world_effects.is_empty():
        return
    
    # Relations factions
    if phase.world_effects.has("all_factions_lose_relation"):
        var loss: int = phase.world_effects["all_factions_lose_relation"]
        for faction in FactionManager.get_all_factions():
            FactionManager.adjust_relation(faction.id, loss)
        print("  → Toutes les factions : %+d relation" % loss)
    
    # Drain ressources
    if phase.world_effects.has("resource_drain"):
        var drains: Dictionary = phase.world_effects["resource_drain"]
        for resource_id in drains:
            var amount: int = drains[resource_id]
            ResourceManager.remove_resource(resource_id, amount)
            print("  → %s : -%d" % [resource_id, amount])

func check_phase_triggers() -> void:
    """Vérifie les déclenchements de phases"""
    for i in range(phases.size()):
        var phase := phases[i]
        var phase_num := i + 1
        
        if phase_num > current_phase:
            # Check jour
            if phase.triggers_on_day > 0 and WorldState.current_day >= phase.triggers_on_day:
                _start_phase(phase_num)
                break
            
            # Check conditions
            if not phase.trigger_conditions.is_empty():
                if QuestConditions.check_all_conditions(phase.trigger_conditions):
                    _start_phase(phase_num)
                    break

func check_deadline() -> bool:
    """Vérifie si la deadline est dépassée"""
    if not timer_started:
        return false
    
    return WorldState.current_day >= deadline_day

func get_days_remaining() -> int:
    """Retourne les jours restants"""
    if not timer_started:
        return -1
    return deadline_day - WorldState.current_day

func is_warning_period() -> bool:
    """Vérifie si on est dans la période d'avertissement"""
    var remaining := get_days_remaining()
    return remaining > 0 and remaining <= warning_days

func add_contribution(contribution_type: String, amount: int) -> void:
    """Ajoute une contribution globale"""
    if not contribution_tracking:
        return
    
    var current :int = global_contributions.get(contribution_type, 0)
    global_contributions[contribution_type] = current + amount
    
    print("📊 Contribution : %s +%d (Total: %d)" % [
        contribution_type,
        amount,
        global_contributions[contribution_type]
    ])

func check_contribution_goals() -> bool:
    """Vérifie si les objectifs globaux sont atteints"""
    if contribution_goals.is_empty():
        return false
    
    for goal_type in contribution_goals:
        var required: int = contribution_goals[goal_type]
        var current: int = global_contributions.get(goal_type, 0)
        
        if current < required:
            return false
    
    return true

func apply_failure_consequences() -> void:
    """Applique les conséquences de l'échec"""
    if failure_consequences.is_empty():
        return
    
    print("\n💀 CONSÉQUENCES DE L'ÉCHEC 💀")
    
    # Toutes factions hostiles
    if failure_consequences.get("all_factions_hostile", false):
        for faction in FactionManager.get_all_factions():
            FactionManager.adjust_relation(faction.id, -100)
        print("  → Toutes les factions sont désormais hostiles")
    
    # Game over
    if failure_consequences.get("game_over", false):
        print("  → GAME OVER")
        QuestManager.add_world_tag("game_over")
    
    # Monde détruit
    if failure_consequences.get("world_destroyed", false):
        print("  → Le monde a été détruit")
        QuestManager.add_world_tag("world_destroyed")

func get_crisis_type_name() -> String:
    """Retourne le nom du type de crise"""
    return CrisisType.keys()[crisis_type]

func get_crisis_description() -> String:
    """Génère une description complète de la crise"""
    var desc := description + "\n\n"
    
    desc += "Type : %s\n" % get_crisis_type_name()
    desc += "Gravité : %d/10\n" % severity
    desc += "Jours restants : %d\n\n" % get_days_remaining()
    
    desc += "Phases :\n"
    for i in range(phases.size()):
        var phase := phases[i]
        var icon := "○"
        if i + 1 < current_phase:
            icon = "✓"
        elif i + 1 == current_phase:
            icon = "▸"
        desc += "%s Phase %d : %s\n" % [icon, i + 1, phase.title]
    
    if contribution_tracking and not contribution_goals.is_empty():
        desc += "\nObjectifs globaux :\n"
        for goal_type in contribution_goals:
            var required: int = contribution_goals[goal_type]
            var current: int = global_contributions.get(goal_type, 0)
            var percent := (float(current) / float(required)) * 100.0
            desc += "• %s : %d / %d (%.0f%%)\n" % [goal_type, current, required, percent]
    
    return desc
