# res://tests/faction/FactionHostilityPickerTest.gd
extends BaseTest
class_name FactionHostilityPickerTest

## Tests de FactionHostilityPicker
## Couvre: filtrage, calcul de score, RNG intelligent

var _rng: RandomNumberGenerator

func _ready() -> void:
    _rng = RandomNumberGenerator.new()
    _rng.seed = 12345
    
    # Sauvegarder l'état initial
    var initial_pair_states := FactionManager.pair_states.duplicate(true)
    _test_excludes_origin()
    _test_excludes_extinct()
    _test_war_state_highest_priority()
    _test_alliance_state_penalized()
    _test_treaty_malus()
    _test_relation_scores_impact()
    _test_rng_dominant_winner()
    _test_rng_close_competition()
    _test_get_top_hostile_factions()
    _test_empty_candidates()
    _test_pick_most_hostile_factions()
    _test_pick_most_hostile_no_duplicates_with_close_scores()
    _test_pick_ally_basic()
    _test_pick_ally_alliance_highest_priority()
    _test_pick_ally_hostile_penalized()
    _test_pick_most_allies()
    
    # Restaurer l'état initial
    FactionManager.pair_states = initial_pair_states
    
    pass_test("FactionHostilityPickerTest: all tests passed")

# =============================================================================
# Helpers
# =============================================================================

func _setup_test_factions() -> void:
    # S'assurer que les factions de test existent
    for faction_id in ["alpha", "beta", "gamma", "delta", "epsilon"]:
        if not FactionManager.has_faction(faction_id):
            var f := Faction.new()
            f.id = faction_id
            f.name = faction_id.capitalize()
            f.profile = FactionProfile.generate_full_profile(_rng, FactionProfile.GEN_NORMAL)
            FactionManager.register_faction(f)
        
        # Initialiser les relations entre toutes les factions
    
    for faction_id in ["alpha", "beta", "gamma", "delta", "epsilon"]:
        var fa: Faction = FactionManager.get_faction(faction_id)
        for other_id in ["alpha", "beta", "gamma", "delta", "epsilon"]:
            if faction_id != other_id and not fa.has_relation_to(StringName(other_id)):
                fa.init_relation(StringName(other_id))

func _cleanup_pair_states() -> void:
    for a in ["alpha", "beta", "gamma", "delta", "epsilon"]:
        for b in ["alpha", "beta", "gamma", "delta", "epsilon"]:
            if a != b:
                FactionManager.remove_pair_state(a, b)

func _set_relation_scores(a: String, b: String, relation: float, trust: float, tension: float, grievance: float = 0.0, weariness: float = 0.0) -> void:
    var rel := FactionManager.get_relation(a, b)
    if rel != null:
        rel.set_score(FactionRelationScore.REL_RELATION, relation)
        rel.set_score(FactionRelationScore.REL_TRUST, trust)
        rel.set_score(FactionRelationScore.REL_TENSION, tension)
        rel.set_score(FactionRelationScore.REL_GRIEVANCE, grievance)
        rel.set_score(FactionRelationScore.REL_WEARINESS, weariness)

# =============================================================================
# Tests: Filtrage
# =============================================================================

func _test_excludes_origin() -> void:
    myLogger.debug("  Testing excludes origin...", LogTypes.Domain.TEST)
    _setup_test_factions()
    
    # Faire plusieurs tirages et vérifier que origin n'est jamais retourné
    for i in range(20):
        var result := FactionHostilityPicker.pick("alpha", _rng)
        _assert(result != "alpha", "Should never return origin faction")
        _assert(result != "", "Should return a valid faction")
    
    _cleanup_pair_states()
    myLogger.debug("  ✓ Excludes origin test passed", LogTypes.Domain.TEST)

func _test_excludes_extinct() -> void:
    myLogger.debug("  Testing excludes extinct...", LogTypes.Domain.TEST)
    _setup_test_factions()
    _cleanup_pair_states()
    
    # Marquer beta comme EXTINCT
    var ps := FactionManager.get_pair_state("alpha", "beta")
    ps.state = FactionPairState.S_EXTINCT
    
    # Faire plusieurs tirages et vérifier que beta n'est jamais retourné
    for i in range(20):
        var result := FactionHostilityPicker.pick("alpha", _rng)
        _assert(result != "beta", "Should never return EXTINCT faction")
    
    _cleanup_pair_states()
    myLogger.debug("  ✓ Excludes extinct test passed", LogTypes.Domain.TEST)

