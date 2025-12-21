# res://src/factions/goals/DomesticPolicyGate.gd
class_name DomesticPolicyGate
extends RefCounted

## Gate pour gérer la pression domestique sur les goals de faction
## FUSION: Logique ChatGPT adaptée pour FactionGoalState (Claude)

# ========================================
# CONSTANTES
# ========================================

const DEFAULT_PRESSURE_THRESHOLD := 0.7
const DEFAULT_FORCE_DAYS := 7
const DEFAULT_MIN_OFFENSIVE_BUDGET := 0.25
const RESTORE_PRESSURE_THRESHOLD := 0.4

# ========================================
# APPLICATION DE LA PRESSION DOMESTIQUE
# ========================================

static func apply(
    faction_id: StringName,
    goal_state: FactionGoalState,
    ctx: Dictionary,
    domestic_state,                # Objet avec .pressure() ou Dictionary avec "pressure"
    params: Dictionary = {}
) -> FactionGoalState:
    """
    Applique la pression domestique sur un FactionGoalState.
    Peut forcer une TRUCE si la pression est trop haute.
    """
    
    # Récupérer la pression (supporte objet avec .pressure() ou Dictionary)
    var p: float
    if domestic_state is Dictionary:
        p = float(domestic_state.get("pressure", 0.0))
    elif domestic_state != null and domestic_state.has_method("pressure"):
        p = float(domestic_state.pressure())
    else:
        return goal_state
    
    var threshold := float(params.get("pressure_threshold", DEFAULT_PRESSURE_THRESHOLD))
    var force_days := int(params.get("force_days", DEFAULT_FORCE_DAYS))
    var min_mult := float(params.get("min_offensive_budget_mult", DEFAULT_MIN_OFFENSIVE_BUDGET))
    var current_day := int(ctx.get("day", ctx.get("current_day", 0)))
    
    # Si pression trop haute -> forcer TRUCE
    if p >= threshold:
        if not goal_state.is_forced():
            # Créer un goal de TRUCE
            var truce_goal := _create_truce_goal(faction_id, current_day, force_days)
            goal_state.suspend_current_goal(truce_goal, current_day + force_days, &"DOMESTIC_PRESSURE")
            print("[DomesticPolicyGate] %s: pressure=%.2f >= %.2f, forcing TRUCE for %d days" % [
                str(faction_id), p, threshold, force_days
            ])
        
        # Réduire les budgets offensifs
        var mult := clampf(1.0 - 0.85 * (p - threshold) / (1.0 - threshold), min_mult, 1.0)
        goal_state.budget_mult_offensive = mult
        goal_state.budget_mult_defensive = maxf(0.8, mult + 0.35)
    
    # Pression modérée -> réduction partielle
    elif p >= threshold * 0.7:
        var reduction := lerpf(1.0, 0.7, (p - threshold * 0.7) / (threshold * 0.3))
        goal_state.budget_mult_offensive = reduction
    
    return goal_state


static func maybe_restore_suspended_goal(
    goal_state: FactionGoalState,
    ctx: Dictionary,
    domestic_state
) -> FactionGoalState:
    """
    Restaure le goal suspendu si la pression est redescendue
    et que la période de force est expirée.
    """
    
    if not goal_state.has_suspended_goal():
        return goal_state
    
    # Récupérer la pression
    var p: float
    if domestic_state is Dictionary:
        p = float(domestic_state.get("pressure", 0.0))
    elif domestic_state != null and domestic_state.has_method("pressure"):
        p = float(domestic_state.pressure())
    else:
        return goal_state
    
    var current_day := int(ctx.get("day", ctx.get("current_day", 0)))
    
    # Conditions pour restaurer:
    # 1. La période de force est expirée
    # 2. La pression est suffisamment basse
    if goal_state.is_force_expired(current_day) and p < RESTORE_PRESSURE_THRESHOLD:
        if goal_state.restore_suspended_goal():
            print("[DomesticPolicyGate] Restored suspended goal for pressure=%.2f" % p)
    
    return goal_state


# ========================================
# HELPERS
# ========================================

static func _create_truce_goal(faction_id: StringName, day: int, duration: int) -> FactionGoal:
    """Crée un goal de trêve temporaire"""
    var g := FactionGoal.new()
    g.id = "truce_%s_%d" % [str(faction_id), day]
    g.type = FactionGoal.GoalType.GAIN_ALLY  # On utilise un type existant, ou ajouter TRUCE à l'enum
    g.title = "Trêve forcée (pression interne)"
    g.actor_faction_id = str(faction_id)
    g.steps = []  # Pas de steps, juste attendre
    return g


static func should_force_truce(
    goal_state: FactionGoalState,
    domestic_state,
    threshold: float = DEFAULT_PRESSURE_THRESHOLD
) -> bool:
    """Vérifie si une trêve devrait être forcée"""
    
    var p: float
    if domestic_state is Dictionary:
        p = float(domestic_state.get("pressure", 0.0))
    elif domestic_state != null and domestic_state.has_method("pressure"):
        p = float(domestic_state.pressure())
    else:
        return false
    
    # Ne pas forcer si déjà en trêve forcée
    if goal_state.is_forced():
        return false
    
    return p >= threshold


static func get_recommended_offensive_budget(domestic_state, base: float = 1.0) -> float:
    """Retourne le budget offensif recommandé basé sur la pression"""
    
    var p: float
    if domestic_state is Dictionary:
        p = float(domestic_state.get("pressure", 0.0))
    elif domestic_state != null and domestic_state.has_method("pressure"):
        p = float(domestic_state.pressure())
    else:
        return base
    
    if p < 0.3:
        return base
    elif p < 0.5:
        return base * 0.8
    elif p < 0.7:
        return base * 0.5
    else:
        return base * DEFAULT_MIN_OFFENSIVE_BUDGET
