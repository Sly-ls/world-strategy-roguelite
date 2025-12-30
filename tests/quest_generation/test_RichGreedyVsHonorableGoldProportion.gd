extends BaseTest
class_name RichGreedyVsHonorableGoldProportionTest

func _ready() -> void:
    _test_rich_greedy_has_higher_gold_proportion_than_honorable()
    pass_test("✅ RichGreedyVsHonorableGoldProportionTest: OK")

func _test_rich_greedy_has_higher_gold_proportion_than_honorable() -> void:
    _assert(RewardEconomyUtilRunner != null, "RewardEconomyUtil must exist")

    var econ_rich := {"wealth_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}
    var tier := 3
    var action := &"arc.truce_talks"
    var n := 200

    var prof_greedy := FactionProfile.new({FactionProfile.PERS_GREED: 0.95, FactionProfile.PERS_OPPORTUNISM: 0.85, FactionProfile.PERS_DISCIPLINE: 0.30, FactionProfile.PERS_HONOR: 0.25})
    var prof_honorable := FactionProfile.new({FactionProfile.PERS_GREED: 0.10, FactionProfile.PERS_OPPORTUNISM: 0.20, FactionProfile.PERS_DISCIPLINE: 0.85, FactionProfile.PERS_HONOR: 0.90})

    # sanity: dw signs
    var s_g := RewardEconomyUtilRunner.compute_reward_style(econ_rich, tier, prof_greedy)
    var s_h := RewardEconomyUtilRunner.compute_reward_style(econ_rich, tier, prof_honorable)
    _assert(float(s_g.w_gold_dw) > 0.03, "expected greedy w_gold_dw positive (got %.3f)" % float(s_g.w_gold_dw))
    _assert(float(s_h.w_gold_dw) < -0.03, "expected honorable w_gold_dw negative (got %.3f)" % float(s_h.w_gold_dw))

    var rng := RandomNumberGenerator.new()
    rng.seed = 90901

    var greedy_gold := 0
    var greedy_non := 0

    for i in range(n):
        var b := RewardEconomyUtilRunner.build_reward_bundle(econ_rich, tier, action, rng, prof_greedy)
        if int(b.get("gold", 0)) > 0:
            greedy_gold += 1
        else:
            greedy_non += 1

    # reset rng for fair comparison (same sequence shape)
    rng.seed = 90901

    var hon_gold := 0
    var hon_non := 0

    for i in range(n):
        var b := RewardEconomyUtilRunner.build_reward_bundle(econ_rich, tier, action, rng, prof_honorable)
        if int(b.get("gold", 0)) > 0:
            hon_gold += 1
        else:
            hon_non += 1

    var p_g := float(greedy_gold) / float(n)
    var p_h := float(hon_gold) / float(n)

    # RICH must stay mostly gold for both (guard rail)
    _assert(p_g >= 0.60, "RICH greedy should still be mostly gold (p=%.2f)" % p_g)
    _assert(p_h >= 0.60, "RICH honorable should still be mostly gold (p=%.2f)" % p_h)

    # greedy significantly higher than honorable
    _assert(p_g >= p_h + 0.08, "expected greedy gold proportion higher (greedy=%.2f honorable=%.2f)" % [p_g, p_h])

    # optional: print-ish debug in log
    myLogger.debug("RICH gold proportions: greedy=%.2f honorable=%.2f (n=%d)" % [p_g, p_h, n], LogTypes.Domain.TEST)
