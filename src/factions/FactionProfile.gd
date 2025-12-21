"""
Exemples d’utilisation
Normal :
    profile.axis_affinity = FactionProfile.generate_axis_affinity(rng, FactionProfile.GEN_NORMAL)
Centré (nuancé) :
    profile.axis_affinity = FactionProfile.generate_axis_affinity(rng, FactionProfile.GEN_CENTERED)
Dramatique (radical) :
    profile.axis_affinity = FactionProfile.generate_axis_affinity(rng, FactionProfile.GEN_DRAMATIC)
Forcer une faction “anti-magie” (antagoniste d’un monde très magique) :
    profile.axis_affinity = FactionProfile.generate_axis_affinity(
        rng, FactionProfile.GEN_DRAMATIC, {}, FactionProfile.AXIS_MAGIC
    )
Forcer une faction antagoniste à une faction dominante (profil connu) :
    profile.axis_affinity = FactionProfile.generate_axis_affinity(
        rng,
        FactionProfile.GEN_NORMAL,
        {},
        &"",                      # pas d’axe imposé
        dominant_faction.profile, # contre cette faction
        1.3                       # antagonisme un peu renforcé
    )
    
    Exemples d’utilisation
Générer une personnalité “normale” aléatoire :
profile.personality = FactionProfile.generate_personality(rng, FactionProfile.PGEN_NORMAL)
Forcer un type précis (ex : pacifique) :
    profile.personality = FactionProfile.generate_personality(
        rng, FactionProfile.PGEN_NORMAL, {}, FactionProfile.PTYPE_PACIFIST
    )
Mode dramatique (traits plus marqués) :
profile.personality = FactionProfile.generate_personality(rng, FactionProfile.PGEN_DRAMATIC)
Faire émerger un antagoniste naturel d’une faction dominante :
    profile.personality = FactionProfile.generate_personality(
        rng,
        FactionProfile.PGEN_NORMAL,
        {"antagonism_blend": 0.15},        # tu peux augmenter si tu veux du “hard counter”
        &"",                               # laisse le code choisir le template antagoniste
        dominant_faction.profile,
        1.3
    )
    
A) Profil “standard” (normal)
    var p := FactionProfile.generate_full_profile(rng, FactionProfile.GEN_NORMAL)
B) Profil “centered” (plus nuancé)
    var p := FactionProfile.generate_full_profile(rng, FactionProfile.GEN_CENTERED)
C) Profil “dramatic” (plus radical)
    var p := FactionProfile.generate_full_profile(rng, FactionProfile.GEN_DRAMATIC)
D) Faire émerger un antagoniste “anti-hégémonie”
    var p := FactionProfile.generate_full_profile(
        rng,
        FactionProfile.GEN_DRAMATIC,
            {
                "antagonist_full_mode": true,
                "antagonist_force_dominant_axis": true,
                "antagonist_personality_blend": 0.20,
                "coherence_strength": 0.75
            },
        &"",                       # pas d’axe forcé à la main
        dominant_faction.profile,  # la faction à contrer
        1.3                        # antagonisme renforcé
    )

E) Forcer “contre Magie” (mais sans cible faction)
    var p := FactionProfile.generate_full_profile(
        rng,
        FactionProfile.GEN_NORMAL,
        {"coherence_strength": 0.6},
        FactionProfile.AXIS_MAGIC
    )
    
Comment l’utiliser pour initialiser ton FactionRelationScore A→B
    var init := FactionProfile.compute_baseline_relation(a.profile, b.profile)

    var rs := FactionRelationScore.new(b.faction_id)
    rs.relation = init["relation"]
    rs.trust = init["trust"]
    rs.tension = init["tension"]
    rs.grievance = 0.0
    rs.weariness = 0.0
    rs.clamp_all()
"""
class_name FactionProfile
extends RefCounted

# --- Keys (StringName) ---
const AXIS_TECH: StringName = &"axis.tech"
const AXIS_MAGIC: StringName = &"axis.magic"
const AXIS_NATURE: StringName = &"axis.nature"
const AXIS_DIVINE: StringName = &"axis.divine"
const AXIS_CORRUPTION: StringName = &"axis.corruption"

const ALL_AXES: Array[StringName] = [
    AXIS_TECH, AXIS_MAGIC, AXIS_NATURE, AXIS_DIVINE, AXIS_CORRUPTION
]

const PERS_AGGRESSION: StringName = &"pers.aggression"
const PERS_VENGEFULNESS: StringName = &"pers.vengefulness"
const PERS_DIPLOMACY: StringName = &"pers.diplomacy"
const PERS_RISK_AVERSION: StringName = &"pers.risk_aversion"
const PERS_EXPANSIONISM: StringName = &"pers.expansionism"
const PERS_INTEGRATIONISM: StringName = &"pers.integrationism"

const ALL_PERSONALITY_KEYS: Array[StringName] = [
    PERS_AGGRESSION,
    PERS_VENGEFULNESS,
    PERS_DIPLOMACY,
    PERS_RISK_AVERSION,
    PERS_EXPANSIONISM,
    PERS_INTEGRATIONISM
]

# --- Generation constraints ---
const AXIS_MIN: int = -100
const AXIS_MAX: int = 100

const AXIS_REQUIRED_POSITIVE_GT: int = 50
const AXIS_REQUIRED_NEGATIVE_LT: int = -20

const GEN_CENTERED: StringName = &"centered"
const GEN_NORMAL: StringName = &"normal"
const GEN_DRAMATIC: StringName = &"dramatic"

const PGEN_CENTERED: StringName = &"centered"
const PGEN_NORMAL: StringName = &"normal"
const PGEN_DRAMATIC: StringName = &"dramatic"

const PTYPE_PACIFIST: StringName = &"pacifist"
const PTYPE_PRAGMATIC: StringName = &"pragmatic"
const PTYPE_WARLIKE: StringName = &"warlike"
const PTYPE_EXPANSIONIST: StringName = &"expansionist"
const PTYPE_FANATIC: StringName = &"fanatic"
const PTYPE_ASSIMILATOR: StringName = &"assimilator"
# Proposed coherent range for sum(axis_affinity.values())
const AXIS_SUM_MIN: int = 20
const AXIS_SUM_MAX: int = 90

# Personality variation around template values
const PERS_VARIATION_MIN: float = -0.1
const PERS_VARIATION_MAX: float = 0.2

# --- Data ---
# -100..100
var axis_affinity: Dictionary[StringName, int] = {}

# 0..1
var personality: Dictionary[StringName, float] = {}


 
# ---- CONSTRUCTOR ----   
func _init() -> void:
    # Defaults (optional): set everything to 0 / 0.5 if you want stable lookups
    for a in ALL_AXES:
        axis_affinity[a] = 0
    for k in ALL_PERSONALITY_KEYS:
        personality[k] = 0.5

