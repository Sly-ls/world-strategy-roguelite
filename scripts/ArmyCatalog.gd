# res://scripts/ArmyCatalog.gd
extends Node
class_name ArmyCatalog

## Catalog d'armées - Charge automatiquement les templates depuis res://data/armies/
## Autoload: ArmyFactory

# key -> ArmyData TEMPLATE
var templates: Dictionary = {}

# ========================================
# INITIALISATION (CODE EXISTANT)
# ========================================

func _ready() -> void:
    _load_army_templates()

func _load_army_templates() -> void:
    templates.clear()

    var base_path := "res://data/armies"
    var dir := DirAccess.open(base_path)
    if dir == null:
        push_error("ArmyCatalog: impossible d'ouvrir %s" % base_path)
        return

    dir.list_dir_begin()
    while true:
        var file_name := dir.get_next()
        if file_name == "":
            break
        if dir.current_is_dir():
            continue
        if not file_name.ends_with(".tres"):
            continue

        var full_path := base_path + "/" + file_name
        var res := load(full_path)
        if res is ArmyData:
            var army_res := res as ArmyData

            var key := army_res.id
            if key == "":
                # fallback: nom de fichier sans extension
                key = file_name.trim_suffix(".tres")

            if templates.has(key):
                push_warning("ArmyCatalog: id d'armée dupliqué '%s' (%s)" % [key, full_path])

            templates[key] = army_res
        else:
            push_warning("ArmyCatalog: %s n'est pas un ArmyData" % full_path)

    dir.list_dir_end()

    print("ArmyCatalog: %d templates d'armées chargés." % templates.size())

# ========================================
# CRÉATION DE BASE (CODE EXISTANT AMÉLIORÉ)
# ========================================

func create_army(id: String, _player: bool = false) -> ArmyData:
    """Crée une armée depuis un template"""
    if not templates.has(id):
        push_error("ArmyCatalog: aucun template pour l'armée id '%s'" % id)
        return _create_fallback_army(id, _player)  # ⭐ Fallback au lieu de null

    var template := templates[id] as ArmyData
    return template.clone_runtime(_player)

# ========================================
# ⭐ NOUVEAUX HELPERS (AJOUTS)
# ========================================

func create_player_army(template_name: String = "starter") -> ArmyData:
    """Crée l'armée du joueur"""
    return create_army(template_name, true)

func create_enemy_army(template_name: String) -> ArmyData:
    """Crée une armée ennemie"""
    return create_army(template_name, false)

func create_random_enemy(difficulty: int = 1) -> ArmyData:
    """
    Crée un ennemi aléatoire selon la difficulté

    Args:
    difficulty: 1=facile, 2=moyen, 3=difficile, 4=boss

    Returns:
    ArmyData ennemie aléatoire
    """
    var candidates: Array[String] = []
    
    match difficulty:
        1:  # Facile
            candidates = ["goblin_raiders", "bandit_group"]
        2:  # Moyen
            candidates = ["orc_patrol", "bandit_gang", "undead_patrol"]
        3:  # Difficile
            candidates = ["orc_warband"]
        4:  # Boss
            candidates = ["orc_warlord", "bandit_king", "lich"]
        _:
            candidates = ["orc_patrol"]
    
    # Filtre les templates existants
    var available: Array[String] = []
    for template_id in candidates:
        if templates.has(template_id):
            available.append(template_id)
    
    if available.is_empty():
        push_warning("ArmyCatalog: aucun template pour difficulté %d, utilise fallback" % difficulty)
        return _create_fallback_army("enemy_difficulty_%d" % difficulty, false)
    
    var chosen = available.pick_random()
    return create_enemy_army(chosen)

func create_procedural_patrol(faction: String, strength: int = 3) -> ArmyData:
    """
    Crée une patrouille procédurale

    Args:
    faction: "orc", "bandit", "undead", "goblin"
    strength: Niveau de force (détermine quel template utiliser)

    Returns:
    ArmyData de patrouille
    """
    var template_id: String
    
    # Choisit template selon faction et force
    match faction:
        "orc":
            template_id = "orc_warband" if strength >= 5 else "orc_patrol"
        "bandit":
            template_id = "bandit_gang" if strength >= 4 else "bandit_group"
        "undead":
            template_id = "undead_patrol"
        "goblin":
            template_id = "goblin_raiders"
        _:
            template_id = "orc_patrol"
    
    # Utilise le template s'il existe
    if templates.has(template_id):
        return create_enemy_army(template_id)
    
    # Fallback: cherche n'importe quel template de cette faction
    for key in templates.keys():
        if key.begins_with(faction):
            return create_enemy_army(key)
    
    # Aucun template trouvé, crée fallback
    push_warning("ArmyCatalog: aucun template pour faction '%s'" % faction)
    return _create_fallback_army("%s_patrol" % faction, false)

# ========================================
# FALLBACK (NOUVEAU)
# ========================================

func _create_fallback_army(id: String, is_player: bool) -> ArmyData:
    """Crée une armée basique si le template est manquant"""
    print("[ArmyCatalog] ⚠️ Fallback pour: %s" % id)
    
    var army = ArmyData.new(is_player)
    army.id = id
    
    # Crée 3 unités basiques
    for i in range(3):
        var unit = UnitData.new()
        unit.name = "%s %d" % [id.capitalize().replace("_", " "), i + 1]
        unit.max_hp = 50
        unit.hp = 50
        unit.powers[PowerEnums.PowerType.MELEE] = 5
        army.units[i] = unit
    
    return army

# ========================================
# UTILITAIRES (NOUVEAUX)
# ========================================

func get_available_templates() -> Array[String]:
    """Retourne la liste de tous les templates disponibles"""
    var result: Array[String] = []
    for key in templates.keys():
        result.append(key)
    return result

func template_exists(template_id: String) -> bool:
    """Vérifie si un template existe"""
    return templates.has(template_id)

func get_template_count() -> int:
    """Retourne le nombre de templates chargés"""
    return templates.size()

# ========================================
# DEBUG (NOUVEAU)
# ========================================

func debug_print_templates() -> void:
    """Affiche tous les templates chargés (debug)"""
    print("\n========== ARMY TEMPLATES ==========")
    for key in templates.keys():
        var template = templates[key] as ArmyData
        var unit_count = 0
        for unit in template.units:
            if unit != null:
                unit_count += 1
        print("  • %s (id: %s, units: %d)" % [key, template.id, unit_count])
    print("Total: %d templates" % templates.size())
    print("====================================\n")
