"""
3) Comment l’utiliser dans ton ArcManager.tick_day()

Schéma typique (direction A→B) :

var p := ArcDecisionUtil.compute_arc_event_chance(rel_ab, profile_a, profile_b, day, {
	"max_p": 0.35
})
if rng.randf() < p:
    var action := ArcDecisionUtil.select_arc_action_type(rel_ab, profile_a, profile_b, rng, day, {
        "external_threat": world_external_threat, # 0..1
        "opportunity": opportunity_ab,            # 0..1 (optionnel)
        "temperature": 0.18
    })
    # spawn offer selon action
    # rel_ab.set_cooldown(day, cooldown_days_for(action))
"""
class_name ArcDecisionUtil
extends RefCounted

# --- Action types (StringName) ---
const ARC_IGNORE: StringName = &"arc.ignore"
const ARC_ULTIMATUM: StringName = &"arc.ultimatum"
const ARC_REPARATIONS: StringName = &"arc.reparations"
const ARC_RAID: StringName = &"arc.raid"
const ARC_SABOTAGE: StringName = &"arc.sabotage"
const ARC_TRUCE_TALKS: StringName = &"arc.truce_talks"
const ARC_DECLARE_WAR: StringName = &"arc.declare_war"
const ARC_ALLIANCE_OFFER: StringName = &"arc.alliance_offer"
const ARC_JOINT_OPERATION: StringName = &"arc.joint_operation"

static func compute_arc_event_chance(
    rel: FactionRelationScore,     # A -> B
    a_profile: FactionProfile,     # personnalité du "décideur" A
    b_profile: FactionProfile,     # pas forcément utile tout de suite, mais futur-proof
    current_day: int,
    params: Dictionary = {}
) -> float:
    # Cooldown => pas d’event
    if rel.is_on_cooldown(current_day):
        return 0.0

    var base: float = float(params.get("base", 0.015))             # 1.5% mini
    var max_p: float = float(params.get("max_p", 0.35))            # cap dur (tick journalier)
    var tension_w: float = float(params.get("tension_w", 0.22))
    var friction_w: float = float(params.get("friction_w", 0.14))
    var grievance_w: float = float(params.get("grievance_w", 0.10))
    var negrel_w: float = float(params.get("negrel_w", 0.20))
    var weariness_w: float = float(params.get("weariness_w", 0.18))

    # personnalité (A filtre l’impulsivité)
    var aggr := a_profile.get_personality(FactionProfile.PERS_AGGRESSION)
    var veng := a_profile.get_personality(FactionProfile.PERS_VENGEFULNESS)
    var diplo := a_profile.get_personality(FactionProfile.PERS_DIPLOMACY)
    var risk := a_profile.get_personality(FactionProfile.PERS_RISK_AVERSION)
    var expa := a_profile.get_personality(FactionProfile.PERS_EXPANSIONISM)

    var p := base

    var tension := rel.get_score(FactionRelationScore.REL_TENSION) / 100.0
    var friction := rel.get_score(FactionRelationScore.REL_FRICTION) / 100.0
    var grievance := rel.get_score(FactionRelationScore.REL_GRIEVANCE) / 100.0
    var weariness := rel.get_score(FactionRelationScore.REL_WEARINESS) / 100.0
    var relation := rel.get_score(FactionRelationScore.REL_RELATION)
    var negrel :float= max(0.0, -float(relation) / 100.0)
    var trust := rel.get_score(FactionRelationScore.REL_TRUST)

    p += tension * tension_w
    p += friction * friction_w
    p += grievance * grievance_w
    p += negrel * negrel_w
    p -= weariness * weariness_w

    # personnalité : agressif/vindicatif/expa => + ; diplomate/prudent => -
    p += (aggr - 0.5) * float(params.get("aggr_w", 0.10))
    p += (veng - 0.5) * float(params.get("veng_w", 0.07))
    p += (expa - 0.5) * float(params.get("expa_w", 0.05))
    p -= (diplo - 0.5) * float(params.get("diplo_w", 0.11))
    p -= (risk - 0.5) * float(params.get("risk_w", 0.05))

    # amortisseur : si relation et trust déjà bons, on coupe beaucoup
    var trust_pos :float= max(0.0, float(trust) / 100.0)
    var rel_pos :float= max(0.0, float(relation) / 100.0)
    var goodwill := 0.5 * trust_pos + 0.5 * rel_pos
    p *= (1.0 - goodwill * float(params.get("goodwill_damp", 0.55)))

    return clampf(p, 0.0, max_p)


