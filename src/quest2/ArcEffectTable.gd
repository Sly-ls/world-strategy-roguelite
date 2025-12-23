"""
Remarques rapides (importantes)
Les deltas “hostiles” (RAID/SABOTAGE/DECLARE_WAR) appliquent le principe “payer la dette” : grievance baisse côté acteur si succès, 
mais augmente côté victime → ça évite une boucle symétrique infinie et crée une dynamique crédible.
TRUCE_TALKS / REPARATIONS / ALLIANCE_OFFER sont bilatéraux : baisse tension + grief, remonte trust/relation.
Tu peux ensuite ajouter une couche “personnalité en multiplicateur” en entourant apply_delta() d’un scale = f(aggression, diplomacy, ...).
"""
class_name ArcEffectTable
extends RefCounted

# --- Choices (match your QuestManager) ---
const CHOICE_LOYAL: StringName = &"LOYAL"
const CHOICE_NEUTRAL: StringName = &"NEUTRAL"
const CHOICE_TRAITOR: StringName = &"TRAITOR"

# --- Action types (same as ArcDecisionUtil) ---
const ARC_IGNORE: StringName = &"arc.ignore"
const ARC_ULTIMATUM: StringName = &"arc.ultimatum"
const ARC_REPARATIONS: StringName = &"arc.reparations"
const ARC_RAID: StringName = &"arc.raid"
const ARC_SABOTAGE: StringName = &"arc.sabotage"
const ARC_TRUCE_TALKS: StringName = &"arc.truce_talks"
const ARC_DECLARE_WAR: StringName = &"arc.declare_war"
const ARC_ALLIANCE_OFFER: StringName = &"arc.alliance_offer"

# -----------------------------
# 1) Cooldowns (min..max days)
# -----------------------------
const COOLDOWNS: Dictionary = {
    ARC_IGNORE:        {"min": 1,  "max": 2},
    ARC_ULTIMATUM:     {"min": 2,  "max": 4},
    ARC_REPARATIONS:   {"min": 4,  "max": 6},
    ARC_TRUCE_TALKS:   {"min": 5,  "max": 7},
    ARC_RAID:          {"min": 3,  "max": 5},
    ARC_SABOTAGE:      {"min": 4,  "max": 6},
    ARC_DECLARE_WAR:   {"min": 7,  "max": 10},
    ARC_ALLIANCE_OFFER:{"min": 6,  "max": 9},
}

static func cooldown_days_for(action: StringName, rng: RandomNumberGenerator) -> int:
    var cd :Dictionary = COOLDOWNS.get(action, {"min": 3, "max": 5})
    return rng.randi_range(int(cd["min"]), int(cd["max"]))

