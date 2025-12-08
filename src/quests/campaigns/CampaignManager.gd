
# res://src/quests/campaigns/CampaignManager.gd
extends Node

## Gestionnaire HYBRIDE : Palier 2-3 + Palier 4
## Gère à la fois :
## - QuestChain (campagnes procédurales)
## - FactionCampaign (campagnes narratives)

# ========================================
# SIGNAUX (compatibilité)
# ========================================

# Signaux génériques (nouveaux)
signal campaign_started_generic(campaign_id: String, type: String)
signal campaign_completed_generic(campaign_id: String, type: String)
signal campaign_failed_generic(campaign_id: String, type: String)

# Signaux legacy (Palier 2-3) - gardés pour compatibilité
signal campaign_started(campaign: QuestChain)
signal campaign_quest_advanced(campaign: QuestChain, quest_index: int)
signal campaign_completed(campaign: QuestChain)
signal campaign_failed(campaign: QuestChain)

# Signaux Palier 4
signal faction_campaign_started(campaign_id: String)
signal faction_campaign_chapter_completed(campaign_id: String, chapter: int)
signal faction_campaign_completed(campaign_id: String)
signal faction_campaign_failed(campaign_id: String)

# ========================================
# PROPRIÉTÉS
# ========================================

# Palier 2-3 : Campagnes procédurales
var quest_chains: Dictionary = {}  ## campaign_id -> QuestChain (templates)
var active_quest_chains: Dictionary = {}  ## campaign_id -> QuestChain (runtime)
var quest_to_campaign: Dictionary = {}  ## quest_id -> campaign_id

# Palier 4 : Campagnes narratives
var faction_campaigns: Dictionary = {}  ## campaign_id -> FactionCampaign
var active_faction_campaigns: Dictionary = {}  ## campaign_id -> FactionCampaign
var completed_faction_campaigns: Array[String] = []

# ========================================
# LIFECYCLE
# ========================================

func _ready() -> void:
    _load_all_campaigns()
    _connect_signals()
    
    print("✓ CampaignManager hybride initialisé")
    print("  - %d campagnes procédurales (QuestChain)" % quest_chains.size())
    print("  - %d campagnes narratives (FactionCampaign)" % faction_campaigns.size())

func _load_all_campaigns() -> void:
    """Charge tous les types de campagnes"""
    _load_quest_chains()
    _load_faction_campaigns()

func _load_quest_chains() -> void:
    """Charge les campagnes procédurales depuis data/campaigns/procedural/"""
    var dir := DirAccess.open("res://data/campaigns/procedural/")
    if dir == null:
        print("  ℹ️ Pas de campagnes procédurales (créer data/campaigns/procedural/)")
        DirAccess.make_dir_recursive_absolute("res://data/campaigns/procedural/")
        return
    
    dir.list_dir_begin()
    var file_name := dir.get_next()
    while file_name != "":
        if file_name.ends_with(".tres"):
            var campaign: QuestChain = load("res://data/campaigns/procedural/" + file_name)
            if campaign:
                quest_chains[campaign.id] = campaign
                print("  ✓ QuestChain chargée: %s" % campaign.title)
        file_name = dir.get_next()
    dir.list_dir_end()

func _load_faction_campaigns() -> void:
    """Charge les campagnes narratives depuis data/campaigns/factions/"""
    var dir := DirAccess.open("res://data/campaigns/factions/")
    if dir == null:
        print("  ℹ️ Pas de campagnes de faction (créer data/campaigns/factions/)")
        DirAccess.make_dir_recursive_absolute("res://data/campaigns/factions/")
        return
    
    dir.list_dir_begin()
    var file_name := dir.get_next()
    while file_name != "":
        if file_name.ends_with(".tres"):
            var campaign: FactionCampaign = load("res://data/campaigns/factions/" + file_name)
            if campaign:
                faction_campaigns[campaign.id] = campaign
                print("  ✓ FactionCampaign chargée: %s (%s)" % [
                    campaign.title,
                    campaign.faction_id
                ])
        file_name = dir.get_next()
    dir.list_dir_end()

func _connect_signals() -> void:
    """Connecte aux signaux du QuestManager"""
    if QuestManager:
        QuestManager.quest_completed.connect(_on_quest_completed)
        QuestManager.quest_failed.connect(_on_quest_failed)

# ========================================
# API UNIFIÉE
# ========================================

func start_campaign(campaign_id: String, context: Dictionary = {}) -> bool:
    """Démarre une campagne (détecte automatiquement le type)"""
    
    # Type 1 : FactionCampaign (prioritaire)
    if faction_campaigns.has(campaign_id):
        return _start_faction_campaign(campaign_id)
    
    # Type 2 : QuestChain
    if quest_chains.has(campaign_id):
        return _start_quest_chain(campaign_id, context)
    
    push_error("Campaign '%s' introuvable" % campaign_id)
    return false

