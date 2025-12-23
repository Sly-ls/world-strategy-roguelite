# ArcStateMachine.gd
class_name ArcStateMachine
extends RefCounted

# --- Arc states ---
const S_NEUTRAL: StringName  = &"NEUTRAL"
const S_RIVALRY: StringName  = &"RIVALRY"
const S_CONFLICT: StringName = &"CONFLICT"
const S_WAR: StringName      = &"WAR"
const S_TRUCE: StringName    = &"TRUCE"
const S_ALLIANCE: StringName = &"ALLIANCE"
const S_MERGED: StringName   = &"MERGED"
const S_EXTINCT: StringName  = &"EXTINCT"

static func is_hostile_action(action: StringName) -> bool:
    return action == ArcDecisionUtil.ARC_RAID \
        or action == ArcDecisionUtil.ARC_SABOTAGE \
        or action == ArcDecisionUtil.ARC_DECLARE_WAR \
        or action == ArcDecisionUtil.ARC_ULTIMATUM

static func is_peace_action(action: StringName) -> bool:
    return action == ArcDecisionUtil.ARC_TRUCE_TALKS \
        or action == ArcDecisionUtil.ARC_REPARATIONS \
        or action == ArcDecisionUtil.ARC_ALLIANCE_OFFER

static func pair_means(rel_ab: FactionRelationScore, rel_ba: FactionRelationScore) -> Dictionary:
    return {
        "rel": 0.5 * (float(rel_ab.relation) + float(rel_ba.relation)),
        "trust": 0.5 * (float(rel_ab.trust) + float(rel_ba.trust)),
        "tension": 0.5 * (rel_ab.tension + rel_ba.tension),
        "griev": 0.5 * (rel_ab.grievance + rel_ba.grievance),
        "wear": 0.5 * (rel_ab.weariness + rel_ba.weariness),
    }

static func _lock_days_for_state(state: StringName, rng: RandomNumberGenerator) -> int:
    match state:
        S_WAR:      return rng.randi_range(10, 20)
        S_TRUCE:    return rng.randi_range(6, 12)
        S_ALLIANCE: return rng.randi_range(12, 25)
        S_RIVALRY:  return rng.randi_range(4, 9)
        S_CONFLICT: return rng.randi_range(6, 12)
        _:          return rng.randi_range(3, 7)

static func _reset_phase(arc_state: ArcState) -> void:
    arc_state.phase_hostile = 0
    arc_state.phase_peace = 0
    arc_state.phase_events = 0
    arc_state.entered_day = arc_state.last_event_day

static func _enter_state(arc_state: ArcState, new_state: StringName, day: int, rng: RandomNumberGenerator) -> void:
    arc_state.state = new_state
    arc_state.entered_day = day
    arc_state.lock_until_day = day + _lock_days_for_state(new_state, rng)
    arc_state.phase_hostile = 0
    arc_state.phase_peace = 0
    arc_state.phase_events = 0

# -------------------------------------------------------------------
# update_arc_state() (compact)
# Appelé APRÈS résolution d’un event (donc on connaît last_action/choice)
# -------------------------------------------------------------------
static func tick_day_for_pair(arc_state: ArcState, rel_ab: FactionRelationScore, rel_ba: FactionRelationScore) -> void:
    var t_low := 25.0
    var rel_good := 35.0
    var trust_good := 55.0

    var tension_mean := 0.5 * (rel_ab.get_score(FactionRelationScore.REL_TENSION) + rel_ba.get_score(FactionRelationScore.REL_TENSION))
    var rel_mean := 0.5 * (float(rel_ab.get_score(FactionRelationScore.REL_RELATION)) + float(rel_ba.get_score(FactionRelationScore.REL_RELATION)))
    var trust_mean := 0.5 * (float(rel_ab.get_score(FactionRelationScore.REL_TRUST)) + float(rel_ba.get_score(FactionRelationScore.REL_TRUST)))

    arc_state.stable_low_tension_days = arc_state.stable_low_tension_days + 1 if tension_mean <= t_low else 0
    arc_state.stable_high_trust_days = arc_state.stable_high_trust_days + 1 if (trust_mean >= trust_good and rel_mean >= rel_good) else 0
    
