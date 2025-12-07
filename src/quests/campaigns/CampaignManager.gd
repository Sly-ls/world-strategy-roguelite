# res://src/quests/campaigns/CampaignManager.gd
extends Node

## Gestionnaire global des campagnes de quêtes
## PALIER 3 : Gère les chaînes de quêtes et leur progression

# ========================================
# SIGNAUX
# ========================================

signal campaign_started(campaign: QuestChain)
signal campaign_quest_advanced(campaign: QuestChain, quest_index: int)
signal campaign_completed(campaign: QuestChain)
signal campaign_failed(campaign: QuestChain)

# ========================================
# PROPRIÉTÉS
# ========================================

var available_campaigns: Dictionary = {}  ## campaign_id -> QuestChain (templates)
var active_campaigns: Dictionary = {}  ## campaign_id -> QuestChain (runtime instances)

var quest_to_campaign: Dictionary = {}  ## quest_id -> campaign_id (mapping)

# ========================================
# LIFECYCLE
# ========================================

func _ready() -> void:
    _load_campaigns()
    _connect_signals()
    print("✓ CampaignManager initialisé (%d campagnes disponibles)" % available_campaigns.size())

func _load_campaigns() -> void:
    """Charge toutes les campagnes depuis data/campaigns/"""
    var dir := DirAccess.open("res://data/campaigns/")
    if dir == null:
        print("⚠️ Dossier data/campaigns/ introuvable, création...")
        DirAccess.make_dir_recursive_absolute("res://data/campaigns/")
        return
    
    dir.list_dir_begin()
    var file_name := dir.get_next()
    while file_name != "":
        if file_name.ends_with(".tres") or file_name.ends_with(".res"):
            var campaign: QuestChain = load("res://data/campaigns/" + file_name)
            if campaign:
                available_campaigns[campaign.id] = campaign
                print("  ✓ Campagne chargée:", campaign.title)
        file_name = dir.get_next()
    dir.list_dir_end()

func _connect_signals() -> void:
    """Connecte aux signaux du QuestManager"""
    if QuestManager:
        QuestManager.quest_completed.connect(_on_quest_completed)
        QuestManager.quest_failed.connect(_on_quest_failed)

# ========================================
# GESTION DES CAMPAGNES
# ========================================

func start_campaign(campaign_id: String, context: Dictionary = {}) -> bool:
    """Démarre une campagne"""
    
    # Vérifier si déjà active
    if campaign_id in active_campaigns:
        print("⚠️ Campagne '%s' déjà active" % campaign_id)
        return false
    
    # Charger le template
    var template: QuestChain = available_campaigns.get(campaign_id)
    if not template:
        print("❌ Campagne '%s' introuvable" % campaign_id)
        return false
    
    # Vérifier conditions
    if not template.can_start():
        print("⚠️ Conditions non remplies pour campagne '%s'" % campaign_id)
        return false
    
    # Créer une instance runtime (copie)
    var campaign_instance := _duplicate_campaign(template)
    campaign_instance.started_at_day = WorldState.current_day
    
    # Activer
    active_campaigns[campaign_id] = campaign_instance
    
    # Émettre signal
    campaign_started.emit(campaign_instance)
    
    print("\n📖 === CAMPAGNE DÉMARRÉE ===")
    print("  Titre: %s" % campaign_instance.title)
    print("  Quêtes: %d" % campaign_instance.get_total_quests())
    print("  Jour: %d" % WorldState.current_day)
    
    # Démarrer la première quête
    _start_next_quest_in_campaign(campaign_id, context)
    
    return true

func _start_next_quest_in_campaign(campaign_id: String, context: Dictionary = {}) -> void:
    """Démarre la prochaine quête de la campagne"""
    
    var campaign: QuestChain = active_campaigns.get(campaign_id)
    if not campaign:
        print("❌ Campagne '%s' introuvable dans actives" % campaign_id)
        return
    
    # Vérifier si terminée
    if campaign.is_complete():
        _complete_campaign(campaign_id)
        return
    
    # Obtenir la règle de génération
    var rule := campaign.get_current_quest_rule()
    if rule.is_empty():
        print("❌ Aucune règle de génération pour index %d" % campaign.current_quest_index)
        return
    
    # Générer ou charger la quête
    var quest_instance: QuestInstance = _create_quest_from_rule(rule, context)
    
    if not quest_instance:
        print("❌ Impossible de créer la quête pour campagne '%s'" % campaign_id)
        return
    
    # Mapper quête → campagne
    quest_to_campaign[quest_instance.runtime_id] = campaign_id
    
    # Démarrer la quête
    QuestManager.start_quest_instance(quest_instance)
    
    # Émettre signal
    campaign_quest_advanced.emit(campaign, campaign.current_quest_index)
    
    print("  → Quête %d/%d démarrée: %s" % [
        campaign.current_quest_index + 1,
        campaign.get_total_quests(),
        quest_instance.template.title
    ])

