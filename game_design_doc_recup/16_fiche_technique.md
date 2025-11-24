🟥 FICHE TECHNIQUE — SYSTÈME D’ÉVÉNEMENTS MONDIAUX

Un événement est une structure générique qui peut être :

locale

régionale

factionnelle

planétaire

cosmique

Chaque événement appartient à un niveau de puissance de 1 à 5.

🟦 1) STRUCTURE GÉNÉRALE D’UN ÉVÉNEMENT
Event:
  id: string
  name: string
  level: int (1–5)
  
  category: enum(
      LOCAL,
      TERRITORIAL,
      FACTION,
      GLOBAL,
      APOCALYPTIC
  )

  trigger: TriggerCondition
  effects: List<Effect>
  duration: DurationSpec
  spread: SpreadSpec
  resolution: ResolutionSpec

  visibility: enum(
      HIDDEN,
      PARTIAL,
      FULL
  )

  factions_involved: list<FactionID>
  tags: list<string>


Chaque champ est détaillé ci-dessous.

🟩 2) NIVEAUX D’ÉVÉNEMENTS (POWER LEVEL)

Les niveaux déterminent l’impact, la rareté et la durée.

⭐ Niveau 1 — Incidents locaux (courants)

Impact faible

Fréquence élevée

Affecte 1 case ou 1 ville

Exemples :

petite révolte

un culte apparaît

effondrement d’une mine

bête magique locale

tempête mineure

→ 3 à 5 par ère

⭐⭐ Niveau 2 — Changements territoriaux

Impact moyen

Affects 2–10 cases

Exemples :

marais qui s’étend

forêt sacrée pousse

glissement de terrain

début de corruption

migration massive

→ 2 à 4 par ère

⭐⭐⭐ Niveau 3 — Événements factionnels

Impact lourd

Affects territoires + factions

Exemples :

une faction tombe en corruption

une faction passe magie 2 ou techno 2

rituel majeur réussi

prise d’un bâtiment critique

guerre civile

→ 1 à 3 par ère

⭐⭐⭐⭐ Niveau 4 — Crises majeures

Impact mondial partiel

plusieurs régions touchées

long à résoudre

Exemples :

contagion magique

invasion démoniaque régionale

IA autonome qui hack des machines

tempête astrale continentale

éruption volcanique prolongée

→ toujours exactement 2 par ère (comme tu l’as choisi)

⭐⭐⭐⭐⭐ Niveau 5 — Crise d’Ère

Impact planétaire

thème de l’ère

change radicalement le monde

a plusieurs phases

Exemples :

Grand Portail démoniaque

Éveil de l’IA planétaire

Titan élémentaire

Supervolcan

Guerre divine

Catastrophe technologique

Mutation du réseau magique

Bombe orbitale inter-dimensionnelle

→ toujours 1 par ère.

🟧 3) TRIGGERS — CONDITIONS DE DÉCLENCHEMENT

Chaque événement possède un ou plusieurs triggers.

TriggerCondition:
  type: enum(
      TIME,
      RANDOM,
      FACTION_STATE,
      TERRAIN_STATE,
      WORLD_STATE,
      AXIS_THRESHOLD,
      POI_STATE,
      STORY
  )
  parameters: dict


Exemples :

• TIME

“à partir du jour 15”

“une fois par hiver”

• FACTION_STATE

“une faction atteint Techno = 3”

“une faction perd sa capitale”

“une faction possède 4 bâtiments magie”

• WORLD_STATE

“corruption > 10% de la map”

“plus de 3 volcans actifs”

“5 POI divins détruits”

• AXIS_THRESHOLD

“Divin >= 3 déclenche Courroux”

“Techno >= 3 déclenche IA”

• RANDOM (pondéré)

poids dynamique en fonction du contexte

🟨 4) EFFECTS — EFFETS D’UN ÉVÉNEMENT

Un événement peut avoir plusieurs effets simultanés :

modification du terrain

apparition de créatures

ajout ou retrait de POI

effets sur factions (bonus/malus)

propagation (corruption, nature, magie…)

météo spéciale

destruction

création d'unités uniques

changement dans les relations diplomatiques

ouverture de rifts / portails

interférences technologiques

Format :

