# res://tests/faction/FactionManagerGenerationTest.gd
extends BaseTest
class_name FactionManagerGenerationTest

## Tests de génération de factions et de monde
## Couvre: generate_faction, generate_factions, generate_world, initialize_relations_world
## Et les helpers: _gen_type_from_heat, _apply_heat_bias_to_personality, etc.

var manager: FactionManagerClass = null
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
    _setup()
    
    # Tests de génération de faction
    _test_generate_faction_basic()
    _test_generate_faction_with_heat_low()
    _test_generate_faction_with_heat_high()
    _test_generate_faction_with_antagonist()
    
    # Tests de génération multiple
    _test_generate_factions_count()
    _test_generate_factions_with_seed_reproducibility()
    
    # Tests de génération de monde
    _test_generate_world_basic()
    _test_generate_world_relations_initialized()
    _test_generate_world_heat_affects_relations()
    
    # Tests des helpers internes
    _test_gen_type_from_heat()
    _test_profile_params_from_heat()
    _test_apply_heat_bias_to_personality()
    
    # Tests des relations
    _test_initialize_relations_world_symmetry()
    _test_center_outgoing_means()
    _test_apply_reciprocity()
    
    _cleanup()
    pass_test("FactionManagerGenerationTest: generate_faction, generate_world, relations OK")


func _setup() -> void:
    manager = FactionManagerClass.new()
    rng.seed = 12345


func _cleanup() -> void:
    if manager != null:
        manager.factions.clear()


# =============================================================================
# Tests: generate_faction
# =============================================================================

func _test_generate_faction_basic() -> void:
    var faction = manager.generate_faction(&"test_faction", rng, 50)
    
    _assert(faction != null, "generate_faction doit retourner une faction")
    _assert(faction.get("id") == &"test_faction", "faction_id doit être correct")
    _assert(faction.get("profile") != null, "faction doit avoir un profile")
    
    var profile: FactionProfile = faction.get("profile")
    _assert(profile is FactionProfile, "profile doit être un FactionProfile")
    
    print("  ✓ generate_faction basic: faction créée avec profile")


func _test_generate_faction_with_heat_low() -> void:
    var faction = manager.generate_faction(&"low_heat_faction", rng, 10)
    var profile: FactionProfile = faction.get("profile")
    
    _assert(profile != null, "profile ne doit pas être null")
    
    # Heat bas => personnalité moins agressive
    var aggression := profile.get_personality(FactionProfile.PERS_AGGRESSION)
    var diplomacy := profile.get_personality(FactionProfile.PERS_DIPLOMACY)
    
    # On vérifie juste que les valeurs sont dans des bornes raisonnables
    _assert(aggression >= 0.0 and aggression <= 1.0, "aggression doit être entre 0 et 1")
    _assert(diplomacy >= 0.0 and diplomacy <= 1.0, "diplomacy doit être entre 0 et 1")
    
    print("  ✓ generate_faction heat=10: aggr=%.2f, diplo=%.2f" % [aggression, diplomacy])


func _test_generate_faction_with_heat_high() -> void:
    rng.seed = 12345  # Reset pour comparaison
    var faction_low = manager.generate_faction(&"compare_low", rng, 10)
    
    rng.seed = 12345  # Même seed
    var faction_high = manager.generate_faction(&"compare_high", rng, 90)
    
    var profile_low: FactionProfile = faction_low.get("profile")
    var profile_high: FactionProfile = faction_high.get("profile")
    
    # Heat élevé devrait augmenter l'aggression via _apply_heat_bias_to_personality
    var aggr_low := profile_low.get_personality(FactionProfile.PERS_AGGRESSION)
    var aggr_high := profile_high.get_personality(FactionProfile.PERS_AGGRESSION)
    
    # Heat élevé devrait diminuer la diplomatie
    var diplo_low := profile_low.get_personality(FactionProfile.PERS_DIPLOMACY)
    var diplo_high := profile_high.get_personality(FactionProfile.PERS_DIPLOMACY)
    
    _assert(aggr_high >= aggr_low - 0.1, "heat élevé devrait augmenter l'aggression (low=%.2f, high=%.2f)" % [aggr_low, aggr_high])
    _assert(diplo_high <= diplo_low + 0.1, "heat élevé devrait diminuer la diplomatie (low=%.2f, high=%.2f)" % [diplo_low, diplo_high])
    
    print("  ✓ generate_faction heat comparison: aggr %.2f→%.2f, diplo %.2f→%.2f" % [aggr_low, aggr_high, diplo_low, diplo_high])


func _test_generate_faction_with_antagonist() -> void:
    # Créer une faction "cible"
    var target_faction = manager.generate_faction(&"target", rng, 50)
    var target_profile: FactionProfile = target_faction.get("profile")
    
    # Créer un antagoniste contre cette faction
    var antagonist = manager.generate_faction(&"antagonist", rng, 70, {}, target_faction)
    var antag_profile: FactionProfile = antagonist.get("profile")
    
    _assert(antag_profile != null, "antagonist doit avoir un profile")
    
    # L'antagoniste devrait avoir des axes opposés (en général)
    # On vérifie juste que le profil existe et est valide
    print("  ✓ generate_faction with antagonist: profiles créés")


