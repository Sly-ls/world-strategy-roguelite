# res://src/arcs/RivalryNotebook.gd
extends RefCounted
class_name RivalryNotebook

const CHAIN_GAP_DAYS: int = 2

var rivalry_histories: Dictionary = {} # faction_id -> (rival_id -> RivalryHistory)

var arcs: Dictionary = {}          # arc_id -> FactionRivalryArc
var arcs_by_pair: Dictionary = {}  # "A|B" -> arc_id
var entry_by_arc_id: Dictionary = {}  # arc_id -> FactionRivalryHistoryEntry

func reset() -> void:
    rivalry_histories.clear()
    arcs.clear()
    arcs_by_pair.clear()
    entry_by_arc_id.clear()

func _day() -> int:
    if WorldState != null and WorldState.has_method("get") and WorldState.get("current_day") != null:
        return int(WorldState.get("current_day"))
    return 0

func _ensure_rivalry_history(faction_id: String, rival_id: String) -> RivalryHistory:
    if not rivalry_histories.has(faction_id):
        rivalry_histories[faction_id] = {}
    var by_rival: Dictionary = rivalry_histories[faction_id]
    if not by_rival.has(rival_id):
        var rh := RivalryHistory.new()
        rh.faction_id = faction_id
        rh.rival_id = rival_id
        if FactionManager != null and FactionManager.has_method("get_faction"):
            var f = FactionManager.get_faction(faction_id)
            rh.faction_label = f.name if f != null else faction_id
        by_rival[rival_id] = rh
    return by_rival[rival_id] as RivalryHistory

func _pair_key(a: String, b: String) -> String:
    return "%s|%s" % [a, b]

func ensure_arc(attacker_id: String, defender_id: String, reason: String, meta: Dictionary = {}) -> FactionRivalryArc:
    var key := _pair_key(attacker_id, defender_id)
    if arcs_by_pair.has(key):
        return arcs[String(arcs_by_pair[key])] as FactionRivalryArc

    var d := _day()
    var arc := FactionRivalryArc.new()
    arc.id = "arc_rivalry_%s_%s_%d" % [attacker_id, defender_id, Time.get_ticks_msec()]
    arc.attacker_id = attacker_id
    arc.defender_id = defender_id
    arc.started_day = d
    arc.last_event_day = d
    arc.stage = FactionRivalryArc.Stage.PROVOCATION
    arc.pending_retaliation = false

    arcs[arc.id] = arc
    arcs_by_pair[key] = arc.id

    # Create history entry now (opened rivalry)
    var e := FactionRivalryHistoryEntry.new()
    e.id = arc.id
    e.attacker_id = attacker_id
    e.defender_id = defender_id
    e.started_day = d
    e.ended_day = -1
    e.trigger_reason = reason
    if meta.size() > 0:
        e.meta = meta
    entry_by_arc_id[arc.id] = e

    # Record into histories (both perspectives) with snapshots if you have them
    _record_entry_open(e)

    return arc

func _record_entry_open(e: FactionRivalryHistoryEntry) -> void:
    var d := _day()
    var rel_att := _get_relation_snapshot(e.attacker_id, e.defender_id)
    var rel_def := _get_relation_snapshot(e.defender_id, e.attacker_id)

    _ensure_rivalry_history(e.attacker_id, e.defender_id).add_entry(e, d, rel_att)
    _ensure_rivalry_history(e.defender_id, e.attacker_id).add_entry(e, d, rel_def)

func close_arc(arc_id: String, end_reason: String) -> void:
    if not entry_by_arc_id.has(arc_id):
        return
    var e: FactionRivalryHistoryEntry = entry_by_arc_id[arc_id]
    if e.ended_day >= 0:
        return # already closed
    var d := _day()
    e.ended_day = d
    e.end_reason = end_reason

    # Refresh counters + durations for both histories
    _ensure_rivalry_history(e.attacker_id, e.defender_id).refresh_counters(d)
    _ensure_rivalry_history(e.defender_id, e.attacker_id).refresh_counters(d)

func on_hostile_action(attacker_id: String, defender_id: String, action_id: String, meta: Dictionary = {}) -> FactionRivalryArc:
    if attacker_id == "" or defender_id == "" or attacker_id == defender_id:
        return null
    var arc := ensure_arc(attacker_id, defender_id, "hostile_action", meta)
    arc.last_event_day = _day()
    return arc
 
func on_quest_resolution_choice(inst: QuestInstance, choice: String) -> void:
    if inst == null:
        return

    var ctx: Dictionary = inst.context
    if not bool(ctx.get("is_arc_rivalry", false)):
        return

    var arc_id := String(ctx.get("arc_id", ""))
    if arc_id == "" or not arcs.has(arc_id):
        return

    var arc: FactionRivalryArc = arcs[arc_id]
    arc.last_event_day = _day()

    # progression MVP
    if choice == "LOYAL":
        if arc.stage < FactionRivalryArc.Stage.DECISIVE:
            arc.stage += 1
        else:
            arc.stage = FactionRivalryArc.Stage.RESOLVED

    # retaliation always (MVP)
    arc.pending_retaliation = true

    # if resolved -> close immediately (retaliation won't matter anymore)
    if arc.stage == FactionRivalryArc.Stage.RESOLVED:
        close_arc(arc.id, "resolved_choice_%s" % choice)

func tick_day(ttl_days: int) -> Array[FactionRivalryArc]:
    var d := _day()

    # 1) expire inactive arcs (TTL)
    var to_remove: Array[String] = []
    for arc_id in arcs.keys():
        var arc: FactionRivalryArc = arcs[arc_id]
        if (d - arc.last_event_day) >= ttl_days:
            close_arc(arc.id, "ttl_expired")
            to_remove.append(arc_id)

    for arc_id in to_remove:
        var arc: FactionRivalryArc = arcs[arc_id]
        arcs.erase(arc_id)
        arcs_by_pair.erase(_pair_key(arc.attacker_id, arc.defender_id))
        entry_by_arc_id.erase(arc_id)

    # 2) retaliation list (ArcManager will spawn offers)
    var ret: Array[FactionRivalryArc] = []
    for arc_id in arcs.keys():
        var arc: FactionRivalryArc = arcs[arc_id]
        if arc.pending_retaliation and arc.stage < FactionRivalryArc.Stage.RESOLVED:
            arc.pending_retaliation = false
            ret.append(arc)

    # 3) refresh counters (optional, cheap)
    for faction_id in rivalry_histories.keys():
        var by_rival: Dictionary = rivalry_histories[faction_id]
        for rival_id in by_rival.keys():
            (by_rival[rival_id] as RivalryHistory).refresh_counters(d)

    return ret

func _get_relation_snapshot(a: String, b: String) -> int:
    # Si tu as un système de relation inter-factions, branche-le ici.
    # Sinon return 0 (ça garde best/worst cohérent même si neutre).
    if FactionManager != null and FactionManager.has_method("get_relation"):
        return int(FactionManager.get_relation_between(a, b))
    return 0