static func from_profile_and_axis(prof: Dictionary[StringName, float], axis: Dictionary[StringName, int]) -> FactionProfile:
    var profile = FactionProfile.new()
    for key in prof.keys():
        profile.personality[key] = float(prof[key])
    for key in axis.keys():
        profile.axis_affinity[key] = int(axis[key])
    return profile
# ---- Axis helpers ----
func set_axis_affinity(axis: StringName, value: int) -> void:
    axis_affinity[axis] = clampi(value, AXIS_MIN, AXIS_MAX)

func get_axis_affinity(axis: StringName, default_value: int = 0) -> int:
    return axis_affinity.get(axis, default_value)

func axis_sum() -> int:
    var s := 0
    for a in ALL_AXES:
        s += int(axis_affinity.get(a, 0))
    return s

func validate_axis_rules() -> bool:
    var has_pos := false
    var has_neg := false
    for a in ALL_AXES:
        var v: int = int(axis_affinity.get(a, 0))
        if v > AXIS_REQUIRED_POSITIVE_GT:
            has_pos = true
        if v < AXIS_REQUIRED_NEGATIVE_LT:
            has_neg = true

    var s := axis_sum()
    return has_pos and has_neg and s >= AXIS_SUM_MIN and s <= AXIS_SUM_MAX

# ---- Personality helpers ----
func set_personality(key: StringName, value: float) -> void:
    personality[key] = clampf(value, 0.0, 1.0)

func get_personality(key: StringName, default_value: float = 0.5) -> float:
    return float(personality.get(key, default_value))
        
# Applies small random variation to a template (Dictionary[StringName, float] of 0..1 values)
func apply_personality_template(template: Dictionary[StringName, float], rng: RandomNumberGenerator = null) -> void:
    for k in ALL_PERSONALITY_KEYS:
        var base := clampf(float(template.get(k, 0.5)), 0.0, 1.0)
        var delta :float = rng.randf_range(PERS_VARIATION_MIN, PERS_VARIATION_MAX) if rng!= null else 0.0
        set_personality(k, base + delta)

# ---- Dynamic lookup (optional): one entry point for “search dynamique” ----
# If you pass an axis key, returns int as float (e.g. 42.0). If personality key, returns 0..1 float.
func get_score_dynamic(key: StringName, default_value: float = 0.0) -> float:
    if axis_affinity.has(key):
        return float(axis_affinity[key])
    if personality.has(key):
        return float(personality[key])
    return default_value


static func generate_axis_affinity_OLD(rng: RandomNumberGenerator) -> Dictionary[StringName, int]:
    # We retry because we want hard guarantees ("à coup sûr") with a nice distribution.
    for attempt in range(60):
        var d: Dictionary[StringName, int] = {}

        # 1) Pick one strong positive axis and one strong negative axis
        var axes := ALL_AXES.duplicate()
        var pos_axis: StringName = axes[rng.randi_range(0, axes.size() - 1)]
        axes.erase(pos_axis)
        var neg_axis: StringName = axes[rng.randi_range(0, axes.size() - 1)]
        axes.erase(neg_axis)
        var rem_axes: Array[StringName] = axes

        # Strong anchors (guarantee constraints)
        # Keep some room for later adjustments.
        d[pos_axis] = rng.randi_range(60, 92)     # > 50 guaranteed, room up to 100
        d[neg_axis] = -rng.randi_range(25, 80)    # < -20 guaranteed, room down to -100

        # 2) Generate remaining axes with a "natural" distribution (not all near 0)
        # We enforce at least 2 out of the 3 remaining axes with |value| >= 15.
        var ok_distribution := false
        for _resample in range(30):
            var strong_count := 0
            for a in rem_axes:
                var v := int(round(rng.randfn(0.0, 32.0))) # normal-ish around 0

                # Push away from 0 sometimes, to avoid "0,0,0"
                if abs(v) < 8:
                    var delta = 1
                    if rng.randf() < 0.5:
                        delta = -1
                    v += delta * rng.randi_range(10, 22)

                # Avoid extremes too often (keeps room for sum-adjust)
                v = clampi(v, -75, 75)
                d[a] = v

                if abs(v) >= 15:
                    strong_count += 1

            if strong_count >= 2:
                ok_distribution = true
                break

        if not ok_distribution:
            continue

        # 3) Choose a target sum inside [AXIS_SUM_MIN..AXIS_SUM_MAX] and adjust values to hit it
        var target_sum := rng.randi_range(AXIS_SUM_MIN, AXIS_SUM_MAX)
        var current_sum := _axis_sum_dict(d)
        var diff := target_sum - current_sum

        # Per-axis allowed ranges (to preserve the >50 and <-20 guarantees)
        var min_allowed: Dictionary[StringName, int] = {}
        var max_allowed: Dictionary[StringName, int] = {}
        for a in ALL_AXES:
            min_allowed[a] = AXIS_MIN
            max_allowed[a] = AXIS_MAX
        min_allowed[pos_axis] = 51
        max_allowed[pos_axis] = 100
        min_allowed[neg_axis] = -100
        max_allowed[neg_axis] = -21

        # Adjustment loop: distribute diff across axes with available headroom.
        var iter := 0
        while diff != 0 and iter < 250:
            iter += 1

            var candidates: Array[StringName] = []
            for a in ALL_AXES:
                var v: int = d.get(a, 0)
                if diff > 0 and v < max_allowed[a]:
                    candidates.append(a)
                elif diff < 0 and v > min_allowed[a]:
                    candidates.append(a)

            if candidates.is_empty():
                break

            # Prefer adjusting non-anchor axes most of the time (keeps identity stable)
            var chosen: StringName
            if rng.randf() < 0.75:
                var non_anchor: Array[StringName] = []
                for a in candidates:
                    if a != pos_axis and a != neg_axis:
                        non_anchor.append(a)
                chosen = candidates[rng.randi_range(0, candidates.size() - 1)] if non_anchor.is_empty() else non_anchor[rng.randi_range(0, non_anchor.size() - 1)]
            else:
                chosen = candidates[rng.randi_range(0, candidates.size() - 1)]

            var headroom := 0
            if diff > 0:
                headroom = max_allowed[chosen] - d[chosen]
            else:
                headroom = d[chosen] - min_allowed[chosen]

            if headroom <= 0:
                continue

            var step_mag :int = min(abs(diff), headroom, rng.randi_range(3, 14))
            var step :int = step_mag if (diff > 0) else -step_mag

            d[chosen] += step
            diff -= step

        # 4) Final validation (hard guarantees)
        var final_sum := _axis_sum_dict(d)
        if final_sum < AXIS_SUM_MIN or final_sum > AXIS_SUM_MAX:
            continue
        if d[pos_axis] <= AXIS_REQUIRED_POSITIVE_GT:
            continue
        if d[neg_axis] >= AXIS_REQUIRED_NEGATIVE_LT:
            continue

        # Extra "interesting distribution" check:
        # At least 3 axes with |value| >= 12 (so it's not "one big +, one -, and dust").
        var interesting := 0
        for a in ALL_AXES:
            if abs(int(d[a])) >= 12:
                interesting += 1
        if interesting < 3:
            continue

        # Clamp (safety) and return
        for a in ALL_AXES:
            d[a] = clampi(int(d[a]), AXIS_MIN, AXIS_MAX)
        return d

    # Fallback (should basically never happen): deterministic-ish profile
    var fallback: Dictionary[StringName, int] = {}
    for a in ALL_AXES:
        fallback[a] = 0
    fallback[AXIS_MAGIC] = 70
    fallback[AXIS_TECH] = -30
    fallback[AXIS_NATURE] = 20
    fallback[AXIS_DIVINE] = -5
    fallback[AXIS_CORRUPTION] = 0
    return fallback


