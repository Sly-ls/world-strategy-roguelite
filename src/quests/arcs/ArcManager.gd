# res://src/arcs/ArcManager.gd
extends Node
class_name ArcManager

const ARC_TTL_DAYS: int = 30
const OFFER_EXPIRE_DAYS: int = 5

var arcs: Dictionary = {}          # arc_id -> FactionRivalryArc
var arcs_by_pair: Dictionary = {}  # "A|B" -> arc_id

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

func _on_quest_resolved(inst: QuestInstance, choice: String) -> void:
    if inst == null:
        return
    if DebugConstants.ARC_LOG:
        print("[ARC] on_quest_resolved choice=%s title=%s is_arc=%s arc_id=%s stage=%s" % [
            choice,
            inst.template.title,
            str(inst.context.get("is_arc_rivalry", false)),
            str(inst.context.get("arc_id", "")),
            str(inst.context.get("arc_stage", "")),
        ])

    if not bool(inst.context.get("is_arc_rivalry", false)):
        if DebugConstants.ARC_LOG: print("[ARC] skip: not an arc quest")
        return

    if choice != "LOYAL":
        if DebugConstants.ARC_LOG: print("[ARC] skip: choice != LOYAL")
        return
        
    var ctx := inst.context
    if not bool(ctx.get("is_arc_rivalry", false)):
        return

    var arc_id := String(ctx.get("arc_id", ""))
    if arc_id == "":
        if DebugConstants.ARC_LOG: print("[ARC] skip: missing arc_id")
        return

    var arc :FactionRivalryArc = arcs.get(arc_id, null) # arcs: Dictionary arc_id -> FactionRivalryArc
    if arc == null:
        # fallback: reconstruire à partir du context si besoin
        arc = FactionRivalryArc.new()
        arc.id = arc_id
        arc.attacker_id = String(ctx.get("giver_faction_id", ""))
        arc.defender_id = String(ctx.get("antagonist_faction_id", ""))
        arc.stage = int(ctx.get("arc_stage", 1))
        arc.pending_retaliation = true
        arcs[arc_id] = arc
        if DebugConstants.ARC_LOG: print("[ARC] arc not found in dict, rebuilding from ctx")
    if DebugConstants.ARC_LOG:
        print("[ARC] spawning retaliation from attacker=%s defender=%s stage=%d" % [
            arc.attacker_id, arc.defender_id, arc.stage
        ])

    call_deferred("_spawn_retaliation_for_arc", arc.id)
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
    arcs.clear()
    arcs_by_pair.clear()

func _day() -> int:
    if WorldState != null and WorldState.has_method("get") and WorldState.get("current_day") != null:
        return int(WorldState.get("current_day"))
    return 0

func _ensure_arc(attacker_id: String, defender_id: String) -> FactionRivalryArc:
    var key: String = "%s|%s" % [attacker_id, defender_id]
    if arcs_by_pair.has(key):
        var arc_id: String = String(arcs_by_pair[key])
        return arcs[arc_id] as FactionRivalryArc

    var arc := FactionRivalryArc.new()
    arc.id = "arc_rivalry_%s_%s_%d" % [attacker_id, defender_id, Time.get_ticks_msec()]
    arc.attacker_id = attacker_id
    arc.defender_id = defender_id
    arc.started_day = _day()
    arc.last_event_day = _day()

    arcs[arc.id] = arc
    arcs_by_pair[key] = arc.id
    return arc

func on_faction_hostile_action(attacker_id: String, defender_id: String, action_id: String, meta: Dictionary = {}) -> void:
    if attacker_id == "" or defender_id == "" or attacker_id == defender_id:
        return

    var arc := _ensure_arc(attacker_id, defender_id)
    arc.last_event_day = _day()

    # MVP: chaque action hostile => on essaye de produire une offer d'arc (cap/validité gérés ailleurs)
    _spawn_arc_offer(arc, "hostile_action")
