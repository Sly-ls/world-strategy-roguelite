extends BaseTest
class_name Integration_OfferFactory_RewardStyleNotebook_Test

class StubArcNotebook:
    extends RefCounted
    var pair_events: Array = []

    func record_pair_event(day: int, a: StringName, b: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
        pair_events.append({
            "day": day, "a": a, "b": b,
            "action": action, "choice": choice,
            "meta": meta
        })

func _ready() -> void:
    _test_spawn_logs_reward_style_with_w_gold_dw()
    print("\n✅ Integration_OfferFactory_RewardStyleNotebook_Test: OK\n")
    get_tree().quit()

func _test_spawn_logs_reward_style_with_w_gold_dw() -> void:
    _assert(ClassDB.class_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

    var arc_mgr := get_node_or_null("/root/ArcManagerRunner")
    _assert(arc_mgr != null, "Missing /root/ArcManagerRunner")
    _assert(_has_prop(arc_mgr, "arc_notebook"), "ArcManagerRunner must have var arc_notebook")

    # Patch notebook
    var prev_notebook = arc_mgr.get("arc_notebook")
    var notebook := StubArcNotebook.new()
    arc_mgr.set("arc_notebook", notebook)

    # Find a factory that can spawn offers
    var factory := _find_root_node_with_method(["spawn_offer_for_pair", "spawn_offer_for_pair_from_params"])
    _assert(factory != null, "No OfferFactory found in /root with spawn_offer_for_pair* method")

    # Prepare deterministic inputs
    var rng := RandomNumberGenerator.new()
    rng.seed = 424242

    var giver := &"RICH_GREEDY"
    var antagonist := &"TARGET"
    var day := 12
    var tier := 3
    var action_type := &"arc.truce_talks"

    var econ_rich := {"wealth_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}
    var param_greedy : = {"personality": {&"greed": 0.95, &"opportunism": 0.85, &"discipline": 0.30, &"honor": 0.25}}

    # Spawn (vraie méthode)
    var spawned = null

    # Option A (recommandé): méthode “test-friendly”
    if factory.has_method("spawn_offer_for_pair_from_params"):
        spawned = factory.call("spawn_offer_for_pair_from_params", {
            "giver_faction_id": giver,
            "antagonist_faction_id": antagonist,
            "arc_action_type": action_type,
            "tier": tier,
            "day": day,
            "econ_override": econ_rich,
            "profile_override": param_greedy,
            "rng": rng
        })
    else:
        # Option B: spawn_offer_for_pair(...) – on passe les args “classiques”
        # 👉 Si ta signature diffère, adapte les paramètres ici une fois (le test reste utile).
        spawned = factory.call("spawn_offer_for_pair",
            giver, antagonist, action_type, tier, day,
            econ_rich, param_greedy, rng
        )

    # On ne force pas l’assert sur spawned si ta factory push direct dans QuestPool,
    # mais ça aide si tu retournes l’instance.
    # _assert(spawned != null, "spawn_offer_for_pair should return a QuestInstance (or at least not null)")

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
            var prof_greedy:FactionProfile = FactionProfile.new()
            prof_greedy.apply_personality_template(param_greedy)
            var style := RewardEconomyUtil.compute_reward_style(econ_rich, tier, prof_greedy)
            _assert(abs(float(style.w_gold_dw) - dw) < 0.0001, "w_gold_dw mismatch vs compute_reward_style")
            found = true
            break

    _assert(found, "expected ArcNotebook record_pair_event with action=offer.reward_style")

    # Restore notebook
    arc_mgr.set("arc_notebook", prev_notebook)


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
