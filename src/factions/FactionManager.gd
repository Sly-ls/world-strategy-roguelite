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

    # Biais “heat” sur la personnalité => plus de friction/conflits quand heat monte
    _apply_heat_bias_to_personality(profile, heat, rng)

    # Crée ta faction (adapte selon ta classe Faction)
    var f = _new_faction_object()
    f.set("id", faction_id)
    f.set("profile", profile)

    factions[faction_id] = f
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

        # plus heat est haut, plus on force des antagonistes “naturels”
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

    # plus heat monte, plus on “autorise” le mode antagoniste à être marqué
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
    # petit jitter pour ne pas faire “toutes identiques”
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
    var factions_generated := generate_factions(count, heat, seed, params)
    initialize_relations_world(factions_generated, heat, seed + 1, params)
    return factions_generated


# -----------------------------------------
# Relations : init globale en 1 passe
# -----------------------------------------
func initialize_relations_world(factions_generated: Array, heat: int, seed: int = 0, params: Dictionary = {}) -> void:
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
    var enemies_k := clampi(1 + int(heat / 35), 1, 3)         # heat↑ => + d’ennemis naturels
    var allies_k := clampi(2 - int(heat / 70), 1, 2)          # heat↑ => - d’alliés naturels

    # --- 1) Build matrix A->B brute
    var ids: Array[StringName] = []
    for f in factions_generated:
        var id: StringName = f.get("id")
        ids.append(id)

    # store[A][B] = relation score object/dict
    var store := {}
    for a in ids:
        store[a] = {}

    for a in ids:
        var fa = factions.get(a, null)
        if fa == null: fa = _find_faction_in_array(factions_generated, a)
        var pa: FactionProfile = fa.get("profile")

        for b in ids:
            if a == b: continue
            var fb = factions.get(b, null)
            if fb == null: fb = _find_faction_in_array(factions_generated, b)
            var pb: FactionProfile = fb.get("profile")

            var init := FactionProfile.compute_baseline_relation(pa, pb, rel_params)
            # relation noise (symétrique, borné)
            var r := int(init["relation"]) + int(round(rng.randfn(0.0, noise_sigma)))
            init["relation"] = clampi(r, -100, 100)

            store[a][b] = _make_relation_score(b, init)

    # --- 2) Center outgoing mean per faction (moyenne ~ 0)
    _center_outgoing_means(store, ids, 1.0)

    # --- 3) Add a few “natural enemies/allies” per faction (polarisation contrôlée)
    _apply_natural_extremes(store, ids, enemies_k, allies_k, heat, rng)

    # --- 4) Re-center lightly to keep global coherence after extremes
    _center_outgoing_means(store, ids, 0.70)

    # --- 5) Apply “light reciprocity” (A->B and B->A converge ~70% sans être identiques)
    _apply_reciprocity(store, ids, reciprocity, rng)

    # --- 6) Commit to factions (store per faction)
    for a in ids:
        var fa = factions.get(a, null)
        if fa == null: fa = _find_faction_in_array(factions_generated, a)
        _set_relations_dict_on_faction(fa, store[a])


# -----------------------------------------
# Helpers (non invasifs)
# -----------------------------------------
func _find_faction_in_array(factions: Array, id: StringName):
    for f in factions:
        if f.get("id") == id:
            return f
    return null

func _set_relations_dict_on_faction(faction_obj, rel_dict: Dictionary) -> void:
    # essaie plusieurs noms de champ possibles
    if _has_prop(faction_obj, "relations_by_faction_id"):
        faction_obj.set("relations_by_faction_id", rel_dict)
    elif _has_prop(faction_obj, "relations"):
        faction_obj.set("relations", rel_dict)
    else:
        # fallback: on l'attache quand même
        faction_obj.set("relations_by_faction_id", rel_dict)

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

func _get_rel_value(rel, key: String, default_val):
    if rel is Dictionary:
        return rel.get(key, default_val)
    return rel.get(key, default_val)

func _set_rel_value(rel, key: String, value) -> void:
    if rel is Dictionary:
        rel[key] = value
    else:
        rel.set(key, value)

