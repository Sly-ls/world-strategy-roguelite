# res://src/quests/generation/QuestGenerator.gd
extends Node

## Générateur procédural de quêtes
## PALIER 2 : Génération seed-based avec variations

# ========================================
# CONFIGURATION
# ========================================

const MAX_QUESTS_PER_DAY := 3  ## Nombre max de quêtes générées par jour
const QUEST_REFRESH_INTERVAL := 3  ## Regénérer pool tous les N jours

# ========================================
# PROPRIÉTÉS
# ========================================

var world_seed: int = 0
var variation_rng: RandomNumberGenerator

var generated_quests: Dictionary = {}  ## poi_id -> QuestInstance
var last_generation_day: int = 0

# ========================================
# LIFECYCLE
# ========================================

func _ready() -> void:
    variation_rng = RandomNumberGenerator.new()
    world_seed = Rng.rng.seed if Rng else 12345
    print("✓ QuestGenerator initialisé (seed: %d)" % world_seed)

# ========================================
# GÉNÉRATION PRINCIPALE
# ========================================
func generate_quest_of_type(quest_type: String, tier: QuestTypes.QuestTier, overrides: Dictionary = {}) -> QuestInstance:
    variation_rng.randomize()

    var params := _generate_random_parameters(quest_type, tier)
    # overrides gagnent sur les valeurs générées
    for k in overrides.keys():
        params[k] = overrides[k]

    return _create_quest_instance(quest_type, params, Vector2i(-1, -1))

func generate_quest_for_poi(poi_pos: Vector2i, poi_type: TilesEnums.CellType) -> QuestInstance:
    """Génère une quête pour un POI spécifique"""
    
    # Structure fixe basée sur seed + position
    var poi_seed := _calculate_poi_seed(poi_pos)
    Rng.rng.seed = poi_seed
    
    # Choisir le type de quête (fixe pour ce POI)
    var quest_type := _choose_quest_type_for_poi(poi_type)
    if quest_type == "":
        return null
    
    # Générer les paramètres (variables)
    variation_rng.randomize()
    var params := _generate_quest_parameters(quest_type, poi_type, poi_pos)
    
    # Créer la quête
    return _create_quest_instance(quest_type, params, poi_pos)

func generate_random_quest(tier: QuestTypes.QuestTier = QuestTypes.QuestTier.TIER_1) -> QuestInstance:
    """Génère une quête aléatoire pure (pas liée à un POI)"""
    
    variation_rng.randomize()
    
    # Choisir type aléatoire
    var available_types := _get_available_quest_types()
    if available_types.is_empty():
        return null
    
    var quest_type: String = available_types[variation_rng.randi_range(0, available_types.size() - 1)]
    
    # Générer paramètres
    var params := _generate_random_parameters(quest_type, tier)
    
    return _create_quest_instance(quest_type, params, Vector2i(-1, -1))

# ========================================
# GÉNÉRATION PAR POOL
# ========================================

func generate_quest_pool(count: int) -> Array[QuestInstance]:
    """Génère un pool de N quêtes aléatoires"""
    
    var pool: Array[QuestInstance] = []
    var tiers := [
        QuestTypes.QuestTier.TIER_1,
        QuestTypes.QuestTier.TIER_1,
        QuestTypes.QuestTier.TIER_1,
        QuestTypes.QuestTier.TIER_2,
        QuestTypes.QuestTier.TIER_2,
        QuestTypes.QuestTier.TIER_3
    ]
    
    for i in range(count):
        var tier: QuestTypes.QuestTier = tiers[variation_rng.randi_range(0, tiers.size() - 1)]
        var quest := generate_random_quest(tier)
        if quest:
            pool.append(quest)
    
    return pool

func refresh_quest_pool_if_needed() -> void:
    """Regénère le pool si intervalle écoulé"""
    var current_day := WorldState.current_day
    
    if current_day - last_generation_day >= QUEST_REFRESH_INTERVAL:
        _refresh_world_quests()
        last_generation_day = current_day

func _refresh_world_quests() -> void:
    """Regénère les quêtes du monde"""
    print("\n🔄 Régénération du pool de quêtes (jour %d)" % WorldState.current_day)
    
    # Générer nouvelles quêtes
    var new_quests := generate_quest_pool(MAX_QUESTS_PER_DAY)
    
    for quest in new_quests:
        # Démarrer automatiquement si conditions remplies
        if quest.template.can_appear():
            QuestManager.start_quest(quest.template.id, quest.context)

# ========================================
# CHOIX DU TYPE DE QUÊTE
# ========================================

func _choose_quest_type_for_poi(poi_type: TilesEnums.CellType) -> String:
    """Choisit le type de quête selon le POI (déterministe)"""
    
    match poi_type:
        TilesEnums.CellType.RUINS:
            var types := ["ruins_clear", "ruins_artifact", "ruins_treasure"]
            return types[Rng.rng.randi() % types.size()]
        
        TilesEnums.CellType.TOWN:
            var types := ["town_delivery", "town_defense", "town_trade"]
            return types[Rng.rng.randi() % types.size()]
        
        TilesEnums.CellType.FOREST_SHRINE:
            var types := ["shrine_offering", "shrine_quest", "shrine_trial"]
            return types[Rng.rng.randi() % types.size()]
        
        _:
            return ""

func _get_available_quest_types() -> Array[String]:
    """Retourne tous les types de quêtes disponibles"""
    return [
        "generic_combat",
        "generic_exploration",
        "generic_survival",
        "generic_collection",
        "faction_diplomacy"
    ]

