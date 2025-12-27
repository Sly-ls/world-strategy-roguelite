Voici **deux livrables clairs et propres** :

1. **Un diagramme global du système de quêtes & campagnes**
2. **Un diagramme complet d’un exemple de campagne**, construit selon ta vision

Le tout en **Markdown prêt à coller dans ton Git**.

---

# 📘 Diagramme global — Système de Quêtes & Campagnes

```md
# Diagramme global du système de quêtes et campagnes

                           ┌────────────────────────────┐
                           │        WORLD STATE          │
                           │  - factions                 │
                           │  - POI                      │
                           │  - territoire               │
                           │  - joueur                   │
                           │  - quêtes actives/finies    │
                           └──────────────┬──────────────┘
                                          │
                                          ▼
                     ┌────────────────────────────────────────┐
                     │          QUEST SYSTEM CORE             │
                     │────────────────────────────────────────│
                     │ * QuestDefinitions (JSON/.tres)        │
                     │ * QuestInstances                       │
                     │ * QuestEngine                          │
                     │     - sélection des quêtes             │
                     │     - résolutions & transitions        │
                     │     - callbacks dans le WorldState     │
                     └──────────────┬─────────────────────────┘
                                    │
               ┌────────────────────┼────────────────────┐
               ▼                    ▼                    ▼
     ┌─────────────────┐  ┌─────────────────┐   ┌──────────────────┐
     │  WORLD EVENTS    │  │ CAMPAIGN ENGINE │   │  QUEST FACTORY   │
     │ (POI, combats…)  │  │  (enchaînement) │   │  génère les      │
     │ déclenchent      │  │  structure un   │   │  étapes selon    │
     │ des quêtes       │  │  “arc narratif” │   │  profil du monde │
     └───────┬──────────┘  └─────────┬──────┘   └──────────┬───────┘
             │                       │                     │
             ▼                       ▼                     ▼
   ┌────────────────┐    ┌─────────────────────┐   ┌──────────────────┐
   │ EventHandlers   │    │ CampaignBlueprints  │   │ DynamicGenerators │
   │ actions locales │    │ (templates narratifs│   │ (artefacts,      │
   │ combat/diplom.  │    │       modulaires)   │   │   boss, factions) │
   └───────┬─────────┘    └──────────┬──────────┘   └──────────┬──────┘
           │                          │                         │
           ▼                          ▼                         ▼
   ┌──────────────────┐     ┌─────────────────┐       ┌────────────────────┐
   │   WORLD CHANGES   │     │  NEW QUESTS     │       │ GENERATED CONTENT   │
   │ (POI modifiés,    │     │ (suite logique) │       │ (donjons, ruines,   │
   │ factions buffées, │     │                 │       │ artefacts, routes…) │
   │ nouveaux lieux…)  │     └─────────────────┘       └────────────────────┘


```

---

# 📙 Exemple complet de campagne — Diagramme détaillé

**Exemple : "La montée du pouvoir divin"**
(avec 3 artefacts, un esprit corrompu, et 4 embranchements majeurs)

```md
# Campagne Exemple : "La Montée du Pouvoir Divin"

                     ┌──────────────────────────────────┐
                     │       CAMPAGNE — NIVEAU 1        │
                     │  Présentation de la menace divine│
                     └───────────────────┬──────────────┘
                                         │
                                         ▼
                          ┌───────────────────────────┐
                          │   QUÊTE 1 : ARTEFACT N°1  │
                          │ - Localiser un artefact   │
                          │ - Ruines = 3 combats + 1 élite + boss
                          └─────────────┬─────────────┘
                                        │
                                        ▼
                          ┌───────────────────────────┐
                          │   QUÊTE 2 : ARTEFACT N°2  │
                          │ - Même structure           │
                          └─────────────┬─────────────┘
                                        │
                                        ▼
                          ┌───────────────────────────┐
                          │   QUÊTE 3 : ESPRIT CORROMPU│
                          │ - Option combat / apaiser │
                          └─────────────┬─────────────┘
                                        │
                          ┌─────────────┼───────────────────────────┐
                          ▼             ▼                           ▼
        ┌────────────────────────┐  ┌─────────────────────────┐  ┌────────────────────────────┐
        │ CHOIX A — "Rendre tout"│  │ CHOIX B — "Garder &      │  │ CHOIX C — "Aider esprit"    │
        │ Alliance faction divine│  │ devenir faction mineure" │  │ L’esprit devient faction    │
        └───────────┬────────────┘  └───────────────┬────────┘  └─────────────┬──────────────┘
                    │                               │                       │
                    ▼                               ▼                       ▼

# NIVEAU 2

A1 — Faction divine <alliée> demande  
   → "Purifier 3 POI", "Détruire une faction hostile"

B1 — Le joueur devient faction mineure  
   → "Fonder une ville", "Attirer colons", "Repousser attaques"

C1 — Nouvelle faction "Esprit Reconstitué"  
   → "Escorter l’esprit", "Éveiller le Nexus", "Bâtir son sanctuaire"

# NIVEAU 3
    A2, B2, C2 : tous mènent à une orientation stratégique forte
    (ex : Conquête, Diplomatie, Ascension divine, Effondrement d’un empire)

# NIVEAU 4
    Les grandes forces du monde réagissent :
    - Invasions
    - Famine
    - Guerres de factions
    - Apparition de nouveaux POI divins/corrompus

# NIVEAU 5 — CLIMAX
    Battle royale narratif :
    - Le joueur a façonné le monde
    - Chaque choix revient sous forme d’épreuve finale
    - Plusieurs fins possibles
```

---

# 📌 Explication et Utilisation (résumé clair)

### 🗺 **Ce que représente le diagramme**

Tu vois ici :

* Les **structures de données** (QuestDefinition, WorldState…)
* Les **mécanismes du moteur de quête**
* Les **éléments générés proceduralement**
* Les **transitions entre quêtes → campagnes → arcs narratifs**

Le système est **modulaire**, donc chaque bloc peut être modifié sans casser le reste.

---

### 🧩 Comment ça s’utilisera dans GODOT ?

* **QuestDefinition** → `.json` ou `.tres` dans `assets/quests/`
* **QuestHandlers** → scripts qui réalisent les effets
* **QuestEngine** → gère activation, fin, embranchement
* **CampaignBlueprint** → profils narratifs (faction divine, empire déchu…)
* **WorldState** → stocke les choix du joueur
* **EventSystem** → relie un POI au système de quêtes

---

### ✨ Conclusion

Tu as maintenant :

✔ **Un diagramme global propre**
✔ **Un exemple complet de campagne avec tous les embranchements**
✔ **Une vision cohérente du système**
✔ **Un document 100% prêt à mettre dans ton Git**

Si tu veux :
➡️ Je peux te générer la **version ZIP**,
➡️ Le **schema UML** en image,
➡️ Ou t’aider à coder l’implémentation Godot.

On continue ?

Bonne question, et franchement c’est *le* point clé : sans bien placer **FactionCampaign**, ton système risque de rester une collection de quêtes cool mais sans “grands arcs” de factions.

Je vais te répondre en trois niveaux :

1. **Où FactionCampaign se place dans le diagramme global**
2. **Quel rôle précis il joue entre QuestManager, WorldState et les POI**
3. **Comment ça se traduit concrètement (données + runtime + flux d’événements)**

---

## 1. Où se place `FactionCampaign` dans ton schéma

Dans le diagramme global que je t’ai donné, tu as cette zone :

```text
                     ┌─────────────────┐
                     │ CAMPAIGN ENGINE │
                     │  (enchaînement) │
                     └─────────┬───────┘
                               │
                               ▼
               ┌────────────────────────────────┐
               │        CampaignBlueprints      │
               │ (templates narratifs modulaires│
               └────────────────────────────────┘
```

**`FactionCampaign` se trouve exactement là :**
C’est un **type particulier de CampaignBlueprint**, spécialisé pour **une faction donnée**.

