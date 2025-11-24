# Roadmap de développement

## Phase 1 – Prototype jouable (ce que tu fais actuellement)

1. **World map minimale**
   - Affichage de la carte.
   - Déplacement par clic en ligne droite.
   - Obstacles simples (rivières / montagnes non franchissables).

2. **Système de temps**
   - Saisons, jours, phases (aube, jour, crépuscule, nuit).
   - Affichage de la date/phase.
   - Temps figé en combat.

3. **Armée & UI d’armées**
   - Slots d’unités (5×4).
   - PV / moral par unité.
   - PV / moral globaux d’armée.

4. **Repos**
   - Repos sur la world map (action bloquante).  
   - Durée = 2 phases.  
   - Restauration partielle des PV / moral selon le terrain.

5. **Combat prototype**
   - Grille 3×5.  
   - Ligne de front, renforts.  
   - Phases distance/CàC/magie.
   - Résolution de victoire/défaite + mise à jour de l’`ArmyData`.

6. **Intégration world map ↔ combat**
   - Lancer un combat depuis un POI.  
   - Retour à la world map avec pertes appliquées.

## Phase 2 – Monde vivant & POI

1. **Système d’événements de POI**
   - Villes : repos amélioré, commerce (plus tard).  
   - Sanctuaires : repos et effets magiques.  
   - Ruines : exploration + combats.

2. **Génération procédurale de la carte**
   - Placement de biomes.  
   - Placement de POI (villes, ruines, sanctuaires, etc.).

3. **Esquisse des factions**
   - Définition de quelques factions majeures de base.  
   - Attitudes simples (ami/neutre/hostile).

## Phase 3 – Factions & crises

1. **Système de développement des factions**
   - Voies magiques / technologiques / hybrides.  
   - Bâtiments = paliers d’avancées.

2. **Crises de niveau 1–5**
   - Implémentation d’arbres d’événements majeurs.  
   - Conséquences visibles sur le monde (biomes, villes, routes).

3. **Persistance entre runs**
   - Sauvegarde de l’état du monde.  
   - Nouveau run basé sur le monde “hérité” du précédent.

## Phase 4 – Profondeur tactique & meta

1. **Pouvoirs du général**
   - Pouvoir race / classe / artefacts.  
   - Charges, cooldowns, synergies avec l’armée.

2. **Logistique avancée**
   - Nourriture, or, chariots, montures.  
   - Impact sur moral, repos, déplacement.

3. **Équilibrage & IA**
   - Auto-simulations de combats.  
   - Ajustements des unités, pouvoirs, factions.

