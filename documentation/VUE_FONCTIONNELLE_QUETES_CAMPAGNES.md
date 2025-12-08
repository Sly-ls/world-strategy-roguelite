# Vue Fonctionnelle - Système de Quêtes, Campagnes et Crises
## World Strategy Roguelite - Godot 4.5

---

## 📋 TABLE DES MATIÈRES

1. [Vue d'ensemble architecturale](#1-vue-densemble-architecturale)
2. [Système de Quêtes (Base)](#2-système-de-quêtes-base)
3. [Système de Campagnes Procédurales](#3-système-de-campagnes-procédurales)
4. [Système de Campagnes Narratives](#4-système-de-campagnes-narratives)
5. [Système de Crises Mondiales](#5-système-de-crises-mondiales)
6. [Intégration Factions](#6-intégration-factions)
7. [Guide d'utilisation pratique](#7-guide-dutilisation-pratique)
8. [Diagrammes et flux](#8-diagrammes-et-flux)

---

## 1. VUE D'ENSEMBLE ARCHITECTURALE

### 1.1 Hiérarchie des Systèmes

```
┌─────────────────────────────────────────────────────────┐
│                   CAMPAIGN MANAGER                       │
│           (Gestionnaire Central Hybride)                 │
│  - Gère QuestChain (procédural)                         │
│  - Gère FactionCampaign (narratif)                      │
│  - Unifie les deux systèmes                             │
└────────────────┬────────────────────────────────────────┘
                 │
     ┌───────────┴───────────┐
     │                       │
┌────▼──────┐      ┌────────▼────────┐
│ PROCEDURAL│      │   NARRATIVE     │
│ (Tier 2-3)│      │   (Tier 4)      │
│           │      │                 │
│QuestChain │      │FactionCampaign  │
└────┬──────┘      └────────┬────────┘
     │                      │
     └──────────┬───────────┘
                │
         ┌──────▼──────┐
         │ QUEST BASE  │
         │  SYSTEM     │
         │             │
         │QuestManager │
         │QuestTemplate│
         └─────────────┘
```

### 1.2 Paliers d'Implémentation

Le système est organisé en 5 paliers de complexité croissante :

| Palier | Nom | Description | Status |
|--------|-----|-------------|--------|
| **1** | Quêtes Simples | Templates basiques, 1 objectif | ✅ Implémenté |
| **2** | Chaînage Simple | Quêtes séquentielles, 2-3 étapes | ✅ Implémenté |
| **3** | Chaînage Avancé | Branches, choix, paramètres | ✅ Implémenté |
| **4** | Campagnes Faction | Arcs narratifs longs (5+ chapitres) | ✅ Implémenté |
| **5** | Crises Mondiales | Événements globaux, timer, phases | 🚧 En cours |

### 1.3 Classes Principales

```gdscript
# BASE
QuestTypes           # Enums centralisés (catégories, tiers, statuts)
QuestTemplate        # Template de quête (Palier 1)
QuestInstance        # Instance runtime d'une quête
QuestObjective       # Objectif individuel
QuestReward          # Récompense

# AVANCÉ (Palier 3)
QuestTemplateAdvanced     # Multi-objectifs + branches
QuestInstanceAdvanced     # Runtime avancé
QuestBranch              # Branche de choix

# CAMPAGNES PROCÉDURALES (Palier 2-3)
QuestChain           # Chaîne de quêtes procédurales
QuestGenerator       # Générateur procédural
QuestPool            # Pool de templates

# CAMPAGNES NARRATIVES (Palier 4)
FactionCampaign      # Campagne longue liée à faction

# CRISES (Palier 5)
WorldCrisis          # Événement mondial critique

# MANAGERS
QuestManager         # Gestionnaire de quêtes actives
CampaignManager      # Gestionnaire hybride campagnes
```

---

## 2. SYSTÈME DE QUÊTES (BASE)

### 2.1 QuestTypes - Enums Centralisés

**Fichier** : `src/quests/QuestTypes.gd`

#### Catégories de Quêtes
```gdscript
enum QuestCategory {
    LOCAL_POI,      # Quête liée à un POI spécifique
    EXPLORATION,    # Quête d'exploration
    COMBAT,         # Quête de combat
    SURVIVAL,       # Quête de survie
    DIPLOMATIC,     # Relations factions
    DELIVERY,       # Livraison
    WORLD_EVENT     # Événement mondial
}
```

#### Tiers de Quêtes
```gdscript
enum QuestTier {
    TIER_1 = 1,  # Quête simple locale
    TIER_2 = 2,  # Quête régionale
    TIER_3 = 3,  # Quête importante
    TIER_4 = 4,  # Crise majeure
    TIER_5 = 5   # Apocalypse
}
```

#### Statuts
```gdscript
enum QuestStatus {
    AVAILABLE,   # Peut être démarrée
    ACTIVE,      # En cours
    COMPLETED,   # Terminée avec succès
    FAILED,      # Échouée
    EXPIRED      # Expirée (temps écoulé)
}
```

#### Types d'Objectifs
```gdscript
enum ObjectiveType {
    CUSTOM,              # Personnalisé
    REACH_POI,           # Aller à un POI
    CLEAR_COMBAT,        # Gagner un combat
    SURVIVE_DAYS,        # Survivre X jours
    MAKE_CHOICE,         # Faire un choix
    COLLECT_RESOURCE,    # Collecter ressources
    FACTION_RELATION,    # Atteindre relation faction
    DELIVER_ITEM,        # Livrer objet
    EXPLORE_AREA,        # Explorer zone
    DEFEAT_ENEMIES       # Vaincre ennemis
}
```

#### Types de Récompenses
```gdscript
enum RewardType {
    GOLD,           # Or
    FOOD,           # Nourriture
    UNIT,           # Nouvelle unité
    ITEM,           # Objet
    FACTION_REP,    # Réputation faction
    UNLOCK_POI,     # Débloque POI
    TAG_PLAYER,     # Tag joueur (pour conditions)
    TAG_WORLD,      # Tag monde (pour conditions)
    BUFF,           # Buff temporaire
    XP              # Expérience
}
```

### 2.2 QuestTemplate - Template de Quête (Palier 1)

**Fichier** : `src/quests/QuestTemplate.gd`

#### Propriétés Principales

```gdscript
# IDENTIFICATION
@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

# CLASSIFICATION
@export var category: QuestTypes.QuestCategory
@export var tier: QuestTypes.QuestTier

# CONDITIONS D'APPARITION
@export var required_day: int = 0
@export var required_player_tags: Array[String] = []
@export var required_world_tags: Array[String] = []
@export var forbidden_player_tags: Array[String] = []
@export var min_faction_relation: Dictionary = {}

# OBJECTIF (Palier 1 : UN SEUL)
@export var objective_type: QuestTypes.ObjectiveType
@export var objective_target: String = ""
@export var objective_count: int = 1
@export_multiline var objective_description: String = ""

# RÉCOMPENSES
@export var rewards: Array[QuestReward] = []

# TAGS AJOUTÉS À LA COMPLÉTION
@export var adds_player_tags: Array[String] = []
@export var adds_world_tags: Array[String] = []

# EXPIRATION
@export var expires_in_days: int = -1  # -1 = jamais

# CHAÎNAGE
@export var completion_event_id: String = ""
@export var next_quest_id: String = ""
```

#### Méthodes Clés

```gdscript
# Vérifier si la quête peut apparaître
func can_appear() -> bool

# Obtenir description formatée de l'objectif
func get_objective_description() -> String
```

### 2.3 QuestInstance - Instance Runtime

**Fichier** : `src/quests/QuestInstance.gd`

Une `QuestInstance` est créée à partir d'un `QuestTemplate` lorsque la quête est démarrée.

```gdscript
class_name QuestInstance

var template: QuestTemplate        # Référence au template
var status: QuestTypes.QuestStatus = QuestTypes.QuestStatus.ACTIVE
var progress: int = 0              # Progression 0-100
var started_on_day: int = -1
var completed_on_day: int = -1

# Méthodes
func update_progress(value: int) -> void
func complete() -> void
func fail() -> void
```

### 2.4 QuestManager - Gestionnaire Central

**Fichier** : `src/systems/QuestManager.gd`

Le `QuestManager` est un **Singleton** (Autoload) qui gère toutes les quêtes actives.

#### Signaux
```gdscript
signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_failed(quest_id: String)
signal quest_updated(quest_id: String, progress: int)
```

#### Méthodes Principales
```gdscript
# Démarrer une quête
func start_quest(quest_id: String, context: Dictionary = {}) -> bool

# Obtenir quête active
func get_active_quest(quest_id: String) -> QuestInstance

# Compléter objectif
func complete_objective(quest_id: String, objective_index: int = 0) -> void

# Tags (pour conditions)
func add_player_tag(tag: String) -> void
func has_player_tag(tag: String) -> bool
func add_world_tag(tag: String) -> void
func has_world_tag(tag: String) -> bool
```

---

## 3. SYSTÈME DE CAMPAGNES PROCÉDURALES

### 3.1 QuestChain - Chaîne de Quêtes (Palier 2-3)

**Fichier** : `src/quests/campaigns/QuestChain.gd`

Les `QuestChain` sont des campagnes procédurales de 2 à 5 quêtes enchaînées.

#### Structure
```gdscript
class_name QuestChain extends Resource

# IDENTIFICATION
@export var id: String = ""
@export var title: String = ""
@export var description: String = ""

# CHAÎNE
@export var quest_templates: Array[String] = []  # IDs des templates
@export var linear: bool = true  # true = séquentiel, false = parallèle

# CONDITIONS
@export var required_faction_id: String = ""
@export var required_relation: int = 0
@export var required_tags: Array[String] = []

# PROGRESSION
var current_quest_index: int = 0
var completed_quests: Array[String] = []
var active: bool = false

# RÉCOMPENSES FINALES
@export var final_rewards: Array[QuestReward] = []
```

#### Méthodes
```gdscript
# Vérifier si peut démarrer
func can_start() -> bool

# Démarrer la campagne
func start() -> void

# Avancer à la quête suivante
func advance() -> void

# Compléter la campagne
func complete() -> void
```

### 3.2 QuestBranch - Branches de Choix (Palier 3)

**Fichier** : `src/quests/campaigns/QuestBranch.gd`

Permet de créer des embranchements dans les quêtes.

```gdscript
class_name QuestBranch extends Resource

@export var branch_id: String = ""
@export var title: String = ""
@export var description: String = ""

# CONDITION DE DÉCLENCHEMENT
@export var trigger_condition: Dictionary = {}
# Ex: {"choice_made": "help_villagers", "faction_relation": {"humans": 50}}

# QUÊTES DE CETTE BRANCHE
@export var quest_ids: Array[String] = []

# TAGS AJOUTÉS
@export var adds_tags: Array[String] = []
```

### 3.3 QuestGenerator - Génération Procédurale

**Fichier** : `src/quests/generation/QuestGenerator.gd`

Génère des quêtes dynamiquement basées sur le contexte actuel.

```gdscript
class_name QuestGenerator

# Générer quête depuis template
static func generate_from_template(
    template: QuestTemplate, 
    context: Dictionary
) -> QuestInstance

# Générer quête aléatoire pour un POI
static func generate_poi_quest(
    poi_type: GameEnums.CellType,
    tier: QuestTypes.QuestTier = QuestTypes.QuestTier.TIER_1
) -> QuestInstance

# Générer campagne procédurale
static func generate_campaign(
    faction_id: String,
    length: int = 3
) -> QuestChain
```

### 3.4 Flux d'Exécution - Campagne Procédurale

```
┌─────────────────┐
│ Démarrer        │
│ QuestChain      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Quest 1 Active  │
│ (via Manager)   │
└────────┬────────┘
         │ Complétée
         ▼
┌─────────────────┐
│ QuestChain      │
│ .advance()      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Quest 2 Active  │
└────────┬────────┘
         │ Complétée
         ▼
      [...]
         │
         ▼
┌─────────────────┐
│ QuestChain      │
│ .complete()     │
│                 │
│ → Rewards       │
│ → Tags          │
└─────────────────┘
```

---

## 4. SYSTÈME DE CAMPAGNES NARRATIVES

### 4.1 FactionCampaign - Campagne Narrative (Palier 4)

**Fichier** : `src/quests/campaigns/FactionCampaign.gd`

Les `FactionCampaign` sont des **arcs narratifs longs** (5+ chapitres) liés à une faction spécifique.

#### Structure Complète

```gdscript
class_name FactionCampaign extends Resource

# ========================================
# IDENTIFICATION
# ========================================
@export var id: String = ""
@export var title: String = ""  # Ex: "La Reconquête du Royaume"
@export var description: String = ""
@export var lore: String = ""  # Background narratif

@export var faction_id: String = ""  # Faction liée
@export var tier: QuestTypes.QuestTier = QuestTypes.QuestTier.TIER_4

# ========================================
# CHAÎNE DE QUÊTES
# ========================================
@export var quest_chain: Array[String] = []  # IDs ordonnés
@export var current_chapter: int = 0  # 0 = pas commencé
@export var max_chapters: int = 5

# ========================================
# CONDITIONS DE DÉPART
# ========================================
@export var required_faction_relation: int = 50
@export var required_player_tags: Array[String] = []
@export var required_world_tags: Array[String] = []
@export var required_day: int = 1

# ========================================
# ÉTATS
# ========================================
enum CampaignStatus {
    LOCKED,      # Pas disponible
    AVAILABLE,   # Peut démarrer
    IN_PROGRESS, # En cours
    COMPLETED,   # Terminée
    FAILED       # Échouée
}

var status: CampaignStatus = CampaignStatus.LOCKED
var started_on_day: int = -1
var completed_on_day: int = -1

# ========================================
# RÉCOMPENSES
# ========================================
@export var final_rewards: Array[QuestReward] = []
@export var chapter_rewards: Dictionary = {}
# Ex: { 1: [reward1, reward2], 3: [reward3], 5: [reward4] }

# ========================================
# IMPACT MONDE
# ========================================
@export var final_world_impact: Dictionary = {}
# Ex: {
#   "faction_becomes_ally": "humans",
#   "unlocks_region": "kingdom_capital",
#   "changes_world_state": "peace_established"
# }

# ========================================
# NARRATIF
# ========================================
@export var chapter_titles: Dictionary = {}
# Ex: { 1: "L'Appel à l'Aide", 2: "La Première Bataille" }

@export var chapter_descriptions: Dictionary = {}

@export var key_characters: Array[Dictionary] = []
# Ex: [
#   {"id": "king_aldric", "name": "Roi Aldric", "role": "Dirigeant"},
#   {"id": "captain_elena", "name": "Capitaine Elena", "role": "Commandante"}
# ]
```

#### Méthodes Clés

```gdscript
# Vérifier conditions
func can_start() -> bool

# Démarrer campagne
func start() -> void
    → status = IN_PROGRESS
    → started_on_day = current_day
    → current_chapter = 1
    → Démarre première quête

# Passer au chapitre suivant
func advance_chapter() -> void
    → Applique chapter_rewards
    → current_chapter++
    → Démarre quête suivante
    → Si max_chapters atteint → complete()

# Compléter campagne
func complete() -> void
    → status = COMPLETED
    → Applique final_rewards
    → Applique final_world_impact
    → Signaux

# Échouer campagne
func fail() -> void
    → status = FAILED

# Queries
func get_progress_percent() -> float
func get_chapter_title(chapter: int) -> String
func get_current_quest_id() -> String
func get_character_info(character_id: String) -> Dictionary
```

### 4.2 Exemple de Campagne Narrative

```gdscript
# data/campaigns/factions/human_kingdom_campaign.tres

id = "campaign_human_kingdom"
title = "La Reconquête du Royaume"
description = "Aidez le Royaume Humain à reprendre ses terres"
faction_id = "humans"
tier = TIER_4

quest_chain = [
    "hk_ch1_distress_call",
    "hk_ch2_first_battle",
    "hk_ch3_gather_allies",
    "hk_ch4_siege_preparation",
    "hk_ch5_final_assault"
]

max_chapters = 5

chapter_titles = {
    1: "L'Appel à l'Aide",
    2: "La Première Bataille",
    3: "Rassembler les Alliés",
    4: "Préparatifs du Siège",
    5: "L'Assaut Final"
}

required_faction_relation = 50
required_day = 10

final_rewards = [
    QuestReward(type=GOLD, amount=5000),
    QuestReward(type=FACTION_REP, target_id="humans", amount=100),
    QuestReward(type=TAG_PLAYER, target_id="hero_of_the_realm")
]

final_world_impact = {
    "faction_becomes_ally": "humans",
    "unlocks_region": "kingdom_restored",
    "changes_world_state": "kingdom_victorious"
}
```

### 4.3 Flux d'Exécution - Campagne Narrative

```
┌─────────────────────┐
│ Conditions remplies │
│ can_start() = true  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Joueur démarre via  │
│ CampaignManager     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ start()             │
│ → status = PROGRESS │
│ → chapter = 1       │
│ → Quête 1 démarrée  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Joueur complète     │
│ Quête Chapitre 1    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Signal détecté par  │
│ CampaignManager     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ advance_chapter()   │
│ → Rewards chapitre  │
│ → chapter = 2       │
│ → Quête 2 démarrée  │
└──────────┬──────────┘
           │
        [...]
           │
           ▼
┌─────────────────────┐
│ Chapitre 5 complété │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ complete()          │
│ → final_rewards     │
│ → world_impact      │
│ → Tags              │
│ → Signaux           │
└─────────────────────┘
```

---

## 5. SYSTÈME DE CRISES MONDIALES

### 5.1 WorldCrisis - Événement Global (Palier 5)

**Fichier** : `src/world_events/WorldCrisis.gd`

Les `WorldCrisis` sont des **événements majeurs** (Tier 4-5) affectant tout le monde.

#### Structure

```gdscript
class_name WorldCrisis extends QuestTemplateAdvanced

# ========================================
# TYPE DE CRISE
# ========================================
@export var crisis_type: CrisisType

enum CrisisType {
    INVASION,         # Invasion massive
    PLAGUE,           # Épidémie
    FAMINE,           # Famine
    CIVIL_WAR,        # Guerre civile
    NATURAL_DISASTER, # Catastrophe naturelle
    CORRUPTION,       # Corruption magique
    APOCALYPSE        # Fin du monde
}

@export var severity: int = 5  # 1-10

# ========================================
# TIMER CRITIQUE
# ========================================
@export var critical_timer_days: int = 10
@export var warning_days: int = 3

var timer_started: bool = false
var deadline_day: int = -1

# ========================================
# PHASES
# ========================================
@export var phases: Array[CrisisPhase] = []
var current_phase: int = 0

class CrisisPhase:
    @export var phase_number: int = 1
    @export var title: String = ""
    @export var description: String = ""
    @export var triggers_on_day: int = -1
    @export var world_effects: Dictionary = {}
    @export var new_objectives: Array[String] = []

# ========================================
# EFFETS GLOBAUX
# ========================================
@export var global_effects: Dictionary = {}
# Ex: {
#   "blocks_travel": true,
#   "increases_prices": 2.0,
#   "faction_relations_frozen": true,
#   "daily_resource_drain": {"food": 10}
# }

@export var failure_consequences: Dictionary = {}
# Ex: {
#   "world_destroyed": true,
#   "all_factions_hostile": true,
#   "game_over": true
# }

# ========================================
# PARTICIPATION MONDIALE
# ========================================
@export var contribution_tracking: bool = true
var global_contributions: Dictionary = {}
@export var contribution_goals: Dictionary = {}
# Ex: {"gold_donated": 10000, "enemies_defeated": 500}

# ========================================
# FACTIONS AFFECTÉES
# ========================================
@export var affected_factions: Array[String] = []  # Vide = toutes
```

#### Méthodes Principales

```gdscript
# Démarrer la crise
func start_crisis() -> void
    → timer_started = true
    → deadline_day calculé
    → Applique global_effects
    → Démarre phase 1

# Avancer les phases
func update_phase(current_day: int) -> void
    → Vérifie triggers de phase
    → Change phase si conditions remplies

# Contribuer à l'effort mondial
func contribute(contribution_type: String, amount: int) -> void
    → Met à jour global_contributions
    → Vérifie si goals atteints

# Résoudre la crise
func resolve_crisis(success: bool) -> void
    → Si success : récompenses
    → Si échec : failure_consequences

# Vérifier deadline
func check_deadline(current_day: int) -> bool
    → Retourne true si deadline dépassée
```

### 5.2 CrisisManager - Gestionnaire de Crises

**Fichier** : `src/world_events/CrisisManager.gd`

```gdscript
extends Node

signal crisis_started(crisis_id: String)
signal crisis_phase_changed(crisis_id: String, phase: int)
signal crisis_deadline_warning(crisis_id: String, days_left: int)
signal crisis_resolved(crisis_id: String, success: bool)

var active_crises: Dictionary = {}  # crisis_id -> WorldCrisis
var crisis_templates: Dictionary = {}  # Chargées au démarrage

func trigger_crisis(crisis_id: String) -> void
func get_active_crisis(crisis_id: String) -> WorldCrisis
func contribute_to_crisis(crisis_id: String, type: String, amount: int) -> void
func _process_active_crises() -> void  # Appelé chaque jour
```

### 5.3 Exemple de Crise

```gdscript
# data/crises/orc_invasion.tres

id = "crisis_orc_invasion"
title = "L'Invasion Orque"
description = "Une horde massive d'orcs envahit les terres civilisées"
tier = TIER_4
crisis_type = INVASION
severity = 8

critical_timer_days = 15
warning_days = 5

phases = [
    CrisisPhase {
        phase_number = 1,
        title = "Premières Attaques",
        triggers_on_day = 0,
        world_effects = {
            "spawns_enemies": {"type": "orc_scouts", "count": 3}
        }
    },
    CrisisPhase {
        phase_number = 2,
        title = "L'Invasion S'intensifie",
        triggers_on_day = 5,
        world_effects = {
            "spawns_enemies": {"type": "orc_warriors", "count": 10},
            "blocks_travel": ["north_region"]
        }
    },
    CrisisPhase {
        phase_number = 3,
        title = "Siège Final",
        triggers_on_day = 12,
        world_effects = {
            "spawns_boss": "orc_warchief"
        }
    }
]

global_effects = {
    "increases_prices": 1.5,
    "daily_resource_drain": {"food": 5}
}

contribution_goals = {
    "enemies_defeated": 50,
    "gold_donated": 2000
}

failure_consequences = {
    "all_factions_hostile": true,
    "region_lost": "northern_plains"
}
```

---

## 6. INTÉGRATION FACTIONS

### 6.1 FactionManager - Gestion des Relations

**Fichier** : `src/factions/FactionManager.gd`

```gdscript
extends Node

# Relations faction (-100 à +100)
var faction_relations: Dictionary = {}  # faction_id -> int

signal relation_changed(faction_id: String, old_value: int, new_value: int)
signal faction_became_hostile(faction_id: String)
signal faction_became_ally(faction_id: String)

func adjust_relation(faction_id: String, amount: int) -> void
func get_relation(faction_id: String) -> int
func is_hostile(faction_id: String) -> bool  # < 0
func is_neutral(faction_id: String) -> bool  # 0-49
func is_friendly(faction_id: String) -> bool  # 50-79
func is_ally(faction_id: String) -> bool     # 80+
```

### 6.2 Faction - Classe de Faction

**Fichier** : `src/factions/Faction.gd`

```gdscript
class_name Faction extends Resource

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var color: Color = Color.WHITE

# Traits de personnalité (pour génération quêtes)
@export var traits: Array[String] = []
# Ex: ["militaristic", "trading", "isolationist", "expansionist"]

# Campagnes associées
var campaign_ids: Array[String] = []

# Relations initiales avec autres factions
@export var initial_relations: Dictionary = {}
# Ex: {"elves": 30, "orcs": -50}
```

### 6.3 Lien Factions ↔ Quêtes

#### Comment une Faction Influence les Quêtes

1. **Conditions d'Apparition**
```gdscript
# Dans QuestTemplate
@export var min_faction_relation: Dictionary = {}
# Ex: {"humans": 50}  → Nécessite 50+ de relation avec humains
```

2. **Récompenses de Réputation**
```gdscript
# Dans QuestReward
QuestReward(
    type = QuestTypes.RewardType.FACTION_REP,
    target_id = "humans",
    amount = 20
)
```

3. **Campagnes Dédiées**
```gdscript
# FactionCampaign
@export var faction_id: String = "humans"
@export var required_faction_relation: int = 50
```

4. **Événements Faction**
```gdscript
# Génération dynamique basée sur faction
QuestGenerator.generate_faction_quest("humans")
    → Utilise traits de la faction
    → Crée quête alignée avec personnalité
```

---

## 7. GUIDE D'UTILISATION PRATIQUE

### 7.1 Créer une Quête Simple (Palier 1)

**Étape 1 : Créer le Template**

```gdscript
# Dans Godot Editor : Créer Resource → QuestTemplate
# Sauvegarder dans data/quests/town_delivery.tres

extends QuestTemplate

# Identification
id = "quest_town_delivery_01"
title = "Livraison Urgente"
description = "Apportez le colis à la ville voisine"

# Classification
category = QuestTypes.QuestCategory.DELIVERY
tier = QuestTypes.QuestTier.TIER_1

# Conditions
required_day = 1  # Disponible dès le début

# Objectif unique
objective_type = QuestTypes.ObjectiveType.DELIVER_ITEM
objective_target = "town_b"  # ID du POI destination
objective_count = 1
objective_description = "Livrer le colis à Ville B"

# Récompenses
rewards = [
    QuestReward(type=QuestTypes.RewardType.GOLD, amount=100),
    QuestReward(type=QuestTypes.RewardType.FOOD, amount=50)
]

# Tags ajoutés
adds_player_tags = ["completed_first_delivery"]

# Expiration
expires_in_days = 5
```

**Étape 2 : Charger dans le Jeu**

```gdscript
# Dans QuestManager ou système de chargement
var template := load("res://data/quests/town_delivery.tres")
QuestManager.register_template(template)
```

**Étape 3 : Déclencher la Quête**

```gdscript
# Dans code de gameplay (ex: interaction POI)
if event_type == "package_received":
    QuestManager.start_quest("quest_town_delivery_01")
```

**Étape 4 : Suivre la Progression**

```gdscript
# Quand joueur atteint destination
func _on_player_reached_poi(poi_id: String):
    if poi_id == "town_b":
        QuestManager.complete_objective("quest_town_delivery_01", 0)
```

### 7.2 Créer une Campagne Procédurale (Palier 2-3)

**Étape 1 : Créer les Templates de Quêtes**

```gdscript
# quest_faction_intro.tres
id = "fq_intro"
title = "Rencontre avec les Humains"
# ...

# quest_faction_trust.tres
id = "fq_trust"
title = "Gagner leur Confiance"
# ...

# quest_faction_alliance.tres
id = "fq_alliance"
title = "Forger l'Alliance"
# ...
```

**Étape 2 : Créer la QuestChain**

```gdscript
# data/campaigns/procedural/human_alliance_chain.tres

extends QuestChain

id = "chain_human_alliance"
title = "Alliance avec le Royaume Humain"
description = "Série de quêtes pour s'allier aux humains"

# Quêtes de la chaîne
quest_templates = [
    "fq_intro",
    "fq_trust",
    "fq_alliance"
]

linear = true  # Séquentiel

# Conditions
required_faction_id = "humans"
required_relation = 20  # Minimum 20 de relation

# Récompenses finales
final_rewards = [
    QuestReward(type=GOLD, amount=1000),
    QuestReward(
        type=FACTION_REP,
        target_id="humans",
        amount=50
    ),
    QuestReward(
        type=TAG_PLAYER,
        target_id="allied_with_humans"
    )
]
```

**Étape 3 : Démarrer la Campagne**

```gdscript
# Via CampaignManager
func _on_player_wants_alliance():
    if CampaignManager.can_start_campaign("chain_human_alliance"):
        CampaignManager.start_campaign("chain_human_alliance")
    else:
        show_message("Conditions non remplies")
```

**Étape 4 : Gestion Automatique**

```gdscript
# Le CampaignManager écoute automatiquement
# les signaux de QuestManager et fait avancer
# la chaîne quand une quête est complétée

# Pas de code supplémentaire nécessaire!
```

### 7.3 Créer une Campagne Narrative (Palier 4)

**Étape 1 : Planifier l'Arc Narratif**

```
Campagne : "La Chute de la Citadelle Noire"
Faction : Ordre des Paladins
Durée : 5 chapitres

Ch1 : Découverte de la menace
Ch2 : Rassemblement des forces
Ch3 : Première offensive
Ch4 : La trahison
Ch5 : L'assaut final
```

**Étape 2 : Créer les Quêtes de Chapitre**

```gdscript
# Créer 5 QuestTemplateAdvanced séparés
# cn_ch1.tres, cn_ch2.tres, ..., cn_ch5.tres
```

**Étape 3 : Créer la FactionCampaign**

```gdscript
# data/campaigns/factions/citadel_campaign.tres

extends FactionCampaign

id = "campaign_dark_citadel"
title = "La Chute de la Citadelle Noire"
description = "Aidez les Paladins à détruire la Citadelle"
lore = """Il y a mille ans, la Citadelle Noire fut scellée.
Aujourd'hui, elle se réveille..."""

faction_id = "paladins"
tier = TIER_4

# Chaîne de quêtes
quest_chain = [
    "cn_ch1", "cn_ch2", "cn_ch3", "cn_ch4", "cn_ch5"
]

max_chapters = 5

# Conditions
required_faction_relation = 60
required_day = 20
required_player_tags = ["discovered_citadel"]

# Titres de chapitres
chapter_titles = {
    1: "Découverte de la Menace",
    2: "Rassemblement des Forces",
    3: "Première Offensive",
    4: "La Trahison",
    5: "L'Assaut Final"
}

# Récompenses par chapitre
chapter_rewards = {
    1: [QuestReward(type=GOLD, amount=500)],
    3: [QuestReward(type=UNIT, target_id="paladin_knight")],
    5: []  # Finales uniquement
}

# Récompenses finales
final_rewards = [
    QuestReward(type=GOLD, amount=5000),
    QuestReward(type=FACTION_REP, target_id="paladins", amount=100),
    QuestReward(type=TAG_PLAYER, target_id="hero_of_light"),
    QuestReward(type=UNLOCK_POI, target_id="citadel_restored")
]

# Impact monde
final_world_impact = {
    "faction_becomes_ally": "paladins",
    "unlocks_region": "holy_lands",
    "changes_world_state": "citadel_destroyed"
}

# Personnages
key_characters = [
    {
        "id": "commander_adrian",
        "name": "Commandant Adrian",
        "role": "Chef des Paladins"
    },
    {
        "id": "sage_elena",
        "name": "Sage Elena",
        "role": "Conseillère"
    }
]
```

**Étape 4 : Déclencher la Campagne**

```gdscript
# Dans UI ou événement
func _on_start_campaign_button_pressed():
    CampaignManager.start_campaign("campaign_dark_citadel")
```

**Étape 5 : Suivre la Progression**

```gdscript
# UI de suivi
func _update_campaign_ui():
    var campaign := CampaignManager.get_active_faction_campaign("campaign_dark_citadel")
    
    if campaign:
        label_title.text = campaign.title
        label_chapter.text = "Chapitre %d/%d" % [
            campaign.current_chapter,
            campaign.max_chapters
        ]
        progress_bar.value = campaign.get_progress_percent()
        
        var chapter_title := campaign.get_chapter_title(campaign.current_chapter)
        label_current_chapter.text = chapter_title
```

### 7.4 Déclencher une Crise Mondiale (Palier 5)

**Étape 1 : Créer la Crise**

```gdscript
# data/crises/demon_invasion.tres

extends WorldCrisis

id = "crisis_demon_invasion"
title = "L'Invasion Démoniaque"
description = "Des démons surgissent des profondeurs"
tier = TIER_5
crisis_type = INVASION
severity = 10

critical_timer_days = 20
warning_days = 5

# Phases
phases = [
    CrisisPhase {
        phase_number = 1,
        title = "Premières Brèches",
        triggers_on_day = 0,
        world_effects = {
            "spawns_enemies": {"demon_scouts": 5}
        },
        new_objectives = ["close_demon_portal_1"]
    },
    CrisisPhase {
        phase_number = 2,
        title = "Les Légions Arrivent",
        triggers_on_day = 7,
        world_effects = {
            "spawns_enemies": {"demon_warriors": 20},
            "blocks_travel": true
        },
        new_objectives = ["defend_major_city"]
    },
    CrisisPhase {
        phase_number = 3,
        title = "Le Seigneur Démon",
        triggers_on_day = 15,
        world_effects = {
            "spawns_boss": "demon_lord"
        },
        new_objectives = ["defeat_demon_lord"]
    }
]

# Effets globaux
global_effects = {
    "blocks_travel": false,  # Appliqué en Phase 2
    "increases_prices": 3.0,
    "faction_relations_frozen": true,
    "daily_resource_drain": {"food": 20, "gold": 50}
}

# Objectifs mondiaux
contribution_goals = {
    "enemies_defeated": 200,
    "gold_donated": 10000,
    "portals_closed": 10
}

# Conséquences d'échec
failure_consequences = {
    "world_destroyed": true,
    "game_over": true,
    "ending_text": "Le monde a succombé aux démons..."
}

# Toutes les factions affectées
affected_factions = []  # Vide = toutes
```

**Étape 2 : Déclencher la Crise**

```gdscript
# Déclenché par événement narratif ou jour spécifique
func _on_day_changed(day: int):
    if day == 50 and not CrisisManager.has_crisis("crisis_demon_invasion"):
        CrisisManager.trigger_crisis("crisis_demon_invasion")
```

**Étape 3 : Contribuer**

```gdscript
# Quand joueur accomplit actions
func _on_demon_defeated():
    CrisisManager.contribute_to_crisis("crisis_demon_invasion", "enemies_defeated", 1)

func _on_gold_donated(amount: int):
    CrisisManager.contribute_to_crisis("crisis_demon_invasion", "gold_donated", amount)
```

**Étape 4 : UI de Suivi Global**

```gdscript
# UI Crise
func _update_crisis_ui():
    var crisis := CrisisManager.get_active_crisis("crisis_demon_invasion")
    
    if crisis:
        label_title.text = crisis.title
        label_phase.text = "Phase %d/3" % crisis.current_phase
        
        var days_left := crisis.deadline_day - WorldState.current_day
        label_deadline.text = "Temps restant : %d jours" % days_left
        
        # Contributions
        for goal_type in crisis.contribution_goals:
            var current := crisis.global_contributions.get(goal_type, 0)
            var target := crisis.contribution_goals[goal_type]
            
            progress_bars[goal_type].value = (float(current) / float(target)) * 100.0
```

### 7.5 Intégrer Tout le Système

#### Dans WorldGameState ou Main

```gdscript
# src/WorldGameState.gd

extends Node

func _ready():
    # Initialiser tous les managers
    QuestManager._ready()
    CampaignManager._ready()
    CrisisManager._ready()
    FactionManager._ready()
    
    # Connecter signaux inter-systèmes
    _connect_cross_system_signals()

func _connect_cross_system_signals():
    # Quête complétée → Vérifier campagnes
    QuestManager.quest_completed.connect(_on_quest_completed)
    
    # Relation faction changée → Vérifier campagnes
    FactionManager.relation_changed.connect(_on_faction_relation_changed)

func _on_quest_completed(quest_id: String):
    # Vérifier campagnes procédurales
    CampaignManager._on_quest_completed(quest_id)
    
    # Vérifier campagnes narratives
    CampaignManager._check_faction_campaign_progress(quest_id)

func _on_faction_relation_changed(faction_id: String, old_rel: int, new_rel: int):
    # Débloquer nouvelles campagnes si seuils atteints
    if new_rel >= 50 and old_rel < 50:
        CampaignManager.check_available_campaigns()
```

---

## 8. DIAGRAMMES ET FLUX

### 8.1 Architecture Complète

```
┌─────────────────────────────────────────────────────────────┐
│                      WORLD GAME STATE                        │
│                   (Orchestrateur Principal)                  │
└────────┬───────────────────────────┬────────────────┬────────┘
         │                           │                │
         │                           │                │
┌────────▼────────┐   ┌──────────────▼─────┐   ┌───▼─────────┐
│  QUEST MANAGER  │   │ CAMPAIGN MANAGER   │   │  FACTION    │
│                 │   │                    │   │  MANAGER    │
│ - Active quests │   │ - QuestChains      │   │             │
│ - Tags          │   │ - FactionCampaigns │   │ - Relations │
│ - Objectives    │   │ - Hybrid system    │   │ - States    │
└────────┬────────┘   └──────────┬─────────┘   └───┬─────────┘
         │                       │                  │
         └───────┬───────────────┴──────────────────┘
                 │
         ┌───────▼──────────┐
         │ CRISIS MANAGER   │
         │                  │
         │ - WorldCrisis    │
         │ - Phases         │
         │ - Timers         │
         │ - Contributions  │
         └──────────────────┘
```

### 8.2 Flux de Décision - Démarrage de Quête/Campagne

```
User triggers event
         │
         ▼
┌─────────────────┐
│ What to start?  │
└────────┬────────┘
         │
    ┌────┴─────┐
    │          │
    ▼          ▼
┌───────┐  ┌─────────┐
│ Quest │  │Campaign │
└───┬───┘  └────┬────┘
    │           │
    │      ┌────┴────┐
    │      │         │
    │      ▼         ▼
    │ ┌────────┐ ┌──────────┐
    │ │QuestCh.│ │FactionCa.│
    │ └────────┘ └──────────┘
    │
    └─────────────────┐
                      │
                      ▼
          ┌───────────────────┐
          │ Check conditions  │
          │                   │
          │ - Day             │
          │ - Tags            │
          │ - Relations       │
          │ - ...             │
          └──────┬────────────┘
                 │
            ┌────┴────┐
            │         │
        ✅ YES     ❌ NO
            │         │
            ▼         ▼
        [START]   [REFUSE]
```

### 8.3 Cycle de Vie d'une Campagne Narrative

```
┌──────────────┐
│   LOCKED     │  Conditions non remplies
└──────┬───────┘
       │ Conditions OK
       ▼
┌──────────────┐
│  AVAILABLE   │  Visible par joueur, peut démarrer
└──────┬───────┘
       │ Joueur démarre
       ▼
┌──────────────┐
│ IN_PROGRESS  │ ────────┐
│              │         │
│ Chapter 1    │         │
└──────┬───────┘         │
       │ Quest complétée │
       ▼                 │ Loop
┌──────────────┐         │ 2-5
│ Chapter 2    │         │ fois
└──────┬───────┘         │
       │                 │
    [...]               │
       │                 │
       ▼                 │
┌──────────────┐         │
│ Chapter N    │ ────────┘
└──────┬───────┘
       │ Dernière quest complétée
       ▼
┌──────────────┐
│  COMPLETED   │  Rewards + World Impact appliqués
└──────────────┘
```

### 8.4 Timeline d'une Crise

```
Jour 0             Jour 5              Jour 15             Jour 20
  │                  │                   │                   │
  │ START            │ WARNING           │ CRITICAL          │ DEADLINE
  │                  │                   │                   │
  ▼                  ▼                   ▼                   ▼
┌─────┐          ┌─────┐            ┌─────┐             ┌──────┐
│Phase│          │Phase│            │Phase│             │ FAIL │
│  1  │──────────│  2  │────────────│  3  │─────────────│  or  │
│     │          │     │            │     │             │WIN   │
└─────┘          └─────┘            └─────┘             └──────┘
   │                │                  │                    │
   │                │                  │                    │
Effects:       Effects:           Effects:             Resolve:
- Spawn        - More enemies     - Boss              - Success
- Alert        - Travel block     - Final obj.        - Failure
```

### 8.5 Relations entre Entités

```
                     QUEST TEMPLATE
                           │
                           │ creates
                           ▼
                     QUEST INSTANCE
                           │
                    ┌──────┴──────┐
                    │             │
                tracked by    part of
                    │             │
                    ▼             ▼
              QUEST MANAGER   QUEST CHAIN
                    │             │
                    │          part of
                    │             │
                    │             ▼
                    │      CAMPAIGN MANAGER
                    │             │
                    └──────┬──────┘
                           │
                        uses
                           │
                           ▼
                    FACTION MANAGER
```

---

## 📝 RÉSUMÉ - COMMENT UTILISER CE SYSTÈME

### Pour Créer du Contenu de Quête

1. **Quête Simple** → Créer `QuestTemplate` (.tres)
2. **Chaîne de Quêtes** → Créer `QuestChain` avec IDs de templates
3. **Campagne Narrative** → Créer `FactionCampaign` avec chaîne de quêtes avancées
4. **Crise Mondiale** → Créer `WorldCrisis` avec phases et timers

### Pour Intégrer dans le Jeu

1. **Charger** les resources au démarrage (dans Managers)
2. **Déclencher** via événements gameplay (`start_quest`, `start_campaign`, `trigger_crisis`)
3. **Suivre** via signaux (`quest_completed`, `campaign_chapter_completed`, etc.)
4. **UI** se connecte aux signaux et queries les Managers

### Points Clés d'Extension

- **Ajouter types d'objectifs** : Modifier `QuestTypes.ObjectiveType`
- **Ajouter types de récompenses** : Modifier `QuestTypes.RewardType`
- **Personnaliser génération** : Modifier `QuestGenerator`
- **Ajouter effets de crise** : Modifier `WorldCrisis._apply_phase_effects()`

### Fichiers à Éditer pour Ajouter du Contenu

- **Nouvelle quête simple** : `data/quests/mon_template.tres`
- **Nouvelle campagne procédurale** : `data/campaigns/procedural/ma_chain.tres`
- **Nouvelle campagne narrative** : `data/campaigns/factions/ma_campaign.tres`
- **Nouvelle crise** : `data/crises/ma_crise.tres`

---

## 🎯 PROCHAINES ÉTAPES RECOMMANDÉES

1. **Créer quelques templates de quêtes** pour tester le système
2. **Créer une petite campagne procédurale** (3 quêtes) pour une faction
3. **Implémenter UI de suivi** pour afficher quêtes actives
4. **Tester le cycle complet** : démarrer → progresser → compléter
5. **Ajouter une campagne narrative** pour faction favorite
6. **Implémenter une crise** simple pour tester le système de timer

---

**📂 Structure de Fichiers Complète**

```
world-strategy-roguelite/
├── src/
│   ├── quests/
│   │   ├── QuestTypes.gd              # ✅ Enums
│   │   ├── QuestTemplate.gd           # ✅ Palier 1
│   │   ├── QuestInstance.gd           # ✅ Runtime
│   │   ├── QuestObjective.gd          # ✅ Objectifs
│   │   ├── QuestReward.gd             # ✅ Récompenses
│   │   ├── QuestTemplateAdvanced.gd   # ✅ Palier 3
│   │   ├── QuestInstanceAdvanced.gd   # ✅ Runtime avancé
│   │   ├── campaigns/
│   │   │   ├── QuestChain.gd          # ✅ Palier 2-3
│   │   │   ├── QuestBranch.gd         # ✅ Branches
│   │   │   ├── FactionCampaign.gd     # ✅ Palier 4
│   │   │   └── CampaignManager.gd     # ✅ Hybride
│   │   └── generation/
│   │       ├── QuestGenerator.gd      # ✅ Procédural
│   │       ├── QuestPool.gd           # ✅ Pool
│   │       └── QuestConditions.gd     # ✅ Conditions
│   ├── world_events/
│   │   ├── WorldCrisis.gd             # 🚧 Palier 5
│   │   ├── CrisisManager.gd           # 🚧 Gestionnaire
│   │   └── NarrativeGenerator.gd      # 🚧 Narratif
│   ├── factions/
│   │   ├── Faction.gd                 # ✅ Faction
│   │   ├── FactionManager.gd          # ✅ Relations
│   │   └── ResourceManager.gd         # ✅ Ressources
│   └── systems/
│       ├── QuestManager.gd            # ✅ Singleton
│       └── EventBus.gd                # ✅ Signaux
├── data/
│   ├── quests/               # Templates de quêtes
│   ├── campaigns/
│   │   ├── procedural/       # QuestChain
│   │   └── factions/         # FactionCampaign
│   └── crises/               # WorldCrisis
└── game_design_doc/          # Documentation
```

**✅ = Implémenté | 🚧 = En cours**

---

*Ce document fournit une vue complète et fonctionnelle du système de quêtes, campagnes et crises. Utilisez-le comme référence pour comprendre l'architecture et créer du nouveau contenu.*
