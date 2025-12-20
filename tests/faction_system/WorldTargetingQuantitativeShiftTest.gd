extends BaseTest
class_name WorldTargetingQuantitativeShiftTest

var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.seed = 77777

    _test_enemy_score_decreases_for_B_between_day10_and_day30()

    print("\n✅ WorldTargetingQuantitativeShiftTest: OK\n")


func _test_enemy_score_decreases_for_B_between_day10_and_day30() -> void:
    var nb := ArcNotebook.new()
    var self_id := &"A"
    var b := &"B"
    var c := &"C"

    var ctx := FactionWorldContext.new()
    ctx.faction_id = self_id
    ctx.fatigue = 0.20

    var arc_b := {
        "other_id": b,
        "pair_key": &"A|B",
        "state": &"RIVALRY",
        "rel_mean": -70.0,
        "trust_mean": 20.0,
        "tension_mean": 70.0,
        "griev_mean": 60.0,
        "wear_mean": 20.0
    }
    var arc_c := {
        "other_id": c,
        "pair_key": &"A|C",
        "state": &"RIVALRY",
        "rel_mean": -50.0,
        "trust_mean": 30.0,
        "tension_mean": 55.0,
        "griev_mean": 40.0,
        "wear_mean": 10.0
    }
    ctx.arcs = [arc_b, arc_c]

    # Simule 30 jours d'events
    for day in range(1, 31):
        ctx.day = day

        # B raid A (3 fois)
        if day == 2 or day == 4 or day == 6:
            nb.record_pair_event(b, self_id, ArcDecisionUtil.ARC_RAID, day)

        # B réparations (2 fois) en fin de période
        if day == 25 or day == 27:
            nb.record_pair_event(b, self_id, ArcDecisionUtil.ARC_REPARATIONS, day)

    # --- Snapshot J10 (B encore en rivalité hostile) ---
    ctx.day = 10
    var res10 := WorldTargeting.compute_priority_targets(ctx, nb, self_id)
    var b_enemy_10 :int = _score_for_id(res10["enemy_rank"], b)
    var b_ally_10 :int = _score_for_id(res10["ally_rank"], b)

    _assert(b_enemy_10 != null, "day10: B must appear in enemy_rank")
    _assert(b_ally_10 != null, "day10: B must appear in ally_rank")

    # --- Snapshot J30 : on inverse la situation courante (B devient partenaire de trêve) ---
    ctx.day = 30
    arc_b["state"] = &"TRUCE"
    arc_b["rel_mean"] = 45.0
    arc_b["trust_mean"] = 70.0
    arc_b["tension_mean"] = 15.0
    arc_b["griev_mean"] = 10.0
    arc_b["wear_mean"] = 25.0

    # C reste hostile
    arc_c["state"] = &"RIVALRY"
    arc_c["rel_mean"] = -55.0
    arc_c["trust_mean"] = 25.0
    arc_c["tension_mean"] = 60.0
    arc_c["griev_mean"] = 45.0
    arc_c["wear_mean"] = 12.0

    var res30 := WorldTargeting.compute_priority_targets(ctx, nb, self_id)
    var b_enemy_30 :int = _score_for_id(res30["enemy_rank"], b)
    var b_ally_30 :int = _score_for_id(res30["ally_rank"], b)

    _assert(b_enemy_30 != null, "day30: B must appear in enemy_rank")
    _assert(b_ally_30 != null, "day30: B must appear in ally_rank")

    # --- Assertions quantitatives ---
    # 1) Le score ennemi de B doit baisser nettement
    var e10 := float(b_enemy_10)
    var e30 := float(b_enemy_30)

    _assert(e30 < e10 - 0.35, "enemy_score(B) should drop by at least 0.35 (got %.3f -> %.3f)" % [e10, e30])
    _assert(e30 < e10 * 0.70, "enemy_score(B) should drop by at least 30%% (got %.3f -> %.3f)" % [e10, e30])

    # 2) (Bonus) Le score allié de B doit augmenter nettement
    var a10 := float(b_ally_10)
    var a30 := float(b_ally_30)

    _assert(a30 > a10 + 0.25, "ally_score(B) should rise by at least 0.25 (got %.3f -> %.3f)" % [a10, a30])


func _score_for_id(rank: Array, id: StringName):
    for item in rank:
        if StringName(item.get("id", &"")) == id:
            return item.get("score", null)
    return null
