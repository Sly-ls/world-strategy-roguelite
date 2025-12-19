extends BaseTest
class_name TestArcSimulationLogged

const GOLDEN_PATH := "user://golden_faction_profiles.json"
const LOG_PATH := "user://arc_sim_log.json"
const SUMMARY_PATH := "user://arc_sim_summary.json"

@export var days_to_simulate: int = 30
@export var max_events_per_day: int = 6

# Escalation metric weights
@export var w_tension: float = 1.0
@export var w_relation: float = 0.55

var rng := RandomNumberGenerator.new()

const PEACE_ACTIONS := [
    ArcDecisionUtil.ARC_TRUCE_TALKS,
    ArcDecisionUtil.ARC_REPARATIONS,
    ArcDecisionUtil.ARC_ALLIANCE_OFFER,
]

const HOSTILE_ACTIONS := [
    ArcDecisionUtil.ARC_RAID,
    ArcDecisionUtil.ARC_SABOTAGE,
    ArcDecisionUtil.ARC_DECLARE_WAR,
    ArcDecisionUtil.ARC_ULTIMATUM,
]

func _ready() -> void:
    rng.seed = 888888
    run(days_to_simulate)
    print("\n✅ Arc simulation (logged + escalation index): OK\n")
    get_tree().quit()


func run(days: int) -> void:
    _assert(days > 0, "days must be > 0")

    # 1) Load golden profiles
    var profiles_list := _load_golden_profiles()
    _assert(profiles_list.size() >= 6, "Need at least 6 profiles")

    var faction_profiles: Dictionary[StringName, FactionProfile] = {}
    for i in range(min(10, profiles_list.size())):
        faction_profiles[StringName("faction_%02d" % i)] = profiles_list[i]

    var ids: Array[StringName] = []
    for fid in faction_profiles.keys():
        ids.append(StringName(fid))

    # 2) Init relations world
    var world_rel := FactionRelationsUtil.initialize_relations_world(
        faction_profiles,
        rng,
        {
            "apply_reciprocity": true,
            "reciprocity_strength": 0.70,
            "keep_asymmetry": 0.30,
            "reciprocity_noise": 2,
            "max_change_per_pair": 18,
            "final_global_sanity": true,
            "max_extremes_per_faction": 2
        },
        {
            "desired_mean": 0.0,
            "desired_std": 22.0,
            "enemy_min": 1, "enemy_max": 2,
            "ally_min": 1, "ally_max": 2,
            "noise": 3,
            "tension_cap": 40.0,
            "final_recenter": true
        },
        {
            "w_axis_similarity": 80.0,
            "w_cross_conflict": 55.0,
            "tension_cap": 40.0
        }
    )

    # 3) Notebook
    var arc_notebook := ArcNotebook.new()

    # 4) Logs + metrics
    var event_log: Array = []
    var daily_escalation: Array[float] = []
    var daily_event_count: Array[int] = []

    # global counters
    var stats := {
        "events_total": 0,
        "by_action": {},
        "by_choice": {},
        "peace_events": 0,
        "hostile_events": 0,
        "declare_war": 0,
    }

    # baseline snapshot for divergence proof
    var baseline := _snapshot_global(ids, world_rel)

    # 5) Sim loop
    for day in range(1, days + 1):
        _daily_decay(ids, world_rel, faction_profiles)

        var candidates: Array = []
        for a_id in ids:
            var map_a: Dictionary = world_rel[a_id]
            for b_id in map_a.keys():
                if b_id == a_id:
                    continue
                var rel_ab: FactionRelationScore = map_a[b_id]
                var p := ArcDecisionUtil.compute_arc_event_chance(
                    rel_ab,
                    faction_profiles[a_id],
                    faction_profiles[b_id],
                    day,
                    {"max_p": 0.35}
                )
                if p > 0.0 and rng.randf() < p:
                    candidates.append({"a": a_id, "b": b_id, "p": p})

        candidates.sort_custom(func(x, y): return float(x["p"]) > float(y["p"]))
        var take :int = min(max_events_per_day, candidates.size())

        var day_ei := 0.0
        var produced := 0

        for i in range(take):
            var c :Dictionary = candidates[i]
            var a_id: StringName = c["a"]
            var b_id: StringName = c["b"]

            var rel_ab: FactionRelationScore = world_rel[a_id][b_id]
            var rel_ba: FactionRelationScore = world_rel[b_id][a_id]

            # ---- BEFORE snapshot (pair mean) ----
            var before := _snapshot_pair_mean(rel_ab, rel_ba)

            var action := ArcDecisionUtil.select_arc_action_type(
                rel_ab,
                faction_profiles[a_id],
                faction_profiles[b_id],
                rng,
                day,
                {
                    "external_threat": 0.15,
                    "opportunity": _compute_opportunity(rel_ab, faction_profiles[a_id]),
                    "temperature": 0.18
                }
            )
            if action == ArcDecisionUtil.ARC_IGNORE:
                continue

            var choice := _resolve_choice(action, rel_ab)

            # Apply event (deltas + cooldown + notebook)
            ArcEffectTable.apply_arc_resolution_event(
                action, choice,
                a_id, b_id,
                rel_ab, rel_ba,
                faction_profiles[a_id],
                faction_profiles[b_id],
                arc_notebook,
                day, rng
            )

            # ---- AFTER snapshot (pair mean) ----
            var after := _snapshot_pair_mean(rel_ab, rel_ba)

            # Escalation index contribution (only escalatory deltas)
            var ei := _event_escalation_index(before, after)
            day_ei += ei

            # Log entry (jour, A,B, action, choice, before/after AB & BA)
            event_log.append(_make_event_log_entry(day, a_id, b_id, action, choice, rel_ab, rel_ba, before, after, ei))

            # stats
            _stats_add(stats, action, choice)

            produced += 1

        daily_escalation.append(day_ei)
        daily_event_count.append(produced)

    # 6) Summaries + invariants
    var summary := _build_summary(stats, baseline, _snapshot_global(ids, world_rel), daily_escalation, daily_event_count, days)

    _write_json(LOG_PATH, {"seed": 888888, "days": days, "events": event_log})
    _write_json(SUMMARY_PATH, summary)

    print("\n📄 Saved logs to: ", LOG_PATH)
    print("📄 Saved summary to: ", SUMMARY_PATH)

    _print_summary(summary)
    _validate_escalation_invariants(summary, days)