# ========================================
# GÉNÉRATION DE PARAMÈTRES
# ========================================
func _generate_quest_parameters(
    quest_type: String,
    poi_type: TilesEnums.CellType,
    poi_pos: Vector2i
) -> Dictionary:
    """Génère les paramètres variables d'une quête liée à un POI"""

    # 1️⃣ Runtime factions
    var giver_faction_id: String = _pick_random_faction()
    var antagonist_faction_id: String = _pick_hostile_faction()

    # 2️⃣ Catégorie depuis le POI
    var category: QuestTypes.QuestCategory = _guess_category_from_poi(poi_type)

    # 3️⃣ Contexte de résolution
    var resolution_context := ContextTagResolver.build_context(
       category,
       QuestTypes.QuestTier.TIER_1,
       giver_faction_id,
       antagonist_faction_id
    )
    
    # 4️⃣ Choix du profil
    var profile_id: String = ResolutionRuleFactory.pick_profile(resolution_context)

    # 5️⃣ Params de base
    var params := {
        "poi_pos": poi_pos,
        "poi_type": poi_type,
        "poi_id": "poi_%d_%d" % [poi_pos.x, poi_pos.y],

        "giver_faction_id": giver_faction_id,
        "antagonist_faction_id": antagonist_faction_id,
        "resolution_profile_id": profile_id
    }
    # 6️⃣ Spécifique au type de quête
    match quest_type:
        "ruins_artifact":
            params["artifact_name"] = _generate_artifact_name()
            params["faction_interested"] = _pick_random_faction()
            params["danger_level"] = variation_rng.randi_range(1, 3)

        "town_delivery":
            params["resource_type"] = _pick_random_resource()
            params["resource_amount"] = variation_rng.randi_range(10, 50)
            params["urgency"] = variation_rng.randi_range(1, 3)

        "town_defense":
            params["enemy_faction"] = _pick_hostile_faction()
            params["enemy_strength"] = variation_rng.randi_range(1, 5)
            params["reward_multiplier"] = variation_rng.randf_range(1.0, 2.0)

        "shrine_offering":
            params["offering_type"] = _pick_random_resource()
            params["offering_amount"] = variation_rng.randi_range(5, 20)
            params["blessing_type"] = _pick_random_blessing()

    return params
func _guess_category_from_poi(poi_type: TilesEnums.CellType) -> QuestTypes.QuestCategory:
    match poi_type:
        TilesEnums.CellType.RUINS:
            return QuestTypes.QuestCategory.EXPLORATION
        TilesEnums.CellType.TOWN, TilesEnums.CellType.VILLAGE:
            return QuestTypes.QuestCategory.DIPLOMATIC
        TilesEnums.CellType.FORTRESS:
            return QuestTypes.QuestCategory.COMBAT
        TilesEnums.CellType.DUNGEON:
            return QuestTypes.QuestCategory.EXPLORATION
        _:
            return QuestTypes.QuestCategory.LOCAL_POI

func _generate_random_parameters(
    quest_type: String,
    tier: QuestTypes.QuestTier
) -> Dictionary:
    """Génère des paramètres pour une quête générique"""

    # 1️⃣ Runtime factions (procédural)
    var giver_faction_id: String = _pick_random_faction()
    var antagonist_faction_id: String = _pick_hostile_faction()

    # 2️⃣ Contexte de résolution
    var resolution_context := ContextTagResolver.build_context(
       _guess_category_from_quest_type(quest_type),
       tier,
       giver_faction_id,
       antagonist_faction_id
    )

    # 3️⃣ Choix du profil
    var profile_id: String = ResolutionRuleFactory.pick_profile(resolution_context)

    # 4️⃣ Params de base
    var params := {
        "tier": tier,
        "generated": true,
        "giver_faction_id": giver_faction_id,
        "antagonist_faction_id": antagonist_faction_id,
        "resolution_profile_id": profile_id
    }

    # 5️⃣ Spécifique au type
    match quest_type:
        "generic_combat":
            params["enemy_type"] = _pick_random_enemy()
            params["enemy_count"] = variation_rng.randi_range(1, 5)
            params["location_type"] = _pick_random_location()

        "generic_exploration":
            params["area_size"] = variation_rng.randi_range(5, 15)
            params["poi_count"] = variation_rng.randi_range(1, 3)

        "generic_survival":
            params["days"] = variation_rng.randi_range(3, 10)
            params["threat_level"] = variation_rng.randi_range(1, tier)

        "generic_collection":
            params["resource_type"] = _pick_random_resource()
            params["amount"] = variation_rng.randi_range(20, 100)

        "faction_diplomacy":
            params["target_faction"] = _pick_random_faction()
            params["relation_target"] = variation_rng.randi_range(25, 75)

    return params

func _guess_category_from_quest_type(quest_type: String) -> QuestTypes.QuestCategory:
    match quest_type:
        "generic_combat":
            return QuestTypes.QuestCategory.COMBAT
        "generic_exploration":
            return QuestTypes.QuestCategory.EXPLORATION
        "generic_survival":
            return QuestTypes.QuestCategory.SURVIVAL
        "generic_collection":
            return QuestTypes.QuestCategory.DELIVERY
        "faction_diplomacy":
            return QuestTypes.QuestCategory.DIPLOMATIC
        _:
            return QuestTypes.QuestCategory.LOCAL_POI

# ========================================
# CRÉATION D'INSTANCE
# ========================================

