# res://src/factions/FactionHostilityPicker.gd
"""
# Un seul allié
var ally := FactionHostilityPicker.pick_ally("humans", variation_rng)

# Plusieurs alliés (sans doublons)
var allies := FactionHostilityPicker.pick_most_allies(3, "humans", variation_rng)
# allies = ["elves", "dwarves", "halflings"]

# Avec contexte
var allies := FactionHostilityPicker.pick_most_ally_factions(
    5,                    # count
    "humans",             # origin
    variation_rng,
    {
        "current_day": WorldState.current_day,
        "exclude": ["orcs"]
    }
)

# Pour debug ou UI - obtenir le classement
var top_allies := FactionHostilityPicker.get_top_ally_factions("humans", 5)
"""
class_name FactionHostilityPicker
extends RefCounted

## Utilitaire pour sélectionner une faction hostile à une faction donnée.
##
## Le calcul prend en compte (par ordre de priorité) :
## 1. État de la paire (WAR > CONFLICT > RIVALRY > NEUTRAL > TRUCE > ALLIANCE)
## 2. État du traité (malus si actif, réduit si proche expiration ou violation)
## 3. Score de relation (inversé : bas = hostile)
## 4. Score de grievance (haut = hostile)
## 5. Score de weariness (inversé : bas = plus enclin à la guerre)
## 6. Score de trust (inversé : bas = hostile)

# =============================================================================
# CONSTANTES - Poids des composantes
# =============================================================================

## Poids pour chaque composante du score (sommés pour le score final)
const WEIGHT_PAIR_STATE := 1.0
const WEIGHT_TREATY_MALUS := 1.0  # Appliqué comme malus additif
const WEIGHT_RELATION := 0.8
const WEIGHT_GRIEVANCE := 0.7
const WEIGHT_TENSION := 0.6
const WEIGHT_TRUST := 0.5
const WEIGHT_WEARINESS := 0.4

## Score de base par état de paire
const STATE_SCORES := {
    FactionPairState.S_WAR: 100.0,
    FactionPairState.S_CONFLICT: 80.0,
    FactionPairState.S_RIVALRY: 60.0,
    FactionPairState.S_NEUTRAL: 30.0,
    FactionPairState.S_TRUCE: 15.0,
    FactionPairState.S_ALLIANCE: -10.0,
    FactionPairState.S_MERGED: 0.0,
    FactionPairState.S_EXTINCT: -999.0,  # Exclu
}

## Malus de base par type de traité
const TREATY_MALUS := {
    &"ALLIANCE": -40.0,
    &"TRUCE": -25.0,
    &"TRADE_PACT": -15.0,
    &"VASSALAGE": -30.0,
}

## Multiplicateur pour les factions alliées (reste candidat mais pénalisé)
const ALLY_SCORE_MULTIPLIER := 0.3

## Multiplicateur pour les factions hostiles (dans pick_ally)
const HOSTILE_SCORE_MULTIPLIER := 0.3

## Seuils pour le RNG intelligent
const RNG_THRESHOLD_DOMINANT := 0.30   # Écart > 30% : le meilleur gagne quasi-certain
const RNG_THRESHOLD_COMPETITIVE := 0.15  # Écart 15-30% : avantage modéré
const RNG_DOMINANT_CHANCE := 0.99       # 99% de chance pour le dominant

## Score de base par état de paire (pour calcul d'alliance)
const STATE_SCORES_ALLY := {
    FactionPairState.S_ALLIANCE: 100.0,
    FactionPairState.S_TRUCE: 70.0,
    FactionPairState.S_NEUTRAL: 40.0,
    FactionPairState.S_RIVALRY: 15.0,
    FactionPairState.S_CONFLICT: -10.0,
    FactionPairState.S_WAR: -30.0,
    FactionPairState.S_MERGED: 0.0,
    FactionPairState.S_EXTINCT: -999.0,
}

## Bonus de base par type de traité (pour alliance)
const TREATY_BONUS := {
    &"ALLIANCE": 40.0,
    &"TRUCE": 25.0,
    &"TRADE_PACT": 20.0,
    &"VASSALAGE": 15.0,
}