# --------------------------------------------------------
# 2) Deltas standards par action + choix (A->B, B->A)
#    Keys: d_relation(int), d_trust(int), d_grievance(float), d_tension(float), d_weariness(float)
# --------------------------------------------------------
const EFFECTS: Dictionary = {
    ARC_IGNORE: {
        CHOICE_LOYAL: {
            "ab": {FactionRelationScore.REL_RELATION:  0,  FactionRelationScore.REL_TRUST:  0,  FactionRelationScore.REL_GRIEVANCE: -3.0, FactionRelationScore.REL_TENSION: -5.0, FactionRelationScore.REL_WEARINESS: -2.0},
            "ba": {FactionRelationScore.REL_RELATION:  0,  FactionRelationScore.REL_TRUST:  0,  FactionRelationScore.REL_GRIEVANCE: -2.0, FactionRelationScore.REL_TENSION: -4.0, FactionRelationScore.REL_WEARINESS: -2.0},
        },
        CHOICE_NEUTRAL: {
            "ab": {FactionRelationScore.REL_RELATION:  0,  FactionRelationScore.REL_TRUST:  0,  FactionRelationScore.REL_GRIEVANCE: -1.0, FactionRelationScore.REL_TENSION: -2.0, FactionRelationScore.REL_WEARINESS: -1.0},
            "ba": {FactionRelationScore.REL_RELATION:  0,  FactionRelationScore.REL_TRUST:  0,  FactionRelationScore.REL_GRIEVANCE: -1.0, FactionRelationScore.REL_TENSION: -2.0, FactionRelationScore.REL_WEARINESS: -1.0},
        },
        CHOICE_TRAITOR: {
            "ab": {FactionRelationScore.REL_RELATION: -2,  FactionRelationScore.REL_TRUST: -2,  FactionRelationScore.REL_GRIEVANCE: +2.0, FactionRelationScore.REL_TENSION: +2.0, FactionRelationScore.REL_WEARINESS:  0.0},
            "ba": {FactionRelationScore.REL_RELATION: -2,  FactionRelationScore.REL_TRUST: -2,  FactionRelationScore.REL_GRIEVANCE: +2.0, FactionRelationScore.REL_TENSION: +2.0, FactionRelationScore.REL_WEARINESS:  0.0},
        },
    },

    ARC_ULTIMATUM: {
        CHOICE_LOYAL: {
            # “A obtient des concessions” : A se sent payé (grievance -), B en garde une rancune (grievance +)
            "ab": {FactionRelationScore.REL_RELATION: -4,  FactionRelationScore.REL_TRUST: -2,  FactionRelationScore.REL_GRIEVANCE: -10.0, FactionRelationScore.REL_TENSION: +2.0, FactionRelationScore.REL_WEARINESS:  0.0},
            "ba": {FactionRelationScore.REL_RELATION: -6,  FactionRelationScore.REL_TRUST: -4,  FactionRelationScore.REL_GRIEVANCE:  +6.0, FactionRelationScore.REL_TENSION: +4.0, FactionRelationScore.REL_WEARINESS:  0.0},
        },
        CHOICE_NEUTRAL: {
            "ab": {FactionRelationScore.REL_RELATION: -2,  FactionRelationScore.REL_TRUST: -2,  FactionRelationScore.REL_GRIEVANCE:  -2.0, FactionRelationScore.REL_TENSION: +1.0, FactionRelationScore.REL_WEARINESS:  0.0},
            "ba": {FactionRelationScore.REL_RELATION: -2,  FactionRelationScore.REL_TRUST: -1,  FactionRelationScore.REL_GRIEVANCE:  +2.0, FactionRelationScore.REL_TENSION: +1.0, FactionRelationScore.REL_WEARINESS:  0.0},
        },
        CHOICE_TRAITOR: {
            # “A humilié / décrédibilisé” : A rancune monte, trust s’effondre
            "ab": {FactionRelationScore.REL_RELATION: -6,  FactionRelationScore.REL_TRUST: -6,  FactionRelationScore.REL_GRIEVANCE:  +6.0, FactionRelationScore.REL_TENSION: +4.0, FactionRelationScore.REL_WEARINESS:  0.0},
            "ba": {FactionRelationScore.REL_RELATION: -3,  FactionRelationScore.REL_TRUST: -1,  FactionRelationScore.REL_GRIEVANCE:   0.0, FactionRelationScore.REL_TENSION: +2.0, FactionRelationScore.REL_WEARINESS:  0.0},
        },
    },

    ARC_REPARATIONS: {
        CHOICE_LOYAL: {
            # Réparations acceptées : forte détente bilatérale
            "ab": {FactionRelationScore.REL_RELATION: +12, FactionRelationScore.REL_TRUST: +10, FactionRelationScore.REL_GRIEVANCE:  -8.0, FactionRelationScore.REL_TENSION: -10.0, FactionRelationScore.REL_WEARINESS: -2.0},
            "ba": {FactionRelationScore.REL_RELATION: +16, FactionRelationScore.REL_TRUST: +12, FactionRelationScore.REL_GRIEVANCE: -18.0, FactionRelationScore.REL_TENSION: -12.0, FactionRelationScore.REL_WEARINESS: -2.0},
        },
        CHOICE_NEUTRAL: {
            "ab": {FactionRelationScore.REL_RELATION:  +6, FactionRelationScore.REL_TRUST:  +5, FactionRelationScore.REL_GRIEVANCE:  -4.0, FactionRelationScore.REL_TENSION:  -6.0, FactionRelationScore.REL_WEARINESS: -1.0},
            "ba": {FactionRelationScore.REL_RELATION:  +8, FactionRelationScore.REL_TRUST:  +6, FactionRelationScore.REL_GRIEVANCE:  -9.0, FactionRelationScore.REL_TENSION:  -7.0, FactionRelationScore.REL_WEARINESS: -1.0},
        },
        CHOICE_TRAITOR: {
            # Réparations sabotées / fraude : backlash
            "ab": {FactionRelationScore.REL_RELATION:  -8, FactionRelationScore.REL_TRUST: -10, FactionRelationScore.REL_GRIEVANCE:  +6.0, FactionRelationScore.REL_TENSION:  +8.0, FactionRelationScore.REL_WEARINESS: +2.0},
            "ba": {FactionRelationScore.REL_RELATION: -10, FactionRelationScore.REL_TRUST: -12, FactionRelationScore.REL_GRIEVANCE: +10.0, FactionRelationScore.REL_TENSION: +10.0, FactionRelationScore.REL_WEARINESS: +2.0},
        },
    },

    ARC_TRUCE_TALKS: {
        CHOICE_LOYAL: {
            "ab": {FactionRelationScore.REL_RELATION:  +8, FactionRelationScore.REL_TRUST: +12, FactionRelationScore.REL_GRIEVANCE: -12.0, FactionRelationScore.REL_TENSION: -18.0, FactionRelationScore.REL_WEARINESS: -4.0},
            "ba": {FactionRelationScore.REL_RELATION:  +8, FactionRelationScore.REL_TRUST: +12, FactionRelationScore.REL_GRIEVANCE: -12.0, FactionRelationScore.REL_TENSION: -18.0, FactionRelationScore.REL_WEARINESS: -4.0},
        },
        CHOICE_NEUTRAL: {
            "ab": {FactionRelationScore.REL_RELATION:  +3, FactionRelationScore.REL_TRUST:  +5, FactionRelationScore.REL_GRIEVANCE:  -5.0, FactionRelationScore.REL_TENSION: -10.0, FactionRelationScore.REL_WEARINESS: -2.0},
            "ba": {FactionRelationScore.REL_RELATION:  +3, FactionRelationScore.REL_TRUST:  +5, FactionRelationScore.REL_GRIEVANCE:  -5.0, FactionRelationScore.REL_TENSION: -10.0, FactionRelationScore.REL_WEARINESS: -2.0},
        },
        CHOICE_TRAITOR: {
            "ab": {FactionRelationScore.REL_RELATION: -10, FactionRelationScore.REL_TRUST: -14, FactionRelationScore.REL_GRIEVANCE:  +8.0, FactionRelationScore.REL_TENSION: +12.0, FactionRelationScore.REL_WEARINESS: +2.0},
            "ba": {FactionRelationScore.REL_RELATION: -10, FactionRelationScore.REL_TRUST: -14, FactionRelationScore.REL_GRIEVANCE:  +8.0, FactionRelationScore.REL_TENSION: +12.0, FactionRelationScore.REL_WEARINESS: +2.0},
        },
    },

    ARC_RAID: {
        CHOICE_LOYAL: {
            # “paiement” : A grievance baisse, B grievance monte
            "ab": {FactionRelationScore.REL_RELATION: -10, FactionRelationScore.REL_TRUST:  -8, FactionRelationScore.REL_GRIEVANCE: -15.0, FactionRelationScore.REL_TENSION: +12.0, FactionRelationScore.REL_WEARINESS: +6.0},
            "ba": {FactionRelationScore.REL_RELATION: -16, FactionRelationScore.REL_TRUST: -12, FactionRelationScore.REL_GRIEVANCE: +18.0, FactionRelationScore.REL_TENSION: +14.0, FactionRelationScore.REL_WEARINESS: +4.0},
        },
        CHOICE_NEUTRAL: {
            "ab": {FactionRelationScore.REL_RELATION:  -5, FactionRelationScore.REL_TRUST:  -4, FactionRelationScore.REL_GRIEVANCE:  -8.0, FactionRelationScore.REL_TENSION:  +7.0, FactionRelationScore.REL_WEARINESS: +3.0},
            "ba": {FactionRelationScore.REL_RELATION:  -8, FactionRelationScore.REL_TRUST:  -6, FactionRelationScore.REL_GRIEVANCE: +10.0, FactionRelationScore.REL_TENSION:  +8.0, FactionRelationScore.REL_WEARINESS: +2.0},
        },
        CHOICE_TRAITOR: {
            # Raid retourné / saboté : A se radicalise, B “satisfait” un peu
            "ab": {FactionRelationScore.REL_RELATION: -12, FactionRelationScore.REL_TRUST: -10, FactionRelationScore.REL_GRIEVANCE: +12.0, FactionRelationScore.REL_TENSION: +12.0, FactionRelationScore.REL_WEARINESS: +7.0},
            "ba": {FactionRelationScore.REL_RELATION:  -8, FactionRelationScore.REL_TRUST:  -6, FactionRelationScore.REL_GRIEVANCE:  -8.0, FactionRelationScore.REL_TENSION: +10.0, FactionRelationScore.REL_WEARINESS: +3.0},
        },
    },

    ARC_SABOTAGE: {
        CHOICE_LOYAL: {
            "ab": {FactionRelationScore.REL_RELATION:  -6, FactionRelationScore.REL_TRUST:  -6, FactionRelationScore.REL_GRIEVANCE:  -8.0, FactionRelationScore.REL_TENSION:  +8.0, FactionRelationScore.REL_WEARINESS: +2.0},
            "ba": {FactionRelationScore.REL_RELATION: -10, FactionRelationScore.REL_TRUST:  -8, FactionRelationScore.REL_GRIEVANCE: +10.0, FactionRelationScore.REL_TENSION: +10.0, FactionRelationScore.REL_WEARINESS: +3.0},
        },
        CHOICE_NEUTRAL: {
            "ab": {FactionRelationScore.REL_RELATION:  -3, FactionRelationScore.REL_TRUST:  -3, FactionRelationScore.REL_GRIEVANCE:  -4.0, FactionRelationScore.REL_TENSION:  +5.0, FactionRelationScore.REL_WEARINESS: +1.0},
            "ba": {FactionRelationScore.REL_RELATION:  -5, FactionRelationScore.REL_TRUST:  -4, FactionRelationScore.REL_GRIEVANCE:  +6.0, FactionRelationScore.REL_TENSION:  +6.0, FactionRelationScore.REL_WEARINESS: +1.0},
        },
        CHOICE_TRAITOR: {
            # double-jeu : A se braque, B est “un peu payé”
            "ab": {FactionRelationScore.REL_RELATION:  -8, FactionRelationScore.REL_TRUST: -10, FactionRelationScore.REL_GRIEVANCE:  +6.0, FactionRelationScore.REL_TENSION:  +8.0, FactionRelationScore.REL_WEARINESS: +3.0},
            "ba": {FactionRelationScore.REL_RELATION:  -6, FactionRelationScore.REL_TRUST:  -4, FactionRelationScore.REL_GRIEVANCE:  -4.0, FactionRelationScore.REL_TENSION:  +6.0, FactionRelationScore.REL_WEARINESS: +2.0},
        },
    },

    ARC_DECLARE_WAR: {
        CHOICE_LOYAL: {
            "ab": {FactionRelationScore.REL_RELATION: -35, FactionRelationScore.REL_TRUST: -30, FactionRelationScore.REL_GRIEVANCE: -20.0, FactionRelationScore.REL_TENSION: +30.0, FactionRelationScore.REL_WEARINESS: +8.0},
            "ba": {FactionRelationScore.REL_RELATION: -35, FactionRelationScore.REL_TRUST: -30, FactionRelationScore.REL_GRIEVANCE: +25.0, FactionRelationScore.REL_TENSION: +35.0, FactionRelationScore.REL_WEARINESS: +10.0},
        },
        CHOICE_NEUTRAL: {
            "ab": {FactionRelationScore.REL_RELATION: -15, FactionRelationScore.REL_TRUST: -12, FactionRelationScore.REL_GRIEVANCE:  -8.0, FactionRelationScore.REL_TENSION: +18.0, FactionRelationScore.REL_WEARINESS:  +4.0},
            "ba": {FactionRelationScore.REL_RELATION: -18, FactionRelationScore.REL_TRUST: -15, FactionRelationScore.REL_GRIEVANCE: +12.0, FactionRelationScore.REL_TENSION: +20.0, FactionRelationScore.REL_WEARINESS:  +6.0},
        },
        CHOICE_TRAITOR: {
            # guerre avortée / retournement politique : A humilié mais pas de guerre totale
            "ab": {FactionRelationScore.REL_RELATION: -20, FactionRelationScore.REL_TRUST: -10, FactionRelationScore.REL_GRIEVANCE: +10.0, FactionRelationScore.REL_TENSION: +10.0, FactionRelationScore.REL_WEARINESS: +3.0},
            "ba": {FactionRelationScore.REL_RELATION: -10, FactionRelationScore.REL_TRUST:  -5, FactionRelationScore.REL_GRIEVANCE:  -5.0, FactionRelationScore.REL_TENSION:  +5.0, FactionRelationScore.REL_WEARINESS: +2.0},
        },
    },

    ARC_ALLIANCE_OFFER: {
        CHOICE_LOYAL: {
            "ab": {FactionRelationScore.REL_RELATION: +20, FactionRelationScore.REL_TRUST: +22, FactionRelationScore.REL_GRIEVANCE: -10.0, FactionRelationScore.REL_TENSION: -15.0, FactionRelationScore.REL_WEARINESS: -3.0},
            "ba": {FactionRelationScore.REL_RELATION: +20, FactionRelationScore.REL_TRUST: +22, FactionRelationScore.REL_GRIEVANCE: -10.0, FactionRelationScore.REL_TENSION: -15.0, FactionRelationScore.REL_WEARINESS: -3.0},
        },
        CHOICE_NEUTRAL: {
            "ab": {FactionRelationScore.REL_RELATION: +10, FactionRelationScore.REL_TRUST: +12, FactionRelationScore.REL_GRIEVANCE:  -5.0, FactionRelationScore.REL_TENSION:  -8.0, FactionRelationScore.REL_WEARINESS: -2.0},
            "ba": {FactionRelationScore.REL_RELATION: +10, FactionRelationScore.REL_TRUST: +12, FactionRelationScore.REL_GRIEVANCE:  -5.0, FactionRelationScore.REL_TENSION:  -8.0, FactionRelationScore.REL_WEARINESS: -2.0},
        },
        CHOICE_TRAITOR: {
            "ab": {FactionRelationScore.REL_RELATION: -12, FactionRelationScore.REL_TRUST: -16, FactionRelationScore.REL_GRIEVANCE:  +8.0, FactionRelationScore.REL_TENSION: +10.0, FactionRelationScore.REL_WEARINESS: +2.0},
            "ba": {FactionRelationScore.REL_RELATION: -12, FactionRelationScore.REL_TRUST: -16, FactionRelationScore.REL_GRIEVANCE:  +8.0, FactionRelationScore.REL_TENSION: +10.0, FactionRelationScore.REL_WEARINESS: +2.0},
        },
    },
}
# --------------------------------------------------------
# 3) Policy Strategy
#
# Parfait. On va faire une table de “policy” par arc_action_type qui définit :
#
# cap_weight : modifie le cap% (10%..30%) pour RELATION
# trust_cap_weight : idem pour TRUST
# cooldown_mult : multiplie le cooldown de base
# (optionnel) delta_mult_* : si tu veux “durcir” tension/grievance sans toucher relation
# Ensuite, à chaque événement résolu, on :
# 1) calcule cap_pct (10%..30%) via l’historique A & B,
# 2) applique cap_weight/trust_cap_weight,
# 3) clamp d_relation (et d_trust),
# 4) applique les deltas,
# 5) pose cooldown,
# 6) enregistre dans ArcNotebook (counts + last_day + record détaillé)
#
# --------------------------------------------------------