func _create_quest_instance(quest_type: String, params: Dictionary, poi_pos: Vector2i) -> QuestInstance:
    """Crée une instance de quête à partir d'un template paramétré"""
    
    # Créer un template dynamique
    var template := _create_dynamic_template(quest_type, params)
    
    # Créer l'instance
    var instance := QuestInstance.new(template, params)
    
    instance.giver_faction_id = params["giver_faction_id"]
    instance.antagonist_faction_id = params["antagonist_faction_id"]
    instance.resolution_profile_id = params["resolution_profile_id"]
    
    return instance

func _create_dynamic_template(quest_type: String, params: Dictionary) -> QuestTemplate:
    """Crée un template de quête dynamique"""
    
    var template := QuestTemplate.new()
    template.id = "generated_%s_%d" % [quest_type, Time.get_ticks_msec()]
    
    match quest_type:
        "ruins_artifact":
            template.title = "L'Artefact de %s" % params.get("artifact_name", "l'Ancien")
            template.description = "Les ruines contiennent un artefact légendaire. %s serait intéressé." % _get_faction_name(params.get("faction_interested", ""))
            template.category = QuestTypes.QuestCategory.LOCAL_POI
            template.tier = QuestTypes.QuestTier.TIER_1
            template.objective_type = QuestTypes.ObjectiveType.CLEAR_COMBAT
            template.objective_target = "ruins"
            template.objective_count = 1
            template.expires_in_days = 7
            _add_artifact_rewards(template, params)
        
        "town_delivery":
            var resource :String = params.get("resource_type", "nourriture")
            var amount :int = params.get("resource_amount", 20)
            template.title = "Livraison de %s" % resource.capitalize()
            template.description = "La ville a besoin de %d unités de %s." % [amount, resource]
            template.category = QuestTypes.QuestCategory.DELIVERY
            template.tier = QuestTypes.QuestTier.TIER_1
            template.objective_type = QuestTypes.ObjectiveType.REACH_POI
            template.objective_target = "town"
            template.objective_count = 1
            template.expires_in_days = 5
            _add_delivery_rewards(template, params)
        
        "generic_combat":
            var enemy :String = params.get("enemy_type", "bandits")
            var count :int = params.get("enemy_count", 3)
            template.title = "Éliminer %s" % enemy.capitalize()
            template.description = "Éliminez %d groupe(s) de %s." % [count, enemy]
            template.category = QuestTypes.QuestCategory.COMBAT
            template.tier = params.get("tier", QuestTypes.QuestTier.TIER_1)
            template.objective_type = QuestTypes.ObjectiveType.CLEAR_COMBAT
            template.objective_target = enemy
            template.objective_count = count
            template.expires_in_days = 10
            _add_combat_rewards(template, params)
        
        "generic_survival":
            var days :int = params.get("days", 5)
            template.title = "Survivre %d jours" % days
            template.description = "Prouvez votre ténacité en survivant %d jours." % days
            template.category = QuestTypes.QuestCategory.SURVIVAL
            template.tier = params.get("tier", QuestTypes.QuestTier.TIER_1)
            template.objective_type = QuestTypes.ObjectiveType.SURVIVE_DAYS
            template.objective_count = days
            template.expires_in_days = -1
            _add_survival_rewards(template, params)
        
        "faction_diplomacy":
            var faction :String = params.get("target_faction", "humans")
            var target :int = params.get("relation_target", 50)
            var faction_name := _get_faction_name(faction)
            template.title = "Alliance avec %s" % faction_name
            template.description = "Améliorez vos relations avec %s jusqu'à %d." % [faction_name, target]
            template.category = QuestTypes.QuestCategory.DIPLOMATIC
            template.tier = params.get("tier", QuestTypes.QuestTier.TIER_2)
            template.objective_type = QuestTypes.ObjectiveType.FACTION_RELATION
            template.objective_target = faction
            template.objective_count = target
            template.expires_in_days = 15
            _add_diplomacy_rewards(template, params)
        "generic_exploration":
            template.title = "Explorer une zone"
            template.description = "Explorez la zone et repérez des points d'intérêt."
            template.category = QuestTypes.QuestCategory.EXPLORATION
            template.tier = params.get("tier", QuestTypes.QuestTier.TIER_1)
            template.objective_type = QuestTypes.ObjectiveType.REACH_POI
            template.objective_target = params.get("location_type", "zone")
            template.objective_count = 1
            template.expires_in_days = -1

        "ruins_clear":
            template.title = "Nettoyer les ruines"
            template.description = "Des ruines sont infestées. Éliminez la menace."
            template.category = QuestTypes.QuestCategory.LOCAL_POI
            template.tier = QuestTypes.QuestTier.TIER_1
            template.objective_type = QuestTypes.ObjectiveType.CLEAR_COMBAT
            template.objective_target = "ruins"
            template.objective_count = 1
            template.expires_in_days = 7
            _add_combat_rewards(template, params)
        _:
            template.title = "Quête inconnue (%s)" % quest_type
            template.description = "Type non géré par _create_dynamic_template()."
            template.category = QuestTypes.QuestCategory.LOCAL_POI
            template.tier = params.get("tier", QuestTypes.QuestTier.TIER_1)
            template.objective_type = QuestTypes.ObjectiveType.MAKE_CHOICE
            template.objective_target = ""
            template.objective_count = 1
            template.expires_in_days = 3
            print("QuestGenerator: quest_type non géré: %s" % quest_type)
            
    return template

