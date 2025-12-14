extends Node
class_name FactionGoalFactory

static func create_goal(actor_id: String) -> FactionGoal:
    var g := FactionGoal.new()
    g.actor_faction_id = actor_id

    # Heuristique de départ (on raffinera avec tags/monde)
    var roll := randi() % 3
    if actor_id == "orcs":
        roll = 1
    match roll:
        0:
            return _goal_build_domain(actor_id, ["divine","tech","nature","magic","corruption"].pick_random())
        1:
            return _goal_gain_ally(actor_id)
        _:
            return _goal_start_war(actor_id)

static func _goal_build_domain(actor_id: String, domain: String) -> FactionGoal:
    var g := FactionGoal.new()
    g.id = "goal_build_domain_%s_%s" % [actor_id, domain]
    g.type = FactionGoal.GoalType.BUILD_DOMAIN
    g.actor_faction_id = actor_id
    g.domain = domain
    g.title = "Développer le domaine %s (N1)" % domain

    g.steps = [
        _step("scout", "Explorer des sites", 2),
        _step("secure", "Sécuriser la zone", 1),
        _step("gather", "Rassembler des ressources", 2),
        _step("build", "Construire le bâtiment de domaine", 1),
    ]

    g.on_complete_world_tags = ["DOMAIN_%s_LEVEL1_BUILT" % domain.to_upper()]
    return g

static func _goal_gain_ally(actor_id: String) -> FactionGoal:
    var target := _pick_other(actor_id)

    var g := FactionGoal.new()
    g.id = "goal_gain_ally_%s_%s" % [actor_id, target]
    g.type = FactionGoal.GoalType.GAIN_ALLY
    g.actor_faction_id = actor_id
    g.target_faction_id = target
    g.title = "Nouer une alliance avec %s" % target

    g.steps = [
        _step("send_envoys", "Envoyer des émissaires", 2),
        _step("help", "Aider le partenaire (quêtes)", 2),
        _step("treaty", "Signer un traité", 1),
    ]
    g.on_complete_world_tags = ["ALLIANCE_FORGED"]
    g.on_complete_relation_delta = +20
    return g
    
static func create_build_domain_goal(actor_id: String, domain: String) -> FactionGoal:
    return _goal_build_domain(actor_id, domain)
    
static func _goal_start_war(actor_id: String) -> FactionGoal:
    var target := _pick_other(actor_id)

    var g := FactionGoal.new()
    g.id = "goal_start_war_%s_%s" % [actor_id, target]
    g.type = FactionGoal.GoalType.START_WAR
    g.actor_faction_id = actor_id
    g.target_faction_id = target
    g.title = "Préparer la guerre contre %s" % target

    g.steps = [
        _step("raids", "Mener des raids", 2),
        _step("mobilize", "Mobiliser les troupes", 1),
        _step("declare", "Déclarer la guerre", 1),
    ]
    g.on_complete_world_tags = ["WAR_DECLARED"]
    g.on_complete_relation_delta = -50
    return g

static func _step(id: String, title: String, required: int) -> FactionGoalStep:
    var s := FactionGoalStep.new()
    s.id = id
    s.title = title
    s.required_amount = required
    return s

static func _pick_other(actor_id: String) -> String:
    var ids := []
    for f in FactionManager.get_all_factions():
        if f.id != actor_id:
            ids.append(f.id)
    return ids.pick_random() if not ids.is_empty() else ""
