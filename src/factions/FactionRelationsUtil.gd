class_name FactionRelationsUtil
extends RefCounted

static func initialize_relations_world(heat: int = 1, seed: int = 123456789, params: Dictionary = {}) -> void:
    heat = clampi(heat, 1, 100)
    
    var heat_percent_raw := float(heat) / 100.0
    var heat_percent_add = 1 + heat_percent_raw

    var rng := RandomNumberGenerator.new()
    if seed != 0: rng.seed = seed
    else: rng.randomize()

    # --- Paramètres relationnels dérivés de heat (plus heat => plus friction/tension)
    var baseline_params :Dictionary = params.get("baseline_params", {})
    var w_axis_similarity: int = int(baseline_params.get("w_axis_similarity", -85))
    var w_cross_conflict: int = int(baseline_params.get("w_cross_conflict", +85))
    var w_personality_bias: int = int(baseline_params.get("w_personality_bias", -85))
    var friction_base: int = int(baseline_params.get("friction_base", +85))
    var friction_from_opposition: int = int(baseline_params.get("friction_from_opposition", -85))
    var friction_from_cross: int = int(baseline_params.get("friction_from_cross", +85))
    var tension_cap: float = float(baseline_params.get("tension_cap", 40.0))
    
    var baseline_params_adapted := {
        "w_axis_similarity": lerp(int(w_axis_similarity * 0.7),int( w_axis_similarity), heat),
        "w_cross_conflict": lerp(int(w_cross_conflict * 0.7), int(w_cross_conflict), heat),
        "w_personality_bias": lerp(int(w_personality_bias * 0.7), int(w_personality_bias), heat),

        "friction_base": lerp(int(friction_base * 0.7), int(friction_base), heat),
        "friction_from_opposition": lerp(int(friction_from_opposition * 0.7), int(friction_from_opposition), heat),
        "friction_from_cross": lerp(int(friction_from_cross * 0.7), int(friction_from_cross), heat),

        "tension_cap": lerp(int(tension_cap * 0.7), int(tension_cap), heat)
    }
    params["baseline_params_adapted"] = baseline_params_adapted
    var all_factions :Array[Faction] = FactionManager.get_all_factions()
    for faction in all_factions:
        initialize_relations_for_faction(faction, rng, params, heat_percent_raw)
        
    # --- 2) Center outgoing mean per faction (moyenne ~ 0)
    _center_outgoing_means(all_factions, heat_percent_add, params)

    # --- 3) Add a few "natural enemies/allies" per faction (polarisation contrôlée)
    var per_faction_params :Dictionary = params.get("per_faction_params", {})
    var ally_min: int = int(per_faction_params.get("ally_min", 0))
    var ally_max: int = int(per_faction_params.get("ally_max", 2))
    var enemy_min: int = int(per_faction_params.get("enemy_min", 0))
    var enemy_max: int = int(per_faction_params.get("enemy_max", 2))
    var enemy_count := rng.randi_range(enemy_min, enemy_max)
    var ally_count := rng.randi_range(ally_min, ally_max)
    enemy_count = clampi(enemy_count + int(heat / 35), enemy_min, enemy_max)    # heat↑ => + d'ennemis naturels
    ally_count = clampi(ally_count - int(heat / 70), ally_min, ally_max)        # heat↑ => - d'alliés naturels
    _apply_natural_extremes(all_factions, enemy_count, ally_count, params)

    # --- 4) Re-center lightly to keep global coherence after extremes
    
    var final_recenter: bool = bool(params.get("final_recenter", true))
    if final_recenter:
        _center_outgoing_means(all_factions, heat_percent_raw, params)

    # --- Pass 2: optional reciprocity convergence ---
    var reciprocity_params = params.get("reciprocity_params", {})
    var apply_recip := bool(reciprocity_params.get("apply_reciprocity", false))
    if apply_recip:
        _apply_reciprocity(all_factions, rng, reciprocity_params)