static func update_arc_state(
    arc_state: ArcState,
    rel_ab: FactionRelationScore,
    rel_ba: FactionRelationScore,
    day: int,
    rng: RandomNumberGenerator,
    last_action: StringName = &"",
    last_choice: StringName = &"" # ArcEffectTable.CHOICE_...
) -> bool:
    # returns true if state changed
    if arc_state.state == S_MERGED or arc_state.state == S_EXTINCT:
        return false

    arc_state.last_event_day = day
    arc_state.last_action = last_action
    arc_state.phase_events += 1

    if is_hostile_action(last_action):
        arc_state.phase_hostile += 1
    elif is_peace_action(last_action):
        arc_state.phase_peace += 1

    var m := pair_means(rel_ab, rel_ba)
    var rel_mean := float(m["rel"])
    var trust_mean := float(m["trust"])
    var tension_mean := float(m["tension"])
    var griev_mean := float(m["griev"])
    var wear_mean := float(m["wear"])

    # Thresholds (tunable)
    var t_high := 70.0
    var t_med := 50.0
    var t_low := 25.0
    var rel_bad := -55.0
    var rel_hate := -70.0
    var rel_good := 35.0
    var trust_good := 55.0
    var griev_high := 60.0
    var wear_high := 65.0

    var prev := arc_state.state
    var locked := arc_state.is_locked(day)

    match arc_state.state:
        S_NEUTRAL:
            if not locked and (tension_mean >= t_med or rel_mean <= rel_bad or is_hostile_action(last_action)):
                _enter_state(arc_state, S_RIVALRY, day, rng)

        S_RIVALRY:
            if not locked:
                if tension_mean >= t_high or arc_state.phase_hostile >= 3:
                    if wear_mean < wear_high:
                        _enter_state(arc_state, S_CONFLICT, day, rng)
                    else:
                        _enter_state(arc_state, S_TRUCE, day, rng)
                elif tension_mean <= t_low and griev_mean <= 20.0 and arc_state.phase_peace >= 1:
                    _enter_state(arc_state, S_NEUTRAL, day, rng)

        S_CONFLICT:
            if not locked:
                if (rel_mean <= rel_hate and tension_mean >= t_high) or (last_action == ArcDecisionUtil.ARC_DECLARE_WAR and last_choice == ArcEffectTable.CHOICE_LOYAL):
                    _enter_state(arc_state, S_WAR, day, rng)
                elif arc_state.phase_peace >= 2 or (tension_mean <= t_med and griev_mean <= griev_high):
                    _enter_state(arc_state, S_TRUCE, day, rng)

        S_WAR:
            # War => sortie surtout via usure ou actions de paix répétées
            if not locked:
                if wear_mean >= wear_high or arc_state.phase_peace >= 2:
                    _enter_state(arc_state, S_TRUCE, day, rng)

        S_TRUCE:
            if not locked:
                if trust_mean >= trust_good and rel_mean >= rel_good and tension_mean <= t_low:
                    _enter_state(arc_state, S_ALLIANCE, day, rng)
                elif tension_mean >= t_med and arc_state.phase_hostile >= 2:
                    _enter_state(arc_state, S_CONFLICT, day, rng)
                elif tension_mean <= t_low and griev_mean <= 15.0 and arc_state.phase_peace >= 2:
                    _enter_state(arc_state, S_NEUTRAL, day, rng)

        S_ALLIANCE:
            if not locked:
                # Rare merge gate (à renforcer avec des conditions monde si besoin)
                if trust_mean >= 75.0 and rel_mean >= 60.0 and tension_mean <= 15.0 and arc_state.phase_peace >= 2:
                    _enter_state(arc_state, S_MERGED, day, rng)
                # Backslide
                elif tension_mean >= t_med and (arc_state.phase_hostile >= 2 or is_hostile_action(last_action)):
                    _enter_state(arc_state, S_RIVALRY, day, rng)

        _:
            pass

    return arc_state.state != prev