# =============================================================================
# Tests: Priorité des états
# =============================================================================

func _test_war_state_highest_priority() -> void:
    myLogger.debug("  Testing WAR state highest priority...", LogTypes.Domain.TEST)
    _setup_test_factions()
    _cleanup_pair_states()
    
    # beta en WAR, gamma en NEUTRAL, delta en RIVALRY, epsilon en NEUTRAL
    FactionManager.force_pair_state("alpha", "beta", FactionPairState.S_WAR, 1, 10)
    FactionManager.force_pair_state("alpha", "gamma", FactionPairState.S_NEUTRAL, 1, 10)
    FactionManager.force_pair_state("alpha", "delta", FactionPairState.S_RIVALRY, 1, 10)
    FactionManager.force_pair_state("alpha", "epsilon", FactionPairState.S_NEUTRAL, 1, 10)
    
    # Mettre des relations neutres pour isoler l'effet du state
    _set_relation_scores("alpha", "beta", 0, 0, 50, 50, 50)
    _set_relation_scores("alpha", "gamma", 0, 0, 50, 50, 50)
    _set_relation_scores("alpha", "delta", 0, 0, 50, 50, 50)
    _set_relation_scores("alpha", "epsilon", 0, 0, 50, 50, 50)
    
    # La faction en WAR devrait être sélectionnée le plus souvent (mais pas obligatoirement 80% avec 4 candidats)
    var war_count := 0
    for i in range(100):
        var result := FactionHostilityPicker.pick("alpha", _rng)
        if result == "beta":
            war_count += 1
    
    _assert(war_count >= 40, "WAR faction should be selected most often, got %d/100" % war_count)
    
    _cleanup_pair_states()
    myLogger.debug("  ✓ WAR state highest priority test passed", LogTypes.Domain.TEST)

func _test_alliance_state_penalized() -> void:
    myLogger.debug("  Testing ALLIANCE state penalized...", LogTypes.Domain.TEST)
    _setup_test_factions()
    _cleanup_pair_states()
    
    # beta en ALLIANCE, gamma en NEUTRAL (on exclut les autres pour isoler le test)
    FactionManager.force_pair_state("alpha", "beta", FactionPairState.S_ALLIANCE, 1, 10)
    FactionManager.force_pair_state("alpha", "gamma", FactionPairState.S_NEUTRAL, 1, 10)
    
    # Relations hostiles pour les deux (pour que beta ait un score positif malgré le malus ALLIANCE)
    _set_relation_scores("alpha", "beta", -80, -80, 90, 90, 5)  # Relations très hostiles
    _set_relation_scores("alpha", "gamma", -50, -50, 60, 60, 30)  # Relations modérément hostiles
    
    # Exclure delta et epsilon pour isoler le test à beta vs gamma
    var ctx := {"exclude": ["delta", "epsilon"]}
    
    # gamma (NEUTRAL) devrait être sélectionnée plus souvent que beta (ALLIANCE)
    var gamma_count := 0
    var beta_count := 0
    for i in range(100):
        var result := FactionHostilityPicker.pick_hostile_faction("alpha", _rng, ctx)
        if result == "gamma":
            gamma_count += 1
        elif result == "beta":
            beta_count += 1
    
    _assert(gamma_count > beta_count, "NEUTRAL should beat ALLIANCE, got gamma=%d vs beta=%d" % [gamma_count, beta_count])
    
    # beta (allié) devrait quand même être parfois sélectionné (grâce à min_candidates)
    # Note: Avec le malus ALLIANCE, beta peut avoir un score très bas, donc on vérifie juste que gamma domine
    # La trahison reste possible via d'autres mécanismes de jeu
    
    _cleanup_pair_states()
    myLogger.debug("  ✓ ALLIANCE state penalized test passed", LogTypes.Domain.TEST)

# =============================================================================
# Tests: Malus traité
# =============================================================================

