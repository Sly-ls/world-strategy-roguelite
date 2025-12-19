# Quest System - Guide d'Intégration

## Vue d'ensemble

Ce dossier contient le nouveau système de quêtes procédurales avec :
- **Arc System** : État des relations entre factions (NEUTRAL → RIVALRY → CONFLICT → WAR → TRUCE)
- **Coalition System** : Alliances et blocs entre factions
- **Knowledge System** : Rumeurs, croyances et faits
- **Domestic System** : Pression politique interne des factions
- **Treaty System** : Traités et clauses entre factions

## Structure des dossiers

```
quest_system/
├── arc/                    # Machine à états pour les arcs de rivalité
│   ├── ArcState.gd         # État d'un arc entre deux factions
│   ├── ArcStateMachine.gd  # Transitions d'états
│   ├── ArcNotebook.gd      # Registre central des événements
│   ├── ArcPairHistory.gd   # Historique par paire de factions
│   ├── ArcHistory.gd       # Historique par faction
│   ├── ArcOfferFactory.gd  # Génération d'offres de quêtes
│   └── ...
├── coalition/              # Système de coalitions
├── knowledge/              # Système de rumeurs et connaissances
├── domestic/               # Pression politique interne
├── targeting/              # Ciblage et priorités
├── third_party/            # Médiation et opportunisme
├── treaty/                 # Système de traités
├── core/                   # Classes de base supplémentaires
│   ├── FactionEconomy.gd
│   ├── FactionOfferBudget.gd
│   ├── FactionDomesticState.gd
│   └── FactionWorldContext.gd
├── quest/                  # Utilitaires de quêtes
└── tests/                  # Tests unitaires et d'intégration
```

## Intégration avec le code existant

### Classes existantes utilisées

Le système utilise ces classes déjà présentes dans ton projet :
- `FactionProfile` (src/factions/)
- `FactionRelationScore` (src/factions/)
- `FactionRelationsUtil` (src/factions/)
- `ArcDecisionUtil` (src/quest2/)
- `ArcEffectTable` (src/quest2/)
- `RivalryNotebook` (src/quests/arcs/)
- `ArcManager` (src/quests/arcs/)

### Modifications apportées

**ArcManager.gd** a été mis à jour pour :
- Intégrer `ArcNotebook` (nouveau système de tracking)
- Supporter `ArcState` et `ArcStateMachine`
- Garder la compatibilité avec `RivalryNotebook`

## Lancer les tests

### Test de base (FactionProfile)

1. Créer une scène de test
2. Attacher `tests/TestFactionProfileGeneration.gd` à un Node
3. Lancer la scène

Le test génère 100 profils par mode et vérifie :
- Les axes respectent les contraintes (un > 50, un < -20, somme 20-90)
- La personnalité est distinctive (traits hauts et bas)
- Sauvegarde des profils "golden" pour les tests futurs

### Tests d'intégration

Les tests dans `tests/` sont organisés par fonctionnalité :
- `TestArcSimulation.gd` - Simulation de 30 jours d'événements
- `TestFactionWorldRelations.gd` - Initialisation des relations monde
- Tests de pression domestique, coalitions, etc.

## Notes importantes

1. **ArcNotebook vs RivalryNotebook** : Les deux coexistent. `RivalryNotebook` gère les anciennes rivalités simples, `ArcNotebook` gère le nouveau système avec heat tracking et relation caps.

2. **Pas de doublons** : Les fichiers `ArcDecisionUtil.gd` et `ArcEffectTable.gd` sont dans `src/quest2/` et ne sont pas dupliqués ici.

3. **Dépendances autoload** : Les tests supposent que ces autoloads existent :
   - `WorldState` (pour `.current_day`)
   - `FactionManager` (pour les relations)
   - `ArcManagerRunner` (pour `arc_notebook`)