static func _center_outgoing_means(all_factions :Array[Faction], heat_percent: float = 0.0, params: Dictionary={}) -> void:
    var per_faction_params :Dictionary = params.get("per_faction_params", {})
    var desired_mean: float = float(per_faction_params.get("desired_mean", 0.0))         # center around 0
    var desired_std: float = float(per_faction_params.get("desired_std", 22.0))          # spread control
    var min_scale: float = float(per_faction_params.get("min_scale", 0.70))
    var max_scale: float = float(per_faction_params.get("max_scale", 1.20))
    var relation_params :Dictionary = params.get("relation_params", {})
    # Hard caps on extremes to avoid too many day-1 dooms
    var min_relation_cap: int = int(relation_params.get("min_relation_cap", -85))
    var max_relation_cap: int = int(relation_params.get("max_relation_cap", +85))

    for fa in all_factions:
        var sum := 0.0
        var cnt := 0
        #calcul du mean
        for fb in all_factions:
            if fa == fb: continue
            sum += fa.get_relation_to(fb.id).get_score(FactionRelationScore.REL_RELATION)
            cnt += 1
        if cnt <= 0: continue
        var mean := sum / float(cnt)
        mean = mean * heat_percent
        #calcul du std (ecart type)
        sum = 0.0
        for fb in all_factions:
            if fa == fb: continue
            var score = fa.get_relation_to(fb.id).get_score(FactionRelationScore.REL_RELATION)
            var d := float(score) - mean
            sum += d * d
        if cnt <= 0: continue
        var std := sqrt(sum / float(cnt))

        # scale to desired std (soft)
        var scale := 1.0
        if std > 0.001:
            scale = desired_std / std
        scale = clampf(scale, min_scale, max_scale)
        var shift := desired_mean - mean 
        for fb in all_factions:
            if fa == fb: continue
            var rel0 := fa.get_relation_to(fb.id).get_score(FactionRelationScore.REL_RELATION)
            rel0 = rel0 - mean * heat_percent 
            fa.get_relation_to(fb.id).set_score(FactionRelationScore.REL_RELATION, rel0)
            var rel_to_set := (rel0 + shift - desired_mean) * scale + desired_mean
            rel_to_set = clampf(rel_to_set, float(min_relation_cap), float(max_relation_cap))
            fa.get_relation_to(fb.id).set_score(FactionRelationScore.REL_RELATION, rel_to_set)

static func _apply_natural_extremes(all_factions :Array[Faction], enemies_count: int, allies_count: int, params: Dictionary = {}) -> void:

    # Boosts applied to selected natural allies/enemies
    var relation_params :Dictionary = params.get("relation_params", {})
    var ally_rel_boost :Dictionary = {
        FactionRelationScore.REL_RELATION: int(relation_params.get("ally_rel_boost", 18)),
        FactionRelationScore.REL_TRUST: int(relation_params.get("ally_trust_boost", 14)),
        FactionRelationScore.REL_TENSION: float(relation_params.get("ally_tension_delta", -10.0)),
    }
    var enemy_rel_boost :Dictionary = {
        FactionRelationScore.REL_RELATION: int(relation_params.get("enemy_rel_boost", -22)),
        FactionRelationScore.REL_TRUST: int(relation_params.get("enemy_trust_boost", -16)),
        FactionRelationScore.REL_TENSION: float(relation_params.get("enemy_tension_delta", +15.0)),
        FactionRelationScore.REL_GRIEVANCE: float(relation_params.get("enemy_grievance_init", 6.0))
        }
    for fa in all_factions:
        # rank others by current relation
        var others: Array = []
        for fb in all_factions:
            if fa == fb: continue
            var score_rel = fa.get_relation_to(fb.id).get_score(FactionRelationScore.REL_RELATION)
            others.append({"id": fb.id, "r": score_rel})

        others.sort_custom(func(x, y): return int(x["r"]) < int(y["r"])) # ascending

        # enemies: lowest relations
        if enemies_count > 0:
            for i in range(min(enemies_count, others.size())):
                var b: StringName = others[i]["id"]
                var relation_fa =  fa.get_relation_to(b)
                relation_fa.apply_delta(enemy_rel_boost)

        # allies: highest relations
        if allies_count > 0:
            for j in range(min(allies_count, others.size())):
                var idx := others.size() - 1 - j
                var b: StringName = others[idx]["id"]
                var relation_fa =  fa.get_relation_to(b)
                relation_fa.apply_delta(ally_rel_boost)



