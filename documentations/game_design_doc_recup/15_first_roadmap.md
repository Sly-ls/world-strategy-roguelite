🎯 Phase 1 — SYSTÈME DE BASE (6–12 mois)

Objectif : que ton jeu tourne et soit jouable à petite échelle.

Contient :

moteur Godot setup

worldmap simple (pas encore dynamique)

déplacement de l’armée

UI worldmap + minimap

système de combat minimal

quelques unités protos

2–3 événements simple

sauvegarde/chargement

code base stable

À la fin :
👉 tu as un proto jouable, moche mais fonctionnel.

🎯 Phase 2 — BOUCLE DE GAMEPLAY (1 an)

Objectif : rendre le jeu fun et rejouable.

Contient :

vrais événements (niv 1–3)

factions simples

IA stratégique basique

interactions joueur ↔ worldmap

système de repos, moral, logistique

premiers artéfacts, POI

10 types d’unités

vraie interface d’armée

progression héroïque minimale

combats plus profonds

génération procédurale de la worldmap

À la fin :
👉 tu as un “mini-jeu complet”, un early access personnel.

🎯 Phase 3 — CORE DU JEU (1 an)

Objectif : faire de ton jeu un vrai roguelite stratégique.

Contient :

systèmes d’événements niv. 4–5

génération complète de factions

interactions entre factions

effets géographiques lourds (volcans, forêts, corruption…)

systèmes de crises planétaires

systèmes divins/démoniaques

races classiques + races procédurales

gros travail de polish UX

tous les systèmes d’ia (militaire + stratégique)

🎯 Phase 4 — FINALISATION (6 mois)

Objectif : polish, performance, assets, cohérence, équilibrage.

Contient :

assets graphiques

sons

optimisation worldmap

optimisation combats

équilibrage sur runs longues

packaging

choix du style artistique

trailers, site, itch.io ou Steam

🟧 2 — ROADMAP PRODUCTION (ordre optimal du dev)

Voici l’ordre exact dans lequel développer le jeu pour éviter les pièges.

🟦 Étape 1 — Fondations Godot

gestion des scènes

entrée utilisateur

système d’autoload (GameManager, DataManager…)

structure dossier

boucle principale

gestion caméra

🟦 Étape 2 — Worldmap minimale

grille logique 1024×1024

affichage d’une map simple (biomes statiques)

déplacement d’armée

minimap

détection POI

sauvegarde simple

🟦 Étape 3 — UI core

interface armée

icônes action (repos, marche forcée…)

représentation simple des troupes

moral + PV global

🟦 Étape 4 — Combat prototype

3 colonnes × 5 lignes

unités basiques

1 pouvoir du général

collisions, attaques

renfort

résolution d’une bataille simple

🟦 Étape 5 — Événements niveau 1–2

apparition cultes

changement local de biome

migration

révolte

météo locale

🟦 Étape 6 — Système de factions minimal

3 factions : humaine / orc / elfes

relations simples

expansion territoriale basique

🟦 Étape 7 — Système d’évolution (bâtiments = axes)

bâtiments niveau 1

effets sur les unités

gestion des axes (techno / magie / nature / divin / corruption)

🟦 Étape 8 — IA stratégique niveau 1

expansion simple

défense simple

réactions aux événements

attaques opportunistes

🟦 Étape 9 — Génération procédurale du monde

factions dynamiques

races dynamiques

POI aléatoires

axes initiaux aléatoires

évolution dynamique

🟦 Étape 10 — Systèmes d’événements niveau 3–5

invasion démoniaque

supervolcan

IA globale

guerre divine

altération massive du continent

🟦 Étape 11 — Rejouabilité + polish

options runs

narration émergente

journal du monde

récapitulatif des ères

sauvegardes multiples