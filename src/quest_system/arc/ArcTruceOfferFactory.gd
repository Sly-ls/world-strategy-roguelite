# ArcTruceOfferFactory.gd (mini pour test)
class_name ArcTruceOfferFactory
extends RefCounted

static func spawn_truce_offer_if_needed(
    faction_id: StringName,
    target_id: StringName,
    domestic_state,
    day: int,
    quest_pool,
    arc_notebook = null
):
    var p := float(domestic_state.pressure())
    if p < 0.65 and int(domestic_state.war_support) > 25:
        return null

    # cooldown simple
    if arc_notebook != null and arc_notebook.has_method("can_spawn_truce_offer"):
        if not arc_notebook.can_spawn_truce_offer(faction_id, target_id, day, 6):
            return null

    var template := DomesticOfferFactory._build_template_fallback(&"arc.truce_talks", 2, 6)
    template.category = &"ARC"

    var ctx := {
        "is_arc_offer": true,
        "arc_action_type": &"arc.truce_talks",
        "giver_faction_id": faction_id,
        "antagonist_faction_id": target_id,
        "tier": 2,
        "expires_in_days": 6,
    }

    var inst := QuestInstance.new(template, ctx)
    inst.status = "AVAILABLE"
    inst.started_on_day = day
    inst.expires_on_day = day + 6

    if quest_pool != null and quest_pool.has_method("try_add_offer"):
        if not quest_pool.try_add_offer(inst):
            return null

    if arc_notebook != null and arc_notebook.has_method("mark_truce_offer_spawned"):
        arc_notebook.mark_truce_offer_spawned(faction_id, target_id, day)

    return inst
