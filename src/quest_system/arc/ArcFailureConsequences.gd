# ArcFailureConsequences.gd
class_name ArcFailureConsequences
extends RefCounted

static func apply(context: Dictionary, choice: StringName, outcome: StringName, relations: Dictionary, domestic_by_faction: Dictionary, arc_notebook = null, day: int = 0) -> void:
    var action_type: StringName = StringName(context.get("arc_action_type", context.get("tp_action", &"")))
    if action_type == &"": return

    var A: StringName = StringName(context.get("giver_faction_id", &""))
    var B: StringName = StringName(context.get("antagonist_faction_id", &""))
    var C: StringName = StringName(context.get("third_party_id", &""))

    # helpers
    var f = func(x): return x # (juste pour garder ça lisible)

    if action_type == &"tp.mediation":
        _apply_mediation(A, B, C, choice, outcome, relations)
    elif action_type == &"arc.truce_talks":
        _apply_truce(A, B, choice, outcome, relations, domestic_by_faction)
    elif action_type == &"arc.raid":
        _apply_raid(A, B, choice, outcome, relations, domestic_by_faction)
    # ... autres actions

    if arc_notebook != null and arc_notebook.has_method("record_pair_event"):
        arc_notebook.record_pair_event(day, A, B, action_type, choice, {"outcome": outcome})


static func _apply_mediation(A, B, C, choice, outcome, relations):
    if C == &"": return
    if outcome == &"SUCCESS":
        _rel(relations, A, B, "tension", -8); _rel(relations, B, A, "tension", -8)
        _rel(relations, A, B, "grievance", -6); _rel(relations, B, A, "grievance", -6)
        _rel(relations, A, C, "trust", +6); _rel(relations, C, A, "trust", +6)
        _rel(relations, B, C, "trust", +6); _rel(relations, C, B, "trust", +6)
    else:
        # échec = frustration + “médiateur incompétent”
        _rel(relations, A, B, "tension", +4); _rel(relations, B, A, "tension", +4)
        _rel(relations, A, B, "grievance", +2); _rel(relations, B, A, "grievance", +2)
        var t = -3 if choice != &"TRAITOR" else -6
        _rel(relations, A, C, "trust", t)
        _rel(relations, B, C, "trust", t)
        _rel(relations, C, A, "trust", t)
        _rel(relations, C, B, "trust", t)


static func _apply_truce(A, B, choice, outcome, relations, domestic_by_faction):
    if outcome == &"SUCCESS":
        _rel(relations, A, B, "tension", -10); _rel(relations, B, A, "tension", -10)
        _rel(relations, A, B, "weariness", -6); _rel(relations, B, A, "weariness", -6)
    else:
        _rel(relations, A, B, "tension", +3); _rel(relations, B, A, "tension", +3)
        _rel(relations, A, B, "weariness", +4); _rel(relations, B, A, "weariness", +4)
        # optionnel : la population se fatigue => support ↓
        if domestic_by_faction.has(A):
            domestic_by_faction[A].war_support = int(clampi(domestic_by_faction[A].war_support - 2, 0, 100))


static func _apply_raid(attacker, victim, choice, outcome, relations, domestic_by_faction):
    if outcome == &"SUCCESS":
        _rel(relations, victim, attacker, "grievance", +6)
        _rel(relations, victim, attacker, "tension", +4)
    else:
        # raid raté => le victim est furieux, mais l’attaquant paie aussi (fatigue interne)
        _rel(relations, victim, attacker, "grievance", +5)
        _rel(relations, victim, attacker, "tension", +3)
        _rel(relations, attacker, victim, "weariness", +3)
        if domestic_by_faction.has(attacker):
            domestic_by_faction[attacker].unrest = int(clampi(domestic_by_faction[attacker].unrest + 2, 0, 100))
            domestic_by_faction[attacker].war_support = int(clampi(domestic_by_faction[attacker].war_support - 2, 0, 100))


static func _rel(relations: Dictionary, a: StringName, b: StringName, field: String, delta: int) -> void:
    if a == &"" or b == &"": return
    if not relations.has(a) or not relations[a].has(b): return
    var r: FactionRelationScore = relations[a][b]
    match field:
        "relation": r.relation = int(clampi(r.relation + delta, -100, 100))
        "trust": r.trust = int(clampi(r.trust + delta, 0, 100))
        "tension": r.tension = int(clampi(r.tension + delta, 0, 100))
        "grievance": r.grievance = int(clampi(r.grievance + delta, 0, 100))
        "weariness": r.weariness = int(clampi(r.weariness + delta, 0, 100))
