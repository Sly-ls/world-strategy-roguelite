# res://src/factions/FactionPairStateMachine.gd
class_name FactionPairStateMachine
extends RefCounted

## Machine à états pour les transitions de FactionPairState
## Gère les transitions NEUTRAL → RIVALRY → CONFLICT → WAR → TRUCE → etc.
##
## Basé sur ArcStateMachine mais découplé du système de quêtes
## pour une meilleure séparation des responsabilités

# =============================================================================
# CONSTANTES - Raccourcis vers les états
# =============================================================================

const S_NEUTRAL  := FactionPairState.S_NEUTRAL
const S_RIVALRY  := FactionPairState.S_RIVALRY
const S_CONFLICT := FactionPairState.S_CONFLICT
const S_WAR      := FactionPairState.S_WAR
const S_TRUCE    := FactionPairState.S_TRUCE
const S_ALLIANCE := FactionPairState.S_ALLIANCE
const S_MERGED   := FactionPairState.S_MERGED
const S_EXTINCT  := FactionPairState.S_EXTINCT

# =============================================================================
# CONSTANTES - Actions (pour classification hostile/pacifique)
# =============================================================================

const HOSTILE_ACTIONS: Array[StringName] = [
	&"arc.raid", &"arc.sabotage", &"arc.declare_war", &"arc.ultimatum",
	&"raid", &"sabotage", &"declare_war", &"ultimatum", &"attack"
]

const PEACE_ACTIONS: Array[StringName] = [
	&"arc.truce_talks", &"arc.reparations", &"arc.alliance_offer",
	&"truce_talks", &"reparations", &"alliance_offer", &"diplomacy", &"mediation"
]

# =============================================================================
# MÉTHODES STATIQUES - Classification des actions
# =============================================================================

## Vérifie si une action est hostile
static func is_hostile_action(action: StringName) -> bool:
	return action in HOSTILE_ACTIONS

## Vérifie si une action est pacifique
static func is_peace_action(action: StringName) -> bool:
	return action in PEACE_ACTIONS

# =============================================================================
# MÉTHODES STATIQUES - Calcul des moyennes de paire
# =============================================================================

## Calcule les moyennes des scores entre deux FactionRelationScore
## Retourne un dictionnaire avec rel, trust, tension, griev, wear
static func pair_means(rel_ab: FactionRelationScore, rel_ba: FactionRelationScore) -> Dictionary:
	return {
		"rel": 0.5 * (rel_ab.get_score(FactionRelationScore.REL_RELATION) + rel_ba.get_score(FactionRelationScore.REL_RELATION)),
		"trust": 0.5 * (rel_ab.get_score(FactionRelationScore.REL_TRUST) + rel_ba.get_score(FactionRelationScore.REL_TRUST)),
		"tension": 0.5 * (rel_ab.get_score(FactionRelationScore.REL_TENSION) + rel_ba.get_score(FactionRelationScore.REL_TENSION)),
		"griev": 0.5 * (rel_ab.get_score(FactionRelationScore.REL_GRIEVANCE) + rel_ba.get_score(FactionRelationScore.REL_GRIEVANCE)),
		"wear": 0.5 * (rel_ab.get_score(FactionRelationScore.REL_WEARINESS) + rel_ba.get_score(FactionRelationScore.REL_WEARINESS)),
	}

# =============================================================================
# MÉTHODES STATIQUES - Lock days par état
# =============================================================================

## Retourne le nombre de jours de verrouillage pour un état donné
static func lock_days_for_state(state: StringName, rng: RandomNumberGenerator) -> int:
	match state:
		S_WAR:      return rng.randi_range(10, 20)
		S_TRUCE:    return rng.randi_range(6, 12)
		S_ALLIANCE: return rng.randi_range(12, 25)
		S_RIVALRY:  return rng.randi_range(4, 9)
		S_CONFLICT: return rng.randi_range(6, 12)
		_:          return rng.randi_range(3, 7)

# =============================================================================
# MÉTHODES STATIQUES - Mise à jour quotidienne
# =============================================================================

