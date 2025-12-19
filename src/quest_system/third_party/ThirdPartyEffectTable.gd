class_name ThirdPartyEffectTable
extends RefCounted

const CHOICE_LOYAL: StringName = &"LOYAL"
const CHOICE_NEUTRAL: StringName = &"NEUTRAL"
const CHOICE_TRAITOR: StringName = &"TRAITOR"

# role -> tp_action -> choice -> effects[]
# effect := { "pair":"AB"|"AC"|"BC", "field":"relation|trust|tension|grievance|weariness", "delta": float }
const EFFECTS: Dictionary = {
    &"MEDIATOR": {
        &"tp.mediation.truce": {
            CHOICE_LOYAL: [
                {"pair":"AB","field":"tension","delta":-15}, {"pair":"AB","field":"grievance","delta":-12},
                {"pair":"AB","field":"trust","delta":+10},  {"pair":"AB","field":"relation","delta":+12},
                {"pair":"AB","field":"weariness","delta":-3},

                {"pair":"AC","field":"trust","delta":+6},   {"pair":"AC","field":"relation","delta":+6},
                {"pair":"BC","field":"trust","delta":+6},   {"pair":"BC","field":"relation","delta":+6},
            ],
            CHOICE_NEUTRAL: [
                {"pair":"AB","field":"tension","delta":-9},  {"pair":"AB","field":"grievance","delta":-6},
                {"pair":"AB","field":"trust","delta":+4},    {"pair":"AB","field":"relation","delta":+5},
                {"pair":"AC","field":"relation","delta":+2}, {"pair":"BC","field":"relation","delta":+2},
            ],
            CHOICE_TRAITOR: [
                {"pair":"AB","field":"tension","delta":+8},  {"pair":"AB","field":"grievance","delta":+8},
                {"pair":"AB","field":"trust","delta":-8},    {"pair":"AB","field":"relation","delta":-6},
                {"pair":"AC","field":"trust","delta":-10},   {"pair":"AC","field":"relation","delta":-10},
                {"pair":"BC","field":"trust","delta":-10},   {"pair":"BC","field":"relation","delta":-10},
            ],
        },

        &"tp.mediation.trade": {
            CHOICE_LOYAL: [
                {"pair":"AB","field":"tension","delta":-8}, {"pair":"AB","field":"grievance","delta":-6},
                {"pair":"AB","field":"trust","delta":+6},  {"pair":"AB","field":"relation","delta":+8},
                {"pair":"AC","field":"relation","delta":+4},{"pair":"BC","field":"relation","delta":+4},
            ],
            CHOICE_NEUTRAL: [
                {"pair":"AB","field":"tension","delta":-4}, {"pair":"AB","field":"relation","delta":+3},
            ],
            CHOICE_TRAITOR: [
                {"pair":"AB","field":"trust","delta":-6}, {"pair":"AC","field":"relation","delta":-6},{"pair":"BC","field":"relation","delta":-6},
            ],
        },
    },

    &"OPPORTUNIST": {
        &"tp.opportunist.raid": {
            # Ici, on suppose que "victim_faction_id" est B (ou A) dans le context ;
            # l’application ci-dessous traite AB comme "C<->victim" via apply_for_opportunist().
            CHOICE_LOYAL: [
                {"pair":"AB","field":"tension","delta":+14}, {"pair":"AB","field":"grievance","delta":+12},
                {"pair":"AB","field":"relation","delta":-12},{"pair":"AB","field":"trust","delta":-8},
                {"pair":"AC","field":"relation","delta":+4}, # beneficiary likes C (optionnel)
            ],
            CHOICE_NEUTRAL: [
                {"pair":"AB","field":"tension","delta":+8}, {"pair":"AB","field":"relation","delta":-7},
            ],
            CHOICE_TRAITOR: [
                {"pair":"AB","field":"tension","delta":+10},{"pair":"AB","field":"relation","delta":-10},
                {"pair":"AC","field":"relation","delta":-6}, {"pair":"BC","field":"relation","delta":-6},
            ],
        },
    },
}

static func canonical_arc_action(role: StringName, tp_action: StringName) -> StringName:
    # utile si tu veux que l’ArcStateMachine compte ça comme peace/hostile
    if role == &"MEDIATOR" and tp_action == &"tp.mediation.truce":
        return ArcDecisionUtil.ARC_TRUCE_TALKS
    if role == &"MEDIATOR" and tp_action == &"tp.mediation.trade":
        return ArcDecisionUtil.ARC_REPARATIONS
    if role == &"OPPORTUNIST" and tp_action == &"tp.opportunist.raid":
        return ArcDecisionUtil.ARC_RAID
    return tp_action