static func initialize_relations_for_faction(
    source_faction: Faction,
    rng: RandomNumberGenerator,
    params: Dictionary = {},
    heat :float = 0.5
) -> void:

    # ---- Tunables (defaults) ----
    var per_faction_params :Dictionary = params.get("per_faction_params", {})
    var noise: int = int(per_faction_params.get("noise", 3))                              # small random jitter in relation

    # Hard caps on extremes to avoid too many day-1 dooms
    var relation_params :Dictionary = params.get("relation_params", {})
    var min_relation_cap: int = int(relation_params.get("min_relation_cap", -85))
    var max_relation_cap: int = int(relation_params.get("max_relation_cap", +85))
    
    var all_factions :Array[Faction] = FactionManager.get_all_factions()
    # ---- 1) Raw baseline compute for all targets ----
    var baseline_params :Dictionary = params.get("baseline_params_adapted", {})
    var tension_cap: float = float(baseline_params.get("tension_cap", 40.0))
    
    for target_faction in all_factions:
        if target_faction != source_faction:
            var rel_init :FactionRelationScore = source_faction.init_relation(target_faction.id, baseline_params)
            if noise > 0:
                var rel_noise = float(rng.randi_range(-noise, noise))
                var tension_noise = float(rng.randi_range(-noise, noise))
                rel_init.apply_delta_to(FactionRelationScore.REL_RELATION, rel_noise)
                rel_init.apply_delta_to(FactionRelationScore.REL_RELATION, tension_noise)
            var relation_score_caped = clampf(rel_init.get_score(FactionRelationScore.REL_RELATION), float(min_relation_cap), float(max_relation_cap))
            var tension_score_caped =  min(float(rel_init.get_score(FactionRelationScore.REL_TENSION)), tension_cap)
            rel_init.set_score(FactionRelationScore.REL_RELATION, relation_score_caped)
            rel_init.set_score(FactionRelationScore.REL_TENSION, tension_score_caped)
 


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

static func _apply_reciprocity(all_factions :Array[Faction], rng: RandomNumberGenerator, params :Dictionary={}) -> void:

    for i in range(all_factions.size()):
        for j in range(i + 1, all_factions.size()):
            var fa :Faction = all_factions[i]
            var fb :Faction = all_factions[j]
            if fa !=fb:
                fa.apply_reciprocity(fb, rng, params)


static func _clamp_delta(old_v: float, new_v: float, max_delta: float) -> float:
    var d := new_v - old_v
    if d > max_delta:
        return old_v + max_delta
    if d < -max_delta:
        return old_v - max_delta
    return new_v


static func _global_sanity_pass(world_params: Dictionary) -> void:
    # Optional: avoid too many extreme relations globally (helps ArcManager).
    # You can disable or keep very light.
    var max_extremes_per_faction := int(world_params.get("max_extremes_per_faction", 2)) # count of relations <= -80
    var all_factions = FactionManager.get_all_factions()
    for faction_a in all_factions:
        var negatives: Array = []
        for faction_b in all_factions:
            if faction_b != faction_a:
                var rs: FactionRelationScore = faction_a.get_relation_to(faction_b.id)
                var relation_score = rs.get_score(FactionRelationScore.REL_RELATION)
                if relation_score <= -80:
                    negatives.append({"b": faction_b.id, "rel": relation_score})

        if negatives.size() <= max_extremes_per_faction:
            continue

        # soften the lowest ones a bit (keep the top few as "true nemesis")
        negatives.sort_custom(func(x, y): return x["rel"] < y["rel"]) # most negative first
        for k in range(max_extremes_per_faction, negatives.size()):
            var b_id :String = negatives[k]["b"]
            if b_id != faction_a.id:
                var rs: FactionRelationScore = faction_a.get_relation_to(b_id)
                var relation_score = rs.get_score(FactionRelationScore.REL_RELATION)
                var new_relation = min(relation_score + 12, -60)  # soften towards -60
                var new_tension = max(0.0, relation_score - 8.0)
                rs.set_score(FactionRelationScore.REL_RELATION, new_relation)
                rs.set_score(FactionRelationScore.REL_TENSION, new_tension)
