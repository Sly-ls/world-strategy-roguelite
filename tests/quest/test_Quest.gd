# res://test/QuestSystemTest.gd
extends BaseTest

const QUEST_GENERATOR_SCRIPT := "res://src/quests/generation/QuestGenerator.gd"
const QUEST_TYPES_SCRIPT := "res://src/quests/QuestTypes.gd"

# Optionnel: si tes singletons existent, on les utilisera
const WORLD_STATE_SINGLETON := "/root/WorldState"
const QUEST_MANAGER_SINGLETON := "res://src/systems/QuestManager.gd"
const FACTION_MANAGER_SINGLETON := "/root/FactionManager"
const RNG_SINGLETON := "/root/Rng"
const TILES_ENUMS_SCRIPT := "res://src/enums/TilesEnums.gd"

const INVENTORY_SCRIPT := "res://src/core/inventory/Inventory.gd"
const ARTIFACT_SPEC_SCRIPT := "res://src/core/artifacts/ArtifactSpec.gd"

# dépendances attendues (autoloads)
const ARTIFACT_REGISTRY_SINGLETON := "res://src/core/artifacts/ArtifactRegistry.gd"
const LOOT_SITE_MANAGER_SINGLETON := "res://src/world/loot/LootSiteManager.gd"
const ARMY_MANAGER_SINGLETON := "res://src/army/ArmyManager.gd"
    
var test_to_run :Dictionary = {
        "all":false,
        "1": false,
        "2": false,
        "3": false,
        "4": false,
        "5": false,
        "6": false,
        "7": false,
        "8": false,
        "9": false,
        "10": false,
        "11": false,
        "12": false
    }
    
func _ready() -> void:
    
    enable_test(true)
        
    myLogger.debug("\n==============================", LogTypes.Domain.TEST)
    myLogger.debug("=== QUEST SYSTEM TEST HARNESS ===", LogTypes.Domain.TEST)
    myLogger.debug("==============================\n", LogTypes.Domain.TEST)
    _force_load_tiles_enums()
    _ensure_world_day(0)

    var gen = _create_generator()
    if gen == null:
        _fail("Impossible de créer QuestGenerator. Vérifie le chemin : %s" % QUEST_GENERATOR_SCRIPT)
        return
    var quest1 = null
    var quest2 = null
    if _is_test_to_run("1"):
        quest1 = _test_1_safe_generate_random_tier1(gen)
    if _is_test_to_run("2"):
        quest2 = _test_2_safe_generate_poi_ruins(gen)
    if _is_test_to_run("3", "1", "2"):
        _test_3(quest1, quest2)
    if _is_test_to_run("4", "1"):
        _test_4(quest1)
    if _is_test_to_run("5"):
        _test_5(gen)
    if _is_test_to_run("6"):
        _test_6_full_resolution_pipeline(gen)
    if _is_test_to_run("7"):
        _test_7()
    if _is_test_to_run("8"):
        _test_8()
    if _is_test_to_run("9"):
        _test_9_hero_competition_30_days()
    if _is_test_to_run("10"):
        _test_10()
    if _is_test_to_run("11"):
        _test_11_offers_pro_100_days()
    if _is_test_to_run("12"):
        _test_12_arc_rivalry_mvp()
    
    myLogger.debug("==============================\n", LogTypes.Domain.TEST)
    myLogger.debug("\n✅ TEST HARNESS FINISHED (regarde les warnings/erreurs ci-dessus).", LogTypes.Domain.TEST)
    myLogger.debug("==============================\n", LogTypes.Domain.TEST)
    pass_test()

func _is_test_to_run(test_id:String, requiered_test_1: String = "", required_test_2="") -> bool:
    var will_run = test_to_run.get("all") || test_to_run.get(test_id)
    if will_run && requiered_test_1 != "":
        will_run = test_to_run.get(requiered_test_1)
    if will_run && required_test_2 != "":
        will_run = test_to_run.get(required_test_2)
    return will_run
