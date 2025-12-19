"""
Usage typique (dans ton FactionManager)
# faction_profiles: Dictionary[StringName, FactionProfile]
# relations_of_A := Dictionary[StringName, FactionRelationScore]
var relations_of_A := FactionRelationsUtil.initialize_relations_for_faction(
    a_id,
    faction_profiles,
    rng,
    {
        "desired_mean": 0.0,
        "desired_std": 22.0,
        "enemy_min": 1, "enemy_max": 2,
        "ally_min": 1, "ally_max": 2
    }
    
    var world_rel := FactionRelationsUtil.initialize_relations_world(
        faction_profiles,
        rng,
        {
            "apply_reciprocity": true,
            "reciprocity_strength": 0.70,
            "keep_asymmetry": 0.30,
            "reciprocity_noise": 2,
            "max_change_per_pair": 18,
            "final_global_sanity": true
        },
        {
            "desired_mean": 0.0,
            "desired_std": 22.0,
            "enemy_min": 1, "enemy_max": 2,
            "ally_min": 1, "ally_max": 2
            },
            {
            # baseline relation tuning forwarded to compute_baseline_relation()
            "w_axis_similarity": 80.0,
            "w_cross_conflict": 55.0
        }
    )

"""
class_name FactionRelationsUtil
extends RefCounted

