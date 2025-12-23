# res://src/factions/Faction.gd
extends Resource
class_name Faction

## Représente une faction dans le monde
## Fusion : Concept de ChatGPT + Implémentation de Claude

# ========================================
# PROPRIÉTÉS EXPORTÉES
# ========================================

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""

# TODO: relation_with_player doit être migré avec les factions mineures et les armées libres
#@export var relation_with_player: int = 0  ## -100 à 100
@export var power_level: int = 1           ## 1-10
@export var faction_type: FactionType = FactionType.NEUTRAL

# ========================================
# ENUMS
# ========================================

enum FactionType {
    NEUTRAL,        ## Neutre
    FRIENDLY,       ## Amical par défaut
    HOSTILE,        ## Hostile par défaut
    TRADER,         ## Marchand
    MAGICAL,        ## Faction magique
    TECHNOLOGICAL,  ## Faction technologique
    DIVINE,         ## Faction divine/religieuse
    DEMONIC         ## Faction démoniaque
}

# ========================================
# PROPRIÉTÉS RUNTIME
# ========================================

var is_destroyed: bool = false
var territories: Array[Vector2i] = []  ## POI contrôlés (futur)

## Profil de la faction (axes + personnalité)
## Utilisé par le système d'arcs et de relations inter-factions
var profile: FactionProfile = FactionProfile.new()

## Relations avec les autres factions (directionnelles, asymétriques)
## other_faction_id -> FactionRelationScore
var relations: Dictionary = {}

# ========================================
# MÉTHODES - RELATIONS INTER-FACTIONS
# ========================================

func get_relation_to(target_id: StringName) -> FactionRelationScore:
    """Récupère le FactionRelationScore vers une autre faction, la crée si elle n'existe pas"""
    if not relations.has(target_id):
        init_relation(target_id)
    return relations[target_id]


## Définit le FactionRelationScore vers une autre faction
func set_relation_to(other_faction_id, score: FactionRelationScore) -> void:
    var other_id := str(other_faction_id)
    relations[other_id] = score


## Vérifie si une relation existe vers une autre faction
func has_relation_to(other_faction_id) -> bool:
    var other_id := str(other_faction_id)
    return relations.has(other_id)

## Retourne toutes les relations de cette faction
func get_all_relations() -> Dictionary:
    return relations


## Retourne les IDs de toutes les factions avec lesquelles on a une relation
func get_related_faction_ids() -> Array[String]:
    var result: Array[String] = []
    for fid in relations.keys():
        result.append(str(fid))
    return result

# ========================================
# MÉTHODES - RELATION 
# ========================================
func init_relation(target_id: StringName, params: Dictionary = {}) -> void:
    var target_faction :Faction = FactionManager.get_faction(target_id)
    var init_rel :Dictionary = compute_baseline_relation(target_faction.profile)
    var target_relation = FactionRelationScore.new(target_id)
    target_relation.init(init_rel)
    relations[target_id] = target_relation
    
