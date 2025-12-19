class_name BeliefEntry
extends RefCounted

var event_id: StringName
var observer_id: StringName     # faction X qui croit
var claimed_actor: StringName   # qui X pense être l’acteur
var claimed_target: StringName
var claim_type: StringName      # RAID/...
var confidence: float = 0.0     # 0..1
var source: StringName = &"RUMOR"   # DIRECT/WITNESS/ALLY/RUMOR/PROPAGANDA
var bias_tag: StringName = &""      # "anti_magic", "anti_orc", etc.
var last_update_day: int = 0
