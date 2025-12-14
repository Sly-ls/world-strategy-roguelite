extends Resource
class_name QuestResolutionRule

@export var id: String

# filtres
@export var allowed_categories: Array[QuestTypes.QuestCategory] = []
@export var allowed_tiers: Array[QuestTypes.QuestTier] = []

@export var requires_antagonist: bool = false
@export var requires_giver: bool = false

@export var required_world_tags: Array[String] = []
@export var forbidden_world_tags: Array[String] = []

@export var required_context_tags: Array[String] = []
@export var forbidden_context_tags: Array[String] = []

# résultat
@export var resolution_profile_id: String

func matches(context: Dictionary) -> bool:
    # category
    if allowed_categories.size() > 0 and not allowed_categories.has(context.category):
        return false

    # tier
    if allowed_tiers.size() > 0 and not allowed_tiers.has(context.tier):
        return false

    # giver / antagonist
    if requires_giver and context.giver_faction_id == "":
        return false
    if requires_antagonist and context.antagonist_faction_id == "":
        return false

    # tags monde
    for tag in required_world_tags:
        if not QuestManager.has_world_tag(tag):
            return false

    for tag in forbidden_world_tags:
        if QuestManager.has_world_tag(tag):
            return false

    for tag in required_context_tags:
        if not context.tags.has(tag):
            return false

    for tag in forbidden_context_tags:
        if context.tags.has(tag):
            return false

    return true