const ARC_TYPE_POLICY: Dictionary = {
    ARC_IGNORE: {
        "cap_weight": 1.00,
        "trust_cap_weight": 1.00,
        "cooldown_mult": 1.00,
    },
    ARC_ULTIMATUM: {
        "cap_weight": 0.90,
        "trust_cap_weight": 0.85,
        "cooldown_mult": 1.05,
    },
    ARC_REPARATIONS: {
        # Peut réellement changer une relation… mais pas instantanément
        "cap_weight": 1.15,
        "trust_cap_weight": 1.20,
        "cooldown_mult": 1.10,
    },
    ARC_TRUCE_TALKS: {
        # Trêve = gros levier sur tension + trust
        "cap_weight": 1.10,
        "trust_cap_weight": 1.25,
        "cooldown_mult": 1.20,
    },
    ARC_RAID: {
        # Hostile : impact relation limité, mais tension/grievance montent via deltas
        "cap_weight": 0.85,
        "trust_cap_weight": 0.80,
        "cooldown_mult": 1.10,
    },
    ARC_SABOTAGE: {
        "cap_weight": 0.80,
        "trust_cap_weight": 0.75,
        "cooldown_mult": 1.15,
    },
    ARC_DECLARE_WAR: {
        # Déclaration de guerre = surtout un changement d'état + tension/weariness,
        # la relation ne doit pas faire un -60 d’un coup.
        "cap_weight": 0.60,
        "trust_cap_weight": 0.60,
        "cooldown_mult": 1.35,
    },
    ARC_ALLIANCE_OFFER: {
        # Alliance: confiance monte, relation suit mais reste capée
        "cap_weight": 0.95,
        "trust_cap_weight": 1.15,
        "cooldown_mult": 1.25,
    },
}