static func _axis_sum_dict_OLD(d: Dictionary) -> int:
    var s := 0
    for a in ALL_AXES:
        s += int(d.get(a, 0))
    return s

static func generate_axis_affinity(
    rng: RandomNumberGenerator,
    mode: StringName = GEN_NORMAL,
    params: Dictionary = {},
    force_against_axis: StringName = &"",        # ex: AXIS_MAGIC -> force un gros négatif sur Magie
    against_faction_profile: FactionProfile = null, # faction dominante à contrer
    antagonism_strength: float = 1.0             # 0..2 (en pratique)
) -> Dictionary[StringName, int]:
    var p := _default_axis_gen_params(mode)
    for k in params.keys():
        p[k] = params[k]

    var attempts: int = int(p.get("attempts", 80))
    var best: Dictionary[StringName, int] = {}
    var best_score := -INF

    for i in range(attempts):
        var candidate := _generate_axis_affinity_once(rng, p, force_against_axis, against_faction_profile, antagonism_strength)
        if candidate.is_empty():
            continue

        # Si on veut contrer une faction, on choisit le candidat le plus antagoniste (dot-product le plus négatif)
        if against_faction_profile != null:
            var score := _antagonism_score(candidate, against_faction_profile.axis_affinity)
            if score > best_score:
                best_score = score
                best = candidate
        else:
            return candidate

    return best if not best.is_empty() else _fallback_axis_affinity()


static func _default_axis_gen_params(mode: StringName) -> Dictionary:
    # Tu peux override n’importe quel champ via `params`.
    # Les 3 modes changent principalement : sigma, clamps, anchors et "interestingness".
    var d := {
        "sum_min": AXIS_SUM_MIN,         # 20
        "sum_max": AXIS_SUM_MAX,         # 90
        "pos_min": 60, "pos_max": 92,    # anchor positif > 50
        "neg_min_abs": 25, "neg_max_abs": 80, # anchor négatif < -20

        "other_sigma": 32.0,
        "other_clamp_abs": 75,

        "near_zero_abs": 8,
        "near_zero_push_min": 10,
        "near_zero_push_max": 22,

        "strong_abs_threshold": 15,
        "min_strong_in_others": 2,       # parmi les 3 axes restants
        "min_interesting_axes": 3,       # total axes avec |v| >= interesting_abs
        "interesting_abs": 12,

        "adjust_step_min": 3,
        "adjust_step_max": 14,

        "cooldown_bias_non_anchor": 0.75,
        "attempts": 80,
        "inner_resample_other": 30,
        "max_adjust_iters": 250,
    }

    match mode:
        GEN_CENTERED:
            # plus “nuancé” : moins d’extrêmes, plus de retour vers 0
            d["pos_min"] = 55
            d["pos_max"] = 78
            d["neg_min_abs"] = 25
            d["neg_max_abs"] = 55
            d["other_sigma"] = 20.0
            d["other_clamp_abs"] = 55
            d["interesting_abs"] = 10
            d["min_interesting_axes"] = 4     # plus d’axes “un peu marqués”
            # somme un peu moins haute en moyenne (garde de la place pour dériver ensuite)
            d["sum_min"] = 20
            d["sum_max"] = 75

        GEN_DRAMATIC:
            # plus “radical” : identité forte, tensions idéologiques marquées
            d["pos_min"] = 75
            d["pos_max"] = 100
            d["neg_min_abs"] = 40
            d["neg_max_abs"] = 100
            d["other_sigma"] = 45.0
            d["other_clamp_abs"] = 95
            d["near_zero_push_min"] = 18
            d["near_zero_push_max"] = 35
            d["strong_abs_threshold"] = 18
            d["interesting_abs"] = 15
            d["min_interesting_axes"] = 3
            d["sum_min"] = 20
            d["sum_max"] = 90

        _:
            # GEN_NORMAL = defaults
            pass

    return d