func get_campaign_type(campaign_id: String) -> String:
    """Retourne le type de campagne : 'faction', 'procedural', ou ''"""
    if faction_campaigns.has(campaign_id):
        return "faction"
    if quest_chains.has(campaign_id):
        return "procedural"
    return ""

func is_campaign_active(campaign_id: String) -> bool:
    """Vérifie si une campagne est active (quelque soit le type)"""
    return (active_faction_campaigns.has(campaign_id) or 
            active_quest_chains.has(campaign_id))

func get_all_available_campaigns() -> Array[Dictionary]:
    """Retourne toutes les campagnes disponibles avec leur type"""
    var result: Array[Dictionary] = []
    
    # FactionCampaigns
    for id in faction_campaigns:
        var fc: FactionCampaign = faction_campaigns[id]
        if fc.can_start():
            result.append({
                "id": id,
                "type": "faction",
                "title": fc.title,
                "description": fc.description,
                "faction_id": fc.faction_id,
                "resource": fc
            })
    
    # QuestChains
    for id in quest_chains:
        var qc: QuestChain = quest_chains[id]
        if qc.can_start():
            result.append({
                "id": id,
                "type": "procedural",
                "title": qc.title,
                "description": qc.description,
                "resource": qc
            })
    
    return result

# ========================================
# FACTION CAMPAIGNS (Palier 4)
# ========================================

func _start_faction_campaign(campaign_id: String) -> bool:
    """Démarre une campagne narrative"""
    
    var campaign: FactionCampaign = faction_campaigns.get(campaign_id)
    if not campaign:
        return false
    
    if not campaign.can_start():
        print("⚠️ Conditions non remplies pour '%s'" % campaign.title)
        return false
    
    if active_faction_campaigns.has(campaign_id):
        print("⚠️ Campagne déjà active: '%s'" % campaign.title)
        return false
    
    # Démarrer
    campaign.start()
    active_faction_campaigns[campaign_id] = campaign
    
    # Signaux
    faction_campaign_started.emit(campaign_id)
    campaign_started_generic.emit(campaign_id, "faction")
    
    print("\n🎬 === CAMPAGNE NARRATIVE DÉMARRÉE ===")
    print("  Titre: %s" % campaign.title)
    print("  Faction: %s" % campaign.faction_id)
    print("  Chapitres: %d" % campaign.max_chapters)
    
    return true

func complete_faction_campaign_chapter(campaign_id: String) -> void:
    """Complète le chapitre actuel d'une campagne narrative"""
    var campaign: FactionCampaign = active_faction_campaigns.get(campaign_id)
    if not campaign:
        return
    
    var chapter := campaign.current_chapter
    faction_campaign_chapter_completed.emit(campaign_id, chapter)
    
    campaign.advance_chapter()
    
    if campaign.is_completed():
        _complete_faction_campaign(campaign_id)

func _complete_faction_campaign(campaign_id: String) -> void:
    """Termine une campagne narrative"""
    var campaign: FactionCampaign = active_faction_campaigns.get(campaign_id)
    if not campaign:
        return
    
    active_faction_campaigns.erase(campaign_id)
    completed_faction_campaigns.append(campaign_id)
    
    # Signaux
    faction_campaign_completed.emit(campaign_id)
    campaign_completed_generic.emit(campaign_id, "faction")

func fail_faction_campaign(campaign_id: String) -> void:
    """Fait échouer une campagne narrative"""
    var campaign: FactionCampaign = active_faction_campaigns.get(campaign_id)
    if not campaign:
        return
    
    campaign.fail()
    active_faction_campaigns.erase(campaign_id)
    
    # Signaux
    faction_campaign_failed.emit(campaign_id)
    campaign_failed_generic.emit(campaign_id, "faction")

# ========================================
# QUEST CHAINS (Palier 2-3) - CODE EXISTANT
# ========================================

func _start_quest_chain(campaign_id: String, context: Dictionary = {}) -> bool:
    """Démarre une campagne procédurale (code Palier 2-3 existant)"""
    
    if campaign_id in active_quest_chains:
        print("⚠️ Campagne '%s' déjà active" % campaign_id)
        return false
    
    var template: QuestChain = quest_chains.get(campaign_id)
    if not template:
        print("❌ Campagne '%s' introuvable" % campaign_id)
        return false
    
    if not template.can_start():
        print("⚠️ Conditions non remplies pour campagne '%s'" % campaign_id)
        return false
    
    # Créer une instance runtime (copie)
    var campaign_instance := _duplicate_quest_chain(template)
    campaign_instance.started_at_day = WorldState.current_day
    
    active_quest_chains[campaign_id] = campaign_instance
    
    # Signaux (legacy + nouveau)
    campaign_started.emit(campaign_instance)
    campaign_started_generic.emit(campaign_id, "procedural")
    
    print("\n📖 === CAMPAGNE PROCÉDURALE DÉMARRÉE ===")
    print("  Titre: %s" % campaign_instance.title)
    print("  Quêtes: %d" % campaign_instance.get_total_quests())
    print("  Jour: %d" % WorldState.current_day)
    
    # Démarrer la première quête
    _start_next_quest_in_chain(campaign_id, context)
    
    return true