static func get_arc_deltas(action: StringName, choice: StringName) -> Dictionary:
    var by_action :Dictionary = EFFECTS.get(action, null)
    if by_action == null:
        return {}
    var by_choice :Dictionary = by_action.get(choice, null)
    if by_choice == null:
        return {}
    return by_choice

# --------------------------------------------------------
# 3) Apply helper (also sets cooldown for both links)
# --------------------------------------------------------
static func apply_arc_resolution_event(
    action: StringName,
    choice: StringName,
    giver_id: StringName,
    ant_id: StringName,
    rel_ab: FactionRelationScore,
    rel_ba: FactionRelationScore,
    profile_a: FactionProfile,
    profile_b: FactionProfile,
    arc_notebook: ArcNotebook,
    current_day: int,
    rng: RandomNumberGenerator,
    params: Dictionary = {}
) -> void:
    var d := get_arc_deltas(action, choice)
    if d.is_empty():
        return

    # 1) scaling personnalité (déjà écrit chez toi)
    var ab_scaled := _scale_deltas_by_personality(d["ab"], profile_a, params)
    var ba_scaled := _scale_deltas_by_personality(d["ba"], profile_b, params)

    # 2) cap% issu de l’historique (10%..30%) + policy de type
    var pol := _policy(action)

    var hist_a := arc_notebook.get_history(giver_id)
    var hist_b := arc_notebook.get_history(ant_id)

    var base_cap_pct := compute_relation_cap_pct_from_histories(
        hist_a, hist_b, giver_id, ant_id, action, current_day, params
    )

    # applique les weights du type (puis re-clamp dans [0.10..0.30] à la fin)
    var pct_min := float(params.get("pct_min", 0.10))
    var pct_max := float(params.get("pct_max", 0.30))

    var cap_pct_rel := clampf(base_cap_pct * float(pol["cap_weight"]), pct_min, pct_max)
    var cap_pct_trust := clampf(base_cap_pct * float(pol["trust_cap_weight"]), pct_min, pct_max)

    # 3) cap absolu (min 10 points, sinon % du score actuel)
    var min_abs := int(params.get("min_abs_cap", 10))

    var cap_ab_rel :int = max(min_abs, int(round(abs(rel_ab.relation) * cap_pct_rel)))
    var cap_ba_rel :int = max(min_abs, int(round(abs(rel_ba.relation) * cap_pct_rel)))

    ab_scaled[FactionRelationScore.REL_RELATION] = clampi(int(ab_scaled[FactionRelationScore.REL_RELATION]), -cap_ab_rel, cap_ab_rel)
    ba_scaled[FactionRelationScore.REL_RELATION] = clampi(int(ba_scaled[FactionRelationScore.REL_RELATION]), -cap_ba_rel, cap_ba_rel)

    # Trust cap (souvent utile)
    if bool(params.get("cap_trust_too", true)):
        var cap_ab_tr :int = max(min_abs, int(round(abs(rel_ab.trust) * cap_pct_trust)))
        var cap_ba_tr :int = max(min_abs, int(round(abs(rel_ba.trust) * cap_pct_trust)))
        ab_scaled[FactionRelationScore.REL_TRUST] = clampi(int(ab_scaled[FactionRelationScore.REL_TRUST]), -cap_ab_tr, cap_ab_tr)
        ba_scaled[FactionRelationScore.REL_TRUST] = clampi(int(ba_scaled[FactionRelationScore.REL_TRUST]), -cap_ba_tr, cap_ba_tr)

    # 4) apply deltas
    rel_ab.apply_delta({
    FactionRelationScore.REL_RELATION: float(ab_scaled[FactionRelationScore.REL_RELATION]), 
    FactionRelationScore.REL_TRUST : int(ab_scaled[FactionRelationScore.REL_TRUST]),
    FactionRelationScore.REL_GRIEVANCE : float(ab_scaled[FactionRelationScore.REL_GRIEVANCE]), 
    FactionRelationScore.REL_TENSION : float(ab_scaled[FactionRelationScore.REL_TENSION]), 
    FactionRelationScore.REL_WEARINESS : float(ab_scaled[FactionRelationScore.REL_WEARINESS])
    })
    rel_ba.apply_delta({
    FactionRelationScore.REL_RELATION: int(ba_scaled[FactionRelationScore.REL_RELATION]), 
    FactionRelationScore.REL_TRUST: int(ba_scaled[FactionRelationScore.REL_TRUST]),
    FactionRelationScore.REL_GRIEVANCE: float(ba_scaled[FactionRelationScore.REL_GRIEVANCE]), 
    FactionRelationScore.REL_TENSION: float(ba_scaled[FactionRelationScore.REL_TENSION]), 
    FactionRelationScore.REL_WEARINESS: float(ba_scaled[FactionRelationScore.REL_WEARINESS])
    })

    # 5) cooldown (base * multiplier)
    var cd_base := cooldown_days_for(action, rng)
    var cd := int(round(float(cd_base) * float(pol["cooldown_mult"])))
    cd = max(1, cd)

    rel_ab.set_cooldown(current_day, cd)
    rel_ba.set_cooldown(current_day, cd)

    # 6) register in notebook (metadata + (optionnel) record détaillé)
    hist_a.register_event(ant_id, action, current_day)
    hist_b.register_event(giver_id, action, current_day)

    # Si tu veux aussi enregistrer la résolution dans l’historique détaillé :
    if hist_a.has_method("add_rivalry_record"):
        hist_a.add_rivalry_record({"other": ant_id, "type": action, "choice": choice, "day": current_day})
    if hist_b.has_method("add_rivalry_record"):
        hist_b.add_rivalry_record({"other": giver_id, "type": action, "choice": choice, "day": current_day})
 
