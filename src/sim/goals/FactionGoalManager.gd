# res://src/factions/goals/FactionGoalManager.gd
extends Node
class_name FactionGoalManager

## Gestionnaire des goals de faction
## FUSION: Factory + completion (Claude) + Domestic pressure hooks (ChatGPT)

# ========================================
# SIGNAUX
# ========================================

signal goal_created(faction_id: String, goal: FactionGoal)
signal goal_completed(faction_id: String, goal: FactionGoal)
signal truce_forced(faction_id: String, duration: int)
signal truce_ended(faction_id: String)

# ========================================
# DONNÉES
# ========================================

# faction_id -> FactionGoalState
var active_goals: Dictionary = {}

# ========================================
# MÉTHODE PRINCIPALE FUSIONNÉE
# ========================================

func ensure_goal(faction_id: String, ctx: Dictionary = {}) -> FactionGoalState:
    """
    Assure qu'une faction a un goal actif.

    FUSION de:
    - Claude: Type safety, factory pattern, completion check
    - ChatGPT: Domestic pressure hooks, suspension/restore

    Args:
        faction_id: ID de la faction
        ctx: Contexte optionnel avec:
            - domestic_state: État domestique (pressure, war_weariness, etc.)
            - day / current_day: Jour actuel
            - profile: FactionProfile (optionnel)
            - relations: Dictionary de relations (optionnel)

    Returns:
        FactionGoalState avec le goal actif
    """
    
    var goal_state: FactionGoalState = active_goals.get(faction_id, null)
    var current_day := _get_current_day(ctx)
    
    # 1) Créer un nouveau goal si inexistant ou complété
    if goal_state == null or goal_state.is_completed():
        var new_goal := FactionGoalFactory.create_goal(faction_id)
        
        if goal_state == null:
            goal_state = FactionGoalState.new(new_goal)
        else:
            # Goal précédent complété
            goal_state.set_goal(new_goal)
        
        active_goals[faction_id] = goal_state
        goal_created.emit(faction_id, new_goal)
        print("🎯 New goal for %s: %s" % [faction_id, new_goal.title])
    
    # 2) Hook Domestic Pressure (non invasif)
    var dom = ctx.get("domestic_state", null)
    if dom != null:
        var was_forced := goal_state.is_forced()
        
        # 2a) Essayer de restaurer un goal suspendu si pression redescendue
        goal_state = DomesticPolicyGate.maybe_restore_suspended_goal(goal_state, ctx, dom)
        
        if was_forced and not goal_state.is_forced():
            truce_ended.emit(faction_id)
            print("🕊️ Truce ended for %s" % faction_id)
        
        # 2b) Appliquer la pression (peut forcer une TRUCE)
        var was_forced_before := goal_state.is_forced()
        goal_state = DomesticPolicyGate.apply(StringName(faction_id), goal_state, ctx, dom, {
            "pressure_threshold": 0.7,
            "force_days": 7,
            "min_offensive_budget_mult": 0.25
        })
        
        if not was_forced_before and goal_state.is_forced():
            var duration := goal_state.forced_until_day - current_day
            truce_forced.emit(faction_id, duration)
        
        active_goals[faction_id] = goal_state
    
    return goal_state


# ========================================
# ACCÈS AUX GOALS
# ========================================

func get_goal_state(faction_id: String) -> FactionGoalState:
    """Récupère l'état du goal d'une faction (peut être null)"""
    return active_goals.get(faction_id, null)


func get_goal(faction_id: String) -> FactionGoal:
    """Récupère le goal actif d'une faction (peut être null)"""
    var state := get_goal_state(faction_id)
    return state.goal if state != null else null


func has_goal(faction_id: String) -> bool:
    """Vérifie si une faction a un goal actif"""
    return active_goals.has(faction_id)


func is_faction_in_truce(faction_id: String) -> bool:
    """Vérifie si une faction est en trêve forcée"""
    var state := get_goal_state(faction_id)
    return state != null and state.is_forced()


# ========================================
# MODIFICATION DES GOALS
# ========================================

func set_goal(faction_id: String, goal: FactionGoal) -> void:
    """Définit manuellement le goal d'une faction"""
    var state := get_goal_state(faction_id)
    if state == null:
        state = FactionGoalState.new(goal)
        active_goals[faction_id] = state
    else:
        state.set_goal(goal)
    
    goal_created.emit(faction_id, goal)
    print("🎯 Goal set for %s: %s" % [faction_id, goal.title])


