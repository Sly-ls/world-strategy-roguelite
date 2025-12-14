extends Node
class_name FactionGoalPlanner

static func plan_action(goal: FactionGoal) -> FactionAction:
    var step := goal.get_current_step()
    if step == null:
        return null

    var a := FactionAction.new()
    a.actor_faction_id = goal.actor_faction_id
    a.target_faction_id = goal.target_faction_id
    a.domain = goal.domain
    a.intensity = 1

    match step.id:
        "scout":
            a.type = FactionAction.ActionType.EXPLORE
        "secure":
            a.type = FactionAction.ActionType.DEFEND
        "gather":
            a.type = FactionAction.ActionType.EXPLORE
        "build":
            a.type = FactionAction.ActionType.BUILD_DOMAIN

        "send_envoys":
            a.type = FactionAction.ActionType.DIPLOMACY
            a.relation_delta_actor_target = 5
        "help":
            # ici on peut générer des offers "aider la faction X"
            a.type = FactionAction.ActionType.EXPLORE
        "treaty":
            a.type = FactionAction.ActionType.DIPLOMACY
            a.relation_delta_actor_target = 10

        "raids":
            a.type = FactionAction.ActionType.RAID
            a.relation_delta_actor_target = -10
            a.tags_to_add_world = ["WAR_SPIKING"]
        "mobilize":
            a.type = FactionAction.ActionType.DEFEND
        "declare":
            a.type = FactionAction.ActionType.RAID
            a.relation_delta_actor_target = -25
            a.tags_to_add_world = ["WAR_SPIKING"]

        _:
            a.type = FactionAction.ActionType.EXPLORE

    a.debug_label = step.title
    return a