* `CampaignBlueprint` = concept général de campagne (arc narratif, suite de quêtes, structure).
* `FactionCampaign` = *CampaignBlueprint + un `faction_id` + des règles spécifiques à cette faction*.

Donc, structure logique :

```text
CampaignManager
    ├── CampaignBlueprint (abstrait / générique)
    │       ├── FactionCampaign (lié à une faction précise)
    │       ├── WorldCrisisCampaign (lié à une crise mondiale)
    │       └── Autre type de campagne si besoin
    └── CampaignInstance (état runtime de chaque campagne active)
```

---

## 2. Rôle précis de `FactionCampaign` dans l’écosystème

### 2.1. Ce que fait `QuestManager`

* Gère **les quêtes individuelles** :

  * crée les `QuestInstance` à partir de `QuestTemplate`,
  * suit leur progression,
  * émet des signaux `quest_started`, `quest_completed`, `quest_failed`.

👉 Il ne raconte pas “une histoire longue”, il gère des **briques**.

### 2.2. Ce que fait `CampaignManager`

* Gère **les arcs** (séquences) :

  * sait qu’une campagne “Faction X – Montée en puissance” a 5 chapitres,
  * sait quand passer du chapitre 1 au 2,
  * demande au QuestManager de lancer **la bonne quête** au bon moment.

👉 Il orchestre, mais il ne sait pas *quelles* quêtes appartient à qui.

### 2.3. Ce que fait `FactionCampaign`

`FactionCampaign` est **le contenu et les règles** d’une campagne dont le “héros” est une faction :

* **qui** : `faction_id = "humans_kingdom"`, `"orc_horde"`, `"elves_forest"`, etc.
* **quelles quêtes** : liste ou graphe de `QuestTemplate`/`QuestChain` associées à cette faction.
* **conditions de déclenchement** :

  * niveau de puissance de la faction,
  * relation avec le joueur,
  * contrôle de certaines régions / POI,
  * tags monde (`"war_in_plains"`, `"spirit_freed"`, etc.).
* **effets de fin** :

  * la faction devient hégémonique,
  * elle est détruite / absorbée,
  * elle change de nature (magie → techno, etc.).

👉 En gros :
**`FactionCampaign` = “arc scénaristique de la faction X, décrit de manière déclarative”**.

---

## 3. Concrètement : comment ça s’insère (data + runtime + flux)

### 3.1. Les Resources : côté données

Tu peux avoir quelque chose comme :

```gdscript
# res://scripts/quests/FactionCampaign.gd
extends Resource
class_name FactionCampaign

@export var id: String = ""             # "campaign_humans_divine_rise"
@export var faction_id: String = ""     # "humans_kingdom"
@export var tier: int = 4               # niveau global de la campagne

# Conditions pour que la campagne démarre
@export var start_conditions: QuestConditionsData
# (tags monde, relations, régions contrôlées, etc.)

# Liste ordonnée ou graphe d'étapes de campagne
@export var stages: Array[CampaignStageData]

# Impact final sur le monde si la campagne se termine
@export var final_world_impact: WorldImpact
```

Et un `CampaignStageData` par exemple :

```gdscript
extends Resource
class_name CampaignStageData

@export var id: String = ""                    # "humans_stage_1_rebuild"
@export var quest_template_ids: Array[String]  # ["quest_humans_rebuild_city", ...]
@export var required_world_tags: Array[String] = []
@export var forbidden_world_tags: Array[String] = []
@export var next_stage_ids_on_success: Array[String] = []
@export var next_stage_ids_on_fail: Array[String] = []
```

👉 Là, tu vois bien :
**`FactionCampaign` = un container de `CampaignStageData`, chaque stage étant relié à des `QuestTemplate` que le QuestManager va instancier.**

---

### 3.2. Côté runtime : CampaignManager + QuestManager + FactionCampaign

Flux typique :

1. **Au début d’une run**, `CampaignManager` charge toutes les `FactionCampaign` (.tres).

2. À chaque **tick de monde** (ou événement majeur), il vérifie :

   ```gdscript
   for campaign_def in all_faction_campaigns:
       if not is_campaign_started(campaign_def.id) and
          campaign_def.start_conditions.are_met(WorldGameState, FactionManager, PlayerState):
           start_campaign(campaign_def)
   ```

3. Quand une campagne `FactionCampaign` démarre :

   * `CampaignManager` crée une `CampaignInstance` :

     * `campaign_id`, `faction_id`, `current_stage_id`, `state = "active"`, etc.
   * Il choisit le premier `CampaignStageData` (souvent le stage de départ)
   * Il demande au `QuestManager` :

     ```gdscript
     QuestManager.start_quest( quest_template_id, { "faction_id": faction_id } )
     ```

4. **QuestManager** gère la quête :

   * progression, objectifs, combats, events,
   * puis émet `quest_completed(quest_instance)`.

5. **CampaignManager** écoute ce signal :

   * regarde si la quête appartient à une campagne (par un tag, un champ `campaign_id`, etc.)
   * met à jour l’instance de campagne :

     * marque le stage comme complété,
     * choisit le `next_stage_id` selon succès / échec,
     * déclenche la/les prochaine(s) quêtes.

6. **WorldImpact final** :

   * à la fin de la campagne (tous les stages terminés, ou condition de fin atteinte),
   * `final_world_impact.apply(WorldGameState, FactionManager, MapGenerator, etc.)` :

     * changement majeur de territoire,
     * buff/malus de faction,
     * crise mondiale déclenchée,
     * accès à un nouvel arc.

👉 `FactionCampaign` est donc **le script narratif de la faction**,
**CampaignManager** est le metteur en scène,
**QuestManager** est le système de gestion des “missions concrètes”.

---

### 3.3. Comment ça se rattache à ce que tu as déjà

Tu as déjà :

* des **POI** (ruines, villes, sanctuaires),
* des **WorldEvents** + handlers,
* un système de quêtes déjà bien avancé.

Tu peux donc faire :

1. Créer une première `FactionCampaign` pour, par exemple, **“Royaume Humain : Reprise des Plaines Fracturées”**.

2. Dans les `CampaignStageData` :

   * Stage 1 : reconstruire une ville ruinée,
   * Stage 2 : repousser des raids orcs,
   * Stage 3 : purifier un sanctuaire corrompu,
   * Stage 4 : bataille majeure pour sécuriser la région.

3. Chaque stage référence des `QuestTemplate` que tu as déjà (ou quelques nouvelles),
   et utilise tes `WorldEvent` pour les exposer au joueur (ex : arrivée dans une ville → event narratif → lancement de la quête de reconstruction).

4. `CampaignManager` se contente de :

   * **suivre l’état** (stage en cours),
   * **écouter les quêtes**,
   * **enchaîner**.

Tu n’as pas besoin de tout FactionManager / CrisisManager ultra avancé pour commencer à jouer avec **UNE** campagne de faction bien structurée.

---

## 4. Résumé en mode “je te le redis cash”

* `QuestManager` = gère les **quêtes individuelles** (plutôt court terme).
* `CampaignManager` = gère les **arcs** (enchaînement de quêtes).
* `FactionCampaign` = **un type particulier d’arc**, centré sur une faction, codé comme un Resource déclaratif, qui dit :

  * quand commencer,
  * quelles étapes,
  * quelles quêtes à chaque étape,
  * comment tout ça réagit à l’état du monde,
  * quel gros impact final sur le monde.

Donc dans ton architecture :

> **FactionCampaign est le “scénario de roman” d’une faction, CampaignManager est l’éditeur qui gère le planning, QuestManager c’est les chapitres, WorldEvents c’est les scènes que voit le joueur.**

---

Si tu veux, au prochain message, on peut faire :

* soit un **exemple complet de `FactionCampaign.tres` + `CampaignStageData.tres`** pour le Royaume Humain,
* soit un **pseudo-code détaillé de `CampaignManager.gd`** avec les signaux à connecter à ton `QuestManager` actuel.


