# Guide de Développement : Système de Quêtes et Campagnes
## État des lieux et Guide Pratique

---

## Table des Matières

1. [Inventaire détaillé de l'implémentation](#1-inventaire-détaillé-de-limplémentation)
2. [Guide du développeur](#2-guide-du-développeur)
3. [Troubleshooting et problèmes connus](#3-troubleshooting-et-problèmes-connus)
4. [Architecture décisionnelle](#4-architecture-décisionnelle)

---

## 1. Inventaire détaillé de l'implémentation

Cette section fait l'état des lieux **réel** de ce qui est implémenté dans le projet, classe par classe, méthode par méthode.

### Légende
- ✅ **Implémenté et testé** : Fonctionne correctement en production
- 🚧 **En cours / Partiel** : Implémenté mais incomplet ou nécessite des améliorations
- ❌ **Non implémenté** : Existe dans la conception mais pas dans le code
- ⚠️ **Problématique** : Implémenté mais bugué ou instable
- 🔄 **À refactorer** : Fonctionne mais le code doit être réécrit

---

### 1.1 QuestTypes (Autoload)

**Fichier** : `src/quests/quest_types.gd`

**État global** : ✅ 100% implémenté

| Élément | État | Notes |
|---------|------|-------|
| Enum `Tier` | ✅ | 5 tiers définis |
| Enum `Category` | ✅ | 8 catégories |
| Enum `Status` | ✅ | 6 états de quête |
| Enum `ObjectiveType` | ✅ | 9 types d'objectifs |
| Enum `RewardType` | ✅ | 7 types de récompenses |
| `get_tier_name()` | ✅ | Retourne nom lisible |
| `get_category_icon()` | ✅ | Retourne chemin d'icône |
| `is_combat_category()` | ✅ | Helper pour catégories de combat |
| `get_status_color()` | ❌ | Pas implémenté |

**Problèmes connus** :
- Aucun

**À faire** :
- Ajouter `get_status_color()` pour UI
- Ajouter `get_objective_icon()` similaire à `get_category_icon()`

---

### 1.2 QuestTemplate (Resource)

**Fichier** : `src/quests/quest_template.gd`

**État global** : ✅ 95% implémenté

| Méthode | État | Notes |
|---------|------|-------|
| Propriétés `@export` | ✅ | Toutes présentes |
| `add_objective()` | ✅ | Fonctionne |
| `add_reward()` | ✅ | Fonctionne |
| `check_availability()` | ✅ | Délègue à QuestConditions |
| `can_repeat()` | ✅ | Gère cooldown |
| `create_instance()` | ✅ | Crée QuestInstance |
| `duplicate_template()` | ✅ | Pour génération procédurale |
| `estimate_difficulty()` | 🚧 | Algorithme basique, peut être amélioré |
| `validate()` | ✅ | Vérifie intégrité du template |

**Problèmes connus** :
- ⚠️ `estimate_difficulty()` ne prend pas en compte la complexité des conditions
- Les templates avec `time_limit = 0` sont traités comme "pas de limite" au lieu de "instantané"

**À faire** :
- Améliorer l'algorithme de `estimate_difficulty()` pour inclure les conditions
- Ajouter méthode `get_estimated_duration()` en nombre de tours/jours

---

### 1.3 QuestInstance (RefCounted)

**Fichier** : `src/quests/quest_instance.gd`

**État global** : ✅ 90% implémenté

| Méthode | État | Notes |
|---------|------|-------|
| `initialize_objectives()` | ✅ | Appelé à la création |
| `update_objective()` | ✅ | Progression d'objectif |
| `complete_objective()` | ✅ | Marque objectif complété |
| `check_completion()` | ✅ | Vérifie tous objectifs |
| `complete_quest()` | ✅ | Marque quête complétée |
| `fail_quest()` | ✅ | Marque quête échouée |
| `check_expiry()` | ✅ | Vérifie expiration |
| `get_overall_progress()` | ✅ | Retourne 0.0-1.0 |
| `get_days_remaining()` | ✅ | Calcule temps restant |
| `log_event()` | ✅ | Ajoute événement au journal |
| `get_status_summary()` | ✅ | Génère résumé texte |
| `save_to_dict()` | 🚧 | Basique, manque events |
| `load_from_dict()` | 🚧 | Basique, manque reconstruction signaux |

**Problèmes connus** :
- ⚠️ Les signaux ne sont pas reconnectés après `load_from_dict()`
- Le journal `events` n'est pas sauvegardé dans `save_to_dict()`

**À faire** :
- Compléter `save_to_dict()` pour inclure le journal d'événements
- Ajouter méthode `reconnect_signals()` appelée après chargement
- Ajouter validation dans `update_objective()` pour éviter progression négative

---

### 1.4 ObjectiveData (Resource)

**Fichier** : `src/quests/objective_data.gd`

**État global** : ✅ 85% implémenté

| Méthode | État | Notes |
|---------|------|-------|
| Propriétés | ✅ | Complètes |
| `get_required_count()` | ✅ | Pour tous types |
| `get_display_description()` | ✅ | Génération auto |
| `matches_event()` | 🚧 | Seulement 5 types sur 9 implémentés |

**Problèmes connus** :
- ❌ `matches_event()` ne gère pas `SURVIVE`, `CONTROL`, `NEGOTIATE`, `DESTROY`
- La génération automatique de description ne gère pas bien les pluriels

**À faire** :
- Compléter `matches_event()` pour tous les types d'objectifs
- Améliorer la génération de descriptions (gestion pluriels, articles)
- Ajouter méthode `get_icon()` pour affichage UI

---

### 1.5 RewardData (Resource)

**Fichier** : `src/quests/reward_data.gd`

**État global** : ✅ 90% implémenté

| Méthode | État | Notes |
|---------|------|-------|
| Propriétés | ✅ | Complètes |
| `apply_reward()` | ✅ | Tous types implémentés |
| `get_display_text()` | ✅ | Génération lisible |
| `estimate_value()` | ✅ | Pour balancing |

**Problèmes connus** :
- ⚠️ `apply_reward()` pour type `ITEMS` ne vérifie pas si l'inventaire est plein
- La récompense `TERRITORY` ne vérifie pas si la région est déjà possédée

**À faire** :
- Ajouter gestion des erreurs dans `apply_reward()` (inventaire plein, etc.)
- Ajouter méthode `can_apply()` pour validation avant application
- Logger les récompenses appliquées pour analytics

---

### 1.6 QuestConditions (Resource)

**Fichier** : `src/quests/quest_conditions.gd`

**État global** : ✅ 95% implémenté

| Méthode | État | Notes |
|---------|------|-------|
| Toutes propriétés | ✅ | Complètes |
| `check_conditions()` | ✅ | Orchestrateur principal |
| `check_temporal_conditions()` | ✅ | Jour et saison |
| `check_tag_conditions()` | ✅ | ET/OU logiques |
| `check_faction_conditions()` | ✅ | Réputation et guerres |
| `check_progression_conditions()` | ✅ | Quêtes et niveau |
| `check_geographic_conditions()` | ✅ | Régions |
| `get_unmet_conditions_text()` | 🚧 | Incomplet pour géographie |

**Problèmes connus** :
- `required_season` utilise un int (0-3) mais WorldGameState retourne parfois un String
- `get_unmet_conditions_text()` ne liste pas toutes les conditions géographiques

**À faire** :
- Uniformiser le type de `required_season` (int ou String)
- Compléter `get_unmet_conditions_text()` pour toutes les conditions
- Ajouter méthode `get_unlock_progress()` qui retourne un pourcentage

---

### 1.7 QuestManager (Autoload)

**Fichier** : `src/quests/quest_manager.gd`

**État global** : ✅ 85% implémenté

| Méthode | État | Notes |
|---------|------|-------|
| **Initialisation** |
| `_ready()` | ✅ | Connecte tous les signaux |
| `load_quest_templates()` | ✅ | Charge depuis data/ |
| **Enregistrement** |
| `register_quest()` | ✅ | Ajoute au registre |
| `unregister_quest()` | ✅ | Retire du registre |
| **Disponibilité** |
| `check_quest_availability()` | ✅ | Vérifie conditions |
| `refresh_available_quests()` | ✅ | Parcourt tous templates |
| **Démarrage** |
| `start_quest()` | ✅ | Démarre instance |
| `cancel_quest()` | ✅ | Annule quête active |
| **Progression** |
| `update_quest_objective()` | ✅ | Met à jour objectif |
| `notify_event()` | ✅ | Notifie événement gameplay |
| **Complétion** |
| `_on_quest_completed_internal()` | ✅ | Gère complétion |
| `_on_quest_failed_internal()` | ✅ | Gère échec |
| `apply_quest_rewards()` | ✅ | Applique récompenses |
| **Événements externes** |
| `_on_day_advanced()` | ✅ | Vérifie expirations |
| `_on_combat_ended()` | ✅ | Notifie défaites |
| `_on_location_reached()` | ✅ | Notifie arrivée |
| `_on_item_collected()` | ❌ | Pas implémenté |
| `_on_negotiation_completed()` | ❌ | Pas implémenté |
| **Requêtes** |
| `get_active_quest()` | ✅ | Retourne instance |
| `get_all_active_quests()` | ✅ | Retourne array |
| `get_available_quests()` | ✅ | Retourne templates |
| `get_quest_template()` | ✅ | Retourne template |
| `is_quest_completed()` | ✅ | Vérifie historique |
| `is_quest_active()` | ✅ | Vérifie actives |
| `get_completion_count()` | ✅ | Compte répétitions |
| `get_statistics()` | ✅ | Stats globales |
| **Sauvegarde** |
| `save_state()` | 🚧 | Basique, manque metadata |
| `load_state()` | 🚧 | Fonctionne mais pas robuste |

**Problèmes connus** :
- ⚠️ **Bug majeur** : `refresh_available_quests()` est appelé à chaque frame si beaucoup de quêtes → lag
- ⚠️ Les signaux de QuestInstance ne sont pas déconnectés quand la quête est complétée → fuite mémoire
- `load_quest_templates()` ne gère pas les sous-dossiers récursivement
- Le maximum de 10 quêtes actives n'est pas configurable

**À faire** :
- **URGENT** : Optimiser `refresh_available_quests()` avec cache et dirty flag
- **URGENT** : Déconnecter les signaux dans `_on_quest_completed_internal()` et `_on_quest_failed_internal()`
- Rendre `MAX_ACTIVE_QUESTS` configurable via settings
- Ajouter méthode `get_quest_by_tag()` pour filtrage
- Implémenter `_on_item_collected()` et `_on_negotiation_completed()`

---

### 1.8 QuestChain (Resource)

**Fichier** : `src/quests/campaigns/quest_chain.gd`

**État global** : ✅ 80% implémenté

| Méthode | État | Notes |
|---------|------|-------|
| Propriétés | ✅ | Complètes |
| `start_chain()` | ✅ | Initialise |
| `get_current_quest_id()` | ✅ | Retourne ID actuel |
| `get_remaining_quest_ids()` | ✅ | Liste restante |
| `advance()` | ✅ | Passe à la suivante |
| `complete_chain()` | ✅ | Termine la chaîne |
| `fail_chain()` | ✅ | Échoue la chaîne |
| `get_progress()` | ✅ | Progression 0-1 |
| `get_current_difficulty()` | ✅ | Difficulté actuelle |
| `contains_quest()` | ✅ | Vérifie appartenance |
| `duplicate_chain()` | ✅ | Clone pour génération |

**Problèmes connus** :
- Aucune gestion d'échec de quête individuelle → toute la chaîne échoue
- Pas de possibilité de "sauter" une quête optionnelle
- Les signaux ne sont pas tous émis correctement

**À faire** :
- Ajouter support pour quêtes optionnelles dans la chaîne
- Ajouter méthode `can_skip_quest()` pour quêtes non-critiques
- Émettre signal `quest_skipped` quand approprié

---

### 1.9 CampaignManager (Autoload)

**Fichier** : `src/quests/campaigns/campaign_manager.gd`

**État global** : 🚧 60% implémenté

| Méthode | État | Notes |
|---------|------|-------|
| **Initialisation** |
| `_ready()` | ✅ | Charge campagnes |
| `load_narrative_campaigns()` | ✅ | Depuis data/ |
| **Chaînes (Tier 2-3)** |
| `generate_quest_chain()` | 🚧 | Basique, génération simpliste |
| `start_chain()` | ✅ | Démarre chaîne |
| `advance_chain()` | ✅ | Avance après complétion |
| `get_chain_for_quest()` | ✅ | Trouve chaîne d'une quête |
| `is_chain_quest()` | ✅ | Vérifie appartenance |
| **Campagnes narratives (Tier 4)** |
| `start_narrative_campaign()` | ✅ | Démarre campagne |
| `check_campaign_unlock()` | ✅ | Vérifie conditions |
| `get_available_campaigns()` | ✅ | Liste disponibles |
| `is_campaign_active()` | ✅ | Vérifie active |
| `get_active_campaign()` | ✅ | Retourne instance |
| **Événements** |
| `_on_quest_completed()` | ✅ | Avance chaînes/campagnes |
| `_on_chain_completed()` | ✅ | Nettoie |
| `_on_chain_failed()` | ✅ | Nettoie |
| `_on_campaign_chapter_completed()` | ✅ | Démarre chapitre suivant |
| `_on_campaign_completed()` | ✅ | Applique impacts |
| `_on_day_advanced()` | ❌ | Vide |
| **Sauvegarde** |
| `save_state()` | 🚧 | Basique |
| `load_state()` | ❌ | TODO commenté |

**Problèmes connus** :
- ⚠️ **Bug critique** : `generate_quest_chain()` ne fonctionne pas réellement car `QuestGenerator` n'est pas implémenté
- `load_state()` est complètement vide → impossible de restaurer les campagnes
- Pas de tracking des campagnes complétées (contrairement aux quêtes)
- `_on_day_advanced()` ne fait rien → campagnes ne peuvent pas expirer

**À faire** :
- **URGENT** : Implémenter `QuestGenerator` ou remplacer par système de templates
- **URGENT** : Implémenter `load_state()` complet
- Ajouter historique `completed_campaigns: Dictionary`
- Implémenter logique dans `_on_day_advanced()` pour campagnes à durée limitée

---

### 1.10 FactionCampaign (Resource)

**Fichier** : `src/quests/campaigns/faction_campaign.gd`

**État global** : ✅ 90% implémenté

| Méthode | État | Notes |
|---------|------|-------|
| Propriétés | ✅ | Complètes |
| `start_campaign()` | ✅ | Initialise |
| `get_current_chapter()` | ✅ | Retourne ChapterData |
| `get_current_chapter_quest_ids()` | ✅ | Liste quêtes |
| `is_quest_in_current_chapter()` | ✅ | Vérifie appartenance |
| `on_quest_completed()` | ✅ | Vérifie complétion chapitre |
| `complete_chapter()` | ✅ | Termine chapitre |
| `advance_chapter()` | ✅ | Passe au suivant |
| `complete_campaign()` | ✅ | Termine campagne |
| `get_progress()` | ✅ | Progression 0-1 |
| `check_unlock_conditions()` | 🚧 | Ne vérifie pas required_campaigns |
| `estimate_duration()` | ✅ | Compte quêtes totales |
| `save_state()` | ✅ | Sérialisation |
| `load_state()` | ✅ | Désérialisation |

**Problèmes connus** :
- `check_unlock_conditions()` ne vérifie pas `required_campaigns` car pas d'historique
- Pas de gestion de chapitres optionnels ou à branches multiples
- `world_impact` n'est appliqué qu'à la fin, pas progressivement

**À faire** :
- Ajouter historique des campagnes complétées dans CampaignManager
- Implémenter chapitres avec branches (choix A ou B)
- Permettre application progressive de `world_impact` par chapitre

---

### 1.11 ChapterData (Resource)

**Fichier** : `src/quests/campaigns/chapter_data.gd`

**État global** : ✅ 95% implémenté

| Méthode | État | Notes |
|---------|------|-------|
| Propriétés | ✅ | Complètes |
| `mark_quest_completed()` | ✅ | Tracking interne |
| `check_completion()` | ✅ | 3 modes : all/any/count |
| `get_progress()` | ✅ | Progression 0-1 |
| `get_progress_text()` | ✅ | Texte lisible |

**Problèmes connus** :
- `completed_quest_ids` n'est jamais utilisé (on vérifie directement QuestManager)
- `next_chapter_conditions` existe mais n'est jamais évalué

**À faire** :
- Supprimer `completed_quest_ids` (redondant)
- Implémenter évaluation de `next_chapter_conditions` dans `check_completion()`

---

### 1.12 WorldCrisis (Resource)

**Fichier** : `src/world_events/world_crisis.gd`

**État global** : 🚧 70% implémenté

| Méthode | État | Notes |
|---------|------|-------|
| Propriétés | ✅ | Complètes |
| `start_crisis()` | ✅ | Initialise |
| `get_current_phase()` | ✅ | Retourne CrisisPhase |
| `get_current_phase_quests()` | ✅ | Liste quêtes |
| `add_contribution()` | ✅ | Ajoute points |
| `advance_phase()` | ✅ | Passe phase suivante |
| `resolve_crisis()` | ✅ | Termine crise |
| `check_time_failure()` | ✅ | Vérifie expiration |
| `get_days_remaining()` | ✅ | Temps restant |
| `get_contribution_progress()` | ✅ | Progression 0-1 |
| `get_top_contributors()` | ✅ | Classement |
| `save_state()` | ✅ | Sérialisation |
| `load_state()` | ✅ | Désérialisation |

**Problèmes connus** :
- Pas encore intégré avec le reste du système (WorldCrisis existe mais n'est jamais utilisé)
- Les `WorldEffect` ne sont pas implémentés

**À faire** :
- **Intégration** : Connecter WorldCrisis avec CrisisManager
- Implémenter la classe `WorldEffect`
- Tester le système de phases et contribution

---

### 1.13 CrisisPhase (Resource)

**Fichier** : `src/world_events/crisis_phase.gd`

**État global** : 🚧 50% implémenté

| Méthode | État | Notes |
|---------|------|-------|
| Propriétés | ✅ | Complètes |
| `start_phase()` | 🚧 | Squelette présent, pas de vraie logique |
| `end_phase()` | 🚧 | Squelette présent, pas de vraie logique |

**Problèmes connus** :
- Les événements (`phase_start_events`, `phase_end_events`) ne sont pas vraiment déclenchés
- Les `phase_effects` ne font rien car `WorldEffect` n'existe pas

**À faire** :
- Implémenter vraiment `start_phase()` et `end_phase()`
- Créer la classe `WorldEffect`
- Tester les transitions de phases

---

### 1.14 CrisisManager (Autoload)

**Fichier** : `src/world_events/crisis_manager.gd`

**État global** : 🚧 40% implémenté

| Méthode | État | Notes |
|---------|------|-------|
| **Initialisation** |
| `_ready()` | 🚧 | Basique |
| `load_crisis_definitions()` | 🚧 | Structure présente |
| **Déclenchement** |
| `trigger_crisis()` | 🚧 | Squelette fonctionnel |
| `trigger_random_crisis()` | ❌ | Pas implémenté |
| **Contribution** |
| `add_contribution()` | 🚧 | Basique |
| `check_contribution_milestones()` | ❌ | Vide |
| **Phases** |
| `advance_phase()` | 🚧 | Squelette |
| **Événements** |
| `_on_day_advanced()` | 🚧 | Logique partielle |
| `_on_quest_completed()` | 🚧 | Contribution automatique |
| Autres handlers | ❌ | Vides |
| **Requêtes** |
| `get_active_crisis()` | ✅ | Simple getter |
| `has_active_crisis()` | ✅ | Simple check |
| `get_crisis_stats()` | ✅ | Retourne dict |
| **Sauvegarde** |
| `save_state()` | 🚧 | Basique |
| `load_state()` | ❌ | TODO |

**Problèmes connus** :
- ⚠️ **Système non utilisé** : CrisisManager existe mais n'est jamais appelé dans le jeu
- La plupart des méthodes sont des squelettes vides
- Pas de tests

**À faire** :
- **Phase 1** : Finir l'implémentation basique
- **Phase 2** : Intégrer avec le reste du système
- **Phase 3** : Créer une crise de test et la tester en jeu

---

### 1.15 Classes manquantes ou partielles

| Classe | État | Localisation prévue | Priorité |
|--------|------|---------------------|----------|
| `QuestGenerator` | ❌ | `src/quests/generation/` | **Haute** |
| `QuestPool` | ❌ | `src/quests/generation/` | **Haute** |
| `NameGenerator` | ❌ | `src/quests/generation/` | Moyenne |
| `WorldEffect` | ❌ | `src/world_events/` | **Haute** |
| `WorldImpact` | ❌ | `src/quests/campaigns/` | **Haute** |
| `QuestEvent` | ❌ | `src/quests/` | Basse |
| `Faction` | ✅ | `src/factions/` | N/A |
| `FactionManager` | ✅ | `src/factions/` | N/A |

---

## 2. Guide du développeur

Cette section fournit des guides **pas-à-pas** pour les tâches courantes de développement sur le système de quêtes.

---

### 2.1 Comment ajouter une nouvelle quête simple (Tier 1)

#### Méthode 1 : Via l'éditeur Godot (Recommandé)

**Étape 1 : Créer le fichier ressource**

1. Dans l'éditeur Godot, naviguer vers `data/quests/tier1/`
2. Clic droit → **New Resource**
3. Chercher `QuestTemplate` dans la liste
4. Nommer le fichier (ex: `rescue_cat_from_tree.tres`)

**Étape 2 : Configurer les propriétés de base**

Dans l'inspecteur :

```
Quest Id: "rescue_cat_from_tree"
Tier: TIER_1
Category: RESCUE
Title: "Sauvetage Félin"
Description: "Un chat est coincé dans un arbre. Sa propriétaire vous supplie de l'aider."
Completion Text: "Le chat est sauvé ! La propriétaire vous remercie avec des larmes de joie."
```

**Étape 3 : Ajouter un objectif**

1. Dans l'inspecteur, sous `Objectives` → cliquer **[+]**
2. Cliquer sur le nouvel élément → cliquer sur `[empty]`
3. Choisir **New ObjectiveData**
4. Configurer :
   ```
   Type: REACH
   Description: "Grimper dans l'arbre et récupérer le chat"
   Parameters:
     location_id: "old_oak_tree"
     radius: 1
   Optional: false
   Hidden: false
   ```

**Étape 4 : Ajouter des récompenses**

1. Sous `Rewards` → cliquer **[+]**
2. **New RewardData**
3. Configurer :
   ```
   Type: GOLD
   Amount: 50
   Description: "Une petite somme en remerciement"
   ```

4. Ajouter une 2ème récompense (réputation) :
   ```
   Type: REPUTATION
   Amount: 10
   Parameters:
     faction_id: "village_locals"
   ```

**Étape 5 : Définir les conditions (optionnel)**

1. Sous `Conditions` → **New QuestConditions**
2. Configurer :
   ```
   Required Day: 3        # Disponible après le jour 3
   Required Player Tags: ["can_climb"]  # Le joueur doit savoir grimper
   Available Regions: ["village_center", "village_outskirts"]
   ```

**Étape 6 : Autres paramètres**

```
Time Limit: 7          # 7 jours pour compléter
Repeatable: false      # Ne peut être faite qu'une fois
Display Priority: 3    # Priorité d'affichage
Tags: ["rescue", "village", "easy", "cat"]
```

**Étape 7 : Sauvegarder**

- `Ctrl+S` ou menu **File → Save**
- La quête est maintenant prête !

**Étape 8 : Tester**

Lancer le jeu et vérifier :
- La quête apparaît-elle dans la liste des quêtes disponibles ?
- Les conditions fonctionnent-elles ?
- La complétion fonctionne-t-elle ?

---

#### Méthode 2 : Par code (pour génération programmatique)

```gdscript
# Dans un script (ex: quest_loader.gd)

func create_rescue_cat_quest() -> QuestTemplate:
    var quest = QuestTemplate.new()
    
    # Configuration de base
    quest.quest_id = "rescue_cat_from_tree"
    quest.tier = QuestTypes.Tier.TIER_1
    quest.category = QuestTypes.Category.RESCUE
    quest.title = "Sauvetage Félin"
    quest.description = "Un chat est coincé dans un arbre."
    quest.completion_text = "Le chat est sauvé !"
    
    # Objectif
    var obj = ObjectiveData.new()
    obj.type = QuestTypes.ObjectiveType.REACH
    obj.description = "Grimper dans l'arbre"
    obj.parameters = {
        "location_id": "old_oak_tree",
        "radius": 1
    }
    quest.objectives.append(obj)
    
    # Récompenses
    var gold = RewardData.new()
    gold.type = QuestTypes.RewardType.GOLD
    gold.amount = 50
    quest.rewards.append(gold)
    
    var rep = RewardData.new()
    rep.type = QuestTypes.RewardType.REPUTATION
    rep.amount = 10
    rep.parameters = {"faction_id": "village_locals"}
    quest.rewards.append(rep)
    
    # Conditions
    var cond = QuestConditions.new()
    cond.required_day = 3
    cond.required_player_tags = ["can_climb"]
    cond.available_regions = ["village_center"]
    quest.conditions = cond
    
    # Autres
    quest.time_limit = 7
    quest.repeatable = false
    quest.tags = ["rescue", "village", "easy"]
    
    # Sauvegarder (optionnel)
    ResourceSaver.save(quest, "res://data/quests/tier1/rescue_cat_from_tree.tres")
    
    return quest

# Utilisation
func _ready() -> void:
    var quest = create_rescue_cat_quest()
    QuestManager.register_quest(quest)
```

---

#### Checklist de validation

Avant de considérer la quête terminée, vérifier :

- [ ] Le `quest_id` est unique dans tout le projet
- [ ] Le `title` et `description` sont en français correct
- [ ] Au moins un `objective` est défini
- [ ] Au moins une `reward` est définie
- [ ] Si `conditions` est défini, les tags/régions existent dans le jeu
- [ ] Si `repeatable = true`, un `repeat_cooldown` est défini
- [ ] Les `tags` sont pertinents pour le filtrage
- [ ] La quête a été testée en jeu du début à la fin
- [ ] Le fichier .tres est sous contrôle de version (git)

---

### 2.2 Comment créer une campagne narrative (Tier 4)

#### Processus complet : Campagne "Rébellion des Mineurs"

**Contexte** : Les mineurs de fer se rebellent contre les taxes excessives de l'Empire. Le joueur peut choisir de les aider ou de les réprimer.

---

**Étape 1 : Planification sur papier**

Avant de toucher à Godot, dessiner la structure :

```
Campagne: "La Rébellion des Mineurs"
Faction: "miners_guild"
Unlock: réputation >= 30 avec miners_guild

Chapitre 1: "Les Doléances" (3 quêtes, toutes requises)
  - rencontrer le chef des mineurs
  - enquêter sur les taxes
  - collecter des preuves

Chapitre 2: "Choix de Camp" (2 quêtes, 1 seule requise)
  BRANCHE A: aider les mineurs
    - négocier avec l'Empire
    - organiser une manifestation pacifique
  BRANCHE B: réprimer la rébellion
    - arrêter les meneurs
    - envoyer des troupes

Chapitre 3: "Conséquences" (1 quête)
  - gérer les répercussions (adapté au choix du Ch.2)

Impact mondial:
  - Si branche A : relations +50 miners, -30 empire
  - Si branche B : relations -50 miners, +30 empire
```

---

**Étape 2 : Créer les quêtes individuelles d'abord**

Avant de créer la campagne, créer **toutes** les quêtes nécessaires dans `data/quests/tier4/miners_rebellion/` :

- `miners_meet_leader.tres`
- `miners_investigate_taxes.tres`
- `miners_collect_proofs.tres`
- `miners_negotiate_empire.tres`
- `miners_organize_protest.tres`
- `miners_arrest_leaders.tres`
- `miners_send_troops.tres`
- `miners_consequences_peace.tres`
- `miners_consequences_war.tres`

*(Suivre le guide 2.1 pour chaque quête)*

---

**Étape 3 : Créer le fichier de campagne**

1. `data/campaigns/faction_campaigns/` → Clic droit → **New Resource**
2. Chercher `FactionCampaign`
3. Nommer : `miners_rebellion.tres`

---

**Étape 4 : Configuration de base**

```
Campaign Id: "miners_rebellion"
Faction Id: "miners_guild"
Title: "La Rébellion des Mineurs"
Description: "Les mineurs de fer se soulèvent contre l'oppression. Choisirez-vous de les aider ou de les réprimer ?"
```

**Conditions de déverrouillage :**
```
Required Reputation: 30
Unlock Tags: ["knows_miners", "politically_active"]
Required Quests: ["visit_mining_town"]
```

---

**Étape 5 : Créer le Chapitre 1**

1. Sous `Chapters` → **[+]**
2. **New ChapterData**
3. Configurer :

```
Chapter Number: 1
Title: "Les Doléances"
Description: "Découvrez les raisons du mécontentement des mineurs."

Quest Ids: (ajouter 3 éléments)
  [0]: "miners_meet_leader"
  [1]: "miners_investigate_taxes"
  [2]: "miners_collect_proofs"

Completion Requirement: "all"  # Les 3 doivent être complétées

Rewards: (ajouter 1)
  - Type: REPUTATION
    Amount: 20
    Parameters: {"faction_id": "miners_guild"}
```

---

**Étape 6 : Créer le Chapitre 2 (avec branchement)**

```
Chapter Number: 2
Title: "Choix de Camp"
Description: "Le moment est venu de choisir votre camp dans ce conflit."

Quest Ids: (ajouter 4 éléments)
  [0]: "miners_negotiate_empire"        # Branche A
  [1]: "miners_organize_protest"         # Branche A
  [2]: "miners_arrest_leaders"           # Branche B
  [3]: "miners_send_troops"              # Branche B

Completion Requirement: "count"
Required Count: 2  # Il faut compléter 2 quêtes (soit A, soit B)

Rewards:
  - Type: GOLD
    Amount: 500
```

**Note** : Le joueur ne peut pas mélanger les branches car les quêtes de la branche A et B seront mutuellement exclusives (via conditions).

---

**Étape 7 : Créer le Chapitre 3**

```
Chapter Number: 3
Title: "Conséquences"
Description: "Faites face aux répercussions de vos choix."

Quest Ids: (ajouter 2 éléments)
  [0]: "miners_consequences_peace"   # Apparaît si branche A
  [1]: "miners_consequences_war"     # Apparaît si branche B

Completion Requirement: "any"  # L'une ou l'autre

Rewards:
  - Type: UNLOCK
    Parameters: {"unlock_type": "region", "unlock_id": "deep_mines"}
```

---

**Étape 8 : Définir l'impact mondial**

1. Sous `World Impact` → **New WorldImpact**
2. Configurer :

```
Unlock Regions: (ajouter 1)
  [0]: "deep_mines"

Change Faction States: (dictionnaire)
  "miners_guild": "autonomous"
  "empire_central": "weakened"

Add World Tags: (ajouter 2)
  [0]: "miners_free"
  [1]: "social_reform_era"

Trigger Events: (ajouter 1)
  [0]: "miners_independence_day"
```

---

**Étape 9 : Définir les relations de faction**

```
Faction Relations: (dictionnaire)
  "miners_guild": 100
  "empire_central": -50
  "merchant_guild": 20
  "village_locals": 30
```

---

**Étape 10 : Sauvegarder et tester**

1. Sauvegarder le fichier `.tres`
2. Lancer le jeu
3. Débloquer la campagne (cheat ou jouer normalement)
4. Tester **les deux branches** complètement

---

#### Checklist de validation

- [ ] Toutes les quêtes référencées existent dans `data/quests/`
- [ ] Les `quest_ids` dans les chapitres sont exacts (pas de typo)
- [ ] La logique de `completion_requirement` a du sens pour chaque chapitre
- [ ] L'impact mondial est cohérent avec l'histoire
- [ ] Les deux branches (si applicable) ont été testées
- [ ] Les transitions entre chapitres fonctionnent
- [ ] La campagne se termine proprement et applique l'impact
- [ ] Le fichier est versionné (git)

---

### 2.3 Comment déboguer une quête qui ne démarre pas

**Symptôme** : La quête n'apparaît pas dans la liste des quêtes disponibles.

---

#### Checklist de débogage (ordre de priorité)

**1. Vérifier que la quête est enregistrée**

```gdscript
# Dans la console de debug ou un script temporaire
func check_quest_registered(quest_id: String) -> void:
    if quest_id in QuestManager.quest_templates:
        print("✅ Quête enregistrée")
    else:
        print("❌ Quête NON enregistrée")
        print("Templates disponibles: ", QuestManager.quest_templates.keys())
```

**Solution si NON enregistrée** :
- Vérifier que le fichier `.tres` est dans `data/quests/tier1/` (ou tier2/tier3)
- Vérifier que `QuestManager.load_quest_templates()` inclut ce répertoire
- Appeler manuellement `QuestManager.register_quest(template)`

---

**2. Vérifier les conditions d'apparition**

```gdscript
func debug_quest_conditions(quest_id: String) -> void:
    var template = QuestManager.get_quest_template(quest_id)
    if not template:
        print("❌ Template introuvable")
        return
    
    if not template.conditions:
        print("✅ Pas de conditions → devrait être disponible")
        return
    
    var player_tags = WorldGameState.get_player_tags()
    var world_tags = WorldGameState.get_world_tags()
    var current_day = WorldGameState.current_day
    
    print("=== Vérification des conditions ===")
    print("Conditions de la quête:")
    print("  - Jour requis: ", template.conditions.required_day)
    print("  - Jour actuel: ", current_day)
    print("  - Tags joueur requis: ", template.conditions.required_player_tags)
    print("  - Tags joueur actuels: ", player_tags)
    print("  - Tags monde requis: ", template.conditions.required_world_tags)
    print("  - Tags monde actuels: ", world_tags)
    
    var result = template.check_availability(player_tags, world_tags, current_day)
    print("Résultat: ", "✅ DISPONIBLE" if result else "❌ BLOQUÉE")
    
    if not result:
        var unmet = template.conditions.get_unmet_conditions_text(player_tags, world_tags, current_day)
        print("Conditions non remplies:")
        for condition in unmet:
            print("  - ", condition)
```

**Solutions courantes** :
- **Jour trop tôt** : Avancer le temps ou réduire `required_day`
- **Tags manquants** : Ajouter les tags requis au joueur via `WorldGameState.add_player_tag()`
- **Réputation insuffisante** : Augmenter la réputation avec `FactionManager.add_reputation()`

---

**3. Vérifier qu'elle n'est pas déjà active ou complétée**

```gdscript
func check_quest_status(quest_id: String) -> void:
    if QuestManager.is_quest_active(quest_id):
        print("⚠️ Quête déjà ACTIVE")
        var instance = QuestManager.get_active_quest(quest_id)
        print("  Statut: ", QuestTypes.Status.keys()[instance.status])
        print("  Progression: %.0f%%" % (instance.get_overall_progress() * 100))
        return
    
    if QuestManager.is_quest_completed(quest_id):
        print("✅ Quête déjà COMPLETÉE")
        var template = QuestManager.get_quest_template(quest_id)
        if template.repeatable:
            print("  Répétable: OUI")
            if template.can_repeat(WorldGameState.current_day):
                print("  ✅ Peut être répétée maintenant")
            else:
                var days_left = template.repeat_cooldown - (WorldGameState.current_day - template.last_completed_day)
                print("  ❌ Cooldown: encore %d jours" % days_left)
        else:
            print("  Répétable: NON → ne peut plus apparaître")
        return
    
    print("❓ Quête ni active ni complétée")
```

---

**4. Forcer le rafraîchissement**

```gdscript
# Appeler manuellement
QuestManager.refresh_available_quests()
QuestManager.check_quest_availability("ma_quete_id")
```

---

**5. Logs de débogage utiles**

Ajouter temporairement dans `QuestManager.check_quest_availability()` :

```gdscript
func check_quest_availability(quest_id: String) -> bool:
    print("[DEBUG] Checking availability: ", quest_id)  # <-- AJOUTER
    
    if quest_id not in quest_templates:
        print("[DEBUG] ❌ Template not found")  # <-- AJOUTER
        return false
    
    var template = quest_templates[quest_id]
    
    if quest_id in active_quests:
        print("[DEBUG] ❌ Already active")  # <-- AJOUTER
        return false
    
    # ... etc
```

---

#### Cas particuliers

**Cas 1 : Quête de campagne qui ne démarre pas**

```gdscript
# Vérifier que la campagne est active
func debug_campaign_quest(quest_id: String) -> void:
    for campaign_id in CampaignManager.active_campaigns.keys():
        var campaign = CampaignManager.active_campaigns[campaign_id]
        var chapter_quests = campaign.get_current_chapter_quest_ids()
        if quest_id in chapter_quests:
            print("✅ Quête fait partie de la campagne: ", campaign_id)
            print("  Chapitre actuel: ", campaign.current_chapter + 1)
            return
    
    print("❌ Quête ne fait partie d'aucune campagne active")
```

---

**Cas 2 : Quête de crise qui n'apparaît pas**

```gdscript
# Vérifier qu'une crise est active
func debug_crisis_quest(quest_id: String) -> void:
    if not CrisisManager.has_active_crisis():
        print("❌ Aucune crise active")
        return
    
    var crisis = CrisisManager.get_active_crisis()
    var phase_quests = crisis.get_current_phase_quests()
    
    if quest_id in phase_quests:
        print("✅ Quête fait partie de la crise: ", crisis.crisis_id)
        print("  Phase: ", crisis.current_phase + 1, "/", crisis.phases.size())
    else:
        print("❌ Quête ne fait pas partie de la phase actuelle")
        print("  Quêtes attendues: ", phase_quests)
```

---

### 2.4 Comment suivre la progression d'une quête

Il existe plusieurs façons de tracker la progression selon le contexte.

---

#### Méthode 1 : Via les signaux (Recommandé pour UI)

```gdscript
# Dans votre contrôleur UI
extends Control

var tracked_quest_id: String = ""

func start_tracking_quest(quest_id: String) -> void:
    tracked_quest_id = quest_id
    
    # Connecter aux signaux du QuestManager
    QuestManager.quest_objective_updated.connect(_on_objective_updated)
    QuestManager.quest_completed.connect(_on_quest_completed)
    QuestManager.quest_failed.connect(_on_quest_failed)
    
    # Afficher l'état initial
    _update_ui()

func _on_objective_updated(quest_id: String, obj_index: int, current: int, required: int) -> void:
    if quest_id != tracked_quest_id:
        return
    
    print("Objectif %d: %d/%d" % [obj_index, current, required])
    _update_ui()

func _on_quest_completed(quest_id: String) -> void:
    if quest_id != tracked_quest_id:
        return
    
    print("✅ Quête complétée!")
    _show_completion_animation()

func _on_quest_failed(quest_id: String, reason: String) -> void:
    if quest_id != tracked_quest_id:
        return
    
    print("❌ Quête échouée: ", reason)
    _show_failure_message(reason)

func _update_ui() -> void:
    var instance = QuestManager.get_active_quest(tracked_quest_id)
    if not instance:
        return
    
    # Mettre à jour la barre de progression
    var progress = instance.get_overall_progress()
    $ProgressBar.value = progress * 100
    
    # Mettre à jour le texte des objectifs
    for i in range(instance.template.objectives.size()):
        var obj_state = instance.objectives_state[i]
        var label = $ObjectivesList.get_child(i) as Label
        label.text = "%d/%d %s" % [
            obj_state.current,
            obj_state.required,
            instance.template.objectives[i].get_display_description()
        ]
        
        # Barrer si complété
        if obj_state.completed:
            label.add_theme_color_override("font_color", Color.GREEN)
```

---

#### Méthode 2 : Polling (pour debug/analytics)

```gdscript
# Script de monitoring qui tourne en arrière-plan
extends Node

var monitored_quests: Array[String] = []

func _ready() -> void:
    # Monitorer toutes les quêtes actives toutes les 5 secondes
    var timer = Timer.new()
    timer.wait_time = 5.0
    timer.timeout.connect(_check_all_quests)
    add_child(timer)
    timer.start()

func _check_all_quests() -> void:
    var active = QuestManager.get_all_active_quests()
    
    print("=== Quest Monitor ===")
    print("Active quests: %d" % active.size())
    
    for instance in active:
        var progress = instance.get_overall_progress()
        var days_left = instance.get_days_remaining(WorldGameState.current_day)
        
        print("  [%s] %.0f%% | %d days left" % [
            instance.template.title,
            progress * 100,
            days_left
        ])
        
        # Alerte si proche de l'expiration
        if days_left >= 0 and days_left <= 2:
            push_warning("Quest '%s' expires soon!" % instance.template.title)
```

---

#### Méthode 3 : Logs détaillés (pour debug approfondi)

```gdscript
# Activer les logs verbeux temporairement
func enable_quest_debug_logs(quest_id: String) -> void:
    var instance = QuestManager.get_active_quest(quest_id)
    if not instance:
        print("Quest not active")
        return
    
    # Connecter tous les signaux avec logs détaillés
    instance.objective_updated.connect(func(idx, curr, req):
        print("[%s] Objective %d: %d/%d (+%d)" % [
            Time.get_ticks_msec(),
            idx,
            curr,
            req,
            1  # Assuming +1 progression
        ])
    )
    
    instance.objective_completed.connect(func(idx):
        print("[%s] ✅ Objective %d COMPLETED" % [
            Time.get_ticks_msec(),
            idx
        ])
    )
    
    instance.quest_completed.connect(func():
        print("[%s] ✅✅✅ QUEST COMPLETED: %s" % [
            Time.get_ticks_msec(),
            instance.template.title
        ])
        _dump_quest_stats(instance)
    )

func _dump_quest_stats(instance: QuestInstance) -> void:
    print("=== Quest Statistics ===")
    print("Title: ", instance.template.title)
    print("Duration: %d days" % (instance.end_day - instance.start_day))
    print("Events: %d" % instance.events.size())
    for i in range(min(5, instance.events.size())):
        var evt = instance.events[i]
        print("  [Day %d] %s" % [evt.day, evt.type])
```

---

### 2.5 Comment tester une campagne complète

**Objectif** : Tester une FactionCampaign du début à la fin sans avoir à jouer des heures.

---

#### Setup de test

```gdscript
# test_campaign.gd
extends Node

## ID de la campagne à tester
@export var campaign_id: String = "miners_rebellion"

## Activer le mode speedrun (complète automatiquement les quêtes)
@export var auto_complete: bool = true

## Delay entre chaque complétion auto (secondes)
@export var auto_delay: float = 2.0

func _ready() -> void:
    print("=== Campaign Test: %s ===" % campaign_id)
    
    # Setup initial
    _setup_test_environment()
    
    # Démarrer la campagne
    if CampaignManager.start_narrative_campaign(campaign_id):
        print("✅ Campaign started")
        _monitor_campaign()
    else:
        print("❌ Failed to start campaign")
        print("Checking unlock conditions...")
        _debug_unlock()

func _setup_test_environment() -> void:
    # Donner au joueur tout ce dont il a besoin
    var campaign = CampaignManager.campaign_library.get(campaign_id)
    if not campaign:
        return
    
    # Tags requis
    for tag in campaign.unlock_tags:
        WorldGameState.add_player_tag(tag)
        print("Added player tag: ", tag)
    
    # Réputation
    if campaign.required_reputation > 0:
        FactionManager.set_reputation(campaign.faction_id, campaign.required_reputation)
        print("Set reputation: %d" % campaign.required_reputation)
    
    # Quêtes prérequises
    for quest_id in campaign.required_quests:
        # Simuler complétion
        QuestManager.completed_quests[quest_id] = {
            "completion_day": 0,
            "duration": 0
        }
        print("Marked quest as completed: ", quest_id)

func _monitor_campaign() -> void:
    # Connecter aux signaux
    CampaignManager.campaign_chapter_completed.connect(_on_chapter_completed)
    CampaignManager.campaign_completed.connect(_on_campaign_completed)
    
    if auto_complete:
        _start_auto_completion()

func _on_chapter_completed(cid: String, chapter_num: int) -> void:
    if cid != campaign_id:
        return
    
    print("✅ Chapter %d completed" % (chapter_num + 1))
    var campaign = CampaignManager.get_active_campaign(campaign_id)
    if campaign:
        print("  Progress: %.0f%%" % (campaign.get_progress() * 100))
        print("  Next chapter: %d/%d" % [campaign.current_chapter + 1, campaign.chapters.size()])

func _on_campaign_completed(cid: String) -> void:
    if cid != campaign_id:
        return
    
    print("🎉🎉🎉 CAMPAIGN COMPLETED 🎉🎉🎉")
    _dump_campaign_results()

func _start_auto_completion() -> void:
    print("Auto-completion enabled (delay: %.1fs)" % auto_delay)
    _auto_complete_next_quest()

func _auto_complete_next_quest() -> void:
    var campaign = CampaignManager.get_active_campaign(campaign_id)
    if not campaign:
        print("Campaign no longer active")
        return
    
    var chapter_quests = campaign.get_current_chapter_quest_ids()
    
    # Trouver une quête active de ce chapitre
    for quest_id in chapter_quests:
        if QuestManager.is_quest_active(quest_id):
            print("Auto-completing: %s" % quest_id)
            _force_complete_quest(quest_id)
            
            # Attendre avant la suivante
            await get_tree().create_timer(auto_delay).timeout
            _auto_complete_next_quest()
            return
    
    # Aucune quête active → démarrer les suivantes
    for quest_id in chapter_quests:
        if not QuestManager.is_quest_completed(quest_id):
            print("Starting quest: %s" % quest_id)
            QuestManager.start_quest(quest_id)
            
            await get_tree().create_timer(auto_delay).timeout
            _auto_complete_next_quest()
            return
    
    # Toutes les quêtes du chapitre sont complétées
    print("Chapter completed, checking next...")
    await get_tree().create_timer(auto_delay).timeout
    _auto_complete_next_quest()

func _force_complete_quest(quest_id: String) -> void:
    var instance = QuestManager.get_active_quest(quest_id)
    if not instance:
        return
    
    # Compléter tous les objectifs
    for i in range(instance.template.objectives.size()):
        var state = instance.objectives_state[i]
        instance.update_objective(i, state.required - state.current)

func _debug_unlock() -> void:
    var campaign = CampaignManager.campaign_library.get(campaign_id)
    if not campaign:
        print("Campaign not found in library")
        return
    
    print("Required reputation: %d" % campaign.required_reputation)
    print("Current reputation: %d" % FactionManager.get_reputation(campaign.faction_id))
    print("Required tags: ", campaign.unlock_tags)
    print("Player tags: ", WorldGameState.get_player_tags())
    print("Required quests: ", campaign.required_quests)
    print("Completed quests: ", QuestManager.completed_quests.keys())

func _dump_campaign_results() -> void:
    var campaign = CampaignManager.get_active_campaign(campaign_id)
    if not campaign:
        # Déjà nettoyée, récupérer depuis la library
        campaign = CampaignManager.campaign_library.get(campaign_id)
    
    if not campaign:
        return
    
    print("=== Campaign Results ===")
    print("Chapters completed: %d" % campaign.completed_chapters.size())
    print("Duration: %d days" % (WorldGameState.current_day - campaign.start_day))
    
    if campaign.world_impact:
        print("World Impact:")
        print("  Unlocked regions: ", campaign.world_impact.unlock_regions)
        print("  Added tags: ", campaign.world_impact.add_world_tags)
    
    print("Faction relations changed:")
    for faction_id in campaign.faction_relations:
        var change = campaign.faction_relations[faction_id]
        print("  %s: %+d" % [faction_id, change])
```

**Utilisation** :

1. Attacher ce script à un Node dans une scène de test
2. Configurer `campaign_id` dans l'inspecteur
3. Activer `auto_complete` pour mode speedrun
4. Lancer la scène

**Résultat** : La campagne se joue automatiquement en quelques secondes, en loggant tout dans la console.

---

## 3. Troubleshooting et problèmes connus

Cette section liste les problèmes fréquemment rencontrés, leurs causes, et leurs solutions.

---

### 3.1 Problèmes de performance

#### Problème 1 : Lag quand beaucoup de quêtes sont enregistrées

**Symptôme** : FPS chute quand `QuestManager.refresh_available_quests()` est appelé.

**Cause** : `refresh_available_quests()` parcourt **tous** les templates et vérifie **toutes** les conditions à chaque appel.

**Solution actuelle (workaround)** :
```gdscript
# N'appeler refresh_available_quests() que quand nécessaire
# Ex: au changement de jour, pas à chaque frame

# Dans QuestManager._on_day_advanced()
func _on_day_advanced(day: int) -> void:
    # ... autres logiques
    
    # Rafraîchir seulement 1 fois par jour
    refresh_available_quests()
```

**Solution à long terme (à implémenter)** :
```gdscript
# Ajouter un système de cache avec dirty flag

var _available_quests_dirty: bool = true
var _cached_available_quests: Array[String] = []

func refresh_available_quests() -> void:
    if not _available_quests_dirty:
        return  # Utiliser le cache
    
    _cached_available_quests.clear()
    
    for quest_id in quest_templates.keys():
        if check_quest_availability(quest_id):
            _cached_available_quests.append(quest_id)
    
    _available_quests_dirty = false
    available_quests = _cached_available_quests.duplicate()

# Marquer comme dirty quand l'état change
func _on_player_tag_added(tag: String) -> void:
    _available_quests_dirty = true

func _on_quest_completed_internal(quest_id: String) -> void:
    # ... logique existante
    _available_quests_dirty = true
```

---

#### Problème 2 : Fuite mémoire avec les signaux de QuestInstance

**Symptôme** : Utilisation mémoire augmente progressivement, surtout après beaucoup de quêtes complétées.

**Cause** : Les signaux de `QuestInstance` ne sont jamais déconnectés.

**Solution** :
```gdscript
# Dans QuestManager._on_quest_completed_internal()
func _on_quest_completed_internal(quest_id: String) -> void:
    if quest_id not in active_quests:
        return
    
    var instance = active_quests[quest_id]
    var template = instance.template
    
    # NOUVEAU : Déconnecter les signaux avant de supprimer
    if instance.objective_updated.is_connected(_on_objective_updated):
        instance.objective_updated.disconnect(_on_objective_updated)
    if instance.objective_completed.is_connected(_on_objective_completed):
        instance.objective_completed.disconnect(_on_objective_completed)
    if instance.quest_completed.is_connected(_on_quest_completed_internal):
        instance.quest_completed.disconnect(_on_quest_completed_internal)
    if instance.quest_failed.is_connected(_on_quest_failed_internal):
        instance.quest_failed.disconnect(_on_quest_failed_internal)
    
    # ... reste de la logique
```

**Même chose dans `_on_quest_failed_internal()`.**

---

### 3.2 Bugs de logique

#### Bug 1 : Quêtes de chaîne qui n'avancent pas automatiquement

**Symptôme** : Une quête d'une `QuestChain` est complétée, mais la suivante ne démarre pas.

**Cause** : La connexion entre `QuestManager` et `CampaignManager` est cassée ou le signal n'est pas émis.

**Vérification** :
```gdscript
# Dans CampaignManager._on_quest_completed()
func _on_quest_completed(quest_id: String) -> void:
    print("[DEBUG] Quest completed: ", quest_id)  # <-- Ajouter ce log
    
    # Vérifier si c'est une quête de chaîne
    var chain = get_chain_for_quest(quest_id)
    if chain:
        print("[DEBUG] Quest is part of chain: ", chain.chain_id)  # <-- Log
        advance_chain(chain.chain_id)
    else:
        print("[DEBUG] Quest is NOT part of any chain")  # <-- Log
```

**Solution si le signal n'est pas connecté** :
```gdscript
# Dans CampaignManager._ready()
func _ready() -> void:
    quest_generator = QuestGenerator.new()
    
    # S'abonner aux événements
    QuestManager.quest_completed.connect(_on_quest_completed)  # <-- Vérifier cette ligne
    # ...
```

---

#### Bug 2 : Conditions de faction qui ne fonctionnent pas

**Symptôme** : Une quête nécessite réputation >= 50, le joueur a 50, mais la quête n'apparaît pas.

**Cause** : Comparaison stricte `<` au lieu de `<=` dans `QuestConditions`.

**Vérification dans `quest_conditions.gd`** :
```gdscript
func check_faction_conditions() -> bool:
    for faction_id in required_faction_reputation:
        var min_rep = required_faction_reputation[faction_id]
        var current_rep = FactionManager.get_reputation(faction_id)
        
        # ⚠️ Vérifier si c'est < ou <=
        if current_rep < min_rep:  # <-- Devrait être < (strictement inférieur)
            return false
    return true
```

**Si le bug se produit** : C'est probablement que `FactionManager.get_reputation()` retourne un type différent (float vs int) ou null.

**Solution robuste** :
```gdscript
var current_rep = FactionManager.get_reputation(faction_id)
if current_rep == null:
    current_rep = 0  # Défaut si faction inconnue

# Cast explicite
current_rep = int(current_rep)
min_rep = int(min_rep)

if current_rep < min_rep:
    return false
```

---

#### Bug 3 : WorldCrisis contribution ne fait rien

**Symptôme** : `CrisisManager.add_contribution()` est appelé mais rien ne se passe.

**Cause** : `WorldCrisis` n'est pas correctement intégré.

**Diagnostic** :
```gdscript
# Dans CrisisManager
func add_contribution(contributor_id: String, amount: int) -> void:
    if not active_crisis:
        push_warning("No active crisis!")  # <-- Ce warning apparaît ?
        return
    
    print("[CrisisManager] Adding contribution: %d" % amount)
    active_crisis.add_contribution(contributor_id, amount)
```

**Solution si aucune crise n'est active** :
- Vérifier que `CrisisManager.trigger_crisis()` a été appelé
- Vérifier que `active_crisis` n'est pas null
- Vérifier les logs au démarrage de la crise

**Solution si la crise est active mais rien ne se passe** :
- Vérifier dans `WorldCrisis.add_contribution()` que le signal est émis
- Vérifier que `contribution_goal` n'est pas 0 ou négatif

---

### 3.3 Problèmes de sauvegarde/chargement

#### Problème 1 : Les quêtes actives ne se restaurent pas après chargement

**Symptôme** : Après `QuestManager.load_state()`, `active_quests` est vide.

**Cause** : Le code de restauration ne reconstruit pas correctement les `QuestInstance`.

**Solution** :
```gdscript
func load_state(state: Dictionary) -> void:
    available_quests = state.get("available_quests", [])
    completed_quests = state.get("completed_quests", {})
    failed_quests = state.get("failed_quests", {})
    
    # Restaurer templates state
    var templates_state = state.get("templates_state", {})
    for quest_id in templates_state.keys():
        if quest_id in quest_templates:
            var template = quest_templates[quest_id]
            var t_state = templates_state[quest_id]
            template.last_completed_day = t_state.get("last_completed_day", -1)
            template.completion_count = t_state.get("completion_count", 0)
    
    # Restaurer les quêtes actives
    for quest_id in state.get("active_quests", {}).keys():
        if quest_id not in quest_templates:
            push_warning("Quest template not found: " + quest_id)
            continue
        
        var quest_state = state["active_quests"][quest_id]
        
        # IMPORTANT : Utiliser start_quest() pour recréer l'instance
        var instance = start_quest(quest_id)
        
        if instance:
            # Charger l'état sauvegardé
            instance.load_from_dict(quest_state)
            
            # CRITIQUE : Reconnecter les signaux
            instance.objective_updated.connect(_on_objective_updated.bind(quest_id))
            instance.objective_completed.connect(_on_objective_completed.bind(quest_id))
            instance.quest_completed.connect(_on_quest_completed_internal.bind(quest_id))
            instance.quest_failed.connect(_on_quest_failed_internal.bind(quest_id))
    
    print("[QuestManager] State loaded: %d active quests" % active_quests.size())
```

---

#### Problème 2 : Les campagnes narratives ne se sauvegardent pas

**Symptôme** : `CampaignManager.save_state()` fonctionne mais `load_state()` est vide.

**Cause** : `load_state()` n'a jamais été implémenté (TODO dans le code).

**Solution** :
```gdscript
func load_state(state: Dictionary) -> void:
    # Restaurer les chaînes
    for chain_id in state.get("active_chains", {}).keys():
        var chain_state = state["active_chains"][chain_id]
        
        # TODO: Recréer la chaîne depuis les données sauvegardées
        # Problème : les QuestChain ne sont pas dans une library
        # Solution temporaire : ignorer les chaînes, elles seront recréées
        push_warning("Chain restoration not implemented: " + chain_id)
    
    # Restaurer les campagnes
    for campaign_id in state.get("active_campaigns", {}).keys():
        if campaign_id not in campaign_library:
            push_warning("Campaign not found in library: " + campaign_id)
            continue
        
        # Dupliquer le template et charger l'état
        var campaign = campaign_library[campaign_id].duplicate(true)
        campaign.load_state(state["active_campaigns"][campaign_id])
        
        active_campaigns[campaign_id] = campaign
        
        # Reconnecter les signaux
        campaign.chapter_completed.connect(_on_campaign_chapter_completed.bind(campaign_id))
        campaign.campaign_completed.connect(_on_campaign_completed.bind(campaign_id))
    
    print("[CampaignManager] State loaded: %d campaigns" % active_campaigns.size())
```

---

### 3.4 Messages d'erreur fréquents

#### Erreur : "Invalid get index 'objectives' (on base: 'null')"

**Cause** : `QuestInstance.template` est null.

**Solution** :
```gdscript
# Toujours vérifier avant d'accéder
if instance and instance.template:
    for obj in instance.template.objectives:
        # ...
```

---

#### Erreur : "Cannot call method 'emit' on a null value"

**Cause** : Un signal est émis sur un objet qui a été libéré de la mémoire.

**Solution** :
- Vérifier que l'objet existe avant d'émettre
- Déconnecter les signaux avant de libérer l'objet

```gdscript
if instance and instance.quest_completed.is_connected(some_func):
    instance.quest_completed.disconnect(some_func)
```

---

#### Warning : "Quest ID already registered"

**Cause** : Tentative d'enregistrer deux fois la même quête (souvent au rechargement).

**Solution** :
```gdscript
func register_quest(template: QuestTemplate) -> void:
    if template.quest_id in quest_templates:
        # Simplement ignorer silencieusement au lieu de warning
        return
    
    quest_templates[template.quest_id] = template
    quest_registered.emit(template.quest_id)
```

---

## 4. Architecture décisionnelle

Cette section explique **pourquoi** certaines décisions de design ont été prises, et les alternatives qui ont été considérées.

---

### 4.1 Pourquoi RefCounted pour QuestInstance au lieu de Resource ?

**Décision** : `QuestInstance extends RefCounted`

**Alternatives considérées** :
1. `QuestInstance extends Resource` (sérialisable nativement)
2. `QuestInstance extends Node` (pour utiliser les signaux Godot natifs)

**Raisons** :

✅ **Avantages de RefCounted** :
- **Performance** : Pas de sérialisation/désérialisation automatique (qui serait inutile pour du runtime)
- **Mémoire** : Libération automatique quand plus de références
- **Simplicité** : Pas besoin d'être dans l'arbre de scène
- **Signaux customs** : On peut définir nos propres signaux sans héritage Node

❌ **Inconvénients** :
- Pas sérialisable nativement (on doit implémenter `save_to_dict()` / `load_from_dict()`)
- Pas d'inspection dans l'éditeur pendant le runtime

**Pourquoi pas Resource ?**
- Un `QuestInstance` n'a pas vocation à être sauvegardé comme fichier `.tres`
- Le runtime state est volatil et change constamment
- Resource impliquerait de sauvegarder chaque frame, ce qui est inutile

**Pourquoi pas Node ?**
- Pas besoin d'être dans l'arbre de scène (overhead inutile)
- Les signaux Godot natifs ne sont pas nécessaires (nos signaux customs suffisent)
- Instancier 10-20 Nodes pour les quêtes actives serait plus lourd

**Conclusion** : RefCounted est le meilleur compromis pour des objets runtime éphémères avec gestion automatique de la mémoire.

---

### 4.2 Pourquoi séparer QuestTemplate (Resource) et QuestInstance (RefCounted) ?

**Décision** : Deux classes séparées au lieu d'une seule.

**Alternatives considérées** :
1. Une seule classe `Quest` qui gère à la fois la définition et l'état runtime
2. `QuestTemplate` seulement, avec des flags `is_active`, `is_completed`, etc.

**Raisons** :

✅ **Avantages de la séparation** :
- **Réutilisabilité** : Un template peut générer plusieurs instances (quêtes répétables)
- **Mémoire** : Les templates sont chargés une fois, les instances sont créées/détruites
- **Clarté** : Séparation claire entre "définition" (immuable) et "état" (mutable)
- **Sauvegarde** : Seulement l'état runtime est sauvegardé, pas la définition complète

❌ **Inconvénients** :
- Deux classes à maintenir
- Navigation entre template et instance (via `instance.template`)

**Pourquoi pas une seule classe ?**
- Mélanger définition et état rend le code confus
- Impossible de différencier "quête jamais jouée" vs "quête en cours" vs "quête complétée"
- Pour les quêtes répétables, il faudrait dupliquer tout le template à chaque fois

**Analogie** : C'est comme la différence entre une `Class` (blueprint) et une `Instance` (object) en POO.

---

### 4.3 Pourquoi un QuestManager singleton au lieu de plusieurs managers spécialisés ?

**Décision** : Un seul `QuestManager` pour toutes les quêtes (Tier 1-3).

**Alternatives considérées** :
1. `SimpleQuestManager`, `ChainQuestManager`, `CampaignQuestManager` séparés
2. Système de composants attachables à `WorldGameState`

**Raisons** :

✅ **Avantages d'un manager unique** :
- **Point d'entrée unique** : `QuestManager.start_quest()` pour toutes les quêtes
- **Pas de duplication** : Logique de disponibilité/complétion partagée
- **Facilité de requête** : `get_all_active_quests()` retourne tout
- **Moins de couplage** : Les autres systèmes n'interagissent qu'avec QuestManager

❌ **Inconvénients** :
- Classe potentiellement grosse (mais organisée en sections)
- Mélange quêtes simples et chaînes (mais géré proprement)

**Pourquoi pas plusieurs managers ?**
- Complexité : Il faudrait coordonner 3 managers
- Requêtes difficiles : "Donner toutes les quêtes actives" nécessiterait 3 appels
- Duplication : Logique similaire copiée 3 fois

**Compromis retenu** :
- `QuestManager` pour Tier 1-3 (quêtes et chaînes)
- `CampaignManager` séparé pour Tier 4 (campagnes narratives) car logique très différente
- `CrisisManager` séparé pour Tier 5 (crises mondiales) car système global

---

### 4.4 Pourquoi ne pas intégrer un système de dialogue dans les quêtes ?

**Décision** : Les quêtes ne gèrent PAS les dialogues.

**Alternatives considérées** :
1. Intégrer des `DialogueNode` dans `QuestTemplate`
2. Ajouter un `DialogueManager` couplé au système de quêtes

**Raisons** :

✅ **Avantages de la séparation** :
- **Principe de responsabilité unique** : Une quête gère la progression, pas l'histoire
- **Flexibilité** : Le dialogue peut être géré par n'importe quel système (DialogueSystem, Ink, YarnSpinner)
- **Réutilisabilité** : Une même quête peut avoir différents dialogues selon le contexte
- **Maintenance** : Modifier les dialogues ne touche pas le code des quêtes

❌ **Inconvénients** :
- Il faut coordonner manuellement QuestManager et DialogueSystem
- Pas de preview des dialogues dans le template de quête

**Comment les dialogues sont-ils gérés ?**
```gdscript
# Dans le NPC qui donne la quête
func _on_npc_interact() -> void:
    # 1. Jouer le dialogue
    DialogueSystem.start_dialogue("merchant_quest_intro")
    await DialogueSystem.dialogue_finished
    
    # 2. Démarrer la quête
    QuestManager.start_quest("escort_merchant")
```

**Pourquoi cette approche ?**
- Le système de quêtes reste générique
- On peut changer de système de dialogue sans toucher aux quêtes
- Les quêtes peuvent être déclenchées par des événements non-dialogués (scripts, triggers, etc.)

---

### 4.5 Pourquoi des tags String au lieu d'enums typés ?

**Décision** : Les tags sont des `Array[String]` libres.

**Alternatives considérées** :
1. `enum PlayerTags { VETERAN, TRADER, DIPLOMAT, ... }`
2. Classe `Tag` avec validation
3. Dictionnaire prédéfini de tags valides

**Raisons** :

✅ **Avantages des String** :
- **Flexibilité** : Ajouter un nouveau tag ne nécessite aucun changement de code
- **Moddability** : Les moddeurs peuvent ajouter leurs propres tags
- **Lisibilité** : `"veteran"` est plus clair que `PlayerTags.VETERAN` dans les fichiers `.tres`
- **Sérialisation** : Pas de problème d'enum en JSON/dictionnaire

❌ **Inconvénients** :
- Pas de validation au compile-time (typos possibles)
- Pas d'autocomplétion

**Compromis retenu** :
```gdscript
# Dans un script helper (ex: tags_constants.gd)
class_name TagsConstants

# Documentation des tags disponibles (mais pas enforcé)
const PLAYER_TAGS = {
    "veteran": "Joueur expérimenté",
    "trader": "Spécialisé dans le commerce",
    "diplomat": "Bon négociateur",
    # etc.
}

const WORLD_TAGS = {
    "war_time": "Le monde est en guerre",
    "peace": "Période de paix",
    # etc.
}
```

**Validation optionnelle** :
```gdscript
# Pour du debug, on peut ajouter une validation
func validate_tag(tag: String, context: String) -> bool:
    var all_tags = []
    all_tags.append_array(TagsConstants.PLAYER_TAGS.keys())
    all_tags.append_array(TagsConstants.WORLD_TAGS.keys())
    
    if tag not in all_tags:
        push_warning("Unknown tag '%s' in %s" % [tag, context])
        return false
    return true
```

---

### 4.6 Pourquoi utiliser des signaux plutôt qu'un observer pattern maison ?

**Décision** : Utiliser les signaux Godot natifs.

**Alternatives considérées** :
1. Pattern Observer custom avec `register_listener()` / `notify_listeners()`
2. Event queue centralisée
3. Callbacks directs (functions as parameters)

**Raisons** :

✅ **Avantages des signaux Godot** :
- **Natif** : Intégré à l'engine, optimisé, debuggable
- **Découplage** : Émetteur ne connaît pas les récepteurs
- **Flexible** : Connexion/déconnexion dynamique
- **Inspectable** : Visible dans le debugger Godot

❌ **Inconvénients** :
- Pas de priorité d'exécution
- Pas de garantie d'ordre si plusieurs callbacks

**Pourquoi pas un Observer custom ?**
- Réinventer la roue
- Overhead de maintenance

**Pourquoi pas une event queue ?**
- Complexité inutile pour ce use case
- Les signaux suffisent

**Conclusion** : Les signaux Godot sont le choix évident pour ce type de communication événementielle.

---

### 4.7 Pourquoi CampaignManager génère-t-il les chaînes mais pas les quêtes individuelles ?

**Décision** : `CampaignManager` crée des `QuestChain` mais délègue la génération des quêtes à `QuestGenerator`.

**Raisons** :

✅ **Séparation des responsabilités** :
- `QuestGenerator` : Crée des quêtes standalone
- `CampaignManager` : Assemble des quêtes en chaînes cohérentes

✅ **Réutilisabilité** :
- `QuestGenerator` peut être utilisé ailleurs (événements aléatoires, quêtes dynamiques)
- Les quêtes générées peuvent exister indépendamment des chaînes

**Flux de génération** :
```
CampaignManager.generate_quest_chain()
  └─> QuestGenerator.generate_quest() (x N fois)
        └─> Retourne QuestTemplate
  └─> Assemble les IDs dans QuestChain
```

---

### 4.8 Pourquoi WorldCrisis est-il un système séparé plutôt qu'une FactionCampaign spéciale ?

**Décision** : `WorldCrisis` est un système distinct avec `CrisisManager`.

**Alternatives considérées** :
1. Faire des crises comme des `FactionCampaign` de Tier 5
2. Intégrer dans `CampaignManager` avec un flag `is_crisis`

**Raisons** :

✅ **Différences fondamentales** :
- **Portée** : Crises affectent le monde entier, pas une faction
- **Contribution partagée** : Plusieurs joueurs/factions contribuent à un objectif commun
- **Timer global** : Compte à rebours pour tout le monde
- **Conséquences globales** : Échec = impact sur tout le monde

✅ **Besoins spécifiques** :
- Classement des contributeurs
- Phases temporisées automatiques
- Événements mondiaux synchronisés

**Pourquoi pas une FactionCampaign ?**
- Une faction ne "possède" pas une crise
- Le système de chapitres ne s'applique pas (phases temporisées différentes)
- Les impacts sont globaux, pas factionnels

**Conclusion** : Un système séparé permet une logique spécialisée sans compliquer `CampaignManager`.

---

### 4.9 Pourquoi load_state() est-il si compliqué ?

**Décision** : Sauvegarde manuelle avec `save_to_dict()` / `load_from_dict()`.

**Alternatives considérées** :
1. Sérialisation automatique Godot (JSON, Resource)
2. Bibliothèque tierce (ex: SaveSystem addon)

**Raisons** :

✅ **Avantages de la sauvegarde manuelle** :
- **Contrôle total** : On décide exactement ce qui est sauvegardé
- **Optimisation** : Pas de sérialisation de données inutiles
- **Compatibilité** : Facile de migrer entre versions

❌ **Inconvénients** :
- Beaucoup de code boilerplate
- Erreurs possibles (oublier un champ)

**Pourquoi pas la sérialisation auto ?**
- `RefCounted` n'est pas sérialisable nativement
- Les signaux ne peuvent pas être sauvegardés
- Certaines données runtime ne doivent pas être sauvegardées (ex: `template` référence)

**Compromis** :
- Sauvegarder seulement les données **essentielles** pour reconstruire l'état
- Utiliser des dictionnaires simples (compatibles JSON)
- Reconstruire les objets et reconnecter les signaux au chargement

---

### 4.10 Pourquoi pas d'éditeur visuel de quêtes ?

**Décision** : Création de quêtes via l'inspecteur Godot standard ou par code.

**Alternatives considérées** :
1. Éditeur de graph nodes (style Blueprint)
2. Éditeur de dialogue intégré
3. Plugin d'édition visuelle

**Raisons** :

❌ **Pourquoi pas d'éditeur custom ?**
- **Temps de développement** : Créer un éditeur visuel prend énormément de temps
- **Maintenance** : Chaque changement de structure nécessite de mettre à jour l'éditeur
- **Bugs** : Un éditeur custom introduit des bugs supplémentaires
- **Apprentissage** : Les utilisateurs doivent apprendre un nouvel outil

✅ **Avantages de l'inspecteur Godot** :
- **Déjà là** : Pas de développement nécessaire
- **Familier** : Les utilisateurs connaissent déjà
- **Robuste** : Testé et maintenu par Godot
- **Flexible** : Support natif des Resources

**Futur possible** :
- Un plugin simple pour faciliter la création (wizards, templates)
- Mais pas un éditeur graph complet

---

## Conclusion

Ce guide complémentaire fournit :

1. ✅ **Inventaire détaillé** : État réel de chaque classe, méthode par méthode
2. ✅ **Guide du développeur** : Procédures step-by-step pour toutes les tâches courantes
3. ✅ **Troubleshooting** : Solutions aux problèmes fréquents avec diagnostics
4. ✅ **Architecture décisionnelle** : Justification des choix de design

**Utilisation recommandée** :
- Consulter l'**inventaire** avant de modifier une classe
- Suivre le **guide du développeur** pour ajouter du contenu
- Vérifier le **troubleshooting** en cas de bug
- Lire l'**architecture** pour comprendre les décisions

**Mise à jour** :
Ce document doit être mis à jour à chaque changement significatif du système de quêtes. Ajouter les nouveaux bugs découverts, les solutions trouvées, et les décisions prises.
