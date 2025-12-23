# res://src/quests/QuestManager.gd
extends Node

## Gestionnaire global des quêtes
## FUSION : Base Claude + Tags ChatGPT + Persistance Claude

# ========================================
# SIGNAUX
# ========================================

signal quest_started(quest: QuestInstance)
signal quest_completed(quest: QuestInstance)
signal quest_failed(quest: QuestInstance)
signal quest_expired(quest: QuestInstance)
signal quest_progress_updated(quest: QuestInstance, progress: int, total: int)
signal quest_resolved(inst: QuestInstance, choice: String)

# ========================================
# PROPRIÉTÉS
# ========================================

## Templates chargés
var templates: Dictionary = {}  # id -> QuestTemplate

## Quêtes actives
var active_quests: Dictionary = {}  # runtime_id -> QuestInstance

## Historique
var completed_quests: Array[QuestInstance] = []
var failed_quests: Array[QuestInstance] = []

## Tags système (de ChatGPT)
var player_tags: Array[String] = []
var world_tags: Array[String] = []

# ========================================
# LIFECYCLE
# ========================================

func _ready() -> void:
    _load_quest_templates()
    print("✓ QuestManager initialisé avec %d templates" % templates.size())

# ========================================
# CHARGEMENT DES TEMPLATES
# ========================================

func _load_quest_templates() -> void:
    """Charge tous les templates de quêtes depuis res://data/quests/"""
    var dir := DirAccess.open("res://data/quests/")
    if dir == null:
        print("QuestManager: Impossible d'ouvrir res://data/quests/")
        return
    
    dir.list_dir_begin()
    var file_name := dir.get_next()
    
    while file_name != "":
        if file_name.ends_with(".tres"):
            var path := "res://data/quests/" + file_name
            var template := load(path) as QuestTemplate
            if template:
                register_template(template)
        file_name = dir.get_next()
    
    dir.list_dir_end()

func register_template(template: QuestTemplate) -> void:
    """Enregistre un template de quête"""
    templates[template.id] = template
    print("  → Template enregistré : %s (%s, Tier %d)" % [
        template.id,
        QuestTypes.get_category_name(template.category),
        template.tier
    ])

# ========================================
# GESTION DES QUÊTES
# ========================================
func start_runtime_quest(inst: QuestInstance, p_owner_type: String = "PLAYER", p_owner_id: String = "") -> void:
    if inst == null:
        return
    inst.owner_type = p_owner_type
    inst.owner_id = p_owner_id
    inst.start()
    active_quests[inst.runtime_id] = inst
    quest_started.emit(inst)


func start_quest(template_id: String, context: Dictionary = {}) -> QuestInstance:
    """Démarre une nouvelle quête"""
    var template :QuestTemplate = templates.get(template_id, null)
    if template == null:
        push_error("QuestManager: template '%s' introuvable" % template_id)
        return null
    
    # Vérifier si peut apparaître
    if not template.can_appear():
        print("⚠ La quête '%s' ne peut pas apparaître (conditions non remplies)" % template_id)
        return null
    
    # Créer l'instance
    var inst := QuestInstance.new(template, context)
    inst.start()
    active_quests[inst.runtime_id] = inst
    
    # Signal
    quest_started.emit(inst)
    
    return inst
func complete_quest(runtime_id: String) -> void:
    """Marque une quête comme complétée (objectif atteint) mais PAS résolue."""
    var inst: QuestInstance = active_quests.get(runtime_id, null)
    if inst == null:
        return

    inst.complete()

    # On ne donne plus les rewards ici : la résolution fera foi.
    quest_completed.emit(inst)

func fail_quest(runtime_id: String) -> void:
    """Échoue une quête"""
    var inst: QuestInstance = active_quests.get(runtime_id, null)
    if inst == null:
        return
    
    inst.fail()
    failed_quests.append(inst)
    active_quests.erase(runtime_id)
    
    quest_failed.emit(inst)

func _apply_rewards(inst: QuestInstance) -> void:
    """Applique les récompenses d'une quête"""
    print("\n=== Récompenses de '%s' ===" % inst.template.title)
    
    for reward in inst.template.rewards:
        _apply_single_reward(reward, inst)
    
    print("============================\n")