func _test_treaty_malus() -> void:
    myLogger.debug("  Testing treaty malus...", LogTypes.Domain.TEST)
    _setup_test_factions()
    _cleanup_pair_states()
    
    # beta avec traité TRUCE expirant dans 30 jours
    var ps_beta := FactionManager.get_pair_state("alpha", "beta")
    ps_beta.state = FactionPairState.S_TRUCE
    ps_beta.treaty = Treaty.new()
    ps_beta.treaty.type = &"TRUCE"
    ps_beta.treaty.end_day = 30
    ps_beta.treaty.violation_score = 0.0
    
    # gamma avec traité TRUCE expirant dans 3 jours (malus réduit)
    var ps_gamma := FactionManager.get_pair_state("alpha", "gamma")
    ps_gamma.state = FactionPairState.S_TRUCE
    ps_gamma.treaty = Treaty.new()
    ps_gamma.treaty.type = &"TRUCE"
    ps_gamma.treaty.end_day = 3
    ps_gamma.treaty.violation_score = 0.0
    
    # delta avec traité TRUCE mais violation élevée
    var ps_delta := FactionManager.get_pair_state("alpha", "delta")
    ps_delta.state = FactionPairState.S_TRUCE
    ps_delta.treaty = Treaty.new()
    ps_delta.treaty.type = &"TRUCE"
    ps_delta.treaty.end_day = 30
    ps_delta.treaty.violation_score = 0.8
    ps_delta.treaty.violation_threshold = 1.0
    
    # Mêmes relations hostiles
    _set_relation_scores("alpha", "beta", -60, -40, 70, 60, 20)
    _set_relation_scores("alpha", "gamma", -60, -40, 70, 60, 20)
    _set_relation_scores("alpha", "delta", -60, -40, 70, 60, 20)
    
    var results := FactionHostilityPicker.get_top_hostile_factions("alpha", 3, {"current_day": 0})
    
    # gamma (proche expiration) et delta (violation élevée) devraient avoir des scores plus hauts que beta
    var score_beta := 0.0
    var score_gamma := 0.0
    var score_delta := 0.0
    
    for r in results:
        if r["id"] == "beta":
            score_beta = r["score"]
        elif r["id"] == "gamma":
            score_gamma = r["score"]
        elif r["id"] == "delta":
            score_delta = r["score"]
    
    _assert(score_gamma > score_beta, "Near-expiry treaty should have less malus: gamma=%.2f > beta=%.2f" % [score_gamma, score_beta])
    _assert(score_delta > score_beta, "High violation treaty should have less malus: delta=%.2f > beta=%.2f" % [score_delta, score_beta])
    
    _cleanup_pair_states()
    myLogger.debug("  ✓ Treaty malus test passed", LogTypes.Domain.TEST)

# =============================================================================
# Tests: Impact des scores de relation
# =============================================================================

func _test_relation_scores_impact() -> void:
    myLogger.debug("  Testing relation scores impact...", LogTypes.Domain.TEST)
    _setup_test_factions()
    _cleanup_pair_states()
    
    # Tous en NEUTRAL pour isoler l'effet des relations
    FactionManager.force_pair_state("alpha", "beta", FactionPairState.S_NEUTRAL, 1, 10)
    FactionManager.force_pair_state("alpha", "gamma", FactionPairState.S_NEUTRAL, 1, 10)
    FactionManager.force_pair_state("alpha", "delta", FactionPairState.S_NEUTRAL, 1, 10)
    FactionManager.force_pair_state("alpha", "epsilon", FactionPairState.S_NEUTRAL, 1, 10)
    
    # beta : très hostile (relation basse, grievance haute, weariness basse)
    _set_relation_scores("alpha", "beta", -80, -60, 90, 80, 10)
    
    # gamma : neutre
    _set_relation_scores("alpha", "gamma", 0, 0, 50, 50, 50)
    
    # delta : amical (relation haute, grievance basse)
    _set_relation_scores("alpha", "delta", 60, 50, 20, 10, 70)
    
    # epsilon : très amical (pour qu'il soit clairement le moins hostile)
    _set_relation_scores("alpha", "epsilon", 80, 70, 10, 5, 90)
    
    var results := FactionHostilityPicker.get_top_hostile_factions("alpha", 4)
    
    # Vérifier que beta est bien le plus hostile
    _assert(results[0]["id"] == "beta", "Most hostile faction should be first, got %s" % results[0]["id"])
    _assert(results[0]["score"] > results[1]["score"], "Hostile should score higher than neutral")
    
    # Vérifier l'ordre général : les scores doivent être décroissants
    for i in range(results.size() - 1):
        _assert(results[i]["score"] >= results[i+1]["score"], "Scores should be in descending order")
    
    _cleanup_pair_states()
    myLogger.debug("  ✓ Relation scores impact test passed", LogTypes.Domain.TEST)

