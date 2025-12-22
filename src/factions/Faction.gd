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
var profile: FactionProfile = null

## Relations avec les autres factions (directionnelles, asymétriques)
## other_faction_id -> FactionRelationScore
var relations: Dictionary = {}

# ========================================
# MÉTHODES - RELATIONS INTER-FACTIONS
# ========================================

## Récupère le FactionRelationScore vers une autre faction
func get_relation_to(other_faction_id) -> FactionRelationScore:
    var other_id := str(other_faction_id)
    return relations.get(other_id, null)


## Définit le FactionRelationScore vers une autre faction
func set_relation_to(other_faction_id, score: FactionRelationScore) -> void:
    var other_id := str(other_faction_id)
    relations[other_id] = score


## Vérifie si une relation existe vers une autre faction
func has_relation_to(other_faction_id) -> bool:
    var other_id := str(other_faction_id)
    return relations.has(other_id)


## Récupère ou crée le FactionRelationScore vers une autre faction
func get_or_create_relation_to(other_faction_id) -> FactionRelationScore:
    var other_id := str(other_faction_id)
    if not relations.has(other_id):
        var score := FactionRelationScore.new(StringName(other_id))
        relations[other_id] = score
    return relations[other_id]


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