func _apply_single_reward(reward: QuestReward, inst: QuestInstance) -> void:
    var inv: Inventory = _get_inventory_for_instance(inst)

    match reward.type:
        QuestTypes.RewardType.GOLD:
            if inv != null:
                inv.add_gold(reward.amount)
                print("→ Gold(inv) : +%d (owner=%s:%s)" % [reward.amount, inst.owner_type, inst.owner_id])
            else:
                ResourceManager.add_resource("gold", reward.amount)

        QuestTypes.RewardType.FOOD:
            if inv != null:
                inv.add_food(reward.amount)
            else:
                ResourceManager.add_resource("food", reward.amount)

        QuestTypes.RewardType.ITEM:
            # Pour T3.3 on utilise ITEM comme “artifact_id” (provisoire)
            if inv != null and reward.target_id != "":
                inv.add_artifact(reward.target_id)
                if ArtifactRegistryRunner != null:
                    ArtifactRegistryRunner.set_artifact_owner(reward.target_id, inst.owner_type, inst.owner_id)
                print("→ Artifact acquired:", reward.target_id, "by", inst.owner_type, inst.owner_id)
            else:
                print("→ ITEM:", reward.target_id)

        _:
            print("→ Récompense non implémentée : %s" % reward.get_readable_description())
func _get_inventory_for_instance(inst: QuestInstance) -> Inventory:
    if inst == null:
        return null

    match inst.owner_type:
        "ARMY":
            var a: ArmyData = ArmyManagerRunner.get_army(inst.owner_id)
            return a.inventory if a else null
        "HERO":
            var h: HeroAgent = HeroManagerRunner.get_hero_by_id(inst.owner_id)
            return h.inventory if h else null
        _:
            return null

func _apply_effect(inst: QuestInstance, effect: QuestEffect) -> void:
    match effect.type:
        QuestEffect.EffectType.GOLD:
            ResourceManager.add_resource("gold", effect.amount)

        QuestEffect.EffectType.TAG_PLAYER:
            if effect.tag != "":
                add_player_tag(effect.tag)

        QuestEffect.EffectType.REL_GIVER:
            var giver := String(inst.context.get("giver_faction_id", ""))
            #TODO avant c'etait pour la relation avec le joueur, maintenant il va faloir que ce soit avec la personne qui fait la quete
            #if giver != "":
            # FactionManager.get_relation(giver).apply_delta_to(FactionRelationScore.REL_TRUST, effect.amount)

        QuestEffect.EffectType.REL_ANT:
            var ant := String(inst.context.get("antagonist_faction_id", ""))
            if ant != "":
                FactionManager.adjust_relation(ant, effect.amount)


func _apply_effect_OLD(inst: QuestInstance, effect: QuestEffect) -> void:
    match effect.type:
        QuestEffect.EffectType.GOLD:
            ResourceManager.add_resource("gold", effect.amount)
             
func resolve_quest(runtime_id: String, choice: String) -> void:
    var inst: QuestInstance = active_quests.get(runtime_id)
    if inst == null:
        return

    print("[QM] profiles available = ", ResolutionFactory.get_all_profile_ids())
    var profile_id = String(inst.context.get("resolution_profile_id", "default_simple"))
    var profile := ResolutionFactory.get_profile(profile_id)

    # IMPORTANT: même si profile null, on ne bloque pas l’arc
    if DebugConstants.ARC_LOG:
        print("profile_id=", inst.resolution_profile_id, " ctx.profile=", inst.context.get("resolution_profile_id","<none>"))
    if profile != null:
        for effect in profile.get_effects(choice):
            _apply_effect(inst, effect)

    if DebugConstants.ARC_LOG:
        print("[QM] resolve_quest rid=%s choice=%s title=%s ctx.is_arc=%s arc_id=%s stage=%s giver=%s ant=%s" % [
            runtime_id,
            choice,
            inst.template.title,
            str(inst.context.get("is_arc_rivalry", false)),
            str(inst.context.get("arc_id", "")),
            str(inst.context.get("arc_stage", "")),
            str(inst.context.get("giver_faction_id", "")),
            str(inst.context.get("antagonist_faction_id", "")),
        ])
    
    # --- Enregistrer l'événement dans ArcNotebook ---
    _record_quest_outcome_event(inst, choice)
    
    active_quests.erase(runtime_id)
    quest_completed.emit(inst)
    if ArcManagerRunner != null and ArcManagerRunner.has_method("on_quest_resolved"):
        ArcManagerRunner.on_quest_resolved(inst, choice)

    quest_resolved.emit(inst, choice)


