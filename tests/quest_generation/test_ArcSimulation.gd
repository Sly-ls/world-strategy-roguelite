extends BaseTest
class_name TestArcSimulation

const GOLDEN_PATH := "user://golden_faction_profiles.json"

@export var days_to_simulate: int = 30
@export var max_events_per_day: int = 6

var rng := RandomNumberGenerator.new()

# --- Action buckets (pour stats + invariants) ---
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
    rng.seed = 777777

    run(days_to_simulate)
    pass_test("\n✅ Arc simulation test: OK\n")


# Appelable depuis ailleurs (le nombre de jours est le param)
func run(days: int) -> void:
    _assert(days > 0, "days must be > 0")

    # 1) Charger profils golden (10) + construire factions
    var profiles_list := _load_golden_profiles()
    _assert(profiles_list.size() >= 6, "Need at least 6 profiles for a meaningful arc sim")

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

    # 3) Notebook (historique arcs) — ton ArcNotebook par faction
    var arc_notebook := ArcNotebook.new()

    # 4) Stats time-series + compteurs
    var stats := {
        "events_total": 0,
        "by_action": {},
        "by_choice": {},
        "declare_war": 0,
        "peace_events": 0,
        "hostile_events": 0,
        "avg_tension_series": [],
        "avg_relation_series": [],
        "avg_weariness_series": [],
    }

    var snap0 := _snapshot_metrics(ids, world_rel)
    stats["avg_tension_series"].append(snap0["avg_tension"])
    stats["avg_relation_series"].append(snap0["avg_relation"])
    stats["avg_weariness_series"].append(snap0["avg_weariness"])

    # 5) Simulation days
    for day in range(1, days + 1):
        # a) cooling passif (important pour casser l’escalade “auto”)
        _daily_decay(ids, world_rel, faction_profiles)

        # b) collect candidates (A->B directionnel)
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
                if p <= 0.0:
                    continue
                # tirage “pré-sélection”
                if rng.randf() < p:
                    candidates.append({"a": a_id, "b": b_id, "p": p})

        # c) limiter le budget d'events / jour (sinon n^2 explose la simulation)
        candidates.sort_custom(func(x, y): return float(x["p"]) > float(y["p"]))
        var take :int = min(max_events_per_day, candidates.size())

        for i in range(take):
            var c :Dictionary = candidates[i]
            var a_id: StringName = c["a"]
            var b_id: StringName = c["b"]

            var rel_ab: FactionRelationScore = world_rel[a_id][b_id]
            var rel_ba: FactionRelationScore = world_rel[b_id][a_id]

            # d) action selection
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

            # e) choix simulé (LOYAL/NEUTRAL/TRAITOR)
            var choice := _resolve_choice(action, rel_ab)

            # f) appliquer l’événement (deltas + cooldown + notebook)
            ArcEffectTable.apply_arc_resolution_event(
                action,
                choice,
                a_id,
                b_id,
                rel_ab,
                rel_ba,
                faction_profiles[a_id],
                faction_profiles[b_id],
                arc_notebook,
                day,
                rng
            )

            # g) stats
            _stats_add(stats, action, choice)

        # h) snapshot
        var snap := _snapshot_metrics(ids, world_rel)
        stats["avg_tension_series"].append(snap["avg_tension"])
        stats["avg_relation_series"].append(snap["avg_relation"])
        stats["avg_weariness_series"].append(snap["avg_weariness"])

    # 6) Invariants anti-escalade + résumé
    _print_summary(stats, days)
    _validate_invariants(stats, ids, world_rel, days)


# -----------------------------
# Decay passif (journalier)
# -----------------------------
func _daily_decay(ids: Array[StringName], world_rel: Dictionary, faction_profiles: Dictionary) -> void:
    # Ajuste ces bases si tu veux un monde plus/moins inflammable
    var base_tension_decay := 0.9
    var base_griev_decay := 0.6
    var base_wear_decay := 0.35

    for a_id in ids:
        var prof: FactionProfile = faction_profiles[a_id]
        var diplo := prof.get_personality(FactionProfile.PERS_DIPLOMACY)
        var veng := prof.get_personality(FactionProfile.PERS_VENGEFULNESS)

        var tension_mul := 0.70 + 0.80 * diplo           # diplomate => tension redescend plus vite
        var griev_mul := 0.55 + 0.90 * (1.0 - veng)      # vindicatif => grievance redescend moins vite

        var map_a: Dictionary = world_rel[a_id]
        for b_id in map_a.keys():
            var rs: FactionRelationScore = map_a[b_id]
            rs.tension = max(0.0, rs.tension - base_tension_decay * tension_mul)
            rs.grievance = max(0.0, rs.grievance - base_griev_decay * griev_mul)
            rs.weariness = max(0.0, rs.weariness - base_wear_decay)
            rs.clamp_all()


