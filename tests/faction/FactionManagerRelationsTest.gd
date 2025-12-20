# res://tests/faction/FactionManagerRelationsTest.gd
extends BaseTest
class_name FactionManagerRelationsTest

## Tests des fonctions de relations et queries de FactionManager
## Couvre: get/set_relation_between, get_relation_score, adjust_relation
## Et queries: get_all_factions, get_allies, get_enemies, get_neutral


func _ready() -> void:
    if FactionManager == null:
        fail_test("FactionManager autoload manquant")
        return
    
    _test_pair_key_symmetry()
    _test_set_get_relation_between()
    _test_get_relation_score()
    _test_adjust_relation()
    _test_get_all_factions()
    _test_get_allies_enemies_neutral()
    _test_get_faction_profile()
    _test_get_faction_profiles()
    _test_save_load_state()
    
    pass_test("FactionManagerRelationsTest: relations, queries, profiles, save/load OK")


# =============================================================================
# Tests: _pair_key
# =============================================================================

func _test_pair_key_symmetry() -> void:
    var key1 := Utils.pair_key("humans", "orcs")
    var key2 := Utils.pair_key("orcs", "humans")
    
    _assert(key1 == key2, "_pair_key doit être symétrique: '%s' vs '%s'" % [key1, key2])
    _assert(key1.find("|") > 0, "_pair_key doit contenir '|'")
    
    print("  ✓ _pair_key symmetry: '%s' == '%s'" % [key1, key2])


# =============================================================================
# Tests: set/get_relation_between
# =============================================================================

func _test_set_get_relation_between() -> void:
    # Sauvegarder l'état actuel
    var old_val := FactionManager.get_relation_between("humans", "orcs")
    
    # Modifier
    FactionManager.set_relation_between("humans", "orcs", -99)
    var new_val := FactionManager.get_relation_between("humans", "orcs")
    _assert(new_val == -99, "get_relation_between doit retourner la valeur set, got %d" % new_val)
    
    # Vérifier symétrie
    var reverse_val := FactionManager.get_relation_between("orcs", "humans")
    _assert(reverse_val == -99, "relation doit être symétrique, got %d" % reverse_val)
    
    # Cas edge: même faction
    var self_val := FactionManager.get_relation_between("humans", "humans")
    _assert(self_val == 0, "relation avec soi-même doit être 0, got %d" % self_val)
    
    # Cas edge: faction vide
    var empty_val := FactionManager.get_relation_between("", "humans")
    _assert(empty_val == 0, "relation avec faction vide doit être 0, got %d" % empty_val)
    
    # Restaurer
    FactionManager.set_relation_between("humans", "orcs", old_val)
    
    print("  ✓ set/get_relation_between: set=-99, get=%d, symmetric=%d" % [new_val, reverse_val])


# =============================================================================
# Tests: get_relation_score
# =============================================================================

func _test_get_relation_score() -> void:
    var score := FactionManager.get_relation_score("humans", "orcs")
    
    _assert(score != null, "get_relation_score ne doit pas retourner null")
    _assert(score is FactionRelationScore, "doit retourner un FactionRelationScore")
    
    # Vérifier les propriétés de base
    _assert("relation" in score, "score doit avoir 'relation'")
    _assert("trust" in score, "score doit avoir 'trust'")
    _assert("tension" in score, "score doit avoir 'tension'")
    
    print("  ✓ get_relation_score: rel=%d, trust=%d, tension=%d" % [
        score.relation, score.trust, score.tension
    ])


# =============================================================================
# Tests: adjust_relation (avec le joueur)
# =============================================================================

