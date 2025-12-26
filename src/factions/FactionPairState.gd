# res://src/factions/FactionPairState.gd
class_name FactionPairState
extends RefCounted

## État bidirectionnel de la relation entre deux factions
## Représente l'état SYMÉTRIQUE (WAR, TRUCE, ALLIANCE) entre A et B
## 
## IMPORTANT: Ceci est différent de FactionRelationScore qui est DIRECTIONNEL (A→B ≠ B→A)
## FactionPairState est BIDIRECTIONNEL : si A est en guerre avec B, alors B est en guerre avec A
##
## Remplace/unifie ArcState pour une architecture plus propre

# =============================================================================
# CONSTANTES - États possibles
# =============================================================================

const S_NEUTRAL: StringName  = &"NEUTRAL"   ## Relation neutre, pas d'arc actif
const S_RIVALRY: StringName  = &"RIVALRY"   ## Rivalité, tensions montantes
const S_CONFLICT: StringName = &"CONFLICT"  ## Conflit ouvert, raids fréquents
const S_WAR: StringName      = &"WAR"       ## Guerre déclarée
const S_TRUCE: StringName    = &"TRUCE"     ## Trêve temporaire
const S_ALLIANCE: StringName = &"ALLIANCE"  ## Alliance formelle
const S_MERGED: StringName   = &"MERGED"    ## Fusion (état terminal)
const S_EXTINCT: StringName  = &"EXTINCT"   ## Une faction éteinte (état terminal)

## Liste ordonnée des états pour UI/debug
const ALL_STATES: Array[StringName] = [
    S_NEUTRAL, S_RIVALRY, S_CONFLICT, S_WAR, S_TRUCE, S_ALLIANCE, S_MERGED, S_EXTINCT
]

## États considérés comme hostiles
const HOSTILE_STATES: Array[StringName] = [S_RIVALRY, S_CONFLICT, S_WAR]

## États considérés comme pacifiques
const PEACEFUL_STATES: Array[StringName] = [S_NEUTRAL, S_TRUCE, S_ALLIANCE]

## États terminaux (pas de transition possible)
const TERMINAL_STATES: Array[StringName] = [S_MERGED, S_EXTINCT]

# =============================================================================
# IDENTITÉ DE LA PAIRE
# =============================================================================

## Première faction (toujours la plus petite alphabétiquement pour garantir unicité)
var a_id: StringName = &""

## Deuxième faction
var b_id: StringName = &""

# =============================================================================
# ÉTAT RELATIONNEL
# =============================================================================

## État actuel de la relation (voir constantes S_*)
var state: StringName = S_NEUTRAL

## Traité actif entre les deux factions (null si aucun)
var treaty: Treaty = null

# =============================================================================
# TEMPORALITÉ
# =============================================================================

## Jour où l'état actuel a commencé
var entered_day: int = 0

## Jour jusqu'auquel l'état est "verrouillé" (pas de transition automatique)
var lock_until_day: int = -999999

## Dernier jour où un événement a eu lieu dans cette paire
var last_event_day: int = -999999

# =============================================================================
# COMPTEURS DE PHASE
# =============================================================================
## Ces compteurs sont réinitialisés à chaque changement d'état
## Ils servent à déterminer les conditions de transition

## Nombre d'actions hostiles depuis le dernier changement d'état
var phase_hostile: int = 0

## Nombre d'actions pacifiques depuis le dernier changement d'état
var phase_peace: int = 0

## Nombre total d'événements depuis le dernier changement d'état
var phase_events: int = 0

# =============================================================================
# STABILITÉ (pour transitions vers ALLIANCE/MERGED)
# =============================================================================

## Jours consécutifs avec tension basse
var stable_low_tension_days: int = 0

## Jours consécutifs avec trust/relation élevés
var stable_high_trust_days: int = 0

# =============================================================================
# WAR TERMS (conditions de fin de guerre)
# =============================================================================

## Termes de guerre actifs (tribut, cessions, etc.)
var war_terms: Dictionary = {}

# =============================================================================
# DEBUG
# =============================================================================

## Dernière action effectuée (pour debug/logging)
var last_action: StringName = &""

# =============================================================================
# CONSTRUCTEUR
# =============================================================================

func _init(faction_a: StringName = &"", faction_b: StringName = &"") -> void:
    # Normaliser l'ordre pour garantir l'unicité de la clé
    # La paire "orcs|humans" et "humans|orcs" doivent donner la même clé
    if String(faction_a) <= String(faction_b):
        a_id = faction_a
        b_id = faction_b
    else:
        a_id = faction_b
        b_id = faction_a

# =============================================================================
# MÉTHODES - IDENTITÉ
# =============================================================================

## Retourne la clé unique de cette paire (format "a_id|b_id")
func get_pair_key() -> StringName:
    return StringName(String(a_id) + "|" + String(b_id))

## Vérifie si cette paire implique une faction donnée
func involves(faction_id: StringName) -> bool:
    return faction_id == a_id or faction_id == b_id

## Retourne l'autre faction de la paire
func get_other(faction_id: StringName) -> StringName:
    if faction_id == a_id:
        return b_id
    elif faction_id == b_id:
        return a_id
    return &""

## Vérifie si la paire est valide (deux factions différentes)
func is_valid() -> bool:
    return a_id != &"" and b_id != &"" and a_id != b_id

