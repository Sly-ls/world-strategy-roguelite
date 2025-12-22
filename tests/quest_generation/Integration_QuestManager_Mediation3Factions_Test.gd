extends BaseTest
class_name Integration_QuestManager_Mediation3Factions_Test


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

    # Build relations for A, B, C
    var A := &"A"
    var B := &"B"
    var C := &"C"  # mediator

    # --- Créer les factions de test ---
    var faction_a := Faction.new()
    faction_a.id = "A"
    faction_a.name = "Faction A"
    FactionManager.factions["A"] = faction_a

    var faction_b := Faction.new()
    faction_b.id = "B"
    faction_b.name = "Faction B"
    FactionManager.factions["B"] = faction_b

    var faction_c := Faction.new()
    faction_c.id = "C"
    faction_c.name = "Faction C (Mediator)"
    FactionManager.factions["C"] = faction_c

    # --- Initialiser les relations dans Faction.relations ---
    # A -> B, A -> C
    faction_a.relations["B"] = FactionRelationScore.new(B)
    faction_a.relations["C"] = FactionRelationScore.new(C)
    
    # B -> A, B -> C
    faction_b.relations["A"] = FactionRelationScore.new(A)
    faction_b.relations["C"] = FactionRelationScore.new(C)
    
    # C -> A, C -> B
    faction_c.relations["A"] = FactionRelationScore.new(A)
    faction_c.relations["B"] = FactionRelationScore.new(B)

    # high heat A<->B + neutral trust to mediator
    faction_a.relations["B"].tension = 80
    faction_b.relations["A"].tension = 80
    faction_a.relations["B"].grievance = 70
    faction_b.relations["A"].grievance = 70
    
    faction_a.relations["C"].trust = 50
    faction_b.relations["C"].trust = 50
    faction_c.relations["A"].trust = 50
    faction_c.relations["B"].trust = 50

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
    var tension_before: float = faction_a.relations["B"].tension
    var trust_a_c_before: float = faction_a.relations["C"].trust

    # --- act ---
    # LOYAL attempt but should fail due to roll
    QuestManager.resolve_quest(inst.runtime_id, &"LOYAL")

    # --- assertions: deltas applied ---
    _assert(faction_a.relations["B"].tension > tension_before, 
        "tension(A→B) should increase after failed mediation (before=%d after=%d)" % [
            tension_before, faction_a.relations["B"].tension
        ])
    _assert(faction_a.relations["C"].trust < trust_a_c_before, 
        "trust(A→C) should decrease after failed mediation (before=%d after=%d)" % [
            trust_a_c_before, faction_a.relations["C"].trust
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

    # --- cleanup: remove test factions ---
    FactionManager.factions.erase("A")
    FactionManager.factions.erase("B")
    FactionManager.factions.erase("C")
    
    # --- restore patched state ---
    ArcManagerRunner.arc_notebook = prev_arc_notebook


func _find_first_root_node(names: Array) -> Node:
    for n in names:
        var node = get_node_or_null("/root/" + String(n))
        if node != null:
            return node
    return null