Effect:
  type: enum(
      TERRAIN_CHANGE,
      UNIT_SPAWN,
      RESOURCE_CHANGE,
      DIPLOMACY_MODIFIER,
      POI_CHANGE,
      BIOME_CHANGE,
      FOG_CHANGE,
      WEATHER,
      DAMAGE_REGION,
      BUFF_FACTION,
      DEBUFF_FACTION
  )
  parameters: dict

🟦 5) DURÉE

Trois modes :

DurationSpec:
  type: enum(
      INSTANT,
      FIXED,
      UNTIL_RESOLVED,
      PHASED
  )
  parameters: dict

INSTANT

Ex : explosion, effondrement

FIXED

Ex : “tempête 4 jours”

UNTIL_RESOLVED

Ex : corruption tant qu’un rituel n’est pas annulé

PHASED (niveau 4–5)

Ex pour un volcan :

Phase 1 : grondements

Phase 2 : explosion

Phase 3 : pluie de cendres

Phase 4 : refroidissement

🟧 6) SPREAD — PROPAGATION

Pour les événements contagieux :

SpreadSpec:
  radius_per_turn: int
  chance_to_spread: float
  stops_on: list<Biome>
  accelerates_on: list<Biome>


Exemples :

Corruption

spread = 1 case / 2 jours

accélère en marais

s'arrête dans désert

Magie sauvage

spread = aléatoire

se renforce dans forêts sacrées

IA

spread via villes technologiques uniquement

🟩 7) RÉSOLUTION

Chaque événement décrit comment il peut se terminer :

ResolutionSpec:
  auto: bool
  auto_duration: int
  manual_conditions: list<Condition>
  reward: list<Reward>
  permanent_changes: list<Effect>


Exemples :

Auto

tempête météo

inondation saisonnière

migration

Manuel

détruire un portail

tuer le titan

purifier un nexus

éteindre la corruption

neutraliser la IA d’une zone

Récompenses

artefacts

ressources

réputation

accès à nouvelles unités

bâtiments uniques

🟦 8) VISIBILITÉ

Pour que le joueur ne voie pas tout d’un coup.

visibility: 
  - HIDDEN (lieu inconnu, rumeurs)
  - PARTIAL (icône + description brève)
  - FULL (access complet aux infos)


Certains niv. 5 peuvent commencer en HIDDEN (effet d’ambiance).

🟧 9) INTÉGRATION DANS LES ÈRES (TON MODÈLE)

Une ère contient :

Era:
  events_level_1: 3–5
  events_level_2: 2–4
  events_level_3: 1–3
  events_level_4: 2
  event_level_5: 1


Et peut commencer :

avant le niv.5

pendant le niv.5

après le niv.5
(selon tes pourcentages)

Avec cette structure, CHAQUE RUN a :

un thème

une histoire

une montée dramatique

un point culminant

des cicatrices pour la run suivante

🟩 10) Exemple d’événement codé

Exemple d’un Portail démoniaque (Niv. 5) :

Event:
  id: "demon_gate_opening"
  name: "Ouverture du Grand Portail"
  level: 5
  category: APOCALYPTIC
  
  trigger:
    type: AXIS_THRESHOLD
    parameters:
      axis: CORRUPTION
      level: 3
      global: true

  effects:
    - type: BIOME_CHANGE
      parameters: { biome: CORRUPTED, radius: 4 }

    - type: UNIT_SPAWN
      parameters: { race: DEMON, count: 10 }

    - type: POI_CHANGE
      parameters: { create: "GateOfHell" }

  duration:
    type: PHASED
    parameters:
      phases: ["Instabilité", "Ouverture", "Invasion", "Stagnation", "Retombées"]

  spread:
    radius_per_turn: 1
    chance_to_spread: 0.3
    accelerates_on: [DESERT, MARSH]

  resolution:
    auto: false
    manual_conditions:
      - "Détruire le portail"
    reward:
      - "Artefact démoniaque"
    permanent_changes:
      - BIOME_CHANGE (scorched earth area)

🎯 Conclusion

Tu as maintenant la fiche technique complète, prête à être intégrée dans ton moteur et suffisante pour générer :

des événements émergents

cohérents

multi-niveaux

avec propagation

résolution

récompenses

phases

interactions avec axes / factions / monde

crises d’ère

C’est un des systèmes les plus puissants du jeu, et tu as maintenant une base béton.