## Mise à jour quotidienne des compteurs de stabilité
## Appelé même les jours sans événement
static func tick_day(
	pair_state: FactionPairState,
	rel_ab: FactionRelationScore,
	rel_ba: FactionRelationScore
) -> void:
	# Seuils
	const T_LOW := 25.0
	const REL_GOOD := 35.0
	const TRUST_GOOD := 55.0
	
	var m := pair_means(rel_ab, rel_ba)
	var tension_mean := float(m["tension"])
	var rel_mean := float(m["rel"])
	var trust_mean := float(m["trust"])
	
	# Compteur de jours stables avec tension basse
	if tension_mean <= T_LOW:
		pair_state.stable_low_tension_days += 1
	else:
		pair_state.stable_low_tension_days = 0
	
	# Compteur de jours stables avec trust/relation élevés
	if trust_mean >= TRUST_GOOD and rel_mean >= REL_GOOD:
		pair_state.stable_high_trust_days += 1
	else:
		pair_state.stable_high_trust_days = 0

# =============================================================================
# MÉTHODES STATIQUES - Mise à jour après événement
# =============================================================================

## Met à jour l'état de la paire après un événement
## Retourne true si l'état a changé
static func update_state(
	pair_state: FactionPairState,
	rel_ab: FactionRelationScore,
	rel_ba: FactionRelationScore,
	day: int,
	rng: RandomNumberGenerator,
	last_action: StringName = &"",
	last_choice: StringName = &""
) -> bool:
	# Pas de transition depuis un état terminal
	if pair_state.is_terminal():
		return false
	
	# Mettre à jour les métadonnées
	pair_state.last_event_day = day
	pair_state.last_action = last_action
	pair_state.phase_events += 1
	
	# Classifier l'action
	if is_hostile_action(last_action):
		pair_state.phase_hostile += 1
	elif is_peace_action(last_action):
		pair_state.phase_peace += 1
	
	# Calculer les moyennes
	var m := pair_means(rel_ab, rel_ba)
	var rel_mean := float(m["rel"])
	var trust_mean := float(m["trust"])
	var tension_mean := float(m["tension"])
	var griev_mean := float(m["griev"])
	var wear_mean := float(m["wear"])
	
	# Seuils (tunables)
	const T_HIGH := 70.0
	const T_MED := 50.0
	const T_LOW := 25.0
	const REL_BAD := -55.0
	const REL_HATE := -70.0
	const REL_GOOD := 35.0
	const TRUST_GOOD := 55.0
	const GRIEV_HIGH := 60.0
	const WEAR_HIGH := 65.0
	
	var prev_state := pair_state.state
	var locked := pair_state.is_locked(day)
	
	# Machine à états
	match pair_state.state:
		S_NEUTRAL:
			if not locked:
				if tension_mean >= T_MED or rel_mean <= REL_BAD or is_hostile_action(last_action):
					_enter_state(pair_state, S_RIVALRY, day, rng)
		
		S_RIVALRY:
			if not locked:
				if tension_mean >= T_HIGH or pair_state.phase_hostile >= 3:
					if wear_mean < WEAR_HIGH:
						_enter_state(pair_state, S_CONFLICT, day, rng)
					else:
						_enter_state(pair_state, S_TRUCE, day, rng)
				elif tension_mean <= T_LOW and griev_mean <= 20.0 and pair_state.phase_peace >= 1:
					_enter_state(pair_state, S_NEUTRAL, day, rng)
		
		S_CONFLICT:
			if not locked:
				var war_declared := last_action == &"arc.declare_war" and last_choice == &"LOYAL"
				if (rel_mean <= REL_HATE and tension_mean >= T_HIGH) or war_declared:
					_enter_state(pair_state, S_WAR, day, rng)
				elif pair_state.phase_peace >= 2 or (tension_mean <= T_MED and griev_mean <= GRIEV_HIGH):
					_enter_state(pair_state, S_TRUCE, day, rng)
		
		S_WAR:
			# Sortie de guerre via usure ou actions de paix répétées
			if not locked:
				if wear_mean >= WEAR_HIGH or pair_state.phase_peace >= 2:
					_enter_state(pair_state, S_TRUCE, day, rng)
		
		S_TRUCE:
			if not locked:
				if trust_mean >= TRUST_GOOD and rel_mean >= REL_GOOD and tension_mean <= T_LOW:
					_enter_state(pair_state, S_ALLIANCE, day, rng)
				elif tension_mean >= T_MED and pair_state.phase_hostile >= 2:
					_enter_state(pair_state, S_CONFLICT, day, rng)
				elif tension_mean <= T_LOW and griev_mean <= 15.0 and pair_state.phase_peace >= 2:
					_enter_state(pair_state, S_NEUTRAL, day, rng)
		
		S_ALLIANCE:
			if not locked:
				# Rare: fusion
				if trust_mean >= 75.0 and rel_mean >= 60.0 and tension_mean <= 15.0 and pair_state.phase_peace >= 2:
					_enter_state(pair_state, S_MERGED, day, rng)
				# Backslide
				elif tension_mean >= T_MED and (pair_state.phase_hostile >= 2 or is_hostile_action(last_action)):
					_enter_state(pair_state, S_RIVALRY, day, rng)
	
	return pair_state.state != prev_state

