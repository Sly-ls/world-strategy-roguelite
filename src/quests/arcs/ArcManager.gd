# res://src/arcs/ArcManager.gd
extends Node
class_name ArcManager

const ARC_TTL_DAYS: int = 30
const OFFER_EXPIRE_DAYS: int = 5

# Notebook unifié (remplace l'ancien RivalryNotebook)
var arc_notebook: ArcNotebook = ArcNotebook.new()

# Arc states per pair (A|B -> ArcState)
var arc_states: Dictionary = {}

# Faction profiles cache (faction_id -> FactionProfile)
var faction_profiles: Dictionary = {}

# Faction relations cache (faction_id -> {other_id -> FactionRelationScore})
var faction_relations: Dictionary = {}

func _ready() -> void:
    myLogger.debug("ArcManager before connect", LogTypes.Domain.ARC)
    _connect_signals()
    myLogger.debug("ArcManager after connect", LogTypes.Domain.ARC)

      
func _connect_signals() -> void:
    if QuestManager != null and QuestManager.has_signal("quest_resolved"):
        if not QuestManager.quest_resolved.is_connected(on_quest_resolution_choice):
            QuestManager.quest_resolved.connect(on_quest_resolution_choice)
            if DebugConstants.ARC_LOG: myLogger.debug("connected to QuestManager.quest_resolved", LogTypes.Domain.ARC)
        else:
            myLogger.debug("QuestManager has no signal quest_resolved", LogTypes.Domain.ARC)
    else:
        myLogger.debug("QuestManagerRunner not found", LogTypes.Domain.ARC)
    return


func tick_day() -> void:
    var retaliations: Array[Dictionary] = arc_notebook.tick_day(ARC_TTL_DAYS)
    for arc in retaliations:
        _spawn_retaliation_offer(arc)


func reset() -> void:
    arc_notebook.reset()
    arc_states.clear()
    faction_profiles.clear()
    faction_relations.clear()


func _day() -> int:
    if WorldState != null and WorldState.has_method("get") and WorldState.get("current_day") != null:
        return int(WorldState.get("current_day"))
    return 0


func on_faction_hostile_action(attacker_id: String, defender_id: String, action_id: String, meta: Dictionary = {}) -> void:
    if attacker_id == "" or defender_id == "" or attacker_id == defender_id:
        return
    var arc := arc_notebook.on_hostile_action(StringName(attacker_id), StringName(defender_id), StringName(action_id), meta)
    if arc.is_empty():
        return
    _spawn_arc_offer(arc, "hostile_action")

    
func on_quest_resolution_choice(inst: QuestInstance, choice: String) -> void:
    # Utiliser arc_notebook pour gérer la résolution
    arc_notebook.on_quest_resolution_choice(inst, choice)
    
    # Enregistrer l'événement dans pair_events
    var ctx: Dictionary = inst.context
    if bool(ctx.get("is_arc_rivalry", false)):
        var giver_id := StringName(ctx.get("giver_faction_id", ""))
        var ant_id := StringName(ctx.get("antagonist_faction_id", ""))
        var action := StringName(ctx.get("arc_action_type", ""))
        var day := _day()
        
        # Enregistrer l'événement
        arc_notebook.record_pair_event(day, giver_id, ant_id, action, StringName(choice), {
            "arc_id": ctx.get("arc_id", ""),
            "arc_stage": ctx.get("arc_stage", 0)
        })
        
        # Mettre à jour l'arc state si on l'a
        var pair_key := Utils.pair_key(giver_id, ant_id)
        if arc_states.has(pair_key):
            var arc_state: ArcState = arc_states[pair_key]
            var rel_ab := _get_relation(giver_id, ant_id)
            var rel_ba := _get_relation(ant_id, giver_id)
            if rel_ab != null and rel_ba != null:
                var rng := RandomNumberGenerator.new()
                rng.seed = hash(String(giver_id) + String(ant_id) + str(day))
                ArcStateMachine.update_arc_state(arc_state, rel_ab, rel_ba, day, rng, action, StringName(choice))


# --- Helper pour obtenir une relation ---
func _get_relation(from_id: StringName, to_id: StringName) -> FactionRelationScore:
    if FactionManager and FactionManager.has_method("get_relation_score"):
        return FactionManager.get_relation(from_id, to_id)    
    # Fallback: utiliser le cache local
    if not faction_relations.has(from_id):
        faction_relations[from_id] = {}
    if not faction_relations[from_id].has(to_id):
        faction_relations[from_id][to_id] = FactionRelationScore.new(to_id)
    return faction_relations[from_id][to_id]


