# CoalitionManager.gd
class_name CoalitionManager
extends Node

var coalitions_by_id: Dictionary = {}       # id -> CoalitionBlock
var coalition_id_by_key: Dictionary = {}    # key -> id

var rng := RandomNumberGenerator.new()

# Tunables V1
const HEGEMON_THRESHOLD := 0.62
const CRISIS_THRESHOLD := 0.60
const MAX_OFFERS_PER_COALITION_PER_TICK := 2
const OFFER_COOLDOWN_DAYS := 5
const COALITION_MIN_MEMBERS := 3
const COALITION_MIN_LIFE_DAYS := 10
const COALITION_MAX_LIFE_DAYS := 30

const STANCE_SUPPORT := &"SUPPORT"
const STANCE_HEDGE := &"HEDGE"
const STANCE_UNDERMINE := &"UNDERMINE"


# ------------------------------------------------------------
# tick_day(day): detect hegemon/crisis, form coalitions, spawn 1-2 offers
# ------------------------------------------------------------
func tick_day(
    day: int,
    faction_ids: Array[StringName],
    profiles: Dictionary,          # faction -> FactionProfile (must have get_personality/get_axis_affinity)
    relations: Dictionary,         # relations[A][B] -> FactionRelationScore
    world: Dictionary,             # crisis + power data
    quest_pool,                    # must have try_add_offer(inst)
    arc_notebook                   # minimal cooldown + optional pair_lock
) -> void:
    # 0) upkeep / expire
    _cleanup_and_expire(day, arc_notebook)

    # 1) CRISIS coalitions (can be AGAINST or WITH the crisis instigator)
    if bool(world.get("crisis_active", false)):
        var sev := float(world.get("crisis_severity", 0.0))
        if sev >= CRISIS_THRESHOLD:
            _ensure_crisis_coalitions(day, faction_ids, profiles, relations, world, arc_notebook)

    # 2) HEGEMON coalition (anti-dominance) if no overriding crisis or if crisis not huge
    var hegemon_id := _detect_hegemon(faction_ids, world)
    if hegemon_id != &"":
        var hegemon_index := float(world.get("hegemon_index_by_faction", {}).get(hegemon_id, 0.0))
        if hegemon_index >= HEGEMON_THRESHOLD:
            _ensure_hegemon_coalition(day, hegemon_id, faction_ids, profiles, relations, world, arc_notebook)

    # 3) Spawn offers (1–2 max / coalition, cooldown)
    for cid in coalitions_by_id.keys():
        var c: CoalitionBlock = coalitions_by_id[cid]
        if day < c.lock_until_day:
            continue
        if (day - c.last_offer_day) < OFFER_COOLDOWN_DAYS:
            continue
        if arc_notebook != null and arc_notebook.has_method("can_spawn_coalition_offer"):
            if not arc_notebook.can_spawn_coalition_offer(c.id, day, OFFER_COOLDOWN_DAYS):
                continue

        var spawned := 0
        # Always try JOINT OP first
        var inst := _spawn_joint_op_offer(c, day, profiles, relations, world)
        if inst != null and quest_pool != null and quest_pool.has_method("try_add_offer"):
            if quest_pool.try_add_offer(inst):
                spawned += 1

        # Optional PLEDGE offer if cohesion low or crisis with mixed members (even at war)
        if spawned < MAX_OFFERS_PER_COALITION_PER_TICK:
            if c.cohesion <= 55 or c.kind == &"CRISIS":
                var inst2 := _spawn_pledge_offer(c, day, profiles, relations, world)
                if inst2 != null and quest_pool != null and quest_pool.has_method("try_add_offer"):
                    if quest_pool.try_add_offer(inst2):
                        spawned += 1

        if spawned > 0:
            c.last_offer_day = day
            if arc_notebook != null and arc_notebook.has_method("mark_coalition_offer_spawned"):
                arc_notebook.mark_coalition_offer_spawned(c.id, day)


