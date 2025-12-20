# ArcNotebook.gd
# Central history + metrics registry for arc system
# Utilise ArcHistory et ArcTargetMeta (remplace RivalryHistory et FactionRivalryHistoryEntry)
class_name ArcNotebook
extends RefCounted

const CHAIN_GAP_DAYS: int = 2
const ARC_TTL_DAYS: int = 30

# =============================================================================
# Arcs actifs (remplace les références à FactionRivalryArc)
# =============================================================================
# Structure d'un arc actif (Dictionary):
# {
#   "id": String,
#   "attacker_id": StringName,
#   "defender_id": StringName,
#   "stage": int,  # 1=PROVOCATION, 2=ESCALATION, 3=DECISIVE, 4=RESOLVED
#   "started_day": int,
#   "last_event_day": int,
#   "pending_retaliation": bool
# }

var arcs: Dictionary = {}              # arc_id -> arc Dictionary
var arcs_by_pair: Dictionary = {}      # "A|B" -> arc_id

# =============================================================================
# Per-faction history (ArcHistory contient ArcTargetMeta par cible)
# =============================================================================
var history_by_faction: Dictionary = {}    # StringName -> ArcHistory

# =============================================================================
# Per-pair tracking
# =============================================================================
var pairs: Dictionary = {}                 # StringName -> ArcPairHistory
var pair_heats: Dictionary = {}            # StringName -> PairHeat
var pair_heat_by_key: Dictionary = {}      # "a|b" -> PairHeat

# =============================================================================
# Offer management
# =============================================================================
var last_offer_refresh_day_by_pair: Dictionary = {}  # StringName -> int
var refresh_attempts_by_pair: Dictionary = {}        # StringName -> int

# =============================================================================
# Event logging (for debugging/metrics)
# =============================================================================
var pair_events: Array = []

# =============================================================================
# Pair locks (for coalition truces, treaties, etc.)
# =============================================================================
var pair_locks: Dictionary = {}            # StringName -> { "until": int, "reason": StringName }

# =============================================================================
# Pair counters (generic counters per pair: wars, treaty_breaks, etc.)
# =============================================================================
var pair_counters: Dictionary = {}         # StringName -> { counter_name -> int }


# =============================================================================
# Arc Stage Constants (remplace FactionRivalryArc.Stage)
# =============================================================================
const STAGE_PROVOCATION: int = 1
const STAGE_ESCALATION: int = 2
const STAGE_DECISIVE: int = 3
const STAGE_RESOLVED: int = 4


# =============================================================================
# Reset
# =============================================================================
func reset() -> void:
    arcs.clear()
    arcs_by_pair.clear()
    history_by_faction.clear()
    pairs.clear()
    pair_heats.clear()
    pair_heat_by_key.clear()
    last_offer_refresh_day_by_pair.clear()
    refresh_attempts_by_pair.clear()
    pair_events.clear()
    pair_locks.clear()
    pair_counters.clear()


# =============================================================================
# Utilities
# =============================================================================
func _day() -> int:
    if WorldState != null and WorldState.has_method("get") and WorldState.get("current_day") != null:
        return int(WorldState.get("current_day"))
    return 0

## Instance version (non-normalisée, garde l'ordre attacker|defender)
func _pair_key(a: String, b: String) -> String:
    return "%s|%s" % [a, b]

## Static version avec StringName, normalisée (a|b où a <= b)
static func pair_key(a: StringName, b: StringName) -> StringName:
    var sa := String(a)
    var sb := String(b)
    return StringName(sa + "|" + sb) if sa <= sb else StringName(sb + "|" + sa)

## Retourne le nom du stage
static func stage_name(stage: int) -> String:
    match stage:
        STAGE_PROVOCATION: return "PROVOCATION"
        STAGE_ESCALATION: return "ESCALATION"
        STAGE_DECISIVE: return "DECISIVE"
        STAGE_RESOLVED: return "RESOLVED"
        _: return "UNKNOWN"


