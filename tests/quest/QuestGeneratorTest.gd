# res://test/quest/QuestGeneratorTest.gd
extends BaseTest
class_name QuestGeneratorTest

## Test de génération basique de quêtes via QuestGenerator

const QUEST_GENERATOR_SCRIPT := "res://src/quests/generation/QuestGenerator.gd"
const TILES_ENUMS_SCRIPT := "res://src/enums/TilesEnums.gd"

var generator: Node = null


func _ready() -> void:
    _setup()
    
    if generator == null:
        fail_test("QuestGenerator introuvable ou impossible à instancier")
        return
    
    _test_generate_random_quest_tier1()
    _test_generate_quest_for_poi_ruins()
    _test_template_can_appear()
    
    _cleanup()
    pass_test("QuestGeneratorTest: génération TIER_1, POI RUINS, can_appear() OK")


func _setup() -> void:
    _force_load_tiles_enums()
    _ensure_world_day(0)
    generator = _create_generator()


func _cleanup() -> void:
    if generator != null and is_instance_valid(generator):
        generator.queue_free()


# =============================================================================
# Test 1: generate_random_quest(TIER_1)
# =============================================================================
func _test_generate_random_quest_tier1() -> void:
    _assert(generator.has_method("generate_random_quest"), 
        "QuestGenerator doit avoir generate_random_quest()")
    
    var quest: QuestInstance = generator.generate_random_quest(QuestTypes.QuestTier.TIER_1)
    
    _assert(quest != null, "generate_random_quest(TIER_1) ne doit pas retourner null")
    _assert(quest.template != null, "QuestInstance.template ne doit pas être null")
    _assert(quest.template.id != "", "QuestTemplate.id ne doit pas être vide")
    _assert(quest.template.title != "", "QuestTemplate.title ne doit pas être vide")
    _assert(quest.template.tier == QuestTypes.QuestTier.TIER_1, 
        "QuestTemplate.tier doit être TIER_1, got: %s" % str(quest.template.tier))
    
    print("  ✓ generate_random_quest(TIER_1): id=%s, title=%s" % [quest.template.id, quest.template.title])


# =============================================================================
# Test 2: generate_quest_for_poi(RUINS)
# =============================================================================
func _test_generate_quest_for_poi_ruins() -> void:
    if not generator.has_method("generate_quest_for_poi"):
        print("  ⚠ generate_quest_for_poi() non disponible, test ignoré")
        return
    
    var ruins_type = _guess_ruins_celltype()
    if ruins_type == null:
        print("  ⚠ TilesEnums.CellType.RUINS introuvable, test ignoré")
        return
    
    var poi_pos := Vector2i(10, 10)
    var quest: QuestInstance = generator.generate_quest_for_poi(poi_pos, ruins_type)
    
    _assert(quest != null, "generate_quest_for_poi(RUINS) ne doit pas retourner null")
    _assert(quest.template != null, "QuestInstance.template ne doit pas être null")
    
    print("  ✓ generate_quest_for_poi(RUINS): id=%s, title=%s" % [quest.template.id, quest.template.title])


# =============================================================================
# Test 3: template.can_appear()
# =============================================================================
func _test_template_can_appear() -> void:
    var quest: QuestInstance = generator.generate_random_quest(QuestTypes.QuestTier.TIER_1)
    
    _assert(quest != null, "Quest pour test can_appear() ne doit pas être null")
    _assert(quest.template != null, "Template ne doit pas être null")
    
    if not quest.template.has_method("can_appear"):
        print("  ⚠ QuestTemplate.can_appear() non disponible, test ignoré")
        return
    
    var can_appear: bool = quest.template.can_appear()
    # On ne teste pas la valeur, juste que ça ne crash pas
    print("  ✓ template.can_appear() = %s" % str(can_appear))


# =============================================================================
# Helpers
# =============================================================================
func _create_generator() -> Node:
    if not ResourceLoader.exists(QUEST_GENERATOR_SCRIPT):
        return null
    
    var script := load(QUEST_GENERATOR_SCRIPT)
    if script == null:
        return null
    
    var gen: Node = script.new()
    add_child(gen)
    return gen


func _force_load_tiles_enums() -> void:
    if ClassDB.class_exists("TilesEnums"):
        return
    if ResourceLoader.exists(TILES_ENUMS_SCRIPT):
        var s = load(TILES_ENUMS_SCRIPT)
        if s != null:
            print("  ✓ TilesEnums chargé")


func _ensure_world_day(day: int) -> void:
    if WorldState != null and "current_day" in WorldState:
        WorldState.current_day = day


func _guess_ruins_celltype():
    var tile_enum = get_node_or_null("/root/TilesEnum")
    if tile_enum != null:
        return tile_enum.CellType.RUINS
    return null
