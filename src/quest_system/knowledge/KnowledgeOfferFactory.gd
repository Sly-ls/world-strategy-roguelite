# KnowledgeOfferFactory.gd
class_name KnowledgeOfferFactory
extends RefCounted

const HEAT_LOW := 15.0
const HEAT_MED := 25.0
const HEAT_HIGH := 40.0
const KNOWLEDGE_TEMPLATES := {
    &"INVESTIGATE": [
        &"knowledge.investigate.stealth",    # infiltrer / récupérer des preuves
        &"knowledge.investigate.diplomacy",  # interroger / convaincre témoins
        &"knowledge.investigate.retrieve",   # récupérer un objet de preuve
    ],
    &"PROVE_INNOCENCE": [
        &"knowledge.innocence.diplomacy",    # audience / plaidoirie / négociation
        &"knowledge.innocence.escort",       # escorter un émissaire / témoin
        &"knowledge.innocence.retrieve",     # récupérer contre-preuve
    ],
    &"FORGE_EVIDENCE": [
        &"knowledge.forge.stealth",          # falsifier sceaux / lettres
        &"knowledge.forge.retrieve",         # voler un artefact “incriminant”
        &"knowledge.forge.sabotage",         # mise en scène / sabotage cadré
    ],
}
static func spawn_offers_for_rumor(
    knowledge: FactionKnowledgeModel,
    rumor: Dictionary,
    observers: Array,                 # factions qui "reçoivent" la rumeur (ex: [B] ou alliés)
    day: int,
    quest_pool,                       # ton QuestPool (ou retourne un Array[QuestInstance])
    profiles: Dictionary = {},
    params: Dictionary = {}
) -> Array:
    var out: Array = []

    var rid: StringName = StringName(rumor.get("id", &""))
    var claimed_actor: StringName = StringName(rumor.get("claim_actor", &""))
    var claimed_target: StringName = StringName(rumor.get("claim_target", &""))
    var claim_type: StringName = StringName(rumor.get("claim_type", &"RAID"))
    var seed_id: StringName = StringName(rumor.get("seed_id", &""))
    var malicious := bool(rumor.get("malicious", false))
    var event_id: StringName = StringName(rumor.get("related_event_id", &""))

    # cooldown anti-spam par rumeur/pair
    var key := StringName("know|" + String(rid))
    var cd := int(params.get("knowledge_offer_cooldown_days", 5))
    if not ArcManagerRunner.arc_notebook.can_spawn_knowledge_offer(key, day, cd):
        return out

    var max_offers := int(params.get("knowledge_bundle_max", 3))

    for obs in observers:
        var observer: StringName = StringName(obs)

        var heat := knowledge.get_perceived_heat(observer, claimed_actor, day)
        if heat < HEAT_LOW:
            continue

        # récupère la confidence du belief associé (si dispo)
        var conf := _get_confidence(knowledge, observer, event_id, claimed_actor, claim_type)
        var deadline_days = 8
        if (heat >= HEAT_HIGH):
            deadline_days= 4
        elif (heat >= HEAT_MED):
            deadline_days= 6
        var conf_ratio =0
        if conf >= 0.60:
            conf_ratio = 1
        var tier := clampi(1 + int(floor(heat / 20.0)) + conf_ratio, 1, 5)

        # 1) INVESTIGATE (giver = observer/victim)
        if conf >= 0.35 and heat >= HEAT_LOW and out.size() < max_offers:
            out.append(_spawn_knowledge_offer(
                &"INVESTIGATE",
                observer,                 # giver
                claimed_actor,             # antagonist “suspect”
                seed_id,                   # third party (source)
                observer, claimed_actor, claimed_target,
                event_id, rid,
                heat, conf, tier, deadline_days, claim_type
            ))

        # 2) PROVE_INNOCENCE (giver = claimed_actor, influence observer=B)
        if conf >= 0.45 and heat >= HEAT_MED and out.size() < max_offers:
            out.append(_spawn_knowledge_offer(
                &"PROVE_INNOCENCE",
                claimed_actor,             # giver
                observer,                  # antagonist “accusateur”
                seed_id,
                observer, claimed_actor, claimed_target,
                event_id, rid,
                heat, conf, tier, deadline_days, claim_type
            ))

        # 3) FORGE_EVIDENCE (giver = seed/tiers, antagonist = claimed_actor)
        # uniquement si ça a un intérêt (pas déjà conviction maximale)
        if malicious and heat >= 30.0 and conf <= 0.85 and out.size() < max_offers:
            out.append(_spawn_knowledge_offer(
                &"FORGE_EVIDENCE",
                seed_id,                  # giver (propagandiste / opportuniste / vraie faction C)
                claimed_actor,            # antagonist (celui qu'on incrimine)
                observer,                 # third party = la cible à convaincre
                observer, claimed_actor, claimed_target,
                event_id, rid,
                heat, conf, tier, deadline_days, claim_type
            ))

    # filtre null + ajout au pool
    var final: Array = []
    for inst in out:
        if inst != null:
            final.append(inst)
            if quest_pool != null and quest_pool.has_method("try_add_offer"):
                quest_pool.try_add_offer(inst)

    # mark cooldown
    ArcManagerRunner.arc_notebook.mark_knowledge_offer_spawned(key, day)

    return final