# ------------------------------------------------------------
# apply_joint_op_resolution(): member stances + progress/cohesion + deltas
# ------------------------------------------------------------
func apply_joint_op_resolution(
    context: Dictionary,           # from QuestInstance.context
    choice: StringName,            # LOYAL/NEUTRAL/TRAITOR (player)
    day: int,
    profiles: Dictionary,
    relations: Dictionary,
    world: Dictionary,
    arc_notebook
) -> void:
    if not bool(context.get("is_coalition", false)):
        return

    var cid: StringName = StringName(context.get("coalition_id", &""))
    if cid == &"" or not coalitions_by_id.has(cid):
        return
    var c: CoalitionBlock = coalitions_by_id[cid]

    var members: Array[StringName] = c.member_ids.duplicate()
    if members.is_empty():
        return

    # 1) Determine stance per member (SUPPORT/HEDGE/UNDERMINE)
    var stances: Dictionary = {}
    var support_count := 0
    var undermine_count := 0

    var crisis_axis: StringName = StringName(world.get("crisis_axis", &"")) # optional (MAGIC/CORRUPTION/...)
    var crisis_source: StringName = StringName(world.get("crisis_source_id", &""))

    for m in members:
        var stance := _decide_member_stance(c, m, day, profiles, relations, world, arc_notebook, crisis_axis, crisis_source)
        stances[m] = stance
        if stance == STANCE_SUPPORT: support_count += 1
        elif stance == STANCE_UNDERMINE: undermine_count += 1

    var support_ratio := float(support_count) / float(max(1, members.size()))

    # 2) Update coalition progress/cohesion (player choice affects efficiency)
    var tier := int(context.get("tier", 2))
    var base_progress := 14.0 + 4.0 * float(tier)

    var undermine_ratio :float = 0.0
    if undermine_count > 0:
        undermine_ratio = 0.30
    var eff := clampf(0.25 + 0.95*support_ratio - (undermine_ratio), 0.05, 1.10)
    if choice == &"LOYAL": eff *= 1.05
    elif choice == &"NEUTRAL": eff *= 0.95
    elif choice == &"TRAITOR": eff *= 0.85

    var dp := base_progress * eff
    c.progress = clampf(c.progress + dp, 0.0, 100.0)

    var dc := 0
    if support_ratio >= 0.66: dc += 4
    elif support_ratio >= 0.40: dc += 1
    else: dc -= 3
    if undermine_count > 0: dc -= 6
    if choice == &"LOYAL": dc += 1
    if choice == &"TRAITOR": dc -= 2
    c.cohesion = int(clampi(c.cohesion + dc, 0, 100))

    # 3) Relationship deltas among members (asymmetric, based on stances)
    _apply_member_deltas(c, members, stances, relations, arc_notebook, day)

    # 4) Member commitment shifts (people can hedge/undermine without being “LOYAL”)
    for m in members:
        var commit := float(c.member_commitment.get(m, 0.6))
        match StringName(stances[m]):
            STANCE_SUPPORT:
                commit = clampf(commit + 0.06, 0.0, 1.0)
            STANCE_HEDGE:
                commit = clampf(commit - 0.03, 0.0, 1.0)
            STANCE_UNDERMINE:
                commit = clampf(commit - 0.22, 0.0, 1.0)
        c.member_commitment[m] = commit

    # Optional: kick persistent underminers (MVP)
    var to_remove: Array[StringName] = []
    for m in members:
        if float(c.member_commitment.get(m, 0.6)) <= 0.12:
            to_remove.append(m)
    for m in to_remove:
        c.member_ids.erase(m)
        c.member_commitment.erase(m)
        c.member_role.erase(m)

    # 5) If coalition achieved its goal or collapsed -> dissolve + lock
    if c.progress >= 100.0:
        _dissolve_coalition(day, c, arc_notebook, &"SUCCESS")
    elif c.cohesion <= 20 or c.member_ids.size() < 2:
        _dissolve_coalition(day, c, arc_notebook, &"COLLAPSE")

    # metrics
    if arc_notebook != null and arc_notebook.has_method("record_coalition_event"):
        arc_notebook.record_coalition_event({
            "day": day, "coalition_id": c.id, "goal": c.goal, "progress": c.progress, "cohesion": c.cohesion,
            "support_ratio": support_ratio, "undermine": undermine_count, "choice": choice
        })


