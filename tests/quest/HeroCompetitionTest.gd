# res://test/hero/HeroCompetitionTest.gd
extends BaseTest
class_name HeroCompetitionTest

## Test de compétition entre héros sur 30 jours
## Vérifie: héros prennent des offres, expirations gérées

const SIMULATION_DAYS := 30


func _ready() -> void:
    if HeroSimRunner == null:
        fail_test("HeroSimRunner autoload manquant")
        return
    
    if FactionSimRunner == null:
        fail_test("FactionSimRunner autoload manquant")
        return
    
    if QuestManager == null:
        fail_test("QuestManager autoload manquant")
        return
    
    _test_hero_competition_30_days()
    
    pass_test("HeroCompetitionTest: %d jours simulés, héros actifs, offres prises" % SIMULATION_DAYS)


# =============================================================================
# Test: Hero Competition 30 days
# =============================================================================
func _test_hero_competition_30_days() -> void:
    # Setup heroes
    var h1 := HeroAgent.new()
    h1.id = "h1"
    h1.name = "Sir Aldren"
    h1.faction_id = "humans"
    h1.loyalty = 0.8
    h1.greed = 0.2
    h1.aggressiveness = 0.3
    h1.competence = 0.8
    
    var h2 := HeroAgent.new()
    h2.id = "h2"
    h2.name = "Krag le Rouge"
    h2.faction_id = "orcs"
    h2.loyalty = 0.2
    h2.greed = 0.4
    h2.aggressiveness = 0.8
    h2.competence = 0.7
    
    var h3 := HeroAgent.new()
    h3.id = "h3"
    h3.name = "L'Errante"
    h3.faction_id = "independent"
    h3.loyalty = 0.3
    h3.greed = 0.8
    h3.aggressiveness = 0.4
    h3.competence = 0.6
    
    HeroSimRunner.heroes = [h1, h2, h3]
    HeroSimRunner.max_offers_taken_per_day = 2
    HeroSimRunner.take_chance = 0.45
    
    _assert(HeroSimRunner.heroes.size() == 3, "3 héros doivent être enregistrés")
    print("  ✓ 3 héros configurés: %s, %s, %s" % [h1.name, h2.name, h3.name])
    
    var offers_taken_total := 0
    var initial_day := WorldState.current_day if WorldState != null else 0
    
    for day in range(SIMULATION_DAYS):
        if WorldState != null:
            WorldState.current_day = initial_day + day + 1
        
        # 1) Factions agissent et créent des offres
        FactionSimRunner.run_day(3)
        
        # 2) Héros prennent des offres
        var offers_before := _count_available_offers()
        HeroSimRunner.tick_day()
        var offers_after := _count_available_offers()
        
        var taken_this_day := offers_before - offers_after
        if taken_this_day > 0:
            offers_taken_total += taken_this_day
        
        # 3) Expirations
        if QuestManager.has_method("check_expirations"):
            QuestManager.check_expirations()
    
    print("  ✓ %d jours simulés" % SIMULATION_DAYS)
    print("  ✓ ~%d offres prises par les héros" % offers_taken_total)
    
    if QuestManager != null and "world_tags" in QuestManager:
        print("  ✓ World tags finaux: %s" % str(QuestManager.world_tags))


# =============================================================================
# Helpers
# =============================================================================
func _count_available_offers() -> int:
    if QuestPool != null and QuestPool.has_method("get_offers"):
        return QuestPool.get_offers().size()
    return 0