static func apply_treaty_enforcement_resolution(
    arc_state: ArcState,
    rel_ab: FactionRelationScore,
    rel_ba: FactionRelationScore,
    enforcement_type: StringName, # &"investigate"|"enforce"|"summit"
    choice: StringName,
    day: int
) -> void:
    var t :Treaty = arc_state.treaty
    if t == null:
        return

    var dv := 0.0
    var dend := 0
    var d_trust := 0
    var d_tension := 0
    var d_rel := 0
    var d_wear := 0

    match enforcement_type:
        &"investigate":
            if choice == &"LOYAL":   dv = -0.35; dend = +2; d_trust = +4; d_tension = -3
            elif choice == &"NEUTRAL":dv = -0.15; dend =  0; d_trust = +1
            else:                   dv = +0.40; dend =  0; d_trust = -4; d_tension = +4
        &"enforce":
            if choice == &"LOYAL":   dv = -0.25; dend = +4; d_tension = -4; d_wear = -2
            elif choice == &"NEUTRAL":dv = -0.10; dend = +1
            else:                   dv = +0.25; dend =  0; d_tension = +3
        &"summit":
            if choice == &"LOYAL":   dv = -0.45; dend = +6; d_trust = +6; d_tension = -6; d_rel = +4
            elif choice == &"NEUTRAL":dv = -0.20; dend = +2; d_trust = +2
            else:                   dv = +0.35; dend = -2; d_trust = -6; d_tension = +6

    t.violation_score = clampf(t.violation_score + dv, 0.0, 2.0)
    t.end_day = max(t.end_day + dend, day + 1)

    # Apply small relation deltas to both directions
    if d_trust != 0:
        rel_ab.trust = int(clampi(rel_ab.trust + d_trust, 0, 100))
        rel_ba.trust = int(clampi(rel_ba.trust + d_trust, 0, 100))
    if d_tension != 0:
        rel_ab.tension = int(clampi(rel_ab.tension + d_tension, 0, 100))
        rel_ba.tension = int(clampi(rel_ba.tension + d_tension, 0, 100))
    if d_rel != 0:
        rel_ab.relation = int(clampi(rel_ab.relation + d_rel, -100, 100))
        rel_ba.relation = int(clampi(rel_ba.relation + d_rel, -100, 100))
    if d_wear != 0:
        rel_ab.weariness = int(clampi(rel_ab.weariness + d_wear, 0, 100))
        rel_ba.weariness = int(clampi(rel_ba.weariness + d_wear, 0, 100))

    # Si on repasse en dessous d’un seuil => “stabilité”
    # (optionnel) si t.violation_score < 0.2: arc_state.pending_retaliation = false
    