# =============================================================================
# Per-Faction History (ArcHistory)
# =============================================================================
func get_history(faction_id: StringName) -> ArcHistory:
    if not history_by_faction.has(faction_id):
        history_by_faction[faction_id] = ArcHistory.new(faction_id)
    return history_by_faction[faction_id]


# =============================================================================
# Arc Management (remplace RivalryNotebook)
# =============================================================================

## Crée un nouvel arc Dictionary
func _create_arc(arc_id: String, attacker_id: StringName, defender_id: StringName, day: int) -> Dictionary:
    return {
        "id": arc_id,
        "attacker_id": attacker_id,
        "defender_id": defender_id,
        "stage": STAGE_PROVOCATION,
        "started_day": day,
        "last_event_day": day,
        "pending_retaliation": false
    }

## Assure qu'un arc existe pour la paire attacker->defender
func ensure_arc(attacker_id: StringName, defender_id: StringName, reason: StringName, meta: Dictionary = {}) -> Dictionary:
    var key := _pair_key(String(attacker_id), String(defender_id))
    if arcs_by_pair.has(key):
        return arcs[String(arcs_by_pair[key])]

    var d := _day()
    var arc_id := "arc_%s_%s_%d" % [String(attacker_id), String(defender_id), Time.get_ticks_msec()]
    var arc := _create_arc(arc_id, attacker_id, defender_id, d)

    arcs[arc_id] = arc
    arcs_by_pair[key] = arc_id

    # Créer l'entrée dans l'historique des deux factions
    var trigger_action := StringName(meta.get("action_id", ""))
    
    # Historique attacker -> defender
    var attacker_history := get_history(attacker_id)
    attacker_history.add_rivalry_entry(
        defender_id,
        arc_id,
        attacker_id,
        defender_id,
        d,
        d,
        _get_relation_snapshot(String(attacker_id), String(defender_id)),
        trigger_action,
        reason
    )
    
    # Historique defender -> attacker
    var defender_history := get_history(defender_id)
    defender_history.add_rivalry_entry(
        attacker_id,
        arc_id,
        attacker_id,
        defender_id,
        d,
        d,
        _get_relation_snapshot(String(defender_id), String(attacker_id)),
        trigger_action,
        reason
    )

    return arc

## Ferme un arc
func close_arc(arc_id: String, end_reason: StringName) -> void:
    if not arcs.has(arc_id):
        return
    
    var arc: Dictionary = arcs[arc_id]
    var d := _day()
    
    var attacker_id: StringName = arc.get("attacker_id", &"")
    var defender_id: StringName = arc.get("defender_id", &"")
    var stage: int = arc.get("stage", STAGE_PROVOCATION)
    
    # Fermer dans l'historique attacker
    if history_by_faction.has(attacker_id):
        history_by_faction[attacker_id].close_rivalry_entry(
            defender_id, arc_id, d, end_reason, &"", stage
        )
    
    # Fermer dans l'historique defender
    if history_by_faction.has(defender_id):
        history_by_faction[defender_id].close_rivalry_entry(
            attacker_id, arc_id, d, end_reason, &"", stage
        )

## Récupère un arc par ID
func get_arc(arc_id: String) -> Dictionary:
    return arcs.get(arc_id, {})

## Récupère un arc par paire
func get_arc_for_pair(attacker_id: StringName, defender_id: StringName) -> Dictionary:
    var key := _pair_key(String(attacker_id), String(defender_id))
    if arcs_by_pair.has(key):
        return arcs.get(String(arcs_by_pair[key]), {})
    return {}

## Vérifie si un arc est actif
func is_arc_active(arc: Dictionary) -> bool:
    return int(arc.get("stage", STAGE_RESOLVED)) < STAGE_RESOLVED

## Action hostile
func on_hostile_action(attacker_id: StringName, defender_id: StringName, action_id: StringName, meta: Dictionary = {}) -> Dictionary:
    if attacker_id == &"" or defender_id == &"" or attacker_id == defender_id:
        return {}
    
    meta["action_id"] = action_id
    var arc := ensure_arc(attacker_id, defender_id, &"hostile_action", meta)
    arc["last_event_day"] = _day()
    return arc

