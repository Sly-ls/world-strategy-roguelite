extends BaseTest
class_name KnowledgeRumorDebunkHeatTest

func _ready() -> void:
    _test_two_rumors_then_debunk_reduces_heat_below_threshold()
    pass_test("\n✅ KnowledgeRumorDebunkHeatTest: OK\n")


func _test_two_rumors_then_debunk_reduces_heat_below_threshold() -> void:
    var knowledge := FactionKnowledgeModel.new()

    var A := &"A"
    var B := &"B"
    var C := &"C"

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
    faction_c.name = "Faction " + C
    FactionManager.register_faction(faction_c)

    # high heat A<->B + neutral trust to mediator
    # Profiles: B is more parano than diplomate => believes rumors more
    faction_b.profile.set_personality(FactionProfile.PERS_PARANOIA, 0.7)
    faction_b.profile.set_personality(FactionProfile.PERS_DIPLOMACY, 0.3)
    faction_b.profile.set_personality(FactionProfile.PERS_INTEL, 0.5)

    # Minimal relations (used by apply_knowledge_resolution)
    faction_b.get_relation_to(A).set_score(FactionRelationScore.REL_TRUST, 40)
    faction_b.get_relation_to(A).set_score(FactionRelationScore.REL_TENSION, 10)
    faction_b.get_relation_to(A).set_score(FactionRelationScore.REL_GRIEVANCE, 5)
    faction_b.get_relation_to(A).set_score(FactionRelationScore.REL_RELATION, 0)
    
    # 1) Fact : le vrai raid est C -> B (jour 1)
    knowledge.register_fact({
        "id": &"evt_1",
        "day": 1,
        "type": &"RAID",
        "true_actor": C,
        "true_target": B,
        "severity": 1.0
    })

    # 2) Rumor #1 : "A a raid B" (jour 2) -> observateur = B
    knowledge.inject_rumor({
        "id": &"rum_1",
        "day": 2,
        "seed_id": C,
        "claim_actor": A,
        "claim_target": B,
        "claim_type": &"RAID",
        "strength": 0.7,
        "credibility": 0.55,
        "malicious": true,
        "related_event_id": &"evt_1"
    }, [B])

    var heat_after_1 := knowledge.get_perceived_heat(B, A, 2)

    # 3) Rumor #2 : même claim (jour 3) -> renforce la croyance
    knowledge.inject_rumor({
        "id": &"rum_2",
        "day": 3,
        "seed_id": &"BROKER",
        "claim_actor": A,
        "claim_target": B,
        "claim_type": &"RAID",
        "strength": 0.65,
        "credibility": 0.55,
        "malicious": true,
        "related_event_id": &"evt_1"
    }, [B])

    var heat_after_2 := knowledge.get_perceived_heat(B, A, 3)

    _assert(heat_after_2 > heat_after_1, "heat should increase after 2nd rumor (%.1f -> %.1f)" % [heat_after_1, heat_after_2])

    # Seuil “ArcManager déclencherait un incident”
    var INCIDENT_THRESHOLD := 25.0
    _assert(heat_after_2 >= INCIDENT_THRESHOLD, "after 2 rumors, heat should be high enough to trigger incident (heat=%.1f)" % heat_after_2)

    # 4) Debunk via INVESTIGATE LOYAL (jour 4) : comme true_actor=C, claim(A) est faux => confidence baisse
    knowledge.apply_knowledge_resolution({
        "observer_id": B,
        "claimed_actor": A,
        "claimed_target": B,
        "claim_type": &"RAID",
        "knowledge_action": &"INVESTIGATE",
        "related_event_id": &"evt_1",
        "day": 4
    }, &"LOYAL", 4)

    var heat_after_debunk := knowledge.get_perceived_heat(B, A, 4)

    _assert(heat_after_debunk < heat_after_2, "heat should drop after debunk (%.1f -> %.1f)" % [heat_after_2, heat_after_debunk])
    _assert(heat_after_debunk < INCIDENT_THRESHOLD, "debunk should drop heat below incident threshold (heat=%.1f)" % heat_after_debunk)

    # Donc : ArcManager/compute_arc_event_chance, basé sur perceived_heat, ne déclenche plus “naturellement” l’escalade.