static func tick_tribute_if_any(
    arc_state: ArcState,
    day: int,
    economies: Dictionary,
    relations: Dictionary,              # relations[winner][loser]
    notebook: ArcNotebook,              # pour cooldown anti-spam d’offer
    spawn_collect_offer_fn: Callable    # injection: (winner, loser, day, tier) -> QuestInstance
) -> void:
    if not arc_state.war_terms.get("tribute_active", false):
        return
    if int(arc_state.war_terms.get("tribute_weeks_left", 0)) <= 0:
        arc_state.war_terms["tribute_active"] = false
        return

    var next_day := int(arc_state.war_terms.get("tribute_next_day", day))
    if day < next_day:
        return

    var winner: StringName = arc_state.war_terms["tribute_winner"]
    var loser: StringName = arc_state.war_terms["tribute_loser"]
    var amt := int(arc_state.war_terms.get("tribute_gold_per_week", 60))

    var ew = economies.get(winner, null)
    var el = economies.get(loser, null)
    if ew == null or el == null:
        return

    # --- Payment attempt ---
    if el.gold >= amt:
        _transfer_gold(loser, winner, amt, economies)
        arc_state.war_terms["tribute_weeks_left"] = int(arc_state.war_terms["tribute_weeks_left"]) - 1
        arc_state.war_terms["tribute_next_day"] = day + 7

        # reset miss counters gradually
        arc_state.war_terms["tribute_missed_payments"] = max(0, int(arc_state.war_terms.get("tribute_missed_payments", 0)) - 1)
        return

    # --- Non-payment: escalate treaty violation + spawn offer ---
    arc_state.war_terms["tribute_missed_payments"] = int(arc_state.war_terms.get("tribute_missed_payments", 0)) + 1
    arc_state.war_terms["tribute_last_miss_day"] = day
    arc_state.war_terms["tribute_next_day"] = day + 7  # next attempt anyway

    # Increase treaty violation_score (if treaty exists)
    if arc_state.treaty != null:
        # miss_count makes repeated failures increasingly serious
        var miss := int(arc_state.war_terms["tribute_missed_payments"])
        arc_state.treaty.violation_score += 0.20 + 0.05 * float(min(miss, 6))

        # Relation fallout: loser hates winner more (asym)
        var l2w: FactionRelationScore = relations[loser][winner]
        l2w.grievance = int(clampi(l2w.grievance + 6, 0, 100))
        l2w.tension = int(clampi(l2w.tension + 4, 0, 100))
        l2w.trust = int(clampi(l2w.trust - 4, 0, 100))

        # winner becomes less trusting too (sym small)
        var w2l: FactionRelationScore = relations[winner][loser]
        w2l.trust = int(clampi(w2l.trust - 2, 0, 100))
        w2l.tension = int(clampi(w2l.tension + 2, 0, 100))

        # Check break
        if ArcStateMachine.maybe_break_treaty(arc_state, day):
            # treaty broke => the "collect tribute" offer can become a WAR/CONFLICT offer naturally elsewhere
            return
    
    # Anti-spam cooldown: max 1 collect offer per 7 days per pair
    var pair_key := StringName((String(winner)+"|"+String(loser)) if (String(winner) <= String(loser)) else (String(loser)+"|"+String(winner)))
    var faction_profiles :Dictionary = {
        winner: FactionManager.get_faction_profile(winner),
        loser: FactionManager.get_faction_profile(loser)
    }
    var desired := ArcStateMachine.decide_state_on_tribute_default( winner, loser, day, arc_state, relations, notebook, faction_profiles, null )

    if ArcStateMachine.maybe_break_treaty(arc_state, day, desired):
        notebook.inc_pair_counter(pair_key, &"treaty_breaks", 1)
        if desired == &"WAR":
            notebook.inc_pair_counter(pair_key, &"wars", 1)
        return
    
    if not notebook.can_spawn_third_party(pair_key, day, 7): # reuse helper OR create a dedicated "can_spawn_collect"
        return
    notebook.mark_third_party_spawned(pair_key, day)

    # Spawn "collect tribute by force" (tier escalates with missed count)
    var missed := int(arc_state.war_terms.get("tribute_missed_payments", 1))
    var tier := clampi(1 + missed, 1, 4)
    var inst: QuestInstance = spawn_collect_offer_fn.call(winner, loser, day, tier)
    if inst != null:
        # caller adds to QuestPool; we keep tick pure
        pass
