# res://src/factions/FactionManager.gd
extends Node
class_name FactionManagerClass 

## Gestionnaire global des factions
## NOUVEAU : Créé par Claude (manquait chez ChatGPT)
## MODIFIÉ : Relations maintenant stockées dans Faction.relations

# ========================================
# SIGNAUX
# ========================================

signal faction_relation_changed(faction_id: String, old_value: int, new_value: int)
signal faction_status_changed(faction_id: String, old_status: String, new_status: String)

# ========================================
# PROPRIÉTÉS
# ========================================
var factions: Dictionary = {}  ## id -> Faction
var pair_states: Dictionary[StringName, FactionPairState]
# RNG pour génération reproductible
var _profile_rng: RandomNumberGenerator = RandomNumberGenerator.new()

# ========================================
# LIFECYCLE
# ========================================

func _ready() -> void:
    _profile_rng.seed = 42  # Seed fixe pour reproductibilité
    _init_default_factions()
    _init_relation_scores()
    myLogger.debug("✓ FactionManager initialisé avec %d factions" % factions.size(), LogTypes.Domain.ARC)

func reset():
    factions.clear()
    
func _init_default_factions() -> void:
    """Initialise les factions par défaut"""
    # Factions humaines
    var humans := register_faction_with_params(
        "humans", "Royaume des Hommes",
        "Le plus grand royaume humain",
        8, Faction.FactionType.FRIENDLY
    )
    humans.profile = _create_human_profile()
    
    var elves := register_faction_with_params(
        "elves", "Conclave Elfique",
        "Les anciens gardiens de la forêt",
        6, Faction.FactionType.MAGICAL
    )
    elves.profile = _create_elf_profile()
    
    # Factions hostiles
    var orcs := register_faction_with_params(
        "orcs", "Horde Orc",
        "Une coalition de tribus guerrières",
        7, Faction.FactionType.HOSTILE
    )
    orcs.profile = _create_orc_profile()
    
    var bandits := register_faction_with_params(
        "bandits", "Confrérie des Ombres",
        "Un réseau de brigands et de voleurs",
        4, Faction.FactionType.HOSTILE
    )
    bandits.profile = _create_bandit_profile()
    
    # Factions neutres
    var merchants := register_faction_with_params(
        "merchants", "Guilde des Marchands",
        "Une puissante guilde commerciale",
        5, Faction.FactionType.TRADER
    )
    merchants.profile = _create_merchant_profile()


func _create_human_profile() -> FactionProfile:
    var profile := FactionProfile.new()
    
    # Humans: balanced, slight tech/divine lean
    profile.set_axis_affinity(FactionProfile.AXIS_TECH, 60)
    profile.set_axis_affinity(FactionProfile.AXIS_MAGIC, 30)
    profile.set_axis_affinity(FactionProfile.AXIS_NATURE, 40)
    profile.set_axis_affinity(FactionProfile.AXIS_DIVINE, 55)
    profile.set_axis_affinity(FactionProfile.AXIS_CORRUPTION, 10)
    
    # Personality: diplomatic, honorable
    profile.set_personality(FactionProfile.PERS_AGGRESSION, 0.4)
    profile.set_personality(FactionProfile.PERS_VENGEFULNESS, 0.5)
    profile.set_personality(FactionProfile.PERS_DIPLOMACY, 0.7)
    profile.set_personality(FactionProfile.PERS_RISK_AVERSION, 0.5)
    profile.set_personality(FactionProfile.PERS_EXPANSIONISM, 0.6)
    profile.set_personality(FactionProfile.PERS_INTEGRATIONISM, 0.6)
    profile.set_personality(FactionProfile.PERS_HONOR, 0.7)
    profile.set_personality(FactionProfile.PERS_CUNNING, 0.4)
    
    return profile