func _record_quest_outcome_event(inst: QuestInstance, choice: String) -> void:
    """Enregistre l'événement de résolution dans ArcNotebook (pair ou triplet)"""
    if ArcManagerRunner == null or ArcManagerRunner.arc_notebook == null:
        return
    
    var ctx: Dictionary = inst.context
    var action: StringName = StringName(ctx.get("tp_action", ctx.get("arc_action_type", &"")))
    var day: int = int(ctx.get("day", 0))
    
    var giver: StringName = StringName(ctx.get("giver_faction_id", &""))
    var antagonist: StringName = StringName(ctx.get("antagonist_faction_id", &""))
    var third_party: StringName = StringName(ctx.get("third_party_id", &""))
    
    # Déterminer le résultat (SUCCESS/FAILURE)
    var chance: float = float(ctx.get("last_success_chance", 0.5))
    var roll: float = float(ctx.get("last_roll", ctx.get("roll", 0.5)))
    var outcome: StringName = &"SUCCESS" if roll < chance else &"FAILURE"
    
    # Si status déjà défini dans inst
    if inst.status == QuestTypes.QuestStatus.COMPLETED:
        outcome = &"SUCCESS"
    elif inst.status == QuestTypes.QuestStatus.FAILED:
        outcome = &"FAILURE"
    
    var meta := {
        "outcome": outcome,
        "chance": chance,
        "roll": roll,
        "choice": choice,
        "tier": inst.template.tier
    }
    
    # Événement tripartite (médiation, intervention) si third_party présent
    if third_party != &"" and action == &"tp.mediation":
        ArcManagerRunner.arc_notebook.record_triplet_event(
            day,
            antagonist,  # A (faction en conflit)
            third_party, # B (autre faction en conflit)
            giver,       # C (médiateur)
            action,
            StringName(choice),
            meta
        )
    # Événement pair standard
    elif giver != &"" and antagonist != &"":
        ArcManagerRunner.arc_notebook.record_pair_event(
            day,
            giver,
            antagonist,
            action,
            StringName(choice),
            meta
        )


# ========================================
# PROGRESSION
# ========================================

func update_quest_progress(template_id: String, delta: int = 1) -> void:
    """Met à jour la progression de toutes les quêtes actives d'un template"""
    for runtime_id in active_quests:
        var inst: QuestInstance = active_quests[runtime_id]
        if inst.template_id == template_id and inst.is_active():
            inst.update_progress(delta)
            quest_progress_updated.emit(inst, inst.progress, inst.template.objective_count)
            
            if inst.is_completed():
                complete_quest(runtime_id)

func update_quest_progress_by_id(runtime_id: String, delta: int = 1) -> void:
    """Met à jour la progression d'une quête spécifique"""
    var inst: QuestInstance = active_quests.get(runtime_id, null)
    if inst and inst.is_active():
        inst.update_progress(delta)
        quest_progress_updated.emit(inst, inst.progress, inst.template.objective_count)
        
        if inst.is_completed():
            complete_quest(runtime_id)

# ========================================
# EXPIRATIONS
# ========================================

func check_expirations() -> void:
    """Vérifie les expirations (appeler chaque changement de jour)"""
    var current_day := WorldState.current_day
    var to_expire: Array[String] = []
    
    for runtime_id in active_quests:
        var inst: QuestInstance = active_quests[runtime_id]
        if inst.check_expiration(current_day):
            to_expire.append(runtime_id)
    
    for rid in to_expire:
        var inst: QuestInstance = active_quests[rid]
        failed_quests.append(inst)
        active_quests.erase(rid)
        quest_expired.emit(inst)