## Helper interne pour entrer dans un nouvel état
static func _enter_state(pair_state: FactionPairState, new_state: StringName, day: int, rng: RandomNumberGenerator) -> void:
	var lock_days := lock_days_for_state(new_state, rng)
	pair_state.enter_state(new_state, day, lock_days)

# =============================================================================
# MÉTHODES STATIQUES - Forcer un état
# =============================================================================

## Force l'entrée dans un état spécifique (bypass les conditions normales)
## Utile pour les événements de script, la pression domestique, etc.
static func force_state(
	pair_state: FactionPairState,
	new_state: StringName,
	day: int,
	lock_days: int = 7,
	reason: StringName = &""
) -> void:
	if pair_state.is_terminal():
		return
	
	pair_state.enter_state(new_state, day, lock_days)
	if reason != &"":
		pair_state.last_action = reason

# =============================================================================
# MÉTHODES STATIQUES - Gestion des traités
# =============================================================================

## Vérifie si un traité doit être cassé et le fait si nécessaire
## Retourne true si le traité a été cassé
static func maybe_break_treaty(pair_state: FactionPairState, day: int, trigger_action: StringName = &"") -> bool:
	var t: Treaty = pair_state.treaty
	if t == null:
		return false
	
	if t.violation_score < t.violation_threshold:
		return false
	
	# Casser le traité + long cooldown
	pair_state.lock_until_day = max(pair_state.lock_until_day, day + t.cooldown_after_end_days)
	
	# Détériorer l'état
	if trigger_action == &"arc.declare_war" or trigger_action == &"declare_war":
		pair_state.state = S_WAR
	else:
		pair_state.state = S_CONFLICT
	
	pair_state.treaty = null
	return true

# =============================================================================
# MÉTHODES STATIQUES - Queries utilitaires
# =============================================================================

## Retourne le nom lisible d'un état
static func state_display_name(state: StringName) -> String:
	match state:
		S_NEUTRAL:  return "Neutral"
		S_RIVALRY:  return "Rivalry"
		S_CONFLICT: return "Conflict"
		S_WAR:      return "War"
		S_TRUCE:    return "Truce"
		S_ALLIANCE: return "Alliance"
		S_MERGED:   return "Merged"
		S_EXTINCT:  return "Extinct"
		_:          return "Unknown"

## Retourne une couleur pour l'UI basée sur l'état
static func state_color(state: StringName) -> Color:
	match state:
		S_NEUTRAL:  return Color(0.7, 0.7, 0.7)    # Gris
		S_RIVALRY:  return Color(1.0, 0.8, 0.2)    # Jaune
		S_CONFLICT: return Color(1.0, 0.5, 0.2)    # Orange
		S_WAR:      return Color(1.0, 0.2, 0.2)    # Rouge
		S_TRUCE:    return Color(0.5, 0.8, 1.0)    # Bleu clair
		S_ALLIANCE: return Color(0.2, 0.8, 0.2)    # Vert
		S_MERGED:   return Color(0.8, 0.6, 1.0)    # Violet
		S_EXTINCT:  return Color(0.3, 0.3, 0.3)    # Gris foncé
		_:          return Color.WHITE

## Vérifie si une transition est possible entre deux états
static func can_transition(from_state: StringName, to_state: StringName) -> bool:
	# Pas de transition depuis un état terminal
	if from_state in FactionPairState.TERMINAL_STATES:
		return false
	
	# Transitions autorisées
	match from_state:
		S_NEUTRAL:
			return to_state in [S_RIVALRY]
		S_RIVALRY:
			return to_state in [S_NEUTRAL, S_CONFLICT, S_TRUCE]
		S_CONFLICT:
			return to_state in [S_WAR, S_TRUCE]
		S_WAR:
			return to_state in [S_TRUCE]
		S_TRUCE:
			return to_state in [S_NEUTRAL, S_CONFLICT, S_ALLIANCE]
		S_ALLIANCE:
			return to_state in [S_RIVALRY, S_MERGED]
		_:
			return false