# =============================================================================
# MÉTHODE PRINCIPALE
# =============================================================================

## Sélectionne une faction hostile à `origin`
##
## @param origin: ID de la faction pour laquelle on cherche un ennemi
## @param rng: RandomNumberGenerator pour le tirage (déterminisme)
## @param ctx: Contexte optionnel { "current_day": int, "exclude": Array[String] }
## @return: ID de la faction sélectionnée, ou "" si aucune disponible
static func pick_hostile_faction(
    origin: String,
    rng: RandomNumberGenerator,
    ctx: Dictionary = {}
) -> String:
    var current_day: int = ctx.get("current_day", _get_current_day())
    var exclude: Array = ctx.get("exclude", [])
    
    # Étape 1 : Récupérer tous les candidats
    var candidates := _get_candidates(origin, exclude)
    if candidates.is_empty():
        return ""
    
    # Étape 2 : Calculer le score de hostilité pour chaque candidat
    var scored_candidates: Array[Dictionary] = []
    for candidate_id in candidates:
        var score := _calculate_hostility_score(origin, candidate_id, current_day)
        scored_candidates.append({
            "id": candidate_id,
            "score": score
        })
    
    # Étape 3 : Trier par score décroissant
    scored_candidates.sort_custom(func(a, b): return a["score"] > b["score"])
    
    # Debug log (peut être désactivé en prod)
    if OS.is_debug_build():
        _debug_log_candidates(origin, scored_candidates)
    
    # Étape 4 : Sélection RNG intelligente
    return _select_with_smart_rng(scored_candidates, rng)

# =============================================================================
# MÉTHODE PRINCIPALE - ALLIANCE
# =============================================================================

## Sélectionne une faction alliée/amicale à `origin`
##
## @param origin: ID de la faction pour laquelle on cherche un allié
## @param rng: RandomNumberGenerator pour le tirage (déterminisme)
## @param ctx: Contexte optionnel { "current_day": int, "exclude": Array[String] }
## @return: ID de la faction sélectionnée, ou "" si aucune disponible
static func pick_ally_faction(
    origin: String,
    rng: RandomNumberGenerator,
    ctx: Dictionary = {}
) -> String:
    var current_day: int = ctx.get("current_day", _get_current_day())
    var exclude: Array = ctx.get("exclude", [])
    
    # Étape 1 : Récupérer tous les candidats
    var candidates := _get_candidates(origin, exclude)
    if candidates.is_empty():
        return ""
    
    # Étape 2 : Calculer le score d'alliance pour chaque candidat
    var scored_candidates: Array[Dictionary] = []
    for candidate_id in candidates:
        var score := _calculate_alliance_score(origin, candidate_id, current_day)
        scored_candidates.append({
            "id": candidate_id,
            "score": score
        })
    
    # Étape 3 : Trier par score décroissant
    scored_candidates.sort_custom(func(a, b): return a["score"] > b["score"])
    
    # Debug log
    if OS.is_debug_build():
        _debug_log_candidates_ally(origin, scored_candidates)
    
    # Étape 4 : Sélection RNG intelligente
    return _select_with_smart_rng(scored_candidates, rng)

# =============================================================================
# ÉTAPE 1 : FILTRAGE DES CANDIDATS
# =============================================================================

static func _get_candidates(origin: String, exclude: Array) -> Array[String]:
    var all_ids := FactionManager.get_all_faction_ids()
    var candidates: Array[String] = []
    
    for faction_id in all_ids:
        # Exclure origin
        if faction_id == origin:
            continue
        
        # Exclure les factions dans la liste d'exclusion
        if faction_id in exclude:
            continue
        
        # Exclure les factions EXTINCT
        if FactionManager.has_pair_state(origin, faction_id):
            var ps := FactionManager.get_pair_state(origin, faction_id)
            if ps.state == FactionPairState.S_EXTINCT:
                continue
            # Note: MERGED est gardé, on pourrait chercher la faction mère si implémenté
        
        candidates.append(faction_id)
    
    return candidates

# =============================================================================
# ÉTAPE 2 : CALCUL DU SCORE DE HOSTILITÉ
# =============================================================================