func _start_next_quest_in_chain(campaign_id: String, context: Dictionary = {}) -> void:
    """Démarre la prochaine quête d'une QuestChain (code existant Palier 2-3)"""
    
    var campaign: QuestChain = active_quest_chains.get(campaign_id)
    if not campaign:
        return
    
    if campaign.is_complete():
        _complete_quest_chain(campaign_id)
        return
    
    var rule := campaign.get_current_quest_rule()
    if rule.is_empty():
        print("❌ Aucune règle de génération pour index %d" % campaign.current_quest_index)
        return
    
    var quest_instance: QuestInstance = _create_quest_from_rule(rule, context)
    if not quest_instance:
        return
    
    quest_to_campaign[quest_instance.runtime_id] = campaign_id
    QuestManager.start_quest_instance(quest_instance)
    
    campaign_quest_advanced.emit(campaign, campaign.current_quest_index)
    
    print("  → Quête %d/%d démarrée: %s" % [
        campaign.current_quest_index + 1,
        campaign.get_total_quests(),
        quest_instance.template.title
    ])

func _create_quest_from_rule(rule: Dictionary, context: Dictionary) -> QuestInstance:
    """Crée une instance de quête selon la règle (code existant)"""
    
    var quest_type: String = rule.get("type", "manual")
    
    match quest_type:
        "manual":
            var template: QuestTemplate = rule.get("template")
            if not template:
                return null
            return template.instantiate(context)
        
        "generated":
            var poi_type: int = rule.get("poi_type", GameEnums.CellType.RUINS)
            var complexity: String = rule.get("complexity", "simple")
            var poi_pos: Vector2i = context.get("poi_pos", Vector2i.ZERO)
            
            if complexity == "advanced":
                return QuestGenerator.generate_advanced_quest_for_poi(poi_pos, poi_type)
            else:
                var template := QuestGenerator.generate_quest_for_poi(poi_pos, poi_type)
                return template.instantiate(context) if template else null
        
        _:
            return null

func _duplicate_quest_chain(template: QuestChain) -> QuestChain:
    """Crée une copie runtime d'une QuestChain (code existant)"""
    var instance := QuestChain.new()
    
    instance.id = template.id
    instance.title = template.title
    instance.description = template.description
    instance.icon = template.icon
    instance.quest_generation_rules = template.quest_generation_rules.duplicate(true)
    instance.campaign_rewards = template.campaign_rewards.duplicate()
    instance.required_player_tags = template.required_player_tags.duplicate()
    instance.adds_player_tags = template.adds_player_tags.duplicate()
    
    instance.reset()
    
    return instance

func _complete_quest_chain(campaign_id: String) -> void:
    """Termine une QuestChain (code existant Palier 2-3)"""
    
    var campaign: QuestChain = active_quest_chains.get(campaign_id)
    if not campaign:
        return
    
    print("\n🎉 === CAMPAGNE PROCÉDURALE TERMINÉE ===")
    print("  Titre: %s" % campaign.title)
    print("  Durée: %d jours" % (WorldState.current_day - campaign.started_at_day))
    
    for reward in campaign.campaign_rewards:
        reward.apply()
        print("  → Récompense: %s" % reward.get_description())
    
    for tag in campaign.adds_player_tags:
        if not tag in QuestManager.player_tags:
            QuestManager.player_tags.append(tag)
            print("  → Tag ajouté: %s" % tag)
    
    # Signaux (legacy + nouveau)
    campaign_completed.emit(campaign)
    campaign_completed_generic.emit(campaign_id, "procedural")
    
    active_quest_chains.erase(campaign_id)

# ========================================
# CALLBACKS QUÊTES
# ========================================

func _on_quest_completed(quest: QuestInstance) -> void:
    """Appelé quand une quête est complétée"""
    
    # Type 1 : Quête de QuestChain (procédural)
    var qc_campaign_id: String = quest_to_campaign.get(quest.runtime_id, "")
    if qc_campaign_id != "":
        var campaign: QuestChain = active_quest_chains.get(qc_campaign_id)
        if campaign:
            print("📖 Quête de campagne procédurale '%s' complétée" % campaign.title)
            campaign.advance_to_next_quest(quest.template.id)
            quest_to_campaign.erase(quest.runtime_id)
            _start_next_quest_in_chain(qc_campaign_id)
        return
    
    # Type 2 : Quête de FactionCampaign (narrative)
    for fc_campaign_id in active_faction_campaigns:
        var fc: FactionCampaign = active_faction_campaigns[fc_campaign_id]
        if fc.get_current_quest_id() == quest.template.id:
            complete_faction_campaign_chapter(fc_campaign_id)
            return

