# Armée, unités et ressources

## Structure de l’armée

- Une armée est composée d’un **nombre fixe de slots** (ex. 20), affichés dans une grille 5×4 dans l’UI.  
- Chaque slot contient soit :
  - une **unité** (`UnitData`),  
  - soit est **vide**.

- Une unité contient au minimum :
  - `name`  
  - `max_hp`, `hp`  
  - `max_morale`, `morale`  
  - `count` (nombre de soldats dans l’unité)  
  - `melee_power`, `ranged_power`, `magic_power`  
  - potentiellement des compétences / tags (lance, multiple attaques, etc.).

- Une unité morte (hp ≤ 0) :
  - n’est plus affichée.  
  - libère son slot dans l’armée (slot remis à null).

## UI d’armée

- En bas de l’écran world map, un panneau affiche :
  - **Deux grandes jauges** :  
    - PV totaux de l’armée.  
    - Moral total de l’armée.
  - La **grille des unités** :
    - chaque slot montre un portrait / icône d’unité,
    - un tooltip indique : nom, PV, moral, effectif.

- Un petit cadre additionnel affiche :  
  - **Ressources logistiques** (prévu) : chariots, nourriture, montures, etc.  
  - **Reliques / objets spéciaux** (objets de quête, artefacts).

## Repos et récupération

- Le repos permet de :
  - restaurer une partie des PV manquants,  
  - restaurer une partie du moral manquant.
- L’efficacité du repos dépend :
  - du type de terrain (plaine, ville, sanctuaire, ruines…).  
  - potentiellement de la phase (nuit plus reposante, zones corrompues moins).

- Le repos est une **action bloquante** :
  - l’armée ne peut pas bouger pendant la durée de repos.  
  - le temps de jeu, lui, continue d’avancer.

## Logistique (prévu)

- Ressources de base :
  - **Nourriture** : consommée par jour / par repos.  
  - **Or** : utilisé dans les villes pour recruter et se rééquiper.
  - **Chariots / montures** : influencent la capacité de transport et la vitesse.

- Manquer de nourriture ou de logistique doit avoir :
  - un impact sur le moral,
  - un impact sur l’efficacité du repos,
  - éventuellement des risques d’événements négatifs (mutinerie, désertions, maladies).

