extends BaseTest
class_name Integration_QuestOfferSimRunner_RewardStyleNotebook_Test

class StubArcNotebook:
    extends RefCounted
    var pair_events: Array = []

    func record_pair_event(day: int, a: StringName, b: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
        pair_events.append({"day": day, "a": a, "b": b, "action": action, "choice": choice, "meta": meta})

func _ready() -> void:
    _test_spawn_logs_reward_style_w_gold_dw_for_greedy()
    pass_test("\n✅ Integration_QuestOfferSimRunner_RewardStyleNotebook_Test: OK\n")

func _test_spawn_logs_reward_style_w_gold_dw_for_greedy() -> void:
    var sim := get_node_or_null("/root/QuestOfferSimRunner")
    _assert(sim != null, "Missing /root/QuestOfferSimRunner autoload")

    var arc_mgr := get_node_or_null("/root/ArcManagerRunner")
    _assert(arc_mgr != null, "Missing /root/ArcManagerRunner autoload")
    _assert(_has_prop(arc_mgr, "arc_notebook"), "ArcManagerRunner must expose var arc_notebook")

    # Patch notebook (capture logs)
    var prev_notebook = arc_mgr.get("arc_notebook")
    var notebook := StubArcNotebook.new()
    arc_mgr.set("arc_notebook", notebook)

    var rng := RandomNumberGenerator.new()
    rng.seed = 424242

    var giver := &"RICH_GREEDY"
    var target := &"TARGET"
    var day := 12
    var tier := 3
    var arc_action_type := &"arc.ultimatum"

    # Overrides injectés uniquement pour le test (évite de dépendre de ton FactionManager)
    var econ_override := {"wealth_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}
    var profile_override := {"personality": {&"greed": 0.95, &"opportunism": 0.85, &"honor": 0.20, &"discipline": 0.30}}

    # Appel "vraie méthode spawn" via une entrée stable.
    _assert(sim.has_method("spawn_offer_for_pair_from_params"),
        "QuestOfferSimRunner must expose spawn_offer_for_pair_from_params(p: Dictionary). See micro-patch below.")
    var offer = sim.call("spawn_offer_for_pair_from_params", {
        "giver_faction_id": giver,
        "antagonist_faction_id": target,
        "arc_action_type": arc_action_type,
        "tier": tier,
        "day": day,
        "rng": rng,
        "econ_override": econ_override,
        "profile_override": profile_override
    })

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
    arc_mgr.set("arc_notebook", prev_notebook)

func _has_prop(obj: Object, prop: String) -> bool:
    for p in obj.get_property_list():
        if p.name == prop:
            return true
    return false