## Résolution de quête
func on_quest_resolution_choice(inst: QuestInstance, choice: String) -> void:
    if inst == null:
        return

    var ctx: Dictionary = inst.context if inst.context != null else {}
    if not bool(ctx.get("is_arc_rivalry", false)):
        return
        
    var arc_id := String(ctx.get("arc_id", ""))
    if arc_id == "" or not arcs.has(arc_id):
        return

    var arc: Dictionary = arcs[arc_id]
    arc["last_event_day"] = _day()

    # Progression MVP
    if choice == "LOYAL":
        var stage: int = arc.get("stage", STAGE_PROVOCATION)
        if stage < STAGE_DECISIVE:
            arc["stage"] = stage + 1
        else:
            arc["stage"] = STAGE_RESOLVED

    # Retaliation always (MVP)
    arc["pending_retaliation"] = true

    # Si résolu -> fermer immédiatement
    if int(arc.get("stage", STAGE_PROVOCATION)) == STAGE_RESOLVED:
        close_arc(arc_id, StringName("resolved_choice_%s" % choice))
        
    # Mettre à jour resolution_choice dans les historiques
    var attacker_id: StringName = arc.get("attacker_id", &"")
    var defender_id: StringName = arc.get("defender_id", &"")
    
    if history_by_faction.has(attacker_id):
        var entry :Dictionary = history_by_faction[attacker_id].find_entry(arc_id)
        if not entry.is_empty():
            entry["resolution_choice"] = StringName(choice)
    
    if history_by_faction.has(defender_id):
        var entry :Dictionary = history_by_faction[defender_id].find_entry(arc_id)
        if not entry.is_empty():
            entry["resolution_choice"] = StringName(choice)

## Tick journalier - retourne les arcs avec retaliation pending
func tick_day(ttl_days: int = ARC_TTL_DAYS) -> Array[Dictionary]:
    var d := _day()

    # 1) Expire inactive arcs (TTL)
    var to_remove: Array[String] = []
    for arc_id in arcs.keys():
        var arc: Dictionary = arcs[arc_id]
        var last_event := int(arc.get("last_event_day", 0))
        if (d - last_event) >= ttl_days:
            close_arc(arc_id, &"ttl_expired")
            to_remove.append(arc_id)

    for arc_id in to_remove:
        var arc: Dictionary = arcs[arc_id]
        var attacker_id := String(arc.get("attacker_id", ""))
        var defender_id := String(arc.get("defender_id", ""))
        arcs.erase(arc_id)
        arcs_by_pair.erase(_pair_key(attacker_id, defender_id))

    # 2) Retaliation list
    var ret: Array[Dictionary] = []
    for arc_id in arcs.keys():
        var arc: Dictionary = arcs[arc_id]
        if bool(arc.get("pending_retaliation", false)) and is_arc_active(arc):
            arc["pending_retaliation"] = false
            ret.append(arc)

    # 3) Refresh counters
    for faction_id in history_by_faction.keys():
        history_by_faction[faction_id].refresh_all_counters(d)

    return ret

func _get_relation_snapshot(a: String, b: String) -> int:
    if FactionManager != null and FactionManager.has_method("get_relation_between"):
        return int(FactionManager.get_relation_between(a, b))
    return 0


# =============================================================================
# Per-Pair History (ArcPairHistory)
# =============================================================================
func get_pair(a: StringName, b: StringName) -> ArcPairHistory:
    var k := pair_key(a, b)
    if not pairs.has(k):
        pairs[k] = ArcPairHistory.new()
    return pairs[k]

func register(a: StringName, b: StringName, arc_type: StringName, day: int) -> void:
    get_pair(a, b).register(arc_type, day)


# =============================================================================
# Pair Heat (for targeting/priority)
# =============================================================================
func get_pair_heat_obj(a: StringName, b: StringName) -> PairHeat:
    var k := pair_key(a, b)
    if not pair_heats.has(k):
        pair_heats[k] = PairHeat.new()
    return pair_heats[k]