static func select_arc_action_type(
    rel: FactionRelationScore,      # A -> B
    a_profile: FactionProfile,
    b_profile: FactionProfile,
    rng: RandomNumberGenerator,
    current_day: int,
    params: Dictionary = {}
) -> StringName:
    # Pré-conditions globales
    if rel.is_on_cooldown(current_day):
        return ARC_IGNORE

    # --- Inputs normalisés ---
    var tension := rel.get_score(FactionRelationScore.REL_TENSION) / 100.0
    var friction := rel.get_score(FactionRelationScore.REL_FRICTION) / 100.0
    var grievance := rel.get_score(FactionRelationScore.REL_GRIEVANCE) / 100.0
    var weariness := rel.get_score(FactionRelationScore.REL_WEARINESS) / 100.0
    var relation := rel.get_score(FactionRelationScore.REL_RELATION)
    var trust := rel.get_score(FactionRelationScore.REL_TRUST)
    var negrel :float = max(0.0, -float(relation) / 100.0)
    var posrel :float = max(0.0, float(relation) / 100.0)
    var trust_pos :float = max(0.0, float(trust) / 100.0)

    # personnalité A
    var aggr := a_profile.get_personality(FactionProfile.PERS_AGGRESSION)
    var veng := a_profile.get_personality(FactionProfile.PERS_VENGEFULNESS)
    var diplo := a_profile.get_personality(FactionProfile.PERS_DIPLOMACY)
    var risk := a_profile.get_personality(FactionProfile.PERS_RISK_AVERSION)
    var expa := a_profile.get_personality(FactionProfile.PERS_EXPANSIONISM)
    var integ := a_profile.get_personality(FactionProfile.PERS_INTEGRATIONISM)
    # (optionnel) si tu ajoutes plus tard pers.cunning : fallback 0.5
    var cunning := float(a_profile.personality.get(&"pers.cunning", 0.5))

    # contexte monde (optionnel)
    var external_threat := float(params.get("external_threat", 0.0)) # 0..1 (crise, ennemi commun)
    var opportunity := float(params.get("opportunity", 0.55))        # 0..1 (si tu n’as rien, laisse ~0.55)

    # température softmax (plus bas => choix plus déterministe)
    var temperature := float(params.get("temperature", 0.18))

    # --- Scores (0..+) ---
    var candidates: Array = []

    # IGNORE : essentiel en journalier
    var s_ignore := 0.0
    s_ignore += 0.90 * weariness
    s_ignore += 0.35 * risk
    s_ignore += 0.25 * diplo
    s_ignore -= 0.60 * grievance
    s_ignore -= 0.40 * tension
    candidates.append({"type": ARC_IGNORE, "s": max(0.0, s_ignore)})

    # ULTIMATUM : pression sans escalade
    var s_ult := 0.0
    s_ult += 0.85 * grievance
    s_ult += 0.45 * tension
    s_ult += 0.25 * risk
    s_ult += 0.20 * diplo
    s_ult += 0.25 * negrel
    s_ult -= 0.35 * weariness
    candidates.append({"type": ARC_ULTIMATUM, "s": max(0.0, s_ult)})

    # REPARATIONS : possible si la relation n’est pas trop noire et que A est diplomate/intégrateur
    # REPARATIONS : porte de sortie “soft” (ne doit pas être trop rare)
    var s_rep := 0.0
    s_rep += 0.70 * diplo
    s_rep += 0.45 * integ
    s_rep += 0.30 * weariness
    s_rep += 0.25 * tension
    s_rep += 0.20 * trust_pos
    s_rep -= 0.25 * negrel
    s_rep -= 0.20 * grievance
    if relation > -75:
        candidates.append({"type": ARC_REPARATIONS, "s": max(0.0, s_rep)})

    # TRUCE_TALKS : fatigue haute + tension haute => sortie
    # TRUCE_TALKS : dé-escalade (ne doit pas être “inaccessible” quand grievance est haut)
    var s_truce := 0.0
    s_truce += 1.10 * weariness
    s_truce += 0.60 * tension
    s_truce += 0.70 * diplo
    s_truce += 0.35 * risk
    s_truce += 0.45 * external_threat
    s_truce -= 0.25 * grievance
    s_truce -= 0.35 * aggr
    candidates.append({"type": ARC_TRUCE_TALKS, "s": max(0.0, s_truce)})

    # RAID : représaille “courte”, satisfait la grievance mais baisse trust ensuite (effets ailleurs)
    # RAID : action très escalatoire → doit être rare et conditionnelle
    var s_raid := 0.0
    s_raid += 1.60 * grievance * tension
    s_raid += 0.60 * negrel * tension
    s_raid += 0.35 * opportunity
    s_raid += 0.30 * aggr
    s_raid += 0.20 * veng
    s_raid += 0.10 * expa
    s_raid -= 1.10 * weariness
    s_raid -= 0.55 * risk
    s_raid -= 0.35 * diplo
    if tension >= 0.35 and grievance >= 0.25:
        candidates.append({"type": ARC_RAID, "s": max(0.0, s_raid)})

    # SABOTAGE : utile quand risk est haut (éviter frontal) + cunning
    # SABOTAGE : rare, et plutôt à tension/grievance élevées
    var s_sab := 0.0
    s_sab += 1.25 * grievance * tension
    s_sab += 0.55 * cunning
    s_sab += 0.35 * risk
    s_sab += 0.20 * opportunity
    s_sab += 0.20 * negrel
    s_sab -= 0.70 * weariness
    s_sab -= 0.25 * diplo
    if tension >= 0.45 and grievance >= 0.30:
        candidates.append({"type": ARC_SABOTAGE, "s": max(0.0, s_sab)})

    # DECLARE_WAR : rare, conditions dures
    var s_war := 0.0
    s_war += 1.10 * tension
    s_war += 0.85 * grievance
    s_war += 0.80 * negrel
    s_war += 0.55 * opportunity
    s_war += 0.35 * expa
    s_war += 0.30 * aggr
    s_war -= 1.00 * weariness
    s_war -= 0.25 * external_threat # si menace externe, moins envie de guerre interne
    if relation <= -55 and tension >= 65.0 and weariness <= 55.0:
        candidates.append({"type": ARC_DECLARE_WAR, "s": max(0.0, s_war)})

    # ALLIANCE_OFFER : si menace externe + relation pas trop négative
    var s_alliance := 0.0
    s_alliance += 0.95 * external_threat
    s_alliance += 0.55 * diplo
    s_alliance += 0.45 * integ
    s_alliance += 0.25 * trust_pos
    s_alliance += 0.15 * posrel
    s_alliance -= 0.55 * negrel
    s_alliance -= 0.25 * grievance
    if external_threat >= 0.35 and relation > -35:
        candidates.append({"type": ARC_ALLIANCE_OFFER, "s": max(0.0, s_alliance)})

    # --- Weighted random via softmax-like ---
    return _pick_by_softmax(rng, candidates, temperature)


static func _pick_by_softmax(rng: RandomNumberGenerator, candidates: Array, temperature: float) -> StringName:
    temperature = max(0.05, temperature)

    var weights: Array[float] = []
    var sum_w := 0.0

    for c in candidates:
        var s := float(c["s"])
        # exp(s / temp) mais clamp pour éviter overflow
        var w := exp(clampf(s / temperature, -20.0, 20.0))
        weights.append(w)
        sum_w += w

    if sum_w <= 0.0:
        return ARC_IGNORE

    var r := rng.randf() * sum_w
    var acc := 0.0
    for i in range(candidates.size()):
        acc += weights[i]
        if r <= acc:
            return StringName(candidates[i]["type"])

    return StringName(candidates.back()["type"])
