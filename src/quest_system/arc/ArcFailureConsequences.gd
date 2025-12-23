# ArcFailureConsequences.gd
class_name ArcFailureConsequences
extends RefCounted

static func apply(context: Dictionary, choice: StringName, outcome: StringName, domestic_by_faction: Dictionary, arc_notebook = null, day: int = 0) -> void:
    var action_type: StringName = StringName(context.get("arc_action_type", context.get("tp_action", &"")))
    if action_type == &"": return

    var target_id: StringName = StringName(context.get("giver_faction_id", &""))
    var antagonist_id: StringName = StringName(context.get("antagonist_faction_id", &""))
    var third_party_id: StringName = StringName(context.get("third_party_id", &""))

    var target: Faction = FactionManager.get_faction(target_id)
    var antagonist: Faction = FactionManager.get_faction(antagonist_id)
    var third_party: Faction = FactionManager.get_faction(third_party_id)
    
    # ArcFailureConsequences.apply(inst.context, &"LOYAL", &"FAILURE", relations, {}, null, 10)

    if action_type == &"tp.mediation":
        _apply_mediation(target, antagonist, third_party, choice, outcome)
    elif action_type == &"arc.truce_talks":
        _apply_truce(target, antagonist, choice, outcome, domestic_by_faction)
    elif action_type == &"arc.raid":
        _apply_raid(target, antagonist, choice, outcome, domestic_by_faction)
    # ... autres actions

    if arc_notebook != null and arc_notebook.has_method("record_pair_event"):
        arc_notebook.record_pair_event(day, target, antagonist, action_type, choice, {"outcome": outcome})


static func _apply_mediation(target :Faction, antagonist :Faction, third_party :Faction, choice, outcome):
    
    var rel_t_a = target.get_relation_to(antagonist.id)
    var rel_t_tp = target.get_relation_to(third_party.id)
    var rel_a_t = antagonist.get_relation_to(target.id)
    var rel_a_tp = antagonist.get_relation_to(third_party.id)
    var rel_tp_a = third_party.get_relation_to(third_party.id)
    var rel_tp_t = third_party.get_relation_to(third_party.id)
    
    if outcome == &"SUCCESS":
        rel_a_t.apply_delta_to(FactionRelationScore.REL_GRIEVANCE, -6)
        rel_a_t.apply_delta_to(FactionRelationScore.REL_TENSION, -8)
        rel_t_a.apply_delta_to(FactionRelationScore.REL_TENSION, -8); 
        rel_t_a.apply_delta_to(FactionRelationScore.REL_GRIEVANCE, -6)
        rel_tp_a.apply_delta_to(FactionRelationScore.REL_TRUST, +6)
        rel_tp_t.apply_delta_to(FactionRelationScore.REL_TRUST, +6)
        rel_a_tp.apply_delta_to(FactionRelationScore.REL_TRUST, +6)
        rel_t_tp.apply_delta_to(FactionRelationScore.REL_TRUST, +6)
    else:
        # échec = frustration + “médiateur incompétent”
        rel_t_a.apply_delta_to(FactionRelationScore.REL_TENSION, +4); 
        rel_a_t.apply_delta_to(FactionRelationScore.REL_TENSION, +4)
        rel_t_a.apply_delta_to(FactionRelationScore.REL_GRIEVANCE, +2)
        rel_a_t.apply_delta_to(FactionRelationScore.REL_GRIEVANCE, +2)
        var t = -3 if choice != &"TRAITOR" else -6
        rel_tp_a.apply_delta_to(FactionRelationScore.REL_TRUST, t)
        rel_tp_t.apply_delta_to(FactionRelationScore.REL_TRUST, t)
        rel_a_tp.apply_delta_to(FactionRelationScore.REL_TRUST, t)
        rel_t_tp.apply_delta_to(FactionRelationScore.REL_TRUST, t)


static func _apply_truce(target :Faction, antagonist :Faction, choice, outcome, domestic_by_faction):
    var rel_t_a = target.get_relation_to(antagonist.id)
    var rel_a_t = antagonist.get_relation_to(target.id)
    if outcome == &"SUCCESS":
        rel_t_a.apply_delta_to(FactionRelationScore.REL_TENSION, -10); 
        rel_a_t.apply_delta_to(FactionRelationScore.REL_TENSION, -10)
        rel_t_a.apply_delta_to(FactionRelationScore.REL_WEARINESS, -6)
        rel_a_t.apply_delta_to(FactionRelationScore.REL_WEARINESS, -6)
    else:
        rel_t_a.apply_delta_to(FactionRelationScore.REL_TENSION, +3);
        rel_a_t.apply_delta_to(FactionRelationScore.REL_TENSION, +3)
        rel_t_a.apply_delta_to(FactionRelationScore.REL_WEARINESS, +4)
        rel_a_t.apply_delta_to(FactionRelationScore.REL_WEARINESS, +4)
        # optionnel : la population se fatigue => support ↓
        if domestic_by_faction.has(target):
            domestic_by_faction[target].war_support = int(clampi(domestic_by_faction[target].war_support - 2, 0, 100))


static func _apply_raid(attacker :Faction, victim :Faction, choice, outcome, domestic_by_faction):
    var rel_a_v = attacker.get_relation_to(victim.id)
    var rel_v_a = victim.get_relation_to(attacker.id)
    if outcome == &"SUCCESS":
        rel_v_a.apply_delta_to(FactionRelationScore.REL_TENSION, +4)
        rel_v_a.apply_delta_to(FactionRelationScore.REL_GRIEVANCE, +6)
    else:
        # raid raté => le victim est furieux, mais l’attaquant paie aussi (fatigue interne)
        rel_v_a.apply_delta_to(FactionRelationScore.REL_TENSION, +3)
        rel_v_a.apply_delta_to(FactionRelationScore.REL_GRIEVANCE, +5)
        rel_a_v.apply_delta_to(FactionRelationScore.REL_WEARINESS, +3)
        if domestic_by_faction.has(attacker):
            domestic_by_faction[attacker].unrest = int(clampi(domestic_by_faction[attacker].unrest + 2, 0, 100))
            domestic_by_faction[attacker].war_support = int(clampi(domestic_by_faction[attacker].war_support - 2, 0, 100))