# -----------------------------
# Choix simulé (auto-résolution)
# -----------------------------
func _resolve_choice(action: StringName, rel_ab: FactionRelationScore) -> StringName:
    # Heuristique: plus tension/grievance sont hauts, plus c’est “LOYAL” côté acteur A (ça passe en force).
    var t := rel_ab.get_score(FactionRelationScore.REL_TENSION) / 100.0
    var g := rel_ab.get_score(FactionRelationScore.REL_GRIEVANCE) / 100.0
    var bias := clampf(0.45 + 0.25*t + 0.20*g, 0.35, 0.75)

    var p_loyal := bias
    var p_neutral := 0.30
    var p_traitor := 1.0 - (p_loyal + p_neutral)
    p_traitor = clampf(p_traitor, 0.05, 0.25)

    # Ajustement selon type (paix : loyal plus probable, guerre : neutral un peu plus probable)
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
    # Rough: expansionism aide, weariness pénalise
    var expa := a_prof.get_personality(FactionProfile.PERS_EXPANSIONISM)
    var w := rel_ab.get_score(FactionRelationScore.REL_WEARINESS) / 100.0
    return clampf(0.45 + 0.35*(expa - 0.5) - 0.40*w, 0.05, 0.95)


# -----------------------------
# Stats & invariants
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


func _snapshot_metrics(ids: Array[StringName], world_rel: Dictionary) -> Dictionary:
    var rels: Array[float] = []
    var tens: Array[float] = []
    var wears: Array[float] = []

    for a_id in ids:
        var map_a: Dictionary = world_rel[a_id]
        for b_id in map_a.keys():
            var rs: FactionRelationScore = map_a[b_id]
            rels.append(float(rs.relation))
            tens.append(float(rs.tension))
            wears.append(float(rs.weariness))

    return {
        "avg_relation": _mean(rels),
        "avg_tension": _mean(tens),
        "avg_weariness": _mean(wears),
    }


func _validate_invariants(stats: Dictionary, ids: Array[StringName], world_rel: Dictionary, days: int) -> void:
    var events_total := int(stats["events_total"])
    _assert(events_total >= min(5, days), "Too few events produced: %d over %d days" % [events_total, days])

    # Pas de “guerre partout”
    var max_wars :int = max(1, int(floor(float(days) / 20.0)) + 1) # ex: 30j => <=2
    _assert(int(stats["declare_war"]) <= max_wars,
        "Too many war declarations: %d (max %d for %d days)" % [int(stats["declare_war"]), max_wars, days])

    # Si on a pas mal d'hostilité, on doit voir au moins un peu de dé-escalade
    var hostile := int(stats["hostile_events"])
    var peace := int(stats["peace_events"])
    if hostile >= 8:
        _assert(peace >= 1, "Hostile events=%d but no peace/de-escalation event occurred" % hostile)

    # Tension globale ne doit pas “exploser”
    var t_series: Array = stats["avg_tension_series"]
    var t0 := float(t_series[0])
    var t_end := float(t_series[t_series.size() - 1])
    _assert(t_end <= 70.0, "Final avg tension too high: %f" % t_end)
    _assert(t_end <= t0 + 35.0, "Avg tension increased too much: %f -> %f" % [t0, t_end])

    # Un petit nombre de paires “ultra chaudes” max
    var hot_pairs := _count_hot_pairs(ids, world_rel)
    _assert(hot_pairs <= 3, "Too many hot pairs (tension>=80 and mean relation<=-70): %d" % hot_pairs)


func _count_hot_pairs(ids: Array[StringName], world_rel: Dictionary) -> int:
    var c := 0
    for i in range(ids.size()):
        for j in range(i + 1, ids.size()):
            var a := ids[i]
            var b := ids[j]
            var ab: FactionRelationScore = world_rel[a][b]
            var ba: FactionRelationScore = world_rel[b][a]
            var mean_rel := 0.5 * (float(ab.relation) + float(ba.relation))
            var mean_t := 0.5 * (ab.get_score(FactionRelationScore.REL_TENSION) + ba.get_score(FactionRelationScore.REL_TENSION))
            if mean_t >= 80.0 and mean_rel <= -70.0:
                c += 1
    return c


func _print_summary(stats: Dictionary, days: int) -> void:
    print("\n--- Arc Simulation Summary (", days, " days) ---")
    print("Events total: ", stats["events_total"])
    print("Hostile: ", stats["hostile_events"], " | Peace: ", stats["peace_events"], " | War declares: ", stats["declare_war"])
    print("By choice: ", stats["by_choice"])
    print("By action: ", stats["by_action"])

    var ts: Array = stats["avg_tension_series"]
    var ws: Array = stats["avg_weariness_series"]
    var rs: Array = stats["avg_relation_series"]
    print("Avg tension:   ", ts[0], " -> ", ts[ts.size() - 1])
    print("Avg weariness: ", ws[0], " -> ", ws[ws.size() - 1])
    print("Avg relation:  ", rs[0], " -> ", rs[rs.size() - 1])


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
# Math + assert
# -----------------------------
func _mean(arr: Array[float]) -> float:
    if arr.is_empty():
        return 0.0
    var s := 0.0
    for v in arr:
        s += v
    return s / float(arr.size())