func _create_elf_profile() -> FactionProfile:
    var profile := FactionProfile.new()
    
    # Elves: magic/nature focused
    profile.set_axis_affinity(FactionProfile.AXIS_TECH, 20)
    profile.set_axis_affinity(FactionProfile.AXIS_MAGIC, 80)
    profile.set_axis_affinity(FactionProfile.AXIS_NATURE, 85)
    profile.set_axis_affinity(FactionProfile.AXIS_DIVINE, 50)
    profile.set_axis_affinity(FactionProfile.AXIS_CORRUPTION, 5)
    
    # Personality: isolationist, honorable
    profile.set_personality(FactionProfile.PERS_AGGRESSION, 0.2)
    profile.set_personality(FactionProfile.PERS_VENGEFULNESS, 0.6)
    profile.set_personality(FactionProfile.PERS_DIPLOMACY, 0.5)
    profile.set_personality(FactionProfile.PERS_RISK_AVERSION, 0.7)
    profile.set_personality(FactionProfile.PERS_EXPANSIONISM, 0.2)
    profile.set_personality(FactionProfile.PERS_INTEGRATIONISM, 0.3)
    profile.set_personality(FactionProfile.PERS_HONOR, 0.8)
    profile.set_personality(FactionProfile.PERS_CUNNING, 0.5)
    
    return profile


func _create_orc_profile() -> FactionProfile:
    var profile := FactionProfile.new()
    
    # Orcs: aggressive, tech-averse
    profile.set_axis_affinity(FactionProfile.AXIS_TECH, 25)
    profile.set_axis_affinity(FactionProfile.AXIS_MAGIC, 30)
    profile.set_axis_affinity(FactionProfile.AXIS_NATURE, 50)
    profile.set_axis_affinity(FactionProfile.AXIS_DIVINE, 35)
    profile.set_axis_affinity(FactionProfile.AXIS_CORRUPTION, 40)
    
    # Personality: aggressive, expansionist
    profile.set_personality(FactionProfile.PERS_AGGRESSION, 0.85)
    profile.set_personality(FactionProfile.PERS_VENGEFULNESS, 0.8)
    profile.set_personality(FactionProfile.PERS_DIPLOMACY, 0.2)
    profile.set_personality(FactionProfile.PERS_RISK_AVERSION, 0.2)
    profile.set_personality(FactionProfile.PERS_EXPANSIONISM, 0.9)
    profile.set_personality(FactionProfile.PERS_INTEGRATIONISM, 0.1)
    profile.set_personality(FactionProfile.PERS_HONOR, 0.4)
    profile.set_personality(FactionProfile.PERS_CUNNING, 0.3)
    
    return profile


func _create_bandit_profile() -> FactionProfile:
    var profile := FactionProfile.new()
    
    # Bandits: opportunistic
    profile.set_axis_affinity(FactionProfile.AXIS_TECH, 40)
    profile.set_axis_affinity(FactionProfile.AXIS_MAGIC, 20)
    profile.set_axis_affinity(FactionProfile.AXIS_NATURE, 30)
    profile.set_axis_affinity(FactionProfile.AXIS_DIVINE, 10)
    profile.set_axis_affinity(FactionProfile.AXIS_CORRUPTION, 60)
    
    # Personality: cunning, dishonorable
    profile.set_personality(FactionProfile.PERS_AGGRESSION, 0.6)
    profile.set_personality(FactionProfile.PERS_VENGEFULNESS, 0.4)
    profile.set_personality(FactionProfile.PERS_DIPLOMACY, 0.3)
    profile.set_personality(FactionProfile.PERS_RISK_AVERSION, 0.4)
    profile.set_personality(FactionProfile.PERS_EXPANSIONISM, 0.5)
    profile.set_personality(FactionProfile.PERS_INTEGRATIONISM, 0.2)
    profile.set_personality(FactionProfile.PERS_HONOR, 0.1)
    profile.set_personality(FactionProfile.PERS_CUNNING, 0.9)
    
    return profile


