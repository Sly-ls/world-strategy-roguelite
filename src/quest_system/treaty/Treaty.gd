# Treaty.gd
class_name Treaty
extends RefCounted

var type: StringName = &"TRUCE"          # TRUCE | ALLIANCE | TRADE_PACT | VASSALAGE (plus tard)
var start_day: int = 0
var end_day: int = 0                    # expiration dure
var cooldown_after_end_days: int = 20   # pair_lock_days post-traité

# Clauses (bitmask) : très compact et facile à tester
const CLAUSE_NO_RAID    := 1 << 0
const CLAUSE_NO_SABOTAGE:= 1 << 1
const CLAUSE_NO_WAR     := 1 << 2
const CLAUSE_OPEN_TRADE := 1 << 3
var clauses: int = 0

# Enforcement / sanctions
var violation_score: float = 0.0        # monte à chaque violation
var violation_threshold: float = 1.0    # si dépassé => traité cassé / pénalités

# “Garants” (optionnel) : troisième partie qui a de l’influence
var guarantor_id: StringName = &""      # ex: C médiateur (ou vide)