static func _calculate_hostility_score(origin: String, target: String, current_day: int) -> float:
    var score := 0.0
    
    # --- 2.1 : Score basé sur l'état de la paire ---
    var pair_state_score := _get_pair_state_score(origin, target)
    score += pair_state_score * WEIGHT_PAIR_STATE
    
    # --- 2.2 : Malus traité ---
    var treaty_malus := _get_treaty_malus(origin, target, current_day)
    score += treaty_malus * WEIGHT_TREATY_MALUS
    
    # --- 2.3 : Scores de relation ---
    var rel := FactionManager.get_relation(origin, target)
    if rel != null:
        # Relation : inversé (bas = hostile) → score = (max - value) / range * 50
        var relation_contrib := _normalize_inverted(
            rel.get_score(FactionRelationScore.REL_RELATION),
            FactionRelationScore.REL_MIN,
            FactionRelationScore.REL_MAX
        ) * 50.0
        score += relation_contrib * WEIGHT_RELATION
        
        # Grievance : direct (haut = hostile)
        var grievance_contrib := _normalize_direct(
            rel.get_score(FactionRelationScore.REL_GRIEVANCE),
            FactionRelationScore.REL_MIN,
            FactionRelationScore.REL_MAX
        ) * 50.0
        score += grievance_contrib * WEIGHT_GRIEVANCE
        
        # Tension : direct (haut = hostile)
        var tension_contrib := _normalize_direct(
            rel.get_score(FactionRelationScore.REL_TENSION),
            FactionRelationScore.METER_MIN,
            FactionRelationScore.METER_MAX
        ) * 50.0
        score += tension_contrib * WEIGHT_TENSION
        
        # Trust : inversé (bas = hostile)
        var trust_contrib := _normalize_inverted(
            rel.get_score(FactionRelationScore.REL_TRUST),
            FactionRelationScore.REL_MIN,
            FactionRelationScore.REL_MAX
        ) * 50.0
        score += trust_contrib * WEIGHT_TRUST
        
        # Weariness : inversé (bas = plus enclin à la guerre)
        var weariness_contrib := _normalize_inverted(
            rel.get_score(FactionRelationScore.REL_WEARINESS),
            FactionRelationScore.METER_MIN,
            FactionRelationScore.METER_MAX
        ) * 35.0
        score += weariness_contrib * WEIGHT_WEARINESS
    
    # --- 2.4 : Pénalité pour les alliés ---
    if _is_ally(origin, target):
        score *= ALLY_SCORE_MULTIPLIER
    
    return score

## Calcule le score d'alliance entre origin et target (critères inversés de hostilité)
static func _calculate_alliance_score(origin: String, target: String, current_day: int) -> float:
    var score := 0.0
    
    # --- 2.1 : Score basé sur l'état de la paire (inversé) ---
    var pair_state_score := _get_pair_state_score_ally(origin, target)
    score += pair_state_score * WEIGHT_PAIR_STATE
    
    # --- 2.2 : Bonus traité ---
    var treaty_bonus := _get_treaty_bonus(origin, target, current_day)
    score += treaty_bonus * WEIGHT_TREATY_MALUS
    
    # --- 2.3 : Scores de relation (inversés par rapport à hostilité) ---
    var rel := FactionManager.get_relation(origin, target)
    if rel != null:
        # Relation : direct (haut = allié)
        var relation_contrib := _normalize_direct(
            rel.get_score(FactionRelationScore.REL_RELATION),
            FactionRelationScore.REL_MIN,
            FactionRelationScore.REL_MAX
        ) * 50.0
        score += relation_contrib * WEIGHT_RELATION
        
        # Grievance : inversé (bas = allié)
        var grievance_contrib := _normalize_inverted(
            rel.get_score(FactionRelationScore.REL_GRIEVANCE),
            FactionRelationScore.REL_MIN,
            FactionRelationScore.REL_MAX
        ) * 50.0
        score += grievance_contrib * WEIGHT_GRIEVANCE
        
        # Tension : inversé (bas = allié)
        var tension_contrib := _normalize_inverted(
            rel.get_score(FactionRelationScore.REL_TENSION),
            FactionRelationScore.METER_MIN,
            FactionRelationScore.METER_MAX
        ) * 50.0
        score += tension_contrib * WEIGHT_TENSION
        
        # Trust : direct (haut = allié)
        var trust_contrib := _normalize_direct(
            rel.get_score(FactionRelationScore.REL_TRUST),
            FactionRelationScore.REL_MIN,
            FactionRelationScore.REL_MAX
        ) * 50.0
        score += trust_contrib * WEIGHT_TRUST
        
        # Weariness : direct (haut = fatigué de la guerre = plus enclin à la paix)
        var weariness_contrib := _normalize_direct(
            rel.get_score(FactionRelationScore.REL_WEARINESS),
            FactionRelationScore.METER_MIN,
            FactionRelationScore.METER_MAX
        ) * 35.0
        score += weariness_contrib * WEIGHT_WEARINESS
    
    # --- 2.4 : Pénalité pour les factions hostiles ---
    if _is_hostile(origin, target):
        score *= HOSTILE_SCORE_MULTIPLIER
    
    return score

