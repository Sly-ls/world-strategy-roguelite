extends BaseTest
class_name Integration_QuestManager_Mediation3Factions_Test


func _ready() -> void:
    _test_resolve_quest_mediation_3f_roll_forced_logs_and_deltas()
    pass_test("✅ Integration_QuestManager_Mediation3Factions_Test: OK")


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

    # Build relations for A, B, C
    var A := &"A"
    var B := &"B"
    var C := &"C"  # mediator

    # --- Créer les factions de test ---
    var faction_a :Faction = Faction.new()
    faction_a.id = A
    faction_a.name = "Faction " + A
    FactionManager.register_faction(faction_a)

    var faction_b :Faction = Faction.new()
    faction_b.id = B
    faction_b.name = "Faction " + B
    FactionManager.register_faction(faction_b)

    var faction_c :Faction = Faction.new()
    faction_c.id = C
    faction_c.name = "Faction " + C + " (Mediator)"
    FactionManager.register_faction(faction_c)

    # high heat A<->B + neutral trust to mediator
    faction_a.get_relation_to(B).set_score(FactionRelationScore.REL_TENSION, 80)
    faction_b.get_relation_to(A).set_score(FactionRelationScore.REL_TENSION, 80)
    faction_a.get_relation_to(B).set_score(FactionRelationScore.REL_GRIEVANCE, 70)
    faction_b.get_relation_to(A).set_score(FactionRelationScore.REL_GRIEVANCE, 70)
    
    faction_a.get_relation_to(C).set_score(FactionRelationScore.REL_TRUST, 50)
    faction_b.get_relation_to(C).set_score(FactionRelationScore.REL_TRUST, 50)
    faction_c.get_relation_to(A).set_score(FactionRelationScore.REL_TRUST, 50)
    faction_c.get_relation_to(B).set_score(FactionRelationScore.REL_TRUST, 50)

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
    var tension_before: float = faction_a.get_relation_to(B).get_score(FactionRelationScore.REL_TENSION)
    var trust_a_c_before: float = faction_a.get_relation_to(C).get_score(FactionRelationScore.REL_TRUST)

    # --- act ---
    # LOYAL attempt but should fail due to roll
    QuestManager.resolve_quest(inst.runtime_id, &"LOYAL")

    var tension_after: float = faction_a.get_relation_to(B).get_score(FactionRelationScore.REL_TENSION)
    var trust_a_c_after: float = faction_a.get_relation_to(C).get_score(FactionRelationScore.REL_TRUST)
    # --- assertions: deltas applied ---
    _assert(tension_after > tension_before, 
        "tension(A→B) should increase after failed mediation (before=%d after=%d)" % [
            tension_before, tension_after
        ])
    _assert(trust_a_c_after < trust_a_c_before, 
        "trust(A→C) should decrease after failed mediation (before=%d after=%d)" % [
            trust_a_c_before, trust_a_c_after
        ])

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

func _find_first_root_node(names: Array) -> Node:
    for n in names:
        var node = get_node_or_null("/root/" + String(n))
        if node != null:
            return node
    return null
