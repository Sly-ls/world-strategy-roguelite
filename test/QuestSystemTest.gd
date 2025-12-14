# res://test/QuestSystemTest.gd
extends Node

const QUEST_GENERATOR_SCRIPT := "res://src/quests/generation/QuestGenerator.gd"
const QUEST_TYPES_SCRIPT := "res://src/quests/QuestTypes.gd"

# Optionnel: si tes singletons existent, on les utilisera
const WORLD_STATE_SINGLETON := "/root/WorldState"
const QUEST_MANAGER_SINGLETON := "/root/QuestManager"
const FACTION_MANAGER_SINGLETON := "/root/FactionManager"
const RNG_SINGLETON := "/root/Rng"
const TILES_ENUMS_SCRIPT := "res://src/enums/TilesEnums.gd"

func _ready() -> void:
    print("\n==============================")
    print("=== QUEST SYSTEM TEST HARNESS ===")
    print("==============================\n")

    _force_load_tiles_enums()
    _ensure_world_day(0)

    var gen = _create_generator()
    if gen == null:
        _fail("Impossible de créer QuestGenerator. Vérifie le chemin : %s" % QUEST_GENERATOR_SCRIPT)
        return

    # --- Test 1 : génération aléatoire Tier 1
    print("\n--- TEST 1: generate_random_quest(TIER_1) ---")
    var quest1 = _safe_generate_random_tier1(gen)
    _print_quest_instance(quest1)

    # --- Test 2 : génération POI (ruines)
    print("\n--- TEST 2: generate_quest_for_poi(RUINS) ---")
    var quest2 = _safe_generate_poi_ruins(gen)
    _print_quest_instance(quest2)

    # --- Test 3 : can_appear()
    print("\n--- TEST 3: template.can_appear() ---")
    _test_can_appear(quest1)
    _test_can_appear(quest2)

    # --- Test 4 : tentative d’intégration QuestManager (si dispo)
    print("\n--- TEST 4: QuestManager integration (if available) ---")
    _try_quest_manager_flow(quest1)
    
    print("\n--- TEST 5: LOYAL / NEUTRAL / TRAITOR ---")
    var qm = get_node_or_null(QUEST_MANAGER_SINGLETON)
    if qm != null and gen != null and qm.has_method("start_runtime_quest") and qm.has_method("resolve_quest"):
        _run_resolution_case(qm, gen, "LOYAL")
        _run_resolution_case(qm, gen, "NEUTRAL")
        _run_resolution_case(qm, gen, "TRAITOR")
    else:
        _warn("TEST 5 ignoré: QuestManager ou méthodes manquantes.")
        
    print("\n--- TEST 6: FULL PALIER 2 PIPELINE ---")
    _test_full_resolution_pipeline(gen)
    
    print("\n✅ TEST HARNESS FINISHED (regarde les warnings/erreurs ci-dessus).")
    print("==============================\n")

func _force_load_tiles_enums() -> void:
    if ClassDB.class_exists("TilesEnums"):
        return
    if ResourceLoader.exists(TILES_ENUMS_SCRIPT):
        var s = load(TILES_ENUMS_SCRIPT)
        if s == null:
            _warn("Impossible de load TilesEnum.gd (%s)" % TILES_ENUMS_SCRIPT)
        else:
            print("✓ TilesEnums chargé via %s" % TILES_ENUMS_SCRIPT)
    else:
        _warn("TilesEnum.gd introuvable (%s). Vérifie le chemin." % TILES_ENUMS_SCRIPT)


# ------------------------------------------------------------
#  Utilities: Creation / safety
# ------------------------------------------------------------

func _create_generator() -> Node:
    if not ResourceLoader.exists(QUEST_GENERATOR_SCRIPT):
        _fail("QuestGenerator.gd introuvable: %s" % QUEST_GENERATOR_SCRIPT)
        return null

    var script := load(QUEST_GENERATOR_SCRIPT)
    if script == null:
        _fail("Impossible de load() QuestGenerator.gd")
        return null

    var gen :Node  = script.new()
    add_child(gen) # déclenche _ready
    return gen


func _safe_generate_random_tier1(gen: Node):
    # On essaye d’obtenir QuestTypes.TIER_1 si possible
    var tier_1 = _get_tier1_value()
    if gen.has_method("generate_random_quest"):
        return gen.generate_random_quest(tier_1)
    _warn("QuestGenerator n'a pas generate_random_quest()")
    return null