# ============================================================
# Internals
# ============================================================

func _cleanup_and_expire(day: int, arc_notebook) -> void:
    var to_remove: Array[StringName] = []
    for cid in coalitions_by_id.keys():
        var c: CoalitionBlock = coalitions_by_id[cid]
        if day >= c.expires_day and day >= (c.started_day + COALITION_MIN_LIFE_DAYS):
            to_remove.append(cid)
        elif c.cohesion <= 10:
            to_remove.append(cid)

    for cid in to_remove:
        var c: CoalitionBlock = coalitions_by_id[cid]
        _dissolve_coalition(day, c, arc_notebook, &"EXPIRE")


func _dissolve_coalition(day: int, c: CoalitionBlock, arc_notebook, reason: StringName) -> void:
    # Long lock to prevent instant reformation
    c.lock_until_day = day + rng.randi_range(15, 40)

    # Mark cooldown in notebook (optional)
    if arc_notebook != null and arc_notebook.has_method("mark_coalition_dissolved"):
        arc_notebook.mark_coalition_dissolved(c.id, day, reason)

    # Remove from registries
    var k := c.key()
    coalition_id_by_key.erase(k)
    coalitions_by_id.erase(c.id)


func _detect_hegemon(faction_ids: Array[StringName], world: Dictionary) -> StringName:
    var idx_map: Dictionary = world.get("hegemon_index_by_faction", {})
    if idx_map is Dictionary and idx_map.size() > 0:
        var best := &""
        var bestv := -1.0
        for f in faction_ids:
            var v := float(idx_map.get(f, 0.0))
            if v > bestv:
                bestv = v
                best = f
        return best

    # fallback from power_by_faction
    var pmap: Dictionary = world.get("power_by_faction", {})
    if pmap.size() == 0:
        return &""
    var best2 := &""
    var bestp := -1.0
    for f in faction_ids:
        var p := float(pmap.get(f, 0.0))
        if p > bestp:
            bestp = p
            best2 = f
    return best2


func _ensure_hegemon_coalition(day: int, hegemon_id: StringName, faction_ids: Array[StringName], profiles: Dictionary, relations: Dictionary, world: Dictionary, arc_notebook) -> void:
    var key := StringName("HEGEMON|AGAINST_TARGET|%s" % String(hegemon_id))
    if coalition_id_by_key.has(key):
        return

    # candidates: factions not hegemon, with fear/hostility, or simply weak ones under pressure
    var candidates: Array[StringName] = []
    for f in faction_ids:
        if f == hegemon_id: continue
        var score := _anti_hegemon_join_score(f, hegemon_id, profiles, relations, world, arc_notebook)
        if score >= 0.55:
            candidates.append(f)

    if candidates.size() < COALITION_MIN_MEMBERS:
        return

    # pick leader = highest score
    var leader := candidates[0]
    var best := -1.0
    for f in candidates:
        var s := _anti_hegemon_join_score(f, hegemon_id, profiles, relations, world, arc_notebook)
        if s > best:
            best = s
            leader = f

    var c := CoalitionBlock.new()
    c.kind = &"HEGEMON"
    c.side = &"AGAINST_TARGET"
    c.goal = &"CONTAIN"
    c.target_id = hegemon_id
    c.leader_id = leader
    c.started_day = day
    c.expires_day = day + rng.randi_range(COALITION_MIN_LIFE_DAYS, COALITION_MAX_LIFE_DAYS)
    c.cohesion = 55
    c.progress = 0.0

    c.member_ids = candidates
    for m in c.member_ids:
        c.member_commitment[m] = clampf(_anti_hegemon_join_score(m, hegemon_id, profiles, relations, world, arc_notebook), 0.2, 0.95)
        c.member_role[m] = &"FRONTLINE" if rng.randf() < 0.35 else &"SUPPORT"

    c.id = StringName("coal_heg_%s_%s" % [String(hegemon_id), str(day)])
    coalitions_by_id[c.id] = c
    coalition_id_by_key[key] = c.id

    # Optional: “soft truce” between members to keep it playable
    _apply_temp_truce_for_members(c, day, arc_notebook, 10)


