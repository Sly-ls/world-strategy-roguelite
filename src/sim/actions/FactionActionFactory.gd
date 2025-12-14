# res://src/sim/actions/FactionActionFactory.gd
extends Node
class_name FactionActionFactory

func pick_action(actor_id: String) -> FactionAction:
    var a := FactionAction.new()
    a.actor_faction_id = actor_id

    # Simple heuristique de départ (on raffinera après)
    var roll := randi() % 5
    match roll:
        0:
            a.type = FactionAction.ActionType.BUILD_DOMAIN
            a.domain = ["divine","tech","nature","magic","corruption"].pick_random()
            a.intensity = 1
            return a
        1:
            a.type = FactionAction.ActionType.DIPLOMACY
            a.target_faction_id = _pick_other_faction(actor_id)
            a.relation_delta_actor_target = 5
            return a
        2:
            a.type = FactionAction.ActionType.RAID
            a.target_faction_id = _pick_other_faction(actor_id)
            a.relation_delta_actor_target = -10
            a.tags_to_add_world = ["WAR_SPIKING"]
            return a
        3:
            a.type = FactionAction.ActionType.EXPLORE
            a.tags_to_add_world = ["MAP_STIRRING"]
            return a
        _:
            a.type = FactionAction.ActionType.DEFEND
            a.tags_to_add_world = ["FRONTLINES_HOLD"]
            return a

func _pick_other_faction(actor_id: String) -> String:
    var ids := []
    for f in FactionManager.get_all_factions():
        if f.id != actor_id:
            ids.append(f.id)
    return ids.pick_random() if not ids.is_empty() else ""
