# RewardEconomyUtil.gd
class_name RewardEconomyUtil
extends RefCounted


static func compute_reward_style(econ: Dictionary, tier: int, profile :FactionProfile = null) -> Dictionary:
    var wealth: StringName = StringName(econ.get("wealth_level", &"MODEST"))
    var liquidity: float = float(econ.get("liquidity", 0.5))

    var rich := (wealth == &"RICH" or wealth == &"OPULENT")
    var poor := (wealth == &"POOR" or liquidity < 0.35)

    # base stable
    var w_gold_base := 0.78 if rich else (0.12 if poor else 0.42)

    # --- personality delta (bounded) ---
    var dw := _w_gold_personality_delta(profile) # [-0.12..+0.12]
    var w_gold := clampf(w_gold_base + dw, 0.05, 0.95)

    # --- guard rails to keep tests stable ---
    if poor:
        w_gold = min(w_gold, 0.35)   # poor ne paye presque jamais en or
    if rich:
        w_gold = max(w_gold, 0.60)   # rich paye souvent en or

    var w_non := 1.0 - w_gold

    # opportunism heat: econ-driven (peut aussi être affecté par personnalité mais pas obligé)
    var opportunism_heat := 0.10 + (0.35 if rich else 0.0) + 0.05 * float(tier)
    opportunism_heat = clampf(opportunism_heat, 0.0, 1.0)

    return {"w_gold": w_gold, "w_non": w_non, "opportunism_heat": opportunism_heat, "w_gold_base": w_gold_base, "w_gold_dw": dw}

static func _w_gold_personality_delta(profile) -> float:
    # Greedy/mercantile/opportunist -> w_gold ↑
    # Honor/discipline/idealist -> w_gold ↓ (plus de faveurs/traités)
    if profile == null:
        return 0.0
    var greed :float = profile.get_personality(FactionProfile.PERS_GREED)
    var opp :float = profile.get_personality(FactionProfile.PERS_OPPORTUNISM)
    var dis :float = profile.get_personality(FactionProfile.PERS_DISCIPLINE)
    var hon :float = profile.get_personality(FactionProfile.PERS_HONOR)
    
    # “greed” est dominant, sinon opportunism fait le job
    var raw := 0.60*(greed - 0.5) + 0.35*(opp - 0.5) - 0.25*(dis - 0.5) - 0.20*(hon - 0.5)

    # Borné pour stabilité
    return clampf(raw, -0.12, 0.12)
    
static func build_reward_bundle(econ: Dictionary, tier: int, action_type: StringName, rng: RandomNumberGenerator, profile :FactionProfile  = null) -> Dictionary:
    var style := compute_reward_style(econ, tier)
    var base_gold := int(round(25.0 * pow(1.35, float(tier - 1))))

    var bundle := {
        "gold": 0,
        "influence": 0,
        "access": [],
        "treaty_clauses": [],
        "favor_debt": 0,
        "artifact_id": "",
        "intel_tags": [],
        "opportunism_heat": float(style.opportunism_heat)
    }

    if rng.randf() < float(style.w_gold):
        var wealth: StringName = StringName(econ.get("wealth_level", &"MODEST"))
        var mult := 1.0 + (0.30 if (wealth == &"RICH" or wealth == &"OPULENT") else 0.0)

        # ✅ variance bornée par personnalité
        var amp := _gold_variance_amp(profile) # 0.04 .. 0.22
        var noise := rng.randf_range(1.0 - amp, 1.0 + amp)
        bundle.gold = int(round(float(base_gold) * mult * noise))

        # debug optionnel
        bundle["gold_var_amp"] = amp
        return bundle

    # non-gold
    var points := base_gold
    bundle.influence = int(round(points * 0.35))

    if rng.randf() < 0.55:
        bundle.access.append("ACCESS_" + String(action_type).to_upper())
    if rng.randf() < 0.40:
        bundle.treaty_clauses.append("OPEN_TRADE")
    if rng.randf() < 0.30:
        bundle.favor_debt = 1
    if rng.randf() < 0.20:
        bundle.intel_tags.append("RUMOR_LEAD")

    var prestige: float = float(econ.get("prestige", 0.5))
    if rng.randf() < 0.03 and prestige > 0.6:
        bundle.artifact_id = "artifact_roll_me"

    return bundle


static func is_non_gold(bundle: Dictionary) -> bool:
    if int(bundle.get("gold", 0)) > 0:
        return false
    return (
        int(bundle.get("influence", 0)) > 0
        or int(bundle.get("favor_debt", 0)) > 0
        or String(bundle.get("artifact_id", "")) != ""
        or (bundle.get("access", []) as Array).size() > 0
        or (bundle.get("treaty_clauses", []) as Array).size() > 0
        or (bundle.get("intel_tags", []) as Array).size() > 0
    )

# -----------------------
# ✅ Variance par personnalité
# -----------------------
static func _gold_variance_amp(profile :FactionProfile) -> float:
    if profile == null:
        return 0.108
    # mapping: greedy/chaotic => opp/aggr ↑ ; bureaucratic => discipline/honor ↑
    # profile attendu: FactionProfile ou Dictionary {"personality":{...}} ou dict direct
    var agr :float = profile.get_personality(FactionProfile.PERS_AGGRESSION)
    var opp :float = profile.get_personality(FactionProfile.PERS_OPPORTUNISM)
    var dis :float = profile.get_personality(FactionProfile.PERS_DISCIPLINE)
    var hon :float = profile.get_personality(FactionProfile.PERS_HONOR)

    # volatility 0..1 (bornée)
    var vol := 0.20 + 0.45*opp + 0.25*agr - 0.55*dis - 0.20*hon
    vol = clampf(vol, 0.0, 1.0)

    # amplitude finale bornée => garde l'inflation contrôlée + tests verts
    return lerp(0.04, 0.22, vol)