static func _scale_deltas_by_personality(delta: Dictionary, prof: FactionProfile, params: Dictionary) -> Dictionary:
    # Params to tune aggressiveness of scaling
    var k_pos_rel := float(params.get("k_pos_rel", 0.35))      # relation/trust gains
    var k_neg_rel := float(params.get("k_neg_rel", 0.20))      # relation/trust losses
    var k_griev_down := float(params.get("k_griev_down", 0.55))# grievance reduction sensitivity
    var k_griev_up := float(params.get("k_griev_up", 0.25))    # grievance increase sensitivity
    var k_tension_down := float(params.get("k_tension_down", 0.35))
    var k_tension_up := float(params.get("k_tension_up", 0.25))
    var k_wear_gain := float(params.get("k_wear_gain", 0.45))

    var diplo := prof.get_personality(FactionProfile.PERS_DIPLOMACY)
    var integ := prof.get_personality(FactionProfile.PERS_INTEGRATIONISM)
    var aggr := prof.get_personality(FactionProfile.PERS_AGGRESSION)
    var veng := prof.get_personality(FactionProfile.PERS_VENGEFULNESS)
    var risk := prof.get_personality(FactionProfile.PERS_RISK_AVERSION)
    var expa := prof.get_personality(FactionProfile.PERS_EXPANSIONISM)

    var out := {
        FactionRelationScore.REL_RELATION: int(delta.get(FactionRelationScore.REL_RELATION, 0)),
        FactionRelationScore.REL_TRUST: int(delta.get(FactionRelationScore.REL_TRUST, 0)),
        FactionRelationScore.REL_GRIEVANCE: float(delta.get(FactionRelationScore.REL_GRIEVANCE, 0.0)),
        FactionRelationScore.REL_TENSION: float(delta.get(FactionRelationScore.REL_TENSION, 0.0)),
        FactionRelationScore.REL_WEARINESS: float(delta.get(FactionRelationScore.REL_WEARINESS, 0.0)),
    }

    # --- relation/trust ---
    # Gains: diplomacy + integration amplify
    var gain_mul := 1.0 + k_pos_rel * ((diplo - 0.5) + 0.8*(integ - 0.5))
    # Losses: aggression + vengefulness amplify (more punitive worldview)
    var loss_mul := 1.0 + k_neg_rel * ((aggr - 0.5) + 0.8*(veng - 0.5))

    out[FactionRelationScore.REL_RELATION] = int(round(_scale_signed_int(out[FactionRelationScore.REL_RELATION], gain_mul, loss_mul)))
    out[FactionRelationScore.REL_TRUST] = int(round(_scale_signed_int(out[FactionRelationScore.REL_TRUST], gain_mul, loss_mul)))

    # --- grievance ---
    # If delta is negative (grievance reduction), vengefulness makes it less effective.
    # If delta is positive, vengefulness makes it sting more.
    var g := float(out[FactionRelationScore.REL_GRIEVANCE])
    if g < 0.0:
        var g_mul_down := 1.0 - k_griev_down * (veng - 0.5)  # veng>0.5 => smaller reduction
        g_mul_down = clampf(g_mul_down, 0.55, 1.35)
        out[FactionRelationScore.REL_GRIEVANCE] = g * g_mul_down
    elif g > 0.0:
        var g_mul_up := 1.0 + k_griev_up * ((veng - 0.5) + 0.5*(aggr - 0.5))
        g_mul_up = clampf(g_mul_up, 0.70, 1.45)
        out[FactionRelationScore.REL_GRIEVANCE] = g * g_mul_up

    # --- tension ---
    var t := float(out[FactionRelationScore.REL_TENSION])
    if t < 0.0:
        var t_mul_down := 1.0 + k_tension_down * (diplo - 0.5)
        t_mul_down = clampf(t_mul_down, 0.75, 1.40)
        out[FactionRelationScore.REL_TENSION] = t * t_mul_down
    elif t > 0.0:
        var t_mul_up := 1.0 + k_tension_up * ((aggr - 0.5) + 0.6*(veng - 0.5))
        t_mul_up = clampf(t_mul_up, 0.75, 1.45)
        out[FactionRelationScore.REL_TENSION] = t * t_mul_up

    # --- weariness ---
    var w := float(out[FactionRelationScore.REL_WEARINESS])
    if w > 0.0:
        # expansionism reduces perceived weariness; risk_aversion increases it
        var w_mul := 1.0 \
            + k_wear_gain * (risk - 0.5) \
            - 0.35 * (expa - 0.5)
        w_mul = clampf(w_mul, 0.65, 1.55)
        out[FactionRelationScore.REL_WEARINESS] = w * w_mul

    # clamp small floats to avoid noise
    out[FactionRelationScore.REL_GRIEVANCE] = _snap_small(out[FactionRelationScore.REL_GRIEVANCE])
    out[FactionRelationScore.REL_TENSION] = _snap_small(out[FactionRelationScore.REL_TENSION])
    out[FactionRelationScore.REL_WEARINESS] = _snap_small(out[FactionRelationScore.REL_WEARINESS])

    return out