func _center_outgoing_means(store: Dictionary, ids: Array[StringName], strength: float) -> void:
    for a in ids:
        var sum := 0.0
        var cnt := 0
        for b in ids:
            if a == b: continue
            var rel = store[a][b]
            sum += float(_get_rel_value(rel, "relation", 0))
            cnt += 1
        if cnt <= 0: continue
        var mean := sum / float(cnt)

        for b in ids:
            if a == b: continue
            var rel = store[a][b]
            var r := float(_get_rel_value(rel, "relation", 0))
            r = r - mean * strength
            _set_rel_value(rel, "relation", clampi(int(round(r)), -100, 100))

func _apply_natural_extremes(store: Dictionary, ids: Array[StringName], enemies_k: int, allies_k: int, heat: int, rng: RandomNumberGenerator) -> void:
    var h := float(heat) / 100.0
    var enemy_delta := int(round(lerp(10.0, 22.0, h)))
    var ally_delta := int(round(lerp(8.0, 18.0, h)))

    for a in ids:
        # rank others by current relation
        var others: Array = []
        for b in ids:
            if a == b: continue
            var rel = store[a][b]
            others.append({"b": b, "r": int(_get_rel_value(rel, "relation", 0))})

        others.sort_custom(func(x, y): return int(x["r"]) < int(y["r"])) # ascending

        # enemies: lowest relations
        for i in range(min(enemies_k, others.size())):
            var b: StringName = others[i]["b"]
            var rel = store[a][b]
            var r := int(_get_rel_value(rel, "relation", 0)) - enemy_delta - rng.randi_range(0, 4)
            _set_rel_value(rel, "relation", clampi(r, -100, 100))
            # tension a bit up too
            var t :float = float(_get_rel_value(rel, "tension", 0.0)) + lerp(2.0, 6.0, h)
            _set_rel_value(rel, "tension", t)

        # allies: highest relations
        for j in range(min(allies_k, others.size())):
            var idx := others.size() - 1 - j
            var b2: StringName = others[idx]["b"]
            var rel2 = store[a][b2]
            var r2 := int(_get_rel_value(rel2, "relation", 0)) + ally_delta + rng.randi_range(0, 3)
            _set_rel_value(rel2, "relation", clampi(r2, -100, 100))
            # tension a bit down
            var t2 :float = float(_get_rel_value(rel2, "tension", 0.0)) - lerp(1.0, 4.0, h)
            _set_rel_value(rel2, "tension", max(0.0, t2))

func _apply_reciprocity(store: Dictionary, ids: Array[StringName], r: float, rng: RandomNumberGenerator) -> void:
    r = clampf(r, 0.0, 1.0)
    for i in range(ids.size()):
        for j in range(i + 1, ids.size()):
            var a := ids[i]
            var b := ids[j]

            var ab = store[a][b]
            var ba = store[b][a]

            # relation
            var rab := float(_get_rel_value(ab, "relation", 0))
            var rba := float(_get_rel_value(ba, "relation", 0))
            var m := (rab + rba) / 2.0
            rab = lerp(rab, m, r)
            rba = lerp(rba, m, r)

            # tiny asym jitter so they’re not identical
            var jitter := rng.randf_range(-2.0, 2.0) * (1.0 - r)
            rab += jitter
            rba -= jitter

            _set_rel_value(ab, "relation", clampi(int(round(rab)), -100, 100))
            _set_rel_value(ba, "relation", clampi(int(round(rba)), -100, 100))

            # trust (same approach)
            var tab := float(_get_rel_value(ab, "trust", 0))
            var tba := float(_get_rel_value(ba, "trust", 0))
            var mt := (tab + tba) / 2.0
            tab = lerp(tab, mt, r)
            tba = lerp(tba, mt, r)
            _set_rel_value(ab, "trust", clampi(int(round(tab)), -100, 100))
            _set_rel_value(ba, "trust", clampi(int(round(tba)), -100, 100))

            # tension (float)
            var ten_ab := float(_get_rel_value(ab, "tension", 0.0))
            var ten_ba := float(_get_rel_value(ba, "tension", 0.0))
            var mt2 := (ten_ab + ten_ba) / 2.0
            ten_ab = lerp(ten_ab, mt2, r)
            ten_ba = lerp(ten_ba, mt2, r)
            _set_rel_value(ab, "tension", max(0.0, ten_ab))
            _set_rel_value(ba, "tension", max(0.0, ten_ba))
