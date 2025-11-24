🟥 BLOC 8 — Génération procédurale du monde et des factions

Ce bloc explique comment ton jeu génère un continent entier, cohérent, vivant, transformable, et compatible avec :

les biomes dynamiques

les factions procédurales

les crises

les POI

les axes (Techno, Magie, Divin, Nature, Corruption)

les structures du combat et du gameplay global

C’est un bloc très important car il définit la boucle de génération = la colonne vertébrale du roguelite.

#️⃣ 8.1 Principes fondamentaux

La génération se fait en 4 couches hiérarchiques :

Topologie globale – forme du continent, montagnes, mers, fleuves

Biomes dynamiques – forêts, déserts, marais, toundra…

Régions vivantes – zones de 20×20 à 50×50 cases avec identité forte

Points d’intérêt (POI) – villes, ruines, autels, portails, nids, ressources spéciales

Factions – placement + territoire + biome + axes

Histoire initiale – une mini-ère simulée avant le début du joueur

Le monde est un tableau de tableaux, mais :

Il n’est jamais intégralement stocké en mémoire.
On utilise un système hybride :

grille logique infinie / vaste

chunks instanciés à la volée

#️⃣ 8.2 Étape 1 : Génération topologique globale

Le continent est généré via une combinaison :

bruit de Perlin (pour relief doux)

bruit de Worley (pour fractures)

couche de tectonique simple (pour montagnes)

gravité simplifiée (pour bassins fluviaux)

Résultat :

forme du continent

zones côtières

zones montagneuses

rivages bruts

plateformes continentales

#️⃣ 8.3 Étape 2 : Biomes dynamiques

Tu veux des biomes qui évoluent pendant le jeu, donc leur base initiale doit être :

cohérente

mais flexible

Biomes de base (déjà validés) :

Forêt (tempérée / profonde / sombre / tropicale / corrompue)

Plaine (standard / fleurie / gelée)

Toundra

Désert (classique / rouge / magique)

Marais (toxique / sacré / normal)

Montagnes (calcaires / volcaniques)

Côtes / îles / archipels

Ravins / fractures géologiques

Zones technologiques (rares au départ)

Zones magiques (nexus, anomalies)

Règles :

la distance à la côte influence humidité

la distance aux montagnes influence pluie

les rivières créent des vallées fertiles

les zones instables (volcans, corruption, magie) se placent en clusters

#️⃣ 8.4 Étape 3 : Régions vivantes

Le monde est découpé en grands “chunks” (concept inventé ensemble) :

20×20 ou 50×50 cases

Chaque chunk = une identité

Chaque chunk = un biome principal + 1 secondaire

Chaque chunk = 1 effet passif (ex : “vent fort”, “sol fertile”, “failles instables”)

Les chunks servent pour :

la performance

la sauvegarde

l’affichage (ton wireframe World Map large)

les changements dynamiques (corruption, nature, techno)

#️⃣ 8.5 Étape 4 : Points d’intérêt (POI)

Les POI sont essentiels à ton design.

Types de POI (déjà validés mais enrichis ici) :

Militaires

camps

forteresses

tours de guet

casernes uniques

Magiques

nexus

failles

pierres runiques

sanctuaires

Techno

usines

stations robotisées

carrefours industriels

Civils

villages

cités

métropoles déchues

ruines anciennes

Naturels

arbres colossaux

geysers

sources sacrées

nids géants

Corrompus

autels impies

monolithes

foyers démoniaques

Chaque POI a :

une “race” graphique

une fonction

un axe dominant

une histoire

un état (inactif / actif / détruit / corrompu)

#️⃣ 8.6 Étape 5 : Placement des factions

C’est une des parties les plus importantes.

Placement basé sur :

biome préféré

affinités d’axe

rapports d’échelle (certaines factions veulent grandes plaines, d’autres montagnes)

densité initiale (selon tes choix : 0/1/2 bâtiments)

Exemples :

factions Nature → forêts, jungles, marais

factions Techno → zones plates, côtes, mines

factions Magie → anomalies et nœuds

factions Divines → montagnes, clairières sacrées

factions Corrompues → ravins, marais sombres, volcans

Placement :

espacement minimum entre factions

génération de frontières logiques (rivières, montagnes)

création de routes et axes commerciaux

#️⃣ 8.7 Étape 6 : Pré-simulation d’histoire

Avant que le joueur commence :

Le jeu simule une mini-ère de 10 à 50 ans
(selon un paramètre de “richesse” du monde).

Cette mini-simulation :

installe déjà une crise N3

déforme un peu la carte

renforce 2–3 factions

affaiblit 1 faction

génère 2–4 événements naturels N2

place des reliques

crée les premières ruines

Le joueur commence donc dans un monde vivant, déjà blessé, déjà dynamique, pas dans un start statique.

#️⃣ 8.8 Architecture technique du générateur

Le générateur doit fournir :

(A) Un seed global

Permettant :

la reproductibilité

le partage de seeds

le debug facile

(B) Un registre des axes

Chaque axe influence :

la couleur

les effets

les unités

les transformations

(C) Un système d’évolution

Pour gérer :

désertification

croissance forestière

apparition de corruption

zones magiques

zones technologiques

(D) Un calendrier des ères

Simule :

mini phénomènes N1

micro-régionalisation N2

mutation factionnelle N3

crises N4

événements majeurs N5

#️⃣ 8.9 Poids mémoire & performance

Tu veux pouvoir gérer des mondes de taille potentiellement IMMENSE.

Donc :

Le monde est :

stocké en chunks

compressé

sauvegardé en diff (uniquement les changements)

streamé (charges dynamiques)

généré procéduralement au fur et à mesure

Seules les zones proches du joueur sont actives :

3×3 chunks rendus

5×5 en mémoire

le reste est désactivé / sérialisé

#️⃣ 8.10 Interaction avec les combats (ton système 5×4)

La carte n’a pas besoin d’être ultra-détaillée :

la zone de combat est générée procéduralement

basée sur le biome du chunk

influencée par le POI local

et par les effets régionaux (météo, magie, techno, corruption)

Exemple :

bataille dans forêt corrompue → champ de bataille rempli de racines mortes

bataille dans techno→ ruines industrielles

bataille près d’un volcan → magma et brûlures

#️⃣ 8.11 Consistance entre runs

Le monde n’est jamais reset sauf :

si événement N5 le justifie

si le joueur décide un “Grand Reset”

Sinon :

POI, factions, rivages changent

le volcan peut exploser dans une ère

dans la suivante, il peut s’être stabilisé

la forêt grandit dans une ère

puis brûle dans une autre

les animaux migrent

les routes se déplacent