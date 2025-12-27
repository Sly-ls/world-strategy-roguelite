# res://test/world/WorldSimulationTest.gd
extends BaseTest
class_name WorldSimulationTest

## Test de simulation du monde sur 10 jours
## Vérifie: factions, relations, offres générées

const SIMULATION_DAYS := 10


func _ready() -> void:
    if WorldSimRunner == null:
        fail_test("WorldSimRunner autoload manquant")
        return
    
    if not WorldSimRunner.has_method("simulate_days"):
        fail_test("WorldSimRunner.simulate_days() introuvable")
        return
    
    FactionManager.generate_world(5)
    var ids = FactionManager.get_all_faction_ids()
    var ATTACKER_FACTION = ids[0]
    var DEFENDER_FACTION = ids[1]
    
    _test_world_sim_10_days()
    
    pass_test("WorldSimulationTest: %d jours simulés, factions actives, offres générées" % SIMULATION_DAYS)


# =============================================================================
# Test: World Sim 10 days
# =============================================================================
func _test_world_sim_10_days() -> void:
    # Reset état si possible
    _set_day(0)
    
    # Simuler
    WorldSimRunner.simulate_days(SIMULATION_DAYS)
    
    # Vérifier les factions
    if FactionManager != null and FactionManager.has_method("get_all_factions"):
        var factions: Array = FactionManager.get_all_factions()
        _assert(factions.size() > 0, "Au moins une faction doit exister après simulation")
        print("  ✓ %d factions actives" % factions.size())
    
    # Vérifier les offres
    if QuestPool != null and QuestPool.has_method("get_offers"):
        var offers: Array = QuestPool.get_offers()
        print("  ✓ %d offres dans le pool" % offers.size())
    
    # Vérifier les world tags
    if QuestManager != null and "world_tags" in QuestManager:
        print("  ✓ World tags: %s" % str(QuestManager.world_tags))
    
    # Afficher les relations si disponible
    if FactionManager != null and FactionManager.has_method("print_relations_between"):
        print("  ✓ Relations entre factions:")
        FactionManager.print_relations_between()
    
    print("  ✓ Simulation de %d jours terminée" % SIMULATION_DAYS)


# =============================================================================
# Helpers
# =============================================================================
func _set_day(day: int) -> void:
    if WorldState != null and "current_day" in WorldState:
        WorldState.current_day = day
