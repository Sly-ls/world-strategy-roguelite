extends BaseTest
class_name TreatySummitTraitorBreaksTest

func _ready() -> void:
    _test_traitor_summit_breaks_treaty()
    print("\n✅ TreatySummitTraitorBreaksTest: OK\n")
    get_tree().quit()

func _test_traitor_summit_breaks_treaty() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 22222

    var rel_ab := FactionRelationScore.new()
    var rel_ba := FactionRelationScore.new()
    rel_ab.relation = 30; rel_ba.relation = 28
    rel_ab.trust = 60;    rel_ba.trust = 58
    rel_ab.tension = 18;  rel_ba.tension = 20
    rel_ab.grievance = 8; rel_ba.grievance = 10

    var arc := ArcState.new()
    arc.state = &"TRUCE"
    arc.lock_until_day = 0

    # Treaty TRUCE: already near threshold so traitor summit pushes it over
    var t := Treaty.new()
    t.type = &"TRUCE"
    t.start_day = 1
    t.end_day = 40
    t.cooldown_after_end_days = 25
    t.clauses = Treaty.CLAUSE_NO_RAID | Treaty.CLAUSE_NO_SABOTAGE | Treaty.CLAUSE_NO_WAR
    t.violation_score = 0.90
    t.violation_threshold = 1.10  # low threshold so the test is deterministic
    arc.treaty = t

    # Day 10: summit TRAITOR => violation_score increases enough to cross threshold
    ArcStateMachine.apply_treaty_enforcement_resolution(
        arc, rel_ab, rel_ba,
        &"summit",
        &"TRAITOR",
        10
    )

    # Now we enforce "break rule" in update_arc_state:
    # Either you break immediately inside apply_treaty_enforcement_resolution,
    # or you check it in update_arc_state on next tick.
    #
    # We'll do a tick to be safe.
    ArcStateMachine.update_arc_state(
        arc, rel_ab, rel_ba,
        11, rng,
        &"", &""
    )

    _assert(arc.treaty == null, "treaty should be broken after traitor summit pushes score over threshold")

    # State should have deteriorated (TRUCE no longer valid)
    _assert(arc.state == &"CONFLICT" or arc.state == &"WAR" or arc.state == &"RIVALRY",
        "arc state should deteriorate after treaty breaks, got %s" % String(arc.state)
    )

    # Lock should be applied (post-treaty cooldown)
    _assert(arc.lock_until_day >= 11, "lock_until_day should be set after treaty break")


func _assert(cond: bool, msg: String) -> void:
    if not cond:
        push_error("TEST FAIL: " + msg)
        assert(false)
