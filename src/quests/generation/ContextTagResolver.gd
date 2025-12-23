extends Node
class_name ContextTagResolver

static func build_context(
    category: QuestTypes.QuestCategory,
    tier: QuestTypes.QuestTier,
    giver_faction_id: String,
    antagonist_faction_id: String
) -> Dictionary:
    var ctx := {
        "category": category,
        "tier": tier,
        "giver_faction_id": giver_faction_id,
        "antagonist_faction_id": antagonist_faction_id,
        "tags": []
    }

    _add_world_tags(ctx)
    _add_player_tags(ctx)
    _add_faction_tags(ctx)

    return ctx
    
static func _add_world_tags(ctx: Dictionary) -> void:
    if QuestManager.has_world_tag("WORLD_CORRUPTED"):
        ctx.tags.append("WORLD_CORRUPTED")

    if QuestManager.has_world_tag("WORLD_UNSTABLE"):
        ctx.tags.append("WORLD_UNSTABLE")

    if QuestManager.has_world_tag("DIVINE_DOMINANT"):
        ctx.tags.append("DIVINE_DOMINANT")
        
static func _add_player_tags(ctx: Dictionary) -> void:
    if QuestManager.has_player_tag("TRAITOR"):
        ctx.tags.append("PLAYER_TRAITOR")

    if QuestManager.has_player_tag("INDEPENDENT"):
        ctx.tags.append("PLAYER_INDEPENDENT")

    if QuestManager.has_player_tag("HEROIC"):
        ctx.tags.append("PLAYER_HEROIC")
static func _add_faction_tags(ctx: Dictionary) -> void:
    var giver: String = str(ctx.get("giver_faction_id", ""))
    var ant: String = str(ctx.get("antagonist_faction_id", ""))

    if giver == "" or ant == "" or giver == ant:
        return

    var rel: int = FactionManager.get_relation(giver, ant).get_score(FactionRelationScore.REL_TRUST)

    if rel <= -50:
        ctx["tags"].append("FACTION_AT_WAR")
    elif rel < 0:
        ctx["tags"].append("FACTION_HOSTILE")
    else:
        ctx["tags"].append("FACTION_PEACEFUL")