# -----------------------------
# Escalation metric
# -----------------------------
func _event_escalation_index(before: Dictionary, after: Dictionary) -> float:
    # EI_event = wT * max(0, Δtension_mean) + wR * max(0, -Δrelation_mean)
    var dt := float(after["tension_mean"]) - float(before["tension_mean"])
    var dr := float(after["relation_mean"]) - float(before["relation_mean"])
    var inc_t :float = max(0.0, dt)
    var inc_r :float = max(0.0, -dr)
    return w_tension * inc_t + w_relation * inc_r


func _snapshot_pair_mean(rel_ab: FactionRelationScore, rel_ba: FactionRelationScore) -> Dictionary:
    return {
        "relation_mean": 0.5 * (float(rel_ab.relation) + float(rel_ba.relation)),
        "trust_mean": 0.5 * (float(rel_ab.trust) + float(rel_ba.trust)),
        "tension_mean": 0.5 * (rel_ab.tension + rel_ba.tension),
        "grievance_mean": 0.5 * (rel_ab.grievance + rel_ba.grievance),
        "weariness_mean": 0.5 * (rel_ab.weariness + rel_ba.weariness),
    }


func _make_event_log_entry(
    day: int,
    a_id: StringName,
    b_id: StringName,
    action: StringName,
    choice: StringName,
    rel_ab: FactionRelationScore,
    rel_ba: FactionRelationScore,
    before: Dictionary,
    after: Dictionary,
    ei: float
) -> Dictionary:
    return {
        "day": day,
        "a": String(a_id),
        "b": String(b_id),
        "action": String(action),
        "choice": String(choice),
        "ei": ei,
        "before_mean": before,
        "after_mean": after,
        "ab_before": {
            "relation": int(round(2.0*float(before["relation_mean"]) - float(rel_ba.relation))), # approx not needed but kept
        },
        "ab_after": {
            "relation": rel_ab.relation,
            "trust": rel_ab.trust,
            "tension": rel_ab.tension,
            "grievance": rel_ab.grievance,
            "weariness": rel_ab.weariness,
        },
        "ba_after": {
            "relation": rel_ba.relation,
            "trust": rel_ba.trust,
            "tension": rel_ba.tension,
            "grievance": rel_ba.grievance,
            "weariness": rel_ba.weariness,
        }
    }


