🟥 BLOC 10 — RESSOURCES, LOGISTIQUE & REPOS

C’est une partie clé de ton jeu, car elle relie :

la world map

l’armée

le combat

les pouvoirs

la survie

le pacing d’une run

Ton système est cohérent, unique, et déjà très fort conceptuellement.
Je consolide tout et j’enrichis.

#️⃣ 10.1 LES RESSOURCES PRINCIPALES

Il existe 4 ressources logistiques, affichées dans l’UI :

1) Nourriture

consommée chaque jour / déplacement

dépend du nombre d’unités

permet de maintenir le moral

pénalités si <0 :

moral -10 / jour

pv des unités -1% / jour

impossibilité de repos

2) Troupes de charge

Représentées par :

Chariots (grande capacité)

Mules (capacité moyenne)

Chevaux (capacité faible mais rapides)

Bottes = capacité minimale (à pied)

Elles influencent :

vitesse maximale

capacité de transport

difficulté des terrains traversés

risque de perdre des ressources

possibilité de construire des camps avancés

efficacité du repos

3) Or

achat de ressources

recrutement d’unités spéciales

négociation diplomatique

entretien de certaines unités techno

L’or sert surtout à équilibrer les choix du joueur.

4) Reliques / Objets spéciaux

Stockés dans un encart spécifique dans l’UI (que tu as demandé).

Types :

reliques divines

artefacts magiques

technologies avancées

objets de quêtes

objets uniques des factions

Ces objets modifient profondément une run.

#️⃣ 10.2 RESSOURCES SECONDAIRES
A) Moral global

(Barre déjà présente dans ton UI)

Facteurs :

nourriture

succès / défaites

repos

événements mondiaux

pouvoirs divins

corruption

Effets :

80 → bonus attaque et initiative

40–80 → normal

20–40 → malus attaque

<20 → risque de fuite complète en combat

B) Points de Campement

Ressource invisible qui mesure :

les tentes

lits

ustensiles

cuisines

équipement d’infirmiers

Plus tu as de campement → meilleur est le repos.

C) Endurance

Utilisée pour :

marche forcée

actions spéciales

combats successifs

porter équipement lourd

Endurance = variable invisible mais impactante.

#️⃣ 10.3 GESTION DU REPOS (TA VERSION OFFICIELLE)

Tu as défini un système classe, on le formalise :

✔ Repos = 8h d’immobilisation

Le repos rend :

PV des unités (en proportion)

Moral

Charges du général

Endurance

Certains cooldowns de pouvoirs

Blessures légères

Types de zones de repos
1) Zones Bénies

tous les pouvoirs +1 charge

moral +30

temps de repos divisé par 2

2) Zones Neutres

Repos complet normal.

3) Zones Corrompues

seulement 1 charge récupérée

moral -10

PV restauré réduit

4) Zones Techno

certains pouvoirs techno récupèrent mieux

réparations mécaniques rapides

Repos Interrompu

Si le joueur est :

poursuivi

harcelé

en territoire hostile

proche d’un événement N2–N5

→ le repos peut être interrompu par une attaque surprise.

#️⃣ 10.4 LOGISTIQUE ET MOUVEMENT
1) Déplacement normal

consomme nourriture

fatigue faible

vitesse dépend des bêtes de charge

2) Marche forcée

capacité spéciale du héros

consomme endurance + moral

augmente le risque d’embuscade

permet de fuir une armée

ne permet pas de se battre dans des conditions optimales (-initiative, -PV max temporaire)

3) Terrain

Les terrains influencent :

vitesse

consommation

moral

capacité de campement

sécurité du repos

Exemples :

montagne → lente + fatigue

forêt → dissimulation meilleure + nourriture sauvage

désert → très forte consommation

marais → risques de maladies

techno → ressources rares

corruption → moral lourdement affecté

#️⃣ 10.5 LOGISTIQUE DES UNITÉS
✔ Une unité = son propre poids logistique

Les unités lourdes demandent :

plus de nourriture

plus d’endurance

plus de place

soins plus longs

✔ Les unités magiques consomment du “mana passif”

Selon lore → coût représenté dans la nourriture / repos.

✔ Les unités techno demandent parfois de l’or ou des pièces

Pour rester opérationnelles.

#️⃣ 10.6 SYSTÈME DE CHARGE
✔ Chaque chariot/mule/cheval a une capacité

Dans ton UI : juste un compteur global est montré.

Si capacité dépasse :

nourriture se perd

moral -10

vitesse grandement réduite

#️⃣ 10.7 INTERACTION AVEC LES ÉVÉNEMENTS

Les ressources influencent :

choix dans les événements

capacité à résoudre certaines crises

possibilités diplomatiques

issue de certains combats

chance de survie dans les biomes hostiles

Exemples :

manque de nourriture → obligé de piller un village → faction devient hostile

trop de corruption dans l’armée → certain POI refusent d’aider

trop d’or → les bandits deviennent plus agressifs

#️⃣ 10.8 ÉQUILIBRAGE GLOBAL

Le système est calibré pour :

1 repos tous les 2–3 jours

1 combat tous les 1–2 jours

1 augmentation de puissance significative toutes les 2 crises

1 événement majeur d’axe environ tous les 10–15 jours

Cela crée un rythme naturel très agréable :

Repos → Progression → Combat → Loot → Danger → Repos → etc.