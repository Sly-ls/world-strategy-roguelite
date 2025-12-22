extends BaseTest
class_name Integration_QuestManager_Mediation3Factions_Test
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
    pass_test("\n✅ Integration_QuestManager_Mediation3Factions_Test: OK\n")


func _test_resolve_quest_mediation_3f_roll_forced_logs_and_deltas() -> void:
    # --- preconditions ---
    _assert(ClassDB.class_exists("QuestOutcomeUtil"), "QuestOutcomeUtil must exist")
    _assert(ClassDB.class_exists("ArcFailureConsequences"), "ArcFailureConsequences must exist")
    _assert(ClassDB.class_exists("QuestInstance"), "QuestInstance must exist")
    _assert(ClassDB.class_exists("QuestTemplate"), "QuestTemplate must exist")

    _assert(QuestManager != null, "Missing /root QuestManagerRunner (or QuestManager)")
    _assert(ArcManagerRunner != null, "Missing /root/ArcManagerRunner")
    _assert(FactionManager != null, "Missing /root/FactionManager")

    # --- snapshot & patch ArcNotebook ---
    var prev_arc_notebook: ArcNotebook = ArcManagerRunner.arc_notebook
    var notebook: ArcNotebook = ArcNotebook.new()
    ArcManagerRunner.arc_notebook = notebook

    # Build relations for A,B,C
    var A := &"A"
    var B := &"B"
    var C := &"C" # mediator

    var store := {}
    FactionManager.relation_scores[A] = {}
    FactionManager.relation_scores[B] = {}
    FactionManager.relation_scores[C] = {}

    FactionManager.relation_scores[A][B] = FactionRelationScore.new()
    FactionManager.relation_scores[B][A] = FactionRelationScore.new()
    FactionManager.relation_scores[A][C] = FactionRelationScore.new()
    FactionManager.relation_scores[B][C] = FactionRelationScore.new()
    FactionManager.relation_scores[C][A] = FactionRelationScore.new()
    FactionManager.relation_scores[C][B] = FactionRelationScore.new()

    # high heat A<->B + neutral trust to mediator
    FactionManager.relation_scores[A][B].tension = 80
    FactionManager.relation_scores[B][A].tension = 80
    FactionManager.relation_scores[A][B].grievance = 70
    FactionManager.relation_scores[B][A].grievance = 70
    FactionManager.relation_scores[A][C].trust = 50
    FactionManager.relation_scores[B][C].trust = 50
    FactionManager.relation_scores[C][A].trust = 50
    FactionManager.relation_scores[C][B].trust = 50

    # --- create mediation QuestInstance and register as ACTIVE ---
    var template = QuestTemplate.new()
    template.id = &"tp.mediation"
    template.title = "Mediation"
    template.description = "Test mediation 3 factions"
    template.category = QuestTypes.QuestCategory.ARC
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
    QuestManager.start_runtime_quest(inst)

    # --- capture before ---
    var tension_before :float = FactionManager.relation_scores[A][B].tension
    var trust_a_c_before :float = FactionManager.relation_scores[A][C].trust

    # --- act ---
    # LOYAL attempt but should fail due to roll
    QuestManager.resolve_quest(inst.runtime_id, &"LOYAL")

    # --- assertions: deltas applied ---
    _assert(FactionManager.relation_scores[A][B].tension > tension_before, "tension(A→B) should increase after failed mediation (before=%d after=%d)" % [tension_before, FactionManager.relation_scores[A][B].tension])
    _assert(FactionManager.relation_scores[A][C].trust < trust_a_c_before, "trust(A→C) should decrease after failed mediation (before=%d after=%d)" % [trust_a_c_before, FactionManager.relation_scores[A][C].trust])

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
    ArcManagerRunner.arc_notebook = prev_arc_notebook

func _find_first_root_node(names: Array) -> Node:
    for n in names:
        var node = get_node_or_null("/root/" + String(n))
        if node != null:
            return node
    return null