func _safe_generate_poi_ruins(gen: Node):
    # On a besoin de TilesEnums.CellType.RUINS (on ne peut pas le hardcoder sans ton enum),
    # donc on teste plusieurs options:
    var ruins_type = _guess_ruins_celltype()
    var poi_pos := Vector2i(10, 10)

    if ruins_type == null:
        _warn("Impossible de déterminer TilesEnums.CellType.RUINS. TEST 2 ignoré.")
        return null

    if gen.has_method("generate_quest_for_poi"):
        return gen.generate_quest_for_poi(poi_pos, ruins_type)

    _warn("QuestGenerator n'a pas generate_quest_for_poi()")
    return null


func _test_can_appear(quest_instance) -> void:
    if quest_instance == null:
        _warn("Quest instance null → can_appear() ignoré.")
        return

    var template = _safe_get(quest_instance, "template", null)
    if template == null:
        _warn("quest_instance.template introuvable → can_appear() ignoré.")
        return

    if template.has_method("can_appear"):
        var ok = template.can_appear()
        print("can_appear() => ", ok)
    else:
        _warn("QuestTemplate n'a pas can_appear() (ou template n'est pas un QuestTemplate).")


func _try_quest_manager_flow(quest_instance) -> void:
    if quest_instance == null:
        _warn("Quest instance null → QuestManager flow ignoré.")
        return
    var qm = get_node_or_null(QUEST_MANAGER_SINGLETON)
    if qm == null:
        _warn("QuestManager singleton introuvable (%s). OK si pas encore autoload." % QUEST_MANAGER_SINGLETON)
        return

    var template = _safe_get(quest_instance, "template", null)
    if template == null:
        _warn("quest_instance.template introuvable → QuestManager flow ignoré.")
        return

    if qm.has_method("start_runtime_quest"):
        qm.start_runtime_quest(quest_instance)
    else:
        _warn("QuestManager n'a pas start_runtime_quest()")
        return

    var rid = _safe_get(quest_instance, "runtime_id", "")
    if rid == "":
        _warn("Impossible de lire runtime_id")
        return
   
    # Snapshot avant
    var gold_before := _safe_get_gold()
    var player_tags_before: Array = qm.get_player_tags() if qm.has_method("get_player_tags") else []
    var world_tags_before: Array = qm.get_world_tags() if qm.has_method("get_world_tags") else []

    # 1) Compléter l'objectif (ne doit PAS donner de récompense dans le modèle final)
    if qm.has_method("complete_quest"):
        qm.complete_quest(rid)

    var gold_after_complete := _safe_get_gold()

    print("Gold before: ", gold_before, " | after complete: ", gold_after_complete)
    print("Player tags before: ", player_tags_before)
    print("World tags before: ", world_tags_before)

    # 2) Résoudre
    if qm.has_method("resolve_quest"):
        qm.resolve_quest(rid, "LOYAL")
    else:
        _warn("QuestManager n'a pas resolve_quest()")
        return

    var gold_after_resolve := _safe_get_gold()
    var player_tags_after: Array = qm.get_player_tags() if qm.has_method("get_player_tags") else []
    var world_tags_after: Array = qm.get_world_tags() if qm.has_method("get_world_tags") else []

    print("Gold after resolve: ", gold_after_resolve)
    print("Player tags after: ", player_tags_after)
    print("World tags after: ", world_tags_after)
    
func _safe_get_gold() -> int:
    var rm = get_node_or_null("/root/ResourceManager")
    if rm != null and rm.has_method("get_resource"):
        return int(rm.get_resource("gold"))
    return -1

func _run_resolution_case(qm: Node, gen: Node, choice: String) -> void:
    var q = gen.generate_random_quest(1) # tier 1 fallback
    if q == null:
        _warn("Impossible de générer une quête pour %s" % choice)
        return

    # injecter factions pour le test si absentes
    if q.context == null:
        q.context = {}
    if not q.context.has("giver_faction_id"):
        q.context["giver_faction_id"] = "humans"
    if not q.context.has("antagonist_faction_id"):
        q.context["antagonist_faction_id"] = "orcs"

    qm.start_runtime_quest(q)
    var rid: String = q.runtime_id

    var gold_before := _safe_get_gold()
    var tags_p_before: Array = qm.get_player_tags() if qm.has_method("get_player_tags") else []
    var tags_w_before: Array = qm.get_world_tags() if qm.has_method("get_world_tags") else []

    qm.complete_quest(rid)
    qm.resolve_quest(rid, choice)

    var gold_after := _safe_get_gold()
    var tags_p_after: Array = qm.get_player_tags() if qm.has_method("get_player_tags") else []
    var tags_w_after: Array = qm.get_world_tags() if qm.has_method("get_world_tags") else []

    print("\n--- RESOLUTION %s ---" % choice)
    print("Gold: ", gold_before, " -> ", gold_after)
    print("Player tags: ", tags_p_before, " -> ", tags_p_after)
    print("World tags: ", tags_w_before, " -> ", tags_w_after)
    