## Retourne le score basé sur l'état de la paire (pour alliance)
static func _get_pair_state_score_ally(origin: String, target: String) -> float:
    if not FactionManager.has_pair_state(origin, target):
        return STATE_SCORES_ALLY[FactionPairState.S_NEUTRAL]
    
    var ps := FactionManager.get_pair_state(origin, target)
    return STATE_SCORES_ALLY.get(ps.state, STATE_SCORES_ALLY[FactionPairState.S_NEUTRAL])

## Calcule le bonus de traité (augmenté si proche expiration ou faible violation)
static func _get_treaty_bonus(origin: String, target: String, current_day: int) -> float:
    if not FactionManager.has_pair_state(origin, target):
        return 0.0
    
    var ps := FactionManager.get_pair_state(origin, target)
    var treaty: Treaty = ps.treaty
    
    if treaty == null:
        return 0.0
    
    # Bonus de base selon le type de traité
    var base_bonus: float = TREATY_BONUS.get(treaty.type, 15.0)
    
    # Le bonus est plus fort si le traité est stable (loin de l'expiration)
    var days_remaining := treaty.end_day - current_day
    var stability_factor := 1.0
    if days_remaining <= 0:
        # Traité expiré, pas de bonus
        return 0.0
    elif days_remaining <= 7:
        # Dernière semaine : bonus réduit (traité instable)
        stability_factor = 0.5
    elif days_remaining <= 14:
        # Deux semaines : bonus légèrement réduit
        stability_factor = 0.75
    elif days_remaining >= 30:
        # Plus d'un mois : bonus maximal (traité solide)
        stability_factor = 1.2
    
    # Réduction du bonus selon le score de violation
    var violation_factor := 1.0 - clampf(treaty.violation_score / treaty.violation_threshold, 0.0, 0.8)
    
    return base_bonus * stability_factor * violation_factor

## Vérifie si deux factions sont hostiles (WAR ou CONFLICT)
static func _is_hostile(origin: String, target: String) -> bool:
    if not FactionManager.has_pair_state(origin, target):
        return false
    var state := FactionManager.get_pair_state(origin, target).state
    return state == FactionPairState.S_WAR or state == FactionPairState.S_CONFLICT

## Retourne le score basé sur l'état de la paire
static func _get_pair_state_score(origin: String, target: String) -> float:
    if not FactionManager.has_pair_state(origin, target):
        return STATE_SCORES[FactionPairState.S_NEUTRAL]
    
    var ps := FactionManager.get_pair_state(origin, target)
    return STATE_SCORES.get(ps.state, STATE_SCORES[FactionPairState.S_NEUTRAL])