# ========================================
# RÉCOMPENSES DYNAMIQUESj
# ========================================
func _add_artifact_rewards(template: QuestTemplate, params: Dictionary) -> void:
    var reward_gold := QuestReward.new()
    reward_gold.type = QuestTypes.RewardType.GOLD
    reward_gold.amount = 50
    template.rewards.append(reward_gold)

func _add_delivery_rewards(template: QuestTemplate, params: Dictionary) -> void:
    var amount: int = params.get("resource_amount", 20)
    var reward := QuestReward.new()
    reward.type = QuestTypes.RewardType.GOLD
    reward.amount = amount * 2
    template.rewards.append(reward)

func _add_combat_rewards(template: QuestTemplate, params: Dictionary) -> void:
    var tier: int = params.get("tier", 1)
    var reward := QuestReward.new()
    reward.type = QuestTypes.RewardType.GOLD
    reward.amount = 30 * tier
    template.rewards.append(reward)

func _add_survival_rewards(template: QuestTemplate, params: Dictionary) -> void:
    var days: int = params.get("days", 5)
    var reward := QuestReward.new()
    reward.type = QuestTypes.RewardType.GOLD
    reward.amount = days * 10
    template.rewards.append(reward)

func _add_diplomacy_rewards(template: QuestTemplate, params: Dictionary) -> void:
    var reward := QuestReward.new()
    reward.type = QuestTypes.RewardType.GOLD
    reward.amount = 100
    template.rewards.append(reward)
    
func _create_reward_OLD(type: QuestTypes.RewardType, amount: int, target_id: String) -> QuestReward:
    var reward := QuestReward.new()
    reward.type = type
    reward.amount = amount
    reward.target_id = target_id
    return reward

# ========================================
# HELPERS - NOMS PROCÉDURAUX
# ========================================

func _generate_artifact_name() -> String:
    var prefixes := ["l'Ancien", "le Maudit", "le Sacré", "l'Éternel", "le Perdu"]
    var suffixes := ["Sceptre", "Amulette", "Couronne", "Grimoire", "Cristal"]
    return "%s %s" % [
        prefixes[variation_rng.randi_range(0, prefixes.size() - 1)],
        suffixes[variation_rng.randi_range(0, suffixes.size() - 1)]
    ]

func _pick_random_faction() -> String:
    var factions := ["humans", "elves", "orcs"]
    return factions[variation_rng.randi_range(0, factions.size() - 1)]

func _pick_hostile_faction() -> String:
    var factions := ["orcs", "bandits"]
    return factions[variation_rng.randi_range(0, factions.size() - 1)]

func _pick_random_resource() -> String:
    var resources := ["gold", "food", "wood", "stone"]
    return resources[variation_rng.randi_range(0, resources.size() - 1)]

func _pick_random_blessing() -> String:
    var blessings := ["force", "sagesse", "chance", "protection"]
    return blessings[variation_rng.randi_range(0, blessings.size() - 1)]

func _pick_random_enemy() -> String:
    var enemies := ["bandits", "orcs", "créatures", "morts-vivants"]
    return enemies[variation_rng.randi_range(0, enemies.size() - 1)]

func _pick_random_location() -> String:
    var locations := ["forêt", "marais", "montagne", "plaine"]
    return locations[variation_rng.randi_range(0, locations.size() - 1)]

func _get_faction_name(faction_id: String) -> String:
    if FactionManager && FactionManager.has_faction(faction_id):
        return FactionManager.get_faction(faction_id).name
    return faction_id.capitalize()

# ========================================
# SEED CALCULATION
# ========================================

func _calculate_poi_seed(poi_pos: Vector2i) -> int:
    """Calcule un seed unique pour un POI basé sur sa position"""
    return world_seed + poi_pos.x * 1000 + poi_pos.y
# EXTENSION QuestGenerator.gd - Ajouter ces fonctions

# ========================================
# GÉNÉRATION ADVANCED (PALIER 2 + 3)
# ========================================

func generate_advanced_quest_for_poi(poi_pos: Vector2i, poi_type: TilesEnums.CellType) -> QuestInstanceAdvanced:
    """Génère une quête complexe avec objectifs multiples pour un POI"""
    
    # Seed basé sur position
    var poi_seed := _calculate_poi_seed(poi_pos)
    Rng.rng.seed = poi_seed
    
    # Créer template advanced
    var template := QuestTemplateAdvanced.new()
    
    # ID et titre
    template.id = "adv_gen_%d" % poi_seed
    template.title = _generate_advanced_title(poi_type, poi_seed)
    template.description = _generate_advanced_description(poi_type)
    
    # Catégorie et tier
    template.category = _get_category_for_poi(poi_type)
    template.tier = _choose_tier_for_poi(poi_type)
    
    # Générer objectifs (2-3)
    var num_objectives := Rng.rng.randi_range(2, 3)
    template.objectives = _generate_objectives_for_poi(poi_type, num_objectives)
    
    # Mode de complétion
    template.completion_mode = QuestTemplateAdvanced.CompletionMode.ALL_OBJECTIVES
    
    # 30% de chance d'avoir des branches
    if Rng.rng.randf() > 0.7:
        template.has_branches = true
        template.branches = _generate_branches_for_poi(poi_type)
    
    # Récompenses
    template.rewards = _generate_rewards_advanced(poi_type, template.tier)
    
    # Expiration
    template.expires_in_days = 7
    
    # Créer instance
    return QuestInstanceAdvanced.new(template, {"poi_pos": poi_pos, "seed": poi_seed})