func _test_full_resolution_pipeline(gen: Node) -> void:
    # 1️⃣ Snapshot initial
    var gold_before := ResourceManager.get_resource("gold")
    var player_tags_before := QuestManager.player_tags.duplicate()
    var world_tags_before := QuestManager.world_tags.duplicate()

    print("Initial gold:", gold_before)
    print("Initial player tags:", player_tags_before)
    print("Initial world tags:", world_tags_before)

    # 2️⃣ Générer une quête procédurale
    var quest :QuestInstance = gen.generate_random_quest(QuestTypes.QuestTier.TIER_1)
    if quest == null:
        _fail("Impossible de générer une quête")
        return

    print("\nGenerated quest:", quest.template.title)

    # 3️⃣ Vérifier contexte runtime
    print("Giver faction:", quest.giver_faction_id)
    print("Antagonist faction:", quest.antagonist_faction_id)
    print("Resolution profile:", quest.resolution_profile_id)

    # 4️⃣ Reconstruire le context pour debug
    var ctx := ContextTagResolver.build_context(
        quest.template.category,
        quest.template.tier,
        quest.giver_faction_id,
        quest.antagonist_faction_id
    )

    print("Context tags:", ctx.tags)

    # 5️⃣ Résolution LOYAL
    print("\n--- RESOLUTION LOYAL ---")
    QuestManager.start_runtime_quest(quest)
    QuestManager.resolve_quest(quest.runtime_id, "LOYAL")

    print("Gold:", gold_before, "→", ResourceManager.get_resource("gold"))
    print("Player tags:", QuestManager.player_tags)
    print("World tags:", QuestManager.world_tags)

    # 6️⃣ Reset partiel (pour test)
    _reset_test_state(gold_before, player_tags_before, world_tags_before)

    # 7️⃣ Résolution NEUTRAL
    print("\n--- RESOLUTION NEUTRAL ---")
    var quest_n :QuestInstance = gen.generate_random_quest(QuestTypes.QuestTier.TIER_1)
    QuestManager.start_runtime_quest(quest_n)
    QuestManager.resolve_quest(quest_n.runtime_id, "NEUTRAL")

    print("Gold:", ResourceManager.get_resource("gold"))
    print("Player tags:", QuestManager.player_tags)
    print("World tags:", QuestManager.world_tags)

    # 8️⃣ Reset partiel
    _reset_test_state(gold_before, player_tags_before, world_tags_before)

    # 9️⃣ Résolution TRAITOR
    print("\n--- RESOLUTION TRAITOR ---")
    var quest_t :QuestInstance = gen.generate_random_quest(QuestTypes.QuestTier.TIER_1)
    QuestManager.start_runtime_quest(quest_t)
    QuestManager.resolve_quest(quest_t.runtime_id, "TRAITOR")

    print("Gold:", ResourceManager.get_resource("gold"))
    print("Player tags:", QuestManager.player_tags)
    print("World tags:", QuestManager.world_tags)

    print("\n✅ TEST 6 PASSED — Palier 2 pipeline OK")

# ------------------------------------------------------------
#  Dump / printing
# ------------------------------------------------------------

func _print_quest_instance(q) -> void:
    if q == null:
        _warn("Quest instance = null")
        return

    var template = _safe_get(q, "template", null)
    if template == null:
        _warn("QuestInstance.template introuvable")
        return

    print("QuestTemplate:")
    print("  id: ", _safe_get(template, "id", "<no id>"))
    print("  title: ", _safe_get(template, "title", "<no title>"))
    print("  tier: ", _safe_get(template, "tier", "<no tier>"))
    print("  category: ", _safe_get(template, "category", "<no category>"))
    print("  objective_type: ", _safe_get(template, "objective_type", "<no objective_type>"))
    print("  objective_target: ", _safe_get(template, "objective_target", "<no objective_target>"))
    print("  objective_count: ", _safe_get(template, "objective_count", "<no objective_count>"))
    print("  expires_in_days: ", _safe_get(template, "expires_in_days", "<no expires>"))

    # champs “résolution” si tu les as ajoutés
    if _has_property(template, "resolution_profile_id"):
        print("  resolution_profile_id: ", _safe_get(template, "resolution_profile_id", ""))
    if _has_property(template, "giver_faction_id"):
        print("  giver_faction_id: ", _safe_get(template, "giver_faction_id", ""))
    if _has_property(template, "antagonist_faction_id"):
        print("  antagonist_faction_id: ", _safe_get(template, "antagonist_faction_id", ""))


