# res://src/quest_system/coalition/CoalitionBlock.gd
class_name CoalitionBlock
extends RefCounted

## Bloc de coalition - représente une coalition entre factions
## Fusionné: champs originaux + champs de CoalitionManager (kind, side, key())

var id: StringName
var target_id: StringName = &""           # hegemon or crisis instigator (can be empty if "world threat")
var leader_id: StringName = &""
var member_ids: Array[StringName] = []

# Type de coalition
var kind: StringName = &"HEGEMON"         # HEGEMON | CRISIS
var side: StringName = &"AGAINST_TARGET"  # AGAINST_TARGET | WITH_TARGET

# Objectif
var goal: StringName = &"CONTAIN"         # CONTAIN | OVERTHROW | TAKE_POI | TRIBUTE | PUNISH | STOP_CRISIS | SUPPORT_CRISIS

# Timing
var started_day: int = 0
var expires_day: int = 0
var lock_until_day: int = 0

# État
var cohesion: int = 60                    # 0..100
var progress: float = 0.0                 # 0..100

# Membres
var member_commitment: Dictionary = {}    # member_id -> 0..1
var member_role: Dictionary = {}          # member_id -> "FRONTLINE"/"SUPPORT"/"DIPLO"

# Offres
var last_offer_day: int = -999999
var primary_offer_active: bool = false


## Génère une clé unique pour cette coalition basée sur kind|side|target
func key() -> StringName:
    return StringName("%s|%s|%s" % [String(kind), String(side), String(target_id)])


## Ajoute un membre à la coalition
func add_member(member_id: StringName, commitment: float = 0.6, role: StringName = &"SUPPORT") -> void:
    if member_id not in member_ids:
        member_ids.append(member_id)
    member_commitment[member_id] = clampf(commitment, 0.0, 1.0)
    member_role[member_id] = role


## Retire un membre de la coalition
func remove_member(member_id: StringName) -> void:
    member_ids.erase(member_id)
    member_commitment.erase(member_id)
    member_role.erase(member_id)


## Vérifie si la coalition est expirée
func is_expired(day: int) -> bool:
    return day >= expires_day


## Vérifie si la coalition est verrouillée
func is_locked(day: int) -> bool:
    return day < lock_until_day


## Retourne le nombre de membres
func member_count() -> int:
    return member_ids.size()


## Calcule la commitment moyenne
func average_commitment() -> float:
    if member_ids.is_empty():
        return 0.0
    var total := 0.0
    for m in member_ids:
        total += float(member_commitment.get(m, 0.5))
    return total / float(member_ids.size())
