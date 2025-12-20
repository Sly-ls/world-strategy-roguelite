extends BaseTest
class_name TestFactionWorldRelations

const GOLDEN_PATH := "user://golden_faction_profiles.json"

var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.seed = 424242 # reproductible

    # 1) Charger 10 profils différents (golden) ou fallback
    var profiles_list := _load_golden_profiles()
    _assert(profiles_list.size() >= 2, "Need at least 2 profiles to test relations")

    # 2) Construire un set de factions (ids + profile)
    var faction_profiles: Dictionary[StringName, FactionProfile] = {}
    for i in range(min(10, profiles_list.size())):
        var id := StringName("faction_%02d" % i)
        faction_profiles[id] = profiles_list[i]

    # 3) Générer le monde des relations
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
            # per-faction params (init directionnel)
            "desired_mean": 0.0,
            "desired_std": 22.0,
            "enemy_min": 1, "enemy_max": 2,
            "ally_min": 1, "ally_max": 2,
            "noise": 3,
            "tension_cap": 40.0,
            "final_recenter": true
        },
        {
            # baseline relation tuning forwarded to compute_baseline_relation()
            "w_axis_similarity": 80.0,
            "w_cross_conflict": 55.0,
            "tension_cap": 40.0
        }
    )

    # 4) Vérifs
    _validate_world_relations(faction_profiles, world_rel)

    pass_test("\n✅ World relations initialization tests: OK\n")


# -------------------------
# Validation
# -------------------------

func _validate_world_relations(faction_profiles: Dictionary, world_rel: Dictionary) -> void:
    var ids: Array[StringName] = []
    for fid in faction_profiles.keys():
        ids.append(StringName(fid))

    # Structure: world_rel[A][B] existe pour tous A!=B
    for a in ids:
        _assert(world_rel.has(a), "Missing relations map for %s" % a)
        var map_a: Dictionary = world_rel[a]
        for b in ids:
            if b == a:
                _assert(not map_a.has(b), "Self relation should not exist: %s->%s" % [a, b])
                continue
            _assert(map_a.has(b), "Missing relation score: %s->%s" % [a, b])
            _validate_score_bounds(a, b, map_a[b])

    # Qualité globale: moyenne centrée + variance raisonnable + allies/enemies
    _validate_centering_and_spread(ids, world_rel)
    _validate_allies_enemies(ids, world_rel)
    _validate_reciprocity(ids, world_rel)


func _validate_score_bounds(a: StringName, b: StringName, rs) -> void:
    # rs est un FactionRelationScore
    _assert(rs != null, "Null score for %s->%s" % [a, b])

    _assert(rs.relation >= -100 and rs.relation <= 100, "relation out of range %s->%s = %d" % [a, b, rs.relation])
    _assert(rs.trust >= -100 and rs.trust <= 100, "trust out of range %s->%s = %d" % [a, b, rs.trust])
    _assert(rs.tension >= 0.0 and rs.tension <= 100.0, "tension out of range %s->%s = %f" % [a, b, rs.tension])
    # friction optionnel mais fortement recommandé
    if "friction" in rs:
        _assert(rs.friction >= 0.0 and rs.friction <= 100.0, "friction out of range %s->%s = %f" % [a, b, rs.friction])
    _assert(rs.grievance >= 0.0 and rs.grievance <= 100.0, "grievance out of range %s->%s = %f" % [a, b, rs.grievance])
    _assert(rs.weariness >= 0.0 and rs.weariness <= 100.0, "weariness out of range %s->%s = %f" % [a, b, rs.weariness])


