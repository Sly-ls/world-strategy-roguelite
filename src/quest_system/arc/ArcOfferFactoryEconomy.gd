class_name ArcOfferFactoryEconomy
extends RefCounted

static func compute_difficulty(arc_state_name: StringName, rel_ab: FactionRelationScore, risk: float, tier: int) -> float:
    var state_factor := 0.15
    match arc_state_name:
        &"RIVALRY":  state_factor = 0.20
        &"CONFLICT": state_factor = 0.45
        &"WAR":      state_factor = 0.70
        &"TRUCE":    state_factor = 0.25
        &"ALLIANCE": state_factor = 0.20
    var t := rel_ab.get_score(FactionRelationScore.REL_TENSION) / 100.0
    var g := rel_ab.get_score(FactionRelationScore.REL_GRIEVANCE) / 100.0
    var tier_factor := clampf(0.15 * float(max(tier - 1, 0)), 0.0, 0.45)
    return clampf(0.35*risk + 0.30*t + 0.20*g + 0.15*state_factor + tier_factor, 0.0, 1.0)

static func compute_reward_gold(tier: int, difficulty: float, domain: String) -> int:
    var base := 40 + 35 * tier
    var dom_mul := 1.0
    if domain == "combat": dom_mul = 1.10
    elif domain == "diplo": dom_mul = 0.95
    var reward := float(base) * dom_mul * (1.0 + 1.35*difficulty)
    return int(round(reward))

static func compute_action_cost_points(action: StringName, arc_state_name: StringName, difficulty: float, tier: int, giver_profile: FactionProfile) -> float:
    var base := 11.0
    match action:
        ArcDecisionUtil.ARC_RAID:           base = 10.0
        ArcDecisionUtil.ARC_SABOTAGE:       base = 12.0
        ArcDecisionUtil.ARC_ULTIMATUM:      base = 9.0
        ArcDecisionUtil.ARC_TRUCE_TALKS:    base = 14.0
        ArcDecisionUtil.ARC_REPARATIONS:    base = 16.0
        ArcDecisionUtil.ARC_ALLIANCE_OFFER: base = 18.0
        ArcDecisionUtil.ARC_DECLARE_WAR:    base = 30.0

    var state_mul := 1.0
    match arc_state_name:
        &"WAR":      state_mul = 1.25
        &"CONFLICT": state_mul = 1.10
        &"ALLIANCE": state_mul = 1.10

    var diff_mul := 0.85 + 0.95 * clampf(difficulty, 0.0, 1.0)
    var tier_mul := 1.0 + 0.18 * float(max(tier - 1, 0))

    var expa := giver_profile.get_personality(FactionProfile.PERS_EXPANSIONISM)
    var diplo := giver_profile.get_personality(FactionProfile.PERS_DIPLOMACY)

    var pers_mul := 1.0
    if ArcStateMachine.is_hostile_action(action):
        pers_mul *= (1.10 - 0.30 * expa)
    if ArcStateMachine.is_peace_action(action):
        pers_mul *= (1.10 - 0.30 * diplo)

    return base * state_mul * diff_mul * tier_mul * pers_mul
