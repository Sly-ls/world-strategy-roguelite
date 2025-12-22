# tests/Integration_OfferFactory_RewardStyleNotebook_Test.gd
extends BaseTest
class_name Integration_OfferFactory_RewardStyleNotebook_Test

func _ready() -> void:
    _test_spawn_logs_reward_style_with_w_gold_dw()
    pass_test("\n✅ Integration_OfferFactory_RewardStyleNotebook_Test: OK\n")


func _test_spawn_logs_reward_style_with_w_gold_dw() -> void:
    _assert(RewardEconomyUtilRunner != null, "Missing /root/RewardEconomyUtilRunner")
    _assert(ArcManagerRunner != null, "Missing /root/ArcManagerRunner")
    _assert(_has_prop(ArcManagerRunner, "arc_notebook"), "ArcManagerRunner must have var arc_notebook")

    # Patch notebook
    var prev_notebook = ArcManagerRunner.arc_notebook
    var notebook := ArcNotebook.new()
    ArcManagerRunner.arc_notebook = notebook

    # Find a factory that can spawn offers
    _assert(ArcOfferFactory != null, "No OfferFactory found in /root with spawn_offer_for_pair* method")

    # Prepare deterministic inputs
    var rng := RandomNumberGenerator.new()
    rng.seed = 424242

    var giver := &"RICH_GREEDY"
    var antagonist := &"TARGET"
    var day := 12
    var tier := 3
    var action_type := &"arc.truce_talks"

    # --- Préparer tous les arguments requis ---
    
    # 1. arc_id et arc_state
    var arc_id := &"test_arc_001"
    var arc_state := ArcState.new()
    arc_state.a_id = giver
    arc_state.b_id = antagonist
    arc_state.state = &"HOSTILE"
    arc_state.entered_day = day - 5
    
    # 2. FactionRelationScore entre giver et antagonist
    var rel_ab := FactionRelationScore.new(antagonist)
    rel_ab.relation = -30
    rel_ab.trust = 20
    rel_ab.tension = 50
    
    # 3. Faction profiles (Dictionary: faction_id -> FactionProfile)
    var prof_greedy := FactionProfile.new()
    prof_greedy.personality[FactionProfile.PERS_AGGRESSION] = 0.95
    prof_greedy.personality[FactionProfile.PERS_RISK_AVERSION] = 0.15
    prof_greedy.personality[FactionProfile.PERS_DIPLOMACY] = 0.30
    
    var prof_target := FactionProfile.new()
    prof_target.personality[FactionProfile.PERS_DIPLOMACY] = 0.60
    
    var faction_profiles := {
        giver: prof_greedy,
        antagonist: prof_target
    }
    
    # 4. Faction economies (Dictionary: faction_id -> FactionEconomy)
    # Créer de vrais objets FactionEconomy pour spawn_offers_for_pair
    var econ_rich := FactionEconomy.new(100)  # wealth/treasury initial
    var econ_target := FactionEconomy.new(50)
    
    var faction_economies := {
        giver: econ_rich,
        antagonist: econ_target
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
        antagonist,
        action_type,
        rel_ab,
        faction_profiles,
        faction_economies,
        budget_mgr,
        rng,
        day,
        tier,
        {}  # params optionnel
    )

    # On ne force pas l'assert sur spawned si ta factory push direct dans QuestPool,
    # mais ça aide si tu retournes l'instance.
    # _assert(not spawned.is_empty(), "spawn_offers_for_pair should return QuestInstances")

    # Assert: ArcNotebook event exists with w_gold_dw > 0
    var found := false
    for e in notebook.pair_events:
        if StringName(e.get("action", &"")) == &"offer.reward_style":
            var meta: Dictionary = e.get("meta", {})
            _assert(meta.has("w_gold_dw"), "offer.reward_style must include meta.w_gold_dw")
            _assert(meta.has("w_gold"), "offer.reward_style must include meta.w_gold")
            _assert(meta.has("w_gold_base"), "offer.reward_style must include meta.w_gold_base")

            var dw := float(meta.get("w_gold_dw", 0.0))
            _assert(dw > 0.0, "expected w_gold_dw > 0 for greedy profile (got %.4f)" % dw)

            # Bonus: verify it matches RewardEconomyUtil.compute_reward_style(...)
            var style := RewardEconomyUtil.compute_reward_style(econ_rich_dict, tier, prof_greedy)
            _assert(abs(float(style.w_gold_dw) - dw) < 0.0001, "w_gold_dw mismatch vs compute_reward_style")
            found = true
            break

    _assert(found, "expected ArcNotebook record_pair_event with action=offer.reward_style")

    # Restore notebook
    ArcManagerRunner.arc_notebook = prev_notebook


# ---------------- helpers ----------------

func _find_root_node_with_method(methods: Array) -> Node:
    var root := get_tree().root
    for child in root.get_children():
        for m in methods:
            if child != null and child.has_method(m):
                return child
    return null


func _has_prop(obj: Object, prop: String) -> bool:
    for p in obj.get_property_list():
        if p.name == prop:
            return true
    return false
