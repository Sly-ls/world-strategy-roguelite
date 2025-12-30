# res://src/resources/ResourceManager.gd
extends Node

## Gestionnaire global des ressources (or, nourriture, etc.)
## NOUVEAU : Créé par Claude (manquait dans le code)

# ========================================
# SIGNAUX
# ========================================

signal resource_changed(resource_type: String, old_value: int, new_value: int)
signal resource_depleted(resource_type: String)

# ========================================
# TYPES DE RESSOURCES
# ========================================

enum ResourceType {
    GOLD,
    FOOD,
    WOOD,
    STONE,
    IRON,
    MAGIC_ESSENCE
}

# ========================================
# PROPRIÉTÉS
# ========================================

var resources: Dictionary = {
    "gold": 100,
    "food": 50,
    "wood": 0,
    "stone": 0,
    "iron": 0,
    "magic_essence": 0
}

# ========================================
# LIFECYCLE
# ========================================

func _ready() -> void:
    myLogger.debug("✓ ResourceManager initialisé", LogTypes.Domain.SYSTEM)

# ========================================
# GESTION DES RESSOURCES
# ========================================

func add_resource(resource_id: String, amount: int) -> void:
    """Ajoute une quantité de ressource"""
    if not resources.has(resource_id):
        print("ResourceManager: ressource '%s' inconnue" % resource_id)
        return
    
    var old_value :int = resources[resource_id]
    resources[resource_id] = max(0, resources[resource_id] + amount)
    var new_value :int = resources[resource_id]
    
    resource_changed.emit(resource_id, old_value, new_value)
    
    var sign := "+" if amount >= 0 else ""
    myLogger.debug("→ %s : %s%d (total: %d)" % [resource_id.capitalize(), sign, amount, new_value], LogTypes.Domain.SYSTEM)

func remove_resource(resource_id: String, amount: int) -> bool:
    """Retire une quantité de ressource. Retourne false si pas assez."""
    if not has_resource(resource_id, amount):
        return false
    
    add_resource(resource_id, -amount)
    return true

func has_resource(resource_id: String, amount: int) -> bool:
    """Vérifie si on a assez d'une ressource"""
    if not resources.has(resource_id):
        return false
    return resources[resource_id] >= amount

func get_resource(resource_id: String) -> int:
    """Obtient la quantité d'une ressource"""
    return resources.get(resource_id, 0)

func set_resource(resource_id: String, amount: int) -> void:
    """Définit la quantité d'une ressource"""
    if not resources.has(resource_id):
        resources[resource_id] = amount
    else:
        var old_value :int = resources[resource_id]
        resources[resource_id] = max(0, amount)
        resource_changed.emit(resource_id, old_value, resources[resource_id])

# ========================================
# HELPERS
# ========================================

func get_all_resources() -> Dictionary:
    """Retourne toutes les ressources"""
    return resources.duplicate()

func can_afford(costs: Dictionary) -> bool:
    """Vérifie si on peut payer un coût
    costs = { "gold": 50, "food": 10 }
    """
    for resource_id in costs:
        var amount: int = costs[resource_id]
        if not has_resource(resource_id, amount):
            return false
    return true

func pay_cost(costs: Dictionary) -> bool:
    """Paie un coût. Retourne false si impossible."""
    if not can_afford(costs):
        return false
    
    for resource_id in costs:
        var amount: int = costs[resource_id]
        remove_resource(resource_id, amount)
    
    return true

# ========================================
# PERSISTANCE
# ========================================

func save_state() -> Dictionary:
    """Sauvegarde l'état des ressources"""
    return resources.duplicate()

func load_state(data: Dictionary) -> void:
    """Charge l'état des ressources"""
    for resource_id in data:
        resources[resource_id] = data[resource_id]
    
    myLogger.debug("✓ État des ressources chargé", LogTypes.Domain.SYSTEM)

# ========================================
# DEBUG
# ========================================

func print_all_resources() -> void:
    """Affiche toutes les ressources (debug)"""
    myLogger.debug("=== RESSOURCES ===", LogTypes.Domain.SYSTEM)
    for resource_id in resources:
        myLogger.debug("- %s : %d" % [resource_id.capitalize(), resources[resource_id]], LogTypes.Domain.SYSTEM)
    myLogger.debug("==================", LogTypes.Domain.SYSTEM)