static func apply(
    relations: Dictionary, # relations[X][Y] -> FactionRelationScore
    a_id: StringName,
    b_id: StringName,
    c_id: StringName,
    role: StringName,
    tp_action: StringName,
    choice: StringName,
    # limiter: max change per tick (ratio); tu peux le brancher à ton ArcNotebook/historique
    max_change_ratio: float = 0.25
) -> void:
    var role_map: Dictionary = EFFECTS.get(role, {})
    var action_map: Dictionary = role_map.get(tp_action, {})
    var effects: Array = action_map.get(choice, [])
    if effects.is_empty():
        return

    for e in effects:
        var pair := String(e.get("pair",""))
        var field := String(e.get("field",""))
        var delta := float(e.get("delta", 0.0))

        match pair:
            "AB":
                _apply_pair(relations, a_id, b_id, field, delta, max_change_ratio)
            "AC":
                _apply_pair(relations, a_id, c_id, field, delta, max_change_ratio)
            "BC":
                _apply_pair(relations, b_id, c_id, field, delta, max_change_ratio)
            _:
                pass

static func apply_for_opportunist(
    relations: Dictionary,
    beneficiary_id: StringName,  # ex: A
    victim_id: StringName,       # ex: B
    c_id: StringName,
    role: StringName,
    tp_action: StringName,
    choice: StringName,
    max_change_ratio: float = 0.25
) -> void:
    # Interprétation:
    # - "AB" = C <-> victim
    # - "AC" = beneficiary <-> C
    # - "BC" = beneficiary <-> victim (optionnel)
    var role_map: Dictionary = EFFECTS.get(role, {})
    var action_map: Dictionary = role_map.get(tp_action, {})
    var effects: Array = action_map.get(choice, [])
    if effects.is_empty():
        return

    for e in effects:
        var pair := String(e.get("pair",""))
        var field := String(e.get("field",""))
        var delta := float(e.get("delta", 0.0))

        match pair:
            "AB":
                _apply_pair(relations, c_id, victim_id, field, delta, max_change_ratio)
            "AC":
                _apply_pair(relations, beneficiary_id, c_id, field, delta, max_change_ratio)
            "BC":
                _apply_pair(relations, beneficiary_id, victim_id, field, delta, max_change_ratio)
            _:
                pass

static func _apply_pair(relations: Dictionary, x_id: StringName, y_id: StringName, field: String, delta: float, max_change_ratio: float) -> void:
    if not relations.has(x_id): return
    if not relations.has(y_id): return
    if not relations[x_id].has(y_id): return
    if not relations[y_id].has(x_id): return

    var xy: FactionRelationScore = relations[x_id][y_id]
    var yx: FactionRelationScore = relations[y_id][x_id]

    _apply_field(xy, field, delta, max_change_ratio)
    _apply_field(yx, field, delta, max_change_ratio)

static func _apply_field(r: FactionRelationScore, field: String, delta: float, max_change_ratio: float) -> void:
    var minv := 0.0
    var maxv := 100.0
    var cur := 0.0

    match field:
        "relation":
            minv = -100.0; maxv = 100.0
            cur = float(r.relation)
            r.relation = int(round(_apply_limited(cur, delta, minv, maxv, max_change_ratio)))
        "trust":
            cur = float(r.trust)
            r.trust = int(round(_apply_limited(cur, delta, minv, maxv, max_change_ratio)))
        "tension":
            cur = float(r.tension)
            r.tension = int(round(_apply_limited(cur, delta, minv, maxv, max_change_ratio)))
        "grievance":
            cur = float(r.grievance)
            r.grievance = int(round(_apply_limited(cur, delta, minv, maxv, max_change_ratio)))
        "weariness":
            cur = float(r.weariness)
            r.weariness = int(round(_apply_limited(cur, delta, minv, maxv, max_change_ratio)))
        _:
            pass

static func _apply_limited(cur: float, delta: float, minv: float, maxv: float, max_change_ratio: float) -> float:
    # limite “10..30% du score actuel” version générique:
    # clamp(delta) par abs(cur)*ratio, avec un minimum de pas.
    var cap := max(3.0, abs(cur) * clampf(max_change_ratio, 0.0, 1.0))
    var d := clampf(delta, -cap, cap)
    return clampf(cur + d, minv, maxv)