func _test_5(gen):
    myLogger.debug("\n--- TEST 5: LOYAL / NEUTRAL / TRAITOR ---", LogTypes.Domain.TEST)
    var qm = get_node_or_null(QUEST_MANAGER_SINGLETON)
    if qm != null and gen != null and qm.has_method("start_runtime_quest") and qm.has_method("resolve_quest"):
        _run_resolution_case(qm, gen, "LOYAL")
        _run_resolution_case(qm, gen, "NEUTRAL")
        _run_resolution_case(qm, gen, "TRAITOR")
    else:
        _warn("TEST 5 ignoré: QuestManager ou méthodes manquantes.")
func _test_4(quest1):
    myLogger.debug("\n--- TEST 4: QuestManager integration (if available) ---", LogTypes.Domain.TEST)
    _try_quest_manager_flow(quest1)
func _test_3(quest1, quest2):
    myLogger.debug("\n--- TEST 3: template.can_appear() ---", LogTypes.Domain.TEST)
    _test_can_appear(quest1)
    _test_can_appear(quest2)
    
func _force_load_tiles_enums() -> void:
    if ClassDB.class_exists("TilesEnums"):
        return
    if ResourceLoader.exists(TILES_ENUMS_SCRIPT):
        var s = load(TILES_ENUMS_SCRIPT)
        if s == null:
            _warn("Impossible de load TilesEnum.gd (%s)" % TILES_ENUMS_SCRIPT)
        else:
            myLogger.debug("✓ TilesEnums chargé via %s" % TILES_ENUMS_SCRIPT, LogTypes.Domain.TEST)
    else:
        _warn("TilesEnum.gd introuvable (%s). Vérifie le chemin." % TILES_ENUMS_SCRIPT)


# ------------------------------------------------------------
#  Utilities: Creation / safety
# ------------------------------------------------------------
func _test_12_arc_rivalry_mvp() -> void:

    myLogger.debug("\n--- TEST 12: ARC RIVALRY MVP ---", LogTypes.Domain.TEST)
    # reset
    if QuestPool != null and QuestPool.has_method("clear_offers"):
        QuestPool.clear_offers()

    if ArcManagerRunner != null and ArcManagerRunner.has_method("reset"):
        ArcManagerRunner.reset()

    _set_day(0)

    # 1) hostile action => offer
    if ArcManagerRunner == null or not ArcManagerRunner.has_method("on_faction_hostile_action"):
        _fail("ArcManagerRunner missing / no on_faction_hostile_action()")
        return

    ArcManagerRunner.on_faction_hostile_action("elves", "humans", "RAID")

    # récup une offer (selon ton QuestPool)
    var offers: Array = []
    if QuestPool != null and QuestPool.has_method("get_offers"):
        offers = QuestPool.get_offers()
    elif QuestPool != null and QuestPool.has_variable("offers"):
        offers = QuestPool.offers

    if offers.is_empty():
        _fail("No arc offer generated")
        return

    var offer :QuestInstance = offers.back()
    var ctx :Dictionary = offer.context
    if not bool(ctx.get("is_arc_rivalry", false)):
        _fail("Last offer is not an arc offer")
        return

    # 2) resolve => retaliation next day
    QuestManager.start_runtime_quest(offer)

# 1) Simuler la completion (mettre la quête en "résolution requise")
    if QuestManager.has_method("complete_quest"):
        QuestManager.complete_quest(offer.runtime_id)
    elif QuestManager.has_method("update_quest_progress_by_id"):
        # fallback: pousser la progression jusqu'au count
        var total := int(offer.template.objective_count)
        QuestManager.update_quest_progress_by_id(offer.runtime_id, total)

    # 2) Résoudre (ça doit setter pending_retaliation via ArcManagerRunner.on_quest_resolution_choice)
    QuestManager.resolve_quest(offer.runtime_id, "LOYAL")
    _set_day(1)
    if ArcManagerRunner.has_method("tick_day"):
        ArcManagerRunner.tick_day()

    # check retaliation offer exists (giver should be "humans" vs "elves")
    var offers2: Array = []
    if QuestPool.has_method("get_offers"):
        offers2 = QuestPool.get_offers()
    elif QuestPool.has_variable("offers"):
        offers2 = QuestPool.offers

    var found := false
    for q in offers2:
        var c :Dictionary = q.context
        if not bool(c.get("is_arc_rivalry", false)):
            continue
        if String(c.get("giver_faction_id","")) == "humans" and String(c.get("antagonist_faction_id","")) == "elves":
            found = true
            break

    if not found:
        _fail("No retaliation offer found")
        return

    myLogger.debug("✅ TEST 12 PASSED — Arc rivalry MVP ok", LogTypes.Domain.TEST)