func _test_adjust_relation() -> void:
    var faction := FactionManager.get_faction("humans")
    if faction == null:
        print("  ⚠ faction 'humans' introuvable, test ignoré")
        return
    
    var old_rel := faction.relation_with_player
    
    # Ajuster positivement
    FactionManager.adjust_relation("humans", 10)
    var after_plus := faction.relation_with_player
    _assert(after_plus == old_rel + 10, "adjust_relation(+10) doit ajouter 10, got %d" % after_plus)
    
    # Ajuster négativement
    FactionManager.adjust_relation("humans", -10)
    var after_minus := faction.relation_with_player
    _assert(after_minus == old_rel, "adjust_relation(-10) doit revenir à %d, got %d" % [old_rel, after_minus])
    
    print("  ✓ adjust_relation: %d → %d → %d" % [old_rel, after_plus, after_minus])


# =============================================================================
# Tests: Queries
# =============================================================================

func _test_get_all_factions() -> void:
    var all := FactionManager.get_all_factions()
    
    _assert(all is Array, "get_all_factions doit retourner un Array")
    _assert(all.size() > 0, "get_all_factions doit retourner au moins une faction")
    
    for f in all:
        _assert(f is Faction, "chaque élément doit être une Faction")
        _assert(f.id != "", "chaque faction doit avoir un id")
    
    print("  ✓ get_all_factions: %d factions" % all.size())


func _test_get_allies_enemies_neutral() -> void:
    var allies := FactionManager.get_allies()
    var enemies := FactionManager.get_enemies()
    var neutral := FactionManager.get_neutral()
    
    _assert(allies is Array, "get_allies doit retourner un Array")
    _assert(enemies is Array, "get_enemies doit retourner un Array")
    _assert(neutral is Array, "get_neutral doit retourner un Array")
    
    # Vérifier que chaque faction est dans exactement une catégorie
    var all := FactionManager.get_all_factions()
    var categorized := allies.size() + enemies.size() + neutral.size()
    
    _assert(categorized == all.size(), 
        "toutes les factions doivent être catégorisées: %d vs %d" % [categorized, all.size()])
    
    # Vérifier les catégories
    for f in allies:
        _assert(f.is_ally(), "faction dans allies doit être alliée: %s" % f.id)
    
    for f in enemies:
        _assert(f.is_enemy(), "faction dans enemies doit être ennemie: %s" % f.id)
    
    for f in neutral:
        _assert(f.is_neutral(), "faction dans neutral doit être neutre: %s" % f.id)
    
    print("  ✓ get_allies/enemies/neutral: %d/%d/%d" % [allies.size(), enemies.size(), neutral.size()])


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
    
    print("  ✓ get_faction_profile: humans tech=%d" % tech)


func _test_get_faction_profiles() -> void:
    var profiles := FactionManager.get_faction_profiles()
    
    _assert(profiles is Dictionary, "get_faction_profiles doit retourner un Dictionary")
    _assert(profiles.size() > 0, "get_faction_profiles doit retourner au moins un profile")
    
    for faction_id in profiles.keys():
        var p: FactionProfile = profiles[faction_id]
        _assert(p is FactionProfile, "chaque valeur doit être un FactionProfile")
    
    print("  ✓ get_faction_profiles: %d profiles" % profiles.size())


# =============================================================================
# Tests: Save/Load State
# =============================================================================

func _test_save_load_state() -> void:
    # Modifier une relation
    var faction := FactionManager.get_faction("humans")
    if faction == null:
        print("  ⚠ faction 'humans' introuvable, test ignoré")
        return
    
    var original_rel := faction.relation_with_player
    faction.relation_with_player = 77
    
    # Sauvegarder
    var saved := FactionManager.save_state()
    
    _assert(saved is Dictionary, "save_state doit retourner un Dictionary")
    _assert(saved.has("humans"), "saved state doit contenir 'humans'")
    
    # Modifier à nouveau
    faction.relation_with_player = -50
    
    # Charger
    FactionManager.load_state(saved)
    
    _assert(faction.relation_with_player == 77, 
        "load_state doit restaurer la relation: expected 77, got %d" % faction.relation_with_player)
    
    # Restaurer l'original
    faction.relation_with_player = original_rel
    
    print("  ✓ save/load_state: relation sauvegardée et restaurée")
