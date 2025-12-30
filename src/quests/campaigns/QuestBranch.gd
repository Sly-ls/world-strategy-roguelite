# res://src/quests/campaigns/QuestBranch.gd
class_name QuestBranch
extends Resource

## Branche de choix dans une quête
## PALIER 3 : Gestion des choix et conséquences

# ========================================
# PROPRIÉTÉS
# ========================================

@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var icon: Texture2D = null

# ========================================
# EFFETS DE LA BRANCHE
# ========================================

@export var rewards: Array[QuestReward] = []  ## Récompenses spécifiques à ce choix
@export var adds_tags: Array[String] = []  ## Tags ajoutés si ce choix est pris
@export var removes_tags: Array[String] = []  ## Tags retirés

# ========================================
# QUÊTES SUIVANTES
# ========================================

@export var leads_to_quest: String = ""  ## ID de quête débloquée par ce choix
@export var blocks_quests: Array[String] = []  ## IDs de quêtes bloquées par ce choix

# ========================================
# CONDITIONS
# ========================================

@export var required_tags: Array[String] = []  ## Tags requis pour prendre ce choix
@export var required_gold: int = 0  ## Or requis
@export var required_items: Array[String] = []  ## Items requis

var is_triggered: bool = false  ## La branche a été déclenchée
var chosen_option: int = -1  ## Index du choix fait (-1 = pas encore choisi)
var triggered_on_day: int = -1  ## Jour où la branche a été déclenchée
# ========================================
# MÉTHODES
# ========================================

func can_choose() -> bool:
    """Peut-on choisir cette branche ?"""
    
    # Vérifier tags
    for tag in required_tags:
        if not tag in QuestManager.player_tags:
            return false
    
    # Vérifier or (si implémenté)
    if required_gold > 0:
        # TODO: Vérifier or du joueur
        pass
    
    return true

func apply_effects() -> void:
    """Applique les effets de la branche choisie"""
    
    # Donner récompenses
    for reward in rewards:
        reward.apply()
    
    # Ajouter tags
    for tag in adds_tags:
        if not tag in QuestManager.player_tags:
            QuestManager.player_tags.append(tag)
            myLogger.debug("  → Tag ajouté: %s" % tag, LogTypes.Domain.QUEST)
    
    # Retirer tags
    for tag in removes_tags:
        QuestManager.player_tags.erase(tag)
        myLogger.debug("  → Tag retiré: %s" % tag, LogTypes.Domain.QUEST)
    
    # Débloquer quête suivante
    if leads_to_quest != "":
        myLogger.debug("  → Quête débloquée: %s" % leads_to_quest, LogTypes.Domain.QUEST)
        # TODO: Démarrer la quête suivante
    
    # Bloquer quêtes
    for quest_id in blocks_quests:
        myLogger.debug("  → Quête bloquée: %s" % quest_id, LogTypes.Domain.QUEST)
        # TODO: Bloquer la quête
# ========================================
# PERSISTANCE
# ========================================

func save_state() -> Dictionary:
    return {
        "id": id,
        "is_triggered": is_triggered,
        "chosen_option": chosen_option,
        "triggered_on_day": triggered_on_day
    }

static func load_from_state(branch: QuestBranch, data: Dictionary) -> void:
    branch.is_triggered = data.get("is_triggered", false)
    branch.chosen_option = data.get("chosen_option", -1)
    branch.triggered_on_day = data.get("triggered_on_day", -1)
# ========================================
# BRANCH CHOICE (sous-classe)
# ========================================

class BranchChoice extends Resource:
    """Choix individuel dans une branche"""
    
    @export var id: String = ""
    @export var title: String = ""
    @export var description: String = ""
    
    # Conditions
    @export var required_conditions: Array[Dictionary] = []
    
    # Conséquences
    @export var immediate_rewards: Array[QuestReward] = []
    @export var immediate_consequences: Dictionary = {}
    
    # Objectifs
    @export var adds_objectives: Array[String] = []
    @export var removes_objectives: Array[String] = []
    @export var fails_objectives: Array[String] = []
    
    # Tags
    @export var adds_player_tags: Array[String] = []
    @export var removes_player_tags: Array[String] = []
    @export var adds_world_tags: Array[String] = []
    
    # Suite
    @export var next_branch_id: String = ""
    @export var completes_quest: bool = false
    @export var fails_quest: bool = false
    
    func check_conditions() -> bool:
        if required_conditions.is_empty():
            return true
        return QuestConditions.check_all_conditions(required_conditions)
    
    func apply_consequences() -> void:
        # Récompenses
        for reward in immediate_rewards:
            _apply_single_reward(reward)
        
        # Relations faction
        if immediate_consequences.has("faction"):
            var faction_id: String = immediate_consequences["faction"]
            var relation_change: int = immediate_consequences.get("relation_change", 0)
            FactionManager.adjust_relation(faction_id, relation_change)
        
        # Tags
        for tag in adds_player_tags:
            QuestManager.add_player_tag(tag)
        for tag in removes_player_tags:
            QuestManager.remove_player_tag(tag)
        for tag in adds_world_tags:
            QuestManager.add_world_tag(tag)
    
    func _apply_single_reward(reward: QuestReward) -> void:
        match reward.reward_type:
            QuestTypes.RewardType.GOLD:
                WorldState.add_gold(reward.value)
            QuestTypes.RewardType.FOOD:
                WorldState.add_food(reward.value)
            QuestTypes.RewardType.FACTION_REP:
                if reward.target_faction:
                    FactionManager.adjust_relation(reward.target_faction, reward.value)
