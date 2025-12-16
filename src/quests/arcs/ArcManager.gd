# res://src/arcs/ArcManager.gd
extends Node
class_name ArcManager

const ARC_TTL_DAYS: int = 30
const OFFER_EXPIRE_DAYS: int = 5

var notebook: RivalryNotebook = RivalryNotebook.new()
func _ready() -> void:
    print("[ARC] ArcManager before connect")
    _connect_signals()
    print("[ARC] ArcManager after connect")
      
func _connect_signals() -> void:
    if QuestManager != null and QuestManager.has_signal("quest_resolved"):
        if not QuestManager.quest_resolved.is_connected(on_quest_resolution_choice):
            QuestManager.quest_resolved.connect(on_quest_resolution_choice)
            if DebugConstants.ARC_LOG: print("[ARC] connected to QuestManager.quest_resolved")
        else:
            print("[ARC] QuestManager has no signal quest_resolved")     
    else:
        print("[ARC] QuestManagerRunner not found")
    return
func tick_day() -> void:
    var retaliations: Array[FactionRivalryArc] = notebook.tick_day(ARC_TTL_DAYS)
    for arc in retaliations:
        _spawn_retaliation_offer(arc)


func _make_rivalry_retaliation_offer(giver_faction_id: String, antagonist_faction_id: String, stage: int) -> QuestInstance:
    var t := QuestTemplate.new()
    t.id = "arc_rivalry_retaliation_s%d" % stage
    t.title = "Riposte contre %s" % giver_faction_id
    t.description = "Une faction prépare une riposte. (stage %d)" % stage
    t.category = QuestTypes.QuestCategory.COMBAT
    t.tier = QuestTypes.QuestTier.TIER_3
    t.objective_type = QuestTypes.ObjectiveType.CLEAR_COMBAT
    t.objective_target = antagonist_faction_id
    t.objective_count = 1
    t.expires_in_days = 3

    var ctx := {
        "is_arc_rivalry": true,
        "arc_stage": stage,
        "giver_faction_id": giver_faction_id,
        "antagonist_faction_id": antagonist_faction_id,
        "resolution_profile_id": "default_simple",
    }

    return QuestInstance.new(t, ctx) # IMPORTANT: ne pas start() => ça reste une OFFER


func reset() -> void:
    notebook.reset()

func _day() -> int:
    if WorldState != null and WorldState.has_method("get") and WorldState.get("current_day") != null:
        return int(WorldState.get("current_day"))
    return 0

func on_faction_hostile_action(attacker_id: String, defender_id: String, action_id: String, meta: Dictionary = {}) -> void:
    if attacker_id == "" or defender_id == "" or attacker_id == defender_id:
        return
    var arc := notebook.on_hostile_action(attacker_id, defender_id, action_id, meta)
    if arc == null:
        return
    _spawn_arc_offer(arc, "hostile_action")
    
func on_quest_resolution_choice(inst: QuestInstance, choice: String) -> void:
    notebook.on_quest_resolution_choice(inst, choice)

func _advance_stage(arc: FactionRivalryArc) -> void:
    if arc.stage < FactionRivalryArc.Stage.DECISIVE:
        arc.stage += 1
    else:
        arc.stage = FactionRivalryArc.Stage.RESOLVED

func _spawn_retaliation_offer(arc: FactionRivalryArc) -> void:
    # Représailles: on inverse giver/antagonist
    var inv := FactionRivalryArc.new()
    inv.id = arc.id
    inv.attacker_id = arc.defender_id
    inv.defender_id = arc.attacker_id
    inv.stage = arc.stage
    _spawn_arc_offer(inv, "retaliation")

func _spawn_arc_offer(arc: FactionRivalryArc, reason: String) -> void:
    # Crée une quête "combat" très contrôlée, pilotée par stage + contexte runtime
    var t := QuestTemplate.new()
    t.id = "arc_offer_%s_%d" % [arc.id, Time.get_ticks_msec()]
    t.category = QuestTypes.QuestCategory.COMBAT
    t.tier = QuestTypes.QuestTier.TIER_1
    t.objective_type = QuestTypes.ObjectiveType.CLEAR_COMBAT
    t.objective_target = arc.defender_id
    t.objective_count = 3 if (arc.stage == FactionRivalryArc.Stage.DECISIVE) else 1
    t.expires_in_days = OFFER_EXPIRE_DAYS

    match arc.stage:
        FactionRivalryArc.Stage.PROVOCATION:
            t.title = "Riposte contre %s" % arc.defender_id
            t.description = "Une provocation exige une réponse."
        FactionRivalryArc.Stage.ESCALATION:
            t.title = "Escarmouches contre %s" % arc.defender_id
            t.description = "La rivalité s’intensifie."
        FactionRivalryArc.Stage.DECISIVE:
            t.title = "Frappe décisive contre %s" % arc.defender_id
            t.description = "C’est le moment de frapper fort."
        _:
            t.title = "Conflit contre %s" % arc.defender_id

    var ctx: Dictionary = {
        "giver_faction_id": arc.attacker_id,
        "antagonist_faction_id": arc.defender_id,
        "resolution_profile_id": "default_simple",
        "is_arc_rivalry": true,
        "arc_id": arc.id,
        "arc_stage": arc.stage,
        "arc_reason": reason
    }

    var inst := QuestInstance.new(t, ctx)
    # Important: on veut une offer, pas une quête “active” immédiatement
    inst.status = QuestTypes.QuestStatus.AVAILABLE
    if DebugConstants.ARC_LOG:
            print("[ARC] created offer title=%s giver=%s ant=%s stage=%s reason=%s" % [
                inst.template.title,
                str(ctx.get("giver_faction_id","")),
                str(ctx.get("antagonist_faction_id","")),
                str(ctx.get("arc_stage","")),
                reason
            ])


    # Inject dans le pool (on reste compatible avec ton pattern Runner)
    if QuestPool != null and QuestPool.has_method("try_add_offer"):
        QuestPool.try_add_offer(inst)
    elif QuestOfferSimRunner != null and QuestOfferSimRunner.has_method("try_add_offer"):
        var ok :bool = QuestOfferSimRunner.try_add_offer(inst)
        if DebugConstants.ARC_LOG:
            print("[ARC] try_add_offer => %s (offers now=%d)" % [str(ok), QuestOfferSimRunner.offers.size()])
    else:
        print("[ArcManager] No offer sink found (QuestPool.try_add_offer missing).")
