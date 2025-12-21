# res://src/factions/goals/FactionGoalState.gd
extends RefCounted
class_name FactionGoalState

## État d'un goal de faction avec support pour suspension/restoration
## FUSION: Structure originale (Claude) + Suspension/restore (ChatGPT)

# ========================================
# PROPRIÉTÉS ORIGINALES (Claude)
# ========================================

var goal: FactionGoal
var last_action: String = ""
var started_day: int = 0

# ========================================
# PROPRIÉTÉS AJOUTÉES (ChatGPT)
# ========================================

var suspended_goal: FactionGoal = null     # Goal suspendu pour restoration
var forced_until_day: int = -1             # Jour jusqu'auquel le goal est forcé
var force_reason: StringName = &""         # Raison: DOMESTIC_PRESSURE, CRISIS, etc.

# Budget multipliers (utilisés par le planner/AI)
var budget_mult_offensive: float = 1.0
var budget_mult_defensive: float = 1.0

# ========================================
# CONSTRUCTEUR
# ========================================

func _init(g: FactionGoal = null) -> void:
    goal = g
    if WorldState != null and "current_day" in WorldState:
        started_day = WorldState.current_day


# ========================================
# ACCESSEURS (compatibilité)
# ========================================

func get_goal() -> FactionGoal:
    return goal


func get_type() -> FactionGoal.GoalType:
    return goal.type if goal != null else FactionGoal.GoalType.BUILD_DOMAIN


func is_completed() -> bool:
    return goal != null and goal.is_completed()


func is_forced() -> bool:
    return forced_until_day > 0


func is_force_expired(current_day: int) -> bool:
    return forced_until_day > 0 and current_day >= forced_until_day


func has_suspended_goal() -> bool:
    return suspended_goal != null


# ========================================
# GESTION DES GOALS
# ========================================

func set_goal(new_goal: FactionGoal) -> void:
    goal = new_goal
    if WorldState != null and "current_day" in WorldState:
        started_day = WorldState.current_day


func suspend_current_goal(replacement: FactionGoal, until_day: int, reason: StringName) -> void:
    """Suspend le goal actuel et le remplace temporairement"""
    if goal != null and not goal.is_completed():
        suspended_goal = goal
    
    forced_until_day = until_day
    force_reason = reason
    goal = replacement
    
    if WorldState != null and "current_day" in WorldState:
        started_day = WorldState.current_day


func restore_suspended_goal() -> bool:
    """Restaure le goal suspendu si disponible"""
    if suspended_goal == null:
        return false
    
    goal = suspended_goal
    suspended_goal = null
    forced_until_day = -1
    force_reason = &""
    budget_mult_offensive = 1.0
    budget_mult_defensive = 1.0
    return true


func clear_force() -> void:
    """Annule la force sans restaurer le goal suspendu"""
    forced_until_day = -1
    force_reason = &""


# ========================================
# CONVERSION DICT (compatibilité ChatGPT)
# ========================================

func to_dict() -> Dictionary:
    """Convertit en Dictionary pour compatibilité avec l'ancien système"""
    var d := {
        "type": goal.type if goal != null else &"IDLE",
        "goal_id": goal.id if goal != null else "",
        "started_day": started_day,
        "forced_until_day": forced_until_day,
        "force_reason": force_reason,
        "budget_mult_offensive": budget_mult_offensive,
        "budget_mult_defensive": budget_mult_defensive,
    }
    
    if suspended_goal != null:
        d["suspended_goal"] = {
            "type": suspended_goal.type,
            "goal_id": suspended_goal.id
        }
    
    return d


static func from_dict(data: Dictionary, goal_lookup: Callable = Callable()) -> FactionGoalState:
    """Crée depuis un Dictionary (pour migration)"""
    var state := FactionGoalState.new(null)
    state.started_day = int(data.get("started_day", 0))
    state.forced_until_day = int(data.get("forced_until_day", -1))
    state.force_reason = StringName(data.get("force_reason", ""))
    state.budget_mult_offensive = float(data.get("budget_mult_offensive", 1.0))
    state.budget_mult_defensive = float(data.get("budget_mult_defensive", 1.0))
    
    # Si un Callable est fourni pour retrouver le goal par ID
    if goal_lookup.is_valid():
        var goal_id: String = data.get("goal_id", "")
        if goal_id != "":
            state.goal = goal_lookup.call(goal_id)
    
    return state
