extends BaseTest
class_name WGoldPersonalityClampedTest

func _ready() -> void:
    _test_w_gold_depends_on_personality_but_is_clamped_by_economy()
    pass_test("\n✅ WGoldPersonalityClampedTest: OK\n")

func _test_w_gold_depends_on_personality_but_is_clamped_by_economy() -> void:
    # CORRECTION: ClassDB.class_exists ne fonctionne PAS pour les classes GDScript
    # Il ne fonctionne que pour les classes C++ natives de Godot.
    # Solution: vérifier directement si on peut utiliser la classe
    
    # On vérifie simplement que RewardEconomyUtil est accessible (via son script)
    # Si le script n'existe pas ou ne compile pas, le test échouera de toute façon
    
    var tier := 3

    var econ_poor := {"wealth_level": &"POOR", "liquidity": 0.20, "prestige": 0.40}
    var econ_rich := {"wealth_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}

    var prof_greedy: FactionProfile = FactionProfile.new({FactionProfile.PERS_GREED: 0.95, FactionProfile.PERS_OPPORTUNISM: 0.85, FactionProfile.PERS_DISCIPLINE: 0.30, FactionProfile.PERS_HONOR: 0.25})
    var prof_honorable: FactionProfile = FactionProfile.new({FactionProfile.PERS_GREED: 0.15, FactionProfile.PERS_OPPORTUNISM: 0.20, FactionProfile.PERS_DISCIPLINE: 0.85, FactionProfile.PERS_HONOR: 0.85})
    
    # Ces appels échoueront automatiquement si RewardEconomyUtil n'existe pas
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
