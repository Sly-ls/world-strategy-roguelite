# ArcNotebook.gd
# Central history + metrics registry for arc system
class_name ArcNotebook
extends RefCounted

# --- Per-faction history ---
var history_by_faction: Dictionary[StringName, ArcHistory] = {}

# --- Per-pair tracking ---
var pairs: Dictionary[StringName, ArcPairHistory] = {}
var pair_heats: Dictionary[StringName, PairHeat] = {}

# --- Offer management ---
var last_offer_refresh_day_by_pair: Dictionary[StringName, int] = {}
var refresh_attempts_by_pair: Dictionary[StringName, int] = {}

# --- Event logging (for debugging/metrics) ---
var pair_events: Array = []
var pair_heat_by_key: Dictionary[StringName, PairHeat] = {} # "a|b" -> heat

# =============================================================================
# Pair Key Utilities
# =============================================================================
static func pair_key(a: StringName, b: StringName) -> StringName:
    var sa := String(a)
    var sb := String(b)
    return StringName(sa + "|" + sb) if sa <= sb else StringName(sb + "|" + sa)

# =============================================================================
# Per-Faction History
# =============================================================================
func get_history(faction_id: StringName) -> ArcHistory:
    if not history_by_faction.has(faction_id):
        history_by_faction[faction_id] = ArcHistory.new(faction_id)
    return history_by_faction[faction_id]

# =============================================================================
# Per-Pair History
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
func get_pair_heat_OLD(a: StringName, b: StringName) -> PairHeat:
    var k := pair_key(a, b)
    if not pair_heats.has(k):
        pair_heats[k] = PairHeat.new()
    return pair_heats[k]
    
func get_pair_heat(self_id: StringName, other_id: StringName, day: int=0, decay_per_day: float = 0.93) -> Dictionary:
    var key := pair_key(self_id, other_id)
    var heat: PairHeat = pair_heat_by_key.get(key, null)
    if heat == null:
        return {"hostile_from_other":0.0, "friendly_from_other":0.0, "hostile_to_other":0.0, "friendly_to_other":0.0}

    heat.decay_to(day, decay_per_day)

    # Reconstituer le sens self->other / other->self
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
        ArcDecisionUtil.ARC_DECLARE_WAR:   return 3.0
        ArcDecisionUtil.ARC_RAID:          return 1.0
        ArcDecisionUtil.ARC_SABOTAGE:      return 1.2
        ArcDecisionUtil.ARC_ULTIMATUM:     return 0.8
        ArcDecisionUtil.ARC_TRUCE_TALKS:   return 1.2
        ArcDecisionUtil.ARC_REPARATIONS:   return 1.0
        ArcDecisionUtil.ARC_ALLIANCE_OFFER:return 1.6
        _:                                 return 1.0
func record_pair_event_OLD(attacker: StringName, defender: StringName, action: StringName, day: int) -> void:
    var key := pair_key(attacker, defender)
    var heat: PairHeat = pair_heat_by_key.get(key, null)
    if heat == null:
        heat = PairHeat.new()
        heat.last_day = day
        pair_heat_by_key[key] = heat
    heat.decay_to(day)

    var sev := _severity_for_action(action)
    var a_is_first := (String(attacker) <= String(defender))

    if ArcStateMachine.is_hostile_action(action):
        if a_is_first:
            heat.hostile_ab += sev
        else:
            heat.hostile_ba += sev
    elif ArcStateMachine.is_peace_action(action):
        if a_is_first:
            heat.friendly_ab += sev
        else:
            heat.friendly_ba += sev
"""
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
    
    # Update pair heat if it's a hostile/peace action
    var heat := get_pair_heat(a, b)
    var delta := _action_heat_delta(action)
    if delta != 0:
        heat.add_contribution(a, delta, day)
        
        
"""
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
# Relation Cap Calculation (based on history)
# =============================================================================
func compute_relation_cap_pct(a: StringName, b: StringName) -> float:
    # Returns 0.10..0.30 based on history between factions
    var pair_hist := get_pair(a, b)
    var total := pair_hist.get_total_count()
    
    # More history = lower cap (more gradual changes)
    # Base: 30%, reduces by ~2% per 5 interactions, min 10%
    var cap := 0.30 - (float(total) / 5.0) * 0.02
    return clampf(cap, 0.10, 0.30)

# =============================================================================
# Query Events
# =============================================================================
func get_events_for_pair(a: StringName, b: StringName) -> Array:
    var k := pair_key(a, b)
    var result: Array = []
    for e in pair_events:
        var ek := pair_key(e["a"], e["b"])
        if ek == k:
            result.append(e)
    return result

func count_events_by_action(action: StringName) -> int:
    var count := 0
    for e in pair_events:
        if e["action"] == action:
            count += 1
    return count