func _validate_centering_and_spread(ids: Array[StringName], world_rel: Dictionary) -> void:
    # global mean / std
    var all_vals: Array[float] = []
    for a in ids:
        var map_a: Dictionary = world_rel[a]
        for b in map_a.keys():
            all_vals.append(float(map_a[b].relation))

    var mean := _mean(all_vals)
    var std := _std(all_vals, mean)

    _assert(abs(mean) <= 6.0, "Global mean too far from 0: mean=%f" % mean)
    _assert(std >= 12.0 and std <= 35.0, "Global std unexpected: std=%f (expect ~[12..35])" % std)

    # per-faction mean not too extreme (cohérence globale)
    for a in ids:
        var vals: Array[float] = []
        var map_a: Dictionary = world_rel[a]
        for b in map_a.keys():
            vals.append(float(map_a[b].relation))
        var m := _mean(vals)
        _assert(abs(m) <= 20.0, "Faction %s mean too extreme: %f" % [a, m])


func _validate_allies_enemies(ids: Array[StringName], world_rel: Dictionary) -> void:
    # On veut "quelques ennemis naturels, quelques alliés naturels"
    # Avec ally/enemy min/max, la plupart des factions devraient en avoir.
    var need_ratio := 0.70 # au moins 70% des factions

    var with_ally := 0
    var with_enemy := 0

    for a in ids:
        var map_a: Dictionary = world_rel[a]
        var has_ally := false
        var has_enemy := false
        for b in map_a.keys():
            var r := int(map_a[b].relation)
            if r >= 30:
                has_ally = true
            if r <= -30:
                has_enemy = true
        if has_ally: with_ally += 1
        if has_enemy: with_enemy += 1

    _assert(float(with_ally) / float(ids.size()) >= need_ratio,
        "Not enough factions with an ally (>=30): %d/%d" % [with_ally, ids.size()])
    _assert(float(with_enemy) / float(ids.size()) >= need_ratio,
        "Not enough factions with an enemy (<=-30): %d/%d" % [with_enemy, ids.size()])


func _validate_reciprocity(ids: Array[StringName], world_rel: Dictionary) -> void:
    # Réciprocité légère: AB et BA convergent, mais restent différents.
    var diffs: Array[float] = []
    var ab_vals: Array[float] = []
    var ba_vals: Array[float] = []

    for i in range(ids.size()):
        for j in range(i + 1, ids.size()):
            var a := ids[i]
            var b := ids[j]
            var ab := float(world_rel[a][b].relation)
            var ba := float(world_rel[b][a].relation)
            ab_vals.append(ab)
            ba_vals.append(ba)
            diffs.append(abs(ab - ba))

    var mean_diff := _mean(diffs)
    # Trop bas => presque symétrique (pas voulu), trop haut => pas de convergence
    _assert(mean_diff >= 4.0 and mean_diff <= 35.0, "Reciprocity diff mean unexpected: %f" % mean_diff)

    # Corrélation positive: si AB déteste, BA tend aussi à détester
    var corr := _pearson(ab_vals, ba_vals)
    _assert(corr >= 0.55, "Reciprocity correlation too low: %f" % corr)


# -------------------------
# Golden load / fallback
# -------------------------

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


# -------------------------
# Math helpers
# -------------------------

func _mean(arr: Array[float]) -> float:
    if arr.is_empty():
        return 0.0
    var s := 0.0
    for v in arr:
        s += v
    return s / float(arr.size())

func _std(arr: Array[float], mean: float) -> float:
    if arr.size() <= 1:
        return 0.0
    var s := 0.0
    for v in arr:
        var d := v - mean
        s += d * d
    return sqrt(s / float(arr.size()))

func _pearson(x: Array[float], y: Array[float]) -> float:
    if x.size() != y.size() or x.is_empty():
        return 0.0
    var mx := _mean(x)
    var my := _mean(y)
    var num := 0.0
    var dx := 0.0
    var dy := 0.0
    for i in range(x.size()):
        var a := x[i] - mx
        var b := y[i] - my
        num += a * b
        dx += a * a
        dy += b * b
    if dx <= 0.000001 or dy <= 0.000001:
        return 0.0
    return num / sqrt(dx * dy)
