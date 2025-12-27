🟥 BLOC 3 — SYSTÈME DE COMBAT ULTRA-COMPLET

C’est la MÉGA section du GDD.
Je vais la découper en sous-parties très structurées, qui seront intégrées telles quelles dans le fichier Markdown final.

#️⃣ 3. COMBAT — STRUCTURE GÉNÉRALE

Le système de combat repose sur :

une grille 3 colonnes × 5 lignes

des unités simples ou multi-cases

un système distance → CàC → magie → renfort

un système d’initiative

des compétences (splash, push/pull…)

un général avec pouvoirs à charges

un mode tour par tour (TBT) ou temps réel avec timers

une IA interne de combat

des cas spéciaux (mort, fuite, moral, effets de zone…)

## 3.1 STRUCTURE DE LA GRILLE DE COMBAT
En 2D :
COLONNE 1     COLONNE 2     COLONNE 3
-----------------------------------------
| 1,1 | 1,2 | 1,3 | 1,4 | 1,5 | ← Front (ligne 1)
| 2,1 | 2,2 | 2,3 | 2,4 | 2,5 | ← Soutien (ligne 2)
| 3,1 | 3,2 | 3,3 | 3,4 | 3,5 | ← Arrière (ligne 3)
-----------------------------------------
| 4,1 | 4,2 | 4,3 | 4,4 | 4,5 | ← Réserve
| 5,1 | 5,2 | 5,3 | 5,4 | 5,5 | ← Réserve profonde

Type de cases :

case simple (1×1)

case large (1×2, 2×2, 3×1…) selon unités

case bloquée (selon événement ou capacité)

## 3.2 UNITÉS — STATISTIQUES

Chaque unité possède :

Caractéristiques principales

PV (points de vie)

MORAL (0–100)

ATK_DISTANCE

ATK_CAC

ATK_MAGIE

INITIATIVE (rapide / normal / lent)

TAILLE (1×1 à 3×3)

PORTÉE distance (1–3 colonnes)

TEMPS ENTRE ATTAQUES (mode temps réel)

ARMURE (réduction fixe)

RÉSISTANCES (physique / magique / corruption)

TYPE :

humanoïde

démon

bête

mécanique

végétale

élémentaire

Caractéristiques comportementales

Ordres par défaut :

agressif

défensif

suicidaire

discipliné

opportuniste

berserk

Déclencheurs spécifiques :

attaque si allié meurt

recul si moral < 20

avance après attaque

## 3.3 ORDRE D’ATTAQUE DÉTAILLÉ
1️⃣ Distance (simultané)

Toutes les unités ayant ATK_DISTANCE > 0 tirent selon :

portée

priorité cible

capacités

2️⃣ CàC (seulement front)

Unités en 1ère ligne :

frappent simultanément

hors initiative spéciale

3️⃣ Magie (simultané)

Tous les lanceurs de sorts déclenchent à la fin du round :

sorts directs

zones

malédictions

buffs

4️⃣ Renfort

Une unité en ligne 2 descend si :

case front vide

unité pas “retardée”

pas d’effet bloquant

## 3.4 INITIATIVE — REFERENTIEL

Il y a 3 niveaux d’initiative :

⚡ Rapide

joue avant tout le monde dans sa catégorie (distance/cac/magie)

exemple : archer expérimenté, assassin, créature rapide

⚪ Normal

simultané

🐢 Lent

joue après tout le monde

exemple : géant, golem, machine lourde

## 3.5 COMPÉTENCES (LISTE COMPLÈTE)
🟥 Attaque & dégâts

Splash Damage — zone 1×3 ou cercle

Perce-Armure — ignore armure

Perce-ligne — touche toutes les unités devant

Multi-coup — frappe 2 à 5 fois

Execution — tue unité < 10% PV

Tir arrière — peut viser ligne 2 ou 3

🟦 Mobilité & positionnement

Push — repousse l’ennemi

Pull — tire vers l’avant

Dash — avance ou recule avant attaque

Recul défensif — recule après attaque

Charge — boost CàC si déplacement

🟩 Défense

Bouclier magique

Armure temporaire

Lien de vie (partage dégâts avec un allié)

Camouflage / Furtivité (1 tour)

🟨 Contrôle

Stun — empêche l’activation du round

Silence — bloque magie

Entrave — annule le renfort

Peur — baisse moral → fuite

🟫 Magie & arcanes

Projectile magique

Explosion arcanique

Invocation temporaire

Brûlure

Saignement

Malédiction

Corruption progressive

🟧 Synergies

Buff d’attaque

Buff moral

Buff défense

Combo Nature (si terrain végétal)

Combo Techno (si unité mécanique alliée)

Combo Corruption (si cible corrompue)

## 3.6 POUVOIRS DU GÉNÉRAL

Le général possède :

1 pouvoir racial

1 pouvoir de classe

pouvoirs trouvés durant run

pouvoirs donnés par reliques

🔋 Charges & recharge

charges limitées

recharge uniquement hors combat :

repos

camp

lieux sacrés

événements

Exemples :
🌿 Pouvoir racial (elfe)

Pointe végétale : immobilise une unité

Flèche lunaire : dégâts magiques + stun

🔥 Pouvoir racial (orc)

Rage de la horde : toutes les unités gagnent +2 CàC

Hurlement : baisse moral ennemi

⚙️ Pouvoir techno

Tir orbital (techno ≥ 3)

Bouclier ionique

😈 Pouvoir corrompu

Propagation

Mutation aléatoire

## 3.7 SYSTÈME DE TEMPS (OPTIONNEL)

Deux modes :

🟦 Mode 1 : Tour par tour (TBT)

chaque round suit les phases fixes

parfait pour calcul stratégique

lisible

🟥 Mode 2 : Temps réel avec timers

Chaque unité possède :

un temps d’attaque (ex : 1.8s)

un cooldown de capacité

un délai de renfort

Le joueur peut jouer en :

vitesse x1

vitesse x2

vitesse x5

pause active

## 3.8 MORAL — SYSTÈME COMPLET

Le moral va de 0 à 100.

Baisse du moral :

perte d’unité

mort d’un allié

compétence de peur

corruption

désavantage numérique

Augmentation :

général (pouvoirs)

victoire de round

buff moral

faction inspirante

Seuils :

< 20 → risque de fuite

< 10 → panique

< 5 → abandon

## 3.9 CONDITIONS DE FIN
Victoire :

armée ennemie annihilée

fuite ennemie

effet de pouvoir

Défaite :

armée détruite

général tué

moral global < 0

Autres issues :

retraite contrôlée

capture de l’unité “général ennemi”

intervention d’événement N3+