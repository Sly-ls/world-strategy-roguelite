# res://src/quests/core/QuestInstanceAdvanced.gd
extends QuestInstance
class_name QuestInstanceAdvanced

## Instance de quête avancée avec gestion d'objectifs multiples et branches
## PALIER 3 : Runtime pour quêtes complexes

# ========================================
# PROPRIÉTÉS AVANCÉES
# ========================================

var objectives_runtime: Dictionary = {}  ## objective_id -> QuestObjective (copies runtime)
var branches_runtime: Dictionary = {}  ## branch_id -> QuestBranch (copies runtime)

var current_branch_id: String = ""  ## Branche en cours
var branch_history: Array[String] = []  ## Historique des branches prises

# ========================================
# CONSTRUCTION
# ========================================

func _init(p_template: QuestTemplate = null, p_context: Dictionary = {}) -> void:
    super(p_template, p_context)
    
    if p_template is QuestTemplateAdvanced:
        _initialize_advanced(p_template)

func _initialize_advanced(advanced_template: QuestTemplateAdvanced) -> void:
    """Initialise les objectifs et branches"""
    
    # Copier objectifs
    for obj in advanced_template.objectives:
        var runtime_obj := _duplicate_objective(obj)
        objectives_runtime[obj.id] = runtime_obj
        
        # Déverrouiller immédiatement si pas de conditions
        if not runtime_obj.is_optional and runtime_obj.unlock_conditions.is_empty() and runtime_obj.required_objectives.is_empty():
            runtime_obj.unlock()
    
    # Copier branches
    if advanced_template.has_branches:
        for branch in advanced_template.branches:
            var runtime_branch := _duplicate_branch(branch)
            branches_runtime[branch.id] = runtime_branch

func _duplicate_objective(obj: QuestObjective) -> QuestObjective:
    """Crée une copie runtime d'un objectif"""
    var copy := QuestObjective.new()
    copy.id = obj.id
    copy.title = obj.title
    copy.description = obj.description
    copy.objective_type = obj.objective_type
    copy.target = obj.target
    copy.count = obj.count
    copy.is_optional = obj.is_optional
    copy.is_hidden = obj.is_hidden
    copy.is_parallel = obj.is_parallel
    copy.unlock_conditions = obj.unlock_conditions.duplicate()
    copy.required_objectives = obj.required_objectives.duplicate()
    copy.unlock_on_day = obj.unlock_on_day
    copy.rewards = obj.rewards.duplicate()
    copy.can_fail = obj.can_fail
    copy.fail_on_day = obj.fail_on_day
    copy.fail_conditions = obj.fail_conditions.duplicate()
    return copy
func _duplicate_branch(branch: QuestBranch) -> QuestBranch:
    """Crée une copie runtime d'une branche - ADAPTÉ AU VRAI QuestBranch"""
    var copy := QuestBranch.new()
    
    # Propriétés de base
    copy.id = branch.id
    copy.title = branch.title
    copy.description = branch.description
    copy.icon = branch.icon
    
    # Effets
    copy.rewards = branch.rewards.duplicate()
    copy.adds_tags = branch.adds_tags.duplicate()
    copy.removes_tags = branch.removes_tags.duplicate()
    
    # Quêtes suivantes
    copy.leads_to_quest = branch.leads_to_quest
    copy.blocks_quests = branch.blocks_quests.duplicate()
    
    # Conditions
    copy.required_tags = branch.required_tags.duplicate()
    copy.required_gold = branch.required_gold
    copy.required_items = branch.required_items.duplicate()
    
    # État runtime (réinitialisé)
    copy.is_triggered = false
    copy.chosen_option = -1
    copy.triggered_on_day = -1
    
    return copy

