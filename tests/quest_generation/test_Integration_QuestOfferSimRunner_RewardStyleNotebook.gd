extends BaseTest
class_name Integration_QuestOfferSimRunner_RewardStyleNotebook_Test

class StubArcNotebook:
    extends RefCounted
    var pair_events: Array = []

    func record_pair_event(day: int, a: StringName, b: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
        pair_events.append({"day": day, "a": a, "b": b, "action": action, "choice": choice, "meta": meta})

func _ready() -> void:
    _test_spawn_logs_reward_style_w_gold_dw_for_greedy()
    pass_test("✅ Integration_QuestOfferSimRunner_RewardStyleNotebook_Test: OK")

func _test_spawn_logs_reward_style_w_gold_dw_for_greedy() -> void:
    _assert(QuestOfferSimRunner != null, "Missing /root/QuestOfferSimRunner autoload")

    _assert(QuestManager != null, "Missing /root QuestManagerRunner (or QuestManager)")
    _assert(ArcManagerRunner != null, "Missing /root/ArcManagerRunner")
    _assert(FactionManager != null, "Missing /root/FactionManager")

    # --- snapshot & patch ArcNotebook ---
    var prev_notebook: ArcNotebook = ArcManagerRunner.arc_notebook
    var notebook: ArcNotebook = ArcNotebook.new()
    ArcManagerRunner.arc_notebook = notebook

    var rng := RandomNumberGenerator.new()
    rng.seed = 424242

    var giver := &"RICH_GREEDY"
    var target := &"TARGET"
    var day := 12
    var tier := 3
    var arc_action_type := &"arc.ultimatum"
    
    var arc_id := &"test_arc_001"
    var arc_state := ArcState.new()
    arc_state.a_id = giver
    arc_state.b_id = target
    arc_state.state = &"HOSTILE"
    arc_state.entered_day = day - 5
    
    var rel_ab := FactionRelationScore.new(target)
    rel_ab.set_score(FactionRelationScore.REL_RELATION, -30)
    rel_ab.set_score(FactionRelationScore.REL_TRUST, 20)
    rel_ab.set_score(FactionRelationScore.REL_TENSION, 50)

    # 3. Faction profiles (Dictionary: faction_id -> FactionProfile)
    var prof_greedy := FactionProfile.new()
    prof_greedy.personality[FactionProfile.PERS_AGGRESSION] = 0.95
    prof_greedy.personality[FactionProfile.PERS_RISK_AVERSION] = 0.15
    prof_greedy.personality[FactionProfile.PERS_DIPLOMACY] = 0.30
    
    var prof_target := FactionProfile.new()
    prof_target.personality[FactionProfile.PERS_DIPLOMACY] = 0.60
    
    var faction_profiles := {
        giver: prof_greedy,
        target: prof_target
    }
    # Overrides injectés uniquement pour le test (évite de dépendre de ton FactionManager)
    var econ_override := {"wealth_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}
    var profile_override := {"personality": {FactionProfile.PERS_GREED: 0.95, FactionProfile.PERS_OPPORTUNISM: 0.85,FactionProfile.PERS_HONOR: 0.20, FactionProfile.PERS_DISCIPLINE: 0.30}}

    var econ_rich := FactionEconomy.new(100)  # wealth/treasury initial
    var econ_target := FactionEconomy.new(50)
    
    var faction_economies := {
        giver: econ_rich,
        target: econ_target
    }
    
    # Dictionary pour RewardEconomyUtil.compute_reward_style (attend un Dictionary, pas FactionEconomy)
    var econ_rich_dict := {"wealth_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}
    
    # 5. Budget manager
    var budget_mgr := ArcOfferBudgetManager.new()
    
    # --- Appel avec tous les arguments ---
    var spawned: Array[QuestInstance] = ArcOfferFactory.spawn_offers_for_pair(
        arc_id,
        arc_state,
        giver,
        target,
        arc_action_type,
        rel_ab,
        faction_profiles,
        faction_economies,
        budget_mgr,
        rng,
        day,
        tier,
        {}  # params optionnel
    )

    # (Optionnel) si tu retournes la QuestInstance
    # _assert(offer != null, "spawn_offer_for_pair_from_params should return the spawned QuestInstance")

    # Assert: ArcNotebook a bien reçu l’event offer.reward_style avec w_gold_dw > 0
    var found := false
    for e in notebook.pair_events:
        if StringName(e.get("action", &"")) == &"offer.reward_style":
            var meta: Dictionary = e.get("meta", {})
            _assert(meta.has("w_gold_dw"), "offer.reward_style meta must include w_gold_dw")
            _assert(meta.has("w_gold"), "offer.reward_style meta must include w_gold")
            _assert(meta.has("tier"), "offer.reward_style meta must include tier")

            var dw := float(meta.get("w_gold_dw", 0.0))
            _assert(dw > 0.0, "Expected w_gold_dw > 0 for greedy profile (got %.4f)" % dw)
            found = true
            break

    _assert(found, "Expected ArcNotebook record_pair_event(action=offer.reward_style)")

    # Restore
    ArcManagerRunner.arc_notebook = prev_notebook

func _has_prop(obj: Object, prop: String) -> bool:
    for p in obj.get_property_list():
        if p.name == prop:
            return true
    return false