func _ensure_crisis_coalitions(day: int, faction_ids: Array[StringName], profiles: Dictionary, relations: Dictionary, world: Dictionary, arc_notebook) -> void:
    var source: StringName = StringName(world.get("crisis_source_id", &""))   # can be empty (pure world crisis)
    var axis: StringName = StringName(world.get("crisis_axis", &""))
    var sev := float(world.get("crisis_severity", 0.0))

    # A) coalition AGAINST crisis/source (STOP_CRISIS)
    var key_anti := StringName("CRISIS|AGAINST_TARGET|%s" % String(source))
    if not coalition_id_by_key.has(key_anti):
        var anti_members: Array[StringName] = []
        for f in faction_ids:
            # some factions prefer letting crisis grow or are friendly to source => won't join anti
            var s := _stop_crisis_join_score(f, source, axis, sev, profiles, relations, world, arc_notebook)
            if s >= 0.55:
                anti_members.append(f)

        if anti_members.size() >= COALITION_MIN_MEMBERS:
            var leader := _pick_best_leader(anti_members, source, profiles, relations)
            var c := CoalitionBlock.new()
            c.kind = &"CRISIS"
            c.side = &"AGAINST_TARGET"
            c.goal = &"STOP_CRISIS"
            c.target_id = source
            c.leader_id = leader
            c.started_day = day
            c.expires_day = day + rng.randi_range(12, 28)
            c.cohesion = 50
            c.member_ids = anti_members
            for m in c.member_ids:
                c.member_commitment[m] = clampf(_stop_crisis_join_score(m, source, axis, sev, profiles, relations, world, arc_notebook), 0.2, 0.95)
                c.member_role[m] = &"DIPLO" if rng.randf() < 0.25 else &"SUPPORT"
            c.id = StringName("coal_crisis_anti_%s_%s" % [String(source), str(day)])
            coalitions_by_id[c.id] = c
            coalition_id_by_key[key_anti] = c.id
            _apply_temp_truce_for_members(c, day, arc_notebook, 12)

    # B) coalition WITH crisis/source (SUPPORT_CRISIS) if source exists and has allies who want crisis
    if source == &"":
        return
    var key_pro := StringName("CRISIS|WITH_TARGET|%s" % String(source))
    if coalition_id_by_key.has(key_pro):
        return

    var pro_members: Array[StringName] = []
    for f in faction_ids:
        if f == source: continue
        var s2 := _support_crisis_join_score(f, source, axis, sev, profiles, relations, world, arc_notebook)
        if s2 >= 0.62:
            pro_members.append(f)

    # Keep pro coalition smaller: it’s a “cabal”
    if pro_members.size() >= 2:
        var c2 := CoalitionBlock.new()
        c2.kind = &"CRISIS"
        c2.side = &"WITH_TARGET"
        c2.goal = &"SUPPORT_CRISIS"
        c2.target_id = source
        c2.leader_id = source
        c2.started_day = day
        c2.expires_day = day + rng.randi_range(10, 22)
        c2.cohesion = 55
        c2.member_ids = pro_members
        for m in c2.member_ids:
            c2.member_commitment[m] = clampf(_support_crisis_join_score(m, source, axis, sev, profiles, relations, world, arc_notebook), 0.2, 0.95)
            c2.member_role[m] = &"STEALTH" if rng.randf() < 0.5 else &"SUPPORT"
        c2.id = StringName("coal_crisis_pro_%s_%s" % [String(source), str(day)])
        coalitions_by_id[c2.id] = c2
        coalition_id_by_key[key_pro] = c2.id


