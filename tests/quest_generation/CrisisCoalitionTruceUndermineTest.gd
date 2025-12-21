extends BaseTest
class_name CrisisCoalitionTruceUndermineTest

# -------- Stubs --------

class TestFactionProfile:
    var personality := {}
    var axis_affinity := {} # axis -> -100..100

    func _init(p: Dictionary, a: Dictionary) -> void:
        personality = p
        axis_affinity = a

    func get_personality(key: StringName, default_val: float = 0.5) -> float:
        return float(personality.get(key, default_val))

    func get_axis_affinity(axis: StringName, default_val: int = 0) -> int:
        return int(axis_affinity.get(axis, default_val))


# -------- Deterministic stance manager (argmax) --------
class TestCoalitionManager:
    extends CoalitionManager

    func _decide_member_stance(
        c: CoalitionBlock,
        m: StringName,
        day: int,
        profiles: Dictionary,
        relations: Dictionary,
        world: Dictionary,
        arc_notebook,
        crisis_axis: StringName,
        crisis_source: StringName
    ) -> StringName:
        var p = profiles.get(m, null)
        var commit := float(c.member_commitment.get(m, 0.6))

        var opportunism := _p(p, &"opportunism", 0.5)
        var diplomacy := _p(p, &"diplomacy", 0.5)
        var honor := _p(p, &"honor", 0.5)
        var fear := _p(p, &"fear", 0.5)

        var rel_to_target := _rel(relations, m, c.target_id)
        var likes_target := rel_to_target >= 40.0
        var hates_target := rel_to_target <= -40.0

        var axis_aff := 0.0
        if crisis_axis != &"" and p != null and p.has_method("get_axis_affinity"):
            axis_aff = float(p.get_axis_affinity(crisis_axis, 0)) / 100.0

        var sev := float(world.get("crisis_severity", 0.0))
        var crisis_pressure := sev if (c.kind == &"CRISIS") else 0.0

        var hate_ratio :float = 0.0
        if hates_target:
            hate_ratio =  1.0
        var p_support :float = 0.25 + 0.55*commit + 0.20*honor + 0.15*(hate_ratio) + 0.20*crisis_pressure - 0.20*fear - 0.15*opportunism
        
        var likes_ratio :float = 0.0
        if likes_target:
            likes_ratio =  1.0
        var p_undermine :float = 0.08 + 0.30*opportunism + 0.20*fear + 0.20*(likes_ratio) - 0.20*honor

        # STOP_CRISIS + corruption-aligned => more undermine
        if c.kind == &"CRISIS" and c.goal == &"STOP_CRISIS" and axis_aff >= 0.55:
            p_undermine += 0.18
            p_support -= 0.10

        # friendly to crisis source => more undermine in STOP coalition
        if crisis_source != &"":
            var rel_to_source := _rel(relations, m, crisis_source)
            if c.goal == &"STOP_CRISIS" and rel_to_source >= 50.0:
                p_undermine += 0.20
                p_support -= 0.10

        p_support = clampf(p_support, 0.0, 0.95)
        p_undermine = clampf(p_undermine, 0.0, 0.80)
        var p_hedge :float = max(0.0, 1.0 - (p_support + p_undermine))

        # deterministic: choose argmax
        if p_undermine >= p_support and p_undermine >= p_hedge:
            return STANCE_UNDERMINE
        if p_support >= p_hedge:
            return STANCE_SUPPORT
        return STANCE_HEDGE


func _ready() -> void:
    _test_crisis_coalition_truce_then_undermine_creates_suspicion()
    pass_test("\n✅ CrisisCoalitionTruceUndermineTest: OK\n")