func _create_merchant_profile() -> FactionProfile:
    var profile := FactionProfile.new()
    
    # Merchants: pragmatic, diplomatic
    profile.set_axis_affinity(FactionProfile.AXIS_TECH, 70)
    profile.set_axis_affinity(FactionProfile.AXIS_MAGIC, 40)
    profile.set_axis_affinity(FactionProfile.AXIS_NATURE, 30)
    profile.set_axis_affinity(FactionProfile.AXIS_DIVINE, 35)
    profile.set_axis_affinity(FactionProfile.AXIS_CORRUPTION, 25)
    
    # Personality: diplomatic, opportunistic
    profile.set_personality(FactionProfile.PERS_AGGRESSION, 0.2)
    profile.set_personality(FactionProfile.PERS_VENGEFULNESS, 0.3)
    profile.set_personality(FactionProfile.PERS_DIPLOMACY, 0.85)
    profile.set_personality(FactionProfile.PERS_RISK_AVERSION, 0.6)
    profile.set_personality(FactionProfile.PERS_EXPANSIONISM, 0.7)
    profile.set_personality(FactionProfile.PERS_INTEGRATIONISM, 0.8)
    profile.set_personality(FactionProfile.PERS_HONOR, 0.5)
    profile.set_personality(FactionProfile.PERS_CUNNING, 0.7)
    
    return profile

    
func _init_relation_scores() -> void:
    """Initialise les FactionRelationScore entre toutes les factions basé sur leurs profils"""
    var faction_ids := factions.keys()
    
    for from_id in faction_ids:
        var from_faction: Faction = factions[from_id]
        
        for to_id in faction_ids:
            if from_id == to_id:
                continue
            from_faction.init_relation(to_id)
    
    myLogger.debug("✓ Relations inter-factions initialisées", LogTypes.Domain.ARC)

# ========================================
# GESTION DES FACTIONS
# ========================================

func register_faction_with_params(
    p_id: String,
    p_name: String,
    p_description: String,
    p_power: int,
    p_type: Faction.FactionType
) -> Faction:
    """Enregistre une nouvelle faction"""
    
    var f := Faction.new()
    f.id = p_id
    f.name = p_name
    f.description = p_description
    # TODO: relation_with_player migré avec factions mineures/armées libres
    #f.relation_with_player = p_relation
    f.power_level = p_power
    f.faction_type = p_type
    return register_faction(f)

func register_faction(
    faction: Faction,
) -> Faction:
    """Enregistre une nouvelle faction"""
    factions[faction.id] = faction
    return faction

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
# Méthodes d'accès centralisées - délèguent à Faction.relations
# ========================================

func get_relation(from_id, to_id) -> FactionRelationScore:
    """Récupère le FactionRelationScore de from_id vers to_id"""
    var from_faction := get_faction(from_id)
    if from_faction == null:
        # Créer un score neutre si la faction n'existe pas
        myLogger.error("faction not found : %s" % from_id, LogTypes.Domain.ARC)
        return null
    else :
        return from_faction.get_relation_to(to_id)
   


func get_relation_score(score_name: StringName, from_id, to_id) -> float:
    """Récupère le FactionRelationScore de from_id vers to_id"""
    var faction_from :Faction = FactionManager.get_faction(from_id)
    var rel : FactionRelationScore = faction_from.get_relation_to(to_id)
    return rel.get_score(score_name)
    
func get_all_relations() -> Dictionary:
    """Retourne le dictionnaire complet des relations (format: from_id -> { to_id -> FactionRelationScore })"""
    var result: Dictionary = {}
    for faction_id in factions.keys():
        var f: Faction = factions[faction_id]
        result[faction_id] = f.relations.duplicate()
    return result


func get_all_relations_for(faction_id: String) -> Dictionary:
    """Retourne toutes les relations d'une faction vers les autres"""
    var f := get_faction(faction_id)
    if f != null:
        return f.relations
    return {}


func set_relation(from_id, to_id, score: FactionRelationScore) -> void:
    """Définit le FactionRelationScore de from_id vers to_id"""
    var from_str := str(from_id)
    var to_str := str(to_id)
    
    var from_faction := get_faction(from_str)
    if from_faction != null:
        from_faction.relations[to_str] = score

