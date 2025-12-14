extends Node
class_name FactionGoalProgressor

static func notify_action_done(action: FactionAction) -> void:
    var st := FactionGoalManagerRunner.get_goal_state(action.actor_faction_id)
    if st == null:
        return

    var g := st.goal
    var step := g.get_current_step()
    if step == null:
        return
        
   # Générer une offer alignée sur l'objectif (pas à chaque fois : on throttle)
    if step.id == "gather" or step.id == "help" or step.id == "raids":
        if randf() < 0.9: # 50% pour éviter le spam
            QuestOfferSimRunner.generate_goal_offer(g.actor_faction_id, g.target_faction_id, g.domain, step.id)

    # Règle simple : 1 action réussie = +1 progress sur le step courant
    step.add_progress(1)
    if g.type == FactionGoal.GoalType.BUILD_DOMAIN:
        var s := g.get_current_step()
        if s != null and (s.id == "scout" or s.id == "gather"):
            QuestManager.add_world_tag("DOMAIN_%s_GROWING" % g.domain.to_upper())

    print("  ↳ Goal progress [%s] %s : %d/%d" % [
        action.actor_faction_id,
        step.title,
        step.current_amount,
        step.required_amount
    ])

    g.advance_if_step_done()

    if g.is_completed():
        FactionGoalManagerRunner.complete_goal(action.actor_faction_id)
