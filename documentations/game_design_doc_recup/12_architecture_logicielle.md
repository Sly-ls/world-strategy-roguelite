🟥 BLOC 12 — ARCHITECTURE LOGICIELLE (GODOT + STRUCTURE DE PROJET)

Version exhaustive, conçue pour que tu puisses réellement coder le jeu.

⚠️ Tu as dit :

tu veux migrer vers Godot

tu viens de Java

tu veux une architecture propre et scalable

tu veux pouvoir gérer un monde immense

tu veux être efficace avec 4h/semaine

Donc l’architecture suivante est modulaire, claire et prête pour un développement long.

#️⃣ 12.1 ORGANISATION GLOBALE DU PROJET

Voici la structure recommandée :

/project
│
├── /src
│    ├── /world
│    ├── /combat
│    ├── /units
│    ├── /factions
│    ├── /events
│    ├── /ui
│    ├── /systems
│    ├── /data
│    └── /utils
│
├── /scenes
│    ├── WorldMap.tscn
│    ├── ArmyPanel.tscn
│    ├── CombatScene.tscn
│    ├── UnitCard.tscn
│    ├── ResourcePanel.tscn
│    ├── MiniMap.tscn
│    └── POI_Scene.tscn
│
├── /assets
│    ├── /textures
│    ├── /portraits
│    ├── /icons
│    ├── /maps
│    └── /fonts
│
├── /config
│    ├── biomes.json
│    ├── units.json
│    ├── factions.json
│    ├── events.json
│    ├── powers.json
│    └── worldgen.json
│
└── main.gd

#️⃣ 12.2 ARCHITECTURE GÉNÉRALE DU CODE (modèle MVC adapté Godot)

Tu auras 5 systèmes principaux :

WorldSystem → génération, biomes, POI, factions

ArmySystem → armée du joueur, ressources, repos, logistique

CombatSystem → grille 5×4, rounds, IA de combat

EventSystem → événements N1–N5

FactionSystem → IA stratégique, évolution, axes

Tout communique via un EventBus (pattern Observer).

#️⃣ 12.3 PRINCIPAUX SINGLETONS (AutoLoad dans Godot)

Ajoute dans Project > Autoload :

✔ World

Gère le continent, les chunks, les POI, les biomes, les factions.

✔ Player

Gère l’armée, les ressources, les pouvoirs, l’inventaire.

✔ EventBus

Système de signaux globaux (découplage maximal).

✔ Combat

Gère les combats, les unités, les rounds.

✔ RNG

Ton générateur pseudo-aléatoire (seed global du monde).

✔ TimeManager

Gère :

le temps de l’ère

les événements programmés

les cycles de repos

les deadlines de crise

#️⃣ 12.4 CLASSES PRINCIPALES — STRUCTURE DÉTAILLÉE
🟩 A) WORLD SYSTEM
WorldMap

chunk_size

chunks (dictionnaire indexé par coordonnées)

seed

world_age

factions[]

pois[]

biomes[]

Chunk

coordX, coordY

biomePrincipal

biomeSecondaire

altitude

humidité

features (forêts, marais, rivières…)

poi_list

faction_owner

POI

id

type (ville, ruine, faille…)

owner_faction

état (actif, détruit, corrompu)

effets passifs

🟩 B) FACTIONS SYSTEM
Faction

id

race

axes (0–5 par axe)

territoire (liste de chunks)

armées[]

personnalité IA

diplomatie[]

objectifs[]

niveauTech / Magie / Nature / Corruption / Divin

FactionAI

update() → décisions

plan_long_terme

plan_moyen_terme

plan_court_terme

réactions aux événements

🟩 C) ARMY SYSTEM
Army

unités (tableau 5×4)

ressources (food, gold, caravanes)

moral_global

pv_total

position (chunk)

statuts (fatigue, corruption, faim…)

Unit

type

race

pv

moral

attaqueDistance

attaqueCAC

attaqueMagie

initiative

lent

motsClés[]

passif[]

taille (1×1, 1×2, 2×2…)

General

race

classe

pouvoirs[]

charges

artefacts

compétences passives

🟩 D) COMBAT SYSTEM
CombatGrid

3 colonnes × 5 lignes

slots[]

règles de descente

gestion des unités géantes

CombatRound

étape Distance

étape CAC

étape Magie

étape Effets spéciaux

étape Moral / Renforts

phase du Général

CombatAI

priorité 1 : tuer front

priorité 2 : casser colonne

priorité 3 : cibler faibles

priorité 4 : focus selon type du joueur

🟩 E) EVENT SYSTEM
Event

id

niveau (1–5)

type

conditions

effets

propagation

EventManager

tirage pondéré

propagation sur carte

lien avec factions

lien avec POI

transformation des chunks

#️⃣ 12.5 SCHÉMA DES OPÉRATIONS (FLOW)
1) Début d’une run

→ WorldGen.generate()
→ FactionGen.place()
→ Mini-Simulation d’histoire
→ Player.spawn(hero)

2) Cycle de jeu

À chaque tick :

Player choisit une action

World avance

Factions AI agissent

Events se déclenchent

Biomes évoluent

Si combat → CombatScene

Retour WorldMap

Repos, craft, loot

3) Fin de run

→ récits
→ mémorial
→ mise à jour du monde
→ simulation extra-run
→ nouvelle ère

#️⃣ 12.6 ARCHITECTURE VISUELLE GODOT (SIGNALS)

Pour maximiser la propreté du code :

Exemple de signaux :

EventBus.emit_signal("combat_start", enemy_army)

EventBus.emit_signal("resource_changed", "food", amount)

EventBus.emit_signal("world_chunk_updated", chunk)

EventBus.emit_signal("army_updated")

L’UI écoute uniquement les signaux → aucune dépendance cyclique.

#️⃣ 12.7 SYSTÈME DE SAUVEGARDE (fonctionne avec ton monde immense)

Tu vas utiliser :

sauvegarde en chunks

compressée

écrite en diff

Le modèle :

save/
 ├── world/
 │    ├── chunk_10_5.json
 │    ├── chunk_10_6.json
 │    ├── ...
 │
 ├── factions.json
 ├── player.json
 ├── events_state.json
 └── metadata.json


Tu ne charges en mémoire que les chunks proches du joueur.