static func _scale_signed_int(x: int, gain_mul: float, loss_mul: float) -> float:
    if x >= 0:
        return float(x) * gain_mul
    return float(x) * loss_mul

static func _snap_small(x: float) -> float:
    return 0.0 if abs(x) < 0.05 else x       
    
static func apply_arc_resolution(
    action: StringName,
    choice: StringName,
    rel_ab: FactionRelationScore, # A -> B
    rel_ba: FactionRelationScore, # B -> A
    current_day: int,
    rng: RandomNumberGenerator,
    cooldown_override_days: int = -1
) -> void:
    var d := get_arc_deltas(action, choice)
    if d.is_empty():
        return

    var ab :Dictionary = d["ab"]
    var ba :Dictionary = d["ba"]
    
    #TODO a revoir, il n'y a pas d'interer a appliquer un delta de 0
    rel_ab.apply_delta({
        FactionRelationScore.REL_RELATION: int(ab.get(FactionRelationScore.REL_RELATION, 0)),
        FactionRelationScore.REL_TRUST: int(ab.get(FactionRelationScore.REL_TRUST, 0)),
        FactionRelationScore.REL_GRIEVANCE: float(ab.get(FactionRelationScore.REL_GRIEVANCE, 0.0)),
        FactionRelationScore.REL_TENSION: float(ab.get(FactionRelationScore.REL_TENSION, 0.0)),
        FactionRelationScore.REL_WEARINESS: float(ab.get(FactionRelationScore.REL_WEARINESS, 0.0))
    })

    rel_ba.apply_delta({
        FactionRelationScore.REL_RELATION: int(ba.get(FactionRelationScore.REL_RELATION, 0)),
        FactionRelationScore.REL_TRUST: int(ba.get(FactionRelationScore.REL_TRUST, 0)),
        FactionRelationScore.REL_GRIEVANCE: float(ba.get(FactionRelationScore.REL_GRIEVANCE, 0.0)),
        FactionRelationScore.REL_TENSION: float(ba.get(FactionRelationScore.REL_TENSION, 0.0)),
        FactionRelationScore.REL_WEARINESS: float(ba.get(FactionRelationScore.REL_WEARINESS, 0.0))
    })

    var cd := cooldown_override_days if cooldown_override_days >= 0 else cooldown_days_for(action, rng)
    rel_ab.set_cooldown(current_day, cd)
    rel_ba.set_cooldown(current_day, cd)