Je vais être direct :
la **prochaine étape** pour ton module campagne, ce n’est pas “refaire tout le système”, c’est de **faire marcher UNE vraie campagne de faction de bout en bout** avec le moins de pièces possibles.

On vise un **palier Campagne 1** :

> 1 seule faction, 1 seule campagne, 3–4 étapes, reliée à ton système de quêtes actuel.

Je te propose un plan très concret, en 5 étapes, avec ce que tu peux coder tout de suite.

---

## 1️⃣ Choisir une campagne précise (ce soir, sur papier)

Tu prends **UNE faction majeure** et tu lui fais **UN arc simple**, par exemple :

**Faction : Royaume humain**
**Campagne : “Reprendre les Plaines Fracturées”**

Stages (exemple) :

1. **Stage 1 – Reconstruire une ville**

   * Quête : sécuriser les environs, repousser une menace (bandits / orcs)
2. **Stage 2 – Stabiliser la région**

   * Quête : neutraliser un camp ennemi / purifier un sanctuaire
3. **Stage 3 – Affirmer la domination**

   * Quête : grosse bataille ou alliance décisive
4. (optionnel) **Stage 4 – Épilogue**

   * Effets sur le monde : buff humain, nouvelles quêtes possibles, etc.

Tu n’as pas besoin d’écrire tous les détails maintenant, juste :
**faction + 3–4 étapes + une quête candidate par étape**.

---

## 2️⃣ Créer les ressources de base campagne

### 2.1 `CampaignStageData.gd`

```gdscript
# res://scripts/quests/CampaignStageData.gd
extends Resource
class_name CampaignStageData

@export var id: String = ""                    # "humans_stage_1_rebuild"
@export var quest_template_ids: Array[String] = []  # ["quest_humans_rebuild_town"]
@export var required_world_tags: Array[String] = [] # prérequis pour démarrer ce stage
@export var forbidden_world_tags: Array[String] = []
@export var next_stage_ids_on_success: Array[String] = []
@export var next_stage_ids_on_fail: Array[String] = []
```

### 2.2 `FactionCampaign.gd`

```gdscript
# res://scripts/quests/FactionCampaign.gd
extends Resource
class_name FactionCampaign

@export var id: String = ""              # "campaign_humans_reconquest"
@export var faction_id: String = ""      # "humans_kingdom"

@export var start_conditions_tags: Array[String] = []  # tags monde/joueur
@export var stages: Array[CampaignStageData] = []

# Id du stage de départ (doit exister dans stages)
@export var start_stage_id: String = ""
```

Ensuite, dans Godot :

* tu crées un `FactionCampaign.tres` dans `data/campaigns/`,
* tu ajoutes 3–4 `CampaignStageData` dans `stages`,
* tu remplis les `quest_template_ids` avec des quêtes qui existent déjà (ou que tu vas créer vite fait).

---

## 3️⃣ Implémenter un `CampaignManager` minimal

### 3.1 Le script

```gdscript
# res://scripts/quests/CampaignManager.gd
extends Node
class_name CampaignManager

var campaigns: Dictionary = {}            # id -> FactionCampaign
var active_campaigns: Dictionary = {}     # campaign_id -> CampaignInstance

class CampaignInstance:
	var campaign_id: String
	var faction_id: String
	var current_stage_id: String
	var state: String = "active" # "active", "completed", "failed"

func _ready() -> void:
	_load_campaigns()
	_connect_quest_signals()


func _load_campaigns() -> void:
	campaigns.clear()
	var base_path := "res://data/campaigns"
	var dir := DirAccess.open(base_path)
	if dir == null:
		push_warning("CampaignManager: pas de dossier %s" % base_path)
		return

	dir.list_dir_begin()
	while true:
		var fn := dir.get_next()
		if fn == "":
			break
		if dir.current_is_dir():
			continue
		if not fn.ends_with(".tres"):
			continue

		var full_path := base_path + "/" + fn
		var res := load(full_path)
		if res is FactionCampaign:
			var fc := res as FactionCampaign
			if campaigns.has(fc.id):
				push_warning("FactionCampaign dupliqué : %s" % fc.id)
			campaigns[fc.id] = fc
	dir.list_dir_end()
	print("CampaignManager: %d campagnes chargées." % campaigns.size())


func _connect_quest_signals() -> void:
	if Engine.has_singleton("QuestManager"):
		var qm = Engine.get_singleton("QuestManager")
		# sinon, si QuestManager est un autoload, utilise simplement QuestManager.quest_completed.connect(...)
	if QuestManager.has_signal("quest_completed"):
		QuestManager.quest_completed.connect(_on_quest_completed)


# === API : démarrer une campagne de faction ===
func start_campaign(campaign_id: String) -> void:
	if not campaigns.has(campaign_id):
		push_warning("CampaignManager: campagne '%s' inconnue" % campaign_id)
		return

	if active_campaigns.has(campaign_id):
		print("CampaignManager: campagne %s déjà active" % campaign_id)
		return

	var def: FactionCampaign = campaigns[campaign_id]
	var inst := CampaignInstance.new()
	inst.campaign_id = def.id
	inst.faction_id = def.faction_id
	inst.current_stage_id = def.start_stage_id
	inst.state = "active"

	active_campaigns[def.id] = inst

	_start_stage(def, inst.current_stage_id)


func _start_stage(def: FactionCampaign, stage_id: String) -> void:
	var stage := _find_stage(def, stage_id)
	if stage == null:
		push_warning("CampaignManager: stage '%s' introuvable dans campagne '%s'" % [stage_id, def.id])
		return

	print("CampaignManager: campagne %s → stage %s" % [def.id, stage.id])

	# Pour Palier 1 : on démarre la première quête du stage
	if stage.quest_template_ids.size() == 0:
		push_warning("CampaignManager: stage %s sans quest_template_ids" % stage.id)
		return

	var quest_id := stage.quest_template_ids[0]
	QuestManager.start_quest(quest_id, {
		"campaign_id": def.id,
		"stage_id": stage.id,
		"faction_id": def.faction_id
	})


func _find_stage(def: FactionCampaign, stage_id: String) -> CampaignStageData:
	for s in def.stages:
		if s.id == stage_id:
			return s
	return null


# === Callback quand une quête se termine ===
func _on_quest_completed(quest_instance: QuestInstance) -> void:
	# On regarde si la quête appartient à une campagne
	var campaign_id := quest_instance.meta.get("campaign_id", "")
	var stage_id := quest_instance.meta.get("stage_id", "")
	if campaign_id == "" or stage_id == "":
		return

	if not active_campaigns.has(campaign_id):
		return

	var inst: CampaignInstance = active_campaigns[campaign_id]
	var def: FactionCampaign = campaigns[campaign_id]

	# On cherche le stage correspondant
	var stage := _find_stage(def, stage_id)
	if stage == null:
		return

	# Pour Palier 1, on prend juste le premier next_stage_ids_on_success
	if stage.next_stage_ids_on_success.size() == 0:
		# Campagne terminée
		print("CampaignManager: campagne %s terminée." % campaign_id)
		inst.state = "completed"
		active_campaigns.erase(campaign_id)
		# TODO: appliquer un WorldImpact ici
		return

	var next_id := stage.next_stage_ids_on_success[0]
	inst.current_stage_id = next_id
	_start_stage(def, next_id)
```

> ⚠️ À ajuster selon ta signature de signal `quest_completed`.
> L’idée : la quête porte `campaign_id` et `stage_id` dans ses `meta`,
> et `CampaignManager` s’en sert pour enchaîner.

---

## 4️⃣ Connecter les quêtes existantes à la campagne

Quand tu démarres une quête qui vient d’une campagne, il faut :

1. Passer dans les paramètres :

   * `campaign_id`,
   * `stage_id`,
   * éventuellement `faction_id`.

2. Stocker ça dans la `QuestInstance` (dans un `meta: Dictionary`).

Exemple dans `QuestManager.start_quest(quest_id, context)` :

