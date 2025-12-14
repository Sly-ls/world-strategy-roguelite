# res://src/sim/actions/FactionActionResolver.gd
extends Node
class_name FactionActionResolver

func apply(action: FactionAction) -> void:
    match action.type:
        FactionAction.ActionType.BUILD_DOMAIN:
            _apply_build_domain(action)
        FactionAction.ActionType.DIPLOMACY:
            _apply_diplomacy(action)
        FactionAction.ActionType.RAID:
            _apply_raid(action)
        _:
            _apply_generic(action)

    for t in action.tags_to_add_world:
        QuestManager.add_world_tag(t)

func _apply_build_domain(a: FactionAction) -> void:
    # Pour l’instant : tag monde + futur hook vers ton système bâtiments
    QuestManager.add_world_tag("DOMAIN_%s_GROWING" % a.domain.to_upper())
    print("Faction %s développe le domaine %s (intensity %d)" % [a.actor_faction_id, a.domain, a.intensity])

func _apply_diplomacy(a: FactionAction) -> void:
    if a.target_faction_id == "":
        return
    FactionManager.set_relation_between(a.actor_faction_id, a.target_faction_id,
        FactionManager.get_relation_between(a.actor_faction_id, a.target_faction_id) + a.relation_delta_actor_target)
    print("Diplomatie %s -> %s (%+d)" % [a.actor_faction_id, a.target_faction_id, a.relation_delta_actor_target])

func _apply_raid(a: FactionAction) -> void:
    if a.target_faction_id == "":
        return
    FactionManager.set_relation_between(a.actor_faction_id, a.target_faction_id,
        FactionManager.get_relation_between(a.actor_faction_id, a.target_faction_id) + a.relation_delta_actor_target)
    print("Raid %s -> %s (%+d)" % [a.actor_faction_id, a.target_faction_id, a.relation_delta_actor_target])

func _apply_generic(a: FactionAction) -> void:
    print("Faction %s action %s" % [a.actor_faction_id, str(a.type)])
