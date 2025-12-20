extends BaseTest
class_name RichGreedyVsHonorableGoldProportionTest

func _ready() -> void:
    _test_rich_greedy_has_higher_gold_proportion_than_honorable()
    print("\n✅ RichGreedyVsHonorableGoldProportionTest: OK\n")

func _test_rich_greedy_has_higher_gold_proportion_than_honorable() -> void:
    _assert(ClassDB.class_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

    var econ_rich := {"wealth_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}
    var tier := 3
    var action := &"arc.truce_talks"
    var n := 200

    var param_greedy := {"personality": {&"greed": 0.95, &"opportunism": 0.85, &"discipline": 0.30, &"honor": 0.25}}
    var param_honorable := {"personality": {&"greed": 0.10, &"opportunism": 0.20, &"discipline": 0.85, &"honor": 0.90}}

    var prof_greedy :FactionProfile = FactionProfile.new()
    prof_greedy.apply_personality_template(param_greedy)
    var prof_honorable :FactionProfile = FactionProfile.new()
    prof_honorable.apply_personality_template(param_honorable)
    # sanity: dw signs
    var s_g := RewardEconomyUtil.compute_reward_style(econ_rich, tier, prof_greedy)
    var s_h := RewardEconomyUtil.compute_reward_style(econ_rich, tier, prof_honorable)
    _assert(float(s_g.w_gold_dw) > 0.03, "expected greedy w_gold_dw positive (got %.3f)" % float(s_g.w_gold_dw))
    _assert(float(s_h.w_gold_dw) < -0.03, "expected honorable w_gold_dw negative (got %.3f)" % float(s_h.w_gold_dw))

    var rng := RandomNumberGenerator.new()
    rng.seed = 90901

    var greedy_gold := 0
    var greedy_non := 0

    for i in range(n):
        var b := RewardEconomyUtil.build_reward_bundle(econ_rich, tier, action, rng, prof_greedy)
        if int(b.get("gold", 0)) > 0:
            greedy_gold += 1
        else:
            greedy_non += 1

    # reset rng for fair comparison (same sequence shape)
    rng.seed = 90901

    var hon_gold := 0
    var hon_non := 0

    for i in range(n):
        var b := RewardEconomyUtil.build_reward_bundle(econ_rich, tier, action, rng, prof_honorable)
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
    print("RICH gold proportions: greedy=%.2f honorable=%.2f (n=%d)" % [p_g, p_h, n])
