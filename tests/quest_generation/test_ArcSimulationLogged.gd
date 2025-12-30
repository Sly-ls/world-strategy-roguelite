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
    pass_test("✅ Arc simulation (logged + escalation index): OK")


func run(days: int) -> void:
    _assert(days > 0, "days must be > 0")

    # 1) Load golden profiles
    var profiles_list := _load_golden_profiles()
    _assert(profiles_list.size() >= 6, "Need at least 6 profiles")

    var params = TestUtils.init_params()
    # 2) Init relations world
    FactionManager.generate_world(10,
        1,
        98765,
        params
    )

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
    var baseline := TestUtils.snapshot_metrics()

    # 5) Sim loop
    for day in range(1, days + 1):
        #_daily_decay(ids, world_rel, faction_profiles)
        FactionManager.daily_decay()

        var candidates: Array = []
        var all_factions = FactionManager.get_all_factions()
        for faction_a in all_factions:
            for faction_b in all_factions:
                var rel_ab: FactionRelationScore = faction_a.get_relation_to(faction_b.id)
                var p := ArcDecisionUtil.compute_arc_event_chance(
                    rel_ab,
                    faction_a.profile,
                    faction_b.profile,
                    day,
                    {"max_p": 0.35}
                )
                if p > 0.0 and rng.randf() < p:
                    candidates.append({"a": faction_a.id, "b": faction_b.id, "p": p})
                

        candidates.sort_custom(func(x, y): return float(x["p"]) > float(y["p"]))
        var take :int = min(max_events_per_day, candidates.size())

        var day_ei := 0.0
        var produced := 0

        for i in range(take):
            var candidate :Dictionary = candidates[i]
            var a_id: StringName = candidate["a"]
            var b_id: StringName = candidate["b"]
            var faction_a = FactionManager.get_faction(a_id)
            var faction_b = FactionManager.get_faction(b_id)
            var rel_ab: FactionRelationScore = faction_a.get_relation_to(faction_b.id)
            var rel_ba: FactionRelationScore = faction_a.get_relation_to(faction_b.id)

            # ---- BEFORE snapshot (pair mean) ----
            var before := _snapshot_pair_mean(rel_ab, rel_ba)

            var action := ArcDecisionUtil.select_arc_action_type(
                rel_ab,
                faction_a.profile,
                faction_b.profile,
                rng,
                day,
                {
                    "external_threat": 0.15,
                    "opportunity": _compute_opportunity(rel_ab, faction_a.profile),
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
                faction_a.profile,
                faction_b.profile,
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
    var end := TestUtils.snapshot_metrics()
    var summary := TestUtils.build_summary(stats, baseline,end, daily_escalation, daily_event_count, days, w_tension, w_relation)

    _write_json(LOG_PATH, {"seed": 888888, "days": days, "events": event_log})
    _write_json(SUMMARY_PATH, summary)

    myLogger.debug("📄 Saved logs to: %s" % LOG_PATH, LogTypes.Domain.TEST)
    myLogger.debug("📄 Saved summary to: %s" % SUMMARY_PATH, LogTypes.Domain.TEST)

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
    
    var relation_ab := rel_ab.get_score(FactionRelationScore.REL_RELATION)
    var trust_ab := rel_ab.get_score(FactionRelationScore.REL_TRUST)
    var tension_ab := rel_ab.get_score(FactionRelationScore.REL_TENSION)
    var grievance_ab := rel_ab.get_score(FactionRelationScore.REL_GRIEVANCE)
    var weariness_ab := rel_ab.get_score(FactionRelationScore.REL_WEARINESS)
    
    var relation_ba := rel_ba.get_score(FactionRelationScore.REL_RELATION)
    var trust_ba := rel_ba.get_score(FactionRelationScore.REL_TRUST)
    var tension_ba := rel_ba.get_score(FactionRelationScore.REL_TENSION)
    var grievance_ba := rel_ba.get_score(FactionRelationScore.REL_GRIEVANCE)
    var weariness_ba := rel_ba.get_score(FactionRelationScore.REL_WEARINESS)
    return {
        "relation_mean": 0.5 * (float(relation_ab) + float(relation_ba)),
        "trust_mean": 0.5 * (float(trust_ab) + float(trust_ba)),
        "tension_mean": 0.5 * (tension_ab + tension_ba),
        "grievance_mean": 0.5 * (grievance_ab + grievance_ba),
        "weariness_mean": 0.5 * (weariness_ab + weariness_ba),
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
            "relation": int(round(2.0*float(before["relation_mean"]) - float(rel_ba.get_score(FactionRelationScore.REL_RELATION)))), # approx not needed but kept
        },
        "ab_after": {
            "relation": rel_ab.get_score(FactionRelationScore.REL_RELATION),
            "trust": rel_ab.get_score(FactionRelationScore.REL_TRUST),
            "tension": rel_ab.get_score(FactionRelationScore.REL_TENSION),
            "grievance": rel_ab.get_score(FactionRelationScore.REL_GRIEVANCE),
            "weariness": rel_ab.get_score(FactionRelationScore.REL_WEARINESS),
        },
        "ba_after": {
            "relation": rel_ba.get_score(FactionRelationScore.REL_RELATION),
            "trust": rel_ba.get_score(FactionRelationScore.REL_TRUST),
            "tension": rel_ba.get_score(FactionRelationScore.REL_TENSION),
            "grievance": rel_ba.get_score(FactionRelationScore.REL_GRIEVANCE),
            "weariness": rel_ba.get_score(FactionRelationScore.REL_WEARINESS),
        }
    }

# -----------------------------
# Daily decay
# -----------------------------
            
# -----------------------------
# Choice simulation + opportunity
# -----------------------------
func _resolve_choice(action: StringName, rel_ab: FactionRelationScore) -> StringName:
    var t := rel_ab.get_score(FactionRelationScore.REL_TENSION) / 100.0
    var g := rel_ab.get_score(FactionRelationScore.REL_GRIEVANCE) / 100.0
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
    var expa := a_prof.get_personality(FactionProfile.PERS_EXPANSIONISM)
    var w := rel_ab.get_score(FactionRelationScore.REL_WEARINESS) / 100.0
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




func _print_summary(stats: Dictionary) -> void:
    
    myLogger.debug("--- Arc Simulation Summary ( %d days) ---" % stats["days"], LogTypes.Domain.TEST)
    myLogger.debug("Events total: %d" % stats["events_total"], LogTypes.Domain.TEST)
    myLogger.debug("Hostile: %d | Peace: %d | War declares: %d" % [stats["hostile_events"], stats["peace_events"], stats["declare_war"]], LogTypes.Domain.TEST)
    myLogger.debug("Escalation EI mean/day: %d | max day: %d " % [stats["escalation"]["mean"], stats["escalation"]["max_day"]], LogTypes.Domain.TEST)
    myLogger.debug("Avg tension drift: %d" % stats["avg_tension_drift"])
    myLogger.debug("Baseline: %s" % stats["baseline"])
    myLogger.debug("Final:    %s" % stats["final"])
    myLogger.debug("By action: %s" % stats["by_action"])

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
