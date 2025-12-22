extends BaseTest
class_name EconomyRewardStyleStatTest

func _ready() -> void:
    _test_poor_vs_rich_reward_distribution_and_opportunism_heat()
    pass_test("\n✅ EconomyRewardStyleStatTest: OK\n")

func _test_poor_vs_rich_reward_distribution_and_opportunism_heat() -> void:
    _assert(RewardEconomyUtilRunner != null, "RewardEconomyUtil must exist")
    var rng := RandomNumberGenerator.new()
    rng.seed = 13371337 # déterministe

    var tier := 3
    var action := &"arc.truce_talks"

    var econ_poor := {
        "wealth_level": &"POOR",
        "liquidity": 0.20,
        "prestige": 0.45
    }
    var econ_rich := {
        "wealth_level": &"RICH",
        "liquidity": 0.85,
        "prestige": 0.75
    }

    var poor_gold := 0
    var poor_non := 0
    var poor_heat_sum := 0.0

    for i in range(50):
        var b := RewardEconomyUtil.build_reward_bundle(econ_poor, tier, action, rng)
        poor_heat_sum += float(b.get("opportunism_heat", 0.0))
        if int(b.get("gold", 0)) > 0:
            poor_gold += 1
        elif RewardEconomyUtil.is_non_gold(b):
            poor_non += 1

    var rich_gold := 0
    var rich_non := 0
    var rich_heat_sum := 0.0

    for i in range(50):
        var b := RewardEconomyUtil.build_reward_bundle(econ_rich, tier, action, rng)
        rich_heat_sum += float(b.get("opportunism_heat", 0.0))
        if int(b.get("gold", 0)) > 0:
            rich_gold += 1
        elif RewardEconomyUtil.is_non_gold(b):
            rich_non += 1

    var poor_heat_avg := poor_heat_sum / 50.0
    var rich_heat_avg := rich_heat_sum / 50.0

    # --- asserts “statistiques” robustes ---
    # Poor: très majoritairement non-gold
    _assert(poor_non >= 32, "POOR should generate mostly non-gold (expected >=32/50, got %d) | gold=%d" % [poor_non, poor_gold])

    # Rich: très majoritairement gold
    _assert(rich_gold >= 32, "RICH should generate mostly gold (expected >=32/50, got %d) | non_gold=%d" % [rich_gold, rich_non])

    # Opportunism heat: rich >> poor
    _assert(rich_heat_avg > poor_heat_avg + 0.25,
        "opportunism_heat should be much higher for RICH (poor=%.3f rich=%.3f)" % [poor_heat_avg, rich_heat_avg])

    # sanity: heat ranges
    _assert(poor_heat_avg >= 0.0 and poor_heat_avg <= 1.0, "poor heat avg out of range")
    _assert(rich_heat_avg >= 0.0 and rich_heat_avg <= 1.0, "rich heat avg out of range")
