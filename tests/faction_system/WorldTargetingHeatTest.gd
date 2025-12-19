extends Node
class_name WorldTargetingHeatTest

var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.seed = 424242

    _test_priority_targets_shift_with_heat_inversion()

    print("\n✅ WorldTargetingHeatTest: OK\n")
    get_tree().quit()


func _test_priority_targets_shift_with_heat_inversion() -> void:
    var nb := ArcNotebook.new()
    var self_id := &"A"
    var b := &"B"
    var c := &"C"

    # Base context for A (2 pairs: A-B and A-C)
    var ctx := FactionWorldContext.new()
    ctx.faction_id = self_id
    ctx.fatigue = 0.20

    # --- Initial arc snapshot (day 1..10): B is the worst, C is bad-but-less ---
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

    # --- Simulate 30 days of events ---
    for day in range(1, 31):
        ctx.day = day

        # B raids A on days 2, 4, 6
        if day == 2 or day == 4 or day == 6:
            nb.record_pair_event(b, self_id, ArcDecisionUtil.ARC_RAID, day)

        # B makes reparations to A on days 25, 27
        if day == 25 or day == 27:
            nb.record_pair_event(b, self_id, ArcDecisionUtil.ARC_REPARATIONS, day)

        # At day 10: B should clearly be best_enemy
        if day == 10:
            var res10 := WorldTargeting.compute_priority_targets(ctx, nb, self_id)
            _assert(StringName(res10["best_enemy"]) == b, "day10: best_enemy should be B after 3 raids")
            # On ne force pas best_ally ici (trop tôt / relations négatives)

    # --- Now invert the "current situation" at day 30: B becomes a truce partner ---
    ctx.day = 30
    arc_b["state"] = &"TRUCE"
    arc_b["rel_mean"] = 45.0
    arc_b["trust_mean"] = 70.0
    arc_b["tension_mean"] = 15.0
    arc_b["griev_mean"] = 10.0
    arc_b["wear_mean"] = 25.0

    # C stays hostile
    arc_c["state"] = &"RIVALRY"
    arc_c["rel_mean"] = -55.0
    arc_c["trust_mean"] = 25.0
    arc_c["tension_mean"] = 60.0
    arc_c["griev_mean"] = 45.0
    arc_c["wear_mean"] = 12.0

    var res30 := WorldTargeting.compute_priority_targets(ctx, nb, self_id)

    _assert(StringName(res30["best_ally"]) == b, "day30: best_ally should be B after reparations + improved trust/rel")
    _assert(StringName(res30["best_enemy"]) == c, "day30: best_enemy should shift to C once B is no longer the top enemy")

    # (Optionnel debug) : vérifier qu'on a bien enregistré des attempts (juste sanity)
    # print(res30["enemy_rank"])
    # print(res30["ally_rank"])


func _assert(cond: bool, msg: String) -> void:
    if not cond:
        push_error("TEST FAIL: " + msg)
        assert(false)
