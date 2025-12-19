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

@export var relation_with_player: int = 0  ## -100 (ennemi juré) à +100 (allié)
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

# ========================================
# MÉTHODES
# ========================================

## Ajuster la relation avec le joueur
func adjust_relation(delta: int) -> void:
    var old_relation := relation_with_player
    relation_with_player = clamp(relation_with_player + delta, -100, 100)
    
    var old_status := _get_relation_status_for_value(old_relation)
    var new_status := get_relation_status()
    
    if old_status != new_status:
        print("⚡ Relation avec %s : %s → %s" % [name, old_status, new_status])

## Obtenir le statut de relation actuel
func get_relation_status() -> String:
    return _get_relation_status_for_value(relation_with_player)

## Helper pour obtenir le statut d'une valeur de relation
func _get_relation_status_for_value(value: int) -> String:
    if value >= 75:
        return "Allié"
    elif value >= 25:
        return "Amical"
    elif value >= -25:
        return "Neutre"
    elif value >= -75:
        return "Hostile"
    else:
        return "Ennemi juré"

## Obtenir la couleur de la relation
func get_relation_color() -> Color:
    if relation_with_player >= 75:
        return Color(0.2, 0.8, 0.2)  # Vert
    elif relation_with_player >= 25:
        return Color(0.5, 1.0, 0.5)  # Vert clair
    elif relation_with_player >= -25:
        return Color(0.8, 0.8, 0.8)  # Gris
    elif relation_with_player >= -75:
        return Color(1.0, 0.5, 0.2)  # Orange
    else:
        return Color(1.0, 0.2, 0.2)  # Rouge

## Vérifier si la faction est alliée
func is_ally() -> bool:
    return relation_with_player >= 50

## Vérifier si la faction est ennemie
func is_enemy() -> bool:
    return relation_with_player <= -50

## Vérifier si la faction est neutre
func is_neutral() -> bool:
    return relation_with_player > -50 and relation_with_player < 50

## Sauvegarder l'état
func save_state() -> Dictionary:
    return {
        "id": id,
        "relation": relation_with_player,
        "power": power_level,
        "is_destroyed": is_destroyed
    }

## Charger l'état
func load_state(data: Dictionary) -> void:
    relation_with_player = data.get("relation", 0)
    power_level = data.get("power", 1)
    is_destroyed = data.get("is_destroyed", false)

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