func get_pair_heat(self_id: StringName, other_id: StringName, day: int = 0, decay_per_day: float = 0.93) -> Dictionary:
    var key := pair_key(self_id, other_id)
    var heat: PairHeat = pair_heat_by_key.get(key, null)
    if heat == null:
        return {"hostile_from_other": 0.0, "friendly_from_other": 0.0, "hostile_to_other": 0.0, "friendly_to_other": 0.0}

    heat.decay_to(day, decay_per_day)

    var self_is_first := (String(self_id) <= String(other_id))
    var hostile_to_other := heat.hostile_ab if self_is_first else heat.hostile_ba
    var friendly_to_other := heat.friendly_ab if self_is_first else heat.friendly_ba
    var hostile_from_other := heat.hostile_ba if self_is_first else heat.hostile_ab
    var friendly_from_other := heat.friendly_ba if self_is_first else heat.friendly_ab

    return {
        "hostile_from_other": hostile_from_other,
        "friendly_from_other": friendly_from_other,
        "hostile_to_other": hostile_to_other,
        "friendly_to_other": friendly_to_other
    }


# =============================================================================
# Event Recording (unified logging)
# =============================================================================
static func _severity_for_action(action: StringName) -> float:
    match action:
        &"arc.declare_war":    return 3.0
        &"arc.raid":           return 1.0
        &"arc.sabotage":       return 1.2
        &"arc.ultimatum":      return 0.8
        &"arc.truce_talks":    return 1.2
        &"arc.reparations":    return 1.0
        &"arc.alliance_offer": return 1.6
        _:                     return 1.0

static func _action_heat_delta(action: StringName) -> int:
    match action:
        &"arc.raid", &"arc.sabotage":
            return 8
        &"arc.ultimatum":
            return 12
        &"arc.declare_war":
            return 20
        &"arc.truce_talks", &"arc.reparations":
            return -5
        &"arc.alliance_offer":
            return -10
        _:
            return 0

func record_pair_event(
    day: int,
    a: StringName,
    b: StringName,
    action: StringName,
    choice: StringName = &"",
    meta: Dictionary = {}
) -> void:
    # Store event for metrics/debugging
    pair_events.append({
        "day": day,
        "a": a,
        "b": b,
        "action": action,
        "choice": choice,
        "meta": meta
    })
    
    # Update pair history
    get_pair(a, b).register(action, day)
    
    # Update pair heat
    var key := pair_key(a, b)
    var heat: PairHeat = pair_heat_by_key.get(key, null)
    if heat == null:
        heat = PairHeat.new()
        heat.last_day = day
        pair_heat_by_key[key] = heat
    heat.decay_to(day)
    
    var sev := _severity_for_action(action)
    var a_is_first := (String(a) <= String(b))
    
    var delta := _action_heat_delta(action)
    if delta > 0:  # hostile
        if a_is_first:
            heat.hostile_ab += sev
        else:
            heat.hostile_ba += sev
    elif delta < 0:  # friendly
        if a_is_first:
            heat.friendly_ab += sev
        else:
            heat.friendly_ba += sev


# =============================================================================
# Offer Refresh Cooldown
# =============================================================================
func can_refresh_offer_for_pair(pair_key_str: StringName, day: int, cooldown_days: int = 5) -> bool:
    var last := int(last_offer_refresh_day_by_pair.get(pair_key_str, -999999))
    return (day - last) >= cooldown_days

func mark_offer_refreshed_for_pair(pair_key_str: StringName, day: int) -> void:
    last_offer_refresh_day_by_pair[pair_key_str] = day

func mark_refresh_attempt_for_pair(pair_key_str: StringName) -> int:
    var n := int(refresh_attempts_by_pair.get(pair_key_str, 0)) + 1
    refresh_attempts_by_pair[pair_key_str] = n
    return n