static func decide_state_on_tribute_default(
    winner_id: StringName,
    loser_id: StringName,
    day: int,
    arc_state: ArcState,
    relations: Dictionary,   # relations[X][Y] -> FactionRelationScore
    notebook: ArcNotebook,
    profiles: Dictionary,    # profiles[faction] -> FactionProfile
    ctx: FactionWorldContext = null
) -> StringName:
    var w2l: FactionRelationScore = relations[winner_id][loser_id]
    var l2w: FactionRelationScore = relations[loser_id][winner_id]

    var tension := 0.5 * (w2l.get_score(FactionRelationScore.REL_TENSION) + l2w.get_score(FactionRelationScore.REL_TENSION)) / 100.0
    var griev := 0.5 * (w2l.get_score(FactionRelationScore.REL_GRIEVANCE) + l2w.get_score(FactionRelationScore.REL_GRIEVANCE)) / 100.0
    var wear := 0.5 * (w2l.get_score(FactionRelationScore.REL_WEARINESS) + l2w.get_score(FactionRelationScore.REL_WEARINESS)) / 100.0
    var rel := 0.5 * (w2l.get_score(FactionRelationScore.REL_RELATION) + l2w.get_score(FactionRelationScore.REL_RELATION)) / 100.0

    # heat (hostile récent)
    var h := notebook.get_pair_heat(winner_id, loser_id, day, 0.93)
    var hostile_recent := 1.0 - exp(-0.35 * (float(h["hostile_to_other"]) + float(h["hostile_from_other"])))

    # historique : compteurs (à brancher sur ton ArcNotebook/arcHistory)
    var pair_key := StringName((String(winner_id)+"|"+String(loser_id)) if (String(winner_id) <= String(loser_id)) else (String(loser_id)+"|"+String(winner_id)))
    var treaty_breaks := float(notebook.get_pair_counter(pair_key, &"treaty_breaks", 0)) # à ajouter
    var wars := float(notebook.get_pair_counter(pair_key, &"wars", 0))                   # à ajouter
    var nonpay := float(notebook.get_pair_counter(pair_key, &"tribute_misses", 0))       # à ajouter
    var history_factor := clampf(0.10*treaty_breaks + 0.15*wars + 0.10*nonpay, 0.0, 0.6)

    # profils
    var pw: FactionProfile = profiles.get(winner_id, null)
    var pl: FactionProfile = profiles.get(loser_id, null)

    var bell := pw.get_personality(FactionProfile.PERS_BELLIGERENCE, 0.5) if pw else 0.5
    var diplo := pw.get_personality(FactionProfile.PERS_DIPLOMACY, 0.5) if pw else 0.5
    var expa := pw.get_personality(FactionProfile.PERS_EXPANSIONISM, 0.5) if pw else 0.5
    var honor := pw.get_personality(FactionProfile.PERS_HONOR, 0.5) if pw else 0.5

    # axes : divergence moyenne (0..1)
    var axis_div := 0.0
    if pw and pl:
        var sum := 0.0
        var n := 0.0
        for k in pw.axis_affinity.keys():
            if pl.axis_affinity.has(k):
                sum += abs(float(pw.axis_affinity[k]) - float(pl.axis_affinity[k])) / 200.0
                n += 1.0
        axis_div = (sum / max(1.0, n))

    # contexte (optionnel)
    var ext_threat := (ctx.external_threat if ctx else 0.0)

    # score d’escalade (0..1)
    # + tension/grievance/hostile_recent/history/axis_div/bell/honor
    # - diplomatie/fatigue/menace externe (pousse vers trêve/coali plutôt que guerre)
    var score := 0.30*tension + 0.22*griev + 0.18*hostile_recent + 0.12*axis_div + history_factor \
        + 0.12*bell + 0.06*honor - 0.18*diplo - 0.22*wear - 0.12*ext_threat

    score = clampf(score, 0.0, 1.0)

    # décision :
    # - guerre si score haut et relation déjà très basse
    # - sinon conflit (punitive / collect-by-force / raids limités)
    if score >= 0.75 and rel <= -0.35:
        # expansionniste => WAR plus souvent, sinon CONFLICT peut suffire
        return &"WAR" if expa >= 0.55 else &"CONFLICT"
    return &"CONFLICT"
# -------------------------------------------------------------------
# build_arc_context() standard
# -------------------------------------------------------------------
static func build_arc_context(
    arc_id: StringName,
    arc_state: ArcState,
    giver_id: StringName,
    ant_id: StringName,
    action: StringName,
    day: int,
    deadline_days: int,
    stakes: Dictionary,
    seed: int
) -> Dictionary:
    var pair_key := arc_state.a_id
    if String(arc_state.a_id) <= String(arc_state.b_id):
        pair_key = StringName(String(arc_state.a_id) + "|" + String(arc_state.b_id))
    else:
        pair_key = StringName(String(arc_state.b_id) + "|" + String(arc_state.a_id))

    return {
        "is_arc_rivalry": true,
        "arc_id": arc_id,
        "arc_state": arc_state.state,
        "arc_action_type": action,

        "giver_faction_id": giver_id,
        "antagonist_faction_id": ant_id,

        "pair_key": pair_key,
        "created_day": day,
        "deadline_days": deadline_days,

        "stakes": stakes,
        "seed": seed,
    }
# -------------------------------------------------------------------
# helpers
# -------------------------------------------------------------------
static func maybe_break_treaty(arc_state: ArcState, day: int, trigger_action: StringName = &"") -> bool:
    var t: Treaty = arc_state.treaty
    if t == null:
        return false
    if t.violation_score < t.violation_threshold:
        return false

    # Break treaty + long cooldown lock
    arc_state.lock_until_day = max(arc_state.lock_until_day, day + t.cooldown_after_end_days)

    # Deteriorate state (declare_war -> WAR, otherwise CONFLICT)
    if trigger_action == ArcDecisionUtil.ARC_DECLARE_WAR:
        arc_state.state = &"WAR"
    else:
        arc_state.state = &"CONFLICT"

    arc_state.treaty = null
    return true
static func _transfer_gold(from_id: StringName, to_id: StringName, amount: int, economies: Dictionary) -> void:
    if amount <= 0: return
    var ef = economies.get(from_id, null)
    var et = economies.get(to_id, null)
    if ef == null or et == null: return
    var pay :int = min(amount, ef.gold)
    ef.gold -= pay
    et.gold += pay