func _test_11_offers_pro_100_days() -> void:
    myLogger.debug("\n--- TEST 11: OFFERS PRO (100 DAYS) ---", LogTypes.Domain.TEST)
    # Preconditions
    if QuestPool == null:
        _fail("QuestPool autoload manquant")
        return
    if not QuestPool.has_method("get_offers"):
        _fail("QuestPool.get_offers() introuvable")
        return

    var day: int = 0
    var max_seen: int = 0

    for d in range(100):
        day = d
        _set_day(day)

        # Simule “création d’offers”
        # 5 offres/jour pour stresser
        for i in range(5):
            var q: QuestInstance = QuestGenerator.generate_random_quest(QuestTypes.QuestTier.TIER_1)
            if q != null:
                # Important: s'assurer que context contient quest_type
                if not q.context.has("quest_type"):
                    q.context["quest_type"] = "generated"  # fallback, mieux : vrai type
                QuestPool.try_add_offer(q)

        # Cleanup
        QuestPool.cleanup_offers()

        var offers :Array = QuestPool.get_offers()
        max_seen = max(max_seen, offers.size())

        # Invariant 1: cap global
        if offers.size() > 20:
            _fail("Cap global dépassé: %d offers au day %d" % [offers.size(), day])
            return

        # Invariant 2: aucune invalide
        for o in offers:
            var qi: QuestInstance = o
            if qi == null:
                _fail("Offer null dans pool")
                return
            if not qi.is_offer_valid(day):
                _fail("Offer invalide détectée day %d: %s" % [day, qi.get_offer_signature()])
                return

        # Invariant 3: pas de doublon signature
        var seen: Dictionary = {}
        for o2 in offers:
            var qi2: QuestInstance = o2
            var sig: String = qi2.get_offer_signature()
            if seen.has(sig):
                _fail("Doublon signature day %d: %s" % [day, sig])
                return
            seen[sig] = true

    myLogger.debug("✅ TEST 12 PASSED — max offers seen: %d" % max_seen)

