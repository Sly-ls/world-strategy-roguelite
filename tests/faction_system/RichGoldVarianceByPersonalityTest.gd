extends BaseTest
class_name RichGoldVarianceByPersonalityTest

func _ready() -> void:
    _test_rich_gold_variance_depends_on_personality_but_stays_bounded()
    pass_test("\n✅ RichGoldVarianceByPersonalityTest: OK\n")

func _test_rich_gold_variance_depends_on_personality_but_stays_bounded() -> void:
    _assert(ClassDB.class_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

    var econ_rich := {"wealth_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}
    var tier := 4
    var action := &"arc.raid"
    var n := 220

    # “greedy/chaotic” => variance ↑
    var prof_chaos := {"personality": {&"opportunism": 0.90, &"aggression": 0.80, &"discipline": 0.20, &"honor": 0.20}}
    # “bureaucratic” => variance ↓
    var prof_bureau := {"personality": {&"opportunism": 0.20, &"aggression": 0.20, &"discipline": 0.90, &"honor": 0.70}}

    var s_chaos := _gold_stats_positive_only(econ_rich, tier, action, n, 77111, prof_chaos)
    var s_buro  := _gold_stats_positive_only(econ_rich, tier, action, n, 77112, prof_bureau)

    # variance chaotique > bureaucratique
    _assert(s_chaos.cv > s_buro.cv + 0.05,
        "expected higher CV for chaotic profile (chaos=%.3f buro=%.3f)" % [s_chaos.cv, s_buro.cv])

    # bornes “inflation contrôlée”
    _assert(s_chaos.cv < 0.25, "chaos CV too high: %.3f (mean=%.1f std=%.1f)" % [s_chaos.cv, s_chaos.mean, s_chaos.std])
    _assert(s_buro.cv  < 0.15, "buro CV too high: %.3f (mean=%.1f std=%.1f)" % [s_buro.cv, s_buro.mean, s_buro.std])

    # moyenne quasi inchangée (bruit symétrique)
    _assert(abs(s_chaos.mean - s_buro.mean) / max(1.0, s_buro.mean) < 0.12,
        "mean should stay roughly stable across personalities (chaos=%.1f buro=%.1f)" % [s_chaos.mean, s_buro.mean])


class Stats:
    var mean: float
    var std: float
    var cv: float
    func _init(m: float, s: float) -> void:
        mean = m
        std = s
        cv = (s / m) if m > 0.0001 else 999.0


func _gold_stats_positive_only(econ: Dictionary, tier: int, action: StringName, n: int, seed: int, profile) -> Stats:
    var rng := RandomNumberGenerator.new()
    rng.seed = seed

    var xs: Array[float] = []
    for i in range(n):
        var b := RewardEconomyUtil.build_reward_bundle(econ, tier, action, rng, profile)
        var g := float(int(b.get("gold", 0)))
        if g > 0.0:
            xs.append(g)

    _assert(xs.size() >= int(0.5 * n), "too few gold samples; check w_gold for rich (got %d/%d)" % [xs.size(), n])

    var m := _mean(xs)
    var s := _std(xs, m)
    return Stats.new(m, s)


func _mean(xs: Array[float]) -> float:
    var sum := 0.0
    for x in xs: sum += x
    return sum / float(xs.size())

func _std(xs: Array[float], mean: float) -> float:
    var acc := 0.0
    for x in xs:
        var d := x - mean
        acc += d * d
    return sqrt(acc / float(xs.size() - 1))