func on_quest_resolution_choice(inst: QuestInstance, choice: String) -> void:
    if inst == null:
        return

    var ctx: Dictionary = inst.context

    if DebugConstants.ARC_LOG:
        print("[ARC] quest_resolution choice=%s title=%s is_arc=%s arc_id=%s stage=%s giver=%s ant=%s" % [
            choice,
            inst.template.title,
            str(ctx.get("is_arc_rivalry", false)),
            str(ctx.get("arc_id", "")),
            str(ctx.get("arc_stage", "")),
            str(ctx.get("giver_faction_id", "")),
            str(ctx.get("antagonist_faction_id", "")),
        ])

    if not bool(ctx.get("is_arc_rivalry", false)):
        if DebugConstants.ARC_LOG: print("[ARC] skip: not an arc quest")
        return

    var arc_id := String(ctx.get("arc_id", ""))
    if arc_id == "":
        if DebugConstants.ARC_LOG: print("[ARC] skip: missing arc_id")
        return

    # 1) Get or rebuild arc from ctx
    var arc: FactionRivalryArc = arcs.get(arc_id, null)
    if arc == null:
        arc = FactionRivalryArc.new()
        arc.id = arc_id
        arc.attacker_id = String(ctx.get("giver_faction_id", ""))
        arc.defender_id = String(ctx.get("antagonist_faction_id", ""))
        arc.stage = int(ctx.get("arc_stage", 1))
        arcs[arc_id] = arc
        if DebugConstants.ARC_LOG: print("[ARC] arc rebuilt from ctx id=%s" % arc_id)

    arc.last_event_day = _day()

    # 2) MVP progression
    if choice == "LOYAL":
        _advance_stage(arc)

    # 3) Retaliation flag (spawned by tick_day, not immediately)
    arc.pending_retaliation = true

    if DebugConstants.ARC_LOG:
        print("[ARC] pending_retaliation=true for arc=%s (attacker=%s defender=%s stage=%d)" % [
            arc.id, arc.attacker_id, arc.defender_id, arc.stage
        ])

func on_quest_resolution_choice_OLD(inst: QuestInstance, choice: String) -> void:
    if inst == null:
        return

    var ctx: Dictionary = inst.context
    if not bool(ctx.get("is_arc_rivalry", false)):
        return

    var arc_id: String = String(ctx.get("arc_id", ""))
    if arc_id == "" or not arcs.has(arc_id):
        return

    var arc := arcs[arc_id] as FactionRivalryArc
    arc.last_event_day = _day()

    # MVP progression ultra simple
    if choice == "LOYAL":
        _advance_stage(arc)
        arc.pending_retaliation = true
    elif choice == "NEUTRAL":
        arc.pending_retaliation = true
    elif choice == "TRAITOR":
        arc.pending_retaliation = true
    
    print("ON PASSE ICIIIIIIIIIIIIIIIIIII")
    
func tick_day() -> void:
    var d := _day()

    # Expire arcs inactifs
    var to_remove: Array[String] = []
    for arc_id in arcs.keys():
        var arc := arcs[arc_id] as FactionRivalryArc
        if (d - arc.last_event_day) >= ARC_TTL_DAYS:
            to_remove.append(arc_id)

    for arc_id in to_remove:
        var arc := arcs[arc_id] as FactionRivalryArc
        arcs.erase(arc_id)
        arcs_by_pair.erase(arc.pair_key())

    # Retaliation (1 règle)
    for arc_id in arcs.keys():
        var arc := arcs[arc_id] as FactionRivalryArc
        if arc.pending_retaliation:
            arc.pending_retaliation = false
            _spawn_retaliation_offer(arc)

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
func _spawn_retaliation_for_arc(arc_id: String) -> void:
    var arc :FactionRivalryArc = arcs.get(arc_id, null)
    if arc == null:
        return
    if not arc.pending_retaliation:
        return

    if DebugConstants.ARC_LOG:
        print("[ARC] spawning retaliation arc_id=%s stage=%d %s->%s" % [
            arc.id, arc.stage, arc.attacker_id, arc.defender_id
        ])

    _spawn_retaliation_offer(arc)
    arc.pending_retaliation = false
