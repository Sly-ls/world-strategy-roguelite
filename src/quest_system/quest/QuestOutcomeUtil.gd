# QuestOutcomeUtil.gd
class_name QuestOutcomeUtil
extends RefCounted

  
static func compute_outcome_success(inst, tier: int, rng: RandomNumberGenerator = null) -> bool:
    var ctx: Dictionary = inst.context if inst != null and "context" in inst else {}
    var action_type: StringName = StringName(ctx.get("action_type", &""))
    var f_mediator_id = ctx.get("third_party_id")
    var f_a_id = ctx.get("giver_faction_id")
    var f_b_id = ctx.get("antagonist_faction_id")
    var faction_a = FactionManager.get_faction(f_a_id)
    var faction_b = FactionManager.get_faction(f_b_id)
    var relation_ab = faction_a.get_relation_to(f_b_id)
    var relation_ba = faction_b.get_relation_to(f_a_id)
    relation_ab.get_score(FactionRelationScore.REL_TENSION)
    var mediator_profile = FactionManager.get_faction(f_mediator_id).profile
    # --- base chance from tier ---
    var p := 0.62 - 0.08 * float(max(0, tier - 1))  # tier 1 ~0.62, tier 5 ~0.30
    p = clampf(p, 0.05, 0.90)
    # --- conflict heat / friction (works for 2 or 3 factions) ---
    var tension := float(max(relation_ab.get_score(FactionRelationScore.REL_TENSION), relation_ba.get_score(FactionRelationScore.REL_TENSION))) / 100.0
    var grievance := float(max(relation_ab.get_score(FactionRelationScore.REL_GRIEVANCE), relation_ba.get_score(FactionRelationScore.REL_GRIEVANCE))) / 100.0
    var friction := float(max(relation_ab.get_score(FactionRelationScore.REL_FRICTION), relation_ba.get_score(FactionRelationScore.REL_FRICTION))) / 100.0
    var heat := clampf(0.55 * tension + 0.35 * grievance + 0.30 * friction, 0.0, 1.0)

    # --- actor skill (2 or 3 participants) ---
    var skill := _compute_actor_skill(mediator_profile, ctx, action_type) # 0..1

    # --- opposition resistance (optional) ---
    var opp := float(max(relation_ab.get_score(FactionRelationScore.REL_RESISTANCE), relation_ba.get_score(FactionRelationScore.REL_RESISTANCE)))
    #TODO NOT USED ANYMORE? TO BE CONFIRMED
    #var opp_participants :Dictionary = opposition.get("participants", null)
    #if opp_participants is Dictionary:
    #    opp = clampf(0.5 + 0.35 * float(opp_participants.size() - 1), 0.5, 0.95)

    # --- action-specific shaping ---
    match action_type:
        &"tp.mediation":
            # médiation = très sensible à la heat
            p += 0.40 * (skill - 0.5)
            p -= 0.55 * heat
            p -= 0.20 * (opp - 0.5)
        &"arc.truce_talks":
            p += 0.25 * (skill - 0.5)
            p -= 0.40 * heat
            p -= 0.15 * (opp - 0.5)
        &"arc.raid", &"arc.sabotage":
            p += 0.30 * (skill - 0.5)
            p -= 0.25 * heat
            p -= 0.25 * (opp - 0.5)
        _:
            p += 0.25 * (skill - 0.5)
            p -= 0.30 * heat
            p -= 0.15 * (opp - 0.5)

    p = clampf(p, 0.05, 0.95)

    # --- deterministic roll support ---
    var roll := float(ctx.get("roll", -1.0))
    if roll < 0.0:
        if rng != null:
            roll = rng.randf()
        else:
            # fallback deterministic-ish (not ideal but stable): hash(day+runtime_id)
            var seed := int(ctx.get("day", 0)) * 73856093 ^ int(hash(String(ctx.get("runtime_id", ""))))
            var local_rng := RandomNumberGenerator.new()
            local_rng.seed = seed
            roll = local_rng.randf()

    # store for debug/metrics
    ctx["last_success_chance"] = p
    ctx["last_roll"] = roll
    inst.context = ctx if inst != null and "context" in inst else ctx

    return roll < p


static func _compute_actor_skill(profile :FactionProfile, ctx: Dictionary, action_type: StringName) -> float:
    # actor_profile can be:
    # - a single profile (has get_personality)
    # - a Dictionary {faction_id: profile}
    # - a Dictionary {"profile": ..., "profiles": ...} (if you want later)
    # TODO JE PENSE QUE CE N4EST PLUS LE CAS, A REVOIR
    #var actor_id: StringName = StringName(ctx.get("actor_faction_id", ctx.get("giver_faction_id", &"")))
    #var prof = actor_profile
    #if actor_profile is Dictionary and actor_profile.has(actor_id):
    #    prof = actor_profile[actor_id]

    # choose key weights by action
    var cun :float = profile.get_personality(FactionProfile.PERS_CUNNING)
    var dip :float = profile.get_personality(FactionProfile.PERS_DIPLOMACY)
    var agr :float = profile.get_personality(FactionProfile.PERS_AGGRESSION)
    var opp :float = profile.get_personality(FactionProfile.PERS_OPPORTUNISM)
    var dis :float = profile.get_personality(FactionProfile.PERS_DISCIPLINE)
    var hon :float = profile.get_personality(FactionProfile.PERS_HONOR)
    match action_type:
        &"tp.mediation", &"arc.truce_talks":
            # bon médiateur = dip/honor/discipline, mauvais = opportunism/aggression
            return clampf(0.40*dip + 0.25*hon + 0.20*dis + 0.10*cun - 0.20*opp - 0.15*agr, 0.0, 1.0)
        &"arc.raid", &"arc.sabotage":
            return clampf(0.40*cun + 0.25*dis + 0.15*agr - 0.10*hon - 0.05*dip, 0.0, 1.0)
        _:
            return clampf(0.25*dip + 0.20*dis + 0.20*cun + 0.10*hon - 0.10*opp, 0.0, 1.0)