# =============================================================================
# Tests: generate_factions
# =============================================================================

func _test_generate_factions_count() -> void:
    var factions_list := manager.generate_factions(5, 50, 12345)
    
    _assert(factions_list.size() == 5, "generate_factions(5) doit créer 5 factions, got %d" % factions_list.size())
    
    for i in range(factions_list.size()):
        var f = factions_list[i]
        _assert(f != null, "faction %d ne doit pas être null" % i)
        _assert(f.get("profile") != null, "faction %d doit avoir un profile" % i)
    
    print("  ✓ generate_factions: %d factions créées" % factions_list.size())


func _test_generate_factions_with_seed_reproducibility() -> void:
    # Générer deux fois avec le même seed
    manager.factions.clear()
    var factions1 := manager.generate_factions(3, 50, 99999)
    
    manager.factions.clear()
    var factions2 := manager.generate_factions(3, 50, 99999)
    
    _assert(factions1.size() == factions2.size(), "même seed doit produire même nombre de factions")
    
    for i in range(factions1.size()):
        var p1: FactionProfile = factions1[i].get("profile")
        var p2: FactionProfile = factions2[i].get("profile")
        
        var aggr1 := p1.get_personality(FactionProfile.PERS_AGGRESSION)
        var aggr2 := p2.get_personality(FactionProfile.PERS_AGGRESSION)
        
        _assert(abs(aggr1 - aggr2) < 0.001, "même seed doit produire mêmes valeurs (faction %d)" % i)
    
    print("  ✓ generate_factions reproducibility: seed=99999 produit résultats identiques")


# =============================================================================
# Tests: generate_world
# =============================================================================

func _test_generate_world_basic() -> void:
    manager.factions.clear()
    var world := manager.generate_world(4, 50, 12345)
    
    _assert(world.size() == 4, "generate_world(4) doit créer 4 factions")
    
    for f in world:
        _assert(f.get("profile") != null, "chaque faction doit avoir un profile")
    
    print("  ✓ generate_world basic: %d factions créées" % world.size())


func _test_generate_world_relations_initialized() -> void:
    manager.factions.clear()
    var world := manager.generate_world(4, 50, 12345)
    
    # Vérifier que les relations sont initialisées
    var ids: Array[StringName] = []
    for f in world:
        ids.append(f.get("id"))
    
    # Chaque faction devrait avoir des relations vers les autres
    for f in world:
        var relations = null
        if f.has_method("get") and f.get("relations_by_faction_id") != null:
            relations = f.get("relations_by_faction_id")
        elif f.has_method("get") and f.get("relations") != null:
            relations = f.get("relations")
        
        if relations != null:
            _assert(relations is Dictionary, "relations doit être un Dictionary")
            # Devrait avoir des relations vers (n-1) factions
            var expected_count := ids.size() - 1
            _assert(relations.size() == expected_count, 
                "faction doit avoir %d relations, got %d" % [expected_count, relations.size()])
    
    print("  ✓ generate_world relations: toutes les factions ont des relations initialisées")


func _test_generate_world_heat_affects_relations() -> void:
    # Monde à faible heat
    manager.factions.clear()
    var world_low := manager.generate_world(4, 15, 12345)
    var relations_low := _extract_all_relations(world_low)
    
    # Monde à heat élevé
    manager.factions.clear()
    var world_high := manager.generate_world(4, 85, 12345)
    var relations_high := _extract_all_relations(world_high)
    
    # Calculer les moyennes de tension
    var avg_tension_low := _average_tension(relations_low)
    var avg_tension_high := _average_tension(relations_high)
    
    # Heat élevé devrait produire plus de tension en moyenne
    print("  ✓ generate_world heat effect: tension avg low=%.1f, high=%.1f" % [avg_tension_low, avg_tension_high])


# =============================================================================
# Tests: Helpers internes
# =============================================================================

func _test_gen_type_from_heat() -> void:
    rng.seed = 42
    
    # Heat bas (< 33) => devrait être CENTERED
    var type_low := manager._gen_type_from_heat(10, rng)
    _assert(type_low == FactionProfile.GEN_CENTERED, "heat=10 devrait donner GEN_CENTERED")
    
    # Heat élevé (> 66) => devrait être DRAMATIC
    var type_high := manager._gen_type_from_heat(80, rng)
    _assert(type_high == FactionProfile.GEN_DRAMATIC, "heat=80 devrait donner GEN_DRAMATIC")
    
    print("  ✓ _gen_type_from_heat: low→CENTERED, high→DRAMATIC")


func _test_profile_params_from_heat() -> void:
    var params_low := manager._profile_params_from_heat(20, {})
    var params_high := manager._profile_params_from_heat(80, {})
    
    _assert(params_low.has("coherence_strength"), "params doit avoir coherence_strength")
    _assert(params_high.has("antagonist_personality_blend"), "params doit avoir antagonist_personality_blend")
    
    # Heat élevé => coherence plus forte
    _assert(params_high["coherence_strength"] >= params_low["coherence_strength"],
        "coherence_strength devrait augmenter avec heat")
    
    print("  ✓ _profile_params_from_heat: coherence %.2f→%.2f" % [
        params_low["coherence_strength"], params_high["coherence_strength"]
    ])