```gdscript
func start_quest(quest_id: String, context: Dictionary = {}) -> QuestInstance:
	var tmpl := quest_templates[quest_id]
	var inst := QuestInstance.new()
	inst.id = quest_id
	inst.state = "active"
	inst.meta = context  # ici tu mets campaign_id, stage_id, etc.

	active_quests.append(inst)
	emit_signal("quest_started", inst)
	return inst
```

Ensuite, quand la quête est terminée :

```gdscript
func complete_quest(inst: QuestInstance) -> void:
	inst.state = "completed"
	emit_signal("quest_completed", inst)
```

Et ton `CampaignManager` récupère le `campaign_id` et `stage_id` depuis `inst.meta`.

---

## 5️⃣ Quand lancer la campagne ?

Pour ce palier, garde ça **ultra simple** :

* soit tu déclenches `CampaignManager.start_campaign("campaign_humans_reconquest")` :

  * à la création du monde,
  * ou quand le joueur atteint un certain POI (ville humaine importante),
  * ou quand certains `world_tags` sont posés.

* plus tard, tu pourras utiliser des `start_conditions_tags` dans `FactionCampaign` et faire :

```gdscript
func try_start_faction_campaigns() -> void:
	for c_id in campaigns.keys():
		var def: FactionCampaign = campaigns[c_id]
		if _conditions_ok(def) and not active_campaigns.has(c_id):
			start_campaign(c_id)
```

---

## 🧭 Résumé de “l’étape suivante”

Si je le reformule de manière ultra concrète :

1. **Choisis UNE campagne de faction** (ex : humains, 3–4 étapes).
2. **Crée `CampaignStageData.gd` et `FactionCampaign.gd`.**
3. **Implémente un `CampaignManager` minimal** qui :

   * charge les FactionCampaign.tres,
   * sait démarrer une campagne,
   * sait démarrer un stage → démarre une quête,
   * écoute `quest_completed` → enchaîne le stage suivant.
4. **Ajoute un champ `meta` dans QuestInstance** pour mémoriser `campaign_id` et `stage_id`.
5. **Connecte une de tes quêtes existantes** (par ex. “reconstruire la ville”) à un stage de la campagne humaine.

Quand tu auras ça, tu auras **un vrai module de campagne fonctionnel**, même s’il n’y a qu’UNE faction et QUATRE étapes.
Ensuite on pourra s’occuper de :

* ajouter des branches,
* lier plus finement aux factions / tags monde,
* faire des campagnes procédurales, etc.

Si tu veux, au prochain message, je peux te :

* proposer le **contenu exact** de la campagne du Royaume Humain (titre, textes, objectifs)
* ou t’aider à adapter ce `CampaignManager` à la forme exacte de ton `QuestManager` actuel.

OK, donc on met de côté “finir UNE campagne humaine” et on attaque la **généricité / génération aléatoire**.

Je vais te proposer une architecture procédurale qui reste **maîtrisable**, pas un truc magique incontrôlable.

Je découpe en 3 couches :

1. **Générateur de quêtes unitaires** (à partir du contexte : POI, faction, monde, joueur)
2. **Générateur de campagnes** (structure d’arc narratif + quêtes qui remplissent les “cases”)
3. **Règles globales de cohérence / limites** (éviter les doublons débiles, faire monter la tension, etc.)

Je te donne un modèle clair + un exemple concret.

---

## 1️⃣ Générateur de quêtes unitaires

### 1.1. Inputs du générateur

Une “demande de quête” arrive toujours avec un **contexte**. Par exemple :

* type de POI : `RUINS`, `TOWN`, `SHRINE`, `FORT`, `CAMP`, `CRATER`…
* région : `PLAINS`, `FOREST`, `MOUNTAINS`, `MARSH`, `DESERT`, `ARCHIPEL`…
* faction impliquée (optionnel) : `humans`, `orcs`, `elves`, `tritons`…
* état du monde : tags (`war_in_plains`, `forest_corruption`, `desert_expanding`)
* état du joueur : niveau, puissance, tags (`pro_elves`, `artefact_divine_owned`)
* “demande” :

  * soit “je veux une quête de niveau 1/2/3 ici”,
  * soit “je veux remplir le prochain maillon d’une campagne”.

En pseudo-structure :

```gdscript
class QuestGenerationContext:
    var poi_type: int
    var region_id: String
    var main_faction_id: String
    var world_tags: Array[String]
    var player_tags: Array[String]
    var desired_tier: int       # 1–5
    var desired_type: String    # "combat", "exploration", "diplomacy", "artefact", etc.
```

### 1.2. QuestTemplate : ce que tu as dans ta “bibliothèque”

Chaque entrée de ton “codex de quêtes” n’est PAS une quête figée, mais un **archétype paramétrable** :

```gdscript
class_name QuestTemplate
extends Resource

@export var id: String
@export var tier: int                       # 1 à 5
@export var allowed_poi_types: Array[int]
@export var allowed_regions: Array[String]
@export var allowed_factions: Array[String]
@export var required_world_tags: Array[String]
@export var forbidden_world_tags: Array[String]
@export var required_player_tags: Array[String]
@export var forbidden_player_tags: Array[String]

@export var quest_type: String              # "combat", "escort", "investigate", "defend"
@export var base_weight: float = 1.0

# Un "pattern" d’objectifs, avec des paramètres à remplir:
@export var objective_pattern: QuestObjectivePattern
@export var reward_pattern: QuestRewardPattern
```

L’idée clé : **le template ne sait pas encore quel POI précis, quel artefact exact, quel ennemi**, il ne fait que dire :

> “Je suis une quête de type X, pour tel type de situation, avec tel genre d’objectif et de récompense”.

### 1.3. Algorithme de sélection

Le générateur de quêtes :

1. Filtre les QuestTemplate sur les conditions (`allowed_poi_types`, `tier`, tags, etc.).

2. Calcule un **score / poids** par template, par exemple :

   ```gdscript
   weight = base_weight
   if quest_type == context.desired_type:
       weight *= 2.0
   if main_faction_id in allowed_factions:
       weight *= 1.5
   # etc.
   ```

3. Fait un *tirage pondéré* (roulette wheel) pour choisir un template.

4. Instancie `QuestInstance` en remplissant les trous de `objective_pattern` et `reward_pattern` avec du concret :

   * “POI cible = cette ruine”
   * “ennemi = orcs de niveau 2”
   * “artefact = artefact divin local”
   * “quantité d’or” = fonction de la difficulté.

> **Random contrôlé :** tu ne génères pas la logique, tu choisis un archétype **compatible** puis tu l’**adaptes au contexte**.

---

## 2️⃣ Générateur de campagnes

Une **campagne**, c’est juste une **structure** qui dit :

> “Je veux un arc en X étapes, avec tel genre de beats narratifs”.

### 2.1. CampaignPattern (forme générique)

Au lieu de tout écrire à la main, tu crées des **patterns de campagne** :

```gdscript
class_name CampaignPattern
extends Resource

@export var id: String
@export var min_stages: int = 3
@export var max_stages: int = 5

# Chaque slot de campagne demande un type de quête
@export var stage_slots: Array[CampaignStageSlotPattern]
```

Et un `CampaignStageSlotPattern` :

```gdscript
class_name CampaignStageSlotPattern
extends Resource

@export var desired_tier: int
@export var desired_type: String         # "combat", "exploration", ...
@export var required_tags: Array[String] # tags monde/joueur nécessaires
@export var stage_role: String           # "intro", "rising_action", "climax", "resolution"
```

Exemple concret pour une campagne **faction divine** :

* Stage 1 : `tier=1`, `type="exploration"`, role="intro"
* Stage 2 : `tier=2`, `type="combat"`, role="rising_action"
* Stage 3 : `tier=3`, `type="artefact"`, role="climax"
* Stage 4 : `tier=2`, `type="defense"`, role="resolution`

### 2.2. Génération d’une campagne à partir d’un pattern

Le générateur de campagnes :