static func _policy(action: StringName) -> Dictionary:
    return ARC_TYPE_POLICY.get(action, {"cap_weight": 1.0, "trust_cap_weight": 1.0, "cooldown_mult": 1.0})
static func compute_relation_cap_pct_from_histories(
    hist_a: ArcHistory,
    hist_b: ArcHistory,
    a_id: StringName,
    b_id: StringName,
    arc_type: StringName,
    current_day: int,
    params: Dictionary = {}
) -> float:
    var pct_min := float(params.get("pct_min", 0.10))
    var pct_max := float(params.get("pct_max", 0.30))

    var meta_ab := hist_a.get_target_meta(b_id)
    var meta_ba := hist_b.get_target_meta(a_id)

    # --- Entrenchment pair (A<->B) ---
    var pair_k := float(params.get("pair_k", 18.0))
    var pair_total := float(meta_ab.total_count + meta_ba.total_count) * 0.5
    var entrench_pair := clampf(pair_total / pair_k, 0.0, 1.0)

    # --- Entrenchment global (A & B) ---
    var global_k := float(params.get("global_k", 40.0))
    var global_total := float(hist_a.total_count + hist_b.total_count) * 0.5
    var entrench_global := clampf(global_total / global_k, 0.0, 1.0)

    # --- Spam récent du même type sur la paire ---
    var window_days := int(params.get("window_days", 14))
    var spam_k := float(params.get("spam_k", 6.0))
    var recent_same := float(meta_ab.count_in_last_days(current_day, window_days, arc_type)
        + meta_ba.count_in_last_days(current_day, window_days, arc_type)) * 0.5
    var spam := clampf(recent_same / spam_k, 0.0, 1.0)

    # --- Récence du type et de la paire ---
    var recency_k := float(params.get("recency_k", 14.0))
    var days_since_type := float(min(
        meta_ab.get_days_since_type(arc_type, current_day),
        meta_ba.get_days_since_type(arc_type, current_day)
    ))
    var type_oldness := clampf(days_since_type / recency_k, 0.0, 1.0)

    var pair_recency_k := float(params.get("pair_recency_k", 21.0))
    var days_since_any := float(min(meta_ab.get_days_since_any(current_day), meta_ba.get_days_since_any(current_day)))
    var pair_oldness := clampf(days_since_any / pair_recency_k, 0.0, 1.0)

    # --- Volatilité (0..1) => cap_pct (10%..30%) ---
    # + vieux / rare => bouge plus
    # + ancré / spammé => bouge moins
    var volatility := 0.40 * (1.0 - entrench_pair) + 0.15 * (1.0 - entrench_global) + 0.20 * type_oldness + 0.10 * pair_oldness +0.15 * (1.0 - spam)

    volatility = clampf(volatility, 0.0, 1.0)

    var cap_pct :float = lerp(pct_min, pct_max, volatility)

    # Optionnel: poids par type (ex: declare_war => plus structurant donc cap plus bas)
    var type_weight := float(params.get("type_weight", 1.0))
    cap_pct *= type_weight

    return clampf(cap_pct, pct_min, pct_max)
