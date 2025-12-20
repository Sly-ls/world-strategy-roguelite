extends BaseTest
class_name PoorNonGoldValueCoherenceTest

func _ready() -> void:
    _test_poor_non_gold_value_scales_with_tier_but_is_bounded()
    pass_test("\n✅ PoorNonGoldValueCoherenceTest: OK\n")

func _test_poor_non_gold_value_scales_with_tier_but_is_bounded() -> void:
    _assert(ClassDB.class_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

    var econ_poor := {
        "wealth_level": &"POOR",
        "liquidity": 0.18,
        "prestige": 0.50
    }

    var action := &"arc.truce_talks"
    var n := 80 # plus stable que 50, toujours rapide

    var avg2 := _avg_value_for_tier(econ_poor, 2, action, n, 20201)
    var avg3 := _avg_value_for_tier(econ_poor, 3, action, n, 20202)
    var avg4 := _avg_value_for_tier(econ_poor, 4, action, n, 20203)
    var avg5 := _avg_value_for_tier(econ_poor, 5, action, n, 20204)

    # 1) Croissance cohérente (pas forcément strictement monotone à 1e-6, mais tendance nette)
    _assert(avg5 > avg2 + 8.0, "expected avg non-gold value to increase with tier (avg2=%.1f avg5=%.1f)" % [avg2, avg5])

    # 2) Bornes anti “pauvre trop généreux”
    _assert(avg2 >= 10.0 and avg2 <= 55.0, "tier2 avg out of bounds (%.1f) expected [10..55]" % avg2)
    _assert(avg3 >= 15.0 and avg3 <= 65.0, "tier3 avg out of bounds (%.1f) expected [15..65]" % avg3)
    _assert(avg4 >= 20.0 and avg4 <= 80.0, "tier4 avg out of bounds (%.1f) expected [20..80]" % avg4)
    _assert(avg5 >= 25.0 and avg5 <= 95.0, "tier5 avg out of bounds (%.1f) expected [25..95]" % avg5)


func _avg_value_for_tier(econ: Dictionary, tier: int, action: StringName, n: int, seed: int) -> float:
    var rng := RandomNumberGenerator.new()
    rng.seed = seed

    var total := 0.0
    var count := 0

    for i in range(n):
        var b := RewardEconomyUtil.build_reward_bundle(econ, tier, action, rng)

        # On mesure seulement le mode non-gold (c’est ce qu’on veut contrôler chez POOR)
        if int(b.get("gold", 0)) > 0:
            continue

        var v := _value_proxy(b)
        total += v
        count += 1

    # si jamais trop de gold (devrait être rare en POOR), on sécurise
    if count == 0:
        return 0.0
    return total / float(count)


func _value_proxy(bundle: Dictionary) -> float:
    var v := 0.0

    # influence
    v += float(int(bundle.get("influence", 0))) * 1.0

    # favor debt: très puissant narrativement
    v += float(int(bundle.get("favor_debt", 0))) * 20.0

    # clauses
    var clauses: Array = bundle.get("treaty_clauses", [])
    for c in clauses:
        if String(c) == "OPEN_TRADE":
            v += 12.0
        else:
            v += 10.0

    # access
    var access: Array = bundle.get("access", [])
    v += float(access.size()) * 8.0

    # intel
    var intel: Array = bundle.get("intel_tags", [])
    v += float(intel.size()) * 6.0

    # artifact: rare mais énorme
    if String(bundle.get("artifact_id", "")) != "":
        v += 60.0

    return v