static func initialize_relations_for_faction(
    source_faction_id: StringName,
    faction_profiles: Dictionary, # Dictionary[StringName, FactionProfile]
    rng: RandomNumberGenerator,
    params: Dictionary = {},
    baseline_params: Dictionary = {}
) -> Dictionary:
    # Returns: Dictionary[StringName, FactionRelationScore] (A -> others)

    if not faction_profiles.has(source_faction_id):
        return {}

    var a: FactionProfile = faction_profiles[source_faction_id]
    var targets: Array[StringName] = []
    for fid in faction_profiles.keys():
        if StringName(fid) != source_faction_id:
            targets.append(StringName(fid))

    if targets.is_empty():
        return {}

    # ---- Tunables (defaults) ----
    var desired_mean: float = float(params.get("desired_mean", 0.0))         # center around 0
    var desired_std: float = float(params.get("desired_std", 22.0))          # spread control
    var min_scale: float = float(params.get("min_scale", 0.70))
    var max_scale: float = float(params.get("max_scale", 1.20))

    var noise: int = int(params.get("noise", 3))                              # small random jitter in relation
    var tension_cap: float = float(params.get("tension_cap", 40.0))

    var ally_min: int = int(params.get("ally_min", 1))
    var ally_max: int = int(params.get("ally_max", 2))
    var enemy_min: int = int(params.get("enemy_min", 1))
    var enemy_max: int = int(params.get("enemy_max", 2))

    # Boosts applied to selected natural allies/enemies
    var ally_rel_boost: int = int(params.get("ally_rel_boost", 18))
    var ally_trust_boost: int = int(params.get("ally_trust_boost", 14))
    var ally_tension_delta: float = float(params.get("ally_tension_delta", -10.0))

    var enemy_rel_boost: int = int(params.get("enemy_rel_boost", -22))
    var enemy_trust_boost: int = int(params.get("enemy_trust_boost", -16))
    var enemy_tension_delta: float = float(params.get("enemy_tension_delta", +15.0))
    var enemy_grievance_init: float = float(params.get("enemy_grievance_init", 6.0))

    # Hard caps on extremes to avoid too many day-1 dooms
    var min_relation_cap: int = int(params.get("min_relation_cap", -85))
    var max_relation_cap: int = int(params.get("max_relation_cap", +85))

    # ---- 1) Raw baseline compute for all targets ----
    var raw_rel: Array[float] = []
    var init_map: Dictionary = {} # fid -> {relation, friction, trust, tension}
    for fid in targets:
        var b: FactionProfile = faction_profiles[fid]
        var init := FactionProfile.compute_baseline_relation(a, b, baseline_params)
        # ensure tension cap here too
        init["tension"] = min(float(init.get("tension", 0.0)), tension_cap)
        init_map[fid] = init
        raw_rel.append(float(init["relation"]))

    # ---- 2) Center mean and normalize spread (std) ----
    var mean := _mean(raw_rel)
    var std := _std(raw_rel, mean)

    # shift to desired mean
    var shift := desired_mean - mean

    # scale to desired std (soft)
    var scale := 1.0
    if std > 0.001:
        scale = desired_std / std
    scale = clampf(scale, min_scale, max_scale)

    # ---- 3) Build preliminary relation scores ----
    var out: Dictionary[StringName, FactionRelationScore] = {}
    for fid in targets:
        var init :Dictionary = init_map[fid]
        var rel0 := float(init["relation"])

        var rel := (rel0 + shift - desired_mean) * scale + desired_mean

        # small jitter to avoid perfectly symmetric worlds
        if noise > 0:
            rel += float(rng.randi_range(-noise, noise))

        rel = clampf(rel, float(min_relation_cap), float(max_relation_cap))

        var rs := FactionRelationScore.new(fid)
        rs.relation = int(round(rel))
        rs.trust = int(init.get("trust", 0))
        rs.tension = float(init.get("tension", 0.0))
        rs.grievance = 0.0
        rs.weariness = 0.0
        rs.last_event_day = -999999
        rs.cooldown_until_day = -999999
        rs.clamp_all()

        out[fid] = rs

    # ---- 4) Pick a few natural enemies and allies (coherence globale) ----
    var enemy_count := rng.randi_range(enemy_min, enemy_max)
    var ally_count := rng.randi_range(ally_min, ally_max)

    # Score candidates (use baseline friction + negativity etc.)
    var enemy_candidates: Array = []
    var ally_candidates: Array = []

    for fid in targets:
        var init :Dictionary = init_map[fid]
        var rs: FactionRelationScore = out[fid]

        var friction := float(init.get("friction", 0.0))
        var neg :float = max(0.0, -float(rs.relation))

        # Enemies: friction + neg + low trust
        var enemy_score :float = (0.65*friction) + (0.55*neg) + (0.25*max(0.0, -float(rs.trust)))
        enemy_candidates.append({"fid": fid, "score": enemy_score})

        # Allies: high relation + trust - friction
        var ally_score := (0.70*float(rs.relation)) + (0.45*float(rs.trust)) - (0.35*friction)
        ally_candidates.append({"fid": fid, "score": ally_score})

    enemy_candidates.sort_custom(func(ae, be): return ae["score"] > be["score"])
    ally_candidates.sort_custom(func(ae, be): return ae["score"] > be["score"])

    var chosen_enemies: Array[StringName] = []
    for i in range(min(enemy_count, enemy_candidates.size())):
        chosen_enemies.append(StringName(enemy_candidates[i]["fid"]))

    var chosen_allies: Array[StringName] = []
    for i in range(ally_candidates.size()):
        if chosen_allies.size() >= ally_count:
            break
        var fid: StringName = StringName(ally_candidates[i]["fid"])
        if chosen_enemies.has(fid):
            continue
        chosen_allies.append(fid)

    # ---- 5) Apply ally/enemy boosts (creates a few “peaks” in the distribution) ----
    for fid in chosen_enemies:
        var rs: FactionRelationScore = out[fid]
        rs.apply_delta(
            enemy_rel_boost,
            enemy_trust_boost,
            enemy_grievance_init,
            enemy_tension_delta,
            0.0
        )

    for fid in chosen_allies:
        var rs: FactionRelationScore = out[fid]
        rs.apply_delta(
            ally_rel_boost,
            ally_trust_boost,
            0.0,
            ally_tension_delta,
            0.0
        )

    # Optional: ensure final mean stays centered-ish (small correction only)
    if bool(params.get("final_recenter", true)):
        _recentre_relations(out, desired_mean, 0.35) # 35% recenter strength

    return out


# ------------------ helpers ------------------

static func _mean(arr: Array) -> float:
    if arr.is_empty():
        return 0.0
    var s := 0.0
    for v in arr:
        s += float(v)
    return s / float(arr.size())

static func _std(arr: Array, mean: float) -> float:
    if arr.size() <= 1:
        return 0.0
    var s := 0.0
    for v in arr:
        var d := float(v) - mean
        s += d * d
    return sqrt(s / float(arr.size()))

static func _recentre_relations(map: Dictionary, desired_mean: float, strength: float) -> void:
    # strength 0..1 : how much to recenter the final relation mean
    var vals: Array[float] = []
    for fid in map.keys():
        vals.append(float(map[fid].relation))
    var mean := _mean(vals)
    var shift := (desired_mean - mean) * clampf(strength, 0.0, 1.0)
    for fid in map.keys():
        var rs: FactionRelationScore = map[fid]
        rs.relation = clampi(int(round(float(rs.relation) + shift)), -100, 100)