func complete_goal(faction_id: String) -> void:
    """Marque le goal d'une faction comme complété et applique les effets"""
    var st: FactionGoalState = active_goals.get(faction_id, null)
    if st == null or st.goal == null:
        return
    
    var g := st.goal
    print("🏁 Goal completed for %s: %s" % [faction_id, g.title])
    
    # Impact monde
    for t in g.on_complete_world_tags:
        if QuestManager != null and QuestManager.has_method("add_world_tag"):
            QuestManager.add_world_tag(t)
    
    # Impact relations (si cible)
    if g.target_faction_id != "" and g.on_complete_relation_delta != 0:
        if FactionManager != null:
            var current_rel := FactionManager.get_relation_between(g.actor_faction_id, g.target_faction_id)
            var new_rel := current_rel + g.on_complete_relation_delta
            FactionManager.set_relation_between(g.actor_faction_id, g.target_faction_id, new_rel)
    
    goal_completed.emit(faction_id, g)
    
    # On force un nouveau goal au prochain ensure_goal()
    active_goals.erase(faction_id)


func force_truce(faction_id: String, duration: int, reason: StringName = &"MANUAL") -> void:
    """Force une trêve pour une faction"""
    var state := get_goal_state(faction_id)
    var current_day := _get_current_day({})
    
    if state == null:
        var idle_goal := FactionGoal.new()
        idle_goal.id = "idle_%s" % faction_id
        idle_goal.title = "En attente"
        idle_goal.actor_faction_id = faction_id
        state = FactionGoalState.new(idle_goal)
        active_goals[faction_id] = state
    
    var truce_goal := FactionGoal.new()
    truce_goal.id = "truce_%s_%d" % [faction_id, current_day]
    truce_goal.title = "Trêve forcée"
    truce_goal.actor_faction_id = faction_id
    
    state.suspend_current_goal(truce_goal, current_day + duration, reason)
    
    truce_forced.emit(faction_id, duration)
    print("🕊️ Truce forced for %s: %d days (reason: %s)" % [faction_id, duration, str(reason)])


# ========================================
# QUERIES
# ========================================

func get_all_active_faction_ids() -> Array[String]:
    """Retourne tous les IDs de faction avec un goal"""
    var result: Array[String] = []
    for fid in active_goals.keys():
        result.append(fid)
    return result


func get_factions_targeting(target_id: String) -> Array[String]:
    """Retourne les factions qui ciblent une faction spécifique"""
    var result: Array[String] = []
    for fid in active_goals.keys():
        var state: FactionGoalState = active_goals[fid]
        if state.goal != null and state.goal.target_faction_id == target_id:
            result.append(fid)
    return result


func get_offensive_budget_mult(faction_id: String) -> float:
    """Retourne le multiplicateur de budget offensif d'une faction"""
    var state := get_goal_state(faction_id)
    return state.budget_mult_offensive if state != null else 1.0


func get_defensive_budget_mult(faction_id: String) -> float:
    """Retourne le multiplicateur de budget défensif d'une faction"""
    var state := get_goal_state(faction_id)
    return state.budget_mult_defensive if state != null else 1.0


# ========================================
# AVANCEMENT DES GOALS
# ========================================

func advance_goal_step(faction_id: String, amount: int = 1) -> void:
    """Avance la progression de l'étape actuelle du goal"""
    var state := get_goal_state(faction_id)
    if state == null or state.goal == null:
        return
    
    var step := state.goal.get_current_step()
    if step != null:
        step.progress += amount
        state.goal.advance_if_step_done()
        
        if state.goal.is_completed():
            complete_goal(faction_id)


# ========================================
# HELPERS PRIVÉS
# ========================================

func _get_current_day(ctx: Dictionary) -> int:
    """Récupère le jour actuel depuis ctx ou WorldState"""
    if ctx.has("day"):
        return int(ctx["day"])
    if ctx.has("current_day"):
        return int(ctx["current_day"])
    if WorldState != null and "current_day" in WorldState:
        return int(WorldState.current_day)
    return 0


# ========================================
# PERSISTANCE
# ========================================

func save_state() -> Dictionary:
    var data := {}
    for fid in active_goals.keys():
        var state: FactionGoalState = active_goals[fid]
        data[fid] = state.to_dict()
    return data


func load_state(data: Dictionary) -> void:
    # Note: nécessite de recréer les goals depuis leurs IDs
    # Implémentation simplifiée - à adapter selon ton système de persistance
    active_goals.clear()
    print("✓ FactionGoalManager: state cleared, ready for new goals")


# ========================================
# DEBUG
# ========================================

func print_all_goals() -> void:
    print("\n=== FACTION GOALS ===")
    for fid in active_goals.keys():
        var state: FactionGoalState = active_goals[fid]
        var forced_str := " [FORCED until day %d]" % state.forced_until_day if state.is_forced() else ""
        var suspended_str := " [suspended: %s]" % state.suspended_goal.title if state.has_suspended_goal() else ""
        var step_info := ""
        if state.goal != null:
            var step := state.goal.get_current_step()
            if step != null:
                step_info = " - Step: %s (%d/%d)" % [step.title, step.progress, step.required_amount]
        print("- %s: %s%s%s%s" % [
            fid,
            state.goal.title if state.goal else "NONE",
            step_info,
            forced_str,
            suspended_str
        ])
    print("=====================\n")