static func _generate_axis_affinity_once(
    rng: RandomNumberGenerator,
    p: Dictionary,
    force_against_axis: StringName,
    against_faction_profile: FactionProfile,
    antagonism_strength: float
) -> Dictionary[StringName, int]:
    # 1) Choix des axes anchors (pos/neg), en tenant compte des “contre”
    var anchors := _pick_anchor_axes(rng, force_against_axis, against_faction_profile)
    if anchors.is_empty():
        return {}
    var pos_axis: StringName = anchors["pos"]
    var neg_axis: StringName = anchors["neg"]

    # 2) Valeurs anchors
    var pos_min: int = int(p["pos_min"])
    var pos_max: int = int(p["pos_max"])
    var neg_min_abs: int = int(p["neg_min_abs"])
    var neg_max_abs: int = int(p["neg_max_abs"])

    # antagonism_strength : renforce légèrement les anchors quand on veut un vrai antagoniste
    if force_against_axis != &"" or against_faction_profile != null:
        var k := clampf(antagonism_strength, 0.0, 2.0)
        pos_min = clampi(pos_min + int(8.0 * k), 51, 100)
        pos_max = clampi(pos_max + int(10.0 * k), 51, 100)
        neg_min_abs = clampi(neg_min_abs + int(8.0 * k), 21, 100)
        neg_max_abs = clampi(neg_max_abs + int(10.0 * k), 21, 100)

    var d: Dictionary[StringName, int] = {}
    for a in ALL_AXES:
        d[a] = 0

    d[pos_axis] = rng.randi_range(pos_min, pos_max)          # > 50
    d[neg_axis] = -rng.randi_range(neg_min_abs, neg_max_abs) # < -20

    # 3) Génération des 3 autres axes (distribution intéressante)
    var rem_axes: Array[StringName] = []
    for a in ALL_AXES:
        if a != pos_axis and a != neg_axis:
            rem_axes.append(a)

    var ok_distribution := false
    for _resample in range(int(p.get("inner_resample_other", 30))):
        var strong_count := 0
        for a in rem_axes:
            var v := int(round(rng.randfn(0.0, float(p["other_sigma"]))))
            if abs(v) < int(p["near_zero_abs"]):
                var delta = 1
                if rng.randf() < 0.5:
                    delta = -1
                v += delta * rng.randi_range(int(p["near_zero_push_min"]), int(p["near_zero_push_max"]))
            v = clampi(v, -int(p["other_clamp_abs"]), int(p["other_clamp_abs"]))
            d[a] = v
            if abs(v) >= int(p["strong_abs_threshold"]):
                strong_count += 1
        if strong_count >= int(p["min_strong_in_others"]):
            ok_distribution = true
            break

    if not ok_distribution:
        return {}

    # 4) Ajuster la somme dans [sum_min..sum_max] sans casser les garanties
    var target_sum := rng.randi_range(int(p["sum_min"]), int(p["sum_max"]))
    var diff := target_sum - _axis_sum_dict(d)

    var min_allowed: Dictionary[StringName, int] = {}
    var max_allowed: Dictionary[StringName, int] = {}
    for a in ALL_AXES:
        min_allowed[a] = AXIS_MIN
        max_allowed[a] = AXIS_MAX
    min_allowed[pos_axis] = 51
    max_allowed[pos_axis] = 100
    min_allowed[neg_axis] = -100
    max_allowed[neg_axis] = -21

    var max_iters := int(p.get("max_adjust_iters", 250))
    var iter := 0
    while diff != 0 and iter < max_iters:
        iter += 1
        var candidates: Array[StringName] = []
        for a in ALL_AXES:
            var v: int = d[a]
            if diff > 0 and v < max_allowed[a]:
                candidates.append(a)
            elif diff < 0 and v > min_allowed[a]:
                candidates.append(a)

        if candidates.is_empty():
            break

        # Ajuster surtout les non-anchors
        var chosen: StringName
        if rng.randf() < float(p.get("cooldown_bias_non_anchor", 0.75)):
            var non_anchor: Array[StringName] = []
            for a in candidates:
                if a != pos_axis and a != neg_axis:
                    non_anchor.append(a)
            chosen = candidates.pick_random() if non_anchor.is_empty() else non_anchor.pick_random()
        else:
            chosen = candidates.pick_random()

        var headroom := 0
        if diff > 0:
            headroom = max_allowed[chosen] - d[chosen]
        else:
            headroom = d[chosen] - min_allowed[chosen]
        if headroom <= 0:
            continue

        var step_mag :int = min(abs(diff), headroom, rng.randi_range(int(p["adjust_step_min"]), int(p["adjust_step_max"])))
        var step :int = step_mag if (diff > 0) else -step_mag
        d[chosen] += step
        diff -= step

    # 5) Validation finale (garanties + “interestingness”)
    var s := _axis_sum_dict(d)
    if s < int(p["sum_min"]) or s > int(p["sum_max"]):
        return {}
    if d[pos_axis] <= AXIS_REQUIRED_POSITIVE_GT:
        return {}
    if d[neg_axis] >= AXIS_REQUIRED_NEGATIVE_LT:
        return {}

    var interesting := 0
    for a in ALL_AXES:
        if abs(d[a]) >= int(p["interesting_abs"]):
            interesting += 1
    if interesting < int(p["min_interesting_axes"]):
        return {}

    # Clamp sécurité
    for a in ALL_AXES:
        d[a] = clampi(d[a], AXIS_MIN, AXIS_MAX)

    return d


static func _pick_anchor_axes(
    rng: RandomNumberGenerator,
    force_against_axis: StringName,
    against_faction_profile: FactionProfile
) -> Dictionary:
    var axes := ALL_AXES.duplicate()

    var neg_axis: StringName = &""
    var pos_axis: StringName = &""

    # 1) Forcer un gros négatif sur un axe précis
    if force_against_axis != &"" and axes.has(force_against_axis):
        neg_axis = force_against_axis
        axes.erase(neg_axis)

    # 2) Forcer un antagonisme contre une faction : opposer les “pôles”
    # - si la faction cible aime fortement un axe -> on le déteste (neg)
    # - si la faction cible déteste fortement un axe -> on l’aime (pos)
    if against_faction_profile != null:
        var tgt := against_faction_profile.axis_affinity

        # Choix pos : axe le plus négatif chez la cible (on fait l’inverse)
        var best_pos_axis: StringName = &""
        var best_pos_value := 999999
        for a in axes:
            var v := int(tgt.get(a, 0))
            if v < best_pos_value:
                best_pos_value = v
                best_pos_axis = a
        if best_pos_axis != &"":
            pos_axis = best_pos_axis
            axes.erase(pos_axis)

        # Si neg_axis n'est pas forcé, choisir l’axe le plus positif chez la cible
        if neg_axis == &"":
            # remettre tous les axes sauf pos_axis
            var axes2 := ALL_AXES.duplicate()
            if axes2.has(pos_axis):
                axes2.erase(pos_axis)

            var best_neg_axis: StringName = &""
            var best_neg_value := -999999
            for a in axes2:
                var v := int(tgt.get(a, 0))
                if v > best_neg_value:
                    best_neg_value = v
                    best_neg_axis = a
            neg_axis = best_neg_axis

    # 3) Si encore incomplet, random
    if pos_axis == &"":
        pos_axis = axes[rng.randi_range(0, axes.size() - 1)]
        axes.erase(pos_axis)
    if neg_axis == &"":
        # pick from remaining original axes
        var remaining := ALL_AXES.duplicate()
        remaining.erase(pos_axis)
        neg_axis = remaining[rng.randi_range(0, remaining.size() - 1)]

    # éviter collision
    if neg_axis == pos_axis:
        var remaining2 := ALL_AXES.duplicate()
        remaining2.erase(pos_axis)
        neg_axis = remaining2[rng.randi_range(0, remaining2.size() - 1)]

    return {"pos": pos_axis, "neg": neg_axis}


static func _antagonism_score(my_aff: Dictionary, target_aff: Dictionary) -> float:
    # On veut être "opposé" : score haut quand le dot-product est très négatif.
    var dot := 0.0
    for a in ALL_AXES:
        dot += float(int(my_aff.get(a, 0)) * int(target_aff.get(a, 0)))
    return -dot


static func _axis_sum_dict(d: Dictionary) -> int:
    var s := 0
    for a in ALL_AXES:
        s += int(d.get(a, 0))
    return s


static func _fallback_axis_affinity() -> Dictionary[StringName, int]:
    var f: Dictionary[StringName, int] = {}
    for a in ALL_AXES:
        f[a] = 0
    f[AXIS_MAGIC] = 70
    f[AXIS_TECH] = -30
    f[AXIS_NATURE] = 20
    f[AXIS_DIVINE] = -5
    f[AXIS_CORRUPTION] = 0
    return f

