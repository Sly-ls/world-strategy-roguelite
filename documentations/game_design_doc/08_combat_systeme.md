# Système de combat

## Champ de bataille

- Grille de **3 colonnes × 5 lignes** pour chaque camp (allié vs ennemi).  
- La **ligne du bas** (ligne 0) est la **ligne de front**.  
- Les lignes au-dessus (1–4) sont des **lignes de renfort**.

- Chaque case de la grille contient :
  - soit une **unité d’armée** (une `UnitData` adaptée au contexte combat),  
  - soit est **vide**.

- Les unités “spéciales” (grandes créatures) peuvent occuper **plusieurs cases** (plus tard).

## Tour de combat (version prototype)

Combat **en tours**, chaque tour est découpé en **phases** dans l’ordre :
1. **Attaques à distance** (ranged)  
2. **Attaques au corps à corps** (melee)  
3. **Magie** (magic)  
4. **Renforts** (descente des unités de derrière vers la ligne de front)

### Ciblage

- Pour chaque côté :
  - seule la **ligne de front** (ligne 0) attaque.  
  - les attaques ciblent toujours la **première unité vivante** de la ligne adverse, de gauche à droite.
- Toutes les unités de la ligne de front peuvent frapper (si elles ont un power > 0 dans la phase considérée).

### Résolution

- Chaque phase (distance / CàC / magie) :
  - parcourt les colonnes de la ligne de front,  
  - applique les dégâts à la cible de front opposée,  
  - tue des unités si leurs PV tombent à 0 ou moins.

- Les **renforts** :
  - après les trois phases, si une case de la ligne de front est vide,  
  - on “tasse” les unités de la colonne (ligne 1 → 0, 2 → 1, etc.).

## Victoire / défaite

- Un côté est considéré comme **mort** si :
  - toutes ses unités sont null ou hp ≤ 0.

- Fin du combat :
  - si les alliés sont morts → **défaite**.  
  - si les ennemis sont morts → **victoire**.  
  - si les deux côtés meurent simultanément → match nul (cas rare).

- À la fin du combat :
  - on copie les PV restants (et les morts) dans l’`ArmyData` du joueur.  
  - les slots correspondants sont vidés si les unités sont mortes.

## Pouvoirs du général (prévu)

- Le général possède :  
  - un pouvoir de **race**,  
  - un pouvoir de **classe**,  
  - et peut en acquérir d’autres pendant la run.

- Chaque pouvoir a :
  - un **nombre de charges** maximum,  
  - un **mode de recharge** :  
    - par repos,  
    - par événements,  
    - ou par conditions spéciales.

- Certains pouvoirs peuvent avoir **recharge infinie** mais un **cooldown** (ex. utilisable une fois tous les X tours).

- Les pouvoirs sont utilisés à des **moments précis** du combat :
  - typiquement en début de tour ou entre les phases.