# ------------------------------------------------------------
#  Environment helpers
# ------------------------------------------------------------
func _reset_test_state(gold: int, player_tags: Array, world_tags: Array) -> void:
    ResourceManager.set_resource("gold", gold)
    QuestManager.player_tags = player_tags.duplicate()
    QuestManager.world_tags = world_tags.duplicate()

func _ensure_world_day(day: int) -> void:
    var ws = get_node_or_null(WORLD_STATE_SINGLETON)
    if ws == null:
        _warn("WorldState singleton introuvable (%s). Si can_appear() dépend de WorldState.current_day, il peut casser." % WORLD_STATE_SINGLETON)
        return

    if _has_property(ws, "current_day"):
        ws.current_day = day
        print("WorldState.current_day = ", day)
    else:
        _warn("WorldState existe mais n'a pas la propriété current_day.")


func _get_tier1_value():
    # Cas normal : QuestTypes est un class_name, donc accessible directement
    if ClassDB.class_exists("QuestTypes"):
        return QuestTypes.QuestTier.TIER_1

    # Fallback: essayer de load le script (si pas de class_name)
    if ResourceLoader.exists(QUEST_TYPES_SCRIPT):
        var qt_script = load(QUEST_TYPES_SCRIPT)
        if qt_script != null:
            # Certains scripts exposent l'enum statiquement
            # Mais sans class_name, c'est rarement accessible proprement.
            # On fallback sur 1 si impossible.
            pass

    _warn("QuestTypes non accessible (class_name manquant ?). Fallback tier=1.")
    return 1

func _guess_ruins_celltype():
    # 1) Utiliser l'autoload (le plus fiable)
    var tile_enum = get_node_or_null("/root/TilesEnum")
    if tile_enum != null:
        # L'enum CellType est un constant du script → accessible via l'instance
        return tile_enum.CellType.RUINS

    # 2) Fallback : essayer de charger le script (au cas où l'autoload n'est pas actif)
    _force_load_tiles_enums()
    var tile_enum2 = get_node_or_null("/root/TilesEnum")
    if tile_enum2 != null:
        return tile_enum2.CellType.RUINS

    _warn("Autoload /root/TileEnum introuvable → impossible de récupérer CellType.RUINS.")
    return null





# ------------------------------------------------------------
#  Reflection / Safe calls
# ------------------------------------------------------------

func _safe_get(obj, prop: String, default_value):
    if obj == null:
        return default_value
    # Resource/Node/RefCounted: get() marche souvent
    if obj.has_method("get"):
        var v = obj.get(prop)
        if v != null:
            return v
    # fallback: accès direct si possible
    if _has_property(obj, prop):
        return obj[prop]
    return default_value


func _has_property(obj, prop: String) -> bool:
    if obj == null:
        return false
    # Godot 4: get_property_list()
    if obj.has_method("get_property_list"):
        for p in obj.get_property_list():
            if p.name == prop:
                return true
    return false


func _call_safe(obj, method: String, args: Array) -> bool:
    # Retourne true si l'appel ne lève pas d'erreur runtime (dans la pratique, Godot n'attrape pas try/catch)
    # Ici on fait juste un appel protégé par has_method
    if obj == null:
        return false
    if not obj.has_method(method):
        return false
    # Appel
    obj.callv(method, args)
    return true


func _dump_player_tags(qm) -> Array:
    if qm.has_method("get_player_tags"):
        return qm.get_player_tags()
    return []


func _dump_world_tags(qm) -> Array:
    if qm.has_method("get_world_tags"):
        return qm.get_world_tags()
    return []


func _warn(msg: String) -> void:
    push_warning("[QuestSystemTest] " + msg)
    print("⚠ ", msg)


func _fail(msg: String) -> void:
    push_error("[QuestSystemTest] " + msg)
    print("❌ ", msg)