func _apply_temp_truce_for_members(c: CoalitionBlock, day: int, arc_notebook, truce_days: int) -> void:
    if arc_notebook == null or not arc_notebook.has_method("set_pair_lock"):
        return
    var until := day + truce_days
    for i in range(c.member_ids.size()):
        for j in range(i + 1, c.member_ids.size()):
            var a := c.member_ids[i]
            var b := c.member_ids[j]
            var pair_key := _pair_key(a, b)
            arc_notebook.set_pair_lock(pair_key, until, &"COALITION_TRUCE")


func _spawn_joint_op_offer(c: CoalitionBlock, day: int, profiles: Dictionary, relations: Dictionary, world: Dictionary) -> QuestInstance:
    var tier := clampi(2 + int(floor(c.progress / 35.0)), 1, 5)
    var deadline := 5 if (c.kind == &"CRISIS") else 7

    var joint_type := &"JOINT_OP"
    var quest_type := &"coalition.joint_op"

    if c.kind == &"HEGEMON":
        quest_type = &"coalition.joint_op.contain"
        joint_type = &"SUPPLY_INTERDICTION"
    elif c.kind == &"CRISIS":
        if c.side == &"AGAINST_TARGET":
            quest_type = &"coalition.joint_op.stop_crisis"
            joint_type = &"SEAL_RIFT"
        else:
            quest_type = &"coalition.joint_op.support_crisis"
            joint_type = &"PROTECT_CULT"

    var template :QuestTemplate = _build_template_fallback(StringName(quest_type), tier, deadline)

    var ctx := {
        "is_coalition": true,
        "coalition_id": c.id,
        "coalition_kind": c.kind,
        "coalition_side": c.side,
        "coalition_goal": c.goal,
        "coalition_target_id": c.target_id,
        "coalition_members": c.member_ids,
        "leader_id": c.leader_id,

        "joint_op_type": joint_type,
        "tier": tier,
        "expires_in_days": deadline,

        "giver_faction_id": c.leader_id,
        "antagonist_faction_id": c.target_id,
        "resolution_profile_id": &"coalition_joint_op"
    }

    var inst := QuestInstance.new(template, ctx)
    inst.status = QuestTypes.QuestStatus.AVAILABLE
    inst.started_on_day = day
    inst.expires_on_day = day + deadline
    return inst


func _spawn_pledge_offer(c: CoalitionBlock, day: int, profiles: Dictionary, relations: Dictionary, world: Dictionary) -> QuestInstance:
    var tier := 1
    var deadline := 6
    var template := _build_template_fallback(&"coalition.pledge", tier, deadline)

    var ctx := {
        "is_coalition": true,
        "coalition_id": c.id,
        "coalition_kind": c.kind,
        "coalition_side": c.side,
        "coalition_goal": c.goal,
        "coalition_target_id": c.target_id,
        "coalition_members": c.member_ids,
        "leader_id": c.leader_id,

        "pledge": true,
        "tier": tier,
        "expires_in_days": deadline,

        "giver_faction_id": c.leader_id,
        "antagonist_faction_id": c.target_id,
        "resolution_profile_id": &"coalition_pledge"
    }

    var inst := QuestInstance.new(template, ctx)
    inst.status = QuestTypes.QuestStatus.AVAILABLE
    inst.started_on_day = day
    inst.expires_on_day = day + deadline
    return inst


func _decide_member_stance(
    c: CoalitionBlock,
    m: StringName,
    day: int,
    profiles: Dictionary,
    relations: Dictionary,
    world: Dictionary,
    arc_notebook,
    crisis_axis: StringName,
    crisis_source: StringName
) -> StringName:
    var p = profiles.get(m, null)
    var commit := float(c.member_commitment.get(m, 0.6))

    var opportunism := _p(p, &"opportunism", 0.5)
    var diplomacy := _p(p, &"diplomacy", 0.5)
    var honor := _p(p, &"honor", 0.5)
    var fear := _p(p, &"fear", 0.5)  # optionnel si tu l’as, sinon 0.5

    # relation to leader/target
    var rel_to_leader := _rel(relations, m, c.leader_id)
    var rel_to_target := _rel(relations, m, c.target_id)

    # Axis alignment with crisis (if crisis axis exists)
    var axis_aff := 0.0
    if crisis_axis != &"" and p != null and p.has_method("get_axis_affinity"):
        axis_aff = float(p.get_axis_affinity(crisis_axis, 0)) / 100.0  # -1..+1

