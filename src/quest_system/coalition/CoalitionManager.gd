# CoalitionManager.gd
extends Node
## Gestionnaire des coalitions
## NOTE: Utilise CoalitionBlock depuis le fichier externe (class_name CoalitionBlock)
## La classe interne a été supprimée pour éviter le conflit "hides a global script class"

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
    world: Dictionary,            # must have try_add_offer(inst)
) -> void:
    # 0) upkeep / expire
    _cleanup_and_expire(day)

    var arc_notebook :ArcNotebook = ArcManagerRunner.arc_notebook
    var all_factions :Array[Faction] = FactionManager.get_all_factions()
    var hegemon_faction :Faction = null
    # 1) CRISIS coalitions (can be AGAINST or WITH the crisis instigator)
    if bool(world.get("crisis_active", false)):
        var sev := float(world.get("crisis_severity", 0.0))
        if sev >= CRISIS_THRESHOLD:
            _ensure_crisis_coalitions(day, all_factions, world)

    # 2) HEGEMON coalition (anti-dominance) if no overriding crisis or if crisis not huge
    var hegemon_id := _detect_hegemon(all_factions, world)
    if hegemon_id != &"":
        var hegemon_index := float(world.get("hegemon_index_by_faction", {}).get(hegemon_id, 0.0))
        if hegemon_index >= HEGEMON_THRESHOLD:
            hegemon_faction = FactionManager.get_faction(hegemon_id)
            _ensure_hegemon_coalition(day, all_factions, hegemon_faction, world)

    # 3) Spawn offers (1–2 max / coalition, cooldown)
    for cid in coalitions_by_id.keys():
        var c: CoalitionBlock = coalitions_by_id[cid]
        if day < c.lock_until_day:
            continue
        if (day - c.last_offer_day) < OFFER_COOLDOWN_DAYS:
            continue
        if not arc_notebook.can_spawn_coalition_offer(c.id, day, OFFER_COOLDOWN_DAYS):
            continue

        var spawned := 0
        # Always try JOINT OP first
        var inst := _spawn_joint_op_offer(c, day, world)
        if inst != null and QuestPool != null and QuestPool.has_method("try_add_offer"):
            if QuestPool.try_add_offer(inst):
                spawned += 1

        # Optional PLEDGE offer if cohesion low or crisis with mixed members (even at war)
        if spawned < MAX_OFFERS_PER_COALITION_PER_TICK:
            if c.cohesion <= 55 or c.kind == &"CRISIS":
                var inst2 := _spawn_pledge_offer(c, day, world)
                if inst2 != null and QuestPool != null and QuestPool.has_method("try_add_offer"):
                    if QuestPool.try_add_offer(inst2):
                        spawned += 1

        if spawned > 0:
            c.last_offer_day = day
            if arc_notebook != null and arc_notebook.has_method("mark_coalition_offer_spawned"):
                arc_notebook.mark_coalition_offer_spawned(c.id, day)


# ------------------------------------------------------------
# apply_joint_op_resolution(): member stances + progress/cohesion + deltas
# ------------------------------------------------------------

func _apply_temp_truce_for_members(c: CoalitionBlock, day: int, truce_days: int) -> void:
    var arc_notebook = ArcManagerRunner.arc_notebook
    if arc_notebook == null or not arc_notebook.has_method("set_pair_lock"):
        return
    var until := day + truce_days
    for i in range(c.member_ids.size()):
        for j in range(i + 1, c.member_ids.size()):
            var a := c.member_ids[i]
            var b := c.member_ids[j]
            var pair_key := Utils.pair_key(a, b)
            arc_notebook.set_pair_lock(pair_key, until, &"COALITION_TRUCE")
            
