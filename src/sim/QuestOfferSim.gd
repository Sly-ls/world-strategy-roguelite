# res://src/sim/QuestOfferSim.gd
extends Node
class_name QuestOfferSim

var offers: Array[QuestInstance] = []
var consumed_offers: Dictionary = {} # runtime_id -> {"by": hero_id, "day": int}
@export var max_offers: int = 10
var offer_created_day: Dictionary = {} # runtime_id -> day

func generate_offers(n: int) -> void:
    if QuestGenerator == null:
        return

    for i in range(n):
        var q: QuestInstance = QuestGenerator.generate_random_quest(QuestTypes.QuestTier.TIER_1)
        if q == null ||  offer_created_day.has(q.runtime_id):
            continue
        QuestPool.try_add_offer(q)

func is_consumed(runtime_id: String) -> bool:
    return consumed_offers.has(runtime_id)

func take_offer(index: int) -> QuestInstance:
    if index < 0 or index >= offers.size():
        return null
    var q := offers[index]
    offers.remove_at(index)
    return q

func tick_day() -> void:
    # 1) Expire offers
    var day := WorldState.current_day
    var to_remove: Array[int] = []

    for i in range(offers.size()):
        var q: QuestInstance = offers[i]
        var created := int(offer_created_day.get(q.runtime_id, day))

        var expires_in := q.template.expires_in_days
        if expires_in > 0 and day >= created + expires_in:
            to_remove.append(i)

    # remove from end to start
    for j in range(to_remove.size() - 1, -1, -1):
        var idx := to_remove[j]
        var q := offers[idx]
        offer_created_day.erase(q.runtime_id)
        offers.remove_at(idx)

    # 2) Cap
    while offers.size() > max_offers:
        var removed :QuestInstance = offers.pop_front()
        offer_created_day.erase(removed.runtime_id)

func generate_goal_offer(actor_id: String, target_id: String, domain: String, step_id: String, tier: QuestTypes.QuestTier = QuestTypes.QuestTier.TIER_1) -> void:
    if QuestGenerator == null:
        return

    # 1) choisir quest_type selon step
    var quest_type := _pick_quest_type_for_step(step_id)

    # 2) construire contexte résolution + tags custom
    var category := _guess_category_for_step(step_id)
    var ctx := ContextTagResolver.build_context(category, tier, actor_id, target_id)
    
    #verification de l'antagonist
    var antagonist := target_id
    if antagonist == "" or antagonist == actor_id:
        antagonist = QuestGenerator._pick_hostile_faction() # si accessible
        if antagonist == actor_id:
            antagonist = "bandits"
            
    # tags supplémentaires (facultatif mais très utile)
    ctx.tags.append("GOAL_STEP_%s" % step_id.to_upper())
    if domain != "":
        ctx.tags.append("DOMAIN_%s" % domain.to_upper())
    if target_id != "":
        ctx.tags.append("TARGET_%s" % target_id.to_upper())

    # 3) choisir profil
    var profile_id := ResolutionRuleFactory.pick_profile(ctx)

    # 4) overrides runtime (giver/antagonist/profile + metadata)
    var overrides := {
        "tier": tier,
        "giver_faction_id": actor_id,
        "antagonist_faction_id": antagonist,
        "resolution_profile_id": profile_id,
        "goal_step_id": step_id,
        "goal_domain": domain,
        "goal_target_faction_id": target_id,
        "is_goal_offer": true
    }

    var q: QuestInstance = QuestGenerator.generate_quest_of_type(quest_type, tier, overrides)
    if q == null:
        return
        
    print("📜 Offer(goal) -> %s | step=%s | giver=%s | ant=%s | profile=%s" % [
        quest_type,
        step_id,
        actor_id,
        antagonist,
        profile_id
    ])

    var sig := "%s|%s|%s|%s|%d" % [actor_id, target_id, quest_type, step_id, WorldState.current_day]
    for existing in offers:
        var c := existing.context
        if c.get("offer_sig","") == sig:
            return
    q.context["offer_sig"] = sig
    QuestPool.try_add_offer(q)
    offer_created_day[q.runtime_id] = WorldState.current_day

func get_available_offers() -> Array[QuestInstance]:
    var out: Array[QuestInstance] = []
    for q in offers:
        if q == null:
            continue
        if consumed_offers.has(q.runtime_id):
            continue
        out.append(q)
    return out

func consume_offer(runtime_id: String, by_id: String) -> void:
    consumed_offers[runtime_id] = {"by": by_id, "day": WorldState.current_day}
    # option A: on laisse dans offers mais marqué consommé (pratique pour debug)
    # option B: on retire de offers (plus clean pour gameplay)
    # Ici: option B
    for i in range(offers.size()):
        if offers[i] and offers[i].runtime_id == runtime_id:
            offers.remove_at(i)
            break

func _pick_quest_type_for_step(step_id: String) -> String:
    match step_id:
        "gather":
            return "generic_collection"
        "scout":
            return "generic_exploration"
        "raids", "declare":
            return "generic_combat"
        "send_envoys", "treaty":
            return "faction_diplomacy"
        "help":
            # aide peut être collection/exploration/diplomacy, simple pour l’instant
            return "generic_collection"
        _:
            return "generic_exploration"

func _guess_category_for_step(step_id: String) -> QuestTypes.QuestCategory:
    match step_id:
        "raids", "declare":
            return QuestTypes.QuestCategory.COMBAT
        "send_envoys", "treaty":
            return QuestTypes.QuestCategory.DIPLOMATIC
        "gather":
            return QuestTypes.QuestCategory.DELIVERY
        _:
            return QuestTypes.QuestCategory.EXPLORATION
