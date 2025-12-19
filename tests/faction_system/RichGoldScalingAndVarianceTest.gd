extends Node
class_name RichGoldScalingAndVarianceTest

func _ready() -> void:
    _test_rich_gold_scales_with_tier_and_variance_is_controlled()
    print("\n✅ RichGoldScalingAndVarianceTest: OK\n")
    get_tree().quit()

func _test_rich_gold_scales_with_tier_and_variance_is_controlled() -> void:
    _assert(ClassDB.class_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

    var econ_rich := {
        "wealth_level": &"RICH",
        "liquidity": 0.90,
        "prestige": 0.80
    }

    var action := &"arc.raid"
    var n := 120

    var s2 := _gold_stats_for_tier(econ_rich, 2, action, n, 33002)
    var s3 := _gold_stats_for_tier(econ_rich, 3, action, n, 33003)
    var s4 := _gold_stats_for_tier(econ_rich, 4, action, n, 33004)
    var s5 := _gold_stats_for_tier(econ_rich, 5, action, n, 33005)

    # 1) scaling
    _assert(s5.mean > s2.mean + 25.0, "avg gold should increase with tier (t2=%.1f t5=%.1f)" % [s2.mean, s5.mean])
    _assert(s5.mean > s4.mean, "avg gold should be increasing (t4=%.1f t5=%.1f)" % [s4.mean, s5.mean])

    # 2) variance control via coefficient of variation
    # (0.6 is generous; if you want tighter economy, drop to 0.4)
    _assert(s2.cv < 0.6, "tier2 gold CV too high: %.3f (mean=%.1f std=%.1f)" % [s2.cv, s2.mean, s2.std])
    _assert(s3.cv < 0.6, "tier3 gold CV too high: %.3f (mean=%.1f std=%.1f)" % [s3.cv, s3.mean, s3.std])
    _assert(s4.cv < 0.6, "tier4 gold CV too high: %.3f (mean=%.1f std=%.1f)" % [s4.cv, s4.mean, s4.std])
    _assert(s5.cv < 0.6, "tier5 gold CV too high: %.3f (mean=%.1f std=%.1f)" % [s5.cv, s5.mean, s5.std])

    # 3) sanity bounds (avoid runaway inflation)
    # base_gold approx: tier2 ~34, tier5 ~84, rich mult ~1.3, plus selection probability.
    # We'll just enforce "not absurd"
    _assert(s2.mean >= 15.0 and s2.mean <= 80.0, "tier2 mean gold out of bounds (%.1f)" % s2.mean)
    _assert(s5.mean >= 35.0 and s5.mean <= 160.0, "tier5 mean gold out of bounds (%.1f)" % s5.mean)


class Stats:
    var mean: float
    var std: float
    var cv: float
    func _init(m: float, s: float) -> void:
        mean = m
        std = s
        cv = (s / m) if m > 0.0001 else 999.0


func _gold_stats_for_tier(econ: Dictionary, tier: int, action: StringName, n: int, seed: int) -> Stats:
    var rng := RandomNumberGenerator.new()
    rng.seed = seed

    var xs: Array[float] = []
    xs.resize(0)

    for i in range(n):
        var b := RewardEconomyUtil.build_reward_bundle(econ, tier, action, rng)
        var g := float(int(b.get("gold", 0)))
        # For rich test, we include 0 gold outcomes too: it’s part of the "style".
        xs.append(g)

    var m := _mean(xs)
    var s := _std(xs, m)
    return Stats.new(m, s)


func _mean(xs: Array[float]) -> float:
    if xs.is_empty(): return 0.0
    var sum := 0.0
    for x in xs: sum += x
    return sum / float(xs.size())


func _std(xs: Array[float], mean: float) -> float:
    if xs.size() <= 1: return 0.0
    var acc := 0.0
    for x in xs:
        var d := x - mean
        acc += d * d
    return sqrt(acc / float(xs.size() - 1))


func _assert(cond: bool, msg: String) -> void:
    if not cond:
        push_error("TEST FAIL: " + msg)
        assert(false)
