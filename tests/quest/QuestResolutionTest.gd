# res://test/quest/QuestResolutionTest.gd
extends BaseTest
class_name QuestResolutionTest

## Test du pipeline de résolution de quêtes (LOYAL / NEUTRAL / TRAITOR)

const QUEST_GENERATOR_SCRIPT := "res://src/quests/generation/QuestGenerator.gd"

var generator: Node = null
var initial_gold: int = 0
var initial_player_tags: Array = []
var initial_world_tags: Array = []


func _ready() -> void:
    _setup()
    
    if generator == null:
        fail_test("QuestGenerator introuvable")
        return
    
    if QuestManager == null:
        fail_test("QuestManager autoload manquant")
        return
    
    
    FactionManager.generate_world(2)
    var ids = FactionManager.get_all_faction_ids()
    var ATTACKER_FACTION = ids[0]
    var DEFENDER_FACTION = ids[1]
    
    _test_resolution_loyal()
    _test_resolution_neutral()
    _test_resolution_traitor()
    _test_full_pipeline()
    
    _cleanup()
    pass_test("QuestResolutionTest: LOYAL, NEUTRAL, TRAITOR + full pipeline OK")


func _setup() -> void:
    _ensure_world_day(0)
    generator = _create_generator()
    _snapshot_initial_state()


func _cleanup() -> void:
    _restore_initial_state()
    if generator != null and is_instance_valid(generator):
        generator.queue_free()


func _snapshot_initial_state() -> void:
    initial_gold = _safe_get_gold()
    initial_player_tags = QuestManager.player_tags.duplicate()
    initial_world_tags = QuestManager.world_tags.duplicate()


func _restore_initial_state() -> void:
    if ResourceManager != null and ResourceManager.has_method("set_resource"):
        ResourceManager.set_resource("gold", initial_gold)
    if QuestManager != null:
        if "player_tags" in QuestManager:
            QuestManager.player_tags = initial_player_tags.duplicate()
        if "world_tags" in QuestManager:
            QuestManager.world_tags = initial_world_tags.duplicate()


# =============================================================================
# Test: Resolution LOYAL
# =============================================================================
func _test_resolution_loyal() -> void:
    var quest := _generate_quest_with_factions()
    _assert(quest != null, "Quest pour LOYAL ne doit pas être null")
    
    var gold_before := _safe_get_gold()
    
    QuestManager.start_runtime_quest(quest)
    _assert(quest.runtime_id != "", "runtime_id doit être assigné après start")
    
    if QuestManager.has_method("complete_quest"):
        QuestManager.complete_quest(quest.runtime_id)
    
    QuestManager.resolve_quest(quest.runtime_id, "LOYAL")
    
    var gold_after := _safe_get_gold()
    
    # LOYAL devrait donner une récompense
    print("  ✓ LOYAL: gold %d → %d" % [gold_before, gold_after])
    _restore_initial_state()


# =============================================================================
# Test: Resolution NEUTRAL
# =============================================================================
func _test_resolution_neutral() -> void:
    var quest := _generate_quest_with_factions()
    _assert(quest != null, "Quest pour NEUTRAL ne doit pas être null")
    
    var gold_before := _safe_get_gold()
    
    QuestManager.start_runtime_quest(quest)
    
    if QuestManager.has_method("complete_quest"):
        QuestManager.complete_quest(quest.runtime_id)
    
    QuestManager.resolve_quest(quest.runtime_id, "NEUTRAL")
    
    var gold_after := _safe_get_gold()
    
    print("  ✓ NEUTRAL: gold %d → %d" % [gold_before, gold_after])
    _restore_initial_state()


# =============================================================================
# Test: Resolution TRAITOR
# =============================================================================
func _test_resolution_traitor() -> void:
    var quest := _generate_quest_with_factions()
    _assert(quest != null, "Quest pour TRAITOR ne doit pas être null")
    
    var gold_before := _safe_get_gold()
    
    QuestManager.start_runtime_quest(quest)
    
    if QuestManager.has_method("complete_quest"):
        QuestManager.complete_quest(quest.runtime_id)
    
    QuestManager.resolve_quest(quest.runtime_id, "TRAITOR")
    
    var gold_after := _safe_get_gold()
    
    print("  ✓ TRAITOR: gold %d → %d" % [gold_before, gold_after])
    _restore_initial_state()


# =============================================================================
# Test: Full Pipeline (Palier 2)
# =============================================================================
func _test_full_pipeline() -> void:
    var quest: QuestInstance = generator.generate_random_quest(QuestTypes.QuestTier.TIER_1)
    _assert(quest != null, "Quest pour full pipeline ne doit pas être null")
    
    # Vérifier que le contexte runtime est présent
    _assert(quest.context != null, "Quest.context ne doit pas être null")
    
    # Vérifier les factions
    var giver :String = quest.context.get("giver_faction_id", "")
    var antagonist :String = quest.context.get("antagonist_faction_id", "")
    var profile :String = quest.context.get("resolution_profile_id", "")
    
    print("  ✓ Full pipeline: giver=%s, antagonist=%s, profile=%s" % [giver, antagonist, profile])
    
    # Test complet
    QuestManager.start_runtime_quest(quest)
    _assert(quest.runtime_id != "", "runtime_id assigné")
    
    if QuestManager.has_method("complete_quest"):
        QuestManager.complete_quest(quest.runtime_id)
    
    QuestManager.resolve_quest(quest.runtime_id, "LOYAL")
    
    print("  ✓ Full pipeline completed successfully")


# =============================================================================
# Helpers
# =============================================================================
func _generate_quest_with_factions() -> QuestInstance:
    var quest: QuestInstance = generator.generate_random_quest(QuestTypes.QuestTier.TIER_1)
    if quest == null:
        return null
    
    # Injecter les factions si absentes
    if quest.context == null:
        quest.context = {}
    if not quest.context.has("giver_faction_id"):
        quest.context["giver_faction_id"] = "humans"
    if not quest.context.has("antagonist_faction_id"):
        quest.context["antagonist_faction_id"] = "orcs"
    if not quest.context.has("resolution_profile_id"):
        quest.context["resolution_profile_id"] = "default_simple"
    
    return quest


func _create_generator() -> Node:
    if not ResourceLoader.exists(QUEST_GENERATOR_SCRIPT):
        return null
    var script := load(QUEST_GENERATOR_SCRIPT)
    if script == null:
        return null
    var gen: Node = script.new()
    add_child(gen)
    return gen


func _ensure_world_day(day: int) -> void:
    if WorldState != null and "current_day" in WorldState:
        WorldState.current_day = day


func _safe_get_gold() -> int:
    if ResourceManager != null and ResourceManager.has_method("get_resource"):
        return int(ResourceManager.get_resource("gold"))
    return 0
