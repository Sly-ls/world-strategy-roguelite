class_name Rumor
extends RefCounted

var id: StringName
var day: int
var seed_id: StringName         # qui lance la rumeur (C, un broker, etc.)
var claim_actor: StringName
var claim_target: StringName
var claim_type: StringName
var strength: float = 0.6       # force du message
var credibility: float = 0.5    # crédibilité perçue (source + réputation)
var malicious: bool = false
var related_event_id: StringName = &""  # si rumeur “sur” un fact