# ========================================
# HELPERS - TITRES ET DESCRIPTIONS
# ========================================

func _generate_advanced_title(poi_type: TilesEnums.CellType, seed: int) -> String:
    """Génère un titre pour quête advanced"""
    
    var adjectives := ["Mystérieux", "Ancien", "Dangereux", "Oublié", "Maudit", "Sacré"]
    var nouns := []
    
    match poi_type:
        TilesEnums.CellType.RUINS:
            nouns = ["Ruines", "Temple", "Tombeau", "Donjon", "Catacombes"]
        TilesEnums.CellType.TOWN:
            nouns = ["Ville", "Cité", "Bourg", "Village", "Hameau"]
        TilesEnums.CellType.FORTRESS:
            nouns = ["Forteresse", "Citadelle", "Bastion", "Château", "Fort"]
        TilesEnums.CellType.DUNGEON:
            nouns = ["Donjon", "Cachot", "Oubliettes", "Prison", "Labyrinthe"]
        _:
            nouns = ["Lieu", "Site", "Zone"]
    
    var rng_title := RandomNumberGenerator.new()
    rng_title.seed = seed
    
    var adj :String = adjectives[rng_title.randi() % adjectives.size()]
    var noun :String = nouns[rng_title.randi() % nouns.size()]
    
    var formats :Array[String] = [
        "Exploration %s %s",
        "Secrets %s %s",
        "Mystères %s %s",
        "Conquête %s %s"
    ]
    
    var format :String = formats[rng_title.randi() % formats.size()]
    return format % [adj, noun]

func _generate_advanced_description(poi_type: TilesEnums.CellType) -> String:
    """Génère une description pour quête advanced"""
    
    match poi_type:
        TilesEnums.CellType.RUINS:
            return "Des ruines anciennes renferment des secrets oubliés. Explorez-les avec précaution."
        TilesEnums.CellType.TOWN:
            return "Les habitants ont besoin d'aide. Accomplissez leurs requêtes pour gagner leur confiance."
        TilesEnums.CellType.FORTRESS:
            return "Une forteresse imposante se dresse devant vous. Ses murs cachent bien des mystères."
        TilesEnums.CellType.DUNGEON:
            return "Un donjon sombre et dangereux vous attend. Survivrez-vous à ses pièges ?"
        _:
            return "Un lieu étrange nécessite votre attention."

# ========================================
# HELPERS - OBJECTIFS
# ========================================

func _generate_objectives_for_poi(poi_type: TilesEnums.CellType, count: int) -> Array[QuestObjective]:
    """Génère plusieurs objectifs pour un POI"""
    
    var objectives: Array[QuestObjective] = []
    
    match poi_type:
        TilesEnums.CellType.RUINS:
            # Objectif 1 : Explorer
            var obj1 := QuestObjective.new()
            obj1.id = "explore"
            obj1.title = "Explorer les ruines"
            obj1.description = "Découvrez les secrets cachés"
            obj1.objective_type = QuestTypes.ObjectiveType.EXPLORE_POI
            obj1.is_optional = false
            objectives.append(obj1)
            
            if count >= 2:
                # Objectif 2 : Combat
                var obj2 := QuestObjective.new()
                obj2.id = "clear_enemies"
                obj2.title = "Vaincre les gardiens"
                obj2.description = "Éliminez les créatures qui protègent les ruines"
                obj2.objective_type = QuestTypes.ObjectiveType.CLEAR_COMBAT
                obj2.count = Rng.rng.randi_range(3, 7)
                obj2.required_objectives = ["explore"]
                objectives.append(obj2)
            
            if count >= 3:
                # Objectif 3 : Loot
                var obj3 := QuestObjective.new()
                obj3.id = "find_artifact"
                obj3.title = "Récupérer l'artefact"
                obj3.description = "Trouvez et récupérez le trésor"
                obj3.objective_type = QuestTypes.ObjectiveType.LOOT_ITEM
                obj3.target = "artifact"
                obj3.required_objectives = ["clear_enemies"]
                objectives.append(obj3)
        
        TilesEnums.CellType.TOWN:
            # Objectif 1 : Parler
            var obj1 := QuestObjective.new()
            obj1.id = "talk_mayor"
            obj1.title = "Parler au maire"
            obj1.description = "Discutez avec le dirigeant de la ville"
            obj1.objective_type = QuestTypes.ObjectiveType.TALK_TO_NPC
            obj1.target = "mayor"
            objectives.append(obj1)
            
            if count >= 2:
                # Objectif 2 : Aider
                var obj2 := QuestObjective.new()
                obj2.id = "help_citizens"
                obj2.title = "Aider les habitants"
                obj2.description = "Accomplissez une tâche pour la communauté"
                obj2.objective_type = QuestTypes.ObjectiveType.DELIVER_RESOURCES
                obj2.count = Rng.rng.randi_range(20, 50)
                obj2.required_objectives = ["talk_mayor"]
                objectives.append(obj2)
            
            if count >= 3:
                # Objectif 3 : Récompense
                var obj3 := QuestObjective.new()
                obj3.id = "receive_reward"
                obj3.title = "Recevoir la gratitude"
                obj3.description = "Les habitants vous remercient"
                obj3.objective_type = QuestTypes.ObjectiveType.TALK_TO_NPC
                obj3.target = "mayor"
                obj3.required_objectives = ["help_citizens"]
                objectives.append(obj3)
        
        _:
            # POI générique
            var obj1 := QuestObjective.new()
            obj1.id = "generic_objective"
            obj1.title = "Accomplir la tâche"
            obj1.description = "Terminez l'objectif principal"
            obj1.objective_type = QuestTypes.ObjectiveType.EXPLORE_POI
            objectives.append(obj1)
    
    return objectives