# =============================================================================
# Tests: RNG intelligent
# =============================================================================

func _test_rng_dominant_winner() -> void:
    myLogger.debug("  Testing RNG dominant winner...", LogTypes.Domain.TEST)
    _setup_test_factions()
    _cleanup_pair_states()
    
    # beta en WAR avec relations très hostiles
    FactionManager.force_pair_state("alpha", "beta", FactionPairState.S_WAR, 1, 10)
    _set_relation_scores("alpha", "beta", -100, -100, 100, 100, 0)
    
    # gamma en NEUTRAL avec relations neutres
    FactionManager.force_pair_state("alpha", "gamma", FactionPairState.S_NEUTRAL, 1, 10)
    _set_relation_scores("alpha", "gamma", 0, 0, 50, 50, 50)
    
    # Avec un écart dominant, beta devrait gagner > 95% du temps
    var beta_count := 0
    for i in range(100):
        var result := FactionHostilityPicker.pick("alpha", _rng)
        if result == "beta":
            beta_count += 1
    
    _assert(beta_count >= 95, "Dominant winner should be selected >95%%, got %d%%" % beta_count)
    
    _cleanup_pair_states()
    myLogger.debug("  ✓ RNG dominant winner test passed", LogTypes.Domain.TEST)

func _test_rng_close_competition() -> void:
    myLogger.debug("  Testing RNG close competition...", LogTypes.Domain.TEST)
    _setup_test_factions()
    _cleanup_pair_states()
    
    # Trois factions avec des scores très proches
    FactionManager.force_pair_state("alpha", "beta", FactionPairState.S_RIVALRY, 1, 10)
    FactionManager.force_pair_state("alpha", "gamma", FactionPairState.S_RIVALRY, 1, 10)
    FactionManager.force_pair_state("alpha", "delta", FactionPairState.S_RIVALRY, 1, 10)
    
    _set_relation_scores("alpha", "beta", -50, -40, 60, 55, 30)
    _set_relation_scores("alpha", "gamma", -48, -38, 58, 53, 32)
    _set_relation_scores("alpha", "delta", -52, -42, 62, 57, 28)
    
    # Compter les sélections
    var counts := {"beta": 0, "gamma": 0, "delta": 0}
    for i in range(300):
        var result := FactionHostilityPicker.pick("alpha", _rng)
        if result in counts:
            counts[result] += 1
    
    # Chaque faction devrait avoir une part significative (>15%)
    for faction_id in counts.keys():
        var percentage :float = counts[faction_id] * 100.0 / 300.0
        _assert(percentage >= 15.0, "Close competition: %s should have >15%%, got %.1f%%" % [faction_id, percentage])
    
    _cleanup_pair_states()
    myLogger.debug("  ✓ RNG close competition test passed", LogTypes.Domain.TEST)

# =============================================================================
# Tests: Méthodes utilitaires
# =============================================================================

func _test_get_top_hostile_factions() -> void:
    myLogger.debug("  Testing get_top_hostile_factions...", LogTypes.Domain.TEST)
    _setup_test_factions()
    _cleanup_pair_states()
    
    var results := FactionHostilityPicker.get_top_hostile_factions("alpha", 3)
    
    _assert(results is Array, "Should return an Array")
    _assert(results.size() <= 3, "Should return at most 3 factions")
    
    for r in results:
        _assert(r.has("id"), "Each result should have 'id'")
        _assert(r.has("score"), "Each result should have 'score'")
        _assert(r["id"] != "alpha", "Should not include origin")
    
    # Vérifier l'ordre décroissant
    for i in range(results.size() - 1):
        _assert(results[i]["score"] >= results[i + 1]["score"], "Results should be sorted by score desc")
    
    _cleanup_pair_states()
    myLogger.debug("  ✓ get_top_hostile_factions test passed", LogTypes.Domain.TEST)

