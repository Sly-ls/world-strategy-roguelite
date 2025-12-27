# World map & déplacement

## Déplacement de l’armée

- Déplacement **continu** en direction du point cliqué :
  - vitesse de base (ex.) : **10 px / seconde**.
  - la direction est recalculée en continu vers la destination.

- La position de l’armée est synchronisée avec une **grille logique** (pour savoir dans quel biome / POI elle se trouve).

## Influence des biomes sur la vitesse

- Chaque type de terrain dispose d’un **modificateur de vitesse** (ou de coût) :
  - plaine : rapide (modificateur proche de 1.0).  
  - forêt, marais, ruines : plus lents.  
  - villes : potentiellement plus rapides (routes).

- À chaque update de mouvement :
  - on détermine la **cellule** dans laquelle se trouve l’armée.  
  - on applique un multiplicateur de vitesse en fonction du biome.

## Obstacles infranchissables

- Certains types de cellules sont **non walkables** :
  - rivières, montagnes abruptes, zones de lave, etc.
- Si le prochain pas du mouvement entrerait dans une cellule non walkable :
  - l’armée s’arrête **au bord** de l’obstacle.  
  - elle ne traverse jamais ces cases sans mécanique spécifique (pont, gué, magie).

## Déplacement par clic

- Le joueur clique sur la carte →  
  l’armée se dirige en **ligne droite** vers le point visé (approximation par déplacement sur la grille).

- La logique clavier (ZQSD / flèches) existe mais est surtout utile pour le debug :  
  le déplacement au clic est la méthode principale prévue pour le joueur.

## Consommation de temps

- Chaque déplacement consomme **du temps de jeu** :  
  - soit via un **coût en secondes** par mouvement (dans la version case-par-case),  
  - soit via la combinaison : vitesse de déplacement × delta (dans la version continue).
- Cela fait interagir :
  - les déplacements,
  - le système de repos,
  - la progression des saisons,
  - et tout ce qui est dépendant de la date.