static func personality_templates() -> Dictionary:
    # Valeurs de base 0..1 (tu pourras ajuster selon ton design)
    return {
        PTYPE_PACIFIST: {
            PERS_AGGRESSION: 0.15,
            PERS_VENGEFULNESS: 0.20,
            PERS_DIPLOMACY: 0.85,
            PERS_RISK_AVERSION: 0.70,
            PERS_EXPANSIONISM: 0.20,
            PERS_INTEGRATIONISM: 0.60,
        },
        PTYPE_PRAGMATIC: {
            PERS_AGGRESSION: 0.35,
            PERS_VENGEFULNESS: 0.35,
            PERS_DIPLOMACY: 0.55,
            PERS_RISK_AVERSION: 0.50,
            PERS_EXPANSIONISM: 0.40,
            PERS_INTEGRATIONISM: 0.40,
        },
        PTYPE_WARLIKE: {
            PERS_AGGRESSION: 0.80,
            PERS_VENGEFULNESS: 0.70,
            PERS_DIPLOMACY: 0.20,
            PERS_RISK_AVERSION: 0.30,
            PERS_EXPANSIONISM: 0.60,
            PERS_INTEGRATIONISM: 0.20,
        },
        PTYPE_EXPANSIONIST: {
            PERS_AGGRESSION: 0.65,
            PERS_VENGEFULNESS: 0.45,
            PERS_DIPLOMACY: 0.30,
            PERS_RISK_AVERSION: 0.35,
            PERS_EXPANSIONISM: 0.90,
            PERS_INTEGRATIONISM: 0.50,
        },
        PTYPE_FANATIC: {
            PERS_AGGRESSION: 0.75,
            PERS_VENGEFULNESS: 0.85,
            PERS_DIPLOMACY: 0.10,
            PERS_RISK_AVERSION: 0.20,
            PERS_EXPANSIONISM: 0.50,
            PERS_INTEGRATIONISM: 0.05,
        },
        PTYPE_ASSIMILATOR: {
            PERS_AGGRESSION: 0.45,
            PERS_VENGEFULNESS: 0.25,
            PERS_DIPLOMACY: 0.60,
            PERS_RISK_AVERSION: 0.45,
            PERS_EXPANSIONISM: 0.55,
            PERS_INTEGRATIONISM: 0.90,
        },
    }

static func default_personality_gen_params(mode: StringName) -> Dictionary:
    var d := {
        "attempts": 50,

        # Par défaut, ta plage souhaitée :
        "variation_min": -0.1,
        "variation_max": 0.2,

        # “Interestingness” : éviter un profil trop plat
        "require_high": 0.75,
        "require_low": 0.35,
        "min_high_count": 1,
        "min_low_count": 1,

        # Blend vers l’antagonisme (0..1)
        "antagonism_blend": 0.0,

        # Optionnel : favoriser certains templates
        # ex: {"pacifist": 1.0, "warlike": 0.2, ...}
        "template_weights": {},
    }

    match mode:
        PGEN_CENTERED:
            d["variation_min"] = -0.05
            d["variation_max"] = 0.10
            d["require_high"] = 0.70
            d["require_low"] = 0.40

        PGEN_DRAMATIC:
            d["variation_min"] = -0.15
            d["variation_max"] = 0.25
            d["require_high"] = 0.80
            d["require_low"] = 0.30

        _:
            pass

    return d

static func generate_personality(
    rng: RandomNumberGenerator,
    mode: StringName = PGEN_NORMAL,
    params: Dictionary = {},
    personality_type: StringName = &"",           # si vide: choisi automatiquement
    against_faction_profile: FactionProfile = null, # pour générer un antagoniste
    antagonism_strength: float = 1.0              # 0..2
) -> Dictionary[StringName, float]:
    var p := default_personality_gen_params(mode)
    for k in params.keys():
        p[k] = params[k]

    var templates := personality_templates()
    var attempts := int(p.get("attempts", 50))

    # 1) Choix du template
    var chosen_type := personality_type
    if chosen_type == &"":
        if against_faction_profile != null:
            chosen_type = _pick_most_antagonistic_template(templates, against_faction_profile.personality)
        else:
            chosen_type = _pick_weighted_template(rng, templates, p.get("template_weights", {}))

    if not templates.has(chosen_type):
        chosen_type = PTYPE_PRAGMATIC

    # 2) Génération avec retries pour “interestingness”
    var best: Dictionary[StringName, float] = {}
    var best_interest := -INF

    for _i in range(attempts):
        var cand := _build_personality_from_template(
            rng,
            Dictionary(templates[chosen_type]),
            p,
            against_faction_profile,
            antagonism_strength
        )
        if cand.is_empty():
            continue

        var interest := _interest_score(cand, float(p["require_high"]), float(p["require_low"]))
        if _meets_interest(cand, p):
            return cand

        # sinon garder la meilleure, au cas où (fallback soft)
        if interest > best_interest:
            best_interest = interest
            best = cand

    return best if not best.is_empty() else _fallback_personality()


static func _build_personality_from_template(
    rng: RandomNumberGenerator,
    base: Dictionary,
    p: Dictionary,
    against_faction_profile: FactionProfile,
    antagonism_strength: float
) -> Dictionary[StringName, float]:
    var out: Dictionary[StringName, float] = {}

    var var_min := float(p.get("variation_min", -0.1))
    var var_max := float(p.get("variation_max", 0.2))

    # Antagonism blend (0..1) : plus c’est haut, plus on tend vers l’inverse de la cible
    var blend := float(p.get("antagonism_blend", 0.0))
    if against_faction_profile != null:
        blend = clampf(blend + 0.35 * clampf(antagonism_strength, 0.0, 2.0), 0.0, 1.0)

    for k in ALL_PERSONALITY_KEYS:
        var v := clampf(float(base.get(k, 0.5)), 0.0, 1.0)

        if against_faction_profile != null:
            var t := clampf(float(against_faction_profile.personality.get(k, 0.5)), 0.0, 1.0)
            var opposite := 1.0 - t
            v = lerp(v, opposite, blend)

        var delta := rng.randf_range(var_min, var_max)
        v = clampf(v + delta, 0.0, 1.0)
        out[k] = v

    return out


static func _pick_weighted_template(
    rng: RandomNumberGenerator,
    templates: Dictionary,
    weights: Dictionary
) -> StringName:
    # Si weights vide => uniforme
    var keys: Array = templates.keys()
    if weights.is_empty():
        return StringName(keys[rng.randi_range(0, keys.size() - 1)])

    var total := 0.0
    for k in keys:
        total += max(0.0, float(weights.get(k, 1.0)))

    if total <= 0.0:
        return StringName(keys[rng.randi_range(0, keys.size() - 1)])

    var r := rng.randf() * total
    var acc := 0.0
    for k in keys:
        acc += max(0.0, float(weights.get(k, 1.0)))
        if r <= acc:
            return StringName(k)

    return StringName(keys[0])


static func _pick_most_antagonistic_template(templates: Dictionary, target_personality: Dictionary) -> StringName:
    # Choisit le template le plus "opposé" au target (corrélation négative autour de 0.5)
    var best_key: StringName = PTYPE_PRAGMATIC
    var best_score := -INF
    for k in templates.keys():
        var tpl: Dictionary = templates[k]
        var score := 0.0
        for perso_trait in ALL_PERSONALITY_KEYS:
            var a := float(tpl.get(perso_trait, 0.5)) - 0.5
            var b := float(target_personality.get(perso_trait, 0.5)) - 0.5
            score += -a * b  # plus c'est grand, plus c’est opposé
        if score > best_score:
            best_score = score
            best_key = StringName(k)
    return best_key


