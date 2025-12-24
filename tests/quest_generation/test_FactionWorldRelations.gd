extends BaseTest
class_name TestFactionWorldRelations

const GOLDEN_PATH := "user://golden_faction_profiles.json"

var rng := RandomNumberGenerator.new()

func _ready() -> void:
    # 1) Charger 10 profils différents (golden) ou fallback
    var profiles_list := _load_golden_profiles()
    _assert(profiles_list.size() >= 2, "Need at least 2 profiles to test relations")

    # 2) Construire un set de factions (ids + profile)
    var faction_profiles: Dictionary[StringName, FactionProfile] = {}
    for i in range(min(10, profiles_list.size())):
        var id := StringName("faction_%02d" % i)
        faction_profiles[id] = profiles_list[i]

    # 3) Générer le monde des relations
    FactionRelationsUtil.initialize_relations_world(
        20,
        424242,
       TestUtils.init_params()
    )

    # 4) Vérifs
    _validate_world_relations()

    pass_test("\n✅ World relations initialization tests: OK\n")


# -------------------------
# Validation
# -------------------------

func _validate_world_relations() -> void:
    var all_factions = FactionManager.get_all_factions()
    for faction_a in all_factions:
        for faction_b in all_factions:
            if faction_a == faction_b:
                _assert(not faction_a.relations.has(faction_a.id), "Self relation should not exist: %s->%s" % [faction_a.id, faction_a.id])
                continue
            _assert(faction_a.relations.has(faction_b.id), "Missing relation score: %s->%s" % [faction_a.id, faction_b.id])
            _validate_score_bounds(faction_a, faction_b)

    # Qualité globale: moyenne centrée + variance raisonnable + allies/enemies
    _validate_centering_and_spread()
    _validate_allies_enemies()
    _validate_reciprocity()


func _validate_score_bounds(faction_a: Faction, faction_b: Faction) -> void:
    # rs est un FactionRelationScore
    var relation = faction_a.get_relation_to(faction_b.id)
    _assert(relation != null, "Null score for %s->%s" % [faction_a.id, faction_b.id])
    var relation_score = relation.get_score(FactionRelationScore.REL_RELATION)
    var trust_score = relation.get_score(FactionRelationScore.REL_TRUST)
    var tension_score = relation.get_score(FactionRelationScore.REL_TENSION)
    var friction_score = relation.get_score(FactionRelationScore.REL_FRICTION)
    var grievance_score = relation.get_score(FactionRelationScore.REL_GRIEVANCE)
    var weariness_score = relation.get_score(FactionRelationScore.REL_WEARINESS)
    _assert(relation_score >= -100 and relation_score <= 100, "relation out of range %s->%s = %d" % [faction_a.id, faction_b.id, relation_score])
    _assert(trust_score >= -100 and trust_score <= 100, "trust out of range %s->%s = %d" % [faction_a.id, faction_b.id, trust_score])
    _assert(tension_score >= 0.0 and tension_score <= 100.0, "tension out of range %s->%s = %f" % [faction_a.id, faction_b.id, tension_score])
    _assert(friction_score >= 0.0 and friction_score <= 100.0, "friction out of range %s->%s = %f" % [faction_a.id, faction_b.id, friction_score])
    _assert(grievance_score >= 0.0 and grievance_score <= 100.0, "grievance out of range %s->%s = %f" % [faction_a.id, faction_b.id, grievance_score])
    _assert(weariness_score >= 0.0 and weariness_score <= 100.0, "weariness out of range %s->%s = %f" % [faction_a.id, faction_b.id, weariness_score])


func _validate_centering_and_spread() -> void:
    # global mean / std
    var all_vals :Array[float] = []
    var all_factions = FactionManager.get_all_factions()
    for faction_a in all_factions:
        var vals: Array[float] = []
        for faction_b in all_factions:
            if faction_a == faction_b: continue
            var relation = faction_a.get_relation_to(faction_b.id)
            all_vals.append(float(relation.get_score(FactionRelationScore.REL_RELATION)))
            vals.append(float(relation.get_score(FactionRelationScore.REL_RELATION)))
        var m := TestUtils.mean(vals)
        # per-faction mean not too extreme (cohérence globale)
        _assert(abs(m) <= 20.0, "Faction %s mean too extreme: %f" % [faction_a.id, m])

    var mean := TestUtils.mean(all_vals)
    var std := TestUtils.std(all_vals, mean)

    # global mean / std
    _assert(abs(mean) <= 6.0, "Global mean too far from 0: mean=%f" % mean)
    _assert(std >= 12.0 and std <= 35.0, "Global std unexpected: std=%f (expect ~[12..35])" % std)

func _validate_allies_enemies() -> void:
    # On veut "quelques ennemis naturels, quelques alliés naturels"
    # Avec ally/enemy min/max, la plupart des factions devraient en avoir.
    var need_ratio := 0.70 # au moins 70% des factions

    var with_ally := 0
    var with_enemy := 0

    var all_factions = FactionManager.get_all_factions()
    for faction_a in all_factions:
        var has_ally := false
        var has_enemy := false
        for faction_b in all_factions:
            if faction_a == faction_b: continue
            var relation = faction_a.get_relation_to(faction_b.id)
            var relation_score = relation.get_score(FactionRelationScore.REL_RELATION)
            if relation_score >= 30:
                has_ally = true
            if relation_score <= -30:
                has_enemy = true
        if has_ally: with_ally += 1
        if has_enemy: with_enemy += 1

    _assert(float(with_ally) / float(all_factions.size()) >= need_ratio,
        "Not enough factions with an ally (>=30): %d/%d" % [with_ally, all_factions.size()])
    _assert(float(with_enemy) / float(all_factions.size()) >= need_ratio,
        "Not enough factions with an enemy (<=-30): %d/%d" % [with_enemy, all_factions.size()])


func _validate_reciprocity() -> void:
    # Réciprocité légère: AB et BA convergent, mais restent différents.
    var diffs: Array[float] = []
    var ab_vals: Array[float] = []
    var ba_vals: Array[float] = []

    var all_factions = FactionManager.get_all_factions()
    for i in range(all_factions.size()):
        for j in range(i + 1, all_factions.size()):
            var faction_a :Faction = all_factions[i]
            var faction_b :Faction = all_factions[j]
            var relation_ab = faction_a.get_relation_to(faction_b.id)
            var relation_ba = faction_b.get_relation_to(faction_a.id)
            var relation_score_ab = relation_ab.get_score(FactionRelationScore.REL_RELATION)
            var relation_score_ba = relation_ba.get_score(FactionRelationScore.REL_RELATION)
            ab_vals.append(relation_score_ab)
            ba_vals.append(relation_score_ba)
            diffs.append(abs(relation_score_ab - relation_score_ba))

    var mean_diff := TestUtils.mean(diffs)
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

func _pearson(x: Array[float], y: Array[float]) -> float:
    if x.size() != y.size() or x.is_empty():
        return 0.0
    var mx := TestUtils.mean(x)
    var my := TestUtils.mean(y)
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
