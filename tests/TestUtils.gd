extends Node

class_name TestUtils
static func snapshot_metrics() -> Dictionary:
    var sum_rels: float = 0
    var sum_tens: float = 0
    var sum_wears: float = 0
    var count = 0
    var all_factions = FactionManager.get_all_factions()
    for faction_a in all_factions:
        for faction_b in all_factions:
            if faction_b == faction_a:
                continue
            count += 1
            var rel_score: FactionRelationScore = faction_a.get_relation_to(faction_b.id)
            sum_rels += float(rel_score.get_score(FactionRelationScore.REL_RELATION))
            sum_tens += float(rel_score.get_score(FactionRelationScore.REL_TENSION))
            sum_wears += float(rel_score.get_score(FactionRelationScore.REL_WEARINESS))

    return {
        "avg_relation": sum_rels / count,
        "avg_tension": sum_tens / count,
        "avg_weariness": sum_wears / count,
    }

static  func mean(arr: Array[float]) -> float:
    if arr.is_empty():
        return 0.0
    var s := 0.0
    for v in arr:
        s += v
    return s / float(arr.size())

static func std(arr: Array[float], mean: float) -> float:
    if arr.size() <= 1:
        return 0.0
    var s := 0.0
    for v in arr:
        var d := v - mean
        s += d * d
    return sqrt(s / float(arr.size()))


static func build_summary(stats: Dictionary, base: Dictionary, end: Dictionary, daily_ei: Array[float], daily_ev: Array[int], days: int, w_tension: float, w_relation: float) -> Dictionary:
    var ei_sum := 0.0
    var ei_max := 0.0
    for v in daily_ei:
        ei_sum += v
        ei_max = max(ei_max, v)
    var ei_mean := ei_sum / float(max(1, daily_ei.size()))

    # "divergence signal": tension should not keep ramping linearly
    var t0 := float(base["avg_tension"])
    var t_end := float(end["avg_tension"])
    var drift := t_end - t0

    return {
        "days": days,
        "events_total": int(stats["events_total"]),
        "by_action": stats["by_action"],
        "by_choice": stats["by_choice"],
        "peace_events": int(stats["peace_events"]),
        "hostile_events": int(stats["hostile_events"]),
        "declare_war": int(stats["declare_war"]),

        "baseline": base,
        "final": end,
        "avg_tension_drift": drift,

        "escalation": {
            "w_tension": w_tension,
            "w_relation": w_relation,
            "daily": daily_ei,
            "daily_event_count": daily_ev,
            "sum": ei_sum,
            "mean": ei_mean,
            "max_day": ei_max,
        }
    }
    
static func init_params(new_params:Dictionary = {}) -> Dictionary:
    
    var reciprocity_params :Dictionary = {
            "apply_reciprocity": true,
            "reciprocity_strength": 0.70,
            "keep_asymmetry": 0.30,
            "reciprocity_noise": 2,
            "max_change_per_pair": 18,
            "final_global_sanity": true,
            "max_extremes_per_faction": 2
        }
    var per_faction_params :Dictionary = {
            "desired_mean": 0.0,
            "desired_std": 22.0,
            "min_scale": 0.70,
            "max_scale": 1.20,
            "enemy_min": 0, "enemy_max": 1,
            "ally_min": 0, "ally_max": 1,
            "noise": 3,
            "tension_cap": 50.0,
            "final_recenter": true
        }
    var relation_params :Dictionary = {
            "ally_rel_boost": 18,
            "ally_trust_boost": 14,
            "ally_tension_delta": -10.0,
            "enemy_rel_boost": -22,
            "enemy_trust_boost": -16,
            "enemy_tension_delta": +15.0,
            "enemy_grievance_init": 6.0,
            "min_relation_cap": -85,
            "max_relation_cap": +85,
        }
    var baseline_params :Dictionary ={
            "w_axis_similarity": 80.0,
            "w_cross_conflict": 55.0,
            "w_personality_bias": 25.0,
            "friction_base": 18.0,
            "friction_from_opposition": 65.0,
            "friction_from_cross": 55.0,
            "w_tech_nature": 1.0,
            "w_tech_divine": 1.0,
            "w_tech_magic": 1.0,
            "w_tech_corruption": 0.35,
            "w_divine_nature": 0.4,
            "w_divine_magic": 0.5,
            "w_divine_corruption": 1.0,
            "w_magic_nature": 0.4,
            "w_magic_corruption": 0.5,
            "w_nature_corruption": 1.0,
        }
    var relations_override :Dictionary ={
        }
    var params :Dictionary = {
        "reciprocity_params": reciprocity_params,
        "per_faction_params": per_faction_params,
        "relation_params": relation_params,
        "baseline_params": baseline_params,
        "relations_override": relations_override
        }
    for key in new_params.keys():
        if new_params[key] is Dictionary:
            for sub_key in new_params[key].keys() :
                params[key][sub_key] = new_params[key][sub_key]
    return params
