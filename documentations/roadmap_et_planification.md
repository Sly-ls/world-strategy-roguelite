# World Strategy Roguelite — Roadmap (v2) + Planification hebdomadaire

> Basé sur l’implémentation présente dans le zip fourni et sur la roadmap historique (Phase 1/2).  
> **Budget** : 1 “semaine” = **4 à 8h** de travail.

---

## Légende

- ✅ **Fait + branché** (utilisable depuis la boucle de jeu)
- 🧩 **Fait mais surtout backend/tests** (pas encore “visible”/branché)
- 🚧 **Partiel / dette technique / incohérences**
- ⬜ **À faire**

---

## Résumé de l’état actuel

### Déjà jouable / visible
- ✅ **WorldMap** jouable (déplacement, obstacles, caméra, path)
- ✅ **Temps** (jours/phases/saisons + affichage)
- ✅ **Armée** : grille **3×5**, drag & drop, stats unitaires
- ✅ **Combat prototype** : résolution + retour worldmap avec pertes
- ✅ **POI/Events** : EventPanel + handlers (ville/sanctuaire/ruines) déclenchant combat / parfois quête

### Très avancé mais pas encore “dans la boucle”
- 🧩 **Quêtes** : QuestManager + QuestPool + générateur + journal/UI (une partie branchée, beaucoup validé via tests)
- 🧩 **Simulation monde** : arcs, coalitions, traités, pression domestique, knowledge/rumors, reward economy, etc. (gros volume de tests)

---

# Roadmap révisée

## 0) Stabilisation / dette technique (priorité)
- 🚧 **Unifier économie & inventaire**
  - Aujourd’hui : `Inventory` (gold/food/artifacts) + `ResourceManager` (global) + appels parfois à des méthodes inexistantes côté `WorldState`.
  - Objectif : **1 source de vérité** + API claire (`add_gold`, `spend_gold`, etc.) + UI branchée.
- 🚧 **Nettoyer/aligner l’API `WorldState` + time/tick**
  - Clarifier `current_day` vs `day`, qui tick quoi, et quels signaux sont émis.
- 🚧 **Refactor POI handlers**
  - Harmoniser `execute_choice` / `execute_choice_new`, ids, et effets réels.
- 🚧 **Normaliser les data assets**
  - Éviter doublons/variantes de `.tres`, noms incohérents, ressources “fantômes”.

**Sortie attendue** : une base stable où chaque action a un effet réel, et où la progression temporelle déclenche toujours les bons systèmes.

---

## 1) Phase 1 — Prototype jouable (déjà fait)
- ✅ World map minimale (déplacement + obstacles)
- ✅ Temps (jours/phases/saisons)
- ✅ Armée + UI (drag/drop, PV, moral)
- ✅ Combat prototype + intégration worldmap ↔ combat

---

## 2) Phase 2 — Monde vivant & POI (partiellement fait)
- ✅ Système d’événements POI (ville/sanctuaire/ruines)
- ⬜ Commerce (achat/vente, prix, stocks)
- ⬜ Dialogues / narration (texte, choix, conséquences)
- ⬜ Génération procédurale worldmap (biomes, placement POI, routes)
- ⬜ Logistique (consommation nourriture, fatigue, entretien, impact moral)

---

## 3) Phase 3 — Quêtes procédurales “tiered” (backend très avancé, intégration à terminer)

### 3.1 Offers / Contrats visibles en jeu
- 🧩 Génération d’offres (QuestPool) existe
- ⬜ UI “Offres disponibles”
  - liste, filtres (tier, faction, distance), expiration, limite d’offres
- ⬜ Accept/Decline
  - prise de quête, suppression/refresh d’offre, timers

### 3.2 Objectifs matérialisés sur la map
- ⬜ Marqueurs/POI temporaires créés par les quêtes
- ⬜ Suivi de progression “en jouant” (pas seulement tests/sim)

### 3.3 Résolution & impacts monde
- 🧩 Beaucoup de logique de résolution existe
- ⬜ Effets visibles sur worldmap
  - spawn/suppression POI, relations, économie, armées, état de région

### 3.4 Brancher la simulation au temps in-game
- 🧩 Sim monde existe
- ⬜ Le tick “jour” appelle réellement les runners/managers
- ⬜ Les conséquences deviennent visibles (raids → armées ennemies, trêve → blocage hostilités, etc.)

---

