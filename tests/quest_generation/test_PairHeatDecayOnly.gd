extends BaseTest
class_name PairHeatDecayOnlyTest

func _ready() -> void:
    _test_decay_only_reduces_hostile_heat_over_time()
    pass_test("✅ PairHeatDecayOnlyTest: OK")


func _test_decay_only_reduces_hostile_heat_over_time() -> void:
    var nb := ArcManagerRunner.arc_notebook
    var a := &"A"
    var b := &"B"

    var decay := 0.93
    var k := 0.35

    # Injecte une "salve" hostile concentrée
    nb.record_pair_event(2, b, a, ArcDecisionUtil.ARC_RAID)
    nb.record_pair_event(4, b, a, ArcDecisionUtil.ARC_RAID)
    nb.record_pair_event(6, b, a, ArcDecisionUtil.ARC_RAID)

    # Snapshot jour 10
    var h10 := nb.get_pair_heat(a, b, 10, decay)
    var hostile10 := float(h10["hostile_from_other"])
    var hostile_n10 := _norm(hostile10, k)

    # Aucun event ensuite => decay pur
    # Snapshot jour 30
    var h30 := nb.get_pair_heat(a, b, 30, decay)
    var hostile30 := float(h30["hostile_from_other"])
    var hostile_n30 := _norm(hostile30, k)

    # Assertions decay-only
    _assert(hostile30 < hostile10, "raw hostile heat should decay (got %.3f -> %.3f)" % [hostile10, hostile30])
    _assert(hostile_n30 < hostile_n10, "normalized hostile_n should decay (got %.3f -> %.3f)" % [hostile_n10, hostile_n30])

    # Quantitatif : baisse “significative”
    _assert(hostile_n30 < hostile_n10 - 0.25, "hostile_n should drop by at least 0.25 via decay-only (got %.3f -> %.3f)" % [hostile_n10, hostile_n30])


func _norm(x: float, k: float) -> float:
    return 1.0 - exp(-k * max(0.0, x))