static func _meets_interest(personality: Dictionary, p: Dictionary) -> bool:
    var high_thr := float(p.get("require_high", 0.75))
    var low_thr := float(p.get("require_low", 0.35))
    var min_high := int(p.get("min_high_count", 1))
    var min_low := int(p.get("min_low_count", 1))

    var hi := 0
    var lo := 0
    for k in ALL_PERSONALITY_KEYS:
        var v := float(personality.get(k, 0.5))
        if v >= high_thr:
            hi += 1
        if v <= low_thr:
            lo += 1

    return hi >= min_high and lo >= min_low


static func _interest_score(personality: Dictionary, high_thr: float, low_thr: float) -> float:
    var hi := 0
    var lo := 0
    var spread := 0.0
    for k in ALL_PERSONALITY_KEYS:
        var v := float(personality.get(k, 0.5))
        if v >= high_thr: hi += 1
        if v <= low_thr: lo += 1
        spread += abs(v - 0.5)
    return float(hi + lo) + spread


static func _fallback_personality() -> Dictionary[StringName, float]:
    # fallback stable
    return {
        PERS_AGGRESSION: 0.35,
        PERS_VENGEFULNESS: 0.35,
        PERS_DIPLOMACY: 0.55,
        PERS_RISK_AVERSION: 0.50,
        PERS_EXPANSIONISM: 0.40,
        PERS_INTEGRATIONISM: 0.40,
    }

static func generate_full_profile(
    rng: RandomNumberGenerator,
    gen_type: StringName = GEN_NORMAL,          # centered/normal/dramatic (on réutilise tes modes)
    params: Dictionary = {},
    force_against_axis: StringName = &"",        # optionnel : AXIS_MAGIC etc.
    against_faction_profile: FactionProfile = null, # optionnel : pour créer un antagoniste
    antagonism_strength: float = 1.0             # 0..2 (≈ 1.0 normal)
) -> FactionProfile:
    var profile := FactionProfile.new()

    # --- Paramètres par défaut ---
    var axis_mode: StringName = StringName(params.get("axis_mode", gen_type))
    var pers_mode: StringName = StringName(params.get("personality_mode", gen_type))

    var axis_params: Dictionary = Dictionary(params.get("axis_params", {}))
    var pers_params: Dictionary = Dictionary(params.get("personality_params", {}))

    # Coherence (blend global axes -> personnalité)
    var coherence_strength := float(params.get("coherence_strength", _default_coherence_strength(gen_type)))

    # Anti-magic style (prudente vs fanatique)
    var anti_magic_base_fanatic := float(params.get("anti_magic_base_fanatic", 0.35)) # base prob
    var anti_magic_enabled := bool(params.get("anti_magic_enabled", true))

    # Antagoniste : si true, on renforce un peu le côté “contre”
    var antagonist_full_mode := bool(params.get("antagonist_full_mode", against_faction_profile != null))
    var antagonist_force_dominant_axis := bool(params.get("antagonist_force_dominant_axis", true))
    var antagonist_personality_blend := float(params.get("antagonist_personality_blend", 0.15))

    # 1) Déterminer un axe à contrer si on vise une faction hégémonique
    var effective_force_against_axis := force_against_axis
    if antagonist_full_mode and against_faction_profile != null and antagonist_force_dominant_axis and effective_force_against_axis == &"":
        effective_force_against_axis = _dominant_axis_of(against_faction_profile.axis_affinity)

    # 2) Générer les axes (normal/centered/dramatic + paramètres)
    profile.axis_affinity = generate_axis_affinity(
        rng,
        axis_mode,
        axis_params,
        effective_force_against_axis,
        against_faction_profile,
        antagonism_strength
    )

    # 3) Choisir un template de personnalité cohérent avec les axes (weights)
    var axis_based_weights := _personality_weights_from_axes(profile.axis_affinity)

    # Si antagoniste complet, on mélange un peu les weights avec l’opposition à la cible
    # (sans empêcher le “contre-template” automatique si tu veux le garder)
    pers_params["template_weights"] = axis_based_weights

    # 4) Générer personnalité (template + variation + éventuellement antagonisme contre une faction)
    if antagonist_full_mode and against_faction_profile != null:
        # un petit boost pour pousser vers l’inverse, sans être une caricature
        var prev := float(pers_params.get("antagonism_blend", 0.0))
        pers_params["antagonism_blend"] = clampf(prev + antagonist_personality_blend, 0.0, 1.0)

    profile.personality = generate_personality(
        rng,
        _to_personality_mode(pers_mode),  # mapping gen_type -> PGEN_*
        pers_params,
        &"", # laisser choisir (pondéré + antagoniste si against != null)
        against_faction_profile,
        antagonism_strength
    )

    # 5) Appliquer “cohérence axes -> traits” (petites poussées, clamp 0..1)
    _apply_axis_bias_to_personality(profile.personality, profile.axis_affinity, coherence_strength)

    # 6) Cas spécial : anti-magie fort => prudente OU fanatique (au choix, probabiliste)
    if anti_magic_enabled:
        _apply_anti_magic_style(profile.personality, profile.axis_affinity, rng, anti_magic_base_fanatic, coherence_strength)

    return profile


# ---------------------------
# Helpers
# ---------------------------

static func _default_coherence_strength(gen_type: StringName) -> float:
    match gen_type:
        GEN_CENTERED:
            return 0.35
        GEN_DRAMATIC:
            return 0.75
        _:
            return 0.55


static func _to_personality_mode(axis_mode: StringName) -> StringName:
    # Recycle tes modes centered/normal/dramatic vers les modes personnalité
    match axis_mode:
        GEN_CENTERED:
            return PGEN_CENTERED
        GEN_DRAMATIC:
            return PGEN_DRAMATIC
        _:
            return PGEN_NORMAL


static func _dominant_axis_of(axis_aff: Dictionary) -> StringName:
    # Axe avec affinité la plus élevée (ex: hégémonie magique -> AXIS_MAGIC)
    var best_axis: StringName = AXIS_TECH
    var best_v := -999999
    for a in ALL_AXES:
        var v := int(axis_aff.get(a, 0))
        if v > best_v:
            best_v = v
            best_axis = a
    return best_axis