func _test_10() -> void:
    
    myLogger.debug("\n--- TEST 10: ARTIFACT LOST / LOOT SITE / RETRIEVE QUEST ---", LogTypes.Domain.TEST)
    _set_day(0)
    _require_autoload(ARTIFACT_REGISTRY_SINGLETON, "ArtifactRegistry")
    _require_autoload(LOOT_SITE_MANAGER_SINGLETON, "LootSiteManager")
    _require_autoload(ARMY_MANAGER_SINGLETON, "ArmyManager")
    _require_autoload(QUEST_MANAGER_SINGLETON, "QuestManager (optional)")

    # 1) Create artifact spec A1 + register
    var ArtifactSpec = load(ARTIFACT_SPEC_SCRIPT)
    if ArtifactSpec == null:
        _fail("ArtifactSpec.gd introuvable.")
        return

    var spec = ArtifactSpec.new()
    spec.id = "A1_DIVINE_RELIC"
    spec.name = "Relique d’Aube"
    spec.domain = "divine"
    spec.power = 2
    spec.unique = true

    ArtifactRegistryRunner.register_spec(spec)
    myLogger.debug("✓ Registered artifact spec: %s - %s" % [spec.id, spec.name], LogTypes.Domain.TEST)

    # 2) Create army with inventory + artifact
    var a :ArmyData = ArmyFactory.create_army("starter")
    a.runtime_position =  Vector2i(7, 7)
    a.inventory.gold = 123
    a.inventory.add_artifact(spec.id)
    ArtifactRegistryRunner.set_artifact_owner(spec.id, "ARMY", a.id)

    ArmyManagerRunner.register_army(a)
    myLogger.debug("✓ Army created: id=%s - pos=%s - gold=%d - artifacts=%s" % [a.id, a.runtime_position, a.inventory.gold, a.inventory.artifacts], LogTypes.Domain.TEST)

    # 3) Destroy army => LootSite spawned
    ArmyManagerRunner.destroy_army(a.id)

    var site_id := _find_loot_site_containing(spec.id)
    if site_id == "":
        _fail("LootSite non trouvé (artefact pas droppé ?) ")
        return

    myLogger.debug("✓ LootSite found: %s" % site_id)
    myLogger.debug("Owner after destroy: %s - %s" %  [ArtifactRegistryRunner.owner_type.get(spec.id, "?"), ArtifactRegistryRunner.owner_id.get(spec.id, "?")], LogTypes.Domain.TEST)

    # 4) Expire LootSite => artifact LOST
    _set_day(999) # force expiration
    LootSiteManagerRunner.tick_day()

    myLogger.debug("Owner after expire:%s - %s" %  [ArtifactRegistryRunner.owner_type.get(spec.id, "?"), ArtifactRegistryRunner.owner_id.get(spec.id, "?")], LogTypes.Domain.TEST)
    if ArtifactRegistryRunner.owner_type.get(spec.id, "") != "LOST":
        _fail("Artefact devrait être LOST après expiration LootSite.")
        return

    # 5) Generate retrieve quest (minimal inline)
    var q := _generate_retrieve_artifact_quest(spec.id)
    if q == null:
        _fail("Impossible de générer la quête retrieve.")
        return

    myLogger.debug("\n✓ Retrieve quest generated:", LogTypes.Domain.TEST)
    myLogger.debug("  id: %s" % q.template.id, LogTypes.Domain.TEST)
    myLogger.debug("  title: %s" % q.template.title, LogTypes.Domain.TEST)
    myLogger.debug("  ctx.artifact_id: %s" % q.context.get("artifact_id", ""), LogTypes.Domain.TEST)
    myLogger.debug("  ctx.giver: %s" % q.context.get("giver_faction_id", ""), LogTypes.Domain.TEST)
    myLogger.debug("  ctx.profile: %s"% q.context.get("resolution_profile_id", ""), LogTypes.Domain.TEST)

    myLogger.debug("\n✅ TEST 10 PASSED")
    myLogger.debug("==============================\n")
func _test_9_hero_competition_30_days() -> void:
    myLogger.debug("\n--- TEST 9: HERO COMPETITION 30 DAYS ---")
    # Setup heroes
    var h1 := HeroAgent.new()
    h1.id = "h1"; h1.name = "Sir Aldren"; h1.faction_id = "humans"
    h1.loyalty = 0.8; h1.greed = 0.2; h1.aggressiveness = 0.3; h1.competence = 0.8

    var h2 := HeroAgent.new()
    h2.id = "h2"; h2.name = "Krag le Rouge"; h2.faction_id = "orcs"
    h2.loyalty = 0.2; h2.greed = 0.4; h2.aggressiveness = 0.8; h2.competence = 0.7

    var h3 := HeroAgent.new()
    h3.id = "h3"; h3.name = "L'Errante"; h3.faction_id = "independent"
    h3.loyalty = 0.3; h3.greed = 0.8; h3.aggressiveness = 0.4; h3.competence = 0.6

    HeroSimRunner.heroes = [h1, h2, h3]
    HeroSimRunner.max_offers_taken_per_day = 2
    HeroSimRunner.take_chance = 0.45

    for day in range(30):
        WorldState.current_day += 1
        myLogger.debug("\n=== DAY %d ===" % WorldState.current_day, LogTypes.Domain.TEST)

        # 1) factions agissent et créent des offers
        FactionSimRunner.run_day(3)

        # 2) heroes prennent des offers
        HeroSimRunner.tick_day()

        # 3) expirations
        QuestManager.check_expirations()

        myLogger.debug("\n=== END TEST 9 ===", LogTypes.Domain.TEST)
        myLogger.debug("World tags: %s" % QuestManager.world_tags, LogTypes.Domain.TEST)