# =============================================================================
# Third Party Offers (cooldown for mediation/intervention offers)
# =============================================================================
func can_spawn_third_party(pair_key_str: StringName, day: int, cooldown_days: int = 7) -> bool:
    return can_refresh_offer_for_pair(pair_key_str, day, cooldown_days)

func mark_third_party_spawned(pair_key_str: StringName, day: int) -> void:
    mark_offer_refreshed_for_pair(pair_key_str, day)


# =============================================================================
# Coalition Offers (cooldown)
# =============================================================================
func can_spawn_coalition_offer(coalition_id: StringName, day: int, cooldown_days: int = 5) -> bool:
    var key := StringName("coalition:" + String(coalition_id))
    var last := int(last_offer_refresh_day_by_pair.get(key, -999999))
    return (day - last) >= cooldown_days

func mark_coalition_offer_spawned(coalition_id: StringName, day: int) -> void:
    var key := StringName("coalition:" + String(coalition_id))
    last_offer_refresh_day_by_pair[key] = day

func mark_coalition_dissolved(coalition_id: StringName, day: int, reason: StringName) -> void:
    pair_events.append({
        "day": day,
        "a": coalition_id,
        "b": &"",
        "action": &"coalition_dissolved",
        "choice": reason,
        "meta": {}
    })

func record_coalition_event(data: Dictionary) -> void:
    pair_events.append(data)


# =============================================================================
# Pair Locks (for coalition truces, treaties, etc.)
# =============================================================================
func set_pair_lock(pair_key_str: StringName, until_day: int, reason: StringName = &"") -> void:
    pair_locks[pair_key_str] = {"until": until_day, "reason": reason}

func is_pair_locked(pair_key_str: StringName, day: int) -> bool:
    if not pair_locks.has(pair_key_str):
        return false
    var lock: Dictionary = pair_locks[pair_key_str]
    return day < int(lock.get("until", 0))

func get_pair_lock_reason(pair_key_str: StringName) -> StringName:
    if not pair_locks.has(pair_key_str):
        return &""
    return StringName(pair_locks[pair_key_str].get("reason", &""))

func clear_pair_lock(pair_key_str: StringName) -> void:
    pair_locks.erase(pair_key_str)


# =============================================================================
# Pair Counters (generic counters per pair: wars, treaty_breaks, etc.)
# =============================================================================
func get_pair_counter(pair_key_str: StringName, counter_name: StringName, default_val: int = 0) -> int:
    if not pair_counters.has(pair_key_str):
        return default_val
    return int(pair_counters[pair_key_str].get(counter_name, default_val))

func set_pair_counter(pair_key_str: StringName, counter_name: StringName, value: int) -> void:
    if not pair_counters.has(pair_key_str):
        pair_counters[pair_key_str] = {}
    pair_counters[pair_key_str][counter_name] = value

func inc_pair_counter(pair_key_str: StringName, counter_name: StringName, delta: int = 1) -> int:
    var current := get_pair_counter(pair_key_str, counter_name, 0)
    var new_val := current + delta
    set_pair_counter(pair_key_str, counter_name, new_val)
    return new_val


# =============================================================================
# Relation Cap Calculation (based on history)
# =============================================================================
func compute_relation_cap_pct(a: StringName, b: StringName) -> float:
    var pair_hist := get_pair(a, b)
    var total := pair_hist.get_total_count()
    
    var cap := 0.30 - (float(total) / 5.0) * 0.02
    return clampf(cap, 0.10, 0.30)


# =============================================================================
# Query Events
# =============================================================================
func get_events_for_pair(a: StringName, b: StringName) -> Array:
    var k := pair_key(a, b)
    var result: Array = []
    for e in pair_events:
        if e.has("a") and e.has("b"):
            var ek := pair_key(e["a"], e["b"])
            if ek == k:
                result.append(e)
    return result

func count_events_by_action(action: StringName) -> int:
    var count := 0
    for e in pair_events:
        if e.get("action", &"") == action:
            count += 1
    return count

func get_recent_events(limit: int = 20) -> Array:
    var start :int = max(0, pair_events.size() - limit)
    return pair_events.slice(start)