## Calcule le malus de traité (réduit si proche expiration ou violation élevée)
static func _get_treaty_malus(origin: String, target: String, current_day: int) -> float:
    if not FactionManager.has_pair_state(origin, target):
        return 0.0
    
    var ps := FactionManager.get_pair_state(origin, target)
    var treaty: Treaty = ps.treaty
    
    if treaty == null:
        return 0.0
    
    # Malus de base selon le type de traité
    var base_malus: float = TREATY_MALUS.get(treaty.type, -20.0)
    
    # Réduction du malus selon proximité de l'expiration
    # Plus on est proche de end_day, moins le malus est fort
    var days_remaining := treaty.end_day - current_day
    var expiration_factor := 1.0
    if days_remaining <= 0:
        # Traité expiré, pas de malus
        return 0.0
    elif days_remaining <= 7:
        # Dernière semaine : malus réduit à 30%
        expiration_factor = 0.3
    elif days_remaining <= 14:
        # Deux semaines : malus réduit à 60%
        expiration_factor = 0.6
    elif days_remaining <= 30:
        # Un mois : malus réduit à 80%
        expiration_factor = 0.8
    
    # Réduction du malus selon le score de violation
    # Plus le violation_score est élevé, moins le traité est respecté
    var violation_factor := 1.0 - clampf(treaty.violation_score / treaty.violation_threshold, 0.0, 0.8)
    
    return base_malus * expiration_factor * violation_factor

## Vérifie si deux factions sont alliées
static func _is_ally(origin: String, target: String) -> bool:
    if not FactionManager.has_pair_state(origin, target):
        return false
    return FactionManager.get_pair_state(origin, target).state == FactionPairState.S_ALLIANCE

# =============================================================================
# NORMALISATION DES SCORES
# =============================================================================

## Normalise une valeur entre 0 et 1 (direct : haut = bon score)
static func _normalize_direct(value: float, min_val: float, max_val: float) -> float:
    if max_val == min_val:
        return 0.5
    return clampf((value - min_val) / (max_val - min_val), 0.0, 1.0)

## Normalise une valeur entre 0 et 1 (inversé : bas = bon score)
static func _normalize_inverted(value: float, min_val: float, max_val: float) -> float:
    return 1.0 - _normalize_direct(value, min_val, max_val)

# =============================================================================
# ÉTAPE 4 : SÉLECTION RNG INTELLIGENTE
# =============================================================================

## Sélectionne un candidat avec un RNG intelligent basé sur les écarts de score
static func _select_with_smart_rng(scored_candidates: Array[Dictionary], rng: RandomNumberGenerator) -> String:
    if scored_candidates.is_empty():
        return ""
    
    if scored_candidates.size() == 1:
        return scored_candidates[0]["id"]
    
    var best_score: float = scored_candidates[0]["score"]
    var second_score: float = scored_candidates[1]["score"]
    
    # Éviter division par zéro
    if best_score <= 0:
        # Tous les scores sont négatifs ou nuls, choix aléatoire
        return scored_candidates[rng.randi_range(0, scored_candidates.size() - 1)]["id"]
    
    # Calculer l'écart relatif
    var gap_ratio: float = (best_score - second_score) / best_score
    
    # Cas 1 : Dominant clair (écart > 30%)
    if gap_ratio > RNG_THRESHOLD_DOMINANT:
        if rng.randf() < RNG_DOMINANT_CHANCE:
            return scored_candidates[0]["id"]
        else:
            # 1% de chance de prendre le second
            return scored_candidates[1]["id"]
    
    # Cas 2 : Avantage modéré (écart 15-30%)
    if gap_ratio > RNG_THRESHOLD_COMPETITIVE:
        return _weighted_selection(scored_candidates, rng, 2.0)  # Température basse
    
    # Cas 3 : Compétition serrée (écart < 15%)
    return _weighted_selection(scored_candidates, rng, 0.5)  # Température haute

## Sélection pondérée avec softmax
## temperature > 1 : favorise le meilleur
## temperature < 1 : distribution plus uniforme
static func _weighted_selection(scored_candidates: Array[Dictionary], rng: RandomNumberGenerator, temperature: float) -> String:
    # Trouver les candidats compétitifs (dans les 20% du meilleur score)
    var best_score: float = scored_candidates[0]["score"]
    var threshold: float = best_score * 0.8
    
    var competitive: Array[Dictionary] = []
    for candidate in scored_candidates:
        if candidate["score"] >= threshold:
            competitive.append(candidate)
        else:
            break  # Liste triée, on peut arrêter
    
    if competitive.size() == 1:
        return competitive[0]["id"]
    
    # Calculer les poids softmax
    var weights: Array[float] = []
    var total_weight := 0.0
    
    for candidate in competitive:
        # Softmax avec température : exp(score / T)
        var weight := exp(candidate["score"] * temperature / 100.0)
        weights.append(weight)
        total_weight += weight
    
    # Normaliser et sélectionner
    var roll := rng.randf() * total_weight
    var cumulative := 0.0
    
    for i in range(competitive.size()):
        cumulative += weights[i]
        if roll <= cumulative:
            return competitive[i]["id"]
    
    # Fallback
    return competitive[competitive.size() - 1]["id"]