# ========================================
# HELPERS - BRANCHES
# ========================================

func _generate_branches_for_poi(poi_type: TilesEnums.CellType) -> Array[QuestBranch]:
    """Génère des branches de choix pour un POI"""
    
    var branches: Array[QuestBranch] = []
    
    match poi_type:
        TilesEnums.CellType.RUINS:
            # Choix : Garder ou Vendre l'artefact
            var branch1 := QuestBranch.new()
            branch1.id = "keep_artifact"
            branch1.title = "Garder l'artefact"
            branch1.description = "Conservez l'artefact pour votre collection"
            branch1.rewards = [
                _create_reward("stat_boost", {"stat": "power", "amount": 5})
            ]
            branches.append(branch1)
            
            var branch2 := QuestBranch.new()
            branch2.id = "sell_artifact"
            branch2.title = "Vendre l'artefact"
            branch2.description = "Vendez l'artefact pour de l'or"
            branch2.rewards = [
                _create_reward("gold", {"amount": 100})
            ]
            branches.append(branch2)
        
        TilesEnums.CellType.TOWN:
            # Choix : Aider gratuitement ou demander paiement
            var branch1 := QuestBranch.new()
            branch1.id = "help_free"
            branch1.title = "Aider gratuitement"
            branch1.description = "Aidez sans demander de récompense"
            branch1.rewards = [
                _create_reward("reputation", {"amount": 20})
            ]
            branches.append(branch1)
            
            var branch2 := QuestBranch.new()
            branch2.id = "ask_payment"
            branch2.title = "Demander paiement"
            branch2.description = "Exigez une rétribution pour vos services"
            branch2.rewards = [
                _create_reward("gold", {"amount": 75})
            ]
            branches.append(branch2)
    
    return branches

func _create_reward(type: String, params: Dictionary) -> QuestReward:
    """Crée une récompense"""
    var reward := QuestReward.new()
    
    match type:
        "gold":
            reward.type = QuestTypes.RewardType.GOLD
            reward.amount = params.get("amount", 50)
        "stat_boost":
            # Placeholder pour boost de stat
            reward.type = QuestTypes.RewardType.ITEM
            reward.target_id = params.get("stat", "power")
            reward.amount = 1
        "reputation":
            reward.type = QuestTypes.RewardType.FACTION_REP
            reward.target_id = params.get("faction_id", "")
            reward.amount = params.get("amount", 10)
    
    return reward

# ========================================
# HELPERS - RÉCOMPENSES
# ========================================

func _generate_rewards_advanced(poi_type: TilesEnums.CellType, tier: QuestTypes.QuestTier) -> Array[QuestReward]:
    """Génère des récompenses pour quête advanced"""
    
    var rewards: Array[QuestReward] = []
    var reward := QuestReward.new()
    
    # Or basé sur tier
    var base_gold := 30
    match tier:
        QuestTypes.QuestTier.TIER_1: base_gold = 50
        QuestTypes.QuestTier.TIER_2: base_gold = 100
        QuestTypes.QuestTier.TIER_3: base_gold = 200
        QuestTypes.QuestTier.TIER_4: base_gold = 400
        QuestTypes.QuestTier.TIER_5: base_gold = 800
    
    reward.type = QuestTypes.RewardType.GOLD
    reward.amount = base_gold
    rewards.append(reward)
    
    # Items supplémentaires pour certains POI
    match poi_type:
        TilesEnums.CellType.RUINS:
            var item_reward := QuestReward.new()
            item_reward.type = QuestTypes.RewardType.ITEM
            item_reward.target_id = "artifact_fragment"
            item_reward.amount = 1
            rewards.append(item_reward)
        TilesEnums.CellType.DUNGEON:
            var item_reward := QuestReward.new()
            item_reward.type = QuestTypes.RewardType.ITEM
            item_reward.target_id = "rare_equipment"
            item_reward.amount = 1
            rewards.append(item_reward)
    
                          
    return rewards

# ========================================
# HELPERS - CATEGORIES ET TIERS
# ========================================

func _get_category_for_poi(poi_type: TilesEnums.CellType) -> QuestTypes.QuestCategory:
    """Retourne la catégorie selon le type de POI"""
    match poi_type:
        TilesEnums.CellType.RUINS:
            return QuestTypes.QuestCategory.EXPLORATION
        TilesEnums.CellType.TOWN:
            return QuestTypes.QuestCategory.DIPLOMATIC
        TilesEnums.CellType.VILLAGE:
            return QuestTypes.QuestCategory.LOCAL_POI
        _:
            return QuestTypes.QuestCategory.LOCAL_POI

func _choose_tier_for_poi(poi_type: TilesEnums.CellType) -> QuestTypes.QuestTier:
    """Choisit un tier selon le POI"""
    var tiers := [
        QuestTypes.QuestTier.TIER_1,
        QuestTypes.QuestTier.TIER_1,
        QuestTypes.QuestTier.TIER_2,
        QuestTypes.QuestTier.TIER_2,
        QuestTypes.QuestTier.TIER_3
    ]
    return tiers[Rng.rng.randi() % tiers.size()]