1. Choisit un `CampaignPattern` adapté :

   * faction = humais / orcs / etc.
   * contexte monde (tags)

2. Pour chaque `stage_slot` :

   * prépare un `QuestGenerationContext` avec :

     * `desired_tier` = `stage_slot.desired_tier`
     * `desired_type` = `stage_slot.desired_type`
     * contexte monde / faction / POI
   * appelle le **QuestGenerator** (celui de la partie 1) pour obtenir une `QuestTemplate` adaptée.
   * crée un `CampaignStageData` :

     * `quest_template_ids = [id_choisi]`
     * `next_stage_ids_on_success` = id du slot suivant

3. Tu obtiens une **FactionCampaign procédurale**, basée sur un pattern, mais remplie avec des quêtes appropriées au seed / monde / état actuel.

> **Tu ne codes pas chaque campagne à la main** : tu codes des **patterns**, et tu les remplis avec des quêtes compatibles.

---

## 3️⃣ Règles globales de cohérence

Si tu fais “random + random + random” tu vas générer du bruit. Il te faut quelques **lois globales**.

### 3.1. Pas de répétition idiote

* Tu gardes une `history` des derniers templates utilisés pour cette faction / région.
* Tu réduis le poids des templates déjà utilisés récemment.

```gdscript
if quest_template.id in campaign_history.last_used_templates:
    weight *= 0.2
```

### 3.2. Progression de difficulté

* Pour une campagne :

  * `desired_tier` doit **augmenter** ou rester stable, pas redescendre brutalement.
* Pour le monde :

  * tu peux avoir une “pression globale” (niveau de menace mondiale) qui augmente le `tier` moyen au fil du temps.

### 3.3. Impact réel sur le monde

Pour éviter les quêtes “cosmétiques” :

* chaque **QuestTemplate** devrait avoir au moins **un effet systémique** :

  * tag monde ajouté / retiré,
  * état d’un POI modifié (ville → ruine, ruine → sanctuaire, etc.),
  * relation faction modifiée.

Ça peut être petit, mais il doit y avoir un minimum de **trace dans le système**.

---

## 4️⃣ Exemple concret de génération (end-to-end)

### Contexte

* POI : Ruines en bordure de forêt, contrôlées par des orcs
* Faction principale : orcs
* Monde : `["forest_corruption", "war_in_plains"]`
* Joueur : niveau 3, `["friend_elves"]`
* Campagne : “Montée de la corruption forestière (faction esprit corrompu)”
* On veut générer **Stage 2 : Tier 2, type combat**

### 4.1. Le slot de campagne

```text
StageSlot:
    desired_tier = 2
    desired_type = "combat"
    required_tags = ["forest_corruption"]
    stage_role = "rising_action"
```

### 4.2. Contexte passé au QuestGenerator

```gdscript
ctx.poi_type = POI_TYPE_RUINS
ctx.region_id = "FOREST_EDGE"
ctx.main_faction_id = "orcs_horde"
ctx.world_tags = ["forest_corruption", "war_in_plains"]
ctx.player_tags = ["friend_elves"]
ctx.desired_tier = 2
ctx.desired_type = "combat"
```

### 4.3. Filtrage des QuestTemplate

Le générateur garde seulement les templates :

* tier == 2
* `allowed_poi_types` contient `RUINS`
* `allowed_regions` contient `FOREST` ou `FOREST_EDGE`
* `allowed_factions` contient `orcs` ou `any`
* `required_world_tags ⊆ world_tags`
* `forbidden_world_tags` non présents

Dans ce pool, tu as par exemple :

* `quest_orc_cult_ritual` (combat + rituel à interrompre)
* `quest_ruins_beasts` (simple nettoyage de bêtes)
* `quest_undead_from_forest` (non compatible si pas de tag "undead_rising")

Il choisit `quest_orc_cult_ritual` car :

* type = combat,
* tags = `["forest_corruption", "orcs_presence"]`,
* meilleure adéquation de contexte.

### 4.4. Instance de campagne

Tu crées un `CampaignStageData` :

* `id = "spirit_corruption_stage2_ritual"`
* `quest_template_ids = ["quest_orc_cult_ritual"]`
* `next_stage_ids_on_success = ["stage3_boss"]`

Et ta **FactionCampaign** pour l’esprit corrompu a maintenant :

* Stage 1 : quêtes générées autour de ruines mineures / artefact
* Stage 2 : cette quête orc + rituel
* Stage 3 : gros combat / choix moral

Le joueur a l’impression que tu as écrit un arc à la main.
En réalité, tu as utilisé des **patterns + générateur**.

---

## 5️⃣ Concrètement, l’étape suivante pour toi

Vu ce que tu as déjà :

1. **Formaliser une structure `QuestGenerationContext`** (même juste un Dictionary au début), et une fonction :

   ```gdscript
   func generate_quest(context: QuestGenerationContext) -> QuestTemplate
   ```

2. **Taguer proprement tes QuestTemplate actuels** :

   * `allowed_poi_types`,
   * `tier`,
   * `quest_type`,
   * `required_world_tags`, etc.

3. **Écrire un générateur simple de quête** :

   * filtre par conditions,
   * pondère,
   * tirage random.

4. **Créer 1 `CampaignPattern`** et faire un petit générateur de campagne qui :

   * lit le pattern,
   * appelle `generate_quest()` pour chaque slot,
   * produit une `FactionCampaign` procédurale.

Quand on aura ça, on pourra :

* raffiner les poids,
* intégrer des histoires d’artefacts spécifiques,
* mettre des contraintes du style “au moins 1 quête d’exploration et 1 de diplomatie dans chaque campagne”, etc.

---

Si tu veux, au prochain message, je peux :

* te proposer la **structure exacte en GDScript** du `QuestGenerator.gd` + `CampaignPattern.gd`,
* ou prendre **une de tes quêtes existantes** et la transformer en vrai `QuestTemplate` procédural, étape par étape.

OK, donc on met de côté “finir UNE campagne humaine” et on attaque la **généricité / génération aléatoire**.

Je vais te proposer une architecture procédurale qui reste **maîtrisable**, pas un truc magique incontrôlable.

Je découpe en 3 couches :

1. **Générateur de quêtes unitaires** (à partir du contexte : POI, faction, monde, joueur)
2. **Générateur de campagnes** (structure d’arc narratif + quêtes qui remplissent les “cases”)
3. **Règles globales de cohérence / limites** (éviter les doublons débiles, faire monter la tension, etc.)

Je te donne un modèle clair + un exemple concret.

---

## 1️⃣ Générateur de quêtes unitaires

### 1.1. Inputs du générateur

Une “demande de quête” arrive toujours avec un **contexte**. Par exemple :

* type de POI : `RUINS`, `TOWN`, `SHRINE`, `FORT`, `CAMP`, `CRATER`…
* région : `PLAINS`, `FOREST`, `MOUNTAINS`, `MARSH`, `DESERT`, `ARCHIPEL`…
* faction impliquée (optionnel) : `humans`, `orcs`, `elves`, `tritons`…
* état du monde : tags (`war_in_plains`, `forest_corruption`, `desert_expanding`)
* état du joueur : niveau, puissance, tags (`pro_elves`, `artefact_divine_owned`)
* “demande” :

  * soit “je veux une quête de niveau 1/2/3 ici”,
  * soit “je veux remplir le prochain maillon d’une campagne”.

En pseudo-structure :

```gdscript
class QuestGenerationContext:
    var poi_type: int
    var region_id: String
    var main_faction_id: String
    var world_tags: Array[String]
    var player_tags: Array[String]
    var desired_tier: int       # 1–5
    var desired_type: String    # "combat", "exploration", "diplomacy", "artefact", etc.
```

### 1.2. QuestTemplate : ce que tu as dans ta “bibliothèque”

Chaque entrée de ton “codex de quêtes” n’est PAS une quête figée, mais un **archétype paramétrable** :

