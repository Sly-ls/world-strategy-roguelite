extends BaseTest
class_name TributeTwoMissesBreakTreatyTest

func _ready() -> void:
    _test_two_non_payments_break_treaty_and_escalate_state()
    pass_test("\n✅ TributeTwoMissesBreakTreatyTest: OK\n")


func _test_two_non_payments_break_treaty_and_escalate_state() -> void:
    var winner := &"A"
    var loser := &"B"

    # --- economies ---
    var economies := {}
    economies[winner] = FactionEconomy.new()
    economies[loser]  = FactionEconomy.new()
    economies[winner].gold = 0
    economies[loser].gold = 0  # always non-payment

    # --- relations ---
    var relations := {}
    relations[winner] = {}
    relations[loser] = {}
    relations[winner][loser] = FactionRelationScore.new()
    relations[loser][winner] = FactionRelationScore.new()

    relations[winner][loser].trust = 40
    relations[winner][loser].tension = 20
    relations[winner][loser].grievance = 10

    relations[loser][winner].trust = 35
    relations[loser][winner].tension = 25
    relations[loser][winner].grievance = 15

    # --- arc + treaty ---
    var arc := ArcState.new()
    arc.state = &"TRUCE"

    var t := Treaty.new()
    t.type = &"TRUCE"
    t.start_day = 1
    t.end_day = 60
    t.cooldown_after_end_days = 25
    t.clauses = Treaty.CLAUSE_NO_RAID | Treaty.CLAUSE_NO_SABOTAGE | Treaty.CLAUSE_NO_WAR | Treaty.CLAUSE_OPEN_TRADE
    t.violation_score = 0.0
    t.violation_threshold = 0.45  # LOW: 2 misses should break deterministically
    arc.treaty = t

    # tribute schedule: due day 7 then day 14
    arc.war_terms = {
        "tribute_active": true,
        "tribute_winner": winner,
        "tribute_loser": loser,
        "tribute_gold_per_week": 50,
        "tribute_weeks_left": 2,
        "tribute_next_day": 7,
        "tribute_missed_payments": 0,
        "tribute_last_miss_day": -999999
    }

    # --- notebook + spawn fn stub ---
    var notebook := ArcNotebook.new()
    var spawn_calls := 0

    var spawn_fn := func(w: StringName, l: StringName, day: int, tier: int) -> QuestInstance:
        spawn_calls += 1
        return null

    # --- Miss #1 (day 7) ---
    ArcStateMachine.tick_tribute_if_any(
        arc, 7,
        economies,
        relations,
        notebook,
        Callable(spawn_fn)
    )

    _assert(arc.treaty != null, "treaty should still exist after first miss (depending on threshold)")
    _assert(spawn_calls == 1, "spawn should be called on first miss")

    # --- Miss #2 (day 14) => should break treaty ---
    ArcStateMachine.tick_tribute_if_any(
        arc, 14,
        economies,
        relations,
        notebook,
        Callable(spawn_fn)
    )

    _assert(spawn_calls >= 1, "spawn should have been called at least once (cooldown may block second)")
    _assert(arc.treaty == null, "treaty should be broken after second miss crosses threshold")

    _assert(
        arc.state == &"CONFLICT" or arc.state == &"WAR",
        "arc state should escalate to CONFLICT/WAR after treaty breaks, got %s" % String(arc.state)
    )

    _assert(arc.lock_until_day >= 14, "lock_until_day should be applied after treaty break")
