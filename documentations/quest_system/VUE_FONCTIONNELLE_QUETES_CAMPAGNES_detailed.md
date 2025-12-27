# Vue Fonctionnelle Détaillée : Système de Quêtes et Campagnes

---

## Table des Matières

1. [Vue d'ensemble du système](#1-vue-densemble-du-système)
2. [Architecture complète des classes](#2-architecture-complète-des-classes)
3. [Génération procédurale et algorithmes](#3-génération-procédurale-et-algorithmes)
4. [Système de conditions et tags](#4-système-de-conditions-et-tags)
5. [Intégrations inter-systèmes](#5-intégrations-inter-systèmes)
6. [Exemples de code complets](#6-exemples-de-code-complets)
7. [Organisation des fichiers](#7-organisation-des-fichiers)

---

## 1. Vue d'ensemble du système

Le système de quêtes et campagnes est organisé en **5 niveaux de complexité** (tiers), formant une hiérarchie cohérente qui va des quêtes simples aux crises mondiales affectant tout le monde de jeu.

### Architecture en Tiers

```
Tier 1: Quêtes Simples (QuestTemplate + QuestInstance)
  │
  ├─ Objectif unique
  ├─ Récompense directe
  └─ Conditions d'apparition simples
  
Tier 2-3: Campagnes Procédurales (QuestChain)
  │
  ├─ 2-5 quêtes séquentielles
  ├─ Génération algorithmique
  ├─ Cohérence thématique
  └─ Progression de difficulté
  
Tier 4: Campagnes Narratives (FactionCampaign)
  │
  ├─ 5+ chapitres structurés
  ├─ Arcs narratifs écrits
  ├─ Impact sur relations factions
  └─ Modifications du monde persistantes
  
Tier 5: Crises Mondiales (WorldCrisis)
  │
  ├─ Événements globaux temporisés
  ├─ Objectifs de contribution partagés
  ├─ Phases avec évolution
  └─ Conséquences majeures (succès/échec)
```

### Flux de Données Global

```
┌─────────────────┐
│ WorldGameState  │ (Orchestrateur principal)
│                 │
│ - current_day   │
│ - world_tags    │
│ - player_data   │
└────────┬────────┘
         │
         ├──────────────┬──────────────┬──────────────┐
         │              │              │              │
         ▼              ▼              ▼              ▼
  ┌──────────┐   ┌──────────┐  ┌──────────┐  ┌──────────┐
  │  Quest   │   │Campaign  │  │ Crisis   │  │ Faction  │
  │ Manager  │◄─►│ Manager  │◄─►│ Manager  │◄─►│ Manager  │
  └──────────┘   └──────────┘  └──────────┘  └──────────┘
       │              │              │              │
       ├──────────────┴──────────────┴──────────────┘
       │
       ▼
  ┌──────────┐
  │ EventBus │ (Communication inter-systèmes)
  └──────────┘
```

### Managers et Orchestration

Le système utilise plusieurs managers singleton qui orchestrent les différents aspects :

- **QuestManager** : Gestionnaire central des quêtes (disponibles, actives, complétées)
- **CampaignManager** : Génération procédurale et suivi des campagnes narratives
- **CrisisManager** : Déclenchement, phases et résolution des crises mondiales
- **FactionManager** : Relations entre factions et leur impact sur les quêtes
- **WorldGameState** : État global du monde, orchestrateur de haut niveau

---

## 2. Architecture complète des classes

### 2.1 QuestTypes (Autoload Singleton)

**Rôle** : Centralise tous les enums et constantes du système de quêtes.

**Fichier** : `src/quests/quest_types.gd`

```gdscript
class_name QuestTypes extends Node

# ============================================================
# ENUMS PRINCIPAUX
# ============================================================

## Niveaux de complexité des quêtes
enum Tier {
    TIER_1 = 1,  ## Quêtes simples, objectif unique
    TIER_2 = 2,  ## Chaînes courtes (2-3 quêtes)
    TIER_3 = 3,  ## Chaînes moyennes (3-5 quêtes)
    TIER_4 = 4,  ## Campagnes narratives (5+ chapitres)
    TIER_5 = 5   ## Crises mondiales
}

## Catégories thématiques de quêtes
enum Category {
    COMBAT,      ## Affrontements, éliminations
    EXPLORATION, ## Découverte, voyages
    DIPLOMACY,   ## Négociations, traités
    TRADE,       ## Commerce, transport
    STEALTH,     ## Infiltration, espionnage
    DEFENSE,     ## Protection, siège
    RESCUE,      ## Sauvetage, évacuation
    INVESTIGATION ## Enquête, recherche d'informations
}

## États d'une quête
enum Status {
    LOCKED,      ## Conditions non remplies
    AVAILABLE,   ## Peut être démarrée
    ACTIVE,      ## En cours
    COMPLETED,   ## Terminée avec succès
    FAILED,      ## Échouée
    EXPIRED      ## Délai dépassé
}

## Types d'objectifs
enum ObjectiveType {
    DEFEAT,      ## Vaincre des ennemis
    REACH,       ## Atteindre un lieu
    COLLECT,     ## Collecter des objets
    PROTECT,     ## Protéger une cible
    NEGOTIATE,   ## Réussir une négociation
    ESCORT,      ## Escorter une unité
    SURVIVE,     ## Survivre X tours
    CONTROL,     ## Contrôler une zone
    DESTROY      ## Détruire une structure
}

## Types de récompenses
enum RewardType {
    GOLD,        ## Or
    ITEMS,       ## Objets/équipement
    REPUTATION,  ## Réputation de faction
    UNLOCK,      ## Débloque contenu
    RESOURCE,    ## Ressources diverses
    EXPERIENCE,  ## XP d'unité
    TERRITORY    ## Territoire/région
}

# ============================================================
# CONSTANTES
# ============================================================

const MAX_ACTIVE_QUESTS: int = 10
const MAX_OBJECTIVES_PER_QUEST: int = 5
const DEFAULT_QUEST_EXPIRY_DAYS: int = 30

# ============================================================
# HELPERS STATIQUES
# ============================================================

## Retourne le nom lisible d'un tier
static func get_tier_name(tier: Tier) -> String:
    match tier:
        Tier.TIER_1: return "Simple"
        Tier.TIER_2: return "Chaîne Courte"
        Tier.TIER_3: return "Chaîne Moyenne"
        Tier.TIER_4: return "Campagne Narrative"
        Tier.TIER_5: return "Crise Mondiale"
        _: return "Inconnu"

## Retourne l'icône associée à une catégorie
static func get_category_icon(category: Category) -> String:
    match category:
        Category.COMBAT: return "res://assets/icons/sword.png"
        Category.EXPLORATION: return "res://assets/icons/compass.png"
        Category.DIPLOMACY: return "res://assets/icons/handshake.png"
        Category.TRADE: return "res://assets/icons/coins.png"
        Category.STEALTH: return "res://assets/icons/dagger.png"
        Category.DEFENSE: return "res://assets/icons/shield.png"
        Category.RESCUE: return "res://assets/icons/help.png"
        Category.INVESTIGATION: return "res://assets/icons/magnifier.png"
        _: return ""

## Vérifie si une catégorie est orientée combat
static func is_combat_category(category: Category) -> bool:
    return category in [Category.COMBAT, Category.DEFENSE, Category.STEALTH]

## Retourne la couleur UI associée au statut
static func get_status_color(status: Status) -> Color:
    match status:
        Status.LOCKED: return Color.GRAY
        Status.AVAILABLE: return Color.YELLOW
        Status.ACTIVE: return Color.CYAN
        Status.COMPLETED: return Color.GREEN
        Status.FAILED: return Color.RED
        Status.EXPIRED: return Color.DARK_RED
        _: return Color.WHITE
```

---

### 2.2 QuestTemplate (Resource)

**Rôle** : Définition statique et réutilisable d'une quête (blueprint).

**Fichier** : `src/quests/quest_template.gd`

```gdscript
class_name QuestTemplate extends Resource

# ============================================================
# PROPRIÉTÉS EXPORT (éditables dans l'inspecteur)
# ============================================================

## Identifiant unique de la quête
@export var quest_id: String = ""

## Niveau de complexité (Tier 1 à 5)
@export var tier: QuestTypes.Tier = QuestTypes.Tier.TIER_1

## Catégorie thématique
@export var category: QuestTypes.Category = QuestTypes.Category.COMBAT

## Titre affiché dans l'UI
@export var title: String = ""

## Description narrative
@export_multiline var description: String = ""

## Texte affiché à la complétion
@export_multiline var completion_text: String = ""

## Liste des objectifs à accomplir
@export var objectives: Array[ObjectiveData] = []

## Liste des récompenses obtenues
@export var rewards: Array[RewardData] = []

## Conditions pour que la quête apparaisse
@export var conditions: QuestConditions = null

## Tags pour filtrage et génération procédurale
@export var tags: Array[String] = []

## Durée limite en jours (-1 = pas de limite)
@export var time_limit: int = -1

## La quête peut-elle être répétée ?
@export var repeatable: bool = false

## Délai minimum entre répétitions (jours)
@export var repeat_cooldown: int = 10

## Priorité d'affichage (plus élevé = plus haut dans la liste)
@export var display_priority: int = 0

# ============================================================
# PROPRIÉTÉS RUNTIME (non exportées)
# ============================================================

## Timestamp de dernière complétion (pour repeatable)
var last_completed_day: int = -1

## Nombre de fois complétée
var completion_count: int = 0

# ============================================================
# MÉTHODES PUBLIQUES
# ============================================================

## Ajoute un objectif à la quête
func add_objective(obj_type: QuestTypes.ObjectiveType, params: Dictionary) -> ObjectiveData:
    var obj = ObjectiveData.new()
    obj.type = obj_type
    obj.parameters = params
    objectives.append(obj)
    return obj

## Ajoute une récompense
func add_reward(reward_type: QuestTypes.RewardType, amount: int, extra_params: Dictionary = {}) -> RewardData:
    var reward = RewardData.new()
    reward.type = reward_type
    reward.amount = amount
    reward.parameters = extra_params
    rewards.append(reward)
    return reward

## Vérifie si les conditions d'apparition sont remplies
func check_availability(player_tags: Array[String], world_tags: Array[String], current_day: int) -> bool:
    if not conditions:
        return true
    return conditions.check_conditions(player_tags, world_tags, current_day)

## Vérifie si la quête peut être répétée maintenant
func can_repeat(current_day: int) -> bool:
    if not repeatable:
        return false
    if last_completed_day < 0:
        return true
    return (current_day - last_completed_day) >= repeat_cooldown

## Crée une instance runtime de cette quête
func create_instance(start_day: int) -> QuestInstance:
    var instance = QuestInstance.new()
    instance.template = self
    instance.status = QuestTypes.Status.ACTIVE
    instance.start_day = start_day
    instance.initialize_objectives()
    return instance

## Clone le template (pour génération procédurale)
func duplicate_template() -> QuestTemplate:
    var dup = self.duplicate(true)
    dup.quest_id = quest_id + "_" + str(randi())
    return dup

## Estime la difficulté globale (1-10)
func estimate_difficulty() -> int:
    var difficulty = 0
    
    # Basé sur le nombre d'objectifs
    difficulty += objectives.size()
    
    # Basé sur la catégorie
    if QuestTypes.is_combat_category(category):
        difficulty += 2
    
    # Basé sur les conditions
    if conditions and not conditions.required_completed_quests.is_empty():
        difficulty += conditions.required_completed_quests.size()
    
    # Basé sur le time limit
    if time_limit > 0 and time_limit < 10:
        difficulty += 2
    
    return clampi(difficulty, 1, 10)

## Valide que le template est bien formé
func validate() -> bool:
    if quest_id == "":
        push_error("Quest template missing quest_id")
        return false
    
    if title == "":
        push_error("Quest template missing title: " + quest_id)
        return false
    
    if objectives.is_empty():
        push_error("Quest template has no objectives: " + quest_id)
        return false
    
    if rewards.is_empty():
        push_warning("Quest template has no rewards: " + quest_id)
    
    return true
```

---

### 2.3 QuestInstance (RefCounted)

**Rôle** : État runtime d'une quête en cours.

**Fichier** : `src/quests/quest_instance.gd`

```gdscript
class_name QuestInstance extends RefCounted

# ============================================================
# PROPRIÉTÉS
# ============================================================

## Référence vers le template source
var template: QuestTemplate

## État actuel
var status: QuestTypes.Status = QuestTypes.Status.ACTIVE

## Jour de démarrage
var start_day: int = 0

## Jour de complétion/échec
var end_day: int = -1

## État de chaque objectif : objective_index -> { current: int, required: int, completed: bool }
var objectives_state: Dictionary = {}

## Journal des événements de la quête
var events: Array[QuestEvent] = []

## Données contextuelles supplémentaires
var context_data: Dictionary = {}

# ============================================================
# SIGNAUX
# ============================================================

signal objective_updated(objective_index: int, current: int, required: int)
signal objective_completed(objective_index: int)
signal quest_completed()
signal quest_failed(reason: String)

# ============================================================
# INITIALISATION
# ============================================================

## Initialise l'état des objectifs
func initialize_objectives() -> void:
    for i in range(template.objectives.size()):
        var obj = template.objectives[i]
        objectives_state[i] = {
            "current": 0,
            "required": obj.get_required_count(),
            "completed": false
        }

# ============================================================
# PROGRESSION
# ============================================================

## Met à jour la progression d'un objectif
func update_objective(objective_index: int, progress: int) -> void:
    if objective_index not in objectives_state:
        push_error("Objectif invalide: " + str(objective_index))
        return
    
    var state = objectives_state[objective_index]
    if state.completed:
        return  # Déjà complété
    
    state.current = clampi(state.current + progress, 0, state.required)
    objective_updated.emit(objective_index, state.current, state.required)
    
    # Log l'événement
    log_event("objective_progress", {
        "objective_index": objective_index,
        "progress": progress,
        "current": state.current,
        "required": state.required
    })
    
    # Vérifie si complété
    if state.current >= state.required:
        complete_objective(objective_index)
    
    # Vérifie si toute la quête est complétée
    check_completion()

## Définit un objectif comme complété
func complete_objective(objective_index: int) -> void:
    if objective_index not in objectives_state:
        return
    
    var state = objectives_state[objective_index]
    if state.completed:
        return
    
    state.completed = true
    state.current = state.required
    objective_completed.emit(objective_index)
    
    log_event("objective_completed", {"objective_index": objective_index})

## Vérifie si tous les objectifs sont complétés
func check_completion() -> bool:
    for state in objectives_state.values():
        if not state.completed:
            return false
    
    # Tous les objectifs complétés !
    complete_quest()
    return true

## Marque la quête comme complétée
func complete_quest() -> void:
    if status == QuestTypes.Status.COMPLETED:
        return
    
    status = QuestTypes.Status.COMPLETED
    end_day = WorldGameState.current_day
    log_event("quest_completed", {})
    quest_completed.emit()

## Marque la quête comme échouée
func fail_quest(reason: String) -> void:
    if status == QuestTypes.Status.FAILED:
        return
    
    status = QuestTypes.Status.FAILED
    end_day = WorldGameState.current_day
    log_event("quest_failed", {"reason": reason})
    quest_failed.emit(reason)

## Vérifie si le temps limite est dépassé
func check_expiry(current_day: int) -> bool:
    if template.time_limit <= 0:
        return false  # Pas de limite de temps
    
    var elapsed = current_day - start_day
    if elapsed > template.time_limit:
        fail_quest("time_expired")
        return true
    return false

# ============================================================
# UTILITAIRES
# ============================================================

## Obtient la progression globale (0.0 à 1.0)
func get_overall_progress() -> float:
    if objectives_state.is_empty():
        return 0.0
    
    var total_progress = 0.0
    for state in objectives_state.values():
        if state.required > 0:
            total_progress += float(state.current) / float(state.required)
    
    return total_progress / float(objectives_state.size())

## Obtient le temps restant (jours)
func get_days_remaining(current_day: int) -> int:
    if template.time_limit <= 0:
        return -1  # Pas de limite
    
    var elapsed = current_day - start_day
    return max(0, template.time_limit - elapsed)

## Ajoute un événement au journal
func log_event(event_type: String, data: Dictionary) -> void:
    var event = QuestEvent.new()
    event.type = event_type
    event.day = WorldGameState.current_day
    event.data = data
    events.append(event)

## Génère un résumé texte de l'état
func get_status_summary() -> String:
    var summary = "Quête: %s\n" % template.title
    summary += "Statut: %s\n" % QuestTypes.Status.keys()[status]
    summary += "Progression: %.0f%%\n" % (get_overall_progress() * 100)
    
    if template.time_limit > 0:
        var remaining = get_days_remaining(WorldGameState.current_day)
        summary += "Temps restant: %d jours\n" % remaining
    
    return summary

## Sauvegarde l'état
func save_to_dict() -> Dictionary:
    return {
        "template_id": template.quest_id,
        "status": status,
        "start_day": start_day,
        "end_day": end_day,
        "objectives_state": objectives_state,
        "context_data": context_data
    }

## Restaure l'état depuis un dictionnaire
func load_from_dict(data: Dictionary) -> void:
    status = data.get("status", QuestTypes.Status.ACTIVE)
    start_day = data.get("start_day", 0)
    end_day = data.get("end_day", -1)
    objectives_state = data.get("objectives_state", {})
    context_data = data.get("context_data", {})
```

---

### 2.4 ObjectiveData (Resource)

**Rôle** : Définit un objectif de quête.

**Fichier** : `src/quests/objective_data.gd`

```gdscript
class_name ObjectiveData extends Resource

# ============================================================
# PROPRIÉTÉS
# ============================================================

## Type d'objectif
@export var type: QuestTypes.ObjectiveType = QuestTypes.ObjectiveType.DEFEAT

## Description affichée
@export var description: String = ""

## Paramètres spécifiques au type
@export var parameters: Dictionary = {}
# Exemples de paramètres :
# - DEFEAT: { "enemy_type": "bandit", "count": 10, "specific_unit_id": "" }
# - REACH: { "location_id": "fortress_north", "radius": 2 }
# - COLLECT: { "item_id": "ancient_artifact", "count": 3 }
# - PROTECT: { "target_id": "caravan_01", "duration": 5 }
# - NEGOTIATE: { "faction_id": "merchant_guild", "min_reputation": 50 }
# - ESCORT: { "unit_id": "diplomat", "destination": "capital", "must_survive": true }
# - SURVIVE: { "turns": 10, "allowed_casualties": 2 }
# - CONTROL: { "zone_id": "hill_central", "duration": 3 }
# - DESTROY: { "structure_id": "enemy_tower", "count": 1 }

## Optionnel (null = obligatoire)
@export var optional: bool = false

## Objectif caché initialement ?
@export var hidden: bool = false

# ============================================================
# MÉTHODES
# ============================================================

## Retourne le nombre requis pour compléter l'objectif
func get_required_count() -> int:
    match type:
        QuestTypes.ObjectiveType.DEFEAT:
            return parameters.get("count", 1)
        QuestTypes.ObjectiveType.COLLECT:
            return parameters.get("count", 1)
        QuestTypes.ObjectiveType.PROTECT:
            return parameters.get("duration", 1)
        QuestTypes.ObjectiveType.SURVIVE:
            return parameters.get("turns", 1)
        QuestTypes.ObjectiveType.CONTROL:
            return parameters.get("duration", 1)
        QuestTypes.ObjectiveType.DESTROY:
            return parameters.get("count", 1)
        _:
            return 1  # La plupart des objectifs sont binaires

## Génère une description automatique si vide
func get_display_description() -> String:
    if description != "":
        return description
    
    # Génération automatique basée sur le type
    match type:
        QuestTypes.ObjectiveType.DEFEAT:
            var enemy = parameters.get("enemy_type", "ennemis")
            var count = parameters.get("count", 1)
            return "Vaincre %d %s" % [count, enemy]
        
        QuestTypes.ObjectiveType.REACH:
            var loc = parameters.get("location_id", "destination")
            return "Atteindre %s" % loc
        
        QuestTypes.ObjectiveType.COLLECT:
            var item = parameters.get("item_id", "objets")
            var count = parameters.get("count", 1)
            return "Collecter %d %s" % [count, item]
        
        QuestTypes.ObjectiveType.PROTECT:
            var target = parameters.get("target_id", "cible")
            var duration = parameters.get("duration", 1)
            return "Protéger %s pendant %d tours" % [target, duration]
        
        QuestTypes.ObjectiveType.ESCORT:
            var unit = parameters.get("unit_id", "unité")
            var dest = parameters.get("destination", "destination")
            return "Escorter %s jusqu'à %s" % [unit, dest]
        
        QuestTypes.ObjectiveType.SURVIVE:
            var turns = parameters.get("turns", 1)
            return "Survivre pendant %d tours" % turns
        
        QuestTypes.ObjectiveType.CONTROL:
            var zone = parameters.get("zone_id", "zone")
            var duration = parameters.get("duration", 1)
            return "Contrôler %s pendant %d tours" % [zone, duration]
        
        QuestTypes.ObjectiveType.NEGOTIATE:
            var faction = parameters.get("faction_id", "faction")
            return "Négocier avec %s" % faction
        
        QuestTypes.ObjectiveType.DESTROY:
            var structure = parameters.get("structure_id", "structure")
            var count = parameters.get("count", 1)
            return "Détruire %d %s" % [count, structure]
        
        _:
            return "Objectif %s" % QuestTypes.ObjectiveType.keys()[type]

## Vérifie si l'objectif correspond à un événement donné
func matches_event(event_type: String, event_data: Dictionary) -> bool:
    match type:
        QuestTypes.ObjectiveType.DEFEAT:
            if event_type == "enemy_defeated":
                var enemy_type = parameters.get("enemy_type", "")
                if enemy_type == "" or enemy_type == event_data.get("enemy_type", ""):
                    return true
        
        QuestTypes.ObjectiveType.REACH:
            if event_type == "location_reached":
                var loc_id = parameters.get("location_id", "")
                if loc_id == event_data.get("location_id", ""):
                    return true
        
        QuestTypes.ObjectiveType.COLLECT:
            if event_type == "item_collected":
                var item_id = parameters.get("item_id", "")
                if item_id == event_data.get("item_id", ""):
                    return true
        
        QuestTypes.ObjectiveType.PROTECT:
            if event_type == "protection_successful":
                var target_id = parameters.get("target_id", "")
                if target_id == event_data.get("target_id", ""):
                    return true
        
        QuestTypes.ObjectiveType.ESCORT:
            if event_type == "escort_arrived":
                var unit_id = parameters.get("unit_id", "")
                if unit_id == event_data.get("unit_id", ""):
                    return true
        
        QuestTypes.ObjectiveType.SURVIVE:
            if event_type == "turn_survived":
                return true
        
        QuestTypes.ObjectiveType.CONTROL:
            if event_type == "zone_controlled":
                var zone_id = parameters.get("zone_id", "")
                if zone_id == event_data.get("zone_id", ""):
                    return true
        
        QuestTypes.ObjectiveType.NEGOTIATE:
            if event_type == "negotiation_successful":
                var faction_id = parameters.get("faction_id", "")
                if faction_id == event_data.get("faction_id", ""):
                    return true
        
        QuestTypes.ObjectiveType.DESTROY:
            if event_type == "structure_destroyed":
                var structure_id = parameters.get("structure_id", "")
                if structure_id == event_data.get("structure_id", ""):
                    return true
    
    return false
```

---

### 2.5 RewardData (Resource)

**Rôle** : Définit une récompense de quête.

**Fichier** : `src/quests/reward_data.gd`

```gdscript
class_name RewardData extends Resource

# ============================================================
# PROPRIÉTÉS
# ============================================================

## Type de récompense
@export var type: QuestTypes.RewardType = QuestTypes.RewardType.GOLD

## Quantité/montant
@export var amount: int = 0

## Paramètres additionnels
@export var parameters: Dictionary = {}
# Exemples :
# - ITEMS: { "item_ids": ["sword_rare", "armor_legendary"] }
# - REPUTATION: { "faction_id": "empire_central" }
# - UNLOCK: { "unlock_type": "region", "unlock_id": "northern_wastes" }
# - RESOURCE: { "resource_id": "wood", "resource_type": "material" }
# - EXPERIENCE: { "target": "all_units" | "specific_unit", "unit_id": "hero_01" }
# - TERRITORY: { "region_id": "grasslands_east" }

## Description de la récompense
@export var description: String = ""

## Récompense cachée (surprise) ?
@export var hidden: bool = false

# ============================================================
# MÉTHODES
# ============================================================

## Applique la récompense au joueur
func apply_reward(player_data: Dictionary) -> void:
    match type:
        QuestTypes.RewardType.GOLD:
            player_data["gold"] = player_data.get("gold", 0) + amount
            EventBus.gold_changed.emit(player_data["gold"])
            print("Récompense appliquée: +%d Or" % amount)
        
        QuestTypes.RewardType.ITEMS:
            var item_ids = parameters.get("item_ids", [])
            for item_id in item_ids:
                player_data["inventory"].append(item_id)
            EventBus.items_gained.emit(item_ids)
            print("Récompense appliquée: %d objets" % item_ids.size())
        
        QuestTypes.RewardType.REPUTATION:
            var faction_id = parameters.get("faction_id", "")
            if faction_id != "":
                FactionManager.add_reputation(faction_id, amount)
                print("Récompense appliquée: +%d réputation avec %s" % [amount, faction_id])
        
        QuestTypes.RewardType.UNLOCK:
            var unlock_type = parameters.get("unlock_type", "")
            var unlock_id = parameters.get("unlock_id", "")
            match unlock_type:
                "region":
                    WorldGameState.unlock_region(unlock_id)
                    print("Région débloquée: %s" % unlock_id)
                "tech":
                    player_data["unlocked_techs"].append(unlock_id)
                    print("Technologie débloquée: %s" % unlock_id)
                "unit":
                    player_data["unlocked_units"].append(unlock_id)
                    print("Unité débloquée: %s" % unlock_id)
        
        QuestTypes.RewardType.RESOURCE:
            var resource_id = parameters.get("resource_id", "")
            if resource_id in player_data["resources"]:
                player_data["resources"][resource_id] += amount
            else:
                player_data["resources"][resource_id] = amount
            print("Ressource gagnée: +%d %s" % [amount, resource_id])
        
        QuestTypes.RewardType.EXPERIENCE:
            var target = parameters.get("target", "all_units")
            if target == "all_units":
                EventBus.add_experience_to_all_units.emit(amount)
                print("XP ajoutée: +%d à toutes les unités" % amount)
            elif target == "specific_unit":
                var unit_id = parameters.get("unit_id", "")
                EventBus.add_experience_to_unit.emit(unit_id, amount)
                print("XP ajoutée: +%d à %s" % [amount, unit_id])
        
        QuestTypes.RewardType.TERRITORY:
            var region_id = parameters.get("region_id", "")
            WorldGameState.claim_territory(region_id, player_data["player_id"])
            print("Territoire revendiqué: %s" % region_id)

## Génère une description lisible
func get_display_text() -> String:
    if description != "":
        return description
    
    match type:
        QuestTypes.RewardType.GOLD:
            return "%d Or" % amount
        QuestTypes.RewardType.ITEMS:
            var items = parameters.get("item_ids", [])
            return "%d Objet(s)" % items.size()
        QuestTypes.RewardType.REPUTATION:
            var faction = parameters.get("faction_id", "faction")
            return "+%d Réputation (%s)" % [amount, faction]
        QuestTypes.RewardType.UNLOCK:
            var unlock_id = parameters.get("unlock_id", "contenu")
            return "Débloque: %s" % unlock_id
        QuestTypes.RewardType.RESOURCE:
            var resource = parameters.get("resource_id", "ressource")
            return "%d %s" % [amount, resource]
        QuestTypes.RewardType.EXPERIENCE:
            return "+%d XP" % amount
        QuestTypes.RewardType.TERRITORY:
            var region = parameters.get("region_id", "territoire")
            return "Territoire: %s" % region
        _:
            return "Récompense inconnue"

## Estime la valeur de la récompense (pour AI/génération)
func estimate_value() -> int:
    var value = 0
    
    match type:
        QuestTypes.RewardType.GOLD:
            value = amount
        QuestTypes.RewardType.ITEMS:
            var items = parameters.get("item_ids", [])
            value = items.size() * 50  # Estimation
        QuestTypes.RewardType.REPUTATION:
            value = amount * 2
        QuestTypes.RewardType.UNLOCK:
            value = 200  # Valeur fixe élevée
        QuestTypes.RewardType.RESOURCE:
            value = amount * 3
        QuestTypes.RewardType.EXPERIENCE:
            value = amount * 5
        QuestTypes.RewardType.TERRITORY:
            value = 500  # Très précieux
    
    return value
```

---

### 2.6 QuestConditions (Resource)

**Rôle** : Définit les conditions d'apparition d'une quête.

**Fichier** : `src/quests/quest_conditions.gd`

```gdscript
class_name QuestConditions extends Resource

# ============================================================
# CONDITIONS TEMPORELLES
# ============================================================

## Jour minimum (inclusif, -1 = pas de minimum)
@export var required_day: int = -1

## Jour maximum (inclusif, -1 = pas de maximum)
@export var max_day: int = -1

## Saison requise (0-3 ou -1 pour any)
@export var required_season: int = -1

# ============================================================
# CONDITIONS DE TAGS
# ============================================================

## Tags que le joueur doit posséder (ET logique)
@export var required_player_tags: Array[String] = []

## Tags du monde requis (ET logique)
@export var required_world_tags: Array[String] = []

## Tags qui bloquent la quête (OU logique)
@export var excluded_tags: Array[String] = []

# ============================================================
# CONDITIONS DE FACTION
# ============================================================

## Réputation minimale requise par faction
@export var required_faction_reputation: Dictionary = {}
# Format: { "faction_id": min_reputation }

## Factions qui doivent être en guerre
@export var required_war_factions: Array[String] = []

## Factions qui ne doivent PAS être en guerre
@export var excluded_war_factions: Array[String] = []

# ============================================================
# CONDITIONS DE PROGRESSION
# ============================================================

## Quêtes qui doivent être complétées (ET logique)
@export var required_completed_quests: Array[String] = []

## Campagnes qui doivent être actives
@export var required_active_campaigns: Array[String] = []

## Niveau de puissance minimum du joueur
@export var min_power_level: int = 0

## Nombre minimum d'unités dans l'armée
@export var min_army_size: int = 0

# ============================================================
# CONDITIONS GÉOGRAPHIQUES
# ============================================================

## Régions où la quête peut apparaître
@export var available_regions: Array[String] = []

## Le joueur doit être dans une région spécifique
@export var must_be_in_region: String = ""

# ============================================================
# MÉTHODES PUBLIQUES
# ============================================================

## Vérifie toutes les conditions
func check_conditions(
    player_tags: Array[String],
    world_tags: Array[String],
    current_day: int,
    player_data: Dictionary = {}
) -> bool:
    
    # Temporel
    if not check_temporal_conditions(current_day):
        return false
    
    # Tags
    if not check_tag_conditions(player_tags, world_tags):
        return false
    
    # Factions
    if not check_faction_conditions():
        return false
    
    # Progression
    if not check_progression_conditions(player_data):
        return false
    
    # Géographique
    if not check_geographic_conditions(player_data):
        return false
    
    return true

# ============================================================
# MÉTHODES PRIVÉES DE VÉRIFICATION
# ============================================================

## Vérifie les conditions temporelles
func check_temporal_conditions(current_day: int) -> bool:
    # Jour minimum
    if required_day > 0 and current_day < required_day:
        return false
    
    # Jour maximum
    if max_day > 0 and current_day > max_day:
        return false
    
    # Saison
    if required_season >= 0:
        var current_season = WorldGameState.get_current_season()
        if current_season != required_season:
            return false
    
    return true

## Vérifie les conditions de tags
func check_tag_conditions(player_tags: Array[String], world_tags: Array[String]) -> bool:
    # Tags requis du joueur (ET logique: TOUS doivent être présents)
    for tag in required_player_tags:
        if not tag in player_tags:
            return false
    
    # Tags requis du monde (ET logique)
    for tag in required_world_tags:
        if not tag in world_tags:
            return false
    
    # Tags exclus (OU logique: SI AU MOINS UN est présent, refuse)
    for tag in excluded_tags:
        if tag in player_tags or tag in world_tags:
            return false
    
    return true

## Vérifie les conditions de faction
func check_faction_conditions() -> bool:
    # Réputation minimale
    for faction_id in required_faction_reputation:
        var min_rep = required_faction_reputation[faction_id]
        var current_rep = FactionManager.get_reputation(faction_id)
        if current_rep < min_rep:
            return false
    
    # Guerres requises
    for faction_id in required_war_factions:
        if not FactionManager.is_at_war(faction_id):
            return false
    
    # Guerres exclues
    for faction_id in excluded_war_factions:
        if FactionManager.is_at_war(faction_id):
            return false
    
    return true

## Vérifie les conditions de progression
func check_progression_conditions(player_data: Dictionary) -> bool:
    # Quêtes complétées (ET logique)
    for quest_id in required_completed_quests:
        if not QuestManager.is_quest_completed(quest_id):
            return false
    
    # Campagnes actives
    for campaign_id in required_active_campaigns:
        if not CampaignManager.is_campaign_active(campaign_id):
            return false
    
    # Niveau de puissance
    if min_power_level > 0:
        var power = player_data.get("power_level", 0)
        if power < min_power_level:
            return false
    
    # Taille d'armée
    if min_army_size > 0:
        var army_size = player_data.get("army", []).size()
        if army_size < min_army_size:
            return false
    
    return true

## Vérifie les conditions géographiques
func check_geographic_conditions(player_data: Dictionary) -> bool:
    # Régions disponibles (OU logique: au moins une doit matcher)
    if not available_regions.is_empty():
        var current_region = player_data.get("current_region", "")
        if not current_region in available_regions:
            return false
    
    # Région obligatoire
    if must_be_in_region != "":
        var current_region = player_data.get("current_region", "")
        if current_region != must_be_in_region:
            return false
    
    return true

## Retourne une explication des conditions non remplies
func get_unmet_conditions_text(
    player_tags: Array[String],
    world_tags: Array[String],
    current_day: int,
    player_data: Dictionary = {}
) -> Array[String]:
    var unmet: Array[String] = []
    
    # Temporel
    if required_day > 0 and current_day < required_day:
        unmet.append("Disponible au jour %d" % required_day)
    
    if max_day > 0 and current_day > max_day:
        unmet.append("Expirée après le jour %d" % max_day)
    
    # Tags joueur manquants
    for tag in required_player_tags:
        if not tag in player_tags:
            unmet.append("Requis: %s" % tag)
    
    # Tags monde manquants
    for tag in required_world_tags:
        if not tag in world_tags:
            unmet.append("Événement requis: %s" % tag)
    
    # Réputation insuffisante
    for faction_id in required_faction_reputation:
        var min_rep = required_faction_reputation[faction_id]
        var current_rep = FactionManager.get_reputation(faction_id)
        if current_rep < min_rep:
            unmet.append("Réputation %s: %d/%d" % [faction_id, current_rep, min_rep])
    
    # Quêtes prérequises
    for quest_id in required_completed_quests:
        if not QuestManager.is_quest_completed(quest_id):
            unmet.append("Compléter: %s" % quest_id)
    
    # Progression
    if min_power_level > 0:
        var power = player_data.get("power_level", 0)
        if power < min_power_level:
            unmet.append("Niveau de puissance: %d/%d" % [power, min_power_level])
    
    if min_army_size > 0:
        var army_size = player_data.get("army", []).size()
        if army_size < min_army_size:
            unmet.append("Taille d'armée: %d/%d" % [army_size, min_army_size])
    
    # Géographie
    if must_be_in_region != "":
        var current_region = player_data.get("current_region", "")
        if current_region != must_be_in_region:
            unmet.append("Doit être dans: %s" % must_be_in_region)
    
    return unmet
```

---

### 2.7 QuestManager (Autoload Singleton)

**Rôle** : Gestionnaire central de toutes les quêtes actives, disponibles et complétées.

**Fichier** : `src/quests/quest_manager.gd`

```gdscript
class_name QuestManager extends Node

# ============================================================
# SIGNAUX
# ============================================================

signal quest_registered(quest_id: String)
signal quest_available(quest_id: String)
signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_failed(quest_id: String, reason: String)
signal quest_objective_updated(quest_id: String, objective_index: int, current: int, required: int)
signal quest_expired(quest_id: String)
signal active_quests_changed()

# ============================================================
# DONNÉES
# ============================================================

## Bibliothèque de tous les templates enregistrés
var quest_templates: Dictionary = {}  # quest_id -> QuestTemplate

## Quêtes actuellement actives
var active_quests: Dictionary = {}  # quest_id -> QuestInstance

## Quêtes disponibles (conditions remplies, pas démarrées)
var available_quests: Array[String] = []

## Historique des quêtes complétées
var completed_quests: Dictionary = {}  # quest_id -> completion_data

## Quêtes échouées
var failed_quests: Dictionary = {}  # quest_id -> failure_data

# ============================================================
# INITIALISATION
# ============================================================

func _ready() -> void:
    # S'abonner aux événements importants
    EventBus.day_advanced.connect(_on_day_advanced)
    EventBus.combat_ended.connect(_on_combat_ended)
    EventBus.location_reached.connect(_on_location_reached)
    EventBus.item_collected.connect(_on_item_collected)
    EventBus.negotiation_completed.connect(_on_negotiation_completed)
    
    # Charger les templates depuis les ressources
    load_quest_templates()
    
    print("[QuestManager] Initialized")

## Charge tous les templates de quêtes depuis les fichiers
func load_quest_templates() -> void:
    var dirs = [
        "res://data/quests/tier1/",
        "res://data/quests/tier2/",
        "res://data/quests/tier3/"
    ]
    
    var total_loaded = 0
    
    for dir_path in dirs:
        var dir = DirAccess.open(dir_path)
        if dir:
            dir.list_dir_begin()
            var file_name = dir.get_next()
            while file_name != "":
                if file_name.ends_with(".tres"):
                    var full_path = dir_path + file_name
                    var template = load(full_path) as QuestTemplate
                    if template and template.validate():
                        register_quest(template)
                        total_loaded += 1
                file_name = dir.get_next()
            dir.list_dir_end()
    
    print("[QuestManager] Loaded %d quest templates" % total_loaded)

# ============================================================
# ENREGISTREMENT
# ============================================================

## Enregistre un template de quête dans la bibliothèque
func register_quest(template: QuestTemplate) -> void:
    if template.quest_id == "":
        push_error("Quest template has no ID")
        return
    
    if template.quest_id in quest_templates:
        push_warning("Quest ID already registered: " + template.quest_id)
        return
    
    quest_templates[template.quest_id] = template
    quest_registered.emit(template.quest_id)
    
    # Vérifier immédiatement la disponibilité
    check_quest_availability(template.quest_id)

## Désenregistre une quête
func unregister_quest(quest_id: String) -> void:
    if quest_id in quest_templates:
        quest_templates.erase(quest_id)
        available_quests.erase(quest_id)
        print("[QuestManager] Unregistered quest: %s" % quest_id)

# ============================================================
# DISPONIBILITÉ
# ============================================================

## Vérifie si une quête devient disponible
func check_quest_availability(quest_id: String) -> bool:
    if quest_id not in quest_templates:
        return false
    
    var template = quest_templates[quest_id]
    
    # Déjà active ?
    if quest_id in active_quests:
        return false
    
    # Déjà complétée et non-répétable ?
    if quest_id in completed_quests and not template.repeatable:
        return false
    
    # Vérifier le cooldown de répétition
    if quest_id in completed_quests and template.repeatable:
        if not template.can_repeat(WorldGameState.current_day):
            return false
    
    # Vérifier les conditions
    var player_tags = WorldGameState.get_player_tags()
    var world_tags = WorldGameState.get_world_tags()
    var current_day = WorldGameState.current_day
    var player_data = WorldGameState.get_player_data()
    
    if not template.check_availability(player_tags, world_tags, current_day):
        return false
    
    # Conditions de faction (si présentes)
    if template.conditions:
        if not template.conditions.check_conditions(player_tags, world_tags, current_day, player_data):
            return false
    
    # Disponible !
    if quest_id not in available_quests:
        available_quests.append(quest_id)
        quest_available.emit(quest_id)
        print("[QuestManager] Quest available: %s" % quest_id)
    
    return true

## Vérifie la disponibilité de toutes les quêtes
func refresh_available_quests() -> void:
    for quest_id in quest_templates.keys():
        check_quest_availability(quest_id)

# ============================================================
# DÉMARRAGE
# ============================================================

## Démarre une quête
func start_quest(quest_id: String) -> QuestInstance:
    if quest_id not in quest_templates:
        push_error("Unknown quest: " + quest_id)
        return null
    
    if quest_id in active_quests:
        push_warning("Quest already active: " + quest_id)
        return active_quests[quest_id]
    
    # Vérifier le nombre maximum de quêtes actives
    if active_quests.size() >= QuestTypes.MAX_ACTIVE_QUESTS:
        push_warning("Maximum active quests reached (%d)" % QuestTypes.MAX_ACTIVE_QUESTS)
        return null
    
    var template = quest_templates[quest_id]
    var instance = template.create_instance(WorldGameState.current_day)
    
    # Connecter les signaux
    instance.objective_updated.connect(_on_objective_updated.bind(quest_id))
    instance.objective_completed.connect(_on_objective_completed.bind(quest_id))
    instance.quest_completed.connect(_on_quest_completed_internal.bind(quest_id))
    instance.quest_failed.connect(_on_quest_failed_internal.bind(quest_id))
    
    active_quests[quest_id] = instance
    available_quests.erase(quest_id)
    
    quest_started.emit(quest_id)
    active_quests_changed.emit()
    print("[QuestManager] Quest started: %s" % quest_id)
    
    return instance

## Annule une quête active
func cancel_quest(quest_id: String) -> void:
    if quest_id not in active_quests:
        return
    
    var instance = active_quests[quest_id]
    instance.fail_quest("cancelled")
    # Le reste sera géré par _on_quest_failed_internal

# ============================================================
# PROGRESSION
# ============================================================

## Met à jour un objectif de quête
func update_quest_objective(quest_id: String, objective_index: int, progress: int) -> void:
    if quest_id not in active_quests:
        return
    
    var instance = active_quests[quest_id]
    instance.update_objective(objective_index, progress)

## Notifie d'un événement qui pourrait progresser des quêtes
func notify_event(event_type: String, event_data: Dictionary) -> void:
    for quest_id in active_quests.keys():
        var instance = active_quests[quest_id]
        var template = instance.template
        
        # Vérifier chaque objectif
        for i in range(template.objectives.size()):
            var objective = template.objectives[i]
            if objective.matches_event(event_type, event_data):
                # Cet événement fait progresser cet objectif
                var progress = event_data.get("progress", 1)
                instance.update_objective(i, progress)

# ============================================================
# COMPLÉTION / ÉCHEC
# ============================================================

## Appelé quand une quête est complétée
func _on_quest_completed_internal(quest_id: String) -> void:
    if quest_id not in active_quests:
        return
    
    var instance = active_quests[quest_id]
    var template = instance.template
    
    # Enregistrer dans l'historique
    completed_quests[quest_id] = {
        "completion_day": WorldGameState.current_day,
        "duration": instance.end_day - instance.start_day,
        "events": instance.events,
        "timestamp": Time.get_unix_time_from_system()
    }
    
    # Mettre à jour le template pour les répétitions
    template.last_completed_day = WorldGameState.current_day
    template.completion_count += 1
    
    # Appliquer les récompenses
    apply_quest_rewards(template)
    
    # Retirer des quêtes actives
    active_quests.erase(quest_id)
    
    # Signals
    quest_completed.emit(quest_id)
    active_quests_changed.emit()
    EventBus.quest_completed.emit(quest_id)
    
    print("[QuestManager] Quest completed: %s" % quest_id)

## Appelé quand une quête échoue
func _on_quest_failed_internal(quest_id: String, reason: String) -> void:
    if quest_id not in active_quests:
        return
    
    var instance = active_quests[quest_id]
    
    # Enregistrer dans l'historique
    failed_quests[quest_id] = {
        "failure_day": WorldGameState.current_day,
        "reason": reason,
        "events": instance.events,
        "timestamp": Time.get_unix_time_from_system()
    }
    
    # Retirer des quêtes actives
    active_quests.erase(quest_id)
    
    # Signals
    quest_failed.emit(quest_id, reason)
    active_quests_changed.emit()
    EventBus.quest_failed.emit(quest_id, reason)
    
    print("[QuestManager] Quest failed: %s (reason: %s)" % [quest_id, reason])

## Applique les récompenses d'une quête
func apply_quest_rewards(template: QuestTemplate) -> void:
    var player_data = WorldGameState.get_player_data()
    
    for reward in template.rewards:
        reward.apply_reward(player_data)
    
    EventBus.rewards_received.emit(template.rewards)

# ============================================================
# ÉVÉNEMENTS EXTERNES
# ============================================================

## Appelé chaque jour
func _on_day_advanced(day: int) -> void:
    # Vérifier l'expiration des quêtes actives
    var expired_quests: Array[String] = []
    for quest_id in active_quests.keys():
        var instance = active_quests[quest_id]
        if instance.check_expiry(day):
            expired_quests.append(quest_id)
    
    for quest_id in expired_quests:
        quest_expired.emit(quest_id)
    
    # Rafraîchir les quêtes disponibles
    refresh_available_quests()

## Appelé après un combat
func _on_combat_ended(combat_data: Dictionary) -> void:
    if combat_data.get("victory", false):
        for enemy in combat_data.get("enemies_defeated", []):
            notify_event("enemy_defeated", {
                "enemy_type": enemy.get("type", ""),
                "enemy_id": enemy.get("id", "")
            })

## Appelé quand le joueur atteint un lieu
func _on_location_reached(location_id: String) -> void:
    notify_event("location_reached", {"location_id": location_id})

## Appelé quand un objet est collecté
func _on_item_collected(item_id: String) -> void:
    notify_event("item_collected", {"item_id": item_id})

## Appelé après une négociation
func _on_negotiation_completed(faction_id: String, success: bool) -> void:
    if success:
        notify_event("negotiation_successful", {"faction_id": faction_id})

## Connecter les signaux internes d'objectif
func _on_objective_updated(objective_index: int, current: int, required: int, quest_id: String) -> void:
    quest_objective_updated.emit(quest_id, objective_index, current, required)

func _on_objective_completed(objective_index: int, quest_id: String) -> void:
    print("[QuestManager] Quest %s - Objective %d completed" % [quest_id, objective_index])

# ============================================================
# REQUÊTES
# ============================================================

## Retourne une quête active
func get_active_quest(quest_id: String) -> QuestInstance:
    return active_quests.get(quest_id)

## Retourne toutes les quêtes actives
func get_all_active_quests() -> Array[QuestInstance]:
    var quests: Array[QuestInstance] = []
    for instance in active_quests.values():
        quests.append(instance)
    return quests

## Retourne les quêtes disponibles
func get_available_quests() -> Array[QuestTemplate]:
    var quests: Array[QuestTemplate] = []
    for quest_id in available_quests:
        if quest_id in quest_templates:
            quests.append(quest_templates[quest_id])
    return quests

## Retourne un template
func get_quest_template(quest_id: String) -> QuestTemplate:
    return quest_templates.get(quest_id)

## Vérifie si une quête est complétée
func is_quest_completed(quest_id: String) -> bool:
    return quest_id in completed_quests

## Vérifie si une quête est active
func is_quest_active(quest_id: String) -> bool:
    return quest_id in active_quests

## Retourne le nombre de fois qu'une quête a été complétée
func get_completion_count(quest_id: String) -> int:
    if quest_id in quest_templates:
        return quest_templates[quest_id].completion_count
    return 0

## Retourne les statistiques globales
func get_statistics() -> Dictionary:
    return {
        "total_templates": quest_templates.size(),
        "active_count": active_quests.size(),
        "available_count": available_quests.size(),
        "completed_count": completed_quests.size(),
        "failed_count": failed_quests.size()
    }

# ============================================================
# SAUVEGARDE / CHARGEMENT
# ============================================================

## Sauvegarde l'état
func save_state() -> Dictionary:
    var state = {
        "active_quests": {},
        "available_quests": available_quests.duplicate(),
        "completed_quests": completed_quests.duplicate(true),
        "failed_quests": failed_quests.duplicate(true)
    }
    
    # Sauvegarder l'état des quêtes actives
    for quest_id in active_quests.keys():
        var instance = active_quests[quest_id]
        state["active_quests"][quest_id] = instance.save_to_dict()
    
    # Sauvegarder l'état des templates (pour répétabilité)
    var templates_state = {}
    for quest_id in quest_templates.keys():
        var template = quest_templates[quest_id]
        templates_state[quest_id] = {
            "last_completed_day": template.last_completed_day,
            "completion_count": template.completion_count
        }
    state["templates_state"] = templates_state
    
    return state

## Charge l'état
func load_state(state: Dictionary) -> void:
    available_quests = state.get("available_quests", [])
    completed_quests = state.get("completed_quests", {})
    failed_quests = state.get("failed_quests", {})
    
    # Restaurer l'état des templates
    var templates_state = state.get("templates_state", {})
    for quest_id in templates_state.keys():
        if quest_id in quest_templates:
            var template = quest_templates[quest_id]
            var t_state = templates_state[quest_id]
            template.last_completed_day = t_state.get("last_completed_day", -1)
            template.completion_count = t_state.get("completion_count", 0)
    
    # Restaurer les quêtes actives
    for quest_id in state.get("active_quests", {}).keys():
        if quest_id in quest_templates:
            var quest_state = state["active_quests"][quest_id]
            var instance = start_quest(quest_id)
            if instance:
                instance.load_from_dict(quest_state)
    
    print("[QuestManager] State loaded")
```

---

### 2.8 QuestChain (Resource)

**Rôle** : Définit une chaîne de quêtes séquentielles (Tier 2-3).

**Fichier** : `src/quests/campaigns/quest_chain.gd`

```gdscript
class_name QuestChain extends Resource

# ============================================================
# PROPRIÉTÉS
# ============================================================

## Identifiant unique de la chaîne
@export var chain_id: String = ""

## Thème de la chaîne (pour cohérence narrative)
@export var theme: String = ""

## Liste ordonnée des IDs de quêtes
@export var quest_ids: Array[String] = []

## Index de la quête actuelle
var current_index: int = 0

## Courbe de difficulté pour chaque quête
@export var difficulty_curve: Array[float] = []

## Récompense bonus pour complétion de toute la chaîne
@export var chain_completion_reward: RewardData = null

## La chaîne est-elle active ?
var is_active: bool = false

## La chaîne est-elle complétée ?
var is_completed: bool = false

## Jour de démarrage
var start_day: int = -1

## Métadonnées supplémentaires
@export var metadata: Dictionary = {}

# ============================================================
# SIGNAUX
# ============================================================

signal chain_started()
signal quest_in_chain_completed(quest_id: String, chain_index: int)
signal chain_advanced(new_index: int)
signal chain_completed()
signal chain_failed(reason: String)

# ============================================================
# MÉTHODES
# ============================================================

## Démarre la chaîne
func start_chain(day: int) -> bool:
    if is_active:
        push_warning("Chain already active: " + chain_id)
        return false
    
    if quest_ids.is_empty():
        push_error("Chain has no quests: " + chain_id)
        return false
    
    is_active = true
    start_day = day
    current_index = 0
    
    chain_started.emit()
    print("[QuestChain] Chain started: %s" % chain_id)
    return true

## Obtient l'ID de la quête actuelle
func get_current_quest_id() -> String:
    if current_index < quest_ids.size():
        return quest_ids[current_index]
    return ""

## Obtient toutes les quêtes restantes
func get_remaining_quest_ids() -> Array[String]:
    var remaining: Array[String] = []
    for i in range(current_index, quest_ids.size()):
        remaining.append(quest_ids[i])
    return remaining

## Avance à la quête suivante
func advance() -> bool:
    if not is_active:
        return false
    
    current_index += 1
    
    if current_index >= quest_ids.size():
        # Chaîne complétée !
        complete_chain()
        return true
    
    chain_advanced.emit(current_index)
    print("[QuestChain] Advanced to quest %d/%d" % [current_index + 1, quest_ids.size()])
    return false  # Pas encore terminée

## Complète la chaîne
func complete_chain() -> void:
    if is_completed:
        return
    
    is_completed = true
    is_active = false
    
    # Appliquer la récompense bonus si présente
    if chain_completion_reward:
        var player_data = WorldGameState.get_player_data()
        chain_completion_reward.apply_reward(player_data)
    
    chain_completed.emit()
    print("[QuestChain] Chain completed: %s" % chain_id)

## Échoue la chaîne
func fail_chain(reason: String) -> void:
    is_active = false
    chain_failed.emit(reason)
    print("[QuestChain] Chain failed: %s (reason: %s)" % [chain_id, reason])

## Obtient la progression (0.0 à 1.0)
func get_progress() -> float:
    if quest_ids.is_empty():
        return 0.0
    return float(current_index) / float(quest_ids.size())

## Obtient la difficulté de la quête actuelle
func get_current_difficulty() -> float:
    if current_index < difficulty_curve.size():
        return difficulty_curve[current_index]
    return 1.0  # Difficulté par défaut

## Vérifie si une quête fait partie de cette chaîne
func contains_quest(quest_id: String) -> bool:
    return quest_id in quest_ids

## Clone la chaîne (pour génération procédurale)
func duplicate_chain() -> QuestChain:
    var dup = self.duplicate(true)
    dup.chain_id = chain_id + "_" + str(randi())
    dup.current_index = 0
    dup.is_active = false
    dup.is_completed = false
    return dup
```

---

### 2.9 CampaignManager (Autoload Singleton)

**Rôle** : Gère la génération procédurale (Tier 2-3) et le suivi des campagnes narratives (Tier 4).

**Fichier** : `src/quests/campaigns/campaign_manager.gd`

```gdscript
class_name CampaignManager extends Node

# ============================================================
# SIGNAUX
# ============================================================

signal campaign_started(campaign_id: String)
signal campaign_chapter_completed(campaign_id: String, chapter_num: int)
signal campaign_completed(campaign_id: String)
signal chain_started(chain_id: String)
signal chain_completed(chain_id: String)

# ============================================================
# DONNÉES
# ============================================================

## Chaînes de quêtes actives (Tier 2-3)
var active_chains: Dictionary = {}  # chain_id -> QuestChain

## Campagnes narratives actives (Tier 4)
var active_campaigns: Dictionary = {}  # campaign_id -> FactionCampaign

## Bibliothèque de campagnes disponibles
var campaign_library: Dictionary = {}  # campaign_id -> FactionCampaign

## Générateur de quêtes procédurales
var quest_generator: QuestGenerator

# ============================================================
# INITIALISATION
# ============================================================

func _ready() -> void:
    quest_generator = QuestGenerator.new()
    
    # S'abonner aux événements
    QuestManager.quest_completed.connect(_on_quest_completed)
    EventBus.day_advanced.connect(_on_day_advanced)
    
    # Charger les campagnes narratives
    load_narrative_campaigns()
    
    print("[CampaignManager] Initialized")

## Charge toutes les campagnes narratives
func load_narrative_campaigns() -> void:
    var dir_path = "res://data/campaigns/faction_campaigns/"
    var dir = DirAccess.open(dir_path)
    
    if not dir:
        print("[CampaignManager] No campaigns directory found")
        return
    
    dir.list_dir_begin()
    var file_name = dir.get_next()
    var count = 0
    
    while file_name != "":
        if file_name.ends_with(".tres"):
            var full_path = dir_path + file_name
            var campaign = load(full_path) as FactionCampaign
            if campaign:
                campaign_library[campaign.campaign_id] = campaign
                count += 1
        file_name = dir.get_next()
    
    dir.list_dir_end()
    print("[CampaignManager] Loaded %d narrative campaigns" % count)

# ============================================================
# CHAÎNES DE QUÊTES (TIER 2-3)
# ============================================================

## Génère une chaîne de quêtes procédurale
func generate_quest_chain(theme: String, quest_count: int, tier: QuestTypes.Tier, params: Dictionary = {}) -> QuestChain:
    var chain = QuestChain.new()
    chain.chain_id = "chain_" + theme + "_" + str(randi())
    chain.theme = theme
    chain.metadata = params
    
    # Générer les quêtes
    for i in range(quest_count):
        var difficulty = 1.0 + (float(i) / float(quest_count)) * 2.0  # Progression 1.0 -> 3.0
        var quest_params = params.duplicate()
        quest_params["difficulty"] = difficulty
        quest_params["chain_position"] = i
        quest_params["theme"] = theme
        
        var quest = quest_generator.generate_quest(tier, quest_params)
        if quest:
            QuestManager.register_quest(quest)
            chain.quest_ids.append(quest.quest_id)
            chain.difficulty_curve.append(difficulty)
    
    # Récompense bonus pour la chaîne complète
    if quest_count >= 3:
        var bonus = RewardData.new()
        bonus.type = QuestTypes.RewardType.GOLD
        bonus.amount = quest_count * 100
        chain.chain_completion_reward = bonus
    
    print("[CampaignManager] Generated chain: %s (%d quests)" % [chain.chain_id, quest_count])
    return chain

## Démarre une chaîne de quêtes
func start_chain(chain: QuestChain) -> bool:
    if chain.chain_id in active_chains:
        push_warning("Chain already active: " + chain.chain_id)
        return false
    
    if not chain.start_chain(WorldGameState.current_day):
        return false
    
    active_chains[chain.chain_id] = chain
    
    # Connecter les signaux
    chain.chain_completed.connect(_on_chain_completed.bind(chain.chain_id))
    chain.chain_failed.connect(_on_chain_failed.bind(chain.chain_id))
    
    # Démarrer la première quête
    var first_quest_id = chain.get_current_quest_id()
    if first_quest_id != "":
        QuestManager.start_quest(first_quest_id)
    
    chain_started.emit(chain.chain_id)
    return true

## Avance une chaîne après complétion d'une quête
func advance_chain(chain_id: String) -> void:
    if chain_id not in active_chains:
        return
    
    var chain = active_chains[chain_id]
    var is_complete = chain.advance()
    
    if not is_complete:
        # Démarrer la quête suivante
        var next_quest_id = chain.get_current_quest_id()
        if next_quest_id != "":
            QuestManager.start_quest(next_quest_id)

## Vérifie si une quête fait partie d'une chaîne active
func get_chain_for_quest(quest_id: String) -> QuestChain:
    for chain in active_chains.values():
        if chain.contains_quest(quest_id):
            return chain
    return null

## Vérifie si une quête fait partie d'une chaîne
func is_chain_quest(quest_id: String) -> bool:
    return get_chain_for_quest(quest_id) != null

# ============================================================
# CAMPAGNES NARRATIVES (TIER 4)
# ============================================================

## Démarre une campagne narrative
func start_narrative_campaign(campaign_id: String) -> bool:
    if campaign_id not in campaign_library:
        push_error("Unknown campaign: " + campaign_id)
        return false
    
    if campaign_id in active_campaigns:
        push_warning("Campaign already active: " + campaign_id)
        return false
    
    var campaign = campaign_library[campaign_id]
    
    # Vérifier les conditions de déverrouillage
    if not check_campaign_unlock(campaign_id):
        push_warning("Campaign not unlocked: " + campaign_id)
        return false
    
    # Démarrer la campagne
    if not campaign.start_campaign(WorldGameState.current_day):
        return false
    
    active_campaigns[campaign_id] = campaign
    
    # Connecter les signaux
    campaign.chapter_completed.connect(_on_campaign_chapter_completed.bind(campaign_id))
    campaign.campaign_completed.connect(_on_campaign_completed.bind(campaign_id))
    
    # Démarrer les quêtes du premier chapitre
    var current_quests = campaign.get_current_chapter_quest_ids()
    for quest_id in current_quests:
        QuestManager.start_quest(quest_id)
    
    campaign_started.emit(campaign_id)
    print("[CampaignManager] Campaign started: %s" % campaign_id)
    return true

## Vérifie si une campagne peut être déverrouillée
func check_campaign_unlock(campaign_id: String) -> bool:
    if campaign_id not in campaign_library:
        return false
    
    var campaign = campaign_library[campaign_id]
    return campaign.check_unlock_conditions()

## Obtient les campagnes disponibles
func get_available_campaigns() -> Array[FactionCampaign]:
    var available: Array[FactionCampaign] = []
    for campaign_id in campaign_library.keys():
        if check_campaign_unlock(campaign_id) and campaign_id not in active_campaigns:
            available.append(campaign_library[campaign_id])
    return available

## Vérifie si une campagne est active
func is_campaign_active(campaign_id: String) -> bool:
    return campaign_id in active_campaigns

## Obtient une campagne active
func get_active_campaign(campaign_id: String) -> FactionCampaign:
    return active_campaigns.get(campaign_id)

# ============================================================
# ÉVÉNEMENTS
# ============================================================

## Appelé quand une quête est complétée
func _on_quest_completed(quest_id: String) -> void:
    # Vérifier si c'est une quête de chaîne
    var chain = get_chain_for_quest(quest_id)
    if chain:
        advance_chain(chain.chain_id)
    
    # Vérifier si c'est une quête de campagne narrative
    for campaign_id in active_campaigns.keys():
        var campaign = active_campaigns[campaign_id]
        if campaign.is_quest_in_current_chapter(quest_id):
            campaign.on_quest_completed(quest_id)

## Appelé quand une chaîne est complétée
func _on_chain_completed(chain_id: String) -> void:
    if chain_id in active_chains:
        active_chains.erase(chain_id)
        chain_completed.emit(chain_id)
        print("[CampaignManager] Chain completed: %s" % chain_id)

## Appelé quand une chaîne échoue
func _on_chain_failed(chain_id: String, reason: String) -> void:
    if chain_id in active_chains:
        active_chains.erase(chain_id)
        print("[CampaignManager] Chain failed: %s (reason: %s)" % [chain_id, reason])

## Appelé quand un chapitre de campagne est complété
func _on_campaign_chapter_completed(chapter_num: int, campaign_id: String) -> void:
    campaign_chapter_completed.emit(campaign_id, chapter_num)
    
    # Démarrer les quêtes du chapitre suivant
    if campaign_id in active_campaigns:
        var campaign = active_campaigns[campaign_id]
        var next_quests = campaign.get_current_chapter_quest_ids()
        for quest_id in next_quests:
            QuestManager.start_quest(quest_id)

## Appelé quand une campagne est complétée
func _on_campaign_completed(campaign_id: String) -> void:
    if campaign_id not in active_campaigns:
        return
    
    var campaign = active_campaigns[campaign_id]
    
    # Appliquer les impacts mondiaux
    if campaign.world_impact:
        campaign.world_impact.apply_to_world()
    
    # Appliquer les changements de relations
    for faction_id in campaign.faction_relations.keys():
        var change = campaign.faction_relations[faction_id]
        FactionManager.add_reputation(faction_id, change)
    
    active_campaigns.erase(campaign_id)
    campaign_completed.emit(campaign_id)
    print("[CampaignManager] Campaign completed: %s" % campaign_id)

## Appelé chaque jour
func _on_day_advanced(day: int) -> void:
    # Vérifier les campagnes qui peuvent être déverrouillées
    pass

# ============================================================
# SAUVEGARDE / CHARGEMENT
# ============================================================

func save_state() -> Dictionary:
    var state = {
        "active_chains": {},
        "active_campaigns": {}
    }
    
    # Sauvegarder les chaînes
    for chain_id in active_chains.keys():
        var chain = active_chains[chain_id]
        state["active_chains"][chain_id] = {
            "current_index": chain.current_index,
            "is_active": chain.is_active,
            "is_completed": chain.is_completed,
            "start_day": chain.start_day
        }
    
    # Sauvegarder les campagnes
    for campaign_id in active_campaigns.keys():
        var campaign = active_campaigns[campaign_id]
        state["active_campaigns"][campaign_id] = campaign.save_state()
    
    return state

func load_state(state: Dictionary) -> void:
    # Restaurer les chaînes
    for chain_id in state.get("active_chains", {}).keys():
        var chain_state = state["active_chains"][chain_id]
        # TODO: Restaurer les chaînes
    
    # Restaurer les campagnes
    for campaign_id in state.get("active_campaigns", {}).keys():
        if campaign_id in campaign_library:
            var campaign = campaign_library[campaign_id]
            campaign.load_state(state["active_campaigns"][campaign_id])
            active_campaigns[campaign_id] = campaign
    
    print("[CampaignManager] State loaded")
```

---

### 2.10 FactionCampaign (Resource)

**Rôle** : Définit une campagne narrative de faction (Tier 4).

**Fichier** : `src/quests/campaigns/faction_campaign.gd`

```gdscript
class_name FactionCampaign extends Resource

# ============================================================
# PROPRIÉTÉS
# ============================================================

## Identifiant unique
@export var campaign_id: String = ""

## Faction associée
@export var faction_id: String = ""

## Titre de la campagne
@export var title: String = ""

## Description générale
@export_multiline var description: String = ""

## Liste des chapitres
@export var chapters: Array[ChapterData] = []

## Chapitre actuel
var current_chapter: int = 0

## Chapitres complétés
var completed_chapters: Array[int] = []

## La campagne est-elle active ?
var is_active: bool = false

## La campagne est-elle complétée ?
var is_completed: bool = false

## Jour de démarrage
var start_day: int = -1

# ============================================================
# IMPACTS SUR LE MONDE
# ============================================================

## Changements de relations avec d'autres factions
@export var faction_relations: Dictionary = {}
# Format: { "faction_id": reputation_change }

## Impact mondial après complétion
@export var world_impact: WorldImpact = null

# ============================================================
# CONDITIONS DE DÉVERROUILLAGE
# ============================================================

## Tags requis pour déverrouiller
@export var unlock_tags: Array[String] = []

## Réputation minimale requise
@export var required_reputation: int = 0

## Quêtes à compléter au préalable
@export var required_quests: Array[String] = []

## Campagnes à compléter au préalable
@export var required_campaigns: Array[String] = []

# ============================================================
# SIGNAUX
# ============================================================

signal chapter_completed(chapter_num: int)
signal campaign_completed()

# ============================================================
# MÉTHODES PUBLIQUES
# ============================================================

## Démarre la campagne
func start_campaign(day: int) -> bool:
    if is_active:
        push_warning("Campaign already active: " + campaign_id)
        return false
    
    if chapters.is_empty():
        push_error("Campaign has no chapters: " + campaign_id)
        return false
    
    is_active = true
    start_day = day
    current_chapter = 0
    completed_chapters.clear()
    
    print("[FactionCampaign] Campaign started: %s" % campaign_id)
    return true

## Obtient le chapitre actuel
func get_current_chapter() -> ChapterData:
    if current_chapter < chapters.size():
        return chapters[current_chapter]
    return null

## Obtient les IDs de quêtes du chapitre actuel
func get_current_chapter_quest_ids() -> Array[String]:
    var chapter = get_current_chapter()
    if chapter:
        return chapter.quest_ids
    return []

## Vérifie si une quête fait partie du chapitre actuel
func is_quest_in_current_chapter(quest_id: String) -> bool:
    var current_quests = get_current_chapter_quest_ids()
    return quest_id in current_quests

## Appelé quand une quête du chapitre est complétée
func on_quest_completed(quest_id: String) -> void:
    var chapter = get_current_chapter()
    if not chapter:
        return
    
    # Vérifier si le chapitre est complété
    if chapter.check_completion():
        complete_chapter(current_chapter)

## Complète un chapitre
func complete_chapter(chapter_num: int) -> void:
    if chapter_num in completed_chapters:
        return
    
    completed_chapters.append(chapter_num)
    chapter_completed.emit(chapter_num)
    
    print("[FactionCampaign] Chapter %d completed in campaign %s" % [chapter_num + 1, campaign_id])
    
    # Appliquer les récompenses du chapitre
    var chapter = chapters[chapter_num]
    if chapter and not chapter.rewards.is_empty():
        var player_data = WorldGameState.get_player_data()
        for reward in chapter.rewards:
            reward.apply_reward(player_data)
    
    # Avancer au chapitre suivant
    advance_chapter()

## Avance au chapitre suivant
func advance_chapter() -> bool:
    current_chapter += 1
    
    if current_chapter >= chapters.size():
        # Campagne complétée !
        complete_campaign()
        return true
    
    print("[FactionCampaign] Advanced to chapter %d/%d" % [current_chapter + 1, chapters.size()])
    return false

## Complète la campagne
func complete_campaign() -> void:
    if is_completed:
        return
    
    is_completed = true
    is_active = false
    
    campaign_completed.emit()
    print("[FactionCampaign] Campaign completed: %s" % campaign_id)

## Obtient la progression (0.0 à 1.0)
func get_progress() -> float:
    if chapters.is_empty():
        return 0.0
    return float(current_chapter) / float(chapters.size())

## Vérifie les conditions de déverrouillage
func check_unlock_conditions() -> bool:
    # Vérifier les tags
    var player_tags = WorldGameState.get_player_tags()
    for tag in unlock_tags:
        if not tag in player_tags:
            return false
    
    # Vérifier la réputation
    if required_reputation > 0:
        var current_rep = FactionManager.get_reputation(faction_id)
        if current_rep < required_reputation:
            return false
    
    # Vérifier les quêtes requises
    for quest_id in required_quests:
        if not QuestManager.is_quest_completed(quest_id):
            return false
    
    # Vérifier les campagnes requises
    for campaign_id in required_campaigns:
        # TODO: Vérifier dans l'historique des campagnes complétées
        pass
    
    return true

## Estime la durée totale (en nombre de quêtes)
func estimate_duration() -> int:
    var total = 0
    for chapter in chapters:
        total += chapter.quest_ids.size()
    return total

# ============================================================
# SAUVEGARDE / CHARGEMENT
# ============================================================

func save_state() -> Dictionary:
    return {
        "current_chapter": current_chapter,
        "completed_chapters": completed_chapters.duplicate(),
        "is_active": is_active,
        "is_completed": is_completed,
        "start_day": start_day
    }

func load_state(state: Dictionary) -> void:
    current_chapter = state.get("current_chapter", 0)
    completed_chapters = state.get("completed_chapters", [])
    is_active = state.get("is_active", false)
    is_completed = state.get("is_completed", false)
    start_day = state.get("start_day", -1)
```

---

### 2.11 ChapterData (Resource)

**Rôle** : Définit un chapitre d'une campagne narrative.

**Fichier** : `src/quests/campaigns/chapter_data.gd`

```gdscript
class_name ChapterData extends Resource

# ============================================================
# PROPRIÉTÉS
# ============================================================

## Numéro du chapitre
@export var chapter_number: int = 1

## Titre du chapitre
@export var title: String = ""

## Description narrative
@export_multiline var description: String = ""

## Liste des IDs de quêtes du chapitre
@export var quest_ids: Array[String] = []

## Quêtes complétées dans ce chapitre
var completed_quest_ids: Array[String] = []

## Condition de complétion
@export_enum("all", "any", "count") var completion_requirement: String = "all"

## Si completion_requirement == "count", nombre requis
@export var required_count: int = 1

## Récompenses à la fin du chapitre
@export var rewards: Array[RewardData] = []

## Conditions pour passer au chapitre suivant
@export var next_chapter_conditions: Array[String] = []

# ============================================================
# MÉTHODES
# ============================================================

## Marque une quête comme complétée
func mark_quest_completed(quest_id: String) -> void:
    if quest_id not in completed_quest_ids:
        completed_quest_ids.append(quest_id)

## Vérifie si le chapitre est complété
func check_completion() -> bool:
    match completion_requirement:
        "all":
            # Toutes les quêtes doivent être complétées
            for quest_id in quest_ids:
                if not QuestManager.is_quest_completed(quest_id):
                    return false
            return true
        
        "any":
            # Au moins une quête doit être complétée
            for quest_id in quest_ids:
                if QuestManager.is_quest_completed(quest_id):
                    return true
            return false
        
        "count":
            # Un nombre minimum de quêtes doit être complété
            var count = 0
            for quest_id in quest_ids:
                if QuestManager.is_quest_completed(quest_id):
                    count += 1
            return count >= required_count
        
        _:
            return false

## Obtient la progression du chapitre (0.0 à 1.0)
func get_progress() -> float:
    if quest_ids.is_empty():
        return 0.0
    
    var completed = 0
    for quest_id in quest_ids:
        if QuestManager.is_quest_completed(quest_id):
            completed += 1
    
    return float(completed) / float(quest_ids.size())

## Obtient un texte de description de la progression
func get_progress_text() -> String:
    match completion_requirement:
        "all":
            var completed = 0
            for quest_id in quest_ids:
                if QuestManager.is_quest_completed(quest_id):
                    completed += 1
            return "%d/%d quêtes complétées" % [completed, quest_ids.size()]
        
        "any":
            for quest_id in quest_ids:
                if QuestManager.is_quest_completed(quest_id):
                    return "Complété"
            return "En cours"
        
        "count":
            var completed = 0
            for quest_id in quest_ids:
                if QuestManager.is_quest_completed(quest_id):
                    completed += 1
            return "%d/%d quêtes complétées" % [completed, required_count]
        
        _:
            return "Inconnu"
```

---

### 2.12 WorldCrisis (Resource)

**Rôle** : Définit une crise mondiale (Tier 5).

**Fichier** : `src/world_events/world_crisis.gd`

```gdscript
class_name WorldCrisis extends Resource

# ============================================================
# PROPRIÉTÉS
# ============================================================

## Identifiant unique
@export var crisis_id: String = ""

## Type de crise
@export_enum("invasion", "plague", "famine", "disaster", "rebellion") var crisis_type: String = "invasion"

## Titre de la crise
@export var title: String = ""

## Description
@export_multiline var description: String = ""

## Phases de la crise
@export var phases: Array[CrisisPhase] = []

## Phase actuelle
var current_phase: int = 0

## Phases complétées
var completed_phases: Array[int] = []

# ============================================================
# TIMER
# ============================================================

## Jour de démarrage
var start_day: int = -1

## Durée limite totale (jours)
@export var time_limit: int = 30

## Est-ce que la crise est active ?
var is_active: bool = false

## Est-ce que la crise est résolue ?
var is_resolved: bool = false

## Résultat final
var result: String = ""  # "success" ou "failure"

# ============================================================
# CONTRIBUTION
# ============================================================

## Objectif de contribution global
@export var contribution_goal: int = 1000

## Contribution actuelle
var current_contribution: int = 0

## Contributions par joueur/faction
var contributors: Dictionary = {}
# Format: { "contributor_id": contribution_amount }

# ============================================================
# EFFETS
# ============================================================

## Effets en cas d'échec
@export var failure_effects: Array[WorldEffect] = []

## Effets en cas de succès
@export var success_effects: Array[WorldEffect] = []

# ============================================================
# SIGNAUX
# ============================================================

signal crisis_started()
signal phase_advanced(phase_num: int)
signal contribution_added(contributor_id: String, amount: int)
signal crisis_resolved(success: bool)

# ============================================================
# MÉTHODES PUBLIQUES
# ============================================================

## Démarre la crise
func start_crisis(day: int) -> bool:
    if is_active:
        push_warning("Crisis already active: " + crisis_id)
        return false
    
    is_active = true
    start_day = day
    current_phase = 0
    current_contribution = 0
    contributors.clear()
    
    crisis_started.emit()
    print("[WorldCrisis] Crisis started: %s" % crisis_id)
    return true

## Obtient la phase actuelle
func get_current_phase() -> CrisisPhase:
    if current_phase < phases.size():
        return phases[current_phase]
    return null

## Obtient les quêtes de la phase actuelle
func get_current_phase_quests() -> Array[String]:
    var phase = get_current_phase()
    if phase:
        return phase.available_quests
    return []

## Ajoute de la contribution
func add_contribution(contributor_id: String, amount: int) -> void:
    current_contribution += amount
    
    if contributor_id in contributors:
        contributors[contributor_id] += amount
    else:
        contributors[contributor_id] = amount
    
    contribution_added.emit(contributor_id, amount)
    
    # Vérifier si l'objectif est atteint
    if current_contribution >= contribution_goal:
        resolve_crisis(true)

## Avance à la phase suivante
func advance_phase() -> bool:
    if current_phase not in completed_phases:
        completed_phases.append(current_phase)
    
    current_phase += 1
    
    if current_phase >= phases.size():
        # Dernière phase complétée
        return true
    
    phase_advanced.emit(current_phase)
    print("[WorldCrisis] Advanced to phase %d/%d" % [current_phase + 1, phases.size()])
    return false

## Résout la crise
func resolve_crisis(success: bool) -> void:
    if is_resolved:
        return
    
    is_resolved = true
    is_active = false
    result = "success" if success else "failure"
    
    # Appliquer les effets
    var effects = success_effects if success else failure_effects
    for effect in effects:
        effect.apply_to_world()
    
    crisis_resolved.emit(success)
    print("[WorldCrisis] Crisis resolved: %s (result: %s)" % [crisis_id, result])

## Vérifie l'échec par temps écoulé
func check_time_failure(current_day: int) -> bool:
    if not is_active or is_resolved:
        return false
    
    var elapsed = current_day - start_day
    if elapsed > time_limit:
        resolve_crisis(false)
        return true
    return false

## Obtient le temps restant
func get_days_remaining(current_day: int) -> int:
    var elapsed = current_day - start_day
    return max(0, time_limit - elapsed)

## Obtient la progression de contribution (0.0 à 1.0)
func get_contribution_progress() -> float:
    if contribution_goal <= 0:
        return 0.0
    return float(current_contribution) / float(contribution_goal)

## Obtient le classement des contributeurs
func get_top_contributors(count: int = 10) -> Array:
    var sorted_contributors = []
    
    for contributor_id in contributors.keys():
        sorted_contributors.append({
            "id": contributor_id,
            "contribution": contributors[contributor_id]
        })
    
    sorted_contributors.sort_custom(func(a, b): return a.contribution > b.contribution)
    
    return sorted_contributors.slice(0, min(count, sorted_contributors.size()))

# ============================================================
# SAUVEGARDE / CHARGEMENT
# ============================================================

func save_state() -> Dictionary:
    return {
        "current_phase": current_phase,
        "completed_phases": completed_phases.duplicate(),
        "start_day": start_day,
        "is_active": is_active,
        "is_resolved": is_resolved,
        "result": result,
        "current_contribution": current_contribution,
        "contributors": contributors.duplicate()
    }

func load_state(state: Dictionary) -> void:
    current_phase = state.get("current_phase", 0)
    completed_phases = state.get("completed_phases", [])
    start_day = state.get("start_day", -1)
    is_active = state.get("is_active", false)
    is_resolved = state.get("is_resolved", false)
    result = state.get("result", "")
    current_contribution = state.get("current_contribution", 0)
    contributors = state.get("contributors", {})
```

---

### 2.13 CrisisPhase (Resource)

**Rôle** : Définit une phase d'une crise mondiale.

**Fichier** : `src/world_events/crisis_phase.gd`

```gdscript
class_name CrisisPhase extends Resource

# ============================================================
# PROPRIÉTÉS
# ============================================================

## Nom de la phase
@export var phase_name: String = ""

## Description
@export_multiline var description: String = ""

## Durée de la phase (jours)
@export var duration: int = 10

## Quêtes disponibles pendant cette phase
@export var available_quests: Array[String] = []

## Événements déclenchés au début de la phase
@export var phase_start_events: Array[String] = []

## Événements déclenchés à la fin de la phase
@export var phase_end_events: Array[String] = []

## Effets appliqués pendant la phase
@export var phase_effects: Array[WorldEffect] = []

# ============================================================
# MÉTHODES
# ============================================================

## Démarre la phase
func start_phase() -> void:
    # Déclencher les événements de début
    for event_id in phase_start_events:
        EventBus.trigger_world_event.emit(event_id)
    
    # Appliquer les effets de phase
    for effect in phase_effects:
        effect.apply_to_world()
    
    print("[CrisisPhase] Phase started: %s" % phase_name)

## Termine la phase
func end_phase() -> void:
    # Déclencher les événements de fin
    for event_id in phase_end_events:
        EventBus.trigger_world_event.emit(event_id)
    
    print("[CrisisPhase] Phase ended: %s" % phase_name)
```

---

### 2.14 CrisisManager (Autoload Singleton)

**Rôle** : Gère les crises mondiales (Tier 5).

**Fichier** : `src/world_events/crisis_manager.gd`

```gdscript
class_name CrisisManager extends Node

# ============================================================
# SIGNAUX
# ============================================================

signal crisis_triggered(crisis_id: String)
signal crisis_phase_changed(crisis_id: String, phase_num: int)
signal crisis_resolved(crisis_id: String, success: bool)
signal contribution_milestone_reached(crisis_id: String, milestone: int)

# ============================================================
# DONNÉES
# ============================================================

## Crise actuellement active
var active_crisis: WorldCrisis = null

## Bibliothèque des crises disponibles
var crisis_library: Dictionary = {}  # crisis_id -> WorldCrisis

## Historique des crises résolues
var resolved_crises: Dictionary = {}  # crisis_id -> result_data

# ============================================================
# INITIALISATION
# ============================================================

func _ready() -> void:
    # S'abonner aux événements
    EventBus.day_advanced.connect(_on_day_advanced)
    QuestManager.quest_completed.connect(_on_quest_completed)
    
    # Charger les crises
    load_crisis_definitions()
    
    print("[CrisisManager] Initialized")

## Charge toutes les définitions de crises
func load_crisis_definitions() -> void:
    var dir_path = "res://data/crises/"
    var dir = DirAccess.open(dir_path)
    
    if not dir:
        print("[CrisisManager] No crises directory found")
        return
    
    dir.list_dir_begin()
    var file_name = dir.get_next()
    var count = 0
    
    while file_name != "":
        if file_name.ends_with(".tres"):
            var full_path = dir_path + file_name
            var crisis = load(full_path) as WorldCrisis
            if crisis:
                crisis_library[crisis.crisis_id] = crisis
                count += 1
        file_name = dir.get_next()
    
    dir.list_dir_end()
    print("[CrisisManager] Loaded %d crisis definitions" % count)

# ============================================================
# DÉCLENCHEMENT
# ============================================================

## Déclenche une crise
func trigger_crisis(crisis_id: String) -> bool:
    if active_crisis:
        push_warning("A crisis is already active: " + active_crisis.crisis_id)
        return false
    
    if crisis_id not in crisis_library:
        push_error("Unknown crisis: " + crisis_id)
        return false
    
    var crisis = crisis_library[crisis_id].duplicate(true)
    
    if not crisis.start_crisis(WorldGameState.current_day):
        return false
    
    active_crisis = crisis
    
    # Connecter les signaux
    crisis.phase_advanced.connect(_on_phase_advanced.bind(crisis_id))
    crisis.contribution_added.connect(_on_contribution_added.bind(crisis_id))
    crisis.crisis_resolved.connect(_on_crisis_resolved.bind(crisis_id))
    
    # Démarrer la première phase
    var first_phase = crisis.get_current_phase()
    if first_phase:
        first_phase.start_phase()
    
    # Ajouter les quêtes de la phase initiale
    var initial_quests = crisis.get_current_phase_quests()
    for quest_id in initial_quests:
        QuestManager.register_quest(QuestManager.get_quest_template(quest_id))
    
    crisis_triggered.emit(crisis_id)
    EventBus.world_crisis_started.emit(crisis_id)
    
    print("[CrisisManager] Crisis triggered: %s" % crisis_id)
    return true

## Déclenche une crise aléatoire
func trigger_random_crisis() -> bool:
    if crisis_library.is_empty():
        return false
    
    var crisis_ids = crisis_library.keys()
    var random_id = crisis_ids[randi() % crisis_ids.size()]
    return trigger_crisis(random_id)

# ============================================================
# CONTRIBUTION
# ============================================================

## Ajoute de la contribution à la crise active
func add_contribution(contributor_id: String, amount: int) -> void:
    if not active_crisis:
        return
    
    active_crisis.add_contribution(contributor_id, amount)
    
    # Vérifier les paliers
    check_contribution_milestones()

## Vérifie les paliers de contribution
func check_contribution_milestones() -> void:
    if not active_crisis:
        return
    
    var progress = active_crisis.get_contribution_progress()
    var milestones = [0.25, 0.50, 0.75, 1.0]
    
    for milestone in milestones:
        if progress >= milestone:
            contribution_milestone_reached.emit(active_crisis.crisis_id, int(milestone * 100))

# ============================================================
# PHASES
# ============================================================

## Avance à la phase suivante
func advance_phase() -> void:
    if not active_crisis:
        return
    
    # Terminer la phase actuelle
    var current_phase = active_crisis.get_current_phase()
    if current_phase:
        current_phase.end_phase()
    
    # Avancer
    var is_last_phase = active_crisis.advance_phase()
    
    if not is_last_phase:
        # Démarrer la nouvelle phase
        var new_phase = active_crisis.get_current_phase()
        if new_phase:
            new_phase.start_phase()
        
        # Ajouter les nouvelles quêtes
        var phase_quests = active_crisis.get_current_phase_quests()
        for quest_id in phase_quests:
            QuestManager.register_quest(QuestManager.get_quest_template(quest_id))
        
        crisis_phase_changed.emit(active_crisis.crisis_id, active_crisis.current_phase)

# ============================================================
# ÉVÉNEMENTS
# ============================================================

## Appelé chaque jour
func _on_day_advanced(day: int) -> void:
    if not active_crisis:
        return
    
    # Vérifier l'échec par temps
    active_crisis.check_time_failure(day)
    
    # Vérifier si il faut avancer de phase (basé sur le temps)
    var phase = active_crisis.get_current_phase()
    if phase:
        var elapsed_in_phase = day - (active_crisis.start_day + active_crisis.current_phase * phase.duration)
        if elapsed_in_phase >= phase.duration:
            advance_phase()

## Appelé quand une quête est complétée
func _on_quest_completed(quest_id: String) -> void:
    if not active_crisis:
        return
    
    # Vérifier si c'est une quête de crise
    var phase_quests = active_crisis.get_current_phase_quests()
    if quest_id in phase_quests:
        # Contribution automatique pour complétion de quête de crise
        var quest_template = QuestManager.get_quest_template(quest_id)
        if quest_template:
            var contribution_value = quest_template.estimate_difficulty() * 10
            add_contribution("player", contribution_value)

## Appelé quand une phase avance
func _on_phase_advanced(phase_num: int, crisis_id: String) -> void:
    print("[CrisisManager] Crisis %s - Phase %d" % [crisis_id, phase_num + 1])

## Appelé quand de la contribution est ajoutée
func _on_contribution_added(contributor_id: String, amount: int, crisis_id: String) -> void:
    print("[CrisisManager] Contribution: %s +%d (total: %d/%d)" % [
        contributor_id,
        amount,
        active_crisis.current_contribution,
        active_crisis.contribution_goal
    ])

## Appelé quand une crise est résolue
func _on_crisis_resolved(success: bool, crisis_id: String) -> void:
    if not active_crisis or active_crisis.crisis_id != crisis_id:
        return
    
    # Enregistrer dans l'historique
    resolved_crises[crisis_id] = {
        "result": active_crisis.result,
        "completion_day": WorldGameState.current_day,
        "duration": WorldGameState.current_day - active_crisis.start_day,
        "contribution": active_crisis.current_contribution,
        "top_contributors": active_crisis.get_top_contributors(5)
    }
    
    crisis_resolved.emit(crisis_id, success)
    EventBus.world_crisis_ended.emit(crisis_id, success)
    
    # Nettoyer
    active_crisis = null
    
    print("[CrisisManager] Crisis resolved: %s (success: %s)" % [crisis_id, success])

# ============================================================
# REQUÊTES
# ============================================================

## Obtient la crise active
func get_active_crisis() -> WorldCrisis:
    return active_crisis

## Vérifie si une crise est active
func has_active_crisis() -> bool:
    return active_crisis != null

## Obtient les statistiques de la crise active
func get_crisis_stats() -> Dictionary:
    if not active_crisis:
        return {}
    
    return {
        "crisis_id": active_crisis.crisis_id,
        "title": active_crisis.title,
        "current_phase": active_crisis.current_phase + 1,
        "total_phases": active_crisis.phases.size(),
        "days_remaining": active_crisis.get_days_remaining(WorldGameState.current_day),
        "contribution_progress": active_crisis.get_contribution_progress(),
        "current_contribution": active_crisis.current_contribution,
        "contribution_goal": active_crisis.contribution_goal
    }

# ============================================================
# SAUVEGARDE / CHARGEMENT
# ============================================================

func save_state() -> Dictionary:
    var state = {
        "active_crisis": null,
        "resolved_crises": resolved_crises.duplicate(true)
    }
    
    if active_crisis:
        state["active_crisis"] = {
            "crisis_id": active_crisis.crisis_id,
            "crisis_state": active_crisis.save_state()
        }
    
    return state

func load_state(state: Dictionary) -> void:
    resolved_crises = state.get("resolved_crises", {})
    
    var active_crisis_data = state.get("active_crisis")
    if active_crisis_data:
        var crisis_id = active_crisis_data.get("crisis_id", "")
        if crisis_id in crisis_library:
            active_crisis = crisis_library[crisis_id].duplicate(true)
            active_crisis.load_state(active_crisis_data.get("crisis_state", {}))
    
    print("[CrisisManager] State loaded")
```

---

## 3. Génération procédurale et algorithmes

### 3.1 QuestGenerator

**Rôle** : Génère des quêtes procéduralement selon des paramètres.

**Fichier** : `src/quests/generation/quest_generator.gd`

```gdscript
class_name QuestGenerator extends RefCounted

# ============================================================
# DONNÉES
# ============================================================

## Pool de templates pour génération
var template_pool: QuestPool

## Générateur de noms
var name_generator: NameGenerator

## Seed aléatoire pour reproductibilité
var generation_seed: int = 0

# ============================================================
# INITIALISATION
# ============================================================

func _init() -> void:
    template_pool = QuestPool.new()
    name_generator = NameGenerator.new()
    generation_seed = randi()

## Définit le seed de génération
func set_seed(seed: int) -> void:
    generation_seed = seed
    seed(seed)

# ============================================================
# GÉNÉRATION PRINCIPALE
# ============================================================

## Génère une quête procédurale
func generate_quest(tier: QuestTypes.Tier, params: Dictionary = {}) -> QuestTemplate:
    # Sélectionner une catégorie
    var category = params.get("category", _random_category())
    
    # Sélectionner un template de base
    var base_template = template_pool.get_random_template(category, tier)
    if not base_template:
        push_error("No template found for category %s tier %d" % [category, tier])
        return null
    
    # Dupliquer et modifier
    var quest = base_template.duplicate_template()
    
    # Personnaliser selon les paramètres
    _customize_quest(quest, params)
    
    # Générer les objectifs
    _generate_objectives(quest, params)
    
    # Générer les récompenses
    _generate_rewards(quest, params)
    
    # Générer les conditions
    _generate_conditions(quest, params)
    
    return quest

## Personnalise une quête selon les paramètres
func _customize_quest(quest: QuestTemplate, params: Dictionary) -> void:
    # Titre et description
    var theme = params.get("theme", "generic")
    quest.title = name_generator.generate_quest_title(theme, quest.category)
    quest.description = name_generator.generate_quest_description(theme, quest.category)
    
    # Ajuster la difficulté
    var difficulty = params.get("difficulty", 1.0)
    _adjust_difficulty(quest, difficulty)
    
    # Tags thématiques
    quest.tags = _generate_tags(theme, quest.category, params)
    
    # Priorité
    quest.display_priority = params.get("priority", randi() % 10)

## Génère les objectifs d'une quête
func _generate_objectives(quest: QuestTemplate, params: Dictionary) -> void:
    quest.objectives.clear()
    
    var objective_count = params.get("objective_count", 1)
    objective_count = clampi(objective_count, 1, QuestTypes.MAX_OBJECTIVES_PER_QUEST)
    
    for i in range(objective_count):
        var objective = _generate_single_objective(quest.category, params)
        if objective:
            quest.objectives.append(objective)

## Génère un objectif unique
func _generate_single_objective(category: QuestTypes.Category, params: Dictionary) -> ObjectiveData:
    var obj = ObjectiveData.new()
    
    # Choisir le type d'objectif selon la catégorie
    obj.type = _select_objective_type(category)
    
    # Paramètres spécifiques
    match obj.type:
        QuestTypes.ObjectiveType.DEFEAT:
            obj.parameters = {
                "enemy_type": params.get("enemy_type", _random_enemy_type()),
                "count": _scaled_count(params.get("difficulty", 1.0), 5, 20)
            }
        
        QuestTypes.ObjectiveType.REACH:
            obj.parameters = {
                "location_id": params.get("location", _random_location()),
                "radius": 2
            }
        
        QuestTypes.ObjectiveType.COLLECT:
            obj.parameters = {
                "item_id": params.get("item", _random_item()),
                "count": _scaled_count(params.get("difficulty", 1.0), 1, 5)
            }
        
        QuestTypes.ObjectiveType.PROTECT:
            obj.parameters = {
                "target_id": params.get("target", _random_npc()),
                "duration": _scaled_count(params.get("difficulty", 1.0), 3, 10)
            }
        
        QuestTypes.ObjectiveType.ESCORT:
            obj.parameters = {
                "unit_id": params.get("unit", _random_npc()),
                "destination": params.get("destination", _random_location()),
                "must_survive": true
            }
    
    # Description auto-générée
    obj.description = obj.get_display_description()
    
    return obj

## Génère les récompenses
func _generate_rewards(quest: QuestTemplate, params: Dictionary) -> void:
    quest.rewards.clear()
    
    var difficulty = params.get("difficulty", 1.0)
    var base_value = int(difficulty * 100)
    
    # Récompense en or (toujours présente)
    var gold_reward = RewardData.new()
    gold_reward.type = QuestTypes.RewardType.GOLD
    gold_reward.amount = base_value + randi() % (base_value / 2)
    quest.rewards.append(gold_reward)
    
    # Récompenses additionnelles basées sur la difficulté
    if difficulty >= 2.0:
        # Réputation
        var rep_reward = RewardData.new()
        rep_reward.type = QuestTypes.RewardType.REPUTATION
        rep_reward.amount = int(difficulty * 10)
        rep_reward.parameters = {"faction_id": params.get("faction", _random_faction())}
        quest.rewards.append(rep_reward)
    
    if difficulty >= 3.0:
        # Items ou XP
        if randf() > 0.5:
            var item_reward = RewardData.new()
            item_reward.type = QuestTypes.RewardType.ITEMS
            item_reward.parameters = {"item_ids": [_random_item_by_rarity("rare")]}
            quest.rewards.append(item_reward)
        else:
            var xp_reward = RewardData.new()
            xp_reward.type = QuestTypes.RewardType.EXPERIENCE
            xp_reward.amount = int(difficulty * 50)
            xp_reward.parameters = {"target": "all_units"}
            quest.rewards.append(xp_reward)

## Génère les conditions d'apparition
func _generate_conditions(quest: QuestTemplate, params: Dictionary) -> void:
    var conditions = QuestConditions.new()
    
    # Conditions temporelles
    var min_day = params.get("min_day", -1)
    if min_day > 0:
        conditions.required_day = min_day
    
    var max_day = params.get("max_day", -1)
    if max_day > 0:
        conditions.max_day = max_day
    
    # Tags requis
    var required_tags = params.get("required_tags", [])
    conditions.required_player_tags = required_tags
    
    # Conditions de faction
    var faction_id = params.get("faction", "")
    if faction_id != "":
        var min_rep = params.get("min_reputation", 0)
        if min_rep > 0:
            conditions.required_faction_reputation[faction_id] = min_rep
    
    # Quêtes prérequises
    var prerequisite = params.get("prerequisite_quest", "")
    if prerequisite != "":
        conditions.required_completed_quests.append(prerequisite)
    
    quest.conditions = conditions

# ============================================================
# HELPERS PRIVÉS
# ============================================================

## Ajuste la difficulté d'une quête
func _adjust_difficulty(quest: QuestTemplate, difficulty: float) -> void:
    # Ajuster le temps limite
    if difficulty >= 2.0:
        quest.time_limit = int(20.0 / difficulty)
    
    # Ajuster les objectifs (sera fait dans _generate_objectives)
    pass

## Génère les tags d'une quête
func _generate_tags(theme: String, category: QuestTypes.Category, params: Dictionary) -> Array[String]:
    var tags: Array[String] = []
    
    tags.append(theme)
    tags.append(QuestTypes.Category.keys()[category].to_lower())
    
    if params.get("difficulty", 1.0) >= 3.0:
        tags.append("difficult")
    
    if params.get("urgent", false):
        tags.append("urgent")
    
    return tags

## Calcule un compte mis à l'échelle selon la difficulté
func _scaled_count(difficulty: float, base_min: int, base_max: int) -> int:
    var min_val = int(base_min * difficulty)
    var max_val = int(base_max * difficulty)
    return min_val + randi() % (max_val - min_val + 1)

## Sélectionne un type d'objectif selon la catégorie
func _select_objective_type(category: QuestTypes.Category) -> QuestTypes.ObjectiveType:
    match category:
        QuestTypes.Category.COMBAT:
            return QuestTypes.ObjectiveType.DEFEAT
        QuestTypes.Category.EXPLORATION:
            return QuestTypes.ObjectiveType.REACH
        QuestTypes.Category.TRADE:
            return [QuestTypes.ObjectiveType.COLLECT, QuestTypes.ObjectiveType.ESCORT][randi() % 2]
        QuestTypes.Category.DEFENSE:
            return QuestTypes.ObjectiveType.PROTECT
        QuestTypes.Category.DIPLOMACY:
            return QuestTypes.ObjectiveType.NEGOTIATE
        _:
            return QuestTypes.ObjectiveType.DEFEAT

## Helpers de génération aléatoire
func _random_category() -> QuestTypes.Category:
    return randi() % QuestTypes.Category.size()

func _random_enemy_type() -> String:
    var enemies = ["bandit", "wolf", "goblin", "orc", "undead"]
    return enemies[randi() % enemies.size()]

func _random_location() -> String:
    return "location_" + str(randi() % 50)

func _random_item() -> String:
    return "item_" + str(randi() % 100)

func _random_npc() -> String:
    return "npc_" + str(randi() % 30)

func _random_faction() -> String:
    var factions = ["empire", "merchants", "rebels", "nomads"]
    return factions[randi() % factions.size()]

func _random_item_by_rarity(rarity: String) -> String:
    return "item_" + rarity + "_" + str(randi() % 20)
```

---

### 3.2 QuestPool

**Rôle** : Bibliothèque de templates pour génération procédurale.

**Fichier** : `src/quests/generation/quest_pool.gd`

```gdscript
class_name QuestPool extends RefCounted

# ============================================================
# DONNÉES
# ============================================================

## Templates organisés par catégorie et tier
var templates_by_category: Dictionary = {}
# Format: { category -> { tier -> [templates] } }

# ============================================================
# INITIALISATION
# ============================================================

func _init() -> void:
    _load_base_templates()

## Charge les templates de base
func _load_base_templates() -> void:
    for category in QuestTypes.Category.values():
        templates_by_category[category] = {}
        for tier in QuestTypes.Tier.values():
            templates_by_category[category][tier] = []
    
    # Charger depuis les fichiers
    _load_templates_from_directory("res://data/quests/templates/")

## Charge les templates depuis un répertoire
func _load_templates_from_directory(dir_path: String) -> void:
    var dir = DirAccess.open(dir_path)
    if not dir:
        return
    
    dir.list_dir_begin()
    var file_name = dir.get_next()
    
    while file_name != "":
        if file_name.ends_with(".tres"):
            var full_path = dir_path + file_name
            var template = load(full_path) as QuestTemplate
            if template:
                add_template(template)
        file_name = dir.get_next()
    
    dir.list_dir_end()

# ============================================================
# GESTION
# ============================================================

## Ajoute un template au pool
func add_template(template: QuestTemplate) -> void:
    var category = template.category
    var tier = template.tier
    
    if category not in templates_by_category:
        templates_by_category[category] = {}
    
    if tier not in templates_by_category[category]:
        templates_by_category[category][tier] = []
    
    templates_by_category[category][tier].append(template)

## Obtient un template aléatoire
func get_random_template(category: QuestTypes.Category, tier: QuestTypes.Tier) -> QuestTemplate:
    if category not in templates_by_category:
        return null
    
    if tier not in templates_by_category[category]:
        return null
    
    var templates = templates_by_category[category][tier]
    if templates.is_empty():
        return null
    
    return templates[randi() % templates.size()]

## Obtient tous les templates d'une catégorie/tier
func get_templates(category: QuestTypes.Category, tier: QuestTypes.Tier) -> Array[QuestTemplate]:
    if category in templates_by_category and tier in templates_by_category[category]:
        return templates_by_category[category][tier]
    return []
```

---

## 4. Système de conditions et tags

### 4.1 Vue d'ensemble

Le système de conditions et tags permet un contrôle fin de l'apparition des quêtes basé sur l'état du monde et du joueur.

### 4.2 Types de tags

```gdscript
# Tags du joueur (player_tags)
# - Compétences/capacités: "veteran", "trader", "diplomat"
# - Expérience: "has_army", "owns_territory", "completed_10_quests"
# - Réputation: "hero_of_realm", "infamous", "neutral"

# Tags du monde (world_tags)
# - États globaux: "war_time", "peace", "prosperity", "crisis"
# - Saisons: "spring", "summer", "autumn", "winter"
# - Événements: "festival_active", "plague_outbreak", "drought"
```

### 4.3 Évaluation des conditions

**Logique ET/OU** :
- `required_player_tags` : ET logique (tous requis)
- `required_world_tags` : ET logique (tous requis)
- `excluded_tags` : OU logique (si au moins un présent → refuse)

**Exemple complexe** :

```gdscript
var conditions = QuestConditions.new()

# Le joueur DOIT avoir "veteran" ET "owns_territory"
conditions.required_player_tags = ["veteran", "owns_territory"]

# Le monde DOIT être en "war_time" ET en "winter"
conditions.required_world_tags = ["war_time", "winter"]

# Mais SI "peace" OU "festival_active" est présent → refuse
conditions.excluded_tags = ["peace", "festival_active"]

# Réputation minimale avec empire
conditions.required_faction_reputation = {"empire": 50}

# Doit avoir complété cette quête avant
conditions.required_completed_quests = ["tutorial_quest"]
```

### 4.4 Propagation des tags

```gdscript
# Dans WorldGameState
func add_world_tag(tag: String) -> void:
    if tag not in world_tags:
        world_tags.append(tag)
        EventBus.world_tag_added.emit(tag)
        # Déclencher une vérification des quêtes disponibles
        QuestManager.refresh_available_quests()

func remove_world_tag(tag: String) -> void:
    if tag in world_tags:
        world_tags.erase(tag)
        EventBus.world_tag_removed.emit(tag)
        QuestManager.refresh_available_quests()

# Tags ajoutés automatiquement
func _on_season_changed(season: int) -> void:
    # Retirer les anciens tags de saison
    for s in ["spring", "summer", "autumn", "winter"]:
        remove_world_tag(s)
    
    # Ajouter le nouveau
    var season_names = ["spring", "summer", "autumn", "winter"]
    add_world_tag(season_names[season])

# Tags ajoutés par événements
func _on_war_declared(faction1: String, faction2: String) -> void:
    add_world_tag("war_time")
    add_world_tag("war_" + faction1 + "_" + faction2)

func _on_peace_treaty(faction1: String, faction2: String) -> void:
    remove_world_tag("war_" + faction1 + "_" + faction2)
    # Si plus aucune guerre
    if not has_active_wars():
        remove_world_tag("war_time")
        add_world_tag("peace")
```

---

## 5. Intégrations inter-systèmes

### 5.1 Quêtes ↔ Factions

**Impact des quêtes sur les factions** :

```gdscript
# Dans RewardData.apply_reward()
if type == QuestTypes.RewardType.REPUTATION:
    var faction_id = parameters.get("faction_id", "")
    var amount = self.amount
    
    FactionManager.add_reputation(faction_id, amount)
    
    # Déclencher des événements si seuils atteints
    var new_rep = FactionManager.get_reputation(faction_id)
    if new_rep >= 100 and new_rep - amount < 100:
        EventBus.faction_ally_reached.emit(faction_id)
    elif new_rep <= -100 and new_rep - amount > -100:
        EventBus.faction_enemy_reached.emit(faction_id)
```

**Impact des factions sur les quêtes** :

```gdscript
# Dans QuestConditions.check_faction_conditions()
func check_faction_conditions() -> bool:
    # Réputation minimale
    for faction_id in required_faction_reputation:
        var min_rep = required_faction_reputation[faction_id]
        var current_rep = FactionManager.get_reputation(faction_id)
        if current_rep < min_rep:
            return false
    
    # Guerres requises
    for faction_id in required_war_factions:
        if not FactionManager.is_at_war(faction_id):
            return false
    
    return true
```

---

### 5.2 Campagnes ↔ Monde

**WorldImpact** appliqué après campagne :

```gdscript
class_name WorldImpact extends Resource

@export var unlock_regions: Array[String] = []
@export var change_faction_states: Dictionary = {}
@export var trigger_events: Array[String] = []
@export var modify_resources: Dictionary = {}
@export var add_world_tags: Array[String] = []
@export var remove_world_tags: Array[String] = []

func apply_to_world() -> void:
    # Déverrouiller régions
    for region_id in unlock_regions:
        WorldGameState.unlock_region(region_id)
        print("Region unlocked: %s" % region_id)
    
    # Changer états de factions
    for faction_id in change_faction_states:
        var new_state = change_faction_states[faction_id]
        FactionManager.set_faction_state(faction_id, new_state)
    
    # Déclencher événements
    for event_id in trigger_events:
        EventBus.trigger_world_event.emit(event_id)
    
    # Modifier ressources globales
    for resource_id in modify_resources:
        var amount = modify_resources[resource_id]
        WorldGameState.modify_global_resource(resource_id, amount)
    
    # Tags du monde
    for tag in add_world_tags:
        WorldGameState.add_world_tag(tag)
    
    for tag in remove_world_tags:
        WorldGameState.remove_world_tag(tag)
```

---

### 5.3 Crises ↔ Tout le système

**Flux de données des crises** :

```
┌─────────────┐
│ CrisisManager│
└──────┬──────┘
       │ trigger_crisis()
       ▼
┌─────────────┐
│ WorldCrisis │
│             │
│ - phases    │
│ - timer     │
│ - contrib   │
└──────┬──────┘
       │
       ├──> QuestManager
       │    (ajoute quêtes de crise)
       │
       ├──> WorldGameState
       │    (ajoute tags "crisis_active")
       │
       ├──> FactionManager
       │    (modifie relations)
       │
       └──> EventBus
            (signaux globaux)
```

**Exemple d'intégration complète** :

```gdscript
# Déclenchement d'une crise
func trigger_invasion_crisis() -> void:
    # 1. Déclencher la crise
    CrisisManager.trigger_crisis("barbarian_invasion")
    
    # 2. Le CrisisManager ajoute automatiquement les tags
    WorldGameState.add_world_tag("crisis_active")
    WorldGameState.add_world_tag("invasion")
    
    # 3. Les quêtes de crise deviennent disponibles
    # (via QuestConditions qui vérifient world_tags)
    QuestManager.refresh_available_quests()
    
    # 4. Les factions réagissent
    EventBus.world_crisis_started.connect(_on_crisis_started)

func _on_crisis_started(crisis_id: String) -> void:
    # Toutes les factions en guerre mettent leurs conflits en pause
    FactionManager.pause_all_wars()
    
    # Modifier les prix dans les marchés
    EconomyManager.apply_crisis_multipliers(1.5)
    
    # Activer des événements aléatoires plus fréquents
    EventManager.increase_event_frequency(2.0)
```

---

## 6. Exemples de code complets

### 6.1 Créer et lancer une quête simple

```gdscript
# Script: example_simple_quest.gd

func create_and_start_escort_quest() -> void:
    # 1. Créer le template
    var quest = QuestTemplate.new()
    quest.quest_id = "escort_merchant_to_capital"
    quest.tier = QuestTypes.Tier.TIER_1
    quest.category = QuestTypes.Category.TRADE
    quest.title = "Escorte du Marchand"
    quest.description = "Un marchand vous demande de l'escorter jusqu'à la capitale. Le voyage est dangereux."
    quest.completion_text = "Le marchand arrive sain et sauf. Il vous remercie chaleureusement."
    
    # 2. Ajouter l'objectif
    var objective = ObjectiveData.new()
    objective.type = QuestTypes.ObjectiveType.ESCORT
    objective.description = "Escortez le marchand jusqu'à la capitale"
    objective.parameters = {
        "unit_id": "merchant_npc_01",
        "destination": "capital_city",
        "must_survive": true
    }
    quest.objectives.append(objective)
    
    # 3. Ajouter les récompenses
    var gold_reward = RewardData.new()
    gold_reward.type = QuestTypes.RewardType.GOLD
    gold_reward.amount = 200
    quest.rewards.append(gold_reward)
    
    var rep_reward = RewardData.new()
    rep_reward.type = QuestTypes.RewardType.REPUTATION
    rep_reward.amount = 15
    rep_reward.parameters = {"faction_id": "merchant_guild"}
    quest.rewards.append(rep_reward)
    
    # 4. Définir les conditions
    var conditions = QuestConditions.new()
    conditions.required_player_tags = ["has_army"]  # Doit avoir une armée
    conditions.available_regions = ["plains", "forest"]  # Disponible dans ces régions
    quest.conditions = conditions
    
    # 5. Autres paramètres
    quest.time_limit = 15  # 15 jours pour compléter
    quest.repeatable = false
    quest.display_priority = 5
    quest.tags = ["trade", "escort", "merchant_guild"]
    
    # 6. Sauvegarder comme ressource (optionnel)
    var save_path = "res://data/quests/tier1/escort_merchant.tres"
    ResourceSaver.save(quest, save_path)
    
    # 7. Enregistrer dans le QuestManager
    QuestManager.register_quest(quest)
    
    # 8. Démarrer la quête
    var instance = QuestManager.start_quest("escort_merchant_to_capital")
    
    # 9. Connecter aux événements pour suivre la progression
    if instance:
        instance.objective_updated.connect(_on_escort_objective_updated)
        instance.quest_completed.connect(_on_escort_quest_completed)
        print("Quête démarrée: " + quest.title)

func _on_escort_objective_updated(obj_index: int, current: int, required: int) -> void:
    print("Progression escorte: %d/%d" % [current, required])

func _on_escort_quest_completed() -> void:
    print("Quête d'escorte terminée!")
    # L'application des récompenses est automatique via QuestManager
```

---

### 6.2 Générer une campagne procédurale complète

```gdscript
# Script: example_procedural_campaign.gd

func generate_bandit_eradication_campaign() -> void:
    # 1. Paramètres de génération
    var campaign_params = {
        "theme": "bandit_threat",
        "difficulty": 2.0,
        "region": "northern_plains",
        "faction": "local_militia",
        "min_reputation": 25
    }
    
    # 2. Générer la chaîne de quêtes
    var chain = CampaignManager.generate_quest_chain(
        "bandit_threat",  # thème
        4,                # 4 quêtes
        QuestTypes.Tier.TIER_2,
        campaign_params
    )
    
    # 3. Personnaliser le bonus de complétion
    var bonus_reward = RewardData.new()
    bonus_reward.type = QuestTypes.RewardType.UNLOCK
    bonus_reward.parameters = {
        "unlock_type": "tech",
        "unlock_id": "advanced_tactics"
    }
    chain.chain_completion_reward = bonus_reward
    
    # 4. Sauvegarder la chaîne (optionnel)
    var save_path = "res://data/campaigns/quest_chains/bandit_threat_%d.tres" % randi()
    ResourceSaver.save(chain, save_path)
    
    # 5. Connecter aux signaux pour suivre la progression
    chain.chain_advanced.connect(_on_campaign_advanced)
    chain.chain_completed.connect(_on_campaign_completed)
    
    # 6. Démarrer la campagne
    if CampaignManager.start_chain(chain):
        print("Campagne démarrée: %d quêtes" % chain.quest_ids.size())
        _display_campaign_info(chain)

func _on_campaign_advanced(new_index: int) -> void:
    print("Campagne avancée: quête %d démarrée" % (new_index + 1))
    # Afficher notification UI
    EventBus.show_notification.emit("Nouvelle quête de campagne disponible!")

func _on_campaign_completed() -> void:
    print("Campagne complétée! Bonus appliqué.")
    # Cinématique de fin, dialogue, etc.
    EventBus.play_campaign_outro.emit("bandit_threat")

func _display_campaign_info(chain: QuestChain) -> void:
    print("=== Campagne: %s ===" % chain.theme)
    print("Quêtes:")
    for i in range(chain.quest_ids.size()):
        var quest_id = chain.quest_ids[i]
        var template = QuestManager.get_quest_template(quest_id)
        if template:
            print("  %d. %s (difficulté: %.1f)" % [i + 1, template.title, chain.difficulty_curve[i]])
    print("Récompense finale: %s" % chain.chain_completion_reward.get_display_text())
```

---

### 6.3 Créer une campagne narrative complète

```gdscript
# Script: example_narrative_campaign.gd

func create_empire_rise_campaign() -> Resource:
    # 1. Créer la campagne
    var campaign = FactionCampaign.new()
    campaign.campaign_id = "empire_rise"
    campaign.faction_id = "empire_central"
    campaign.title = "L'Ascension de l'Empire"
    campaign.description = "Aidez l'Empire Central à étendre son influence et à restaurer sa gloire passée."
    
    # 2. Conditions de déverrouillage
    campaign.required_reputation = 50
    campaign.unlock_tags = ["empire_sympathizer"]
    campaign.required_quests = ["meet_emperor"]
    
    # 3. Créer le Chapitre 1
    var chapter1 = ChapterData.new()
    chapter1.chapter_number = 1
    chapter1.title = "Premiers Pas"
    chapter1.description = "Établissez une présence impériale dans les terres frontalières."
    chapter1.quest_ids = [
        "empire_build_outpost",
        "empire_recruit_garrison",
        "empire_secure_roads"
    ]
    chapter1.completion_requirement = "all"
    
    # Récompenses du chapitre 1
    var ch1_reward = RewardData.new()
    ch1_reward.type = QuestTypes.RewardType.TERRITORY
    ch1_reward.parameters = {"region_id": "frontier_outpost"}
    chapter1.rewards.append(ch1_reward)
    
    campaign.chapters.append(chapter1)
    
    # 4. Créer le Chapitre 2 (branchement)
    var chapter2 = ChapterData.new()
    chapter2.chapter_number = 2
    chapter2.title = "Diplomatie ou Conquête"
    chapter2.description = "Choisissez votre approche pour étendre l'influence impériale."
    chapter2.quest_ids = [
        "empire_diplomatic_mission",  # Branche diplomatique
        "empire_military_campaign"    # Branche militaire
    ]
    chapter2.completion_requirement = "any"  # L'une OU l'autre
    chapter2.required_count = 1
    
    campaign.chapters.append(chapter2)
    
    # 5. Créer le Chapitre 3
    var chapter3 = ChapterData.new()
    chapter3.chapter_number = 3
    chapter3.title = "Consolidation"
    chapter3.description = "Renforcez les gains territoriaux et les alliances."
    chapter3.quest_ids = [
        "empire_fortify_borders",
        "empire_trade_agreements",
        "empire_cultural_festival"
    ]
    chapter3.completion_requirement = "count"
    chapter3.required_count = 2  # Au moins 2 sur 3
    
    campaign.chapters.append(chapter3)
    
    # 6. Créer le Chapitre 4 (final)
    var chapter4 = ChapterData.new()
    chapter4.chapter_number = 4
    chapter4.title = "L'Apogée"
    chapter4.description = "Menez l'Empire vers une nouvelle ère de prospérité."
    chapter4.quest_ids = [
        "empire_grand_coronation",
        "empire_defeat_rivals"
    ]
    chapter4.completion_requirement = "all"
    
    # Récompense finale
    var final_reward = RewardData.new()
    final_reward.type = QuestTypes.RewardType.UNLOCK
    final_reward.parameters = {
        "unlock_type": "unit",
        "unlock_id": "imperial_guard"
    }
    chapter4.rewards.append(final_reward)
    
    campaign.chapters.append(chapter4)
    
    # 7. Impact mondial de la campagne
    var world_impact = WorldImpact.new()
    world_impact.unlock_regions = ["northern_territories", "eastern_provinces"]
    world_impact.change_faction_states = {
        "empire_central": "dominant",
        "rebels": "weakened"
    }
    world_impact.add_world_tags = ["imperial_era", "prosperity"]
    world_impact.trigger_events = ["imperial_golden_age_begins"]
    campaign.world_impact = world_impact
    
    # 8. Relations avec d'autres factions
    campaign.faction_relations = {
        "empire_central": 100,     # Boost énorme
        "merchant_guild": 50,      # Amélioration
        "kingdom_north": -30,      # Détérioration
        "rebels": -100             # Hostilité
    }
    
    # 9. Sauvegarder
    var save_path = "res://data/campaigns/faction_campaigns/empire_rise.tres"
    ResourceSaver.save(campaign, save_path)
    
    print("Campagne narrative créée: %s (%d chapitres)" % [campaign.title, campaign.chapters.size()])
    return campaign

# Démarrer la campagne
func start_empire_campaign() -> void:
    # Vérifier que la campagne a été chargée dans CampaignManager
    if CampaignManager.check_campaign_unlock("empire_rise"):
        if CampaignManager.start_narrative_campaign("empire_rise"):
            print("Campagne 'L'Ascension de l'Empire' démarrée!")
            # Afficher cinématique d'intro
            EventBus.play_campaign_intro.emit("empire_rise")
    else:
        print("Conditions non remplies pour démarrer cette campagne")
        # Afficher les conditions manquantes au joueur
        var campaign = CampaignManager.campaign_library.get("empire_rise")
        if campaign:
            print("Requis:")
            print("- Réputation Empire: %d" % campaign.required_reputation)
            print("- Tags: %s" % str(campaign.unlock_tags))
            print("- Quêtes: %s" % str(campaign.required_quests))
```

---

### 6.4 Déclencher et gérer une crise mondiale

```gdscript
# Script: example_world_crisis.gd

func create_barbarian_invasion_crisis() -> Resource:
    # 1. Créer la crise
    var crisis = WorldCrisis.new()
    crisis.crisis_id = "barbarian_horde_2025"
    crisis.crisis_type = "invasion"
    crisis.title = "La Horde Barbare"
    crisis.description = "Une immense horde barbare déferle sur les royaumes civilisés. Toutes les factions doivent s'unir pour survivre."
    crisis.time_limit = 40  # 40 jours
    crisis.contribution_goal = 2000
    
    # 2. Créer la Phase 1
    var phase1 = CrisisPhase.new()
    phase1.phase_name = "Raids Préliminaires"
    phase1.description = "Des éclaireurs barbares attaquent les villages isolés."
    phase1.duration = 12
    phase1.available_quests = [
        "crisis_defend_village_1",
        "crisis_defend_village_2",
        "crisis_scout_enemy",
        "crisis_evacuate_civilians"
    ]
    phase1.phase_start_events = ["barbarian_scouts_spotted"]
    
    # Effet: réduction des ressources
    var phase1_effect = WorldEffect.new()
    phase1_effect.effect_type = "modify_resource"
    phase1_effect.parameters = {"resource": "food", "multiplier": 0.9}
    phase1.phase_effects.append(phase1_effect)
    
    crisis.phases.append(phase1)
    
    # 3. Créer la Phase 2
    var phase2 = CrisisPhase.new()
    phase2.phase_name = "L'Offensive Principale"
    phase2.description = "La horde principale arrive. Les batailles font rage partout."
    phase2.duration = 15
    phase2.available_quests = [
        "crisis_hold_fortress",
        "crisis_flank_attack",
        "crisis_destroy_siege",
        "crisis_rescue_troops"
    ]
    phase2.phase_start_events = ["horde_main_force_arrives"]
    
    # Effet: augmentation des ennemis
    var phase2_effect = WorldEffect.new()
    phase2_effect.effect_type = "increase_enemy_spawn"
    phase2_effect.parameters = {"multiplier": 1.5}
    phase2.phase_effects.append(phase2_effect)
    
    crisis.phases.append(phase2)
    
    # 4. Créer la Phase 3 (finale)
    var phase3 = CrisisPhase.new()
    phase3.phase_name = "Confrontation Finale"
    phase3.description = "Affrontez le chef de guerre barbare dans une bataille décisive."
    phase3.duration = 13
    phase3.available_quests = [
        "crisis_final_battle",
        "crisis_duel_warlord",
        "crisis_destroy_totems"
    ]
    phase3.phase_start_events = ["warlord_challenges_world"]
    phase3.phase_end_events = ["barbarians_retreat"]
    
    crisis.phases.append(phase3)
    
    # 5. Effets d'échec
    var failure1 = WorldEffect.new()
    failure1.effect_type = "destroy_region"
    failure1.parameters = {"region_id": "frontier_lands"}
    crisis.failure_effects.append(failure1)
    
    var failure2 = WorldEffect.new()
    failure2.effect_type = "add_world_tag"
    failure2.parameters = {"tag": "dark_age"}
    crisis.failure_effects.append(failure2)
    
    var failure3 = WorldEffect.new()
    failure3.effect_type = "faction_state_change"
    failure3.parameters = {
        "changes": {
            "empire_central": "weakened",
            "rebels": "destroyed"
        }
    }
    crisis.failure_effects.append(failure3)
    
    # 6. Effets de succès
    var success1 = WorldEffect.new()
    success1.effect_type = "unlock_tech"
    success1.parameters = {"tech_id": "fortification_mastery"}
    crisis.success_effects.append(success1)
    
    var success2 = WorldEffect.new()
    success2.effect_type = "add_world_tag"
    success2.parameters = {"tag": "united_front"}
    crisis.success_effects.append(success2)
    
    var success3 = WorldEffect.new()
    success3.effect_type = "global_reputation_boost"
    success3.parameters = {"amount": 50}
    crisis.success_effects.append(success3)
    
    # 7. Sauvegarder
    var save_path = "res://data/crises/barbarian_horde.tres"
    ResourceSaver.save(crisis, save_path)
    
    print("Crise mondiale créée: %s" % crisis.title)
    return crisis

# Démarrer et gérer la crise
func trigger_and_manage_crisis() -> void:
    # 1. Déclencher
    if CrisisManager.trigger_crisis("barbarian_horde_2025"):
        print("CRISE MONDIALE DÉCLENCHÉE!")
        
        # 2. Connecter aux événements
        CrisisManager.crisis_phase_changed.connect(_on_crisis_phase_changed)
        CrisisManager.contribution_milestone_reached.connect(_on_milestone_reached)
        CrisisManager.crisis_resolved.connect(_on_crisis_resolved)
        
        # 3. Afficher UI
        _show_crisis_ui()
        
        # 4. Notifications globales
        EventBus.show_global_alert.emit("ALERTE: Invasion barbare imminente!")

func _on_crisis_phase_changed(crisis_id: String, phase_num: int) -> void:
    print("=== Nouvelle Phase ===")
    var crisis = CrisisManager.get_active_crisis()
    if crisis:
        var phase = crisis.get_current_phase()
        print("Phase %d: %s" % [phase_num + 1, phase.phase_name])
        print(phase.description)
        
        # Cinématique de transition
        EventBus.play_crisis_phase_cutscene.emit(crisis_id, phase_num)
        
        # Mise à jour UI
        _update_crisis_ui()

func _on_milestone_reached(crisis_id: String, milestone: int) -> void:
    print("Palier de contribution atteint: %d%%" % milestone)
    
    match milestone:
        25:
            EventBus.show_notification.emit("Le moral des troupes s'améliore!")
        50:
            EventBus.show_notification.emit("Les barbares commencent à reculer!")
        75:
            EventBus.show_notification.emit("La victoire est à portée de main!")
        100:
            EventBus.show_notification.emit("VICTOIRE! La horde est repoussée!")

func _on_crisis_resolved(crisis_id: String, success: bool) -> void:
    print("=== Crise résolue ===")
    print("Résultat: %s" % ("SUCCÈS" if success else "ÉCHEC"))
    
    if success:
        # Cinématique de victoire
        EventBus.play_victory_cutscene.emit(crisis_id)
        # Récompenses spéciales
        _distribute_crisis_rewards()
    else:
        # Cinématique d'échec
        EventBus.play_defeat_cutscene.emit(crisis_id)
        # Conséquences
        _apply_crisis_consequences()
    
    # Fermer l'UI de crise
    _hide_crisis_ui()
    
    # Statistiques finales
    _show_crisis_stats()

func _show_crisis_stats() -> void:
    var stats = CrisisManager.get_crisis_stats()
    print("Statistiques de la crise:")
    print("- Contribution totale: %d/%d" % [stats.current_contribution, stats.contribution_goal])
    
    var crisis = CrisisManager.get_active_crisis()
    if crisis:
        var top_contributors = crisis.get_top_contributors(5)
        print("- Top contributeurs:")
        for i in range(top_contributors.size()):
            var contrib = top_contributors[i]
            print("  %d. %s: %d points" % [i + 1, contrib.id, contrib.contribution])

func _show_crisis_ui() -> void:
    # Implémenter l'affichage de l'UI de crise
    pass

func _update_crisis_ui() -> void:
    # Mettre à jour l'UI avec les nouvelles infos
    pass

func _hide_crisis_ui() -> void:
    # Cacher l'UI de crise
    pass

func _distribute_crisis_rewards() -> void:
    # Récompenses basées sur la contribution
    pass

func _apply_crisis_consequences() -> void:
    # Appliquer les effets d'échec
    pass
```

---

## 7. Organisation des fichiers

### 7.1 Structure complète

```
project/
├── src/
│   ├── quests/
│   │   ├── quest_types.gd                    # Autoload - Enums et constantes
│   │   ├── quest_template.gd                 # Resource - Définition de quête
│   │   ├── quest_instance.gd                 # RefCounted - État runtime
│   │   ├── quest_manager.gd                  # Autoload - Gestionnaire principal
│   │   ├── quest_conditions.gd               # Resource - Conditions d'apparition
│   │   ├── objective_data.gd                 # Resource - Objectif de quête
│   │   ├── reward_data.gd                    # Resource - Récompense
│   │   └── quest_event.gd                    # RefCounted - Événement de quête
│   │
│   ├── quests/campaigns/
│   │   ├── quest_chain.gd                    # Resource - Chaîne de quêtes (Tier 2-3)
│   │   ├── faction_campaign.gd               # Resource - Campagne narrative (Tier 4)
│   │   ├── chapter_data.gd                   # Resource - Chapitre de campagne
│   │   ├── campaign_manager.gd               # Autoload - Gestionnaire de campagnes
│   │   └── world_impact.gd                   # Resource - Impact sur le monde
│   │
│   ├── quests/generation/
│   │   ├── quest_generator.gd                # RefCounted - Générateur procédural
│   │   ├── quest_pool.gd                     # RefCounted - Pool de templates
│   │   ├── name_generator.gd                 # RefCounted - Génération de noms
│   │   └── difficulty_scaler.gd              # RefCounted - Ajustement de difficulté
│   │
│   ├── world_events/
│   │   ├── world_crisis.gd                   # Resource - Crise mondiale (Tier 5)
│   │   ├── crisis_phase.gd                   # Resource - Phase de crise
│   │   ├── crisis_manager.gd                 # Autoload - Gestionnaire de crises
│   │   └── world_effect.gd                   # Resource - Effet sur le monde
│   │
│   ├── factions/
│   │   ├── faction.gd                        # Resource - Définition de faction
│   │   ├── faction_manager.gd                # Autoload - Gestionnaire de factions
│   │   ├── faction_relations.gd              # RefCounted - Relations entre factions
│   │   └── reputation_tracker.gd             # RefCounted - Suivi de réputation
│   │
│   └── core/
│       ├── world_game_state.gd               # Autoload - État global du monde
│       └── event_bus.gd                      # Autoload - Communication globale
│
└── data/
    ├── quests/
    │   ├── tier1/                            # Quêtes simples
    │   │   ├── hunt_wolves.tres
    │   │   ├── escort_merchant.tres
    │   │   └── defend_village.tres
    │   │
    │   ├── tier2/                            # Chaînes courtes
    │   │   ├── bandit_threat_01.tres
    │   │   └── trade_route_problems.tres
    │   │
    │   ├── tier3/                            # Chaînes moyennes
    │   │   ├── investigate_corruption.tres
    │   │   └── rescue_kidnapped.tres
    │   │
    │   └── templates/                        # Templates pour génération procédurale
    │       ├── combat_template.tres
    │       ├── exploration_template.tres
    │       └── diplomacy_template.tres
    │
    ├── campaigns/
    │   ├── faction_campaigns/                # Campagnes narratives (Tier 4)
    │   │   ├── empire_rise.tres
    │   │   ├── merchant_guild_expansion.tres
    │   │   ├── rebel_uprising.tres
    │   │   └── nomad_unity.tres
    │   │
    │   └── quest_chains/                     # Chaînes procédurales sauvegardées
    │       ├── bandit_eradication_01.tres
    │       └── trade_disputes_02.tres
    │
    ├── crises/                               # Crises mondiales (Tier 5)
    │   ├── barbarian_invasion.tres
    │   ├── plague_outbreak.tres
    │   ├── great_famine.tres
    │   └── civil_war.tres
    │
    └── factions/
        ├── empire_central.tres
        ├── merchant_guild.tres
        ├── kingdom_north.tres
        └── rebel_alliance.tres
```

### 7.2 Conventions de nommage

**Fichiers de code (.gd)** :
- `snake_case` pour tous les fichiers
- Suffixe `_manager` pour les singletons gestionnaires
- Suffixe `_data` pour les Resources de données

**Fichiers de ressources (.tres)** :
- `snake_case`
- Préfixe du type: `quest_`, `campaign_`, `crisis_`, `faction_`
- Numérotation pour les variantes: `_01`, `_02`, etc.

**IDs dans les ressources** :
- `snake_case`
- Format: `{type}_{nom}_{variant}`
- Exemples: `quest_hunt_wolves`, `campaign_empire_rise`, `crisis_barbarian_invasion_2025`

### 7.3 Dépendances entre fichiers

```
QuestManager
├── require: QuestTypes, EventBus, WorldGameState
└── use: QuestTemplate, QuestInstance, QuestConditions

CampaignManager
├── require: QuestManager, QuestTypes, EventBus, FactionManager
└── use: QuestChain, FactionCampaign, QuestGenerator

CrisisManager
├── require: QuestManager, EventBus, WorldGameState
└── use: WorldCrisis, CrisisPhase, WorldEffect

QuestGenerator
├── require: QuestTypes
└── use: QuestTemplate, QuestPool, ObjectiveData, RewardData

WorldGameState (orchestrateur principal)
├── require: EventBus
└── coordinate: QuestManager, CampaignManager, CrisisManager, FactionManager
```

---

## Résumé Final

Ce document décrit en détail l'architecture complète du système de quêtes et campagnes pour le World Strategy Roguelite. Le système est organisé en 5 tiers de complexité croissante, depuis les quêtes simples jusqu'aux crises mondiales, avec une génération procédurale sophistiquée et une intégration profonde avec les systèmes de factions et le monde de jeu.

**Points clés** :
- Architecture modulaire avec séparation claire des responsabilités
- Système de tags et conditions flexible pour le déverrouillage progressif
- Génération procédurale pour rejouabilité infinie
- Intégration profonde avec les systèmes de factions, monde, et économie
- Événements et signaux pour communication inter-systèmes
- Sauvegarde/chargement complet de l'état
- Exemples de code complets pour tous les cas d'usage

**État d'implémentation** :
- ✅ Tier 1-3 : Implémentés et testés
- ✅ Tier 4 : Implémenté (FactionCampaign, ChapterData)
- 🚧 Tier 5 : Structure complète définie, intégration en cours
- ✅ Génération procédurale : QuestGenerator fonctionnel
- ✅ Système de conditions : Complet
- ✅ Intégrations : Factions, monde, événements
