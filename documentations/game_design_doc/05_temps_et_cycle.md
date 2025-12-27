# Temps, saisons et phases

## Structure du temps

- Le jeu suit un temps **continu**, découpé en :
  - **4 saisons** : Printemps, Été, Automne, Hiver.
  - Chaque saison : **15 jours**.
  - Chaque jour : **4 phases** : Aube, Jour, Crépuscule, Nuit.
- Une journée en temps réel dure **1 minute** (60 secondes).  
  ⇒ une phase dure **15 secondes**.

## Représentation

- Affichage sous la forme :  
  `Saison numéro_jour - phase`  
  Ex. : `Printemps 3 - Crépuscule`.

- Sur la world map :
  - le temps avance en continu (appel d’un `advance_time(delta)` global).  
  - le temps est **figé en combat** (pas d’appel à `advance_time` dans la scène de combat).

## Impact sur le gameplay

- Certains événements / POI peuvent dépendre :
  - de la saison (ex. : certains cultes n’apparaissent qu’en Automne).  
  - de la phase (ex. : événements nocturnes, attaques de créatures, bonus de repos la nuit).

- Le temps sert également de base à :
  - la **durée de vie du général** (vieillesse).  
  - la **progression des factions** (déverrouillage de nouvelles étapes magiques/techno).  
  - le **timing des crises mondiales** (niveau 1 à 5).

## Repos et consommation de temps

- Un **repos** dure actuellement **2 phases** (soit 30 secondes de temps de jeu), pendant lesquelles :
  - le général / l’armée ne peuvent pas agir ni se déplacer.  
  - le temps de jeu, lui, continue d’avancer.