func _create_quest_from_rule(rule: Dictionary, context: Dictionary) -> QuestInstance:
    """Crée une instance de quête selon la règle"""
    
    var quest_type: String = rule.get("type", "manual")
    
    match quest_type:
        "manual":
            # Quête écrite à la main
            var template: QuestTemplate = rule.get("template")
            if not template:
                print("❌ Template manquant dans règle manuelle")
                return null
            return template.instantiate(context)
        
        "generated":
            # Quête générée procéduralement
            var poi_type: int = rule.get("poi_type", GameEnums.CellType.RUINS)
            var complexity: String = rule.get("complexity", "simple")
            var poi_pos: Vector2i = context.get("poi_pos", Vector2i.ZERO)
            
            if complexity == "advanced":
                # Générer quête complexe (Palier 2 + 3)
                return QuestGenerator.generate_advanced_quest_for_poi(poi_pos, poi_type)
            else:
                # Générer quête simple (Palier 2)
                var template := QuestGenerator.generate_quest_for_poi(poi_pos, poi_type)
                return template.instantiate(context) if template else null
        
        _:
            print("❌ Type de règle inconnu: %s" % quest_type)
            return null

func _duplicate_campaign(template: QuestChain) -> QuestChain:
    """Crée une copie runtime d'une campagne"""
    var instance := QuestChain.new()
    
    # Copier propriétés
    instance.id = template.id
    instance.title = template.title
    instance.description = template.description
    instance.icon = template.icon
    instance.quest_generation_rules = template.quest_generation_rules.duplicate(true)
    instance.campaign_rewards = template.campaign_rewards.duplicate()
    instance.required_player_tags = template.required_player_tags.duplicate()
    instance.adds_player_tags = template.adds_player_tags.duplicate()
    
    # Réinitialiser progression
    instance.reset()
    
    return instance

# ========================================
# CALLBACKS QUÊTES
# ========================================

func _on_quest_completed(quest: QuestInstance) -> void:
    """Appelé quand une quête est complétée"""
    
    # Vérifier si c'est une quête de campagne
    var campaign_id: String = quest_to_campaign.get(quest.runtime_id, "")
    if campaign_id == "":
        return  # Pas une quête de campagne
    
    var campaign: QuestChain = active_campaigns.get(campaign_id)
    if not campaign:
        return
    
    print("📖 Quête de campagne '%s' complétée" % campaign.title)
    
    # Avancer la campagne
    campaign.advance_to_next_quest(quest.template.id)
    
    # Nettoyer le mapping
    quest_to_campaign.erase(quest.runtime_id)
    
    # Démarrer la quête suivante
    _start_next_quest_in_campaign(campaign_id)

func _on_quest_failed(quest: QuestInstance) -> void:
    """Appelé quand une quête échoue"""
    
    # Vérifier si c'est une quête de campagne
    var campaign_id: String = quest_to_campaign.get(quest.runtime_id, "")
    if campaign_id == "":
        return
    
    # Pour l'instant, on ne fait rien de spécial
    # (la campagne continue, mais on pourrait fail toute la campagne)
    quest_to_campaign.erase(quest.runtime_id)

func _complete_campaign(campaign_id: String) -> void:
    """Termine une campagne"""
    
    var campaign: QuestChain = active_campaigns.get(campaign_id)
    if not campaign:
        return
    
    print("\n🎉 === CAMPAGNE TERMINÉE ===")
    print("  Titre: %s" % campaign.title)
    print("  Durée: %d jours" % (WorldState.current_day - campaign.started_at_day))
    
    # Donner récompenses de campagne
    for reward in campaign.campaign_rewards:
        reward.apply()
        print("  → Récompense: %s" % reward.get_description())
    
    # Ajouter tags
    for tag in campaign.adds_player_tags:
        if not tag in QuestManager.player_tags:
            QuestManager.player_tags.append(tag)
            print("  → Tag ajouté: %s" % tag)
    
    # Émettre signal
    campaign_completed.emit(campaign)
    
    # Retirer des campagnes actives
    active_campaigns.erase(campaign_id)

# ========================================
# QUERIES
# ========================================

func get_active_campaigns() -> Array[QuestChain]:
    """Retourne toutes les campagnes actives"""
    var result: Array[QuestChain] = []
    for campaign in active_campaigns.values():
        result.append(campaign)
    return result

func is_campaign_active(campaign_id: String) -> bool:
    """Une campagne est-elle active ?"""
    return campaign_id in active_campaigns

func get_campaign_progress(campaign_id: String) -> float:
    """Progression d'une campagne (0.0 à 1.0)"""
    var campaign: QuestChain = active_campaigns.get(campaign_id)
    if not campaign:
        return 0.0
    return campaign.get_progress()