# ========================================
# QUERIES
# ========================================

func get_active_quests() -> Array[QuestInstance]:
    """Retourne toutes les quêtes actives"""
    var result: Array[QuestInstance] = []
    for inst in active_quests.values():
        result.append(inst)
    return result

func get_active_quests_by_tier(tier: QuestTypes.QuestTier) -> Array[QuestInstance]:
    """Retourne les quêtes actives d'un tier donné"""
    var result: Array[QuestInstance] = []
    for inst in active_quests.values():
        if inst.template.tier == tier:
            result.append(inst)
    return result

func get_quest_by_id(runtime_id: String) -> QuestInstance:
    """Retourne une quête par son runtime_id"""
    return active_quests.get(runtime_id, null)

func has_active_quest(template_id: String) -> bool:
    """Vérifie si une quête est active"""
    for inst in active_quests.values():
        if inst.template_id == template_id:
            return true
    return false

# ========================================
# TAGS SYSTÈME (de ChatGPT)
# ========================================

func add_player_tag(tag: String) -> void:
    """Ajoute un tag au joueur"""
    if not player_tags.has(tag):
        player_tags.append(tag)
        print("→ Tag joueur ajouté : %s" % tag)

func remove_player_tag(tag: String) -> void:
    """Retire un tag du joueur"""
    player_tags.erase(tag)

func has_player_tag(tag: String) -> bool:
    """Vérifie si le joueur a un tag"""
    return player_tags.has(tag)

func add_world_tag(tag: String) -> void:
    """Ajoute un tag au monde"""
    if not world_tags.has(tag):
        world_tags.append(tag)
        print("→ Tag monde ajouté : %s" % tag)

func remove_world_tag(tag: String) -> void:
    """Retire un tag du monde"""
    world_tags.erase(tag)

func has_world_tag(tag: String) -> bool:
    """Vérifie si le monde a un tag"""
    return world_tags.has(tag)

# ========================================
# PERSISTANCE (de Claude)
# ========================================

func save_state() -> Dictionary:
    """Sauvegarde l'état complet du système de quêtes"""
    return {
        "active_quests": _serialize_quests(active_quests.values()),
        "completed_quests": _serialize_quests(completed_quests),
        "failed_quests": _serialize_quests(failed_quests),
        "player_tags": player_tags,
        "world_tags": world_tags
    }

func _serialize_quests(quests: Array) -> Array[Dictionary]:
    """Sérialise un array de quêtes"""
    var result: Array[Dictionary] = []
    for q in quests:
        if q is QuestInstance:
            result.append(q.save_state())
    return result

func load_state(data: Dictionary) -> void:
    """Charge l'état complet du système de quêtes"""
    active_quests.clear()
    completed_quests.clear()
    failed_quests.clear()
    
    # Quêtes actives
    for q_data in data.get("active_quests", []):
        var inst := QuestInstance.load_from_state(q_data, templates)
        if inst:
            active_quests[inst.runtime_id] = inst
    
    # Quêtes complétées
    for q_data in data.get("completed_quests", []):
        var inst := QuestInstance.load_from_state(q_data, templates)
        if inst:
            completed_quests.append(inst)
    
    # Quêtes échouées
    for q_data in data.get("failed_quests", []):
        var inst := QuestInstance.load_from_state(q_data, templates)
        if inst:
            failed_quests.append(inst)
    
    # Tags
    player_tags = data.get("player_tags", [])
    world_tags = data.get("world_tags", [])
    
    print("✓ État du système de quêtes chargé")
    print("  → %d quêtes actives" % active_quests.size())
    print("  → %d quêtes terminées" % completed_quests.size())

# ========================================
# DEBUG
# ========================================

func print_all_quests() -> void:
    """Affiche toutes les quêtes (debug)"""
    print("\n=== QUÊTES ACTIVES ===")
    for inst in get_active_quests():
        print("- %s (%d/%d) - %s" % [
            inst.template.title,
            inst.progress,
            inst.template.objective_count,
            inst.get_status_text()
        ])
    print("======================\n")