# -----------------------------
# Daily decay
# -----------------------------
func _daily_decay(ids: Array[StringName], world_rel: Dictionary, faction_profiles: Dictionary) -> void:
    var base_tension_decay := 0.9
    var base_griev_decay := 0.6
    var base_wear_decay := 0.35

    for a_id in ids:
        var prof: FactionProfile = faction_profiles[a_id]
        var diplo := prof.get_personality(FactionProfile.PERS_DIPLOMACY, 0.5)
        var veng := prof.get_personality(FactionProfile.PERS_VENGEFULNESS, 0.5)

        var tension_mul := 0.70 + 0.80 * diplo
        var griev_mul := 0.55 + 0.90 * (1.0 - veng)

        var map_a: Dictionary = world_rel[a_id]
        for b_id in map_a.keys():
            var rs: FactionRelationScore = map_a[b_id]
            rs.tension = max(0.0, rs.tension - base_tension_decay * tension_mul)
            rs.grievance = max(0.0, rs.grievance - base_griev_decay * griev_mul)
            rs.weariness = max(0.0, rs.weariness - base_wear_decay)
            rs.clamp_all()


# -----------------------------
# Choice simulation + opportunity
# -----------------------------
func _resolve_choice(action: StringName, rel_ab: FactionRelationScore) -> StringName:
    var t := rel_ab.tension / 100.0
    var g := rel_ab.grievance / 100.0
    var bias := clampf(0.45 + 0.25*t + 0.20*g, 0.35, 0.75)

    var p_loyal := bias
    var p_neutral := 0.30
    var p_traitor := 1.0 - (p_loyal + p_neutral)
    p_traitor = clampf(p_traitor, 0.05, 0.25)

    if PEACE_ACTIONS.has(action):
        p_loyal = clampf(p_loyal + 0.10, 0.45, 0.85)
        p_neutral = 0.25
        p_traitor = 1.0 - (p_loyal + p_neutral)
    elif action == ArcDecisionUtil.ARC_DECLARE_WAR:
        p_neutral = 0.35
        p_loyal = clampf(p_loyal, 0.40, 0.70)
        p_traitor = 1.0 - (p_loyal + p_neutral)

    var r := rng.randf()
    if r < p_loyal:
        return ArcEffectTable.CHOICE_LOYAL
    if r < p_loyal + p_neutral:
        return ArcEffectTable.CHOICE_NEUTRAL
    return ArcEffectTable.CHOICE_TRAITOR


func _compute_opportunity(rel_ab: FactionRelationScore, a_prof: FactionProfile) -> float:
    var expa := a_prof.get_personality(FactionProfile.PERS_EXPANSIONISM, 0.5)
    var w := rel_ab.weariness / 100.0
    return clampf(0.45 + 0.35*(expa - 0.5) - 0.40*w, 0.05, 0.95)


# -----------------------------
# Global snapshots + summary
# -----------------------------
func _snapshot_global(ids: Array[StringName], world_rel: Dictionary) -> Dictionary:
    var rels: Array[float] = []
    var tens: Array[float] = []
    var wears: Array[float] = []
    var grs: Array[float] = []

    for a_id in ids:
        var map_a: Dictionary = world_rel[a_id]
        for b_id in map_a.keys():
            var rs: FactionRelationScore = map_a[b_id]
            rels.append(float(rs.relation))
            tens.append(float(rs.tension))
            wears.append(float(rs.weariness))
            grs.append(float(rs.grievance))

    return {
        "avg_relation": _mean(rels),
        "avg_tension": _mean(tens),
        "avg_weariness": _mean(wears),
        "avg_grievance": _mean(grs),
    }


func _build_summary(stats: Dictionary, base: Dictionary, end: Dictionary, daily_ei: Array[float], daily_ev: Array[int], days: int) -> Dictionary:
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


func _print_summary(summary: Dictionary) -> void:
    print("\n--- Arc Simulation Logged Summary ---")
    print("Days: ", summary["days"], " | Events: ", summary["events_total"])
    print("Hostile: ", summary["hostile_events"], " | Peace: ", summary["peace_events"], " | War declares: ", summary["declare_war"])
    print("Avg tension drift: ", summary["avg_tension_drift"])
    print("Escalation EI mean/day: ", summary["escalation"]["mean"], " | max day: ", summary["escalation"]["max_day"])
    print("Baseline: ", summary["baseline"])
    print("Final:    ", summary["final"])
    print("By action: ", summary["by_action"])


