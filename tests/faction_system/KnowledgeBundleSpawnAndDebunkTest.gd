extends Node
class_name KnowledgeBundleSpawnAndDebunkTest

# --- stubs (no dependency on your real QuestPool/ArcNotebook) ---
class TestQuestPool:
    var offers: Array = []
    func try_add_offer(inst) -> bool:
        offers.append(inst)
        return true

class TestArcNotebook:
    func can_spawn_knowledge_offer(_key: StringName, _day: int, _cooldown_days: int) -> bool:
        return true
    func mark_knowledge_offer_spawned(_key: StringName, _day: int) -> void:
        pass


func _ready() -> void:
    _test_bundle_spawns_then_debunk_reduces_bundle()
    print("\n✅ KnowledgeBundleSpawnAndDebunkTest: OK\n")
    get_tree().quit()


func _test_bundle_spawns_then_debunk_reduces_bundle() -> void:
    # Make randomness deterministic for qtype selection (factory uses randi()).
    seed(424242)

    var knowledge := FactionKnowledgeModel.new()

    var A := &"A"  # scapegoat
    var B := &"B"  # observer/victim
    var C := &"C"  # true actor

    # Profiles: B is more parano than diplomate => believes rumors more
    var profiles := {
        B: {"personality": {&"paranoia": 0.7, &"diplomacy": 0.3, &"intel": 0.5}}
    }

    # Minimal relations (used by apply_knowledge_resolution)
    var relations := {}
    relations[B] = {}
    relations[B][A] = FactionRelationScore.new()
    relations[B][A].trust = 40
    relations[B][A].tension = 10
    relations[B][A].grievance = 5
    relations[B][A].relation = 0

    # Fact: true raid is C -> B at day 1
    knowledge.register_fact({
        "id": &"evt_1",
        "day": 1,
        "type": &"RAID",
        "true_actor": C,
        "true_target": B,
        "severity": 1.0
    })

    # Rumor #1 (day 2): "A did it" (malicious)
    var rumor1 := {
        "id": &"rum_1",
        "day": 2,
        "seed_id": C,
        "claim_actor": A,
        "claim_target": B,
        "claim_type": &"RAID",
        "strength": 0.70,
        "credibility": 0.60,
        "malicious": true,
        "related_event_id": &"evt_1"
    }
    knowledge.inject_rumor(rumor1, [B], profiles)

    # Rumor #2 (day 3): reinforce the same claim, seed = BROKER
    var rumor2 := {
        "id": &"rum_2",
        "day": 3,
        "seed_id": &"BROKER",
        "claim_actor": A,
        "claim_target": B,
        "claim_type": &"RAID",
        "strength": 0.65,
        "credibility": 0.60,
        "malicious": true,
        "related_event_id": &"evt_1"
    }
    knowledge.inject_rumor(rumor2, [B], profiles)

    var heat_before := knowledge.get_perceived_heat(B, A, 3)
    _assert(heat_before >= 40.0, "precondition: heat should be >=40 after 2 rumors (heat=%.1f)" % heat_before)

    # Spawn bundle offers for rumor2
    var pool := TestQuestPool.new()
    var notebook := Notebook.new()

    var offers_before: Array = KnowledgeOfferFactory.spawn_offers_for_rumor(
        knowledge,
        rumor2,
        [B],
        3,
        pool,
        notebook,
        profiles,
        {"knowledge_bundle_max": 3, "knowledge_offer_cooldown_days": 0}
    )

    _assert(offers_before.size() >= 2 and offers_before.size() <= 3,
        "expected 2-3 offers at high heat, got %d" % offers_before.size())

    # Validate roles per knowledge_action
    var has_investigate := false
    var has_innocence := false
    var has_forge := false

    for inst in offers_before:
        var ctx: Dictionary = inst.context
        _assert(bool(ctx.get("is_knowledge_offer", false)), "offer must have is_knowledge_offer=true")

        var kact: StringName = StringName(ctx.get("knowledge_action", &""))
        var giver: StringName = StringName(ctx.get("giver_faction_id", &""))
        var ant: StringName = StringName(ctx.get("antagonist_faction_id", &""))
        var tp: StringName = StringName(ctx.get("third_party_id", &""))

        if kact == &"INVESTIGATE":
            has_investigate = true
            _assert(giver == B, "INVESTIGATE giver should be observer/victim B")
            _assert(ant == A, "INVESTIGATE antagonist should be claimed_actor A")
            _assert(tp == &"BROKER", "INVESTIGATE third_party should be rumor seed (BROKER)")
        elif kact == &"PROVE_INNOCENCE":
            has_innocence = true
            _assert(giver == A, "PROVE_INNOCENCE giver should be claimed_actor A")
            _assert(ant == B, "PROVE_INNOCENCE antagonist should be observer B")
            _assert(tp == &"BROKER", "PROVE_INNOCENCE third_party should be rumor seed (BROKER)")
        elif kact == &"FORGE_EVIDENCE":
            has_forge = true
            _assert(giver == &"BROKER", "FORGE_EVIDENCE giver should be seed (BROKER)")
            _assert(ant == A, "FORGE_EVIDENCE antagonist should be claimed_actor A")
            _assert(tp == B, "FORGE_EVIDENCE third_party should be observer/victim B")

    _assert(has_investigate, "bundle should include INVESTIGATE at heat>=40")
    _assert(has_innocence, "bundle should include PROVE_INNOCENCE at heat>=40")
    # FORGE is expected in most cases at malicious=true and heat>=40 (unless confidence already >0.85).
    _assert(has_forge or offers_before.size() == 2, "bundle should include FORGE_EVIDENCE unless confidence already saturated")

    # --- Debunk at day 4: PROVE_INNOCENCE LOYAL reduces confidence in the hostile claim ---
    knowledge.apply_knowledge_resolution({
        "observer_id": B,
        "claimed_actor": A,
        "claimed_target": B,
        "claim_type": &"RAID",
        "knowledge_action": &"PROVE_INNOCENCE",
        "related_event_id": &"evt_1",
        "day": 4
    }, &"LOYAL", relations, profiles, 4)

    var heat_after_debunk := knowledge.get_perceived_heat(B, A, 4)
    _assert(heat_after_debunk < heat_before, "heat should drop after debunk (%.1f -> %.1f)" % [heat_before, heat_after_debunk])
    _assert(heat_after_debunk < 40.0, "heat should drop below 'high heat' zone after debunk (heat=%.1f)" % heat_after_debunk)

    # --- Day 5: a new weak malicious rumor tries again, but bundle should be smaller due to debunk ---
    var rumor3 := {
        "id": &"rum_3",
        "day": 5,
        "seed_id": &"BROKER",
        "claim_actor": A,
        "claim_target": B,
        "claim_type": &"RAID",
        "strength": 0.40,
        "credibility": 0.50,
        "malicious": true,
        "related_event_id": &"evt_1"
    }
    knowledge.inject_rumor(rumor3, [B], profiles)

    var heat_day5 := knowledge.get_perceived_heat(B, A, 5)

    var pool2 := TestQuestPool.new()
    var offers_after: Array = KnowledgeOfferFactory.spawn_offers_for_rumor(
        knowledge,
        rumor3,
        [B],
        5,
        pool2,
        notebook,
        profiles,
        {"knowledge_bundle_max": 3, "knowledge_offer_cooldown_days": 0}
    )

    _assert(offers_after.size() <= offers_before.size() - 1,
        "bundle should be reduced after debunk (before=%d after=%d heat=%.1f)" % [offers_before.size(), offers_after.size(), heat_day5])

    # With lower heat/confidence, FORGE should usually not appear anymore.
    for inst2 in offers_after:
        var kact2: StringName = StringName(inst2.context.get("knowledge_action", &""))
        _assert(kact2 != &"FORGE_EVIDENCE", "after debunk + weaker rumor, FORGE_EVIDENCE should not be spawned (heat=%.1f)" % heat_day5)


func _assert(cond: bool, msg: String) -> void:
    if not cond:
        push_error("TEST FAIL: " + msg)
        assert(false)
