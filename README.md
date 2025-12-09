# World Strategy Roguelite – Documentation

Bienvenue dans le dépôt du projet **World Strategy Roguelite**, un jeu de stratégie roguelite se déroulant dans un monde vivant, persistant et systémique.

Ce README sert de point d’entrée et regroupe toute la documentation de game design.

---

## 📚 Sommaire – Game Design Document

Tous les fichiers se trouvent dans :  
**`game_design_doc/`**

### 1. Vision générale
👉 [01 vision generale](game_design_doc/01_vision_generale.md)

### 2. Boucle de jeu
👉 [02 boucle de jeu](game_design_doc/02_boucle_de_jeu.md)

### 3. Monde & biomes
👉 [03 monde et biomes](game_design_doc/03_monde_et_biomes.md)

### 4. Factions
👉 [04 factions](game_design_doc/04_factions.md)

### 5. Système de temps
👉 [05 temps et cycle](game_design_doc/05_temps_et_cycle.md)

### 6. Déplacement & world map
👉 [06 worldmap deplacement](game_design_doc/06_worldmap_deplacement.md)

### 7. Armée & ressources
👉 [07 armee et ressources](game_design_doc/07_armee_et_ressources.md)

### 8. Combat tactique
👉 [08 combat systeme](game_design_doc/08_combat_systeme.md)

### 9. Événements & crises
👉 [09 evenements crises](game_design_doc/09_evenements_crises.md)

### 10. Roadmap développement
👉 [10 roadmap dev](game_design_doc/10_roadmap_dev.md)

---
### 📁 Documentation des quetes

description du système de quete implémenté (08/12/2025) :

👉 **[Overview](documentation/VUE_FONCTIONNELLE_QUETES_CAMPAGNES.md)**

👉 **[Details](documentation/VUE_FONCTIONNELLE_QUETES_CAMPAGNES_detailed.md)**

👉 **[Quest System](documentation/QuestSystem.md)**

👉 **[Guide de dev](documentation/GUIDE_DEVELOPPEMENT_QUETES.md)**

👉 **[Next steps](documentation/RAF.md)**

---
### 📁 Documentation complémentaire (archives & exhaustives)

Une partie des documents de conception exhaustives et exploratoires est conservée dans le dossier :

👉 **[readme_2.md](README_2.md)**

Ce dossier contient les versions discuté avec ChatGPT et détaillées.

Ces documents servent de **référence** et permettent de retracer l’évolution du projet.


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
