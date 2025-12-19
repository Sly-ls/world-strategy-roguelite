# tests/WGoldPersonalityClampedTest.gd
extends BaseTest
class_name WGoldPersonalityClampedTest

func _ready() -> void:
    _test_w_gold_depends_on_personality_but_is_clamped_by_economy()
    print("\n✅ WGoldPersonalityClampedTest: OK\n")
    get_tree().quit()

func _test_w_gold_depends_on_personality_but_is_clamped_by_economy() -> void:
    assert_true(ClassDB.class_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

    var tier := 3

    var econ_poor := {"wealth_level": &"POOR", "liquidity": 0.20, "prestige": 0.40}
    var econ_rich := {"wealth_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}

    var param_greedy := {"personality": {&"greed": 0.95, &"opportunism": 0.85, &"discipline": 0.30, &"honor": 0.25}}
    var param_honorable := {"personality": {&"greed": 0.15, &"opportunism": 0.20, &"discipline": 0.85, &"honor": 0.85}}

    var prof_greedy :FactionProfile = FactionProfile.new()
    prof_greedy.apply_personality_template(param_greedy)
    var prof_honorable :FactionProfile = FactionProfile.new()
    prof_honorable.apply_personality_template(param_honorable)
    
    var s_poor_g := RewardEconomyUtil.compute_reward_style(econ_poor, tier, prof_greedy)
    var s_poor_h := RewardEconomyUtil.compute_reward_style(econ_poor, tier, prof_honorable)
    var s_rich_g := RewardEconomyUtil.compute_reward_style(econ_rich, tier, prof_greedy)
    var s_rich_h := RewardEconomyUtil.compute_reward_style(econ_rich, tier, prof_honorable)

    assert_true(float(s_poor_g.w_gold) <= 0.35, "POOR greedy w_gold must be clamped <= 0.35 (got %.3f)" % float(s_poor_g.w_gold))
    assert_true(float(s_poor_h.w_gold) <= 0.35, "POOR honorable w_gold must be clamped <= 0.35 (got %.3f)" % float(s_poor_h.w_gold))

    assert_true(float(s_rich_g.w_gold) >= 0.60, "RICH greedy w_gold must be clamped >= 0.60 (got %.3f)" % float(s_rich_g.w_gold))
    assert_true(float(s_rich_h.w_gold) >= 0.60, "RICH honorable w_gold must be clamped >= 0.60 (got %.3f)" % float(s_rich_h.w_gold))

    # personality effect visible (within rails)
    assert_true(float(s_rich_g.w_gold) > float(s_rich_h.w_gold) + 0.05, "greedy should have higher w_gold than honorable in RICH")
