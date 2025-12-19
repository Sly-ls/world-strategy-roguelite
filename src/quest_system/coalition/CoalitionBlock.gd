class_name CoalitionBlock
extends RefCounted

var id: StringName
var target_id: StringName
var leader_id: StringName
var member_ids: Array[StringName] = []

var goal: StringName = &"CONTAIN"         # CONTAIN/OVERTHROW/TAKE_POI/TRIBUTE/PUNISH
var started_day: int = 0
var expires_day: int = 0
var lock_until_day: int = 0

var cohesion: int = 60                    # 0..100
var progress: float = 0.0                 # 0..100

var member_commitment: Dictionary = {}    # member_id -> 0..1
var member_role: Dictionary = {}          # member_id -> "FRONTLINE"/"SUPPORT"/"DIPLO"

var last_offer_day: int = -999999
var primary_offer_active: bool = false

var kind: StringName = &"HEGEMON"              # HEGEMON | CRISIS
var side: StringName = &"AGAINST_TARGET"       # AGAINST_TARGET | WITH_TARGET

func key() -> StringName:
    return StringName("%s|%s|%s" % [String(kind), String(side), String(target_id)])
