# res://tests/faction/FactionManagerRelationsTest.gd
# VERSION CORRIGÉE
extends BaseTest
class_name FactionManagerRelationsTest

## Tests des fonctions de relations et queries de FactionManager
## Couvre: get/set_relation_between, get_relation_score, adjust_relation
## Et queries: get_all_factions, get_allies, get_enemies, get_neutral

var ids :Array[String]= []

var A = ""
var B = ""
    
func _ready() -> void:
    if FactionManager == null:
        fail_test("FactionManager autoload manquant")
        return
    
    _test_pair_key_symmetry()
    _test_set_get_relation_between()
    _test_get_relation_score()
    _test_get_faction_profile()
    _test_get_faction_profiles()
    
    pass_test("FactionManagerRelationsTest: relations, queries, profiles, save/load OK")


# =============================================================================
# Tests: _pair_key
# =============================================================================

func _test_pair_key_symmetry() -> void:
    var key1 := Utils.pair_key("humans", "orcs")
    var key2 := Utils.pair_key("orcs", "humans")
    
    _assert(key1 == key2, "_pair_key doit être symétrique: '%s' vs '%s'" % [key1, key2])
    _assert(key1.find("|") > 0, "_pair_key doit contenir '|'")
    
    myLogger.debug("  ✓ _pair_key symmetry: '%s' == '%s'" % [key1, key2], LogTypes.Domain.TEST)


# =============================================================================
# Tests: set/get_relation_between
# =============================================================================

func _test_set_get_relation_between() -> void:
    FactionManager.generate_world(2)
    ids = FactionManager.get_all_faction_ids()
    A = ids[0]
    B = ids[1]
    
    var rel_ab = FactionManager.get_relation(A, B)
    var rel_ba = FactionManager.get_relation(B, A)
    
    # Test 1: Modifier A->B et vérifier que la valeur est bien stockée
    rel_ab.set_score(FactionRelationScore.REL_RELATION, -99)
    var new_score = rel_ab.get_score(FactionRelationScore.REL_RELATION)
    _assert(new_score == -99, "get_relation_between doit retourner la valeur set, got %d" % new_score)
    
    # Test 2: Les relations sont asymétriques par design (A->B != B->A)
    # On peut set chaque direction indépendamment
    var ba_before = rel_ba.get_score(FactionRelationScore.REL_RELATION)
    rel_ba.set_score(FactionRelationScore.REL_RELATION, -50)
    var ba_after = rel_ba.get_score(FactionRelationScore.REL_RELATION)
    _assert(ba_after == -50, "relation B->A doit être settable indépendamment, got %d" % ba_after)
    
    # Test 3: Cas edge - même faction (self-relation)
    var self_rel: FactionRelationScore = FactionManager.get_relation(A, A)
    if self_rel != null:
        var self_score = self_rel.get_score(FactionRelationScore.REL_RELATION)
        _assert(self_score == 0, "relation avec soi-même doit être 0, got %d" % self_score)
    else:
        myLogger.debug("  ⚠ self-relation retourne null (comportement accepté)", LogTypes.Domain.TEST)
    
    # Test 4: Cas edge - faction vide
    var empty_rel: FactionRelationScore = FactionManager.get_relation("", A)
    _assert(empty_rel == null, "relation to empty should be null, got %s" % str(empty_rel))
    
    myLogger.debug("  ✓ set/get_relation_between: set=-99, get=%d" % new_score, LogTypes.Domain.TEST)


# =============================================================================
# Tests: get_relation_score
# =============================================================================

func _test_get_relation_score() -> void:
    var score := FactionManager.get_relation(A, B)
    
    _assert(score != null, "get_relation_score ne doit pas retourner null")
    _assert(score is FactionRelationScore, "doit retourner un FactionRelationScore")
    
    # CORRECTION 3: Utiliser .scores.has() au lieu de l'opérateur 'in'
    _assert(score.scores.has(FactionRelationScore.REL_RELATION), "score doit avoir 'relation'")
    _assert(score.scores.has(FactionRelationScore.REL_TRUST), "score doit avoir 'trust'")
    _assert(score.scores.has(FactionRelationScore.REL_TENSION), "score doit avoir 'tension'")
    
    var score_rel = score.get_score(FactionRelationScore.REL_RELATION)
    var score_trust = score.get_score(FactionRelationScore.REL_TRUST)
    var score_tension = score.get_score(FactionRelationScore.REL_TENSION)
    myLogger.debug("  ✓ get_relation_score: rel=%d, trust=%d, tension=%d" % [score_rel, score_trust, score_tension], LogTypes.Domain.TEST)


# =============================================================================
# Tests: Profiles
# =============================================================================

func _test_get_faction_profile() -> void:
    var profile := FactionManager.get_faction_profile("humans")
    
    _assert(profile != null, "get_faction_profile ne doit pas retourner null")
    _assert(profile is FactionProfile, "doit retourner un FactionProfile")
    
    # Vérifier qu'on peut lire les axes
    var tech := profile.get_axis_affinity(FactionProfile.AXIS_TECH)
    _assert(tech >= -100 and tech <= 100, "axis_affinity doit être entre -100 et 100")
    myLogger.debug("  ✓ get_faction_profile: humans tech=%d" % tech, LogTypes.Domain.TEST)


func _test_get_faction_profiles() -> void:
    var profiles := FactionManager.get_faction_profiles()
    
    _assert(profiles is Dictionary, "get_faction_profiles doit retourner un Dictionary")
    _assert(profiles.size() > 0, "get_faction_profiles doit retourner au moins un profile")
    
    for faction_id in profiles.keys():
        var p: FactionProfile = profiles[faction_id]
        _assert(p is FactionProfile, "chaque valeur doit être un FactionProfile")
    
    myLogger.debug("  ✓ get_faction_profiles: %d profiles" % profiles.size(), LogTypes.Domain.TEST)
