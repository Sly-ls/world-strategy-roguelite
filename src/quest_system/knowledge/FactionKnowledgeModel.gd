class_name FactionKnowledgeModel
extends RefCounted

# --- storage ---
var events_by_id: Dictionary = {}                # event_id -> KnowledgeEvent(Dictionary)
var beliefs_by_faction: Dictionary = {}          # observer -> (event_id -> BeliefEntry(Dictionary))
var rumors_by_id: Dictionary = {}                # rumor_id -> Rumor(Dictionary)

# config
var decay_per_day: float = 0.93
var k_norm: float = 0.35                         # for softcap if needed

const HOSTILE_TYPES := {
    &"RAID": true,
    &"SABOTAGE": true,
    &"DECLARE_WAR": true,
    &"war.capture_poi": true,
    &"war.collect_tribute_by_force": true,
}
# ------------------------------------------------------------
# 1) register_fact(event)
# ------------------------------------------------------------
func register_fact(event: Dictionary) -> void:
    # Expected keys:
    # id, day, type, true_actor, true_target, severity (optional), pair_key (optional), meta(optional)
    var eid: StringName = StringName(event.get("id", &""))
    if eid == &"":
        eid = StringName("evt_%s_%s" % [str(event.get("day", 0)), str(randi())])
        event["id"] = eid

    if not event.has("severity"):
        event["severity"] = 1.0

    if not event.has("pair_key"):
        var a := String(event.get("true_actor", ""))
        var b := String(event.get("true_target", ""))
        event["pair_key"] = StringName((a + "|" + b) if (a <= b) else (b + "|" + a))

    events_by_id[eid] = event


# ------------------------------------------------------------
# 2) inject_rumor(rumor)
# ------------------------------------------------------------
func inject_rumor(rumor: Dictionary, observers: Array, profiles: Dictionary = {}) -> void:
    # Expected keys:
    # id, day, seed_id, claim_actor, claim_target, claim_type, strength(0..1), credibility(0..1),
    # malicious(bool), related_event_id(optional)
    var rid: StringName = StringName(rumor.get("id", &""))
    if rid == &"":
        rid = StringName("rum_%s_%s" % [str(rumor.get("day", 0)), str(randi())])
        rumor["id"] = rid

    rumor["strength"] = clampf(float(rumor.get("strength", 0.6)), 0.0, 1.0)
    rumor["credibility"] = clampf(float(rumor.get("credibility", 0.5)), 0.0, 1.0)
    rumors_by_id[rid] = rumor

    var day := int(rumor.get("day", 0))
    var claim_actor: StringName = StringName(rumor.get("claim_actor", &""))
    var claim_target: StringName = StringName(rumor.get("claim_target", &""))
    var claim_type: StringName = StringName(rumor.get("claim_type", &""))

    for obs_id in observers:
        var observer: StringName = StringName(obs_id)
        _ensure_observer(observer)

        # base confidence from rumor strength + credibility
        var base := 0.10 + 0.55 * float(rumor["strength"]) * float(rumor["credibility"])

        # bias from personality (optional)
        # keys expected in profile personality dict: paranoia, diplomacy, intel
        var paranoia := _get_personality(profiles, observer, &"paranoia", 0.5)
        var diplomacy := _get_personality(profiles, observer, &"diplomacy", 0.5)
        var intel := _get_personality(profiles, observer, &"intel", 0.5)

        var conf := base + 0.20*intel + 0.20*paranoia - 0.20*diplomacy
        conf = clampf(conf, 0.05, 0.95)

        # Each rumor can either attach to a real event or live alone
        var event_id: StringName = StringName(rumor.get("related_event_id", &""))
        if event_id == &"":
            # create synthetic event id for belief tracking
            event_id = StringName("syn_%s_%s" % [str(day), String(rid)])
            if not events_by_id.has(event_id):
                events_by_id[event_id] = {
                    "id": event_id,
                    "day": day,
                    "type": claim_type,
                    "true_actor": &"",      # unknown/none
                    "true_target": claim_target,
                    "severity": 1.0,
                    "pair_key": StringName((String(claim_actor)+"|"+String(claim_target)) if (String(claim_actor) <= String(claim_target)) else (String(claim_target)+"|"+String(claim_actor))),
                    "meta": {"rumor_only": true, "rumor_id": rid}
                }

        # write belief
        var b := {
            "event_id": event_id,
            "observer_id": observer,
            "claimed_actor": claim_actor,
            "claimed_target": claim_target,
            "claim_type": claim_type,
            "confidence": conf,
            "source": &"RUMOR",
            "bias_tag": StringName(rumor.get("bias_tag", &"")),
            "last_update_day": day,
            "rumor_id": rid
        }
        beliefs_by_faction[observer][event_id] = b