# If coalition is AGAINST target but member likes target => more hedge/undermine
    var likes_target = 0.0
    if rel_to_target >= 40.0:
        likes_target = 1.0
    
    var hates_target = 0.0
    if rel_to_target <= -40.0:
        hates_target = 0.0
    var sev := float(world.get("crisis_severity", 0.0))
    var crisis_pressure := sev if (c.kind == &"CRISIS") else 0.0
    # Members can join a crisis coalition even if they dislike others; stance models actual cooperation.
    var p_support :float = 0.25 + 0.55*commit + 0.20*honor + 0.15*hates_target + 0.20*crisis_pressure - 0.20*fear - 0.15*opportunism
    var p_undermine :float = 0.08 + 0.30*opportunism + 0.20*fear + 0.20*likes_target - 0.20*honor

    # Crisis special-case: if axis_aff strongly positive for crisis axis and coalition is STOP_CRISIS => undermine rises
    if c.kind == &"CRISIS" and c.goal == &"STOP_CRISIS" and axis_aff >= 0.55:
        p_undermine += 0.18
        p_support -= 0.10

    # If coalition is SUPPORT_CRISIS and member is anti-axis => they hedge/undermine that coalition
    if c.kind == &"CRISIS" and c.goal == &"SUPPORT_CRISIS" and axis_aff <= -0.45:
        p_support -= 0.15
        p_undermine += 0.10

    # Friendly with crisis source => more undermine in anti coalition, more support in pro coalition
    if crisis_source != &"":
        var rel_to_source := _rel(relations, m, crisis_source)
        if c.goal == &"STOP_CRISIS" and rel_to_source >= 50.0:
            p_undermine += 0.20
            p_support -= 0.10
        if c.goal == &"SUPPORT_CRISIS" and rel_to_source >= 20.0:
            p_support += 0.15

    p_support = clampf(p_support, 0.0, 0.95)
    p_undermine = clampf(p_undermine, 0.0, 0.80)

    var r := rng.randf()
    if r < p_support:
        return STANCE_SUPPORT
    if r < (p_support + p_undermine):
        return STANCE_UNDERMINE
    return STANCE_HEDGE