func _test_crisis_coalition_truce_then_undermine_creates_suspicion() -> void:
    var mgr := CoalitionManager.new()

    var A := &"A"  # enemy of B, but will SUPPORT coalition
    var B := &"B"  # opportunist + corruption affinity => UNDERMINE
    var D := &"D"  # third member to satisfy min members
    var C := &"C"  # crisis instigator/target of STOP coalition

    var faction_ids: Array[StringName] = [A, B, C, D]

    # Profiles
    var profiles := {
        A: FactionProfile.from_profile_and_axis(
            {&"honor": 0.8, &"diplomacy": 0.6, &"opportunism": 0.2, &"fear": 0.3},
            {FactionProfile.AXIS_CORRUPTION: -80}
        ),
        # B: can join STOP_CRISIS (honor/diplomacy decent), but stance will undermine due opportunism/fear + corruption affinity
        B: FactionProfile.from_profile_and_axis(
            {&"honor": 0.75, &"diplomacy": 0.7, &"opportunism": 0.9, &"fear": 0.9},
            {FactionProfile.AXIS_CORRUPTION: 85}
        ),
        D: FactionProfile.from_profile_and_axis(
            {&"honor": 0.65, &"diplomacy": 0.55, &"opportunism": 0.35, &"fear": 0.35},
            {FactionProfile.AXIS_CORRUPTION: -40}
        ),
        C: FactionProfile.from_profile_and_axis(
            {&"honor": 0.3, &"diplomacy": 0.2, &"opportunism": 0.7, &"fear": 0.4},
            {FactionProfile.AXIS_CORRUPTION: 90}
        ),
    }

    # Relations matrix
    var relations := {}
    for f in faction_ids:
        relations[f] = {}
    for x in faction_ids:
        for y in faction_ids:
            if x == y: continue
            relations[x][y] = FactionRelationScore.new()

    # A and B are enemies / at war-like
    relations[A][B].relation = -80
    relations[B][A].relation = -80

    # Everyone dislikes C enough to join anti crisis (STOP_CRISIS uses dislike source)
    relations[A][C].relation = -70
    relations[D][C].relation = -60
    relations[B][C].relation = -60

    # (Optional) B is NOT friendly to C here; undermine is driven by corruption affinity + opportunism/fear
    # If you want “B friendly to instigator”, set relations[B][C].relation = +60 (but then join score might drop unless you update join scoring)

    # World crisis
    var world := {
        "crisis_active": true,
        "crisis_severity": 0.90,
        "crisis_axis": FactionProfile.AXIS_CORRUPTION,
        "crisis_source_id": C,
        "power_by_faction": {A: 40.0, B: 38.0, C: 60.0, D: 70.0},
        "hegemon_index_by_faction": {} # not needed
    }
    var notebook := ArcNotebook.new()

    # Day 10: tick => should form STOP_CRISIS coalition and set truce locks
    mgr.tick_day(10, faction_ids, profiles, relations, world, notebook)

    # Find the created STOP_CRISIS coalition
    var coal:CoalitionBlock = null
    for cid in mgr.coalitions_by_id.keys():
        var c = mgr.coalitions_by_id[cid]
        if c.kind == &"CRISIS" and c.goal == &"STOP_CRISIS" and c.target_id == C:
            coal = c
            break

    _assert(coal != null, "should create a STOP_CRISIS coalition")
    _assert(coal.member_ids.has(A) and coal.member_ids.has(B) and coal.member_ids.has(D), "coalition should include A,B,D")

    # Verify pair lock truce between members (A|B in particular)
    var pair_key_ab := Utils.pair_key(A, B)
    _assert(notebook.pair_locks.has(pair_key_ab), "expected pair lock for A|B to exist (temporary coalition truce)")
    var lock :Dictionary = notebook.pair_locks.get("pair_key_ab")
    _assert(int(lock["until"]) >= 10 + 10, "truce lock should last ~10+ days, got until=%d" % int(lock["until"]))
    _assert(StringName(lock["reason"]) == &"COALITION_TRUCE", "lock reason should be COALITION_TRUCE")

    # Ensure a JOINT OP offer exists (spawned by tick_day)
    var joint_ctx: Dictionary = {}
    for inst in QuestPool.offers:
        if bool(inst.context.get("is_coalition", false)) and StringName(inst.context.get("coalition_id", &"")) == coal.id:
            if inst.context.has("joint_op_type"):
                joint_ctx = inst.context
                break
    _assert(not joint_ctx.is_empty(), "expected at least one joint_op offer context")

    # Apply resolution at day 11: should cause B to UNDERMINE deterministically and lower cohesion, and create suspicion event
    var cohesion_before := coal.cohesion
    var betrayals_before := notebook.count_events_by_action(&"COALITION_BETRAYAL")

    mgr.apply_joint_op_resolution(joint_ctx, &"LOYAL", 11, profiles, relations, world, notebook)

    _assert(coal.cohesion < cohesion_before, "cohesion should decrease when a member undermines (before=%d after=%d)" % [cohesion_before, coal.cohesion])

    var betrayals_after := notebook.count_events_by_action(&"COALITION_BETRAYAL")
    _assert(betrayals_after > betrayals_before, "should record COALITION_BETRAYAL suspicion event after undermine")
