extends BaseTest
class_name TestFactionProfileGeneration

const N_PER_MODE := 100
const GOLDEN_COUNT := 10
const GOLDEN_PATH := "user://golden_faction_profiles.json"

var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.seed = 1337 # reproductible

    _run_mode(FactionProfile.GEN_CENTERED)
    _run_mode(FactionProfile.GEN_NORMAL)
    _run_mode(FactionProfile.GEN_DRAMATIC)

    print("\n✅ FactionProfile generation tests: OK\n")


func _run_mode(mode: StringName) -> void:
    print("\n--- Testing mode: ", String(mode), " ---")

    var profiles: Array[FactionProfile] = []
    for i in range(N_PER_MODE):
        var p := FactionProfile.generate_full_profile(rng, mode)
        _validate_profile(p, mode, i)
        profiles.append(p)

    # Golden profiles (diversité) — on les garde une fois (normal) ou par mode (au choix).
    # Ici: on sauvegarde un set global à partir du mode NORMAL (souvent le plus stable pour fixtures).
    if mode == FactionProfile.GEN_NORMAL:
        var golden := _pick_diverse_profiles(profiles, GOLDEN_COUNT)
        _save_golden(golden, mode)


func _validate_profile(p: FactionProfile, mode: StringName, idx: int) -> void:
    _assert(p != null, "Profile is null (idx=%d, mode=%s)" % [idx, mode])

    _validate_axes(p.axis_affinity, mode, idx)
    _validate_personality(p.personality, mode, idx)


func _validate_axes(axis: Dictionary, mode: StringName, idx: int) -> void:
    # 5 axes présents, bornes, règles (pos>50, neg<-20), somme, distribution intéressante
    for a in FactionProfile.ALL_AXES:
        _assert(axis.has(a), "Missing axis '%s' (idx=%d, mode=%s)" % [a, idx, mode])
        var v := int(axis[a])
        _assert(v >= -100 and v <= 100, "Axis out of range %s=%d (idx=%d, mode=%s)" % [a, v, idx, mode])

    var has_pos := false
    var has_neg := false
    var sum := 0
    var interesting := 0

    var interesting_abs := 12
    var min_interesting := 3
    var sum_min := 20
    var sum_max := 90

    match mode:
        FactionProfile.GEN_CENTERED:
            interesting_abs = 10
            min_interesting = 4
            sum_min = 20
            sum_max = 75
        FactionProfile.GEN_DRAMATIC:
            interesting_abs = 15
            min_interesting = 3
            sum_min = 20
            sum_max = 90
        _:
            # normal
            interesting_abs = 12
            min_interesting = 3
            sum_min = 20
            sum_max = 90

    for a in FactionProfile.ALL_AXES:
        var v := int(axis[a])
        sum += v
        if v > 50:
            has_pos = true
        if v < -20:
            has_neg = true
        if abs(v) >= interesting_abs:
            interesting += 1

    _assert(has_pos, "No axis > 50 (idx=%d, mode=%s) axis=%s" % [idx, mode, str(axis)])
    _assert(has_neg, "No axis < -20 (idx=%d, mode=%s) axis=%s" % [idx, mode, str(axis)])
    _assert(sum >= sum_min and sum <= sum_max,
        "Axis sum out of range sum=%d expected=[%d..%d] (idx=%d, mode=%s) axis=%s"
        % [sum, sum_min, sum_max, idx, mode, str(axis)])
    _assert(interesting >= min_interesting,
        "Axis distribution too flat interesting=%d (<%d), abs>=%d (idx=%d, mode=%s) axis=%s"
        % [interesting, min_interesting, interesting_abs, idx, mode, str(axis)])


func _validate_personality(per: Dictionary, mode: StringName, idx: int) -> void:
    # clés, bornes 0..1, + “interestingness” (au moins un high et un low)
    var require_high := 0.75
    var require_low := 0.35
    match mode:
        FactionProfile.GEN_CENTERED:
            require_high = 0.70
            require_low = 0.40
        FactionProfile.GEN_DRAMATIC:
            require_high = 0.80
            require_low = 0.30
        _:
            require_high = 0.75
            require_low = 0.35

    var hi := 0
    var lo := 0

    for k in FactionProfile.ALL_PERSONALITY_KEYS:
        _assert(per.has(k), "Missing personality key '%s' (idx=%d, mode=%s)" % [k, idx, mode])
        var v := float(per[k])
        _assert(v >= 0.0 and v <= 1.0, "Personality out of range %s=%f (idx=%d, mode=%s)" % [k, v, idx, mode])
        if v >= require_high:
            hi += 1
        if v <= require_low:
            lo += 1

    _assert(hi >= 1, "Personality not distinctive: no trait >= %.2f (idx=%d, mode=%s) per=%s" % [require_high, idx, mode, str(per)])
    _assert(lo >= 1, "Personality not distinctive: no trait <= %.2f (idx=%d, mode=%s) per=%s" % [require_low, idx, mode, str(per)])


# -----------------------
# Golden profiles (diversité)
# -----------------------

func _pick_diverse_profiles(profiles: Array, k: int) -> Array:
    if profiles.is_empty():
        return []

    # Greedy farthest-point sampling
    var chosen: Array = []
    chosen.append(profiles[rng.randi_range(0, profiles.size() - 1)])

    while chosen.size() < k and chosen.size() < profiles.size():
        var best_p: FactionProfile = null
        var best_score := -INF

        for p in profiles:
            if chosen.has(p):
                continue
            var min_d := INF
            for c in chosen:
                min_d = min(min_d, _profile_distance(p, c))
            if min_d > best_score:
                best_score = min_d
                best_p = p

        if best_p == null:
            break
        chosen.append(best_p)

    return chosen


func _profile_distance(a: FactionProfile, b: FactionProfile) -> float:
    # Axes: [-1..1], Personality: centered around 0.5 then scaled
    var s := 0.0

    for ax in FactionProfile.ALL_AXES:
        var da := float(a.axis_affinity[ax]) / 100.0
        var db := float(b.axis_affinity[ax]) / 100.0
        var d := da - db
        s += 1.0 * d * d

    for k in FactionProfile.ALL_PERSONALITY_KEYS:
        var pa := (float(a.personality[k]) - 0.5) * 2.0 # [-1..1]
        var pb := (float(b.personality[k]) - 0.5) * 2.0
        var d2 := pa - pb
        s += 0.6 * d2 * d2

    return sqrt(s)


func _save_golden(golden: Array, mode: StringName) -> void:
    var arr := []
    for p in golden:
        arr.append(_to_json_dict(p))

    var payload := {
        "seed": 1337,
        "mode": String(mode),
        "generated_at_day": 0,
        "profiles": arr
    }

    var json := JSON.stringify(payload, "\t")
    var f := FileAccess.open(GOLDEN_PATH, FileAccess.WRITE)
    _assert(f != null, "Cannot open %s for writing" % GOLDEN_PATH)
    f.store_string(json)
    f.close()

    print("\n⭐ Saved ", golden.size(), " golden profiles to: ", GOLDEN_PATH)
    print("   (Tu peux les recharger ensuite pour tes tests de quêtes/arcs.)")


func _to_json_dict(p: FactionProfile) -> Dictionary:
    var axis := {}
    for ax in FactionProfile.ALL_AXES:
        axis[String(ax)] = int(p.axis_affinity[ax])

    var per := {}
    for k in FactionProfile.ALL_PERSONALITY_KEYS:
        per[String(k)] = float(p.personality[k])

    return {"axis_affinity": axis, "personality": per}