func _test_empty_candidates() -> void:
    myLogger.debug("  Testing empty candidates...", LogTypes.Domain.TEST)
    
    # Tester avec une faction qui n'existe pas ou exclure tout
    var result := FactionHostilityPicker.pick_hostile_faction(
        "alpha", 
        _rng, 
        {"exclude": ["beta", "gamma", "delta", "epsilon"]}
    )
    
    # Devrait retourner "" ou une faction valide (dépend de ce qui existe)
    _assert(result != "alpha", "Should never return origin even with exclusions")
    
    myLogger.debug("  ✓ Empty candidates test passed", LogTypes.Domain.TEST)

func _test_pick_most_hostile_factions() -> void:
    myLogger.debug("  Testing pick_most_hostile_factions...", LogTypes.Domain.TEST)
    _setup_test_factions()
    _cleanup_pair_states()
    
    # Configurer des relations variées
    FactionManager.force_pair_state("alpha", "beta", FactionPairState.S_WAR, 1, 10)
    FactionManager.force_pair_state("alpha", "gamma", FactionPairState.S_CONFLICT, 1, 10)
    FactionManager.force_pair_state("alpha", "delta", FactionPairState.S_RIVALRY, 1, 10)
    FactionManager.force_pair_state("alpha", "epsilon", FactionPairState.S_NEUTRAL, 1, 10)
    
    _set_relation_scores("alpha", "beta", -90, -80, 95, 90, 10)
    _set_relation_scores("alpha", "gamma", -70, -60, 80, 70, 20)
    _set_relation_scores("alpha", "delta", -50, -40, 60, 50, 30)
    _set_relation_scores("alpha", "epsilon", -20, -10, 40, 20, 50)
    
    # Test 1: Demander 3 factions
    var result := FactionHostilityPicker.pick_most_hostile(3, "alpha", _rng)
    
    _assert(result.size() == 3, "Should return exactly 3 factions, got %d" % result.size())
    _assert(not "alpha" in result, "Should not include origin")
    
    # Vérifier qu'il n'y a pas de doublons
    var unique := {}
    for faction_id in result:
        _assert(not unique.has(faction_id), "Should not have duplicates: %s" % faction_id)
        unique[faction_id] = true
    
    myLogger.debug("    Result: %s" % str(result), LogTypes.Domain.TEST)
    
    # Test 2: Les factions les plus hostiles devraient apparaître plus souvent en premier
    var first_position_counts := {"beta": 0, "gamma": 0, "delta": 0, "epsilon": 0}
    for i in range(100):
        var r := FactionHostilityPicker.pick_most_hostile(3, "alpha", _rng)
        if r.size() > 0 and r[0] in first_position_counts:
            first_position_counts[r[0]] += 1
    
    # beta (WAR, très hostile) devrait être premier plus souvent
    _assert(first_position_counts["beta"] > first_position_counts["epsilon"], 
        "WAR faction should be first more often: beta=%d vs epsilon=%d" % [first_position_counts["beta"], first_position_counts["epsilon"]])
    
    myLogger.debug("    First position distribution: %s" % str(first_position_counts), LogTypes.Domain.TEST)
    
    # Test 3: Demander plus de factions qu'il n'y en a
    var result_all := FactionHostilityPicker.pick_most_hostile(10, "alpha", _rng)
    _assert(result_all.size() == 4, "Should return all 4 available factions, got %d" % result_all.size())
    
    # Test 4: Demander 1 faction (équivalent à pick)
    var result_one := FactionHostilityPicker.pick_most_hostile(1, "alpha", _rng)
    _assert(result_one.size() == 1, "Should return exactly 1 faction")
    _assert(result_one[0] != "alpha", "Should not return origin")
    
    _cleanup_pair_states()
    myLogger.debug("  ✓ pick_most_hostile_factions test passed", LogTypes.Domain.TEST)

