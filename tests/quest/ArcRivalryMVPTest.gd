# res://test/arc/ArcRivalryMVPTest.gd
extends BaseTest
class_name ArcRivalryMVPTest

## Test MVP du système de rivalité entre factions
## Vérifie: action hostile → offre arc → résolution → retaliation

var ATTACKER_FACTION := "elves"
var DEFENDER_FACTION := "humans"
var ids :Array[String]= []
    
func _ready() -> void:
    if ArcManagerRunner == null:
        fail_test("ArcManagerRunner autoload manquant")
        return
    
    if not ArcManagerRunner.has_method("on_faction_hostile_action"):
        fail_test("ArcManagerRunner.on_faction_hostile_action() introuvable")
        return
    
    if QuestPool == null:
        fail_test("QuestPool autoload manquant")
        return
    
    if QuestManager == null:
        fail_test("QuestManager autoload manquant")
        return
    
    _setup()
    _test_hostile_action_creates_arc_offer()
    _test_resolution_triggers_retaliation()
    
    pass_test("ArcRivalryMVPTest: hostile action → arc offer → LOYAL resolution → retaliation offer")


func _setup() -> void:
    # Reset
    if QuestPool.has_method("clear_offers"):
        QuestPool.clear_offers()
    elif "offers" in QuestPool:
        QuestPool.offers.clear()
    
    if ArcManagerRunner.has_method("reset"):
        ArcManagerRunner.reset()
    
    FactionManager.generate_world(2)
    ids = FactionManager.get_all_faction_ids()
    ATTACKER_FACTION = ids[0]
    DEFENDER_FACTION = ids[1]
    
    _set_day(0)


# =============================================================================
# Test 1: Hostile action creates arc offer
# =============================================================================
func _test_hostile_action_creates_arc_offer() -> void:
    # Action hostile
    ArcManagerRunner.on_faction_hostile_action(ATTACKER_FACTION, DEFENDER_FACTION, "RAID")
    
    # Récupérer les offres
    var offers: Array = _get_offers()
    _assert(not offers.is_empty(), "Une offre doit être générée après action hostile")
    
    # Trouver l'offre arc
    var arc_offer: QuestInstance = null
    for offer in offers:
        var ctx: Dictionary = offer.context
        if bool(ctx.get("is_arc_rivalry", false)):
            arc_offer = offer
            break
    
    _assert(arc_offer != null, "Une offre arc rivalry doit exister")
    
    var ctx: Dictionary = arc_offer.context
    _assert(ctx.get("giver_faction_id", "") == ATTACKER_FACTION, 
        "giver_faction_id doit être %s" % ATTACKER_FACTION)
    _assert(ctx.get("antagonist_faction_id", "") == DEFENDER_FACTION, 
        "antagonist_faction_id doit être %s" % DEFENDER_FACTION)
    _assert(ctx.has("arc_id"), "context doit avoir arc_id")
    _assert(ctx.has("arc_stage"), "context doit avoir arc_stage")
    
    print("  ✓ Action hostile %s → %s crée une offre arc" % [ATTACKER_FACTION, DEFENDER_FACTION])
    print("  ✓ Arc offer: %s (stage=%s)" % [arc_offer.template.title, ctx.get("arc_stage", "")])


# =============================================================================
# Test 2: Resolution triggers retaliation
# =============================================================================
func _test_resolution_triggers_retaliation() -> void:
    # Récupérer l'offre arc
    var offers: Array = _get_offers()
    var arc_offer: QuestInstance = null
    for offer in offers:
        if bool(offer.context.get("is_arc_rivalry", false)):
            arc_offer = offer
            break
    
    _assert(arc_offer != null, "Offre arc doit exister pour test retaliation")
    
    # Démarrer la quête
    QuestManager.start_runtime_quest(arc_offer)
    _assert(arc_offer.runtime_id != "", "runtime_id doit être assigné")
    
    # Compléter la quête
    if QuestManager.has_method("complete_quest"):
        QuestManager.complete_quest(arc_offer.runtime_id)
    elif QuestManager.has_method("update_quest_progress_by_id"):
        var count := int(arc_offer.template.objective_count)
        QuestManager.update_quest_progress_by_id(arc_offer.runtime_id, count)
    
    # Résoudre LOYAL
    QuestManager.resolve_quest(arc_offer.runtime_id, "LOYAL")
    print("  ✓ Quête résolue LOYAL")
    
    # Avancer d'un jour et tick
    _set_day(1)
    if ArcManagerRunner.has_method("tick_day"):
        ArcManagerRunner.tick_day()
    
    # Vérifier qu'une offre de retaliation existe
    var offers_after: Array = _get_offers()
    var retaliation_found := false
    
    for offer in offers_after:
        var ctx: Dictionary = offer.context
        if not bool(ctx.get("is_arc_rivalry", false)):
            continue
        # Retaliation: giver=defender, antagonist=attacker (inversé)
        if ctx.get("giver_faction_id", "") == DEFENDER_FACTION and ctx.get("antagonist_faction_id", "") == ATTACKER_FACTION:
            retaliation_found = true
            print("  ✓ Retaliation offer trouvée: %s → %s" % [DEFENDER_FACTION, ATTACKER_FACTION])
            break
    
    _assert(retaliation_found, "Offre de retaliation doit être générée (giver=%s, ant=%s)" % [DEFENDER_FACTION, ATTACKER_FACTION])


# =============================================================================
# Helpers
# =============================================================================
func _set_day(day: int) -> void:
    if WorldState != null and "current_day" in WorldState:
        WorldState.current_day = day


func _get_offers() -> Array:
    if QuestPool.has_method("get_offers"):
        return QuestPool.get_offers()
    elif "offers" in QuestPool:
        return QuestPool.offers
    return []