# ========================================
# HELPERS - TITRES ET DESCRIPTIONS
# ========================================

func _generate_advanced_title_fixed(poi_type: TilesEnums.CellType, seed: int) -> String:
    """Génère un titre pour quête advanced"""
    
    var adjectives := ["Mystérieux", "Ancien", "Dangereux", "Oublié", "Maudit", "Sacré"]
    var nouns := []
    
    match poi_type:
        TilesEnums.CellType.RUINS:
            nouns = ["Ruines", "Temple", "Tombeau", "Sanctuaire", "Catacombes"]
        TilesEnums.CellType.TOWN:
            nouns = ["Ville", "Cité", "Bourg", "Cité-État", "Métropole"]
        TilesEnums.CellType.VILLAGE:
            nouns = ["Village", "Hameau", "Bourg", "Bourgade", "Communauté"]
        _:
            nouns = ["Lieu", "Site", "Zone", "Région", "Territoire"]
    
    var rng_title := RandomNumberGenerator.new()
    rng_title.seed = seed
    
    var adj: String = adjectives[rng_title.randi() % adjectives.size()]
    var noun: String = nouns[rng_title.randi() % nouns.size()]
    
    var formats := [
        "Exploration %s %s",
        "Secrets %s %s",
        "Mystères %s %s",
        "Conquête %s %s"
    ]
    
    var format: String = formats[rng_title.randi() % formats.size()]
    return format % [adj, noun]

func _generate_advanced_description_fixed(poi_type: TilesEnums.CellType) -> String:
    """Génère une description pour quête advanced"""
    
    match poi_type:
        TilesEnums.CellType.RUINS:
            return "Des ruines anciennes renferment des secrets oubliés. Explorez-les avec précaution."
        TilesEnums.CellType.TOWN:
            return "Les habitants ont besoin d'aide. Accomplissez leurs requêtes pour gagner leur confiance."
        TilesEnums.CellType.VILLAGE:
            return "Un village paisible vous accueille. Les habitants ont des besoins simples mais urgents."
        _:
            return "Un lieu étrange nécessite votre attention."

# ========================================
# HELPERS - OBJECTIFS
# ========================================

func _generate_objectives_for_poi_fixed(poi_type: TilesEnums.CellType, count: int) -> Array[QuestObjective]:
    """Génère plusieurs objectifs pour un POI"""
    
    var objectives: Array[QuestObjective] = []
    
    match poi_type:
        TilesEnums.CellType.RUINS:
            # Objectif 1 : Explorer
            var obj1 := QuestObjective.new()
            obj1.id = "explore"
            obj1.title = "Explorer les ruines"
            obj1.description = "Découvrez les secrets cachés"
            obj1.objective_type = QuestTypes.ObjectiveType.REACH_LOCATION
            obj1.is_optional = false
            objectives.append(obj1)
            
            if count >= 2:
                # Objectif 2 : Combat
                var obj2 := QuestObjective.new()
                obj2.id = "clear_enemies"
                obj2.title = "Vaincre les gardiens"
                obj2.description = "Éliminez les créatures qui protègent les ruines"
                obj2.objective_type = QuestTypes.ObjectiveType.DEFEAT_ENEMIES
                obj2.count = Rng.rng.randi_range(3, 7)
                obj2.required_objectives = ["explore"]
                objectives.append(obj2)
            
            if count >= 3:
                # Objectif 3 : Loot
                var obj3 := QuestObjective.new()
                obj3.id = "find_artifact"
                obj3.title = "Récupérer l'artefact"
                obj3.description = "Trouvez et récupérez le trésor"
                obj3.objective_type = QuestTypes.ObjectiveType.COLLECT_RESOURCES
                obj3.target = "artifact"
                obj3.count = 1
                obj3.required_objectives = ["clear_enemies"]
                objectives.append(obj3)
        
        TilesEnums.CellType.TOWN:
            # Objectif 1 : Parler
            var obj1 := QuestObjective.new()
            obj1.id = "talk_mayor"
            obj1.title = "Parler au maire"
            obj1.description = "Discutez avec le dirigeant de la ville"
            obj1.objective_type = QuestTypes.ObjectiveType.REACH_LOCATION
            obj1.target = "mayor"
            objectives.append(obj1)
            
            if count >= 2:
                # Objectif 2 : Aider
                var obj2 := QuestObjective.new()
                obj2.id = "help_citizens"
                obj2.title = "Aider les habitants"
                obj2.description = "Accomplissez une tâche pour la communauté"
                obj2.objective_type = QuestTypes.ObjectiveType.COLLECT_RESOURCES
                obj2.count = Rng.rng.randi_range(20, 50)
                obj2.required_objectives = ["talk_mayor"]
                objectives.append(obj2)
            
            if count >= 3:
                # Objectif 3 : Récompense
                var obj3 := QuestObjective.new()
                obj3.id = "receive_reward"
                obj3.title = "Recevoir la gratitude"
                obj3.description = "Les habitants vous remercient"
                obj3.objective_type = QuestTypes.ObjectiveType.REACH_LOCATION
                obj3.target = "mayor"
                obj3.required_objectives = ["help_citizens"]
                objectives.append(obj3)
        
        _:
            # POI générique
            var obj1 := QuestObjective.new()
            obj1.id = "generic_objective"
            obj1.title = "Accomplir la tâche"
            obj1.description = "Terminez l'objectif principal"
            obj1.objective_type = QuestTypes.ObjectiveType.REACH_LOCATION
            objectives.append(obj1)
    
    return objectives