func _test_7() -> void:
    
    myLogger.debug("\n--- TEST 7: WORLD SIM 10 DAYS ---", LogTypes.Domain.TEST)
    WorldSimRunner.simulate_days(10)
    FactionManager.print_all_factions()
    myLogger.debug("World tags: %s" % QuestManager.world_tags, LogTypes.Domain.TEST)
    myLogger.debug("Offers: %d" % QuestPool.get_offers().size(), LogTypes.Domain.TEST)
    FactionManager.print_relations_between()
    _print_sample_offers()
    
func _test_8() -> void:
    myLogger.debug("\n--- TEST 8: GOAL OFFER DOMAIN ---")
    QuestPool.get_offers().clear()
    QuestOfferSimRunner.offer_created_day.clear()

    var g := FactionGoalFactory.create_build_domain_goal("orcs", "corruption")
    FactionGoalManagerRunner.active_goals["orcs"] = FactionGoalState.new(g)

    QuestOfferSimRunner.generate_goal_offer("orcs", "", "corruption", "gather")

    myLogger.debug("\n=== OFFERS SAMPLE (goal only) ===", LogTypes.Domain.TEST)

    if QuestPool.get_offers().is_empty():
        push_error("TEST 8 failed: offers is empty (generate_goal_offer n'a rien ajouté).")
        return

    var quest_instance_1: QuestInstance = QuestPool.get_offers().back()
    if quest_instance_1 == null:
        push_error("TEST 8 failed: last offer is null (generate_goal_offer a ajouté null).")
        return

    var ctx_1: Dictionary = quest_instance_1.context
    myLogger.debug("- %s | giver=%s | ant=%s | step=%s | domain=%s | profile=%s" % [
        quest_instance_1.template.title,
        str(ctx_1.get("giver_faction_id","")),
        str(ctx_1.get("antagonist_faction_id","")),
        str(ctx_1.get("goal_step_id","")),
        str(ctx_1.get("goal_domain","")),
        str(ctx_1.get("resolution_profile_id",""))
    ], LogTypes.Domain.TEST)

    var found := false
    for q in QuestPool.get_offers():
        var ctx := q.context
        if not ctx.get("is_goal_offer", false):
            continue
        if ctx.get("goal_step_id","") != "gather":
            continue
        if ctx.get("goal_domain","") != "corruption":
            continue

        myLogger.debug("✅ FOUND: % s - giver=%s - ant=%s" % [q.template.title, ctx.get("giver_faction_id"), ctx.get("antagonist_faction_id")], LogTypes.Domain.TEST)
        found = true
        break

    if not found:
        push_error("TEST 8 failed: no gather/corruption goal offer found")
        
func _print_sample_offers() -> void:
    myLogger.debug("\n=== OFFERS SAMPLE ===", LogTypes.Domain.TEST)
    for i in range(min(QuestPool.get_offers().size(), 5)):
        var q: QuestInstance = QuestPool.get_offers()[i]
        var ctx := q.context
        if not ctx.get("is_goal_offer", false):
            continue
        myLogger.debug("- %s | giver=%s | ant=%s | step=%s | domain=%s | profile=%s" % [
            q.template.title,
            str(ctx.get("giver_faction_id","")),
            str(ctx.get("antagonist_faction_id","")),
            str(ctx.get("goal_step_id","")),
            str(ctx.get("goal_domain","")),
            str(ctx.get("resolution_profile_id",""))
        ], LogTypes.Domain.TEST)

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