# ========================================
# GESTION OBJECTIFS
# ========================================
func update_objective_progress(objective_id: String, delta: int = 1) -> bool:
    """Met à jour la progression d'un objectif spécifique"""
    var obj := objectives_runtime.get(objective_id) as QuestObjective
    if not obj:
        push_error("Objective not found: %s" % objective_id)
        return false
    
    if not obj.is_active():
        return false
    
    var was_completed :bool = obj.update_progress(delta)
    
    if was_completed:
        _on_objective_completed(obj)
    
    # Check si quête complète
    if _check_quest_completion():
        complete()
    
    return was_completed

func _on_objective_completed(obj: QuestObjective) -> void:
    """Appelé quand un objectif est complété"""
    
    # Appliquer récompenses de l'objectif
    for reward in obj.rewards:
        _apply_objective_reward(reward)
    
    # Déverrouiller objectifs suivants
    _check_unlock_objectives()
    
    # Vérifier branches déclenchées par cet objectif
    _check_trigger_branches(obj.id)

func _apply_objective_reward(reward: QuestReward) -> void:
    """Applique une récompense d'objectif"""
    match reward.type:
        QuestTypes.RewardType.GOLD:
            ResourceManager.add_resource("gold", reward.amount)
        QuestTypes.RewardType.FOOD:
            ResourceManager.add_resource("food", reward.amount)
        QuestTypes.RewardType.FACTION_REP:
            if reward.target_id:
                FactionManager.adjust_relation(reward.target_id, reward.amount)

func _check_unlock_objectives() -> void:
    """Vérifie et déverrouille les objectifs dont les conditions sont remplies"""
    for obj_id in objectives_runtime:
        var obj := objectives_runtime[obj_id] as QuestObjective
        if obj.is_locked() and obj.check_unlock_conditions({"objectives": objectives_runtime}):
            obj.unlock()

func _check_quest_completion() -> bool:
    """Vérifie si la quête est complète"""
    if not template is QuestTemplateAdvanced:
        return false
    
    return (template as QuestTemplateAdvanced).is_quest_complete()

# ========================================
# GESTION BRANCHES
# ========================================

func _check_trigger_branches(completed_objective_id: String = "") -> void:
    """Vérifie et déclenche les branches dont les conditions sont remplies"""
    for branch_id in branches_runtime:
        var branch := branches_runtime[branch_id] as QuestBranch
        
        # Check si déclenchée par objectif
        if completed_objective_id and branch.trigger_on_objective == completed_objective_id:
            branch.trigger()
            current_branch_id = branch_id
            continue
        
        # Check conditions générales
        if not branch.is_triggered and branch.check_trigger_conditions():
            branch.trigger()
            current_branch_id = branch_id

func make_branch_choice(branch_id: String, choice_index: int) -> void:
    """Fait un choix dans une branche"""
    var branch := branches_runtime.get(branch_id) as QuestBranch
    if not branch:
        push_error("Branch not found: %s" % branch_id)
        return
    
    var choice :QuestBranch.BranchChoice = branch.make_choice(choice_index)
    if not choice:
        return
    
    # Ajouter à l'historique
    branch_history.append("%s:%d" % [branch_id, choice_index])
    
    # Appliquer conséquences
    choice.apply_consequences()
    
    # Gérer objectifs
    _apply_choice_objectives(choice)
    
    # Vérifier si la quête se termine
    if choice.completes_quest:
        complete()
    elif choice.fails_quest:
        fail()
    
    # Branche suivante
    if choice.next_branch_id:
        var next_branch := branches_runtime.get(choice.next_branch_id) as QuestBranch
        if next_branch:
            next_branch.trigger()
            current_branch_id = choice.next_branch_id

func _apply_choice_objectives(choice: QuestBranch.BranchChoice) -> void:
    """Applique les changements d'objectifs d'un choix"""
    
    # Ajouter objectifs
    for obj_id in choice.adds_objectives:
        var obj := objectives_runtime.get(obj_id) as QuestObjective
        if obj:
            obj.unlock()
    
    # Retirer objectifs
    for obj_id in choice.removes_objectives:
        objectives_runtime.erase(obj_id)
    
    # Faire échouer objectifs
    for obj_id in choice.fails_objectives:
        var obj := objectives_runtime.get(obj_id) as QuestObjective
        if obj:
            obj.fail()

