📅 BLOC 13 — ROADMAP DE DÉVELOPPEMENT (ORDRE EXACT DU CODAGE)

Voici la feuille de route complète, conçue pour un dev solo, 4 h/semaine, pour faire un jeu riche, modulaire, robuste.

🎯 Vision générale

Durée estimée : 3 ans (~150 semaines)

Temps hebdo moyen : 4 h

Total estimé : ~600 h

Découpé en phases distinctes, de complexité croissante

🟩 Phase 1 — Fondations (~6–12 mois, ~24–48 semaines)

Semaine 1-4

Choix version de Godot (3.x ou 4.x)

Création projet + structure dossier (voir Bloc 12)

Implémenter autoloads : World, Player, EventBus, RNG, Combat

Présentation minimaliste de la carte (TileMap simple)

Semaine 5-12

Affichage worldmap de base (grille logique, déplacement)

Caméra (pan, zoom)

Mini-map statique

Création de 3 biomes simples

Simple représentation UI : panneaux vides

Semaine 13-24

Panneau inférieure : Actions bouton, Grille 5×4 vide

Ressources de base : nourriture & or

Repos simplifié (8h fixe)

Unit test : déplacement armée, panneau UI

Semaine 25-36

Système d’unités minimal : définition via JSON/Resource

Prototype d’unité : Archer, Soldat, Mage (3 types)

Interface détail unité

Sauvegarde / chargement de base

Semaine 37-48

Prototype de combat : grille 3×5, tour par tour

Implémentation : distance → CàC → magie

Victoire / défaite simples

Mini-éditeur de carte de test

Première faction statique (2-3 factions)

🟦 Phase 2 — Boucle de gameplay complète (~12–18 mois)

Semaine 49-84

Événements N1–N2

Placement de POI + interactions simples

Factions dynamiques (3 factions, IA très simple)

Logistique “chariots/mules/chevaux”

Ressources approfondies : transport, repos amélioré

Semaine 85-120

Système d’unités géantes + compétences avancées

Grille 5×4 complète, UI équipée

Pouvoirs du général (charges, rechargement)

Moral global + mécanique d’abandon

Terrain d’influence combat (biome effet)

Semaine 121-150

Génération procédurale du monde (seed, chunks)

Simulation mini-ère initiale

Biomes dynamiques : désert avance, forêts poussent

Événements N3

IA stratégique basique

🟨 Phase 3 — Systèmes avancés (~12–15 mois)

Semaine 151-198

Événements N4–N5

Transformations mondiales (volcans, portails, titans)

IA avancée : plans long terme, diplomatie, alliances, trahisons

Évolution d’axes des factions (bâtiments, pertes, reliques)

Semaine 199-246

Crafting / reliques / objets de quête

Quêtes globales liées aux événements d’ère

Guerre persistante entre factions

Multi-fin de run, héritage d’ère suivant

Profil de joueur “succès” & “échec”

🟥 Phase 4 — Polish, optimisation et lancement (~6 mois)

Semaine 247-272

Graphismes : icônes, portraits, animations unitaires

Sons : musique, effets, environnement

Optimisation worldmap (streaming, mémoire)

Tests longue durée (≈100 rounds combats)

Interface fine tuning (zoom, responsive)

Semaine 273-300

Traduction / localisation (option)

Packaging / export (PC, Mac, Linux)

Documentation utilisateur / manuel

Trailer + site web

Lancement early access ou distribution indie

🎬 Résumé en un tableau simplifié
Phase	Durée estimée	Objectifs principaux
1	6-12 mois	Fondations, prototype worldmap, combat simple
2	12-18 mois	Boucle gameplay complète, IA de base, génération procédurale
3	12-15 mois	Systèmes avancés, crises globales, IA complète
4	6 mois	Polish, optimisation, assets, lancement