static func _personality_weights_from_axes(axis_aff: Dictionary) -> Dictionary:
    # Renvoie un poids par template, basé sur “couleur idéologique” (simple mais efficace).
    # Les poids sont relatifs, _pick_weighted_template gère la normalisation.
    var tech := float(int(axis_aff.get(AXIS_TECH, 0))) / 100.0
    var magic := float(int(axis_aff.get(AXIS_MAGIC, 0))) / 100.0
    var nature := float(int(axis_aff.get(AXIS_NATURE, 0))) / 100.0
    var divine := float(int(axis_aff.get(AXIS_DIVINE, 0))) / 100.0
    var corr := float(int(axis_aff.get(AXIS_CORRUPTION, 0))) / 100.0

    # Quelques heuristiques :
    # - Corruption forte => fanatique / belliqueux
    # - Nature + Divine => pacifique / assimilateur
    # - Tech => pragmatique / expansionniste
    # - Anti-magic très fort peut pousser pacifique prudent OU fanatique puriste (géré plus bas aussi)
    var anti_magic := clampf((-magic - 0.5) / 0.5, 0.0, 1.0) # ~0 si magic >= -50, ~1 si magic <= -100

    var w := {}
    w[PTYPE_PRAGMATIC] = 1.0 + 1.2*max(0.0, tech) + 0.4*max(0.0, magic)
    w[PTYPE_EXPANSIONIST] = 0.8 + 1.6*max(0.0, tech) + 0.8*max(0.0, corr)
    w[PTYPE_PACIFIST] = 0.8 + 1.6*max(0.0, nature) + 1.2*max(0.0, divine) + 0.6*anti_magic
    w[PTYPE_ASSIMILATOR] = 0.7 + 1.4*max(0.0, divine) + 0.8*max(0.0, magic) + 0.6*max(0.0, nature)
    w[PTYPE_WARLIKE] = 0.7 + 1.2*max(0.0, corr) + 0.6*max(0.0, tech)
    w[PTYPE_FANATIC] = 0.5 + 2.0*max(0.0, corr) + 1.0*max(0.0, divine) + 0.7*anti_magic

    return w


static func _apply_axis_bias_to_personality(personality: Dictionary, axis_aff: Dictionary, strength: float) -> void:
    # Pousses douces et cohérentes : axes -> traits.
    # strength 0..1 (0 = aucun effet, 1 = effet plein)
    var tech := float(int(axis_aff.get(AXIS_TECH, 0))) / 100.0
    var magic := float(int(axis_aff.get(AXIS_MAGIC, 0))) / 100.0
    var nature := float(int(axis_aff.get(AXIS_NATURE, 0))) / 100.0
    var divine := float(int(axis_aff.get(AXIS_DIVINE, 0))) / 100.0
    var corr := float(int(axis_aff.get(AXIS_CORRUPTION, 0))) / 100.0

    # Ajustements (petits, puis multipliés par strength)
    var adj := {
        PERS_AGGRESSION: 0.0,
        PERS_VENGEFULNESS: 0.0,
        PERS_DIPLOMACY: 0.0,
        PERS_RISK_AVERSION: 0.0,
        PERS_EXPANSIONISM: 0.0,
        PERS_INTEGRATIONISM: 0.0,
    }

    # Tech : plus structurant/expansion, un peu moins “conciliant”
    adj[PERS_EXPANSIONISM] += 0.18 * tech
    adj[PERS_AGGRESSION] += 0.08 * tech
    adj[PERS_DIPLOMACY] -= 0.06 * tech

    # Magie : souvent moins prudent (prise de risque), plus ouvert à intégration (soft)
    adj[PERS_RISK_AVERSION] -= 0.12 * magic
    adj[PERS_INTEGRATIONISM] += 0.08 * magic

    # Nature : plus diplomate, moins agressif, un peu plus prudent
    adj[PERS_DIPLOMACY] += 0.12 * nature
    adj[PERS_AGGRESSION] -= 0.10 * nature
    adj[PERS_RISK_AVERSION] += 0.06 * nature

    # Divin : diplomatie + intégration (coalitions), un peu plus prudent
    adj[PERS_DIPLOMACY] += 0.10 * divine
    adj[PERS_INTEGRATIONISM] += 0.10 * divine
    adj[PERS_RISK_AVERSION] += 0.05 * divine

    # Corruption : agressif, rancunier, peu diplomate, peu intégrateur, moins prudent
    adj[PERS_AGGRESSION] += 0.22 * corr
    adj[PERS_VENGEFULNESS] += 0.18 * corr
    adj[PERS_DIPLOMACY] -= 0.18 * corr
    adj[PERS_INTEGRATIONISM] -= 0.18 * corr
    adj[PERS_RISK_AVERSION] -= 0.10 * corr

    for k in ALL_PERSONALITY_KEYS:
        var v := float(personality.get(k, 0.5))
        v = clampf(v + adj.get(k, 0.0) * clampf(strength, 0.0, 1.0), 0.0, 1.0)
        personality[k] = v


static func _apply_anti_magic_style(
    personality: Dictionary,
    axis_aff: Dictionary,
    rng: RandomNumberGenerator,
    base_fanatic_prob: float,
    coherence_strength: float
) -> void:
    var magic_aff := int(axis_aff.get(AXIS_MAGIC, 0))
    if magic_aff > -50:
        return

    var corr := float(int(axis_aff.get(AXIS_CORRUPTION, 0))) / 100.0
    var divine := float(int(axis_aff.get(AXIS_DIVINE, 0))) / 100.0
    var nature := float(int(axis_aff.get(AXIS_NATURE, 0))) / 100.0

    # Plus l’anti-magie est fort, plus le style (prudence/fanatisme) s’affirme.
    var anti_magic_strength := clampf(float(-magic_aff - 50) / 50.0, 0.0, 1.0)

    # Probabilité fanatique (puriste) : augmente avec corruption/divin, diminue avec nature
    var p_fanatic :float = base_fanatic_prob \
        + 0.25 * anti_magic_strength \
        + 0.20 * max(0.0, corr) \
        + 0.15 * max(0.0, divine) \
        - 0.10 * max(0.0, nature)

    p_fanatic = clampf(p_fanatic, 0.10, 0.90)

    var style_strength := clampf(0.35 + 0.45 * anti_magic_strength, 0.0, 1.0) * clampf(coherence_strength, 0.0, 1.0)

    if rng.randf() < p_fanatic:
        # Puriste / fanatique anti-magie : agressif + rancune, peu diplomate
        _personality_add(personality, PERS_AGGRESSION, +0.15 * style_strength)
        _personality_add(personality, PERS_VENGEFULNESS, +0.20 * style_strength)
        _personality_add(personality, PERS_DIPLOMACY, -0.20 * style_strength)
        _personality_add(personality, PERS_INTEGRATIONISM, -0.10 * style_strength)
        _personality_add(personality, PERS_RISK_AVERSION, -0.05 * style_strength)
    else:
        # Prudente / “méfiance institutionnelle” : très risk_averse, plutôt diplomate
        _personality_add(personality, PERS_RISK_AVERSION, +0.20 * style_strength)
        _personality_add(personality, PERS_DIPLOMACY, +0.10 * style_strength)
        _personality_add(personality, PERS_AGGRESSION, -0.10 * style_strength)
        _personality_add(personality, PERS_VENGEFULNESS, -0.05 * style_strength)
        _personality_add(personality, PERS_EXPANSIONISM, -0.05 * style_strength)