## 4) Phase 4 — IA stratégique & armées vivantes
- ⬜ Armées ennemies sur la worldmap (déplacement, patrouilles, raids, sièges)
- ⬜ Conflits faction vs faction visibles
- ⬜ Interactions joueur ↔ conflits (interception, escorte, sabotage, médiation)

---

## 5) Phase 5 — Persistance & roguelite
- ⬜ Save/Load run (WorldState, quêtes, factions, POIs dynamiques, inventaires)
- ⬜ Meta-progression (déblocages entre runs)
- ⬜ Setup de run (seed, génération départ)

---

## 6) Phase 6 — Polish & contenu
- ⬜ UI/UX (tooltips, feedback, journal, filtres, logs)
- ⬜ Équilibrage (combat/économie/cadence événements)
- ⬜ Audio/visuel, perf worldmap, packaging

---

## Prochain jalon recommandé (le plus rentable)
**Boucle quotidienne complète visible**
1) avancer le temps →  
2) tick simulation (factions/crises/offers) →  
3) UI affiche des offers →  
4) joueur accepte une quête →  
5) la quête spawn des objectifs sur la map →  
6) résolution applique un effet visible (relations + POI/armée/etc.)

---

# Planification détaillée (par semaine, 4–8h)

> Format : **Objectif** → **Tâches** → **Définition de “fait”**  
> Chaque semaine doit idéalement aboutir à un commit “mergeable”.

---

## Semaine 1 — Audit + instrumentation (4–6h)
**Objectif** : Avoir une vision claire de ce qui est branché, et détecter rapidement les régressions.

**Tâches**
- Lister les scènes d’entrée (main), autoloads, et le flux worldmap → events → combat → retour.
- Ajouter un mini panneau debug (ou logs structurés) : jour/phases, gold/food, quête active, nombre d’offres.
- Identifier 10–20 “points de friction” (TODO/incohérences d’API, handlers qui appellent des méthodes inexistantes).

**Fait si**
- Un lancement “from scratch” affiche les infos clés.
- Un fichier `docs/dev_notes.md` contient la liste priorisée des frictions.

---

## Semaine 2 — Unifier économie & inventaire (6–8h)
**Objectif** : Une seule API fiable pour les ressources joueur.

**Tâches**
- Choisir **Inventory** comme source de vérité joueur (gold/food/artifacts).
- Créer une API stable (ex : `add_gold`, `spend_gold`, `add_food`, `consume_food`, etc.).
- Remplacer les appels incohérents (handlers/WorldState) par l’API unique.
- Mettre à jour l’UI d’affichage (si existante) pour utiliser cette source.

**Fait si**
- Aucun handler n’appelle une méthode “fantôme”.
- Les ressources évoluent correctement après 3–4 actions (POI/combat/repos).

---

## Semaine 3 — Nettoyage WorldState + signaux de tick (6–8h)
**Objectif** : un tick temporel clair qui peut déclencher la simulation.

**Tâches**
- Standardiser les champs (`day`, `phase`, `season`) + supprimer doublons (`current_day` vs `day`).
- Émettre des signaux (`day_advanced`, `phase_changed`) depuis un seul endroit.
- Ajouter un test/miniscène “Advance Day” pour valider l’ordre d’appel.

**Fait si**
- Avancer le temps déclenche toujours les signaux attendus.
- Les systèmes downstream peuvent s’abonner sans hacks.

---

## Semaine 4 — Refactor POI handlers (6–8h)
**Objectif** : les choix d’event sont cohérents et testables.

**Tâches**
- Fusionner/harmoniser `execute_choice` / `execute_choice_new`.
- Standardiser le format des choix (id, texte, prérequis, effets).
- Corriger 3 POI types (ville/sanctuaire/ruines) : effets réellement appliqués (gold, combat, quête, etc.).
- Ajouter un test simple par handler (ou une scène de test) pour 2–3 choix clés.

**Fait si**
- 3 POIs couvrent : (gain ressource), (déclenche combat), (propose une quête) sans bug.

---

## Semaine 5 — Brancher le tick simulation → génération d’offres (4–8h)
**Objectif** : à chaque jour (ou certains jours), la simulation produit des offres consultables.

**Tâches**
- Connecter `day_advanced` à un `SimOrchestrator` (ou équivalent).
- À chaque tick : produire/rafraîchir `QuestPool` (respect TTL, limite).
- Journaliser le nombre d’offres générées + source (faction/crise/etc.) si dispo.

**Fait si**
- Après 3 jours, la liste d’offres change et respecte les règles (TTL, max).

---

