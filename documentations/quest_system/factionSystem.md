Moi:
predns connaissance du texte ci dessous qui decrit ce que j'ai mis en place.
Prends aussi connaissances des docuement que je t'envoie pour comprendre le contexte de mon jeu

Voici un **résumé fonctionnel et exhaustif** de l’état actuel du système de quêtes (procédural + offers + résolution + simulation + arcs). Tu peux le coller tel quel pour démarrer une nouvelle conversation.

---

## 1) Vue d’ensemble

Le jeu possède un **système de quêtes procédural data-driven**, basé sur une séparation stricte :

* **QuestTemplate** : décrit la “forme” de la quête (catégorie, objectif, tier, expiration, etc.).
* **QuestInstance** : instance runtime créée à partir d’un template + **context runtime** (giver/antagonist, paramètres de génération, arc info, goal step, artefact id, owner, etc.).

Les quêtes existent sous 2 formes runtime distinctes :

1. **Offers** : quêtes “disponibles” dans un pool (pas encore acceptées).
2. **Active quests** : quêtes prises par un owner (player / hero / army IA / etc.), suivies en progression et résolues.

---

## 2) Données principales

### QuestTemplate

Contient les champs “communs à toutes les occurrences” :

* `id`, `title`, `description`
* `category`, `tier`
* `objective_type`, `objective_target`, `objective_count`
* `expires_in_days` (souvent utilisé pour offers / quêtes)
* * éventuellement des champs liés à la résolution (selon tes itérations)

### QuestInstance

Représente une occurrence runtime :

* `runtime_id` : identifiant unique
* `template_id`, `template`
* `status` : AVAILABLE / ACTIVE / COMPLETED / FAILED / EXPIRED
* `progress`
* `started_on_day`, `expires_on_day`
* `context : Dictionary` : **coeur du procédural** (voir ci-dessous)

Le `context` contient typiquement :

* `giver_faction_id`
* `antagonist_faction_id`
* `resolution_profile_id`
* flags : `is_goal_offer`, `is_arc_rivalry`
* pour les goals : `goal_step_id`, `goal_domain`
* pour les arcs : `arc_id`, `arc_stage`, `arc_reason`
* pour artefacts/lost loot : `artifact_id`, `owner_type`, `owner_id`
* paramètres de génération : enemy_type, days, amount, etc.

---

## 3) Génération procédurale

### QuestGenerator

Génère des quêtes “dynamiques” en construisant :

1. un **template runtime** (souvent via `_create_dynamic_template(quest_type, params)`)
2. un **context runtime** (giver/antagonist/profile/goal/arc/etc.)
3. une **QuestInstance** créée avec `QuestInstance.new(template, context)`.

Deux modes principaux :

* `generate_random_quest(tier)` : quête générique (combat/exploration/survival/collection/diplomacy…).
* `generate_quest_for_poi(poi_pos, poi_type)` : quête spécifique à un POI (ruines, ville, sanctuaire…).

Les paramètres runtime sont générés par :

* `_generate_random_parameters(quest_type, tier)`
* `_generate_quest_parameters(quest_type, poi_type, poi_pos)`

Le générateur injecte aussi :

* `giver_faction_id`, `antagonist_faction_id`
* `resolution_profile_id` (choisi dynamiquement via règles / factory)

---

## 4) Offers : pool global + caps + validation

### QuestPool

Contient les offers disponibles (quêtes status AVAILABLE).
Il y a une logique de contrôle :

* **expiration**
* **cap global** : ex. MAX_OFFERS_GLOBAL
* **cap par signature** (anti-spam d’un même “type” d’offre)
* **cap par giver** (anti-monopole d’une faction)

Une offer peut être invalidée si :

* elle est expirée
* elle référence un owner runtime disparu (ex: LootSite qui n’existe plus)
* giver faction invalide / inconnue
* dépendances d’autoload manquantes (selon implémentation)

---

## 5) QuestManager : acceptation, progression, résolution

### QuestManager

Responsable de :

* charger/registrer des templates (si tu utilises des .tres pour certains)
* démarrer une quête (instance ACTIVE)
* suivre la progression
* compléter/expirer
* appliquer la **résolution** via un profil

Principales opérations :

#### Démarrer une quête

* `start_quest(template_id, context)` (mode “templates enregistrés”)
* `start_runtime_quest(quest_instance)` (mode “quest instance procédurale déjà construite”)

Cela place la quête dans `active_quests[runtime_id]`.

#### Progression

* `update_quest_progress_by_id(runtime_id, delta)`
  Quand l’objectif est atteint, la quête passe en état “résolution requise” (selon ta logique actuelle).

#### Résolution

* `resolve_quest(runtime_id, choice)` avec choice ∈ {LOYAL, NEUTRAL, TRAITOR}

Le QuestManager :

1. récupère le `resolution_profile_id` (sur l’instance ou via context)
2. charge le profil depuis un registry (souvent basé sur `.tres`)
3. applique les effets (or, tags, relations giver/antagonist…)

Il émet aussi un signal :

* `quest_resolved(inst, choice)` (utilisé par ArcManager)

---

## 6) Profils de résolution (data-driven via .tres)

### QuestResolutionProfile (.tres)

Resource contenant :

* `id`
* `loyal_effects`, `neutral_effects`, `traitor_effects` : Array[QuestEffect]

### QuestEffect

Resource contenant :

* `type` ∈ {GOLD, TAG_PLAYER, REL_GIVER, REL_ANT, TAG_WORLD}
* `amount` (or / delta relation)
* `tag` (tag player/world)

Le système permet :

* même quête/template, résolutions différentes
* effets modulables et équilibrables sans toucher au code

---

## 7) Tags monde/joueur

Le QuestManager maintient :

* `player_tags : Array[String]`
* `world_tags : Array[String]`

Ils servent de mémoire globale simple pour :

* influencer la génération (context tags, rules, unlocks…)
* marquer des états persistants (WAR_SPIKING, DOMAIN_*_GROWING, WAR_DECLARED, etc.)

---

## 8) Simulation de monde (Option B) : factions avec objectifs

Le monde avance par jours via un simulateur (WorldSim / FactionSim).

### FactionSim

Chaque jour :

* choisit une faction
* s’assure qu’elle a un objectif (`FactionGoalManagerRunner.ensure_goal(faction_id)`)
* planifie une action (`FactionGoalPlanner.plan_action(goal)`)
* applique l’action (`FactionGoalManagerRunner.apply(action)`)

Les actions peuvent produire :

* des tags monde
* des changements de relation entre factions
* des progressions de goals
* des offers de quêtes (notamment goal offers)

### Goals structurés (steps + progress)

Un goal est composé de steps (ex: gather → secure → build).
Chaque step peut produire :

* logs
* progression
* offers de quêtes liées au goal (`is_goal_offer = true`, `goal_step_id`, `goal_domain`, etc.)

---

## 9) Héros IA : compétition sur les offers

Un test de simulation (Hero competition) existe :

* Des héros IA prennent parfois une offer avant le joueur
* Ils démarrent la quête (ACTIVE), résolvent ou échouent/expirent
* Cela crée une dynamique d’écosystème : offers consommées / expirées / prises

---

## 10) Artefacts perdus / Loot sites / Quêtes de récupération

Un système existe pour :

* créer un artefact dans l’inventaire d’une armée
* détruire l’armée → spawn d’un **LootSite** à la position
* l’artefact devient “owner_type=LOOT_SITE, owner_id=loot_xxx”
* si le LootSite expire → owner devient LOST

Une quête “Retrieve artifact X” est générée avec context :

* `artifact_id`
* `owner_type`, `owner_id` (si loot site)
* `resolution_profile_id = artifact_recovery` (ou autre)

Offers liées à un LootSite sont invalidées si :

* LootSiteManager n’existe pas
* LootSiteManager.sites ne contient plus owner_id

---

## 11) Arcs narratifs (Option A en cours) : Rivalité de factions (MVP)

Un arc “Faction Rivalry” existe (MVP contrôlé) :

### FactionRivalryArc

* `attacker_id`, `defender_id`
* `stage` : 1 PROVOCATION, 2 ESCALATION, 3 DECISIVE, 4 RESOLVED (terminal)
* `started_day`, `last_event_day`
* `pending_retaliation`

### ArcManager

Déclenchement :

* `on_faction_hostile_action(attacker, defender, action)` ⇒ crée/assure un arc + spawn une offer d’arc.

Résolution :

* QuestManager appelle ArcManager lors de `resolve_quest` via signal `quest_resolved(inst, choice)` ou appel direct `on_quest_resolution_choice`.
* Si la quête est une quête d’arc (`context.is_arc_rivalry=true`) :

  * progression d’arc (LOYAL avance de stage)
  * `pending_retaliation=true`

Retaliation rule (1 règle MVP) :

* `tick_day()` : si `pending_retaliation`, spawn une offer “retaliation” en inversant giver/antagonist.

Les offers d’arc sont des QuestInstances avec context :

* `is_arc_rivalry=true`
* `arc_id`, `arc_stage`, `arc_reason`
* `giver_faction_id`, `antagonist_faction_id`
* `resolution_profile_id` (ex: default_simple)

---

## 12) Tests (harness)

Il existe un `QuestSystemTest.gd` (test harness) qui valide :

* génération quest tier
* génération POI
* intégration QuestManager (start/progress/resolve)
* pipeline Palier 2 (LOYAL/NEUTRAL/TRAITOR + effects)
* offers caps / expiration (max offers)
* simulation monde multi-jours (goals, tags, relations, offers)
* arcs rivalry MVP (retaliation)
* artefact lost / loot site / retrieve quest (test 10/11 selon versions)

---

## 13) Convention Runner / Autoload

Plusieurs systèmes sont en autoload avec parfois un nom différent de `class_name` (à cause de Godot).
Ex : `ArcManagerRunner`, `FactionGoalManagerRunner`, etc.

Le code fait souvent :

* `if XxxRunner != null and XxxRunner.has_method(...)`

---

Si tu veux, pour la prochaine conversation, tu peux ajouter à ce résumé :

* la liste exacte de tes autoloads actuels (nom autoload → script)
* la structure exacte de tes relations inter-factions (où est stocké `humans|orcs : -70`, etc.)
* comment QuestPool est branché (QuestPool.try_add_offer vs QuestOfferSimRunner.try_add_offer)

ChatGPT:
OK — j’ai pris connaissance :

- de ton **résumé “état actuel”** (procédural + QuestTemplate/QuestInstance + offers/active + résolution LOYAL/NEUTRAL/TRAITOR + simulation + arcs + artefacts/lootsites),
- et des documents fournis (quêtes/campagnes/crises, POI, axes, événements, ères/IA, logistique).

### Ce que je comprends du contexte “jeu” (couche design)

- **Orchestration globale** autour d’un `WorldGameState` qui coordonne `QuestManager`, `CampaignManager`, `CrisisManager`, `FactionManager`, avec un `EventBus` pour la communication inter-systèmes. fileciteturn1file1  
- Un **système de quêtes/campagnes en tiers** (du local jusqu’aux crises mondiales), avec génération procédurale via `QuestGenerator` + `QuestPool` (templates par catégorie/tier). fileciteturn2file8turn2file9  
- Un **contrôle d’apparition par tags + conditions** (tags monde/joueur, saisons, guerres, réputation, prérequis), avec propagation de tags qui rafraîchit la disponibilité des quêtes. fileciteturn1file16turn1file14  
- Une couche **campagnes narratives** (chapitres, progression, rewards, conditions de déverrouillage, impacts monde + relations de factions). fileciteturn1file0turn1file2turn1file5  
- Une couche **crises mondiales** (phases, time limit, contribution, quêtes injectées par phase, effets succès/échec, save/load). fileciteturn1file6turn2file4  
- Le “terrain de jeu” : **POI catégorisés et transformables** par factions/événements/ères, servant d’ancrages naturels à exploration/combat/quête. fileciteturn2file16  
- Le rythme de run : **logistique & repos** (nourriture, transport, or, reliques, moral, endurance, repos dépendant de la zone, marche forcée, etc.). fileciteturn2file3turn2file6  
- L’évolution long terme : **ères (runs) avec événements N1→N5**, et une **IA stratégique** (personnalités, réaction aux crises, priorités). fileciteturn2file10turn0file3  
- L’identité du monde : **axes Techno/Magie/Nature/Divin/Corruption** (niveaux, bâtiments, unités, transformations) qui influencent factions, événements et contenu. fileciteturn0file2  

### Comment ça se “colle” avec ton implémentation actuelle (couche système)

- Ton triptyque **Offer → Active → Résolution** colle très bien avec le modèle “disponible/active/complétée” documenté côté `QuestManager`, mais toi tu l’as déjà poussé plus loin avec des **QuestInstance runtime + context riche + profils de résolution** (et la compétition IA / arcs / lootsites). fileciteturn1file14turn2file15  
- Tes choix **LOYAL / NEUTRAL / TRAITOR** s’alignent naturellement avec la philosophie “**Soutenir / S’enrichir / Trahir**” des campagnes/branches décrites dans `QuestSystem.md`. fileciteturn2file17turn1file10  

### Point important (à garder en tête)
Dans tes docs “QuestManager/CampaignManager/CrisisManager”, on voit une approche très *resource-driven* (IDs de quêtes, disponibilité via conditions, etc.). fileciteturn1file14turn1file16  
Ton résumé, lui, décrit une approche plus *runtime/procédurale* (instances uniques, offers pool, invalidation, context, arcs, loot ownership). Les deux sont compatibles : il suffit de considérer les `.tres`/templates comme une **source de formes**, et tes `QuestInstance` comme la **réalité runtime**.

Si tu veux enchaîner maintenant, je peux directement :
- proposer une **terminologie unifiée** (mêmes noms pour offers/disponibles, runtime_id, template_id, etc.),
- ou écrire un **plan d’intégration** “Campaign/Crisis (docs) ↔ Offers/Arcs/Lootsites (actuel)” sans refaire le système.

Moi:
Je voudrais qu'on discute du ArcManager
Actuellement, une action histile d'une faction permet de declencher une rivalité, ce qui va entrainer une action de vengeance, ce qui entraine une action histile vers la faction d'origine.
Ca risque de faire une boucle est de toujours mener a l'escalade.
Deja, je voudrais qu'on discute de quand arreter une rivalité et de comlent et sur quelle critere la faire evoluer.
Je voudrais que ca puisse mzner tant a une guerre d'extermination qu'a une alliance, voir une fusion des deux factions majeures.
En gros, je ne veux pas que l'historique des relation (parce qu'actuellement, je conserve un historiqie des actions hostile et des rettribution) conduisent forcement a l'escalade

ChatGPT:
Oui, avec ton modèle actuel “hostile action ⇒ rivalité ⇒ vengeance ⇒ hostile action inverse”, tu as une **boucle déterministe** qui *tend* mécaniquement vers l’escalade. La clé, c’est que l’arc ne doit pas “répondre” automatiquement par de l’hostilité : il doit **choisir une réponse** parmi plusieurs options, guidé par des métriques (tension, coût, opportunité, objectifs…).

Voici une façon solide de cadrer **quand arrêter**, **comment évoluer**, et comment rendre possible **extermination / paix / alliance / fusion**, sans que l’historique impose l’escalade.

---

## 1) Remplacer “pending_retaliation” par un vrai modèle de dynamique

Au lieu de `pending_retaliation=true`, donne à chaque arc quelques **variables continues** :

- **tension** (0..100) : chaleur du conflit
- **grievance_A→B** et **grievance_B→A** (0..100) : “dette” ressentie par chaque camp
- **trust** (-100..+100) : confiance/défiance (peut remonter !)
- **war_weariness_A / _B** (0..100) : fatigue, coût interne, lassitude
- **opportunity** (0..100) : capacité réelle à frapper maintenant (armées proches, logistique, etc.)
- **external_pressure** : menace commune / crise / médiation possible

L’historique n’est plus un rail, c’est un **input** qui alimente ces variables.

---

## 2) Une rivalité doit pouvoir “répondre” autrement que par la vengeance

À chaque tick (jour / semaine), pour un arc, tu fais choisir une **réponse** à chaque camp (ou au “camp actif” du tour). Exemple d’ensemble d’actions possibles :

### Réponses hostiles
- **Raid / escarmouche** (petit coût, petite tension)
- **Coup majeur** (gros coût, grosse tension)
- **Guerre ouverte** (change le “mode” du conflit)

### Réponses non-hostiles mais “dures”
- **Sanctions / embargo**
- **Propagande / sabotage / espionnage**
- **Ultimatum / demande de réparation**
- **Renforcement défensif** (pas d’attaque, mais monte la préparation)

### Réponses d’apaisement
- **Ignorer / temporiser** (laisse la dette diminuer si fatigue haute)
- **Proposer trêve** (réduit tension, demande concessions)
- **Payer réparation / rendre artefact / libérer prisonniers**
- **Médiation** par une 3e faction

👉 Le point important : même avec “grief élevé”, la faction peut **ne pas** frapper si (fatigue élevée) ou (mauvaise opportunité) ou (menace externe).

---

## 3) Évolution par “stades” + transitions probabilistes (pas déterministes)

Garde tes stades, mais fais-les dépendre de la *combinaison* tension / trust / fatigue / opportunité, avec des transitions **non garanties**.

Exemple de stades utiles :
1. **Incident** (PROVOCATION)
2. **Feud** (ESCALATION faible : raids, représailles limitées)
3. **War** (guerre ouverte)
4. **Total War** (extermination / siège / destruction)
5. **Truce** (cessation des hostilités, fragile)
6. **Peace** (stabilisé)
7. **Alliance**
8. **Confederation / Fusion** (terminal)
9. **Annihilated / Subjugated** (terminal)

### Règle simple de transition
- Tension haute + opportunité haute + fatigue basse ⇒ **escalade probable**
- Tension haute + fatigue haute ⇒ **trêve / pause probable**
- Tension moyenne + menace externe forte ⇒ **alliance possible** (ennemi commun)
- Trust remonte au-dessus d’un seuil + objectifs convergents ⇒ **paix durable / alliance**
- Power ratio extrême + trust pas trop bas + proximité culturelle ⇒ **vassalisation / fusion**

---

## 4) “Quand arrêter une rivalité ?” (conditions terminales claires)

Tu veux des issues variées : fixe des **conditions de fin** (RESOLVED) explicites :

### Fin “violente”
- **Extermination** : une faction passe sous un seuil (armée/territoire/population)
- **Capitulation / vassalisation** : grief élevé d’un côté + ratio de puissance défavorable + fatigue max
- **Annexion** : victoire + contrôle de POI clés + décision politique (tag monde)

### Fin “politique”
- **Traité de paix** : tension < X pendant Y jours + concessions acceptées
- **Alliance** : menace externe + confiance > seuil + bénéfices stratégiques
- **Fusion** : alliance stable + confiance haute + (leader trait / idéologie compatible) + “période d’union”

### Fin “extinction naturelle”
- **Désintérêt / oubli** : si aucun incident pendant N jours, tension et griefs décroissent jusqu’à 0 ⇒ arc se clôt

---

## 5) Comment éviter la boucle de vengeance “à coup sûr”

Voilà 6 garde-fous très efficaces :

1. **Cooldown** : un arc ne génère pas d’événement tous les jours (ex : min 3–7 jours entre 2 actes majeurs).
2. **Décroissance** : chaque jour sans incident, `tension -= decay` et `grievance -= decay_grief`.
3. **Coût interne** : chaque action hostile augmente `war_weariness`. À fatigue haute, la valeur d’une vengeance chute.
4. **Rendements décroissants** : la 5e représaille “identique” apporte moins de gain politique/stratégique.
5. **Opportunité** : pas de représaille si pas de moyens (armées loin, logistique faible, crise interne).
6. **Sortie honorable** (“face-saving”) : réparations, échange de prisonniers, ultimatum, médiation… qui “paient” la dette sans escalade.

---

## 6) Comment rendre possibles alliance et fusion (même après hostilités)

Il te faut des **mécaniques de remontée de trust**, sinon tu n’iras jamais vers “+”.

Sources réalistes de regain de confiance :
- **Ennemi commun** (crise mondiale / 3e faction agressive)
- **Intérêts convergents** (commerce, accès à une ressource/POI, religion/idéologie)
- **Actions de réparation** (payer, rendre un artefact, sauver un héros, aider en logistique)
- **Quêtes “pont”** : missions spéciales (escorte diplomatique, mariage politique, purge d’un traître commun, pacte de non-agression)

Concrètement : certaines résolutions de quêtes (LOYAL/NEUTRAL/TRAITOR) peuvent **augmenter trust** ou **réduire grief** au lieu d’ajouter du conflit.

---

## 7) Proposition d’implémentation minimaliste (compatible avec ton ArcManager actuel)

### Données à ajouter à `FactionRivalryArc`
- `tension`
- `grievance_attacker`, `grievance_defender`
- `trust`
- `weariness_attacker`, `weariness_defender`
- `cooldown_until_day`

### Tick
- appliquer décroissance tension/grief
- si `day < cooldown_until_day` ⇒ rien
- sinon : choisir une **réponse** (retaliate / hard_nonhostile / deescalate) via un score simple :

Exemple d’intuition de score (pas besoin de ML) :
- **score_retaliate** = grievance + tension + opportunity − weariness − external_threat_penalty
- **score_deescalate** = weariness + external_threat + low_opportunity + (tension_trop_haute_qui_devient_dangereuse)
- **score_hard_nonhostile** = grievance + low_opportunity + politique_interne

Puis tu spawns une offer correspondant à la réponse choisie.

---

Si tu veux, on peut maintenant faire un vrai “design pass” sur ton ArcManager en 2 étapes :

1) On définit **les variables minimales** (celles qui te donnent déjà 80% du résultat sans complexité).  
2) On définit une **liste de réponses** (5–8) + quelles quests/offers elles génèrent + quels effets elles appliquent (tension/trust/grief/weariness), et **les conditions terminales** (guerre, paix, alliance, fusion).

Dis-moi juste : tu veux que le tick d’arc soit **journalier** (comme ta sim) ou plutôt **hebdomadaire** (moins d’événements, plus lisible) ?

Moi:
Journalier

ChatGPT:
Journalier, c’est très bien — mais il faut absolument que le tick **ne génère pas automatiquement une vengeance**. Il doit *évaluer* la situation et parfois… ne rien faire, temporiser, négocier, ou même coopérer.

Voilà une proposition **simple à implémenter** dans ton ArcManager actuel (sans tout refondre), qui règle :
- l’arrêt d’une rivalité,
- son évolution,
- et des issues allant de **guerre d’extermination** à **alliance / fusion**,
sans que l’historique force l’escalade.

---

## 1) Changer le cœur : “pending_retaliation” → variables d’arc + décision quotidienne

Dans `FactionRivalryArc`, ajoute quelques métriques (valeurs bornées, faciles) :

- `tension` (0..100) : chaleur globale
- `grievance_A` et `grievance_B` (0..100) : “dette” ressentie par chaque camp
- `trust` (-100..+100) : confiance (peut remonter)
- `weariness_A`, `weariness_B` (0..100) : fatigue/coût interne
- `cooldown_until_day` : empêche spam (ex : min 2–5 jours entre “événements d’arc”)

L’**historique** (tes logs d’hostilité/retaliation) reste utile pour le récit, mais n’est plus la “mécanique”.

---

## 2) Tick journalier : décroissance + probabilité d’événement + choix d’une réponse

### A) Décroissance (anti-boucle)
Chaque jour, **si pas d’incident majeur** :
- `tension -= 1` (clamp 0..100)
- `grievance -= 0.5`
- `trust += 0.2` (jusqu’à un plafond)
- `weariness -= 0.3` (si pas en guerre)

Ça garantit qu’une rivalité peut “mourir” naturellement si rien n’alimente la boucle.

### B) Ne pas générer un event tous les jours
Même en tick journalier, fais une **chance** de produire une offer d’arc :

- `event_chance = clamp(0.05 + tension/250 - avg_weariness/300, 0.0, 0.35)`

Si tirage échoue → rien aujourd’hui (mais les valeurs continuent d’évoluer).

### C) Choisir une “réponse” (pas forcément hostile)
Tu définis 6–8 actions-types que l’arc peut produire sous forme d’offers :

**Hostiles**
- `RAID` (petit)
- `MAJOR_STRIKE` (gros)
- `DECLARE_WAR` (change d’état)

**Non-hostiles dures**
- `ULTIMATUM` (demande réparation)
- `SABOTAGE/ESPIONAGE` (pression sans bataille)

**Apaisement**
- `TRUCE_TALKS` (trêve)
- `REPARATIONS` (payer/rendre/compensation)
- `MEDIATION` (via 3e faction) *(optionnel mais puissant pour casser l’escalade)*

Chaque jour où un event est possible, tu scores ces options et tu prends la meilleure.

Exemple de scoring simple (tu peux faire ça en dur, pas besoin d’IA) :
- **Retaliate** score ↑ avec `grievance` + `tension` + `opportunity`, ↓ avec `weariness` + `external_threat`
- **De-escalate** score ↑ avec `weariness` + `external_threat` + “mauvaise opportunity”
- **Hard-non-hostile** score ↑ avec `grievance` mais ↓ si “tension déjà trop haute”

> `opportunity` peut être approximée au début (random pondéré par tier, proximité, forces), puis raffinée quand ta sim/logistique est prête.

---

## 3) Stades + conditions d’évolution (sans déterminisme)

Garde une machine à états, mais avec **transitions conditionnelles** :

- `INCIDENT` → `FEUD` si `tension >= 25`
- `FEUD` → `WAR` si `tension >= 60` ET `min(grievance_A, grievance_B) >= 40` ET `avg_weariness < 70`
- `WAR` → `TOTAL_WAR` si `tension >= 85` ET `trust <= -60` ET `avg_weariness < 80`
- `WAR/FEUD` → `TRUCE` si `avg_weariness >= 80` OU `external_threat` très haut
- `TRUCE` → `PEACE` si `tension <= 20` pendant `7 jours` ET `grievances <= 10`
- `PEACE` → `ALLIANCE` si `trust >= 40` pendant `14 jours` ET (ennemi commun OU intérêts convergents)
- `ALLIANCE` → `FUSION` si `trust >= 75` pendant `30 jours` ET (compatibilité/objectif commun) ET (ratio puissance très déséquilibré OU “union volontaire”)

> La “compatibilité” peut être ultra simple : tags de doctrine/axe/biome/diplomatie, ou juste une table de compatibilités par faction.

---

## 4) Quand arrêter l’arc (RESOLVED) : critères terminaux

Tu veux éviter l’escalade *infinie* → il faut des fins claires :

### Fins “dures”
- **Extermination** : faction sous seuil (territoires/armées/pop) → `ANNIHILATED`
- **Capitulation / vassalisation** : un camp a `weariness` très haut + ratio de puissance défavorable → `SUBJUGATED`
- **Annexion** : contrôle de POI clés + victoire → `ANNEXED`

### Fins “douces”
- **Paix durable** : `PEACE` stable X jours → `RESOLVED_PEACE`
- **Alliance stable** : `ALLIANCE` stable X jours → `RESOLVED_ALLIANCE`
- **Fusion** : `MERGED` terminal

### Extinction naturelle
- Si `tension == 0` et `grievances == 0` pendant `N jours` → `RESOLVED_FORGOTTEN`

---

## 5) Le point crucial : comment une action hostile “paie” la dette (sinon boucle)

Quand une faction réussit une représaille, tu dois **réduire sa grievance**, sinon elle reste “en dette” et retape à l’infini.

Ex :
- `RAID` réussi :
  - grievance du camp qui frappe **-15**
  - tension **+10**
  - grievance du camp frappé **+10**
  - trust **-5**
  - weariness du camp qui frappe **+5**
- `TRUCE_TALKS` réussi :
  - tension **-15**
  - trust **+10**
  - grievances **-10**
- `REPARATIONS` :
  - grievances du receveur **-20**
  - trust **+5**
  - tension **-10**

Ça crée un système où “frapper” peut satisfaire (donc calmer *à court terme*) mais dégrade trust et augmente fatigue, ce qui pousse ensuite vers trêve/paix.

---

## 6) Intégration avec tes quêtes LOYAL/NEUTRAL/TRAITOR

Chaque offer d’arc doit préciser `arc_action_type`. Dans `on_quest_resolution_choice(inst, choice)` tu appliques une matrice d’effets **selon l’action** :

- Sur une quête de `RAID` :
  - LOYAL = l’attaque réussit (effets hostiles + “paiement” de grievance)
  - NEUTRAL = sabotage limité (moins de tension, moins de paiement)
  - TRAITOR = tu aides l’autre camp (trust bascule / grief inversé)

- Sur `TRUCE_TALKS` :
  - LOYAL = trêve signée (gros -tension, +trust)
  - NEUTRAL = statu quo (petit -tension)
  - TRAITOR = trêve sabotée (tension +, trust --)

C’est ça qui te permet d’aller vers alliance/fusion *même après des coups*.

---

### Si tu veux un “MVP” en 2 heures de code
1) Ajouter les variables (`tension/grievance/trust/weariness/cooldown`)  
2) Tick journalier avec décroissance + chance d’event + cooldown  
3) 4 actions seulement au début : `RAID`, `ULTIMATUM`, `TRUCE_TALKS`, `IGNORE`  
4) Matrices d’effets sur `quest_resolved` pour ces 4 actions  
5) Conditions de fin : oubli / paix / guerre totale / annihilation

Ensuite tu ajoutes `ALLIANCE` puis `FUSION` quand tu es content de la stabilité.

Si tu veux, je peux te proposer **des valeurs par défaut** (seuils + deltas) qui donnent un comportement “organique” (pas trop belliqueux, mais capable de spiraler en guerre totale quand les conditions s’alignent).

Moi:
Chaque faction va aussi avoir une personalité, je pense qu'il faut prendre ca en compte dans le calcule.
Par exemple, une faction pacifique fait baisser la grievance plus vite, a l'inverse d'une belliqueuse.
Une expansionniste aura un cout pour la guerre moins elevée etc

ChatGPT:
Oui — la personnalité doit entrer **à deux endroits** :

1) dans la **physique** de l’arc (comment tension/grievance/trust/weariness évoluent naturellement chaque jour),  
2) dans la **prise de décision** (quelles réponses la faction privilégie à situation égale).

Et c’est exactement ce qui te permettra d’avoir des arcs qui peuvent se calmer, se retourner, ou au contraire dégénérer.

---

## 1) Modèle de personnalité simple (data-driven)

Je te conseille 5–7 axes max, sinon tu vas te noyer. Par exemple :

- **aggression** (0..1) : goût pour l’action hostile
- **vengefulness** (0..1) : besoin de “payer la dette” (grievance)
- **diplomacy** (0..1) : préférence pour trêves/accords
- **risk_aversion** (0..1) : prudence, peur des coûts
- **expansionism** (0..1) : intérêt structurel à la guerre/prise de territoire
- **honor** (0..1) : valeur accordée aux traités / “sauver la face”
- (optionnel) **cunning** (0..1) : préférence pour sabotage/espionnage plutôt que frontal

Tu peux stocker ça dans un `FactionPersonalityProfile.tres` par faction, ou via ton système de tags.

---

## 2) La personnalité modifie les “deltas” journaliers (anti-escalade naturelle)

### A) Décroissance de grievance (ton exemple pacifique/belliqueux)
Au lieu d’un `grievance -= 0.5` fixe :

- `grievance_decay = base_decay * (1.6 - 0.9*vengefulness) * (0.8 + 0.6*diplomacy)`
  - pacifique/diplomate → grief retombe vite
  - vindicatif → retombe lentement

### B) Coût/fatigue de guerre (ton exemple expansionniste)
Au lieu d’un `weariness += +5` fixe sur une action hostile :

- `weariness_gain = base_weariness * (0.7 + 0.6*risk_aversion) * (1.1 - 0.5*expansionism)`
  - expansionniste → “coût perçu” plus bas (mais pas zéro)
  - prudent → fatigue grimpe vite

### C) Récupération de trust
- `trust_recovery = base_trust * (0.6 + 0.8*diplomacy) * (0.9 - 0.4*aggression)`

👉 Résultat : même avec historique hostile, une faction pacifique va **laisser la température redescendre** plus naturellement, sans que tu forces une boucle.

---

## 3) La personnalité modifie le choix de réponse (scoring)

Tu gardes ton choix d’action par score, mais tu ajoutes un **bias personnalité**.

Exemple pour 4 actions MVP : `RAID`, `ULTIMATUM`, `TRUCE_TALKS`, `IGNORE`.

### Score “RAID”
```
score_raid =
  + 1.2*grievance
  + 0.8*tension
  + 0.6*opportunity
  - 1.0*weariness
  + 25*aggression
  + 20*expansionism
  + 15*vengefulness
  - 25*risk_aversion
  - 15*diplomacy
```

### Score “TRUCE_TALKS”
```
score_truce =
  + 0.8*weariness
  + 0.5*external_threat
  - 0.6*grievance
  - 0.4*tension
  + 30*diplomacy
  + 15*honor
  + 10*risk_aversion
  - 20*aggression
  - 10*vengefulness
```

### Score “ULTIMATUM” (pression sans attaque)
Très utile pour casser la boucle “vengeance automatique” :
```
score_ultimatum =
  + 0.9*grievance
  + 0.4*tension
  + 15*honor
  + 10*diplomacy
  + 10*risk_aversion
  - 10*aggression
```

### Score “IGNORE”
Option ultra importante en journalier :
```
score_ignore =
  + 0.9*weariness
  - 0.6*opportunity
  + 20*risk_aversion
  + 10*diplomacy
  - 10*vengefulness
```

---

## 4) La personnalité modifie aussi les seuils d’évolution / fin

Tu peux rendre les transitions **variables par faction**.

### Exemple : seuil de passage en “WAR”
Au lieu de `tension >= 60` fixe :

- faction belliqueuse : `war_threshold = 50`
- faction pacifique : `war_threshold = 75`

Formule simple :
`war_threshold = 70 - 20*aggression - 10*expansionism + 15*diplomacy`

### Acceptation d’alliance / fusion
- alliance possible si `trust` monte, mais le seuil dépend :
`alliance_threshold = 50 + 20*vengefulness - 25*diplomacy - 10*honor`

Fusion (plus rare) :
- nécessite `trust` haut **et** `honor` ou intérêt expansionniste (confédération)
- ou “dominant + vassal” (expansionism haut côté dominant, risk_aversion haut côté dominé)

---

## 5) Exemples concrets de comportements

### Faction pacifique (diplomacy haute, aggression basse, vengefulness basse)
- grievance retombe vite
- choisit souvent `ULTIMATUM` / `TRUCE_TALKS` / `IGNORE`
- peut passer d’hostilité à alliance si ennemi commun / médiation

### Faction belliqueuse (aggression + vengefulness hautes)
- grievance retombe lentement
- préfère `RAID`/`MAJOR_STRIKE`
- escalade plus facilement vers WAR/TOTAL_WAR

### Faction expansionniste (expansionism haut)
- “coût perçu” de guerre plus bas
- tend à déclarer guerre si opportunité (frontières, POI, faiblesse)
- mais peut aussi accepter “fusion/vassalisation” comme issue logique

---

## 6) Implémentation minimaliste dans ton ArcManager

- `ArcManager.tick_day()` :
  1) pour chaque arc : appliquer **decay** avec multiplicateurs personnalité (par camp)
  2) si cooldown OK et tirage event OK :
     - calculer scores d’actions **par camp** en injectant personnalité
     - choisir l’action gagnante (ou une action “globale arc” si tu veux rester simple)
     - spawn l’offer correspondante avec `context.arc_action_type`
  3) sur `quest_resolved` : appliquer la matrice d’effets + “paiement de grievance”

---

Si tu veux, on peut faire la prochaine étape très concrète : tu me dis quelles **personnalités** tu veux au minimum (ex : Pacifique, Pragmatique, Belliqueuse, Expansionniste, Fanatique), et je te propose une table de valeurs par archétype (axes 0..1) + les multiplicateurs (decay/grief/weariness) + les poids de scoring déjà calibrés pour que ça “vive” en journalier sans spam ni escalade inévitable.

ChatGPT:
Carrément. La personnalité devient ton “anti-boucle” naturel : elle influence **l’inertie** (decay) *et* les **préférences d’action** (scoring). Je te propose un cadre **léger** qui marche bien en tick journalier.

## 1) Axes de personnalité (0..1) + un bonus utile pour fusion
Garde ça simple :

- `aggression` : tendance à attaquer
- `vengefulness` : rancune (grievance retombe lentement)
- `diplomacy` : tendance à négocier / apaiser
- `risk_aversion` : peur des coûts (fatigue pèse plus)
- `expansionism` : intérêt structurel à la guerre/territoire
- `integrationism` : propension alliance → fusion (culture/idéologie “assimilatrice”)

## 2) Effets “physiques” journaliers (ça casse l’escalade automatique)

### Décroissance de grievance (pacifique vs belliqueuse)
```text
grievance_decay = base * (1.4 - 0.9*vengefulness) * (0.8 + 0.6*diplomacy)
```
- pacifique/diplomate → la dette retombe vite
- vindicative → elle colle

### Coût perçu de la guerre (expansionniste)
```text
weariness_gain = base * (0.7 + 0.6*risk_aversion) * (1.1 - 0.5*expansionism)
```
- expansionniste → “paie” moins de fatigue pour le même acte
- prudente → fatigue grimpe vite ⇒ pousse trêve/ignore

### Remontée de trust (pour alliance/fusion)
```text
trust_recovery = base * (0.6 + 0.9*diplomacy) * (0.9 - 0.4*aggression)
```

> Avec juste ces 3 lignes, tu peux avoir des rivalités qui **s’éteignent** sans nouvelle provocation.

## 3) Décision quotidienne : personnalité = biais sur le score des actions

Tu calcules des scores pour quelques actions (MVP : `RAID`, `ULTIMATUM`, `TRUCE_TALKS`, `IGNORE`) et tu ajoutes un biais :

- `RAID` aime `aggression + vengefulness + expansionism`, déteste `risk_aversion + diplomacy`
- `TRUCE_TALKS` aime `diplomacy + risk_aversion`, déteste `aggression + vengefulness`
- `ULTIMATUM` est le “pont” : pression sans escalade (super utile)
- `IGNORE` est vital en tick journalier (sinon tu spams des arcs)

## 4) Archétypes prêts à l’emploi (profils 0..1)
Tu peux démarrer avec ça :

| Archétype | aggression | vengefulness | diplomacy | risk_aversion | expansionism | integrationism |
|---|---:|---:|---:|---:|---:|---:|
| Pacifique | 0.15 | 0.20 | 0.85 | 0.70 | 0.20 | 0.60 |
| Pragmatique | 0.35 | 0.35 | 0.55 | 0.50 | 0.40 | 0.40 |
| Belliqueux | 0.80 | 0.70 | 0.20 | 0.30 | 0.60 | 0.20 |
| Expansionniste | 0.65 | 0.45 | 0.30 | 0.35 | 0.90 | 0.50 |
| Fanatique | 0.75 | 0.85 | 0.10 | 0.20 | 0.50 | 0.05 |
| Assimilateur (fusion) | 0.45 | 0.25 | 0.60 | 0.45 | 0.55 | 0.90 |

- **Pacifique** : grief descend vite, fatigue pèse beaucoup ⇒ trêve/ultimatum/ignore fréquents.
- **Belliqueux/Fanatique** : grief colle, fatigue “compte moins” ⇒ escalade plus probable.
- **Assimilateur** : plutôt diplomate + très intégrateur ⇒ alliance stable puis fusion possible.

## 5) Alliance / fusion sans “magie” : conditions + personnalité
Exemples de règles simples :

- **Alliance possible** si `trust >= 40` ET `tension <= 35` pendant X jours  
  et bonus si `(integrationism_A + integrationism_B) élevé` ou `external_threat` élevé.
- **Fusion possible** si `trust >= 75` pendant 30 jours ET `tension <= 15`  
  et `integrationism` élevé côté au moins une faction, + compatibilité (tags/axes/doctrine).

Tu peux aussi autoriser une **fusion “domination”** (vassalisation → fusion) si :
- ratio puissance très déséquilibré,
- fatigue très haute du dominé,
- et `integrationism` haut du dominant.

---

Si tu me dis **quels “types” de factions** tu as (orcs tribaux, empire humain, ordre religieux, nécromants, etc.) et quels axes (Tech/Magie/Nature/Divin/Corruption) tu utilises déjà dans leurs identités, je te propose une table de profils “cohérents lore” + les pondérations de score calibrées pour que, en journalier, tu voies :
- des vendettas qui meurent,
- des guerres qui partent parfois en total war,
- et des réconciliations/alliance/fusion quand le contexte s’y prête.

Moi:
Actuellement, on a un score de relation de chaque faction envers les autres. Il faut que ca soit pris en compte dans le calcul et il faut que ca evolue avec les actions. Il faut aussi que la faction ai un score de relation avec chacun des axes (Tech/Magie/Nature/Divin/Corruption).
Il faut prevoir la liste d'action/quete qui vont decouler des calculs (tu en as deja parler). Je pense qu'on pourra conserver tous les score que tu calcules dans une seule structure de donnés (FactionRelationScore) on mettra ensuite ca dans un dictionnaire faction_id ->FactionRelationScore. Chaque faction aura ce dictionnaire. Les types de personnalités, les races (procedurales ou non) et les axes (il n'y en a que 5 et tu les as cité) sont dans les documents que je t'ai donné au depart. Mais en gros, c'est procedurale lors de la creation et ensuite le monde evoluera vers... je ne sais pas. Mais on peut avoir des orcs pacifiques dans une societé feodal (type moyen age européen) et en rejet de la magie.
Si les races sont classique (au moins dans une v1) le reste ne l'est pas forcément.

ChatGPT:
Oui — ton **score de relation inter-factions** doit devenir *l’axe principal* (et il doit évoluer), et les **axes (Tech/Magie/Nature/Divin/Corruption)** doivent influencer à la fois :

1) la relation “A ↔ B” (compatibilité idéologique / friction),
2) le choix des actions d’arc,
3) l’évolution possible (paix, alliance, fusion, extermination).

Les docs vont clairement dans ce sens : l’IA diplomatique est influencée par **personnalité + axes dominants + puissance relative + proximité** fileciteturn3file1, et les axes ont des **interactions fortes** (Nature vs Techno, Divin vs Corruption, etc.) fileciteturn3file2turn3file3. Tu as déjà la mécanique “réputation/relations” qui déclenche des seuils ally/enemy fileciteturn3file8, donc on s’appuie dessus.

---

## 1) Data model : `FactionRelationScore` directionnel + profil d’axes par faction

### A) Par faction : profil d’axes
Chaque faction a **un état par axe** (les 5) :
- `axis_level[axis] : 0..5` (progression par bâtiments/choix/conquêtes, et dominance possible) fileciteturn3file3  
- `axis_affinity[axis] : -100..+100` (**opinion/adhésion** : “rejette la magie”, “vénère le divin”, “tolère techno”, etc.)

Ça colle à ton besoin “relation avec chacun des axes” et ça reste compatible avec le fait que les factions peuvent être **multi-axes** fileciteturn3file3.

### B) Par faction : dictionnaire vers les autres (`faction_id -> FactionRelationScore`)
Tu peux garder ton idée : *chaque faction possède* un dictionnaire “sa vision des autres”.

Je te propose un `FactionRelationScore` **minimal** (les “scores”, pas l’état d’arc) :

- `relation` : -100..+100 (ton score existant / “réputation”)
- `trust` : -100..+100 (remonte avec le temps + actes positifs)
- `grievance` : 0..100 (rancune / dette perçue)
- `tension` : 0..100 (risque d’incident/violence)
- `weariness` : 0..100 (fatigue de guerre vs ce rival)
- `last_event_day` / `cooldown_until_day`

> Tout ce qui est “stade de rivalité / arc_id / war_state” je le laisserais au **ArcManager** (sinon tu dupliques et tu te bats avec la cohérence).

---

## 2) Comment les axes influencent la relation A→B (sans figer le monde)

Tu veux “des orcs pacifiques féodaux anti-magie” : donc la race ne doit pas figer l’idéologie. La bonne approche : **race = faible biais**, axes + personnalité = vrai moteur.

### A) Calculer une “friction idéologique” A→B
Exemple (simple, efficace) :

- Pour chaque axe `X` :
  - plus `B.axis_level[X]` est haut, plus ça “irrite” ou “attire” A selon `A.axis_affinity[X]`
  - `axis_term_X = (A.axis_affinity[X] / 100) * (B.axis_level[X] / 5)`

Puis :
- `axis_compat = sum(axis_term_X)`  (≈ entre -5 et +5)
- `axis_bias = axis_compat * 15` (converti en points de relation)

Et tu appliques ça comme **baseline** vers lequel `relation` dérive lentement.

Ça exploite tes interactions d’axes (ex : Divin vs Corruption, Nature vs Techno…) fileciteturn3file2turn3file3 et la logique “réaction aux axes” dans l’IA fileciteturn3file1.

### B) Drift quotidien (très important)
Chaque jour, si pas d’incident majeur :
- `relation += (baseline_relation - relation) * 0.01` (petit rappel)
- `tension -= decay`
- `grievance -= decay`
- `trust += recover`
- `weariness -= recover`

👉 C’est ça qui empêche l’historique de “verrouiller” une escalade éternelle.

---

## 3) Les actions d’arc : une liste finie (offers/quests) choisie par scoring

Tu voulais “prévoir la liste d’action/quête”. Je te propose une **bibliothèque d’actions d’arc** qui devient ton catalogue d’offers “arc_rivalry”.

Chaque action :
- a des **préconditions** (stade, relation, tension, trust, grievance, axes…)
- génère une **QuestInstance** (offer) avec `context.arc_action_type`
- applique des **deltas** (sur relation/trust/grievance/tension/weariness + parfois axes)

### Actions “incident / feud” (évite boucle vengeance)
1) **EXCUSES / ENQUÊTE** (diplomatie soft)  
2) **ULTIMATUM** (pression sans violence)  
3) **REPARATIONS / TRIBUTE** (paie la dette)  
4) **BORDER PATROL** (défensif, baisse tension si réussite)  
5) **RAID** (petit hostile, “paie” grievance mais baisse trust)

### Actions “war”
6) **SKIRMISH** (escarmouche)  
7) **SABOTAGE** (ciblé sur un axe : usine techno / nexus magique / temple / nid corrompu / forêt sacrée)  
8) **SIEGE / CAPTURE_POI** (impact carte via POI, cohérent avec ton système POI transformables) fileciteturn3file6  
9) **ASSASSINATE_CHAMPION** (N3/N4 style) fileciteturn3file9

### Actions “désescalade”
10) **TRUCE_TALKS** (trêve)  
11) **PRISONER_EXCHANGE**  
12) **MEDIATION** (3e faction, très bon contre l’escalade automatique)

### Actions “alliance / fusion”
13) **JOINT_CRISIS_RESPONSE** (ennemi commun : corruption/démons → alliances temporaires, cohérent IA) fileciteturn3file1  
14) **TECH/MAGIC SHARING** (coopération d’axe, fait évoluer les affinités)  
15) **UNION_TREATY** (alliance formelle)  
16) **INTEGRATION_CAMPAIGN** (fusion : harmonisation lois/armée, purge extrémistes, administration commune)

> Tu peux même t’appuyer sur ton catalogue d’événements : “coalition spontanée”, “alliance apocalyptique”, etc., comme accélérateurs d’alliance/fusion fileciteturn3file9turn3file7.

---

## 4) Faire évoluer relation + axes avec les actions (et pas que l’inverse)

### A) Deltas sur relation (les deux sens, mais pas symétriques)
Quand A fait un raid sur B :
- A→B : grievance -X (A estime avoir “rendu”), weariness +, tension +, trust -
- B→A : grievance +X (B veut se venger), tension +, trust --, relation --

Ça évite la boucle “je frappe donc je refrappe” : **l’attaquant se calme** (sa grievance baisse), mais **le victime s’énerve**.

### B) Deltas sur axes (niveau + affinité)
Exemples :
- **Sabotage d’un Nexus (Magie)** :  
  - B.axis_level[Magie] peut reculer (temporaire) + B.axis_affinity[Magie] peut monter (“on doit renforcer la magie”)  
  - A.axis_affinity[Magie] peut baisser (“ça confirme que c’est dangereux”)  
- **Coop techno/magie** :  
  - A.axis_affinity[Magie] monte un peu, B.axis_affinity[Tech] monte un peu (effet “acculturation”)  
- **Crise Corruption** :  
  - beaucoup de factions gagnent une “tolérance à coopérer” temporaire (alliances de survie), exactement comme décrit fileciteturn3file1

Les axes sont “au cœur de l’évolution des factions” et influencent les comportements fileciteturn3file3 : donc c’est cohérent que les quêtes laissent une trace sur axes + relations.

---

## 5) Seuils & intégration avec ton système actuel (enemy/ally + tags)
Tu as déjà le pattern “réputation >= 100 → ally, <= -100 → enemy” fileciteturn3file8 et des tags `war_*` / `peace` lors de déclaration de guerre/paix fileciteturn3file14.

Donc :
- si `relation(A→B)` et `relation(B→A)` passent sous un seuil + `tension` haut → **ArcManager déclenche WAR** (tag monde, state faction)
- si `tension` bas durablement + `trust` remonte → **ArcManager déclenche PEACE**
- si `trust` très haut + compatibilité/pression externe → **ALLIANCE**
- si alliance stable + `integrationism` (personnalité) + compatibilité d’axes → **FUSION**

Et surtout : la rivalité peut aussi **s’éteindre** si tension/grievance retombent à 0 pendant N jours.

---

Si tu veux qu’on enchaîne proprement, ma proposition est :

1) On fixe les **bornes** (relation -100..100, trust -100..100, grievance/tension/weariness 0..100) et les **decays journaliers**.  
2) On définit 10–12 `arc_action_type` “MVP” (parmi la liste ci-dessus) avec leurs préconditions + deltas.  
3) On branche ça sur ton pipeline existant `QuestInstance.context + resolve(choice)` pour que LOYAL/NEUTRAL/TRAITOR appliquent des deltas différents (et donc puissent mener à paix/alliance/fusion, pas seulement escalade).

Tu veux qu’on commence par écrire la **structure GDScript** de `FactionRelationScore` + `FactionAxisProfile`, ou par lister les **12 actions MVP** avec leurs préconditions/deltas ?

Moi:
Appelons FactionAxisProfile plutot FactionProfile.
On va avoir le FactionProfile qui aura les score de personalité et les score d'afinité par axe
Les score par axes seront dans un dictionnaire (plus facile pour une recherche dynamique) et seront sur une echelle de -100 a +100
Les scores de personnalités seront sur un float de 0 a 1, ils serviront de multiplicateur pour les scores calculer. Ils seront aussi dans un dictionnaire (pourquoi pas le meme que les affinité d'axe, ca permet une recherche vraiment dynamique).
Pour les regles de generation sur les affinités avec les axes, il faut au moins un axe superieur a 50 et un autre inferieur a -20.
Il faudrait que la somme soient compris dans une fourchette (20 a 80, je te laisse me proposer une fourchette coherente qui créera de la dynamique dans le monde).
Pour les score de personnalité (regarde ce que tu as decrit plus haut). Ce sera un template par personnalité, mais on peut avoir une legere variation (de -0.1 a + 0.2, qu'en dis tu?)
Ecrivons les structure de donnée pour FactionRelationScore + FactionProfile.

ChatGPT:
Parfait. Je te propose :

- **`FactionProfile`** : 2 dictionnaires (`axis_affinity` et `personality`), avec une méthode de lookup “dynamique” (qui cherche dans les deux).
- **`FactionRelationScore`** : les scores directionnels A→B (relation/trust/grievance/tension/weariness + cooldown).

### Fourchette cohérente pour la somme des affinités d’axes
Avec 5 axes en `[-100..100]` + contrainte “≥1 axe > 50” et “≥1 axe < -20”, une somme trop large dilue l’identité, et trop serrée force des profils similaires.

Je te propose : **somme ∈ [20 .. 90]**  
- `>= 20` : évite les factions “anti-tout” (trop neutres/négatives) malgré un axe très positif.  
- `<= 90` : évite les factions “pro-tout sauf un petit rejet”, et garde des tensions idéologiques.

Tu peux évidemment rendre ça configurable.

### Variation personnalité
Ton `[-0.1 .. +0.2]` marche bien si tu veux un monde un peu plus “caractérisé” (biais vers le haut). Je l’implémente tel quel, avec clamp `0..1`.

---

## `FactionProfile.gd`

```gdscript
# Godot 4.x
class_name FactionProfile
extends RefCounted

# --- Keys (StringName) ---
const AXIS_TECH: StringName = &"axis.tech"
const AXIS_MAGIC: StringName = &"axis.magic"
const AXIS_NATURE: StringName = &"axis.nature"
const AXIS_DIVINE: StringName = &"axis.divine"
const AXIS_CORRUPTION: StringName = &"axis.corruption"

const ALL_AXES: Array[StringName] = [
	AXIS_TECH, AXIS_MAGIC, AXIS_NATURE, AXIS_DIVINE, AXIS_CORRUPTION
]

const PERS_AGGRESSION: StringName = &"pers.aggression"
const PERS_VENGEFULNESS: StringName = &"pers.vengefulness"
const PERS_DIPLOMACY: StringName = &"pers.diplomacy"
const PERS_RISK_AVERSION: StringName = &"pers.risk_aversion"
const PERS_EXPANSIONISM: StringName = &"pers.expansionism"
const PERS_INTEGRATIONISM: StringName = &"pers.integrationism"

const ALL_PERSONALITY_KEYS: Array[StringName] = [
	PERS_AGGRESSION,
	PERS_VENGEFULNESS,
	PERS_DIPLOMACY,
	PERS_RISK_AVERSION,
	PERS_EXPANSIONISM,
	PERS_INTEGRATIONISM
]

# --- Generation constraints ---
const AXIS_MIN: int = -100
const AXIS_MAX: int = 100

const AXIS_REQUIRED_POSITIVE_GT: int = 50
const AXIS_REQUIRED_NEGATIVE_LT: int = -20

# Proposed coherent range for sum(axis_affinity.values())
const AXIS_SUM_MIN: int = 20
const AXIS_SUM_MAX: int = 90

# Personality variation around template values
const PERS_VARIATION_MIN: float = -0.1
const PERS_VARIATION_MAX: float = 0.2

# --- Data ---
# -100..100
var axis_affinity: Dictionary[StringName, int] = {}

# 0..1
var personality: Dictionary[StringName, float] = {}

func _init() -> void:
	# Defaults (optional): set everything to 0 / 0.5 if you want stable lookups
	for a in ALL_AXES:
		axis_affinity[a] = 0
	for k in ALL_PERSONALITY_KEYS:
		personality[k] = 0.5

# ---- Axis helpers ----
func set_axis_affinity(axis: StringName, value: int) -> void:
	axis_affinity[axis] = clampi(value, AXIS_MIN, AXIS_MAX)

func get_axis_affinity(axis: StringName, default_value: int = 0) -> int:
	return axis_affinity.get(axis, default_value)

func axis_sum() -> int:
	var s := 0
	for a in ALL_AXES:
		s += int(axis_affinity.get(a, 0))
	return s

func validate_axis_rules() -> bool:
	var has_pos := false
	var has_neg := false
	for a in ALL_AXES:
		var v: int = int(axis_affinity.get(a, 0))
		if v > AXIS_REQUIRED_POSITIVE_GT:
			has_pos = true
		if v < AXIS_REQUIRED_NEGATIVE_LT:
			has_neg = true

	var s := axis_sum()
	return has_pos and has_neg and s >= AXIS_SUM_MIN and s <= AXIS_SUM_MAX

# ---- Personality helpers ----
func set_personality(key: StringName, value: float) -> void:
	personality[key] = clampf(value, 0.0, 1.0)

func get_personality(key: StringName, default_value: float = 0.5) -> float:
	return float(personality.get(key, default_value))

# Applies small random variation to a template (Dictionary[StringName, float] of 0..1 values)
func apply_personality_template(template: Dictionary[StringName, float], rng: RandomNumberGenerator) -> void:
	for k in ALL_PERSONALITY_KEYS:
		var base := clampf(float(template.get(k, 0.5)), 0.0, 1.0)
		var delta := rng.randf_range(PERS_VARIATION_MIN, PERS_VARIATION_MAX)
		set_personality(k, base + delta)

# ---- Dynamic lookup (optional): one entry point for “search dynamique” ----
# If you pass an axis key, returns int as float (e.g. 42.0). If personality key, returns 0..1 float.
func get_score_dynamic(key: StringName, default_value: float = 0.0) -> float:
	if axis_affinity.has(key):
		return float(axis_affinity[key])
	if personality.has(key):
		return float(personality[key])
	return default_value
```

---

## `FactionRelationScore.gd`

```gdscript
# Godot 4.x
class_name FactionRelationScore
extends RefCounted

const REL_MIN: int = -100
const REL_MAX: int = 100

const TRUST_MIN: int = -100
const TRUST_MAX: int = 100

const METER_MIN: float = 0.0
const METER_MAX: float = 100.0

# Directional: this is "from owner faction" -> "to target faction"
var target_faction_id: StringName

# Your existing “relation” score (reputation / opinion)
var relation: int = 0          # -100..100
var trust: int = 0             # -100..100

var grievance: float = 0.0     # 0..100
var tension: float = 0.0       # 0..100
var weariness: float = 0.0     # 0..100

var last_event_day: int = -999999
var cooldown_until_day: int = -999999

func _init(target_id: StringName = &"") -> void:
	target_faction_id = target_id

func clamp_all() -> void:
	relation = clampi(relation, REL_MIN, REL_MAX)
	trust = clampi(trust, TRUST_MIN, TRUST_MAX)
	grievance = clampf(grievance, METER_MIN, METER_MAX)
	tension = clampf(tension, METER_MIN, METER_MAX)
	weariness = clampf(weariness, METER_MIN, METER_MAX)

func apply_delta(
	d_relation: int = 0,
	d_trust: int = 0,
	d_grievance: float = 0.0,
	d_tension: float = 0.0,
	d_weariness: float = 0.0
) -> void:
	relation += d_relation
	trust += d_trust
	grievance += d_grievance
	tension += d_tension
	weariness += d_weariness
	clamp_all()

func is_on_cooldown(current_day: int) -> bool:
	return current_day < cooldown_until_day

func set_cooldown(current_day: int, days: int) -> void:
	cooldown_until_day = current_day + max(days, 0)
```

---

Si tu veux, prochaine étape : je te propose une fonction de **génération procédurale** des `axis_affinity` qui garantit *à coup sûr* :
- 1 axe > 50,
- 1 axe < -20,
- somme dans `[20..90]`,
et qui garde une distribution intéressante (pas juste “un gros +, un petit -, le reste 0”).

Moi:
Oui s'il te plait, fait :
une fonction de génération procédurale des axis_affinity qui garantit à coup sûr :

1 axe > 50,

1 axe < -20,

somme dans [20..90],
et qui garde une distribution intéressante (pas juste “un gros +, un petit -, le reste 0”)

ChatGPT:
Voici une **fonction de génération procédurale** (GDScript Godot 4) qui produit `axis_affinity` et garantit **à coup sûr** :

- au moins **1 axe > 50**
- au moins **1 axe < -20**
- **somme** des 5 axes dans **[20..90]**
- une distribution “vivante” : **au moins 2 des 3 axes restants** ont une magnitude significative (pas juste 0/0/0)

À coller directement dans `FactionProfile.gd`.

```gdscript
# --- In FactionProfile.gd ---

static func generate_axis_affinity(rng: RandomNumberGenerator) -> Dictionary[StringName, int]:
	# We retry because we want hard guarantees ("à coup sûr") with a nice distribution.
	for attempt in range(60):
		var d: Dictionary[StringName, int] = {}

		# 1) Pick one strong positive axis and one strong negative axis
		var axes := ALL_AXES.duplicate()
		var pos_axis: StringName = axes[rng.randi_range(0, axes.size() - 1)]
		axes.erase(pos_axis)
		var neg_axis: StringName = axes[rng.randi_range(0, axes.size() - 1)]
		axes.erase(neg_axis)
		var rem_axes: Array[StringName] = axes

		# Strong anchors (guarantee constraints)
		# Keep some room for later adjustments.
		d[pos_axis] = rng.randi_range(60, 92)     # > 50 guaranteed, room up to 100
		d[neg_axis] = -rng.randi_range(25, 80)    # < -20 guaranteed, room down to -100

		# 2) Generate remaining axes with a "natural" distribution (not all near 0)
		# We enforce at least 2 out of the 3 remaining axes with |value| >= 15.
		var ok_distribution := false
		for _resample in range(30):
			var strong_count := 0
			for a in rem_axes:
				var v := int(round(rng.randfn(0.0, 32.0))) # normal-ish around 0

				# Push away from 0 sometimes, to avoid "0,0,0"
				if abs(v) < 8:
					v += (rng.randf() < 0.5 ? -1 : 1) * rng.randi_range(10, 22)

				# Avoid extremes too often (keeps room for sum-adjust)
				v = clampi(v, -75, 75)
				d[a] = v

				if abs(v) >= 15:
					strong_count += 1

			if strong_count >= 2:
				ok_distribution = true
				break

		if not ok_distribution:
			continue

		# 3) Choose a target sum inside [AXIS_SUM_MIN..AXIS_SUM_MAX] and adjust values to hit it
		var target_sum := rng.randi_range(AXIS_SUM_MIN, AXIS_SUM_MAX)
		var current_sum := _axis_sum_dict(d)
		var diff := target_sum - current_sum

		# Per-axis allowed ranges (to preserve the >50 and <-20 guarantees)
		var min_allowed: Dictionary[StringName, int] = {}
		var max_allowed: Dictionary[StringName, int] = {}
		for a in ALL_AXES:
			min_allowed[a] = AXIS_MIN
			max_allowed[a] = AXIS_MAX
		min_allowed[pos_axis] = 51
		max_allowed[pos_axis] = 100
		min_allowed[neg_axis] = -100
		max_allowed[neg_axis] = -21

		# Adjustment loop: distribute diff across axes with available headroom.
		var iter := 0
		while diff != 0 and iter < 250:
			iter += 1

			var candidates: Array[StringName] = []
			for a in ALL_AXES:
				var v: int = d.get(a, 0)
				if diff > 0 and v < max_allowed[a]:
					candidates.append(a)
				elif diff < 0 and v > min_allowed[a]:
					candidates.append(a)

			if candidates.is_empty():
				break

			# Prefer adjusting non-anchor axes most of the time (keeps identity stable)
			var chosen: StringName
			if rng.randf() < 0.75:
				var non_anchor: Array[StringName] = []
				for a in candidates:
					if a != pos_axis and a != neg_axis:
						non_anchor.append(a)
				chosen = non_anchor.is_empty() ? candidates[rng.randi_range(0, candidates.size() - 1)]
					: non_anchor[rng.randi_range(0, non_anchor.size() - 1)]
			else:
				chosen = candidates[rng.randi_range(0, candidates.size() - 1)]

			var headroom := 0
			if diff > 0:
				headroom = max_allowed[chosen] - d[chosen]
			else:
				headroom = d[chosen] - min_allowed[chosen]

			if headroom <= 0:
				continue

			var step_mag := min(abs(diff), headroom, rng.randi_range(3, 14))
			var step := (diff > 0) ? step_mag : -step_mag

			d[chosen] += step
			diff -= step

		# 4) Final validation (hard guarantees)
		var final_sum := _axis_sum_dict(d)
		if final_sum < AXIS_SUM_MIN or final_sum > AXIS_SUM_MAX:
			continue
		if d[pos_axis] <= AXIS_REQUIRED_POSITIVE_GT:
			continue
		if d[neg_axis] >= AXIS_REQUIRED_NEGATIVE_LT:
			continue

		# Extra "interesting distribution" check:
		# At least 3 axes with |value| >= 12 (so it's not "one big +, one -, and dust").
		var interesting := 0
		for a in ALL_AXES:
			if abs(int(d[a])) >= 12:
				interesting += 1
		if interesting < 3:
			continue

		# Clamp (safety) and return
		for a in ALL_AXES:
			d[a] = clampi(int(d[a]), AXIS_MIN, AXIS_MAX)
		return d

	# Fallback (should basically never happen): deterministic-ish profile
	var fallback: Dictionary[StringName, int] = {}
	for a in ALL_AXES:
		fallback[a] = 0
	fallback[AXIS_MAGIC] = 70
	fallback[AXIS_TECH] = -30
	fallback[AXIS_NATURE] = 20
	fallback[AXIS_DIVINE] = -5
	fallback[AXIS_CORRUPTION] = 0
	return fallback


static func _axis_sum_dict(d: Dictionary) -> int:
	var s := 0
	for a in ALL_AXES:
		s += int(d.get(a, 0))
	return s
```

Si tu veux, je peux aussi te donner une variante “plus dramatique” (avec davantage d’extrêmes) ou “plus nuancée” (plus centrée), juste en changeant 2–3 paramètres (`randfn` deviation, clamps, contraintes “interesting”).

Moi:
Fait les deux, on choisira l'algo en fonction de l'etat du monde.
L'ideal serait un algo qui prend un dictionnaire de parametre en entrée ainsi qu'un type de generation.
De la on choisit si on fait un tirage centré, dramatique ou normal.
Il faut aussi qu'on puisse forcée un tirage contre un axe/faction (cas d'une faction qui a pris le controle du monde, il faut qu'on puisse faire emergée une faction qui va naturellement se placer en antagoniste).

ChatGPT:
Voilà une version **paramétrable** qui supporte 3 modes (**centered / normal / dramatic**), accepte un **dictionnaire de paramètres**, et permet de **forcer un tirage antagoniste** contre un **axe** et/ou contre une **faction** (via son `FactionProfile`).

À coller dans `FactionProfile.gd` (en gardant tes constantes `ALL_AXES`, `AXIS_MIN/MAX`, etc.).

```gdscript
# --- In FactionProfile.gd ---

const GEN_CENTERED: StringName = &"centered"
const GEN_NORMAL: StringName = &"normal"
const GEN_DRAMATIC: StringName = &"dramatic"

static func generate_axis_affinity(
	rng: RandomNumberGenerator,
	mode: StringName = GEN_NORMAL,
	params: Dictionary = {},
	force_against_axis: StringName = &"",        # ex: AXIS_MAGIC -> force un gros négatif sur Magie
	against_faction_profile: FactionProfile = null, # faction dominante à contrer
	antagonism_strength: float = 1.0             # 0..2 (en pratique)
) -> Dictionary[StringName, int]:
	var p := _default_axis_gen_params(mode)
	for k in params.keys():
		p[k] = params[k]

	var attempts: int = int(p.get("attempts", 80))
	var best: Dictionary[StringName, int] = {}
	var best_score := -INF

	for i in range(attempts):
		var candidate := _generate_axis_affinity_once(rng, p, force_against_axis, against_faction_profile, antagonism_strength)
		if candidate.is_empty():
			continue

		# Si on veut contrer une faction, on choisit le candidat le plus antagoniste (dot-product le plus négatif)
		if against_faction_profile != null:
			var score := _antagonism_score(candidate, against_faction_profile.axis_affinity)
			if score > best_score:
				best_score = score
				best = candidate
		else:
			return candidate

	return best if not best.is_empty() else _fallback_axis_affinity()


static func _default_axis_gen_params(mode: StringName) -> Dictionary:
	# Tu peux override n’importe quel champ via `params`.
	# Les 3 modes changent principalement : sigma, clamps, anchors et "interestingness".
	var d := {
		"sum_min": AXIS_SUM_MIN,         # 20
		"sum_max": AXIS_SUM_MAX,         # 90
		"pos_min": 60, "pos_max": 92,    # anchor positif > 50
		"neg_min_abs": 25, "neg_max_abs": 80, # anchor négatif < -20

		"other_sigma": 32.0,
		"other_clamp_abs": 75,

		"near_zero_abs": 8,
		"near_zero_push_min": 10,
		"near_zero_push_max": 22,

		"strong_abs_threshold": 15,
		"min_strong_in_others": 2,       # parmi les 3 axes restants
		"min_interesting_axes": 3,       # total axes avec |v| >= interesting_abs
		"interesting_abs": 12,

		"adjust_step_min": 3,
		"adjust_step_max": 14,

		"cooldown_bias_non_anchor": 0.75,
		"attempts": 80,
		"inner_resample_other": 30,
		"max_adjust_iters": 250,
	}

	match mode:
		GEN_CENTERED:
			# plus “nuancé” : moins d’extrêmes, plus de retour vers 0
			d["pos_min"] = 55
			d["pos_max"] = 78
			d["neg_min_abs"] = 25
			d["neg_max_abs"] = 55
			d["other_sigma"] = 20.0
			d["other_clamp_abs"] = 55
			d["interesting_abs"] = 10
			d["min_interesting_axes"] = 4     # plus d’axes “un peu marqués”
			# somme un peu moins haute en moyenne (garde de la place pour dériver ensuite)
			d["sum_min"] = 20
			d["sum_max"] = 75

		GEN_DRAMATIC:
			# plus “radical” : identité forte, tensions idéologiques marquées
			d["pos_min"] = 75
			d["pos_max"] = 100
			d["neg_min_abs"] = 40
			d["neg_max_abs"] = 100
			d["other_sigma"] = 45.0
			d["other_clamp_abs"] = 95
			d["near_zero_push_min"] = 18
			d["near_zero_push_max"] = 35
			d["strong_abs_threshold"] = 18
			d["interesting_abs"] = 15
			d["min_interesting_axes"] = 3
			d["sum_min"] = 20
			d["sum_max"] = 90

		_:
			# GEN_NORMAL = defaults
			pass

	return d


static func _generate_axis_affinity_once(
	rng: RandomNumberGenerator,
	p: Dictionary,
	force_against_axis: StringName,
	against_faction_profile: FactionProfile,
	antagonism_strength: float
) -> Dictionary[StringName, int]:
	# 1) Choix des axes anchors (pos/neg), en tenant compte des “contre”
	var anchors := _pick_anchor_axes(rng, force_against_axis, against_faction_profile)
	if anchors.is_empty():
		return {}
	var pos_axis: StringName = anchors["pos"]
	var neg_axis: StringName = anchors["neg"]

	# 2) Valeurs anchors
	var pos_min: int = int(p["pos_min"])
	var pos_max: int = int(p["pos_max"])
	var neg_min_abs: int = int(p["neg_min_abs"])
	var neg_max_abs: int = int(p["neg_max_abs"])

	# antagonism_strength : renforce légèrement les anchors quand on veut un vrai antagoniste
	if force_against_axis != &"" or against_faction_profile != null:
		var k := clampf(antagonism_strength, 0.0, 2.0)
		pos_min = clampi(pos_min + int(8.0 * k), 51, 100)
		pos_max = clampi(pos_max + int(10.0 * k), 51, 100)
		neg_min_abs = clampi(neg_min_abs + int(8.0 * k), 21, 100)
		neg_max_abs = clampi(neg_max_abs + int(10.0 * k), 21, 100)

	var d: Dictionary[StringName, int] = {}
	for a in ALL_AXES:
		d[a] = 0

	d[pos_axis] = rng.randi_range(pos_min, pos_max)          # > 50
	d[neg_axis] = -rng.randi_range(neg_min_abs, neg_max_abs) # < -20

	# 3) Génération des 3 autres axes (distribution intéressante)
	var rem_axes: Array[StringName] = []
	for a in ALL_AXES:
		if a != pos_axis and a != neg_axis:
			rem_axes.append(a)

	var ok_distribution := false
	for _resample in range(int(p.get("inner_resample_other", 30))):
		var strong_count := 0
		for a in rem_axes:
			var v := int(round(rng.randfn(0.0, float(p["other_sigma"]))))
			if abs(v) < int(p["near_zero_abs"]):
				v += (rng.randf() < 0.5 ? -1 : 1) * rng.randi_range(int(p["near_zero_push_min"]), int(p["near_zero_push_max"]))
			v = clampi(v, -int(p["other_clamp_abs"]), int(p["other_clamp_abs"]))
			d[a] = v
			if abs(v) >= int(p["strong_abs_threshold"]):
				strong_count += 1
		if strong_count >= int(p["min_strong_in_others"]):
			ok_distribution = true
			break

	if not ok_distribution:
		return {}

	# 4) Ajuster la somme dans [sum_min..sum_max] sans casser les garanties
	var target_sum := rng.randi_range(int(p["sum_min"]), int(p["sum_max"]))
	var diff := target_sum - _axis_sum_dict(d)

	var min_allowed: Dictionary[StringName, int] = {}
	var max_allowed: Dictionary[StringName, int] = {}
	for a in ALL_AXES:
		min_allowed[a] = AXIS_MIN
		max_allowed[a] = AXIS_MAX
	min_allowed[pos_axis] = 51
	max_allowed[pos_axis] = 100
	min_allowed[neg_axis] = -100
	max_allowed[neg_axis] = -21

	var max_iters := int(p.get("max_adjust_iters", 250))
	var iter := 0
	while diff != 0 and iter < max_iters:
		iter += 1
		var candidates: Array[StringName] = []
		for a in ALL_AXES:
			var v: int = d[a]
			if diff > 0 and v < max_allowed[a]:
				candidates.append(a)
			elif diff < 0 and v > min_allowed[a]:
				candidates.append(a)

		if candidates.is_empty():
			break

		# Ajuster surtout les non-anchors
		var chosen: StringName
		if rng.randf() < float(p.get("cooldown_bias_non_anchor", 0.75)):
			var non_anchor: Array[StringName] = []
			for a in candidates:
				if a != pos_axis and a != neg_axis:
					non_anchor.append(a)
			chosen = non_anchor.is_empty() ? candidates.pick_random() : non_anchor.pick_random()
		else:
			chosen = candidates.pick_random()

		var headroom := 0
		if diff > 0:
			headroom = max_allowed[chosen] - d[chosen]
		else:
			headroom = d[chosen] - min_allowed[chosen]
		if headroom <= 0:
			continue

		var step_mag := min(abs(diff), headroom, rng.randi_range(int(p["adjust_step_min"]), int(p["adjust_step_max"])))
		var step := (diff > 0) ? step_mag : -step_mag
		d[chosen] += step
		diff -= step

	# 5) Validation finale (garanties + “interestingness”)
	var s := _axis_sum_dict(d)
	if s < int(p["sum_min"]) or s > int(p["sum_max"]):
		return {}
	if d[pos_axis] <= AXIS_REQUIRED_POSITIVE_GT:
		return {}
	if d[neg_axis] >= AXIS_REQUIRED_NEGATIVE_LT:
		return {}

	var interesting := 0
	for a in ALL_AXES:
		if abs(d[a]) >= int(p["interesting_abs"]):
			interesting += 1
	if interesting < int(p["min_interesting_axes"]):
		return {}

	# Clamp sécurité
	for a in ALL_AXES:
		d[a] = clampi(d[a], AXIS_MIN, AXIS_MAX)

	return d


static func _pick_anchor_axes(
	rng: RandomNumberGenerator,
	force_against_axis: StringName,
	against_faction_profile: FactionProfile
) -> Dictionary:
	var axes := ALL_AXES.duplicate()

	var neg_axis: StringName = &""
	var pos_axis: StringName = &""

	# 1) Forcer un gros négatif sur un axe précis
	if force_against_axis != &"" and axes.has(force_against_axis):
		neg_axis = force_against_axis
		axes.erase(neg_axis)

	# 2) Forcer un antagonisme contre une faction : opposer les “pôles”
	# - si la faction cible aime fortement un axe -> on le déteste (neg)
	# - si la faction cible déteste fortement un axe -> on l’aime (pos)
	if against_faction_profile != null:
		var tgt := against_faction_profile.axis_affinity

		# Choix pos : axe le plus négatif chez la cible (on fait l’inverse)
		var best_pos_axis: StringName = &""
		var best_pos_value := 999999
		for a in axes:
			var v := int(tgt.get(a, 0))
			if v < best_pos_value:
				best_pos_value = v
				best_pos_axis = a
		if best_pos_axis != &"":
			pos_axis = best_pos_axis
			axes.erase(pos_axis)

		# Si neg_axis n'est pas forcé, choisir l’axe le plus positif chez la cible
		if neg_axis == &"":
			# remettre tous les axes sauf pos_axis
			var axes2 := ALL_AXES.duplicate()
			if axes2.has(pos_axis):
				axes2.erase(pos_axis)

			var best_neg_axis: StringName = &""
			var best_neg_value := -999999
			for a in axes2:
				var v := int(tgt.get(a, 0))
				if v > best_neg_value:
					best_neg_value = v
					best_neg_axis = a
			neg_axis = best_neg_axis

	# 3) Si encore incomplet, random
	if pos_axis == &"":
		pos_axis = axes[rng.randi_range(0, axes.size() - 1)]
		axes.erase(pos_axis)
	if neg_axis == &"":
		# pick from remaining original axes
		var remaining := ALL_AXES.duplicate()
		remaining.erase(pos_axis)
		neg_axis = remaining[rng.randi_range(0, remaining.size() - 1)]

	# éviter collision
	if neg_axis == pos_axis:
		var remaining2 := ALL_AXES.duplicate()
		remaining2.erase(pos_axis)
		neg_axis = remaining2[rng.randi_range(0, remaining2.size() - 1)]

	return {"pos": pos_axis, "neg": neg_axis}


static func _antagonism_score(my_aff: Dictionary, target_aff: Dictionary) -> float:
	# On veut être "opposé" : score haut quand le dot-product est très négatif.
	var dot := 0.0
	for a in ALL_AXES:
		dot += float(int(my_aff.get(a, 0)) * int(target_aff.get(a, 0)))
	return -dot


static func _axis_sum_dict(d: Dictionary) -> int:
	var s := 0
	for a in ALL_AXES:
		s += int(d.get(a, 0))
	return s


static func _fallback_axis_affinity() -> Dictionary[StringName, int]:
	var f: Dictionary[StringName, int] = {}
	for a in ALL_AXES:
		f[a] = 0
	f[AXIS_MAGIC] = 70
	f[AXIS_TECH] = -30
	f[AXIS_NATURE] = 20
	f[AXIS_DIVINE] = -5
	f[AXIS_CORRUPTION] = 0
	return f
```

### Exemples d’utilisation

**Normal :**
```gdscript
profile.axis_affinity = FactionProfile.generate_axis_affinity(rng, FactionProfile.GEN_NORMAL)
```

**Centré (nuancé) :**
```gdscript
profile.axis_affinity = FactionProfile.generate_axis_affinity(rng, FactionProfile.GEN_CENTERED)
```

**Dramatique (radical) :**
```gdscript
profile.axis_affinity = FactionProfile.generate_axis_affinity(rng, FactionProfile.GEN_DRAMATIC)
```

**Forcer une faction “anti-magie” (antagoniste d’un monde très magique) :**
```gdscript
profile.axis_affinity = FactionProfile.generate_axis_affinity(
	rng, FactionProfile.GEN_DRAMATIC, {}, FactionProfile.AXIS_MAGIC
)
```

**Forcer une faction antagoniste à une faction dominante (profil connu) :**
```gdscript
profile.axis_affinity = FactionProfile.generate_axis_affinity(
	rng,
	FactionProfile.GEN_NORMAL,
	{},
	&"",                      # pas d’axe imposé
	dominant_faction.profile, # contre cette faction
	1.3                       # antagonisme un peu renforcé
)
```

Si tu veux, prochaine étape : on fait la même chose pour la **génération de personnalité** (templates + variation -0.1..+0.2), avec aussi un mode “antagoniste” (ex : si tu contrer une faction pacifique, tu génères un profil plus agressif, etc.).

Moi:
Go pour génération de personnalité

ChatGPT:
Voici une génération **procédurale + templates** pour la personnalité, avec :

- **templates** (pacifique, pragmatique, belliqueux, expansionniste, fanatique, assimilateur)
- **variation** par trait (par défaut **[-0.1 .. +0.2]**, clamp 0..1)
- 3 modes : **centered / normal / dramatic** (qui modulent l’amplitude + l’“interestingness”)
- un mode **antagoniste** : tu peux générer une faction “qui s’oppose naturellement” à une autre (en choisissant le template le plus opposé + en blendant vers l’inverse des valeurs)

À coller dans `FactionProfile.gd` (en plus de tes constantes `ALL_PERSONALITY_KEYS`, `PERS_*`, etc.).

```gdscript
# --- In FactionProfile.gd ---

const PGEN_CENTERED: StringName = &"centered"
const PGEN_NORMAL: StringName = &"normal"
const PGEN_DRAMATIC: StringName = &"dramatic"

const PTYPE_PACIFIST: StringName = &"pacifist"
const PTYPE_PRAGMATIC: StringName = &"pragmatic"
const PTYPE_WARLIKE: StringName = &"warlike"
const PTYPE_EXPANSIONIST: StringName = &"expansionist"
const PTYPE_FANATIC: StringName = &"fanatic"
const PTYPE_ASSIMILATOR: StringName = &"assimilator"

static func personality_templates() -> Dictionary:
	# Valeurs de base 0..1 (tu pourras ajuster selon ton design)
	return {
		PTYPE_PACIFIST: {
			PERS_AGGRESSION: 0.15,
			PERS_VENGEFULNESS: 0.20,
			PERS_DIPLOMACY: 0.85,
			PERS_RISK_AVERSION: 0.70,
			PERS_EXPANSIONISM: 0.20,
			PERS_INTEGRATIONISM: 0.60,
		},
		PTYPE_PRAGMATIC: {
			PERS_AGGRESSION: 0.35,
			PERS_VENGEFULNESS: 0.35,
			PERS_DIPLOMACY: 0.55,
			PERS_RISK_AVERSION: 0.50,
			PERS_EXPANSIONISM: 0.40,
			PERS_INTEGRATIONISM: 0.40,
		},
		PTYPE_WARLIKE: {
			PERS_AGGRESSION: 0.80,
			PERS_VENGEFULNESS: 0.70,
			PERS_DIPLOMACY: 0.20,
			PERS_RISK_AVERSION: 0.30,
			PERS_EXPANSIONISM: 0.60,
			PERS_INTEGRATIONISM: 0.20,
		},
		PTYPE_EXPANSIONIST: {
			PERS_AGGRESSION: 0.65,
			PERS_VENGEFULNESS: 0.45,
			PERS_DIPLOMACY: 0.30,
			PERS_RISK_AVERSION: 0.35,
			PERS_EXPANSIONISM: 0.90,
			PERS_INTEGRATIONISM: 0.50,
		},
		PTYPE_FANATIC: {
			PERS_AGGRESSION: 0.75,
			PERS_VENGEFULNESS: 0.85,
			PERS_DIPLOMACY: 0.10,
			PERS_RISK_AVERSION: 0.20,
			PERS_EXPANSIONISM: 0.50,
			PERS_INTEGRATIONISM: 0.05,
		},
		PTYPE_ASSIMILATOR: {
			PERS_AGGRESSION: 0.45,
			PERS_VENGEFULNESS: 0.25,
			PERS_DIPLOMACY: 0.60,
			PERS_RISK_AVERSION: 0.45,
			PERS_EXPANSIONISM: 0.55,
			PERS_INTEGRATIONISM: 0.90,
		},
	}

static func default_personality_gen_params(mode: StringName) -> Dictionary:
	var d := {
		"attempts": 50,

		# Par défaut, ta plage souhaitée :
		"variation_min": -0.1,
		"variation_max": 0.2,

		# “Interestingness” : éviter un profil trop plat
		"require_high": 0.75,
		"require_low": 0.35,
		"min_high_count": 1,
		"min_low_count": 1,

		# Blend vers l’antagonisme (0..1)
		"antagonism_blend": 0.0,

		# Optionnel : favoriser certains templates
		# ex: {"pacifist": 1.0, "warlike": 0.2, ...}
		"template_weights": {},
	}

	match mode:
		PGEN_CENTERED:
			d["variation_min"] = -0.05
			d["variation_max"] = 0.10
			d["require_high"] = 0.70
			d["require_low"] = 0.40

		PGEN_DRAMATIC:
			d["variation_min"] = -0.15
			d["variation_max"] = 0.25
			d["require_high"] = 0.80
			d["require_low"] = 0.30

		_:
			pass

	return d

static func generate_personality(
	rng: RandomNumberGenerator,
	mode: StringName = PGEN_NORMAL,
	params: Dictionary = {},
	personality_type: StringName = &"",           # si vide: choisi automatiquement
	against_faction_profile: FactionProfile = null, # pour générer un antagoniste
	antagonism_strength: float = 1.0              # 0..2
) -> Dictionary[StringName, float]:
	var p := default_personality_gen_params(mode)
	for k in params.keys():
		p[k] = params[k]

	var templates := personality_templates()
	var attempts := int(p.get("attempts", 50))

	# 1) Choix du template
	var chosen_type := personality_type
	if chosen_type == &"":
		if against_faction_profile != null:
			chosen_type = _pick_most_antagonistic_template(templates, against_faction_profile.personality)
		else:
			chosen_type = _pick_weighted_template(rng, templates, p.get("template_weights", {}))

	if not templates.has(chosen_type):
		chosen_type = PTYPE_PRAGMATIC

	# 2) Génération avec retries pour “interestingness”
	var best: Dictionary[StringName, float] = {}
	var best_interest := -INF

	for _i in range(attempts):
		var cand := _build_personality_from_template(
			rng,
			Dictionary(templates[chosen_type]),
			p,
			against_faction_profile,
			antagonism_strength
		)
		if cand.is_empty():
			continue

		var interest := _interest_score(cand, float(p["require_high"]), float(p["require_low"]))
		if _meets_interest(cand, p):
			return cand

		# sinon garder la meilleure, au cas où (fallback soft)
		if interest > best_interest:
			best_interest = interest
			best = cand

	return best if not best.is_empty() else _fallback_personality()


static func _build_personality_from_template(
	rng: RandomNumberGenerator,
	base: Dictionary,
	p: Dictionary,
	against_faction_profile: FactionProfile,
	antagonism_strength: float
) -> Dictionary[StringName, float]:
	var out: Dictionary[StringName, float] = {}

	var var_min := float(p.get("variation_min", -0.1))
	var var_max := float(p.get("variation_max", 0.2))

	# Antagonism blend (0..1) : plus c’est haut, plus on tend vers l’inverse de la cible
	var blend := float(p.get("antagonism_blend", 0.0))
	if against_faction_profile != null:
		blend = clampf(blend + 0.35 * clampf(antagonism_strength, 0.0, 2.0), 0.0, 1.0)

	for k in ALL_PERSONALITY_KEYS:
		var v := clampf(float(base.get(k, 0.5)), 0.0, 1.0)

		if against_faction_profile != null:
			var t := clampf(float(against_faction_profile.personality.get(k, 0.5)), 0.0, 1.0)
			var opposite := 1.0 - t
			v = lerp(v, opposite, blend)

		var delta := rng.randf_range(var_min, var_max)
		v = clampf(v + delta, 0.0, 1.0)
		out[k] = v

	return out


static func _pick_weighted_template(
	rng: RandomNumberGenerator,
	templates: Dictionary,
	weights: Dictionary
) -> StringName:
	# Si weights vide => uniforme
	var keys: Array = templates.keys()
	if weights.is_empty():
		return StringName(keys[rng.randi_range(0, keys.size() - 1)])

	var total := 0.0
	for k in keys:
		total += max(0.0, float(weights.get(k, 1.0)))

	if total <= 0.0:
		return StringName(keys[rng.randi_range(0, keys.size() - 1)])

	var r := rng.randf() * total
	var acc := 0.0
	for k in keys:
		acc += max(0.0, float(weights.get(k, 1.0)))
		if r <= acc:
			return StringName(k)

	return StringName(keys[0])


static func _pick_most_antagonistic_template(templates: Dictionary, target_personality: Dictionary) -> StringName:
	# Choisit le template le plus "opposé" au target (corrélation négative autour de 0.5)
	var best_key: StringName = PTYPE_PRAGMATIC
	var best_score := -INF
	for k in templates.keys():
		var tpl: Dictionary = templates[k]
		var score := 0.0
		for trait in ALL_PERSONALITY_KEYS:
			var a := float(tpl.get(trait, 0.5)) - 0.5
			var b := float(target_personality.get(trait, 0.5)) - 0.5
			score += -a * b  # plus c'est grand, plus c’est opposé
		if score > best_score:
			best_score = score
			best_key = StringName(k)
	return best_key


static func _meets_interest(personality: Dictionary, p: Dictionary) -> bool:
	var high_thr := float(p.get("require_high", 0.75))
	var low_thr := float(p.get("require_low", 0.35))
	var min_high := int(p.get("min_high_count", 1))
	var min_low := int(p.get("min_low_count", 1))

	var hi := 0
	var lo := 0
	for k in ALL_PERSONALITY_KEYS:
		var v := float(personality.get(k, 0.5))
		if v >= high_thr:
			hi += 1
		if v <= low_thr:
			lo += 1

	return hi >= min_high and lo >= min_low


static func _interest_score(personality: Dictionary, high_thr: float, low_thr: float) -> float:
	var hi := 0
	var lo := 0
	var spread := 0.0
	for k in ALL_PERSONALITY_KEYS:
		var v := float(personality.get(k, 0.5))
		if v >= high_thr: hi += 1
		if v <= low_thr: lo += 1
		spread += abs(v - 0.5)
	return float(hi + lo) + spread


static func _fallback_personality() -> Dictionary[StringName, float]:
	# fallback stable
	return {
		PERS_AGGRESSION: 0.35,
		PERS_VENGEFULNESS: 0.35,
		PERS_DIPLOMACY: 0.55,
		PERS_RISK_AVERSION: 0.50,
		PERS_EXPANSIONISM: 0.40,
		PERS_INTEGRATIONISM: 0.40,
	}
```

### Exemples d’utilisation

**Générer une personnalité “normale” aléatoire :**
```gdscript
profile.personality = FactionProfile.generate_personality(rng, FactionProfile.PGEN_NORMAL)
```

**Forcer un type précis (ex : pacifique) :**
```gdscript
profile.personality = FactionProfile.generate_personality(
	rng, FactionProfile.PGEN_NORMAL, {}, FactionProfile.PTYPE_PACIFIST
)
```

**Mode dramatique (traits plus marqués) :**
```gdscript
profile.personality = FactionProfile.generate_personality(rng, FactionProfile.PGEN_DRAMATIC)
```

**Faire émerger un antagoniste naturel d’une faction dominante :**
```gdscript
profile.personality = FactionProfile.generate_personality(
	rng,
	FactionProfile.PGEN_NORMAL,
	{"antagonism_blend": 0.15},        # tu peux augmenter si tu veux du “hard counter”
	&"",                               # laisse le code choisir le template antagoniste
	dominant_faction.profile,
	1.3
)
```

Si tu veux, prochaine étape logique : une fonction “**generate_full_profile**” qui génère **axes + personnalité** en cohérence (ex : une faction anti-magie a plus de chances d’être prudente/risk_averse, ou au contraire fanatique anti-magie selon le monde), et surtout un “mode antagoniste complet” contre une faction hégémonique.

Moi:
Ok prochaine étape logique : une fonction “generate_full_profile” qui génère axes + personnalité en cohérence (ex : une faction anti-magie a plus de chances d’être prudente/risk_averse, ou au contraire fanatique anti-magie selon le monde), et surtout un “mode antagoniste complet” contre une faction hégémonique.

ChatGPT:
Voilà une proposition **clé en main** pour `generate_full_profile()` qui :

- génère **axes + personnalité**,
- assure une **cohérence** (les axes “poussent” certains traits),
- supporte les modes **centered / normal / dramatic** via `gen_type` + `params`,
- et gère un **mode antagoniste complet** contre une faction hégémonique (axes opposés + personnalité adaptée).

À coller dans `FactionProfile.gd` (en s’appuyant sur les fonctions que tu as déjà : `generate_axis_affinity()` et `generate_personality()`).

---

## 1) `generate_full_profile()` + helpers

```gdscript
# --- In FactionProfile.gd ---

static func generate_full_profile(
	rng: RandomNumberGenerator,
	gen_type: StringName = GEN_NORMAL,          # centered/normal/dramatic (on réutilise tes modes)
	params: Dictionary = {},
	force_against_axis: StringName = &"",        # optionnel : AXIS_MAGIC etc.
	against_faction_profile: FactionProfile = null, # optionnel : pour créer un antagoniste
	antagonism_strength: float = 1.0             # 0..2 (≈ 1.0 normal)
) -> FactionProfile:
	var profile := FactionProfile.new()

	# --- Paramètres par défaut ---
	var axis_mode: StringName = StringName(params.get("axis_mode", gen_type))
	var pers_mode: StringName = StringName(params.get("personality_mode", gen_type))

	var axis_params: Dictionary = Dictionary(params.get("axis_params", {}))
	var pers_params: Dictionary = Dictionary(params.get("personality_params", {}))

	# Coherence (blend global axes -> personnalité)
	var coherence_strength := float(params.get("coherence_strength", _default_coherence_strength(gen_type)))

	# Anti-magic style (prudente vs fanatique)
	var anti_magic_base_fanatic := float(params.get("anti_magic_base_fanatic", 0.35)) # base prob
	var anti_magic_enabled := bool(params.get("anti_magic_enabled", true))

	# Antagoniste : si true, on renforce un peu le côté “contre”
	var antagonist_full_mode := bool(params.get("antagonist_full_mode", against_faction_profile != null))
	var antagonist_force_dominant_axis := bool(params.get("antagonist_force_dominant_axis", true))
	var antagonist_personality_blend := float(params.get("antagonist_personality_blend", 0.15))

	# 1) Déterminer un axe à contrer si on vise une faction hégémonique
	var effective_force_against_axis := force_against_axis
	if antagonist_full_mode and against_faction_profile != null and antagonist_force_dominant_axis and effective_force_against_axis == &"":
		effective_force_against_axis = _dominant_axis_of(against_faction_profile.axis_affinity)

	# 2) Générer les axes (normal/centered/dramatic + paramètres)
	profile.axis_affinity = generate_axis_affinity(
		rng,
		axis_mode,
		axis_params,
		effective_force_against_axis,
		against_faction_profile,
		antagonism_strength
	)

	# 3) Choisir un template de personnalité cohérent avec les axes (weights)
	var axis_based_weights := _personality_weights_from_axes(profile.axis_affinity)

	# Si antagoniste complet, on mélange un peu les weights avec l’opposition à la cible
	# (sans empêcher le “contre-template” automatique si tu veux le garder)
	pers_params["template_weights"] = axis_based_weights

	# 4) Générer personnalité (template + variation + éventuellement antagonisme contre une faction)
	if antagonist_full_mode and against_faction_profile != null:
		# un petit boost pour pousser vers l’inverse, sans être une caricature
		var prev := float(pers_params.get("antagonism_blend", 0.0))
		pers_params["antagonism_blend"] = clampf(prev + antagonist_personality_blend, 0.0, 1.0)

	profile.personality = generate_personality(
		rng,
		_to_personality_mode(pers_mode),  # mapping gen_type -> PGEN_*
		pers_params,
		&"", # laisser choisir (pondéré + antagoniste si against != null)
		against_faction_profile,
		antagonism_strength
	)

	# 5) Appliquer “cohérence axes -> traits” (petites poussées, clamp 0..1)
	_apply_axis_bias_to_personality(profile.personality, profile.axis_affinity, coherence_strength)

	# 6) Cas spécial : anti-magie fort => prudente OU fanatique (au choix, probabiliste)
	if anti_magic_enabled:
		_apply_anti_magic_style(profile.personality, profile.axis_affinity, rng, anti_magic_base_fanatic, coherence_strength)

	return profile


# ---------------------------
# Helpers
# ---------------------------

static func _default_coherence_strength(gen_type: StringName) -> float:
	match gen_type:
		GEN_CENTERED:
			return 0.35
		GEN_DRAMATIC:
			return 0.75
		_:
			return 0.55


static func _to_personality_mode(axis_mode: StringName) -> StringName:
	# Recycle tes modes centered/normal/dramatic vers les modes personnalité
	match axis_mode:
		GEN_CENTERED:
			return PGEN_CENTERED
		GEN_DRAMATIC:
			return PGEN_DRAMATIC
		_:
			return PGEN_NORMAL


static func _dominant_axis_of(axis_aff: Dictionary) -> StringName:
	# Axe avec affinité la plus élevée (ex: hégémonie magique -> AXIS_MAGIC)
	var best_axis: StringName = AXIS_TECH
	var best_v := -999999
	for a in ALL_AXES:
		var v := int(axis_aff.get(a, 0))
		if v > best_v:
			best_v = v
			best_axis = a
	return best_axis


static func _personality_weights_from_axes(axis_aff: Dictionary) -> Dictionary:
	# Renvoie un poids par template, basé sur “couleur idéologique” (simple mais efficace).
	# Les poids sont relatifs, _pick_weighted_template gère la normalisation.
	var tech := float(int(axis_aff.get(AXIS_TECH, 0))) / 100.0
	var magic := float(int(axis_aff.get(AXIS_MAGIC, 0))) / 100.0
	var nature := float(int(axis_aff.get(AXIS_NATURE, 0))) / 100.0
	var divine := float(int(axis_aff.get(AXIS_DIVINE, 0))) / 100.0
	var corr := float(int(axis_aff.get(AXIS_CORRUPTION, 0))) / 100.0

	# Quelques heuristiques :
	# - Corruption forte => fanatique / belliqueux
	# - Nature + Divine => pacifique / assimilateur
	# - Tech => pragmatique / expansionniste
	# - Anti-magic très fort peut pousser pacifique prudent OU fanatique puriste (géré plus bas aussi)
	var anti_magic := clampf((-magic - 0.5) / 0.5, 0.0, 1.0) # ~0 si magic >= -50, ~1 si magic <= -100

	var w := {}
	w[PTYPE_PRAGMATIC] = 1.0 + 1.2*max(0.0, tech) + 0.4*max(0.0, magic)
	w[PTYPE_EXPANSIONIST] = 0.8 + 1.6*max(0.0, tech) + 0.8*max(0.0, corr)
	w[PTYPE_PACIFIST] = 0.8 + 1.6*max(0.0, nature) + 1.2*max(0.0, divine) + 0.6*anti_magic
	w[PTYPE_ASSIMILATOR] = 0.7 + 1.4*max(0.0, divine) + 0.8*max(0.0, magic) + 0.6*max(0.0, nature)
	w[PTYPE_WARLIKE] = 0.7 + 1.2*max(0.0, corr) + 0.6*max(0.0, tech)
	w[PTYPE_FANATIC] = 0.5 + 2.0*max(0.0, corr) + 1.0*max(0.0, divine) + 0.7*anti_magic

	return w


static func _apply_axis_bias_to_personality(personality: Dictionary, axis_aff: Dictionary, strength: float) -> void:
	# Pousses douces et cohérentes : axes -> traits.
	# strength 0..1 (0 = aucun effet, 1 = effet plein)
	var tech := float(int(axis_aff.get(AXIS_TECH, 0))) / 100.0
	var magic := float(int(axis_aff.get(AXIS_MAGIC, 0))) / 100.0
	var nature := float(int(axis_aff.get(AXIS_NATURE, 0))) / 100.0
	var divine := float(int(axis_aff.get(AXIS_DIVINE, 0))) / 100.0
	var corr := float(int(axis_aff.get(AXIS_CORRUPTION, 0))) / 100.0

	# Ajustements (petits, puis multipliés par strength)
	var adj := {
		PERS_AGGRESSION: 0.0,
		PERS_VENGEFULNESS: 0.0,
		PERS_DIPLOMACY: 0.0,
		PERS_RISK_AVERSION: 0.0,
		PERS_EXPANSIONISM: 0.0,
		PERS_INTEGRATIONISM: 0.0,
	}

	# Tech : plus structurant/expansion, un peu moins “conciliant”
	adj[PERS_EXPANSIONISM] += 0.18 * tech
	adj[PERS_AGGRESSION] += 0.08 * tech
	adj[PERS_DIPLOMACY] -= 0.06 * tech

	# Magie : souvent moins prudent (prise de risque), plus ouvert à intégration (soft)
	adj[PERS_RISK_AVERSION] -= 0.12 * magic
	adj[PERS_INTEGRATIONISM] += 0.08 * magic

	# Nature : plus diplomate, moins agressif, un peu plus prudent
	adj[PERS_DIPLOMACY] += 0.12 * nature
	adj[PERS_AGGRESSION] -= 0.10 * nature
	adj[PERS_RISK_AVERSION] += 0.06 * nature

	# Divin : diplomatie + intégration (coalitions), un peu plus prudent
	adj[PERS_DIPLOMACY] += 0.10 * divine
	adj[PERS_INTEGRATIONISM] += 0.10 * divine
	adj[PERS_RISK_AVERSION] += 0.05 * divine

	# Corruption : agressif, rancunier, peu diplomate, peu intégrateur, moins prudent
	adj[PERS_AGGRESSION] += 0.22 * corr
	adj[PERS_VENGEFULNESS] += 0.18 * corr
	adj[PERS_DIPLOMACY] -= 0.18 * corr
	adj[PERS_INTEGRATIONISM] -= 0.18 * corr
	adj[PERS_RISK_AVERSION] -= 0.10 * corr

	for k in ALL_PERSONALITY_KEYS:
		var v := float(personality.get(k, 0.5))
		v = clampf(v + adj.get(k, 0.0) * clampf(strength, 0.0, 1.0), 0.0, 1.0)
		personality[k] = v


static func _apply_anti_magic_style(
	personality: Dictionary,
	axis_aff: Dictionary,
	rng: RandomNumberGenerator,
	base_fanatic_prob: float,
	coherence_strength: float
) -> void:
	var magic_aff := int(axis_aff.get(AXIS_MAGIC, 0))
	if magic_aff > -50:
		return

	var corr := float(int(axis_aff.get(AXIS_CORRUPTION, 0))) / 100.0
	var divine := float(int(axis_aff.get(AXIS_DIVINE, 0))) / 100.0
	var nature := float(int(axis_aff.get(AXIS_NATURE, 0))) / 100.0

	# Plus l’anti-magie est fort, plus le style (prudence/fanatisme) s’affirme.
	var anti_magic_strength := clampf(float(-magic_aff - 50) / 50.0, 0.0, 1.0)

	# Probabilité fanatique (puriste) : augmente avec corruption/divin, diminue avec nature
	var p_fanatic := base_fanatic_prob \
		+ 0.25 * anti_magic_strength \
		+ 0.20 * max(0.0, corr) \
		+ 0.15 * max(0.0, divine) \
		- 0.10 * max(0.0, nature)

	p_fanatic = clampf(p_fanatic, 0.10, 0.90)

	var style_strength := clampf(0.35 + 0.45 * anti_magic_strength, 0.0, 1.0) * clampf(coherence_strength, 0.0, 1.0)

	if rng.randf() < p_fanatic:
		# Puriste / fanatique anti-magie : agressif + rancune, peu diplomate
		_personality_add(personality, PERS_AGGRESSION, +0.15 * style_strength)
		_personality_add(personality, PERS_VENGEFULNESS, +0.20 * style_strength)
		_personality_add(personality, PERS_DIPLOMACY, -0.20 * style_strength)
		_personality_add(personality, PERS_INTEGRATIONISM, -0.10 * style_strength)
		_personality_add(personality, PERS_RISK_AVERSION, -0.05 * style_strength)
	else:
		# Prudente / “méfiance institutionnelle” : très risk_averse, plutôt diplomate
		_personality_add(personality, PERS_RISK_AVERSION, +0.20 * style_strength)
		_personality_add(personality, PERS_DIPLOMACY, +0.10 * style_strength)
		_personality_add(personality, PERS_AGGRESSION, -0.10 * style_strength)
		_personality_add(personality, PERS_VENGEFULNESS, -0.05 * style_strength)
		_personality_add(personality, PERS_EXPANSIONISM, -0.05 * style_strength)


static func _personality_add(personality: Dictionary, key: StringName, delta: float) -> void:
	var v := float(personality.get(key, 0.5))
	personality[key] = clampf(v + delta, 0.0, 1.0)
```

---

## 2) Exemples d’utilisation

### A) Profil “standard” (normal)
```gdscript
var p := FactionProfile.generate_full_profile(rng, FactionProfile.GEN_NORMAL)
```

### B) Profil “centered” (plus nuancé)
```gdscript
var p := FactionProfile.generate_full_profile(rng, FactionProfile.GEN_CENTERED)
```

### C) Profil “dramatic” (plus radical)
```gdscript
var p := FactionProfile.generate_full_profile(rng, FactionProfile.GEN_DRAMATIC)
```

### D) Faire émerger un antagoniste “anti-hégémonie”
```gdscript
var p := FactionProfile.generate_full_profile(
	rng,
	FactionProfile.GEN_DRAMATIC,
	{
		"antagonist_full_mode": true,
		"antagonist_force_dominant_axis": true,
		"antagonist_personality_blend": 0.20,
		"coherence_strength": 0.75
	},
	&"",                       # pas d’axe forcé à la main
	dominant_faction.profile,  # la faction à contrer
	1.3                        # antagonisme renforcé
)
```

### E) Forcer “contre Magie” (mais sans cible faction)
```gdscript
var p := FactionProfile.generate_full_profile(
	rng,
	FactionProfile.GEN_NORMAL,
	{"coherence_strength": 0.6},
	FactionProfile.AXIS_MAGIC
)
```

---

## 3) Pourquoi ça marche bien pour ton monde procédural
- Les **axes** donnent une identité idéologique.
- La **personnalité** reste libre (variation + templates), mais est **poussée** par les axes pour créer des comportements cohérents.
- En mode **antagoniste**, tu obtiens une faction :
  - idéologiquement opposée (axes),
  - et naturellement portée à agir différemment (personnalité),
  - sans imposer “race = comportement”.

---

Si tu veux, prochaine brique logique : une fonction `compute_baseline_relation(A_profile, B_profile)` qui transforme **axes + personnalité** en **relation initiale** et en “friction” (pour initialiser ton `FactionRelationScore` A→B).

Moi:
Ok prochaine brique logique : une fonction compute_baseline_relation(A_profile, B_profile) qui transforme axes + personnalité en relation initiale et en “friction” (pour initialiser ton FactionRelationScore A→B).

ChatGPT:
Voici une brique **simple mais expressive** : `compute_baseline_relation(A, B)` calcule la **relation initiale (A→B)** + une **friction** (volatilité) à partir de :

- compatibilité idéologique (axes),
- conflits “croisés” (Tech↔Nature, Divin↔Corruption),
- et filtres de personnalité **côté A** (diplomatie, agressivité, rancune, prudence, expansion, intégration).

Je te renvoie aussi `trust` et `tension` initiaux (pratiques pour initialiser directement ton `FactionRelationScore`), mais tu peux ignorer si tu veux.

À coller dans `FactionProfile.gd`.

```gdscript
# --- In FactionProfile.gd ---

static func compute_baseline_relation(
	a: FactionProfile,
	b: FactionProfile,
	params: Dictionary = {}
) -> Dictionary:
	# ---- Tunables ----
	var w_axis_similarity: float = float(params.get("w_axis_similarity", 80.0))  # poids du "même axe"
	var w_cross_conflict: float = float(params.get("w_cross_conflict", 55.0))   # poids des conflits croisés
	var w_personality_bias: float = float(params.get("w_personality_bias", 25.0))

	# Cross-conflict weights (abs-products), tu peux en ajouter plus tard
	var w_tech_nature: float = float(params.get("w_tech_nature", 1.0))
	var w_divine_corruption: float = float(params.get("w_divine_corruption", 1.0))
	var w_magic_tech: float = float(params.get("w_magic_tech", 0.35)) # optionnel, plus léger

	# Friction tuning
	var friction_base: float = float(params.get("friction_base", 18.0))
	var friction_from_opposition: float = float(params.get("friction_from_opposition", 65.0))
	var friction_from_cross: float = float(params.get("friction_from_cross", 55.0))

	# Tension init tuning (tu peux la plafonner pour éviter guerres immédiates)
	var tension_cap: float = float(params.get("tension_cap", 40.0))

	# ---- Read profiles (normalized -1..+1) ----
	var aT := float(a.get_axis_affinity(AXIS_TECH)) / 100.0
	var aM := float(a.get_axis_affinity(AXIS_MAGIC)) / 100.0
	var aN := float(a.get_axis_affinity(AXIS_NATURE)) / 100.0
	var aD := float(a.get_axis_affinity(AXIS_DIVINE)) / 100.0
	var aC := float(a.get_axis_affinity(AXIS_CORRUPTION)) / 100.0

	var bT := float(b.get_axis_affinity(AXIS_TECH)) / 100.0
	var bM := float(b.get_axis_affinity(AXIS_MAGIC)) / 100.0
	var bN := float(b.get_axis_affinity(AXIS_NATURE)) / 100.0
	var bD := float(b.get_axis_affinity(AXIS_DIVINE)) / 100.0
	var bC := float(b.get_axis_affinity(AXIS_CORRUPTION)) / 100.0

	# ---- Axis similarity (dot / 5) in [-1..+1] ----
	var dot := (aT*bT + aM*bM + aN*bN + aD*bD + aC*bC)
	var similarity := dot / 5.0

	# Opposition measure in [0..~1] : somme des contributions "opposées"
	# (produit négatif => opposition)
	var opposition := (
		max(0.0, -(aT*bT)) +
		max(0.0, -(aM*bM)) +
		max(0.0, -(aN*bN)) +
		max(0.0, -(aD*bD)) +
		max(0.0, -(aC*bC))
	) / 5.0

	# Cross-conflicts (abs-products) in [0..~1]
	var cross := 0.0
	cross += w_tech_nature * (abs(aT) * abs(bN) + abs(aN) * abs(bT)) / 2.0
	cross += w_divine_corruption * (abs(aD) * abs(bC) + abs(aC) * abs(bD)) / 2.0
	cross += w_magic_tech * (abs(aM) * abs(bT) + abs(aT) * abs(bM)) / 2.0
	cross = clampf(cross, 0.0, 1.0)

	# ---- Personality filters (directional: A's worldview) ----
	var aggr := a.get_personality(PERS_AGGRESSION, 0.5)
	var veng := a.get_personality(PERS_VENGEFULNESS, 0.5)
	var diplo := a.get_personality(PERS_DIPLOMACY, 0.5)
	var risk := a.get_personality(PERS_RISK_AVERSION, 0.5)
	var expa := a.get_personality(PERS_EXPANSIONISM, 0.5)
	var integ := a.get_personality(PERS_INTEGRATIONISM, 0.5)

	# "Ideological intensity" : plus A est extrême, plus il juge fort (positif ou négatif)
	var intensity := (abs(aT) + abs(aM) + abs(aN) + abs(aD) + abs(aC)) / 5.0  # 0..1
	var judgment_gain := clampf(0.65 + 0.7*intensity + 0.2*veng - 0.25*diplo, 0.5, 1.6)

	# Relation bias: diplomatie et intégration rendent plus "ouvert" par défaut,
	# aggression + vengeance rendent plus dur, expansionism rend suspicieux si l'autre est incompatible.
	var pers_bias :=
		(+0.65*(diplo - 0.5)) +
		(+0.45*(integ - 0.5)) +
		(-0.55*(aggr - 0.5)) +
		(-0.45*(veng - 0.5)) +
		(-0.25*(expa - 0.5))

	# ---- Baseline relation (A -> B) ----
	# similarity pousse + ; cross + opposition poussent - ; personnalité ajuste le ton.
	var rel_f := 0.0
	rel_f += (similarity * w_axis_similarity) * judgment_gain
	rel_f -= (cross * w_cross_conflict) * judgment_gain
	rel_f += pers_bias * w_personality_bias

	var relation := clampi(int(round(rel_f)), -100, 100)

	# ---- Friction (volatilité / risque d'incident) ----
	# friction augmente avec opposition + cross-conflicts, puis est multipliée par le tempérament de A.
	var fr := friction_base
	fr += opposition * friction_from_opposition * judgment_gain
	fr += cross * friction_from_cross * judgment_gain

	# tempérament : aggression/vengefulness augmentent, diplomacy/risk_aversion diminuent
	var fr_mul := 1.0 \
		+ 0.50*(aggr - 0.5) \
		+ 0.45*(veng - 0.5) \
		- 0.40*(diplo - 0.5) \
		- 0.25*(risk - 0.5)

	fr = clampf(fr * clampf(fr_mul, 0.55, 1.65), 0.0, 100.0)

	# ---- Optional: init trust & tension (useful to init FactionRelationScore) ----
	# Trust suit la relation, mais est pénalisée par rancune/agressivité.
	var trust_f := 0.65*float(relation) + 18.0*(diplo - 0.5) - 14.0*(veng - 0.5) - 10.0*(aggr - 0.5)
	var trust := clampi(int(round(trust_f)), -100, 100)

	# Tension est une “partie” de la friction + négativité de relation, plafonnée (évite guerres day 1)
	var tension := clampf(0.35*fr + 0.20*max(0.0, -float(relation)), 0.0, tension_cap)

	return {
		"relation": relation,  # -100..100 (A -> B)
		"friction": fr,        # 0..100 (A -> B)
		"trust": trust,        # -100..100 (A -> B)
		"tension": tension     # 0..tension_cap
	}
```

### Comment l’utiliser pour initialiser ton `FactionRelationScore A→B`
```gdscript
var init := FactionProfile.compute_baseline_relation(a.profile, b.profile)

var rs := FactionRelationScore.new(b.faction_id)
rs.relation = init["relation"]
rs.trust = init["trust"]
rs.tension = init["tension"]
rs.grievance = 0.0
rs.weariness = 0.0
rs.clamp_all()
```

### Notes rapides (design)
- C’est **directionnel** : A→B ≠ B→A, car la personnalité de A filtre le jugement.
- `friction` est ce qui te sert ensuite dans l’ArcManager pour décider si un “incident” est probable, même si `relation` n’est pas déjà très bas.
- Tu peux très facilement “brancher” les axes du monde : par ex. si le monde est dominé par la magie, tu augmentes `w_magic_tech` ou `w_axis_similarity`, etc.

Si tu veux, prochaine brique logique : une fonction `initialize_relations_for_faction(faction_id)` qui construit le dictionnaire complet A→(toutes les autres) avec **cohérence globale** (ex : moyenne relation centrée, quelques ennemis naturels, etc.).

Moi:
Ok,prochaine brique logique : une fonction initialize_relations_for_faction(faction_id) qui construit le dictionnaire complet A→(toutes les autres) avec cohérence globale (ex : moyenne relation centrée, quelques ennemis naturels, etc.).

ChatGPT:
Voici une version **robuste + paramétrable** de `initialize_relations_for_faction()` qui construit **A→(toutes les autres)** avec :

- une **moyenne centrée** (≈ 0 par défaut),
- une **dispersion contrôlée** (pas 12 ennemis mortels day 1),
- **quelques ennemis naturels** et **quelques alliés naturels** (sélectionnés de façon “logique” : friction/opposition vs compatibilité),
- tout en restant **directionnel** (A→B ≠ B→A).

Je te la donne sous forme de **fonction utilitaire** (plus simple à brancher où tu veux). Elle suppose que tu as déjà `compute_baseline_relation(a_profile, b_profile)` et la classe `FactionRelationScore`.

---

## `FactionRelationsUtil.gd` (ou à coller dans un manager)

```gdscript
# Godot 4.x
class_name FactionRelationsUtil
extends RefCounted

static func initialize_relations_for_faction(
	source_faction_id: StringName,
	faction_profiles: Dictionary, # Dictionary[StringName, FactionProfile]
	rng: RandomNumberGenerator,
	params: Dictionary = {},
	baseline_params: Dictionary = {}
) -> Dictionary:
	# Returns: Dictionary[StringName, FactionRelationScore] (A -> others)

	if not faction_profiles.has(source_faction_id):
		return {}

	var a: FactionProfile = faction_profiles[source_faction_id]
	var targets: Array[StringName] = []
	for fid in faction_profiles.keys():
		if StringName(fid) != source_faction_id:
			targets.append(StringName(fid))

	if targets.is_empty():
		return {}

	# ---- Tunables (defaults) ----
	var desired_mean: float = float(params.get("desired_mean", 0.0))         # center around 0
	var desired_std: float = float(params.get("desired_std", 22.0))          # spread control
	var min_scale: float = float(params.get("min_scale", 0.70))
	var max_scale: float = float(params.get("max_scale", 1.20))

	var noise: int = int(params.get("noise", 3))                              # small random jitter in relation
	var tension_cap: float = float(params.get("tension_cap", 40.0))

	var ally_min: int = int(params.get("ally_min", 1))
	var ally_max: int = int(params.get("ally_max", 2))
	var enemy_min: int = int(params.get("enemy_min", 1))
	var enemy_max: int = int(params.get("enemy_max", 2))

	# Boosts applied to selected natural allies/enemies
	var ally_rel_boost: int = int(params.get("ally_rel_boost", 18))
	var ally_trust_boost: int = int(params.get("ally_trust_boost", 14))
	var ally_tension_delta: float = float(params.get("ally_tension_delta", -10.0))

	var enemy_rel_boost: int = int(params.get("enemy_rel_boost", -22))
	var enemy_trust_boost: int = int(params.get("enemy_trust_boost", -16))
	var enemy_tension_delta: float = float(params.get("enemy_tension_delta", +15.0))
	var enemy_grievance_init: float = float(params.get("enemy_grievance_init", 6.0))

	# Hard caps on extremes to avoid too many day-1 dooms
	var min_relation_cap: int = int(params.get("min_relation_cap", -85))
	var max_relation_cap: int = int(params.get("max_relation_cap", +85))

	# ---- 1) Raw baseline compute for all targets ----
	var raw_rel: Array[float] = []
	var init_map: Dictionary = {} # fid -> {relation, friction, trust, tension}
	for fid in targets:
		var b: FactionProfile = faction_profiles[fid]
		var init := FactionProfile.compute_baseline_relation(a, b, baseline_params)
		# ensure tension cap here too
		init["tension"] = min(float(init.get("tension", 0.0)), tension_cap)
		init_map[fid] = init
		raw_rel.append(float(init["relation"]))

	# ---- 2) Center mean and normalize spread (std) ----
	var mean := _mean(raw_rel)
	var std := _std(raw_rel, mean)

	# shift to desired mean
	var shift := desired_mean - mean

	# scale to desired std (soft)
	var scale := 1.0
	if std > 0.001:
		scale = desired_std / std
	scale = clampf(scale, min_scale, max_scale)

	# ---- 3) Build preliminary relation scores ----
	var out: Dictionary[StringName, FactionRelationScore] = {}
	for fid in targets:
		var init := init_map[fid]
		var rel0 := float(init["relation"])

		var rel := (rel0 + shift - desired_mean) * scale + desired_mean

		# small jitter to avoid perfectly symmetric worlds
		if noise > 0:
			rel += float(rng.randi_range(-noise, noise))

		rel = clampf(rel, float(min_relation_cap), float(max_relation_cap))

		var rs := FactionRelationScore.new(fid)
		rs.relation = int(round(rel))
		rs.trust = int(init.get("trust", 0))
		rs.tension = float(init.get("tension", 0.0))
		rs.grievance = 0.0
		rs.weariness = 0.0
		rs.last_event_day = -999999
		rs.cooldown_until_day = -999999
		rs.clamp_all()

		out[fid] = rs

	# ---- 4) Pick a few natural enemies and allies (coherence globale) ----
	var enemy_count := rng.randi_range(enemy_min, enemy_max)
	var ally_count := rng.randi_range(ally_min, ally_max)

	# Score candidates (use baseline friction + negativity etc.)
	var enemy_candidates: Array = []
	var ally_candidates: Array = []

	for fid in targets:
		var init := init_map[fid]
		var rs: FactionRelationScore = out[fid]

		var friction := float(init.get("friction", 0.0))
		var neg := max(0.0, -float(rs.relation))

		# Enemies: friction + neg + low trust
		var enemy_score := (0.65*friction) + (0.55*neg) + (0.25*max(0.0, -float(rs.trust)))
		enemy_candidates.append({"fid": fid, "score": enemy_score})

		# Allies: high relation + trust - friction
		var ally_score := (0.70*float(rs.relation)) + (0.45*float(rs.trust)) - (0.35*friction)
		ally_candidates.append({"fid": fid, "score": ally_score})

	enemy_candidates.sort_custom(func(ae, be): return ae["score"] > be["score"])
	ally_candidates.sort_custom(func(ae, be): return ae["score"] > be["score"])

	var chosen_enemies: Array[StringName] = []
	for i in range(min(enemy_count, enemy_candidates.size())):
		chosen_enemies.append(StringName(enemy_candidates[i]["fid"]))

	var chosen_allies: Array[StringName] = []
	for i in range(ally_candidates.size()):
		if chosen_allies.size() >= ally_count:
			break
		var fid: StringName = StringName(ally_candidates[i]["fid"])
		if chosen_enemies.has(fid):
			continue
		chosen_allies.append(fid)

	# ---- 5) Apply ally/enemy boosts (creates a few “peaks” in the distribution) ----
	for fid in chosen_enemies:
		var rs: FactionRelationScore = out[fid]
		rs.apply_delta(
			enemy_rel_boost,
			enemy_trust_boost,
			enemy_grievance_init,
			enemy_tension_delta,
			0.0
		)

	for fid in chosen_allies:
		var rs: FactionRelationScore = out[fid]
		rs.apply_delta(
			ally_rel_boost,
			ally_trust_boost,
			0.0,
			ally_tension_delta,
			0.0
		)

	# Optional: ensure final mean stays centered-ish (small correction only)
	if bool(params.get("final_recenter", true)):
		_recentre_relations(out, desired_mean, 0.35) # 35% recenter strength

	return out


# ------------------ helpers ------------------

static func _mean(arr: Array) -> float:
	if arr.is_empty():
		return 0.0
	var s := 0.0
	for v in arr:
		s += float(v)
	return s / float(arr.size())

static func _std(arr: Array, mean: float) -> float:
	if arr.size() <= 1:
		return 0.0
	var s := 0.0
	for v in arr:
		var d := float(v) - mean
		s += d * d
	return sqrt(s / float(arr.size()))

static func _recentre_relations(map: Dictionary, desired_mean: float, strength: float) -> void:
	# strength 0..1 : how much to recenter the final relation mean
	var vals: Array[float] = []
	for fid in map.keys():
		vals.append(float(map[fid].relation))
	var mean := _mean(vals)
	var shift := (desired_mean - mean) * clampf(strength, 0.0, 1.0)
	for fid in map.keys():
		var rs: FactionRelationScore = map[fid]
		rs.relation = clampi(int(round(float(rs.relation) + shift)), -100, 100)
```

---

## Usage typique (dans ton FactionManager)
```gdscript
# faction_profiles: Dictionary[StringName, FactionProfile]
# relations_of_A := Dictionary[StringName, FactionRelationScore]
var relations_of_A := FactionRelationsUtil.initialize_relations_for_faction(
	a_id,
	faction_profiles,
	rng,
	{
		"desired_mean": 0.0,
		"desired_std": 22.0,
		"enemy_min": 1, "enemy_max": 2,
		"ally_min": 1, "ally_max": 2
	}
)
```

---

## Pourquoi ça donne une “cohérence globale”
- La compatibilité axes/personnalité est déjà dans `compute_baseline_relation()`.
- Ici, on **corrige la distribution** (centrage + std) pour éviter un monde “trop noir” ou “trop rose”.
- On **crée volontairement quelques pics** (alliés/ennemis naturels) au lieu d’un bruit uniforme.

---

Si tu veux, la **brique suivante** (utile pour ton ArcManager) : une fonction `initialize_relations_world()` qui initialise **toutes** les factions en une passe et peut, optionnellement, appliquer une contrainte de **réciprocité légère** (ex : A→B et B→A convergent à 70% sans être identiques).

Moi:
Ok brique suivante (utile pour ton ArcManager) : une fonction initialize_relations_world() qui initialise toutes les factions en une passe et peut, optionnellement, appliquer une contrainte de réciprocité légère (ex : A→B et B→A convergent à 70% sans être identiques).

ChatGPT:
Voici `initialize_relations_world()` : une passe complète qui :

1) initialise **A→(tous les autres)** pour chaque faction via `initialize_relations_for_faction()`,
2) applique optionnellement une **réciprocité légère** (A→B et B→A convergent partiellement),
3) garde des relations **directionnelles** (pas parfaitement symétriques).

Je l’ajoute dans `FactionRelationsUtil.gd` (même fichier que la fonction précédente).

---

## `initialize_relations_world()` + réciprocité

```gdscript
# --- In FactionRelationsUtil.gd ---

static func initialize_relations_world(
	faction_profiles: Dictionary, # Dictionary[StringName, FactionProfile]
	rng: RandomNumberGenerator,
	world_params: Dictionary = {},
	per_faction_params: Dictionary = {},
	baseline_params: Dictionary = {}
) -> Dictionary:
	# Returns:
	# Dictionary[StringName, Dictionary[StringName, FactionRelationScore]]
	# i.e. world_relations[A][B] = score (directional)

	var ids: Array[StringName] = []
	for fid in faction_profiles.keys():
		ids.append(StringName(fid))

	var world: Dictionary = {}
	if ids.size() <= 1:
		return world

	# --- Pass 1: directional initialization for each faction ---
	for a_id in ids:
		world[a_id] = initialize_relations_for_faction(
			a_id,
			faction_profiles,
			rng,
			per_faction_params,
			baseline_params
		)

	# --- Pass 2: optional reciprocity convergence ---
	var apply_recip := bool(world_params.get("apply_reciprocity", true))
	if apply_recip:
		var reciprocity_strength := float(world_params.get("reciprocity_strength", 0.70)) # 0..1
		var keep_asymmetry := float(world_params.get("keep_asymmetry", 0.30))            # 0..1
		var reciprocity_noise := int(world_params.get("reciprocity_noise", 2))           # small jitter
		var max_change_per_pair := int(world_params.get("max_change_per_pair", 18))      # clamp per pair update

		_apply_reciprocity(
			world,
			ids,
			rng,
			reciprocity_strength,
			keep_asymmetry,
			reciprocity_noise,
			max_change_per_pair
		)

	# --- Pass 3: optional global clamps / sanity ---
	if bool(world_params.get("final_global_sanity", true)):
		_global_sanity_pass(world, ids, world_params)

	return world


static func _apply_reciprocity(
	world: Dictionary,
	ids: Array[StringName],
	rng: RandomNumberGenerator,
	reciprocity_strength: float,
	keep_asymmetry: float,
	reciprocity_noise: int,
	max_change_per_pair: int
) -> void:
	reciprocity_strength = clampf(reciprocity_strength, 0.0, 1.0)
	keep_asymmetry = clampf(keep_asymmetry, 0.0, 1.0)

	for i in range(ids.size()):
		var a_id := ids[i]
		for j in range(i + 1, ids.size()):
			var b_id := ids[j]

			var map_a: Dictionary = world.get(a_id, {})
			var map_b: Dictionary = world.get(b_id, {})
			if not map_a.has(b_id) or not map_b.has(a_id):
				continue

			var ab: FactionRelationScore = map_a[b_id]
			var ba: FactionRelationScore = map_b[a_id]

			# --- Relation reciprocity ---
			var ab_rel := float(ab.relation)
			var ba_rel := float(ba.relation)
			var avg_rel := (ab_rel + ba_rel) * 0.5

			# asymmetry target: keep part of (ab - ba)
			var asym := (ab_rel - ba_rel) * keep_asymmetry

			var ab_target := avg_rel + asym
			var ba_target := avg_rel - asym

			# move each towards target by reciprocity_strength
			var ab_new := lerp(ab_rel, ab_target, reciprocity_strength)
			var ba_new := lerp(ba_rel, ba_target, reciprocity_strength)

			# tiny noise to avoid perfect pair patterns
			if reciprocity_noise > 0:
				ab_new += float(rng.randi_range(-reciprocity_noise, reciprocity_noise))
				ba_new += float(rng.randi_range(-reciprocity_noise, reciprocity_noise))

			# clamp change per pair so you don't destroy natural enemies/allies too much
			ab_new = _clamp_delta(ab_rel, ab_new, float(max_change_per_pair))
			ba_new = _clamp_delta(ba_rel, ba_new, float(max_change_per_pair))

			ab.relation = clampi(int(round(ab_new)), -100, 100)
			ba.relation = clampi(int(round(ba_new)), -100, 100)

			# --- Trust reciprocity (softer) ---
			var ab_tr := float(ab.trust)
			var ba_tr := float(ba.trust)
			var avg_tr := (ab_tr + ba_tr) * 0.5
			var asym_tr := (ab_tr - ba_tr) * (keep_asymmetry * 0.8)

			var ab_tr_target := avg_tr + asym_tr
			var ba_tr_target := avg_tr - asym_tr

			var ab_tr_new := lerp(ab_tr, ab_tr_target, reciprocity_strength * 0.55)
			var ba_tr_new := lerp(ba_tr, ba_tr_target, reciprocity_strength * 0.55)

			ab.trust = clampi(int(round(ab_tr_new)), -100, 100)
			ba.trust = clampi(int(round(ba_tr_new)), -100, 100)

			# --- Tension reciprocity (makes arcs more stable) ---
			# Tension converges faster than relation (keeps wars from being too one-sided).
			var ab_te := ab.tension
			var ba_te := ba.tension
			var avg_te := (ab_te + ba_te) * 0.5

			ab.tension = clampf(lerp(ab_te, avg_te, reciprocity_strength * 0.80), 0.0, 100.0)
			ba.tension = clampf(lerp(ba_te, avg_te, reciprocity_strength * 0.80), 0.0, 100.0)

			ab.clamp_all()
			ba.clamp_all()


static func _clamp_delta(old_v: float, new_v: float, max_delta: float) -> float:
	var d := new_v - old_v
	if d > max_delta:
		return old_v + max_delta
	if d < -max_delta:
		return old_v - max_delta
	return new_v


static func _global_sanity_pass(world: Dictionary, ids: Array[StringName], world_params: Dictionary) -> void:
	# Optional: avoid too many extreme relations globally (helps ArcManager).
	# You can disable or keep very light.
	var max_extremes_per_faction := int(world_params.get("max_extremes_per_faction", 2)) # count of relations <= -80
	for a_id in ids:
		var map_a: Dictionary = world.get(a_id, {})
		if map_a.is_empty():
			continue

		# collect extremes
		var negatives: Array = []
		for b_id in map_a.keys():
			var rs: FactionRelationScore = map_a[b_id]
			if rs.relation <= -80:
				negatives.append({"b": b_id, "rel": rs.relation})

		if negatives.size() <= max_extremes_per_faction:
			continue

		# soften the lowest ones a bit (keep the top few as "true nemesis")
		negatives.sort_custom(func(x, y): return x["rel"] < y["rel"]) # most negative first
		for k in range(max_extremes_per_faction, negatives.size()):
			var b_id := negatives[k]["b"]
			var rs2: FactionRelationScore = map_a[b_id]
			rs2.relation = min(rs2.relation + 12, -60)  # soften towards -60
			rs2.tension = max(0.0, rs2.tension - 8.0)
			rs2.clamp_all()
```

---

## Exemple d’appel

```gdscript
var world_rel := FactionRelationsUtil.initialize_relations_world(
	faction_profiles,
	rng,
	{
		"apply_reciprocity": true,
		"reciprocity_strength": 0.70,
		"keep_asymmetry": 0.30,
		"reciprocity_noise": 2,
		"max_change_per_pair": 18,
		"final_global_sanity": true
	},
	{
		"desired_mean": 0.0,
		"desired_std": 22.0,
		"enemy_min": 1, "enemy_max": 2,
		"ally_min": 1, "ally_max": 2
	},
	{
		# baseline relation tuning forwarded to compute_baseline_relation()
		"w_axis_similarity": 80.0,
		"w_cross_conflict": 55.0
	}
)
```

---

### Pourquoi la réciprocité “70% sans être identiques” marche bien
- `reciprocity_strength` rapproche les deux directions vers une moyenne,
- `keep_asymmetry` conserve une partie de l’écart initial (ex : “A respecte B, mais B méprise A”),
- un peu de bruit + un clamp `max_change_per_pair` évitent de casser tes “alliés/ennemis naturels”.

---

Si tu veux, prochaine brique ArcManager : une fonction `compute_arc_event_chance(A->B score)` qui convertit **tension + friction + relation + personnalité** en probabilité d’incident, et une table de sélection d’`arc_action_type` (raid/ultimatum/truce/etc.) à partir de ces mêmes métriques.

Moi:
une fonction compute_arc_event_chance(A->B score) qui convertit tension + friction + relation + personnalité en probabilité d’incident, et une table de sélection d’arc_action_type (raid/ultimatum/truce/etc.) à partir de ces mêmes métriques.

ChatGPT:
Voici une implémentation **prête à brancher** (Godot 4 / GDScript) :

- `compute_arc_event_chance(A→B)` : convertit **tension + friction + relation + grief + fatigue + personnalité** en **proba d’incident** (0..1), en respectant le cooldown.
- `select_arc_action_type(A→B)` : table de sélection **extensible** (raid / ultimatum / trêve / réparations / sabotage / guerre / ignore), basée sur les mêmes métriques, avec **weighted-random** (pas déterministe).

> Reco : ajoute `friction` dans `FactionRelationScore` (sinon tu dois la recalculer à chaque tick). Je l’utilise ci-dessous.

---

## 1) Petite extension : ajouter `friction` au `FactionRelationScore`

Dans `FactionRelationScore.gd` :

```gdscript
var friction: float = 0.0  # 0..100 (volatilité / friction idéologique)
```

Et dans `clamp_all()` :

```gdscript
friction = clampf(friction, METER_MIN, METER_MAX)
```

Quand tu initialises (baseline), fais :

```gdscript
rs.friction = init["friction"]
```

---

## 2) Utilitaire Arc : proba d’incident + sélection d’action

Tu peux mettre ça dans `ArcManager.gd` ou un `ArcDecisionUtil.gd`.

```gdscript
# Godot 4.x
class_name ArcDecisionUtil
extends RefCounted

# --- Action types (StringName) ---
const ARC_IGNORE: StringName = &"arc.ignore"
const ARC_ULTIMATUM: StringName = &"arc.ultimatum"
const ARC_REPARATIONS: StringName = &"arc.reparations"
const ARC_RAID: StringName = &"arc.raid"
const ARC_SABOTAGE: StringName = &"arc.sabotage"
const ARC_TRUCE_TALKS: StringName = &"arc.truce_talks"
const ARC_DECLARE_WAR: StringName = &"arc.declare_war"
const ARC_ALLIANCE_OFFER: StringName = &"arc.alliance_offer"

static func compute_arc_event_chance(
	rel: FactionRelationScore,     # A -> B
	a_profile: FactionProfile,     # personnalité du "décideur" A
	b_profile: FactionProfile,     # pas forcément utile tout de suite, mais futur-proof
	current_day: int,
	params: Dictionary = {}
) -> float:
	# Cooldown => pas d’event
	if rel.is_on_cooldown(current_day):
		return 0.0

	var base: float = float(params.get("base", 0.015))             # 1.5% mini
	var max_p: float = float(params.get("max_p", 0.35))            # cap dur (tick journalier)
	var tension_w: float = float(params.get("tension_w", 0.22))
	var friction_w: float = float(params.get("friction_w", 0.14))
	var grievance_w: float = float(params.get("grievance_w", 0.10))
	var negrel_w: float = float(params.get("negrel_w", 0.20))
	var weariness_w: float = float(params.get("weariness_w", 0.18))

	# personnalité (A filtre l’impulsivité)
	var aggr := a_profile.get_personality(FactionProfile.PERS_AGGRESSION, 0.5)
	var veng := a_profile.get_personality(FactionProfile.PERS_VENGEFULNESS, 0.5)
	var diplo := a_profile.get_personality(FactionProfile.PERS_DIPLOMACY, 0.5)
	var risk := a_profile.get_personality(FactionProfile.PERS_RISK_AVERSION, 0.5)
	var expa := a_profile.get_personality(FactionProfile.PERS_EXPANSIONISM, 0.5)

	var p := base

	var tension := rel.tension / 100.0
	var friction := rel.friction / 100.0
	var grievance := rel.grievance / 100.0
	var weariness := rel.weariness / 100.0
	var negrel := max(0.0, -float(rel.relation) / 100.0)

	p += tension * tension_w
	p += friction * friction_w
	p += grievance * grievance_w
	p += negrel * negrel_w
	p -= weariness * weariness_w

	# personnalité : agressif/vindicatif/expa => + ; diplomate/prudent => -
	p += (aggr - 0.5) * float(params.get("aggr_w", 0.10))
	p += (veng - 0.5) * float(params.get("veng_w", 0.07))
	p += (expa - 0.5) * float(params.get("expa_w", 0.05))
	p -= (diplo - 0.5) * float(params.get("diplo_w", 0.11))
	p -= (risk - 0.5) * float(params.get("risk_w", 0.05))

	# amortisseur : si relation et trust déjà bons, on coupe beaucoup
	var trust_pos := max(0.0, float(rel.trust) / 100.0)
	var rel_pos := max(0.0, float(rel.relation) / 100.0)
	var goodwill := 0.5 * trust_pos + 0.5 * rel_pos
	p *= (1.0 - goodwill * float(params.get("goodwill_damp", 0.55)))

	return clampf(p, 0.0, max_p)


static func select_arc_action_type(
	rel: FactionRelationScore,      # A -> B
	a_profile: FactionProfile,
	b_profile: FactionProfile,
	rng: RandomNumberGenerator,
	current_day: int,
	params: Dictionary = {}
) -> StringName:
	# Pré-conditions globales
	if rel.is_on_cooldown(current_day):
		return ARC_IGNORE

	# --- Inputs normalisés ---
	var tension := rel.tension / 100.0
	var friction := rel.friction / 100.0
	var grievance := rel.grievance / 100.0
	var weariness := rel.weariness / 100.0
	var negrel := max(0.0, -float(rel.relation) / 100.0)
	var posrel := max(0.0, float(rel.relation) / 100.0)
	var trust_pos := max(0.0, float(rel.trust) / 100.0)

	# personnalité A
	var aggr := a_profile.get_personality(FactionProfile.PERS_AGGRESSION, 0.5)
	var veng := a_profile.get_personality(FactionProfile.PERS_VENGEFULNESS, 0.5)
	var diplo := a_profile.get_personality(FactionProfile.PERS_DIPLOMACY, 0.5)
	var risk := a_profile.get_personality(FactionProfile.PERS_RISK_AVERSION, 0.5)
	var expa := a_profile.get_personality(FactionProfile.PERS_EXPANSIONISM, 0.5)
	var integ := a_profile.get_personality(FactionProfile.PERS_INTEGRATIONISM, 0.5)
	# (optionnel) si tu ajoutes plus tard pers.cunning : fallback 0.5
	var cunning := float(a_profile.personality.get(&"pers.cunning", 0.5))

	# contexte monde (optionnel)
	var external_threat := float(params.get("external_threat", 0.0)) # 0..1 (crise, ennemi commun)
	var opportunity := float(params.get("opportunity", 0.55))        # 0..1 (si tu n’as rien, laisse ~0.55)

	# température softmax (plus bas => choix plus déterministe)
	var temperature := float(params.get("temperature", 0.18))

	# --- Scores (0..+) ---
	var candidates: Array = []

	# IGNORE : essentiel en journalier
	var s_ignore := 0.0
	s_ignore += 0.90 * weariness
	s_ignore += 0.35 * risk
	s_ignore += 0.25 * diplo
	s_ignore -= 0.60 * grievance
	s_ignore -= 0.40 * tension
	candidates.append({"type": ARC_IGNORE, "s": max(0.0, s_ignore)})

	# ULTIMATUM : pression sans escalade
	var s_ult := 0.0
	s_ult += 0.85 * grievance
	s_ult += 0.45 * tension
	s_ult += 0.25 * risk
	s_ult += 0.20 * diplo
	s_ult += 0.25 * negrel
	s_ult -= 0.35 * weariness
	candidates.append({"type": ARC_ULTIMATUM, "s": max(0.0, s_ult)})

	# REPARATIONS : possible si la relation n’est pas trop noire et que A est diplomate/intégrateur
	var s_rep := 0.0
	s_rep += 0.55 * diplo
	s_rep += 0.35 * integ
	s_rep += 0.25 * weariness
	s_rep += 0.25 * tension
	s_rep += 0.20 * trust_pos
	s_rep -= 0.55 * negrel
	s_rep -= 0.40 * grievance
	# précondition douce
	if rel.relation > -60:
		candidates.append({"type": ARC_REPARATIONS, "s": max(0.0, s_rep)})

	# TRUCE_TALKS : fatigue haute + tension haute => sortie
	var s_truce := 0.0
	s_truce += 0.95 * weariness
	s_truce += 0.55 * tension
	s_truce += 0.55 * diplo
	s_truce += 0.25 * risk
	s_truce += 0.35 * external_threat
	s_truce -= 0.65 * grievance
	s_truce -= 0.45 * (aggr)
	candidates.append({"type": ARC_TRUCE_TALKS, "s": max(0.0, s_truce)})

	# RAID : représaille “courte”, satisfait la grievance mais baisse trust ensuite (effets ailleurs)
	var s_raid := 0.0
	s_raid += 0.95 * grievance
	s_raid += 0.70 * tension
	s_raid += 0.55 * negrel
	s_raid += 0.70 * opportunity
	s_raid += 0.55 * aggr
	s_raid += 0.35 * veng
	s_raid += 0.25 * expa
	s_raid -= 0.80 * weariness
	s_raid -= 0.35 * diplo
	if tension >= 0.20: # pas de raid si tout est froid
		candidates.append({"type": ARC_RAID, "s": max(0.0, s_raid)})

	# SABOTAGE : utile quand risk est haut (éviter frontal) + cunning
	var s_sab := 0.0
	s_sab += 0.65 * grievance
	s_sab += 0.45 * tension
	s_sab += 0.55 * cunning
	s_sab += 0.35 * risk
	s_sab += 0.35 * opportunity
	s_sab += 0.25 * negrel
	s_sab -= 0.55 * weariness
	s_sab -= 0.25 * diplo
	if tension >= 0.25:
		candidates.append({"type": ARC_SABOTAGE, "s": max(0.0, s_sab)})

	# DECLARE_WAR : rare, conditions dures
	var s_war := 0.0
	s_war += 1.10 * tension
	s_war += 0.85 * grievance
	s_war += 0.80 * negrel
	s_war += 0.55 * opportunity
	s_war += 0.35 * expa
	s_war += 0.30 * aggr
	s_war -= 1.00 * weariness
	s_war -= 0.25 * external_threat # si menace externe, moins envie de guerre interne
	if rel.relation <= -55 and rel.tension >= 65.0 and rel.weariness <= 55.0:
		candidates.append({"type": ARC_DECLARE_WAR, "s": max(0.0, s_war)})

	# ALLIANCE_OFFER : si menace externe + relation pas trop négative
	var s_alliance := 0.0
	s_alliance += 0.95 * external_threat
	s_alliance += 0.55 * diplo
	s_alliance += 0.45 * integ
	s_alliance += 0.25 * trust_pos
	s_alliance += 0.15 * posrel
	s_alliance -= 0.55 * negrel
	s_alliance -= 0.25 * grievance
	if external_threat >= 0.35 and rel.relation > -35:
		candidates.append({"type": ARC_ALLIANCE_OFFER, "s": max(0.0, s_alliance)})

	# --- Weighted random via softmax-like ---
	return _pick_by_softmax(rng, candidates, temperature)


static func _pick_by_softmax(rng: RandomNumberGenerator, candidates: Array, temperature: float) -> StringName:
	temperature = max(0.05, temperature)

	var weights: Array[float] = []
	var sum_w := 0.0

	for c in candidates:
		var s := float(c["s"])
		# exp(s / temp) mais clamp pour éviter overflow
		var w := exp(clampf(s / temperature, -20.0, 20.0))
		weights.append(w)
		sum_w += w

	if sum_w <= 0.0:
		return ARC_IGNORE

	var r := rng.randf() * sum_w
	var acc := 0.0
	for i in range(candidates.size()):
		acc += weights[i]
		if r <= acc:
			return StringName(candidates[i]["type"])

	return StringName(candidates.back()["type"])
```

---

## 3) Comment l’utiliser dans ton `ArcManager.tick_day()`

Schéma typique (direction A→B) :

```gdscript
var p := ArcDecisionUtil.compute_arc_event_chance(rel_ab, profile_a, profile_b, day, {
	"max_p": 0.35
})
if rng.randf() < p:
	var action := ArcDecisionUtil.select_arc_action_type(rel_ab, profile_a, profile_b, rng, day, {
		"external_threat": world_external_threat, # 0..1
		"opportunity": opportunity_ab,            # 0..1 (optionnel)
		"temperature": 0.18
	})
	# spawn offer selon action
	# rel_ab.set_cooldown(day, cooldown_days_for(action))
```

---

## Notes importantes (ArcManager “stable”)
- Tu verras que `IGNORE` et `ULTIMATUM/TRUCE` sortent souvent quand **weariness** monte : c’est exactement ce qui casse la boucle “vengeance ⇒ vengeance”.
- `RAID` est conditionné par `tension`, `opportunity`, et pénalisé par `weariness` + `diplomacy`.
- `DECLARE_WAR` a des **préconditions dures**, sinon tu vas déclarer la guerre trop tôt.

Si tu veux, prochaine brique : une table `cooldown_days_for(action)` + des deltas standards par `arc_action_type` (ce que la résolution LOYAL/NEUTRAL/TRAITOR appliquera sur relation/trust/grievance/tension/weariness).

Moi:
Ok prochaine brique : une table cooldown_days_for(action) + des deltas standards par arc_action_type (ce que la résolution LOYAL/NEUTRAL/TRAITOR appliquera sur relation/trust/grievance/tension/weariness)

ChatGPT:
Voici une brique **data-driven** (table + helpers) :

- `cooldown_days_for(action, rng)` : renvoie un cooldown (min..max + jitter).
- `get_arc_deltas(action, choice)` : renvoie les deltas **A→B** et **B→A**.
- `apply_arc_resolution(action, choice, rel_ab, rel_ba, day, rng)` : applique les deltas + pose le cooldown (sur les deux liens).

> Convention : **A = giver**, **B = antagonist**.  
> `LOYAL` = le joueur aide **A** (l’action réussit “dans le sens A”).  
> `NEUTRAL` = résultat mitigé.  
> `TRAITOR` = le joueur aide **B** (ou sabote A).

À mettre dans un util genre `ArcEffectTable.gd` (ou dans ton `ArcManager`).

```gdscript
# Godot 4.x
class_name ArcEffectTable
extends RefCounted

# --- Choices (match your QuestManager) ---
const CHOICE_LOYAL: StringName = &"LOYAL"
const CHOICE_NEUTRAL: StringName = &"NEUTRAL"
const CHOICE_TRAITOR: StringName = &"TRAITOR"

# --- Action types (same as ArcDecisionUtil) ---
const ARC_IGNORE: StringName = &"arc.ignore"
const ARC_ULTIMATUM: StringName = &"arc.ultimatum"
const ARC_REPARATIONS: StringName = &"arc.reparations"
const ARC_RAID: StringName = &"arc.raid"
const ARC_SABOTAGE: StringName = &"arc.sabotage"
const ARC_TRUCE_TALKS: StringName = &"arc.truce_talks"
const ARC_DECLARE_WAR: StringName = &"arc.declare_war"
const ARC_ALLIANCE_OFFER: StringName = &"arc.alliance_offer"

# -----------------------------
# 1) Cooldowns (min..max days)
# -----------------------------
const COOLDOWNS: Dictionary = {
	ARC_IGNORE:        {"min": 1,  "max": 2},
	ARC_ULTIMATUM:     {"min": 2,  "max": 4},
	ARC_REPARATIONS:   {"min": 4,  "max": 6},
	ARC_TRUCE_TALKS:   {"min": 5,  "max": 7},
	ARC_RAID:          {"min": 3,  "max": 5},
	ARC_SABOTAGE:      {"min": 4,  "max": 6},
	ARC_DECLARE_WAR:   {"min": 7,  "max": 10},
	ARC_ALLIANCE_OFFER:{"min": 6,  "max": 9},
}

static func cooldown_days_for(action: StringName, rng: RandomNumberGenerator) -> int:
	var cd := COOLDOWNS.get(action, {"min": 3, "max": 5})
	return rng.randi_range(int(cd["min"]), int(cd["max"]))

# --------------------------------------------------------
# 2) Deltas standards par action + choix (A->B, B->A)
#    Keys: d_relation(int), d_trust(int), d_grievance(float), d_tension(float), d_weariness(float)
# --------------------------------------------------------
const EFFECTS: Dictionary = {
	ARC_IGNORE: {
		CHOICE_LOYAL: {
			"ab": {"d_relation":  0,  "d_trust":  0,  "d_grievance": -3.0, "d_tension": -5.0, "d_weariness": -2.0},
			"ba": {"d_relation":  0,  "d_trust":  0,  "d_grievance": -2.0, "d_tension": -4.0, "d_weariness": -2.0},
		},
		CHOICE_NEUTRAL: {
			"ab": {"d_relation":  0,  "d_trust":  0,  "d_grievance": -1.0, "d_tension": -2.0, "d_weariness": -1.0},
			"ba": {"d_relation":  0,  "d_trust":  0,  "d_grievance": -1.0, "d_tension": -2.0, "d_weariness": -1.0},
		},
		CHOICE_TRAITOR: {
			"ab": {"d_relation": -2,  "d_trust": -2,  "d_grievance": +2.0, "d_tension": +2.0, "d_weariness":  0.0},
			"ba": {"d_relation": -2,  "d_trust": -2,  "d_grievance": +2.0, "d_tension": +2.0, "d_weariness":  0.0},
		},
	},

	ARC_ULTIMATUM: {
		CHOICE_LOYAL: {
			# “A obtient des concessions” : A se sent payé (grievance -), B en garde une rancune (grievance +)
			"ab": {"d_relation": -4,  "d_trust": -2,  "d_grievance": -10.0, "d_tension": +2.0, "d_weariness":  0.0},
			"ba": {"d_relation": -6,  "d_trust": -4,  "d_grievance":  +6.0, "d_tension": +4.0, "d_weariness":  0.0},
		},
		CHOICE_NEUTRAL: {
			"ab": {"d_relation": -2,  "d_trust": -2,  "d_grievance":  -2.0, "d_tension": +1.0, "d_weariness":  0.0},
			"ba": {"d_relation": -2,  "d_trust": -1,  "d_grievance":  +2.0, "d_tension": +1.0, "d_weariness":  0.0},
		},
		CHOICE_TRAITOR: {
			# “A humilié / décrédibilisé” : A rancune monte, trust s’effondre
			"ab": {"d_relation": -6,  "d_trust": -6,  "d_grievance":  +6.0, "d_tension": +4.0, "d_weariness":  0.0},
			"ba": {"d_relation": -3,  "d_trust": -1,  "d_grievance":   0.0, "d_tension": +2.0, "d_weariness":  0.0},
		},
	},

	ARC_REPARATIONS: {
		CHOICE_LOYAL: {
			# Réparations acceptées : forte détente bilatérale
			"ab": {"d_relation": +12, "d_trust": +10, "d_grievance":  -8.0, "d_tension": -10.0, "d_weariness": -2.0},
			"ba": {"d_relation": +16, "d_trust": +12, "d_grievance": -18.0, "d_tension": -12.0, "d_weariness": -2.0},
		},
		CHOICE_NEUTRAL: {
			"ab": {"d_relation":  +6, "d_trust":  +5, "d_grievance":  -4.0, "d_tension":  -6.0, "d_weariness": -1.0},
			"ba": {"d_relation":  +8, "d_trust":  +6, "d_grievance":  -9.0, "d_tension":  -7.0, "d_weariness": -1.0},
		},
		CHOICE_TRAITOR: {
			# Réparations sabotées / fraude : backlash
			"ab": {"d_relation":  -8, "d_trust": -10, "d_grievance":  +6.0, "d_tension":  +8.0, "d_weariness": +2.0},
			"ba": {"d_relation": -10, "d_trust": -12, "d_grievance": +10.0, "d_tension": +10.0, "d_weariness": +2.0},
		},
	},

	ARC_TRUCE_TALKS: {
		CHOICE_LOYAL: {
			"ab": {"d_relation":  +8, "d_trust": +12, "d_grievance": -12.0, "d_tension": -18.0, "d_weariness": -4.0},
			"ba": {"d_relation":  +8, "d_trust": +12, "d_grievance": -12.0, "d_tension": -18.0, "d_weariness": -4.0},
		},
		CHOICE_NEUTRAL: {
			"ab": {"d_relation":  +3, "d_trust":  +5, "d_grievance":  -5.0, "d_tension": -10.0, "d_weariness": -2.0},
			"ba": {"d_relation":  +3, "d_trust":  +5, "d_grievance":  -5.0, "d_tension": -10.0, "d_weariness": -2.0},
		},
		CHOICE_TRAITOR: {
			"ab": {"d_relation": -10, "d_trust": -14, "d_grievance":  +8.0, "d_tension": +12.0, "d_weariness": +2.0},
			"ba": {"d_relation": -10, "d_trust": -14, "d_grievance":  +8.0, "d_tension": +12.0, "d_weariness": +2.0},
		},
	},

	ARC_RAID: {
		CHOICE_LOYAL: {
			# “paiement” : A grievance baisse, B grievance monte
			"ab": {"d_relation": -10, "d_trust":  -8, "d_grievance": -15.0, "d_tension": +12.0, "d_weariness": +6.0},
			"ba": {"d_relation": -16, "d_trust": -12, "d_grievance": +18.0, "d_tension": +14.0, "d_weariness": +4.0},
		},
		CHOICE_NEUTRAL: {
			"ab": {"d_relation":  -5, "d_trust":  -4, "d_grievance":  -8.0, "d_tension":  +7.0, "d_weariness": +3.0},
			"ba": {"d_relation":  -8, "d_trust":  -6, "d_grievance": +10.0, "d_tension":  +8.0, "d_weariness": +2.0},
		},
		CHOICE_TRAITOR: {
			# Raid retourné / saboté : A se radicalise, B “satisfait” un peu
			"ab": {"d_relation": -12, "d_trust": -10, "d_grievance": +12.0, "d_tension": +12.0, "d_weariness": +7.0},
			"ba": {"d_relation":  -8, "d_trust":  -6, "d_grievance":  -8.0, "d_tension": +10.0, "d_weariness": +3.0},
		},
	},

	ARC_SABOTAGE: {
		CHOICE_LOYAL: {
			"ab": {"d_relation":  -6, "d_trust":  -6, "d_grievance":  -8.0, "d_tension":  +8.0, "d_weariness": +2.0},
			"ba": {"d_relation": -10, "d_trust":  -8, "d_grievance": +10.0, "d_tension": +10.0, "d_weariness": +3.0},
		},
		CHOICE_NEUTRAL: {
			"ab": {"d_relation":  -3, "d_trust":  -3, "d_grievance":  -4.0, "d_tension":  +5.0, "d_weariness": +1.0},
			"ba": {"d_relation":  -5, "d_trust":  -4, "d_grievance":  +6.0, "d_tension":  +6.0, "d_weariness": +1.0},
		},
		CHOICE_TRAITOR: {
			# double-jeu : A se braque, B est “un peu payé”
			"ab": {"d_relation":  -8, "d_trust": -10, "d_grievance":  +6.0, "d_tension":  +8.0, "d_weariness": +3.0},
			"ba": {"d_relation":  -6, "d_trust":  -4, "d_grievance":  -4.0, "d_tension":  +6.0, "d_weariness": +2.0},
		},
	},

	ARC_DECLARE_WAR: {
		CHOICE_LOYAL: {
			"ab": {"d_relation": -35, "d_trust": -30, "d_grievance": -20.0, "d_tension": +30.0, "d_weariness": +8.0},
			"ba": {"d_relation": -35, "d_trust": -30, "d_grievance": +25.0, "d_tension": +35.0, "d_weariness": +10.0},
		},
		CHOICE_NEUTRAL: {
			"ab": {"d_relation": -15, "d_trust": -12, "d_grievance":  -8.0, "d_tension": +18.0, "d_weariness":  +4.0},
			"ba": {"d_relation": -18, "d_trust": -15, "d_grievance": +12.0, "d_tension": +20.0, "d_weariness":  +6.0},
		},
		CHOICE_TRAITOR: {
			# guerre avortée / retournement politique : A humilié mais pas de guerre totale
			"ab": {"d_relation": -20, "d_trust": -10, "d_grievance": +10.0, "d_tension": +10.0, "d_weariness": +3.0},
			"ba": {"d_relation": -10, "d_trust":  -5, "d_grievance":  -5.0, "d_tension":  +5.0, "d_weariness": +2.0},
		},
	},

	ARC_ALLIANCE_OFFER: {
		CHOICE_LOYAL: {
			"ab": {"d_relation": +20, "d_trust": +22, "d_grievance": -10.0, "d_tension": -15.0, "d_weariness": -3.0},
			"ba": {"d_relation": +20, "d_trust": +22, "d_grievance": -10.0, "d_tension": -15.0, "d_weariness": -3.0},
		},
		CHOICE_NEUTRAL: {
			"ab": {"d_relation": +10, "d_trust": +12, "d_grievance":  -5.0, "d_tension":  -8.0, "d_weariness": -2.0},
			"ba": {"d_relation": +10, "d_trust": +12, "d_grievance":  -5.0, "d_tension":  -8.0, "d_weariness": -2.0},
		},
		CHOICE_TRAITOR: {
			"ab": {"d_relation": -12, "d_trust": -16, "d_grievance":  +8.0, "d_tension": +10.0, "d_weariness": +2.0},
			"ba": {"d_relation": -12, "d_trust": -16, "d_grievance":  +8.0, "d_tension": +10.0, "d_weariness": +2.0},
		},
	},
}

static func get_arc_deltas(action: StringName, choice: StringName) -> Dictionary:
	var by_action := EFFECTS.get(action, null)
	if by_action == null:
		return {}
	var by_choice := by_action.get(choice, null)
	if by_choice == null:
		return {}
	return by_choice

# --------------------------------------------------------
# 3) Apply helper (also sets cooldown for both links)
# --------------------------------------------------------
static func apply_arc_resolution(
	action: StringName,
	choice: StringName,
	rel_ab: FactionRelationScore, # A -> B
	rel_ba: FactionRelationScore, # B -> A
	current_day: int,
	rng: RandomNumberGenerator,
	cooldown_override_days: int = -1
) -> void:
	var d := get_arc_deltas(action, choice)
	if d.is_empty():
		return

	var ab := d["ab"]
	var ba := d["ba"]

	rel_ab.apply_delta(
		int(ab.get("d_relation", 0)),
		int(ab.get("d_trust", 0)),
		float(ab.get("d_grievance", 0.0)),
		float(ab.get("d_tension", 0.0)),
		float(ab.get("d_weariness", 0.0))
	)

	rel_ba.apply_delta(
		int(ba.get("d_relation", 0)),
		int(ba.get("d_trust", 0)),
		float(ba.get("d_grievance", 0.0)),
		float(ba.get("d_tension", 0.0)),
		float(ba.get("d_weariness", 0.0))
	)

	var cd := cooldown_override_days if cooldown_override_days >= 0 else cooldown_days_for(action, rng)
	rel_ab.set_cooldown(current_day, cd)
	rel_ba.set_cooldown(current_day, cd)
```

### Remarques rapides (importantes)
- Les deltas “hostiles” (`RAID/SABOTAGE/DECLARE_WAR`) appliquent le principe **“payer la dette”** : `grievance` baisse côté acteur si succès, mais augmente côté victime → ça évite une boucle symétrique infinie et crée une dynamique crédible.
- `TRUCE_TALKS / REPARATIONS / ALLIANCE_OFFER` sont **bilatéraux** : baisse tension + grief, remonte trust/relation.
- Tu peux ensuite ajouter une couche “personnalité en multiplicateur” en entourant `apply_delta()` d’un `scale = f(aggression, diplomacy, ...)` (mais je te laisse d’abord stabiliser ces valeurs de base).

Si tu veux, prochaine brique : brancher ça directement dans `ArcManager.on_quest_resolution_choice(inst, choice)` en lisant `context.arc_action_type`, `giver_faction_id`, `antagonist_faction_id`, puis en récupérant `rel_ab`/`rel_ba` depuis tes dictionnaires faction→(faction→score).

Moi:
Ok

ChatGPT:
Parfait. Voilà le branchement direct “ArcManager-ready” dans `on_quest_resolution_choice(inst, choice)`.

Hypothèses (adaptables à ton code) :
- `inst.context` contient `giver_faction_id`, `antagonist_faction_id`, `arc_action_type` (ou `arc_reason` si tu préfères), et `is_arc_rivalry=true`.
- Tu as une structure globale :
  - `faction_relations: Dictionary[StringName, Dictionary[StringName, FactionRelationScore]]`
  - où `faction_relations[A][B]` = A→B.
- Les profils :
  - `faction_profiles: Dictionary[StringName, FactionProfile]`.

---

## ArcManager.gd — branchement résolution

```gdscript
func on_quest_resolution_choice(inst: QuestInstance, choice: StringName) -> void:
	# 0) Filtre: uniquement les quêtes d'arc
	if inst == null or inst.context == null:
		return
	if not bool(inst.context.get("is_arc_rivalry", false)):
		return

	var giver_id: StringName = StringName(inst.context.get("giver_faction_id", &""))
	var ant_id: StringName = StringName(inst.context.get("antagonist_faction_id", &""))
	if giver_id == &"" or ant_id == &"":
		return

	# action type stockée dans le context (à toi de choisir le nom)
	var action: StringName = StringName(inst.context.get("arc_action_type", &""))
	if action == &"":
		# fallback (si tu utilisais arc_reason / autre)
		action = StringName(inst.context.get("arc_reason", &"arc.ignore"))

	# 1) Récupérer les liens relationnels A->B et B->A
	var rel_ab: FactionRelationScore = _get_or_create_relation_score(giver_id, ant_id)
	var rel_ba: FactionRelationScore = _get_or_create_relation_score(ant_id, giver_id)
	if rel_ab == null or rel_ba == null:
		return

	# 2) Appliquer effets standards (deltas + cooldown)
	ArcEffectTable.apply_arc_resolution(
		action,
		choice,
		rel_ab,
		rel_ba,
		WorldGameState.day, # ou ton compteur de jour
		_rng                # RandomNumberGenerator de ton sim
	)

	# 3) Optionnel: tags / état “WAR/PEACE/ALLIANCE” selon seuils
	# (tu peux commencer simple et raffiner)
	_post_arc_state_update(giver_id, ant_id, rel_ab, rel_ba)
```

---

## Helpers nécessaires

### 1) Accès sûr à `FactionRelationScore` (création lazy)

```gdscript
# faction_relations: Dictionary[StringName, Dictionary[StringName, FactionRelationScore]]
# faction_profiles: Dictionary[StringName, FactionProfile]

func _get_or_create_relation_score(a_id: StringName, b_id: StringName) -> FactionRelationScore:
	if not faction_relations.has(a_id):
		faction_relations[a_id] = {}

	var map_a: Dictionary = faction_relations[a_id]
	if map_a.has(b_id):
		return map_a[b_id]

	# Création lazy (si jamais ça arrive en cours de jeu)
	if not faction_profiles.has(a_id) or not faction_profiles.has(b_id):
		return null

	var a_prof: FactionProfile = faction_profiles[a_id]
	var b_prof: FactionProfile = faction_profiles[b_id]
	var init := FactionProfile.compute_baseline_relation(a_prof, b_prof)

	var rs := FactionRelationScore.new(b_id)
	rs.relation = int(init["relation"])
	rs.trust = int(init["trust"])
	rs.tension = float(init["tension"])
	rs.friction = float(init.get("friction", 0.0)) # si tu l’as ajouté
	rs.grievance = 0.0
	rs.weariness = 0.0
	rs.clamp_all()

	map_a[b_id] = rs
	faction_relations[a_id] = map_a
	return rs
```

### 2) Mise à jour d’état après résolution (version simple)

Tu peux faire une logique minimaliste basée sur les deux directions :

```gdscript
func _post_arc_state_update(
	a_id: StringName,
	b_id: StringName,
	rel_ab: FactionRelationScore,
	rel_ba: FactionRelationScore
) -> void:
	var rel_mean := 0.5 * (float(rel_ab.relation) + float(rel_ba.relation))
	var tension_mean := 0.5 * (rel_ab.tension + rel_ba.tension)
	var trust_mean := 0.5 * (float(rel_ab.trust) + float(rel_ba.trust))

	# War trigger (simple)
	if rel_mean <= -70.0 and tension_mean >= 70.0:
		# set war state / tags
		# WorldTags.add("WAR_%s_%s" % [a_id, b_id]) etc.
		return

	# Alliance trigger
	if trust_mean >= 65.0 and rel_mean >= 45.0 and tension_mean <= 25.0:
		# set alliance state / tags
		return

	# Peace / resolved rivalry hint
	if tension_mean <= 10.0 and abs(rel_mean) <= 20.0:
		# optionally close rivalry arc / stop generating events for this pair
		return
```

---

## À brancher côté “génération d’offre d’arc”
Quand tu crées une offer, mets dans `context` :

```gdscript
context["is_arc_rivalry"] = true
context["arc_action_type"] = action_type # ex: "arc.raid"
context["giver_faction_id"] = giver_id
context["antagonist_faction_id"] = ant_id
```

Et l’ArcManager n’a plus qu’à lire ça à la résolution.

---

Si tu veux, prochaine étape très utile : intégrer un **multiplicateur personnalité** sur les deltas (ex : une faction pacifique convertit plus une trêve en trust, une vindicative réduit moins la grievance, etc.), tout en gardant la table “valeurs de base” stable.

Moi:
Ok

ChatGPT:
Top. Voilà l’étape suivante : **multiplicateurs de personnalité** appliqués aux deltas, sans casser ta table “base”.

Idée : tu gardes `EFFECTS` comme “valeurs de base”, puis tu scales certains deltas selon la personnalité du camp concerné **au moment d’appliquer**.

## 1) Règles de scaling (simples et efficaces)

Pour un camp X qui subit/applique un delta :

- **Grievance** :
  - réduction de grievance est **moins efficace** si `vengefulness` est haut
- **Trust / Relation** (positifs) :
  - gains sont **plus efficaces** si `diplomacy` et/ou `integrationism` sont hauts
- **Tension** (baisse) :
  - baisse est **plus efficace** si `diplomacy` est haut
- **Tension** (hausse) :
  - hausse est **plus forte** si `aggression` et `vengefulness` sont hauts
- **Weariness** :
  - gain est **plus faible** si `expansionism` est haut
  - gain est **plus fort** si `risk_aversion` est haut

Ça suffit déjà à donner des factions “qui se calment vite” vs “qui s’enlisent”.

---

## 2) Implémentation : `apply_arc_resolution_with_personality(...)`

Ajoute ça dans `ArcEffectTable.gd` (en plus de ta table `EFFECTS` existante).  
Ça remplace l’appel à `apply_arc_resolution()` dans l’ArcManager.

```gdscript
static func apply_arc_resolution_with_personality(
	action: StringName,
	choice: StringName,
	rel_ab: FactionRelationScore,        # A -> B
	rel_ba: FactionRelationScore,        # B -> A
	profile_a: FactionProfile,
	profile_b: FactionProfile,
	current_day: int,
	rng: RandomNumberGenerator,
	cooldown_override_days: int = -1,
	params: Dictionary = {}
) -> void:
	var d := get_arc_deltas(action, choice)
	if d.is_empty():
		return

	var ab := d["ab"] # deltas applied to A->B score (A viewpoint)
	var ba := d["ba"] # deltas applied to B->A score (B viewpoint)

	# Apply scaled deltas for each direction using the personality of the "owner" of that score:
	# - rel_ab belongs to faction A => scale with profile_a
	# - rel_ba belongs to faction B => scale with profile_b
	var ab_scaled := _scale_deltas_by_personality(ab, profile_a, params)
	var ba_scaled := _scale_deltas_by_personality(ba, profile_b, params)

	rel_ab.apply_delta(
		int(ab_scaled["d_relation"]),
		int(ab_scaled["d_trust"]),
		float(ab_scaled["d_grievance"]),
		float(ab_scaled["d_tension"]),
		float(ab_scaled["d_weariness"])
	)

	rel_ba.apply_delta(
		int(ba_scaled["d_relation"]),
		int(ba_scaled["d_trust"]),
		float(ba_scaled["d_grievance"]),
		float(ba_scaled["d_tension"]),
		float(ba_scaled["d_weariness"])
	)

	var cd := cooldown_override_days if cooldown_override_days >= 0 else cooldown_days_for(action, rng)
	rel_ab.set_cooldown(current_day, cd)
	rel_ba.set_cooldown(current_day, cd)


static func _scale_deltas_by_personality(delta: Dictionary, prof: FactionProfile, params: Dictionary) -> Dictionary:
	# Params to tune aggressiveness of scaling
	var k_pos_rel := float(params.get("k_pos_rel", 0.35))      # relation/trust gains
	var k_neg_rel := float(params.get("k_neg_rel", 0.20))      # relation/trust losses
	var k_griev_down := float(params.get("k_griev_down", 0.55))# grievance reduction sensitivity
	var k_griev_up := float(params.get("k_griev_up", 0.25))    # grievance increase sensitivity
	var k_tension_down := float(params.get("k_tension_down", 0.35))
	var k_tension_up := float(params.get("k_tension_up", 0.25))
	var k_wear_gain := float(params.get("k_wear_gain", 0.45))

	var diplo := prof.get_personality(FactionProfile.PERS_DIPLOMACY, 0.5)
	var integ := prof.get_personality(FactionProfile.PERS_INTEGRATIONISM, 0.5)
	var aggr := prof.get_personality(FactionProfile.PERS_AGGRESSION, 0.5)
	var veng := prof.get_personality(FactionProfile.PERS_VENGEFULNESS, 0.5)
	var risk := prof.get_personality(FactionProfile.PERS_RISK_AVERSION, 0.5)
	var expa := prof.get_personality(FactionProfile.PERS_EXPANSIONISM, 0.5)

	var out := {
		"d_relation": int(delta.get("d_relation", 0)),
		"d_trust": int(delta.get("d_trust", 0)),
		"d_grievance": float(delta.get("d_grievance", 0.0)),
		"d_tension": float(delta.get("d_tension", 0.0)),
		"d_weariness": float(delta.get("d_weariness", 0.0)),
	}

	# --- relation/trust ---
	# Gains: diplomacy + integration amplify
	var gain_mul := 1.0 + k_pos_rel * ((diplo - 0.5) + 0.8*(integ - 0.5))
	# Losses: aggression + vengefulness amplify (more punitive worldview)
	var loss_mul := 1.0 + k_neg_rel * ((aggr - 0.5) + 0.8*(veng - 0.5))

	out["d_relation"] = int(round(_scale_signed_int(out["d_relation"], gain_mul, loss_mul)))
	out["d_trust"] = int(round(_scale_signed_int(out["d_trust"], gain_mul, loss_mul)))

	# --- grievance ---
	# If delta is negative (grievance reduction), vengefulness makes it less effective.
	# If delta is positive, vengefulness makes it sting more.
	var g := float(out["d_grievance"])
	if g < 0.0:
		var g_mul_down := 1.0 - k_griev_down * (veng - 0.5)  # veng>0.5 => smaller reduction
		g_mul_down = clampf(g_mul_down, 0.55, 1.35)
		out["d_grievance"] = g * g_mul_down
	elif g > 0.0:
		var g_mul_up := 1.0 + k_griev_up * ((veng - 0.5) + 0.5*(aggr - 0.5))
		g_mul_up = clampf(g_mul_up, 0.70, 1.45)
		out["d_grievance"] = g * g_mul_up

	# --- tension ---
	var t := float(out["d_tension"])
	if t < 0.0:
		var t_mul_down := 1.0 + k_tension_down * (diplo - 0.5)
		t_mul_down = clampf(t_mul_down, 0.75, 1.40)
		out["d_tension"] = t * t_mul_down
	elif t > 0.0:
		var t_mul_up := 1.0 + k_tension_up * ((aggr - 0.5) + 0.6*(veng - 0.5))
		t_mul_up = clampf(t_mul_up, 0.75, 1.45)
		out["d_tension"] = t * t_mul_up

	# --- weariness ---
	var w := float(out["d_weariness"])
	if w > 0.0:
		# expansionism reduces perceived weariness; risk_aversion increases it
		var w_mul := 1.0 \
			+ k_wear_gain * (risk - 0.5) \
			- 0.35 * (expa - 0.5)
		w_mul = clampf(w_mul, 0.65, 1.55)
		out["d_weariness"] = w * w_mul

	# clamp small floats to avoid noise
	out["d_grievance"] = _snap_small(out["d_grievance"])
	out["d_tension"] = _snap_small(out["d_tension"])
	out["d_weariness"] = _snap_small(out["d_weariness"])

	return out


static func _scale_signed_int(x: int, gain_mul: float, loss_mul: float) -> float:
	if x >= 0:
		return float(x) * gain_mul
	return float(x) * loss_mul

static func _snap_small(x: float) -> float:
	return 0.0 if abs(x) < 0.05 else x
```

---

## 3) Brancher dans ton ArcManager

Dans `on_quest_resolution_choice` :

```gdscript
var profile_a: FactionProfile = faction_profiles[giver_id]
var profile_b: FactionProfile = faction_profiles[ant_id]

ArcEffectTable.apply_arc_resolution_with_personality(
	action,
	choice,
	rel_ab,
	rel_ba,
	profile_a,
	profile_b,
	WorldGameState.day,
	_rng
)
```

---

### Résultat attendu (ce que tu veux)
- Une faction **pacifique/diplomate** transforme une trêve en vraie détente (tension ↓↓, trust ↑↑).
- Une faction **vindicative** “digère” mal : grievance baisse moins vite, tension remonte plus vite.
- Une faction **expansionniste** “supporte” mieux la guerre (weariness monte moins), donc peut pousser plus loin.
- Tu obtiens des arcs qui peuvent **se désamorcer**, **stagner**, **exploser**, ou **bifurquer** vers alliance/fusion, selon profils.

Si tu veux, dernière brique utile pour stabiliser : un “cap” qui empêche une seule résolution de faire sauter relation/trust de 40 points (clamp par évènement), mais je peux aussi te proposer ça directement sans attendre.

Moi:
Ok, on dit qu'une relation ne peut pas evoluer de plus de 10 a 30% de son score actuelle (dans une direction ou l'autre, c'est a dire en + ou en -), en fonction de l'historique des deux factions (je recupere toute les actions faites et j'ai un compteur de type d'action dans ArcNotebook, j'ai un dictionnaire arcType -> nb_arc
Et arc_type -> last_arc_date

ChatGPT:
OK — on va **caper le delta de relation** (et optionnellement le trust) à chaque résolution, avec une borne qui varie entre **10% et 30%** de la relation actuelle (en valeur absolue), **minimum 10 points**, selon l’historique stocké dans ton `ArcNotebook` (compteurs + last date par type).

## 1) Règle de cap

Pour un lien A→B (score `rel_ab.relation`), on calcule :

- `cap_pct ∈ [0.10 .. 0.30]` (dépend de l’historique)
- `cap_abs = max(10, round(abs(rel_ab.relation) * cap_pct))`
- puis on clamp : `d_relation = clamp(d_relation, -cap_abs, +cap_abs)`

Même logique pour B→A.

---

## 2) `ArcNotebook.gd` (minimal)

```gdscript
class_name ArcNotebook
extends RefCounted

var count_by_type: Dictionary[StringName, int] = {}
var last_day_by_type: Dictionary[StringName, int] = {}

func get_total_count() -> int:
	var s := 0
	for k in count_by_type.keys():
		s += int(count_by_type[k])
	return s

func get_count(arc_type: StringName) -> int:
	return int(count_by_type.get(arc_type, 0))

func get_days_since(arc_type: StringName, current_day: int) -> int:
	var last := int(last_day_by_type.get(arc_type, -999999))
	return current_day - last

func register(arc_type: StringName, current_day: int) -> void:
	count_by_type[arc_type] = get_count(arc_type) + 1
	last_day_by_type[arc_type] = current_day
```

---

## 3) Calcul du `cap_pct` basé historique (10% ↔ 30%)

- **Plus l’historique est “ancré”** (beaucoup d’arcs entre eux) ⇒ cap vers **10%**
- **Plus c’est rare / ancien** ⇒ cap vers **30%**
- **Répétition du même type** (spam) ⇒ cap réduit

```gdscript
static func compute_relation_cap_pct(
	notebook: ArcNotebook,
	arc_type: StringName,
	current_day: int,
	params: Dictionary = {}
) -> float:
	var pct_min := float(params.get("pct_min", 0.10))
	var pct_max := float(params.get("pct_max", 0.30))

	# ancrage global: plus il y a d'historique, moins ça bouge
	var total := notebook.get_total_count()
	var entrench := clampf(float(total) / float(params.get("entrench_k", 30.0)), 0.0, 1.0)

	# répétition du type: spam => moins d'impact marginal
	var type_count := notebook.get_count(arc_type)
	var repetition := clampf(float(type_count) / float(params.get("repetition_k", 10.0)), 0.0, 1.0)

	# récence du type: si ça date, on autorise plus de changement
	var days_since := notebook.get_days_since(arc_type, current_day)
	var recency := clampf(float(days_since) / float(params.get("recency_k", 14.0)), 0.0, 1.0)

	# volatilité (0..1) => cap_pct via lerp(min,max)
	# - (1-entrench) : relations "jeunes" bougent plus
	# - recency : ancien => bouge plus
	# - (1-repetition) : moins de spam => bouge plus
	var volatility :=
		0.55 * (1.0 - entrench) +
		0.30 * recency +
		0.15 * (1.0 - repetition)

	volatility = clampf(volatility, 0.0, 1.0)

	var cap_pct := lerp(pct_min, pct_max, volatility)

	# Optionnel: poids par type (ex: guerre = plus structurant)
	var type_weight := float(params.get("type_weight", 1.0)) # ou table externe
	cap_pct *= type_weight

	return clampf(cap_pct, pct_min, pct_max)
```

---

## 4) Clamp du delta + intégration dans `ArcEffectTable.apply...`

On ajoute une variante qui prend `notebook` et applique le cap sur `d_relation` (et optionnellement `d_trust`).

```gdscript
static func apply_arc_resolution_with_personality_and_caps(
	action: StringName,
	choice: StringName,
	rel_ab: FactionRelationScore,
	rel_ba: FactionRelationScore,
	profile_a: FactionProfile,
	profile_b: FactionProfile,
	notebook: ArcNotebook,          # <- historique du pair (A,B)
	current_day: int,
	rng: RandomNumberGenerator,
	cooldown_override_days: int = -1,
	params: Dictionary = {}
) -> void:
	var d := get_arc_deltas(action, choice)
	if d.is_empty():
		return

	# 1) scaling personnalité (comme avant)
	var ab_scaled := _scale_deltas_by_personality(d["ab"], profile_a, params)
	var ba_scaled := _scale_deltas_by_personality(d["ba"], profile_b, params)

	# 2) cap percent (10%..30%) basé historique
	var cap_pct := compute_relation_cap_pct(notebook, action, current_day, params)

	# 3) cap absolute pour chaque direction (min 10 points)
	var min_abs := int(params.get("min_abs_cap", 10))

	var cap_ab := max(min_abs, int(round(abs(rel_ab.relation) * cap_pct)))
	var cap_ba := max(min_abs, int(round(abs(rel_ba.relation) * cap_pct)))

	ab_scaled["d_relation"] = _clamp_delta_int(int(ab_scaled["d_relation"]), cap_ab)
	ba_scaled["d_relation"] = _clamp_delta_int(int(ba_scaled["d_relation"]), cap_ba)

	# Optionnel: cap trust aussi (souvent utile)
	if bool(params.get("cap_trust_too", true)):
		var cap_pct_trust := float(params.get("cap_pct_trust", cap_pct)) # par défaut même règle
		var cap_ab_t := max(min_abs, int(round(abs(rel_ab.trust) * cap_pct_trust)))
		var cap_ba_t := max(min_abs, int(round(abs(rel_ba.trust) * cap_pct_trust)))
		ab_scaled["d_trust"] = _clamp_delta_int(int(ab_scaled["d_trust"]), cap_ab_t)
		ba_scaled["d_trust"] = _clamp_delta_int(int(ba_scaled["d_trust"]), cap_ba_t)

	# 4) apply
	rel_ab.apply_delta(int(ab_scaled["d_relation"]), int(ab_scaled["d_trust"]),
		float(ab_scaled["d_grievance"]), float(ab_scaled["d_tension"]), float(ab_scaled["d_weariness"]))
	rel_ba.apply_delta(int(ba_scaled["d_relation"]), int(ba_scaled["d_trust"]),
		float(ba_scaled["d_grievance"]), float(ba_scaled["d_tension"]), float(ba_scaled["d_weariness"]))

	# 5) cooldown + notebook update
	var cd := cooldown_override_days if cooldown_override_days >= 0 else cooldown_days_for(action, rng)
	rel_ab.set_cooldown(current_day, cd)
	rel_ba.set_cooldown(current_day, cd)

	notebook.register(action, current_day)


static func _clamp_delta_int(delta: int, cap_abs: int) -> int:
	return clampi(delta, -cap_abs, cap_abs)
```

---

## 5) Où récupérer le `ArcNotebook` ?
Le plus simple : **un notebook par paire** (A,B) dans l’ArcManager, clé canonique :

- `key = "%s|%s" % [min(a,b), max(a,b)]`
- `pair_notebooks[key] = ArcNotebook`

Et tu passes ce notebook à `apply_arc_resolution_with_personality_and_caps(...)`.

---

Si tu me dis comment tu stockes actuellement `ArcNotebook` (par `arc_id` ? par paire ?), je te donne le code exact `_get_or_create_notebook(giver_id, ant_id)` + la clé canonique et où l’initialiser dans ton pipeline.

Moi:
Le ArcNotebook est stocké dans le arcManager comme ça : var arc_notebook :ArcNotebook.
Il est encore en construction, donc tu peux y ajouter ce dont tu as besoin.
J'adapterai ce qui a besoin de l'etre

ChatGPT:
Parfait : avec **un seul** `arc_notebook : ArcNotebook` dans l’`ArcManager`, le plus simple est d’en faire un **registre d’historique par paire** (A,B), puisque ton cap dépend de “l’historique des deux factions”.

Ci-dessous, je te donne :

1) une version d’`ArcNotebook` extensible (par paire, compteur par type + last day + mémoire récente),
2) une fonction `compute_relation_cap_pct(...)` qui sort **[0.10 .. 0.30]** selon cet historique,
3) l’intégration dans `apply_arc_resolution...` pour caper `d_relation` (et optionnellement `d_trust`).

---

## 1) ArcNotebook par paire

### `ArcPairHistory.gd` (ou en inner class)

```gdscript
class_name ArcPairHistory
extends RefCounted

var total_count: int = 0
var count_by_type: Dictionary[StringName, int] = {}
var last_day_by_type: Dictionary[StringName, int] = {}

var last_event_day: int = -999999

# Mémoire courte (pour détecter spam récent)
var recent_events: Array = [] # [{day:int, type:StringName}]
var max_recent: int = 64

func register(arc_type: StringName, day: int) -> void:
	total_count += 1
	count_by_type[arc_type] = int(count_by_type.get(arc_type, 0)) + 1
	last_day_by_type[arc_type] = day
	last_event_day = max(last_event_day, day)

	recent_events.append({"day": day, "type": arc_type})
	if recent_events.size() > max_recent:
		recent_events.pop_front()

func get_count(arc_type: StringName) -> int:
	return int(count_by_type.get(arc_type, 0))

func get_days_since(arc_type: StringName, current_day: int) -> int:
	var last := int(last_day_by_type.get(arc_type, -999999))
	return current_day - last

func get_days_since_any(current_day: int) -> int:
	return current_day - last_event_day

func count_in_last_days(current_day: int, days: int, arc_type: StringName = &"") -> int:
	var c := 0
	for e in recent_events:
		var d := int(e["day"])
		if current_day - d > days:
			continue
		if arc_type == &"" or StringName(e["type"]) == arc_type:
			c += 1
	return c
```

### `ArcNotebook.gd`

```gdscript
class_name ArcNotebook
extends RefCounted

var pairs: Dictionary[StringName, ArcPairHistory] = {}

static func _pair_key(a: StringName, b: StringName) -> StringName:
	var sa := String(a)
	var sb := String(b)
	return StringName(sa + "|" + sb) if sa <= sb else StringName(sb + "|" + sa)

func get_pair(a: StringName, b: StringName) -> ArcPairHistory:
	var k := _pair_key(a, b)
	if not pairs.has(k):
		pairs[k] = ArcPairHistory.new()
	return pairs[k]

func register(a: StringName, b: StringName, arc_type: StringName, day: int) -> void:
	get_pair(a, b).register(arc_type, day)
```

---

## 2) Cap % (10%..30%) basé sur l’historique de la paire

```gdscript
static func compute_relation_cap_pct(
	h: ArcPairHistory,
	arc_type: StringName,
	current_day: int,
	params: Dictionary = {}
) -> float:
	var pct_min := float(params.get("pct_min", 0.10))
	var pct_max := float(params.get("pct_max", 0.30))

	# Plus il y a d'historique, plus la relation est "ancrée" => cap vers 10%
	var entrench_k := float(params.get("entrench_k", 30.0)) # ~30 events => bien ancré
	var entrench := clampf(float(h.total_count) / entrench_k, 0.0, 1.0)

	# Spam récent du même type => cap réduit
	var window_days := int(params.get("window_days", 14))
	var spam_k := float(params.get("spam_k", 6.0)) # 6 events du même type sur 14j => spam fort
	var recent_same := float(h.count_in_last_days(current_day, window_days, arc_type))
	var spam := clampf(recent_same / spam_k, 0.0, 1.0)

	# Si ça fait longtemps qu’on n’a pas vu ce type => cap augmente
	var recency_k := float(params.get("recency_k", 14.0))
	var days_since_type := float(max(0, h.get_days_since(arc_type, current_day)))
	var type_oldness := clampf(days_since_type / recency_k, 0.0, 1.0)

	# Si la paire n’a eu aucun event depuis longtemps => cap augmente (relation plus "mobile")
	var pair_recency_k := float(params.get("pair_recency_k", 21.0))
	var days_since_any := float(max(0, h.get_days_since_any(current_day)))
	var pair_oldness := clampf(days_since_any / pair_recency_k, 0.0, 1.0)

	# Volatilité 0..1
	var volatility :=
		0.45 * (1.0 - entrench) +
		0.25 * type_oldness +
		0.15 * pair_oldness +
		0.15 * (1.0 - spam)

	volatility = clampf(volatility, 0.0, 1.0)

	var cap_pct := lerp(pct_min, pct_max, volatility)

	# Optionnel: certains types "comptent" plus / moins
	var type_weight := float(params.get("type_weight", 1.0))
	cap_pct *= type_weight

	return clampf(cap_pct, pct_min, pct_max)
```

---

## 3) Clamp du delta de relation (10 points min, sinon % du score actuel)

Dans ton `ArcEffectTable.apply_arc_resolution_with_personality_and_caps(...)`, remplace le calcul du cap par la version “pair history” :

```gdscript
# h = ArcPairHistory (paire A,B)
var cap_pct := compute_relation_cap_pct(h, action, current_day, params)

var min_abs := int(params.get("min_abs_cap", 10))

var cap_ab := max(min_abs, int(round(abs(rel_ab.relation) * cap_pct)))
var cap_ba := max(min_abs, int(round(abs(rel_ba.relation) * cap_pct)))

ab_scaled["d_relation"] = clampi(int(ab_scaled["d_relation"]), -cap_ab, cap_ab)
ba_scaled["d_relation"] = clampi(int(ba_scaled["d_relation"]), -cap_ba, cap_ba)
```

Et à la fin (après application), enregistre l’event :

```gdscript
h.register(action, current_day)
# ou arc_notebook.register(giver_id, ant_id, action, current_day)
```

---

## 4) Intégration ArcManager (résolution)

```gdscript
var h: ArcPairHistory = arc_notebook.get_pair(giver_id, ant_id)

ArcEffectTable.apply_arc_resolution_with_personality_and_caps(
	action, choice,
	rel_ab, rel_ba,
	profile_a, profile_b,
	h,
	WorldGameState.day,
	_rng
)
```

---

### Ce que ça t’apporte
- Au début (peu d’historique) : **cap proche de 30%** → les relations bougent vite (dynamique).
- Quand l’historique s’accumule : **cap se rapproche de 10%** → inertie, impossible de “retourner” une haine viscérale en 2 quêtes.
- Si tu spams le même type d’action : impact marginal baisse → anti-boucle “raid raid raid”.

Si tu veux, prochaine micro-brique utile : une table `type_weight` par `arc_action_type` (ex : `declare_war` plus structurant mais *moins* fréquent), et/ou un cap différent pour `trust` que pour `relation` (souvent meilleur gameplay).

Moi:
En fait, dans un ArcNotebook, j'ai des arcHistory par faction, l'arcHistory contient des metadata (les count des arcType par exemple) et aussi l'historique de toute les rivalité genere avec leur date de resolutions etc

ChatGPT:
OK, on peut garder ton modèle “**ArcNotebook → ArcHistory par faction**”, et en déduire un **cap A→B** en combinant :

- l’historique **global** de A et B (plus une faction a vécu d’arcs, plus ses positions sont “ancrées”),
- l’historique **spécifique A↔B** (plus ils se sont affrontés/négociés, plus ça bouge lentement),
- la **récence** (si ça date, ça bouge plus),
- le **spam de type** récent (si tu répètes le même arc_type, impact marginal ↓).

Pour éviter de rescanner “toutes les rivalités” à chaque résolution, je te conseille d’ajouter dans `ArcHistory` un petit **index par cible** (B) qui contient les mêmes metadata que tu as déjà globalement.

---

## 1) Structures de données (ArcNotebook → ArcHistory → ArcTargetMeta)

### ArcNotebook.gd

```gdscript
class_name ArcNotebook
extends RefCounted

var history_by_faction: Dictionary[StringName, ArcHistory] = {}

func get_history(faction_id: StringName) -> ArcHistory:
	if not history_by_faction.has(faction_id):
		history_by_faction[faction_id] = ArcHistory.new(faction_id)
	return history_by_faction[faction_id]
```

### ArcHistory.gd

```gdscript
class_name ArcHistory
extends RefCounted

var owner_id: StringName

# Global metadata (comme tu as déjà)
var total_count: int = 0
var count_by_type: Dictionary[StringName, int] = {}
var last_day_by_type: Dictionary[StringName, int] = {}

# Index par cible (B) -> meta “A envers B”
var meta_by_target: Dictionary[StringName, ArcTargetMeta] = {}

# Historique détaillé (tes rivalités / dates / résolutions / choix etc.)
var rivalry_records: Array = [] # à toi: records/objects existants

func _init(id: StringName = &"") -> void:
	owner_id = id

func get_target_meta(target_id: StringName) -> ArcTargetMeta:
	if not meta_by_target.has(target_id):
		meta_by_target[target_id] = ArcTargetMeta.new(target_id)
	return meta_by_target[target_id]

func register_event(target_id: StringName, arc_type: StringName, day: int) -> void:
	total_count += 1
	count_by_type[arc_type] = int(count_by_type.get(arc_type, 0)) + 1
	last_day_by_type[arc_type] = day

	get_target_meta(target_id).register(arc_type, day)
```

### ArcTargetMeta.gd

```gdscript
class_name ArcTargetMeta
extends RefCounted

var target_id: StringName
var total_count: int = 0
var count_by_type: Dictionary[StringName, int] = {}
var last_day_by_type: Dictionary[StringName, int] = {}
var last_event_day: int = -999999

# mémoire courte “anti-spam”
var recent_events: Array = [] # [{day:int, type:StringName}]
var max_recent: int = 64

func _init(id: StringName = &"") -> void:
	target_id = id

func register(arc_type: StringName, day: int) -> void:
	total_count += 1
	count_by_type[arc_type] = int(count_by_type.get(arc_type, 0)) + 1
	last_day_by_type[arc_type] = day
	last_event_day = max(last_event_day, day)

	recent_events.append({"day": day, "type": arc_type})
	if recent_events.size() > max_recent:
		recent_events.pop_front()

func get_count(arc_type: StringName) -> int:
	return int(count_by_type.get(arc_type, 0))

func get_days_since_type(arc_type: StringName, current_day: int) -> int:
	return current_day - int(last_day_by_type.get(arc_type, -999999))

func get_days_since_any(current_day: int) -> int:
	return current_day - last_event_day

func count_in_last_days(current_day: int, days: int, arc_type: StringName = &"") -> int:
	var c := 0
	for e in recent_events:
		var d := int(e["day"])
		if current_day - d > days:
			continue
		if arc_type == &"" or StringName(e["type"]) == arc_type:
			c += 1
	return c
```

> Ensuite, quand une rivalité se résout, tu fais `historyA.register_event(B, arc_type, day)` **et** `historyB.register_event(A, arc_type, day)` + tu ajoutes ton record détaillé dans `rivalry_records` si tu veux.

---

## 2) Cap % (10%..30%) basé sur “l’historique des deux factions”

On combine **A→B meta** + **B→A meta** + (global A + global B).

```gdscript
static func compute_relation_cap_pct_from_histories(
	hist_a: ArcHistory,
	hist_b: ArcHistory,
	a_id: StringName,
	b_id: StringName,
	arc_type: StringName,
	current_day: int,
	params: Dictionary = {}
) -> float:
	var pct_min := float(params.get("pct_min", 0.10))
	var pct_max := float(params.get("pct_max", 0.30))

	var meta_ab := hist_a.get_target_meta(b_id)
	var meta_ba := hist_b.get_target_meta(a_id)

	# --- Entrenchment pair (A<->B) ---
	var pair_k := float(params.get("pair_k", 18.0))
	var pair_total := float(meta_ab.total_count + meta_ba.total_count) * 0.5
	var entrench_pair := clampf(pair_total / pair_k, 0.0, 1.0)

	# --- Entrenchment global (A & B) ---
	var global_k := float(params.get("global_k", 40.0))
	var global_total := float(hist_a.total_count + hist_b.total_count) * 0.5
	var entrench_global := clampf(global_total / global_k, 0.0, 1.0)

	# --- Spam récent du même type sur la paire ---
	var window_days := int(params.get("window_days", 14))
	var spam_k := float(params.get("spam_k", 6.0))
	var recent_same := float(meta_ab.count_in_last_days(current_day, window_days, arc_type)
		+ meta_ba.count_in_last_days(current_day, window_days, arc_type)) * 0.5
	var spam := clampf(recent_same / spam_k, 0.0, 1.0)

	# --- Récence du type et de la paire ---
	var recency_k := float(params.get("recency_k", 14.0))
	var days_since_type := float(min(
		meta_ab.get_days_since_type(arc_type, current_day),
		meta_ba.get_days_since_type(arc_type, current_day)
	))
	var type_oldness := clampf(days_since_type / recency_k, 0.0, 1.0)

	var pair_recency_k := float(params.get("pair_recency_k", 21.0))
	var days_since_any := float(min(meta_ab.get_days_since_any(current_day), meta_ba.get_days_since_any(current_day)))
	var pair_oldness := clampf(days_since_any / pair_recency_k, 0.0, 1.0)

	# --- Volatilité (0..1) => cap_pct (10%..30%) ---
	# + vieux / rare => bouge plus
	# + ancré / spammé => bouge moins
	var volatility :=
		0.40 * (1.0 - entrench_pair) +
		0.15 * (1.0 - entrench_global) +
		0.20 * type_oldness +
		0.10 * pair_oldness +
		0.15 * (1.0 - spam)

	volatility = clampf(volatility, 0.0, 1.0)

	var cap_pct := lerp(pct_min, pct_max, volatility)

	# Optionnel: poids par type (ex: declare_war => plus structurant donc cap plus bas)
	var type_weight := float(params.get("type_weight", 1.0))
	cap_pct *= type_weight

	return clampf(cap_pct, pct_min, pct_max)
```

---

## 3) Application dans ta résolution (clamp du delta)

Après avoir calculé tes deltas (avec personnalité ou non), tu clamps juste `d_relation` :

```gdscript
var cap_pct := compute_relation_cap_pct_from_histories(
	arc_notebook.get_history(giver_id),
	arc_notebook.get_history(ant_id),
	giver_id, ant_id,
	action, WorldGameState.day,
	{"type_weight": 1.0}
)

var min_abs := 10
var cap_ab := max(min_abs, int(round(abs(rel_ab.relation) * cap_pct)))
var cap_ba := max(min_abs, int(round(abs(rel_ba.relation) * cap_pct)))

ab_scaled["d_relation"] = clampi(int(ab_scaled["d_relation"]), -cap_ab, cap_ab)
ba_scaled["d_relation"] = clampi(int(ba_scaled["d_relation"]), -cap_ba, cap_ba)
```

Et tu enregistres l’event :

```gdscript
arc_notebook.get_history(giver_id).register_event(ant_id, action, WorldGameState.day)
arc_notebook.get_history(ant_id).register_event(giver_id, action, WorldGameState.day)
```

---

### Pourquoi ça colle à ton besoin
- Tu gardes ton `ArcNotebook` “par faction” + historique complet.
- Tu ajoutes juste un **résumé par cible** (léger), ce qui te donne un cap basé sur “l’historique des deux factions” sans coûts.
- Le cap devient naturellement :
  - **haut (≈30%)** quand la relation est jeune ou que la paire n’a pas interagi depuis longtemps,
  - **bas (≈10%)** quand A et B ont un long passif, ou quand tu spams le même arc_type.

Si tu veux, je peux te proposer une table `type_weight` “raisonnable” (ex : `declare_war: 0.6`, `truce_talks: 1.0`, `raid: 0.85`, etc.) pour que certains événements soient **plus structurants** (mais bougent moins d’un coup) tout en restant impactants via tension/grievance/weariness.

Moi:
Ok pour la table et l'application par evenement

ChatGPT:
Parfait. On va faire une **table de “policy” par `arc_action_type`** qui définit :

- `cap_weight` : modifie le **cap%** (10%..30%) pour **RELATION**
- `trust_cap_weight` : idem pour **TRUST**
- `cooldown_mult` : multiplie le cooldown de base
- (optionnel) `delta_mult_*` : si tu veux “durcir” tension/grievance sans toucher relation

Ensuite, à **chaque événement résolu**, on :
1) calcule `cap_pct` (10%..30%) via l’historique A & B,
2) applique `cap_weight`/`trust_cap_weight`,
3) clamp `d_relation` (et `d_trust`),
4) applique les deltas,
5) pose cooldown,
6) enregistre dans `ArcNotebook` (counts + last_day + record détaillé).

---

## 1) Table `ARC_TYPE_POLICY`

À mettre dans `ArcEffectTable.gd` (ou un fichier dédié).

```gdscript
const ARC_TYPE_POLICY: Dictionary = {
	ARC_IGNORE: {
		"cap_weight": 1.00,
		"trust_cap_weight": 1.00,
		"cooldown_mult": 1.00,
	},
	ARC_ULTIMATUM: {
		"cap_weight": 0.90,
		"trust_cap_weight": 0.85,
		"cooldown_mult": 1.05,
	},
	ARC_REPARATIONS: {
		# Peut réellement changer une relation… mais pas instantanément
		"cap_weight": 1.15,
		"trust_cap_weight": 1.20,
		"cooldown_mult": 1.10,
	},
	ARC_TRUCE_TALKS: {
		# Trêve = gros levier sur tension + trust
		"cap_weight": 1.10,
		"trust_cap_weight": 1.25,
		"cooldown_mult": 1.20,
	},
	ARC_RAID: {
		# Hostile : impact relation limité, mais tension/grievance montent via deltas
		"cap_weight": 0.85,
		"trust_cap_weight": 0.80,
		"cooldown_mult": 1.10,
	},
	ARC_SABOTAGE: {
		"cap_weight": 0.80,
		"trust_cap_weight": 0.75,
		"cooldown_mult": 1.15,
	},
	ARC_DECLARE_WAR: {
		# Déclaration de guerre = surtout un changement d'état + tension/weariness,
		# la relation ne doit pas faire un -60 d’un coup.
		"cap_weight": 0.60,
		"trust_cap_weight": 0.60,
		"cooldown_mult": 1.35,
	},
	ARC_ALLIANCE_OFFER: {
		# Alliance: confiance monte, relation suit mais reste capée
		"cap_weight": 0.95,
		"trust_cap_weight": 1.15,
		"cooldown_mult": 1.25,
	},
}

static func _policy(action: StringName) -> Dictionary:
	return ARC_TYPE_POLICY.get(action, {"cap_weight": 1.0, "trust_cap_weight": 1.0, "cooldown_mult": 1.0})
```

---

## 2) Application “par événement” dans `apply_arc_resolution...`

Ici je te donne une version complète qui :
- applique scaling personnalité,
- applique cap relation/trust,
- applique cooldown * `cooldown_mult`,
- enregistre l’événement dans `ArcNotebook` (A et B).

```gdscript
static func apply_arc_resolution_event(
	action: StringName,
	choice: StringName,
	giver_id: StringName,
	ant_id: StringName,
	rel_ab: FactionRelationScore,
	rel_ba: FactionRelationScore,
	profile_a: FactionProfile,
	profile_b: FactionProfile,
	arc_notebook: ArcNotebook,
	current_day: int,
	rng: RandomNumberGenerator,
	params: Dictionary = {}
) -> void:
	var d := get_arc_deltas(action, choice)
	if d.is_empty():
		return

	# 1) scaling personnalité (déjà écrit chez toi)
	var ab_scaled := _scale_deltas_by_personality(d["ab"], profile_a, params)
	var ba_scaled := _scale_deltas_by_personality(d["ba"], profile_b, params)

	# 2) cap% issu de l’historique (10%..30%) + policy de type
	var pol := _policy(action)

	var hist_a := arc_notebook.get_history(giver_id)
	var hist_b := arc_notebook.get_history(ant_id)

	var base_cap_pct := compute_relation_cap_pct_from_histories(
		hist_a, hist_b, giver_id, ant_id, action, current_day, params
	)

	# applique les weights du type (puis re-clamp dans [0.10..0.30] à la fin)
	var pct_min := float(params.get("pct_min", 0.10))
	var pct_max := float(params.get("pct_max", 0.30))

	var cap_pct_rel := clampf(base_cap_pct * float(pol["cap_weight"]), pct_min, pct_max)
	var cap_pct_trust := clampf(base_cap_pct * float(pol["trust_cap_weight"]), pct_min, pct_max)

	# 3) cap absolu (min 10 points, sinon % du score actuel)
	var min_abs := int(params.get("min_abs_cap", 10))

	var cap_ab_rel := max(min_abs, int(round(abs(rel_ab.relation) * cap_pct_rel)))
	var cap_ba_rel := max(min_abs, int(round(abs(rel_ba.relation) * cap_pct_rel)))

	ab_scaled["d_relation"] = clampi(int(ab_scaled["d_relation"]), -cap_ab_rel, cap_ab_rel)
	ba_scaled["d_relation"] = clampi(int(ba_scaled["d_relation"]), -cap_ba_rel, cap_ba_rel)

	# Trust cap (souvent utile)
	if bool(params.get("cap_trust_too", true)):
		var cap_ab_tr := max(min_abs, int(round(abs(rel_ab.trust) * cap_pct_trust)))
		var cap_ba_tr := max(min_abs, int(round(abs(rel_ba.trust) * cap_pct_trust)))
		ab_scaled["d_trust"] = clampi(int(ab_scaled["d_trust"]), -cap_ab_tr, cap_ab_tr)
		ba_scaled["d_trust"] = clampi(int(ba_scaled["d_trust"]), -cap_ba_tr, cap_ba_tr)

	# 4) apply deltas
	rel_ab.apply_delta(int(ab_scaled["d_relation"]), int(ab_scaled["d_trust"]),
		float(ab_scaled["d_grievance"]), float(ab_scaled["d_tension"]), float(ab_scaled["d_weariness"]))
	rel_ba.apply_delta(int(ba_scaled["d_relation"]), int(ba_scaled["d_trust"]),
		float(ba_scaled["d_grievance"]), float(ba_scaled["d_tension"]), float(ba_scaled["d_weariness"]))

	# 5) cooldown (base * multiplier)
	var cd_base := cooldown_days_for(action, rng)
	var cd := int(round(float(cd_base) * float(pol["cooldown_mult"])))
	cd = max(1, cd)

	rel_ab.set_cooldown(current_day, cd)
	rel_ba.set_cooldown(current_day, cd)

	# 6) register in notebook (metadata + (optionnel) record détaillé)
	hist_a.register_event(ant_id, action, current_day)
	hist_b.register_event(giver_id, action, current_day)

	# Si tu veux aussi enregistrer la résolution dans l’historique détaillé :
	if hist_a.has_method("add_rivalry_record"):
		hist_a.add_rivalry_record({"other": ant_id, "type": action, "choice": choice, "day": current_day})
	if hist_b.has_method("add_rivalry_record"):
		hist_b.add_rivalry_record({"other": giver_id, "type": action, "choice": choice, "day": current_day})
```

---

## 3) Où ça se branche
Dans ton `ArcManager.on_quest_resolution_choice()` tu remplaces l’appel précédent par :

```gdscript
ArcEffectTable.apply_arc_resolution_event(
	action, choice,
	giver_id, ant_id,
	rel_ab, rel_ba,
	profile_a, profile_b,
	arc_notebook,
	WorldGameState.day,
	_rng
)
```

---

### Petit conseil de tuning
- Si tu trouves que “on ne peut jamais se réconcilier”, augmente `cap_weight` sur `TRUCE_TALKS` / `REPARATIONS`.
- Si tu trouves que “ça tourne trop vite en guerre”, baisse `cap_weight` de `ULTIMATUM/RAID/SABOTAGE` ou augmente `cooldown_mult`.

Si tu veux, prochaine brique : appliquer aussi un **cap sur `tension`/`grievance` par événement** (souvent utile pour éviter des +40 tension sur un seul événement), mais sans les lier au % de relation.

Moi:
Ok, maintenant, je voudrais des tests pour ce qu'on a fait dans les Faction (personnalité et axe, je me souvient plus du nom de la classe)
On genere 100 profiles, on verifit les regles.
On garde aussi 10 profils bien differents pour les test ensuites

ChatGPT:
Voilà un **test harness Godot 4** (GDScript) pour `FactionProfile` (axes + personnalité) qui :

1) génère **100 profils** (pour chaque mode : centered/normal/dramatic),
2) **vérifie les règles** (axes + personnalité),
3) sélectionne et **sauvegarde 10 profils “bien différents”** dans `user://golden_faction_profiles.json` (réutilisables ensuite).

> Ta classe s’appelle **`FactionProfile`** (celle avec `generate_full_profile`, `axis_affinity`, `personality`).

---

## `TestFactionProfileGeneration.gd`

```gdscript
# Godot 4.x
# Attache ce script à un Node dans une scène "tests" et lance la scène.
extends Node
class_name TestFactionProfileGeneration

const N_PER_MODE := 100
const GOLDEN_COUNT := 10
const GOLDEN_PATH := "user://golden_faction_profiles.json"

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 1337 # reproductible

	_run_mode(FactionProfile.GEN_CENTERED)
	_run_mode(FactionProfile.GEN_NORMAL)
	_run_mode(FactionProfile.GEN_DRAMATIC)

	print("\n✅ FactionProfile generation tests: OK\n")
	get_tree().quit()


func _run_mode(mode: StringName) -> void:
	print("\n--- Testing mode: ", String(mode), " ---")

	var profiles: Array[FactionProfile] = []
	for i in range(N_PER_MODE):
		var p := FactionProfile.generate_full_profile(rng, mode)
		_validate_profile(p, mode, i)
		profiles.append(p)

	# Golden profiles (diversité) — on les garde une fois (normal) ou par mode (au choix).
	# Ici: on sauvegarde un set global à partir du mode NORMAL (souvent le plus stable pour fixtures).
	if mode == FactionProfile.GEN_NORMAL:
		var golden := _pick_diverse_profiles(profiles, GOLDEN_COUNT)
		_save_golden(golden, mode)


func _validate_profile(p: FactionProfile, mode: StringName, idx: int) -> void:
	_assert(p != null, "Profile is null (idx=%d, mode=%s)" % [idx, mode])

	_validate_axes(p.axis_affinity, mode, idx)
	_validate_personality(p.personality, mode, idx)


func _validate_axes(axis: Dictionary, mode: StringName, idx: int) -> void:
	# 5 axes présents, bornes, règles (pos>50, neg<-20), somme, distribution intéressante
	for a in FactionProfile.ALL_AXES:
		_assert(axis.has(a), "Missing axis '%s' (idx=%d, mode=%s)" % [a, idx, mode])
		var v := int(axis[a])
		_assert(v >= -100 and v <= 100, "Axis out of range %s=%d (idx=%d, mode=%s)" % [a, v, idx, mode])

	var has_pos := false
	var has_neg := false
	var sum := 0
	var interesting := 0

	var interesting_abs := 12
	var min_interesting := 3
	var sum_min := 20
	var sum_max := 90

	match mode:
		FactionProfile.GEN_CENTERED:
			interesting_abs = 10
			min_interesting = 4
			sum_min = 20
			sum_max = 75
		FactionProfile.GEN_DRAMATIC:
			interesting_abs = 15
			min_interesting = 3
			sum_min = 20
			sum_max = 90
		_:
			# normal
			interesting_abs = 12
			min_interesting = 3
			sum_min = 20
			sum_max = 90

	for a in FactionProfile.ALL_AXES:
		var v := int(axis[a])
		sum += v
		if v > 50:
			has_pos = true
		if v < -20:
			has_neg = true
		if abs(v) >= interesting_abs:
			interesting += 1

	_assert(has_pos, "No axis > 50 (idx=%d, mode=%s) axis=%s" % [idx, mode, str(axis)])
	_assert(has_neg, "No axis < -20 (idx=%d, mode=%s) axis=%s" % [idx, mode, str(axis)])
	_assert(sum >= sum_min and sum <= sum_max,
		"Axis sum out of range sum=%d expected=[%d..%d] (idx=%d, mode=%s) axis=%s"
		% [sum, sum_min, sum_max, idx, mode, str(axis)])
	_assert(interesting >= min_interesting,
		"Axis distribution too flat interesting=%d (<%d), abs>=%d (idx=%d, mode=%s) axis=%s"
		% [interesting, min_interesting, interesting_abs, idx, mode, str(axis)])


func _validate_personality(per: Dictionary, mode: StringName, idx: int) -> void:
	# clés, bornes 0..1, + “interestingness” (au moins un high et un low)
	var require_high := 0.75
	var require_low := 0.35
	match mode:
		FactionProfile.GEN_CENTERED:
			require_high = 0.70
			require_low = 0.40
		FactionProfile.GEN_DRAMATIC:
			require_high = 0.80
			require_low = 0.30
		_:
			require_high = 0.75
			require_low = 0.35

	var hi := 0
	var lo := 0

	for k in FactionProfile.ALL_PERSONALITY_KEYS:
		_assert(per.has(k), "Missing personality key '%s' (idx=%d, mode=%s)" % [k, idx, mode])
		var v := float(per[k])
		_assert(v >= 0.0 and v <= 1.0, "Personality out of range %s=%f (idx=%d, mode=%s)" % [k, v, idx, mode])
		if v >= require_high:
			hi += 1
		if v <= require_low:
			lo += 1

	_assert(hi >= 1, "Personality not distinctive: no trait >= %.2f (idx=%d, mode=%s) per=%s" % [require_high, idx, mode, str(per)])
	_assert(lo >= 1, "Personality not distinctive: no trait <= %.2f (idx=%d, mode=%s) per=%s" % [require_low, idx, mode, str(per)])


# -----------------------
# Golden profiles (diversité)
# -----------------------

func _pick_diverse_profiles(profiles: Array, k: int) -> Array:
	if profiles.is_empty():
		return []

	# Greedy farthest-point sampling
	var chosen: Array = []
	chosen.append(profiles[rng.randi_range(0, profiles.size() - 1)])

	while chosen.size() < k and chosen.size() < profiles.size():
		var best_p: FactionProfile = null
		var best_score := -INF

		for p in profiles:
			if chosen.has(p):
				continue
			var min_d := INF
			for c in chosen:
				min_d = min(min_d, _profile_distance(p, c))
			if min_d > best_score:
				best_score = min_d
				best_p = p

		if best_p == null:
			break
		chosen.append(best_p)

	return chosen


func _profile_distance(a: FactionProfile, b: FactionProfile) -> float:
	# Axes: [-1..1], Personality: centered around 0.5 then scaled
	var s := 0.0

	for ax in FactionProfile.ALL_AXES:
		var da := float(a.axis_affinity[ax]) / 100.0
		var db := float(b.axis_affinity[ax]) / 100.0
		var d := da - db
		s += 1.0 * d * d

	for k in FactionProfile.ALL_PERSONALITY_KEYS:
		var pa := (float(a.personality[k]) - 0.5) * 2.0 # [-1..1]
		var pb := (float(b.personality[k]) - 0.5) * 2.0
		var d2 := pa - pb
		s += 0.6 * d2 * d2

	return sqrt(s)


func _save_golden(golden: Array, mode: StringName) -> void:
	var arr := []
	for p in golden:
		arr.append(_to_json_dict(p))

	var payload := {
		"seed": 1337,
		"mode": String(mode),
		"generated_at_day": 0,
		"profiles": arr
	}

	var json := JSON.stringify(payload, "\t")
	var f := FileAccess.open(GOLDEN_PATH, FileAccess.WRITE)
	_assert(f != null, "Cannot open %s for writing" % GOLDEN_PATH)
	f.store_string(json)
	f.close()

	print("\n⭐ Saved ", golden.size(), " golden profiles to: ", GOLDEN_PATH)
	print("   (Tu peux les recharger ensuite pour tes tests de quêtes/arcs.)")


func _to_json_dict(p: FactionProfile) -> Dictionary:
	var axis := {}
	for ax in FactionProfile.ALL_AXES:
		axis[String(ax)] = int(p.axis_affinity[ax])

	var per := {}
	for k in FactionProfile.ALL_PERSONALITY_KEYS:
		per[String(k)] = float(p.personality[k])

	return {"axis_affinity": axis, "personality": per}


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

## Comment tu l’utilises
1) Crée une scène `Tests.tscn` avec un `Node`.
2) Attache `TestFactionProfileGeneration.gd` au node.
3) Lance la scène :  
   - si un test échoue → `assert(false)` + erreur explicite  
   - sinon → écrit `user://golden_faction_profiles.json`

---

## Les 10 profils “bien différents”
Ils sont choisis par **farthest-point sampling** (greedy), donc vraiment écartés (axes + personnalité).  
Tu peux ensuite les recharger pour des tests déterministes de ton ArcManager/QuestGenerator.

Si tu veux, je te donne aussi un petit helper `load_golden_profiles()` qui relit ce JSON et reconstruit des `FactionProfile` (pratique pour tes futurs tests).

Moi:
L'idée, maintenant on va generer les relations de depart entre les factions dans un deuxieme tests

ChatGPT:
OK — voici un **2ᵉ test harness** qui :

- charge tes **10 “golden profiles”** (ceux générés au test précédent),
- crée un mini-monde de **10 factions**,
- génère les **relations de départ** via `FactionRelationsUtil.initialize_relations_world()`,
- vérifie des **invariants** (structure, bornes, présence d’alliés/ennemis, moyenne centrée, réciprocité “70% mais pas identique”).

## `TestFactionWorldRelations.gd`

```gdscript
# Godot 4.x
# Scène de test: un Node avec ce script attaché.
extends Node
class_name TestFactionWorldRelations

const GOLDEN_PATH := "user://golden_faction_profiles.json"

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 424242 # reproductible

	# 1) Charger 10 profils différents (golden) ou fallback
	var profiles_list := _load_golden_profiles()
	_assert(profiles_list.size() >= 2, "Need at least 2 profiles to test relations")

	# 2) Construire un set de factions (ids + profile)
	var faction_profiles: Dictionary[StringName, FactionProfile] = {}
	for i in range(min(10, profiles_list.size())):
		var id := StringName("faction_%02d" % i)
		faction_profiles[id] = profiles_list[i]

	# 3) Générer le monde des relations
	var world_rel := FactionRelationsUtil.initialize_relations_world(
		faction_profiles,
		rng,
		{
			"apply_reciprocity": true,
			"reciprocity_strength": 0.70,
			"keep_asymmetry": 0.30,
			"reciprocity_noise": 2,
			"max_change_per_pair": 18,
			"final_global_sanity": true,
			"max_extremes_per_faction": 2
		},
		{
			# per-faction params (init directionnel)
			"desired_mean": 0.0,
			"desired_std": 22.0,
			"enemy_min": 1, "enemy_max": 2,
			"ally_min": 1, "ally_max": 2,
			"noise": 3,
			"tension_cap": 40.0,
			"final_recenter": true
		},
		{
			# baseline relation tuning forwarded to compute_baseline_relation()
			"w_axis_similarity": 80.0,
			"w_cross_conflict": 55.0,
			"tension_cap": 40.0
		}
	)

	# 4) Vérifs
	_validate_world_relations(faction_profiles, world_rel)

	print("\n✅ World relations initialization tests: OK\n")
	get_tree().quit()


# -------------------------
# Validation
# -------------------------

func _validate_world_relations(faction_profiles: Dictionary, world_rel: Dictionary) -> void:
	var ids: Array[StringName] = []
	for fid in faction_profiles.keys():
		ids.append(StringName(fid))

	# Structure: world_rel[A][B] existe pour tous A!=B
	for a in ids:
		_assert(world_rel.has(a), "Missing relations map for %s" % a)
		var map_a: Dictionary = world_rel[a]
		for b in ids:
			if b == a:
				_assert(not map_a.has(b), "Self relation should not exist: %s->%s" % [a, b])
				continue
			_assert(map_a.has(b), "Missing relation score: %s->%s" % [a, b])
			_validate_score_bounds(a, b, map_a[b])

	# Qualité globale: moyenne centrée + variance raisonnable + allies/enemies
	_validate_centering_and_spread(ids, world_rel)
	_validate_allies_enemies(ids, world_rel)
	_validate_reciprocity(ids, world_rel)


func _validate_score_bounds(a: StringName, b: StringName, rs) -> void:
	# rs est un FactionRelationScore
	_assert(rs != null, "Null score for %s->%s" % [a, b])

	_assert(rs.relation >= -100 and rs.relation <= 100, "relation out of range %s->%s = %d" % [a, b, rs.relation])
	_assert(rs.trust >= -100 and rs.trust <= 100, "trust out of range %s->%s = %d" % [a, b, rs.trust])
	_assert(rs.tension >= 0.0 and rs.tension <= 100.0, "tension out of range %s->%s = %f" % [a, b, rs.tension])
	# friction optionnel mais fortement recommandé
	if "friction" in rs:
		_assert(rs.friction >= 0.0 and rs.friction <= 100.0, "friction out of range %s->%s = %f" % [a, b, rs.friction])
	_assert(rs.grievance >= 0.0 and rs.grievance <= 100.0, "grievance out of range %s->%s = %f" % [a, b, rs.grievance])
	_assert(rs.weariness >= 0.0 and rs.weariness <= 100.0, "weariness out of range %s->%s = %f" % [a, b, rs.weariness])


func _validate_centering_and_spread(ids: Array[StringName], world_rel: Dictionary) -> void:
	# global mean / std
	var all_vals: Array[float] = []
	for a in ids:
		var map_a: Dictionary = world_rel[a]
		for b in map_a.keys():
			all_vals.append(float(map_a[b].relation))

	var mean := _mean(all_vals)
	var std := _std(all_vals, mean)

	_assert(abs(mean) <= 6.0, "Global mean too far from 0: mean=%f" % mean)
	_assert(std >= 12.0 and std <= 35.0, "Global std unexpected: std=%f (expect ~[12..35])" % std)

	# per-faction mean not too extreme (cohérence globale)
	for a in ids:
		var vals: Array[float] = []
		var map_a: Dictionary = world_rel[a]
		for b in map_a.keys():
			vals.append(float(map_a[b].relation))
		var m := _mean(vals)
		_assert(abs(m) <= 20.0, "Faction %s mean too extreme: %f" % [a, m])


func _validate_allies_enemies(ids: Array[StringName], world_rel: Dictionary) -> void:
	# On veut "quelques ennemis naturels, quelques alliés naturels"
	# Avec ally/enemy min/max, la plupart des factions devraient en avoir.
	var need_ratio := 0.70 # au moins 70% des factions

	var with_ally := 0
	var with_enemy := 0

	for a in ids:
		var map_a: Dictionary = world_rel[a]
		var has_ally := false
		var has_enemy := false
		for b in map_a.keys():
			var r := int(map_a[b].relation)
			if r >= 30:
				has_ally = true
			if r <= -30:
				has_enemy = true
		if has_ally: with_ally += 1
		if has_enemy: with_enemy += 1

	_assert(float(with_ally) / float(ids.size()) >= need_ratio,
		"Not enough factions with an ally (>=30): %d/%d" % [with_ally, ids.size()])
	_assert(float(with_enemy) / float(ids.size()) >= need_ratio,
		"Not enough factions with an enemy (<=-30): %d/%d" % [with_enemy, ids.size()])


func _validate_reciprocity(ids: Array[StringName], world_rel: Dictionary) -> void:
	# Réciprocité légère: AB et BA convergent, mais restent différents.
	var diffs: Array[float] = []
	var ab_vals: Array[float] = []
	var ba_vals: Array[float] = []

	for i in range(ids.size()):
		for j in range(i + 1, ids.size()):
			var a := ids[i]
			var b := ids[j]
			var ab := float(world_rel[a][b].relation)
			var ba := float(world_rel[b][a].relation)
			ab_vals.append(ab)
			ba_vals.append(ba)
			diffs.append(abs(ab - ba))

	var mean_diff := _mean(diffs)
	# Trop bas => presque symétrique (pas voulu), trop haut => pas de convergence
	_assert(mean_diff >= 4.0 and mean_diff <= 35.0, "Reciprocity diff mean unexpected: %f" % mean_diff)

	# Corrélation positive: si AB déteste, BA tend aussi à détester
	var corr := _pearson(ab_vals, ba_vals)
	_assert(corr >= 0.55, "Reciprocity correlation too low: %f" % corr)


# -------------------------
# Golden load / fallback
# -------------------------

func _load_golden_profiles() -> Array[FactionProfile]:
	if not FileAccess.file_exists(GOLDEN_PATH):
		push_warning("Golden profiles not found at %s, generating 10 fallback profiles." % GOLDEN_PATH)
		return _generate_fallback_profiles(10)

	var f := FileAccess.open(GOLDEN_PATH, FileAccess.READ)
	_assert(f != null, "Cannot open %s" % GOLDEN_PATH)
	var txt := f.get_as_text()
	f.close()

	var json := JSON.new()
	var err := json.parse(txt)
	_assert(err == OK, "JSON parse failed in %s" % GOLDEN_PATH)
	var root: Dictionary = json.data

	var arr: Array = root.get("profiles", [])
	_assert(arr.size() > 0, "Golden file has no profiles")

	var out: Array[FactionProfile] = []
	for item in arr:
		out.append(_profile_from_json_dict(item))
	return out


func _profile_from_json_dict(d: Dictionary) -> FactionProfile:
	var p := FactionProfile.new()

	var axis_in: Dictionary = d.get("axis_affinity", {})
	var per_in: Dictionary = d.get("personality", {})

	p.axis_affinity = {}
	for ax in FactionProfile.ALL_AXES:
		p.axis_affinity[ax] = int(axis_in.get(String(ax), 0))

	p.personality = {}
	for k in FactionProfile.ALL_PERSONALITY_KEYS:
		p.personality[k] = float(per_in.get(String(k), 0.5))

	return p


func _generate_fallback_profiles(n: int) -> Array[FactionProfile]:
	var out: Array[FactionProfile] = []
	for _i in range(n):
		out.append(FactionProfile.generate_full_profile(rng, FactionProfile.GEN_NORMAL))
	return out


# -------------------------
# Math helpers
# -------------------------

func _mean(arr: Array[float]) -> float:
	if arr.is_empty():
		return 0.0
	var s := 0.0
	for v in arr:
		s += v
	return s / float(arr.size())

func _std(arr: Array[float], mean: float) -> float:
	if arr.size() <= 1:
		return 0.0
	var s := 0.0
	for v in arr:
		var d := v - mean
		s += d * d
	return sqrt(s / float(arr.size()))

func _pearson(x: Array[float], y: Array[float]) -> float:
	if x.size() != y.size() or x.is_empty():
		return 0.0
	var mx := _mean(x)
	var my := _mean(y)
	var num := 0.0
	var dx := 0.0
	var dy := 0.0
	for i in range(x.size()):
		var a := x[i] - mx
		var b := y[i] - my
		num += a * b
		dx += a * a
		dy += b * b
	if dx <= 0.000001 or dy <= 0.000001:
		return 0.0
	return num / sqrt(dx * dy)


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

### Ce que ce test garantit
- tu as bien **un dictionnaire complet A→(tous les autres)**,
- les valeurs restent **dans les bornes**,
- tu as bien “**quelques ennemis/alliés**” (cohérence globale),
- la **moyenne** des relations est **centrée**,
- la **réciprocité légère** fonctionne : **corrélation élevée**, mais **différences non nulles**.

Si tu veux, prochaine étape : un 3ᵉ test qui simule **30 jours** en appelant `compute_arc_event_chance` et `select_arc_action_type`, puis vérifie qu’on ne tombe pas dans une boucle d’escalade systématique (distribution des actions + tendance tension/weariness).

Moi:
Exactement ce que je voulais

ChatGPT:
L'utilisateur veut des tests Godot pour générer 100 FactionProfile (axes+personnalité) en vérifiant les règles, conserver 10 profils “golden”, puis un second test pour initialiser les relations de départ entre factions à partir de ces profils avec invariants (moyenne centrée, alliés/ennemis, réciprocité légère).

ChatGPT:
Super — on a donc :

- **Test 1** : génération `FactionProfile` (100 profils / mode) + vérifs + sauvegarde de **10 golden**.
- **Test 2** : chargement des golden + `initialize_relations_world()` + invariants (bornes, moyenne, spread, alliés/ennemis, réciprocité légère).

Quand tu voudras, on peut enchaîner avec le **Test 3** (simulation multi-jours + stats sur incidents / escalade) pour valider que la boucle vengeance n’est plus automatique.

Moi:
On enchaine avec le test 3, le nombre de jour est parametrable (on le recoit en entrée de la fonction de tests)

ChatGPT:
OK — voici un **Test 3** Godot (GDScript) qui simule un monde “arc-driven” sur **N jours paramétrables**.

- Il charge les **10 golden profiles** (ou fallback),
- initialise `initialize_relations_world()`,
- puis chaque jour :
  - applique une **décroissance passive** (tension/grievance/weariness) dépendante de la personnalité,
  - calcule `compute_arc_event_chance(A→B)` sur toutes les paires directionnelles,
  - déclenche au plus `max_events_per_day` événements (les plus probables),
  - choisit `arc_action_type` + un **choix simulé** (LOYAL/NEUTRAL/TRAITOR),
  - applique `ArcEffectTable.apply_arc_resolution_event(...)` (donc cooldown + notebook + caps si tu l’as branché).

Enfin il valide des **invariants anti-escalade** et imprime un résumé.

---

## `TestArcSimulation.gd`

```gdscript
# Godot 4.x
extends Node
class_name TestArcSimulation

const GOLDEN_PATH := "user://golden_faction_profiles.json"

@export var days_to_simulate: int = 30
@export var max_events_per_day: int = 6

var rng := RandomNumberGenerator.new()

# --- Action buckets (pour stats + invariants) ---
const PEACE_ACTIONS := [
	ArcDecisionUtil.ARC_TRUCE_TALKS,
	ArcDecisionUtil.ARC_REPARATIONS,
	ArcDecisionUtil.ARC_ALLIANCE_OFFER,
]

const HOSTILE_ACTIONS := [
	ArcDecisionUtil.ARC_RAID,
	ArcDecisionUtil.ARC_SABOTAGE,
	ArcDecisionUtil.ARC_DECLARE_WAR,
	ArcDecisionUtil.ARC_ULTIMATUM,
]

func _ready() -> void:
	rng.seed = 777777

	run(days_to_simulate)
	print("\n✅ Arc simulation test: OK\n")
	get_tree().quit()


# Appelable depuis ailleurs (le nombre de jours est le param)
func run(days: int) -> void:
	_assert(days > 0, "days must be > 0")

	# 1) Charger profils golden (10) + construire factions
	var profiles_list := _load_golden_profiles()
	_assert(profiles_list.size() >= 6, "Need at least 6 profiles for a meaningful arc sim")

	var faction_profiles: Dictionary[StringName, FactionProfile] = {}
	for i in range(min(10, profiles_list.size())):
		faction_profiles[StringName("faction_%02d" % i)] = profiles_list[i]

	var ids: Array[StringName] = []
	for fid in faction_profiles.keys():
		ids.append(StringName(fid))

	# 2) Init relations world
	var world_rel := FactionRelationsUtil.initialize_relations_world(
		faction_profiles,
		rng,
		{
			"apply_reciprocity": true,
			"reciprocity_strength": 0.70,
			"keep_asymmetry": 0.30,
			"reciprocity_noise": 2,
			"max_change_per_pair": 18,
			"final_global_sanity": true,
			"max_extremes_per_faction": 2
		},
		{
			"desired_mean": 0.0,
			"desired_std": 22.0,
			"enemy_min": 1, "enemy_max": 2,
			"ally_min": 1, "ally_max": 2,
			"noise": 3,
			"tension_cap": 40.0,
			"final_recenter": true
		},
		{
			"w_axis_similarity": 80.0,
			"w_cross_conflict": 55.0,
			"tension_cap": 40.0
		}
	)

	# 3) Notebook (historique arcs) — ton ArcNotebook par faction
	var arc_notebook := ArcNotebook.new()

	# 4) Stats time-series + compteurs
	var stats := {
		"events_total": 0,
		"by_action": {},
		"by_choice": {},
		"declare_war": 0,
		"peace_events": 0,
		"hostile_events": 0,
		"avg_tension_series": [],
		"avg_relation_series": [],
		"avg_weariness_series": [],
	}

	var snap0 := _snapshot_metrics(ids, world_rel)
	stats["avg_tension_series"].append(snap0["avg_tension"])
	stats["avg_relation_series"].append(snap0["avg_relation"])
	stats["avg_weariness_series"].append(snap0["avg_weariness"])

	# 5) Simulation days
	for day in range(1, days + 1):
		# a) cooling passif (important pour casser l’escalade “auto”)
		_daily_decay(ids, world_rel, faction_profiles)

		# b) collect candidates (A->B directionnel)
		var candidates: Array = []
		for a_id in ids:
			var map_a: Dictionary = world_rel[a_id]
			for b_id in map_a.keys():
				if b_id == a_id:
					continue
				var rel_ab: FactionRelationScore = map_a[b_id]

				var p := ArcDecisionUtil.compute_arc_event_chance(
					rel_ab,
					faction_profiles[a_id],
					faction_profiles[b_id],
					day,
					{"max_p": 0.35}
				)
				if p <= 0.0:
					continue
				# tirage “pré-sélection”
				if rng.randf() < p:
					candidates.append({"a": a_id, "b": b_id, "p": p})

		# c) limiter le budget d'events / jour (sinon n^2 explose la simulation)
		candidates.sort_custom(func(x, y): return float(x["p"]) > float(y["p"]))
		var take := min(max_events_per_day, candidates.size())

		for i in range(take):
			var c := candidates[i]
			var a_id: StringName = c["a"]
			var b_id: StringName = c["b"]

			var rel_ab: FactionRelationScore = world_rel[a_id][b_id]
			var rel_ba: FactionRelationScore = world_rel[b_id][a_id]

			# d) action selection
			var action := ArcDecisionUtil.select_arc_action_type(
				rel_ab,
				faction_profiles[a_id],
				faction_profiles[b_id],
				rng,
				day,
				{
					"external_threat": 0.15,
					"opportunity": _compute_opportunity(rel_ab, faction_profiles[a_id]),
					"temperature": 0.18
				}
			)

			if action == ArcDecisionUtil.ARC_IGNORE:
				continue

			# e) choix simulé (LOYAL/NEUTRAL/TRAITOR)
			var choice := _resolve_choice(action, rel_ab)

			# f) appliquer l’événement (deltas + cooldown + notebook)
			ArcEffectTable.apply_arc_resolution_event(
				action,
				choice,
				a_id,
				b_id,
				rel_ab,
				rel_ba,
				faction_profiles[a_id],
				faction_profiles[b_id],
				arc_notebook,
				day,
				rng
			)

			# g) stats
			_stats_add(stats, action, choice)

		# h) snapshot
		var snap := _snapshot_metrics(ids, world_rel)
		stats["avg_tension_series"].append(snap["avg_tension"])
		stats["avg_relation_series"].append(snap["avg_relation"])
		stats["avg_weariness_series"].append(snap["avg_weariness"])

	# 6) Invariants anti-escalade + résumé
	_print_summary(stats, days)
	_validate_invariants(stats, ids, world_rel, days)


# -----------------------------
# Decay passif (journalier)
# -----------------------------
func _daily_decay(ids: Array[StringName], world_rel: Dictionary, faction_profiles: Dictionary) -> void:
	# Ajuste ces bases si tu veux un monde plus/moins inflammable
	var base_tension_decay := 0.9
	var base_griev_decay := 0.6
	var base_wear_decay := 0.35

	for a_id in ids:
		var prof: FactionProfile = faction_profiles[a_id]
		var diplo := prof.get_personality(FactionProfile.PERS_DIPLOMACY, 0.5)
		var veng := prof.get_personality(FactionProfile.PERS_VENGEFULNESS, 0.5)

		var tension_mul := 0.70 + 0.80 * diplo           # diplomate => tension redescend plus vite
		var griev_mul := 0.55 + 0.90 * (1.0 - veng)      # vindicatif => grievance redescend moins vite

		var map_a: Dictionary = world_rel[a_id]
		for b_id in map_a.keys():
			var rs: FactionRelationScore = map_a[b_id]
			rs.tension = max(0.0, rs.tension - base_tension_decay * tension_mul)
			rs.grievance = max(0.0, rs.grievance - base_griev_decay * griev_mul)
			rs.weariness = max(0.0, rs.weariness - base_wear_decay)
			rs.clamp_all()


# -----------------------------
# Choix simulé (auto-résolution)
# -----------------------------
func _resolve_choice(action: StringName, rel_ab: FactionRelationScore) -> StringName:
	# Heuristique: plus tension/grievance sont hauts, plus c’est “LOYAL” côté acteur A (ça passe en force).
	var t := rel_ab.tension / 100.0
	var g := rel_ab.grievance / 100.0
	var bias := clampf(0.45 + 0.25*t + 0.20*g, 0.35, 0.75)

	var p_loyal := bias
	var p_neutral := 0.30
	var p_traitor := 1.0 - (p_loyal + p_neutral)
	p_traitor = clampf(p_traitor, 0.05, 0.25)

	# Ajustement selon type (paix : loyal plus probable, guerre : neutral un peu plus probable)
	if PEACE_ACTIONS.has(action):
		p_loyal = clampf(p_loyal + 0.10, 0.45, 0.85)
		p_neutral = 0.25
		p_traitor = 1.0 - (p_loyal + p_neutral)
	elif action == ArcDecisionUtil.ARC_DECLARE_WAR:
		p_neutral = 0.35
		p_loyal = clampf(p_loyal, 0.40, 0.70)
		p_traitor = 1.0 - (p_loyal + p_neutral)

	var r := rng.randf()
	if r < p_loyal:
		return ArcEffectTable.CHOICE_LOYAL
	if r < p_loyal + p_neutral:
		return ArcEffectTable.CHOICE_NEUTRAL
	return ArcEffectTable.CHOICE_TRAITOR


func _compute_opportunity(rel_ab: FactionRelationScore, a_prof: FactionProfile) -> float:
	# Rough: expansionism aide, weariness pénalise
	var expa := a_prof.get_personality(FactionProfile.PERS_EXPANSIONISM, 0.5)
	var w := rel_ab.weariness / 100.0
	return clampf(0.45 + 0.35*(expa - 0.5) - 0.40*w, 0.05, 0.95)


# -----------------------------
# Stats & invariants
# -----------------------------
func _stats_add(stats: Dictionary, action: StringName, choice: StringName) -> void:
	stats["events_total"] = int(stats["events_total"]) + 1

	var by_action: Dictionary = stats["by_action"]
	by_action[action] = int(by_action.get(action, 0)) + 1
	stats["by_action"] = by_action

	var by_choice: Dictionary = stats["by_choice"]
	by_choice[choice] = int(by_choice.get(choice, 0)) + 1
	stats["by_choice"] = by_choice

	if action == ArcDecisionUtil.ARC_DECLARE_WAR:
		stats["declare_war"] = int(stats["declare_war"]) + 1

	if PEACE_ACTIONS.has(action):
		stats["peace_events"] = int(stats["peace_events"]) + 1
	if HOSTILE_ACTIONS.has(action):
		stats["hostile_events"] = int(stats["hostile_events"]) + 1


func _snapshot_metrics(ids: Array[StringName], world_rel: Dictionary) -> Dictionary:
	var rels: Array[float] = []
	var tens: Array[float] = []
	var wears: Array[float] = []

	for a_id in ids:
		var map_a: Dictionary = world_rel[a_id]
		for b_id in map_a.keys():
			var rs: FactionRelationScore = map_a[b_id]
			rels.append(float(rs.relation))
			tens.append(float(rs.tension))
			wears.append(float(rs.weariness))

	return {
		"avg_relation": _mean(rels),
		"avg_tension": _mean(tens),
		"avg_weariness": _mean(wears),
	}


func _validate_invariants(stats: Dictionary, ids: Array[StringName], world_rel: Dictionary, days: int) -> void:
	var events_total := int(stats["events_total"])
	_assert(events_total >= min(5, days), "Too few events produced: %d over %d days" % [events_total, days])

	# Pas de “guerre partout”
	var max_wars := max(1, int(floor(float(days) / 20.0)) + 1) # ex: 30j => <=2
	_assert(int(stats["declare_war"]) <= max_wars,
		"Too many war declarations: %d (max %d for %d days)" % [int(stats["declare_war"]), max_wars, days])

	# Si on a pas mal d'hostilité, on doit voir au moins un peu de dé-escalade
	var hostile := int(stats["hostile_events"])
	var peace := int(stats["peace_events"])
	if hostile >= 8:
		_assert(peace >= 1, "Hostile events=%d but no peace/de-escalation event occurred" % hostile)

	# Tension globale ne doit pas “exploser”
	var t_series: Array = stats["avg_tension_series"]
	var t0 := float(t_series[0])
	var t_end := float(t_series[t_series.size() - 1])
	_assert(t_end <= 70.0, "Final avg tension too high: %f" % t_end)
	_assert(t_end <= t0 + 35.0, "Avg tension increased too much: %f -> %f" % [t0, t_end])

	# Un petit nombre de paires “ultra chaudes” max
	var hot_pairs := _count_hot_pairs(ids, world_rel)
	_assert(hot_pairs <= 3, "Too many hot pairs (tension>=80 and mean relation<=-70): %d" % hot_pairs)


func _count_hot_pairs(ids: Array[StringName], world_rel: Dictionary) -> int:
	var c := 0
	for i in range(ids.size()):
		for j in range(i + 1, ids.size()):
			var a := ids[i]
			var b := ids[j]
			var ab: FactionRelationScore = world_rel[a][b]
			var ba: FactionRelationScore = world_rel[b][a]
			var mean_rel := 0.5 * (float(ab.relation) + float(ba.relation))
			var mean_t := 0.5 * (ab.tension + ba.tension)
			if mean_t >= 80.0 and mean_rel <= -70.0:
				c += 1
	return c


func _print_summary(stats: Dictionary, days: int) -> void:
	print("\n--- Arc Simulation Summary (", days, " days) ---")
	print("Events total: ", stats["events_total"])
	print("Hostile: ", stats["hostile_events"], " | Peace: ", stats["peace_events"], " | War declares: ", stats["declare_war"])
	print("By choice: ", stats["by_choice"])
	print("By action: ", stats["by_action"])

	var ts: Array = stats["avg_tension_series"]
	var ws: Array = stats["avg_weariness_series"]
	var rs: Array = stats["avg_relation_series"]
	print("Avg tension:   ", ts[0], " -> ", ts[ts.size() - 1])
	print("Avg weariness: ", ws[0], " -> ", ws[ws.size() - 1])
	print("Avg relation:  ", rs[0], " -> ", rs[rs.size() - 1])


# -----------------------------
# Golden load / fallback
# -----------------------------
func _load_golden_profiles() -> Array[FactionProfile]:
	if not FileAccess.file_exists(GOLDEN_PATH):
		push_warning("Golden profiles not found at %s, generating 10 fallback profiles." % GOLDEN_PATH)
		return _generate_fallback_profiles(10)

	var f := FileAccess.open(GOLDEN_PATH, FileAccess.READ)
	_assert(f != null, "Cannot open %s" % GOLDEN_PATH)
	var txt := f.get_as_text()
	f.close()

	var json := JSON.new()
	var err := json.parse(txt)
	_assert(err == OK, "JSON parse failed in %s" % GOLDEN_PATH)
	var root: Dictionary = json.data

	var arr: Array = root.get("profiles", [])
	_assert(arr.size() > 0, "Golden file has no profiles")

	var out: Array[FactionProfile] = []
	for item in arr:
		out.append(_profile_from_json_dict(item))
	return out


func _profile_from_json_dict(d: Dictionary) -> FactionProfile:
	var p := FactionProfile.new()

	var axis_in: Dictionary = d.get("axis_affinity", {})
	var per_in: Dictionary = d.get("personality", {})

	p.axis_affinity = {}
	for ax in FactionProfile.ALL_AXES:
		p.axis_affinity[ax] = int(axis_in.get(String(ax), 0))

	p.personality = {}
	for k in FactionProfile.ALL_PERSONALITY_KEYS:
		p.personality[k] = float(per_in.get(String(k), 0.5))

	return p


func _generate_fallback_profiles(n: int) -> Array[FactionProfile]:
	var out: Array[FactionProfile] = []
	for _i in range(n):
		out.append(FactionProfile.generate_full_profile(rng, FactionProfile.GEN_NORMAL))
	return out


# -----------------------------
# Math + assert
# -----------------------------
func _mean(arr: Array[float]) -> float:
	if arr.is_empty():
		return 0.0
	var s := 0.0
	for v in arr:
		s += v
	return s / float(arr.size())

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

### Comment régler le nombre de jours
- Dans l’inspecteur : `days_to_simulate`
- Ou par code : `run(120)` (par exemple)
- Tu peux aussi exposer `max_events_per_day` pour contrôler la “densité” d’événements.

---

### À adapter chez toi (2 points)
1) **`ArcEffectTable.apply_arc_resolution_event(...)`** : si tu utilises la version “caps + personality”, branche-la ici (même signature, ou ajoute `params`).
2) `FactionRelationScore` doit avoir : `relation/trust/tension/grievance/weariness`, `clamp_all()`, `cooldown` via `is_on_cooldown` + `set_cooldown` (déjà dans notre design).

---

Si tu veux, je te fais une variante du test 3 qui :
- enregistre un **log d’événements** (jour, A, B, action, choice, avant/après),
- et calcule une métrique “**escalation index**” (tension↑ + relation↓ pondérée) pour prouver quantitativement que ça ne diverge pas.

Moi:
fais une variante du test 3 qui :

enregistre un log d’événements (jour, A, B, action, choice, avant/après),

et calcule une métrique “escalation index” (tension↑ + relation↓ pondérée) pour prouver quantitativement que ça ne diverge pas.

ChatGPT:
OK. Voici une **variante du Test 3** qui :

- enregistre un **log détaillé** par événement (jour, A, B, action, choice, avant/après sur AB et BA),
- calcule un **Escalation Index** journalier et global :
  - `EI_event = wT * max(0, Δtension_mean) + wR * max(0, -Δrelation_mean)`
  - (donc ça ne “récompense” pas la désescalade, mais mesure uniquement les poussées vers le conflit)
- écrit un fichier `user://arc_sim_log.json` + `user://arc_sim_summary.json`
- vérifie un invariant : **l’Escalation Index moyen ne doit pas exploser** (cap + cooldown + decay doivent le stabiliser).

---

## `TestArcSimulationLogged.gd`

```gdscript
# Godot 4.x
extends Node
class_name TestArcSimulationLogged

const GOLDEN_PATH := "user://golden_faction_profiles.json"
const LOG_PATH := "user://arc_sim_log.json"
const SUMMARY_PATH := "user://arc_sim_summary.json"

@export var days_to_simulate: int = 30
@export var max_events_per_day: int = 6

# Escalation metric weights
@export var w_tension: float = 1.0
@export var w_relation: float = 0.55

var rng := RandomNumberGenerator.new()

const PEACE_ACTIONS := [
	ArcDecisionUtil.ARC_TRUCE_TALKS,
	ArcDecisionUtil.ARC_REPARATIONS,
	ArcDecisionUtil.ARC_ALLIANCE_OFFER,
]

const HOSTILE_ACTIONS := [
	ArcDecisionUtil.ARC_RAID,
	ArcDecisionUtil.ARC_SABOTAGE,
	ArcDecisionUtil.ARC_DECLARE_WAR,
	ArcDecisionUtil.ARC_ULTIMATUM,
]

func _ready() -> void:
	rng.seed = 888888
	run(days_to_simulate)
	print("\n✅ Arc simulation (logged + escalation index): OK\n")
	get_tree().quit()


func run(days: int) -> void:
	_assert(days > 0, "days must be > 0")

	# 1) Load golden profiles
	var profiles_list := _load_golden_profiles()
	_assert(profiles_list.size() >= 6, "Need at least 6 profiles")

	var faction_profiles: Dictionary[StringName, FactionProfile] = {}
	for i in range(min(10, profiles_list.size())):
		faction_profiles[StringName("faction_%02d" % i)] = profiles_list[i]

	var ids: Array[StringName] = []
	for fid in faction_profiles.keys():
		ids.append(StringName(fid))

	# 2) Init relations world
	var world_rel := FactionRelationsUtil.initialize_relations_world(
		faction_profiles,
		rng,
		{
			"apply_reciprocity": true,
			"reciprocity_strength": 0.70,
			"keep_asymmetry": 0.30,
			"reciprocity_noise": 2,
			"max_change_per_pair": 18,
			"final_global_sanity": true,
			"max_extremes_per_faction": 2
		},
		{
			"desired_mean": 0.0,
			"desired_std": 22.0,
			"enemy_min": 1, "enemy_max": 2,
			"ally_min": 1, "ally_max": 2,
			"noise": 3,
			"tension_cap": 40.0,
			"final_recenter": true
		},
		{
			"w_axis_similarity": 80.0,
			"w_cross_conflict": 55.0,
			"tension_cap": 40.0
		}
	)

	# 3) Notebook
	var arc_notebook := ArcNotebook.new()

	# 4) Logs + metrics
	var event_log: Array = []
	var daily_escalation: Array[float] = []
	var daily_event_count: Array[int] = []

	# global counters
	var stats := {
		"events_total": 0,
		"by_action": {},
		"by_choice": {},
		"peace_events": 0,
		"hostile_events": 0,
		"declare_war": 0,
	}

	# baseline snapshot for divergence proof
	var baseline := _snapshot_global(ids, world_rel)

	# 5) Sim loop
	for day in range(1, days + 1):
		_daily_decay(ids, world_rel, faction_profiles)

		var candidates: Array = []
		for a_id in ids:
			var map_a: Dictionary = world_rel[a_id]
			for b_id in map_a.keys():
				if b_id == a_id:
					continue
				var rel_ab: FactionRelationScore = map_a[b_id]
				var p := ArcDecisionUtil.compute_arc_event_chance(
					rel_ab,
					faction_profiles[a_id],
					faction_profiles[b_id],
					day,
					{"max_p": 0.35}
				)
				if p > 0.0 and rng.randf() < p:
					candidates.append({"a": a_id, "b": b_id, "p": p})

		candidates.sort_custom(func(x, y): return float(x["p"]) > float(y["p"]))
		var take := min(max_events_per_day, candidates.size())

		var day_ei := 0.0
		var produced := 0

		for i in range(take):
			var c := candidates[i]
			var a_id: StringName = c["a"]
			var b_id: StringName = c["b"]

			var rel_ab: FactionRelationScore = world_rel[a_id][b_id]
			var rel_ba: FactionRelationScore = world_rel[b_id][a_id]

			# ---- BEFORE snapshot (pair mean) ----
			var before := _snapshot_pair_mean(rel_ab, rel_ba)

			var action := ArcDecisionUtil.select_arc_action_type(
				rel_ab,
				faction_profiles[a_id],
				faction_profiles[b_id],
				rng,
				day,
				{
					"external_threat": 0.15,
					"opportunity": _compute_opportunity(rel_ab, faction_profiles[a_id]),
					"temperature": 0.18
				}
			)
			if action == ArcDecisionUtil.ARC_IGNORE:
				continue

			var choice := _resolve_choice(action, rel_ab)

			# Apply event (deltas + cooldown + notebook)
			ArcEffectTable.apply_arc_resolution_event(
				action, choice,
				a_id, b_id,
				rel_ab, rel_ba,
				faction_profiles[a_id],
				faction_profiles[b_id],
				arc_notebook,
				day, rng
			)

			# ---- AFTER snapshot (pair mean) ----
			var after := _snapshot_pair_mean(rel_ab, rel_ba)

			# Escalation index contribution (only escalatory deltas)
			var ei := _event_escalation_index(before, after)
			day_ei += ei

			# Log entry (jour, A,B, action, choice, before/after AB & BA)
			event_log.append(_make_event_log_entry(day, a_id, b_id, action, choice, rel_ab, rel_ba, before, after, ei))

			# stats
			_stats_add(stats, action, choice)

			produced += 1

		daily_escalation.append(day_ei)
		daily_event_count.append(produced)

	# 6) Summaries + invariants
	var summary := _build_summary(stats, baseline, _snapshot_global(ids, world_rel), daily_escalation, daily_event_count, days)

	_write_json(LOG_PATH, {"seed": 888888, "days": days, "events": event_log})
	_write_json(SUMMARY_PATH, summary)

	print("\n📄 Saved logs to: ", LOG_PATH)
	print("📄 Saved summary to: ", SUMMARY_PATH)

	_print_summary(summary)
	_validate_escalation_invariants(summary, days)


# -----------------------------
# Escalation metric
# -----------------------------
func _event_escalation_index(before: Dictionary, after: Dictionary) -> float:
	# EI_event = wT * max(0, Δtension_mean) + wR * max(0, -Δrelation_mean)
	var dt := float(after["tension_mean"]) - float(before["tension_mean"])
	var dr := float(after["relation_mean"]) - float(before["relation_mean"])
	var inc_t := max(0.0, dt)
	var inc_r := max(0.0, -dr)
	return w_tension * inc_t + w_relation * inc_r


func _snapshot_pair_mean(rel_ab: FactionRelationScore, rel_ba: FactionRelationScore) -> Dictionary:
	return {
		"relation_mean": 0.5 * (float(rel_ab.relation) + float(rel_ba.relation)),
		"trust_mean": 0.5 * (float(rel_ab.trust) + float(rel_ba.trust)),
		"tension_mean": 0.5 * (rel_ab.tension + rel_ba.tension),
		"grievance_mean": 0.5 * (rel_ab.grievance + rel_ba.grievance),
		"weariness_mean": 0.5 * (rel_ab.weariness + rel_ba.weariness),
	}


func _make_event_log_entry(
	day: int,
	a_id: StringName,
	b_id: StringName,
	action: StringName,
	choice: StringName,
	rel_ab: FactionRelationScore,
	rel_ba: FactionRelationScore,
	before: Dictionary,
	after: Dictionary,
	ei: float
) -> Dictionary:
	return {
		"day": day,
		"a": String(a_id),
		"b": String(b_id),
		"action": String(action),
		"choice": String(choice),
		"ei": ei,
		"before_mean": before,
		"after_mean": after,
		"ab_before": {
			"relation": int(round(2.0*float(before["relation_mean"]) - float(rel_ba.relation))), # approx not needed but kept
		},
		"ab_after": {
			"relation": rel_ab.relation,
			"trust": rel_ab.trust,
			"tension": rel_ab.tension,
			"grievance": rel_ab.grievance,
			"weariness": rel_ab.weariness,
		},
		"ba_after": {
			"relation": rel_ba.relation,
			"trust": rel_ba.trust,
			"tension": rel_ba.tension,
			"grievance": rel_ba.grievance,
			"weariness": rel_ba.weariness,
		}
	}


# -----------------------------
# Daily decay
# -----------------------------
func _daily_decay(ids: Array[StringName], world_rel: Dictionary, faction_profiles: Dictionary) -> void:
	var base_tension_decay := 0.9
	var base_griev_decay := 0.6
	var base_wear_decay := 0.35

	for a_id in ids:
		var prof: FactionProfile = faction_profiles[a_id]
		var diplo := prof.get_personality(FactionProfile.PERS_DIPLOMACY, 0.5)
		var veng := prof.get_personality(FactionProfile.PERS_VENGEFULNESS, 0.5)

		var tension_mul := 0.70 + 0.80 * diplo
		var griev_mul := 0.55 + 0.90 * (1.0 - veng)

		var map_a: Dictionary = world_rel[a_id]
		for b_id in map_a.keys():
			var rs: FactionRelationScore = map_a[b_id]
			rs.tension = max(0.0, rs.tension - base_tension_decay * tension_mul)
			rs.grievance = max(0.0, rs.grievance - base_griev_decay * griev_mul)
			rs.weariness = max(0.0, rs.weariness - base_wear_decay)
			rs.clamp_all()


# -----------------------------
# Choice simulation + opportunity
# -----------------------------
func _resolve_choice(action: StringName, rel_ab: FactionRelationScore) -> StringName:
	var t := rel_ab.tension / 100.0
	var g := rel_ab.grievance / 100.0
	var bias := clampf(0.45 + 0.25*t + 0.20*g, 0.35, 0.75)

	var p_loyal := bias
	var p_neutral := 0.30
	var p_traitor := 1.0 - (p_loyal + p_neutral)
	p_traitor = clampf(p_traitor, 0.05, 0.25)

	if PEACE_ACTIONS.has(action):
		p_loyal = clampf(p_loyal + 0.10, 0.45, 0.85)
		p_neutral = 0.25
		p_traitor = 1.0 - (p_loyal + p_neutral)
	elif action == ArcDecisionUtil.ARC_DECLARE_WAR:
		p_neutral = 0.35
		p_loyal = clampf(p_loyal, 0.40, 0.70)
		p_traitor = 1.0 - (p_loyal + p_neutral)

	var r := rng.randf()
	if r < p_loyal:
		return ArcEffectTable.CHOICE_LOYAL
	if r < p_loyal + p_neutral:
		return ArcEffectTable.CHOICE_NEUTRAL
	return ArcEffectTable.CHOICE_TRAITOR


func _compute_opportunity(rel_ab: FactionRelationScore, a_prof: FactionProfile) -> float:
	var expa := a_prof.get_personality(FactionProfile.PERS_EXPANSIONISM, 0.5)
	var w := rel_ab.weariness / 100.0
	return clampf(0.45 + 0.35*(expa - 0.5) - 0.40*w, 0.05, 0.95)


# -----------------------------
# Global snapshots + summary
# -----------------------------
func _snapshot_global(ids: Array[StringName], world_rel: Dictionary) -> Dictionary:
	var rels: Array[float] = []
	var tens: Array[float] = []
	var wears: Array[float] = []
	var grs: Array[float] = []

	for a_id in ids:
		var map_a: Dictionary = world_rel[a_id]
		for b_id in map_a.keys():
			var rs: FactionRelationScore = map_a[b_id]
			rels.append(float(rs.relation))
			tens.append(float(rs.tension))
			wears.append(float(rs.weariness))
			grs.append(float(rs.grievance))

	return {
		"avg_relation": _mean(rels),
		"avg_tension": _mean(tens),
		"avg_weariness": _mean(wears),
		"avg_grievance": _mean(grs),
	}


func _build_summary(stats: Dictionary, base: Dictionary, end: Dictionary, daily_ei: Array[float], daily_ev: Array[int], days: int) -> Dictionary:
	var ei_sum := 0.0
	var ei_max := 0.0
	for v in daily_ei:
		ei_sum += v
		ei_max = max(ei_max, v)
	var ei_mean := ei_sum / float(max(1, daily_ei.size()))

	# "divergence signal": tension should not keep ramping linearly
	var t0 := float(base["avg_tension"])
	var t_end := float(end["avg_tension"])
	var drift := t_end - t0

	return {
		"days": days,
		"events_total": int(stats["events_total"]),
		"by_action": stats["by_action"],
		"by_choice": stats["by_choice"],
		"peace_events": int(stats["peace_events"]),
		"hostile_events": int(stats["hostile_events"]),
		"declare_war": int(stats["declare_war"]),

		"baseline": base,
		"final": end,
		"avg_tension_drift": drift,

		"escalation": {
			"w_tension": w_tension,
			"w_relation": w_relation,
			"daily": daily_ei,
			"daily_event_count": daily_ev,
			"sum": ei_sum,
			"mean": ei_mean,
			"max_day": ei_max,
		}
	}


func _print_summary(summary: Dictionary) -> void:
	print("\n--- Arc Simulation Logged Summary ---")
	print("Days: ", summary["days"], " | Events: ", summary["events_total"])
	print("Hostile: ", summary["hostile_events"], " | Peace: ", summary["peace_events"], " | War declares: ", summary["declare_war"])
	print("Avg tension drift: ", summary["avg_tension_drift"])
	print("Escalation EI mean/day: ", summary["escalation"]["mean"], " | max day: ", summary["escalation"]["max_day"])
	print("Baseline: ", summary["baseline"])
	print("Final:    ", summary["final"])
	print("By action: ", summary["by_action"])


func _validate_escalation_invariants(summary: Dictionary, days: int) -> void:
	# 1) EI moyen/jour ne doit pas exploser
	var ei_mean := float(summary["escalation"]["mean"])
	# ordre de grandeur: avec caps+cooldowns+decay, on attend EI/jour modéré
	_assert(ei_mean <= 18.0, "Escalation index mean/day too high: %f" % ei_mean)

	# 2) la tension globale ne doit pas diverger
	var drift := float(summary["avg_tension_drift"])
	_assert(drift <= 35.0, "Avg tension drift too high: %f" % drift)

	# 3) pas trop de guerres
	var max_wars := max(1, int(floor(float(days) / 20.0)) + 1)
	_assert(int(summary["declare_war"]) <= max_wars,
		"Too many war declarations: %d (max %d)" % [int(summary["declare_war"]), max_wars])


# -----------------------------
# IO helpers
# -----------------------------
func _write_json(path: String, payload: Dictionary) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	_assert(f != null, "Cannot open %s for writing" % path)
	f.store_string(JSON.stringify(payload, "\t"))
	f.close()


# -----------------------------
# Golden load / fallback
# -----------------------------
func _load_golden_profiles() -> Array[FactionProfile]:
	if not FileAccess.file_exists(GOLDEN_PATH):
		push_warning("Golden profiles not found at %s, generating 10 fallback profiles." % GOLDEN_PATH)
		return _generate_fallback_profiles(10)

	var f := FileAccess.open(GOLDEN_PATH, FileAccess.READ)
	_assert(f != null, "Cannot open %s" % GOLDEN_PATH)
	var txt := f.get_as_text()
	f.close()

	var json := JSON.new()
	var err := json.parse(txt)
	_assert(err == OK, "JSON parse failed in %s" % GOLDEN_PATH)
	var root: Dictionary = json.data

	var arr: Array = root.get("profiles", [])
	_assert(arr.size() > 0, "Golden file has no profiles")

	var out: Array[FactionProfile] = []
	for item in arr:
		out.append(_profile_from_json_dict(item))
	return out


func _profile_from_json_dict(d: Dictionary) -> FactionProfile:
	var p := FactionProfile.new()

	var axis_in: Dictionary = d.get("axis_affinity", {})
	var per_in: Dictionary = d.get("personality", {})

	p.axis_affinity = {}
	for ax in FactionProfile.ALL_AXES:
		p.axis_affinity[ax] = int(axis_in.get(String(ax), 0))

	p.personality = {}
	for k in FactionProfile.ALL_PERSONALITY_KEYS:
		p.personality[k] = float(per_in.get(String(k), 0.5))

	return p


func _generate_fallback_profiles(n: int) -> Array[FactionProfile]:
	var out: Array[FactionProfile] = []
	for _i in range(n):
		out.append(FactionProfile.generate_full_profile(rng, FactionProfile.GEN_NORMAL))
	return out


# -----------------------------
# Stats helper
# -----------------------------
func _stats_add(stats: Dictionary, action: StringName, choice: StringName) -> void:
	stats["events_total"] = int(stats["events_total"]) + 1

	var by_action: Dictionary = stats["by_action"]
	by_action[action] = int(by_action.get(action, 0)) + 1
	stats["by_action"] = by_action

	var by_choice: Dictionary = stats["by_choice"]
	by_choice[choice] = int(by_choice.get(choice, 0)) + 1
	stats["by_choice"] = by_choice

	if action == ArcDecisionUtil.ARC_DECLARE_WAR:
		stats["declare_war"] = int(stats["declare_war"]) + 1

	if PEACE_ACTIONS.has(action):
		stats["peace_events"] = int(stats["peace_events"]) + 1
	if HOSTILE_ACTIONS.has(action):
		stats["hostile_events"] = int(stats["hostile_events"]) + 1


# -----------------------------
# Math + assert
# -----------------------------
func _mean(arr: Array[float]) -> float:
	if arr.is_empty():
		return 0.0
	var s := 0.0
	for v in arr:
		s += v
	return s / float(arr.size())

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

### Fichiers générés
- `user://arc_sim_log.json` : liste des événements (jour, A, B, action, choice, EI, avant/après)
- `user://arc_sim_summary.json` : résumé + série `daily EI`

---

### Remarques pratiques
- Le log contient `before_mean/after_mean` (moyenne AB/BA). Si tu veux **avant/après AB et BA complets**, je peux te fournir une version qui snapshot explicitement `ab_before` et `ba_before` avant l’apply (là j’ai gardé “mean” en vrai avant, et “after” complet).
- L’invariant `EI_mean <= 18` est un **seuil de départ** : tu le calibreras selon tes deltas/caps/decay réels.

Si tu veux, je te fais la micro-amélioration “**avant complet AB + BA**” (relation/trust/tension/grievance/weariness) dans chaque entrée de log, c’est 10 lignes de plus et ça rend le débug beaucoup plus agréable.

Moi:
Oui, ajoute ca

ChatGPT:
Bien vu — voici la modification pour logger **avant complet AB** et **avant complet BA** (et après complet aussi), en plus des moyennes.

## 1) Ajoute ces helpers

```gdscript
func _snapshot_link(rs: FactionRelationScore) -> Dictionary:
	return {
		"relation": rs.relation,
		"trust": rs.trust,
		"tension": rs.tension,
		"grievance": rs.grievance,
		"weariness": rs.weariness,
		# optionnel si tu l'as: "friction": rs.friction
	}
```

Et remplace `_make_event_log_entry(...)` par une version qui prend `ab_before` + `ba_before`.

```gdscript
func _make_event_log_entry(
	day: int,
	a_id: StringName,
	b_id: StringName,
	action: StringName,
	choice: StringName,
	before_mean: Dictionary,
	after_mean: Dictionary,
	ab_before: Dictionary,
	ba_before: Dictionary,
	ab_after: Dictionary,
	ba_after: Dictionary,
	ei: float
) -> Dictionary:
	return {
		"day": day,
		"a": String(a_id),
		"b": String(b_id),
		"action": String(action),
		"choice": String(choice),
		"ei": ei,
		"before_mean": before_mean,
		"after_mean": after_mean,
		"ab_before": ab_before,
		"ba_before": ba_before,
		"ab_after": ab_after,
		"ba_after": ba_after,
	}
```

## 2) Dans la boucle d’événements, prends les snapshots AVANT puis APRÈS

Remplace la partie “BEFORE / AFTER” de la boucle par ça :

```gdscript
# ---- BEFORE snapshots ----
var before_mean := _snapshot_pair_mean(rel_ab, rel_ba)
var ab_before := _snapshot_link(rel_ab)
var ba_before := _snapshot_link(rel_ba)

var action := ArcDecisionUtil.select_arc_action_type(...)
if action == ArcDecisionUtil.ARC_IGNORE:
	continue

var choice := _resolve_choice(action, rel_ab)

ArcEffectTable.apply_arc_resolution_event(...)

# ---- AFTER snapshots ----
var after_mean := _snapshot_pair_mean(rel_ab, rel_ba)
var ab_after := _snapshot_link(rel_ab)
var ba_after := _snapshot_link(rel_ba)

var ei := _event_escalation_index(before_mean, after_mean)
day_ei += ei

event_log.append(_make_event_log_entry(
	day, a_id, b_id, action, choice,
	before_mean, after_mean,
	ab_before, ba_before,
	ab_after, ba_after,
	ei
))
```

## 3) Supprime l’ancienne version qui essayait de “reconstruire” `ab_before`
Dans ton script précédent, tu avais un bout approximatif :

```gdscript
"ab_before": {"relation": int(round(2.0*...))}
```

Tu peux le supprimer entièrement : maintenant on a le vrai snapshot.

---

Avec ça, chaque ligne du log te donne exactement :
- l’état AB et BA **avant**,
- l’état AB et BA **après**,
- le “mean” (pratique pour EI),
- et l’`ei` de l’événement.

Si tu veux, je peux aussi ajouter une sortie CSV (souvent plus agréable à analyser vite), mais le JSON suffit déjà bien.

Moi:
Une sortie cv serait parfaite

ChatGPT:
Parfait — on ajoute une **sortie CSV** (même contenu que le log JSON, mais aplati en colonnes).

Je te propose 2 fichiers :
- `user://arc_sim_events.csv` : **1 ligne = 1 événement** (avant/après AB & BA + moyennes + EI)
- `user://arc_sim_daily.csv` : **1 ligne = 1 jour** (events du jour + EI du jour + métriques globales)

Ci-dessous, uniquement les ajouts/modifs à faire dans `TestArcSimulationLogged.gd`.

---

## 1) Constantes CSV

Ajoute en haut :

```gdscript
const CSV_EVENTS_PATH := "user://arc_sim_events.csv"
const CSV_DAILY_PATH := "user://arc_sim_daily.csv"
```

---

## 2) Helpers CSV

Ajoute ces fonctions :

```gdscript
func _csv_cell(v) -> String:
	var s := ""
	if v == null:
		s = ""
	elif typeof(v) == TYPE_FLOAT:
		s = "%0.4f" % float(v)
	else:
		s = str(v)

	# escape quotes, wrap in quotes (safe for commas/newlines)
	s = s.replace("\"", "\"\"")
	return "\"" + s + "\""


func _write_csv(path: String, header: Array[String], rows: Array[Array]) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	_assert(f != null, "Cannot open %s for writing" % path)

	# header
	var h: Array[String] = []
	for c in header:
		h.append(_csv_cell(c))
	f.store_line(",".join(h))

	# rows
	for r in rows:
		var line: Array[String] = []
		for c in r:
			line.append(_csv_cell(c))
		f.store_line(",".join(line))

	f.close()
```

---

## 3) Export CSV “events”

Ajoute :

```gdscript
func _export_events_csv(event_log: Array) -> void:
	var header := [
		"day","a","b","action","choice","ei",

		"before_mean_relation","before_mean_trust","before_mean_tension","before_mean_grievance","before_mean_weariness",
		"after_mean_relation","after_mean_trust","after_mean_tension","after_mean_grievance","after_mean_weariness",

		"ab_before_relation","ab_before_trust","ab_before_tension","ab_before_grievance","ab_before_weariness",
		"ba_before_relation","ba_before_trust","ba_before_tension","ba_before_grievance","ba_before_weariness",

		"ab_after_relation","ab_after_trust","ab_after_tension","ab_after_grievance","ab_after_weariness",
		"ba_after_relation","ba_after_trust","ba_after_tension","ba_after_grievance","ba_after_weariness",
	]

	var rows: Array[Array] = []
	for e in event_log:
		var bm: Dictionary = e["before_mean"]
		var am: Dictionary = e["after_mean"]
		var abb: Dictionary = e["ab_before"]
		var bab: Dictionary = e["ba_before"]
		var aba: Dictionary = e["ab_after"]
		var baa: Dictionary = e["ba_after"]

		rows.append([
			e["day"], e["a"], e["b"], e["action"], e["choice"], e["ei"],

			bm["relation_mean"], bm["trust_mean"], bm["tension_mean"], bm["grievance_mean"], bm["weariness_mean"],
			am["relation_mean"], am["trust_mean"], am["tension_mean"], am["grievance_mean"], am["weariness_mean"],

			abb["relation"], abb["trust"], abb["tension"], abb["grievance"], abb["weariness"],
			bab["relation"], bab["trust"], bab["tension"], bab["grievance"], bab["weariness"],

			aba["relation"], aba["trust"], aba["tension"], aba["grievance"], aba["weariness"],
			baa["relation"], baa["trust"], baa["tension"], baa["grievance"], baa["weariness"],
		])

	_write_csv(CSV_EVENTS_PATH, header, rows)
	print("📄 Saved events CSV to: ", CSV_EVENTS_PATH)
```

---

## 4) Export CSV “daily”

Dans ton script, tu as déjà `daily_escalation` et `daily_event_count`. Ajoute aussi un snapshot global par jour (tension/relation/weariness/grievance). Le plus simple :

1) Déclare dans `run()` :

```gdscript
var daily_global: Array = [] # [{day, avg_tension, avg_relation, ...}]
```

2) À la fin de chaque jour, après `daily_escalation.append(...)`, ajoute :

```gdscript
var g := _snapshot_global(ids, world_rel)
daily_global.append({"day": day, "g": g})
```

3) Ajoute l’export :

```gdscript
func _export_daily_csv(daily_escalation: Array[float], daily_event_count: Array[int], daily_global: Array) -> void:
	var header := [
		"day","events","ei_day",
		"avg_relation","avg_tension","avg_grievance","avg_weariness"
	]

	var rows: Array[Array] = []
	for i in range(daily_escalation.size()):
		var day := i + 1
		var g: Dictionary = daily_global[i]["g"]
		rows.append([
			day,
			daily_event_count[i],
			daily_escalation[i],
			g["avg_relation"],
			g["avg_tension"],
			g["avg_grievance"],
			g["avg_weariness"]
		])

	_write_csv(CSV_DAILY_PATH, header, rows)
	print("📄 Saved daily CSV to: ", CSV_DAILY_PATH)
```

---

## 5) Appels à la fin du test

Après tes `_write_json(...)`, ajoute :

```gdscript
_export_events_csv(event_log)
_export_daily_csv(daily_escalation, daily_event_count, daily_global)
```

---

Si tu veux, je peux aussi te proposer une version “compacte” du CSV events (juste day/A/B/action/choice/EI + before/after mean), utile quand tu veux juste tracer vite l’escalation.

Moi:
Non ca suffira
Selon toi, est ce que le systeme que tu viens de créer est complet? 
Qu'est ce qui pourrait manquer ?
A la fin, chaque faction va se baser sur ce que tu as fait pour creer des offres de quetes

ChatGPT:
Oui, tu as déjà une base très solide et “fermée” (profils → relations → arcs → décisions → effets → caps/cooldowns → tests). Pour que ce soit vraiment complet en jeu (et pas juste en test), il manque surtout des **points d’intégration** et quelques **garde-fous de design**.

## Ce qui manque le plus souvent en prod

### 1) Un “ArcState” par paire (état explicite)
Aujourd’hui tu as des métriques (relation/tension/grievance/…) + notebook. C’est très bien, mais il te manque un état clair :
- `PEACE / RIVALRY / CONFLICT / WAR / ALLIANCE / VASSAL / MERGED`
Ça sert à :
- contrôler quelles actions sont autorisées (pas d’“alliance offer” en pleine guerre totale),
- adapter les probabilités,
- définir quand un arc **se termine** (sortie propre).

### 2) Des “conditions de fin” + “cooldown long” d’arc
Tu as cap/cooldown par évènement, mais il faut aussi une règle de fin :
- Rivalité se termine si `tension_mean < X` pendant Y jours,
- ou si `trust_mean > X` et `relation_mean > X`,
- ou si guerre déclarée → on passe en état WAR et on stoppe certains arcs “mineurs”.
Et surtout un `pair_lock_days` (genre 15–40 jours) après résolution d’un arc majeur (trêve, alliance, fusion), sinon tu “re-rentres” tout de suite en incident.

### 3) Un modèle de “coût” et “capacité” faction (budget d’actions)
Pour éviter que des factions déclenchent trop d’offres :
- budget/jour ou budget/semaine (dépend de ressources/logistique, état de guerre, fatigue),
- limite d’offres actives par faction,
- coût par action type (raid coûte moins qu’une guerre, trêve coûte du capital politique, etc.).
Sans ça, tu risques un spam d’offres même si la probabilité est stable.

### 4) Le mapping “arc_action_type → offres de quêtes”
C’est LE pont vers ton QuestPool :
- chaque `arc_action_type` doit produire 1+ **templates d’offres** (avec variantes),
- et des **context keys** standardisées (`arc_action_type`, `giver`, `antagonist`, `target_poi`, `stake`, `deadline`, etc.).
Il manque donc une table “OfferFactory” :
- `arc.raid` → quests combat/stealth/supply-line,
- `arc.ultimatum` → diplomacy / escort envoy / retrieve proof,
- `arc.truce_talks` → escort diplomat / secure venue / eliminate spoiler,
- `arc.alliance_offer` → joint mission / exchange hostages / oath ritual.

### 5) Une boucle “monde” cohérente (pas seulement ArcManager)
Les arcs ne doivent pas être l’unique moteur :
- les goals (FactionGoalPlanner) doivent influencer `opportunity`, `external_threat`, `priority targets`,
- et inversement les arcs doivent modifier les goals (en guerre, les objectifs changent).
Sinon, tu auras des arcs “hors-sol”.

### 6) Une notion de “third party” (intervention, médiation, opportunisme)
Très important pour éviter l’escalade binaire A↔B :
- C intervient comme médiateur (trêve) ou profite (raid opportuniste),
- les offres peuvent impliquer 3 factions (donne beaucoup de vie au monde).
Même une version simple (“si A↔B est chaud, C peut proposer trêve/commerce/allié”) ajoute énormément.

### 7) La persistance et la stabilité des métriques
Pour être safe :
- sérialiser `FactionRelationScore` + `ArcNotebook` (counts/last_day + records),
- versionner le format (quand tu changes les champs, tu ne casses pas une save).

## Pour “chaque faction va créer des offres de quêtes”
Oui, ton système est parfaitement adapté à ça, mais je recommande une étape intermédiaire :

**Decision (ArcDecisionUtil)** → **Intent (ArcIntent)** → **QuestOffer(s)**

Un `ArcIntent` est une structure simple :
- `type` (raid/truce/…)
- `a_id`, `b_id`
- `priority`, `deadline_days`
- `suggested_domains` (combat/diplomacy/stealth/…)
- `stakes` (resource, artifact, territory, reputation…)

Puis une `QuestOfferFactory` transforme ça en 1..N offers dans ton `QuestPool`, avec caps.

## En bref
Le cœur “math/évolution” est complet. Ce qui manque pour passer en jeu, c’est surtout :
- **ArcState par paire + règles de fin**,
- **budget/capacité** pour éviter le spam,
- une **OfferFactory** qui mappe actions → quêtes,
- et un minimum de “tiers” (3e faction) pour casser les boucles.

Si tu veux, prochaine brique logique : je te propose une spec compacte de `ArcState` + conditions de transition + table `arc_action_type → liste d’offres` (avec context standard).

Moi:
Ok : prochaine brique logique : propose une spec compacte de ArcState + conditions de transition + table arc_action_type → liste d’offres (avec context standard).

ChatGPT:
Voici une spec **compacte mais complète** : un `ArcState` par paire, des **transitions** claires, et une **table action → offers** avec un `context` standardisé.

---

## 1) ArcState par paire

### Enum d’état
```text
NEUTRAL        (pas d’arc actif)
RIVALRY        (hostilité diffuse / incidents)
CONFLICT       (actions hostiles fréquentes, mais pas guerre totale)
WAR            (guerre ouverte)
TRUCE          (désescalade active, fragile)
ALLIANCE       (coopération active)
VASSALAGE      (optionnel) A domine B
MERGED         (terminal) fusion / absorption
EXTINCT        (terminal) faction détruite (hors scope arc mais utile)
```

### Structure `ArcState` (données minimales)
```gdscript
class_name ArcState
extends RefCounted

var a_id: StringName
var b_id: StringName
var state: StringName = &"NEUTRAL"   # see enum above

var entered_day: int = 0
var last_event_day: int = -999999
var lock_until_day: int = -999999     # empêche re-trigger trop vite

# compteurs “phase” (réinitialisés à chaque changement d’état)
var phase_hostile: int = 0
var phase_peace: int = 0
var phase_events: int = 0

# optionnel: dernier arc_action_type utile pour debug
var last_action: StringName = &""

func is_locked(day: int) -> bool:
	return day < lock_until_day
```

---

## 2) Conditions de transition (règles simples)

On utilise les **moyennes pair** :
- `rel_mean = (AB.relation + BA.relation)/2`
- `trust_mean`, `tension_mean`, `griev_mean`, `wear_mean`

Et on utilise aussi les compteurs `phase_hostile/phase_peace` alimentés par les actions.

### Seuils suggérés (tunable)
```text
t_high = 70   (tension haute)
t_med  = 50
t_low  = 25
rel_bad = -55
rel_hate = -70
rel_good = +35
trust_good = +55
griev_high = 60
wear_high  = 65
```

### Transitions (ordre d’évaluation recommandé)

#### A) Entrée en arc
- `NEUTRAL → RIVALRY` si :
  - `not locked` AND (`tension_mean >= t_med` OR `rel_mean <= rel_bad` OR “incident hostile”)  
  - et tu poses un `lock_until_day = day + 5..10` uniquement si tu veux éviter “retrigger immédiat” (optionnel)

#### B) Escalade
- `RIVALRY → CONFLICT` si :
  - `tension_mean >= t_high` **ou** `phase_hostile >= 3` sur une fenêtre (ex. 10 jours)  
  - **et** `wear_mean < wear_high` (si usure très haute, on force plutôt trêve/gel)
- `CONFLICT → WAR` si :
  - (`rel_mean <= rel_hate` AND `tension_mean >= t_high`)  
  - **ou** action `arc.declare_war` résolue LOYAL  
  - WAR met un lock plus long sur les “paix prématurées” (ex. 10 jours minimum avant trêve)

#### C) Désescalade
- `WAR → TRUCE` si :
  - `wear_mean >= wear_high` **ou** `phase_peace >= 2` (truce_talks/reparations)  
  - et `tension_mean <= 85` (si 100 constant, laisse respirer mais garde war)
- `CONFLICT → TRUCE` si :
  - `phase_peace >= 2` **ou** (`tension_mean <= t_med` AND `griev_mean <= griev_high`)
- `RIVALRY → NEUTRAL` si :
  - `tension_mean <= t_low` AND `griev_mean <= 20` pendant `Y jours` (ex. 7 jours)  
  - ou `phase_peace >= 2` + `trust_mean` remonte

#### D) Diplomatie / alliance / fusion
- `TRUCE → ALLIANCE` si :
  - `trust_mean >= trust_good` AND `rel_mean >= rel_good` AND `tension_mean <= t_low`
- `ALLIANCE → MERGED` si (rare, gated) :
  - `trust_mean >= 75` AND `rel_mean >= 60` ET conditions monde (même “bloc”, menace externe haute, intégrationnisme, etc.)
- `ALLIANCE → RIVALRY/CONFLICT` si :
  - grosse trahison (traitor sur alliance offer / sabotage) + tension remonte au-dessus de `t_med`

#### E) Verrous (anti-yo-yo)
Quand tu entres dans :
- `WAR` : `lock_until_day = day + 10..20`
- `TRUCE` : `lock_until_day = day + 6..12`
- `ALLIANCE` : `lock_until_day = day + 12..25`
- `MERGED` : terminal (plus d’arc pour la paire)

---

## 3) Table `arc_action_type → offers`

### Context standard (clés communes)
Toujours mettre au minimum :
```gdscript
context["is_arc_rivalry"] = true
context["arc_id"] = arc_id
context["arc_state"] = arc_state_name          # e.g. "RIVALRY"
context["arc_action_type"] = arc_action_type   # e.g. "arc.raid"

context["giver_faction_id"] = a_id
context["antagonist_faction_id"] = b_id

context["pair_key"] = "a|b"
context["deadline_days"] = int
context["stakes"] = { ... }        # structure légère (voir plus bas)
context["seed"] = int              # debug/repro
```

`stakes` recommandé :
```gdscript
context["stakes"] = {
  "gold": int,
  "relation_delta_hint": int,   # pour UI/preview
  "risk": float,               # 0..1
  "domain": "combat|diplo|stealth|logistics|exploration",
  "target_poi": StringName,    # optionnel
  "artifact_id": StringName,   # optionnel
}
```

### Table d’offres (catalogue compact)

> Chaque entrée retourne **1..N “offer specs”** : `{template_id OR generator_tag, weight, deadline_days, extra_context}`

```gdscript
const ARC_OFFERS: Dictionary = {
	&"arc.raid": [
		{"tag": "combat.raid_camp",        "w": 50, "deadline": 6, "ctx": {"domain":"combat"}},
		{"tag": "stealth.burn_supplies",   "w": 25, "deadline": 5, "ctx": {"domain":"stealth"}},
		{"tag": "logistics.intercept",     "w": 25, "deadline": 7, "ctx": {"domain":"logistics"}},
	],

	&"arc.sabotage": [
		{"tag": "stealth.sabotage_site",   "w": 55, "deadline": 7, "ctx": {"domain":"stealth"}},
		{"tag": "diplo.frame_agent",       "w": 20, "deadline": 6, "ctx": {"domain":"diplo"}},
		{"tag": "combat.assassinate",      "w": 25, "deadline": 8, "ctx": {"domain":"combat"}},
	],

	&"arc.ultimatum": [
		{"tag": "diplo.deliver_terms",     "w": 55, "deadline": 5, "ctx": {"domain":"diplo"}},
		{"tag": "combat.show_of_force",    "w": 25, "deadline": 6, "ctx": {"domain":"combat"}},
		{"tag": "logistics.seize_toll",    "w": 20, "deadline": 6, "ctx": {"domain":"logistics"}},
	],

	&"arc.truce_talks": [
		{"tag": "diplo.secure_venue",      "w": 45, "deadline": 6, "ctx": {"domain":"diplo"}},
		{"tag": "combat.protect_envoy",    "w": 30, "deadline": 6, "ctx": {"domain":"combat"}},
		{"tag": "stealth.remove_spoiler",  "w": 25, "deadline": 7, "ctx": {"domain":"stealth"}},
	],

	&"arc.reparations": [
		{"tag": "logistics.deliver_goods", "w": 45, "deadline": 8, "ctx": {"domain":"logistics"}},
		{"tag": "diplo.audit_treaty",      "w": 35, "deadline": 7, "ctx": {"domain":"diplo"}},
		{"tag": "combat.guard_caravan",    "w": 20, "deadline": 7, "ctx": {"domain":"combat"}},
	],

	&"arc.declare_war": [
		{"tag": "combat.capture_outpost",  "w": 45, "deadline": 10, "ctx": {"domain":"combat"}},
		{"tag": "logistics.mobilize",      "w": 30, "deadline": 9,  "ctx": {"domain":"logistics"}},
		{"tag": "stealth.break_alliance",  "w": 25, "deadline": 9,  "ctx": {"domain":"stealth"}},
	],

	&"arc.alliance_offer": [
		{"tag": "diplo.sign_pact",         "w": 45, "deadline": 8, "ctx": {"domain":"diplo"}},
		{"tag": "combat.joint_operation",  "w": 35, "deadline": 9, "ctx": {"domain":"combat"}},
		{"tag": "logistics.exchange_aid",  "w": 20, "deadline": 8, "ctx": {"domain":"logistics"}},
	],
}
```

### Sélection d’une offer (helper)
- choisit 1 entrée weighted,
- merge le context standard,
- ajoute `deadline_days`.

```gdscript
static func pick_offer_spec(action: StringName, rng: RandomNumberGenerator) -> Dictionary:
	var arr: Array = ARC_OFFERS.get(action, [])
	if arr.is_empty():
		return {}

	var sum := 0
	for s in arr:
		sum += int(s["w"])

	var r := rng.randi_range(1, max(1, sum))
	var acc := 0
	for s in arr:
		acc += int(s["w"])
		if r <= acc:
			return s
	return arr.back()
```

---

## 4) Comment ça s’assemble dans l’ArcManager

Pipeline recommandé par jour / tick :

1) Pour chaque paire, tu as `ArcState`.
2) Tu évalues si incident possible (proba) puis `arc_action_type`.
3) Tu génères 1 offer :
   - `spec = pick_offer_spec(action)`
   - `context = build_arc_context(ArcState, a,b, action, spec)`
4) Tu appelles ton `QuestPool.try_add_offer(QuestInstance(...))`
5) À la résolution, `ArcEffectTable` met à jour relations + notebook
6) Puis tu appelles `update_arc_state(pair_state, rel_ab, rel_ba, day, last_action, last_was_hostile/peace)`.

---

## 5) Petit “minimum viable” de `update_arc_state`
Tu peux coder ça avec un simple `match state` + règles ci-dessus, et un petit helper :

- `is_hostile_action(action)` (raid/sabotage/ultimatum/declare_war)
- `is_peace_action(action)` (truce/reparations/alliance_offer)

Et tu incrémentes :
- `phase_hostile += 1` si hostile
- `phase_peace += 1` si peace
- `phase_events += 1` toujours

Puis tu appliques transitions et reset `phase_*` quand state change.

---

Si tu veux, prochaine brique : je te donne le code GDScript de `update_arc_state()` (version compacte) + `build_arc_context()` + un `ArcOfferFactory.spawn_offer_for_pair()` qui produit une `QuestInstance` directement compatible avec ton QuestPool.

Moi:
donne le code GDScript de update_arc_state() (version compacte) + build_arc_context() + un ArcOfferFactory.spawn_offer_for_pair() qui produit une QuestInstance directement compatible avec ton QuestPool

ChatGPT:
Voici une implémentation **GDScript (Godot 4)** en 3 blocs :

1) `update_arc_state()` (compact, avec lock + compteurs phase)
2) `build_arc_context()` (context standard)
3) `ArcOfferFactory.spawn_offer_for_pair()` (retourne une `QuestInstance` “offer” compatible QuestPool)

> Hypothèses minimales :  
> - `QuestInstance.new(template, context)` existe  
> - `QuestTemplate.new()` existe (Resource) **ou** tu remplaceras `_build_template_fallback()` par ton générateur existant.  
> - `ArcDecisionUtil` contient les StringNames d’actions (`ARC_RAID`, etc.) comme on avait défini.

---

## 1) `ArcStateMachine.gd` — update_arc_state + build_arc_context

```gdscript
# ArcStateMachine.gd
class_name ArcStateMachine
extends RefCounted

# --- Arc states ---
const S_NEUTRAL: StringName  = &"NEUTRAL"
const S_RIVALRY: StringName  = &"RIVALRY"
const S_CONFLICT: StringName = &"CONFLICT"
const S_WAR: StringName      = &"WAR"
const S_TRUCE: StringName    = &"TRUCE"
const S_ALLIANCE: StringName = &"ALLIANCE"
const S_MERGED: StringName   = &"MERGED"
const S_EXTINCT: StringName  = &"EXTINCT"

static func is_hostile_action(action: StringName) -> bool:
	return action == ArcDecisionUtil.ARC_RAID \
		or action == ArcDecisionUtil.ARC_SABOTAGE \
		or action == ArcDecisionUtil.ARC_DECLARE_WAR \
		or action == ArcDecisionUtil.ARC_ULTIMATUM

static func is_peace_action(action: StringName) -> bool:
	return action == ArcDecisionUtil.ARC_TRUCE_TALKS \
		or action == ArcDecisionUtil.ARC_REPARATIONS \
		or action == ArcDecisionUtil.ARC_ALLIANCE_OFFER

static func pair_means(rel_ab: FactionRelationScore, rel_ba: FactionRelationScore) -> Dictionary:
	return {
		"rel": 0.5 * (float(rel_ab.relation) + float(rel_ba.relation)),
		"trust": 0.5 * (float(rel_ab.trust) + float(rel_ba.trust)),
		"tension": 0.5 * (rel_ab.tension + rel_ba.tension),
		"griev": 0.5 * (rel_ab.grievance + rel_ba.grievance),
		"wear": 0.5 * (rel_ab.weariness + rel_ba.weariness),
	}

static func _lock_days_for_state(state: StringName, rng: RandomNumberGenerator) -> int:
	match state:
		S_WAR:      return rng.randi_range(10, 20)
		S_TRUCE:    return rng.randi_range(6, 12)
		S_ALLIANCE: return rng.randi_range(12, 25)
		S_RIVALRY:  return rng.randi_range(4, 9)
		S_CONFLICT: return rng.randi_range(6, 12)
		_:          return rng.randi_range(3, 7)

static func _reset_phase(arc_state: ArcState) -> void:
	arc_state.phase_hostile = 0
	arc_state.phase_peace = 0
	arc_state.phase_events = 0
	arc_state.entered_day = arc_state.last_event_day

static func _enter_state(arc_state: ArcState, new_state: StringName, day: int, rng: RandomNumberGenerator) -> void:
	arc_state.state = new_state
	arc_state.entered_day = day
	arc_state.lock_until_day = day + _lock_days_for_state(new_state, rng)
	arc_state.phase_hostile = 0
	arc_state.phase_peace = 0
	arc_state.phase_events = 0

# -------------------------------------------------------------------
# update_arc_state() (compact)
# Appelé APRÈS résolution d’un event (donc on connaît last_action/choice)
# -------------------------------------------------------------------
static func update_arc_state(
	arc_state: ArcState,
	rel_ab: FactionRelationScore,
	rel_ba: FactionRelationScore,
	day: int,
	rng: RandomNumberGenerator,
	last_action: StringName = &"",
	last_choice: StringName = &"" # ArcEffectTable.CHOICE_...
) -> bool:
	# returns true if state changed
	if arc_state.state == S_MERGED or arc_state.state == S_EXTINCT:
		return false

	arc_state.last_event_day = day
	arc_state.last_action = last_action
	arc_state.phase_events += 1

	if is_hostile_action(last_action):
		arc_state.phase_hostile += 1
	elif is_peace_action(last_action):
		arc_state.phase_peace += 1

	var m := pair_means(rel_ab, rel_ba)
	var rel_mean := float(m["rel"])
	var trust_mean := float(m["trust"])
	var tension_mean := float(m["tension"])
	var griev_mean := float(m["griev"])
	var wear_mean := float(m["wear"])

	# Thresholds (tunable)
	var t_high := 70.0
	var t_med := 50.0
	var t_low := 25.0
	var rel_bad := -55.0
	var rel_hate := -70.0
	var rel_good := 35.0
	var trust_good := 55.0
	var griev_high := 60.0
	var wear_high := 65.0

	var prev := arc_state.state
	var locked := arc_state.is_locked(day)

	match arc_state.state:
		S_NEUTRAL:
			if not locked and (tension_mean >= t_med or rel_mean <= rel_bad or is_hostile_action(last_action)):
				_enter_state(arc_state, S_RIVALRY, day, rng)

		S_RIVALRY:
			if not locked:
				if tension_mean >= t_high or arc_state.phase_hostile >= 3:
					if wear_mean < wear_high:
						_enter_state(arc_state, S_CONFLICT, day, rng)
					else:
						_enter_state(arc_state, S_TRUCE, day, rng)
				elif tension_mean <= t_low and griev_mean <= 20.0 and arc_state.phase_peace >= 1:
					_enter_state(arc_state, S_NEUTRAL, day, rng)

		S_CONFLICT:
			if not locked:
				if (rel_mean <= rel_hate and tension_mean >= t_high) or (last_action == ArcDecisionUtil.ARC_DECLARE_WAR and last_choice == ArcEffectTable.CHOICE_LOYAL):
					_enter_state(arc_state, S_WAR, day, rng)
				elif arc_state.phase_peace >= 2 or (tension_mean <= t_med and griev_mean <= griev_high):
					_enter_state(arc_state, S_TRUCE, day, rng)

		S_WAR:
			# War => sortie surtout via usure ou actions de paix répétées
			if not locked:
				if wear_mean >= wear_high or arc_state.phase_peace >= 2:
					_enter_state(arc_state, S_TRUCE, day, rng)

		S_TRUCE:
			if not locked:
				if trust_mean >= trust_good and rel_mean >= rel_good and tension_mean <= t_low:
					_enter_state(arc_state, S_ALLIANCE, day, rng)
				elif tension_mean >= t_med and arc_state.phase_hostile >= 2:
					_enter_state(arc_state, S_CONFLICT, day, rng)
				elif tension_mean <= t_low and griev_mean <= 15.0 and arc_state.phase_peace >= 2:
					_enter_state(arc_state, S_NEUTRAL, day, rng)

		S_ALLIANCE:
			if not locked:
				# Rare merge gate (à renforcer avec des conditions monde si besoin)
				if trust_mean >= 75.0 and rel_mean >= 60.0 and tension_mean <= 15.0 and arc_state.phase_peace >= 2:
					_enter_state(arc_state, S_MERGED, day, rng)
				# Backslide
				elif tension_mean >= t_med and (arc_state.phase_hostile >= 2 or is_hostile_action(last_action)):
					_enter_state(arc_state, S_RIVALRY, day, rng)

		_:
			pass

	return arc_state.state != prev


# -------------------------------------------------------------------
# build_arc_context() standard
# -------------------------------------------------------------------
static func build_arc_context(
	arc_id: StringName,
	arc_state: ArcState,
	giver_id: StringName,
	ant_id: StringName,
	action: StringName,
	day: int,
	deadline_days: int,
	stakes: Dictionary,
	seed: int
) -> Dictionary:
	var pair_key := arc_state.a_id
	if String(arc_state.a_id) <= String(arc_state.b_id):
		pair_key = StringName(String(arc_state.a_id) + "|" + String(arc_state.b_id))
	else:
		pair_key = StringName(String(arc_state.b_id) + "|" + String(arc_state.a_id))

	return {
		"is_arc_rivalry": true,
		"arc_id": arc_id,
		"arc_state": arc_state.state,
		"arc_action_type": action,

		"giver_faction_id": giver_id,
		"antagonist_faction_id": ant_id,

		"pair_key": pair_key,
		"created_day": day,
		"deadline_days": deadline_days,

		"stakes": stakes,
		"seed": seed,
	}
```

---

## 2) `ArcOfferFactory.gd` — spawn_offer_for_pair() → QuestInstance(AVAILABLE)

```gdscript
# ArcOfferFactory.gd
class_name ArcOfferFactory
extends RefCounted

# action -> weighted offer specs
const ARC_OFFERS: Dictionary = {
	&"arc.raid": [
		{"tag": "combat.raid_camp",        "w": 50, "deadline": 6,  "ctx": {"domain":"combat"}},
		{"tag": "stealth.burn_supplies",   "w": 25, "deadline": 5,  "ctx": {"domain":"stealth"}},
		{"tag": "logistics.intercept",     "w": 25, "deadline": 7,  "ctx": {"domain":"logistics"}},
	],
	&"arc.sabotage": [
		{"tag": "stealth.sabotage_site",   "w": 55, "deadline": 7,  "ctx": {"domain":"stealth"}},
		{"tag": "diplo.frame_agent",       "w": 20, "deadline": 6,  "ctx": {"domain":"diplo"}},
		{"tag": "combat.assassinate",      "w": 25, "deadline": 8,  "ctx": {"domain":"combat"}},
	],
	&"arc.ultimatum": [
		{"tag": "diplo.deliver_terms",     "w": 55, "deadline": 5,  "ctx": {"domain":"diplo"}},
		{"tag": "combat.show_of_force",    "w": 25, "deadline": 6,  "ctx": {"domain":"combat"}},
		{"tag": "logistics.seize_toll",    "w": 20, "deadline": 6,  "ctx": {"domain":"logistics"}},
	],
	&"arc.truce_talks": [
		{"tag": "diplo.secure_venue",      "w": 45, "deadline": 6,  "ctx": {"domain":"diplo"}},
		{"tag": "combat.protect_envoy",    "w": 30, "deadline": 6,  "ctx": {"domain":"combat"}},
		{"tag": "stealth.remove_spoiler",  "w": 25, "deadline": 7,  "ctx": {"domain":"stealth"}},
	],
	&"arc.reparations": [
		{"tag": "logistics.deliver_goods", "w": 45, "deadline": 8,  "ctx": {"domain":"logistics"}},
		{"tag": "diplo.audit_treaty",      "w": 35, "deadline": 7,  "ctx": {"domain":"diplo"}},
		{"tag": "combat.guard_caravan",    "w": 20, "deadline": 7,  "ctx": {"domain":"combat"}},
	],
	&"arc.declare_war": [
		{"tag": "combat.capture_outpost",  "w": 45, "deadline": 10, "ctx": {"domain":"combat"}},
		{"tag": "logistics.mobilize",      "w": 30, "deadline": 9,  "ctx": {"domain":"logistics"}},
		{"tag": "stealth.break_alliance",  "w": 25, "deadline": 9,  "ctx": {"domain":"stealth"}},
	],
	&"arc.alliance_offer": [
		{"tag": "diplo.sign_pact",         "w": 45, "deadline": 8,  "ctx": {"domain":"diplo"}},
		{"tag": "combat.joint_operation",  "w": 35, "deadline": 9,  "ctx": {"domain":"combat"}},
		{"tag": "logistics.exchange_aid",  "w": 20, "deadline": 8,  "ctx": {"domain":"logistics"}},
	],
}

static func _pick_offer_spec(action: StringName, rng: RandomNumberGenerator) -> Dictionary:
	var arr: Array = ARC_OFFERS.get(action, [])
	if arr.is_empty():
		return {}
	var sum := 0
	for s in arr:
		sum += int(s["w"])
	var r := rng.randi_range(1, max(1, sum))
	var acc := 0
	for s in arr:
		acc += int(s["w"])
		if r <= acc:
			return s
	return arr.back()

static func _build_stakes(rel_ab: FactionRelationScore, action: StringName, domain: String) -> Dictionary:
	# Stakes “light” (UI/preview + génération)
	var risk := clampf(0.25 + 0.007 * rel_ab.tension + 0.006 * rel_ab.grievance, 0.1, 0.95)
	var gold := 40 + int(rel_ab.tension * 1.2) # simple, à adapter
	var hint := 0
	if action == ArcDecisionUtil.ARC_TRUCE_TALKS or action == ArcDecisionUtil.ARC_REPARATIONS:
		hint = +8
	elif action == ArcDecisionUtil.ARC_RAID or action == ArcDecisionUtil.ARC_SABOTAGE:
		hint = -8
	elif action == ArcDecisionUtil.ARC_DECLARE_WAR:
		hint = -12
	return {"gold": gold, "risk": risk, "domain": domain, "relation_delta_hint": hint}

static func _build_template_fallback(tag: String, action: StringName, tier: int) -> QuestTemplate:
	# Fallback si tu n'as pas ton QuestGenerator branché ici.
	# Remplace ça par ton create_dynamic_template(tag, params) si tu veux.
	var t := QuestTemplate.new()
	t.id = StringName("arc_" + tag)             # à adapter si ton id est String
	t.title = "Arc: " + tag
	t.description = "Arc offer (" + String(action) + ")"
	t.category = "ARC"
	t.tier = tier
	t.objective_type = "GENERIC"
	t.objective_target = tag
	t.objective_count = 1
	t.expires_in_days = 7
	return t

# -------------------------------------------------------------------
# spawn_offer_for_pair() -> QuestInstance AVAILABLE compatible QuestPool
# -------------------------------------------------------------------
static func spawn_offer_for_pair(
	arc_id: StringName,
	arc_state: ArcState,
	giver_id: StringName,
	ant_id: StringName,
	action: StringName,
	rel_ab: FactionRelationScore,                 # giver -> antagonist (pour stakes)
	faction_profiles: Dictionary,                 # optionnel si tu veux enrichir
	rng: RandomNumberGenerator,
	day: int,
	tier: int = 1,
	params: Dictionary = {}
) -> QuestInstance:
	var spec := _pick_offer_spec(action, rng)
	if spec.is_empty():
		return null

	var tag: String = String(spec["tag"])
	var deadline_days: int = int(spec.get("deadline", 7))
	var extra_ctx: Dictionary = Dictionary(spec.get("ctx", {}))
	var domain: String = String(extra_ctx.get("domain", "combat"))

	var stakes := _build_stakes(rel_ab, action, domain)
	var seed := rng.randi()

	# standard context
	var ctx := ArcStateMachine.build_arc_context(
		arc_id, arc_state, giver_id, ant_id, action, day, deadline_days, stakes, seed
	)

	# merge extra ctx
	for k in extra_ctx.keys():
		ctx[k] = extra_ctx[k]

	# template: try your generator if present, else fallback
	var template: QuestTemplate = null
	if Engine.has_singleton("QuestGeneratorRunner"):
		var qg = Engine.get_singleton("QuestGeneratorRunner")
		# adapte le nom de méthode à ton projet si besoin
		if qg != null and qg.has_method("create_dynamic_template_from_tag"):
			template = qg.create_dynamic_template_from_tag(tag, tier, ctx)
		elif qg != null and qg.has_method("_create_dynamic_template"):
			# si tu fais plutôt _create_dynamic_template(quest_type, params)
			template = qg._create_dynamic_template(tag, {"tier": tier})
	if template == null:
		template = _build_template_fallback(tag, action, tier)

	# instance offer
	var inst := QuestInstance.new(template, ctx)
	inst.status = QuestInstance.STATUS_AVAILABLE if "STATUS_AVAILABLE" in QuestInstance else "AVAILABLE"
	inst.started_on_day = day
	inst.expires_on_day = day + deadline_days
	inst.progress = 0

	return inst
```

---

## 3) Exemple d’utilisation dans ton ArcManager (tick)

```gdscript
# après avoir décidé action_type pour giver_id -> ant_id :
var inst := ArcOfferFactory.spawn_offer_for_pair(
	arc_id, pair_arc_state,
	giver_id, ant_id,
	action_type,
	relations[giver_id][ant_id],   # rel_ab
	faction_profiles,
	_rng, day,
	1 # tier
)

if inst != null:
	QuestPool.try_add_offer(inst) # ou QuestOfferSimRunner.try_add_offer(inst)
```

Et **à la résolution** (QuestManager → ArcManager), après `apply_arc_resolution_event(...)` :

```gdscript
ArcStateMachine.update_arc_state(
	pair_arc_state,
	relations[a][b],
	relations[b][a],
	day, _rng,
	action_type,
	choice
)
```

---

Si tu veux, prochaine brique logique : un `ArcOfferBudget` (budget/semaine par faction + cap par paire + cap par état) pour éviter le spam, et qui choisit aussi le **tier** de l’offre selon `state` (WAR → tier plus élevé, RIVALRY → tier faible).

Moi:
Il faut prendre aussi en compte les recompenses, plus la mission est difficile, plus elle coute cher, il fzut que la faction ai l'or pour payer

ChatGPT:
Oui — si la faction “giver” finance l’offre, il faut un **modèle d’économie** (trésor + réservations) et un **prix** lié à la difficulté. Sinon tu vas générer des offers “gratuites” qui cassent la cohérence.

Voici une implémentation simple (et robuste) qui s’intègre bien à ton système.

---

## 1) Données côté faction : trésor + escrow

```gdscript
# FactionEconomy.gd
class_name FactionEconomy
extends RefCounted

var gold: int = 0
var reserved_by_quest: Dictionary[StringName, int] = {} # runtime_id -> amount

func available_gold() -> int:
	var reserved := 0
	for k in reserved_by_quest.keys():
		reserved += int(reserved_by_quest[k])
	return gold - reserved

func can_reserve(amount: int) -> bool:
	return amount > 0 and available_gold() >= amount

func reserve_for_quest(quest_runtime_id: StringName, amount: int) -> bool:
	if not can_reserve(amount):
		return false
	reserved_by_quest[quest_runtime_id] = amount
	return true

func release_reservation(quest_runtime_id: StringName) -> void:
	reserved_by_quest.erase(quest_runtime_id)

func payout_reserved(quest_runtime_id: StringName, amount_override: int = -1) -> int:
	# Déduit réellement l’or du trésor, en consommant la réservation.
	var reserved := int(reserved_by_quest.get(quest_runtime_id, 0))
	var amount := reserved if amount_override < 0 else min(reserved, amount_override)
	if amount <= 0:
		return 0
	gold -= amount
	reserved_by_quest.erase(quest_runtime_id)
	return amount
```

---

## 2) Prix / récompense = fonction de difficulté

### Heuristique de difficulté (compacte)
On réutilise tes signaux : tension, grievance, état (WAR etc.), tier, “risk”.

```gdscript
static func compute_difficulty(
	arc_state_name: StringName,
	rel_ab: FactionRelationScore,
	risk: float,
	tier: int
) -> float:
	var state_factor := 0.0
	match arc_state_name:
		&"RIVALRY":  state_factor = 0.20
		&"CONFLICT": state_factor = 0.45
		&"WAR":      state_factor = 0.70
		&"TRUCE":    state_factor = 0.25
		&"ALLIANCE": state_factor = 0.20
		_:           state_factor = 0.15

	var t := rel_ab.tension / 100.0
	var g := rel_ab.grievance / 100.0
	var tier_factor := clampf(0.15 * float(max(tier - 1, 0)), 0.0, 0.45)

	# 0..~1.6 → clamp à 0..1
	var d := 0.35*risk + 0.30*t + 0.20*g + 0.15*state_factor + tier_factor
	return clampf(d, 0.0, 1.0)
```

### Récompense (gold) dérivée de la difficulté
```gdscript
static func compute_reward_gold(tier: int, difficulty: float, domain: String) -> int:
	var base := 40 + 35 * tier  # simple, monte vite
	# domain modifier (optionnel)
	var dom_mul := 1.0
	if domain == "combat":
		dom_mul = 1.10
	elif domain == "stealth":
		dom_mul = 1.00
	elif domain == "diplo":
		dom_mul = 0.95
	elif domain == "logistics":
		dom_mul = 1.00

	var reward := float(base) * dom_mul * (1.0 + 1.35*difficulty)
	return int(round(reward))
```

---

## 3) Modification ArcOfferFactory : ne spawn que si la faction peut payer

Tu ajoutes `faction_economies: Dictionary[StringName, FactionEconomy]` et tu réserves l’or dès la création de l’offre (escrow).

```gdscript
static func spawn_offer_for_pair(
	arc_id: StringName,
	arc_state: ArcState,
	giver_id: StringName,
	ant_id: StringName,
	action: StringName,
	rel_ab: FactionRelationScore,
	faction_profiles: Dictionary,
	faction_economies: Dictionary,          # <-- NEW
	rng: RandomNumberGenerator,
	day: int,
	tier: int = 1
) -> QuestInstance:
	var econ: FactionEconomy = faction_economies.get(giver_id, null)
	if econ == null:
		return null

	var spec := _pick_offer_spec(action, rng)
	if spec.is_empty():
		return null

	var tag: String = String(spec["tag"])
	var deadline_days: int = int(spec.get("deadline", 7))
	var extra_ctx: Dictionary = Dictionary(spec.get("ctx", {}))
	var domain: String = String(extra_ctx.get("domain", "combat"))

	# Stakes/risk
	var risk := clampf(0.25 + 0.007 * rel_ab.tension + 0.006 * rel_ab.grievance, 0.1, 0.95)

	# Difficulty -> reward
	var difficulty := compute_difficulty(arc_state.state, rel_ab, risk, tier)
	var reward_gold := compute_reward_gold(tier, difficulty, domain)

	# Budget check (escrow)
	if not econ.can_reserve(reward_gold):
		return null

	var stakes := {
		"gold": reward_gold,
		"risk": risk,
		"domain": domain,
		"difficulty": difficulty
	}

	var ctx := ArcStateMachine.build_arc_context(
		arc_id, arc_state, giver_id, ant_id, action, day, deadline_days, stakes, rng.randi()
	)
	for k in extra_ctx.keys():
		ctx[k] = extra_ctx[k]

	# Template
	var template: QuestTemplate = _build_template_fallback(tag, action, tier)

	# Instance
	var inst := QuestInstance.new(template, ctx)
	inst.status = "AVAILABLE"
	inst.started_on_day = day
	inst.expires_on_day = day + deadline_days
	inst.progress = 0

	# Reserve AFTER runtime_id is known
	var qid: StringName = StringName(inst.runtime_id)
	if not econ.reserve_for_quest(qid, reward_gold):
		return null

	# Persist escrow info in context
	inst.context["reward_gold"] = reward_gold
	inst.context["escrow_gold"] = reward_gold
	inst.context["escrow_faction_id"] = giver_id

	return inst
```

---

## 4) Où libérer / payer l’escrow

### A) Offer expirée / supprimée du pool
Quand `QuestPool` retire une offer (expired/invalid), tu fais :

```gdscript
var giver_id: StringName = inst.context.get("escrow_faction_id", &"")
var econ: FactionEconomy = faction_economies.get(giver_id, null)
if econ != null:
	econ.release_reservation(StringName(inst.runtime_id))
```

### B) Quête complétée (QuestManager.resolve_quest)
Au moment où tu attribues les récompenses :

```gdscript
var giver_id: StringName = inst.context.get("escrow_faction_id", &"")
var reward: int = int(inst.context.get("reward_gold", 0))
var econ: FactionEconomy = faction_economies.get(giver_id, null)
if econ != null:
	var paid := econ.payout_reserved(StringName(inst.runtime_id))
	# puis tu crédites le joueur / hero avec "paid"
```

Et si tu veux gérer LOYAL/NEUTRAL/TRAITOR :
- LOYAL : `paid = 100%`
- NEUTRAL : `paid = 70%` (le reste rendu à la faction → tu peux faire `econ.release + econ.payout_override`)
- TRAITOR : `paid = 0–30%` (ou confiscation / pénalité réputation)

---

## Ce que ça apporte immédiatement
- Les offres sont **économiquement plausibles**.
- Une faction pauvre **ne spamme pas**.
- Les quêtes “WAR / high tension” deviennent naturellement **plus rémunératrices** donc plus rares.
- Et ton ArcManager a un vrai levier : “peut-on financer l’action ?” → sinon il sélectionne une action moins chère / une autre cible.

Si tu veux, prochaine brique utile : un `ArcOfferBudget` (budget/jour + plafond escrow total) pour éviter qu’une faction riche bloque tout son or dans des offers simultanées.

Moi:
Ok

ChatGPT:
Parfait.

Prochaines étapes “concrètes” pour que ça tourne en vrai jeu :

1) **Ajouter `FactionEconomy` au monde**
- `economy_by_faction_id[giver_id] = FactionEconomy.new()`
- init `gold` (fixe, ou dérivé du tier/poids de faction).

2) **Brancher l’escrow dans le lifecycle des quêtes**
- **À la création d’une offer** : `reserve_for_quest(runtime_id, reward_gold)` (déjà dans `spawn_offer_for_pair`)
- **À l’expiration / suppression d’une offer** (QuestPool) : `release_reservation(runtime_id)`
- **À la complétion** (QuestManager.resolve) : `payout_reserved(runtime_id)` puis payer le joueur/héros
- **À l’échec** : soit remboursement (release) soit pénalité (payout partiel) selon design.

3) **Optionnel mais recommandé : fallback d’action si pas assez d’or**
- si `spawn_offer_for_pair()` retourne `null`, ArcManager tente un `arc_action_type` moins cher (ex: `ultimatum` → `raid` → `ignore`) ou baisse `tier`.

4) **Étendre Test 3**
- ajouter des trésors initiaux,
- vérifier qu’on ne génère pas d’offres quand `available_gold < reward`,
- vérifier que l’escrow revient bien à 0 après expiration/resolve.

Quand tu veux, je te donne le patch exact pour :
- `QuestPool.remove_expired_offers()` (release escrow),
- `QuestManager.resolve_quest()` (payout escrow + variations LOYAL/NEUTRAL/TRAITOR),
- et une version du **Test 3 logged** qui inclut la colonne `giver_gold_before/after` + `escrow_before/after` dans le CSV.

Moi:
Non, on fait 
2) Des “conditions de fin” + “cooldown long” d’arc

Tu as cap/cooldown par évènement, mais il faut aussi une règle de fin :

Rivalité se termine si tension_mean < X pendant Y jours,

ou si trust_mean > X et relation_mean > X,

ou si guerre déclarée → on passe en état WAR et on stoppe certains arcs “mineurs”.
Et surtout un pair_lock_days (genre 15–40 jours) après résolution d’un arc majeur (trêve, alliance, fusion), sinon tu “re-rentres” tout de suite en incident.

Mais je crois qu'on l'a deja dans ce que tu viens de faire non?

ChatGPT:
On l’a **en grande partie**, oui — mais pas totalement “au niveau prod” tel que tu l’as formulé.

### Ce qu’on a déjà dans le code
- **Cooldown court par évènement** : via `FactionRelationScore.set_cooldown()` (ex: 5–12 jours).
- **Pair lock** (verrou long) : via `ArcState.lock_until_day` + `_lock_days_for_state()`  
  - WAR / TRUCE / ALLIANCE ont déjà des locks plus longs.
- **Conditions de fin / sortie d’état** :
  - `RIVALRY → NEUTRAL` si `tension_mean <= t_low` + `griev` bas + `phase_peace >= 1`
  - `TRUCE → NEUTRAL`, `TRUCE → ALLIANCE`, etc.
- **Guerre déclarée stoppe les arcs “mineurs”** : implicite, parce qu’on passe en `WAR` et les prochaines actions seront filtrées par l’état (si tu le fais côté sélection d’actions/offers).

### Ce qui manque (ou est encore trop approximatif)
1) **“tension_mean < X pendant Y jours”**  
   Dans notre `update_arc_state()`, on a un check instantané + compteur `phase_peace`, mais pas un vrai *timer de stabilité*.
   - Si tu veux “pendant Y jours”, il faut un compteur dédié, typiquement :
     - `stable_low_tension_days`
     - `stable_high_trust_days`
   - Sinon un seul bon jour peut clôturer trop vite.

2) **Locks longs 15–40 jours après un évènement MAJEUR (trêve/alliance/fusion)**  
   On a des locks (ex: TRUCE 6–12, ALLIANCE 12–25), mais pas un **lock encore plus long** déclenché par *certains événements/choix* (ex: “signature de traité” ou “fusion”).
   - Tu veux un `pair_lock_days` post-évènement majeur, qui peut être **indépendant de l’état**.

3) **Stopper les arcs mineurs en WAR**  
   C’est mieux si c’est explicite : en `WAR`, on n’autorise que certains `arc_action_type` et certaines offers.

---

## Patch compact pour compléter exactement ta spec

### A) Ajoute des compteurs “stabilité” dans `ArcState`

```gdscript
# dans ArcState
var stable_low_tension_days: int = 0
var stable_high_trust_days: int = 0
```

### B) Mets à jour ces compteurs chaque jour (ou à chaque event)

Idéal : 1 fois par jour dans le tick pair, même sans event.  
Mais version compacte “à chaque update_arc_state” :

```gdscript
# après calcul des means
if tension_mean <= 25.0:
	arc_state.stable_low_tension_days += 1
else:
	arc_state.stable_low_tension_days = 0

if trust_mean >= 55.0 and rel_mean >= 35.0:
	arc_state.stable_high_trust_days += 1
else:
	arc_state.stable_high_trust_days = 0
```

### C) Utilise Y jours pour terminer la rivalité / trêve

```gdscript
var Y := 7  # tunable

# RIVALRY -> NEUTRAL
if arc_state.stable_low_tension_days >= Y:
	_enter_state(arc_state, S_NEUTRAL, day, rng)

# TRUCE -> NEUTRAL (plus rapide) ou TRUCE -> ALLIANCE
if arc_state.stable_low_tension_days >= Y and griev_mean <= 15.0:
	_enter_state(arc_state, S_NEUTRAL, day, rng)

if arc_state.stable_high_trust_days >= Y and tension_mean <= 25.0:
	_enter_state(arc_state, S_ALLIANCE, day, rng)
```

### D) Pair lock long déclenché par évènement majeur

Ajoute une fonction :

```gdscript
static func apply_major_pair_lock(arc_state: ArcState, day: int, rng: RandomNumberGenerator, min_d := 15, max_d := 40) -> void:
	arc_state.lock_until_day = max(arc_state.lock_until_day, day + rng.randi_range(min_d, max_d))
```

Et appelle-la quand tu résous un “évènement majeur”, par exemple :
- `arc.truce_talks` résolu LOYAL
- `arc.alliance_offer` résolu LOYAL
- état devient `MERGED`

Dans `update_arc_state`, juste avant de changer d’état ou juste après :

```gdscript
if last_action == ArcDecisionUtil.ARC_TRUCE_TALKS and last_choice == ArcEffectTable.CHOICE_LOYAL:
	apply_major_pair_lock(arc_state, day, rng)

if last_action == ArcDecisionUtil.ARC_ALLIANCE_OFFER and last_choice == ArcEffectTable.CHOICE_LOYAL:
	apply_major_pair_lock(arc_state, day, rng, 20, 50)

if arc_state.state == S_MERGED:
	apply_major_pair_lock(arc_state, day, rng, 9999, 9999) # terminal
```

### E) Stopper explicitement les arcs mineurs en WAR

Dans ta sélection d’actions/offers, impose :

```gdscript
if arc_state.state == S_WAR:
	allowed = [ARC_RAID, ARC_SABOTAGE, ARC_DECLARE_WAR]  # ou tes actions “war-only”
else:
	allowed = [...]
```

---

## Conclusion
- **Oui**, la direction est déjà là (locks + transitions).
- **Non**, il manque encore les deux éléments précis de ta spec :  
  **(1) “pendant Y jours”** (stabilité) et **(2) pair_lock long déclenché par événement majeur** (15–40j).

Si tu veux, je te renvoie `update_arc_state()` avec ces ajouts intégrés proprement (toujours compact), sans te redonner tout le fichier.

Moi:
Oui envoi

ChatGPT:
Voici une version **compacte** de `update_arc_state()` **avec** :

- compteurs de stabilité “**pendant Y jours**” (tension basse / confiance haute),
- **pair_lock long** (15–40 jours) déclenché par **événements majeurs**,
- transitions identiques à ce qu’on avait, mais avec “fin” plus robuste.

> À intégrer dans `ArcStateMachine.gd`.  
> Pré-requis : dans `ArcState`, ajoute :
> ```gdscript
> var stable_low_tension_days: int = 0
> var stable_high_trust_days: int = 0
> ```

---

```gdscript
static func apply_major_pair_lock(
	arc_state: ArcState,
	day: int,
	rng: RandomNumberGenerator,
	min_d: int = 15,
	max_d: int = 40
) -> void:
	arc_state.lock_until_day = max(arc_state.lock_until_day, day + rng.randi_range(min_d, max_d))


static func update_arc_state(
	arc_state: ArcState,
	rel_ab: FactionRelationScore,
	rel_ba: FactionRelationScore,
	day: int,
	rng: RandomNumberGenerator,
	last_action: StringName = &"",
	last_choice: StringName = &""
) -> bool:
	if arc_state.state == S_MERGED or arc_state.state == S_EXTINCT:
		return false

	arc_state.last_event_day = day
	arc_state.last_action = last_action
	arc_state.phase_events += 1

	if is_hostile_action(last_action):
		arc_state.phase_hostile += 1
	elif is_peace_action(last_action):
		arc_state.phase_peace += 1

	var m := pair_means(rel_ab, rel_ba)
	var rel_mean := float(m["rel"])
	var trust_mean := float(m["trust"])
	var tension_mean := float(m["tension"])
	var griev_mean := float(m["griev"])
	var wear_mean := float(m["wear"])

	# Thresholds (tunable)
	var t_high := 70.0
	var t_med  := 50.0
	var t_low  := 25.0
	var rel_bad := -55.0
	var rel_hate := -70.0
	var rel_good := 35.0
	var trust_good := 55.0
	var griev_high := 60.0
	var wear_high := 65.0

	# "Pendant Y jours"
	var Y_low_tension := 7
	var Y_high_trust := 7

	# --- Stability counters update (ideally daily tick; ok here too) ---
	if tension_mean <= t_low:
		arc_state.stable_low_tension_days += 1
	else:
		arc_state.stable_low_tension_days = 0

	if trust_mean >= trust_good and rel_mean >= rel_good:
		arc_state.stable_high_trust_days += 1
	else:
		arc_state.stable_high_trust_days = 0

	# --- Major event locks (post-major resolution) ---
	# Trêve réussie => verrou long pour éviter re-trigger immédiat
	if last_action == ArcDecisionUtil.ARC_TRUCE_TALKS and last_choice == ArcEffectTable.CHOICE_LOYAL:
		apply_major_pair_lock(arc_state, day, rng, 15, 40)

	# Alliance signée => encore plus long
	if last_action == ArcDecisionUtil.ARC_ALLIANCE_OFFER and last_choice == ArcEffectTable.CHOICE_LOYAL:
		apply_major_pair_lock(arc_state, day, rng, 20, 50)

	# Déclaration de guerre LOYAL => lock WAR plus long (optionnel)
	if last_action == ArcDecisionUtil.ARC_DECLARE_WAR and last_choice == ArcEffectTable.CHOICE_LOYAL:
		apply_major_pair_lock(arc_state, day, rng, 10, 25)

	var prev := arc_state.state
	var locked := arc_state.is_locked(day)

	match arc_state.state:
		S_NEUTRAL:
			if not locked and (tension_mean >= t_med or rel_mean <= rel_bad or is_hostile_action(last_action)):
				_enter_state(arc_state, S_RIVALRY, day, rng)

		S_RIVALRY:
			# Fin propre: tension basse PENDANT Y jours
			if arc_state.stable_low_tension_days >= Y_low_tension and griev_mean <= 20.0:
				_enter_state(arc_state, S_NEUTRAL, day, rng)
			elif not locked:
				if (tension_mean >= t_high or arc_state.phase_hostile >= 3):
					if wear_mean < wear_high:
						_enter_state(arc_state, S_CONFLICT, day, rng)
					else:
						_enter_state(arc_state, S_TRUCE, day, rng)

		S_CONFLICT:
			if not locked:
				# Escalade vers WAR
				if (rel_mean <= rel_hate and tension_mean >= t_high) \
				or (last_action == ArcDecisionUtil.ARC_DECLARE_WAR and last_choice == ArcEffectTable.CHOICE_LOYAL):
					_enter_state(arc_state, S_WAR, day, rng)
				# Désescalade vers TRUCE
				elif arc_state.phase_peace >= 2 or (tension_mean <= t_med and griev_mean <= griev_high):
					_enter_state(arc_state, S_TRUCE, day, rng)

		S_WAR:
			# Sortie de WAR: usure ou paix répétée (et pas locked)
			if not locked:
				if wear_mean >= wear_high or arc_state.phase_peace >= 2:
					_enter_state(arc_state, S_TRUCE, day, rng)

		S_TRUCE:
			# TRUCE peut finir (NEUTRAL) ou monter (ALLIANCE) via stabilité
			if arc_state.stable_high_trust_days >= Y_high_trust and tension_mean <= t_low:
				_enter_state(arc_state, S_ALLIANCE, day, rng)
			elif arc_state.stable_low_tension_days >= Y_low_tension and griev_mean <= 15.0:
				_enter_state(arc_state, S_NEUTRAL, day, rng)
			elif not locked:
				# Rechute
				if tension_mean >= t_med and arc_state.phase_hostile >= 2:
					_enter_state(arc_state, S_CONFLICT, day, rng)

		S_ALLIANCE:
			if not locked:
				# Merge rare gate + stabilité de confiance
				if trust_mean >= 75.0 and rel_mean >= 60.0 and tension_mean <= 15.0 and arc_state.stable_high_trust_days >= (Y_high_trust + 3):
					_enter_state(arc_state, S_MERGED, day, rng)
					apply_major_pair_lock(arc_state, day, rng, 9999, 9999) # terminal
				# Backslide
				elif tension_mean >= t_med and (arc_state.phase_hostile >= 2 or is_hostile_action(last_action)):
					_enter_state(arc_state, S_RIVALRY, day, rng)

		_:
			pass

	return arc_state.state != prev
```

### Notes rapides
- Pour que “pendant Y jours” soit **exact**, l’idéal est d’appeler une fonction `tick_day_for_pair()` qui met à jour `stable_*_days` même quand il n’y a **pas d’événement** ce jour-là. Là, c’est déjà beaucoup mieux que du “1-shot”, mais c’est encore event-driven.
- Le `apply_major_pair_lock()` est indépendant de l’état : exactement ce que tu voulais pour éviter de retomber immédiatement en incident après trêve/alliance.

Si tu veux, je te donne le mini `tick_day_for_pair(arc_state, rel_ab, rel_ba)` (10 lignes) pour que les compteurs “Y jours” soient parfaits même les jours sans arcs.

Moi:
Oui, donne le mini tick_day_for_pair(arc_state, rel_ab, rel_ba) (10 lignes) pour que les compteurs “Y jours” soient parfaits même les jours sans arcs.

ChatGPT:
```gdscript
static func tick_day_for_pair(arc_state: ArcState, rel_ab: FactionRelationScore, rel_ba: FactionRelationScore) -> void:
	var t_low := 25.0
	var rel_good := 35.0
	var trust_good := 55.0

	var tension_mean := 0.5 * (rel_ab.tension + rel_ba.tension)
	var rel_mean := 0.5 * (float(rel_ab.relation) + float(rel_ba.relation))
	var trust_mean := 0.5 * (float(rel_ab.trust) + float(rel_ba.trust))

	arc_state.stable_low_tension_days = arc_state.stable_low_tension_days + 1 if tension_mean <= t_low else 0
	arc_state.stable_high_trust_days = arc_state.stable_high_trust_days + 1 if (trust_mean >= trust_good and rel_mean >= rel_good) else 0
```

Moi:
Maintenant, on fait :
3) Un modèle de “coût” et “capacité” faction (budget d’actions)

Pour éviter que des factions déclenchent trop d’offres :

budget/jour ou budget/semaine (dépend de ressources/logistique, état de guerre, fatigue),

limite d’offres actives par faction,

coût par action type (raid coûte moins qu’une guerre, trêve coûte du capital politique, etc.).
Sans ça, tu risques un spam d’offres même si la probabilité est stable.
Si tu penses qu'on l'as deja fait en partie, dis moi ce qui manque et implemente a partir de ce qu'on a deja fait

ChatGPT:
On l’a **déjà en partie** grâce à l’**escrow d’or** (une faction pauvre ne peut pas payer ⇒ elle ne spawn pas).  
Mais ça **ne suffit pas** contre le spam, parce qu’une faction riche pourrait :

- générer **trop d’offres/jour**,
- ouvrir **trop d’offres en parallèle**,
- déclencher des actions “politiquement lourdes” (trêve/alliance/guerre) trop souvent.

Ce qui manque donc : un **budget de capacité** (points/jour ou points/semaine) + des **caps d’offres actives** + un **coût par action type** indépendant de l’or.

Ci-dessous une implémentation qui s’appuie sur ce qu’on a déjà : *ArcState / ArcOfferFactory / QuestPool*.

---

# 1) Budget de capacité : `FactionOfferBudget` + manager

## `FactionOfferBudget.gd`
```gdscript
class_name FactionOfferBudget
extends RefCounted

var faction_id: StringName

# Points “politiques / opérationnels”
var points: float = 0.0
var points_per_week: float = 70.0  # base (tunable)

# Caps
var max_active_offers: int = 6
var max_active_offers_per_pair: int = 2

# Tracking
var reserved_points_by_quest: Dictionary[StringName, float] = {}  # runtime_id -> points
var active_offer_ids: Dictionary[StringName, bool] = {}           # runtime_id -> true
var active_count_by_pair: Dictionary[StringName, int] = {}        # "a|b" -> count

func _init(id: StringName = &"") -> void:
	faction_id = id

func regen_daily(profile: FactionProfile, war_pressure: float = 0.0) -> void:
	# war_pressure 0..1 (ex: proportion de paires en WAR)
	# Logistique/discipline => meilleure regen (si tu as ces traits)
	var org := profile.get_personality(FactionProfile.PERS_ORGANIZATION, 0.5)
	var base := points_per_week / 7.0
	var mul := 0.85 + 0.50 * org
	mul *= (1.0 - 0.35 * clampf(war_pressure, 0.0, 1.0))
	points = min(points + base * mul, points_per_week)  # cap weekly

func _reserved_total() -> float:
	var s := 0.0
	for k in reserved_points_by_quest.keys():
		s += float(reserved_points_by_quest[k])
	return s

func available_points() -> float:
	return points - _reserved_total()

func can_open_offer(pair_key: StringName, cost_points: float) -> bool:
	if active_offer_ids.size() >= max_active_offers:
		return false
	if int(active_count_by_pair.get(pair_key, 0)) >= max_active_offers_per_pair:
		return false
	return available_points() >= cost_points

func reserve_for_offer(runtime_id: StringName, pair_key: StringName, cost_points: float) -> bool:
	if not can_open_offer(pair_key, cost_points):
		return false
	reserved_points_by_quest[runtime_id] = cost_points
	active_offer_ids[runtime_id] = true
	active_count_by_pair[pair_key] = int(active_count_by_pair.get(pair_key, 0)) + 1
	return true

func release_offer(runtime_id: StringName, pair_key: StringName, refund_ratio: float = 1.0) -> void:
	var reserved := float(reserved_points_by_quest.get(runtime_id, 0.0))
	reserved_points_by_quest.erase(runtime_id)
	active_offer_ids.erase(runtime_id)

	# décrémente pair count
	if active_count_by_pair.has(pair_key):
		active_count_by_pair[pair_key] = max(0, int(active_count_by_pair[pair_key]) - 1)

	# refund partiel (anti-spam): 1.0 = full refund, 0.8 = listing fee 20%
	refund_ratio = clampf(refund_ratio, 0.0, 1.0)
	points = min(points + reserved * refund_ratio, points_per_week)

func consume_on_resolution(runtime_id: StringName, pair_key: StringName) -> void:
	# à la résolution, on consomme 100%: on retire la réservation sans refund
	reserved_points_by_quest.erase(runtime_id)
	active_offer_ids.erase(runtime_id)
	if active_count_by_pair.has(pair_key):
		active_count_by_pair[pair_key] = max(0, int(active_count_by_pair[pair_key]) - 1)
```

## `ArcOfferBudgetManager.gd`
```gdscript
class_name ArcOfferBudgetManager
extends RefCounted

var budget_by_faction: Dictionary[StringName, FactionOfferBudget] = {}

func get_budget(faction_id: StringName) -> FactionOfferBudget:
	if not budget_by_faction.has(faction_id):
		budget_by_faction[faction_id] = FactionOfferBudget.new(faction_id)
	return budget_by_faction[faction_id]

func tick_day(faction_profiles: Dictionary, war_pressure_by_faction: Dictionary = {}) -> void:
	for fid in faction_profiles.keys():
		var b := get_budget(StringName(fid))
		var p: FactionProfile = faction_profiles[fid]
		var wp := float(war_pressure_by_faction.get(fid, 0.0))
		b.regen_daily(p, wp)
```

---

# 2) Coût par action type (points), dépendant difficulté/état/personnalité

À mettre dans `ArcOfferFactory.gd` (ou util séparé).

```gdscript
static func compute_action_cost_points(
	action: StringName,
	arc_state_name: StringName,
	difficulty: float,
	tier: int,
	giver_profile: FactionProfile
) -> float:
	# base costs (tunable)
	var base := 10.0
	match action:
		ArcDecisionUtil.ARC_RAID:          base = 10.0
		ArcDecisionUtil.ARC_SABOTAGE:      base = 12.0
		ArcDecisionUtil.ARC_ULTIMATUM:     base = 9.0
		ArcDecisionUtil.ARC_TRUCE_TALKS:   base = 14.0
		ArcDecisionUtil.ARC_REPARATIONS:   base = 16.0
		ArcDecisionUtil.ARC_ALLIANCE_OFFER:base = 18.0
		ArcDecisionUtil.ARC_DECLARE_WAR:   base = 30.0
		_:                                base = 11.0

	# état amplifie le coût (WAR = lourd)
	var state_mul := 1.0
	match arc_state_name:
		&"WAR":      state_mul = 1.25
		&"CONFLICT": state_mul = 1.10
		&"RIVALRY":  state_mul = 1.00
		&"TRUCE":    state_mul = 1.05
		&"ALLIANCE": state_mul = 1.10
		_:          state_mul = 1.00

	# difficulté & tier
	var diff_mul := 0.85 + 0.95 * clampf(difficulty, 0.0, 1.0)
	var tier_mul := 1.0 + 0.18 * float(max(tier - 1, 0))

	# personnalité: expansionism réduit coût hostile, diplomacy réduit coût peace
	var expa := giver_profile.get_personality(FactionProfile.PERS_EXPANSIONISM, 0.5)
	var diplo := giver_profile.get_personality(FactionProfile.PERS_DIPLOMACY, 0.5)

	var pers_mul := 1.0
	if ArcStateMachine.is_hostile_action(action):
		pers_mul *= (1.10 - 0.30 * expa)   # expa élevé => coût ↓
	if ArcStateMachine.is_peace_action(action):
		pers_mul *= (1.10 - 0.30 * diplo)  # diplo élevé => coût ↓

	return base * state_mul * diff_mul * tier_mul * pers_mul
```

---

# 3) Intégration dans `ArcOfferFactory.spawn_offer_for_pair()`

On combine **2 contraintes** :
1) **or** via `FactionEconomy.can_reserve(reward_gold)`
2) **capacité** via `FactionOfferBudget.can_open_offer(pair_key, cost_points)`

Ajouts (les lignes importantes) :

```gdscript
static func spawn_offer_for_pair(
	arc_id: StringName,
	arc_state: ArcState,
	giver_id: StringName,
	ant_id: StringName,
	action: StringName,
	rel_ab: FactionRelationScore,
	faction_profiles: Dictionary,
	faction_economies: Dictionary,
	budget_mgr: ArcOfferBudgetManager,          # <-- NEW
	rng: RandomNumberGenerator,
	day: int,
	tier: int = 1,
	params: Dictionary = {}
) -> QuestInstance:
	var econ: FactionEconomy = faction_economies.get(giver_id, null)
	if econ == null:
		return null

	var giver_prof: FactionProfile = faction_profiles.get(giver_id, null)
	if giver_prof == null:
		return null

	var spec := _pick_offer_spec(action, rng)
	if spec.is_empty():
		return null

	var extra_ctx: Dictionary = Dictionary(spec.get("ctx", {}))
	var domain: String = String(extra_ctx.get("domain", "combat"))

	# risk/difficulty/reward (comme avant)
	var risk := clampf(0.25 + 0.007 * rel_ab.tension + 0.006 * rel_ab.grievance, 0.1, 0.95)
	var difficulty := compute_difficulty(arc_state.state, rel_ab, risk, tier)
	var reward_gold := compute_reward_gold(tier, difficulty, domain)

	# pair_key (même que build_arc_context)
	var pair_key := StringName((String(giver_id) <= String(ant_id)) \
		? (String(giver_id) + "|" + String(ant_id)) \
		: (String(ant_id) + "|" + String(giver_id)))

	# --- NEW: capacity cost points ---
	var cost_points := compute_action_cost_points(action, arc_state.state, difficulty, tier, giver_prof)
	var budget := budget_mgr.get_budget(giver_id)

	# checks
	if not econ.can_reserve(reward_gold):
		return null
	if not budget.can_open_offer(pair_key, cost_points):
		return null

	# context + template + instance
	var stakes := {"gold": reward_gold, "risk": risk, "domain": domain, "difficulty": difficulty, "cost_points": cost_points}
	var ctx := ArcStateMachine.build_arc_context(arc_id, arc_state, giver_id, ant_id, action, day, int(spec.get("deadline", 7)), stakes, rng.randi())
	for k in extra_ctx.keys():
		ctx[k] = extra_ctx[k]

	var template: QuestTemplate = _build_template_fallback(String(spec["tag"]), action, tier)
	var inst := QuestInstance.new(template, ctx)
	inst.status = "AVAILABLE"
	inst.started_on_day = day
	inst.expires_on_day = day + int(spec.get("deadline", 7))
	inst.progress = 0

	# --- Reserve BOTH escrow gold and capacity points (after runtime_id exists) ---
	var qid := StringName(inst.runtime_id)

	if not econ.reserve_for_quest(qid, reward_gold):
		return null

	if not budget.reserve_for_offer(qid, pair_key, cost_points):
		# rollback gold if capacity fails
		econ.release_reservation(qid)
		return null

	# persist escrow info
	inst.context["escrow_faction_id"] = giver_id
	inst.context["escrow_gold"] = reward_gold
	inst.context["escrow_points"] = cost_points
	inst.context["pair_key"] = pair_key

	return inst
```

---

# 4) Lifecycle : release/consume des points + or

Tu fais déjà “release/payout” pour l’or. On ajoute pareil pour les points.

### A) Offer expirée / retirée du pool (pas acceptée)
Anti-spam conseillé : refund partiel (ex. 80% ⇒ listing fee 20%)

```gdscript
var giver_id: StringName = inst.context.get("escrow_faction_id", &"")
var pair_key: StringName = inst.context.get("pair_key", &"")
var qid: StringName = StringName(inst.runtime_id)

# gold
var econ: FactionEconomy = faction_economies.get(giver_id, null)
if econ != null:
	econ.release_reservation(qid)

# points (refund partiel)
var budget := budget_mgr.get_budget(giver_id)
budget.release_offer(qid, pair_key, 0.80) # 80% refund
```

### B) Quête résolue (acceptée puis terminée)
- Or : `payout_reserved()`
- Points : `consume_on_resolution()` (0 refund)

```gdscript
var giver_id: StringName = inst.context.get("escrow_faction_id", &"")
var pair_key: StringName = inst.context.get("pair_key", &"")
var qid: StringName = StringName(inst.runtime_id)

# gold payout vers joueur/héros
var econ: FactionEconomy = faction_economies.get(giver_id, null)
var paid := 0
if econ != null:
	paid = econ.payout_reserved(qid)

# points consumed
budget_mgr.get_budget(giver_id).consume_on_resolution(qid, pair_key)
```

---

# Résumé : ce qu’on avait / ce qu’on ajoute

✅ Déjà fait :  
- **or escrow** (payer la récompense)  
- **cooldowns** + **pair locks** + **tests**

✅ Ajout maintenant :  
- **budget de capacité** (points/semaine)  
- **caps d’offres actives** (global + par paire)  
- **coût par action type** (modulé par état/difficulté/tier/personnalité)  
- release/consume cohérent dans le lifecycle

---

Si tu veux la suite logique : je te propose un mini patch “ArcManager fallback” : quand `spawn_offer_for_pair()` échoue (pas assez d’or/points), il retente une action moins chère (ultimatum → raid → ignore) au lieu de simplement abandonner le tick.

Moi:
Ok propose un mini patch “ArcManager fallback” : quand spawn_offer_for_pair() échoue (pas assez d’or/points), il retente une action moins chère (ultimatum → raid → ignore) au lieu de simplement abandonner le tick.

ChatGPT:
Voici un mini patch **ArcManager fallback** : si `spawn_offer_for_pair()` échoue (or/points/caps), on retente une action moins chère dans un ordre typique :

- `DECLARE_WAR → ULTIMATUM → RAID → IGNORE`
- `ALLIANCE_OFFER → TRUCE_TALKS → REPARATIONS → IGNORE`
- `SABOTAGE → RAID → IGNORE`
- défaut : `ULTIMATUM → RAID → IGNORE`

## Patch compact (helpers + usage)

### 1) Helpers (dans `ArcManager.gd` ou util)

```gdscript
func _fallback_chain_for(action: StringName) -> Array[StringName]:
	match action:
		ArcDecisionUtil.ARC_DECLARE_WAR:
			return [ArcDecisionUtil.ARC_DECLARE_WAR, ArcDecisionUtil.ARC_ULTIMATUM, ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_IGNORE]
		ArcDecisionUtil.ARC_ALLIANCE_OFFER:
			return [ArcDecisionUtil.ARC_ALLIANCE_OFFER, ArcDecisionUtil.ARC_TRUCE_TALKS, ArcDecisionUtil.ARC_REPARATIONS, ArcDecisionUtil.ARC_IGNORE]
		ArcDecisionUtil.ARC_TRUCE_TALKS:
			return [ArcDecisionUtil.ARC_TRUCE_TALKS, ArcDecisionUtil.ARC_REPARATIONS, ArcDecisionUtil.ARC_IGNORE]
		ArcDecisionUtil.ARC_REPARATIONS:
			return [ArcDecisionUtil.ARC_REPARATIONS, ArcDecisionUtil.ARC_TRUCE_TALKS, ArcDecisionUtil.ARC_IGNORE]
		ArcDecisionUtil.ARC_SABOTAGE:
			return [ArcDecisionUtil.ARC_SABOTAGE, ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_IGNORE]
		ArcDecisionUtil.ARC_RAID:
			return [ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_IGNORE]
		ArcDecisionUtil.ARC_ULTIMATUM:
			return [ArcDecisionUtil.ARC_ULTIMATUM, ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_IGNORE]
		_:
			return [action, ArcDecisionUtil.ARC_ULTIMATUM, ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_IGNORE]


func _try_spawn_offer_with_fallback(
	arc_id: StringName,
	arc_state: ArcState,
	giver_id: StringName,
	ant_id: StringName,
	initial_action: StringName,
	rel_ab: FactionRelationScore,
	faction_profiles: Dictionary,
	faction_economies: Dictionary,
	budget_mgr: ArcOfferBudgetManager,
	rng: RandomNumberGenerator,
	day: int,
	tier: int
) -> QuestInstance:
	for action in _fallback_chain_for(initial_action):
		if action == ArcDecisionUtil.ARC_IGNORE:
			return null
		var inst := ArcOfferFactory.spawn_offer_for_pair(
			arc_id, arc_state,
			giver_id, ant_id,
			action,
			rel_ab,
			faction_profiles,
			faction_economies,
			budget_mgr,
			rng,
			day,
			tier
		)
		if inst != null:
			# important: mettre l’action réelle dans le context (si tu veux tracer)
			inst.context["arc_action_type"] = action
			inst.context["arc_action_type_initial"] = initial_action
			return inst
	return null
```

### 2) Usage dans ton tick (à la place de “spawn direct”)

```gdscript
var action := ArcDecisionUtil.select_arc_action_type(...)
var tier := _tier_for_state(pair_arc_state.state) # si tu as, sinon 1

var inst := _try_spawn_offer_with_fallback(
	arc_id, pair_arc_state,
	giver_id, ant_id,
	action,
	relations[giver_id][ant_id],
	faction_profiles,
	faction_economies,
	budget_mgr,
	_rng, day,
	tier
)

if inst != null:
	QuestPool.try_add_offer(inst)
	# optionnel: si tu veux considérer qu’un “intent” a eu lieu même si fallback
	# pair_arc_state.last_action = StringName(inst.context["arc_action_type"])
```

### (Optionnel) 3) Ajuster tier en fallback
Si tu veux encore plus robuste : quand le spawn échoue, on peut aussi baisser le tier avant de changer d’action :

- essayer `(action, tier)`
- puis `(action, tier-1)`
- puis fallback action…

Je te le fais si tu veux, mais le patch ci-dessus suffit déjà pour éviter les “ticks à vide” des factions riches mais capées.

Moi:
Fait :
Ajuster tier en fallback

Si tu veux encore plus robuste : quand le spawn échoue, on peut aussi baisser le tier avant de changer d’action :

essayer (action, tier)

puis (action, tier-1)

puis fallback action…

ChatGPT:
Voici une version “fallback robuste” qui essaie :

1) même **action** avec `tier`, puis `tier-1`, puis `tier-2`… jusqu’à `min_tier`
2) si toujours impossible → **fallback action** (ultimatum→raid→ignore etc.), et pour chaque action, même logique de tiers.

## Patch : `_try_spawn_offer_with_fallback_and_tier()`

```gdscript
func _try_spawn_offer_with_fallback_and_tier(
	arc_id: StringName,
	arc_state: ArcState,
	giver_id: StringName,
	ant_id: StringName,
	initial_action: StringName,
	rel_ab: FactionRelationScore,
	faction_profiles: Dictionary,
	faction_economies: Dictionary,
	budget_mgr: ArcOfferBudgetManager,
	rng: RandomNumberGenerator,
	day: int,
	tier: int,
	min_tier: int = 1
) -> QuestInstance:
	var chain := _fallback_chain_for(initial_action)

	for action in chain:
		if action == ArcDecisionUtil.ARC_IGNORE:
			return null

		var t := tier
		while t >= min_tier:
			var inst := ArcOfferFactory.spawn_offer_for_pair(
				arc_id, arc_state,
				giver_id, ant_id,
				action,
				rel_ab,
				faction_profiles,
				faction_economies,
				budget_mgr,
				rng,
				day,
				t
			)
			if inst != null:
				inst.context["arc_action_type"] = action
				inst.context["arc_action_type_initial"] = initial_action
				inst.context["arc_tier_initial"] = tier
				inst.context["arc_tier_final"] = t
				return inst

			t -= 1

	return null
```

## Utilisation dans ton tick

```gdscript
var action := ArcDecisionUtil.select_arc_action_type(...)
var tier := _tier_for_state(pair_arc_state.state) # ex: WAR=3, CONFLICT=2, RIVALRY=1
var inst := _try_spawn_offer_with_fallback_and_tier(
	arc_id, pair_arc_state,
	giver_id, ant_id,
	action,
	relations[giver_id][ant_id],
	faction_profiles,
	faction_economies,
	budget_mgr,
	_rng, day,
	tier,
	1
)

if inst != null:
	QuestPool.try_add_offer(inst)
```

### Conseil rapide
- Si tu veux éviter de “dégrader” trop souvent, tu peux limiter à `tier-1` seulement (au lieu de descendre jusqu’à 1), en remplaçant la boucle `while` par deux essais (`tier` puis `tier-1`).

Moi:
Fait que le nombre de fois qu'on degrader l'action et le tiers soit des parametre dans la fonction

ChatGPT:
Voici une version où **le nombre de dégradations d’action** et **le nombre de dégradations de tier** sont paramétrables.

- `max_action_degrades` : combien de “pas” on fait dans la chaîne de fallback (0 = seulement l’action initiale)
- `max_tier_degrades` : combien de fois on baisse le tier (0 = seulement tier initial)
- `min_tier` : plancher

```gdscript
func _try_spawn_offer_with_fallback_and_tier(
	arc_id: StringName,
	arc_state: ArcState,
	giver_id: StringName,
	ant_id: StringName,
	initial_action: StringName,
	rel_ab: FactionRelationScore,
	faction_profiles: Dictionary,
	faction_economies: Dictionary,
	budget_mgr: ArcOfferBudgetManager,
	rng: RandomNumberGenerator,
	day: int,
	tier: int,
	min_tier: int = 1,
	max_action_degrades: int = 2,  # 0 = aucune dégradation d’action
	max_tier_degrades: int = 1     # 0 = aucun downgrade de tier
) -> QuestInstance:
	var chain := _fallback_chain_for(initial_action)

	# Limite action: on prend 1 + max_action_degrades éléments max
	var max_actions := min(chain.size(), 1 + max_action_degrades)

	for ai in range(max_actions):
		var action: StringName = chain[ai]
		if action == ArcDecisionUtil.ARC_IGNORE:
			return null

		# essais de tier: tier, tier-1, ... limité par max_tier_degrades et min_tier
		var tries := 1 + max_tier_degrades
		for k in range(tries):
			var t := tier - k
			if t < min_tier:
				break

			var inst := ArcOfferFactory.spawn_offer_for_pair(
				arc_id, arc_state,
				giver_id, ant_id,
				action,
				rel_ab,
				faction_profiles,
				faction_economies,
				budget_mgr,
				rng,
				day,
				t
			)

			if inst != null:
				inst.context["arc_action_type"] = action
				inst.context["arc_action_type_initial"] = initial_action
				inst.context["arc_tier_initial"] = tier
				inst.context["arc_tier_final"] = t
				inst.context["arc_fallback_action_steps"] = ai
				inst.context["arc_fallback_tier_steps"] = k
				return inst

	return null
```

Exemple d’appel :
```gdscript
var inst := _try_spawn_offer_with_fallback_and_tier(
	arc_id, pair_arc_state,
	giver_id, ant_id,
	action,
	relations[giver_id][ant_id],
	faction_profiles,
	faction_economies,
	budget_mgr,
	_rng, day,
	tier,
	1,     # min_tier
	2,     # max_action_degrades (ex: action + 2 fallback)
	1      # max_tier_degrades (ex: tier puis tier-1)
)
```

Moi:
Maintenant, fait :
4) Le mapping “arc_action_type → offres de quêtes”
C’est LE pont vers ton QuestPool :
• chaque arc_action_type doit produire 1+ templates d’offres (avec variantes),
• et des context keys standardisées (arc_action_type, giver, antagonist, target_poi, stake, deadline, etc.).
Il manque donc une table “OfferFactory” :
• arc.raid → quests combat/stealth/supply-line,
• arc.ultimatum → diplomacy / escort envoy / retrieve proof,
• arc.truce_talks → escort diplomat / secure venue / eliminate spoiler,
• arc.alliance_offer → joint mission / exchange hostages / oath ritual.

ChatGPT:
OK — on va formaliser un vrai **OfferFactory** “arc_action_type → 1..N offers”, avec :

- **catalogue** (variants + poids + domaines + besoins de cible),
- **context standardisé** (keys communes + clés de cible),
- **spawn** qui produit des `QuestInstance` directement ajoutables au `QuestPool`.

Je te donne une implémentation **prête à brancher** (avec fallback si tes managers POI/QuestGenerator ne sont pas encore dispo).

---

# 1) Spec compacte du contexte standard

Toujours présent dans `inst.context` :

```gdscript
# Arc keys (communes)
"is_arc_rivalry": true
"arc_id": StringName
"arc_state": StringName          # NEUTRAL/RIVALRY/...
"arc_action_type": StringName    # arc.raid/arc.ultimatum/...
"giver_faction_id": StringName
"antagonist_faction_id": StringName
"pair_key": StringName           # "a|b"
"created_day": int
"deadline_days": int
"seed": int

# Offer keys (communes)
"offer_tag": String              # ex: "combat.raid_camp"
"offer_domain": String           # combat/diplo/stealth/logistics/exploration
"offer_kind": String             # "ARC_PRIMARY"/"ARC_SECONDARY"
"stakes": Dictionary             # gold/risk/difficulty/cost_points/...
```

Cibles standard (optionnelles, selon variant) :

```gdscript
"target_poi_id": StringName
"target_poi_type": StringName
"target_poi_pos": Vector2i

"target_faction_id": StringName        # si 3e partie/tiers
"target_character_id": StringName      # envoy/hostage/etc.
"target_item_tag": StringName          # proof/documents
"target_artifact_id": StringName
```

---

# 2) OfferFactory : catalogue + spawn 1..N offers

## `ArcOfferFactory.gd` (nouvelle version “catalogue + bundles”)

```gdscript
class_name ArcOfferFactory
extends RefCounted

# --------------------------------------------
# Catalogue : arc_action_type -> bundles
# Chaque bundle peut produire 1..N offers (primary + optional secondary)
# --------------------------------------------
const CATALOG: Dictionary = {
	&"arc.raid": {
		"count_min": 1,
		"count_max": 2,
		"variants": [
			{"tag":"combat.raid_camp",      "w":45, "domain":"combat",    "needs_poi":true,  "poi_types":[&"CAMP",&"OUTPOST"], "deadline":[5,8]},
			{"tag":"stealth.burn_supplies", "w":30, "domain":"stealth",   "needs_poi":true,  "poi_types":[&"DEPOT",&"WORKSHOP"], "deadline":[4,7]},
			{"tag":"logistics.intercept",   "w":25, "domain":"logistics", "needs_poi":false, "deadline":[6,9]},
		]
	},

	&"arc.ultimatum": {
		"count_min": 1,
		"count_max": 2,
		"variants": [
			{"tag":"diplo.deliver_terms",   "w":45, "domain":"diplo",     "needs_poi":true,  "poi_types":[&"CITY",&"CAPITAL"], "deadline":[4,6]},
			{"tag":"combat.show_of_force",  "w":30, "domain":"combat",    "needs_poi":true,  "poi_types":[&"BORDER",&"OUTPOST"], "deadline":[5,7]},
			{"tag":"diplo.retrieve_proof",  "w":25, "domain":"diplo",     "needs_poi":true,  "poi_types":[&"RUINS",&"LIBRARY"], "deadline":[6,9],
			 "ctx":{"target_item_tag":&"PROOF_DOSSIER"}}
		]
	},

	&"arc.truce_talks": {
		"count_min": 1,
		"count_max": 2,
		"variants": [
			{"tag":"diplo.secure_venue",    "w":40, "domain":"diplo",     "needs_poi":true, "poi_types":[&"CITY",&"SANCTUARY"], "deadline":[5,7]},
			{"tag":"combat.protect_envoy",  "w":35, "domain":"combat",    "needs_poi":true, "poi_types":[&"ROAD",&"CITY"], "deadline":[5,7],
			 "ctx":{"target_character_id":&"ENVOY"}},
			{"tag":"stealth.remove_spoiler","w":25, "domain":"stealth",   "needs_poi":true, "poi_types":[&"CITY",&"CAMP"], "deadline":[6,9]}
		]
	},

	&"arc.alliance_offer": {
		"count_min": 1,
		"count_max": 2,
		"variants": [
			{"tag":"combat.joint_operation","w":35, "domain":"combat",    "needs_poi":true, "poi_types":[&"RUINS",&"OUTPOST"], "deadline":[7,10]},
			{"tag":"diplo.exchange_hostages","w":35,"domain":"diplo",     "needs_poi":true, "poi_types":[&"CITY",&"CAPITAL"], "deadline":[6,9],
			 "ctx":{"target_character_id":&"HOSTAGE"}},
			{"tag":"diplo.oath_ritual",     "w":30, "domain":"diplo",     "needs_poi":true, "poi_types":[&"SANCTUARY",&"TEMPLE"], "deadline":[7,10],
			 "ctx":{"ritual":true}}
		]
	},

	&"arc.sabotage": {
		"count_min": 1,
		"count_max": 2,
		"variants": [
			{"tag":"stealth.sabotage_site", "w":55, "domain":"stealth",   "needs_poi":true,  "poi_types":[&"WORKSHOP",&"DEPOT"], "deadline":[6,9]},
			{"tag":"combat.assassinate",    "w":25, "domain":"combat",    "needs_poi":false, "deadline":[7,10]},
			{"tag":"diplo.frame_agent",     "w":20, "domain":"diplo",     "needs_poi":true,  "poi_types":[&"CITY"], "deadline":[6,8]},
		]
	},

	&"arc.declare_war": {
		"count_min": 2,   # guerre => souvent 2 offers (mobilisation + objectif)
		"count_max": 3,
		"variants": [
			{"tag":"logistics.mobilize",     "w":40, "domain":"logistics", "needs_poi":false, "deadline":[7,10]},
			{"tag":"combat.capture_outpost", "w":40, "domain":"combat",    "needs_poi":true,  "poi_types":[&"OUTPOST",&"BORDER"], "deadline":[8,12]},
			{"tag":"stealth.break_alliance", "w":20, "domain":"stealth",   "needs_poi":false, "deadline":[7,11]},
		]
	},

	&"arc.reparations": {
		"count_min": 1,
		"count_max": 2,
		"variants": [
			{"tag":"logistics.deliver_goods","w":45,"domain":"logistics", "needs_poi":true,  "poi_types":[&"CITY",&"CAPITAL"], "deadline":[7,11]},
			{"tag":"combat.guard_caravan",   "w":25,"domain":"combat",    "needs_poi":true,  "poi_types":[&"ROAD",&"CITY"], "deadline":[6,10]},
			{"tag":"diplo.audit_treaty",     "w":30,"domain":"diplo",     "needs_poi":true,  "poi_types":[&"CITY"], "deadline":[6,9]},
		]
	},
}

# -------------------------------------------------
# Utilities
# -------------------------------------------------
static func _weighted_pick(variants: Array, rng: RandomNumberGenerator) -> Dictionary:
	var sum := 0
	for v in variants:
		sum += int(v.get("w", 1))
	var r := rng.randi_range(1, max(1, sum))
	var acc := 0
	for v in variants:
		acc += int(v.get("w", 1))
		if r <= acc:
			return v
	return variants.back()

static func _roll_deadline_days(v: Dictionary, rng: RandomNumberGenerator) -> int:
	var d := v.get("deadline", [6, 9])
	return rng.randi_range(int(d[0]), int(d[1]))

static func _roll_count(bundle: Dictionary, rng: RandomNumberGenerator) -> int:
	return rng.randi_range(int(bundle.get("count_min", 1)), int(bundle.get("count_max", 1)))

static func _pair_key(a: StringName, b: StringName) -> StringName:
	return StringName((String(a) <= String(b)) ? (String(a) + "|" + String(b)) : (String(b) + "|" + String(a)))

# -------------------------------------------------
# Target POI resolution (stub + autoload-friendly)
# -------------------------------------------------
static func _pick_target_poi(poi_types: Array, rng: RandomNumberGenerator) -> Dictionary:
	# Attendu: { "id": StringName, "type": StringName, "pos": Vector2i }
	# Branche ton POIManager/WorldMap ici.
	if Engine.has_singleton("POIManagerRunner"):
		var pm = Engine.get_singleton("POIManagerRunner")
		if pm != null and pm.has_method("pick_random_poi"):
			return pm.pick_random_poi(poi_types, rng) # à adapter à ton API
	# fallback : aucun poi
	return {}

# -------------------------------------------------
# Template builder (fallback). Remplace par ton QuestGenerator si dispo.
# -------------------------------------------------
static func _build_template_fallback(tag: String, tier: int, deadline_days: int) -> QuestTemplate:
	var t := QuestTemplate.new()
	t.id = StringName("arc_" + tag)
	t.title = "Arc: " + tag
	t.description = "Arc offer: " + tag
	t.category = "ARC"
	t.tier = tier
	t.objective_type = "GENERIC"
	t.objective_target = tag
	t.objective_count = 1
	t.expires_in_days = deadline_days
	return t

# -------------------------------------------------
# Public API: spawn 1..N offers for a pair
# -------------------------------------------------
static func spawn_offers_for_pair(
	arc_id: StringName,
	arc_state: ArcState,
	giver_id: StringName,
	ant_id: StringName,
	action: StringName,
	rel_ab: FactionRelationScore,
	faction_profiles: Dictionary,
	faction_economies: Dictionary,
	budget_mgr: ArcOfferBudgetManager,
	rng: RandomNumberGenerator,
	day: int,
	tier: int,
	params: Dictionary = {}
) -> Array[QuestInstance]:
	var bundle: Dictionary = CATALOG.get(action, {})
	if bundle.is_empty():
		return []

	var variants: Array = bundle.get("variants", [])
	if variants.is_empty():
		return []

	var count := _roll_count(bundle, rng)
	var out: Array[QuestInstance] = []
	var used_tags := {}

	# on essaie de varier les offers (pas 2 fois le même tag)
	for idx in range(count):
		var tries := 0
		var v := {}
		while tries < 5:
			v = _weighted_pick(variants, rng)
			var tag := String(v.get("tag", ""))
			if tag != "" and not used_tags.has(tag):
				used_tags[tag] = true
				break
			tries += 1

		var offer := _spawn_single_offer_from_variant(
			arc_id, arc_state,
			giver_id, ant_id,
			StringName(action),
			rel_ab,
			faction_profiles,
			faction_economies,
			budget_mgr,
			rng, day,
			tier,
			v,
			(idx == 0) ? "ARC_PRIMARY" : "ARC_SECONDARY"
		)

		if offer != null:
			out.append(offer)

	return out


static func _spawn_single_offer_from_variant(
	arc_id: StringName,
	arc_state: ArcState,
	giver_id: StringName,
	ant_id: StringName,
	action: StringName,
	rel_ab: FactionRelationScore,
	faction_profiles: Dictionary,
	faction_economies: Dictionary,
	budget_mgr: ArcOfferBudgetManager,
	rng: RandomNumberGenerator,
	day: int,
	tier: int,
	variant: Dictionary,
	offer_kind: String
) -> QuestInstance:
	var econ: FactionEconomy = faction_economies.get(giver_id, null)
	var giver_prof: FactionProfile = faction_profiles.get(giver_id, null)
	if econ == null or giver_prof == null:
		return null

	var tag := String(variant.get("tag", ""))
	if tag == "":
		return null

	var domain := String(variant.get("domain", "combat"))
	var deadline_days := _roll_deadline_days(variant, rng)
	var pair_key := _pair_key(giver_id, ant_id)

	# --- cible POI si demandée ---
	var target_poi := {}
	if bool(variant.get("needs_poi", false)):
		target_poi = _pick_target_poi(variant.get("poi_types", []), rng)
		if target_poi.is_empty():
			return null # pas de cible => pas d’offre

	# --- stakes/risk/difficulty/reward ---
	var risk := clampf(0.25 + 0.007 * rel_ab.tension + 0.006 * rel_ab.grievance, 0.1, 0.95)
	var difficulty := ArcOfferFactoryEconomy.compute_difficulty(arc_state.state, rel_ab, risk, tier)
	var reward_gold := ArcOfferFactoryEconomy.compute_reward_gold(tier, difficulty, domain)

	# --- coût capacité ---
	var cost_points := ArcOfferFactoryEconomy.compute_action_cost_points(action, arc_state.state, difficulty, tier, giver_prof)
	var budget := budget_mgr.get_budget(giver_id)

	# --- checks ---
	if not econ.can_reserve(reward_gold):
		return null
	if not budget.can_open_offer(pair_key, cost_points):
		return null

	var stakes := {"gold": reward_gold, "risk": risk, "domain": domain, "difficulty": difficulty, "cost_points": cost_points}

	# context standard + patch variant ctx + target poi
	var ctx := ArcStateMachine.build_arc_context(arc_id, arc_state, giver_id, ant_id, action, day, deadline_days, stakes, rng.randi())
	ctx["offer_tag"] = tag
	ctx["offer_domain"] = domain
	ctx["offer_kind"] = offer_kind
	ctx["pair_key"] = pair_key

	var patch: Dictionary = variant.get("ctx", {})
	for k in patch.keys():
		ctx[k] = patch[k]

	if not target_poi.is_empty():
		ctx["target_poi_id"] = target_poi.get("id", &"")
		ctx["target_poi_type"] = target_poi.get("type", &"")
		ctx["target_poi_pos"] = target_poi.get("pos", Vector2i.ZERO)

	# template via QuestGenerator si dispo, sinon fallback
	var template: QuestTemplate = null
	if Engine.has_singleton("QuestGeneratorRunner"):
		var qg = Engine.get_singleton("QuestGeneratorRunner")
		if qg != null and qg.has_method("create_dynamic_template_from_tag"):
			template = qg.create_dynamic_template_from_tag(tag, tier, ctx)
	if template == null:
		template = _build_template_fallback(tag, tier, deadline_days)

	var inst := QuestInstance.new(template, ctx)
	inst.status = "AVAILABLE"
	inst.started_on_day = day
	inst.expires_on_day = day + deadline_days
	inst.progress = 0

	# reserve gold + points AFTER runtime_id exists
	var qid := StringName(inst.runtime_id)
	if not econ.reserve_for_quest(qid, reward_gold):
		return null
	if not budget.reserve_for_offer(qid, pair_key, cost_points):
		econ.release_reservation(qid)
		return null

	inst.context["escrow_faction_id"] = giver_id
	inst.context["escrow_gold"] = reward_gold
	inst.context["escrow_points"] = cost_points

	return inst
```

### Petit détail : les fonctions économie utilisées ci-dessus
Pour ne pas dupliquer, je te suggère un petit util séparé.

## `ArcOfferFactoryEconomy.gd` (util)
```gdscript
class_name ArcOfferFactoryEconomy
extends RefCounted

static func compute_difficulty(arc_state_name: StringName, rel_ab: FactionRelationScore, risk: float, tier: int) -> float:
	var state_factor := 0.15
	match arc_state_name:
		&"RIVALRY":  state_factor = 0.20
		&"CONFLICT": state_factor = 0.45
		&"WAR":      state_factor = 0.70
		&"TRUCE":    state_factor = 0.25
		&"ALLIANCE": state_factor = 0.20
	var t := rel_ab.tension / 100.0
	var g := rel_ab.grievance / 100.0
	var tier_factor := clampf(0.15 * float(max(tier - 1, 0)), 0.0, 0.45)
	return clampf(0.35*risk + 0.30*t + 0.20*g + 0.15*state_factor + tier_factor, 0.0, 1.0)

static func compute_reward_gold(tier: int, difficulty: float, domain: String) -> int:
	var base := 40 + 35 * tier
	var dom_mul := 1.0
	if domain == "combat": dom_mul = 1.10
	elif domain == "diplo": dom_mul = 0.95
	var reward := float(base) * dom_mul * (1.0 + 1.35*difficulty)
	return int(round(reward))

static func compute_action_cost_points(action: StringName, arc_state_name: StringName, difficulty: float, tier: int, giver_profile: FactionProfile) -> float:
	var base := 11.0
	match action:
		ArcDecisionUtil.ARC_RAID:           base = 10.0
		ArcDecisionUtil.ARC_SABOTAGE:       base = 12.0
		ArcDecisionUtil.ARC_ULTIMATUM:      base = 9.0
		ArcDecisionUtil.ARC_TRUCE_TALKS:    base = 14.0
		ArcDecisionUtil.ARC_REPARATIONS:    base = 16.0
		ArcDecisionUtil.ARC_ALLIANCE_OFFER: base = 18.0
		ArcDecisionUtil.ARC_DECLARE_WAR:    base = 30.0

	var state_mul := 1.0
	match arc_state_name:
		&"WAR":      state_mul = 1.25
		&"CONFLICT": state_mul = 1.10
		&"ALLIANCE": state_mul = 1.10

	var diff_mul := 0.85 + 0.95 * clampf(difficulty, 0.0, 1.0)
	var tier_mul := 1.0 + 0.18 * float(max(tier - 1, 0))

	var expa := giver_profile.get_personality(FactionProfile.PERS_EXPANSIONISM, 0.5)
	var diplo := giver_profile.get_personality(FactionProfile.PERS_DIPLOMACY, 0.5)

	var pers_mul := 1.0
	if ArcStateMachine.is_hostile_action(action):
		pers_mul *= (1.10 - 0.30 * expa)
	if ArcStateMachine.is_peace_action(action):
		pers_mul *= (1.10 - 0.30 * diplo)

	return base * state_mul * diff_mul * tier_mul * pers_mul
```

---

# 3) Comment l’utiliser côté ArcManager

Au lieu d’un `spawn_offer_for_pair()` unique :

```gdscript
var offers := ArcOfferFactory.spawn_offers_for_pair(
	arc_id, pair_arc_state,
	giver_id, ant_id,
	action_type,
	relations[giver_id][ant_id],
	faction_profiles,
	faction_economies,
	budget_mgr,
	_rng, day,
	tier
)

for inst in offers:
	QuestPool.try_add_offer(inst)
```

Et si tu veux garder ton fallback action/tier : tu fais le fallback autour de `spawn_offers_for_pair()` (même principe).

---

Si tu veux, prochaine brique utile : une mini règle “**allowed actions per ArcState**” + “**bundle size** selon état” (ex: en WAR, count_min=2 garanti, en RIVALRY count_max=1) pour maîtriser encore mieux le spam et la lisibilité côté joueur.

Moi:
prochaine brique utile : une mini règle “allowed actions per ArcState” + “bundle size selon état” (ex: en WAR, count_min=2 garanti, en RIVALRY count_max=1) pour maîtriser encore mieux le spam et la lisibilité côté joueur.

ChatGPT:
Voici une brique **simple, très efficace** : une règle `allowed actions per ArcState` + un “scaling” du **bundle size** selon l’état (WAR produit plus d’offres, RIVALRY en produit peu).

---

# 1) Allowed actions par ArcState

## `ArcPolicy.gd`
```gdscript
class_name ArcPolicy
extends RefCounted

# Actions autorisées selon l’état
const ALLOWED_BY_STATE: Dictionary = {
	&"NEUTRAL":  [ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_ULTIMATUM, ArcDecisionUtil.ARC_IGNORE],
	&"RIVALRY":  [ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_SABOTAGE, ArcDecisionUtil.ARC_ULTIMATUM, ArcDecisionUtil.ARC_TRUCE_TALKS, ArcDecisionUtil.ARC_IGNORE],
	&"CONFLICT": [ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_SABOTAGE, ArcDecisionUtil.ARC_ULTIMATUM, ArcDecisionUtil.ARC_DECLARE_WAR, ArcDecisionUtil.ARC_TRUCE_TALKS, ArcDecisionUtil.ARC_IGNORE],
	&"WAR":      [ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_SABOTAGE, ArcDecisionUtil.ARC_DECLARE_WAR, ArcDecisionUtil.ARC_TRUCE_TALKS, ArcDecisionUtil.ARC_IGNORE],
	&"TRUCE":    [ArcDecisionUtil.ARC_TRUCE_TALKS, ArcDecisionUtil.ARC_REPARATIONS, ArcDecisionUtil.ARC_ALLIANCE_OFFER, ArcDecisionUtil.ARC_IGNORE],
	&"ALLIANCE": [ArcDecisionUtil.ARC_ALLIANCE_OFFER, ArcDecisionUtil.ARC_JOINT_OPERATION if ArcDecisionUtil.has(&"ARC_JOINT_OPERATION") else ArcDecisionUtil.ARC_IGNORE, ArcDecisionUtil.ARC_IGNORE],
}

static func filter_action_for_state(state: StringName, proposed: StringName, rng: RandomNumberGenerator) -> StringName:
	var allowed: Array = ALLOWED_BY_STATE.get(state, [])
	if allowed.is_empty():
		return proposed
	if allowed.has(proposed):
		return proposed
	# fallback: pick an allowed non-IGNORE if possible
	var non_ignore: Array = []
	for a in allowed:
		if a != ArcDecisionUtil.ARC_IGNORE:
			non_ignore.append(a)
	if non_ignore.is_empty():
		return ArcDecisionUtil.ARC_IGNORE
	return non_ignore[rng.randi_range(0, non_ignore.size() - 1)]
```

> Note : j’ai laissé un placeholder `ARC_JOINT_OPERATION` si tu ajoutes une action dédiée “coop”.

---

# 2) Bundle size selon état (min/max override)

Au lieu de modifier le catalogue, on applique un **override** au moment du spawn.

## `ArcPolicy.gd` (suite)
```gdscript
# Overrides de bundle selon état (lisibilité + anti-spam)
const BUNDLE_BY_STATE: Dictionary = {
	&"NEUTRAL":  {"count_min": 0, "count_max": 1},  # souvent 0 (pas d’offre) ou 1 incident
	&"RIVALRY":  {"count_min": 1, "count_max": 1},  # lisible : 1 offer max
	&"CONFLICT": {"count_min": 1, "count_max": 2},
	&"WAR":      {"count_min": 2, "count_max": 3},  # WAR => plusieurs fronts
	&"TRUCE":    {"count_min": 1, "count_max": 2},
	&"ALLIANCE": {"count_min": 1, "count_max": 2},
}

static func override_bundle_count(state: StringName, base_bundle: Dictionary, rng: RandomNumberGenerator) -> int:
	var ov: Dictionary = BUNDLE_BY_STATE.get(state, {})
	if ov.is_empty():
		# fallback sur le bundle du catalogue
		var mn := int(base_bundle.get("count_min", 1))
		var mx := int(base_bundle.get("count_max", 1))
		return rng.randi_range(mn, mx)

	var mn2 := int(ov.get("count_min", int(base_bundle.get("count_min", 1))))
	var mx2 := int(ov.get("count_max", int(base_bundle.get("count_max", 1))))
	return rng.randi_range(mn2, mx2)
```

---

# 3) Patch dans `ArcOfferFactory.spawn_offers_for_pair()`

Dans `ArcOfferFactory.gd`, remplace :

```gdscript
var count := _roll_count(bundle, rng)
```

par :

```gdscript
var count := ArcPolicy.override_bundle_count(arc_state.state, bundle, rng)
if count <= 0:
	return []
```

Et avant d’utiliser `action`, filtre-la côté ArcManager (recommandé), ou directement ici.

---

# 4) Patch côté ArcManager (recommandé)

Juste après `select_arc_action_type(...)` :

```gdscript
action_type = ArcPolicy.filter_action_for_state(pair_arc_state.state, action_type, _rng)
if action_type == ArcDecisionUtil.ARC_IGNORE:
	return
```

---

# 5) Résultat (ce que tu gagnes)
- En **RIVALRY**, tu garantis **1 offer max** → le joueur comprend “l’incident du moment”.
- En **WAR**, tu as automatiquement **2–3 offers** → sensation de fronts multiples.
- En **TRUCE**, tu as 1–2 offers max → négociation + “spoiler” ou “logistique”.
- Le tout réduit le spam même si les proba d’incident sont élevées.

Si tu veux, prochaine mini-brique : une règle “**1 seul ARC_PRIMARY visible par paire**” (les secondary existent mais ne sont spawn que si le pool est bas, ou si le joueur a déjà accepté la primary).

Moi:
Le max est part faction? Ou pour toute les faction ?
Si je suis en guerre avec une facttion X et en rivalry avec une faction Y, j'ai 2 actions min contre la faction X et 1 contre la faction Y, donc 3 en tout. Ou j'en ai 2 contre les deux ?

ChatGPT:
Dans la règle que je viens de proposer, le **count_min / count_max est “par paire”** (par arc A↔B), pas global.

Donc dans ton exemple, **si tu as la capacité** :

- en **WAR contre X** → tu *tentes* de produire **2 à 3 offers** liées à X  
- en **RIVALRY contre Y** → tu *tentes* de produire **1 offer** liée à Y  
➡️ donc **3 offers au total** (voire 4 si WAR sort 3)

Mais attention : le “tentes” est important, parce qu’en pratique tu vas presque toujours appliquer des **caps/budgets par faction** (et éventuellement un cap global QuestPool). C’est ça qui répond à “est-ce que c’est 2 contre les deux ?”.

## La bonne réponse design
- **Bundle size = par paire (par état de la paire)**  
- **Capacité = par faction (giver)**  
- et le résultat final = **clamp** par la capacité restante de la faction.

### Concrètement, la faction A a par exemple :
- `max_active_offers` (cap total offers actives en même temps)
- `points` (budget/jour/semaine) + coût points par action
- `gold escrow` (budget financier)
- éventuellement un `max_new_offers_per_day` (cap “rythme”)

Donc A en WAR avec X **ne garantit pas** 2 offers si :
- A a déjà atteint `max_active_offers`,
- ou pas assez de points,
- ou pas assez d’or pour escrow,
- ou quota journalier atteint.

## Comment répartir si plusieurs adversaires
Le plus robuste : tu fais un **budget de “slots” par faction par tick/jour**, et tu les alloues par priorité :

1) Construire la liste des paires actives de A (X en WAR, Y en RIVALRY, etc.)
2) Trier par priorité d’état : `WAR > CONFLICT > TRUCE > RIVALRY > NEUTRAL`
3) Pour chaque paire, calculer `wanted = bundle_count_override(state)` (2..3, 1..1, etc.)
4) `granted = min(wanted, slots_restants, points_restants, gold_possible)`  
5) Spawn `granted` offers, puis passer à la paire suivante.

### Donc ton exemple :
- Si A a assez de slots/points/or → **2 contre X + 1 contre Y = 3**
- Si A est limité (par ex slots_restants = 2) → tu fais **2 contre X** et **0 contre Y** (ou 1/1 selon la stratégie)
  - variante : tu peux forcer “au moins 1 offer par paire active” si tu veux plus de variété, mais c’est un choix.

## Reco “lisibilité joueur”
Je te conseille ce comportement :
- **WAR** prend la priorité (parce que c’est l’arc majeur)
- RIVALRY passe après
- et si tu es à court de budget → RIVALRY peut ne rien produire ce jour-là.

Si tu veux, je te donne un mini code `allocate_offer_slots_for_faction(faction_id, pairs)` qui fait exactement ce clamp + priorité, et branche ça sur `spawn_offers_for_pair()`.

Moi:
Non, explique moi ce que tu voulais dire par :
prochaine mini-brique : une règle “1 seul ARC_PRIMARY visible par paire” (les secondary existent mais ne sont spawn que si le pool est bas, ou si le joueur a déjà accepté la primary)._

ChatGPT:
L’idée “**1 seul ARC_PRIMARY visible par paire**”, c’est une règle de **lisibilité + anti-spam** côté joueur.

### Le problème qu’on évite
Si une paire A↔B en WAR génère 2–3 offers par jour, tu peux te retrouver avec :
- 6 offres “contre la même faction” très similaires,
- et le joueur ne comprend plus “quelle est l’histoire / l’événement principal”.

### La règle proposée
Pour chaque paire `(A,B)` :
- **au maximum 1 offer “ARC_PRIMARY”** dans le pool (visible, prioritaire, narrative).
- les autres offres possibles sont des **ARC_SECONDARY** (variantes), mais :
  - soit tu **ne les génères pas** tant que la primary existe,
  - soit tu les génères seulement dans certains cas (voir ci-dessous).

### Ce que ça change concrètement
- En **RIVALRY**, ça ne change presque rien (tu avais déjà 1 offer max).
- En **WAR**, au lieu de 3 offers simultanées pour la paire, tu as :
  - 1 “événement principal” (primary) visible,
  - puis éventuellement 0–1 secondaires “en renfort” selon les conditions.

### Quand autoriser les SECONDARY
Deux stratégies (tu peux mixer) :

1) **Après acceptation**  
   - Tant que la primary n’est pas acceptée → pas de secondary (ou très peu).
   - Dès que le joueur accepte la primary → tu peux spawn 1 secondary (ex: “front secondaire” pendant la mission principale).

2) **Si le pool est bas** (pression de contenu)  
   - Si `QuestPool.offers.size() < MIN_POOL` (genre 6) → autorise 1 secondary même sans acceptation.
   - Sinon, reste sur primary only.

### Comment l’implémenter simplement
Dans `QuestPool.try_add_offer(inst)` (ou juste avant), tu mets une garde :

- si `inst.context.offer_kind == "ARC_PRIMARY"` :
  - refuser si une autre offer ARC_PRIMARY existe déjà pour `pair_key`
- si `offer_kind == "ARC_SECONDARY"` :
  - refuser si primary existe et que (a) le joueur ne l’a pas acceptée, et (b) pool pas bas

En pratique, tu as besoin d’un index rapide :
- `arc_primary_by_pair[pair_key] = runtime_id`
- `arc_secondary_count_by_pair[pair_key]`

### Pourquoi c’est utile
- Le joueur voit “**le** problème du moment” entre A et B.
- Tu gardes quand même de la variété grâce aux variants secondaires, sans saturer.
- Ça rend tes arcs plus “narratifs” : une primary = un événement marquant.

Si tu veux, je peux te donner un patch précis pour `QuestPool.try_add_offer()` (ou une fonction `ArcOfferVisibilityGate.can_add_offer(inst, quest_pool_state)`).

Moi:
Je pensais que le max_offer (3 pour War) etait une limite pour le nombre d'offre total, pas le nombre d'offre par jour.
Il faut que ce soit le cas.
Par contre, on peut verifier si on peut generé de meilleur quete (cas du fallback action/tiers ou meilleur cible) et remplacer d'ancienne quete moins bien

ChatGPT:
Tu as raison : dans ce design-là, **`count_min/count_max` (ex: WAR=2..3)** doit surtout être compris comme une **limite de “stock” d’offres simultanées** pour une **paire** (A↔B), pas comme “on en recrée 3 par jour”.

On avait décrit “bundle size” au moment du spawn, mais l’intention “anti-spam + lisibilité” est beaucoup meilleure si on l’utilise comme **cap concurrent**.

Et oui : si on détecte qu’on peut générer **une meilleure quête**, on peut **remplacer** une ancienne “moins bonne” (avec une politique anti-churn).

Voici la brique complète (compacte) : **cap par paire + remplacement “upgrade”**.

---

## 1) Interprétation correcte

Pour une paire `(A,B)` :

- `bundle_cap = ArcPolicy.bundle_cap_for_state(arc_state.state)`  
  - RIVALRY → 1 (max 1 offer dans le pool pour cette paire)
  - WAR → 3 (max 3 offers dans le pool pour cette paire)
- Chaque jour / tick, on fait juste :  
  **“si on est sous le cap → on complète”**  
  sinon **rien** (ou “upgrade” opportuniste).

---

## 2) Patch : cap concurrent par paire

### `ArcPolicy.gd` (helper cap)
```gdscript
static func bundle_cap_for_state(state: StringName) -> int:
	var ov: Dictionary = BUNDLE_BY_STATE.get(state, {})
	if ov.is_empty():
		return 1
	return int(ov.get("count_max", 1)) # cap concurrent (on prend le max)
```

### `QuestPool` (ou un util) : récupérer les offers d’une paire
```gdscript
func get_arc_offers_for_pair(pair_key: StringName) -> Array:
	var out: Array = []
	for inst in offers: # à adapter selon ton stockage
		if inst == null: continue
		if not inst.context.get("is_arc_rivalry", false): continue
		if StringName(inst.context.get("pair_key", &"")) != pair_key: continue
		out.append(inst)
	return out
```

---

## 3) Remplacement “upgrade” (meilleure quête remplace moins bonne)

### A) Score “qualité” (simple, stable)
On score une offer avec ce que tu as déjà dans `context["stakes"]` :

```gdscript
static func offer_quality_score(inst: QuestInstance) -> float:
	var stakes: Dictionary = inst.context.get("stakes", {})
	var reward := float(stakes.get("gold", 0))
	var diff := float(stakes.get("difficulty", 0.0)) # 0..1
	var tier := float(inst.template.tier if inst.template != null else 1)
	var deadline := float(inst.context.get("deadline_days", 7))

	# Plus c’est payé / difficile / tier haut => “mieux”
	# deadline court = plus “urgent” (léger bonus)
	var urgency := clampf((10.0 - deadline) / 10.0, 0.0, 1.0)

	return 0.45 * reward + 55.0 * diff + 25.0 * tier + 10.0 * urgency
```

### B) Politique de remplacement
- On ne remplace que si le nouveau est **nettement meilleur** (hystérésis).
- On évite de remplacer trop souvent (cooldown “refresh”) : idéalement stocké dans `ArcNotebook` (par `pair_key`).

```gdscript
static func should_replace(new_score: float, old_score: float, min_improvement_ratio: float = 1.15) -> bool:
	if old_score <= 0.0:
		return true
	return new_score >= old_score * min_improvement_ratio
```

### C) Release / rollback des réservations (or + points)
Comme ton `spawn` réserve déjà, il faut pouvoir rollback si on n’ajoute pas au pool :

```gdscript
static func release_offer_reservations(
	inst: QuestInstance,
	faction_economies: Dictionary,
	budget_mgr: ArcOfferBudgetManager,
	points_refund_ratio: float = 0.80
) -> void:
	var giver_id: StringName = inst.context.get("escrow_faction_id", &"")
	var pair_key: StringName = inst.context.get("pair_key", &"")
	var qid := StringName(inst.runtime_id)

	# gold escrow
	var econ: FactionEconomy = faction_economies.get(giver_id, null)
	if econ != null:
		econ.release_reservation(qid)

	# points escrow
	var bud := budget_mgr.get_budget(giver_id)
	bud.release_offer(qid, pair_key, points_refund_ratio)
```

---

## 4) Fonction “ensure cap + upgrade” (ArcManager)

C’est la fonction que tu appelles quand tu as décidé `(giver, antagonist, action)`.

```gdscript
func _ensure_arc_offers_for_pair(
	quest_pool,
	arc_id: StringName,
	arc_state: ArcState,
	giver_id: StringName,
	ant_id: StringName,
	action: StringName,
	rel_ab: FactionRelationScore,
	faction_profiles: Dictionary,
	faction_economies: Dictionary,
	budget_mgr: ArcOfferBudgetManager,
	rng: RandomNumberGenerator,
	day: int,
	tier: int,
	params: Dictionary = {}
) -> void:
	var pair_key := StringName(insta_pair_key(giver_id, ant_id)) # ou ArcOfferFactory._pair_key()

	var cap := ArcPolicy.bundle_cap_for_state(arc_state.state)
	var existing: Array = quest_pool.get_arc_offers_for_pair(pair_key)

	# (Optionnel) si l’état a changé, tu peux virer celles qui ne matchent plus
	# existing = existing.filter(func(i): return StringName(i.context.get("arc_state",&"")) == arc_state.state)

	# 1) Compléter si sous cap
	if existing.size() < cap:
		var offers := ArcOfferFactory.spawn_offers_for_pair(
			arc_id, arc_state,
			giver_id, ant_id,
			action,
			rel_ab,
			faction_profiles,
			faction_economies,
			budget_mgr,
			rng, day,
			tier
		)
		for inst in offers:
			# stop dès qu’on atteint le cap
			if existing.size() >= cap:
				release_offer_reservations(inst, faction_economies, budget_mgr)
				continue
			if quest_pool.try_add_offer(inst):
				existing.append(inst)
			else:
				release_offer_reservations(inst, faction_economies, budget_mgr)
		return

	# 2) Sinon : tentative d’upgrade (1 seule tentative max / jour / paire conseillé)
	# Génère 1 candidat, et remplace le pire si nettement meilleur
	var candidate_list := ArcOfferFactory.spawn_offers_for_pair(
		arc_id, arc_state,
		giver_id, ant_id,
		action,
		rel_ab,
		faction_profiles,
		faction_economies,
		budget_mgr,
		rng, day,
		tier,
		{"count_min": 1, "count_max": 1} # si tu veux forcer 1 candidat
	)
	if candidate_list.is_empty():
		return
	var cand: QuestInstance = candidate_list[0]

	var cand_score := offer_quality_score(cand)

	var worst := existing[0]
	var worst_score := offer_quality_score(worst)
	for e in existing:
		var s := offer_quality_score(e)
		if s < worst_score:
			worst = e
			worst_score = s

	if should_replace(cand_score, worst_score, 1.15):
		# retirer worst du pool + libérer ses réservations
		quest_pool.remove_offer_by_id(StringName(worst.runtime_id))
		release_offer_reservations(worst, faction_economies, budget_mgr)

		# ajouter candidate (déjà réservée)
		if not quest_pool.try_add_offer(cand):
			# si add échoue, rollback candidate
			release_offer_reservations(cand, faction_economies, budget_mgr)
	else:
		# candidate rejetée => rollback
		release_offer_reservations(cand, faction_economies, budget_mgr)
```

> Notes :
> - `insta_pair_key()` = ta façon de calculer `pair_key` (ou réutilise celle de `ArcOfferFactory`).
> - `QuestPool.remove_offer_by_id()` est à adapter (ou remove direct dans ta liste).
> - J’ai volontairement limité l’upgrade à **1 candidat** pour éviter le churn.

---

## 5) “Meilleure cible” (POI) sans tout recoder
Dans `ArcOfferFactory._pick_target_poi(...)`, au lieu de prendre “un POI random”, tu peux :
- tirer `N` candidats (ex: 5),
- scorer (distance frontière, valeur stratégique, proximité du giver, etc.),
- garder le meilleur.

Interface simple :
```gdscript
# POIManagerRunner.score_poi_for_arc(action, giver_id, ant_id, poi_dict) -> float
```

---

### En résumé
- Oui : `WAR=3` doit être **cap total simultané** pour la paire, pas “par jour”.
- Et oui : on peut **remplacer** une vieille offer par une meilleure, avec :
  - un score de qualité,
  - un seuil d’amélioration (hystérésis),
  - un cooldown anti-churn (facile à ajouter via ArcNotebook).

Si tu veux, je te propose le micro-ajout “cooldown refresh par pair” dans `ArcNotebook` (genre pas plus d’un upgrade tous les 5 jours) — c’est vraiment le petit détail qui rend le système très stable côté joueur.

Moi:
Ok 
propose le micro-ajout “cooldown refresh par pair” dans ArcNotebook (genre pas plus d’un upgrade tous les 5 jours) — c’est vraiment le petit détail qui rend le système très stable côté joueur.

ChatGPT:
Voici un **micro-ajout** simple dans `ArcNotebook` pour limiter les “upgrades/remplacements” à **1 toutes les N journées par paire**.

---

## 1) Ajout dans `ArcNotebook`

### A) Données (par paire)
```gdscript
# ArcNotebook.gd
class_name ArcNotebook
extends RefCounted

var last_offer_refresh_day_by_pair: Dictionary[StringName, int] = {} # pair_key -> last_day

func can_refresh_offer_for_pair(pair_key: StringName, day: int, cooldown_days: int = 5) -> bool:
	var last := int(last_offer_refresh_day_by_pair.get(pair_key, -999999))
	return (day - last) >= cooldown_days

func mark_offer_refreshed_for_pair(pair_key: StringName, day: int) -> void:
	last_offer_refresh_day_by_pair[pair_key] = day
```

> Tu peux aussi le ranger dans ton `ArcHistory` par faction si tu préfères, mais au niveau notebook global c’est parfait.

---

## 2) Utilisation dans ton “upgrade logic”

Dans la fonction `_ensure_arc_offers_for_pair(...)`, juste avant de tenter l’upgrade (quand `existing.size() >= cap`) :

```gdscript
if not arc_notebook.can_refresh_offer_for_pair(pair_key, day, 5):
	return
```

Et **uniquement si tu fais un remplacement effectif** (ou si tu veux limiter même les tentatives, à toi de voir) :

```gdscript
if should_replace(...):
	# ... remove worst, add candidate ...
	arc_notebook.mark_offer_refreshed_for_pair(pair_key, day)
```

### Variante recommandée
- Marquer le refresh **seulement si remplacement réel** ⇒ plus permissif.
- Si tu veux encore moins de churn CPU, tu peux marquer dès la **tentative** (même si pas remplacé), mais c’est plus “dur”.

---

## 3) Bonus (optionnel) : cooldown différent par état
Ex:
- RIVALRY : 7 jours (ça bouge peu)
- WAR : 3 jours (fronts qui évoluent)

```gdscript
func refresh_cooldown_for_state(state: StringName) -> int:
	match state:
		&"WAR": return 3
		&"CONFLICT": return 4
		&"RIVALRY": return 7
		&"TRUCE": return 6
		&"ALLIANCE": return 8
		_: return 5
```

Puis :
```gdscript
var cd := refresh_cooldown_for_state(arc_state.state)
if not arc_notebook.can_refresh_offer_for_pair(pair_key, day, cd):
	return
```

---

Si tu veux, je te propose aussi un mini champ “refresh_attempts_by_pair” pour debug/metrics, mais fonctionnellement, les 2 méthodes ci-dessus suffisent.

Moi:
propose aussi un mini champ “refresh_attempts_by_pair” pour debug/metrics, mais fonctionnellement, les 2 méthodes ci-dessus suffisent.
Et prevoit des test pour couvrir ce qu'on a fait depuis le dernier tests

ChatGPT:
Voilà le **micro-ajout** demandé + une proposition de **tests Godot** qui couvre ce qu’on a ajouté depuis les derniers tests (policy/caps, cooldown refresh, budget points/caps, et un test “fallback action/tier” fiable via stub).

---

## 1) Micro-ajout dans `ArcNotebook`

Ajoute un compteur par paire :

```gdscript
# ArcNotebook.gd
class_name ArcNotebook
extends RefCounted

var last_offer_refresh_day_by_pair: Dictionary[StringName, int] = {}   # pair_key -> last successful refresh day
var refresh_attempts_by_pair: Dictionary[StringName, int] = {}         # pair_key -> count (debug/metrics)

func can_refresh_offer_for_pair(pair_key: StringName, day: int, cooldown_days: int = 5) -> bool:
	var last := int(last_offer_refresh_day_by_pair.get(pair_key, -999999))
	return (day - last) >= cooldown_days

func mark_offer_refreshed_for_pair(pair_key: StringName, day: int) -> void:
	last_offer_refresh_day_by_pair[pair_key] = day

func mark_refresh_attempt_for_pair(pair_key: StringName) -> int:
	var n := int(refresh_attempts_by_pair.get(pair_key, 0)) + 1
	refresh_attempts_by_pair[pair_key] = n
	return n
```

### Où l’utiliser
Dans ton code “upgrade” (quand `existing.size() >= cap` et que `can_refresh == true`) :

- juste avant de générer un candidat : `arc_notebook.mark_refresh_attempt_for_pair(pair_key)`
- si remplacement effectif : `arc_notebook.mark_offer_refreshed_for_pair(pair_key, day)`

---

## 2) Tests (depuis les dernières briques)

Je te propose un nouveau fichier de test autonome (même style que ton harness) :

### `tests/ArcGovernanceTest.gd`

```gdscript
extends Node
class_name ArcGovernanceTest

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 12345

	_test_notebook_refresh_cooldown_and_attempts()
	_test_policy_allowed_actions_and_caps()
	_test_budget_points_caps()
	_test_tick_day_for_pair_stability_counters()
	_test_fallback_action_tier_with_stub()

	print("\n✅ ArcGovernanceTest: OK\n")
	get_tree().quit()


# -------------------------
# 1) ArcNotebook cooldown + attempts
# -------------------------
func _test_notebook_refresh_cooldown_and_attempts() -> void:
	var nb := ArcNotebook.new()
	var pair := &"a|b"

	_assert(nb.can_refresh_offer_for_pair(pair, 10, 5), "should refresh at day 10")
	_assert(nb.mark_refresh_attempt_for_pair(pair) == 1, "attempts should be 1")
	nb.mark_offer_refreshed_for_pair(pair, 10)

	_assert(not nb.can_refresh_offer_for_pair(pair, 14, 5), "should NOT refresh at day 14 (cooldown=5)")
	_assert(nb.can_refresh_offer_for_pair(pair, 15, 5), "should refresh at day 15")

	_assert(nb.mark_refresh_attempt_for_pair(pair) == 2, "attempts should be 2")


# -------------------------
# 2) ArcPolicy allowed actions + bundle cap (concurrent cap)
# -------------------------
func _test_policy_allowed_actions_and_caps() -> void:
	_assert(ArcPolicy.bundle_cap_for_state(&"RIVALRY") == 1, "RIVALRY cap should be 1")
	_assert(ArcPolicy.bundle_cap_for_state(&"WAR") == 3, "WAR cap should be 3")

	var proposed := ArcDecisionUtil.ARC_ALLIANCE_OFFER
	var filtered := ArcPolicy.filter_action_for_state(&"WAR", proposed, rng)

	var allowed: Array = ArcPolicy.ALLOWED_BY_STATE[&"WAR"]
	_assert(allowed.has(filtered), "filtered action must be allowed in WAR")


# -------------------------
# 3) FactionOfferBudget caps (global + per pair) + points reserve/release
# -------------------------
func _test_budget_points_caps() -> void:
	var b := FactionOfferBudget.new(&"A")
	b.points_per_week = 70
	b.points = 20
	b.max_active_offers = 2
	b.max_active_offers_per_pair = 1

	var p1 := &"a|x"
	var p2 := &"a|y"

	_assert(b.reserve_for_offer(&"q1", p1, 10.0), "reserve q1 should succeed")
	_assert(not b.reserve_for_offer(&"q2", p1, 5.0), "reserve q2 should fail (per-pair cap)")

	_assert(b.reserve_for_offer(&"q2", p2, 10.0), "reserve q2 should succeed on other pair")
	_assert(not b.reserve_for_offer(&"q3", p2, 1.0), "reserve q3 should fail (max_active_offers=2)")

	# release with refund (listing fee)
	var before := b.points
	b.release_offer(&"q1", p1, 0.80)
	_assert(b.active_offer_ids.size() == 1, "one active offer should remain after release")
	_assert(b.points > before, "refund should increase points")


# -------------------------
# 4) tick_day_for_pair stability counters
# -------------------------
func _test_tick_day_for_pair_stability_counters() -> void:
	var arc_state := ArcState.new()
	arc_state.stable_low_tension_days = 0
	arc_state.stable_high_trust_days = 0

	var ab := FactionRelationScore.new()
	var ba := FactionRelationScore.new()

	# Low tension + high trust
	ab.tension = 10; ba.tension = 12
	ab.relation = 40; ba.relation = 38
	ab.trust = 60; ba.trust = 58

	for i in range(7):
		ArcStateMachine.tick_day_for_pair(arc_state, ab, ba)

	_assert(arc_state.stable_low_tension_days == 7, "stable_low_tension_days should count up")
	_assert(arc_state.stable_high_trust_days == 7, "stable_high_trust_days should count up")

	# Break condition
	ab.tension = 60; ba.tension = 60
	ArcStateMachine.tick_day_for_pair(arc_state, ab, ba)
	_assert(arc_state.stable_low_tension_days == 0, "stable_low_tension_days should reset when tension high")


# -------------------------
# 5) Fallback action/tier (test fiable via stub spawn callable)
# -------------------------
# Pour tester sans dépendre du hasard/POI, on utilise un stub spawn.
#
# ⚠️ Reco mini-changement: ajoute un param optionnel spawn_fn: Callable
# à ta fonction _try_spawn_offer_with_fallback_and_tier() (sinon copie la logique ici).
func _test_fallback_action_tier_with_stub() -> void:
	var arc_id := &"arc_test"
	var st := ArcState.new()
	st.a_id = &"A"; st.b_id = &"B"; st.state = &"WAR"

	# stub: échoue si tier > 1, réussit seulement pour action RAID au tier 1
	var spawn_fn := func(action: StringName, t: int) -> QuestInstance:
		if action != ArcDecisionUtil.ARC_RAID:
			return null
		if t != 1:
			return null
		var qt := QuestTemplate.new()
		qt.tier = t
		var ctx := {"is_arc_rivalry": true, "arc_action_type": action, "stakes": {"gold": 50, "difficulty": 0.3}, "deadline_days": 7}
		return QuestInstance.new(qt, ctx)

	# On simule une chaîne: DECLARE_WAR -> ULTIMATUM -> RAID
	var initial_action := ArcDecisionUtil.ARC_DECLARE_WAR
	var tier := 3

	# Cette fonction de test reproduit EXACTEMENT ta logique de fallback,
	# mais en utilisant spawn_fn(action,tier) au lieu d’ArcOfferFactory.
	var inst := _fallback_with_injected_spawn(initial_action, tier, 1, 2, 2, spawn_fn)
	_assert(inst != null, "fallback should eventually succeed via RAID tier 1")
	_assert(StringName(inst.context["arc_action_type"]) == ArcDecisionUtil.ARC_RAID, "action should downgrade to RAID")
	_assert(int(inst.template.tier) == 1, "tier should downgrade to 1")


func _fallback_with_injected_spawn(
	initial_action: StringName,
	tier: int,
	min_tier: int,
	max_action_degrades: int,
	max_tier_degrades: int,
	spawn_fn: Callable
) -> QuestInstance:
	var chain := _fallback_chain_for(initial_action)
	var max_actions := min(chain.size(), 1 + max_action_degrades)

	for ai in range(max_actions):
		var action: StringName = chain[ai]
		if action == ArcDecisionUtil.ARC_IGNORE:
			return null

		var tries := 1 + max_tier_degrades
		for k in range(tries):
			var t := tier - k
			if t < min_tier:
				break
			var inst: QuestInstance = spawn_fn.call(action, t)
			if inst != null:
				inst.context["arc_action_type"] = action
				inst.context["arc_action_type_initial"] = initial_action
				inst.context["arc_tier_initial"] = tier
				inst.context["arc_tier_final"] = t
				inst.context["arc_fallback_action_steps"] = ai
				inst.context["arc_fallback_tier_steps"] = k
				return inst
	return null


func _fallback_chain_for(action: StringName) -> Array[StringName]:
	match action:
		ArcDecisionUtil.ARC_DECLARE_WAR:
			return [ArcDecisionUtil.ARC_DECLARE_WAR, ArcDecisionUtil.ARC_ULTIMATUM, ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_IGNORE]
		ArcDecisionUtil.ARC_SABOTAGE:
			return [ArcDecisionUtil.ARC_SABOTAGE, ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_IGNORE]
		ArcDecisionUtil.ARC_ULTIMATUM:
			return [ArcDecisionUtil.ARC_ULTIMATUM, ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_IGNORE]
		_:
			return [action, ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_IGNORE]


# -------------------------
# Assert helper
# -------------------------
func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

### Ce que ces tests couvrent réellement
- **ArcNotebook** : cooldown + métriques “attempts”
- **ArcPolicy** : allowed actions + “cap concurrent” (WAR=3, RIVALRY=1)
- **FactionOfferBudget** : cap global/per-pair + refund partiel
- **tick_day_for_pair** : stabilité “pendant Y jours”
- **fallback action/tier** : test fiable (sans RNG/POI) via stub

---

Si tu veux que le test 5 utilise *ta* fonction réelle (au lieu du helper injecté), je te donne un micro-patch “optionnel” (ajouter `spawn_fn: Callable = Callable()` à `_try_spawn_offer_with_fallback_and_tier`) pour rendre la fonction testable sans changer son comportement en prod.

Moi:
Je veux que le test 5 utilise ta fonction réelle (au lieu du helper injecté), donne un micro-patch “optionnel” (ajouter spawn_fn: Callable = Callable() à _try_spawn_offer_with_fallback_and_tier) pour rendre la fonction testable sans changer son comportement en prod.

ChatGPT:
Voici le **micro-patch optionnel** pour rendre ta fonction réelle testable **sans changer le comportement en prod**.

L’idée : ajouter un paramètre `spawn_fn: Callable = Callable()` ;  
- si `spawn_fn.is_valid()` ⇒ on l’utilise (tests)  
- sinon ⇒ comportement normal (prod) en appelant `ArcOfferFactory.spawn_offer_for_pair(...)`.

---

## 1) Patch de la fonction réelle

Remplace ta fonction par celle-ci (même signature + `spawn_fn` en plus) :

```gdscript
func _try_spawn_offer_with_fallback_and_tier(
	arc_id: StringName,
	arc_state: ArcState,
	giver_id: StringName,
	ant_id: StringName,
	initial_action: StringName,
	rel_ab: FactionRelationScore,
	faction_profiles: Dictionary,
	faction_economies: Dictionary,
	budget_mgr: ArcOfferBudgetManager,
	rng: RandomNumberGenerator,
	day: int,
	tier: int,
	min_tier: int = 1,
	max_action_degrades: int = 2,
	max_tier_degrades: int = 1,
	spawn_fn: Callable = Callable()  # <-- NEW (optional)
) -> QuestInstance:
	var chain := _fallback_chain_for(initial_action)

	# Limite action: on prend 1 + max_action_degrades éléments max
	var max_actions := min(chain.size(), 1 + max_action_degrades)

	for ai in range(max_actions):
		var action: StringName = chain[ai]
		if action == ArcDecisionUtil.ARC_IGNORE:
			return null

		# essais de tier: tier, tier-1, ... limité par max_tier_degrades et min_tier
		var tries := 1 + max_tier_degrades
		for k in range(tries):
			var t := tier - k
			if t < min_tier:
				break

			var inst: QuestInstance = null

			# --- NEW: injectable spawn for tests ---
			if spawn_fn.is_valid():
				# Convention: spawn_fn(action: StringName, tier: int) -> QuestInstance
				inst = spawn_fn.call(action, t)
			else:
				inst = ArcOfferFactory.spawn_offer_for_pair(
					arc_id, arc_state,
					giver_id, ant_id,
					action,
					rel_ab,
					faction_profiles,
					faction_economies,
					budget_mgr,
					rng,
					day,
					t
				)

			if inst != null:
				inst.context["arc_action_type"] = action
				inst.context["arc_action_type_initial"] = initial_action
				inst.context["arc_tier_initial"] = tier
				inst.context["arc_tier_final"] = t
				inst.context["arc_fallback_action_steps"] = ai
				inst.context["arc_fallback_tier_steps"] = k
				return inst

	return null
```

✅ En prod : tu n’envoies pas `spawn_fn` ⇒ ça appelle exactement `ArcOfferFactory.spawn_offer_for_pair` comme avant.  
✅ En test : tu passes un `Callable` stub ⇒ contrôle total.

---

## 2) Patch du Test 5 (utilise la fonction réelle)

Dans ton test, remplace le helper injecté par un appel direct :

```gdscript
func _test_fallback_action_tier_with_stub_real_function() -> void:
	var arc_id := &"arc_test"
	var st := ArcState.new()
	st.a_id = &"A"; st.b_id = &"B"; st.state = &"WAR"

	# stub: échoue si tier > 1, réussit seulement pour action RAID au tier 1
	var spawn_fn := func(action: StringName, t: int) -> QuestInstance:
		if action != ArcDecisionUtil.ARC_RAID:
			return null
		if t != 1:
			return null
		var qt := QuestTemplate.new()
		qt.tier = t
		var ctx := {"is_arc_rivalry": true, "arc_action_type": action, "stakes": {"gold": 50, "difficulty": 0.3}, "deadline_days": 7}
		return QuestInstance.new(qt, ctx)

	var inst := _try_spawn_offer_with_fallback_and_tier(
		arc_id, st,
		&"A", &"B",
		ArcDecisionUtil.ARC_DECLARE_WAR,
		FactionRelationScore.new(),
		{}, {}, ArcOfferBudgetManager.new(),
		rng, 1,
		3,     # tier initial
		1,     # min_tier
		2,     # max_action_degrades
		2,     # max_tier_degrades
		spawn_fn
	)

	_assert(inst != null, "fallback should succeed via stub")
	_assert(StringName(inst.context["arc_action_type"]) == ArcDecisionUtil.ARC_RAID, "action should downgrade to RAID")
	_assert(int(inst.template.tier) == 1, "tier should downgrade to 1")
```

(Le reste de ton test file ne change pas.)

---

Si tu veux, je peux aussi te proposer une convention de stub un peu plus riche (avec `giver_id/ant_id/day`), mais ce patch-là est le minimum efficace et ne touche pas ton comportement prod.

Moi:
Non, on fait :
5) Une boucle “monde” cohérente (pas seulement ArcManager)
Les arcs ne doivent pas être l’unique moteur :
• les goals (FactionGoalPlanner) doivent influencer opportunity, external_threat, priority targets,
• et inversement les arcs doivent modifier les goals (en guerre, les objectifs changent).
Sinon, tu auras des arcs “hors-sol”.

ChatGPT:
Oui — là, on passe du “moteur d’arcs” à une **boucle monde** où :

- les **Goals** pilotent *qui* on cible et *pourquoi* (opportunity / external_threat / priority targets),
- les **Arcs** réécrivent la stratégie (en WAR tu ne continues pas tranquillement un goal “build market”…).

Je te propose une intégration **minimale mais structurante**, sans tout refaire : on ajoute un **FactionWorldContext** (snapshot stratégique par faction) + 2 hooks bidirectionnels.

---

# 1) Nouvelle brique : `FactionWorldContext` (snapshot journalier)

### Objectif
Donner au `FactionGoalPlanner` des signaux stables, et permettre aux arcs de **modifier** la planification.

```gdscript
# FactionWorldContext.gd
class_name FactionWorldContext
extends RefCounted

var day: int
var faction_id: StringName

# signaux “stratégiques”
var war_pressure: float = 0.0           # 0..1 (part de paires en WAR/CONFLICT)
var external_threat: float = 0.0        # 0..1 (menace globale)
var opportunity: float = 0.0            # 0..1 (fenêtres d’opportunité)
var fatigue: float = 0.0                # 0..1 (ex: weariness agrégée)

# priorités/targets calculés
var priority_targets: Array[StringName] = []
var target_scores: Dictionary[StringName, float] = {} # faction_id -> score

# vue arcs
var arcs: Array[Dictionary] = [] # each: {other_id, pair_key, state, rel_mean, tension_mean, griev_mean, wear_mean}
```

---

# 2) Hook A : Les Goals influencent les arcs (targets / posture / opportunités)

### Idée
Ton `FactionGoalPlanner` ne renvoie pas juste “une action”.  
Il renvoie une **intent** qui dit : *quel adversaire / quel style / quelle priorité*.

Ex :
- goal “expand territory” → cible préférée = voisin faible (opportunity)
- goal “survive” → posture = défensive (truce/reparations)
- goal “crush rival” → posture agressive (raid/sabotage/declare_war)

**Mini interface** (sans casser ton existant) :

```gdscript
# dans FactionGoalPlanner (ou un wrapper)
func plan_action(goal, ctx: FactionWorldContext) -> Dictionary:
	# return { "type": "ARC"|"WORLD", "target": faction_id, "posture": "...", "weight": float, ... }
```

Puis ArcManager consomme ça :
- si `type=="ARC"` : il restreint `allowed actions` et choisit l’action + spawn offers
- sinon : action monde (build, recruit, scout, etc.)

---

# 3) Hook B : Les Arcs modifient les Goals (override / replan / budget split)

### Idée
Quand une paire passe en `WAR` ou `TRUCE`, tu **ne laisses pas** un goal “peaceful” inchangé.

Tu ajoutes un hook dans ton `FactionGoalManagerRunner` :

```gdscript
func apply_arc_modifiers(faction_id: StringName, ctx: FactionWorldContext) -> void:
	# Peut: (1) forcer un goal d’urgence, (2) injecter un step, (3) modifier les poids
```

### Règle simple (MVP efficace)
Ordre de priorité :
1) **Survival/Emergency** si `external_threat` ou `war_pressure` élevé  
2) **War goals** si une paire est en `WAR`  
3) **Conflict goals** si `CONFLICT`  
4) sinon goal normal (économie/expansion/culture…)

Ex de “goal override” :
- WAR avec X → goal devient `DEFEND_OR_CONQUER(target=X)`
- TRUCE avec X → goal devient `NEGOTIATE_STABILITY(target=X)` pendant N jours
- ALLIANCE avec X → goal “JOINT_OP(target_third_party)” si menace externe

---

# 4) Calculs concrets (opportunity / external_threat / priority targets)

### A) Extraire une “arc view” depuis ArcManager
Tu ajoutes à ArcManager un helper :

```gdscript
func get_arc_view_for_faction(faction_id: StringName) -> Array[Dictionary]:
	# retourne la liste des relations actives + états
	# {other_id, pair_key, state, rel_mean, tension_mean, griev_mean, wear_mean}
	return []
```

### B) Construire `FactionWorldContext` chaque jour (dans WorldSim)
Pseudo-code :

```gdscript
func build_context_for_faction(fid: StringName, day: int) -> FactionWorldContext:
	var ctx := FactionWorldContext.new()
	ctx.day = day
	ctx.faction_id = fid

	ctx.arcs = ArcManagerRunner.get_arc_view_for_faction(fid)

	# war_pressure / fatigue
	var war_pairs := 0
	var fatigue_acc := 0.0
	for a in ctx.arcs:
		var st: StringName = a["state"]
		if st == &"WAR" or st == &"CONFLICT":
			war_pairs += 1
		fatigue_acc += float(a.get("wear_mean", 0.0)) / 100.0
	ctx.war_pressure = clampf(float(war_pairs) / max(1.0, float(ctx.arcs.size())), 0.0, 1.0)
	ctx.fatigue = clampf(fatigue_acc / max(1.0, float(ctx.arcs.size())), 0.0, 1.0)

	# target scoring (menace/opportunité)
	for a in ctx.arcs:
		var other := StringName(a["other_id"])
		var rel := float(a.get("rel_mean", 0.0))
		var tens := float(a.get("tension_mean", 0.0))
		var griev := float(a.get("griev_mean", 0.0))
		var wear := float(a.get("wear_mean", 0.0))

		# menace: relation négative + tension + grievance (usure réduit la capacité)
		var threat := clampf(max(0.0, -rel) / 100.0, 0.0, 1.0) * (tens/100.0) * (0.6 + 0.4*(griev/100.0)) * (1.0 - 0.5*(wear/100.0))

		# opportunité: relation très basse ET wear adverse (si tu l’as) / ou tension haute + rel très basse
		var opp := clampf((tens/100.0) * max(0.0, (-rel - 30.0)/70.0), 0.0, 1.0)

		ctx.target_scores[other] = threat + 0.6 * opp
	ctx.priority_targets = _top_targets(ctx.target_scores, 3)

	# external_threat = max ou moyenne des menaces
	ctx.external_threat = _aggregate_threat(ctx.target_scores)

	return ctx
```

( `_top_targets` et `_aggregate_threat` sont triviales.)

---

# 5) Boucle monde cohérente (ordre d’exécution recommandé)

Dans ton `WorldSim.tick_day()` :

1) **ArcManager tick** (stabilité + transitions)
- pour chaque paire : `tick_day_for_pair()` + éventuelle transition via `update_arc_state()` si events
2) **Construire contexts** pour chaque faction
3) **Goal system** :
- `FactionGoalManagerRunner.ensure_goal(fid, ctx)` (signature enrichie)
- `FactionGoalManagerRunner.apply_arc_modifiers(fid, ctx)`
- `action_intent = FactionGoalPlanner.plan_action(goal, ctx)`
4) **Exécuter l’intent** :
- si intent ARC : `ArcManagerRunner.spawn_offers_from_intent(fid, intent, ctx)`
- sinon : action monde normale (build, scout, recruit…)
5) **QuestPool** : caps/expiration/cleanup

Ça rend les arcs **ancrés** : ils ne sortent plus “de nulle part”, ils deviennent une conséquence de la stratégie et des pressions.

---

# 6) Le minimum à coder maintenant (sans refactor massif)

### À ajouter
- `FactionWorldContext` + `build_context_for_faction()`
- `ArcManager.get_arc_view_for_faction()`
- `FactionGoalManagerRunner.apply_arc_modifiers()`
- `FactionGoalPlanner.plan_action(goal, ctx)` qui peut rester très simple au début (même juste “si WAR→ARC sinon WORLD”)

### Ce que ça débloque immédiatement
- Pas d’arcs “hors-sol”
- Les goals changent quand la diplomatie/guerre change
- Les targets deviennent cohérents (priority_targets)

---

Si tu veux, prochaine étape logique : je te donne un **MVP concret** de `apply_arc_modifiers()` (10–30 lignes) avec 3 goals d’urgence (WAR/CONFLICT/TRUCE) + comment “revenir” au goal précédent après N jours (via un petit stack ou un `suspended_goal`).

Moi:
donne un MVP concret de apply_arc_modifiers() (10–30 lignes) avec 3 goals d’urgence (WAR/CONFLICT/TRUCE) + comment “revenir” au goal précédent après N jours (via un petit stack ou un suspended_goal).

ChatGPT:
Voici un MVP **concret** (court, robuste) pour `apply_arc_modifiers()` avec 3 goals d’urgence **WAR / CONFLICT / TRUCE** + retour au goal précédent via `suspended_goal`.

## Hypothèses minimales
- Tu as un stockage par faction du goal courant, ex: `goals_by_faction[fid]`.
- Un goal est un `Dictionary` (ou une classe) avec au moins `id`, et éventuellement `target_faction_id`.
- Tu peux créer un goal via `GoalFactory.make_goal(goal_id, data)` (à adapter).

---

## 1) Données à ajouter au goal courant
Dans le goal courant (Dictionary), on va stocker :
- `suspended_goal` : l’ancien goal sauvegardé
- `override_until_day` : jour de fin de l’override

---

## 2) MVP `apply_arc_modifiers()`

```gdscript
func apply_arc_modifiers(faction_id: StringName, ctx: FactionWorldContext) -> void:
	var goal: Dictionary = goals_by_faction.get(faction_id, {})
	if goal.is_empty():
		return

	# 1) Si on est dans un override et qu’il est terminé => restore
	var until := int(goal.get("override_until_day", -1))
	if until >= 0 and ctx.day >= until:
		if goal.has("suspended_goal"):
			goals_by_faction[faction_id] = goal["suspended_goal"]
		return

	# 2) Déterminer l’urgence dominante (WAR > CONFLICT > TRUCE) sur la meilleure cible
	var best_target: StringName = &""
	var best_state: StringName = &"NEUTRAL"
	for a in ctx.arcs:
		var st: StringName = a.get("state", &"NEUTRAL")
		if st == &"WAR":
			best_state = &"WAR"
			best_target = StringName(a.get("other_id", &""))
			break
		elif st == &"CONFLICT" and best_state != &"WAR":
			best_state = &"CONFLICT"
			best_target = StringName(a.get("other_id", &""))
		elif st == &"TRUCE" and best_state == &"NEUTRAL":
			best_state = &"TRUCE"
			best_target = StringName(a.get("other_id", &""))

	if best_state == &"NEUTRAL" or best_target == &"":
		return

	# 3) Si déjà sur le bon goal d’urgence => rien
	var gid := String(goal.get("id", ""))
	if (best_state == &"WAR" and gid == "GOAL_WAR") \
	or (best_state == &"CONFLICT" and gid == "GOAL_CONFLICT") \
	or (best_state == &"TRUCE" and gid == "GOAL_TRUCE"):
		return

	# 4) Appliquer override: sauvegarder l’ancien goal + poser une durée (N jours)
	var duration := 0
	match best_state:
		&"WAR":      duration = 14
		&"CONFLICT": duration = 8
		&"TRUCE":    duration = 6

	var new_goal := {}
	match best_state:
		&"WAR":
			new_goal = {"id":"GOAL_WAR", "target_faction_id": best_target, "mode":"total_war"}
		&"CONFLICT":
			new_goal = {"id":"GOAL_CONFLICT", "target_faction_id": best_target, "mode":"pressure"}
		&"TRUCE":
			new_goal = {"id":"GOAL_TRUCE", "target_faction_id": best_target, "mode":"stabilize"}

	new_goal["suspended_goal"] = goal
	new_goal["override_until_day"] = ctx.day + duration

	goals_by_faction[faction_id] = new_goal
```

---

## 3) Comment ça “revient” au goal précédent
- Quand `ctx.day >= override_until_day`, on restore `suspended_goal`.
- Donc le goal normal reprend automatiquement **sans état global compliqué**.

### Variante “stack” (si tu veux plusieurs overrides imbriqués)
Pour l’instant, ce MVP garde **un seul niveau** (suffisant et stable).  
Si tu veux un stack plus tard :
- `suspended_goals: Array[Dictionary]`
- push l’ancien à chaque override, pop à la fin.

---

## 4) Bonus (facultatif mais utile)
Si tu veux empêcher qu’un override remplace un override trop souvent :
- mets un `goal_override_lock_until_day` dans `goals_by_faction[fid]` ou dans `ArcNotebook`,
- et n’override que si `ctx.day >= lock_until`.

---

Si tu veux, prochaine brique logique : un `plan_action(goal, ctx)` MVP correspondant (WAR→générer offers WAR, TRUCE→offers trêve, etc.) pour boucler proprement le triangle **Goals ↔ Arcs ↔ QuestPool**.

Moi:
prochaine brique logique : un plan_action(goal, ctx) MVP correspondant (WAR→générer offers WAR, TRUCE→offers trêve, etc.) pour boucler proprement le triangle Goals ↔ Arcs ↔ QuestPool.

ChatGPT:
Voici un MVP **plan_action(goal, ctx)** qui ferme proprement la boucle **Goals → Arcs → QuestPool** sans refactor lourd.

L’idée : `plan_action()` retourne une **intent** simple :
- soit `type="ARC"` (demande à ArcManager de générer des offers contre une cible),
- soit `type="WORLD"` (action monde non-arc),
- soit `type="NONE"`.

---

## 1) `FactionGoalPlanner.plan_action(goal, ctx)` (MVP)

```gdscript
# FactionGoalPlanner.gd (ou un util)
func plan_action(goal: Dictionary, ctx: FactionWorldContext, rng: RandomNumberGenerator) -> Dictionary:
	var gid := String(goal.get("id", ""))
	var target: StringName = StringName(goal.get("target_faction_id", &""))

	# fallback: si le goal n’a pas de cible, prendre le meilleur target du contexte
	if target == &"" and ctx.priority_targets.size() > 0:
		target = StringName(ctx.priority_targets[0])

	# --- Goals d’urgence (ceux posés par apply_arc_modifiers) ---
	if gid == "GOAL_WAR":
		return {
			"type": "ARC",
			"target_faction_id": target,
			"preferred_actions": [ArcDecisionUtil.ARC_DECLARE_WAR, ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_SABOTAGE],
			"priority": 1.0,
			"tier_bias": +2,  # WAR -> tier plus haut
		}

	if gid == "GOAL_CONFLICT":
		return {
			"type": "ARC",
			"target_faction_id": target,
			"preferred_actions": [ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_SABOTAGE, ArcDecisionUtil.ARC_ULTIMATUM],
			"priority": 0.8,
			"tier_bias": +1,
		}

	if gid == "GOAL_TRUCE":
		return {
			"type": "ARC",
			"target_faction_id": target,
			"preferred_actions": [ArcDecisionUtil.ARC_TRUCE_TALKS, ArcDecisionUtil.ARC_REPARATIONS, ArcDecisionUtil.ARC_ALLIANCE_OFFER],
			"priority": 0.7,
			"tier_bias": 0,
		}

	# --- Goals “normaux” (MVP) : parfois ARC, parfois WORLD ---
	# Exemple simple: si menace externe forte, réduire les arcs hostiles
	if ctx.external_threat >= 0.6:
		return {"type":"WORLD", "action":"fortify", "priority":0.7}

	# Si grosse opportunité, autoriser une action ARC opportuniste
	if ctx.opportunity >= 0.55 and target != &"":
		return {
			"type": "ARC",
			"target_faction_id": target,
			"preferred_actions": [ArcDecisionUtil.ARC_ULTIMATUM, ArcDecisionUtil.ARC_RAID],
			"priority": 0.55,
			"tier_bias": 0,
		}

	# Sinon action monde par défaut
	return {"type":"WORLD", "action":"develop", "priority":0.4}
```

---

## 2) Côté ArcManager : consommer l’intent et générer des offers

### Helper “pick action depuis intent + policy”
```gdscript
func _pick_action_from_intent(intent: Dictionary, arc_state: ArcState, rng: RandomNumberGenerator) -> StringName:
	var prefs: Array = intent.get("preferred_actions", [])
	var proposed: StringName = ArcDecisionUtil.ARC_IGNORE
	if prefs.size() > 0:
		proposed = prefs[rng.randi_range(0, prefs.size() - 1)]
	else:
		proposed = ArcDecisionUtil.select_arc_action_type(...) # si tu veux fallback

	# Filtrer selon l’état (WAR/RIVALRY/etc.)
	return ArcPolicy.filter_action_for_state(arc_state.state, proposed, rng)
```

### Helper “tier” depuis état + bias
```gdscript
func _tier_for_state(state: StringName) -> int:
	match state:
		&"WAR": return 3
		&"CONFLICT": return 2
		&"RIVALRY": return 1
		&"TRUCE": return 1
		&"ALLIANCE": return 2
		_: return 1

func _apply_tier_bias(base_tier: int, bias: int) -> int:
	return clampi(base_tier + bias, 1, 5)
```

### Consommation dans la boucle monde
Dans ton `WorldSim.tick_day()` (ou `FactionSim.apply()`), après `intent = plan_action(...)` :

```gdscript
if intent.get("type","") == "ARC":
	var target: StringName = intent.get("target_faction_id", &"")
	if target == &"":
		return

	var pair_state: ArcState = ArcManagerRunner.get_or_create_pair_state(faction_id, target)
	ArcStateMachine.tick_day_for_pair(pair_state, relations[faction_id][target], relations[target][faction_id])

	var action := _pick_action_from_intent(intent, pair_state, _rng)
	if action == ArcDecisionUtil.ARC_IGNORE:
		return

	var base_tier := _tier_for_state(pair_state.state)
	var tier := _apply_tier_bias(base_tier, int(intent.get("tier_bias", 0)))

	# Ici tu utilises ta logique "cap concurrent + upgrade possible"
	_ensure_arc_offers_for_pair(
		QuestPool,
		ArcManagerRunner.get_arc_id_for_pair(faction_id, target),
		pair_state,
		faction_id,
		target,
		action,
		relations[faction_id][target],
		faction_profiles,
		faction_economies,
		budget_mgr,
		_rng, ctx.day,
		tier
	)
```

---

## 3) Ce que ça donne en pratique
- WAR → le goal force **actions hostiles** (raid/sabotage/declare_war) + tier plus élevé → meilleures quêtes, plus rares (budget/or).
- TRUCE → le goal force **actions paix** (truce/reparations/alliance) → quêtes diplomatiques/logistiques.
- Les goals “normaux” peuvent générer des arcs opportunistes mais sinon font des actions monde.

C’est déjà suffisant pour que les arcs ne soient plus “hors-sol”.

---

Si tu veux, prochaine brique (très utile) : une fonction `compute_opportunity/external_threat` mieux définie + une règle simple “si fatigue>0.7 => privilégier TRUCE/REPARATIONS même si CONFLICT”.

Moi:
prochaine brique (très utile) : une fonction compute_opportunity/external_threat mieux définie + une règle simple “si fatigue>0.7 => privilégier TRUCE/REPARATIONS même si CONFLICT”.

ChatGPT:
Voici une version **mieux définie** de `compute_external_threat()` / `compute_opportunity()` + une règle simple de **fatigue** qui pousse vers **TRUCE/REPARATIONS** même en CONFLICT.

Je pars de ton `FactionWorldContext.arcs` (liste d’entrées `{state, rel_mean, tension_mean, griev_mean, wear_mean, other_id, ...}`).

---

## 1) Fonctions de calcul

### `compute_external_threat(ctx)`
But : mesurer “à quel point la faction est menacée” (0..1).  
On combine :
- **hostility** (relation négative)
- **pressure** (tension + grievance)
- **immediacy** (état WAR/CONFLICT)
- **self fatigue** (si tu es usé, la menace est “pire”)

```gdscript
static func compute_external_threat(ctx: FactionWorldContext) -> float:
	if ctx.arcs.is_empty():
		return 0.0

	var sum := 0.0
	var max_t := 0.0

	for a in ctx.arcs:
		var st: StringName = a.get("state", &"NEUTRAL")
		var rel := float(a.get("rel_mean", 0.0))
		var tens := float(a.get("tension_mean", 0.0)) / 100.0
		var griev := float(a.get("griev_mean", 0.0)) / 100.0
		var wear := float(a.get("wear_mean", 0.0)) / 100.0

		# 0..1 : plus relation est négative, plus host élevé
		var host := clampf(max(0.0, -rel) / 100.0, 0.0, 1.0)

		# état = immédiateté
		var state_mul := 0.25
		match st:
			&"WAR":      state_mul = 1.00
			&"CONFLICT": state_mul = 0.80
			&"RIVALRY":  state_mul = 0.55
			&"TRUCE":    state_mul = 0.35
			&"ALLIANCE": state_mul = 0.10

		# pression combinée
		var pressure := clampf(0.65 * tens + 0.35 * griev, 0.0, 1.0)

		# menace de cette paire
		var t := host * pressure * state_mul

		# la fatigue locale réduit ta capacité => menace perçue augmente légèrement
		t *= (1.0 + 0.35 * wear)

		sum += t
		if t > max_t:
			max_t = t

	# external_threat = mix max (danger immédiat) + moyenne (pression globale)
	var avg := sum / float(ctx.arcs.size())
	var fatigue_boost := 1.0 + 0.20 * clampf(ctx.fatigue, 0.0, 1.0)
	return clampf((0.65 * max_t + 0.35 * avg) * fatigue_boost, 0.0, 1.0)
```

---

### `compute_opportunity(ctx)`
But : détecter “une fenêtre d’attaque rentable” (0..1).  
On favorise :
- hostilité forte (relation très négative)
- tension haute (conflit mûr)
- **mais** on pénalise si **toi** tu es fatigué (tu ne peux pas capitaliser)
- on boost si l’adversaire est en TRUCE/RIVALRY (plus vulnérable politiquement)

Comme on n’a pas la fatigue adverse, on s’appuie sur l’état et la tension.

```gdscript
static func compute_opportunity(ctx: FactionWorldContext) -> float:
	if ctx.arcs.is_empty():
		return 0.0

	var best := 0.0
	for a in ctx.arcs:
		var st: StringName = a.get("state", &"NEUTRAL")
		var rel := float(a.get("rel_mean", 0.0))
		var tens := float(a.get("tension_mean", 0.0)) / 100.0
		var griev := float(a.get("griev_mean", 0.0)) / 100.0

		var host := clampf(max(0.0, -rel - 20.0) / 80.0, 0.0, 1.0)  # nécessite déjà une hostilité “installée”
		var heat := clampf(0.70 * tens + 0.30 * griev, 0.0, 1.0)

		# état “opportunity” : TRUCE/RIVALRY sont plus “exploitables” que WAR (où c’est déjà engagé)
		var state_mul := 0.35
		match st:
			&"TRUCE":    state_mul = 1.00
			&"RIVALRY":  state_mul = 0.85
			&"CONFLICT": state_mul = 0.70
			&"WAR":      state_mul = 0.45
			&"ALLIANCE": state_mul = 0.10

		# opportunité locale
		var o := host * heat * state_mul

		# ta fatigue pénalise ta capacité à exploiter l’opportunité
		o *= (1.0 - 0.60 * clampf(ctx.fatigue, 0.0, 1.0))

		best = max(best, o)

	return clampf(best, 0.0, 1.0)
```

---

## 2) Règle “fatigue > 0.7 => privilégier TRUCE/REPARATIONS même si CONFLICT”

Tu peux l’implémenter **dans le planner** (c’est le meilleur endroit), ou comme override de `preferred_actions`.

### Patch minimal dans `plan_action(goal, ctx, rng)`

Juste avant de retourner l’intent CONFLICT :

```gdscript
if gid == "GOAL_CONFLICT":
	# règle fatigue
	if ctx.fatigue >= 0.70:
		return {
			"type": "ARC",
			"target_faction_id": target,
			"preferred_actions": [ArcDecisionUtil.ARC_TRUCE_TALKS, ArcDecisionUtil.ARC_REPARATIONS],
			"priority": 0.85,
			"tier_bias": 0,
			"reason": "fatigue_override"
		}

	return {
		"type": "ARC",
		"target_faction_id": target,
		"preferred_actions": [ArcDecisionUtil.ARC_RAID, ArcDecisionUtil.ARC_SABOTAGE, ArcDecisionUtil.ARC_ULTIMATUM],
		"priority": 0.8,
		"tier_bias": +1,
	}
```

### Variante encore plus simple (sans toucher aux goals)
Si tu veux que ça s’applique “même si le goal est autre chose” :
- après calcul de l’intent, si `ctx.fatigue >= 0.7` et `intent.type=="ARC"` et `intent` est hostile → remplace par `TRUCE/REPARATIONS`.

---

## 3) Où les appeler
Dans ton `build_context_for_faction()` :

```gdscript
ctx.external_threat = WorldMetrics.compute_external_threat(ctx)
ctx.opportunity = WorldMetrics.compute_opportunity(ctx)
```

(ou direct si tu gardes les fonctions statiques dans un util `WorldMetrics.gd`).

---

Si tu veux, prochaine brique logique : une fonction `compute_priority_targets(ctx)` qui utilise **threat** et **opportunity** pour choisir une cible cohérente (pas forcément la même), et qui peut retourner “meilleur ennemi” + “meilleur futur allié”.

Moi:
prochaine brique logique : une fonction compute_priority_targets(ctx) qui utilise threat et opportunity pour choisir une cible cohérente (pas forcément la même), et qui peut retourner “meilleur ennemi” + “meilleur futur allié”.
Il faut aussi que ca prenne en compte le nombre d'action hostile ou amicale fait par la faction qu'on vise (dans le passé et en cours actuellement).

ChatGPT:
OK — on peut faire ça proprement avec un “score ennemi” et un “score allié” calculés **par paire** à partir de :

- l’état courant (WAR/CONFLICT/TRUCE/…),
- `rel_mean / trust_mean / tension_mean / griev_mean / wear_mean`,
- **et** l’historique des actions **du target vers nous** (hostile/amical), avec un **poids de récence** (heat/decay).

Je te propose :

1) un micro-ajout à `ArcNotebook` : `PairHeat` + `record_pair_event()` + `get_pair_heat()`
2) `compute_priority_targets(ctx, notebook, self_id)` qui renvoie :
   - `best_enemy`
   - `best_ally`
   - des rankings (debug/metrics)

---

## 1) Micro-ajout ArcNotebook : “heat” hostile/amical par paire

### `PairHeat.gd`
```gdscript
class_name PairHeat
extends RefCounted

var last_day: int = -999999

var hostile_ab: float = 0.0
var friendly_ab: float = 0.0
var hostile_ba: float = 0.0
var friendly_ba: float = 0.0

func decay_to(day: int, decay_per_day: float = 0.93) -> void:
	var dt := max(0, day - last_day)
	if dt == 0:
		return
	var f := pow(decay_per_day, float(dt))
	hostile_ab *= f
	friendly_ab *= f
	hostile_ba *= f
	friendly_ba *= f
	last_day = day
```

### Ajouts dans `ArcNotebook.gd`
```gdscript
# ArcNotebook.gd
var pair_heat_by_key: Dictionary[StringName, PairHeat] = {} # "a|b" -> heat

static func _pair_key(a: StringName, b: StringName) -> StringName:
	return StringName((String(a) <= String(b)) ? (String(a) + "|" + String(b)) : (String(b) + "|" + String(a)))

static func _severity_for_action(action: StringName) -> float:
	match action:
		ArcDecisionUtil.ARC_DECLARE_WAR:    return 3.0
		ArcDecisionUtil.ARC_RAID:          return 1.0
		ArcDecisionUtil.ARC_SABOTAGE:      return 1.2
		ArcDecisionUtil.ARC_ULTIMATUM:     return 0.8
		ArcDecisionUtil.ARC_TRUCE_TALKS:   return 1.2
		ArcDecisionUtil.ARC_REPARATIONS:   return 1.0
		ArcDecisionUtil.ARC_ALLIANCE_OFFER:return 1.6
		_:                                 return 1.0

func record_pair_event(attacker: StringName, defender: StringName, action: StringName, day: int) -> void:
	var key := _pair_key(attacker, defender)
	var heat: PairHeat = pair_heat_by_key.get(key, null)
	if heat == null:
		heat = PairHeat.new()
		heat.last_day = day
		pair_heat_by_key[key] = heat
	heat.decay_to(day)

	var sev := _severity_for_action(action)
	var a_is_first := (String(attacker) <= String(defender))

	if ArcStateMachine.is_hostile_action(action):
		if a_is_first:
			heat.hostile_ab += sev
		else:
			heat.hostile_ba += sev
	elif ArcStateMachine.is_peace_action(action):
		if a_is_first:
			heat.friendly_ab += sev
		else:
			heat.friendly_ba += sev

func get_pair_heat(self_id: StringName, other_id: StringName, day: int, decay_per_day: float = 0.93) -> Dictionary:
	var key := _pair_key(self_id, other_id)
	var heat: PairHeat = pair_heat_by_key.get(key, null)
	if heat == null:
		return {"hostile_from_other":0.0, "friendly_from_other":0.0, "hostile_to_other":0.0, "friendly_to_other":0.0}

	heat.decay_to(day, decay_per_day)

	# Reconstituer le sens self->other / other->self
	var self_is_first := (String(self_id) <= String(other_id))
	var hostile_to_other := heat.hostile_ab if self_is_first else heat.hostile_ba
	var friendly_to_other := heat.friendly_ab if self_is_first else heat.friendly_ba
	var hostile_from_other := heat.hostile_ba if self_is_first else heat.hostile_ab
	var friendly_from_other := heat.friendly_ba if self_is_first else heat.friendly_ab

	return {
		"hostile_from_other": hostile_from_other,
		"friendly_from_other": friendly_from_other,
		"hostile_to_other": hostile_to_other,
		"friendly_to_other": friendly_to_other
	}
```

✅ Où appeler `record_pair_event()` ?  
Au moment où tu appliques un event d’arc / résolution (QuestManager→ArcManager), avec `(attacker=giver, defender=antagonist, action=arc_action_type, day)`.

---

## 2) `compute_priority_targets(ctx)` : meilleur ennemi + meilleur allié

### `WorldTargeting.gd`
```gdscript
class_name WorldTargeting
extends RefCounted

static func _state_threat_mul(st: StringName) -> float:
	match st:
		&"WAR":      return 1.00
		&"CONFLICT": return 0.80
		&"RIVALRY":  return 0.55
		&"TRUCE":    return 0.30
		&"ALLIANCE": return 0.10
		_:           return 0.25

static func _state_opp_mul(st: StringName) -> float:
	match st:
		&"TRUCE":    return 1.00
		&"RIVALRY":  return 0.85
		&"CONFLICT": return 0.70
		&"WAR":      return 0.45
		&"ALLIANCE": return 0.10
		_:           return 0.35

static func _pair_threat(a: Dictionary, self_fatigue: float) -> float:
	var st: StringName = a.get("state", &"NEUTRAL")
	var rel := float(a.get("rel_mean", 0.0))
	var tens := float(a.get("tension_mean", 0.0)) / 100.0
	var griev := float(a.get("griev_mean", 0.0)) / 100.0
	var wear := float(a.get("wear_mean", 0.0)) / 100.0

	var host := clampf(max(0.0, -rel) / 100.0, 0.0, 1.0)
	var pressure := clampf(0.65 * tens + 0.35 * griev, 0.0, 1.0)
	var t := host * pressure * _state_threat_mul(st)
	t *= (1.0 + 0.35 * wear) * (1.0 + 0.20 * clampf(self_fatigue, 0.0, 1.0))
	return clampf(t, 0.0, 1.0)

static func _pair_opportunity(a: Dictionary, self_fatigue: float) -> float:
	var st: StringName = a.get("state", &"NEUTRAL")
	var rel := float(a.get("rel_mean", 0.0))
	var tens := float(a.get("tension_mean", 0.0)) / 100.0
	var griev := float(a.get("griev_mean", 0.0)) / 100.0

	var host := clampf(max(0.0, -rel - 20.0) / 80.0, 0.0, 1.0)
	var heat := clampf(0.70 * tens + 0.30 * griev, 0.0, 1.0)

	var o := host * heat * _state_opp_mul(st)
	o *= (1.0 - 0.60 * clampf(self_fatigue, 0.0, 1.0))
	return clampf(o, 0.0, 1.0)

static func compute_priority_targets(
	ctx: FactionWorldContext,
	notebook: ArcNotebook,
	self_id: StringName,
	decay_per_day: float = 0.93
) -> Dictionary:
	var best_enemy := &""
	var best_enemy_score := -1e9
	var best_ally := &""
	var best_ally_score := -1e9

	var enemy_rank: Array = []
	var ally_rank: Array = []

	for a in ctx.arcs:
		var other: StringName = StringName(a.get("other_id", &""))
		if other == &"":
			continue

		var rel := float(a.get("rel_mean", 0.0))
		var trust := float(a.get("trust_mean", 0.0))
		var st: StringName = a.get("state", &"NEUTRAL")

		var threat := _pair_threat(a, ctx.fatigue)
		var opp := _pair_opportunity(a, ctx.fatigue)

		# Historique (heat décadent) : ce que l’autre a fait envers nous
		var h := notebook.get_pair_heat(self_id, other, ctx.day, decay_per_day)
		var hostile_from := float(h["hostile_from_other"])
		var friendly_from := float(h["friendly_from_other"])

		# Normaliser heat -> 0..1 (soft cap)
		var hostile_n := 1.0 - exp(-0.35 * hostile_from)   # 0..~1
		var friendly_n := 1.0 - exp(-0.35 * friendly_from)

		# --- Score ennemi ---
		# menace + opportunité + hostilité récente de l’autre
		var enemy_score := 1.00*threat + 0.70*opp + 0.55*hostile_n - 0.35*friendly_n
		# si relation déjà positive, on pénalise (évite de choisir comme “ennemi” un allié)
		enemy_score -= 0.25 * clampf((rel) / 100.0, 0.0, 1.0)

		# --- Score allié ---
		# relation + trust + gestes amicaux récents, pénalise hostilité
		var rel_pos := clampf(rel / 100.0, 0.0, 1.0)
		var trust_pos := clampf(trust / 100.0, 0.0, 1.0)
		var ally_score := 0.70*rel_pos + 0.55*trust_pos + 0.70*friendly_n - 0.85*hostile_n
		# si on est en WAR/CONFLICT, on baisse un peu la probabilité “allié” avec cet autre
		if st == &"WAR" or st == &"CONFLICT":
			ally_score *= 0.55

		enemy_rank.append({"id": other, "score": enemy_score, "threat": threat, "opp": opp, "hostile": hostile_from, "friendly": friendly_from})
		ally_rank.append({"id": other, "score": ally_score, "rel": rel, "trust": trust, "hostile": hostile_from, "friendly": friendly_from})

		if enemy_score > best_enemy_score:
			best_enemy_score = enemy_score
			best_enemy = other

		if ally_score > best_ally_score:
			best_ally_score = ally_score
			best_ally = other

	# Évite best_enemy == best_ally : si collision, prend le 2ème meilleur ally
	if best_enemy != &"" and best_enemy == best_ally:
		ally_rank.sort_custom(func(x,y): return float(x["score"]) > float(y["score"]))
		for item in ally_rank:
			var oid: StringName = item["id"]
			if oid != best_enemy:
				best_ally = oid
				best_ally_score = float(item["score"])
				break

	# Tri debug/metrics
	enemy_rank.sort_custom(func(x,y): return float(x["score"]) > float(y["score"]))
	ally_rank.sort_custom(func(x,y): return float(x["score"]) > float(y["score"]))

	return {
		"best_enemy": best_enemy,
		"best_enemy_score": best_enemy_score,
		"best_ally": best_ally,
		"best_ally_score": best_ally_score,
		"enemy_rank": enemy_rank,
		"ally_rank": ally_rank
	}
```

### Comment l’utiliser
Dans `build_context_for_faction()` :
```gdscript
var tgt := WorldTargeting.compute_priority_targets(ctx, ArcManagerRunner.arc_notebook, fid)
ctx.priority_targets = []
if tgt["best_enemy"] != &"": ctx.priority_targets.append(tgt["best_enemy"])
if tgt["best_ally"] != &"": ctx.priority_targets.append(tgt["best_ally"])
```

---

## 3) Ce que ça apporte (très concret)
- La cible “ennemi” n’est pas seulement “relation négative”, mais aussi :
  - menace/opportunité **et** “ils ont été hostiles récemment”.
- La cible “allié” favorise :
  - relation/trust **et** “ils ont fait des gestes amicaux récemment”.
- Et comme c’est du **heat décadent**, ça reflète “passé + en cours” naturellement.

Si tu veux, prochaine brique : un mini test qui simule 30 jours d’events `record_pair_event()` et vérifie que `best_enemy/best_ally` basculent correctement quand on inverse les actions (ex: B fait 3 raids sur A puis 2 réparations).

Moi:
prochaine brique : un mini test qui simule 30 jours d’events record_pair_event() et vérifie que best_enemy/best_ally basculent correctement quand on inverse les actions (ex: B fait 3 raids sur A puis 2 réparations).

ChatGPT:
Voici un **mini test Godot (GDScript)** qui simule **30 jours** d’événements `record_pair_event()` et vérifie le basculement :

- **Jour 10** : `best_enemy == B` (B a fait 3 raids sur A)
- **Jour 30** : `best_ally == B` (B fait 2 réparations + contexte relation/trust amélioré), et `best_enemy == C` (reste hostile)

> Pré-requis : `ArcNotebook.record_pair_event()`, `FactionWorldContext`, `WorldTargeting.compute_priority_targets()` existent (comme on vient de poser).  
> Tu peux placer ce fichier dans ton dossier tests/harness.

---

## `tests/WorldTargetingHeatTest.gd`

```gdscript
extends Node
class_name WorldTargetingHeatTest

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 424242

	_test_priority_targets_shift_with_heat_inversion()

	print("\n✅ WorldTargetingHeatTest: OK\n")
	get_tree().quit()


func _test_priority_targets_shift_with_heat_inversion() -> void:
	var nb := ArcNotebook.new()
	var self_id := &"A"
	var b := &"B"
	var c := &"C"

	# Base context for A (2 pairs: A-B and A-C)
	var ctx := FactionWorldContext.new()
	ctx.faction_id = self_id
	ctx.fatigue = 0.20

	# --- Initial arc snapshot (day 1..10): B is the worst, C is bad-but-less ---
	var arc_b := {
		"other_id": b,
		"pair_key": &"A|B",
		"state": &"RIVALRY",
		"rel_mean": -70.0,
		"trust_mean": 20.0,
		"tension_mean": 70.0,
		"griev_mean": 60.0,
		"wear_mean": 20.0
	}
	var arc_c := {
		"other_id": c,
		"pair_key": &"A|C",
		"state": &"RIVALRY",
		"rel_mean": -50.0,
		"trust_mean": 30.0,
		"tension_mean": 55.0,
		"griev_mean": 40.0,
		"wear_mean": 10.0
	}
	ctx.arcs = [arc_b, arc_c]

	# --- Simulate 30 days of events ---
	for day in range(1, 31):
		ctx.day = day

		# B raids A on days 2, 4, 6
		if day == 2 or day == 4 or day == 6:
			nb.record_pair_event(b, self_id, ArcDecisionUtil.ARC_RAID, day)

		# B makes reparations to A on days 25, 27
		if day == 25 or day == 27:
			nb.record_pair_event(b, self_id, ArcDecisionUtil.ARC_REPARATIONS, day)

		# At day 10: B should clearly be best_enemy
		if day == 10:
			var res10 := WorldTargeting.compute_priority_targets(ctx, nb, self_id)
			_assert(StringName(res10["best_enemy"]) == b, "day10: best_enemy should be B after 3 raids")
			# On ne force pas best_ally ici (trop tôt / relations négatives)

	# --- Now invert the "current situation" at day 30: B becomes a truce partner ---
	ctx.day = 30
	arc_b["state"] = &"TRUCE"
	arc_b["rel_mean"] = 45.0
	arc_b["trust_mean"] = 70.0
	arc_b["tension_mean"] = 15.0
	arc_b["griev_mean"] = 10.0
	arc_b["wear_mean"] = 25.0

	# C stays hostile
	arc_c["state"] = &"RIVALRY"
	arc_c["rel_mean"] = -55.0
	arc_c["trust_mean"] = 25.0
	arc_c["tension_mean"] = 60.0
	arc_c["griev_mean"] = 45.0
	arc_c["wear_mean"] = 12.0

	var res30 := WorldTargeting.compute_priority_targets(ctx, nb, self_id)

	_assert(StringName(res30["best_ally"]) == b, "day30: best_ally should be B after reparations + improved trust/rel")
	_assert(StringName(res30["best_enemy"]) == c, "day30: best_enemy should shift to C once B is no longer the top enemy")

	# (Optionnel debug) : vérifier qu'on a bien enregistré des attempts (juste sanity)
	# print(res30["enemy_rank"])
	# print(res30["ally_rank"])


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

### Pourquoi ce test est robuste
- Il ne dépend pas de POI, de QuestGenerator, ni de RNG.
- Il prouve que ton **heat décadent + contexte relation/trust** fait basculer :
  - l’ennemi prioritaire (B → C)
  - et l’allié prioritaire (B devient allié)

Si tu veux, je peux ajouter une 2e assertion “quantitative” (ex: `best_enemy_score` baisse pour B entre J10 et J30) pour vérifier la décroissance/renversement plus finement.

Moi:
ajouter dans un autre test une 2e assertion “quantitative” (ex: best_enemy_score baisse pour B entre J10 et J30) pour vérifier la décroissance/renversement plus finement

ChatGPT:
Voici un **second test** dédié aux assertions quantitatives : on mesure le **score “enemy” de B** à J10 puis à J30, et on vérifie qu’il **baisse fortement** (et, bonus utile, que le score “ally” de B **monte**).

## `tests/WorldTargetingQuantitativeShiftTest.gd`

```gdscript
extends Node
class_name WorldTargetingQuantitativeShiftTest

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 77777

	_test_enemy_score_decreases_for_B_between_day10_and_day30()

	print("\n✅ WorldTargetingQuantitativeShiftTest: OK\n")
	get_tree().quit()


func _test_enemy_score_decreases_for_B_between_day10_and_day30() -> void:
	var nb := ArcNotebook.new()
	var self_id := &"A"
	var b := &"B"
	var c := &"C"

	var ctx := FactionWorldContext.new()
	ctx.faction_id = self_id
	ctx.fatigue = 0.20

	var arc_b := {
		"other_id": b,
		"pair_key": &"A|B",
		"state": &"RIVALRY",
		"rel_mean": -70.0,
		"trust_mean": 20.0,
		"tension_mean": 70.0,
		"griev_mean": 60.0,
		"wear_mean": 20.0
	}
	var arc_c := {
		"other_id": c,
		"pair_key": &"A|C",
		"state": &"RIVALRY",
		"rel_mean": -50.0,
		"trust_mean": 30.0,
		"tension_mean": 55.0,
		"griev_mean": 40.0,
		"wear_mean": 10.0
	}
	ctx.arcs = [arc_b, arc_c]

	# Simule 30 jours d'events
	for day in range(1, 31):
		ctx.day = day

		# B raid A (3 fois)
		if day == 2 or day == 4 or day == 6:
			nb.record_pair_event(b, self_id, ArcDecisionUtil.ARC_RAID, day)

		# B réparations (2 fois) en fin de période
		if day == 25 or day == 27:
			nb.record_pair_event(b, self_id, ArcDecisionUtil.ARC_REPARATIONS, day)

	# --- Snapshot J10 (B encore en rivalité hostile) ---
	ctx.day = 10
	var res10 := WorldTargeting.compute_priority_targets(ctx, nb, self_id)
	var b_enemy_10 := _score_for_id(res10["enemy_rank"], b)
	var b_ally_10 := _score_for_id(res10["ally_rank"], b)

	_assert(b_enemy_10 != null, "day10: B must appear in enemy_rank")
	_assert(b_ally_10 != null, "day10: B must appear in ally_rank")

	# --- Snapshot J30 : on inverse la situation courante (B devient partenaire de trêve) ---
	ctx.day = 30
	arc_b["state"] = &"TRUCE"
	arc_b["rel_mean"] = 45.0
	arc_b["trust_mean"] = 70.0
	arc_b["tension_mean"] = 15.0
	arc_b["griev_mean"] = 10.0
	arc_b["wear_mean"] = 25.0

	# C reste hostile
	arc_c["state"] = &"RIVALRY"
	arc_c["rel_mean"] = -55.0
	arc_c["trust_mean"] = 25.0
	arc_c["tension_mean"] = 60.0
	arc_c["griev_mean"] = 45.0
	arc_c["wear_mean"] = 12.0

	var res30 := WorldTargeting.compute_priority_targets(ctx, nb, self_id)
	var b_enemy_30 := _score_for_id(res30["enemy_rank"], b)
	var b_ally_30 := _score_for_id(res30["ally_rank"], b)

	_assert(b_enemy_30 != null, "day30: B must appear in enemy_rank")
	_assert(b_ally_30 != null, "day30: B must appear in ally_rank")

	# --- Assertions quantitatives ---
	# 1) Le score ennemi de B doit baisser nettement
	var e10 := float(b_enemy_10)
	var e30 := float(b_enemy_30)

	_assert(e30 < e10 - 0.35, "enemy_score(B) should drop by at least 0.35 (got %.3f -> %.3f)" % [e10, e30])
	_assert(e30 < e10 * 0.70, "enemy_score(B) should drop by at least 30%% (got %.3f -> %.3f)" % [e10, e30])

	# 2) (Bonus) Le score allié de B doit augmenter nettement
	var a10 := float(b_ally_10)
	var a30 := float(b_ally_30)

	_assert(a30 > a10 + 0.25, "ally_score(B) should rise by at least 0.25 (got %.3f -> %.3f)" % [a10, a30])


func _score_for_id(rank: Array, id: StringName):
	for item in rank:
		if StringName(item.get("id", &"")) == id:
			return item.get("score", null)
	return null


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

### Pourquoi ces seuils sont raisonnables
- Tes scores sont typiquement dans une plage ~[-1 ; +2] selon la heat + threat/opp, donc :
  - `-0.35` et `-30%` sont des deltas “significatifs” mais pas trop fragiles.
- Et la montée “ally” de `+0.25` reflète bien le passage “rivalité hostile → trêve + gestes amicaux”.

Si tu veux que ce soit encore plus stable, je peux te proposer une version qui compare **la contribution heat** seule (hostile_n/friendly_n) en plus du score final.

Moi:
Oui dans un autre test

ChatGPT:
Voici un **3ᵉ test** focalisé uniquement sur la **contribution “heat”** (hostile/friendly) — sans dépendre de `WorldTargeting`.

Il vérifie quantitativement que :
- la composante **hostile_from_other** (normalisée) pour B **baisse** entre J10 et J30 (décroissance/decay),
- la composante **friendly_from_other** (normalisée) pour B **augmente** après 2 réparations.

## `tests/PairHeatContributionShiftTest.gd`

```gdscript
extends Node
class_name PairHeatContributionShiftTest

func _ready() -> void:
	_test_heat_norms_shift_between_day10_and_day30()
	print("\n✅ PairHeatContributionShiftTest: OK\n")
	get_tree().quit()


func _test_heat_norms_shift_between_day10_and_day30() -> void:
	var nb := ArcNotebook.new()
	var self_id := &"A"
	var b := &"B"

	var decay := 0.93
	var k := 0.35 # doit matcher WorldTargeting (hostile_n = 1 - exp(-k*hostile_from))

	# Simule 30 jours d'events (B -> A)
	for day in range(1, 31):
		# B raid A (3 fois)
		if day == 2 or day == 4 or day == 6:
			nb.record_pair_event(b, self_id, ArcDecisionUtil.ARC_RAID, day)

		# B réparations (2 fois)
		if day == 25 or day == 27:
			nb.record_pair_event(b, self_id, ArcDecisionUtil.ARC_REPARATIONS, day)

	# --- Day 10 heat ---
	var h10 := nb.get_pair_heat(self_id, b, 10, decay)
	var hostile10 := float(h10["hostile_from_other"])
	var friendly10 := float(h10["friendly_from_other"])
	var hostile_n10 := _norm(hostile10, k)
	var friendly_n10 := _norm(friendly10, k)

	# --- Day 30 heat ---
	var h30 := nb.get_pair_heat(self_id, b, 30, decay)
	var hostile30 := float(h30["hostile_from_other"])
	var friendly30 := float(h30["friendly_from_other"])
	var hostile_n30 := _norm(hostile30, k)
	var friendly_n30 := _norm(friendly30, k)

	# Assertions qualitatives simples
	_assert(hostile10 > hostile30, "hostile_from_other should decay over time (raw)")
	_assert(friendly30 > friendly10, "friendly_from_other should increase after reparations (raw)")

	# Assertions quantitatives robustes (sur la partie normalisée 0..1)
	_assert(hostile_n30 < hostile_n10 - 0.30, "hostile_n should drop by at least 0.30 (got %.3f -> %.3f)" % [hostile_n10, hostile_n30])
	_assert(friendly_n30 > friendly_n10 + 0.25, "friendly_n should rise by at least 0.25 (got %.3f -> %.3f)" % [friendly_n10, friendly_n30])

	# (Optionnel) sanity: à J10 friendly devrait être ~0
	_assert(friendly_n10 <= 0.05, "friendly_n at day10 should be near 0 (got %.3f)" % friendly_n10)


func _norm(x: float, k: float) -> float:
	# 1 - exp(-k*x) => soft cap vers 1
	return 1.0 - exp(-k * max(0.0, x))


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

Si tu veux rendre ça encore plus “blindé”, on peut aussi vérifier que `hostile_from_other` baisse *même sans changer le contexte relationnel*, juste par le decay (ce test le fait déjà implicitement).

Moi:
Oui dans un 4eme test

ChatGPT:
Voici un **4ᵉ test** ultra ciblé : il prouve que le **decay seul** fait baisser `hostile_from_other` (et sa version normalisée) **même si aucun événement amical n’arrive** et même si on ne “change” aucun contexte.

## `tests/PairHeatDecayOnlyTest.gd`

```gdscript
extends Node
class_name PairHeatDecayOnlyTest

func _ready() -> void:
	_test_decay_only_reduces_hostile_heat_over_time()
	print("\n✅ PairHeatDecayOnlyTest: OK\n")
	get_tree().quit()


func _test_decay_only_reduces_hostile_heat_over_time() -> void:
	var nb := ArcNotebook.new()
	var a := &"A"
	var b := &"B"

	var decay := 0.93
	var k := 0.35

	# Injecte une "salve" hostile concentrée
	nb.record_pair_event(b, a, ArcDecisionUtil.ARC_RAID, 2)
	nb.record_pair_event(b, a, ArcDecisionUtil.ARC_RAID, 4)
	nb.record_pair_event(b, a, ArcDecisionUtil.ARC_RAID, 6)

	# Snapshot jour 10
	var h10 := nb.get_pair_heat(a, b, 10, decay)
	var hostile10 := float(h10["hostile_from_other"])
	var hostile_n10 := _norm(hostile10, k)

	# Aucun event ensuite => decay pur
	# Snapshot jour 30
	var h30 := nb.get_pair_heat(a, b, 30, decay)
	var hostile30 := float(h30["hostile_from_other"])
	var hostile_n30 := _norm(hostile30, k)

	# Assertions decay-only
	_assert(hostile30 < hostile10, "raw hostile heat should decay (got %.3f -> %.3f)" % [hostile10, hostile30])
	_assert(hostile_n30 < hostile_n10, "normalized hostile_n should decay (got %.3f -> %.3f)" % [hostile_n10, hostile_n30])

	# Quantitatif : baisse “significative”
	_assert(hostile_n30 < hostile_n10 - 0.25, "hostile_n should drop by at least 0.25 via decay-only (got %.3f -> %.3f)" % [hostile_n10, hostile_n30])


func _norm(x: float, k: float) -> float:
	return 1.0 - exp(-k * max(0.0, x))


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

Ce test est volontairement **indépendant** :
- pas de `WorldTargeting`,
- pas de relation/tension/trust,
- juste `ArcNotebook.record_pair_event()` + `get_pair_heat()` + decay.

Si tu veux, je peux te proposer une petite règle “si dt > 200 jours, clamp à ~0” pour éviter des floats résiduels, mais c’est optionnel.

Moi:
On fait :
6) Une notion de “third party” (intervention, médiation, opportunisme)
Très important pour éviter l’escalade binaire A↔B :
• C intervient comme médiateur (trêve) ou profite (raid opportuniste),
• les offres peuvent impliquer 3 factions (donne beaucoup de vie au monde).
Même une version simple (“si A↔B est chaud, C peut proposer trêve/commerce/allié”) ajoute énormément.

ChatGPT:
Oui — une “third party layer” est *le* truc qui casse l’escalade binaire A↔B et rend le monde vivant. Je te propose une V1 **simple mais déjà très efficace** : on ne crée pas un “arc à 3” complet, on fait des **offers à 3 factions** **attachées à l’arc principal A↔B** (donc ça impacte bien la rivalité), et on laisse ces offers **créer** (optionnellement) un nouvel arc C↔X si ça dérape.

---

## 1) Contexte standardisé pour une quête “3 factions”

On garde tes clés d’arc, et on ajoute :

```gdscript
# Third party keys
"is_third_party": true
"third_party_faction_id": StringName     # C (giver dans la plupart des cas)
"third_party_role": StringName           # "MEDIATOR"|"OPPORTUNIST"|"BROKER"
"primary_pair_key": StringName           # A|B (arc principal)
"side_a_faction_id": StringName          # A
"side_b_faction_id": StringName          # B
"involved_factions": Array[StringName]   # [A,B,C]
```

Optionnel selon la variante :
```gdscript
"beneficiary_faction_id": StringName     # ex: le camp aidé (commerce/armes/coalition)
"victim_faction_id": StringName          # ex: camp ciblé (raid opportuniste)
```

---

## 2) Micro-ajout ArcNotebook : cooldown “third party” par paire

```gdscript
# ArcNotebook.gd
var last_third_party_day_by_pair: Dictionary[StringName, int] = {} # primary_pair_key -> day

func can_spawn_third_party(primary_pair_key: StringName, day: int, cooldown_days: int = 7) -> bool:
	var last := int(last_third_party_day_by_pair.get(primary_pair_key, -999999))
	return (day - last) >= cooldown_days

func mark_third_party_spawned(primary_pair_key: StringName, day: int) -> void:
	last_third_party_day_by_pair[primary_pair_key] = day
```

---

## 3) Déclencheur : quand considérer qu’une paire A↔B est “chaude”

Tu as déjà les métriques + heat. Un score simple :

```gdscript
static func compute_pair_hotness(
	day: int,
	notebook: ArcNotebook,
	a_id: StringName,
	b_id: StringName,
	rel_ab: FactionRelationScore,
	rel_ba: FactionRelationScore
) -> float:
	var tension_mean := 0.5 * (rel_ab.tension + rel_ba.tension) / 100.0
	var griev_mean := 0.5 * (rel_ab.grievance + rel_ba.grievance) / 100.0

	var h := notebook.get_pair_heat(a_id, b_id, day) # hostile/friendly both ways
	var hostile_from_a := float(h["hostile_to_other"]) # A->B
	var hostile_from_b := float(h["hostile_from_other"]) # B->A (du point de vue de A)
	var hostile_n := 1.0 - exp(-0.35 * (hostile_from_a + hostile_from_b))

	return clampf(0.55*tension_mean + 0.30*griev_mean + 0.15*hostile_n, 0.0, 1.0)
```

---

## 4) Choix de la third party C : médiateur vs opportuniste

### Score médiation (C “aime” A et B, et a de la diplomatie)
```gdscript
static func score_mediator(
	profiles: Dictionary,
	relations: Dictionary, # relations[C][A], relations[C][B]
	c_id: StringName, a_id: StringName, b_id: StringName
) -> float:
	var p: FactionProfile = profiles[c_id]
	var diplo := p.get_personality(FactionProfile.PERS_DIPLOMACY, 0.5)
	var expa := p.get_personality(FactionProfile.PERS_EXPANSIONISM, 0.5)

	var rel_ca := float(relations[c_id][a_id].relation) / 100.0
	var rel_cb := float(relations[c_id][b_id].relation) / 100.0

	return 0.55*(max(rel_ca, 0.0) + max(rel_cb, 0.0)) + 0.60*diplo - 0.35*expa
```

### Score opportunisme (C belliqueux/expansionniste, et “déteste” un camp)
```gdscript
static func score_opportunist(
	profiles: Dictionary,
	relations: Dictionary,
	c_id: StringName, victim_id: StringName
) -> float:
	var p: FactionProfile = profiles[c_id]
	var expa := p.get_personality(FactionProfile.PERS_EXPANSIONISM, 0.5)
	var bell := p.get_personality(FactionProfile.PERS_BELLIGERENCE, 0.5) # si tu l’as, sinon remplace

	var rel_cv := float(relations[c_id][victim_id].relation)
	var host := clampf(max(0.0, -rel_cv) / 100.0, 0.0, 1.0)

	return 0.55*host + 0.35*expa + 0.35*bell
```

---

## 5) OfferFactory “third party” : mapping role → offers

### Actions third party (tags exemples)
- **MEDIATOR**
  - `tp.mediation.truce` → escort envoys / secure venue / investigate incident
  - `tp.mediation.trade` → reopen trade / protect caravan / audit reparations
- **OPPORTUNIST**
  - `tp.opportunist.raid` → raid supply-line / steal resources / sabotage
  - `tp.opportunist.coalition` → propose alliance A+C vs B (ou inverse)

> Techniquement : tu peux réutiliser ton `ArcOfferFactory.spawn_offers_for_pair()` en le “wrappant” pour injecter les clés third party et choisir les variants d’un petit catalogue TP.

### Factory minimale (produit une `QuestInstance` compatible `QuestPool`)
```gdscript
class_name ThirdPartyOfferFactory
extends RefCounted

const TP_CATALOG := {
	&"tp.mediation.truce": [
		{"tag":"diplo.mediation_escort_envoys", "w":40, "domain":"diplo", "needs_poi":true, "poi_types":[&"CITY",&"SANCTUARY"], "deadline":[5,7]},
		{"tag":"diplo.mediation_secure_venue",  "w":35, "domain":"diplo", "needs_poi":true, "poi_types":[&"CITY",&"TEMPLE"], "deadline":[5,7]},
		{"tag":"stealth.mediation_find_spoiler","w":25, "domain":"stealth","needs_poi":true, "poi_types":[&"CITY",&"CAMP"], "deadline":[6,9]},
	],
	&"tp.opportunist.raid": [
		{"tag":"combat.opportunist_raid",       "w":45, "domain":"combat", "needs_poi":true, "poi_types":[&"DEPOT",&"OUTPOST"], "deadline":[5,8]},
		{"tag":"stealth.opportunist_sabotage",  "w":35, "domain":"stealth","needs_poi":true, "poi_types":[&"WORKSHOP",&"DEPOT"], "deadline":[6,9]},
		{"tag":"logistics.opportunist_intercept","w":20, "domain":"logistics","needs_poi":false,"deadline":[6,9]},
	],
}

static func spawn_third_party_offer(
	primary_arc_id: StringName,
	primary_arc_state: ArcState,
	a_id: StringName,
	b_id: StringName,
	c_id: StringName,
	role: StringName,
	tp_action: StringName,
	rel_ca: FactionRelationScore, # C -> A (juste pour difficulty/risk si tu veux)
	profiles: Dictionary,
	economies: Dictionary,
	budget_mgr: ArcOfferBudgetManager,
	notebook: ArcNotebook,
	rng: RandomNumberGenerator,
	day: int,
	tier: int
) -> QuestInstance:
	var primary_pair_key := StringName((String(a_id) <= String(b_id)) ? (String(a_id)+"|"+String(b_id)) : (String(b_id)+"|"+String(a_id)))
	if not notebook.can_spawn_third_party(primary_pair_key, day, 7):
		return null

	var variants: Array = TP_CATALOG.get(tp_action, [])
	if variants.is_empty():
		return null

	# pick variant
	var v := ArcOfferFactory._weighted_pick(variants, rng) # si _weighted_pick est static/public, sinon recopie
	var domain := String(v.get("domain","diplo"))
	var deadline_days := rng.randi_range(int(v["deadline"][0]), int(v["deadline"][1]))

	# build a normal arc context first (giver=C, antagonist = "victim" selon rôle)
	# MEDIATOR: antagonist = none logique -> on met B par défaut, mais on stocke A/B dans context
	var antagonist := b_id
	if role == &"OPPORTUNIST":
		antagonist = b_id # victim (choisi par le caller)
	# stakes (réutilise tes compute_* si tu veux)
	var risk := 0.35
	var difficulty := 0.35
	var reward_gold := ArcOfferFactoryEconomy.compute_reward_gold(tier, difficulty, domain)
	var cost_points := ArcOfferFactoryEconomy.compute_action_cost_points(tp_action, primary_arc_state.state, difficulty, tier, profiles[c_id])

	var econ: FactionEconomy = economies.get(c_id, null)
	if econ == null or not econ.can_reserve(reward_gold):
		return null
	var budget := budget_mgr.get_budget(c_id)
	var pair_key_cx := StringName((String(c_id) <= String(antagonist)) ? (String(c_id)+"|"+String(antagonist)) : (String(antagonist)+"|"+String(c_id)))
	if not budget.can_open_offer(pair_key_cx, cost_points):
		return null

	var stakes := {"gold":reward_gold, "risk":risk, "difficulty":difficulty, "cost_points":cost_points, "domain":domain}

	var ctx := ArcStateMachine.build_arc_context(primary_arc_id, primary_arc_state, c_id, antagonist, tp_action, day, deadline_days, stakes, rng.randi())
	ctx["is_third_party"] = true
	ctx["third_party_faction_id"] = c_id
	ctx["third_party_role"] = role
	ctx["primary_pair_key"] = primary_pair_key
	ctx["side_a_faction_id"] = a_id
	ctx["side_b_faction_id"] = b_id
	ctx["involved_factions"] = [a_id, b_id, c_id]
	ctx["offer_tag"] = String(v.get("tag",""))
	ctx["offer_domain"] = domain

	# create template (fallback)
	var template := ArcOfferFactory._build_template_fallback(String(ctx["offer_tag"]), tier, deadline_days)
	var inst := QuestInstance.new(template, ctx)
	inst.status = "AVAILABLE"
	inst.started_on_day = day
	inst.expires_on_day = day + deadline_days

	# reserve
	var qid := StringName(inst.runtime_id)
	if not econ.reserve_for_quest(qid, reward_gold):
		return null
	if not budget.reserve_for_offer(qid, pair_key_cx, cost_points):
		econ.release_reservation(qid)
		return null

	inst.context["escrow_faction_id"] = c_id
	inst.context["escrow_gold"] = reward_gold
	inst.context["escrow_points"] = cost_points
	notebook.mark_third_party_spawned(primary_pair_key, day)

	return inst
```

---

## 6) Règle monde : “si A↔B est chaud, C peut proposer trêve/commerce/allié”

Dans ton tick monde (après avoir mesuré hotness), tu fais :

- si `hotness > 0.65` et pas de cooldown → tenter médiateur
- sinon si `hotness > 0.75` → tenter opportuniste (raid)

Pseudo :

```gdscript
func try_third_party_for_pair(a_id: StringName, b_id: StringName, day: int) -> void:
	var hot := compute_pair_hotness(day, arc_notebook, a_id, b_id, relations[a_id][b_id], relations[b_id][a_id])
	if hot < 0.65:
		return

	var primary_arc_id := get_arc_id_for_pair(a_id, b_id)
	var st: ArcState = get_or_create_pair_state(a_id, b_id)

	# pick best mediator C
	var best_c := &""
	var best_s := -1e9
	for c_id in faction_ids:
		if c_id == a_id or c_id == b_id: continue
		var s := score_mediator(faction_profiles, relations, c_id, a_id, b_id)
		if s > best_s:
			best_s = s
			best_c = c_id

	if best_c != &"" and best_s > 0.55:
		var inst := ThirdPartyOfferFactory.spawn_third_party_offer(
			primary_arc_id, st,
			a_id, b_id, best_c,
			&"MEDIATOR", &"tp.mediation.truce",
			relations[best_c][a_id],
			faction_profiles, faction_economies, budget_mgr, arc_notebook, _rng, day,
			1
		)
		if inst != null:
			QuestPool.try_add_offer(inst)
			return

	# sinon opportuniste (choisir victim = le plus faible / le plus détesté par C)
	if hot >= 0.75:
		# pick opportunist C (simple: celui qui déteste le plus B)
		var best_o := &""
		var best_os := -1e9
		for c_id in faction_ids:
			if c_id == a_id or c_id == b_id: continue
			var os := score_opportunist(faction_profiles, relations, c_id, b_id)
			if os > best_os:
				best_os = os
				best_o = c_id

		if best_o != &"" and best_os > 0.60:
			var inst2 := ThirdPartyOfferFactory.spawn_third_party_offer(
				primary_arc_id, st,
				a_id, b_id, best_o,
				&"OPPORTUNIST", &"tp.opportunist.raid",
				relations[best_o][b_id],
				faction_profiles, faction_economies, budget_mgr, arc_notebook, _rng, day,
				2
			)
			if inst2 != null:
				QuestPool.try_add_offer(inst2)
```

---

## 7) Résolution : effets à 3 factions (simple V1)

Tu gardes ton système LOYAL/NEUTRAL/TRAITOR, mais quand `is_third_party` :

- **MEDIATOR / LOYAL** :  
  - baisse tension & grievance entre A↔B  
  - monte trust A↔B  
  - monte relation A↔C et B↔C
- **OPPORTUNIST / LOYAL** :  
  - monte grievance/tension entre C↔victim  
  - peut **déclencher** un nouvel arc C↔victim si seuil dépassé

Tu n’as pas besoin d’un “arc à 3” complet pour que ça vive : l’offer est à 3, les **relations** changent à 3, et le système d’arcs “par paire” fait le reste.

---

Si tu veux, prochaine brique logique : **un mapping d’effets standard** pour `third_party_role + tp_action + choice` (deltas sur A↔B, A↔C, B↔C), et un petit test qui montre que “médiation répétée” fait converger vers TRUCE/ALLIANCE sans boucler en escalade.

Moi:
Ok fais
prochaine brique logique : un mapping d’effets standard pour third_party_role + tp_action + choice (deltas sur A↔B, A↔C, B↔C), et un petit test qui montre que “médiation répétée” fait converger vers TRUCE/ALLIANCE sans boucler en escalade

ChatGPT:
Voici ce que je te propose pour la **V1 “third party effects”** :

1) un fichier `ThirdPartyEffectTable.gd` : **table standardisée** `role + tp_action + choice → deltas` (sur **A↔B**, **A↔C**, **B↔C**), + une fonction `apply()`.
2) un test `ThirdPartyMediationConvergenceTest.gd` : répète des médiations LOYAL et montre que l’arc **converge vers TRUCE puis ALLIANCE** (tension↓, relation/trust↑), sans reboucler vers l’escalade.

---

## 1) Mapping d’effets standard

### `ThirdPartyEffectTable.gd`
```gdscript
class_name ThirdPartyEffectTable
extends RefCounted

const CHOICE_LOYAL: StringName = &"LOYAL"
const CHOICE_NEUTRAL: StringName = &"NEUTRAL"
const CHOICE_TRAITOR: StringName = &"TRAITOR"

# role -> tp_action -> choice -> effects[]
# effect := { "pair":"AB"|"AC"|"BC", "field":"relation|trust|tension|grievance|weariness", "delta": float }
const EFFECTS: Dictionary = {
	&"MEDIATOR": {
		&"tp.mediation.truce": {
			CHOICE_LOYAL: [
				{"pair":"AB","field":"tension","delta":-15}, {"pair":"AB","field":"grievance","delta":-12},
				{"pair":"AB","field":"trust","delta":+10},  {"pair":"AB","field":"relation","delta":+12},
				{"pair":"AB","field":"weariness","delta":-3},

				{"pair":"AC","field":"trust","delta":+6},   {"pair":"AC","field":"relation","delta":+6},
				{"pair":"BC","field":"trust","delta":+6},   {"pair":"BC","field":"relation","delta":+6},
			],
			CHOICE_NEUTRAL: [
				{"pair":"AB","field":"tension","delta":-9},  {"pair":"AB","field":"grievance","delta":-6},
				{"pair":"AB","field":"trust","delta":+4},    {"pair":"AB","field":"relation","delta":+5},
				{"pair":"AC","field":"relation","delta":+2}, {"pair":"BC","field":"relation","delta":+2},
			],
			CHOICE_TRAITOR: [
				{"pair":"AB","field":"tension","delta":+8},  {"pair":"AB","field":"grievance","delta":+8},
				{"pair":"AB","field":"trust","delta":-8},    {"pair":"AB","field":"relation","delta":-6},
				{"pair":"AC","field":"trust","delta":-10},   {"pair":"AC","field":"relation","delta":-10},
				{"pair":"BC","field":"trust","delta":-10},   {"pair":"BC","field":"relation","delta":-10},
			],
		},

		&"tp.mediation.trade": {
			CHOICE_LOYAL: [
				{"pair":"AB","field":"tension","delta":-8}, {"pair":"AB","field":"grievance","delta":-6},
				{"pair":"AB","field":"trust","delta":+6},  {"pair":"AB","field":"relation","delta":+8},
				{"pair":"AC","field":"relation","delta":+4},{"pair":"BC","field":"relation","delta":+4},
			],
			CHOICE_NEUTRAL: [
				{"pair":"AB","field":"tension","delta":-4}, {"pair":"AB","field":"relation","delta":+3},
			],
			CHOICE_TRAITOR: [
				{"pair":"AB","field":"trust","delta":-6}, {"pair":"AC","field":"relation","delta":-6},{"pair":"BC","field":"relation","delta":-6},
			],
		},
	},

	&"OPPORTUNIST": {
		&"tp.opportunist.raid": {
			# Ici, on suppose que "victim_faction_id" est B (ou A) dans le context ;
			# l’application ci-dessous traite AB comme "C<->victim" via apply_for_opportunist().
			CHOICE_LOYAL: [
				{"pair":"AB","field":"tension","delta":+14}, {"pair":"AB","field":"grievance","delta":+12},
				{"pair":"AB","field":"relation","delta":-12},{"pair":"AB","field":"trust","delta":-8},
				{"pair":"AC","field":"relation","delta":+4}, # beneficiary likes C (optionnel)
			],
			CHOICE_NEUTRAL: [
				{"pair":"AB","field":"tension","delta":+8}, {"pair":"AB","field":"relation","delta":-7},
			],
			CHOICE_TRAITOR: [
				{"pair":"AB","field":"tension","delta":+10},{"pair":"AB","field":"relation","delta":-10},
				{"pair":"AC","field":"relation","delta":-6}, {"pair":"BC","field":"relation","delta":-6},
			],
		},
	},
}

static func canonical_arc_action(role: StringName, tp_action: StringName) -> StringName:
	# utile si tu veux que l’ArcStateMachine compte ça comme peace/hostile
	if role == &"MEDIATOR" and tp_action == &"tp.mediation.truce":
		return ArcDecisionUtil.ARC_TRUCE_TALKS
	if role == &"MEDIATOR" and tp_action == &"tp.mediation.trade":
		return ArcDecisionUtil.ARC_REPARATIONS
	if role == &"OPPORTUNIST" and tp_action == &"tp.opportunist.raid":
		return ArcDecisionUtil.ARC_RAID
	return tp_action

static func apply(
	relations: Dictionary, # relations[X][Y] -> FactionRelationScore
	a_id: StringName,
	b_id: StringName,
	c_id: StringName,
	role: StringName,
	tp_action: StringName,
	choice: StringName,
	# limiter: max change per tick (ratio); tu peux le brancher à ton ArcNotebook/historique
	max_change_ratio: float = 0.25
) -> void:
	var role_map: Dictionary = EFFECTS.get(role, {})
	var action_map: Dictionary = role_map.get(tp_action, {})
	var effects: Array = action_map.get(choice, [])
	if effects.is_empty():
		return

	for e in effects:
		var pair := String(e.get("pair",""))
		var field := String(e.get("field",""))
		var delta := float(e.get("delta", 0.0))

		match pair:
			"AB":
				_apply_pair(relations, a_id, b_id, field, delta, max_change_ratio)
			"AC":
				_apply_pair(relations, a_id, c_id, field, delta, max_change_ratio)
			"BC":
				_apply_pair(relations, b_id, c_id, field, delta, max_change_ratio)
			_:
				pass

static func apply_for_opportunist(
	relations: Dictionary,
	beneficiary_id: StringName,  # ex: A
	victim_id: StringName,       # ex: B
	c_id: StringName,
	role: StringName,
	tp_action: StringName,
	choice: StringName,
	max_change_ratio: float = 0.25
) -> void:
	# Interprétation:
	# - "AB" = C <-> victim
	# - "AC" = beneficiary <-> C
	# - "BC" = beneficiary <-> victim (optionnel)
	var role_map: Dictionary = EFFECTS.get(role, {})
	var action_map: Dictionary = role_map.get(tp_action, {})
	var effects: Array = action_map.get(choice, [])
	if effects.is_empty():
		return

	for e in effects:
		var pair := String(e.get("pair",""))
		var field := String(e.get("field",""))
		var delta := float(e.get("delta", 0.0))

		match pair:
			"AB":
				_apply_pair(relations, c_id, victim_id, field, delta, max_change_ratio)
			"AC":
				_apply_pair(relations, beneficiary_id, c_id, field, delta, max_change_ratio)
			"BC":
				_apply_pair(relations, beneficiary_id, victim_id, field, delta, max_change_ratio)
			_:
				pass

static func _apply_pair(relations: Dictionary, x_id: StringName, y_id: StringName, field: String, delta: float, max_change_ratio: float) -> void:
	if not relations.has(x_id): return
	if not relations.has(y_id): return
	if not relations[x_id].has(y_id): return
	if not relations[y_id].has(x_id): return

	var xy: FactionRelationScore = relations[x_id][y_id]
	var yx: FactionRelationScore = relations[y_id][x_id]

	_apply_field(xy, field, delta, max_change_ratio)
	_apply_field(yx, field, delta, max_change_ratio)

static func _apply_field(r: FactionRelationScore, field: String, delta: float, max_change_ratio: float) -> void:
	var minv := 0.0
	var maxv := 100.0
	var cur := 0.0

	match field:
		"relation":
			minv = -100.0; maxv = 100.0
			cur = float(r.relation)
			r.relation = int(round(_apply_limited(cur, delta, minv, maxv, max_change_ratio)))
		"trust":
			cur = float(r.trust)
			r.trust = int(round(_apply_limited(cur, delta, minv, maxv, max_change_ratio)))
		"tension":
			cur = float(r.tension)
			r.tension = int(round(_apply_limited(cur, delta, minv, maxv, max_change_ratio)))
		"grievance":
			cur = float(r.grievance)
			r.grievance = int(round(_apply_limited(cur, delta, minv, maxv, max_change_ratio)))
		"weariness":
			cur = float(r.weariness)
			r.weariness = int(round(_apply_limited(cur, delta, minv, maxv, max_change_ratio)))
		_:
			pass

static func _apply_limited(cur: float, delta: float, minv: float, maxv: float, max_change_ratio: float) -> float:
	# limite “10..30% du score actuel” version générique:
	# clamp(delta) par abs(cur)*ratio, avec un minimum de pas.
	var cap := max(3.0, abs(cur) * clampf(max_change_ratio, 0.0, 1.0))
	var d := clampf(delta, -cap, cap)
	return clampf(cur + d, minv, maxv)
```

> Important : `max_change_ratio` peut être calculé dynamiquement via ton `ArcNotebook` (en fonction de l’historique / nb d’incidents), et passé ici.

---

## 2) Test : “médiation répétée” converge vers TRUCE/ALLIANCE

### `tests/ThirdPartyMediationConvergenceTest.gd`
Ce test simule 30 jours :
- A↔B démarre en **CONFLICT** avec tension/grievance élevées
- C déclenche 3 médiations `tp.mediation.truce` résolues **LOYAL**
- On tick chaque jour (stability counters), et on appelle `update_arc_state()` quotidiennement (action vide) pour laisser passer les transitions “après Y jours”.

```gdscript
extends Node
class_name ThirdPartyMediationConvergenceTest

func _ready() -> void:
	_test_repeated_mediation_converges()
	print("\n✅ ThirdPartyMediationConvergenceTest: OK\n")
	get_tree().quit()

func _test_repeated_mediation_converges() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 202501

	# ids
	var A := &"A"
	var B := &"B"
	var C := &"C"

	# relations dict
	var relations := {}
	relations[A] = {}; relations[B] = {}; relations[C] = {}

	relations[A][B] = FactionRelationScore.new()
	relations[B][A] = FactionRelationScore.new()
	relations[A][C] = FactionRelationScore.new()
	relations[C][A] = FactionRelationScore.new()
	relations[B][C] = FactionRelationScore.new()
	relations[C][B] = FactionRelationScore.new()

	# init A<->B hostile conflict
	relations[A][B].relation = -50; relations[B][A].relation = -52
	relations[A][B].trust = 20;     relations[B][A].trust = 18
	relations[A][B].tension = 70;   relations[B][A].tension = 72
	relations[A][B].grievance = 60; relations[B][A].grievance = 58
	relations[A][B].weariness = 30; relations[B][A].weariness = 28

	# init C neutral/good with both
	relations[A][C].relation = 10; relations[C][A].relation = 8
	relations[B][C].relation = 5;  relations[C][B].relation = 6
	relations[A][C].trust = 35;    relations[C][A].trust = 30
	relations[B][C].trust = 30;    relations[C][B].trust = 32

	# arc state A<->B
	var arc := ArcState.new()
	arc.state = &"CONFLICT"
	arc.lock_until_day = 0
	arc.phase_events = 0
	arc.phase_hostile = 0
	arc.phase_peace = 0
	arc.stable_low_tension_days = 0
	arc.stable_high_trust_days = 0

	var initial_tension := 0.5 * (relations[A][B].tension + relations[B][A].tension)
	var initial_rel := 0.5 * (relations[A][B].relation + relations[B][A].relation)

	var mediation_days := {2:true, 4:true, 6:true}

	for day in range(1, 31):
		# daily stability counters
		ArcStateMachine.tick_day_for_pair(arc, relations[A][B], relations[B][A])

		# Apply mediated event on some days
		if mediation_days.has(day):
			ThirdPartyEffectTable.apply(
				relations,
				A, B, C,
				&"MEDIATOR",
				&"tp.mediation.truce",
				ThirdPartyEffectTable.CHOICE_LOYAL,
				0.30 # max_change_ratio (plutôt permissif pour ce test)
			)

			# Feed arc state machine with canonical peace action
			ArcStateMachine.update_arc_state(
				arc, relations[A][B], relations[B][A],
				day, rng,
				ArcDecisionUtil.ARC_TRUCE_TALKS,
				ThirdPartyEffectTable.CHOICE_LOYAL
			)
		else:
			# passive update to allow transitions “après Y jours”
			ArcStateMachine.update_arc_state(
				arc, relations[A][B], relations[B][A],
				day, rng,
				&"", &""
			)

	# Final metrics
	var final_tension := 0.5 * (relations[A][B].tension + relations[B][A].tension)
	var final_rel := 0.5 * (relations[A][B].relation + relations[B][A].relation)
	var final_trust := 0.5 * (relations[A][B].trust + relations[B][A].trust)

	# Convergence checks (no escalation)
	_assert(final_tension < initial_tension, "tension should decrease (%.1f -> %.1f)" % [initial_tension, final_tension])
	_assert(final_rel > initial_rel, "relation should increase (%.1f -> %.1f)" % [initial_rel, final_rel])

	# Outcome: TRUCE or ALLIANCE (ALLIANCE expected often)
	_assert(arc.state == &"TRUCE" or arc.state == &"ALLIANCE",
		"arc should converge to TRUCE/ALLIANCE, got: %s" % [String(arc.state)]
	)

	# If ALLIANCE, it must satisfy the stability intent
	if arc.state == &"ALLIANCE":
		_assert(final_tension <= 25.0, "ALLIANCE implies low tension (<=25)")
		_assert(final_trust >= 55.0, "ALLIANCE implies trust >=55")
		_assert(final_rel >= 35.0, "ALLIANCE implies relation >=35")


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

### Comment tu l’intègres “en vrai”
- Quand une quête `is_third_party=true` est résolue, tu appelles :
  - `ThirdPartyEffectTable.apply(...)` (MEDIATOR)
  - ou `ThirdPartyEffectTable.apply_for_opportunist(...)` (OPPORTUNIST avec beneficiary/victim)
- Et tu passes aussi une `canonical_arc_action()` au `ArcStateMachine.update_arc_state()` pour que l’arc A↔B “compte” ces événements (peace/hostile).

Si tu veux, prochaine brique logique : une variante de test qui vérifie que **l’opportunisme** crée naturellement un **nouvel arc C↔victim** (via augmentation tension/grievance + seuil).

Moi:
Ok prochaine brique logique : une variante de test qui vérifie que l’opportunisme crée naturellement un nouvel arc C↔victim (via augmentation tension/grievance + seuil

ChatGPT:
Voilà une **variante de test** qui montre que l’**opportunisme** (C raid B pendant que A↔B est “chaud”) peut **créer naturellement un nouvel arc C↔B** via montée **tension/grievance** au-dessus de seuils.

> Le test ne dépend pas de ta logique “choisir C automatiquement”. Il force juste l’event opportuniste (comme si ta sélection l’avait décidé), puis vérifie que l’état de l’arc **C↔B** quitte **NEUTRAL**.

---

## `tests/ThirdPartyOpportunismCreatesArcTest.gd`

```gdscript
extends Node
class_name ThirdPartyOpportunismCreatesArcTest

func _ready() -> void:
	_test_opportunism_creates_new_arc_between_C_and_victim()
	print("\n✅ ThirdPartyOpportunismCreatesArcTest: OK\n")
	get_tree().quit()


func _test_opportunism_creates_new_arc_between_C_and_victim() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 909090

	var A := &"A"
	var B := &"B"
	var C := &"C"

	# -----------------------------
	# Relations world: relations[X][Y] -> FactionRelationScore
	# -----------------------------
	var relations := {}
	relations[A] = {}; relations[B] = {}; relations[C] = {}

	relations[A][B] = FactionRelationScore.new()
	relations[B][A] = FactionRelationScore.new()
	relations[A][C] = FactionRelationScore.new()
	relations[C][A] = FactionRelationScore.new()
	relations[B][C] = FactionRelationScore.new()
	relations[C][B] = FactionRelationScore.new()

	# A<->B : conflit "chaud" (contexte qui motive l'opportunisme)
	relations[A][B].relation = -65; relations[B][A].relation = -60
	relations[A][B].trust = 18;     relations[B][A].trust = 22
	relations[A][B].tension = 75;   relations[B][A].tension = 70
	relations[A][B].grievance = 55; relations[B][A].grievance = 50
	relations[A][B].weariness = 25; relations[B][A].weariness = 22

	# A<->C : plutôt positif (C "profite" pour aider A implicitement)
	relations[A][C].relation = 20; relations[C][A].relation = 18
	relations[A][C].trust = 45;    relations[C][A].trust = 40
	relations[A][C].tension = 10;  relations[C][A].tension = 10
	relations[A][C].grievance = 5; relations[C][A].grievance = 5

	# C<->B : NEUTRAL au départ (cible = victim)
	# Important: tension/grievance pas trop bas sinon ta limite "max_change_ratio" bride trop.
	relations[C][B].relation = -10; relations[B][C].relation = -8
	relations[C][B].trust = 35;     relations[B][C].trust = 38
	relations[C][B].tension = 20;   relations[B][C].tension = 22
	relations[C][B].grievance = 18; relations[B][C].grievance = 16
	relations[C][B].weariness = 10; relations[B][C].weariness = 10

	var initial_cb_tension := 0.5 * (relations[C][B].tension + relations[B][C].tension)
	var initial_cb_rel := 0.5 * (relations[C][B].relation + relations[B][C].relation)

	# -----------------------------
	# Arc states
	# -----------------------------
	var arc_cb := ArcState.new()
	arc_cb.state = &"NEUTRAL"
	arc_cb.lock_until_day = 0
	arc_cb.phase_events = 0
	arc_cb.phase_hostile = 0
	arc_cb.phase_peace = 0
	arc_cb.stable_low_tension_days = 0
	arc_cb.stable_high_trust_days = 0

	# -----------------------------
	# Opportunist events: C raids B (beneficiary = A, victim = B)
	# -----------------------------
	var opportunism_days := {2:true, 4:true, 6:true}

	for day in range(1, 21):
		# counters (même les jours sans event)
		ArcStateMachine.tick_day_for_pair(arc_cb, relations[C][B], relations[B][C])

		if opportunism_days.has(day):
			ThirdPartyEffectTable.apply_for_opportunist(
				relations,
				A,  # beneficiary
				B,  # victim
				C,  # third party
				&"OPPORTUNIST",
				&"tp.opportunist.raid",
				ThirdPartyEffectTable.CHOICE_LOYAL,
				0.80  # max_change_ratio (volontairement permissif pour franchir le seuil)
			)

			# Feed the state machine with a canonical hostile action
			ArcStateMachine.update_arc_state(
				arc_cb,
				relations[C][B],
				relations[B][C],
				day,
				rng,
				ArcDecisionUtil.ARC_RAID,
				ThirdPartyEffectTable.CHOICE_LOYAL
			)
		else:
			ArcStateMachine.update_arc_state(
				arc_cb,
				relations[C][B],
				relations[B][C],
				day,
				rng,
				&"", &""
			)

	# -----------------------------
	# Assertions: C<->B should have escalated to at least RIVALRY/CONFLICT
	# -----------------------------
	var final_cb_tension := 0.5 * (relations[C][B].tension + relations[B][C].tension)
	var final_cb_rel := 0.5 * (relations[C][B].relation + relations[B][C].relation)

	_assert(final_cb_tension > initial_cb_tension, "C<->B tension should increase (%.1f -> %.1f)" % [initial_cb_tension, final_cb_tension])
	_assert(final_cb_rel < initial_cb_rel, "C<->B relation should decrease (%.1f -> %.1f)" % [initial_cb_rel, final_cb_rel])

	_assert(
		arc_cb.state != &"NEUTRAL" and arc_cb.state != &"ALLIANCE" and arc_cb.state != &"TRUCE",
		"opportunism should create a hostile arc state for C<->B (got %s)" % [String(arc_cb.state)]
	)

	# Optionnel: si tu veux être plus strict (selon tes seuils)
	# _assert(arc_cb.state == &"RIVALRY" or arc_cb.state == &"CONFLICT" or arc_cb.state == &"WAR",
	# 	"expected RIVALRY/CONFLICT/WAR for C<->B, got %s" % [String(arc_cb.state)]
	# )


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

### Notes importantes
- J’ai mis `max_change_ratio = 0.80` **dans le test** pour franchir les seuils rapidement et éviter une fragilité liée à ton clamp (sinon il faut davantage d’events / plus de jours).
- Si ton `update_arc_state()` ne transitionne pas depuis `NEUTRAL` sur simple hausse de tension/grievance, adapte l’assert “strict” (ou ajoute une règle “si hostile event alors NEUTRAL→RIVALRY”).

Si tu veux, je te fais une **2e variante** de ce test qui vérifie aussi que **A↔C** s’améliore (beneficiary likes C) et que **A↔B** n’est pas directement modifié par l’opportunisme (sauf si tu l’ajoutes volontairement).

Moi:
fais une 2e variante de ce test qui vérifie aussi que A↔C s’améliore (beneficiary likes C) et que A↔B n’est pas directement modifié par l’opportunisme (sauf si tu l’ajoutes volontairement).

ChatGPT:
Voici une **2e variante** du test opportunisme qui vérifie en plus :

1) **A↔C s’améliore** (beneficiary likes C)  
2) **A↔B ne change pas** à cause de l’opportunisme (on tolère uniquement de très petites variations dues à ton clamp/arrondis, sinon 0)

> Dans notre table actuelle `tp.opportunist.raid / LOYAL`, on a bien un petit bonus **AC relation +4**.  
> Et on n’applique **aucun delta AB** (beneficiary↔victim) dans `apply_for_opportunist()` sauf si tu ajoutes volontairement des effets `{"pair":"BC", ...}` dans la table.

---

## `tests/ThirdPartyOpportunismSideEffectsTest.gd`

```gdscript
extends Node
class_name ThirdPartyOpportunismSideEffectsTest

func _ready() -> void:
	_test_opportunism_improves_A_C_and_does_not_touch_A_B()
	print("\n✅ ThirdPartyOpportunismSideEffectsTest: OK\n")
	get_tree().quit()


func _test_opportunism_improves_A_C_and_does_not_touch_A_B() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 919191

	var A := &"A"
	var B := &"B"
	var C := &"C"

	# -----------------------------
	# Relations world
	# -----------------------------
	var relations := {}
	relations[A] = {}; relations[B] = {}; relations[C] = {}

	relations[A][B] = FactionRelationScore.new()
	relations[B][A] = FactionRelationScore.new()
	relations[A][C] = FactionRelationScore.new()
	relations[C][A] = FactionRelationScore.new()
	relations[B][C] = FactionRelationScore.new()
	relations[C][B] = FactionRelationScore.new()

	# A<->B : conflict hot, but should NOT be modified by opportunism effects
	relations[A][B].relation = -65; relations[B][A].relation = -60
	relations[A][B].trust = 18;     relations[B][A].trust = 22
	relations[A][B].tension = 75;   relations[B][A].tension = 70
	relations[A][B].grievance = 55; relations[B][A].grievance = 50
	relations[A][B].weariness = 25; relations[B][A].weariness = 22

	# A<->C : already friendly, should improve a bit (beneficiary likes C)
	relations[A][C].relation = 20; relations[C][A].relation = 18
	relations[A][C].trust = 45;    relations[C][A].trust = 40
	relations[A][C].tension = 10;  relations[C][A].tension = 10
	relations[A][C].grievance = 5; relations[C][A].grievance = 5

	# C<->B : neutral-ish, will escalate
	relations[C][B].relation = -10; relations[B][C].relation = -8
	relations[C][B].trust = 35;     relations[B][C].trust = 38
	relations[C][B].tension = 20;   relations[B][C].tension = 22
	relations[C][B].grievance = 18; relations[B][C].grievance = 16
	relations[C][B].weariness = 10; relations[B][C].weariness = 10

	# Baselines to compare
	var ab_before := _snapshot(relations[A][B], relations[B][A])
	var ac_before := _snapshot(relations[A][C], relations[C][A])

	# Arc C<->B (target of opportunism)
	var arc_cb := ArcState.new()
	arc_cb.state = &"NEUTRAL"

	# Events: C raids B (beneficiary=A)
	var opportunism_days := {2:true, 4:true, 6:true}

	for day in range(1, 21):
		ArcStateMachine.tick_day_for_pair(arc_cb, relations[C][B], relations[B][C])

		if opportunism_days.has(day):
			ThirdPartyEffectTable.apply_for_opportunist(
				relations,
				A, B, C,
				&"OPPORTUNIST",
				&"tp.opportunist.raid",
				ThirdPartyEffectTable.CHOICE_LOYAL,
				0.80
			)

			ArcStateMachine.update_arc_state(
				arc_cb, relations[C][B], relations[B][C],
				day, rng,
				ArcDecisionUtil.ARC_RAID,
				ThirdPartyEffectTable.CHOICE_LOYAL
			)
		else:
			ArcStateMachine.update_arc_state(
				arc_cb, relations[C][B], relations[B][C],
				day, rng,
				&"", &""
			)

	# After
	var ab_after := _snapshot(relations[A][B], relations[B][A])
	var ac_after := _snapshot(relations[A][C], relations[C][A])

	# -----------------------------
	# Assertions 1) A<->C improves
	# -----------------------------
	_assert(ac_after["rel_mean"] > ac_before["rel_mean"], "A<->C relation should improve (%.1f -> %.1f)" % [ac_before["rel_mean"], ac_after["rel_mean"]])

	# Optionnel: trust peut rester stable, mais tu peux aussi le booster si tu veux.
	# _assert(ac_after["trust_mean"] >= ac_before["trust_mean"], "A<->C trust should not decrease")

	# -----------------------------
	# Assertions 2) A<->B not modified by opportunism table
	# -----------------------------
	# On attend 0 variation, mais on tolère +/-1 en cas d'arrondi/clamp
	var eps := 1.0

	_assert(abs(ab_after["rel_mean"] - ab_before["rel_mean"]) <= eps, "A<->B relation should not change (%.1f -> %.1f)" % [ab_before["rel_mean"], ab_after["rel_mean"]])
	_assert(abs(ab_after["trust_mean"] - ab_before["trust_mean"]) <= eps, "A<->B trust should not change (%.1f -> %.1f)" % [ab_before["trust_mean"], ab_after["trust_mean"]])
	_assert(abs(ab_after["tension_mean"] - ab_before["tension_mean"]) <= eps, "A<->B tension should not change (%.1f -> %.1f)" % [ab_before["tension_mean"], ab_after["tension_mean"]])
	_assert(abs(ab_after["griev_mean"] - ab_before["griev_mean"]) <= eps, "A<->B grievance should not change (%.1f -> %.1f)" % [ab_before["griev_mean"], ab_after["griev_mean"]])

	# Sanity: C<->B should have escalated
	_assert(arc_cb.state != &"NEUTRAL", "C<->B arc should no longer be NEUTRAL after opportunism (got %s)" % String(arc_cb.state))


func _snapshot(xy: FactionRelationScore, yx: FactionRelationScore) -> Dictionary:
	return {
		"rel_mean": 0.5 * (xy.relation + yx.relation),
		"trust_mean": 0.5 * (xy.trust + yx.trust),
		"tension_mean": 0.5 * (xy.tension + yx.tension),
		"griev_mean": 0.5 * (xy.grievance + yx.grievance),
	}

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

### Si tu ajoutes volontairement un effet AB plus tard
Si tu décides que “C raid B” augmente la haine A↔B (ex: propagande, blame), tu ajoutes un effet `{"pair":"BC", ...}` dans la table opportuniste (dans `apply_for_opportunist`, `BC = beneficiary↔victim`).  
À ce moment-là tu modifies ce test pour **attendre** un delta AB au lieu de “0”.

Si tu veux, je peux aussi te proposer une règle “si third party opportunist aidait A, alors B en veut davantage à A (même sans preuve)” en mettant juste `tension +3` et `grievance +2` sur AB.

Moi:
Ok 
proposer une règle “si third party opportunist aidait A, alors B en veut davantage à A (même sans preuve)” en mettant juste tension +3 et grievance +2 sur AB

ChatGPT:
Voici une règle simple (et très “vivante”) : **quand C fait un raid opportuniste contre B pendant un conflit A↔B, B soupçonne A d’être derrière**, donc **B en veut davantage à A** même sans preuve.

### Règle (V1)
Sur un évènement `OPPORTUNIST / tp.opportunist.raid / LOYAL` :
- appliquer aussi sur **A↔B** :
  - `tension +3`
  - `grievance +2`
- (optionnel) si tu veux une légère “paranoïa” : `trust -1` côté B→A uniquement

---

## Patch dans `ThirdPartyEffectTable.gd`

Dans `EFFECTS[&"OPPORTUNIST"][&"tp.opportunist.raid"][LOYAL]`, ajoute ces 2 lignes avec `pair:"BC"` (dans notre convention `apply_for_opportunist()` : `"BC" = beneficiary↔victim` donc **A↔B**).

```gdscript
&"OPPORTUNIST": {
	&"tp.opportunist.raid": {
		CHOICE_LOYAL: [
			{"pair":"AB","field":"tension","delta":+14}, {"pair":"AB","field":"grievance","delta":+12},
			{"pair":"AB","field":"relation","delta":-12},{"pair":"AB","field":"trust","delta":-8},
			{"pair":"AC","field":"relation","delta":+4},

			# NEW: suspicion spillover (beneficiary A, victim B) => affects A<->B
			{"pair":"BC","field":"tension","delta":+3},
			{"pair":"BC","field":"grievance","delta":+2},
		],
		...
	}
}
```

### Comment ça se lit
- `"AB"` = `C↔victim` (C↔B) : escalade directe contre la victime
- `"AC"` = `beneficiary↔C` (A↔C) : A apprécie l’aide de C
- `"BC"` = `beneficiary↔victim` (A↔B) : **B soupçonne A**, donc A↔B se dégrade

---

## (Optionnel) suspicion asymétrique (B→A seulement)
Si tu veux que ce soit **uniquement** B qui accuse A (pas forcément réciproque), on peut ajouter un helper dédié (au lieu d’utiliser `_apply_pair` qui applique aux deux sens).

Dis-moi si tu veux ce mode “asymétrique”, je te donne la mini-fonction `apply_one_way(relations, from_id, to_id, field, delta)` et on patch en 2 lignes.

Moi:
Je veux que ce soit asymetrique

ChatGPT:
Parfait — on garde la table d’effets, mais on ajoute une **option “one-way”** pour pouvoir appliquer un delta **uniquement dans un sens** (ici **victim → beneficiary**, donc **B→A**).

## 1) Micro-patch `ThirdPartyEffectTable.gd` : helper one-way + support `dir`

Ajoute ce helper (à côté de `_apply_pair`) :

```gdscript
static func _apply_one_way(relations: Dictionary, from_id: StringName, to_id: StringName, field: String, delta: float, max_change_ratio: float) -> void:
	if not relations.has(from_id): return
	if not relations[from_id].has(to_id): return
	var r: FactionRelationScore = relations[from_id][to_id]
	_apply_field(r, field, delta, max_change_ratio)
```

Puis, dans `apply_for_opportunist(...)`, remplace la boucle `for e in effects:` par une version qui supporte `dir` :

```gdscript
for e in effects:
	var pair := String(e.get("pair",""))
	var field := String(e.get("field",""))
	var delta := float(e.get("delta", 0.0))
	var dir := String(e.get("dir","")) # NEW (optional)

	# NEW: direction spéciale (asymétrique)
	if dir == "V2BEN": # victim -> beneficiary
		_apply_one_way(relations, victim_id, beneficiary_id, field, delta, max_change_ratio)
		continue
	if dir == "BEN2V": # beneficiary -> victim (si un jour tu veux)
		_apply_one_way(relations, beneficiary_id, victim_id, field, delta, max_change_ratio)
		continue

	# comportement actuel (symétrique) inchangé
	match pair:
		"AB":
			_apply_pair(relations, c_id, victim_id, field, delta, max_change_ratio)
		"AC":
			_apply_pair(relations, beneficiary_id, c_id, field, delta, max_change_ratio)
		"BC":
			_apply_pair(relations, beneficiary_id, victim_id, field, delta, max_change_ratio)
		_:
			pass
```

✅ En prod, si tu n’utilises pas `dir`, rien ne change.

---

## 2) Règle “suspicion” asymétrique : **B→A** uniquement

Dans `EFFECTS[OPPORTUNIST][tp.opportunist.raid][LOYAL]`, ajoute ces entrées (au lieu de la version symétrique) :

```gdscript
# Suspicion spillover (asym): victim(B) -> beneficiary(A)
{"dir":"V2BEN","field":"tension","delta":+3},
{"dir":"V2BEN","field":"grievance","delta":+2},

# (optionnel) paranoïa légère
# {"dir":"V2BEN","field":"trust","delta":-1},
```

> Pas besoin de `pair` ici : `dir` suffit.

---

## 3) Impact sur tes tests existants
Le test `ThirdPartyOpportunismSideEffectsTest.gd` (celui qui vérifiait “A↔B ne bouge pas”) va maintenant **échouer** — et c’est normal.

La nouvelle assertion attendue devient :
- **B→A** : `tension +` et `grievance +`
- **A→B** : inchangé (ou quasi inchangé)

Si tu veux, je te donne le patch exact du test dans le prochain message.

Moi:
donne le patch exact du test dans le prochain message.

ChatGPT:
Voici le **patch exact** pour `tests/ThirdPartyOpportunismSideEffectsTest.gd` afin de refléter la suspicion **asymétrique B→A** :

- On **ne compare plus la moyenne A↔B**.
- On vérifie :
  - `B→A` : **tension↑** et **grievance↑** (au moins +1)
  - `A→B` : **inchangé** (±1)

> Hypothèse : tu appliques la suspicion via `dir:"V2BEN"` avec `tension +3` et `grievance +2` pour chaque event opportuniste LOYAL, donc sur 3 events ça fera typiquement +6..+9 (clamp/ratio peut limiter un peu).

---

## Patch (diff logique) dans le test

### 1) Remplace le snapshot AB mean par des snapshots directionnels

**Avant :**
```gdscript
var ab_before := _snapshot(relations[A][B], relations[B][A])
...
var ab_after := _snapshot(relations[A][B], relations[B][A])
...
var eps := 1.0
_assert(abs(ab_after["tension_mean"] - ab_before["tension_mean"]) <= eps, ...)
_assert(abs(ab_after["griev_mean"] - ab_before["griev_mean"]) <= eps, ...)
```

**Après :**
```gdscript
var ab_dir_before := _snapshot_dir(relations[A][B], relations[B][A])
...
var ab_dir_after := _snapshot_dir(relations[A][B], relations[B][A])
```

Et ajoute ce helper en bas du fichier (à côté de `_snapshot`) :

```gdscript
func _snapshot_dir(a_to_b: FactionRelationScore, b_to_a: FactionRelationScore) -> Dictionary:
	return {
		"A2B_tension": float(a_to_b.tension),
		"A2B_griev": float(a_to_b.grievance),
		"A2B_trust": float(a_to_b.trust),
		"A2B_rel": float(a_to_b.relation),

		"B2A_tension": float(b_to_a.tension),
		"B2A_griev": float(b_to_a.grievance),
		"B2A_trust": float(b_to_a.trust),
		"B2A_rel": float(b_to_a.relation),
	}
```

---

### 2) Remplace la section “A↔B not modified” par “B→A augmente, A→B stable”

Cherche cette section :

```gdscript
# Assertions 2) A<->B not modified by opportunism table
# On attend 0 variation, mais on tolère +/-1 en cas d'arrondi/clamp
var eps := 1.0

_assert(abs(ab_after["rel_mean"] - ab_before["rel_mean"]) <= eps, ...)
_assert(abs(ab_after["trust_mean"] - ab_before["trust_mean"]) <= eps, ...)
_assert(abs(ab_after["tension_mean"] - ab_before["tension_mean"]) <= eps, ...)
_assert(abs(ab_after["griev_mean"] - ab_before["griev_mean"]) <= eps, ...)
```

**Remplace par :**
```gdscript
# Assertions 2) Suspicion asymétrique: B->A augmente, A->B reste stable
var eps := 1.0

# A->B doit rester stable (±1)
_assert(abs(ab_dir_after["A2B_tension"] - ab_dir_before["A2B_tension"]) <= eps,
	"A->B tension should remain stable (%.1f -> %.1f)" % [ab_dir_before["A2B_tension"], ab_dir_after["A2B_tension"]])

_assert(abs(ab_dir_after["A2B_griev"] - ab_dir_before["A2B_griev"]) <= eps,
	"A->B grievance should remain stable (%.1f -> %.1f)" % [ab_dir_before["A2B_griev"], ab_dir_after["A2B_griev"]])

# B->A doit monter (au moins +1) en tension/grievance
_assert(ab_dir_after["B2A_tension"] >= ab_dir_before["B2A_tension"] + 1.0,
	"B->A tension should increase due to suspicion (%.1f -> %.1f)" % [ab_dir_before["B2A_tension"], ab_dir_after["B2A_tension"]])

_assert(ab_dir_after["B2A_griev"] >= ab_dir_before["B2A_griev"] + 1.0,
	"B->A grievance should increase due to suspicion (%.1f -> %.1f)" % [ab_dir_before["B2A_griev"], ab_dir_after["B2A_griev"]])
```

> Si ton clamp est très strict, tu peux mettre `+0.5` au lieu de `+1.0`, mais avec 3 events, tu devrais largement dépasser +1.

---

### 3) Où placer les nouvelles snapshots

Dans ton test, remplace ces lignes :

```gdscript
var ab_before := _snapshot(relations[A][B], relations[B][A])
var ac_before := _snapshot(relations[A][C], relations[C][A])
...
var ab_after := _snapshot(relations[A][B], relations[B][A])
var ac_after := _snapshot(relations[A][C], relations[C][A])
```

Par :

```gdscript
var ab_dir_before := _snapshot_dir(relations[A][B], relations[B][A])
var ac_before := _snapshot(relations[A][C], relations[C][A])
...
var ab_dir_after := _snapshot_dir(relations[A][B], relations[B][A])
var ac_after := _snapshot(relations[A][C], relations[C][A])
```

(et garde la partie A↔C identique).

---

Si tu veux, je peux aussi ajouter une assertion bonus : **B→A trust baisse** (si tu actives le `trust -1` optionnel).

Moi:
ajouter une assertion bonus : B→A trust baisse

ChatGPT:
Voici le patch bonus **exact** à ajouter au même test (`ThirdPartyOpportunismSideEffectsTest.gd`) pour vérifier que **B→A trust baisse**, *si* tu as activé l’option `{"dir":"V2BEN","field":"trust","delta":-1}` dans ta table.

### À ajouter juste après les assertions “B→A tension/grievance augmente”
Ajoute ceci :

```gdscript
# Bonus: si tu actives la paranoïa (trust -1), alors B->A trust doit baisser
_assert(ab_dir_after["B2A_trust"] <= ab_dir_before["B2A_trust"] - 1.0,
	"B->A trust should decrease due to suspicion (%.1f -> %.1f)" % [ab_dir_before["B2A_trust"], ab_dir_after["B2A_trust"]])
```

### Si tu veux que le test passe même quand tu n’actives PAS le trust -1
Remplace par une version “soft” :

```gdscript
# Bonus optionnel: trust baisse seulement si la règle est active.
# Si la règle n'est pas active, trust devrait rester stable (±1).
var trust_delta := ab_dir_after["B2A_trust"] - ab_dir_before["B2A_trust"]
_assert(trust_delta <= 0.0 + 1.0, "B->A trust should not increase unexpectedly (delta=%.1f)" % trust_delta)
```

Mais si tu m’as dit “ajouter l’assertion bonus”, je pars sur la version stricte (la première).

Moi:
Tu dis
pour vérifier que B→A trust baisse, si tu as activé l’option

Comment activer l'option?

ChatGPT:
Dans le design qu’on a posé, “activer l’option” = **ajouter (ou décommenter) l’effet dans la table** `ThirdPartyEffectTable.gd`. Il n’y a pas de flag magique ailleurs : c’est data-driven.

## Option 1 — Le plus simple : ajouter la ligne dans `EFFECTS`
Dans `ThirdPartyEffectTable.gd`, à l’endroit où tu as mis la suspicion asymétrique `dir:"V2BEN"` pour `OPPORTUNIST / tp.opportunist.raid / LOYAL`, tu ajoutes (ou décommentes) :

```gdscript
{"dir":"V2BEN","field":"trust","delta":-1},
```

Exemple complet :

```gdscript
CHOICE_LOYAL: [
	# ... effets C<->victim et A<->C ...

	{"dir":"V2BEN","field":"tension","delta":+3},
	{"dir":"V2BEN","field":"grievance","delta":+2},
	{"dir":"V2BEN","field":"trust","delta":-1}, # <-- active la paranoïa
],
```

✅ C’est tout : dès que cette entrée est dans la table, `apply_for_opportunist()` la lit et l’applique en one-way **B→A**.

## Option 2 — Via un paramètre (si tu veux toggle runtime)
Si tu veux pouvoir l’activer/désactiver selon ton “mode monde”, tu peux faire un micro-patch :
- ajouter `params: Dictionary = {}` à `apply_for_opportunist(...)`
- et conditionner l’ajout de cet effet “trust -1” via `params.get("suspicion_trust", false)`.

Mais pour une V1, l’option 1 suffit largement.

Si tu me dis “je veux un toggle runtime”, je te donne le micro-patch exact aussi.

Moi:
Non
Je voudrais que tu me dise ce que tu penses de cr qu'on a mis en place et est ce que tu as ded idées pour ameliorer les choses hors La persistance et la stabilité des métriques

ChatGPT:
Globalement, ce qu’on a construit est déjà **très “système complet V1”** :  
- **profils** (axes + personnalité) → **relations** (multi-métriques) → **arcs** (états + transitions + cooldowns) → **offers** (QuestPool)  
- + la **3rd party** qui casse l’escalade binaire  
- + le pont **Goals ↔ Arcs** pour éviter le “hors-sol”.

Si je cherche ce qui améliorerait vraiment le résultat **sans parler persistance/stabilité**, voilà les meilleures idées.

---

## 1) “Knowledge / rumeurs” (information imparfaite)
Aujourd’hui une faction “voit” les relations/métriques comme si elles étaient parfaites.  
Ajoute une notion de **connaissance** :
- “B soupçonne A” (suspicion) peut être basé sur des rumeurs, pas sur vérité.
- Une action “investigate / proof” peut convertir rumeur → fait (et changer les deltas).

Effet : tu obtiens des quêtes “preuve/espionnage” super naturelles, et l’opportunisme/propagande devient un vrai gameplay.

---

## 2) Casus belli + légitimité (political capital)
Tu as déjà “grievance/tension”. Mais il manque un “**droit moral/politique**” de faire la guerre :
- `casus_belli_strength` (0..100) ou `legitimacy_cost`
- déclarer WAR sans casus fort coûte plus (points, trust interne, réputation), et génère plus de **médiation**.

Effet : les escalades “gratuites” diminuent, et les arcs deviennent plus plausibles.

---

## 3) Traités/engagements explicites (pas juste relation)
TRUCE/ALLIANCE ne devrait pas être seulement un état :  
Crée un mini objet “**Treaty**” dans l’ArcState (durée, clauses, pénalités).
- ex: TRUCE 20 jours, clause “no raids”, si violée → gros spike grievance + perte de trust chez les tiers.

Effet : tu fais émerger “trahison”, “incidents frontaliers”, “garanties”, etc.

---

## 4) Objectifs de guerre (war aims) + conditions de sortie
WAR sans “but”, ça boucle. Ajoute une cible :
- `war_aim`: “punish”, “take_land”, “destroy_army”, “install_puppet”, “tribute”
- et une condition de sortie liée au but (réussite partielle possible).

Effet : tes transitions WAR → TRUCE/RESOLVED deviennent mécaniquement motivées.

---

## 5) Coalitions/blocs (multi-paires mais lisibles)
La 3rd party est un bon début. Une étape simple au-dessus :
- un “bloc” (liste de factions) **temporaire** autour d’un conflit (ex: coalition anti-hégémonique),
- avec 1–2 quêtes “joint operation” (pas besoin d’un arc à 3 complet).

Effet : le monde se structure, et tu obtiens naturellement alliances/fusions.

---

## 6) “Domestic pressure” (politique interne)
Même sans sim interne complexe, un scaler suffit :
- `internal_stability` ou `war_support`
- la guerre longue baisse le support → pousse TRUCE/REPARATIONS même si l’ennemi est détesté.

Effet : sortie de guerre organique + quêtes “maintenir l’ordre / propaganda / appease nobles”.

---

## 7) UX : journal d’arc côté joueur (résumé + raisons)
Tes systèmes vont produire des comportements subtils. Il faut que le joueur voie :
- “Pourquoi cette offer existe ?” (hotness, suspicion, médiation, opportunisme)
- un **résumé en 2 lignes** par paire A↔B (“3 raids récents, suspicion élevée, médiation proposée par C”).

Effet : le système paraît intelligent, pas arbitraire.

---

## 8) Variété des offers par “stake” (pas que combat/diplo)
Tu as déjà les types, mais tu peux renforcer :
- “stakes” → détermine le **genre** : otages / artefacts / famine / frontière / ressources / sanctuaire profané.
- et la 3rd party peut offrir “garantie / arbitrage / commerce”.

Effet : la guerre devient aussi logistique, morale, économique.

---

## 9) Économie : inflation narrative & rareté
Tu as escrow/or/budget. Ajoute une règle “rare” :
- si une faction est pauvre → elle propose plus souvent des quêtes **non-monnayées** (faveurs, accès, traités, artefacts, influence).
- inversement, riche → paye plus, mais attire opportunistes.

Effet : le monde raconte l’économie, pas juste “gold ↑”.

---

## 10) “Failure modes” intéressants
Aujourd’hui, un échec est souvent “rien”. Donne-lui une conséquence :
- LOYAL/NEUTRAL/TRAITOR + SUCCESS/FAILURE
- ex: médiation échoue → tension↑ mais trust envers C peut ↓ (“médiateur incompétent”).

Effet : tes quêtes nourrissent vraiment le monde.

---

### Ce qui me semble manquer “en priorité”
Si je ne dois en choisir que 3 pour une V1+ :
1) **Traités/clauses** (TRUCE/ALLIANCE deviennent concrets)  
2) **War aims + sortie** (sinon WAR peut tourner longtemps)  
3) **Knowledge/rumeurs** (ça rend les offers à 3 factions incroyablement naturelles)

Si tu veux, je peux te proposer un mini schéma de données **Treaty** (10 champs max) + comment il s’intègre à `ArcStateMachine.update_arc_state()` et aux deltas (violation/expiration).

Moi:
Ok 
proposer un mini schéma de données Treaty (10 champs max) + comment il s’intègre à ArcStateMachine.update_arc_state() et aux deltas (violation/expiration).

ChatGPT:
Voici une proposition **Treaty V1** (≤10 champs) + l’intégration **très simple** dans `ArcStateMachine.update_arc_state()` et dans l’application des deltas (violation/expiration).

---

## 1) Schéma de données `Treaty` (10 champs max)

```gdscript
# Treaty.gd
class_name Treaty
extends RefCounted

var type: StringName = &"TRUCE"          # TRUCE | ALLIANCE | TRADE_PACT | VASSALAGE (plus tard)
var start_day: int = 0
var end_day: int = 0                    # expiration dure
var cooldown_after_end_days: int = 20   # pair_lock_days post-traité

# Clauses (bitmask) : très compact et facile à tester
const CLAUSE_NO_RAID    := 1 << 0
const CLAUSE_NO_SABOTAGE:= 1 << 1
const CLAUSE_NO_WAR     := 1 << 2
const CLAUSE_OPEN_TRADE := 1 << 3
var clauses: int = 0

# Enforcement / sanctions
var violation_score: float = 0.0        # monte à chaque violation
var violation_threshold: float = 1.0    # si dépassé => traité cassé / pénalités

# “Garants” (optionnel) : troisième partie qui a de l’influence
var guarantor_id: StringName = &""      # ex: C médiateur (ou vide)
```

✅ 9 champs, extensible sans casser.

---

## 2) Intégration dans `ArcState`

Ajoute un champ dans `ArcState.gd` :

```gdscript
var treaty: Treaty = null
```

---

## 3) Définir les violations (quelles actions cassent quelles clauses)

Dans `ArcStateMachine.gd` :

```gdscript
static func action_violates_clauses(action: StringName, clauses: int) -> bool:
	if (clauses & Treaty.CLAUSE_NO_RAID) != 0 and action == ArcDecisionUtil.ARC_RAID:
		return true
	if (clauses & Treaty.CLAUSE_NO_SABOTAGE) != 0 and action == ArcDecisionUtil.ARC_SABOTAGE:
		return true
	if (clauses & Treaty.CLAUSE_NO_WAR) != 0 and action == ArcDecisionUtil.ARC_DECLARE_WAR:
		return true
	return false

static func violation_severity(action: StringName) -> float:
	match action:
		ArcDecisionUtil.ARC_DECLARE_WAR: return 1.2
		ArcDecisionUtil.ARC_SABOTAGE:    return 0.6
		ArcDecisionUtil.ARC_RAID:        return 0.45
		_:                               return 0.3
```

---

## 4) Deltas standard en cas de violation (et côté garant)

Toujours dans `ArcStateMachine.gd` (ou un util) :

```gdscript
static func apply_treaty_violation_deltas(
	rel_ab: FactionRelationScore,
	rel_ba: FactionRelationScore,
	sev: float
) -> void:
	# AB et BA (symétrique) : trust s'effondre, tension/grievance montent
	rel_ab.trust = int(clampi(rel_ab.trust - int(20.0 * sev), 0, 100))
	rel_ba.trust = int(clampi(rel_ba.trust - int(20.0 * sev), 0, 100))

	rel_ab.tension = int(clampi(rel_ab.tension + int(15.0 * sev), 0, 100))
	rel_ba.tension = int(clampi(rel_ba.tension + int(15.0 * sev), 0, 100))

	rel_ab.grievance = int(clampi(rel_ab.grievance + int(18.0 * sev), 0, 100))
	rel_ba.grievance = int(clampi(rel_ba.grievance + int(18.0 * sev), 0, 100))

	rel_ab.relation = int(clampi(rel_ab.relation - int(12.0 * sev), -100, 100))
	rel_ba.relation = int(clampi(rel_ba.relation - int(12.0 * sev), -100, 100))
```

Et si tu veux que le **garant** perde aussi en “crédibilité” (optionnel mais cool) :
- tu appliques une petite baisse de trust vers le garant (A→C et B→C), mais ça se fait plutôt dans une couche “WorldRelations” où tu as accès aux 3 ids.

---

## 5) Intégration dans `update_arc_state()`

### A) Expiration automatique
Au début de `update_arc_state()` :

```gdscript
# 0) Treaty expiration check
if arc_state.treaty != null and day >= arc_state.treaty.end_day:
	# traité expiré => lock post-traité
	arc_state.lock_until_day = max(arc_state.lock_until_day, day + arc_state.treaty.cooldown_after_end_days)
	arc_state.treaty = null

	# (optionnel) après expiration, tu peux revenir vers NEUTRAL/TRUCE selon tes métriques
	# arc_state.state = &"NEUTRAL"
```

### B) Détection de violation si un action “hostile” arrive pendant un traité
Juste après avoir reçu `action` (ou après avoir déterminé `canonical_action`) :

```gdscript
# 1) Treaty violation check (if treaty active)
if arc_state.treaty != null and action != &"":
	if action_violates_clauses(action, arc_state.treaty.clauses):
		var sev := violation_severity(action)
		arc_state.treaty.violation_score += sev

		apply_treaty_violation_deltas(rel_ab, rel_ba, sev)

		# Si trop de violations => traité cassé
		if arc_state.treaty.violation_score >= arc_state.treaty.violation_threshold:
			arc_state.lock_until_day = max(arc_state.lock_until_day, day + arc_state.treaty.cooldown_after_end_days)
			arc_state.treaty = null
			# Le state remonte vers CONFLICT (ou WAR si action=DECLARE_WAR)
			arc_state.state = &"CONFLICT" if action != ArcDecisionUtil.ARC_DECLARE_WAR else &"WAR"
			arc_state.phase_hostile += 1
			return
		# Sinon, on garde le traité mais on “enregistre” le choc
		arc_state.phase_hostile += 1
		return
```

> `return` est important : une violation est déjà un événement “majeur”, inutile de faire en plus d’autres transitions ce tick.

---

## 6) Quand créer un traité (TRUCE/ALLIANCE)
Deux options :
- quand l’arc passe en état `TRUCE` → créer `Treaty(TRUCE)`
- quand l’arc passe `ALLIANCE` → créer `Treaty(ALLIANCE)`

Ex :

```gdscript
static func create_truce_treaty(day: int, guarantor_id: StringName = &"") -> Treaty:
	var t := Treaty.new()
	t.type = &"TRUCE"
	t.start_day = day
	t.end_day = day + 20
	t.cooldown_after_end_days = 25
	t.clauses = Treaty.CLAUSE_NO_RAID | Treaty.CLAUSE_NO_SABOTAGE | Treaty.CLAUSE_NO_WAR
	t.violation_score = 0.0
	t.violation_threshold = 1.2
	t.guarantor_id = guarantor_id
	return t
```

Et dans ta transition vers TRUCE (dans `update_arc_state()` quand tes conditions sont remplies) :

```gdscript
arc_state.state = &"TRUCE"
arc_state.treaty = create_truce_treaty(day, arc_state.last_mediator_id if arc_state.has("last_mediator_id") else &"")
arc_state.lock_until_day = max(arc_state.lock_until_day, day + 10) # lock court “anti-churn”
```

---

## 7) Pourquoi ça marche bien
- TRUCE/ALLIANCE deviennent **des engagements** (pas juste un label).
- La **violation** est un événement clair, avec **conséquences mécaniques**.
- La **fin** (expiration) déclenche un **pair_lock** long, ce qui évite “incident→trêve→incident” en boucle.
- Facile à brancher sur tes offers : “enforce treaty”, “investigate violator”, “mediate breach”.

---

Si tu veux, prochaine brique logique : 2–3 offres “treaty enforcement” + comment elles modifient `violation_score` (ex : LOYAL baisse violation_score ou prolonge end_day, TRAITOR falsifie preuves et augmente violation_score).

Moi:
logique : 2–3 offres “treaty enforcement” + comment elles modifient violation_score (ex : LOYAL baisse violation_score ou prolonge end_day, TRAITOR falsifie preuves et augmente violation_score).

ChatGPT:
Voici 3 offres “**treaty enforcement**” très simples (mais super riches) + un mapping clair des effets sur `Treaty.violation_score` / `end_day` / relations.

## Contexte standard (dans `QuestInstance.context`)
Pour toutes ces offres :
```gdscript
"is_treaty_enforcement": true
"treaty_type": &"TRUCE" | &"ALLIANCE"
"pair_key": primary_pair_key
"side_a_faction_id": A
"side_b_faction_id": B
"guarantor_id": C (optionnel)
"treaty_end_day": treaty.end_day
"treaty_violation_score": treaty.violation_score
"treaty_violation_threshold": treaty.violation_threshold
```

---

# 1) Offer: “Investigate breach” (preuve / espionnage)
### Quand la générer
- `treaty.violation_score > 0.3` **et** il y a eu une action suspecte récente (via ArcNotebook heat ou “last_violation_action” si tu la stockes)

### Variants (2-3 templates)
- stealth: infiltrate border post / recover orders
- diplomacy: interrogate witnesses in neutral city
- retrieval: seize “proof artifact” (letters/seals)

### Effets (sur résolution)
**LOYAL** (preuve réelle, stabilise)
- `treaty.violation_score -= 0.35`
- `treaty.end_day += 2` (petite prolongation, “on clarifie”)
- `A↔B trust +4`, `tension -3`

**NEUTRAL** (rapport flou)
- `treaty.violation_score -= 0.15`
- `treaty.end_day += 0`
- `trust +1`

**TRAITOR** (falsifie preuves pour faire monter)
- `treaty.violation_score += 0.40`
- `A↔B tension +4`, `trust -4`
- (optionnel) si garant C : `A→C trust -3` et/ou `B→C trust -3` quand la fraude est découverte plus tard

---

# 2) Offer: “Enforce ceasefire” (patrouille / escorte / crackdown)
### Quand la générer
- traité actif + “incident mineur” (raid/sabotage avorté) OU `violation_score` approche le seuil (ex > 0.6)

### Variants
- combat: stop border skirmish
- escort: escort inspectors / peacekeepers
- logistics: secure checkpoints / supply compliance

### Effets
**LOYAL** (application ferme)
- `treaty.violation_score -= 0.25`
- `treaty.end_day += 4` (ça stabilise)
- `weariness -2` (réduit coût guerre)
- `A↔B tension -4`

**NEUTRAL** (application molle)
- `treaty.violation_score -= 0.10`
- `end_day += 1`

**TRAITOR** (ferme les yeux / laisse passer)
- `treaty.violation_score += 0.25`
- `A↔B tension +3`, `grievance +3`

---

# 3) Offer: “Arbitration summit” (conférence / arbitrage, souvent via third party)
### Quand la générer
- si `guarantor_id != ""` OU si l’un des camps a une personnalité “diplomacy” élevée
- surtout quand `violation_score` oscille sans retomber (ex: 0.3–0.8)

### Variants
- escort diplomat
- secure neutral venue
- eliminate spoiler (tiers qui veut faire capoter)

### Effets
**LOYAL** (accord d’arbitrage)
- `treaty.violation_score = max(0, treaty.violation_score - 0.45)`
- `treaty.end_day += 6`
- `A↔B trust +6`, `relation +4`, `tension -6`
- si garant C : `A↔C relation +4`, `B↔C relation +4` (crédibilité)

**NEUTRAL**
- `violation_score -= 0.20`
- `end_day += 2`
- `trust +2`

**TRAITOR** (sabotage diplomatique)
- `violation_score += 0.35`
- `end_day -= 2` (ou traité cassé si tu préfères)
- `trust -6`, `tension +6`

---

## Application code (mini util)
Dans `ArcStateMachine` (ou `TreatySystem.gd`) :

```gdscript
static func apply_treaty_enforcement_resolution(
	arc_state: ArcState,
	rel_ab: FactionRelationScore,
	rel_ba: FactionRelationScore,
	enforcement_type: StringName, # &"investigate"|"enforce"|"summit"
	choice: StringName,
	day: int
) -> void:
	var t := arc_state.treaty
	if t == null:
		return

	var dv := 0.0
	var dend := 0
	var d_trust := 0
	var d_tension := 0
	var d_rel := 0
	var d_wear := 0

	match enforcement_type:
		&"investigate":
			if choice == &"LOYAL":   dv = -0.35; dend = +2; d_trust = +4; d_tension = -3
			elif choice == &"NEUTRAL":dv = -0.15; dend =  0; d_trust = +1
			else:                   dv = +0.40; dend =  0; d_trust = -4; d_tension = +4
		&"enforce":
			if choice == &"LOYAL":   dv = -0.25; dend = +4; d_tension = -4; d_wear = -2
			elif choice == &"NEUTRAL":dv = -0.10; dend = +1
			else:                   dv = +0.25; dend =  0; d_tension = +3
		&"summit":
			if choice == &"LOYAL":   dv = -0.45; dend = +6; d_trust = +6; d_tension = -6; d_rel = +4
			elif choice == &"NEUTRAL":dv = -0.20; dend = +2; d_trust = +2
			else:                   dv = +0.35; dend = -2; d_trust = -6; d_tension = +6

	t.violation_score = clampf(t.violation_score + dv, 0.0, 2.0)
	t.end_day = max(t.end_day + dend, day + 1)

	# Apply small relation deltas to both directions
	if d_trust != 0:
		rel_ab.trust = int(clampi(rel_ab.trust + d_trust, 0, 100))
		rel_ba.trust = int(clampi(rel_ba.trust + d_trust, 0, 100))
	if d_tension != 0:
		rel_ab.tension = int(clampi(rel_ab.tension + d_tension, 0, 100))
		rel_ba.tension = int(clampi(rel_ba.tension + d_tension, 0, 100))
	if d_rel != 0:
		rel_ab.relation = int(clampi(rel_ab.relation + d_rel, -100, 100))
		rel_ba.relation = int(clampi(rel_ba.relation + d_rel, -100, 100))
	if d_wear != 0:
		rel_ab.weariness = int(clampi(rel_ab.weariness + d_wear, 0, 100))
		rel_ba.weariness = int(clampi(rel_ba.weariness + d_wear, 0, 100))

	# Si on repasse en dessous d’un seuil => “stabilité”
	# (optionnel) si t.violation_score < 0.2: arc_state.pending_retaliation = false
```

---

## Génération (2–3 templates / mapping vers QuestPool)
Tu peux mapper ça à ton OfferFactory comme :
- `arc.treaty_investigate` → stealth/retrieve/diplomacy
- `arc.treaty_enforce` → combat/escort/logistics
- `arc.treaty_summit` → escort/secure venue/eliminate spoiler

Et context :
```gdscript
"context.is_arc_rivalry" = true
"context.is_treaty_enforcement" = true
"context.enforcement_type" = &"investigate"|"enforce"|"summit"
"context.treaty_type" = arc_state.treaty.type
"context.pair_key" = primary_pair_key
```

---

Si tu veux, prochaine brique logique : un mini test “violation puis enforcement loyal” qui vérifie que `violation_score` redescend et que le traité ne casse pas, + un test “traitor summit” qui casse le traité (score dépasse threshold).

Moi:
prochaine brique logique : un mini test “violation puis enforcement loyal” qui vérifie que violation_score redescend et que le traité ne casse pas, + un test “traitor summit” qui casse le traité (score dépasse threshold).

ChatGPT:
Voici 2 mini tests Godot (GDScript) qui couvrent exactement ça.

- Test 1 : **violation** (raid pendant TRUCE) → `violation_score` monte → **enforcement LOYAL** → `violation_score` redescend et le traité reste actif.
- Test 2 : **summit TRAITOR** → `violation_score` dépasse `threshold` → le traité **casse** (treaty devient `null`) et l’arc repasse en **CONFLICT/WAR** (selon ta logique).

> Hypothèse : tu as implémenté le schéma `Treaty` + la logique de violation dans `ArcStateMachine.update_arc_state()` (celle qu’on a décrite).  
> Et la fonction `apply_treaty_enforcement_resolution()` existe (celle du message précédent).

---

## Test 1 — Violation puis enforcement loyal

### `tests/TreatyEnforcementStabilizesTest.gd`
```gdscript
extends Node
class_name TreatyEnforcementStabilizesTest

func _ready() -> void:
	_test_violation_then_enforcement_loyal_stabilizes()
	print("\n✅ TreatyEnforcementStabilizesTest: OK\n")
	get_tree().quit()

func _test_violation_then_enforcement_loyal_stabilizes() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11111

	var rel_ab := FactionRelationScore.new()
	var rel_ba := FactionRelationScore.new()
	rel_ab.relation = 25; rel_ba.relation = 22
	rel_ab.trust = 55;    rel_ba.trust = 52
	rel_ab.tension = 20;  rel_ba.tension = 22
	rel_ab.grievance = 10;rel_ba.grievance = 12

	var arc := ArcState.new()
	arc.state = &"TRUCE"
	arc.lock_until_day = 0

	# Treaty TRUCE: no raids, threshold fairly high so 1 violation doesn't auto-break
	var t := Treaty.new()
	t.type = &"TRUCE"
	t.start_day = 1
	t.end_day = 30
	t.cooldown_after_end_days = 20
	t.clauses = Treaty.CLAUSE_NO_RAID | Treaty.CLAUSE_NO_SABOTAGE | Treaty.CLAUSE_NO_WAR
	t.violation_score = 0.0
	t.violation_threshold = 1.2
	arc.treaty = t

	# Day 5: RAID happens => violation score must go up
	ArcStateMachine.update_arc_state(
		arc, rel_ab, rel_ba,
		5, rng,
		ArcDecisionUtil.ARC_RAID,
		&"LOYAL"
	)

	_assert(arc.treaty != null, "treaty should still exist after a single violation")
	var v_after_violation := arc.treaty.violation_score
	_assert(v_after_violation > 0.0, "violation_score should increase after violation (got %.3f)" % v_after_violation)

	# Day 6: enforcement LOYAL should reduce violation_score and not break treaty
	ArcStateMachine.apply_treaty_enforcement_resolution(
		arc, rel_ab, rel_ba,
		&"enforce",
		&"LOYAL",
		6
	)

	_assert(arc.treaty != null, "treaty should remain active after enforcement")
	_assert(arc.treaty.violation_score < v_after_violation, "violation_score should decrease after enforcement (%.3f -> %.3f)" % [v_after_violation, arc.treaty.violation_score])

	# Sanity: tension should not be higher than right after violation (usually decreases)
	_assert(rel_ab.tension <= 100 and rel_ba.tension <= 100, "tension stays in bounds")


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

## Test 2 — Summit traitor casse le traité

### `tests/TreatySummitTraitorBreaksTest.gd`
```gdscript
extends Node
class_name TreatySummitTraitorBreaksTest

func _ready() -> void:
	_test_traitor_summit_breaks_treaty()
	print("\n✅ TreatySummitTraitorBreaksTest: OK\n")
	get_tree().quit()

func _test_traitor_summit_breaks_treaty() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 22222

	var rel_ab := FactionRelationScore.new()
	var rel_ba := FactionRelationScore.new()
	rel_ab.relation = 30; rel_ba.relation = 28
	rel_ab.trust = 60;    rel_ba.trust = 58
	rel_ab.tension = 18;  rel_ba.tension = 20
	rel_ab.grievance = 8; rel_ba.grievance = 10

	var arc := ArcState.new()
	arc.state = &"TRUCE"
	arc.lock_until_day = 0

	# Treaty TRUCE: already near threshold so traitor summit pushes it over
	var t := Treaty.new()
	t.type = &"TRUCE"
	t.start_day = 1
	t.end_day = 40
	t.cooldown_after_end_days = 25
	t.clauses = Treaty.CLAUSE_NO_RAID | Treaty.CLAUSE_NO_SABOTAGE | Treaty.CLAUSE_NO_WAR
	t.violation_score = 0.90
	t.violation_threshold = 1.10  # low threshold so the test is deterministic
	arc.treaty = t

	# Day 10: summit TRAITOR => violation_score increases enough to cross threshold
	ArcStateMachine.apply_treaty_enforcement_resolution(
		arc, rel_ab, rel_ba,
		&"summit",
		&"TRAITOR",
		10
	)

	# Now we enforce "break rule" in update_arc_state:
	# Either you break immediately inside apply_treaty_enforcement_resolution,
	# or you check it in update_arc_state on next tick.
	#
	# We'll do a tick to be safe.
	ArcStateMachine.update_arc_state(
		arc, rel_ab, rel_ba,
		11, rng,
		&"", &""
	)

	_assert(arc.treaty == null, "treaty should be broken after traitor summit pushes score over threshold")

	# State should have deteriorated (TRUCE no longer valid)
	_assert(arc.state == &"CONFLICT" or arc.state == &"WAR" or arc.state == &"RIVALRY",
		"arc state should deteriorate after treaty breaks, got %s" % String(arc.state)
	)

	# Lock should be applied (post-treaty cooldown)
	_assert(arc.lock_until_day >= 11, "lock_until_day should be set after treaty break")


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

### Petit détail d’implémentation à décider (pour que le test 2 passe)
Actuellement `apply_treaty_enforcement_resolution()` ne casse pas le traité directement. Deux options :

1) **Casser immédiatement dans `apply_treaty_enforcement_resolution()`** si `violation_score >= threshold`  
2) Ou bien faire la vérif dans `update_arc_state()` “au début de tick” :
```gdscript
if arc_state.treaty != null and arc_state.treaty.violation_score >= arc_state.treaty.violation_threshold:
	arc_state.lock_until_day = max(arc_state.lock_until_day, day + arc_state.treaty.cooldown_after_end_days)
	arc_state.treaty = null
	arc_state.state = &"CONFLICT"
```

Le test 2 est compatible avec les deux (il appelle un tick `update_arc_state` au jour 11).

Si tu veux, je te donne aussi la micro-fonction utilitaire `maybe_break_treaty(arc_state, day)` pour centraliser ça proprement.

Moi:
donne aussi la micro-fonction utilitaire maybe_break_treaty(arc_state, day) pour centraliser ça proprement. Et dis moi où et comment l'integrer

ChatGPT:
Voici une micro-fonction utilitaire **centralisée** `maybe_break_treaty()` + où/comment l’intégrer.

---

## 1) Micro-fonction `maybe_break_treaty(arc_state, day, action=…)`

À mettre dans `ArcStateMachine.gd` (ou `TreatySystem.gd` si tu préfères) :

```gdscript
static func maybe_break_treaty(arc_state: ArcState, day: int, trigger_action: StringName = &"") -> bool:
	var t: Treaty = arc_state.treaty
	if t == null:
		return false
	if t.violation_score < t.violation_threshold:
		return false

	# Break treaty + long cooldown lock
	arc_state.lock_until_day = max(arc_state.lock_until_day, day + t.cooldown_after_end_days)

	# Deteriorate state (declare_war -> WAR, otherwise CONFLICT)
	if trigger_action == ArcDecisionUtil.ARC_DECLARE_WAR:
		arc_state.state = &"WAR"
	else:
		arc_state.state = &"CONFLICT"

	arc_state.treaty = null
	return true
```

✅ Retourne `true` si le traité a été cassé (utile pour `return` immédiat dans `update_arc_state()`).

---

## 2) Où l’intégrer (2 endroits clés)

### A) Dans `update_arc_state()` : après toute modification de `violation_score`
1) **après une violation détectée** (raid pendant TRUCE, etc.)
2) **après application d’une quête d’enforcement** si tu fais ça via `update_arc_state()`

Exemple (après `arc_state.treaty.violation_score += sev` + deltas) :

```gdscript
if maybe_break_treaty(arc_state, day, action):
	arc_state.phase_hostile += 1
	return
```

### B) En début de `update_arc_state()` : sécurité “tick passif”
Ça permet au test “traitor summit” de casser le traité même si l’augmentation du score a été faite ailleurs.

Au tout début (après expiration éventuelle, ou même avant) :

```gdscript
# Break check (passive)
if maybe_break_treaty(arc_state, day):
	return
```

> Comme ça, si `apply_treaty_enforcement_resolution()` a poussé `violation_score` au-dessus du seuil, le traité casse au prochain tick.

---

## 3) Comment l’utiliser avec `apply_treaty_enforcement_resolution()`
Deux styles possibles :

### Style 1 (recommandé) : **ne casse pas** dans apply, laisse `update_arc_state()` gérer
- `apply_treaty_enforcement_resolution()` modifie `violation_score`
- au prochain tick, `maybe_break_treaty()` est appelé et tranche

Avantage : **un seul endroit** décide de la cassure.

### Style 2 : casser immédiatement (si tu veux feedback instant)
À la fin de `apply_treaty_enforcement_resolution()` :

```gdscript
ArcStateMachine.maybe_break_treaty(arc_state, day)
```

---

### Résumé “où et comment”
- **Ajoute** `maybe_break_treaty()` dans `ArcStateMachine`.
- **Appelle-la** :
  - en **début** de `update_arc_state()` (passif),
  - et **juste après** toute hausse de `violation_score` (actif).
- Optionnel : l’appeler aussi à la fin de `apply_treaty_enforcement_resolution()` si tu veux une rupture immédiate.

Si tu veux, je peux te donner un patch “diff” exact de `update_arc_state()` (avec les 3 emplacements) en gardant ton style compact.

Moi:
Non, on va travailler sur • War aims + sortie (sinon WAR peut tourner longtemps)

ChatGPT:
OK. Pour éviter que `WAR` tourne “à vide”, il faut que **la guerre ait un but explicite** (*war aim*) + **un compteur de progrès** + **des sorties** (victoire / paix négociée / capitulation / enlisement).

Voici une V1 **compacte** qui s’intègre très bien à tout ce qu’on a déjà (ArcStateMachine + QuestPool + LOYAL/NEUTRAL/TRAITOR).

---

## 1) WarAim V1

### Enum (5 aims utiles dès maintenant)
- `PUNISH` : “punir / faire payer” (raid, sabotage, humiliation)
- `TRIBUTE` : “obtenir un tribut” (or / ressources / otages)
- `TAKE_POI` : “prendre/contrôler un POI” (ville, fort, mine, sanctuaire)
- `SUBJUGATE` : “vassaliser” (imposer un traité inégal)
- `EXTERMINATE` : “guerre d’extermination” (rare, très coûteux, personnalité belliqueuse/haine)

> `ALLIANCE` / `FUSION` ne sont pas des war aims “naturels” : ce sont plutôt des **sorties** possibles d’un conflit long + médiation + menace externe + compatibilité d’axes (on peut les produire via la diplomatie/traités).

---

## 2) Champs à ajouter à `ArcState` (MVP)

```gdscript
# ArcState.gd (ajouts)
var war_aim: StringName = &""               # PUNISH/TRIBUTE/TAKE_POI/SUBJUGATE/EXTERMINATE
var war_progress: float = 0.0               # 0..100 (progrès vers l’aim)
var war_progress_target: float = 100.0      # seuil de “victoire”
var war_start_day: int = -1
var war_max_days: int = 45                  # au-delà -> pression vers sortie (armistice/terms)
var war_target_poi_id: StringName = &""     # pour TAKE_POI
var war_terms: Dictionary = {}              # conditions proposées à la sortie
```

---

## 3) Choisir un war aim au passage en WAR

### Heuristique simple (suffisante)
- `EXTERMINATE` si relation très basse + grievance très haute + personnalité belliqueuse + coût supportable
- `TAKE_POI` si opportunité forte + POI stratégique voisin
- `TRIBUTE` si l’attaquant est pauvre / opportuniste
- `PUNISH` par défaut (aim “court”)
- `SUBJUGATE` si rapport de force très favorable + target déjà instable

```gdscript
static func choose_war_aim(arc_state: ArcState, rel_ab: FactionRelationScore, rel_ba: FactionRelationScore, profiles: Dictionary, a_id: StringName, b_id: StringName, ctx: FactionWorldContext) -> void:
	var rel_mean := 0.5 * (rel_ab.relation + rel_ba.relation)
	var griev_mean := 0.5 * (rel_ab.grievance + rel_ba.grievance)
	var tens_mean := 0.5 * (rel_ab.tension + rel_ba.tension)
	var wear_mean := 0.5 * (rel_ab.weariness + rel_ba.weariness)

	# exemples de traits (à adapter à tes clés)
	var pa: FactionProfile = profiles.get(a_id, null)
	var bell := (pa.get_personality(&"belligerence", 0.5) if pa else 0.5)
	var expa := (pa.get_personality(&"expansionism", 0.5) if pa else 0.5)

	if rel_mean <= -80 and griev_mean >= 70 and bell >= 0.75 and wear_mean <= 55:
		arc_state.war_aim = &"EXTERMINATE"
		arc_state.war_max_days = 70
	elif expa >= 0.65 and ctx.opportunity >= 0.55:
		arc_state.war_aim = &"TAKE_POI"
		arc_state.war_target_poi_id = &"" # à remplir via ta sélection POI
		arc_state.war_max_days = 55
	elif ctx.external_threat >= 0.6:
		arc_state.war_aim = &"PUNISH" # guerre “limitée” si menace externe
		arc_state.war_max_days = 35
	else:
		arc_state.war_aim = &"TRIBUTE" if griev_mean < 55 else &"PUNISH"
		arc_state.war_max_days = 45

	arc_state.war_progress = 0.0
	arc_state.war_progress_target = 100.0
```

---

## 4) Le cœur : convertir les events/quests en `war_progress`

### Table simple (peut être raffinée plus tard)
- Raid réussi : +12 (PUNISH/TRIBUTE), +6 (TAKE_POI)
- Sabotage : +10 (PUNISH), +8 (TAKE_POI)
- Capture POI : +35 (TAKE_POI)
- Imposer tribut (quest): +40 (TRIBUTE)
- Victoire “décisive” (quest decisive battle): +25
- Échec : progression faible ou négative (et weariness↑)

```gdscript
static func apply_war_progress_from_arc_action(
	arc_state: ArcState,
	arc_action: StringName,
	choice: StringName,
	success: bool,
	rel_ab: FactionRelationScore,
	rel_ba: FactionRelationScore
) -> void:
	if arc_state.state != &"WAR":
		return

	var aim := arc_state.war_aim
	var dp := 0.0

	if not success:
		# échec = pas de progrès et fatigue augmente
		rel_ab.weariness = int(clampi(rel_ab.weariness + 3, 0, 100))
		rel_ba.weariness = int(clampi(rel_ba.weariness + 3, 0, 100))
		arc_state.war_progress = max(0.0, arc_state.war_progress - 4.0)
		return

	match arc_action:
		ArcDecisionUtil.ARC_RAID:
			dp = 12.0 if (aim == &"PUNISH" or aim == &"TRIBUTE") else 6.0
		ArcDecisionUtil.ARC_SABOTAGE:
			dp = 10.0 if aim == &"PUNISH" else 8.0
		&"war.capture_poi":
			dp = 35.0 if aim == &"TAKE_POI" else 15.0
		&"war.enforce_tribute":
			dp = 40.0 if aim == &"TRIBUTE" else 12.0
		&"war.decicive_battle":
			dp = 25.0
		_:
			dp = 8.0

	# choice peut moduler (TRAITOR = gain court terme mais trust se dégrade ailleurs)
	if choice == &"LOYAL": dp *= 1.05
	elif choice == &"NEUTRAL": dp *= 0.95
	elif choice == &"TRAITOR": dp *= 1.10

	arc_state.war_progress = clampf(arc_state.war_progress + dp, 0.0, 120.0)
```

---

## 5) Sorties de guerre (le point clé)

### A) Victoire par accomplissement de l’aim
Si `war_progress >= target` :
- produire des **terms** selon aim
- passer en `TRUCE` (avec `Treaty`) ou `RESOLVED` si tu as un état terminal
- lock long (pair_lock_days)

Exemples de `war_terms` :
- PUNISH : réparations + libération prisonniers
- TRIBUTE : escrow/tribut X jours
- TAKE_POI : transfert de contrôle POI
- SUBJUGATE : vassalage + no-war clause
- EXTERMINATE : (si tu le gardes) → fusion de territoire / destruction (très rare)

### B) Enlisement (max days) → armistice forcé
Si `day - war_start_day >= war_max_days` **ou** `weariness_mean > 75` :
- pousser vers `TRUCE_TALKS / REPARATIONS / SUMMIT` (offers)
- si refus répété → “stalemate” (TRUCE courte + clauses strictes)

### C) Changement de contexte monde
Si `external_threat` explose (menace tierce), même en WAR :
- offrir une sortie “trêve + coalition” (ça crée tes alliances organiques)

```gdscript
static func maybe_end_war(arc_state: ArcState, rel_ab: FactionRelationScore, rel_ba: FactionRelationScore, day: int, ctx: FactionWorldContext) -> bool:
	if arc_state.state != &"WAR":
		return false

	var wear_mean := 0.5 * (rel_ab.weariness + rel_ba.weariness)

	# Victory
	if arc_state.war_progress >= arc_state.war_progress_target:
		arc_state.war_terms = build_war_terms(arc_state)
		arc_state.state = &"TRUCE"
		# ici: arc_state.treaty = create_truce_treaty(day, guarantor?) + lock
		arc_state.lock_until_day = max(arc_state.lock_until_day, day + 20)
		return true

	# Forced armistice
	if arc_state.war_start_day >= 0 and (day - arc_state.war_start_day) >= arc_state.war_max_days:
		arc_state.war_terms = {"type":"ARMISTICE", "duration_days":14}
		arc_state.state = &"TRUCE"
		arc_state.lock_until_day = max(arc_state.lock_until_day, day + 12)
		return true

	if wear_mean >= 78.0:
		arc_state.war_terms = {"type":"EXHAUSTION_TRUCE", "duration_days":10}
		arc_state.state = &"TRUCE"
		arc_state.lock_until_day = max(arc_state.lock_until_day, day + 10)
		return true

	# External threat pivot
	if ctx.external_threat >= 0.75:
		# pas forcément fin immédiate, mais pousse à une offer de trêve/coalition
		# (ici tu peux juste poser un flag pending_peace_offer)
		arc_state.war_terms["pivot"] = "EXTERNAL_THREAT"
	return false
```

---

## 6) Le pont vers QuestPool : offres “war aim driven”

Chaque aim doit produire **au moins 2–3 familles d’offres** :

- `PUNISH` → raid / sabotage / decisive battle / assassinate officer  
- `TRIBUTE` → seize treasury / intercept caravan / enforce payment / hostage exchange  
- `TAKE_POI` → capture fort / cut supply / scout weak point / siege prep  
- `SUBJUGATE` → capture leader / destroy army / force treaty / propaganda  
- `EXTERMINATE` → (rare) burn nests / purge corruption / end leadership (très violent)

Et surtout : **les offers ajoutent du war_progress** si succès (via `apply_war_progress_from_arc_action()`).

---

## 7) Ce que ça change immédiatement
- Une guerre a une **fin naturelle** (objectif atteint ou épuisement).
- Tu peux faire émerger :
  - une guerre courte de punition,
  - une guerre économique (tribut),
  - une guerre territoriale (POI),
  - une domination (subjugate),
  - et très rarement extermination.
- Les offres générées deviennent cohérentes et variées (pas juste “raid infini”).

---

Si tu veux, prochaine brique logique : je te propose `build_war_terms(arc_state)` (compact) + un mapping “terms → Treaty clauses + rewards/penalties” (ex: TRIBUTE crée un traité avec clause `OPEN_TRADE` + escrow périodique).

Moi:
prochaine brique logique : je te propose build_war_terms(arc_state) (compact) + un mapping “terms → Treaty clauses + rewards/penalties” (ex: TRIBUTE crée un traité avec clause OPEN_TRADE + escrow périodique).

ChatGPT:
OK — voici une V1 **compacte** de `build_war_terms(arc_state)` + un mapping `terms → Treaty` (clauses) + rewards/penalties (deltas relation/trust/tension + “escrow périodique” simple).

L’idée : `war_terms` reste un `Dictionary` minimal, et on crée ensuite un `Treaty` + effets via une fonction `apply_terms_outcome(...)`.

---

## 1) `build_war_terms(arc_state)` (compact)

```gdscript
static func build_war_terms(arc_state: ArcState) -> Dictionary:
	var aim := arc_state.war_aim

	match aim:
		&"PUNISH":
			return {
				"type": &"PUNISH",
				"truce_days": 18,
				"reparations_gold": 120,   # base, modulé ensuite (tier/progress)
				"humiliation": 1,          # flag
			}

		&"TRIBUTE":
			return {
				"type": &"TRIBUTE",
				"truce_days": 22,
				"tribute_gold_per_week": 80,
				"tribute_weeks": 4,
				"open_trade": true,
			}

		&"TAKE_POI":
			return {
				"type": &"TAKE_POI",
				"truce_days": 20,
				"poi_id": arc_state.war_target_poi_id,
				"no_raid_days": 20,
			}

		&"SUBJUGATE":
			return {
				"type": &"SUBJUGATE",
				"truce_days": 26,
				"vassalage_days": 40,
				"tribute_gold_per_week": 60,
				"no_war_days": 40,
			}

		&"EXTERMINATE":
			# V1: on ne fait pas "suppression de faction" ici. On en fait un traité très dur (capitulation),
			# et le reste (annexion/fusion) peut venir ensuite via systems monde.
			return {
				"type": &"CAPITULATION",
				"truce_days": 30,
				"disarm": true,
				"no_war_days": 60,
				"reparations_gold": 200,
			}

		_:
			return {"type": &"ARMISTICE", "truce_days": 14}
```

---

## 2) Mapping terms → Treaty (clauses + durée)

```gdscript
static func treaty_from_terms(day: int, terms: Dictionary, guarantor_id: StringName = &"") -> Treaty:
	var t := Treaty.new()
	t.start_day = day
	t.type = &"TRUCE"
	t.guarantor_id = guarantor_id

	var truce_days := int(terms.get("truce_days", 14))
	t.end_day = day + truce_days
	t.cooldown_after_end_days = 25

	# Clauses de base: "pas de reprise immédiate"
	t.clauses = Treaty.CLAUSE_NO_RAID | Treaty.CLAUSE_NO_SABOTAGE | Treaty.CLAUSE_NO_WAR

	var typ: StringName = terms.get("type", &"ARMISTICE")

	# Extensions par type
	if typ == &"TRIBUTE":
		t.clauses |= Treaty.CLAUSE_OPEN_TRADE
		# un tribut implique souvent "pas de sabotage" strict → déjà couvert

	elif typ == &"TAKE_POI":
		# rien de spécial en clauses (déjà no_raid/sabotage/war)
		pass

	elif typ == &"SUBJUGATE" or typ == &"CAPITULATION":
		# traité "dur" : seuil plus strict (cassure plus rapide si violation)
		t.violation_threshold = 0.9
		t.cooldown_after_end_days = 35
		# option : pas de trade automatiquement (à décider)
	else:
		# ARMISTICE / PUNISH
		pass

	# Defaults si non posés
	if t.violation_threshold <= 0.0:
		t.violation_threshold = 1.2
	t.violation_score = 0.0

	return t
```

---

## 3) Rewards/Penalties + “escrow périodique” (tribut)

### A) Deltas immédiats “fin de guerre”
On applique des changements sur A↔B (et éventuellement sur l’image du gagnant/perdant plus tard).

```gdscript
static func apply_terms_outcome(
	relations: Dictionary,          # relations[X][Y] -> FactionRelationScore
	winner_id: StringName,
	loser_id: StringName,
	arc_state: ArcState,
	day: int,
	terms: Dictionary,
	economies: Dictionary           # economies[faction] -> FactionEconomy
) -> void:
	var w2l: FactionRelationScore = relations[winner_id][loser_id]
	var l2w: FactionRelationScore = relations[loser_id][winner_id]

	var typ: StringName = terms.get("type", &"ARMISTICE")

	# Base: fin de guerre réduit la tension mais la relation reste souvent négative
	_apply_one_way_score(w2l, "tension", -18)
	_apply_one_way_score(l2w, "tension", -18)
	_apply_one_way_score(w2l, "weariness", -8)
	_apply_one_way_score(l2w, "weariness", -8)

	match typ:
		&"PUNISH":
			_apply_one_way_score(w2l, "trust", +3)
			_apply_one_way_score(l2w, "trust", -6)      # rancune
			_apply_one_way_score(l2w, "grievance", +10)
			_transfer_gold(loser_id, winner_id, int(terms.get("reparations_gold", 0)), economies)

		&"TRIBUTE":
			_apply_one_way_score(w2l, "trust", +4)
			_apply_one_way_score(l2w, "trust", -8)
			_apply_one_way_score(l2w, "grievance", +12)
			# pas de gros paiement upfront, mais planification périodique (voir plus bas)
			_schedule_tribute(arc_state, winner_id, loser_id, terms)

		&"TAKE_POI":
			_apply_one_way_score(w2l, "relation", -2)
			_apply_one_way_score(l2w, "relation", -14)
			_apply_one_way_score(l2w, "grievance", +14)
			# le transfert POI se fait dans ton système monde (ownership)
			arc_state.war_terms["apply_poi_transfer"] = true

		&"SUBJUGATE":
			_apply_one_way_score(w2l, "trust", +2)
			_apply_one_way_score(l2w, "trust", -14)
			_apply_one_way_score(l2w, "relation", -18)
			_apply_one_way_score(l2w, "grievance", +18)
			_schedule_tribute(arc_state, winner_id, loser_id, terms)

		&"CAPITULATION":
			_apply_one_way_score(l2w, "trust", -20)
			_apply_one_way_score(l2w, "relation", -22)
			_apply_one_way_score(l2w, "grievance", +25)
			_transfer_gold(loser_id, winner_id, int(terms.get("reparations_gold", 0)), economies)

		_:
			# ARMISTICE
			_apply_one_way_score(w2l, "trust", +2)
			_apply_one_way_score(l2w, "trust", +1)
```

Helpers (compacts) :

```gdscript
static func _apply_one_way_score(r: FactionRelationScore, field: String, delta: int) -> void:
	match field:
		"relation":   r.relation = int(clampi(r.relation + delta, -100, 100))
		"trust":      r.trust = int(clampi(r.trust + delta, 0, 100))
		"tension":    r.tension = int(clampi(r.tension + delta, 0, 100))
		"grievance":  r.grievance = int(clampi(r.grievance + delta, 0, 100))
		"weariness":  r.weariness = int(clampi(r.weariness + delta, 0, 100))

static func _transfer_gold(from_id: StringName, to_id: StringName, amount: int, economies: Dictionary) -> void:
	if amount <= 0: return
	var ef = economies.get(from_id, null)
	var et = economies.get(to_id, null)
	if ef == null or et == null: return
	var pay := min(amount, ef.gold)
	ef.gold -= pay
	et.gold += pay
```

### B) “Escrow périodique” (tribut hebdo)
V1 la plus simple : stocker un petit “schedule” dans `arc_state.war_terms` et le faire tick dans `tick_day_for_pair()`.

```gdscript
static func _schedule_tribute(arc_state: ArcState, winner_id: StringName, loser_id: StringName, terms: Dictionary) -> void:
	arc_state.war_terms["tribute_active"] = true
	arc_state.war_terms["tribute_winner"] = winner_id
	arc_state.war_terms["tribute_loser"] = loser_id
	arc_state.war_terms["tribute_gold_per_week"] = int(terms.get("tribute_gold_per_week", 60))
	arc_state.war_terms["tribute_weeks_left"] = int(terms.get("tribute_weeks", 4))
	arc_state.war_terms["tribute_next_day"] = int(arc_state.war_terms.get("tribute_next_day", 0)) # set by caller if needed
```

Et dans `ArcStateMachine.tick_day_for_pair()` (ou dans le tick monde), tu ajoutes :

```gdscript
static func tick_tribute_if_any(arc_state: ArcState, day: int, economies: Dictionary) -> void:
	if not arc_state.war_terms.get("tribute_active", false):
		return
	if int(arc_state.war_terms.get("tribute_weeks_left", 0)) <= 0:
		arc_state.war_terms["tribute_active"] = false
		return

	var next_day := int(arc_state.war_terms.get("tribute_next_day", day))
	if day < next_day:
		return

	var winner: StringName = arc_state.war_terms["tribute_winner"]
	var loser: StringName = arc_state.war_terms["tribute_loser"]
	var amt := int(arc_state.war_terms.get("tribute_gold_per_week", 60))

	_transfer_gold(loser, winner, amt, economies)

	arc_state.war_terms["tribute_weeks_left"] = int(arc_state.war_terms["tribute_weeks_left"]) - 1
	arc_state.war_terms["tribute_next_day"] = day + 7
```

> Tu peux appeler `tick_tribute_if_any()` depuis ton tick monde global (pas forcément dans ArcStateMachine), mais mécaniquement c’est “pair-local” donc ça s’y prête bien.

---

## 4) Où ça s’intègre dans ton flow

Quand `maybe_end_war()` détecte une victoire :
1) `terms = build_war_terms(arc_state)`
2) `treaty = treaty_from_terms(day, terms, guarantor_id?)`
3) `arc_state.treaty = treaty` et `arc_state.state = TRUCE`
4) `apply_terms_outcome(relations, winner, loser, arc_state, day, terms, economies)`
5) tick hebdo : `tick_tribute_if_any(arc_state, day, economies)`

---

## 5) Pont vers QuestPool (hyper direct)
Ces `terms` te donnent des **offers de sortie** :
- `TRIBUTE` → “collect payment / punish non-payment / escort tax collector”
- `TAKE_POI` → “secure captured POI / quell rebels / rebuild fortifications”
- `PUNISH` → “deliver reparations / hostage release / war crimes trial”
- `SUBJUGATE` → “install governor / swear oath / crush uprising”

---

Si tu veux, prochaine brique logique : une petite règle “non-payment” pour le tribut (si loser n’a pas l’or → violation_score du traité monte + offre ‘collect tribute by force’).

Moi:
prochaine brique logique : une petite règle “non-payment” pour le tribut (si loser n’a pas l’or → violation_score du traité monte + offre ‘collect tribute by force’).

ChatGPT:
OK — voici une règle V1 “**non-payment**” (tribut) qui est simple, robuste, et génère une offer “**collect tribute by force**”.

---

## 1) Stockage minimal dans `war_terms` (déjà compatible)

On réutilise ce qu’on a :
```gdscript
"tribute_active": true
"tribute_winner": winner_id
"tribute_loser": loser_id
"tribute_gold_per_week": N
"tribute_weeks_left": K
"tribute_next_day": day+7
```

On ajoute juste 2 champs pour gérer l’incident :
```gdscript
"tribute_missed_payments": 0
"tribute_last_miss_day": -999999
```

---

## 2) Règle “tick_tribute_if_any” + non-payment

Patch de la fonction `tick_tribute_if_any()` :

```gdscript
static func tick_tribute_if_any(
	arc_state: ArcState,
	day: int,
	economies: Dictionary,
	relations: Dictionary,              # relations[winner][loser]
	notebook: ArcNotebook,              # pour cooldown anti-spam d’offer
	spawn_collect_offer_fn: Callable    # injection: (winner, loser, day, tier) -> QuestInstance
) -> void:
	if not arc_state.war_terms.get("tribute_active", false):
		return
	if int(arc_state.war_terms.get("tribute_weeks_left", 0)) <= 0:
		arc_state.war_terms["tribute_active"] = false
		return

	var next_day := int(arc_state.war_terms.get("tribute_next_day", day))
	if day < next_day:
		return

	var winner: StringName = arc_state.war_terms["tribute_winner"]
	var loser: StringName = arc_state.war_terms["tribute_loser"]
	var amt := int(arc_state.war_terms.get("tribute_gold_per_week", 60))

	var ew = economies.get(winner, null)
	var el = economies.get(loser, null)
	if ew == null or el == null:
		return

	# --- Payment attempt ---
	if el.gold >= amt:
		_transfer_gold(loser, winner, amt, economies)
		arc_state.war_terms["tribute_weeks_left"] = int(arc_state.war_terms["tribute_weeks_left"]) - 1
		arc_state.war_terms["tribute_next_day"] = day + 7

		# reset miss counters gradually
		arc_state.war_terms["tribute_missed_payments"] = max(0, int(arc_state.war_terms.get("tribute_missed_payments", 0)) - 1)
		return

	# --- Non-payment: escalate treaty violation + spawn offer ---
	arc_state.war_terms["tribute_missed_payments"] = int(arc_state.war_terms.get("tribute_missed_payments", 0)) + 1
	arc_state.war_terms["tribute_last_miss_day"] = day
	arc_state.war_terms["tribute_next_day"] = day + 7  # next attempt anyway

	# Increase treaty violation_score (if treaty exists)
	if arc_state.treaty != null:
		# miss_count makes repeated failures increasingly serious
		var miss := int(arc_state.war_terms["tribute_missed_payments"])
		arc_state.treaty.violation_score += 0.20 + 0.05 * float(min(miss, 6))

		# Relation fallout: loser hates winner more (asym)
		var l2w: FactionRelationScore = relations[loser][winner]
		l2w.grievance = int(clampi(l2w.grievance + 6, 0, 100))
		l2w.tension = int(clampi(l2w.tension + 4, 0, 100))
		l2w.trust = int(clampi(l2w.trust - 4, 0, 100))

		# winner becomes less trusting too (sym small)
		var w2l: FactionRelationScore = relations[winner][loser]
		w2l.trust = int(clampi(w2l.trust - 2, 0, 100))
		w2l.tension = int(clampi(w2l.tension + 2, 0, 100))

		# Check break
		if ArcStateMachine.maybe_break_treaty(arc_state, day):
			# treaty broke => the "collect tribute" offer can become a WAR/CONFLICT offer naturally elsewhere
			return

	# Anti-spam cooldown: max 1 collect offer per 7 days per pair
	var pair_key := StringName((String(winner) <= String(loser)) ? (String(winner)+"|"+String(loser)) : (String(loser)+"|"+String(winner)))
	if not notebook.can_spawn_third_party(pair_key, day, 7): # reuse helper OR create a dedicated "can_spawn_collect"
		return
	notebook.mark_third_party_spawned(pair_key, day)

	# Spawn "collect tribute by force" (tier escalates with missed count)
	var missed := int(arc_state.war_terms.get("tribute_missed_payments", 1))
	var tier := clampi(1 + missed, 1, 4)
	var inst: QuestInstance = spawn_collect_offer_fn.call(winner, loser, day, tier)
	if inst != null:
		# caller adds to QuestPool; we keep tick pure
		pass
```

> Note : j’ai réutilisé `can_spawn_third_party()` juste pour cooldown (tu peux renommer en `can_spawn_pair_offer()` plus générique).

---

## 3) Offer “collect tribute by force” (MVP)

C’est une offer **WAR-terms**, pas une simple ARC_RAID.  
Tu peux la mapper à 2–3 variantes :
- `combat.collect_tribute` (attaquer percepteurs / dépôt)
- `stealth.collect_tribute` (voler coffres / falsifier registres)
- `logistics.collect_tribute` (saisir caravanes)

### Spawn fn (simple)
```gdscript
func spawn_collect_tribute_offer(winner: StringName, loser: StringName, day: int, tier: int) -> QuestInstance:
	var ctx := {
		"is_arc_rivalry": true,
		"is_war_terms": true,
		"war_terms_type": &"TRIBUTE",
		"arc_action_type": &"war.collect_tribute_by_force",
		"giver_faction_id": winner,
		"antagonist_faction_id": loser,
		"expires_in_days": 7,
		"stake": {"type":"TRIBUTE", "tier":tier}
	}
	var template := ArcOfferFactory._build_template_fallback("logistics.collect_tribute", tier, 7)
	var inst := QuestInstance.new(template, ctx)
	inst.status = "AVAILABLE"
	inst.started_on_day = day
	inst.expires_on_day = day + 7
	return inst
```

### Effet sur succès/échec
- Succès LOYAL : paiement partiel récupéré + `violation_score -= 0.15` (on “régularise”)  
- Échec : `violation_score += 0.10`, et augmente weariness

---

## 4) Où brancher ça
- Si tu tick les arcs quotidiennement : à la fin de `ArcStateMachine.tick_day_for_pair()` (ou juste après) tu appelles `tick_tribute_if_any(...)`.
- Si tu préfères centraliser : dans ton `WorldSim.tick_day()` après avoir tické toutes les paires.

L’important : ça doit être appelé **même les jours sans arcs**, comme tes autres compteurs.

---

## 5) Mini test (si tu veux tout de suite)
Un test rapide :
- loser.gold = 0
- tribute due day 7
- assert `violation_score` augmente
- assert spawn_collect_offer_fn est appelé (via Callable stub)
- puis donne de l’or au loser, tick suivant => paiement OK et missed decreases.

Si tu veux, je te l’écris comme les autres tests.

Moi:
Ok, fais ca 
5) Mini test (si tu veux tout de suite)

Un test rapide :

loser.gold = 0

tribute due day 7

assert violation_score augmente

assert spawn_collect_offer_fn est appelé (via Callable stub)

puis donne de l’or au loser, tick suivant écris comme les autres tests

ChatGPT:
Voici un **mini test Godot** dans le même style que les précédents. Il simule :

- `loser.gold = 0`
- tribut dû au **jour 7**
- ✅ `violation_score` augmente
- ✅ `spawn_collect_offer_fn` est appelé (stub)
- puis on donne de l’or au loser et on retick au **jour 14**
- ✅ paiement effectué (gold transféré) et `weeks_left` diminue

> Hypothèses :  
> - `ArcState`, `Treaty`, `FactionRelationScore`, `ArcStateMachine.tick_tribute_if_any()` existent avec la signature qu’on a proposée.  
> - `ArcNotebook` existe et a `can_spawn_third_party()` / `mark_third_party_spawned()` (ou équivalent cooldown).  
> - `FactionEconomy` a un champ `gold:int` (sinon adapte en `economy.gold`/`get_gold()`).

---

## `tests/TributeNonPaymentSpawnsCollectOfferTest.gd`

```gdscript
extends Node
class_name TributeNonPaymentSpawnsCollectOfferTest

func _ready() -> void:
	_test_non_payment_spawns_collect_offer_then_payment_succeeds()
	print("\n✅ TributeNonPaymentSpawnsCollectOfferTest: OK\n")
	get_tree().quit()


func _test_non_payment_spawns_collect_offer_then_payment_succeeds() -> void:
	var winner := &"A"
	var loser := &"B"

	# --- economies ---
	var economies := {}
	economies[winner] = FactionEconomy.new()
	economies[loser]  = FactionEconomy.new()
	economies[winner].gold = 0
	economies[loser].gold = 0  # non-payment

	# --- relations ---
	var relations := {}
	relations[winner] = {}
	relations[loser] = {}
	relations[winner][loser] = FactionRelationScore.new()
	relations[loser][winner] = FactionRelationScore.new()

	# some baseline values
	relations[winner][loser].trust = 40
	relations[winner][loser].tension = 20
	relations[winner][loser].grievance = 10

	relations[loser][winner].trust = 35
	relations[loser][winner].tension = 25
	relations[loser][winner].grievance = 15

	# --- arc + treaty + tribute schedule ---
	var arc := ArcState.new()
	arc.state = &"TRUCE"

	var t := Treaty.new()
	t.type = &"TRUCE"
	t.start_day = 1
	t.end_day = 60
	t.cooldown_after_end_days = 25
	t.clauses = Treaty.CLAUSE_NO_RAID | Treaty.CLAUSE_NO_SABOTAGE | Treaty.CLAUSE_NO_WAR | Treaty.CLAUSE_OPEN_TRADE
	t.violation_score = 0.0
	t.violation_threshold = 1.2
	arc.treaty = t

	arc.war_terms = {
		"tribute_active": true,
		"tribute_winner": winner,
		"tribute_loser": loser,
		"tribute_gold_per_week": 50,
		"tribute_weeks_left": 2,
		"tribute_next_day": 7,
		"tribute_missed_payments": 0,
		"tribute_last_miss_day": -999999
	}

	# --- notebook + stub spawn fn ---
	var notebook := ArcNotebook.new()
	var spawn_called := false
	var spawn_args := {}

	var spawn_fn := func(w: StringName, l: StringName, day: int, tier: int) -> QuestInstance:
		spawn_called = true
		spawn_args = {"winner": w, "loser": l, "day": day, "tier": tier}
		# returning null is fine; this test only checks callback call
		return null

	# --- Day 7: due but loser has 0 => violation_score increases + spawn called ---
	var v_before := arc.treaty.violation_score
	ArcStateMachine.tick_tribute_if_any(
		arc, 7,
		economies,
		relations,
		notebook,
		Callable(spawn_fn)
	)

	_assert(arc.treaty != null, "treaty should still exist after first non-payment (should not auto-break)")
	_assert(arc.treaty.violation_score > v_before, "violation_score should increase on non-payment (%.3f -> %.3f)" % [v_before, arc.treaty.violation_score])
	_assert(spawn_called, "spawn_collect_offer_fn should be called on non-payment")
	_assert(StringName(spawn_args.get("winner", &"")) == winner, "spawn arg winner mismatch")
	_assert(StringName(spawn_args.get("loser", &"")) == loser, "spawn arg loser mismatch")
	_assert(int(spawn_args.get("day", -1)) == 7, "spawn day should be 7")

	# weeks_left should NOT decrement on non-payment
	_assert(int(arc.war_terms["tribute_weeks_left"]) == 2, "weeks_left should not decrement on non-payment")

	# --- Give gold and tick next due (day 14) => payment succeeds, gold transfers, weeks_left decrements ---
	economies[loser].gold = 80
	spawn_called = false
	spawn_args = {}

	var winner_gold_before := economies[winner].gold
	var loser_gold_before := economies[loser].gold
	var weeks_before := int(arc.war_terms["tribute_weeks_left"])

	ArcStateMachine.tick_tribute_if_any(
		arc, 14,
		economies,
		relations,
		notebook,
		Callable(spawn_fn)
	)

	# should not spawn now (successful payment)
	_assert(not spawn_called, "spawn_collect_offer_fn should not be called on successful payment")

	# transfer happened
	var amt := int(arc.war_terms.get("tribute_gold_per_week", 50))
	_assert(economies[winner].gold == winner_gold_before + amt, "winner gold should increase by tribute amount")
	_assert(economies[loser].gold == loser_gold_before - amt, "loser gold should decrease by tribute amount")

	# weeks left decremented
	_assert(int(arc.war_terms["tribute_weeks_left"]) == weeks_before - 1, "weeks_left should decrement on successful payment")


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

### Notes d’adaptation rapide (si besoin)
- Si ton `FactionEconomy` n’a pas `gold`, remplace par tes méthodes (ex `get_gold()` / `add_gold()`).
- Si tu ne veux pas réutiliser `can_spawn_third_party()` pour le cooldown, le test s’en fiche tant que le spawn fn est appelé au jour 7.

Si tu veux, je te fais aussi une variante où **2 non-payments** déclenchent une **cassure du traité** (violation_score dépasse threshold) et bascule vers `CONFLICT/WAR`.

Moi:
fais aussi une variante où 2 non-payments déclenchent une cassure du traité (violation_score dépasse threshold) et bascule vers CONFLICT/WAR

ChatGPT:
Voici une **variante** qui force une cassure du traité après **2 non-payments**, en configurant `violation_threshold` bas, puis vérifie :

- `treaty == null`
- `arc.state` est `CONFLICT` ou `WAR`

> Hypothèse : `tick_tribute_if_any()` appelle `ArcStateMachine.maybe_break_treaty()` quand `violation_score` dépasse le seuil (comme dans le patch proposé).

---

## `tests/TributeTwoMissesBreakTreatyTest.gd`

```gdscript
extends Node
class_name TributeTwoMissesBreakTreatyTest

func _ready() -> void:
	_test_two_non_payments_break_treaty_and_escalate_state()
	print("\n✅ TributeTwoMissesBreakTreatyTest: OK\n")
	get_tree().quit()


func _test_two_non_payments_break_treaty_and_escalate_state() -> void:
	var winner := &"A"
	var loser := &"B"

	# --- economies ---
	var economies := {}
	economies[winner] = FactionEconomy.new()
	economies[loser]  = FactionEconomy.new()
	economies[winner].gold = 0
	economies[loser].gold = 0  # always non-payment

	# --- relations ---
	var relations := {}
	relations[winner] = {}
	relations[loser] = {}
	relations[winner][loser] = FactionRelationScore.new()
	relations[loser][winner] = FactionRelationScore.new()

	relations[winner][loser].trust = 40
	relations[winner][loser].tension = 20
	relations[winner][loser].grievance = 10

	relations[loser][winner].trust = 35
	relations[loser][winner].tension = 25
	relations[loser][winner].grievance = 15

	# --- arc + treaty ---
	var arc := ArcState.new()
	arc.state = &"TRUCE"

	var t := Treaty.new()
	t.type = &"TRUCE"
	t.start_day = 1
	t.end_day = 60
	t.cooldown_after_end_days = 25
	t.clauses = Treaty.CLAUSE_NO_RAID | Treaty.CLAUSE_NO_SABOTAGE | Treaty.CLAUSE_NO_WAR | Treaty.CLAUSE_OPEN_TRADE
	t.violation_score = 0.0
	t.violation_threshold = 0.45  # LOW: 2 misses should break deterministically
	arc.treaty = t

	# tribute schedule: due day 7 then day 14
	arc.war_terms = {
		"tribute_active": true,
		"tribute_winner": winner,
		"tribute_loser": loser,
		"tribute_gold_per_week": 50,
		"tribute_weeks_left": 2,
		"tribute_next_day": 7,
		"tribute_missed_payments": 0,
		"tribute_last_miss_day": -999999
	}

	# --- notebook + spawn fn stub ---
	var notebook := ArcNotebook.new()
	var spawn_calls := 0

	var spawn_fn := func(w: StringName, l: StringName, day: int, tier: int) -> QuestInstance:
		spawn_calls += 1
		return null

	# --- Miss #1 (day 7) ---
	ArcStateMachine.tick_tribute_if_any(
		arc, 7,
		economies,
		relations,
		notebook,
		Callable(spawn_fn)
	)

	_assert(arc.treaty != null, "treaty should still exist after first miss (depending on threshold)")
	_assert(spawn_calls == 1, "spawn should be called on first miss")

	# --- Miss #2 (day 14) => should break treaty ---
	ArcStateMachine.tick_tribute_if_any(
		arc, 14,
		economies,
		relations,
		notebook,
		Callable(spawn_fn)
	)

	_assert(spawn_calls >= 1, "spawn should have been called at least once (cooldown may block second)")
	_assert(arc.treaty == null, "treaty should be broken after second miss crosses threshold")

	_assert(
		arc.state == &"CONFLICT" or arc.state == &"WAR",
		"arc state should escalate to CONFLICT/WAR after treaty breaks, got %s" % String(arc.state)
	)

	_assert(arc.lock_until_day >= 14, "lock_until_day should be applied after treaty break")


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

### Petit détail important
- Le test tolère que `spawn_fn` ne soit pas appelé au 2e miss si ton cooldown empêche le spam (`spawn_calls >= 1` et pas `==2`), mais la cassure du traité doit arriver quand même.

Si tu veux, je peux te donner une version où le **trigger_action** de `maybe_break_treaty()` passe à `DECLARE_WAR` si tu veux que non-payment puisse *directement* déclencher `WAR` au lieu de `CONFLICT`.

Moi:
Ok, mais il faut que ca soit en fonction de l'historique des deux factions et de leur affinité/personnalité

ChatGPT:
Oui — **la cassure de traité (et surtout le choix CONFLICT vs WAR)** ne doit pas être “binaire fixe”. On peut la rendre **dépendante** :

- de l’**historique A↔B** (raids, sabotages, traités cassés, guerres passées, non-payments…)
- des **profils** (axes + personnalité : bellicisme/diplomatie/opportunisme/honneur…)
- des **métriques actuelles** (relation/trust/tension/grievance/weariness)
- et même du **contexte** (menace externe, fatigue du monde, etc.)

Voici un **mini patch propre** : on garde `maybe_break_treaty()` centralisée, mais on lui donne un **état cible calculé** par une fonction dédiée.

---

## 1) Nouvelle fonction : décider de l’escalade après non-payment

```gdscript
static func decide_state_on_tribute_default(
	winner_id: StringName,
	loser_id: StringName,
	day: int,
	arc_state: ArcState,
	relations: Dictionary,   # relations[X][Y] -> FactionRelationScore
	notebook: ArcNotebook,
	profiles: Dictionary,    # profiles[faction] -> FactionProfile
	ctx: FactionWorldContext = null
) -> StringName:
	var w2l: FactionRelationScore = relations[winner_id][loser_id]
	var l2w: FactionRelationScore = relations[loser_id][winner_id]

	var tension := 0.5 * (w2l.tension + l2w.tension) / 100.0
	var griev := 0.5 * (w2l.grievance + l2w.grievance) / 100.0
	var wear := 0.5 * (w2l.weariness + l2w.weariness) / 100.0
	var rel := 0.5 * (w2l.relation + l2w.relation) / 100.0

	# heat (hostile récent)
	var h := notebook.get_pair_heat(winner_id, loser_id, day, 0.93)
	var hostile_recent := 1.0 - exp(-0.35 * (float(h["hostile_to_other"]) + float(h["hostile_from_other"])))

	# historique : compteurs (à brancher sur ton ArcNotebook/arcHistory)
	var pair_key := StringName((String(winner_id) <= String(loser_id)) ? (String(winner_id)+"|"+String(loser_id)) : (String(loser_id)+"|"+String(winner_id)))
	var treaty_breaks := float(notebook.get_pair_counter(pair_key, &"treaty_breaks", 0)) # à ajouter
	var wars := float(notebook.get_pair_counter(pair_key, &"wars", 0))                   # à ajouter
	var nonpay := float(notebook.get_pair_counter(pair_key, &"tribute_misses", 0))       # à ajouter
	var history_factor := clampf(0.10*treaty_breaks + 0.15*wars + 0.10*nonpay, 0.0, 0.6)

	# profils
	var pw: FactionProfile = profiles.get(winner_id, null)
	var pl: FactionProfile = profiles.get(loser_id, null)

	var bell := pw.get_personality(&"belligerence", 0.5) if pw else 0.5
	var diplo := pw.get_personality(&"diplomacy", 0.5) if pw else 0.5
	var expa := pw.get_personality(&"expansionism", 0.5) if pw else 0.5
	var honor := pw.get_personality(&"honor", 0.5) if pw else 0.5

	# axes : divergence moyenne (0..1)
	var axis_div := 0.0
	if pw and pl:
		var sum := 0.0
		var n := 0.0
		for k in pw.axis_affinity.keys():
			if pl.axis_affinity.has(k):
				sum += abs(float(pw.axis_affinity[k]) - float(pl.axis_affinity[k])) / 200.0
				n += 1.0
		axis_div = (sum / max(1.0, n))

	# contexte (optionnel)
	var ext_threat := (ctx.external_threat if ctx else 0.0)

	# score d’escalade (0..1)
	# + tension/grievance/hostile_recent/history/axis_div/bell/honor
	# - diplomatie/fatigue/menace externe (pousse vers trêve/coali plutôt que guerre)
	var score := 0.30*tension + 0.22*griev + 0.18*hostile_recent + 0.12*axis_div + history_factor \
		+ 0.12*bell + 0.06*honor - 0.18*diplo - 0.22*wear - 0.12*ext_threat

	score = clampf(score, 0.0, 1.0)

	# décision :
	# - guerre si score haut et relation déjà très basse
	# - sinon conflit (punitive / collect-by-force / raids limités)
	if score >= 0.75 and rel <= -0.35:
		# expansionniste => WAR plus souvent, sinon CONFLICT peut suffire
		return &"WAR" if expa >= 0.55 else &"CONFLICT"
	return &"CONFLICT"
```

👉 Remarque : `get_pair_counter()` est un mini ajout sur ton ArcNotebook (voir section 3).

---

## 2) Patch `maybe_break_treaty` : accepter un état cible

```gdscript
static func maybe_break_treaty(arc_state: ArcState, day: int, desired_state: StringName = &"") -> bool:
	var t: Treaty = arc_state.treaty
	if t == null:
		return false
	if t.violation_score < t.violation_threshold:
		return false

	arc_state.lock_until_day = max(arc_state.lock_until_day, day + t.cooldown_after_end_days)

	# état choisi par la logique (sinon fallback)
	if desired_state != &"":
		arc_state.state = desired_state
	else:
		arc_state.state = &"CONFLICT"

	arc_state.treaty = null
	return true
```

---

## 3) Mini ajout ArcNotebook : counters par paire

Tu as déjà ton historique; le plus simple est d’ajouter un petit store “metrics by pair” :

```gdscript
# ArcNotebook.gd
var pair_counters: Dictionary = {} # pair_key -> {counter_name:StringName : int}

func inc_pair_counter(pair_key: StringName, name: StringName, delta: int = 1) -> void:
	if not pair_counters.has(pair_key):
		pair_counters[pair_key] = {}
	pair_counters[pair_key][name] = int(pair_counters[pair_key].get(name, 0)) + delta

func get_pair_counter(pair_key: StringName, name: StringName, default_val: int = 0) -> int:
	if not pair_counters.has(pair_key):
		return default_val
	return int(pair_counters[pair_key].get(name, default_val))
```

À appeler :
- à chaque `non-payment` : `inc_pair_counter(pair_key, &"tribute_misses", 1)`
- quand un traité casse : `inc_pair_counter(pair_key, &"treaty_breaks", 1)`
- quand WAR démarre : `inc_pair_counter(pair_key, &"wars", 1)`

---

## 4) Intégration : dans `tick_tribute_if_any()` au moment de casser

Dans le bloc non-payment, juste avant `maybe_break_treaty()` :

```gdscript
# ... après arc_state.treaty.violation_score += ...
notebook.inc_pair_counter(pair_key, &"tribute_misses", 1)

var desired := ArcStateMachine.decide_state_on_tribute_default(
	winner, loser, day, arc_state, relations, notebook, faction_profiles, ctx
)

if ArcStateMachine.maybe_break_treaty(arc_state, day, desired):
	notebook.inc_pair_counter(pair_key, &"treaty_breaks", 1)
	if desired == &"WAR":
		notebook.inc_pair_counter(pair_key, &"wars", 1)
	return
```

---

## 5) Conséquence : WAR aim dépend aussi des profils/historique
Si ça bascule en WAR après défaut de tribut, tu peux forcer un aim cohérent :
- `war_aim = TRIBUTE` (enforcement) ou `PUNISH` (punitive war)
- et si `expa` haut + target faible : `SUBJUGATE`

Ex :
```gdscript
if arc_state.state == &"WAR":
	arc_state.war_aim = &"TRIBUTE" if expa < 0.6 else &"SUBJUGATE"
```

---

### Pourquoi c’est mieux
- Une faction **diplomate/fatiguée** ne déclenchera pas une WAR pour 1 défaut de paiement.
- Une faction **honor+belligerence**, avec un lourd passif de guerre/traités cassés, escalade beaucoup plus facilement.
- Les **axes** rendent certaines paires “naturellement irréconciliables” (divergence haute) → plus de risques de WAR.

Si tu veux, je te donne une version “déterministe test-friendly” (où tu injectes un `params` pour fixer les poids/seuils) pour écrire un test qui prouve : *mêmes non-payments, mais profils différents => CONFLICT vs WAR*.

Moi:
Non ca suffit je pense
On passe sur :
• Knowledge/rumeurs (ça rend les offers à 3 factions incroyablement naturelles)

ChatGPT:
OK, passons à **Knowledge / rumeurs** en mode MVP “utile tout de suite” (et compatible avec ton ArcNotebook + offers à 3 factions).

L’objectif : **les factions ne réagissent pas aux faits**, mais à ce qu’elles **croient** (avec une **confiance**), et ces croyances peuvent être :
- vraies (témoins / preuves),
- fausses (propagande / biais),
- ou incomplètes (bruit, délais).

---

## 1) Modèle MVP

### Vérité (fact) vs croyance (belief)
- Le monde enregistre un **Fact** : “C a raid B à J6”.
- Chaque faction X obtient une **Belief** sur ce fact :  
  “Je pense que **A** a orchestré le raid” avec une **confidence**.

Ensuite :
- les décisions ArcManager (incident, escalade, third party, offers) utilisent **PerceivedHeat** (dérivé des beliefs),
- les quêtes “investigate / proof / propaganda” modifient les beliefs (et donc le futur).

---

## 2) Structures de données

### `KnowledgeEvent` (la vérité du monde)
```gdscript
class_name KnowledgeEvent
extends RefCounted

var id: StringName
var day: int
var type: StringName            # RAID/SABOTAGE/TRIBUTE_MISS/TREATY_BREACH/...
var true_actor: StringName      # qui a vraiment fait l’action
var true_target: StringName
var severity: float = 1.0       # 0.5..2.0
var pair_key: StringName        # "A|B" (actor/target)
var meta: Dictionary = {}       # poi_id, arc_id, etc.
```

### `BeliefEntry` (ce que X croit à propos d’un event)
```gdscript
class_name BeliefEntry
extends RefCounted

var event_id: StringName
var observer_id: StringName     # faction X qui croit
var claimed_actor: StringName   # qui X pense être l’acteur
var claimed_target: StringName
var claim_type: StringName      # RAID/...
var confidence: float = 0.0     # 0..1
var source: StringName = &"RUMOR"   # DIRECT/WITNESS/ALLY/RUMOR/PROPAGANDA
var bias_tag: StringName = &""      # "anti_magic", "anti_orc", etc.
var last_update_day: int = 0
```

### `Rumor` (un “paquet” qui crée/booste des beliefs)
```gdscript
class_name Rumor
extends RefCounted

var id: StringName
var day: int
var seed_id: StringName         # qui lance la rumeur (C, un broker, etc.)
var claim_actor: StringName
var claim_target: StringName
var claim_type: StringName
var strength: float = 0.6       # force du message
var credibility: float = 0.5    # crédibilité perçue (source + réputation)
var malicious: bool = false
var related_event_id: StringName = &""  # si rumeur “sur” un fact
```

---

## 3) Le système : `FactionKnowledgeModel`

Tu as deux dictionnaires principaux :

```gdscript
# FactionKnowledgeModel.gd
var events_by_id: Dictionary[StringName, KnowledgeEvent] = {}
var beliefs_by_faction: Dictionary[StringName, Dictionary] = {} # X -> event_id -> BeliefEntry

# agrégats rapides (pour ArcManager) :
var perceived_hostile_heat: Dictionary[StringName, Dictionary] = {} 
# X -> other -> float (hostile “perçu”)
```

---

## 4) Comment une faction “perçoit” un fact

### A) Visibilité / délai / biais (MVP)
Une faction X apprend un fact avec une probabilité + une confidence initiale :

- **DIRECT** : si X est actor/target → confidence 0.9
- **ALLY** : si X est allié du target → 0.6
- **RUMOR** : sinon → 0.2..0.5 selon diplomatie/espionnage du monde

Puis on applique un **biais** selon :
- personnalité (paranoïa, diplomatie),
- axes (divergence → plus crédule aux rumeurs hostiles),
- historique (ArcNotebook : “A a déjà trahi”).

### B) Une formule simple
```gdscript
confidence = base
  + 0.25 * intel(observer)
  + 0.20 * paranoia(observer)
  + 0.15 * hostility_bias(observer, claimed_actor)
  - 0.25 * diplomacy(observer)
```
Clamp 0..1.

---

## 5) PerceivedHeat (pour casser l’escalade binaire)

ArcManager ne doit pas seulement regarder “hostile facts”, mais :
- “**B croit à 70% que A est derrière**”
- “C diffuse une version différente”
- “A peut chercher des preuves pour inocenter”

### Agrégat rapide (par paire, par observateur)
Pour une faction X et un autre Y :

```gdscript
perceived_hostile_heat[X][Y] =
  Σ over beliefs where claimed_actor == Y and claim is hostile:
      confidence * severity * decay(day - event_day)
```

**C’est ça** que tu utilises dans :
- `compute_arc_event_chance()`,
- `third party mediator/opportunist triggers`,
- “suspicion spillover” (mais au lieu d’un delta fixe, tu mets un delta proportionnel à la croyance).

---

## 6) Quêtes qui modifient les beliefs (le gameplay)

### Types d’offres “Knowledge”
1) **Investigate / Proof** (réduit la rumeur, augmente vérité)
2) **Counter-propaganda / Prove innocence** (baisse confidence sur claim faux)
3) **Fabricate evidence** (augmente confidence sur claim faux → escalade)

#### Context standard
```gdscript
"is_knowledge_offer": true
"related_event_id": event_id
"rumor_id": rumor_id (optionnel)
"observer_id": B (souvent)
"claimed_actor": A
"true_actor": C (optionnel si c’est caché au joueur)
"knowledge_action": &"INVESTIGATE"|"PROVE_INNOCENCE"|"FORGE_EVIDENCE"
```

### Effet sur beliefs (MVP)
- LOYAL INVESTIGATE : `confidence -= 0.35` si claim faux, sinon `confidence += 0.25`
- TRAITOR FORGE : `confidence += 0.35` même si faux
- NEUTRAL : +-0.15

Et si confidence passe sous 0.2 : la rumeur “tombe”.  
Si elle passe au-dessus de 0.8 : “croyance forte” → peut déclencher WAR.

---

## 7) Intégration dans tes deltas relations / arc states

### Règle clé : **les deltas relationnels viennent du “perçu”**
Au lieu de :
> “B→A tension +3, grievance +2”

Tu fais :
```gdscript
delta_tension = round(3.0 * belief.confidence)
delta_griev   = round(2.0 * belief.confidence)
```

Et si plus tard une quête prouve l’inverse :
- tu réduis la confidence
- et tu appliques un petit delta inverse (pas forcément symétrique) :
  - B→A tension -2, grievance -1
  - B→source trust -3 (si la source était une rumeur/propagande)

---

## 8) Le rôle “3 factions” devient naturel

Exemple canonique :
- Fact : **C raid B**
- Rumor : **A hired C** (seed: C ou un broker)
- Belief chez B : “A est derrière” (confidence 0.6)
- Résultats :
  - B s’énerve contre A (sans preuve)
  - Offer à 3 factions :
    - **Investigate** (B demande au joueur)
    - **Prove innocence** (A demande au joueur)
    - **Forge evidence** (C propose au joueur)

Ça évite l’escalade binaire “faits → vengeance” : tu as **doute / manipulation / arbitrage**.

---

## 9) MVP “low cost” pour toi (recommandé)
Pour ne pas exploser la complexité :
- ne stocke pas 10 000 beliefs : garde seulement les **N derniers events importants par paire** (ex N=30).
- agrège en continu `perceived_hostile_heat[X][Y]` (cache), recalcul léger 1 fois/jour.
- utilise ArcNotebook pour l’historique “macro” (counters), KnowledgeModel pour le “micro” (rumeurs récentes).

---

Si tu veux, prochaine brique logique : je te donne une implémentation compacte des 3 fonctions essentielles :
1) `register_fact(event)`  
2) `inject_rumor(rumor)`  
3) `apply_knowledge_resolution(context, choice)` (qui modifie beliefs + relations)

Moi:
prochaine brique logique : je te donne une implémentation compacte des 3 fonctions essentielles :

register_fact(event)

inject_rumor(rumor)

apply_knowledge_resolution(context, choice) (qui modifie beliefs + relations)

ChatGPT:
Voici une implémentation **compacte** (MVP) des 3 fonctions, sous forme d’un script `FactionKnowledgeModel.gd`.  
Elle est volontairement “light” : pas de dépendances lourdes, et elle s’intègre à tes `relations` existantes + ton ArcNotebook si tu veux.

> Hypothèses minimales :  
> - `relations[f1][f2]` est un `FactionRelationScore` avec `trust/tension/grievance/relation`.  
> - `choice` ∈ `&"LOYAL"|"NEUTRAL"|"TRAITOR"`.  
> - Le `context` de quête contient au moins `observer_id`, `claimed_actor`, `claimed_target`, `related_event_id` (optionnel), `knowledge_action`.

---

## `FactionKnowledgeModel.gd`

```gdscript
class_name FactionKnowledgeModel
extends RefCounted

# --- storage ---
var events_by_id: Dictionary = {}                # event_id -> KnowledgeEvent(Dictionary)
var beliefs_by_faction: Dictionary = {}          # observer -> (event_id -> BeliefEntry(Dictionary))
var rumors_by_id: Dictionary = {}                # rumor_id -> Rumor(Dictionary)

# config
var decay_per_day: float = 0.93
var k_norm: float = 0.35                         # for softcap if needed

# ------------------------------------------------------------
# 1) register_fact(event)
# ------------------------------------------------------------
func register_fact(event: Dictionary) -> void:
	# Expected keys:
	# id, day, type, true_actor, true_target, severity (optional), pair_key (optional), meta(optional)
	var eid: StringName = StringName(event.get("id", &""))
	if eid == &"":
		eid = StringName("evt_%s_%s" % [str(event.get("day", 0)), str(randi())])
		event["id"] = eid

	if not event.has("severity"):
		event["severity"] = 1.0

	if not event.has("pair_key"):
		var a := String(event.get("true_actor", ""))
		var b := String(event.get("true_target", ""))
		event["pair_key"] = StringName((a <= b) ? (a + "|" + b) : (b + "|" + a))

	events_by_id[eid] = event


# ------------------------------------------------------------
# 2) inject_rumor(rumor)
# ------------------------------------------------------------
func inject_rumor(rumor: Dictionary, observers: Array, profiles: Dictionary = {}) -> void:
	# Expected keys:
	# id, day, seed_id, claim_actor, claim_target, claim_type, strength(0..1), credibility(0..1),
	# malicious(bool), related_event_id(optional)
	var rid: StringName = StringName(rumor.get("id", &""))
	if rid == &"":
		rid = StringName("rum_%s_%s" % [str(rumor.get("day", 0)), str(randi())])
		rumor["id"] = rid

	rumor["strength"] = clampf(float(rumor.get("strength", 0.6)), 0.0, 1.0)
	rumor["credibility"] = clampf(float(rumor.get("credibility", 0.5)), 0.0, 1.0)
	rumors_by_id[rid] = rumor

	var day := int(rumor.get("day", 0))
	var claim_actor: StringName = StringName(rumor.get("claim_actor", &""))
	var claim_target: StringName = StringName(rumor.get("claim_target", &""))
	var claim_type: StringName = StringName(rumor.get("claim_type", &""))

	for obs_id in observers:
		var observer: StringName = StringName(obs_id)
		_ensure_observer(observer)

		# base confidence from rumor strength + credibility
		var base := 0.10 + 0.55 * float(rumor["strength"]) * float(rumor["credibility"])

		# bias from personality (optional)
		# keys expected in profile personality dict: paranoia, diplomacy, intel
		var paranoia := _get_personality(profiles, observer, &"paranoia", 0.5)
		var diplomacy := _get_personality(profiles, observer, &"diplomacy", 0.5)
		var intel := _get_personality(profiles, observer, &"intel", 0.5)

		var conf := base + 0.20*intel + 0.20*paranoia - 0.20*diplomacy
		conf = clampf(conf, 0.05, 0.95)

		# Each rumor can either attach to a real event or live alone
		var event_id: StringName = StringName(rumor.get("related_event_id", &""))
		if event_id == &"":
			# create synthetic event id for belief tracking
			event_id = StringName("syn_%s_%s" % [str(day), String(rid)])
			if not events_by_id.has(event_id):
				events_by_id[event_id] = {
					"id": event_id,
					"day": day,
					"type": claim_type,
					"true_actor": &"",      # unknown/none
					"true_target": claim_target,
					"severity": 1.0,
					"pair_key": StringName((String(claim_actor) <= String(claim_target)) ? (String(claim_actor)+"|"+String(claim_target)) : (String(claim_target)+"|"+String(claim_actor))),
					"meta": {"rumor_only": true, "rumor_id": rid}
				}

		# write belief
		var b := {
			"event_id": event_id,
			"observer_id": observer,
			"claimed_actor": claim_actor,
			"claimed_target": claim_target,
			"claim_type": claim_type,
			"confidence": conf,
			"source": &"RUMOR",
			"bias_tag": StringName(rumor.get("bias_tag", &"")),
			"last_update_day": day,
			"rumor_id": rid
		}
		beliefs_by_faction[observer][event_id] = b


# ------------------------------------------------------------
# 3) apply_knowledge_resolution(context, choice)
# ------------------------------------------------------------
func apply_knowledge_resolution(
	context: Dictionary,
	choice: StringName,
	relations: Dictionary,
	profiles: Dictionary = {},
	day: int = -1
) -> void:
	# context expected:
	# observer_id, claimed_actor, claimed_target, knowledge_action
	# related_event_id optional, rumor_id optional
	var observer: StringName = StringName(context.get("observer_id", &""))
	var claimed_actor: StringName = StringName(context.get("claimed_actor", &""))
	var claimed_target: StringName = StringName(context.get("claimed_target", &""))
	var action: StringName = StringName(context.get("knowledge_action", &"INVESTIGATE"))
	var eid: StringName = StringName(context.get("related_event_id", &""))

	if day < 0:
		day = int(context.get("day", 0))

	_ensure_observer(observer)

	# ensure belief exists (if quest created from rumor, we should have it; but be safe)
	if eid == &"":
		# try from rumor_id
		var rid: StringName = StringName(context.get("rumor_id", &""))
		if rid != &"" and rumors_by_id.has(rid):
			eid = StringName(rumors_by_id[rid].get("related_event_id", &""))
	if eid == &"":
		# fallback synthetic
		eid = StringName("syn_res_%s_%s" % [str(day), str(randi())])
		events_by_id[eid] = {"id": eid, "day": day, "type": &"", "true_actor": &"", "true_target": claimed_target, "severity": 1.0}

	var belief := beliefs_by_faction[observer].get(eid, null)
	if belief == null:
		belief = {
			"event_id": eid,
			"observer_id": observer,
			"claimed_actor": claimed_actor,
			"claimed_target": claimed_target,
			"claim_type": StringName(context.get("claim_type", &"")),
			"confidence": 0.35,
			"source": &"RUMOR",
			"bias_tag": &"",
			"last_update_day": day
		}
		beliefs_by_faction[observer][eid] = belief

	# determine if claim matches truth (if known)
	var ev: Dictionary = events_by_id.get(eid, {})
	var true_actor: StringName = StringName(ev.get("true_actor", &""))
	var truth_known := (true_actor != &"")
	var claim_is_true := truth_known and (true_actor == claimed_actor)

	# delta confidence based on knowledge_action + choice
	var dconf := 0.0
	match action:
		&"INVESTIGATE":
			if choice == &"LOYAL":   dconf = +0.25 if claim_is_true else -0.35
			elif choice == &"NEUTRAL":dconf = +0.10 if claim_is_true else -0.15
			else:                   dconf = +0.35  # forge/lie: push confidence upward
		&"PROVE_INNOCENCE":
			# target is "claimed_actor is innocent"
			# so we reduce confidence in the hostile claim
			if choice == &"LOYAL":   dconf = -0.40
			elif choice == &"NEUTRAL":dconf = -0.18
			else:                   dconf = +0.20  # sabotage defense
		&"FORGE_EVIDENCE":
			if choice == &"LOYAL":   dconf = +0.35
			elif choice == &"NEUTRAL":dconf = +0.15
			else:                   dconf = +0.45
		_:
			dconf = -0.15 if choice == &"LOYAL" else 0.0

	# apply personality modulation (optional): paranoia amplifies, diplomacy dampens
	var paranoia := _get_personality(profiles, observer, &"paranoia", 0.5)
	var diplomacy := _get_personality(profiles, observer, &"diplomacy", 0.5)
	var mult := clampf(1.0 + 0.25*(paranoia - 0.5) - 0.25*(diplomacy - 0.5), 0.75, 1.25)

	var old_conf := float(belief["confidence"])
	var new_conf := clampf(old_conf + dconf*mult, 0.0, 1.0)
	belief["confidence"] = new_conf
	belief["last_update_day"] = day
	beliefs_by_faction[observer][eid] = belief

	# Apply relationship deltas based on perceived belief change (asymmetric: observer -> claimed_actor)
	if claimed_actor != &"" and observer != &"" and relations.has(observer) and relations[observer].has(claimed_actor):
		var r: FactionRelationScore = relations[observer][claimed_actor]

		# hostile claim: higher confidence => higher tension/grievance and lower trust/relation
		# We use delta_conf to determine direction of change.
		var delta_conf := new_conf - old_conf
		var sev := float(ev.get("severity", 1.0))
		var scale := 10.0 * sev

		# if we're increasing confidence in hostile claim => worsen relation
		# if decreasing confidence => ease relation a bit
		r.tension = int(clampi(r.tension + int(round(+3.0 * delta_conf * scale)), 0, 100))
		r.grievance = int(clampi(r.grievance + int(round(+2.0 * delta_conf * scale)), 0, 100))
		r.trust = int(clampi(r.trust - int(round(+2.0 * delta_conf * scale)), 0, 100))
		r.relation = int(clampi(r.relation - int(round(+2.0 * delta_conf * scale)), -100, 100))

		# If we strongly debunked a rumor: small bonus
		if old_conf >= 0.6 and new_conf <= 0.25:
			r.tension = int(clampi(r.tension - 3, 0, 100))
			r.trust = int(clampi(r.trust + 2, 0, 100))

	# Optional: if source is propaganda and was debunked, reduce trust in seed_id (not implemented here)


# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
func _ensure_observer(observer: StringName) -> void:
	if not beliefs_by_faction.has(observer):
		beliefs_by_faction[observer] = {}

func _get_personality(profiles: Dictionary, faction_id: StringName, key: StringName, default_val: float) -> float:
	var p = profiles.get(faction_id, null)
	if p == null:
		return default_val
	# supports either Dictionary profiles, or FactionProfile with get_personality()
	if p is Dictionary:
		var d: Dictionary = p.get("personality", {})
		return float(d.get(key, default_val))
	if p.has_method("get_personality"):
		return float(p.get_personality(key, default_val))
	return default_val
```

---

## Notes d’intégration (très pratiques)

### A) Comment alimenter `register_fact`
Quand un arc event “réel” arrive (raid/sabotage/tribute miss), tu appelles :

```gdscript
knowledge.register_fact({
	"id": &"evt_123",
	"day": day,
	"type": ArcDecisionUtil.ARC_RAID,
	"true_actor": attacker_id,
	"true_target": defender_id,
	"severity": 1.0,
	"meta": {"arc_id": arc_id}
})
```

### B) Comment injecter une rumeur (tierce partie / propagande)
```gdscript
knowledge.inject_rumor({
	"day": day,
	"seed_id": C,
	"claim_actor": A,  # "A est derrière"
	"claim_target": B,
	"claim_type": ArcDecisionUtil.ARC_RAID,
	"strength": 0.7,
	"credibility": 0.55,
	"malicious": true,
	"related_event_id": &"evt_123"
}, observers_array, faction_profiles)
```

### C) Comment appliquer une résolution de quête “knowledge”
Dans `QuestManager.resolve_quest` si `context.is_knowledge_offer` :

```gdscript
knowledge.apply_knowledge_resolution(inst.context, choice, relations, faction_profiles, world_day)
```

---

Si tu veux, prochaine brique logique : une fonction `get_perceived_heat(observer, other, day)` + un mini test qui prouve que **2 rumeurs + 1 debunk** font chuter la “heat perçue” et empêchent une escalade A↔B.

Moi:
prochaine brique logique : une fonction get_perceived_heat(observer, other, day) + un mini test qui prouve que 2 rumeurs + 1 debunk font chuter la “heat perçue” et empêchent une escalade A↔B.

ChatGPT:
Voici la brique **MVP** : `get_perceived_heat(observer, other, day)` + un **mini test** démontrant que **2 rumeurs** font monter la heat perçue, puis **1 debunk** la fait chuter **sous un seuil**, ce qui “empêche l’escalade” (au sens : ArcManager n’aurait plus de raison de déclencher un incident).

---

## 1) Patch `FactionKnowledgeModel.gd` : `get_perceived_heat()`

Ajoute ça à ton `FactionKnowledgeModel.gd` :

```gdscript
# Types considérés comme hostiles (ajoute/retire selon ton jeu)
const HOSTILE_TYPES := {
	&"RAID": true,
	&"SABOTAGE": true,
	&"DECLARE_WAR": true,
	&"war.capture_poi": true,
	&"war.collect_tribute_by_force": true,
}

func get_perceived_heat(observer: StringName, other: StringName, day: int) -> float:
	# Retourne un score 0..100 : "à quel point observer pense que other est hostile (récemment)"
	if not beliefs_by_faction.has(observer):
		return 0.0

	var sum := 0.0
	for eid in beliefs_by_faction[observer].keys():
		var b: Dictionary = beliefs_by_faction[observer][eid]
		if StringName(b.get("claimed_actor", &"")) != other:
			continue

		var ctype: StringName = StringName(b.get("claim_type", &""))
		if not HOSTILE_TYPES.has(ctype):
			continue

		var conf := clampf(float(b.get("confidence", 0.0)), 0.0, 1.0)

		var ev: Dictionary = events_by_id.get(StringName(b.get("event_id", eid)), {})
		var ev_day := int(ev.get("day", int(b.get("last_update_day", day))))
		var age := max(0, day - ev_day)

		var sev := float(ev.get("severity", 1.0))
		var decay := pow(decay_per_day, float(age))

		sum += conf * sev * decay

	# Saturation douce -> 0..100 (évite divergence)
	return 100.0 * (1.0 - exp(-sum * 0.9))
```

### (Optionnel mais recommandé) : faire “stacker” 2 rumeurs sur le même event
Sinon ta 2e rumeur écrase la 1ère. Dans `inject_rumor()`, remplace l’affectation finale par un merge :

```gdscript
var existing := beliefs_by_faction[observer].get(event_id, null)
if existing != null:
	var oldc := float(existing.get("confidence", 0.0))
	# noisy-OR : deux rumeurs indépendantes renforcent la croyance
	var merged := 1.0 - (1.0 - oldc) * (1.0 - conf)
	existing["confidence"] = clampf(merged, 0.0, 1.0)
	existing["last_update_day"] = day
	existing["source"] = &"RUMOR"
	beliefs_by_faction[observer][event_id] = existing
else:
	beliefs_by_faction[observer][event_id] = b
```

---

## 2) Mini test : 2 rumeurs + 1 debunk

### `tests/KnowledgeRumorDebunkHeatTest.gd`

```gdscript
extends Node
class_name KnowledgeRumorDebunkHeatTest

func _ready() -> void:
	_test_two_rumors_then_debunk_reduces_heat_below_threshold()
	print("\n✅ KnowledgeRumorDebunkHeatTest: OK\n")
	get_tree().quit()


func _test_two_rumors_then_debunk_reduces_heat_below_threshold() -> void:
	var knowledge := FactionKnowledgeModel.new()

	var A := &"A"
	var B := &"B"
	var C := &"C"

	# Profiles (minimum) : B est un peu parano et pas trop diplomate => croit plus vite aux rumeurs
	var profiles := {
		B: {"personality": {&"paranoia": 0.7, &"diplomacy": 0.3, &"intel": 0.5}}
	}

	# Relations (optionnel, mais apply_knowledge_resolution peut les modifier)
	var relations := {}
	relations[B] = {}
	relations[B][A] = FactionRelationScore.new()
	relations[B][A].trust = 40
	relations[B][A].tension = 10
	relations[B][A].grievance = 5
	relations[B][A].relation = 0

	# 1) Fact : le vrai raid est C -> B (jour 1)
	knowledge.register_fact({
		"id": &"evt_1",
		"day": 1,
		"type": &"RAID",
		"true_actor": C,
		"true_target": B,
		"severity": 1.0
	})

	# 2) Rumor #1 : "A a raid B" (jour 2) -> observateur = B
	knowledge.inject_rumor({
		"id": &"rum_1",
		"day": 2,
		"seed_id": C,
		"claim_actor": A,
		"claim_target": B,
		"claim_type": &"RAID",
		"strength": 0.7,
		"credibility": 0.55,
		"malicious": true,
		"related_event_id": &"evt_1"
	}, [B], profiles)

	var heat_after_1 := knowledge.get_perceived_heat(B, A, 2)

	# 3) Rumor #2 : même claim (jour 3) -> renforce la croyance
	knowledge.inject_rumor({
		"id": &"rum_2",
		"day": 3,
		"seed_id": &"BROKER",
		"claim_actor": A,
		"claim_target": B,
		"claim_type": &"RAID",
		"strength": 0.65,
		"credibility": 0.55,
		"malicious": true,
		"related_event_id": &"evt_1"
	}, [B], profiles)

	var heat_after_2 := knowledge.get_perceived_heat(B, A, 3)

	_assert(heat_after_2 > heat_after_1, "heat should increase after 2nd rumor (%.1f -> %.1f)" % [heat_after_1, heat_after_2])

	# Seuil “ArcManager déclencherait un incident”
	var INCIDENT_THRESHOLD := 25.0
	_assert(heat_after_2 >= INCIDENT_THRESHOLD, "after 2 rumors, heat should be high enough to trigger incident (heat=%.1f)" % heat_after_2)

	# 4) Debunk via INVESTIGATE LOYAL (jour 4) : comme true_actor=C, claim(A) est faux => confidence baisse
	knowledge.apply_knowledge_resolution({
		"observer_id": B,
		"claimed_actor": A,
		"claimed_target": B,
		"claim_type": &"RAID",
		"knowledge_action": &"INVESTIGATE",
		"related_event_id": &"evt_1",
		"day": 4
	}, &"LOYAL", relations, profiles, 4)

	var heat_after_debunk := knowledge.get_perceived_heat(B, A, 4)

	_assert(heat_after_debunk < heat_after_2, "heat should drop after debunk (%.1f -> %.1f)" % [heat_after_2, heat_after_debunk])
	_assert(heat_after_debunk < INCIDENT_THRESHOLD, "debunk should drop heat below incident threshold (heat=%.1f)" % heat_after_debunk)

	# Donc : ArcManager/compute_arc_event_chance, basé sur perceived_heat, ne déclenche plus “naturellement” l’escalade.


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

### Intégration côté ArcManager (1 ligne utile)
À la place de “heat hostile factuel”, tu utilises :
- `heat = knowledge.get_perceived_heat(observer=B, other=A, day)`
et tu branches ça dans `compute_arc_event_chance()` ou `compute_priority_targets()`.

Si tu veux, prochaine brique logique : un mini mapping “rumeur → offers” (PROVE INNOCENCE / INVESTIGATE / FORGE EVIDENCE) basé sur `heat` et `confidence` pour générer automatiquement les quêtes à 3 factions.

Moi:
prochaine brique logique : un mini mapping “rumeur → offers” (PROVE INNOCENCE / INVESTIGATE / FORGE EVIDENCE) basé sur heat et confidence pour générer automatiquement les quêtes à 3 factions

ChatGPT:
Voici un **mini mapping “rumeur → offers”** qui génère automatiquement des quêtes **à 3 factions** (victime/observateur ↔ bouc-émissaire ↔ source/tiers), basé sur **heat** et **confidence**.

L’idée : à partir d’une rumeur (ou d’un belief), tu spawns un petit “bundle” :
- **INVESTIGATE** (B veut la vérité)
- **PROVE_INNOCENCE** (A veut se blanchir)
- **FORGE_EVIDENCE** (C veut faire condamner A)

---

# 1) Règles de décision (heat + confidence)

### Seuils (V1)
- `heat < 15` : rien (trop faible)
- `15 ≤ heat < 25` : 1 offer max (investigate OU prove innocence)
- `25 ≤ heat < 40` : 1–2 offers (investigate + prove innocence)
- `heat ≥ 40` : 2–3 offers (ajoute forge si possible)

### Conditions par action
- **INVESTIGATE** : si `conf ≥ 0.35` et `heat ≥ 15`
- **PROVE_INNOCENCE** : si `conf ≥ 0.45` et `heat ≥ 25`
- **FORGE_EVIDENCE** : si rumeur malveillante *et* `conf ≤ 0.85` *et* `heat ≥ 30`  
  (sinon c’est inutile : si la croyance est déjà ~max, “forcer” n’apporte rien)

### Tier + deadline (V1)
- `tier = clamp(1 + floor(heat/20) + (conf>0.6?1:0), 1..5)`
- `deadline_days = (heat >= 40 ? 4 : heat >= 25 ? 6 : 8)`

---

# 2) Mapping action → familles de quêtes (templates)

V1 simple (3 variantes par action) :

```gdscript
const KNOWLEDGE_TEMPLATES := {
	&"INVESTIGATE": [
		&"knowledge.investigate.stealth",    # infiltrer / récupérer des preuves
		&"knowledge.investigate.diplomacy",  # interroger / convaincre témoins
		&"knowledge.investigate.retrieve",   # récupérer un objet de preuve
	],
	&"PROVE_INNOCENCE": [
		&"knowledge.innocence.diplomacy",    # audience / plaidoirie / négociation
		&"knowledge.innocence.escort",       # escorter un émissaire / témoin
		&"knowledge.innocence.retrieve",     # récupérer contre-preuve
	],
	&"FORGE_EVIDENCE": [
		&"knowledge.forge.stealth",          # falsifier sceaux / lettres
		&"knowledge.forge.retrieve",         # voler un artefact “incriminant”
		&"knowledge.forge.sabotage",         # mise en scène / sabotage cadré
	],
}
```

> Ces ids peuvent être des “quest types” que ton `QuestGenerator` comprend, ou des templates runtime via ton `_build_template_fallback()`.

---

# 3) `KnowledgeOfferFactory.spawn_offers_for_rumor(...)` (compatible QuestPool)

```gdscript
# KnowledgeOfferFactory.gd
class_name KnowledgeOfferFactory
extends RefCounted

const HEAT_LOW := 15.0
const HEAT_MED := 25.0
const HEAT_HIGH := 40.0

static func spawn_offers_for_rumor(
	knowledge: FactionKnowledgeModel,
	rumor: Dictionary,
	observers: Array,                 # factions qui "reçoivent" la rumeur (ex: [B] ou alliés)
	day: int,
	quest_pool,                       # ton QuestPool (ou retourne un Array[QuestInstance])
	arc_notebook: ArcNotebook,
	profiles: Dictionary = {},
	params: Dictionary = {}
) -> Array:
	var out: Array = []

	var rid: StringName = StringName(rumor.get("id", &""))
	var claimed_actor: StringName = StringName(rumor.get("claim_actor", &""))
	var claimed_target: StringName = StringName(rumor.get("claim_target", &""))
	var claim_type: StringName = StringName(rumor.get("claim_type", &"RAID"))
	var seed_id: StringName = StringName(rumor.get("seed_id", &""))
	var malicious := bool(rumor.get("malicious", false))
	var event_id: StringName = StringName(rumor.get("related_event_id", &""))

	# cooldown anti-spam par rumeur/pair
	var key := StringName("know|" + String(rid))
	var cd := int(params.get("knowledge_offer_cooldown_days", 5))
	if arc_notebook.has_method("can_spawn_knowledge_offer") and not arc_notebook.can_spawn_knowledge_offer(key, day, cd):
		return out

	var max_offers := int(params.get("knowledge_bundle_max", 3))

	for obs in observers:
		var observer: StringName = StringName(obs)

		var heat := knowledge.get_perceived_heat(observer, claimed_actor, day)
		if heat < HEAT_LOW:
			continue

		# récupère la confidence du belief associé (si dispo)
		var conf := _get_confidence(knowledge, observer, event_id, claimed_actor, claim_type)

		var deadline_days := (heat >= HEAT_HIGH) ? 4 : (heat >= HEAT_MED) ? 6 : 8
		var tier := clampi(1 + int(floor(heat / 20.0)) + (conf >= 0.60 ? 1 : 0), 1, 5)

		# 1) INVESTIGATE (giver = observer/victim)
		if conf >= 0.35 and heat >= HEAT_LOW and out.size() < max_offers:
			out.append(_spawn_knowledge_offer(
				&"INVESTIGATE",
				observer,                 # giver
				claimed_actor,             # antagonist “suspect”
				seed_id,                   # third party (source)
				observer, claimed_actor, claimed_target,
				event_id, rid,
				heat, conf, tier, deadline_days, claim_type
			))

		# 2) PROVE_INNOCENCE (giver = claimed_actor, influence observer=B)
		if conf >= 0.45 and heat >= HEAT_MED and out.size() < max_offers:
			out.append(_spawn_knowledge_offer(
				&"PROVE_INNOCENCE",
				claimed_actor,             # giver
				observer,                  # antagonist “accusateur”
				seed_id,
				observer, claimed_actor, claimed_target,
				event_id, rid,
				heat, conf, tier, deadline_days, claim_type
			))

		# 3) FORGE_EVIDENCE (giver = seed/tiers, antagonist = claimed_actor)
		# uniquement si ça a un intérêt (pas déjà conviction maximale)
		if malicious and heat >= 30.0 and conf <= 0.85 and out.size() < max_offers:
			out.append(_spawn_knowledge_offer(
				&"FORGE_EVIDENCE",
				seed_id,                  # giver (propagandiste / opportuniste / vraie faction C)
				claimed_actor,            # antagonist (celui qu'on incrimine)
				observer,                 # third party = la cible à convaincre
				observer, claimed_actor, claimed_target,
				event_id, rid,
				heat, conf, tier, deadline_days, claim_type
			))

	# filtre null + ajout au pool
	var final: Array = []
	for inst in out:
		if inst != null:
			final.append(inst)
			if quest_pool != null and quest_pool.has_method("try_add_offer"):
				quest_pool.try_add_offer(inst)

	# mark cooldown
	if arc_notebook.has_method("mark_knowledge_offer_spawned"):
		arc_notebook.mark_knowledge_offer_spawned(key, day)

	return final


static func _spawn_knowledge_offer(
	knowledge_action: StringName,
	giver: StringName,
	antagonist: StringName,
	third_party: StringName,
	observer_id: StringName,
	claimed_actor: StringName,
	claimed_target: StringName,
	event_id: StringName,
	rumor_id: StringName,
	heat: float,
	conf: float,
	tier: int,
	deadline_days: int,
	claim_type: StringName
) -> QuestInstance:
	if giver == &"" or claimed_actor == &"" or claimed_target == &"":
		return null

	# Choix d’un “quest type/template id” (au hasard simple)
	var options: Array = KNOWLEDGE_TEMPLATES.get(knowledge_action, [])
	if options.is_empty():
		return null
	var qtype: StringName = options[randi() % options.size()]

	# Ici tu peux appeler ton ArcOfferFactory / QuestGenerator. MVP: template runtime minimal.
	var template := ArcOfferFactory._build_template_fallback(String(qtype), tier, deadline_days)

	var ctx := {
		"is_knowledge_offer": true,
		"knowledge_action": knowledge_action,
		"observer_id": observer_id,
		"claimed_actor": claimed_actor,
		"claimed_target": claimed_target,
		"claim_type": claim_type,

		"related_event_id": event_id,
		"rumor_id": rumor_id,

		"giver_faction_id": giver,
		"antagonist_faction_id": antagonist,
		"third_party_id": third_party,

		"stake": {"heat": heat, "confidence": conf, "tier": tier},
		"expires_in_days": deadline_days,

		# profil de résolution “knowledge” (tu peux le router vers apply_knowledge_resolution)
		"resolution_profile_id": &"knowledge_default"
	}

	var inst := QuestInstance.new(template, ctx)
	inst.status = "AVAILABLE"
	inst.started_on_day = int(ctx.get("day", 0))
	inst.expires_on_day = inst.started_on_day + deadline_days
	return inst


static func _get_confidence(knowledge: FactionKnowledgeModel, observer: StringName, event_id: StringName, claimed_actor: StringName, claim_type: StringName) -> float:
	# cherche un belief précis, sinon fallback
	if knowledge.beliefs_by_faction.has(observer):
		if knowledge.beliefs_by_faction[observer].has(event_id):
			var b: Dictionary = knowledge.beliefs_by_faction[observer][event_id]
			if StringName(b.get("claimed_actor", &"")) == claimed_actor and StringName(b.get("claim_type", &"")) == claim_type:
				return clampf(float(b.get("confidence", 0.35)), 0.0, 1.0)
	return 0.35
```

### Deux micro-ajouts ArcNotebook (cooldown knowledge)
```gdscript
# ArcNotebook.gd (mini)
var knowledge_spawn_cooldowns: Dictionary = {} # key -> last_day

func can_spawn_knowledge_offer(key: StringName, day: int, cooldown_days: int) -> bool:
	var last := int(knowledge_spawn_cooldowns.get(key, -999999))
	return (day - last) >= cooldown_days

func mark_knowledge_offer_spawned(key: StringName, day: int) -> void:
	knowledge_spawn_cooldowns[key] = day
```

---

# 4) Comment ça donne des “quêtes à 3 factions”
Exemple C fait un raid opportuniste sur B, mais lance une rumeur “A est derrière” :

- **INVESTIGATE** : giver=B, antagonist=A, third_party=C (source)
- **PROVE_INNOCENCE** : giver=A, antagonist=B, third_party=C
- **FORGE_EVIDENCE** : giver=C, antagonist=A, third_party=B (cible à convaincre)

Chaque quête a un `context` standard (`observer_id`, `claimed_actor`, `rumor_id`, etc.), ce qui permet ensuite :
- `QuestManager.resolve_quest()` → `knowledge.apply_knowledge_resolution(context, choice, relations, profiles, day)`

---

Si tu veux, prochaine brique logique : un test “bundle” qui vérifie qu’à `heat>=40` + `malicious=true`, on spawne bien 2–3 offers (avec giver/antagonist/third_party corrects), et qu’un debunk fait retomber `heat` et réduit automatiquement le bundle les jours suivants.

Moi:
prochaine brique logique : un test “bundle” qui vérifie qu’à heat>=40 + malicious=true, on spawne bien 2–3 offers (avec giver/antagonist/third_party corrects), et qu’un debunk fait retomber heat et réduit automatiquement le bundle les jours suivants.

ChatGPT:
Voici un **test “bundle”** (style identique aux précédents) qui vérifie :

1) avec `heat >= 40` + `malicious=true`, on spawn **2–3 offers**  
2) les offers ont les bons rôles **giver/antagonist/third_party** selon `knowledge_action`  
3) après un **debunk**, `heat` retombe et **le bundle est réduit** les jours suivants (ex: 0–1 offer, et plus de FORGE)

---

## `tests/KnowledgeBundleSpawnAndDebunkTest.gd`

```gdscript
extends Node
class_name KnowledgeBundleSpawnAndDebunkTest

# --- stubs (no dependency on your real QuestPool/ArcNotebook) ---
class TestQuestPool:
	var offers: Array = []
	func try_add_offer(inst) -> bool:
		offers.append(inst)
		return true

class TestArcNotebook:
	func can_spawn_knowledge_offer(_key: StringName, _day: int, _cooldown_days: int) -> bool:
		return true
	func mark_knowledge_offer_spawned(_key: StringName, _day: int) -> void:
		pass


func _ready() -> void:
	_test_bundle_spawns_then_debunk_reduces_bundle()
	print("\n✅ KnowledgeBundleSpawnAndDebunkTest: OK\n")
	get_tree().quit()


func _test_bundle_spawns_then_debunk_reduces_bundle() -> void:
	# Make randomness deterministic for qtype selection (factory uses randi()).
	seed(424242)

	var knowledge := FactionKnowledgeModel.new()

	var A := &"A"  # scapegoat
	var B := &"B"  # observer/victim
	var C := &"C"  # true actor

	# Profiles: B is more parano than diplomate => believes rumors more
	var profiles := {
		B: {"personality": {&"paranoia": 0.7, &"diplomacy": 0.3, &"intel": 0.5}}
	}

	# Minimal relations (used by apply_knowledge_resolution)
	var relations := {}
	relations[B] = {}
	relations[B][A] = FactionRelationScore.new()
	relations[B][A].trust = 40
	relations[B][A].tension = 10
	relations[B][A].grievance = 5
	relations[B][A].relation = 0

	# Fact: true raid is C -> B at day 1
	knowledge.register_fact({
		"id": &"evt_1",
		"day": 1,
		"type": &"RAID",
		"true_actor": C,
		"true_target": B,
		"severity": 1.0
	})

	# Rumor #1 (day 2): "A did it" (malicious)
	var rumor1 := {
		"id": &"rum_1",
		"day": 2,
		"seed_id": C,
		"claim_actor": A,
		"claim_target": B,
		"claim_type": &"RAID",
		"strength": 0.70,
		"credibility": 0.60,
		"malicious": true,
		"related_event_id": &"evt_1"
	}
	knowledge.inject_rumor(rumor1, [B], profiles)

	# Rumor #2 (day 3): reinforce the same claim, seed = BROKER
	var rumor2 := {
		"id": &"rum_2",
		"day": 3,
		"seed_id": &"BROKER",
		"claim_actor": A,
		"claim_target": B,
		"claim_type": &"RAID",
		"strength": 0.65,
		"credibility": 0.60,
		"malicious": true,
		"related_event_id": &"evt_1"
	}
	knowledge.inject_rumor(rumor2, [B], profiles)

	var heat_before := knowledge.get_perceived_heat(B, A, 3)
	_assert(heat_before >= 40.0, "precondition: heat should be >=40 after 2 rumors (heat=%.1f)" % heat_before)

	# Spawn bundle offers for rumor2
	var pool := TestQuestPool.new()
	var notebook := TestArcNotebook.new()

	var offers_before: Array = KnowledgeOfferFactory.spawn_offers_for_rumor(
		knowledge,
		rumor2,
		[B],
		3,
		pool,
		notebook,
		profiles,
		{"knowledge_bundle_max": 3, "knowledge_offer_cooldown_days": 0}
	)

	_assert(offers_before.size() >= 2 and offers_before.size() <= 3,
		"expected 2-3 offers at high heat, got %d" % offers_before.size())

	# Validate roles per knowledge_action
	var has_investigate := false
	var has_innocence := false
	var has_forge := false

	for inst in offers_before:
		var ctx: Dictionary = inst.context
		_assert(bool(ctx.get("is_knowledge_offer", false)), "offer must have is_knowledge_offer=true")

		var kact: StringName = StringName(ctx.get("knowledge_action", &""))
		var giver: StringName = StringName(ctx.get("giver_faction_id", &""))
		var ant: StringName = StringName(ctx.get("antagonist_faction_id", &""))
		var tp: StringName = StringName(ctx.get("third_party_id", &""))

		if kact == &"INVESTIGATE":
			has_investigate = true
			_assert(giver == B, "INVESTIGATE giver should be observer/victim B")
			_assert(ant == A, "INVESTIGATE antagonist should be claimed_actor A")
			_assert(tp == &"BROKER", "INVESTIGATE third_party should be rumor seed (BROKER)")
		elif kact == &"PROVE_INNOCENCE":
			has_innocence = true
			_assert(giver == A, "PROVE_INNOCENCE giver should be claimed_actor A")
			_assert(ant == B, "PROVE_INNOCENCE antagonist should be observer B")
			_assert(tp == &"BROKER", "PROVE_INNOCENCE third_party should be rumor seed (BROKER)")
		elif kact == &"FORGE_EVIDENCE":
			has_forge = true
			_assert(giver == &"BROKER", "FORGE_EVIDENCE giver should be seed (BROKER)")
			_assert(ant == A, "FORGE_EVIDENCE antagonist should be claimed_actor A")
			_assert(tp == B, "FORGE_EVIDENCE third_party should be observer/victim B")

	_assert(has_investigate, "bundle should include INVESTIGATE at heat>=40")
	_assert(has_innocence, "bundle should include PROVE_INNOCENCE at heat>=40")
	# FORGE is expected in most cases at malicious=true and heat>=40 (unless confidence already >0.85).
	_assert(has_forge or offers_before.size() == 2, "bundle should include FORGE_EVIDENCE unless confidence already saturated")

	# --- Debunk at day 4: PROVE_INNOCENCE LOYAL reduces confidence in the hostile claim ---
	knowledge.apply_knowledge_resolution({
		"observer_id": B,
		"claimed_actor": A,
		"claimed_target": B,
		"claim_type": &"RAID",
		"knowledge_action": &"PROVE_INNOCENCE",
		"related_event_id": &"evt_1",
		"day": 4
	}, &"LOYAL", relations, profiles, 4)

	var heat_after_debunk := knowledge.get_perceived_heat(B, A, 4)
	_assert(heat_after_debunk < heat_before, "heat should drop after debunk (%.1f -> %.1f)" % [heat_before, heat_after_debunk])
	_assert(heat_after_debunk < 40.0, "heat should drop below 'high heat' zone after debunk (heat=%.1f)" % heat_after_debunk)

	# --- Day 5: a new weak malicious rumor tries again, but bundle should be smaller due to debunk ---
	var rumor3 := {
		"id": &"rum_3",
		"day": 5,
		"seed_id": &"BROKER",
		"claim_actor": A,
		"claim_target": B,
		"claim_type": &"RAID",
		"strength": 0.40,
		"credibility": 0.50,
		"malicious": true,
		"related_event_id": &"evt_1"
	}
	knowledge.inject_rumor(rumor3, [B], profiles)

	var heat_day5 := knowledge.get_perceived_heat(B, A, 5)

	var pool2 := TestQuestPool.new()
	var offers_after: Array = KnowledgeOfferFactory.spawn_offers_for_rumor(
		knowledge,
		rumor3,
		[B],
		5,
		pool2,
		notebook,
		profiles,
		{"knowledge_bundle_max": 3, "knowledge_offer_cooldown_days": 0}
	)

	_assert(offers_after.size() <= offers_before.size() - 1,
		"bundle should be reduced after debunk (before=%d after=%d heat=%.1f)" % [offers_before.size(), offers_after.size(), heat_day5])

	# With lower heat/confidence, FORGE should usually not appear anymore.
	for inst2 in offers_after:
		var kact2: StringName = StringName(inst2.context.get("knowledge_action", &""))
		_assert(kact2 != &"FORGE_EVIDENCE", "after debunk + weaker rumor, FORGE_EVIDENCE should not be spawned (heat=%.1f)" % heat_day5)


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

### Remarques
- Le test suppose que tu as bien le “merge/noisy-OR” dans `inject_rumor()` (sinon 2 rumeurs n’augmentent pas forcément `heat`).
- Le critère “bundle réduit” est volontairement robuste : `offers_after <= offers_before-1` plutôt que “exactement 1”, parce que ton `heat` après debunk peut varier selon tes poids de personnalité/decay.

Si tu veux, je peux aussi te faire une variante plus stricte (ex: **3 offers** avant, **0–1** après) en fixant exactement les paramètres (paranoia/diplomacy/strength/credibility) pour rendre ça 100% déterministe dans ton réglage actuel.

Moi:
Qu'apporte le fait que ce soit 100% deterministe et qurl sont les parametres qui randomize

ChatGPT:
Un test **100% déterministe** apporte surtout 3 choses :

- **Reproductibilité parfaite** : si ça casse sur ta CI ou sur ta machine, tu peux rerun et obtenir exactement le même résultat (même nombre d’offres, mêmes rôles).
- **Débogage rapide** : tu sais que l’échec vient d’un changement de code/règles, pas d’un tirage chanceux.
- **Non-flakiness** : pas de tests “parfois verts, parfois rouges” quand tu changes un seuil ou un poids.

À l’inverse, un test un peu stochastique est utile pour “property testing” (robustesse), mais il faut alors des assertions plus souples.

---

## Ce qui peut “randomizer” dans ce qu’on a écrit

### 1) Sélection de variante de quête (template)
Dans `KnowledgeOfferFactory._spawn_knowledge_offer()` on fait :
```gdscript
var qtype: StringName = options[randi() % options.size()]
```
Ça change le `quest_type` choisi (stealth vs diplomacy…), mais normalement pas le **nombre** d’offres.

✅ Pour rendre ça déterministe :
- appeler `seed(…)` au début du test (ce qu’on fait),
- ou remplacer `randi()` par `rng.randi()` injecté.

### 2) Le merge/noisy-OR (pas random)
Le merge qu’on propose (`1 - (1-old)(1-conf)`) est **déterministe**.

### 3) Les paramètres qui font varier `heat` (pas random, mais sensibles)
Même sans hasard, `heat` varie fortement selon :
- `strength`, `credibility` des rumeurs
- `profiles` (paranoia/diplomacy/intel)
- `decay_per_day`
- `severity`
- les seuils `HEAT_LOW/MED/HIGH`

Donc un test peut devenir “instable” si tu ajustes ces valeurs, même sans RNG. C’est une autre forme de non-déterminisme : pas aléatoire, mais fragile aux tunings.

### 4) Les endroits où tu pourrais introduire du RNG plus tard
Si tu ajoutes des probas du type :
- “observer reçoit la rumeur avec p=…”
- “rumeur se propage à un allié au hasard”
- “confidence initiale = base + noise”

Alors là, le **nombre** d’offres deviendra réellement dépendant du hasard.

---

## Ce que je te conseille (pratique)
- Garder **deux catégories de tests** :
  1) **déterministes** : vérifient les invariants logiques (rôles giver/antagonist/third_party, debunk ↓ heat, seuils).
  2) **stochastiques** (optionnels) : 200 runs, vérifier des stats (“en moyenne, debunk réduit le bundle”, pas de divergence, etc.).

Et si tu veux rendre ton système test-friendly, le meilleur micro-patch est :
- injecter `rng: RandomNumberGenerator` dans `spawn_offers_for_rumor` (ou au moins dans `_spawn_knowledge_offer`) au lieu d’utiliser `randi()` global.

Si tu veux, je te donne le patch minimal “rng optionnel” (aucun changement en prod, mais tests 100% maîtrisés).

Moi:
On travaille sur 
5) Coalitions/blocs (multi-paires mais lisibles)
La 3rd party est un bon début. Une étape simple au-dessus :
• un “bloc” (liste de factions) temporaire autour d’un conflit (ex: coalition anti-hégémonique),
• avec 1–2 quêtes “joint operation” (pas besoin d’un arc à 3 complet).
Effet : le monde se structure, et tu obtiens naturellement alliances/fusions.

Il Faudrait aussi que ca s'active si il y a une factions tres dominante face a de petites factions qui se font ecrasé

Par contre, il possible que la resolution ne soit pas loyal pour tout le monde

ChatGPT:
OK — passer de la *3rd party* à des **coalitions/blocs** est exactement le bon “niveau au-dessus” pour structurer le monde sans tomber dans un arc à 3 ultra-complexe.

Je te propose une V1 **lisible** (côté joueur) + **systémique** (côté IA), avec activation “anti-hégémon” et surtout un modèle où **la résolution n’est pas LOYAL pour tout le monde**.

---

## 1) Concept V1 : CoalitionBlock (temporaire, cible unique)

Une coalition est un objet **autour d’une cible** (souvent un hégémon) :

- **target_id** : la faction dominante à contenir/abattre
- **members** : petites/moyennes factions qui se coordonnent
- **leader_id** : celui qui initie (pas forcément le plus fort, souvent le plus motivé)
- **goal** : *CONTAIN / PUNISH / TAKE_POI / SUBJUGATE / OVERTHROW*
- **cohesion** (0..100) : capacité à rester alignés
- **progress** (0..100) : progrès vers le goal (se nourrit des “joint operations”)
- **expires / lock** : évite spam / reformation instantanée

### Lisibilité côté joueur
- **1 seule coalition primaire visible par target** (pas 4 coalitions anti-A en même temps)
- **bundle d’offres 1–2 max** (ex: “joint operation” + “diplomatic pledge”)
- si pool bas, tu peux montrer une secondaire, sinon non.

---

## 2) Déclenchement “anti-hégémon” (dominant vs petites factions)

Pour activer **même si les relations ne sont pas encore “chaudes”**, tu utilises un score de dominance.

### `hegemon_index` (simple, robuste)
Un index 0..1 basé sur la part relative dans le monde :

- `power_share` (armée/territoire)
- `econ_share` (or/revenus)
- `recent_wins` (wars/POI captures, pondéré par récence)
- `threat_projection` (capacité à projeter des actions)

Exemple :
```
hegemon_index = 0.35*power_share + 0.25*econ_share + 0.25*recent_wins + 0.15*threat_projection
```

### Condition d’activation (V1)
- si `hegemon_index > 0.62`
- et au moins `N` factions ont `fear_of_target > 0.55` (ou “ont subi des pertes” récemment)
- alors on tente une coalition **DEFENSIVE** (containment) ou **OVERTHROW** selon profils.

👉 `fear_of_target` peut venir de :
- pertes récentes (POI perdu, tribut imposé, raids subis)
- proximité géographique (si tu l’as)
- divergence d’axes + historique hostile
- “rumeurs/knowledge” (très puissant : *“A est derrière tout”*)

---

## 3) Structure de données compacte

```gdscript
class_name CoalitionBlock
extends RefCounted

var id: StringName
var target_id: StringName
var leader_id: StringName
var member_ids: Array[StringName] = []

var goal: StringName = &"CONTAIN"         # CONTAIN/OVERTHROW/TAKE_POI/TRIBUTE/PUNISH
var started_day: int = 0
var expires_day: int = 0
var lock_until_day: int = 0

var cohesion: int = 60                    # 0..100
var progress: float = 0.0                 # 0..100

var member_commitment: Dictionary = {}    # member_id -> 0..1
var member_role: Dictionary = {}          # member_id -> "FRONTLINE"/"SUPPORT"/"DIPLO"

var last_offer_day: int = -999999
var primary_offer_active: bool = false
```

---

## 4) Offres “joint operation” (pont direct vers QuestPool)

Tu n’as besoin que de **2 familles** au début :

### A) `coalition.joint_op` (action concrète)
Variants (selon goal) :
- CONTAIN → supply interdiction / sabotage / scout / defend ally
- TAKE_POI → joint siege prep / cut reinforcements / capture fort
- OVERTHROW → decisive battle / eliminate warlord / steal war plans

Context standard :
```gdscript
"is_coalition": true,
"coalition_id": coalition.id,
"coalition_goal": coalition.goal,
"coalition_target_id": coalition.target_id,
"coalition_members": coalition.member_ids,
"leader_id": coalition.leader_id,
"joint_op_type": &"SUPPLY_LINE"|"SIEGE_PREP"|...,
"stake": {...}, "expires_in_days": X
```

### B) `coalition.pledge` (engagement politique)
“prêter serment / échanger otages / signer pacte / faire un rituel”
→ augmente **commitment** et **cohesion**, et ouvre la porte à **alliance/fusion** plus tard.

---

## 5) Point crucial : “la résolution n’est pas LOYAL pour tout le monde”

Au lieu de supposer un unique choix, tu fais une **résolution par membre** (stance).

### Stances par membre
- `SUPPORT` (équiv. LOYAL à la coalition)
- `HEDGE` (NEUTRAL : “je fais le minimum”)
- `UNDERMINE` (TRAITOR : fuite d’info, sabotage, double jeu)

#### Comment décider la stance (IA)
Pour chaque membre `m` :
- base sur `commitment[m]`
- personnalité (opportunisme, diplomatie, peur, honneur)
- coût (fatigue, budget)
- et “fear of hegemon” (si target est terrifiante, certains vont trahir par peur)

Exemple très simple :
```
p_support = 0.35 + 0.45*commitment + 0.20*honor - 0.25*fear - 0.20*fatigue
p_undermine = 0.10 + 0.30*opportunism + 0.25*fear + 0.15*history_with_target
else hedge
```

### Application des effets
Après une joint op, tu appliques :

1) **progress coalition** dépend du % de SUPPORT
- si ≥ 60% SUPPORT → progress full
- si 30–60% → progress réduit
- si < 30% ou UNDERMINE présent → progress faible + pénalité cohesion

2) relations inter-membres selon alignement
- SUPPORT↔SUPPORT : trust +2
- SUPPORT vs HEDGE : trust -1 (frustration)
- SUPPORT vs UNDERMINE : trust -6 + “suspicion heat” (knowledge)

3) relations membre↔target
- SUPPORT : tension/grievance ↑
- UNDERMINE : member↔target s’améliore (et coalition le déteste)

C’est exactement ce qui crée des coalitions **instables mais vivantes**, et qui peut mener :
- à une **alliance durable** si la coalition tient,
- ou à une **fusion** si cohesion + compatibilité axes + traités,
- ou à une **implosion** (et parfois un nouveau bloc pro-hégémon).

---

## 6) Conditions de fin (coalition) et sorties naturelles

### Fin “réussite”
- `progress >= 100` :
  - goal CONTAIN → treaty “mutual defense” (clauses no-raid/no-war, voire open_trade entre membres)
  - goal TAKE_POI → transfert POI + trêve
  - goal OVERTHROW → target affaiblie → soit “vassalage”, soit fragmentation, soit fusion de 2 membres dominants

### Fin “échec / implosion”
- `cohesion < 25` ou trop d’UNDERMINE → dissolve + lock long (15–40 jours)
- effet : relations internes se dégradent, et parfois formation d’un **bloc rival**

### Fin “contexte”
- menace externe majeure → conversion de coalition en **coalition défensive** (même membres, nouveau goal)

---

## 7) Où brancher ça dans ton architecture actuelle

- **ArcManager** reste pair-wise (A↔B)
- **CoalitionManager** est “multi-factions” et ne remplace pas ArcManager, il *oriente* :
  - pousse des offers “joint operations”
  - modifie les goals (WAR/CONFLICT/TRUCE) via `apply_arc_modifiers()`
  - influence `compute_priority_targets()` (target = hegemon)

Et ton `QuestManager.resolve_quest()` appelle :
- `CoalitionManager.apply_joint_op_resolution(inst, choice)`  
qui calcule les stances des membres et applique deltas.

---

Si tu veux, prochaine brique logique : je te donne un **MVP concret** en GDScript de :
1) `CoalitionManager.tick_day()` (détection hégémon + formation + spawn 1–2 offers max)  
2) `apply_joint_op_resolution()` (stances par membre + progress/cohesion + deltas relationnels)  
avec des hooks minimalistes vers QuestPool et ArcNotebook.

Moi:
donne un MVP concret en GDScript de :

CoalitionManager.tick_day() (détection hégémon + formation + spawn 1–2 offers max)

apply_joint_op_resolution() (stances par membre + progress/cohesion + deltas relationnels)
avec des hooks minimalistes vers QuestPool et ArcNotebook.

PrenDs en compte que la coalition peut aussi se creer pour prevenir une crise mondiale.
Ceux qyivy participe pzuvent ne pas s'apprecier ou meme etre en guerre et faire une treve temporaire pour repousser la menace. 
Amoins qu'il aient plus d'interet a laisser la menace eclore plutot que d'arreter la guerre ou qu'ils soient en bon termes avec la faction qui declencje la crise, auqel cas ils peuvent faire une coalition avec la faction qui declenche la crise.

ChatGPT:
Voici un **MVP concret** en GDScript (Godot 4) qui fait :

- `CoalitionManager.tick_day()`  
  - détecte **hégémon** (anti-dominance) **OU** **crise mondiale** (anti-crise + pro-crise possible),
  - forme/maintient 1–2 coalitions max par “key”,
  - applique une **trêve temporaire** entre membres (même si en WAR),
  - spawn **1–2 offers max** par coalition (joint op + pledge optionnel) via `QuestPool.try_add_offer()`,
  - cooldown via `ArcNotebook`.

- `apply_joint_op_resolution()`  
  - calcule une **stance par membre** (SUPPORT / HEDGE / UNDERMINE) selon **profil + affinités + historique + relations + intérêts**,
  - met à jour `progress/cohesion/commitment`,
  - applique deltas relationnels **asymétriques** (et pas “LOYAL pour tout le monde”),
  - enregistre des métriques simples dans `ArcNotebook`.

> Les classes `QuestTemplate` / `QuestInstance` sont supposées exister chez toi. Si ton builder de template runtime est ailleurs, remplace `_build_template_fallback()` par ton builder.

---

```gdscript
# CoalitionManager.gd
class_name CoalitionManager
extends Node

class CoalitionBlock:
	var id: StringName
	var kind: StringName = &"HEGEMON"              # HEGEMON | CRISIS
	var side: StringName = &"AGAINST_TARGET"       # AGAINST_TARGET | WITH_TARGET
	var goal: StringName = &"CONTAIN"              # CONTAIN | OVERTHROW | STOP_CRISIS | SUPPORT_CRISIS

	var target_id: StringName = &""                # hegemon or crisis instigator (can be empty if “world threat”)
	var leader_id: StringName = &""
	var member_ids: Array[StringName] = []

	var started_day: int = 0
	var expires_day: int = 0
	var lock_until_day: int = 0

	var cohesion: int = 60                         # 0..100
	var progress: float = 0.0                      # 0..100

	var member_commitment: Dictionary = {}         # member -> 0..1
	var member_role: Dictionary = {}               # member -> FRONTLINE/SUPPORT/DIPLO

	var last_offer_day: int = -999999

	func key() -> StringName:
		return StringName("%s|%s|%s" % [String(kind), String(side), String(target_id)])


var coalitions_by_id: Dictionary = {}       # id -> CoalitionBlock
var coalition_id_by_key: Dictionary = {}    # key -> id

var rng := RandomNumberGenerator.new()

# Tunables V1
const HEGEMON_THRESHOLD := 0.62
const CRISIS_THRESHOLD := 0.60
const MAX_OFFERS_PER_COALITION_PER_TICK := 2
const OFFER_COOLDOWN_DAYS := 5
const COALITION_MIN_MEMBERS := 3
const COALITION_MIN_LIFE_DAYS := 10
const COALITION_MAX_LIFE_DAYS := 30

const STANCE_SUPPORT := &"SUPPORT"
const STANCE_HEDGE := &"HEDGE"
const STANCE_UNDERMINE := &"UNDERMINE"


# ------------------------------------------------------------
# tick_day(day): detect hegemon/crisis, form coalitions, spawn 1-2 offers
# ------------------------------------------------------------
func tick_day(
	day: int,
	faction_ids: Array[StringName],
	profiles: Dictionary,          # faction -> FactionProfile (must have get_personality/get_axis_affinity)
	relations: Dictionary,         # relations[A][B] -> FactionRelationScore
	world: Dictionary,             # crisis + power data
	quest_pool,                    # must have try_add_offer(inst)
	arc_notebook                   # minimal cooldown + optional pair_lock
) -> void:
	# 0) upkeep / expire
	_cleanup_and_expire(day, arc_notebook)

	# 1) CRISIS coalitions (can be AGAINST or WITH the crisis instigator)
	if bool(world.get("crisis_active", false)):
		var sev := float(world.get("crisis_severity", 0.0))
		if sev >= CRISIS_THRESHOLD:
			_ensure_crisis_coalitions(day, faction_ids, profiles, relations, world, arc_notebook)

	# 2) HEGEMON coalition (anti-dominance) if no overriding crisis or if crisis not huge
	var hegemon_id := _detect_hegemon(faction_ids, world)
	if hegemon_id != &"":
		var hegemon_index := float(world.get("hegemon_index_by_faction", {}).get(hegemon_id, 0.0))
		if hegemon_index >= HEGEMON_THRESHOLD:
			_ensure_hegemon_coalition(day, hegemon_id, faction_ids, profiles, relations, world, arc_notebook)

	# 3) Spawn offers (1–2 max / coalition, cooldown)
	for cid in coalitions_by_id.keys():
		var c: CoalitionBlock = coalitions_by_id[cid]
		if day < c.lock_until_day:
			continue
		if (day - c.last_offer_day) < OFFER_COOLDOWN_DAYS:
			continue
		if arc_notebook != null and arc_notebook.has_method("can_spawn_coalition_offer"):
			if not arc_notebook.can_spawn_coalition_offer(c.id, day, OFFER_COOLDOWN_DAYS):
				continue

		var spawned := 0
		# Always try JOINT OP first
		var inst := _spawn_joint_op_offer(c, day, profiles, relations, world)
		if inst != null and quest_pool != null and quest_pool.has_method("try_add_offer"):
			if quest_pool.try_add_offer(inst):
				spawned += 1

		# Optional PLEDGE offer if cohesion low or crisis with mixed members (even at war)
		if spawned < MAX_OFFERS_PER_COALITION_PER_TICK:
			if c.cohesion <= 55 or c.kind == &"CRISIS":
				var inst2 := _spawn_pledge_offer(c, day, profiles, relations, world)
				if inst2 != null and quest_pool != null and quest_pool.has_method("try_add_offer"):
					if quest_pool.try_add_offer(inst2):
						spawned += 1

		if spawned > 0:
			c.last_offer_day = day
			if arc_notebook != null and arc_notebook.has_method("mark_coalition_offer_spawned"):
				arc_notebook.mark_coalition_offer_spawned(c.id, day)


# ------------------------------------------------------------
# apply_joint_op_resolution(): member stances + progress/cohesion + deltas
# ------------------------------------------------------------
func apply_joint_op_resolution(
	context: Dictionary,           # from QuestInstance.context
	choice: StringName,            # LOYAL/NEUTRAL/TRAITOR (player)
	day: int,
	profiles: Dictionary,
	relations: Dictionary,
	world: Dictionary,
	arc_notebook
) -> void:
	if not bool(context.get("is_coalition", false)):
		return

	var cid: StringName = StringName(context.get("coalition_id", &""))
	if cid == &"" or not coalitions_by_id.has(cid):
		return
	var c: CoalitionBlock = coalitions_by_id[cid]

	var members: Array[StringName] = c.member_ids.duplicate()
	if members.is_empty():
		return

	# 1) Determine stance per member (SUPPORT/HEDGE/UNDERMINE)
	var stances: Dictionary = {}
	var support_count := 0
	var undermine_count := 0

	var crisis_axis: StringName = StringName(world.get("crisis_axis", &"")) # optional (MAGIC/CORRUPTION/...)
	var crisis_source: StringName = StringName(world.get("crisis_source_id", &""))

	for m in members:
		var stance := _decide_member_stance(c, m, day, profiles, relations, world, arc_notebook, crisis_axis, crisis_source)
		stances[m] = stance
		if stance == STANCE_SUPPORT: support_count += 1
		elif stance == STANCE_UNDERMINE: undermine_count += 1

	var support_ratio := float(support_count) / float(max(1, members.size()))

	# 2) Update coalition progress/cohesion (player choice affects efficiency)
	var tier := int(context.get("tier", 2))
	var base_progress := 14.0 + 4.0 * float(tier)

	var eff := clampf(0.25 + 0.95*support_ratio - (undermine_count > 0 ? 0.30 : 0.0), 0.05, 1.10)
	if choice == &"LOYAL": eff *= 1.05
	elif choice == &"NEUTRAL": eff *= 0.95
	elif choice == &"TRAITOR": eff *= 0.85

	var dp := base_progress * eff
	c.progress = clampf(c.progress + dp, 0.0, 100.0)

	var dc := 0
	if support_ratio >= 0.66: dc += 4
	elif support_ratio >= 0.40: dc += 1
	else: dc -= 3
	if undermine_count > 0: dc -= 6
	if choice == &"LOYAL": dc += 1
	if choice == &"TRAITOR": dc -= 2
	c.cohesion = int(clampi(c.cohesion + dc, 0, 100))

	# 3) Relationship deltas among members (asymmetric, based on stances)
	_apply_member_deltas(c, members, stances, relations, arc_notebook, day)

	# 4) Member commitment shifts (people can hedge/undermine without being “LOYAL”)
	for m in members:
		var commit := float(c.member_commitment.get(m, 0.6))
		match StringName(stances[m]):
			STANCE_SUPPORT:
				commit = clampf(commit + 0.06, 0.0, 1.0)
			STANCE_HEDGE:
				commit = clampf(commit - 0.03, 0.0, 1.0)
			STANCE_UNDERMINE:
				commit = clampf(commit - 0.22, 0.0, 1.0)
		c.member_commitment[m] = commit

	# Optional: kick persistent underminers (MVP)
	var to_remove: Array[StringName] = []
	for m in members:
		if float(c.member_commitment.get(m, 0.6)) <= 0.12:
			to_remove.append(m)
	for m in to_remove:
		c.member_ids.erase(m)
		c.member_commitment.erase(m)
		c.member_role.erase(m)

	# 5) If coalition achieved its goal or collapsed -> dissolve + lock
	if c.progress >= 100.0:
		_dissolve_coalition(day, c, arc_notebook, &"SUCCESS")
	elif c.cohesion <= 20 or c.member_ids.size() < 2:
		_dissolve_coalition(day, c, arc_notebook, &"COLLAPSE")

	# metrics
	if arc_notebook != null and arc_notebook.has_method("record_coalition_event"):
		arc_notebook.record_coalition_event({
			"day": day, "coalition_id": c.id, "goal": c.goal, "progress": c.progress, "cohesion": c.cohesion,
			"support_ratio": support_ratio, "undermine": undermine_count, "choice": choice
		})


# ============================================================
# Internals
# ============================================================

func _cleanup_and_expire(day: int, arc_notebook) -> void:
	var to_remove: Array[StringName] = []
	for cid in coalitions_by_id.keys():
		var c: CoalitionBlock = coalitions_by_id[cid]
		if day >= c.expires_day and day >= (c.started_day + COALITION_MIN_LIFE_DAYS):
			to_remove.append(cid)
		elif c.cohesion <= 10:
			to_remove.append(cid)

	for cid in to_remove:
		var c: CoalitionBlock = coalitions_by_id[cid]
		_dissolve_coalition(day, c, arc_notebook, &"EXPIRE")


func _dissolve_coalition(day: int, c: CoalitionBlock, arc_notebook, reason: StringName) -> void:
	# Long lock to prevent instant reformation
	c.lock_until_day = day + rng.randi_range(15, 40)

	# Mark cooldown in notebook (optional)
	if arc_notebook != null and arc_notebook.has_method("mark_coalition_dissolved"):
		arc_notebook.mark_coalition_dissolved(c.id, day, reason)

	# Remove from registries
	var k := c.key()
	coalition_id_by_key.erase(k)
	coalitions_by_id.erase(c.id)


func _detect_hegemon(faction_ids: Array[StringName], world: Dictionary) -> StringName:
	var idx_map: Dictionary = world.get("hegemon_index_by_faction", {})
	if idx_map is Dictionary and idx_map.size() > 0:
		var best := &""
		var bestv := -1.0
		for f in faction_ids:
			var v := float(idx_map.get(f, 0.0))
			if v > bestv:
				bestv = v
				best = f
		return best

	# fallback from power_by_faction
	var pmap: Dictionary = world.get("power_by_faction", {})
	if pmap.size() == 0:
		return &""
	var best2 := &""
	var bestp := -1.0
	for f in faction_ids:
		var p := float(pmap.get(f, 0.0))
		if p > bestp:
			bestp = p
			best2 = f
	return best2


func _ensure_hegemon_coalition(day: int, hegemon_id: StringName, faction_ids: Array[StringName], profiles: Dictionary, relations: Dictionary, world: Dictionary, arc_notebook) -> void:
	var key := StringName("HEGEMON|AGAINST_TARGET|%s" % String(hegemon_id))
	if coalition_id_by_key.has(key):
		return

	# candidates: factions not hegemon, with fear/hostility, or simply weak ones under pressure
	var candidates: Array[StringName] = []
	for f in faction_ids:
		if f == hegemon_id: continue
		var score := _anti_hegemon_join_score(f, hegemon_id, profiles, relations, world, arc_notebook)
		if score >= 0.55:
			candidates.append(f)

	if candidates.size() < COALITION_MIN_MEMBERS:
		return

	# pick leader = highest score
	var leader := candidates[0]
	var best := -1.0
	for f in candidates:
		var s := _anti_hegemon_join_score(f, hegemon_id, profiles, relations, world, arc_notebook)
		if s > best:
			best = s
			leader = f

	var c := CoalitionBlock.new()
	c.kind = &"HEGEMON"
	c.side = &"AGAINST_TARGET"
	c.goal = &"CONTAIN"
	c.target_id = hegemon_id
	c.leader_id = leader
	c.started_day = day
	c.expires_day = day + rng.randi_range(COALITION_MIN_LIFE_DAYS, COALITION_MAX_LIFE_DAYS)
	c.cohesion = 55
	c.progress = 0.0

	c.member_ids = candidates
	for m in c.member_ids:
		c.member_commitment[m] = clampf(_anti_hegemon_join_score(m, hegemon_id, profiles, relations, world, arc_notebook), 0.2, 0.95)
		c.member_role[m] = &"FRONTLINE" if rng.randf() < 0.35 else &"SUPPORT"

	c.id = StringName("coal_heg_%s_%s" % [String(hegemon_id), str(day)])
	coalitions_by_id[c.id] = c
	coalition_id_by_key[key] = c.id

	# Optional: “soft truce” between members to keep it playable
	_apply_temp_truce_for_members(c, day, arc_notebook, 10)


func _ensure_crisis_coalitions(day: int, faction_ids: Array[StringName], profiles: Dictionary, relations: Dictionary, world: Dictionary, arc_notebook) -> void:
	var source: StringName = StringName(world.get("crisis_source_id", &""))   # can be empty (pure world crisis)
	var axis: StringName = StringName(world.get("crisis_axis", &""))
	var sev := float(world.get("crisis_severity", 0.0))

	# A) coalition AGAINST crisis/source (STOP_CRISIS)
	var key_anti := StringName("CRISIS|AGAINST_TARGET|%s" % String(source))
	if not coalition_id_by_key.has(key_anti):
		var anti_members: Array[StringName] = []
		for f in faction_ids:
			# some factions prefer letting crisis grow or are friendly to source => won't join anti
			var s := _stop_crisis_join_score(f, source, axis, sev, profiles, relations, world, arc_notebook)
			if s >= 0.55:
				anti_members.append(f)

		if anti_members.size() >= COALITION_MIN_MEMBERS:
			var leader := _pick_best_leader(anti_members, source, profiles, relations)
			var c := CoalitionBlock.new()
			c.kind = &"CRISIS"
			c.side = &"AGAINST_TARGET"
			c.goal = &"STOP_CRISIS"
			c.target_id = source
			c.leader_id = leader
			c.started_day = day
			c.expires_day = day + rng.randi_range(12, 28)
			c.cohesion = 50
			c.member_ids = anti_members
			for m in c.member_ids:
				c.member_commitment[m] = clampf(_stop_crisis_join_score(m, source, axis, sev, profiles, relations, world, arc_notebook), 0.2, 0.95)
				c.member_role[m] = &"DIPLO" if rng.randf() < 0.25 else &"SUPPORT"
			c.id = StringName("coal_crisis_anti_%s_%s" % [String(source), str(day)])
			coalitions_by_id[c.id] = c
			coalition_id_by_key[key_anti] = c.id
			_apply_temp_truce_for_members(c, day, arc_notebook, 12)

	# B) coalition WITH crisis/source (SUPPORT_CRISIS) if source exists and has allies who want crisis
	if source == &"":
		return
	var key_pro := StringName("CRISIS|WITH_TARGET|%s" % String(source))
	if coalition_id_by_key.has(key_pro):
		return

	var pro_members: Array[StringName] = []
	for f in faction_ids:
		if f == source: continue
		var s2 := _support_crisis_join_score(f, source, axis, sev, profiles, relations, world, arc_notebook)
		if s2 >= 0.62:
			pro_members.append(f)

	# Keep pro coalition smaller: it’s a “cabal”
	if pro_members.size() >= 2:
		var c2 := CoalitionBlock.new()
		c2.kind = &"CRISIS"
		c2.side = &"WITH_TARGET"
		c2.goal = &"SUPPORT_CRISIS"
		c2.target_id = source
		c2.leader_id = source
		c2.started_day = day
		c2.expires_day = day + rng.randi_range(10, 22)
		c2.cohesion = 55
		c2.member_ids = pro_members
		for m in c2.member_ids:
			c2.member_commitment[m] = clampf(_support_crisis_join_score(m, source, axis, sev, profiles, relations, world, arc_notebook), 0.2, 0.95)
			c2.member_role[m] = &"STEALTH" if rng.randf() < 0.5 else &"SUPPORT"
		c2.id = StringName("coal_crisis_pro_%s_%s" % [String(source), str(day)])
		coalitions_by_id[c2.id] = c2
		coalition_id_by_key[key_pro] = c2.id


func _apply_temp_truce_for_members(c: CoalitionBlock, day: int, arc_notebook, truce_days: int) -> void:
	if arc_notebook == null or not arc_notebook.has_method("set_pair_lock"):
		return
	var until := day + truce_days
	for i in range(c.member_ids.size()):
		for j in range(i + 1, c.member_ids.size()):
			var a := c.member_ids[i]
			var b := c.member_ids[j]
			var pair_key := _pair_key(a, b)
			arc_notebook.set_pair_lock(pair_key, until, &"COALITION_TRUCE")


func _spawn_joint_op_offer(c: CoalitionBlock, day: int, profiles: Dictionary, relations: Dictionary, world: Dictionary) -> QuestInstance:
	var tier := clampi(2 + int(floor(c.progress / 35.0)), 1, 5)
	var deadline := (c.kind == &"CRISIS") ? 5 : 7

	var joint_type := &"JOINT_OP"
	var quest_type := &"coalition.joint_op"

	if c.kind == &"HEGEMON":
		quest_type = &"coalition.joint_op.contain"
		joint_type = &"SUPPLY_INTERDICTION"
	elif c.kind == &"CRISIS":
		if c.side == &"AGAINST_TARGET":
			quest_type = &"coalition.joint_op.stop_crisis"
			joint_type = &"SEAL_RIFT"
		else:
			quest_type = &"coalition.joint_op.support_crisis"
			joint_type = &"PROTECT_CULT"

	var template := _build_template_fallback(StringName(quest_type), tier, deadline)

	var ctx := {
		"is_coalition": true,
		"coalition_id": c.id,
		"coalition_kind": c.kind,
		"coalition_side": c.side,
		"coalition_goal": c.goal,
		"coalition_target_id": c.target_id,
		"coalition_members": c.member_ids,
		"leader_id": c.leader_id,

		"joint_op_type": joint_type,
		"tier": tier,
		"expires_in_days": deadline,

		"giver_faction_id": c.leader_id,
		"antagonist_faction_id": c.target_id,
		"resolution_profile_id": &"coalition_joint_op"
	}

	var inst := QuestInstance.new(template, ctx)
	inst.status = "AVAILABLE"
	inst.started_on_day = day
	inst.expires_on_day = day + deadline
	return inst


func _spawn_pledge_offer(c: CoalitionBlock, day: int, profiles: Dictionary, relations: Dictionary, world: Dictionary) -> QuestInstance:
	var tier := 1
	var deadline := 6
	var template := _build_template_fallback(&"coalition.pledge", tier, deadline)

	var ctx := {
		"is_coalition": true,
		"coalition_id": c.id,
		"coalition_kind": c.kind,
		"coalition_side": c.side,
		"coalition_goal": c.goal,
		"coalition_target_id": c.target_id,
		"coalition_members": c.member_ids,
		"leader_id": c.leader_id,

		"pledge": true,
		"tier": tier,
		"expires_in_days": deadline,

		"giver_faction_id": c.leader_id,
		"antagonist_faction_id": c.target_id,
		"resolution_profile_id": &"coalition_pledge"
	}

	var inst := QuestInstance.new(template, ctx)
	inst.status = "AVAILABLE"
	inst.started_on_day = day
	inst.expires_on_day = day + deadline
	return inst


func _decide_member_stance(
	c: CoalitionBlock,
	m: StringName,
	day: int,
	profiles: Dictionary,
	relations: Dictionary,
	world: Dictionary,
	arc_notebook,
	crisis_axis: StringName,
	crisis_source: StringName
) -> StringName:
	var p = profiles.get(m, null)
	var commit := float(c.member_commitment.get(m, 0.6))

	var opportunism := _p(p, &"opportunism", 0.5)
	var diplomacy := _p(p, &"diplomacy", 0.5)
	var honor := _p(p, &"honor", 0.5)
	var fear := _p(p, &"fear", 0.5)  # optionnel si tu l’as, sinon 0.5

	# relation to leader/target
	var rel_to_leader := _rel(relations, m, c.leader_id)
	var rel_to_target := _rel(relations, m, c.target_id)

	# Axis alignment with crisis (if crisis axis exists)
	var axis_aff := 0.0
	if crisis_axis != &"" and p != null and p.has_method("get_axis_affinity"):
		axis_aff = float(p.get_axis_affinity(crisis_axis, 0)) / 100.0  # -1..+1

	# If coalition is AGAINST target but member likes target => more hedge/undermine
	var likes_target := rel_to_target >= 40.0
	var hates_target := rel_to_target <= -40.0

	var sev := float(world.get("crisis_severity", 0.0))
	var crisis_pressure := (c.kind == &"CRISIS") ? sev : 0.0

	# Members can join a crisis coalition even if they dislike others; stance models actual cooperation.
	var p_support := 0.25 + 0.55*commit + 0.20*honor + 0.15*hates_target + 0.20*crisis_pressure - 0.20*fear - 0.15*opportunism
	var p_undermine := 0.08 + 0.30*opportunism + 0.20*fear + 0.20*likes_target - 0.20*honor

	# Crisis special-case: if axis_aff strongly positive for crisis axis and coalition is STOP_CRISIS => undermine rises
	if c.kind == &"CRISIS" and c.goal == &"STOP_CRISIS" and axis_aff >= 0.55:
		p_undermine += 0.18
		p_support -= 0.10

	# If coalition is SUPPORT_CRISIS and member is anti-axis => they hedge/undermine that coalition
	if c.kind == &"CRISIS" and c.goal == &"SUPPORT_CRISIS" and axis_aff <= -0.45:
		p_support -= 0.15
		p_undermine += 0.10

	# Friendly with crisis source => more undermine in anti coalition, more support in pro coalition
	if crisis_source != &"":
		var rel_to_source := _rel(relations, m, crisis_source)
		if c.goal == &"STOP_CRISIS" and rel_to_source >= 50.0:
			p_undermine += 0.20
			p_support -= 0.10
		if c.goal == &"SUPPORT_CRISIS" and rel_to_source >= 20.0:
			p_support += 0.15

	p_support = clampf(p_support, 0.0, 0.95)
	p_undermine = clampf(p_undermine, 0.0, 0.80)

	var r := rng.randf()
	if r < p_support:
		return STANCE_SUPPORT
	if r < (p_support + p_undermine):
		return STANCE_UNDERMINE
	return STANCE_HEDGE


func _apply_member_deltas(
	c: CoalitionBlock,
	members: Array[StringName],
	stances: Dictionary,
	relations: Dictionary,
	arc_notebook,
	day: int
) -> void:
	# Member vs leader and member vs target
	for m in members:
		var stance: StringName = StringName(stances[m])

		# Leader disappointed by hedgers/underminers
		if m != c.leader_id:
			_apply_rel(relations, c.leader_id, m, "trust", (stance == STANCE_SUPPORT ? +2 : stance == STANCE_HEDGE ? -2 : -6))
			_apply_rel(relations, c.leader_id, m, "relation", (stance == STANCE_SUPPORT ? +1 : stance == STANCE_HEDGE ? -1 : -4))

		# Target relationship (if target exists)
		if c.target_id != &"" and relations.has(m) and relations[m].has(c.target_id):
			if c.side == &"AGAINST_TARGET":
				if stance == STANCE_SUPPORT:
					_apply_rel(relations, m, c.target_id, "tension", +4)
					_apply_rel(relations, m, c.target_id, "grievance", +3)
					_apply_rel(relations, m, c.target_id, "relation", -3)
				elif stance == STANCE_UNDERMINE:
					# le membre “fait copain-copain” ou leak => relation s'améliore, coalition le déteste
					_apply_rel(relations, m, c.target_id, "trust", +2)
					_apply_rel(relations, m, c.target_id, "relation", +2)
			else:
				# coalition WITH target
				if stance == STANCE_SUPPORT:
					_apply_rel(relations, m, c.target_id, "trust", +2)
					_apply_rel(relations, m, c.target_id, "relation", +2)
				elif stance == STANCE_UNDERMINE:
					_apply_rel(relations, m, c.target_id, "trust", -4)
					_apply_rel(relations, m, c.target_id, "relation", -3)

	# Member-member trust shifts
	for i in range(members.size()):
		for j in range(i + 1, members.size()):
			var a := members[i]
			var b := members[j]
			var sa: StringName = StringName(stances[a])
			var sb: StringName = StringName(stances[b])

			if sa == STANCE_SUPPORT and sb == STANCE_SUPPORT:
				_apply_rel(relations, a, b, "trust", +2)
				_apply_rel(relations, b, a, "trust", +2)
			elif (sa == STANCE_SUPPORT and sb == STANCE_HEDGE) or (sa == STANCE_HEDGE and sb == STANCE_SUPPORT):
				_apply_rel(relations, a, b, "trust", -1)
				_apply_rel(relations, b, a, "trust", -1)
			elif (sa == STANCE_UNDERMINE and sb == STANCE_SUPPORT) or (sa == STANCE_SUPPORT and sb == STANCE_UNDERMINE):
				_apply_rel(relations, a, b, "trust", -6)
				_apply_rel(relations, b, a, "trust", -6)
				if arc_notebook != null and arc_notebook.has_method("record_pair_event"):
					arc_notebook.record_pair_event(day, a, b, &"COALITION_BETRAYAL", &"", {}) # debug/metrics


# -------------------- scoring helpers --------------------

func _anti_hegemon_join_score(f: StringName, hegemon: StringName, profiles: Dictionary, relations: Dictionary, world: Dictionary, arc_notebook) -> float:
	# join if fear/hostility or recent losses or ideology clash; also if weak
	var rel := _rel(relations, f, hegemon) / 100.0
	var p = profiles.get(f, null)
	var diplomacy := _p(p, &"diplomacy", 0.5)
	var opportunism := _p(p, &"opportunism", 0.5)
	var honor := _p(p, &"honor", 0.5)

	var power_map: Dictionary = world.get("power_by_faction", {})
	var my_power := float(power_map.get(f, 0.0))
	var heg_power := float(power_map.get(hegemon, 0.0))
	var weak := (heg_power > 0.0) ? clampf(1.0 - (my_power / heg_power), 0.0, 1.0) : 0.0

	# history pressure (optional)
	var hist := 0.0
	if arc_notebook != null and arc_notebook.has_method("get_pair_counter"):
		var pk := _pair_key(f, hegemon)
		hist = clampf(0.05 * float(arc_notebook.get_pair_counter(pk, &"hostile_events", 0)), 0.0, 0.4)

	var s := 0.30*weak + 0.30*clampf(-rel, 0.0, 1.0) + 0.15*honor - 0.15*diplomacy + 0.10*opportunism + hist
	return clampf(s, 0.0, 1.0)


func _stop_crisis_join_score(f: StringName, source: StringName, crisis_axis: StringName, sev: float, profiles: Dictionary, relations: Dictionary, world: Dictionary, arc_notebook) -> float:
	# join anti-crisis if altruism/honor/diplomacy, dislikes source, or crisis threatens them
	var p = profiles.get(f, null)
	var honor := _p(p, &"honor", 0.5)
	var diplomacy := _p(p, &"diplomacy", 0.5)
	var opportunism := _p(p, &"opportunism", 0.5)

	var rel_to_source := (source == &"") ? 0.0 : _rel(relations, f, source) / 100.0
	var axis_aff := 0.0
	if crisis_axis != &"" and p != null and p.has_method("get_axis_affinity"):
		axis_aff = float(p.get_axis_affinity(crisis_axis, 0)) / 100.0

	# If member *likes* the crisis axis (ex corruption) => less motivated to stop it
	var axis_resist := clampf(-axis_aff, 0.0, 1.0)

	var s := 0.25*sev + 0.20*honor + 0.20*diplomacy + 0.20*axis_resist + 0.15*clampf(-rel_to_source, 0.0, 1.0) - 0.15*opportunism
	return clampf(s, 0.0, 1.0)


func _support_crisis_join_score(f: StringName, source: StringName, crisis_axis: StringName, sev: float, profiles: Dictionary, relations: Dictionary, world: Dictionary, arc_notebook) -> float:
	# join pro-crisis if opportunistic, aligned with axis, friendly to source
	var p = profiles.get(f, null)
	var opportunism := _p(p, &"opportunism", 0.5)
	var honor := _p(p, &"honor", 0.5)
	var rel_to_source := _rel(relations, f, source) / 100.0

	var axis_aff := 0.0
	if crisis_axis != &"" and p != null and p.has_method("get_axis_affinity"):
		axis_aff = float(p.get_axis_affinity(crisis_axis, 0)) / 100.0

	var s := 0.25*sev + 0.25*opportunism + 0.20*clampf(rel_to_source, 0.0, 1.0) + 0.20*clampf(axis_aff, 0.0, 1.0) - 0.15*honor
	return clampf(s, 0.0, 1.0)


func _pick_best_leader(members: Array[StringName], target: StringName, profiles: Dictionary, relations: Dictionary) -> StringName:
	var best := members[0]
	var bestv := -1.0
	for f in members:
		var p = profiles.get(f, null)
		var diplomacy := _p(p, &"diplomacy", 0.5)
		var honor := _p(p, &"honor", 0.5)
		var rel := _rel(relations, f, target) / 100.0
		var v := 0.40*diplomacy + 0.25*honor + 0.35*clampf(-rel, 0.0, 1.0)
		if v > bestv:
			bestv = v
			best = f
	return best


# -------------------- template builder (fallback) --------------------

func _build_template_fallback(id: StringName, tier: int, expires_in_days: int):
	var t := QuestTemplate.new()
	t.id = id
	t.title = String(id)
	t.description = "Coalition offer: %s" % String(id)
	t.category = &"COALITION"
	t.tier = tier
	t.objective_type = &"GENERIC"
	t.objective_target = &""
	t.objective_count = 1
	t.expires_in_days = expires_in_days
	return t


# -------------------- tiny relation utils --------------------

func _rel(relations: Dictionary, a: StringName, b: StringName) -> float:
	if a == &"" or b == &"":
		return 0.0
	if not relations.has(a) or not relations[a].has(b):
		return 0.0
	return float(relations[a][b].relation)

func _apply_rel(relations: Dictionary, a: StringName, b: StringName, field: String, delta: int) -> void:
	if a == &"" or b == &"":
		return
	if not relations.has(a) or not relations[a].has(b):
		return
	var r: FactionRelationScore = relations[a][b]
	match field:
		"relation":   r.relation = int(clampi(r.relation + delta, -100, 100))
		"trust":      r.trust = int(clampi(r.trust + delta, 0, 100))
		"tension":    r.tension = int(clampi(r.tension + delta, 0, 100))
		"grievance":  r.grievance = int(clampi(r.grievance + delta, 0, 100))
		"weariness":  r.weariness = int(clampi(r.weariness + delta, 0, 100))

func _p(profile, key: StringName, default_val: float) -> float:
	if profile == null:
		return default_val
	if profile.has_method("get_personality"):
		return float(profile.get_personality(key, default_val))
	if profile is Dictionary:
		return float(profile.get("personality", {}).get(key, default_val))
	return default_val

func _pair_key(a: StringName, b: StringName) -> StringName:
	var sa := String(a)
	var sb := String(b)
	return StringName((sa <= sb) ? (sa + "|" + sb) : (sb + "|" + sa))
```

---

### Points importants (ce que ce MVP couvre par rapport à ta demande)

- **Coalition anti-hégémon** : se forme si une faction est trop dominante, même si les petites factions se détestent (elles peuvent quand même rejoindre, puis “hedge/undermine” modélise la réalité).
- **Coalition crise mondiale** :
  - une coalition **STOP_CRISIS** *contre* la menace / l’instigateur,
  - une coalition **SUPPORT_CRISIS** *avec* l’instigateur (cabal) si certaines factions y ont intérêt (opportunisme, affinité d’axe, bonnes relations).
- **Trêve temporaire** entre membres : via `ArcNotebook.set_pair_lock(pair_key, until_day, reason)` (si tu l’implémentes, ArcManager peut ignorer les incidents).
- **Résolution non uniforme** : chaque membre prend une stance (SUPPORT/HEDGE/UNDERMINE) -> deltas internes cohérents.

Si tu veux, prochaine brique logique : je te donne un mini test “crisis coalition” où 2 factions ennemies entrent en coalition STOP_CRISIS, lock leurs arcs en trêve, puis une d’elles UNDERMINE (opportuniste + affinité corruption), ce qui fait baisser la cohesion et crée une suspicion mesurable dans ArcNotebook.

Moi:
prochaine brique logique : je te donne un mini test “crisis coalition” où 2 factions ennemies entrent en coalition STOP_CRISIS, lock leurs arcs en trêve, puis une d’elles UNDERMINE (opportuniste + affinité corruption), ce qui fait baisser la cohesion et crée une suspicion mesurable dans ArcNotebook.

ChatGPT:
Voici un **mini test “crisis coalition”** (style identique aux autres) qui vérifie :

1) Une **coalition STOP_CRISIS** se forme même si **A et B sont ennemis**  
2) `ArcNotebook.set_pair_lock()` est appelé ⇒ **trêve temporaire** entre membres (donc A↔B lock)  
3) Lors d’une **joint op**, **B UNDERMINE** (opportuniste + affinité Corruption)  
4) ⇒ **cohesion baisse**  
5) ⇒ **suspicion mesurable** via un event `COALITION_BETRAYAL` (record_pair_event)

Pour éviter la flakiness RNG, le test utilise un **TestCoalitionManager** qui choisit la stance de façon **déterministe (argmax)** à partir des mêmes signaux (opportunism/axis_affinity/etc.). Ça prouve bien “opportuniste + corruption ⇒ UNDERMINE”.

---

## `tests/CrisisCoalitionTruceUndermineTest.gd`

```gdscript
extends Node
class_name CrisisCoalitionTruceUndermineTest

# -------- Stubs --------

class TestFactionProfile:
	var personality := {}
	var axis_affinity := {} # axis -> -100..100

	func _init(p: Dictionary, a: Dictionary) -> void:
		personality = p
		axis_affinity = a

	func get_personality(key: StringName, default_val: float = 0.5) -> float:
		return float(personality.get(key, default_val))

	func get_axis_affinity(axis: StringName, default_val: int = 0) -> int:
		return int(axis_affinity.get(axis, default_val))


class TestQuestPool:
	var offers: Array = []
	func try_add_offer(inst) -> bool:
		offers.append(inst)
		return true


class TestArcNotebook:
	var pair_locks: Dictionary = {} # pair_key -> {"until": int, "reason": StringName}
	var pair_events: Array = []

	func set_pair_lock(pair_key: StringName, until_day: int, reason: StringName) -> void:
		pair_locks[pair_key] = {"until": until_day, "reason": reason}

	func can_spawn_coalition_offer(_coalition_id: StringName, _day: int, _cooldown: int) -> bool:
		return true
	func mark_coalition_offer_spawned(_coalition_id: StringName, _day: int) -> void:
		pass

	func record_pair_event(day: int, a: StringName, b: StringName, action: StringName, _choice: StringName, _meta: Dictionary) -> void:
		pair_events.append({"day": day, "a": a, "b": b, "action": action})

	func count_events(action: StringName) -> int:
		var n := 0
		for e in pair_events:
			if StringName(e.get("action", &"")) == action:
				n += 1
		return n


# -------- Deterministic stance manager (argmax) --------
class TestCoalitionManager:
	extends CoalitionManager

	func _decide_member_stance(
		c: CoalitionBlock,
		m: StringName,
		day: int,
		profiles: Dictionary,
		relations: Dictionary,
		world: Dictionary,
		arc_notebook,
		crisis_axis: StringName,
		crisis_source: StringName
	) -> StringName:
		var p = profiles.get(m, null)
		var commit := float(c.member_commitment.get(m, 0.6))

		var opportunism := _p(p, &"opportunism", 0.5)
		var diplomacy := _p(p, &"diplomacy", 0.5)
		var honor := _p(p, &"honor", 0.5)
		var fear := _p(p, &"fear", 0.5)

		var rel_to_target := _rel(relations, m, c.target_id)
		var likes_target := rel_to_target >= 40.0
		var hates_target := rel_to_target <= -40.0

		var axis_aff := 0.0
		if crisis_axis != &"" and p != null and p.has_method("get_axis_affinity"):
			axis_aff = float(p.get_axis_affinity(crisis_axis, 0)) / 100.0

		var sev := float(world.get("crisis_severity", 0.0))
		var crisis_pressure := (c.kind == &"CRISIS") ? sev : 0.0

		var p_support := 0.25 + 0.55*commit + 0.20*honor + 0.15*(hates_target ? 1.0 : 0.0) + 0.20*crisis_pressure - 0.20*fear - 0.15*opportunism
		var p_undermine := 0.08 + 0.30*opportunism + 0.20*fear + 0.20*(likes_target ? 1.0 : 0.0) - 0.20*honor

		# STOP_CRISIS + corruption-aligned => more undermine
		if c.kind == &"CRISIS" and c.goal == &"STOP_CRISIS" and axis_aff >= 0.55:
			p_undermine += 0.18
			p_support -= 0.10

		# friendly to crisis source => more undermine in STOP coalition
		if crisis_source != &"":
			var rel_to_source := _rel(relations, m, crisis_source)
			if c.goal == &"STOP_CRISIS" and rel_to_source >= 50.0:
				p_undermine += 0.20
				p_support -= 0.10

		p_support = clampf(p_support, 0.0, 0.95)
		p_undermine = clampf(p_undermine, 0.0, 0.80)
		var p_hedge := max(0.0, 1.0 - (p_support + p_undermine))

		# deterministic: choose argmax
		if p_undermine >= p_support and p_undermine >= p_hedge:
			return STANCE_UNDERMINE
		if p_support >= p_hedge:
			return STANCE_SUPPORT
		return STANCE_HEDGE


func _ready() -> void:
	_test_crisis_coalition_truce_then_undermine_creates_suspicion()
	print("\n✅ CrisisCoalitionTruceUndermineTest: OK\n")
	get_tree().quit()


func _test_crisis_coalition_truce_then_undermine_creates_suspicion() -> void:
	var mgr := TestCoalitionManager.new()

	var A := &"A"  # enemy of B, but will SUPPORT coalition
	var B := &"B"  # opportunist + corruption affinity => UNDERMINE
	var D := &"D"  # third member to satisfy min members
	var C := &"C"  # crisis instigator/target of STOP coalition

	var faction_ids: Array[StringName] = [A, B, C, D]

	# Profiles
	var profiles := {
		A: TestFactionProfile.new(
			{&"honor": 0.8, &"diplomacy": 0.6, &"opportunism": 0.2, &"fear": 0.3},
			{&"CORRUPTION": -80}
		),
		# B: can join STOP_CRISIS (honor/diplomacy decent), but stance will undermine due opportunism/fear + corruption affinity
		B: TestFactionProfile.new(
			{&"honor": 0.75, &"diplomacy": 0.7, &"opportunism": 0.9, &"fear": 0.9},
			{&"CORRUPTION": 85}
		),
		D: TestFactionProfile.new(
			{&"honor": 0.65, &"diplomacy": 0.55, &"opportunism": 0.35, &"fear": 0.35},
			{&"CORRUPTION": -40}
		),
		C: TestFactionProfile.new(
			{&"honor": 0.3, &"diplomacy": 0.2, &"opportunism": 0.7, &"fear": 0.4},
			{&"CORRUPTION": 90}
		),
	}

	# Relations matrix
	var relations := {}
	for f in faction_ids:
		relations[f] = {}
	for x in faction_ids:
		for y in faction_ids:
			if x == y: continue
			relations[x][y] = FactionRelationScore.new()

	# A and B are enemies / at war-like
	relations[A][B].relation = -80
	relations[B][A].relation = -80

	# Everyone dislikes C enough to join anti crisis (STOP_CRISIS uses dislike source)
	relations[A][C].relation = -70
	relations[D][C].relation = -60
	relations[B][C].relation = -60

	# (Optional) B is NOT friendly to C here; undermine is driven by corruption affinity + opportunism/fear
	# If you want “B friendly to instigator”, set relations[B][C].relation = +60 (but then join score might drop unless you update join scoring)

	# World crisis
	var world := {
		"crisis_active": true,
		"crisis_severity": 0.85,
		"crisis_axis": &"CORRUPTION",
		"crisis_source_id": C,
		"power_by_faction": {A: 40.0, B: 38.0, C: 50.0, D: 22.0},
		"hegemon_index_by_faction": {} # not needed
	}

	var pool := TestQuestPool.new()
	var notebook := TestArcNotebook.new()

	# Day 10: tick => should form STOP_CRISIS coalition and set truce locks
	mgr.tick_day(10, faction_ids, profiles, relations, world, pool, notebook)

	# Find the created STOP_CRISIS coalition
	var coal: CoalitionManager.CoalitionBlock = null
	for cid in mgr.coalitions_by_id.keys():
		var c = mgr.coalitions_by_id[cid]
		if c.kind == &"CRISIS" and c.goal == &"STOP_CRISIS" and c.target_id == C:
			coal = c
			break

	_assert(coal != null, "should create a STOP_CRISIS coalition")
	_assert(coal.member_ids.has(A) and coal.member_ids.has(B) and coal.member_ids.has(D), "coalition should include A,B,D")

	# Verify pair lock truce between members (A|B in particular)
	var pair_key_ab := _pair_key(A, B)
	_assert(notebook.pair_locks.has(pair_key_ab), "expected pair lock for A|B to exist (temporary coalition truce)")
	var lock := notebook.pair_locks[pair_key_ab]
	_assert(int(lock["until"]) >= 10 + 10, "truce lock should last ~10+ days, got until=%d" % int(lock["until"]))
	_assert(StringName(lock["reason"]) == &"COALITION_TRUCE", "lock reason should be COALITION_TRUCE")

	# Ensure a JOINT OP offer exists (spawned by tick_day)
	var joint_ctx: Dictionary = {}
	for inst in pool.offers:
		if bool(inst.context.get("is_coalition", false)) and StringName(inst.context.get("coalition_id", &"")) == coal.id:
			if inst.context.has("joint_op_type"):
				joint_ctx = inst.context
				break
	_assert(not joint_ctx.is_empty(), "expected at least one joint_op offer context")

	# Apply resolution at day 11: should cause B to UNDERMINE deterministically and lower cohesion, and create suspicion event
	var cohesion_before := coal.cohesion
	var betrayals_before := notebook.count_events(&"COALITION_BETRAYAL")

	mgr.apply_joint_op_resolution(joint_ctx, &"LOYAL", 11, profiles, relations, world, notebook)

	_assert(coal.cohesion < cohesion_before, "cohesion should decrease when a member undermines (before=%d after=%d)" % [cohesion_before, coal.cohesion])

	var betrayals_after := notebook.count_events(&"COALITION_BETRAYAL")
	_assert(betrayals_after > betrayals_before, "should record COALITION_BETRAYAL suspicion event after undermine")


func _pair_key(a: StringName, b: StringName) -> StringName:
	var sa := String(a)
	var sb := String(b)
	return StringName((sa <= sb) ? (sa + "|" + sb) : (sb + "|" + sa))


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

### Notes rapides
- Le test force la stance “UNDermine” de façon déterministe via **argmax** (mêmes signaux que ton modèle), ce qui évite un test flaky.
- Il valide explicitement :
  - **trêve** (pair_lock A|B),
  - **cohesion baisse**,
  - **suspicion** via `COALITION_BETRAYAL`.

Si tu veux, je peux aussi ajouter une assertion bonus : `trust(A→B)` baisse fortement après l’undermine (via les deltas de `_apply_member_deltas`), ce qui rend la suspicion “mesurable” aussi par les métriques relationnelles, pas seulement via ArcNotebook.

Moi:
Bonne idée, fais ajouter une assertion bonus : trust(A→B) baisse fortement après l’undermine (via les deltas de _apply_member_deltas), ce qui rend la suspicion “mesurable” aussi par les métriques relationnelles, pas seulement via ArcNotebook.

ChatGPT:
Voici le **patch exact** du test pour ajouter l’assertion bonus “`trust(A→B)` baisse fortement après l’undermine”.

L’idée : on initialise `trust(A→B)` à une valeur connue (ex: 50), puis après `apply_joint_op_resolution`, on vérifie qu’il a chuté d’au moins **6** (car `_apply_member_deltas` applique `-6` sur trust quand SUPPORT vs UNDERMINE).

---

## Patch à appliquer dans `CrisisCoalitionTruceUndermineTest.gd`

### 1) Initialiser le trust avant la résolution
Dans la section “A and B are enemies / at war-like”, ajoute :

```gdscript
	relations[A][B].trust = 50
	relations[B][A].trust = 50
```

(Juste après `relations[A][B].relation = -80` etc.)

### 2) Capturer `trust(A→B)` avant l’appel
Juste avant :

```gdscript
	mgr.apply_joint_op_resolution(joint_ctx, &"LOYAL", 11, profiles, relations, world, notebook)
```

Ajoute :

```gdscript
	var trust_ab_before := relations[A][B].trust
```

### 3) Ajouter l’assertion après l’appel
Juste après l’assertion sur la cohésion, ajoute :

```gdscript
	var trust_ab_after := relations[A][B].trust
	_assert(trust_ab_after <= trust_ab_before - 6,
		"trust(A→B) should drop strongly after undermine (before=%d after=%d)" % [trust_ab_before, trust_ab_after])
```

---

### Pourquoi “-6” ?
Dans `_apply_member_deltas`, le cas SUPPORT vs UNDERMINE fait :

- `trust -6` dans les deux sens (`a→b` et `b→a`), donc c’est un seuil clair et stable.

Si tu préfères une marge plus large (au cas où tu changes les deltas), mets `-4` ou `-5`.

Moi:
Ok, on passe a :
6) “Domestic pressure” (politique interne)
Même sans sim interne complexe, un scaler suffit :
• internal_stability ou war_support
• la guerre longue baisse le support → pousse TRUCE/REPARATIONS même si l’ennemi est détesté.
Effet : sortie de guerre organique + quêtes “maintenir l’ordre / propaganda / appease nobles

ChatGPT:
OK — “Domestic pressure” est parfait pour obtenir une **sortie de guerre organique** sans sim interne lourde.

## 1) Modèle minimal de données

Un seul scaler suffit, mais je te propose 2 champs + 1 dérivé (super lisible) :

```gdscript
# FactionDomesticState.gd
class_name FactionDomesticState
extends RefCounted

var stability: int = 70        # 0..100 (ordre public / cohésion interne)
var war_support: int = 70      # 0..100 (acceptation sociale de la guerre)
var unrest: int = 10           # 0..100 (moteur de quests "maintenir l'ordre")

func pressure() -> float:
	# 0..1 (plus haut = plus fragile)
	return clampf(0.55*(1.0 - war_support/100.0) + 0.45*(unrest/100.0), 0.0, 1.0)
```

> `pressure()` devient ton “bouton magique” : plus il monte, plus l’IA pousse **TRUCE/REPARATIONS**, même si l’ennemi est haï.

---

## 2) Tick journalier (MVP) : guerre longue → support↓, unrest↑

On s’appuie sur ce que tu as déjà : **ArcNotebook** (historique), `weariness` relationnel, budget/or, et éventuellement des tags monde.

```gdscript
# DomesticPressureUtil.gd
class_name DomesticPressureUtil
extends RefCounted

static func tick_domestic(
	day: int,
	faction_id: StringName,
	dom: FactionDomesticState,
	profile,                        # FactionProfile (optionnel)
	economy,                        # FactionEconomy (optionnel)
	arc_notebook,                   # pour compter jours de guerre / pertes proxy
	relations: Dictionary,          # relations[faction][other] -> FactionRelationScore
	world: Dictionary               # tags / crisis flags
) -> void:
	# ---- inputs/proxies ----
	var diplo := _p(profile, &"diplomacy", 0.5)
	var honor := _p(profile, &"honor", 0.5)
	var bell := _p(profile, &"belligerence", 0.5)
	var fear := _p(profile, &"fear", 0.5)

	var gold := (economy.gold if economy != null and economy.has_method("get") == false else (economy.gold if economy != null else 0))
	var poor := (gold < 80) # proxy simple (à remplacer par income/expenses si tu as)

	var war_days := 0
	if arc_notebook != null and arc_notebook.has_method("get_faction_counter"):
		war_days = int(arc_notebook.get_faction_counter(faction_id, &"war_days_rolling_30", 0))
	# fallback: approx via relations weariness (moyenne)
	if war_days == 0 and relations.has(faction_id):
		var w := 0.0
		var n := 0.0
		for other in relations[faction_id].keys():
			var r: FactionRelationScore = relations[faction_id][other]
			w += float(r.weariness)
			n += 1.0
		war_days = int(clampf((w/max(1.0, n)) / 4.0, 0.0, 30.0)) # grossier mais utile

	var crisis := bool(world.get("crisis_active", false))
	var crisis_sev := float(world.get("crisis_severity", 0.0))

	# ---- dynamics ----
	# guerre longue => war_support baisse, unrest monte
	var war_fatigue := clampf(float(war_days) / 30.0, 0.0, 1.0) # 0..1
	var support_drop := 1.2 + 2.5*war_fatigue + 0.8*bell - 0.9*diplo - 0.6*honor
	if poor: support_drop += 0.9
	if crisis: support_drop += 0.6*crisis_sev  # crise fatigue la population

	var unrest_rise := 0.6 + 1.8*war_fatigue + 0.8*fear - 0.6*diplo
	if poor: unrest_rise += 0.8
	if crisis: unrest_rise += 0.7*crisis_sev

	# petits amortisseurs (propagande/ordre) : ici on triche via stabilité actuelle
	support_drop *= (1.0 + 0.35*(1.0 - dom.stability/100.0))
	unrest_rise *= (1.0 - 0.25*(dom.stability/100.0))

	# ---- apply ----
	dom.war_support = int(clampi(dom.war_support - int(round(support_drop)), 0, 100))
	dom.unrest = int(clampi(dom.unrest + int(round(unrest_rise)), 0, 100))

	# stabilité suit l’unrest
	var stab_delta := -int(round(0.6*unrest_rise)) + int(round(0.25*diplo*2.0))
	dom.stability = int(clampi(dom.stability + stab_delta, 0, 100))


static func _p(profile, key: StringName, default_val: float) -> float:
	if profile == null:
		return default_val
	if profile.has_method("get_personality"):
		return float(profile.get_personality(key, default_val))
	if profile is Dictionary:
		return float(profile.get("personality", {}).get(key, default_val))
	return default_val
```

---

## 3) Comment ça influence Arcs/Goals (effet “sortie de guerre”)

Tu utilises `pressure()` comme multiplicateur :

- **actions offensives** (raid, declare_war, sabotage) : probabilité × `(1 - 0.55*pressure)`
- **actions de sortie** (truce_talks, reparations, armistice, enforcement) : probabilité × `(1 + 0.75*pressure)`
- **coalitions** : un membre à forte pression a plus de chance de **HEDGE/UNDERMINE** (capacité politique limitée)

Exemple (dans ton `compute_arc_event_chance` ou table action selection) :
```gdscript
var p := domestic.pressure()
if action_is_offensive:
	chance *= (1.0 - 0.55*p)
else:
	chance *= (1.0 + 0.75*p)

# règle simple
if domestic.war_support <= 25:
	# même si l’ennemi est haï, on privilégie TRUCE/REPARATIONS
	force_prefer_truce = true
```

---

## 4) Offres “domestic” (pont vers QuestPool)

Quand `pressure >= 0.65` ou `unrest >= 60`, tu spawns **1 offer max** par faction (anti-spam) :

### Mapping MVP
- `domestic.maintain_order` (combat) : réprimer émeutes / bandits / milice
- `domestic.propaganda` (diplomacy/stealth) : discours, rumeurs, contrôler presse/temples
- `domestic.appease_nobles` (gold/escort/diplomacy) : payer / négocier / escorter émissaire
- `domestic.reparations_push` (diplomacy) : “faire accepter une paix coûteuse”

**Effets typiques à la résolution** :
- LOYAL : `unrest -15`, `stability +8`, `war_support +6` (propaganda) OU `+0` (maintain_order)
- NEUTRAL : moitié
- TRAITOR : `unrest +8`, `stability -6` (aggrave la crise interne)

Context standard :
```gdscript
"is_domestic_offer": true
"domestic_action": "maintain_order|propaganda|appease_nobles|reparations_push"
"giver_faction_id": faction_id
"stake": {"pressure": p, "unrest": unrest}
"expires_in_days": 5..9
```

---

Si tu veux, prochaine brique logique : je te donne un `DomesticOfferFactory.spawn_offer_if_needed(faction_id, domestic_state)` + `apply_domestic_resolution(context, choice)` (comme on a fait pour Knowledge), et un mini test “war_support tombe en 20 jours de guerre → apparition d’offres TRUCE + domestic”.

Moi:
Ok prochaine brique logique : je te donne un DomesticOfferFactory.spawn_offer_if_needed(faction_id, domestic_state) + apply_domestic_resolution(context, choice) (comme on a fait pour Knowledge), et un mini test “war_support tombe en 20 jours de guerre → apparition d’offres TRUCE + domestic

ChatGPT:
Voici la brique **DomesticOfferFactory** + **apply_domestic_resolution** + un **mini test** “20 jours de guerre ⇒ war_support chute ⇒ apparition d’offres TRUCE + domestic”.

---

## 1) `DomesticOfferFactory.gd`

```gdscript
# DomesticOfferFactory.gd
class_name DomesticOfferFactory
extends RefCounted

const DEFAULT_COOLDOWN_DAYS := 5

# choix d'action (MVP)
const ACTION_MAINTAIN_ORDER := &"domestic.maintain_order"
const ACTION_PROPAGANDA     := &"domestic.propaganda"
const ACTION_APPEASE_NOBLES  := &"domestic.appease_nobles"
const ACTION_REPARATIONS     := &"domestic.reparations_push"

static func spawn_offer_if_needed(
	faction_id: StringName,
	domestic_state,                 # FactionDomesticState
	day: int,
	quest_pool,                     # QuestPool.try_add_offer(inst)
	arc_notebook = null,
	economy = null,                 # optional (gold)
	params: Dictionary = {}
):
	var pressure := float(domestic_state.pressure())
	var unrest := int(domestic_state.unrest)
	var war_support := int(domestic_state.war_support)
	var stability := int(domestic_state.stability)

	# conditions d’apparition (MVP)
	if pressure < 0.55 and unrest < 55 and war_support > 35:
		return null

	var cooldown := int(params.get("cooldown_days", DEFAULT_COOLDOWN_DAYS))

	# cooldown anti-spam (si ArcNotebook le supporte)
	if arc_notebook != null and arc_notebook.has_method("can_spawn_domestic_offer"):
		if not arc_notebook.can_spawn_domestic_offer(faction_id, day, cooldown):
			return null

	# choisir action
	var action: StringName
	if war_support <= 25:
		action = ACTION_REPARATIONS
	elif unrest >= 70:
		action = ACTION_MAINTAIN_ORDER
	elif stability <= 40:
		action = ACTION_APPEASE_NOBLES
	else:
		action = ACTION_PROPAGANDA

	# coût politique/éco (MVP) + fallback
	var cost_gold := 0
	if action == ACTION_APPEASE_NOBLES:
		cost_gold = 60
	if action == ACTION_REPARATIONS:
		cost_gold = 30

	if economy != null and cost_gold > 0 and int(economy.gold) < cost_gold:
		# pas assez d’or => fallback vers propaganda (toujours faisable)
		action = ACTION_PROPAGANDA
		cost_gold = 0

	# tier/deadline
	var tier := clampi(1 + int(floor(pressure * 4.0)) + (unrest >= 70 ? 1 : 0), 1, 5)
	var deadline := clampi(9 - int(floor(pressure * 5.0)), 4, 9)

	var template := _build_template_fallback(action, tier, deadline)

	var ctx := {
		"is_domestic_offer": true,
		"domestic_action": action,
		"giver_faction_id": faction_id,
		"tier": tier,
		"expires_in_days": deadline,
		"stake": {"pressure": pressure, "unrest": unrest, "war_support": war_support, "stability": stability},
		"domestic_cost_gold": cost_gold,
		"resolution_profile_id": &"domestic_default"
	}

	var inst := QuestInstance.new(template, ctx)
	inst.status = "AVAILABLE"
	inst.started_on_day = day
	inst.expires_on_day = day + deadline

	if quest_pool != null and quest_pool.has_method("try_add_offer"):
		if not quest_pool.try_add_offer(inst):
			return null

	if arc_notebook != null and arc_notebook.has_method("mark_domestic_offer_spawned"):
		arc_notebook.mark_domestic_offer_spawned(faction_id, day)

	return inst


static func apply_domestic_resolution(
	context: Dictionary,
	choice: StringName,             # LOYAL/NEUTRAL/TRAITOR
	domestic_state,                 # FactionDomesticState
	economy = null
) -> void:
	if not bool(context.get("is_domestic_offer", false)):
		return

	var action: StringName = StringName(context.get("domestic_action", &""))
	var cost_gold := int(context.get("domestic_cost_gold", 0))

	# payer si nécessaire (LOYAL/NEUTRAL seulement)
	if economy != null and cost_gold > 0 and (choice == &"LOYAL" or choice == &"NEUTRAL"):
		var pay := cost_gold if choice == &"LOYAL" else int(ceil(cost_gold * 0.5))
		economy.gold = max(0, int(economy.gold) - pay)

	# effets (MVP)
	var du := 0
	var ds := 0
	var dw := 0

	match action:
		ACTION_MAINTAIN_ORDER:
			if choice == &"LOYAL":    du = -18; ds = +6;  dw = +0
			elif choice == &"NEUTRAL":du = -9;  ds = +3;  dw = +0
			else:                    du = +10; ds = -6;  dw = -3
		ACTION_PROPAGANDA:
			if choice == &"LOYAL":    du = -8;  ds = +3;  dw = +10
			elif choice == &"NEUTRAL":du = -4;  ds = +1;  dw = +5
			else:                    du = +8;  ds = -4;  dw = -6
		ACTION_APPEASE_NOBLES:
			if choice == &"LOYAL":    du = -10; ds = +10; dw = +4
			elif choice == &"NEUTRAL":du = -5;  ds = +5;  dw = +2
			else:                    du = +12; ds = -10; dw = -4
		ACTION_REPARATIONS:
			# pousse la sortie de guerre
			if choice == &"LOYAL":    du = -6;  ds = +4;  dw = +12
			elif choice == &"NEUTRAL":du = -3;  ds = +2;  dw = +6
			else:                    du = +6;  ds = -5;  dw = -6
		_:
			pass

	domestic_state.unrest = int(clampi(domestic_state.unrest + du, 0, 100))
	domestic_state.stability = int(clampi(domestic_state.stability + ds, 0, 100))
	domestic_state.war_support = int(clampi(domestic_state.war_support + dw, 0, 100))


static func _build_template_fallback(id: StringName, tier: int, expires_in_days: int):
	var t := QuestTemplate.new()
	t.id = id
	t.title = String(id)
	t.description = "Domestic offer: %s" % String(id)
	t.category = &"DOMESTIC"
	t.tier = tier
	t.objective_type = &"GENERIC"
	t.objective_target = &""
	t.objective_count = 1
	t.expires_in_days = expires_in_days
	return t
```

---

## 2) Mini factory TRUCE (pour le test)

```gdscript
# ArcTruceOfferFactory.gd (mini pour test)
class_name ArcTruceOfferFactory
extends RefCounted

static func spawn_truce_offer_if_needed(
	faction_id: StringName,
	target_id: StringName,
	domestic_state,
	day: int,
	quest_pool,
	arc_notebook = null
):
	var p := float(domestic_state.pressure())
	if p < 0.65 and int(domestic_state.war_support) > 25:
		return null

	# cooldown simple
	if arc_notebook != null and arc_notebook.has_method("can_spawn_truce_offer"):
		if not arc_notebook.can_spawn_truce_offer(faction_id, target_id, day, 6):
			return null

	var template := DomesticOfferFactory._build_template_fallback(&"arc.truce_talks", 2, 6)
	template.category = &"ARC"

	var ctx := {
		"is_arc_offer": true,
		"arc_action_type": &"arc.truce_talks",
		"giver_faction_id": faction_id,
		"antagonist_faction_id": target_id,
		"tier": 2,
		"expires_in_days": 6,
	}

	var inst := QuestInstance.new(template, ctx)
	inst.status = "AVAILABLE"
	inst.started_on_day = day
	inst.expires_on_day = day + 6

	if quest_pool != null and quest_pool.has_method("try_add_offer"):
		if not quest_pool.try_add_offer(inst):
			return null

	if arc_notebook != null and arc_notebook.has_method("mark_truce_offer_spawned"):
		arc_notebook.mark_truce_offer_spawned(faction_id, target_id, day)

	return inst
```

---

## 3) Mini test : “20 jours de guerre ⇒ TRUCE + domestic apparaissent”

```gdscript
extends Node
class_name DomesticPressureOffers20DaysTest

class TestQuestPool:
	var offers: Array = []
	func try_add_offer(inst) -> bool:
		offers.append(inst)
		return true

class TestArcNotebook:
	var last_domestic: Dictionary = {}
	var last_truce: Dictionary = {}
	var faction_counters: Dictionary = {}

	func can_spawn_domestic_offer(faction_id: StringName, day: int, cooldown: int) -> bool:
		return (day - int(last_domestic.get(faction_id, -999999))) >= cooldown
	func mark_domestic_offer_spawned(faction_id: StringName, day: int) -> void:
		last_domestic[faction_id] = day

	func can_spawn_truce_offer(a: StringName, b: StringName, day: int, cooldown: int) -> bool:
		var k := StringName(String(a) + "|" + String(b))
		return (day - int(last_truce.get(k, -999999))) >= cooldown
	func mark_truce_offer_spawned(a: StringName, b: StringName, day: int) -> void:
		var k := StringName(String(a) + "|" + String(b))
		last_truce[k] = day

	func set_faction_counter(fid: StringName, name: StringName, val: int) -> void:
		if not faction_counters.has(fid):
			faction_counters[fid] = {}
		faction_counters[fid][name] = val
	func get_faction_counter(fid: StringName, name: StringName, default_val: int = 0) -> int:
		if not faction_counters.has(fid): return default_val
		return int(faction_counters[fid].get(name, default_val))


class FactionDomesticState:
	var stability: int = 70
	var war_support: int = 75
	var unrest: int = 10
	func pressure() -> float:
		return clampf(0.55*(1.0 - war_support/100.0) + 0.45*(unrest/100.0), 0.0, 1.0)

class FactionEconomy:
	var gold: int = 120


func _ready() -> void:
	_test_20_days_war_support_drops_and_spawns_truce_and_domestic()
	print("\n✅ DomesticPressureOffers20DaysTest: OK\n")
	get_tree().quit()


func _test_20_days_war_support_drops_and_spawns_truce_and_domestic() -> void:
	var A := &"A"
	var B := &"B"

	var dom := FactionDomesticState.new()
	var eco := FactionEconomy.new()
	var pool := TestQuestPool.new()
	var nb := TestArcNotebook.new()

	# simulate "20 days of war" via war_days_rolling_30 counter + tick_domestic
	var relations := {A: {B: FactionRelationScore.new()}} # minimal (not used by tick in this test)
	var profile := {"personality": {&"diplomacy": 0.3, &"honor": 0.5, &"belligerence": 0.7, &"fear": 0.6}}
	var world := {"crisis_active": false}

	var saw_domestic := false
	var saw_truce := false

	for day in range(1, 21):
		# “guerre continue” : 1..20
		nb.set_faction_counter(A, &"war_days_rolling_30", day)

		# tick domestic pressure
		DomesticPressureUtil.tick_domestic(day, A, dom, profile, eco, nb, relations, world)

		# spawn domestic offer if needed
		var inst_dom = DomesticOfferFactory.spawn_offer_if_needed(A, dom, day, pool, nb, eco, {"cooldown_days": 3})
		if inst_dom != null:
			saw_domestic = true

		# spawn truce if needed (linked to domestic pressure/war_support)
		var inst_truce = ArcTruceOfferFactory.spawn_truce_offer_if_needed(A, B, dom, day, pool, nb)
		if inst_truce != null:
			saw_truce = true

	# Assertions
	_assert(dom.war_support <= 35, "war_support should drop significantly after 20 war days (got %d)" % dom.war_support)
	_assert(saw_domestic, "should spawn at least one domestic offer within 20 war days")
	_assert(saw_truce, "should spawn at least one TRUCE offer when pressure high / war_support low")

	# Bonus: ensure we really have both types in pool
	var dom_count := 0
	var truce_count := 0
	for inst in pool.offers:
		if bool(inst.context.get("is_domestic_offer", false)): dom_count += 1
		if StringName(inst.context.get("arc_action_type", &"")) == &"arc.truce_talks": truce_count += 1

	_assert(dom_count >= 1, "pool should contain domestic offers")
	_assert(truce_count >= 1, "pool should contain truce offers")


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

Si tu veux ensuite : je te propose le hook “propre” dans ton **GoalPlanner** : quand `domestic.pressure() > 0.7`, on force le goal **TRUCE/REPARATIONS**, et on réduit automatiquement les budgets d’actions offensivesTF (ça stabilise énormément les sorties de guerre).

Moi:
Ok 
propose le hook “propre” dans ton GoalPlanner : quand domestic.pressure() > 0.7, on force le goal TRUCE/REPARATIONS, et on réduit automatiquement les budgets d’actions offensivesTF (ça stabilise énormément les sorties de guerre).

ChatGPT:
Voici un **hook “propre”** (MVP) pour ton **GoalPlanner** : quand `domestic.pressure() > 0.7`, on **force TRUCE/REPARATIONS** et on **réduit automatiquement le budget offensif** (sans casser ton système existant).

L’idée : tu ajoutes une étape “policy gate” juste avant `plan_action(goal)`.

---

## 1) Ajout minimal : `DomesticPolicyGate.apply(...)`

```gdscript
# DomesticPolicyGate.gd
class_name DomesticPolicyGate
extends RefCounted

static func apply(
	faction_id: StringName,
	goal: Dictionary,              # ton goal courant (ou un objet)
	ctx: Dictionary,               # world sim ctx / planner ctx
	domestic_state,                # FactionDomesticState
	params: Dictionary = {}
) -> Dictionary:
	var p := float(domestic_state.pressure())
	var threshold := float(params.get("pressure_threshold", 0.7))

	# Nothing to do
	if p < threshold:
		return goal

	# 1) Force goal TRUCE/REPARATIONS (mais réversible)
	# On met en "suspended_goal" l'objectif précédent pour y revenir plus tard.
	if not goal.has("suspended_goal"):
		goal["suspended_goal"] = goal.duplicate(true)

	goal["type"] = &"TRUCE"  # ou &"REPARATIONS"
	goal["reason"] = &"DOMESTIC_PRESSURE"
	goal["until_day"] = int(ctx.get("day", 0)) + int(params.get("force_days", 7))

	# 2) Réduire budgets offensifs (0..1 multiplier)
	var min_mult := float(params.get("min_offensive_budget_mult", 0.25))
	var mult := clampf(1.0 - 0.85*(p - threshold)/(1.0 - threshold), min_mult, 1.0)

	# exemple : on stocke des multiplicateurs que le planner utilisera
	ctx["budget_mult_offensive"] = mult
	ctx["budget_mult_defensive"] = max(0.8, mult + 0.35)  # on garde de la défense
	ctx["prefer_actions"] = [&"arc.truce_talks", &"arc.reparations", &"domestic.maintain_order", &"domestic.appease_nobles"]

	return goal
```

---

## 2) Hook dans ton `FactionGoalPlanner.plan_action(goal, ctx)`

Juste avant la sélection d’action :

```gdscript
# FactionGoalPlanner.gd (extrait)
func plan_action(goal: Dictionary, ctx: Dictionary) -> Dictionary:
	var fid: StringName = ctx["faction_id"]
	var domestic_state = ctx.get("domestic_state", null)
	if domestic_state != null:
		goal = DomesticPolicyGate.apply(fid, goal, ctx, domestic_state, {
			"pressure_threshold": 0.7,
			"force_days": 7,
			"min_offensive_budget_mult": 0.25
		})

	# ... ensuite ton choix d'action normal
	# mais en tenant compte de ctx["budget_mult_offensive"] si présent
	return _plan_action_core(goal, ctx)
```

---

## 3) Réduction du budget offensif (intégration simple)

Si tu as déjà un budget “points” (actions par jour/semaine), tu appliques un multiplicateur **uniquement sur les actions offensives** :

```gdscript
func _can_afford_action(action: StringName, base_cost: int, ctx: Dictionary) -> bool:
	var budget := int(ctx.get("budget_points", 0))
	var off_mult := float(ctx.get("budget_mult_offensive", 1.0))

	var cost := base_cost
	if _is_offensive(action):
		cost = int(ceil(float(base_cost) / max(0.01, off_mult))) # offensif devient "plus cher"
	return budget >= cost
```

> Variante plus intuitive : au lieu de rendre l’offensif plus cher, tu réduis le budget disponible pour offensif. Mais “cost inflation” est simple et stable.

---

## 4) Revenir au goal précédent (éviter blocage en TRUCE)

Dans ton tick daily (GoalManagerRunner), juste avant `ensure_goal()` :

```gdscript
func maybe_restore_suspended_goal(goal: Dictionary, ctx: Dictionary, domestic_state) -> Dictionary:
	if not goal.has("suspended_goal"):
		return goal
	var day := int(ctx.get("day", 0))
	var until := int(goal.get("until_day", 0))
	var p := float(domestic_state.pressure())
	if day >= until and p < 0.62:
		return goal["suspended_goal"]
	return goal
```

Et tu l’appelles avant planification.

---

## 5) Effet gameplay (ce que ça change concrètement)
- Quand la pression interne monte, la faction :
  - génère des offers **trêve / réparations / maintien de l’ordre**,
  - **réduit mécaniquement** la fréquence des raids/guerre,
  - “sort” de la guerre sans que tu aies besoin de scripts spéciaux.

Si tu veux, prochaine brique logique : un mini test “pressure gate” qui simule `pressure>0.7` et vérifie que `goal.type` est forcé en TRUCE + que le coût offensif est effectivement augmenté (ou le budget réduit).

Moi:
Ok 
prochaine brique logique : un mini test “pressure gate” qui simule pressure>0.7 et vérifie que goal.type est forcé en TRUCE + que le coût offensif est effectivement augmenté (ou le budget réduit).

ChatGPT:
Voici un mini test **“pressure gate”** qui :

1) simule `pressure > 0.7`  
2) vérifie que `goal.type` est forcé en `TRUCE`  
3) vérifie que `ctx["budget_mult_offensive"] < 1.0`  
4) vérifie qu’un **coût offensif est effectivement augmenté** via `_can_afford_action()` (inflation de coût)

---

## `tests/DomesticPressureGateTest.gd`

```gdscript
extends Node
class_name DomesticPressureGateTest

# ---- minimal domestic state ----
class FactionDomesticState:
	var stability: int = 40
	var war_support: int = 15
	var unrest: int = 85
	func pressure() -> float:
		return clampf(0.55*(1.0 - war_support/100.0) + 0.45*(unrest/100.0), 0.0, 1.0)

# ---- minimal policy gate (use your real DomesticPolicyGate if available) ----
class DomesticPolicyGate:
	static func apply(faction_id: StringName, goal: Dictionary, ctx: Dictionary, domestic_state, params: Dictionary = {}) -> Dictionary:
		var p := float(domestic_state.pressure())
		var threshold := float(params.get("pressure_threshold", 0.7))
		if p < threshold:
			return goal

		if not goal.has("suspended_goal"):
			goal["suspended_goal"] = goal.duplicate(true)

		goal["type"] = &"TRUCE"
		goal["reason"] = &"DOMESTIC_PRESSURE"
		goal["until_day"] = int(ctx.get("day", 0)) + int(params.get("force_days", 7))

		var min_mult := float(params.get("min_offensive_budget_mult", 0.25))
		var mult := clampf(1.0 - 0.85*(p - threshold)/(1.0 - threshold), min_mult, 1.0)

		ctx["budget_mult_offensive"] = mult
		ctx["budget_mult_defensive"] = max(0.8, mult + 0.35)
		ctx["prefer_actions"] = [&"arc.truce_talks", &"arc.reparations", &"domestic.maintain_order"]

		return goal

# ---- minimal affordability check with offensive cost inflation ----
func _is_offensive(action: StringName) -> bool:
	return action == &"arc.raid" or action == &"arc.declare_war" or action == &"arc.sabotage"

func _can_afford_action(action: StringName, base_cost: int, ctx: Dictionary) -> bool:
	var budget := int(ctx.get("budget_points", 0))
	var off_mult := float(ctx.get("budget_mult_offensive", 1.0))
	var cost := base_cost
	if _is_offensive(action):
		cost = int(ceil(float(base_cost) / max(0.01, off_mult)))
	return budget >= cost


func _ready() -> void:
	_test_pressure_gate_forces_truce_and_inflates_offensive_cost()
	print("\n✅ DomesticPressureGateTest: OK\n")
	get_tree().quit()


func _test_pressure_gate_forces_truce_and_inflates_offensive_cost() -> void:
	var domestic := FactionDomesticState.new()
	var ctx := {"day": 10, "faction_id": &"A", "budget_points": 10, "domestic_state": domestic}
	var goal := {"type": &"WAR", "target_id": &"B"}

	var p := domestic.pressure()
	_assert(p > 0.7, "precondition: pressure must be > 0.7 (got %.3f)" % p)

	goal = DomesticPolicyGate.apply(&"A", goal, ctx, domestic, {
		"pressure_threshold": 0.7,
		"force_days": 7,
		"min_offensive_budget_mult": 0.25
	})

	# 1) goal forced to TRUCE
	_assert(StringName(goal.get("type", &"")) == &"TRUCE", "goal.type should be forced to TRUCE under high pressure")
	_assert(goal.has("suspended_goal"), "goal should keep suspended_goal for later restore")

	# 2) offensive budget multiplier reduced
	var mult := float(ctx.get("budget_mult_offensive", 1.0))
	_assert(mult < 1.0, "budget_mult_offensive should be < 1.0 under high pressure (got %.3f)" % mult)

	# 3) offensive cost inflation makes a previously affordable offensive action unaffordable
	# base_cost 10, budget 10:
	# without gate => affordable
	var ctx_no_gate := {"budget_points": 10} # no budget_mult_offensive => 1.0
	_assert(_can_afford_action(&"arc.raid", 10, ctx_no_gate), "without gate, arc.raid base_cost=10 should be affordable")

	# with gate => cost becomes ceil(10 / mult) >= 11 if mult <= 0.91
	var can_after := _can_afford_action(&"arc.raid", 10, ctx)
	_assert(not can_after, "with gate, arc.raid should become unaffordable due to inflated cost (mult=%.3f)" % mult)

	# non-offensive action should remain affordable
	_assert(_can_afford_action(&"arc.truce_talks", 4, ctx), "non-offensive action should remain affordable")


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

### Ce que ce test prouve
- le “policy gate” **change le goal** de manière déterministe
- il **réduit la capacité offensive** de façon mécanique, ce qui stabilise les sorties de guerre
- il ne bloque pas la faction (actions non-offensives restent faisables)

Si tu veux, prochaine brique logique : brancher ce gate directement dans ton simulateur (`FactionGoalManagerRunner.ensure_goal` ou `plan_action`) et faire un test d’intégration “20 jours de WAR + pression => plus de raids à partir de J15, mais apparition de trêves/domestic”.

Moi:
Ok
prochaine brique logique : brancher ce gate directement dans ton simulateur (FactionGoalManagerRunner.ensure_goal ou plan_action) et faire un test d’intégration “20 jours de WAR + pression => plus de raids à partir de J15, mais apparition de trêves/domestic”.

ChatGPT:
Voilà le **branching “propre”** dans ton simulateur + un **test d’intégration** “20 jours WAR + pression ⇒ plus de raids après J15, mais des offres TRUCE + domestic apparaissent”.

---

## 1) Hook dans le simulateur

### Option A (recommandée) : dans `FactionGoalPlanner.plan_action(goal, ctx)`
Tu forces *temporairement* le goal (sans casser ta machine de goals) et tu poses les multiplicateurs de budget.

```gdscript
# FactionGoalPlanner.gd
func plan_action(goal: Dictionary, ctx: Dictionary) -> Dictionary:
	var fid: StringName = ctx["faction_id"]
	var dom = ctx.get("domestic_state", null)
	if dom != null:
		goal = DomesticPolicyGate.apply(fid, goal, ctx, dom, {
			"pressure_threshold": 0.7,
			"force_days": 7,
			"min_offensive_budget_mult": 0.25
		})

	# ... ton code normal
	return _plan_action_core(goal, ctx)
```

Et dans ton check budget (ou coût), applique l’inflation offensive :

```gdscript
func _can_afford_action(action: StringName, base_cost: int, ctx: Dictionary) -> bool:
	var budget := int(ctx.get("budget_points", 0))
	var mult := float(ctx.get("budget_mult_offensive", 1.0))
	var cost := base_cost
	if _is_offensive(action):
		cost = int(ceil(float(base_cost) / max(0.01, mult)))
	return budget >= cost
```

### Option B (en plus) : dans `ensure_goal` (si tu veux que le goal “visible” soit TRUCE)
Avant de renvoyer le goal :

```gdscript
# FactionGoalManagerRunner.gd
func ensure_goal(fid: StringName, ctx: Dictionary) -> Dictionary:
	var goal := _get_or_create_goal(fid, ctx)

	var dom = ctx.get("domestic_state", null)
	if dom != null:
		goal = maybe_restore_suspended_goal(goal, ctx, dom)
		goal = DomesticPolicyGate.apply(fid, goal, ctx, dom)

	_set_goal(fid, goal)
	return goal
```

---

## 2) Test d’intégration

Ce test simule une faction A “en WAR” qui choisit normalement des **raids** tant qu’elle peut les payer, mais dès que la pression dépasse 0.7 (vers J15), le gate force TRUCE + rend les raids inabordables, et on vérifie qu’on spawn bien **TRUCE + domestic**.

> Le test suppose que tu as déjà : `DomesticPolicyGate`, `DomesticOfferFactory`, `ArcTruceOfferFactory`, et une classe `FactionDomesticState` (ou équivalent). Ajuste si tes noms diffèrent.

### `tests/IntegrationWarPressureStopsRaidsTest.gd`

```gdscript
extends Node
class_name IntegrationWarPressureStopsRaidsTest

class TestQuestPool:
	var offers: Array = []
	func try_add_offer(inst) -> bool:
		offers.append(inst)
		return true

class TestArcNotebook:
	var last_domestic: Dictionary = {}
	var last_truce: Dictionary = {}

	func can_spawn_domestic_offer(fid: StringName, day: int, cooldown: int) -> bool:
		return (day - int(last_domestic.get(fid, -999999))) >= cooldown
	func mark_domestic_offer_spawned(fid: StringName, day: int) -> void:
		last_domestic[fid] = day

	func can_spawn_truce_offer(a: StringName, b: StringName, day: int, cooldown: int) -> bool:
		var k := StringName(String(a) + "|" + String(b))
		return (day - int(last_truce.get(k, -999999))) >= cooldown
	func mark_truce_offer_spawned(a: StringName, b: StringName, day: int) -> void:
		var k := StringName(String(a) + "|" + String(b))
		last_truce[k] = day

# Planner mini (intégration du gate + budget inflation)
class PlannerSim:
	func _is_offensive(action: StringName) -> bool:
		return action == &"arc.raid" or action == &"arc.declare_war" or action == &"arc.sabotage"

	func _can_afford(action: StringName, base_cost: int, ctx: Dictionary) -> bool:
		var budget := int(ctx.get("budget_points", 0))
		var mult := float(ctx.get("budget_mult_offensive", 1.0))
		var cost := base_cost
		if _is_offensive(action):
			cost = int(ceil(float(base_cost) / max(0.01, mult)))
		return budget >= cost

	func plan_action(goal: Dictionary, ctx: Dictionary) -> StringName:
		var fid: StringName = ctx["faction_id"]
		var dom = ctx.get("domestic_state", null)
		if dom != null:
			goal = DomesticPolicyGate.apply(fid, goal, ctx, dom, {
				"pressure_threshold": 0.7,
				"force_days": 7,
				"min_offensive_budget_mult": 0.25
			})

		# WAR => préfère raid si possible
		if StringName(goal.get("type", &"")) == &"WAR":
			if _can_afford(&"arc.raid", 10, ctx):
				return &"arc.raid"
			return &"arc.defend"

		# TRUCE => truce talks
		if StringName(goal.get("type", &"")) == &"TRUCE":
			return &"arc.truce_talks"

		return &"arc.idle"


func _ready() -> void:
	_test_20_days_war_pressure_stops_raids_after_day15_and_spawns_truce_domestic()
	print("\n✅ IntegrationWarPressureStopsRaidsTest: OK\n")
	get_tree().quit()


func _test_20_days_war_pressure_stops_raids_after_day15_and_spawns_truce_domestic() -> void:
	var A := &"A"
	var B := &"B"

	var pool := TestQuestPool.new()
	var nb := TestArcNotebook.new()
	var planner := PlannerSim.new()

	# Domestic state (utilise TA classe si tu l’as déjà)
	var dom := FactionDomesticState.new()
	dom.stability = 60
	dom.war_support = 75
	dom.unrest = 10

	# Economy (optionnel)
	var economy := null
	if Engine.has_singleton("Dummy"): pass # noop, juste pour éviter warning
	# Si tu as une classe d’économie, branche-la ici; sinon DomesticOfferFactory fallback propaganda.

	# Sim config
	var actions_by_day: Dictionary = {}
	var goal := {"type": &"WAR", "target_id": B}

	# On force une montée déterministe de la pression (sim “guerre longue”)
	# => à J15 on passe typiquement > 0.7
	for day in range(1, 21):
		# Approx: chaque jour de guerre, support↓ et unrest↑
		dom.war_support = int(clampi(dom.war_support - 4, 0, 100))
		dom.unrest = int(clampi(dom.unrest + 4, 0, 100))

		var ctx := {
			"day": day,
			"faction_id": A,
			"domestic_state": dom,
			"budget_points": 10
		}

		# 1) plan action (gate intégré)
		var act: StringName = planner.plan_action(goal, ctx)
		actions_by_day[day] = act

		# 2) spawn offers : domestic + truce (comme en prod)
		DomesticOfferFactory.spawn_offer_if_needed(A, dom, day, pool, nb, economy, {"cooldown_days": 3})
		ArcTruceOfferFactory.spawn_truce_offer_if_needed(A, B, dom, day, pool, nb)

	# ---- Assertions ----

	# A) Il y a des raids avant J15 (sinon le test ne prouve rien)
	var raids_pre := 0
	for day in range(1, 15):
		if actions_by_day[day] == &"arc.raid":
			raids_pre += 1
	_assert(raids_pre >= 1, "should have at least one raid before day 15 (got %d)" % raids_pre)

	# B) Plus aucun raid à partir de J15
	for day in range(15, 21):
		_assert(actions_by_day[day] != &"arc.raid", "no raids expected from day 15 (day %d had %s)" % [day, String(actions_by_day[day])])

	# C) On a au moins une offre TRUCE à partir de J15
	var truce_offer_post := 0
	var domestic_offer_post := 0
	for inst in pool.offers:
		var sd := int(inst.started_on_day) if inst.has_property("started_on_day") else int(inst.context.get("day", 0))
		if sd < 15:
			continue
		if StringName(inst.context.get("arc_action_type", &"")) == &"arc.truce_talks":
			truce_offer_post += 1
		if bool(inst.context.get("is_domestic_offer", false)):
			domestic_offer_post += 1

	_assert(truce_offer_post >= 1, "expected at least one TRUCE offer from day 15+")
	_assert(domestic_offer_post >= 1, "expected at least one DOMESTIC offer from day 15+")

	# D) Bonus : pression bien élevée
	_assert(float(dom.pressure()) > 0.7, "pressure should end above 0.7 (got %.3f)" % float(dom.pressure()))


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

### Pourquoi ce test est utile
- Il valide **l’intégration** (gate → changement de comportement) sans dépendre de tout ton WorldSim.
- Il prouve le point clé : **sortie de guerre organique** (plus de raids) + **apparition d’outils de sortie** (TRUCE + domestic).

Si tu veux, prochaine brique logique : faire la même intégration testée **avec un vrai goal stack** (WAR → TRUCE forcé 7 jours → restore WAR si pressure retombe), pour vérifier la boucle complète “suspended_goal”.

Moi:
Ok
prochaine brique logique : faire la même intégration testée avec un vrai goal stack (WAR → TRUCE forcé 7 jours → restore WAR si pressure retombe), pour vérifier la boucle complète “suspended_goal”.

ChatGPT:
Voici un test d’intégration **avec un vrai goal stack** (via `suspended_goal`) qui vérifie :

- on part en `WAR`
- quand `pressure > 0.7` ⇒ goal forcé `TRUCE` et `suspended_goal` stocké
- après **7 jours** de TRUCE + baisse de pression (`pressure < 0.62`) ⇒ **restaure** le goal `WAR`
- et les actions repartent en `raid` (si budget OK)

---

## `tests/IntegrationGoalStackRestoreTest.gd`

```gdscript
extends Node
class_name IntegrationGoalStackRestoreTest

# --- Minimal domestic state ---
class FactionDomesticState:
	var stability: int = 60
	var war_support: int = 75
	var unrest: int = 10
	func pressure() -> float:
		return clampf(0.55*(1.0 - war_support/100.0) + 0.45*(unrest/100.0), 0.0, 1.0)

# --- Gate + restore helpers (use your real ones if available) ---
class DomesticPolicyGate:
	static func apply(faction_id: StringName, goal: Dictionary, ctx: Dictionary, domestic_state, params: Dictionary = {}) -> Dictionary:
		var p := float(domestic_state.pressure())
		var threshold := float(params.get("pressure_threshold", 0.7))
		if p < threshold:
			return goal

		if not goal.has("suspended_goal"):
			goal["suspended_goal"] = goal.duplicate(true)

		goal["type"] = &"TRUCE"
		goal["reason"] = &"DOMESTIC_PRESSURE"
		goal["until_day"] = int(ctx.get("day", 0)) + int(params.get("force_days", 7))

		var min_mult := float(params.get("min_offensive_budget_mult", 0.25))
		var mult := clampf(1.0 - 0.85*(p - threshold)/(1.0 - threshold), min_mult, 1.0)
		ctx["budget_mult_offensive"] = mult
		return goal

static func maybe_restore_suspended_goal(goal: Dictionary, ctx: Dictionary, domestic_state) -> Dictionary:
	if not goal.has("suspended_goal"):
		return goal
	var day := int(ctx.get("day", 0))
	var until := int(goal.get("until_day", 0))
	var p := float(domestic_state.pressure())
	if day >= until and p < 0.62:
		return goal["suspended_goal"]
	return goal


# --- Planner sim using goal stack ---
class PlannerSim:
	func _is_offensive(action: StringName) -> bool:
		return action == &"arc.raid"

	func _can_afford(action: StringName, base_cost: int, ctx: Dictionary) -> bool:
		var budget := int(ctx.get("budget_points", 0))
		var mult := float(ctx.get("budget_mult_offensive", 1.0))
		var cost := base_cost
		if _is_offensive(action):
			cost = int(ceil(float(base_cost) / max(0.01, mult)))
		return budget >= cost

	func plan_action(goal: Dictionary, ctx: Dictionary) -> StringName:
		# WAR => raid if can
		if StringName(goal.get("type", &"")) == &"WAR":
			return &"arc.raid" if _can_afford(&"arc.raid", 10, ctx) else &"arc.defend"
		# TRUCE => talks
		if StringName(goal.get("type", &"")) == &"TRUCE":
			return &"arc.truce_talks"
		return &"arc.idle"


func _ready() -> void:
	_test_goal_stack_war_to_truce_7_days_then_restore_war()
	print("\n✅ IntegrationGoalStackRestoreTest: OK\n")
	get_tree().quit()


func _test_goal_stack_war_to_truce_7_days_then_restore_war() -> void:
	var A := &"A"
	var B := &"B"

	var dom := FactionDomesticState.new()
	var planner := PlannerSim.new()

	var goal := {"type": &"WAR", "target_id": B}
	var actions_by_day: Dictionary = {}
	var goal_type_by_day: Dictionary = {}

	var saw_truce := false
	var saw_restore_war := false
	var first_truce_day := -1

	for day in range(1, 31):
		# --- simulate domestic dynamics ---
		# Phase 1: war fatigue rises until ~day 15
		if day <= 17:
			dom.war_support = int(clampi(dom.war_support - 4, 0, 100))
			dom.unrest = int(clampi(dom.unrest + 4, 0, 100))
		# Phase 2: after some days of truce + “domestic work”, pressure drops
		else:
			dom.war_support = int(clampi(dom.war_support + 5, 0, 100))
			dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

		var ctx := {"day": day, "faction_id": A, "domestic_state": dom, "budget_points": 10}

		# --- restore step (goal stack) ---
		goal = maybe_restore_suspended_goal(goal, ctx, dom)

		# --- apply gate (may force TRUCE and attach suspended_goal) ---
		goal = DomesticPolicyGate.apply(A, goal, ctx, dom, {
			"pressure_threshold": 0.7,
			"force_days": 7,
			"min_offensive_budget_mult": 0.25
		})

		goal_type_by_day[day] = StringName(goal.get("type", &""))
		var act: StringName = planner.plan_action(goal, ctx)
		actions_by_day[day] = act

		# record first TRUCE day
		if goal_type_by_day[day] == &"TRUCE" and not saw_truce:
			saw_truce = true
			first_truce_day = day

		# detect restore WAR after having had TRUCE
		if saw_truce and goal_type_by_day[day] == &"WAR":
			saw_restore_war = true

	# ---- Assertions ----
	_assert(saw_truce, "should enter TRUCE at least once due to pressure > 0.7")
	_assert(first_truce_day > 0, "first_truce_day should be set")

	# A) during forced TRUCE window, actions should be truce talks (not raids)
	var until_day := first_truce_day + 7
	for d in range(first_truce_day, min(until_day + 1, 31)):
		_assert(goal_type_by_day[d] == &"TRUCE", "goal should stay TRUCE during forced window (day %d)" % d)
		_assert(actions_by_day[d] == &"arc.truce_talks", "action should be truce talks during TRUCE (day %d)" % d)

	# B) after window + pressure drop, we restore WAR
	_assert(saw_restore_war, "should restore suspended WAR after forced TRUCE window if pressure drops")

	# C) after restore, raids can happen again (at least once) if budget allows
	var raids_after_restore := 0
	for d in range(until_day + 1, 31):
		if goal_type_by_day[d] == &"WAR" and actions_by_day[d] == &"arc.raid":
			raids_after_restore += 1
	_assert(raids_after_restore >= 1, "should see raids again after WAR restore (got %d)" % raids_after_restore)

	# D) pressure should end lower
	_assert(float(dom.pressure()) < 0.62, "pressure should end below restore threshold (got %.3f)" % float(dom.pressure()))


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

### Ce que ce test valide exactement
- `suspended_goal` est bien utilisé comme “stack”
- la trêve est **temporaire** (7 jours)
- la restauration se fait uniquement si la pression est redescendue (seuil 0.62)
- le simulateur redevient offensif une fois la contrainte levée

Si tu veux, prochaine brique logique : brancher ça *dans tes vraies classes* (`FactionGoalManagerRunner` + `FactionGoalPlanner`) avec un micro patch “non-invasif”, puis un test d’intégration qui utilise tes vrais runners (pas les classes de test).

Moi:
Ok 
prochaine brique logique : brancher ça dans tes vraies classes (FactionGoalManagerRunner + FactionGoalPlanner) avec un micro patch “non-invasif”, puis un test d’intégration qui utilise tes vrais runners (pas les classes de test).

ChatGPT:
Parfait — voilà un **micro-patch non invasif** (ctx optionnel + goal stack) dans tes **vraies classes** + un **test d’intégration** qui instancie **FactionGoalManagerRunner + FactionGoalPlanner** (pas de planner “fake”).

---

## 1) Micro-patch `FactionGoalManagerRunner.gd`

Objectif :
- garder le comportement actuel si `ctx` est vide
- si `ctx.domestic_state` est présent : **restore suspended_goal** puis **force TRUCE** si `pressure>0.7`

```gdscript
# FactionGoalManagerRunner.gd (extraits à intégrer)
# +++ AJOUTS MINIMAUX +++

# (optionnel) si tu as déjà un dict interne, garde le tien
var goals_by_faction: Dictionary = {} # faction_id -> Dictionary goal

func get_goal_state(faction_id: StringName) -> Dictionary:
	return goals_by_faction.get(faction_id, {})

func set_goal_state(faction_id: StringName, goal: Dictionary) -> void:
	goals_by_faction[faction_id] = goal


# MICRO PATCH : ctx optionnel (ne casse pas les appels existants)
func ensure_goal(faction_id: StringName, ctx: Dictionary = {}) -> Dictionary:
	# --- ton code existant pour assurer un goal ---
	# ex:
	# var goal := goals_by_faction.get(faction_id, {})
	# if goal.is_empty(): goal = _create_default_goal(faction_id)
	# ...
	var goal := get_goal_state(faction_id)
	if goal.is_empty():
		goal = {"type": &"IDLE"} # remplace par ton défaut

	# --- HOOK DOMESTIC PRESSURE (non invasif) ---
	var dom = ctx.get("domestic_state", null)
	if dom != null:
		# 1) restore (si TRUCE forcée passée et pressure basse)
		goal = DomesticPolicyGate.maybe_restore_suspended_goal(goal, ctx, dom)

		# 2) force TRUCE + budget_mult_offensive
		goal = DomesticPolicyGate.apply(faction_id, goal, ctx, dom, {
			"pressure_threshold": 0.7,
			"force_days": 7,
			"min_offensive_budget_mult": 0.25
		})

	set_goal_state(faction_id, goal)
	return goal
```

> Si ton runner a déjà une structure “goal instance”, adapte juste `get/set_goal_state` pour pointer vers ton stockage actuel.

---

## 2) Micro-patch `FactionGoalPlanner.gd`

Objectif :
- `plan_action(goal, ctx := {})` (ctx optionnel)
- appliquer l’**inflation de coût offensif** via `ctx["budget_mult_offensive"]`

```gdscript
# FactionGoalPlanner.gd (extraits à intégrer)

func plan_action(goal: Dictionary, ctx: Dictionary = {}) -> Variant:
	# (optionnel) safety : si ensure_goal n’est pas appelé, on garde le gate ici aussi
	var dom = ctx.get("domestic_state", null)
	if dom != null and StringName(goal.get("reason", &"")) != &"DOMESTIC_PRESSURE":
		goal = DomesticPolicyGate.apply(StringName(ctx.get("faction_id", &"")), goal, ctx, dom)

	# ... ton code existant de sélection d’action ...
	return _plan_action_core(goal, ctx)


# ---- hook coût (à appeler dans TON calcul de coût existant) ----
func _inflate_offensive_cost_if_needed(action_type: StringName, base_cost: int, ctx: Dictionary) -> int:
	var mult := float(ctx.get("budget_mult_offensive", 1.0))
	if mult >= 0.999:
		return base_cost
	if _is_offensive_action(action_type):
		return int(ceil(float(base_cost) / max(0.01, mult)))
	return base_cost

func _is_offensive_action(action_type: StringName) -> bool:
	return action_type in [&"arc.raid", &"arc.declare_war", &"arc.sabotage"]
```

> Tu l’utilises exactement là où tu fais ton `base_cost` (budget/jour, points/semaine, etc.) :
`cost = _inflate_offensive_cost_if_needed(action_type, cost, ctx)`.

---

## 3) Test d’intégration (vrais runners + goal stack)

Ce test :
- instancie / récupère `/root/FactionGoalManagerRunner` et `/root/FactionGoalPlanner`
- simule 30 jours :
  - J1–J17 : pression monte (support↓ unrest↑)
  - J18–J30 : pression baisse (support↑ unrest↓)
- vérifie : **WAR → TRUCE 7 jours → restore WAR**
- + vérifie “plus de raids pendant TRUCE”
- + vérifie “au moins 1 offer TRUCE + 1 offer domestic après J15” (via tes factories)

```gdscript
# tests/IntegrationRealRunnersGoalStackTest.gd
extends Node
class_name IntegrationRealRunnersGoalStackTest

class TestQuestPool:
	var offers: Array = []
	func try_add_offer(inst) -> bool:
		offers.append(inst)
		return true

class TestArcNotebook:
	var last_domestic := {}
	var last_truce := {}
	func can_spawn_domestic_offer(fid: StringName, day: int, cooldown: int) -> bool:
		return (day - int(last_domestic.get(fid, -999999))) >= cooldown
	func mark_domestic_offer_spawned(fid: StringName, day: int) -> void:
		last_domestic[fid] = day
	func can_spawn_truce_offer(a: StringName, b: StringName, day: int, cooldown: int) -> bool:
		var k := StringName(String(a) + "|" + String(b))
		return (day - int(last_truce.get(k, -999999))) >= cooldown
	func mark_truce_offer_spawned(a: StringName, b: StringName, day: int) -> void:
		var k := StringName(String(a) + "|" + String(b))
		last_truce[k] = day

# utilise ta vraie classe si elle existe déjà; sinon garde ce mini state
class FactionDomesticState:
	var stability: int = 60
	var war_support: int = 75
	var unrest: int = 10
	func pressure() -> float:
		return clampf(0.55*(1.0 - war_support/100.0) + 0.45*(unrest/100.0), 0.0, 1.0)

func _ready() -> void:
	_test_real_runners_goal_stack_restore()
	print("\n✅ IntegrationRealRunnersGoalStackTest: OK\n")
	get_tree().quit()

func _test_real_runners_goal_stack_restore() -> void:
	var A := &"A"
	var B := &"B"

	# --- récupérer ou instancier les vrais runners ---
	var runner = get_node_or_null("/root/FactionGoalManagerRunner")
	if runner == null:
		runner = FactionGoalManagerRunner.new()
		add_child(runner)

	var planner = get_node_or_null("/root/FactionGoalPlanner")
	if planner == null:
		planner = FactionGoalPlanner.new()
		add_child(planner)

	# --- init goal WAR ---
	runner.set_goal_state(A, {"type": &"WAR", "target_id": B})

	var dom := FactionDomesticState.new()
	var pool := TestQuestPool.new()
	var nb := TestArcNotebook.new()

	var first_truce_day := -1
	var until_day := -1
	var saw_restore_war := false
	var raids_after_restore := 0

	for day in range(1, 31):
		# domestic dynamics
		if day <= 17:
			dom.war_support = int(clampi(dom.war_support - 4, 0, 100))
			dom.unrest = int(clampi(dom.unrest + 4, 0, 100))
		else:
			dom.war_support = int(clampi(dom.war_support + 5, 0, 100))
			dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

		var ctx := {
			"day": day,
			"faction_id": A,
			"domestic_state": dom,
			"budget_points": 10
		}

		var goal := runner.ensure_goal(A, ctx)
		var goal_type: StringName = StringName(goal.get("type", &""))

		# action via vrai planner
		var act_v = planner.plan_action(goal, ctx)
		var action_type: StringName = act_v if act_v is StringName else StringName(act_v.get("type", &""))

		# offers (comme ta boucle monde le ferait)
		DomesticOfferFactory.spawn_offer_if_needed(A, dom, day, pool, nb, null, {"cooldown_days": 3})
		ArcTruceOfferFactory.spawn_truce_offer_if_needed(A, B, dom, day, pool, nb)

		if goal_type == &"TRUCE" and first_truce_day < 0:
			first_truce_day = day
			until_day = int(goal.get("until_day", day + 7))

		if first_truce_day > 0 and day >= first_truce_day and day <= until_day:
			_assert(goal_type == &"TRUCE", "goal must stay TRUCE during forced window (day %d)" % day)
			_assert(action_type == &"arc.truce_talks", "no raids during TRUCE (day %d had %s)" % [day, String(action_type)])

		if first_truce_day > 0 and day > until_day and goal_type == &"WAR":
			saw_restore_war = true
			if action_type == &"arc.raid":
				raids_after_restore += 1

	# --- asserts ---
	_assert(first_truce_day > 0, "should enter TRUCE at least once")
	_assert(saw_restore_war, "should restore WAR after TRUCE window when pressure drops")
	_assert(raids_after_restore >= 1, "should see raids again after restore (got %d)" % raids_after_restore)

	# offers post J15
	var truce_offers := 0
	var domestic_offers := 0
	for inst in pool.offers:
		if int(inst.started_on_day) < 15:
			continue
		if StringName(inst.context.get("arc_action_type", &"")) == &"arc.truce_talks":
			truce_offers += 1
		if bool(inst.context.get("is_domestic_offer", false)):
			domestic_offers += 1

	_assert(truce_offers >= 1, "expected >=1 TRUCE offer after day 15")
	_assert(domestic_offers >= 1, "expected >=1 DOMESTIC offer after day 15")

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

Si tu veux une version encore plus “100% vraie boucle monde”, je peux aussi te proposer un micro-patch `FactionGoalManagerRunner.tick_day(faction_id, ctx)` qui appelle `ensure_goal → plan_action → apply → spawn offers`, mais là on dépasse un peu le “non-invasif”.

Moi:
Ok pour
version encore plus “100% vraie boucle monde”, je peux aussi te proposer un micro-patch FactionGoalManagerRunner.tick_day(faction_id, ctx) qui appelle ensure_goal → plan_action → apply → spawn offers, mais là on dépasse un peu le “non-invasif”.

ChatGPT:
Voici une version **“100% vraie boucle monde”** avec un **micro-patch** `FactionGoalManagerRunner.tick_day(faction_id, ctx)` qui enchaîne :

`ensure_goal → planner.plan_action → apply_action → spawn_offers`

…tout en restant **non-invasif** : si tu ne l’appelles pas, rien ne change.

---

## 1) Micro-patch `FactionGoalManagerRunner.tick_day(...)`

```gdscript
# FactionGoalManagerRunner.gd
# +++ AJOUT NON INVASIF +++

# Dépendances injectables (pour test et prod)
@export var planner_path: NodePath = NodePath("/root/FactionGoalPlanner")
@export var quest_pool_path: NodePath = NodePath("/root/QuestPool")
@export var arc_notebook_path: NodePath = NodePath("/root/ArcManagerRunner") # ou ArcNotebook direct si tu l’as en singleton

# Optionnel : si tu as déjà un economy runner / faction registry
@export var economy_runner_path: NodePath = NodePath("")

func tick_day(faction_id: StringName, ctx: Dictionary = {}) -> Dictionary:
	# 0) Resolve deps (fallback soft)
	var planner = get_node_or_null(planner_path)
	var quest_pool = get_node_or_null(quest_pool_path)

	var arc_notebook = null
	var arc_mgr = get_node_or_null(arc_notebook_path)
	if arc_mgr != null and arc_mgr.has_variable("arc_notebook"):
		arc_notebook = arc_mgr.arc_notebook
	elif arc_mgr != null and arc_mgr.has_method("get_arc_notebook"):
		arc_notebook = arc_mgr.get_arc_notebook()

	var economy = null
	var econ_runner = (economy_runner_path != NodePath("")) ? get_node_or_null(economy_runner_path) : null
	if econ_runner != null and econ_runner.has_method("get_economy"):
		economy = econ_runner.get_economy(faction_id)

	# 1) Ensure goal (includes restore + domestic gate if ctx has domestic_state)
	ctx["faction_id"] = faction_id
	var goal := ensure_goal(faction_id, ctx)

	# 2) Plan action
	var action = null
	if planner != null and planner.has_method("plan_action"):
		action = planner.plan_action(goal, ctx)
	else:
		action = {"type": &"arc.idle"}

	var action_type: StringName = action if action is StringName else StringName(action.get("type", &"arc.idle"))

	# 3) Apply action (MVP no-op unless you already have apply methods)
	# Ici tu branches ton apply réel:
	# - decrement budget
	# - record event in ArcNotebook
	# - modify relations/tags/goals
	if has_method("_apply_planned_action"):
		_apply_planned_action(faction_id, action, ctx)
	elif arc_notebook != null and arc_notebook.has_method("record_faction_action"):
		arc_notebook.record_faction_action({
			"day": int(ctx.get("day", 0)),
			"faction_id": faction_id,
			"action": action_type
		})

	# 4) Spawn offers from domestic + (optionnel) truce push
	# Domestic offer (pressure/unrest)
	if ctx.has("domestic_state") and quest_pool != null:
		DomesticOfferFactory.spawn_offer_if_needed(
			faction_id,
			ctx["domestic_state"],
			int(ctx.get("day", 0)),
			quest_pool,
			arc_notebook,
			economy,
			{"cooldown_days": 3}
		)

	# TRUCE offer if pressure high (simple hook)
	if ctx.has("domestic_state") and quest_pool != null and goal.get("type", &"") == &"TRUCE":
		var target_id: StringName = StringName(goal.get("target_id", &""))
		if target_id != &"":
			ArcTruceOfferFactory.spawn_truce_offer_if_needed(
				faction_id,
				target_id,
				ctx["domestic_state"],
				int(ctx.get("day", 0)),
				quest_pool,
				arc_notebook
			)

	# 5) Return a summary (useful for tests/metrics)
	return {
		"goal": goal,
		"action": action,
		"action_type": action_type
	}
```

### Pourquoi c’est “non invasif”
- tu ajoutes une **nouvelle méthode**, tu ne modifies pas ton pipeline existant
- elle appelle des hooks “soft” (`_apply_planned_action` si tu l’as, sinon no-op + record)
- tu peux l’utiliser seulement dans le WorldSim, ou juste dans les tests

---

## 2) Test d’intégration “vraie boucle monde” (avec `tick_day`)

Ce test appelle `runner.tick_day(A, ctx)` sur 30 jours, comme une vraie boucle.

```gdscript
# tests/IntegrationRealWorldLoopTickDayTest.gd
extends Node
class_name IntegrationRealWorldLoopTickDayTest

class TestQuestPool:
	var offers: Array = []
	func try_add_offer(inst) -> bool:
		offers.append(inst)
		return true

class TestArcManagerRunner:
	var arc_notebook := TestArcNotebook.new()

class TestArcNotebook:
	var last_domestic := {}
	var last_truce := {}
	func can_spawn_domestic_offer(fid: StringName, day: int, cooldown: int) -> bool:
		return (day - int(last_domestic.get(fid, -999999))) >= cooldown
	func mark_domestic_offer_spawned(fid: StringName, day: int) -> void:
		last_domestic[fid] = day
	func can_spawn_truce_offer(a: StringName, b: StringName, day: int, cooldown: int) -> bool:
		var k := StringName(String(a) + "|" + String(b))
		return (day - int(last_truce.get(k, -999999))) >= cooldown
	func mark_truce_offer_spawned(a: StringName, b: StringName, day: int) -> void:
		var k := StringName(String(a) + "|" + String(b))
		last_truce[k] = day

class FactionDomesticState:
	var stability: int = 60
	var war_support: int = 75
	var unrest: int = 10
	func pressure() -> float:
		return clampf(0.55*(1.0 - war_support/100.0) + 0.45*(unrest/100.0), 0.0, 1.0)

func _ready() -> void:
	_test_tick_day_loop_goal_stack_and_offers()
	print("\n✅ IntegrationRealWorldLoopTickDayTest: OK\n")
	get_tree().quit()

func _test_tick_day_loop_goal_stack_and_offers() -> void:
	var A := &"A"
	var B := &"B"

	# Real runner + planner nodes
	var runner = get_node_or_null("/root/FactionGoalManagerRunner")
	if runner == null:
		runner = FactionGoalManagerRunner.new()
		runner.name = "FactionGoalManagerRunner"
		add_child(runner)

	var planner = get_node_or_null("/root/FactionGoalPlanner")
	if planner == null:
		planner = FactionGoalPlanner.new()
		planner.name = "FactionGoalPlanner"
		add_child(planner)

	# Inject test QuestPool + ArcManagerRunner (to provide arc_notebook)
	var qp = TestQuestPool.new()
	var qp_node := Node.new()
	qp_node.name = "QuestPool"
	# expose try_add_offer
	qp_node.set_script(qp.get_script()) # if your test pool is a script, else skip
	# simpler: just add as child and access directly below
	add_child(qp_node)

	var arc_runner := TestArcManagerRunner.new()
	var arc_node := Node.new()
	arc_node.name = "ArcManagerRunner"
	arc_node.set_script(arc_runner.get_script())
	add_child(arc_node)

	# Directly set paths to our test nodes (safer than default /root paths)
	runner.planner_path = planner.get_path()
	runner.quest_pool_path = qp_node.get_path()
	runner.arc_notebook_path = arc_node.get_path()

	# Init goal WAR
	runner.set_goal_state(A, {"type": &"WAR", "target_id": B})

	var dom := FactionDomesticState.new()
	var first_truce_day := -1
	var until_day := -1
	var saw_restore_war := false

	# We'll log action types
	var actions: Dictionary = {}

	for day in range(1, 31):
		# domestic dynamics
		if day <= 17:
			dom.war_support = int(clampi(dom.war_support - 4, 0, 100))
			dom.unrest = int(clampi(dom.unrest + 4, 0, 100))
		else:
			dom.war_support = int(clampi(dom.war_support + 5, 0, 100))
			dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

		var ctx := {"day": day, "domestic_state": dom}
		var out: Dictionary = runner.tick_day(A, ctx)

		var goal: Dictionary = out["goal"]
		var gt: StringName = StringName(goal.get("type", &""))
		var at: StringName = StringName(out.get("action_type", &""))
		actions[day] = at

		if gt == &"TRUCE" and first_truce_day < 0:
			first_truce_day = day
			until_day = int(goal.get("until_day", day + 7))

		if first_truce_day > 0 and day > until_day and gt == &"WAR":
			saw_restore_war = true

	# Assertions: no raids during truce window
	_assert(first_truce_day > 0, "should enter TRUCE at least once")
	for d in range(first_truce_day, min(until_day + 1, 31)):
		_assert(actions[d] != &"arc.raid", "no raids during forced TRUCE (day %d had raid)" % d)

	_assert(saw_restore_war, "should restore WAR after TRUCE if pressure drops")

	# Offers check: this depends on your QuestPool wiring; if qp_node isn't truly a pool, validate via factories separately.
	# If you wire a real QuestPool node, assert at least one domestic and one truce offer exist post day 15.

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

### Petite note pratique sur le test
Le test ci-dessus montre le principe “tick_day réel”, mais **le wiring d’un faux QuestPool comme Node** est pénible en GDScript pur si tu n’as pas une interface stable (script attaché, etc.).

👉 La version la plus propre (et 100% “real”) est :
- soit tu utilises ton **vrai QuestPool autoload** et tu le reset en début de test,
- soit tu ajoutes un champ optionnel `quest_pool_override` dans `ctx` (non invasif) pour injecter un stub **sans bidouiller NodePath**.

Si tu veux, je te donne le micro-patch minimal :  
`var quest_pool = ctx.get("quest_pool_override", get_node_or_null(quest_pool_path))`  
…et le test devient trivial et *vraiment* intégration “tick_day” + pool.

Tu préfères quel style : **utiliser tes autoloads réels** (reset propre), ou **override via ctx** (plus simple et stable pour tests) ?

Moi:
utiliser tes autoloads réels

ChatGPT:
Parfait — si on veut **utiliser les autoloads réels**, la clé c’est : **(1) un tick_day qui va chercher /root/**, et **(2) un test qui “snapshoote + reset” proprement** l’état des singletons qu’il touche, puis restaure à la fin.

Je te donne ci-dessous :

1) un `tick_day(...)` version autoloads (pas d’injection)  
2) un **test d’intégration** “20–30 jours WAR → pression → TRUCE → restore” qui **utilise tes vrais autoloads** et qui nettoie l’état avant/après.

---

## 1) `FactionGoalManagerRunner.tick_day()` version autoloads réels

```gdscript
# FactionGoalManagerRunner.gd
# +++ AJOUT NON INVASIF +++

func tick_day(faction_id: StringName, ctx: Dictionary = {}) -> Dictionary:
	ctx["faction_id"] = faction_id
	var day := int(ctx.get("day", 0))

	# Autoloads attendus
	var planner = get_node_or_null("/root/FactionGoalPlanner")
	if planner == null:
		planner = get_node_or_null("/root/FactionGoalPlannerRunner") # fallback si tu as renommé

	# Ton “pool d’offres” peut s’appeler différemment selon ton projet.
	# On cherche un autoload qui a try_add_offer(inst).
	var offer_sink: Node = null
	for n in ["QuestPool", "QuestOfferSimRunner", "QuestOfferPool", "QuestOffers"]:
		var cand = get_node_or_null("/root/" + n)
		if cand != null and cand.has_method("try_add_offer"):
			offer_sink = cand
			break

	# ArcNotebook si dispo (pour cooldown/refresh/debug)
	var arc_mgr = get_node_or_null("/root/ArcManagerRunner")
	var arc_notebook = null
	if arc_mgr != null:
		if arc_mgr.has_variable("arc_notebook"):
			arc_notebook = arc_mgr.arc_notebook
		elif arc_mgr.has_method("get_arc_notebook"):
			arc_notebook = arc_mgr.get_arc_notebook()

	# 1) ensure_goal (ton code existant)
	var goal: Dictionary = ensure_goal(faction_id, ctx)

	# 2) plan_action
	var action: Dictionary = {"type": &"arc.idle"}
	if planner != null and planner.has_method("plan_action"):
		action = planner.plan_action(goal, ctx)
	var action_type: StringName = StringName(action.get("type", &"arc.idle"))

	# 3) apply (si tu as déjà un apply, sinon record minimal)
	if has_method("_apply_planned_action"):
		_apply_planned_action(faction_id, action, ctx)
	elif arc_notebook != null and arc_notebook.has_method("record_faction_action"):
		arc_notebook.record_faction_action({
			"day": day,
			"faction_id": faction_id,
			"action": action_type
		})

	# 4) spawn offers (domestic + truce) si les factories existent
	if offer_sink != null:
		if ctx.has("domestic_state") and ClassDB.class_exists("DomesticOfferFactory"):
			DomesticOfferFactory.spawn_offer_if_needed(
				faction_id, ctx["domestic_state"], day,
				offer_sink, arc_notebook
			)

		if goal.get("type", &"") == &"TRUCE":
			var target_id: StringName = StringName(goal.get("target_id", &""))
			if target_id != &"" and ClassDB.class_exists("ArcTruceOfferFactory"):
				ArcTruceOfferFactory.spawn_truce_offer_if_needed(
					faction_id, target_id,
					ctx.get("domestic_state", null),
					day, offer_sink, arc_notebook
				)

	return {
		"day": day,
		"goal": goal,
		"action": action,
		"action_type": action_type
	}
```

---

## 2) Test d’intégration avec **autoloads réels** (snapshot + reset + restore)

> Objectif : simuler 30 jours, faire monter la pression (>0.7), vérifier qu’on force TRUCE (7 jours), qu’on **arrête les offensives** pendant TRUCE, puis qu’on **restore** WAR quand la pression retombe.

```gdscript
# tests/Integration_WarPressureGate_Autoloads.gd
extends Node
class_name Integration_WarPressureGate_Autoloads

class DomesticState:
	var war_support := 75
	var unrest := 10
	func pressure() -> float:
		# même formule que ce qu’on a discuté : simple, stable
		return clampf(0.55 * (1.0 - war_support / 100.0) + 0.45 * (unrest / 100.0), 0.0, 1.0)

func _ready() -> void:
	_test_world_loop_uses_real_autoloads()
	print("\n✅ Integration_WarPressureGate_Autoloads: OK\n")
	get_tree().quit()

func _test_world_loop_uses_real_autoloads() -> void:
	var runner = get_node_or_null("/root/FactionGoalManagerRunner")
	_assert(runner != null, "Missing autoload /root/FactionGoalManagerRunner")

	# Offer sink réel (celui qui a try_add_offer)
	var offer_sink: Node = null
	for n in ["QuestPool", "QuestOfferSimRunner", "QuestOfferPool", "QuestOffers"]:
		var cand = get_node_or_null("/root/" + n)
		if cand != null and cand.has_method("try_add_offer"):
			offer_sink = cand
			break
	_assert(offer_sink != null, "No offer sink autoload found (need try_add_offer)")

	var world = get_node_or_null("/root/WorldGameState") # si tu l’as
	var A := &"A"
	var B := &"B"

	# --- SNAPSHOT minimal ---
	var snap := {}

	# World day
	if world != null and world.has_variable("current_day"):
		snap["prev_day"] = int(world.current_day)

	# Offers
	snap["offers_prev"] = _snapshot_offers(offer_sink)
	_clear_offers(offer_sink)

	# Goal state A (on snapshot ce qu’on peut)
	snap["goal_prev"] = _snapshot_goal_state(runner, A)
	_set_goal_state(runner, A, {"type": &"WAR", "target_id": B})

	# --- Simulation ---
	var dom := DomesticState.new()

	var first_truce_day := -1
	var truce_until := -1
	var saw_restore_war := false

	var offensive_actions_during_truce := 0

	for day in range(1, 31):
		# Pilote la pression :
		# J1..J17 -> pression monte (support↓, unrest↑)
		# J18..J30 -> pression baisse (support↑, unrest↓)
		if day <= 17:
			dom.war_support = int(clampi(dom.war_support - 4, 0, 100))
			dom.unrest = int(clampi(dom.unrest + 4, 0, 100))
		else:
			dom.war_support = int(clampi(dom.war_support + 5, 0, 100))
			dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

		if world != null and world.has_variable("current_day"):
			world.current_day = day

		var out: Dictionary = runner.tick_day(A, {"day": day, "domestic_state": dom})
		var goal: Dictionary = out.get("goal", {})
		var gt: StringName = StringName(goal.get("type", &""))
		var at: StringName = StringName(out.get("action_type", &"arc.idle"))

		# détecter entrée en TRUCE
		if gt == &"TRUCE" and first_truce_day < 0:
			first_truce_day = day
			truce_until = int(goal.get("until_day", day + 7))

		# compter offensives pendant TRUCE (liste simple, adapte si tu as d’autres types)
		if first_truce_day > 0 and day >= first_truce_day and day <= truce_until:
			if at in [&"arc.raid", &"arc.sabotage", &"arc.attack", &"arc.declare_war"]:
				offensive_actions_during_truce += 1

		# vérifier restore WAR après TRUCE
		if first_truce_day > 0 and day > truce_until and gt == &"WAR":
			saw_restore_war = true

	# --- Assertions ---
	_assert(first_truce_day > 0, "Should enter TRUCE at least once (pressure gate)")
	_assert(truce_until >= first_truce_day, "TRUCE until_day invalid")
	_assert(offensive_actions_during_truce == 0, "No offensive actions allowed during TRUCE window")
	_assert(saw_restore_war, "Should restore WAR after TRUCE when pressure drops")

	# Offers spawned check (simple : au moins 1 offer en période de pression haute)
	var offers_after = _snapshot_offers(offer_sink)
	_assert(offers_after.size() >= 1, "Expected at least 1 offer spawned during loop")

	# --- RESTORE ---
	_restore_goal_state(runner, A, snap["goal_prev"])
	_restore_offers(offer_sink, snap["offers_prev"])
	if world != null and snap.has("prev_day"):
		world.current_day = snap["prev_day"]

func _snapshot_offers(offer_sink: Node) -> Array:
	# essaye plusieurs layouts
	if offer_sink.has_variable("offers") and offer_sink.offers is Array:
		return offer_sink.offers.duplicate(true)
	if offer_sink.has_method("get_offers"):
		var arr = offer_sink.get_offers()
		return (arr is Array) ? arr.duplicate(true) : []
	return []

func _clear_offers(offer_sink: Node) -> void:
	if offer_sink.has_method("_test_clear_offers"):
		offer_sink._test_clear_offers()
		return
	if offer_sink.has_variable("offers") and offer_sink.offers is Array:
		offer_sink.offers.clear()

func _restore_offers(offer_sink: Node, prev: Array) -> void:
	_clear_offers(offer_sink)
	if offer_sink.has_variable("offers") and offer_sink.offers is Array:
		for o in prev:
			offer_sink.offers.append(o)

func _snapshot_goal_state(runner: Node, faction_id: StringName) -> Variant:
	if runner.has_method("get_goal_state"):
		return runner.get_goal_state(faction_id)
	if runner.has_variable("goals_by_faction"):
		return runner.goals_by_faction.get(faction_id, null)
	return null

func _set_goal_state(runner: Node, faction_id: StringName, goal: Dictionary) -> void:
	if runner.has_method("set_goal_state"):
		runner.set_goal_state(faction_id, goal)
		return
	if runner.has_variable("goals_by_faction"):
		runner.goals_by_faction[faction_id] = goal

func _restore_goal_state(runner: Node, faction_id: StringName, prev: Variant) -> void:
	if prev == null:
		# clear
		if runner.has_variable("goals_by_faction"):
			runner.goals_by_faction.erase(faction_id)
		return
	_set_goal_state(runner, faction_id, prev)

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

## Micro-patch recommandé (optionnel mais pratique) : `offer_sink._test_clear_offers()`

Dans ton autoload qui gère réellement les offers (celui qui a `try_add_offer`), ajoute juste :

```gdscript
func _test_clear_offers() -> void:
	if has_variable("offers") and offers is Array:
		offers.clear()
```

Ça évite les tests “fragiles” quand le stockage interne change.

---

Si tu me confirmes le **nom exact** de ton autoload “offers pool” (celui qui contient les `QuestInstance AVAILABLE`), je te donne une version du test qui vérifie aussi **le contenu du context** (ex: `arc_action_type`, `giver_faction_id`, `antagonist_faction_id`, `is_truce_offer`, etc.), pas seulement le comptage.

Moi:
QuestPool.gd

ChatGPT:
Parfait — si ton autoload s’appelle **`/root/QuestPool`** (script `QuestPool.gd`), on peut faire un test d’intégration **vraiment propre** en s’appuyant dessus directement, à condition d’avoir un mini “hook de test” pour **snapshot/clear/restore** des offers.

## 1) Micro-patch minimal dans `QuestPool.gd` (test-only helpers)

Ajoute ces méthodes (elles ne changent pas le gameplay, juste les tests) :

```gdscript
# QuestPool.gd

# Si ton conteneur d'offres ne s'appelle pas "offers", adapte ici.
# Dans ton résumé, c'est "offers disponibles (AVAILABLE)" => souvent `var offers: Array[QuestInstance]`.

func _test_snapshot_offers() -> Array:
	return offers.duplicate(true)

func _test_clear_offers() -> void:
	offers.clear()

func _test_restore_offers(prev: Array) -> void:
	offers.clear()
	for o in prev:
		offers.append(o)
```

---

## 2) Micro-patch `FactionGoalManagerRunner.tick_day()` (QuestPool direct)

Dans ton `tick_day`, remplace la détection multi-noms par **QuestPool direct** :

```gdscript
var quest_pool = get_node_or_null("/root/QuestPool")
# ...
if quest_pool != null and quest_pool.has_method("try_add_offer"):
	# spawn Domestic + Truce ici
```

(Le reste inchangé.)

---

## 3) Test d’intégration “autoloads réels” avec restore complet

### `tests/Integration_WarPressureGate_Autoloads_QuestPool.gd`

```gdscript
extends Node
class_name Integration_WarPressureGate_Autoloads_QuestPool

# Domestic state minimal compatible avec DomesticPolicyGate (pressure())
class DomesticState:
	var war_support := 75
	var unrest := 10
	func pressure() -> float:
		return clampf(0.55 * (1.0 - war_support / 100.0) + 0.45 * (unrest / 100.0), 0.0, 1.0)

func _ready() -> void:
	_test_real_autoload_loop_with_goal_stack_and_offers()
	print("\n✅ Integration_WarPressureGate_Autoloads_QuestPool: OK\n")
	get_tree().quit()

func _test_real_autoload_loop_with_goal_stack_and_offers() -> void:
	var runner = get_node_or_null("/root/FactionGoalManagerRunner")
	_assert(runner != null, "Missing autoload /root/FactionGoalManagerRunner")

	var planner = get_node_or_null("/root/FactionGoalPlanner")
	_assert(planner != null, "Missing autoload /root/FactionGoalPlanner")

	var quest_pool = get_node_or_null("/root/QuestPool")
	_assert(quest_pool != null, "Missing autoload /root/QuestPool")
	_assert(quest_pool.has_method("try_add_offer"), "QuestPool must expose try_add_offer(inst)")

	# test helpers in QuestPool
	_assert(quest_pool.has_method("_test_snapshot_offers"), "QuestPool needs _test_snapshot_offers() for this test")
	_assert(quest_pool.has_method("_test_clear_offers"), "QuestPool needs _test_clear_offers() for this test")
	_assert(quest_pool.has_method("_test_restore_offers"), "QuestPool needs _test_restore_offers(prev) for this test")

	# goal state API in runner
	_assert(runner.has_method("get_goal_state") and runner.has_method("set_goal_state"),
		"FactionGoalManagerRunner must expose get_goal_state/set_goal_state for clean restore")

	var A := &"A"
	var B := &"B"

	# ---------------- SNAPSHOT & RESET ----------------
	var prev_offers: Array = quest_pool._test_snapshot_offers()
	quest_pool._test_clear_offers()

	var prev_goal = runner.get_goal_state(A)
	runner.set_goal_state(A, {"type": &"WAR", "target_id": B})

	# ---------------- SIM LOOP ----------------
	var dom := DomesticState.new()

	var first_truce_day := -1
	var truce_until := -1
	var saw_restore_war := false

	var raids_pre_15 := 0
	var raids_during_truce := 0

	for day in range(1, 31):
		# pression monte jusqu'à ~J17, puis redescend franchement
		if day <= 17:
			dom.war_support = int(clampi(dom.war_support - 4, 0, 100))
			dom.unrest = int(clampi(dom.unrest + 4, 0, 100))
		else:
			dom.war_support = int(clampi(dom.war_support + 5, 0, 100))
			dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

		var out: Dictionary = runner.tick_day(A, {"day": day, "domestic_state": dom})
		var goal: Dictionary = out.get("goal", {})
		var gt: StringName = StringName(goal.get("type", &""))
		var at: StringName = StringName(out.get("action_type", &"arc.idle"))

		if day < 15 and at == &"arc.raid":
			raids_pre_15 += 1

		if gt == &"TRUCE" and first_truce_day < 0:
			first_truce_day = day
			truce_until = int(goal.get("until_day", day + 7))

		if first_truce_day > 0 and day >= first_truce_day and day <= truce_until:
			if at == &"arc.raid":
				raids_during_truce += 1

		if first_truce_day > 0 and day > truce_until and gt == &"WAR":
			saw_restore_war = true

	# ---------------- ASSERTIONS ----------------
	_assert(raids_pre_15 >= 1, "Expected at least one raid before day 15 (else test doesn't prove gating)")
	_assert(first_truce_day > 0, "Should enter TRUCE at least once (pressure gate)")
	_assert(raids_during_truce == 0, "No raids allowed during forced TRUCE window")
	_assert(saw_restore_war, "Should restore WAR after TRUCE window when pressure drops")

	# Offers spawned (post J15): au moins 1 domestic + 1 truce
	var offers_after: Array = quest_pool._test_snapshot_offers()

	var domestic_post := 0
	var truce_post := 0
	for inst in offers_after:
		# started_on_day existe dans ton modèle (sinon fallback context)
		var sd := 0
		if inst != null and inst.has_method("get"):
			# pas fiable; on préfère accès direct si champ
			pass
		if "started_on_day" in inst:
			sd = int(inst.started_on_day)
		else:
			sd = int(inst.context.get("started_on_day", inst.context.get("day", 0)))

		if sd < 15:
			continue

		if bool(inst.context.get("is_domestic_offer", false)):
			domestic_post += 1
		if StringName(inst.context.get("arc_action_type", &"")) == &"arc.truce_talks":
			truce_post += 1

	_assert(domestic_post >= 1, "Expected >= 1 DOMESTIC offer after day 15")
	_assert(truce_post >= 1, "Expected >= 1 TRUCE offer after day 15")

	# ---------------- RESTORE ----------------
	runner.set_goal_state(A, prev_goal)
	quest_pool._test_restore_offers(prev_offers)


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

### Ce test valide “en vrai”
- Le runner appelle bien `ensure_goal → planner → apply → spawn offers` via **ton `tick_day`**
- Le **gate domestic** force `TRUCE` + stocke `suspended_goal`
- Pendant la fenêtre de trêve, on **ne raid plus**
- Quand la pression retombe, on **restore WAR**
- Le vrai `QuestPool` reçoit bien des offers **domestic** + **truce**

---

Si tu veux, prochaine brique logique : je te fais la même chose mais en vérifiant aussi le **contenu du context** des offers (tier, deadline, giver/antagonist, reason DOMESTIC_PRESSURE), pour garantir que le pipeline est strictement conforme à ta spec “data-driven”.

Moi:
Passons plutot sur
10) “Failure modes” intéressants
Aujourd’hui, un échec est souvent “rien”. Donne-lui une conséquence :
• LOYAL/NEUTRAL/TRAITOR + SUCCESS/FAILURE
• ex: médiation échoue → tension↑ mais trust envers C peut ↓ (“médiateur incompétent”).
Effet : tes quêtes nourrissent vraiment le monde.

ChatGPT:
Oui — si tu veux que tes quêtes “nourrissent vraiment le monde”, il faut que **l’issue** ne soit pas juste *LOYAL/NEUTRAL/TRAITOR*, mais **(choice × outcome)** :

- `choice ∈ {LOYAL, NEUTRAL, TRAITOR}`
- `outcome ∈ {SUCCESS, FAILURE}` (et plus tard tu pourras ajouter `PARTIAL` / `CRITICAL`)

L’idée simple : **un échec doit déplacer des métriques**, mais pas forcément “dans le sens escalade pure” : il peut **réduire la confiance**, **augmenter la fatigue**, **déclencher des rumeurs**, **créer des offres de réparation**… et donc générer des sorties de crise organiques.

---

## 1) Patch minimal data-driven

### A) Ajout d’un outcome dans la résolution
Dans `QuestManager.resolve_quest`, tu ajoutes un paramètre :

```gdscript
func resolve_quest(runtime_id: StringName, choice: StringName, outcome: StringName = &"SUCCESS") -> void:
	# outcome: SUCCESS / FAILURE
```

Et tu émets un signal plus riche :

```gdscript
signal quest_resolved(inst, choice, outcome)
```

### B) `QuestResolutionProfile` : 6 tableaux (simple à éditer en .tres)
Au lieu de 3 arrays, tu passes à 6 arrays :

```gdscript
# QuestResolutionProfile.gd
class_name QuestResolutionProfile
extends Resource

@export var id: StringName

@export var success_loyal_effects: Array[QuestEffect] = []
@export var success_neutral_effects: Array[QuestEffect] = []
@export var success_traitor_effects: Array[QuestEffect] = []

@export var failure_loyal_effects: Array[QuestEffect] = []
@export var failure_neutral_effects: Array[QuestEffect] = []
@export var failure_traitor_effects: Array[QuestEffect] = []
```

Puis dans le QuestManager :

```gdscript
func _get_effects(profile: QuestResolutionProfile, choice: StringName, outcome: StringName) -> Array:
	if outcome == &"SUCCESS":
		match choice:
			&"LOYAL": return profile.success_loyal_effects
			&"NEUTRAL": return profile.success_neutral_effects
			&"TRAITOR": return profile.success_traitor_effects
	else:
		match choice:
			&"LOYAL": return profile.failure_loyal_effects
			&"NEUTRAL": return profile.failure_neutral_effects
			&"TRAITOR": return profile.failure_traitor_effects
	return []
```

---

## 2) “Failure modes” intéressants : règles standard (par type d’offre)

Tu vas vite vouloir une table **action_type → deltas standard** (en plus du profil .tres), parce que toutes les quêtes n’auront pas un profil bespoke.

Je te propose un fallback très clair : une fonction `apply_failure_consequences(context, choice, outcome)` appelée **après** les effects du profile.

### Exemples concrets (Arc / Third party)

#### A) Médiation (3 factions) — ce que tu as demandé explicitement
Contexte :
- `A` ↔ `B` en conflit
- `C` médiateur

**SUCCESS / LOYAL**
- `A↔B`: tension -8, grievance -6, trust +2
- `A↔C`: trust +6, relation +3
- `B↔C`: trust +6, relation +3

**FAILURE / LOYAL**
- `A↔B`: tension +4 (négociations ratées), grievance +2
- `A↔C`: trust -3 (“médiateur incompétent”), relation -1
- `B↔C`: trust -3, relation -1

**FAILURE / TRAITOR**
- `A↔B`: tension +7, grievance +4
- `A→C`: trust -6 (C suspect)
- `B→C`: trust -6
- + rumeur “C a saboté” (si tu branches Knowledge)

Ça donne exactement le côté *“échec ≠ rien, mais ≠ escalade automatique”* : souvent ça fait **baisser la confiance** et **augmenter la fatigue**, ce qui pousse ensuite des offres “réparer / prouver / apaiser”.

#### B) Truce talks (2 factions)
**FAILURE**
- `A↔B`: tension +3 (frustration)
- `A↔B`: weariness +4 (ça use)
- `domestic(A)`: war_support -3 (si tu veux le lier)

=> Ça peut paradoxalement **faire descendre l’appétit de guerre** côté interne, donc tu crées une sortie.

#### C) Raid / sabotage
**FAILURE**
- `victim→attacker`: grievance +5, tension +3 (ils sont furieux)
- `attacker domestic`: war_support -2 / unrest +2 (humiliation / pertes)
- et/ou `attacker→victim trust` ne bouge pas (déjà bas), mais `weariness` monte.

=> Tu obtiens un système auto-stabilisant : les échecs offensifs font aussi **payer** l’attaquant (politique interne), donc il finit par chercher trêve / réparations.

---

## 3) Hooks minimalistes pour ArcNotebook

Le but : pouvoir mesurer “médiateur incompétent”, “soupçon”, “fail streak”.

### À chaque résolution :
```gdscript
if arc_notebook != null:
	arc_notebook.record_pair_event(day, giver, antagonist, action_type, choice, {
		"outcome": outcome,
		"runtime_id": inst.runtime_id
	})
```

Et pour la 3rd party :
```gdscript
arc_notebook.record_triplet_event(day, A, B, C, action_type, choice, {"outcome": outcome})
```

Même si tu ne l’exploites pas tout de suite, c’est précieux pour :
- limiter la variance (fail streak ⇒ plus de chances d’offres “repair”)
- générer des rumeurs
- faire du debug sur l’escalade

---

## 4) MVP code : appliquer des conséquences d’échec (Arc/Third party)

Voici une version compacte, “drop-in”, qui suppose que tu as déjà `FactionRelationScore` avec `relation/trust/tension/grievance/weariness`.

```gdscript
# ArcFailureConsequences.gd
class_name ArcFailureConsequences
extends RefCounted

static func apply(context: Dictionary, choice: StringName, outcome: StringName, relations: Dictionary, domestic_by_faction: Dictionary, arc_notebook = null, day: int = 0) -> void:
	var action_type: StringName = StringName(context.get("arc_action_type", context.get("tp_action", &"")))
	if action_type == &"": return

	var A: StringName = StringName(context.get("giver_faction_id", &""))
	var B: StringName = StringName(context.get("antagonist_faction_id", &""))
	var C: StringName = StringName(context.get("third_party_id", &""))

	# helpers
	var f = func(x): return x # (juste pour garder ça lisible)

	if action_type == &"tp.mediation":
		_apply_mediation(A, B, C, choice, outcome, relations)
	elif action_type == &"arc.truce_talks":
		_apply_truce(A, B, choice, outcome, relations, domestic_by_faction)
	elif action_type == &"arc.raid":
		_apply_raid(A, B, choice, outcome, relations, domestic_by_faction)
	# ... autres actions

	if arc_notebook != null and arc_notebook.has_method("record_pair_event"):
		arc_notebook.record_pair_event(day, A, B, action_type, choice, {"outcome": outcome})


static func _apply_mediation(A, B, C, choice, outcome, relations):
	if C == &"": return
	if outcome == &"SUCCESS":
		_rel(relations, A, B, "tension", -8); _rel(relations, B, A, "tension", -8)
		_rel(relations, A, B, "grievance", -6); _rel(relations, B, A, "grievance", -6)
		_rel(relations, A, C, "trust", +6); _rel(relations, C, A, "trust", +6)
		_rel(relations, B, C, "trust", +6); _rel(relations, C, B, "trust", +6)
	else:
		# échec = frustration + “médiateur incompétent”
		_rel(relations, A, B, "tension", +4); _rel(relations, B, A, "tension", +4)
		_rel(relations, A, B, "grievance", +2); _rel(relations, B, A, "grievance", +2)
		var t = -3 if choice != &"TRAITOR" else -6
		_rel(relations, A, C, "trust", t)
		_rel(relations, B, C, "trust", t)
		_rel(relations, C, A, "trust", t)
		_rel(relations, C, B, "trust", t)


static func _apply_truce(A, B, choice, outcome, relations, domestic_by_faction):
	if outcome == &"SUCCESS":
		_rel(relations, A, B, "tension", -10); _rel(relations, B, A, "tension", -10)
		_rel(relations, A, B, "weariness", -6); _rel(relations, B, A, "weariness", -6)
	else:
		_rel(relations, A, B, "tension", +3); _rel(relations, B, A, "tension", +3)
		_rel(relations, A, B, "weariness", +4); _rel(relations, B, A, "weariness", +4)
		# optionnel : la population se fatigue => support ↓
		if domestic_by_faction.has(A):
			domestic_by_faction[A].war_support = int(clampi(domestic_by_faction[A].war_support - 2, 0, 100))


static func _apply_raid(attacker, victim, choice, outcome, relations, domestic_by_faction):
	if outcome == &"SUCCESS":
		_rel(relations, victim, attacker, "grievance", +6)
		_rel(relations, victim, attacker, "tension", +4)
	else:
		# raid raté => le victim est furieux, mais l’attaquant paie aussi (fatigue interne)
		_rel(relations, victim, attacker, "grievance", +5)
		_rel(relations, victim, attacker, "tension", +3)
		_rel(relations, attacker, victim, "weariness", +3)
		if domestic_by_faction.has(attacker):
			domestic_by_faction[attacker].unrest = int(clampi(domestic_by_faction[attacker].unrest + 2, 0, 100))
			domestic_by_faction[attacker].war_support = int(clampi(domestic_by_faction[attacker].war_support - 2, 0, 100))


static func _rel(relations: Dictionary, a: StringName, b: StringName, field: String, delta: int) -> void:
	if a == &"" or b == &"": return
	if not relations.has(a) or not relations[a].has(b): return
	var r: FactionRelationScore = relations[a][b]
	match field:
		"relation": r.relation = int(clampi(r.relation + delta, -100, 100))
		"trust": r.trust = int(clampi(r.trust + delta, 0, 100))
		"tension": r.tension = int(clampi(r.tension + delta, 0, 100))
		"grievance": r.grievance = int(clampi(r.grievance + delta, 0, 100))
		"weariness": r.weariness = int(clampi(r.weariness + delta, 0, 100))
```

---

## 5) Ce que ça change tout de suite (gameplay)

- Tu as des quêtes “réelles” : même ratées, elles déplacent le monde.
- Tu obtiens des arcs qui **peuvent s’éteindre** :
  - l’échec monte `weariness` et baisse `war_support` ⇒ TRUCE/REPARATIONS
  - l’échec de médiation baisse la confiance envers le médiateur ⇒ quêtes “prove competence / investigate sabotage”
- Tu crées naturellement des branches narratives :
  - “médiateur incompétent” ⇒ rumeurs ⇒ 3 factions
  - raid raté ⇒ domestic unrest ⇒ quêtes internes

---

Si tu veux la prochaine brique logique : je te propose une mini-fonction **compute_outcome_success(inst, actor_profile, opposition, tier)** (pour déterminer SUCCESS/FAILURE de façon data-driven), + un test simple “médiation échoue ⇒ tension↑ et trust envers C↓”.

Moi:
Ok
prochaine brique logique : je te propose une mini-fonction compute_outcome_success(inst, actor_profile, opposition, tier) (pour déterminer SUCCESS/FAILURE de façon data-driven), + un test simple “médiation échoue ⇒ tension↑ et trust envers C↓”.
Penses bien qu'il peut y avoir 2 ou 3 participant

ChatGPT:
Voici une proposition **MVP “data-driven”** pour déterminer `SUCCESS/FAILURE`, compatible **2 ou 3 participants**, + un **mini test** “médiation échoue ⇒ tension↑ et trust envers C↓”.

---

## 1) `QuestOutcomeUtil.compute_outcome_success(...)`

- `actor_profile` peut être **un seul profil** (cas 2 factions) **ou** un **dictionnaire** `{faction_id: profile}` (cas 3 factions).
- `opposition` peut contenir `tension_mean/grievance_mean/friction` + (optionnel) `participants` pour pondérer la difficulté.
- Déterminisme : si `inst.context.roll` est fourni, c’est **100% déterministe**.

```gdscript
# QuestOutcomeUtil.gd
class_name QuestOutcomeUtil
extends RefCounted

static func compute_outcome_success(inst, actor_profile, opposition: Dictionary, tier: int, rng: RandomNumberGenerator = null) -> bool:
	var ctx: Dictionary = inst.context if inst != null and "context" in inst else {}
	var action_type: StringName = StringName(ctx.get("arc_action_type", ctx.get("tp_action", ctx.get("quest_type", &""))))

	# --- base chance from tier ---
	var p := 0.62 - 0.08 * float(max(0, tier - 1))  # tier 1 ~0.62, tier 5 ~0.30
	p = clampf(p, 0.05, 0.90)

	# --- conflict heat / friction (works for 2 or 3 factions) ---
	var tension := float(opposition.get("tension_mean", opposition.get("tension", 0.0))) / 100.0
	var grievance := float(opposition.get("grievance_mean", opposition.get("grievance", 0.0))) / 100.0
	var friction := float(opposition.get("friction", 0.0))          # 0..1 (si tu l’as)
	var heat := clampf(0.55 * tension + 0.35 * grievance + 0.30 * friction, 0.0, 1.0)

	# --- actor skill (2 or 3 participants) ---
	var skill := _compute_actor_skill(actor_profile, ctx, action_type) # 0..1

	# --- opposition resistance (optional) ---
	var opp := float(opposition.get("resistance", 0.5))               # 0..1
	var opp_participants := opposition.get("participants", null)
	if opp_participants is Dictionary:
		opp = clampf(0.5 + 0.35 * float(opp_participants.size() - 1), 0.5, 0.95)

	# --- action-specific shaping ---
	match action_type:
		&"tp.mediation":
			# médiation = très sensible à la heat
			p += 0.40 * (skill - 0.5)
			p -= 0.55 * heat
			p -= 0.20 * (opp - 0.5)
		&"arc.truce_talks":
			p += 0.25 * (skill - 0.5)
			p -= 0.40 * heat
			p -= 0.15 * (opp - 0.5)
		&"arc.raid", &"arc.sabotage":
			p += 0.30 * (skill - 0.5)
			p -= 0.25 * heat
			p -= 0.25 * (opp - 0.5)
		_:
			p += 0.25 * (skill - 0.5)
			p -= 0.30 * heat
			p -= 0.15 * (opp - 0.5)

	p = clampf(p, 0.05, 0.95)

	# --- deterministic roll support ---
	var roll := float(ctx.get("roll", -1.0))
	if roll < 0.0:
		if rng != null:
			roll = rng.randf()
		else:
			# fallback deterministic-ish (not ideal but stable): hash(day+runtime_id)
			var seed := int(ctx.get("day", 0)) * 73856093 ^ int(hash(String(ctx.get("runtime_id", ""))))
			var local_rng := RandomNumberGenerator.new()
			local_rng.seed = seed
			roll = local_rng.randf()

	# store for debug/metrics
	ctx["last_success_chance"] = p
	ctx["last_roll"] = roll
	inst.context = ctx if inst != null and "context" in inst else ctx

	return roll < p


static func _compute_actor_skill(actor_profile, ctx: Dictionary, action_type: StringName) -> float:
	# actor_profile can be:
	# - a single profile (has get_personality)
	# - a Dictionary {faction_id: profile}
	# - a Dictionary {"profile": ..., "profiles": ...} (if you want later)
	var actor_id: StringName = StringName(ctx.get("actor_faction_id", ctx.get("giver_faction_id", &"")))
	var prof = actor_profile
	if actor_profile is Dictionary and actor_profile.has(actor_id):
		prof = actor_profile[actor_id]

	# choose key weights by action
	var dip := _p(prof, &"diplomacy", 0.5)
	var hon := _p(prof, &"honor", 0.5)
	var cun := _p(prof, &"cunning", 0.5)
	var opp := _p(prof, &"opportunism", 0.5)
	var agr := _p(prof, &"aggression", 0.5)
	var dis := _p(prof, &"discipline", 0.5)

	match action_type:
		&"tp.mediation", &"arc.truce_talks":
			# bon médiateur = dip/honor/discipline, mauvais = opportunism/aggression
			return clampf(0.40*dip + 0.25*hon + 0.20*dis + 0.10*cun - 0.20*opp - 0.15*agr, 0.0, 1.0)
		&"arc.raid", &"arc.sabotage":
			return clampf(0.40*cun + 0.25*dis + 0.15*agr - 0.10*hon - 0.05*dip, 0.0, 1.0)
		_:
			return clampf(0.25*dip + 0.20*dis + 0.20*cun + 0.10*hon - 0.10*opp, 0.0, 1.0)


static func _p(profile, key: StringName, default_val: float) -> float:
	if profile == null:
		return default_val
	if profile.has_method("get_personality"):
		return float(profile.get_personality(key, default_val))
	if profile is Dictionary:
		# accept either {"personality":{...}} or direct keys
		if profile.has("personality"):
			return float(profile["personality"].get(key, default_val))
		return float(profile.get(key, default_val))
	return default_val
```

### Comment gérer 3 participants ?
- Dans `context`, mets :
  - `giver_faction_id` = C (médiateur)
  - `antagonist_faction_id` = A (ou B)
  - `third_party_id` = B (l’autre)
- Et dans `opposition` passe `tension_mean/grievance_mean` entre A et B (ou la moyenne A↔B).

---

## 2) Mini test : “médiation échoue ⇒ tension↑ et trust envers C↓”

Ce test :
- fabrique un “inst” minimal (juste `context`)
- force un `roll = 0.95` pour garantir `FAILURE`
- applique tes conséquences d’échec via `ArcFailureConsequences.apply(...)`
- vérifie :
  - `tension(A↔B)` augmente
  - `trust(A→C)` baisse (et idem B→C si tu veux)

```gdscript
# tests/MediationFailureConsequencesTest.gd
extends Node
class_name MediationFailureConsequencesTest

# fallback minimal if your real class isn't available
class TestRelationScore:
	var relation := 0
	var trust := 50
	var tension := 10
	var grievance := 10
	var weariness := 0

# minimal inst
class TestInst:
	var context := {}

func _ready() -> void:
	_test_mediation_failure_increases_tension_and_decreases_trust_to_mediator()
	print("\n✅ MediationFailureConsequencesTest: OK\n")
	get_tree().quit()

func _test_mediation_failure_increases_tension_and_decreases_trust_to_mediator() -> void:
	var A := &"A"
	var B := &"B"
	var C := &"C" # mediator

	# relations dict: relations[x][y] = score
	var relations := {}
	relations[A] = {}
	relations[B] = {}
	relations[C] = {}

	var ScoreClass = FactionRelationScore if ClassDB.class_exists("FactionRelationScore") else TestRelationScore

	relations[A][B] = ScoreClass.new()
	relations[B][A] = ScoreClass.new()
	relations[A][C] = ScoreClass.new()
	relations[B][C] = ScoreClass.new()
	relations[C][A] = ScoreClass.new()
	relations[C][B] = ScoreClass.new()

	# baseline
	relations[A][B].tension = 70
	relations[B][A].tension = 70
	relations[A][C].trust = 50
	relations[B][C].trust = 50

	# create mediation quest context (3 participants)
	var inst := TestInst.new()
	inst.context = {
		"tp_action": &"tp.mediation",
		"giver_faction_id": C,        # mediator "actor"
		"antagonist_faction_id": A,
		"third_party_id": B,
		"actor_faction_id": C,
		"roll": 0.95                  # force failure with low p
	}

	# mediator profile: mediocre diplomacy => low success chance
	var mediator_profile := {"personality": {&"diplomacy": 0.2, &"honor": 0.4, &"discipline": 0.4, &"opportunism": 0.6, &"aggression": 0.4}}

	# opposition: high heat between A and B
	var opposition := {"tension_mean": 85, "grievance_mean": 70, "friction": 0.3, "resistance": 0.7}

	var success := QuestOutcomeUtil.compute_outcome_success(inst, mediator_profile, opposition, 3, null)
	_assert(not success, "precondition: mediation should FAIL in this setup (chance=%.3f roll=%.3f)" % [float(inst.context.get("last_success_chance", 0.0)), float(inst.context.get("last_roll", 0.0))])

	var tension_before := relations[A][B].tension
	var trust_a_c_before := relations[A][C].trust

	# apply failure consequences (LOYAL attempt but failure)
	ArcFailureConsequences.apply(inst.context, &"LOYAL", &"FAILURE", relations, {}, null, 10)

	_assert(relations[A][B].tension > tension_before, "tension(A→B) should increase after failed mediation (before=%d after=%d)" % [tension_before, relations[A][B].tension])
	_assert(relations[A][C].trust < trust_a_c_before, "trust(A→C) should decrease after failed mediation (before=%d after=%d)" % [trust_a_c_before, relations[A][C].trust])

	# optional extra: B also distrusts mediator
	_assert(relations[B][C].trust < 50, "trust(B→C) should also decrease after failed mediation (after=%d)" % relations[B][C].trust)

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

### Petit détail important (2 vs 3 participants)
- Pour **2 participants** (ex: `arc.truce_talks`) : pas besoin de `third_party_id`, et `opposition` peut être juste `{tension:…, grievance:…}`.
- Pour **3 participants** : `tp_action` + `third_party_id` suffit, et `opposition.tension_mean/grievance_mean` représente la “chaleur” du conflit A↔B.

Si tu veux, prochaine brique logique : brancher `compute_outcome_success()` directement dans `QuestManager.resolve_quest()` (en gardant un override manuel pour les quêtes “scriptées”), et loguer systématiquement `last_success_chance/last_roll` dans ArcNotebook pour debug/metrics.

Moi:
Ok
prochaine brique logique : brancher compute_outcome_success() directement dans QuestManager.resolve_quest() (en gardant un override manuel pour les quêtes “scriptées”), et loguer systématiquement last_success_chance/last_roll dans ArcNotebook pour debug/metrics.

ChatGPT:
OK — voilà un **patch concret** pour brancher `compute_outcome_success()` **dans `QuestManager.resolve_quest()`**, avec :

- **override manuel** (quêtes “scriptées” ou déterminées autrement)
- **2 ou 3 participants** (pair A↔B ou triplet avec médiateur)
- **logging systématique** `last_success_chance / last_roll` dans **ArcNotebook** (via `record_pair_event` + meta)

---

## 1) Patch `QuestManager.gd`

### A) Ajouter un nouveau signal (sans casser l’ancien)
Garde ton signal actuel `quest_resolved(inst, choice)` intact, et ajoute une V2 :

```gdscript
signal quest_resolved(inst, choice)
signal quest_resolved_v2(inst, choice, outcome, meta)
```

### B) Remplacer / étendre `resolve_quest(...)`

```gdscript
func resolve_quest(runtime_id: StringName, choice: StringName, outcome_override: StringName = &"") -> void:
	var inst: QuestInstance = active_quests.get(runtime_id, null)
	if inst == null:
		return

	var ctx: Dictionary = inst.context

	# -----------------------
	# 1) Outcome: override ou calcul
	# -----------------------
	var outcome: StringName = outcome_override

	# override via context (quêtes scriptées)
	if outcome == &"":
		outcome = StringName(ctx.get("outcome_override", &"")) # "SUCCESS"/"FAILURE"

	# si tu veux un flag ultra explicite
	if outcome == &"" and bool(ctx.get("is_scripted_quest", false)):
		outcome = StringName(ctx.get("scripted_outcome", &"")) # facultatif

	# auto-failure si l'instance est déjà FAILED/EXPIRED (si ça peut arriver ici)
	if outcome == &"" and String(inst.status) in ["FAILED", "EXPIRED"]:
		outcome = &"FAILURE"

	# compute outcome si toujours vide
	var meta := {}
	if outcome == &"":
		var tier := int(inst.template.tier) if inst.template != null else int(ctx.get("tier", 1))
		var day := _get_current_day(ctx)

		# participants (2 ou 3)
		var giver: StringName = StringName(ctx.get("giver_faction_id", &""))
		var antagonist: StringName = StringName(ctx.get("antagonist_faction_id", &""))
		var third: StringName = StringName(ctx.get("third_party_id", &""))

		var actor_id: StringName = StringName(ctx.get("actor_faction_id", giver))
		var actor_profile = _get_faction_profile(actor_id)

		# opposition: priorise ctx.opposition si fourni (pré-calculé par ArcManager/OfferFactory)
		var opposition: Dictionary = {}
		if ctx.has("opposition") and ctx["opposition"] is Dictionary:
			opposition = ctx["opposition"]
		else:
			opposition = _compute_opposition_from_relations(ctx, antagonist, third)

		# inject day/runtime_id pour seed debug si utile
		ctx["day"] = day
		ctx["runtime_id"] = StringName(inst.runtime_id)

		var success := QuestOutcomeUtil.compute_outcome_success(inst, actor_profile, opposition, tier, null)
		outcome = &"SUCCESS" if success else &"FAILURE"

		# meta debug
		meta["success_chance"] = float(ctx.get("last_success_chance", 0.0))
		meta["roll"] = float(ctx.get("last_roll", 0.0))
		meta["tier"] = tier
		meta["day"] = day
		meta["actor_id"] = actor_id
		meta["opposition"] = opposition

	# persiste dans le context (hyper utile pour replay/debug)
	ctx["outcome"] = outcome
	inst.context = ctx

	# -----------------------
	# 2) Apply profile effects (SUCCESS/FAILURE + choice)
	# -----------------------
	var profile_id: StringName = StringName(ctx.get("resolution_profile_id", &""))
	var profile = _get_resolution_profile(profile_id) # ton registry actuel

	var effects: Array = _get_effects_compat(profile, choice, outcome)
	_apply_effects(inst, effects)

	# -----------------------
	# 3) Apply systemic consequences (Arc / third party / domestic)
	# -----------------------
	# (relations/domestic accessibles par autoloads, comme tu fais déjà pour d’autres systèmes)
	var relations = _get_relations_store()
	var domestic_by_faction = _get_domestic_store()
	var arc_notebook = _get_arc_notebook()

	if relations != null:
		ArcFailureConsequences.apply(ctx, choice, outcome, relations, domestic_by_faction, arc_notebook, int(meta.get("day", _get_current_day(ctx))))

	# -----------------------
	# 4) Finalize + signals + log ArcNotebook
	# -----------------------
	inst.status = "COMPLETED" if outcome == &"SUCCESS" else "FAILED"
	active_quests.erase(runtime_id)

	# ancien signal (compat)
	emit_signal("quest_resolved", inst, choice)
	# nouveau signal riche
	emit_signal("quest_resolved_v2", inst, choice, outcome, meta)

	# log notebook (pair ou triplet)
	_log_resolution_in_notebook(inst, choice, outcome, meta, arc_notebook)
```

### C) Helpers “soft” (non-invasifs)

```gdscript
func _get_current_day(ctx: Dictionary) -> int:
	if ctx.has("day"):
		return int(ctx["day"])
	var world = get_node_or_null("/root/WorldGameState")
	if world != null and world.has_variable("current_day"):
		return int(world.current_day)
	return 0


func _get_arc_notebook():
	var arc_mgr = get_node_or_null("/root/ArcManagerRunner")
	if arc_mgr == null:
		return null
	if arc_mgr.has_variable("arc_notebook"):
		return arc_mgr.arc_notebook
	if arc_mgr.has_method("get_arc_notebook"):
		return arc_mgr.get_arc_notebook()
	return null


func _get_faction_profile(faction_id: StringName):
	# adapte aux noms réels (runner/registry)
	var fr = get_node_or_null("/root/FactionProfileRunner")
	if fr != null:
		if fr.has_method("get_profile"):
			return fr.get_profile(faction_id)
		if fr.has_method("get_faction_profile"):
			return fr.get_faction_profile(faction_id)
	# fallback neutre
	return {"personality": {&"diplomacy": 0.5, &"honor": 0.5, &"discipline": 0.5, &"opportunism": 0.5, &"aggression": 0.5}}


func _compute_opposition_from_relations(ctx: Dictionary, a: StringName, b: StringName) -> Dictionary:
	# pour 2 factions (a=antagonist, b=third_party ou giver selon action)
	# pour médiation: antagoniste = A, third_party = B => heat sur A↔B
	var rel = _get_relations_store()
	if rel == null or a == &"" or b == &"":
		return {"tension_mean": 50, "grievance_mean": 50, "friction": 0.2, "resistance": 0.6}

	if not rel.has(a) or not rel[a].has(b) or not rel.has(b) or not rel[b].has(a):
		return {"tension_mean": 50, "grievance_mean": 50, "friction": 0.2, "resistance": 0.6}

	var ab = rel[a][b]
	var ba = rel[b][a]
	var tmean := 0.5 * (float(ab.tension) + float(ba.tension))
	var gmean := 0.5 * (float(ab.grievance) + float(ba.grievance))
	var fric := float(ctx.get("friction", 0.2))
	var res := clampf(0.45 + 0.005 * tmean + 0.005 * gmean, 0.45, 0.90)

	return {"tension_mean": tmean, "grievance_mean": gmean, "friction": fric, "resistance": res}


func _get_relations_store():
	# adapte au stockage réel (faction -> dict -> FactionRelationScore)
	var rm = get_node_or_null("/root/FactionRelationsRunner")
	if rm != null and rm.has_variable("relations_by_faction"):
		return rm.relations_by_faction
	if rm != null and rm.has_method("get_relations_store"):
		return rm.get_relations_store()
	return null


func _get_domestic_store():
	var dm = get_node_or_null("/root/DomesticPressureRunner")
	if dm != null and dm.has_variable("domestic_by_faction"):
		return dm.domestic_by_faction
	return {}
```

### D) Effects compat (ancien profil 3 arrays + nouveau 6 arrays)

```gdscript
func _get_effects_compat(profile, choice: StringName, outcome: StringName) -> Array:
	if profile == null:
		return []

	# Nouveau format (6 arrays)
	if "success_loyal_effects" in profile:
		if outcome == &"SUCCESS":
			match choice:
				&"LOYAL": return profile.success_loyal_effects
				&"NEUTRAL": return profile.success_neutral_effects
				&"TRAITOR": return profile.success_traitor_effects
		else:
			match choice:
				&"LOYAL": return profile.failure_loyal_effects
				&"NEUTRAL": return profile.failure_neutral_effects
				&"TRAITOR": return profile.failure_traitor_effects

	# Ancien format (3 arrays) => on les considère comme SUCCESS, et FAILURE => [] (compensé par ArcFailureConsequences)
	if "loyal_effects" in profile:
		match choice:
			&"LOYAL": return profile.loyal_effects
			&"NEUTRAL": return profile.neutral_effects
			&"TRAITOR": return profile.traitor_effects

	return []
```

### E) Logging ArcNotebook (chance/roll systématiques)

```gdscript
func _log_resolution_in_notebook(inst: QuestInstance, choice: StringName, outcome: StringName, meta: Dictionary, arc_notebook) -> void:
	if arc_notebook == null:
		return

	var ctx := inst.context
	var day := int(meta.get("day", _get_current_day(ctx)))
	var giver: StringName = StringName(ctx.get("giver_faction_id", &""))
	var ant: StringName = StringName(ctx.get("antagonist_faction_id", &""))
	var third: StringName = StringName(ctx.get("third_party_id", &""))

	var action_type: StringName = StringName(ctx.get("arc_action_type", ctx.get("tp_action", &"quest")))
	var payload := {
		"outcome": outcome,
		"chance": float(ctx.get("last_success_chance", meta.get("success_chance", 0.0))),
		"roll": float(ctx.get("last_roll", meta.get("roll", 0.0))),
		"runtime_id": StringName(inst.runtime_id),
		"tier": int(meta.get("tier", ctx.get("tier", 1)))
	}

	if third != &"" and arc_notebook.has_method("record_triplet_event"):
		arc_notebook.record_triplet_event(day, ant, third, giver, action_type, choice, payload) # (A,B,C)
	elif arc_notebook.has_method("record_pair_event"):
		arc_notebook.record_pair_event(day, giver, ant, action_type, choice, payload)
```

---

## 2) Override “scripted quest” (simple et robuste)

Pour une quête scriptée, au moment de la création de l’instance (ou juste avant resolve), tu poses :

```gdscript
inst.context["is_scripted_quest"] = true
inst.context["outcome_override"] = &"SUCCESS"  # ou FAILURE
```

ou alors tu appelles directement :

```gdscript
QuestManager.resolve_quest(runtime_id, &"LOYAL", &"SUCCESS")
```

---

## 3) Important pour 2 vs 3 participants

- **2 factions** (ex: `arc.truce_talks`) : `giver_faction_id=A`, `antagonist_faction_id=B`, pas de `third_party_id`
- **3 factions** (ex: médiation) : `giver=C (médiateur)`, `antagonist=A`, `third_party=B`
  - l’**opposition/heat** est calculée sur **A↔B** (antagonist ↔ third_party), ce qui est exactement ce qu’on veut.

---

Si tu veux la brique suivante : je te donne un mini test d’intégration sur ton pipeline réel : *QuestManager.resolve_quest()* sur une médiation 3 factions, avec `roll` forcé, et assertion que `ArcNotebook` reçoit bien `chance/roll/outcome` + que les deltas tension/trust sont appliqués.

Moi:
Ok 
brique suivante : je te donne un mini test d’intégration sur ton pipeline réel : QuestManager.resolve_quest() sur une médiation 3 factions, avec roll forcé, et assertion que ArcNotebook reçoit bien chance/roll/outcome + que les deltas tension/trust sont appliqués.

ChatGPT:
Voici un **mini test d’intégration “pipeline réel”** qui :

- crée une **quête de médiation 3 factions** (A↔B, C médiateur)
- force un `roll` élevé pour garantir **FAILURE** via `compute_outcome_success()`
- appelle **`QuestManager.resolve_quest()`**
- assert :
  - **ArcNotebook** reçoit bien `outcome + chance + roll`
  - les **deltas** sont appliqués : `tension(A↔B)` ↑ et `trust(A→C)` ↓

> Le test **utilise tes autoloads réels** (QuestManager, ArcManagerRunner/ArcNotebook, FactionRelationsRunner si présent), mais **ne les casse pas** : il snapshot/restore ce qu’il remplace.

---

## `tests/Integration_QuestManager_Mediation3Factions_Test.gd`

```gdscript
extends Node
class_name Integration_QuestManager_Mediation3Factions_Test

# --- ArcNotebook stub (captures meta) ---
class StubArcNotebook:
	extends RefCounted
	var pair_events: Array = []
	var triplet_events: Array = []

	func record_pair_event(day: int, a: StringName, b: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
		pair_events.append({"day": day, "a": a, "b": b, "action": action, "choice": choice, "meta": meta})

	func record_triplet_event(day: int, a: StringName, b: StringName, c: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
		triplet_events.append({"day": day, "a": a, "b": b, "c": c, "action": action, "choice": choice, "meta": meta})


# --- Fallback relation score if your real one isn't in ClassDB ---
class TestRelationScore:
	extends RefCounted
	var relation: int = 0
	var trust: int = 50
	var tension: int = 0
	var grievance: int = 0
	var weariness: int = 0


func _ready() -> void:
	_test_resolve_quest_mediation_3f_roll_forced_logs_and_deltas()
	print("\n✅ Integration_QuestManager_Mediation3Factions_Test: OK\n")
	get_tree().quit()


func _test_resolve_quest_mediation_3f_roll_forced_logs_and_deltas() -> void:
	# --- preconditions ---
	_assert(ClassDB.class_exists("QuestOutcomeUtil"), "QuestOutcomeUtil must exist")
	_assert(ClassDB.class_exists("ArcFailureConsequences"), "ArcFailureConsequences must exist")
	_assert(ClassDB.class_exists("QuestInstance"), "QuestInstance must exist")
	_assert(ClassDB.class_exists("QuestTemplate"), "QuestTemplate must exist")

	# Find real QuestManager autoload
	var qm: Node = _find_first_root_node(["QuestManagerRunner", "QuestManager"])
	_assert(qm != null, "Missing /root QuestManagerRunner (or QuestManager)")

	# ArcManagerRunner (to host arc_notebook)
	var arc_mgr: Node = _find_first_root_node(["ArcManagerRunner"])
	_assert(arc_mgr != null, "Missing /root/ArcManagerRunner (needed for ArcNotebook logging)")

	# Relations runner (optional, but we need QuestManager to find relations store)
	var rel_runner: Node = _find_first_root_node(["FactionRelationsRunner"])
	var created_rel_runner := false
	if rel_runner == null:
		rel_runner = Node.new()
		rel_runner.name = "FactionRelationsRunner"
		# QuestManager helper earlier expects relations_by_faction variable
		rel_runner.set("relations_by_faction", {})
		get_tree().root.add_child(rel_runner)
		created_rel_runner = true

	# --- snapshot & patch ArcNotebook ---
	var prev_arc_notebook = null
	if arc_mgr.has_variable("arc_notebook"):
		prev_arc_notebook = arc_mgr.arc_notebook
	var notebook := StubArcNotebook.new()
	arc_mgr.arc_notebook = notebook

	# --- snapshot & patch relations store ---
	var prev_rel_store = null
	if rel_runner.has_variable("relations_by_faction"):
		prev_rel_store = rel_runner.relations_by_faction

	# Build relations for A,B,C
	var A := &"A"
	var B := &"B"
	var C := &"C" # mediator

	var ScoreClass = FactionRelationScore if ClassDB.class_exists("FactionRelationScore") else TestRelationScore
	var store := {}
	store[A] = {}
	store[B] = {}
	store[C] = {}

	store[A][B] = ScoreClass.new()
	store[B][A] = ScoreClass.new()
	store[A][C] = ScoreClass.new()
	store[B][C] = ScoreClass.new()
	store[C][A] = ScoreClass.new()
	store[C][B] = ScoreClass.new()

	# high heat A<->B + neutral trust to mediator
	store[A][B].tension = 80
	store[B][A].tension = 80
	store[A][B].grievance = 70
	store[B][A].grievance = 70
	store[A][C].trust = 50
	store[B][C].trust = 50
	store[C][A].trust = 50
	store[C][B].trust = 50

	rel_runner.relations_by_faction = store

	# --- create mediation QuestInstance and register as ACTIVE ---
	var template = QuestTemplate.new()
	template.id = &"tp.mediation"
	template.title = "Mediation"
	template.description = "Test mediation 3 factions"
	template.category = &"ARC"
	template.tier = 3
	template.expires_in_days = 7

	var inst = QuestInstance.new(template, {
		# 3 participants
		"tp_action": &"tp.mediation",
		"giver_faction_id": C,          # mediator is giver/actor
		"actor_faction_id": C,
		"antagonist_faction_id": A,
		"third_party_id": B,

		# make outcome deterministic and FAIL
		"roll": 0.95,

		# opposition precomputed so QuestManager doesn't need extra runners
		"opposition": {"tension_mean": 85, "grievance_mean": 75, "friction": 0.3, "resistance": 0.7},

		# day for notebook logging + seeding
		"day": 10,

		# ensure some profile exists (optional)
		"resolution_profile_id": &"default_simple"
	})
	inst.runtime_id = &"test_mediation_3f_001"
	inst.status = "ACTIVE"
	inst.started_on_day = 10
	inst.expires_on_day = 17

	# Add to QuestManager active list via real method if possible
	if qm.has_method("start_runtime_quest"):
		qm.start_runtime_quest(inst)
	else:
		# fallback: set active_quests directly
		_assert(qm.has_variable("active_quests"), "QuestManager must have active_quests or start_runtime_quest()")
		qm.active_quests[inst.runtime_id] = inst

	# --- capture before ---
	var tension_before := store[A][B].tension
	var trust_a_c_before := store[A][C].trust

	# --- act ---
	# LOYAL attempt but should fail due to roll
	qm.resolve_quest(inst.runtime_id, &"LOYAL")

	# --- assertions: deltas applied ---
	_assert(store[A][B].tension > tension_before, "tension(A→B) should increase after failed mediation (before=%d after=%d)" % [tension_before, store[A][B].tension])
	_assert(store[A][C].trust < trust_a_c_before, "trust(A→C) should decrease after failed mediation (before=%d after=%d)" % [trust_a_c_before, store[A][C].trust])

	# --- assertions: ArcNotebook logged chance/roll/outcome ---
	var found := false
	for e in notebook.triplet_events:
		if StringName(e.get("action", &"")) == &"tp.mediation":
			var meta: Dictionary = e.get("meta", {})
			_assert(StringName(meta.get("outcome", &"")) == &"FAILURE", "notebook meta.outcome should be FAILURE")
			_assert(meta.has("chance") and meta.has("roll"), "notebook meta should include chance + roll")
			_assert(float(meta["roll"]) == 0.95, "notebook roll should match forced roll (0.95)")
			_assert(float(meta["chance"]) < float(meta["roll"]), "chance should be < roll to justify failure (chance=%.3f roll=%.3f)" % [float(meta["chance"]), float(meta["roll"])])
			found = true
			break
	_assert(found, "expected a triplet_event for tp.mediation in ArcNotebook")

	# --- restore patched state ---
	arc_mgr.arc_notebook = prev_arc_notebook
	if prev_rel_store != null:
		rel_runner.relations_by_faction = prev_rel_store
	if created_rel_runner:
		rel_runner.queue_free()


func _find_first_root_node(names: Array) -> Node:
	for n in names:
		var node = get_node_or_null("/root/" + String(n))
		if node != null:
			return node
	return null


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

### Notes importantes
- Le test **ne force pas `outcome_override`**, donc il passe bien par `compute_outcome_success()` et loggue `last_success_chance/last_roll`.
- Pour garantir le FAIL, on met `roll = 0.95` + opposition “chaude”.
- Le log est attendu dans `record_triplet_event` (3 factions). Si ton implémentation ne fait que `record_pair_event`, dis-le et je te donne la variante (2 asserts sur pair_events).

Si tu veux la brique suivante : une variante “SUCCESS” (roll faible) qui vérifie l’inverse (tension↓, trust vers médiateur↑) + que la quête finit `COMPLETED` au lieu de `FAILED`.

Moi:
Ok
brique suivante : une variante “SUCCESS” (roll faible) qui vérifie l’inverse (tension↓, trust vers médiateur↑) + que la quête finit COMPLETED au lieu de FAILED.

ChatGPT:
Voici la **variante “SUCCESS”** (roll faible) du test d’intégration, qui vérifie :

- `outcome == SUCCESS`
- `tension(A↔B)` **baisse**
- `trust(A→C)` **augmente** (médiateur)
- la quête finit en **COMPLETED** (et pas FAILED)
- ArcNotebook reçoit bien `chance/roll/outcome`

---

## `tests/Integration_QuestManager_Mediation3Factions_Success_Test.gd`

```gdscript
extends Node
class_name Integration_QuestManager_Mediation3Factions_Success_Test

class StubArcNotebook:
	extends RefCounted
	var pair_events: Array = []
	var triplet_events: Array = []

	func record_pair_event(day: int, a: StringName, b: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
		pair_events.append({"day": day, "a": a, "b": b, "action": action, "choice": choice, "meta": meta})

	func record_triplet_event(day: int, a: StringName, b: StringName, c: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
		triplet_events.append({"day": day, "a": a, "b": b, "c": c, "action": action, "choice": choice, "meta": meta})

class TestRelationScore:
	extends RefCounted
	var relation: int = 0
	var trust: int = 50
	var tension: int = 0
	var grievance: int = 0
	var weariness: int = 0

func _ready() -> void:
	_test_resolve_quest_mediation_success_logs_and_inverse_deltas()
	print("\n✅ Integration_QuestManager_Mediation3Factions_Success_Test: OK\n")
	get_tree().quit()

func _test_resolve_quest_mediation_success_logs_and_inverse_deltas() -> void:
	_assert(ClassDB.class_exists("QuestOutcomeUtil"), "QuestOutcomeUtil must exist")
	_assert(ClassDB.class_exists("ArcFailureConsequences"), "ArcFailureConsequences must exist")
	_assert(ClassDB.class_exists("QuestInstance"), "QuestInstance must exist")
	_assert(ClassDB.class_exists("QuestTemplate"), "QuestTemplate must exist")

	var qm: Node = _find_first_root_node(["QuestManagerRunner", "QuestManager"])
	_assert(qm != null, "Missing /root QuestManagerRunner (or QuestManager)")

	var arc_mgr: Node = _find_first_root_node(["ArcManagerRunner"])
	_assert(arc_mgr != null, "Missing /root/ArcManagerRunner")

	var rel_runner: Node = _find_first_root_node(["FactionRelationsRunner"])
	var created_rel_runner := false
	if rel_runner == null:
		rel_runner = Node.new()
		rel_runner.name = "FactionRelationsRunner"
		rel_runner.set("relations_by_faction", {})
		get_tree().root.add_child(rel_runner)
		created_rel_runner = true

	# --- patch notebook ---
	var prev_arc_notebook = null
	if arc_mgr.has_variable("arc_notebook"):
		prev_arc_notebook = arc_mgr.arc_notebook
	var notebook := StubArcNotebook.new()
	arc_mgr.arc_notebook = notebook

	# --- relations store ---
	var prev_rel_store = null
	if rel_runner.has_variable("relations_by_faction"):
		prev_rel_store = rel_runner.relations_by_faction

	var A := &"A"
	var B := &"B"
	var C := &"C" # mediator

	var ScoreClass = FactionRelationScore if ClassDB.class_exists("FactionRelationScore") else TestRelationScore
	var store := {A: {}, B: {}, C: {}}

	store[A][B] = ScoreClass.new()
	store[B][A] = ScoreClass.new()
	store[A][C] = ScoreClass.new()
	store[B][C] = ScoreClass.new()
	store[C][A] = ScoreClass.new()
	store[C][B] = ScoreClass.new()

	# baseline: conflict moderate, mediator trust neutral
	store[A][B].tension = 45
	store[B][A].tension = 45
	store[A][B].grievance = 25
	store[B][A].grievance = 25
	store[A][C].trust = 50
	store[B][C].trust = 50
	store[C][A].trust = 50
	store[C][B].trust = 50

	rel_runner.relations_by_faction = store

	# --- quest instance mediation 3 factions ---
	var template = QuestTemplate.new()
	template.id = &"tp.mediation"
	template.title = "Mediation"
	template.description = "Test mediation SUCCESS"
	template.category = &"ARC"
	template.tier = 2
	template.expires_in_days = 7

	var inst = QuestInstance.new(template, {
		"tp_action": &"tp.mediation",
		"giver_faction_id": C,
		"actor_faction_id": C,
		"antagonist_faction_id": A,
		"third_party_id": B,

		# force success: roll small
		"roll": 0.02,

		# opposition mild => success chance should be > 0.02
		"opposition": {"tension_mean": 40, "grievance_mean": 20, "friction": 0.1, "resistance": 0.55},

		"day": 10,
		"resolution_profile_id": &"default_simple"
	})
	inst.runtime_id = &"test_mediation_3f_success_001"
	inst.status = "ACTIVE"
	inst.started_on_day = 10
	inst.expires_on_day = 17

	# add to active quests
	if qm.has_method("start_runtime_quest"):
		qm.start_runtime_quest(inst)
	else:
		_assert(qm.has_variable("active_quests"), "QuestManager must have active_quests or start_runtime_quest()")
		qm.active_quests[inst.runtime_id] = inst

	var tension_before := store[A][B].tension
	var trust_a_c_before := store[A][C].trust

	# --- act ---
	qm.resolve_quest(inst.runtime_id, &"LOYAL")

	# --- status should be COMPLETED (not FAILED) ---
	_assert(String(inst.status) == "COMPLETED", "quest status should be COMPLETED (got %s)" % String(inst.status))

	# optional: should be removed from active_quests
	if qm.has_variable("active_quests"):
		_assert(not qm.active_quests.has(inst.runtime_id), "quest should be removed from active_quests after resolve")

	# --- inverse deltas: tension down, trust to mediator up ---
	_assert(store[A][B].tension < tension_before, "tension(A→B) should decrease on successful mediation (before=%d after=%d)" % [tension_before, store[A][B].tension])
	_assert(store[A][C].trust > trust_a_c_before, "trust(A→C) should increase on successful mediation (before=%d after=%d)" % [trust_a_c_before, store[A][C].trust])

	# --- ArcNotebook meta: outcome/chance/roll ---
	var found := false
	for e in notebook.triplet_events:
		if StringName(e.get("action", &"")) == &"tp.mediation":
			var meta: Dictionary = e.get("meta", {})
			_assert(StringName(meta.get("outcome", &"")) == &"SUCCESS", "notebook meta.outcome should be SUCCESS")
			_assert(meta.has("chance") and meta.has("roll"), "notebook meta should include chance + roll")
			_assert(float(meta["roll"]) == 0.02, "notebook roll should match forced roll (0.02)")
			_assert(float(meta["chance"]) > float(meta["roll"]), "chance should be > roll to justify success (chance=%.3f roll=%.3f)" % [float(meta["chance"]), float(meta["roll"])])
			found = true
			break
	_assert(found, "expected a triplet_event for tp.mediation in ArcNotebook")

	# --- restore ---
	arc_mgr.arc_notebook = prev_arc_notebook
	if prev_rel_store != null:
		rel_runner.relations_by_faction = prev_rel_store
	if created_rel_runner:
		rel_runner.queue_free()

func _find_first_root_node(names: Array) -> Node:
	for n in names:
		var node = get_node_or_null("/root/" + String(n))
		if node != null:
			return node
	return null

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

Si dans ton code `status` est un **enum** au lieu d’une string, dis-moi le nom exact (ex: `QuestStatus.COMPLETED`) et je te donne l’assertion compatible.

Moi:
QuestCompletionStatus

ChatGPT:
Parfait — du coup on remplace **toutes les assertions “COMPLETED/FAILED”** (qui étaient en string ou en `QuestTypes.Status`) par **`QuestCompletionStatus`**.

Comme on ne sait pas encore si ton `QuestInstance` expose `status` **ou** `completion_status`, je te mets un micro-helper **zéro ambiguïté** (et qui évite les erreurs “property not found”) :

```gdscript
# test_helpers.gd (ou dans ta classe de test)
static func _has_prop(obj: Object, prop: String) -> bool:
	for p in obj.get_property_list():
		if p.name == prop:
			return true
	return false

static func _get_completion_status(inst: Object) -> int:
	# Supporte tes deux variantes sans casser le parse
	if _has_prop(inst, "completion_status"):
		return inst.get("completion_status")
	return inst.get("status")
```

Ensuite, dans tes tests d’intégration “FAILURE” / “SUCCESS”, tu remplaces les asserts par :

```gdscript
# Variante FAILURE
assert_eq(_get_completion_status(inst), QuestCompletionStatus.FAILED)

# Variante SUCCESS
assert_eq(_get_completion_status(inst), QuestCompletionStatus.COMPLETED)
```

Et si dans le test tu avais aussi une assertion “quest finit COMPLETED au lieu de FAILED”, tu remplaces pareil (et tu gardes tes asserts ArcNotebook/deltas inchangés).

Si tu veux être encore plus clean côté prod (dans `QuestManager.resolve_quest()`), tu peux aussi écrire le status comme ça (sans dépendre du nom du champ) :

```gdscript
func _set_completion_status(inst: Object, st: int) -> void:
	if inst == null: return
	for p in inst.get_property_list():
		if p.name == "completion_status":
			inst.set("completion_status", st)
			return
	if inst.get_property_list().any(func(pp): return pp.name == "status"):
		inst.set("status", st)
```

Et tu appelles `_set_completion_status(inst, QuestCompletionStatus.COMPLETED/FAILED)` au moment où tu détermines `SUCCESS/FAILURE`.

Si tu me confirmes juste **le nom exact du champ** (status vs completion_status), je peux te donner une version simplifiée sans helper.

Moi:
Je ne suis plus sur du nom du champ
Faisons :
9) Économie : inflation narrative & rareté
Tu as escrow/or/budget. Ajoute une règle “rare” :
• si une faction est pauvre → elle propose plus souvent des quêtes non-monnayées (faveurs, accès, traités, artefacts, influence).
• inversement, riche → paye plus, mais attire opportunistes.
Effet : le monde raconte l’économie, pas juste “gold ↑”.

ChatGPT:
OK — là tu ajoutes une couche “le monde **raconte** l’économie”, pas juste “gold ±”. Je te propose un MVP très intégrable à ton pipeline actuel (OfferFactory → QuestPool → resolve → deltas), avec une règle rareté/inflation narrative.

## 1) Nouveau concept léger : `FactionEconomyState` + “reward_style”
Tu as déjà l’or/budget. Ajoute 2–3 métriques dérivées (peu coûteuses) :

- `gold` (déjà)
- `liquidity` (0..1) : capacité à payer **maintenant** (ex: gold / (weekly_expenses+1))
- `prestige` (0..1) : capacité à “payer autrement” (accès, titres, traités)
- `wealth_level` (enum) : POOR / MODEST / RICH / OPULENT (dérivé de gold+income)

**Règle centrale :**
- **POOR** → probabilité forte de récompenses **non monétaires** (faveur, accès, traité, influence, artefact, info)
- **RICH** → gold↑, mais génère du “bruit opportuniste” (fraude, vol, chantage, mercenaires)

## 2) Un “RewardBundle” data-driven (dans `context`)
Tu n’as pas besoin d’une classe au début : un dictionnaire standardisé dans le `context` suffit.

```gdscript
# context["reward_bundle"]
{
  "gold": 0,
  "influence": 12,                 # monnaie politique interne
  "access": ["PORT_PASS", "LIBRARY"],# accès/permissions
  "treaty_clauses": ["OPEN_TRADE"], # concessions contractuelles
  "favor_debt": 1,                  # promesse future (IOU)
  "artifact_id": "",                # rare
  "intel_tags": ["RUMOR_X"]         # info/knowledge hooks
}
```

## 3) Fonction de sélection : pauvre → non-monnaie, riche → or (et risques)
### Reward style (simple, lisible)
```gdscript
func compute_reward_style(econ, tier: int) -> Dictionary:
	var rich := econ.wealth_level in [&"RICH", &"OPULENT"]
	var poor := econ.wealth_level == &"POOR" or econ.liquidity < 0.35

	# poids (peuvent être modifiés par personnalité/axes)
	var w_gold := 0.65 if rich else (0.15 if poor else 0.40)
	var w_non  := 1.0 - w_gold

	# “opportunists attracted” (sert pour arcs/rumeurs)
	var opportunism_heat := 0.10 + (0.35 if rich else 0.0) + 0.05 * tier
	return {"w_gold": w_gold, "w_non": w_non, "opportunism_heat": opportunism_heat}
```

### Construction du RewardBundle (MVP)
- Base reward selon tier
- Si pauvre : convertit gold en “valeurs narratives”
- Si riche : gold augmente, mais injecte un “opportunism flag”

```gdscript
func build_reward_bundle(faction_id, econ, tier: int, action_type: StringName, rng: RandomNumberGenerator) -> Dictionary:
	var style := compute_reward_style(econ, tier)
	var base_gold := int(round(25 * pow(1.35, tier - 1))) # ex: 25, 34, 46, 62, 84
	var bundle := {"gold": 0, "influence": 0, "access": [], "treaty_clauses": [], "favor_debt": 0, "artifact_id": "", "intel_tags": []}

	if rng.randf() < style.w_gold:
		# Pay gold (rich pays more)
		var mult := 1.0 + (0.30 if econ.wealth_level in [&"RICH", &"OPULENT"] else 0.0)
		bundle.gold = int(round(base_gold * mult))
	else:
		# Non-monetary menu
		var points := base_gold # “valeur” à répartir
		bundle.influence = int(round(points * 0.35))
		if rng.randf() < 0.5: bundle.access.append("ACCESS_" + String(action_type).to_upper())
		if rng.randf() < 0.35: bundle.treaty_clauses.append("OPEN_TRADE")
		if rng.randf() < 0.25: bundle.favor_debt += 1
		if rng.randf() < 0.15: bundle.intel_tags.append("RUMOR_LEAD") # hook knowledge
		# artifact très rare, gated
		if rng.randf() < 0.03 and econ.prestige > 0.6: bundle.artifact_id = "artifact_roll_me"

	return bundle
```

## 4) Résolution : appliquer “non-monnaie” comme effets monde/relations
Au resolve (SUCCESS/FAILURE), tu appliques :
- gold si présent
- sinon : `influence/access/clauses` → tags + traités + relations

Exemples d’effets narratifs (simples, puissants) :
- `favor_debt`: crée une **dette** côté giver → futur arc “repayment request” si non honorée
- `access`: débloque des **POI**/marchands/quêtes spéciales (“accès au port”, “archives”, “temple”)
- `treaty_clauses`: génère/renforce un **Treaty** (que tu avais commencé à modéliser)
- `influence`: augmente la capacité future à lever des troupes / calmer l’unrest / faire passer une trêve

## 5) Le “prix” des riches : opportunistes + fraude + banditisme
Quand `style.opportunism_heat` est élevé, tu ajoutes un **side-effect** au monde (pas forcément immédiat) :
- augmente la probabilité d’actions `tp.opportunism` / `arc.heist` / `forge_evidence`
- ou crée des offers “shakedown”, “embezzle”, “steal payroll”
- (optionnel) génère des rumeurs “rich convoy”, “tribute wagon”

Concrètement : dans ton `ArcNotebook`, record un flag :
```gdscript
ctx["opportunism_heat"] = style.opportunism_heat
```
Et dans ton tick (Arc/Coalition/Knowledge) : si heat>0.35, autorise 1 offer opportuniste/jour max autour de cette faction.

## 6) Rareté (la partie “rare”)
Sans sim complexe, tu peux rendre rare par **inventaire de concessions** :
- `econ.concession_tokens` (0..N) : quand pauvre offre “access/treaty”, ça consomme 1 token
- tokens se régénèrent lentement (1/10 jours) ou via goals (commerce, stabilité)
- si tokens à 0 → pauvre ne peut proposer que `favor_debt` / `intel` / petites récompenses

Ça empêche : “pauvre mais distribue 50 accès/traités”.

## 7) Où brancher ça chez toi
- **OfferFactory.spawn_offer_for_pair / DomesticOfferFactory / ThirdPartyOfferFactory**
  - construit `reward_bundle` selon économie du giver
  - stocke dans `context`
- **QuestManager.resolve_quest(...)**
  - après outcome/choice, applique `reward_bundle` (SUCCESS surtout, FAILURE peut aussi créer dette/rumor)

## 8) Mini règle UX (important)
Affiche au joueur des récompenses “non-gold” comme des **bénéfices concrets** :
- “Accès au Port (7 jours)”
- “Clause de libre-échange (Treaty)”
- “Faveur due : +1 (utilisable pour forcer une audience / aide)”
Sinon le joueur pense “récompense nulle”.

Si tu veux, prochaine brique : un mini test statistique (50 offers POOR vs RICH) qui assert que **POOR génère majoritairement non-gold** et **RICH majoritairement gold**, et qu’un flag `opportunism_heat` est bien plus haut chez RICH.

Moi:
Ok
prochaine brique : un mini test statistique (50 offers POOR vs RICH) qui assert que POOR génère majoritairement non-gold et RICH majoritairement gold, et qu’un flag opportunism_heat est bien plus haut chez RICH.

ChatGPT:
Voici un **mini test statistique déterministe** (50 offers POOR vs 50 offers RICH) qui vérifie :

- **POOR** → majoritairement **non-gold**
- **RICH** → majoritairement **gold**
- `opportunism_heat` est **nettement plus haut** chez RICH

Je te mets aussi la mini util `RewardEconomyUtil.gd` (si tu ne l’as pas encore). Le test utilise un RNG seedé ⇒ **pas flaky**.

---

## `RewardEconomyUtil.gd`

```gdscript
# RewardEconomyUtil.gd
class_name RewardEconomyUtil
extends RefCounted

static func compute_reward_style(econ: Dictionary, tier: int) -> Dictionary:
	var wealth: StringName = StringName(econ.get("wealth_level", &"MODEST"))
	var liquidity: float = float(econ.get("liquidity", 0.5))

	var rich := (wealth == &"RICH" or wealth == &"OPULENT")
	var poor := (wealth == &"POOR" or liquidity < 0.35)

	# Gold weight: poor -> low, rich -> high
	var w_gold := 0.78 if rich else (0.12 if poor else 0.42)
	var w_non := 1.0 - w_gold

	# “Riche attire opportunistes”
	var opportunism_heat := 0.10 + (0.35 if rich else 0.0) + 0.05 * float(tier)
	opportunism_heat = clampf(opportunism_heat, 0.0, 1.0)

	return {"w_gold": w_gold, "w_non": w_non, "opportunism_heat": opportunism_heat}


static func build_reward_bundle(econ: Dictionary, tier: int, action_type: StringName, rng: RandomNumberGenerator) -> Dictionary:
	var style := compute_reward_style(econ, tier)
	var base_gold := int(round(25.0 * pow(1.35, float(tier - 1)))) # 25,34,46,62,84...
	var bundle := {
		"gold": 0,
		"influence": 0,
		"access": [],
		"treaty_clauses": [],
		"favor_debt": 0,
		"artifact_id": "",
		"intel_tags": [],
		"opportunism_heat": float(style.opportunism_heat)
	}

	if rng.randf() < float(style.w_gold):
		var wealth: StringName = StringName(econ.get("wealth_level", &"MODEST"))
		var mult := 1.0 + (0.30 if (wealth == &"RICH" or wealth == &"OPULENT") else 0.0)
		bundle.gold = int(round(float(base_gold) * mult))
		return bundle

	# non-gold
	var points := base_gold
	bundle.influence = int(round(points * 0.35))

	if rng.randf() < 0.55:
		bundle.access.append("ACCESS_" + String(action_type).to_upper())

	if rng.randf() < 0.40:
		bundle.treaty_clauses.append("OPEN_TRADE")

	if rng.randf() < 0.30:
		bundle.favor_debt = 1

	if rng.randf() < 0.20:
		bundle.intel_tags.append("RUMOR_LEAD")

	# artefact très rare et gated par prestige
	var prestige: float = float(econ.get("prestige", 0.5))
	if rng.randf() < 0.03 and prestige > 0.6:
		bundle.artifact_id = "artifact_roll_me"

	return bundle


static func is_non_gold(bundle: Dictionary) -> bool:
	if int(bundle.get("gold", 0)) > 0:
		return false
	return (
		int(bundle.get("influence", 0)) > 0
		or int(bundle.get("favor_debt", 0)) > 0
		or String(bundle.get("artifact_id", "")) != ""
		or (bundle.get("access", []) as Array).size() > 0
		or (bundle.get("treaty_clauses", []) as Array).size() > 0
		or (bundle.get("intel_tags", []) as Array).size() > 0
	)
```

---

## Test : `tests/EconomyRewardStyleStatTest.gd`

```gdscript
extends Node
class_name EconomyRewardStyleStatTest

func _ready() -> void:
	_test_poor_vs_rich_reward_distribution_and_opportunism_heat()
	print("\n✅ EconomyRewardStyleStatTest: OK\n")
	get_tree().quit()

func _test_poor_vs_rich_reward_distribution_and_opportunism_heat() -> void:
	_assert(ClassDB.class_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

	var rng := RandomNumberGenerator.new()
	rng.seed = 13371337 # déterministe

	var tier := 3
	var action := &"arc.truce_talks"

	var econ_poor := {
		"wealth_level": &"POOR",
		"liquidity": 0.20,
		"prestige": 0.45
	}
	var econ_rich := {
		"wealth_level": &"RICH",
		"liquidity": 0.85,
		"prestige": 0.75
	}

	var poor_gold := 0
	var poor_non := 0
	var poor_heat_sum := 0.0

	for i in range(50):
		var b := RewardEconomyUtil.build_reward_bundle(econ_poor, tier, action, rng)
		poor_heat_sum += float(b.get("opportunism_heat", 0.0))
		if int(b.get("gold", 0)) > 0:
			poor_gold += 1
		elif RewardEconomyUtil.is_non_gold(b):
			poor_non += 1

	var rich_gold := 0
	var rich_non := 0
	var rich_heat_sum := 0.0

	for i in range(50):
		var b := RewardEconomyUtil.build_reward_bundle(econ_rich, tier, action, rng)
		rich_heat_sum += float(b.get("opportunism_heat", 0.0))
		if int(b.get("gold", 0)) > 0:
			rich_gold += 1
		elif RewardEconomyUtil.is_non_gold(b):
			rich_non += 1

	var poor_heat_avg := poor_heat_sum / 50.0
	var rich_heat_avg := rich_heat_sum / 50.0

	# --- asserts “statistiques” robustes ---
	# Poor: très majoritairement non-gold
	_assert(poor_non >= 32, "POOR should generate mostly non-gold (expected >=32/50, got %d) | gold=%d" % [poor_non, poor_gold])

	# Rich: très majoritairement gold
	_assert(rich_gold >= 32, "RICH should generate mostly gold (expected >=32/50, got %d) | non_gold=%d" % [rich_gold, rich_non])

	# Opportunism heat: rich >> poor
	_assert(rich_heat_avg > poor_heat_avg + 0.25,
		"opportunism_heat should be much higher for RICH (poor=%.3f rich=%.3f)" % [poor_heat_avg, rich_heat_avg])

	# sanity: heat ranges
	_assert(poor_heat_avg >= 0.0 and poor_heat_avg <= 1.0, "poor heat avg out of range")
	_assert(rich_heat_avg >= 0.0 and rich_heat_avg <= 1.0, "rich heat avg out of range")


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

Si tu veux la suite logique : je te propose un 2e test qui vérifie qu’en **mode pauvre**, la “valeur” totale attendue (influence+faveur+clauses) reste cohérente avec le tier (pour éviter une économie “pauvre mais trop généreuse”).

Moi:
Ok
propose un 2e test qui vérifie qu’en mode pauvre, la “valeur” totale attendue (influence+faveur+clauses) reste cohérente avec le tier (pour éviter une économie “pauvre mais trop généreuse”).

ChatGPT:
Voici un **2e test** (toujours déterministe) qui vérifie, pour une faction **POOR**, que la **valeur moyenne** des récompenses **non-gold** augmente avec le tier mais reste **bornée** (donc pas “pauvre mais trop généreuse”).

L’idée : définir une fonction “proxy de valeur” simple et stable :

- `influence` : 1 point = 1 valeur
- `favor_debt` : +20 (gros levier narratif)
- `OPEN_TRADE` (clause) : +12
- `ACCESS_*` : +8
- `intel_tags` : +6
- `artifact_id` : +60 (rare)

Puis on teste :
1) `avg_value(tier 5) > avg_value(tier 2)` (cohérence de progression)
2) `avg_value(tier t)` reste dans une enveloppe raisonnable, ex :
   - tier2: 10..55
   - tier3: 15..65
   - tier4: 20..80
   - tier5: 25..95

---

## `tests/PoorNonGoldValueCoherenceTest.gd`

```gdscript
extends Node
class_name PoorNonGoldValueCoherenceTest

func _ready() -> void:
	_test_poor_non_gold_value_scales_with_tier_but_is_bounded()
	print("\n✅ PoorNonGoldValueCoherenceTest: OK\n")
	get_tree().quit()

func _test_poor_non_gold_value_scales_with_tier_but_is_bounded() -> void:
	_assert(ClassDB.class_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

	var econ_poor := {
		"wealth_level": &"POOR",
		"liquidity": 0.18,
		"prestige": 0.50
	}

	var action := &"arc.truce_talks"
	var n := 80 # plus stable que 50, toujours rapide

	var avg2 := _avg_value_for_tier(econ_poor, 2, action, n, 20201)
	var avg3 := _avg_value_for_tier(econ_poor, 3, action, n, 20202)
	var avg4 := _avg_value_for_tier(econ_poor, 4, action, n, 20203)
	var avg5 := _avg_value_for_tier(econ_poor, 5, action, n, 20204)

	# 1) Croissance cohérente (pas forcément strictement monotone à 1e-6, mais tendance nette)
	_assert(avg5 > avg2 + 8.0, "expected avg non-gold value to increase with tier (avg2=%.1f avg5=%.1f)" % [avg2, avg5])

	# 2) Bornes anti “pauvre trop généreux”
	_assert(avg2 >= 10.0 and avg2 <= 55.0, "tier2 avg out of bounds (%.1f) expected [10..55]" % avg2)
	_assert(avg3 >= 15.0 and avg3 <= 65.0, "tier3 avg out of bounds (%.1f) expected [15..65]" % avg3)
	_assert(avg4 >= 20.0 and avg4 <= 80.0, "tier4 avg out of bounds (%.1f) expected [20..80]" % avg4)
	_assert(avg5 >= 25.0 and avg5 <= 95.0, "tier5 avg out of bounds (%.1f) expected [25..95]" % avg5)


func _avg_value_for_tier(econ: Dictionary, tier: int, action: StringName, n: int, seed: int) -> float:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed

	var total := 0.0
	var count := 0

	for i in range(n):
		var b := RewardEconomyUtil.build_reward_bundle(econ, tier, action, rng)

		# On mesure seulement le mode non-gold (c’est ce qu’on veut contrôler chez POOR)
		if int(b.get("gold", 0)) > 0:
			continue

		var v := _value_proxy(b)
		total += v
		count += 1

	# si jamais trop de gold (devrait être rare en POOR), on sécurise
	if count == 0:
		return 0.0
	return total / float(count)


func _value_proxy(bundle: Dictionary) -> float:
	var v := 0.0

	# influence
	v += float(int(bundle.get("influence", 0))) * 1.0

	# favor debt: très puissant narrativement
	v += float(int(bundle.get("favor_debt", 0))) * 20.0

	# clauses
	var clauses: Array = bundle.get("treaty_clauses", [])
	for c in clauses:
		if String(c) == "OPEN_TRADE":
			v += 12.0
		else:
			v += 10.0

	# access
	var access: Array = bundle.get("access", [])
	v += float(access.size()) * 8.0

	# intel
	var intel: Array = bundle.get("intel_tags", [])
	v += float(intel.size()) * 6.0

	# artifact: rare mais énorme
	if String(bundle.get("artifact_id", "")) != "":
		v += 60.0

	return v


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

### Pourquoi ce test est utile
- Il t’évite de “casser” l’économie narrative en retouchant un poids (favor/access/treaty).
- Il garantit que le tier garde du sens, même si la faction paye en “politique” plutôt qu’en or.

Si tu veux, prochaine brique logique : un test équivalent côté **RICH** qui vérifie que `gold` scale bien avec tier *mais* que la variance n’explose pas (inflation contrôlée).

Moi:
Ok
prochaine brique logique : un test équivalent côté RICH qui vérifie que gold scale bien avec tier mais que la variance n’explose pas (inflation contrôlée).

ChatGPT:
Voici un **test équivalent côté RICH** qui vérifie :

1) `avg_gold(tier5) > avg_gold(tier2)` (gold scale bien avec tier)  
2) la variance reste contrôlée : **coefficient de variation** `cv = std/mean` **< 0.6** (tu peux ajuster)  
3) bonus : la moyenne suit à peu près la formule attendue (sans être trop stricte)

> Test déterministe : RNG seedé, 120 tirages par tier.

---

## `tests/RichGoldScalingAndVarianceTest.gd`

```gdscript
extends Node
class_name RichGoldScalingAndVarianceTest

func _ready() -> void:
	_test_rich_gold_scales_with_tier_and_variance_is_controlled()
	print("\n✅ RichGoldScalingAndVarianceTest: OK\n")
	get_tree().quit()

func _test_rich_gold_scales_with_tier_and_variance_is_controlled() -> void:
	_assert(ClassDB.class_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

	var econ_rich := {
		"wealth_level": &"RICH",
		"liquidity": 0.90,
		"prestige": 0.80
	}

	var action := &"arc.raid"
	var n := 120

	var s2 := _gold_stats_for_tier(econ_rich, 2, action, n, 33002)
	var s3 := _gold_stats_for_tier(econ_rich, 3, action, n, 33003)
	var s4 := _gold_stats_for_tier(econ_rich, 4, action, n, 33004)
	var s5 := _gold_stats_for_tier(econ_rich, 5, action, n, 33005)

	# 1) scaling
	_assert(s5.mean > s2.mean + 25.0, "avg gold should increase with tier (t2=%.1f t5=%.1f)" % [s2.mean, s5.mean])
	_assert(s5.mean > s4.mean, "avg gold should be increasing (t4=%.1f t5=%.1f)" % [s4.mean, s5.mean])

	# 2) variance control via coefficient of variation
	# (0.6 is generous; if you want tighter economy, drop to 0.4)
	_assert(s2.cv < 0.6, "tier2 gold CV too high: %.3f (mean=%.1f std=%.1f)" % [s2.cv, s2.mean, s2.std])
	_assert(s3.cv < 0.6, "tier3 gold CV too high: %.3f (mean=%.1f std=%.1f)" % [s3.cv, s3.mean, s3.std])
	_assert(s4.cv < 0.6, "tier4 gold CV too high: %.3f (mean=%.1f std=%.1f)" % [s4.cv, s4.mean, s4.std])
	_assert(s5.cv < 0.6, "tier5 gold CV too high: %.3f (mean=%.1f std=%.1f)" % [s5.cv, s5.mean, s5.std])

	# 3) sanity bounds (avoid runaway inflation)
	# base_gold approx: tier2 ~34, tier5 ~84, rich mult ~1.3, plus selection probability.
	# We'll just enforce "not absurd"
	_assert(s2.mean >= 15.0 and s2.mean <= 80.0, "tier2 mean gold out of bounds (%.1f)" % s2.mean)
	_assert(s5.mean >= 35.0 and s5.mean <= 160.0, "tier5 mean gold out of bounds (%.1f)" % s5.mean)


class Stats:
	var mean: float
	var std: float
	var cv: float
	func _init(m: float, s: float) -> void:
		mean = m
		std = s
		cv = (s / m) if m > 0.0001 else 999.0


func _gold_stats_for_tier(econ: Dictionary, tier: int, action: StringName, n: int, seed: int) -> Stats:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed

	var xs: Array[float] = []
	xs.resize(0)

	for i in range(n):
		var b := RewardEconomyUtil.build_reward_bundle(econ, tier, action, rng)
		var g := float(int(b.get("gold", 0)))
		# For rich test, we include 0 gold outcomes too: it’s part of the "style".
		xs.append(g)

	var m := _mean(xs)
	var s := _std(xs, m)
	return Stats.new(m, s)


func _mean(xs: Array[float]) -> float:
	if xs.is_empty(): return 0.0
	var sum := 0.0
	for x in xs: sum += x
	return sum / float(xs.size())


func _std(xs: Array[float], mean: float) -> float:
	if xs.size() <= 1: return 0.0
	var acc := 0.0
	for x in xs:
		var d := x - mean
		acc += d * d
	return sqrt(acc / float(xs.size() - 1))


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

### Si ce test échoue (2 causes probables)
- ton `RewardEconomyUtil` donne trop souvent des “non-gold” même en RICH (w_gold trop bas)
- ou tu as ajouté des multiplicateurs aléatoires trop forts (variance trop élevée)

Dans ce cas, la correction la plus simple est :
- augmenter `w_gold` pour RICH (ex: 0.85)
- ou rendre le gold moins “spiky” (ex: `gold = round(base_gold * mult * lerp(0.9,1.1,rng.randf()))` au lieu de grosses variations)

Si tu veux, prochaine brique logique : lier la “variance” à la **personnalité** (ex: greedy/chaotic => variance↑, bureaucratic => variance↓), tout en gardant ce test vert grâce à des bornes.

Moi:
Ok
prochaine brique logique : lier la “variance” à la personnalité (ex: greedy/chaotic => variance↑, bureaucratic => variance↓), tout en gardant ce test vert grâce à des bornes.

ChatGPT:
OK — on peut lier la **variance du gold** à la **personnalité** sans casser tes tests en :

- gardant une variance **bornée** (ex: ±4% à ±22%)
- appliquant la variance **uniquement quand la récompense est en gold** (pas sur le choix gold vs non-gold)
- laissant un **comportement par défaut** (profil = null) “sage” → tes tests actuels restent verts

---

## 1) Patch `RewardEconomyUtil.gd` : variance pilotée par personnalité

Modifs :
- `build_reward_bundle(..., profile := null)` (param optionnel)
- ajoute `_gold_variance_amp(profile)` basé sur `opportunism/aggression/discipline/honor`
- applique un bruit multiplicatif `uniform[1-amp, 1+amp]` **symétrique** (moyenne stable)

```gdscript
# RewardEconomyUtil.gd
class_name RewardEconomyUtil
extends RefCounted

static func compute_reward_style(econ: Dictionary, tier: int) -> Dictionary:
	var wealth: StringName = StringName(econ.get("wealth_level", &"MODEST"))
	var liquidity: float = float(econ.get("liquidity", 0.5))

	var rich := (wealth == &"RICH" or wealth == &"OPULENT")
	var poor := (wealth == &"POOR" or liquidity < 0.35)

	var w_gold := 0.78 if rich else (0.12 if poor else 0.42)
	var w_non := 1.0 - w_gold

	var opportunism_heat := 0.10 + (0.35 if rich else 0.0) + 0.05 * float(tier)
	opportunism_heat = clampf(opportunism_heat, 0.0, 1.0)

	return {"w_gold": w_gold, "w_non": w_non, "opportunism_heat": opportunism_heat}


# ✅ NOUVEAU: profile optionnel
static func build_reward_bundle(econ: Dictionary, tier: int, action_type: StringName, rng: RandomNumberGenerator, profile := null) -> Dictionary:
	var style := compute_reward_style(econ, tier)
	var base_gold := int(round(25.0 * pow(1.35, float(tier - 1))))

	var bundle := {
		"gold": 0,
		"influence": 0,
		"access": [],
		"treaty_clauses": [],
		"favor_debt": 0,
		"artifact_id": "",
		"intel_tags": [],
		"opportunism_heat": float(style.opportunism_heat)
	}

	if rng.randf() < float(style.w_gold):
		var wealth: StringName = StringName(econ.get("wealth_level", &"MODEST"))
		var mult := 1.0 + (0.30 if (wealth == &"RICH" or wealth == &"OPULENT") else 0.0)

		# ✅ variance bornée par personnalité
		var amp := _gold_variance_amp(profile) # 0.04 .. 0.22
		var noise := rng.randf_range(1.0 - amp, 1.0 + amp)
		bundle.gold = int(round(float(base_gold) * mult * noise))

		# debug optionnel
		bundle["gold_var_amp"] = amp
		return bundle

	# non-gold
	var points := base_gold
	bundle.influence = int(round(points * 0.35))

	if rng.randf() < 0.55:
		bundle.access.append("ACCESS_" + String(action_type).to_upper())
	if rng.randf() < 0.40:
		bundle.treaty_clauses.append("OPEN_TRADE")
	if rng.randf() < 0.30:
		bundle.favor_debt = 1
	if rng.randf() < 0.20:
		bundle.intel_tags.append("RUMOR_LEAD")

	var prestige: float = float(econ.get("prestige", 0.5))
	if rng.randf() < 0.03 and prestige > 0.6:
		bundle.artifact_id = "artifact_roll_me"

	return bundle


static func is_non_gold(bundle: Dictionary) -> bool:
	if int(bundle.get("gold", 0)) > 0:
		return false
	return (
		int(bundle.get("influence", 0)) > 0
		or int(bundle.get("favor_debt", 0)) > 0
		or String(bundle.get("artifact_id", "")) != ""
		or (bundle.get("access", []) as Array).size() > 0
		or (bundle.get("treaty_clauses", []) as Array).size() > 0
		or (bundle.get("intel_tags", []) as Array).size() > 0
	)

# -----------------------
# ✅ Variance par personnalité
# -----------------------
static func _gold_variance_amp(profile) -> float:
	# mapping: greedy/chaotic => opp/aggr ↑ ; bureaucratic => discipline/honor ↑
	# profile attendu: FactionProfile ou Dictionary {"personality":{...}} ou dict direct
	var opp := _p(profile, &"opportunism", 0.5)
	var agr := _p(profile, &"aggression", 0.5)
	var dis := _p(profile, &"discipline", 0.5)
	var hon := _p(profile, &"honor", 0.5)

	# volatility 0..1 (bornée)
	var vol := 0.20 + 0.45*opp + 0.25*agr - 0.55*dis - 0.20*hon
	vol = clampf(vol, 0.0, 1.0)

	# amplitude finale bornée => garde l'inflation contrôlée + tests verts
	return lerp(0.04, 0.22, vol)


static func _p(profile, key: StringName, default_val: float) -> float:
	if profile == null:
		return default_val
	if profile.has_method("get_personality"):
		return float(profile.get_personality(key, default_val))
	if profile is Dictionary:
		if profile.has("personality"):
			return float(profile["personality"].get(key, default_val))
		return float(profile.get(key, default_val))
	return default_val
```

✅ **Tes tests existants restent verts** parce que :
- ils appellent `build_reward_bundle(..., rng)` sans profil ⇒ profil `null` ⇒ amp modérée (≈ 8–10% en pratique avec vol ~0.2–0.3)

---

## 2) Nouveau test : variance greedy/chaotic > bureaucratic (mais bornée)

Ce test compare la variance **sur les tirages où `gold>0`** (sinon le mix gold/non-gold pollue la mesure).

### `tests/RichGoldVarianceByPersonalityTest.gd`

```gdscript
extends Node
class_name RichGoldVarianceByPersonalityTest

func _ready() -> void:
	_test_rich_gold_variance_depends_on_personality_but_stays_bounded()
	print("\n✅ RichGoldVarianceByPersonalityTest: OK\n")
	get_tree().quit()

func _test_rich_gold_variance_depends_on_personality_but_stays_bounded() -> void:
	_assert(ClassDB.class_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

	var econ_rich := {"wealth_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}
	var tier := 4
	var action := &"arc.raid"
	var n := 220

	# “greedy/chaotic” => variance ↑
	var prof_chaos := {"personality": {&"opportunism": 0.90, &"aggression": 0.80, &"discipline": 0.20, &"honor": 0.20}}
	# “bureaucratic” => variance ↓
	var prof_bureau := {"personality": {&"opportunism": 0.20, &"aggression": 0.20, &"discipline": 0.90, &"honor": 0.70}}

	var s_chaos := _gold_stats_positive_only(econ_rich, tier, action, n, 77111, prof_chaos)
	var s_buro  := _gold_stats_positive_only(econ_rich, tier, action, n, 77112, prof_bureau)

	# variance chaotique > bureaucratique
	_assert(s_chaos.cv > s_buro.cv + 0.05,
		"expected higher CV for chaotic profile (chaos=%.3f buro=%.3f)" % [s_chaos.cv, s_buro.cv])

	# bornes “inflation contrôlée”
	_assert(s_chaos.cv < 0.25, "chaos CV too high: %.3f (mean=%.1f std=%.1f)" % [s_chaos.cv, s_chaos.mean, s_chaos.std])
	_assert(s_buro.cv  < 0.15, "buro CV too high: %.3f (mean=%.1f std=%.1f)" % [s_buro.cv, s_buro.mean, s_buro.std])

	# moyenne quasi inchangée (bruit symétrique)
	_assert(abs(s_chaos.mean - s_buro.mean) / max(1.0, s_buro.mean) < 0.12,
		"mean should stay roughly stable across personalities (chaos=%.1f buro=%.1f)" % [s_chaos.mean, s_buro.mean])


class Stats:
	var mean: float
	var std: float
	var cv: float
	func _init(m: float, s: float) -> void:
		mean = m
		std = s
		cv = (s / m) if m > 0.0001 else 999.0


func _gold_stats_positive_only(econ: Dictionary, tier: int, action: StringName, n: int, seed: int, profile) -> Stats:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed

	var xs: Array[float] = []
	for i in range(n):
		var b := RewardEconomyUtil.build_reward_bundle(econ, tier, action, rng, profile)
		var g := float(int(b.get("gold", 0)))
		if g > 0.0:
			xs.append(g)

	_assert(xs.size() >= int(0.5 * n), "too few gold samples; check w_gold for rich (got %d/%d)" % [xs.size(), n])

	var m := _mean(xs)
	var s := _std(xs, m)
	return Stats.new(m, s)


func _mean(xs: Array[float]) -> float:
	var sum := 0.0
	for x in xs: sum += x
	return sum / float(xs.size())

func _std(xs: Array[float], mean: float) -> float:
	var acc := 0.0
	for x in xs:
		var d := x - mean
		acc += d * d
	return sqrt(acc / float(xs.size() - 1))


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

## 3) Où le brancher “pour de vrai”
Dans ton `OfferFactory.spawn_offer_*` (ou là où tu construis `reward_bundle`) :

- récupère le **FactionProfile** du giver (ou acteur)
- appelle `RewardEconomyUtil.build_reward_bundle(econ, tier, action_type, rng, giver_profile)`

Ça donne immédiatement :
- factions chaotiques/opportunistes → récompenses gold plus “spiky”
- factions bureaucratiques → gold plus stable, plus “prévisible”
- sans explosion de variance (tests bornés)

Si tu veux la brique suivante : faire dépendre **w_gold** (pas juste la variance) de la personnalité aussi (ex: “greed” augmente la part monétaire), tout en gardant les tests statistiques stables.

Moi:
Ok
brique suivante : faire dépendre w_gold (pas juste la variance) de la personnalité aussi (ex: “greed” augmente la part monétaire), tout en gardant les tests statistiques stables.

ChatGPT:
OK — on fait dépendre **`w_gold`** de la personnalité, mais de façon **bornée** pour ne pas casser tes tests “POOR majoritairement non-gold” / “RICH majoritairement gold”.

Principe :
- on calcule un `w_gold_base` à partir de l’économie (POOR/RICH/liquidité)
- on applique un **delta personality** `Δw` dans une fenêtre **petite et clampée** (ex: ±0.12)
- puis on **re-clamp** selon le wealth level (ex: POOR max 0.35, RICH min 0.60)

---

## 1) Patch `RewardEconomyUtil.compute_reward_style(...)` + helpers

### A) `compute_reward_style(econ, tier, profile := null)` (signature étendue)
```gdscript
# RewardEconomyUtil.gd

static func compute_reward_style(econ: Dictionary, tier: int, profile := null) -> Dictionary:
	var wealth: StringName = StringName(econ.get("wealth_level", &"MODEST"))
	var liquidity: float = float(econ.get("liquidity", 0.5))

	var rich := (wealth == &"RICH" or wealth == &"OPULENT")
	var poor := (wealth == &"POOR" or liquidity < 0.35)

	# base stable
	var w_gold_base := 0.78 if rich else (0.12 if poor else 0.42)

	# --- personality delta (bounded) ---
	var dw := _w_gold_personality_delta(profile) # [-0.12..+0.12]
	var w_gold := clampf(w_gold_base + dw, 0.05, 0.95)

	# --- guard rails to keep tests stable ---
	if poor:
		w_gold = min(w_gold, 0.35)   # poor ne paye presque jamais en or
	if rich:
		w_gold = max(w_gold, 0.60)   # rich paye souvent en or

	var w_non := 1.0 - w_gold

	# opportunism heat: econ-driven (peut aussi être affecté par personnalité mais pas obligé)
	var opportunism_heat := 0.10 + (0.35 if rich else 0.0) + 0.05 * float(tier)
	opportunism_heat = clampf(opportunism_heat, 0.0, 1.0)

	return {"w_gold": w_gold, "w_non": w_non, "opportunism_heat": opportunism_heat, "w_gold_base": w_gold_base, "w_gold_dw": dw}


static func _w_gold_personality_delta(profile) -> float:
	# Greedy/mercantile/opportunist -> w_gold ↑
	# Honor/discipline/idealist -> w_gold ↓ (plus de faveurs/traités)
	var greed := _p(profile, &"greed", 0.5)                 # si tu n’as pas ce trait, laisse 0.5
	var opp := _p(profile, &"opportunism", 0.5)
	var dis := _p(profile, &"discipline", 0.5)
	var hon := _p(profile, &"honor", 0.5)

	# “greed” est dominant, sinon opportunism fait le job
	var raw := 0.60*(greed - 0.5) + 0.35*(opp - 0.5) - 0.25*(dis - 0.5) - 0.20*(hon - 0.5)

	# Borné pour stabilité
	return clampf(raw, -0.12, 0.12)
```

### B) `build_reward_bundle` appelle `compute_reward_style(..., profile)`
```gdscript
static func build_reward_bundle(econ: Dictionary, tier: int, action_type: StringName, rng: RandomNumberGenerator, profile := null) -> Dictionary:
	var style := compute_reward_style(econ, tier, profile)
	# ...
	if rng.randf() < float(style.w_gold):
		# gold ...
```

✅ Résultat :
- une faction “greedy” RICH tend vers 0.85–0.90 gold
- une faction “honorable/bureaucratic” RICH peut descendre vers 0.60–0.70 (mais jamais <0.60)
- une faction POOR peut monter un peu, mais jamais >0.35

---

## 2) Garder les tests verts (stabilité)

### Pourquoi ça ne casse pas tes tests existants
- **POOR** : `w_gold ≤ 0.35` ⇒ majoritairement non-gold reste vrai
- **RICH** : `w_gold ≥ 0.60` ⇒ majoritairement gold reste vrai
- ton test précédent utilisait `build_reward_bundle(econ, tier, action, rng)` sans profil ⇒ `dw≈0`, comportement inchangé.

---

## 3) Nouveau mini test : `w_gold` varie avec la personnalité mais reste dans les rails

Ce test vérifie :
- greedy > honor en `w_gold`
- poor clamp ≤ 0.35
- rich clamp ≥ 0.60

```gdscript
# tests/WGoldPersonalityClampedTest.gd
extends Node
class_name WGoldPersonalityClampedTest

func _ready() -> void:
	_test_w_gold_depends_on_personality_but_is_clamped_by_economy()
	print("\n✅ WGoldPersonalityClampedTest: OK\n")
	get_tree().quit()

func _test_w_gold_depends_on_personality_but_is_clamped_by_economy() -> void:
	_assert(ClassDB.class_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

	var tier := 3

	var econ_poor := {"wealth_level": &"POOR", "liquidity": 0.20, "prestige": 0.40}
	var econ_rich := {"wealth_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}

	var prof_greedy := {"personality": {&"greed": 0.95, &"opportunism": 0.85, &"discipline": 0.30, &"honor": 0.25}}
	var prof_honorable := {"personality": {&"greed": 0.15, &"opportunism": 0.20, &"discipline": 0.85, &"honor": 0.85}}

	var s_poor_g := RewardEconomyUtil.compute_reward_style(econ_poor, tier, prof_greedy)
	var s_poor_h := RewardEconomyUtil.compute_reward_style(econ_poor, tier, prof_honorable)
	var s_rich_g := RewardEconomyUtil.compute_reward_style(econ_rich, tier, prof_greedy)
	var s_rich_h := RewardEconomyUtil.compute_reward_style(econ_rich, tier, prof_honorable)

	_assert(float(s_poor_g.w_gold) <= 0.35, "POOR greedy w_gold must be clamped <= 0.35 (got %.3f)" % float(s_poor_g.w_gold))
	_assert(float(s_poor_h.w_gold) <= 0.35, "POOR honorable w_gold must be clamped <= 0.35 (got %.3f)" % float(s_poor_h.w_gold))

	_assert(float(s_rich_g.w_gold) >= 0.60, "RICH greedy w_gold must be clamped >= 0.60 (got %.3f)" % float(s_rich_g.w_gold))
	_assert(float(s_rich_h.w_gold) >= 0.60, "RICH honorable w_gold must be clamped >= 0.60 (got %.3f)" % float(s_rich_h.w_gold))

	# personality effect visible (within rails)
	_assert(float(s_rich_g.w_gold) > float(s_rich_h.w_gold) + 0.05, "greedy should have higher w_gold than honorable in RICH")
```

---

## 4) Petite note sur le trait “greed”
Si tu n’as pas (encore) un trait `greed`, tu peux :
- soit l’ajouter à tes templates de personnalité (recommandé, super utile pour economy),
- soit le mapper à `opportunism` (et laisser `greed` à 0.5 par défaut, comme dans le code).

---

Si tu veux la brique suivante : brancher `w_gold_dw` (le delta personnalité) dans ton **ArcNotebook** pour debug (“cette faction paye en or parce que greedy”), et faire un test statistique RICH greedy vs RICH honorable qui vérifie la proportion gold/non-gold.

Moi:
Ok
brique suivante : brancher w_gold_dw (le delta personnalité) dans ton ArcNotebook pour debug (“cette faction paye en or parce que greedy”), et faire un test statistique RICH greedy vs RICH honorable qui vérifie la proportion gold/non-gold.

ChatGPT:
OK — on fait 2 choses :

1) **Brancher** `w_gold_dw` (et idéalement `w_gold_base`/`w_gold`) dans `ArcNotebook` au moment du spawn d’offre (debug/metrics).  
2) Un **test statistique** déterministe : **RICH greedy** produit significativement plus de **gold offers** que **RICH honorable**.

---

## 1) Patch : logguer `w_gold_dw` dans ArcNotebook

### A) Dans ton `OfferFactory.spawn_offer_for_pair()` (ou l’endroit où tu construis `reward_bundle`)
Après `compute_reward_style(...)` / `build_reward_bundle(...)`, tu ajoutes les champs debug dans le `context` **et** tu enregistres un event.

```gdscript
# OfferFactory / ArcOfferFactory (extrait)

var style := RewardEconomyUtil.compute_reward_style(econ, tier, giver_profile)
var reward := RewardEconomyUtil.build_reward_bundle(econ, tier, action_type, rng, giver_profile)

context["reward_bundle"] = reward
context["reward_style"] = {
	"w_gold": float(style.w_gold),
	"w_gold_base": float(style.w_gold_base),
	"w_gold_dw": float(style.w_gold_dw),
	"opportunism_heat": float(style.opportunism_heat)
}

# debug ArcNotebook (si dispo)
var arc_notebook = _get_arc_notebook()
if arc_notebook != null and arc_notebook.has_method("record_pair_event"):
	arc_notebook.record_pair_event(
		int(context.get("day", 0)),
		StringName(context.get("giver_faction_id", &"")),
		StringName(context.get("antagonist_faction_id", &"")),
		&"offer.reward_style",
		&"NEUTRAL",
		{
			"w_gold": float(style.w_gold),
			"w_gold_base": float(style.w_gold_base),
			"w_gold_dw": float(style.w_gold_dw),
			"wealth_level": StringName(econ.get("wealth_level", &"")),
			"tier": tier
		}
	)
```

> Avantage : tu peux, en debug, afficher “**gold bias**” par faction, et expliquer au joueur/au log *pourquoi* une faction paye cash ou en faveurs.

### B) (Optionnel) Ajout d’une méthode dédiée `record_reward_style(...)`
Plus propre que détourner `record_pair_event`, mais pas obligatoire.

---

## 2) Test statistique : RICH greedy vs RICH honorable (gold proportion)

Ce test ne dépend pas de QuestPool/OfferFactory : il teste directement la logique reward (plus stable, rapide).  
Il vérifie que sur 200 tirages :

- greedy => proportion gold **nettement** plus élevée
- honorable => plus de non-gold (mais RICH reste majoritairement gold)
- et que `w_gold_dw` a bien le signe attendu (greedy positif, honorable négatif)

### `tests/RichGreedyVsHonorableGoldProportionTest.gd`

```gdscript
extends Node
class_name RichGreedyVsHonorableGoldProportionTest

func _ready() -> void:
	_test_rich_greedy_has_higher_gold_proportion_than_honorable()
	print("\n✅ RichGreedyVsHonorableGoldProportionTest: OK\n")
	get_tree().quit()

func _test_rich_greedy_has_higher_gold_proportion_than_honorable() -> void:
	_assert(ClassDB.class_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

	var econ_rich := {"wealth_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}
	var tier := 3
	var action := &"arc.truce_talks"
	var n := 200

	var prof_greedy := {"personality": {&"greed": 0.95, &"opportunism": 0.85, &"discipline": 0.30, &"honor": 0.25}}
	var prof_honorable := {"personality": {&"greed": 0.10, &"opportunism": 0.20, &"discipline": 0.85, &"honor": 0.90}}

	# sanity: dw signs
	var s_g := RewardEconomyUtil.compute_reward_style(econ_rich, tier, prof_greedy)
	var s_h := RewardEconomyUtil.compute_reward_style(econ_rich, tier, prof_honorable)
	_assert(float(s_g.w_gold_dw) > 0.03, "expected greedy w_gold_dw positive (got %.3f)" % float(s_g.w_gold_dw))
	_assert(float(s_h.w_gold_dw) < -0.03, "expected honorable w_gold_dw negative (got %.3f)" % float(s_h.w_gold_dw))

	var rng := RandomNumberGenerator.new()
	rng.seed = 90901

	var greedy_gold := 0
	var greedy_non := 0

	for i in range(n):
		var b := RewardEconomyUtil.build_reward_bundle(econ_rich, tier, action, rng, prof_greedy)
		if int(b.get("gold", 0)) > 0:
			greedy_gold += 1
		else:
			greedy_non += 1

	# reset rng for fair comparison (same sequence shape)
	rng.seed = 90901

	var hon_gold := 0
	var hon_non := 0

	for i in range(n):
		var b := RewardEconomyUtil.build_reward_bundle(econ_rich, tier, action, rng, prof_honorable)
		if int(b.get("gold", 0)) > 0:
			hon_gold += 1
		else:
			hon_non += 1

	var p_g := float(greedy_gold) / float(n)
	var p_h := float(hon_gold) / float(n)

	# RICH must stay mostly gold for both (guard rail)
	_assert(p_g >= 0.60, "RICH greedy should still be mostly gold (p=%.2f)" % p_g)
	_assert(p_h >= 0.60, "RICH honorable should still be mostly gold (p=%.2f)" % p_h)

	# greedy significantly higher than honorable
	_assert(p_g >= p_h + 0.08, "expected greedy gold proportion higher (greedy=%.2f honorable=%.2f)" % [p_g, p_h])

	# optional: print-ish debug in log
	print("RICH gold proportions: greedy=%.2f honorable=%.2f (n=%d)" % [p_g, p_h, n])

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

### Remarque importante
Le test est “robuste” parce que :
- delta `w_gold_dw` est clampé ±0.12
- RICH clamp min 0.60
- donc le résultat doit rester stable même si tu ajustes un peu les poids

---

Si tu veux la suite logique : faire un mini test d’intégration “OfferFactory + ArcNotebook” (vraie méthode spawn) qui assert que l’event `offer.reward_style` est bien écrit avec `w_gold_dw` pour une faction greedy.

Moi:
Ok
faire un mini test d’intégration “OfferFactory + ArcNotebook” (vraie méthode spawn) qui assert que l’event offer.reward_style est bien écrit avec w_gold_dw pour une faction greedy

ChatGPT:
Voici un **mini test d’intégration “OfferFactory + ArcNotebook”** qui appelle **ta vraie méthode de spawn**, et vérifie que l’event **`offer.reward_style`** est bien écrit avec un `w_gold_dw` **positif** pour un profil **greedy**.

> Comme on ne connaît pas (encore) le nom exact de ton autoload factory, le test **le cherche dynamiquement** dans `/root` en trouvant un node qui expose une méthode `spawn_offer_for_pair` (ou `spawn_offer_for_pair_from_params`).  
> Idem, il patch temporairement `ArcManagerRunner.arc_notebook` avec un stub qui capture les events.

---

## `tests/Integration_OfferFactory_RewardStyleNotebook_Test.gd`

```gdscript
extends Node
class_name Integration_OfferFactory_RewardStyleNotebook_Test

class StubArcNotebook:
	extends RefCounted
	var pair_events: Array = []

	func record_pair_event(day: int, a: StringName, b: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
		pair_events.append({
			"day": day, "a": a, "b": b,
			"action": action, "choice": choice,
			"meta": meta
		})

func _ready() -> void:
	_test_spawn_logs_reward_style_with_w_gold_dw()
	print("\n✅ Integration_OfferFactory_RewardStyleNotebook_Test: OK\n")
	get_tree().quit()

func _test_spawn_logs_reward_style_with_w_gold_dw() -> void:
	_assert(ClassDB.class_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

	var arc_mgr := get_node_or_null("/root/ArcManagerRunner")
	_assert(arc_mgr != null, "Missing /root/ArcManagerRunner")
	_assert(_has_prop(arc_mgr, "arc_notebook"), "ArcManagerRunner must have var arc_notebook")

	# Patch notebook
	var prev_notebook = arc_mgr.get("arc_notebook")
	var notebook := StubArcNotebook.new()
	arc_mgr.set("arc_notebook", notebook)

	# Find a factory that can spawn offers
	var factory := _find_root_node_with_method(["spawn_offer_for_pair", "spawn_offer_for_pair_from_params"])
	_assert(factory != null, "No OfferFactory found in /root with spawn_offer_for_pair* method")

	# Prepare deterministic inputs
	var rng := RandomNumberGenerator.new()
	rng.seed = 424242

	var giver := &"RICH_GREEDY"
	var antagonist := &"TARGET"
	var day := 12
	var tier := 3
	var action_type := &"arc.truce_talks"

	var econ_rich := {"wealth_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}
	var prof_greedy := {"personality": {&"greed": 0.95, &"opportunism": 0.85, &"discipline": 0.30, &"honor": 0.25}}

	# Spawn (vraie méthode)
	var spawned = null

	# Option A (recommandé): méthode “test-friendly”
	if factory.has_method("spawn_offer_for_pair_from_params"):
		spawned = factory.call("spawn_offer_for_pair_from_params", {
			"giver_faction_id": giver,
			"antagonist_faction_id": antagonist,
			"arc_action_type": action_type,
			"tier": tier,
			"day": day,
			"econ_override": econ_rich,
			"profile_override": prof_greedy,
			"rng": rng
		})
	else:
		# Option B: spawn_offer_for_pair(...) – on passe les args “classiques”
		# 👉 Si ta signature diffère, adapte les paramètres ici une fois (le test reste utile).
		spawned = factory.call("spawn_offer_for_pair",
			giver, antagonist, action_type, tier, day,
			econ_rich, prof_greedy, rng
		)

	# On ne force pas l’assert sur spawned si ta factory push direct dans QuestPool,
	# mais ça aide si tu retournes l’instance.
	# _assert(spawned != null, "spawn_offer_for_pair should return a QuestInstance (or at least not null)")

	# Assert: ArcNotebook event exists with w_gold_dw > 0
	var found := false
	for e in notebook.pair_events:
		if StringName(e.get("action", &"")) == &"offer.reward_style":
			var meta: Dictionary = e.get("meta", {})
			_assert(meta.has("w_gold_dw"), "offer.reward_style must include meta.w_gold_dw")
			_assert(meta.has("w_gold"), "offer.reward_style must include meta.w_gold")
			_assert(meta.has("w_gold_base"), "offer.reward_style must include meta.w_gold_base")

			var dw := float(meta.get("w_gold_dw", 0.0))
			_assert(dw > 0.0, "expected w_gold_dw > 0 for greedy profile (got %.4f)" % dw)

			# Bonus: verify it matches RewardEconomyUtil.compute_reward_style(...)
			var style := RewardEconomyUtil.compute_reward_style(econ_rich, tier, prof_greedy)
			_assert(abs(float(style.w_gold_dw) - dw) < 0.0001, "w_gold_dw mismatch vs compute_reward_style")
			found = true
			break

	_assert(found, "expected ArcNotebook record_pair_event with action=offer.reward_style")

	# Restore notebook
	arc_mgr.set("arc_notebook", prev_notebook)


# ---------------- helpers ----------------

func _find_root_node_with_method(methods: Array) -> Node:
	var root := get_tree().root
	for child in root.get_children():
		for m in methods:
			if child != null and child.has_method(m):
				return child
	return null

func _has_prop(obj: Object, prop: String) -> bool:
	for p in obj.get_property_list():
		if p.name == prop:
			return true
	return false

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

## Petit micro-patch “facultatif mais conseillé” dans ta Factory (pour rendre le test plug-and-play)

Si tu n’as pas déjà une entrée stable, ajoute **sans changer le comportement prod** :

```gdscript
# ArcOfferFactory.gd (ou OfferFactory.gd)
func spawn_offer_for_pair_from_params(p: Dictionary):
	# econ/profile overrides restent optionnels
	return spawn_offer_for_pair(
		StringName(p.get("giver_faction_id", &"")),
		StringName(p.get("antagonist_faction_id", &"")),
		StringName(p.get("arc_action_type", &"arc.raid")),
		int(p.get("tier", 1)),
		int(p.get("day", 0)),
		p.get("econ_override", null),
		p.get("profile_override", null),
		p.get("rng", null)
	)
```

Ça te donne une signature **stable pour les tests**, et en prod tu continues à appeler `spawn_offer_for_pair(...)` comme avant.

---

Si tu me confirmes le **nom exact** de ton autoload factory (ex: `ArcOfferFactory` ou `QuestOfferSimRunner`), je te fais une version du test qui l’adresse directement (sans recherche dynamique).

Moi:
QuestOfferSimRunner

ChatGPT:
Parfait — du coup on cible **directement** l’autoload **`/root/QuestOfferSimRunner`**.

Ci-dessous :

1) un **test d’intégration** qui appelle **QuestOfferSimRunner** (vraie chaîne spawn → log ArcNotebook)  
2) un **micro-patch minimal** à ajouter dans `QuestOfferSimRunner.gd` si tu n’as pas encore une entrée “params dict” stable (ça ne change rien en prod : ça ne fait que forward).

---

## 1) Test d’intégration : `tests/Integration_QuestOfferSimRunner_RewardStyleNotebook_Test.gd`

```gdscript
extends Node
class_name Integration_QuestOfferSimRunner_RewardStyleNotebook_Test

class StubArcNotebook:
	extends RefCounted
	var pair_events: Array = []

	func record_pair_event(day: int, a: StringName, b: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
		pair_events.append({"day": day, "a": a, "b": b, "action": action, "choice": choice, "meta": meta})

func _ready() -> void:
	_test_spawn_logs_reward_style_w_gold_dw_for_greedy()
	print("\n✅ Integration_QuestOfferSimRunner_RewardStyleNotebook_Test: OK\n")
	get_tree().quit()

func _test_spawn_logs_reward_style_w_gold_dw_for_greedy() -> void:
	var sim := get_node_or_null("/root/QuestOfferSimRunner")
	_assert(sim != null, "Missing /root/QuestOfferSimRunner autoload")

	var arc_mgr := get_node_or_null("/root/ArcManagerRunner")
	_assert(arc_mgr != null, "Missing /root/ArcManagerRunner autoload")
	_assert(_has_prop(arc_mgr, "arc_notebook"), "ArcManagerRunner must expose var arc_notebook")

	# Patch notebook (capture logs)
	var prev_notebook = arc_mgr.get("arc_notebook")
	var notebook := StubArcNotebook.new()
	arc_mgr.set("arc_notebook", notebook)

	var rng := RandomNumberGenerator.new()
	rng.seed = 424242

	var giver := &"RICH_GREEDY"
	var target := &"TARGET"
	var day := 12
	var tier := 3
	var arc_action_type := &"arc.ultimatum"

	# Overrides injectés uniquement pour le test (évite de dépendre de ton FactionManager)
	var econ_override := {"wealth_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}
	var profile_override := {"personality": {&"greed": 0.95, &"opportunism": 0.85, &"honor": 0.20, &"discipline": 0.30}}

	# Appel "vraie méthode spawn" via une entrée stable.
	_assert(sim.has_method("spawn_offer_for_pair_from_params"),
		"QuestOfferSimRunner must expose spawn_offer_for_pair_from_params(p: Dictionary). See micro-patch below.")
	var offer = sim.call("spawn_offer_for_pair_from_params", {
		"giver_faction_id": giver,
		"antagonist_faction_id": target,
		"arc_action_type": arc_action_type,
		"tier": tier,
		"day": day,
		"rng": rng,
		"econ_override": econ_override,
		"profile_override": profile_override
	})

	# (Optionnel) si tu retournes la QuestInstance
	# _assert(offer != null, "spawn_offer_for_pair_from_params should return the spawned QuestInstance")

	# Assert: ArcNotebook a bien reçu l’event offer.reward_style avec w_gold_dw > 0
	var found := false
	for e in notebook.pair_events:
		if StringName(e.get("action", &"")) == &"offer.reward_style":
			var meta: Dictionary = e.get("meta", {})
			_assert(meta.has("w_gold_dw"), "offer.reward_style meta must include w_gold_dw")
			_assert(meta.has("w_gold"), "offer.reward_style meta must include w_gold")
			_assert(meta.has("tier"), "offer.reward_style meta must include tier")

			var dw := float(meta.get("w_gold_dw", 0.0))
			_assert(dw > 0.0, "Expected w_gold_dw > 0 for greedy profile (got %.4f)" % dw)
			found = true
			break

	_assert(found, "Expected ArcNotebook record_pair_event(action=offer.reward_style)")

	# Restore
	arc_mgr.set("arc_notebook", prev_notebook)

func _has_prop(obj: Object, prop: String) -> bool:
	for p in obj.get_property_list():
		if p.name == prop:
			return true
	return false

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("TEST FAIL: " + msg)
		assert(false)
```

---

## 2) Micro-patch dans `QuestOfferSimRunner.gd` (entrée stable pour tests + prod inchangé)

Ajoute juste cette fonction (elle **forward** vers ta logique réelle de spawn ; adapte la ligne “CALL REAL” si besoin).

```gdscript
# QuestOfferSimRunner.gd

func spawn_offer_for_pair_from_params(p: Dictionary):
	# Paramètres standardisés
	var giver: StringName = p.get("giver_faction_id", &"")
	var ant: StringName = p.get("antagonist_faction_id", &"")
	var action: StringName = p.get("arc_action_type", &"arc.raid")
	var tier: int = int(p.get("tier", 1))
	var day: int = int(p.get("day", 0))
	var rng: RandomNumberGenerator = p.get("rng", null)

	var econ_override = p.get("econ_override", null)
	var profile_override = p.get("profile_override", null)

	# --- CALL REAL ---
	# 1) Si tu as déjà une méthode “réelle” style ArcOfferFactory.spawn_offer_for_pair(...)
	# var inst = ArcOfferFactory.spawn_offer_for_pair(giver, ant, action, tier, day, econ_override, profile_override, rng)

	# 2) Ou si ta “vraie” méthode est déjà dans QuestOfferSimRunner :
	# var inst = spawn_offer_for_pair(giver, ant, action, tier, day, econ_override, profile_override, rng)

	# 3) Sinon, appelle ton pipeline interne actuel (celle que ton ArcManager utilise déjà).
	var inst = _spawn_arc_offer_internal(giver, ant, action, tier, day, econ_override, profile_override, rng)

	return inst
```

### Si ton log “reward_style” n’est pas encore écrit
Dans **la fonction réelle** (celle qui calcule `w_gold` / `w_gold_dw`), ajoute ce log (ou son équivalent) :

```gdscript
if ArcManagerRunner and ArcManagerRunner.arc_notebook:
	ArcManagerRunner.arc_notebook.record_pair_event(
		day, giver, ant,
		&"offer.reward_style", &"NA",
		{
			"tier": tier,
			"w_gold": w_gold,
			"w_gold_dw": w_gold_dw
		}
	)
```

---

Si tu me colles la signature de ta méthode “réelle” (celle que ton ArcManager appelle déjà pour spawner les offers), je te remplace `_spawn_arc_offer_internal(...)` par **l’appel exact**, sans placeholders.
