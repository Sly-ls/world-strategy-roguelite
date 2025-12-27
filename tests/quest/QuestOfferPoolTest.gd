# res://test/quest/QuestOfferPoolTest.gd
extends BaseTest
class_name QuestOfferPoolTest

## Test du pool d'offres de quêtes sur 100 jours
## Vérifie: cap global, validité des offres, pas de doublons

const MAX_OFFERS_CAP := 20
const SIMULATION_DAYS := 100
const OFFERS_PER_DAY := 5


func _ready() -> void:
    if QuestPool == null:
        fail_test("QuestPool autoload manquant")
        return
    
    if not QuestPool.has_method("get_offers"):
        fail_test("QuestPool.get_offers() introuvable")
        return
    
    
    FactionManager.generate_world(5)
    var ids = FactionManager.get_all_faction_ids()
    var ATTACKER_FACTION = ids[0]
    var DEFENDER_FACTION = ids[1]
    
    _test_offers_100_days_simulation()
    
    pass_test("QuestOfferPoolTest: 100 jours simulés, cap=%d respecté, aucune offre invalide, aucun doublon" % MAX_OFFERS_CAP)


# =============================================================================
# Test: Simulation 100 jours
# =============================================================================
func _test_offers_100_days_simulation() -> void:
    var max_seen: int = 0
    var total_offers_created: int = 0
    var total_offers_expired: int = 0
    
    for day in range(SIMULATION_DAYS):
        _set_day(day)
        
        # Créer des offres
        for i in range(OFFERS_PER_DAY):
            var quest: QuestInstance = QuestGenerator.generate_random_quest(QuestTypes.QuestTier.TIER_1)
            if quest != null:
                if not quest.context.has("quest_type"):
                    quest.context["quest_type"] = "generated"
                QuestPool.try_add_offer(quest)
                total_offers_created += 1
        
        # Cleanup des offres expirées
        if QuestPool.has_method("cleanup_offers"):
            QuestPool.cleanup_offers()
        
        var offers: Array = QuestPool.get_offers()
        max_seen = max(max_seen, offers.size())
        
        # Invariant 1: Cap global
        _assert(offers.size() <= MAX_OFFERS_CAP, 
            "Cap global dépassé: %d offres au jour %d (max=%d)" % [offers.size(), day, MAX_OFFERS_CAP])
        
        # Invariant 2: Toutes les offres sont valides
        for offer in offers:
            var qi: QuestInstance = offer
            _assert(qi != null, "Offre null dans le pool au jour %d" % day)
            
            if qi.has_method("is_offer_valid"):
                _assert(qi.is_offer_valid(day), 
                    "Offre invalide détectée jour %d: %s" % [day, _get_offer_signature(qi)])
        
        # Invariant 3: Pas de doublons de signature
        var seen_signatures: Dictionary = {}
        for offer in offers:
            var qi: QuestInstance = offer
            var sig: String = _get_offer_signature(qi)
            _assert(not seen_signatures.has(sig), 
                "Doublon de signature jour %d: %s" % [day, sig])
            seen_signatures[sig] = true
    
    print("  ✓ %d jours simulés" % SIMULATION_DAYS)
    print("  ✓ %d offres créées au total" % total_offers_created)
    print("  ✓ Max offres simultanées: %d (cap=%d)" % [max_seen, MAX_OFFERS_CAP])
    print("  ✓ Aucune offre invalide détectée")
    print("  ✓ Aucun doublon de signature détecté")


# =============================================================================
# Helpers
# =============================================================================
func _set_day(day: int) -> void:
    if WorldState != null and "current_day" in WorldState:
        WorldState.current_day = day


func _get_offer_signature(qi: QuestInstance) -> String:
    if qi.has_method("get_offer_signature"):
        return qi.get_offer_signature()
    # Fallback: construire une signature basique
    var template_id := qi.template.id if qi.template != null else "unknown"
    var giver := str(qi.context.get("giver_faction_id", ""))
    return "%s|%s" % [template_id, giver]
