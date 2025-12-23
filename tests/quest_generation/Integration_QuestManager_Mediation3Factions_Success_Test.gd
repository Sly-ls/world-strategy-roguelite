# tests/Integration_QuestManager_Mediation3Factions_Success_Test.gd
extends BaseTest
class_name Integration_QuestManager_Mediation3Factions_Success_Test

func _ready() -> void:
    _test_resolve_quest_mediation_success_logs_and_inverse_deltas()
    pass_test("\n✅ Integration_QuestManager_Mediation3Factions_Success_Test: OK\n")


func _test_resolve_quest_mediation_success_logs_and_inverse_deltas() -> void:
    _assert(ClassDB.class_exists("QuestOutcomeUtil"), "QuestOutcomeUtil must exist")
    _assert(ClassDB.class_exists("ArcFailureConsequences"), "ArcFailureConsequences must exist")
    _assert(ClassDB.class_exists("QuestInstance"), "QuestInstance must exist")
    _assert(ClassDB.class_exists("QuestTemplate"), "QuestTemplate must exist")

    _assert(QuestManager != null, "Missing /root QuestManagerRunner (or QuestManager)")
    _assert(ArcManagerRunner != null, "Missing /root/ArcManagerRunner")
    _assert(FactionManager != null, "Missing /root/FactionManager")

    # --- patch notebook ---
    var prev_arc_notebook: ArcNotebook = ArcManagerRunner.arc_notebook
    var notebook: ArcNotebook = ArcNotebook.new()
    ArcManagerRunner.arc_notebook = notebook

    # --- backup existing relation_scores ---
    var prev_relation_scores: Dictionary = FactionManager.get_all_relations().duplicate(true)

    var A := &"A"
    var B := &"B"
    var C := &"C"  # mediator

    # --- setup test relations in FactionManager.relation_scores ---
    # Structure: relation_scores[from_id][to_id, FactionRelationScore
    FactionManager.set_relation(A, B, FactionRelationScore.new(B))
    FactionManager.set_relation(B, A, FactionRelationScore.new(A))
    FactionManager.set_relation(A, C, FactionRelationScore.new(C))
    FactionManager.set_relation(B, C, FactionRelationScore.new(C))
    FactionManager.set_relation(C, A, FactionRelationScore.new(A))
    FactionManager.set_relation(C, B, FactionRelationScore.new(B))

    # baseline: conflict moderate, mediator trust neutral
    var relation_to_change : FactionRelationScore = FactionManager.get_relation_score(A,B)
    relation_to_change.tension = 45
    relation_to_change.grievance = 25
    FactionManager.set_relation(A,B, relation_to_change)
    relation_to_change = FactionManager.get_relation_score(B, A)
    relation_to_change.tension = 45
    relation_to_change.grievance = 25
    FactionManager.set_relation(B, A, relation_to_change)
    relation_to_change = FactionManager.get_relation_score(A, C)
    relation_to_change.grievance = 25
    relation_to_change.trust = 50
    FactionManager.set_relation(A, C, relation_to_change)
    relation_to_change = FactionManager.get_relation_score(B, C)
    relation_to_change.trust = 50
    FactionManager.set_relation(B, C, relation_to_change)
    relation_to_change = FactionManager.get_relation_score(C, A)
    relation_to_change.trust = 50
    FactionManager.set_relation(C, A, relation_to_change)
    relation_to_change = FactionManager.get_relation_score(C, B)
    relation_to_change.trust = 50
    FactionManager.set_relation(C, B, relation_to_change)

    # --- quest instance mediation 3 factions ---
    var template = QuestTemplate.new()
    template.id = &"tp.mediation"
    template.title = "Mediation"
    template.description = "Test mediation SUCCESS"
    template.category = QuestTypes.QuestCategory.ARC
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
    inst.status = QuestTypes.QuestStatus.ACTIVE
    inst.started_on_day = 10
    inst.expires_on_day = 17

    # add to active quests
    QuestManager.start_runtime_quest(inst)

    var tension_before: int = FactionManager.relation_scores[A][B].tension
    var trust_a_c_before: int = FactionManager.relation_scores[A][C].trust

    # --- act ---
    QuestManager.resolve_quest(inst.runtime_id, &"LOYAL")

    # --- status should be COMPLETED (not FAILED) ---
    _assert(inst.status == QuestTypes.QuestStatus.COMPLETED, "quest status should be COMPLETED (got %s)" % str(inst.status))

    # optional: should be removed from active_quests
    if "active_quests" in QuestManager:
        _assert(not QuestManager.active_quests.has(inst.runtime_id), "quest should be removed from active_quests after resolve")

    # --- inverse deltas: tension down, trust to mediator up ---
    _assert(FactionManager.relation_scores[A][B].tension < tension_before, 
        "tension(A→B) should decrease on successful mediation (before=%d after=%d)" % [
            tension_before, FactionManager.relation_scores[A][B].tension
        ])
    _assert(FactionManager.relation_scores[A][C].trust > trust_a_c_before, 
        "trust(A→C) should increase on successful mediation (before=%d after=%d)" % [
            trust_a_c_before, FactionManager.relation_scores[A][C].trust
        ])

    # --- ArcNotebook meta: outcome/chance/roll ---
    # Note: Les événements tripartites (médiation) sont dans triplet_events
    var found := false
    for e in notebook.triplet_events:
        if StringName(e.get("action", &"")) == &"tp.mediation":
            var meta: Dictionary = e.get("meta", {})
            _assert(StringName(meta.get("outcome", &"")) == &"SUCCESS", "notebook meta.outcome should be SUCCESS")
            _assert(meta.has("chance") and meta.has("roll"), "notebook meta should include chance + roll")
            _assert(float(meta["roll"]) == 0.02, "notebook roll should match forced roll (0.02)")
            _assert(float(meta["chance"]) > float(meta["roll"]), 
                "chance should be > roll to justify success (chance=%.3f roll=%.3f)" % [
                    float(meta["chance"]), float(meta["roll"])
                ])
            found = true
            break
    _assert(found, "expected a triplet_event for tp.mediation in ArcNotebook")

    # --- restore ---
    ArcManagerRunner.arc_notebook = prev_arc_notebook
    FactionManager.relation_scores = prev_relation_scores