func get_current_branch() -> QuestBranch:
    """Retourne la branche en cours"""
    if current_branch_id.is_empty():
        return null
    return branches_runtime.get(current_branch_id)

# ========================================
# QUERIES
# ========================================

func get_all_objectives() -> Array[QuestObjective]:
    """Retourne tous les objectifs"""
    var objs: Array[QuestObjective] = []
    for obj_id in objectives_runtime:
        objs.append(objectives_runtime[obj_id])
    return objs

func get_active_objectives() -> Array[QuestObjective]:
    """Retourne les objectifs actifs"""
    var active: Array[QuestObjective] = []
    for obj in get_all_objectives():
        if obj.is_active():
            active.append(obj)
    return active

func get_completed_objectives() -> Array[QuestObjective]:
    """Retourne les objectifs complétés"""
    var completed: Array[QuestObjective] = []
    for obj in get_all_objectives():
        if obj.status == QuestObjective.ObjectiveStatus.COMPLETED:
            completed.append(obj)
    return completed

func get_completion_ratio() -> float:
    """Retourne le ratio de complétion (0.0 à 1.0)"""
    var total := get_all_objectives().size()
    if total == 0:
        return 0.0
    
    var completed := get_completed_objectives().size()
    return float(completed) / float(total)

# ========================================
# EXPIRATIONS & ÉCHECS
# ========================================

func check_objectives_expiration() -> void:
    """Vérifie les objectifs avec limite de temps"""
    for obj in get_all_objectives():
        if obj.is_active() and obj.check_fail_conditions():
            obj.fail()
            
            # Si objectif principal échoue, la quête échoue
            if not obj.is_optional:
                fail()
                return

# ========================================
# PERSISTANCE
# ========================================

func save_state() -> Dictionary:
    """Sauvegarde l'état de l'instance avancée"""
    var base_state := super.save_state()
    
    # Sauvegarder objectifs
    var objectives_state := {}
    for obj_id in objectives_runtime:
        var obj := objectives_runtime[obj_id] as QuestObjective
        objectives_state[obj_id] = obj.save_state()
    
    # Sauvegarder branches
    var branches_state := {}
    for branch_id in branches_runtime:
        var branch := branches_runtime[branch_id] as QuestBranch
        branches_state[branch_id] = branch.save_state()
    
    base_state["objectives_runtime"] = objectives_state
    base_state["branches_runtime"] = branches_state
    base_state["current_branch_id"] = current_branch_id
    base_state["branch_history"] = branch_history
    
    return base_state

static func load_from_state_advanced(template: QuestTemplateAdvanced, data: Dictionary) -> QuestInstanceAdvanced:
    """Charge une instance avancée depuis l'état sauvegardé"""
    var instance := QuestInstanceAdvanced.new(template, data.get("context", {}))
    
    # Charger base
    instance.runtime_id = data.get("runtime_id", "")
    instance.template_id = data.get("template_id", "")
    instance.status = data.get("status", QuestTypes.QuestStatus.AVAILABLE)
    instance.started_on_day = data.get("started_on_day", -1)
    instance.expires_on_day = data.get("expires_on_day", -1)
    
    # Charger objectifs
    var objectives_state: Dictionary = data.get("objectives_runtime", {})
    for obj_id in objectives_state:
        var obj := instance.objectives_runtime.get(obj_id) as QuestObjective
        if obj:
            QuestObjective.load_from_state(obj, objectives_state[obj_id])
    
    # Charger branches
    var branches_state: Dictionary = data.get("branches_runtime", {})
    for branch_id in branches_state:
        var branch := instance.branches_runtime.get(branch_id) as QuestBranch
        if branch:
            QuestBranch.load_from_state(branch, branches_state[branch_id])
    
    instance.current_branch_id = data.get("current_branch_id", "")
    instance.branch_history = data.get("branch_history", [])
    
    return instance