func compute_baseline_relation(b: FactionProfile, params: Dictionary = {}) -> Dictionary:
    # ---- Tunables ----
    var w_axis_similarity: float = float(params.get("w_axis_similarity", 80.0))  # poids du "même axe"
    var w_cross_conflict: float = float(params.get("w_cross_conflict", 55.0))   # poids des conflits croisés
    var w_personality_bias: float = float(params.get("w_personality_bias", 25.0))

    # Cross-conflict weights (abs-products), tu peux en ajouter plus tard
    var w_tech_nature: float = float(params.get("w_tech_nature", 1.0))
    var w_divine_corruption: float = float(params.get("w_divine_corruption", 1.0))
    var w_magic_tech: float = float(params.get("w_magic_tech", 0.35)) # optionnel, plus léger

    # Friction tuning
    var friction_base: float = float(params.get("friction_base", 18.0))
    var friction_from_opposition: float = float(params.get("friction_from_opposition", 65.0))
    var friction_from_cross: float = float(params.get("friction_from_cross", 55.0))

    # Tension init tuning (tu peux la plafonner pour éviter guerres immédiates)
    var tension_cap: float = float(params.get("tension_cap", 40.0))

    # ---- Read profiles (normalized -1..+1) ----
    var aT := float(profile.get_axis_affinity(FactionProfile.AXIS_TECH)) / 100.0
    var aM := float(profile.get_axis_affinity(FactionProfile.AXIS_MAGIC)) / 100.0
    var aN := float(profile.get_axis_affinity(FactionProfile.AXIS_NATURE)) / 100.0
    var aD := float(profile.get_axis_affinity(FactionProfile.AXIS_DIVINE)) / 100.0
    var aC := float(profile.get_axis_affinity(FactionProfile.AXIS_CORRUPTION)) / 100.0

    var bT := float(b.get_axis_affinity(FactionProfile.AXIS_TECH)) / 100.0
    var bM := float(b.get_axis_affinity(FactionProfile.AXIS_MAGIC)) / 100.0
    var bN := float(b.get_axis_affinity(FactionProfile.AXIS_NATURE)) / 100.0
    var bD := float(b.get_axis_affinity(FactionProfile.AXIS_DIVINE)) / 100.0
    var bC := float(b.get_axis_affinity(FactionProfile.AXIS_CORRUPTION)) / 100.0

    # ---- Axis similarity (dot / 5) in [-1..+1] ----
    var dot := (aT*bT + aM*bM + aN*bN + aD*bD + aC*bC)
    var similarity := dot / 5.0

    # Opposition measure in [0..~1] : somme des contributions "opposées"
    # (produit négatif => opposition)
    var opposition :float = (
        max(0.0, -(aT*bT)) +
        max(0.0, -(aM*bM)) +
        max(0.0, -(aN*bN)) +
        max(0.0, -(aD*bD)) +
        max(0.0, -(aC*bC))
    ) / 5.0

    # Cross-conflicts (abs-products) in [0..~1]
    var cross := 0.0
    cross += w_tech_nature * (abs(aT) * abs(bN) + abs(aN) * abs(bT)) / 2.0
    cross += w_divine_corruption * (abs(aD) * abs(bC) + abs(aC) * abs(bD)) / 2.0
    cross += w_magic_tech * (abs(aM) * abs(bT) + abs(aT) * abs(bM)) / 2.0
    cross = clampf(cross, 0.0, 1.0)

    # ---- Personality filters (directional: A's worldview) ----
    var aggr := profile.get_personality(FactionProfile.PERS_AGGRESSION)
    var veng := profile.get_personality(FactionProfile.PERS_VENGEFULNESS)
    var diplo := profile.get_personality(FactionProfile.PERS_DIPLOMACY)
    var risk := profile.get_personality(FactionProfile.PERS_RISK_AVERSION)
    var expa := profile.get_personality(FactionProfile.PERS_EXPANSIONISM)
    var integ := profile.get_personality(FactionProfile.PERS_INTEGRATIONISM)

    # "Ideological intensity" : plus A est extrême, plus il juge fort (positif ou négatif)
    var intensity :float = (abs(aT) + abs(aM) + abs(aN) + abs(aD) + abs(aC)) / 5.0  # 0..1
    var judgment_gain := clampf(0.65 + 0.7*intensity + 0.2*veng - 0.25*diplo, 0.5, 1.6)

    # Relation bias: diplomatie et intégration rendent plus "ouvert" par défaut,
    # aggression + vengeance rendent plus dur, expansionism rend suspicieux si l'autre est incompatible.
    var pers_bias :=(+0.65*(diplo - 0.5)) + (+0.45*(integ - 0.5)) + (-0.55*(aggr - 0.5)) + (-0.45*(veng - 0.5)) + (-0.25*(expa - 0.5))

    # ---- Baseline relation (A -> B) ----
    # similarity pousse + ; cross + opposition poussent - ; personnalité ajuste le ton.
    var rel_f := 0.0
    rel_f += (similarity * w_axis_similarity) * judgment_gain
    rel_f -= (cross * w_cross_conflict) * judgment_gain
    rel_f += pers_bias * w_personality_bias

    var relation := clampi(int(round(rel_f)), -100, 100)

    # ---- Friction (volatilité / risque d'incident) ----
    # friction augmente avec opposition + cross-conflicts, puis est multipliée par le tempérament de A.
    var fr := friction_base
    fr += opposition * friction_from_opposition * judgment_gain
    fr += cross * friction_from_cross * judgment_gain

    # tempérament : aggression/vengefulness augmentent, diplomacy/risk_aversion diminuent
    var fr_mul := 1.0 \
        + 0.50*(aggr - 0.5) \
        + 0.45*(veng - 0.5) \
        - 0.40*(diplo - 0.5) \
        - 0.25*(risk - 0.5)

    fr = clampf(fr * clampf(fr_mul, 0.55, 1.65), 0.0, 100.0)

    # ---- Optional: init trust & tension (useful to init FactionRelationScore) ----
    # Trust suit la relation, mais est pénalisée par rancune/agressivité.
    var trust_f := 0.65*float(relation) + 18.0*(diplo - 0.5) - 14.0*(veng - 0.5) - 10.0*(aggr - 0.5)
    var trust := clampi(int(round(trust_f)), -100, 100)

    # Tension est une “partie” de la friction + négativité de relation, plafonnée (évite guerres day 1)
    var tension := clampf(0.35*fr + 0.20*max(0.0, -float(relation)), 0.0, tension_cap)
    var init_dict :Dictionary = {
    FactionRelationScore.REL_RELATION: relation,  # -100..100 (A -> B)
    FactionRelationScore.REL_FRICTION: fr,        # 0..100 (A -> B)
    FactionRelationScore.REL_TRUST: trust,        # -100..100 (A -> B)
    FactionRelationScore.REL_TENSION: tension     # 0..tension_cap
    }
                
    return init_dict