## Semaine 6 — UI “Offres disponibles” (6–8h)
**Objectif** : le joueur peut voir les offres, leur tier, expiration et conditions.

**Tâches**
- Écran/panneau Offres : liste scroll, détails à droite (ou tooltip).
- Affichage : tier, faction, récompenses, expiration (jours restants), difficulté/risque si dispo.
- Boutons : “Accepter”, “Refuser”, “Suivre”.

**Fait si**
- Le joueur peut ouvrir l’UI, parcourir 10 offres, et en accepter 1.

---

## Semaine 7 — Accept/Decline + cycle d’une quête (4–8h)
**Objectif** : accepter une offre crée une quête active et met à jour le journal.

**Tâches**
- Sur “Accepter” : création d’instance de quête, ajout au journal, retrait de l’offre.
- Sur “Refuser” : retrait + éventuellement remplacement/rafraîchissement.
- Expiration : offre qui dépasse TTL disparaît proprement.

**Fait si**
- Une quête “Active” apparaît dans le journal et survit à un changement de scène (worldmap/combat).

---

## Semaine 8 — Marqueurs d’objectifs sur la worldmap (6–8h)
**Objectif** : une quête crée des objectifs atteignables “en jouant”.

**Tâches**
- Définir un modèle de “QuestObjectiveMarker” (POI temporaire ou icône).
- Spawn à une position valide (tile walkable, distance raisonnable, évite obstacles).
- Interaction : entrer sur le marker → déclencher event/étape de quête.

**Fait si**
- Accepter une quête spawn au moins 1 marker visible sur la map.
- Entrer dessus fait progresser la quête (au moins 1 étape).

---

## Semaine 9 — Résolution + récompenses + effets minimaux (6–8h)
**Objectif** : finir une quête et voir un impact.

**Tâches**
- Implémenter 1–2 templates “MVP” : ex. “Clear Ruins”, “Escort to Town”.
- Récompenses : gold/food/artifact appliqués via l’API inventaire unifiée.
- Effets monde minimaux : relation faction +/-, spawn/suppression d’un POI simple.

**Fait si**
- Une quête complète : journal passe en “Completed”, récompense reçue, effet visible sur map.

---

## Semaine 10 — Rendre visibles 1–2 conséquences de la simulation (4–8h)
**Objectif** : relier au moins une crise/arc à un résultat worldmap.

**Tâches**
- Choisir 1 conséquence simple : ex. “Raid” → spawn d’une armée ennemie (statique) OU “Corruption” → POI “Corrupted”.
- Ajout d’un message/log de monde (“News”) côté UI.
- Nettoyage/expiration : conséquence disparaît après X jours.

**Fait si**
- Après quelques jours, un événement “monde” apparaît sans intervention du joueur.

---

## Semaine 11 — Save/Load minimal (6–8h)
**Objectif** : pouvoir reprendre une run avec quêtes/ressources/temps.

**Tâches**
- Sérialiser : temps, inventaire, quêtes actives, offers, POIs temporaires, seed.
- Load : restauration et re-spawn des markers/POIs temporaires.
- Ajouter un bouton debug “Save/Load” (temporaire).

**Fait si**
- Tu peux sauvegarder, quitter, relancer, recharger et retrouver : jour + inventaire + quête active + marker.

---

## Semaine 12 — Polish MVP + dette (4–8h)
**Objectif** : rendre la boucle quotidienne agréable et robuste.

**Tâches**
- Tooltips / détails (récompenses, risques, faction).
- Corrections bugs (edge cases : marker inaccessible, offre expirée acceptée, etc.).
- Pass “cleanup” sur logs + suppression des hacks temporaires.

**Fait si**
- Une session de 15–20 minutes se déroule sans blocage majeur et avec feedback clair.

---

# Backlog (après MVP)

## Combat & progression
- Équilibrage stats / perks / progression unités
- Variantes d’ennemis, terrains, traits

## Monde vivant
- Armées mobiles, patrouilles, sièges
- Diplomatie visible + interactions joueur (médiation/sabotage)

## Roguelite
- Meta progression, déblocages, “starting loadouts”
- Seeds / world gen plus riche

## Contenu
- Tiers 3–5 plus narratifs (trahison, coalition, traités complexes)
- Dialogues + écriture + événements rares

---

## Notes d’implémentation (raccourcis conseillés)
- Toujours privilégier une implémentation “MVP visible” (un template de quête jouable) avant d’élargir.
- Garder les systèmes avancés existants, mais **les brancher progressivement** via 1 conséquence visible à la fois.