# =============================================================================
# MÉTHODES - ÉTAT
# =============================================================================

## Vérifie si l'état actuel est hostile
func is_hostile() -> bool:
    return state in HOSTILE_STATES

## Vérifie si l'état actuel est pacifique
func is_peaceful() -> bool:
    return state in PEACEFUL_STATES

## Vérifie si l'état actuel est terminal (pas de transition possible)
func is_terminal() -> bool:
    return state in TERMINAL_STATES

## Vérifie si l'état est verrouillé (pas de transition automatique avant lock_until_day)
func is_locked(day: int) -> bool:
    return day < lock_until_day

## Vérifie si les deux factions sont en guerre
func is_at_war() -> bool:
    return state == S_WAR

## Vérifie si les deux factions sont alliées
func is_allied() -> bool:
    return state == S_ALLIANCE

## Vérifie si les deux factions sont en trêve
func is_in_truce() -> bool:
    return state == S_TRUCE

## Vérifie si un traité est actif
func has_treaty() -> bool:
    return treaty != null

# =============================================================================
# MÉTHODES - TRANSITIONS
# =============================================================================

## Change l'état et réinitialise les compteurs de phase
func enter_state(new_state: StringName, day: int, lock_days: int = 0) -> void:
    if is_terminal():
        return  # Pas de transition depuis un état terminal
    
    state = new_state
    entered_day = day
    lock_until_day = day + lock_days
    
    # Réinitialiser les compteurs de phase
    phase_hostile = 0
    phase_peace = 0
    phase_events = 0

## Incrémente le compteur d'actions hostiles
func record_hostile_action() -> void:
    phase_hostile += 1
    phase_events += 1

## Incrémente le compteur d'actions pacifiques
func record_peace_action() -> void:
    phase_peace += 1
    phase_events += 1

## Incrémente le compteur d'événements (neutre)
func record_event() -> void:
    phase_events += 1

## Met à jour le dernier jour d'événement
func update_last_event_day(day: int) -> void:
    last_event_day = max(last_event_day, day)

# =============================================================================
# MÉTHODES - SÉRIALISATION
# =============================================================================

## Sérialise l'état pour sauvegarde
func to_dict() -> Dictionary:
    var data := {
        "a_id": String(a_id),
        "b_id": String(b_id),
        "state": String(state),
        "entered_day": entered_day,
        "lock_until_day": lock_until_day,
        "last_event_day": last_event_day,
        "phase_hostile": phase_hostile,
        "phase_peace": phase_peace,
        "phase_events": phase_events,
        "stable_low_tension_days": stable_low_tension_days,
        "stable_high_trust_days": stable_high_trust_days,
        "last_action": String(last_action),
        "war_terms": war_terms.duplicate(true),
    }
    
    if treaty != null and treaty.has_method("to_dict"):
        data["treaty"] = treaty.to_dict()
    
    return data

## Désérialise depuis un dictionnaire
static func from_dict(data: Dictionary) -> FactionPairState:
    var ps := FactionPairState.new(
        StringName(data.get("a_id", "")),
        StringName(data.get("b_id", ""))
    )
    
    ps.state = StringName(data.get("state", S_NEUTRAL))
    ps.entered_day = int(data.get("entered_day", 0))
    ps.lock_until_day = int(data.get("lock_until_day", -999999))
    ps.last_event_day = int(data.get("last_event_day", -999999))
    ps.phase_hostile = int(data.get("phase_hostile", 0))
    ps.phase_peace = int(data.get("phase_peace", 0))
    ps.phase_events = int(data.get("phase_events", 0))
    ps.stable_low_tension_days = int(data.get("stable_low_tension_days", 0))
    ps.stable_high_trust_days = int(data.get("stable_high_trust_days", 0))
    ps.last_action = StringName(data.get("last_action", ""))
    ps.war_terms = data.get("war_terms", {}).duplicate(true)
    
    # Treaty désérialisation (si implémenté)
    var teatryInst :Treaty = Treaty.new()
    if data.has("treaty") and data["treaty"] != null:
        if ClassDB.class_exists("Treaty") and teatryInst.has_method("from_dict"):
            ps.treaty = teatryInst.from_dict(data["treaty"])
    
    return ps

# =============================================================================
# MÉTHODES - DEBUG
# =============================================================================

## Retourne une représentation string pour debug
func _to_string() -> String:
    return "FactionPairState(%s↔%s: %s, day %d)" % [a_id, b_id, state, entered_day]

## Retourne un résumé détaillé pour debug
func debug_summary() -> String:
    var lines: Array[String] = [
        "=== FactionPairState ===",
        "Pair: %s ↔ %s" % [a_id, b_id],
        "State: %s (since day %d)" % [state, entered_day],
        "Locked until: %d" % lock_until_day,
        "Last event: day %d (%s)" % [last_event_day, last_action],
        "Phase counts: hostile=%d, peace=%d, events=%d" % [phase_hostile, phase_peace, phase_events],
        "Stability: low_tension=%d days, high_trust=%d days" % [stable_low_tension_days, stable_high_trust_days],
        "Treaty: %s" % ("Yes" if treaty != null else "No"),
        "War terms: %s" % str(war_terms),
    ]
    return "\n".join(lines)