# --- In FactionRelationsUtil.gd ---

static func initialize_relations_world_OLD(
    faction_profiles: Dictionary, # Dictionary[StringName, FactionProfile]
    rng: RandomNumberGenerator,
    world_params: Dictionary = {},
    per_faction_params: Dictionary = {},
    baseline_params: Dictionary = {}
) -> Dictionary:
    # Returns:
    # Dictionary[StringName, Dictionary[StringName, FactionRelationScore]]
    # i.e. world_relations[A][B] = score (directional)

    var ids: Array[StringName] = []
    for fid in faction_profiles.keys():
        ids.append(StringName(fid))

    var world: Dictionary = {}
    if ids.size() <= 1:
        return world

    # --- Pass 1: directional initialization for each faction ---
    for a_id in ids:
        world[a_id] = initialize_relations_for_faction(
            a_id,
            faction_profiles,
            rng,
            per_faction_params,
            baseline_params
        )

    # --- Pass 2: optional reciprocity convergence ---
    var apply_recip := bool(world_params.get("apply_reciprocity", true))
    if apply_recip:
        var reciprocity_strength := float(world_params.get("reciprocity_strength", 0.70)) # 0..1
        var keep_asymmetry := float(world_params.get("keep_asymmetry", 0.30))            # 0..1
        var reciprocity_noise := int(world_params.get("reciprocity_noise", 2))           # small jitter
        var max_change_per_pair := int(world_params.get("max_change_per_pair", 18))      # clamp per pair update

        _apply_reciprocity(
            world,
            ids,
            rng,
            reciprocity_strength,
            keep_asymmetry,
            reciprocity_noise,
            max_change_per_pair
        )

    # --- Pass 3: optional global clamps / sanity ---
    if bool(world_params.get("final_global_sanity", true)):
        _global_sanity_pass(world, ids, world_params)

    return world

static func initialize_relations_world(
    faction_profiles: Dictionary, # Dictionary[StringName, FactionProfile]
    rng: RandomNumberGenerator,
    world_params: Dictionary = {},
    per_faction_params: Dictionary = {},
    baseline_params: Dictionary = {}
) -> Dictionary:
    # Returns:
    # Dictionary[StringName, Dictionary[StringName, FactionRelationScore]]
    # i.e. world_relations[A][B] = score (directional)

    var ids: Array[StringName] = []
    for fid in faction_profiles.keys():
        ids.append(StringName(fid))

    var world: Dictionary = {}
    if ids.size() <= 1:
        return world

    # --- Pass 1: directional initialization for each faction ---
    for a_id in ids:
        world[a_id] = initialize_relations_for_faction(
            a_id,
            faction_profiles,
            rng,
            per_faction_params,
            baseline_params
        )

    # --- Pass 2: optional reciprocity convergence ---
    var apply_recip := bool(world_params.get("apply_reciprocity", true))
    if apply_recip:
        var reciprocity_strength := float(world_params.get("reciprocity_strength", 0.70)) # 0..1
        var keep_asymmetry := float(world_params.get("keep_asymmetry", 0.30))            # 0..1
        var reciprocity_noise := int(world_params.get("reciprocity_noise", 2))           # small jitter
        var max_change_per_pair := int(world_params.get("max_change_per_pair", 18))      # clamp per pair update

        _apply_reciprocity(
            world,
            ids,
            rng,
            reciprocity_strength,
            keep_asymmetry,
            reciprocity_noise,
            max_change_per_pair
        )

    # --- Pass 3: optional global clamps / sanity ---
    if bool(world_params.get("final_global_sanity", true)):
        _global_sanity_pass(world, ids, world_params)

    return world


