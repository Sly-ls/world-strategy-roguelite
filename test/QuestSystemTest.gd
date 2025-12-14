# res://test/QuestSystemTest.gd
extends Node

const QUEST_GENERATOR_SCRIPT := "res://src/quests/generation/QuestGenerator.gd"
const QUEST_TYPES_SCRIPT := "res://src/quests/QuestTypes.gd"

# Optionnel: si tes singletons existent, on les utilisera
const WORLD_STATE_SINGLETON := "/root/WorldState"
const QUEST_MANAGER_SINGLETON := "/root/QuestManager"
const FACTION_MANAGER_SINGLETON := "/root/FactionManager"
const RNG_SINGLETON := "/root/Rng"

func _ready() -> void:
    print("\n==============================")
    print("=== QUEST SYSTEM TEST HARNESS ===")
    print("==============================\n")

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

    print("\n✅ TEST HARNESS FINISHED (regarde les warnings/erreurs ci-dessus).")
    print("==============================\n")


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
    # On a besoin de GameEnums.CellType.RUINS (on ne peut pas le hardcoder sans ton enum),
    # donc on teste plusieurs options:
    var ruins_type = _guess_ruins_celltype()
    var poi_pos := Vector2i(10, 10)

    if ruins_type == null:
        _warn("Impossible de déterminer GameEnums.CellType.RUINS. TEST 2 ignoré.")
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

    # Essai: start_quest(template.id, context/params)
    var template_id = _safe_get(template, "id", "")
    var context = _safe_get(quest_instance, "context", null)
    if context == null:
        # fallback si ton QuestInstance stocke params plutôt que context
        context = _safe_get(quest_instance, "params", {})

    print("QuestManager detected. template.id=", template_id)

    if qm.has_method("start_quest"):
        print("→ Calling QuestManager.start_quest(...)")
        # on essaye différents formats sans casser
        var started = false
        # start_quest(id, context)
        if _call_safe(qm, "start_quest", [template_id, context]):
            started = true
        # start_quest(template_id) fallback
        elif _call_safe(qm, "start_quest", [template_id]):
            started = true

        if not started:
            _warn("start_quest() existe mais la signature ne matche pas (ou a échoué).")
    else:
        _warn("QuestManager n'a pas start_quest().")

    # Essai: resolve_quest / complete_quest si présent
    var choice := "NEUTRAL"
    if qm.has_method("resolve_quest"):
        print("→ Calling QuestManager.resolve_quest(..., %s)" % choice)
        _call_safe(qm, "resolve_quest", [quest_instance, choice])
    elif qm.has_method("complete_quest"):
        print("→ Calling QuestManager.complete_quest(...)")
        _call_safe(qm, "complete_quest", [quest_instance])
    else:
        _warn("QuestManager n'a ni resolve_quest() ni complete_quest(). (Normal si pas encore implémenté)")

    # Dump tags si méthodes dispo
    if qm.has_method("has_player_tag") or qm.has_method("get_player_tags"):
        print("Player tags snapshot: ", _dump_player_tags(qm))
    if qm.has_method("has_world_tag") or qm.has_method("get_world_tags"):
        print("World tags snapshot: ", _dump_world_tags(qm))


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
    # On essaye GameEnums.CellType.RUINS via la classe globale.
    # Si GameEnums n'est pas accessible ici, on ne peut pas deviner proprement.
    if not Engine.has_singleton("GameEnums"):
        # pas un vrai singleton dans Godot, donc on tente via ClassDB:
        pass

    # Tentative: accéder à la classe GameEnums (si class_name GameEnums)
    if ClassDB.class_exists("GameEnums"):
        var ge = GameEnums
        if ge and ge.has("CellType"):
            # accès enum direct (si possible)
            return GameEnums.CellType.RUINS

    # Dernier recours: certains projets ont CellType en global
    _warn("GameEnums.CellType.RUINS non accessible depuis le test (class_name GameEnums manquant ?).")
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
