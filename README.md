# World Strategy Roguelite – Documentation

Bienvenue dans le dépôt du projet **World Strategy Roguelite**, un jeu de stratégie roguelite se déroulant dans un monde vivant, persistant et systémique.

Ce README sert de point d’entrée et regroupe toute la documentation de game design.

---

## 📚 Sommaire – Game Design Document

Tous les fichiers se trouvent dans :  
**`game_design_doc/`**

### 1. Vision générale
👉 [01_vision_generale.md](game_design_doc/01_vision_generale.md)

### 2. Boucle de jeu
👉 [02_boucle_de_jeu.md](game_design_doc/02_boucle_de_jeu.md)

### 3. Monde & biomes
👉 [03_monde_et_biomes.md](game_design_doc/03_monde_et_biomes.md)

### 4. Factions
👉 [04_factions.md](game_design_doc/04_factions.md)

### 5. Système de temps
👉 [05_temps_et_cycle.md](game_design_doc/05_temps_et_cycle.md)

### 6. Déplacement & world map
👉 [06_worldmap_deplacement.md](game_design_doc/06_worldmap_deplacement.md)

### 7. Armée & ressources
👉 [07_armee_et_ressources.md](game_design_doc/07_armee_et_ressources.md)

### 8. Combat tactique
👉 [08_combat_systeme.md](game_design_doc/08_combat_systeme.md)

### 9. Événements & crises
👉 [09_evenements_crises.md](game_design_doc/09_evenements_crises.md)

### 10. Roadmap développement
👉 [10_roadmap_dev.md](game_design_doc/10_roadmap_dev.md)

---

## 🎮 État actuel du projet

Le prototype inclut déjà :

- Déplacement sur la world map  
- Système de temps (saisons, phases du jour)  
- Armée + UI  
- Repos avec consommation de temps  
- Combat tactique (3×5, front/renforts, phases distance/CàC/magie)  
- Transition WorldMap → Combat → retour  
- Événements de base (ville, sanctuaire, ruines)  

---

## 🛠 Technologies

- **Godot 4.5.1** (Forward+)  
- GDScript  
- Système modulaire basé sur scripts et autoLoad  

---

## 🧭 Organisation du code

- `/scenes/WorldMap/` – world map + UI + POI  
- `/scenes/Combat/` – système de combat  
- `/scripts/` – logique gameplay  
- `/game_design_doc/` – documents de conception  

---

Si tu veux, je peux aussi te générer une **image UML des fichiers**, un **schéma du combat**, ou un **diagramme du cycle du temps** pour ajouter au README.