static func _apply_reciprocity(
    world: Dictionary,
    ids: Array[StringName],
    rng: RandomNumberGenerator,
    reciprocity_strength: float,
    keep_asymmetry: float,
    reciprocity_noise: int,
    max_change_per_pair: int
) -> void:
    reciprocity_strength = clampf(reciprocity_strength, 0.0, 1.0)
    keep_asymmetry = clampf(keep_asymmetry, 0.0, 1.0)

    for i in range(ids.size()):
        var a_id := ids[i]
        for j in range(i + 1, ids.size()):
            var b_id := ids[j]

            var map_a: Dictionary = world.get(a_id, {})
            var map_b: Dictionary = world.get(b_id, {})
            if not map_a.has(b_id) or not map_b.has(a_id):
                continue

            var ab: FactionRelationScore = map_a[b_id]
            var ba: FactionRelationScore = map_b[a_id]

            # --- Relation reciprocity ---
            var ab_rel := float(ab.relation)
            var ba_rel := float(ba.relation)
            var avg_rel := (ab_rel + ba_rel) * 0.5

            # asymmetry target: keep part of (ab - ba)
            var asym := (ab_rel - ba_rel) * keep_asymmetry

            var ab_target := avg_rel + asym
            var ba_target := avg_rel - asym

            # move each towards target by reciprocity_strength
            var ab_new :float = lerp(ab_rel, ab_target, reciprocity_strength)
            var ba_new :float = lerp(ba_rel, ba_target, reciprocity_strength)

            # tiny noise to avoid perfect pair patterns
            if reciprocity_noise > 0:
                ab_new += float(rng.randi_range(-reciprocity_noise, reciprocity_noise))
                ba_new += float(rng.randi_range(-reciprocity_noise, reciprocity_noise))

            # clamp change per pair so you don't destroy natural enemies/allies too much
            ab_new = _clamp_delta(ab_rel, ab_new, float(max_change_per_pair))
            ba_new = _clamp_delta(ba_rel, ba_new, float(max_change_per_pair))

            ab.relation = clampi(int(round(ab_new)), -100, 100)
            ba.relation = clampi(int(round(ba_new)), -100, 100)

            # --- Trust reciprocity (softer) ---
            var ab_tr := float(ab.trust)
            var ba_tr := float(ba.trust)
            var avg_tr := (ab_tr + ba_tr) * 0.5
            var asym_tr := (ab_tr - ba_tr) * (keep_asymmetry * 0.8)

            var ab_tr_target := avg_tr + asym_tr
            var ba_tr_target := avg_tr - asym_tr

            var ab_tr_new :float = lerp(ab_tr, ab_tr_target, reciprocity_strength * 0.55)
            var ba_tr_new :float = lerp(ba_tr, ba_tr_target, reciprocity_strength * 0.55)

            ab.trust = clampi(int(round(ab_tr_new)), -100, 100)
            ba.trust = clampi(int(round(ba_tr_new)), -100, 100)

            # --- Tension reciprocity (makes arcs more stable) ---
            # Tension converges faster than relation (keeps wars from being too one-sided).
            var ab_te := ab.tension
            var ba_te := ba.tension
            var avg_te := (ab_te + ba_te) * 0.5

            ab.tension = clampf(lerp(ab_te, avg_te, reciprocity_strength * 0.80), 0.0, 100.0)
            ba.tension = clampf(lerp(ba_te, avg_te, reciprocity_strength * 0.80), 0.0, 100.0)

            ab.clamp_all()
            ba.clamp_all()


static func _clamp_delta(old_v: float, new_v: float, max_delta: float) -> float:
    var d := new_v - old_v
    if d > max_delta:
        return old_v + max_delta
    if d < -max_delta:
        return old_v - max_delta
    return new_v


static func _global_sanity_pass(world: Dictionary, ids: Array[StringName], world_params: Dictionary) -> void:
    # Optional: avoid too many extreme relations globally (helps ArcManager).
    # You can disable or keep very light.
    var max_extremes_per_faction := int(world_params.get("max_extremes_per_faction", 2)) # count of relations <= -80
    for a_id in ids:
        var map_a: Dictionary = world.get(a_id, {})
        if map_a.is_empty():
            continue

        # collect extremes
        var negatives: Array = []
        for b_id in map_a.keys():
            var rs: FactionRelationScore = map_a[b_id]
            if rs.relation <= -80:
                negatives.append({"b": b_id, "rel": rs.relation})

        if negatives.size() <= max_extremes_per_faction:
            continue

        # soften the lowest ones a bit (keep the top few as "true nemesis")
        negatives.sort_custom(func(x, y): return x["rel"] < y["rel"]) # most negative first
        for k in range(max_extremes_per_faction, negatives.size()):
            var b_id :String = negatives[k]["b"]
            var rs2: FactionRelationScore = map_a[b_id]
            rs2.relation = min(rs2.relation + 12, -60)  # soften towards -60
            rs2.tension = max(0.0, rs2.tension - 8.0)
            rs2.clamp_all()