func apply_joint_op_resolution(
    context: Dictionary,           # from QuestInstance.context
    choice: StringName,            # LOYAL/NEUTRAL/TRAITOR (player)
    day: int,
    world: Dictionary,
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
        var member = FactionManager.get_faction(m)
        var stance := _decide_member_stance(c, member, day, world, crisis_axis, crisis_source)
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
    _apply_member_deltas(c, members, stances, day)

    # 4) Member commitment shifts (people can hedge/undermine without being "LOYAL")
    for m in members:
        var commit := float(c.member_commitment.get(m, 0.6))
        match StringName(stances[m]):
            STANCE_SUPPORT:
                commit = clampf(commit + 0.06, 0.0, 1.0)
            STANCE_HEDGE:
                commit = clampf(commit - 0.03, 0.0, 1.0)
            STANCE_UNDERMINE:
                commit = clampf(commit - 0.12, 0.0, 1.0)
        c.member_commitment[m] = commit


# ------------------------------------------------------------
# apply_pledge_resolution(): player just committed to a coalition
# ------------------------------------------------------------
func apply_pledge_resolution(
    context: Dictionary,
    choice: StringName,            # ACCEPT/DECLINE/BETRAY
    day: int,
    profiles: Dictionary,
    relations: Dictionary,
    world: Dictionary,
    arc_notebook
) -> void:
    if not bool(context.get("is_coalition_pledge", false)):
        return

    var cid: StringName = StringName(context.get("coalition_id", &""))
    if cid == &"" or not coalitions_by_id.has(cid):
        return
    var c: CoalitionBlock = coalitions_by_id[cid]

    match choice:
        &"ACCEPT":
            c.cohesion = int(clampi(c.cohesion + 3, 0, 100))
            # optionally add player to coalition if not already (skip for simplicity)
        &"DECLINE":
            c.cohesion = int(clampi(c.cohesion - 2, 0, 100))
        &"BETRAY":
            c.cohesion = int(clampi(c.cohesion - 8, 0, 100))
            # possibly spawn UNDERMINE flag if player is a member
            if arc_notebook != null and arc_notebook.has_method("record_pair_event"):
                arc_notebook.record_pair_event(day, c.leader_id, &"player", &"COALITION_BETRAYAL", &"", {})


# ------------------------------------------------------------
# _cleanup_and_expire(day, arc_notebook)
# ------------------------------------------------------------
func _cleanup_and_expire(day: int) -> void:
    var to_remove: Array[StringName] = []
    for cid in coalitions_by_id.keys():
        var c: CoalitionBlock = coalitions_by_id[cid]
        if c.is_expired(day) or c.cohesion <= 0 or c.member_count() < 2:
            to_remove.append(cid)

    for cid in to_remove:
        var c: CoalitionBlock = coalitions_by_id[cid]
        coalition_id_by_key.erase(c.key())
        coalitions_by_id.erase(cid)


# ------------------------------------------------------------
# _detect_hegemon(faction_ids, world)
# ------------------------------------------------------------
func _detect_hegemon(all_factions :Array[Faction], world: Dictionary) -> StringName:
    var hegemon_index_map: Dictionary = world.get("hegemon_index_by_faction", {})
    var best_id := &""
    var best_val := 0.0
    for faction in all_factions:
        var fid = faction.id
        var val := float(hegemon_index_map.get(fid, 0.0))
        if val > best_val:
            best_val = val
            best_id = fid
    return best_id


# ------------------------------------------------------------
# _ensure_hegemon_coalition(...)
# ------------------------------------------------------------

func _ensure_hegemon_coalition(day: int, 
all_factions: Array[Faction],
hegemon: Faction, 
world: Dictionary) -> void:
    var key := StringName("HEGEMON|AGAINST_TARGET|%s" % String(hegemon.id))
    if coalition_id_by_key.has(key):
        return

    # candidates: factions not hegemon, with fear/hostility, or simply weak ones under pressure
    var candidates: Array[Faction] = []
    for faction in all_factions:
        if faction == hegemon: continue
        var score := _anti_hegemon_join_score(faction, hegemon, world)
        if score >= 0.55:
            candidates.append(faction)

    if candidates.size() < COALITION_MIN_MEMBERS:
        return

    # pick leader = highest score
    var leader := candidates[0]
    var best := -1.0
    for faction in candidates:
        var s := _anti_hegemon_join_score(faction, hegemon, world)
        if s > best:
            best = s
            leader = faction

    var c := CoalitionBlock.new()
    c.kind = &"HEGEMON"
    c.side = &"AGAINST_TARGET"
    c.goal = &"CONTAIN"
    c.target_id = hegemon.id
    c.leader_id = leader.id
    c.started_day = day
    c.expires_day = day + rng.randi_range(COALITION_MIN_LIFE_DAYS, COALITION_MAX_LIFE_DAYS)
    c.cohesion = 55
    c.progress = 0.0
    
    c.member_ids = candidates.map(func(f): return f.id)
    for m in c.member_ids:
        var faction :Faction = FactionManager.get_faction(m)
        c.member_commitment[m] = clampf(_anti_hegemon_join_score(faction, hegemon, world), 0.2, 0.95)
        c.member_role[m] = &"FRONTLINE" if rng.randf() < 0.35 else &"SUPPORT"

    c.id = StringName("coal_heg_%s_%s" % [String(hegemon.id), str(day)])
    coalitions_by_id[c.id] = c
    coalition_id_by_key[key] = c.id

    # Optional: “soft truce” between members to keep it playable
    _apply_temp_truce_for_members(c, day, 10)

# ------------------------------------------------------------
# _ensure_crisis_coalitions(...)
# ------------------------------------------------------------
func _ensure_crisis_coalitions(
    day: int,
    all_factions :Array[Faction],
    world: Dictionary,
) -> void:
    var source: StringName = StringName(world.get("crisis_source_id", &""))   # can be empty (pure world crisis)
    var source_faction: Faction = FactionManager.get_faction(source)
    var axis: StringName = StringName(world.get("crisis_axis", &""))
    var sev := float(world.get("crisis_severity", 0.0))
    # A) coalition AGAINST crisis/source (STOP_CRISIS)
    var key_anti := StringName("CRISIS|AGAINST_TARGET|%s" % String(source))
    if not coalition_id_by_key.has(key_anti):
        var anti_members: Array[StringName] = []
        for faction :Faction  in all_factions:
            # some factions prefer letting crisis grow or are friendly to source => won't join anti
            var s := _stop_crisis_join_score(faction, source_faction, axis, sev, world)
            if s >= 0.55:
                anti_members.append(faction)

        if anti_members.size() >= COALITION_MIN_MEMBERS:
            var leader := _pick_best_leader(anti_members, source)
            var c := CoalitionBlock.new()
            c.kind = &"CRISIS"
            c.side = &"AGAINST_TARGET"
            c.goal = &"STOP_CRISIS"
            c.target_id = source
            c.leader_id = leader
            c.started_day = day
            c.expires_day = day + rng.randi_range(12, 28)
            c.cohesion = 50
            c.member_ids = anti_members.map(func(f): return f.id)
            for m in c.member_ids:
                var faction = FactionManager.get_faction(m)
                c.member_commitment[m] = clampf(_stop_crisis_join_score(faction, source_faction, axis, sev, world), 0.2, 0.95)
                c.member_role[m] = &"DIPLO" if rng.randf() < 0.25 else &"SUPPORT"
            c.id = StringName("coal_crisis_anti_%s_%s" % [String(source), str(day)])
            coalitions_by_id[c.id] = c
            coalition_id_by_key[key_anti] = c.id
            _apply_temp_truce_for_members(c, day, 12)

    # B) coalition WITH crisis/source (SUPPORT_CRISIS) if source exists and has allies who want crisis
    if source == &"":
        return
    var key_pro := StringName("CRISIS|WITH_TARGET|%s" % String(source))
    if coalition_id_by_key.has(key_pro):
        return

    var pro_members: Array[Faction] = []
    for faction in all_factions:
        if faction == source_faction: continue
        var s2 := _support_crisis_join_score(faction, source_faction, axis, sev, world)
        if s2 >= 0.62:
            pro_members.append(faction)

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
        c2.member_ids = pro_members.map(func(f): return f.id)
        for m in c2.member_ids:
            var faction = FactionManager.get_faction(m)
            c2.member_commitment[m] = clampf(_support_crisis_join_score(faction, source_faction, axis, sev, world), 0.2, 0.95)
            c2.member_role[m] = &"STEALTH" if rng.randf() < 0.5 else &"SUPPORT"
        c2.id = StringName("coal_crisis_pro_%s_%s" % [String(source), str(day)])
        coalitions_by_id[c2.id] = c2
        coalition_id_by_key[key_pro] = c2.id



# ------------------------------------------------------------
# _decide_member_stance(c, m, day, profiles, relations, world, arc_notebook, crisis_axis, crisis_source)
# ------------------------------------------------------------
func _decide_member_stance(
    c: CoalitionBlock,
    member: Faction,
    day: int,
    world: Dictionary,
    crisis_axis: StringName,
    crisis_source: StringName
) -> StringName:
    var diplomacy :float = member.profile.get_personality(FactionProfile.PERS_DIPLOMACY)
    var honor :float = member.profile.get_personality(FactionProfile.PERS_HONOR)
    var opportunism :float = member.profile.get_personality(FactionProfile.PERS_OPPORTUNISM)

    var commit := float(c.member_commitment.get(member.id, 0.6))

    # Relation to target
    var rel_score :float = member.get_relation_to(c.target_id).get_score(FactionRelationScore.REL_RELATION)
    var rel_to_target = rel_score / 100.0

    # Axis affinity (for crisis)
    var axis_aff := 0.0
    axis_aff = float(member.profile.get_axis_affinity(crisis_axis, 0)) / 100.0

    # Base probability
    var p_support := 0.40 + 0.30*commit + 0.15*honor + 0.10*diplomacy
    var p_undermine := 0.10 + 0.25*opportunism - 0.15*honor - 0.10*commit

    # Modulate based on coalition type
    if c.side == &"AGAINST_TARGET":
        # If member secretly likes target => more likely to undermine
        if rel_to_target > 0.3:
            p_undermine += 0.15 * rel_to_target
            p_support -= 0.10 * rel_to_target
    else:
        # WITH_TARGET: if member dislikes target => undermine
        if rel_to_target < -0.3:
            p_undermine += 0.15 * abs(rel_to_target)
            p_support -= 0.10 * abs(rel_to_target)

    # Crisis axis: if aligned with crisis => less motivated to stop it
    if c.goal == &"STOP_CRISIS" and axis_aff > 0.3:
        p_undermine += 0.10 * axis_aff
        p_support -= 0.10 * axis_aff

    p_support = clampf(p_support, 0.05, 0.95)
    p_undermine = clampf(p_undermine, 0.02, 0.40)

    var roll := rng.randf()
    if roll < p_undermine:
        return STANCE_UNDERMINE
    elif roll < p_undermine + (1.0 - p_support - p_undermine):
        return STANCE_HEDGE
    else:
        return STANCE_SUPPORT


# ------------------------------------------------------------
# _spawn_joint_op_offer(c, day, profiles, relations, world)
# ------------------------------------------------------------
func _spawn_joint_op_offer(c: CoalitionBlock, day: int, world: Dictionary) -> QuestInstance:
    var tier := 2
    if c.kind == &"CRISIS":
        tier = 3
    if c.progress >= 70.0:
        tier = 4

    var t := _build_template_fallback(StringName("coalition_joint_%s" % String(c.id)), tier, 5)
    t.title = "Coalition: %s" % String(c.goal)
    t.description = "Joint operation for coalition %s" % String(c.id)

    var ctx := {
        "is_coalition": true,
        "coalition_id": c.id,
        "coalition_kind": c.kind,
        "coalition_goal": c.goal,
        "coalition_target": c.target_id,
        "tier": tier,
        "joint_op_type": &"JOINT_MILITARY"
    }

    var inst := QuestInstance.new(t, ctx)
    inst.status = QuestTypes.QuestStatus.AVAILABLE
    return inst


# ------------------------------------------------------------
# _spawn_pledge_offer(c, day, profiles, relations, world)
# ------------------------------------------------------------
func _spawn_pledge_offer(c: CoalitionBlock, 
day: int, 
world: Dictionary) -> QuestInstance:
    var t := _build_template_fallback(StringName("coalition_pledge_%s" % String(c.id)), 1, 3)
    t.title = "Pledge to %s Coalition" % String(c.goal)
    t.description = "Commit to coalition %s" % String(c.id)

    var ctx := {
        "is_coalition_pledge": true,
        "coalition_id": c.id,
        "coalition_kind": c.kind,
        "coalition_goal": c.goal,
        "tier": 1
    }

    var inst := QuestInstance.new(t, ctx)
    inst.status = QuestTypes.QuestStatus.AVAILABLE
    return inst


# ------------------------------------------------------------
# _apply_member_deltas(...)
# ------------------------------------------------------------
func _apply_member_deltas(
    c: CoalitionBlock,
    members: Array[StringName],
    stances: Dictionary,
    day: int
) -> void:
    # Leader trust towards members based on stance
    var leader :Faction = FactionManager.get_faction(c.leader_id)
    for m in members:
        var stance: StringName = StringName(stances.get(m, STANCE_HEDGE))
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
                
            leader.get_relation_to(m).apply_delta_to(FactionRelationScore.REL_TRUST, modificator_trust)
            leader.get_relation_to(m).apply_delta_to(FactionRelationScore.REL_RELATION, modificator_relation)

        # Target relationship (if target exists)
        if c.target_id != &"":
            var member :Faction = FactionManager.get_faction(m)
            if c.side == &"AGAINST_TARGET":
                if stance == STANCE_SUPPORT:
                    member.get_relation_to(c.target_id).apply_delta_to(FactionRelationScore.REL_TENSION, +4)
                    member.get_relation_to(c.target_id).apply_delta_to(FactionRelationScore.REL_GRIEVANCE, +3)
                    member.get_relation_to(c.target_id).apply_delta_to(FactionRelationScore.REL_RELATION, -3)
                elif stance == STANCE_UNDERMINE:
                    # le membre "fait copain-copain" ou leak => relation s'améliore, coalition le déteste
                    member.get_relation_to(c.target_id).apply_delta_to(FactionRelationScore.REL_TRUST, +2)
                    member.get_relation_to(c.target_id).apply_delta_to(FactionRelationScore.REL_RELATION, +2)
            else:
                # coalition WITH target
                if stance == STANCE_SUPPORT:
                    member.get_relation_to(c.target_id).apply_delta_to(FactionRelationScore.REL_TRUST, +2)
                    member.get_relation_to(c.target_id).apply_delta_to(FactionRelationScore.REL_RELATION, +2)
                elif stance == STANCE_UNDERMINE:
                    member.get_relation_to(c.target_id).apply_delta_to(FactionRelationScore.REL_TRUST, -4)
                    member.get_relation_to(c.target_id).apply_delta_to(FactionRelationScore.REL_RELATION, -3)

    # Member-member trust shifts
    for i in range(members.size()):
        for j in range(i + 1, members.size()):
            var a := members[i]
            var b := members[j]
            var sa: StringName = StringName(stances[a])
            var sb: StringName = StringName(stances[b])
            var member_a := FactionManager.get_faction(members[i])
            var member_b := FactionManager.get_faction(members[j])

            if sa == STANCE_SUPPORT and sb == STANCE_SUPPORT:
                member_a.get_relation_to(b).apply_delta_to(FactionRelationScore.REL_TRUST, 2)
                member_b.get_relation_to(a).apply_delta_to(FactionRelationScore.REL_TRUST, 2)
            elif (sa == STANCE_SUPPORT and sb == STANCE_HEDGE) or (sa == STANCE_HEDGE and sb == STANCE_SUPPORT):
                member_a.get_relation_to(b).apply_delta_to(FactionRelationScore.REL_TRUST, -1)
                member_b.get_relation_to(a).apply_delta_to(FactionRelationScore.REL_TRUST, -1)
            elif (sa == STANCE_UNDERMINE and sb == STANCE_SUPPORT) or (sa == STANCE_SUPPORT and sb == STANCE_UNDERMINE):
                member_a.get_relation_to(b).apply_delta_to(FactionRelationScore.REL_TRUST, -6)
                member_b.get_relation_to(a).apply_delta_to(FactionRelationScore.REL_TRUST, -6)
                ArcManagerRunner.arc_notebook.record_pair_event(day, a, b, &"COALITION_BETRAYAL", &"", {}) # debug/metrics


# -------------------- scoring helpers --------------------

func _anti_hegemon_join_score(
faction: Faction, 
hegemon: Faction, 
world: Dictionary) -> float:
    # join if fear/hostility or recent losses or ideology clash; also if weak
    var relation = faction.get_relation(hegemon.id)
    var rel :float = relation.get_score(FactionRelationScore.REL_RELATION) / 100.0
    var diplomacy :float = faction.profile.get_personality(FactionProfile.PERS_DIPLOMACY)
    var opportunism :float = faction.profile.get_personality(FactionProfile.PERS_OPPORTUNISM)
    var honor :float = faction.profile.get_personality(FactionProfile.PERS_HONOR)

    var power_map: Dictionary = world.get("power_by_faction", {})
    var my_power := float(power_map.get(faction.id, 0.0))
    var heg_power := float(power_map.get(hegemon.id, 0.0))
    var weak := clampf(1.0 - (my_power / heg_power), 0.0, 1.0) if (heg_power > 0.0) else 0.0

    # history pressure (optional)
    var hist := 0.0
    var pk := Utils.pair_key(faction.id, hegemon.id)
    hist = clampf(0.05 * float(ArcManagerRunner.arc_notebook.get_pair_counter(pk, &"hostile_events", 0)), 0.0, 0.4)

    var s := 0.30*weak + 0.30*clampf(-rel, 0.0, 1.0) + 0.15*honor - 0.15*diplomacy + 0.10*opportunism + hist
    return clampf(s, 0.0, 1.0)


func _stop_crisis_join_score(faction: Faction, source: Faction, crisis_axis: StringName, sev: float, world: Dictionary) -> float:
    # join anti-crisis if altruism/honor/diplomacy, dislikes source, or crisis threatens them
    var diplomacy :float = faction.profile.get_personality(FactionProfile.PERS_DIPLOMACY)
    var opportunism :float = faction.profile.get_personality(FactionProfile.PERS_OPPORTUNISM)
    var honor :float = faction.profile.get_personality(FactionProfile.PERS_HONOR)
    
    var rel_to_source := faction.get_relation_to(source.id).get_score(FactionRelationScore.REL_RELATION) / 100.0
    var axis_aff := 0.0
    axis_aff = float(faction.profile.get_axis_affinity(crisis_axis, 0)) / 100.0

    # If member *likes* the crisis axis (ex corruption) => less motivated to stop it
    var axis_resist := clampf(-axis_aff, 0.0, 1.0)

    var s := 0.25*sev + 0.20*honor + 0.20*diplomacy + 0.20*axis_resist + 0.15*clampf(-rel_to_source, 0.0, 1.0) - 0.15*opportunism
    return clampf(s, 0.0, 1.0)


func _support_crisis_join_score(faction: Faction, source: Faction, crisis_axis: StringName, sev: float, world: Dictionary) -> float:
    # join pro-crisis if opportunistic, aligned with axis, friendly to source
    var opportunism :float = faction.profile.get_personality(FactionProfile.PERS_OPPORTUNISM)
    var honor :float = faction.profile.get_personality(FactionProfile.PERS_HONOR)
    var rel_to_source := faction.get_relation_to(source.id).get_score(FactionRelationScore.REL_RELATION) / 100.0

    var axis_aff := 0.0
    axis_aff = float(faction.profile.get_axis_affinity(crisis_axis, 0)) / 100.0

    var s := 0.25*sev + 0.25*opportunism + 0.20*clampf(rel_to_source, 0.0, 1.0) + 0.20*clampf(axis_aff, 0.0, 1.0) - 0.15*honor
    return clampf(s, 0.0, 1.0)


func _pick_best_leader(members: Array[StringName], target: StringName) -> StringName:
    var best := members[0]
    var bestv := -1.0
    for f in members:
        var faction = FactionManager.get_faction(f)
        var diplomacy :float = faction.profile.get_personality(FactionProfile.PERS_DIPLOMACY, 0.5)
        var honor :float = faction.profile.get_personality(FactionProfile.PERS_HONOR, 0.5)
        var rel := faction.get_relation_to(target).get_score(FactionRelationScore.REL_RELATION) / 100.0
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
    t.objective_type = QuestTypes.ObjectiveType.GENERIC
    t.objective_target = &""
    t.objective_count = 1
    t.expires_in_days = expires_in_days
    return t