func set_relation_score(from_id, to_id, score_name: StringName, score: int) -> void:
    """Définit le FactionRelationScore de from_id vers to_id"""
    var from_str := str(from_id)
    var to_str := str(to_id)
    
    var from_faction := get_faction(from_str)
    if from_faction != null:
        from_faction.get_relation_to(to_str).set_score(score_name, score)
# ========================================
# RELATIONS (avec le joueur)
# TODO: doit être migré avec les factions mineures et les armées libres
# ========================================

#func adjust_relation(faction_id: String, delta: int) -> void:
#	"""Ajuste la relation avec une faction"""
#	var f := get_faction(faction_id)
#	if f == null:
#		print("FactionManager: faction '%s' introuvable" % faction_id)
#		return
#	
#	var old_value := f.relation_with_player
#	var old_status := f.get_relation_status()
#	
#	f.adjust_relation(delta)
#	
#	var new_value := f.relation_with_player
#	var new_status := f.get_relation_status()
#	
#	# Signaux
#	faction_relation_changed.emit(faction_id, old_value, new_value)
#	
#	if old_status != new_status:
#		faction_status_changed.emit(faction_id, old_status, new_status)
#	
#	# Log
#	var sign := "+" if delta >= 0 else ""
#	print("→ Relation avec %s : %s%d (total: %d - %s)" % [
#		f.name,
#		sign,
#		delta,
#		f.relation_with_player,
#		f.get_relation_status()
#	])


#func get_relation(faction_id: String) -> int:
#	"""Obtient la relation avec une faction"""
#	var f := get_faction(faction_id)
#	return f.relation_with_player if f else 0


#func get_relation_status(faction_id: String) -> String:
#	"""Obtient le statut de relation avec une faction"""
#	var f := get_faction(faction_id)
#	return f.get_relation_status() if f else "Inconnu"

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


# TODO: get_allies, get_enemies, get_neutral - doit être migré avec factions mineures/armées libres
#func get_allies() -> Array[Faction]:
#	"""Retourne les factions alliées"""
#	var result: Array[Faction] = []
#	for f in factions.values():
#		if f.is_ally():
#			result.append(f)
#	return result


#func get_enemies() -> Array[Faction]:
#	"""Retourne les factions ennemies"""
#	var result: Array[Faction] = []
#	for f in factions.values():
#		if f.is_enemy():
#			result.append(f)
#	return result


#func get_neutral() -> Array[Faction]:
#	"""Retourne les factions neutres"""
#	var result: Array[Faction] = []
#	for f in factions.values():
#		if f.is_neutral():
#			result.append(f)
#	return result

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
    
    myLogger.debug("✓ État des factions chargé", LogTypes.Domain.ARC)

# ========================================
# DEBUG
# ========================================

func print_relation_scores() -> void:
    """Affiche les FactionRelationScore détaillés"""
    myLogger.debug("=== RELATION SCORES DÉTAILLÉS ===", LogTypes.Domain.ARC)
    for faction_id in factions.keys():
        var f: Faction = factions[faction_id]
        for to_id in f.relations.keys():
            var rs: FactionRelationScore = f.relations[to_id]
            myLogger.debug("- %s → %s : rel=%d trust=%d tension=%d" % [
                faction_id, to_id, rs.relation, rs.trust, rs.tension
            ], LogTypes.Domain.ARC)
    myLogger.debug("=================================", LogTypes.Domain.ARC)


