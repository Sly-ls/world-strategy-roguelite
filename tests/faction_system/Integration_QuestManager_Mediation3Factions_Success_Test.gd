extends BaseTest
class_name Integration_QuestManager_Mediation3Factions_Success_Test

class StubArcNotebook:
    extends RefCounted
    var pair_events: Array = []
    var triplet_events: Array = []

    func record_pair_event(day: int, a: StringName, b: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
        pair_events.append({"day": day, "a": a, "b": b, "action": action, "choice": choice, "meta": meta})

    func record_triplet_event(day: int, a: StringName, b: StringName, c: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
        triplet_events.append({"day": day, "a": a, "b": b, "c": c, "action": action, "choice": choice, "meta": meta})

class TestRelationScore:
    extends RefCounted
    var relation: int = 0
    var trust: int = 50
    var tension: int = 0
    var grievance: int = 0
    var weariness: int = 0

func _ready() -> void:
    _test_resolve_quest_mediation_success_logs_and_inverse_deltas()
    print("\n✅ Integration_QuestManager_Mediation3Factions_Success_Test: OK\n")
    get_tree().quit()

func _test_resolve_quest_mediation_success_logs_and_inverse_deltas() -> void:
    _assert(ClassDB.class_exists("QuestOutcomeUtil"), "QuestOutcomeUtil must exist")
    _assert(ClassDB.class_exists("ArcFailureConsequences"), "ArcFailureConsequences must exist")
    _assert(ClassDB.class_exists("QuestInstance"), "QuestInstance must exist")
    _assert(ClassDB.class_exists("QuestTemplate"), "QuestTemplate must exist")

    var qm: Node = _find_first_root_node(["QuestManagerRunner", "QuestManager"])
    _assert(qm != null, "Missing /root QuestManagerRunner (or QuestManager)")

    var arc_mgr: Node = _find_first_root_node(["ArcManagerRunner"])
    _assert(arc_mgr != null, "Missing /root/ArcManagerRunner")

    var rel_runner: Node = _find_first_root_node(["FactionRelationsRunner"])
    var created_rel_runner := false
    if rel_runner == null:
        rel_runner = Node.new()
        rel_runner.name = "FactionRelationsRunner"
        rel_runner.set("relations_by_faction", {})
        get_tree().root.add_child(rel_runner)
        created_rel_runner = true

    # --- patch notebook ---
    var prev_arc_notebook = null
    if arc_mgr.has_variable("arc_notebook"):
        prev_arc_notebook = arc_mgr.arc_notebook
    var notebook := StubArcNotebook.new()
    arc_mgr.arc_notebook = notebook

    # --- relations store ---
    var prev_rel_store = null
    if rel_runner.has_variable("relations_by_faction"):
        prev_rel_store = rel_runner.relations_by_faction

    var A := &"A"
    var B := &"B"
    var C := &"C" # mediator

    var ScoreClass = FactionRelationScore if ClassDB.class_exists("FactionRelationScore") else TestRelationScore
    var store := {A: {}, B: {}, C: {}}

    store[A][B] = ScoreClass.new()
    store[B][A] = ScoreClass.new()
    store[A][C] = ScoreClass.new()
    store[B][C] = ScoreClass.new()
    store[C][A] = ScoreClass.new()
    store[C][B] = ScoreClass.new()

    # baseline: conflict moderate, mediator trust neutral
    store[A][B].tension = 45
    store[B][A].tension = 45
    store[A][B].grievance = 25
    store[B][A].grievance = 25
    store[A][C].trust = 50
    store[B][C].trust = 50
    store[C][A].trust = 50
    store[C][B].trust = 50

    rel_runner.relations_by_faction = store

    # --- quest instance mediation 3 factions ---
    var template = QuestTemplate.new()
    template.id = &"tp.mediation"
    template.title = "Mediation"
    template.description = "Test mediation SUCCESS"
    template.category = &"ARC"
    template.tier = 2
    template.expires_in_days = 7

    var inst = QuestInstance.new(template, {
        "tp_action": &"tp.mediation",
        "giver_faction_id": C,
        "actor_faction_id": C,
        "antagonist_faction_id": A,
        "third_party_id": B,

        # force success: roll small
        "roll": 0.02,

        # opposition mild => success chance should be > 0.02
        "opposition": {"tension_mean": 40, "grievance_mean": 20, "friction": 0.1, "resistance": 0.55},

        "day": 10,
        "resolution_profile_id": &"default_simple"
    })
    inst.runtime_id = &"test_mediation_3f_success_001"
    inst.status = "ACTIVE"
    inst.started_on_day = 10
    inst.expires_on_day = 17

    # add to active quests
    if qm.has_method("start_runtime_quest"):
        qm.start_runtime_quest(inst)
    else:
        _assert(qm.has_variable("active_quests"), "QuestManager must have active_quests or start_runtime_quest()")
        qm.active_quests[inst.runtime_id] = inst

    var tension_before :int = store[A][B].tension
    var trust_a_c_before :int = store[A][C].trust

    # --- act ---
    qm.resolve_quest(inst.runtime_id, &"LOYAL")

    # --- status should be COMPLETED (not FAILED) ---
    _assert(String(inst.status) == "COMPLETED", "quest status should be COMPLETED (got %s)" % String(inst.status))

    # optional: should be removed from active_quests
    if qm.has_variable("active_quests"):
        _assert(not qm.active_quests.has(inst.runtime_id), "quest should be removed from active_quests after resolve")

    # --- inverse deltas: tension down, trust to mediator up ---
    _assert(store[A][B].tension < tension_before, "tension(A→B) should decrease on successful mediation (before=%d after=%d)" % [tension_before, store[A][B].tension])
    _assert(store[A][C].trust > trust_a_c_before, "trust(A→C) should increase on successful mediation (before=%d after=%d)" % [trust_a_c_before, store[A][C].trust])

    # --- ArcNotebook meta: outcome/chance/roll ---
    var found := false
    for e in notebook.triplet_events:
        if StringName(e.get("action", &"")) == &"tp.mediation":
            var meta: Dictionary = e.get("meta", {})
            _assert(StringName(meta.get("outcome", &"")) == &"SUCCESS", "notebook meta.outcome should be SUCCESS")
            _assert(meta.has("chance") and meta.has("roll"), "notebook meta should include chance + roll")
            _assert(float(meta["roll"]) == 0.02, "notebook roll should match forced roll (0.02)")
            _assert(float(meta["chance"]) > float(meta["roll"]), "chance should be > roll to justify success (chance=%.3f roll=%.3f)" % [float(meta["chance"]), float(meta["roll"])])
            found = true
            break
    _assert(found, "expected a triplet_event for tp.mediation in ArcNotebook")

    # --- restore ---
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