```gdscript
class_name QuestTemplate
extends Resource

@export var id: String
@export var tier: int                       # 1 à 5
@export var allowed_poi_types: Array[int]
@export var allowed_regions: Array[String]
@export var allowed_factions: Array[String]
@export var required_world_tags: Array[String]
@export var forbidden_world_tags: Array[String]
@export var required_player_tags: Array[String]
@export var forbidden_player_tags: Array[String]

@export var quest_type: String              # "combat", "escort", "investigate", "defend"
@export var base_weight: float = 1.0

# Un "pattern" d’objectifs, avec des paramètres à remplir:
@export var objective_pattern: QuestObjectivePattern
@export var reward_pattern: QuestRewardPattern
```

L’idée clé : **le template ne sait pas encore quel POI précis, quel artefact exact, quel ennemi**, il ne fait que dire :

> “Je suis une quête de type X, pour tel type de situation, avec tel genre d’objectif et de récompense”.

### 1.3. Algorithme de sélection

Le générateur de quêtes :

1. Filtre les QuestTemplate sur les conditions (`allowed_poi_types`, `tier`, tags, etc.).

2. Calcule un **score / poids** par template, par exemple :

   ```gdscript
   weight = base_weight
   if quest_type == context.desired_type:
       weight *= 2.0
   if main_faction_id in allowed_factions:
       weight *= 1.5
   # etc.
   ```

3. Fait un *tirage pondéré* (roulette wheel) pour choisir un template.

4. Instancie `QuestInstance` en remplissant les trous de `objective_pattern` et `reward_pattern` avec du concret :

   * “POI cible = cette ruine”
   * “ennemi = orcs de niveau 2”
   * “artefact = artefact divin local”
   * “quantité d’or” = fonction de la difficulté.

> **Random contrôlé :** tu ne génères pas la logique, tu choisis un archétype **compatible** puis tu l’**adaptes au contexte**.

---

## 2️⃣ Générateur de campagnes

Une **campagne**, c’est juste une **structure** qui dit :

> “Je veux un arc en X étapes, avec tel genre de beats narratifs”.

### 2.1. CampaignPattern (forme générique)

Au lieu de tout écrire à la main, tu crées des **patterns de campagne** :

```gdscript
class_name CampaignPattern
extends Resource

@export var id: String
@export var min_stages: int = 3
@export var max_stages: int = 5

# Chaque slot de campagne demande un type de quête
@export var stage_slots: Array[CampaignStageSlotPattern]
```

Et un `CampaignStageSlotPattern` :

```gdscript
class_name CampaignStageSlotPattern
extends Resource

@export var desired_tier: int
@export var desired_type: String         # "combat", "exploration", ...
@export var required_tags: Array[String] # tags monde/joueur nécessaires
@export var stage_role: String           # "intro", "rising_action", "climax", "resolution"
```

Exemple concret pour une campagne **faction divine** :

* Stage 1 : `tier=1`, `type="exploration"`, role="intro"
* Stage 2 : `tier=2`, `type="combat"`, role="rising_action"
* Stage 3 : `tier=3`, `type="artefact"`, role="climax"
* Stage 4 : `tier=2`, `type="defense"`, role="resolution`

### 2.2. Génération d’une campagne à partir d’un pattern

Le générateur de campagnes :

1. Choisit un `CampaignPattern` adapté :

   * faction = humais / orcs / etc.
   * contexte monde (tags)

2. Pour chaque `stage_slot` :

   * prépare un `QuestGenerationContext` avec :

     * `desired_tier` = `stage_slot.desired_tier`
     * `desired_type` = `stage_slot.desired_type`
     * contexte monde / faction / POI
   * appelle le **QuestGenerator** (celui de la partie 1) pour obtenir une `QuestTemplate` adaptée.
   * crée un `CampaignStageData` :

     * `quest_template_ids = [id_choisi]`
     * `next_stage_ids_on_success` = id du slot suivant

3. Tu obtiens une **FactionCampaign procédurale**, basée sur un pattern, mais remplie avec des quêtes appropriées au seed / monde / état actuel.

> **Tu ne codes pas chaque campagne à la main** : tu codes des **patterns**, et tu les remplis avec des quêtes compatibles.

---

## 3️⃣ Règles globales de cohérence

Si tu fais “random + random + random” tu vas générer du bruit. Il te faut quelques **lois globales**.

### 3.1. Pas de répétition idiote

* Tu gardes une `history` des derniers templates utilisés pour cette faction / région.
* Tu réduis le poids des templates déjà utilisés récemment.

```gdscript
if quest_template.id in campaign_history.last_used_templates:
    weight *= 0.2
```

### 3.2. Progression de difficulté

* Pour une campagne :

  * `desired_tier` doit **augmenter** ou rester stable, pas redescendre brutalement.
* Pour le monde :

  * tu peux avoir une “pression globale” (niveau de menace mondiale) qui augmente le `tier` moyen au fil du temps.

### 3.3. Impact réel sur le monde

Pour éviter les quêtes “cosmétiques” :

* chaque **QuestTemplate** devrait avoir au moins **un effet systémique** :

  * tag monde ajouté / retiré,
  * état d’un POI modifié (ville → ruine, ruine → sanctuaire, etc.),
  * relation faction modifiée.

Ça peut être petit, mais il doit y avoir un minimum de **trace dans le système**.

---

## 4️⃣ Exemple concret de génération (end-to-end)

### Contexte

* POI : Ruines en bordure de forêt, contrôlées par des orcs
* Faction principale : orcs
* Monde : `["forest_corruption", "war_in_plains"]`
* Joueur : niveau 3, `["friend_elves"]`
* Campagne : “Montée de la corruption forestière (faction esprit corrompu)”
* On veut générer **Stage 2 : Tier 2, type combat**

### 4.1. Le slot de campagne

```text
StageSlot:
    desired_tier = 2
    desired_type = "combat"
    required_tags = ["forest_corruption"]
    stage_role = "rising_action"
```

### 4.2. Contexte passé au QuestGenerator

```gdscript
ctx.poi_type = POI_TYPE_RUINS
ctx.region_id = "FOREST_EDGE"
ctx.main_faction_id = "orcs_horde"
ctx.world_tags = ["forest_corruption", "war_in_plains"]
ctx.player_tags = ["friend_elves"]
ctx.desired_tier = 2
ctx.desired_type = "combat"
```

### 4.3. Filtrage des QuestTemplate

Le générateur garde seulement les templates :

* tier == 2
* `allowed_poi_types` contient `RUINS`
* `allowed_regions` contient `FOREST` ou `FOREST_EDGE`
* `allowed_factions` contient `orcs` ou `any`
* `required_world_tags ⊆ world_tags`
* `forbidden_world_tags` non présents

Dans ce pool, tu as par exemple :

* `quest_orc_cult_ritual` (combat + rituel à interrompre)
* `quest_ruins_beasts` (simple nettoyage de bêtes)
* `quest_undead_from_forest` (non compatible si pas de tag "undead_rising")

Il choisit `quest_orc_cult_ritual` car :

* type = combat,
* tags = `["forest_corruption", "orcs_presence"]`,
* meilleure adéquation de contexte.

### 4.4. Instance de campagne

Tu crées un `CampaignStageData` :

* `id = "spirit_corruption_stage2_ritual"`
* `quest_template_ids = ["quest_orc_cult_ritual"]`
* `next_stage_ids_on_success = ["stage3_boss"]`

Et ta **FactionCampaign** pour l’esprit corrompu a maintenant :

* Stage 1 : quêtes générées autour de ruines mineures / artefact
* Stage 2 : cette quête orc + rituel
* Stage 3 : gros combat / choix moral

Le joueur a l’impression que tu as écrit un arc à la main.
En réalité, tu as utilisé des **patterns + générateur**.

---

## 5️⃣ Concrètement, l’étape suivante pour toi

Vu ce que tu as déjà :

1. **Formaliser une structure `QuestGenerationContext`** (même juste un Dictionary au début), et une fonction :

   ```gdscript
   func generate_quest(context: QuestGenerationContext) -> QuestTemplate
   ```