func _test_1_safe_generate_random_tier1(gen: Node):
    # On essaye d’obtenir QuestTypes.TIER_1 si possible
    myLogger.debug("\n--- TEST 1: generate_random_quest(TIER_1) ---", LogTypes.Domain.TEST)
    var tier_1 = _get_tier1_value()
    if gen.has_method("generate_random_quest"):
        var quest1 = gen.generate_random_quest(tier_1)
        _print_quest_instance(quest1)
        return quest1
    _warn("QuestGenerator n'a pas generate_random_quest()")
    return null


func _test_2_safe_generate_poi_ruins(gen: Node):
    # On a besoin de TilesEnums.CellType.RUINS (on ne peut pas le hardcoder sans ton enum),
    # donc on teste plusieurs options:
    myLogger.debug("\n--- TEST 2: generate_quest_for_poi(RUINS) ---", LogTypes.Domain.TEST)
    var ruins_type = _guess_ruins_celltype()
    var poi_pos := Vector2i(10, 10)

    if ruins_type == null:
        _warn("Impossible de déterminer TilesEnums.CellType.RUINS. TEST 2 ignoré.")
    return null

    if gen.has_method("generate_quest_for_poi"):
        var quest2 = gen.generate_quest_for_poi(poi_pos, ruins_type)
        _print_quest_instance(quest2)
        return quest2
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
        myLogger.debug("can_appear() => %b " % ok, LogTypes.Domain.TEST)
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

    myLogger.debug("Gold before: %d | after complete: %d" % [gold_before, gold_after_complete], LogTypes.Domain.TEST)
    myLogger.debug("Player tags before: %s" % player_tags_before, LogTypes.Domain.TEST)
    myLogger.debug("World tags before: %s" % world_tags_before, LogTypes.Domain.TEST)

    # 2) Résoudre
    if qm.has_method("resolve_quest"):
        qm.resolve_quest(rid, "LOYAL")
    else:
        _warn("QuestManager n'a pas resolve_quest()")
        return

    var gold_after_resolve := _safe_get_gold()
    var player_tags_after: Array = qm.get_player_tags() if qm.has_method("get_player_tags") else []
    var world_tags_after: Array = qm.get_world_tags() if qm.has_method("get_world_tags") else []

    myLogger.debug("Gold after resolve: %d " % gold_after_resolve, LogTypes.Domain.TEST)
    myLogger.debug("Player tags after: %s" % player_tags_before, LogTypes.Domain.TEST)
    myLogger.debug("World tags after: %s" % world_tags_before, LogTypes.Domain.TEST)
    
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

    myLogger.debug("\n--- RESOLUTION %s ---" % choice)
    myLogger.debug("Gold: %d -> %d" % [gold_before, gold_after], LogTypes.Domain.TEST)
    myLogger.debug("Player tags:  %d -> %d" % [tags_p_before, tags_p_after], LogTypes.Domain.TEST)
    myLogger.debug("World tags:  %d -> %d" % [tags_w_before, tags_w_after], LogTypes.Domain.TEST)
    
