🟥 BLOC 11 — INTERFACE UTILISATEUR (UI) GLOBALE

L’interface est conçue pour :

être lisible sur un grand écran

afficher les informations sans surcharger

permettre des décisions stratégiques rapides

montrer l’état de l’armée en un coup d’œil

afficher le monde comme un tapis vivant

#️⃣ 11.1 STRUCTURE GÉNÉRALE (WORLD MAP)

La world map occupe 100% de la surface, à part quelques panneaux :

Mini-map (en haut à droite)

Bandeau supérieur (optionnel)

Panneau inférieur (Armée + Actions + Ressources)

✔ Positionnement validé :
┌────────────────────────────────────────────┐
│                                            │
│                WORLD MAP                   │
│                                            │
│                                ┌──────────┐│
│                                │ MINIMAP  ││
│                                └──────────┘│
└────────────────────────────────────────────┘
┌────────────────────────────────────────────┐
│ ACTIONS | ARMÉE (5×4) | JAUGES | RESSOURCES │
└────────────────────────────────────────────┘

#️⃣ 11.2 MINI-MAP (EN HAUT À DROITE)
Contenu :

relief simplifié

limites de biomes

frontières de factions

points d’intérêt (icônes POI)

position du joueur

directions des armées ennemies (si connues)

Fonctions :

clic pour naviguer

zoom local

affichage des couches (tactique / politique / axe / météo)

#️⃣ 11.3 BANDEAU SUPÉRIEUR (OPTIONNEL MAIS RECOMMANDÉ)

Très discret, semi-transparent, contient :

jour / heure

météo globale

3 icônes :

Encyclopédie

Journal des événements

Menu

#️⃣ 11.4 PANNEAU INFÉRIEUR — LE CŒUR DE L'UI

Ce panneau occupe environ 25% de la hauteur, centré horizontalement.

Il contient 4 sous-zones :

Zone d’Actions (à gauche, débordant sur la map)

Jauges globales (au centre, en haut du panneau)

Grille des unités (5×4)

Cadre Ressources & Reliques (à droite)

✔️ 11.4.1 ZONE D’ACTIONS (GAUCHE)

Ces boutons sont “semi-détachés” du panneau pour un style Warhammer Total War.

Boutons :

Repos

Fortification

Marche forcée

Assiéger / Lever siège

Pouvoirs de World Map (2 à 6 boutons selon capacités)

Chaque bouton :

a son cooldown

sa couleur d’état

une info-bulle détaillée

✔️ 11.4.2 JAUGES GLOBALES (CENTRE HAUT DU PANNEAU)

Deux grandes barres :

PV totaux de l’armée

Moral global

Format :

[ PV ████████████░░░░░░░ ] 12 450 / 16 200

[ MORAL ████████░░░░ ] 63 / 100

✔️ 11.4.3 GRILLE DE L’ARMÉE (5×4)

C’est le cœur du panneau.

Chaque unité affiche :

un portrait ou une icône de la troupe en bataille

le nombre restant / total

2 mini-barres :

PV

Moral

icônes de statut :

blessure

poison

buff

debuff

charge en cours

lent / initiative

ombre ou cadre pour unités géantes occupant plusieurs cases

Disposition :

Col1      Col2       Col3
[1,1]    [1,2]     [1,3]
[2,1]    [2,2]     [2,3]
[3,1]    [3,2]     [3,3]
[4,1]    [4,2]     [4,3]
[5,1]    [5,2]     [5,3]

✔️ 11.4.4 CADRE RESSOURCES & RELIQUES (À DROITE)

Affiché comme un panneau vertical séparé, légèrement détaché.

Ressources visibles :

Nourriture : 128

Chariots / Mules / Chevaux / Bottes : 7

Or : 342

Objets spéciaux :

reliques

artefacts

objets de quête

consommables stratégiques (non liés au combat)

Chaque objet :

carré 48×48

info-bulle détaillée

rareté (couleur)

#️⃣ 11.5 INTERFACES DE DÉTAIL (OVERLAYS)
1) Détail d’unité

Clique sur une unité → ouvre panneau sur la droite :

nom

race

description

pv / moral / compétences

statistiques d’attaque

mots-clés

synergies

statut

2) Grille de combat (preview)

Quand un combat est sur le point de commencer :

preview des 5×4

infos de terrains

météo

morale

composition ennemie

3) Panneau de faction

Quand tu cliques sur une ville ou un territoire :

détails faction

axes

dirigeants

diplomatie

#️⃣ 11.6 INTERFACE DE COMBAT (SÉPARÉE)

Quand on entre en combat :

Haut de l’écran :

nom de la bataille

biome

météo

Gauche :

pouvoirs du général (cooldowns + charges)

Bas :

grille 5×4 des unités du joueur

bouton “fuite” (si possible)

Droite :

grille 5×4 ennemie

profils adverses

Effets spéciaux :

éclairs magiques

corruptions

rituels

aura divine

etc.

#️⃣ 11.7 STYLE GRAPHIQUE
Style inspiré de :

Warhammer Total War (pour HUD)

Darkest Dungeon (pour structure d’infos)

Northgard (pour lisibilité)

Couleurs selon axes :

Techno → bleu acier

Magie → violet

Nature → vert

Divin → or/blanc

Corruption → rouge sombre

Effets :

bordures runiques

surbrillance sur hover

transitions douces

animations légères des jauges