func apply_reciprocity(fb :Faction, rng: RandomNumberGenerator, params: Dictionary = {}) -> void:
    # --- get parameter ---
    var reciprocity_strength = params.get("reciprocity_strength", 0.5)
    var keep_asymmetry = params.get("keep_asymmetry", 0)
    var reciprocity_noise = params.get("reciprocity_noise", 2)
    var max_change_per_pair = params.get("max_change_per_pair", 18)
    reciprocity_strength = clampf(reciprocity_strength, 0.0, 1.0)
    keep_asymmetry = clampf(keep_asymmetry, 0.0, 1.0)
    reciprocity_noise = clampf(reciprocity_noise, 0, 20)
    max_change_per_pair = clampf(max_change_per_pair, 0, 50)
    
    # --- get existing relation ---
    var ab: FactionRelationScore = get_relation_to(fb.id)
    var ba: FactionRelationScore = fb.get_relation_to(id)

    # --- Relation reciprocity ---
    var ab_rel := float(ab.get_score(FactionRelationScore.REL_RELATION))
    var ba_rel := float(ba.get_score(FactionRelationScore.REL_RELATION))
    var avg_rel := (ab_rel + ba_rel) * 0.5

    # asymmetry target: keep part of (ab - ba)
    var asym :float = (ab_rel - ba_rel) * keep_asymmetry

    var ab_target := avg_rel + asym
    var ba_target := avg_rel - asym

    # move each towards target by reciprocity_strength
    var ab_new :float = lerp(ab_rel, ab_target, reciprocity_strength)
    var ba_new :float = lerp(ba_rel, ba_target, reciprocity_strength)

    # tiny noise to avoid perfect pair patterns
    if reciprocity_noise > 0:
        ab_new += float(rng.randi_range(-reciprocity_noise, reciprocity_noise))
        ba_new += float(rng.randi_range(-reciprocity_noise, reciprocity_noise))

    # clamp change per pair so you don't destroy natural enemies/allies too much
    ab_new = _clamp_delta(ab_rel, ab_new, float(max_change_per_pair))
    ba_new = _clamp_delta(ba_rel, ba_new, float(max_change_per_pair))
   
    var ab_relation_score = clampi(int(round(ab_new)), -100, 100)
    var ba_relation_score = clampi(int(round(ba_new)), -100, 100)
    ab.set_score(FactionRelationScore.REL_RELATION, ab_relation_score)
    ba.set_score(FactionRelationScore.REL_RELATION, ba_relation_score)
    
    # --- Trust reciprocity (softer) ---
    var ab_tr := float(ab.get_score(FactionRelationScore.REL_TRUST))
    var ba_tr := float(ba.get_score(FactionRelationScore.REL_TRUST))
    var avg_tr := (ab_tr + ba_tr) * 0.5
    var asym_tr :float = (ab_tr - ba_tr) * (keep_asymmetry * 0.8)

    var ab_tr_target :float = avg_tr + asym_tr
    var ba_tr_target :float = avg_tr - asym_tr

    var ab_tr_new :float = lerp(ab_tr, ab_tr_target, reciprocity_strength * 0.55)
    var ba_tr_new :float = lerp(ba_tr, ba_tr_target, reciprocity_strength * 0.55)

    var ab_trust_score = clampi(int(round(ab_tr_new)), -100, 100)
    var ba_trust_score = clampi(int(round(ba_tr_new)), -100, 100)
    ab.set_score(FactionRelationScore.REL_TRUST, ab_trust_score)
    ba.set_score(FactionRelationScore.REL_TRUST, ba_trust_score)

    # --- Tension reciprocity (makes arcs more stable) ---
    # Tension converges faster than relation (keeps wars from being too one-sided).
    var ab_te := ab.get_score(FactionRelationScore.REL_TENSION)
    var ba_te := ba.get_score(FactionRelationScore.REL_TENSION)
    var avg_te := (ab_te + ba_te) * 0.5

    var ab_tension_score = clampf(lerp(ab_te, avg_te, reciprocity_strength * 0.80), 0.0, 100.0)
    var ba_tension_score = clampf(lerp(ba_te, avg_te, reciprocity_strength * 0.80), 0.0, 100.0)
    ab.set_score(FactionRelationScore.REL_TENSION, ab_tension_score)
    ba.set_score(FactionRelationScore.REL_TENSION, ba_tension_score)

