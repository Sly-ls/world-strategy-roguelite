# FactionWorldContext.gd
class_name FactionWorldContext
extends RefCounted

var day: int
var faction_id: StringName

# signaux “stratégiques”
var war_pressure: float = 0.0           # 0..1 (part de paires en WAR/CONFLICT)
var external_threat: float = 0.0        # 0..1 (menace globale)
var opportunity: float = 0.0            # 0..1 (fenêtres d’opportunité)
var fatigue: float = 0.0                # 0..1 (ex: weariness agrégée)

# priorités/targets calculés
var priority_targets: Array[StringName] = []
var target_scores: Dictionary[StringName, float] = {} # faction_id -> score

# vue arcs
var arcs: Array[Dictionary] = [] # each: {other_id, pair_key, state, rel_mean, tension_mean, griev_mean, wear_mean}
