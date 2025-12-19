# Godot 4.x
class_name FactionRelationScore
extends RefCounted

const REL_MIN: int = -100
const REL_MAX: int = 100

const TRUST_MIN: int = -100
const TRUST_MAX: int = 100

const METER_MIN: float = 0.0
const METER_MAX: float = 100.0

# Directional: this is "from owner faction" -> "to target faction"
var target_faction_id: StringName

# Your existing “relation” score (reputation / opinion)
var relation: int = 0          # -100..100
var trust: int = 0             # -100..100

var grievance: float = 0.0     # 0..100
var tension: float = 0.0       # 0..100
var weariness: float = 0.0     # 0..100

var last_event_day: int = -999999
var cooldown_until_day: int = -999999

var friction: float = 0.0  # 0..100 (volatilité / friction idéologique)


# var faction_relations: Dictionary[StringName, Dictionary[StringName, FactionRelationScore]]
# var faction_profiles: Dictionary[StringName, FactionProfile]
var faction_relations: Dictionary = {}
var faction_profiles: Dictionary = {}

func _init(target_id: StringName = &"") -> void:
    target_faction_id = target_id

func clamp_all() -> void:
    relation = clampi(relation, REL_MIN, REL_MAX)
    trust = clampi(trust, TRUST_MIN, TRUST_MAX)
    grievance = clampf(grievance, METER_MIN, METER_MAX)
    tension = clampf(tension, METER_MIN, METER_MAX)
    weariness = clampf(weariness, METER_MIN, METER_MAX)
    friction = clampf(friction, METER_MIN, METER_MAX)

func apply_delta_OLD(
    d_relation: int = 0,
    d_trust: int = 0,
    d_grievance: float = 0.0,
    d_tension: float = 0.0,
    d_weariness: float = 0.0
) -> void:
    relation += d_relation
    trust += d_trust
    grievance += d_grievance
    tension += d_tension
    weariness += d_weariness
    clamp_all()

func apply_delta(
    d_relation: int = 0,
    d_trust: int = 0,
    d_grievance: float = 0.0,
    d_tension: float = 0.0,
    d_weariness: float = 0.0,
    d_friction: float = 0.0
) -> void:
    relation += d_relation
    trust += d_trust
    grievance += d_grievance
    tension += d_tension
    weariness += d_weariness
    friction += d_friction
    clamp_all()
func is_on_cooldown(current_day: int) -> bool:
    return current_day < cooldown_until_day

func set_cooldown(current_day: int, days: int) -> void:
    cooldown_until_day = current_day + max(days, 0)


func _get_or_create_relation_score(a_id: StringName, b_id: StringName) -> FactionRelationScore:
    if not faction_relations.has(a_id):
        faction_relations[a_id] = {}

    var map_a: Dictionary = faction_relations[a_id]
    if map_a.has(b_id):
        return map_a[b_id]

    # Création lazy (si jamais ça arrive en cours de jeu)
    if not faction_profiles.has(a_id) or not faction_profiles.has(b_id):
        return null

    var a_prof: FactionProfile = faction_profiles[a_id]
    var b_prof: FactionProfile = faction_profiles[b_id]
    var init := FactionProfile.compute_baseline_relation(a_prof, b_prof)

    var rs := FactionRelationScore.new(b_id)
    rs.relation = int(init["relation"])
    rs.trust = int(init["trust"])
    rs.tension = float(init["tension"])
    rs.friction = float(init.get("friction", 0.0)) # si tu l’as ajouté
    rs.grievance = 0.0
    rs.weariness = 0.0
    rs.clamp_all()

    map_a[b_id] = rs
    faction_relations[a_id] = map_a
    return rs