# --- Helper pour obtenir un profil ---
func _get_profile(faction_id: StringName) -> FactionProfile:
    if FactionManager and FactionManager.has_method("get_faction_profile"):
        return FactionManager.get_faction_profile(faction_id)
    
    # Fallback: utiliser le cache local ou créer un profil par défaut
    if not faction_profiles.has(faction_id):
        var rng := RandomNumberGenerator.new()
        rng.seed = hash(String(faction_id))
        faction_profiles[faction_id] = FactionProfile.generate_full_profile(rng, FactionProfile.GEN_NORMAL)
    return faction_profiles[faction_id]


# --- Helper pour obtenir/créer un arc state ---
func get_or_create_arc_state(a: StringName, b: StringName) -> ArcState:
    var k := Utils.pair_key(a, b)
    if not arc_states.has(k):
        var state := ArcState.new()
        state.a_id = a if String(a) <= String(b) else b
        state.b_id = b if String(a) <= String(b) else a
        arc_states[k] = state
    return arc_states[k]


func _spawn_retaliation_offer(arc: Dictionary) -> void:
    # Représailles: on inverse giver/antagonist
    var inv := {
        "id": arc.get("id", ""),
        "attacker_id": arc.get("defender_id", &""),
        "defender_id": arc.get("attacker_id", &""),
        "stage": arc.get("stage", ArcNotebook.STAGE_PROVOCATION)
    }
    _spawn_arc_offer(inv, "retaliation")


func _spawn_arc_offer(arc: Dictionary, reason: String) -> void:
    var attacker_id: String = String(arc.get("attacker_id", &""))
    var defender_id: String = String(arc.get("defender_id", &""))
    var stage: int = arc.get("stage", ArcNotebook.STAGE_PROVOCATION)
    var arc_id: String = arc.get("id", "")
    
    # Crée une quête "combat" très contrôlée, pilotée par stage + contexte runtime
    var t := QuestTemplate.new()
    t.id = "arc_offer_%s_%d" % [arc_id, Time.get_ticks_msec()]
    t.category = QuestTypes.QuestCategory.COMBAT
    t.tier = QuestTypes.QuestTier.TIER_1
    t.objective_type = QuestTypes.ObjectiveType.CLEAR_COMBAT
    t.objective_target = defender_id
    t.objective_count = 3 if (stage == ArcNotebook.STAGE_DECISIVE) else 1
    t.expires_in_days = OFFER_EXPIRE_DAYS

    match stage:
        ArcNotebook.STAGE_PROVOCATION:
            t.title = "Riposte contre %s" % defender_id
            t.description = "Une provocation exige une réponse."
        ArcNotebook.STAGE_ESCALATION:
            t.title = "Escarmouches contre %s" % defender_id
            t.description = "La rivalité s'intensifie."
        ArcNotebook.STAGE_DECISIVE:
            t.title = "Frappe décisive contre %s" % defender_id
            t.description = "C'est le moment de frapper fort."
        _:
            t.title = "Conflit contre %s" % defender_id

    var ctx: Dictionary = {
        "giver_faction_id": attacker_id,
        "antagonist_faction_id": defender_id,
        "resolution_profile_id": "default_simple",
        "is_arc_rivalry": true,
        "arc_id": arc_id,
        "arc_stage": stage,
        "arc_reason": reason
    }

    var inst := QuestInstance.new(t, ctx)
    # Important: on veut une offer, pas une quête "active" immédiatement
    inst.status = QuestTypes.QuestStatus.AVAILABLE
    if DebugConstants.ARC_LOG:
        myLogger.debug("created offer title=%s giver=%s ant=%s stage=%s reason=%s" % [
            inst.template.title,
            str(ctx.get("giver_faction_id","")),
            str(ctx.get("antagonist_faction_id","")),
            str(ctx.get("arc_stage","")),
            reason
        ], LogTypes.Domain.ARC)

    # Inject dans le pool (on reste compatible avec ton pattern Runner)
    if QuestPool != null and QuestPool.has_method("try_add_offer"):
        QuestPool.try_add_offer(inst)
    elif QuestOfferSimRunner != null and QuestOfferSimRunner.has_method("try_add_offer"):
        var ok: bool = QuestOfferSimRunner.try_add_offer(inst)
        if DebugConstants.ARC_LOG:
            myLogger.debug("try_add_offer => %s (offers now=%d)" % [str(ok), QuestOfferSimRunner.offers.size()], LogTypes.Domain.ARC)
    else:
        myLogger.debug("No offer sink found (QuestPool.try_add_offer missing).", LogTypes.Domain.ARC)