func _apply_member_deltas(
    c: CoalitionBlock,
    members: Array[StringName],
    stances: Dictionary,
    relations: Dictionary,
    arc_notebook,
    day: int
) -> void:
    # Member vs leader and member vs target
    for m in members:
        var stance: StringName = StringName(stances[m])

        # Leader disappointed by hedgers/underminers
        if m != c.leader_id:
            var modificator_trust = 0
            var modificator_relation = 0
            if stance == STANCE_SUPPORT:
                modificator_trust = +2
                modificator_relation = +1
            elif stance == STANCE_HEDGE:
                modificator_trust = -2
                modificator_relation = -1
            else:
                modificator_trust = -6
                modificator_relation = -4
                
                
            _apply_rel(relations, c.leader_id, m, "trust", (modificator_trust))
            _apply_rel(relations, c.leader_id, m, "relation", (modificator_relation))

        # Target relationship (if target exists)
        if c.target_id != &"" and relations.has(m) and relations[m].has(c.target_id):
            if c.side == &"AGAINST_TARGET":
                if stance == STANCE_SUPPORT:
                    _apply_rel(relations, m, c.target_id, "tension", +4)
                    _apply_rel(relations, m, c.target_id, "grievance", +3)
                    _apply_rel(relations, m, c.target_id, "relation", -3)
                elif stance == STANCE_UNDERMINE:
                    # le membre “fait copain-copain” ou leak => relation s'améliore, coalition le déteste
                    _apply_rel(relations, m, c.target_id, "trust", +2)
                    _apply_rel(relations, m, c.target_id, "relation", +2)
            else:
                # coalition WITH target
                if stance == STANCE_SUPPORT:
                    _apply_rel(relations, m, c.target_id, "trust", +2)
                    _apply_rel(relations, m, c.target_id, "relation", +2)
                elif stance == STANCE_UNDERMINE:
                    _apply_rel(relations, m, c.target_id, "trust", -4)
                    _apply_rel(relations, m, c.target_id, "relation", -3)

    # Member-member trust shifts
    for i in range(members.size()):
        for j in range(i + 1, members.size()):
            var a := members[i]
            var b := members[j]
            var sa: StringName = StringName(stances[a])
            var sb: StringName = StringName(stances[b])

            if sa == STANCE_SUPPORT and sb == STANCE_SUPPORT:
                _apply_rel(relations, a, b, "trust", +2)
                _apply_rel(relations, b, a, "trust", +2)
            elif (sa == STANCE_SUPPORT and sb == STANCE_HEDGE) or (sa == STANCE_HEDGE and sb == STANCE_SUPPORT):
                _apply_rel(relations, a, b, "trust", -1)
                _apply_rel(relations, b, a, "trust", -1)
            elif (sa == STANCE_UNDERMINE and sb == STANCE_SUPPORT) or (sa == STANCE_SUPPORT and sb == STANCE_UNDERMINE):
                _apply_rel(relations, a, b, "trust", -6)
                _apply_rel(relations, b, a, "trust", -6)
                if arc_notebook != null and arc_notebook.has_method("record_pair_event"):
                    arc_notebook.record_pair_event(day, a, b, &"COALITION_BETRAYAL", &"", {}) # debug/metrics


# -------------------- scoring helpers --------------------

func _anti_hegemon_join_score(f: StringName, hegemon: StringName, profiles: Dictionary, relations: Dictionary, world: Dictionary, arc_notebook) -> float:
    # join if fear/hostility or recent losses or ideology clash; also if weak
    var rel := _rel(relations, f, hegemon) / 100.0
    var p = profiles.get(f, null)
    var diplomacy := _p(p, &"diplomacy", 0.5)
    var opportunism := _p(p, &"opportunism", 0.5)
    var honor := _p(p, &"honor", 0.5)

    var power_map: Dictionary = world.get("power_by_faction", {})
    var my_power := float(power_map.get(f, 0.0))
    var heg_power := float(power_map.get(hegemon, 0.0))
    var weak := clampf(1.0 - (my_power / heg_power), 0.0, 1.0) if (heg_power > 0.0) else 0.0

    # history pressure (optional)
    var hist := 0.0
    if arc_notebook != null and arc_notebook.has_method("get_pair_counter"):
        var pk := _pair_key(f, hegemon)
        hist = clampf(0.05 * float(arc_notebook.get_pair_counter(pk, &"hostile_events", 0)), 0.0, 0.4)

    var s := 0.30*weak + 0.30*clampf(-rel, 0.0, 1.0) + 0.15*honor - 0.15*diplomacy + 0.10*opportunism + hist
    return clampf(s, 0.0, 1.0)


func _stop_crisis_join_score(f: StringName, source: StringName, crisis_axis: StringName, sev: float, profiles: Dictionary, relations: Dictionary, world: Dictionary, arc_notebook) -> float:
    # join anti-crisis if altruism/honor/diplomacy, dislikes source, or crisis threatens them
    var p = profiles.get(f, null)
    var honor := _p(p, &"honor", 0.5)
    var diplomacy := _p(p, &"diplomacy", 0.5)
    var opportunism := _p(p, &"opportunism", 0.5)

    var rel_to_source := 0.0 if  (source == &"") else _rel(relations, f, source) / 100.0
    var axis_aff := 0.0
    if crisis_axis != &"" and p != null and p.has_method("get_axis_affinity"):
        axis_aff = float(p.get_axis_affinity(crisis_axis, 0)) / 100.0

    # If member *likes* the crisis axis (ex corruption) => less motivated to stop it
    var axis_resist := clampf(-axis_aff, 0.0, 1.0)

    var s := 0.25*sev + 0.20*honor + 0.20*diplomacy + 0.20*axis_resist + 0.15*clampf(-rel_to_source, 0.0, 1.0) - 0.15*opportunism
    return clampf(s, 0.0, 1.0)