func print_faction_profiles() -> void:
    """Affiche les profils de faction"""
    myLogger.debug("=== FACTION PROFILES ===", LogTypes.Domain.ARC)
    for id in factions.keys():
        var f: Faction = factions[id]
        if f.profile != null:
            myLogger.debug("- %s:" % id, LogTypes.Domain.ARC)
            myLogger.debug("  Axes: tech=%d magic=%d nature=%d divine=%d corr=%d" % [
                f.profile.get_axis_affinity(FactionProfile.AXIS_TECH),
                f.profile.get_axis_affinity(FactionProfile.AXIS_MAGIC),
                f.profile.get_axis_affinity(FactionProfile.AXIS_NATURE),
                f.profile.get_axis_affinity(FactionProfile.AXIS_DIVINE),
                f.profile.get_axis_affinity(FactionProfile.AXIS_CORRUPTION)
            ], LogTypes.Domain.ARC)
            myLogger.debug("  Pers: aggr=%.2f veng=%.2f diplo=%.2f risk=%.2f expan=%.2f integ=%.2f" % [
                f.profile.get_personality(FactionProfile.PERS_AGGRESSION),
                f.profile.get_personality(FactionProfile.PERS_VENGEFULNESS),
                f.profile.get_personality(FactionProfile.PERS_DIPLOMACY),
                f.profile.get_personality(FactionProfile.PERS_RISK_AVERSION),
                f.profile.get_personality(FactionProfile.PERS_EXPANSIONISM),
                f.profile.get_personality(FactionProfile.PERS_INTEGRATIONISM)
            ], LogTypes.Domain.ARC)
    myLogger.debug("========================", LogTypes.Domain.ARC)
    

# TODO: print_all_factions - doit être migré avec factions mineures/armées libres
#func print_all_factions() -> void:
#	"""Affiche toutes les factions (debug)"""
#	print("\n=== FACTIONS ===")
#	for f in get_all_factions():
#		print("- %s : %d (%s)" % [f.name, f.relation_with_player, f.get_relation_status()])
#	print("================\n")

# -------------------------
# Public API
# -------------------------

func generate_faction(
    faction_id: StringName,
    rng: RandomNumberGenerator,
    heat: int,
    params: Dictionary = {},
    against_faction = null # Faction optionnelle (pour créer un antagoniste)
):
    heat = clampi(heat, 1, 100)

    var gen_type := _gen_type_from_heat(heat, rng)
    var antagonism_strength :float = lerp(1.0, 1.55, float(heat) / 100.0)

    var profile_params := _profile_params_from_heat(heat, params)

    var against_profile = null
    if against_faction != null and against_faction.has_method("get") and against_faction.get("profile") != null:
        against_profile = against_faction.get("profile")

    var profile: FactionProfile = FactionProfile.generate_full_profile(
        rng,
        gen_type,
        profile_params,
        &"",                 # force_against_axis (optionnel)
        against_profile,     # against_faction_profile (optionnel)
        antagonism_strength
    )

    # Biais "heat" sur la personnalité => plus de friction/conflits quand heat monte
    _apply_heat_bias_to_personality(profile, heat, rng)

    # Crée ta faction (adapte selon ta classe Faction)
    var f = _new_faction_object()
    f.set("id", faction_id)
    f.set("profile", profile)
    register_faction(f)
    return f


func generate_factions(
    count: int,
    heat: int = 1,
    seed: int = 123456789,
    params: Dictionary = {}
) -> Array:
    heat = clampi(heat, 1, 100)

    var rng := RandomNumberGenerator.new()
    if seed != 0:
        rng.seed = seed
    else:
        rng.randomize()

    var created: Array = []

    for i in range(count):
        var id: StringName = StringName("f_%03d" % i)

        # plus heat est haut, plus on force des antagonistes "naturels"
        var p_ant := clampf((float(heat) - 15.0) / 85.0, 0.0, 1.0) * 0.75
        var against = null
        if created.size() > 0 and rng.randf() < p_ant:
            against = created[rng.randi_range(0, created.size() - 1)]

        var f = generate_faction(id, rng, heat, params, against)
        created.append(f)

    return created


# -------------------------
# Internal helpers
# -------------------------

func _gen_type_from_heat(heat: int, rng: RandomNumberGenerator) -> StringName:
    # heat faible => centered ; heat moyen => normal ; heat fort => dramatic
    var h := float(heat) / 100.0
    if h < 0.3:
        return FactionProfile.GEN_CENTERED
    elif h > 0.7:
        return FactionProfile.GEN_DRAMATIC

    # zone milieu : mix (évite un monde trop homogène)
    return FactionProfile.GEN_DRAMATIC if rng.randf() < (h - 0.33) / 0.33 else FactionProfile.GEN_NORMAL