2. **Taguer proprement tes QuestTemplate actuels** :

   * `allowed_poi_types`,
   * `tier`,
   * `quest_type`,
   * `required_world_tags`, etc.

3. **Écrire un générateur simple de quête** :

   * filtre par conditions,
   * pondère,
   * tirage random.

4. **Créer 1 `CampaignPattern`** et faire un petit générateur de campagne qui :

   * lit le pattern,
   * appelle `generate_quest()` pour chaque slot,
   * produit une `FactionCampaign` procédurale.

Quand on aura ça, on pourra :

* raffiner les poids,
* intégrer des histoires d’artefacts spécifiques,
* mettre des contraintes du style “au moins 1 quête d’exploration et 1 de diplomatie dans chaque campagne”, etc.

---

Si tu veux, au prochain message, je peux :

* te proposer la **structure exacte en GDScript** du `QuestGenerator.gd` + `CampaignPattern.gd`,
* ou prendre **une de tes quêtes existantes** et la transformer en vrai `QuestTemplate` procédural, étape par étape.

```md
peux etre qu'on peut partir sur quelque chose de simple en faisant 1 archétype de camapgne
au depart, une quete niveau émane toujours d'une faction majeure qui veut agrandir son pouvoir
mais les objectifs peut variés (une combinaison de 3 à 5 objectifs)
- de gagner des combat (en nettoyant des ruines, en détruisant une armée errante, en abbatant un ennemie puissant...)
- récupére des ressources (artefact/richesse/objet de quete en explorant un POI ou en detruisant une armée)
- je te laisse me suggérer 3 autres type objectifs cohérent avec mon gameplay et les quetes que l'on a déjà évoquer

les choix sont ensuite dans 3 catégories :
- soutenir la faction (en lui remettant les objects/richesse et en détruisant les armées)
- s'enrichir (tout garder pour soit)
- trahir (en s'allaint avec ceux que l'on devait détruire, peut être pour détruire la faction ou pour fuir la faction de départ)

le choix donne ensuite la quete tiers 2
je te laisse me proposer le format des quetes 2 à 5 en te basant sur le descriptif que je viens de faire, le scope que l'ont s'est donné pour les quetes et les choix dont tu avais parler (que j'avais trouver excellents)
```

Parfait, là on commence à toucher du *vrai* système.
Je vais t’aider, mais je vais aussi challenger un peu pour éviter que tu partes dans un truc bancal sans t’en rendre compte.

On part sur :

* **1 archétype de campagne** : “une faction majeure veut agrandir son pouvoir”.
* Tier 1 : toujours initié par cette faction.
* 3 à 5 objectifs combinés parmi plusieurs types.
* 3 grandes orientations de choix : **Soutenir / S’enrichir / Trahir**.
* Ces choix déterminent la **quête Tier 2** et l’orientation de la campagne (jusqu’à T5).

Je vais te donner :

1. ✅ 3 nouveaux types d’objectifs cohérents avec TON gameplay.
2. ✅ Le **format de la campagne T1 → T5** pour cet archétype (structure claire).
3. ✅ Pour chaque Tier, le “format” des quêtes : type d’objectifs, choix possibles, impact monde.

---

## 1️⃣ Types d’objectifs — base générique pour l’archétype

Tu as déjà :

1. **Gagner des combats**

   * nettoyer des ruines,
   * détruire une armée errante,
   * abattre un ennemi puissant / élite / boss.

2. **Récupérer des ressources / artefacts / objets de quête**

   * en explorant un POI,
   * en détruisant une armée,
   * en fouillant des ruines, sanctuaires, etc.

Je te propose **3 types supplémentaires**, parfaitement compatibles avec ton système :

---

### 🔹 Objectif 3 : Contrôle & sécurisation de territoire

**But :**
Contrôler une zone stratégique pour la faction initiatrice (ou pour soi-même).

Formes possibles :

* Capturer / sécuriser un **POI clé** :

  * ville, fort, pont, sanctuaire, carrefour de routes.
* Maintenir le contrôle sur une zone pendant X jours / X phases :

  * “Défendre la ville pendant 3 jours contre des vagues d’ennemis”.
* **Fortifier** un point :

  * construire des campements, chariots, garnisons, tours, etc. (plus tard quand tu auras la logistique avancée).

C’est cohérent avec ton gameplay :

* tu as déjà le déplacement, les POI, le combat, le temps, et l’idée de repos/fortification.

---

### 🔹 Objectif 4 : Influence & diplomatie locale

**But :**
Modifier la **position d’une autre faction** vis-à-vis de la faction initiatrice (ou du joueur).

Formes possibles :

* Convaincre une faction mineure de :

  * rejoindre l’effort militaire,
  * ouvrir ses frontières,
  * cesser une alliance adverse.
* Améliorer ou dégrader une relation :

  * livrer des ressources,
  * sauver une ville d’une autre faction,
  * trahir une promesse (qui donnera des malus).

Gameplay minimal viable (sans système diplomatique complet) :

* Tu peux symboliser ça par :

  * un tag monde `faction_X_helped_by_player`,
  * un bonus/malus sur le comportement futur (plus d’armées alliées / moins d’incursions).

---

### 🔹 Objectif 5 : Rituel / intervention magique / technologique

**But :**
Utiliser / interrompre / détourner un pouvoir **supérieur** (magique ou techno).

Formes possibles :

* Mener un rituel :

  * purifier un esprit,
  * renforcer un dieu,
  * stabiliser une faille,
  * booster une armée ou une région.
* Corrompre un rituel :

  * donner un artefact à un mauvais esprit,
  * saboter une machine ancienne.
* Activer un artefact :

  * “Accepter” qu’une faction l’utilise,
  * l’utiliser toi-même,
  * le détruire (résultat radical mais imprévisible).

Ça colle parfaitement :

* à tes esprits, artefacts, dieux, volcan, corruption, techno.

---

## 2️⃣ Archétype de campagne : “Expansion d’une faction majeure”

On va formaliser **UN archétype** de campagne procédurale :

> **Une faction majeure veut étendre son pouvoir.**
> Elle confie des objectifs au joueur.
> Le joueur peut :
>
> * l’aider vraiment (**Soutenir**),
> * se servir d’elle pour s’enrichir (**S’enrichir**),
> * la trahir (“changer de camp”, voire créer un nouvel acteur) (**Trahir**).

Et cette campagne est structurée en **5 Tiers de quêtes** :

* **Tier 1** : mise en place (3–5 objectifs)
* **Tier 2** : première orientation (Soutien / Profit / Trahison)
* **Tier 3** : consolidation / escalade
* **Tier 4** : conflit de grande ampleur / bascule du monde
* **Tier 5** : résolution / conséquences mondiales

Je vais te donner le **format** de chaque Tier, pas un scénario figé.

---

## 3️⃣ Tier 1 — Quête initiale multi-objectifs

**Origine :**
Toujours une faction majeure (humaine, orc, elfe, nain, triton…).

**Objectifs (3 à 5, tirés aléatoirement parmi les 5 types) :**

Par exemple :

* 🎯 Combat : détruire une armée errante qui menace une ville.
* 🎯 Ressources : récupérer un artefact ou richesse dans des ruines.
* 🎯 Territoire : sécuriser un fort sur une frontière.
* 🎯 Diplomatie : obtenir le soutien d’une faction mineure ou faire passer un message.
* 🎯 Rituel : assister à un rituel de bénédiction / renforcement pour la faction.

Tu peux générer ces objectifs de façon procédurale, mais dans le scope actuel, tu peux commencer avec :

> **1 combat + 1 ressource + 1 territoire**
> et plus tard, ajouter diplomatie/rituels comme variantes.

---

### 🔸 Fin de la quête Tier 1 : les choix

À la fin, tu as **les 3 grandes orientations** :