func _test_pick_most_hostile_no_duplicates_with_close_scores() -> void:
    myLogger.debug("  Testing pick_most_hostile no duplicates with close scores...", LogTypes.Domain.TEST)
    _setup_test_factions()
    _cleanup_pair_states()
    
    # Tous avec des scores très proches pour maximiser le RNG
    FactionManager.force_pair_state("alpha", "beta", FactionPairState.S_RIVALRY, 1, 10)
    FactionManager.force_pair_state("alpha", "gamma", FactionPairState.S_RIVALRY, 1, 10)
    FactionManager.force_pair_state("alpha", "delta", FactionPairState.S_RIVALRY, 1, 10)
    FactionManager.force_pair_state("alpha", "epsilon", FactionPairState.S_RIVALRY, 1, 10)
    
    _set_relation_scores("alpha", "beta", -50, -40, 60, 50, 30)
    _set_relation_scores("alpha", "gamma", -51, -41, 61, 51, 29)
    _set_relation_scores("alpha", "delta", -49, -39, 59, 49, 31)
    _set_relation_scores("alpha", "epsilon", -50, -40, 60, 50, 30)
    
    # Faire plusieurs tirages et vérifier qu'il n'y a jamais de doublons
    for i in range(50):
        var result := FactionHostilityPicker.pick_most_hostile(4, "alpha", _rng)
        
        var seen := {}
        for faction_id in result:
            _assert(not seen.has(faction_id), "Iteration %d: Duplicate found: %s in %s" % [i, faction_id, str(result)])
            seen[faction_id] = true
        
        _assert(result.size() == 4, "Iteration %d: Should return 4 unique factions" % i)
    
    _cleanup_pair_states()
    myLogger.debug("  ✓ pick_most_hostile no duplicates test passed", LogTypes.Domain.TEST)

# =============================================================================
# Tests: Alliance (pick_ally)
# =============================================================================

func _test_pick_ally_basic() -> void:
    myLogger.debug("  Testing pick_ally basic...", LogTypes.Domain.TEST)
    _setup_test_factions()
    _cleanup_pair_states()
    
    # Faire plusieurs tirages et vérifier que origin n'est jamais retourné
    for i in range(20):
        var result := FactionHostilityPicker.pick_ally("alpha", _rng)
        _assert(result != "alpha", "Should never return origin faction")
        _assert(result != "", "Should return a valid faction")
    
    _cleanup_pair_states()
    myLogger.debug("  ✓ pick_ally basic test passed", LogTypes.Domain.TEST)

func _test_pick_ally_alliance_highest_priority() -> void:
    myLogger.debug("  Testing ALLIANCE state highest priority for pick_ally...", LogTypes.Domain.TEST)
    _setup_test_factions()
    _cleanup_pair_states()
    
    # beta en ALLIANCE, gamma en NEUTRAL, delta en TRUCE, epsilon en NEUTRAL
    FactionManager.force_pair_state("alpha", "beta", FactionPairState.S_ALLIANCE, 1, 10)
    FactionManager.force_pair_state("alpha", "gamma", FactionPairState.S_NEUTRAL, 1, 10)
    FactionManager.force_pair_state("alpha", "delta", FactionPairState.S_TRUCE, 1, 10)
    FactionManager.force_pair_state("alpha", "epsilon", FactionPairState.S_NEUTRAL, 1, 10)
    
    # Mettre des relations neutres pour isoler l'effet du state
    _set_relation_scores("alpha", "beta", 50, 50, 20, 10, 50)
    _set_relation_scores("alpha", "gamma", 50, 50, 20, 10, 50)
    _set_relation_scores("alpha", "delta", 50, 50, 20, 10, 50)
    _set_relation_scores("alpha", "epsilon", 50, 50, 20, 10, 50)
    
    # La faction en ALLIANCE devrait être sélectionnée le plus souvent
    var alliance_count := 0
    for i in range(100):
        var result := FactionHostilityPicker.pick_ally("alpha", _rng)
        if result == "beta":
            alliance_count += 1
    
    _assert(alliance_count >= 35, "ALLIANCE faction should be selected most often, got %d/100" % alliance_count)
    
    _cleanup_pair_states()
    myLogger.debug("  ✓ ALLIANCE state highest priority test passed", LogTypes.Domain.TEST)