func _profile_params_from_heat(heat: int, user_params: Dictionary) -> Dictionary:
    var h := float(heat) / 100.0

    # cohérence plus forte quand heat monte (identités plus nettes => relations plus polarisées)
    var coherence :float = lerp(0.55, 0.85, h)

    # plus heat monte, plus on "autorise" le mode antagoniste à être marqué
    var antagonist_blend :float = lerp(0.10, 0.28, h)

    var p := {
        "coherence_strength": coherence,
        "antagonist_personality_blend": antagonist_blend,
        "antagonist_force_dominant_axis": true,
        "anti_magic_enabled": true
    }

    # allow overrides
    for k in user_params.keys():
        p[k] = user_params[k]
    return p


func _apply_heat_bias_to_personality(profile: FactionProfile, heat: int, rng: RandomNumberGenerator) -> void:
    var h := float(heat) / 100.0
    # petit jitter pour ne pas faire "toutes identiques"
    var j := rng.randf_range(-0.04, 0.04)

    # Heat => +aggression +vengefulness +expansionism, -diplomacy -integrationism, -risk_aversion
    # (ça augmente friction et diminue relation dans compute_baseline_relation)
    profile.set_personality(FactionProfile.PERS_AGGRESSION,
        profile.get_personality(FactionProfile.PERS_AGGRESSION) + 0.22*h + j)
    profile.set_personality(FactionProfile.PERS_VENGEFULNESS,
        profile.get_personality(FactionProfile.PERS_VENGEFULNESS) + 0.18*h + j)
    profile.set_personality(FactionProfile.PERS_EXPANSIONISM,
        profile.get_personality(FactionProfile.PERS_EXPANSIONISM) + 0.16*h + j)

    profile.set_personality(FactionProfile.PERS_DIPLOMACY,
        profile.get_personality(FactionProfile.PERS_DIPLOMACY) - 0.18*h + j)
    profile.set_personality(FactionProfile.PERS_INTEGRATIONISM,
        profile.get_personality(FactionProfile.PERS_INTEGRATIONISM) - 0.12*h + j)
    profile.set_personality(FactionProfile.PERS_RISK_AVERSION,
        profile.get_personality(FactionProfile.PERS_RISK_AVERSION) - 0.10*h + j)


func _new_faction_object():
    # Adapte selon ta classe réelle.
    # Si tu as class_name Faction, remplace par: return Faction.new()
    var f := Faction.new()
    return f

# -----------------------------------------
# API high-level : monde complet
# -----------------------------------------
func generate_world(count: int, heat: int=1, seed: int = 123456789, params: Dictionary = {}) -> Array:
    generate_factions(count, heat, seed, params)
    FactionRelationsUtil.initialize_relations_world(heat, seed + 1, params)
    return get_all_factions()


# -----------------------------------------
# Relations : init globale en 1 passe
# -----------------------------------------

# -----------------------------------------
# Helpers (non invasifs)
# -----------------------------------------
func _set_relations_dict_on_faction(faction_obj, rel_dict: Dictionary) -> void:
    # Utiliser directement Faction.relations
    if faction_obj is Faction:
        faction_obj.relations = rel_dict
    elif _has_prop(faction_obj, "relations"):
        faction_obj.set("relations", rel_dict)
    else:
        # fallback: on l'attache quand même
        faction_obj.set("relations", rel_dict)


func _has_prop(obj: Object, prop: String) -> bool:
    for p in obj.get_property_list():
        if p.name == prop:
            return true
    return false


func _make_relation_score(other_id: StringName, init: Dictionary):
    # init keys: relation(int), friction(float), trust(int), tension(float)
    
    var rs = FactionRelationScore.new(other_id)
    rs.init(init)
    return rs