# =============================================================================
# UTILITAIRES
# =============================================================================

static func _get_current_day() -> int:
    if WorldState != null and "current_day" in WorldState:
        return WorldState.current_day
    return 0

static func _debug_log_candidates(origin: String, scored_candidates: Array[Dictionary]) -> void:
    print("=== FactionHostilityPicker (hostile): %s ===" % origin)
    var count := mini(5, scored_candidates.size())
    for i in range(count):
        var c: Dictionary = scored_candidates[i]
        print("  %d. %s: %.2f" % [i + 1, c["id"], c["score"]])
    if scored_candidates.size() > 5:
        print("  ... +%d autres" % (scored_candidates.size() - 5))
    print("===")

static func _debug_log_candidates_ally(origin: String, scored_candidates: Array[Dictionary]) -> void:
    print("=== FactionHostilityPicker (ally): %s ===" % origin)
    var count := mini(5, scored_candidates.size())
    for i in range(count):
        var c: Dictionary = scored_candidates[i]
        print("  %d. %s: %.2f" % [i + 1, c["id"], c["score"]])
    if scored_candidates.size() > 5:
        print("  ... +%d autres" % (scored_candidates.size() - 5))
    print("===")

# =============================================================================
# MÉTHODES DE CONVENANCE
# =============================================================================

## Version simplifiée sans contexte
static func pick(origin: String, rng: RandomNumberGenerator) -> String:
    return pick_hostile_faction(origin, rng, {})

## Sélectionne les N factions les plus hostiles à `origin`
## Utilise le même système de scoring et RNG intelligent, sans doublons
##
## @param count: Nombre de factions à retourner
## @param origin: ID de la faction pour laquelle on cherche des ennemis
## @param rng: RandomNumberGenerator pour le tirage (déterminisme)
## @param ctx: Contexte optionnel { "current_day": int, "exclude": Array[String] }
## @return: Array des IDs de factions sélectionnées (peut être < count si pas assez de candidats)
static func pick_most_hostile_factions(
    count: int,
    origin: String,
    rng: RandomNumberGenerator,
    ctx: Dictionary = {}
) -> Array[String]:
    var current_day: int = ctx.get("current_day", _get_current_day())
    var exclude: Array = ctx.get("exclude", [])
    
    # Étape 1 : Récupérer tous les candidats
    var candidates := _get_candidates(origin, exclude)
    if candidates.is_empty():
        return []
    
    # Étape 2 : Calculer le score de hostilité pour chaque candidat
    var scored_candidates: Array[Dictionary] = []
    for candidate_id in candidates:
        var score := _calculate_hostility_score(origin, candidate_id, current_day)
        scored_candidates.append({
            "id": candidate_id,
            "score": score
        })
    
    # Étape 3 : Trier par score décroissant
    scored_candidates.sort_custom(func(a, b): return a["score"] > b["score"])
    
    # Étape 4 : Sélection itérative avec RNG intelligent (sans remise)
    var result: Array[String] = []
    var remaining := scored_candidates.duplicate()
    
    var iterations := mini(count, remaining.size())
    for i in range(iterations):
        if remaining.is_empty():
            break
        
        # Sélectionner une faction avec le RNG intelligent
        var selected_id := _select_with_smart_rng(remaining, rng)
        result.append(selected_id)
        
        # Retirer la faction sélectionnée des candidats restants
        for j in range(remaining.size() - 1, -1, -1):
            if remaining[j]["id"] == selected_id:
                remaining.remove_at(j)
                break
    
    return result

