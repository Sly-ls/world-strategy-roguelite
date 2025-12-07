# res://src/quests/core/QuestBranch.gd
class_name QuestBranch0ld extends Resource

## Branche de quête avec choix et conséquences
## PALIER 3 : Système de choix qui modifient la suite de la quête

# ========================================
# PROPRIÉTÉS
# ========================================

@export var id: String = ""  ## ID unique de la branche
@export var title: String = ""  ## Titre du choix
@export var description: String = ""  ## Description détaillée

@export var branch_type: BranchType = BranchType.CHOICE  ## Type de branche

enum BranchType {
    CHOICE,        ## Choix explicite du joueur
    CONDITION,     ## Déclenchement automatique par condition
    RANDOM,        ## Choix aléatoire
    SEQUENTIAL     ## Toujours pris (pas de branche)
}

# ========================================
# CHOIX
# ========================================

@export var choices: Array[BranchChoice] = []  ## Choix disponibles

# ========================================
# CONDITIONS DE DÉCLENCHEMENT
# ========================================

@export var trigger_conditions: Array[Dictionary] = []  ## Conditions pour activer la branche
@export var trigger_on_objective: String = ""  ## ID d'objectif qui déclenche la branche
@export var trigger_on_day: int = -1  ## Jour de déclenchement

# ========================================
# ÉTAT
# ========================================

var is_triggered: bool = false  ## La branche a-t-elle été déclenchée ?
var chosen_option: int = -1  ## Index du choix fait (-1 = pas encore choisi)
var triggered_on_day: int = -1  ## Jour où la branche a été déclenchée

# ========================================
# MÉTHODES
# ========================================

func trigger() -> void:
    """Déclenche la branche"""
    if is_triggered:
        return
    
    is_triggered = true
    triggered_on_day = WorldState.current_day
    print("🔀 Branche déclenchée : %s" % title)

func make_choice(choice_index: int) -> BranchChoice:
    """Fait un choix dans la branche"""
    if choice_index < 0 or choice_index >= choices.size():
        push_error("Invalid choice index: %d" % choice_index)
        return null
    
    chosen_option = choice_index
    var choice := choices[choice_index]
    
    print("➤ Choix fait : %s" % choice.title)
    return choice

func check_trigger_conditions() -> bool:
    """Vérifie si les conditions de déclenchement sont remplies"""
    if is_triggered:
        return false
    
    # Check jour
    if trigger_on_day > 0 and WorldState.current_day < trigger_on_day:
        return false
    
    # Check conditions
    if not trigger_conditions.is_empty():
        return QuestConditions.check_all_conditions(trigger_conditions)
    
    return true

func get_available_choices() -> Array[BranchChoice]:
    """Retourne les choix disponibles (selon conditions)"""
    var available: Array[BranchChoice] = []
    
    for choice in choices:
        if choice.check_conditions():
            available.append(choice)
    
    return available

func get_chosen_choice() -> BranchChoice:
    """Retourne le choix fait"""
    if chosen_option >= 0 and chosen_option < choices.size():
        return choices[chosen_option]
    return null

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
    @export var title: String = ""  ## Ex: "Garder l'artefact"
    @export var description: String = ""  ## Conséquences
    
    # Conditions d'affichage
    @export var required_conditions: Array[Dictionary] = []
    
    # Conséquences immédiates
    @export var immediate_rewards: Array[QuestReward] = []
    @export var immediate_consequences: Dictionary = {}  ## {"faction": "humans", "relation_change": -20}
    
    # Objectifs ajoutés/retirés
    @export var adds_objectives: Array[String] = []  ## IDs d'objectifs à ajouter
    @export var removes_objectives: Array[String] = []  ## IDs d'objectifs à retirer
    @export var fails_objectives: Array[String] = []  ## IDs d'objectifs à faire échouer
    
    # Tags
    @export var adds_player_tags: Array[String] = []
    @export var removes_player_tags: Array[String] = []
    @export var adds_world_tags: Array[String] = []
    
    # Suite de la quête
    @export var next_branch_id: String = ""  ## Branche suivante
    @export var completes_quest: bool = false  ## Ce choix complète-t-il la quête ?
    @export var fails_quest: bool = false  ## Ce choix fait-il échouer la quête ?
    
    func check_conditions() -> bool:
        """Vérifie si le choix est disponible"""
        if required_conditions.is_empty():
            return true
        return QuestConditions.check_all_conditions(required_conditions)
    
    func apply_consequences() -> void:
        """Applique les conséquences du choix"""
        # Récompenses immédiates
        for reward in immediate_rewards:
            _apply_single_reward(reward)
        
        # Conséquences custom
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
        
        print("✓ Conséquences appliquées pour choix : %s" % title)
    
    func _apply_single_reward(reward: QuestReward) -> void:
        """Applique une récompense individuelle"""
        match reward.type:
            QuestTypes.RewardType.GOLD:
                ResourceManager.add_resource("gold", reward.amount)
            
            QuestTypes.RewardType.FOOD:
                ResourceManager.add_resource("food", reward.amount)
            
            QuestTypes.RewardType.FACTION_REP:
                if reward.target_id:
                    FactionManager.adjust_relation(reward.target_id, reward.amount)
            
            QuestTypes.RewardType.TAG_PLAYER:
                QuestManager.add_player_tag(reward.target_id)
            
            QuestTypes.RewardType.TAG_WORLD:
                QuestManager.add_world_tag(reward.target_id)