func daily_decay() -> void:
    var base_tension_decay := 0.9
    var base_griev_decay := 0.6
    var base_wear_decay := 0.35

    for faction in get_all_factions():
        var diplo := faction.profile.get_personality(FactionProfile.PERS_DIPLOMACY)
        var veng := faction.profile.get_personality(FactionProfile.PERS_VENGEFULNESS)

        var tension_mul := 0.70 + 0.80 * diplo
        var griev_mul := 0.55 + 0.90 * (1.0 - veng)

        var map_rel: Dictionary = faction.get_all_relations()
        for target_id: StringName in map_rel.keys():
            var rel: FactionRelationScore = map_rel[target_id]
            var tension_score := rel.get_score(FactionRelationScore.REL_TENSION)
            var grievance_score := rel.get_score(FactionRelationScore.REL_GRIEVANCE)
            var weariness_score := rel.get_score(FactionRelationScore.REL_WEARINESS)
            var tension_new = max(0.0, tension_score - base_tension_decay * tension_mul)
            var grievance_new = max(0.0, grievance_score - base_griev_decay * griev_mul)
            var weariness_new = max(0.0, weariness_score - base_wear_decay)
            rel.set_score(FactionRelationScore.REL_TENSION, tension_new)
            rel.set_score(FactionRelationScore.REL_GRIEVANCE, grievance_new)
            rel.set_score(FactionRelationScore.REL_WEARINESS, weariness_new)

# ========================================
# PAIR STATES - Sérialisation
# ========================================

## Récupère l'état de paire entre deux factions
## Crée un nouvel état NEUTRAL si la paire n'existe pas
func get_pair_state(a, b) -> FactionPairState:
    var key := Utils.pair_key(a, b)
    if not pair_states.has(key):
        pair_states[key] = FactionPairState.new(StringName(str(a)), StringName(str(b)))
    return pair_states[key]

## Vérifie si un état de paire existe (sans le créer)
func has_pair_state(a, b) -> bool:
    return pair_states.has(Utils.pair_key(a, b))

## Définit l'état de paire (remplace l'existant)
func set_pair_state(a, b, state: FactionPairState) -> void:
    var key := Utils.pair_key(a, b)
    pair_states[key] = state

## Supprime l'état de paire (revient à l'état par défaut)
func remove_pair_state(a, b) -> void:
    var key := Utils.pair_key(a, b)
    pair_states.erase(key)

## Récupère tous les états de paire
func get_all_pair_states() -> Dictionary:
    return pair_states.duplicate()

# ========================================
# PAIR STATES - Queries de haut niveau
# ========================================

## Vérifie si deux factions sont en guerre
func are_at_war(a, b) -> bool:
    if not has_pair_state(a, b):
        return false
    return get_pair_state(a, b).is_at_war()

## Vérifie si deux factions sont alliées
func are_allied(a, b) -> bool:
    if not has_pair_state(a, b):
        return false
    return get_pair_state(a, b).is_allied()

## Vérifie si deux factions sont en trêve
func are_in_truce(a, b) -> bool:
    if not has_pair_state(a, b):
        return false
    return get_pair_state(a, b).is_in_truce()

## Vérifie si deux factions sont en conflit (hostile mais pas en guerre)
func are_in_conflict(a, b) -> bool:
    if not has_pair_state(a, b):
        return false
    var ps := get_pair_state(a, b)
    return ps.state == FactionPairState.S_CONFLICT or ps.state == FactionPairState.S_RIVALRY

## Vérifie si deux factions ont une relation hostile
func are_hostile(a, b) -> bool:
    if not has_pair_state(a, b):
        return false
    return get_pair_state(a, b).is_hostile()

## Vérifie si deux factions ont une relation pacifique
func are_peaceful(a, b) -> bool:
    if not has_pair_state(a, b):
        return true  # Par défaut, les factions sont neutres/pacifiques
    return get_pair_state(a, b).is_peaceful()

# ========================================
# PAIR STATES - Queries par faction
# ========================================

## Récupère tous les états de paire impliquant une faction
func get_pair_states_for(faction_id) -> Array[FactionPairState]:
    var result: Array[FactionPairState] = []
    var fid := StringName(str(faction_id))
    for ps in pair_states.values():
        if ps.involves(fid):
            result.append(ps)
    return result

