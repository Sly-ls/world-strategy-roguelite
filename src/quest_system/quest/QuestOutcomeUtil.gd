# QuestOutcomeUtil.gd
class_name QuestOutcomeUtil
extends RefCounted

static func compute_outcome_success(inst, actor_profile, opposition: Dictionary, tier: int, rng: RandomNumberGenerator = null) -> bool:
    var ctx: Dictionary = inst.context if inst != null and "context" in inst else {}
    var action_type: StringName = StringName(ctx.get("arc_action_type", ctx.get("tp_action", ctx.get("quest_type", &""))))

    # --- base chance from tier ---
    var p := 0.62 - 0.08 * float(max(0, tier - 1))  # tier 1 ~0.62, tier 5 ~0.30
    p = clampf(p, 0.05, 0.90)

    # --- conflict heat / friction (works for 2 or 3 factions) ---
    var tension := float(opposition.get("tension_mean", opposition.get("tension", 0.0))) / 100.0
    var grievance := float(opposition.get("grievance_mean", opposition.get("grievance", 0.0))) / 100.0
    var friction := float(opposition.get("friction", 0.0))          # 0..1 (si tu l’as)
    var heat := clampf(0.55 * tension + 0.35 * grievance + 0.30 * friction, 0.0, 1.0)

    # --- actor skill (2 or 3 participants) ---
    var skill := _compute_actor_skill(actor_profile, ctx, action_type) # 0..1

    # --- opposition resistance (optional) ---
    var opp := float(opposition.get("resistance", 0.5))               # 0..1
    var opp_participants := opposition.get("participants", null)
    if opp_participants is Dictionary:
        opp = clampf(0.5 + 0.35 * float(opp_participants.size() - 1), 0.5, 0.95)

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


static func _compute_actor_skill(actor_profile, ctx: Dictionary, action_type: StringName) -> float:
    # actor_profile can be:
    # - a single profile (has get_personality)
    # - a Dictionary {faction_id: profile}
    # - a Dictionary {"profile": ..., "profiles": ...} (if you want later)
    var actor_id: StringName = StringName(ctx.get("actor_faction_id", ctx.get("giver_faction_id", &"")))
    var prof = actor_profile
    if actor_profile is Dictionary and actor_profile.has(actor_id):
        prof = actor_profile[actor_id]

    # choose key weights by action
    var dip := _p(prof, &"diplomacy", 0.5)
    var hon := _p(prof, &"honor", 0.5)
    var cun := _p(prof, &"cunning", 0.5)
    var opp := _p(prof, &"opportunism", 0.5)
    var agr := _p(prof, &"aggression", 0.5)
    var dis := _p(prof, &"discipline", 0.5)

    match action_type:
        &"tp.mediation", &"arc.truce_talks":
            # bon médiateur = dip/honor/discipline, mauvais = opportunism/aggression
            return clampf(0.40*dip + 0.25*hon + 0.20*dis + 0.10*cun - 0.20*opp - 0.15*agr, 0.0, 1.0)
        &"arc.raid", &"arc.sabotage":
            return clampf(0.40*cun + 0.25*dis + 0.15*agr - 0.10*hon - 0.05*dip, 0.0, 1.0)
        _:
            return clampf(0.25*dip + 0.20*dis + 0.20*cun + 0.10*hon - 0.10*opp, 0.0, 1.0)


static func _p(profile, key: StringName, default_val: float) -> float:
    if profile == null:
        return default_val
    if profile.has_method("get_personality"):
        return float(profile.get_personality(key, default_val))
    if profile is Dictionary:
        # accept either {"personality":{...}} or direct keys
        if profile.has("personality"):
            return float(profile["personality"].get(key, default_val))
        return float(profile.get(key, default_val))
    return default_val