# ========================================
# HELPERS - BRANCHES
# ========================================

func _generate_branches_for_poi_fixed(poi_type: TilesEnums.CellType) -> Array[QuestBranch]:
    """Génère des branches de choix pour un POI"""
    
    var branches: Array[QuestBranch] = []
    
    match poi_type:
        TilesEnums.CellType.RUINS:
            # Choix : Garder ou Vendre l'artefact
            var branch1 := QuestBranch.new()
            branch1.id = "keep_artifact"
            branch1.title = "Garder l'artefact"
            branch1.description = "Conservez l'artefact pour votre collection"
            branch1.rewards = _create_branch_rewards("power", 5)
            branches.append(branch1)
            
            var branch2 := QuestBranch.new()
            branch2.id = "sell_artifact"
            branch2.title = "Vendre l'artefact"
            branch2.description = "Vendez l'artefact pour de l'or"
            branch2.rewards = _create_branch_rewards("gold", 100)
            branches.append(branch2)
        
        TilesEnums.CellType.TOWN:
            # Choix : Aider gratuitement ou demander paiement
            var branch1 := QuestBranch.new()
            branch1.id = "help_free"
            branch1.title = "Aider gratuitement"
            branch1.description = "Aidez sans demander de récompense"
            branch1.rewards = _create_branch_rewards("reputation", 20)
            branches.append(branch1)
            
            var branch2 := QuestBranch.new()
            branch2.id = "ask_payment"
            branch2.title = "Demander paiement"
            branch2.description = "Exigez une rétribution pour vos services"
            branch2.rewards = _create_branch_rewards("gold", 75)
            branches.append(branch2)
    
    return branches

func _create_branch_rewards(type: String, amount: int, target: String = "") -> Array[QuestReward]:
    """Crée des récompenses pour une branche"""
    var rewards: Array[QuestReward] = []
    var reward := QuestReward.new()
    
    match type:
        "gold":
            reward.type = QuestTypes.RewardType.GOLD
            reward.amount = amount
        "power":
            # Placeholder - à implémenter selon ton système
            reward.type = QuestTypes.RewardType.ITEM
            reward.target_id = "power_boost"
            reward.amount = 1
        "reputation":
            # Placeholder - à implémenter selon ton système
            reward.type = QuestTypes.RewardType.FACTION_REP
            reward.target_id = target
            reward.amount = 10
    
    rewards.append(reward)
    return rewards

# ========================================
# HELPERS - RÉCOMPENSES
# ========================================

func tick_artifact_recovery_offers() -> void:
    if ArtifactRegistry == null:
        return
    for artifact_id in ArtifactRegistryRunner.owner_type.keys():
        if ArtifactRegistryRunner.is_lost(artifact_id):
            var q := generate_retrieve_artifact_quest(artifact_id)
            if q != null:
                QuestOfferSimRunner.add_offer(q) # ou ton système d'offers
                
func generate_retrieve_artifact_quest(artifact_id: String) -> QuestInstance:
    var spec: ArtifactSpec = ArtifactRegistryRunner.get_spec(artifact_id) if ArtifactRegistry else null
    if spec == null:
        return null

    var template := QuestTemplate.new()
    template.id = "retrieve_%s_%d" % [artifact_id, Time.get_ticks_msec()]
    template.title = "Retrouver l'artefact : %s" % spec.name
    template.description = "Un artefact a disparu. Retrouve %s et décide à qui il revient." % spec.name
    template.category = QuestTypes.QuestCategory.EXPLORATION
    template.tier = QuestTypes.QuestTier.TIER_2
    template.objective_type = QuestTypes.ObjectiveType.REACH_POI
    template.objective_target = "loot_site_for_%s" % artifact_id
    template.objective_count = 1
    template.expires_in_days = 15

    # récompense exemple
    var r := QuestReward.new()
    r.type = QuestTypes.RewardType.GOLD
    r.amount = 80
    template.rewards = [r]

    var ctx := {
        "artifact_id": artifact_id,
        "resolution_profile_id": "artifact_recovery",
        "giver_faction_id": _pick_random_faction(),
        "antagonist_faction_id": _pick_hostile_faction(),
        "tier": template.tier,
        "category": template.category
    }
    return QuestInstance.new(template, ctx)

func _generate_rewards_advanced_fixed(poi_type: TilesEnums.CellType, tier: QuestTypes.QuestTier) -> Array[QuestReward]:
    """Génère des récompenses pour quête advanced"""
    
    var rewards: Array[QuestReward] = []
    var reward := QuestReward.new()
    
    # Or basé sur tier
    var base_gold := 30
    match tier:
        QuestTypes.QuestTier.TIER_1: base_gold = 50
        QuestTypes.QuestTier.TIER_2: base_gold = 100
        QuestTypes.QuestTier.TIER_3: base_gold = 200
        QuestTypes.QuestTier.TIER_4: base_gold = 400
        QuestTypes.QuestTier.TIER_5: base_gold = 800
    
    reward.type = QuestTypes.RewardType.GOLD
    reward.amount = base_gold
    rewards.append(reward)
    
    # Items supplémentaires pour certains POI
    match poi_type:
        TilesEnums.CellType.RUINS:
            var item_reward := QuestReward.new()
            item_reward.type = QuestTypes.RewardType.ITEM
            item_reward.target_id = "artifact_fragment"
            item_reward.amount = 1
            rewards.append(item_reward)
        _:
            pass
    
                          
    return rewards