1. **Soutenir la faction**

   * Tu lui remets les artefacts / richesses.
   * Tu détruis les ennemis comme demandé.
   * Tu fais les objectifs “dans le sens” de leur agenda.

2. **S’enrichir**

   * Tu gardes les artefacts, richesses, objets de quête.
   * Tu accomplis les combats, mais tu détournes le profit.
   * Tu peux commencer à “jouer perso” (futur faction mineure / indépendante).

3. **Trahir**

   * Tu fais alliance avec ceux que tu devais détruire (faction mineure, esprit, empire rival).
   * Tu conserves / offres les objets au camp adverse.
   * Tu peux saboter un rituel ou un objectif clé.

> Ces trois choix déterminent **quel type de Tier 2 est généré**.

---

## 4️⃣ Tier 2 — Format des quêtes selon l’orientation

On reste en **archétype**, pas en scénario figé.

### 🟢 Branche A — Soutenir la faction

**Tier 2 — “Renforcer la faction”**

Objectifs possibles (2–3 parmi) :

* Combat :

  * éliminer une base ennemie importante,
  * détruire un héros / unité d’élite.

* Territoire :

  * capturer / fortifier un POI (fort, carrefour stratégique).

* Ressource / rituel :

  * livrer un artefact ou ressources à la capitale,
  * assister / sécuriser un rituel de renforcement de la faction (bonus global).

**Impact :**

* tags monde du type :

  * `faction_X_empowered`,
  * `region_Y_under_control_of_X`.
* meilleure capacité de la faction sur la world map (plus d’armées, plus forte).

---

### 🟡 Branche B — S’enrichir

**Tier 2 — “S’installer / se renforcer personnellement”**

Objectifs possibles :

* Ressources :

  * utiliser l’artefact pour toi,
  * monter ton propre camp / avant-poste.

* Territoire perso :

  * fonder un **campement personnalisé** (proto faction mineure).

* Combat :

  * repousser des attaquants qui veulent récupérer ce que tu as pris,
  * protéger ton nouveau camp.

**Impact :**

* ajout d’un POI “camp du joueur” / base,
* tag du type `player_is_proto_faction`,
* faction initiale commence à se méfier.

---

### 🔴 Branche C — Trahir

**Tier 2 — “Changer de camp”**

Objectifs possibles :

* Diplomatie inversée :

  * contacter ceux que tu devais détruire,
  * livrer l’artefact/l’information à la faction ennemie.

* Combat ciblé :

  * saboter un convoi ou un rituel de la faction initiale,
  * faire tomber une avant-poste clé.

**Impact :**

* tags :

  * `betrayed_faction_X`,
  * `allied_with_enemy_of_X`.
* réaction de la faction initiale : hostilité, chasse, pression sur la carte.

---

## 5️⃣ Tier 3–4 — Escalade & structuration

À partir de là, tu peux garder **la même structure** et faire évoluer :

* la **portée** des objectifs,
* le **nombre de POI impliqués**,
* l’**échelle des combats** (armées plus grosses, élites, boss),
* l’**impact monde** (biomes, crises, alliances).

### 🟢 Branche A — Soutien (tiers 3 et 4)

**Tier 3 — “Domination régionale”**

* Objectifs :

  * contrôler **toute une région** (plaines, forêt, etc.) :

    * 2–3 POI à capturer / sécuriser,
    * neutraliser une faction rivale locale.
  * possiblement un rituel massif pour “sacraliser” la région ou la technologiser.

* Impact :

  * la région passe officiellement sous contrôle de la faction →
    `region_plains_owner = humans`.

**Tier 4 — “Hégémonie ou escalade globale”**

* Objectifs :

  * attaquer le cœur d’un rival majeur,
  * accomplir un rituel majeur (divin ou techno),
  * ou écraser une alliance concurrençant la faction.

* Impact :

  * la faction peut devenir **super-puissance**,
  * déclenche potentiellement une **crise globale** (Tier 5).

---

### 🟡 Branche B — S’enrichir (tiers 3 et 4)

**Tier 3 — “Devenir une vraie faction mineure”**

* Objectifs :

  * développer ton camp en **base solide** (amélioration logistique, ressources, garnison).
  * former des alliances opportunistes (factions mineures).

* Impact :

  * passage de `player_is_proto_faction` à `player_is_minor_faction`.
  * apparition de nouvelles quêtes liées à ta base.

**Tier 4 — “Se positionner dans le conflit global”**

* Objectifs :

  * soit s’allier formellement à une grande faction,
  * soit rester indépendant mais s’accaparer des ressources clés.

* Impact :

  * tu deviens un acteur systémique dans le monde :
    → certaines factions te traitent comme un vrai joueur politique.

---

### 🔴 Branche C — Trahir (tiers 3 et 4)

**Tier 3 — “Affaiblir l’ancienne faction”**

* Objectifs :

  * saboter des POI critiques (forts, villes, sanctuaires) de la faction initiale,
  * renforcer ouvertement leurs ennemis (don de ressources, défenses, etc.).

* Impact :

  * `faction_X_weakened`,
  * progression d’une faction rivale ou d’un esprit/dieu/corruption.

**Tier 4 — “Changer l’équilibre des grandes puissances”**

* Objectifs :

  * aider la nouvelle faction (esprit, empire rival…) à prendre le dessus dans une région clé,
  * provoquer une guerre ouverte.

* Impact :

  * déséquilibre massif dans la géopolitique du monde,
  * préfiguration d’une crise (Tier 5).

---

## 6️⃣ Tier 5 — Résolution / Crise mondiale

Peu importe l’orientation, Tier 5 doit :

* conclure la campagne,
* laisser une **trace durable** sur le monde,
* ouvrir des portes pour les run suivantes (tu reprends le monde tel qu’il est).

Exemples de Tier 5 par branche :

### 🟢 Soutenir

* La faction soutenue devient **super-puissance** (ou tente de le devenir) :

  * objectifs : bataille finale, protection d’un rituel d’ascension, défense globale.
  * fin possible :

    * dominatrice mais stable (version “Empire fort”),
    * dominatrice et oppressive → nouvelles résistances.

### 🟡 S’enrichir

* Le joueur/Faction-joueur doit :

  * soit survivre à la pression combinée des grands,
  * soit choisir un camp,
  * soit devenir un pivot (médiation, exploitation, etc.).

Résultat :

* le joueur est quelqu'un de **systémique** dans le monde (faction mineure ou majeure selon ta vision).

### 🔴 Trahir

* Final :

  * destruction ou chute de la faction initiale,
  * montée en puissance du camp que tu as aidé,
  * ou retournement final (tu te fais doubler / trahir à ton tour, ou tu jugules la menace).

---

## 7️⃣ Ce que tu as maintenant (et ce que tu peux faire tout de suite)

Tu as :

* ✅ 5 types d’objectifs génériques alignés avec ton gameplay (combat, loot, territoire, diplomatie, rituels).
* ✅ Un **archétype de campagne** cohérent T1–T5 :

  * T1 : multi-objectifs, 3 choix (Soutien / Profit / Trahison),
  * T2 : orientation claire,
  * T3–4 : escalade / structuration,
  * T5 : résolution / bouleversement du monde.

La **prochaine étape concrète**, si tu veux rester dans la généricité, ce serait :

1. Formaliser cet archétype sous forme de **CampaignPattern** (avec des “slots” : T1, T2, T3, T4, T5).
2. Définir la **structure de QuestTemplate** pour chaque type d’objectif (combat, ressource, territoire, diplomatie, rituel).
3. Commencer par générer **UN chemin complet** :

   * T1 → T2 soutien → T3 → T4 → T5 soutien,
     via ton futur `QuestGenerator`.

Si tu veux, au prochain message, on peut :

* soit transformer ce design en **structure de données concrète** (Resources Godot pour `CampaignPattern`, `QuestTemplate`, etc.),
* soit prendre **un chemin particulier** (ex : Soutenir → Soutenir → Hégémonie) et le transformer en une suite de quêtes prototypables *dans ton projet actuel*.
