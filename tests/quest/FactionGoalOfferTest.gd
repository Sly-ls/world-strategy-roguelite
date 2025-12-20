# res://test/quest/FactionGoalOfferTest.gd
extends BaseTest
class_name FactionGoalOfferTest

## Test de génération d'offres liées aux goals de faction
## Vérifie: goal domain=corruption, step=gather, contexte correct


func _ready() -> void:
    if QuestPool == null:
        fail_test("QuestPool autoload manquant")
        return
    
    if QuestOfferSimRunner == null:
        fail_test("QuestOfferSimRunner autoload manquant")
        return
    
    if not QuestOfferSimRunner.has_method("generate_goal_offer"):
        fail_test("QuestOfferSimRunner.generate_goal_offer() introuvable")
        return
    
    _test_goal_offer_domain_corruption()
    
    pass_test("FactionGoalOfferTest: goal offer corruption/gather créée avec contexte correct")


# =============================================================================
# Test: Goal Offer Domain
# =============================================================================
func _test_goal_offer_domain_corruption() -> void:
    # Clear existing offers
    if QuestPool.has_method("get_offers"):
        QuestPool.get_offers().clear()
    if "offer_created_day" in QuestOfferSimRunner:
        QuestOfferSimRunner.offer_created_day.clear()
    
    # Créer un goal de faction
    var goal = FactionGoalFactory.create_build_domain_goal("orcs", "corruption")
    _assert(goal != null, "FactionGoalFactory.create_build_domain_goal() ne doit pas retourner null")
    
    # Enregistrer le goal
    if FactionGoalManagerRunner != null and "active_goals" in FactionGoalManagerRunner:
        FactionGoalManagerRunner.active_goals["orcs"] = FactionGoalState.new(goal)
    
    # Générer l'offre
    QuestOfferSimRunner.generate_goal_offer("orcs", "", "corruption", "gather")
    
    # Vérifier qu'une offre a été créée
    var offers: Array = QuestPool.get_offers()
    _assert(not offers.is_empty(), "Au moins une offre doit être créée")
    
    # Trouver l'offre goal
    var found_offer: QuestInstance = null
    for offer in offers:
        var ctx: Dictionary = offer.context
        if not ctx.get("is_goal_offer", false):
            continue
        if ctx.get("goal_step_id", "") != "gather":
            continue
        if ctx.get("goal_domain", "") != "corruption":
            continue
        found_offer = offer
        break
    
    _assert(found_offer != null, "Offre gather/corruption non trouvée")
    
    # Vérifier le contexte
    var ctx: Dictionary = found_offer.context
    _assert(ctx.get("is_goal_offer", false) == true, "is_goal_offer doit être true")
    _assert(ctx.get("goal_step_id", "") == "gather", "goal_step_id doit être 'gather'")
    _assert(ctx.get("goal_domain", "") == "corruption", "goal_domain doit être 'corruption'")
    _assert(ctx.get("giver_faction_id", "") == "orcs", "giver_faction_id doit être 'orcs'")
    
    print("  ✓ Goal offer créée: %s" % found_offer.template.title)
    print("  ✓ Contexte: giver=%s, domain=%s, step=%s" % [
        ctx.get("giver_faction_id", ""),
        ctx.get("goal_domain", ""),
        ctx.get("goal_step_id", "")
    ])