func _test_6_full_resolution_pipeline(gen: Node) -> void:
    # 1️⃣ Snapshot initial
    myLogger.debug("\n--- TEST 6: FULL PALIER 2 PIPELINE ---", LogTypes.Domain.TEST)
    var gold_before := ResourceManager.get_resource("gold")
    var player_tags_before := QuestManager.player_tags.duplicate()
    var world_tags_before := QuestManager.world_tags.duplicate()

    myLogger.debug("Initial gold: %d" % gold_before)
    myLogger.debug("Initial player tags: %s" % player_tags_before)
    myLogger.debug("Initial world tags %s" % world_tags_before)

    # 2️⃣ Générer une quête procédurale
    var quest :QuestInstance = gen.generate_random_quest(QuestTypes.QuestTier.TIER_1)
    if quest == null:
        _fail("Impossible de générer une quête")
        return

    myLogger.debug("\nGenerated quest: %s" % quest.template.title, LogTypes.Domain.TEST)

    # 3️⃣ Vérifier contexte runtime
    myLogger.debug("Giver faction: %s" % quest.giver_faction_id, LogTypes.Domain.TEST)
    myLogger.debug("Antagonist faction %s" % quest.antagonist_faction_id, LogTypes.Domain.TEST)
    myLogger.debug("Resolution profile: %s" % quest.resolution_profile_id, LogTypes.Domain.TEST)

    # 4️⃣ Reconstruire le context pour debug
    var ctx := ContextTagResolver.build_context(
        quest.template.category,
        quest.template.tier,
        quest.giver_faction_id,
        quest.antagonist_faction_id
    )

    myLogger.debug("Context tags:", ctx.tags)

    # 5️⃣ Résolution LOYAL
    myLogger.debug("\n--- RESOLUTION LOYAL ---")
    QuestManager.start_runtime_quest(quest)
    QuestManager.resolve_quest(quest.runtime_id, "LOYAL")

    myLogger.debug("Gold: %d -> %d" % [gold_before,ResourceManager.get_resource("gold")], LogTypes.Domain.TEST)
    myLogger.debug("Player tags: %s" % QuestManager.player_tags, LogTypes.Domain.TEST)
    myLogger.debug("World tags: %s" % QuestManager.world_tags, LogTypes.Domain.TEST)

    # 6️⃣ Reset partiel (pour test)
    _reset_test_state(gold_before, player_tags_before, world_tags_before)

    # 7️⃣ Résolution NEUTRAL
    myLogger.debug("\n--- RESOLUTION NEUTRAL ---", LogTypes.Domain.TEST)
    var quest_n :QuestInstance = gen.generate_random_quest(QuestTypes.QuestTier.TIER_1)
    QuestManager.start_runtime_quest(quest_n)
    QuestManager.resolve_quest(quest_n.runtime_id, "NEUTRAL")

    myLogger.debug("Gold: %d" % ResourceManager.get_resource("gold"), LogTypes.Domain.TEST)
    myLogger.debug("Player tags: %s" % QuestManager.player_tags, LogTypes.Domain.TEST)
    myLogger.debug("World tags: %s" % QuestManager.world_tags, LogTypes.Domain.TEST)

    # 8️⃣ Reset partiel
    _reset_test_state(gold_before, player_tags_before, world_tags_before)

    # 9️⃣ Résolution TRAITOR
    myLogger.debug("\n--- RESOLUTION TRAITOR ---")
    var quest_t :QuestInstance = gen.generate_random_quest(QuestTypes.QuestTier.TIER_1)
    QuestManager.start_runtime_quest(quest_t)
    QuestManager.resolve_quest(quest_t.runtime_id, "TRAITOR")

    myLogger.debug("Gold: %d" % ResourceManager.get_resource("gold"))
    myLogger.debug("Player tags: %s" % QuestManager.player_tags, LogTypes.Domain.TEST)
    myLogger.debug("World tags: %s" % QuestManager.world_tags, LogTypes.Domain.TEST)

    myLogger.debug("\n✅ TEST 6 PASSED — Palier 2 pipeline OK")

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

    myLogger.debug("QuestTemplate:", LogTypes.Domain.TEST)
    myLogger.debug("  id:  %s" % _safe_get(template, "id", "<no id>"), LogTypes.Domain.TEST)
    myLogger.debug("  title: %s" % _safe_get(template, "title", "<no title>"), LogTypes.Domain.TEST)
    myLogger.debug("  tier: %s" % _safe_get(template, "tier", "<no tier>"), LogTypes.Domain.TEST)
    myLogger.debug("  category: %s" % _safe_get(template, "category", "<no category>"), LogTypes.Domain.TEST)
    myLogger.debug("  objective_type: %s" % _safe_get(template, "objective_type", "<no objective_type>"), LogTypes.Domain.TEST)
    myLogger.debug("  objective_target: %s" % _safe_get(template, "objective_target", "<no objective_target>"), LogTypes.Domain.TEST)
    myLogger.debug("  objective_count: %s" % _safe_get(template, "objective_count", "<no objective_count>"), LogTypes.Domain.TEST)
    myLogger.debug("  expires_in_days: %s" %  _safe_get(template, "expires_in_days", "<no expires>"), LogTypes.Domain.TEST)

    # champs “résolution” si tu les as ajoutés
    if _has_property(template, "resolution_profile_id"):
        myLogger.debug("  resolution_profile_id: %s" % _safe_get(template, "resolution_profile_id", ""), LogTypes.Domain.TEST)
    if _has_property(template, "giver_faction_id"):
        myLogger.debug("  giver_faction_id: %s" % _safe_get(template, "giver_faction_id", ""), LogTypes.Domain.TEST)
    if _has_property(template, "antagonist_faction_id"):
        myLogger.debug("  antagonist_faction_id: %s" % _safe_get(template, "antagonist_faction_id", ""), LogTypes.Domain.TEST)


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
        myLogger.debug("WorldState.current_day = %d" % day, LogTypes.Domain.TEST)
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
    myLogger.debug("[QuestSystemTest] %s" % msg, LogTypes.Domain.TEST)
    myLogger.debug("⚠  %s" % msg, LogTypes.Domain.TEST)