## Version simplifiée de pick_most_hostile_factions
static func pick_most_hostile(count: int, origin: String, rng: RandomNumberGenerator) -> Array[String]:
    return pick_most_hostile_factions(count, origin, rng, {})

## Version simplifiée de pick_ally_faction
static func pick_ally(origin: String, rng: RandomNumberGenerator) -> String:
    return pick_ally_faction(origin, rng, {})

## Sélectionne les N factions les plus alliées/amicales à `origin`
## Utilise le même système de scoring et RNG intelligent, sans doublons
##
## @param count: Nombre de factions à retourner
## @param origin: ID de la faction pour laquelle on cherche des alliés
## @param rng: RandomNumberGenerator pour le tirage (déterminisme)
## @param ctx: Contexte optionnel { "current_day": int, "exclude": Array[String] }
## @return: Array des IDs de factions sélectionnées
static func pick_most_ally_factions(
    count: int,
    origin: String,
    rng: RandomNumberGenerator,
    ctx: Dictionary = {}
) -> Array[String]:
    var current_day: int = ctx.get("current_day", _get_current_day())
    var exclude: Array = ctx.get("exclude", [])
    
    # Étape 1 : Récupérer tous les candidats
    var candidates := _get_candidates(origin, exclude)
    if candidates.is_empty():
        return []
    
    # Étape 2 : Calculer le score d'alliance pour chaque candidat
    var scored_candidates: Array[Dictionary] = []
    for candidate_id in candidates:
        var score := _calculate_alliance_score(origin, candidate_id, current_day)
        scored_candidates.append({
            "id": candidate_id,
            "score": score
        })
    
    # Étape 3 : Trier par score décroissant
    scored_candidates.sort_custom(func(a, b): return a["score"] > b["score"])
    
    # Étape 4 : Sélection itérative avec RNG intelligent (sans remise)
    var result: Array[String] = []
    var remaining := scored_candidates.duplicate()
    
    var iterations := mini(count, remaining.size())
    for i in range(iterations):
        if remaining.is_empty():
            break
        
        var selected_id := _select_with_smart_rng(remaining, rng)
        result.append(selected_id)
        
        for j in range(remaining.size() - 1, -1, -1):
            if remaining[j]["id"] == selected_id:
                remaining.remove_at(j)
                break
    
    return result

## Version simplifiée de pick_most_ally_factions
static func pick_most_allies(count: int, origin: String, rng: RandomNumberGenerator) -> Array[String]:
    return pick_most_ally_factions(count, origin, rng, {})

## Retourne les N factions les plus alliées (pour debug ou UI)
static func get_top_ally_factions(origin: String, count: int = 5, ctx: Dictionary = {}) -> Array[Dictionary]:
    var current_day: int = ctx.get("current_day", _get_current_day())
    var exclude: Array = ctx.get("exclude", [])
    
    var candidates := _get_candidates(origin, exclude)
    var scored_candidates: Array[Dictionary] = []
    
    for candidate_id in candidates:
        var score := _calculate_alliance_score(origin, candidate_id, current_day)
        scored_candidates.append({
            "id": candidate_id,
            "score": score
        })
    
    scored_candidates.sort_custom(func(a, b): return a["score"] > b["score"])
    
    var result: Array[Dictionary] = []
    for i in range(mini(count, scored_candidates.size())):
        result.append(scored_candidates[i])
    
    return result

## Retourne les N factions les plus hostiles (pour debug ou UI)
static func get_top_hostile_factions(origin: String, count: int = 5, ctx: Dictionary = {}) -> Array[Dictionary]:
    var current_day: int = ctx.get("current_day", _get_current_day())
    var exclude: Array = ctx.get("exclude", [])
    
    var candidates := _get_candidates(origin, exclude)
    var scored_candidates: Array[Dictionary] = []
    
    for candidate_id in candidates:
        var score := _calculate_hostility_score(origin, candidate_id, current_day)
        scored_candidates.append({
            "id": candidate_id,
            "score": score
        })
    
    scored_candidates.sort_custom(func(a, b): return a["score"] > b["score"])
    
    var result: Array[Dictionary] = []
    for i in range(mini(count, scored_candidates.size())):
        result.append(scored_candidates[i])
    
    return result
