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

func generate_quest_for_poi(poi_pos: Vector2i, poi_type: GameEnums.CellType) -> QuestInstance:
    """Génère une quête pour un POI spécifique"""
    
    # Structure fixe basée sur seed + position
    var poi_seed := _calculate_poi_seed(poi_pos)
    Rng.rng.seed = poi_seed
    
    # Choisir le type de quête (fixe pour ce POI)
    var quest_type := _choose_quest_type_for_poi(poi_type)
    if quest_type == null:
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

func _choose_quest_type_for_poi(poi_type: GameEnums.CellType) -> String:
    """Choisit le type de quête selon le POI (déterministe)"""
    
    match poi_type:
        GameEnums.CellType.RUINS:
            var types := ["ruins_clear", "ruins_artifact", "ruins_treasure"]
            return types[Rng.rng.randi() % types.size()]
        
        GameEnums.CellType.TOWN:
            var types := ["town_delivery", "town_defense", "town_trade"]
            return types[Rng.rng.randi() % types.size()]
        
        GameEnums.CellType.FOREST_SHRINE:
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

func _generate_quest_parameters(quest_type: String, poi_type: GameEnums.CellType, poi_pos: Vector2i) -> Dictionary:
    """Génère les paramètres variables d'une quête"""
    
    var params := {
        "poi_pos": poi_pos,
        "poi_type": poi_type,
        "poi_id": "poi_%d_%d" % [poi_pos.x, poi_pos.y]
    }
    
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

func _generate_random_parameters(quest_type: String, tier: QuestTypes.QuestTier) -> Dictionary:
    """Génère des paramètres pour une quête générique"""
    
    var params := {
        "tier": tier,
        "generated": true
    }
    
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

# ========================================
# CRÉATION D'INSTANCE
# ========================================

func _create_quest_instance(quest_type: String, params: Dictionary, poi_pos: Vector2i) -> QuestInstance:
    """Crée une instance de quête à partir d'un template paramétré"""
    
    # Créer un template dynamique
    var template := _create_dynamic_template(quest_type, params)
    
    # Créer l'instance
    var instance := QuestInstance.new(template, params)
    
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
    
    return template

# ========================================
# RÉCOMPENSES DYNAMIQUESj
# ========================================

func _add_artifact_rewards(template: QuestTemplate, params: Dictionary) -> void:
    var faction :String = params.get("faction_interested", "humans")
    
    template.rewards.append(_create_reward(QuestTypes.RewardType.GOLD, 50, ""))
    template.rewards.append(_create_reward(QuestTypes.RewardType.FACTION_REP, 15, faction))
    template.rewards.append(_create_reward(QuestTypes.RewardType.TAG_PLAYER, 0, "artifact_hunter"))

func _add_delivery_rewards(template: QuestTemplate, params: Dictionary) -> void:
    var amount :int = params.get("resource_amount", 20)
    var gold_reward := amount * 2
    
    template.rewards.append(_create_reward(QuestTypes.RewardType.GOLD, gold_reward, ""))
    template.rewards.append(_create_reward(QuestTypes.RewardType.FACTION_REP, 10, "humans"))

func _add_combat_rewards(template: QuestTemplate, params: Dictionary) -> void:
    var tier: int = params.get("tier", 1)
    var gold := 30 * tier
    
    template.rewards.append(_create_reward(QuestTypes.RewardType.GOLD, gold, ""))
    if tier >= 2:
        template.rewards.append(_create_reward(QuestTypes.RewardType.FACTION_REP, 5, "humans"))

func _add_survival_rewards(template: QuestTemplate, params: Dictionary) -> void:
    var days :int = params.get("days", 5)
    var gold := days * 10
    
    template.rewards.append(_create_reward(QuestTypes.RewardType.GOLD, gold, ""))
    template.rewards.append(_create_reward(QuestTypes.RewardType.TAG_PLAYER, 0, "survivor"))

func _add_diplomacy_rewards(template: QuestTemplate, params: Dictionary) -> void:
    template.rewards.append(_create_reward(QuestTypes.RewardType.GOLD, 100, ""))
    template.rewards.append(_create_reward(QuestTypes.RewardType.TAG_PLAYER, 0, "diplomat"))

func _create_reward(type: QuestTypes.RewardType, amount: int, target_id: String) -> QuestReward:
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
    if FactionManager.has_faction(faction_id):
        return FactionManager.get_faction(faction_id).name
    return faction_id.capitalize()

# ========================================
# SEED CALCULATION
# ========================================

func _calculate_poi_seed(poi_pos: Vector2i) -> int:
    """Calcule un seed unique pour un POI basé sur sa position"""
    return world_seed + poi_pos.x * 1000 + poi_pos.y