## Récupère toutes les factions en guerre avec une faction donnée
func get_war_enemies(faction_id) -> Array[StringName]:
    var result: Array[StringName] = []
    var fid := StringName(str(faction_id))
    for ps in pair_states.values():
        if ps.involves(fid) and ps.is_at_war():
            result.append(ps.get_other(fid))
    return result

## Récupère toutes les factions alliées avec une faction donnée
func get_war_allies(faction_id) -> Array[StringName]:
    var result: Array[StringName] = []
    var fid := StringName(str(faction_id))
    for ps in pair_states.values():
        if ps.involves(fid) and ps.is_allied():
            result.append(ps.get_other(fid))
    return result

## Récupère toutes les factions en conflit avec une faction donnée (RIVALRY ou CONFLICT)
func get_rivals(faction_id) -> Array[StringName]:
    var result: Array[StringName] = []
    var fid := StringName(str(faction_id))
    for ps in pair_states.values():
        if ps.involves(fid) and ps.is_hostile() and not ps.is_at_war():
            result.append(ps.get_other(fid))
    return result

## Compte le nombre de guerres actives pour une faction
func count_active_wars(faction_id) -> int:
    return get_war_enemies(faction_id).size()

## Compte le nombre d'alliances actives pour une faction
func count_active_alliances(faction_id) -> int:
    return get_war_allies(faction_id).size()

# ========================================
# PAIR STATES - Mise à jour
# ========================================

## Met à jour l'état de paire après un événement
## Utilise FactionPairStateMachine pour les transitions
func update_pair_state(
    a, b, 
    day: int, 
    rng: RandomNumberGenerator, 
    action: StringName = &"",
    choice: StringName = &""
) -> bool:
    var ps := get_pair_state(a, b)
    var rel_ab := get_relation(a, b)
    var rel_ba := get_relation(b, a)
    
    if rel_ab == null or rel_ba == null:
        return false
    
    return FactionPairStateMachine.update_state(ps, rel_ab, rel_ba, day, rng, action, choice)

## Mise à jour quotidienne des compteurs de stabilité pour toutes les paires
func tick_day_all_pairs() -> void:
    for key in pair_states.keys():
        var ps: FactionPairState = pair_states[key]
        var rel_ab := get_relation(ps.a_id, ps.b_id)
        var rel_ba := get_relation(ps.b_id, ps.a_id)
        
        if rel_ab != null and rel_ba != null:
            FactionPairStateMachine.tick_day(ps, rel_ab, rel_ba)

## Force un état sur une paire (bypass les conditions normales)
func force_pair_state(
    a, b,
    new_state: StringName,
    day: int,
    lock_days: int = 7,
    reason: StringName = &""
) -> void:
    var ps := get_pair_state(a, b)
    FactionPairStateMachine.force_state(ps, new_state, day, lock_days, reason)

# ========================================
# PAIR STATES - Sérialisation
# ========================================

## Sérialise tous les états de paire pour sauvegarde
func save_pair_states() -> Dictionary:
    var result: Dictionary = {}
    for key in pair_states.keys():
        var ps: FactionPairState = pair_states[key]
        result[String(key)] = ps.to_dict()
    return result

## Charge les états de paire depuis une sauvegarde
func load_pair_states(data: Dictionary) -> void:
    pair_states.clear()
    for key in data.keys():
        var ps := FactionPairState.from_dict(data[key])
        pair_states[StringName(key)] = ps

# ========================================
# PAIR STATES - Debug
# ========================================

## Affiche un résumé de tous les états de paire
func debug_print_pair_states() -> void:
    myLogger.debug("=== Pair States (%d) ===" % pair_states.size(), LogTypes.Domain.ARC)
    for key in pair_states.keys():
        var ps: FactionPairState = pair_states[key]
        myLogger.debug("  %s: %s (day %d)" % [key, ps.state, ps.entered_day], LogTypes.Domain.ARC)
    myLogger.debug("=== End Pair States ===", LogTypes.Domain.ARC)