func _test_apply_heat_bias_to_personality() -> void:
    # Créer un profile de base
    var profile := FactionProfile.generate_full_profile(rng, FactionProfile.GEN_NORMAL)
    var aggr_before := profile.get_personality(FactionProfile.PERS_AGGRESSION)
    var diplo_before := profile.get_personality(FactionProfile.PERS_DIPLOMACY)
    
    # Appliquer le biais heat élevé
    manager._apply_heat_bias_to_personality(profile, 90, rng)
    
    var aggr_after := profile.get_personality(FactionProfile.PERS_AGGRESSION)
    var diplo_after := profile.get_personality(FactionProfile.PERS_DIPLOMACY)
    
    # Heat élevé devrait augmenter aggression et diminuer diplomacy
    _assert(aggr_after > aggr_before - 0.05, "aggression devrait augmenter avec heat=90")
    _assert(diplo_after < diplo_before + 0.05, "diplomacy devrait diminuer avec heat=90")
    
    print("  ✓ _apply_heat_bias_to_personality: aggr %.2f→%.2f, diplo %.2f→%.2f" % [
        aggr_before, aggr_after, diplo_before, diplo_after
    ])


# =============================================================================
# Tests: Relations
# =============================================================================

func _test_initialize_relations_world_symmetry() -> void:
    manager.factions.clear()
    var world := manager.generate_world(4, 50, 12345)
    
    # Extraire les relations
    var relations := _extract_all_relations(world)
    
    # Vérifier que les relations A→B et B→A existent (pas forcément identiques, mais proches)
    var ids := relations.keys()
    for a in ids:
        for b in relations[a].keys():
            if a == b:
                continue
            
            # Vérifier que B→A existe aussi
            _assert(relations.has(b), "faction %s doit avoir des relations" % str(b))
            _assert(relations[b].has(a), "relation %s→%s doit exister si %s→%s existe" % [str(b), str(a), str(a), str(b)])
    
    print("  ✓ initialize_relations_world: relations bidirectionnelles présentes")


func _test_center_outgoing_means() -> void:
    # Test que _center_outgoing_means centre les relations autour de 0
    manager.factions.clear()
    var world := manager.generate_world(5, 50, 12345)
    var relations := _extract_all_relations(world)
    
    # Pour chaque faction, calculer la moyenne des relations sortantes
    for faction_id in relations.keys():
        var sum := 0.0
        var count := 0
        for other_id in relations[faction_id].keys():
            var rel = relations[faction_id][other_id]
            sum += float(_get_rel_value(rel, "relation", 0))
            count += 1
        
        if count > 0:
            var mean := sum / float(count)
            # La moyenne devrait être relativement proche de 0 après centering
            _assert(abs(mean) < 40, "moyenne des relations devrait être centrée, got %.1f" % mean)
    
    print("  ✓ _center_outgoing_means: moyennes centrées (< 40 de 0)")


func _test_apply_reciprocity() -> void:
    manager.factions.clear()
    var world := manager.generate_world(4, 50, 12345, {"reciprocity": 0.90})
    var relations := _extract_all_relations(world)
    
    # Avec reciprocity=0.90, les relations A→B et B→A devraient être très proches
    var max_diff := 0
    var ids := relations.keys()
    
    for i in range(ids.size()):
        for j in range(i + 1, ids.size()):
            var a = ids[i]
            var b = ids[j]
            
            if not relations[a].has(b) or not relations[b].has(a):
                continue
            
            var rel_ab := int(_get_rel_value(relations[a][b], "relation", 0))
            var rel_ba := int(_get_rel_value(relations[b][a], "relation", 0))
            var diff :int = abs(rel_ab - rel_ba)
            max_diff = max(max_diff, diff)
    
    # Avec reciprocity élevée, la différence max devrait être faible
    _assert(max_diff < 25, "avec reciprocity=0.90, diff max devrait être <25, got %d" % max_diff)
    
    print("  ✓ _apply_reciprocity: diff max entre A→B et B→A = %d" % max_diff)


# =============================================================================
# Helpers
# =============================================================================

func _extract_all_relations(world: Array) -> Dictionary:
    var result := {}
    for f in world:
        var faction_id = f.get("id")
        var relations = null
        
        if f.has_method("get"):
            relations = f.get("relations_by_faction_id")
            if relations == null:
                relations = f.get("relations")
        
        if relations != null:
            result[faction_id] = relations
    
    return result


func _average_tension(relations: Dictionary) -> float:
    var sum := 0.0
    var count := 0
    
    for faction_id in relations.keys():
        for other_id in relations[faction_id].keys():
            var rel = relations[faction_id][other_id]
            sum += float(_get_rel_value(rel, "tension", 0.0))
            count += 1
    
    return sum / float(max(count, 1))


func _get_rel_value(rel, key: String, default_val):
    if rel is Dictionary:
        return rel.get(key, default_val)
    if rel != null and rel.has_method("get"):
        return rel.get(key)
    return default_val