func _support_crisis_join_score(f: StringName, source: StringName, crisis_axis: StringName, sev: float, profiles: Dictionary, relations: Dictionary, world: Dictionary, arc_notebook) -> float:
    # join pro-crisis if opportunistic, aligned with axis, friendly to source
    var p = profiles.get(f, null)
    var opportunism := _p(p, &"opportunism", 0.5)
    var honor := _p(p, &"honor", 0.5)
    var rel_to_source := _rel(relations, f, source) / 100.0

    var axis_aff := 0.0
    if crisis_axis != &"" and p != null and p.has_method("get_axis_affinity"):
        axis_aff = float(p.get_axis_affinity(crisis_axis, 0)) / 100.0

    var s := 0.25*sev + 0.25*opportunism + 0.20*clampf(rel_to_source, 0.0, 1.0) + 0.20*clampf(axis_aff, 0.0, 1.0) - 0.15*honor
    return clampf(s, 0.0, 1.0)


func _pick_best_leader(members: Array[StringName], target: StringName, profiles: Dictionary, relations: Dictionary) -> StringName:
    var best := members[0]
    var bestv := -1.0
    for f in members:
        var p = profiles.get(f, null)
        var diplomacy := _p(p, &"diplomacy", 0.5)
        var honor := _p(p, &"honor", 0.5)
        var rel := _rel(relations, f, target) / 100.0
        var v := 0.40*diplomacy + 0.25*honor + 0.35*clampf(-rel, 0.0, 1.0)
        if v > bestv:
            bestv = v
            best = f
    return best


# -------------------- template builder (fallback) --------------------

func _build_template_fallback(id: StringName, tier: int, expires_in_days: int) -> QuestTemplate:
    var t := QuestTemplate.new()
    t.id = id
    t.title = String(id)
    t.description = "Coalition offer: %s" % String(id)
    t.category = QuestTypes.QuestCategory.COALITION
    t.tier = tier
    t.objective_type = QuestTypes.ObjectiveType.REACH_POI
    t.objective_target = &""
    t.objective_count = 1
    t.expires_in_days = expires_in_days
    return t


# -------------------- tiny relation utils --------------------

func _rel(relations: Dictionary, a: StringName, b: StringName) -> float:
    if a == &"" or b == &"":
        return 0.0
    if not relations.has(a) or not relations[a].has(b):
        return 0.0
    return float(relations[a][b].relation)

func _apply_rel(relations: Dictionary, a: StringName, b: StringName, field: String, delta: int) -> void:
    if a == &"" or b == &"":
        return
    if not relations.has(a) or not relations[a].has(b):
        return
    var r: FactionRelationScore = relations[a][b]
    match field:
        "relation":   r.relation = int(clampi(r.relation + delta, -100, 100))
        "trust":      r.trust = int(clampi(r.trust + delta, 0, 100))
        "tension":    r.tension = int(clampi(r.tension + delta, 0, 100))
        "grievance":  r.grievance = int(clampi(r.grievance + delta, 0, 100))
        "weariness":  r.weariness = int(clampi(r.weariness + delta, 0, 100))

func _p(profile, key: StringName, default_val: float) -> float:
    if profile == null:
        return default_val
    if profile.has_method("get_personality"):
        return float(profile.get_personality(key, default_val))
    if profile is Dictionary:
        return float(profile.get("personality", {}).get(key, default_val))
    return default_val

func _pair_key(a: StringName, b: StringName) -> StringName:
    var sa := String(a)
    var sb := String(b)
    return StringName((sa + "|" + sb) if (sa <= sb) else (sb + "|" + sa))
