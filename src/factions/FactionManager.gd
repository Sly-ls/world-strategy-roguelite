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

# RNG pour génération reproductible
var _profile_rng: RandomNumberGenerator = RandomNumberGenerator.new()

# ========================================
# LIFECYCLE
# ========================================

func _ready() -> void:
    _profile_rng.seed = 42  # Seed fixe pour reproductibilité
    _init_default_factions()
    _init_relation_scores()
    print("✓ FactionManager initialisé avec %d factions" % factions.size())

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
    
    print("✓ Relations inter-factions initialisées")

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
        myLogger.error("faction not found : " + from_id)
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
        from_faction.relations[to_str] = score
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
    
    print("✓ État des factions chargé")

# ========================================
# DEBUG
# ========================================

func print_relation_scores() -> void:
    """Affiche les FactionRelationScore détaillés"""
    print("\n=== RELATION SCORES DÉTAILLÉS ===")
    for faction_id in factions.keys():
        var f: Faction = factions[faction_id]
        for to_id in f.relations.keys():
            var rs: FactionRelationScore = f.relations[to_id]
            print("- %s → %s : rel=%d trust=%d tension=%d" % [
                faction_id, to_id, rs.relation, rs.trust, rs.tension
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
    heat: int,
    seed: int = 0,
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
func generate_world(count: int, heat: int, seed: int = 0, params: Dictionary = {}) -> Array:
    generate_factions(count, heat, seed, params)
    initialize_relations_world(heat, seed + 1, params)
    return get_all_factions()


# -----------------------------------------
# Relations : init globale en 1 passe
# -----------------------------------------
func initialize_relations_world(heat: int = 1, seed: int = 0, params: Dictionary = {}) -> void:
    heat = clampi(heat, 1, 100)
    var h := float(heat) / 100.0

    var rng := RandomNumberGenerator.new()
    if seed != 0: rng.seed = seed
    else: rng.randomize()

    # --- Paramètres relationnels dérivés de heat (plus heat => plus friction/tension)
    var rel_params := {
        "w_axis_similarity": lerp(80.0, 75.0, h),
        "w_cross_conflict": lerp(50.0, 72.0, h),
        "w_personality_bias": lerp(22.0, 30.0, h),

        "friction_base": lerp(14.0, 24.0, h),
        "friction_from_opposition": lerp(58.0, 78.0, h),
        "friction_from_cross": lerp(50.0, 72.0, h),

        "tension_cap": lerp(28.0, 55.0, h)
    }
    # allow overrides
    for k in params.keys():
        if String(k).begins_with("rel_"):
            # ex: params["rel_tension_cap"]=45 -> rel_params["tension_cap"]=45
            rel_params[String(k).replace("rel_", "")] = params[k]

    var reciprocity := float(params.get("reciprocity", 0.70)) # 0..1
    var noise_sigma :float = lerp(4.0, 10.0, h)                    # petit bruit sur relation
    var enemies_k := clampi(1 + int(heat / 35), 1, 3)         # heat↑ => + d'ennemis naturels
    var allies_k := clampi(2 - int(heat / 70), 1, 2)          # heat↑ => - d'alliés naturels

    # store[A][B] = relation score object/dict
    var store := {}
    for a in get_all_factions():
        store[a.id] = {}

    for fa in get_all_factions():
        for fb in get_all_factions():
            if fa == fb: continue
            fa.init_relation(fb.id, rel_params)
            
            # relation noise (symétrique, borné)
            var delta = int(round(rng.randfn(0.0, noise_sigma)))
            fa.get_relation_to(fb.id).apply_delta_to(FactionRelationScore.REL_RELATION, delta)

    # --- 2) Center outgoing mean per faction (moyenne ~ 0)
    _center_outgoing_means(1.0)

    # --- 3) Add a few "natural enemies/allies" per faction (polarisation contrôlée)
    _apply_natural_extremes(enemies_k, allies_k, heat, rng)

    # --- 4) Re-center lightly to keep global coherence after extremes
    _center_outgoing_means(0.70)

    # --- 5) Apply "light reciprocity" (A->B and B->A converge ~70% sans être identiques)
    _apply_reciprocity(reciprocity, rng)



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
    if ClassDB.class_exists("FactionRelationScore"):
        var rs = ClassDB.instantiate("FactionRelationScore")
        # set common fields if present
        if _has_prop(rs, "other_faction_id"): rs.set("other_faction_id", other_id)
        if _has_prop(rs, "relation"): rs.set("relation", int(init["relation"]))
        if _has_prop(rs, "trust"): rs.set("trust", int(init["trust"]))
        if _has_prop(rs, "tension"): rs.set("tension", float(init["tension"]))
        if _has_prop(rs, "friction"): rs.set("friction", float(init["friction"]))
        if _has_prop(rs, "grievance"): rs.set("grievance", 0.0)
        if _has_prop(rs, "weariness"): rs.set("weariness", 0.0)
        if rs.has_method("clamp_all"):
            rs.call("clamp_all")
        return rs

    # fallback dict
    return {
        "other_faction_id": other_id,
        "relation": int(init["relation"]),
        "trust": int(init["trust"]),
        "tension": float(init["tension"]),
        "friction": float(init["friction"]),
        "grievance": 0.0,
        "weariness": 0.0
    }

func _center_outgoing_means(strength: float) -> void:
    var all_factions = get_all_factions()
    for fa in all_factions:
        var sum := 0.0
        var cnt := 0
        for fb in all_factions:
            if fa == fb: continue
            sum += fa.get_relation_to(fb.id).get_score(FactionRelationScore.REL_RELATION)
            cnt += 1
        if cnt <= 0: continue
        var mean := sum / float(cnt)

        for fb in all_factions:
            if fa == fb: continue
            var r := fa.get_relation_to(fb.id).get_score(FactionRelationScore.REL_RELATION)
            r = r - mean * strength
            fa.get_relation_to(fb.id).set_score(FactionRelationScore.REL_RELATION, r)


func _apply_natural_extremes(enemies_k: int, allies_k: int, heat: int, rng: RandomNumberGenerator) -> void:
    var h := float(heat) / 100.0
    var enemy_delta := int(round(lerp(10.0, 22.0, h)))
    var ally_delta := int(round(lerp(8.0, 18.0, h)))

    var all_factions = get_all_factions()
    for fa in all_factions:
        # rank others by current relation
        var others: Array = []
        for fb in all_factions:
            if fa == fb: continue
            var score_rel = fa.get_relation_to(fb.id).get_score(FactionRelationScore.REL_RELATION)
            others.append({"b": fb.id, "r": score_rel})

        others.sort_custom(func(x, y): return int(x["r"]) < int(y["r"])) # ascending

        # enemies: lowest relations
        for i in range(min(enemies_k, others.size())):
            var b: StringName = others[i]["b"]
            var relation_fa =  fa.get_relation_to(b)
            var score_rel = relation_fa.get_score(FactionRelationScore.REL_RELATION)
            var r :float = score_rel - enemy_delta - rng.randi_range(0, 4)
            relation_fa.set_score(FactionRelationScore.REL_RELATION, r)
            # tension a bit up too
            var score_tension = relation_fa.get_score(FactionRelationScore.REL_TENSION)
            var t :float = score_tension + lerp(2.0, 6.0, h)
            relation_fa.set_score(FactionRelationScore.REL_TENSION, t)

        # allies: highest relations
        for j in range(min(allies_k, others.size())):
            var idx := others.size() - 1 - j
            var b: StringName = others[idx]["b"]
            var relation_fa =  fa.get_relation_to(b)
            var score_rel = relation_fa.get_score(FactionRelationScore.REL_RELATION)
            var r :float = score_rel + ally_delta + rng.randi_range(0, 3)
            relation_fa.set_score(FactionRelationScore.REL_RELATION, r)
            # tension a bit down
            var score_tension = relation_fa.get_score(FactionRelationScore.REL_TENSION)
            var t :float = score_tension - lerp(1.0, 4.0, h)
            relation_fa.set_score(FactionRelationScore.REL_TENSION, t)


func _apply_reciprocity(r: float, rng: RandomNumberGenerator) -> void:
    r = clampf(r, 0.0, 1.0)
    var all_factions = get_all_factions()
    for i in range(all_factions.size()):
        for j in range(i + 1, all_factions.size()):
            var fa :Faction = all_factions[i]
            var fb :Faction = all_factions[j]

            var relation_fa =  fa.get_relation_to(fb.id)
            var relation_fb =  fb.get_relation_to(fa.id)
            # relation
            var rab := relation_fa.get_score(FactionRelationScore.REL_RELATION)
            var rba := relation_fb.get_score(FactionRelationScore.REL_RELATION)
            var m := (rab + rba) / 2.0
            rab = lerp(rab, m, r)
            rba = lerp(rba, m, r)

            # tiny asym jitter so they're not identical
            var jitter := rng.randf_range(-2.0, 2.0) * (1.0 - r)
            rab += jitter
            rba -= jitter
            relation_fa.apply_delta_to(FactionRelationScore.REL_RELATION, jitter)
            relation_fb.apply_delta_to(FactionRelationScore.REL_RELATION, -jitter)

            # trust (same approach)
            
            var tab := relation_fa.get_score(FactionRelationScore.REL_TRUST)
            var tba := relation_fb.get_score(FactionRelationScore.REL_TRUST)
            var mt := (tab + tba) / 2.0
            tab = lerp(tab, mt, r)
            tba = lerp(tba, mt, r)
            relation_fa.set_score(FactionRelationScore.REL_TRUST, tab)
            relation_fb.set_score(FactionRelationScore.REL_TRUST, tba)

            # tension (float)
            var ten_ab := relation_fa.get_score(FactionRelationScore.REL_TENSION)
            var ten_ba := relation_fb.get_score(FactionRelationScore.REL_TENSION)
            var mt2 := (ten_ab + ten_ba) / 2.0
            ten_ab = lerp(ten_ab, mt2, r)
            ten_ba = lerp(ten_ba, mt2, r)
            relation_fa.set_score(FactionRelationScore.REL_TRUST, ten_ab)
            relation_fb.set_score(FactionRelationScore.REL_TRUST, ten_ba)
