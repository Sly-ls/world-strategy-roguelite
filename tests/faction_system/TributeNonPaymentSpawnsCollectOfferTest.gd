extends BaseTest
class_name TributeNonPaymentSpawnsCollectOfferTest

func _ready() -> void:
    _test_non_payment_spawns_collect_offer_then_payment_succeeds()
    pass_test("\n✅ TributeNonPaymentSpawnsCollectOfferTest: OK\n")


func _test_non_payment_spawns_collect_offer_then_payment_succeeds() -> void:
    var winner := &"A"
    var loser := &"B"

    # --- economies ---
    var economies := {}
    economies[winner] = FactionEconomy.new()
    economies[loser]  = FactionEconomy.new()
    economies[winner].gold = 0
    economies[loser].gold = 0  # non-payment

    # --- relations ---
    var relations := {}
    relations[winner] = {}
    relations[loser] = {}
    relations[winner][loser] = FactionRelationScore.new()
    relations[loser][winner] = FactionRelationScore.new()

    # some baseline values
    relations[winner][loser].trust = 40
    relations[winner][loser].tension = 20
    relations[winner][loser].grievance = 10

    relations[loser][winner].trust = 35
    relations[loser][winner].tension = 25
    relations[loser][winner].grievance = 15

    # --- arc + treaty + tribute schedule ---
    var arc := ArcState.new()
    arc.state = &"TRUCE"

    var t := Treaty.new()
    t.type = &"TRUCE"
    t.start_day = 1
    t.end_day = 60
    t.cooldown_after_end_days = 25
    t.clauses = Treaty.CLAUSE_NO_RAID | Treaty.CLAUSE_NO_SABOTAGE | Treaty.CLAUSE_NO_WAR | Treaty.CLAUSE_OPEN_TRADE
    t.violation_score = 0.0
    t.violation_threshold = 1.2
    arc.treaty = t

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

    # --- notebook + stub spawn fn ---
    var notebook := ArcNotebook.new()
    var spawn_called := false
    var spawn_args := {}

    var spawn_fn := func(w: StringName, l: StringName, day: int, tier: int) -> QuestInstance:
        spawn_called = true
        spawn_args = {"winner": w, "loser": l, "day": day, "tier": tier}
        # returning null is fine; this test only checks callback call
        return null

    # --- Day 7: due but loser has 0 => violation_score increases + spawn called ---
    var v_before :float = arc.treaty.violation_score
    ArcStateMachine.tick_tribute_if_any(
        arc, 7,
        economies,
        relations,
        notebook,
        Callable(spawn_fn)
    )

    _assert(arc.treaty != null, "treaty should still exist after first non-payment (should not auto-break)")
    _assert(arc.treaty.violation_score > v_before, "violation_score should increase on non-payment (%.3f -> %.3f)" % [v_before, arc.treaty.violation_score])
    _assert(spawn_called, "spawn_collect_offer_fn should be called on non-payment")
    _assert(StringName(spawn_args.get("winner", &"")) == winner, "spawn arg winner mismatch")
    _assert(StringName(spawn_args.get("loser", &"")) == loser, "spawn arg loser mismatch")
    _assert(int(spawn_args.get("day", -1)) == 7, "spawn day should be 7")

    # weeks_left should NOT decrement on non-payment
    _assert(int(arc.war_terms["tribute_weeks_left"]) == 2, "weeks_left should not decrement on non-payment")

    # --- Give gold and tick next due (day 14) => payment succeeds, gold transfers, weeks_left decrements ---
    economies[loser].gold = 80
    spawn_called = false
    spawn_args = {}

    var winner_gold_before :int = economies[winner].gold
    var loser_gold_before :int = economies[loser].gold
    var weeks_before := int(arc.war_terms["tribute_weeks_left"])

    ArcStateMachine.tick_tribute_if_any(
        arc, 14,
        economies,
        relations,
        notebook,
        Callable(spawn_fn)
    )

    # should not spawn now (successful payment)
    _assert(not spawn_called, "spawn_collect_offer_fn should not be called on successful payment")

    # transfer happened
    var amt := int(arc.war_terms.get("tribute_gold_per_week", 50))
    _assert(economies[winner].gold == winner_gold_before + amt, "winner gold should increase by tribute amount")
    _assert(economies[loser].gold == loser_gold_before - amt, "loser gold should decrease by tribute amount")

    # weeks left decremented
    _assert(int(arc.war_terms["tribute_weeks_left"]) == weeks_before - 1, "weeks_left should decrement on successful payment")