# ------------------------------------------------------------
# 3) apply_knowledge_resolution(context, choice)
# ------------------------------------------------------------
func apply_knowledge_resolution(
    context: Dictionary,
    choice: StringName,
    relations: Dictionary,
    profiles: Dictionary = {},
    day: int = -1
) -> void:
    # context expected:
    # observer_id, claimed_actor, claimed_target, knowledge_action
    # related_event_id optional, rumor_id optional
    var observer: StringName = StringName(context.get("observer_id", &""))
    var claimed_actor: StringName = StringName(context.get("claimed_actor", &""))
    var claimed_target: StringName = StringName(context.get("claimed_target", &""))
    var action: StringName = StringName(context.get("knowledge_action", &"INVESTIGATE"))
    var eid: StringName = StringName(context.get("related_event_id", &""))

    if day < 0:
        day = int(context.get("day", 0))

    _ensure_observer(observer)

    # ensure belief exists (if quest created from rumor, we should have it; but be safe)
    if eid == &"":
        # try from rumor_id
        var rid: StringName = StringName(context.get("rumor_id", &""))
        if rid != &"" and rumors_by_id.has(rid):
            eid = StringName(rumors_by_id[rid].get("related_event_id", &""))
    if eid == &"":
        # fallback synthetic
        eid = StringName("syn_res_%s_%s" % [str(day), str(randi())])
        events_by_id[eid] = {"id": eid, "day": day, "type": &"", "true_actor": &"", "true_target": claimed_target, "severity": 1.0}

    var belief :Dictionary = beliefs_by_faction[observer].get(eid, null)
    if belief == null:
        belief = {
            "event_id": eid,
            "observer_id": observer,
            "claimed_actor": claimed_actor,
            "claimed_target": claimed_target,
            "claim_type": StringName(context.get("claim_type", &"")),
            "confidence": 0.35,
            "source": &"RUMOR",
            "bias_tag": &"",
            "last_update_day": day
        }
        beliefs_by_faction[observer][eid] = belief

    # determine if claim matches truth (if known)
    var ev: Dictionary = events_by_id.get(eid, {})
    var true_actor: StringName = StringName(ev.get("true_actor", &""))
    var truth_known := (true_actor != &"")
    var claim_is_true := truth_known and (true_actor == claimed_actor)

    # delta confidence based on knowledge_action + choice
    var dconf := 0.0
    match action:
        &"INVESTIGATE":
            if choice == &"LOYAL":   dconf = +0.25 if claim_is_true else -0.35
            elif choice == &"NEUTRAL":dconf = +0.10 if claim_is_true else -0.15
            else:                   dconf = +0.35  # forge/lie: push confidence upward
        &"PROVE_INNOCENCE":
            # target is "claimed_actor is innocent"
            # so we reduce confidence in the hostile claim
            if choice == &"LOYAL":   dconf = -0.40
            elif choice == &"NEUTRAL":dconf = -0.18
            else:                   dconf = +0.20  # sabotage defense
        &"FORGE_EVIDENCE":
            if choice == &"LOYAL":   dconf = +0.35
            elif choice == &"NEUTRAL":dconf = +0.15
            else:                   dconf = +0.45
        _:
            dconf = -0.15 if choice == &"LOYAL" else 0.0

    # apply personality modulation (optional): paranoia amplifies, diplomacy dampens
    var paranoia := _get_personality(profiles, observer, &"paranoia", 0.5)
    var diplomacy := _get_personality(profiles, observer, &"diplomacy", 0.5)
    var mult := clampf(1.0 + 0.25*(paranoia - 0.5) - 0.25*(diplomacy - 0.5), 0.75, 1.25)

    var old_conf := float(belief["confidence"])
    var new_conf := clampf(old_conf + dconf*mult, 0.0, 1.0)
    belief["confidence"] = new_conf
    belief["last_update_day"] = day
    beliefs_by_faction[observer][eid] = belief

    # Apply relationship deltas based on perceived belief change (asymmetric: observer -> claimed_actor)
    if claimed_actor != &"" and observer != &"" and relations.has(observer) and relations[observer].has(claimed_actor):
        var r: FactionRelationScore = relations[observer][claimed_actor]

        # hostile claim: higher confidence => higher tension/grievance and lower trust/relation
        # We use delta_conf to determine direction of change.
        var delta_conf := new_conf - old_conf
        var sev := float(ev.get("severity", 1.0))
        var scale := 10.0 * sev

        # if we're increasing confidence in hostile claim => worsen relation
        # if decreasing confidence => ease relation a bit
        r.tension = int(clampi(r.tension + int(round(+3.0 * delta_conf * scale)), 0, 100))
        r.grievance = int(clampi(r.grievance + int(round(+2.0 * delta_conf * scale)), 0, 100))
        r.trust = int(clampi(r.trust - int(round(+2.0 * delta_conf * scale)), 0, 100))
        r.relation = int(clampi(r.relation - int(round(+2.0 * delta_conf * scale)), -100, 100))

        # If we strongly debunked a rumor: small bonus
        if old_conf >= 0.6 and new_conf <= 0.25:
            r.tension = int(clampi(r.tension - 3, 0, 100))
            r.trust = int(clampi(r.trust + 2, 0, 100))

    # Optional: if source is propaganda and was debunked, reduce trust in seed_id (not implemented here)


# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
func get_perceived_heat(observer: StringName, other: StringName, day: int) -> float:
    # Retourne un score 0..100 : "à quel point observer pense que other est hostile (récemment)"
    if not beliefs_by_faction.has(observer):
        return 0.0

    var sum := 0.0
    for eid in beliefs_by_faction[observer].keys():
        var b: Dictionary = beliefs_by_faction[observer][eid]
        if StringName(b.get("claimed_actor", &"")) != other:
            continue

        var ctype: StringName = StringName(b.get("claim_type", &""))
        if not HOSTILE_TYPES.has(ctype):
            continue

        var conf := clampf(float(b.get("confidence", 0.0)), 0.0, 1.0)

        var ev: Dictionary = events_by_id.get(StringName(b.get("event_id", eid)), {})
        var ev_day := int(ev.get("day", int(b.get("last_update_day", day))))
        var age :int = max(0, day - ev_day)

        var sev := float(ev.get("severity", 1.0))
        var decay := pow(decay_per_day, float(age))

        sum += conf * sev * decay

    # Saturation douce -> 0..100 (évite divergence)
    return 100.0 * (1.0 - exp(-sum * 0.9))
    
func _ensure_observer(observer: StringName) -> void:
    if not beliefs_by_faction.has(observer):
        beliefs_by_faction[observer] = {}

func _get_personality(profiles: Dictionary, faction_id: StringName, key: StringName, default_val: float) -> float:
    var p = profiles.get(faction_id, null)
    if p == null:
        return default_val
    # supports either Dictionary profiles, or FactionProfile with get_personality()
    if p is Dictionary:
        var d: Dictionary = p.get("personality", {})
        return float(d.get(key, default_val))
    if p.has_method("get_personality"):
        return float(p.get_personality(key, default_val))
    return default_val