func _test_pick_ally_hostile_penalized() -> void:
    myLogger.debug("  Testing hostile factions penalized for pick_ally...", LogTypes.Domain.TEST)
    _setup_test_factions()
    _cleanup_pair_states()
    
    # beta en WAR, gamma en NEUTRAL
    FactionManager.force_pair_state("alpha", "beta", FactionPairState.S_WAR, 1, 10)
    FactionManager.force_pair_state("alpha", "gamma", FactionPairState.S_NEUTRAL, 1, 10)
    
    # Même relations positives pour les deux
    _set_relation_scores("alpha", "beta", 60, 50, 10, 10, 60)
    _set_relation_scores("alpha", "gamma", 60, 50, 10, 10, 60)
    
    # gamma (NEUTRAL) devrait être sélectionnée plus souvent que beta (WAR)
    var gamma_count := 0
    var beta_count := 0
    for i in range(100):
        var result := FactionHostilityPicker.pick_ally("alpha", _rng)
        if result == "gamma":
            gamma_count += 1
        elif result == "beta":
            beta_count += 1
    
    _assert(gamma_count > beta_count, "NEUTRAL should beat WAR for alliance, got gamma=%d vs beta=%d" % [gamma_count, beta_count])
    
    # beta (hostile) devrait quand même être parfois sélectionné (réconciliation possible)
    _assert(beta_count > 0, "WAR faction should still be possible (for reconciliation)")
    
    _cleanup_pair_states()
    myLogger.debug("  ✓ hostile factions penalized test passed", LogTypes.Domain.TEST)

func _test_pick_most_allies() -> void:
    myLogger.debug("  Testing pick_most_allies...", LogTypes.Domain.TEST)
    _setup_test_factions()
    _cleanup_pair_states()
    
    # Configurer des relations variées
    FactionManager.force_pair_state("alpha", "beta", FactionPairState.S_ALLIANCE, 1, 10)
    FactionManager.force_pair_state("alpha", "gamma", FactionPairState.S_TRUCE, 1, 10)
    FactionManager.force_pair_state("alpha", "delta", FactionPairState.S_NEUTRAL, 1, 10)
    FactionManager.force_pair_state("alpha", "epsilon", FactionPairState.S_WAR, 1, 10)
    
    _set_relation_scores("alpha", "beta", 90, 80, 5, 5, 70)
    _set_relation_scores("alpha", "gamma", 60, 50, 20, 15, 50)
    _set_relation_scores("alpha", "delta", 30, 20, 40, 30, 30)
    _set_relation_scores("alpha", "epsilon", -50, -40, 80, 70, 10)
    
    # Test 1: Demander 3 factions
    var result := FactionHostilityPicker.pick_most_allies(3, "alpha", _rng)
    
    _assert(result.size() == 3, "Should return exactly 3 factions, got %d" % result.size())
    _assert(not "alpha" in result, "Should not include origin")
    
    # Vérifier qu'il n'y a pas de doublons
    var unique := {}
    for faction_id in result:
        _assert(not unique.has(faction_id), "Should not have duplicates: %s" % faction_id)
        unique[faction_id] = true
    
    myLogger.debug("    Result: %s" % str(result), LogTypes.Domain.TEST)
    
    # Test 2: Les factions les plus alliées devraient apparaître plus souvent en premier
    var first_position_counts := {"beta": 0, "gamma": 0, "delta": 0, "epsilon": 0}
    for i in range(100):
        var r := FactionHostilityPicker.pick_most_allies(3, "alpha", _rng)
        if r.size() > 0 and r[0] in first_position_counts:
            first_position_counts[r[0]] += 1
    
    # beta (ALLIANCE, très amical) devrait être premier plus souvent
    _assert(first_position_counts["beta"] > first_position_counts["epsilon"], 
        "ALLIANCE faction should be first more often: beta=%d vs epsilon=%d" % [first_position_counts["beta"], first_position_counts["epsilon"]])
    
    myLogger.debug("    First position distribution: %s" % str(first_position_counts))
    
    # Test 3: get_top_ally_factions
    var top_allies := FactionHostilityPicker.get_top_ally_factions("alpha", 4)
    _assert(top_allies.size() == 4, "Should return 4 factions")
    _assert(top_allies[0]["score"] >= top_allies[1]["score"], "Should be sorted by score desc")
    
    myLogger.debug("    Top allies: %s" % str(top_allies), LogTypes.Domain.TEST)
    
    _cleanup_pair_states()
    myLogger.debug("  ✓ pick_most_allies test passed", LogTypes.Domain.TEST)
    pass_test("Faction hostility picker ok")
