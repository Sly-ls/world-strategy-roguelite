# Godot 4.x
class_name FactionRelationScore
extends RefCounted

#const PERS_RISK_AVERSION: StringName = &"diplomacy"
const REL_RELATION: StringName = &"relation"
const REL_TRUST: StringName = &"trust"
const REL_GRIEVANCE: StringName = &"grievance"
const REL_TENSION: StringName = &"tension"
const REL_WEARINESS: StringName = &"weariness"
const REL_FRICTION: StringName = &"friction"
const REL_RESISTANCE: StringName = &"resistance"


const MIN: StringName = &"min"
const MAX: StringName = &"max"

const ALL_RELATION_KEYS: Array[StringName] = [
    REL_RELATION,
    REL_TRUST,
    REL_GRIEVANCE,
    REL_TENSION,
    REL_WEARINESS,
    REL_FRICTION,
    REL_RESISTANCE,
]

var min_max :Dictionary = {
    REL_RELATION:{
        MIN:REL_MIN,
        MAX:REL_MAX,
    },
    REL_TRUST:{
        MIN:REL_MIN,
        MAX:REL_MAX,
    },
    REL_GRIEVANCE:{
        MIN:REL_MIN,
        MAX:REL_MAX,
    },
    REL_TENSION:{
        MIN:METER_MIN,
        MAX:METER_MIN,
    },
    REL_WEARINESS:{
        MIN:METER_MIN,
        MAX:METER_MIN,
    },
    REL_FRICTION:{
        MIN:RATIO_MIN,
        MAX:RATIO_MAX,
    },
    REL_RESISTANCE:{
        MIN:RATIO_MIN,
        MAX:RATIO_MAX,
    },
}
const REL_MIN: float = -100.0
const REL_MAX: float = 100.0

const TRUST_MIN: float = -100
const TRUST_MAX: float = 100

const METER_MIN: float = 0.0
const METER_MAX: float = 100.0

const RATIO_MIN: float = 0.0
const RATIO_MAX: float = 1.0
# Directional: this is "from owner faction" -> "to target faction"
var target_faction_id: StringName

var last_event_day: int = -999999
var cooldown_until_day: int = -999999

var friction: float = 0.0  # 0..100 (volatilité / friction idéologique)
var scores :Dictionary = {}

func _init(target_id: StringName = &"") -> void:
    target_faction_id = target_id
    init_relations_dict()

func init(scores_to_init: Dictionary) -> void:
    for k in scores_to_init:
        set_score(k, scores_to_init[k])
    
func init_relations_dict() -> void:
    for k in ALL_RELATION_KEYS:
        
        set_score(k, 0.0)
        
func clamp_all() -> void:
    for k in scores:
        clamp_one(k)

func clamp_one(k: StringName = &"") -> void:
    var score = scores[k]
    var min = min_max[k][MIN]
    var max = min_max[k][MAX]
    var clamp = clampf(score, METER_MIN, METER_MAX)
    scores[k] =clamp

func get_score(score_name:StringName) -> float:
    return scores.get(score_name, 0)
    
func set_score(score_name:StringName, score_to_apply :float) -> void:
    scores.set(score_name, score_to_apply)
    clamp_one(score_name)
    
func apply_delta( delta_to_apply : Dictionary) -> void:
    for k in delta_to_apply:
        apply_delta_to(k, delta_to_apply[k])
    
func apply_delta_to(score_name:StringName, delta_to_apply : float) -> void:
    scores[score_name] = scores[score_name] + delta_to_apply
    clamp_one(score_name)
func is_on_cooldown(current_day: int) -> bool:
    return current_day < cooldown_until_day

func set_cooldown(current_day: int, days: int) -> void:
    cooldown_until_day = current_day + max(days, 0)
