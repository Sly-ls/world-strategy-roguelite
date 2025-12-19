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

# Relations entre factions (symétrique) - ancienne méthode simple
var relations_between: Dictionary = {} # key "a|b" -> int

# Relations avancées entre factions (directionnelles) : faction_id -> { other_id -> FactionRelationScore }
var relation_scores: Dictionary = {}

# RNG pour génération reproductible
var _profile_rng: RandomNumberGenerator = RandomNumberGenerator.new()

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
    _profile_rng.seed = 42  # Seed fixe pour reproductibilité
    _init_default_factions()
    _init_relation_scores()
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
    """Crée les factions de base du jeu avec leurs profils"""
    
    # Royaume Humain - tendance Tech/Divine
    var humans := register_faction(
        "humans",
        "Royaume Humain",
        "Un royaume humain organisé et ambitieux.",
        0,
        5,
        Faction.FactionType.NEUTRAL
    )
    humans.profile = _generate_profile_with_bias({
        FactionProfile.AXIS_TECH: 40,
        FactionProfile.AXIS_DIVINE: 20,
        FactionProfile.AXIS_NATURE: -30
    })
    
    # Elfes de la Forêt - tendance Nature/Magie
    var elves := register_faction(
        "elves",
        "Elfes de la Forêt",
        "Gardiens ancestraux de la grande forêt.",
        -10,
        4,
        Faction.FactionType.NEUTRAL
    )
    elves.profile = _generate_profile_with_bias({
        FactionProfile.AXIS_NATURE: 60,
        FactionProfile.AXIS_MAGIC: 40,
        FactionProfile.AXIS_TECH: -50
    })
    
    # Tribus Orques - tendance Corruption/pas de Divine
    var orcs := register_faction(
        "orcs",
        "Tribus Orques",
        "Guerriers féroces cherchant à bâtir leur empire.",
        -30,
        6,
        Faction.FactionType.HOSTILE
    )
    orcs.profile = _generate_profile_with_bias({
        FactionProfile.AXIS_CORRUPTION: 50,
        FactionProfile.AXIS_DIVINE: -40,
        FactionProfile.AXIS_NATURE: -20
    })
    
    # Bandits - tendance Corruption légère, pragmatique
    var bandits := register_faction(
        "bandits",
        "Bandits des Routes",
        "Pillards et hors-la-loi sans scrupules.",
        -50,
        2,
        Faction.FactionType.HOSTILE
    )
    bandits.profile = _generate_profile_with_bias({
        FactionProfile.AXIS_CORRUPTION: 30,
        FactionProfile.AXIS_DIVINE: -60,
        FactionProfile.AXIS_TECH: 10
    })

func _generate_profile_with_bias(axis_hints: Dictionary) -> FactionProfile:
    """Génère un profil en appliquant des biais sur les axes"""
    var profile := FactionProfile.generate_full_profile(_profile_rng, FactionProfile.GEN_NORMAL)
    
    # Appliquer les biais
    for axis in axis_hints.keys():
        var current: int = profile.get_axis_affinity(axis)
        var bias: int = axis_hints[axis]
        # Blend: 70% bias + 30% généré
        var blended: int = int(float(bias) * 0.7 + float(current) * 0.3)
        profile.set_axis_affinity(axis, blended)
    
    return profile

func _init_relation_scores() -> void:
    """Initialise les FactionRelationScore entre toutes les factions basé sur leurs profils"""
    var faction_ids := factions.keys()
    
    for from_id in faction_ids:
        relation_scores[from_id] = {}
        var from_faction: Faction = factions[from_id]
        
        for to_id in faction_ids:
            if from_id == to_id:
                continue
            
            var to_faction: Faction = factions[to_id]
            var score := FactionRelationScore.new(StringName(to_id))
            
            # Calculer baseline si les deux ont des profils
            if from_faction.profile != null and to_faction.profile != null:
                var baseline := FactionProfile.compute_baseline_relation(
                    from_faction.profile, 
                    to_faction.profile
                )
                score.relation = baseline["relation"]
                score.trust = baseline["trust"]
                score.tension = int(baseline["tension"])
                score.grievance = 0
                score.weariness = 0
                score.clamp_all()
            
            relation_scores[from_id][to_id] = score
    
    print("✓ Relations inter-factions initialisées")

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
# PROFILES (pour système d'arcs)
# ========================================