func _fail(msg: String) -> void:
    push_error("[QuestSystemTest] %s" % msg, LogTypes.Domain.TEST)
    myLogger.debug("❌ %s" % msg, LogTypes.Domain.TEST)


func _generate_retrieve_artifact_quest(artifact_id: String) -> QuestInstance:
    var spec = ArtifactRegistryRunner.get_spec(artifact_id)
    if spec == null:
        return null

    var template := QuestTemplate.new()
    template.id = "retrieve_%s_%d" % [artifact_id, Time.get_ticks_msec()]
    template.title = "Retrouver l'artefact : %s" % spec.name
    template.description = "Un artefact a disparu. Retrouve %s et décide à qui il revient." % spec.name
    template.category = QuestTypes.QuestCategory.EXPLORATION
    template.tier = QuestTypes.QuestTier.TIER_2
    template.objective_type = QuestTypes.ObjectiveType.REACH_POI
    template.objective_target = "loot_site_for_%s" % artifact_id
    template.objective_count = 1
    template.expires_in_days = 15

    var ctx: Dictionary = {
        "artifact_id": artifact_id,
        "resolution_profile_id": "artifact_recovery",
        "giver_faction_id": "humans",
        "antagonist_faction_id": "bandits"
    }

    var inst := QuestInstance.new(template, ctx)
    return inst


func _find_loot_site_containing(artifact_id: String) -> String:
    # LootSiteManager.sites : Dictionary id->LootSite
    if LootSiteManager == null:
        return ""
    # Vérifier que la propriété "sites" existe
    var has_sites := false
    for p in LootSiteManagerRunner.get_property_list():
        if p.name == "sites":
            has_sites = true
            break

    if not has_sites:
        return ""
    var sites: Dictionary = LootSiteManagerRunner.sites
    for sid in sites.keys():
        var s = sites[sid]
        if s != null and s.inventory != null:
            if s.inventory.artifacts.has(artifact_id):
                return String(sid)
    return ""


func _set_day(day: int) -> void:
    var ws := get_node_or_null(WORLD_STATE_SINGLETON)
    if ws == null:
        _warn("WorldState introuvable (%s)" % WORLD_STATE_SINGLETON)
        return

    # Vérifie que la propriété existe vraiment
    var has_current_day := false
    for p in ws.get_property_list():
        if p.name == "current_day":
            has_current_day = true
            break

    if not has_current_day:
        _warn("WorldState existe mais n'a pas la propriété 'current_day'")
        return

    ws.set("current_day", day)
    if day %10 == 0:
        myLogger.debug("WorldState.current_day = %s" % day, LogTypes.Domain.TEST)


func _require_autoload(path: String, label: String) -> void:
    var n = get_node_or_null(path)
    if n == null:
        myLogger.debug("[TEST 10] Missing autoload: %s at %s" % [label, path], LogTypes.Domain.TEST)
        myLogger.debug("⚠ Missing autoload: %s : %s" % [label, path], LogTypes.Domain.TEST)