func _on_quest_failed(quest: QuestInstance) -> void:
    """Appelé quand une quête échoue"""
    
    # Type 1 : QuestChain
    var qc_campaign_id: String = quest_to_campaign.get(quest.runtime_id, "")
    if qc_campaign_id != "":
        quest_to_campaign.erase(quest.runtime_id)
        # Pour l'instant on continue
        return
    
    # Type 2 : FactionCampaign
    for fc_campaign_id in active_faction_campaigns:
        var fc: FactionCampaign = active_faction_campaigns[fc_campaign_id]
        if fc.get_current_quest_id() == quest.template.id:
            fail_faction_campaign(fc_campaign_id)
            return

# ========================================
# QUERIES
# ========================================

func get_active_quest_chains() -> Array[QuestChain]:
    """Retourne les campagnes procédurales actives"""
    var result: Array[QuestChain] = []
    for campaign in active_quest_chains.values():
        result.append(campaign)
    return result

func get_active_faction_campaigns() -> Array[FactionCampaign]:
    """Retourne les campagnes narratives actives"""
    var result: Array[FactionCampaign] = []
    for campaign in active_faction_campaigns.values():
        result.append(campaign)
    return result

func get_available_faction_campaigns() -> Array[FactionCampaign]:
    """Retourne les campagnes narratives disponibles"""
    var result: Array[FactionCampaign] = []
    for fc_id in faction_campaigns:
        var fc: FactionCampaign = faction_campaigns[fc_id]
        if fc.can_start():
            result.append(fc)
    return result

func get_campaigns_by_faction(faction_id: String) -> Array[FactionCampaign]:
    """Retourne toutes les campagnes d'une faction"""
    var result: Array[FactionCampaign] = []
    for fc_id in faction_campaigns:
        var fc: FactionCampaign = faction_campaigns[fc_id]
        if fc.faction_id == faction_id:
            result.append(fc)
    return result

# ========================================
# PERSISTANCE
# ========================================

func save_state() -> Dictionary:
    """Sauvegarde l'état des deux types de campagnes"""
    
    # QuestChains
    var qc_states := {}
    for id in active_quest_chains:
        var qc: QuestChain = active_quest_chains[id]
        qc_states[id] = {
            "current_quest_index": qc.current_quest_index,
            "completed_quest_ids": qc.completed_quest_ids,
            "started_at_day": qc.started_at_day
        }
    
    # FactionCampaigns
    var fc_states := {}
    for id in active_faction_campaigns:
        var fc: FactionCampaign = active_faction_campaigns[id]
        fc_states[id] = fc.save_state()
    
    var all_fc_states := {}
    for id in faction_campaigns:
        var fc: FactionCampaign = faction_campaigns[id]
        all_fc_states[id] = fc.save_state()
    
    return {
        "quest_chains": qc_states,
        "faction_campaigns": fc_states,
        "all_faction_campaign_states": all_fc_states,
        "completed_faction_campaigns": completed_faction_campaigns,
        "quest_to_campaign": quest_to_campaign
    }

func load_state(data: Dictionary) -> void:
    """Charge l'état des deux types de campagnes"""
    
    # Restore QuestChains
    var qc_states: Dictionary = data.get("quest_chains", {})
    for id in qc_states:
        if quest_chains.has(id):
            var template: QuestChain = quest_chains[id]
            var instance := _duplicate_quest_chain(template)
            
            var state: Dictionary = qc_states[id]
            instance.current_quest_index = state.get("current_quest_index", 0)
            instance.completed_quest_ids = state.get("completed_quest_ids", [])
            instance.started_at_day = state.get("started_at_day", 0)
            
            active_quest_chains[id] = instance
    
    # Restore FactionCampaigns
    var all_fc_states: Dictionary = data.get("all_faction_campaign_states", {})
    for id in all_fc_states:
        if faction_campaigns.has(id):
            var fc: FactionCampaign = faction_campaigns[id]
            FactionCampaign.load_from_state(fc, all_fc_states[id])
    
    var fc_states: Dictionary = data.get("faction_campaigns", {})
    for id in fc_states:
        if faction_campaigns.has(id):
            active_faction_campaigns[id] = faction_campaigns[id]
    
    completed_faction_campaigns = data.get("completed_faction_campaigns", [])
    quest_to_campaign = data.get("quest_to_campaign", {})
    
    print("✓ État des campagnes chargé")