static func _spawn_knowledge_offer(
    knowledge_action: StringName,
    giver: StringName,
    antagonist: StringName,
    third_party: StringName,
    observer_id: StringName,
    claimed_actor: StringName,
    claimed_target: StringName,
    event_id: StringName,
    rumor_id: StringName,
    heat: float,
    conf: float,
    tier: int,
    deadline_days: int,
    claim_type: StringName
) -> QuestInstance:
    if giver == &"" or claimed_actor == &"" or claimed_target == &"":
        return null

    # Choix d’un “quest type/template id” (au hasard simple)
    var options: Array = KNOWLEDGE_TEMPLATES.get(knowledge_action, [])
    if options.is_empty():
        return null
    var qtype: StringName = options[randi() % options.size()]

    # Ici tu peux appeler ton ArcOfferFactory / QuestGenerator. MVP: template runtime minimal.
    var template := ArcOfferFactory._build_template_fallback(String(qtype), tier, deadline_days)

    var ctx := {
        "is_knowledge_offer": true,
        "knowledge_action": knowledge_action,
        "observer_id": observer_id,
        "claimed_actor": claimed_actor,
        "claimed_target": claimed_target,
        "claim_type": claim_type,

        "related_event_id": event_id,
        "rumor_id": rumor_id,

        "giver_faction_id": giver,
        "antagonist_faction_id": antagonist,
        "third_party_id": third_party,

        "stake": {"heat": heat, "confidence": conf, "tier": tier},
        "expires_in_days": deadline_days,

        # profil de résolution “knowledge” (tu peux le router vers apply_knowledge_resolution)
        "resolution_profile_id": &"knowledge_default"
    }

    var inst := QuestInstance.new(template, ctx)
    inst.status = QuestTypes.QuestStatus.AVAILABLE
    inst.started_on_day = int(ctx.get("day", 0))
    inst.expires_on_day = inst.started_on_day + deadline_days
    return inst


static func _get_confidence(knowledge: FactionKnowledgeModel, observer: StringName, event_id: StringName, claimed_actor: StringName, claim_type: StringName) -> float:
    # cherche un belief précis, sinon fallback
    if knowledge.beliefs_by_faction.has(observer):
        if knowledge.beliefs_by_faction[observer].has(event_id):
            var b: Dictionary = knowledge.beliefs_by_faction[observer][event_id]
            if StringName(b.get("claimed_actor", &"")) == claimed_actor and StringName(b.get("claim_type", &"")) == claim_type:
                return clampf(float(b.get("confidence", 0.35)), 0.0, 1.0)
    return 0.35