static func _clamp_delta(old_v: float, new_v: float, max_delta: float) -> float:
    var d := new_v - old_v
    if d > max_delta:
        return old_v + max_delta
    if d < -max_delta:
        return old_v - max_delta
    return new_v
# ========================================
# PERSISTANCE
# ========================================

## Sauvegarder l'état
func save_state() -> Dictionary:
    var relations_data := {}
    for other_id in relations.keys():
        var rs: FactionRelationScore = relations[other_id]
        relations_data[other_id] = {
            "relation": rs.relation,
            "trust": rs.trust,
            "tension": rs.tension,
            "grievance": rs.grievance,
            "weariness": rs.weariness
        }
    
    return {
        "id": id,
        # TODO: relation_with_player migré avec factions mineures/armées libres
        #"relation": relation_with_player,
        "power": power_level,
        "is_destroyed": is_destroyed,
        "relations": relations_data
    }


## Charger l'état
func load_state(data: Dictionary) -> void:
    # TODO: relation_with_player migré avec factions mineures/armées libres
    #relation_with_player = data.get("relation", 0)
    power_level = data.get("power", 1)
    is_destroyed = data.get("is_destroyed", false)
    
    # Charger les relations inter-factions
    var relations_data: Dictionary = data.get("relations", {})
    relations.clear()
    for other_id in relations_data.keys():
        var rs_data: Dictionary = relations_data[other_id]
        var rs := FactionRelationScore.new(StringName(other_id))
        rs.relation = int(rs_data.get("relation", 0))
        rs.trust = int(rs_data.get("trust", 50))
        rs.tension = int(rs_data.get("tension", 0))
        rs.grievance = int(rs_data.get("grievance", 0))
        rs.weariness = int(rs_data.get("weariness", 0))
        relations[other_id] = rs

# ========================================
# UTILITAIRES
# ========================================

## Obtenir le nom du type de faction
func get_type_name() -> String:
    match faction_type:
        FactionType.NEUTRAL: return "Neutre"
        FactionType.FRIENDLY: return "Amical"
        FactionType.HOSTILE: return "Hostile"
        FactionType.TRADER: return "Marchand"
        FactionType.MAGICAL: return "Magique"
        FactionType.TECHNOLOGICAL: return "Technologique"
        FactionType.DIVINE: return "Divin"
        FactionType.DEMONIC: return "Démoniaque"
        _: return "Inconnu"


# ========================================
# MÉTHODES - RELATION AVEC LE JOUEUR
# TODO: doit être migré avec les factions mineures et les armées libres
# ========================================
## Ajuster la relation avec le joueur
#func adjust_relation(delta: int) -> void:
#	var old_relation := relation_with_player
#	relation_with_player = clampi(relation_with_player + delta, -100, 100)
#	
#	var old_status := _get_relation_status_for_value(old_relation)
#	var new_status := get_relation_status()
#	
#	if old_status != new_status:
#		print("⚡ Relation avec %s : %s → %s" % [name, old_status, new_status])
## Obtenir le statut de relation actuel avec le joueur
#func get_relation_status() -> String:
#	return _get_relation_status_for_value(relation_with_player)

## Helper pour obtenir le statut d'une valeur de relation
#func _get_relation_status_for_value(value: int) -> String:
#	if value >= 75:
#		return "Allié"
#	elif value >= 25:
#		return "Amical"
#	elif value >= -25:
#		return "Neutre"
#	elif value >= -75:
#		return "Hostile"
#	else:
#		return "Ennemi juré"

## Obtenir la couleur de la relation
#func get_relation_color() -> Color:
#	if relation_with_player >= 75:
#		return Color(0.2, 0.8, 0.2)  # Vert
#	elif relation_with_player >= 25:
#		return Color(0.5, 1.0, 0.5)  # Vert clair
#	elif relation_with_player >= -25:
#		return Color(0.8, 0.8, 0.8)  # Gris
#	elif relation_with_player >= -75:
#		return Color(1.0, 0.5, 0.2)  # Orange
#	else:
#		return Color(1.0, 0.2, 0.2)  # Rouge

## Vérifier si la faction est alliée (avec le joueur)
#func is_ally() -> bool:
#	return relation_with_player >= 50

## Vérifier si la faction est ennemie (avec le joueur)
#func is_enemy() -> bool:
#	return relation_with_player <= -50

## Vérifier si la faction est neutre (avec le joueur)
#func is_neutral() -> bool:
#	return relation_with_player > -50 and relation_with_player < 50