static func _personality_add(personality: Dictionary, key: StringName, delta: float) -> void:
    var v := float(personality.get(key, 0.5))
    personality[key] = clampf(v + delta, 0.0, 1.0)

static func compute_baseline_relation(
    a: FactionProfile,
    b: FactionProfile,
    params: Dictionary = {}
) -> Dictionary:
    # ---- Tunables ----
    var w_axis_similarity: float = float(params.get("w_axis_similarity", 80.0))  # poids du "même axe"
    var w_cross_conflict: float = float(params.get("w_cross_conflict", 55.0))   # poids des conflits croisés
    var w_personality_bias: float = float(params.get("w_personality_bias", 25.0))

    # Cross-conflict weights (abs-products), tu peux en ajouter plus tard
    var w_tech_nature: float = float(params.get("w_tech_nature", 1.0))
    var w_divine_corruption: float = float(params.get("w_divine_corruption", 1.0))
    var w_magic_tech: float = float(params.get("w_magic_tech", 0.35)) # optionnel, plus léger

    # Friction tuning
    var friction_base: float = float(params.get("friction_base", 18.0))
    var friction_from_opposition: float = float(params.get("friction_from_opposition", 65.0))
    var friction_from_cross: float = float(params.get("friction_from_cross", 55.0))

    # Tension init tuning (tu peux la plafonner pour éviter guerres immédiates)
    var tension_cap: float = float(params.get("tension_cap", 40.0))

    # ---- Read profiles (normalized -1..+1) ----
    var aT := float(a.get_axis_affinity(AXIS_TECH)) / 100.0
    var aM := float(a.get_axis_affinity(AXIS_MAGIC)) / 100.0
    var aN := float(a.get_axis_affinity(AXIS_NATURE)) / 100.0
    var aD := float(a.get_axis_affinity(AXIS_DIVINE)) / 100.0
    var aC := float(a.get_axis_affinity(AXIS_CORRUPTION)) / 100.0

    var bT := float(b.get_axis_affinity(AXIS_TECH)) / 100.0
    var bM := float(b.get_axis_affinity(AXIS_MAGIC)) / 100.0
    var bN := float(b.get_axis_affinity(AXIS_NATURE)) / 100.0
    var bD := float(b.get_axis_affinity(AXIS_DIVINE)) / 100.0
    var bC := float(b.get_axis_affinity(AXIS_CORRUPTION)) / 100.0

    # ---- Axis similarity (dot / 5) in [-1..+1] ----
    var dot := (aT*bT + aM*bM + aN*bN + aD*bD + aC*bC)
    var similarity := dot / 5.0

    # Opposition measure in [0..~1] : somme des contributions "opposées"
    # (produit négatif => opposition)
    var opposition :float = (
        max(0.0, -(aT*bT)) +
        max(0.0, -(aM*bM)) +
        max(0.0, -(aN*bN)) +
        max(0.0, -(aD*bD)) +
        max(0.0, -(aC*bC))
    ) / 5.0

    # Cross-conflicts (abs-products) in [0..~1]
    var cross := 0.0
    cross += w_tech_nature * (abs(aT) * abs(bN) + abs(aN) * abs(bT)) / 2.0
    cross += w_divine_corruption * (abs(aD) * abs(bC) + abs(aC) * abs(bD)) / 2.0
    cross += w_magic_tech * (abs(aM) * abs(bT) + abs(aT) * abs(bM)) / 2.0
    cross = clampf(cross, 0.0, 1.0)

    # ---- Personality filters (directional: A's worldview) ----
    var aggr := a.get_personality(PERS_AGGRESSION, 0.5)
    var veng := a.get_personality(PERS_VENGEFULNESS, 0.5)
    var diplo := a.get_personality(PERS_DIPLOMACY, 0.5)
    var risk := a.get_personality(PERS_RISK_AVERSION, 0.5)
    var expa := a.get_personality(PERS_EXPANSIONISM, 0.5)
    var integ := a.get_personality(PERS_INTEGRATIONISM, 0.5)

    # "Ideological intensity" : plus A est extrême, plus il juge fort (positif ou négatif)
    var intensity :float = (abs(aT) + abs(aM) + abs(aN) + abs(aD) + abs(aC)) / 5.0  # 0..1
    var judgment_gain := clampf(0.65 + 0.7*intensity + 0.2*veng - 0.25*diplo, 0.5, 1.6)

    # Relation bias: diplomatie et intégration rendent plus "ouvert" par défaut,
    # aggression + vengeance rendent plus dur, expansionism rend suspicieux si l'autre est incompatible.
    var pers_bias :=(+0.65*(diplo - 0.5)) + (+0.45*(integ - 0.5)) + (-0.55*(aggr - 0.5)) + (-0.45*(veng - 0.5)) + (-0.25*(expa - 0.5))

    # ---- Baseline relation (A -> B) ----
    # similarity pousse + ; cross + opposition poussent - ; personnalité ajuste le ton.
    var rel_f := 0.0
    rel_f += (similarity * w_axis_similarity) * judgment_gain
    rel_f -= (cross * w_cross_conflict) * judgment_gain
    rel_f += pers_bias * w_personality_bias

    var relation := clampi(int(round(rel_f)), -100, 100)

    # ---- Friction (volatilité / risque d'incident) ----
    # friction augmente avec opposition + cross-conflicts, puis est multipliée par le tempérament de A.
    var fr := friction_base
    fr += opposition * friction_from_opposition * judgment_gain
    fr += cross * friction_from_cross * judgment_gain

    # tempérament : aggression/vengefulness augmentent, diplomacy/risk_aversion diminuent
    var fr_mul := 1.0 \
        + 0.50*(aggr - 0.5) \
        + 0.45*(veng - 0.5) \
        - 0.40*(diplo - 0.5) \
        - 0.25*(risk - 0.5)

    fr = clampf(fr * clampf(fr_mul, 0.55, 1.65), 0.0, 100.0)

    # ---- Optional: init trust & tension (useful to init FactionRelationScore) ----
    # Trust suit la relation, mais est pénalisée par rancune/agressivité.
    var trust_f := 0.65*float(relation) + 18.0*(diplo - 0.5) - 14.0*(veng - 0.5) - 10.0*(aggr - 0.5)
    var trust := clampi(int(round(trust_f)), -100, 100)

    # Tension est une “partie” de la friction + négativité de relation, plafonnée (évite guerres day 1)
    var tension := clampf(0.35*fr + 0.20*max(0.0, -float(relation)), 0.0, tension_cap)

    return {
        "relation": relation,  # -100..100 (A -> B)
        "friction": fr,        # 0..100 (A -> B)
        "trust": trust,        # -100..100 (A -> B)
        "tension": tension     # 0..tension_cap
    }
