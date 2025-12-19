class_name ArcPolicy
extends RefCounted

const BUNDLE_BY_STATE: Dictionary = {
    &"NEUTRAL":  {"count_min": 0, "count_max": 1},  # souvent 0 (pas d’offre) ou 1 incident
    &"RIVALRY":  {"count_min": 1, "count_max": 1},  # lisible : 1 offer max
    &"CONFLICT": {"count_min": 1, "count_max": 2},
    &"WAR":      {"count_min": 2, "count_max": 3},  # WAR => plusieurs fronts
    &"TRUCE":    {"count_min": 1, "count_max": 2},
    &"ALLIANCE": {"count_min": 1, "count_max": 2},
}

# Actions autorisées selon l’état
const ALLOWED_BY_STATE: Dictionary = {
    &"NEUTRAL":  [ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_ULTIMATUM, ArcDecisionUtil.ARC_IGNORE],
    &"RIVALRY":  [ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_SABOTAGE, ArcDecisionUtil.ARC_ULTIMATUM, ArcDecisionUtil.ARC_TRUCE_TALKS, ArcDecisionUtil.ARC_IGNORE],
    &"CONFLICT": [ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_SABOTAGE, ArcDecisionUtil.ARC_ULTIMATUM, ArcDecisionUtil.ARC_DECLARE_WAR, ArcDecisionUtil.ARC_TRUCE_TALKS, ArcDecisionUtil.ARC_IGNORE],
    &"WAR":      [ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_SABOTAGE, ArcDecisionUtil.ARC_DECLARE_WAR, ArcDecisionUtil.ARC_TRUCE_TALKS, ArcDecisionUtil.ARC_IGNORE],
    &"TRUCE":    [ArcDecisionUtil.ARC_TRUCE_TALKS, ArcDecisionUtil.ARC_REPARATIONS, ArcDecisionUtil.ARC_ALLIANCE_OFFER, ArcDecisionUtil.ARC_IGNORE],
    &"ALLIANCE": [ArcDecisionUtil.ARC_ALLIANCE_OFFER, ArcDecisionUtil.ARC_IGNORE, ArcDecisionUtil.ARC_IGNORE],
}

static func filter_action_for_state(state: StringName, proposed: StringName, rng: RandomNumberGenerator) -> StringName:
    var allowed: Array = ALLOWED_BY_STATE.get(state, [])
    if allowed.is_empty():
        return proposed
    if allowed.has(proposed):
        return proposed
    # fallback: pick an allowed non-IGNORE if possible
    var non_ignore: Array = []
    for a in allowed:
        if a != ArcDecisionUtil.ARC_IGNORE:
            non_ignore.append(a)
    if non_ignore.is_empty():
        return ArcDecisionUtil.ARC_IGNORE
    return non_ignore[rng.randi_range(0, non_ignore.size() - 1)]

static func bundle_cap_for_state(state: StringName) -> int:
    var ov: Dictionary = BUNDLE_BY_STATE.get(state, {})
    if ov.is_empty():
        return 1
    return int(ov.get("count_max", 1)) # cap concurrent (on prend le max)


static func override_bundle_count(state: StringName, base_bundle: Dictionary, rng: RandomNumberGenerator) -> int:
    var ov: Dictionary = BUNDLE_BY_STATE.get(state, {})
    if ov.is_empty():
        # fallback sur le bundle du catalogue
        var mn := int(base_bundle.get("count_min", 1))
        var mx := int(base_bundle.get("count_max", 1))
        return rng.randi_range(mn, mx)

    var mn2 := int(ov.get("count_min", int(base_bundle.get("count_min", 1))))
    var mx2 := int(ov.get("count_max", int(base_bundle.get("count_max", 1))))
    return rng.randi_range(mn2, mx2)
