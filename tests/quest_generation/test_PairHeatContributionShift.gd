extends BaseTest
class_name PairHeatContributionShiftTest

func _ready() -> void:
    _test_heat_norms_shift_between_day10_and_day30()
    pass_test("\n✅ PairHeatContributionShiftTest: OK\n")


func _test_heat_norms_shift_between_day10_and_day30() -> void:
    var nb := ArcNotebook.new()
    var self_id := &"A"
    var b := &"B"

    var decay := 0.93
    var k := 0.35 # doit matcher WorldTargeting (hostile_n = 1 - exp(-k*hostile_from))

    # Simule 30 jours d'events (B -> A)
    for day in range(1, 31):
        # B raid A (3 fois)
        if day == 2 or day == 4 or day == 6:
            nb.record_pair_event(day, b, self_id, ArcDecisionUtil.ARC_RAID)

        # B réparations (2 fois)
        if day == 25 or day == 27:
            nb.record_pair_event(day, b, self_id, ArcDecisionUtil.ARC_REPARATIONS)

    # --- Day 10 heat ---
    var h10 := nb.get_pair_heat(self_id, b, 10, decay)
    var hostile10 := float(h10["hostile_from_other"])
    var friendly10 := float(h10["friendly_from_other"])
    var hostile_n10 := _norm(hostile10, k)
    var friendly_n10 := _norm(friendly10, k)

    # --- Day 30 heat ---
    var h30 := nb.get_pair_heat(self_id, b, 30, decay)
    var hostile30 := float(h30["hostile_from_other"])
    var friendly30 := float(h30["friendly_from_other"])
    var hostile_n30 := _norm(hostile30, k)
    var friendly_n30 := _norm(friendly30, k)

    # Assertions qualitatives simples
    _assert(hostile10 > hostile30, "hostile_from_other should decay over time (raw)")
    _assert(friendly30 > friendly10, "friendly_from_other should increase after reparations (raw)")

    # Assertions quantitatives robustes (sur la partie normalisée 0..1)
    _assert(hostile_n30 < hostile_n10 - 0.30, "hostile_n should drop by at least 0.30 (got %.3f -> %.3f)" % [hostile_n10, hostile_n30])
    _assert(friendly_n30 > friendly_n10 + 0.25, "friendly_n should rise by at least 0.25 (got %.3f -> %.3f)" % [friendly_n10, friendly_n30])

    # (Optionnel) sanity: à J10 friendly devrait être ~0
    _assert(friendly_n10 <= 0.05, "friendly_n at day10 should be near 0 (got %.3f)" % friendly_n10)


func _norm(x: float, k: float) -> float:
    # 1 - exp(-k*x) => soft cap vers 1
    return 1.0 - exp(-k * max(0.0, x))
