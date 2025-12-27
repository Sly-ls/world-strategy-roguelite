🟥 BLOC 1 — VISION + WORLDMAP (BIOMES, DYNAMIQUES, EXEMPLES)

Voici le bloc 1 complet, extrêmement détaillé, intégrable tel quel dans le Markdown final.

#️⃣ 1. VISION GÉNÉRALE (VERSION ÉTENDUE)

Le jeu est un roguelite stratégique narratif émergent se déroulant sur un continent vivant où :
- chaque région peut évoluer, muter, se dégrader ou prospérer
- chaque faction suit une trajectoire technologique, magique, naturelle, divine ou corruptrice
- le joueur incarne une armée unique dépassant progressivement sa condition
- chaque run forme une ère, laissant des cicatrices permanentes

le monde se transforme entre les runs :
- villes détruites
- forêts étendues
- corruption stabilisée ou éradiquée
- déserts agrandis
- zones irradiées ou bénies
- civilisations effondrées

Le but est d’explorer, survivre, influencer et transformer un monde en perpétuel conflit, où les événements ne suivent pas un scénario linéaire mais émergent de systèmes interconnectés.

Le joueur est une force mineure dans un monde immense au début, mais peut devenir :
- un héros légendaire
- un tyran
- un prophète divin
- un commandant technologique
- un catalyseur de corruption
- ou simplement un survivant lucide

#️⃣ 2. WORLDMAP (VERSION ULTRA COMPLÈTE)

La worldmap est le cœur du jeu :
un immense continent 1024×1024 cases, entièrement simulé.

##️⃣ 2.1 BIOMES — CATALOGUE COMPLET

Chaque biome possède :
- une apparence
- des propriétés de gameplay
- des effets sur le déplacement
- des interactions avec les axes (magie, techno, nature…)
- des impacts sur les événements

🌲 Forêt tempérée
- croissance lente mais continue
- abrite créatures naturelles et druidiques
- réduit la visibilité
- ralentit les armées sauf axées Nature

🌳 Forêt primitive / sacrée
- densité extrême
- source de magie naturelle
- accélère la croissance végétale
- réagit à la magie ou corruption

🌾 Plaine / prairie
- biome neutre
- idéal pour les batailles ouvertes
- grande visibilité

🏜️ Désert
- se propage lentement par sécheresse
- dépense 2× la nourriture
- chaleur extrême
- affinité Techno (énergie solaire / drones)

🏜️🔥 Désert corrompu
- variante infernale
- apparition de fissures démoniaques
- favorise corruption
- peut “manger” les biomes voisins

🏞️ Steppe
- zone semi-aride
- favorise cavalerie
- conversions rapides vers désert OU forêt selon conditions

🏔️ Montagnes
- bloquent le déplacement
- ressources riches (métal, runes)
- affinité forte avec Nains, Techno, Magie

🌋 Biome volcanique
- créé par un volcan actif
- lave / cendre / tremors
- détruit la végétation
- peut se stabiliser après plusieurs ères

🐉🔥 Terre draconique
- rare
- où résident créatures mythiques
- haute affinité magie + chaleur
- se déplace lentement selon dragons alpha
- regorgen d'or et d'arteefact et de richesse magique

❄️ Toundra
- froid extrême
- mouvement ralenti
- peut avancer ou reculer selon saisons d’ère

❄️🏔️ Glacier
- impassable
- peut fondre sur plusieurs ères

🧪 Zone altérée (anomalie magique/technologique)
- couleurs instables
- effets aléatoires
- peut muter unités ou POI
- instable en propagation

🕳️ Corruption
- biome dangereux
- peut transformer unités
- se propage automatiquement
- accélère certains événements N4–N5

🧫 Biome infectieux
- spores, peste, moisissures
- lié à corruption ou nature
- peut devenir “ruche” d’une faction émergente

##️⃣ 2.2 DYNAMIQUES DE TRANSFORMATION — LISTE COMPLÈTE

La worldmap évolue en continu.

Les transformations peuvent être :
- lentes (plusieurs ères)
- progressives (chaque jour/round)
- instantanées (événements / pouvoirs)

🔁 Transformation par Nature
- forêts qui poussent (+1 case au bord / X jours)
- rivières qui changent leur cours
- marais qui apparaissent après fortes pluies
- zones sauvages qui engloutissent ruines/villages abandonnés

🔥 Transformation par Volcanisme
- nouvelles coulées
- tremors
- création de roche noire
- îles volcaniques émergent en mer
- effondrement de montagnes

🧪 Transformation par Magie
- zones instables
- anomalies spatio-temporelles
- failles invoquées
- zones bénies ou maudites
- forêts enchantées
- plaines cristallisées

🦠 Transformation par Corruption
- propagation organique
- mutation du terrain
- toxicité croissante
- rivières contaminées
- désert corrompu
- marais infectés

⚙️ Transformation par Technologie
- zones industrielles
- pollution
- terraformation artificielle
- boucliers énergétiques
- routes
- villes complexes

🌀 Transformation par Événements (N1–N5)
- météores
- portails
- apparition de montagnes / cratères
- inondations
- tempêtes arcaniques
- batailles massives (scars of war)

##️⃣ 2.3 EXEMPLES DE TRANSFORMATIONS VALIDÉS
✔️ Exemple : Désert qui avance
vitesse : 1 case / 40 jours
- accéléré par température
stoppé par :
- forêt mature
- magie eau
- technologie “irrigation”

✔️ Exemple : Forêt qui pousse
si humidité élevée
+1 case / 20 jours
- peut envahir ruines
interactions :
- brûlable
- corrompue → forêt monstrueuse

✔️ Exemple : Volcan actif
4 phases :
- grondement
- explosion
- cendres
- refroidissement

Effets :
- biomes brûlés
- failles de lave
- nouvelles montagnes

✔️ Exemple : Cratère mystérieux
créé par événement N3 ou N4
- anomalies magiques
- possible entrée vers monde souterrain

✔️ Exemple : Archipel
- peut apparaître par événement tectonique
- factions tritons / pirates / anciennes civilisations