func get_faction_profile(faction_id) -> FactionProfile:
    """Récupère le profil d'une faction (ou en génère un par défaut)"""
    var id_str := str(faction_id)
    var f := get_faction(id_str)
    if f != null and f.profile != null:
        return f.profile
    
    # Fallback: générer un profil par défaut
    var rng := RandomNumberGenerator.new()
    rng.seed = hash(id_str)
    return FactionProfile.generate_full_profile(rng, FactionProfile.GEN_NORMAL)

func get_faction_profiles() -> Dictionary:
    """Retourne un dictionnaire faction_id -> FactionProfile pour toutes les factions"""
    var profiles: Dictionary = {}  # StringName -> FactionProfile
    for faction_id in factions.keys():
        var f: Faction = factions[faction_id]
        if f.profile != null:
            profiles[StringName(faction_id)] = f.profile
    return profiles

# ========================================
# RELATION SCORES (pour système d'arcs)
# ========================================

func get_relation_score(from_id, to_id) -> FactionRelationScore:
    """Récupère le FactionRelationScore de from_id vers to_id"""
    var from_str := str(from_id)
    var to_str := str(to_id)
    
    if relation_scores.has(from_str) and relation_scores[from_str].has(to_str):
        return relation_scores[from_str][to_str]
    
    # Fallback: créer un nouveau score neutre
    var score := FactionRelationScore.new(StringName(to_str))
    
    # Initialiser avec le cache si dispo
    if not relation_scores.has(from_str):
        relation_scores[from_str] = {}
    relation_scores[from_str][to_str] = score
    
    return score

func get_relation_scores() -> Dictionary:
    """Retourne le dictionnaire complet des relations"""
    return relation_scores

func get_all_relation_scores_for(faction_id: String) -> Dictionary:
    """Retourne toutes les relations d'une faction vers les autres"""
    if relation_scores.has(faction_id):
        return relation_scores[faction_id]
    return {}

# ========================================
# RELATIONS (avec le joueur)
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

func get_all_faction_ids() -> Array[String]:
    """Retourne tous les IDs de faction"""
    var result: Array[String] = []
    for id in factions.keys():
        result.append(id)
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

func print_relation_scores() -> void:
    """Affiche les FactionRelationScore détaillés"""
    print("\n=== RELATION SCORES DÉTAILLÉS ===")
    for from_id in relation_scores.keys():
        for to_id in relation_scores[from_id].keys():
            var rs: FactionRelationScore = relation_scores[from_id][to_id]
            print("- %s → %s : rel=%d trust=%d tension=%d" % [
                from_id, to_id, rs.relation, rs.trust, rs.tension
            ])
    print("=================================\n")

func print_faction_profiles() -> void:
    """Affiche les profils de faction"""
    print("\n=== FACTION PROFILES ===")
    for id in factions.keys():
        var f: Faction = factions[id]
        if f.profile != null:
            print("- %s:" % id)
            print("  Axes: tech=%d magic=%d nature=%d divine=%d corr=%d" % [
                f.profile.get_axis_affinity(FactionProfile.AXIS_TECH),
                f.profile.get_axis_affinity(FactionProfile.AXIS_MAGIC),
                f.profile.get_axis_affinity(FactionProfile.AXIS_NATURE),
                f.profile.get_axis_affinity(FactionProfile.AXIS_DIVINE),
                f.profile.get_axis_affinity(FactionProfile.AXIS_CORRUPTION)
            ])
            print("  Pers: aggr=%.2f veng=%.2f diplo=%.2f risk=%.2f expan=%.2f integ=%.2f" % [
                f.profile.get_personality(FactionProfile.PERS_AGGRESSION),
                f.profile.get_personality(FactionProfile.PERS_VENGEFULNESS),
                f.profile.get_personality(FactionProfile.PERS_DIPLOMACY),
                f.profile.get_personality(FactionProfile.PERS_RISK_AVERSION),
                f.profile.get_personality(FactionProfile.PERS_EXPANSIONISM),
                f.profile.get_personality(FactionProfile.PERS_INTEGRATIONISM)
            ])
    print("========================\n")
    
func print_all_factions() -> void:
    """Affiche toutes les factions (debug)"""
    print("\n=== FACTIONS ===")
    for f in get_all_factions():
        print("- %s : %d (%s)" % [f.name, f.relation_with_player, f.get_relation_status()])
    print("================\n")