func _validate_escalation_invariants(summary: Dictionary, days: int) -> void:
    # 1) EI moyen/jour ne doit pas exploser
    var ei_mean := float(summary["escalation"]["mean"])
    # ordre de grandeur: avec caps+cooldowns+decay, on attend EI/jour modéré
    _assert(ei_mean <= 18.0, "Escalation index mean/day too high: %f" % ei_mean)

    # 2) la tension globale ne doit pas diverger
    var drift := float(summary["avg_tension_drift"])
    _assert(drift <= 35.0, "Avg tension drift too high: %f" % drift)

    # 3) pas trop de guerres
    var max_wars :float = max(1, int(floor(float(days) / 20.0)) + 1)
    _assert(int(summary["declare_war"]) <= max_wars,
        "Too many war declarations: %d (max %d)" % [int(summary["declare_war"]), max_wars])


# -----------------------------
# IO helpers
# -----------------------------
func _write_json(path: String, payload: Dictionary) -> void:
    var f := FileAccess.open(path, FileAccess.WRITE)
    _assert(f != null, "Cannot open %s for writing" % path)
    f.store_string(JSON.stringify(payload, "\t"))
    f.close()


# -----------------------------
# Golden load / fallback
# -----------------------------
func _load_golden_profiles() -> Array[FactionProfile]:
    if not FileAccess.file_exists(GOLDEN_PATH):
        push_warning("Golden profiles not found at %s, generating 10 fallback profiles." % GOLDEN_PATH)
        return _generate_fallback_profiles(10)

    var f := FileAccess.open(GOLDEN_PATH, FileAccess.READ)
    _assert(f != null, "Cannot open %s" % GOLDEN_PATH)
    var txt := f.get_as_text()
    f.close()

    var json := JSON.new()
    var err := json.parse(txt)
    _assert(err == OK, "JSON parse failed in %s" % GOLDEN_PATH)
    var root: Dictionary = json.data

    var arr: Array = root.get("profiles", [])
    _assert(arr.size() > 0, "Golden file has no profiles")

    var out: Array[FactionProfile] = []
    for item in arr:
        out.append(_profile_from_json_dict(item))
    return out


func _profile_from_json_dict(d: Dictionary) -> FactionProfile:
    var p := FactionProfile.new()

    var axis_in: Dictionary = d.get("axis_affinity", {})
    var per_in: Dictionary = d.get("personality", {})

    p.axis_affinity = {}
    for ax in FactionProfile.ALL_AXES:
        p.axis_affinity[ax] = int(axis_in.get(String(ax), 0))

    p.personality = {}
    for k in FactionProfile.ALL_PERSONALITY_KEYS:
        p.personality[k] = float(per_in.get(String(k), 0.5))

    return p


func _generate_fallback_profiles(n: int) -> Array[FactionProfile]:
    var out: Array[FactionProfile] = []
    for _i in range(n):
        out.append(FactionProfile.generate_full_profile(rng, FactionProfile.GEN_NORMAL))
    return out


# -----------------------------
# Stats helper
# -----------------------------
func _stats_add(stats: Dictionary, action: StringName, choice: StringName) -> void:
    stats["events_total"] = int(stats["events_total"]) + 1

    var by_action: Dictionary = stats["by_action"]
    by_action[action] = int(by_action.get(action, 0)) + 1
    stats["by_action"] = by_action

    var by_choice: Dictionary = stats["by_choice"]
    by_choice[choice] = int(by_choice.get(choice, 0)) + 1
    stats["by_choice"] = by_choice

    if action == ArcDecisionUtil.ARC_DECLARE_WAR:
        stats["declare_war"] = int(stats["declare_war"]) + 1

    if PEACE_ACTIONS.has(action):
        stats["peace_events"] = int(stats["peace_events"]) + 1
    if HOSTILE_ACTIONS.has(action):
        stats["hostile_events"] = int(stats["hostile_events"]) + 1


# -----------------------------
# Math + assert
# -----------------------------
func _mean(arr: Array[float]) -> float:
    if arr.is_empty():
        return 0.0
    var s := 0.0
    for v in arr:
        s += v
    return s / float(arr.size())

func _assert(cond: bool, msg: String) -> void:
    if not cond:
        push_error("TEST FAIL: " + msg)
        assert(false)
