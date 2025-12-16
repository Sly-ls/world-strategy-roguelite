# res://src/factions/FactionManager.gd
extends Node
class_name FactionManagerClass 

## Gestionnaire global des factions
## NOUVEAU : Créé par Claude (manquait chez ChatGPT)

# ========================================
# SIGNAUX
# ========================================

signal faction_relation_changed(faction_id: String, old_value: int, new_value: int)
signal faction_status_changed(faction_id: String, old_status: String, new_status: String)

# ========================================
# PROPRIÉTÉS
# ========================================

var factions: Dictionary = {}  ## id -> Faction
# Relations entre factions (symétrique)
var relations_between: Dictionary = {} # key "a|b" -> int

func _pair_key(a: String, b: String) -> String:
    if a < b:
        return "%s|%s" % [a, b]
    return "%s|%s" % [b, a]

func set_relation_between(a: String, b: String, value: int) -> void:
    relations_between[_pair_key(a, b)] = value

func get_relation_between(a: String, b: String) -> int:
    if a == "" or b == "" or a == b:
        return 0
    return int(relations_between.get(_pair_key(a, b), 0))

# ========================================
# LIFECYCLE
# ========================================

func _ready() -> void:
    _init_default_factions()
    set_relation_between("humans", "orcs", -80)
    set_relation_between("humans", "bandits", -60)
    set_relation_between("elves", "orcs", -40)
    set_relation_between("elves", "bandits", -30)
    set_relation_between("humans", "elves", 10)
    print("✓ FactionManager initialisé avec %d factions" % factions.size())

# ========================================
# INITIALISATION
# ========================================

func _init_default_factions() -> void:
    """Crée les factions de base du jeu"""
    
    # Royaume Humain
    register_faction(
        "humans",
        "Royaume Humain",
        "Un royaume humain organisé et ambitieux.",
        0,
        5,
        Faction.FactionType.NEUTRAL
    )
    
    # Elfes de la Forêt
    register_faction(
        "elves",
        "Elfes de la Forêt",
        "Gardiens ancestraux de la grande forêt.",
        -10,
        4,
        Faction.FactionType.NEUTRAL
    )
    
    # Tribus Orques
    register_faction(
        "orcs",
        "Tribus Orques",
        "Guerriers féroces cherchant à bâtir leur empire.",
        -30,
        6,
        Faction.FactionType.HOSTILE
    )
    
    # Bandits
    register_faction(
        "bandits",
        "Bandits des Routes",
        "Pillards et hors-la-loi sans scrupules.",
        -50,
        2,
        Faction.FactionType.HOSTILE
    )

# ========================================
# GESTION DES FACTIONS
# ========================================

func register_faction(
    p_id: String,
    p_name: String,
    p_description: String,
    p_relation: int,
    p_power: int,
    p_type: Faction.FactionType
) -> Faction:
    """Enregistre une nouvelle faction"""
    
    var f := Faction.new()
    f.id = p_id
    f.name = p_name
    f.description = p_description
    f.relation_with_player = p_relation
    f.power_level = p_power
    f.faction_type = p_type
    
    factions[p_id] = f
    return f

func get_faction(faction_id: String) -> Faction:
    """Récupère une faction par son ID"""
    return factions.get(faction_id, null)

func has_faction(faction_id: String) -> bool:
    """Vérifie si une faction existe"""
    return factions.has(faction_id)

# ========================================
# RELATIONS
# ========================================

func adjust_relation(faction_id: String, delta: int) -> void:
    """Ajuste la relation avec une faction"""
    var f := get_faction(faction_id)
    if f == null:
        print("FactionManager: faction '%s' introuvable" % faction_id)
        return
    
    var old_value := f.relation_with_player
    var old_status := f.get_relation_status()
    
    f.adjust_relation(delta)
    
    var new_value := f.relation_with_player
    var new_status := f.get_relation_status()
    
    # Signaux
    faction_relation_changed.emit(faction_id, old_value, new_value)
    
    if old_status != new_status:
        faction_status_changed.emit(faction_id, old_status, new_status)
    
    # Log
    var sign := "+" if delta >= 0 else ""
    print("→ Relation avec %s : %s%d (total: %d - %s)" % [
        f.name,
        sign,
        delta,
        f.relation_with_player,
        f.get_relation_status()
    ])

func get_relation(faction_id: String) -> int:
    """Obtient la relation avec une faction"""
    var f := get_faction(faction_id)
    return f.relation_with_player if f else 0

func get_relation_status(faction_id: String) -> String:
    """Obtient le statut de relation avec une faction"""
    var f := get_faction(faction_id)
    return f.get_relation_status() if f else "Inconnu"

# ========================================
# QUERIES
# ========================================

func get_all_factions() -> Array[Faction]:
    """Retourne toutes les factions"""
    var result: Array[Faction] = []
    for f in factions.values():
        result.append(f)
    return result

func get_allies() -> Array[Faction]:
    """Retourne les factions alliées"""
    var result: Array[Faction] = []
    for f in factions.values():
        if f.is_ally():
            result.append(f)
    return result

func get_enemies() -> Array[Faction]:
    """Retourne les factions ennemies"""
    var result: Array[Faction] = []
    for f in factions.values():
        if f.is_enemy():
            result.append(f)
    return result

func get_neutral() -> Array[Faction]:
    """Retourne les factions neutres"""
    var result: Array[Faction] = []
    for f in factions.values():
        if f.is_neutral():
            result.append(f)
    return result

# ========================================
# PERSISTANCE
# ========================================

func save_state() -> Dictionary:
    """Sauvegarde l'état de toutes les factions"""
    var data := {}
    for id in factions:
        var f: Faction = factions[id]
        data[id] = f.save_state()
    return data

func load_state(data: Dictionary) -> void:
    """Charge l'état de toutes les factions"""
    for id in data:
        if factions.has(id):
            var f: Faction = factions[id]
            f.load_state(data[id])
    
    print("✓ État des factions chargé")

# ========================================
# DEBUG
# ========================================
func print_relations_between() -> void:
    print("\n=== RELATIONS INTER-FACTIONS ===")
    for k in relations_between.keys():
        print("- %s : %d" % [k, relations_between[k]])
    print("===============================\n")
    
func print_all_factions() -> void:
    """Affiche toutes les factions (debug)"""
    print("\n=== FACTIONS ===")
    for f in get_all_factions():
        print("- %s : %d (%s)" % [f.name, f.relation_with_player, f.get_relation_status()])
    print("================\n")
