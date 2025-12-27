# Événements & crises

## Types d’événements

- **Événements locaux** :
  - liés à un POI (ville, ruines, sanctuaire, etc.).  
  - déclenchés à l’entrée de l’armée sur la case.

- **Événements globaux** :
  - affectent tout ou partie du monde :  
    - éruption du volcan,  
    - invasion démoniaque,  
    - croisade,  
    - effondrement d’un empire, etc.

- **Événements de faction** :
  - liés à la progression d’une faction particulière :  
    - changement de régime,  
    - adoption d’une technologie,  
    - corruption magique, etc.

## Niveaux d’événements (1 à 5)

- Idée d’**arbre d’événements par “aura” / crise** :
  - 3–5 événements de **niveau 1**  
  - 2–4 de **niveau 2**  
  - 1–3 de **niveau 3**  
  - 2 de **niveau 4**  
  - 1 de **niveau 5**

- Les événements de plus haut niveau :  
  - sont plus rares,  
  - peuvent changer radicalement une région ou le monde (ex. : volcan actif, désert qui recouvre un royaume).

## Chronologie & cohérence

- La world-gen peut démarrer :
  - **avant**, **pendant** ou **après** une crise majeure.  
  - Il est donc tout à fait cohérent que le joueur commence un run au milieu d’un événement de niveau 5 déjà en cours.

- Entre les runs :
  - certaines crises peuvent être **résolues** (en bien ou en mal),  
  - leurs conséquences restent visibles (région détruite, faction disparue ou transformée).

## Fiche technique d’un événement (structure générale)

- `id` : identifiant unique.  
- `niveau` : 1 à 5.  
- `type` : local / global / faction.  
- `conditions` :  
  - de temps (saison, phase, année),  
  - de localisation (biome, POI spécifique),  
  - de factions impliquées,  
  - d’état du monde.
- `effets` :  
  - sur la carte (biomes, POI, routes),  
  - sur les factions (alliances, guerres, boosts),  
  - sur le joueur (bonus/malus, combats, choix).  
- `sous-événements` / `branches` :  
  - chaînage possible vers d’autres événements en fonction des choix ou des résultats.

