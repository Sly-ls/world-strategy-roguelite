extends BaseTest
class_name Integration_QuestManager_Mediation3Factions_Test

# --- ArcNotebook stub (captures meta) ---
class StubArcNotebook:
    extends RefCounted
    var pair_events: Array = []
    var triplet_events: Array = []

    func record_pair_event(day: int, a: StringName, b: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
        pair_events.append({"day": day, "a": a, "b": b, "action": action, "choice": choice, "meta": meta})

    func record_triplet_event(day: int, a: StringName, b: StringName, c: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
        triplet_events.append({"day": day, "a": a, "b": b, "c": c, "action": action, "choice": choice, "meta": meta})


# --- Fallback relation score if your real one isn't in ClassDB ---
class TestRelationScore:
    extends RefCounted
    var relation: int = 0
    var trust: int = 50
    var tension: int = 0
    var grievance: int = 0
    var weariness: int = 0


func _ready() -> void:
    _test_resolve_quest_mediation_3f_roll_forced_logs_and_deltas()
    print("\n✅ Integration_QuestManager_Mediation3Factions_Test: OK\n")


func _test_resolve_quest_mediation_3f_roll_forced_logs_and_deltas() -> void:
    # --- preconditions ---
    _assert(ClassDB.class_exists("QuestOutcomeUtil"), "QuestOutcomeUtil must exist")
    _assert(ClassDB.class_exists("ArcFailureConsequences"), "ArcFailureConsequences must exist")
    _assert(ClassDB.class_exists("QuestInstance"), "QuestInstance must exist")
    _assert(ClassDB.class_exists("QuestTemplate"), "QuestTemplate must exist")

    # Find real QuestManager autoload
    var qm: Node = _find_first_root_node(["QuestManagerRunner", "QuestManager"])
    _assert(qm != null, "Missing /root QuestManagerRunner (or QuestManager)")

    # ArcManagerRunner (to host arc_notebook)
    var arc_mgr: Node = _find_first_root_node(["ArcManagerRunner"])
    _assert(arc_mgr != null, "Missing /root/ArcManagerRunner (needed for ArcNotebook logging)")

    # Relations runner (optional, but we need QuestManager to find relations store)
    var rel_runner: Node = _find_first_root_node(["FactionRelationsRunner"])
    var created_rel_runner := false
    if rel_runner == null:
        rel_runner = Node.new()
        rel_runner.name = "FactionRelationsRunner"
        # QuestManager helper earlier expects relations_by_faction variable
        rel_runner.set("relations_by_faction", {})
        get_tree().root.add_child(rel_runner)
        created_rel_runner = true

    # --- snapshot & patch ArcNotebook ---
    var prev_arc_notebook = null
    if arc_mgr.has_variable("arc_notebook"):
        prev_arc_notebook = arc_mgr.arc_notebook
    var notebook := StubArcNotebook.new()
    arc_mgr.arc_notebook = notebook

    # --- snapshot & patch relations store ---
    var prev_rel_store = null
    if rel_runner.has_variable("relations_by_faction"):
        prev_rel_store = rel_runner.relations_by_faction

    # Build relations for A,B,C
    var A := &"A"
    var B := &"B"
    var C := &"C" # mediator

    var ScoreClass = FactionRelationScore if ClassDB.class_exists("FactionRelationScore") else TestRelationScore
    var store := {}
    store[A] = {}
    store[B] = {}
    store[C] = {}

    store[A][B] = ScoreClass.new()
    store[B][A] = ScoreClass.new()
    store[A][C] = ScoreClass.new()
    store[B][C] = ScoreClass.new()
    store[C][A] = ScoreClass.new()
    store[C][B] = ScoreClass.new()

    # high heat A<->B + neutral trust to mediator
    store[A][B].tension = 80
    store[B][A].tension = 80
    store[A][B].grievance = 70
    store[B][A].grievance = 70
    store[A][C].trust = 50
    store[B][C].trust = 50
    store[C][A].trust = 50
    store[C][B].trust = 50

    rel_runner.relations_by_faction = store

    # --- create mediation QuestInstance and register as ACTIVE ---
    var template = QuestTemplate.new()
    template.id = &"tp.mediation"
    template.title = "Mediation"
    template.description = "Test mediation 3 factions"
    template.category = &"ARC"
    template.tier = 3
    template.expires_in_days = 7

    var inst = QuestInstance.new(template, {
        # 3 participants
        "tp_action": &"tp.mediation",
        "giver_faction_id": C,          # mediator is giver/actor
        "actor_faction_id": C,
        "antagonist_faction_id": A,
        "third_party_id": B,

        # make outcome deterministic and FAIL
        "roll": 0.95,

        # opposition precomputed so QuestManager doesn't need extra runners
        "opposition": {"tension_mean": 85, "grievance_mean": 75, "friction": 0.3, "resistance": 0.7},

        # day for notebook logging + seeding
        "day": 10,

        # ensure some profile exists (optional)
        "resolution_profile_id": &"default_simple"
    })
    inst.runtime_id = &"test_mediation_3f_001"
    inst.status = "ACTIVE"
    inst.started_on_day = 10
    inst.expires_on_day = 17

    # Add to QuestManager active list via real method if possible
    if qm.has_method("start_runtime_quest"):
        qm.start_runtime_quest(inst)
    else:
        # fallback: set active_quests directly
        _assert(qm.has_variable("active_quests"), "QuestManager must have active_quests or start_runtime_quest()")
        qm.active_quests[inst.runtime_id] = inst

    # --- capture before ---
    var tension_before :float = store[A][B].tension
    var trust_a_c_before :float = store[A][C].trust

    # --- act ---
    # LOYAL attempt but should fail due to roll
    qm.resolve_quest(inst.runtime_id, &"LOYAL")

    # --- assertions: deltas applied ---
    _assert(store[A][B].tension > tension_before, "tension(A→B) should increase after failed mediation (before=%d after=%d)" % [tension_before, store[A][B].tension])
    _assert(store[A][C].trust < trust_a_c_before, "trust(A→C) should decrease after failed mediation (before=%d after=%d)" % [trust_a_c_before, store[A][C].trust])

    # --- assertions: ArcNotebook logged chance/roll/outcome ---
    var found := false
    for e in notebook.triplet_events:
        if StringName(e.get("action", &"")) == &"tp.mediation":
            var meta: Dictionary = e.get("meta", {})
            _assert(StringName(meta.get("outcome", &"")) == &"FAILURE", "notebook meta.outcome should be FAILURE")
            _assert(meta.has("chance") and meta.has("roll"), "notebook meta should include chance + roll")
            _assert(float(meta["roll"]) == 0.95, "notebook roll should match forced roll (0.95)")
            _assert(float(meta["chance"]) < float(meta["roll"]), "chance should be < roll to justify failure (chance=%.3f roll=%.3f)" % [float(meta["chance"]), float(meta["roll"])])
            found = true
            break
    _assert(found, "expected a triplet_event for tp.mediation in ArcNotebook")

    # --- restore patched state ---
    arc_mgr.arc_notebook = prev_arc_notebook
    if prev_rel_store != null:
        rel_runner.relations_by_faction = prev_rel_store
    if created_rel_runner:
        rel_runner.queue_free()


func _find_first_root_node(names: Array) -> Node:
    for n in names:
        var node = get_node_or_null("/root/" + String(n))
        if node != null:
            return node
    return null
