# Dialogues Moi / ChatGPT


Généré le 2025-12-19 06:05
<a id="sommaire-general"></a>

## Sommaire général — chapitres

Résumé par chapitre

Chaque chapitre ci‑dessous est résumé en 3 phrases : *ce dont on parle*, *ce qu’on met en place*, *le but*.

1. [**Chapitre 1 —** Cadrage général & état du système](#toc-detail-ch1) Ce chapitre cadre le problème (arcs/relations entre factions) et les invariants attendus.On pose les briques principales et leur rôle dans l’architecture globale.Le but est d’obtenir un système cohérent, testable et extensible.
2. [**Chapitre 2 —** ArcManager : éviter la boucle d’escalade](#toc-detail-ch2) On identifie le risque de spirale d’escalade dans la génération d’arcs.On met en place des garde-fous (cooldowns, budgets, saturation, anti-emballement).Le but est d’avoir des arcs crédibles sans explosion incontrôlée.
3. [**Chapitre 3 —** Profils de factions : axes & personnalité](#toc-detail-ch3) On définit comment décrire une faction via des axes + une personnalité.On met en place une génération/validation de profils avec contraintes et diversité.Le but est d’alimenter relations et décisions avec une base solide.
4. [**Chapitre 4 —** Relations initiales : baseline & init monde](#toc-detail-ch4) On construit l’état initial du monde via une matrice de relations.On met en place des invariants (moyenne centrée, alliés/ennemis, réciprocité légère).Le but est un point de départ stable et jouable.
5. [**Chapitre 5 —** Arc events : chance, cooldowns, deltas & ArcNotebook](#toc-detail-ch5) On décrit comment des ArcEvents se déclenchent (chance, conditions, cooldowns).On applique des deltas et on journalise l’historique (ArcNotebook) pour tracer le pourquoi.Le but est une progression lisible, debuggable et équilibrable.
6. [**Chapitre 6 —** Tests & simulations : profils, relations, arcs](#toc-detail-ch6) On organise des tests/simulations pour sécuriser profils, relations et arcs.On met en place des jeux de données “golden” et des invariants automatisés.Le but est d’éviter les régressions et d’aider au calibrage.
7. [**Chapitre 7 —** ArcState machine : offers, mapping, coûts & fallback](#toc-detail-ch7) On formalise la machine d’état (ArcState) pour gérer offers, mapping et transitions.On met en place des coûts/contraintes et des fallbacks en cas d’impasse.Le but est une logique de négociation claire et déterministe.
8. [**Chapitre 8 —** Boucle monde : goals, planification, cibles](#toc-detail-ch8) On définit la boucle monde : choix de goals, planification et sélection des cibles.On met en place des priorités guidées par le contexte, ressources et relations.Le but est une IA de faction cohérente sur la durée.
9. [**Chapitre 9 —** Third party : intervention, médiation, opportunisme](#toc-detail-ch9) On ajoute les acteurs tiers : intervention, médiation et opportunisme.On met en place les règles d’implication (quand, comment, à quel coût/risque).Le but est de créer des dynamiques émergentes et des retournements.
10. [**Chapitre 10 —** Traités : modèle, enforcement & cassure](#toc-detail-ch10) On modélise les traités (clauses, durée, conditions) et leur enforcement.On met en place la rupture, les sanctions et les conséquences sur les relations.Le but est une diplomatie persistante et impactante.
11. [**Chapitre 11 —** War aims : termes, clauses, non-payment](#toc-detail-ch11) On précise les war aims et la structure des termes (clauses, paiement, concessions).On met en place la gestion du non-paiement / non-respect et ses effets.Le but est d’avoir des fins de guerre crédibles et exploitables.
12. [**Chapitre 12 —** Knowledge / rumeurs : facts, heat, offers](#toc-detail-ch12) On gère l’information imparfaite via knowledge/rumeurs et faits partiels.On met en place le “heat” et l’impact sur les offers et les décisions.Le but est d’introduire incertitude et gameplay émergent.
13. [**Chapitre 13 —** Coalitions / blocs : formation & résolution](#toc-detail-ch13) On traite la formation de coalitions/blocs et leur stabilité.On met en place des règles d’adhésion, de sortie et de résolution des blocs.Le but est de voir apparaître des fronts dynamiques et cohérents.
14. [**Chapitre 14 —** Domestic pressure : gate goals & intégration réelle](#toc-detail-ch14) On introduit la pression interne (domestic pressure) qui contraint les goals externes.On met en place des gates/thresholds et l’intégration réelle dans les décisions.Le but est une politique interne qui pèse sur la diplomatie et la guerre.
15. [**Chapitre 15 —** Failure modes : succès/échec & intégration](#toc-detail-ch15) On recense les failure modes et la façon de les gérer proprement.On met en place des critères succès/échec intégrés aux mécaniques existantes.Le but est un système robuste, avec des issues intéressantes.
16. [**Chapitre 16 —** Économie : rareté, inflation narrative & rewards](#toc-detail-ch16) On modélise l’économie : rareté, coûts, inflation narrative et rewards.On met en place les connexions avec arcs, traités et pression interne.Le but est un équilibre long terme et des motivations claires.
17. [Index — classes & fichiers](#toc-detail-index)
⎯⎯⎯⎯⎯⎯
<a id="sommaire-detaille"></a>

## Sommaire détaillé — chapitres & sous-chapitres

<a id="toc-detail-ch1"></a>2. **Chapitre 1 — Cadrage général & état du système**
	1. [**Moi 1:** predns connaissance du texte ci dessous qui decrit ce que j'ai mis en place.
	Mots-clés : offers, quête, context, quêtes, résolution](#moi-1)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-ch2"></a>4. **Chapitre 2 — ArcManager : éviter la boucle d’escalade**
	1. [**Moi 2:** Définir : qu'on discute du ArcManager Actuellement, une action histile d'une faction permet de declencher une rivalité,…
	Mots-clés : voudrais, action, actuellement, rivalité, escalade](#moi-2)
	2. [**Moi 3:** Choix rapide : Journalier
	Contexte : tension, alliance, fatigue, trust • ArcManager : éviter la boucle d’escalade](#moi-3)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-ch3"></a>6. **Chapitre 3 — Profils de factions : axes & personnalité**
	1. [**Moi 4:** Chaque faction va aussi avoir une personalité, je pense qu'il faut prendre ca en compte dans le calcule.
	Mots-clés : faction, expansionniste, personalité, belliqueuse, pacifique](#moi-4)
	2. [**Moi 5:** Actuellement, on a un score de relation de chaque faction envers les autres.
	Mots-clés : faut, faction, score, factionrelationscore, dictionnaire](#moi-5)
	3. [**Moi 6:** Appelons FactionAxisProfile plutot FactionProfile .
	Mots-clés : seront, score, factionprofile, dynamique, dictionnaire](#moi-6)
	4. [**Moi 7:** Oui s'il te plait, fait : une fonction de génération procédurale des axis\_affinity qui garantit à coup sûr : 1 axe > 50…
	Mots-clés : axis\_affinity, distribution, intéressante, procédurale, génération](#moi-7)
	5. [**Moi 8:** Fait les deux, on choisira l'algo en fonction de l'etat du monde.
	Mots-clés : faction, tirage, puisse, monde, algo](#moi-8)
	6. [**Moi 9:** Go pour génération de personnalité
	Mots-clés : personnalité, génération](#moi-9)
	7. [**Moi 10:** prochaine étape logique : une fonction “generate\_full\_profile” qui génère axes + personnalité en cohérence (ex : une fa…
	Mots-clés : faction, magie, anti, generate\_full\_profile, personnalité](#moi-10)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-ch4"></a>8. **Chapitre 4 — Relations initiales : baseline & init monde**
	1. [**Moi 11:** prochaine brique logique : une fonction compute\_baseline\_relation(A\_profile, B\_profile) qui transforme axes + personnal…
	Mots-clés : compute\_baseline\_relation, factionrelationscore, personnalité, initialiser, transf…](#moi-11)
	2. [**Moi 12:** prochaine brique logique : une fonction initialize\_relations\_for\_faction(faction\_id) qui construit le dictionnaire comp…
	Mots-clés : initialize\_relations\_for\_faction, dictionnaire, faction\_id, prochaine, construit](#moi-12)
	3. [**Moi 13:** brique suivante (utile pour ton ArcManager ) : une fonction initialize\_relations\_world() qui initialise toutes les fact…
	Mots-clés : initialize\_relations\_world, optionnellement, réciprocité, arcmanager, initialise](#moi-13)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-ch5"></a>10. **Chapitre 5 — Arc events : chance, cooldowns, deltas & ArcNotebook**
	1. [**Moi 14:** une fonction compute\_arc\_event\_chance(A->B score) qui convertit tension + friction + relation + personnalité en probabi…
	Mots-clés : compute\_arc\_event\_chance, arc\_action\_type, personnalité, probabilité, convertit](#moi-14)
	2. [**Moi 15:** prochaine brique : une table cooldown\_days\_for(action) + des deltas standards par arc\_action\_type (ce que la résolution…
	Mots-clés : cooldown\_days\_for, arc\_action\_type, résolution, appliquera, prochaine](#moi-15)
	3. [**Moi 16:**](#moi-16)
	4. [**Moi 17:**](#moi-17)
	5. [**Moi 18:** on dit qu'une relation ne peut pas evoluer de plus de 10 a 30% de son score actuelle (dans une direction ou l'autre, c'…
	Mots-clés : last\_arc\_date, dictionnaire, arcnotebook, historique, direction](#moi-18)
	6. [**Moi 19:** Le ArcNotebook est stocké dans le arcManager comme ça : var arc\_notebook : ArcNotebook .
	Mots-clés : arcnotebook, besoin, arc\_notebook, construction, arcmanager](#moi-19)
	7. [**Moi 20:** En fait, dans un ArcNotebook , j'ai des arcHistory par faction, l'arcHistory contient des metadata (les count des arcTy…
	Mots-clés : archistory, arcnotebook, resolutions, historique, contient](#moi-20)
	8. [**Moi 21:** pour la table et l'application par evenement](#moi-21)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-ch6"></a>12. **Chapitre 6 — Tests & simulations : profils, relations, arcs**
	1. [**Moi 22:** maintenant, je voudrais des tests pour ce qu'on a fait dans les Faction (personnalité et axe, je me souvient plus du no…
	Mots-clés : personnalité, differents, voudrais, souvient, profiles](#moi-22)
	2. [**Moi 23:** L'idée, maintenant on va generer les relations de depart entre les factions dans un deuxieme tests](#moi-23)
	3. [**Moi 24:** Exactement ce que je voulais
	Mots-clés : exactement, voulais](#moi-24)
	4. [**Moi 25:** On enchaine avec le test 3, le nombre de jour est parametrable (on le recoit en entrée de la fonction de tests)](#moi-25)
	5. [**Moi 26:** fais une variante du test 3 qui : enregistre un log d’événements (jour, A, B, action, choice, avant/après), et calcule…
	Mots-clés : quantitativement, enregistre, événements, escalation, variante](#moi-26)
	6. [**Moi 27:** Oui, ajoute ca
	Mots-clés : ajoute](#moi-27)
	7. [**Moi 28:** Une sortie cv serait parfaite
	Mots-clés : parfaite, sortie](#moi-28)
	8. [**Moi 29:** Non ca suffira Selon toi, est ce que le systeme que tu viens de créer est complet?
	Mots-clés : pourrait, suffira, systeme, complet, manquer](#moi-29)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-ch7"></a>14. **Chapitre 7 — ArcState machine : offers, mapping, coûts & fallback**
	1. [**Moi 30:** : prochaine brique logique : propose une spec compacte de ArcState + conditions de transition + table arc\_action\_type →…](#moi-30)
	2. [**Moi 31:** donne le code GDScript de update\_arc\_state() (version compacte) + build\_arc\_context() + un ArcOfferFactory .spawn\_offer…
	Mots-clés : spawn\_offer\_for\_pair, build\_arc\_context, update\_arc\_state, arcofferfactory, questi…](#moi-31)
	3. [**Moi 32:** Il faut prendre aussi en compte les recompenses, plus la mission est difficile, plus elle coute cher, il fzut que la fa…](#moi-32)
	4. [**Moi 33:**](#moi-33)
	5. [**Moi 34:** Non, on fait 2) Des “conditions de fin” + “cooldown long” d’arc Tu as cap/cooldown par évènement, mais il faut aussi un…
	Mots-clés : cooldown, jours, pair\_lock\_days, relation\_mean, tension\_mean](#moi-34)
	6. [**Moi 35:** Oui envoi
	Mots-clés : envoi](#moi-35)
	7. [**Moi 36:** Oui, donne le mini tick\_day\_for\_pair(arc\_state, rel\_ab, rel\_ba) (10 lignes) pour que les compteurs “Y jours” soient par…](#moi-36)
	8. [**Moi 37:** Maintenant, on fait : 3) Un modèle de “coût” et “capacité” faction (budget d’actions) Pour éviter que des factions décl…
	Mots-clés : budget, offres, faction, guerre, coûte](#moi-37)
	9. [**Moi 38:** Propositions : un mini patch “ ArcManager fallback” : quand spawn\_offer\_for\_pair() échoue (pas assez d’or/points), il r…
	Mots-clés : spawn\_offer\_for\_pair, arcmanager, simplement, abandonner, ultimatum](#moi-38)
	10. [**Moi 39:** Fait : Ajuster tier en fallback Si tu veux encore plus robuste : quand le spawn échoue, on peut aussi baisser le tier a…
	Mots-clés : action, tier, fallback, puis, ajuster](#moi-39)
	11. [**Moi 40:** Fait que le nombre de fois qu'on degrader l'action et le tiers soit des parametre dans la fonction](#moi-40)
	12. [**Moi 41:** Maintenant, fait : 4) Le mapping “arc\_action\_type → offres de quêtes” C’est LE pont vers ton QuestPool : • chaque arc\_a…
	Mots-clés : arc\_action\_type, offres, escort, alliance\_offer, standardisées](#moi-41)
	13. [**Moi 42:** prochaine brique utile : une mini règle “allowed actions per ArcState ” + “bundle size selon état” (ex: en WAR, count\_m…
	Mots-clés : lisibilité, prochaine, count\_min, count\_max, maîtriser](#moi-42)
	14. [**Moi 43:** Le max est part faction?
	Mots-clés : faction, contre, facttion, rivalry, actions](#moi-43)
	15. [**Moi 44:** Non, explique moi ce que tu voulais dire par : prochaine mini-brique : une règle “1 seul ARC\_PRIMARY visible par paire”…
	Mots-clés : arc\_primary, prochaine, secondary, explique, existent](#moi-44)
	16. [**Moi 45:** Je pensais que le max\_offer (3 pour War) etait une limite pour le nombre d'offre total, pas le nombre d'offre par jour.
	Mots-clés : meilleur, nombre, offre, quete, max\_offer](#moi-45)
	17. [**Moi 46:** Propositions : le micro-ajout “cooldown refresh par pair” dans ArcNotebook (genre pas plus d’un upgrade tous les 5 jour…
	Mots-clés : arcnotebook, cooldown, vraiment, propose, refresh](#moi-46)
	18. [**Moi 47:** Propositions : aussi un mini champ “refresh\_attempts\_by\_pair” pour debug/metrics, mais fonctionnellement, les 2 méthode…
	Mots-clés : refresh\_attempts\_by\_pair, fonctionnellement, suffisent, méthodes, propose](#moi-47)
	19. [**Moi 48:** Objectif : que le test 5 utilise ta fonction réelle (au lieu du helper injecté), donne un micro-patch “optionnel” (ajou…
	Mots-clés : fonction, callable, \_try\_spawn\_offer\_with\_fallback\_and\_tier, comportement, optionn…](#moi-48)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-ch8"></a>16. **Chapitre 8 — Boucle monde : goals, planification, cibles**
	1. [**Moi 49:** Non, on fait : 5) Une boucle “monde” cohérente (pas seulement ArcManager ) Les arcs ne doivent pas être l’unique moteur…
	Mots-clés : doivent, arcs, goals, factiongoalplanner, external\_threat](#moi-49)
	2. [**Moi 50:** donne un MVP concret de apply\_arc\_modifiers() (10–30 lignes) avec 3 goals d’urgence (WAR/CONFLICT/TRUCE) + comment “rev…
	Mots-clés : apply\_arc\_modifiers, suspended\_goal, précédent, conflict, concret](#moi-50)
	3. [**Moi 51:** prochaine brique logique : un plan\_action(goal, ctx) MVP correspondant (WAR→générer offers WAR, TRUCE→offers trêve, etc…
	Mots-clés : offers, correspondant, plan\_action, proprement, prochaine](#moi-51)
	4. [**Moi 52:** prochaine brique (très utile) : une fonction compute\_opportunity/external\_threat mieux définie + une règle simple “si f…
	Mots-clés : compute\_opportunity, external\_threat, privilégier, reparations, prochaine](#moi-52)
	5. [**Moi 53:** prochaine brique logique : une fonction compute\_priority\_targets(ctx) qui utilise threat et opportunity pour choisir un…
	Mots-clés : meilleur, compute\_priority\_targets, actuellement, opportunity, prochaine](#moi-53)
	6. [**Moi 54:** prochaine brique : un mini test qui simule 30 jours d’events record\_pair\_event() et vérifie que best\_enemy/best\_ally ba…
	Mots-clés : record\_pair\_event, correctement, réparations, best\_enemy, prochaine](#moi-54)
	7. [**Moi 55:** ajouter dans un autre test une 2e assertion “quantitative” (ex: best\_enemy\_score baisse pour B entre J10 et J30) pour v…
	Mots-clés : best\_enemy\_score, quantitative, décroissance, renversement, assertion](#moi-55)
	8. [**Moi 56:** Oui dans un autre test
	Mots-clés : test](#moi-56)
	9. [**Moi 57:** Oui dans un 4eme test
	Mots-clés : 4eme, test](#moi-57)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-ch9"></a>18. **Chapitre 9 — Third party : intervention, médiation, opportunisme**
	1. [**Moi 58:** On fait : 6) Une notion de “third party” (intervention, médiation, opportunisme) Très important pour éviter l’escalade…
	Mots-clés : trêve, intervention, opportunisme, opportuniste, intervient](#moi-58)
	2. [**Moi 59:** fais prochaine brique logique : un mapping d’effets standard pour third\_party\_role + tp\_action + choice (deltas sur A↔B…
	Mots-clés : third\_party\_role, prochaine, tp\_action, médiation, converger](#moi-59)
	3. [**Moi 60:** prochaine brique logique : une variante de test qui vérifie que l’opportunisme crée naturellement un nouvel arc C↔victi…
	Mots-clés : naturellement, opportunisme, augmentation, prochaine, grievance](#moi-60)
	4. [**Moi 61:** fais une 2e variante de ce test qui vérifie aussi que A↔C s’améliore (beneficiary likes C) et que A↔B n’est pas directe…
	Mots-clés : volontairement, opportunisme, beneficiary, directement, variante](#moi-61)
	5. [**Moi 62:** Propositions : proposer une règle “si third party opportunist aidait A, alors B en veut davantage à A (même sans preuve…](#moi-62)
	6. [**Moi 63:** Objectif : que ce soit asymetrique
	Mots-clés : asymetrique, veux, soit](#moi-63)
	7. [**Moi 64:** donne le patch exact du test dans le prochain message.](#moi-64)
	8. [**Moi 65:** ajouter une assertion bonus : B→A trust baisse](#moi-65)
	9. [**Moi 66:** Tu dis pour vérifier que B→A trust baisse, si tu as activé l’option Comment activer l'option?](#moi-66)
	10. [**Moi 67:** Non Je voudrais que tu me dise ce que tu penses de cr qu'on a mis en place et est ce que tu as ded idées pour ameliorer…
	Mots-clés : persistance, ameliorer, stabilité, métriques, voudrais](#moi-67)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-ch10"></a>20. **Chapitre 10 — Traités : modèle, enforcement & cassure**
	1. [**Moi 68:** Propositions : proposer un mini schéma de données Treaty (10 champs max) + comment il s’intègre à ArcStateMachine .upda…](#moi-68)
	2. [**Moi 69:** logique : 2–3 offres “treaty enforcement” + comment elles modifient violation\_score (ex : LOYAL baisse violation\_score…
	Mots-clés : violation\_score, enforcement, modifient, prolonge, falsifie](#moi-69)
	3. [**Moi 70:** prochaine brique logique : un mini test “violation puis enforcement loyal” qui vérifie que violation\_score redescend et…
	Mots-clés : traité, casse, test, violation\_score, enforcement](#moi-70)
	4. [**Moi 71:** donne aussi la micro-fonction utilitaire maybe\_break\_treaty(arc\_state, day) pour centraliser ça proprement.](#moi-71)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-ch11"></a>22. **Chapitre 11 — War aims : termes, clauses, non-payment**
	1. [**Moi 72:** Non, on va travailler sur • War aims + sortie (sinon WAR peut tourner longtemps)](#moi-72)
	2. [**Moi 73:** prochaine brique logique : je te propose build\_war\_terms(arc\_state) (compact) + un mapping “terms → Treaty clauses + re…
	Mots-clés : build\_war\_terms, open\_trade, périodique, prochaine, arc\_state](#moi-73)
	3. [**Moi 74:** prochaine brique logique : une petite règle “non-payment” pour le tribut (si loser n’a pas l’or → violation\_score du tr…
	Mots-clés : violation\_score, prochaine, logique, payment, collect](#moi-74)
	4. [**Moi 75:** fais ca 5) Mini test (si tu veux tout de suite) Un test rapide : loser.gold = 0 tribute due day 7 assert violation\_scor…
	Mots-clés : assert, loser, test, spawn\_collect\_offer\_fn, violation\_score](#moi-75)
	5. [**Moi 76:** fais aussi une variante où 2 non-payments déclenchent une cassure du traité (violation\_score dépasse threshold) et basc…](#moi-76)
	6. [**Moi 77:** mais il faut que ca soit en fonction de l'historique des deux factions et de leur affinité/personnalité](#moi-77)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-ch12"></a>24. **Chapitre 12 — Knowledge / rumeurs : facts, heat, offers**
	1. [**Moi 78:** Non ca suffit je pense On passe sur : • Knowledge/rumeurs (ça rend les offers à 3 factions incroyablement naturelles)](#moi-78)
	2. [**Moi 79:** prochaine brique logique : je te donne une implémentation compacte des 3 fonctions essentielles : register\_fact(event)…
	Mots-clés : apply\_knowledge\_resolution, implémentation, register\_fact, essentielles, inject\_ru…](#moi-79)
	3. [**Moi 80:** prochaine brique logique : une fonction get\_perceived\_heat(observer, other, day) + un mini test qui prouve que 2 rumeur…
	Mots-clés : get\_perceived\_heat, prochaine, empêchent, fonction, observer](#moi-80)
	4. [**Moi 81:** prochaine brique logique : un mini mapping “rumeur → offers” (PROVE INNOCENCE / INVESTIGATE / FORGE EVIDENCE) basé sur…
	Mots-clés : automatiquement, investigate, confidence, prochaine, innocence](#moi-81)
	5. [**Moi 82:** prochaine brique logique : un test “bundle” qui vérifie qu’à heat>=40 + malicious=true, on spawne bien 2–3 offers (avec…
	Mots-clés : bundle, heat, automatiquement, third\_party, antagonist](#moi-82)
	6. [**Moi 83:** Qu'apporte le fait que ce soit 100% deterministe et qurl sont les parametres qui randomize](#moi-83)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-ch13"></a>26. **Chapitre 13 — Coalitions / blocs : formation & résolution**
	1. [**Moi 84:** On travaille sur 5) Coalitions/blocs (multi-paires mais lisibles) La 3rd party est un bon début.
	Mots-clés : factions, monde, naturellement, hégémonique, coalitions](#moi-84)
	2. [**Moi 85:** donne un MVP concret en GDScript de : CoalitionManager .tick\_day() (détection hégémon + formation + spawn 1–2 offers ma…
	Mots-clés : crise, coalition, faction, guerre, menace](#moi-85)
	3. [**Moi 86:** prochaine brique logique : je te donne un mini test “crisis coalition” où 2 factions ennemies entrent en coalition STOP…
	Mots-clés : coalition, opportuniste, stop\_crisis, arcnotebook, corruption](#moi-86)
	4. [**Moi 87:** ne idée, fais ajouter une assertion bonus : trust(A→B) baisse fortement après l’undermine (via les deltas de \_apply\_mem…
	Mots-clés : \_apply\_member\_deltas, relationnelles, arcnotebook, assertion, fortement](#moi-87)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-ch14"></a>28. **Chapitre 14 — Domestic pressure : gate goals & intégration réelle**
	1. [**Moi 88:** on passe a : 6) “Domestic pressure” (politique interne) Même sans sim interne complexe, un scaler suffit : • internal\_s…
	Mots-clés : interne, guerre, internal\_stability, war\_support, reparations](#moi-88)
	2. [**Moi 89:** prochaine brique logique : je te donne un DomesticOfferFactory .spawn\_offer\_if\_needed(faction\_id, domestic\_state) + app…
	Mots-clés : apply\_domestic\_resolution, spawn\_offer\_if\_needed, domesticofferfactory, domestic\_s…](#moi-89)
	3. [**Moi 90:** Propositions : le hook “propre” dans ton GoalPlanner : quand domestic.pressure() > 0.7, on force le goal TRUCE/REPARATI…
	Mots-clés : automatiquement, offensivestf, goalplanner, reparations, énormément](#moi-90)
	4. [**Moi 91:** prochaine brique logique : un mini test “pressure gate” qui simule pressure>0.7 et vérifie que goal.type est forcé en T…
	Mots-clés : pressure, effectivement, prochaine, offensif, augmenté](#moi-91)
	5. [**Moi 92:** prochaine brique logique : brancher ce gate directement dans ton simulateur ( FactionGoalManagerRunner .ensure\_goal ou…
	Mots-clés : factiongoalmanagerrunner, directement, ensure\_goal, plan\_action, intégration](#moi-92)
	6. [**Moi 93:** prochaine brique logique : faire la même intégration testée avec un vrai goal stack (WAR → TRUCE forcé 7 jours → restor…
	Mots-clés : suspended\_goal, intégration, prochaine, pressure, vérifier](#moi-93)
	7. [**Moi 94:** prochaine brique logique : brancher ça dans tes vraies classes ( FactionGoalManagerRunner + FactionGoalPlanner ) avec u…
	Mots-clés : classes, test, factiongoalmanagerrunner, factiongoalplanner, intégration](#moi-94)
	8. [**Moi 95:** pour version encore plus “100% vraie boucle monde”, je peux aussi te proposer un micro-patch FactionGoalManagerRunner .…
	Mots-clés : factiongoalmanagerrunner, ensure\_goal, plan\_action, faction\_id, proposer](#moi-95)
	9. [**Moi 96:** utiliser tes autoloads réels
	Mots-clés : autoloads, utiliser, réels](#moi-96)
	10. [**Moi 97:** QuestPool.gd
	Mots-clés : questpool](#moi-97)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-ch15"></a>30. **Chapitre 15 — Failure modes : succès/échec & intégration**
	1. [**Moi 98:** Passons plutot sur 10) “Failure modes” intéressants Aujourd’hui, un échec est souvent “rien”.
	Mots-clés : failure, intéressants, conséquence, incompétent, nourrissent](#moi-98)
	2. [**Moi 99:** prochaine brique logique : je te propose une mini-fonction compute\_outcome\_success(inst, actor\_profile, opposition, tie…
	Mots-clés : compute\_outcome\_success, actor\_profile, participant, opposition, déterminer](#moi-99)
	3. [**Moi 100:** prochaine brique logique : brancher compute\_outcome\_success() directement dans QuestManager .resolve\_quest() (en gardan…
	Mots-clés : compute\_outcome\_success, last\_success\_chance, systématiquement, resolve\_quest, que…](#moi-100)
	4. [**Moi 101:** brique suivante : je te donne un mini test d’intégration sur ton pipeline réel : QuestManager .resolve\_quest() sur une…
	Mots-clés : roll, resolve\_quest, questmanager, intégration, arcnotebook](#moi-101)
	5. [**Moi 102:** brique suivante : une variante “SUCCESS” (roll faible) qui vérifie l’inverse (tension↓, trust vers médiateur↑) + que la…](#moi-102)
	6. [**Moi 103:** QuestCompletionStatus
	Mots-clés : questcompletionstatus](#moi-103)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-ch16"></a>32. **Chapitre 16 — Économie : rareté, inflation narrative & rewards**
	1. [**Moi 104:** Je ne suis plus sur du nom du champ Faisons : 9) Économie : inflation narrative & rareté Tu as escrow/or/budget.
	Mots-clés : plus, économie, opportunistes, inversement, inflation](#moi-104)
	2. [**Moi 105:** prochaine brique : un mini test statistique (50 offers POOR vs RICH) qui assert que POOR génère majoritairement non-gol…
	Mots-clés : rich, majoritairement, poor, gold, opportunism\_heat](#moi-105)
	3. [**Moi 106:** Propositions : un 2e test qui vérifie qu’en mode pauvre, la “valeur” totale attendue (influence+faveur+clauses) reste c…
	Mots-clés : pauvre, influence, cohérente, généreuse, attendue](#moi-106)
	4. [**Moi 107:** prochaine brique logique : un test équivalent côté RICH qui vérifie que gold scale bien avec tier mais que la variance…](#moi-107)
	5. [**Moi 108:** prochaine brique logique : lier la “variance” à la personnalité (ex: greedy/chaotic => variance↑, bureaucratic => varia…
	Mots-clés : variance, personnalité, bureaucratic, prochaine, logique](#moi-108)
	6. [**Moi 109:** brique suivante : faire dépendre w\_gold (pas juste la variance) de la personnalité aussi (ex: “greed” augmente la part…
	Mots-clés : personnalité, statistiques, monétaire, suivante, dépendre](#moi-109)
	7. [**Moi 110:** brique suivante : brancher w\_gold\_dw (le delta personnalité) dans ton ArcNotebook pour debug (“cette faction paye en or…
	Mots-clés : greedy, rich, gold, personnalité, arcnotebook](#moi-110)
	8. [**Moi 111:** faire un mini test d’intégration “ OfferFactory + ArcNotebook ” (vraie méthode spawn) qui assert que l’event offer.rewa…
	Mots-clés : offerfactory, reward\_style, intégration, arcnotebook, w\_gold\_dw](#moi-111)
	9. [**Moi 112:** QuestOfferSimRunner
	Mots-clés : questoffersimrunner](#moi-112)[↑ Retour au sommaire général](#sommaire-general)
<a id="toc-detail-index"></a>34. **Index — classes & fichiers**
	1. [Ouvrir l’index (citations cliquables)](#index)[↑ Retour au sommaire général](#sommaire-general)

<a id="index"></a>

## Chapitre Index — classes & fichiers

Tous les termes ci-dessous sont listés avec un numéro par occurrence. Clique sur un numéro pour aller exactement à l’endroit où le terme est cité.

* `ArcManager` : [1](#cite-arcmanager-1d7a8c-1) [2](#cite-arcmanager-1d7a8c-2) [3](#cite-arcmanager-1d7a8c-3) [4](#cite-arcmanager-1d7a8c-4) [5](#cite-arcmanager-1d7a8c-5) [6](#cite-arcmanager-1d7a8c-6) [7](#cite-arcmanager-1d7a8c-7)
* `ArcManagerRunner` : [1](#cite-arcmanagerrunner-f86edc-1)
* `ArcNotebook` : [1](#cite-arcnotebook-b751fa-1) [2](#cite-arcnotebook-b751fa-2) [3](#cite-arcnotebook-b751fa-3) [4](#cite-arcnotebook-b751fa-4) [5](#cite-arcnotebook-b751fa-5) [6](#cite-arcnotebook-b751fa-6) [7](#cite-arcnotebook-b751fa-7) [8](#cite-arcnotebook-b751fa-8) [9](#cite-arcnotebook-b751fa-9) [10](#cite-arcnotebook-b751fa-10) [11](#cite-arcnotebook-b751fa-11) [12](#cite-arcnotebook-b751fa-12)
* `ArcOfferFactory` : [1](#cite-arcofferfactory-dd2763-1)
* `ArcState` : [1](#cite-arcstate-66333b-1) [2](#cite-arcstate-66333b-2)
* `ArcStateMachine` : [1](#cite-arcstatemachine-253c3b-1)
* `CoalitionManager` : [1](#cite-coalitionmanager-d24e07-1)
* `DomesticOfferFactory` : [1](#cite-domesticofferfactory-a7a48d-1)
* `FactionAxisProfile` : [1](#cite-factionaxisprofile-93f0d3-1)
* `FactionGoalManagerRunner` : [1](#cite-factiongoalmanagerrunner-a52b6d-1) [2](#cite-factiongoalmanagerrunner-a52b6d-2) [3](#cite-factiongoalmanagerrunner-a52b6d-3) [4](#cite-factiongoalmanagerrunner-a52b6d-4) [5](#cite-factiongoalmanagerrunner-a52b6d-5) [6](#cite-factiongoalmanagerrunner-a52b6d-6)
* `FactionGoalPlanner` : [1](#cite-factiongoalplanner-73d377-1) [2](#cite-factiongoalplanner-73d377-2) [3](#cite-factiongoalplanner-73d377-3)
* `FactionProfile` : [1](#cite-factionprofile-11982e-1) [2](#cite-factionprofile-11982e-2) [3](#cite-factionprofile-11982e-3)
* `FactionRelationScore` : [1](#cite-factionrelationscore-783d2e-1) [2](#cite-factionrelationscore-783d2e-2) [3](#cite-factionrelationscore-783d2e-3) [4](#cite-factionrelationscore-783d2e-4)
* `FactionRivalryArc` : [1](#cite-factionrivalryarc-78cb4d-1)
* `FactionSim` : [1](#cite-factionsim-d4515c-1) [2](#cite-factionsim-d4515c-2)
* `GoalPlanner` : [1](#cite-goalplanner-9cd268-1)
* `LootSite` : [1](#cite-lootsite-9df50b-1) [2](#cite-lootsite-9df50b-2) [3](#cite-lootsite-9df50b-3) [4](#cite-lootsite-9df50b-4)
* `LootSiteManager` : [1](#cite-lootsitemanager-ee96d2-1) [2](#cite-lootsitemanager-ee96d2-2)
* `OfferFactory` : [1](#cite-offerfactory-ecafbb-1) [2](#cite-offerfactory-ecafbb-2)
* `PrenDs` : [1](#cite-prends-a86775-1)
* `QuestCompletionStatus` : [1](#cite-questcompletionstatus-0c9fe3-1)
* `QuestEffect` : [1](#cite-questeffect-a36c70-1) [2](#cite-questeffect-a36c70-2)
* `QuestGenerator` : [1](#cite-questgenerator-14f567-1)
* `QuestInstance` : [1](#cite-questinstance-a4c334-1) [2](#cite-questinstance-a4c334-2) [3](#cite-questinstance-a4c334-3) [4](#cite-questinstance-a4c334-4) [5](#cite-questinstance-a4c334-5)
* `QuestInstances` : [1](#cite-questinstances-05d563-1)
* `QuestManager` : [1](#cite-questmanager-0ffcf2-1) [2](#cite-questmanager-0ffcf2-2) [3](#cite-questmanager-0ffcf2-3) [4](#cite-questmanager-0ffcf2-4) [5](#cite-questmanager-0ffcf2-5) [6](#cite-questmanager-0ffcf2-6) [7](#cite-questmanager-0ffcf2-7) [8](#cite-questmanager-0ffcf2-8)
* `QuestOfferSimRunner` : [1](#cite-questoffersimrunner-664bb4-1) [2](#cite-questoffersimrunner-664bb4-2)
* `QuestPool` : [1](#cite-questpool-43825e-1) [2](#cite-questpool-43825e-2) [3](#cite-questpool-43825e-3) [4](#cite-questpool-43825e-4) [5](#cite-questpool-43825e-5) [6](#cite-questpool-43825e-6) [7](#cite-questpool-43825e-7)
* `QuestPool.gd` : [1](#cite-questpool-gd-caba10-1)
* `QuestResolutionProfile` : [1](#cite-questresolutionprofile-1167dd-1)
* `QuestSystemTest.gd` : [1](#cite-questsystemtest-gd-c5b90c-1)
* `QuestTemplate` : [1](#cite-questtemplate-fe9f87-1) [2](#cite-questtemplate-fe9f87-2)
* `WorldSim` : [1](#cite-worldsim-44f86b-1)
* `XxxRunner` : [1](#cite-xxxrunner-7f5129-1) [2](#cite-xxxrunner-7f5129-2)

[↑ Retour au sommaire général](#sommaire-general)

## Transcription


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 1](#toc-detail-ch1)
<a id="moi-1"></a>
**Moi 1:**
predns connaissance du texte ci dessous qui decrit ce que j'ai mis en place.

Prends aussi connaissances des docuement que je t'envoie pour comprendre le contexte de mon jeu


Voici un **résumé fonctionnel et exhaustif** de l’état actuel du système de quêtes (procédural + offers + résolution + simulation + arcs). Tu peux le coller tel quel pour démarrer une nouvelle conversation.


---


## 1) Vue d’ensemble


Le jeu possède un **système de quêtes procédural data-driven**, basé sur une séparation stricte :


* **
<a id="cite-questtemplate-fe9f87-1"></a>QuestTemplate** : décrit la “forme” de la quête (catégorie, objectif, tier, expiration, etc.).
* **
<a id="cite-questinstance-a4c334-1"></a>QuestInstance** : instance runtime créée à partir d’un template + **context runtime** (giver/antagonist, paramètres de génération, arc info, goal step, artefact id, owner, etc.).


Les quêtes existent sous 2 formes runtime distinctes :


1. **Offers** : quêtes “disponibles” dans un pool (pas encore acceptées).
2. **Active quests** : quêtes prises par un owner (player / hero / army IA / etc.), suivies en progression et résolues.


---


## 2) Données principales


###

<a id="cite-questtemplate-fe9f87-2"></a>QuestTemplate


Contient les champs “communs à toutes les occurrences” :


* `id`, `title`, `description`
* `category`, `tier`
* `objective_type`, `objective_target`, `objective_count`
* `expires_in_days` (souvent utilisé pour offers / quêtes)
*
	+ éventuellement des champs liés à la résolution (selon tes itérations)

###

<a id="cite-questinstance-a4c334-2"></a>QuestInstance


Représente une occurrence runtime :


* `runtime_id` : identifiant unique
* `template_id`, `template`
* `status` : AVAILABLE / ACTIVE / COMPLETED / FAILED / EXPIRED
* `progress`
* `started_on_day`, `expires_on_day`
* `context : Dictionary` : **coeur du procédural** (voir ci-dessous)


Le `context` contient typiquement :


* `giver_faction_id`
* `antagonist_faction_id`
* `resolution_profile_id`
* flags : `is_goal_offer`, `is_arc_rivalry`
* pour les goals : `goal_step_id`, `goal_domain`
* pour les arcs : `arc_id`, `arc_stage`, `arc_reason`
* pour artefacts/lost loot : `artifact_id`, `owner_type`, `owner_id`
* paramètres de génération : enemy\_type, days, amount, etc.


---


## 3) Génération procédurale


###

<a id="cite-questgenerator-14f567-1"></a>QuestGenerator


Génère des quêtes “dynamiques” en construisant :


1. un **template runtime** (souvent via `_create_dynamic_template(quest_type, params)`)
2. un **context runtime** (giver/antagonist/profile/goal/arc/etc.)
3. une **
<a id="cite-questinstance-a4c334-3"></a>QuestInstance** créée avec `
<a id="cite-questinstance-a4c334-4"></a>QuestInstance.new(template, context)`.


Deux modes principaux :


* `generate_random_quest(tier)` : quête générique (combat/exploration/survival/collection/diplomacy…).
* `generate_quest_for_poi(poi_pos, poi_type)` : quête spécifique à un POI (ruines, ville, sanctuaire…).


Les paramètres runtime sont générés par :


* `_generate_random_parameters(quest_type, tier)`
* `_generate_quest_parameters(quest_type, poi_type, poi_pos)`


Le générateur injecte aussi :


* `giver_faction_id`, `antagonist_faction_id`
* `resolution_profile_id` (choisi dynamiquement via règles / factory)


---


## 4) Offers : pool global + caps + validation


###

<a id="cite-questpool-43825e-1"></a>QuestPool


Contient les offers disponibles (quêtes status AVAILABLE).

Il y a une logique de contrôle :


* **expiration**
* **cap global** : ex. MAX\_OFFERS\_GLOBAL
* **cap par signature** (anti-spam d’un même “type” d’offre)
* **cap par giver** (anti-monopole d’une faction)


Une offer peut être invalidée si :


* elle est expirée
* elle référence un owner runtime disparu (ex:
<a id="cite-lootsite-9df50b-1"></a>LootSite qui n’existe plus)
* giver faction invalide / inconnue
* dépendances d’autoload manquantes (selon implémentation)


---


## 5)

<a id="cite-questmanager-0ffcf2-1"></a>QuestManager : acceptation, progression, résolution


###

<a id="cite-questmanager-0ffcf2-2"></a>QuestManager


Responsable de :


* charger/registrer des templates (si tu utilises des .tres pour certains)
* démarrer une quête (instance ACTIVE)
* suivre la progression
* compléter/expirer
* appliquer la **résolution** via un profil


Principales opérations :


#### Démarrer une quête


* `start_quest(template_id, context)` (mode “templates enregistrés”)
* `start_runtime_quest(quest_instance)` (mode “quest instance procédurale déjà construite”)


Cela place la quête dans `active_quests[runtime_id]`.


#### Progression


* `update_quest_progress_by_id(runtime_id, delta)`

Quand l’objectif est atteint, la quête passe en état “résolution requise” (selon ta logique actuelle).


#### Résolution


* `resolve_quest(runtime_id, choice)` avec choice ∈ {LOYAL, NEUTRAL, TRAITOR}


Le
<a id="cite-questmanager-0ffcf2-3"></a>QuestManager :


1. récupère le `resolution_profile_id` (sur l’instance ou via context)
2. charge le profil depuis un registry (souvent basé sur `.tres`)
3. applique les effets (or, tags, relations giver/antagonist…)


Il émet aussi un signal :


* `quest_resolved(inst, choice)` (utilisé par
<a id="cite-arcmanager-1d7a8c-1"></a>ArcManager)


---


## 6) Profils de résolution (data-driven via .tres)

###

<a id="cite-questresolutionprofile-1167dd-1"></a>QuestResolutionProfile (.tres)


Resource contenant :


* `id`
* `loyal_effects`, `neutral_effects`, `traitor_effects` : Array[
<a id="cite-questeffect-a36c70-1"></a>QuestEffect]


###

<a id="cite-questeffect-a36c70-2"></a>QuestEffect


Resource contenant :


* `type` ∈ {GOLD, TAG\_PLAYER, REL\_GIVER, REL\_ANT, TAG\_WORLD}
* `amount` (or / delta relation)
* `tag` (tag player/world)


Le système permet :


* même quête/template, résolutions différentes
* effets modulables et équilibrables sans toucher au code


---


## 7) Tags monde/joueur


Le
<a id="cite-questmanager-0ffcf2-4"></a>QuestManager maintient :


* `player_tags : Array[String]`
* `world_tags : Array[String]`


Ils servent de mémoire globale simple pour :


* influencer la génération (context tags, rules, unlocks…)
* marquer des états persistants (WAR\_SPIKING, DOMAIN\_*\_GROWING, WAR\_DECLARED, etc.)


---


## 8) Simulation de monde (Option B) : factions avec objectifs


Le monde avance par jours via un simulateur (
<a id="cite-worldsim-44f86b-1"></a>WorldSim /
<a id="cite-factionsim-d4515c-1"></a>FactionSim).


###

<a id="cite-factionsim-d4515c-2"></a>FactionSim


Chaque jour :


* choisit une faction
* s’assure qu’elle a un objectif (`
<a id="cite-factiongoalmanagerrunner-a52b6d-1"></a>FactionGoalManagerRunner.ensure_goal(faction_id)`)
* planifie une action (`
<a id="cite-factiongoalplanner-73d377-1"></a>FactionGoalPlanner.plan_action(goal)`)
* applique l’action (`
<a id="cite-factiongoalmanagerrunner-a52b6d-2"></a>FactionGoalManagerRunner.apply(action)`)


Les actions peuvent produire :


* des tags monde
* des changements de relation entre factions
* des progressions de goals
* des offers de quêtes (notamment goal offers)

### Goals structurés (steps + progress)


Un goal est composé de steps (ex: gather → secure → build).

Chaque step peut produire :


* logs
* progression
* offers de quêtes liées au goal (`is_goal_offer = true`, `goal_step_id`, `goal_domain`, etc.)


---


## 9) Héros IA : compétition sur les offers


Un test de simulation (Hero competition) existe :


* Des héros IA prennent parfois une offer avant le joueur
* Ils démarrent la quête (ACTIVE), résolvent ou échouent/expirent
* Cela crée une dynamique d’écosystème : offers consommées / expirées / prises


---


## 10) Artefacts perdus / Loot sites / Quêtes de récupération


Un système existe pour :


* créer un artefact dans l’inventaire d’une armée
* détruire l’armée → spawn d’un **
<a id="cite-lootsite-9df50b-2"></a>LootSite** à la position
* l’artefact devient “owner\_type=LOOT\_SITE, owner\_id=loot\_xxx”
* si le
<a id="cite-lootsite-9df50b-3"></a>LootSite expire → owner devient LOST


Une quête “Retrieve artifact X” est générée avec context :


* `artifact_id`
* `owner_type`, `owner_id` (si loot site)
* `resolution_profile_id = artifact_recovery` (ou autre)


Offers liées à un
<a id="cite-lootsite-9df50b-4"></a>LootSite sont invalidées si :


*
<a id="cite-lootsitemanager-ee96d2-1"></a>LootSiteManager n’existe pas
*
<a id="cite-lootsitemanager-ee96d2-2"></a>LootSiteManager.sites ne contient plus owner\_id


---


## 11) Arcs narratifs (Option A en cours) : Rivalité de factions (MVP)


Un arc “Faction Rivalry” existe (MVP contrôlé) :


###

<a id="cite-factionrivalryarc-78cb4d-1"></a>FactionRivalryArc


* `attacker_id`, `defender_id`
* `stage` : 1 PROVOCATION, 2 ESCALATION, 3 DECISIVE, 4 RESOLVED (terminal)
* `started_day`, `last_event_day`
* `pending_retaliation`


###

<a id="cite-arcmanager-1d7a8c-2"></a>ArcManager


Déclenchement :


* `on_faction_hostile_action(attacker, defender, action)` ⇒ crée/assure un arc + spawn une offer d’arc.


Résolution :


*
<a id="cite-questmanager-0ffcf2-5"></a>QuestManager appelle
<a id="cite-arcmanager-1d7a8c-3"></a>ArcManager lors de `resolve_quest` via signal `quest_resolved(inst, choice)` ou appel direct `on_quest_resolution_choice`.
* Si la quête est une quête d’arc (`context.is_arc_rivalry=true`) :


	+ progression d’arc (LOYAL avance de stage)
	+ `pending_retaliation=true`


Retaliation rule (1 règle MVP) :


* `tick_day()` : si `pending_retaliation`, spawn une offer “retaliation” en inversant giver/antagonist.


Les offers d’arc sont des
<a id="cite-questinstances-05d563-1"></a>QuestInstances avec context :


* `is_arc_rivalry=true`
* `arc_id`, `arc_stage`, `arc_reason`
* `giver_faction_id`, `antagonist_faction_id`
* `resolution_profile_id` (ex: default\_simple)


---


## 12) Tests (harness)


Il existe un `
<a id="cite-questsystemtest-gd-c5b90c-1"></a>QuestSystemTest.gd` (test harness) qui valide :


* génération quest tier
* génération POI
* intégration
<a id="cite-questmanager-0ffcf2-6"></a>QuestManager (start/progress/resolve)
* pipeline Palier 2 (LOYAL/NEUTRAL/TRAITOR + effects)
* offers caps / expiration (max offers)
* simulation monde multi-jours (goals, tags, relations, offers)
* arcs rivalry MVP (retaliation)
* artefact lost / loot site / retrieve quest (test 10/11 selon versions)


---


## 13) Convention Runner / Autoload


Plusieurs systèmes sont en autoload avec parfois un nom différent de `class_name` (à cause de Godot).

Ex : `
<a id="cite-arcmanagerrunner-f86edc-1"></a>ArcManagerRunner`, `
<a id="cite-factiongoalmanagerrunner-a52b6d-3"></a>FactionGoalManagerRunner`, etc.


Le code fait souvent :


* `if
<a id="cite-xxxrunner-7f5129-1"></a>XxxRunner != null and
<a id="cite-xxxrunner-7f5129-2"></a>XxxRunner.has_method(...)`


---


Si tu veux, pour la prochaine conversation, tu peux ajouter à ce résumé :


* la liste exacte de tes autoloads actuels (nom autoload → script)
* la structure exacte de tes relations inter-factions (où est stocké `humans|orcs : -70`, etc.)
* comment
<a id="cite-questpool-43825e-2"></a>QuestPool est branché (
<a id="cite-questpool-43825e-3"></a>QuestPool.try\_add\_offer vs
<a id="cite-questoffersimrunner-664bb4-1"></a>QuestOfferSimRunner.try\_add\_offer)


**ChatGPT:**
OK — j’ai pris connaissance :


* de ton **résumé “état actuel”** (procédural + QuestTemplate/QuestInstance + offers/active + résolution LOYAL/NEUTRAL/TRAITOR + simulation + arcs + artefacts/lootsites),
* et des documents fournis (quêtes/campagnes/crises, POI, axes, événements, ères/IA, logistique).


### Ce que je comprends du contexte “jeu” (couche design)


* **Orchestration globale** autour d’un `WorldGameState` qui coordonne `QuestManager`, `CampaignManager`, `CrisisManager`, `FactionManager`, avec un `EventBus` pour la communication inter-systèmes. fileciteturn1file1
* Un **système de quêtes/campagnes en tiers** (du local jusqu’aux crises mondiales), avec génération procédurale via `QuestGenerator` + `QuestPool` (templates par catégorie/tier). fileciteturn2file8turn2file9
* Un **contrôle d’apparition par tags + conditions** (tags monde/joueur, saisons, guerres, réputation, prérequis), avec propagation de tags qui rafraîchit la disponibilité des quêtes. fileciteturn1file16turn1file14
* Une couche **campagnes narratives** (chapitres, progression, rewards, conditions de déverrouillage, impacts monde + relations de factions). fileciteturn1file0turn1file2turn1file5
* Une couche **crises mondiales** (phases, time limit, contribution, quêtes injectées par phase, effets succès/échec, save/load). fileciteturn1file6turn2file4
* Le “terrain de jeu” : **POI catégorisés et transformables** par factions/événements/ères, servant d’ancrages naturels à exploration/combat/quête. fileciteturn2file16
* Le rythme de run : **logistique & repos** (nourriture, transport, or, reliques, moral, endurance, repos dépendant de la zone, marche forcée, etc.). fileciteturn2file3turn2file6
* L’évolution long terme : **ères (runs) avec événements N1→N5**, et une **IA stratégique** (personnalités, réaction aux crises, priorités). fileciteturn2file10turn0file3
* L’identité du monde : **axes Techno/Magie/Nature/Divin/Corruption** (niveaux, bâtiments, unités, transformations) qui influencent factions, événements et contenu. fileciteturn0file2


### Comment ça se “colle” avec ton implémentation actuelle (couche système)


* Ton triptyque **Offer → Active → Résolution** colle très bien avec le modèle “disponible/active/complétée” documenté côté `QuestManager`, mais toi tu l’as déjà poussé plus loin avec des **QuestInstance runtime + context riche + profils de résolution** (et la compétition IA / arcs / lootsites). fileciteturn1file14turn2file15
* Tes choix **LOYAL / NEUTRAL / TRAITOR** s’alignent naturellement avec la philosophie “**Soutenir / S’enrichir / Trahir**” des campagnes/branches décrites dans `QuestSystem.md`. fileciteturn2file17turn1file10


### Point important (à garder en tête)


Dans tes docs “QuestManager/CampaignManager/CrisisManager”, on voit une approche très *resource-driven* (IDs de quêtes, disponibilité via conditions, etc.). fileciteturn1file14turn1file16

Ton résumé, lui, décrit une approche plus *runtime/procédurale* (instances uniques, offers pool, invalidation, context, arcs, loot ownership). Les deux sont compatibles : il suffit de considérer les `.tres`/templates comme une **source de formes**, et tes `QuestInstance` comme la **réalité runtime**.


Si tu veux enchaîner maintenant, je peux directement :


* proposer une **terminologie unifiée** (mêmes noms pour offers/disponibles, runtime\_id, template\_id, etc.),
* ou écrire un **plan d’intégration** “Campaign/Crisis (docs) ↔ Offers/Arcs/Lootsites (actuel)” sans refaire le système.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 1](#toc-detail-ch1)
<a id="moi-2"></a>
**Moi 2:**
Je voudrais qu'on discute du
<a id="cite-arcmanager-1d7a8c-4"></a>ArcManager

Actuellement, une action histile d'une faction permet de declencher une rivalité, ce qui va entrainer une action de vengeance, ce qui entraine une action histile vers la faction d'origine.

Ca risque de faire une boucle est de toujours mener a l'escalade.

Deja, je voudrais qu'on discute de quand arreter une rivalité et de comlent et sur quelle critere la faire evoluer.

Je voudrais que ca puisse mzner tant a une guerre d'extermination qu'a une alliance, voir une fusion des deux factions majeures.

En gros, je ne veux pas que l'historique des relation (parce qu'actuellement, je conserve un historiqie des actions hostile et des rettribution) conduisent forcement a l'escalade


**ChatGPT:**
Oui, avec ton modèle actuel “hostile action ⇒ rivalité ⇒ vengeance ⇒ hostile action inverse”, tu as une **boucle déterministe** qui *tend* mécaniquement vers l’escalade. La clé, c’est que l’arc ne doit pas “répondre” automatiquement par de l’hostilité : il doit **choisir une réponse** parmi plusieurs options, guidé par des métriques (tension, coût, opportunité, objectifs…).


Voici une façon solide de cadrer **quand arrêter**, **comment évoluer**, et comment rendre possible **extermination / paix / alliance / fusion**, sans que l’historique impose l’escalade.


---


## 1) Remplacer “pending\_retaliation” par un vrai modèle de dynamique


Au lieu de `pending_retaliation=true`, donne à chaque arc quelques **variables continues** :


* **tension** (0..100) : chaleur du conflit
* **grievance\_A→B** et **grievance\_B→A** (0..100) : “dette” ressentie par chaque camp
* **trust** (-100..+100) : confiance/défiance (peut remonter !)
* **war\_weariness\_A / \_B** (0..100) : fatigue, coût interne, lassitude
* **opportunity** (0..100) : capacité réelle à frapper maintenant (armées proches, logistique, etc.)
* **external\_pressure** : menace commune / crise / médiation possible


L’historique n’est plus un rail, c’est un **input** qui alimente ces variables.


---


## 2) Une rivalité doit pouvoir “répondre” autrement que par la vengeance


À chaque tick (jour / semaine), pour un arc, tu fais choisir une **réponse** à chaque camp (ou au “camp actif” du tour). Exemple d’ensemble d’actions possibles :


### Réponses hostiles


* **Raid / escarmouche** (petit coût, petite tension)
* **Coup majeur** (gros coût, grosse tension)
* **Guerre ouverte** (change le “mode” du conflit)

### Réponses non-hostiles mais “dures”


* **Sanctions / embargo**
* **Propagande / sabotage / espionnage**
* **Ultimatum / demande de réparation**
* **Renforcement défensif** (pas d’attaque, mais monte la préparation)

### Réponses d’apaisement


* **Ignorer / temporiser** (laisse la dette diminuer si fatigue haute)
* **Proposer trêve** (réduit tension, demande concessions)
* **Payer réparation / rendre artefact / libérer prisonniers**
* **Médiation** par une 3e faction


👉 Le point important : même avec “grief élevé”, la faction peut **ne pas** frapper si (fatigue élevée) ou (mauvaise opportunité) ou (menace externe).


---


## 3) Évolution par “stades” + transitions probabilistes (pas déterministes)


Garde tes stades, mais fais-les dépendre de la *combinaison* tension / trust / fatigue / opportunité, avec des transitions **non garanties**.


Exemple de stades utiles :


1. **Incident** (PROVOCATION)
2. **Feud** (ESCALATION faible : raids, représailles limitées)
3. **War** (guerre ouverte)
4. **Total War** (extermination / siège / destruction)
5. **Truce** (cessation des hostilités, fragile)
6. **Peace** (stabilisé)
7. **Alliance**
8. **Confederation / Fusion** (terminal)
9. **Annihilated / Subjugated** (terminal)

### Règle simple de transition


* Tension haute + opportunité haute + fatigue basse ⇒ **escalade probable**
* Tension haute + fatigue haute ⇒ **trêve / pause probable**
* Tension moyenne + menace externe forte ⇒ **alliance possible** (ennemi commun)
* Trust remonte au-dessus d’un seuil + objectifs convergents ⇒ **paix durable / alliance**
* Power ratio extrême + trust pas trop bas + proximité culturelle ⇒ **vassalisation / fusion**


---


## 4) “Quand arrêter une rivalité ?” (conditions terminales claires)


Tu veux des issues variées : fixe des **conditions de fin** (RESOLVED) explicites :


### Fin “violente”


* **Extermination** : une faction passe sous un seuil (armée/territoire/population)
* **Capitulation / vassalisation** : grief élevé d’un côté + ratio de puissance défavorable + fatigue max
* **Annexion** : victoire + contrôle de POI clés + décision politique (tag monde)

### Fin “politique”


* **Traité de paix** : tension < X pendant Y jours + concessions acceptées
* **Alliance** : menace externe + confiance > seuil + bénéfices stratégiques
* **Fusion** : alliance stable + confiance haute + (leader trait / idéologie compatible) + “période d’union”


### Fin “extinction naturelle”


* **Désintérêt / oubli** : si aucun incident pendant N jours, tension et griefs décroissent jusqu’à 0 ⇒ arc se clôt


---


## 5) Comment éviter la boucle de vengeance “à coup sûr”


Voilà 6 garde-fous très efficaces :


1. **Cooldown** : un arc ne génère pas d’événement tous les jours (ex : min 3–7 jours entre 2 actes majeurs).
2. **Décroissance** : chaque jour sans incident, `tension -= decay` et `grievance -= decay_grief`.
3. **Coût interne** : chaque action hostile augmente `war_weariness`. À fatigue haute, la valeur d’une vengeance chute.
4. **Rendements décroissants** : la 5e représaille “identique” apporte moins de gain politique/stratégique.
5. **Opportunité** : pas de représaille si pas de moyens (armées loin, logistique faible, crise interne).
6. **Sortie honorable** (“face-saving”) : réparations, échange de prisonniers, ultimatum, médiation… qui “paient” la dette sans escalade.


---


## 6) Comment rendre possibles alliance et fusion (même après hostilités)


Il te faut des **mécaniques de remontée de trust**, sinon tu n’iras jamais vers “+”.


Sources réalistes de regain de confiance :


* **Ennemi commun** (crise mondiale / 3e faction agressive)
* **Intérêts convergents** (commerce, accès à une ressource/POI, religion/idéologie)
* **Actions de réparation** (payer, rendre un artefact, sauver un héros, aider en logistique)
* **Quêtes “pont”** : missions spéciales (escorte diplomatique, mariage politique, purge d’un traître commun, pacte de non-agression)


Concrètement : certaines résolutions de quêtes (LOYAL/NEUTRAL/TRAITOR) peuvent **augmenter trust** ou **réduire grief** au lieu d’ajouter du conflit.


---


## 7) Proposition d’implémentation minimaliste (compatible avec ton ArcManager actuel)

### Données à ajouter à `FactionRivalryArc`


* `tension`
* `grievance_attacker`, `grievance_defender`
* `trust`
* `weariness_attacker`, `weariness_defender`
* `cooldown_until_day`


### Tick


* appliquer décroissance tension/grief
* si `day < cooldown_until_day` ⇒ rien
* sinon : choisir une **réponse** (retaliate / hard\_nonhostile / deescalate) via un score simple :


Exemple d’intuition de score (pas besoin de ML) :


* **score\_retaliate** = grievance + tension + opportunity − weariness − external\_threat\_penalty
* **score\_deescalate** = weariness + external\_threat + low\_opportunity + (tension\_trop\_haute\_qui\_devient\_dangereuse)
* **score\_hard\_nonhostile** = grievance + low\_opportunity + politique\_interne


Puis tu spawns une offer correspondant à la réponse choisie.


---


Si tu veux, on peut maintenant faire un vrai “design pass” sur ton ArcManager en 2 étapes :


1) On définit **les variables minimales** (celles qui te donnent déjà 80% du résultat sans complexité).

2) On définit une **liste de réponses** (5–8) + quelles quests/offers elles génèrent + quels effets elles appliquent (tension/trust/grief/weariness), et **les conditions terminales** (guerre, paix, alliance, fusion).


Dis-moi juste : tu veux que le tick d’arc soit **journalier** (comme ta sim) ou plutôt **hebdomadaire** (moins d’événements, plus lisible) ?


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 2](#toc-detail-ch2)
<a id="moi-3"></a>
**Moi 3:**
Journalier


**ChatGPT:**
Journalier, c’est très bien — mais il faut absolument que le tick **ne génère pas automatiquement une vengeance**. Il doit *évaluer* la situation et parfois… ne rien faire, temporiser, négocier, ou même coopérer.


Voilà une proposition **simple à implémenter** dans ton ArcManager actuel (sans tout refondre), qui règle :


* l’arrêt d’une rivalité,
* son évolution,
* et des issues allant de **guerre d’extermination** à **alliance / fusion**,

sans que l’historique force l’escalade.


---


## 1) Changer le cœur : “pending\_retaliation” → variables d’arc + décision quotidienne


Dans `FactionRivalryArc`, ajoute quelques métriques (valeurs bornées, faciles) :


* `tension` (0..100) : chaleur globale
* `grievance_A` et `grievance_B` (0..100) : “dette” ressentie par chaque camp
* `trust` (-100..+100) : confiance (peut remonter)
* `weariness_A`, `weariness_B` (0..100) : fatigue/coût interne
* `cooldown_until_day` : empêche spam (ex : min 2–5 jours entre “événements d’arc”)


L’**historique** (tes logs d’hostilité/retaliation) reste utile pour le récit, mais n’est plus la “mécanique”.


---


## 2) Tick journalier : décroissance + probabilité d’événement + choix d’une réponse


### A) Décroissance (anti-boucle)


Chaque jour, **si pas d’incident majeur** :


* `tension -= 1` (clamp 0..100)
* `grievance -= 0.5`
* `trust += 0.2` (jusqu’à un plafond)
* `weariness -= 0.3` (si pas en guerre)


Ça garantit qu’une rivalité peut “mourir” naturellement si rien n’alimente la boucle.


### B) Ne pas générer un event tous les jours


Même en tick journalier, fais une **chance** de produire une offer d’arc :


* `event_chance = clamp(0.05 + tension/250 - avg_weariness/300, 0.0, 0.35)`


Si tirage échoue → rien aujourd’hui (mais les valeurs continuent d’évoluer).


### C) Choisir une “réponse” (pas forcément hostile)


Tu définis 6–8 actions-types que l’arc peut produire sous forme d’offers :


**Hostiles**


* `RAID` (petit)
* `MAJOR_STRIKE` (gros)
* `DECLARE_WAR` (change d’état)


**Non-hostiles dures**


* `ULTIMATUM` (demande réparation)
* `SABOTAGE/ESPIONAGE` (pression sans bataille)


**Apaisement**


* `TRUCE_TALKS` (trêve)
* `REPARATIONS` (payer/rendre/compensation)
* `MEDIATION` (via 3e faction) *(optionnel mais puissant pour casser l’escalade)*


Chaque jour où un event est possible, tu scores ces options et tu prends la meilleure.


Exemple de scoring simple (tu peux faire ça en dur, pas besoin d’IA) :


* **Retaliate** score ↑ avec `grievance` + `tension` + `opportunity`, ↓ avec `weariness` + `external_threat`
* **De-escalate** score ↑ avec `weariness` + `external_threat` + “mauvaise opportunity”
* **Hard-non-hostile** score ↑ avec `grievance` mais ↓ si “tension déjà trop haute”


>
> `opportunity` peut être approximée au début (random pondéré par tier, proximité, forces), puis raffinée quand ta sim/logistique est prête.
>
>
>


---


## 3) Stades + conditions d’évolution (sans déterminisme)


Garde une machine à états, mais avec **transitions conditionnelles** :


* `INCIDENT` → `FEUD` si `tension >= 25`
* `FEUD` → `WAR` si `tension >= 60` ET `min(grievance_A, grievance_B) >= 40` ET `avg_weariness < 70`
* `WAR` → `TOTAL_WAR` si `tension >= 85` ET `trust <= -60` ET `avg_weariness < 80`
* `WAR/FEUD` → `TRUCE` si `avg_weariness >= 80` OU `external_threat` très haut
* `TRUCE` → `PEACE` si `tension <= 20` pendant `7 jours` ET `grievances <= 10`
* `PEACE` → `ALLIANCE` si `trust >= 40` pendant `14 jours` ET (ennemi commun OU intérêts convergents)
* `ALLIANCE` → `FUSION` si `trust >= 75` pendant `30 jours` ET (compatibilité/objectif commun) ET (ratio puissance très déséquilibré OU “union volontaire”)


>
> La “compatibilité” peut être ultra simple : tags de doctrine/axe/biome/diplomatie, ou juste une table de compatibilités par faction.
>
>
>


---


## 4) Quand arrêter l’arc (RESOLVED) : critères terminaux


Tu veux éviter l’escalade *infinie* → il faut des fins claires :


### Fins “dures”


* **Extermination** : faction sous seuil (territoires/armées/pop) → `ANNIHILATED`
* **Capitulation / vassalisation** : un camp a `weariness` très haut + ratio de puissance défavorable → `SUBJUGATED`
* **Annexion** : contrôle de POI clés + victoire → `ANNEXED`


### Fins “douces”


* **Paix durable** : `PEACE` stable X jours → `RESOLVED_PEACE`
* **Alliance stable** : `ALLIANCE` stable X jours → `RESOLVED_ALLIANCE`
* **Fusion** : `MERGED` terminal


### Extinction naturelle


* Si `tension == 0` et `grievances == 0` pendant `N jours` → `RESOLVED_FORGOTTEN`


---


## 5) Le point crucial : comment une action hostile “paie” la dette (sinon boucle)


Quand une faction réussit une représaille, tu dois **réduire sa grievance**, sinon elle reste “en dette” et retape à l’infini.


Ex :


* `RAID` réussi :
	+ grievance du camp qui frappe **-15**
	+ tension **+10**
	+ grievance du camp frappé **+10**
	+ trust **-5**
	+ weariness du camp qui frappe **+5**
* `TRUCE_TALKS` réussi :
	+ tension **-15**
	+ trust **+10**
	+ grievances **-10**
* `REPARATIONS` :
	+ grievances du receveur **-20**
	+ trust **+5**
	+ tension **-10**


Ça crée un système où “frapper” peut satisfaire (donc calmer *à court terme*) mais dégrade trust et augmente fatigue, ce qui pousse ensuite vers trêve/paix.


---


## 6) Intégration avec tes quêtes LOYAL/NEUTRAL/TRAITOR


Chaque offer d’arc doit préciser `arc_action_type`. Dans `on_quest_resolution_choice(inst, choice)` tu appliques une matrice d’effets **selon l’action** :


* Sur une quête de `RAID` :


	+ LOYAL = l’attaque réussit (effets hostiles + “paiement” de grievance)
	+ NEUTRAL = sabotage limité (moins de tension, moins de paiement)
	+ TRAITOR = tu aides l’autre camp (trust bascule / grief inversé)
* Sur `TRUCE_TALKS` :


	+ LOYAL = trêve signée (gros -tension, +trust)
	+ NEUTRAL = statu quo (petit -tension)
	+ TRAITOR = trêve sabotée (tension +, trust --)


C’est ça qui te permet d’aller vers alliance/fusion *même après des coups*.


---


### Si tu veux un “MVP” en 2 heures de code


1) Ajouter les variables (`tension/grievance/trust/weariness/cooldown`)

2) Tick journalier avec décroissance + chance d’event + cooldown

3) 4 actions seulement au début : `RAID`, `ULTIMATUM`, `TRUCE_TALKS`, `IGNORE`

4) Matrices d’effets sur `quest_resolved` pour ces 4 actions

5) Conditions de fin : oubli / paix / guerre totale / annihilation


Ensuite tu ajoutes `ALLIANCE` puis `FUSION` quand tu es content de la stabilité.


Si tu veux, je peux te proposer **des valeurs par défaut** (seuils + deltas) qui donnent un comportement “organique” (pas trop belliqueux, mais capable de spiraler en guerre totale quand les conditions s’alignent).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 2](#toc-detail-ch2)
<a id="moi-4"></a>
**Moi 4:**
Chaque faction va aussi avoir une personalité, je pense qu'il faut prendre ca en compte dans le calcule.

Par exemple, une faction pacifique fait baisser la grievance plus vite, a l'inverse d'une belliqueuse.

Une expansionniste aura un cout pour la guerre moins elevée etc


**ChatGPT:**
Oui — la personnalité doit entrer **à deux endroits** :


1) dans la **physique** de l’arc (comment tension/grievance/trust/weariness évoluent naturellement chaque jour),

2) dans la **prise de décision** (quelles réponses la faction privilégie à situation égale).


Et c’est exactement ce qui te permettra d’avoir des arcs qui peuvent se calmer, se retourner, ou au contraire dégénérer.


---


## 1) Modèle de personnalité simple (data-driven)


Je te conseille 5–7 axes max, sinon tu vas te noyer. Par exemple :


* **aggression** (0..1) : goût pour l’action hostile
* **vengefulness** (0..1) : besoin de “payer la dette” (grievance)
* **diplomacy** (0..1) : préférence pour trêves/accords
* **risk\_aversion** (0..1) : prudence, peur des coûts
* **expansionism** (0..1) : intérêt structurel à la guerre/prise de territoire
* **honor** (0..1) : valeur accordée aux traités / “sauver la face”
* (optionnel) **cunning** (0..1) : préférence pour sabotage/espionnage plutôt que frontal


Tu peux stocker ça dans un `FactionPersonalityProfile.tres` par faction, ou via ton système de tags.


---


## 2) La personnalité modifie les “deltas” journaliers (anti-escalade naturelle)

### A) Décroissance de grievance (ton exemple pacifique/belliqueux)


Au lieu d’un `grievance -= 0.5` fixe :


* `grievance_decay = base_decay * (1.6 - 0.9*vengefulness) * (0.8 + 0.6*diplomacy)`
	+ pacifique/diplomate → grief retombe vite
	+ vindicatif → retombe lentement


### B) Coût/fatigue de guerre (ton exemple expansionniste)


Au lieu d’un `weariness += +5` fixe sur une action hostile :


* `weariness_gain = base_weariness * (0.7 + 0.6*risk_aversion) * (1.1 - 0.5*expansionism)`
	+ expansionniste → “coût perçu” plus bas (mais pas zéro)
	+ prudent → fatigue grimpe vite


### C) Récupération de trust


* `trust_recovery = base_trust * (0.6 + 0.8*diplomacy) * (0.9 - 0.4*aggression)`


👉 Résultat : même avec historique hostile, une faction pacifique va **laisser la température redescendre** plus naturellement, sans que tu forces une boucle.


---


## 3) La personnalité modifie le choix de réponse (scoring)


Tu gardes ton choix d’action par score, mais tu ajoutes un **bias personnalité**.


Exemple pour 4 actions MVP : `RAID`, `ULTIMATUM`, `TRUCE_TALKS`, `IGNORE`.


### Score “RAID”


```
score_raid =
  + 1.2*grievance
  + 0.8*tension
  + 0.6*opportunity
  - 1.0*weariness
  + 25*aggression
  + 20*expansionism
  + 15*vengefulness
  - 25*risk_aversion
  - 15*diplomacy
```


### Score “TRUCE\_TALKS”


```
score_truce =
  + 0.8*weariness
  + 0.5*external_threat
  - 0.6*grievance
  - 0.4*tension
  + 30*diplomacy
  + 15*honor
  + 10*risk_aversion
  - 20*aggression
  - 10*vengefulness
```


### Score “ULTIMATUM” (pression sans attaque)


Très utile pour casser la boucle “vengeance automatique” :


```
score_ultimatum =
  + 0.9*grievance
  + 0.4*tension
  + 15*honor
  + 10*diplomacy
  + 10*risk_aversion
  - 10*aggression
```


### Score “IGNORE”


Option ultra importante en journalier :


```
score_ignore =
  + 0.9*weariness
  - 0.6*opportunity
  + 20*risk_aversion
  + 10*diplomacy
  - 10*vengefulness
```


---


## 4) La personnalité modifie aussi les seuils d’évolution / fin


Tu peux rendre les transitions **variables par faction**.


### Exemple : seuil de passage en “WAR”


Au lieu de `tension >= 60` fixe :


* faction belliqueuse : `war_threshold = 50`
* faction pacifique : `war_threshold = 75`


Formule simple :

`war_threshold = 70 - 20*aggression - 10*expansionism + 15*diplomacy`


### Acceptation d’alliance / fusion


* alliance possible si `trust` monte, mais le seuil dépend :

`alliance_threshold = 50 + 20*vengefulness - 25*diplomacy - 10*honor`


Fusion (plus rare) :


* nécessite `trust` haut **et** `honor` ou intérêt expansionniste (confédération)
* ou “dominant + vassal” (expansionism haut côté dominant, risk\_aversion haut côté dominé)


---


## 5) Exemples concrets de comportements


### Faction pacifique (diplomacy haute, aggression basse, vengefulness basse)


* grievance retombe vite
* choisit souvent `ULTIMATUM` / `TRUCE_TALKS` / `IGNORE`
* peut passer d’hostilité à alliance si ennemi commun / médiation


### Faction belliqueuse (aggression + vengefulness hautes)


* grievance retombe lentement
* préfère `RAID`/`MAJOR_STRIKE`
* escalade plus facilement vers WAR/TOTAL\_WAR


### Faction expansionniste (expansionism haut)


* “coût perçu” de guerre plus bas
* tend à déclarer guerre si opportunité (frontières, POI, faiblesse)
* mais peut aussi accepter “fusion/vassalisation” comme issue logique


---


## 6) Implémentation minimaliste dans ton ArcManager


* `ArcManager.tick_day()` :

1) pour chaque arc : appliquer **decay** avec multiplicateurs personnalité (par camp)

2) si cooldown OK et tirage event OK :
	+ calculer scores d’actions **par camp** en injectant personnalité
	+ choisir l’action gagnante (ou une action “globale arc” si tu veux rester simple)
	+ spawn l’offer correspondante avec `context.arc_action_type`


	3) sur `quest_resolved` : appliquer la matrice d’effets + “paiement de grievance”


---


Si tu veux, on peut faire la prochaine étape très concrète : tu me dis quelles **personnalités** tu veux au minimum (ex : Pacifique, Pragmatique, Belliqueuse, Expansionniste, Fanatique), et je te propose une table de valeurs par archétype (axes 0..1) + les multiplicateurs (decay/grief/weariness) + les poids de scoring déjà calibrés pour que ça “vive” en journalier sans spam ni escalade inévitable.


**ChatGPT:**
Carrément. La personnalité devient ton “anti-boucle” naturel : elle influence **l’inertie** (decay) *et* les **préférences d’action** (scoring). Je te propose un cadre **léger** qui marche bien en tick journalier.


## 1) Axes de personnalité (0..1) + un bonus utile pour fusion


Garde ça simple :


* `aggression` : tendance à attaquer
* `vengefulness` : rancune (grievance retombe lentement)
* `diplomacy` : tendance à négocier / apaiser
* `risk_aversion` : peur des coûts (fatigue pèse plus)
* `expansionism` : intérêt structurel à la guerre/territoire
* `integrationism` : propension alliance → fusion (culture/idéologie “assimilatrice”)

## 2) Effets “physiques” journaliers (ça casse l’escalade automatique)

### Décroissance de grievance (pacifique vs belliqueuse)


```
grievance_decay = base * (1.4 - 0.9*vengefulness) * (0.8 + 0.6*diplomacy)
```


* pacifique/diplomate → la dette retombe vite
* vindicative → elle colle


### Coût perçu de la guerre (expansionniste)


```
weariness_gain = base * (0.7 + 0.6*risk_aversion) * (1.1 - 0.5*expansionism)
```


* expansionniste → “paie” moins de fatigue pour le même acte
* prudente → fatigue grimpe vite ⇒ pousse trêve/ignore


### Remontée de trust (pour alliance/fusion)


```
trust_recovery = base * (0.6 + 0.9*diplomacy) * (0.9 - 0.4*aggression)
```


>
> Avec juste ces 3 lignes, tu peux avoir des rivalités qui **s’éteignent** sans nouvelle provocation.
>
>
>


## 3) Décision quotidienne : personnalité = biais sur le score des actions


Tu calcules des scores pour quelques actions (MVP : `RAID`, `ULTIMATUM`, `TRUCE_TALKS`, `IGNORE`) et tu ajoutes un biais :


* `RAID` aime `aggression + vengefulness + expansionism`, déteste `risk_aversion + diplomacy`
* `TRUCE_TALKS` aime `diplomacy + risk_aversion`, déteste `aggression + vengefulness`
* `ULTIMATUM` est le “pont” : pression sans escalade (super utile)
* `IGNORE` est vital en tick journalier (sinon tu spams des arcs)

## 4) Archétypes prêts à l’emploi (profils 0..1)


Tu peux démarrer avec ça :


| Archétype | aggression | vengefulness | diplomacy | risk\_aversion | expansionism | integrationism |
| --- | --- | --- | --- | --- | --- | --- |
| Pacifique | 0.15 | 0.20 | 0.85 | 0.70 | 0.20 | 0.60 |
| Pragmatique | 0.35 | 0.35 | 0.55 | 0.50 | 0.40 | 0.40 |
| Belliqueux | 0.80 | 0.70 | 0.20 | 0.30 | 0.60 | 0.20 |
| Expansionniste | 0.65 | 0.45 | 0.30 | 0.35 | 0.90 | 0.50 |
| Fanatique | 0.75 | 0.85 | 0.10 | 0.20 | 0.50 | 0.05 |
| Assimilateur (fusion) | 0.45 | 0.25 | 0.60 | 0.45 | 0.55 | 0.90 |


* **Pacifique** : grief descend vite, fatigue pèse beaucoup ⇒ trêve/ultimatum/ignore fréquents.
* **Belliqueux/Fanatique** : grief colle, fatigue “compte moins” ⇒ escalade plus probable.
* **Assimilateur** : plutôt diplomate + très intégrateur ⇒ alliance stable puis fusion possible.


## 5) Alliance / fusion sans “magie” : conditions + personnalité


Exemples de règles simples :


* **Alliance possible** si `trust >= 40` ET `tension <= 35` pendant X jours

et bonus si `(integrationism_A + integrationism_B) élevé` ou `external_threat` élevé.
* **Fusion possible** si `trust >= 75` pendant 30 jours ET `tension <= 15`

et `integrationism` élevé côté au moins une faction, + compatibilité (tags/axes/doctrine).


Tu peux aussi autoriser une **fusion “domination”** (vassalisation → fusion) si :


* ratio puissance très déséquilibré,
* fatigue très haute du dominé,
* et `integrationism` haut du dominant.


---


Si tu me dis **quels “types” de factions** tu as (orcs tribaux, empire humain, ordre religieux, nécromants, etc.) et quels axes (Tech/Magie/Nature/Divin/Corruption) tu utilises déjà dans leurs identités, je te propose une table de profils “cohérents lore” + les pondérations de score calibrées pour que, en journalier, tu voies :


* des vendettas qui meurent,
* des guerres qui partent parfois en total war,
* et des réconciliations/alliance/fusion quand le contexte s’y prête.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 3](#toc-detail-ch3)
<a id="moi-5"></a>
**Moi 5:**
Actuellement, on a un score de relation de chaque faction envers les autres. Il faut que ca soit pris en compte dans le calcul et il faut que ca evolue avec les actions. Il faut aussi que la faction ai un score de relation avec chacun des axes (Tech/Magie/Nature/Divin/Corruption).

Il faut prevoir la liste d'action/quete qui vont decouler des calculs (tu en as deja parler). Je pense qu'on pourra conserver tous les score que tu calcules dans une seule structure de donnés (
<a id="cite-factionrelationscore-783d2e-1"></a>FactionRelationScore) on mettra ensuite ca dans un dictionnaire faction\_id ->
<a id="cite-factionrelationscore-783d2e-2"></a>FactionRelationScore. Chaque faction aura ce dictionnaire. Les types de personnalités, les races (procedurales ou non) et les axes (il n'y en a que 5 et tu les as cité) sont dans les documents que je t'ai donné au depart. Mais en gros, c'est procedurale lors de la creation et ensuite le monde evoluera vers... je ne sais pas. Mais on peut avoir des orcs pacifiques dans une societé feodal (type moyen age européen) et en rejet de la magie.

Si les races sont classique (au moins dans une v1) le reste ne l'est pas forcément.


**ChatGPT:**
Oui — ton **score de relation inter-factions** doit devenir *l’axe principal* (et il doit évoluer), et les **axes (Tech/Magie/Nature/Divin/Corruption)** doivent influencer à la fois :


1) la relation “A ↔ B” (compatibilité idéologique / friction),

2) le choix des actions d’arc,

3) l’évolution possible (paix, alliance, fusion, extermination).


Les docs vont clairement dans ce sens : l’IA diplomatique est influencée par **personnalité + axes dominants + puissance relative + proximité** fileciteturn3file1, et les axes ont des **interactions fortes** (Nature vs Techno, Divin vs Corruption, etc.) fileciteturn3file2turn3file3. Tu as déjà la mécanique “réputation/relations” qui déclenche des seuils ally/enemy fileciteturn3file8, donc on s’appuie dessus.


---


## 1) Data model : `FactionRelationScore` directionnel + profil d’axes par faction


### A) Par faction : profil d’axes


Chaque faction a **un état par axe** (les 5) :


* `axis_level[axis] : 0..5` (progression par bâtiments/choix/conquêtes, et dominance possible) fileciteturn3file3
* `axis_affinity[axis] : -100..+100` (**opinion/adhésion** : “rejette la magie”, “vénère le divin”, “tolère techno”, etc.)


Ça colle à ton besoin “relation avec chacun des axes” et ça reste compatible avec le fait que les factions peuvent être **multi-axes** fileciteturn3file3.


### B) Par faction : dictionnaire vers les autres (`faction_id -> FactionRelationScore`)


Tu peux garder ton idée : *chaque faction possède* un dictionnaire “sa vision des autres”.


Je te propose un `FactionRelationScore` **minimal** (les “scores”, pas l’état d’arc) :


* `relation` : -100..+100 (ton score existant / “réputation”)
* `trust` : -100..+100 (remonte avec le temps + actes positifs)
* `grievance` : 0..100 (rancune / dette perçue)
* `tension` : 0..100 (risque d’incident/violence)
* `weariness` : 0..100 (fatigue de guerre vs ce rival)
* `last_event_day` / `cooldown_until_day`


>
> Tout ce qui est “stade de rivalité / arc\_id / war\_state” je le laisserais au **ArcManager** (sinon tu dupliques et tu te bats avec la cohérence).
>
>
>


---


## 2) Comment les axes influencent la relation A→B (sans figer le monde)


Tu veux “des orcs pacifiques féodaux anti-magie” : donc la race ne doit pas figer l’idéologie. La bonne approche : **race = faible biais**, axes + personnalité = vrai moteur.


### A) Calculer une “friction idéologique” A→B


Exemple (simple, efficace) :


* Pour chaque axe `X` :
	+ plus `B.axis_level[X]` est haut, plus ça “irrite” ou “attire” A selon `A.axis_affinity[X]`
	+ `axis_term_X = (A.axis_affinity[X] / 100) * (B.axis_level[X] / 5)`


Puis :


* `axis_compat = sum(axis_term_X)` (≈ entre -5 et +5)
* `axis_bias = axis_compat * 15` (converti en points de relation)


Et tu appliques ça comme **baseline** vers lequel `relation` dérive lentement.


Ça exploite tes interactions d’axes (ex : Divin vs Corruption, Nature vs Techno…) fileciteturn3file2turn3file3 et la logique “réaction aux axes” dans l’IA fileciteturn3file1.


### B) Drift quotidien (très important)


Chaque jour, si pas d’incident majeur :


* `relation += (baseline_relation - relation) * 0.01` (petit rappel)
* `tension -= decay`
* `grievance -= decay`
* `trust += recover`
* `weariness -= recover`


👉 C’est ça qui empêche l’historique de “verrouiller” une escalade éternelle.


---


## 3) Les actions d’arc : une liste finie (offers/quests) choisie par scoring


Tu voulais “prévoir la liste d’action/quête”. Je te propose une **bibliothèque d’actions d’arc** qui devient ton catalogue d’offers “arc\_rivalry”.


Chaque action :


* a des **préconditions** (stade, relation, tension, trust, grievance, axes…)
* génère une **QuestInstance** (offer) avec `context.arc_action_type`
* applique des **deltas** (sur relation/trust/grievance/tension/weariness + parfois axes)

### Actions “incident / feud” (évite boucle vengeance)


1) **EXCUSES / ENQUÊTE** (diplomatie soft)

2) **ULTIMATUM** (pression sans violence)

3) **REPARATIONS / TRIBUTE** (paie la dette)

4) **BORDER PATROL** (défensif, baisse tension si réussite)

5) **RAID** (petit hostile, “paie” grievance mais baisse trust)

### Actions “war”


6) **SKIRMISH** (escarmouche)

7) **SABOTAGE** (ciblé sur un axe : usine techno / nexus magique / temple / nid corrompu / forêt sacrée)

8) **SIEGE / CAPTURE\_POI** (impact carte via POI, cohérent avec ton système POI transformables) fileciteturn3file6

9) **ASSASSINATE\_CHAMPION** (N3/N4 style) fileciteturn3file9


### Actions “désescalade”


10) **TRUCE\_TALKS** (trêve)

11) **PRISONER\_EXCHANGE**

12) **MEDIATION** (3e faction, très bon contre l’escalade automatique)

### Actions “alliance / fusion”


13) **JOINT\_CRISIS\_RESPONSE** (ennemi commun : corruption/démons → alliances temporaires, cohérent IA) fileciteturn3file1

14) **TECH/MAGIC SHARING** (coopération d’axe, fait évoluer les affinités)

15) **UNION\_TREATY** (alliance formelle)

16) **INTEGRATION\_CAMPAIGN** (fusion : harmonisation lois/armée, purge extrémistes, administration commune)


>
> Tu peux même t’appuyer sur ton catalogue d’événements : “coalition spontanée”, “alliance apocalyptique”, etc., comme accélérateurs d’alliance/fusion fileciteturn3file9turn3file7.
>
>
>


---


## 4) Faire évoluer relation + axes avec les actions (et pas que l’inverse)

### A) Deltas sur relation (les deux sens, mais pas symétriques)


Quand A fait un raid sur B :


* A→B : grievance -X (A estime avoir “rendu”), weariness +, tension +, trust -
* B→A : grievance +X (B veut se venger), tension +, trust --, relation --


Ça évite la boucle “je frappe donc je refrappe” : **l’attaquant se calme** (sa grievance baisse), mais **le victime s’énerve**.


### B) Deltas sur axes (niveau + affinité)


Exemples :


* **Sabotage d’un Nexus (Magie)** :
	+ B.axis\_level[Magie] peut reculer (temporaire) + B.axis\_affinity[Magie] peut monter (“on doit renforcer la magie”)
	+ A.axis\_affinity[Magie] peut baisser (“ça confirme que c’est dangereux”)
* **Coop techno/magie** :
	+ A.axis\_affinity[Magie] monte un peu, B.axis\_affinity[Tech] monte un peu (effet “acculturation”)
* **Crise Corruption** :
	+ beaucoup de factions gagnent une “tolérance à coopérer” temporaire (alliances de survie), exactement comme décrit fileciteturn3file1


Les axes sont “au cœur de l’évolution des factions” et influencent les comportements fileciteturn3file3 : donc c’est cohérent que les quêtes laissent une trace sur axes + relations.


---


## 5) Seuils & intégration avec ton système actuel (enemy/ally + tags)


Tu as déjà le pattern “réputation >= 100 → ally, <= -100 → enemy” fileciteturn3file8 et des tags `war_*` / `peace` lors de déclaration de guerre/paix fileciteturn3file14.


Donc :


* si `relation(A→B)` et `relation(B→A)` passent sous un seuil + `tension` haut → **ArcManager déclenche WAR** (tag monde, state faction)
* si `tension` bas durablement + `trust` remonte → **ArcManager déclenche PEACE**
* si `trust` très haut + compatibilité/pression externe → **ALLIANCE**
* si alliance stable + `integrationism` (personnalité) + compatibilité d’axes → **FUSION**


Et surtout : la rivalité peut aussi **s’éteindre** si tension/grievance retombent à 0 pendant N jours.


---


Si tu veux qu’on enchaîne proprement, ma proposition est :


1) On fixe les **bornes** (relation -100..100, trust -100..100, grievance/tension/weariness 0..100) et les **decays journaliers**.

2) On définit 10–12 `arc_action_type` “MVP” (parmi la liste ci-dessus) avec leurs préconditions + deltas.

3) On branche ça sur ton pipeline existant `QuestInstance.context + resolve(choice)` pour que LOYAL/NEUTRAL/TRAITOR appliquent des deltas différents (et donc puissent mener à paix/alliance/fusion, pas seulement escalade).


Tu veux qu’on commence par écrire la **structure GDScript** de `FactionRelationScore` + `FactionAxisProfile`, ou par lister les **12 actions MVP** avec leurs préconditions/deltas ?


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 3](#toc-detail-ch3)
<a id="moi-6"></a>
**Moi 6:**
Appelons
<a id="cite-factionaxisprofile-93f0d3-1"></a>FactionAxisProfile plutot
<a id="cite-factionprofile-11982e-1"></a>FactionProfile.

On va avoir le
<a id="cite-factionprofile-11982e-2"></a>FactionProfile qui aura les score de personalité et les score d'afinité par axe

Les score par axes seront dans un dictionnaire (plus facile pour une recherche dynamique) et seront sur une echelle de -100 a +100

Les scores de personnalités seront sur un float de 0 a 1, ils serviront de multiplicateur pour les scores calculer. Ils seront aussi dans un dictionnaire (pourquoi pas le meme que les affinité d'axe, ca permet une recherche vraiment dynamique).

Pour les regles de generation sur les affinités avec les axes, il faut au moins un axe superieur a 50 et un autre inferieur a -20.

Il faudrait que la somme soient compris dans une fourchette (20 a 80, je te laisse me proposer une fourchette coherente qui créera de la dynamique dans le monde).

Pour les score de personnalité (regarde ce que tu as decrit plus haut). Ce sera un template par personnalité, mais on peut avoir une legere variation (de -0.1 a + 0.2, qu'en dis tu?)

Ecrivons les structure de donnée pour
<a id="cite-factionrelationscore-783d2e-3"></a>FactionRelationScore +
<a id="cite-factionprofile-11982e-3"></a>FactionProfile.


**ChatGPT:**
Parfait. Je te propose :


* **`FactionProfile`** : 2 dictionnaires (`axis_affinity` et `personality`), avec une méthode de lookup “dynamique” (qui cherche dans les deux).
* **`FactionRelationScore`** : les scores directionnels A→B (relation/trust/grievance/tension/weariness + cooldown).


### Fourchette cohérente pour la somme des affinités d’axes


Avec 5 axes en `[-100..100]` + contrainte “≥1 axe > 50” et “≥1 axe < -20”, une somme trop large dilue l’identité, et trop serrée force des profils similaires.


Je te propose : **somme ∈ [20 .. 90]**


* `>= 20` : évite les factions “anti-tout” (trop neutres/négatives) malgré un axe très positif.
* `<= 90` : évite les factions “pro-tout sauf un petit rejet”, et garde des tensions idéologiques.


Tu peux évidemment rendre ça configurable.


### Variation personnalité


Ton `[-0.1 .. +0.2]` marche bien si tu veux un monde un peu plus “caractérisé” (biais vers le haut). Je l’implémente tel quel, avec clamp `0..1`.


---


## `FactionProfile.gd`


```
# Godot 4.x

class\_name FactionProfile
extends RefCounted

# --- Keys (StringName) ---

const AXIS\_TECH: StringName = &"axis.tech"
const AXIS\_MAGIC: StringName = &"axis.magic"
const AXIS\_NATURE: StringName = &"axis.nature"
const AXIS\_DIVINE: StringName = &"axis.divine"
const AXIS\_CORRUPTION: StringName = &"axis.corruption"

const ALL\_AXES: Array[StringName] = [
 AXIS\_TECH, AXIS\_MAGIC, AXIS\_NATURE, AXIS\_DIVINE, AXIS\_CORRUPTION
]

const PERS\_AGGRESSION: StringName = &"pers.aggression"
const PERS\_VENGEFULNESS: StringName = &"pers.vengefulness"
const PERS\_DIPLOMACY: StringName = &"pers.diplomacy"
const PERS\_RISK\_AVERSION: StringName = &"pers.risk\_aversion"
const PERS\_EXPANSIONISM: StringName = &"pers.expansionism"
const PERS\_INTEGRATIONISM: StringName = &"pers.integrationism"

const ALL\_PERSONALITY\_KEYS: Array[StringName] = [
 PERS\_AGGRESSION,
 PERS\_VENGEFULNESS,
 PERS\_DIPLOMACY,
 PERS\_RISK\_AVERSION,
 PERS\_EXPANSIONISM,
 PERS\_INTEGRATIONISM
]

# --- Generation constraints ---

const AXIS\_MIN: int = -100
const AXIS\_MAX: int = 100

const AXIS\_REQUIRED\_POSITIVE\_GT: int = 50
const AXIS\_REQUIRED\_NEGATIVE\_LT: int = -20

# Proposed coherent range for sum(axis\_affinity.values())

const AXIS\_SUM\_MIN: int = 20
const AXIS\_SUM\_MAX: int = 90

# Personality variation around template values

const PERS\_VARIATION\_MIN: float = -0.1
const PERS\_VARIATION\_MAX: float = 0.2

# --- Data ---

# -100..100

var axis\_affinity: Dictionary[StringName, int] = {}

# 0..1

var personality: Dictionary[StringName, float] = {}

func \_init() -> void:
 # Defaults (optional): set everything to 0 / 0.5 if you want stable lookups
 for a in ALL\_AXES:
 axis\_affinity[a] = 0
 for k in ALL\_PERSONALITY\_KEYS:
 personality[k] = 0.5

# ---- Axis helpers ----

func set\_axis\_affinity(axis: StringName, value: int) -> void:
 axis\_affinity[axis] = clampi(value, AXIS\_MIN, AXIS\_MAX)

func get\_axis\_affinity(axis: StringName, default\_value: int = 0) -> int:
 return axis\_affinity.get(axis, default\_value)

func axis\_sum() -> int:
 var s := 0
 for a in ALL\_AXES:
 s += int(axis\_affinity.get(a, 0))
 return s

func validate\_axis\_rules() -> bool:
 var has\_pos := false
 var has\_neg := false
 for a in ALL\_AXES:
 var v: int = int(axis\_affinity.get(a, 0))
 if v > AXIS\_REQUIRED\_POSITIVE\_GT:
 has\_pos = true
 if v < AXIS\_REQUIRED\_NEGATIVE\_LT:
 has\_neg = true

 var s := axis\_sum()
 return has\_pos and has\_neg and s >= AXIS\_SUM\_MIN and s <= AXIS\_SUM\_MAX

# ---- Personality helpers ----

func set\_personality(key: StringName, value: float) -> void:
 personality[key] = clampf(value, 0.0, 1.0)

func get\_personality(key: StringName, default\_value: float = 0.5) -> float:
 return float(personality.get(key, default\_value))

# Applies small random variation to a template (Dictionary[StringName, float] of 0..1 values)

func apply\_personality\_template(template: Dictionary[StringName, float], rng: RandomNumberGenerator) -> void:
 for k in ALL\_PERSONALITY\_KEYS:
 var base := clampf(float(template.get(k, 0.5)), 0.0, 1.0)
 var delta := rng.randf\_range(PERS\_VARIATION\_MIN, PERS\_VARIATION\_MAX)
 set\_personality(k, base + delta)

# ---- Dynamic lookup (optional): one entry point for “search dynamique” ----

# If you pass an axis key, returns int as float (e.g. 42.0). If personality key, returns 0..1 float.

func get\_score\_dynamic(key: StringName, default\_value: float = 0.0) -> float:
 if axis\_affinity.has(key):
 return float(axis\_affinity[key])
 if personality.has(key):
 return float(personality[key])
 return default\_value
```


---


## `FactionRelationScore.gd`


```
# Godot 4.x

class\_name FactionRelationScore
extends RefCounted

const REL\_MIN: int = -100
const REL\_MAX: int = 100

const TRUST\_MIN: int = -100
const TRUST\_MAX: int = 100

const METER\_MIN: float = 0.0
const METER\_MAX: float = 100.0

# Directional: this is "from owner faction" -> "to target faction"

var target\_faction\_id: StringName

# Your existing “relation” score (reputation / opinion)

var relation: int = 0 # -100..100
var trust: int = 0 # -100..100

var grievance: float = 0.0 # 0..100
var tension: float = 0.0 # 0..100
var weariness: float = 0.0 # 0..100

var last\_event\_day: int = -999999
var cooldown\_until\_day: int = -999999

func \_init(target\_id: StringName = &"") -> void:
 target\_faction\_id = target\_id

func clamp\_all() -> void:
 relation = clampi(relation, REL\_MIN, REL\_MAX)
 trust = clampi(trust, TRUST\_MIN, TRUST\_MAX)
 grievance = clampf(grievance, METER\_MIN, METER\_MAX)
 tension = clampf(tension, METER\_MIN, METER\_MAX)
 weariness = clampf(weariness, METER\_MIN, METER\_MAX)

func apply\_delta(
 d\_relation: int = 0,
 d\_trust: int = 0,
 d\_grievance: float = 0.0,
 d\_tension: float = 0.0,
 d\_weariness: float = 0.0
) -> void:
 relation += d\_relation
 trust += d\_trust
 grievance += d\_grievance
 tension += d\_tension
 weariness += d\_weariness
 clamp\_all()

func is\_on\_cooldown(current\_day: int) -> bool:
 return current\_day < cooldown\_until\_day

func set\_cooldown(current\_day: int, days: int) -> void:
 cooldown\_until\_day = current\_day + max(days, 0)
```


---


Si tu veux, prochaine étape : je te propose une fonction de **génération procédurale** des `axis_affinity` qui garantit *à coup sûr* :


* 1 axe > 50,
* 1 axe < -20,
* somme dans `[20..90]`,

et qui garde une distribution intéressante (pas juste “un gros +, un petit -, le reste 0”).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 3](#toc-detail-ch3)
<a id="moi-7"></a>
**Moi 7:**
Oui s'il te plait, fait :

une fonction de génération procédurale des axis\_affinity qui garantit à coup sûr :


1 axe > 50,


1 axe < -20,


somme dans [20..90],

et qui garde une distribution intéressante (pas juste “un gros +, un petit -, le reste 0”)


**ChatGPT:**
Voici une **fonction de génération procédurale** (GDScript Godot 4) qui produit `axis_affinity` et garantit **à coup sûr** :


* au moins **1 axe > 50**
* au moins **1 axe < -20**
* **somme** des 5 axes dans **[20..90]**
* une distribution “vivante” : **au moins 2 des 3 axes restants** ont une magnitude significative (pas juste 0/0/0)


À coller directement dans `FactionProfile.gd`.


```
# --- In FactionProfile.gd ---

static func generate\_axis\_affinity(rng: RandomNumberGenerator) -> Dictionary[StringName, int]:
 # We retry because we want hard guarantees ("à coup sûr") with a nice distribution.
 for attempt in range(60):
 var d: Dictionary[StringName, int] = {}

 # 1) Pick one strong positive axis and one strong negative axis
 var axes := ALL\_AXES.duplicate()
 var pos\_axis: StringName = axes[rng.randi\_range(0, axes.size() - 1)]
 axes.erase(pos\_axis)
 var neg\_axis: StringName = axes[rng.randi\_range(0, axes.size() - 1)]
 axes.erase(neg\_axis)
 var rem\_axes: Array[StringName] = axes

 # Strong anchors (guarantee constraints)

# Keep some room for later adjustments.

 d[pos\_axis] = rng.randi\_range(60, 92)

# > 50 guaranteed, room up to 100

 d[neg\_axis] = -rng.randi\_range(25, 80)

# < -20 guaranteed, room down to -100

 # 2) Generate remaining axes with a "natural" distribution (not all near 0)

# We enforce at least 2 out of the 3 remaining axes with |value| >= 15.

 var ok\_distribution := false
 for \_resample in range(30):
 var strong\_count := 0
 for a in rem\_axes:
 var v := int(round(rng.randfn(0.0, 32.0)))

# normal-ish around 0

 # Push away from 0 sometimes, to avoid "0,0,0"
 if abs(v) < 8:
 v += (rng.randf() < 0.5 ? -1 : 1) * rng.randi\_range(10, 22)

# Avoid extremes too often (keeps room for sum-adjust)

 v = clampi(v, -75, 75)
 d[a] = v

 if abs(v) >= 15:
 strong\_count += 1

 if strong\_count >= 2:
 ok\_distribution = true
 break

 if not ok\_distribution:
 continue

 # 3) Choose a target sum inside [AXIS\_SUM\_MIN..AXIS\_SUM\_MAX] and adjust values to hit it
 var target\_sum := rng.randi\_range(AXIS\_SUM\_MIN, AXIS\_SUM\_MAX)
 var current\_sum := \_axis\_sum\_dict(d)
 var diff := target\_sum - current\_sum

 # Per-axis allowed ranges (to preserve the >50 and <-20 guarantees)
 var min\_allowed: Dictionary[StringName, int] = {}
 var max\_allowed: Dictionary[StringName, int] = {}
 for a in ALL\_AXES:
 min\_allowed[a] = AXIS\_MIN
 max\_allowed[a] = AXIS\_MAX
 min\_allowed[pos\_axis] = 51
 max\_allowed[pos\_axis] = 100
 min\_allowed[neg\_axis] = -100
 max\_allowed[neg\_axis] = -21

 # Adjustment loop: distribute diff across axes with available headroom.
 var iter := 0
 while diff != 0 and iter < 250:
 iter += 1

 var candidates: Array[StringName] = []
 for a in ALL\_AXES:
 var v: int = d.get(a, 0)
 if diff > 0 and v < max\_allowed[a]:
 candidates.append(a)
 elif diff < 0 and v > min\_allowed[a]:
 candidates.append(a)

 if candidates.is\_empty():
 break

 # Prefer adjusting non-anchor axes most of the time (keeps identity stable)
 var chosen: StringName
 if rng.randf() < 0.75:
 var non\_anchor: Array[StringName] = []
 for a in candidates:
 if a != pos\_axis and a != neg\_axis:
 non\_anchor.append(a)
 chosen = non\_anchor.is\_empty() ? candidates[rng.randi\_range(0, candidates.size() - 1)]
 : non\_anchor[rng.randi\_range(0, non\_anchor.size() - 1)]
 else:
 chosen = candidates[rng.randi\_range(0, candidates.size() - 1)]

 var headroom := 0
 if diff > 0:
 headroom = max\_allowed[chosen] - d[chosen]
 else:
 headroom = d[chosen] - min\_allowed[chosen]

 if headroom <= 0:
 continue

 var step\_mag := min(abs(diff), headroom, rng.randi\_range(3, 14))
 var step := (diff > 0) ? step\_mag : -step\_mag

 d[chosen] += step
 diff -= step

 # 4) Final validation (hard guarantees)
 var final\_sum := \_axis\_sum\_dict(d)
 if final\_sum < AXIS\_SUM\_MIN or final\_sum > AXIS\_SUM\_MAX:
 continue
 if d[pos\_axis] <= AXIS\_REQUIRED\_POSITIVE\_GT:
 continue
 if d[neg\_axis] >= AXIS\_REQUIRED\_NEGATIVE\_LT:
 continue

 # Extra "interesting distribution" check:
 # At least 3 axes with |value| >= 12 (so it's not "one big +, one -, and dust").
 var interesting := 0
 for a in ALL\_AXES:
 if abs(int(d[a])) >= 12:
 interesting += 1
 if interesting < 3:
 continue

 # Clamp (safety) and return
 for a in ALL\_AXES:
 d[a] = clampi(int(d[a]), AXIS\_MIN, AXIS\_MAX)
 return d

 # Fallback (should basically never happen): deterministic-ish profile
 var fallback: Dictionary[StringName, int] = {}
 for a in ALL\_AXES:
 fallback[a] = 0
 fallback[AXIS\_MAGIC] = 70
 fallback[AXIS\_TECH] = -30
 fallback[AXIS\_NATURE] = 20
 fallback[AXIS\_DIVINE] = -5
 fallback[AXIS\_CORRUPTION] = 0
 return fallback


static func \_axis\_sum\_dict(d: Dictionary) -> int:
 var s := 0
 for a in ALL\_AXES:
 s += int(d.get(a, 0))
 return s
```


Si tu veux, je peux aussi te donner une variante “plus dramatique” (avec davantage d’extrêmes) ou “plus nuancée” (plus centrée), juste en changeant 2–3 paramètres (`randfn` deviation, clamps, contraintes “interesting”).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 3](#toc-detail-ch3)
<a id="moi-8"></a>
**Moi 8:**
Fait les deux, on choisira l'algo en fonction de l'etat du monde.

L'ideal serait un algo qui prend un dictionnaire de parametre en entrée ainsi qu'un type de generation.

De la on choisit si on fait un tirage centré, dramatique ou normal.

Il faut aussi qu'on puisse forcée un tirage contre un axe/faction (cas d'une faction qui a pris le controle du monde, il faut qu'on puisse faire emergée une faction qui va naturellement se placer en antagoniste).


**ChatGPT:**
Voilà une version **paramétrable** qui supporte 3 modes (**centered / normal / dramatic**), accepte un **dictionnaire de paramètres**, et permet de **forcer un tirage antagoniste** contre un **axe** et/ou contre une **faction** (via son `FactionProfile`).


À coller dans `FactionProfile.gd` (en gardant tes constantes `ALL_AXES`, `AXIS_MIN/MAX`, etc.).


```
# --- In FactionProfile.gd ---

const GEN\_CENTERED: StringName = &"centered"
const GEN\_NORMAL: StringName = &"normal"
const GEN\_DRAMATIC: StringName = &"dramatic"

static func generate\_axis\_affinity(
 rng: RandomNumberGenerator,
 mode: StringName = GEN\_NORMAL,
 params: Dictionary = {},
 force\_against\_axis: StringName = &"", # ex: AXIS\_MAGIC -> force un gros négatif sur Magie
 against\_faction\_profile: FactionProfile = null, # faction dominante à contrer
 antagonism\_strength: float = 1.0 # 0..2 (en pratique)
) -> Dictionary[StringName, int]:
 var p := \_default\_axis\_gen\_params(mode)
 for k in params.keys():
 p[k] = params[k]

 var attempts: int = int(p.get("attempts", 80))
 var best: Dictionary[StringName, int] = {}
 var best\_score := -INF

 for i in range(attempts):
 var candidate := \_generate\_axis\_affinity\_once(rng, p, force\_against\_axis, against\_faction\_profile, antagonism\_strength)
 if candidate.is\_empty():
 continue

 # Si on veut contrer une faction, on choisit le candidat le plus antagoniste (dot-product le plus négatif)
 if against\_faction\_profile != null:
 var score := \_antagonism\_score(candidate, against\_faction\_profile.axis\_affinity)
 if score > best\_score:
 best\_score = score
 best = candidate
 else:
 return candidate

 return best if not best.is\_empty() else \_fallback\_axis\_affinity()


static func \_default\_axis\_gen\_params(mode: StringName) -> Dictionary:
 # Tu peux override n’importe quel champ via `params`.
 # Les 3 modes changent principalement : sigma, clamps, anchors et "interestingness".
 var d := {
 "sum\_min": AXIS\_SUM\_MIN, # 20
 "sum\_max": AXIS\_SUM\_MAX, # 90
 "pos\_min": 60, "pos\_max": 92, # anchor positif > 50
 "neg\_min\_abs": 25, "neg\_max\_abs": 80, # anchor négatif < -20

 "other\_sigma": 32.0,
 "other\_clamp\_abs": 75,

 "near\_zero\_abs": 8,
 "near\_zero\_push\_min": 10,
 "near\_zero\_push\_max": 22,

 "strong\_abs\_threshold": 15,
 "min\_strong\_in\_others": 2, # parmi les 3 axes restants
 "min\_interesting\_axes": 3, # total axes avec |v| >= interesting\_abs
 "interesting\_abs": 12,

 "adjust\_step\_min": 3,
 "adjust\_step\_max": 14,

 "cooldown\_bias\_non\_anchor": 0.75,
 "attempts": 80,
 "inner\_resample\_other": 30,
 "max\_adjust\_iters": 250,
 }

 match mode:
 GEN\_CENTERED:
 # plus “nuancé” : moins d’extrêmes, plus de retour vers 0
 d["pos\_min"] = 55
 d["pos\_max"] = 78
 d["neg\_min\_abs"] = 25
 d["neg\_max\_abs"] = 55
 d["other\_sigma"] = 20.0
 d["other\_clamp\_abs"] = 55
 d["interesting\_abs"] = 10
 d["min\_interesting\_axes"] = 4 # plus d’axes “un peu marqués”
 # somme un peu moins haute en moyenne (garde de la place pour dériver ensuite)
 d["sum\_min"] = 20
 d["sum\_max"] = 75

 GEN\_DRAMATIC:
 # plus “radical” : identité forte, tensions idéologiques marquées
 d["pos\_min"] = 75
 d["pos\_max"] = 100
 d["neg\_min\_abs"] = 40
 d["neg\_max\_abs"] = 100
 d["other\_sigma"] = 45.0
 d["other\_clamp\_abs"] = 95
 d["near\_zero\_push\_min"] = 18
 d["near\_zero\_push\_max"] = 35
 d["strong\_abs\_threshold"] = 18
 d["interesting\_abs"] = 15
 d["min\_interesting\_axes"] = 3
 d["sum\_min"] = 20
 d["sum\_max"] = 90

 \_:
 # GEN\_NORMAL = defaults
 pass

 return d


static func \_generate\_axis\_affinity\_once(
 rng: RandomNumberGenerator,
 p: Dictionary,
 force\_against\_axis: StringName,
 against\_faction\_profile: FactionProfile,
 antagonism\_strength: float
) -> Dictionary[StringName, int]:
 # 1) Choix des axes anchors (pos/neg), en tenant compte des “contre”
 var anchors := \_pick\_anchor\_axes(rng, force\_against\_axis, against\_faction\_profile)
 if anchors.is\_empty():
 return {}
 var pos\_axis: StringName = anchors["pos"]
 var neg\_axis: StringName = anchors["neg"]

 # 2) Valeurs anchors
 var pos\_min: int = int(p["pos\_min"])
 var pos\_max: int = int(p["pos\_max"])
 var neg\_min\_abs: int = int(p["neg\_min\_abs"])
 var neg\_max\_abs: int = int(p["neg\_max\_abs"])

# antagonism\_strength : renforce légèrement les anchors quand on veut un vrai antagoniste

 if force\_against\_axis != &"" or against\_faction\_profile != null:
 var k := clampf(antagonism\_strength, 0.0, 2.0)
 pos\_min = clampi(pos\_min + int(8.0 * k), 51, 100)
 pos\_max = clampi(pos\_max + int(10.0 * k), 51, 100)
 neg\_min\_abs = clampi(neg\_min\_abs + int(8.0 * k), 21, 100)
 neg\_max\_abs = clampi(neg\_max\_abs + int(10.0 * k), 21, 100)

 var d: Dictionary[StringName, int] = {}
 for a in ALL\_AXES:
 d[a] = 0

 d[pos\_axis] = rng.randi\_range(pos\_min, pos\_max)

# > 50

 d[neg\_axis] = -rng.randi\_range(neg\_min\_abs, neg\_max\_abs)

# < -20

 # 3) Génération des 3 autres axes (distribution intéressante)
 var rem\_axes: Array[StringName] = []
 for a in ALL\_AXES:
 if a != pos\_axis and a != neg\_axis:
 rem\_axes.append(a)

 var ok\_distribution := false
 for \_resample in range(int(p.get("inner\_resample\_other", 30))):
 var strong\_count := 0
 for a in rem\_axes:
 var v := int(round(rng.randfn(0.0, float(p["other\_sigma"]))))
 if abs(v) < int(p["near\_zero\_abs"]):
 v += (rng.randf() < 0.5 ? -1 : 1) * rng.randi\_range(int(p["near\_zero\_push\_min"]), int(p["near\_zero\_push\_max"]))
 v = clampi(v, -int(p["other\_clamp\_abs"]), int(p["other\_clamp\_abs"]))
 d[a] = v
 if abs(v) >= int(p["strong\_abs\_threshold"]):
 strong\_count += 1
 if strong\_count >= int(p["min\_strong\_in\_others"]):
 ok\_distribution = true
 break

 if not ok\_distribution:
 return {}

 # 4) Ajuster la somme dans [sum\_min..sum\_max] sans casser les garanties
 var target\_sum := rng.randi\_range(int(p["sum\_min"]), int(p["sum\_max"]))
 var diff := target\_sum - \_axis\_sum\_dict(d)

 var min\_allowed: Dictionary[StringName, int] = {}
 var max\_allowed: Dictionary[StringName, int] = {}
 for a in ALL\_AXES:
 min\_allowed[a] = AXIS\_MIN
 max\_allowed[a] = AXIS\_MAX
 min\_allowed[pos\_axis] = 51
 max\_allowed[pos\_axis] = 100
 min\_allowed[neg\_axis] = -100
 max\_allowed[neg\_axis] = -21

 var max\_iters := int(p.get("max\_adjust\_iters", 250))
 var iter := 0
 while diff != 0 and iter < max\_iters:
 iter += 1
 var candidates: Array[StringName] = []
 for a in ALL\_AXES:
 var v: int = d[a]
 if diff > 0 and v < max\_allowed[a]:
 candidates.append(a)
 elif diff < 0 and v > min\_allowed[a]:
 candidates.append(a)

 if candidates.is\_empty():
 break

 # Ajuster surtout les non-anchors
 var chosen: StringName
 if rng.randf() < float(p.get("cooldown\_bias\_non\_anchor", 0.75)):
 var non\_anchor: Array[StringName] = []
 for a in candidates:
 if a != pos\_axis and a != neg\_axis:
 non\_anchor.append(a)
 chosen = non\_anchor.is\_empty() ? candidates.pick\_random() : non\_anchor.pick\_random()
 else:
 chosen = candidates.pick\_random()

 var headroom := 0
 if diff > 0:
 headroom = max\_allowed[chosen] - d[chosen]
 else:
 headroom = d[chosen] - min\_allowed[chosen]
 if headroom <= 0:
 continue

 var step\_mag := min(abs(diff), headroom, rng.randi\_range(int(p["adjust\_step\_min"]), int(p["adjust\_step\_max"])))
 var step := (diff > 0) ? step\_mag : -step\_mag
 d[chosen] += step
 diff -= step

 # 5) Validation finale (garanties + “interestingness”)
 var s := \_axis\_sum\_dict(d)
 if s < int(p["sum\_min"]) or s > int(p["sum\_max"]):
 return {}
 if d[pos\_axis] <= AXIS\_REQUIRED\_POSITIVE\_GT:
 return {}
 if d[neg\_axis] >= AXIS\_REQUIRED\_NEGATIVE\_LT:
 return {}

 var interesting := 0
 for a in ALL\_AXES:
 if abs(d[a]) >= int(p["interesting\_abs"]):
 interesting += 1
 if interesting < int(p["min\_interesting\_axes"]):
 return {}

 # Clamp sécurité
 for a in ALL\_AXES:
 d[a] = clampi(d[a], AXIS\_MIN, AXIS\_MAX)

 return d


static func \_pick\_anchor\_axes(
 rng: RandomNumberGenerator,
 force\_against\_axis: StringName,
 against\_faction\_profile: FactionProfile
) -> Dictionary:
 var axes := ALL\_AXES.duplicate()

 var neg\_axis: StringName = &""
 var pos\_axis: StringName = &""

 # 1) Forcer un gros négatif sur un axe précis
 if force\_against\_axis != &"" and axes.has(force\_against\_axis):
 neg\_axis = force\_against\_axis
 axes.erase(neg\_axis)

# 2) Forcer un antagonisme contre une faction : opposer les “pôles”

 # - si la faction cible aime fortement un axe -> on le déteste (neg)

# - si la faction cible déteste fortement un axe -> on l’aime (pos)

 if against\_faction\_profile != null:
 var tgt := against\_faction\_profile.axis\_affinity

 # Choix pos : axe le plus négatif chez la cible (on fait l’inverse)
 var best\_pos\_axis: StringName = &""
 var best\_pos\_value := 999999
 for a in axes:
 var v := int(tgt.get(a, 0))
 if v < best\_pos\_value:
 best\_pos\_value = v
 best\_pos\_axis = a
 if best\_pos\_axis != &"":
 pos\_axis = best\_pos\_axis
 axes.erase(pos\_axis)

# Si neg\_axis n'est pas forcé, choisir l’axe le plus positif chez la cible

 if neg\_axis == &"":
 # remettre tous les axes sauf pos\_axis
 var axes2 := ALL\_AXES.duplicate()
 if axes2.has(pos\_axis):
 axes2.erase(pos\_axis)

 var best\_neg\_axis: StringName = &""
 var best\_neg\_value := -999999
 for a in axes2:
 var v := int(tgt.get(a, 0))
 if v > best\_neg\_value:
 best\_neg\_value = v
 best\_neg\_axis = a
 neg\_axis = best\_neg\_axis

 # 3) Si encore incomplet, random
 if pos\_axis == &"":
 pos\_axis = axes[rng.randi\_range(0, axes.size() - 1)]
 axes.erase(pos\_axis)
 if neg\_axis == &"":
 # pick from remaining original axes
 var remaining := ALL\_AXES.duplicate()
 remaining.erase(pos\_axis)
 neg\_axis = remaining[rng.randi\_range(0, remaining.size() - 1)]

 # éviter collision
 if neg\_axis == pos\_axis:
 var remaining2 := ALL\_AXES.duplicate()
 remaining2.erase(pos\_axis)
 neg\_axis = remaining2[rng.randi\_range(0, remaining2.size() - 1)]

 return {"pos": pos\_axis, "neg": neg\_axis}


static func \_antagonism\_score(my\_aff: Dictionary, target\_aff: Dictionary) -> float:
 # On veut être "opposé" : score haut quand le dot-product est très négatif.
 var dot := 0.0
 for a in ALL\_AXES:
 dot += float(int(my\_aff.get(a, 0)) * int(target\_aff.get(a, 0)))
 return -dot


static func \_axis\_sum\_dict(d: Dictionary) -> int:
 var s := 0
 for a in ALL\_AXES:
 s += int(d.get(a, 0))
 return s


static func \_fallback\_axis\_affinity() -> Dictionary[StringName, int]:
 var f: Dictionary[StringName, int] = {}
 for a in ALL\_AXES:
 f[a] = 0
 f[AXIS\_MAGIC] = 70
 f[AXIS\_TECH] = -30
 f[AXIS\_NATURE] = 20
 f[AXIS\_DIVINE] = -5
 f[AXIS\_CORRUPTION] = 0
 return f
```


### Exemples d’utilisation


**Normal :**


```
profile.axis\_affinity = FactionProfile.generate\_axis\_affinity(rng, FactionProfile.GEN\_NORMAL)
```


**Centré (nuancé) :**


```
profile.axis\_affinity = FactionProfile.generate\_axis\_affinity(rng, FactionProfile.GEN\_CENTERED)
```


**Dramatique (radical) :**


```
profile.axis\_affinity = FactionProfile.generate\_axis\_affinity(rng, FactionProfile.GEN\_DRAMATIC)
```


**Forcer une faction “anti-magie” (antagoniste d’un monde très magique) :**


```
profile.axis\_affinity = FactionProfile.generate\_axis\_affinity(
 rng, FactionProfile.GEN\_DRAMATIC, {}, FactionProfile.AXIS\_MAGIC
)
```


**Forcer une faction antagoniste à une faction dominante (profil connu) :**


```
profile.axis\_affinity = FactionProfile.generate\_axis\_affinity(
 rng,
 FactionProfile.GEN\_NORMAL,
 {},
 &"", # pas d’axe imposé
 dominant\_faction.profile, # contre cette faction
 1.3 # antagonisme un peu renforcé
)
```


Si tu veux, prochaine étape : on fait la même chose pour la **génération de personnalité** (templates + variation -0.1..+0.2), avec aussi un mode “antagoniste” (ex : si tu contrer une faction pacifique, tu génères un profil plus agressif, etc.).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 3](#toc-detail-ch3)
<a id="moi-9"></a>
**Moi 9:**
Go pour génération de personnalité


**ChatGPT:**
Voici une génération **procédurale + templates** pour la personnalité, avec :


* **templates** (pacifique, pragmatique, belliqueux, expansionniste, fanatique, assimilateur)
* **variation** par trait (par défaut **[-0.1 .. +0.2]**, clamp 0..1)
* 3 modes : **centered / normal / dramatic** (qui modulent l’amplitude + l’“interestingness”)
* un mode **antagoniste** : tu peux générer une faction “qui s’oppose naturellement” à une autre (en choisissant le template le plus opposé + en blendant vers l’inverse des valeurs)


À coller dans `FactionProfile.gd` (en plus de tes constantes `ALL_PERSONALITY_KEYS`, `PERS_*`, etc.).


```
# --- In FactionProfile.gd ---

const PGEN\_CENTERED: StringName = &"centered"
const PGEN\_NORMAL: StringName = &"normal"
const PGEN\_DRAMATIC: StringName = &"dramatic"

const PTYPE\_PACIFIST: StringName = &"pacifist"
const PTYPE\_PRAGMATIC: StringName = &"pragmatic"
const PTYPE\_WARLIKE: StringName = &"warlike"
const PTYPE\_EXPANSIONIST: StringName = &"expansionist"
const PTYPE\_FANATIC: StringName = &"fanatic"
const PTYPE\_ASSIMILATOR: StringName = &"assimilator"

static func personality\_templates() -> Dictionary:
 # Valeurs de base 0..1 (tu pourras ajuster selon ton design)
 return {
 PTYPE\_PACIFIST: {
 PERS\_AGGRESSION: 0.15,
 PERS\_VENGEFULNESS: 0.20,
 PERS\_DIPLOMACY: 0.85,
 PERS\_RISK\_AVERSION: 0.70,
 PERS\_EXPANSIONISM: 0.20,
 PERS\_INTEGRATIONISM: 0.60,
 },
 PTYPE\_PRAGMATIC: {
 PERS\_AGGRESSION: 0.35,
 PERS\_VENGEFULNESS: 0.35,
 PERS\_DIPLOMACY: 0.55,
 PERS\_RISK\_AVERSION: 0.50,
 PERS\_EXPANSIONISM: 0.40,
 PERS\_INTEGRATIONISM: 0.40,
 },
 PTYPE\_WARLIKE: {
 PERS\_AGGRESSION: 0.80,
 PERS\_VENGEFULNESS: 0.70,
 PERS\_DIPLOMACY: 0.20,
 PERS\_RISK\_AVERSION: 0.30,
 PERS\_EXPANSIONISM: 0.60,
 PERS\_INTEGRATIONISM: 0.20,
 },
 PTYPE\_EXPANSIONIST: {
 PERS\_AGGRESSION: 0.65,
 PERS\_VENGEFULNESS: 0.45,
 PERS\_DIPLOMACY: 0.30,
 PERS\_RISK\_AVERSION: 0.35,
 PERS\_EXPANSIONISM: 0.90,
 PERS\_INTEGRATIONISM: 0.50,
 },
 PTYPE\_FANATIC: {
 PERS\_AGGRESSION: 0.75,
 PERS\_VENGEFULNESS: 0.85,
 PERS\_DIPLOMACY: 0.10,
 PERS\_RISK\_AVERSION: 0.20,
 PERS\_EXPANSIONISM: 0.50,
 PERS\_INTEGRATIONISM: 0.05,
 },
 PTYPE\_ASSIMILATOR: {
 PERS\_AGGRESSION: 0.45,
 PERS\_VENGEFULNESS: 0.25,
 PERS\_DIPLOMACY: 0.60,
 PERS\_RISK\_AVERSION: 0.45,
 PERS\_EXPANSIONISM: 0.55,
 PERS\_INTEGRATIONISM: 0.90,
 },
 }

static func default\_personality\_gen\_params(mode: StringName) -> Dictionary:
 var d := {
 "attempts": 50,

 # Par défaut, ta plage souhaitée :
 "variation\_min": -0.1,
 "variation\_max": 0.2,

 # “Interestingness” : éviter un profil trop plat
 "require\_high": 0.75,
 "require\_low": 0.35,
 "min\_high\_count": 1,
 "min\_low\_count": 1,

 # Blend vers l’antagonisme (0..1)
 "antagonism\_blend": 0.0,

 # Optionnel : favoriser certains templates
 # ex: {"pacifist": 1.0, "warlike": 0.2, ...}
 "template\_weights": {},
 }

 match mode:
 PGEN\_CENTERED:
 d["variation\_min"] = -0.05
 d["variation\_max"] = 0.10
 d["require\_high"] = 0.70
 d["require\_low"] = 0.40

 PGEN\_DRAMATIC:
 d["variation\_min"] = -0.15
 d["variation\_max"] = 0.25
 d["require\_high"] = 0.80
 d["require\_low"] = 0.30

 \_:
 pass

 return d

static func generate\_personality(
 rng: RandomNumberGenerator,
 mode: StringName = PGEN\_NORMAL,
 params: Dictionary = {},
 personality\_type: StringName = &"", # si vide: choisi automatiquement
 against\_faction\_profile: FactionProfile = null, # pour générer un antagoniste
 antagonism\_strength: float = 1.0 # 0..2
) -> Dictionary[StringName, float]:
 var p := default\_personality\_gen\_params(mode)
 for k in params.keys():
 p[k] = params[k]

 var templates := personality\_templates()
 var attempts := int(p.get("attempts", 50))

# 1) Choix du template

 var chosen\_type := personality\_type
 if chosen\_type == &"":
 if against\_faction\_profile != null:
 chosen\_type = \_pick\_most\_antagonistic\_template(templates, against\_faction\_profile.personality)
 else:
 chosen\_type = \_pick\_weighted\_template(rng, templates, p.get("template\_weights", {}))

 if not templates.has(chosen\_type):
 chosen\_type = PTYPE\_PRAGMATIC

 # 2) Génération avec retries pour “interestingness”
 var best: Dictionary[StringName, float] = {}
 var best\_interest := -INF

 for \_i in range(attempts):
 var cand := \_build\_personality\_from\_template(
 rng,
 Dictionary(templates[chosen\_type]),
 p,
 against\_faction\_profile,
 antagonism\_strength
 )
 if cand.is\_empty():
 continue

 var interest := \_interest\_score(cand, float(p["require\_high"]), float(p["require\_low"]))
 if \_meets\_interest(cand, p):
 return cand

 # sinon garder la meilleure, au cas où (fallback soft)
 if interest > best\_interest:
 best\_interest = interest
 best = cand

 return best if not best.is\_empty() else \_fallback\_personality()


static func \_build\_personality\_from\_template(
 rng: RandomNumberGenerator,
 base: Dictionary,
 p: Dictionary,
 against\_faction\_profile: FactionProfile,
 antagonism\_strength: float
) -> Dictionary[StringName, float]:
 var out: Dictionary[StringName, float] = {}

 var var\_min := float(p.get("variation\_min", -0.1))
 var var\_max := float(p.get("variation\_max", 0.2))

# Antagonism blend (0..1) : plus c’est haut, plus on tend vers l’inverse de la cible

 var blend := float(p.get("antagonism\_blend", 0.0))
 if against\_faction\_profile != null:
 blend = clampf(blend + 0.35 * clampf(antagonism\_strength, 0.0, 2.0), 0.0, 1.0)

 for k in ALL\_PERSONALITY\_KEYS:
 var v := clampf(float(base.get(k, 0.5)), 0.0, 1.0)

 if against\_faction\_profile != null:
 var t := clampf(float(against\_faction\_profile.personality.get(k, 0.5)), 0.0, 1.0)
 var opposite := 1.0 - t
 v = lerp(v, opposite, blend)

 var delta := rng.randf\_range(var\_min, var\_max)
 v = clampf(v + delta, 0.0, 1.0)
 out[k] = v

 return out


static func \_pick\_weighted\_template(
 rng: RandomNumberGenerator,
 templates: Dictionary,
 weights: Dictionary
) -> StringName:
 # Si weights vide => uniforme
 var keys: Array = templates.keys()
 if weights.is\_empty():
 return StringName(keys[rng.randi\_range(0, keys.size() - 1)])

 var total := 0.0
 for k in keys:
 total += max(0.0, float(weights.get(k, 1.0)))

 if total <= 0.0:
 return StringName(keys[rng.randi\_range(0, keys.size() - 1)])

 var r := rng.randf() * total
 var acc := 0.0
 for k in keys:
 acc += max(0.0, float(weights.get(k, 1.0)))
 if r <= acc:
 return StringName(k)

 return StringName(keys[0])


static func \_pick\_most\_antagonistic\_template(templates: Dictionary, target\_personality: Dictionary) -> StringName:
 # Choisit le template le plus "opposé" au target (corrélation négative autour de 0.5)
 var best\_key: StringName = PTYPE\_PRAGMATIC
 var best\_score := -INF
 for k in templates.keys():
 var tpl: Dictionary = templates[k]
 var score := 0.0
 for trait in ALL\_PERSONALITY\_KEYS:
 var a := float(tpl.get(trait, 0.5)) - 0.5
 var b := float(target\_personality.get(trait, 0.5)) - 0.5
 score += -a * b # plus c'est grand, plus c’est opposé
 if score > best\_score:
 best\_score = score
 best\_key = StringName(k)
 return best\_key


static func \_meets\_interest(personality: Dictionary, p: Dictionary) -> bool:
 var high\_thr := float(p.get("require\_high", 0.75))
 var low\_thr := float(p.get("require\_low", 0.35))
 var min\_high := int(p.get("min\_high\_count", 1))
 var min\_low := int(p.get("min\_low\_count", 1))

 var hi := 0
 var lo := 0
 for k in ALL\_PERSONALITY\_KEYS:
 var v := float(personality.get(k, 0.5))
 if v >= high\_thr:
 hi += 1
 if v <= low\_thr:
 lo += 1

 return hi >= min\_high and lo >= min\_low


static func \_interest\_score(personality: Dictionary, high\_thr: float, low\_thr: float) -> float:
 var hi := 0
 var lo := 0
 var spread := 0.0
 for k in ALL\_PERSONALITY\_KEYS:
 var v := float(personality.get(k, 0.5))
 if v >= high\_thr: hi += 1
 if v <= low\_thr: lo += 1
 spread += abs(v - 0.5)
 return float(hi + lo) + spread


static func \_fallback\_personality() -> Dictionary[StringName, float]:
 # fallback stable
 return {
 PERS\_AGGRESSION: 0.35,
 PERS\_VENGEFULNESS: 0.35,
 PERS\_DIPLOMACY: 0.55,
 PERS\_RISK\_AVERSION: 0.50,
 PERS\_EXPANSIONISM: 0.40,
 PERS\_INTEGRATIONISM: 0.40,
 }
```


### Exemples d’utilisation


**Générer une personnalité “normale” aléatoire :**


```
profile.personality = FactionProfile.generate\_personality(rng, FactionProfile.PGEN\_NORMAL)
```


**Forcer un type précis (ex : pacifique) :**


```
profile.personality = FactionProfile.generate\_personality(
 rng, FactionProfile.PGEN\_NORMAL, {}, FactionProfile.PTYPE\_PACIFIST
)
```


**Mode dramatique (traits plus marqués) :**


```
profile.personality = FactionProfile.generate\_personality(rng, FactionProfile.PGEN\_DRAMATIC)
```


**Faire émerger un antagoniste naturel d’une faction dominante :**


```
profile.personality = FactionProfile.generate\_personality(
 rng,
 FactionProfile.PGEN\_NORMAL,
 {"antagonism\_blend": 0.15}, # tu peux augmenter si tu veux du “hard counter”
 &"", # laisse le code choisir le template antagoniste
 dominant\_faction.profile,
 1.3
)
```


Si tu veux, prochaine étape logique : une fonction “**generate\_full\_profile**” qui génère **axes + personnalité** en cohérence (ex : une faction anti-magie a plus de chances d’être prudente/risk\_averse, ou au contraire fanatique anti-magie selon le monde), et surtout un “mode antagoniste complet” contre une faction hégémonique.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 3](#toc-detail-ch3)
<a id="moi-10"></a>
**Moi 10:**
Ok prochaine étape logique : une fonction “generate\_full\_profile” qui génère axes + personnalité en cohérence (ex : une faction anti-magie a plus de chances d’être prudente/risk\_averse, ou au contraire fanatique anti-magie selon le monde), et surtout un “mode antagoniste complet” contre une faction hégémonique.


**ChatGPT:**
Voilà une proposition **clé en main** pour `generate_full_profile()` qui :


* génère **axes + personnalité**,
* assure une **cohérence** (les axes “poussent” certains traits),
* supporte les modes **centered / normal / dramatic** via `gen_type` + `params`,
* et gère un **mode antagoniste complet** contre une faction hégémonique (axes opposés + personnalité adaptée).


À coller dans `FactionProfile.gd` (en s’appuyant sur les fonctions que tu as déjà : `generate_axis_affinity()` et `generate_personality()`).


---


## 1) `generate_full_profile()` + helpers


```
# --- In FactionProfile.gd ---

static func generate\_full\_profile(
 rng: RandomNumberGenerator,
 gen\_type: StringName = GEN\_NORMAL, # centered/normal/dramatic (on réutilise tes modes)
 params: Dictionary = {},
 force\_against\_axis: StringName = &"", # optionnel : AXIS\_MAGIC etc.
 against\_faction\_profile: FactionProfile = null, # optionnel : pour créer un antagoniste
 antagonism\_strength: float = 1.0 # 0..2 (≈ 1.0 normal)
) -> FactionProfile:
 var profile := FactionProfile.new()

# --- Paramètres par défaut ---

 var axis\_mode: StringName = StringName(params.get("axis\_mode", gen\_type))
 var pers\_mode: StringName = StringName(params.get("personality\_mode", gen\_type))

 var axis\_params: Dictionary = Dictionary(params.get("axis\_params", {}))
 var pers\_params: Dictionary = Dictionary(params.get("personality\_params", {}))

# Coherence (blend global axes -> personnalité)

 var coherence\_strength := float(params.get("coherence\_strength", \_default\_coherence\_strength(gen\_type)))

# Anti-magic style (prudente vs fanatique)

 var anti\_magic\_base\_fanatic := float(params.get("anti\_magic\_base\_fanatic", 0.35))

# base prob

 var anti\_magic\_enabled := bool(params.get("anti\_magic\_enabled", true))

# Antagoniste : si true, on renforce un peu le côté “contre”

 var antagonist\_full\_mode := bool(params.get("antagonist\_full\_mode", against\_faction\_profile != null))
 var antagonist\_force\_dominant\_axis := bool(params.get("antagonist\_force\_dominant\_axis", true))
 var antagonist\_personality\_blend := float(params.get("antagonist\_personality\_blend", 0.15))

# 1) Déterminer un axe à contrer si on vise une faction hégémonique

 var effective\_force\_against\_axis := force\_against\_axis
 if antagonist\_full\_mode and against\_faction\_profile != null and antagonist\_force\_dominant\_axis and effective\_force\_against\_axis == &"":
 effective\_force\_against\_axis = \_dominant\_axis\_of(against\_faction\_profile.axis\_affinity)

# 2) Générer les axes (normal/centered/dramatic + paramètres)

 profile.axis\_affinity = generate\_axis\_affinity(
 rng,
 axis\_mode,
 axis\_params,
 effective\_force\_against\_axis,
 against\_faction\_profile,
 antagonism\_strength
 )

# 3) Choisir un template de personnalité cohérent avec les axes (weights)

 var axis\_based\_weights := \_personality\_weights\_from\_axes(profile.axis\_affinity)

# Si antagoniste complet, on mélange un peu les weights avec l’opposition à la cible

 # (sans empêcher le “contre-template” automatique si tu veux le garder)
 pers\_params["template\_weights"] = axis\_based\_weights

 # 4) Générer personnalité (template + variation + éventuellement antagonisme contre une faction)
 if antagonist\_full\_mode and against\_faction\_profile != null:
 # un petit boost pour pousser vers l’inverse, sans être une caricature
 var prev := float(pers\_params.get("antagonism\_blend", 0.0))
 pers\_params["antagonism\_blend"] = clampf(prev + antagonist\_personality\_blend, 0.0, 1.0)

 profile.personality = generate\_personality(
 rng,
 \_to\_personality\_mode(pers\_mode), # mapping gen\_type -> PGEN\_*
 pers\_params,
 &"", # laisser choisir (pondéré + antagoniste si against != null)
 against\_faction\_profile,
 antagonism\_strength
 )

# 5) Appliquer “cohérence axes -> traits” (petites poussées, clamp 0..1)

 \_apply\_axis\_bias\_to\_personality(profile.personality, profile.axis\_affinity, coherence\_strength)

# 6) Cas spécial : anti-magie fort => prudente OU fanatique (au choix, probabiliste)

 if anti\_magic\_enabled:
 \_apply\_anti\_magic\_style(profile.personality, profile.axis\_affinity, rng, anti\_magic\_base\_fanatic, coherence\_strength)

 return profile


# ---------------------------

# Helpers

# ---------------------------

static func \_default\_coherence\_strength(gen\_type: StringName) -> float:
 match gen\_type:
 GEN\_CENTERED:
 return 0.35
 GEN\_DRAMATIC:
 return 0.75
 \_:
 return 0.55


static func \_to\_personality\_mode(axis\_mode: StringName) -> StringName:
 # Recycle tes modes centered/normal/dramatic vers les modes personnalité
 match axis\_mode:
 GEN\_CENTERED:
 return PGEN\_CENTERED
 GEN\_DRAMATIC:
 return PGEN\_DRAMATIC
 \_:
 return PGEN\_NORMAL


static func \_dominant\_axis\_of(axis\_aff: Dictionary) -> StringName:
 # Axe avec affinité la plus élevée (ex: hégémonie magique -> AXIS\_MAGIC)
 var best\_axis: StringName = AXIS\_TECH
 var best\_v := -999999
 for a in ALL\_AXES:
 var v := int(axis\_aff.get(a, 0))
 if v > best\_v:
 best\_v = v
 best\_axis = a
 return best\_axis


static func \_personality\_weights\_from\_axes(axis\_aff: Dictionary) -> Dictionary:
 # Renvoie un poids par template, basé sur “couleur idéologique” (simple mais efficace).
 # Les poids sont relatifs, \_pick\_weighted\_template gère la normalisation.
 var tech := float(int(axis\_aff.get(AXIS\_TECH, 0))) / 100.0
 var magic := float(int(axis\_aff.get(AXIS\_MAGIC, 0))) / 100.0
 var nature := float(int(axis\_aff.get(AXIS\_NATURE, 0))) / 100.0
 var divine := float(int(axis\_aff.get(AXIS\_DIVINE, 0))) / 100.0
 var corr := float(int(axis\_aff.get(AXIS\_CORRUPTION, 0))) / 100.0

 # Quelques heuristiques :
 # - Corruption forte => fanatique / belliqueux
 # - Nature + Divine => pacifique / assimilateur
 # - Tech => pragmatique / expansionniste
 # - Anti-magic très fort peut pousser pacifique prudent OU fanatique puriste (géré plus bas aussi)
 var anti\_magic := clampf((-magic - 0.5) / 0.5, 0.0, 1.0)

# ~0 si magic >= -50, ~1 si magic <= -100

 var w := {}
 w[PTYPE\_PRAGMATIC] = 1.0 + 1.2*max(0.0, tech) + 0.4*max(0.0, magic)
 w[PTYPE\_EXPANSIONIST] = 0.8 + 1.6*max(0.0, tech) + 0.8*max(0.0, corr)
 w[PTYPE\_PACIFIST] = 0.8 + 1.6*max(0.0, nature) + 1.2*max(0.0, divine) + 0.6*anti\_magic
 w[PTYPE\_ASSIMILATOR] = 0.7 + 1.4*max(0.0, divine) + 0.8*max(0.0, magic) + 0.6*max(0.0, nature)
 w[PTYPE\_WARLIKE] = 0.7 + 1.2*max(0.0, corr) + 0.6*max(0.0, tech)
 w[PTYPE\_FANATIC] = 0.5 + 2.0*max(0.0, corr) + 1.0*max(0.0, divine) + 0.7*anti\_magic

 return w


static func \_apply\_axis\_bias\_to\_personality(personality: Dictionary, axis\_aff: Dictionary, strength: float) -> void:
 # Pousses douces et cohérentes : axes -> traits.
 # strength 0..1 (0 = aucun effet, 1 = effet plein)
 var tech := float(int(axis\_aff.get(AXIS\_TECH, 0))) / 100.0
 var magic := float(int(axis\_aff.get(AXIS\_MAGIC, 0))) / 100.0
 var nature := float(int(axis\_aff.get(AXIS\_NATURE, 0))) / 100.0
 var divine := float(int(axis\_aff.get(AXIS\_DIVINE, 0))) / 100.0
 var corr := float(int(axis\_aff.get(AXIS\_CORRUPTION, 0))) / 100.0

 # Ajustements (petits, puis multipliés par strength)
 var adj := {
 PERS\_AGGRESSION: 0.0,
 PERS\_VENGEFULNESS: 0.0,
 PERS\_DIPLOMACY: 0.0,
 PERS\_RISK\_AVERSION: 0.0,
 PERS\_EXPANSIONISM: 0.0,
 PERS\_INTEGRATIONISM: 0.0,
 }

 # Tech : plus structurant/expansion, un peu moins “conciliant”
 adj[PERS\_EXPANSIONISM] += 0.18 * tech
 adj[PERS\_AGGRESSION] += 0.08 * tech
 adj[PERS\_DIPLOMACY] -= 0.06 * tech

 # Magie : souvent moins prudent (prise de risque), plus ouvert à intégration (soft)
 adj[PERS\_RISK\_AVERSION] -= 0.12 * magic
 adj[PERS\_INTEGRATIONISM] += 0.08 * magic

 # Nature : plus diplomate, moins agressif, un peu plus prudent
 adj[PERS\_DIPLOMACY] += 0.12 * nature
 adj[PERS\_AGGRESSION] -= 0.10 * nature
 adj[PERS\_RISK\_AVERSION] += 0.06 * nature

 # Divin : diplomatie + intégration (coalitions), un peu plus prudent
 adj[PERS\_DIPLOMACY] += 0.10 * divine
 adj[PERS\_INTEGRATIONISM] += 0.10 * divine
 adj[PERS\_RISK\_AVERSION] += 0.05 * divine

 # Corruption : agressif, rancunier, peu diplomate, peu intégrateur, moins prudent
 adj[PERS\_AGGRESSION] += 0.22 * corr
 adj[PERS\_VENGEFULNESS] += 0.18 * corr
 adj[PERS\_DIPLOMACY] -= 0.18 * corr
 adj[PERS\_INTEGRATIONISM] -= 0.18 * corr
 adj[PERS\_RISK\_AVERSION] -= 0.10 * corr

 for k in ALL\_PERSONALITY\_KEYS:
 var v := float(personality.get(k, 0.5))
 v = clampf(v + adj.get(k, 0.0) * clampf(strength, 0.0, 1.0), 0.0, 1.0)
 personality[k] = v


static func \_apply\_anti\_magic\_style(
 personality: Dictionary,
 axis\_aff: Dictionary,
 rng: RandomNumberGenerator,
 base\_fanatic\_prob: float,
 coherence\_strength: float
) -> void:
 var magic\_aff := int(axis\_aff.get(AXIS\_MAGIC, 0))
 if magic\_aff > -50:
 return

 var corr := float(int(axis\_aff.get(AXIS\_CORRUPTION, 0))) / 100.0
 var divine := float(int(axis\_aff.get(AXIS\_DIVINE, 0))) / 100.0
 var nature := float(int(axis\_aff.get(AXIS\_NATURE, 0))) / 100.0

 # Plus l’anti-magie est fort, plus le style (prudence/fanatisme) s’affirme.
 var anti\_magic\_strength := clampf(float(-magic\_aff - 50) / 50.0, 0.0, 1.0)

# Probabilité fanatique (puriste) : augmente avec corruption/divin, diminue avec nature

 var p\_fanatic := base\_fanatic\_prob \
 + 0.25 * anti\_magic\_strength \
 + 0.20 * max(0.0, corr) \
 + 0.15 * max(0.0, divine) \
 - 0.10 * max(0.0, nature)

 p\_fanatic = clampf(p\_fanatic, 0.10, 0.90)

 var style\_strength := clampf(0.35 + 0.45 * anti\_magic\_strength, 0.0, 1.0) * clampf(coherence\_strength, 0.0, 1.0)

 if rng.randf() < p\_fanatic:
 # Puriste / fanatique anti-magie : agressif + rancune, peu diplomate
 \_personality\_add(personality, PERS\_AGGRESSION, +0.15 * style\_strength)
 \_personality\_add(personality, PERS\_VENGEFULNESS, +0.20 * style\_strength)
 \_personality\_add(personality, PERS\_DIPLOMACY, -0.20 * style\_strength)
 \_personality\_add(personality, PERS\_INTEGRATIONISM, -0.10 * style\_strength)
 \_personality\_add(personality, PERS\_RISK\_AVERSION, -0.05 * style\_strength)
 else:
 # Prudente / “méfiance institutionnelle” : très risk\_averse, plutôt diplomate
 \_personality\_add(personality, PERS\_RISK\_AVERSION, +0.20 * style\_strength)
 \_personality\_add(personality, PERS\_DIPLOMACY, +0.10 * style\_strength)
 \_personality\_add(personality, PERS\_AGGRESSION, -0.10 * style\_strength)
 \_personality\_add(personality, PERS\_VENGEFULNESS, -0.05 * style\_strength)
 \_personality\_add(personality, PERS\_EXPANSIONISM, -0.05 * style\_strength)


static func \_personality\_add(personality: Dictionary, key: StringName, delta: float) -> void:
 var v := float(personality.get(key, 0.5))
 personality[key] = clampf(v + delta, 0.0, 1.0)
```


---


## 2) Exemples d’utilisation


### A) Profil “standard” (normal)


```
var p := FactionProfile.generate\_full\_profile(rng, FactionProfile.GEN\_NORMAL)
```


### B) Profil “centered” (plus nuancé)


```
var p := FactionProfile.generate\_full\_profile(rng, FactionProfile.GEN\_CENTERED)
```


### C) Profil “dramatic” (plus radical)


```
var p := FactionProfile.generate\_full\_profile(rng, FactionProfile.GEN\_DRAMATIC)
```


### D) Faire émerger un antagoniste “anti-hégémonie”


```
var p := FactionProfile.generate\_full\_profile(
 rng,
 FactionProfile.GEN\_DRAMATIC,
 {
 "antagonist\_full\_mode": true,
 "antagonist\_force\_dominant\_axis": true,
 "antagonist\_personality\_blend": 0.20,
 "coherence\_strength": 0.75
 },
 &"", # pas d’axe forcé à la main
 dominant\_faction.profile, # la faction à contrer
 1.3 # antagonisme renforcé
)
```


### E) Forcer “contre Magie” (mais sans cible faction)


```
var p := FactionProfile.generate\_full\_profile(
 rng,
 FactionProfile.GEN\_NORMAL,
 {"coherence\_strength": 0.6},
 FactionProfile.AXIS\_MAGIC
)
```


---


## 3) Pourquoi ça marche bien pour ton monde procédural


* Les **axes** donnent une identité idéologique.
* La **personnalité** reste libre (variation + templates), mais est **poussée** par les axes pour créer des comportements cohérents.
* En mode **antagoniste**, tu obtiens une faction :
	+ idéologiquement opposée (axes),
	+ et naturellement portée à agir différemment (personnalité),
	+ sans imposer “race = comportement”.


---


Si tu veux, prochaine brique logique : une fonction `compute_baseline_relation(A_profile, B_profile)` qui transforme **axes + personnalité** en **relation initiale** et en “friction” (pour initialiser ton `FactionRelationScore` A→B).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 3](#toc-detail-ch3)
<a id="moi-11"></a>
**Moi 11:**
Ok prochaine brique logique : une fonction compute\_baseline\_relation(A\_profile, B\_profile) qui transforme axes + personnalité en relation initiale et en “friction” (pour initialiser ton
<a id="cite-factionrelationscore-783d2e-4"></a>FactionRelationScore A→B).


**ChatGPT:**
Voici une brique **simple mais expressive** : `compute_baseline_relation(A, B)` calcule la **relation initiale (A→B)** + une **friction** (volatilité) à partir de :


* compatibilité idéologique (axes),
* conflits “croisés” (Tech↔Nature, Divin↔Corruption),
* et filtres de personnalité **côté A** (diplomatie, agressivité, rancune, prudence, expansion, intégration).


Je te renvoie aussi `trust` et `tension` initiaux (pratiques pour initialiser directement ton `FactionRelationScore`), mais tu peux ignorer si tu veux.


À coller dans `FactionProfile.gd`.


```
# --- In FactionProfile.gd ---

static func compute\_baseline\_relation(
 a: FactionProfile,
 b: FactionProfile,
 params: Dictionary = {}
) -> Dictionary:
 # ---- Tunables ----
 var w\_axis\_similarity: float = float(params.get("w\_axis\_similarity", 80.0))

# poids du "même axe"

 var w\_cross\_conflict: float = float(params.get("w\_cross\_conflict", 55.0))

# poids des conflits croisés

 var w\_personality\_bias: float = float(params.get("w\_personality\_bias", 25.0))

# Cross-conflict weights (abs-products), tu peux en ajouter plus tard

 var w\_tech\_nature: float = float(params.get("w\_tech\_nature", 1.0))
 var w\_divine\_corruption: float = float(params.get("w\_divine\_corruption", 1.0))
 var w\_magic\_tech: float = float(params.get("w\_magic\_tech", 0.35))

# optionnel, plus léger

 # Friction tuning
 var friction\_base: float = float(params.get("friction\_base", 18.0))
 var friction\_from\_opposition: float = float(params.get("friction\_from\_opposition", 65.0))
 var friction\_from\_cross: float = float(params.get("friction\_from\_cross", 55.0))

# Tension init tuning (tu peux la plafonner pour éviter guerres immédiates)

 var tension\_cap: float = float(params.get("tension\_cap", 40.0))

# ---- Read profiles (normalized -1..+1) ----

 var aT := float(a.get\_axis\_affinity(AXIS\_TECH)) / 100.0
 var aM := float(a.get\_axis\_affinity(AXIS\_MAGIC)) / 100.0
 var aN := float(a.get\_axis\_affinity(AXIS\_NATURE)) / 100.0
 var aD := float(a.get\_axis\_affinity(AXIS\_DIVINE)) / 100.0
 var aC := float(a.get\_axis\_affinity(AXIS\_CORRUPTION)) / 100.0

 var bT := float(b.get\_axis\_affinity(AXIS\_TECH)) / 100.0
 var bM := float(b.get\_axis\_affinity(AXIS\_MAGIC)) / 100.0
 var bN := float(b.get\_axis\_affinity(AXIS\_NATURE)) / 100.0
 var bD := float(b.get\_axis\_affinity(AXIS\_DIVINE)) / 100.0
 var bC := float(b.get\_axis\_affinity(AXIS\_CORRUPTION)) / 100.0

 # ---- Axis similarity (dot / 5) in [-1..+1] ----
 var dot := (aT*bT + aM*bM + aN*bN + aD*bD + aC*bC)
 var similarity := dot / 5.0

 # Opposition measure in [0..~1] : somme des contributions "opposées"
 # (produit négatif => opposition)
 var opposition := (
 max(0.0, -(aT*bT)) +
 max(0.0, -(aM*bM)) +
 max(0.0, -(aN*bN)) +
 max(0.0, -(aD*bD)) +
 max(0.0, -(aC*bC))
 ) / 5.0

 # Cross-conflicts (abs-products) in [0..~1]
 var cross := 0.0
 cross += w\_tech\_nature * (abs(aT) * abs(bN) + abs(aN) * abs(bT)) / 2.0
 cross += w\_divine\_corruption * (abs(aD) * abs(bC) + abs(aC) * abs(bD)) / 2.0
 cross += w\_magic\_tech * (abs(aM) * abs(bT) + abs(aT) * abs(bM)) / 2.0
 cross = clampf(cross, 0.0, 1.0)

# ---- Personality filters (directional: A's worldview) ----

 var aggr := a.get\_personality(PERS\_AGGRESSION, 0.5)
 var veng := a.get\_personality(PERS\_VENGEFULNESS, 0.5)
 var diplo := a.get\_personality(PERS\_DIPLOMACY, 0.5)
 var risk := a.get\_personality(PERS\_RISK\_AVERSION, 0.5)
 var expa := a.get\_personality(PERS\_EXPANSIONISM, 0.5)
 var integ := a.get\_personality(PERS\_INTEGRATIONISM, 0.5)

# "Ideological intensity" : plus A est extrême, plus il juge fort (positif ou négatif)

 var intensity := (abs(aT) + abs(aM) + abs(aN) + abs(aD) + abs(aC)) / 5.0 # 0..1
 var judgment\_gain := clampf(0.65 + 0.7*intensity + 0.2*veng - 0.25*diplo, 0.5, 1.6)

# Relation bias: diplomatie et intégration rendent plus "ouvert" par défaut,

 # aggression + vengeance rendent plus dur, expansionism rend suspicieux si l'autre est incompatible.
 var pers\_bias :=
 (+0.65*(diplo - 0.5)) +
 (+0.45*(integ - 0.5)) +
 (-0.55*(aggr - 0.5)) +
 (-0.45*(veng - 0.5)) +
 (-0.25*(expa - 0.5))

# ---- Baseline relation (A -> B) ----

 # similarity pousse + ; cross + opposition poussent - ; personnalité ajuste le ton.
 var rel\_f := 0.0
 rel\_f += (similarity * w\_axis\_similarity) * judgment\_gain
 rel\_f -= (cross * w\_cross\_conflict) * judgment\_gain
 rel\_f += pers\_bias * w\_personality\_bias

 var relation := clampi(int(round(rel\_f)), -100, 100)

# ---- Friction (volatilité / risque d'incident) ----

 # friction augmente avec opposition + cross-conflicts, puis est multipliée par le tempérament de A.
 var fr := friction\_base
 fr += opposition * friction\_from\_opposition * judgment\_gain
 fr += cross * friction\_from\_cross * judgment\_gain

 # tempérament : aggression/vengefulness augmentent, diplomacy/risk\_aversion diminuent
 var fr\_mul := 1.0 \
 + 0.50*(aggr - 0.5) \
 + 0.45*(veng - 0.5) \
 - 0.40*(diplo - 0.5) \
 - 0.25*(risk - 0.5)

 fr = clampf(fr * clampf(fr\_mul, 0.55, 1.65), 0.0, 100.0)

# ---- Optional: init trust & tension (useful to init FactionRelationScore) ----

 # Trust suit la relation, mais est pénalisée par rancune/agressivité.
 var trust\_f := 0.65*float(relation) + 18.0*(diplo - 0.5) - 14.0*(veng - 0.5) - 10.0*(aggr - 0.5)
 var trust := clampi(int(round(trust\_f)), -100, 100)

# Tension est une “partie” de la friction + négativité de relation, plafonnée (évite guerres day 1)

 var tension := clampf(0.35*fr + 0.20*max(0.0, -float(relation)), 0.0, tension\_cap)

 return {
 "relation": relation, # -100..100 (A -> B)
 "friction": fr, # 0..100 (A -> B)
 "trust": trust, # -100..100 (A -> B)
 "tension": tension # 0..tension\_cap
 }
```


### Comment l’utiliser pour initialiser ton `FactionRelationScore A→B`


```
var init := FactionProfile.compute\_baseline\_relation(a.profile, b.profile)

var rs := FactionRelationScore.new(b.faction\_id)
rs.relation = init["relation"]
rs.trust = init["trust"]
rs.tension = init["tension"]
rs.grievance = 0.0
rs.weariness = 0.0
rs.clamp\_all()
```


### Notes rapides (design)


* C’est **directionnel** : A→B ≠ B→A, car la personnalité de A filtre le jugement.
* `friction` est ce qui te sert ensuite dans l’ArcManager pour décider si un “incident” est probable, même si `relation` n’est pas déjà très bas.
* Tu peux très facilement “brancher” les axes du monde : par ex. si le monde est dominé par la magie, tu augmentes `w_magic_tech` ou `w_axis_similarity`, etc.


Si tu veux, prochaine brique logique : une fonction `initialize_relations_for_faction(faction_id)` qui construit le dictionnaire complet A→(toutes les autres) avec **cohérence globale** (ex : moyenne relation centrée, quelques ennemis naturels, etc.).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 4](#toc-detail-ch4)
<a id="moi-12"></a>
**Moi 12:**
Ok,prochaine brique logique : une fonction initialize\_relations\_for\_faction(faction\_id) qui construit le dictionnaire complet A→(toutes les autres) avec cohérence globale (ex : moyenne relation centrée, quelques ennemis naturels, etc.).


**ChatGPT:**
Voici une version **robuste + paramétrable** de `initialize_relations_for_faction()` qui construit **A→(toutes les autres)** avec :


* une **moyenne centrée** (≈ 0 par défaut),
* une **dispersion contrôlée** (pas 12 ennemis mortels day 1),
* **quelques ennemis naturels** et **quelques alliés naturels** (sélectionnés de façon “logique” : friction/opposition vs compatibilité),
* tout en restant **directionnel** (A→B ≠ B→A).


Je te la donne sous forme de **fonction utilitaire** (plus simple à brancher où tu veux). Elle suppose que tu as déjà `compute_baseline_relation(a_profile, b_profile)` et la classe `FactionRelationScore`.


---


## `FactionRelationsUtil.gd` (ou à coller dans un manager)


```
# Godot 4.x

class\_name FactionRelationsUtil
extends RefCounted

static func initialize\_relations\_for\_faction(
 source\_faction\_id: StringName,
 faction\_profiles: Dictionary, # Dictionary[StringName, FactionProfile]
 rng: RandomNumberGenerator,
 params: Dictionary = {},
 baseline\_params: Dictionary = {}
) -> Dictionary:
 # Returns: Dictionary[StringName, FactionRelationScore] (A -> others)

 if not faction\_profiles.has(source\_faction\_id):
 return {}

 var a: FactionProfile = faction\_profiles[source\_faction\_id]
 var targets: Array[StringName] = []
 for fid in faction\_profiles.keys():
 if StringName(fid) != source\_faction\_id:
 targets.append(StringName(fid))

 if targets.is\_empty():
 return {}

 # ---- Tunables (defaults) ----
 var desired\_mean: float = float(params.get("desired\_mean", 0.0))

# center around 0

 var desired\_std: float = float(params.get("desired\_std", 22.0))

# spread control

 var min\_scale: float = float(params.get("min\_scale", 0.70))
 var max\_scale: float = float(params.get("max\_scale", 1.20))

 var noise: int = int(params.get("noise", 3))

# small random jitter in relation

 var tension\_cap: float = float(params.get("tension\_cap", 40.0))

 var ally\_min: int = int(params.get("ally\_min", 1))
 var ally\_max: int = int(params.get("ally\_max", 2))
 var enemy\_min: int = int(params.get("enemy\_min", 1))
 var enemy\_max: int = int(params.get("enemy\_max", 2))

# Boosts applied to selected natural allies/enemies

 var ally\_rel\_boost: int = int(params.get("ally\_rel\_boost", 18))
 var ally\_trust\_boost: int = int(params.get("ally\_trust\_boost", 14))
 var ally\_tension\_delta: float = float(params.get("ally\_tension\_delta", -10.0))

 var enemy\_rel\_boost: int = int(params.get("enemy\_rel\_boost", -22))
 var enemy\_trust\_boost: int = int(params.get("enemy\_trust\_boost", -16))
 var enemy\_tension\_delta: float = float(params.get("enemy\_tension\_delta", +15.0))
 var enemy\_grievance\_init: float = float(params.get("enemy\_grievance\_init", 6.0))

# Hard caps on extremes to avoid too many day-1 dooms

 var min\_relation\_cap: int = int(params.get("min\_relation\_cap", -85))
 var max\_relation\_cap: int = int(params.get("max\_relation\_cap", +85))

# ---- 1) Raw baseline compute for all targets ----

 var raw\_rel: Array[float] = []
 var init\_map: Dictionary = {} # fid -> {relation, friction, trust, tension}
 for fid in targets:
 var b: FactionProfile = faction\_profiles[fid]
 var init := FactionProfile.compute\_baseline\_relation(a, b, baseline\_params)

# ensure tension cap here too

 init["tension"] = min(float(init.get("tension", 0.0)), tension\_cap)
 init\_map[fid] = init
 raw\_rel.append(float(init["relation"]))

# ---- 2) Center mean and normalize spread (std) ----

 var mean := \_mean(raw\_rel)
 var std := \_std(raw\_rel, mean)

# shift to desired mean

 var shift := desired\_mean - mean

 # scale to desired std (soft)
 var scale := 1.0
 if std > 0.001:
 scale = desired\_std / std
 scale = clampf(scale, min\_scale, max\_scale)

# ---- 3) Build preliminary relation scores ----

 var out: Dictionary[StringName, FactionRelationScore] = {}
 for fid in targets:
 var init := init\_map[fid]
 var rel0 := float(init["relation"])

 var rel := (rel0 + shift - desired\_mean) * scale + desired\_mean

 # small jitter to avoid perfectly symmetric worlds
 if noise > 0:
 rel += float(rng.randi\_range(-noise, noise))

 rel = clampf(rel, float(min\_relation\_cap), float(max\_relation\_cap))

 var rs := FactionRelationScore.new(fid)
 rs.relation = int(round(rel))
 rs.trust = int(init.get("trust", 0))
 rs.tension = float(init.get("tension", 0.0))
 rs.grievance = 0.0
 rs.weariness = 0.0
 rs.last\_event\_day = -999999
 rs.cooldown\_until\_day = -999999
 rs.clamp\_all()

 out[fid] = rs

 # ---- 4) Pick a few natural enemies and allies (coherence globale) ----
 var enemy\_count := rng.randi\_range(enemy\_min, enemy\_max)
 var ally\_count := rng.randi\_range(ally\_min, ally\_max)

# Score candidates (use baseline friction + negativity etc.)

 var enemy\_candidates: Array = []
 var ally\_candidates: Array = []

 for fid in targets:
 var init := init\_map[fid]
 var rs: FactionRelationScore = out[fid]

 var friction := float(init.get("friction", 0.0))
 var neg := max(0.0, -float(rs.relation))

# Enemies: friction + neg + low trust

 var enemy\_score := (0.65*friction) + (0.55*neg) + (0.25*max(0.0, -float(rs.trust)))
 enemy\_candidates.append({"fid": fid, "score": enemy\_score})

# Allies: high relation + trust - friction

 var ally\_score := (0.70*float(rs.relation)) + (0.45*float(rs.trust)) - (0.35*friction)
 ally\_candidates.append({"fid": fid, "score": ally\_score})

 enemy\_candidates.sort\_custom(func(ae, be): return ae["score"] > be["score"])
 ally\_candidates.sort\_custom(func(ae, be): return ae["score"] > be["score"])

 var chosen\_enemies: Array[StringName] = []
 for i in range(min(enemy\_count, enemy\_candidates.size())):
 chosen\_enemies.append(StringName(enemy\_candidates[i]["fid"]))

 var chosen\_allies: Array[StringName] = []
 for i in range(ally\_candidates.size()):
 if chosen\_allies.size() >= ally\_count:
 break
 var fid: StringName = StringName(ally\_candidates[i]["fid"])
 if chosen\_enemies.has(fid):
 continue
 chosen\_allies.append(fid)

# ---- 5) Apply ally/enemy boosts (creates a few “peaks” in the distribution) ----

 for fid in chosen\_enemies:
 var rs: FactionRelationScore = out[fid]
 rs.apply\_delta(
 enemy\_rel\_boost,
 enemy\_trust\_boost,
 enemy\_grievance\_init,
 enemy\_tension\_delta,
 0.0
 )

 for fid in chosen\_allies:
 var rs: FactionRelationScore = out[fid]
 rs.apply\_delta(
 ally\_rel\_boost,
 ally\_trust\_boost,
 0.0,
 ally\_tension\_delta,
 0.0
 )

# Optional: ensure final mean stays centered-ish (small correction only)

 if bool(params.get("final\_recenter", true)):
 \_recentre\_relations(out, desired\_mean, 0.35)

# 35% recenter strength

 return out


# ------------------ helpers ------------------

static func \_mean(arr: Array) -> float:
 if arr.is\_empty():
 return 0.0
 var s := 0.0
 for v in arr:
 s += float(v)
 return s / float(arr.size())

static func \_std(arr: Array, mean: float) -> float:
 if arr.size() <= 1:
 return 0.0
 var s := 0.0
 for v in arr:
 var d := float(v) - mean
 s += d * d
 return sqrt(s / float(arr.size()))

static func \_recentre\_relations(map: Dictionary, desired\_mean: float, strength: float) -> void:
 # strength 0..1 : how much to recenter the final relation mean
 var vals: Array[float] = []
 for fid in map.keys():
 vals.append(float(map[fid].relation))
 var mean := \_mean(vals)
 var shift := (desired\_mean - mean) * clampf(strength, 0.0, 1.0)
 for fid in map.keys():
 var rs: FactionRelationScore = map[fid]
 rs.relation = clampi(int(round(float(rs.relation) + shift)), -100, 100)
```


---


## Usage typique (dans ton FactionManager)


```
# faction\_profiles: Dictionary[StringName, FactionProfile]

# relations\_of\_A := Dictionary[StringName, FactionRelationScore]

var relations\_of\_A := FactionRelationsUtil.initialize\_relations\_for\_faction(
 a\_id,
 faction\_profiles,
 rng,
 {
 "desired\_mean": 0.0,
 "desired\_std": 22.0,
 "enemy\_min": 1, "enemy\_max": 2,
 "ally\_min": 1, "ally\_max": 2
 }
)
```


---


## Pourquoi ça donne une “cohérence globale”


* La compatibilité axes/personnalité est déjà dans `compute_baseline_relation()`.
* Ici, on **corrige la distribution** (centrage + std) pour éviter un monde “trop noir” ou “trop rose”.
* On **crée volontairement quelques pics** (alliés/ennemis naturels) au lieu d’un bruit uniforme.


---


Si tu veux, la **brique suivante** (utile pour ton ArcManager) : une fonction `initialize_relations_world()` qui initialise **toutes** les factions en une passe et peut, optionnellement, appliquer une contrainte de **réciprocité légère** (ex : A→B et B→A convergent à 70% sans être identiques).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 4](#toc-detail-ch4)
<a id="moi-13"></a>
**Moi 13:**
Ok brique suivante (utile pour ton
<a id="cite-arcmanager-1d7a8c-5"></a>ArcManager) : une fonction initialize\_relations\_world() qui initialise toutes les factions en une passe et peut, optionnellement, appliquer une contrainte de réciprocité légère (ex : A→B et B→A convergent à 70% sans être identiques).


**ChatGPT:**
Voici `initialize_relations_world()` : une passe complète qui :


1) initialise **A→(tous les autres)** pour chaque faction via `initialize_relations_for_faction()`,

2) applique optionnellement une **réciprocité légère** (A→B et B→A convergent partiellement),

3) garde des relations **directionnelles** (pas parfaitement symétriques).


Je l’ajoute dans `FactionRelationsUtil.gd` (même fichier que la fonction précédente).


---


## `initialize_relations_world()` + réciprocité


```
# --- In FactionRelationsUtil.gd ---

static func initialize\_relations\_world(
 faction\_profiles: Dictionary, # Dictionary[StringName, FactionProfile]
 rng: RandomNumberGenerator,
 world\_params: Dictionary = {},
 per\_faction\_params: Dictionary = {},
 baseline\_params: Dictionary = {}
) -> Dictionary:
 # Returns:
 # Dictionary[StringName, Dictionary[StringName, FactionRelationScore]]
 # i.e. world\_relations[A][B] = score (directional)

 var ids: Array[StringName] = []
 for fid in faction\_profiles.keys():
 ids.append(StringName(fid))

 var world: Dictionary = {}
 if ids.size() <= 1:
 return world

 # --- Pass 1: directional initialization for each faction ---
 for a\_id in ids:
 world[a\_id] = initialize\_relations\_for\_faction(
 a\_id,
 faction\_profiles,
 rng,
 per\_faction\_params,
 baseline\_params
 )

# --- Pass 2: optional reciprocity convergence ---

 var apply\_recip := bool(world\_params.get("apply\_reciprocity", true))
 if apply\_recip:
 var reciprocity\_strength := float(world\_params.get("reciprocity\_strength", 0.70))

# 0..1

 var keep\_asymmetry := float(world\_params.get("keep\_asymmetry", 0.30))

# 0..1

 var reciprocity\_noise := int(world\_params.get("reciprocity\_noise", 2))

# small jitter

 var max\_change\_per\_pair := int(world\_params.get("max\_change\_per\_pair", 18))

# clamp per pair update

 \_apply\_reciprocity(
 world,
 ids,
 rng,
 reciprocity\_strength,
 keep\_asymmetry,
 reciprocity\_noise,
 max\_change\_per\_pair
 )

# --- Pass 3: optional global clamps / sanity ---

 if bool(world\_params.get("final\_global\_sanity", true)):
 \_global\_sanity\_pass(world, ids, world\_params)

 return world


static func \_apply\_reciprocity(
 world: Dictionary,
 ids: Array[StringName],
 rng: RandomNumberGenerator,
 reciprocity\_strength: float,
 keep\_asymmetry: float,
 reciprocity\_noise: int,
 max\_change\_per\_pair: int
) -> void:
 reciprocity\_strength = clampf(reciprocity\_strength, 0.0, 1.0)
 keep\_asymmetry = clampf(keep\_asymmetry, 0.0, 1.0)

 for i in range(ids.size()):
 var a\_id := ids[i]
 for j in range(i + 1, ids.size()):
 var b\_id := ids[j]

 var map\_a: Dictionary = world.get(a\_id, {})
 var map\_b: Dictionary = world.get(b\_id, {})
 if not map\_a.has(b\_id) or not map\_b.has(a\_id):
 continue

 var ab: FactionRelationScore = map\_a[b\_id]
 var ba: FactionRelationScore = map\_b[a\_id]

 # --- Relation reciprocity ---
 var ab\_rel := float(ab.relation)
 var ba\_rel := float(ba.relation)
 var avg\_rel := (ab\_rel + ba\_rel) * 0.5

 # asymmetry target: keep part of (ab - ba)
 var asym := (ab\_rel - ba\_rel) * keep\_asymmetry

 var ab\_target := avg\_rel + asym
 var ba\_target := avg\_rel - asym

 # move each towards target by reciprocity\_strength
 var ab\_new := lerp(ab\_rel, ab\_target, reciprocity\_strength)
 var ba\_new := lerp(ba\_rel, ba\_target, reciprocity\_strength)

# tiny noise to avoid perfect pair patterns

 if reciprocity\_noise > 0:
 ab\_new += float(rng.randi\_range(-reciprocity\_noise, reciprocity\_noise))
 ba\_new += float(rng.randi\_range(-reciprocity\_noise, reciprocity\_noise))

# clamp change per pair so you don't destroy natural enemies/allies too much

 ab\_new = \_clamp\_delta(ab\_rel, ab\_new, float(max\_change\_per\_pair))
 ba\_new = \_clamp\_delta(ba\_rel, ba\_new, float(max\_change\_per\_pair))

 ab.relation = clampi(int(round(ab\_new)), -100, 100)
 ba.relation = clampi(int(round(ba\_new)), -100, 100)

# --- Trust reciprocity (softer) ---

 var ab\_tr := float(ab.trust)
 var ba\_tr := float(ba.trust)
 var avg\_tr := (ab\_tr + ba\_tr) * 0.5
 var asym\_tr := (ab\_tr - ba\_tr) * (keep\_asymmetry * 0.8)

 var ab\_tr\_target := avg\_tr + asym\_tr
 var ba\_tr\_target := avg\_tr - asym\_tr

 var ab\_tr\_new := lerp(ab\_tr, ab\_tr\_target, reciprocity\_strength * 0.55)
 var ba\_tr\_new := lerp(ba\_tr, ba\_tr\_target, reciprocity\_strength * 0.55)

 ab.trust = clampi(int(round(ab\_tr\_new)), -100, 100)
 ba.trust = clampi(int(round(ba\_tr\_new)), -100, 100)

# --- Tension reciprocity (makes arcs more stable) ---

 # Tension converges faster than relation (keeps wars from being too one-sided).
 var ab\_te := ab.tension
 var ba\_te := ba.tension
 var avg\_te := (ab\_te + ba\_te) * 0.5

 ab.tension = clampf(lerp(ab\_te, avg\_te, reciprocity\_strength * 0.80), 0.0, 100.0)
 ba.tension = clampf(lerp(ba\_te, avg\_te, reciprocity\_strength * 0.80), 0.0, 100.0)

 ab.clamp\_all()
 ba.clamp\_all()


static func \_clamp\_delta(old\_v: float, new\_v: float, max\_delta: float) -> float:
 var d := new\_v - old\_v
 if d > max\_delta:
 return old\_v + max\_delta
 if d < -max\_delta:
 return old\_v - max\_delta
 return new\_v


static func \_global\_sanity\_pass(world: Dictionary, ids: Array[StringName], world\_params: Dictionary) -> void:
 # Optional: avoid too many extreme relations globally (helps ArcManager).
 # You can disable or keep very light.
 var max\_extremes\_per\_faction := int(world\_params.get("max\_extremes\_per\_faction", 2))

# count of relations <= -80

 for a\_id in ids:
 var map\_a: Dictionary = world.get(a\_id, {})
 if map\_a.is\_empty():
 continue

 # collect extremes
 var negatives: Array = []
 for b\_id in map\_a.keys():
 var rs: FactionRelationScore = map\_a[b\_id]
 if rs.relation <= -80:
 negatives.append({"b": b\_id, "rel": rs.relation})

 if negatives.size() <= max\_extremes\_per\_faction:
 continue

 # soften the lowest ones a bit (keep the top few as "true nemesis")
 negatives.sort\_custom(func(x, y): return x["rel"] < y["rel"])

# most negative first

 for k in range(max\_extremes\_per\_faction, negatives.size()):
 var b\_id := negatives[k]["b"]
 var rs2: FactionRelationScore = map\_a[b\_id]
 rs2.relation = min(rs2.relation + 12, -60)

# soften towards -60

 rs2.tension = max(0.0, rs2.tension - 8.0)
 rs2.clamp\_all()
```


---


## Exemple d’appel


```
var world\_rel := FactionRelationsUtil.initialize\_relations\_world(
 faction\_profiles,
 rng,
 {
 "apply\_reciprocity": true,
 "reciprocity\_strength": 0.70,
 "keep\_asymmetry": 0.30,
 "reciprocity\_noise": 2,
 "max\_change\_per\_pair": 18,
 "final\_global\_sanity": true
 },
 {
 "desired\_mean": 0.0,
 "desired\_std": 22.0,
 "enemy\_min": 1, "enemy\_max": 2,
 "ally\_min": 1, "ally\_max": 2
 },
 {
 # baseline relation tuning forwarded to compute\_baseline\_relation()
 "w\_axis\_similarity": 80.0,
 "w\_cross\_conflict": 55.0
 }
)
```


---


### Pourquoi la réciprocité “70% sans être identiques” marche bien


* `reciprocity_strength` rapproche les deux directions vers une moyenne,
* `keep_asymmetry` conserve une partie de l’écart initial (ex : “A respecte B, mais B méprise A”),
* un peu de bruit + un clamp `max_change_per_pair` évitent de casser tes “alliés/ennemis naturels”.


---


Si tu veux, prochaine brique ArcManager : une fonction `compute_arc_event_chance(A->B score)` qui convertit **tension + friction + relation + personnalité** en probabilité d’incident, et une table de sélection d’`arc_action_type` (raid/ultimatum/truce/etc.) à partir de ces mêmes métriques.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 4](#toc-detail-ch4)
<a id="moi-14"></a>
**Moi 14:**
une fonction compute\_arc\_event\_chance(A->B score) qui convertit tension + friction + relation + personnalité en probabilité d’incident, et une table de sélection d’arc\_action\_type (raid/ultimatum/truce/etc.) à partir de ces mêmes métriques.


**ChatGPT:**
Voici une implémentation **prête à brancher** (Godot 4 / GDScript) :


* `compute_arc_event_chance(A→B)` : convertit **tension + friction + relation + grief + fatigue + personnalité** en **proba d’incident** (0..1), en respectant le cooldown.
* `select_arc_action_type(A→B)` : table de sélection **extensible** (raid / ultimatum / trêve / réparations / sabotage / guerre / ignore), basée sur les mêmes métriques, avec **weighted-random** (pas déterministe).


>
> Reco : ajoute `friction` dans `FactionRelationScore` (sinon tu dois la recalculer à chaque tick). Je l’utilise ci-dessous.
>
>
>


---


## 1) Petite extension : ajouter `friction` au `FactionRelationScore`


Dans `FactionRelationScore.gd` :


```
var friction: float = 0.0 # 0..100 (volatilité / friction idéologique)
```


Et dans `clamp_all()` :


```
friction = clampf(friction, METER\_MIN, METER\_MAX)
```


Quand tu initialises (baseline), fais :


```
rs.friction = init["friction"]
```


---


## 2) Utilitaire Arc : proba d’incident + sélection d’action


Tu peux mettre ça dans `ArcManager.gd` ou un `ArcDecisionUtil.gd`.


```
# Godot 4.x

class\_name ArcDecisionUtil
extends RefCounted

# --- Action types (StringName) ---

const ARC\_IGNORE: StringName = &"arc.ignore"
const ARC\_ULTIMATUM: StringName = &"arc.ultimatum"
const ARC\_REPARATIONS: StringName = &"arc.reparations"
const ARC\_RAID: StringName = &"arc.raid"
const ARC\_SABOTAGE: StringName = &"arc.sabotage"
const ARC\_TRUCE\_TALKS: StringName = &"arc.truce\_talks"
const ARC\_DECLARE\_WAR: StringName = &"arc.declare\_war"
const ARC\_ALLIANCE\_OFFER: StringName = &"arc.alliance\_offer"

static func compute\_arc\_event\_chance(
 rel: FactionRelationScore, # A -> B
 a\_profile: FactionProfile, # personnalité du "décideur" A
 b\_profile: FactionProfile, # pas forcément utile tout de suite, mais futur-proof
 current\_day: int,
 params: Dictionary = {}
) -> float:
 # Cooldown => pas d’event
 if rel.is\_on\_cooldown(current\_day):
 return 0.0

 var base: float = float(params.get("base", 0.015))

# 1.5% mini

 var max\_p: float = float(params.get("max\_p", 0.35))

# cap dur (tick journalier)

 var tension\_w: float = float(params.get("tension\_w", 0.22))
 var friction\_w: float = float(params.get("friction\_w", 0.14))
 var grievance\_w: float = float(params.get("grievance\_w", 0.10))
 var negrel\_w: float = float(params.get("negrel\_w", 0.20))
 var weariness\_w: float = float(params.get("weariness\_w", 0.18))

# personnalité (A filtre l’impulsivité)

 var aggr := a\_profile.get\_personality(FactionProfile.PERS\_AGGRESSION, 0.5)
 var veng := a\_profile.get\_personality(FactionProfile.PERS\_VENGEFULNESS, 0.5)
 var diplo := a\_profile.get\_personality(FactionProfile.PERS\_DIPLOMACY, 0.5)
 var risk := a\_profile.get\_personality(FactionProfile.PERS\_RISK\_AVERSION, 0.5)
 var expa := a\_profile.get\_personality(FactionProfile.PERS\_EXPANSIONISM, 0.5)

 var p := base

 var tension := rel.tension / 100.0
 var friction := rel.friction / 100.0
 var grievance := rel.grievance / 100.0
 var weariness := rel.weariness / 100.0
 var negrel := max(0.0, -float(rel.relation) / 100.0)

 p += tension * tension\_w
 p += friction * friction\_w
 p += grievance * grievance\_w
 p += negrel * negrel\_w
 p -= weariness * weariness\_w

 # personnalité : agressif/vindicatif/expa => + ; diplomate/prudent => -
 p += (aggr - 0.5) * float(params.get("aggr\_w", 0.10))
 p += (veng - 0.5) * float(params.get("veng\_w", 0.07))
 p += (expa - 0.5) * float(params.get("expa\_w", 0.05))
 p -= (diplo - 0.5) * float(params.get("diplo\_w", 0.11))
 p -= (risk - 0.5) * float(params.get("risk\_w", 0.05))

# amortisseur : si relation et trust déjà bons, on coupe beaucoup

 var trust\_pos := max(0.0, float(rel.trust) / 100.0)
 var rel\_pos := max(0.0, float(rel.relation) / 100.0)
 var goodwill := 0.5 * trust\_pos + 0.5 * rel\_pos
 p *= (1.0 - goodwill * float(params.get("goodwill\_damp", 0.55)))

 return clampf(p, 0.0, max\_p)


static func select\_arc\_action\_type(
 rel: FactionRelationScore, # A -> B
 a\_profile: FactionProfile,
 b\_profile: FactionProfile,
 rng: RandomNumberGenerator,
 current\_day: int,
 params: Dictionary = {}
) -> StringName:
 # Pré-conditions globales
 if rel.is\_on\_cooldown(current\_day):
 return ARC\_IGNORE

 # --- Inputs normalisés ---
 var tension := rel.tension / 100.0
 var friction := rel.friction / 100.0
 var grievance := rel.grievance / 100.0
 var weariness := rel.weariness / 100.0
 var negrel := max(0.0, -float(rel.relation) / 100.0)
 var posrel := max(0.0, float(rel.relation) / 100.0)
 var trust\_pos := max(0.0, float(rel.trust) / 100.0)

# personnalité A

 var aggr := a\_profile.get\_personality(FactionProfile.PERS\_AGGRESSION, 0.5)
 var veng := a\_profile.get\_personality(FactionProfile.PERS\_VENGEFULNESS, 0.5)
 var diplo := a\_profile.get\_personality(FactionProfile.PERS\_DIPLOMACY, 0.5)
 var risk := a\_profile.get\_personality(FactionProfile.PERS\_RISK\_AVERSION, 0.5)
 var expa := a\_profile.get\_personality(FactionProfile.PERS\_EXPANSIONISM, 0.5)
 var integ := a\_profile.get\_personality(FactionProfile.PERS\_INTEGRATIONISM, 0.5)

# (optionnel) si tu ajoutes plus tard pers.cunning : fallback 0.5

 var cunning := float(a\_profile.personality.get(&"pers.cunning", 0.5))

# contexte monde (optionnel)

 var external\_threat := float(params.get("external\_threat", 0.0))

# 0..1 (crise, ennemi commun)

 var opportunity := float(params.get("opportunity", 0.55))

# 0..1 (si tu n’as rien, laisse ~0.55)

# température softmax (plus bas => choix plus déterministe)

 var temperature := float(params.get("temperature", 0.18))

# --- Scores (0..+) ---

 var candidates: Array = []

 # IGNORE : essentiel en journalier
 var s\_ignore := 0.0
 s\_ignore += 0.90 * weariness
 s\_ignore += 0.35 * risk
 s\_ignore += 0.25 * diplo
 s\_ignore -= 0.60 * grievance
 s\_ignore -= 0.40 * tension
 candidates.append({"type": ARC\_IGNORE, "s": max(0.0, s\_ignore)})

# ULTIMATUM : pression sans escalade

 var s\_ult := 0.0
 s\_ult += 0.85 * grievance
 s\_ult += 0.45 * tension
 s\_ult += 0.25 * risk
 s\_ult += 0.20 * diplo
 s\_ult += 0.25 * negrel
 s\_ult -= 0.35 * weariness
 candidates.append({"type": ARC\_ULTIMATUM, "s": max(0.0, s\_ult)})

# REPARATIONS : possible si la relation n’est pas trop noire et que A est diplomate/intégrateur

 var s\_rep := 0.0
 s\_rep += 0.55 * diplo
 s\_rep += 0.35 * integ
 s\_rep += 0.25 * weariness
 s\_rep += 0.25 * tension
 s\_rep += 0.20 * trust\_pos
 s\_rep -= 0.55 * negrel
 s\_rep -= 0.40 * grievance
 # précondition douce
 if rel.relation > -60:
 candidates.append({"type": ARC\_REPARATIONS, "s": max(0.0, s\_rep)})

# TRUCE\_TALKS : fatigue haute + tension haute => sortie

 var s\_truce := 0.0
 s\_truce += 0.95 * weariness
 s\_truce += 0.55 * tension
 s\_truce += 0.55 * diplo
 s\_truce += 0.25 * risk
 s\_truce += 0.35 * external\_threat
 s\_truce -= 0.65 * grievance
 s\_truce -= 0.45 * (aggr)
 candidates.append({"type": ARC\_TRUCE\_TALKS, "s": max(0.0, s\_truce)})

# RAID : représaille “courte”, satisfait la grievance mais baisse trust ensuite (effets ailleurs)

 var s\_raid := 0.0
 s\_raid += 0.95 * grievance
 s\_raid += 0.70 * tension
 s\_raid += 0.55 * negrel
 s\_raid += 0.70 * opportunity
 s\_raid += 0.55 * aggr
 s\_raid += 0.35 * veng
 s\_raid += 0.25 * expa
 s\_raid -= 0.80 * weariness
 s\_raid -= 0.35 * diplo
 if tension >= 0.20: # pas de raid si tout est froid
 candidates.append({"type": ARC\_RAID, "s": max(0.0, s\_raid)})

# SABOTAGE : utile quand risk est haut (éviter frontal) + cunning

 var s\_sab := 0.0
 s\_sab += 0.65 * grievance
 s\_sab += 0.45 * tension
 s\_sab += 0.55 * cunning
 s\_sab += 0.35 * risk
 s\_sab += 0.35 * opportunity
 s\_sab += 0.25 * negrel
 s\_sab -= 0.55 * weariness
 s\_sab -= 0.25 * diplo
 if tension >= 0.25:
 candidates.append({"type": ARC\_SABOTAGE, "s": max(0.0, s\_sab)})

# DECLARE\_WAR : rare, conditions dures

 var s\_war := 0.0
 s\_war += 1.10 * tension
 s\_war += 0.85 * grievance
 s\_war += 0.80 * negrel
 s\_war += 0.55 * opportunity
 s\_war += 0.35 * expa
 s\_war += 0.30 * aggr
 s\_war -= 1.00 * weariness
 s\_war -= 0.25 * external\_threat # si menace externe, moins envie de guerre interne
 if rel.relation <= -55 and rel.tension >= 65.0 and rel.weariness <= 55.0:
 candidates.append({"type": ARC\_DECLARE\_WAR, "s": max(0.0, s\_war)})

# ALLIANCE\_OFFER : si menace externe + relation pas trop négative

 var s\_alliance := 0.0
 s\_alliance += 0.95 * external\_threat
 s\_alliance += 0.55 * diplo
 s\_alliance += 0.45 * integ
 s\_alliance += 0.25 * trust\_pos
 s\_alliance += 0.15 * posrel
 s\_alliance -= 0.55 * negrel
 s\_alliance -= 0.25 * grievance
 if external\_threat >= 0.35 and rel.relation > -35:
 candidates.append({"type": ARC\_ALLIANCE\_OFFER, "s": max(0.0, s\_alliance)})

# --- Weighted random via softmax-like ---

 return \_pick\_by\_softmax(rng, candidates, temperature)


static func \_pick\_by\_softmax(rng: RandomNumberGenerator, candidates: Array, temperature: float) -> StringName:
 temperature = max(0.05, temperature)

 var weights: Array[float] = []
 var sum\_w := 0.0

 for c in candidates:
 var s := float(c["s"])

# exp(s / temp) mais clamp pour éviter overflow

 var w := exp(clampf(s / temperature, -20.0, 20.0))
 weights.append(w)
 sum\_w += w

 if sum\_w <= 0.0:
 return ARC\_IGNORE

 var r := rng.randf() * sum\_w
 var acc := 0.0
 for i in range(candidates.size()):
 acc += weights[i]
 if r <= acc:
 return StringName(candidates[i]["type"])

 return StringName(candidates.back()["type"])
```


---


## 3) Comment l’utiliser dans ton `ArcManager.tick_day()`


Schéma typique (direction A→B) :


```
var p := ArcDecisionUtil.compute\_arc\_event\_chance(rel\_ab, profile\_a, profile\_b, day, {
 "max\_p": 0.35
})
if rng.randf() < p:
 var action := ArcDecisionUtil.select\_arc\_action\_type(rel\_ab, profile\_a, profile\_b, rng, day, {
 "external\_threat": world\_external\_threat, # 0..1
 "opportunity": opportunity\_ab, # 0..1 (optionnel)
 "temperature": 0.18
 })

# spawn offer selon action

 # rel\_ab.set\_cooldown(day, cooldown\_days\_for(action))
```


---


## Notes importantes (ArcManager “stable”)


* Tu verras que `IGNORE` et `ULTIMATUM/TRUCE` sortent souvent quand **weariness** monte : c’est exactement ce qui casse la boucle “vengeance ⇒ vengeance”.
* `RAID` est conditionné par `tension`, `opportunity`, et pénalisé par `weariness` + `diplomacy`.
* `DECLARE_WAR` a des **préconditions dures**, sinon tu vas déclarer la guerre trop tôt.


Si tu veux, prochaine brique : une table `cooldown_days_for(action)` + des deltas standards par `arc_action_type` (ce que la résolution LOYAL/NEUTRAL/TRAITOR appliquera sur relation/trust/grievance/tension/weariness).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 5](#toc-detail-ch5)
<a id="moi-15"></a>
**Moi 15:**
Ok prochaine brique : une table cooldown\_days\_for(action) + des deltas standards par arc\_action\_type (ce que la résolution LOYAL/NEUTRAL/TRAITOR appliquera sur relation/trust/grievance/tension/weariness)


**ChatGPT:**
Voici une brique **data-driven** (table + helpers) :


* `cooldown_days_for(action, rng)` : renvoie un cooldown (min..max + jitter).
* `get_arc_deltas(action, choice)` : renvoie les deltas **A→B** et **B→A**.
* `apply_arc_resolution(action, choice, rel_ab, rel_ba, day, rng)` : applique les deltas + pose le cooldown (sur les deux liens).


>
> Convention : **A = giver**, **B = antagonist**.
>
> `LOYAL` = le joueur aide **A** (l’action réussit “dans le sens A”).
>
> `NEUTRAL` = résultat mitigé.
>
> `TRAITOR` = le joueur aide **B** (ou sabote A).
>
>
>


À mettre dans un util genre `ArcEffectTable.gd` (ou dans ton `ArcManager`).


```
# Godot 4.x

class\_name ArcEffectTable
extends RefCounted

# --- Choices (match your QuestManager) ---

const CHOICE\_LOYAL: StringName = &"LOYAL"
const CHOICE\_NEUTRAL: StringName = &"NEUTRAL"
const CHOICE\_TRAITOR: StringName = &"TRAITOR"

# --- Action types (same as ArcDecisionUtil) ---

const ARC\_IGNORE: StringName = &"arc.ignore"
const ARC\_ULTIMATUM: StringName = &"arc.ultimatum"
const ARC\_REPARATIONS: StringName = &"arc.reparations"
const ARC\_RAID: StringName = &"arc.raid"
const ARC\_SABOTAGE: StringName = &"arc.sabotage"
const ARC\_TRUCE\_TALKS: StringName = &"arc.truce\_talks"
const ARC\_DECLARE\_WAR: StringName = &"arc.declare\_war"
const ARC\_ALLIANCE\_OFFER: StringName = &"arc.alliance\_offer"

# -----------------------------

# 1) Cooldowns (min..max days)

# -----------------------------

const COOLDOWNS: Dictionary = {
 ARC\_IGNORE: {"min": 1, "max": 2},
 ARC\_ULTIMATUM: {"min": 2, "max": 4},
 ARC\_REPARATIONS: {"min": 4, "max": 6},
 ARC\_TRUCE\_TALKS: {"min": 5, "max": 7},
 ARC\_RAID: {"min": 3, "max": 5},
 ARC\_SABOTAGE: {"min": 4, "max": 6},
 ARC\_DECLARE\_WAR: {"min": 7, "max": 10},
 ARC\_ALLIANCE\_OFFER:{"min": 6, "max": 9},
}

static func cooldown\_days\_for(action: StringName, rng: RandomNumberGenerator) -> int:
 var cd := COOLDOWNS.get(action, {"min": 3, "max": 5})
 return rng.randi\_range(int(cd["min"]), int(cd["max"]))

# --------------------------------------------------------

# 2) Deltas standards par action + choix (A->B, B->A)

# Keys: d\_relation(int), d\_trust(int), d\_grievance(float), d\_tension(float), d\_weariness(float)

# --------------------------------------------------------

const EFFECTS: Dictionary = {
 ARC\_IGNORE: {
 CHOICE\_LOYAL: {
 "ab": {"d\_relation": 0, "d\_trust": 0, "d\_grievance": -3.0, "d\_tension": -5.0, "d\_weariness": -2.0},
 "ba": {"d\_relation": 0, "d\_trust": 0, "d\_grievance": -2.0, "d\_tension": -4.0, "d\_weariness": -2.0},
 },
 CHOICE\_NEUTRAL: {
 "ab": {"d\_relation": 0, "d\_trust": 0, "d\_grievance": -1.0, "d\_tension": -2.0, "d\_weariness": -1.0},
 "ba": {"d\_relation": 0, "d\_trust": 0, "d\_grievance": -1.0, "d\_tension": -2.0, "d\_weariness": -1.0},
 },
 CHOICE\_TRAITOR: {
 "ab": {"d\_relation": -2, "d\_trust": -2, "d\_grievance": +2.0, "d\_tension": +2.0, "d\_weariness": 0.0},
 "ba": {"d\_relation": -2, "d\_trust": -2, "d\_grievance": +2.0, "d\_tension": +2.0, "d\_weariness": 0.0},
 },
 },

 ARC\_ULTIMATUM: {
 CHOICE\_LOYAL: {
 # “A obtient des concessions” : A se sent payé (grievance -), B en garde une rancune (grievance +)
 "ab": {"d\_relation": -4, "d\_trust": -2, "d\_grievance": -10.0, "d\_tension": +2.0, "d\_weariness": 0.0},
 "ba": {"d\_relation": -6, "d\_trust": -4, "d\_grievance": +6.0, "d\_tension": +4.0, "d\_weariness": 0.0},
 },
 CHOICE\_NEUTRAL: {
 "ab": {"d\_relation": -2, "d\_trust": -2, "d\_grievance": -2.0, "d\_tension": +1.0, "d\_weariness": 0.0},
 "ba": {"d\_relation": -2, "d\_trust": -1, "d\_grievance": +2.0, "d\_tension": +1.0, "d\_weariness": 0.0},
 },
 CHOICE\_TRAITOR: {
 # “A humilié / décrédibilisé” : A rancune monte, trust s’effondre
 "ab": {"d\_relation": -6, "d\_trust": -6, "d\_grievance": +6.0, "d\_tension": +4.0, "d\_weariness": 0.0},
 "ba": {"d\_relation": -3, "d\_trust": -1, "d\_grievance": 0.0, "d\_tension": +2.0, "d\_weariness": 0.0},
 },
 },

 ARC\_REPARATIONS: {
 CHOICE\_LOYAL: {
 # Réparations acceptées : forte détente bilatérale
 "ab": {"d\_relation": +12, "d\_trust": +10, "d\_grievance": -8.0, "d\_tension": -10.0, "d\_weariness": -2.0},
 "ba": {"d\_relation": +16, "d\_trust": +12, "d\_grievance": -18.0, "d\_tension": -12.0, "d\_weariness": -2.0},
 },
 CHOICE\_NEUTRAL: {
 "ab": {"d\_relation": +6, "d\_trust": +5, "d\_grievance": -4.0, "d\_tension": -6.0, "d\_weariness": -1.0},
 "ba": {"d\_relation": +8, "d\_trust": +6, "d\_grievance": -9.0, "d\_tension": -7.0, "d\_weariness": -1.0},
 },
 CHOICE\_TRAITOR: {
 # Réparations sabotées / fraude : backlash
 "ab": {"d\_relation": -8, "d\_trust": -10, "d\_grievance": +6.0, "d\_tension": +8.0, "d\_weariness": +2.0},
 "ba": {"d\_relation": -10, "d\_trust": -12, "d\_grievance": +10.0, "d\_tension": +10.0, "d\_weariness": +2.0},
 },
 },

 ARC\_TRUCE\_TALKS: {
 CHOICE\_LOYAL: {
 "ab": {"d\_relation": +8, "d\_trust": +12, "d\_grievance": -12.0, "d\_tension": -18.0, "d\_weariness": -4.0},
 "ba": {"d\_relation": +8, "d\_trust": +12, "d\_grievance": -12.0, "d\_tension": -18.0, "d\_weariness": -4.0},
 },
 CHOICE\_NEUTRAL: {
 "ab": {"d\_relation": +3, "d\_trust": +5, "d\_grievance": -5.0, "d\_tension": -10.0, "d\_weariness": -2.0},
 "ba": {"d\_relation": +3, "d\_trust": +5, "d\_grievance": -5.0, "d\_tension": -10.0, "d\_weariness": -2.0},
 },
 CHOICE\_TRAITOR: {
 "ab": {"d\_relation": -10, "d\_trust": -14, "d\_grievance": +8.0, "d\_tension": +12.0, "d\_weariness": +2.0},
 "ba": {"d\_relation": -10, "d\_trust": -14, "d\_grievance": +8.0, "d\_tension": +12.0, "d\_weariness": +2.0},
 },
 },

 ARC\_RAID: {
 CHOICE\_LOYAL: {
 # “paiement” : A grievance baisse, B grievance monte
 "ab": {"d\_relation": -10, "d\_trust": -8, "d\_grievance": -15.0, "d\_tension": +12.0, "d\_weariness": +6.0},
 "ba": {"d\_relation": -16, "d\_trust": -12, "d\_grievance": +18.0, "d\_tension": +14.0, "d\_weariness": +4.0},
 },
 CHOICE\_NEUTRAL: {
 "ab": {"d\_relation": -5, "d\_trust": -4, "d\_grievance": -8.0, "d\_tension": +7.0, "d\_weariness": +3.0},
 "ba": {"d\_relation": -8, "d\_trust": -6, "d\_grievance": +10.0, "d\_tension": +8.0, "d\_weariness": +2.0},
 },
 CHOICE\_TRAITOR: {
 # Raid retourné / saboté : A se radicalise, B “satisfait” un peu
 "ab": {"d\_relation": -12, "d\_trust": -10, "d\_grievance": +12.0, "d\_tension": +12.0, "d\_weariness": +7.0},
 "ba": {"d\_relation": -8, "d\_trust": -6, "d\_grievance": -8.0, "d\_tension": +10.0, "d\_weariness": +3.0},
 },
 },

 ARC\_SABOTAGE: {
 CHOICE\_LOYAL: {
 "ab": {"d\_relation": -6, "d\_trust": -6, "d\_grievance": -8.0, "d\_tension": +8.0, "d\_weariness": +2.0},
 "ba": {"d\_relation": -10, "d\_trust": -8, "d\_grievance": +10.0, "d\_tension": +10.0, "d\_weariness": +3.0},
 },
 CHOICE\_NEUTRAL: {
 "ab": {"d\_relation": -3, "d\_trust": -3, "d\_grievance": -4.0, "d\_tension": +5.0, "d\_weariness": +1.0},
 "ba": {"d\_relation": -5, "d\_trust": -4, "d\_grievance": +6.0, "d\_tension": +6.0, "d\_weariness": +1.0},
 },
 CHOICE\_TRAITOR: {
 # double-jeu : A se braque, B est “un peu payé”
 "ab": {"d\_relation": -8, "d\_trust": -10, "d\_grievance": +6.0, "d\_tension": +8.0, "d\_weariness": +3.0},
 "ba": {"d\_relation": -6, "d\_trust": -4, "d\_grievance": -4.0, "d\_tension": +6.0, "d\_weariness": +2.0},
 },
 },

 ARC\_DECLARE\_WAR: {
 CHOICE\_LOYAL: {
 "ab": {"d\_relation": -35, "d\_trust": -30, "d\_grievance": -20.0, "d\_tension": +30.0, "d\_weariness": +8.0},
 "ba": {"d\_relation": -35, "d\_trust": -30, "d\_grievance": +25.0, "d\_tension": +35.0, "d\_weariness": +10.0},
 },
 CHOICE\_NEUTRAL: {
 "ab": {"d\_relation": -15, "d\_trust": -12, "d\_grievance": -8.0, "d\_tension": +18.0, "d\_weariness": +4.0},
 "ba": {"d\_relation": -18, "d\_trust": -15, "d\_grievance": +12.0, "d\_tension": +20.0, "d\_weariness": +6.0},
 },
 CHOICE\_TRAITOR: {
 # guerre avortée / retournement politique : A humilié mais pas de guerre totale
 "ab": {"d\_relation": -20, "d\_trust": -10, "d\_grievance": +10.0, "d\_tension": +10.0, "d\_weariness": +3.0},
 "ba": {"d\_relation": -10, "d\_trust": -5, "d\_grievance": -5.0, "d\_tension": +5.0, "d\_weariness": +2.0},
 },
 },

 ARC\_ALLIANCE\_OFFER: {
 CHOICE\_LOYAL: {
 "ab": {"d\_relation": +20, "d\_trust": +22, "d\_grievance": -10.0, "d\_tension": -15.0, "d\_weariness": -3.0},
 "ba": {"d\_relation": +20, "d\_trust": +22, "d\_grievance": -10.0, "d\_tension": -15.0, "d\_weariness": -3.0},
 },
 CHOICE\_NEUTRAL: {
 "ab": {"d\_relation": +10, "d\_trust": +12, "d\_grievance": -5.0, "d\_tension": -8.0, "d\_weariness": -2.0},
 "ba": {"d\_relation": +10, "d\_trust": +12, "d\_grievance": -5.0, "d\_tension": -8.0, "d\_weariness": -2.0},
 },
 CHOICE\_TRAITOR: {
 "ab": {"d\_relation": -12, "d\_trust": -16, "d\_grievance": +8.0, "d\_tension": +10.0, "d\_weariness": +2.0},
 "ba": {"d\_relation": -12, "d\_trust": -16, "d\_grievance": +8.0, "d\_tension": +10.0, "d\_weariness": +2.0},
 },
 },
}

static func get\_arc\_deltas(action: StringName, choice: StringName) -> Dictionary:
 var by\_action := EFFECTS.get(action, null)
 if by\_action == null:
 return {}
 var by\_choice := by\_action.get(choice, null)
 if by\_choice == null:
 return {}
 return by\_choice

# --------------------------------------------------------

# 3) Apply helper (also sets cooldown for both links)

# --------------------------------------------------------

static func apply\_arc\_resolution(
 action: StringName,
 choice: StringName,
 rel\_ab: FactionRelationScore, # A -> B
 rel\_ba: FactionRelationScore, # B -> A
 current\_day: int,
 rng: RandomNumberGenerator,
 cooldown\_override\_days: int = -1
) -> void:
 var d := get\_arc\_deltas(action, choice)
 if d.is\_empty():
 return

 var ab := d["ab"]
 var ba := d["ba"]

 rel\_ab.apply\_delta(
 int(ab.get("d\_relation", 0)),
 int(ab.get("d\_trust", 0)),
 float(ab.get("d\_grievance", 0.0)),
 float(ab.get("d\_tension", 0.0)),
 float(ab.get("d\_weariness", 0.0))
 )

 rel\_ba.apply\_delta(
 int(ba.get("d\_relation", 0)),
 int(ba.get("d\_trust", 0)),
 float(ba.get("d\_grievance", 0.0)),
 float(ba.get("d\_tension", 0.0)),
 float(ba.get("d\_weariness", 0.0))
 )

 var cd := cooldown\_override\_days if cooldown\_override\_days >= 0 else cooldown\_days\_for(action, rng)
 rel\_ab.set\_cooldown(current\_day, cd)
 rel\_ba.set\_cooldown(current\_day, cd)
```


### Remarques rapides (importantes)


* Les deltas “hostiles” (`RAID/SABOTAGE/DECLARE_WAR`) appliquent le principe **“payer la dette”** : `grievance` baisse côté acteur si succès, mais augmente côté victime → ça évite une boucle symétrique infinie et crée une dynamique crédible.
* `TRUCE_TALKS / REPARATIONS / ALLIANCE_OFFER` sont **bilatéraux** : baisse tension + grief, remonte trust/relation.
* Tu peux ensuite ajouter une couche “personnalité en multiplicateur” en entourant `apply_delta()` d’un `scale = f(aggression, diplomacy, ...)` (mais je te laisse d’abord stabiliser ces valeurs de base).


Si tu veux, prochaine brique : brancher ça directement dans `ArcManager.on_quest_resolution_choice(inst, choice)` en lisant `context.arc_action_type`, `giver_faction_id`, `antagonist_faction_id`, puis en récupérant `rel_ab`/`rel_ba` depuis tes dictionnaires faction→(faction→score).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 5](#toc-detail-ch5)
<a id="moi-16"></a>
**Moi 16:**
Ok


**ChatGPT:**
Parfait. Voilà le branchement direct “ArcManager-ready” dans `on_quest_resolution_choice(inst, choice)`.


Hypothèses (adaptables à ton code) :


* `inst.context` contient `giver_faction_id`, `antagonist_faction_id`, `arc_action_type` (ou `arc_reason` si tu préfères), et `is_arc_rivalry=true`.
* Tu as une structure globale :
	+ `faction_relations: Dictionary[StringName, Dictionary[StringName, FactionRelationScore]]`
	+ où `faction_relations[A][B]` = A→B.
* Les profils :
	+ `faction_profiles: Dictionary[StringName, FactionProfile]`.


---


## ArcManager.gd — branchement résolution


```
func on\_quest\_resolution\_choice(inst: QuestInstance, choice: StringName) -> void:
 # 0) Filtre: uniquement les quêtes d'arc
 if inst == null or inst.context == null:
 return
 if not bool(inst.context.get("is\_arc\_rivalry", false)):
 return

 var giver\_id: StringName = StringName(inst.context.get("giver\_faction\_id", &""))
 var ant\_id: StringName = StringName(inst.context.get("antagonist\_faction\_id", &""))
 if giver\_id == &"" or ant\_id == &"":
 return

 # action type stockée dans le context (à toi de choisir le nom)
 var action: StringName = StringName(inst.context.get("arc\_action\_type", &""))
 if action == &"":
 # fallback (si tu utilisais arc\_reason / autre)
 action = StringName(inst.context.get("arc\_reason", &"arc.ignore"))

# 1) Récupérer les liens relationnels A->B et B->A

 var rel\_ab: FactionRelationScore = \_get\_or\_create\_relation\_score(giver\_id, ant\_id)
 var rel\_ba: FactionRelationScore = \_get\_or\_create\_relation\_score(ant\_id, giver\_id)
 if rel\_ab == null or rel\_ba == null:
 return

 # 2) Appliquer effets standards (deltas + cooldown)
 ArcEffectTable.apply\_arc\_resolution(
 action,
 choice,
 rel\_ab,
 rel\_ba,
 WorldGameState.day, # ou ton compteur de jour
 \_rng # RandomNumberGenerator de ton sim
 )

# 3) Optionnel: tags / état “WAR/PEACE/ALLIANCE” selon seuils

 # (tu peux commencer simple et raffiner)
 \_post\_arc\_state\_update(giver\_id, ant\_id, rel\_ab, rel\_ba)
```


---


## Helpers nécessaires


### 1) Accès sûr à `FactionRelationScore` (création lazy)


```
# faction\_relations: Dictionary[StringName, Dictionary[StringName, FactionRelationScore]]

# faction\_profiles: Dictionary[StringName, FactionProfile]

func \_get\_or\_create\_relation\_score(a\_id: StringName, b\_id: StringName) -> FactionRelationScore:
 if not faction\_relations.has(a\_id):
 faction\_relations[a\_id] = {}

 var map\_a: Dictionary = faction\_relations[a\_id]
 if map\_a.has(b\_id):
 return map\_a[b\_id]

 # Création lazy (si jamais ça arrive en cours de jeu)
 if not faction\_profiles.has(a\_id) or not faction\_profiles.has(b\_id):
 return null

 var a\_prof: FactionProfile = faction\_profiles[a\_id]
 var b\_prof: FactionProfile = faction\_profiles[b\_id]
 var init := FactionProfile.compute\_baseline\_relation(a\_prof, b\_prof)

 var rs := FactionRelationScore.new(b\_id)
 rs.relation = int(init["relation"])
 rs.trust = int(init["trust"])
 rs.tension = float(init["tension"])
 rs.friction = float(init.get("friction", 0.0))

# si tu l’as ajouté

 rs.grievance = 0.0
 rs.weariness = 0.0
 rs.clamp\_all()

 map\_a[b\_id] = rs
 faction\_relations[a\_id] = map\_a
 return rs
```


### 2) Mise à jour d’état après résolution (version simple)


Tu peux faire une logique minimaliste basée sur les deux directions :


```
func \_post\_arc\_state\_update(
 a\_id: StringName,
 b\_id: StringName,
 rel\_ab: FactionRelationScore,
 rel\_ba: FactionRelationScore
) -> void:
 var rel\_mean := 0.5 * (float(rel\_ab.relation) + float(rel\_ba.relation))
 var tension\_mean := 0.5 * (rel\_ab.tension + rel\_ba.tension)
 var trust\_mean := 0.5 * (float(rel\_ab.trust) + float(rel\_ba.trust))

# War trigger (simple)

 if rel\_mean <= -70.0 and tension\_mean >= 70.0:
 # set war state / tags
 # WorldTags.add("WAR\_%s\_%s" % [a\_id, b\_id]) etc.
 return

 # Alliance trigger
 if trust\_mean >= 65.0 and rel\_mean >= 45.0 and tension\_mean <= 25.0:
 # set alliance state / tags
 return

 # Peace / resolved rivalry hint
 if tension\_mean <= 10.0 and abs(rel\_mean) <= 20.0:
 # optionally close rivalry arc / stop generating events for this pair
 return
```


---


## À brancher côté “génération d’offre d’arc”


Quand tu crées une offer, mets dans `context` :


```
context["is\_arc\_rivalry"] = true
context["arc\_action\_type"] = action\_type # ex: "arc.raid"
context["giver\_faction\_id"] = giver\_id
context["antagonist\_faction\_id"] = ant\_id
```


Et l’ArcManager n’a plus qu’à lire ça à la résolution.


---


Si tu veux, prochaine étape très utile : intégrer un **multiplicateur personnalité** sur les deltas (ex : une faction pacifique convertit plus une trêve en trust, une vindicative réduit moins la grievance, etc.), tout en gardant la table “valeurs de base” stable.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 5](#toc-detail-ch5)
<a id="moi-17"></a>
**Moi 17:**
Ok


**ChatGPT:**
Top. Voilà l’étape suivante : **multiplicateurs de personnalité** appliqués aux deltas, sans casser ta table “base”.


Idée : tu gardes `EFFECTS` comme “valeurs de base”, puis tu scales certains deltas selon la personnalité du camp concerné **au moment d’appliquer**.


## 1) Règles de scaling (simples et efficaces)


Pour un camp X qui subit/applique un delta :


* **Grievance** :
	+ réduction de grievance est **moins efficace** si `vengefulness` est haut
* **Trust / Relation** (positifs) :
	+ gains sont **plus efficaces** si `diplomacy` et/ou `integrationism` sont hauts
* **Tension** (baisse) :
	+ baisse est **plus efficace** si `diplomacy` est haut
* **Tension** (hausse) :
	+ hausse est **plus forte** si `aggression` et `vengefulness` sont hauts
* **Weariness** :
	+ gain est **plus faible** si `expansionism` est haut
	+ gain est **plus fort** si `risk_aversion` est haut


Ça suffit déjà à donner des factions “qui se calment vite” vs “qui s’enlisent”.


---


## 2) Implémentation : `apply_arc_resolution_with_personality(...)`


Ajoute ça dans `ArcEffectTable.gd` (en plus de ta table `EFFECTS` existante).

Ça remplace l’appel à `apply_arc_resolution()` dans l’ArcManager.


```
static func apply\_arc\_resolution\_with\_personality(
 action: StringName,
 choice: StringName,
 rel\_ab: FactionRelationScore, # A -> B
 rel\_ba: FactionRelationScore, # B -> A
 profile\_a: FactionProfile,
 profile\_b: FactionProfile,
 current\_day: int,
 rng: RandomNumberGenerator,
 cooldown\_override\_days: int = -1,
 params: Dictionary = {}
) -> void:
 var d := get\_arc\_deltas(action, choice)
 if d.is\_empty():
 return

 var ab := d["ab"] # deltas applied to A->B score (A viewpoint)
 var ba := d["ba"] # deltas applied to B->A score (B viewpoint)

# Apply scaled deltas for each direction using the personality of the "owner" of that score:

 # - rel\_ab belongs to faction A => scale with profile\_a
 # - rel\_ba belongs to faction B => scale with profile\_b
 var ab\_scaled := \_scale\_deltas\_by\_personality(ab, profile\_a, params)
 var ba\_scaled := \_scale\_deltas\_by\_personality(ba, profile\_b, params)

 rel\_ab.apply\_delta(
 int(ab\_scaled["d\_relation"]),
 int(ab\_scaled["d\_trust"]),
 float(ab\_scaled["d\_grievance"]),
 float(ab\_scaled["d\_tension"]),
 float(ab\_scaled["d\_weariness"])
 )

 rel\_ba.apply\_delta(
 int(ba\_scaled["d\_relation"]),
 int(ba\_scaled["d\_trust"]),
 float(ba\_scaled["d\_grievance"]),
 float(ba\_scaled["d\_tension"]),
 float(ba\_scaled["d\_weariness"])
 )

 var cd := cooldown\_override\_days if cooldown\_override\_days >= 0 else cooldown\_days\_for(action, rng)
 rel\_ab.set\_cooldown(current\_day, cd)
 rel\_ba.set\_cooldown(current\_day, cd)


static func \_scale\_deltas\_by\_personality(delta: Dictionary, prof: FactionProfile, params: Dictionary) -> Dictionary:
 # Params to tune aggressiveness of scaling
 var k\_pos\_rel := float(params.get("k\_pos\_rel", 0.35))

# relation/trust gains

 var k\_neg\_rel := float(params.get("k\_neg\_rel", 0.20))

# relation/trust losses

 var k\_griev\_down := float(params.get("k\_griev\_down", 0.55))

# grievance reduction sensitivity

 var k\_griev\_up := float(params.get("k\_griev\_up", 0.25))

# grievance increase sensitivity

 var k\_tension\_down := float(params.get("k\_tension\_down", 0.35))
 var k\_tension\_up := float(params.get("k\_tension\_up", 0.25))
 var k\_wear\_gain := float(params.get("k\_wear\_gain", 0.45))

 var diplo := prof.get\_personality(FactionProfile.PERS\_DIPLOMACY, 0.5)
 var integ := prof.get\_personality(FactionProfile.PERS\_INTEGRATIONISM, 0.5)
 var aggr := prof.get\_personality(FactionProfile.PERS\_AGGRESSION, 0.5)
 var veng := prof.get\_personality(FactionProfile.PERS\_VENGEFULNESS, 0.5)
 var risk := prof.get\_personality(FactionProfile.PERS\_RISK\_AVERSION, 0.5)
 var expa := prof.get\_personality(FactionProfile.PERS\_EXPANSIONISM, 0.5)

 var out := {
 "d\_relation": int(delta.get("d\_relation", 0)),
 "d\_trust": int(delta.get("d\_trust", 0)),
 "d\_grievance": float(delta.get("d\_grievance", 0.0)),
 "d\_tension": float(delta.get("d\_tension", 0.0)),
 "d\_weariness": float(delta.get("d\_weariness", 0.0)),
 }

 # --- relation/trust ---
 # Gains: diplomacy + integration amplify
 var gain\_mul := 1.0 + k\_pos\_rel * ((diplo - 0.5) + 0.8*(integ - 0.5))

# Losses: aggression + vengefulness amplify (more punitive worldview)

 var loss\_mul := 1.0 + k\_neg\_rel * ((aggr - 0.5) + 0.8*(veng - 0.5))

 out["d\_relation"] = int(round(\_scale\_signed\_int(out["d\_relation"], gain\_mul, loss\_mul)))
 out["d\_trust"] = int(round(\_scale\_signed\_int(out["d\_trust"], gain\_mul, loss\_mul)))

# --- grievance ---

 # If delta is negative (grievance reduction), vengefulness makes it less effective.
 # If delta is positive, vengefulness makes it sting more.
 var g := float(out["d\_grievance"])
 if g < 0.0:
 var g\_mul\_down := 1.0 - k\_griev\_down * (veng - 0.5)

# veng>0.5 => smaller reduction

 g\_mul\_down = clampf(g\_mul\_down, 0.55, 1.35)
 out["d\_grievance"] = g * g\_mul\_down
 elif g > 0.0:
 var g\_mul\_up := 1.0 + k\_griev\_up * ((veng - 0.5) + 0.5*(aggr - 0.5))
 g\_mul\_up = clampf(g\_mul\_up, 0.70, 1.45)
 out["d\_grievance"] = g * g\_mul\_up

 # --- tension ---
 var t := float(out["d\_tension"])
 if t < 0.0:
 var t\_mul\_down := 1.0 + k\_tension\_down * (diplo - 0.5)
 t\_mul\_down = clampf(t\_mul\_down, 0.75, 1.40)
 out["d\_tension"] = t * t\_mul\_down
 elif t > 0.0:
 var t\_mul\_up := 1.0 + k\_tension\_up * ((aggr - 0.5) + 0.6*(veng - 0.5))
 t\_mul\_up = clampf(t\_mul\_up, 0.75, 1.45)
 out["d\_tension"] = t * t\_mul\_up

 # --- weariness ---
 var w := float(out["d\_weariness"])
 if w > 0.0:
 # expansionism reduces perceived weariness; risk\_aversion increases it
 var w\_mul := 1.0 \
 + k\_wear\_gain * (risk - 0.5) \
 - 0.35 * (expa - 0.5)
 w\_mul = clampf(w\_mul, 0.65, 1.55)
 out["d\_weariness"] = w * w\_mul

 # clamp small floats to avoid noise
 out["d\_grievance"] = \_snap\_small(out["d\_grievance"])
 out["d\_tension"] = \_snap\_small(out["d\_tension"])
 out["d\_weariness"] = \_snap\_small(out["d\_weariness"])

 return out


static func \_scale\_signed\_int(x: int, gain\_mul: float, loss\_mul: float) -> float:
 if x >= 0:
 return float(x) * gain\_mul
 return float(x) * loss\_mul

static func \_snap\_small(x: float) -> float:
 return 0.0 if abs(x) < 0.05 else x
```


---


## 3) Brancher dans ton ArcManager


Dans `on_quest_resolution_choice` :


```
var profile\_a: FactionProfile = faction\_profiles[giver\_id]
var profile\_b: FactionProfile = faction\_profiles[ant\_id]

ArcEffectTable.apply\_arc\_resolution\_with\_personality(
 action,
 choice,
 rel\_ab,
 rel\_ba,
 profile\_a,
 profile\_b,
 WorldGameState.day,
 \_rng
)
```


---


### Résultat attendu (ce que tu veux)


* Une faction **pacifique/diplomate** transforme une trêve en vraie détente (tension ↓↓, trust ↑↑).
* Une faction **vindicative** “digère” mal : grievance baisse moins vite, tension remonte plus vite.
* Une faction **expansionniste** “supporte” mieux la guerre (weariness monte moins), donc peut pousser plus loin.
* Tu obtiens des arcs qui peuvent **se désamorcer**, **stagner**, **exploser**, ou **bifurquer** vers alliance/fusion, selon profils.


Si tu veux, dernière brique utile pour stabiliser : un “cap” qui empêche une seule résolution de faire sauter relation/trust de 40 points (clamp par évènement), mais je peux aussi te proposer ça directement sans attendre.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 5](#toc-detail-ch5)
<a id="moi-18"></a>
**Moi 18:**
Ok, on dit qu'une relation ne peut pas evoluer de plus de 10 a 30% de son score actuelle (dans une direction ou l'autre, c'est a dire en + ou en -), en fonction de l'historique des deux factions (je recupere toute les actions faites et j'ai un compteur de type d'action dans
<a id="cite-arcnotebook-b751fa-1"></a>ArcNotebook, j'ai un dictionnaire arcType -> nb\_arc
Et arc\_type -> last\_arc\_date


**ChatGPT:**
OK — on va **caper le delta de relation** (et optionnellement le trust) à chaque résolution, avec une borne qui varie entre **10% et 30%** de la relation actuelle (en valeur absolue), **minimum 10 points**, selon l’historique stocké dans ton `ArcNotebook` (compteurs + last date par type).


## 1) Règle de cap


Pour un lien A→B (score `rel_ab.relation`), on calcule :


* `cap_pct ∈ [0.10 .. 0.30]` (dépend de l’historique)
* `cap_abs = max(10, round(abs(rel_ab.relation) * cap_pct))`
* puis on clamp : `d_relation = clamp(d_relation, -cap_abs, +cap_abs)`


Même logique pour B→A.


---


## 2) `ArcNotebook.gd` (minimal)


```
class\_name ArcNotebook
extends RefCounted

var count\_by\_type: Dictionary[StringName, int] = {}
var last\_day\_by\_type: Dictionary[StringName, int] = {}

func get\_total\_count() -> int:
 var s := 0
 for k in count\_by\_type.keys():
 s += int(count\_by\_type[k])
 return s

func get\_count(arc\_type: StringName) -> int:
 return int(count\_by\_type.get(arc\_type, 0))

func get\_days\_since(arc\_type: StringName, current\_day: int) -> int:
 var last := int(last\_day\_by\_type.get(arc\_type, -999999))
 return current\_day - last

func register(arc\_type: StringName, current\_day: int) -> void:
 count\_by\_type[arc\_type] = get\_count(arc\_type) + 1
 last\_day\_by\_type[arc\_type] = current\_day
```


---


## 3) Calcul du `cap_pct` basé historique (10% ↔ 30%)


* **Plus l’historique est “ancré”** (beaucoup d’arcs entre eux) ⇒ cap vers **10%**
* **Plus c’est rare / ancien** ⇒ cap vers **30%**
* **Répétition du même type** (spam) ⇒ cap réduit


```
static func compute\_relation\_cap\_pct(
 notebook: ArcNotebook,
 arc\_type: StringName,
 current\_day: int,
 params: Dictionary = {}
) -> float:
 var pct\_min := float(params.get("pct\_min", 0.10))
 var pct\_max := float(params.get("pct\_max", 0.30))

# ancrage global: plus il y a d'historique, moins ça bouge

 var total := notebook.get\_total\_count()
 var entrench := clampf(float(total) / float(params.get("entrench\_k", 30.0)), 0.0, 1.0)

# répétition du type: spam => moins d'impact marginal

 var type\_count := notebook.get\_count(arc\_type)
 var repetition := clampf(float(type\_count) / float(params.get("repetition\_k", 10.0)), 0.0, 1.0)

# récence du type: si ça date, on autorise plus de changement

 var days\_since := notebook.get\_days\_since(arc\_type, current\_day)
 var recency := clampf(float(days\_since) / float(params.get("recency\_k", 14.0)), 0.0, 1.0)

# volatilité (0..1) => cap\_pct via lerp(min,max)

# - (1-entrench) : relations "jeunes" bougent plus

 # - recency : ancien => bouge plus
 # - (1-repetition) : moins de spam => bouge plus
 var volatility :=
 0.55 * (1.0 - entrench) +
 0.30 * recency +
 0.15 * (1.0 - repetition)

 volatility = clampf(volatility, 0.0, 1.0)

 var cap\_pct := lerp(pct\_min, pct\_max, volatility)

# Optionnel: poids par type (ex: guerre = plus structurant)

 var type\_weight := float(params.get("type\_weight", 1.0))

# ou table externe

 cap\_pct *= type\_weight

 return clampf(cap\_pct, pct\_min, pct\_max)
```


---


## 4) Clamp du delta + intégration dans `ArcEffectTable.apply...`


On ajoute une variante qui prend `notebook` et applique le cap sur `d_relation` (et optionnellement `d_trust`).


```
static func apply\_arc\_resolution\_with\_personality\_and\_caps(
 action: StringName,
 choice: StringName,
 rel\_ab: FactionRelationScore,
 rel\_ba: FactionRelationScore,
 profile\_a: FactionProfile,
 profile\_b: FactionProfile,
 notebook: ArcNotebook, # <- historique du pair (A,B)
 current\_day: int,
 rng: RandomNumberGenerator,
 cooldown\_override\_days: int = -1,
 params: Dictionary = {}
) -> void:
 var d := get\_arc\_deltas(action, choice)
 if d.is\_empty():
 return

 # 1) scaling personnalité (comme avant)
 var ab\_scaled := \_scale\_deltas\_by\_personality(d["ab"], profile\_a, params)
 var ba\_scaled := \_scale\_deltas\_by\_personality(d["ba"], profile\_b, params)

# 2) cap percent (10%..30%) basé historique

 var cap\_pct := compute\_relation\_cap\_pct(notebook, action, current\_day, params)

# 3) cap absolute pour chaque direction (min 10 points)

 var min\_abs := int(params.get("min\_abs\_cap", 10))

 var cap\_ab := max(min\_abs, int(round(abs(rel\_ab.relation) * cap\_pct)))
 var cap\_ba := max(min\_abs, int(round(abs(rel\_ba.relation) * cap\_pct)))

 ab\_scaled["d\_relation"] = \_clamp\_delta\_int(int(ab\_scaled["d\_relation"]), cap\_ab)
 ba\_scaled["d\_relation"] = \_clamp\_delta\_int(int(ba\_scaled["d\_relation"]), cap\_ba)

# Optionnel: cap trust aussi (souvent utile)

 if bool(params.get("cap\_trust\_too", true)):
 var cap\_pct\_trust := float(params.get("cap\_pct\_trust", cap\_pct))

# par défaut même règle

 var cap\_ab\_t := max(min\_abs, int(round(abs(rel\_ab.trust) * cap\_pct\_trust)))
 var cap\_ba\_t := max(min\_abs, int(round(abs(rel\_ba.trust) * cap\_pct\_trust)))
 ab\_scaled["d\_trust"] = \_clamp\_delta\_int(int(ab\_scaled["d\_trust"]), cap\_ab\_t)
 ba\_scaled["d\_trust"] = \_clamp\_delta\_int(int(ba\_scaled["d\_trust"]), cap\_ba\_t)

# 4) apply

 rel\_ab.apply\_delta(int(ab\_scaled["d\_relation"]), int(ab\_scaled["d\_trust"]),
 float(ab\_scaled["d\_grievance"]), float(ab\_scaled["d\_tension"]), float(ab\_scaled["d\_weariness"]))
 rel\_ba.apply\_delta(int(ba\_scaled["d\_relation"]), int(ba\_scaled["d\_trust"]),
 float(ba\_scaled["d\_grievance"]), float(ba\_scaled["d\_tension"]), float(ba\_scaled["d\_weariness"]))

# 5) cooldown + notebook update

 var cd := cooldown\_override\_days if cooldown\_override\_days >= 0 else cooldown\_days\_for(action, rng)
 rel\_ab.set\_cooldown(current\_day, cd)
 rel\_ba.set\_cooldown(current\_day, cd)

 notebook.register(action, current\_day)


static func \_clamp\_delta\_int(delta: int, cap\_abs: int) -> int:
 return clampi(delta, -cap\_abs, cap\_abs)
```


---


## 5) Où récupérer le `ArcNotebook` ?


Le plus simple : **un notebook par paire** (A,B) dans l’ArcManager, clé canonique :


* `key = "%s|%s" % [min(a,b), max(a,b)]`
* `pair_notebooks[key] = ArcNotebook`


Et tu passes ce notebook à `apply_arc_resolution_with_personality_and_caps(...)`.


---


Si tu me dis comment tu stockes actuellement `ArcNotebook` (par `arc_id` ? par paire ?), je te donne le code exact `_get_or_create_notebook(giver_id, ant_id)` + la clé canonique et où l’initialiser dans ton pipeline.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 5](#toc-detail-ch5)
<a id="moi-19"></a>
**Moi 19:**
Le
<a id="cite-arcnotebook-b751fa-2"></a>ArcNotebook est stocké dans le arcManager comme ça : var arc\_notebook :
<a id="cite-arcnotebook-b751fa-3"></a>ArcNotebook.

Il est encore en construction, donc tu peux y ajouter ce dont tu as besoin.

J'adapterai ce qui a besoin de l'etre


**ChatGPT:**
Parfait : avec **un seul** `arc_notebook : ArcNotebook` dans l’`ArcManager`, le plus simple est d’en faire un **registre d’historique par paire** (A,B), puisque ton cap dépend de “l’historique des deux factions”.


Ci-dessous, je te donne :


1) une version d’`ArcNotebook` extensible (par paire, compteur par type + last day + mémoire récente),

2) une fonction `compute_relation_cap_pct(...)` qui sort **[0.10 .. 0.30]** selon cet historique,

3) l’intégration dans `apply_arc_resolution...` pour caper `d_relation` (et optionnellement `d_trust`).


---


## 1) ArcNotebook par paire


### `ArcPairHistory.gd` (ou en inner class)


```
class\_name ArcPairHistory
extends RefCounted

var total\_count: int = 0
var count\_by\_type: Dictionary[StringName, int] = {}
var last\_day\_by\_type: Dictionary[StringName, int] = {}

var last\_event\_day: int = -999999

# Mémoire courte (pour détecter spam récent)

var recent\_events: Array = [] # [{day:int, type:StringName}]
var max\_recent: int = 64

func register(arc\_type: StringName, day: int) -> void:
 total\_count += 1
 count\_by\_type[arc\_type] = int(count\_by\_type.get(arc\_type, 0)) + 1
 last\_day\_by\_type[arc\_type] = day
 last\_event\_day = max(last\_event\_day, day)

 recent\_events.append({"day": day, "type": arc\_type})
 if recent\_events.size() > max\_recent:
 recent\_events.pop\_front()

func get\_count(arc\_type: StringName) -> int:
 return int(count\_by\_type.get(arc\_type, 0))

func get\_days\_since(arc\_type: StringName, current\_day: int) -> int:
 var last := int(last\_day\_by\_type.get(arc\_type, -999999))
 return current\_day - last

func get\_days\_since\_any(current\_day: int) -> int:
 return current\_day - last\_event\_day

func count\_in\_last\_days(current\_day: int, days: int, arc\_type: StringName = &"") -> int:
 var c := 0
 for e in recent\_events:
 var d := int(e["day"])
 if current\_day - d > days:
 continue
 if arc\_type == &"" or StringName(e["type"]) == arc\_type:
 c += 1
 return c
```


### `ArcNotebook.gd`


```
class\_name ArcNotebook
extends RefCounted

var pairs: Dictionary[StringName, ArcPairHistory] = {}

static func \_pair\_key(a: StringName, b: StringName) -> StringName:
 var sa := String(a)
 var sb := String(b)
 return StringName(sa + "|" + sb) if sa <= sb else StringName(sb + "|" + sa)

func get\_pair(a: StringName, b: StringName) -> ArcPairHistory:
 var k := \_pair\_key(a, b)
 if not pairs.has(k):
 pairs[k] = ArcPairHistory.new()
 return pairs[k]

func register(a: StringName, b: StringName, arc\_type: StringName, day: int) -> void:
 get\_pair(a, b).register(arc\_type, day)
```


---


## 2) Cap % (10%..30%) basé sur l’historique de la paire


```
static func compute\_relation\_cap\_pct(
 h: ArcPairHistory,
 arc\_type: StringName,
 current\_day: int,
 params: Dictionary = {}
) -> float:
 var pct\_min := float(params.get("pct\_min", 0.10))
 var pct\_max := float(params.get("pct\_max", 0.30))

# Plus il y a d'historique, plus la relation est "ancrée" => cap vers 10%

 var entrench\_k := float(params.get("entrench\_k", 30.0))

# ~30 events => bien ancré

 var entrench := clampf(float(h.total\_count) / entrench\_k, 0.0, 1.0)

# Spam récent du même type => cap réduit

 var window\_days := int(params.get("window\_days", 14))
 var spam\_k := float(params.get("spam\_k", 6.0))

# 6 events du même type sur 14j => spam fort

 var recent\_same := float(h.count\_in\_last\_days(current\_day, window\_days, arc\_type))
 var spam := clampf(recent\_same / spam\_k, 0.0, 1.0)

# Si ça fait longtemps qu’on n’a pas vu ce type => cap augmente

 var recency\_k := float(params.get("recency\_k", 14.0))
 var days\_since\_type := float(max(0, h.get\_days\_since(arc\_type, current\_day)))
 var type\_oldness := clampf(days\_since\_type / recency\_k, 0.0, 1.0)

# Si la paire n’a eu aucun event depuis longtemps => cap augmente (relation plus "mobile")

 var pair\_recency\_k := float(params.get("pair\_recency\_k", 21.0))
 var days\_since\_any := float(max(0, h.get\_days\_since\_any(current\_day)))
 var pair\_oldness := clampf(days\_since\_any / pair\_recency\_k, 0.0, 1.0)

# Volatilité 0..1

 var volatility :=
 0.45 * (1.0 - entrench) +
 0.25 * type\_oldness +
 0.15 * pair\_oldness +
 0.15 * (1.0 - spam)

 volatility = clampf(volatility, 0.0, 1.0)

 var cap\_pct := lerp(pct\_min, pct\_max, volatility)

# Optionnel: certains types "comptent" plus / moins

 var type\_weight := float(params.get("type\_weight", 1.0))
 cap\_pct *= type\_weight

 return clampf(cap\_pct, pct\_min, pct\_max)
```


---


## 3) Clamp du delta de relation (10 points min, sinon % du score actuel)


Dans ton `ArcEffectTable.apply_arc_resolution_with_personality_and_caps(...)`, remplace le calcul du cap par la version “pair history” :


```
# h = ArcPairHistory (paire A,B)

var cap\_pct := compute\_relation\_cap\_pct(h, action, current\_day, params)

var min\_abs := int(params.get("min\_abs\_cap", 10))

var cap\_ab := max(min\_abs, int(round(abs(rel\_ab.relation) * cap\_pct)))
var cap\_ba := max(min\_abs, int(round(abs(rel\_ba.relation) * cap\_pct)))

ab\_scaled["d\_relation"] = clampi(int(ab\_scaled["d\_relation"]), -cap\_ab, cap\_ab)
ba\_scaled["d\_relation"] = clampi(int(ba\_scaled["d\_relation"]), -cap\_ba, cap\_ba)
```


Et à la fin (après application), enregistre l’event :


```
h.register(action, current\_day)

# ou arc\_notebook.register(giver\_id, ant\_id, action, current\_day)

```


---


## 4) Intégration ArcManager (résolution)


```
var h: ArcPairHistory = arc\_notebook.get\_pair(giver\_id, ant\_id)

ArcEffectTable.apply\_arc\_resolution\_with\_personality\_and\_caps(
 action, choice,
 rel\_ab, rel\_ba,
 profile\_a, profile\_b,
 h,
 WorldGameState.day,
 \_rng
)
```


---


### Ce que ça t’apporte


* Au début (peu d’historique) : **cap proche de 30%** → les relations bougent vite (dynamique).
* Quand l’historique s’accumule : **cap se rapproche de 10%** → inertie, impossible de “retourner” une haine viscérale en 2 quêtes.
* Si tu spams le même type d’action : impact marginal baisse → anti-boucle “raid raid raid”.


Si tu veux, prochaine micro-brique utile : une table `type_weight` par `arc_action_type` (ex : `declare_war` plus structurant mais *moins* fréquent), et/ou un cap différent pour `trust` que pour `relation` (souvent meilleur gameplay).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 5](#toc-detail-ch5)
<a id="moi-20"></a>
**Moi 20:**
En fait, dans un
<a id="cite-arcnotebook-b751fa-4"></a>ArcNotebook, j'ai des arcHistory par faction, l'arcHistory contient des metadata (les count des arcType par exemple) et aussi l'historique de toute les rivalité genere avec leur date de resolutions etc


**ChatGPT:**
OK, on peut garder ton modèle “**ArcNotebook → ArcHistory par faction**”, et en déduire un **cap A→B** en combinant :


* l’historique **global** de A et B (plus une faction a vécu d’arcs, plus ses positions sont “ancrées”),
* l’historique **spécifique A↔B** (plus ils se sont affrontés/négociés, plus ça bouge lentement),
* la **récence** (si ça date, ça bouge plus),
* le **spam de type** récent (si tu répètes le même arc\_type, impact marginal ↓).


Pour éviter de rescanner “toutes les rivalités” à chaque résolution, je te conseille d’ajouter dans `ArcHistory` un petit **index par cible** (B) qui contient les mêmes metadata que tu as déjà globalement.


---


## 1) Structures de données (ArcNotebook → ArcHistory → ArcTargetMeta)

### ArcNotebook.gd


```
class\_name ArcNotebook
extends RefCounted

var history\_by\_faction: Dictionary[StringName, ArcHistory] = {}

func get\_history(faction\_id: StringName) -> ArcHistory:
 if not history\_by\_faction.has(faction\_id):
 history\_by\_faction[faction\_id] = ArcHistory.new(faction\_id)
 return history\_by\_faction[faction\_id]
```


### ArcHistory.gd


```
class\_name ArcHistory
extends RefCounted

var owner\_id: StringName

# Global metadata (comme tu as déjà)

var total\_count: int = 0
var count\_by\_type: Dictionary[StringName, int] = {}
var last\_day\_by\_type: Dictionary[StringName, int] = {}

# Index par cible (B) -> meta “A envers B”

var meta\_by\_target: Dictionary[StringName, ArcTargetMeta] = {}

# Historique détaillé (tes rivalités / dates / résolutions / choix etc.)

var rivalry\_records: Array = [] # à toi: records/objects existants

func \_init(id: StringName = &"") -> void:
 owner\_id = id

func get\_target\_meta(target\_id: StringName) -> ArcTargetMeta:
 if not meta\_by\_target.has(target\_id):
 meta\_by\_target[target\_id] = ArcTargetMeta.new(target\_id)
 return meta\_by\_target[target\_id]

func register\_event(target\_id: StringName, arc\_type: StringName, day: int) -> void:
 total\_count += 1
 count\_by\_type[arc\_type] = int(count\_by\_type.get(arc\_type, 0)) + 1
 last\_day\_by\_type[arc\_type] = day

 get\_target\_meta(target\_id).register(arc\_type, day)
```


### ArcTargetMeta.gd


```
class\_name ArcTargetMeta
extends RefCounted

var target\_id: StringName
var total\_count: int = 0
var count\_by\_type: Dictionary[StringName, int] = {}
var last\_day\_by\_type: Dictionary[StringName, int] = {}
var last\_event\_day: int = -999999

# mémoire courte “anti-spam”

var recent\_events: Array = [] # [{day:int, type:StringName}]
var max\_recent: int = 64

func \_init(id: StringName = &"") -> void:
 target\_id = id

func register(arc\_type: StringName, day: int) -> void:
 total\_count += 1
 count\_by\_type[arc\_type] = int(count\_by\_type.get(arc\_type, 0)) + 1
 last\_day\_by\_type[arc\_type] = day
 last\_event\_day = max(last\_event\_day, day)

 recent\_events.append({"day": day, "type": arc\_type})
 if recent\_events.size() > max\_recent:
 recent\_events.pop\_front()

func get\_count(arc\_type: StringName) -> int:
 return int(count\_by\_type.get(arc\_type, 0))

func get\_days\_since\_type(arc\_type: StringName, current\_day: int) -> int:
 return current\_day - int(last\_day\_by\_type.get(arc\_type, -999999))

func get\_days\_since\_any(current\_day: int) -> int:
 return current\_day - last\_event\_day

func count\_in\_last\_days(current\_day: int, days: int, arc\_type: StringName = &"") -> int:
 var c := 0
 for e in recent\_events:
 var d := int(e["day"])
 if current\_day - d > days:
 continue
 if arc\_type == &"" or StringName(e["type"]) == arc\_type:
 c += 1
 return c
```


>
> Ensuite, quand une rivalité se résout, tu fais `historyA.register_event(B, arc_type, day)` **et** `historyB.register_event(A, arc_type, day)` + tu ajoutes ton record détaillé dans `rivalry_records` si tu veux.
>
>
>


---


## 2) Cap % (10%..30%) basé sur “l’historique des deux factions”


On combine **A→B meta** + **B→A meta** + (global A + global B).


```
static func compute\_relation\_cap\_pct\_from\_histories(
 hist\_a: ArcHistory,
 hist\_b: ArcHistory,
 a\_id: StringName,
 b\_id: StringName,
 arc\_type: StringName,
 current\_day: int,
 params: Dictionary = {}
) -> float:
 var pct\_min := float(params.get("pct\_min", 0.10))
 var pct\_max := float(params.get("pct\_max", 0.30))

 var meta\_ab := hist\_a.get\_target\_meta(b\_id)
 var meta\_ba := hist\_b.get\_target\_meta(a\_id)

# --- Entrenchment pair (A<->B) ---

 var pair\_k := float(params.get("pair\_k", 18.0))
 var pair\_total := float(meta\_ab.total\_count + meta\_ba.total\_count) * 0.5
 var entrench\_pair := clampf(pair\_total / pair\_k, 0.0, 1.0)

# --- Entrenchment global (A & B) ---

 var global\_k := float(params.get("global\_k", 40.0))
 var global\_total := float(hist\_a.total\_count + hist\_b.total\_count) * 0.5
 var entrench\_global := clampf(global\_total / global\_k, 0.0, 1.0)

# --- Spam récent du même type sur la paire ---

 var window\_days := int(params.get("window\_days", 14))
 var spam\_k := float(params.get("spam\_k", 6.0))
 var recent\_same := float(meta\_ab.count\_in\_last\_days(current\_day, window\_days, arc\_type)
 + meta\_ba.count\_in\_last\_days(current\_day, window\_days, arc\_type)) * 0.5
 var spam := clampf(recent\_same / spam\_k, 0.0, 1.0)

# --- Récence du type et de la paire ---

 var recency\_k := float(params.get("recency\_k", 14.0))
 var days\_since\_type := float(min(
 meta\_ab.get\_days\_since\_type(arc\_type, current\_day),
 meta\_ba.get\_days\_since\_type(arc\_type, current\_day)
 ))
 var type\_oldness := clampf(days\_since\_type / recency\_k, 0.0, 1.0)

 var pair\_recency\_k := float(params.get("pair\_recency\_k", 21.0))
 var days\_since\_any := float(min(meta\_ab.get\_days\_since\_any(current\_day), meta\_ba.get\_days\_since\_any(current\_day)))
 var pair\_oldness := clampf(days\_since\_any / pair\_recency\_k, 0.0, 1.0)

# --- Volatilité (0..1) => cap\_pct (10%..30%) ---

 # + vieux / rare => bouge plus
 # + ancré / spammé => bouge moins
 var volatility :=
 0.40 * (1.0 - entrench\_pair) +
 0.15 * (1.0 - entrench\_global) +
 0.20 * type\_oldness +
 0.10 * pair\_oldness +
 0.15 * (1.0 - spam)

 volatility = clampf(volatility, 0.0, 1.0)

 var cap\_pct := lerp(pct\_min, pct\_max, volatility)

# Optionnel: poids par type (ex: declare\_war => plus structurant donc cap plus bas)

 var type\_weight := float(params.get("type\_weight", 1.0))
 cap\_pct *= type\_weight

 return clampf(cap\_pct, pct\_min, pct\_max)
```


---


## 3) Application dans ta résolution (clamp du delta)


Après avoir calculé tes deltas (avec personnalité ou non), tu clamps juste `d_relation` :


```
var cap\_pct := compute\_relation\_cap\_pct\_from\_histories(
 arc\_notebook.get\_history(giver\_id),
 arc\_notebook.get\_history(ant\_id),
 giver\_id, ant\_id,
 action, WorldGameState.day,
 {"type\_weight": 1.0}
)

var min\_abs := 10
var cap\_ab := max(min\_abs, int(round(abs(rel\_ab.relation) * cap\_pct)))
var cap\_ba := max(min\_abs, int(round(abs(rel\_ba.relation) * cap\_pct)))

ab\_scaled["d\_relation"] = clampi(int(ab\_scaled["d\_relation"]), -cap\_ab, cap\_ab)
ba\_scaled["d\_relation"] = clampi(int(ba\_scaled["d\_relation"]), -cap\_ba, cap\_ba)
```


Et tu enregistres l’event :


```
arc\_notebook.get\_history(giver\_id).register\_event(ant\_id, action, WorldGameState.day)
arc\_notebook.get\_history(ant\_id).register\_event(giver\_id, action, WorldGameState.day)
```


---


### Pourquoi ça colle à ton besoin


* Tu gardes ton `ArcNotebook` “par faction” + historique complet.
* Tu ajoutes juste un **résumé par cible** (léger), ce qui te donne un cap basé sur “l’historique des deux factions” sans coûts.
* Le cap devient naturellement :
	+ **haut (≈30%)** quand la relation est jeune ou que la paire n’a pas interagi depuis longtemps,
	+ **bas (≈10%)** quand A et B ont un long passif, ou quand tu spams le même arc\_type.


Si tu veux, je peux te proposer une table `type_weight` “raisonnable” (ex : `declare_war: 0.6`, `truce_talks: 1.0`, `raid: 0.85`, etc.) pour que certains événements soient **plus structurants** (mais bougent moins d’un coup) tout en restant impactants via tension/grievance/weariness.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 5](#toc-detail-ch5)
<a id="moi-21"></a>
**Moi 21:**
Ok pour la table et l'application par evenement


**ChatGPT:**
Parfait. On va faire une **table de “policy” par `arc_action_type`** qui définit :


* `cap_weight` : modifie le **cap%** (10%..30%) pour **RELATION**
* `trust_cap_weight` : idem pour **TRUST**
* `cooldown_mult` : multiplie le cooldown de base
* (optionnel) `delta_mult_*` : si tu veux “durcir” tension/grievance sans toucher relation


Ensuite, à **chaque événement résolu**, on :

1) calcule `cap_pct` (10%..30%) via l’historique A & B,

2) applique `cap_weight`/`trust_cap_weight`,

3) clamp `d_relation` (et `d_trust`),

4) applique les deltas,

5) pose cooldown,

6) enregistre dans `ArcNotebook` (counts + last\_day + record détaillé).


---


## 1) Table `ARC_TYPE_POLICY`


À mettre dans `ArcEffectTable.gd` (ou un fichier dédié).


```
const ARC\_TYPE\_POLICY: Dictionary = {
 ARC\_IGNORE: {
 "cap\_weight": 1.00,
 "trust\_cap\_weight": 1.00,
 "cooldown\_mult": 1.00,
 },
 ARC\_ULTIMATUM: {
 "cap\_weight": 0.90,
 "trust\_cap\_weight": 0.85,
 "cooldown\_mult": 1.05,
 },
 ARC\_REPARATIONS: {
 # Peut réellement changer une relation… mais pas instantanément
 "cap\_weight": 1.15,
 "trust\_cap\_weight": 1.20,
 "cooldown\_mult": 1.10,
 },
 ARC\_TRUCE\_TALKS: {
 # Trêve = gros levier sur tension + trust
 "cap\_weight": 1.10,
 "trust\_cap\_weight": 1.25,
 "cooldown\_mult": 1.20,
 },
 ARC\_RAID: {
 # Hostile : impact relation limité, mais tension/grievance montent via deltas
 "cap\_weight": 0.85,
 "trust\_cap\_weight": 0.80,
 "cooldown\_mult": 1.10,
 },
 ARC\_SABOTAGE: {
 "cap\_weight": 0.80,
 "trust\_cap\_weight": 0.75,
 "cooldown\_mult": 1.15,
 },
 ARC\_DECLARE\_WAR: {
 # Déclaration de guerre = surtout un changement d'état + tension/weariness,
 # la relation ne doit pas faire un -60 d’un coup.
 "cap\_weight": 0.60,
 "trust\_cap\_weight": 0.60,
 "cooldown\_mult": 1.35,
 },
 ARC\_ALLIANCE\_OFFER: {
 # Alliance: confiance monte, relation suit mais reste capée
 "cap\_weight": 0.95,
 "trust\_cap\_weight": 1.15,
 "cooldown\_mult": 1.25,
 },
}

static func \_policy(action: StringName) -> Dictionary:
 return ARC\_TYPE\_POLICY.get(action, {"cap\_weight": 1.0, "trust\_cap\_weight": 1.0, "cooldown\_mult": 1.0})
```


---


## 2) Application “par événement” dans `apply_arc_resolution...`


Ici je te donne une version complète qui :


* applique scaling personnalité,
* applique cap relation/trust,
* applique cooldown * `cooldown_mult`,
* enregistre l’événement dans `ArcNotebook` (A et B).


```
static func apply\_arc\_resolution\_event(
 action: StringName,
 choice: StringName,
 giver\_id: StringName,
 ant\_id: StringName,
 rel\_ab: FactionRelationScore,
 rel\_ba: FactionRelationScore,
 profile\_a: FactionProfile,
 profile\_b: FactionProfile,
 arc\_notebook: ArcNotebook,
 current\_day: int,
 rng: RandomNumberGenerator,
 params: Dictionary = {}
) -> void:
 var d := get\_arc\_deltas(action, choice)
 if d.is\_empty():
 return

 # 1) scaling personnalité (déjà écrit chez toi)
 var ab\_scaled := \_scale\_deltas\_by\_personality(d["ab"], profile\_a, params)
 var ba\_scaled := \_scale\_deltas\_by\_personality(d["ba"], profile\_b, params)

# 2) cap% issu de l’historique (10%..30%) + policy de type

 var pol := \_policy(action)

 var hist\_a := arc\_notebook.get\_history(giver\_id)
 var hist\_b := arc\_notebook.get\_history(ant\_id)

 var base\_cap\_pct := compute\_relation\_cap\_pct\_from\_histories(
 hist\_a, hist\_b, giver\_id, ant\_id, action, current\_day, params
 )

# applique les weights du type (puis re-clamp dans [0.10..0.30] à la fin)

 var pct\_min := float(params.get("pct\_min", 0.10))
 var pct\_max := float(params.get("pct\_max", 0.30))

 var cap\_pct\_rel := clampf(base\_cap\_pct * float(pol["cap\_weight"]), pct\_min, pct\_max)
 var cap\_pct\_trust := clampf(base\_cap\_pct * float(pol["trust\_cap\_weight"]), pct\_min, pct\_max)

# 3) cap absolu (min 10 points, sinon % du score actuel)

 var min\_abs := int(params.get("min\_abs\_cap", 10))

 var cap\_ab\_rel := max(min\_abs, int(round(abs(rel\_ab.relation) * cap\_pct\_rel)))
 var cap\_ba\_rel := max(min\_abs, int(round(abs(rel\_ba.relation) * cap\_pct\_rel)))

 ab\_scaled["d\_relation"] = clampi(int(ab\_scaled["d\_relation"]), -cap\_ab\_rel, cap\_ab\_rel)
 ba\_scaled["d\_relation"] = clampi(int(ba\_scaled["d\_relation"]), -cap\_ba\_rel, cap\_ba\_rel)

# Trust cap (souvent utile)

 if bool(params.get("cap\_trust\_too", true)):
 var cap\_ab\_tr := max(min\_abs, int(round(abs(rel\_ab.trust) * cap\_pct\_trust)))
 var cap\_ba\_tr := max(min\_abs, int(round(abs(rel\_ba.trust) * cap\_pct\_trust)))
 ab\_scaled["d\_trust"] = clampi(int(ab\_scaled["d\_trust"]), -cap\_ab\_tr, cap\_ab\_tr)
 ba\_scaled["d\_trust"] = clampi(int(ba\_scaled["d\_trust"]), -cap\_ba\_tr, cap\_ba\_tr)

# 4) apply deltas

 rel\_ab.apply\_delta(int(ab\_scaled["d\_relation"]), int(ab\_scaled["d\_trust"]),
 float(ab\_scaled["d\_grievance"]), float(ab\_scaled["d\_tension"]), float(ab\_scaled["d\_weariness"]))
 rel\_ba.apply\_delta(int(ba\_scaled["d\_relation"]), int(ba\_scaled["d\_trust"]),
 float(ba\_scaled["d\_grievance"]), float(ba\_scaled["d\_tension"]), float(ba\_scaled["d\_weariness"]))

# 5) cooldown (base * multiplier)

 var cd\_base := cooldown\_days\_for(action, rng)
 var cd := int(round(float(cd\_base) * float(pol["cooldown\_mult"])))
 cd = max(1, cd)

 rel\_ab.set\_cooldown(current\_day, cd)
 rel\_ba.set\_cooldown(current\_day, cd)

# 6) register in notebook (metadata + (optionnel) record détaillé)

 hist\_a.register\_event(ant\_id, action, current\_day)
 hist\_b.register\_event(giver\_id, action, current\_day)

# Si tu veux aussi enregistrer la résolution dans l’historique détaillé :

 if hist\_a.has\_method("add\_rivalry\_record"):
 hist\_a.add\_rivalry\_record({"other": ant\_id, "type": action, "choice": choice, "day": current\_day})
 if hist\_b.has\_method("add\_rivalry\_record"):
 hist\_b.add\_rivalry\_record({"other": giver\_id, "type": action, "choice": choice, "day": current\_day})
```


---


## 3) Où ça se branche


Dans ton `ArcManager.on_quest_resolution_choice()` tu remplaces l’appel précédent par :


```
ArcEffectTable.apply\_arc\_resolution\_event(
 action, choice,
 giver\_id, ant\_id,
 rel\_ab, rel\_ba,
 profile\_a, profile\_b,
 arc\_notebook,
 WorldGameState.day,
 \_rng
)
```


---


### Petit conseil de tuning


* Si tu trouves que “on ne peut jamais se réconcilier”, augmente `cap_weight` sur `TRUCE_TALKS` / `REPARATIONS`.
* Si tu trouves que “ça tourne trop vite en guerre”, baisse `cap_weight` de `ULTIMATUM/RAID/SABOTAGE` ou augmente `cooldown_mult`.


Si tu veux, prochaine brique : appliquer aussi un **cap sur `tension`/`grievance` par événement** (souvent utile pour éviter des +40 tension sur un seul événement), mais sans les lier au % de relation.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 5](#toc-detail-ch5)
<a id="moi-22"></a>
**Moi 22:**
Ok, maintenant, je voudrais des tests pour ce qu'on a fait dans les Faction (personnalité et axe, je me souvient plus du nom de la classe)

On genere 100 profiles, on verifit les regles.

On garde aussi 10 profils bien differents pour les test ensuites


**ChatGPT:**
Voilà un **test harness Godot 4** (GDScript) pour `FactionProfile` (axes + personnalité) qui :


1) génère **100 profils** (pour chaque mode : centered/normal/dramatic),

2) **vérifie les règles** (axes + personnalité),

3) sélectionne et **sauvegarde 10 profils “bien différents”** dans `user://golden_faction_profiles.json` (réutilisables ensuite).


>
> Ta classe s’appelle **`FactionProfile`** (celle avec `generate_full_profile`, `axis_affinity`, `personality`).
>
>
>


---


## `TestFactionProfileGeneration.gd`


```
# Godot 4.x

# Attache ce script à un Node dans une scène "tests" et lance la scène.

extends Node
class\_name TestFactionProfileGeneration

const N\_PER\_MODE := 100
const GOLDEN\_COUNT := 10
const GOLDEN\_PATH := "user://golden\_faction\_profiles.json"

var rng := RandomNumberGenerator.new()

func \_ready() -> void:
 rng.seed = 1337 # reproductible

 \_run\_mode(FactionProfile.GEN\_CENTERED)
 \_run\_mode(FactionProfile.GEN\_NORMAL)
 \_run\_mode(FactionProfile.GEN\_DRAMATIC)

 print("\n✅ FactionProfile generation tests: OK\n")
 get\_tree().quit()


func \_run\_mode(mode: StringName) -> void:
 print("\n--- Testing mode: ", String(mode), " ---")

 var profiles: Array[FactionProfile] = []
 for i in range(N\_PER\_MODE):
 var p := FactionProfile.generate\_full\_profile(rng, mode)
 \_validate\_profile(p, mode, i)
 profiles.append(p)

# Golden profiles (diversité) — on les garde une fois (normal) ou par mode (au choix).

 # Ici: on sauvegarde un set global à partir du mode NORMAL (souvent le plus stable pour fixtures).
 if mode == FactionProfile.GEN\_NORMAL:
 var golden := \_pick\_diverse\_profiles(profiles, GOLDEN\_COUNT)
 \_save\_golden(golden, mode)


func \_validate\_profile(p: FactionProfile, mode: StringName, idx: int) -> void:
 \_assert(p != null, "Profile is null (idx=%d, mode=%s)" % [idx, mode])

 \_validate\_axes(p.axis\_affinity, mode, idx)
 \_validate\_personality(p.personality, mode, idx)


func \_validate\_axes(axis: Dictionary, mode: StringName, idx: int) -> void:
 # 5 axes présents, bornes, règles (pos>50, neg<-20), somme, distribution intéressante
 for a in FactionProfile.ALL\_AXES:
 \_assert(axis.has(a), "Missing axis '%s' (idx=%d, mode=%s)" % [a, idx, mode])
 var v := int(axis[a])
 \_assert(v >= -100 and v <= 100, "Axis out of range %s=%d (idx=%d, mode=%s)" % [a, v, idx, mode])

 var has\_pos := false
 var has\_neg := false
 var sum := 0
 var interesting := 0

 var interesting\_abs := 12
 var min\_interesting := 3
 var sum\_min := 20
 var sum\_max := 90

 match mode:
 FactionProfile.GEN\_CENTERED:
 interesting\_abs = 10
 min\_interesting = 4
 sum\_min = 20
 sum\_max = 75
 FactionProfile.GEN\_DRAMATIC:
 interesting\_abs = 15
 min\_interesting = 3
 sum\_min = 20
 sum\_max = 90
 \_:
 # normal
 interesting\_abs = 12
 min\_interesting = 3
 sum\_min = 20
 sum\_max = 90

 for a in FactionProfile.ALL\_AXES:
 var v := int(axis[a])
 sum += v
 if v > 50:
 has\_pos = true
 if v < -20:
 has\_neg = true
 if abs(v) >= interesting\_abs:
 interesting += 1

 \_assert(has\_pos, "No axis > 50 (idx=%d, mode=%s) axis=%s" % [idx, mode, str(axis)])
 \_assert(has\_neg, "No axis < -20 (idx=%d, mode=%s) axis=%s" % [idx, mode, str(axis)])
 \_assert(sum >= sum\_min and sum <= sum\_max,
 "Axis sum out of range sum=%d expected=[%d..%d] (idx=%d, mode=%s) axis=%s"
 % [sum, sum\_min, sum\_max, idx, mode, str(axis)])
 \_assert(interesting >= min\_interesting,
 "Axis distribution too flat interesting=%d (<%d), abs>=%d (idx=%d, mode=%s) axis=%s"
 % [interesting, min\_interesting, interesting\_abs, idx, mode, str(axis)])


func \_validate\_personality(per: Dictionary, mode: StringName, idx: int) -> void:
 # clés, bornes 0..1, + “interestingness” (au moins un high et un low)
 var require\_high := 0.75
 var require\_low := 0.35
 match mode:
 FactionProfile.GEN\_CENTERED:
 require\_high = 0.70
 require\_low = 0.40
 FactionProfile.GEN\_DRAMATIC:
 require\_high = 0.80
 require\_low = 0.30
 \_:
 require\_high = 0.75
 require\_low = 0.35

 var hi := 0
 var lo := 0

 for k in FactionProfile.ALL\_PERSONALITY\_KEYS:
 \_assert(per.has(k), "Missing personality key '%s' (idx=%d, mode=%s)" % [k, idx, mode])
 var v := float(per[k])
 \_assert(v >= 0.0 and v <= 1.0, "Personality out of range %s=%f (idx=%d, mode=%s)" % [k, v, idx, mode])
 if v >= require\_high:
 hi += 1
 if v <= require\_low:
 lo += 1

 \_assert(hi >= 1, "Personality not distinctive: no trait >= %.2f (idx=%d, mode=%s) per=%s" % [require\_high, idx, mode, str(per)])
 \_assert(lo >= 1, "Personality not distinctive: no trait <= %.2f (idx=%d, mode=%s) per=%s" % [require\_low, idx, mode, str(per)])

# -----------------------

# Golden profiles (diversité)

# -----------------------

func \_pick\_diverse\_profiles(profiles: Array, k: int) -> Array:
 if profiles.is\_empty():
 return []

 # Greedy farthest-point sampling
 var chosen: Array = []
 chosen.append(profiles[rng.randi\_range(0, profiles.size() - 1)])

 while chosen.size() < k and chosen.size() < profiles.size():
 var best\_p: FactionProfile = null
 var best\_score := -INF

 for p in profiles:
 if chosen.has(p):
 continue
 var min\_d := INF
 for c in chosen:
 min\_d = min(min\_d, \_profile\_distance(p, c))
 if min\_d > best\_score:
 best\_score = min\_d
 best\_p = p

 if best\_p == null:
 break
 chosen.append(best\_p)

 return chosen


func \_profile\_distance(a: FactionProfile, b: FactionProfile) -> float:
 # Axes: [-1..1], Personality: centered around 0.5 then scaled
 var s := 0.0

 for ax in FactionProfile.ALL\_AXES:
 var da := float(a.axis\_affinity[ax]) / 100.0
 var db := float(b.axis\_affinity[ax]) / 100.0
 var d := da - db
 s += 1.0 * d * d

 for k in FactionProfile.ALL\_PERSONALITY\_KEYS:
 var pa := (float(a.personality[k]) - 0.5) * 2.0 # [-1..1]
 var pb := (float(b.personality[k]) - 0.5) * 2.0
 var d2 := pa - pb
 s += 0.6 * d2 * d2

 return sqrt(s)


func \_save\_golden(golden: Array, mode: StringName) -> void:
 var arr := []
 for p in golden:
 arr.append(\_to\_json\_dict(p))

 var payload := {
 "seed": 1337,
 "mode": String(mode),
 "generated\_at\_day": 0,
 "profiles": arr
 }

 var json := JSON.stringify(payload, "\t")
 var f := FileAccess.open(GOLDEN\_PATH, FileAccess.WRITE)
 \_assert(f != null, "Cannot open %s for writing" % GOLDEN\_PATH)
 f.store\_string(json)
 f.close()

 print("\n⭐ Saved ", golden.size(), " golden profiles to: ", GOLDEN\_PATH)
 print(" (Tu peux les recharger ensuite pour tes tests de quêtes/arcs.)")


func \_to\_json\_dict(p: FactionProfile) -> Dictionary:
 var axis := {}
 for ax in FactionProfile.ALL\_AXES:
 axis[String(ax)] = int(p.axis\_affinity[ax])

 var per := {}
 for k in FactionProfile.ALL\_PERSONALITY\_KEYS:
 per[String(k)] = float(p.personality[k])

 return {"axis\_affinity": axis, "personality": per}


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


## Comment tu l’utilises


1) Crée une scène `Tests.tscn` avec un `Node`.

2) Attache `TestFactionProfileGeneration.gd` au node.

3) Lance la scène :


* si un test échoue → `assert(false)` + erreur explicite
* sinon → écrit `user://golden_faction_profiles.json`


---


## Les 10 profils “bien différents”


Ils sont choisis par **farthest-point sampling** (greedy), donc vraiment écartés (axes + personnalité).

Tu peux ensuite les recharger pour des tests déterministes de ton ArcManager/QuestGenerator.


Si tu veux, je te donne aussi un petit helper `load_golden_profiles()` qui relit ce JSON et reconstruit des `FactionProfile` (pratique pour tes futurs tests).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 6](#toc-detail-ch6)
<a id="moi-23"></a>
**Moi 23:**
L'idée, maintenant on va generer les relations de depart entre les factions dans un deuxieme tests


**ChatGPT:**
OK — voici un **2ᵉ test harness** qui :


* charge tes **10 “golden profiles”** (ceux générés au test précédent),
* crée un mini-monde de **10 factions**,
* génère les **relations de départ** via `FactionRelationsUtil.initialize_relations_world()`,
* vérifie des **invariants** (structure, bornes, présence d’alliés/ennemis, moyenne centrée, réciprocité “70% mais pas identique”).


## `TestFactionWorldRelations.gd`


```
# Godot 4.x

# Scène de test: un Node avec ce script attaché.

extends Node
class\_name TestFactionWorldRelations

const GOLDEN\_PATH := "user://golden\_faction\_profiles.json"

var rng := RandomNumberGenerator.new()

func \_ready() -> void:
 rng.seed = 424242 # reproductible

 # 1) Charger 10 profils différents (golden) ou fallback
 var profiles\_list := \_load\_golden\_profiles()
 \_assert(profiles\_list.size() >= 2, "Need at least 2 profiles to test relations")

# 2) Construire un set de factions (ids + profile)

 var faction\_profiles: Dictionary[StringName, FactionProfile] = {}
 for i in range(min(10, profiles\_list.size())):
 var id := StringName("faction\_%02d" % i)
 faction\_profiles[id] = profiles\_list[i]

 # 3) Générer le monde des relations
 var world\_rel := FactionRelationsUtil.initialize\_relations\_world(
 faction\_profiles,
 rng,
 {
 "apply\_reciprocity": true,
 "reciprocity\_strength": 0.70,
 "keep\_asymmetry": 0.30,
 "reciprocity\_noise": 2,
 "max\_change\_per\_pair": 18,
 "final\_global\_sanity": true,
 "max\_extremes\_per\_faction": 2
 },
 {
 # per-faction params (init directionnel)
 "desired\_mean": 0.0,
 "desired\_std": 22.0,
 "enemy\_min": 1, "enemy\_max": 2,
 "ally\_min": 1, "ally\_max": 2,
 "noise": 3,
 "tension\_cap": 40.0,
 "final\_recenter": true
 },
 {
 # baseline relation tuning forwarded to compute\_baseline\_relation()
 "w\_axis\_similarity": 80.0,
 "w\_cross\_conflict": 55.0,
 "tension\_cap": 40.0
 }
 )

# 4) Vérifs

 \_validate\_world\_relations(faction\_profiles, world\_rel)

 print("\n✅ World relations initialization tests: OK\n")
 get\_tree().quit()

# -------------------------

# Validation

# -------------------------

func \_validate\_world\_relations(faction\_profiles: Dictionary, world\_rel: Dictionary) -> void:
 var ids: Array[StringName] = []
 for fid in faction\_profiles.keys():
 ids.append(StringName(fid))

# Structure: world\_rel[A][B] existe pour tous A!=B

 for a in ids:
 \_assert(world\_rel.has(a), "Missing relations map for %s" % a)
 var map\_a: Dictionary = world\_rel[a]
 for b in ids:
 if b == a:
 \_assert(not map\_a.has(b), "Self relation should not exist: %s->%s" % [a, b])
 continue
 \_assert(map\_a.has(b), "Missing relation score: %s->%s" % [a, b])
 \_validate\_score\_bounds(a, b, map\_a[b])

# Qualité globale: moyenne centrée + variance raisonnable + allies/enemies

 \_validate\_centering\_and\_spread(ids, world\_rel)
 \_validate\_allies\_enemies(ids, world\_rel)
 \_validate\_reciprocity(ids, world\_rel)


func \_validate\_score\_bounds(a: StringName, b: StringName, rs) -> void:
 # rs est un FactionRelationScore
 \_assert(rs != null, "Null score for %s->%s" % [a, b])

 \_assert(rs.relation >= -100 and rs.relation <= 100, "relation out of range %s->%s = %d" % [a, b, rs.relation])
 \_assert(rs.trust >= -100 and rs.trust <= 100, "trust out of range %s->%s = %d" % [a, b, rs.trust])
 \_assert(rs.tension >= 0.0 and rs.tension <= 100.0, "tension out of range %s->%s = %f" % [a, b, rs.tension])

# friction optionnel mais fortement recommandé

 if "friction" in rs:
 \_assert(rs.friction >= 0.0 and rs.friction <= 100.0, "friction out of range %s->%s = %f" % [a, b, rs.friction])
 \_assert(rs.grievance >= 0.0 and rs.grievance <= 100.0, "grievance out of range %s->%s = %f" % [a, b, rs.grievance])
 \_assert(rs.weariness >= 0.0 and rs.weariness <= 100.0, "weariness out of range %s->%s = %f" % [a, b, rs.weariness])


func \_validate\_centering\_and\_spread(ids: Array[StringName], world\_rel: Dictionary) -> void:
 # global mean / std
 var all\_vals: Array[float] = []
 for a in ids:
 var map\_a: Dictionary = world\_rel[a]
 for b in map\_a.keys():
 all\_vals.append(float(map\_a[b].relation))

 var mean := \_mean(all\_vals)
 var std := \_std(all\_vals, mean)

 \_assert(abs(mean) <= 6.0, "Global mean too far from 0: mean=%f" % mean)
 \_assert(std >= 12.0 and std <= 35.0, "Global std unexpected: std=%f (expect ~[12..35])" % std)

# per-faction mean not too extreme (cohérence globale)

 for a in ids:
 var vals: Array[float] = []
 var map\_a: Dictionary = world\_rel[a]
 for b in map\_a.keys():
 vals.append(float(map\_a[b].relation))
 var m := \_mean(vals)
 \_assert(abs(m) <= 20.0, "Faction %s mean too extreme: %f" % [a, m])


func \_validate\_allies\_enemies(ids: Array[StringName], world\_rel: Dictionary) -> void:
 # On veut "quelques ennemis naturels, quelques alliés naturels"
 # Avec ally/enemy min/max, la plupart des factions devraient en avoir.
 var need\_ratio := 0.70 # au moins 70% des factions

 var with\_ally := 0
 var with\_enemy := 0

 for a in ids:
 var map\_a: Dictionary = world\_rel[a]
 var has\_ally := false
 var has\_enemy := false
 for b in map\_a.keys():
 var r := int(map\_a[b].relation)
 if r >= 30:
 has\_ally = true
 if r <= -30:
 has\_enemy = true
 if has\_ally: with\_ally += 1
 if has\_enemy: with\_enemy += 1

 \_assert(float(with\_ally) / float(ids.size()) >= need\_ratio,
 "Not enough factions with an ally (>=30): %d/%d" % [with\_ally, ids.size()])
 \_assert(float(with\_enemy) / float(ids.size()) >= need\_ratio,
 "Not enough factions with an enemy (<=-30): %d/%d" % [with\_enemy, ids.size()])


func \_validate\_reciprocity(ids: Array[StringName], world\_rel: Dictionary) -> void:
 # Réciprocité légère: AB et BA convergent, mais restent différents.
 var diffs: Array[float] = []
 var ab\_vals: Array[float] = []
 var ba\_vals: Array[float] = []

 for i in range(ids.size()):
 for j in range(i + 1, ids.size()):
 var a := ids[i]
 var b := ids[j]
 var ab := float(world\_rel[a][b].relation)
 var ba := float(world\_rel[b][a].relation)
 ab\_vals.append(ab)
 ba\_vals.append(ba)
 diffs.append(abs(ab - ba))

 var mean\_diff := \_mean(diffs)

# Trop bas => presque symétrique (pas voulu), trop haut => pas de convergence

 \_assert(mean\_diff >= 4.0 and mean\_diff <= 35.0, "Reciprocity diff mean unexpected: %f" % mean\_diff)

# Corrélation positive: si AB déteste, BA tend aussi à détester

 var corr := \_pearson(ab\_vals, ba\_vals)
 \_assert(corr >= 0.55, "Reciprocity correlation too low: %f" % corr)

# -------------------------

# Golden load / fallback

# -------------------------

func \_load\_golden\_profiles() -> Array[FactionProfile]:
 if not FileAccess.file\_exists(GOLDEN\_PATH):
 push\_warning("Golden profiles not found at %s, generating 10 fallback profiles." % GOLDEN\_PATH)
 return \_generate\_fallback\_profiles(10)

 var f := FileAccess.open(GOLDEN\_PATH, FileAccess.READ)
 \_assert(f != null, "Cannot open %s" % GOLDEN\_PATH)
 var txt := f.get\_as\_text()
 f.close()

 var json := JSON.new()
 var err := json.parse(txt)
 \_assert(err == OK, "JSON parse failed in %s" % GOLDEN\_PATH)
 var root: Dictionary = json.data

 var arr: Array = root.get("profiles", [])
 \_assert(arr.size() > 0, "Golden file has no profiles")

 var out: Array[FactionProfile] = []
 for item in arr:
 out.append(\_profile\_from\_json\_dict(item))
 return out


func \_profile\_from\_json\_dict(d: Dictionary) -> FactionProfile:
 var p := FactionProfile.new()

 var axis\_in: Dictionary = d.get("axis\_affinity", {})
 var per\_in: Dictionary = d.get("personality", {})

 p.axis\_affinity = {}
 for ax in FactionProfile.ALL\_AXES:
 p.axis\_affinity[ax] = int(axis\_in.get(String(ax), 0))

 p.personality = {}
 for k in FactionProfile.ALL\_PERSONALITY\_KEYS:
 p.personality[k] = float(per\_in.get(String(k), 0.5))

 return p


func \_generate\_fallback\_profiles(n: int) -> Array[FactionProfile]:
 var out: Array[FactionProfile] = []
 for \_i in range(n):
 out.append(FactionProfile.generate\_full\_profile(rng, FactionProfile.GEN\_NORMAL))
 return out


# -------------------------

# Math helpers

# -------------------------

func \_mean(arr: Array[float]) -> float:
 if arr.is\_empty():
 return 0.0
 var s := 0.0
 for v in arr:
 s += v
 return s / float(arr.size())

func \_std(arr: Array[float], mean: float) -> float:
 if arr.size() <= 1:
 return 0.0
 var s := 0.0
 for v in arr:
 var d := v - mean
 s += d * d
 return sqrt(s / float(arr.size()))

func \_pearson(x: Array[float], y: Array[float]) -> float:
 if x.size() != y.size() or x.is\_empty():
 return 0.0
 var mx := \_mean(x)
 var my := \_mean(y)
 var num := 0.0
 var dx := 0.0
 var dy := 0.0
 for i in range(x.size()):
 var a := x[i] - mx
 var b := y[i] - my
 num += a * b
 dx += a * a
 dy += b * b
 if dx <= 0.000001 or dy <= 0.000001:
 return 0.0
 return num / sqrt(dx * dy)


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


### Ce que ce test garantit


* tu as bien **un dictionnaire complet A→(tous les autres)**,
* les valeurs restent **dans les bornes**,
* tu as bien “**quelques ennemis/alliés**” (cohérence globale),
* la **moyenne** des relations est **centrée**,
* la **réciprocité légère** fonctionne : **corrélation élevée**, mais **différences non nulles**.


Si tu veux, prochaine étape : un 3ᵉ test qui simule **30 jours** en appelant `compute_arc_event_chance` et `select_arc_action_type`, puis vérifie qu’on ne tombe pas dans une boucle d’escalade systématique (distribution des actions + tendance tension/weariness).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 6](#toc-detail-ch6)
<a id="moi-24"></a>
**Moi 24:**
Exactement ce que je voulais


**ChatGPT:**
L'utilisateur veut des tests Godot pour générer 100 FactionProfile (axes+personnalité) en vérifiant les règles, conserver 10 profils “golden”, puis un second test pour initialiser les relations de départ entre factions à partir de ces profils avec invariants (moyenne centrée, alliés/ennemis, réciprocité légère).


**ChatGPT:**
Super — on a donc :


* **Test 1** : génération `FactionProfile` (100 profils / mode) + vérifs + sauvegarde de **10 golden**.
* **Test 2** : chargement des golden + `initialize_relations_world()` + invariants (bornes, moyenne, spread, alliés/ennemis, réciprocité légère).


Quand tu voudras, on peut enchaîner avec le **Test 3** (simulation multi-jours + stats sur incidents / escalade) pour valider que la boucle vengeance n’est plus automatique.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 6](#toc-detail-ch6)
<a id="moi-25"></a>
**Moi 25:**
On enchaine avec le test 3, le nombre de jour est parametrable (on le recoit en entrée de la fonction de tests)


**ChatGPT:**
OK — voici un **Test 3** Godot (GDScript) qui simule un monde “arc-driven” sur **N jours paramétrables**.


* Il charge les **10 golden profiles** (ou fallback),
* initialise `initialize_relations_world()`,
* puis chaque jour :
	+ applique une **décroissance passive** (tension/grievance/weariness) dépendante de la personnalité,
	+ calcule `compute_arc_event_chance(A→B)` sur toutes les paires directionnelles,
	+ déclenche au plus `max_events_per_day` événements (les plus probables),
	+ choisit `arc_action_type` + un **choix simulé** (LOYAL/NEUTRAL/TRAITOR),
	+ applique `ArcEffectTable.apply_arc_resolution_event(...)` (donc cooldown + notebook + caps si tu l’as branché).


Enfin il valide des **invariants anti-escalade** et imprime un résumé.


---


## `TestArcSimulation.gd`


```
# Godot 4.x

extends Node
class\_name TestArcSimulation

const GOLDEN\_PATH := "user://golden\_faction\_profiles.json"

@export var days\_to\_simulate: int = 30
@export var max\_events\_per\_day: int = 6

var rng := RandomNumberGenerator.new()

# --- Action buckets (pour stats + invariants) ---

const PEACE\_ACTIONS := [
 ArcDecisionUtil.ARC\_TRUCE\_TALKS,
 ArcDecisionUtil.ARC\_REPARATIONS,
 ArcDecisionUtil.ARC\_ALLIANCE\_OFFER,
]

const HOSTILE\_ACTIONS := [
 ArcDecisionUtil.ARC\_RAID,
 ArcDecisionUtil.ARC\_SABOTAGE,
 ArcDecisionUtil.ARC\_DECLARE\_WAR,
 ArcDecisionUtil.ARC\_ULTIMATUM,
]

func \_ready() -> void:
 rng.seed = 777777

 run(days\_to\_simulate)
 print("\n✅ Arc simulation test: OK\n")
 get\_tree().quit()

# Appelable depuis ailleurs (le nombre de jours est le param)

func run(days: int) -> void:
 \_assert(days > 0, "days must be > 0")

# 1) Charger profils golden (10) + construire factions

 var profiles\_list := \_load\_golden\_profiles()
 \_assert(profiles\_list.size() >= 6, "Need at least 6 profiles for a meaningful arc sim")

 var faction\_profiles: Dictionary[StringName, FactionProfile] = {}
 for i in range(min(10, profiles\_list.size())):
 faction\_profiles[StringName("faction\_%02d" % i)] = profiles\_list[i]

 var ids: Array[StringName] = []
 for fid in faction\_profiles.keys():
 ids.append(StringName(fid))

# 2) Init relations world

 var world\_rel := FactionRelationsUtil.initialize\_relations\_world(
 faction\_profiles,
 rng,
 {
 "apply\_reciprocity": true,
 "reciprocity\_strength": 0.70,
 "keep\_asymmetry": 0.30,
 "reciprocity\_noise": 2,
 "max\_change\_per\_pair": 18,
 "final\_global\_sanity": true,
 "max\_extremes\_per\_faction": 2
 },
 {
 "desired\_mean": 0.0,
 "desired\_std": 22.0,
 "enemy\_min": 1, "enemy\_max": 2,
 "ally\_min": 1, "ally\_max": 2,
 "noise": 3,
 "tension\_cap": 40.0,
 "final\_recenter": true
 },
 {
 "w\_axis\_similarity": 80.0,
 "w\_cross\_conflict": 55.0,
 "tension\_cap": 40.0
 }
 )

# 3) Notebook (historique arcs) — ton ArcNotebook par faction

 var arc\_notebook := ArcNotebook.new()

# 4) Stats time-series + compteurs

 var stats := {
 "events\_total": 0,
 "by\_action": {},
 "by\_choice": {},
 "declare\_war": 0,
 "peace\_events": 0,
 "hostile\_events": 0,
 "avg\_tension\_series": [],
 "avg\_relation\_series": [],
 "avg\_weariness\_series": [],
 }

 var snap0 := \_snapshot\_metrics(ids, world\_rel)
 stats["avg\_tension\_series"].append(snap0["avg\_tension"])
 stats["avg\_relation\_series"].append(snap0["avg\_relation"])
 stats["avg\_weariness\_series"].append(snap0["avg\_weariness"])

# 5) Simulation days

 for day in range(1, days + 1):
 # a) cooling passif (important pour casser l’escalade “auto”)
 \_daily\_decay(ids, world\_rel, faction\_profiles)

# b) collect candidates (A->B directionnel)

 var candidates: Array = []
 for a\_id in ids:
 var map\_a: Dictionary = world\_rel[a\_id]
 for b\_id in map\_a.keys():
 if b\_id == a\_id:
 continue
 var rel\_ab: FactionRelationScore = map\_a[b\_id]

 var p := ArcDecisionUtil.compute\_arc\_event\_chance(
 rel\_ab,
 faction\_profiles[a\_id],
 faction\_profiles[b\_id],
 day,
 {"max\_p": 0.35}
 )
 if p <= 0.0:
 continue
 # tirage “pré-sélection”
 if rng.randf() < p:
 candidates.append({"a": a\_id, "b": b\_id, "p": p})

# c) limiter le budget d'events / jour (sinon n^2 explose la simulation)

 candidates.sort\_custom(func(x, y): return float(x["p"]) > float(y["p"]))
 var take := min(max\_events\_per\_day, candidates.size())

 for i in range(take):
 var c := candidates[i]
 var a\_id: StringName = c["a"]
 var b\_id: StringName = c["b"]

 var rel\_ab: FactionRelationScore = world\_rel[a\_id][b\_id]
 var rel\_ba: FactionRelationScore = world\_rel[b\_id][a\_id]

 # d) action selection
 var action := ArcDecisionUtil.select\_arc\_action\_type(
 rel\_ab,
 faction\_profiles[a\_id],
 faction\_profiles[b\_id],
 rng,
 day,
 {
 "external\_threat": 0.15,
 "opportunity": \_compute\_opportunity(rel\_ab, faction\_profiles[a\_id]),
 "temperature": 0.18
 }
 )

 if action == ArcDecisionUtil.ARC\_IGNORE:
 continue

 # e) choix simulé (LOYAL/NEUTRAL/TRAITOR)
 var choice := \_resolve\_choice(action, rel\_ab)

# f) appliquer l’événement (deltas + cooldown + notebook)

 ArcEffectTable.apply\_arc\_resolution\_event(
 action,
 choice,
 a\_id,
 b\_id,
 rel\_ab,
 rel\_ba,
 faction\_profiles[a\_id],
 faction\_profiles[b\_id],
 arc\_notebook,
 day,
 rng
 )

# g) stats

 \_stats\_add(stats, action, choice)

# h) snapshot

 var snap := \_snapshot\_metrics(ids, world\_rel)
 stats["avg\_tension\_series"].append(snap["avg\_tension"])
 stats["avg\_relation\_series"].append(snap["avg\_relation"])
 stats["avg\_weariness\_series"].append(snap["avg\_weariness"])

# 6) Invariants anti-escalade + résumé

 \_print\_summary(stats, days)
 \_validate\_invariants(stats, ids, world\_rel, days)

# -----------------------------

# Decay passif (journalier)

# -----------------------------

func \_daily\_decay(ids: Array[StringName], world\_rel: Dictionary, faction\_profiles: Dictionary) -> void:
 # Ajuste ces bases si tu veux un monde plus/moins inflammable
 var base\_tension\_decay := 0.9
 var base\_griev\_decay := 0.6
 var base\_wear\_decay := 0.35

 for a\_id in ids:
 var prof: FactionProfile = faction\_profiles[a\_id]
 var diplo := prof.get\_personality(FactionProfile.PERS\_DIPLOMACY, 0.5)
 var veng := prof.get\_personality(FactionProfile.PERS\_VENGEFULNESS, 0.5)

 var tension\_mul := 0.70 + 0.80 * diplo # diplomate => tension redescend plus vite
 var griev\_mul := 0.55 + 0.90 * (1.0 - veng)

# vindicatif => grievance redescend moins vite

 var map\_a: Dictionary = world\_rel[a\_id]
 for b\_id in map\_a.keys():
 var rs: FactionRelationScore = map\_a[b\_id]
 rs.tension = max(0.0, rs.tension - base\_tension\_decay * tension\_mul)
 rs.grievance = max(0.0, rs.grievance - base\_griev\_decay * griev\_mul)
 rs.weariness = max(0.0, rs.weariness - base\_wear\_decay)
 rs.clamp\_all()

# -----------------------------

# Choix simulé (auto-résolution)

# -----------------------------

func \_resolve\_choice(action: StringName, rel\_ab: FactionRelationScore) -> StringName:
 # Heuristique: plus tension/grievance sont hauts, plus c’est “LOYAL” côté acteur A (ça passe en force).
 var t := rel\_ab.tension / 100.0
 var g := rel\_ab.grievance / 100.0
 var bias := clampf(0.45 + 0.25*t + 0.20*g, 0.35, 0.75)

 var p\_loyal := bias
 var p\_neutral := 0.30
 var p\_traitor := 1.0 - (p\_loyal + p\_neutral)
 p\_traitor = clampf(p\_traitor, 0.05, 0.25)

# Ajustement selon type (paix : loyal plus probable, guerre : neutral un peu plus probable)

 if PEACE\_ACTIONS.has(action):
 p\_loyal = clampf(p\_loyal + 0.10, 0.45, 0.85)
 p\_neutral = 0.25
 p\_traitor = 1.0 - (p\_loyal + p\_neutral)
 elif action == ArcDecisionUtil.ARC\_DECLARE\_WAR:
 p\_neutral = 0.35
 p\_loyal = clampf(p\_loyal, 0.40, 0.70)
 p\_traitor = 1.0 - (p\_loyal + p\_neutral)

 var r := rng.randf()
 if r < p\_loyal:
 return ArcEffectTable.CHOICE\_LOYAL
 if r < p\_loyal + p\_neutral:
 return ArcEffectTable.CHOICE\_NEUTRAL
 return ArcEffectTable.CHOICE\_TRAITOR


func \_compute\_opportunity(rel\_ab: FactionRelationScore, a\_prof: FactionProfile) -> float:
 # Rough: expansionism aide, weariness pénalise
 var expa := a\_prof.get\_personality(FactionProfile.PERS\_EXPANSIONISM, 0.5)
 var w := rel\_ab.weariness / 100.0
 return clampf(0.45 + 0.35*(expa - 0.5) - 0.40*w, 0.05, 0.95)

# -----------------------------

# Stats & invariants

# -----------------------------

func \_stats\_add(stats: Dictionary, action: StringName, choice: StringName) -> void:
 stats["events\_total"] = int(stats["events\_total"]) + 1

 var by\_action: Dictionary = stats["by\_action"]
 by\_action[action] = int(by\_action.get(action, 0)) + 1
 stats["by\_action"] = by\_action

 var by\_choice: Dictionary = stats["by\_choice"]
 by\_choice[choice] = int(by\_choice.get(choice, 0)) + 1
 stats["by\_choice"] = by\_choice

 if action == ArcDecisionUtil.ARC\_DECLARE\_WAR:
 stats["declare\_war"] = int(stats["declare\_war"]) + 1

 if PEACE\_ACTIONS.has(action):
 stats["peace\_events"] = int(stats["peace\_events"]) + 1
 if HOSTILE\_ACTIONS.has(action):
 stats["hostile\_events"] = int(stats["hostile\_events"]) + 1


func \_snapshot\_metrics(ids: Array[StringName], world\_rel: Dictionary) -> Dictionary:
 var rels: Array[float] = []
 var tens: Array[float] = []
 var wears: Array[float] = []

 for a\_id in ids:
 var map\_a: Dictionary = world\_rel[a\_id]
 for b\_id in map\_a.keys():
 var rs: FactionRelationScore = map\_a[b\_id]
 rels.append(float(rs.relation))
 tens.append(float(rs.tension))
 wears.append(float(rs.weariness))

 return {
 "avg\_relation": \_mean(rels),
 "avg\_tension": \_mean(tens),
 "avg\_weariness": \_mean(wears),
 }


func \_validate\_invariants(stats: Dictionary, ids: Array[StringName], world\_rel: Dictionary, days: int) -> void:
 var events\_total := int(stats["events\_total"])
 \_assert(events\_total >= min(5, days), "Too few events produced: %d over %d days" % [events\_total, days])

# Pas de “guerre partout”

 var max\_wars := max(1, int(floor(float(days) / 20.0)) + 1)

# ex: 30j => <=2

 \_assert(int(stats["declare\_war"]) <= max\_wars,
 "Too many war declarations: %d (max %d for %d days)" % [int(stats["declare\_war"]), max\_wars, days])

# Si on a pas mal d'hostilité, on doit voir au moins un peu de dé-escalade

 var hostile := int(stats["hostile\_events"])
 var peace := int(stats["peace\_events"])
 if hostile >= 8:
 \_assert(peace >= 1, "Hostile events=%d but no peace/de-escalation event occurred" % hostile)

# Tension globale ne doit pas “exploser”

 var t\_series: Array = stats["avg\_tension\_series"]
 var t0 := float(t\_series[0])
 var t\_end := float(t\_series[t\_series.size() - 1])
 \_assert(t\_end <= 70.0, "Final avg tension too high: %f" % t\_end)
 \_assert(t\_end <= t0 + 35.0, "Avg tension increased too much: %f -> %f" % [t0, t\_end])

# Un petit nombre de paires “ultra chaudes” max

 var hot\_pairs := \_count\_hot\_pairs(ids, world\_rel)
 \_assert(hot\_pairs <= 3, "Too many hot pairs (tension>=80 and mean relation<=-70): %d" % hot\_pairs)


func \_count\_hot\_pairs(ids: Array[StringName], world\_rel: Dictionary) -> int:
 var c := 0
 for i in range(ids.size()):
 for j in range(i + 1, ids.size()):
 var a := ids[i]
 var b := ids[j]
 var ab: FactionRelationScore = world\_rel[a][b]
 var ba: FactionRelationScore = world\_rel[b][a]
 var mean\_rel := 0.5 * (float(ab.relation) + float(ba.relation))
 var mean\_t := 0.5 * (ab.tension + ba.tension)
 if mean\_t >= 80.0 and mean\_rel <= -70.0:
 c += 1
 return c


func \_print\_summary(stats: Dictionary, days: int) -> void:
 print("\n--- Arc Simulation Summary (", days, " days) ---")
 print("Events total: ", stats["events\_total"])
 print("Hostile: ", stats["hostile\_events"], " | Peace: ", stats["peace\_events"], " | War declares: ", stats["declare\_war"])
 print("By choice: ", stats["by\_choice"])
 print("By action: ", stats["by\_action"])

 var ts: Array = stats["avg\_tension\_series"]
 var ws: Array = stats["avg\_weariness\_series"]
 var rs: Array = stats["avg\_relation\_series"]
 print("Avg tension: ", ts[0], " -> ", ts[ts.size() - 1])
 print("Avg weariness: ", ws[0], " -> ", ws[ws.size() - 1])
 print("Avg relation: ", rs[0], " -> ", rs[rs.size() - 1])

# -----------------------------

# Golden load / fallback

# -----------------------------

func \_load\_golden\_profiles() -> Array[FactionProfile]:
 if not FileAccess.file\_exists(GOLDEN\_PATH):
 push\_warning("Golden profiles not found at %s, generating 10 fallback profiles." % GOLDEN\_PATH)
 return \_generate\_fallback\_profiles(10)

 var f := FileAccess.open(GOLDEN\_PATH, FileAccess.READ)
 \_assert(f != null, "Cannot open %s" % GOLDEN\_PATH)
 var txt := f.get\_as\_text()
 f.close()

 var json := JSON.new()
 var err := json.parse(txt)
 \_assert(err == OK, "JSON parse failed in %s" % GOLDEN\_PATH)
 var root: Dictionary = json.data

 var arr: Array = root.get("profiles", [])
 \_assert(arr.size() > 0, "Golden file has no profiles")

 var out: Array[FactionProfile] = []
 for item in arr:
 out.append(\_profile\_from\_json\_dict(item))
 return out


func \_profile\_from\_json\_dict(d: Dictionary) -> FactionProfile:
 var p := FactionProfile.new()

 var axis\_in: Dictionary = d.get("axis\_affinity", {})
 var per\_in: Dictionary = d.get("personality", {})

 p.axis\_affinity = {}
 for ax in FactionProfile.ALL\_AXES:
 p.axis\_affinity[ax] = int(axis\_in.get(String(ax), 0))

 p.personality = {}
 for k in FactionProfile.ALL\_PERSONALITY\_KEYS:
 p.personality[k] = float(per\_in.get(String(k), 0.5))

 return p


func \_generate\_fallback\_profiles(n: int) -> Array[FactionProfile]:
 var out: Array[FactionProfile] = []
 for \_i in range(n):
 out.append(FactionProfile.generate\_full\_profile(rng, FactionProfile.GEN\_NORMAL))
 return out


# -----------------------------

# Math + assert

# -----------------------------

func \_mean(arr: Array[float]) -> float:
 if arr.is\_empty():
 return 0.0
 var s := 0.0
 for v in arr:
 s += v
 return s / float(arr.size())

func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


### Comment régler le nombre de jours


* Dans l’inspecteur : `days_to_simulate`
* Ou par code : `run(120)` (par exemple)
* Tu peux aussi exposer `max_events_per_day` pour contrôler la “densité” d’événements.


---


### À adapter chez toi (2 points)


1) **`ArcEffectTable.apply_arc_resolution_event(...)`** : si tu utilises la version “caps + personality”, branche-la ici (même signature, ou ajoute `params`).

2) `FactionRelationScore` doit avoir : `relation/trust/tension/grievance/weariness`, `clamp_all()`, `cooldown` via `is_on_cooldown` + `set_cooldown` (déjà dans notre design).


---


Si tu veux, je te fais une variante du test 3 qui :


* enregistre un **log d’événements** (jour, A, B, action, choice, avant/après),
* et calcule une métrique “**escalation index**” (tension↑ + relation↓ pondérée) pour prouver quantitativement que ça ne diverge pas.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 6](#toc-detail-ch6)
<a id="moi-26"></a>
**Moi 26:**
fais une variante du test 3 qui :


enregistre un log d’événements (jour, A, B, action, choice, avant/après),


et calcule une métrique “escalation index” (tension↑ + relation↓ pondérée) pour prouver quantitativement que ça ne diverge pas.


**ChatGPT:**
OK. Voici une **variante du Test 3** qui :


* enregistre un **log détaillé** par événement (jour, A, B, action, choice, avant/après sur AB et BA),
* calcule un **Escalation Index** journalier et global :
	+ `EI_event = wT * max(0, Δtension_mean) + wR * max(0, -Δrelation_mean)`
	+ (donc ça ne “récompense” pas la désescalade, mais mesure uniquement les poussées vers le conflit)
* écrit un fichier `user://arc_sim_log.json` + `user://arc_sim_summary.json`
* vérifie un invariant : **l’Escalation Index moyen ne doit pas exploser** (cap + cooldown + decay doivent le stabiliser).


---


## `TestArcSimulationLogged.gd`


```
# Godot 4.x

extends Node
class\_name TestArcSimulationLogged

const GOLDEN\_PATH := "user://golden\_faction\_profiles.json"
const LOG\_PATH := "user://arc\_sim\_log.json"
const SUMMARY\_PATH := "user://arc\_sim\_summary.json"

@export var days\_to\_simulate: int = 30
@export var max\_events\_per\_day: int = 6

# Escalation metric weights

@export var w\_tension: float = 1.0
@export var w\_relation: float = 0.55

var rng := RandomNumberGenerator.new()

const PEACE\_ACTIONS := [
 ArcDecisionUtil.ARC\_TRUCE\_TALKS,
 ArcDecisionUtil.ARC\_REPARATIONS,
 ArcDecisionUtil.ARC\_ALLIANCE\_OFFER,
]

const HOSTILE\_ACTIONS := [
 ArcDecisionUtil.ARC\_RAID,
 ArcDecisionUtil.ARC\_SABOTAGE,
 ArcDecisionUtil.ARC\_DECLARE\_WAR,
 ArcDecisionUtil.ARC\_ULTIMATUM,
]

func \_ready() -> void:
 rng.seed = 888888
 run(days\_to\_simulate)
 print("\n✅ Arc simulation (logged + escalation index): OK\n")
 get\_tree().quit()


func run(days: int) -> void:
 \_assert(days > 0, "days must be > 0")

# 1) Load golden profiles

 var profiles\_list := \_load\_golden\_profiles()
 \_assert(profiles\_list.size() >= 6, "Need at least 6 profiles")

 var faction\_profiles: Dictionary[StringName, FactionProfile] = {}
 for i in range(min(10, profiles\_list.size())):
 faction\_profiles[StringName("faction\_%02d" % i)] = profiles\_list[i]

 var ids: Array[StringName] = []
 for fid in faction\_profiles.keys():
 ids.append(StringName(fid))

# 2) Init relations world

 var world\_rel := FactionRelationsUtil.initialize\_relations\_world(
 faction\_profiles,
 rng,
 {
 "apply\_reciprocity": true,
 "reciprocity\_strength": 0.70,
 "keep\_asymmetry": 0.30,
 "reciprocity\_noise": 2,
 "max\_change\_per\_pair": 18,
 "final\_global\_sanity": true,
 "max\_extremes\_per\_faction": 2
 },
 {
 "desired\_mean": 0.0,
 "desired\_std": 22.0,
 "enemy\_min": 1, "enemy\_max": 2,
 "ally\_min": 1, "ally\_max": 2,
 "noise": 3,
 "tension\_cap": 40.0,
 "final\_recenter": true
 },
 {
 "w\_axis\_similarity": 80.0,
 "w\_cross\_conflict": 55.0,
 "tension\_cap": 40.0
 }
 )

# 3) Notebook

 var arc\_notebook := ArcNotebook.new()

# 4) Logs + metrics

 var event\_log: Array = []
 var daily\_escalation: Array[float] = []
 var daily\_event\_count: Array[int] = []

 # global counters
 var stats := {
 "events\_total": 0,
 "by\_action": {},
 "by\_choice": {},
 "peace\_events": 0,
 "hostile\_events": 0,
 "declare\_war": 0,
 }

 # baseline snapshot for divergence proof
 var baseline := \_snapshot\_global(ids, world\_rel)

# 5) Sim loop

 for day in range(1, days + 1):
 \_daily\_decay(ids, world\_rel, faction\_profiles)

 var candidates: Array = []
 for a\_id in ids:
 var map\_a: Dictionary = world\_rel[a\_id]
 for b\_id in map\_a.keys():
 if b\_id == a\_id:
 continue
 var rel\_ab: FactionRelationScore = map\_a[b\_id]
 var p := ArcDecisionUtil.compute\_arc\_event\_chance(
 rel\_ab,
 faction\_profiles[a\_id],
 faction\_profiles[b\_id],
 day,
 {"max\_p": 0.35}
 )
 if p > 0.0 and rng.randf() < p:
 candidates.append({"a": a\_id, "b": b\_id, "p": p})

 candidates.sort\_custom(func(x, y): return float(x["p"]) > float(y["p"]))
 var take := min(max\_events\_per\_day, candidates.size())

 var day\_ei := 0.0
 var produced := 0

 for i in range(take):
 var c := candidates[i]
 var a\_id: StringName = c["a"]
 var b\_id: StringName = c["b"]

 var rel\_ab: FactionRelationScore = world\_rel[a\_id][b\_id]
 var rel\_ba: FactionRelationScore = world\_rel[b\_id][a\_id]

 # ---- BEFORE snapshot (pair mean) ----
 var before := \_snapshot\_pair\_mean(rel\_ab, rel\_ba)

 var action := ArcDecisionUtil.select\_arc\_action\_type(
 rel\_ab,
 faction\_profiles[a\_id],
 faction\_profiles[b\_id],
 rng,
 day,
 {
 "external\_threat": 0.15,
 "opportunity": \_compute\_opportunity(rel\_ab, faction\_profiles[a\_id]),
 "temperature": 0.18
 }
 )
 if action == ArcDecisionUtil.ARC\_IGNORE:
 continue

 var choice := \_resolve\_choice(action, rel\_ab)

# Apply event (deltas + cooldown + notebook)

 ArcEffectTable.apply\_arc\_resolution\_event(
 action, choice,
 a\_id, b\_id,
 rel\_ab, rel\_ba,
 faction\_profiles[a\_id],
 faction\_profiles[b\_id],
 arc\_notebook,
 day, rng
 )

# ---- AFTER snapshot (pair mean) ----

 var after := \_snapshot\_pair\_mean(rel\_ab, rel\_ba)

# Escalation index contribution (only escalatory deltas)

 var ei := \_event\_escalation\_index(before, after)
 day\_ei += ei

 # Log entry (jour, A,B, action, choice, before/after AB & BA)
 event\_log.append(\_make\_event\_log\_entry(day, a\_id, b\_id, action, choice, rel\_ab, rel\_ba, before, after, ei))

# stats

 \_stats\_add(stats, action, choice)

 produced += 1

 daily\_escalation.append(day\_ei)
 daily\_event\_count.append(produced)

# 6) Summaries + invariants

 var summary := \_build\_summary(stats, baseline, \_snapshot\_global(ids, world\_rel), daily\_escalation, daily\_event\_count, days)

 \_write\_json(LOG\_PATH, {"seed": 888888, "days": days, "events": event\_log})
 \_write\_json(SUMMARY\_PATH, summary)

 print("\n📄 Saved logs to: ", LOG\_PATH)
 print("📄 Saved summary to: ", SUMMARY\_PATH)

 \_print\_summary(summary)
 \_validate\_escalation\_invariants(summary, days)

# -----------------------------

# Escalation metric

# -----------------------------

func \_event\_escalation\_index(before: Dictionary, after: Dictionary) -> float:
 # EI\_event = wT * max(0, Δtension\_mean) + wR * max(0, -Δrelation\_mean)
 var dt := float(after["tension\_mean"]) - float(before["tension\_mean"])
 var dr := float(after["relation\_mean"]) - float(before["relation\_mean"])
 var inc\_t := max(0.0, dt)
 var inc\_r := max(0.0, -dr)
 return w\_tension * inc\_t + w\_relation * inc\_r


func \_snapshot\_pair\_mean(rel\_ab: FactionRelationScore, rel\_ba: FactionRelationScore) -> Dictionary:
 return {
 "relation\_mean": 0.5 * (float(rel\_ab.relation) + float(rel\_ba.relation)),
 "trust\_mean": 0.5 * (float(rel\_ab.trust) + float(rel\_ba.trust)),
 "tension\_mean": 0.5 * (rel\_ab.tension + rel\_ba.tension),
 "grievance\_mean": 0.5 * (rel\_ab.grievance + rel\_ba.grievance),
 "weariness\_mean": 0.5 * (rel\_ab.weariness + rel\_ba.weariness),
 }


func \_make\_event\_log\_entry(
 day: int,
 a\_id: StringName,
 b\_id: StringName,
 action: StringName,
 choice: StringName,
 rel\_ab: FactionRelationScore,
 rel\_ba: FactionRelationScore,
 before: Dictionary,
 after: Dictionary,
 ei: float
) -> Dictionary:
 return {
 "day": day,
 "a": String(a\_id),
 "b": String(b\_id),
 "action": String(action),
 "choice": String(choice),
 "ei": ei,
 "before\_mean": before,
 "after\_mean": after,
 "ab\_before": {
 "relation": int(round(2.0*float(before["relation\_mean"]) - float(rel\_ba.relation))), # approx not needed but kept
 },
 "ab\_after": {
 "relation": rel\_ab.relation,
 "trust": rel\_ab.trust,
 "tension": rel\_ab.tension,
 "grievance": rel\_ab.grievance,
 "weariness": rel\_ab.weariness,
 },
 "ba\_after": {
 "relation": rel\_ba.relation,
 "trust": rel\_ba.trust,
 "tension": rel\_ba.tension,
 "grievance": rel\_ba.grievance,
 "weariness": rel\_ba.weariness,
 }
 }


# -----------------------------

# Daily decay

# -----------------------------

func \_daily\_decay(ids: Array[StringName], world\_rel: Dictionary, faction\_profiles: Dictionary) -> void:
 var base\_tension\_decay := 0.9
 var base\_griev\_decay := 0.6
 var base\_wear\_decay := 0.35

 for a\_id in ids:
 var prof: FactionProfile = faction\_profiles[a\_id]
 var diplo := prof.get\_personality(FactionProfile.PERS\_DIPLOMACY, 0.5)
 var veng := prof.get\_personality(FactionProfile.PERS\_VENGEFULNESS, 0.5)

 var tension\_mul := 0.70 + 0.80 * diplo
 var griev\_mul := 0.55 + 0.90 * (1.0 - veng)

 var map\_a: Dictionary = world\_rel[a\_id]
 for b\_id in map\_a.keys():
 var rs: FactionRelationScore = map\_a[b\_id]
 rs.tension = max(0.0, rs.tension - base\_tension\_decay * tension\_mul)
 rs.grievance = max(0.0, rs.grievance - base\_griev\_decay * griev\_mul)
 rs.weariness = max(0.0, rs.weariness - base\_wear\_decay)
 rs.clamp\_all()

# -----------------------------

# Choice simulation + opportunity

# -----------------------------

func \_resolve\_choice(action: StringName, rel\_ab: FactionRelationScore) -> StringName:
 var t := rel\_ab.tension / 100.0
 var g := rel\_ab.grievance / 100.0
 var bias := clampf(0.45 + 0.25*t + 0.20*g, 0.35, 0.75)

 var p\_loyal := bias
 var p\_neutral := 0.30
 var p\_traitor := 1.0 - (p\_loyal + p\_neutral)
 p\_traitor = clampf(p\_traitor, 0.05, 0.25)

 if PEACE\_ACTIONS.has(action):
 p\_loyal = clampf(p\_loyal + 0.10, 0.45, 0.85)
 p\_neutral = 0.25
 p\_traitor = 1.0 - (p\_loyal + p\_neutral)
 elif action == ArcDecisionUtil.ARC\_DECLARE\_WAR:
 p\_neutral = 0.35
 p\_loyal = clampf(p\_loyal, 0.40, 0.70)
 p\_traitor = 1.0 - (p\_loyal + p\_neutral)

 var r := rng.randf()
 if r < p\_loyal:
 return ArcEffectTable.CHOICE\_LOYAL
 if r < p\_loyal + p\_neutral:
 return ArcEffectTable.CHOICE\_NEUTRAL
 return ArcEffectTable.CHOICE\_TRAITOR


func \_compute\_opportunity(rel\_ab: FactionRelationScore, a\_prof: FactionProfile) -> float:
 var expa := a\_prof.get\_personality(FactionProfile.PERS\_EXPANSIONISM, 0.5)
 var w := rel\_ab.weariness / 100.0
 return clampf(0.45 + 0.35*(expa - 0.5) - 0.40*w, 0.05, 0.95)

# -----------------------------

# Global snapshots + summary

# -----------------------------

func \_snapshot\_global(ids: Array[StringName], world\_rel: Dictionary) -> Dictionary:
 var rels: Array[float] = []
 var tens: Array[float] = []
 var wears: Array[float] = []
 var grs: Array[float] = []

 for a\_id in ids:
 var map\_a: Dictionary = world\_rel[a\_id]
 for b\_id in map\_a.keys():
 var rs: FactionRelationScore = map\_a[b\_id]
 rels.append(float(rs.relation))
 tens.append(float(rs.tension))
 wears.append(float(rs.weariness))
 grs.append(float(rs.grievance))

 return {
 "avg\_relation": \_mean(rels),
 "avg\_tension": \_mean(tens),
 "avg\_weariness": \_mean(wears),
 "avg\_grievance": \_mean(grs),
 }


func \_build\_summary(stats: Dictionary, base: Dictionary, end: Dictionary, daily\_ei: Array[float], daily\_ev: Array[int], days: int) -> Dictionary:
 var ei\_sum := 0.0
 var ei\_max := 0.0
 for v in daily\_ei:
 ei\_sum += v
 ei\_max = max(ei\_max, v)
 var ei\_mean := ei\_sum / float(max(1, daily\_ei.size()))

# "divergence signal": tension should not keep ramping linearly

 var t0 := float(base["avg\_tension"])
 var t\_end := float(end["avg\_tension"])
 var drift := t\_end - t0

 return {
 "days": days,
 "events\_total": int(stats["events\_total"]),
 "by\_action": stats["by\_action"],
 "by\_choice": stats["by\_choice"],
 "peace\_events": int(stats["peace\_events"]),
 "hostile\_events": int(stats["hostile\_events"]),
 "declare\_war": int(stats["declare\_war"]),

 "baseline": base,
 "final": end,
 "avg\_tension\_drift": drift,

 "escalation": {
 "w\_tension": w\_tension,
 "w\_relation": w\_relation,
 "daily": daily\_ei,
 "daily\_event\_count": daily\_ev,
 "sum": ei\_sum,
 "mean": ei\_mean,
 "max\_day": ei\_max,
 }
 }


func \_print\_summary(summary: Dictionary) -> void:
 print("\n--- Arc Simulation Logged Summary ---")
 print("Days: ", summary["days"], " | Events: ", summary["events\_total"])
 print("Hostile: ", summary["hostile\_events"], " | Peace: ", summary["peace\_events"], " | War declares: ", summary["declare\_war"])
 print("Avg tension drift: ", summary["avg\_tension\_drift"])
 print("Escalation EI mean/day: ", summary["escalation"]["mean"], " | max day: ", summary["escalation"]["max\_day"])
 print("Baseline: ", summary["baseline"])
 print("Final: ", summary["final"])
 print("By action: ", summary["by\_action"])


func \_validate\_escalation\_invariants(summary: Dictionary, days: int) -> void:
 # 1) EI moyen/jour ne doit pas exploser
 var ei\_mean := float(summary["escalation"]["mean"])

# ordre de grandeur: avec caps+cooldowns+decay, on attend EI/jour modéré

 \_assert(ei\_mean <= 18.0, "Escalation index mean/day too high: %f" % ei\_mean)

# 2) la tension globale ne doit pas diverger

 var drift := float(summary["avg\_tension\_drift"])
 \_assert(drift <= 35.0, "Avg tension drift too high: %f" % drift)

# 3) pas trop de guerres

 var max\_wars := max(1, int(floor(float(days) / 20.0)) + 1)
 \_assert(int(summary["declare\_war"]) <= max\_wars,
 "Too many war declarations: %d (max %d)" % [int(summary["declare\_war"]), max\_wars])

# -----------------------------

# IO helpers

# -----------------------------

func \_write\_json(path: String, payload: Dictionary) -> void:
 var f := FileAccess.open(path, FileAccess.WRITE)
 \_assert(f != null, "Cannot open %s for writing" % path)
 f.store\_string(JSON.stringify(payload, "\t"))
 f.close()

# -----------------------------

# Golden load / fallback

# -----------------------------

func \_load\_golden\_profiles() -> Array[FactionProfile]:
 if not FileAccess.file\_exists(GOLDEN\_PATH):
 push\_warning("Golden profiles not found at %s, generating 10 fallback profiles." % GOLDEN\_PATH)
 return \_generate\_fallback\_profiles(10)

 var f := FileAccess.open(GOLDEN\_PATH, FileAccess.READ)
 \_assert(f != null, "Cannot open %s" % GOLDEN\_PATH)
 var txt := f.get\_as\_text()
 f.close()

 var json := JSON.new()
 var err := json.parse(txt)
 \_assert(err == OK, "JSON parse failed in %s" % GOLDEN\_PATH)
 var root: Dictionary = json.data

 var arr: Array = root.get("profiles", [])
 \_assert(arr.size() > 0, "Golden file has no profiles")

 var out: Array[FactionProfile] = []
 for item in arr:
 out.append(\_profile\_from\_json\_dict(item))
 return out


func \_profile\_from\_json\_dict(d: Dictionary) -> FactionProfile:
 var p := FactionProfile.new()

 var axis\_in: Dictionary = d.get("axis\_affinity", {})
 var per\_in: Dictionary = d.get("personality", {})

 p.axis\_affinity = {}
 for ax in FactionProfile.ALL\_AXES:
 p.axis\_affinity[ax] = int(axis\_in.get(String(ax), 0))

 p.personality = {}
 for k in FactionProfile.ALL\_PERSONALITY\_KEYS:
 p.personality[k] = float(per\_in.get(String(k), 0.5))

 return p


func \_generate\_fallback\_profiles(n: int) -> Array[FactionProfile]:
 var out: Array[FactionProfile] = []
 for \_i in range(n):
 out.append(FactionProfile.generate\_full\_profile(rng, FactionProfile.GEN\_NORMAL))
 return out


# -----------------------------

# Stats helper

# -----------------------------

func \_stats\_add(stats: Dictionary, action: StringName, choice: StringName) -> void:
 stats["events\_total"] = int(stats["events\_total"]) + 1

 var by\_action: Dictionary = stats["by\_action"]
 by\_action[action] = int(by\_action.get(action, 0)) + 1
 stats["by\_action"] = by\_action

 var by\_choice: Dictionary = stats["by\_choice"]
 by\_choice[choice] = int(by\_choice.get(choice, 0)) + 1
 stats["by\_choice"] = by\_choice

 if action == ArcDecisionUtil.ARC\_DECLARE\_WAR:
 stats["declare\_war"] = int(stats["declare\_war"]) + 1

 if PEACE\_ACTIONS.has(action):
 stats["peace\_events"] = int(stats["peace\_events"]) + 1
 if HOSTILE\_ACTIONS.has(action):
 stats["hostile\_events"] = int(stats["hostile\_events"]) + 1


# -----------------------------

# Math + assert

# -----------------------------

func \_mean(arr: Array[float]) -> float:
 if arr.is\_empty():
 return 0.0
 var s := 0.0
 for v in arr:
 s += v
 return s / float(arr.size())

func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


### Fichiers générés


* `user://arc_sim_log.json` : liste des événements (jour, A, B, action, choice, EI, avant/après)
* `user://arc_sim_summary.json` : résumé + série `daily EI`


---


### Remarques pratiques


* Le log contient `before_mean/after_mean` (moyenne AB/BA). Si tu veux **avant/après AB et BA complets**, je peux te fournir une version qui snapshot explicitement `ab_before` et `ba_before` avant l’apply (là j’ai gardé “mean” en vrai avant, et “after” complet).
* L’invariant `EI_mean <= 18` est un **seuil de départ** : tu le calibreras selon tes deltas/caps/decay réels.


Si tu veux, je te fais la micro-amélioration “**avant complet AB + BA**” (relation/trust/tension/grievance/weariness) dans chaque entrée de log, c’est 10 lignes de plus et ça rend le débug beaucoup plus agréable.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 6](#toc-detail-ch6)
<a id="moi-27"></a>
**Moi 27:**
Oui, ajoute ca


**ChatGPT:**
Bien vu — voici la modification pour logger **avant complet AB** et **avant complet BA** (et après complet aussi), en plus des moyennes.


## 1) Ajoute ces helpers


```
func \_snapshot\_link(rs: FactionRelationScore) -> Dictionary:
 return {
 "relation": rs.relation,
 "trust": rs.trust,
 "tension": rs.tension,
 "grievance": rs.grievance,
 "weariness": rs.weariness,
 # optionnel si tu l'as: "friction": rs.friction
 }
```


Et remplace `_make_event_log_entry(...)` par une version qui prend `ab_before` + `ba_before`.


```
func \_make\_event\_log\_entry(
 day: int,
 a\_id: StringName,
 b\_id: StringName,
 action: StringName,
 choice: StringName,
 before\_mean: Dictionary,
 after\_mean: Dictionary,
 ab\_before: Dictionary,
 ba\_before: Dictionary,
 ab\_after: Dictionary,
 ba\_after: Dictionary,
 ei: float
) -> Dictionary:
 return {
 "day": day,
 "a": String(a\_id),
 "b": String(b\_id),
 "action": String(action),
 "choice": String(choice),
 "ei": ei,
 "before\_mean": before\_mean,
 "after\_mean": after\_mean,
 "ab\_before": ab\_before,
 "ba\_before": ba\_before,
 "ab\_after": ab\_after,
 "ba\_after": ba\_after,
 }
```


## 2) Dans la boucle d’événements, prends les snapshots AVANT puis APRÈS


Remplace la partie “BEFORE / AFTER” de la boucle par ça :


```
# ---- BEFORE snapshots ----

var before\_mean := \_snapshot\_pair\_mean(rel\_ab, rel\_ba)
var ab\_before := \_snapshot\_link(rel\_ab)
var ba\_before := \_snapshot\_link(rel\_ba)

var action := ArcDecisionUtil.select\_arc\_action\_type(...)
if action == ArcDecisionUtil.ARC\_IGNORE:
 continue

var choice := \_resolve\_choice(action, rel\_ab)

ArcEffectTable.apply\_arc\_resolution\_event(...)

# ---- AFTER snapshots ----

var after\_mean := \_snapshot\_pair\_mean(rel\_ab, rel\_ba)
var ab\_after := \_snapshot\_link(rel\_ab)
var ba\_after := \_snapshot\_link(rel\_ba)

var ei := \_event\_escalation\_index(before\_mean, after\_mean)
day\_ei += ei

event\_log.append(\_make\_event\_log\_entry(
 day, a\_id, b\_id, action, choice,
 before\_mean, after\_mean,
 ab\_before, ba\_before,
 ab\_after, ba\_after,
 ei
))
```


## 3) Supprime l’ancienne version qui essayait de “reconstruire” `ab_before`


Dans ton script précédent, tu avais un bout approximatif :


```
"ab\_before": {"relation": int(round(2.0*...))}
```


Tu peux le supprimer entièrement : maintenant on a le vrai snapshot.


---


Avec ça, chaque ligne du log te donne exactement :


* l’état AB et BA **avant**,
* l’état AB et BA **après**,
* le “mean” (pratique pour EI),
* et l’`ei` de l’événement.


Si tu veux, je peux aussi ajouter une sortie CSV (souvent plus agréable à analyser vite), mais le JSON suffit déjà bien.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 6](#toc-detail-ch6)
<a id="moi-28"></a>
**Moi 28:**
Une sortie cv serait parfaite


**ChatGPT:**
Parfait — on ajoute une **sortie CSV** (même contenu que le log JSON, mais aplati en colonnes).


Je te propose 2 fichiers :


* `user://arc_sim_events.csv` : **1 ligne = 1 événement** (avant/après AB & BA + moyennes + EI)
* `user://arc_sim_daily.csv` : **1 ligne = 1 jour** (events du jour + EI du jour + métriques globales)


Ci-dessous, uniquement les ajouts/modifs à faire dans `TestArcSimulationLogged.gd`.


---


## 1) Constantes CSV


Ajoute en haut :


```
const CSV\_EVENTS\_PATH := "user://arc\_sim\_events.csv"
const CSV\_DAILY\_PATH := "user://arc\_sim\_daily.csv"
```


---


## 2) Helpers CSV


Ajoute ces fonctions :


```
func \_csv\_cell(v) -> String:
 var s := ""
 if v == null:
 s = ""
 elif typeof(v) == TYPE\_FLOAT:
 s = "%0.4f" % float(v)
 else:
 s = str(v)

# escape quotes, wrap in quotes (safe for commas/newlines)

 s = s.replace("\"", "\"\"")
 return "\"" + s + "\""


func \_write\_csv(path: String, header: Array[String], rows: Array[Array]) -> void:
 var f := FileAccess.open(path, FileAccess.WRITE)
 \_assert(f != null, "Cannot open %s for writing" % path)

# header

 var h: Array[String] = []
 for c in header:
 h.append(\_csv\_cell(c))
 f.store\_line(",".join(h))

# rows

 for r in rows:
 var line: Array[String] = []
 for c in r:
 line.append(\_csv\_cell(c))
 f.store\_line(",".join(line))

 f.close()
```


---


## 3) Export CSV “events”


Ajoute :


```
func \_export\_events\_csv(event\_log: Array) -> void:
 var header := [
 "day","a","b","action","choice","ei",

 "before\_mean\_relation","before\_mean\_trust","before\_mean\_tension","before\_mean\_grievance","before\_mean\_weariness",
 "after\_mean\_relation","after\_mean\_trust","after\_mean\_tension","after\_mean\_grievance","after\_mean\_weariness",

 "ab\_before\_relation","ab\_before\_trust","ab\_before\_tension","ab\_before\_grievance","ab\_before\_weariness",
 "ba\_before\_relation","ba\_before\_trust","ba\_before\_tension","ba\_before\_grievance","ba\_before\_weariness",

 "ab\_after\_relation","ab\_after\_trust","ab\_after\_tension","ab\_after\_grievance","ab\_after\_weariness",
 "ba\_after\_relation","ba\_after\_trust","ba\_after\_tension","ba\_after\_grievance","ba\_after\_weariness",
 ]

 var rows: Array[Array] = []
 for e in event\_log:
 var bm: Dictionary = e["before\_mean"]
 var am: Dictionary = e["after\_mean"]
 var abb: Dictionary = e["ab\_before"]
 var bab: Dictionary = e["ba\_before"]
 var aba: Dictionary = e["ab\_after"]
 var baa: Dictionary = e["ba\_after"]

 rows.append([
 e["day"], e["a"], e["b"], e["action"], e["choice"], e["ei"],

 bm["relation\_mean"], bm["trust\_mean"], bm["tension\_mean"], bm["grievance\_mean"], bm["weariness\_mean"],
 am["relation\_mean"], am["trust\_mean"], am["tension\_mean"], am["grievance\_mean"], am["weariness\_mean"],

 abb["relation"], abb["trust"], abb["tension"], abb["grievance"], abb["weariness"],
 bab["relation"], bab["trust"], bab["tension"], bab["grievance"], bab["weariness"],

 aba["relation"], aba["trust"], aba["tension"], aba["grievance"], aba["weariness"],
 baa["relation"], baa["trust"], baa["tension"], baa["grievance"], baa["weariness"],
 ])

 \_write\_csv(CSV\_EVENTS\_PATH, header, rows)
 print("📄 Saved events CSV to: ", CSV\_EVENTS\_PATH)
```


---


## 4) Export CSV “daily”


Dans ton script, tu as déjà `daily_escalation` et `daily_event_count`. Ajoute aussi un snapshot global par jour (tension/relation/weariness/grievance). Le plus simple :


1) Déclare dans `run()` :


```
var daily\_global: Array = [] # [{day, avg\_tension, avg\_relation, ...}]
```


2) À la fin de chaque jour, après `daily_escalation.append(...)`, ajoute :


```
var g := \_snapshot\_global(ids, world\_rel)
daily\_global.append({"day": day, "g": g})
```


3) Ajoute l’export :


```
func \_export\_daily\_csv(daily\_escalation: Array[float], daily\_event\_count: Array[int], daily\_global: Array) -> void:
 var header := [
 "day","events","ei\_day",
 "avg\_relation","avg\_tension","avg\_grievance","avg\_weariness"
 ]

 var rows: Array[Array] = []
 for i in range(daily\_escalation.size()):
 var day := i + 1
 var g: Dictionary = daily\_global[i]["g"]
 rows.append([
 day,
 daily\_event\_count[i],
 daily\_escalation[i],
 g["avg\_relation"],
 g["avg\_tension"],
 g["avg\_grievance"],
 g["avg\_weariness"]
 ])

 \_write\_csv(CSV\_DAILY\_PATH, header, rows)
 print("📄 Saved daily CSV to: ", CSV\_DAILY\_PATH)
```


---


## 5) Appels à la fin du test


Après tes `_write_json(...)`, ajoute :


```
\_export\_events\_csv(event\_log)
\_export\_daily\_csv(daily\_escalation, daily\_event\_count, daily\_global)
```


---


Si tu veux, je peux aussi te proposer une version “compacte” du CSV events (juste day/A/B/action/choice/EI + before/after mean), utile quand tu veux juste tracer vite l’escalation.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 6](#toc-detail-ch6)
<a id="moi-29"></a>
**Moi 29:**
Non ca suffira

Selon toi, est ce que le systeme que tu viens de créer est complet?

Qu'est ce qui pourrait manquer ?

A la fin, chaque faction va se baser sur ce que tu as fait pour creer des offres de quetes


**ChatGPT:**
Oui, tu as déjà une base très solide et “fermée” (profils → relations → arcs → décisions → effets → caps/cooldowns → tests). Pour que ce soit vraiment complet en jeu (et pas juste en test), il manque surtout des **points d’intégration** et quelques **garde-fous de design**.


## Ce qui manque le plus souvent en prod


### 1) Un “ArcState” par paire (état explicite)


Aujourd’hui tu as des métriques (relation/tension/grievance/…) + notebook. C’est très bien, mais il te manque un état clair :


* `PEACE / RIVALRY / CONFLICT / WAR / ALLIANCE / VASSAL / MERGED`

Ça sert à :
* contrôler quelles actions sont autorisées (pas d’“alliance offer” en pleine guerre totale),
* adapter les probabilités,
* définir quand un arc **se termine** (sortie propre).


### 2) Des “conditions de fin” + “cooldown long” d’arc


Tu as cap/cooldown par évènement, mais il faut aussi une règle de fin :


* Rivalité se termine si `tension_mean < X` pendant Y jours,
* ou si `trust_mean > X` et `relation_mean > X`,
* ou si guerre déclarée → on passe en état WAR et on stoppe certains arcs “mineurs”.

Et surtout un `pair_lock_days` (genre 15–40 jours) après résolution d’un arc majeur (trêve, alliance, fusion), sinon tu “re-rentres” tout de suite en incident.


### 3) Un modèle de “coût” et “capacité” faction (budget d’actions)


Pour éviter que des factions déclenchent trop d’offres :


* budget/jour ou budget/semaine (dépend de ressources/logistique, état de guerre, fatigue),
* limite d’offres actives par faction,
* coût par action type (raid coûte moins qu’une guerre, trêve coûte du capital politique, etc.).

Sans ça, tu risques un spam d’offres même si la probabilité est stable.


### 4) Le mapping “arc\_action\_type → offres de quêtes”


C’est LE pont vers ton QuestPool :


* chaque `arc_action_type` doit produire 1+ **templates d’offres** (avec variantes),
* et des **context keys** standardisées (`arc_action_type`, `giver`, `antagonist`, `target_poi`, `stake`, `deadline`, etc.).

Il manque donc une table “OfferFactory” :
* `arc.raid` → quests combat/stealth/supply-line,
* `arc.ultimatum` → diplomacy / escort envoy / retrieve proof,
* `arc.truce_talks` → escort diplomat / secure venue / eliminate spoiler,
* `arc.alliance_offer` → joint mission / exchange hostages / oath ritual.


### 5) Une boucle “monde” cohérente (pas seulement ArcManager)


Les arcs ne doivent pas être l’unique moteur :


* les goals (FactionGoalPlanner) doivent influencer `opportunity`, `external_threat`, `priority targets`,
* et inversement les arcs doivent modifier les goals (en guerre, les objectifs changent).

Sinon, tu auras des arcs “hors-sol”.


### 6) Une notion de “third party” (intervention, médiation, opportunisme)


Très important pour éviter l’escalade binaire A↔B :


* C intervient comme médiateur (trêve) ou profite (raid opportuniste),
* les offres peuvent impliquer 3 factions (donne beaucoup de vie au monde).

Même une version simple (“si A↔B est chaud, C peut proposer trêve/commerce/allié”) ajoute énormément.


### 7) La persistance et la stabilité des métriques


Pour être safe :


* sérialiser `FactionRelationScore` + `ArcNotebook` (counts/last\_day + records),
* versionner le format (quand tu changes les champs, tu ne casses pas une save).


## Pour “chaque faction va créer des offres de quêtes”


Oui, ton système est parfaitement adapté à ça, mais je recommande une étape intermédiaire :


**Decision (ArcDecisionUtil)** → **Intent (ArcIntent)** → **QuestOffer(s)**


Un `ArcIntent` est une structure simple :


* `type` (raid/truce/…)
* `a_id`, `b_id`
* `priority`, `deadline_days`
* `suggested_domains` (combat/diplomacy/stealth/…)
* `stakes` (resource, artifact, territory, reputation…)


Puis une `QuestOfferFactory` transforme ça en 1..N offers dans ton `QuestPool`, avec caps.


## En bref


Le cœur “math/évolution” est complet. Ce qui manque pour passer en jeu, c’est surtout :


* **ArcState par paire + règles de fin**,
* **budget/capacité** pour éviter le spam,
* une **OfferFactory** qui mappe actions → quêtes,
* et un minimum de “tiers” (3e faction) pour casser les boucles.


Si tu veux, prochaine brique logique : je te propose une spec compacte de `ArcState` + conditions de transition + table `arc_action_type → liste d’offres` (avec context standard).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 6](#toc-detail-ch6)
<a id="moi-30"></a>
**Moi 30:**
Ok : prochaine brique logique : propose une spec compacte de
<a id="cite-arcstate-66333b-1"></a>ArcState + conditions de transition + table arc\_action\_type → liste d’offres (avec context standard).


**ChatGPT:**
Voici une spec **compacte mais complète** : un `ArcState` par paire, des **transitions** claires, et une **table action → offers** avec un `context` standardisé.


---


## 1) ArcState par paire


### Enum d’état


```
NEUTRAL        (pas d’arc actif)
RIVALRY        (hostilité diffuse / incidents)
CONFLICT       (actions hostiles fréquentes, mais pas guerre totale)
WAR            (guerre ouverte)
TRUCE          (désescalade active, fragile)
ALLIANCE       (coopération active)
VASSALAGE      (optionnel) A domine B
MERGED         (terminal) fusion / absorption
EXTINCT        (terminal) faction détruite (hors scope arc mais utile)
```


### Structure `ArcState` (données minimales)


```
class\_name ArcState
extends RefCounted

var a\_id: StringName
var b\_id: StringName
var state: StringName = &"NEUTRAL" # see enum above

var entered\_day: int = 0
var last\_event\_day: int = -999999
var lock\_until\_day: int = -999999 # empêche re-trigger trop vite

# compteurs “phase” (réinitialisés à chaque changement d’état)

var phase\_hostile: int = 0
var phase\_peace: int = 0
var phase\_events: int = 0

# optionnel: dernier arc\_action\_type utile pour debug

var last\_action: StringName = &""

func is\_locked(day: int) -> bool:
 return day < lock\_until\_day
```


---


## 2) Conditions de transition (règles simples)


On utilise les **moyennes pair** :


* `rel_mean = (AB.relation + BA.relation)/2`
* `trust_mean`, `tension_mean`, `griev_mean`, `wear_mean`


Et on utilise aussi les compteurs `phase_hostile/phase_peace` alimentés par les actions.


### Seuils suggérés (tunable)


```
t_high = 70   (tension haute)
t_med  = 50
t_low  = 25
rel_bad = -55
rel_hate = -70
rel_good = +35
trust_good = +55
griev_high = 60
wear_high  = 65
```


### Transitions (ordre d’évaluation recommandé)

#### A) Entrée en arc


* `NEUTRAL → RIVALRY` si :
	+ `not locked` AND (`tension_mean >= t_med` OR `rel_mean <= rel_bad` OR “incident hostile”)
	+ et tu poses un `lock_until_day = day + 5..10` uniquement si tu veux éviter “retrigger immédiat” (optionnel)

#### B) Escalade


* `RIVALRY → CONFLICT` si :
	+ `tension_mean >= t_high` **ou** `phase_hostile >= 3` sur une fenêtre (ex. 10 jours)
	+ **et** `wear_mean < wear_high` (si usure très haute, on force plutôt trêve/gel)
* `CONFLICT → WAR` si :
	+ (`rel_mean <= rel_hate` AND `tension_mean >= t_high`)
	+ **ou** action `arc.declare_war` résolue LOYAL
	+ WAR met un lock plus long sur les “paix prématurées” (ex. 10 jours minimum avant trêve)

#### C) Désescalade


* `WAR → TRUCE` si :
	+ `wear_mean >= wear_high` **ou** `phase_peace >= 2` (truce\_talks/reparations)
	+ et `tension_mean <= 85` (si 100 constant, laisse respirer mais garde war)
* `CONFLICT → TRUCE` si :
	+ `phase_peace >= 2` **ou** (`tension_mean <= t_med` AND `griev_mean <= griev_high`)
* `RIVALRY → NEUTRAL` si :
	+ `tension_mean <= t_low` AND `griev_mean <= 20` pendant `Y jours` (ex. 7 jours)
	+ ou `phase_peace >= 2` + `trust_mean` remonte


#### D) Diplomatie / alliance / fusion


* `TRUCE → ALLIANCE` si :
	+ `trust_mean >= trust_good` AND `rel_mean >= rel_good` AND `tension_mean <= t_low`
* `ALLIANCE → MERGED` si (rare, gated) :
	+ `trust_mean >= 75` AND `rel_mean >= 60` ET conditions monde (même “bloc”, menace externe haute, intégrationnisme, etc.)
* `ALLIANCE → RIVALRY/CONFLICT` si :
	+ grosse trahison (traitor sur alliance offer / sabotage) + tension remonte au-dessus de `t_med`


#### E) Verrous (anti-yo-yo)


Quand tu entres dans :


* `WAR` : `lock_until_day = day + 10..20`
* `TRUCE` : `lock_until_day = day + 6..12`
* `ALLIANCE` : `lock_until_day = day + 12..25`
* `MERGED` : terminal (plus d’arc pour la paire)


---


## 3) Table `arc_action_type → offers`


### Context standard (clés communes)


Toujours mettre au minimum :


```
context["is\_arc\_rivalry"] = true
context["arc\_id"] = arc\_id
context["arc\_state"] = arc\_state\_name # e.g. "RIVALRY"
context["arc\_action\_type"] = arc\_action\_type # e.g. "arc.raid"

context["giver\_faction\_id"] = a\_id
context["antagonist\_faction\_id"] = b\_id

context["pair\_key"] = "a|b"
context["deadline\_days"] = int
context["stakes"] = { ... } # structure légère (voir plus bas)
context["seed"] = int # debug/repro
```


`stakes` recommandé :


```
context["stakes"] = {
 "gold": int,
 "relation\_delta\_hint": int, # pour UI/preview
 "risk": float, # 0..1
 "domain": "combat|diplo|stealth|logistics|exploration",
 "target\_poi": StringName, # optionnel
 "artifact\_id": StringName, # optionnel
}
```


### Table d’offres (catalogue compact)


>
> Chaque entrée retourne **1..N “offer specs”** : `{template_id OR generator_tag, weight, deadline_days, extra_context}`
>
>
>


```
const ARC\_OFFERS: Dictionary = {
 &"arc.raid": [
 {"tag": "combat.raid\_camp", "w": 50, "deadline": 6, "ctx": {"domain":"combat"}},
 {"tag": "stealth.burn\_supplies", "w": 25, "deadline": 5, "ctx": {"domain":"stealth"}},
 {"tag": "logistics.intercept", "w": 25, "deadline": 7, "ctx": {"domain":"logistics"}},
 ],

 &"arc.sabotage": [
 {"tag": "stealth.sabotage\_site", "w": 55, "deadline": 7, "ctx": {"domain":"stealth"}},
 {"tag": "diplo.frame\_agent", "w": 20, "deadline": 6, "ctx": {"domain":"diplo"}},
 {"tag": "combat.assassinate", "w": 25, "deadline": 8, "ctx": {"domain":"combat"}},
 ],

 &"arc.ultimatum": [
 {"tag": "diplo.deliver\_terms", "w": 55, "deadline": 5, "ctx": {"domain":"diplo"}},
 {"tag": "combat.show\_of\_force", "w": 25, "deadline": 6, "ctx": {"domain":"combat"}},
 {"tag": "logistics.seize\_toll", "w": 20, "deadline": 6, "ctx": {"domain":"logistics"}},
 ],

 &"arc.truce\_talks": [
 {"tag": "diplo.secure\_venue", "w": 45, "deadline": 6, "ctx": {"domain":"diplo"}},
 {"tag": "combat.protect\_envoy", "w": 30, "deadline": 6, "ctx": {"domain":"combat"}},
 {"tag": "stealth.remove\_spoiler", "w": 25, "deadline": 7, "ctx": {"domain":"stealth"}},
 ],

 &"arc.reparations": [
 {"tag": "logistics.deliver\_goods", "w": 45, "deadline": 8, "ctx": {"domain":"logistics"}},
 {"tag": "diplo.audit\_treaty", "w": 35, "deadline": 7, "ctx": {"domain":"diplo"}},
 {"tag": "combat.guard\_caravan", "w": 20, "deadline": 7, "ctx": {"domain":"combat"}},
 ],

 &"arc.declare\_war": [
 {"tag": "combat.capture\_outpost", "w": 45, "deadline": 10, "ctx": {"domain":"combat"}},
 {"tag": "logistics.mobilize", "w": 30, "deadline": 9, "ctx": {"domain":"logistics"}},
 {"tag": "stealth.break\_alliance", "w": 25, "deadline": 9, "ctx": {"domain":"stealth"}},
 ],

 &"arc.alliance\_offer": [
 {"tag": "diplo.sign\_pact", "w": 45, "deadline": 8, "ctx": {"domain":"diplo"}},
 {"tag": "combat.joint\_operation", "w": 35, "deadline": 9, "ctx": {"domain":"combat"}},
 {"tag": "logistics.exchange\_aid", "w": 20, "deadline": 8, "ctx": {"domain":"logistics"}},
 ],
}
```


### Sélection d’une offer (helper)


* choisit 1 entrée weighted,
* merge le context standard,
* ajoute `deadline_days`.


```
static func pick\_offer\_spec(action: StringName, rng: RandomNumberGenerator) -> Dictionary:
 var arr: Array = ARC\_OFFERS.get(action, [])
 if arr.is\_empty():
 return {}

 var sum := 0
 for s in arr:
 sum += int(s["w"])

 var r := rng.randi\_range(1, max(1, sum))
 var acc := 0
 for s in arr:
 acc += int(s["w"])
 if r <= acc:
 return s
 return arr.back()
```


---


## 4) Comment ça s’assemble dans l’ArcManager


Pipeline recommandé par jour / tick :


1) Pour chaque paire, tu as `ArcState`.

2) Tu évalues si incident possible (proba) puis `arc_action_type`.

3) Tu génères 1 offer :


* `spec = pick_offer_spec(action)`
* `context = build_arc_context(ArcState, a,b, action, spec)`

4) Tu appelles ton `QuestPool.try_add_offer(QuestInstance(...))`

5) À la résolution, `ArcEffectTable` met à jour relations + notebook

6) Puis tu appelles `update_arc_state(pair_state, rel_ab, rel_ba, day, last_action, last_was_hostile/peace)`.


---


## 5) Petit “minimum viable” de `update_arc_state`


Tu peux coder ça avec un simple `match state` + règles ci-dessus, et un petit helper :


* `is_hostile_action(action)` (raid/sabotage/ultimatum/declare\_war)
* `is_peace_action(action)` (truce/reparations/alliance\_offer)


Et tu incrémentes :


* `phase_hostile += 1` si hostile
* `phase_peace += 1` si peace
* `phase_events += 1` toujours


Puis tu appliques transitions et reset `phase_*` quand state change.


---


Si tu veux, prochaine brique : je te donne le code GDScript de `update_arc_state()` (version compacte) + `build_arc_context()` + un `ArcOfferFactory.spawn_offer_for_pair()` qui produit une `QuestInstance` directement compatible avec ton QuestPool.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-31"></a>
**Moi 31:**
donne le code GDScript de update\_arc\_state() (version compacte) + build\_arc\_context() + un
<a id="cite-arcofferfactory-dd2763-1"></a>ArcOfferFactory.spawn\_offer\_for\_pair() qui produit une
<a id="cite-questinstance-a4c334-5"></a>QuestInstance directement compatible avec ton
<a id="cite-questpool-43825e-4"></a>QuestPool


**ChatGPT:**
Voici une implémentation **GDScript (Godot 4)** en 3 blocs :


1) `update_arc_state()` (compact, avec lock + compteurs phase)

2) `build_arc_context()` (context standard)

3) `ArcOfferFactory.spawn_offer_for_pair()` (retourne une `QuestInstance` “offer” compatible QuestPool)


>
> Hypothèses minimales :
>
>
> * `QuestInstance.new(template, context)` existe
> * `QuestTemplate.new()` existe (Resource) **ou** tu remplaceras `_build_template_fallback()` par ton générateur existant.
> * `ArcDecisionUtil` contient les StringNames d’actions (`ARC_RAID`, etc.) comme on avait défini.
>
>
>


---


## 1) `ArcStateMachine.gd` — update\_arc\_state + build\_arc\_context


```
# ArcStateMachine.gd

class\_name ArcStateMachine
extends RefCounted

# --- Arc states ---

const S\_NEUTRAL: StringName = &"NEUTRAL"
const S\_RIVALRY: StringName = &"RIVALRY"
const S\_CONFLICT: StringName = &"CONFLICT"
const S\_WAR: StringName = &"WAR"
const S\_TRUCE: StringName = &"TRUCE"
const S\_ALLIANCE: StringName = &"ALLIANCE"
const S\_MERGED: StringName = &"MERGED"
const S\_EXTINCT: StringName = &"EXTINCT"

static func is\_hostile\_action(action: StringName) -> bool:
 return action == ArcDecisionUtil.ARC\_RAID \
 or action == ArcDecisionUtil.ARC\_SABOTAGE \
 or action == ArcDecisionUtil.ARC\_DECLARE\_WAR \
 or action == ArcDecisionUtil.ARC\_ULTIMATUM

static func is\_peace\_action(action: StringName) -> bool:
 return action == ArcDecisionUtil.ARC\_TRUCE\_TALKS \
 or action == ArcDecisionUtil.ARC\_REPARATIONS \
 or action == ArcDecisionUtil.ARC\_ALLIANCE\_OFFER

static func pair\_means(rel\_ab: FactionRelationScore, rel\_ba: FactionRelationScore) -> Dictionary:
 return {
 "rel": 0.5 * (float(rel\_ab.relation) + float(rel\_ba.relation)),
 "trust": 0.5 * (float(rel\_ab.trust) + float(rel\_ba.trust)),
 "tension": 0.5 * (rel\_ab.tension + rel\_ba.tension),
 "griev": 0.5 * (rel\_ab.grievance + rel\_ba.grievance),
 "wear": 0.5 * (rel\_ab.weariness + rel\_ba.weariness),
 }

static func \_lock\_days\_for\_state(state: StringName, rng: RandomNumberGenerator) -> int:
 match state:
 S\_WAR: return rng.randi\_range(10, 20)
 S\_TRUCE: return rng.randi\_range(6, 12)
 S\_ALLIANCE: return rng.randi\_range(12, 25)
 S\_RIVALRY: return rng.randi\_range(4, 9)
 S\_CONFLICT: return rng.randi\_range(6, 12)
 \_: return rng.randi\_range(3, 7)

static func \_reset\_phase(arc\_state: ArcState) -> void:
 arc\_state.phase\_hostile = 0
 arc\_state.phase\_peace = 0
 arc\_state.phase\_events = 0
 arc\_state.entered\_day = arc\_state.last\_event\_day

static func \_enter\_state(arc\_state: ArcState, new\_state: StringName, day: int, rng: RandomNumberGenerator) -> void:
 arc\_state.state = new\_state
 arc\_state.entered\_day = day
 arc\_state.lock\_until\_day = day + \_lock\_days\_for\_state(new\_state, rng)
 arc\_state.phase\_hostile = 0
 arc\_state.phase\_peace = 0
 arc\_state.phase\_events = 0

# -------------------------------------------------------------------

# update\_arc\_state() (compact)

# Appelé APRÈS résolution d’un event (donc on connaît last\_action/choice)

# -------------------------------------------------------------------

static func update\_arc\_state(
 arc\_state: ArcState,
 rel\_ab: FactionRelationScore,
 rel\_ba: FactionRelationScore,
 day: int,
 rng: RandomNumberGenerator,
 last\_action: StringName = &"",
 last\_choice: StringName = &"" # ArcEffectTable.CHOICE\_...
) -> bool:
 # returns true if state changed
 if arc\_state.state == S\_MERGED or arc\_state.state == S\_EXTINCT:
 return false

 arc\_state.last\_event\_day = day
 arc\_state.last\_action = last\_action
 arc\_state.phase\_events += 1

 if is\_hostile\_action(last\_action):
 arc\_state.phase\_hostile += 1
 elif is\_peace\_action(last\_action):
 arc\_state.phase\_peace += 1

 var m := pair\_means(rel\_ab, rel\_ba)
 var rel\_mean := float(m["rel"])
 var trust\_mean := float(m["trust"])
 var tension\_mean := float(m["tension"])
 var griev\_mean := float(m["griev"])
 var wear\_mean := float(m["wear"])

# Thresholds (tunable)

 var t\_high := 70.0
 var t\_med := 50.0
 var t\_low := 25.0
 var rel\_bad := -55.0
 var rel\_hate := -70.0
 var rel\_good := 35.0
 var trust\_good := 55.0
 var griev\_high := 60.0
 var wear\_high := 65.0

 var prev := arc\_state.state
 var locked := arc\_state.is\_locked(day)

 match arc\_state.state:
 S\_NEUTRAL:
 if not locked and (tension\_mean >= t\_med or rel\_mean <= rel\_bad or is\_hostile\_action(last\_action)):
 \_enter\_state(arc\_state, S\_RIVALRY, day, rng)

 S\_RIVALRY:
 if not locked:
 if tension\_mean >= t\_high or arc\_state.phase\_hostile >= 3:
 if wear\_mean < wear\_high:
 \_enter\_state(arc\_state, S\_CONFLICT, day, rng)
 else:
 \_enter\_state(arc\_state, S\_TRUCE, day, rng)
 elif tension\_mean <= t\_low and griev\_mean <= 20.0 and arc\_state.phase\_peace >= 1:
 \_enter\_state(arc\_state, S\_NEUTRAL, day, rng)

 S\_CONFLICT:
 if not locked:
 if (rel\_mean <= rel\_hate and tension\_mean >= t\_high) or (last\_action == ArcDecisionUtil.ARC\_DECLARE\_WAR and last\_choice == ArcEffectTable.CHOICE\_LOYAL):
 \_enter\_state(arc\_state, S\_WAR, day, rng)
 elif arc\_state.phase\_peace >= 2 or (tension\_mean <= t\_med and griev\_mean <= griev\_high):
 \_enter\_state(arc\_state, S\_TRUCE, day, rng)

 S\_WAR:
 # War => sortie surtout via usure ou actions de paix répétées
 if not locked:
 if wear\_mean >= wear\_high or arc\_state.phase\_peace >= 2:
 \_enter\_state(arc\_state, S\_TRUCE, day, rng)

 S\_TRUCE:
 if not locked:
 if trust\_mean >= trust\_good and rel\_mean >= rel\_good and tension\_mean <= t\_low:
 \_enter\_state(arc\_state, S\_ALLIANCE, day, rng)
 elif tension\_mean >= t\_med and arc\_state.phase\_hostile >= 2:
 \_enter\_state(arc\_state, S\_CONFLICT, day, rng)
 elif tension\_mean <= t\_low and griev\_mean <= 15.0 and arc\_state.phase\_peace >= 2:
 \_enter\_state(arc\_state, S\_NEUTRAL, day, rng)

 S\_ALLIANCE:
 if not locked:
 # Rare merge gate (à renforcer avec des conditions monde si besoin)
 if trust\_mean >= 75.0 and rel\_mean >= 60.0 and tension\_mean <= 15.0 and arc\_state.phase\_peace >= 2:
 \_enter\_state(arc\_state, S\_MERGED, day, rng)

# Backslide

 elif tension\_mean >= t\_med and (arc\_state.phase\_hostile >= 2 or is\_hostile\_action(last\_action)):
 \_enter\_state(arc\_state, S\_RIVALRY, day, rng)

 \_:
 pass

 return arc\_state.state != prev


# -------------------------------------------------------------------

# build\_arc\_context() standard

# -------------------------------------------------------------------

static func build\_arc\_context(
 arc\_id: StringName,
 arc\_state: ArcState,
 giver\_id: StringName,
 ant\_id: StringName,
 action: StringName,
 day: int,
 deadline\_days: int,
 stakes: Dictionary,
 seed: int
) -> Dictionary:
 var pair\_key := arc\_state.a\_id
 if String(arc\_state.a\_id) <= String(arc\_state.b\_id):
 pair\_key = StringName(String(arc\_state.a\_id) + "|" + String(arc\_state.b\_id))
 else:
 pair\_key = StringName(String(arc\_state.b\_id) + "|" + String(arc\_state.a\_id))

 return {
 "is\_arc\_rivalry": true,
 "arc\_id": arc\_id,
 "arc\_state": arc\_state.state,
 "arc\_action\_type": action,

 "giver\_faction\_id": giver\_id,
 "antagonist\_faction\_id": ant\_id,

 "pair\_key": pair\_key,
 "created\_day": day,
 "deadline\_days": deadline\_days,

 "stakes": stakes,
 "seed": seed,
 }
```


---


## 2) `ArcOfferFactory.gd` — spawn\_offer\_for\_pair() → QuestInstance(AVAILABLE)


```
# ArcOfferFactory.gd

class\_name ArcOfferFactory
extends RefCounted

# action -> weighted offer specs

const ARC\_OFFERS: Dictionary = {
 &"arc.raid": [
 {"tag": "combat.raid\_camp", "w": 50, "deadline": 6, "ctx": {"domain":"combat"}},
 {"tag": "stealth.burn\_supplies", "w": 25, "deadline": 5, "ctx": {"domain":"stealth"}},
 {"tag": "logistics.intercept", "w": 25, "deadline": 7, "ctx": {"domain":"logistics"}},
 ],
 &"arc.sabotage": [
 {"tag": "stealth.sabotage\_site", "w": 55, "deadline": 7, "ctx": {"domain":"stealth"}},
 {"tag": "diplo.frame\_agent", "w": 20, "deadline": 6, "ctx": {"domain":"diplo"}},
 {"tag": "combat.assassinate", "w": 25, "deadline": 8, "ctx": {"domain":"combat"}},
 ],
 &"arc.ultimatum": [
 {"tag": "diplo.deliver\_terms", "w": 55, "deadline": 5, "ctx": {"domain":"diplo"}},
 {"tag": "combat.show\_of\_force", "w": 25, "deadline": 6, "ctx": {"domain":"combat"}},
 {"tag": "logistics.seize\_toll", "w": 20, "deadline": 6, "ctx": {"domain":"logistics"}},
 ],
 &"arc.truce\_talks": [
 {"tag": "diplo.secure\_venue", "w": 45, "deadline": 6, "ctx": {"domain":"diplo"}},
 {"tag": "combat.protect\_envoy", "w": 30, "deadline": 6, "ctx": {"domain":"combat"}},
 {"tag": "stealth.remove\_spoiler", "w": 25, "deadline": 7, "ctx": {"domain":"stealth"}},
 ],
 &"arc.reparations": [
 {"tag": "logistics.deliver\_goods", "w": 45, "deadline": 8, "ctx": {"domain":"logistics"}},
 {"tag": "diplo.audit\_treaty", "w": 35, "deadline": 7, "ctx": {"domain":"diplo"}},
 {"tag": "combat.guard\_caravan", "w": 20, "deadline": 7, "ctx": {"domain":"combat"}},
 ],
 &"arc.declare\_war": [
 {"tag": "combat.capture\_outpost", "w": 45, "deadline": 10, "ctx": {"domain":"combat"}},
 {"tag": "logistics.mobilize", "w": 30, "deadline": 9, "ctx": {"domain":"logistics"}},
 {"tag": "stealth.break\_alliance", "w": 25, "deadline": 9, "ctx": {"domain":"stealth"}},
 ],
 &"arc.alliance\_offer": [
 {"tag": "diplo.sign\_pact", "w": 45, "deadline": 8, "ctx": {"domain":"diplo"}},
 {"tag": "combat.joint\_operation", "w": 35, "deadline": 9, "ctx": {"domain":"combat"}},
 {"tag": "logistics.exchange\_aid", "w": 20, "deadline": 8, "ctx": {"domain":"logistics"}},
 ],
}

static func \_pick\_offer\_spec(action: StringName, rng: RandomNumberGenerator) -> Dictionary:
 var arr: Array = ARC\_OFFERS.get(action, [])
 if arr.is\_empty():
 return {}
 var sum := 0
 for s in arr:
 sum += int(s["w"])
 var r := rng.randi\_range(1, max(1, sum))
 var acc := 0
 for s in arr:
 acc += int(s["w"])
 if r <= acc:
 return s
 return arr.back()

static func \_build\_stakes(rel\_ab: FactionRelationScore, action: StringName, domain: String) -> Dictionary:
 # Stakes “light” (UI/preview + génération)
 var risk := clampf(0.25 + 0.007 * rel\_ab.tension + 0.006 * rel\_ab.grievance, 0.1, 0.95)
 var gold := 40 + int(rel\_ab.tension * 1.2)

# simple, à adapter

 var hint := 0
 if action == ArcDecisionUtil.ARC\_TRUCE\_TALKS or action == ArcDecisionUtil.ARC\_REPARATIONS:
 hint = +8
 elif action == ArcDecisionUtil.ARC\_RAID or action == ArcDecisionUtil.ARC\_SABOTAGE:
 hint = -8
 elif action == ArcDecisionUtil.ARC\_DECLARE\_WAR:
 hint = -12
 return {"gold": gold, "risk": risk, "domain": domain, "relation\_delta\_hint": hint}

static func \_build\_template\_fallback(tag: String, action: StringName, tier: int) -> QuestTemplate:
 # Fallback si tu n'as pas ton QuestGenerator branché ici.
 # Remplace ça par ton create\_dynamic\_template(tag, params) si tu veux.
 var t := QuestTemplate.new()
 t.id = StringName("arc\_" + tag)

# à adapter si ton id est String

 t.title = "Arc: " + tag
 t.description = "Arc offer (" + String(action) + ")"
 t.category = "ARC"
 t.tier = tier
 t.objective\_type = "GENERIC"
 t.objective\_target = tag
 t.objective\_count = 1
 t.expires\_in\_days = 7
 return t

# -------------------------------------------------------------------

# spawn\_offer\_for\_pair() -> QuestInstance AVAILABLE compatible QuestPool

# -------------------------------------------------------------------

static func spawn\_offer\_for\_pair(
 arc\_id: StringName,
 arc\_state: ArcState,
 giver\_id: StringName,
 ant\_id: StringName,
 action: StringName,
 rel\_ab: FactionRelationScore, # giver -> antagonist (pour stakes)
 faction\_profiles: Dictionary, # optionnel si tu veux enrichir
 rng: RandomNumberGenerator,
 day: int,
 tier: int = 1,
 params: Dictionary = {}
) -> QuestInstance:
 var spec := \_pick\_offer\_spec(action, rng)
 if spec.is\_empty():
 return null

 var tag: String = String(spec["tag"])
 var deadline\_days: int = int(spec.get("deadline", 7))
 var extra\_ctx: Dictionary = Dictionary(spec.get("ctx", {}))
 var domain: String = String(extra\_ctx.get("domain", "combat"))

 var stakes := \_build\_stakes(rel\_ab, action, domain)
 var seed := rng.randi()

# standard context

 var ctx := ArcStateMachine.build\_arc\_context(
 arc\_id, arc\_state, giver\_id, ant\_id, action, day, deadline\_days, stakes, seed
 )

# merge extra ctx

 for k in extra\_ctx.keys():
 ctx[k] = extra\_ctx[k]

 # template: try your generator if present, else fallback
 var template: QuestTemplate = null
 if Engine.has\_singleton("QuestGeneratorRunner"):
 var qg = Engine.get\_singleton("QuestGeneratorRunner")

# adapte le nom de méthode à ton projet si besoin

 if qg != null and qg.has\_method("create\_dynamic\_template\_from\_tag"):
 template = qg.create\_dynamic\_template\_from\_tag(tag, tier, ctx)
 elif qg != null and qg.has\_method("\_create\_dynamic\_template"):
 # si tu fais plutôt \_create\_dynamic\_template(quest\_type, params)
 template = qg.\_create\_dynamic\_template(tag, {"tier": tier})
 if template == null:
 template = \_build\_template\_fallback(tag, action, tier)

# instance offer

 var inst := QuestInstance.new(template, ctx)
 inst.status = QuestInstance.STATUS\_AVAILABLE if "STATUS\_AVAILABLE" in QuestInstance else "AVAILABLE"
 inst.started\_on\_day = day
 inst.expires\_on\_day = day + deadline\_days
 inst.progress = 0

 return inst
```


---


## 3) Exemple d’utilisation dans ton ArcManager (tick)


```
# après avoir décidé action\_type pour giver\_id -> ant\_id :

var inst := ArcOfferFactory.spawn\_offer\_for\_pair(
 arc\_id, pair\_arc\_state,
 giver\_id, ant\_id,
 action\_type,
 relations[giver\_id][ant\_id], # rel\_ab
 faction\_profiles,
 \_rng, day,
 1 # tier
)

if inst != null:
 QuestPool.try\_add\_offer(inst)

# ou QuestOfferSimRunner.try\_add\_offer(inst)

```


Et **à la résolution** (QuestManager → ArcManager), après `apply_arc_resolution_event(...)` :


```
ArcStateMachine.update\_arc\_state(
 pair\_arc\_state,
 relations[a][b],
 relations[b][a],
 day, \_rng,
 action\_type,
 choice
)
```


---


Si tu veux, prochaine brique logique : un `ArcOfferBudget` (budget/semaine par faction + cap par paire + cap par état) pour éviter le spam, et qui choisit aussi le **tier** de l’offre selon `state` (WAR → tier plus élevé, RIVALRY → tier faible).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-32"></a>
**Moi 32:**
Il faut prendre aussi en compte les recompenses, plus la mission est difficile, plus elle coute cher, il fzut que la faction ai l'or pour payer


**ChatGPT:**
Oui — si la faction “giver” finance l’offre, il faut un **modèle d’économie** (trésor + réservations) et un **prix** lié à la difficulté. Sinon tu vas générer des offers “gratuites” qui cassent la cohérence.


Voici une implémentation simple (et robuste) qui s’intègre bien à ton système.


---


## 1) Données côté faction : trésor + escrow


```
# FactionEconomy.gd

class\_name FactionEconomy
extends RefCounted

var gold: int = 0
var reserved\_by\_quest: Dictionary[StringName, int] = {} # runtime\_id -> amount

func available\_gold() -> int:
 var reserved := 0
 for k in reserved\_by\_quest.keys():
 reserved += int(reserved\_by\_quest[k])
 return gold - reserved

func can\_reserve(amount: int) -> bool:
 return amount > 0 and available\_gold() >= amount

func reserve\_for\_quest(quest\_runtime\_id: StringName, amount: int) -> bool:
 if not can\_reserve(amount):
 return false
 reserved\_by\_quest[quest\_runtime\_id] = amount
 return true

func release\_reservation(quest\_runtime\_id: StringName) -> void:
 reserved\_by\_quest.erase(quest\_runtime\_id)

func payout\_reserved(quest\_runtime\_id: StringName, amount\_override: int = -1) -> int:
 # Déduit réellement l’or du trésor, en consommant la réservation.
 var reserved := int(reserved\_by\_quest.get(quest\_runtime\_id, 0))
 var amount := reserved if amount\_override < 0 else min(reserved, amount\_override)
 if amount <= 0:
 return 0
 gold -= amount
 reserved\_by\_quest.erase(quest\_runtime\_id)
 return amount
```


---


## 2) Prix / récompense = fonction de difficulté


### Heuristique de difficulté (compacte)


On réutilise tes signaux : tension, grievance, état (WAR etc.), tier, “risk”.


```
static func compute\_difficulty(
 arc\_state\_name: StringName,
 rel\_ab: FactionRelationScore,
 risk: float,
 tier: int
) -> float:
 var state\_factor := 0.0
 match arc\_state\_name:
 &"RIVALRY": state\_factor = 0.20
 &"CONFLICT": state\_factor = 0.45
 &"WAR": state\_factor = 0.70
 &"TRUCE": state\_factor = 0.25
 &"ALLIANCE": state\_factor = 0.20
 \_: state\_factor = 0.15

 var t := rel\_ab.tension / 100.0
 var g := rel\_ab.grievance / 100.0
 var tier\_factor := clampf(0.15 * float(max(tier - 1, 0)), 0.0, 0.45)

# 0..~1.6 → clamp à 0..1

 var d := 0.35*risk + 0.30*t + 0.20*g + 0.15*state\_factor + tier\_factor
 return clampf(d, 0.0, 1.0)
```


### Récompense (gold) dérivée de la difficulté


```
static func compute\_reward\_gold(tier: int, difficulty: float, domain: String) -> int:
 var base := 40 + 35 * tier # simple, monte vite
 # domain modifier (optionnel)
 var dom\_mul := 1.0
 if domain == "combat":
 dom\_mul = 1.10
 elif domain == "stealth":
 dom\_mul = 1.00
 elif domain == "diplo":
 dom\_mul = 0.95
 elif domain == "logistics":
 dom\_mul = 1.00

 var reward := float(base) * dom\_mul * (1.0 + 1.35*difficulty)
 return int(round(reward))
```


---


## 3) Modification ArcOfferFactory : ne spawn que si la faction peut payer


Tu ajoutes `faction_economies: Dictionary[StringName, FactionEconomy]` et tu réserves l’or dès la création de l’offre (escrow).


```
static func spawn\_offer\_for\_pair(
 arc\_id: StringName,
 arc\_state: ArcState,
 giver\_id: StringName,
 ant\_id: StringName,
 action: StringName,
 rel\_ab: FactionRelationScore,
 faction\_profiles: Dictionary,
 faction\_economies: Dictionary, # <-- NEW
 rng: RandomNumberGenerator,
 day: int,
 tier: int = 1
) -> QuestInstance:
 var econ: FactionEconomy = faction\_economies.get(giver\_id, null)
 if econ == null:
 return null

 var spec := \_pick\_offer\_spec(action, rng)
 if spec.is\_empty():
 return null

 var tag: String = String(spec["tag"])
 var deadline\_days: int = int(spec.get("deadline", 7))
 var extra\_ctx: Dictionary = Dictionary(spec.get("ctx", {}))
 var domain: String = String(extra\_ctx.get("domain", "combat"))

# Stakes/risk

 var risk := clampf(0.25 + 0.007 * rel\_ab.tension + 0.006 * rel\_ab.grievance, 0.1, 0.95)

# Difficulty -> reward

 var difficulty := compute\_difficulty(arc\_state.state, rel\_ab, risk, tier)
 var reward\_gold := compute\_reward\_gold(tier, difficulty, domain)

# Budget check (escrow)

 if not econ.can\_reserve(reward\_gold):
 return null

 var stakes := {
 "gold": reward\_gold,
 "risk": risk,
 "domain": domain,
 "difficulty": difficulty
 }

 var ctx := ArcStateMachine.build\_arc\_context(
 arc\_id, arc\_state, giver\_id, ant\_id, action, day, deadline\_days, stakes, rng.randi()
 )
 for k in extra\_ctx.keys():
 ctx[k] = extra\_ctx[k]

 # Template
 var template: QuestTemplate = \_build\_template\_fallback(tag, action, tier)

# Instance

 var inst := QuestInstance.new(template, ctx)
 inst.status = "AVAILABLE"
 inst.started\_on\_day = day
 inst.expires\_on\_day = day + deadline\_days
 inst.progress = 0

 # Reserve AFTER runtime\_id is known
 var qid: StringName = StringName(inst.runtime\_id)
 if not econ.reserve\_for\_quest(qid, reward\_gold):
 return null

 # Persist escrow info in context
 inst.context["reward\_gold"] = reward\_gold
 inst.context["escrow\_gold"] = reward\_gold
 inst.context["escrow\_faction\_id"] = giver\_id

 return inst
```


---


## 4) Où libérer / payer l’escrow


### A) Offer expirée / supprimée du pool


Quand `QuestPool` retire une offer (expired/invalid), tu fais :


```
var giver\_id: StringName = inst.context.get("escrow\_faction\_id", &"")
var econ: FactionEconomy = faction\_economies.get(giver\_id, null)
if econ != null:
 econ.release\_reservation(StringName(inst.runtime\_id))
```


### B) Quête complétée (QuestManager.resolve\_quest)


Au moment où tu attribues les récompenses :


```
var giver\_id: StringName = inst.context.get("escrow\_faction\_id", &"")
var reward: int = int(inst.context.get("reward\_gold", 0))
var econ: FactionEconomy = faction\_economies.get(giver\_id, null)
if econ != null:
 var paid := econ.payout\_reserved(StringName(inst.runtime\_id))

# puis tu crédites le joueur / hero avec "paid"

```


Et si tu veux gérer LOYAL/NEUTRAL/TRAITOR :


* LOYAL : `paid = 100%`
* NEUTRAL : `paid = 70%` (le reste rendu à la faction → tu peux faire `econ.release + econ.payout_override`)
* TRAITOR : `paid = 0–30%` (ou confiscation / pénalité réputation)


---


## Ce que ça apporte immédiatement


* Les offres sont **économiquement plausibles**.
* Une faction pauvre **ne spamme pas**.
* Les quêtes “WAR / high tension” deviennent naturellement **plus rémunératrices** donc plus rares.
* Et ton ArcManager a un vrai levier : “peut-on financer l’action ?” → sinon il sélectionne une action moins chère / une autre cible.


Si tu veux, prochaine brique utile : un `ArcOfferBudget` (budget/jour + plafond escrow total) pour éviter qu’une faction riche bloque tout son or dans des offers simultanées.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-33"></a>
**Moi 33:**
Ok


**ChatGPT:**
Parfait.


Prochaines étapes “concrètes” pour que ça tourne en vrai jeu :


1) **Ajouter `FactionEconomy` au monde**


* `economy_by_faction_id[giver_id] = FactionEconomy.new()`
* init `gold` (fixe, ou dérivé du tier/poids de faction).


2) **Brancher l’escrow dans le lifecycle des quêtes**


* **À la création d’une offer** : `reserve_for_quest(runtime_id, reward_gold)` (déjà dans `spawn_offer_for_pair`)
* **À l’expiration / suppression d’une offer** (QuestPool) : `release_reservation(runtime_id)`
* **À la complétion** (QuestManager.resolve) : `payout_reserved(runtime_id)` puis payer le joueur/héros
* **À l’échec** : soit remboursement (release) soit pénalité (payout partiel) selon design.


3) **Optionnel mais recommandé : fallback d’action si pas assez d’or**


* si `spawn_offer_for_pair()` retourne `null`, ArcManager tente un `arc_action_type` moins cher (ex: `ultimatum` → `raid` → `ignore`) ou baisse `tier`.


4) **Étendre Test 3**


* ajouter des trésors initiaux,
* vérifier qu’on ne génère pas d’offres quand `available_gold < reward`,
* vérifier que l’escrow revient bien à 0 après expiration/resolve.


Quand tu veux, je te donne le patch exact pour :


* `QuestPool.remove_expired_offers()` (release escrow),
* `QuestManager.resolve_quest()` (payout escrow + variations LOYAL/NEUTRAL/TRAITOR),
* et une version du **Test 3 logged** qui inclut la colonne `giver_gold_before/after` + `escrow_before/after` dans le CSV.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-34"></a>
**Moi 34:**
Non, on fait

2) Des “conditions de fin” + “cooldown long” d’arc


Tu as cap/cooldown par évènement, mais il faut aussi une règle de fin :


Rivalité se termine si tension\_mean < X pendant Y jours,


ou si trust\_mean > X et relation\_mean > X,


ou si guerre déclarée → on passe en état WAR et on stoppe certains arcs “mineurs”.

Et surtout un pair\_lock\_days (genre 15–40 jours) après résolution d’un arc majeur (trêve, alliance, fusion), sinon tu “re-rentres” tout de suite en incident.


Mais je crois qu'on l'a deja dans ce que tu viens de faire non?


**ChatGPT:**
On l’a **en grande partie**, oui — mais pas totalement “au niveau prod” tel que tu l’as formulé.


### Ce qu’on a déjà dans le code


* **Cooldown court par évènement** : via `FactionRelationScore.set_cooldown()` (ex: 5–12 jours).
* **Pair lock** (verrou long) : via `ArcState.lock_until_day` + `_lock_days_for_state()`
	+ WAR / TRUCE / ALLIANCE ont déjà des locks plus longs.
* **Conditions de fin / sortie d’état** :
	+ `RIVALRY → NEUTRAL` si `tension_mean <= t_low` + `griev` bas + `phase_peace >= 1`
	+ `TRUCE → NEUTRAL`, `TRUCE → ALLIANCE`, etc.
* **Guerre déclarée stoppe les arcs “mineurs”** : implicite, parce qu’on passe en `WAR` et les prochaines actions seront filtrées par l’état (si tu le fais côté sélection d’actions/offers).


### Ce qui manque (ou est encore trop approximatif)


1) **“tension\_mean < X pendant Y jours”**

 Dans notre `update_arc_state()`, on a un check instantané + compteur `phase_peace`, mais pas un vrai *timer de stabilité*.


* Si tu veux “pendant Y jours”, il faut un compteur dédié, typiquement :
	+ `stable_low_tension_days`
	+ `stable_high_trust_days`
* Sinon un seul bon jour peut clôturer trop vite.


2) **Locks longs 15–40 jours après un évènement MAJEUR (trêve/alliance/fusion)**

 On a des locks (ex: TRUCE 6–12, ALLIANCE 12–25), mais pas un **lock encore plus long** déclenché par *certains événements/choix* (ex: “signature de traité” ou “fusion”).


* Tu veux un `pair_lock_days` post-évènement majeur, qui peut être **indépendant de l’état**.


3) **Stopper les arcs mineurs en WAR**

 C’est mieux si c’est explicite : en `WAR`, on n’autorise que certains `arc_action_type` et certaines offers.


---


## Patch compact pour compléter exactement ta spec


### A) Ajoute des compteurs “stabilité” dans `ArcState`


```
# dans ArcState

var stable\_low\_tension\_days: int = 0
var stable\_high\_trust\_days: int = 0
```


### B) Mets à jour ces compteurs chaque jour (ou à chaque event)


Idéal : 1 fois par jour dans le tick pair, même sans event.

Mais version compacte “à chaque update\_arc\_state” :


```
# après calcul des means

if tension\_mean <= 25.0:
 arc\_state.stable\_low\_tension\_days += 1
else:
 arc\_state.stable\_low\_tension\_days = 0

if trust\_mean >= 55.0 and rel\_mean >= 35.0:
 arc\_state.stable\_high\_trust\_days += 1
else:
 arc\_state.stable\_high\_trust\_days = 0
```


### C) Utilise Y jours pour terminer la rivalité / trêve


```
var Y := 7 # tunable

# RIVALRY -> NEUTRAL

if arc\_state.stable\_low\_tension\_days >= Y:
 \_enter\_state(arc\_state, S\_NEUTRAL, day, rng)

# TRUCE -> NEUTRAL (plus rapide) ou TRUCE -> ALLIANCE

if arc\_state.stable\_low\_tension\_days >= Y and griev\_mean <= 15.0:
 \_enter\_state(arc\_state, S\_NEUTRAL, day, rng)

if arc\_state.stable\_high\_trust\_days >= Y and tension\_mean <= 25.0:
 \_enter\_state(arc\_state, S\_ALLIANCE, day, rng)
```


### D) Pair lock long déclenché par évènement majeur


Ajoute une fonction :


```
static func apply\_major\_pair\_lock(arc\_state: ArcState, day: int, rng: RandomNumberGenerator, min\_d := 15, max\_d := 40) -> void:
 arc\_state.lock\_until\_day = max(arc\_state.lock\_until\_day, day + rng.randi\_range(min\_d, max\_d))
```


Et appelle-la quand tu résous un “évènement majeur”, par exemple :


* `arc.truce_talks` résolu LOYAL
* `arc.alliance_offer` résolu LOYAL
* état devient `MERGED`


Dans `update_arc_state`, juste avant de changer d’état ou juste après :


```
if last\_action == ArcDecisionUtil.ARC\_TRUCE\_TALKS and last\_choice == ArcEffectTable.CHOICE\_LOYAL:
 apply\_major\_pair\_lock(arc\_state, day, rng)

if last\_action == ArcDecisionUtil.ARC\_ALLIANCE\_OFFER and last\_choice == ArcEffectTable.CHOICE\_LOYAL:
 apply\_major\_pair\_lock(arc\_state, day, rng, 20, 50)

if arc\_state.state == S\_MERGED:
 apply\_major\_pair\_lock(arc\_state, day, rng, 9999, 9999)

# terminal

```


### E) Stopper explicitement les arcs mineurs en WAR


Dans ta sélection d’actions/offers, impose :


```
if arc\_state.state == S\_WAR:
 allowed = [ARC\_RAID, ARC\_SABOTAGE, ARC\_DECLARE\_WAR] # ou tes actions “war-only”
else:
 allowed = [...]
```


---


## Conclusion


* **Oui**, la direction est déjà là (locks + transitions).
* **Non**, il manque encore les deux éléments précis de ta spec :

**(1) “pendant Y jours”** (stabilité) et **(2) pair\_lock long déclenché par événement majeur** (15–40j).


Si tu veux, je te renvoie `update_arc_state()` avec ces ajouts intégrés proprement (toujours compact), sans te redonner tout le fichier.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-35"></a>
**Moi 35:**
Oui envoi


**ChatGPT:**
Voici une version **compacte** de `update_arc_state()` **avec** :


* compteurs de stabilité “**pendant Y jours**” (tension basse / confiance haute),
* **pair\_lock long** (15–40 jours) déclenché par **événements majeurs**,
* transitions identiques à ce qu’on avait, mais avec “fin” plus robuste.


>
> À intégrer dans `ArcStateMachine.gd`.
>
>  Pré-requis : dans `ArcState`, ajoute :
>
>
>
>
>
> ```
> var stable\_low\_tension\_days: int = 0
> var stable\_high\_trust\_days: int = 0
> ```
>
>
>
>


---


```
static func apply\_major\_pair\_lock(
 arc\_state: ArcState,
 day: int,
 rng: RandomNumberGenerator,
 min\_d: int = 15,
 max\_d: int = 40
) -> void:
 arc\_state.lock\_until\_day = max(arc\_state.lock\_until\_day, day + rng.randi\_range(min\_d, max\_d))


static func update\_arc\_state(
 arc\_state: ArcState,
 rel\_ab: FactionRelationScore,
 rel\_ba: FactionRelationScore,
 day: int,
 rng: RandomNumberGenerator,
 last\_action: StringName = &"",
 last\_choice: StringName = &""
) -> bool:
 if arc\_state.state == S\_MERGED or arc\_state.state == S\_EXTINCT:
 return false

 arc\_state.last\_event\_day = day
 arc\_state.last\_action = last\_action
 arc\_state.phase\_events += 1

 if is\_hostile\_action(last\_action):
 arc\_state.phase\_hostile += 1
 elif is\_peace\_action(last\_action):
 arc\_state.phase\_peace += 1

 var m := pair\_means(rel\_ab, rel\_ba)
 var rel\_mean := float(m["rel"])
 var trust\_mean := float(m["trust"])
 var tension\_mean := float(m["tension"])
 var griev\_mean := float(m["griev"])
 var wear\_mean := float(m["wear"])

# Thresholds (tunable)

 var t\_high := 70.0
 var t\_med := 50.0
 var t\_low := 25.0
 var rel\_bad := -55.0
 var rel\_hate := -70.0
 var rel\_good := 35.0
 var trust\_good := 55.0
 var griev\_high := 60.0
 var wear\_high := 65.0

 # "Pendant Y jours"
 var Y\_low\_tension := 7
 var Y\_high\_trust := 7

 # --- Stability counters update (ideally daily tick; ok here too) ---
 if tension\_mean <= t\_low:
 arc\_state.stable\_low\_tension\_days += 1
 else:
 arc\_state.stable\_low\_tension\_days = 0

 if trust\_mean >= trust\_good and rel\_mean >= rel\_good:
 arc\_state.stable\_high\_trust\_days += 1
 else:
 arc\_state.stable\_high\_trust\_days = 0

 # --- Major event locks (post-major resolution) ---
 # Trêve réussie => verrou long pour éviter re-trigger immédiat
 if last\_action == ArcDecisionUtil.ARC\_TRUCE\_TALKS and last\_choice == ArcEffectTable.CHOICE\_LOYAL:
 apply\_major\_pair\_lock(arc\_state, day, rng, 15, 40)

# Alliance signée => encore plus long

 if last\_action == ArcDecisionUtil.ARC\_ALLIANCE\_OFFER and last\_choice == ArcEffectTable.CHOICE\_LOYAL:
 apply\_major\_pair\_lock(arc\_state, day, rng, 20, 50)

# Déclaration de guerre LOYAL => lock WAR plus long (optionnel)

 if last\_action == ArcDecisionUtil.ARC\_DECLARE\_WAR and last\_choice == ArcEffectTable.CHOICE\_LOYAL:
 apply\_major\_pair\_lock(arc\_state, day, rng, 10, 25)

 var prev := arc\_state.state
 var locked := arc\_state.is\_locked(day)

 match arc\_state.state:
 S\_NEUTRAL:
 if not locked and (tension\_mean >= t\_med or rel\_mean <= rel\_bad or is\_hostile\_action(last\_action)):
 \_enter\_state(arc\_state, S\_RIVALRY, day, rng)

 S\_RIVALRY:
 # Fin propre: tension basse PENDANT Y jours
 if arc\_state.stable\_low\_tension\_days >= Y\_low\_tension and griev\_mean <= 20.0:
 \_enter\_state(arc\_state, S\_NEUTRAL, day, rng)
 elif not locked:
 if (tension\_mean >= t\_high or arc\_state.phase\_hostile >= 3):
 if wear\_mean < wear\_high:
 \_enter\_state(arc\_state, S\_CONFLICT, day, rng)
 else:
 \_enter\_state(arc\_state, S\_TRUCE, day, rng)

 S\_CONFLICT:
 if not locked:
 # Escalade vers WAR
 if (rel\_mean <= rel\_hate and tension\_mean >= t\_high) \
 or (last\_action == ArcDecisionUtil.ARC\_DECLARE\_WAR and last\_choice == ArcEffectTable.CHOICE\_LOYAL):
 \_enter\_state(arc\_state, S\_WAR, day, rng)

# Désescalade vers TRUCE

 elif arc\_state.phase\_peace >= 2 or (tension\_mean <= t\_med and griev\_mean <= griev\_high):
 \_enter\_state(arc\_state, S\_TRUCE, day, rng)

 S\_WAR:
 # Sortie de WAR: usure ou paix répétée (et pas locked)
 if not locked:
 if wear\_mean >= wear\_high or arc\_state.phase\_peace >= 2:
 \_enter\_state(arc\_state, S\_TRUCE, day, rng)

 S\_TRUCE:
 # TRUCE peut finir (NEUTRAL) ou monter (ALLIANCE) via stabilité
 if arc\_state.stable\_high\_trust\_days >= Y\_high\_trust and tension\_mean <= t\_low:
 \_enter\_state(arc\_state, S\_ALLIANCE, day, rng)
 elif arc\_state.stable\_low\_tension\_days >= Y\_low\_tension and griev\_mean <= 15.0:
 \_enter\_state(arc\_state, S\_NEUTRAL, day, rng)
 elif not locked:
 # Rechute
 if tension\_mean >= t\_med and arc\_state.phase\_hostile >= 2:
 \_enter\_state(arc\_state, S\_CONFLICT, day, rng)

 S\_ALLIANCE:
 if not locked:
 # Merge rare gate + stabilité de confiance
 if trust\_mean >= 75.0 and rel\_mean >= 60.0 and tension\_mean <= 15.0 and arc\_state.stable\_high\_trust\_days >= (Y\_high\_trust + 3):
 \_enter\_state(arc\_state, S\_MERGED, day, rng)
 apply\_major\_pair\_lock(arc\_state, day, rng, 9999, 9999)

# terminal

 # Backslide
 elif tension\_mean >= t\_med and (arc\_state.phase\_hostile >= 2 or is\_hostile\_action(last\_action)):
 \_enter\_state(arc\_state, S\_RIVALRY, day, rng)

 \_:
 pass

 return arc\_state.state != prev
```


### Notes rapides


* Pour que “pendant Y jours” soit **exact**, l’idéal est d’appeler une fonction `tick_day_for_pair()` qui met à jour `stable_*_days` même quand il n’y a **pas d’événement** ce jour-là. Là, c’est déjà beaucoup mieux que du “1-shot”, mais c’est encore event-driven.
* Le `apply_major_pair_lock()` est indépendant de l’état : exactement ce que tu voulais pour éviter de retomber immédiatement en incident après trêve/alliance.


Si tu veux, je te donne le mini `tick_day_for_pair(arc_state, rel_ab, rel_ba)` (10 lignes) pour que les compteurs “Y jours” soient parfaits même les jours sans arcs.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-36"></a>
**Moi 36:**
Oui, donne le mini tick\_day\_for\_pair(arc\_state, rel\_ab, rel\_ba) (10 lignes) pour que les compteurs “Y jours” soient parfaits même les jours sans arcs.


**ChatGPT:**


```
static func tick\_day\_for\_pair(arc\_state: ArcState, rel\_ab: FactionRelationScore, rel\_ba: FactionRelationScore) -> void:
 var t\_low := 25.0
 var rel\_good := 35.0
 var trust\_good := 55.0

 var tension\_mean := 0.5 * (rel\_ab.tension + rel\_ba.tension)
 var rel\_mean := 0.5 * (float(rel\_ab.relation) + float(rel\_ba.relation))
 var trust\_mean := 0.5 * (float(rel\_ab.trust) + float(rel\_ba.trust))

 arc\_state.stable\_low\_tension\_days = arc\_state.stable\_low\_tension\_days + 1 if tension\_mean <= t\_low else 0
 arc\_state.stable\_high\_trust\_days = arc\_state.stable\_high\_trust\_days + 1 if (trust\_mean >= trust\_good and rel\_mean >= rel\_good) else 0
```


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-37"></a>
**Moi 37:**
Maintenant, on fait :

3) Un modèle de “coût” et “capacité” faction (budget d’actions)


Pour éviter que des factions déclenchent trop d’offres :


budget/jour ou budget/semaine (dépend de ressources/logistique, état de guerre, fatigue),


limite d’offres actives par faction,


coût par action type (raid coûte moins qu’une guerre, trêve coûte du capital politique, etc.).

Sans ça, tu risques un spam d’offres même si la probabilité est stable.

Si tu penses qu'on l'as deja fait en partie, dis moi ce qui manque et implemente a partir de ce qu'on a deja fait


**ChatGPT:**
On l’a **déjà en partie** grâce à l’**escrow d’or** (une faction pauvre ne peut pas payer ⇒ elle ne spawn pas).

Mais ça **ne suffit pas** contre le spam, parce qu’une faction riche pourrait :


* générer **trop d’offres/jour**,
* ouvrir **trop d’offres en parallèle**,
* déclencher des actions “politiquement lourdes” (trêve/alliance/guerre) trop souvent.


Ce qui manque donc : un **budget de capacité** (points/jour ou points/semaine) + des **caps d’offres actives** + un **coût par action type** indépendant de l’or.


Ci-dessous une implémentation qui s’appuie sur ce qu’on a déjà : *ArcState / ArcOfferFactory / QuestPool*.


---


# 1) Budget de capacité : `FactionOfferBudget` + manager


## `FactionOfferBudget.gd`


```
class\_name FactionOfferBudget
extends RefCounted

var faction\_id: StringName

# Points “politiques / opérationnels”

var points: float = 0.0
var points\_per\_week: float = 70.0 # base (tunable)

# Caps

var max\_active\_offers: int = 6
var max\_active\_offers\_per\_pair: int = 2

# Tracking

var reserved\_points\_by\_quest: Dictionary[StringName, float] = {} # runtime\_id -> points
var active\_offer\_ids: Dictionary[StringName, bool] = {} # runtime\_id -> true
var active\_count\_by\_pair: Dictionary[StringName, int] = {} # "a|b" -> count

func \_init(id: StringName = &"") -> void:
 faction\_id = id

func regen\_daily(profile: FactionProfile, war\_pressure: float = 0.0) -> void:
 # war\_pressure 0..1 (ex: proportion de paires en WAR)

# Logistique/discipline => meilleure regen (si tu as ces traits)

 var org := profile.get\_personality(FactionProfile.PERS\_ORGANIZATION, 0.5)
 var base := points\_per\_week / 7.0
 var mul := 0.85 + 0.50 * org
 mul *= (1.0 - 0.35 * clampf(war\_pressure, 0.0, 1.0))
 points = min(points + base * mul, points\_per\_week)

# cap weekly

func \_reserved\_total() -> float:
 var s := 0.0
 for k in reserved\_points\_by\_quest.keys():
 s += float(reserved\_points\_by\_quest[k])
 return s

func available\_points() -> float:
 return points - \_reserved\_total()

func can\_open\_offer(pair\_key: StringName, cost\_points: float) -> bool:
 if active\_offer\_ids.size() >= max\_active\_offers:
 return false
 if int(active\_count\_by\_pair.get(pair\_key, 0)) >= max\_active\_offers\_per\_pair:
 return false
 return available\_points() >= cost\_points

func reserve\_for\_offer(runtime\_id: StringName, pair\_key: StringName, cost\_points: float) -> bool:
 if not can\_open\_offer(pair\_key, cost\_points):
 return false
 reserved\_points\_by\_quest[runtime\_id] = cost\_points
 active\_offer\_ids[runtime\_id] = true
 active\_count\_by\_pair[pair\_key] = int(active\_count\_by\_pair.get(pair\_key, 0)) + 1
 return true

func release\_offer(runtime\_id: StringName, pair\_key: StringName, refund\_ratio: float = 1.0) -> void:
 var reserved := float(reserved\_points\_by\_quest.get(runtime\_id, 0.0))
 reserved\_points\_by\_quest.erase(runtime\_id)
 active\_offer\_ids.erase(runtime\_id)

# décrémente pair count

 if active\_count\_by\_pair.has(pair\_key):
 active\_count\_by\_pair[pair\_key] = max(0, int(active\_count\_by\_pair[pair\_key]) - 1)

# refund partiel (anti-spam): 1.0 = full refund, 0.8 = listing fee 20%

 refund\_ratio = clampf(refund\_ratio, 0.0, 1.0)
 points = min(points + reserved * refund\_ratio, points\_per\_week)

func consume\_on\_resolution(runtime\_id: StringName, pair\_key: StringName) -> void:
 # à la résolution, on consomme 100%: on retire la réservation sans refund
 reserved\_points\_by\_quest.erase(runtime\_id)
 active\_offer\_ids.erase(runtime\_id)
 if active\_count\_by\_pair.has(pair\_key):
 active\_count\_by\_pair[pair\_key] = max(0, int(active\_count\_by\_pair[pair\_key]) - 1)
```


## `ArcOfferBudgetManager.gd`


```
class\_name ArcOfferBudgetManager
extends RefCounted

var budget\_by\_faction: Dictionary[StringName, FactionOfferBudget] = {}

func get\_budget(faction\_id: StringName) -> FactionOfferBudget:
 if not budget\_by\_faction.has(faction\_id):
 budget\_by\_faction[faction\_id] = FactionOfferBudget.new(faction\_id)
 return budget\_by\_faction[faction\_id]

func tick\_day(faction\_profiles: Dictionary, war\_pressure\_by\_faction: Dictionary = {}) -> void:
 for fid in faction\_profiles.keys():
 var b := get\_budget(StringName(fid))
 var p: FactionProfile = faction\_profiles[fid]
 var wp := float(war\_pressure\_by\_faction.get(fid, 0.0))
 b.regen\_daily(p, wp)
```


---


# 2) Coût par action type (points), dépendant difficulté/état/personnalité


À mettre dans `ArcOfferFactory.gd` (ou util séparé).


```
static func compute\_action\_cost\_points(
 action: StringName,
 arc\_state\_name: StringName,
 difficulty: float,
 tier: int,
 giver\_profile: FactionProfile
) -> float:
 # base costs (tunable)
 var base := 10.0
 match action:
 ArcDecisionUtil.ARC\_RAID: base = 10.0
 ArcDecisionUtil.ARC\_SABOTAGE: base = 12.0
 ArcDecisionUtil.ARC\_ULTIMATUM: base = 9.0
 ArcDecisionUtil.ARC\_TRUCE\_TALKS: base = 14.0
 ArcDecisionUtil.ARC\_REPARATIONS: base = 16.0
 ArcDecisionUtil.ARC\_ALLIANCE\_OFFER:base = 18.0
 ArcDecisionUtil.ARC\_DECLARE\_WAR: base = 30.0
 \_: base = 11.0

 # état amplifie le coût (WAR = lourd)
 var state\_mul := 1.0
 match arc\_state\_name:
 &"WAR": state\_mul = 1.25
 &"CONFLICT": state\_mul = 1.10
 &"RIVALRY": state\_mul = 1.00
 &"TRUCE": state\_mul = 1.05
 &"ALLIANCE": state\_mul = 1.10
 \_: state\_mul = 1.00

 # difficulté & tier
 var diff\_mul := 0.85 + 0.95 * clampf(difficulty, 0.0, 1.0)
 var tier\_mul := 1.0 + 0.18 * float(max(tier - 1, 0))

# personnalité: expansionism réduit coût hostile, diplomacy réduit coût peace

 var expa := giver\_profile.get\_personality(FactionProfile.PERS\_EXPANSIONISM, 0.5)
 var diplo := giver\_profile.get\_personality(FactionProfile.PERS\_DIPLOMACY, 0.5)

 var pers\_mul := 1.0
 if ArcStateMachine.is\_hostile\_action(action):
 pers\_mul *= (1.10 - 0.30 * expa)

# expa élevé => coût ↓

 if ArcStateMachine.is\_peace\_action(action):
 pers\_mul *= (1.10 - 0.30 * diplo)

# diplo élevé => coût ↓

 return base * state\_mul * diff\_mul * tier\_mul * pers\_mul
```


---


# 3) Intégration dans `ArcOfferFactory.spawn_offer_for_pair()`


On combine **2 contraintes** :

1) **or** via `FactionEconomy.can_reserve(reward_gold)`

2) **capacité** via `FactionOfferBudget.can_open_offer(pair_key, cost_points)`


Ajouts (les lignes importantes) :


```
static func spawn\_offer\_for\_pair(
 arc\_id: StringName,
 arc\_state: ArcState,
 giver\_id: StringName,
 ant\_id: StringName,
 action: StringName,
 rel\_ab: FactionRelationScore,
 faction\_profiles: Dictionary,
 faction\_economies: Dictionary,
 budget\_mgr: ArcOfferBudgetManager, # <-- NEW
 rng: RandomNumberGenerator,
 day: int,
 tier: int = 1,
 params: Dictionary = {}
) -> QuestInstance:
 var econ: FactionEconomy = faction\_economies.get(giver\_id, null)
 if econ == null:
 return null

 var giver\_prof: FactionProfile = faction\_profiles.get(giver\_id, null)
 if giver\_prof == null:
 return null

 var spec := \_pick\_offer\_spec(action, rng)
 if spec.is\_empty():
 return null

 var extra\_ctx: Dictionary = Dictionary(spec.get("ctx", {}))
 var domain: String = String(extra\_ctx.get("domain", "combat"))

# risk/difficulty/reward (comme avant)

 var risk := clampf(0.25 + 0.007 * rel\_ab.tension + 0.006 * rel\_ab.grievance, 0.1, 0.95)
 var difficulty := compute\_difficulty(arc\_state.state, rel\_ab, risk, tier)
 var reward\_gold := compute\_reward\_gold(tier, difficulty, domain)

# pair\_key (même que build\_arc\_context)

 var pair\_key := StringName((String(giver\_id) <= String(ant\_id)) \
 ? (String(giver\_id) + "|" + String(ant\_id)) \
 : (String(ant\_id) + "|" + String(giver\_id)))

# --- NEW: capacity cost points ---

 var cost\_points := compute\_action\_cost\_points(action, arc\_state.state, difficulty, tier, giver\_prof)
 var budget := budget\_mgr.get\_budget(giver\_id)

# checks

 if not econ.can\_reserve(reward\_gold):
 return null
 if not budget.can\_open\_offer(pair\_key, cost\_points):
 return null

 # context + template + instance
 var stakes := {"gold": reward\_gold, "risk": risk, "domain": domain, "difficulty": difficulty, "cost\_points": cost\_points}
 var ctx := ArcStateMachine.build\_arc\_context(arc\_id, arc\_state, giver\_id, ant\_id, action, day, int(spec.get("deadline", 7)), stakes, rng.randi())
 for k in extra\_ctx.keys():
 ctx[k] = extra\_ctx[k]

 var template: QuestTemplate = \_build\_template\_fallback(String(spec["tag"]), action, tier)
 var inst := QuestInstance.new(template, ctx)
 inst.status = "AVAILABLE"
 inst.started\_on\_day = day
 inst.expires\_on\_day = day + int(spec.get("deadline", 7))
 inst.progress = 0

 # --- Reserve BOTH escrow gold and capacity points (after runtime\_id exists) ---
 var qid := StringName(inst.runtime\_id)

 if not econ.reserve\_for\_quest(qid, reward\_gold):
 return null

 if not budget.reserve\_for\_offer(qid, pair\_key, cost\_points):
 # rollback gold if capacity fails
 econ.release\_reservation(qid)
 return null

 # persist escrow info
 inst.context["escrow\_faction\_id"] = giver\_id
 inst.context["escrow\_gold"] = reward\_gold
 inst.context["escrow\_points"] = cost\_points
 inst.context["pair\_key"] = pair\_key

 return inst
```


---


# 4) Lifecycle : release/consume des points + or


Tu fais déjà “release/payout” pour l’or. On ajoute pareil pour les points.


### A) Offer expirée / retirée du pool (pas acceptée)


Anti-spam conseillé : refund partiel (ex. 80% ⇒ listing fee 20%)


```
var giver\_id: StringName = inst.context.get("escrow\_faction\_id", &"")
var pair\_key: StringName = inst.context.get("pair\_key", &"")
var qid: StringName = StringName(inst.runtime\_id)

# gold

var econ: FactionEconomy = faction\_economies.get(giver\_id, null)
if econ != null:
 econ.release\_reservation(qid)

# points (refund partiel)

var budget := budget\_mgr.get\_budget(giver\_id)
budget.release\_offer(qid, pair\_key, 0.80)

# 80% refund

```


### B) Quête résolue (acceptée puis terminée)


* Or : `payout_reserved()`
* Points : `consume_on_resolution()` (0 refund)


```
var giver\_id: StringName = inst.context.get("escrow\_faction\_id", &"")
var pair\_key: StringName = inst.context.get("pair\_key", &"")
var qid: StringName = StringName(inst.runtime\_id)

# gold payout vers joueur/héros

var econ: FactionEconomy = faction\_economies.get(giver\_id, null)
var paid := 0
if econ != null:
 paid = econ.payout\_reserved(qid)

# points consumed

budget\_mgr.get\_budget(giver\_id).consume\_on\_resolution(qid, pair\_key)
```


---


# Résumé : ce qu’on avait / ce qu’on ajoute


✅ Déjà fait :


* **or escrow** (payer la récompense)
* **cooldowns** + **pair locks** + **tests**


✅ Ajout maintenant :


* **budget de capacité** (points/semaine)
* **caps d’offres actives** (global + par paire)
* **coût par action type** (modulé par état/difficulté/tier/personnalité)
* release/consume cohérent dans le lifecycle


---


Si tu veux la suite logique : je te propose un mini patch “ArcManager fallback” : quand `spawn_offer_for_pair()` échoue (pas assez d’or/points), il retente une action moins chère (ultimatum → raid → ignore) au lieu de simplement abandonner le tick.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-38"></a>
**Moi 38:**
Ok propose un mini patch “
<a id="cite-arcmanager-1d7a8c-6"></a>ArcManager fallback” : quand spawn\_offer\_for\_pair() échoue (pas assez d’or/points), il retente une action moins chère (ultimatum → raid → ignore) au lieu de simplement abandonner le tick.


**ChatGPT:**
Voici un mini patch **ArcManager fallback** : si `spawn_offer_for_pair()` échoue (or/points/caps), on retente une action moins chère dans un ordre typique :


* `DECLARE_WAR → ULTIMATUM → RAID → IGNORE`
* `ALLIANCE_OFFER → TRUCE_TALKS → REPARATIONS → IGNORE`
* `SABOTAGE → RAID → IGNORE`
* défaut : `ULTIMATUM → RAID → IGNORE`


## Patch compact (helpers + usage)

### 1) Helpers (dans `ArcManager.gd` ou util)


```
func \_fallback\_chain\_for(action: StringName) -> Array[StringName]:
 match action:
 ArcDecisionUtil.ARC\_DECLARE\_WAR:
 return [ArcDecisionUtil.ARC\_DECLARE\_WAR, ArcDecisionUtil.ARC\_ULTIMATUM, ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_IGNORE]
 ArcDecisionUtil.ARC\_ALLIANCE\_OFFER:
 return [ArcDecisionUtil.ARC\_ALLIANCE\_OFFER, ArcDecisionUtil.ARC\_TRUCE\_TALKS, ArcDecisionUtil.ARC\_REPARATIONS, ArcDecisionUtil.ARC\_IGNORE]
 ArcDecisionUtil.ARC\_TRUCE\_TALKS:
 return [ArcDecisionUtil.ARC\_TRUCE\_TALKS, ArcDecisionUtil.ARC\_REPARATIONS, ArcDecisionUtil.ARC\_IGNORE]
 ArcDecisionUtil.ARC\_REPARATIONS:
 return [ArcDecisionUtil.ARC\_REPARATIONS, ArcDecisionUtil.ARC\_TRUCE\_TALKS, ArcDecisionUtil.ARC\_IGNORE]
 ArcDecisionUtil.ARC\_SABOTAGE:
 return [ArcDecisionUtil.ARC\_SABOTAGE, ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_IGNORE]
 ArcDecisionUtil.ARC\_RAID:
 return [ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_IGNORE]
 ArcDecisionUtil.ARC\_ULTIMATUM:
 return [ArcDecisionUtil.ARC\_ULTIMATUM, ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_IGNORE]
 \_:
 return [action, ArcDecisionUtil.ARC\_ULTIMATUM, ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_IGNORE]


func \_try\_spawn\_offer\_with\_fallback(
 arc\_id: StringName,
 arc\_state: ArcState,
 giver\_id: StringName,
 ant\_id: StringName,
 initial\_action: StringName,
 rel\_ab: FactionRelationScore,
 faction\_profiles: Dictionary,
 faction\_economies: Dictionary,
 budget\_mgr: ArcOfferBudgetManager,
 rng: RandomNumberGenerator,
 day: int,
 tier: int
) -> QuestInstance:
 for action in \_fallback\_chain\_for(initial\_action):
 if action == ArcDecisionUtil.ARC\_IGNORE:
 return null
 var inst := ArcOfferFactory.spawn\_offer\_for\_pair(
 arc\_id, arc\_state,
 giver\_id, ant\_id,
 action,
 rel\_ab,
 faction\_profiles,
 faction\_economies,
 budget\_mgr,
 rng,
 day,
 tier
 )
 if inst != null:
 # important: mettre l’action réelle dans le context (si tu veux tracer)
 inst.context["arc\_action\_type"] = action
 inst.context["arc\_action\_type\_initial"] = initial\_action
 return inst
 return null
```


### 2) Usage dans ton tick (à la place de “spawn direct”)


```
var action := ArcDecisionUtil.select\_arc\_action\_type(...)
var tier := \_tier\_for\_state(pair\_arc\_state.state)

# si tu as, sinon 1

var inst := \_try\_spawn\_offer\_with\_fallback(
 arc\_id, pair\_arc\_state,
 giver\_id, ant\_id,
 action,
 relations[giver\_id][ant\_id],
 faction\_profiles,
 faction\_economies,
 budget\_mgr,
 \_rng, day,
 tier
)

if inst != null:
 QuestPool.try\_add\_offer(inst)

# optionnel: si tu veux considérer qu’un “intent” a eu lieu même si fallback

 # pair\_arc\_state.last\_action = StringName(inst.context["arc\_action\_type"])
```


### (Optionnel) 3) Ajuster tier en fallback


Si tu veux encore plus robuste : quand le spawn échoue, on peut aussi baisser le tier avant de changer d’action :


* essayer `(action, tier)`
* puis `(action, tier-1)`
* puis fallback action…


Je te le fais si tu veux, mais le patch ci-dessus suffit déjà pour éviter les “ticks à vide” des factions riches mais capées.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-39"></a>
**Moi 39:**
Fait :

Ajuster tier en fallback


Si tu veux encore plus robuste : quand le spawn échoue, on peut aussi baisser le tier avant de changer d’action :


essayer (action, tier)


puis (action, tier-1)


puis fallback action…


**ChatGPT:**
Voici une version “fallback robuste” qui essaie :


1) même **action** avec `tier`, puis `tier-1`, puis `tier-2`… jusqu’à `min_tier`

2) si toujours impossible → **fallback action** (ultimatum→raid→ignore etc.), et pour chaque action, même logique de tiers.


## Patch : `_try_spawn_offer_with_fallback_and_tier()`


```
func \_try\_spawn\_offer\_with\_fallback\_and\_tier(
 arc\_id: StringName,
 arc\_state: ArcState,
 giver\_id: StringName,
 ant\_id: StringName,
 initial\_action: StringName,
 rel\_ab: FactionRelationScore,
 faction\_profiles: Dictionary,
 faction\_economies: Dictionary,
 budget\_mgr: ArcOfferBudgetManager,
 rng: RandomNumberGenerator,
 day: int,
 tier: int,
 min\_tier: int = 1
) -> QuestInstance:
 var chain := \_fallback\_chain\_for(initial\_action)

 for action in chain:
 if action == ArcDecisionUtil.ARC\_IGNORE:
 return null

 var t := tier
 while t >= min\_tier:
 var inst := ArcOfferFactory.spawn\_offer\_for\_pair(
 arc\_id, arc\_state,
 giver\_id, ant\_id,
 action,
 rel\_ab,
 faction\_profiles,
 faction\_economies,
 budget\_mgr,
 rng,
 day,
 t
 )
 if inst != null:
 inst.context["arc\_action\_type"] = action
 inst.context["arc\_action\_type\_initial"] = initial\_action
 inst.context["arc\_tier\_initial"] = tier
 inst.context["arc\_tier\_final"] = t
 return inst

 t -= 1

 return null
```


## Utilisation dans ton tick


```
var action := ArcDecisionUtil.select\_arc\_action\_type(...)
var tier := \_tier\_for\_state(pair\_arc\_state.state)

# ex: WAR=3, CONFLICT=2, RIVALRY=1

var inst := \_try\_spawn\_offer\_with\_fallback\_and\_tier(
 arc\_id, pair\_arc\_state,
 giver\_id, ant\_id,
 action,
 relations[giver\_id][ant\_id],
 faction\_profiles,
 faction\_economies,
 budget\_mgr,
 \_rng, day,
 tier,
 1
)

if inst != null:
 QuestPool.try\_add\_offer(inst)
```


### Conseil rapide


* Si tu veux éviter de “dégrader” trop souvent, tu peux limiter à `tier-1` seulement (au lieu de descendre jusqu’à 1), en remplaçant la boucle `while` par deux essais (`tier` puis `tier-1`).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-40"></a>
**Moi 40:**
Fait que le nombre de fois qu'on degrader l'action et le tiers soit des parametre dans la fonction


**ChatGPT:**
Voici une version où **le nombre de dégradations d’action** et **le nombre de dégradations de tier** sont paramétrables.


* `max_action_degrades` : combien de “pas” on fait dans la chaîne de fallback (0 = seulement l’action initiale)
* `max_tier_degrades` : combien de fois on baisse le tier (0 = seulement tier initial)
* `min_tier` : plancher


```
func \_try\_spawn\_offer\_with\_fallback\_and\_tier(
 arc\_id: StringName,
 arc\_state: ArcState,
 giver\_id: StringName,
 ant\_id: StringName,
 initial\_action: StringName,
 rel\_ab: FactionRelationScore,
 faction\_profiles: Dictionary,
 faction\_economies: Dictionary,
 budget\_mgr: ArcOfferBudgetManager,
 rng: RandomNumberGenerator,
 day: int,
 tier: int,
 min\_tier: int = 1,
 max\_action\_degrades: int = 2, # 0 = aucune dégradation d’action
 max\_tier\_degrades: int = 1 # 0 = aucun downgrade de tier
) -> QuestInstance:
 var chain := \_fallback\_chain\_for(initial\_action)

# Limite action: on prend 1 + max\_action\_degrades éléments max

 var max\_actions := min(chain.size(), 1 + max\_action\_degrades)

 for ai in range(max\_actions):
 var action: StringName = chain[ai]
 if action == ArcDecisionUtil.ARC\_IGNORE:
 return null

 # essais de tier: tier, tier-1, ... limité par max\_tier\_degrades et min\_tier
 var tries := 1 + max\_tier\_degrades
 for k in range(tries):
 var t := tier - k
 if t < min\_tier:
 break

 var inst := ArcOfferFactory.spawn\_offer\_for\_pair(
 arc\_id, arc\_state,
 giver\_id, ant\_id,
 action,
 rel\_ab,
 faction\_profiles,
 faction\_economies,
 budget\_mgr,
 rng,
 day,
 t
 )

 if inst != null:
 inst.context["arc\_action\_type"] = action
 inst.context["arc\_action\_type\_initial"] = initial\_action
 inst.context["arc\_tier\_initial"] = tier
 inst.context["arc\_tier\_final"] = t
 inst.context["arc\_fallback\_action\_steps"] = ai
 inst.context["arc\_fallback\_tier\_steps"] = k
 return inst

 return null
```


Exemple d’appel :


```
var inst := \_try\_spawn\_offer\_with\_fallback\_and\_tier(
 arc\_id, pair\_arc\_state,
 giver\_id, ant\_id,
 action,
 relations[giver\_id][ant\_id],
 faction\_profiles,
 faction\_economies,
 budget\_mgr,
 \_rng, day,
 tier,
 1, # min\_tier
 2, # max\_action\_degrades (ex: action + 2 fallback)
 1 # max\_tier\_degrades (ex: tier puis tier-1)
)
```


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-41"></a>
**Moi 41:**
Maintenant, fait :

4) Le mapping “arc\_action\_type → offres de quêtes”

C’est LE pont vers ton
<a id="cite-questpool-43825e-5"></a>QuestPool :

• chaque arc\_action\_type doit produire 1+ templates d’offres (avec variantes),

• et des context keys standardisées (arc\_action\_type, giver, antagonist, target\_poi, stake, deadline, etc.).
Il manque donc une table “
<a id="cite-offerfactory-ecafbb-1"></a>OfferFactory” :
• arc.raid → quests combat/stealth/supply-line,
• arc.ultimatum → diplomacy / escort envoy / retrieve proof,
• arc.truce\_talks → escort diplomat / secure venue / eliminate spoiler,

• arc.alliance\_offer → joint mission / exchange hostages / oath ritual.


**ChatGPT:**
OK — on va formaliser un vrai **OfferFactory** “arc\_action\_type → 1..N offers”, avec :


* **catalogue** (variants + poids + domaines + besoins de cible),
* **context standardisé** (keys communes + clés de cible),
* **spawn** qui produit des `QuestInstance` directement ajoutables au `QuestPool`.


Je te donne une implémentation **prête à brancher** (avec fallback si tes managers POI/QuestGenerator ne sont pas encore dispo).


---


# 1) Spec compacte du contexte standard


Toujours présent dans `inst.context` :


```
# Arc keys (communes)

"is\_arc\_rivalry": true
"arc\_id": StringName
"arc\_state": StringName # NEUTRAL/RIVALRY/...
"arc\_action\_type": StringName # arc.raid/arc.ultimatum/...
"giver\_faction\_id": StringName
"antagonist\_faction\_id": StringName
"pair\_key": StringName # "a|b"
"created\_day": int
"deadline\_days": int
"seed": int

# Offer keys (communes)

"offer\_tag": String # ex: "combat.raid\_camp"
"offer\_domain": String # combat/diplo/stealth/logistics/exploration
"offer\_kind": String # "ARC\_PRIMARY"/"ARC\_SECONDARY"
"stakes": Dictionary # gold/risk/difficulty/cost\_points/...
```


Cibles standard (optionnelles, selon variant) :


```
"target\_poi\_id": StringName
"target\_poi\_type": StringName
"target\_poi\_pos": Vector2i

"target\_faction\_id": StringName # si 3e partie/tiers
"target\_character\_id": StringName # envoy/hostage/etc.
"target\_item\_tag": StringName # proof/documents
"target\_artifact\_id": StringName
```


---


# 2) OfferFactory : catalogue + spawn 1..N offers


## `ArcOfferFactory.gd` (nouvelle version “catalogue + bundles”)


```
class\_name ArcOfferFactory
extends RefCounted

# --------------------------------------------

# Catalogue : arc\_action\_type -> bundles

# Chaque bundle peut produire 1..N offers (primary + optional secondary)

# --------------------------------------------

const CATALOG: Dictionary = {
 &"arc.raid": {
 "count\_min": 1,
 "count\_max": 2,
 "variants": [
 {"tag":"combat.raid\_camp", "w":45, "domain":"combat", "needs\_poi":true, "poi\_types":[&"CAMP",&"OUTPOST"], "deadline":[5,8]},
 {"tag":"stealth.burn\_supplies", "w":30, "domain":"stealth", "needs\_poi":true, "poi\_types":[&"DEPOT",&"WORKSHOP"], "deadline":[4,7]},
 {"tag":"logistics.intercept", "w":25, "domain":"logistics", "needs\_poi":false, "deadline":[6,9]},
 ]
 },

 &"arc.ultimatum": {
 "count\_min": 1,
 "count\_max": 2,
 "variants": [
 {"tag":"diplo.deliver\_terms", "w":45, "domain":"diplo", "needs\_poi":true, "poi\_types":[&"CITY",&"CAPITAL"], "deadline":[4,6]},
 {"tag":"combat.show\_of\_force", "w":30, "domain":"combat", "needs\_poi":true, "poi\_types":[&"BORDER",&"OUTPOST"], "deadline":[5,7]},
 {"tag":"diplo.retrieve\_proof", "w":25, "domain":"diplo", "needs\_poi":true, "poi\_types":[&"RUINS",&"LIBRARY"], "deadline":[6,9],
 "ctx":{"target\_item\_tag":&"PROOF\_DOSSIER"}}
 ]
 },

 &"arc.truce\_talks": {
 "count\_min": 1,
 "count\_max": 2,
 "variants": [
 {"tag":"diplo.secure\_venue", "w":40, "domain":"diplo", "needs\_poi":true, "poi\_types":[&"CITY",&"SANCTUARY"], "deadline":[5,7]},
 {"tag":"combat.protect\_envoy", "w":35, "domain":"combat", "needs\_poi":true, "poi\_types":[&"ROAD",&"CITY"], "deadline":[5,7],
 "ctx":{"target\_character\_id":&"ENVOY"}},
 {"tag":"stealth.remove\_spoiler","w":25, "domain":"stealth", "needs\_poi":true, "poi\_types":[&"CITY",&"CAMP"], "deadline":[6,9]}
 ]
 },

 &"arc.alliance\_offer": {
 "count\_min": 1,
 "count\_max": 2,
 "variants": [
 {"tag":"combat.joint\_operation","w":35, "domain":"combat", "needs\_poi":true, "poi\_types":[&"RUINS",&"OUTPOST"], "deadline":[7,10]},
 {"tag":"diplo.exchange\_hostages","w":35,"domain":"diplo", "needs\_poi":true, "poi\_types":[&"CITY",&"CAPITAL"], "deadline":[6,9],
 "ctx":{"target\_character\_id":&"HOSTAGE"}},
 {"tag":"diplo.oath\_ritual", "w":30, "domain":"diplo", "needs\_poi":true, "poi\_types":[&"SANCTUARY",&"TEMPLE"], "deadline":[7,10],
 "ctx":{"ritual":true}}
 ]
 },

 &"arc.sabotage": {
 "count\_min": 1,
 "count\_max": 2,
 "variants": [
 {"tag":"stealth.sabotage\_site", "w":55, "domain":"stealth", "needs\_poi":true, "poi\_types":[&"WORKSHOP",&"DEPOT"], "deadline":[6,9]},
 {"tag":"combat.assassinate", "w":25, "domain":"combat", "needs\_poi":false, "deadline":[7,10]},
 {"tag":"diplo.frame\_agent", "w":20, "domain":"diplo", "needs\_poi":true, "poi\_types":[&"CITY"], "deadline":[6,8]},
 ]
 },

 &"arc.declare\_war": {
 "count\_min": 2, # guerre => souvent 2 offers (mobilisation + objectif)
 "count\_max": 3,
 "variants": [
 {"tag":"logistics.mobilize", "w":40, "domain":"logistics", "needs\_poi":false, "deadline":[7,10]},
 {"tag":"combat.capture\_outpost", "w":40, "domain":"combat", "needs\_poi":true, "poi\_types":[&"OUTPOST",&"BORDER"], "deadline":[8,12]},
 {"tag":"stealth.break\_alliance", "w":20, "domain":"stealth", "needs\_poi":false, "deadline":[7,11]},
 ]
 },

 &"arc.reparations": {
 "count\_min": 1,
 "count\_max": 2,
 "variants": [
 {"tag":"logistics.deliver\_goods","w":45,"domain":"logistics", "needs\_poi":true, "poi\_types":[&"CITY",&"CAPITAL"], "deadline":[7,11]},
 {"tag":"combat.guard\_caravan", "w":25,"domain":"combat", "needs\_poi":true, "poi\_types":[&"ROAD",&"CITY"], "deadline":[6,10]},
 {"tag":"diplo.audit\_treaty", "w":30,"domain":"diplo", "needs\_poi":true, "poi\_types":[&"CITY"], "deadline":[6,9]},
 ]
 },
}

# -------------------------------------------------

# Utilities

# -------------------------------------------------

static func \_weighted\_pick(variants: Array, rng: RandomNumberGenerator) -> Dictionary:
 var sum := 0
 for v in variants:
 sum += int(v.get("w", 1))
 var r := rng.randi\_range(1, max(1, sum))
 var acc := 0
 for v in variants:
 acc += int(v.get("w", 1))
 if r <= acc:
 return v
 return variants.back()

static func \_roll\_deadline\_days(v: Dictionary, rng: RandomNumberGenerator) -> int:
 var d := v.get("deadline", [6, 9])
 return rng.randi\_range(int(d[0]), int(d[1]))

static func \_roll\_count(bundle: Dictionary, rng: RandomNumberGenerator) -> int:
 return rng.randi\_range(int(bundle.get("count\_min", 1)), int(bundle.get("count\_max", 1)))

static func \_pair\_key(a: StringName, b: StringName) -> StringName:
 return StringName((String(a) <= String(b)) ? (String(a) + "|" + String(b)) : (String(b) + "|" + String(a)))

# -------------------------------------------------

# Target POI resolution (stub + autoload-friendly)

# -------------------------------------------------

static func \_pick\_target\_poi(poi\_types: Array, rng: RandomNumberGenerator) -> Dictionary:
 # Attendu: { "id": StringName, "type": StringName, "pos": Vector2i }
 # Branche ton POIManager/WorldMap ici.
 if Engine.has\_singleton("POIManagerRunner"):
 var pm = Engine.get\_singleton("POIManagerRunner")
 if pm != null and pm.has\_method("pick\_random\_poi"):
 return pm.pick\_random\_poi(poi\_types, rng)

# à adapter à ton API

 # fallback : aucun poi
 return {}

# -------------------------------------------------

# Template builder (fallback). Remplace par ton QuestGenerator si dispo.

# -------------------------------------------------

static func \_build\_template\_fallback(tag: String, tier: int, deadline\_days: int) -> QuestTemplate:
 var t := QuestTemplate.new()
 t.id = StringName("arc\_" + tag)
 t.title = "Arc: " + tag
 t.description = "Arc offer: " + tag
 t.category = "ARC"
 t.tier = tier
 t.objective\_type = "GENERIC"
 t.objective\_target = tag
 t.objective\_count = 1
 t.expires\_in\_days = deadline\_days
 return t

# -------------------------------------------------

# Public API: spawn 1..N offers for a pair

# -------------------------------------------------

static func spawn\_offers\_for\_pair(
 arc\_id: StringName,
 arc\_state: ArcState,
 giver\_id: StringName,
 ant\_id: StringName,
 action: StringName,
 rel\_ab: FactionRelationScore,
 faction\_profiles: Dictionary,
 faction\_economies: Dictionary,
 budget\_mgr: ArcOfferBudgetManager,
 rng: RandomNumberGenerator,
 day: int,
 tier: int,
 params: Dictionary = {}
) -> Array[QuestInstance]:
 var bundle: Dictionary = CATALOG.get(action, {})
 if bundle.is\_empty():
 return []

 var variants: Array = bundle.get("variants", [])
 if variants.is\_empty():
 return []

 var count := \_roll\_count(bundle, rng)
 var out: Array[QuestInstance] = []
 var used\_tags := {}

 # on essaie de varier les offers (pas 2 fois le même tag)
 for idx in range(count):
 var tries := 0
 var v := {}
 while tries < 5:
 v = \_weighted\_pick(variants, rng)
 var tag := String(v.get("tag", ""))
 if tag != "" and not used\_tags.has(tag):
 used\_tags[tag] = true
 break
 tries += 1

 var offer := \_spawn\_single\_offer\_from\_variant(
 arc\_id, arc\_state,
 giver\_id, ant\_id,
 StringName(action),
 rel\_ab,
 faction\_profiles,
 faction\_economies,
 budget\_mgr,
 rng, day,
 tier,
 v,
 (idx == 0) ? "ARC\_PRIMARY" : "ARC\_SECONDARY"
 )

 if offer != null:
 out.append(offer)

 return out


static func \_spawn\_single\_offer\_from\_variant(
 arc\_id: StringName,
 arc\_state: ArcState,
 giver\_id: StringName,
 ant\_id: StringName,
 action: StringName,
 rel\_ab: FactionRelationScore,
 faction\_profiles: Dictionary,
 faction\_economies: Dictionary,
 budget\_mgr: ArcOfferBudgetManager,
 rng: RandomNumberGenerator,
 day: int,
 tier: int,
 variant: Dictionary,
 offer\_kind: String
) -> QuestInstance:
 var econ: FactionEconomy = faction\_economies.get(giver\_id, null)
 var giver\_prof: FactionProfile = faction\_profiles.get(giver\_id, null)
 if econ == null or giver\_prof == null:
 return null

 var tag := String(variant.get("tag", ""))
 if tag == "":
 return null

 var domain := String(variant.get("domain", "combat"))
 var deadline\_days := \_roll\_deadline\_days(variant, rng)
 var pair\_key := \_pair\_key(giver\_id, ant\_id)

# --- cible POI si demandée ---

 var target\_poi := {}
 if bool(variant.get("needs\_poi", false)):
 target\_poi = \_pick\_target\_poi(variant.get("poi\_types", []), rng)
 if target\_poi.is\_empty():
 return null # pas de cible => pas d’offre

 # --- stakes/risk/difficulty/reward ---
 var risk := clampf(0.25 + 0.007 * rel\_ab.tension + 0.006 * rel\_ab.grievance, 0.1, 0.95)
 var difficulty := ArcOfferFactoryEconomy.compute\_difficulty(arc\_state.state, rel\_ab, risk, tier)
 var reward\_gold := ArcOfferFactoryEconomy.compute\_reward\_gold(tier, difficulty, domain)

# --- coût capacité ---

 var cost\_points := ArcOfferFactoryEconomy.compute\_action\_cost\_points(action, arc\_state.state, difficulty, tier, giver\_prof)
 var budget := budget\_mgr.get\_budget(giver\_id)

# --- checks ---

 if not econ.can\_reserve(reward\_gold):
 return null
 if not budget.can\_open\_offer(pair\_key, cost\_points):
 return null

 var stakes := {"gold": reward\_gold, "risk": risk, "domain": domain, "difficulty": difficulty, "cost\_points": cost\_points}

 # context standard + patch variant ctx + target poi
 var ctx := ArcStateMachine.build\_arc\_context(arc\_id, arc\_state, giver\_id, ant\_id, action, day, deadline\_days, stakes, rng.randi())
 ctx["offer\_tag"] = tag
 ctx["offer\_domain"] = domain
 ctx["offer\_kind"] = offer\_kind
 ctx["pair\_key"] = pair\_key

 var patch: Dictionary = variant.get("ctx", {})
 for k in patch.keys():
 ctx[k] = patch[k]

 if not target\_poi.is\_empty():
 ctx["target\_poi\_id"] = target\_poi.get("id", &"")
 ctx["target\_poi\_type"] = target\_poi.get("type", &"")
 ctx["target\_poi\_pos"] = target\_poi.get("pos", Vector2i.ZERO)

# template via QuestGenerator si dispo, sinon fallback

 var template: QuestTemplate = null
 if Engine.has\_singleton("QuestGeneratorRunner"):
 var qg = Engine.get\_singleton("QuestGeneratorRunner")
 if qg != null and qg.has\_method("create\_dynamic\_template\_from\_tag"):
 template = qg.create\_dynamic\_template\_from\_tag(tag, tier, ctx)
 if template == null:
 template = \_build\_template\_fallback(tag, tier, deadline\_days)

 var inst := QuestInstance.new(template, ctx)
 inst.status = "AVAILABLE"
 inst.started\_on\_day = day
 inst.expires\_on\_day = day + deadline\_days
 inst.progress = 0

 # reserve gold + points AFTER runtime\_id exists
 var qid := StringName(inst.runtime\_id)
 if not econ.reserve\_for\_quest(qid, reward\_gold):
 return null
 if not budget.reserve\_for\_offer(qid, pair\_key, cost\_points):
 econ.release\_reservation(qid)
 return null

 inst.context["escrow\_faction\_id"] = giver\_id
 inst.context["escrow\_gold"] = reward\_gold
 inst.context["escrow\_points"] = cost\_points

 return inst
```


### Petit détail : les fonctions économie utilisées ci-dessus


Pour ne pas dupliquer, je te suggère un petit util séparé.


## `ArcOfferFactoryEconomy.gd` (util)


```
class\_name ArcOfferFactoryEconomy
extends RefCounted

static func compute\_difficulty(arc\_state\_name: StringName, rel\_ab: FactionRelationScore, risk: float, tier: int) -> float:
 var state\_factor := 0.15
 match arc\_state\_name:
 &"RIVALRY": state\_factor = 0.20
 &"CONFLICT": state\_factor = 0.45
 &"WAR": state\_factor = 0.70
 &"TRUCE": state\_factor = 0.25
 &"ALLIANCE": state\_factor = 0.20
 var t := rel\_ab.tension / 100.0
 var g := rel\_ab.grievance / 100.0
 var tier\_factor := clampf(0.15 * float(max(tier - 1, 0)), 0.0, 0.45)
 return clampf(0.35*risk + 0.30*t + 0.20*g + 0.15*state\_factor + tier\_factor, 0.0, 1.0)

static func compute\_reward\_gold(tier: int, difficulty: float, domain: String) -> int:
 var base := 40 + 35 * tier
 var dom\_mul := 1.0
 if domain == "combat": dom\_mul = 1.10
 elif domain == "diplo": dom\_mul = 0.95
 var reward := float(base) * dom\_mul * (1.0 + 1.35*difficulty)
 return int(round(reward))

static func compute\_action\_cost\_points(action: StringName, arc\_state\_name: StringName, difficulty: float, tier: int, giver\_profile: FactionProfile) -> float:
 var base := 11.0
 match action:
 ArcDecisionUtil.ARC\_RAID: base = 10.0
 ArcDecisionUtil.ARC\_SABOTAGE: base = 12.0
 ArcDecisionUtil.ARC\_ULTIMATUM: base = 9.0
 ArcDecisionUtil.ARC\_TRUCE\_TALKS: base = 14.0
 ArcDecisionUtil.ARC\_REPARATIONS: base = 16.0
 ArcDecisionUtil.ARC\_ALLIANCE\_OFFER: base = 18.0
 ArcDecisionUtil.ARC\_DECLARE\_WAR: base = 30.0

 var state\_mul := 1.0
 match arc\_state\_name:
 &"WAR": state\_mul = 1.25
 &"CONFLICT": state\_mul = 1.10
 &"ALLIANCE": state\_mul = 1.10

 var diff\_mul := 0.85 + 0.95 * clampf(difficulty, 0.0, 1.0)
 var tier\_mul := 1.0 + 0.18 * float(max(tier - 1, 0))

 var expa := giver\_profile.get\_personality(FactionProfile.PERS\_EXPANSIONISM, 0.5)
 var diplo := giver\_profile.get\_personality(FactionProfile.PERS\_DIPLOMACY, 0.5)

 var pers\_mul := 1.0
 if ArcStateMachine.is\_hostile\_action(action):
 pers\_mul *= (1.10 - 0.30 * expa)
 if ArcStateMachine.is\_peace\_action(action):
 pers\_mul *= (1.10 - 0.30 * diplo)

 return base * state\_mul * diff\_mul * tier\_mul * pers\_mul
```


---


# 3) Comment l’utiliser côté ArcManager


Au lieu d’un `spawn_offer_for_pair()` unique :


```
var offers := ArcOfferFactory.spawn\_offers\_for\_pair(
 arc\_id, pair\_arc\_state,
 giver\_id, ant\_id,
 action\_type,
 relations[giver\_id][ant\_id],
 faction\_profiles,
 faction\_economies,
 budget\_mgr,
 \_rng, day,
 tier
)

for inst in offers:
 QuestPool.try\_add\_offer(inst)
```


Et si tu veux garder ton fallback action/tier : tu fais le fallback autour de `spawn_offers_for_pair()` (même principe).


---


Si tu veux, prochaine brique utile : une mini règle “**allowed actions per ArcState**” + “**bundle size** selon état” (ex: en WAR, count\_min=2 garanti, en RIVALRY count\_max=1) pour maîtriser encore mieux le spam et la lisibilité côté joueur.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-42"></a>
**Moi 42:**
prochaine brique utile : une mini règle “allowed actions per
<a id="cite-arcstate-66333b-2"></a>ArcState” + “bundle size selon état” (ex: en WAR, count\_min=2 garanti, en RIVALRY count\_max=1) pour maîtriser encore mieux le spam et la lisibilité côté joueur.


**ChatGPT:**
Voici une brique **simple, très efficace** : une règle `allowed actions per ArcState` + un “scaling” du **bundle size** selon l’état (WAR produit plus d’offres, RIVALRY en produit peu).


---


# 1) Allowed actions par ArcState


## `ArcPolicy.gd`


```
class\_name ArcPolicy
extends RefCounted

# Actions autorisées selon l’état

const ALLOWED\_BY\_STATE: Dictionary = {
 &"NEUTRAL": [ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_ULTIMATUM, ArcDecisionUtil.ARC\_IGNORE],
 &"RIVALRY": [ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_SABOTAGE, ArcDecisionUtil.ARC\_ULTIMATUM, ArcDecisionUtil.ARC\_TRUCE\_TALKS, ArcDecisionUtil.ARC\_IGNORE],
 &"CONFLICT": [ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_SABOTAGE, ArcDecisionUtil.ARC\_ULTIMATUM, ArcDecisionUtil.ARC\_DECLARE\_WAR, ArcDecisionUtil.ARC\_TRUCE\_TALKS, ArcDecisionUtil.ARC\_IGNORE],
 &"WAR": [ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_SABOTAGE, ArcDecisionUtil.ARC\_DECLARE\_WAR, ArcDecisionUtil.ARC\_TRUCE\_TALKS, ArcDecisionUtil.ARC\_IGNORE],
 &"TRUCE": [ArcDecisionUtil.ARC\_TRUCE\_TALKS, ArcDecisionUtil.ARC\_REPARATIONS, ArcDecisionUtil.ARC\_ALLIANCE\_OFFER, ArcDecisionUtil.ARC\_IGNORE],
 &"ALLIANCE": [ArcDecisionUtil.ARC\_ALLIANCE\_OFFER, ArcDecisionUtil.ARC\_JOINT\_OPERATION if ArcDecisionUtil.has(&"ARC\_JOINT\_OPERATION") else ArcDecisionUtil.ARC\_IGNORE, ArcDecisionUtil.ARC\_IGNORE],
}

static func filter\_action\_for\_state(state: StringName, proposed: StringName, rng: RandomNumberGenerator) -> StringName:
 var allowed: Array = ALLOWED\_BY\_STATE.get(state, [])
 if allowed.is\_empty():
 return proposed
 if allowed.has(proposed):
 return proposed
 # fallback: pick an allowed non-IGNORE if possible
 var non\_ignore: Array = []
 for a in allowed:
 if a != ArcDecisionUtil.ARC\_IGNORE:
 non\_ignore.append(a)
 if non\_ignore.is\_empty():
 return ArcDecisionUtil.ARC\_IGNORE
 return non\_ignore[rng.randi\_range(0, non\_ignore.size() - 1)]
```


>
> Note : j’ai laissé un placeholder `ARC_JOINT_OPERATION` si tu ajoutes une action dédiée “coop”.
>
>
>


---


# 2) Bundle size selon état (min/max override)


Au lieu de modifier le catalogue, on applique un **override** au moment du spawn.


## `ArcPolicy.gd` (suite)


```
# Overrides de bundle selon état (lisibilité + anti-spam)

const BUNDLE\_BY\_STATE: Dictionary = {
 &"NEUTRAL": {"count\_min": 0, "count\_max": 1}, # souvent 0 (pas d’offre) ou 1 incident
 &"RIVALRY": {"count\_min": 1, "count\_max": 1}, # lisible : 1 offer max
 &"CONFLICT": {"count\_min": 1, "count\_max": 2},
 &"WAR": {"count\_min": 2, "count\_max": 3}, # WAR => plusieurs fronts
 &"TRUCE": {"count\_min": 1, "count\_max": 2},
 &"ALLIANCE": {"count\_min": 1, "count\_max": 2},
}

static func override\_bundle\_count(state: StringName, base\_bundle: Dictionary, rng: RandomNumberGenerator) -> int:
 var ov: Dictionary = BUNDLE\_BY\_STATE.get(state, {})
 if ov.is\_empty():
 # fallback sur le bundle du catalogue
 var mn := int(base\_bundle.get("count\_min", 1))
 var mx := int(base\_bundle.get("count\_max", 1))
 return rng.randi\_range(mn, mx)

 var mn2 := int(ov.get("count\_min", int(base\_bundle.get("count\_min", 1))))
 var mx2 := int(ov.get("count\_max", int(base\_bundle.get("count\_max", 1))))
 return rng.randi\_range(mn2, mx2)
```


---


# 3) Patch dans `ArcOfferFactory.spawn_offers_for_pair()`


Dans `ArcOfferFactory.gd`, remplace :


```
var count := \_roll\_count(bundle, rng)
```


par :


```
var count := ArcPolicy.override\_bundle\_count(arc\_state.state, bundle, rng)
if count <= 0:
 return []
```


Et avant d’utiliser `action`, filtre-la côté ArcManager (recommandé), ou directement ici.


---


# 4) Patch côté ArcManager (recommandé)


Juste après `select_arc_action_type(...)` :


```
action\_type = ArcPolicy.filter\_action\_for\_state(pair\_arc\_state.state, action\_type, \_rng)
if action\_type == ArcDecisionUtil.ARC\_IGNORE:
 return
```


---


# 5) Résultat (ce que tu gagnes)


* En **RIVALRY**, tu garantis **1 offer max** → le joueur comprend “l’incident du moment”.
* En **WAR**, tu as automatiquement **2–3 offers** → sensation de fronts multiples.
* En **TRUCE**, tu as 1–2 offers max → négociation + “spoiler” ou “logistique”.
* Le tout réduit le spam même si les proba d’incident sont élevées.


Si tu veux, prochaine mini-brique : une règle “**1 seul ARC\_PRIMARY visible par paire**” (les secondary existent mais ne sont spawn que si le pool est bas, ou si le joueur a déjà accepté la primary).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-43"></a>
**Moi 43:**
Le max est part faction? Ou pour toute les faction ?

Si je suis en guerre avec une facttion X et en rivalry avec une faction Y, j'ai 2 actions min contre la faction X et 1 contre la faction Y, donc 3 en tout. Ou j'en ai 2 contre les deux ?


**ChatGPT:**
Dans la règle que je viens de proposer, le **count\_min / count\_max est “par paire”** (par arc A↔B), pas global.


Donc dans ton exemple, **si tu as la capacité** :


* en **WAR contre X** → tu *tentes* de produire **2 à 3 offers** liées à X
* en **RIVALRY contre Y** → tu *tentes* de produire **1 offer** liée à Y

➡️ donc **3 offers au total** (voire 4 si WAR sort 3)


Mais attention : le “tentes” est important, parce qu’en pratique tu vas presque toujours appliquer des **caps/budgets par faction** (et éventuellement un cap global QuestPool). C’est ça qui répond à “est-ce que c’est 2 contre les deux ?”.


## La bonne réponse design


* **Bundle size = par paire (par état de la paire)**
* **Capacité = par faction (giver)**
* et le résultat final = **clamp** par la capacité restante de la faction.


### Concrètement, la faction A a par exemple :


* `max_active_offers` (cap total offers actives en même temps)
* `points` (budget/jour/semaine) + coût points par action
* `gold escrow` (budget financier)
* éventuellement un `max_new_offers_per_day` (cap “rythme”)


Donc A en WAR avec X **ne garantit pas** 2 offers si :


* A a déjà atteint `max_active_offers`,
* ou pas assez de points,
* ou pas assez d’or pour escrow,
* ou quota journalier atteint.


## Comment répartir si plusieurs adversaires


Le plus robuste : tu fais un **budget de “slots” par faction par tick/jour**, et tu les alloues par priorité :


1) Construire la liste des paires actives de A (X en WAR, Y en RIVALRY, etc.)

2) Trier par priorité d’état : `WAR > CONFLICT > TRUCE > RIVALRY > NEUTRAL`

3) Pour chaque paire, calculer `wanted = bundle_count_override(state)` (2..3, 1..1, etc.)

4) `granted = min(wanted, slots_restants, points_restants, gold_possible)`

5) Spawn `granted` offers, puis passer à la paire suivante.


### Donc ton exemple :


* Si A a assez de slots/points/or → **2 contre X + 1 contre Y = 3**
* Si A est limité (par ex slots\_restants = 2) → tu fais **2 contre X** et **0 contre Y** (ou 1/1 selon la stratégie)
	+ variante : tu peux forcer “au moins 1 offer par paire active” si tu veux plus de variété, mais c’est un choix.


## Reco “lisibilité joueur”


Je te conseille ce comportement :


* **WAR** prend la priorité (parce que c’est l’arc majeur)
* RIVALRY passe après
* et si tu es à court de budget → RIVALRY peut ne rien produire ce jour-là.


Si tu veux, je te donne un mini code `allocate_offer_slots_for_faction(faction_id, pairs)` qui fait exactement ce clamp + priorité, et branche ça sur `spawn_offers_for_pair()`.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-44"></a>
**Moi 44:**
Non, explique moi ce que tu voulais dire par :

prochaine mini-brique : une règle “1 seul ARC\_PRIMARY visible par paire” (les secondary existent mais ne sont spawn que si le pool est bas, ou si le joueur a déjà accepté la primary).\_


**ChatGPT:**
L’idée “**1 seul ARC\_PRIMARY visible par paire**”, c’est une règle de **lisibilité + anti-spam** côté joueur.


### Le problème qu’on évite


Si une paire A↔B en WAR génère 2–3 offers par jour, tu peux te retrouver avec :


* 6 offres “contre la même faction” très similaires,
* et le joueur ne comprend plus “quelle est l’histoire / l’événement principal”.


### La règle proposée


Pour chaque paire `(A,B)` :


* **au maximum 1 offer “ARC\_PRIMARY”** dans le pool (visible, prioritaire, narrative).
* les autres offres possibles sont des **ARC\_SECONDARY** (variantes), mais :
	+ soit tu **ne les génères pas** tant que la primary existe,
	+ soit tu les génères seulement dans certains cas (voir ci-dessous).


### Ce que ça change concrètement


* En **RIVALRY**, ça ne change presque rien (tu avais déjà 1 offer max).
* En **WAR**, au lieu de 3 offers simultanées pour la paire, tu as :
	+ 1 “événement principal” (primary) visible,
	+ puis éventuellement 0–1 secondaires “en renfort” selon les conditions.


### Quand autoriser les SECONDARY


Deux stratégies (tu peux mixer) :


1) **Après acceptation**


* Tant que la primary n’est pas acceptée → pas de secondary (ou très peu).
* Dès que le joueur accepte la primary → tu peux spawn 1 secondary (ex: “front secondaire” pendant la mission principale).


2) **Si le pool est bas** (pression de contenu)


* Si `QuestPool.offers.size() < MIN_POOL` (genre 6) → autorise 1 secondary même sans acceptation.
* Sinon, reste sur primary only.


### Comment l’implémenter simplement


Dans `QuestPool.try_add_offer(inst)` (ou juste avant), tu mets une garde :


* si `inst.context.offer_kind == "ARC_PRIMARY"` :
	+ refuser si une autre offer ARC\_PRIMARY existe déjà pour `pair_key`
* si `offer_kind == "ARC_SECONDARY"` :
	+ refuser si primary existe et que (a) le joueur ne l’a pas acceptée, et (b) pool pas bas


En pratique, tu as besoin d’un index rapide :


* `arc_primary_by_pair[pair_key] = runtime_id`
* `arc_secondary_count_by_pair[pair_key]`


### Pourquoi c’est utile


* Le joueur voit “**le** problème du moment” entre A et B.
* Tu gardes quand même de la variété grâce aux variants secondaires, sans saturer.
* Ça rend tes arcs plus “narratifs” : une primary = un événement marquant.


Si tu veux, je peux te donner un patch précis pour `QuestPool.try_add_offer()` (ou une fonction `ArcOfferVisibilityGate.can_add_offer(inst, quest_pool_state)`).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-45"></a>
**Moi 45:**
Je pensais que le max\_offer (3 pour War) etait une limite pour le nombre d'offre total, pas le nombre d'offre par jour.

Il faut que ce soit le cas.

Par contre, on peut verifier si on peut generé de meilleur quete (cas du fallback action/tiers ou meilleur cible) et remplacer d'ancienne quete moins bien


**ChatGPT:**
Tu as raison : dans ce design-là, **`count_min/count_max` (ex: WAR=2..3)** doit surtout être compris comme une **limite de “stock” d’offres simultanées** pour une **paire** (A↔B), pas comme “on en recrée 3 par jour”.


On avait décrit “bundle size” au moment du spawn, mais l’intention “anti-spam + lisibilité” est beaucoup meilleure si on l’utilise comme **cap concurrent**.


Et oui : si on détecte qu’on peut générer **une meilleure quête**, on peut **remplacer** une ancienne “moins bonne” (avec une politique anti-churn).


Voici la brique complète (compacte) : **cap par paire + remplacement “upgrade”**.


---


## 1) Interprétation correcte


Pour une paire `(A,B)` :


* `bundle_cap = ArcPolicy.bundle_cap_for_state(arc_state.state)`
	+ RIVALRY → 1 (max 1 offer dans le pool pour cette paire)
	+ WAR → 3 (max 3 offers dans le pool pour cette paire)
* Chaque jour / tick, on fait juste :

**“si on est sous le cap → on complète”**

sinon **rien** (ou “upgrade” opportuniste).


---


## 2) Patch : cap concurrent par paire


### `ArcPolicy.gd` (helper cap)


```
static func bundle\_cap\_for\_state(state: StringName) -> int:
 var ov: Dictionary = BUNDLE\_BY\_STATE.get(state, {})
 if ov.is\_empty():
 return 1
 return int(ov.get("count\_max", 1))

# cap concurrent (on prend le max)

```


### `QuestPool` (ou un util) : récupérer les offers d’une paire


```
func get\_arc\_offers\_for\_pair(pair\_key: StringName) -> Array:
 var out: Array = []
 for inst in offers: # à adapter selon ton stockage
 if inst == null: continue
 if not inst.context.get("is\_arc\_rivalry", false): continue
 if StringName(inst.context.get("pair\_key", &"")) != pair\_key: continue
 out.append(inst)
 return out
```


---


## 3) Remplacement “upgrade” (meilleure quête remplace moins bonne)

### A) Score “qualité” (simple, stable)


On score une offer avec ce que tu as déjà dans `context["stakes"]` :


```
static func offer\_quality\_score(inst: QuestInstance) -> float:
 var stakes: Dictionary = inst.context.get("stakes", {})
 var reward := float(stakes.get("gold", 0))
 var diff := float(stakes.get("difficulty", 0.0))

# 0..1

 var tier := float(inst.template.tier if inst.template != null else 1)
 var deadline := float(inst.context.get("deadline\_days", 7))

# Plus c’est payé / difficile / tier haut => “mieux”

 # deadline court = plus “urgent” (léger bonus)
 var urgency := clampf((10.0 - deadline) / 10.0, 0.0, 1.0)

 return 0.45 * reward + 55.0 * diff + 25.0 * tier + 10.0 * urgency
```


### B) Politique de remplacement


* On ne remplace que si le nouveau est **nettement meilleur** (hystérésis).
* On évite de remplacer trop souvent (cooldown “refresh”) : idéalement stocké dans `ArcNotebook` (par `pair_key`).


```
static func should\_replace(new\_score: float, old\_score: float, min\_improvement\_ratio: float = 1.15) -> bool:
 if old\_score <= 0.0:
 return true
 return new\_score >= old\_score * min\_improvement\_ratio
```


### C) Release / rollback des réservations (or + points)


Comme ton `spawn` réserve déjà, il faut pouvoir rollback si on n’ajoute pas au pool :


```
static func release\_offer\_reservations(
 inst: QuestInstance,
 faction\_economies: Dictionary,
 budget\_mgr: ArcOfferBudgetManager,
 points\_refund\_ratio: float = 0.80
) -> void:
 var giver\_id: StringName = inst.context.get("escrow\_faction\_id", &"")
 var pair\_key: StringName = inst.context.get("pair\_key", &"")
 var qid := StringName(inst.runtime\_id)

# gold escrow

 var econ: FactionEconomy = faction\_economies.get(giver\_id, null)
 if econ != null:
 econ.release\_reservation(qid)

# points escrow

 var bud := budget\_mgr.get\_budget(giver\_id)
 bud.release\_offer(qid, pair\_key, points\_refund\_ratio)
```


---


## 4) Fonction “ensure cap + upgrade” (ArcManager)


C’est la fonction que tu appelles quand tu as décidé `(giver, antagonist, action)`.


```
func \_ensure\_arc\_offers\_for\_pair(
 quest\_pool,
 arc\_id: StringName,
 arc\_state: ArcState,
 giver\_id: StringName,
 ant\_id: StringName,
 action: StringName,
 rel\_ab: FactionRelationScore,
 faction\_profiles: Dictionary,
 faction\_economies: Dictionary,
 budget\_mgr: ArcOfferBudgetManager,
 rng: RandomNumberGenerator,
 day: int,
 tier: int,
 params: Dictionary = {}
) -> void:
 var pair\_key := StringName(insta\_pair\_key(giver\_id, ant\_id))

# ou ArcOfferFactory.\_pair\_key()

 var cap := ArcPolicy.bundle\_cap\_for\_state(arc\_state.state)
 var existing: Array = quest\_pool.get\_arc\_offers\_for\_pair(pair\_key)

# (Optionnel) si l’état a changé, tu peux virer celles qui ne matchent plus

 # existing = existing.filter(func(i): return StringName(i.context.get("arc\_state",&"")) == arc\_state.state)

# 1) Compléter si sous cap

 if existing.size() < cap:
 var offers := ArcOfferFactory.spawn\_offers\_for\_pair(
 arc\_id, arc\_state,
 giver\_id, ant\_id,
 action,
 rel\_ab,
 faction\_profiles,
 faction\_economies,
 budget\_mgr,
 rng, day,
 tier
 )
 for inst in offers:
 # stop dès qu’on atteint le cap
 if existing.size() >= cap:
 release\_offer\_reservations(inst, faction\_economies, budget\_mgr)
 continue
 if quest\_pool.try\_add\_offer(inst):
 existing.append(inst)
 else:
 release\_offer\_reservations(inst, faction\_economies, budget\_mgr)
 return

 # 2) Sinon : tentative d’upgrade (1 seule tentative max / jour / paire conseillé)

# Génère 1 candidat, et remplace le pire si nettement meilleur

 var candidate\_list := ArcOfferFactory.spawn\_offers\_for\_pair(
 arc\_id, arc\_state,
 giver\_id, ant\_id,
 action,
 rel\_ab,
 faction\_profiles,
 faction\_economies,
 budget\_mgr,
 rng, day,
 tier,
 {"count\_min": 1, "count\_max": 1} # si tu veux forcer 1 candidat
 )
 if candidate\_list.is\_empty():
 return
 var cand: QuestInstance = candidate\_list[0]

 var cand\_score := offer\_quality\_score(cand)

 var worst := existing[0]
 var worst\_score := offer\_quality\_score(worst)
 for e in existing:
 var s := offer\_quality\_score(e)
 if s < worst\_score:
 worst = e
 worst\_score = s

 if should\_replace(cand\_score, worst\_score, 1.15):
 # retirer worst du pool + libérer ses réservations
 quest\_pool.remove\_offer\_by\_id(StringName(worst.runtime\_id))
 release\_offer\_reservations(worst, faction\_economies, budget\_mgr)

# ajouter candidate (déjà réservée)

 if not quest\_pool.try\_add\_offer(cand):
 # si add échoue, rollback candidate
 release\_offer\_reservations(cand, faction\_economies, budget\_mgr)
 else:
 # candidate rejetée => rollback
 release\_offer\_reservations(cand, faction\_economies, budget\_mgr)
```


>
> Notes :
>
>
> * `insta_pair_key()` = ta façon de calculer `pair_key` (ou réutilise celle de `ArcOfferFactory`).
> * `QuestPool.remove_offer_by_id()` est à adapter (ou remove direct dans ta liste).
> * J’ai volontairement limité l’upgrade à **1 candidat** pour éviter le churn.
>
>
>


---


## 5) “Meilleure cible” (POI) sans tout recoder


Dans `ArcOfferFactory._pick_target_poi(...)`, au lieu de prendre “un POI random”, tu peux :


* tirer `N` candidats (ex: 5),
* scorer (distance frontière, valeur stratégique, proximité du giver, etc.),
* garder le meilleur.


Interface simple :


```
# POIManagerRunner.score\_poi\_for\_arc(action, giver\_id, ant\_id, poi\_dict) -> float

```


---


### En résumé


* Oui : `WAR=3` doit être **cap total simultané** pour la paire, pas “par jour”.
* Et oui : on peut **remplacer** une vieille offer par une meilleure, avec :
	+ un score de qualité,
	+ un seuil d’amélioration (hystérésis),
	+ un cooldown anti-churn (facile à ajouter via ArcNotebook).


Si tu veux, je te propose le micro-ajout “cooldown refresh par pair” dans `ArcNotebook` (genre pas plus d’un upgrade tous les 5 jours) — c’est vraiment le petit détail qui rend le système très stable côté joueur.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-46"></a>
**Moi 46:**
Ok

propose le micro-ajout “cooldown refresh par pair” dans
<a id="cite-arcnotebook-b751fa-5"></a>ArcNotebook (genre pas plus d’un upgrade tous les 5 jours) — c’est vraiment le petit détail qui rend le système très stable côté joueur.


**ChatGPT:**
Voici un **micro-ajout** simple dans `ArcNotebook` pour limiter les “upgrades/remplacements” à **1 toutes les N journées par paire**.


---


## 1) Ajout dans `ArcNotebook`


### A) Données (par paire)


```
# ArcNotebook.gd

class\_name ArcNotebook
extends RefCounted

var last\_offer\_refresh\_day\_by\_pair: Dictionary[StringName, int] = {} # pair\_key -> last\_day

func can\_refresh\_offer\_for\_pair(pair\_key: StringName, day: int, cooldown\_days: int = 5) -> bool:
 var last := int(last\_offer\_refresh\_day\_by\_pair.get(pair\_key, -999999))
 return (day - last) >= cooldown\_days

func mark\_offer\_refreshed\_for\_pair(pair\_key: StringName, day: int) -> void:
 last\_offer\_refresh\_day\_by\_pair[pair\_key] = day
```


>
> Tu peux aussi le ranger dans ton `ArcHistory` par faction si tu préfères, mais au niveau notebook global c’est parfait.
>
>
>


---


## 2) Utilisation dans ton “upgrade logic”


Dans la fonction `_ensure_arc_offers_for_pair(...)`, juste avant de tenter l’upgrade (quand `existing.size() >= cap`) :


```
if not arc\_notebook.can\_refresh\_offer\_for\_pair(pair\_key, day, 5):
 return
```


Et **uniquement si tu fais un remplacement effectif** (ou si tu veux limiter même les tentatives, à toi de voir) :


```
if should\_replace(...):
 # ... remove worst, add candidate ...
 arc\_notebook.mark\_offer\_refreshed\_for\_pair(pair\_key, day)
```


### Variante recommandée


* Marquer le refresh **seulement si remplacement réel** ⇒ plus permissif.
* Si tu veux encore moins de churn CPU, tu peux marquer dès la **tentative** (même si pas remplacé), mais c’est plus “dur”.


---


## 3) Bonus (optionnel) : cooldown différent par état


Ex:


* RIVALRY : 7 jours (ça bouge peu)
* WAR : 3 jours (fronts qui évoluent)


```
func refresh\_cooldown\_for\_state(state: StringName) -> int:
 match state:
 &"WAR": return 3
 &"CONFLICT": return 4
 &"RIVALRY": return 7
 &"TRUCE": return 6
 &"ALLIANCE": return 8
 \_: return 5
```


Puis :


```
var cd := refresh\_cooldown\_for\_state(arc\_state.state)
if not arc\_notebook.can\_refresh\_offer\_for\_pair(pair\_key, day, cd):
 return
```


---


Si tu veux, je te propose aussi un mini champ “refresh\_attempts\_by\_pair” pour debug/metrics, mais fonctionnellement, les 2 méthodes ci-dessus suffisent.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-47"></a>
**Moi 47:**
propose aussi un mini champ “refresh\_attempts\_by\_pair” pour debug/metrics, mais fonctionnellement, les 2 méthodes ci-dessus suffisent.

Et prevoit des test pour couvrir ce qu'on a fait depuis le dernier tests


**ChatGPT:**
Voilà le **micro-ajout** demandé + une proposition de **tests Godot** qui couvre ce qu’on a ajouté depuis les derniers tests (policy/caps, cooldown refresh, budget points/caps, et un test “fallback action/tier” fiable via stub).


---


## 1) Micro-ajout dans `ArcNotebook`


Ajoute un compteur par paire :


```
# ArcNotebook.gd

class\_name ArcNotebook
extends RefCounted

var last\_offer\_refresh\_day\_by\_pair: Dictionary[StringName, int] = {} # pair\_key -> last successful refresh day
var refresh\_attempts\_by\_pair: Dictionary[StringName, int] = {} # pair\_key -> count (debug/metrics)

func can\_refresh\_offer\_for\_pair(pair\_key: StringName, day: int, cooldown\_days: int = 5) -> bool:
 var last := int(last\_offer\_refresh\_day\_by\_pair.get(pair\_key, -999999))
 return (day - last) >= cooldown\_days

func mark\_offer\_refreshed\_for\_pair(pair\_key: StringName, day: int) -> void:
 last\_offer\_refresh\_day\_by\_pair[pair\_key] = day

func mark\_refresh\_attempt\_for\_pair(pair\_key: StringName) -> int:
 var n := int(refresh\_attempts\_by\_pair.get(pair\_key, 0)) + 1
 refresh\_attempts\_by\_pair[pair\_key] = n
 return n
```


### Où l’utiliser


Dans ton code “upgrade” (quand `existing.size() >= cap` et que `can_refresh == true`) :


* juste avant de générer un candidat : `arc_notebook.mark_refresh_attempt_for_pair(pair_key)`
* si remplacement effectif : `arc_notebook.mark_offer_refreshed_for_pair(pair_key, day)`


---


## 2) Tests (depuis les dernières briques)


Je te propose un nouveau fichier de test autonome (même style que ton harness) :


### `tests/ArcGovernanceTest.gd`


```
extends Node
class\_name ArcGovernanceTest

var rng := RandomNumberGenerator.new()

func \_ready() -> void:
 rng.seed = 12345

 \_test\_notebook\_refresh\_cooldown\_and\_attempts()
 \_test\_policy\_allowed\_actions\_and\_caps()
 \_test\_budget\_points\_caps()
 \_test\_tick\_day\_for\_pair\_stability\_counters()
 \_test\_fallback\_action\_tier\_with\_stub()

 print("\n✅ ArcGovernanceTest: OK\n")
 get\_tree().quit()

# -------------------------

# 1) ArcNotebook cooldown + attempts

# -------------------------

func \_test\_notebook\_refresh\_cooldown\_and\_attempts() -> void:
 var nb := ArcNotebook.new()
 var pair := &"a|b"

 \_assert(nb.can\_refresh\_offer\_for\_pair(pair, 10, 5), "should refresh at day 10")
 \_assert(nb.mark\_refresh\_attempt\_for\_pair(pair) == 1, "attempts should be 1")
 nb.mark\_offer\_refreshed\_for\_pair(pair, 10)

 \_assert(not nb.can\_refresh\_offer\_for\_pair(pair, 14, 5), "should NOT refresh at day 14 (cooldown=5)")
 \_assert(nb.can\_refresh\_offer\_for\_pair(pair, 15, 5), "should refresh at day 15")

 \_assert(nb.mark\_refresh\_attempt\_for\_pair(pair) == 2, "attempts should be 2")

# -------------------------

# 2) ArcPolicy allowed actions + bundle cap (concurrent cap)

# -------------------------

func \_test\_policy\_allowed\_actions\_and\_caps() -> void:
 \_assert(ArcPolicy.bundle\_cap\_for\_state(&"RIVALRY") == 1, "RIVALRY cap should be 1")
 \_assert(ArcPolicy.bundle\_cap\_for\_state(&"WAR") == 3, "WAR cap should be 3")

 var proposed := ArcDecisionUtil.ARC\_ALLIANCE\_OFFER
 var filtered := ArcPolicy.filter\_action\_for\_state(&"WAR", proposed, rng)

 var allowed: Array = ArcPolicy.ALLOWED\_BY\_STATE[&"WAR"]
 \_assert(allowed.has(filtered), "filtered action must be allowed in WAR")

# -------------------------

# 3) FactionOfferBudget caps (global + per pair) + points reserve/release

# -------------------------

func \_test\_budget\_points\_caps() -> void:
 var b := FactionOfferBudget.new(&"A")
 b.points\_per\_week = 70
 b.points = 20
 b.max\_active\_offers = 2
 b.max\_active\_offers\_per\_pair = 1

 var p1 := &"a|x"
 var p2 := &"a|y"

 \_assert(b.reserve\_for\_offer(&"q1", p1, 10.0), "reserve q1 should succeed")
 \_assert(not b.reserve\_for\_offer(&"q2", p1, 5.0), "reserve q2 should fail (per-pair cap)")

 \_assert(b.reserve\_for\_offer(&"q2", p2, 10.0), "reserve q2 should succeed on other pair")
 \_assert(not b.reserve\_for\_offer(&"q3", p2, 1.0), "reserve q3 should fail (max\_active\_offers=2)")

# release with refund (listing fee)

 var before := b.points
 b.release\_offer(&"q1", p1, 0.80)
 \_assert(b.active\_offer\_ids.size() == 1, "one active offer should remain after release")
 \_assert(b.points > before, "refund should increase points")

# -------------------------

# 4) tick\_day\_for\_pair stability counters

# -------------------------

func \_test\_tick\_day\_for\_pair\_stability\_counters() -> void:
 var arc\_state := ArcState.new()
 arc\_state.stable\_low\_tension\_days = 0
 arc\_state.stable\_high\_trust\_days = 0

 var ab := FactionRelationScore.new()
 var ba := FactionRelationScore.new()

# Low tension + high trust

 ab.tension = 10; ba.tension = 12
 ab.relation = 40; ba.relation = 38
 ab.trust = 60; ba.trust = 58

 for i in range(7):
 ArcStateMachine.tick\_day\_for\_pair(arc\_state, ab, ba)

 \_assert(arc\_state.stable\_low\_tension\_days == 7, "stable\_low\_tension\_days should count up")
 \_assert(arc\_state.stable\_high\_trust\_days == 7, "stable\_high\_trust\_days should count up")

# Break condition

 ab.tension = 60; ba.tension = 60
 ArcStateMachine.tick\_day\_for\_pair(arc\_state, ab, ba)
 \_assert(arc\_state.stable\_low\_tension\_days == 0, "stable\_low\_tension\_days should reset when tension high")

# -------------------------

# 5) Fallback action/tier (test fiable via stub spawn callable)

# -------------------------

# Pour tester sans dépendre du hasard/POI, on utilise un stub spawn.

#
# ⚠️ Reco mini-changement: ajoute un param optionnel spawn\_fn: Callable

# à ta fonction \_try\_spawn\_offer\_with\_fallback\_and\_tier() (sinon copie la logique ici).

func \_test\_fallback\_action\_tier\_with\_stub() -> void:
 var arc\_id := &"arc\_test"
 var st := ArcState.new()
 st.a\_id = &"A"; st.b\_id = &"B"; st.state = &"WAR"

 # stub: échoue si tier > 1, réussit seulement pour action RAID au tier 1
 var spawn\_fn := func(action: StringName, t: int) -> QuestInstance:
 if action != ArcDecisionUtil.ARC\_RAID:
 return null
 if t != 1:
 return null
 var qt := QuestTemplate.new()
 qt.tier = t
 var ctx := {"is\_arc\_rivalry": true, "arc\_action\_type": action, "stakes": {"gold": 50, "difficulty": 0.3}, "deadline\_days": 7}
 return QuestInstance.new(qt, ctx)

# On simule une chaîne: DECLARE\_WAR -> ULTIMATUM -> RAID

 var initial\_action := ArcDecisionUtil.ARC\_DECLARE\_WAR
 var tier := 3

 # Cette fonction de test reproduit EXACTEMENT ta logique de fallback,
 # mais en utilisant spawn\_fn(action,tier) au lieu d’ArcOfferFactory.
 var inst := \_fallback\_with\_injected\_spawn(initial\_action, tier, 1, 2, 2, spawn\_fn)
 \_assert(inst != null, "fallback should eventually succeed via RAID tier 1")
 \_assert(StringName(inst.context["arc\_action\_type"]) == ArcDecisionUtil.ARC\_RAID, "action should downgrade to RAID")
 \_assert(int(inst.template.tier) == 1, "tier should downgrade to 1")


func \_fallback\_with\_injected\_spawn(
 initial\_action: StringName,
 tier: int,
 min\_tier: int,
 max\_action\_degrades: int,
 max\_tier\_degrades: int,
 spawn\_fn: Callable
) -> QuestInstance:
 var chain := \_fallback\_chain\_for(initial\_action)
 var max\_actions := min(chain.size(), 1 + max\_action\_degrades)

 for ai in range(max\_actions):
 var action: StringName = chain[ai]
 if action == ArcDecisionUtil.ARC\_IGNORE:
 return null

 var tries := 1 + max\_tier\_degrades
 for k in range(tries):
 var t := tier - k
 if t < min\_tier:
 break
 var inst: QuestInstance = spawn\_fn.call(action, t)
 if inst != null:
 inst.context["arc\_action\_type"] = action
 inst.context["arc\_action\_type\_initial"] = initial\_action
 inst.context["arc\_tier\_initial"] = tier
 inst.context["arc\_tier\_final"] = t
 inst.context["arc\_fallback\_action\_steps"] = ai
 inst.context["arc\_fallback\_tier\_steps"] = k
 return inst
 return null


func \_fallback\_chain\_for(action: StringName) -> Array[StringName]:
 match action:
 ArcDecisionUtil.ARC\_DECLARE\_WAR:
 return [ArcDecisionUtil.ARC\_DECLARE\_WAR, ArcDecisionUtil.ARC\_ULTIMATUM, ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_IGNORE]
 ArcDecisionUtil.ARC\_SABOTAGE:
 return [ArcDecisionUtil.ARC\_SABOTAGE, ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_IGNORE]
 ArcDecisionUtil.ARC\_ULTIMATUM:
 return [ArcDecisionUtil.ARC\_ULTIMATUM, ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_IGNORE]
 \_:
 return [action, ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_IGNORE]


# -------------------------

# Assert helper

# -------------------------

func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


### Ce que ces tests couvrent réellement


* **ArcNotebook** : cooldown + métriques “attempts”
* **ArcPolicy** : allowed actions + “cap concurrent” (WAR=3, RIVALRY=1)
* **FactionOfferBudget** : cap global/per-pair + refund partiel
* **tick\_day\_for\_pair** : stabilité “pendant Y jours”
* **fallback action/tier** : test fiable (sans RNG/POI) via stub


---


Si tu veux que le test 5 utilise *ta* fonction réelle (au lieu du helper injecté), je te donne un micro-patch “optionnel” (ajouter `spawn_fn: Callable = Callable()` à `_try_spawn_offer_with_fallback_and_tier`) pour rendre la fonction testable sans changer son comportement en prod.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-48"></a>
**Moi 48:**
Je veux que le test 5 utilise ta fonction réelle (au lieu du helper injecté), donne un micro-patch “optionnel” (ajouter spawn\_fn: Callable = Callable() à \_try\_spawn\_offer\_with\_fallback\_and\_tier) pour rendre la fonction testable sans changer son comportement en prod.


**ChatGPT:**
Voici le **micro-patch optionnel** pour rendre ta fonction réelle testable **sans changer le comportement en prod**.


L’idée : ajouter un paramètre `spawn_fn: Callable = Callable()` ;


* si `spawn_fn.is_valid()` ⇒ on l’utilise (tests)
* sinon ⇒ comportement normal (prod) en appelant `ArcOfferFactory.spawn_offer_for_pair(...)`.


---


## 1) Patch de la fonction réelle


Remplace ta fonction par celle-ci (même signature + `spawn_fn` en plus) :


```
func \_try\_spawn\_offer\_with\_fallback\_and\_tier(
 arc\_id: StringName,
 arc\_state: ArcState,
 giver\_id: StringName,
 ant\_id: StringName,
 initial\_action: StringName,
 rel\_ab: FactionRelationScore,
 faction\_profiles: Dictionary,
 faction\_economies: Dictionary,
 budget\_mgr: ArcOfferBudgetManager,
 rng: RandomNumberGenerator,
 day: int,
 tier: int,
 min\_tier: int = 1,
 max\_action\_degrades: int = 2,
 max\_tier\_degrades: int = 1,
 spawn\_fn: Callable = Callable()

# <-- NEW (optional)

) -> QuestInstance:
 var chain := \_fallback\_chain\_for(initial\_action)

# Limite action: on prend 1 + max\_action\_degrades éléments max

 var max\_actions := min(chain.size(), 1 + max\_action\_degrades)

 for ai in range(max\_actions):
 var action: StringName = chain[ai]
 if action == ArcDecisionUtil.ARC\_IGNORE:
 return null

 # essais de tier: tier, tier-1, ... limité par max\_tier\_degrades et min\_tier
 var tries := 1 + max\_tier\_degrades
 for k in range(tries):
 var t := tier - k
 if t < min\_tier:
 break

 var inst: QuestInstance = null

 # --- NEW: injectable spawn for tests ---
 if spawn\_fn.is\_valid():
 # Convention: spawn\_fn(action: StringName, tier: int) -> QuestInstance
 inst = spawn\_fn.call(action, t)
 else:
 inst = ArcOfferFactory.spawn\_offer\_for\_pair(
 arc\_id, arc\_state,
 giver\_id, ant\_id,
 action,
 rel\_ab,
 faction\_profiles,
 faction\_economies,
 budget\_mgr,
 rng,
 day,
 t
 )

 if inst != null:
 inst.context["arc\_action\_type"] = action
 inst.context["arc\_action\_type\_initial"] = initial\_action
 inst.context["arc\_tier\_initial"] = tier
 inst.context["arc\_tier\_final"] = t
 inst.context["arc\_fallback\_action\_steps"] = ai
 inst.context["arc\_fallback\_tier\_steps"] = k
 return inst

 return null
```


✅ En prod : tu n’envoies pas `spawn_fn` ⇒ ça appelle exactement `ArcOfferFactory.spawn_offer_for_pair` comme avant.

✅ En test : tu passes un `Callable` stub ⇒ contrôle total.


---


## 2) Patch du Test 5 (utilise la fonction réelle)


Dans ton test, remplace le helper injecté par un appel direct :


```
func \_test\_fallback\_action\_tier\_with\_stub\_real\_function() -> void:
 var arc\_id := &"arc\_test"
 var st := ArcState.new()
 st.a\_id = &"A"; st.b\_id = &"B"; st.state = &"WAR"

 # stub: échoue si tier > 1, réussit seulement pour action RAID au tier 1
 var spawn\_fn := func(action: StringName, t: int) -> QuestInstance:
 if action != ArcDecisionUtil.ARC\_RAID:
 return null
 if t != 1:
 return null
 var qt := QuestTemplate.new()
 qt.tier = t
 var ctx := {"is\_arc\_rivalry": true, "arc\_action\_type": action, "stakes": {"gold": 50, "difficulty": 0.3}, "deadline\_days": 7}
 return QuestInstance.new(qt, ctx)

 var inst := \_try\_spawn\_offer\_with\_fallback\_and\_tier(
 arc\_id, st,
 &"A", &"B",
 ArcDecisionUtil.ARC\_DECLARE\_WAR,
 FactionRelationScore.new(),
 {}, {}, ArcOfferBudgetManager.new(),
 rng, 1,
 3, # tier initial
 1, # min\_tier
 2, # max\_action\_degrades
 2, # max\_tier\_degrades
 spawn\_fn
 )

 \_assert(inst != null, "fallback should succeed via stub")
 \_assert(StringName(inst.context["arc\_action\_type"]) == ArcDecisionUtil.ARC\_RAID, "action should downgrade to RAID")
 \_assert(int(inst.template.tier) == 1, "tier should downgrade to 1")
```


(Le reste de ton test file ne change pas.)


---


Si tu veux, je peux aussi te proposer une convention de stub un peu plus riche (avec `giver_id/ant_id/day`), mais ce patch-là est le minimum efficace et ne touche pas ton comportement prod.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 7](#toc-detail-ch7)
<a id="moi-49"></a>
**Moi 49:**
Non, on fait :

5) Une boucle “monde” cohérente (pas seulement
<a id="cite-arcmanager-1d7a8c-7"></a>ArcManager)

Les arcs ne doivent pas être l’unique moteur :

• les goals (
<a id="cite-factiongoalplanner-73d377-2"></a>FactionGoalPlanner) doivent influencer opportunity, external\_threat, priority targets,

• et inversement les arcs doivent modifier les goals (en guerre, les objectifs changent).

Sinon, tu auras des arcs “hors-sol”.


**ChatGPT:**
Oui — là, on passe du “moteur d’arcs” à une **boucle monde** où :


* les **Goals** pilotent *qui* on cible et *pourquoi* (opportunity / external\_threat / priority targets),
* les **Arcs** réécrivent la stratégie (en WAR tu ne continues pas tranquillement un goal “build market”…).


Je te propose une intégration **minimale mais structurante**, sans tout refaire : on ajoute un **FactionWorldContext** (snapshot stratégique par faction) + 2 hooks bidirectionnels.


---


# 1) Nouvelle brique : `FactionWorldContext` (snapshot journalier)

### Objectif


Donner au `FactionGoalPlanner` des signaux stables, et permettre aux arcs de **modifier** la planification.


```
# FactionWorldContext.gd

class\_name FactionWorldContext
extends RefCounted

var day: int
var faction\_id: StringName

# signaux “stratégiques”

var war\_pressure: float = 0.0 # 0..1 (part de paires en WAR/CONFLICT)
var external\_threat: float = 0.0 # 0..1 (menace globale)
var opportunity: float = 0.0 # 0..1 (fenêtres d’opportunité)
var fatigue: float = 0.0 # 0..1 (ex: weariness agrégée)

# priorités/targets calculés

var priority\_targets: Array[StringName] = []
var target\_scores: Dictionary[StringName, float] = {} # faction\_id -> score

# vue arcs

var arcs: Array[Dictionary] = [] # each: {other\_id, pair\_key, state, rel\_mean, tension\_mean, griev\_mean, wear\_mean}
```


---


# 2) Hook A : Les Goals influencent les arcs (targets / posture / opportunités)

### Idée


Ton `FactionGoalPlanner` ne renvoie pas juste “une action”.

Il renvoie une **intent** qui dit : *quel adversaire / quel style / quelle priorité*.


Ex :


* goal “expand territory” → cible préférée = voisin faible (opportunity)
* goal “survive” → posture = défensive (truce/reparations)
* goal “crush rival” → posture agressive (raid/sabotage/declare\_war)


**Mini interface** (sans casser ton existant) :


```
# dans FactionGoalPlanner (ou un wrapper)

func plan\_action(goal, ctx: FactionWorldContext) -> Dictionary:
 # return { "type": "ARC"|"WORLD", "target": faction\_id, "posture": "...", "weight": float, ... }
```


Puis ArcManager consomme ça :


* si `type=="ARC"` : il restreint `allowed actions` et choisit l’action + spawn offers
* sinon : action monde (build, recruit, scout, etc.)


---


# 3) Hook B : Les Arcs modifient les Goals (override / replan / budget split)

### Idée


Quand une paire passe en `WAR` ou `TRUCE`, tu **ne laisses pas** un goal “peaceful” inchangé.


Tu ajoutes un hook dans ton `FactionGoalManagerRunner` :


```
func apply\_arc\_modifiers(faction\_id: StringName, ctx: FactionWorldContext) -> void:
 # Peut: (1) forcer un goal d’urgence, (2) injecter un step, (3) modifier les poids
```


### Règle simple (MVP efficace)


Ordre de priorité :

1) **Survival/Emergency** si `external_threat` ou `war_pressure` élevé

2) **War goals** si une paire est en `WAR`

3) **Conflict goals** si `CONFLICT`

4) sinon goal normal (économie/expansion/culture…)


Ex de “goal override” :


* WAR avec X → goal devient `DEFEND_OR_CONQUER(target=X)`
* TRUCE avec X → goal devient `NEGOTIATE_STABILITY(target=X)` pendant N jours
* ALLIANCE avec X → goal “JOINT\_OP(target\_third\_party)” si menace externe


---


# 4) Calculs concrets (opportunity / external\_threat / priority targets)

### A) Extraire une “arc view” depuis ArcManager


Tu ajoutes à ArcManager un helper :


```
func get\_arc\_view\_for\_faction(faction\_id: StringName) -> Array[Dictionary]:
 # retourne la liste des relations actives + états
 # {other\_id, pair\_key, state, rel\_mean, tension\_mean, griev\_mean, wear\_mean}
 return []
```


### B) Construire `FactionWorldContext` chaque jour (dans WorldSim)


Pseudo-code :


```
func build\_context\_for\_faction(fid: StringName, day: int) -> FactionWorldContext:
 var ctx := FactionWorldContext.new()
 ctx.day = day
 ctx.faction\_id = fid

 ctx.arcs = ArcManagerRunner.get\_arc\_view\_for\_faction(fid)

# war\_pressure / fatigue

 var war\_pairs := 0
 var fatigue\_acc := 0.0
 for a in ctx.arcs:
 var st: StringName = a["state"]
 if st == &"WAR" or st == &"CONFLICT":
 war\_pairs += 1
 fatigue\_acc += float(a.get("wear\_mean", 0.0)) / 100.0
 ctx.war\_pressure = clampf(float(war\_pairs) / max(1.0, float(ctx.arcs.size())), 0.0, 1.0)
 ctx.fatigue = clampf(fatigue\_acc / max(1.0, float(ctx.arcs.size())), 0.0, 1.0)

# target scoring (menace/opportunité)

 for a in ctx.arcs:
 var other := StringName(a["other\_id"])
 var rel := float(a.get("rel\_mean", 0.0))
 var tens := float(a.get("tension\_mean", 0.0))
 var griev := float(a.get("griev\_mean", 0.0))
 var wear := float(a.get("wear\_mean", 0.0))

# menace: relation négative + tension + grievance (usure réduit la capacité)

 var threat := clampf(max(0.0, -rel) / 100.0, 0.0, 1.0) * (tens/100.0) * (0.6 + 0.4*(griev/100.0)) * (1.0 - 0.5*(wear/100.0))

# opportunité: relation très basse ET wear adverse (si tu l’as) / ou tension haute + rel très basse

 var opp := clampf((tens/100.0) * max(0.0, (-rel - 30.0)/70.0), 0.0, 1.0)

 ctx.target\_scores[other] = threat + 0.6 * opp
 ctx.priority\_targets = \_top\_targets(ctx.target\_scores, 3)

# external\_threat = max ou moyenne des menaces

 ctx.external\_threat = \_aggregate\_threat(ctx.target\_scores)

 return ctx
```


( `_top_targets` et `_aggregate_threat` sont triviales.)


---


# 5) Boucle monde cohérente (ordre d’exécution recommandé)


Dans ton `WorldSim.tick_day()` :


1) **ArcManager tick** (stabilité + transitions)


* pour chaque paire : `tick_day_for_pair()` + éventuelle transition via `update_arc_state()` si events

2) **Construire contexts** pour chaque faction

3) **Goal system** :
* `FactionGoalManagerRunner.ensure_goal(fid, ctx)` (signature enrichie)
* `FactionGoalManagerRunner.apply_arc_modifiers(fid, ctx)`
* `action_intent = FactionGoalPlanner.plan_action(goal, ctx)`

4) **Exécuter l’intent** :
* si intent ARC : `ArcManagerRunner.spawn_offers_from_intent(fid, intent, ctx)`
* sinon : action monde normale (build, scout, recruit…)

5) **QuestPool** : caps/expiration/cleanup


Ça rend les arcs **ancrés** : ils ne sortent plus “de nulle part”, ils deviennent une conséquence de la stratégie et des pressions.


---


# 6) Le minimum à coder maintenant (sans refactor massif)

### À ajouter


* `FactionWorldContext` + `build_context_for_faction()`
* `ArcManager.get_arc_view_for_faction()`
* `FactionGoalManagerRunner.apply_arc_modifiers()`
* `FactionGoalPlanner.plan_action(goal, ctx)` qui peut rester très simple au début (même juste “si WAR→ARC sinon WORLD”)

### Ce que ça débloque immédiatement


* Pas d’arcs “hors-sol”
* Les goals changent quand la diplomatie/guerre change
* Les targets deviennent cohérents (priority\_targets)


---


Si tu veux, prochaine étape logique : je te donne un **MVP concret** de `apply_arc_modifiers()` (10–30 lignes) avec 3 goals d’urgence (WAR/CONFLICT/TRUCE) + comment “revenir” au goal précédent après N jours (via un petit stack ou un `suspended_goal`).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 8](#toc-detail-ch8)
<a id="moi-50"></a>
**Moi 50:**
donne un MVP concret de apply\_arc\_modifiers() (10–30 lignes) avec 3 goals d’urgence (WAR/CONFLICT/TRUCE) + comment “revenir” au goal précédent après N jours (via un petit stack ou un suspended\_goal).


**ChatGPT:**
Voici un MVP **concret** (court, robuste) pour `apply_arc_modifiers()` avec 3 goals d’urgence **WAR / CONFLICT / TRUCE** + retour au goal précédent via `suspended_goal`.


## Hypothèses minimales


* Tu as un stockage par faction du goal courant, ex: `goals_by_faction[fid]`.
* Un goal est un `Dictionary` (ou une classe) avec au moins `id`, et éventuellement `target_faction_id`.
* Tu peux créer un goal via `GoalFactory.make_goal(goal_id, data)` (à adapter).


---


## 1) Données à ajouter au goal courant


Dans le goal courant (Dictionary), on va stocker :


* `suspended_goal` : l’ancien goal sauvegardé
* `override_until_day` : jour de fin de l’override


---


## 2) MVP `apply_arc_modifiers()`


```
func apply\_arc\_modifiers(faction\_id: StringName, ctx: FactionWorldContext) -> void:
 var goal: Dictionary = goals\_by\_faction.get(faction\_id, {})
 if goal.is\_empty():
 return

 # 1) Si on est dans un override et qu’il est terminé => restore
 var until := int(goal.get("override\_until\_day", -1))
 if until >= 0 and ctx.day >= until:
 if goal.has("suspended\_goal"):
 goals\_by\_faction[faction\_id] = goal["suspended\_goal"]
 return

 # 2) Déterminer l’urgence dominante (WAR > CONFLICT > TRUCE) sur la meilleure cible
 var best\_target: StringName = &""
 var best\_state: StringName = &"NEUTRAL"
 for a in ctx.arcs:
 var st: StringName = a.get("state", &"NEUTRAL")
 if st == &"WAR":
 best\_state = &"WAR"
 best\_target = StringName(a.get("other\_id", &""))
 break
 elif st == &"CONFLICT" and best\_state != &"WAR":
 best\_state = &"CONFLICT"
 best\_target = StringName(a.get("other\_id", &""))
 elif st == &"TRUCE" and best\_state == &"NEUTRAL":
 best\_state = &"TRUCE"
 best\_target = StringName(a.get("other\_id", &""))

 if best\_state == &"NEUTRAL" or best\_target == &"":
 return

 # 3) Si déjà sur le bon goal d’urgence => rien
 var gid := String(goal.get("id", ""))
 if (best\_state == &"WAR" and gid == "GOAL\_WAR") \
 or (best\_state == &"CONFLICT" and gid == "GOAL\_CONFLICT") \
 or (best\_state == &"TRUCE" and gid == "GOAL\_TRUCE"):
 return

 # 4) Appliquer override: sauvegarder l’ancien goal + poser une durée (N jours)
 var duration := 0
 match best\_state:
 &"WAR": duration = 14
 &"CONFLICT": duration = 8
 &"TRUCE": duration = 6

 var new\_goal := {}
 match best\_state:
 &"WAR":
 new\_goal = {"id":"GOAL\_WAR", "target\_faction\_id": best\_target, "mode":"total\_war"}
 &"CONFLICT":
 new\_goal = {"id":"GOAL\_CONFLICT", "target\_faction\_id": best\_target, "mode":"pressure"}
 &"TRUCE":
 new\_goal = {"id":"GOAL\_TRUCE", "target\_faction\_id": best\_target, "mode":"stabilize"}

 new\_goal["suspended\_goal"] = goal
 new\_goal["override\_until\_day"] = ctx.day + duration

 goals\_by\_faction[faction\_id] = new\_goal
```


---


## 3) Comment ça “revient” au goal précédent


* Quand `ctx.day >= override_until_day`, on restore `suspended_goal`.
* Donc le goal normal reprend automatiquement **sans état global compliqué**.


### Variante “stack” (si tu veux plusieurs overrides imbriqués)


Pour l’instant, ce MVP garde **un seul niveau** (suffisant et stable).

Si tu veux un stack plus tard :


* `suspended_goals: Array[Dictionary]`
* push l’ancien à chaque override, pop à la fin.


---


## 4) Bonus (facultatif mais utile)


Si tu veux empêcher qu’un override remplace un override trop souvent :


* mets un `goal_override_lock_until_day` dans `goals_by_faction[fid]` ou dans `ArcNotebook`,
* et n’override que si `ctx.day >= lock_until`.


---


Si tu veux, prochaine brique logique : un `plan_action(goal, ctx)` MVP correspondant (WAR→générer offers WAR, TRUCE→offers trêve, etc.) pour boucler proprement le triangle **Goals ↔ Arcs ↔ QuestPool**.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 8](#toc-detail-ch8)
<a id="moi-51"></a>
**Moi 51:**
prochaine brique logique : un plan\_action(goal, ctx) MVP correspondant (WAR→générer offers WAR, TRUCE→offers trêve, etc.) pour boucler proprement le triangle Goals ↔ Arcs ↔
<a id="cite-questpool-43825e-6"></a>QuestPool.


**ChatGPT:**
Voici un MVP **plan\_action(goal, ctx)** qui ferme proprement la boucle **Goals → Arcs → QuestPool** sans refactor lourd.


L’idée : `plan_action()` retourne une **intent** simple :


* soit `type="ARC"` (demande à ArcManager de générer des offers contre une cible),
* soit `type="WORLD"` (action monde non-arc),
* soit `type="NONE"`.


---


## 1) `FactionGoalPlanner.plan_action(goal, ctx)` (MVP)


```
# FactionGoalPlanner.gd (ou un util)

func plan\_action(goal: Dictionary, ctx: FactionWorldContext, rng: RandomNumberGenerator) -> Dictionary:
 var gid := String(goal.get("id", ""))
 var target: StringName = StringName(goal.get("target\_faction\_id", &""))

# fallback: si le goal n’a pas de cible, prendre le meilleur target du contexte

 if target == &"" and ctx.priority\_targets.size() > 0:
 target = StringName(ctx.priority\_targets[0])

# --- Goals d’urgence (ceux posés par apply\_arc\_modifiers) ---

 if gid == "GOAL\_WAR":
 return {
 "type": "ARC",
 "target\_faction\_id": target,
 "preferred\_actions": [ArcDecisionUtil.ARC\_DECLARE\_WAR, ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_SABOTAGE],
 "priority": 1.0,
 "tier\_bias": +2, # WAR -> tier plus haut
 }

 if gid == "GOAL\_CONFLICT":
 return {
 "type": "ARC",
 "target\_faction\_id": target,
 "preferred\_actions": [ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_SABOTAGE, ArcDecisionUtil.ARC\_ULTIMATUM],
 "priority": 0.8,
 "tier\_bias": +1,
 }

 if gid == "GOAL\_TRUCE":
 return {
 "type": "ARC",
 "target\_faction\_id": target,
 "preferred\_actions": [ArcDecisionUtil.ARC\_TRUCE\_TALKS, ArcDecisionUtil.ARC\_REPARATIONS, ArcDecisionUtil.ARC\_ALLIANCE\_OFFER],
 "priority": 0.7,
 "tier\_bias": 0,
 }

 # --- Goals “normaux” (MVP) : parfois ARC, parfois WORLD ---
 # Exemple simple: si menace externe forte, réduire les arcs hostiles
 if ctx.external\_threat >= 0.6:
 return {"type":"WORLD", "action":"fortify", "priority":0.7}

 # Si grosse opportunité, autoriser une action ARC opportuniste
 if ctx.opportunity >= 0.55 and target != &"":
 return {
 "type": "ARC",
 "target\_faction\_id": target,
 "preferred\_actions": [ArcDecisionUtil.ARC\_ULTIMATUM, ArcDecisionUtil.ARC\_RAID],
 "priority": 0.55,
 "tier\_bias": 0,
 }

 # Sinon action monde par défaut
 return {"type":"WORLD", "action":"develop", "priority":0.4}
```


---


## 2) Côté ArcManager : consommer l’intent et générer des offers


### Helper “pick action depuis intent + policy”


```
func \_pick\_action\_from\_intent(intent: Dictionary, arc\_state: ArcState, rng: RandomNumberGenerator) -> StringName:
 var prefs: Array = intent.get("preferred\_actions", [])
 var proposed: StringName = ArcDecisionUtil.ARC\_IGNORE
 if prefs.size() > 0:
 proposed = prefs[rng.randi\_range(0, prefs.size() - 1)]
 else:
 proposed = ArcDecisionUtil.select\_arc\_action\_type(...)

# si tu veux fallback

 # Filtrer selon l’état (WAR/RIVALRY/etc.)
 return ArcPolicy.filter\_action\_for\_state(arc\_state.state, proposed, rng)
```


### Helper “tier” depuis état + bias


```
func \_tier\_for\_state(state: StringName) -> int:
 match state:
 &"WAR": return 3
 &"CONFLICT": return 2
 &"RIVALRY": return 1
 &"TRUCE": return 1
 &"ALLIANCE": return 2
 \_: return 1

func \_apply\_tier\_bias(base\_tier: int, bias: int) -> int:
 return clampi(base\_tier + bias, 1, 5)
```


### Consommation dans la boucle monde


Dans ton `WorldSim.tick_day()` (ou `FactionSim.apply()`), après `intent = plan_action(...)` :


```
if intent.get("type","") == "ARC":
 var target: StringName = intent.get("target\_faction\_id", &"")
 if target == &"":
 return

 var pair\_state: ArcState = ArcManagerRunner.get\_or\_create\_pair\_state(faction\_id, target)
 ArcStateMachine.tick\_day\_for\_pair(pair\_state, relations[faction\_id][target], relations[target][faction\_id])

 var action := \_pick\_action\_from\_intent(intent, pair\_state, \_rng)
 if action == ArcDecisionUtil.ARC\_IGNORE:
 return

 var base\_tier := \_tier\_for\_state(pair\_state.state)
 var tier := \_apply\_tier\_bias(base\_tier, int(intent.get("tier\_bias", 0)))

# Ici tu utilises ta logique "cap concurrent + upgrade possible"

 \_ensure\_arc\_offers\_for\_pair(
 QuestPool,
 ArcManagerRunner.get\_arc\_id\_for\_pair(faction\_id, target),
 pair\_state,
 faction\_id,
 target,
 action,
 relations[faction\_id][target],
 faction\_profiles,
 faction\_economies,
 budget\_mgr,
 \_rng, ctx.day,
 tier
 )
```


---


## 3) Ce que ça donne en pratique


* WAR → le goal force **actions hostiles** (raid/sabotage/declare\_war) + tier plus élevé → meilleures quêtes, plus rares (budget/or).
* TRUCE → le goal force **actions paix** (truce/reparations/alliance) → quêtes diplomatiques/logistiques.
* Les goals “normaux” peuvent générer des arcs opportunistes mais sinon font des actions monde.


C’est déjà suffisant pour que les arcs ne soient plus “hors-sol”.


---


Si tu veux, prochaine brique (très utile) : une fonction `compute_opportunity/external_threat` mieux définie + une règle simple “si fatigue>0.7 => privilégier TRUCE/REPARATIONS même si CONFLICT”.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 8](#toc-detail-ch8)
<a id="moi-52"></a>
**Moi 52:**
prochaine brique (très utile) : une fonction compute\_opportunity/external\_threat mieux définie + une règle simple “si fatigue>0.7 => privilégier TRUCE/REPARATIONS même si CONFLICT”.


**ChatGPT:**
Voici une version **mieux définie** de `compute_external_threat()` / `compute_opportunity()` + une règle simple de **fatigue** qui pousse vers **TRUCE/REPARATIONS** même en CONFLICT.


Je pars de ton `FactionWorldContext.arcs` (liste d’entrées `{state, rel_mean, tension_mean, griev_mean, wear_mean, other_id, ...}`).


---


## 1) Fonctions de calcul


### `compute_external_threat(ctx)`


But : mesurer “à quel point la faction est menacée” (0..1).

On combine :


* **hostility** (relation négative)
* **pressure** (tension + grievance)
* **immediacy** (état WAR/CONFLICT)
* **self fatigue** (si tu es usé, la menace est “pire”)


```
static func compute\_external\_threat(ctx: FactionWorldContext) -> float:
 if ctx.arcs.is\_empty():
 return 0.0

 var sum := 0.0
 var max\_t := 0.0

 for a in ctx.arcs:
 var st: StringName = a.get("state", &"NEUTRAL")
 var rel := float(a.get("rel\_mean", 0.0))
 var tens := float(a.get("tension\_mean", 0.0)) / 100.0
 var griev := float(a.get("griev\_mean", 0.0)) / 100.0
 var wear := float(a.get("wear\_mean", 0.0)) / 100.0

 # 0..1 : plus relation est négative, plus host élevé
 var host := clampf(max(0.0, -rel) / 100.0, 0.0, 1.0)

# état = immédiateté

 var state\_mul := 0.25
 match st:
 &"WAR": state\_mul = 1.00
 &"CONFLICT": state\_mul = 0.80
 &"RIVALRY": state\_mul = 0.55
 &"TRUCE": state\_mul = 0.35
 &"ALLIANCE": state\_mul = 0.10

 # pression combinée
 var pressure := clampf(0.65 * tens + 0.35 * griev, 0.0, 1.0)

# menace de cette paire

 var t := host * pressure * state\_mul

 # la fatigue locale réduit ta capacité => menace perçue augmente légèrement
 t *= (1.0 + 0.35 * wear)

 sum += t
 if t > max\_t:
 max\_t = t

 # external\_threat = mix max (danger immédiat) + moyenne (pression globale)
 var avg := sum / float(ctx.arcs.size())
 var fatigue\_boost := 1.0 + 0.20 * clampf(ctx.fatigue, 0.0, 1.0)
 return clampf((0.65 * max\_t + 0.35 * avg) * fatigue\_boost, 0.0, 1.0)
```


---


### `compute_opportunity(ctx)`


But : détecter “une fenêtre d’attaque rentable” (0..1).

On favorise :


* hostilité forte (relation très négative)
* tension haute (conflit mûr)
* **mais** on pénalise si **toi** tu es fatigué (tu ne peux pas capitaliser)
* on boost si l’adversaire est en TRUCE/RIVALRY (plus vulnérable politiquement)


Comme on n’a pas la fatigue adverse, on s’appuie sur l’état et la tension.


```
static func compute\_opportunity(ctx: FactionWorldContext) -> float:
 if ctx.arcs.is\_empty():
 return 0.0

 var best := 0.0
 for a in ctx.arcs:
 var st: StringName = a.get("state", &"NEUTRAL")
 var rel := float(a.get("rel\_mean", 0.0))
 var tens := float(a.get("tension\_mean", 0.0)) / 100.0
 var griev := float(a.get("griev\_mean", 0.0)) / 100.0

 var host := clampf(max(0.0, -rel - 20.0) / 80.0, 0.0, 1.0)

# nécessite déjà une hostilité “installée”

 var heat := clampf(0.70 * tens + 0.30 * griev, 0.0, 1.0)

# état “opportunity” : TRUCE/RIVALRY sont plus “exploitables” que WAR (où c’est déjà engagé)

 var state\_mul := 0.35
 match st:
 &"TRUCE": state\_mul = 1.00
 &"RIVALRY": state\_mul = 0.85
 &"CONFLICT": state\_mul = 0.70
 &"WAR": state\_mul = 0.45
 &"ALLIANCE": state\_mul = 0.10

 # opportunité locale
 var o := host * heat * state\_mul

 # ta fatigue pénalise ta capacité à exploiter l’opportunité
 o *= (1.0 - 0.60 * clampf(ctx.fatigue, 0.0, 1.0))

 best = max(best, o)

 return clampf(best, 0.0, 1.0)
```


---


## 2) Règle “fatigue > 0.7 => privilégier TRUCE/REPARATIONS même si CONFLICT”


Tu peux l’implémenter **dans le planner** (c’est le meilleur endroit), ou comme override de `preferred_actions`.


### Patch minimal dans `plan_action(goal, ctx, rng)`


Juste avant de retourner l’intent CONFLICT :


```
if gid == "GOAL\_CONFLICT":
 # règle fatigue
 if ctx.fatigue >= 0.70:
 return {
 "type": "ARC",
 "target\_faction\_id": target,
 "preferred\_actions": [ArcDecisionUtil.ARC\_TRUCE\_TALKS, ArcDecisionUtil.ARC\_REPARATIONS],
 "priority": 0.85,
 "tier\_bias": 0,
 "reason": "fatigue\_override"
 }

 return {
 "type": "ARC",
 "target\_faction\_id": target,
 "preferred\_actions": [ArcDecisionUtil.ARC\_RAID, ArcDecisionUtil.ARC\_SABOTAGE, ArcDecisionUtil.ARC\_ULTIMATUM],
 "priority": 0.8,
 "tier\_bias": +1,
 }
```


### Variante encore plus simple (sans toucher aux goals)


Si tu veux que ça s’applique “même si le goal est autre chose” :


* après calcul de l’intent, si `ctx.fatigue >= 0.7` et `intent.type=="ARC"` et `intent` est hostile → remplace par `TRUCE/REPARATIONS`.


---


## 3) Où les appeler


Dans ton `build_context_for_faction()` :


```
ctx.external\_threat = WorldMetrics.compute\_external\_threat(ctx)
ctx.opportunity = WorldMetrics.compute\_opportunity(ctx)
```


(ou direct si tu gardes les fonctions statiques dans un util `WorldMetrics.gd`).


---


Si tu veux, prochaine brique logique : une fonction `compute_priority_targets(ctx)` qui utilise **threat** et **opportunity** pour choisir une cible cohérente (pas forcément la même), et qui peut retourner “meilleur ennemi” + “meilleur futur allié”.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 8](#toc-detail-ch8)
<a id="moi-53"></a>
**Moi 53:**
prochaine brique logique : une fonction compute\_priority\_targets(ctx) qui utilise threat et opportunity pour choisir une cible cohérente (pas forcément la même), et qui peut retourner “meilleur ennemi” + “meilleur futur allié”.

Il faut aussi que ca prenne en compte le nombre d'action hostile ou amicale fait par la faction qu'on vise (dans le passé et en cours actuellement).


**ChatGPT:**
OK — on peut faire ça proprement avec un “score ennemi” et un “score allié” calculés **par paire** à partir de :


* l’état courant (WAR/CONFLICT/TRUCE/…),
* `rel_mean / trust_mean / tension_mean / griev_mean / wear_mean`,
* **et** l’historique des actions **du target vers nous** (hostile/amical), avec un **poids de récence** (heat/decay).


Je te propose :


1) un micro-ajout à `ArcNotebook` : `PairHeat` + `record_pair_event()` + `get_pair_heat()`

2) `compute_priority_targets(ctx, notebook, self_id)` qui renvoie :


* `best_enemy`
* `best_ally`
* des rankings (debug/metrics)


---


## 1) Micro-ajout ArcNotebook : “heat” hostile/amical par paire


### `PairHeat.gd`


```
class\_name PairHeat
extends RefCounted

var last\_day: int = -999999

var hostile\_ab: float = 0.0
var friendly\_ab: float = 0.0
var hostile\_ba: float = 0.0
var friendly\_ba: float = 0.0

func decay\_to(day: int, decay\_per\_day: float = 0.93) -> void:
 var dt := max(0, day - last\_day)
 if dt == 0:
 return
 var f := pow(decay\_per\_day, float(dt))
 hostile\_ab *= f
 friendly\_ab *= f
 hostile\_ba *= f
 friendly\_ba *= f
 last\_day = day
```


### Ajouts dans `ArcNotebook.gd`


```
# ArcNotebook.gd

var pair\_heat\_by\_key: Dictionary[StringName, PairHeat] = {} # "a|b" -> heat

static func \_pair\_key(a: StringName, b: StringName) -> StringName:
 return StringName((String(a) <= String(b)) ? (String(a) + "|" + String(b)) : (String(b) + "|" + String(a)))

static func \_severity\_for\_action(action: StringName) -> float:
 match action:
 ArcDecisionUtil.ARC\_DECLARE\_WAR: return 3.0
 ArcDecisionUtil.ARC\_RAID: return 1.0
 ArcDecisionUtil.ARC\_SABOTAGE: return 1.2
 ArcDecisionUtil.ARC\_ULTIMATUM: return 0.8
 ArcDecisionUtil.ARC\_TRUCE\_TALKS: return 1.2
 ArcDecisionUtil.ARC\_REPARATIONS: return 1.0
 ArcDecisionUtil.ARC\_ALLIANCE\_OFFER:return 1.6
 \_: return 1.0

func record\_pair\_event(attacker: StringName, defender: StringName, action: StringName, day: int) -> void:
 var key := \_pair\_key(attacker, defender)
 var heat: PairHeat = pair\_heat\_by\_key.get(key, null)
 if heat == null:
 heat = PairHeat.new()
 heat.last\_day = day
 pair\_heat\_by\_key[key] = heat
 heat.decay\_to(day)

 var sev := \_severity\_for\_action(action)
 var a\_is\_first := (String(attacker) <= String(defender))

 if ArcStateMachine.is\_hostile\_action(action):
 if a\_is\_first:
 heat.hostile\_ab += sev
 else:
 heat.hostile\_ba += sev
 elif ArcStateMachine.is\_peace\_action(action):
 if a\_is\_first:
 heat.friendly\_ab += sev
 else:
 heat.friendly\_ba += sev

func get\_pair\_heat(self\_id: StringName, other\_id: StringName, day: int, decay\_per\_day: float = 0.93) -> Dictionary:
 var key := \_pair\_key(self\_id, other\_id)
 var heat: PairHeat = pair\_heat\_by\_key.get(key, null)
 if heat == null:
 return {"hostile\_from\_other":0.0, "friendly\_from\_other":0.0, "hostile\_to\_other":0.0, "friendly\_to\_other":0.0}

 heat.decay\_to(day, decay\_per\_day)

# Reconstituer le sens self->other / other->self

 var self\_is\_first := (String(self\_id) <= String(other\_id))
 var hostile\_to\_other := heat.hostile\_ab if self\_is\_first else heat.hostile\_ba
 var friendly\_to\_other := heat.friendly\_ab if self\_is\_first else heat.friendly\_ba
 var hostile\_from\_other := heat.hostile\_ba if self\_is\_first else heat.hostile\_ab
 var friendly\_from\_other := heat.friendly\_ba if self\_is\_first else heat.friendly\_ab

 return {
 "hostile\_from\_other": hostile\_from\_other,
 "friendly\_from\_other": friendly\_from\_other,
 "hostile\_to\_other": hostile\_to\_other,
 "friendly\_to\_other": friendly\_to\_other
 }
```


✅ Où appeler `record_pair_event()` ?

Au moment où tu appliques un event d’arc / résolution (QuestManager→ArcManager), avec `(attacker=giver, defender=antagonist, action=arc_action_type, day)`.


---


## 2) `compute_priority_targets(ctx)` : meilleur ennemi + meilleur allié


### `WorldTargeting.gd`


```
class\_name WorldTargeting
extends RefCounted

static func \_state\_threat\_mul(st: StringName) -> float:
 match st:
 &"WAR": return 1.00
 &"CONFLICT": return 0.80
 &"RIVALRY": return 0.55
 &"TRUCE": return 0.30
 &"ALLIANCE": return 0.10
 \_: return 0.25

static func \_state\_opp\_mul(st: StringName) -> float:
 match st:
 &"TRUCE": return 1.00
 &"RIVALRY": return 0.85
 &"CONFLICT": return 0.70
 &"WAR": return 0.45
 &"ALLIANCE": return 0.10
 \_: return 0.35

static func \_pair\_threat(a: Dictionary, self\_fatigue: float) -> float:
 var st: StringName = a.get("state", &"NEUTRAL")
 var rel := float(a.get("rel\_mean", 0.0))
 var tens := float(a.get("tension\_mean", 0.0)) / 100.0
 var griev := float(a.get("griev\_mean", 0.0)) / 100.0
 var wear := float(a.get("wear\_mean", 0.0)) / 100.0

 var host := clampf(max(0.0, -rel) / 100.0, 0.0, 1.0)
 var pressure := clampf(0.65 * tens + 0.35 * griev, 0.0, 1.0)
 var t := host * pressure * \_state\_threat\_mul(st)
 t *= (1.0 + 0.35 * wear) * (1.0 + 0.20 * clampf(self\_fatigue, 0.0, 1.0))
 return clampf(t, 0.0, 1.0)

static func \_pair\_opportunity(a: Dictionary, self\_fatigue: float) -> float:
 var st: StringName = a.get("state", &"NEUTRAL")
 var rel := float(a.get("rel\_mean", 0.0))
 var tens := float(a.get("tension\_mean", 0.0)) / 100.0
 var griev := float(a.get("griev\_mean", 0.0)) / 100.0

 var host := clampf(max(0.0, -rel - 20.0) / 80.0, 0.0, 1.0)
 var heat := clampf(0.70 * tens + 0.30 * griev, 0.0, 1.0)

 var o := host * heat * \_state\_opp\_mul(st)
 o *= (1.0 - 0.60 * clampf(self\_fatigue, 0.0, 1.0))
 return clampf(o, 0.0, 1.0)

static func compute\_priority\_targets(
 ctx: FactionWorldContext,
 notebook: ArcNotebook,
 self\_id: StringName,
 decay\_per\_day: float = 0.93
) -> Dictionary:
 var best\_enemy := &""
 var best\_enemy\_score := -1e9
 var best\_ally := &""
 var best\_ally\_score := -1e9

 var enemy\_rank: Array = []
 var ally\_rank: Array = []

 for a in ctx.arcs:
 var other: StringName = StringName(a.get("other\_id", &""))
 if other == &"":
 continue

 var rel := float(a.get("rel\_mean", 0.0))
 var trust := float(a.get("trust\_mean", 0.0))
 var st: StringName = a.get("state", &"NEUTRAL")

 var threat := \_pair\_threat(a, ctx.fatigue)
 var opp := \_pair\_opportunity(a, ctx.fatigue)

# Historique (heat décadent) : ce que l’autre a fait envers nous

 var h := notebook.get\_pair\_heat(self\_id, other, ctx.day, decay\_per\_day)
 var hostile\_from := float(h["hostile\_from\_other"])
 var friendly\_from := float(h["friendly\_from\_other"])

# Normaliser heat -> 0..1 (soft cap)

 var hostile\_n := 1.0 - exp(-0.35 * hostile\_from)

# 0..~1

 var friendly\_n := 1.0 - exp(-0.35 * friendly\_from)

# --- Score ennemi ---

 # menace + opportunité + hostilité récente de l’autre
 var enemy\_score := 1.00*threat + 0.70*opp + 0.55*hostile\_n - 0.35*friendly\_n
 # si relation déjà positive, on pénalise (évite de choisir comme “ennemi” un allié)
 enemy\_score -= 0.25 * clampf((rel) / 100.0, 0.0, 1.0)

# --- Score allié ---

 # relation + trust + gestes amicaux récents, pénalise hostilité
 var rel\_pos := clampf(rel / 100.0, 0.0, 1.0)
 var trust\_pos := clampf(trust / 100.0, 0.0, 1.0)
 var ally\_score := 0.70*rel\_pos + 0.55*trust\_pos + 0.70*friendly\_n - 0.85*hostile\_n
 # si on est en WAR/CONFLICT, on baisse un peu la probabilité “allié” avec cet autre
 if st == &"WAR" or st == &"CONFLICT":
 ally\_score *= 0.55

 enemy\_rank.append({"id": other, "score": enemy\_score, "threat": threat, "opp": opp, "hostile": hostile\_from, "friendly": friendly\_from})
 ally\_rank.append({"id": other, "score": ally\_score, "rel": rel, "trust": trust, "hostile": hostile\_from, "friendly": friendly\_from})

 if enemy\_score > best\_enemy\_score:
 best\_enemy\_score = enemy\_score
 best\_enemy = other

 if ally\_score > best\_ally\_score:
 best\_ally\_score = ally\_score
 best\_ally = other

 # Évite best\_enemy == best\_ally : si collision, prend le 2ème meilleur ally
 if best\_enemy != &"" and best\_enemy == best\_ally:
 ally\_rank.sort\_custom(func(x,y): return float(x["score"]) > float(y["score"]))
 for item in ally\_rank:
 var oid: StringName = item["id"]
 if oid != best\_enemy:
 best\_ally = oid
 best\_ally\_score = float(item["score"])
 break

 # Tri debug/metrics
 enemy\_rank.sort\_custom(func(x,y): return float(x["score"]) > float(y["score"]))
 ally\_rank.sort\_custom(func(x,y): return float(x["score"]) > float(y["score"]))

 return {
 "best\_enemy": best\_enemy,
 "best\_enemy\_score": best\_enemy\_score,
 "best\_ally": best\_ally,
 "best\_ally\_score": best\_ally\_score,
 "enemy\_rank": enemy\_rank,
 "ally\_rank": ally\_rank
 }
```


### Comment l’utiliser


Dans `build_context_for_faction()` :


```
var tgt := WorldTargeting.compute\_priority\_targets(ctx, ArcManagerRunner.arc\_notebook, fid)
ctx.priority\_targets = []
if tgt["best\_enemy"] != &"": ctx.priority\_targets.append(tgt["best\_enemy"])
if tgt["best\_ally"] != &"": ctx.priority\_targets.append(tgt["best\_ally"])
```


---


## 3) Ce que ça apporte (très concret)


* La cible “ennemi” n’est pas seulement “relation négative”, mais aussi :
	+ menace/opportunité **et** “ils ont été hostiles récemment”.
* La cible “allié” favorise :
	+ relation/trust **et** “ils ont fait des gestes amicaux récemment”.
* Et comme c’est du **heat décadent**, ça reflète “passé + en cours” naturellement.


Si tu veux, prochaine brique : un mini test qui simule 30 jours d’events `record_pair_event()` et vérifie que `best_enemy/best_ally` basculent correctement quand on inverse les actions (ex: B fait 3 raids sur A puis 2 réparations).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 8](#toc-detail-ch8)
<a id="moi-54"></a>
**Moi 54:**
prochaine brique : un mini test qui simule 30 jours d’events record\_pair\_event() et vérifie que best\_enemy/best\_ally basculent correctement quand on inverse les actions (ex: B fait 3 raids sur A puis 2 réparations).


**ChatGPT:**
Voici un **mini test Godot (GDScript)** qui simule **30 jours** d’événements `record_pair_event()` et vérifie le basculement :


* **Jour 10** : `best_enemy == B` (B a fait 3 raids sur A)
* **Jour 30** : `best_ally == B` (B fait 2 réparations + contexte relation/trust amélioré), et `best_enemy == C` (reste hostile)


>
> Pré-requis : `ArcNotebook.record_pair_event()`, `FactionWorldContext`, `WorldTargeting.compute_priority_targets()` existent (comme on vient de poser).
>
>  Tu peux placer ce fichier dans ton dossier tests/harness.
>
>
>


---


## `tests/WorldTargetingHeatTest.gd`


```
extends Node
class\_name WorldTargetingHeatTest

var rng := RandomNumberGenerator.new()

func \_ready() -> void:
 rng.seed = 424242

 \_test\_priority\_targets\_shift\_with\_heat\_inversion()

 print("\n✅ WorldTargetingHeatTest: OK\n")
 get\_tree().quit()


func \_test\_priority\_targets\_shift\_with\_heat\_inversion() -> void:
 var nb := ArcNotebook.new()
 var self\_id := &"A"
 var b := &"B"
 var c := &"C"

 # Base context for A (2 pairs: A-B and A-C)
 var ctx := FactionWorldContext.new()
 ctx.faction\_id = self\_id
 ctx.fatigue = 0.20

 # --- Initial arc snapshot (day 1..10): B is the worst, C is bad-but-less ---
 var arc\_b := {
 "other\_id": b,
 "pair\_key": &"A|B",
 "state": &"RIVALRY",
 "rel\_mean": -70.0,
 "trust\_mean": 20.0,
 "tension\_mean": 70.0,
 "griev\_mean": 60.0,
 "wear\_mean": 20.0
 }
 var arc\_c := {
 "other\_id": c,
 "pair\_key": &"A|C",
 "state": &"RIVALRY",
 "rel\_mean": -50.0,
 "trust\_mean": 30.0,
 "tension\_mean": 55.0,
 "griev\_mean": 40.0,
 "wear\_mean": 10.0
 }
 ctx.arcs = [arc\_b, arc\_c]

 # --- Simulate 30 days of events ---
 for day in range(1, 31):
 ctx.day = day

 # B raids A on days 2, 4, 6
 if day == 2 or day == 4 or day == 6:
 nb.record\_pair\_event(b, self\_id, ArcDecisionUtil.ARC\_RAID, day)

# B makes reparations to A on days 25, 27

 if day == 25 or day == 27:
 nb.record\_pair\_event(b, self\_id, ArcDecisionUtil.ARC\_REPARATIONS, day)

# At day 10: B should clearly be best\_enemy

 if day == 10:
 var res10 := WorldTargeting.compute\_priority\_targets(ctx, nb, self\_id)
 \_assert(StringName(res10["best\_enemy"]) == b, "day10: best\_enemy should be B after 3 raids")

# On ne force pas best\_ally ici (trop tôt / relations négatives)

# --- Now invert the "current situation" at day 30: B becomes a truce partner ---

 ctx.day = 30
 arc\_b["state"] = &"TRUCE"
 arc\_b["rel\_mean"] = 45.0
 arc\_b["trust\_mean"] = 70.0
 arc\_b["tension\_mean"] = 15.0
 arc\_b["griev\_mean"] = 10.0
 arc\_b["wear\_mean"] = 25.0

 # C stays hostile
 arc\_c["state"] = &"RIVALRY"
 arc\_c["rel\_mean"] = -55.0
 arc\_c["trust\_mean"] = 25.0
 arc\_c["tension\_mean"] = 60.0
 arc\_c["griev\_mean"] = 45.0
 arc\_c["wear\_mean"] = 12.0

 var res30 := WorldTargeting.compute\_priority\_targets(ctx, nb, self\_id)

 \_assert(StringName(res30["best\_ally"]) == b, "day30: best\_ally should be B after reparations + improved trust/rel")
 \_assert(StringName(res30["best\_enemy"]) == c, "day30: best\_enemy should shift to C once B is no longer the top enemy")

# (Optionnel debug) : vérifier qu'on a bien enregistré des attempts (juste sanity)

# print(res30["enemy\_rank"])

# print(res30["ally\_rank"])


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


### Pourquoi ce test est robuste


* Il ne dépend pas de POI, de QuestGenerator, ni de RNG.
* Il prouve que ton **heat décadent + contexte relation/trust** fait basculer :
	+ l’ennemi prioritaire (B → C)
	+ et l’allié prioritaire (B devient allié)


Si tu veux, je peux ajouter une 2e assertion “quantitative” (ex: `best_enemy_score` baisse pour B entre J10 et J30) pour vérifier la décroissance/renversement plus finement.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 8](#toc-detail-ch8)
<a id="moi-55"></a>
**Moi 55:**
ajouter dans un autre test une 2e assertion “quantitative” (ex: best\_enemy\_score baisse pour B entre J10 et J30) pour vérifier la décroissance/renversement plus finement


**ChatGPT:**
Voici un **second test** dédié aux assertions quantitatives : on mesure le **score “enemy” de B** à J10 puis à J30, et on vérifie qu’il **baisse fortement** (et, bonus utile, que le score “ally” de B **monte**).


## `tests/WorldTargetingQuantitativeShiftTest.gd`


```
extends Node
class\_name WorldTargetingQuantitativeShiftTest

var rng := RandomNumberGenerator.new()

func \_ready() -> void:
 rng.seed = 77777

 \_test\_enemy\_score\_decreases\_for\_B\_between\_day10\_and\_day30()

 print("\n✅ WorldTargetingQuantitativeShiftTest: OK\n")
 get\_tree().quit()


func \_test\_enemy\_score\_decreases\_for\_B\_between\_day10\_and\_day30() -> void:
 var nb := ArcNotebook.new()
 var self\_id := &"A"
 var b := &"B"
 var c := &"C"

 var ctx := FactionWorldContext.new()
 ctx.faction\_id = self\_id
 ctx.fatigue = 0.20

 var arc\_b := {
 "other\_id": b,
 "pair\_key": &"A|B",
 "state": &"RIVALRY",
 "rel\_mean": -70.0,
 "trust\_mean": 20.0,
 "tension\_mean": 70.0,
 "griev\_mean": 60.0,
 "wear\_mean": 20.0
 }
 var arc\_c := {
 "other\_id": c,
 "pair\_key": &"A|C",
 "state": &"RIVALRY",
 "rel\_mean": -50.0,
 "trust\_mean": 30.0,
 "tension\_mean": 55.0,
 "griev\_mean": 40.0,
 "wear\_mean": 10.0
 }
 ctx.arcs = [arc\_b, arc\_c]

 # Simule 30 jours d'events
 for day in range(1, 31):
 ctx.day = day

 # B raid A (3 fois)
 if day == 2 or day == 4 or day == 6:
 nb.record\_pair\_event(b, self\_id, ArcDecisionUtil.ARC\_RAID, day)

# B réparations (2 fois) en fin de période

 if day == 25 or day == 27:
 nb.record\_pair\_event(b, self\_id, ArcDecisionUtil.ARC\_REPARATIONS, day)

# --- Snapshot J10 (B encore en rivalité hostile) ---

 ctx.day = 10
 var res10 := WorldTargeting.compute\_priority\_targets(ctx, nb, self\_id)
 var b\_enemy\_10 := \_score\_for\_id(res10["enemy\_rank"], b)
 var b\_ally\_10 := \_score\_for\_id(res10["ally\_rank"], b)

 \_assert(b\_enemy\_10 != null, "day10: B must appear in enemy\_rank")
 \_assert(b\_ally\_10 != null, "day10: B must appear in ally\_rank")

# --- Snapshot J30 : on inverse la situation courante (B devient partenaire de trêve) ---

 ctx.day = 30
 arc\_b["state"] = &"TRUCE"
 arc\_b["rel\_mean"] = 45.0
 arc\_b["trust\_mean"] = 70.0
 arc\_b["tension\_mean"] = 15.0
 arc\_b["griev\_mean"] = 10.0
 arc\_b["wear\_mean"] = 25.0

 # C reste hostile
 arc\_c["state"] = &"RIVALRY"
 arc\_c["rel\_mean"] = -55.0
 arc\_c["trust\_mean"] = 25.0
 arc\_c["tension\_mean"] = 60.0
 arc\_c["griev\_mean"] = 45.0
 arc\_c["wear\_mean"] = 12.0

 var res30 := WorldTargeting.compute\_priority\_targets(ctx, nb, self\_id)
 var b\_enemy\_30 := \_score\_for\_id(res30["enemy\_rank"], b)
 var b\_ally\_30 := \_score\_for\_id(res30["ally\_rank"], b)

 \_assert(b\_enemy\_30 != null, "day30: B must appear in enemy\_rank")
 \_assert(b\_ally\_30 != null, "day30: B must appear in ally\_rank")

# --- Assertions quantitatives ---

 # 1) Le score ennemi de B doit baisser nettement
 var e10 := float(b\_enemy\_10)
 var e30 := float(b\_enemy\_30)

 \_assert(e30 < e10 - 0.35, "enemy\_score(B) should drop by at least 0.35 (got %.3f -> %.3f)" % [e10, e30])
 \_assert(e30 < e10 * 0.70, "enemy\_score(B) should drop by at least 30%% (got %.3f -> %.3f)" % [e10, e30])

# 2) (Bonus) Le score allié de B doit augmenter nettement

 var a10 := float(b\_ally\_10)
 var a30 := float(b\_ally\_30)

 \_assert(a30 > a10 + 0.25, "ally\_score(B) should rise by at least 0.25 (got %.3f -> %.3f)" % [a10, a30])


func \_score\_for\_id(rank: Array, id: StringName):
 for item in rank:
 if StringName(item.get("id", &"")) == id:
 return item.get("score", null)
 return null


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


### Pourquoi ces seuils sont raisonnables


* Tes scores sont typiquement dans une plage ~[-1 ; +2] selon la heat + threat/opp, donc :
	+ `-0.35` et `-30%` sont des deltas “significatifs” mais pas trop fragiles.
* Et la montée “ally” de `+0.25` reflète bien le passage “rivalité hostile → trêve + gestes amicaux”.


Si tu veux que ce soit encore plus stable, je peux te proposer une version qui compare **la contribution heat** seule (hostile\_n/friendly\_n) en plus du score final.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 8](#toc-detail-ch8)
<a id="moi-56"></a>
**Moi 56:**
Oui dans un autre test


**ChatGPT:**
Voici un **3ᵉ test** focalisé uniquement sur la **contribution “heat”** (hostile/friendly) — sans dépendre de `WorldTargeting`.


Il vérifie quantitativement que :


* la composante **hostile\_from\_other** (normalisée) pour B **baisse** entre J10 et J30 (décroissance/decay),
* la composante **friendly\_from\_other** (normalisée) pour B **augmente** après 2 réparations.


## `tests/PairHeatContributionShiftTest.gd`


```
extends Node
class\_name PairHeatContributionShiftTest

func \_ready() -> void:
 \_test\_heat\_norms\_shift\_between\_day10\_and\_day30()
 print("\n✅ PairHeatContributionShiftTest: OK\n")
 get\_tree().quit()


func \_test\_heat\_norms\_shift\_between\_day10\_and\_day30() -> void:
 var nb := ArcNotebook.new()
 var self\_id := &"A"
 var b := &"B"

 var decay := 0.93
 var k := 0.35 # doit matcher WorldTargeting (hostile\_n = 1 - exp(-k*hostile\_from))

# Simule 30 jours d'events (B -> A)

 for day in range(1, 31):
 # B raid A (3 fois)
 if day == 2 or day == 4 or day == 6:
 nb.record\_pair\_event(b, self\_id, ArcDecisionUtil.ARC\_RAID, day)

# B réparations (2 fois)

 if day == 25 or day == 27:
 nb.record\_pair\_event(b, self\_id, ArcDecisionUtil.ARC\_REPARATIONS, day)

# --- Day 10 heat ---

 var h10 := nb.get\_pair\_heat(self\_id, b, 10, decay)
 var hostile10 := float(h10["hostile\_from\_other"])
 var friendly10 := float(h10["friendly\_from\_other"])
 var hostile\_n10 := \_norm(hostile10, k)
 var friendly\_n10 := \_norm(friendly10, k)

# --- Day 30 heat ---

 var h30 := nb.get\_pair\_heat(self\_id, b, 30, decay)
 var hostile30 := float(h30["hostile\_from\_other"])
 var friendly30 := float(h30["friendly\_from\_other"])
 var hostile\_n30 := \_norm(hostile30, k)
 var friendly\_n30 := \_norm(friendly30, k)

# Assertions qualitatives simples

 \_assert(hostile10 > hostile30, "hostile\_from\_other should decay over time (raw)")
 \_assert(friendly30 > friendly10, "friendly\_from\_other should increase after reparations (raw)")

# Assertions quantitatives robustes (sur la partie normalisée 0..1)

 \_assert(hostile\_n30 < hostile\_n10 - 0.30, "hostile\_n should drop by at least 0.30 (got %.3f -> %.3f)" % [hostile\_n10, hostile\_n30])
 \_assert(friendly\_n30 > friendly\_n10 + 0.25, "friendly\_n should rise by at least 0.25 (got %.3f -> %.3f)" % [friendly\_n10, friendly\_n30])

# (Optionnel) sanity: à J10 friendly devrait être ~0

 \_assert(friendly\_n10 <= 0.05, "friendly\_n at day10 should be near 0 (got %.3f)" % friendly\_n10)


func \_norm(x: float, k: float) -> float:
 # 1 - exp(-k*x) => soft cap vers 1
 return 1.0 - exp(-k * max(0.0, x))


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


Si tu veux rendre ça encore plus “blindé”, on peut aussi vérifier que `hostile_from_other` baisse *même sans changer le contexte relationnel*, juste par le decay (ce test le fait déjà implicitement).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 8](#toc-detail-ch8)
<a id="moi-57"></a>
**Moi 57:**
Oui dans un 4eme test


**ChatGPT:**
Voici un **4ᵉ test** ultra ciblé : il prouve que le **decay seul** fait baisser `hostile_from_other` (et sa version normalisée) **même si aucun événement amical n’arrive** et même si on ne “change” aucun contexte.


## `tests/PairHeatDecayOnlyTest.gd`


```
extends Node
class\_name PairHeatDecayOnlyTest

func \_ready() -> void:
 \_test\_decay\_only\_reduces\_hostile\_heat\_over\_time()
 print("\n✅ PairHeatDecayOnlyTest: OK\n")
 get\_tree().quit()


func \_test\_decay\_only\_reduces\_hostile\_heat\_over\_time() -> void:
 var nb := ArcNotebook.new()
 var a := &"A"
 var b := &"B"

 var decay := 0.93
 var k := 0.35

 # Injecte une "salve" hostile concentrée
 nb.record\_pair\_event(b, a, ArcDecisionUtil.ARC\_RAID, 2)
 nb.record\_pair\_event(b, a, ArcDecisionUtil.ARC\_RAID, 4)
 nb.record\_pair\_event(b, a, ArcDecisionUtil.ARC\_RAID, 6)

# Snapshot jour 10

 var h10 := nb.get\_pair\_heat(a, b, 10, decay)
 var hostile10 := float(h10["hostile\_from\_other"])
 var hostile\_n10 := \_norm(hostile10, k)

# Aucun event ensuite => decay pur

 # Snapshot jour 30
 var h30 := nb.get\_pair\_heat(a, b, 30, decay)
 var hostile30 := float(h30["hostile\_from\_other"])
 var hostile\_n30 := \_norm(hostile30, k)

# Assertions decay-only

 \_assert(hostile30 < hostile10, "raw hostile heat should decay (got %.3f -> %.3f)" % [hostile10, hostile30])
 \_assert(hostile\_n30 < hostile\_n10, "normalized hostile\_n should decay (got %.3f -> %.3f)" % [hostile\_n10, hostile\_n30])

# Quantitatif : baisse “significative”

 \_assert(hostile\_n30 < hostile\_n10 - 0.25, "hostile\_n should drop by at least 0.25 via decay-only (got %.3f -> %.3f)" % [hostile\_n10, hostile\_n30])


func \_norm(x: float, k: float) -> float:
 return 1.0 - exp(-k * max(0.0, x))


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


Ce test est volontairement **indépendant** :


* pas de `WorldTargeting`,
* pas de relation/tension/trust,
* juste `ArcNotebook.record_pair_event()` + `get_pair_heat()` + decay.


Si tu veux, je peux te proposer une petite règle “si dt > 200 jours, clamp à ~0” pour éviter des floats résiduels, mais c’est optionnel.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 8](#toc-detail-ch8)
<a id="moi-58"></a>
**Moi 58:**
On fait :

6) Une notion de “third party” (intervention, médiation, opportunisme)

Très important pour éviter l’escalade binaire A↔B :

• C intervient comme médiateur (trêve) ou profite (raid opportuniste),

• les offres peuvent impliquer 3 factions (donne beaucoup de vie au monde).

Même une version simple (“si A↔B est chaud, C peut proposer trêve/commerce/allié”) ajoute énormément.


**ChatGPT:**
Oui — une “third party layer” est *le* truc qui casse l’escalade binaire A↔B et rend le monde vivant. Je te propose une V1 **simple mais déjà très efficace** : on ne crée pas un “arc à 3” complet, on fait des **offers à 3 factions** **attachées à l’arc principal A↔B** (donc ça impacte bien la rivalité), et on laisse ces offers **créer** (optionnellement) un nouvel arc C↔X si ça dérape.


---


## 1) Contexte standardisé pour une quête “3 factions”


On garde tes clés d’arc, et on ajoute :


```
# Third party keys

"is\_third\_party": true
"third\_party\_faction\_id": StringName # C (giver dans la plupart des cas)
"third\_party\_role": StringName # "MEDIATOR"|"OPPORTUNIST"|"BROKER"
"primary\_pair\_key": StringName # A|B (arc principal)
"side\_a\_faction\_id": StringName # A
"side\_b\_faction\_id": StringName # B
"involved\_factions": Array[StringName] # [A,B,C]
```


Optionnel selon la variante :


```
"beneficiary\_faction\_id": StringName # ex: le camp aidé (commerce/armes/coalition)
"victim\_faction\_id": StringName # ex: camp ciblé (raid opportuniste)
```


---


## 2) Micro-ajout ArcNotebook : cooldown “third party” par paire


```
# ArcNotebook.gd

var last\_third\_party\_day\_by\_pair: Dictionary[StringName, int] = {} # primary\_pair\_key -> day

func can\_spawn\_third\_party(primary\_pair\_key: StringName, day: int, cooldown\_days: int = 7) -> bool:
 var last := int(last\_third\_party\_day\_by\_pair.get(primary\_pair\_key, -999999))
 return (day - last) >= cooldown\_days

func mark\_third\_party\_spawned(primary\_pair\_key: StringName, day: int) -> void:
 last\_third\_party\_day\_by\_pair[primary\_pair\_key] = day
```


---


## 3) Déclencheur : quand considérer qu’une paire A↔B est “chaude”


Tu as déjà les métriques + heat. Un score simple :


```
static func compute\_pair\_hotness(
 day: int,
 notebook: ArcNotebook,
 a\_id: StringName,
 b\_id: StringName,
 rel\_ab: FactionRelationScore,
 rel\_ba: FactionRelationScore
) -> float:
 var tension\_mean := 0.5 * (rel\_ab.tension + rel\_ba.tension) / 100.0
 var griev\_mean := 0.5 * (rel\_ab.grievance + rel\_ba.grievance) / 100.0

 var h := notebook.get\_pair\_heat(a\_id, b\_id, day)

# hostile/friendly both ways

 var hostile\_from\_a := float(h["hostile\_to\_other"])

# A->B

 var hostile\_from\_b := float(h["hostile\_from\_other"])

# B->A (du point de vue de A)

 var hostile\_n := 1.0 - exp(-0.35 * (hostile\_from\_a + hostile\_from\_b))

 return clampf(0.55*tension\_mean + 0.30*griev\_mean + 0.15*hostile\_n, 0.0, 1.0)
```


---


## 4) Choix de la third party C : médiateur vs opportuniste


### Score médiation (C “aime” A et B, et a de la diplomatie)


```
static func score\_mediator(
 profiles: Dictionary,
 relations: Dictionary, # relations[C][A], relations[C][B]
 c\_id: StringName, a\_id: StringName, b\_id: StringName
) -> float:
 var p: FactionProfile = profiles[c\_id]
 var diplo := p.get\_personality(FactionProfile.PERS\_DIPLOMACY, 0.5)
 var expa := p.get\_personality(FactionProfile.PERS\_EXPANSIONISM, 0.5)

 var rel\_ca := float(relations[c\_id][a\_id].relation) / 100.0
 var rel\_cb := float(relations[c\_id][b\_id].relation) / 100.0

 return 0.55*(max(rel\_ca, 0.0) + max(rel\_cb, 0.0)) + 0.60*diplo - 0.35*expa
```


### Score opportunisme (C belliqueux/expansionniste, et “déteste” un camp)


```
static func score\_opportunist(
 profiles: Dictionary,
 relations: Dictionary,
 c\_id: StringName, victim\_id: StringName
) -> float:
 var p: FactionProfile = profiles[c\_id]
 var expa := p.get\_personality(FactionProfile.PERS\_EXPANSIONISM, 0.5)
 var bell := p.get\_personality(FactionProfile.PERS\_BELLIGERENCE, 0.5)

# si tu l’as, sinon remplace

 var rel\_cv := float(relations[c\_id][victim\_id].relation)
 var host := clampf(max(0.0, -rel\_cv) / 100.0, 0.0, 1.0)

 return 0.55*host + 0.35*expa + 0.35*bell
```


---


## 5) OfferFactory “third party” : mapping role → offers


### Actions third party (tags exemples)


* **MEDIATOR**
	+ `tp.mediation.truce` → escort envoys / secure venue / investigate incident
	+ `tp.mediation.trade` → reopen trade / protect caravan / audit reparations
* **OPPORTUNIST**
	+ `tp.opportunist.raid` → raid supply-line / steal resources / sabotage
	+ `tp.opportunist.coalition` → propose alliance A+C vs B (ou inverse)


>
> Techniquement : tu peux réutiliser ton `ArcOfferFactory.spawn_offers_for_pair()` en le “wrappant” pour injecter les clés third party et choisir les variants d’un petit catalogue TP.
>
>
>


### Factory minimale (produit une `QuestInstance` compatible `QuestPool`)


```
class\_name ThirdPartyOfferFactory
extends RefCounted

const TP\_CATALOG := {
 &"tp.mediation.truce": [
 {"tag":"diplo.mediation\_escort\_envoys", "w":40, "domain":"diplo", "needs\_poi":true, "poi\_types":[&"CITY",&"SANCTUARY"], "deadline":[5,7]},
 {"tag":"diplo.mediation\_secure\_venue", "w":35, "domain":"diplo", "needs\_poi":true, "poi\_types":[&"CITY",&"TEMPLE"], "deadline":[5,7]},
 {"tag":"stealth.mediation\_find\_spoiler","w":25, "domain":"stealth","needs\_poi":true, "poi\_types":[&"CITY",&"CAMP"], "deadline":[6,9]},
 ],
 &"tp.opportunist.raid": [
 {"tag":"combat.opportunist\_raid", "w":45, "domain":"combat", "needs\_poi":true, "poi\_types":[&"DEPOT",&"OUTPOST"], "deadline":[5,8]},
 {"tag":"stealth.opportunist\_sabotage", "w":35, "domain":"stealth","needs\_poi":true, "poi\_types":[&"WORKSHOP",&"DEPOT"], "deadline":[6,9]},
 {"tag":"logistics.opportunist\_intercept","w":20, "domain":"logistics","needs\_poi":false,"deadline":[6,9]},
 ],
}

static func spawn\_third\_party\_offer(
 primary\_arc\_id: StringName,
 primary\_arc\_state: ArcState,
 a\_id: StringName,
 b\_id: StringName,
 c\_id: StringName,
 role: StringName,
 tp\_action: StringName,
 rel\_ca: FactionRelationScore, # C -> A (juste pour difficulty/risk si tu veux)
 profiles: Dictionary,
 economies: Dictionary,
 budget\_mgr: ArcOfferBudgetManager,
 notebook: ArcNotebook,
 rng: RandomNumberGenerator,
 day: int,
 tier: int
) -> QuestInstance:
 var primary\_pair\_key := StringName((String(a\_id) <= String(b\_id)) ? (String(a\_id)+"|"+String(b\_id)) : (String(b\_id)+"|"+String(a\_id)))
 if not notebook.can\_spawn\_third\_party(primary\_pair\_key, day, 7):
 return null

 var variants: Array = TP\_CATALOG.get(tp\_action, [])
 if variants.is\_empty():
 return null

 # pick variant
 var v := ArcOfferFactory.\_weighted\_pick(variants, rng)

# si \_weighted\_pick est static/public, sinon recopie

 var domain := String(v.get("domain","diplo"))
 var deadline\_days := rng.randi\_range(int(v["deadline"][0]), int(v["deadline"][1]))

# build a normal arc context first (giver=C, antagonist = "victim" selon rôle)

# MEDIATOR: antagonist = none logique -> on met B par défaut, mais on stocke A/B dans context

 var antagonist := b\_id
 if role == &"OPPORTUNIST":
 antagonist = b\_id # victim (choisi par le caller)

# stakes (réutilise tes compute\_* si tu veux)

 var risk := 0.35
 var difficulty := 0.35
 var reward\_gold := ArcOfferFactoryEconomy.compute\_reward\_gold(tier, difficulty, domain)
 var cost\_points := ArcOfferFactoryEconomy.compute\_action\_cost\_points(tp\_action, primary\_arc\_state.state, difficulty, tier, profiles[c\_id])

 var econ: FactionEconomy = economies.get(c\_id, null)
 if econ == null or not econ.can\_reserve(reward\_gold):
 return null
 var budget := budget\_mgr.get\_budget(c\_id)
 var pair\_key\_cx := StringName((String(c\_id) <= String(antagonist)) ? (String(c\_id)+"|"+String(antagonist)) : (String(antagonist)+"|"+String(c\_id)))
 if not budget.can\_open\_offer(pair\_key\_cx, cost\_points):
 return null

 var stakes := {"gold":reward\_gold, "risk":risk, "difficulty":difficulty, "cost\_points":cost\_points, "domain":domain}

 var ctx := ArcStateMachine.build\_arc\_context(primary\_arc\_id, primary\_arc\_state, c\_id, antagonist, tp\_action, day, deadline\_days, stakes, rng.randi())
 ctx["is\_third\_party"] = true
 ctx["third\_party\_faction\_id"] = c\_id
 ctx["third\_party\_role"] = role
 ctx["primary\_pair\_key"] = primary\_pair\_key
 ctx["side\_a\_faction\_id"] = a\_id
 ctx["side\_b\_faction\_id"] = b\_id
 ctx["involved\_factions"] = [a\_id, b\_id, c\_id]
 ctx["offer\_tag"] = String(v.get("tag",""))
 ctx["offer\_domain"] = domain

 # create template (fallback)
 var template := ArcOfferFactory.\_build\_template\_fallback(String(ctx["offer\_tag"]), tier, deadline\_days)
 var inst := QuestInstance.new(template, ctx)
 inst.status = "AVAILABLE"
 inst.started\_on\_day = day
 inst.expires\_on\_day = day + deadline\_days

 # reserve
 var qid := StringName(inst.runtime\_id)
 if not econ.reserve\_for\_quest(qid, reward\_gold):
 return null
 if not budget.reserve\_for\_offer(qid, pair\_key\_cx, cost\_points):
 econ.release\_reservation(qid)
 return null

 inst.context["escrow\_faction\_id"] = c\_id
 inst.context["escrow\_gold"] = reward\_gold
 inst.context["escrow\_points"] = cost\_points
 notebook.mark\_third\_party\_spawned(primary\_pair\_key, day)

 return inst
```


---


## 6) Règle monde : “si A↔B est chaud, C peut proposer trêve/commerce/allié”


Dans ton tick monde (après avoir mesuré hotness), tu fais :


* si `hotness > 0.65` et pas de cooldown → tenter médiateur
* sinon si `hotness > 0.75` → tenter opportuniste (raid)


Pseudo :


```
func try\_third\_party\_for\_pair(a\_id: StringName, b\_id: StringName, day: int) -> void:
 var hot := compute\_pair\_hotness(day, arc\_notebook, a\_id, b\_id, relations[a\_id][b\_id], relations[b\_id][a\_id])
 if hot < 0.65:
 return

 var primary\_arc\_id := get\_arc\_id\_for\_pair(a\_id, b\_id)
 var st: ArcState = get\_or\_create\_pair\_state(a\_id, b\_id)

# pick best mediator C

 var best\_c := &""
 var best\_s := -1e9
 for c\_id in faction\_ids:
 if c\_id == a\_id or c\_id == b\_id: continue
 var s := score\_mediator(faction\_profiles, relations, c\_id, a\_id, b\_id)
 if s > best\_s:
 best\_s = s
 best\_c = c\_id

 if best\_c != &"" and best\_s > 0.55:
 var inst := ThirdPartyOfferFactory.spawn\_third\_party\_offer(
 primary\_arc\_id, st,
 a\_id, b\_id, best\_c,
 &"MEDIATOR", &"tp.mediation.truce",
 relations[best\_c][a\_id],
 faction\_profiles, faction\_economies, budget\_mgr, arc\_notebook, \_rng, day,
 1
 )
 if inst != null:
 QuestPool.try\_add\_offer(inst)
 return

 # sinon opportuniste (choisir victim = le plus faible / le plus détesté par C)
 if hot >= 0.75:
 # pick opportunist C (simple: celui qui déteste le plus B)
 var best\_o := &""
 var best\_os := -1e9
 for c\_id in faction\_ids:
 if c\_id == a\_id or c\_id == b\_id: continue
 var os := score\_opportunist(faction\_profiles, relations, c\_id, b\_id)
 if os > best\_os:
 best\_os = os
 best\_o = c\_id

 if best\_o != &"" and best\_os > 0.60:
 var inst2 := ThirdPartyOfferFactory.spawn\_third\_party\_offer(
 primary\_arc\_id, st,
 a\_id, b\_id, best\_o,
 &"OPPORTUNIST", &"tp.opportunist.raid",
 relations[best\_o][b\_id],
 faction\_profiles, faction\_economies, budget\_mgr, arc\_notebook, \_rng, day,
 2
 )
 if inst2 != null:
 QuestPool.try\_add\_offer(inst2)
```


---


## 7) Résolution : effets à 3 factions (simple V1)


Tu gardes ton système LOYAL/NEUTRAL/TRAITOR, mais quand `is_third_party` :


* **MEDIATOR / LOYAL** :
	+ baisse tension & grievance entre A↔B
	+ monte trust A↔B
	+ monte relation A↔C et B↔C
* **OPPORTUNIST / LOYAL** :
	+ monte grievance/tension entre C↔victim
	+ peut **déclencher** un nouvel arc C↔victim si seuil dépassé


Tu n’as pas besoin d’un “arc à 3” complet pour que ça vive : l’offer est à 3, les **relations** changent à 3, et le système d’arcs “par paire” fait le reste.


---


Si tu veux, prochaine brique logique : **un mapping d’effets standard** pour `third_party_role + tp_action + choice` (deltas sur A↔B, A↔C, B↔C), et un petit test qui montre que “médiation répétée” fait converger vers TRUCE/ALLIANCE sans boucler en escalade.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 9](#toc-detail-ch9)
<a id="moi-59"></a>
**Moi 59:**
Ok fais

prochaine brique logique : un mapping d’effets standard pour third\_party\_role + tp\_action + choice (deltas sur A↔B, A↔C, B↔C), et un petit test qui montre que “médiation répétée” fait converger vers TRUCE/ALLIANCE sans boucler en escalade


**ChatGPT:**
Voici ce que je te propose pour la **V1 “third party effects”** :


1) un fichier `ThirdPartyEffectTable.gd` : **table standardisée** `role + tp_action + choice → deltas` (sur **A↔B**, **A↔C**, **B↔C**), + une fonction `apply()`.

2) un test `ThirdPartyMediationConvergenceTest.gd` : répète des médiations LOYAL et montre que l’arc **converge vers TRUCE puis ALLIANCE** (tension↓, relation/trust↑), sans reboucler vers l’escalade.


---


## 1) Mapping d’effets standard


### `ThirdPartyEffectTable.gd`


```
class\_name ThirdPartyEffectTable
extends RefCounted

const CHOICE\_LOYAL: StringName = &"LOYAL"
const CHOICE\_NEUTRAL: StringName = &"NEUTRAL"
const CHOICE\_TRAITOR: StringName = &"TRAITOR"

# role -> tp\_action -> choice -> effects[]

# effect := { "pair":"AB"|"AC"|"BC", "field":"relation|trust|tension|grievance|weariness", "delta": float }

const EFFECTS: Dictionary = {
 &"MEDIATOR": {
 &"tp.mediation.truce": {
 CHOICE\_LOYAL: [
 {"pair":"AB","field":"tension","delta":-15}, {"pair":"AB","field":"grievance","delta":-12},
 {"pair":"AB","field":"trust","delta":+10}, {"pair":"AB","field":"relation","delta":+12},
 {"pair":"AB","field":"weariness","delta":-3},

 {"pair":"AC","field":"trust","delta":+6}, {"pair":"AC","field":"relation","delta":+6},
 {"pair":"BC","field":"trust","delta":+6}, {"pair":"BC","field":"relation","delta":+6},
 ],
 CHOICE\_NEUTRAL: [
 {"pair":"AB","field":"tension","delta":-9}, {"pair":"AB","field":"grievance","delta":-6},
 {"pair":"AB","field":"trust","delta":+4}, {"pair":"AB","field":"relation","delta":+5},
 {"pair":"AC","field":"relation","delta":+2}, {"pair":"BC","field":"relation","delta":+2},
 ],
 CHOICE\_TRAITOR: [
 {"pair":"AB","field":"tension","delta":+8}, {"pair":"AB","field":"grievance","delta":+8},
 {"pair":"AB","field":"trust","delta":-8}, {"pair":"AB","field":"relation","delta":-6},
 {"pair":"AC","field":"trust","delta":-10}, {"pair":"AC","field":"relation","delta":-10},
 {"pair":"BC","field":"trust","delta":-10}, {"pair":"BC","field":"relation","delta":-10},
 ],
 },

 &"tp.mediation.trade": {
 CHOICE\_LOYAL: [
 {"pair":"AB","field":"tension","delta":-8}, {"pair":"AB","field":"grievance","delta":-6},
 {"pair":"AB","field":"trust","delta":+6}, {"pair":"AB","field":"relation","delta":+8},
 {"pair":"AC","field":"relation","delta":+4},{"pair":"BC","field":"relation","delta":+4},
 ],
 CHOICE\_NEUTRAL: [
 {"pair":"AB","field":"tension","delta":-4}, {"pair":"AB","field":"relation","delta":+3},
 ],
 CHOICE\_TRAITOR: [
 {"pair":"AB","field":"trust","delta":-6}, {"pair":"AC","field":"relation","delta":-6},{"pair":"BC","field":"relation","delta":-6},
 ],
 },
 },

 &"OPPORTUNIST": {
 &"tp.opportunist.raid": {
 # Ici, on suppose que "victim\_faction\_id" est B (ou A) dans le context ;
 # l’application ci-dessous traite AB comme "C<->victim" via apply\_for\_opportunist().
 CHOICE\_LOYAL: [
 {"pair":"AB","field":"tension","delta":+14}, {"pair":"AB","field":"grievance","delta":+12},
 {"pair":"AB","field":"relation","delta":-12},{"pair":"AB","field":"trust","delta":-8},
 {"pair":"AC","field":"relation","delta":+4}, # beneficiary likes C (optionnel)
 ],
 CHOICE\_NEUTRAL: [
 {"pair":"AB","field":"tension","delta":+8}, {"pair":"AB","field":"relation","delta":-7},
 ],
 CHOICE\_TRAITOR: [
 {"pair":"AB","field":"tension","delta":+10},{"pair":"AB","field":"relation","delta":-10},
 {"pair":"AC","field":"relation","delta":-6}, {"pair":"BC","field":"relation","delta":-6},
 ],
 },
 },
}

static func canonical\_arc\_action(role: StringName, tp\_action: StringName) -> StringName:
 # utile si tu veux que l’ArcStateMachine compte ça comme peace/hostile
 if role == &"MEDIATOR" and tp\_action == &"tp.mediation.truce":
 return ArcDecisionUtil.ARC\_TRUCE\_TALKS
 if role == &"MEDIATOR" and tp\_action == &"tp.mediation.trade":
 return ArcDecisionUtil.ARC\_REPARATIONS
 if role == &"OPPORTUNIST" and tp\_action == &"tp.opportunist.raid":
 return ArcDecisionUtil.ARC\_RAID
 return tp\_action

static func apply(
 relations: Dictionary, # relations[X][Y] -> FactionRelationScore
 a\_id: StringName,
 b\_id: StringName,
 c\_id: StringName,
 role: StringName,
 tp\_action: StringName,
 choice: StringName,
 # limiter: max change per tick (ratio); tu peux le brancher à ton ArcNotebook/historique
 max\_change\_ratio: float = 0.25
) -> void:
 var role\_map: Dictionary = EFFECTS.get(role, {})
 var action\_map: Dictionary = role\_map.get(tp\_action, {})
 var effects: Array = action\_map.get(choice, [])
 if effects.is\_empty():
 return

 for e in effects:
 var pair := String(e.get("pair",""))
 var field := String(e.get("field",""))
 var delta := float(e.get("delta", 0.0))

 match pair:
 "AB":
 \_apply\_pair(relations, a\_id, b\_id, field, delta, max\_change\_ratio)
 "AC":
 \_apply\_pair(relations, a\_id, c\_id, field, delta, max\_change\_ratio)
 "BC":
 \_apply\_pair(relations, b\_id, c\_id, field, delta, max\_change\_ratio)
 \_:
 pass

static func apply\_for\_opportunist(
 relations: Dictionary,
 beneficiary\_id: StringName, # ex: A
 victim\_id: StringName, # ex: B
 c\_id: StringName,
 role: StringName,
 tp\_action: StringName,
 choice: StringName,
 max\_change\_ratio: float = 0.25
) -> void:
 # Interprétation:
 # - "AB" = C <-> victim
 # - "AC" = beneficiary <-> C
 # - "BC" = beneficiary <-> victim (optionnel)
 var role\_map: Dictionary = EFFECTS.get(role, {})
 var action\_map: Dictionary = role\_map.get(tp\_action, {})
 var effects: Array = action\_map.get(choice, [])
 if effects.is\_empty():
 return

 for e in effects:
 var pair := String(e.get("pair",""))
 var field := String(e.get("field",""))
 var delta := float(e.get("delta", 0.0))

 match pair:
 "AB":
 \_apply\_pair(relations, c\_id, victim\_id, field, delta, max\_change\_ratio)
 "AC":
 \_apply\_pair(relations, beneficiary\_id, c\_id, field, delta, max\_change\_ratio)
 "BC":
 \_apply\_pair(relations, beneficiary\_id, victim\_id, field, delta, max\_change\_ratio)
 \_:
 pass

static func \_apply\_pair(relations: Dictionary, x\_id: StringName, y\_id: StringName, field: String, delta: float, max\_change\_ratio: float) -> void:
 if not relations.has(x\_id): return
 if not relations.has(y\_id): return
 if not relations[x\_id].has(y\_id): return
 if not relations[y\_id].has(x\_id): return

 var xy: FactionRelationScore = relations[x\_id][y\_id]
 var yx: FactionRelationScore = relations[y\_id][x\_id]

 \_apply\_field(xy, field, delta, max\_change\_ratio)
 \_apply\_field(yx, field, delta, max\_change\_ratio)

static func \_apply\_field(r: FactionRelationScore, field: String, delta: float, max\_change\_ratio: float) -> void:
 var minv := 0.0
 var maxv := 100.0
 var cur := 0.0

 match field:
 "relation":
 minv = -100.0; maxv = 100.0
 cur = float(r.relation)
 r.relation = int(round(\_apply\_limited(cur, delta, minv, maxv, max\_change\_ratio)))
 "trust":
 cur = float(r.trust)
 r.trust = int(round(\_apply\_limited(cur, delta, minv, maxv, max\_change\_ratio)))
 "tension":
 cur = float(r.tension)
 r.tension = int(round(\_apply\_limited(cur, delta, minv, maxv, max\_change\_ratio)))
 "grievance":
 cur = float(r.grievance)
 r.grievance = int(round(\_apply\_limited(cur, delta, minv, maxv, max\_change\_ratio)))
 "weariness":
 cur = float(r.weariness)
 r.weariness = int(round(\_apply\_limited(cur, delta, minv, maxv, max\_change\_ratio)))
 \_:
 pass

static func \_apply\_limited(cur: float, delta: float, minv: float, maxv: float, max\_change\_ratio: float) -> float:
 # limite “10..30% du score actuel” version générique:
 # clamp(delta) par abs(cur)*ratio, avec un minimum de pas.
 var cap := max(3.0, abs(cur) * clampf(max\_change\_ratio, 0.0, 1.0))
 var d := clampf(delta, -cap, cap)
 return clampf(cur + d, minv, maxv)
```


>
> Important : `max_change_ratio` peut être calculé dynamiquement via ton `ArcNotebook` (en fonction de l’historique / nb d’incidents), et passé ici.
>
>
>


---


## 2) Test : “médiation répétée” converge vers TRUCE/ALLIANCE


### `tests/ThirdPartyMediationConvergenceTest.gd`


Ce test simule 30 jours :


* A↔B démarre en **CONFLICT** avec tension/grievance élevées
* C déclenche 3 médiations `tp.mediation.truce` résolues **LOYAL**
* On tick chaque jour (stability counters), et on appelle `update_arc_state()` quotidiennement (action vide) pour laisser passer les transitions “après Y jours”.


```
extends Node
class\_name ThirdPartyMediationConvergenceTest

func \_ready() -> void:
 \_test\_repeated\_mediation\_converges()
 print("\n✅ ThirdPartyMediationConvergenceTest: OK\n")
 get\_tree().quit()

func \_test\_repeated\_mediation\_converges() -> void:
 var rng := RandomNumberGenerator.new()
 rng.seed = 202501

 # ids
 var A := &"A"
 var B := &"B"
 var C := &"C"

 # relations dict
 var relations := {}
 relations[A] = {}; relations[B] = {}; relations[C] = {}

 relations[A][B] = FactionRelationScore.new()
 relations[B][A] = FactionRelationScore.new()
 relations[A][C] = FactionRelationScore.new()
 relations[C][A] = FactionRelationScore.new()
 relations[B][C] = FactionRelationScore.new()
 relations[C][B] = FactionRelationScore.new()

# init A<->B hostile conflict

 relations[A][B].relation = -50; relations[B][A].relation = -52
 relations[A][B].trust = 20; relations[B][A].trust = 18
 relations[A][B].tension = 70; relations[B][A].tension = 72
 relations[A][B].grievance = 60; relations[B][A].grievance = 58
 relations[A][B].weariness = 30; relations[B][A].weariness = 28

 # init C neutral/good with both
 relations[A][C].relation = 10; relations[C][A].relation = 8
 relations[B][C].relation = 5; relations[C][B].relation = 6
 relations[A][C].trust = 35; relations[C][A].trust = 30
 relations[B][C].trust = 30; relations[C][B].trust = 32

 # arc state A<->B
 var arc := ArcState.new()
 arc.state = &"CONFLICT"
 arc.lock\_until\_day = 0
 arc.phase\_events = 0
 arc.phase\_hostile = 0
 arc.phase\_peace = 0
 arc.stable\_low\_tension\_days = 0
 arc.stable\_high\_trust\_days = 0

 var initial\_tension := 0.5 * (relations[A][B].tension + relations[B][A].tension)
 var initial\_rel := 0.5 * (relations[A][B].relation + relations[B][A].relation)

 var mediation\_days := {2:true, 4:true, 6:true}

 for day in range(1, 31):
 # daily stability counters
 ArcStateMachine.tick\_day\_for\_pair(arc, relations[A][B], relations[B][A])

# Apply mediated event on some days

 if mediation\_days.has(day):
 ThirdPartyEffectTable.apply(
 relations,
 A, B, C,
 &"MEDIATOR",
 &"tp.mediation.truce",
 ThirdPartyEffectTable.CHOICE\_LOYAL,
 0.30 # max\_change\_ratio (plutôt permissif pour ce test)
 )

# Feed arc state machine with canonical peace action

 ArcStateMachine.update\_arc\_state(
 arc, relations[A][B], relations[B][A],
 day, rng,
 ArcDecisionUtil.ARC\_TRUCE\_TALKS,
 ThirdPartyEffectTable.CHOICE\_LOYAL
 )
 else:
 # passive update to allow transitions “après Y jours”
 ArcStateMachine.update\_arc\_state(
 arc, relations[A][B], relations[B][A],
 day, rng,
 &"", &""
 )

# Final metrics

 var final\_tension := 0.5 * (relations[A][B].tension + relations[B][A].tension)
 var final\_rel := 0.5 * (relations[A][B].relation + relations[B][A].relation)
 var final\_trust := 0.5 * (relations[A][B].trust + relations[B][A].trust)

# Convergence checks (no escalation)

 \_assert(final\_tension < initial\_tension, "tension should decrease (%.1f -> %.1f)" % [initial\_tension, final\_tension])
 \_assert(final\_rel > initial\_rel, "relation should increase (%.1f -> %.1f)" % [initial\_rel, final\_rel])

# Outcome: TRUCE or ALLIANCE (ALLIANCE expected often)

 \_assert(arc.state == &"TRUCE" or arc.state == &"ALLIANCE",
 "arc should converge to TRUCE/ALLIANCE, got: %s" % [String(arc.state)]
 )

# If ALLIANCE, it must satisfy the stability intent

 if arc.state == &"ALLIANCE":
 \_assert(final\_tension <= 25.0, "ALLIANCE implies low tension (<=25)")
 \_assert(final\_trust >= 55.0, "ALLIANCE implies trust >=55")
 \_assert(final\_rel >= 35.0, "ALLIANCE implies relation >=35")


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


### Comment tu l’intègres “en vrai”


* Quand une quête `is_third_party=true` est résolue, tu appelles :
	+ `ThirdPartyEffectTable.apply(...)` (MEDIATOR)
	+ ou `ThirdPartyEffectTable.apply_for_opportunist(...)` (OPPORTUNIST avec beneficiary/victim)
* Et tu passes aussi une `canonical_arc_action()` au `ArcStateMachine.update_arc_state()` pour que l’arc A↔B “compte” ces événements (peace/hostile).


Si tu veux, prochaine brique logique : une variante de test qui vérifie que **l’opportunisme** crée naturellement un **nouvel arc C↔victim** (via augmentation tension/grievance + seuil).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 9](#toc-detail-ch9)
<a id="moi-60"></a>
**Moi 60:**
Ok prochaine brique logique : une variante de test qui vérifie que l’opportunisme crée naturellement un nouvel arc C↔victim (via augmentation tension/grievance + seuil


**ChatGPT:**
Voilà une **variante de test** qui montre que l’**opportunisme** (C raid B pendant que A↔B est “chaud”) peut **créer naturellement un nouvel arc C↔B** via montée **tension/grievance** au-dessus de seuils.


>
> Le test ne dépend pas de ta logique “choisir C automatiquement”. Il force juste l’event opportuniste (comme si ta sélection l’avait décidé), puis vérifie que l’état de l’arc **C↔B** quitte **NEUTRAL**.
>
>
>


---


## `tests/ThirdPartyOpportunismCreatesArcTest.gd`


```
extends Node
class\_name ThirdPartyOpportunismCreatesArcTest

func \_ready() -> void:
 \_test\_opportunism\_creates\_new\_arc\_between\_C\_and\_victim()
 print("\n✅ ThirdPartyOpportunismCreatesArcTest: OK\n")
 get\_tree().quit()


func \_test\_opportunism\_creates\_new\_arc\_between\_C\_and\_victim() -> void:
 var rng := RandomNumberGenerator.new()
 rng.seed = 909090

 var A := &"A"
 var B := &"B"
 var C := &"C"

 # -----------------------------
 # Relations world: relations[X][Y] -> FactionRelationScore
 # -----------------------------
 var relations := {}
 relations[A] = {}; relations[B] = {}; relations[C] = {}

 relations[A][B] = FactionRelationScore.new()
 relations[B][A] = FactionRelationScore.new()
 relations[A][C] = FactionRelationScore.new()
 relations[C][A] = FactionRelationScore.new()
 relations[B][C] = FactionRelationScore.new()
 relations[C][B] = FactionRelationScore.new()

# A<->B : conflit "chaud" (contexte qui motive l'opportunisme)

 relations[A][B].relation = -65; relations[B][A].relation = -60
 relations[A][B].trust = 18; relations[B][A].trust = 22
 relations[A][B].tension = 75; relations[B][A].tension = 70
 relations[A][B].grievance = 55; relations[B][A].grievance = 50
 relations[A][B].weariness = 25; relations[B][A].weariness = 22

 # A<->C : plutôt positif (C "profite" pour aider A implicitement)
 relations[A][C].relation = 20; relations[C][A].relation = 18
 relations[A][C].trust = 45; relations[C][A].trust = 40
 relations[A][C].tension = 10; relations[C][A].tension = 10
 relations[A][C].grievance = 5; relations[C][A].grievance = 5

 # C<->B : NEUTRAL au départ (cible = victim)

# Important: tension/grievance pas trop bas sinon ta limite "max\_change\_ratio" bride trop.

 relations[C][B].relation = -10; relations[B][C].relation = -8
 relations[C][B].trust = 35; relations[B][C].trust = 38
 relations[C][B].tension = 20; relations[B][C].tension = 22
 relations[C][B].grievance = 18; relations[B][C].grievance = 16
 relations[C][B].weariness = 10; relations[B][C].weariness = 10

 var initial\_cb\_tension := 0.5 * (relations[C][B].tension + relations[B][C].tension)
 var initial\_cb\_rel := 0.5 * (relations[C][B].relation + relations[B][C].relation)

# -----------------------------

 # Arc states
 # -----------------------------
 var arc\_cb := ArcState.new()
 arc\_cb.state = &"NEUTRAL"
 arc\_cb.lock\_until\_day = 0
 arc\_cb.phase\_events = 0
 arc\_cb.phase\_hostile = 0
 arc\_cb.phase\_peace = 0
 arc\_cb.stable\_low\_tension\_days = 0
 arc\_cb.stable\_high\_trust\_days = 0

 # -----------------------------
 # Opportunist events: C raids B (beneficiary = A, victim = B)

# -----------------------------

 var opportunism\_days := {2:true, 4:true, 6:true}

 for day in range(1, 21):
 # counters (même les jours sans event)
 ArcStateMachine.tick\_day\_for\_pair(arc\_cb, relations[C][B], relations[B][C])

 if opportunism\_days.has(day):
 ThirdPartyEffectTable.apply\_for\_opportunist(
 relations,
 A, # beneficiary
 B, # victim
 C, # third party
 &"OPPORTUNIST",
 &"tp.opportunist.raid",
 ThirdPartyEffectTable.CHOICE\_LOYAL,
 0.80 # max\_change\_ratio (volontairement permissif pour franchir le seuil)
 )

# Feed the state machine with a canonical hostile action

 ArcStateMachine.update\_arc\_state(
 arc\_cb,
 relations[C][B],
 relations[B][C],
 day,
 rng,
 ArcDecisionUtil.ARC\_RAID,
 ThirdPartyEffectTable.CHOICE\_LOYAL
 )
 else:
 ArcStateMachine.update\_arc\_state(
 arc\_cb,
 relations[C][B],
 relations[B][C],
 day,
 rng,
 &"", &""
 )

# -----------------------------

 # Assertions: C<->B should have escalated to at least RIVALRY/CONFLICT
 # -----------------------------
 var final\_cb\_tension := 0.5 * (relations[C][B].tension + relations[B][C].tension)
 var final\_cb\_rel := 0.5 * (relations[C][B].relation + relations[B][C].relation)

 \_assert(final\_cb\_tension > initial\_cb\_tension, "C<->B tension should increase (%.1f -> %.1f)" % [initial\_cb\_tension, final\_cb\_tension])
 \_assert(final\_cb\_rel < initial\_cb\_rel, "C<->B relation should decrease (%.1f -> %.1f)" % [initial\_cb\_rel, final\_cb\_rel])

 \_assert(
 arc\_cb.state != &"NEUTRAL" and arc\_cb.state != &"ALLIANCE" and arc\_cb.state != &"TRUCE",
 "opportunism should create a hostile arc state for C<->B (got %s)" % [String(arc\_cb.state)]
 )

# Optionnel: si tu veux être plus strict (selon tes seuils)

# \_assert(arc\_cb.state == &"RIVALRY" or arc\_cb.state == &"CONFLICT" or arc\_cb.state == &"WAR",

 # "expected RIVALRY/CONFLICT/WAR for C<->B, got %s" % [String(arc\_cb.state)]
 # )


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


### Notes importantes


* J’ai mis `max_change_ratio = 0.80` **dans le test** pour franchir les seuils rapidement et éviter une fragilité liée à ton clamp (sinon il faut davantage d’events / plus de jours).
* Si ton `update_arc_state()` ne transitionne pas depuis `NEUTRAL` sur simple hausse de tension/grievance, adapte l’assert “strict” (ou ajoute une règle “si hostile event alors NEUTRAL→RIVALRY”).


Si tu veux, je te fais une **2e variante** de ce test qui vérifie aussi que **A↔C** s’améliore (beneficiary likes C) et que **A↔B** n’est pas directement modifié par l’opportunisme (sauf si tu l’ajoutes volontairement).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 9](#toc-detail-ch9)
<a id="moi-61"></a>
**Moi 61:**
fais une 2e variante de ce test qui vérifie aussi que A↔C s’améliore (beneficiary likes C) et que A↔B n’est pas directement modifié par l’opportunisme (sauf si tu l’ajoutes volontairement).


**ChatGPT:**
Voici une **2e variante** du test opportunisme qui vérifie en plus :


1) **A↔C s’améliore** (beneficiary likes C)

2) **A↔B ne change pas** à cause de l’opportunisme (on tolère uniquement de très petites variations dues à ton clamp/arrondis, sinon 0)


>
> Dans notre table actuelle `tp.opportunist.raid / LOYAL`, on a bien un petit bonus **AC relation +4**.
>
>  Et on n’applique **aucun delta AB** (beneficiary↔victim) dans `apply_for_opportunist()` sauf si tu ajoutes volontairement des effets `{"pair":"BC", ...}` dans la table.
>
>
>


---


## `tests/ThirdPartyOpportunismSideEffectsTest.gd`


```
extends Node
class\_name ThirdPartyOpportunismSideEffectsTest

func \_ready() -> void:
 \_test\_opportunism\_improves\_A\_C\_and\_does\_not\_touch\_A\_B()
 print("\n✅ ThirdPartyOpportunismSideEffectsTest: OK\n")
 get\_tree().quit()


func \_test\_opportunism\_improves\_A\_C\_and\_does\_not\_touch\_A\_B() -> void:
 var rng := RandomNumberGenerator.new()
 rng.seed = 919191

 var A := &"A"
 var B := &"B"
 var C := &"C"

 # -----------------------------
 # Relations world
 # -----------------------------
 var relations := {}
 relations[A] = {}; relations[B] = {}; relations[C] = {}

 relations[A][B] = FactionRelationScore.new()
 relations[B][A] = FactionRelationScore.new()
 relations[A][C] = FactionRelationScore.new()
 relations[C][A] = FactionRelationScore.new()
 relations[B][C] = FactionRelationScore.new()
 relations[C][B] = FactionRelationScore.new()

# A<->B : conflict hot, but should NOT be modified by opportunism effects

 relations[A][B].relation = -65; relations[B][A].relation = -60
 relations[A][B].trust = 18; relations[B][A].trust = 22
 relations[A][B].tension = 75; relations[B][A].tension = 70
 relations[A][B].grievance = 55; relations[B][A].grievance = 50
 relations[A][B].weariness = 25; relations[B][A].weariness = 22

 # A<->C : already friendly, should improve a bit (beneficiary likes C)
 relations[A][C].relation = 20; relations[C][A].relation = 18
 relations[A][C].trust = 45; relations[C][A].trust = 40
 relations[A][C].tension = 10; relations[C][A].tension = 10
 relations[A][C].grievance = 5; relations[C][A].grievance = 5

 # C<->B : neutral-ish, will escalate
 relations[C][B].relation = -10; relations[B][C].relation = -8
 relations[C][B].trust = 35; relations[B][C].trust = 38
 relations[C][B].tension = 20; relations[B][C].tension = 22
 relations[C][B].grievance = 18; relations[B][C].grievance = 16
 relations[C][B].weariness = 10; relations[B][C].weariness = 10

 # Baselines to compare
 var ab\_before := \_snapshot(relations[A][B], relations[B][A])
 var ac\_before := \_snapshot(relations[A][C], relations[C][A])

# Arc C<->B (target of opportunism)

 var arc\_cb := ArcState.new()
 arc\_cb.state = &"NEUTRAL"

 # Events: C raids B (beneficiary=A)
 var opportunism\_days := {2:true, 4:true, 6:true}

 for day in range(1, 21):
 ArcStateMachine.tick\_day\_for\_pair(arc\_cb, relations[C][B], relations[B][C])

 if opportunism\_days.has(day):
 ThirdPartyEffectTable.apply\_for\_opportunist(
 relations,
 A, B, C,
 &"OPPORTUNIST",
 &"tp.opportunist.raid",
 ThirdPartyEffectTable.CHOICE\_LOYAL,
 0.80
 )

 ArcStateMachine.update\_arc\_state(
 arc\_cb, relations[C][B], relations[B][C],
 day, rng,
 ArcDecisionUtil.ARC\_RAID,
 ThirdPartyEffectTable.CHOICE\_LOYAL
 )
 else:
 ArcStateMachine.update\_arc\_state(
 arc\_cb, relations[C][B], relations[B][C],
 day, rng,
 &"", &""
 )

# After

 var ab\_after := \_snapshot(relations[A][B], relations[B][A])
 var ac\_after := \_snapshot(relations[A][C], relations[C][A])

# -----------------------------

 # Assertions 1) A<->C improves
 # -----------------------------
 \_assert(ac\_after["rel\_mean"] > ac\_before["rel\_mean"], "A<->C relation should improve (%.1f -> %.1f)" % [ac\_before["rel\_mean"], ac\_after["rel\_mean"]])

# Optionnel: trust peut rester stable, mais tu peux aussi le booster si tu veux.

 # \_assert(ac\_after["trust\_mean"] >= ac\_before["trust\_mean"], "A<->C trust should not decrease")

# -----------------------------

 # Assertions 2) A<->B not modified by opportunism table
 # -----------------------------
 # On attend 0 variation, mais on tolère +/-1 en cas d'arrondi/clamp
 var eps := 1.0

 \_assert(abs(ab\_after["rel\_mean"] - ab\_before["rel\_mean"]) <= eps, "A<->B relation should not change (%.1f -> %.1f)" % [ab\_before["rel\_mean"], ab\_after["rel\_mean"]])
 \_assert(abs(ab\_after["trust\_mean"] - ab\_before["trust\_mean"]) <= eps, "A<->B trust should not change (%.1f -> %.1f)" % [ab\_before["trust\_mean"], ab\_after["trust\_mean"]])
 \_assert(abs(ab\_after["tension\_mean"] - ab\_before["tension\_mean"]) <= eps, "A<->B tension should not change (%.1f -> %.1f)" % [ab\_before["tension\_mean"], ab\_after["tension\_mean"]])
 \_assert(abs(ab\_after["griev\_mean"] - ab\_before["griev\_mean"]) <= eps, "A<->B grievance should not change (%.1f -> %.1f)" % [ab\_before["griev\_mean"], ab\_after["griev\_mean"]])

# Sanity: C<->B should have escalated

 \_assert(arc\_cb.state != &"NEUTRAL", "C<->B arc should no longer be NEUTRAL after opportunism (got %s)" % String(arc\_cb.state))


func \_snapshot(xy: FactionRelationScore, yx: FactionRelationScore) -> Dictionary:
 return {
 "rel\_mean": 0.5 * (xy.relation + yx.relation),
 "trust\_mean": 0.5 * (xy.trust + yx.trust),
 "tension\_mean": 0.5 * (xy.tension + yx.tension),
 "griev\_mean": 0.5 * (xy.grievance + yx.grievance),
 }

func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


### Si tu ajoutes volontairement un effet AB plus tard


Si tu décides que “C raid B” augmente la haine A↔B (ex: propagande, blame), tu ajoutes un effet `{"pair":"BC", ...}` dans la table opportuniste (dans `apply_for_opportunist`, `BC = beneficiary↔victim`).

À ce moment-là tu modifies ce test pour **attendre** un delta AB au lieu de “0”.


Si tu veux, je peux aussi te proposer une règle “si third party opportunist aidait A, alors B en veut davantage à A (même sans preuve)” en mettant juste `tension +3` et `grievance +2` sur AB.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 9](#toc-detail-ch9)
<a id="moi-62"></a>
**Moi 62:**
Ok

proposer une règle “si third party opportunist aidait A, alors B en veut davantage à A (même sans preuve)” en mettant juste tension +3 et grievance +2 sur AB


**ChatGPT:**
Voici une règle simple (et très “vivante”) : **quand C fait un raid opportuniste contre B pendant un conflit A↔B, B soupçonne A d’être derrière**, donc **B en veut davantage à A** même sans preuve.


### Règle (V1)


Sur un évènement `OPPORTUNIST / tp.opportunist.raid / LOYAL` :


* appliquer aussi sur **A↔B** :
	+ `tension +3`
	+ `grievance +2`
* (optionnel) si tu veux une légère “paranoïa” : `trust -1` côté B→A uniquement


---


## Patch dans `ThirdPartyEffectTable.gd`


Dans `EFFECTS[&"OPPORTUNIST"][&"tp.opportunist.raid"][LOYAL]`, ajoute ces 2 lignes avec `pair:"BC"` (dans notre convention `apply_for_opportunist()` : `"BC" = beneficiary↔victim` donc **A↔B**).


```
&"OPPORTUNIST": {
 &"tp.opportunist.raid": {
 CHOICE\_LOYAL: [
 {"pair":"AB","field":"tension","delta":+14}, {"pair":"AB","field":"grievance","delta":+12},
 {"pair":"AB","field":"relation","delta":-12},{"pair":"AB","field":"trust","delta":-8},
 {"pair":"AC","field":"relation","delta":+4},

 # NEW: suspicion spillover (beneficiary A, victim B) => affects A<->B
 {"pair":"BC","field":"tension","delta":+3},
 {"pair":"BC","field":"grievance","delta":+2},
 ],
 ...
 }
}
```


### Comment ça se lit


* `"AB"` = `C↔victim` (C↔B) : escalade directe contre la victime
* `"AC"` = `beneficiary↔C` (A↔C) : A apprécie l’aide de C
* `"BC"` = `beneficiary↔victim` (A↔B) : **B soupçonne A**, donc A↔B se dégrade


---


## (Optionnel) suspicion asymétrique (B→A seulement)


Si tu veux que ce soit **uniquement** B qui accuse A (pas forcément réciproque), on peut ajouter un helper dédié (au lieu d’utiliser `_apply_pair` qui applique aux deux sens).


Dis-moi si tu veux ce mode “asymétrique”, je te donne la mini-fonction `apply_one_way(relations, from_id, to_id, field, delta)` et on patch en 2 lignes.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 9](#toc-detail-ch9)
<a id="moi-63"></a>
**Moi 63:**
Je veux que ce soit asymetrique


**ChatGPT:**
Parfait — on garde la table d’effets, mais on ajoute une **option “one-way”** pour pouvoir appliquer un delta **uniquement dans un sens** (ici **victim → beneficiary**, donc **B→A**).


## 1) Micro-patch `ThirdPartyEffectTable.gd` : helper one-way + support `dir`


Ajoute ce helper (à côté de `_apply_pair`) :


```
static func \_apply\_one\_way(relations: Dictionary, from\_id: StringName, to\_id: StringName, field: String, delta: float, max\_change\_ratio: float) -> void:
 if not relations.has(from\_id): return
 if not relations[from\_id].has(to\_id): return
 var r: FactionRelationScore = relations[from\_id][to\_id]
 \_apply\_field(r, field, delta, max\_change\_ratio)
```


Puis, dans `apply_for_opportunist(...)`, remplace la boucle `for e in effects:` par une version qui supporte `dir` :


```
for e in effects:
 var pair := String(e.get("pair",""))
 var field := String(e.get("field",""))
 var delta := float(e.get("delta", 0.0))
 var dir := String(e.get("dir",""))

# NEW (optional)

# NEW: direction spéciale (asymétrique)

 if dir == "V2BEN": # victim -> beneficiary
 \_apply\_one\_way(relations, victim\_id, beneficiary\_id, field, delta, max\_change\_ratio)
 continue
 if dir == "BEN2V": # beneficiary -> victim (si un jour tu veux)
 \_apply\_one\_way(relations, beneficiary\_id, victim\_id, field, delta, max\_change\_ratio)
 continue

 # comportement actuel (symétrique) inchangé
 match pair:
 "AB":
 \_apply\_pair(relations, c\_id, victim\_id, field, delta, max\_change\_ratio)
 "AC":
 \_apply\_pair(relations, beneficiary\_id, c\_id, field, delta, max\_change\_ratio)
 "BC":
 \_apply\_pair(relations, beneficiary\_id, victim\_id, field, delta, max\_change\_ratio)
 \_:
 pass
```


✅ En prod, si tu n’utilises pas `dir`, rien ne change.


---


## 2) Règle “suspicion” asymétrique : **B→A** uniquement


Dans `EFFECTS[OPPORTUNIST][tp.opportunist.raid][LOYAL]`, ajoute ces entrées (au lieu de la version symétrique) :


```
# Suspicion spillover (asym): victim(B) -> beneficiary(A)

{"dir":"V2BEN","field":"tension","delta":+3},
{"dir":"V2BEN","field":"grievance","delta":+2},

# (optionnel) paranoïa légère

# {"dir":"V2BEN","field":"trust","delta":-1},

```


>
> Pas besoin de `pair` ici : `dir` suffit.
>
>
>


---


## 3) Impact sur tes tests existants


Le test `ThirdPartyOpportunismSideEffectsTest.gd` (celui qui vérifiait “A↔B ne bouge pas”) va maintenant **échouer** — et c’est normal.


La nouvelle assertion attendue devient :


* **B→A** : `tension +` et `grievance +`
* **A→B** : inchangé (ou quasi inchangé)


Si tu veux, je te donne le patch exact du test dans le prochain message.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 9](#toc-detail-ch9)
<a id="moi-64"></a>
**Moi 64:**
donne le patch exact du test dans le prochain message.


**ChatGPT:**
Voici le **patch exact** pour `tests/ThirdPartyOpportunismSideEffectsTest.gd` afin de refléter la suspicion **asymétrique B→A** :


* On **ne compare plus la moyenne A↔B**.
* On vérifie :
	+ `B→A` : **tension↑** et **grievance↑** (au moins +1)
	+ `A→B` : **inchangé** (±1)


>
> Hypothèse : tu appliques la suspicion via `dir:"V2BEN"` avec `tension +3` et `grievance +2` pour chaque event opportuniste LOYAL, donc sur 3 events ça fera typiquement +6..+9 (clamp/ratio peut limiter un peu).
>
>
>


---


## Patch (diff logique) dans le test


### 1) Remplace le snapshot AB mean par des snapshots directionnels


**Avant :**


```
var ab\_before := \_snapshot(relations[A][B], relations[B][A])
...
var ab\_after := \_snapshot(relations[A][B], relations[B][A])
...
var eps := 1.0
\_assert(abs(ab\_after["tension\_mean"] - ab\_before["tension\_mean"]) <= eps, ...)
\_assert(abs(ab\_after["griev\_mean"] - ab\_before["griev\_mean"]) <= eps, ...)
```


**Après :**


```
var ab\_dir\_before := \_snapshot\_dir(relations[A][B], relations[B][A])
...
var ab\_dir\_after := \_snapshot\_dir(relations[A][B], relations[B][A])
```


Et ajoute ce helper en bas du fichier (à côté de `_snapshot`) :


```
func \_snapshot\_dir(a\_to\_b: FactionRelationScore, b\_to\_a: FactionRelationScore) -> Dictionary:
 return {
 "A2B\_tension": float(a\_to\_b.tension),
 "A2B\_griev": float(a\_to\_b.grievance),
 "A2B\_trust": float(a\_to\_b.trust),
 "A2B\_rel": float(a\_to\_b.relation),

 "B2A\_tension": float(b\_to\_a.tension),
 "B2A\_griev": float(b\_to\_a.grievance),
 "B2A\_trust": float(b\_to\_a.trust),
 "B2A\_rel": float(b\_to\_a.relation),
 }
```


---


### 2) Remplace la section “A↔B not modified” par “B→A augmente, A→B stable”


Cherche cette section :


```
# Assertions 2) A<->B not modified by opportunism table

# On attend 0 variation, mais on tolère +/-1 en cas d'arrondi/clamp

var eps := 1.0

\_assert(abs(ab\_after["rel\_mean"] - ab\_before["rel\_mean"]) <= eps, ...)
\_assert(abs(ab\_after["trust\_mean"] - ab\_before["trust\_mean"]) <= eps, ...)
\_assert(abs(ab\_after["tension\_mean"] - ab\_before["tension\_mean"]) <= eps, ...)
\_assert(abs(ab\_after["griev\_mean"] - ab\_before["griev\_mean"]) <= eps, ...)
```


**Remplace par :**


```
# Assertions 2) Suspicion asymétrique: B->A augmente, A->B reste stable

var eps := 1.0

# A->B doit rester stable (±1)

\_assert(abs(ab\_dir\_after["A2B\_tension"] - ab\_dir\_before["A2B\_tension"]) <= eps,
 "A->B tension should remain stable (%.1f -> %.1f)" % [ab\_dir\_before["A2B\_tension"], ab\_dir\_after["A2B\_tension"]])

\_assert(abs(ab\_dir\_after["A2B\_griev"] - ab\_dir\_before["A2B\_griev"]) <= eps,
 "A->B grievance should remain stable (%.1f -> %.1f)" % [ab\_dir\_before["A2B\_griev"], ab\_dir\_after["A2B\_griev"]])

# B->A doit monter (au moins +1) en tension/grievance

\_assert(ab\_dir\_after["B2A\_tension"] >= ab\_dir\_before["B2A\_tension"] + 1.0,
 "B->A tension should increase due to suspicion (%.1f -> %.1f)" % [ab\_dir\_before["B2A\_tension"], ab\_dir\_after["B2A\_tension"]])

\_assert(ab\_dir\_after["B2A\_griev"] >= ab\_dir\_before["B2A\_griev"] + 1.0,
 "B->A grievance should increase due to suspicion (%.1f -> %.1f)" % [ab\_dir\_before["B2A\_griev"], ab\_dir\_after["B2A\_griev"]])
```


>
> Si ton clamp est très strict, tu peux mettre `+0.5` au lieu de `+1.0`, mais avec 3 events, tu devrais largement dépasser +1.
>
>
>


---


### 3) Où placer les nouvelles snapshots


Dans ton test, remplace ces lignes :


```
var ab\_before := \_snapshot(relations[A][B], relations[B][A])
var ac\_before := \_snapshot(relations[A][C], relations[C][A])
...
var ab\_after := \_snapshot(relations[A][B], relations[B][A])
var ac\_after := \_snapshot(relations[A][C], relations[C][A])
```


Par :


```
var ab\_dir\_before := \_snapshot\_dir(relations[A][B], relations[B][A])
var ac\_before := \_snapshot(relations[A][C], relations[C][A])
...
var ab\_dir\_after := \_snapshot\_dir(relations[A][B], relations[B][A])
var ac\_after := \_snapshot(relations[A][C], relations[C][A])
```


(et garde la partie A↔C identique).


---


Si tu veux, je peux aussi ajouter une assertion bonus : **B→A trust baisse** (si tu actives le `trust -1` optionnel).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 9](#toc-detail-ch9)
<a id="moi-65"></a>
**Moi 65:**
ajouter une assertion bonus : B→A trust baisse


**ChatGPT:**
Voici le patch bonus **exact** à ajouter au même test (`ThirdPartyOpportunismSideEffectsTest.gd`) pour vérifier que **B→A trust baisse**, *si* tu as activé l’option `{"dir":"V2BEN","field":"trust","delta":-1}` dans ta table.


### À ajouter juste après les assertions “B→A tension/grievance augmente”


Ajoute ceci :


```
# Bonus: si tu actives la paranoïa (trust -1), alors B->A trust doit baisser

\_assert(ab\_dir\_after["B2A\_trust"] <= ab\_dir\_before["B2A\_trust"] - 1.0,
 "B->A trust should decrease due to suspicion (%.1f -> %.1f)" % [ab\_dir\_before["B2A\_trust"], ab\_dir\_after["B2A\_trust"]])
```


### Si tu veux que le test passe même quand tu n’actives PAS le trust -1


Remplace par une version “soft” :


```
# Bonus optionnel: trust baisse seulement si la règle est active.

# Si la règle n'est pas active, trust devrait rester stable (±1).

var trust\_delta := ab\_dir\_after["B2A\_trust"] - ab\_dir\_before["B2A\_trust"]
\_assert(trust\_delta <= 0.0 + 1.0, "B->A trust should not increase unexpectedly (delta=%.1f)" % trust\_delta)
```


Mais si tu m’as dit “ajouter l’assertion bonus”, je pars sur la version stricte (la première).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 9](#toc-detail-ch9)
<a id="moi-66"></a>
**Moi 66:**
Tu dis

pour vérifier que B→A trust baisse, si tu as activé l’option


Comment activer l'option?


**ChatGPT:**
Dans le design qu’on a posé, “activer l’option” = **ajouter (ou décommenter) l’effet dans la table** `ThirdPartyEffectTable.gd`. Il n’y a pas de flag magique ailleurs : c’est data-driven.


## Option 1 — Le plus simple : ajouter la ligne dans `EFFECTS`


Dans `ThirdPartyEffectTable.gd`, à l’endroit où tu as mis la suspicion asymétrique `dir:"V2BEN"` pour `OPPORTUNIST / tp.opportunist.raid / LOYAL`, tu ajoutes (ou décommentes) :


```
{"dir":"V2BEN","field":"trust","delta":-1},
```


Exemple complet :


```
CHOICE\_LOYAL: [
 # ... effets C<->victim et A<->C ...

 {"dir":"V2BEN","field":"tension","delta":+3},
 {"dir":"V2BEN","field":"grievance","delta":+2},
 {"dir":"V2BEN","field":"trust","delta":-1}, # <-- active la paranoïa
],
```


✅ C’est tout : dès que cette entrée est dans la table, `apply_for_opportunist()` la lit et l’applique en one-way **B→A**.


## Option 2 — Via un paramètre (si tu veux toggle runtime)


Si tu veux pouvoir l’activer/désactiver selon ton “mode monde”, tu peux faire un micro-patch :


* ajouter `params: Dictionary = {}` à `apply_for_opportunist(...)`
* et conditionner l’ajout de cet effet “trust -1” via `params.get("suspicion_trust", false)`.


Mais pour une V1, l’option 1 suffit largement.


Si tu me dis “je veux un toggle runtime”, je te donne le micro-patch exact aussi.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 9](#toc-detail-ch9)
<a id="moi-67"></a>
**Moi 67:**
Non

Je voudrais que tu me dise ce que tu penses de cr qu'on a mis en place et est ce que tu as ded idées pour ameliorer les choses hors La persistance et la stabilité des métriques


**ChatGPT:**
Globalement, ce qu’on a construit est déjà **très “système complet V1”** :


* **profils** (axes + personnalité) → **relations** (multi-métriques) → **arcs** (états + transitions + cooldowns) → **offers** (QuestPool)
*
	+ la **3rd party** qui casse l’escalade binaire
*
	+ le pont **Goals ↔ Arcs** pour éviter le “hors-sol”.


Si je cherche ce qui améliorerait vraiment le résultat **sans parler persistance/stabilité**, voilà les meilleures idées.


---


## 1) “Knowledge / rumeurs” (information imparfaite)


Aujourd’hui une faction “voit” les relations/métriques comme si elles étaient parfaites.

Ajoute une notion de **connaissance** :


* “B soupçonne A” (suspicion) peut être basé sur des rumeurs, pas sur vérité.
* Une action “investigate / proof” peut convertir rumeur → fait (et changer les deltas).


Effet : tu obtiens des quêtes “preuve/espionnage” super naturelles, et l’opportunisme/propagande devient un vrai gameplay.


---


## 2) Casus belli + légitimité (political capital)


Tu as déjà “grievance/tension”. Mais il manque un “**droit moral/politique**” de faire la guerre :


* `casus_belli_strength` (0..100) ou `legitimacy_cost`
* déclarer WAR sans casus fort coûte plus (points, trust interne, réputation), et génère plus de **médiation**.


Effet : les escalades “gratuites” diminuent, et les arcs deviennent plus plausibles.


---


## 3) Traités/engagements explicites (pas juste relation)


TRUCE/ALLIANCE ne devrait pas être seulement un état :

Crée un mini objet “**Treaty**” dans l’ArcState (durée, clauses, pénalités).


* ex: TRUCE 20 jours, clause “no raids”, si violée → gros spike grievance + perte de trust chez les tiers.


Effet : tu fais émerger “trahison”, “incidents frontaliers”, “garanties”, etc.


---


## 4) Objectifs de guerre (war aims) + conditions de sortie


WAR sans “but”, ça boucle. Ajoute une cible :


* `war_aim`: “punish”, “take\_land”, “destroy\_army”, “install\_puppet”, “tribute”
* et une condition de sortie liée au but (réussite partielle possible).


Effet : tes transitions WAR → TRUCE/RESOLVED deviennent mécaniquement motivées.


---


## 5) Coalitions/blocs (multi-paires mais lisibles)


La 3rd party est un bon début. Une étape simple au-dessus :


* un “bloc” (liste de factions) **temporaire** autour d’un conflit (ex: coalition anti-hégémonique),
* avec 1–2 quêtes “joint operation” (pas besoin d’un arc à 3 complet).


Effet : le monde se structure, et tu obtiens naturellement alliances/fusions.


---


## 6) “Domestic pressure” (politique interne)


Même sans sim interne complexe, un scaler suffit :


* `internal_stability` ou `war_support`
* la guerre longue baisse le support → pousse TRUCE/REPARATIONS même si l’ennemi est détesté.


Effet : sortie de guerre organique + quêtes “maintenir l’ordre / propaganda / appease nobles”.


---


## 7) UX : journal d’arc côté joueur (résumé + raisons)


Tes systèmes vont produire des comportements subtils. Il faut que le joueur voie :


* “Pourquoi cette offer existe ?” (hotness, suspicion, médiation, opportunisme)
* un **résumé en 2 lignes** par paire A↔B (“3 raids récents, suspicion élevée, médiation proposée par C”).


Effet : le système paraît intelligent, pas arbitraire.


---


## 8) Variété des offers par “stake” (pas que combat/diplo)


Tu as déjà les types, mais tu peux renforcer :


* “stakes” → détermine le **genre** : otages / artefacts / famine / frontière / ressources / sanctuaire profané.
* et la 3rd party peut offrir “garantie / arbitrage / commerce”.


Effet : la guerre devient aussi logistique, morale, économique.


---


## 9) Économie : inflation narrative & rareté


Tu as escrow/or/budget. Ajoute une règle “rare” :


* si une faction est pauvre → elle propose plus souvent des quêtes **non-monnayées** (faveurs, accès, traités, artefacts, influence).
* inversement, riche → paye plus, mais attire opportunistes.


Effet : le monde raconte l’économie, pas juste “gold ↑”.


---


## 10) “Failure modes” intéressants


Aujourd’hui, un échec est souvent “rien”. Donne-lui une conséquence :


* LOYAL/NEUTRAL/TRAITOR + SUCCESS/FAILURE
* ex: médiation échoue → tension↑ mais trust envers C peut ↓ (“médiateur incompétent”).


Effet : tes quêtes nourrissent vraiment le monde.


---


### Ce qui me semble manquer “en priorité”


Si je ne dois en choisir que 3 pour une V1+ :

1) **Traités/clauses** (TRUCE/ALLIANCE deviennent concrets)

2) **War aims + sortie** (sinon WAR peut tourner longtemps)

3) **Knowledge/rumeurs** (ça rend les offers à 3 factions incroyablement naturelles)


Si tu veux, je peux te proposer un mini schéma de données **Treaty** (10 champs max) + comment il s’intègre à `ArcStateMachine.update_arc_state()` et aux deltas (violation/expiration).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 9](#toc-detail-ch9)
<a id="moi-68"></a>
**Moi 68:**
Ok

proposer un mini schéma de données Treaty (10 champs max) + comment il s’intègre à
<a id="cite-arcstatemachine-253c3b-1"></a>ArcStateMachine.update\_arc\_state() et aux deltas (violation/expiration).


**ChatGPT:**
Voici une proposition **Treaty V1** (≤10 champs) + l’intégration **très simple** dans `ArcStateMachine.update_arc_state()` et dans l’application des deltas (violation/expiration).


---


## 1) Schéma de données `Treaty` (10 champs max)


```
# Treaty.gd

class\_name Treaty
extends RefCounted

var type: StringName = &"TRUCE" # TRUCE | ALLIANCE | TRADE\_PACT | VASSALAGE (plus tard)
var start\_day: int = 0
var end\_day: int = 0 # expiration dure
var cooldown\_after\_end\_days: int = 20 # pair\_lock\_days post-traité

# Clauses (bitmask) : très compact et facile à tester

const CLAUSE\_NO\_RAID := 1 << 0
const CLAUSE\_NO\_SABOTAGE:= 1 << 1
const CLAUSE\_NO\_WAR := 1 << 2
const CLAUSE\_OPEN\_TRADE := 1 << 3
var clauses: int = 0

# Enforcement / sanctions

var violation\_score: float = 0.0 # monte à chaque violation
var violation\_threshold: float = 1.0 # si dépassé => traité cassé / pénalités

# “Garants” (optionnel) : troisième partie qui a de l’influence

var guarantor\_id: StringName = &"" # ex: C médiateur (ou vide)
```


✅ 9 champs, extensible sans casser.


---


## 2) Intégration dans `ArcState`


Ajoute un champ dans `ArcState.gd` :


```
var treaty: Treaty = null
```


---


## 3) Définir les violations (quelles actions cassent quelles clauses)


Dans `ArcStateMachine.gd` :


```
static func action\_violates\_clauses(action: StringName, clauses: int) -> bool:
 if (clauses & Treaty.CLAUSE\_NO\_RAID) != 0 and action == ArcDecisionUtil.ARC\_RAID:
 return true
 if (clauses & Treaty.CLAUSE\_NO\_SABOTAGE) != 0 and action == ArcDecisionUtil.ARC\_SABOTAGE:
 return true
 if (clauses & Treaty.CLAUSE\_NO\_WAR) != 0 and action == ArcDecisionUtil.ARC\_DECLARE\_WAR:
 return true
 return false

static func violation\_severity(action: StringName) -> float:
 match action:
 ArcDecisionUtil.ARC\_DECLARE\_WAR: return 1.2
 ArcDecisionUtil.ARC\_SABOTAGE: return 0.6
 ArcDecisionUtil.ARC\_RAID: return 0.45
 \_: return 0.3
```


---


## 4) Deltas standard en cas de violation (et côté garant)


Toujours dans `ArcStateMachine.gd` (ou un util) :


```
static func apply\_treaty\_violation\_deltas(
 rel\_ab: FactionRelationScore,
 rel\_ba: FactionRelationScore,
 sev: float
) -> void:
 # AB et BA (symétrique) : trust s'effondre, tension/grievance montent
 rel\_ab.trust = int(clampi(rel\_ab.trust - int(20.0 * sev), 0, 100))
 rel\_ba.trust = int(clampi(rel\_ba.trust - int(20.0 * sev), 0, 100))

 rel\_ab.tension = int(clampi(rel\_ab.tension + int(15.0 * sev), 0, 100))
 rel\_ba.tension = int(clampi(rel\_ba.tension + int(15.0 * sev), 0, 100))

 rel\_ab.grievance = int(clampi(rel\_ab.grievance + int(18.0 * sev), 0, 100))
 rel\_ba.grievance = int(clampi(rel\_ba.grievance + int(18.0 * sev), 0, 100))

 rel\_ab.relation = int(clampi(rel\_ab.relation - int(12.0 * sev), -100, 100))
 rel\_ba.relation = int(clampi(rel\_ba.relation - int(12.0 * sev), -100, 100))
```


Et si tu veux que le **garant** perde aussi en “crédibilité” (optionnel mais cool) :


* tu appliques une petite baisse de trust vers le garant (A→C et B→C), mais ça se fait plutôt dans une couche “WorldRelations” où tu as accès aux 3 ids.


---


## 5) Intégration dans `update_arc_state()`


### A) Expiration automatique


Au début de `update_arc_state()` :


```
# 0) Treaty expiration check

if arc\_state.treaty != null and day >= arc\_state.treaty.end\_day:
 # traité expiré => lock post-traité
 arc\_state.lock\_until\_day = max(arc\_state.lock\_until\_day, day + arc\_state.treaty.cooldown\_after\_end\_days)
 arc\_state.treaty = null

 # (optionnel) après expiration, tu peux revenir vers NEUTRAL/TRUCE selon tes métriques
 # arc\_state.state = &"NEUTRAL"
```


### B) Détection de violation si un action “hostile” arrive pendant un traité


Juste après avoir reçu `action` (ou après avoir déterminé `canonical_action`) :


```
# 1) Treaty violation check (if treaty active)

if arc\_state.treaty != null and action != &"":
 if action\_violates\_clauses(action, arc\_state.treaty.clauses):
 var sev := violation\_severity(action)
 arc\_state.treaty.violation\_score += sev

 apply\_treaty\_violation\_deltas(rel\_ab, rel\_ba, sev)

# Si trop de violations => traité cassé

 if arc\_state.treaty.violation\_score >= arc\_state.treaty.violation\_threshold:
 arc\_state.lock\_until\_day = max(arc\_state.lock\_until\_day, day + arc\_state.treaty.cooldown\_after\_end\_days)
 arc\_state.treaty = null
 # Le state remonte vers CONFLICT (ou WAR si action=DECLARE\_WAR)
 arc\_state.state = &"CONFLICT" if action != ArcDecisionUtil.ARC\_DECLARE\_WAR else &"WAR"
 arc\_state.phase\_hostile += 1
 return
 # Sinon, on garde le traité mais on “enregistre” le choc
 arc\_state.phase\_hostile += 1
 return
```


>
> `return` est important : une violation est déjà un événement “majeur”, inutile de faire en plus d’autres transitions ce tick.
>
>
>


---


## 6) Quand créer un traité (TRUCE/ALLIANCE)


Deux options :


* quand l’arc passe en état `TRUCE` → créer `Treaty(TRUCE)`
* quand l’arc passe `ALLIANCE` → créer `Treaty(ALLIANCE)`


Ex :


```
static func create\_truce\_treaty(day: int, guarantor\_id: StringName = &"") -> Treaty:
 var t := Treaty.new()
 t.type = &"TRUCE"
 t.start\_day = day
 t.end\_day = day + 20
 t.cooldown\_after\_end\_days = 25
 t.clauses = Treaty.CLAUSE\_NO\_RAID | Treaty.CLAUSE\_NO\_SABOTAGE | Treaty.CLAUSE\_NO\_WAR
 t.violation\_score = 0.0
 t.violation\_threshold = 1.2
 t.guarantor\_id = guarantor\_id
 return t
```


Et dans ta transition vers TRUCE (dans `update_arc_state()` quand tes conditions sont remplies) :


```
arc\_state.state = &"TRUCE"
arc\_state.treaty = create\_truce\_treaty(day, arc\_state.last\_mediator\_id if arc\_state.has("last\_mediator\_id") else &"")
arc\_state.lock\_until\_day = max(arc\_state.lock\_until\_day, day + 10)

# lock court “anti-churn”

```


---


## 7) Pourquoi ça marche bien


* TRUCE/ALLIANCE deviennent **des engagements** (pas juste un label).
* La **violation** est un événement clair, avec **conséquences mécaniques**.
* La **fin** (expiration) déclenche un **pair\_lock** long, ce qui évite “incident→trêve→incident” en boucle.
* Facile à brancher sur tes offers : “enforce treaty”, “investigate violator”, “mediate breach”.


---


Si tu veux, prochaine brique logique : 2–3 offres “treaty enforcement” + comment elles modifient `violation_score` (ex : LOYAL baisse violation\_score ou prolonge end\_day, TRAITOR falsifie preuves et augmente violation\_score).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 10](#toc-detail-ch10)
<a id="moi-69"></a>
**Moi 69:**
logique : 2–3 offres “treaty enforcement” + comment elles modifient violation\_score (ex : LOYAL baisse violation\_score ou prolonge end\_day, TRAITOR falsifie preuves et augmente violation\_score).


**ChatGPT:**
Voici 3 offres “**treaty enforcement**” très simples (mais super riches) + un mapping clair des effets sur `Treaty.violation_score` / `end_day` / relations.


## Contexte standard (dans `QuestInstance.context`)


Pour toutes ces offres :


```
"is\_treaty\_enforcement": true
"treaty\_type": &"TRUCE" | &"ALLIANCE"
"pair\_key": primary\_pair\_key
"side\_a\_faction\_id": A
"side\_b\_faction\_id": B
"guarantor\_id": C (optionnel)
"treaty\_end\_day": treaty.end\_day
"treaty\_violation\_score": treaty.violation\_score
"treaty\_violation\_threshold": treaty.violation\_threshold
```


---


# 1) Offer: “Investigate breach” (preuve / espionnage)

### Quand la générer


* `treaty.violation_score > 0.3` **et** il y a eu une action suspecte récente (via ArcNotebook heat ou “last\_violation\_action” si tu la stockes)

### Variants (2-3 templates)


* stealth: infiltrate border post / recover orders
* diplomacy: interrogate witnesses in neutral city
* retrieval: seize “proof artifact” (letters/seals)

### Effets (sur résolution)


**LOYAL** (preuve réelle, stabilise)


* `treaty.violation_score -= 0.35`
* `treaty.end_day += 2` (petite prolongation, “on clarifie”)
* `A↔B trust +4`, `tension -3`


**NEUTRAL** (rapport flou)


* `treaty.violation_score -= 0.15`
* `treaty.end_day += 0`
* `trust +1`


**TRAITOR** (falsifie preuves pour faire monter)


* `treaty.violation_score += 0.40`
* `A↔B tension +4`, `trust -4`
* (optionnel) si garant C : `A→C trust -3` et/ou `B→C trust -3` quand la fraude est découverte plus tard


---


# 2) Offer: “Enforce ceasefire” (patrouille / escorte / crackdown)

### Quand la générer


* traité actif + “incident mineur” (raid/sabotage avorté) OU `violation_score` approche le seuil (ex > 0.6)

### Variants


* combat: stop border skirmish
* escort: escort inspectors / peacekeepers
* logistics: secure checkpoints / supply compliance


### Effets


**LOYAL** (application ferme)


* `treaty.violation_score -= 0.25`
* `treaty.end_day += 4` (ça stabilise)
* `weariness -2` (réduit coût guerre)
* `A↔B tension -4`


**NEUTRAL** (application molle)


* `treaty.violation_score -= 0.10`
* `end_day += 1`


**TRAITOR** (ferme les yeux / laisse passer)


* `treaty.violation_score += 0.25`
* `A↔B tension +3`, `grievance +3`


---


# 3) Offer: “Arbitration summit” (conférence / arbitrage, souvent via third party)

### Quand la générer


* si `guarantor_id != ""` OU si l’un des camps a une personnalité “diplomacy” élevée
* surtout quand `violation_score` oscille sans retomber (ex: 0.3–0.8)

### Variants


* escort diplomat
* secure neutral venue
* eliminate spoiler (tiers qui veut faire capoter)

### Effets


**LOYAL** (accord d’arbitrage)


* `treaty.violation_score = max(0, treaty.violation_score - 0.45)`
* `treaty.end_day += 6`
* `A↔B trust +6`, `relation +4`, `tension -6`
* si garant C : `A↔C relation +4`, `B↔C relation +4` (crédibilité)


**NEUTRAL**


* `violation_score -= 0.20`
* `end_day += 2`
* `trust +2`


**TRAITOR** (sabotage diplomatique)


* `violation_score += 0.35`
* `end_day -= 2` (ou traité cassé si tu préfères)
* `trust -6`, `tension +6`


---


## Application code (mini util)


Dans `ArcStateMachine` (ou `TreatySystem.gd`) :


```
static func apply\_treaty\_enforcement\_resolution(
 arc\_state: ArcState,
 rel\_ab: FactionRelationScore,
 rel\_ba: FactionRelationScore,
 enforcement\_type: StringName, # &"investigate"|"enforce"|"summit"
 choice: StringName,
 day: int
) -> void:
 var t := arc\_state.treaty
 if t == null:
 return

 var dv := 0.0
 var dend := 0
 var d\_trust := 0
 var d\_tension := 0
 var d\_rel := 0
 var d\_wear := 0

 match enforcement\_type:
 &"investigate":
 if choice == &"LOYAL": dv = -0.35; dend = +2; d\_trust = +4; d\_tension = -3
 elif choice == &"NEUTRAL":dv = -0.15; dend = 0; d\_trust = +1
 else: dv = +0.40; dend = 0; d\_trust = -4; d\_tension = +4
 &"enforce":
 if choice == &"LOYAL": dv = -0.25; dend = +4; d\_tension = -4; d\_wear = -2
 elif choice == &"NEUTRAL":dv = -0.10; dend = +1
 else: dv = +0.25; dend = 0; d\_tension = +3
 &"summit":
 if choice == &"LOYAL": dv = -0.45; dend = +6; d\_trust = +6; d\_tension = -6; d\_rel = +4
 elif choice == &"NEUTRAL":dv = -0.20; dend = +2; d\_trust = +2
 else: dv = +0.35; dend = -2; d\_trust = -6; d\_tension = +6

 t.violation\_score = clampf(t.violation\_score + dv, 0.0, 2.0)
 t.end\_day = max(t.end\_day + dend, day + 1)

# Apply small relation deltas to both directions

 if d\_trust != 0:
 rel\_ab.trust = int(clampi(rel\_ab.trust + d\_trust, 0, 100))
 rel\_ba.trust = int(clampi(rel\_ba.trust + d\_trust, 0, 100))
 if d\_tension != 0:
 rel\_ab.tension = int(clampi(rel\_ab.tension + d\_tension, 0, 100))
 rel\_ba.tension = int(clampi(rel\_ba.tension + d\_tension, 0, 100))
 if d\_rel != 0:
 rel\_ab.relation = int(clampi(rel\_ab.relation + d\_rel, -100, 100))
 rel\_ba.relation = int(clampi(rel\_ba.relation + d\_rel, -100, 100))
 if d\_wear != 0:
 rel\_ab.weariness = int(clampi(rel\_ab.weariness + d\_wear, 0, 100))
 rel\_ba.weariness = int(clampi(rel\_ba.weariness + d\_wear, 0, 100))

# Si on repasse en dessous d’un seuil => “stabilité”

 # (optionnel) si t.violation\_score < 0.2: arc\_state.pending\_retaliation = false
```


---


## Génération (2–3 templates / mapping vers QuestPool)


Tu peux mapper ça à ton OfferFactory comme :


* `arc.treaty_investigate` → stealth/retrieve/diplomacy
* `arc.treaty_enforce` → combat/escort/logistics
* `arc.treaty_summit` → escort/secure venue/eliminate spoiler


Et context :


```
"context.is\_arc\_rivalry" = true
"context.is\_treaty\_enforcement" = true
"context.enforcement\_type" = &"investigate"|"enforce"|"summit"
"context.treaty\_type" = arc\_state.treaty.type
"context.pair\_key" = primary\_pair\_key
```


---


Si tu veux, prochaine brique logique : un mini test “violation puis enforcement loyal” qui vérifie que `violation_score` redescend et que le traité ne casse pas, + un test “traitor summit” qui casse le traité (score dépasse threshold).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 10](#toc-detail-ch10)
<a id="moi-70"></a>
**Moi 70:**
prochaine brique logique : un mini test “violation puis enforcement loyal” qui vérifie que violation\_score redescend et que le traité ne casse pas, + un test “traitor summit” qui casse le traité (score dépasse threshold).


**ChatGPT:**
Voici 2 mini tests Godot (GDScript) qui couvrent exactement ça.


* Test 1 : **violation** (raid pendant TRUCE) → `violation_score` monte → **enforcement LOYAL** → `violation_score` redescend et le traité reste actif.
* Test 2 : **summit TRAITOR** → `violation_score` dépasse `threshold` → le traité **casse** (treaty devient `null`) et l’arc repasse en **CONFLICT/WAR** (selon ta logique).


>
> Hypothèse : tu as implémenté le schéma `Treaty` + la logique de violation dans `ArcStateMachine.update_arc_state()` (celle qu’on a décrite).
>
>  Et la fonction `apply_treaty_enforcement_resolution()` existe (celle du message précédent).
>
>
>


---


## Test 1 — Violation puis enforcement loyal


### `tests/TreatyEnforcementStabilizesTest.gd`


```
extends Node
class\_name TreatyEnforcementStabilizesTest

func \_ready() -> void:
 \_test\_violation\_then\_enforcement\_loyal\_stabilizes()
 print("\n✅ TreatyEnforcementStabilizesTest: OK\n")
 get\_tree().quit()

func \_test\_violation\_then\_enforcement\_loyal\_stabilizes() -> void:
 var rng := RandomNumberGenerator.new()
 rng.seed = 11111

 var rel\_ab := FactionRelationScore.new()
 var rel\_ba := FactionRelationScore.new()
 rel\_ab.relation = 25; rel\_ba.relation = 22
 rel\_ab.trust = 55; rel\_ba.trust = 52
 rel\_ab.tension = 20; rel\_ba.tension = 22
 rel\_ab.grievance = 10;rel\_ba.grievance = 12

 var arc := ArcState.new()
 arc.state = &"TRUCE"
 arc.lock\_until\_day = 0

 # Treaty TRUCE: no raids, threshold fairly high so 1 violation doesn't auto-break
 var t := Treaty.new()
 t.type = &"TRUCE"
 t.start\_day = 1
 t.end\_day = 30
 t.cooldown\_after\_end\_days = 20
 t.clauses = Treaty.CLAUSE\_NO\_RAID | Treaty.CLAUSE\_NO\_SABOTAGE | Treaty.CLAUSE\_NO\_WAR
 t.violation\_score = 0.0
 t.violation\_threshold = 1.2
 arc.treaty = t

 # Day 5: RAID happens => violation score must go up
 ArcStateMachine.update\_arc\_state(
 arc, rel\_ab, rel\_ba,
 5, rng,
 ArcDecisionUtil.ARC\_RAID,
 &"LOYAL"
 )

 \_assert(arc.treaty != null, "treaty should still exist after a single violation")
 var v\_after\_violation := arc.treaty.violation\_score
 \_assert(v\_after\_violation > 0.0, "violation\_score should increase after violation (got %.3f)" % v\_after\_violation)

# Day 6: enforcement LOYAL should reduce violation\_score and not break treaty

 ArcStateMachine.apply\_treaty\_enforcement\_resolution(
 arc, rel\_ab, rel\_ba,
 &"enforce",
 &"LOYAL",
 6
 )

 \_assert(arc.treaty != null, "treaty should remain active after enforcement")
 \_assert(arc.treaty.violation\_score < v\_after\_violation, "violation\_score should decrease after enforcement (%.3f -> %.3f)" % [v\_after\_violation, arc.treaty.violation\_score])

# Sanity: tension should not be higher than right after violation (usually decreases)

 \_assert(rel\_ab.tension <= 100 and rel\_ba.tension <= 100, "tension stays in bounds")


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


## Test 2 — Summit traitor casse le traité


### `tests/TreatySummitTraitorBreaksTest.gd`


```
extends Node
class\_name TreatySummitTraitorBreaksTest

func \_ready() -> void:
 \_test\_traitor\_summit\_breaks\_treaty()
 print("\n✅ TreatySummitTraitorBreaksTest: OK\n")
 get\_tree().quit()

func \_test\_traitor\_summit\_breaks\_treaty() -> void:
 var rng := RandomNumberGenerator.new()
 rng.seed = 22222

 var rel\_ab := FactionRelationScore.new()
 var rel\_ba := FactionRelationScore.new()
 rel\_ab.relation = 30; rel\_ba.relation = 28
 rel\_ab.trust = 60; rel\_ba.trust = 58
 rel\_ab.tension = 18; rel\_ba.tension = 20
 rel\_ab.grievance = 8; rel\_ba.grievance = 10

 var arc := ArcState.new()
 arc.state = &"TRUCE"
 arc.lock\_until\_day = 0

 # Treaty TRUCE: already near threshold so traitor summit pushes it over
 var t := Treaty.new()
 t.type = &"TRUCE"
 t.start\_day = 1
 t.end\_day = 40
 t.cooldown\_after\_end\_days = 25
 t.clauses = Treaty.CLAUSE\_NO\_RAID | Treaty.CLAUSE\_NO\_SABOTAGE | Treaty.CLAUSE\_NO\_WAR
 t.violation\_score = 0.90
 t.violation\_threshold = 1.10 # low threshold so the test is deterministic
 arc.treaty = t

 # Day 10: summit TRAITOR => violation\_score increases enough to cross threshold
 ArcStateMachine.apply\_treaty\_enforcement\_resolution(
 arc, rel\_ab, rel\_ba,
 &"summit",
 &"TRAITOR",
 10
 )

# Now we enforce "break rule" in update\_arc\_state:

 # Either you break immediately inside apply\_treaty\_enforcement\_resolution,
 # or you check it in update\_arc\_state on next tick.
 #
 # We'll do a tick to be safe.
 ArcStateMachine.update\_arc\_state(
 arc, rel\_ab, rel\_ba,
 11, rng,
 &"", &""
 )

 \_assert(arc.treaty == null, "treaty should be broken after traitor summit pushes score over threshold")

# State should have deteriorated (TRUCE no longer valid)

 \_assert(arc.state == &"CONFLICT" or arc.state == &"WAR" or arc.state == &"RIVALRY",
 "arc state should deteriorate after treaty breaks, got %s" % String(arc.state)
 )

# Lock should be applied (post-treaty cooldown)

 \_assert(arc.lock\_until\_day >= 11, "lock\_until\_day should be set after treaty break")


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


### Petit détail d’implémentation à décider (pour que le test 2 passe)


Actuellement `apply_treaty_enforcement_resolution()` ne casse pas le traité directement. Deux options :


1) **Casser immédiatement dans `apply_treaty_enforcement_resolution()`** si `violation_score >= threshold`

2) Ou bien faire la vérif dans `update_arc_state()` “au début de tick” :


```
if arc\_state.treaty != null and arc\_state.treaty.violation\_score >= arc\_state.treaty.violation\_threshold:
 arc\_state.lock\_until\_day = max(arc\_state.lock\_until\_day, day + arc\_state.treaty.cooldown\_after\_end\_days)
 arc\_state.treaty = null
 arc\_state.state = &"CONFLICT"
```


Le test 2 est compatible avec les deux (il appelle un tick `update_arc_state` au jour 11).


Si tu veux, je te donne aussi la micro-fonction utilitaire `maybe_break_treaty(arc_state, day)` pour centraliser ça proprement.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 10](#toc-detail-ch10)
<a id="moi-71"></a>
**Moi 71:**
donne aussi la micro-fonction utilitaire maybe\_break\_treaty(arc\_state, day) pour centraliser ça proprement. Et dis moi où et comment l'integrer


**ChatGPT:**
Voici une micro-fonction utilitaire **centralisée** `maybe_break_treaty()` + où/comment l’intégrer.


---


## 1) Micro-fonction `maybe_break_treaty(arc_state, day, action=…)`


À mettre dans `ArcStateMachine.gd` (ou `TreatySystem.gd` si tu préfères) :


```
static func maybe\_break\_treaty(arc\_state: ArcState, day: int, trigger\_action: StringName = &"") -> bool:
 var t: Treaty = arc\_state.treaty
 if t == null:
 return false
 if t.violation\_score < t.violation\_threshold:
 return false

 # Break treaty + long cooldown lock
 arc\_state.lock\_until\_day = max(arc\_state.lock\_until\_day, day + t.cooldown\_after\_end\_days)

# Deteriorate state (declare\_war -> WAR, otherwise CONFLICT)

 if trigger\_action == ArcDecisionUtil.ARC\_DECLARE\_WAR:
 arc\_state.state = &"WAR"
 else:
 arc\_state.state = &"CONFLICT"

 arc\_state.treaty = null
 return true
```


✅ Retourne `true` si le traité a été cassé (utile pour `return` immédiat dans `update_arc_state()`).


---


## 2) Où l’intégrer (2 endroits clés)

### A) Dans `update_arc_state()` : après toute modification de `violation_score`


1) **après une violation détectée** (raid pendant TRUCE, etc.)

2) **après application d’une quête d’enforcement** si tu fais ça via `update_arc_state()`


Exemple (après `arc_state.treaty.violation_score += sev` + deltas) :


```
if maybe\_break\_treaty(arc\_state, day, action):
 arc\_state.phase\_hostile += 1
 return
```


### B) En début de `update_arc_state()` : sécurité “tick passif”


Ça permet au test “traitor summit” de casser le traité même si l’augmentation du score a été faite ailleurs.


Au tout début (après expiration éventuelle, ou même avant) :


```
# Break check (passive)

if maybe\_break\_treaty(arc\_state, day):
 return
```


>
> Comme ça, si `apply_treaty_enforcement_resolution()` a poussé `violation_score` au-dessus du seuil, le traité casse au prochain tick.
>
>
>


---


## 3) Comment l’utiliser avec `apply_treaty_enforcement_resolution()`


Deux styles possibles :


### Style 1 (recommandé) : **ne casse pas** dans apply, laisse `update_arc_state()` gérer


* `apply_treaty_enforcement_resolution()` modifie `violation_score`
* au prochain tick, `maybe_break_treaty()` est appelé et tranche


Avantage : **un seul endroit** décide de la cassure.


### Style 2 : casser immédiatement (si tu veux feedback instant)


À la fin de `apply_treaty_enforcement_resolution()` :


```
ArcStateMachine.maybe\_break\_treaty(arc\_state, day)
```


---


### Résumé “où et comment”


* **Ajoute** `maybe_break_treaty()` dans `ArcStateMachine`.
* **Appelle-la** :
	+ en **début** de `update_arc_state()` (passif),
	+ et **juste après** toute hausse de `violation_score` (actif).
* Optionnel : l’appeler aussi à la fin de `apply_treaty_enforcement_resolution()` si tu veux une rupture immédiate.


Si tu veux, je peux te donner un patch “diff” exact de `update_arc_state()` (avec les 3 emplacements) en gardant ton style compact.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 10](#toc-detail-ch10)
<a id="moi-72"></a>
**Moi 72:**
Non, on va travailler sur • War aims + sortie (sinon WAR peut tourner longtemps)


**ChatGPT:**
OK. Pour éviter que `WAR` tourne “à vide”, il faut que **la guerre ait un but explicite** (*war aim*) + **un compteur de progrès** + **des sorties** (victoire / paix négociée / capitulation / enlisement).


Voici une V1 **compacte** qui s’intègre très bien à tout ce qu’on a déjà (ArcStateMachine + QuestPool + LOYAL/NEUTRAL/TRAITOR).


---


## 1) WarAim V1


### Enum (5 aims utiles dès maintenant)


* `PUNISH` : “punir / faire payer” (raid, sabotage, humiliation)
* `TRIBUTE` : “obtenir un tribut” (or / ressources / otages)
* `TAKE_POI` : “prendre/contrôler un POI” (ville, fort, mine, sanctuaire)
* `SUBJUGATE` : “vassaliser” (imposer un traité inégal)
* `EXTERMINATE` : “guerre d’extermination” (rare, très coûteux, personnalité belliqueuse/haine)


>
> `ALLIANCE` / `FUSION` ne sont pas des war aims “naturels” : ce sont plutôt des **sorties** possibles d’un conflit long + médiation + menace externe + compatibilité d’axes (on peut les produire via la diplomatie/traités).
>
>
>


---


## 2) Champs à ajouter à `ArcState` (MVP)


```
# ArcState.gd (ajouts)

var war\_aim: StringName = &"" # PUNISH/TRIBUTE/TAKE\_POI/SUBJUGATE/EXTERMINATE
var war\_progress: float = 0.0 # 0..100 (progrès vers l’aim)
var war\_progress\_target: float = 100.0 # seuil de “victoire”
var war\_start\_day: int = -1
var war\_max\_days: int = 45 # au-delà -> pression vers sortie (armistice/terms)
var war\_target\_poi\_id: StringName = &"" # pour TAKE\_POI
var war\_terms: Dictionary = {} # conditions proposées à la sortie
```


---


## 3) Choisir un war aim au passage en WAR


### Heuristique simple (suffisante)


* `EXTERMINATE` si relation très basse + grievance très haute + personnalité belliqueuse + coût supportable
* `TAKE_POI` si opportunité forte + POI stratégique voisin
* `TRIBUTE` si l’attaquant est pauvre / opportuniste
* `PUNISH` par défaut (aim “court”)
* `SUBJUGATE` si rapport de force très favorable + target déjà instable


```
static func choose\_war\_aim(arc\_state: ArcState, rel\_ab: FactionRelationScore, rel\_ba: FactionRelationScore, profiles: Dictionary, a\_id: StringName, b\_id: StringName, ctx: FactionWorldContext) -> void:
 var rel\_mean := 0.5 * (rel\_ab.relation + rel\_ba.relation)
 var griev\_mean := 0.5 * (rel\_ab.grievance + rel\_ba.grievance)
 var tens\_mean := 0.5 * (rel\_ab.tension + rel\_ba.tension)
 var wear\_mean := 0.5 * (rel\_ab.weariness + rel\_ba.weariness)

# exemples de traits (à adapter à tes clés)

 var pa: FactionProfile = profiles.get(a\_id, null)
 var bell := (pa.get\_personality(&"belligerence", 0.5) if pa else 0.5)
 var expa := (pa.get\_personality(&"expansionism", 0.5) if pa else 0.5)

 if rel\_mean <= -80 and griev\_mean >= 70 and bell >= 0.75 and wear\_mean <= 55:
 arc\_state.war\_aim = &"EXTERMINATE"
 arc\_state.war\_max\_days = 70
 elif expa >= 0.65 and ctx.opportunity >= 0.55:
 arc\_state.war\_aim = &"TAKE\_POI"
 arc\_state.war\_target\_poi\_id = &"" # à remplir via ta sélection POI
 arc\_state.war\_max\_days = 55
 elif ctx.external\_threat >= 0.6:
 arc\_state.war\_aim = &"PUNISH" # guerre “limitée” si menace externe
 arc\_state.war\_max\_days = 35
 else:
 arc\_state.war\_aim = &"TRIBUTE" if griev\_mean < 55 else &"PUNISH"
 arc\_state.war\_max\_days = 45

 arc\_state.war\_progress = 0.0
 arc\_state.war\_progress\_target = 100.0
```


---


## 4) Le cœur : convertir les events/quests en `war_progress`


### Table simple (peut être raffinée plus tard)


* Raid réussi : +12 (PUNISH/TRIBUTE), +6 (TAKE\_POI)
* Sabotage : +10 (PUNISH), +8 (TAKE\_POI)
* Capture POI : +35 (TAKE\_POI)
* Imposer tribut (quest): +40 (TRIBUTE)
* Victoire “décisive” (quest decisive battle): +25
* Échec : progression faible ou négative (et weariness↑)


```
static func apply\_war\_progress\_from\_arc\_action(
 arc\_state: ArcState,
 arc\_action: StringName,
 choice: StringName,
 success: bool,
 rel\_ab: FactionRelationScore,
 rel\_ba: FactionRelationScore
) -> void:
 if arc\_state.state != &"WAR":
 return

 var aim := arc\_state.war\_aim
 var dp := 0.0

 if not success:
 # échec = pas de progrès et fatigue augmente
 rel\_ab.weariness = int(clampi(rel\_ab.weariness + 3, 0, 100))
 rel\_ba.weariness = int(clampi(rel\_ba.weariness + 3, 0, 100))
 arc\_state.war\_progress = max(0.0, arc\_state.war\_progress - 4.0)
 return

 match arc\_action:
 ArcDecisionUtil.ARC\_RAID:
 dp = 12.0 if (aim == &"PUNISH" or aim == &"TRIBUTE") else 6.0
 ArcDecisionUtil.ARC\_SABOTAGE:
 dp = 10.0 if aim == &"PUNISH" else 8.0
 &"war.capture\_poi":
 dp = 35.0 if aim == &"TAKE\_POI" else 15.0
 &"war.enforce\_tribute":
 dp = 40.0 if aim == &"TRIBUTE" else 12.0
 &"war.decicive\_battle":
 dp = 25.0
 \_:
 dp = 8.0

 # choice peut moduler (TRAITOR = gain court terme mais trust se dégrade ailleurs)
 if choice == &"LOYAL": dp *= 1.05
 elif choice == &"NEUTRAL": dp *= 0.95
 elif choice == &"TRAITOR": dp *= 1.10

 arc\_state.war\_progress = clampf(arc\_state.war\_progress + dp, 0.0, 120.0)
```


---


## 5) Sorties de guerre (le point clé)

### A) Victoire par accomplissement de l’aim


Si `war_progress >= target` :


* produire des **terms** selon aim
* passer en `TRUCE` (avec `Treaty`) ou `RESOLVED` si tu as un état terminal
* lock long (pair\_lock\_days)


Exemples de `war_terms` :


* PUNISH : réparations + libération prisonniers
* TRIBUTE : escrow/tribut X jours
* TAKE\_POI : transfert de contrôle POI
* SUBJUGATE : vassalage + no-war clause
* EXTERMINATE : (si tu le gardes) → fusion de territoire / destruction (très rare)

### B) Enlisement (max days) → armistice forcé


Si `day - war_start_day >= war_max_days` **ou** `weariness_mean > 75` :


* pousser vers `TRUCE_TALKS / REPARATIONS / SUMMIT` (offers)
* si refus répété → “stalemate” (TRUCE courte + clauses strictes)

### C) Changement de contexte monde


Si `external_threat` explose (menace tierce), même en WAR :


* offrir une sortie “trêve + coalition” (ça crée tes alliances organiques)


```
static func maybe\_end\_war(arc\_state: ArcState, rel\_ab: FactionRelationScore, rel\_ba: FactionRelationScore, day: int, ctx: FactionWorldContext) -> bool:
 if arc\_state.state != &"WAR":
 return false

 var wear\_mean := 0.5 * (rel\_ab.weariness + rel\_ba.weariness)

# Victory

 if arc\_state.war\_progress >= arc\_state.war\_progress\_target:
 arc\_state.war\_terms = build\_war\_terms(arc\_state)
 arc\_state.state = &"TRUCE"
 # ici: arc\_state.treaty = create\_truce\_treaty(day, guarantor?) + lock
 arc\_state.lock\_until\_day = max(arc\_state.lock\_until\_day, day + 20)
 return true

 # Forced armistice
 if arc\_state.war\_start\_day >= 0 and (day - arc\_state.war\_start\_day) >= arc\_state.war\_max\_days:
 arc\_state.war\_terms = {"type":"ARMISTICE", "duration\_days":14}
 arc\_state.state = &"TRUCE"
 arc\_state.lock\_until\_day = max(arc\_state.lock\_until\_day, day + 12)
 return true

 if wear\_mean >= 78.0:
 arc\_state.war\_terms = {"type":"EXHAUSTION\_TRUCE", "duration\_days":10}
 arc\_state.state = &"TRUCE"
 arc\_state.lock\_until\_day = max(arc\_state.lock\_until\_day, day + 10)
 return true

 # External threat pivot
 if ctx.external\_threat >= 0.75:
 # pas forcément fin immédiate, mais pousse à une offer de trêve/coalition
 # (ici tu peux juste poser un flag pending\_peace\_offer)
 arc\_state.war\_terms["pivot"] = "EXTERNAL\_THREAT"
 return false
```


---


## 6) Le pont vers QuestPool : offres “war aim driven”


Chaque aim doit produire **au moins 2–3 familles d’offres** :


* `PUNISH` → raid / sabotage / decisive battle / assassinate officer
* `TRIBUTE` → seize treasury / intercept caravan / enforce payment / hostage exchange
* `TAKE_POI` → capture fort / cut supply / scout weak point / siege prep
* `SUBJUGATE` → capture leader / destroy army / force treaty / propaganda
* `EXTERMINATE` → (rare) burn nests / purge corruption / end leadership (très violent)


Et surtout : **les offers ajoutent du war\_progress** si succès (via `apply_war_progress_from_arc_action()`).


---


## 7) Ce que ça change immédiatement


* Une guerre a une **fin naturelle** (objectif atteint ou épuisement).
* Tu peux faire émerger :
	+ une guerre courte de punition,
	+ une guerre économique (tribut),
	+ une guerre territoriale (POI),
	+ une domination (subjugate),
	+ et très rarement extermination.
* Les offres générées deviennent cohérentes et variées (pas juste “raid infini”).


---


Si tu veux, prochaine brique logique : je te propose `build_war_terms(arc_state)` (compact) + un mapping “terms → Treaty clauses + rewards/penalties” (ex: TRIBUTE crée un traité avec clause `OPEN_TRADE` + escrow périodique).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 11](#toc-detail-ch11)
<a id="moi-73"></a>
**Moi 73:**
prochaine brique logique : je te propose build\_war\_terms(arc\_state) (compact) + un mapping “terms → Treaty clauses + rewards/penalties” (ex: TRIBUTE crée un traité avec clause OPEN\_TRADE + escrow périodique).


**ChatGPT:**
OK — voici une V1 **compacte** de `build_war_terms(arc_state)` + un mapping `terms → Treaty` (clauses) + rewards/penalties (deltas relation/trust/tension + “escrow périodique” simple).


L’idée : `war_terms` reste un `Dictionary` minimal, et on crée ensuite un `Treaty` + effets via une fonction `apply_terms_outcome(...)`.


---


## 1) `build_war_terms(arc_state)` (compact)


```
static func build\_war\_terms(arc\_state: ArcState) -> Dictionary:
 var aim := arc\_state.war\_aim

 match aim:
 &"PUNISH":
 return {
 "type": &"PUNISH",
 "truce\_days": 18,
 "reparations\_gold": 120, # base, modulé ensuite (tier/progress)
 "humiliation": 1, # flag
 }

 &"TRIBUTE":
 return {
 "type": &"TRIBUTE",
 "truce\_days": 22,
 "tribute\_gold\_per\_week": 80,
 "tribute\_weeks": 4,
 "open\_trade": true,
 }

 &"TAKE\_POI":
 return {
 "type": &"TAKE\_POI",
 "truce\_days": 20,
 "poi\_id": arc\_state.war\_target\_poi\_id,
 "no\_raid\_days": 20,
 }

 &"SUBJUGATE":
 return {
 "type": &"SUBJUGATE",
 "truce\_days": 26,
 "vassalage\_days": 40,
 "tribute\_gold\_per\_week": 60,
 "no\_war\_days": 40,
 }

 &"EXTERMINATE":
 # V1: on ne fait pas "suppression de faction" ici. On en fait un traité très dur (capitulation),
 # et le reste (annexion/fusion) peut venir ensuite via systems monde.
 return {
 "type": &"CAPITULATION",
 "truce\_days": 30,
 "disarm": true,
 "no\_war\_days": 60,
 "reparations\_gold": 200,
 }

 \_:
 return {"type": &"ARMISTICE", "truce\_days": 14}
```


---


## 2) Mapping terms → Treaty (clauses + durée)


```
static func treaty\_from\_terms(day: int, terms: Dictionary, guarantor\_id: StringName = &"") -> Treaty:
 var t := Treaty.new()
 t.start\_day = day
 t.type = &"TRUCE"
 t.guarantor\_id = guarantor\_id

 var truce\_days := int(terms.get("truce\_days", 14))
 t.end\_day = day + truce\_days
 t.cooldown\_after\_end\_days = 25

 # Clauses de base: "pas de reprise immédiate"
 t.clauses = Treaty.CLAUSE\_NO\_RAID | Treaty.CLAUSE\_NO\_SABOTAGE | Treaty.CLAUSE\_NO\_WAR

 var typ: StringName = terms.get("type", &"ARMISTICE")

# Extensions par type

 if typ == &"TRIBUTE":
 t.clauses |= Treaty.CLAUSE\_OPEN\_TRADE
 # un tribut implique souvent "pas de sabotage" strict → déjà couvert

 elif typ == &"TAKE\_POI":
 # rien de spécial en clauses (déjà no\_raid/sabotage/war)
 pass

 elif typ == &"SUBJUGATE" or typ == &"CAPITULATION":
 # traité "dur" : seuil plus strict (cassure plus rapide si violation)
 t.violation\_threshold = 0.9
 t.cooldown\_after\_end\_days = 35
 # option : pas de trade automatiquement (à décider)
 else:
 # ARMISTICE / PUNISH
 pass

 # Defaults si non posés
 if t.violation\_threshold <= 0.0:
 t.violation\_threshold = 1.2
 t.violation\_score = 0.0

 return t
```


---


## 3) Rewards/Penalties + “escrow périodique” (tribut)

### A) Deltas immédiats “fin de guerre”


On applique des changements sur A↔B (et éventuellement sur l’image du gagnant/perdant plus tard).


```
static func apply\_terms\_outcome(
 relations: Dictionary, # relations[X][Y] -> FactionRelationScore
 winner\_id: StringName,
 loser\_id: StringName,
 arc\_state: ArcState,
 day: int,
 terms: Dictionary,
 economies: Dictionary # economies[faction] -> FactionEconomy
) -> void:
 var w2l: FactionRelationScore = relations[winner\_id][loser\_id]
 var l2w: FactionRelationScore = relations[loser\_id][winner\_id]

 var typ: StringName = terms.get("type", &"ARMISTICE")

# Base: fin de guerre réduit la tension mais la relation reste souvent négative

 \_apply\_one\_way\_score(w2l, "tension", -18)
 \_apply\_one\_way\_score(l2w, "tension", -18)
 \_apply\_one\_way\_score(w2l, "weariness", -8)
 \_apply\_one\_way\_score(l2w, "weariness", -8)

 match typ:
 &"PUNISH":
 \_apply\_one\_way\_score(w2l, "trust", +3)
 \_apply\_one\_way\_score(l2w, "trust", -6)

# rancune

 \_apply\_one\_way\_score(l2w, "grievance", +10)
 \_transfer\_gold(loser\_id, winner\_id, int(terms.get("reparations\_gold", 0)), economies)

 &"TRIBUTE":
 \_apply\_one\_way\_score(w2l, "trust", +4)
 \_apply\_one\_way\_score(l2w, "trust", -8)
 \_apply\_one\_way\_score(l2w, "grievance", +12)

# pas de gros paiement upfront, mais planification périodique (voir plus bas)

 \_schedule\_tribute(arc\_state, winner\_id, loser\_id, terms)

 &"TAKE\_POI":
 \_apply\_one\_way\_score(w2l, "relation", -2)
 \_apply\_one\_way\_score(l2w, "relation", -14)
 \_apply\_one\_way\_score(l2w, "grievance", +14)

# le transfert POI se fait dans ton système monde (ownership)

 arc\_state.war\_terms["apply\_poi\_transfer"] = true

 &"SUBJUGATE":
 \_apply\_one\_way\_score(w2l, "trust", +2)
 \_apply\_one\_way\_score(l2w, "trust", -14)
 \_apply\_one\_way\_score(l2w, "relation", -18)
 \_apply\_one\_way\_score(l2w, "grievance", +18)
 \_schedule\_tribute(arc\_state, winner\_id, loser\_id, terms)

 &"CAPITULATION":
 \_apply\_one\_way\_score(l2w, "trust", -20)
 \_apply\_one\_way\_score(l2w, "relation", -22)
 \_apply\_one\_way\_score(l2w, "grievance", +25)
 \_transfer\_gold(loser\_id, winner\_id, int(terms.get("reparations\_gold", 0)), economies)

 \_:
 # ARMISTICE
 \_apply\_one\_way\_score(w2l, "trust", +2)
 \_apply\_one\_way\_score(l2w, "trust", +1)
```


Helpers (compacts) :


```
static func \_apply\_one\_way\_score(r: FactionRelationScore, field: String, delta: int) -> void:
 match field:
 "relation": r.relation = int(clampi(r.relation + delta, -100, 100))
 "trust": r.trust = int(clampi(r.trust + delta, 0, 100))
 "tension": r.tension = int(clampi(r.tension + delta, 0, 100))
 "grievance": r.grievance = int(clampi(r.grievance + delta, 0, 100))
 "weariness": r.weariness = int(clampi(r.weariness + delta, 0, 100))

static func \_transfer\_gold(from\_id: StringName, to\_id: StringName, amount: int, economies: Dictionary) -> void:
 if amount <= 0: return
 var ef = economies.get(from\_id, null)
 var et = economies.get(to\_id, null)
 if ef == null or et == null: return
 var pay := min(amount, ef.gold)
 ef.gold -= pay
 et.gold += pay
```


### B) “Escrow périodique” (tribut hebdo)


V1 la plus simple : stocker un petit “schedule” dans `arc_state.war_terms` et le faire tick dans `tick_day_for_pair()`.


```
static func \_schedule\_tribute(arc\_state: ArcState, winner\_id: StringName, loser\_id: StringName, terms: Dictionary) -> void:
 arc\_state.war\_terms["tribute\_active"] = true
 arc\_state.war\_terms["tribute\_winner"] = winner\_id
 arc\_state.war\_terms["tribute\_loser"] = loser\_id
 arc\_state.war\_terms["tribute\_gold\_per\_week"] = int(terms.get("tribute\_gold\_per\_week", 60))
 arc\_state.war\_terms["tribute\_weeks\_left"] = int(terms.get("tribute\_weeks", 4))
 arc\_state.war\_terms["tribute\_next\_day"] = int(arc\_state.war\_terms.get("tribute\_next\_day", 0))

# set by caller if needed

```


Et dans `ArcStateMachine.tick_day_for_pair()` (ou dans le tick monde), tu ajoutes :


```
static func tick\_tribute\_if\_any(arc\_state: ArcState, day: int, economies: Dictionary) -> void:
 if not arc\_state.war\_terms.get("tribute\_active", false):
 return
 if int(arc\_state.war\_terms.get("tribute\_weeks\_left", 0)) <= 0:
 arc\_state.war\_terms["tribute\_active"] = false
 return

 var next\_day := int(arc\_state.war\_terms.get("tribute\_next\_day", day))
 if day < next\_day:
 return

 var winner: StringName = arc\_state.war\_terms["tribute\_winner"]
 var loser: StringName = arc\_state.war\_terms["tribute\_loser"]
 var amt := int(arc\_state.war\_terms.get("tribute\_gold\_per\_week", 60))

 \_transfer\_gold(loser, winner, amt, economies)

 arc\_state.war\_terms["tribute\_weeks\_left"] = int(arc\_state.war\_terms["tribute\_weeks\_left"]) - 1
 arc\_state.war\_terms["tribute\_next\_day"] = day + 7
```


>
> Tu peux appeler `tick_tribute_if_any()` depuis ton tick monde global (pas forcément dans ArcStateMachine), mais mécaniquement c’est “pair-local” donc ça s’y prête bien.
>
>
>


---


## 4) Où ça s’intègre dans ton flow


Quand `maybe_end_war()` détecte une victoire :

1) `terms = build_war_terms(arc_state)`

2) `treaty = treaty_from_terms(day, terms, guarantor_id?)`

3) `arc_state.treaty = treaty` et `arc_state.state = TRUCE`

4) `apply_terms_outcome(relations, winner, loser, arc_state, day, terms, economies)`

5) tick hebdo : `tick_tribute_if_any(arc_state, day, economies)`


---


## 5) Pont vers QuestPool (hyper direct)


Ces `terms` te donnent des **offers de sortie** :


* `TRIBUTE` → “collect payment / punish non-payment / escort tax collector”
* `TAKE_POI` → “secure captured POI / quell rebels / rebuild fortifications”
* `PUNISH` → “deliver reparations / hostage release / war crimes trial”
* `SUBJUGATE` → “install governor / swear oath / crush uprising”


---


Si tu veux, prochaine brique logique : une petite règle “non-payment” pour le tribut (si loser n’a pas l’or → violation\_score du traité monte + offre ‘collect tribute by force’).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 11](#toc-detail-ch11)
<a id="moi-74"></a>
**Moi 74:**
prochaine brique logique : une petite règle “non-payment” pour le tribut (si loser n’a pas l’or → violation\_score du traité monte + offre ‘collect tribute by force’).


**ChatGPT:**
OK — voici une règle V1 “**non-payment**” (tribut) qui est simple, robuste, et génère une offer “**collect tribute by force**”.


---


## 1) Stockage minimal dans `war_terms` (déjà compatible)


On réutilise ce qu’on a :


```
"tribute\_active": true
"tribute\_winner": winner\_id
"tribute\_loser": loser\_id
"tribute\_gold\_per\_week": N
"tribute\_weeks\_left": K
"tribute\_next\_day": day+7
```


On ajoute juste 2 champs pour gérer l’incident :


```
"tribute\_missed\_payments": 0
"tribute\_last\_miss\_day": -999999
```


---


## 2) Règle “tick\_tribute\_if\_any” + non-payment


Patch de la fonction `tick_tribute_if_any()` :


```
static func tick\_tribute\_if\_any(
 arc\_state: ArcState,
 day: int,
 economies: Dictionary,
 relations: Dictionary, # relations[winner][loser]
 notebook: ArcNotebook, # pour cooldown anti-spam d’offer
 spawn\_collect\_offer\_fn: Callable # injection: (winner, loser, day, tier) -> QuestInstance
) -> void:
 if not arc\_state.war\_terms.get("tribute\_active", false):
 return
 if int(arc\_state.war\_terms.get("tribute\_weeks\_left", 0)) <= 0:
 arc\_state.war\_terms["tribute\_active"] = false
 return

 var next\_day := int(arc\_state.war\_terms.get("tribute\_next\_day", day))
 if day < next\_day:
 return

 var winner: StringName = arc\_state.war\_terms["tribute\_winner"]
 var loser: StringName = arc\_state.war\_terms["tribute\_loser"]
 var amt := int(arc\_state.war\_terms.get("tribute\_gold\_per\_week", 60))

 var ew = economies.get(winner, null)
 var el = economies.get(loser, null)
 if ew == null or el == null:
 return

 # --- Payment attempt ---
 if el.gold >= amt:
 \_transfer\_gold(loser, winner, amt, economies)
 arc\_state.war\_terms["tribute\_weeks\_left"] = int(arc\_state.war\_terms["tribute\_weeks\_left"]) - 1
 arc\_state.war\_terms["tribute\_next\_day"] = day + 7

 # reset miss counters gradually
 arc\_state.war\_terms["tribute\_missed\_payments"] = max(0, int(arc\_state.war\_terms.get("tribute\_missed\_payments", 0)) - 1)
 return

 # --- Non-payment: escalate treaty violation + spawn offer ---
 arc\_state.war\_terms["tribute\_missed\_payments"] = int(arc\_state.war\_terms.get("tribute\_missed\_payments", 0)) + 1
 arc\_state.war\_terms["tribute\_last\_miss\_day"] = day
 arc\_state.war\_terms["tribute\_next\_day"] = day + 7 # next attempt anyway

 # Increase treaty violation\_score (if treaty exists)
 if arc\_state.treaty != null:
 # miss\_count makes repeated failures increasingly serious
 var miss := int(arc\_state.war\_terms["tribute\_missed\_payments"])
 arc\_state.treaty.violation\_score += 0.20 + 0.05 * float(min(miss, 6))

# Relation fallout: loser hates winner more (asym)

 var l2w: FactionRelationScore = relations[loser][winner]
 l2w.grievance = int(clampi(l2w.grievance + 6, 0, 100))
 l2w.tension = int(clampi(l2w.tension + 4, 0, 100))
 l2w.trust = int(clampi(l2w.trust - 4, 0, 100))

# winner becomes less trusting too (sym small)

 var w2l: FactionRelationScore = relations[winner][loser]
 w2l.trust = int(clampi(w2l.trust - 2, 0, 100))
 w2l.tension = int(clampi(w2l.tension + 2, 0, 100))

# Check break

 if ArcStateMachine.maybe\_break\_treaty(arc\_state, day):
 # treaty broke => the "collect tribute" offer can become a WAR/CONFLICT offer naturally elsewhere
 return

 # Anti-spam cooldown: max 1 collect offer per 7 days per pair
 var pair\_key := StringName((String(winner) <= String(loser)) ? (String(winner)+"|"+String(loser)) : (String(loser)+"|"+String(winner)))
 if not notebook.can\_spawn\_third\_party(pair\_key, day, 7): # reuse helper OR create a dedicated "can\_spawn\_collect"
 return
 notebook.mark\_third\_party\_spawned(pair\_key, day)

# Spawn "collect tribute by force" (tier escalates with missed count)

 var missed := int(arc\_state.war\_terms.get("tribute\_missed\_payments", 1))
 var tier := clampi(1 + missed, 1, 4)
 var inst: QuestInstance = spawn\_collect\_offer\_fn.call(winner, loser, day, tier)
 if inst != null:
 # caller adds to QuestPool; we keep tick pure
 pass
```


>
> Note : j’ai réutilisé `can_spawn_third_party()` juste pour cooldown (tu peux renommer en `can_spawn_pair_offer()` plus générique).
>
>
>


---


## 3) Offer “collect tribute by force” (MVP)


C’est une offer **WAR-terms**, pas une simple ARC\_RAID.

Tu peux la mapper à 2–3 variantes :


* `combat.collect_tribute` (attaquer percepteurs / dépôt)
* `stealth.collect_tribute` (voler coffres / falsifier registres)
* `logistics.collect_tribute` (saisir caravanes)

### Spawn fn (simple)


```
func spawn\_collect\_tribute\_offer(winner: StringName, loser: StringName, day: int, tier: int) -> QuestInstance:
 var ctx := {
 "is\_arc\_rivalry": true,
 "is\_war\_terms": true,
 "war\_terms\_type": &"TRIBUTE",
 "arc\_action\_type": &"war.collect\_tribute\_by\_force",
 "giver\_faction\_id": winner,
 "antagonist\_faction\_id": loser,
 "expires\_in\_days": 7,
 "stake": {"type":"TRIBUTE", "tier":tier}
 }
 var template := ArcOfferFactory.\_build\_template\_fallback("logistics.collect\_tribute", tier, 7)
 var inst := QuestInstance.new(template, ctx)
 inst.status = "AVAILABLE"
 inst.started\_on\_day = day
 inst.expires\_on\_day = day + 7
 return inst
```


### Effet sur succès/échec


* Succès LOYAL : paiement partiel récupéré + `violation_score -= 0.15` (on “régularise”)
* Échec : `violation_score += 0.10`, et augmente weariness


---


## 4) Où brancher ça


* Si tu tick les arcs quotidiennement : à la fin de `ArcStateMachine.tick_day_for_pair()` (ou juste après) tu appelles `tick_tribute_if_any(...)`.
* Si tu préfères centraliser : dans ton `WorldSim.tick_day()` après avoir tické toutes les paires.


L’important : ça doit être appelé **même les jours sans arcs**, comme tes autres compteurs.


---


## 5) Mini test (si tu veux tout de suite)


Un test rapide :


* loser.gold = 0
* tribute due day 7
* assert `violation_score` augmente
* assert spawn\_collect\_offer\_fn est appelé (via Callable stub)
* puis donne de l’or au loser, tick suivant => paiement OK et missed decreases.


Si tu veux, je te l’écris comme les autres tests.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 11](#toc-detail-ch11)
<a id="moi-75"></a>
**Moi 75:**
Ok, fais ca

5) Mini test (si tu veux tout de suite)


Un test rapide :


loser.gold = 0


tribute due day 7


assert violation\_score augmente


assert spawn\_collect\_offer\_fn est appelé (via Callable stub)


puis donne de l’or au loser, tick suivant écris comme les autres tests


**ChatGPT:**
Voici un **mini test Godot** dans le même style que les précédents. Il simule :


* `loser.gold = 0`
* tribut dû au **jour 7**
* ✅ `violation_score` augmente
* ✅ `spawn_collect_offer_fn` est appelé (stub)
* puis on donne de l’or au loser et on retick au **jour 14**
* ✅ paiement effectué (gold transféré) et `weeks_left` diminue


>
> Hypothèses :
>
>
> * `ArcState`, `Treaty`, `FactionRelationScore`, `ArcStateMachine.tick_tribute_if_any()` existent avec la signature qu’on a proposée.
> * `ArcNotebook` existe et a `can_spawn_third_party()` / `mark_third_party_spawned()` (ou équivalent cooldown).
> * `FactionEconomy` a un champ `gold:int` (sinon adapte en `economy.gold`/`get_gold()`).
>
>
>


---


## `tests/TributeNonPaymentSpawnsCollectOfferTest.gd`


```
extends Node
class\_name TributeNonPaymentSpawnsCollectOfferTest

func \_ready() -> void:
 \_test\_non\_payment\_spawns\_collect\_offer\_then\_payment\_succeeds()
 print("\n✅ TributeNonPaymentSpawnsCollectOfferTest: OK\n")
 get\_tree().quit()


func \_test\_non\_payment\_spawns\_collect\_offer\_then\_payment\_succeeds() -> void:
 var winner := &"A"
 var loser := &"B"

 # --- economies ---
 var economies := {}
 economies[winner] = FactionEconomy.new()
 economies[loser] = FactionEconomy.new()
 economies[winner].gold = 0
 economies[loser].gold = 0 # non-payment

 # --- relations ---
 var relations := {}
 relations[winner] = {}
 relations[loser] = {}
 relations[winner][loser] = FactionRelationScore.new()
 relations[loser][winner] = FactionRelationScore.new()

# some baseline values

 relations[winner][loser].trust = 40
 relations[winner][loser].tension = 20
 relations[winner][loser].grievance = 10

 relations[loser][winner].trust = 35
 relations[loser][winner].tension = 25
 relations[loser][winner].grievance = 15

 # --- arc + treaty + tribute schedule ---
 var arc := ArcState.new()
 arc.state = &"TRUCE"

 var t := Treaty.new()
 t.type = &"TRUCE"
 t.start\_day = 1
 t.end\_day = 60
 t.cooldown\_after\_end\_days = 25
 t.clauses = Treaty.CLAUSE\_NO\_RAID | Treaty.CLAUSE\_NO\_SABOTAGE | Treaty.CLAUSE\_NO\_WAR | Treaty.CLAUSE\_OPEN\_TRADE
 t.violation\_score = 0.0
 t.violation\_threshold = 1.2
 arc.treaty = t

 arc.war\_terms = {
 "tribute\_active": true,
 "tribute\_winner": winner,
 "tribute\_loser": loser,
 "tribute\_gold\_per\_week": 50,
 "tribute\_weeks\_left": 2,
 "tribute\_next\_day": 7,
 "tribute\_missed\_payments": 0,
 "tribute\_last\_miss\_day": -999999
 }

 # --- notebook + stub spawn fn ---
 var notebook := ArcNotebook.new()
 var spawn\_called := false
 var spawn\_args := {}

 var spawn\_fn := func(w: StringName, l: StringName, day: int, tier: int) -> QuestInstance:
 spawn\_called = true
 spawn\_args = {"winner": w, "loser": l, "day": day, "tier": tier}
 # returning null is fine; this test only checks callback call
 return null

 # --- Day 7: due but loser has 0 => violation\_score increases + spawn called ---
 var v\_before := arc.treaty.violation\_score
 ArcStateMachine.tick\_tribute\_if\_any(
 arc, 7,
 economies,
 relations,
 notebook,
 Callable(spawn\_fn)
 )

 \_assert(arc.treaty != null, "treaty should still exist after first non-payment (should not auto-break)")
 \_assert(arc.treaty.violation\_score > v\_before, "violation\_score should increase on non-payment (%.3f -> %.3f)" % [v\_before, arc.treaty.violation\_score])
 \_assert(spawn\_called, "spawn\_collect\_offer\_fn should be called on non-payment")
 \_assert(StringName(spawn\_args.get("winner", &"")) == winner, "spawn arg winner mismatch")
 \_assert(StringName(spawn\_args.get("loser", &"")) == loser, "spawn arg loser mismatch")
 \_assert(int(spawn\_args.get("day", -1)) == 7, "spawn day should be 7")

# weeks\_left should NOT decrement on non-payment

 \_assert(int(arc.war\_terms["tribute\_weeks\_left"]) == 2, "weeks\_left should not decrement on non-payment")

# --- Give gold and tick next due (day 14) => payment succeeds, gold transfers, weeks\_left decrements ---

 economies[loser].gold = 80
 spawn\_called = false
 spawn\_args = {}

 var winner\_gold\_before := economies[winner].gold
 var loser\_gold\_before := economies[loser].gold
 var weeks\_before := int(arc.war\_terms["tribute\_weeks\_left"])

 ArcStateMachine.tick\_tribute\_if\_any(
 arc, 14,
 economies,
 relations,
 notebook,
 Callable(spawn\_fn)
 )

# should not spawn now (successful payment)

 \_assert(not spawn\_called, "spawn\_collect\_offer\_fn should not be called on successful payment")

# transfer happened

 var amt := int(arc.war\_terms.get("tribute\_gold\_per\_week", 50))
 \_assert(economies[winner].gold == winner\_gold\_before + amt, "winner gold should increase by tribute amount")
 \_assert(economies[loser].gold == loser\_gold\_before - amt, "loser gold should decrease by tribute amount")

# weeks left decremented

 \_assert(int(arc.war\_terms["tribute\_weeks\_left"]) == weeks\_before - 1, "weeks\_left should decrement on successful payment")


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


### Notes d’adaptation rapide (si besoin)


* Si ton `FactionEconomy` n’a pas `gold`, remplace par tes méthodes (ex `get_gold()` / `add_gold()`).
* Si tu ne veux pas réutiliser `can_spawn_third_party()` pour le cooldown, le test s’en fiche tant que le spawn fn est appelé au jour 7.


Si tu veux, je te fais aussi une variante où **2 non-payments** déclenchent une **cassure du traité** (violation\_score dépasse threshold) et bascule vers `CONFLICT/WAR`.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 11](#toc-detail-ch11)
<a id="moi-76"></a>
**Moi 76:**
fais aussi une variante où 2 non-payments déclenchent une cassure du traité (violation\_score dépasse threshold) et bascule vers CONFLICT/WAR


**ChatGPT:**
Voici une **variante** qui force une cassure du traité après **2 non-payments**, en configurant `violation_threshold` bas, puis vérifie :


* `treaty == null`
* `arc.state` est `CONFLICT` ou `WAR`


>
> Hypothèse : `tick_tribute_if_any()` appelle `ArcStateMachine.maybe_break_treaty()` quand `violation_score` dépasse le seuil (comme dans le patch proposé).
>
>
>


---


## `tests/TributeTwoMissesBreakTreatyTest.gd`


```
extends Node
class\_name TributeTwoMissesBreakTreatyTest

func \_ready() -> void:
 \_test\_two\_non\_payments\_break\_treaty\_and\_escalate\_state()
 print("\n✅ TributeTwoMissesBreakTreatyTest: OK\n")
 get\_tree().quit()


func \_test\_two\_non\_payments\_break\_treaty\_and\_escalate\_state() -> void:
 var winner := &"A"
 var loser := &"B"

 # --- economies ---
 var economies := {}
 economies[winner] = FactionEconomy.new()
 economies[loser] = FactionEconomy.new()
 economies[winner].gold = 0
 economies[loser].gold = 0 # always non-payment

 # --- relations ---
 var relations := {}
 relations[winner] = {}
 relations[loser] = {}
 relations[winner][loser] = FactionRelationScore.new()
 relations[loser][winner] = FactionRelationScore.new()

 relations[winner][loser].trust = 40
 relations[winner][loser].tension = 20
 relations[winner][loser].grievance = 10

 relations[loser][winner].trust = 35
 relations[loser][winner].tension = 25
 relations[loser][winner].grievance = 15

 # --- arc + treaty ---
 var arc := ArcState.new()
 arc.state = &"TRUCE"

 var t := Treaty.new()
 t.type = &"TRUCE"
 t.start\_day = 1
 t.end\_day = 60
 t.cooldown\_after\_end\_days = 25
 t.clauses = Treaty.CLAUSE\_NO\_RAID | Treaty.CLAUSE\_NO\_SABOTAGE | Treaty.CLAUSE\_NO\_WAR | Treaty.CLAUSE\_OPEN\_TRADE
 t.violation\_score = 0.0
 t.violation\_threshold = 0.45 # LOW: 2 misses should break deterministically
 arc.treaty = t

 # tribute schedule: due day 7 then day 14
 arc.war\_terms = {
 "tribute\_active": true,
 "tribute\_winner": winner,
 "tribute\_loser": loser,
 "tribute\_gold\_per\_week": 50,
 "tribute\_weeks\_left": 2,
 "tribute\_next\_day": 7,
 "tribute\_missed\_payments": 0,
 "tribute\_last\_miss\_day": -999999
 }

 # --- notebook + spawn fn stub ---
 var notebook := ArcNotebook.new()
 var spawn\_calls := 0

 var spawn\_fn := func(w: StringName, l: StringName, day: int, tier: int) -> QuestInstance:
 spawn\_calls += 1
 return null

 # --- Miss #1 (day 7) ---
 ArcStateMachine.tick\_tribute\_if\_any(
 arc, 7,
 economies,
 relations,
 notebook,
 Callable(spawn\_fn)
 )

 \_assert(arc.treaty != null, "treaty should still exist after first miss (depending on threshold)")
 \_assert(spawn\_calls == 1, "spawn should be called on first miss")

# --- Miss #2 (day 14) => should break treaty ---

 ArcStateMachine.tick\_tribute\_if\_any(
 arc, 14,
 economies,
 relations,
 notebook,
 Callable(spawn\_fn)
 )

 \_assert(spawn\_calls >= 1, "spawn should have been called at least once (cooldown may block second)")
 \_assert(arc.treaty == null, "treaty should be broken after second miss crosses threshold")

 \_assert(
 arc.state == &"CONFLICT" or arc.state == &"WAR",
 "arc state should escalate to CONFLICT/WAR after treaty breaks, got %s" % String(arc.state)
 )

 \_assert(arc.lock\_until\_day >= 14, "lock\_until\_day should be applied after treaty break")


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


### Petit détail important


* Le test tolère que `spawn_fn` ne soit pas appelé au 2e miss si ton cooldown empêche le spam (`spawn_calls >= 1` et pas `==2`), mais la cassure du traité doit arriver quand même.


Si tu veux, je peux te donner une version où le **trigger\_action** de `maybe_break_treaty()` passe à `DECLARE_WAR` si tu veux que non-payment puisse *directement* déclencher `WAR` au lieu de `CONFLICT`.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 11](#toc-detail-ch11)
<a id="moi-77"></a>
**Moi 77:**
Ok, mais il faut que ca soit en fonction de l'historique des deux factions et de leur affinité/personnalité


**ChatGPT:**
Oui — **la cassure de traité (et surtout le choix CONFLICT vs WAR)** ne doit pas être “binaire fixe”. On peut la rendre **dépendante** :


* de l’**historique A↔B** (raids, sabotages, traités cassés, guerres passées, non-payments…)
* des **profils** (axes + personnalité : bellicisme/diplomatie/opportunisme/honneur…)
* des **métriques actuelles** (relation/trust/tension/grievance/weariness)
* et même du **contexte** (menace externe, fatigue du monde, etc.)


Voici un **mini patch propre** : on garde `maybe_break_treaty()` centralisée, mais on lui donne un **état cible calculé** par une fonction dédiée.


---


## 1) Nouvelle fonction : décider de l’escalade après non-payment


```
static func decide\_state\_on\_tribute\_default(
 winner\_id: StringName,
 loser\_id: StringName,
 day: int,
 arc\_state: ArcState,
 relations: Dictionary, # relations[X][Y] -> FactionRelationScore
 notebook: ArcNotebook,
 profiles: Dictionary, # profiles[faction] -> FactionProfile
 ctx: FactionWorldContext = null
) -> StringName:
 var w2l: FactionRelationScore = relations[winner\_id][loser\_id]
 var l2w: FactionRelationScore = relations[loser\_id][winner\_id]

 var tension := 0.5 * (w2l.tension + l2w.tension) / 100.0
 var griev := 0.5 * (w2l.grievance + l2w.grievance) / 100.0
 var wear := 0.5 * (w2l.weariness + l2w.weariness) / 100.0
 var rel := 0.5 * (w2l.relation + l2w.relation) / 100.0

 # heat (hostile récent)
 var h := notebook.get\_pair\_heat(winner\_id, loser\_id, day, 0.93)
 var hostile\_recent := 1.0 - exp(-0.35 * (float(h["hostile\_to\_other"]) + float(h["hostile\_from\_other"])))

# historique : compteurs (à brancher sur ton ArcNotebook/arcHistory)

 var pair\_key := StringName((String(winner\_id) <= String(loser\_id)) ? (String(winner\_id)+"|"+String(loser\_id)) : (String(loser\_id)+"|"+String(winner\_id)))
 var treaty\_breaks := float(notebook.get\_pair\_counter(pair\_key, &"treaty\_breaks", 0))

# à ajouter

 var wars := float(notebook.get\_pair\_counter(pair\_key, &"wars", 0))

# à ajouter

 var nonpay := float(notebook.get\_pair\_counter(pair\_key, &"tribute\_misses", 0))

# à ajouter

 var history\_factor := clampf(0.10*treaty\_breaks + 0.15*wars + 0.10*nonpay, 0.0, 0.6)

# profils

 var pw: FactionProfile = profiles.get(winner\_id, null)
 var pl: FactionProfile = profiles.get(loser\_id, null)

 var bell := pw.get\_personality(&"belligerence", 0.5) if pw else 0.5
 var diplo := pw.get\_personality(&"diplomacy", 0.5) if pw else 0.5
 var expa := pw.get\_personality(&"expansionism", 0.5) if pw else 0.5
 var honor := pw.get\_personality(&"honor", 0.5) if pw else 0.5

 # axes : divergence moyenne (0..1)
 var axis\_div := 0.0
 if pw and pl:
 var sum := 0.0
 var n := 0.0
 for k in pw.axis\_affinity.keys():
 if pl.axis\_affinity.has(k):
 sum += abs(float(pw.axis\_affinity[k]) - float(pl.axis\_affinity[k])) / 200.0
 n += 1.0
 axis\_div = (sum / max(1.0, n))

# contexte (optionnel)

 var ext\_threat := (ctx.external\_threat if ctx else 0.0)

# score d’escalade (0..1)

# + tension/grievance/hostile\_recent/history/axis\_div/bell/honor

 # - diplomatie/fatigue/menace externe (pousse vers trêve/coali plutôt que guerre)
 var score := 0.30*tension + 0.22*griev + 0.18*hostile\_recent + 0.12*axis\_div + history\_factor \
 + 0.12*bell + 0.06*honor - 0.18*diplo - 0.22*wear - 0.12*ext\_threat

 score = clampf(score, 0.0, 1.0)

# décision :

 # - guerre si score haut et relation déjà très basse
 # - sinon conflit (punitive / collect-by-force / raids limités)
 if score >= 0.75 and rel <= -0.35:
 # expansionniste => WAR plus souvent, sinon CONFLICT peut suffire
 return &"WAR" if expa >= 0.55 else &"CONFLICT"
 return &"CONFLICT"
```


👉 Remarque : `get_pair_counter()` est un mini ajout sur ton ArcNotebook (voir section 3).


---


## 2) Patch `maybe_break_treaty` : accepter un état cible


```
static func maybe\_break\_treaty(arc\_state: ArcState, day: int, desired\_state: StringName = &"") -> bool:
 var t: Treaty = arc\_state.treaty
 if t == null:
 return false
 if t.violation\_score < t.violation\_threshold:
 return false

 arc\_state.lock\_until\_day = max(arc\_state.lock\_until\_day, day + t.cooldown\_after\_end\_days)

# état choisi par la logique (sinon fallback)

 if desired\_state != &"":
 arc\_state.state = desired\_state
 else:
 arc\_state.state = &"CONFLICT"

 arc\_state.treaty = null
 return true
```


---


## 3) Mini ajout ArcNotebook : counters par paire


Tu as déjà ton historique; le plus simple est d’ajouter un petit store “metrics by pair” :


```
# ArcNotebook.gd

var pair\_counters: Dictionary = {} # pair\_key -> {counter\_name:StringName : int}

func inc\_pair\_counter(pair\_key: StringName, name: StringName, delta: int = 1) -> void:
 if not pair\_counters.has(pair\_key):
 pair\_counters[pair\_key] = {}
 pair\_counters[pair\_key][name] = int(pair\_counters[pair\_key].get(name, 0)) + delta

func get\_pair\_counter(pair\_key: StringName, name: StringName, default\_val: int = 0) -> int:
 if not pair\_counters.has(pair\_key):
 return default\_val
 return int(pair\_counters[pair\_key].get(name, default\_val))
```


À appeler :


* à chaque `non-payment` : `inc_pair_counter(pair_key, &"tribute_misses", 1)`
* quand un traité casse : `inc_pair_counter(pair_key, &"treaty_breaks", 1)`
* quand WAR démarre : `inc_pair_counter(pair_key, &"wars", 1)`


---


## 4) Intégration : dans `tick_tribute_if_any()` au moment de casser


Dans le bloc non-payment, juste avant `maybe_break_treaty()` :


```
# ... après arc\_state.treaty.violation\_score += ...

notebook.inc\_pair\_counter(pair\_key, &"tribute\_misses", 1)

var desired := ArcStateMachine.decide\_state\_on\_tribute\_default(
 winner, loser, day, arc\_state, relations, notebook, faction\_profiles, ctx
)

if ArcStateMachine.maybe\_break\_treaty(arc\_state, day, desired):
 notebook.inc\_pair\_counter(pair\_key, &"treaty\_breaks", 1)
 if desired == &"WAR":
 notebook.inc\_pair\_counter(pair\_key, &"wars", 1)
 return
```


---


## 5) Conséquence : WAR aim dépend aussi des profils/historique


Si ça bascule en WAR après défaut de tribut, tu peux forcer un aim cohérent :


* `war_aim = TRIBUTE` (enforcement) ou `PUNISH` (punitive war)
* et si `expa` haut + target faible : `SUBJUGATE`


Ex :


```
if arc\_state.state == &"WAR":
 arc\_state.war\_aim = &"TRIBUTE" if expa < 0.6 else &"SUBJUGATE"
```


---


### Pourquoi c’est mieux


* Une faction **diplomate/fatiguée** ne déclenchera pas une WAR pour 1 défaut de paiement.
* Une faction **honor+belligerence**, avec un lourd passif de guerre/traités cassés, escalade beaucoup plus facilement.
* Les **axes** rendent certaines paires “naturellement irréconciliables” (divergence haute) → plus de risques de WAR.


Si tu veux, je te donne une version “déterministe test-friendly” (où tu injectes un `params` pour fixer les poids/seuils) pour écrire un test qui prouve : *mêmes non-payments, mais profils différents => CONFLICT vs WAR*.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 11](#toc-detail-ch11)
<a id="moi-78"></a>
**Moi 78:**
Non ca suffit je pense

On passe sur :

• Knowledge/rumeurs (ça rend les offers à 3 factions incroyablement naturelles)


**ChatGPT:**
OK, passons à **Knowledge / rumeurs** en mode MVP “utile tout de suite” (et compatible avec ton ArcNotebook + offers à 3 factions).


L’objectif : **les factions ne réagissent pas aux faits**, mais à ce qu’elles **croient** (avec une **confiance**), et ces croyances peuvent être :


* vraies (témoins / preuves),
* fausses (propagande / biais),
* ou incomplètes (bruit, délais).


---


## 1) Modèle MVP


### Vérité (fact) vs croyance (belief)


* Le monde enregistre un **Fact** : “C a raid B à J6”.
* Chaque faction X obtient une **Belief** sur ce fact :

“Je pense que **A** a orchestré le raid” avec une **confidence**.


Ensuite :


* les décisions ArcManager (incident, escalade, third party, offers) utilisent **PerceivedHeat** (dérivé des beliefs),
* les quêtes “investigate / proof / propaganda” modifient les beliefs (et donc le futur).


---


## 2) Structures de données


### `KnowledgeEvent` (la vérité du monde)


```
class\_name KnowledgeEvent
extends RefCounted

var id: StringName
var day: int
var type: StringName # RAID/SABOTAGE/TRIBUTE\_MISS/TREATY\_BREACH/...
var true\_actor: StringName # qui a vraiment fait l’action
var true\_target: StringName
var severity: float = 1.0 # 0.5..2.0
var pair\_key: StringName # "A|B" (actor/target)
var meta: Dictionary = {} # poi\_id, arc\_id, etc.
```


### `BeliefEntry` (ce que X croit à propos d’un event)


```
class\_name BeliefEntry
extends RefCounted

var event\_id: StringName
var observer\_id: StringName # faction X qui croit
var claimed\_actor: StringName # qui X pense être l’acteur
var claimed\_target: StringName
var claim\_type: StringName # RAID/...
var confidence: float = 0.0 # 0..1
var source: StringName = &"RUMOR" # DIRECT/WITNESS/ALLY/RUMOR/PROPAGANDA
var bias\_tag: StringName = &"" # "anti\_magic", "anti\_orc", etc.
var last\_update\_day: int = 0
```


### `Rumor` (un “paquet” qui crée/booste des beliefs)


```
class\_name Rumor
extends RefCounted

var id: StringName
var day: int
var seed\_id: StringName # qui lance la rumeur (C, un broker, etc.)
var claim\_actor: StringName
var claim\_target: StringName
var claim\_type: StringName
var strength: float = 0.6 # force du message
var credibility: float = 0.5 # crédibilité perçue (source + réputation)
var malicious: bool = false
var related\_event\_id: StringName = &"" # si rumeur “sur” un fact
```


---


## 3) Le système : `FactionKnowledgeModel`


Tu as deux dictionnaires principaux :


```
# FactionKnowledgeModel.gd

var events\_by\_id: Dictionary[StringName, KnowledgeEvent] = {}
var beliefs\_by\_faction: Dictionary[StringName, Dictionary] = {} # X -> event\_id -> BeliefEntry

# agrégats rapides (pour ArcManager) :

var perceived\_hostile\_heat: Dictionary[StringName, Dictionary] = {}
# X -> other -> float (hostile “perçu”)

```


---


## 4) Comment une faction “perçoit” un fact


### A) Visibilité / délai / biais (MVP)


Une faction X apprend un fact avec une probabilité + une confidence initiale :


* **DIRECT** : si X est actor/target → confidence 0.9
* **ALLY** : si X est allié du target → 0.6
* **RUMOR** : sinon → 0.2..0.5 selon diplomatie/espionnage du monde


Puis on applique un **biais** selon :


* personnalité (paranoïa, diplomatie),
* axes (divergence → plus crédule aux rumeurs hostiles),
* historique (ArcNotebook : “A a déjà trahi”).


### B) Une formule simple


```
confidence = base
 + 0.25 * intel(observer)
 + 0.20 * paranoia(observer)
 + 0.15 * hostility\_bias(observer, claimed\_actor)
 - 0.25 * diplomacy(observer)
```


Clamp 0..1.


---


## 5) PerceivedHeat (pour casser l’escalade binaire)


ArcManager ne doit pas seulement regarder “hostile facts”, mais :


* “**B croit à 70% que A est derrière**”
* “C diffuse une version différente”
* “A peut chercher des preuves pour inocenter”


### Agrégat rapide (par paire, par observateur)


Pour une faction X et un autre Y :


```
perceived\_hostile\_heat[X][Y] =
 Σ over beliefs where claimed\_actor == Y and claim is hostile:
 confidence * severity * decay(day - event\_day)
```


**C’est ça** que tu utilises dans :


* `compute_arc_event_chance()`,
* `third party mediator/opportunist triggers`,
* “suspicion spillover” (mais au lieu d’un delta fixe, tu mets un delta proportionnel à la croyance).


---


## 6) Quêtes qui modifient les beliefs (le gameplay)

### Types d’offres “Knowledge”


1) **Investigate / Proof** (réduit la rumeur, augmente vérité)

2) **Counter-propaganda / Prove innocence** (baisse confidence sur claim faux)

3) **Fabricate evidence** (augmente confidence sur claim faux → escalade)

#### Context standard


```
"is\_knowledge\_offer": true
"related\_event\_id": event\_id
"rumor\_id": rumor\_id (optionnel)
"observer\_id": B (souvent)
"claimed\_actor": A
"true\_actor": C (optionnel si c’est caché au joueur)
"knowledge\_action": &"INVESTIGATE"|"PROVE\_INNOCENCE"|"FORGE\_EVIDENCE"
```


### Effet sur beliefs (MVP)


* LOYAL INVESTIGATE : `confidence -= 0.35` si claim faux, sinon `confidence += 0.25`
* TRAITOR FORGE : `confidence += 0.35` même si faux
* NEUTRAL : +-0.15


Et si confidence passe sous 0.2 : la rumeur “tombe”.

Si elle passe au-dessus de 0.8 : “croyance forte” → peut déclencher WAR.


---


## 7) Intégration dans tes deltas relations / arc states


### Règle clé : **les deltas relationnels viennent du “perçu”**


Au lieu de :


>
> “B→A tension +3, grievance +2”
>
>
>


Tu fais :


```
delta\_tension = round(3.0 * belief.confidence)
delta\_griev = round(2.0 * belief.confidence)
```


Et si plus tard une quête prouve l’inverse :


* tu réduis la confidence
* et tu appliques un petit delta inverse (pas forcément symétrique) :
	+ B→A tension -2, grievance -1
	+ B→source trust -3 (si la source était une rumeur/propagande)


---


## 8) Le rôle “3 factions” devient naturel


Exemple canonique :


* Fact : **C raid B**
* Rumor : **A hired C** (seed: C ou un broker)
* Belief chez B : “A est derrière” (confidence 0.6)
* Résultats :
	+ B s’énerve contre A (sans preuve)
	+ Offer à 3 factions :
		- **Investigate** (B demande au joueur)
		- **Prove innocence** (A demande au joueur)
		- **Forge evidence** (C propose au joueur)


Ça évite l’escalade binaire “faits → vengeance” : tu as **doute / manipulation / arbitrage**.


---


## 9) MVP “low cost” pour toi (recommandé)


Pour ne pas exploser la complexité :


* ne stocke pas 10 000 beliefs : garde seulement les **N derniers events importants par paire** (ex N=30).
* agrège en continu `perceived_hostile_heat[X][Y]` (cache), recalcul léger 1 fois/jour.
* utilise ArcNotebook pour l’historique “macro” (counters), KnowledgeModel pour le “micro” (rumeurs récentes).


---


Si tu veux, prochaine brique logique : je te donne une implémentation compacte des 3 fonctions essentielles :

1) `register_fact(event)`

2) `inject_rumor(rumor)`

3) `apply_knowledge_resolution(context, choice)` (qui modifie beliefs + relations)


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 12](#toc-detail-ch12)
<a id="moi-79"></a>
**Moi 79:**
prochaine brique logique : je te donne une implémentation compacte des 3 fonctions essentielles :


register\_fact(event)


inject\_rumor(rumor)


apply\_knowledge\_resolution(context, choice) (qui modifie beliefs + relations)


**ChatGPT:**
Voici une implémentation **compacte** (MVP) des 3 fonctions, sous forme d’un script `FactionKnowledgeModel.gd`.

Elle est volontairement “light” : pas de dépendances lourdes, et elle s’intègre à tes `relations` existantes + ton ArcNotebook si tu veux.


>
> Hypothèses minimales :
>
>
> * `relations[f1][f2]` est un `FactionRelationScore` avec `trust/tension/grievance/relation`.
> * `choice` ∈ `&"LOYAL"|"NEUTRAL"|"TRAITOR"`.
> * Le `context` de quête contient au moins `observer_id`, `claimed_actor`, `claimed_target`, `related_event_id` (optionnel), `knowledge_action`.
>
>
>


---


## `FactionKnowledgeModel.gd`


```
class\_name FactionKnowledgeModel
extends RefCounted

# --- storage ---

var events\_by\_id: Dictionary = {} # event\_id -> KnowledgeEvent(Dictionary)
var beliefs\_by\_faction: Dictionary = {} # observer -> (event\_id -> BeliefEntry(Dictionary))
var rumors\_by\_id: Dictionary = {} # rumor\_id -> Rumor(Dictionary)

# config

var decay\_per\_day: float = 0.93
var k\_norm: float = 0.35 # for softcap if needed

# ------------------------------------------------------------

# 1) register\_fact(event)

# ------------------------------------------------------------

func register\_fact(event: Dictionary) -> void:
 # Expected keys:
 # id, day, type, true\_actor, true\_target, severity (optional), pair\_key (optional), meta(optional)
 var eid: StringName = StringName(event.get("id", &""))
 if eid == &"":
 eid = StringName("evt\_%s\_%s" % [str(event.get("day", 0)), str(randi())])
 event["id"] = eid

 if not event.has("severity"):
 event["severity"] = 1.0

 if not event.has("pair\_key"):
 var a := String(event.get("true\_actor", ""))
 var b := String(event.get("true\_target", ""))
 event["pair\_key"] = StringName((a <= b) ? (a + "|" + b) : (b + "|" + a))

 events\_by\_id[eid] = event


# ------------------------------------------------------------

# 2) inject\_rumor(rumor)

# ------------------------------------------------------------

func inject\_rumor(rumor: Dictionary, observers: Array, profiles: Dictionary = {}) -> void:
 # Expected keys:
 # id, day, seed\_id, claim\_actor, claim\_target, claim\_type, strength(0..1), credibility(0..1),
 # malicious(bool), related\_event\_id(optional)
 var rid: StringName = StringName(rumor.get("id", &""))
 if rid == &"":
 rid = StringName("rum\_%s\_%s" % [str(rumor.get("day", 0)), str(randi())])
 rumor["id"] = rid

 rumor["strength"] = clampf(float(rumor.get("strength", 0.6)), 0.0, 1.0)
 rumor["credibility"] = clampf(float(rumor.get("credibility", 0.5)), 0.0, 1.0)
 rumors\_by\_id[rid] = rumor

 var day := int(rumor.get("day", 0))
 var claim\_actor: StringName = StringName(rumor.get("claim\_actor", &""))
 var claim\_target: StringName = StringName(rumor.get("claim\_target", &""))
 var claim\_type: StringName = StringName(rumor.get("claim\_type", &""))

 for obs\_id in observers:
 var observer: StringName = StringName(obs\_id)
 \_ensure\_observer(observer)

# base confidence from rumor strength + credibility

 var base := 0.10 + 0.55 * float(rumor["strength"]) * float(rumor["credibility"])

# bias from personality (optional)

# keys expected in profile personality dict: paranoia, diplomacy, intel

 var paranoia := \_get\_personality(profiles, observer, &"paranoia", 0.5)
 var diplomacy := \_get\_personality(profiles, observer, &"diplomacy", 0.5)
 var intel := \_get\_personality(profiles, observer, &"intel", 0.5)

 var conf := base + 0.20*intel + 0.20*paranoia - 0.20*diplomacy
 conf = clampf(conf, 0.05, 0.95)

# Each rumor can either attach to a real event or live alone

 var event\_id: StringName = StringName(rumor.get("related\_event\_id", &""))
 if event\_id == &"":
 # create synthetic event id for belief tracking
 event\_id = StringName("syn\_%s\_%s" % [str(day), String(rid)])
 if not events\_by\_id.has(event\_id):
 events\_by\_id[event\_id] = {
 "id": event\_id,
 "day": day,
 "type": claim\_type,
 "true\_actor": &"", # unknown/none
 "true\_target": claim\_target,
 "severity": 1.0,
 "pair\_key": StringName((String(claim\_actor) <= String(claim\_target)) ? (String(claim\_actor)+"|"+String(claim\_target)) : (String(claim\_target)+"|"+String(claim\_actor))),
 "meta": {"rumor\_only": true, "rumor\_id": rid}
 }

 # write belief
 var b := {
 "event\_id": event\_id,
 "observer\_id": observer,
 "claimed\_actor": claim\_actor,
 "claimed\_target": claim\_target,
 "claim\_type": claim\_type,
 "confidence": conf,
 "source": &"RUMOR",
 "bias\_tag": StringName(rumor.get("bias\_tag", &"")),
 "last\_update\_day": day,
 "rumor\_id": rid
 }
 beliefs\_by\_faction[observer][event\_id] = b


# ------------------------------------------------------------

# 3) apply\_knowledge\_resolution(context, choice)

# ------------------------------------------------------------

func apply\_knowledge\_resolution(
 context: Dictionary,
 choice: StringName,
 relations: Dictionary,
 profiles: Dictionary = {},
 day: int = -1
) -> void:
 # context expected:
 # observer\_id, claimed\_actor, claimed\_target, knowledge\_action
 # related\_event\_id optional, rumor\_id optional
 var observer: StringName = StringName(context.get("observer\_id", &""))
 var claimed\_actor: StringName = StringName(context.get("claimed\_actor", &""))
 var claimed\_target: StringName = StringName(context.get("claimed\_target", &""))
 var action: StringName = StringName(context.get("knowledge\_action", &"INVESTIGATE"))
 var eid: StringName = StringName(context.get("related\_event\_id", &""))

 if day < 0:
 day = int(context.get("day", 0))

 \_ensure\_observer(observer)

# ensure belief exists (if quest created from rumor, we should have it; but be safe)

 if eid == &"":
 # try from rumor\_id
 var rid: StringName = StringName(context.get("rumor\_id", &""))
 if rid != &"" and rumors\_by\_id.has(rid):
 eid = StringName(rumors\_by\_id[rid].get("related\_event\_id", &""))
 if eid == &"":
 # fallback synthetic
 eid = StringName("syn\_res\_%s\_%s" % [str(day), str(randi())])
 events\_by\_id[eid] = {"id": eid, "day": day, "type": &"", "true\_actor": &"", "true\_target": claimed\_target, "severity": 1.0}

 var belief := beliefs\_by\_faction[observer].get(eid, null)
 if belief == null:
 belief = {
 "event\_id": eid,
 "observer\_id": observer,
 "claimed\_actor": claimed\_actor,
 "claimed\_target": claimed\_target,
 "claim\_type": StringName(context.get("claim\_type", &"")),
 "confidence": 0.35,
 "source": &"RUMOR",
 "bias\_tag": &"",
 "last\_update\_day": day
 }
 beliefs\_by\_faction[observer][eid] = belief

 # determine if claim matches truth (if known)
 var ev: Dictionary = events\_by\_id.get(eid, {})
 var true\_actor: StringName = StringName(ev.get("true\_actor", &""))
 var truth\_known := (true\_actor != &"")
 var claim\_is\_true := truth\_known and (true\_actor == claimed\_actor)

# delta confidence based on knowledge\_action + choice

 var dconf := 0.0
 match action:
 &"INVESTIGATE":
 if choice == &"LOYAL": dconf = +0.25 if claim\_is\_true else -0.35
 elif choice == &"NEUTRAL":dconf = +0.10 if claim\_is\_true else -0.15
 else: dconf = +0.35 # forge/lie: push confidence upward
 &"PROVE\_INNOCENCE":
 # target is "claimed\_actor is innocent"
 # so we reduce confidence in the hostile claim
 if choice == &"LOYAL": dconf = -0.40
 elif choice == &"NEUTRAL":dconf = -0.18
 else: dconf = +0.20 # sabotage defense
 &"FORGE\_EVIDENCE":
 if choice == &"LOYAL": dconf = +0.35
 elif choice == &"NEUTRAL":dconf = +0.15
 else: dconf = +0.45
 \_:
 dconf = -0.15 if choice == &"LOYAL" else 0.0

 # apply personality modulation (optional): paranoia amplifies, diplomacy dampens
 var paranoia := \_get\_personality(profiles, observer, &"paranoia", 0.5)
 var diplomacy := \_get\_personality(profiles, observer, &"diplomacy", 0.5)
 var mult := clampf(1.0 + 0.25*(paranoia - 0.5) - 0.25*(diplomacy - 0.5), 0.75, 1.25)

 var old\_conf := float(belief["confidence"])
 var new\_conf := clampf(old\_conf + dconf*mult, 0.0, 1.0)
 belief["confidence"] = new\_conf
 belief["last\_update\_day"] = day
 beliefs\_by\_faction[observer][eid] = belief

 # Apply relationship deltas based on perceived belief change (asymmetric: observer -> claimed\_actor)
 if claimed\_actor != &"" and observer != &"" and relations.has(observer) and relations[observer].has(claimed\_actor):
 var r: FactionRelationScore = relations[observer][claimed\_actor]

 # hostile claim: higher confidence => higher tension/grievance and lower trust/relation
 # We use delta\_conf to determine direction of change.
 var delta\_conf := new\_conf - old\_conf
 var sev := float(ev.get("severity", 1.0))
 var scale := 10.0 * sev

 # if we're increasing confidence in hostile claim => worsen relation
 # if decreasing confidence => ease relation a bit
 r.tension = int(clampi(r.tension + int(round(+3.0 * delta\_conf * scale)), 0, 100))
 r.grievance = int(clampi(r.grievance + int(round(+2.0 * delta\_conf * scale)), 0, 100))
 r.trust = int(clampi(r.trust - int(round(+2.0 * delta\_conf * scale)), 0, 100))
 r.relation = int(clampi(r.relation - int(round(+2.0 * delta\_conf * scale)), -100, 100))

# If we strongly debunked a rumor: small bonus

 if old\_conf >= 0.6 and new\_conf <= 0.25:
 r.tension = int(clampi(r.tension - 3, 0, 100))
 r.trust = int(clampi(r.trust + 2, 0, 100))

# Optional: if source is propaganda and was debunked, reduce trust in seed\_id (not implemented here)

# ------------------------------------------------------------

# Helpers

# ------------------------------------------------------------

func \_ensure\_observer(observer: StringName) -> void:
 if not beliefs\_by\_faction.has(observer):
 beliefs\_by\_faction[observer] = {}

func \_get\_personality(profiles: Dictionary, faction\_id: StringName, key: StringName, default\_val: float) -> float:
 var p = profiles.get(faction\_id, null)
 if p == null:
 return default\_val
 # supports either Dictionary profiles, or FactionProfile with get\_personality()
 if p is Dictionary:
 var d: Dictionary = p.get("personality", {})
 return float(d.get(key, default\_val))
 if p.has\_method("get\_personality"):
 return float(p.get\_personality(key, default\_val))
 return default\_val
```


---


## Notes d’intégration (très pratiques)

### A) Comment alimenter `register_fact`


Quand un arc event “réel” arrive (raid/sabotage/tribute miss), tu appelles :


```
knowledge.register\_fact({
 "id": &"evt\_123",
 "day": day,
 "type": ArcDecisionUtil.ARC\_RAID,
 "true\_actor": attacker\_id,
 "true\_target": defender\_id,
 "severity": 1.0,
 "meta": {"arc\_id": arc\_id}
})
```


### B) Comment injecter une rumeur (tierce partie / propagande)


```
knowledge.inject\_rumor({
 "day": day,
 "seed\_id": C,
 "claim\_actor": A, # "A est derrière"
 "claim\_target": B,
 "claim\_type": ArcDecisionUtil.ARC\_RAID,
 "strength": 0.7,
 "credibility": 0.55,
 "malicious": true,
 "related\_event\_id": &"evt\_123"
}, observers\_array, faction\_profiles)
```


### C) Comment appliquer une résolution de quête “knowledge”


Dans `QuestManager.resolve_quest` si `context.is_knowledge_offer` :


```
knowledge.apply\_knowledge\_resolution(inst.context, choice, relations, faction\_profiles, world\_day)
```


---


Si tu veux, prochaine brique logique : une fonction `get_perceived_heat(observer, other, day)` + un mini test qui prouve que **2 rumeurs + 1 debunk** font chuter la “heat perçue” et empêchent une escalade A↔B.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 12](#toc-detail-ch12)
<a id="moi-80"></a>
**Moi 80:**
prochaine brique logique : une fonction get\_perceived\_heat(observer, other, day) + un mini test qui prouve que 2 rumeurs + 1 debunk font chuter la “heat perçue” et empêchent une escalade A↔B.


**ChatGPT:**
Voici la brique **MVP** : `get_perceived_heat(observer, other, day)` + un **mini test** démontrant que **2 rumeurs** font monter la heat perçue, puis **1 debunk** la fait chuter **sous un seuil**, ce qui “empêche l’escalade” (au sens : ArcManager n’aurait plus de raison de déclencher un incident).


---


## 1) Patch `FactionKnowledgeModel.gd` : `get_perceived_heat()`


Ajoute ça à ton `FactionKnowledgeModel.gd` :


```
# Types considérés comme hostiles (ajoute/retire selon ton jeu)

const HOSTILE\_TYPES := {
 &"RAID": true,
 &"SABOTAGE": true,
 &"DECLARE\_WAR": true,
 &"war.capture\_poi": true,
 &"war.collect\_tribute\_by\_force": true,
}

func get\_perceived\_heat(observer: StringName, other: StringName, day: int) -> float:
 # Retourne un score 0..100 : "à quel point observer pense que other est hostile (récemment)"
 if not beliefs\_by\_faction.has(observer):
 return 0.0

 var sum := 0.0
 for eid in beliefs\_by\_faction[observer].keys():
 var b: Dictionary = beliefs\_by\_faction[observer][eid]
 if StringName(b.get("claimed\_actor", &"")) != other:
 continue

 var ctype: StringName = StringName(b.get("claim\_type", &""))
 if not HOSTILE\_TYPES.has(ctype):
 continue

 var conf := clampf(float(b.get("confidence", 0.0)), 0.0, 1.0)

 var ev: Dictionary = events\_by\_id.get(StringName(b.get("event\_id", eid)), {})
 var ev\_day := int(ev.get("day", int(b.get("last\_update\_day", day))))
 var age := max(0, day - ev\_day)

 var sev := float(ev.get("severity", 1.0))
 var decay := pow(decay\_per\_day, float(age))

 sum += conf * sev * decay

 # Saturation douce -> 0..100 (évite divergence)
 return 100.0 * (1.0 - exp(-sum * 0.9))
```


### (Optionnel mais recommandé) : faire “stacker” 2 rumeurs sur le même event


Sinon ta 2e rumeur écrase la 1ère. Dans `inject_rumor()`, remplace l’affectation finale par un merge :


```
var existing := beliefs\_by\_faction[observer].get(event\_id, null)
if existing != null:
 var oldc := float(existing.get("confidence", 0.0))

# noisy-OR : deux rumeurs indépendantes renforcent la croyance

 var merged := 1.0 - (1.0 - oldc) * (1.0 - conf)
 existing["confidence"] = clampf(merged, 0.0, 1.0)
 existing["last\_update\_day"] = day
 existing["source"] = &"RUMOR"
 beliefs\_by\_faction[observer][event\_id] = existing
else:
 beliefs\_by\_faction[observer][event\_id] = b
```


---


## 2) Mini test : 2 rumeurs + 1 debunk


### `tests/KnowledgeRumorDebunkHeatTest.gd`


```
extends Node
class\_name KnowledgeRumorDebunkHeatTest

func \_ready() -> void:
 \_test\_two\_rumors\_then\_debunk\_reduces\_heat\_below\_threshold()
 print("\n✅ KnowledgeRumorDebunkHeatTest: OK\n")
 get\_tree().quit()


func \_test\_two\_rumors\_then\_debunk\_reduces\_heat\_below\_threshold() -> void:
 var knowledge := FactionKnowledgeModel.new()

 var A := &"A"
 var B := &"B"
 var C := &"C"

 # Profiles (minimum) : B est un peu parano et pas trop diplomate => croit plus vite aux rumeurs
 var profiles := {
 B: {"personality": {&"paranoia": 0.7, &"diplomacy": 0.3, &"intel": 0.5}}
 }

 # Relations (optionnel, mais apply\_knowledge\_resolution peut les modifier)
 var relations := {}
 relations[B] = {}
 relations[B][A] = FactionRelationScore.new()
 relations[B][A].trust = 40
 relations[B][A].tension = 10
 relations[B][A].grievance = 5
 relations[B][A].relation = 0

 # 1) Fact : le vrai raid est C -> B (jour 1)
 knowledge.register\_fact({
 "id": &"evt\_1",
 "day": 1,
 "type": &"RAID",
 "true\_actor": C,
 "true\_target": B,
 "severity": 1.0
 })

# 2) Rumor #1 : "A a raid B" (jour 2) -> observateur = B

 knowledge.inject\_rumor({
 "id": &"rum\_1",
 "day": 2,
 "seed\_id": C,
 "claim\_actor": A,
 "claim\_target": B,
 "claim\_type": &"RAID",
 "strength": 0.7,
 "credibility": 0.55,
 "malicious": true,
 "related\_event\_id": &"evt\_1"
 }, [B], profiles)

 var heat\_after\_1 := knowledge.get\_perceived\_heat(B, A, 2)

# 3) Rumor #2 : même claim (jour 3) -> renforce la croyance

 knowledge.inject\_rumor({
 "id": &"rum\_2",
 "day": 3,
 "seed\_id": &"BROKER",
 "claim\_actor": A,
 "claim\_target": B,
 "claim\_type": &"RAID",
 "strength": 0.65,
 "credibility": 0.55,
 "malicious": true,
 "related\_event\_id": &"evt\_1"
 }, [B], profiles)

 var heat\_after\_2 := knowledge.get\_perceived\_heat(B, A, 3)

 \_assert(heat\_after\_2 > heat\_after\_1, "heat should increase after 2nd rumor (%.1f -> %.1f)" % [heat\_after\_1, heat\_after\_2])

# Seuil “ArcManager déclencherait un incident”

 var INCIDENT\_THRESHOLD := 25.0
 \_assert(heat\_after\_2 >= INCIDENT\_THRESHOLD, "after 2 rumors, heat should be high enough to trigger incident (heat=%.1f)" % heat\_after\_2)

# 4) Debunk via INVESTIGATE LOYAL (jour 4) : comme true\_actor=C, claim(A) est faux => confidence baisse

 knowledge.apply\_knowledge\_resolution({
 "observer\_id": B,
 "claimed\_actor": A,
 "claimed\_target": B,
 "claim\_type": &"RAID",
 "knowledge\_action": &"INVESTIGATE",
 "related\_event\_id": &"evt\_1",
 "day": 4
 }, &"LOYAL", relations, profiles, 4)

 var heat\_after\_debunk := knowledge.get\_perceived\_heat(B, A, 4)

 \_assert(heat\_after\_debunk < heat\_after\_2, "heat should drop after debunk (%.1f -> %.1f)" % [heat\_after\_2, heat\_after\_debunk])
 \_assert(heat\_after\_debunk < INCIDENT\_THRESHOLD, "debunk should drop heat below incident threshold (heat=%.1f)" % heat\_after\_debunk)

# Donc : ArcManager/compute\_arc\_event\_chance, basé sur perceived\_heat, ne déclenche plus “naturellement” l’escalade.


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


### Intégration côté ArcManager (1 ligne utile)


À la place de “heat hostile factuel”, tu utilises :


* `heat = knowledge.get_perceived_heat(observer=B, other=A, day)`

et tu branches ça dans `compute_arc_event_chance()` ou `compute_priority_targets()`.


Si tu veux, prochaine brique logique : un mini mapping “rumeur → offers” (PROVE INNOCENCE / INVESTIGATE / FORGE EVIDENCE) basé sur `heat` et `confidence` pour générer automatiquement les quêtes à 3 factions.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 12](#toc-detail-ch12)
<a id="moi-81"></a>
**Moi 81:**
prochaine brique logique : un mini mapping “rumeur → offers” (PROVE INNOCENCE / INVESTIGATE / FORGE EVIDENCE) basé sur heat et confidence pour générer automatiquement les quêtes à 3 factions


**ChatGPT:**
Voici un **mini mapping “rumeur → offers”** qui génère automatiquement des quêtes **à 3 factions** (victime/observateur ↔ bouc-émissaire ↔ source/tiers), basé sur **heat** et **confidence**.


L’idée : à partir d’une rumeur (ou d’un belief), tu spawns un petit “bundle” :


* **INVESTIGATE** (B veut la vérité)
* **PROVE\_INNOCENCE** (A veut se blanchir)
* **FORGE\_EVIDENCE** (C veut faire condamner A)


---


# 1) Règles de décision (heat + confidence)

### Seuils (V1)


* `heat < 15` : rien (trop faible)
* `15 ≤ heat < 25` : 1 offer max (investigate OU prove innocence)
* `25 ≤ heat < 40` : 1–2 offers (investigate + prove innocence)
* `heat ≥ 40` : 2–3 offers (ajoute forge si possible)

### Conditions par action


* **INVESTIGATE** : si `conf ≥ 0.35` et `heat ≥ 15`
* **PROVE\_INNOCENCE** : si `conf ≥ 0.45` et `heat ≥ 25`
* **FORGE\_EVIDENCE** : si rumeur malveillante *et* `conf ≤ 0.85` *et* `heat ≥ 30`

(sinon c’est inutile : si la croyance est déjà ~max, “forcer” n’apporte rien)

### Tier + deadline (V1)


* `tier = clamp(1 + floor(heat/20) + (conf>0.6?1:0), 1..5)`
* `deadline_days = (heat >= 40 ? 4 : heat >= 25 ? 6 : 8)`


---


# 2) Mapping action → familles de quêtes (templates)


V1 simple (3 variantes par action) :


```
const KNOWLEDGE\_TEMPLATES := {
 &"INVESTIGATE": [
 &"knowledge.investigate.stealth", # infiltrer / récupérer des preuves
 &"knowledge.investigate.diplomacy", # interroger / convaincre témoins
 &"knowledge.investigate.retrieve", # récupérer un objet de preuve
 ],
 &"PROVE\_INNOCENCE": [
 &"knowledge.innocence.diplomacy", # audience / plaidoirie / négociation
 &"knowledge.innocence.escort", # escorter un émissaire / témoin
 &"knowledge.innocence.retrieve", # récupérer contre-preuve
 ],
 &"FORGE\_EVIDENCE": [
 &"knowledge.forge.stealth", # falsifier sceaux / lettres
 &"knowledge.forge.retrieve", # voler un artefact “incriminant”
 &"knowledge.forge.sabotage", # mise en scène / sabotage cadré
 ],
}
```


>
> Ces ids peuvent être des “quest types” que ton `QuestGenerator` comprend, ou des templates runtime via ton `_build_template_fallback()`.
>
>
>


---


# 3) `KnowledgeOfferFactory.spawn_offers_for_rumor(...)` (compatible QuestPool)


```
# KnowledgeOfferFactory.gd

class\_name KnowledgeOfferFactory
extends RefCounted

const HEAT\_LOW := 15.0
const HEAT\_MED := 25.0
const HEAT\_HIGH := 40.0

static func spawn\_offers\_for\_rumor(
 knowledge: FactionKnowledgeModel,
 rumor: Dictionary,
 observers: Array, # factions qui "reçoivent" la rumeur (ex: [B] ou alliés)
 day: int,
 quest\_pool, # ton QuestPool (ou retourne un Array[QuestInstance])
 arc\_notebook: ArcNotebook,
 profiles: Dictionary = {},
 params: Dictionary = {}
) -> Array:
 var out: Array = []

 var rid: StringName = StringName(rumor.get("id", &""))
 var claimed\_actor: StringName = StringName(rumor.get("claim\_actor", &""))
 var claimed\_target: StringName = StringName(rumor.get("claim\_target", &""))
 var claim\_type: StringName = StringName(rumor.get("claim\_type", &"RAID"))
 var seed\_id: StringName = StringName(rumor.get("seed\_id", &""))
 var malicious := bool(rumor.get("malicious", false))
 var event\_id: StringName = StringName(rumor.get("related\_event\_id", &""))

# cooldown anti-spam par rumeur/pair

 var key := StringName("know|" + String(rid))
 var cd := int(params.get("knowledge\_offer\_cooldown\_days", 5))
 if arc\_notebook.has\_method("can\_spawn\_knowledge\_offer") and not arc\_notebook.can\_spawn\_knowledge\_offer(key, day, cd):
 return out

 var max\_offers := int(params.get("knowledge\_bundle\_max", 3))

 for obs in observers:
 var observer: StringName = StringName(obs)

 var heat := knowledge.get\_perceived\_heat(observer, claimed\_actor, day)
 if heat < HEAT\_LOW:
 continue

 # récupère la confidence du belief associé (si dispo)
 var conf := \_get\_confidence(knowledge, observer, event\_id, claimed\_actor, claim\_type)

 var deadline\_days := (heat >= HEAT\_HIGH) ? 4 : (heat >= HEAT\_MED) ? 6 : 8
 var tier := clampi(1 + int(floor(heat / 20.0)) + (conf >= 0.60 ? 1 : 0), 1, 5)

# 1) INVESTIGATE (giver = observer/victim)

 if conf >= 0.35 and heat >= HEAT\_LOW and out.size() < max\_offers:
 out.append(\_spawn\_knowledge\_offer(
 &"INVESTIGATE",
 observer, # giver
 claimed\_actor, # antagonist “suspect”
 seed\_id, # third party (source)
 observer, claimed\_actor, claimed\_target,
 event\_id, rid,
 heat, conf, tier, deadline\_days, claim\_type
 ))

# 2) PROVE\_INNOCENCE (giver = claimed\_actor, influence observer=B)

 if conf >= 0.45 and heat >= HEAT\_MED and out.size() < max\_offers:
 out.append(\_spawn\_knowledge\_offer(
 &"PROVE\_INNOCENCE",
 claimed\_actor, # giver
 observer, # antagonist “accusateur”
 seed\_id,
 observer, claimed\_actor, claimed\_target,
 event\_id, rid,
 heat, conf, tier, deadline\_days, claim\_type
 ))

# 3) FORGE\_EVIDENCE (giver = seed/tiers, antagonist = claimed\_actor)

# uniquement si ça a un intérêt (pas déjà conviction maximale)

 if malicious and heat >= 30.0 and conf <= 0.85 and out.size() < max\_offers:
 out.append(\_spawn\_knowledge\_offer(
 &"FORGE\_EVIDENCE",
 seed\_id, # giver (propagandiste / opportuniste / vraie faction C)
 claimed\_actor, # antagonist (celui qu'on incrimine)
 observer, # third party = la cible à convaincre
 observer, claimed\_actor, claimed\_target,
 event\_id, rid,
 heat, conf, tier, deadline\_days, claim\_type
 ))

# filtre null + ajout au pool

 var final: Array = []
 for inst in out:
 if inst != null:
 final.append(inst)
 if quest\_pool != null and quest\_pool.has\_method("try\_add\_offer"):
 quest\_pool.try\_add\_offer(inst)

# mark cooldown

 if arc\_notebook.has\_method("mark\_knowledge\_offer\_spawned"):
 arc\_notebook.mark\_knowledge\_offer\_spawned(key, day)

 return final


static func \_spawn\_knowledge\_offer(
 knowledge\_action: StringName,
 giver: StringName,
 antagonist: StringName,
 third\_party: StringName,
 observer\_id: StringName,
 claimed\_actor: StringName,
 claimed\_target: StringName,
 event\_id: StringName,
 rumor\_id: StringName,
 heat: float,
 conf: float,
 tier: int,
 deadline\_days: int,
 claim\_type: StringName
) -> QuestInstance:
 if giver == &"" or claimed\_actor == &"" or claimed\_target == &"":
 return null

 # Choix d’un “quest type/template id” (au hasard simple)
 var options: Array = KNOWLEDGE\_TEMPLATES.get(knowledge\_action, [])
 if options.is\_empty():
 return null
 var qtype: StringName = options[randi() % options.size()]

 # Ici tu peux appeler ton ArcOfferFactory / QuestGenerator. MVP: template runtime minimal.
 var template := ArcOfferFactory.\_build\_template\_fallback(String(qtype), tier, deadline\_days)

 var ctx := {
 "is\_knowledge\_offer": true,
 "knowledge\_action": knowledge\_action,
 "observer\_id": observer\_id,
 "claimed\_actor": claimed\_actor,
 "claimed\_target": claimed\_target,
 "claim\_type": claim\_type,

 "related\_event\_id": event\_id,
 "rumor\_id": rumor\_id,

 "giver\_faction\_id": giver,
 "antagonist\_faction\_id": antagonist,
 "third\_party\_id": third\_party,

 "stake": {"heat": heat, "confidence": conf, "tier": tier},
 "expires\_in\_days": deadline\_days,

 # profil de résolution “knowledge” (tu peux le router vers apply\_knowledge\_resolution)
 "resolution\_profile\_id": &"knowledge\_default"
 }

 var inst := QuestInstance.new(template, ctx)
 inst.status = "AVAILABLE"
 inst.started\_on\_day = int(ctx.get("day", 0))
 inst.expires\_on\_day = inst.started\_on\_day + deadline\_days
 return inst


static func \_get\_confidence(knowledge: FactionKnowledgeModel, observer: StringName, event\_id: StringName, claimed\_actor: StringName, claim\_type: StringName) -> float:
 # cherche un belief précis, sinon fallback
 if knowledge.beliefs\_by\_faction.has(observer):
 if knowledge.beliefs\_by\_faction[observer].has(event\_id):
 var b: Dictionary = knowledge.beliefs\_by\_faction[observer][event\_id]
 if StringName(b.get("claimed\_actor", &"")) == claimed\_actor and StringName(b.get("claim\_type", &"")) == claim\_type:
 return clampf(float(b.get("confidence", 0.35)), 0.0, 1.0)
 return 0.35
```


### Deux micro-ajouts ArcNotebook (cooldown knowledge)


```
# ArcNotebook.gd (mini)

var knowledge\_spawn\_cooldowns: Dictionary = {} # key -> last\_day

func can\_spawn\_knowledge\_offer(key: StringName, day: int, cooldown\_days: int) -> bool:
 var last := int(knowledge\_spawn\_cooldowns.get(key, -999999))
 return (day - last) >= cooldown\_days

func mark\_knowledge\_offer\_spawned(key: StringName, day: int) -> void:
 knowledge\_spawn\_cooldowns[key] = day
```


---


# 4) Comment ça donne des “quêtes à 3 factions”


Exemple C fait un raid opportuniste sur B, mais lance une rumeur “A est derrière” :


* **INVESTIGATE** : giver=B, antagonist=A, third\_party=C (source)
* **PROVE\_INNOCENCE** : giver=A, antagonist=B, third\_party=C
* **FORGE\_EVIDENCE** : giver=C, antagonist=A, third\_party=B (cible à convaincre)


Chaque quête a un `context` standard (`observer_id`, `claimed_actor`, `rumor_id`, etc.), ce qui permet ensuite :


* `QuestManager.resolve_quest()` → `knowledge.apply_knowledge_resolution(context, choice, relations, profiles, day)`


---


Si tu veux, prochaine brique logique : un test “bundle” qui vérifie qu’à `heat>=40` + `malicious=true`, on spawne bien 2–3 offers (avec giver/antagonist/third\_party corrects), et qu’un debunk fait retomber `heat` et réduit automatiquement le bundle les jours suivants.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 12](#toc-detail-ch12)
<a id="moi-82"></a>
**Moi 82:**
prochaine brique logique : un test “bundle” qui vérifie qu’à heat>=40 + malicious=true, on spawne bien 2–3 offers (avec giver/antagonist/third\_party corrects), et qu’un debunk fait retomber heat et réduit automatiquement le bundle les jours suivants.


**ChatGPT:**
Voici un **test “bundle”** (style identique aux précédents) qui vérifie :


1) avec `heat >= 40` + `malicious=true`, on spawn **2–3 offers**

2) les offers ont les bons rôles **giver/antagonist/third\_party** selon `knowledge_action`

3) après un **debunk**, `heat` retombe et **le bundle est réduit** les jours suivants (ex: 0–1 offer, et plus de FORGE)


---


## `tests/KnowledgeBundleSpawnAndDebunkTest.gd`


```
extends Node
class\_name KnowledgeBundleSpawnAndDebunkTest

# --- stubs (no dependency on your real QuestPool/ArcNotebook) ---

class TestQuestPool:
 var offers: Array = []
 func try\_add\_offer(inst) -> bool:
 offers.append(inst)
 return true

class TestArcNotebook:
 func can\_spawn\_knowledge\_offer(\_key: StringName, \_day: int, \_cooldown\_days: int) -> bool:
 return true
 func mark\_knowledge\_offer\_spawned(\_key: StringName, \_day: int) -> void:
 pass


func \_ready() -> void:
 \_test\_bundle\_spawns\_then\_debunk\_reduces\_bundle()
 print("\n✅ KnowledgeBundleSpawnAndDebunkTest: OK\n")
 get\_tree().quit()


func \_test\_bundle\_spawns\_then\_debunk\_reduces\_bundle() -> void:
 # Make randomness deterministic for qtype selection (factory uses randi()).
 seed(424242)

 var knowledge := FactionKnowledgeModel.new()

 var A := &"A" # scapegoat
 var B := &"B" # observer/victim
 var C := &"C" # true actor

 # Profiles: B is more parano than diplomate => believes rumors more
 var profiles := {
 B: {"personality": {&"paranoia": 0.7, &"diplomacy": 0.3, &"intel": 0.5}}
 }

 # Minimal relations (used by apply\_knowledge\_resolution)
 var relations := {}
 relations[B] = {}
 relations[B][A] = FactionRelationScore.new()
 relations[B][A].trust = 40
 relations[B][A].tension = 10
 relations[B][A].grievance = 5
 relations[B][A].relation = 0

 # Fact: true raid is C -> B at day 1
 knowledge.register\_fact({
 "id": &"evt\_1",
 "day": 1,
 "type": &"RAID",
 "true\_actor": C,
 "true\_target": B,
 "severity": 1.0
 })

# Rumor #1 (day 2): "A did it" (malicious)

 var rumor1 := {
 "id": &"rum\_1",
 "day": 2,
 "seed\_id": C,
 "claim\_actor": A,
 "claim\_target": B,
 "claim\_type": &"RAID",
 "strength": 0.70,
 "credibility": 0.60,
 "malicious": true,
 "related\_event\_id": &"evt\_1"
 }
 knowledge.inject\_rumor(rumor1, [B], profiles)

# Rumor #2 (day 3): reinforce the same claim, seed = BROKER

 var rumor2 := {
 "id": &"rum\_2",
 "day": 3,
 "seed\_id": &"BROKER",
 "claim\_actor": A,
 "claim\_target": B,
 "claim\_type": &"RAID",
 "strength": 0.65,
 "credibility": 0.60,
 "malicious": true,
 "related\_event\_id": &"evt\_1"
 }
 knowledge.inject\_rumor(rumor2, [B], profiles)

 var heat\_before := knowledge.get\_perceived\_heat(B, A, 3)
 \_assert(heat\_before >= 40.0, "precondition: heat should be >=40 after 2 rumors (heat=%.1f)" % heat\_before)

# Spawn bundle offers for rumor2

 var pool := TestQuestPool.new()
 var notebook := TestArcNotebook.new()

 var offers\_before: Array = KnowledgeOfferFactory.spawn\_offers\_for\_rumor(
 knowledge,
 rumor2,
 [B],
 3,
 pool,
 notebook,
 profiles,
 {"knowledge\_bundle\_max": 3, "knowledge\_offer\_cooldown\_days": 0}
 )

 \_assert(offers\_before.size() >= 2 and offers\_before.size() <= 3,
 "expected 2-3 offers at high heat, got %d" % offers\_before.size())

# Validate roles per knowledge\_action

 var has\_investigate := false
 var has\_innocence := false
 var has\_forge := false

 for inst in offers\_before:
 var ctx: Dictionary = inst.context
 \_assert(bool(ctx.get("is\_knowledge\_offer", false)), "offer must have is\_knowledge\_offer=true")

 var kact: StringName = StringName(ctx.get("knowledge\_action", &""))
 var giver: StringName = StringName(ctx.get("giver\_faction\_id", &""))
 var ant: StringName = StringName(ctx.get("antagonist\_faction\_id", &""))
 var tp: StringName = StringName(ctx.get("third\_party\_id", &""))

 if kact == &"INVESTIGATE":
 has\_investigate = true
 \_assert(giver == B, "INVESTIGATE giver should be observer/victim B")
 \_assert(ant == A, "INVESTIGATE antagonist should be claimed\_actor A")
 \_assert(tp == &"BROKER", "INVESTIGATE third\_party should be rumor seed (BROKER)")
 elif kact == &"PROVE\_INNOCENCE":
 has\_innocence = true
 \_assert(giver == A, "PROVE\_INNOCENCE giver should be claimed\_actor A")
 \_assert(ant == B, "PROVE\_INNOCENCE antagonist should be observer B")
 \_assert(tp == &"BROKER", "PROVE\_INNOCENCE third\_party should be rumor seed (BROKER)")
 elif kact == &"FORGE\_EVIDENCE":
 has\_forge = true
 \_assert(giver == &"BROKER", "FORGE\_EVIDENCE giver should be seed (BROKER)")
 \_assert(ant == A, "FORGE\_EVIDENCE antagonist should be claimed\_actor A")
 \_assert(tp == B, "FORGE\_EVIDENCE third\_party should be observer/victim B")

 \_assert(has\_investigate, "bundle should include INVESTIGATE at heat>=40")
 \_assert(has\_innocence, "bundle should include PROVE\_INNOCENCE at heat>=40")

# FORGE is expected in most cases at malicious=true and heat>=40 (unless confidence already >0.85).

 \_assert(has\_forge or offers\_before.size() == 2, "bundle should include FORGE\_EVIDENCE unless confidence already saturated")

# --- Debunk at day 4: PROVE\_INNOCENCE LOYAL reduces confidence in the hostile claim ---

 knowledge.apply\_knowledge\_resolution({
 "observer\_id": B,
 "claimed\_actor": A,
 "claimed\_target": B,
 "claim\_type": &"RAID",
 "knowledge\_action": &"PROVE\_INNOCENCE",
 "related\_event\_id": &"evt\_1",
 "day": 4
 }, &"LOYAL", relations, profiles, 4)

 var heat\_after\_debunk := knowledge.get\_perceived\_heat(B, A, 4)
 \_assert(heat\_after\_debunk < heat\_before, "heat should drop after debunk (%.1f -> %.1f)" % [heat\_before, heat\_after\_debunk])
 \_assert(heat\_after\_debunk < 40.0, "heat should drop below 'high heat' zone after debunk (heat=%.1f)" % heat\_after\_debunk)

# --- Day 5: a new weak malicious rumor tries again, but bundle should be smaller due to debunk ---

 var rumor3 := {
 "id": &"rum\_3",
 "day": 5,
 "seed\_id": &"BROKER",
 "claim\_actor": A,
 "claim\_target": B,
 "claim\_type": &"RAID",
 "strength": 0.40,
 "credibility": 0.50,
 "malicious": true,
 "related\_event\_id": &"evt\_1"
 }
 knowledge.inject\_rumor(rumor3, [B], profiles)

 var heat\_day5 := knowledge.get\_perceived\_heat(B, A, 5)

 var pool2 := TestQuestPool.new()
 var offers\_after: Array = KnowledgeOfferFactory.spawn\_offers\_for\_rumor(
 knowledge,
 rumor3,
 [B],
 5,
 pool2,
 notebook,
 profiles,
 {"knowledge\_bundle\_max": 3, "knowledge\_offer\_cooldown\_days": 0}
 )

 \_assert(offers\_after.size() <= offers\_before.size() - 1,
 "bundle should be reduced after debunk (before=%d after=%d heat=%.1f)" % [offers\_before.size(), offers\_after.size(), heat\_day5])

# With lower heat/confidence, FORGE should usually not appear anymore.

 for inst2 in offers\_after:
 var kact2: StringName = StringName(inst2.context.get("knowledge\_action", &""))
 \_assert(kact2 != &"FORGE\_EVIDENCE", "after debunk + weaker rumor, FORGE\_EVIDENCE should not be spawned (heat=%.1f)" % heat\_day5)


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


### Remarques


* Le test suppose que tu as bien le “merge/noisy-OR” dans `inject_rumor()` (sinon 2 rumeurs n’augmentent pas forcément `heat`).
* Le critère “bundle réduit” est volontairement robuste : `offers_after <= offers_before-1` plutôt que “exactement 1”, parce que ton `heat` après debunk peut varier selon tes poids de personnalité/decay.


Si tu veux, je peux aussi te faire une variante plus stricte (ex: **3 offers** avant, **0–1** après) en fixant exactement les paramètres (paranoia/diplomacy/strength/credibility) pour rendre ça 100% déterministe dans ton réglage actuel.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 12](#toc-detail-ch12)
<a id="moi-83"></a>
**Moi 83:**
Qu'apporte le fait que ce soit 100% deterministe et qurl sont les parametres qui randomize


**ChatGPT:**
Un test **100% déterministe** apporte surtout 3 choses :


* **Reproductibilité parfaite** : si ça casse sur ta CI ou sur ta machine, tu peux rerun et obtenir exactement le même résultat (même nombre d’offres, mêmes rôles).
* **Débogage rapide** : tu sais que l’échec vient d’un changement de code/règles, pas d’un tirage chanceux.
* **Non-flakiness** : pas de tests “parfois verts, parfois rouges” quand tu changes un seuil ou un poids.


À l’inverse, un test un peu stochastique est utile pour “property testing” (robustesse), mais il faut alors des assertions plus souples.


---


## Ce qui peut “randomizer” dans ce qu’on a écrit


### 1) Sélection de variante de quête (template)


Dans `KnowledgeOfferFactory._spawn_knowledge_offer()` on fait :


```
var qtype: StringName = options[randi() % options.size()]
```


Ça change le `quest_type` choisi (stealth vs diplomacy…), mais normalement pas le **nombre** d’offres.


✅ Pour rendre ça déterministe :


* appeler `seed(…)` au début du test (ce qu’on fait),
* ou remplacer `randi()` par `rng.randi()` injecté.


### 2) Le merge/noisy-OR (pas random)


Le merge qu’on propose (`1 - (1-old)(1-conf)`) est **déterministe**.


### 3) Les paramètres qui font varier `heat` (pas random, mais sensibles)


Même sans hasard, `heat` varie fortement selon :


* `strength`, `credibility` des rumeurs
* `profiles` (paranoia/diplomacy/intel)
* `decay_per_day`
* `severity`
* les seuils `HEAT_LOW/MED/HIGH`


Donc un test peut devenir “instable” si tu ajustes ces valeurs, même sans RNG. C’est une autre forme de non-déterminisme : pas aléatoire, mais fragile aux tunings.


### 4) Les endroits où tu pourrais introduire du RNG plus tard


Si tu ajoutes des probas du type :


* “observer reçoit la rumeur avec p=…”
* “rumeur se propage à un allié au hasard”
* “confidence initiale = base + noise”


Alors là, le **nombre** d’offres deviendra réellement dépendant du hasard.


---


## Ce que je te conseille (pratique)


* Garder **deux catégories de tests** :

1) **déterministes** : vérifient les invariants logiques (rôles giver/antagonist/third\_party, debunk ↓ heat, seuils).

2) **stochastiques** (optionnels) : 200 runs, vérifier des stats (“en moyenne, debunk réduit le bundle”, pas de divergence, etc.).


Et si tu veux rendre ton système test-friendly, le meilleur micro-patch est :


* injecter `rng: RandomNumberGenerator` dans `spawn_offers_for_rumor` (ou au moins dans `_spawn_knowledge_offer`) au lieu d’utiliser `randi()` global.


Si tu veux, je te donne le patch minimal “rng optionnel” (aucun changement en prod, mais tests 100% maîtrisés).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 12](#toc-detail-ch12)
<a id="moi-84"></a>
**Moi 84:**
On travaille sur

5) Coalitions/blocs (multi-paires mais lisibles)

La 3rd party est un bon début. Une étape simple au-dessus :

• un “bloc” (liste de factions) temporaire autour d’un conflit (ex: coalition anti-hégémonique),

• avec 1–2 quêtes “joint operation” (pas besoin d’un arc à 3 complet).

Effet : le monde se structure, et tu obtiens naturellement alliances/fusions.


Il Faudrait aussi que ca s'active si il y a une factions tres dominante face a de petites factions qui se font ecrasé


Par contre, il possible que la resolution ne soit pas loyal pour tout le monde


**ChatGPT:**
OK — passer de la *3rd party* à des **coalitions/blocs** est exactement le bon “niveau au-dessus” pour structurer le monde sans tomber dans un arc à 3 ultra-complexe.


Je te propose une V1 **lisible** (côté joueur) + **systémique** (côté IA), avec activation “anti-hégémon” et surtout un modèle où **la résolution n’est pas LOYAL pour tout le monde**.


---


## 1) Concept V1 : CoalitionBlock (temporaire, cible unique)


Une coalition est un objet **autour d’une cible** (souvent un hégémon) :


* **target\_id** : la faction dominante à contenir/abattre
* **members** : petites/moyennes factions qui se coordonnent
* **leader\_id** : celui qui initie (pas forcément le plus fort, souvent le plus motivé)
* **goal** : *CONTAIN / PUNISH / TAKE\_POI / SUBJUGATE / OVERTHROW*
* **cohesion** (0..100) : capacité à rester alignés
* **progress** (0..100) : progrès vers le goal (se nourrit des “joint operations”)
* **expires / lock** : évite spam / reformation instantanée


### Lisibilité côté joueur


* **1 seule coalition primaire visible par target** (pas 4 coalitions anti-A en même temps)
* **bundle d’offres 1–2 max** (ex: “joint operation” + “diplomatic pledge”)
* si pool bas, tu peux montrer une secondaire, sinon non.


---


## 2) Déclenchement “anti-hégémon” (dominant vs petites factions)


Pour activer **même si les relations ne sont pas encore “chaudes”**, tu utilises un score de dominance.


### `hegemon_index` (simple, robuste)


Un index 0..1 basé sur la part relative dans le monde :


* `power_share` (armée/territoire)
* `econ_share` (or/revenus)
* `recent_wins` (wars/POI captures, pondéré par récence)
* `threat_projection` (capacité à projeter des actions)


Exemple :


```
hegemon_index = 0.35*power_share + 0.25*econ_share + 0.25*recent_wins + 0.15*threat_projection
```


### Condition d’activation (V1)


* si `hegemon_index > 0.62`
* et au moins `N` factions ont `fear_of_target > 0.55` (ou “ont subi des pertes” récemment)
* alors on tente une coalition **DEFENSIVE** (containment) ou **OVERTHROW** selon profils.


👉 `fear_of_target` peut venir de :


* pertes récentes (POI perdu, tribut imposé, raids subis)
* proximité géographique (si tu l’as)
* divergence d’axes + historique hostile
* “rumeurs/knowledge” (très puissant : *“A est derrière tout”*)


---


## 3) Structure de données compacte


```
class\_name CoalitionBlock
extends RefCounted

var id: StringName
var target\_id: StringName
var leader\_id: StringName
var member\_ids: Array[StringName] = []

var goal: StringName = &"CONTAIN" # CONTAIN/OVERTHROW/TAKE\_POI/TRIBUTE/PUNISH
var started\_day: int = 0
var expires\_day: int = 0
var lock\_until\_day: int = 0

var cohesion: int = 60 # 0..100
var progress: float = 0.0 # 0..100

var member\_commitment: Dictionary = {} # member\_id -> 0..1
var member\_role: Dictionary = {} # member\_id -> "FRONTLINE"/"SUPPORT"/"DIPLO"

var last\_offer\_day: int = -999999
var primary\_offer\_active: bool = false
```


---


## 4) Offres “joint operation” (pont direct vers QuestPool)


Tu n’as besoin que de **2 familles** au début :


### A) `coalition.joint_op` (action concrète)


Variants (selon goal) :


* CONTAIN → supply interdiction / sabotage / scout / defend ally
* TAKE\_POI → joint siege prep / cut reinforcements / capture fort
* OVERTHROW → decisive battle / eliminate warlord / steal war plans


Context standard :


```
"is\_coalition": true,
"coalition\_id": coalition.id,
"coalition\_goal": coalition.goal,
"coalition\_target\_id": coalition.target\_id,
"coalition\_members": coalition.member\_ids,
"leader\_id": coalition.leader\_id,
"joint\_op\_type": &"SUPPLY\_LINE"|"SIEGE\_PREP"|...,
"stake": {...}, "expires\_in\_days": X
```


### B) `coalition.pledge` (engagement politique)


“prêter serment / échanger otages / signer pacte / faire un rituel”

→ augmente **commitment** et **cohesion**, et ouvre la porte à **alliance/fusion** plus tard.


---


## 5) Point crucial : “la résolution n’est pas LOYAL pour tout le monde”


Au lieu de supposer un unique choix, tu fais une **résolution par membre** (stance).


### Stances par membre


* `SUPPORT` (équiv. LOYAL à la coalition)
* `HEDGE` (NEUTRAL : “je fais le minimum”)
* `UNDERMINE` (TRAITOR : fuite d’info, sabotage, double jeu)

#### Comment décider la stance (IA)


Pour chaque membre `m` :


* base sur `commitment[m]`
* personnalité (opportunisme, diplomatie, peur, honneur)
* coût (fatigue, budget)
* et “fear of hegemon” (si target est terrifiante, certains vont trahir par peur)


Exemple très simple :


```
p_support = 0.35 + 0.45*commitment + 0.20*honor - 0.25*fear - 0.20*fatigue
p_undermine = 0.10 + 0.30*opportunism + 0.25*fear + 0.15*history_with_target
else hedge
```


### Application des effets


Après une joint op, tu appliques :


1) **progress coalition** dépend du % de SUPPORT


* si ≥ 60% SUPPORT → progress full
* si 30–60% → progress réduit
* si < 30% ou UNDERMINE présent → progress faible + pénalité cohesion


2) relations inter-membres selon alignement


* SUPPORT↔SUPPORT : trust +2
* SUPPORT vs HEDGE : trust -1 (frustration)
* SUPPORT vs UNDERMINE : trust -6 + “suspicion heat” (knowledge)


3) relations membre↔target


* SUPPORT : tension/grievance ↑
* UNDERMINE : member↔target s’améliore (et coalition le déteste)


C’est exactement ce qui crée des coalitions **instables mais vivantes**, et qui peut mener :


* à une **alliance durable** si la coalition tient,
* ou à une **fusion** si cohesion + compatibilité axes + traités,
* ou à une **implosion** (et parfois un nouveau bloc pro-hégémon).


---


## 6) Conditions de fin (coalition) et sorties naturelles


### Fin “réussite”


* `progress >= 100` :
	+ goal CONTAIN → treaty “mutual defense” (clauses no-raid/no-war, voire open\_trade entre membres)
	+ goal TAKE\_POI → transfert POI + trêve
	+ goal OVERTHROW → target affaiblie → soit “vassalage”, soit fragmentation, soit fusion de 2 membres dominants


### Fin “échec / implosion”


* `cohesion < 25` ou trop d’UNDERMINE → dissolve + lock long (15–40 jours)
* effet : relations internes se dégradent, et parfois formation d’un **bloc rival**


### Fin “contexte”


* menace externe majeure → conversion de coalition en **coalition défensive** (même membres, nouveau goal)


---


## 7) Où brancher ça dans ton architecture actuelle


* **ArcManager** reste pair-wise (A↔B)
* **CoalitionManager** est “multi-factions” et ne remplace pas ArcManager, il *oriente* :
	+ pousse des offers “joint operations”
	+ modifie les goals (WAR/CONFLICT/TRUCE) via `apply_arc_modifiers()`
	+ influence `compute_priority_targets()` (target = hegemon)


Et ton `QuestManager.resolve_quest()` appelle :


* `CoalitionManager.apply_joint_op_resolution(inst, choice)`

qui calcule les stances des membres et applique deltas.


---


Si tu veux, prochaine brique logique : je te donne un **MVP concret** en GDScript de :

1) `CoalitionManager.tick_day()` (détection hégémon + formation + spawn 1–2 offers max)

2) `apply_joint_op_resolution()` (stances par membre + progress/cohesion + deltas relationnels)

avec des hooks minimalistes vers QuestPool et ArcNotebook.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 13](#toc-detail-ch13)
<a id="moi-85"></a>
**Moi 85:**
donne un MVP concret en GDScript de :


<a id="cite-coalitionmanager-d24e07-1"></a>CoalitionManager.tick\_day() (détection hégémon + formation + spawn 1–2 offers max)


apply\_joint\_op\_resolution() (stances par membre + progress/cohesion + deltas relationnels)

avec des hooks minimalistes vers
<a id="cite-questpool-43825e-7"></a>QuestPool et
<a id="cite-arcnotebook-b751fa-6"></a>ArcNotebook.


<a id="cite-prends-a86775-1"></a>PrenDs en compte que la coalition peut aussi se creer pour prevenir une crise mondiale.

Ceux qyivy participe pzuvent ne pas s'apprecier ou meme etre en guerre et faire une treve temporaire pour repousser la menace.

Amoins qu'il aient plus d'interet a laisser la menace eclore plutot que d'arreter la guerre ou qu'ils soient en bon termes avec la faction qui declencje la crise, auqel cas ils peuvent faire une coalition avec la faction qui declenche la crise.


**ChatGPT:**
Voici un **MVP concret** en GDScript (Godot 4) qui fait :


* `CoalitionManager.tick_day()`


	+ détecte **hégémon** (anti-dominance) **OU** **crise mondiale** (anti-crise + pro-crise possible),
	+ forme/maintient 1–2 coalitions max par “key”,
	+ applique une **trêve temporaire** entre membres (même si en WAR),
	+ spawn **1–2 offers max** par coalition (joint op + pledge optionnel) via `QuestPool.try_add_offer()`,
	+ cooldown via `ArcNotebook`.
* `apply_joint_op_resolution()`


	+ calcule une **stance par membre** (SUPPORT / HEDGE / UNDERMINE) selon **profil + affinités + historique + relations + intérêts**,
	+ met à jour `progress/cohesion/commitment`,
	+ applique deltas relationnels **asymétriques** (et pas “LOYAL pour tout le monde”),
	+ enregistre des métriques simples dans `ArcNotebook`.


>
> Les classes `QuestTemplate` / `QuestInstance` sont supposées exister chez toi. Si ton builder de template runtime est ailleurs, remplace `_build_template_fallback()` par ton builder.
>
>
>


---


```
# CoalitionManager.gd

class\_name CoalitionManager
extends Node

class CoalitionBlock:
 var id: StringName
 var kind: StringName = &"HEGEMON" # HEGEMON | CRISIS
 var side: StringName = &"AGAINST\_TARGET" # AGAINST\_TARGET | WITH\_TARGET
 var goal: StringName = &"CONTAIN" # CONTAIN | OVERTHROW | STOP\_CRISIS | SUPPORT\_CRISIS

 var target\_id: StringName = &"" # hegemon or crisis instigator (can be empty if “world threat”)
 var leader\_id: StringName = &""
 var member\_ids: Array[StringName] = []

 var started\_day: int = 0
 var expires\_day: int = 0
 var lock\_until\_day: int = 0

 var cohesion: int = 60 # 0..100
 var progress: float = 0.0 # 0..100

 var member\_commitment: Dictionary = {} # member -> 0..1
 var member\_role: Dictionary = {} # member -> FRONTLINE/SUPPORT/DIPLO

 var last\_offer\_day: int = -999999

 func key() -> StringName:
 return StringName("%s|%s|%s" % [String(kind), String(side), String(target\_id)])


var coalitions\_by\_id: Dictionary = {} # id -> CoalitionBlock
var coalition\_id\_by\_key: Dictionary = {} # key -> id

var rng := RandomNumberGenerator.new()

# Tunables V1

const HEGEMON\_THRESHOLD := 0.62
const CRISIS\_THRESHOLD := 0.60
const MAX\_OFFERS\_PER\_COALITION\_PER\_TICK := 2
const OFFER\_COOLDOWN\_DAYS := 5
const COALITION\_MIN\_MEMBERS := 3
const COALITION\_MIN\_LIFE\_DAYS := 10
const COALITION\_MAX\_LIFE\_DAYS := 30

const STANCE\_SUPPORT := &"SUPPORT"
const STANCE\_HEDGE := &"HEDGE"
const STANCE\_UNDERMINE := &"UNDERMINE"


# ------------------------------------------------------------

# tick\_day(day): detect hegemon/crisis, form coalitions, spawn 1-2 offers

# ------------------------------------------------------------

func tick\_day(
 day: int,
 faction\_ids: Array[StringName],
 profiles: Dictionary, # faction -> FactionProfile (must have get\_personality/get\_axis\_affinity)
 relations: Dictionary, # relations[A][B] -> FactionRelationScore
 world: Dictionary, # crisis + power data
 quest\_pool, # must have try\_add\_offer(inst)
 arc\_notebook # minimal cooldown + optional pair\_lock
) -> void:
 # 0) upkeep / expire
 \_cleanup\_and\_expire(day, arc\_notebook)

# 1) CRISIS coalitions (can be AGAINST or WITH the crisis instigator)

 if bool(world.get("crisis\_active", false)):
 var sev := float(world.get("crisis\_severity", 0.0))
 if sev >= CRISIS\_THRESHOLD:
 \_ensure\_crisis\_coalitions(day, faction\_ids, profiles, relations, world, arc\_notebook)

# 2) HEGEMON coalition (anti-dominance) if no overriding crisis or if crisis not huge

 var hegemon\_id := \_detect\_hegemon(faction\_ids, world)
 if hegemon\_id != &"":
 var hegemon\_index := float(world.get("hegemon\_index\_by\_faction", {}).get(hegemon\_id, 0.0))
 if hegemon\_index >= HEGEMON\_THRESHOLD:
 \_ensure\_hegemon\_coalition(day, hegemon\_id, faction\_ids, profiles, relations, world, arc\_notebook)

# 3) Spawn offers (1–2 max / coalition, cooldown)

 for cid in coalitions\_by\_id.keys():
 var c: CoalitionBlock = coalitions\_by\_id[cid]
 if day < c.lock\_until\_day:
 continue
 if (day - c.last\_offer\_day) < OFFER\_COOLDOWN\_DAYS:
 continue
 if arc\_notebook != null and arc\_notebook.has\_method("can\_spawn\_coalition\_offer"):
 if not arc\_notebook.can\_spawn\_coalition\_offer(c.id, day, OFFER\_COOLDOWN\_DAYS):
 continue

 var spawned := 0
 # Always try JOINT OP first
 var inst := \_spawn\_joint\_op\_offer(c, day, profiles, relations, world)
 if inst != null and quest\_pool != null and quest\_pool.has\_method("try\_add\_offer"):
 if quest\_pool.try\_add\_offer(inst):
 spawned += 1

 # Optional PLEDGE offer if cohesion low or crisis with mixed members (even at war)
 if spawned < MAX\_OFFERS\_PER\_COALITION\_PER\_TICK:
 if c.cohesion <= 55 or c.kind == &"CRISIS":
 var inst2 := \_spawn\_pledge\_offer(c, day, profiles, relations, world)
 if inst2 != null and quest\_pool != null and quest\_pool.has\_method("try\_add\_offer"):
 if quest\_pool.try\_add\_offer(inst2):
 spawned += 1

 if spawned > 0:
 c.last\_offer\_day = day
 if arc\_notebook != null and arc\_notebook.has\_method("mark\_coalition\_offer\_spawned"):
 arc\_notebook.mark\_coalition\_offer\_spawned(c.id, day)

# ------------------------------------------------------------

# apply\_joint\_op\_resolution(): member stances + progress/cohesion + deltas

# ------------------------------------------------------------

func apply\_joint\_op\_resolution(
 context: Dictionary, # from QuestInstance.context
 choice: StringName, # LOYAL/NEUTRAL/TRAITOR (player)
 day: int,
 profiles: Dictionary,
 relations: Dictionary,
 world: Dictionary,
 arc\_notebook
) -> void:
 if not bool(context.get("is\_coalition", false)):
 return

 var cid: StringName = StringName(context.get("coalition\_id", &""))
 if cid == &"" or not coalitions\_by\_id.has(cid):
 return
 var c: CoalitionBlock = coalitions\_by\_id[cid]

 var members: Array[StringName] = c.member\_ids.duplicate()
 if members.is\_empty():
 return

 # 1) Determine stance per member (SUPPORT/HEDGE/UNDERMINE)
 var stances: Dictionary = {}
 var support\_count := 0
 var undermine\_count := 0

 var crisis\_axis: StringName = StringName(world.get("crisis\_axis", &""))

# optional (MAGIC/CORRUPTION/...)

 var crisis\_source: StringName = StringName(world.get("crisis\_source\_id", &""))

 for m in members:
 var stance := \_decide\_member\_stance(c, m, day, profiles, relations, world, arc\_notebook, crisis\_axis, crisis\_source)
 stances[m] = stance
 if stance == STANCE\_SUPPORT: support\_count += 1
 elif stance == STANCE\_UNDERMINE: undermine\_count += 1

 var support\_ratio := float(support\_count) / float(max(1, members.size()))

# 2) Update coalition progress/cohesion (player choice affects efficiency)

 var tier := int(context.get("tier", 2))
 var base\_progress := 14.0 + 4.0 * float(tier)

 var eff := clampf(0.25 + 0.95*support\_ratio - (undermine\_count > 0 ? 0.30 : 0.0), 0.05, 1.10)
 if choice == &"LOYAL": eff *= 1.05
 elif choice == &"NEUTRAL": eff *= 0.95
 elif choice == &"TRAITOR": eff *= 0.85

 var dp := base\_progress * eff
 c.progress = clampf(c.progress + dp, 0.0, 100.0)

 var dc := 0
 if support\_ratio >= 0.66: dc += 4
 elif support\_ratio >= 0.40: dc += 1
 else: dc -= 3
 if undermine\_count > 0: dc -= 6
 if choice == &"LOYAL": dc += 1
 if choice == &"TRAITOR": dc -= 2
 c.cohesion = int(clampi(c.cohesion + dc, 0, 100))

# 3) Relationship deltas among members (asymmetric, based on stances)

 \_apply\_member\_deltas(c, members, stances, relations, arc\_notebook, day)

# 4) Member commitment shifts (people can hedge/undermine without being “LOYAL”)

 for m in members:
 var commit := float(c.member\_commitment.get(m, 0.6))
 match StringName(stances[m]):
 STANCE\_SUPPORT:
 commit = clampf(commit + 0.06, 0.0, 1.0)
 STANCE\_HEDGE:
 commit = clampf(commit - 0.03, 0.0, 1.0)
 STANCE\_UNDERMINE:
 commit = clampf(commit - 0.22, 0.0, 1.0)
 c.member\_commitment[m] = commit

 # Optional: kick persistent underminers (MVP)
 var to\_remove: Array[StringName] = []
 for m in members:
 if float(c.member\_commitment.get(m, 0.6)) <= 0.12:
 to\_remove.append(m)
 for m in to\_remove:
 c.member\_ids.erase(m)
 c.member\_commitment.erase(m)
 c.member\_role.erase(m)

# 5) If coalition achieved its goal or collapsed -> dissolve + lock

 if c.progress >= 100.0:
 \_dissolve\_coalition(day, c, arc\_notebook, &"SUCCESS")
 elif c.cohesion <= 20 or c.member\_ids.size() < 2:
 \_dissolve\_coalition(day, c, arc\_notebook, &"COLLAPSE")

# metrics

 if arc\_notebook != null and arc\_notebook.has\_method("record\_coalition\_event"):
 arc\_notebook.record\_coalition\_event({
 "day": day, "coalition\_id": c.id, "goal": c.goal, "progress": c.progress, "cohesion": c.cohesion,
 "support\_ratio": support\_ratio, "undermine": undermine\_count, "choice": choice
 })

# ============================================================

# Internals

# ============================================================

func \_cleanup\_and\_expire(day: int, arc\_notebook) -> void:
 var to\_remove: Array[StringName] = []
 for cid in coalitions\_by\_id.keys():
 var c: CoalitionBlock = coalitions\_by\_id[cid]
 if day >= c.expires\_day and day >= (c.started\_day + COALITION\_MIN\_LIFE\_DAYS):
 to\_remove.append(cid)
 elif c.cohesion <= 10:
 to\_remove.append(cid)

 for cid in to\_remove:
 var c: CoalitionBlock = coalitions\_by\_id[cid]
 \_dissolve\_coalition(day, c, arc\_notebook, &"EXPIRE")


func \_dissolve\_coalition(day: int, c: CoalitionBlock, arc\_notebook, reason: StringName) -> void:
 # Long lock to prevent instant reformation
 c.lock\_until\_day = day + rng.randi\_range(15, 40)

# Mark cooldown in notebook (optional)

 if arc\_notebook != null and arc\_notebook.has\_method("mark\_coalition\_dissolved"):
 arc\_notebook.mark\_coalition\_dissolved(c.id, day, reason)

# Remove from registries

 var k := c.key()
 coalition\_id\_by\_key.erase(k)
 coalitions\_by\_id.erase(c.id)


func \_detect\_hegemon(faction\_ids: Array[StringName], world: Dictionary) -> StringName:
 var idx\_map: Dictionary = world.get("hegemon\_index\_by\_faction", {})
 if idx\_map is Dictionary and idx\_map.size() > 0:
 var best := &""
 var bestv := -1.0
 for f in faction\_ids:
 var v := float(idx\_map.get(f, 0.0))
 if v > bestv:
 bestv = v
 best = f
 return best

 # fallback from power\_by\_faction
 var pmap: Dictionary = world.get("power\_by\_faction", {})
 if pmap.size() == 0:
 return &""
 var best2 := &""
 var bestp := -1.0
 for f in faction\_ids:
 var p := float(pmap.get(f, 0.0))
 if p > bestp:
 bestp = p
 best2 = f
 return best2


func \_ensure\_hegemon\_coalition(day: int, hegemon\_id: StringName, faction\_ids: Array[StringName], profiles: Dictionary, relations: Dictionary, world: Dictionary, arc\_notebook) -> void:
 var key := StringName("HEGEMON|AGAINST\_TARGET|%s" % String(hegemon\_id))
 if coalition\_id\_by\_key.has(key):
 return

 # candidates: factions not hegemon, with fear/hostility, or simply weak ones under pressure
 var candidates: Array[StringName] = []
 for f in faction\_ids:
 if f == hegemon\_id: continue
 var score := \_anti\_hegemon\_join\_score(f, hegemon\_id, profiles, relations, world, arc\_notebook)
 if score >= 0.55:
 candidates.append(f)

 if candidates.size() < COALITION\_MIN\_MEMBERS:
 return

 # pick leader = highest score
 var leader := candidates[0]
 var best := -1.0
 for f in candidates:
 var s := \_anti\_hegemon\_join\_score(f, hegemon\_id, profiles, relations, world, arc\_notebook)
 if s > best:
 best = s
 leader = f

 var c := CoalitionBlock.new()
 c.kind = &"HEGEMON"
 c.side = &"AGAINST\_TARGET"
 c.goal = &"CONTAIN"
 c.target\_id = hegemon\_id
 c.leader\_id = leader
 c.started\_day = day
 c.expires\_day = day + rng.randi\_range(COALITION\_MIN\_LIFE\_DAYS, COALITION\_MAX\_LIFE\_DAYS)
 c.cohesion = 55
 c.progress = 0.0

 c.member\_ids = candidates
 for m in c.member\_ids:
 c.member\_commitment[m] = clampf(\_anti\_hegemon\_join\_score(m, hegemon\_id, profiles, relations, world, arc\_notebook), 0.2, 0.95)
 c.member\_role[m] = &"FRONTLINE" if rng.randf() < 0.35 else &"SUPPORT"

 c.id = StringName("coal\_heg\_%s\_%s" % [String(hegemon\_id), str(day)])
 coalitions\_by\_id[c.id] = c
 coalition\_id\_by\_key[key] = c.id

 # Optional: “soft truce” between members to keep it playable
 \_apply\_temp\_truce\_for\_members(c, day, arc\_notebook, 10)


func \_ensure\_crisis\_coalitions(day: int, faction\_ids: Array[StringName], profiles: Dictionary, relations: Dictionary, world: Dictionary, arc\_notebook) -> void:
 var source: StringName = StringName(world.get("crisis\_source\_id", &""))

# can be empty (pure world crisis)

 var axis: StringName = StringName(world.get("crisis\_axis", &""))
 var sev := float(world.get("crisis\_severity", 0.0))

# A) coalition AGAINST crisis/source (STOP\_CRISIS)

 var key\_anti := StringName("CRISIS|AGAINST\_TARGET|%s" % String(source))
 if not coalition\_id\_by\_key.has(key\_anti):
 var anti\_members: Array[StringName] = []
 for f in faction\_ids:
 # some factions prefer letting crisis grow or are friendly to source => won't join anti
 var s := \_stop\_crisis\_join\_score(f, source, axis, sev, profiles, relations, world, arc\_notebook)
 if s >= 0.55:
 anti\_members.append(f)

 if anti\_members.size() >= COALITION\_MIN\_MEMBERS:
 var leader := \_pick\_best\_leader(anti\_members, source, profiles, relations)
 var c := CoalitionBlock.new()
 c.kind = &"CRISIS"
 c.side = &"AGAINST\_TARGET"
 c.goal = &"STOP\_CRISIS"
 c.target\_id = source
 c.leader\_id = leader
 c.started\_day = day
 c.expires\_day = day + rng.randi\_range(12, 28)
 c.cohesion = 50
 c.member\_ids = anti\_members
 for m in c.member\_ids:
 c.member\_commitment[m] = clampf(\_stop\_crisis\_join\_score(m, source, axis, sev, profiles, relations, world, arc\_notebook), 0.2, 0.95)
 c.member\_role[m] = &"DIPLO" if rng.randf() < 0.25 else &"SUPPORT"
 c.id = StringName("coal\_crisis\_anti\_%s\_%s" % [String(source), str(day)])
 coalitions\_by\_id[c.id] = c
 coalition\_id\_by\_key[key\_anti] = c.id
 \_apply\_temp\_truce\_for\_members(c, day, arc\_notebook, 12)

# B) coalition WITH crisis/source (SUPPORT\_CRISIS) if source exists and has allies who want crisis

 if source == &"":
 return
 var key\_pro := StringName("CRISIS|WITH\_TARGET|%s" % String(source))
 if coalition\_id\_by\_key.has(key\_pro):
 return

 var pro\_members: Array[StringName] = []
 for f in faction\_ids:
 if f == source: continue
 var s2 := \_support\_crisis\_join\_score(f, source, axis, sev, profiles, relations, world, arc\_notebook)
 if s2 >= 0.62:
 pro\_members.append(f)

# Keep pro coalition smaller: it’s a “cabal”

 if pro\_members.size() >= 2:
 var c2 := CoalitionBlock.new()
 c2.kind = &"CRISIS"
 c2.side = &"WITH\_TARGET"
 c2.goal = &"SUPPORT\_CRISIS"
 c2.target\_id = source
 c2.leader\_id = source
 c2.started\_day = day
 c2.expires\_day = day + rng.randi\_range(10, 22)
 c2.cohesion = 55
 c2.member\_ids = pro\_members
 for m in c2.member\_ids:
 c2.member\_commitment[m] = clampf(\_support\_crisis\_join\_score(m, source, axis, sev, profiles, relations, world, arc\_notebook), 0.2, 0.95)
 c2.member\_role[m] = &"STEALTH" if rng.randf() < 0.5 else &"SUPPORT"
 c2.id = StringName("coal\_crisis\_pro\_%s\_%s" % [String(source), str(day)])
 coalitions\_by\_id[c2.id] = c2
 coalition\_id\_by\_key[key\_pro] = c2.id


func \_apply\_temp\_truce\_for\_members(c: CoalitionBlock, day: int, arc\_notebook, truce\_days: int) -> void:
 if arc\_notebook == null or not arc\_notebook.has\_method("set\_pair\_lock"):
 return
 var until := day + truce\_days
 for i in range(c.member\_ids.size()):
 for j in range(i + 1, c.member\_ids.size()):
 var a := c.member\_ids[i]
 var b := c.member\_ids[j]
 var pair\_key := \_pair\_key(a, b)
 arc\_notebook.set\_pair\_lock(pair\_key, until, &"COALITION\_TRUCE")


func \_spawn\_joint\_op\_offer(c: CoalitionBlock, day: int, profiles: Dictionary, relations: Dictionary, world: Dictionary) -> QuestInstance:
 var tier := clampi(2 + int(floor(c.progress / 35.0)), 1, 5)
 var deadline := (c.kind == &"CRISIS") ? 5 : 7

 var joint\_type := &"JOINT\_OP"
 var quest\_type := &"coalition.joint\_op"

 if c.kind == &"HEGEMON":
 quest\_type = &"coalition.joint\_op.contain"
 joint\_type = &"SUPPLY\_INTERDICTION"
 elif c.kind == &"CRISIS":
 if c.side == &"AGAINST\_TARGET":
 quest\_type = &"coalition.joint\_op.stop\_crisis"
 joint\_type = &"SEAL\_RIFT"
 else:
 quest\_type = &"coalition.joint\_op.support\_crisis"
 joint\_type = &"PROTECT\_CULT"

 var template := \_build\_template\_fallback(StringName(quest\_type), tier, deadline)

 var ctx := {
 "is\_coalition": true,
 "coalition\_id": c.id,
 "coalition\_kind": c.kind,
 "coalition\_side": c.side,
 "coalition\_goal": c.goal,
 "coalition\_target\_id": c.target\_id,
 "coalition\_members": c.member\_ids,
 "leader\_id": c.leader\_id,

 "joint\_op\_type": joint\_type,
 "tier": tier,
 "expires\_in\_days": deadline,

 "giver\_faction\_id": c.leader\_id,
 "antagonist\_faction\_id": c.target\_id,
 "resolution\_profile\_id": &"coalition\_joint\_op"
 }

 var inst := QuestInstance.new(template, ctx)
 inst.status = "AVAILABLE"
 inst.started\_on\_day = day
 inst.expires\_on\_day = day + deadline
 return inst


func \_spawn\_pledge\_offer(c: CoalitionBlock, day: int, profiles: Dictionary, relations: Dictionary, world: Dictionary) -> QuestInstance:
 var tier := 1
 var deadline := 6
 var template := \_build\_template\_fallback(&"coalition.pledge", tier, deadline)

 var ctx := {
 "is\_coalition": true,
 "coalition\_id": c.id,
 "coalition\_kind": c.kind,
 "coalition\_side": c.side,
 "coalition\_goal": c.goal,
 "coalition\_target\_id": c.target\_id,
 "coalition\_members": c.member\_ids,
 "leader\_id": c.leader\_id,

 "pledge": true,
 "tier": tier,
 "expires\_in\_days": deadline,

 "giver\_faction\_id": c.leader\_id,
 "antagonist\_faction\_id": c.target\_id,
 "resolution\_profile\_id": &"coalition\_pledge"
 }

 var inst := QuestInstance.new(template, ctx)
 inst.status = "AVAILABLE"
 inst.started\_on\_day = day
 inst.expires\_on\_day = day + deadline
 return inst


func \_decide\_member\_stance(
 c: CoalitionBlock,
 m: StringName,
 day: int,
 profiles: Dictionary,
 relations: Dictionary,
 world: Dictionary,
 arc\_notebook,
 crisis\_axis: StringName,
 crisis\_source: StringName
) -> StringName:
 var p = profiles.get(m, null)
 var commit := float(c.member\_commitment.get(m, 0.6))

 var opportunism := \_p(p, &"opportunism", 0.5)
 var diplomacy := \_p(p, &"diplomacy", 0.5)
 var honor := \_p(p, &"honor", 0.5)
 var fear := \_p(p, &"fear", 0.5)

# optionnel si tu l’as, sinon 0.5

 # relation to leader/target
 var rel\_to\_leader := \_rel(relations, m, c.leader\_id)
 var rel\_to\_target := \_rel(relations, m, c.target\_id)

# Axis alignment with crisis (if crisis axis exists)

 var axis\_aff := 0.0
 if crisis\_axis != &"" and p != null and p.has\_method("get\_axis\_affinity"):
 axis\_aff = float(p.get\_axis\_affinity(crisis\_axis, 0)) / 100.0 # -1..+1

 # If coalition is AGAINST target but member likes target => more hedge/undermine
 var likes\_target := rel\_to\_target >= 40.0
 var hates\_target := rel\_to\_target <= -40.0

 var sev := float(world.get("crisis\_severity", 0.0))
 var crisis\_pressure := (c.kind == &"CRISIS") ? sev : 0.0

 # Members can join a crisis coalition even if they dislike others; stance models actual cooperation.
 var p\_support := 0.25 + 0.55*commit + 0.20*honor + 0.15*hates\_target + 0.20*crisis\_pressure - 0.20*fear - 0.15*opportunism
 var p\_undermine := 0.08 + 0.30*opportunism + 0.20*fear + 0.20*likes\_target - 0.20*honor

 # Crisis special-case: if axis\_aff strongly positive for crisis axis and coalition is STOP\_CRISIS => undermine rises
 if c.kind == &"CRISIS" and c.goal == &"STOP\_CRISIS" and axis\_aff >= 0.55:
 p\_undermine += 0.18
 p\_support -= 0.10

 # If coalition is SUPPORT\_CRISIS and member is anti-axis => they hedge/undermine that coalition
 if c.kind == &"CRISIS" and c.goal == &"SUPPORT\_CRISIS" and axis\_aff <= -0.45:
 p\_support -= 0.15
 p\_undermine += 0.10

 # Friendly with crisis source => more undermine in anti coalition, more support in pro coalition
 if crisis\_source != &"":
 var rel\_to\_source := \_rel(relations, m, crisis\_source)
 if c.goal == &"STOP\_CRISIS" and rel\_to\_source >= 50.0:
 p\_undermine += 0.20
 p\_support -= 0.10
 if c.goal == &"SUPPORT\_CRISIS" and rel\_to\_source >= 20.0:
 p\_support += 0.15

 p\_support = clampf(p\_support, 0.0, 0.95)
 p\_undermine = clampf(p\_undermine, 0.0, 0.80)

 var r := rng.randf()
 if r < p\_support:
 return STANCE\_SUPPORT
 if r < (p\_support + p\_undermine):
 return STANCE\_UNDERMINE
 return STANCE\_HEDGE


func \_apply\_member\_deltas(
 c: CoalitionBlock,
 members: Array[StringName],
 stances: Dictionary,
 relations: Dictionary,
 arc\_notebook,
 day: int
) -> void:
 # Member vs leader and member vs target
 for m in members:
 var stance: StringName = StringName(stances[m])

# Leader disappointed by hedgers/underminers

 if m != c.leader\_id:
 \_apply\_rel(relations, c.leader\_id, m, "trust", (stance == STANCE\_SUPPORT ? +2 : stance == STANCE\_HEDGE ? -2 : -6))
 \_apply\_rel(relations, c.leader\_id, m, "relation", (stance == STANCE\_SUPPORT ? +1 : stance == STANCE\_HEDGE ? -1 : -4))

# Target relationship (if target exists)

 if c.target\_id != &"" and relations.has(m) and relations[m].has(c.target\_id):
 if c.side == &"AGAINST\_TARGET":
 if stance == STANCE\_SUPPORT:
 \_apply\_rel(relations, m, c.target\_id, "tension", +4)
 \_apply\_rel(relations, m, c.target\_id, "grievance", +3)
 \_apply\_rel(relations, m, c.target\_id, "relation", -3)
 elif stance == STANCE\_UNDERMINE:
 # le membre “fait copain-copain” ou leak => relation s'améliore, coalition le déteste
 \_apply\_rel(relations, m, c.target\_id, "trust", +2)
 \_apply\_rel(relations, m, c.target\_id, "relation", +2)
 else:
 # coalition WITH target
 if stance == STANCE\_SUPPORT:
 \_apply\_rel(relations, m, c.target\_id, "trust", +2)
 \_apply\_rel(relations, m, c.target\_id, "relation", +2)
 elif stance == STANCE\_UNDERMINE:
 \_apply\_rel(relations, m, c.target\_id, "trust", -4)
 \_apply\_rel(relations, m, c.target\_id, "relation", -3)

# Member-member trust shifts

 for i in range(members.size()):
 for j in range(i + 1, members.size()):
 var a := members[i]
 var b := members[j]
 var sa: StringName = StringName(stances[a])
 var sb: StringName = StringName(stances[b])

 if sa == STANCE\_SUPPORT and sb == STANCE\_SUPPORT:
 \_apply\_rel(relations, a, b, "trust", +2)
 \_apply\_rel(relations, b, a, "trust", +2)
 elif (sa == STANCE\_SUPPORT and sb == STANCE\_HEDGE) or (sa == STANCE\_HEDGE and sb == STANCE\_SUPPORT):
 \_apply\_rel(relations, a, b, "trust", -1)
 \_apply\_rel(relations, b, a, "trust", -1)
 elif (sa == STANCE\_UNDERMINE and sb == STANCE\_SUPPORT) or (sa == STANCE\_SUPPORT and sb == STANCE\_UNDERMINE):
 \_apply\_rel(relations, a, b, "trust", -6)
 \_apply\_rel(relations, b, a, "trust", -6)
 if arc\_notebook != null and arc\_notebook.has\_method("record\_pair\_event"):
 arc\_notebook.record\_pair\_event(day, a, b, &"COALITION\_BETRAYAL", &"", {})

# debug/metrics


# -------------------- scoring helpers --------------------

func \_anti\_hegemon\_join\_score(f: StringName, hegemon: StringName, profiles: Dictionary, relations: Dictionary, world: Dictionary, arc\_notebook) -> float:
 # join if fear/hostility or recent losses or ideology clash; also if weak
 var rel := \_rel(relations, f, hegemon) / 100.0
 var p = profiles.get(f, null)
 var diplomacy := \_p(p, &"diplomacy", 0.5)
 var opportunism := \_p(p, &"opportunism", 0.5)
 var honor := \_p(p, &"honor", 0.5)

 var power\_map: Dictionary = world.get("power\_by\_faction", {})
 var my\_power := float(power\_map.get(f, 0.0))
 var heg\_power := float(power\_map.get(hegemon, 0.0))
 var weak := (heg\_power > 0.0) ? clampf(1.0 - (my\_power / heg\_power), 0.0, 1.0) : 0.0

 # history pressure (optional)
 var hist := 0.0
 if arc\_notebook != null and arc\_notebook.has\_method("get\_pair\_counter"):
 var pk := \_pair\_key(f, hegemon)
 hist = clampf(0.05 * float(arc\_notebook.get\_pair\_counter(pk, &"hostile\_events", 0)), 0.0, 0.4)

 var s := 0.30*weak + 0.30*clampf(-rel, 0.0, 1.0) + 0.15*honor - 0.15*diplomacy + 0.10*opportunism + hist
 return clampf(s, 0.0, 1.0)


func \_stop\_crisis\_join\_score(f: StringName, source: StringName, crisis\_axis: StringName, sev: float, profiles: Dictionary, relations: Dictionary, world: Dictionary, arc\_notebook) -> float:
 # join anti-crisis if altruism/honor/diplomacy, dislikes source, or crisis threatens them
 var p = profiles.get(f, null)
 var honor := \_p(p, &"honor", 0.5)
 var diplomacy := \_p(p, &"diplomacy", 0.5)
 var opportunism := \_p(p, &"opportunism", 0.5)

 var rel\_to\_source := (source == &"") ? 0.0 : \_rel(relations, f, source) / 100.0
 var axis\_aff := 0.0
 if crisis\_axis != &"" and p != null and p.has\_method("get\_axis\_affinity"):
 axis\_aff = float(p.get\_axis\_affinity(crisis\_axis, 0)) / 100.0

 # If member *likes* the crisis axis (ex corruption) => less motivated to stop it
 var axis\_resist := clampf(-axis\_aff, 0.0, 1.0)

 var s := 0.25*sev + 0.20*honor + 0.20*diplomacy + 0.20*axis\_resist + 0.15*clampf(-rel\_to\_source, 0.0, 1.0) - 0.15*opportunism
 return clampf(s, 0.0, 1.0)


func \_support\_crisis\_join\_score(f: StringName, source: StringName, crisis\_axis: StringName, sev: float, profiles: Dictionary, relations: Dictionary, world: Dictionary, arc\_notebook) -> float:
 # join pro-crisis if opportunistic, aligned with axis, friendly to source
 var p = profiles.get(f, null)
 var opportunism := \_p(p, &"opportunism", 0.5)
 var honor := \_p(p, &"honor", 0.5)
 var rel\_to\_source := \_rel(relations, f, source) / 100.0

 var axis\_aff := 0.0
 if crisis\_axis != &"" and p != null and p.has\_method("get\_axis\_affinity"):
 axis\_aff = float(p.get\_axis\_affinity(crisis\_axis, 0)) / 100.0

 var s := 0.25*sev + 0.25*opportunism + 0.20*clampf(rel\_to\_source, 0.0, 1.0) + 0.20*clampf(axis\_aff, 0.0, 1.0) - 0.15*honor
 return clampf(s, 0.0, 1.0)


func \_pick\_best\_leader(members: Array[StringName], target: StringName, profiles: Dictionary, relations: Dictionary) -> StringName:
 var best := members[0]
 var bestv := -1.0
 for f in members:
 var p = profiles.get(f, null)
 var diplomacy := \_p(p, &"diplomacy", 0.5)
 var honor := \_p(p, &"honor", 0.5)
 var rel := \_rel(relations, f, target) / 100.0
 var v := 0.40*diplomacy + 0.25*honor + 0.35*clampf(-rel, 0.0, 1.0)
 if v > bestv:
 bestv = v
 best = f
 return best


# -------------------- template builder (fallback) --------------------

func \_build\_template\_fallback(id: StringName, tier: int, expires\_in\_days: int):
 var t := QuestTemplate.new()
 t.id = id
 t.title = String(id)
 t.description = "Coalition offer: %s" % String(id)
 t.category = &"COALITION"
 t.tier = tier
 t.objective\_type = &"GENERIC"
 t.objective\_target = &""
 t.objective\_count = 1
 t.expires\_in\_days = expires\_in\_days
 return t


# -------------------- tiny relation utils --------------------

func \_rel(relations: Dictionary, a: StringName, b: StringName) -> float:
 if a == &"" or b == &"":
 return 0.0
 if not relations.has(a) or not relations[a].has(b):
 return 0.0
 return float(relations[a][b].relation)

func \_apply\_rel(relations: Dictionary, a: StringName, b: StringName, field: String, delta: int) -> void:
 if a == &"" or b == &"":
 return
 if not relations.has(a) or not relations[a].has(b):
 return
 var r: FactionRelationScore = relations[a][b]
 match field:
 "relation": r.relation = int(clampi(r.relation + delta, -100, 100))
 "trust": r.trust = int(clampi(r.trust + delta, 0, 100))
 "tension": r.tension = int(clampi(r.tension + delta, 0, 100))
 "grievance": r.grievance = int(clampi(r.grievance + delta, 0, 100))
 "weariness": r.weariness = int(clampi(r.weariness + delta, 0, 100))

func \_p(profile, key: StringName, default\_val: float) -> float:
 if profile == null:
 return default\_val
 if profile.has\_method("get\_personality"):
 return float(profile.get\_personality(key, default\_val))
 if profile is Dictionary:
 return float(profile.get("personality", {}).get(key, default\_val))
 return default\_val

func \_pair\_key(a: StringName, b: StringName) -> StringName:
 var sa := String(a)
 var sb := String(b)
 return StringName((sa <= sb) ? (sa + "|" + sb) : (sb + "|" + sa))
```


---


### Points importants (ce que ce MVP couvre par rapport à ta demande)


* **Coalition anti-hégémon** : se forme si une faction est trop dominante, même si les petites factions se détestent (elles peuvent quand même rejoindre, puis “hedge/undermine” modélise la réalité).
* **Coalition crise mondiale** :
	+ une coalition **STOP\_CRISIS** *contre* la menace / l’instigateur,
	+ une coalition **SUPPORT\_CRISIS** *avec* l’instigateur (cabal) si certaines factions y ont intérêt (opportunisme, affinité d’axe, bonnes relations).
* **Trêve temporaire** entre membres : via `ArcNotebook.set_pair_lock(pair_key, until_day, reason)` (si tu l’implémentes, ArcManager peut ignorer les incidents).
* **Résolution non uniforme** : chaque membre prend une stance (SUPPORT/HEDGE/UNDERMINE) -> deltas internes cohérents.


Si tu veux, prochaine brique logique : je te donne un mini test “crisis coalition” où 2 factions ennemies entrent en coalition STOP\_CRISIS, lock leurs arcs en trêve, puis une d’elles UNDERMINE (opportuniste + affinité corruption), ce qui fait baisser la cohesion et crée une suspicion mesurable dans ArcNotebook.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 13](#toc-detail-ch13)
<a id="moi-86"></a>
**Moi 86:**
prochaine brique logique : je te donne un mini test “crisis coalition” où 2 factions ennemies entrent en coalition STOP\_CRISIS, lock leurs arcs en trêve, puis une d’elles UNDERMINE (opportuniste + affinité corruption), ce qui fait baisser la cohesion et crée une suspicion mesurable dans
<a id="cite-arcnotebook-b751fa-7"></a>ArcNotebook.


**ChatGPT:**
Voici un **mini test “crisis coalition”** (style identique aux autres) qui vérifie :


1) Une **coalition STOP\_CRISIS** se forme même si **A et B sont ennemis**

2) `ArcNotebook.set_pair_lock()` est appelé ⇒ **trêve temporaire** entre membres (donc A↔B lock)

3) Lors d’une **joint op**, **B UNDERMINE** (opportuniste + affinité Corruption)

4) ⇒ **cohesion baisse**

5) ⇒ **suspicion mesurable** via un event `COALITION_BETRAYAL` (record\_pair\_event)


Pour éviter la flakiness RNG, le test utilise un **TestCoalitionManager** qui choisit la stance de façon **déterministe (argmax)** à partir des mêmes signaux (opportunism/axis\_affinity/etc.). Ça prouve bien “opportuniste + corruption ⇒ UNDERMINE”.


---


## `tests/CrisisCoalitionTruceUndermineTest.gd`


```
extends Node
class\_name CrisisCoalitionTruceUndermineTest

# -------- Stubs --------

class TestFactionProfile:
 var personality := {}
 var axis\_affinity := {} # axis -> -100..100

 func \_init(p: Dictionary, a: Dictionary) -> void:
 personality = p
 axis\_affinity = a

 func get\_personality(key: StringName, default\_val: float = 0.5) -> float:
 return float(personality.get(key, default\_val))

 func get\_axis\_affinity(axis: StringName, default\_val: int = 0) -> int:
 return int(axis\_affinity.get(axis, default\_val))


class TestQuestPool:
 var offers: Array = []
 func try\_add\_offer(inst) -> bool:
 offers.append(inst)
 return true


class TestArcNotebook:
 var pair\_locks: Dictionary = {} # pair\_key -> {"until": int, "reason": StringName}
 var pair\_events: Array = []

 func set\_pair\_lock(pair\_key: StringName, until\_day: int, reason: StringName) -> void:
 pair\_locks[pair\_key] = {"until": until\_day, "reason": reason}

 func can\_spawn\_coalition\_offer(\_coalition\_id: StringName, \_day: int, \_cooldown: int) -> bool:
 return true
 func mark\_coalition\_offer\_spawned(\_coalition\_id: StringName, \_day: int) -> void:
 pass

 func record\_pair\_event(day: int, a: StringName, b: StringName, action: StringName, \_choice: StringName, \_meta: Dictionary) -> void:
 pair\_events.append({"day": day, "a": a, "b": b, "action": action})

 func count\_events(action: StringName) -> int:
 var n := 0
 for e in pair\_events:
 if StringName(e.get("action", &"")) == action:
 n += 1
 return n


# -------- Deterministic stance manager (argmax) --------

class TestCoalitionManager:
 extends CoalitionManager

 func \_decide\_member\_stance(
 c: CoalitionBlock,
 m: StringName,
 day: int,
 profiles: Dictionary,
 relations: Dictionary,
 world: Dictionary,
 arc\_notebook,
 crisis\_axis: StringName,
 crisis\_source: StringName
 ) -> StringName:
 var p = profiles.get(m, null)
 var commit := float(c.member\_commitment.get(m, 0.6))

 var opportunism := \_p(p, &"opportunism", 0.5)
 var diplomacy := \_p(p, &"diplomacy", 0.5)
 var honor := \_p(p, &"honor", 0.5)
 var fear := \_p(p, &"fear", 0.5)

 var rel\_to\_target := \_rel(relations, m, c.target\_id)
 var likes\_target := rel\_to\_target >= 40.0
 var hates\_target := rel\_to\_target <= -40.0

 var axis\_aff := 0.0
 if crisis\_axis != &"" and p != null and p.has\_method("get\_axis\_affinity"):
 axis\_aff = float(p.get\_axis\_affinity(crisis\_axis, 0)) / 100.0

 var sev := float(world.get("crisis\_severity", 0.0))
 var crisis\_pressure := (c.kind == &"CRISIS") ? sev : 0.0

 var p\_support := 0.25 + 0.55*commit + 0.20*honor + 0.15*(hates\_target ? 1.0 : 0.0) + 0.20*crisis\_pressure - 0.20*fear - 0.15*opportunism
 var p\_undermine := 0.08 + 0.30*opportunism + 0.20*fear + 0.20*(likes\_target ? 1.0 : 0.0) - 0.20*honor

 # STOP\_CRISIS + corruption-aligned => more undermine
 if c.kind == &"CRISIS" and c.goal == &"STOP\_CRISIS" and axis\_aff >= 0.55:
 p\_undermine += 0.18
 p\_support -= 0.10

 # friendly to crisis source => more undermine in STOP coalition
 if crisis\_source != &"":
 var rel\_to\_source := \_rel(relations, m, crisis\_source)
 if c.goal == &"STOP\_CRISIS" and rel\_to\_source >= 50.0:
 p\_undermine += 0.20
 p\_support -= 0.10

 p\_support = clampf(p\_support, 0.0, 0.95)
 p\_undermine = clampf(p\_undermine, 0.0, 0.80)
 var p\_hedge := max(0.0, 1.0 - (p\_support + p\_undermine))

# deterministic: choose argmax

 if p\_undermine >= p\_support and p\_undermine >= p\_hedge:
 return STANCE\_UNDERMINE
 if p\_support >= p\_hedge:
 return STANCE\_SUPPORT
 return STANCE\_HEDGE


func \_ready() -> void:
 \_test\_crisis\_coalition\_truce\_then\_undermine\_creates\_suspicion()
 print("\n✅ CrisisCoalitionTruceUndermineTest: OK\n")
 get\_tree().quit()


func \_test\_crisis\_coalition\_truce\_then\_undermine\_creates\_suspicion() -> void:
 var mgr := TestCoalitionManager.new()

 var A := &"A" # enemy of B, but will SUPPORT coalition
 var B := &"B" # opportunist + corruption affinity => UNDERMINE
 var D := &"D" # third member to satisfy min members
 var C := &"C" # crisis instigator/target of STOP coalition

 var faction\_ids: Array[StringName] = [A, B, C, D]

 # Profiles
 var profiles := {
 A: TestFactionProfile.new(
 {&"honor": 0.8, &"diplomacy": 0.6, &"opportunism": 0.2, &"fear": 0.3},
 {&"CORRUPTION": -80}
 ),
 # B: can join STOP\_CRISIS (honor/diplomacy decent), but stance will undermine due opportunism/fear + corruption affinity
 B: TestFactionProfile.new(
 {&"honor": 0.75, &"diplomacy": 0.7, &"opportunism": 0.9, &"fear": 0.9},
 {&"CORRUPTION": 85}
 ),
 D: TestFactionProfile.new(
 {&"honor": 0.65, &"diplomacy": 0.55, &"opportunism": 0.35, &"fear": 0.35},
 {&"CORRUPTION": -40}
 ),
 C: TestFactionProfile.new(
 {&"honor": 0.3, &"diplomacy": 0.2, &"opportunism": 0.7, &"fear": 0.4},
 {&"CORRUPTION": 90}
 ),
 }

 # Relations matrix
 var relations := {}
 for f in faction\_ids:
 relations[f] = {}
 for x in faction\_ids:
 for y in faction\_ids:
 if x == y: continue
 relations[x][y] = FactionRelationScore.new()

# A and B are enemies / at war-like

 relations[A][B].relation = -80
 relations[B][A].relation = -80

 # Everyone dislikes C enough to join anti crisis (STOP\_CRISIS uses dislike source)
 relations[A][C].relation = -70
 relations[D][C].relation = -60
 relations[B][C].relation = -60

 # (Optional) B is NOT friendly to C here; undermine is driven by corruption affinity + opportunism/fear
 # If you want “B friendly to instigator”, set relations[B][C].relation = +60 (but then join score might drop unless you update join scoring)

# World crisis

 var world := {
 "crisis\_active": true,
 "crisis\_severity": 0.85,
 "crisis\_axis": &"CORRUPTION",
 "crisis\_source\_id": C,
 "power\_by\_faction": {A: 40.0, B: 38.0, C: 50.0, D: 22.0},
 "hegemon\_index\_by\_faction": {} # not needed
 }

 var pool := TestQuestPool.new()
 var notebook := TestArcNotebook.new()

# Day 10: tick => should form STOP\_CRISIS coalition and set truce locks

 mgr.tick\_day(10, faction\_ids, profiles, relations, world, pool, notebook)

# Find the created STOP\_CRISIS coalition

 var coal: CoalitionManager.CoalitionBlock = null
 for cid in mgr.coalitions\_by\_id.keys():
 var c = mgr.coalitions\_by\_id[cid]
 if c.kind == &"CRISIS" and c.goal == &"STOP\_CRISIS" and c.target\_id == C:
 coal = c
 break

 \_assert(coal != null, "should create a STOP\_CRISIS coalition")
 \_assert(coal.member\_ids.has(A) and coal.member\_ids.has(B) and coal.member\_ids.has(D), "coalition should include A,B,D")

# Verify pair lock truce between members (A|B in particular)

 var pair\_key\_ab := \_pair\_key(A, B)
 \_assert(notebook.pair\_locks.has(pair\_key\_ab), "expected pair lock for A|B to exist (temporary coalition truce)")
 var lock := notebook.pair\_locks[pair\_key\_ab]
 \_assert(int(lock["until"]) >= 10 + 10, "truce lock should last ~10+ days, got until=%d" % int(lock["until"]))
 \_assert(StringName(lock["reason"]) == &"COALITION\_TRUCE", "lock reason should be COALITION\_TRUCE")

# Ensure a JOINT OP offer exists (spawned by tick\_day)

 var joint\_ctx: Dictionary = {}
 for inst in pool.offers:
 if bool(inst.context.get("is\_coalition", false)) and StringName(inst.context.get("coalition\_id", &"")) == coal.id:
 if inst.context.has("joint\_op\_type"):
 joint\_ctx = inst.context
 break
 \_assert(not joint\_ctx.is\_empty(), "expected at least one joint\_op offer context")

# Apply resolution at day 11: should cause B to UNDERMINE deterministically and lower cohesion, and create suspicion event

 var cohesion\_before := coal.cohesion
 var betrayals\_before := notebook.count\_events(&"COALITION\_BETRAYAL")

 mgr.apply\_joint\_op\_resolution(joint\_ctx, &"LOYAL", 11, profiles, relations, world, notebook)

 \_assert(coal.cohesion < cohesion\_before, "cohesion should decrease when a member undermines (before=%d after=%d)" % [cohesion\_before, coal.cohesion])

 var betrayals\_after := notebook.count\_events(&"COALITION\_BETRAYAL")
 \_assert(betrayals\_after > betrayals\_before, "should record COALITION\_BETRAYAL suspicion event after undermine")


func \_pair\_key(a: StringName, b: StringName) -> StringName:
 var sa := String(a)
 var sb := String(b)
 return StringName((sa <= sb) ? (sa + "|" + sb) : (sb + "|" + sa))


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


### Notes rapides


* Le test force la stance “UNDermine” de façon déterministe via **argmax** (mêmes signaux que ton modèle), ce qui évite un test flaky.
* Il valide explicitement :
	+ **trêve** (pair\_lock A|B),
	+ **cohesion baisse**,
	+ **suspicion** via `COALITION_BETRAYAL`.


Si tu veux, je peux aussi ajouter une assertion bonus : `trust(A→B)` baisse fortement après l’undermine (via les deltas de `_apply_member_deltas`), ce qui rend la suspicion “mesurable” aussi par les métriques relationnelles, pas seulement via ArcNotebook.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 13](#toc-detail-ch13)
<a id="moi-87"></a>
**Moi 87:**
Bonne idée, fais ajouter une assertion bonus : trust(A→B) baisse fortement après l’undermine (via les deltas de \_apply\_member\_deltas), ce qui rend la suspicion “mesurable” aussi par les métriques relationnelles, pas seulement via
<a id="cite-arcnotebook-b751fa-8"></a>ArcNotebook.


**ChatGPT:**
Voici le **patch exact** du test pour ajouter l’assertion bonus “`trust(A→B)` baisse fortement après l’undermine”.


L’idée : on initialise `trust(A→B)` à une valeur connue (ex: 50), puis après `apply_joint_op_resolution`, on vérifie qu’il a chuté d’au moins **6** (car `_apply_member_deltas` applique `-6` sur trust quand SUPPORT vs UNDERMINE).


---


## Patch à appliquer dans `CrisisCoalitionTruceUndermineTest.gd`


### 1) Initialiser le trust avant la résolution


Dans la section “A and B are enemies / at war-like”, ajoute :


```
 relations[A][B].trust = 50
 relations[B][A].trust = 50
```


(Juste après `relations[A][B].relation = -80` etc.)

### 2) Capturer `trust(A→B)` avant l’appel


Juste avant :


```
 mgr.apply\_joint\_op\_resolution(joint\_ctx, &"LOYAL", 11, profiles, relations, world, notebook)
```


Ajoute :


```
 var trust\_ab\_before := relations[A][B].trust
```


### 3) Ajouter l’assertion après l’appel


Juste après l’assertion sur la cohésion, ajoute :


```
 var trust\_ab\_after := relations[A][B].trust
 \_assert(trust\_ab\_after <= trust\_ab\_before - 6,
 "trust(A→B) should drop strongly after undermine (before=%d after=%d)" % [trust\_ab\_before, trust\_ab\_after])
```


---


### Pourquoi “-6” ?


Dans `_apply_member_deltas`, le cas SUPPORT vs UNDERMINE fait :


* `trust -6` dans les deux sens (`a→b` et `b→a`), donc c’est un seuil clair et stable.


Si tu préfères une marge plus large (au cas où tu changes les deltas), mets `-4` ou `-5`.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 13](#toc-detail-ch13)
<a id="moi-88"></a>
**Moi 88:**
Ok, on passe a :

6) “Domestic pressure” (politique interne)

Même sans sim interne complexe, un scaler suffit :

• internal\_stability ou war\_support

• la guerre longue baisse le support → pousse TRUCE/REPARATIONS même si l’ennemi est détesté.

Effet : sortie de guerre organique + quêtes “maintenir l’ordre / propaganda / appease nobles


**ChatGPT:**
OK — “Domestic pressure” est parfait pour obtenir une **sortie de guerre organique** sans sim interne lourde.


## 1) Modèle minimal de données


Un seul scaler suffit, mais je te propose 2 champs + 1 dérivé (super lisible) :


```
# FactionDomesticState.gd

class\_name FactionDomesticState
extends RefCounted

var stability: int = 70 # 0..100 (ordre public / cohésion interne)
var war\_support: int = 70 # 0..100 (acceptation sociale de la guerre)
var unrest: int = 10 # 0..100 (moteur de quests "maintenir l'ordre")

func pressure() -> float:
 # 0..1 (plus haut = plus fragile)
 return clampf(0.55*(1.0 - war\_support/100.0) + 0.45*(unrest/100.0), 0.0, 1.0)
```


>
> `pressure()` devient ton “bouton magique” : plus il monte, plus l’IA pousse **TRUCE/REPARATIONS**, même si l’ennemi est haï.
>
>
>


---


## 2) Tick journalier (MVP) : guerre longue → support↓, unrest↑


On s’appuie sur ce que tu as déjà : **ArcNotebook** (historique), `weariness` relationnel, budget/or, et éventuellement des tags monde.


```
# DomesticPressureUtil.gd

class\_name DomesticPressureUtil
extends RefCounted

static func tick\_domestic(
 day: int,
 faction\_id: StringName,
 dom: FactionDomesticState,
 profile, # FactionProfile (optionnel)
 economy, # FactionEconomy (optionnel)
 arc\_notebook, # pour compter jours de guerre / pertes proxy
 relations: Dictionary, # relations[faction][other] -> FactionRelationScore
 world: Dictionary # tags / crisis flags
) -> void:
 # ---- inputs/proxies ----
 var diplo := \_p(profile, &"diplomacy", 0.5)
 var honor := \_p(profile, &"honor", 0.5)
 var bell := \_p(profile, &"belligerence", 0.5)
 var fear := \_p(profile, &"fear", 0.5)

 var gold := (economy.gold if economy != null and economy.has\_method("get") == false else (economy.gold if economy != null else 0))
 var poor := (gold < 80)

# proxy simple (à remplacer par income/expenses si tu as)

 var war\_days := 0
 if arc\_notebook != null and arc\_notebook.has\_method("get\_faction\_counter"):
 war\_days = int(arc\_notebook.get\_faction\_counter(faction\_id, &"war\_days\_rolling\_30", 0))

# fallback: approx via relations weariness (moyenne)

 if war\_days == 0 and relations.has(faction\_id):
 var w := 0.0
 var n := 0.0
 for other in relations[faction\_id].keys():
 var r: FactionRelationScore = relations[faction\_id][other]
 w += float(r.weariness)
 n += 1.0
 war\_days = int(clampf((w/max(1.0, n)) / 4.0, 0.0, 30.0))

# grossier mais utile

 var crisis := bool(world.get("crisis\_active", false))
 var crisis\_sev := float(world.get("crisis\_severity", 0.0))

# ---- dynamics ----

 # guerre longue => war\_support baisse, unrest monte
 var war\_fatigue := clampf(float(war\_days) / 30.0, 0.0, 1.0)

# 0..1

 var support\_drop := 1.2 + 2.5*war\_fatigue + 0.8*bell - 0.9*diplo - 0.6*honor
 if poor: support\_drop += 0.9
 if crisis: support\_drop += 0.6*crisis\_sev # crise fatigue la population

 var unrest\_rise := 0.6 + 1.8*war\_fatigue + 0.8*fear - 0.6*diplo
 if poor: unrest\_rise += 0.8
 if crisis: unrest\_rise += 0.7*crisis\_sev

 # petits amortisseurs (propagande/ordre) : ici on triche via stabilité actuelle
 support\_drop *= (1.0 + 0.35*(1.0 - dom.stability/100.0))
 unrest\_rise *= (1.0 - 0.25*(dom.stability/100.0))

# ---- apply ----

 dom.war\_support = int(clampi(dom.war\_support - int(round(support\_drop)), 0, 100))
 dom.unrest = int(clampi(dom.unrest + int(round(unrest\_rise)), 0, 100))

# stabilité suit l’unrest

 var stab\_delta := -int(round(0.6*unrest\_rise)) + int(round(0.25*diplo*2.0))
 dom.stability = int(clampi(dom.stability + stab\_delta, 0, 100))


static func \_p(profile, key: StringName, default\_val: float) -> float:
 if profile == null:
 return default\_val
 if profile.has\_method("get\_personality"):
 return float(profile.get\_personality(key, default\_val))
 if profile is Dictionary:
 return float(profile.get("personality", {}).get(key, default\_val))
 return default\_val
```


---


## 3) Comment ça influence Arcs/Goals (effet “sortie de guerre”)


Tu utilises `pressure()` comme multiplicateur :


* **actions offensives** (raid, declare\_war, sabotage) : probabilité × `(1 - 0.55*pressure)`
* **actions de sortie** (truce\_talks, reparations, armistice, enforcement) : probabilité × `(1 + 0.75*pressure)`
* **coalitions** : un membre à forte pression a plus de chance de **HEDGE/UNDERMINE** (capacité politique limitée)


Exemple (dans ton `compute_arc_event_chance` ou table action selection) :


```
var p := domestic.pressure()
if action\_is\_offensive:
 chance *= (1.0 - 0.55*p)
else:
 chance *= (1.0 + 0.75*p)

# règle simple

if domestic.war\_support <= 25:
 # même si l’ennemi est haï, on privilégie TRUCE/REPARATIONS
 force\_prefer\_truce = true
```


---


## 4) Offres “domestic” (pont vers QuestPool)


Quand `pressure >= 0.65` ou `unrest >= 60`, tu spawns **1 offer max** par faction (anti-spam) :


### Mapping MVP


* `domestic.maintain_order` (combat) : réprimer émeutes / bandits / milice
* `domestic.propaganda` (diplomacy/stealth) : discours, rumeurs, contrôler presse/temples
* `domestic.appease_nobles` (gold/escort/diplomacy) : payer / négocier / escorter émissaire
* `domestic.reparations_push` (diplomacy) : “faire accepter une paix coûteuse”


**Effets typiques à la résolution** :


* LOYAL : `unrest -15`, `stability +8`, `war_support +6` (propaganda) OU `+0` (maintain\_order)
* NEUTRAL : moitié
* TRAITOR : `unrest +8`, `stability -6` (aggrave la crise interne)


Context standard :


```
"is\_domestic\_offer": true
"domestic\_action": "maintain\_order|propaganda|appease\_nobles|reparations\_push"
"giver\_faction\_id": faction\_id
"stake": {"pressure": p, "unrest": unrest}
"expires\_in\_days": 5..9
```


---


Si tu veux, prochaine brique logique : je te donne un `DomesticOfferFactory.spawn_offer_if_needed(faction_id, domestic_state)` + `apply_domestic_resolution(context, choice)` (comme on a fait pour Knowledge), et un mini test “war\_support tombe en 20 jours de guerre → apparition d’offres TRUCE + domestic”.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 14](#toc-detail-ch14)
<a id="moi-89"></a>
**Moi 89:**
Ok prochaine brique logique : je te donne un
<a id="cite-domesticofferfactory-a7a48d-1"></a>DomesticOfferFactory.spawn\_offer\_if\_needed(faction\_id, domestic\_state) + apply\_domestic\_resolution(context, choice) (comme on a fait pour Knowledge), et un mini test “war\_support tombe en 20 jours de guerre → apparition d’offres TRUCE + domestic


**ChatGPT:**
Voici la brique **DomesticOfferFactory** + **apply\_domestic\_resolution** + un **mini test** “20 jours de guerre ⇒ war\_support chute ⇒ apparition d’offres TRUCE + domestic”.


---


## 1) `DomesticOfferFactory.gd`


```
# DomesticOfferFactory.gd

class\_name DomesticOfferFactory
extends RefCounted

const DEFAULT\_COOLDOWN\_DAYS := 5

# choix d'action (MVP)

const ACTION\_MAINTAIN\_ORDER := &"domestic.maintain\_order"
const ACTION\_PROPAGANDA := &"domestic.propaganda"
const ACTION\_APPEASE\_NOBLES := &"domestic.appease\_nobles"
const ACTION\_REPARATIONS := &"domestic.reparations\_push"

static func spawn\_offer\_if\_needed(
 faction\_id: StringName,
 domestic\_state, # FactionDomesticState
 day: int,
 quest\_pool, # QuestPool.try\_add\_offer(inst)
 arc\_notebook = null,
 economy = null, # optional (gold)
 params: Dictionary = {}
):
 var pressure := float(domestic\_state.pressure())
 var unrest := int(domestic\_state.unrest)
 var war\_support := int(domestic\_state.war\_support)
 var stability := int(domestic\_state.stability)

# conditions d’apparition (MVP)

 if pressure < 0.55 and unrest < 55 and war\_support > 35:
 return null

 var cooldown := int(params.get("cooldown\_days", DEFAULT\_COOLDOWN\_DAYS))

# cooldown anti-spam (si ArcNotebook le supporte)

 if arc\_notebook != null and arc\_notebook.has\_method("can\_spawn\_domestic\_offer"):
 if not arc\_notebook.can\_spawn\_domestic\_offer(faction\_id, day, cooldown):
 return null

 # choisir action
 var action: StringName
 if war\_support <= 25:
 action = ACTION\_REPARATIONS
 elif unrest >= 70:
 action = ACTION\_MAINTAIN\_ORDER
 elif stability <= 40:
 action = ACTION\_APPEASE\_NOBLES
 else:
 action = ACTION\_PROPAGANDA

 # coût politique/éco (MVP) + fallback
 var cost\_gold := 0
 if action == ACTION\_APPEASE\_NOBLES:
 cost\_gold = 60
 if action == ACTION\_REPARATIONS:
 cost\_gold = 30

 if economy != null and cost\_gold > 0 and int(economy.gold) < cost\_gold:
 # pas assez d’or => fallback vers propaganda (toujours faisable)
 action = ACTION\_PROPAGANDA
 cost\_gold = 0

 # tier/deadline
 var tier := clampi(1 + int(floor(pressure * 4.0)) + (unrest >= 70 ? 1 : 0), 1, 5)
 var deadline := clampi(9 - int(floor(pressure * 5.0)), 4, 9)

 var template := \_build\_template\_fallback(action, tier, deadline)

 var ctx := {
 "is\_domestic\_offer": true,
 "domestic\_action": action,
 "giver\_faction\_id": faction\_id,
 "tier": tier,
 "expires\_in\_days": deadline,
 "stake": {"pressure": pressure, "unrest": unrest, "war\_support": war\_support, "stability": stability},
 "domestic\_cost\_gold": cost\_gold,
 "resolution\_profile\_id": &"domestic\_default"
 }

 var inst := QuestInstance.new(template, ctx)
 inst.status = "AVAILABLE"
 inst.started\_on\_day = day
 inst.expires\_on\_day = day + deadline

 if quest\_pool != null and quest\_pool.has\_method("try\_add\_offer"):
 if not quest\_pool.try\_add\_offer(inst):
 return null

 if arc\_notebook != null and arc\_notebook.has\_method("mark\_domestic\_offer\_spawned"):
 arc\_notebook.mark\_domestic\_offer\_spawned(faction\_id, day)

 return inst


static func apply\_domestic\_resolution(
 context: Dictionary,
 choice: StringName, # LOYAL/NEUTRAL/TRAITOR
 domestic\_state, # FactionDomesticState
 economy = null
) -> void:
 if not bool(context.get("is\_domestic\_offer", false)):
 return

 var action: StringName = StringName(context.get("domestic\_action", &""))
 var cost\_gold := int(context.get("domestic\_cost\_gold", 0))

# payer si nécessaire (LOYAL/NEUTRAL seulement)

 if economy != null and cost\_gold > 0 and (choice == &"LOYAL" or choice == &"NEUTRAL"):
 var pay := cost\_gold if choice == &"LOYAL" else int(ceil(cost\_gold * 0.5))
 economy.gold = max(0, int(economy.gold) - pay)

# effets (MVP)

 var du := 0
 var ds := 0
 var dw := 0

 match action:
 ACTION\_MAINTAIN\_ORDER:
 if choice == &"LOYAL": du = -18; ds = +6; dw = +0
 elif choice == &"NEUTRAL":du = -9; ds = +3; dw = +0
 else: du = +10; ds = -6; dw = -3
 ACTION\_PROPAGANDA:
 if choice == &"LOYAL": du = -8; ds = +3; dw = +10
 elif choice == &"NEUTRAL":du = -4; ds = +1; dw = +5
 else: du = +8; ds = -4; dw = -6
 ACTION\_APPEASE\_NOBLES:
 if choice == &"LOYAL": du = -10; ds = +10; dw = +4
 elif choice == &"NEUTRAL":du = -5; ds = +5; dw = +2
 else: du = +12; ds = -10; dw = -4
 ACTION\_REPARATIONS:
 # pousse la sortie de guerre
 if choice == &"LOYAL": du = -6; ds = +4; dw = +12
 elif choice == &"NEUTRAL":du = -3; ds = +2; dw = +6
 else: du = +6; ds = -5; dw = -6
 \_:
 pass

 domestic\_state.unrest = int(clampi(domestic\_state.unrest + du, 0, 100))
 domestic\_state.stability = int(clampi(domestic\_state.stability + ds, 0, 100))
 domestic\_state.war\_support = int(clampi(domestic\_state.war\_support + dw, 0, 100))


static func \_build\_template\_fallback(id: StringName, tier: int, expires\_in\_days: int):
 var t := QuestTemplate.new()
 t.id = id
 t.title = String(id)
 t.description = "Domestic offer: %s" % String(id)
 t.category = &"DOMESTIC"
 t.tier = tier
 t.objective\_type = &"GENERIC"
 t.objective\_target = &""
 t.objective\_count = 1
 t.expires\_in\_days = expires\_in\_days
 return t
```


---


## 2) Mini factory TRUCE (pour le test)


```
# ArcTruceOfferFactory.gd (mini pour test)

class\_name ArcTruceOfferFactory
extends RefCounted

static func spawn\_truce\_offer\_if\_needed(
 faction\_id: StringName,
 target\_id: StringName,
 domestic\_state,
 day: int,
 quest\_pool,
 arc\_notebook = null
):
 var p := float(domestic\_state.pressure())
 if p < 0.65 and int(domestic\_state.war\_support) > 25:
 return null

 # cooldown simple
 if arc\_notebook != null and arc\_notebook.has\_method("can\_spawn\_truce\_offer"):
 if not arc\_notebook.can\_spawn\_truce\_offer(faction\_id, target\_id, day, 6):
 return null

 var template := DomesticOfferFactory.\_build\_template\_fallback(&"arc.truce\_talks", 2, 6)
 template.category = &"ARC"

 var ctx := {
 "is\_arc\_offer": true,
 "arc\_action\_type": &"arc.truce\_talks",
 "giver\_faction\_id": faction\_id,
 "antagonist\_faction\_id": target\_id,
 "tier": 2,
 "expires\_in\_days": 6,
 }

 var inst := QuestInstance.new(template, ctx)
 inst.status = "AVAILABLE"
 inst.started\_on\_day = day
 inst.expires\_on\_day = day + 6

 if quest\_pool != null and quest\_pool.has\_method("try\_add\_offer"):
 if not quest\_pool.try\_add\_offer(inst):
 return null

 if arc\_notebook != null and arc\_notebook.has\_method("mark\_truce\_offer\_spawned"):
 arc\_notebook.mark\_truce\_offer\_spawned(faction\_id, target\_id, day)

 return inst
```


---


## 3) Mini test : “20 jours de guerre ⇒ TRUCE + domestic apparaissent”


```
extends Node
class\_name DomesticPressureOffers20DaysTest

class TestQuestPool:
 var offers: Array = []
 func try\_add\_offer(inst) -> bool:
 offers.append(inst)
 return true

class TestArcNotebook:
 var last\_domestic: Dictionary = {}
 var last\_truce: Dictionary = {}
 var faction\_counters: Dictionary = {}

 func can\_spawn\_domestic\_offer(faction\_id: StringName, day: int, cooldown: int) -> bool:
 return (day - int(last\_domestic.get(faction\_id, -999999))) >= cooldown
 func mark\_domestic\_offer\_spawned(faction\_id: StringName, day: int) -> void:
 last\_domestic[faction\_id] = day

 func can\_spawn\_truce\_offer(a: StringName, b: StringName, day: int, cooldown: int) -> bool:
 var k := StringName(String(a) + "|" + String(b))
 return (day - int(last\_truce.get(k, -999999))) >= cooldown
 func mark\_truce\_offer\_spawned(a: StringName, b: StringName, day: int) -> void:
 var k := StringName(String(a) + "|" + String(b))
 last\_truce[k] = day

 func set\_faction\_counter(fid: StringName, name: StringName, val: int) -> void:
 if not faction\_counters.has(fid):
 faction\_counters[fid] = {}
 faction\_counters[fid][name] = val
 func get\_faction\_counter(fid: StringName, name: StringName, default\_val: int = 0) -> int:
 if not faction\_counters.has(fid): return default\_val
 return int(faction\_counters[fid].get(name, default\_val))


class FactionDomesticState:
 var stability: int = 70
 var war\_support: int = 75
 var unrest: int = 10
 func pressure() -> float:
 return clampf(0.55*(1.0 - war\_support/100.0) + 0.45*(unrest/100.0), 0.0, 1.0)

class FactionEconomy:
 var gold: int = 120


func \_ready() -> void:
 \_test\_20\_days\_war\_support\_drops\_and\_spawns\_truce\_and\_domestic()
 print("\n✅ DomesticPressureOffers20DaysTest: OK\n")
 get\_tree().quit()


func \_test\_20\_days\_war\_support\_drops\_and\_spawns\_truce\_and\_domestic() -> void:
 var A := &"A"
 var B := &"B"

 var dom := FactionDomesticState.new()
 var eco := FactionEconomy.new()
 var pool := TestQuestPool.new()
 var nb := TestArcNotebook.new()

# simulate "20 days of war" via war\_days\_rolling\_30 counter + tick\_domestic

 var relations := {A: {B: FactionRelationScore.new()}} # minimal (not used by tick in this test)
 var profile := {"personality": {&"diplomacy": 0.3, &"honor": 0.5, &"belligerence": 0.7, &"fear": 0.6}}
 var world := {"crisis\_active": false}

 var saw\_domestic := false
 var saw\_truce := false

 for day in range(1, 21):
 # “guerre continue” : 1..20
 nb.set\_faction\_counter(A, &"war\_days\_rolling\_30", day)

# tick domestic pressure

 DomesticPressureUtil.tick\_domestic(day, A, dom, profile, eco, nb, relations, world)

# spawn domestic offer if needed

 var inst\_dom = DomesticOfferFactory.spawn\_offer\_if\_needed(A, dom, day, pool, nb, eco, {"cooldown\_days": 3})
 if inst\_dom != null:
 saw\_domestic = true

 # spawn truce if needed (linked to domestic pressure/war\_support)
 var inst\_truce = ArcTruceOfferFactory.spawn\_truce\_offer\_if\_needed(A, B, dom, day, pool, nb)
 if inst\_truce != null:
 saw\_truce = true

 # Assertions
 \_assert(dom.war\_support <= 35, "war\_support should drop significantly after 20 war days (got %d)" % dom.war\_support)
 \_assert(saw\_domestic, "should spawn at least one domestic offer within 20 war days")
 \_assert(saw\_truce, "should spawn at least one TRUCE offer when pressure high / war\_support low")

# Bonus: ensure we really have both types in pool

 var dom\_count := 0
 var truce\_count := 0
 for inst in pool.offers:
 if bool(inst.context.get("is\_domestic\_offer", false)): dom\_count += 1
 if StringName(inst.context.get("arc\_action\_type", &"")) == &"arc.truce\_talks": truce\_count += 1

 \_assert(dom\_count >= 1, "pool should contain domestic offers")
 \_assert(truce\_count >= 1, "pool should contain truce offers")


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


Si tu veux ensuite : je te propose le hook “propre” dans ton **GoalPlanner** : quand `domestic.pressure() > 0.7`, on force le goal **TRUCE/REPARATIONS**, et on réduit automatiquement les budgets d’actions offensivesTF (ça stabilise énormément les sorties de guerre).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 14](#toc-detail-ch14)
<a id="moi-90"></a>
**Moi 90:**
Ok

propose le hook “propre” dans ton
<a id="cite-goalplanner-9cd268-1"></a>GoalPlanner : quand domestic.pressure() > 0.7, on force le goal TRUCE/REPARATIONS, et on réduit automatiquement les budgets d’actions offensivesTF (ça stabilise énormément les sorties de guerre).


**ChatGPT:**
Voici un **hook “propre”** (MVP) pour ton **GoalPlanner** : quand `domestic.pressure() > 0.7`, on **force TRUCE/REPARATIONS** et on **réduit automatiquement le budget offensif** (sans casser ton système existant).


L’idée : tu ajoutes une étape “policy gate” juste avant `plan_action(goal)`.


---


## 1) Ajout minimal : `DomesticPolicyGate.apply(...)`


```
# DomesticPolicyGate.gd

class\_name DomesticPolicyGate
extends RefCounted

static func apply(
 faction\_id: StringName,
 goal: Dictionary, # ton goal courant (ou un objet)
 ctx: Dictionary, # world sim ctx / planner ctx
 domestic\_state, # FactionDomesticState
 params: Dictionary = {}
) -> Dictionary:
 var p := float(domestic\_state.pressure())
 var threshold := float(params.get("pressure\_threshold", 0.7))

# Nothing to do

 if p < threshold:
 return goal

 # 1) Force goal TRUCE/REPARATIONS (mais réversible)

# On met en "suspended\_goal" l'objectif précédent pour y revenir plus tard.

 if not goal.has("suspended\_goal"):
 goal["suspended\_goal"] = goal.duplicate(true)

 goal["type"] = &"TRUCE" # ou &"REPARATIONS"
 goal["reason"] = &"DOMESTIC\_PRESSURE"
 goal["until\_day"] = int(ctx.get("day", 0)) + int(params.get("force\_days", 7))

# 2) Réduire budgets offensifs (0..1 multiplier)

 var min\_mult := float(params.get("min\_offensive\_budget\_mult", 0.25))
 var mult := clampf(1.0 - 0.85*(p - threshold)/(1.0 - threshold), min\_mult, 1.0)

# exemple : on stocke des multiplicateurs que le planner utilisera

 ctx["budget\_mult\_offensive"] = mult
 ctx["budget\_mult\_defensive"] = max(0.8, mult + 0.35)

# on garde de la défense

 ctx["prefer\_actions"] = [&"arc.truce\_talks", &"arc.reparations", &"domestic.maintain\_order", &"domestic.appease\_nobles"]

 return goal
```


---


## 2) Hook dans ton `FactionGoalPlanner.plan_action(goal, ctx)`


Juste avant la sélection d’action :


```
# FactionGoalPlanner.gd (extrait)

func plan\_action(goal: Dictionary, ctx: Dictionary) -> Dictionary:
 var fid: StringName = ctx["faction\_id"]
 var domestic\_state = ctx.get("domestic\_state", null)
 if domestic\_state != null:
 goal = DomesticPolicyGate.apply(fid, goal, ctx, domestic\_state, {
 "pressure\_threshold": 0.7,
 "force\_days": 7,
 "min\_offensive\_budget\_mult": 0.25
 })

# ... ensuite ton choix d'action normal

 # mais en tenant compte de ctx["budget\_mult\_offensive"] si présent
 return \_plan\_action\_core(goal, ctx)
```


---


## 3) Réduction du budget offensif (intégration simple)


Si tu as déjà un budget “points” (actions par jour/semaine), tu appliques un multiplicateur **uniquement sur les actions offensives** :


```
func \_can\_afford\_action(action: StringName, base\_cost: int, ctx: Dictionary) -> bool:
 var budget := int(ctx.get("budget\_points", 0))
 var off\_mult := float(ctx.get("budget\_mult\_offensive", 1.0))

 var cost := base\_cost
 if \_is\_offensive(action):
 cost = int(ceil(float(base\_cost) / max(0.01, off\_mult)))

# offensif devient "plus cher"

 return budget >= cost
```


>
> Variante plus intuitive : au lieu de rendre l’offensif plus cher, tu réduis le budget disponible pour offensif. Mais “cost inflation” est simple et stable.
>
>
>


---


## 4) Revenir au goal précédent (éviter blocage en TRUCE)


Dans ton tick daily (GoalManagerRunner), juste avant `ensure_goal()` :


```
func maybe\_restore\_suspended\_goal(goal: Dictionary, ctx: Dictionary, domestic\_state) -> Dictionary:
 if not goal.has("suspended\_goal"):
 return goal
 var day := int(ctx.get("day", 0))
 var until := int(goal.get("until\_day", 0))
 var p := float(domestic\_state.pressure())
 if day >= until and p < 0.62:
 return goal["suspended\_goal"]
 return goal
```


Et tu l’appelles avant planification.


---


## 5) Effet gameplay (ce que ça change concrètement)


* Quand la pression interne monte, la faction :
	+ génère des offers **trêve / réparations / maintien de l’ordre**,
	+ **réduit mécaniquement** la fréquence des raids/guerre,
	+ “sort” de la guerre sans que tu aies besoin de scripts spéciaux.


Si tu veux, prochaine brique logique : un mini test “pressure gate” qui simule `pressure>0.7` et vérifie que `goal.type` est forcé en TRUCE + que le coût offensif est effectivement augmenté (ou le budget réduit).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 14](#toc-detail-ch14)
<a id="moi-91"></a>
**Moi 91:**
Ok

prochaine brique logique : un mini test “pressure gate” qui simule pressure>0.7 et vérifie que goal.type est forcé en TRUCE + que le coût offensif est effectivement augmenté (ou le budget réduit).


**ChatGPT:**
Voici un mini test **“pressure gate”** qui :


1) simule `pressure > 0.7`

2) vérifie que `goal.type` est forcé en `TRUCE`

3) vérifie que `ctx["budget_mult_offensive"] < 1.0`

4) vérifie qu’un **coût offensif est effectivement augmenté** via `_can_afford_action()` (inflation de coût)


---


## `tests/DomesticPressureGateTest.gd`


```
extends Node
class\_name DomesticPressureGateTest

# ---- minimal domestic state ----

class FactionDomesticState:
 var stability: int = 40
 var war\_support: int = 15
 var unrest: int = 85
 func pressure() -> float:
 return clampf(0.55*(1.0 - war\_support/100.0) + 0.45*(unrest/100.0), 0.0, 1.0)

# ---- minimal policy gate (use your real DomesticPolicyGate if available) ----

class DomesticPolicyGate:
 static func apply(faction\_id: StringName, goal: Dictionary, ctx: Dictionary, domestic\_state, params: Dictionary = {}) -> Dictionary:
 var p := float(domestic\_state.pressure())
 var threshold := float(params.get("pressure\_threshold", 0.7))
 if p < threshold:
 return goal

 if not goal.has("suspended\_goal"):
 goal["suspended\_goal"] = goal.duplicate(true)

 goal["type"] = &"TRUCE"
 goal["reason"] = &"DOMESTIC\_PRESSURE"
 goal["until\_day"] = int(ctx.get("day", 0)) + int(params.get("force\_days", 7))

 var min\_mult := float(params.get("min\_offensive\_budget\_mult", 0.25))
 var mult := clampf(1.0 - 0.85*(p - threshold)/(1.0 - threshold), min\_mult, 1.0)

 ctx["budget\_mult\_offensive"] = mult
 ctx["budget\_mult\_defensive"] = max(0.8, mult + 0.35)
 ctx["prefer\_actions"] = [&"arc.truce\_talks", &"arc.reparations", &"domestic.maintain\_order"]

 return goal

# ---- minimal affordability check with offensive cost inflation ----

func \_is\_offensive(action: StringName) -> bool:
 return action == &"arc.raid" or action == &"arc.declare\_war" or action == &"arc.sabotage"

func \_can\_afford\_action(action: StringName, base\_cost: int, ctx: Dictionary) -> bool:
 var budget := int(ctx.get("budget\_points", 0))
 var off\_mult := float(ctx.get("budget\_mult\_offensive", 1.0))
 var cost := base\_cost
 if \_is\_offensive(action):
 cost = int(ceil(float(base\_cost) / max(0.01, off\_mult)))
 return budget >= cost


func \_ready() -> void:
 \_test\_pressure\_gate\_forces\_truce\_and\_inflates\_offensive\_cost()
 print("\n✅ DomesticPressureGateTest: OK\n")
 get\_tree().quit()


func \_test\_pressure\_gate\_forces\_truce\_and\_inflates\_offensive\_cost() -> void:
 var domestic := FactionDomesticState.new()
 var ctx := {"day": 10, "faction\_id": &"A", "budget\_points": 10, "domestic\_state": domestic}
 var goal := {"type": &"WAR", "target\_id": &"B"}

 var p := domestic.pressure()
 \_assert(p > 0.7, "precondition: pressure must be > 0.7 (got %.3f)" % p)

 goal = DomesticPolicyGate.apply(&"A", goal, ctx, domestic, {
 "pressure\_threshold": 0.7,
 "force\_days": 7,
 "min\_offensive\_budget\_mult": 0.25
 })

# 1) goal forced to TRUCE

 \_assert(StringName(goal.get("type", &"")) == &"TRUCE", "goal.type should be forced to TRUCE under high pressure")
 \_assert(goal.has("suspended\_goal"), "goal should keep suspended\_goal for later restore")

# 2) offensive budget multiplier reduced

 var mult := float(ctx.get("budget\_mult\_offensive", 1.0))
 \_assert(mult < 1.0, "budget\_mult\_offensive should be < 1.0 under high pressure (got %.3f)" % mult)

# 3) offensive cost inflation makes a previously affordable offensive action unaffordable

 # base\_cost 10, budget 10:
 # without gate => affordable
 var ctx\_no\_gate := {"budget\_points": 10} # no budget\_mult\_offensive => 1.0
 \_assert(\_can\_afford\_action(&"arc.raid", 10, ctx\_no\_gate), "without gate, arc.raid base\_cost=10 should be affordable")

# with gate => cost becomes ceil(10 / mult) >= 11 if mult <= 0.91

 var can\_after := \_can\_afford\_action(&"arc.raid", 10, ctx)
 \_assert(not can\_after, "with gate, arc.raid should become unaffordable due to inflated cost (mult=%.3f)" % mult)

# non-offensive action should remain affordable

 \_assert(\_can\_afford\_action(&"arc.truce\_talks", 4, ctx), "non-offensive action should remain affordable")


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


### Ce que ce test prouve


* le “policy gate” **change le goal** de manière déterministe
* il **réduit la capacité offensive** de façon mécanique, ce qui stabilise les sorties de guerre
* il ne bloque pas la faction (actions non-offensives restent faisables)


Si tu veux, prochaine brique logique : brancher ce gate directement dans ton simulateur (`FactionGoalManagerRunner.ensure_goal` ou `plan_action`) et faire un test d’intégration “20 jours de WAR + pression => plus de raids à partir de J15, mais apparition de trêves/domestic”.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 14](#toc-detail-ch14)
<a id="moi-92"></a>
**Moi 92:**
Ok

prochaine brique logique : brancher ce gate directement dans ton simulateur (
<a id="cite-factiongoalmanagerrunner-a52b6d-4"></a>FactionGoalManagerRunner.ensure\_goal ou plan\_action) et faire un test d’intégration “20 jours de WAR + pression => plus de raids à partir de J15, mais apparition de trêves/domestic”.


**ChatGPT:**
Voilà le **branching “propre”** dans ton simulateur + un **test d’intégration** “20 jours WAR + pression ⇒ plus de raids après J15, mais des offres TRUCE + domestic apparaissent”.


---


## 1) Hook dans le simulateur


### Option A (recommandée) : dans `FactionGoalPlanner.plan_action(goal, ctx)`


Tu forces *temporairement* le goal (sans casser ta machine de goals) et tu poses les multiplicateurs de budget.


```
# FactionGoalPlanner.gd

func plan\_action(goal: Dictionary, ctx: Dictionary) -> Dictionary:
 var fid: StringName = ctx["faction\_id"]
 var dom = ctx.get("domestic\_state", null)
 if dom != null:
 goal = DomesticPolicyGate.apply(fid, goal, ctx, dom, {
 "pressure\_threshold": 0.7,
 "force\_days": 7,
 "min\_offensive\_budget\_mult": 0.25
 })

# ... ton code normal

 return \_plan\_action\_core(goal, ctx)
```


Et dans ton check budget (ou coût), applique l’inflation offensive :


```
func \_can\_afford\_action(action: StringName, base\_cost: int, ctx: Dictionary) -> bool:
 var budget := int(ctx.get("budget\_points", 0))
 var mult := float(ctx.get("budget\_mult\_offensive", 1.0))
 var cost := base\_cost
 if \_is\_offensive(action):
 cost = int(ceil(float(base\_cost) / max(0.01, mult)))
 return budget >= cost
```


### Option B (en plus) : dans `ensure_goal` (si tu veux que le goal “visible” soit TRUCE)


Avant de renvoyer le goal :


```
# FactionGoalManagerRunner.gd

func ensure\_goal(fid: StringName, ctx: Dictionary) -> Dictionary:
 var goal := \_get\_or\_create\_goal(fid, ctx)

 var dom = ctx.get("domestic\_state", null)
 if dom != null:
 goal = maybe\_restore\_suspended\_goal(goal, ctx, dom)
 goal = DomesticPolicyGate.apply(fid, goal, ctx, dom)

 \_set\_goal(fid, goal)
 return goal
```


---


## 2) Test d’intégration


Ce test simule une faction A “en WAR” qui choisit normalement des **raids** tant qu’elle peut les payer, mais dès que la pression dépasse 0.7 (vers J15), le gate force TRUCE + rend les raids inabordables, et on vérifie qu’on spawn bien **TRUCE + domestic**.


>
> Le test suppose que tu as déjà : `DomesticPolicyGate`, `DomesticOfferFactory`, `ArcTruceOfferFactory`, et une classe `FactionDomesticState` (ou équivalent). Ajuste si tes noms diffèrent.
>
>
>


### `tests/IntegrationWarPressureStopsRaidsTest.gd`


```
extends Node
class\_name IntegrationWarPressureStopsRaidsTest

class TestQuestPool:
 var offers: Array = []
 func try\_add\_offer(inst) -> bool:
 offers.append(inst)
 return true

class TestArcNotebook:
 var last\_domestic: Dictionary = {}
 var last\_truce: Dictionary = {}

 func can\_spawn\_domestic\_offer(fid: StringName, day: int, cooldown: int) -> bool:
 return (day - int(last\_domestic.get(fid, -999999))) >= cooldown
 func mark\_domestic\_offer\_spawned(fid: StringName, day: int) -> void:
 last\_domestic[fid] = day

 func can\_spawn\_truce\_offer(a: StringName, b: StringName, day: int, cooldown: int) -> bool:
 var k := StringName(String(a) + "|" + String(b))
 return (day - int(last\_truce.get(k, -999999))) >= cooldown
 func mark\_truce\_offer\_spawned(a: StringName, b: StringName, day: int) -> void:
 var k := StringName(String(a) + "|" + String(b))
 last\_truce[k] = day

# Planner mini (intégration du gate + budget inflation)

class PlannerSim:
 func \_is\_offensive(action: StringName) -> bool:
 return action == &"arc.raid" or action == &"arc.declare\_war" or action == &"arc.sabotage"

 func \_can\_afford(action: StringName, base\_cost: int, ctx: Dictionary) -> bool:
 var budget := int(ctx.get("budget\_points", 0))
 var mult := float(ctx.get("budget\_mult\_offensive", 1.0))
 var cost := base\_cost
 if \_is\_offensive(action):
 cost = int(ceil(float(base\_cost) / max(0.01, mult)))
 return budget >= cost

 func plan\_action(goal: Dictionary, ctx: Dictionary) -> StringName:
 var fid: StringName = ctx["faction\_id"]
 var dom = ctx.get("domestic\_state", null)
 if dom != null:
 goal = DomesticPolicyGate.apply(fid, goal, ctx, dom, {
 "pressure\_threshold": 0.7,
 "force\_days": 7,
 "min\_offensive\_budget\_mult": 0.25
 })

# WAR => préfère raid si possible

 if StringName(goal.get("type", &"")) == &"WAR":
 if \_can\_afford(&"arc.raid", 10, ctx):
 return &"arc.raid"
 return &"arc.defend"

 # TRUCE => truce talks
 if StringName(goal.get("type", &"")) == &"TRUCE":
 return &"arc.truce\_talks"

 return &"arc.idle"


func \_ready() -> void:
 \_test\_20\_days\_war\_pressure\_stops\_raids\_after\_day15\_and\_spawns\_truce\_domestic()
 print("\n✅ IntegrationWarPressureStopsRaidsTest: OK\n")
 get\_tree().quit()


func \_test\_20\_days\_war\_pressure\_stops\_raids\_after\_day15\_and\_spawns\_truce\_domestic() -> void:
 var A := &"A"
 var B := &"B"

 var pool := TestQuestPool.new()
 var nb := TestArcNotebook.new()
 var planner := PlannerSim.new()

# Domestic state (utilise TA classe si tu l’as déjà)

 var dom := FactionDomesticState.new()
 dom.stability = 60
 dom.war\_support = 75
 dom.unrest = 10

 # Economy (optionnel)
 var economy := null
 if Engine.has\_singleton("Dummy"): pass # noop, juste pour éviter warning
 # Si tu as une classe d’économie, branche-la ici; sinon DomesticOfferFactory fallback propaganda.

 # Sim config
 var actions\_by\_day: Dictionary = {}
 var goal := {"type": &"WAR", "target\_id": B}

 # On force une montée déterministe de la pression (sim “guerre longue”)

# => à J15 on passe typiquement > 0.7

 for day in range(1, 21):
 # Approx: chaque jour de guerre, support↓ et unrest↑
 dom.war\_support = int(clampi(dom.war\_support - 4, 0, 100))
 dom.unrest = int(clampi(dom.unrest + 4, 0, 100))

 var ctx := {
 "day": day,
 "faction\_id": A,
 "domestic\_state": dom,
 "budget\_points": 10
 }

 # 1) plan action (gate intégré)
 var act: StringName = planner.plan\_action(goal, ctx)
 actions\_by\_day[day] = act

 # 2) spawn offers : domestic + truce (comme en prod)
 DomesticOfferFactory.spawn\_offer\_if\_needed(A, dom, day, pool, nb, economy, {"cooldown\_days": 3})
 ArcTruceOfferFactory.spawn\_truce\_offer\_if\_needed(A, B, dom, day, pool, nb)

# ---- Assertions ----

 # A) Il y a des raids avant J15 (sinon le test ne prouve rien)
 var raids\_pre := 0
 for day in range(1, 15):
 if actions\_by\_day[day] == &"arc.raid":
 raids\_pre += 1
 \_assert(raids\_pre >= 1, "should have at least one raid before day 15 (got %d)" % raids\_pre)

# B) Plus aucun raid à partir de J15

 for day in range(15, 21):
 \_assert(actions\_by\_day[day] != &"arc.raid", "no raids expected from day 15 (day %d had %s)" % [day, String(actions\_by\_day[day])])

# C) On a au moins une offre TRUCE à partir de J15

 var truce\_offer\_post := 0
 var domestic\_offer\_post := 0
 for inst in pool.offers:
 var sd := int(inst.started\_on\_day) if inst.has\_property("started\_on\_day") else int(inst.context.get("day", 0))
 if sd < 15:
 continue
 if StringName(inst.context.get("arc\_action\_type", &"")) == &"arc.truce\_talks":
 truce\_offer\_post += 1
 if bool(inst.context.get("is\_domestic\_offer", false)):
 domestic\_offer\_post += 1

 \_assert(truce\_offer\_post >= 1, "expected at least one TRUCE offer from day 15+")
 \_assert(domestic\_offer\_post >= 1, "expected at least one DOMESTIC offer from day 15+")

# D) Bonus : pression bien élevée

 \_assert(float(dom.pressure()) > 0.7, "pressure should end above 0.7 (got %.3f)" % float(dom.pressure()))


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


### Pourquoi ce test est utile


* Il valide **l’intégration** (gate → changement de comportement) sans dépendre de tout ton WorldSim.
* Il prouve le point clé : **sortie de guerre organique** (plus de raids) + **apparition d’outils de sortie** (TRUCE + domestic).


Si tu veux, prochaine brique logique : faire la même intégration testée **avec un vrai goal stack** (WAR → TRUCE forcé 7 jours → restore WAR si pressure retombe), pour vérifier la boucle complète “suspended\_goal”.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 14](#toc-detail-ch14)
<a id="moi-93"></a>
**Moi 93:**
Ok

prochaine brique logique : faire la même intégration testée avec un vrai goal stack (WAR → TRUCE forcé 7 jours → restore WAR si pressure retombe), pour vérifier la boucle complète “suspended\_goal”.


**ChatGPT:**
Voici un test d’intégration **avec un vrai goal stack** (via `suspended_goal`) qui vérifie :


* on part en `WAR`
* quand `pressure > 0.7` ⇒ goal forcé `TRUCE` et `suspended_goal` stocké
* après **7 jours** de TRUCE + baisse de pression (`pressure < 0.62`) ⇒ **restaure** le goal `WAR`
* et les actions repartent en `raid` (si budget OK)


---


## `tests/IntegrationGoalStackRestoreTest.gd`


```
extends Node
class\_name IntegrationGoalStackRestoreTest

# --- Minimal domestic state ---

class FactionDomesticState:
 var stability: int = 60
 var war\_support: int = 75
 var unrest: int = 10
 func pressure() -> float:
 return clampf(0.55*(1.0 - war\_support/100.0) + 0.45*(unrest/100.0), 0.0, 1.0)

# --- Gate + restore helpers (use your real ones if available) ---

class DomesticPolicyGate:
 static func apply(faction\_id: StringName, goal: Dictionary, ctx: Dictionary, domestic\_state, params: Dictionary = {}) -> Dictionary:
 var p := float(domestic\_state.pressure())
 var threshold := float(params.get("pressure\_threshold", 0.7))
 if p < threshold:
 return goal

 if not goal.has("suspended\_goal"):
 goal["suspended\_goal"] = goal.duplicate(true)

 goal["type"] = &"TRUCE"
 goal["reason"] = &"DOMESTIC\_PRESSURE"
 goal["until\_day"] = int(ctx.get("day", 0)) + int(params.get("force\_days", 7))

 var min\_mult := float(params.get("min\_offensive\_budget\_mult", 0.25))
 var mult := clampf(1.0 - 0.85*(p - threshold)/(1.0 - threshold), min\_mult, 1.0)
 ctx["budget\_mult\_offensive"] = mult
 return goal

static func maybe\_restore\_suspended\_goal(goal: Dictionary, ctx: Dictionary, domestic\_state) -> Dictionary:
 if not goal.has("suspended\_goal"):
 return goal
 var day := int(ctx.get("day", 0))
 var until := int(goal.get("until\_day", 0))
 var p := float(domestic\_state.pressure())
 if day >= until and p < 0.62:
 return goal["suspended\_goal"]
 return goal


# --- Planner sim using goal stack ---

class PlannerSim:
 func \_is\_offensive(action: StringName) -> bool:
 return action == &"arc.raid"

 func \_can\_afford(action: StringName, base\_cost: int, ctx: Dictionary) -> bool:
 var budget := int(ctx.get("budget\_points", 0))
 var mult := float(ctx.get("budget\_mult\_offensive", 1.0))
 var cost := base\_cost
 if \_is\_offensive(action):
 cost = int(ceil(float(base\_cost) / max(0.01, mult)))
 return budget >= cost

 func plan\_action(goal: Dictionary, ctx: Dictionary) -> StringName:
 # WAR => raid if can
 if StringName(goal.get("type", &"")) == &"WAR":
 return &"arc.raid" if \_can\_afford(&"arc.raid", 10, ctx) else &"arc.defend"
 # TRUCE => talks
 if StringName(goal.get("type", &"")) == &"TRUCE":
 return &"arc.truce\_talks"
 return &"arc.idle"


func \_ready() -> void:
 \_test\_goal\_stack\_war\_to\_truce\_7\_days\_then\_restore\_war()
 print("\n✅ IntegrationGoalStackRestoreTest: OK\n")
 get\_tree().quit()


func \_test\_goal\_stack\_war\_to\_truce\_7\_days\_then\_restore\_war() -> void:
 var A := &"A"
 var B := &"B"

 var dom := FactionDomesticState.new()
 var planner := PlannerSim.new()

 var goal := {"type": &"WAR", "target\_id": B}
 var actions\_by\_day: Dictionary = {}
 var goal\_type\_by\_day: Dictionary = {}

 var saw\_truce := false
 var saw\_restore\_war := false
 var first\_truce\_day := -1

 for day in range(1, 31):
 # --- simulate domestic dynamics ---
 # Phase 1: war fatigue rises until ~day 15
 if day <= 17:
 dom.war\_support = int(clampi(dom.war\_support - 4, 0, 100))
 dom.unrest = int(clampi(dom.unrest + 4, 0, 100))

# Phase 2: after some days of truce + “domestic work”, pressure drops

 else:
 dom.war\_support = int(clampi(dom.war\_support + 5, 0, 100))
 dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

 var ctx := {"day": day, "faction\_id": A, "domestic\_state": dom, "budget\_points": 10}

 # --- restore step (goal stack) ---
 goal = maybe\_restore\_suspended\_goal(goal, ctx, dom)

# --- apply gate (may force TRUCE and attach suspended\_goal) ---

 goal = DomesticPolicyGate.apply(A, goal, ctx, dom, {
 "pressure\_threshold": 0.7,
 "force\_days": 7,
 "min\_offensive\_budget\_mult": 0.25
 })

 goal\_type\_by\_day[day] = StringName(goal.get("type", &""))
 var act: StringName = planner.plan\_action(goal, ctx)
 actions\_by\_day[day] = act

 # record first TRUCE day
 if goal\_type\_by\_day[day] == &"TRUCE" and not saw\_truce:
 saw\_truce = true
 first\_truce\_day = day

 # detect restore WAR after having had TRUCE
 if saw\_truce and goal\_type\_by\_day[day] == &"WAR":
 saw\_restore\_war = true

 # ---- Assertions ----
 \_assert(saw\_truce, "should enter TRUCE at least once due to pressure > 0.7")
 \_assert(first\_truce\_day > 0, "first\_truce\_day should be set")

# A) during forced TRUCE window, actions should be truce talks (not raids)

 var until\_day := first\_truce\_day + 7
 for d in range(first\_truce\_day, min(until\_day + 1, 31)):
 \_assert(goal\_type\_by\_day[d] == &"TRUCE", "goal should stay TRUCE during forced window (day %d)" % d)
 \_assert(actions\_by\_day[d] == &"arc.truce\_talks", "action should be truce talks during TRUCE (day %d)" % d)

# B) after window + pressure drop, we restore WAR

 \_assert(saw\_restore\_war, "should restore suspended WAR after forced TRUCE window if pressure drops")

# C) after restore, raids can happen again (at least once) if budget allows

 var raids\_after\_restore := 0
 for d in range(until\_day + 1, 31):
 if goal\_type\_by\_day[d] == &"WAR" and actions\_by\_day[d] == &"arc.raid":
 raids\_after\_restore += 1
 \_assert(raids\_after\_restore >= 1, "should see raids again after WAR restore (got %d)" % raids\_after\_restore)

# D) pressure should end lower

 \_assert(float(dom.pressure()) < 0.62, "pressure should end below restore threshold (got %.3f)" % float(dom.pressure()))


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


### Ce que ce test valide exactement


* `suspended_goal` est bien utilisé comme “stack”
* la trêve est **temporaire** (7 jours)
* la restauration se fait uniquement si la pression est redescendue (seuil 0.62)
* le simulateur redevient offensif une fois la contrainte levée


Si tu veux, prochaine brique logique : brancher ça *dans tes vraies classes* (`FactionGoalManagerRunner` + `FactionGoalPlanner`) avec un micro patch “non-invasif”, puis un test d’intégration qui utilise tes vrais runners (pas les classes de test).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 14](#toc-detail-ch14)
<a id="moi-94"></a>
**Moi 94:**
Ok

prochaine brique logique : brancher ça dans tes vraies classes (
<a id="cite-factiongoalmanagerrunner-a52b6d-5"></a>FactionGoalManagerRunner +
<a id="cite-factiongoalplanner-73d377-3"></a>FactionGoalPlanner) avec un micro patch “non-invasif”, puis un test d’intégration qui utilise tes vrais runners (pas les classes de test).


**ChatGPT:**
Parfait — voilà un **micro-patch non invasif** (ctx optionnel + goal stack) dans tes **vraies classes** + un **test d’intégration** qui instancie **FactionGoalManagerRunner + FactionGoalPlanner** (pas de planner “fake”).


---


## 1) Micro-patch `FactionGoalManagerRunner.gd`


Objectif :


* garder le comportement actuel si `ctx` est vide
* si `ctx.domestic_state` est présent : **restore suspended\_goal** puis **force TRUCE** si `pressure>0.7`


```
# FactionGoalManagerRunner.gd (extraits à intégrer)

# +++ AJOUTS MINIMAUX +++

# (optionnel) si tu as déjà un dict interne, garde le tien

var goals\_by\_faction: Dictionary = {} # faction\_id -> Dictionary goal

func get\_goal\_state(faction\_id: StringName) -> Dictionary:
 return goals\_by\_faction.get(faction\_id, {})

func set\_goal\_state(faction\_id: StringName, goal: Dictionary) -> void:
 goals\_by\_faction[faction\_id] = goal


# MICRO PATCH : ctx optionnel (ne casse pas les appels existants)

func ensure\_goal(faction\_id: StringName, ctx: Dictionary = {}) -> Dictionary:
 # --- ton code existant pour assurer un goal ---
 # ex:
 # var goal := goals\_by\_faction.get(faction\_id, {})

# if goal.is\_empty(): goal = \_create\_default\_goal(faction\_id)

# ...

 var goal := get\_goal\_state(faction\_id)
 if goal.is\_empty():
 goal = {"type": &"IDLE"} # remplace par ton défaut

 # --- HOOK DOMESTIC PRESSURE (non invasif) ---
 var dom = ctx.get("domestic\_state", null)
 if dom != null:
 # 1) restore (si TRUCE forcée passée et pressure basse)
 goal = DomesticPolicyGate.maybe\_restore\_suspended\_goal(goal, ctx, dom)

# 2) force TRUCE + budget\_mult\_offensive

 goal = DomesticPolicyGate.apply(faction\_id, goal, ctx, dom, {
 "pressure\_threshold": 0.7,
 "force\_days": 7,
 "min\_offensive\_budget\_mult": 0.25
 })

 set\_goal\_state(faction\_id, goal)
 return goal
```


>
> Si ton runner a déjà une structure “goal instance”, adapte juste `get/set_goal_state` pour pointer vers ton stockage actuel.
>
>
>


---


## 2) Micro-patch `FactionGoalPlanner.gd`


Objectif :


* `plan_action(goal, ctx := {})` (ctx optionnel)
* appliquer l’**inflation de coût offensif** via `ctx["budget_mult_offensive"]`


```
# FactionGoalPlanner.gd (extraits à intégrer)

func plan\_action(goal: Dictionary, ctx: Dictionary = {}) -> Variant:
 # (optionnel) safety : si ensure\_goal n’est pas appelé, on garde le gate ici aussi
 var dom = ctx.get("domestic\_state", null)
 if dom != null and StringName(goal.get("reason", &"")) != &"DOMESTIC\_PRESSURE":
 goal = DomesticPolicyGate.apply(StringName(ctx.get("faction\_id", &"")), goal, ctx, dom)

# ... ton code existant de sélection d’action ...

 return \_plan\_action\_core(goal, ctx)

# ---- hook coût (à appeler dans TON calcul de coût existant) ----

func \_inflate\_offensive\_cost\_if\_needed(action\_type: StringName, base\_cost: int, ctx: Dictionary) -> int:
 var mult := float(ctx.get("budget\_mult\_offensive", 1.0))
 if mult >= 0.999:
 return base\_cost
 if \_is\_offensive\_action(action\_type):
 return int(ceil(float(base\_cost) / max(0.01, mult)))
 return base\_cost

func \_is\_offensive\_action(action\_type: StringName) -> bool:
 return action\_type in [&"arc.raid", &"arc.declare\_war", &"arc.sabotage"]
```


>
> Tu l’utilises exactement là où tu fais ton `base_cost` (budget/jour, points/semaine, etc.) :
>
> `cost = _inflate_offensive_cost_if_needed(action_type, cost, ctx)`.
>
>
>


---


## 3) Test d’intégration (vrais runners + goal stack)


Ce test :


* instancie / récupère `/root/FactionGoalManagerRunner` et `/root/FactionGoalPlanner`
* simule 30 jours :
	+ J1–J17 : pression monte (support↓ unrest↑)
	+ J18–J30 : pression baisse (support↑ unrest↓)
* vérifie : **WAR → TRUCE 7 jours → restore WAR**
*
	+ vérifie “plus de raids pendant TRUCE”
*
	+ vérifie “au moins 1 offer TRUCE + 1 offer domestic après J15” (via tes factories)


```
# tests/IntegrationRealRunnersGoalStackTest.gd

extends Node
class\_name IntegrationRealRunnersGoalStackTest

class TestQuestPool:
 var offers: Array = []
 func try\_add\_offer(inst) -> bool:
 offers.append(inst)
 return true

class TestArcNotebook:
 var last\_domestic := {}
 var last\_truce := {}
 func can\_spawn\_domestic\_offer(fid: StringName, day: int, cooldown: int) -> bool:
 return (day - int(last\_domestic.get(fid, -999999))) >= cooldown
 func mark\_domestic\_offer\_spawned(fid: StringName, day: int) -> void:
 last\_domestic[fid] = day
 func can\_spawn\_truce\_offer(a: StringName, b: StringName, day: int, cooldown: int) -> bool:
 var k := StringName(String(a) + "|" + String(b))
 return (day - int(last\_truce.get(k, -999999))) >= cooldown
 func mark\_truce\_offer\_spawned(a: StringName, b: StringName, day: int) -> void:
 var k := StringName(String(a) + "|" + String(b))
 last\_truce[k] = day

# utilise ta vraie classe si elle existe déjà; sinon garde ce mini state

class FactionDomesticState:
 var stability: int = 60
 var war\_support: int = 75
 var unrest: int = 10
 func pressure() -> float:
 return clampf(0.55*(1.0 - war\_support/100.0) + 0.45*(unrest/100.0), 0.0, 1.0)

func \_ready() -> void:
 \_test\_real\_runners\_goal\_stack\_restore()
 print("\n✅ IntegrationRealRunnersGoalStackTest: OK\n")
 get\_tree().quit()

func \_test\_real\_runners\_goal\_stack\_restore() -> void:
 var A := &"A"
 var B := &"B"

 # --- récupérer ou instancier les vrais runners ---
 var runner = get\_node\_or\_null("/root/FactionGoalManagerRunner")
 if runner == null:
 runner = FactionGoalManagerRunner.new()
 add\_child(runner)

 var planner = get\_node\_or\_null("/root/FactionGoalPlanner")
 if planner == null:
 planner = FactionGoalPlanner.new()
 add\_child(planner)

# --- init goal WAR ---

 runner.set\_goal\_state(A, {"type": &"WAR", "target\_id": B})

 var dom := FactionDomesticState.new()
 var pool := TestQuestPool.new()
 var nb := TestArcNotebook.new()

 var first\_truce\_day := -1
 var until\_day := -1
 var saw\_restore\_war := false
 var raids\_after\_restore := 0

 for day in range(1, 31):
 # domestic dynamics
 if day <= 17:
 dom.war\_support = int(clampi(dom.war\_support - 4, 0, 100))
 dom.unrest = int(clampi(dom.unrest + 4, 0, 100))
 else:
 dom.war\_support = int(clampi(dom.war\_support + 5, 0, 100))
 dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

 var ctx := {
 "day": day,
 "faction\_id": A,
 "domestic\_state": dom,
 "budget\_points": 10
 }

 var goal := runner.ensure\_goal(A, ctx)
 var goal\_type: StringName = StringName(goal.get("type", &""))

# action via vrai planner

 var act\_v = planner.plan\_action(goal, ctx)
 var action\_type: StringName = act\_v if act\_v is StringName else StringName(act\_v.get("type", &""))

# offers (comme ta boucle monde le ferait)

 DomesticOfferFactory.spawn\_offer\_if\_needed(A, dom, day, pool, nb, null, {"cooldown\_days": 3})
 ArcTruceOfferFactory.spawn\_truce\_offer\_if\_needed(A, B, dom, day, pool, nb)

 if goal\_type == &"TRUCE" and first\_truce\_day < 0:
 first\_truce\_day = day
 until\_day = int(goal.get("until\_day", day + 7))

 if first\_truce\_day > 0 and day >= first\_truce\_day and day <= until\_day:
 \_assert(goal\_type == &"TRUCE", "goal must stay TRUCE during forced window (day %d)" % day)
 \_assert(action\_type == &"arc.truce\_talks", "no raids during TRUCE (day %d had %s)" % [day, String(action\_type)])

 if first\_truce\_day > 0 and day > until\_day and goal\_type == &"WAR":
 saw\_restore\_war = true
 if action\_type == &"arc.raid":
 raids\_after\_restore += 1

 # --- asserts ---
 \_assert(first\_truce\_day > 0, "should enter TRUCE at least once")
 \_assert(saw\_restore\_war, "should restore WAR after TRUCE window when pressure drops")
 \_assert(raids\_after\_restore >= 1, "should see raids again after restore (got %d)" % raids\_after\_restore)

# offers post J15

 var truce\_offers := 0
 var domestic\_offers := 0
 for inst in pool.offers:
 if int(inst.started\_on\_day) < 15:
 continue
 if StringName(inst.context.get("arc\_action\_type", &"")) == &"arc.truce\_talks":
 truce\_offers += 1
 if bool(inst.context.get("is\_domestic\_offer", false)):
 domestic\_offers += 1

 \_assert(truce\_offers >= 1, "expected >=1 TRUCE offer after day 15")
 \_assert(domestic\_offers >= 1, "expected >=1 DOMESTIC offer after day 15")

func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


Si tu veux une version encore plus “100% vraie boucle monde”, je peux aussi te proposer un micro-patch `FactionGoalManagerRunner.tick_day(faction_id, ctx)` qui appelle `ensure_goal → plan_action → apply → spawn offers`, mais là on dépasse un peu le “non-invasif”.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 14](#toc-detail-ch14)
<a id="moi-95"></a>
**Moi 95:**
Ok pour

version encore plus “100% vraie boucle monde”, je peux aussi te proposer un micro-patch
<a id="cite-factiongoalmanagerrunner-a52b6d-6"></a>FactionGoalManagerRunner.tick\_day(faction\_id, ctx) qui appelle ensure\_goal → plan\_action → apply → spawn offers, mais là on dépasse un peu le “non-invasif”.


**ChatGPT:**
Voici une version **“100% vraie boucle monde”** avec un **micro-patch** `FactionGoalManagerRunner.tick_day(faction_id, ctx)` qui enchaîne :


`ensure_goal → planner.plan_action → apply_action → spawn_offers`


…tout en restant **non-invasif** : si tu ne l’appelles pas, rien ne change.


---


## 1) Micro-patch `FactionGoalManagerRunner.tick_day(...)`


```
# FactionGoalManagerRunner.gd

# +++ AJOUT NON INVASIF +++

# Dépendances injectables (pour test et prod)

@export var planner\_path: NodePath = NodePath("/root/FactionGoalPlanner")
@export var quest\_pool\_path: NodePath = NodePath("/root/QuestPool")
@export var arc\_notebook\_path: NodePath = NodePath("/root/ArcManagerRunner")

# ou ArcNotebook direct si tu l’as en singleton

# Optionnel : si tu as déjà un economy runner / faction registry

@export var economy\_runner\_path: NodePath = NodePath("")

func tick\_day(faction\_id: StringName, ctx: Dictionary = {}) -> Dictionary:
 # 0) Resolve deps (fallback soft)
 var planner = get\_node\_or\_null(planner\_path)
 var quest\_pool = get\_node\_or\_null(quest\_pool\_path)

 var arc\_notebook = null
 var arc\_mgr = get\_node\_or\_null(arc\_notebook\_path)
 if arc\_mgr != null and arc\_mgr.has\_variable("arc\_notebook"):
 arc\_notebook = arc\_mgr.arc\_notebook
 elif arc\_mgr != null and arc\_mgr.has\_method("get\_arc\_notebook"):
 arc\_notebook = arc\_mgr.get\_arc\_notebook()

 var economy = null
 var econ\_runner = (economy\_runner\_path != NodePath("")) ? get\_node\_or\_null(economy\_runner\_path) : null
 if econ\_runner != null and econ\_runner.has\_method("get\_economy"):
 economy = econ\_runner.get\_economy(faction\_id)

# 1) Ensure goal (includes restore + domestic gate if ctx has domestic\_state)

 ctx["faction\_id"] = faction\_id
 var goal := ensure\_goal(faction\_id, ctx)

# 2) Plan action

 var action = null
 if planner != null and planner.has\_method("plan\_action"):
 action = planner.plan\_action(goal, ctx)
 else:
 action = {"type": &"arc.idle"}

 var action\_type: StringName = action if action is StringName else StringName(action.get("type", &"arc.idle"))

# 3) Apply action (MVP no-op unless you already have apply methods)

# Ici tu branches ton apply réel:

 # - decrement budget
 # - record event in ArcNotebook
 # - modify relations/tags/goals
 if has\_method("\_apply\_planned\_action"):
 \_apply\_planned\_action(faction\_id, action, ctx)
 elif arc\_notebook != null and arc\_notebook.has\_method("record\_faction\_action"):
 arc\_notebook.record\_faction\_action({
 "day": int(ctx.get("day", 0)),
 "faction\_id": faction\_id,
 "action": action\_type
 })

# 4) Spawn offers from domestic + (optionnel) truce push

 # Domestic offer (pressure/unrest)
 if ctx.has("domestic\_state") and quest\_pool != null:
 DomesticOfferFactory.spawn\_offer\_if\_needed(
 faction\_id,
 ctx["domestic\_state"],
 int(ctx.get("day", 0)),
 quest\_pool,
 arc\_notebook,
 economy,
 {"cooldown\_days": 3}
 )

# TRUCE offer if pressure high (simple hook)

 if ctx.has("domestic\_state") and quest\_pool != null and goal.get("type", &"") == &"TRUCE":
 var target\_id: StringName = StringName(goal.get("target\_id", &""))
 if target\_id != &"":
 ArcTruceOfferFactory.spawn\_truce\_offer\_if\_needed(
 faction\_id,
 target\_id,
 ctx["domestic\_state"],
 int(ctx.get("day", 0)),
 quest\_pool,
 arc\_notebook
 )

# 5) Return a summary (useful for tests/metrics)

 return {
 "goal": goal,
 "action": action,
 "action\_type": action\_type
 }
```


### Pourquoi c’est “non invasif”


* tu ajoutes une **nouvelle méthode**, tu ne modifies pas ton pipeline existant
* elle appelle des hooks “soft” (`_apply_planned_action` si tu l’as, sinon no-op + record)
* tu peux l’utiliser seulement dans le WorldSim, ou juste dans les tests


---


## 2) Test d’intégration “vraie boucle monde” (avec `tick_day`)


Ce test appelle `runner.tick_day(A, ctx)` sur 30 jours, comme une vraie boucle.


```
# tests/IntegrationRealWorldLoopTickDayTest.gd

extends Node
class\_name IntegrationRealWorldLoopTickDayTest

class TestQuestPool:
 var offers: Array = []
 func try\_add\_offer(inst) -> bool:
 offers.append(inst)
 return true

class TestArcManagerRunner:
 var arc\_notebook := TestArcNotebook.new()

class TestArcNotebook:
 var last\_domestic := {}
 var last\_truce := {}
 func can\_spawn\_domestic\_offer(fid: StringName, day: int, cooldown: int) -> bool:
 return (day - int(last\_domestic.get(fid, -999999))) >= cooldown
 func mark\_domestic\_offer\_spawned(fid: StringName, day: int) -> void:
 last\_domestic[fid] = day
 func can\_spawn\_truce\_offer(a: StringName, b: StringName, day: int, cooldown: int) -> bool:
 var k := StringName(String(a) + "|" + String(b))
 return (day - int(last\_truce.get(k, -999999))) >= cooldown
 func mark\_truce\_offer\_spawned(a: StringName, b: StringName, day: int) -> void:
 var k := StringName(String(a) + "|" + String(b))
 last\_truce[k] = day

class FactionDomesticState:
 var stability: int = 60
 var war\_support: int = 75
 var unrest: int = 10
 func pressure() -> float:
 return clampf(0.55*(1.0 - war\_support/100.0) + 0.45*(unrest/100.0), 0.0, 1.0)

func \_ready() -> void:
 \_test\_tick\_day\_loop\_goal\_stack\_and\_offers()
 print("\n✅ IntegrationRealWorldLoopTickDayTest: OK\n")
 get\_tree().quit()

func \_test\_tick\_day\_loop\_goal\_stack\_and\_offers() -> void:
 var A := &"A"
 var B := &"B"

 # Real runner + planner nodes
 var runner = get\_node\_or\_null("/root/FactionGoalManagerRunner")
 if runner == null:
 runner = FactionGoalManagerRunner.new()
 runner.name = "FactionGoalManagerRunner"
 add\_child(runner)

 var planner = get\_node\_or\_null("/root/FactionGoalPlanner")
 if planner == null:
 planner = FactionGoalPlanner.new()
 planner.name = "FactionGoalPlanner"
 add\_child(planner)

# Inject test QuestPool + ArcManagerRunner (to provide arc\_notebook)

 var qp = TestQuestPool.new()
 var qp\_node := Node.new()
 qp\_node.name = "QuestPool"
 # expose try\_add\_offer
 qp\_node.set\_script(qp.get\_script())

# if your test pool is a script, else skip

 # simpler: just add as child and access directly below
 add\_child(qp\_node)

 var arc\_runner := TestArcManagerRunner.new()
 var arc\_node := Node.new()
 arc\_node.name = "ArcManagerRunner"
 arc\_node.set\_script(arc\_runner.get\_script())
 add\_child(arc\_node)

# Directly set paths to our test nodes (safer than default /root paths)

 runner.planner\_path = planner.get\_path()
 runner.quest\_pool\_path = qp\_node.get\_path()
 runner.arc\_notebook\_path = arc\_node.get\_path()

# Init goal WAR

 runner.set\_goal\_state(A, {"type": &"WAR", "target\_id": B})

 var dom := FactionDomesticState.new()
 var first\_truce\_day := -1
 var until\_day := -1
 var saw\_restore\_war := false

 # We'll log action types
 var actions: Dictionary = {}

 for day in range(1, 31):
 # domestic dynamics
 if day <= 17:
 dom.war\_support = int(clampi(dom.war\_support - 4, 0, 100))
 dom.unrest = int(clampi(dom.unrest + 4, 0, 100))
 else:
 dom.war\_support = int(clampi(dom.war\_support + 5, 0, 100))
 dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

 var ctx := {"day": day, "domestic\_state": dom}
 var out: Dictionary = runner.tick\_day(A, ctx)

 var goal: Dictionary = out["goal"]
 var gt: StringName = StringName(goal.get("type", &""))
 var at: StringName = StringName(out.get("action\_type", &""))
 actions[day] = at

 if gt == &"TRUCE" and first\_truce\_day < 0:
 first\_truce\_day = day
 until\_day = int(goal.get("until\_day", day + 7))

 if first\_truce\_day > 0 and day > until\_day and gt == &"WAR":
 saw\_restore\_war = true

 # Assertions: no raids during truce window
 \_assert(first\_truce\_day > 0, "should enter TRUCE at least once")
 for d in range(first\_truce\_day, min(until\_day + 1, 31)):
 \_assert(actions[d] != &"arc.raid", "no raids during forced TRUCE (day %d had raid)" % d)

 \_assert(saw\_restore\_war, "should restore WAR after TRUCE if pressure drops")

# Offers check: this depends on your QuestPool wiring; if qp\_node isn't truly a pool, validate via factories separately.

 # If you wire a real QuestPool node, assert at least one domestic and one truce offer exist post day 15.

func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


### Petite note pratique sur le test


Le test ci-dessus montre le principe “tick\_day réel”, mais **le wiring d’un faux QuestPool comme Node** est pénible en GDScript pur si tu n’as pas une interface stable (script attaché, etc.).


👉 La version la plus propre (et 100% “real”) est :


* soit tu utilises ton **vrai QuestPool autoload** et tu le reset en début de test,
* soit tu ajoutes un champ optionnel `quest_pool_override` dans `ctx` (non invasif) pour injecter un stub **sans bidouiller NodePath**.


Si tu veux, je te donne le micro-patch minimal :

`var quest_pool = ctx.get("quest_pool_override", get_node_or_null(quest_pool_path))`

…et le test devient trivial et *vraiment* intégration “tick\_day” + pool.


Tu préfères quel style : **utiliser tes autoloads réels** (reset propre), ou **override via ctx** (plus simple et stable pour tests) ?


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 14](#toc-detail-ch14)
<a id="moi-96"></a>
**Moi 96:**
utiliser tes autoloads réels


**ChatGPT:**
Parfait — si on veut **utiliser les autoloads réels**, la clé c’est : **(1) un tick\_day qui va chercher /root/**, et **(2) un test qui “snapshoote + reset” proprement** l’état des singletons qu’il touche, puis restaure à la fin.


Je te donne ci-dessous :


1) un `tick_day(...)` version autoloads (pas d’injection)

2) un **test d’intégration** “20–30 jours WAR → pression → TRUCE → restore” qui **utilise tes vrais autoloads** et qui nettoie l’état avant/après.


---


## 1) `FactionGoalManagerRunner.tick_day()` version autoloads réels


```
# FactionGoalManagerRunner.gd

# +++ AJOUT NON INVASIF +++

func tick\_day(faction\_id: StringName, ctx: Dictionary = {}) -> Dictionary:
 ctx["faction\_id"] = faction\_id
 var day := int(ctx.get("day", 0))

# Autoloads attendus

 var planner = get\_node\_or\_null("/root/FactionGoalPlanner")
 if planner == null:
 planner = get\_node\_or\_null("/root/FactionGoalPlannerRunner")

# fallback si tu as renommé

 # Ton “pool d’offres” peut s’appeler différemment selon ton projet.
 # On cherche un autoload qui a try\_add\_offer(inst).
 var offer\_sink: Node = null
 for n in ["QuestPool", "QuestOfferSimRunner", "QuestOfferPool", "QuestOffers"]:
 var cand = get\_node\_or\_null("/root/" + n)
 if cand != null and cand.has\_method("try\_add\_offer"):
 offer\_sink = cand
 break

 # ArcNotebook si dispo (pour cooldown/refresh/debug)
 var arc\_mgr = get\_node\_or\_null("/root/ArcManagerRunner")
 var arc\_notebook = null
 if arc\_mgr != null:
 if arc\_mgr.has\_variable("arc\_notebook"):
 arc\_notebook = arc\_mgr.arc\_notebook
 elif arc\_mgr.has\_method("get\_arc\_notebook"):
 arc\_notebook = arc\_mgr.get\_arc\_notebook()

# 1) ensure\_goal (ton code existant)

 var goal: Dictionary = ensure\_goal(faction\_id, ctx)

# 2) plan\_action

 var action: Dictionary = {"type": &"arc.idle"}
 if planner != null and planner.has\_method("plan\_action"):
 action = planner.plan\_action(goal, ctx)
 var action\_type: StringName = StringName(action.get("type", &"arc.idle"))

# 3) apply (si tu as déjà un apply, sinon record minimal)

 if has\_method("\_apply\_planned\_action"):
 \_apply\_planned\_action(faction\_id, action, ctx)
 elif arc\_notebook != null and arc\_notebook.has\_method("record\_faction\_action"):
 arc\_notebook.record\_faction\_action({
 "day": day,
 "faction\_id": faction\_id,
 "action": action\_type
 })

# 4) spawn offers (domestic + truce) si les factories existent

 if offer\_sink != null:
 if ctx.has("domestic\_state") and ClassDB.class\_exists("DomesticOfferFactory"):
 DomesticOfferFactory.spawn\_offer\_if\_needed(
 faction\_id, ctx["domestic\_state"], day,
 offer\_sink, arc\_notebook
 )

 if goal.get("type", &"") == &"TRUCE":
 var target\_id: StringName = StringName(goal.get("target\_id", &""))
 if target\_id != &"" and ClassDB.class\_exists("ArcTruceOfferFactory"):
 ArcTruceOfferFactory.spawn\_truce\_offer\_if\_needed(
 faction\_id, target\_id,
 ctx.get("domestic\_state", null),
 day, offer\_sink, arc\_notebook
 )

 return {
 "day": day,
 "goal": goal,
 "action": action,
 "action\_type": action\_type
 }
```


---


## 2) Test d’intégration avec **autoloads réels** (snapshot + reset + restore)


>
> Objectif : simuler 30 jours, faire monter la pression (>0.7), vérifier qu’on force TRUCE (7 jours), qu’on **arrête les offensives** pendant TRUCE, puis qu’on **restore** WAR quand la pression retombe.
>
>
>


```
# tests/Integration\_WarPressureGate\_Autoloads.gd

extends Node
class\_name Integration\_WarPressureGate\_Autoloads

class DomesticState:
 var war\_support := 75
 var unrest := 10
 func pressure() -> float:
 # même formule que ce qu’on a discuté : simple, stable
 return clampf(0.55 * (1.0 - war\_support / 100.0) + 0.45 * (unrest / 100.0), 0.0, 1.0)

func \_ready() -> void:
 \_test\_world\_loop\_uses\_real\_autoloads()
 print("\n✅ Integration\_WarPressureGate\_Autoloads: OK\n")
 get\_tree().quit()

func \_test\_world\_loop\_uses\_real\_autoloads() -> void:
 var runner = get\_node\_or\_null("/root/FactionGoalManagerRunner")
 \_assert(runner != null, "Missing autoload /root/FactionGoalManagerRunner")

# Offer sink réel (celui qui a try\_add\_offer)

 var offer\_sink: Node = null
 for n in ["QuestPool", "QuestOfferSimRunner", "QuestOfferPool", "QuestOffers"]:
 var cand = get\_node\_or\_null("/root/" + n)
 if cand != null and cand.has\_method("try\_add\_offer"):
 offer\_sink = cand
 break
 \_assert(offer\_sink != null, "No offer sink autoload found (need try\_add\_offer)")

 var world = get\_node\_or\_null("/root/WorldGameState")

# si tu l’as

 var A := &"A"
 var B := &"B"

 # --- SNAPSHOT minimal ---
 var snap := {}

 # World day
 if world != null and world.has\_variable("current\_day"):
 snap["prev\_day"] = int(world.current\_day)

# Offers

 snap["offers\_prev"] = \_snapshot\_offers(offer\_sink)
 \_clear\_offers(offer\_sink)

# Goal state A (on snapshot ce qu’on peut)

 snap["goal\_prev"] = \_snapshot\_goal\_state(runner, A)
 \_set\_goal\_state(runner, A, {"type": &"WAR", "target\_id": B})

# --- Simulation ---

 var dom := DomesticState.new()

 var first\_truce\_day := -1
 var truce\_until := -1
 var saw\_restore\_war := false

 var offensive\_actions\_during\_truce := 0

 for day in range(1, 31):
 # Pilote la pression :
 # J1..J17 -> pression monte (support↓, unrest↑)

# J18..J30 -> pression baisse (support↑, unrest↓)

 if day <= 17:
 dom.war\_support = int(clampi(dom.war\_support - 4, 0, 100))
 dom.unrest = int(clampi(dom.unrest + 4, 0, 100))
 else:
 dom.war\_support = int(clampi(dom.war\_support + 5, 0, 100))
 dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

 if world != null and world.has\_variable("current\_day"):
 world.current\_day = day

 var out: Dictionary = runner.tick\_day(A, {"day": day, "domestic\_state": dom})
 var goal: Dictionary = out.get("goal", {})
 var gt: StringName = StringName(goal.get("type", &""))
 var at: StringName = StringName(out.get("action\_type", &"arc.idle"))

# détecter entrée en TRUCE

 if gt == &"TRUCE" and first\_truce\_day < 0:
 first\_truce\_day = day
 truce\_until = int(goal.get("until\_day", day + 7))

# compter offensives pendant TRUCE (liste simple, adapte si tu as d’autres types)

 if first\_truce\_day > 0 and day >= first\_truce\_day and day <= truce\_until:
 if at in [&"arc.raid", &"arc.sabotage", &"arc.attack", &"arc.declare\_war"]:
 offensive\_actions\_during\_truce += 1

 # vérifier restore WAR après TRUCE
 if first\_truce\_day > 0 and day > truce\_until and gt == &"WAR":
 saw\_restore\_war = true

 # --- Assertions ---
 \_assert(first\_truce\_day > 0, "Should enter TRUCE at least once (pressure gate)")
 \_assert(truce\_until >= first\_truce\_day, "TRUCE until\_day invalid")
 \_assert(offensive\_actions\_during\_truce == 0, "No offensive actions allowed during TRUCE window")
 \_assert(saw\_restore\_war, "Should restore WAR after TRUCE when pressure drops")

# Offers spawned check (simple : au moins 1 offer en période de pression haute)

 var offers\_after = \_snapshot\_offers(offer\_sink)
 \_assert(offers\_after.size() >= 1, "Expected at least 1 offer spawned during loop")

# --- RESTORE ---

 \_restore\_goal\_state(runner, A, snap["goal\_prev"])
 \_restore\_offers(offer\_sink, snap["offers\_prev"])
 if world != null and snap.has("prev\_day"):
 world.current\_day = snap["prev\_day"]

func \_snapshot\_offers(offer\_sink: Node) -> Array:
 # essaye plusieurs layouts
 if offer\_sink.has\_variable("offers") and offer\_sink.offers is Array:
 return offer\_sink.offers.duplicate(true)
 if offer\_sink.has\_method("get\_offers"):
 var arr = offer\_sink.get\_offers()
 return (arr is Array) ? arr.duplicate(true) : []
 return []

func \_clear\_offers(offer\_sink: Node) -> void:
 if offer\_sink.has\_method("\_test\_clear\_offers"):
 offer\_sink.\_test\_clear\_offers()
 return
 if offer\_sink.has\_variable("offers") and offer\_sink.offers is Array:
 offer\_sink.offers.clear()

func \_restore\_offers(offer\_sink: Node, prev: Array) -> void:
 \_clear\_offers(offer\_sink)
 if offer\_sink.has\_variable("offers") and offer\_sink.offers is Array:
 for o in prev:
 offer\_sink.offers.append(o)

func \_snapshot\_goal\_state(runner: Node, faction\_id: StringName) -> Variant:
 if runner.has\_method("get\_goal\_state"):
 return runner.get\_goal\_state(faction\_id)
 if runner.has\_variable("goals\_by\_faction"):
 return runner.goals\_by\_faction.get(faction\_id, null)
 return null

func \_set\_goal\_state(runner: Node, faction\_id: StringName, goal: Dictionary) -> void:
 if runner.has\_method("set\_goal\_state"):
 runner.set\_goal\_state(faction\_id, goal)
 return
 if runner.has\_variable("goals\_by\_faction"):
 runner.goals\_by\_faction[faction\_id] = goal

func \_restore\_goal\_state(runner: Node, faction\_id: StringName, prev: Variant) -> void:
 if prev == null:
 # clear
 if runner.has\_variable("goals\_by\_faction"):
 runner.goals\_by\_faction.erase(faction\_id)
 return
 \_set\_goal\_state(runner, faction\_id, prev)

func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


## Micro-patch recommandé (optionnel mais pratique) : `offer_sink._test_clear_offers()`


Dans ton autoload qui gère réellement les offers (celui qui a `try_add_offer`), ajoute juste :


```
func \_test\_clear\_offers() -> void:
 if has\_variable("offers") and offers is Array:
 offers.clear()
```


Ça évite les tests “fragiles” quand le stockage interne change.


---


Si tu me confirmes le **nom exact** de ton autoload “offers pool” (celui qui contient les `QuestInstance AVAILABLE`), je te donne une version du test qui vérifie aussi **le contenu du context** (ex: `arc_action_type`, `giver_faction_id`, `antagonist_faction_id`, `is_truce_offer`, etc.), pas seulement le comptage.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 14](#toc-detail-ch14)
<a id="moi-97"></a>
**Moi 97:**
<a id="cite-questpool-gd-caba10-1"></a>QuestPool.gd


**ChatGPT:**
Parfait — si ton autoload s’appelle **`/root/QuestPool`** (script `QuestPool.gd`), on peut faire un test d’intégration **vraiment propre** en s’appuyant dessus directement, à condition d’avoir un mini “hook de test” pour **snapshot/clear/restore** des offers.


## 1) Micro-patch minimal dans `QuestPool.gd` (test-only helpers)


Ajoute ces méthodes (elles ne changent pas le gameplay, juste les tests) :


```
# QuestPool.gd

# Si ton conteneur d'offres ne s'appelle pas "offers", adapte ici.

# Dans ton résumé, c'est "offers disponibles (AVAILABLE)" => souvent `var offers: Array[QuestInstance]`.

func \_test\_snapshot\_offers() -> Array:
 return offers.duplicate(true)

func \_test\_clear\_offers() -> void:
 offers.clear()

func \_test\_restore\_offers(prev: Array) -> void:
 offers.clear()
 for o in prev:
 offers.append(o)
```


---


## 2) Micro-patch `FactionGoalManagerRunner.tick_day()` (QuestPool direct)


Dans ton `tick_day`, remplace la détection multi-noms par **QuestPool direct** :


```
var quest\_pool = get\_node\_or\_null("/root/QuestPool")

# ...

if quest\_pool != null and quest\_pool.has\_method("try\_add\_offer"):
 # spawn Domestic + Truce ici
```


(Le reste inchangé.)


---


## 3) Test d’intégration “autoloads réels” avec restore complet


### `tests/Integration_WarPressureGate_Autoloads_QuestPool.gd`


```
extends Node
class\_name Integration\_WarPressureGate\_Autoloads\_QuestPool

# Domestic state minimal compatible avec DomesticPolicyGate (pressure())

class DomesticState:
 var war\_support := 75
 var unrest := 10
 func pressure() -> float:
 return clampf(0.55 * (1.0 - war\_support / 100.0) + 0.45 * (unrest / 100.0), 0.0, 1.0)

func \_ready() -> void:
 \_test\_real\_autoload\_loop\_with\_goal\_stack\_and\_offers()
 print("\n✅ Integration\_WarPressureGate\_Autoloads\_QuestPool: OK\n")
 get\_tree().quit()

func \_test\_real\_autoload\_loop\_with\_goal\_stack\_and\_offers() -> void:
 var runner = get\_node\_or\_null("/root/FactionGoalManagerRunner")
 \_assert(runner != null, "Missing autoload /root/FactionGoalManagerRunner")

 var planner = get\_node\_or\_null("/root/FactionGoalPlanner")
 \_assert(planner != null, "Missing autoload /root/FactionGoalPlanner")

 var quest\_pool = get\_node\_or\_null("/root/QuestPool")
 \_assert(quest\_pool != null, "Missing autoload /root/QuestPool")
 \_assert(quest\_pool.has\_method("try\_add\_offer"), "QuestPool must expose try\_add\_offer(inst)")

# test helpers in QuestPool

 \_assert(quest\_pool.has\_method("\_test\_snapshot\_offers"), "QuestPool needs \_test\_snapshot\_offers() for this test")
 \_assert(quest\_pool.has\_method("\_test\_clear\_offers"), "QuestPool needs \_test\_clear\_offers() for this test")
 \_assert(quest\_pool.has\_method("\_test\_restore\_offers"), "QuestPool needs \_test\_restore\_offers(prev) for this test")

# goal state API in runner

 \_assert(runner.has\_method("get\_goal\_state") and runner.has\_method("set\_goal\_state"),
 "FactionGoalManagerRunner must expose get\_goal\_state/set\_goal\_state for clean restore")

 var A := &"A"
 var B := &"B"

 # ---------------- SNAPSHOT & RESET ----------------
 var prev\_offers: Array = quest\_pool.\_test\_snapshot\_offers()
 quest\_pool.\_test\_clear\_offers()

 var prev\_goal = runner.get\_goal\_state(A)
 runner.set\_goal\_state(A, {"type": &"WAR", "target\_id": B})

# ---------------- SIM LOOP ----------------

 var dom := DomesticState.new()

 var first\_truce\_day := -1
 var truce\_until := -1
 var saw\_restore\_war := false

 var raids\_pre\_15 := 0
 var raids\_during\_truce := 0

 for day in range(1, 31):
 # pression monte jusqu'à ~J17, puis redescend franchement
 if day <= 17:
 dom.war\_support = int(clampi(dom.war\_support - 4, 0, 100))
 dom.unrest = int(clampi(dom.unrest + 4, 0, 100))
 else:
 dom.war\_support = int(clampi(dom.war\_support + 5, 0, 100))
 dom.unrest = int(clampi(dom.unrest - 6, 0, 100))

 var out: Dictionary = runner.tick\_day(A, {"day": day, "domestic\_state": dom})
 var goal: Dictionary = out.get("goal", {})
 var gt: StringName = StringName(goal.get("type", &""))
 var at: StringName = StringName(out.get("action\_type", &"arc.idle"))

 if day < 15 and at == &"arc.raid":
 raids\_pre\_15 += 1

 if gt == &"TRUCE" and first\_truce\_day < 0:
 first\_truce\_day = day
 truce\_until = int(goal.get("until\_day", day + 7))

 if first\_truce\_day > 0 and day >= first\_truce\_day and day <= truce\_until:
 if at == &"arc.raid":
 raids\_during\_truce += 1

 if first\_truce\_day > 0 and day > truce\_until and gt == &"WAR":
 saw\_restore\_war = true

 # ---------------- ASSERTIONS ----------------
 \_assert(raids\_pre\_15 >= 1, "Expected at least one raid before day 15 (else test doesn't prove gating)")
 \_assert(first\_truce\_day > 0, "Should enter TRUCE at least once (pressure gate)")
 \_assert(raids\_during\_truce == 0, "No raids allowed during forced TRUCE window")
 \_assert(saw\_restore\_war, "Should restore WAR after TRUCE window when pressure drops")

# Offers spawned (post J15): au moins 1 domestic + 1 truce

 var offers\_after: Array = quest\_pool.\_test\_snapshot\_offers()

 var domestic\_post := 0
 var truce\_post := 0
 for inst in offers\_after:
 # started\_on\_day existe dans ton modèle (sinon fallback context)
 var sd := 0
 if inst != null and inst.has\_method("get"):
 # pas fiable; on préfère accès direct si champ
 pass
 if "started\_on\_day" in inst:
 sd = int(inst.started\_on\_day)
 else:
 sd = int(inst.context.get("started\_on\_day", inst.context.get("day", 0)))

 if sd < 15:
 continue

 if bool(inst.context.get("is\_domestic\_offer", false)):
 domestic\_post += 1
 if StringName(inst.context.get("arc\_action\_type", &"")) == &"arc.truce\_talks":
 truce\_post += 1

 \_assert(domestic\_post >= 1, "Expected >= 1 DOMESTIC offer after day 15")
 \_assert(truce\_post >= 1, "Expected >= 1 TRUCE offer after day 15")

# ---------------- RESTORE ----------------

 runner.set\_goal\_state(A, prev\_goal)
 quest\_pool.\_test\_restore\_offers(prev\_offers)


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


### Ce test valide “en vrai”


* Le runner appelle bien `ensure_goal → planner → apply → spawn offers` via **ton `tick_day`**
* Le **gate domestic** force `TRUCE` + stocke `suspended_goal`
* Pendant la fenêtre de trêve, on **ne raid plus**
* Quand la pression retombe, on **restore WAR**
* Le vrai `QuestPool` reçoit bien des offers **domestic** + **truce**


---


Si tu veux, prochaine brique logique : je te fais la même chose mais en vérifiant aussi le **contenu du context** des offers (tier, deadline, giver/antagonist, reason DOMESTIC\_PRESSURE), pour garantir que le pipeline est strictement conforme à ta spec “data-driven”.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 14](#toc-detail-ch14)
<a id="moi-98"></a>
**Moi 98:**
Passons plutot sur

10) “Failure modes” intéressants

Aujourd’hui, un échec est souvent “rien”. Donne-lui une conséquence :

• LOYAL/NEUTRAL/TRAITOR + SUCCESS/FAILURE

• ex: médiation échoue → tension↑ mais trust envers C peut ↓ (“médiateur incompétent”).

Effet : tes quêtes nourrissent vraiment le monde.


**ChatGPT:**
Oui — si tu veux que tes quêtes “nourrissent vraiment le monde”, il faut que **l’issue** ne soit pas juste *LOYAL/NEUTRAL/TRAITOR*, mais **(choice × outcome)** :


* `choice ∈ {LOYAL, NEUTRAL, TRAITOR}`
* `outcome ∈ {SUCCESS, FAILURE}` (et plus tard tu pourras ajouter `PARTIAL` / `CRITICAL`)


L’idée simple : **un échec doit déplacer des métriques**, mais pas forcément “dans le sens escalade pure” : il peut **réduire la confiance**, **augmenter la fatigue**, **déclencher des rumeurs**, **créer des offres de réparation**… et donc générer des sorties de crise organiques.


---


## 1) Patch minimal data-driven


### A) Ajout d’un outcome dans la résolution


Dans `QuestManager.resolve_quest`, tu ajoutes un paramètre :


```
func resolve\_quest(runtime\_id: StringName, choice: StringName, outcome: StringName = &"SUCCESS") -> void:
 # outcome: SUCCESS / FAILURE
```


Et tu émets un signal plus riche :


```
signal quest\_resolved(inst, choice, outcome)
```


### B) `QuestResolutionProfile` : 6 tableaux (simple à éditer en .tres)


Au lieu de 3 arrays, tu passes à 6 arrays :


```
# QuestResolutionProfile.gd

class\_name QuestResolutionProfile
extends Resource

@export var id: StringName

@export var success\_loyal\_effects: Array[QuestEffect] = []
@export var success\_neutral\_effects: Array[QuestEffect] = []
@export var success\_traitor\_effects: Array[QuestEffect] = []

@export var failure\_loyal\_effects: Array[QuestEffect] = []
@export var failure\_neutral\_effects: Array[QuestEffect] = []
@export var failure\_traitor\_effects: Array[QuestEffect] = []
```


Puis dans le QuestManager :


```
func \_get\_effects(profile: QuestResolutionProfile, choice: StringName, outcome: StringName) -> Array:
 if outcome == &"SUCCESS":
 match choice:
 &"LOYAL": return profile.success\_loyal\_effects
 &"NEUTRAL": return profile.success\_neutral\_effects
 &"TRAITOR": return profile.success\_traitor\_effects
 else:
 match choice:
 &"LOYAL": return profile.failure\_loyal\_effects
 &"NEUTRAL": return profile.failure\_neutral\_effects
 &"TRAITOR": return profile.failure\_traitor\_effects
 return []
```


---


## 2) “Failure modes” intéressants : règles standard (par type d’offre)


Tu vas vite vouloir une table **action\_type → deltas standard** (en plus du profil .tres), parce que toutes les quêtes n’auront pas un profil bespoke.


Je te propose un fallback très clair : une fonction `apply_failure_consequences(context, choice, outcome)` appelée **après** les effects du profile.


### Exemples concrets (Arc / Third party)

#### A) Médiation (3 factions) — ce que tu as demandé explicitement


Contexte :


* `A` ↔ `B` en conflit
* `C` médiateur


**SUCCESS / LOYAL**


* `A↔B`: tension -8, grievance -6, trust +2
* `A↔C`: trust +6, relation +3
* `B↔C`: trust +6, relation +3


**FAILURE / LOYAL**


* `A↔B`: tension +4 (négociations ratées), grievance +2
* `A↔C`: trust -3 (“médiateur incompétent”), relation -1
* `B↔C`: trust -3, relation -1


**FAILURE / TRAITOR**


* `A↔B`: tension +7, grievance +4
* `A→C`: trust -6 (C suspect)
* `B→C`: trust -6
*
	+ rumeur “C a saboté” (si tu branches Knowledge)


Ça donne exactement le côté *“échec ≠ rien, mais ≠ escalade automatique”* : souvent ça fait **baisser la confiance** et **augmenter la fatigue**, ce qui pousse ensuite des offres “réparer / prouver / apaiser”.


#### B) Truce talks (2 factions)


**FAILURE**


* `A↔B`: tension +3 (frustration)
* `A↔B`: weariness +4 (ça use)
* `domestic(A)`: war\_support -3 (si tu veux le lier)


=> Ça peut paradoxalement **faire descendre l’appétit de guerre** côté interne, donc tu crées une sortie.


#### C) Raid / sabotage


**FAILURE**


* `victim→attacker`: grievance +5, tension +3 (ils sont furieux)
* `attacker domestic`: war\_support -2 / unrest +2 (humiliation / pertes)
* et/ou `attacker→victim trust` ne bouge pas (déjà bas), mais `weariness` monte.


=> Tu obtiens un système auto-stabilisant : les échecs offensifs font aussi **payer** l’attaquant (politique interne), donc il finit par chercher trêve / réparations.


---


## 3) Hooks minimalistes pour ArcNotebook


Le but : pouvoir mesurer “médiateur incompétent”, “soupçon”, “fail streak”.


### À chaque résolution :


```
if arc\_notebook != null:
 arc\_notebook.record\_pair\_event(day, giver, antagonist, action\_type, choice, {
 "outcome": outcome,
 "runtime\_id": inst.runtime\_id
 })
```


Et pour la 3rd party :


```
arc\_notebook.record\_triplet\_event(day, A, B, C, action\_type, choice, {"outcome": outcome})
```


Même si tu ne l’exploites pas tout de suite, c’est précieux pour :


* limiter la variance (fail streak ⇒ plus de chances d’offres “repair”)
* générer des rumeurs
* faire du debug sur l’escalade


---


## 4) MVP code : appliquer des conséquences d’échec (Arc/Third party)


Voici une version compacte, “drop-in”, qui suppose que tu as déjà `FactionRelationScore` avec `relation/trust/tension/grievance/weariness`.


```
# ArcFailureConsequences.gd

class\_name ArcFailureConsequences
extends RefCounted

static func apply(context: Dictionary, choice: StringName, outcome: StringName, relations: Dictionary, domestic\_by\_faction: Dictionary, arc\_notebook = null, day: int = 0) -> void:
 var action\_type: StringName = StringName(context.get("arc\_action\_type", context.get("tp\_action", &"")))
 if action\_type == &"": return

 var A: StringName = StringName(context.get("giver\_faction\_id", &""))
 var B: StringName = StringName(context.get("antagonist\_faction\_id", &""))
 var C: StringName = StringName(context.get("third\_party\_id", &""))

# helpers

 var f = func(x): return x # (juste pour garder ça lisible)

 if action\_type == &"tp.mediation":
 \_apply\_mediation(A, B, C, choice, outcome, relations)
 elif action\_type == &"arc.truce\_talks":
 \_apply\_truce(A, B, choice, outcome, relations, domestic\_by\_faction)
 elif action\_type == &"arc.raid":
 \_apply\_raid(A, B, choice, outcome, relations, domestic\_by\_faction)

# ... autres actions

 if arc\_notebook != null and arc\_notebook.has\_method("record\_pair\_event"):
 arc\_notebook.record\_pair\_event(day, A, B, action\_type, choice, {"outcome": outcome})


static func \_apply\_mediation(A, B, C, choice, outcome, relations):
 if C == &"": return
 if outcome == &"SUCCESS":
 \_rel(relations, A, B, "tension", -8); \_rel(relations, B, A, "tension", -8)
 \_rel(relations, A, B, "grievance", -6); \_rel(relations, B, A, "grievance", -6)
 \_rel(relations, A, C, "trust", +6); \_rel(relations, C, A, "trust", +6)
 \_rel(relations, B, C, "trust", +6); \_rel(relations, C, B, "trust", +6)
 else:
 # échec = frustration + “médiateur incompétent”
 \_rel(relations, A, B, "tension", +4); \_rel(relations, B, A, "tension", +4)
 \_rel(relations, A, B, "grievance", +2); \_rel(relations, B, A, "grievance", +2)
 var t = -3 if choice != &"TRAITOR" else -6
 \_rel(relations, A, C, "trust", t)
 \_rel(relations, B, C, "trust", t)
 \_rel(relations, C, A, "trust", t)
 \_rel(relations, C, B, "trust", t)


static func \_apply\_truce(A, B, choice, outcome, relations, domestic\_by\_faction):
 if outcome == &"SUCCESS":
 \_rel(relations, A, B, "tension", -10); \_rel(relations, B, A, "tension", -10)
 \_rel(relations, A, B, "weariness", -6); \_rel(relations, B, A, "weariness", -6)
 else:
 \_rel(relations, A, B, "tension", +3); \_rel(relations, B, A, "tension", +3)
 \_rel(relations, A, B, "weariness", +4); \_rel(relations, B, A, "weariness", +4)

# optionnel : la population se fatigue => support ↓

 if domestic\_by\_faction.has(A):
 domestic\_by\_faction[A].war\_support = int(clampi(domestic\_by\_faction[A].war\_support - 2, 0, 100))


static func \_apply\_raid(attacker, victim, choice, outcome, relations, domestic\_by\_faction):
 if outcome == &"SUCCESS":
 \_rel(relations, victim, attacker, "grievance", +6)
 \_rel(relations, victim, attacker, "tension", +4)
 else:
 # raid raté => le victim est furieux, mais l’attaquant paie aussi (fatigue interne)
 \_rel(relations, victim, attacker, "grievance", +5)
 \_rel(relations, victim, attacker, "tension", +3)
 \_rel(relations, attacker, victim, "weariness", +3)
 if domestic\_by\_faction.has(attacker):
 domestic\_by\_faction[attacker].unrest = int(clampi(domestic\_by\_faction[attacker].unrest + 2, 0, 100))
 domestic\_by\_faction[attacker].war\_support = int(clampi(domestic\_by\_faction[attacker].war\_support - 2, 0, 100))


static func \_rel(relations: Dictionary, a: StringName, b: StringName, field: String, delta: int) -> void:
 if a == &"" or b == &"": return
 if not relations.has(a) or not relations[a].has(b): return
 var r: FactionRelationScore = relations[a][b]
 match field:
 "relation": r.relation = int(clampi(r.relation + delta, -100, 100))
 "trust": r.trust = int(clampi(r.trust + delta, 0, 100))
 "tension": r.tension = int(clampi(r.tension + delta, 0, 100))
 "grievance": r.grievance = int(clampi(r.grievance + delta, 0, 100))
 "weariness": r.weariness = int(clampi(r.weariness + delta, 0, 100))
```


---


## 5) Ce que ça change tout de suite (gameplay)


* Tu as des quêtes “réelles” : même ratées, elles déplacent le monde.
* Tu obtiens des arcs qui **peuvent s’éteindre** :
	+ l’échec monte `weariness` et baisse `war_support` ⇒ TRUCE/REPARATIONS
	+ l’échec de médiation baisse la confiance envers le médiateur ⇒ quêtes “prove competence / investigate sabotage”
* Tu crées naturellement des branches narratives :
	+ “médiateur incompétent” ⇒ rumeurs ⇒ 3 factions
	+ raid raté ⇒ domestic unrest ⇒ quêtes internes


---


Si tu veux la prochaine brique logique : je te propose une mini-fonction **compute\_outcome\_success(inst, actor\_profile, opposition, tier)** (pour déterminer SUCCESS/FAILURE de façon data-driven), + un test simple “médiation échoue ⇒ tension↑ et trust envers C↓”.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 15](#toc-detail-ch15)
<a id="moi-99"></a>
**Moi 99:**
Ok

prochaine brique logique : je te propose une mini-fonction compute\_outcome\_success(inst, actor\_profile, opposition, tier) (pour déterminer SUCCESS/FAILURE de façon data-driven), + un test simple “médiation échoue ⇒ tension↑ et trust envers C↓”.

Penses bien qu'il peut y avoir 2 ou 3 participant


**ChatGPT:**
Voici une proposition **MVP “data-driven”** pour déterminer `SUCCESS/FAILURE`, compatible **2 ou 3 participants**, + un **mini test** “médiation échoue ⇒ tension↑ et trust envers C↓”.


---


## 1) `QuestOutcomeUtil.compute_outcome_success(...)`


* `actor_profile` peut être **un seul profil** (cas 2 factions) **ou** un **dictionnaire** `{faction_id: profile}` (cas 3 factions).
* `opposition` peut contenir `tension_mean/grievance_mean/friction` + (optionnel) `participants` pour pondérer la difficulté.
* Déterminisme : si `inst.context.roll` est fourni, c’est **100% déterministe**.


```
# QuestOutcomeUtil.gd

class\_name QuestOutcomeUtil
extends RefCounted

static func compute\_outcome\_success(inst, actor\_profile, opposition: Dictionary, tier: int, rng: RandomNumberGenerator = null) -> bool:
 var ctx: Dictionary = inst.context if inst != null and "context" in inst else {}
 var action\_type: StringName = StringName(ctx.get("arc\_action\_type", ctx.get("tp\_action", ctx.get("quest\_type", &""))))

# --- base chance from tier ---

 var p := 0.62 - 0.08 * float(max(0, tier - 1))

# tier 1 ~0.62, tier 5 ~0.30

 p = clampf(p, 0.05, 0.90)

# --- conflict heat / friction (works for 2 or 3 factions) ---

 var tension := float(opposition.get("tension\_mean", opposition.get("tension", 0.0))) / 100.0
 var grievance := float(opposition.get("grievance\_mean", opposition.get("grievance", 0.0))) / 100.0
 var friction := float(opposition.get("friction", 0.0))

# 0..1 (si tu l’as)

 var heat := clampf(0.55 * tension + 0.35 * grievance + 0.30 * friction, 0.0, 1.0)

# --- actor skill (2 or 3 participants) ---

 var skill := \_compute\_actor\_skill(actor\_profile, ctx, action\_type)

# 0..1

 # --- opposition resistance (optional) ---
 var opp := float(opposition.get("resistance", 0.5))

# 0..1

 var opp\_participants := opposition.get("participants", null)
 if opp\_participants is Dictionary:
 opp = clampf(0.5 + 0.35 * float(opp\_participants.size() - 1), 0.5, 0.95)

# --- action-specific shaping ---

 match action\_type:
 &"tp.mediation":
 # médiation = très sensible à la heat
 p += 0.40 * (skill - 0.5)
 p -= 0.55 * heat
 p -= 0.20 * (opp - 0.5)
 &"arc.truce\_talks":
 p += 0.25 * (skill - 0.5)
 p -= 0.40 * heat
 p -= 0.15 * (opp - 0.5)
 &"arc.raid", &"arc.sabotage":
 p += 0.30 * (skill - 0.5)
 p -= 0.25 * heat
 p -= 0.25 * (opp - 0.5)
 \_:
 p += 0.25 * (skill - 0.5)
 p -= 0.30 * heat
 p -= 0.15 * (opp - 0.5)

 p = clampf(p, 0.05, 0.95)

# --- deterministic roll support ---

 var roll := float(ctx.get("roll", -1.0))
 if roll < 0.0:
 if rng != null:
 roll = rng.randf()
 else:
 # fallback deterministic-ish (not ideal but stable): hash(day+runtime\_id)
 var seed := int(ctx.get("day", 0)) * 73856093 ^ int(hash(String(ctx.get("runtime\_id", ""))))
 var local\_rng := RandomNumberGenerator.new()
 local\_rng.seed = seed
 roll = local\_rng.randf()

# store for debug/metrics

 ctx["last\_success\_chance"] = p
 ctx["last\_roll"] = roll
 inst.context = ctx if inst != null and "context" in inst else ctx

 return roll < p


static func \_compute\_actor\_skill(actor\_profile, ctx: Dictionary, action\_type: StringName) -> float:
 # actor\_profile can be:
 # - a single profile (has get\_personality)

# - a Dictionary {faction\_id: profile}

 # - a Dictionary {"profile": ..., "profiles": ...} (if you want later)
 var actor\_id: StringName = StringName(ctx.get("actor\_faction\_id", ctx.get("giver\_faction\_id", &"")))
 var prof = actor\_profile
 if actor\_profile is Dictionary and actor\_profile.has(actor\_id):
 prof = actor\_profile[actor\_id]

 # choose key weights by action
 var dip := \_p(prof, &"diplomacy", 0.5)
 var hon := \_p(prof, &"honor", 0.5)
 var cun := \_p(prof, &"cunning", 0.5)
 var opp := \_p(prof, &"opportunism", 0.5)
 var agr := \_p(prof, &"aggression", 0.5)
 var dis := \_p(prof, &"discipline", 0.5)

 match action\_type:
 &"tp.mediation", &"arc.truce\_talks":
 # bon médiateur = dip/honor/discipline, mauvais = opportunism/aggression
 return clampf(0.40*dip + 0.25*hon + 0.20*dis + 0.10*cun - 0.20*opp - 0.15*agr, 0.0, 1.0)
 &"arc.raid", &"arc.sabotage":
 return clampf(0.40*cun + 0.25*dis + 0.15*agr - 0.10*hon - 0.05*dip, 0.0, 1.0)
 \_:
 return clampf(0.25*dip + 0.20*dis + 0.20*cun + 0.10*hon - 0.10*opp, 0.0, 1.0)


static func \_p(profile, key: StringName, default\_val: float) -> float:
 if profile == null:
 return default\_val
 if profile.has\_method("get\_personality"):
 return float(profile.get\_personality(key, default\_val))
 if profile is Dictionary:
 # accept either {"personality":{...}} or direct keys
 if profile.has("personality"):
 return float(profile["personality"].get(key, default\_val))
 return float(profile.get(key, default\_val))
 return default\_val
```


### Comment gérer 3 participants ?


* Dans `context`, mets :
	+ `giver_faction_id` = C (médiateur)
	+ `antagonist_faction_id` = A (ou B)
	+ `third_party_id` = B (l’autre)
* Et dans `opposition` passe `tension_mean/grievance_mean` entre A et B (ou la moyenne A↔B).


---


## 2) Mini test : “médiation échoue ⇒ tension↑ et trust envers C↓”


Ce test :


* fabrique un “inst” minimal (juste `context`)
* force un `roll = 0.95` pour garantir `FAILURE`
* applique tes conséquences d’échec via `ArcFailureConsequences.apply(...)`
* vérifie :
	+ `tension(A↔B)` augmente
	+ `trust(A→C)` baisse (et idem B→C si tu veux)


```
# tests/MediationFailureConsequencesTest.gd

extends Node
class\_name MediationFailureConsequencesTest

# fallback minimal if your real class isn't available

class TestRelationScore:
 var relation := 0
 var trust := 50
 var tension := 10
 var grievance := 10
 var weariness := 0

# minimal inst

class TestInst:
 var context := {}

func \_ready() -> void:
 \_test\_mediation\_failure\_increases\_tension\_and\_decreases\_trust\_to\_mediator()
 print("\n✅ MediationFailureConsequencesTest: OK\n")
 get\_tree().quit()

func \_test\_mediation\_failure\_increases\_tension\_and\_decreases\_trust\_to\_mediator() -> void:
 var A := &"A"
 var B := &"B"
 var C := &"C" # mediator

 # relations dict: relations[x][y] = score
 var relations := {}
 relations[A] = {}
 relations[B] = {}
 relations[C] = {}

 var ScoreClass = FactionRelationScore if ClassDB.class\_exists("FactionRelationScore") else TestRelationScore

 relations[A][B] = ScoreClass.new()
 relations[B][A] = ScoreClass.new()
 relations[A][C] = ScoreClass.new()
 relations[B][C] = ScoreClass.new()
 relations[C][A] = ScoreClass.new()
 relations[C][B] = ScoreClass.new()

# baseline

 relations[A][B].tension = 70
 relations[B][A].tension = 70
 relations[A][C].trust = 50
 relations[B][C].trust = 50

 # create mediation quest context (3 participants)
 var inst := TestInst.new()
 inst.context = {
 "tp\_action": &"tp.mediation",
 "giver\_faction\_id": C, # mediator "actor"
 "antagonist\_faction\_id": A,
 "third\_party\_id": B,
 "actor\_faction\_id": C,
 "roll": 0.95 # force failure with low p
 }

 # mediator profile: mediocre diplomacy => low success chance
 var mediator\_profile := {"personality": {&"diplomacy": 0.2, &"honor": 0.4, &"discipline": 0.4, &"opportunism": 0.6, &"aggression": 0.4}}

 # opposition: high heat between A and B
 var opposition := {"tension\_mean": 85, "grievance\_mean": 70, "friction": 0.3, "resistance": 0.7}

 var success := QuestOutcomeUtil.compute\_outcome\_success(inst, mediator\_profile, opposition, 3, null)
 \_assert(not success, "precondition: mediation should FAIL in this setup (chance=%.3f roll=%.3f)" % [float(inst.context.get("last\_success\_chance", 0.0)), float(inst.context.get("last\_roll", 0.0))])

 var tension\_before := relations[A][B].tension
 var trust\_a\_c\_before := relations[A][C].trust

 # apply failure consequences (LOYAL attempt but failure)
 ArcFailureConsequences.apply(inst.context, &"LOYAL", &"FAILURE", relations, {}, null, 10)

 \_assert(relations[A][B].tension > tension\_before, "tension(A→B) should increase after failed mediation (before=%d after=%d)" % [tension\_before, relations[A][B].tension])
 \_assert(relations[A][C].trust < trust\_a\_c\_before, "trust(A→C) should decrease after failed mediation (before=%d after=%d)" % [trust\_a\_c\_before, relations[A][C].trust])

# optional extra: B also distrusts mediator

 \_assert(relations[B][C].trust < 50, "trust(B→C) should also decrease after failed mediation (after=%d)" % relations[B][C].trust)

func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


### Petit détail important (2 vs 3 participants)


* Pour **2 participants** (ex: `arc.truce_talks`) : pas besoin de `third_party_id`, et `opposition` peut être juste `{tension:…, grievance:…}`.
* Pour **3 participants** : `tp_action` + `third_party_id` suffit, et `opposition.tension_mean/grievance_mean` représente la “chaleur” du conflit A↔B.


Si tu veux, prochaine brique logique : brancher `compute_outcome_success()` directement dans `QuestManager.resolve_quest()` (en gardant un override manuel pour les quêtes “scriptées”), et loguer systématiquement `last_success_chance/last_roll` dans ArcNotebook pour debug/metrics.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 15](#toc-detail-ch15)
<a id="moi-100"></a>
**Moi 100:**
Ok

prochaine brique logique : brancher compute\_outcome\_success() directement dans
<a id="cite-questmanager-0ffcf2-7"></a>QuestManager.resolve\_quest() (en gardant un override manuel pour les quêtes “scriptées”), et loguer systématiquement last\_success\_chance/last\_roll dans
<a id="cite-arcnotebook-b751fa-9"></a>ArcNotebook pour debug/metrics.


**ChatGPT:**
OK — voilà un **patch concret** pour brancher `compute_outcome_success()` **dans `QuestManager.resolve_quest()`**, avec :


* **override manuel** (quêtes “scriptées” ou déterminées autrement)
* **2 ou 3 participants** (pair A↔B ou triplet avec médiateur)
* **logging systématique** `last_success_chance / last_roll` dans **ArcNotebook** (via `record_pair_event` + meta)


---


## 1) Patch `QuestManager.gd`


### A) Ajouter un nouveau signal (sans casser l’ancien)


Garde ton signal actuel `quest_resolved(inst, choice)` intact, et ajoute une V2 :


```
signal quest\_resolved(inst, choice)
signal quest\_resolved\_v2(inst, choice, outcome, meta)
```


### B) Remplacer / étendre `resolve_quest(...)`


```
func resolve\_quest(runtime\_id: StringName, choice: StringName, outcome\_override: StringName = &"") -> void:
 var inst: QuestInstance = active\_quests.get(runtime\_id, null)
 if inst == null:
 return

 var ctx: Dictionary = inst.context

 # -----------------------
 # 1) Outcome: override ou calcul
 # -----------------------
 var outcome: StringName = outcome\_override

 # override via context (quêtes scriptées)
 if outcome == &"":
 outcome = StringName(ctx.get("outcome\_override", &""))

# "SUCCESS"/"FAILURE"

 # si tu veux un flag ultra explicite
 if outcome == &"" and bool(ctx.get("is\_scripted\_quest", false)):
 outcome = StringName(ctx.get("scripted\_outcome", &""))

# facultatif

 # auto-failure si l'instance est déjà FAILED/EXPIRED (si ça peut arriver ici)
 if outcome == &"" and String(inst.status) in ["FAILED", "EXPIRED"]:
 outcome = &"FAILURE"

 # compute outcome si toujours vide
 var meta := {}
 if outcome == &"":
 var tier := int(inst.template.tier) if inst.template != null else int(ctx.get("tier", 1))
 var day := \_get\_current\_day(ctx)

# participants (2 ou 3)

 var giver: StringName = StringName(ctx.get("giver\_faction\_id", &""))
 var antagonist: StringName = StringName(ctx.get("antagonist\_faction\_id", &""))
 var third: StringName = StringName(ctx.get("third\_party\_id", &""))

 var actor\_id: StringName = StringName(ctx.get("actor\_faction\_id", giver))
 var actor\_profile = \_get\_faction\_profile(actor\_id)

# opposition: priorise ctx.opposition si fourni (pré-calculé par ArcManager/OfferFactory)

 var opposition: Dictionary = {}
 if ctx.has("opposition") and ctx["opposition"] is Dictionary:
 opposition = ctx["opposition"]
 else:
 opposition = \_compute\_opposition\_from\_relations(ctx, antagonist, third)

# inject day/runtime\_id pour seed debug si utile

 ctx["day"] = day
 ctx["runtime\_id"] = StringName(inst.runtime\_id)

 var success := QuestOutcomeUtil.compute\_outcome\_success(inst, actor\_profile, opposition, tier, null)
 outcome = &"SUCCESS" if success else &"FAILURE"

 # meta debug
 meta["success\_chance"] = float(ctx.get("last\_success\_chance", 0.0))
 meta["roll"] = float(ctx.get("last\_roll", 0.0))
 meta["tier"] = tier
 meta["day"] = day
 meta["actor\_id"] = actor\_id
 meta["opposition"] = opposition

 # persiste dans le context (hyper utile pour replay/debug)
 ctx["outcome"] = outcome
 inst.context = ctx

 # -----------------------
 # 2) Apply profile effects (SUCCESS/FAILURE + choice)

# -----------------------

 var profile\_id: StringName = StringName(ctx.get("resolution\_profile\_id", &""))
 var profile = \_get\_resolution\_profile(profile\_id)

# ton registry actuel

 var effects: Array = \_get\_effects\_compat(profile, choice, outcome)
 \_apply\_effects(inst, effects)

# -----------------------

 # 3) Apply systemic consequences (Arc / third party / domestic)

# -----------------------

 # (relations/domestic accessibles par autoloads, comme tu fais déjà pour d’autres systèmes)
 var relations = \_get\_relations\_store()
 var domestic\_by\_faction = \_get\_domestic\_store()
 var arc\_notebook = \_get\_arc\_notebook()

 if relations != null:
 ArcFailureConsequences.apply(ctx, choice, outcome, relations, domestic\_by\_faction, arc\_notebook, int(meta.get("day", \_get\_current\_day(ctx))))

# -----------------------

 # 4) Finalize + signals + log ArcNotebook
 # -----------------------
 inst.status = "COMPLETED" if outcome == &"SUCCESS" else "FAILED"
 active\_quests.erase(runtime\_id)

# ancien signal (compat)

 emit\_signal("quest\_resolved", inst, choice)

# nouveau signal riche

 emit\_signal("quest\_resolved\_v2", inst, choice, outcome, meta)

# log notebook (pair ou triplet)

 \_log\_resolution\_in\_notebook(inst, choice, outcome, meta, arc\_notebook)
```


### C) Helpers “soft” (non-invasifs)


```
func \_get\_current\_day(ctx: Dictionary) -> int:
 if ctx.has("day"):
 return int(ctx["day"])
 var world = get\_node\_or\_null("/root/WorldGameState")
 if world != null and world.has\_variable("current\_day"):
 return int(world.current\_day)
 return 0


func \_get\_arc\_notebook():
 var arc\_mgr = get\_node\_or\_null("/root/ArcManagerRunner")
 if arc\_mgr == null:
 return null
 if arc\_mgr.has\_variable("arc\_notebook"):
 return arc\_mgr.arc\_notebook
 if arc\_mgr.has\_method("get\_arc\_notebook"):
 return arc\_mgr.get\_arc\_notebook()
 return null


func \_get\_faction\_profile(faction\_id: StringName):
 # adapte aux noms réels (runner/registry)
 var fr = get\_node\_or\_null("/root/FactionProfileRunner")
 if fr != null:
 if fr.has\_method("get\_profile"):
 return fr.get\_profile(faction\_id)
 if fr.has\_method("get\_faction\_profile"):
 return fr.get\_faction\_profile(faction\_id)

# fallback neutre

 return {"personality": {&"diplomacy": 0.5, &"honor": 0.5, &"discipline": 0.5, &"opportunism": 0.5, &"aggression": 0.5}}


func \_compute\_opposition\_from\_relations(ctx: Dictionary, a: StringName, b: StringName) -> Dictionary:
 # pour 2 factions (a=antagonist, b=third\_party ou giver selon action)

# pour médiation: antagoniste = A, third\_party = B => heat sur A↔B

 var rel = \_get\_relations\_store()
 if rel == null or a == &"" or b == &"":
 return {"tension\_mean": 50, "grievance\_mean": 50, "friction": 0.2, "resistance": 0.6}

 if not rel.has(a) or not rel[a].has(b) or not rel.has(b) or not rel[b].has(a):
 return {"tension\_mean": 50, "grievance\_mean": 50, "friction": 0.2, "resistance": 0.6}

 var ab = rel[a][b]
 var ba = rel[b][a]
 var tmean := 0.5 * (float(ab.tension) + float(ba.tension))
 var gmean := 0.5 * (float(ab.grievance) + float(ba.grievance))
 var fric := float(ctx.get("friction", 0.2))
 var res := clampf(0.45 + 0.005 * tmean + 0.005 * gmean, 0.45, 0.90)

 return {"tension\_mean": tmean, "grievance\_mean": gmean, "friction": fric, "resistance": res}


func \_get\_relations\_store():
 # adapte au stockage réel (faction -> dict -> FactionRelationScore)
 var rm = get\_node\_or\_null("/root/FactionRelationsRunner")
 if rm != null and rm.has\_variable("relations\_by\_faction"):
 return rm.relations\_by\_faction
 if rm != null and rm.has\_method("get\_relations\_store"):
 return rm.get\_relations\_store()
 return null


func \_get\_domestic\_store():
 var dm = get\_node\_or\_null("/root/DomesticPressureRunner")
 if dm != null and dm.has\_variable("domestic\_by\_faction"):
 return dm.domestic\_by\_faction
 return {}
```


### D) Effects compat (ancien profil 3 arrays + nouveau 6 arrays)


```
func \_get\_effects\_compat(profile, choice: StringName, outcome: StringName) -> Array:
 if profile == null:
 return []

 # Nouveau format (6 arrays)
 if "success\_loyal\_effects" in profile:
 if outcome == &"SUCCESS":
 match choice:
 &"LOYAL": return profile.success\_loyal\_effects
 &"NEUTRAL": return profile.success\_neutral\_effects
 &"TRAITOR": return profile.success\_traitor\_effects
 else:
 match choice:
 &"LOYAL": return profile.failure\_loyal\_effects
 &"NEUTRAL": return profile.failure\_neutral\_effects
 &"TRAITOR": return profile.failure\_traitor\_effects

 # Ancien format (3 arrays) => on les considère comme SUCCESS, et FAILURE => [] (compensé par ArcFailureConsequences)
 if "loyal\_effects" in profile:
 match choice:
 &"LOYAL": return profile.loyal\_effects
 &"NEUTRAL": return profile.neutral\_effects
 &"TRAITOR": return profile.traitor\_effects

 return []
```


### E) Logging ArcNotebook (chance/roll systématiques)


```
func \_log\_resolution\_in\_notebook(inst: QuestInstance, choice: StringName, outcome: StringName, meta: Dictionary, arc\_notebook) -> void:
 if arc\_notebook == null:
 return

 var ctx := inst.context
 var day := int(meta.get("day", \_get\_current\_day(ctx)))
 var giver: StringName = StringName(ctx.get("giver\_faction\_id", &""))
 var ant: StringName = StringName(ctx.get("antagonist\_faction\_id", &""))
 var third: StringName = StringName(ctx.get("third\_party\_id", &""))

 var action\_type: StringName = StringName(ctx.get("arc\_action\_type", ctx.get("tp\_action", &"quest")))
 var payload := {
 "outcome": outcome,
 "chance": float(ctx.get("last\_success\_chance", meta.get("success\_chance", 0.0))),
 "roll": float(ctx.get("last\_roll", meta.get("roll", 0.0))),
 "runtime\_id": StringName(inst.runtime\_id),
 "tier": int(meta.get("tier", ctx.get("tier", 1)))
 }

 if third != &"" and arc\_notebook.has\_method("record\_triplet\_event"):
 arc\_notebook.record\_triplet\_event(day, ant, third, giver, action\_type, choice, payload)

# (A,B,C)

 elif arc\_notebook.has\_method("record\_pair\_event"):
 arc\_notebook.record\_pair\_event(day, giver, ant, action\_type, choice, payload)
```


---


## 2) Override “scripted quest” (simple et robuste)


Pour une quête scriptée, au moment de la création de l’instance (ou juste avant resolve), tu poses :


```
inst.context["is\_scripted\_quest"] = true
inst.context["outcome\_override"] = &"SUCCESS" # ou FAILURE
```


ou alors tu appelles directement :


```
QuestManager.resolve\_quest(runtime\_id, &"LOYAL", &"SUCCESS")
```


---


## 3) Important pour 2 vs 3 participants


* **2 factions** (ex: `arc.truce_talks`) : `giver_faction_id=A`, `antagonist_faction_id=B`, pas de `third_party_id`
* **3 factions** (ex: médiation) : `giver=C (médiateur)`, `antagonist=A`, `third_party=B`
	+ l’**opposition/heat** est calculée sur **A↔B** (antagonist ↔ third\_party), ce qui est exactement ce qu’on veut.


---


Si tu veux la brique suivante : je te donne un mini test d’intégration sur ton pipeline réel : *QuestManager.resolve\_quest()* sur une médiation 3 factions, avec `roll` forcé, et assertion que `ArcNotebook` reçoit bien `chance/roll/outcome` + que les deltas tension/trust sont appliqués.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 15](#toc-detail-ch15)
<a id="moi-101"></a>
**Moi 101:**
Ok

brique suivante : je te donne un mini test d’intégration sur ton pipeline réel :
<a id="cite-questmanager-0ffcf2-8"></a>QuestManager.resolve\_quest() sur une médiation 3 factions, avec roll forcé, et assertion que
<a id="cite-arcnotebook-b751fa-10"></a>ArcNotebook reçoit bien chance/roll/outcome + que les deltas tension/trust sont appliqués.


**ChatGPT:**
Voici un **mini test d’intégration “pipeline réel”** qui :


* crée une **quête de médiation 3 factions** (A↔B, C médiateur)
* force un `roll` élevé pour garantir **FAILURE** via `compute_outcome_success()`
* appelle **`QuestManager.resolve_quest()`**
* assert :
	+ **ArcNotebook** reçoit bien `outcome + chance + roll`
	+ les **deltas** sont appliqués : `tension(A↔B)` ↑ et `trust(A→C)` ↓


>
> Le test **utilise tes autoloads réels** (QuestManager, ArcManagerRunner/ArcNotebook, FactionRelationsRunner si présent), mais **ne les casse pas** : il snapshot/restore ce qu’il remplace.
>
>
>


---


## `tests/Integration_QuestManager_Mediation3Factions_Test.gd`


```
extends Node
class\_name Integration\_QuestManager\_Mediation3Factions\_Test

# --- ArcNotebook stub (captures meta) ---

class StubArcNotebook:
 extends RefCounted
 var pair\_events: Array = []
 var triplet\_events: Array = []

 func record\_pair\_event(day: int, a: StringName, b: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
 pair\_events.append({"day": day, "a": a, "b": b, "action": action, "choice": choice, "meta": meta})

 func record\_triplet\_event(day: int, a: StringName, b: StringName, c: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
 triplet\_events.append({"day": day, "a": a, "b": b, "c": c, "action": action, "choice": choice, "meta": meta})

# --- Fallback relation score if your real one isn't in ClassDB ---

class TestRelationScore:
 extends RefCounted
 var relation: int = 0
 var trust: int = 50
 var tension: int = 0
 var grievance: int = 0
 var weariness: int = 0


func \_ready() -> void:
 \_test\_resolve\_quest\_mediation\_3f\_roll\_forced\_logs\_and\_deltas()
 print("\n✅ Integration\_QuestManager\_Mediation3Factions\_Test: OK\n")
 get\_tree().quit()


func \_test\_resolve\_quest\_mediation\_3f\_roll\_forced\_logs\_and\_deltas() -> void:
 # --- preconditions ---
 \_assert(ClassDB.class\_exists("QuestOutcomeUtil"), "QuestOutcomeUtil must exist")
 \_assert(ClassDB.class\_exists("ArcFailureConsequences"), "ArcFailureConsequences must exist")
 \_assert(ClassDB.class\_exists("QuestInstance"), "QuestInstance must exist")
 \_assert(ClassDB.class\_exists("QuestTemplate"), "QuestTemplate must exist")

# Find real QuestManager autoload

 var qm: Node = \_find\_first\_root\_node(["QuestManagerRunner", "QuestManager"])
 \_assert(qm != null, "Missing /root QuestManagerRunner (or QuestManager)")

# ArcManagerRunner (to host arc\_notebook)

 var arc\_mgr: Node = \_find\_first\_root\_node(["ArcManagerRunner"])
 \_assert(arc\_mgr != null, "Missing /root/ArcManagerRunner (needed for ArcNotebook logging)")

# Relations runner (optional, but we need QuestManager to find relations store)

 var rel\_runner: Node = \_find\_first\_root\_node(["FactionRelationsRunner"])
 var created\_rel\_runner := false
 if rel\_runner == null:
 rel\_runner = Node.new()
 rel\_runner.name = "FactionRelationsRunner"
 # QuestManager helper earlier expects relations\_by\_faction variable
 rel\_runner.set("relations\_by\_faction", {})
 get\_tree().root.add\_child(rel\_runner)
 created\_rel\_runner = true

 # --- snapshot & patch ArcNotebook ---
 var prev\_arc\_notebook = null
 if arc\_mgr.has\_variable("arc\_notebook"):
 prev\_arc\_notebook = arc\_mgr.arc\_notebook
 var notebook := StubArcNotebook.new()
 arc\_mgr.arc\_notebook = notebook

 # --- snapshot & patch relations store ---
 var prev\_rel\_store = null
 if rel\_runner.has\_variable("relations\_by\_faction"):
 prev\_rel\_store = rel\_runner.relations\_by\_faction

 # Build relations for A,B,C
 var A := &"A"
 var B := &"B"
 var C := &"C" # mediator

 var ScoreClass = FactionRelationScore if ClassDB.class\_exists("FactionRelationScore") else TestRelationScore
 var store := {}
 store[A] = {}
 store[B] = {}
 store[C] = {}

 store[A][B] = ScoreClass.new()
 store[B][A] = ScoreClass.new()
 store[A][C] = ScoreClass.new()
 store[B][C] = ScoreClass.new()
 store[C][A] = ScoreClass.new()
 store[C][B] = ScoreClass.new()

# high heat A<->B + neutral trust to mediator

 store[A][B].tension = 80
 store[B][A].tension = 80
 store[A][B].grievance = 70
 store[B][A].grievance = 70
 store[A][C].trust = 50
 store[B][C].trust = 50
 store[C][A].trust = 50
 store[C][B].trust = 50

 rel\_runner.relations\_by\_faction = store

 # --- create mediation QuestInstance and register as ACTIVE ---
 var template = QuestTemplate.new()
 template.id = &"tp.mediation"
 template.title = "Mediation"
 template.description = "Test mediation 3 factions"
 template.category = &"ARC"
 template.tier = 3
 template.expires\_in\_days = 7

 var inst = QuestInstance.new(template, {
 # 3 participants
 "tp\_action": &"tp.mediation",
 "giver\_faction\_id": C, # mediator is giver/actor
 "actor\_faction\_id": C,
 "antagonist\_faction\_id": A,
 "third\_party\_id": B,

 # make outcome deterministic and FAIL
 "roll": 0.95,

 # opposition precomputed so QuestManager doesn't need extra runners
 "opposition": {"tension\_mean": 85, "grievance\_mean": 75, "friction": 0.3, "resistance": 0.7},

 # day for notebook logging + seeding
 "day": 10,

 # ensure some profile exists (optional)
 "resolution\_profile\_id": &"default\_simple"
 })
 inst.runtime\_id = &"test\_mediation\_3f\_001"
 inst.status = "ACTIVE"
 inst.started\_on\_day = 10
 inst.expires\_on\_day = 17

 # Add to QuestManager active list via real method if possible
 if qm.has\_method("start\_runtime\_quest"):
 qm.start\_runtime\_quest(inst)
 else:
 # fallback: set active\_quests directly
 \_assert(qm.has\_variable("active\_quests"), "QuestManager must have active\_quests or start\_runtime\_quest()")
 qm.active\_quests[inst.runtime\_id] = inst

 # --- capture before ---
 var tension\_before := store[A][B].tension
 var trust\_a\_c\_before := store[A][C].trust

 # --- act ---
 # LOYAL attempt but should fail due to roll
 qm.resolve\_quest(inst.runtime\_id, &"LOYAL")

# --- assertions: deltas applied ---

 \_assert(store[A][B].tension > tension\_before, "tension(A→B) should increase after failed mediation (before=%d after=%d)" % [tension\_before, store[A][B].tension])
 \_assert(store[A][C].trust < trust\_a\_c\_before, "trust(A→C) should decrease after failed mediation (before=%d after=%d)" % [trust\_a\_c\_before, store[A][C].trust])

# --- assertions: ArcNotebook logged chance/roll/outcome ---

 var found := false
 for e in notebook.triplet\_events:
 if StringName(e.get("action", &"")) == &"tp.mediation":
 var meta: Dictionary = e.get("meta", {})
 \_assert(StringName(meta.get("outcome", &"")) == &"FAILURE", "notebook meta.outcome should be FAILURE")
 \_assert(meta.has("chance") and meta.has("roll"), "notebook meta should include chance + roll")
 \_assert(float(meta["roll"]) == 0.95, "notebook roll should match forced roll (0.95)")
 \_assert(float(meta["chance"]) < float(meta["roll"]), "chance should be < roll to justify failure (chance=%.3f roll=%.3f)" % [float(meta["chance"]), float(meta["roll"])])
 found = true
 break
 \_assert(found, "expected a triplet\_event for tp.mediation in ArcNotebook")

# --- restore patched state ---

 arc\_mgr.arc\_notebook = prev\_arc\_notebook
 if prev\_rel\_store != null:
 rel\_runner.relations\_by\_faction = prev\_rel\_store
 if created\_rel\_runner:
 rel\_runner.queue\_free()


func \_find\_first\_root\_node(names: Array) -> Node:
 for n in names:
 var node = get\_node\_or\_null("/root/" + String(n))
 if node != null:
 return node
 return null


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


### Notes importantes


* Le test **ne force pas `outcome_override`**, donc il passe bien par `compute_outcome_success()` et loggue `last_success_chance/last_roll`.
* Pour garantir le FAIL, on met `roll = 0.95` + opposition “chaude”.
* Le log est attendu dans `record_triplet_event` (3 factions). Si ton implémentation ne fait que `record_pair_event`, dis-le et je te donne la variante (2 asserts sur pair\_events).


Si tu veux la brique suivante : une variante “SUCCESS” (roll faible) qui vérifie l’inverse (tension↓, trust vers médiateur↑) + que la quête finit `COMPLETED` au lieu de `FAILED`.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 15](#toc-detail-ch15)
<a id="moi-102"></a>
**Moi 102:**
Ok

brique suivante : une variante “SUCCESS” (roll faible) qui vérifie l’inverse (tension↓, trust vers médiateur↑) + que la quête finit COMPLETED au lieu de FAILED.


**ChatGPT:**
Voici la **variante “SUCCESS”** (roll faible) du test d’intégration, qui vérifie :


* `outcome == SUCCESS`
* `tension(A↔B)` **baisse**
* `trust(A→C)` **augmente** (médiateur)
* la quête finit en **COMPLETED** (et pas FAILED)
* ArcNotebook reçoit bien `chance/roll/outcome`


---


## `tests/Integration_QuestManager_Mediation3Factions_Success_Test.gd`


```
extends Node
class\_name Integration\_QuestManager\_Mediation3Factions\_Success\_Test

class StubArcNotebook:
 extends RefCounted
 var pair\_events: Array = []
 var triplet\_events: Array = []

 func record\_pair\_event(day: int, a: StringName, b: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
 pair\_events.append({"day": day, "a": a, "b": b, "action": action, "choice": choice, "meta": meta})

 func record\_triplet\_event(day: int, a: StringName, b: StringName, c: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
 triplet\_events.append({"day": day, "a": a, "b": b, "c": c, "action": action, "choice": choice, "meta": meta})

class TestRelationScore:
 extends RefCounted
 var relation: int = 0
 var trust: int = 50
 var tension: int = 0
 var grievance: int = 0
 var weariness: int = 0

func \_ready() -> void:
 \_test\_resolve\_quest\_mediation\_success\_logs\_and\_inverse\_deltas()
 print("\n✅ Integration\_QuestManager\_Mediation3Factions\_Success\_Test: OK\n")
 get\_tree().quit()

func \_test\_resolve\_quest\_mediation\_success\_logs\_and\_inverse\_deltas() -> void:
 \_assert(ClassDB.class\_exists("QuestOutcomeUtil"), "QuestOutcomeUtil must exist")
 \_assert(ClassDB.class\_exists("ArcFailureConsequences"), "ArcFailureConsequences must exist")
 \_assert(ClassDB.class\_exists("QuestInstance"), "QuestInstance must exist")
 \_assert(ClassDB.class\_exists("QuestTemplate"), "QuestTemplate must exist")

 var qm: Node = \_find\_first\_root\_node(["QuestManagerRunner", "QuestManager"])
 \_assert(qm != null, "Missing /root QuestManagerRunner (or QuestManager)")

 var arc\_mgr: Node = \_find\_first\_root\_node(["ArcManagerRunner"])
 \_assert(arc\_mgr != null, "Missing /root/ArcManagerRunner")

 var rel\_runner: Node = \_find\_first\_root\_node(["FactionRelationsRunner"])
 var created\_rel\_runner := false
 if rel\_runner == null:
 rel\_runner = Node.new()
 rel\_runner.name = "FactionRelationsRunner"
 rel\_runner.set("relations\_by\_faction", {})
 get\_tree().root.add\_child(rel\_runner)
 created\_rel\_runner = true

 # --- patch notebook ---
 var prev\_arc\_notebook = null
 if arc\_mgr.has\_variable("arc\_notebook"):
 prev\_arc\_notebook = arc\_mgr.arc\_notebook
 var notebook := StubArcNotebook.new()
 arc\_mgr.arc\_notebook = notebook

 # --- relations store ---
 var prev\_rel\_store = null
 if rel\_runner.has\_variable("relations\_by\_faction"):
 prev\_rel\_store = rel\_runner.relations\_by\_faction

 var A := &"A"
 var B := &"B"
 var C := &"C" # mediator

 var ScoreClass = FactionRelationScore if ClassDB.class\_exists("FactionRelationScore") else TestRelationScore
 var store := {A: {}, B: {}, C: {}}

 store[A][B] = ScoreClass.new()
 store[B][A] = ScoreClass.new()
 store[A][C] = ScoreClass.new()
 store[B][C] = ScoreClass.new()
 store[C][A] = ScoreClass.new()
 store[C][B] = ScoreClass.new()

# baseline: conflict moderate, mediator trust neutral

 store[A][B].tension = 45
 store[B][A].tension = 45
 store[A][B].grievance = 25
 store[B][A].grievance = 25
 store[A][C].trust = 50
 store[B][C].trust = 50
 store[C][A].trust = 50
 store[C][B].trust = 50

 rel\_runner.relations\_by\_faction = store

 # --- quest instance mediation 3 factions ---
 var template = QuestTemplate.new()
 template.id = &"tp.mediation"
 template.title = "Mediation"
 template.description = "Test mediation SUCCESS"
 template.category = &"ARC"
 template.tier = 2
 template.expires\_in\_days = 7

 var inst = QuestInstance.new(template, {
 "tp\_action": &"tp.mediation",
 "giver\_faction\_id": C,
 "actor\_faction\_id": C,
 "antagonist\_faction\_id": A,
 "third\_party\_id": B,

 # force success: roll small
 "roll": 0.02,

 # opposition mild => success chance should be > 0.02
 "opposition": {"tension\_mean": 40, "grievance\_mean": 20, "friction": 0.1, "resistance": 0.55},

 "day": 10,
 "resolution\_profile\_id": &"default\_simple"
 })
 inst.runtime\_id = &"test\_mediation\_3f\_success\_001"
 inst.status = "ACTIVE"
 inst.started\_on\_day = 10
 inst.expires\_on\_day = 17

 # add to active quests
 if qm.has\_method("start\_runtime\_quest"):
 qm.start\_runtime\_quest(inst)
 else:
 \_assert(qm.has\_variable("active\_quests"), "QuestManager must have active\_quests or start\_runtime\_quest()")
 qm.active\_quests[inst.runtime\_id] = inst

 var tension\_before := store[A][B].tension
 var trust\_a\_c\_before := store[A][C].trust

 # --- act ---
 qm.resolve\_quest(inst.runtime\_id, &"LOYAL")

# --- status should be COMPLETED (not FAILED) ---

 \_assert(String(inst.status) == "COMPLETED", "quest status should be COMPLETED (got %s)" % String(inst.status))

# optional: should be removed from active\_quests

 if qm.has\_variable("active\_quests"):
 \_assert(not qm.active\_quests.has(inst.runtime\_id), "quest should be removed from active\_quests after resolve")

# --- inverse deltas: tension down, trust to mediator up ---

 \_assert(store[A][B].tension < tension\_before, "tension(A→B) should decrease on successful mediation (before=%d after=%d)" % [tension\_before, store[A][B].tension])
 \_assert(store[A][C].trust > trust\_a\_c\_before, "trust(A→C) should increase on successful mediation (before=%d after=%d)" % [trust\_a\_c\_before, store[A][C].trust])

# --- ArcNotebook meta: outcome/chance/roll ---

 var found := false
 for e in notebook.triplet\_events:
 if StringName(e.get("action", &"")) == &"tp.mediation":
 var meta: Dictionary = e.get("meta", {})
 \_assert(StringName(meta.get("outcome", &"")) == &"SUCCESS", "notebook meta.outcome should be SUCCESS")
 \_assert(meta.has("chance") and meta.has("roll"), "notebook meta should include chance + roll")
 \_assert(float(meta["roll"]) == 0.02, "notebook roll should match forced roll (0.02)")
 \_assert(float(meta["chance"]) > float(meta["roll"]), "chance should be > roll to justify success (chance=%.3f roll=%.3f)" % [float(meta["chance"]), float(meta["roll"])])
 found = true
 break
 \_assert(found, "expected a triplet\_event for tp.mediation in ArcNotebook")

# --- restore ---

 arc\_mgr.arc\_notebook = prev\_arc\_notebook
 if prev\_rel\_store != null:
 rel\_runner.relations\_by\_faction = prev\_rel\_store
 if created\_rel\_runner:
 rel\_runner.queue\_free()

func \_find\_first\_root\_node(names: Array) -> Node:
 for n in names:
 var node = get\_node\_or\_null("/root/" + String(n))
 if node != null:
 return node
 return null

func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


Si dans ton code `status` est un **enum** au lieu d’une string, dis-moi le nom exact (ex: `QuestStatus.COMPLETED`) et je te donne l’assertion compatible.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 15](#toc-detail-ch15)
<a id="moi-103"></a>
**Moi 103:**
<a id="cite-questcompletionstatus-0c9fe3-1"></a>QuestCompletionStatus


**ChatGPT:**
Parfait — du coup on remplace **toutes les assertions “COMPLETED/FAILED”** (qui étaient en string ou en `QuestTypes.Status`) par **`QuestCompletionStatus`**.


Comme on ne sait pas encore si ton `QuestInstance` expose `status` **ou** `completion_status`, je te mets un micro-helper **zéro ambiguïté** (et qui évite les erreurs “property not found”) :


```
# test\_helpers.gd (ou dans ta classe de test)

static func \_has\_prop(obj: Object, prop: String) -> bool:
 for p in obj.get\_property\_list():
 if p.name == prop:
 return true
 return false

static func \_get\_completion\_status(inst: Object) -> int:
 # Supporte tes deux variantes sans casser le parse
 if \_has\_prop(inst, "completion\_status"):
 return inst.get("completion\_status")
 return inst.get("status")
```


Ensuite, dans tes tests d’intégration “FAILURE” / “SUCCESS”, tu remplaces les asserts par :


```
# Variante FAILURE

assert\_eq(\_get\_completion\_status(inst), QuestCompletionStatus.FAILED)

# Variante SUCCESS

assert\_eq(\_get\_completion\_status(inst), QuestCompletionStatus.COMPLETED)
```


Et si dans le test tu avais aussi une assertion “quest finit COMPLETED au lieu de FAILED”, tu remplaces pareil (et tu gardes tes asserts ArcNotebook/deltas inchangés).


Si tu veux être encore plus clean côté prod (dans `QuestManager.resolve_quest()`), tu peux aussi écrire le status comme ça (sans dépendre du nom du champ) :


```
func \_set\_completion\_status(inst: Object, st: int) -> void:
 if inst == null: return
 for p in inst.get\_property\_list():
 if p.name == "completion\_status":
 inst.set("completion\_status", st)
 return
 if inst.get\_property\_list().any(func(pp): return pp.name == "status"):
 inst.set("status", st)
```


Et tu appelles `_set_completion_status(inst, QuestCompletionStatus.COMPLETED/FAILED)` au moment où tu détermines `SUCCESS/FAILURE`.


Si tu me confirmes juste **le nom exact du champ** (status vs completion\_status), je peux te donner une version simplifiée sans helper.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 15](#toc-detail-ch15)
<a id="moi-104"></a>
**Moi 104:**
Je ne suis plus sur du nom du champ

Faisons :

9) Économie : inflation narrative & rareté

Tu as escrow/or/budget. Ajoute une règle “rare” :

• si une faction est pauvre → elle propose plus souvent des quêtes non-monnayées (faveurs, accès, traités, artefacts, influence).

• inversement, riche → paye plus, mais attire opportunistes.

Effet : le monde raconte l’économie, pas juste “gold ↑”.


**ChatGPT:**
OK — là tu ajoutes une couche “le monde **raconte** l’économie”, pas juste “gold ±”. Je te propose un MVP très intégrable à ton pipeline actuel (OfferFactory → QuestPool → resolve → deltas), avec une règle rareté/inflation narrative.


## 1) Nouveau concept léger : `FactionEconomyState` + “reward\_style”


Tu as déjà l’or/budget. Ajoute 2–3 métriques dérivées (peu coûteuses) :


* `gold` (déjà)
* `liquidity` (0..1) : capacité à payer **maintenant** (ex: gold / (weekly\_expenses+1))
* `prestige` (0..1) : capacité à “payer autrement” (accès, titres, traités)
* `wealth_level` (enum) : POOR / MODEST / RICH / OPULENT (dérivé de gold+income)


**Règle centrale :**


* **POOR** → probabilité forte de récompenses **non monétaires** (faveur, accès, traité, influence, artefact, info)
* **RICH** → gold↑, mais génère du “bruit opportuniste” (fraude, vol, chantage, mercenaires)

## 2) Un “RewardBundle” data-driven (dans `context`)


Tu n’as pas besoin d’une classe au début : un dictionnaire standardisé dans le `context` suffit.


```
# context["reward\_bundle"]

{
 "gold": 0,
 "influence": 12, # monnaie politique interne
 "access": ["PORT\_PASS", "LIBRARY"],# accès/permissions
 "treaty\_clauses": ["OPEN\_TRADE"], # concessions contractuelles
 "favor\_debt": 1, # promesse future (IOU)
 "artifact\_id": "", # rare
 "intel\_tags": ["RUMOR\_X"] # info/knowledge hooks
}
```


## 3) Fonction de sélection : pauvre → non-monnaie, riche → or (et risques)

### Reward style (simple, lisible)


```
func compute\_reward\_style(econ, tier: int) -> Dictionary:
 var rich := econ.wealth\_level in [&"RICH", &"OPULENT"]
 var poor := econ.wealth\_level == &"POOR" or econ.liquidity < 0.35

 # poids (peuvent être modifiés par personnalité/axes)
 var w\_gold := 0.65 if rich else (0.15 if poor else 0.40)
 var w\_non := 1.0 - w\_gold

 # “opportunists attracted” (sert pour arcs/rumeurs)
 var opportunism\_heat := 0.10 + (0.35 if rich else 0.0) + 0.05 * tier
 return {"w\_gold": w\_gold, "w\_non": w\_non, "opportunism\_heat": opportunism\_heat}
```


### Construction du RewardBundle (MVP)


* Base reward selon tier
* Si pauvre : convertit gold en “valeurs narratives”
* Si riche : gold augmente, mais injecte un “opportunism flag”


```
func build\_reward\_bundle(faction\_id, econ, tier: int, action\_type: StringName, rng: RandomNumberGenerator) -> Dictionary:
 var style := compute\_reward\_style(econ, tier)
 var base\_gold := int(round(25 * pow(1.35, tier - 1)))

# ex: 25, 34, 46, 62, 84

 var bundle := {"gold": 0, "influence": 0, "access": [], "treaty\_clauses": [], "favor\_debt": 0, "artifact\_id": "", "intel\_tags": []}

 if rng.randf() < style.w\_gold:
 # Pay gold (rich pays more)
 var mult := 1.0 + (0.30 if econ.wealth\_level in [&"RICH", &"OPULENT"] else 0.0)
 bundle.gold = int(round(base\_gold * mult))
 else:
 # Non-monetary menu
 var points := base\_gold # “valeur” à répartir
 bundle.influence = int(round(points * 0.35))
 if rng.randf() < 0.5: bundle.access.append("ACCESS\_" + String(action\_type).to\_upper())
 if rng.randf() < 0.35: bundle.treaty\_clauses.append("OPEN\_TRADE")
 if rng.randf() < 0.25: bundle.favor\_debt += 1
 if rng.randf() < 0.15: bundle.intel\_tags.append("RUMOR\_LEAD")

# hook knowledge

 # artifact très rare, gated
 if rng.randf() < 0.03 and econ.prestige > 0.6: bundle.artifact\_id = "artifact\_roll\_me"

 return bundle
```


## 4) Résolution : appliquer “non-monnaie” comme effets monde/relations


Au resolve (SUCCESS/FAILURE), tu appliques :


* gold si présent
* sinon : `influence/access/clauses` → tags + traités + relations


Exemples d’effets narratifs (simples, puissants) :


* `favor_debt`: crée une **dette** côté giver → futur arc “repayment request” si non honorée
* `access`: débloque des **POI**/marchands/quêtes spéciales (“accès au port”, “archives”, “temple”)
* `treaty_clauses`: génère/renforce un **Treaty** (que tu avais commencé à modéliser)
* `influence`: augmente la capacité future à lever des troupes / calmer l’unrest / faire passer une trêve


## 5) Le “prix” des riches : opportunistes + fraude + banditisme


Quand `style.opportunism_heat` est élevé, tu ajoutes un **side-effect** au monde (pas forcément immédiat) :


* augmente la probabilité d’actions `tp.opportunism` / `arc.heist` / `forge_evidence`
* ou crée des offers “shakedown”, “embezzle”, “steal payroll”
* (optionnel) génère des rumeurs “rich convoy”, “tribute wagon”


Concrètement : dans ton `ArcNotebook`, record un flag :


```
ctx["opportunism\_heat"] = style.opportunism\_heat
```


Et dans ton tick (Arc/Coalition/Knowledge) : si heat>0.35, autorise 1 offer opportuniste/jour max autour de cette faction.


## 6) Rareté (la partie “rare”)


Sans sim complexe, tu peux rendre rare par **inventaire de concessions** :


* `econ.concession_tokens` (0..N) : quand pauvre offre “access/treaty”, ça consomme 1 token
* tokens se régénèrent lentement (1/10 jours) ou via goals (commerce, stabilité)
* si tokens à 0 → pauvre ne peut proposer que `favor_debt` / `intel` / petites récompenses


Ça empêche : “pauvre mais distribue 50 accès/traités”.


## 7) Où brancher ça chez toi


* **OfferFactory.spawn\_offer\_for\_pair / DomesticOfferFactory / ThirdPartyOfferFactory**
	+ construit `reward_bundle` selon économie du giver
	+ stocke dans `context`
* **QuestManager.resolve\_quest(...)**
	+ après outcome/choice, applique `reward_bundle` (SUCCESS surtout, FAILURE peut aussi créer dette/rumor)

## 8) Mini règle UX (important)


Affiche au joueur des récompenses “non-gold” comme des **bénéfices concrets** :


* “Accès au Port (7 jours)”
* “Clause de libre-échange (Treaty)”
* “Faveur due : +1 (utilisable pour forcer une audience / aide)”

Sinon le joueur pense “récompense nulle”.


Si tu veux, prochaine brique : un mini test statistique (50 offers POOR vs RICH) qui assert que **POOR génère majoritairement non-gold** et **RICH majoritairement gold**, et qu’un flag `opportunism_heat` est bien plus haut chez RICH.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 16](#toc-detail-ch16)
<a id="moi-105"></a>
**Moi 105:**
Ok

prochaine brique : un mini test statistique (50 offers POOR vs RICH) qui assert que POOR génère majoritairement non-gold et RICH majoritairement gold, et qu’un flag opportunism\_heat est bien plus haut chez RICH.


**ChatGPT:**
Voici un **mini test statistique déterministe** (50 offers POOR vs 50 offers RICH) qui vérifie :


* **POOR** → majoritairement **non-gold**
* **RICH** → majoritairement **gold**
* `opportunism_heat` est **nettement plus haut** chez RICH


Je te mets aussi la mini util `RewardEconomyUtil.gd` (si tu ne l’as pas encore). Le test utilise un RNG seedé ⇒ **pas flaky**.


---


## `RewardEconomyUtil.gd`


```
# RewardEconomyUtil.gd

class\_name RewardEconomyUtil
extends RefCounted

static func compute\_reward\_style(econ: Dictionary, tier: int) -> Dictionary:
 var wealth: StringName = StringName(econ.get("wealth\_level", &"MODEST"))
 var liquidity: float = float(econ.get("liquidity", 0.5))

 var rich := (wealth == &"RICH" or wealth == &"OPULENT")
 var poor := (wealth == &"POOR" or liquidity < 0.35)

# Gold weight: poor -> low, rich -> high

 var w\_gold := 0.78 if rich else (0.12 if poor else 0.42)
 var w\_non := 1.0 - w\_gold

 # “Riche attire opportunistes”
 var opportunism\_heat := 0.10 + (0.35 if rich else 0.0) + 0.05 * float(tier)
 opportunism\_heat = clampf(opportunism\_heat, 0.0, 1.0)

 return {"w\_gold": w\_gold, "w\_non": w\_non, "opportunism\_heat": opportunism\_heat}


static func build\_reward\_bundle(econ: Dictionary, tier: int, action\_type: StringName, rng: RandomNumberGenerator) -> Dictionary:
 var style := compute\_reward\_style(econ, tier)
 var base\_gold := int(round(25.0 * pow(1.35, float(tier - 1))))

# 25,34,46,62,84...

 var bundle := {
 "gold": 0,
 "influence": 0,
 "access": [],
 "treaty\_clauses": [],
 "favor\_debt": 0,
 "artifact\_id": "",
 "intel\_tags": [],
 "opportunism\_heat": float(style.opportunism\_heat)
 }

 if rng.randf() < float(style.w\_gold):
 var wealth: StringName = StringName(econ.get("wealth\_level", &"MODEST"))
 var mult := 1.0 + (0.30 if (wealth == &"RICH" or wealth == &"OPULENT") else 0.0)
 bundle.gold = int(round(float(base\_gold) * mult))
 return bundle

 # non-gold
 var points := base\_gold
 bundle.influence = int(round(points * 0.35))

 if rng.randf() < 0.55:
 bundle.access.append("ACCESS\_" + String(action\_type).to\_upper())

 if rng.randf() < 0.40:
 bundle.treaty\_clauses.append("OPEN\_TRADE")

 if rng.randf() < 0.30:
 bundle.favor\_debt = 1

 if rng.randf() < 0.20:
 bundle.intel\_tags.append("RUMOR\_LEAD")

# artefact très rare et gated par prestige

 var prestige: float = float(econ.get("prestige", 0.5))
 if rng.randf() < 0.03 and prestige > 0.6:
 bundle.artifact\_id = "artifact\_roll\_me"

 return bundle


static func is\_non\_gold(bundle: Dictionary) -> bool:
 if int(bundle.get("gold", 0)) > 0:
 return false
 return (
 int(bundle.get("influence", 0)) > 0
 or int(bundle.get("favor\_debt", 0)) > 0
 or String(bundle.get("artifact\_id", "")) != ""
 or (bundle.get("access", []) as Array).size() > 0
 or (bundle.get("treaty\_clauses", []) as Array).size() > 0
 or (bundle.get("intel\_tags", []) as Array).size() > 0
 )
```


---


## Test : `tests/EconomyRewardStyleStatTest.gd`


```
extends Node
class\_name EconomyRewardStyleStatTest

func \_ready() -> void:
 \_test\_poor\_vs\_rich\_reward\_distribution\_and\_opportunism\_heat()
 print("\n✅ EconomyRewardStyleStatTest: OK\n")
 get\_tree().quit()

func \_test\_poor\_vs\_rich\_reward\_distribution\_and\_opportunism\_heat() -> void:
 \_assert(ClassDB.class\_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

 var rng := RandomNumberGenerator.new()
 rng.seed = 13371337 # déterministe

 var tier := 3
 var action := &"arc.truce\_talks"

 var econ\_poor := {
 "wealth\_level": &"POOR",
 "liquidity": 0.20,
 "prestige": 0.45
 }
 var econ\_rich := {
 "wealth\_level": &"RICH",
 "liquidity": 0.85,
 "prestige": 0.75
 }

 var poor\_gold := 0
 var poor\_non := 0
 var poor\_heat\_sum := 0.0

 for i in range(50):
 var b := RewardEconomyUtil.build\_reward\_bundle(econ\_poor, tier, action, rng)
 poor\_heat\_sum += float(b.get("opportunism\_heat", 0.0))
 if int(b.get("gold", 0)) > 0:
 poor\_gold += 1
 elif RewardEconomyUtil.is\_non\_gold(b):
 poor\_non += 1

 var rich\_gold := 0
 var rich\_non := 0
 var rich\_heat\_sum := 0.0

 for i in range(50):
 var b := RewardEconomyUtil.build\_reward\_bundle(econ\_rich, tier, action, rng)
 rich\_heat\_sum += float(b.get("opportunism\_heat", 0.0))
 if int(b.get("gold", 0)) > 0:
 rich\_gold += 1
 elif RewardEconomyUtil.is\_non\_gold(b):
 rich\_non += 1

 var poor\_heat\_avg := poor\_heat\_sum / 50.0
 var rich\_heat\_avg := rich\_heat\_sum / 50.0

 # --- asserts “statistiques” robustes ---
 # Poor: très majoritairement non-gold
 \_assert(poor\_non >= 32, "POOR should generate mostly non-gold (expected >=32/50, got %d) | gold=%d" % [poor\_non, poor\_gold])

# Rich: très majoritairement gold

 \_assert(rich\_gold >= 32, "RICH should generate mostly gold (expected >=32/50, got %d) | non\_gold=%d" % [rich\_gold, rich\_non])

# Opportunism heat: rich >> poor

 \_assert(rich\_heat\_avg > poor\_heat\_avg + 0.25,
 "opportunism\_heat should be much higher for RICH (poor=%.3f rich=%.3f)" % [poor\_heat\_avg, rich\_heat\_avg])

# sanity: heat ranges

 \_assert(poor\_heat\_avg >= 0.0 and poor\_heat\_avg <= 1.0, "poor heat avg out of range")
 \_assert(rich\_heat\_avg >= 0.0 and rich\_heat\_avg <= 1.0, "rich heat avg out of range")


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


Si tu veux la suite logique : je te propose un 2e test qui vérifie qu’en **mode pauvre**, la “valeur” totale attendue (influence+faveur+clauses) reste cohérente avec le tier (pour éviter une économie “pauvre mais trop généreuse”).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 16](#toc-detail-ch16)
<a id="moi-106"></a>
**Moi 106:**
Ok

propose un 2e test qui vérifie qu’en mode pauvre, la “valeur” totale attendue (influence+faveur+clauses) reste cohérente avec le tier (pour éviter une économie “pauvre mais trop généreuse”).


**ChatGPT:**
Voici un **2e test** (toujours déterministe) qui vérifie, pour une faction **POOR**, que la **valeur moyenne** des récompenses **non-gold** augmente avec le tier mais reste **bornée** (donc pas “pauvre mais trop généreuse”).


L’idée : définir une fonction “proxy de valeur” simple et stable :


* `influence` : 1 point = 1 valeur
* `favor_debt` : +20 (gros levier narratif)
* `OPEN_TRADE` (clause) : +12
* `ACCESS_*` : +8
* `intel_tags` : +6
* `artifact_id` : +60 (rare)


Puis on teste :

1) `avg_value(tier 5) > avg_value(tier 2)` (cohérence de progression)

2) `avg_value(tier t)` reste dans une enveloppe raisonnable, ex :


* tier2: 10..55
* tier3: 15..65
* tier4: 20..80
* tier5: 25..95


---


## `tests/PoorNonGoldValueCoherenceTest.gd`


```
extends Node
class\_name PoorNonGoldValueCoherenceTest

func \_ready() -> void:
 \_test\_poor\_non\_gold\_value\_scales\_with\_tier\_but\_is\_bounded()
 print("\n✅ PoorNonGoldValueCoherenceTest: OK\n")
 get\_tree().quit()

func \_test\_poor\_non\_gold\_value\_scales\_with\_tier\_but\_is\_bounded() -> void:
 \_assert(ClassDB.class\_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

 var econ\_poor := {
 "wealth\_level": &"POOR",
 "liquidity": 0.18,
 "prestige": 0.50
 }

 var action := &"arc.truce\_talks"
 var n := 80 # plus stable que 50, toujours rapide

 var avg2 := \_avg\_value\_for\_tier(econ\_poor, 2, action, n, 20201)
 var avg3 := \_avg\_value\_for\_tier(econ\_poor, 3, action, n, 20202)
 var avg4 := \_avg\_value\_for\_tier(econ\_poor, 4, action, n, 20203)
 var avg5 := \_avg\_value\_for\_tier(econ\_poor, 5, action, n, 20204)

# 1) Croissance cohérente (pas forcément strictement monotone à 1e-6, mais tendance nette)

 \_assert(avg5 > avg2 + 8.0, "expected avg non-gold value to increase with tier (avg2=%.1f avg5=%.1f)" % [avg2, avg5])

# 2) Bornes anti “pauvre trop généreux”

 \_assert(avg2 >= 10.0 and avg2 <= 55.0, "tier2 avg out of bounds (%.1f) expected [10..55]" % avg2)
 \_assert(avg3 >= 15.0 and avg3 <= 65.0, "tier3 avg out of bounds (%.1f) expected [15..65]" % avg3)
 \_assert(avg4 >= 20.0 and avg4 <= 80.0, "tier4 avg out of bounds (%.1f) expected [20..80]" % avg4)
 \_assert(avg5 >= 25.0 and avg5 <= 95.0, "tier5 avg out of bounds (%.1f) expected [25..95]" % avg5)


func \_avg\_value\_for\_tier(econ: Dictionary, tier: int, action: StringName, n: int, seed: int) -> float:
 var rng := RandomNumberGenerator.new()
 rng.seed = seed

 var total := 0.0
 var count := 0

 for i in range(n):
 var b := RewardEconomyUtil.build\_reward\_bundle(econ, tier, action, rng)

# On mesure seulement le mode non-gold (c’est ce qu’on veut contrôler chez POOR)

 if int(b.get("gold", 0)) > 0:
 continue

 var v := \_value\_proxy(b)
 total += v
 count += 1

 # si jamais trop de gold (devrait être rare en POOR), on sécurise
 if count == 0:
 return 0.0
 return total / float(count)


func \_value\_proxy(bundle: Dictionary) -> float:
 var v := 0.0

 # influence
 v += float(int(bundle.get("influence", 0))) * 1.0

 # favor debt: très puissant narrativement
 v += float(int(bundle.get("favor\_debt", 0))) * 20.0

 # clauses
 var clauses: Array = bundle.get("treaty\_clauses", [])
 for c in clauses:
 if String(c) == "OPEN\_TRADE":
 v += 12.0
 else:
 v += 10.0

 # access
 var access: Array = bundle.get("access", [])
 v += float(access.size()) * 8.0

 # intel
 var intel: Array = bundle.get("intel\_tags", [])
 v += float(intel.size()) * 6.0

 # artifact: rare mais énorme
 if String(bundle.get("artifact\_id", "")) != "":
 v += 60.0

 return v


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


### Pourquoi ce test est utile


* Il t’évite de “casser” l’économie narrative en retouchant un poids (favor/access/treaty).
* Il garantit que le tier garde du sens, même si la faction paye en “politique” plutôt qu’en or.


Si tu veux, prochaine brique logique : un test équivalent côté **RICH** qui vérifie que `gold` scale bien avec tier *mais* que la variance n’explose pas (inflation contrôlée).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 16](#toc-detail-ch16)
<a id="moi-107"></a>
**Moi 107:**
Ok

prochaine brique logique : un test équivalent côté RICH qui vérifie que gold scale bien avec tier mais que la variance n’explose pas (inflation contrôlée).


**ChatGPT:**
Voici un **test équivalent côté RICH** qui vérifie :


1) `avg_gold(tier5) > avg_gold(tier2)` (gold scale bien avec tier)

2) la variance reste contrôlée : **coefficient de variation** `cv = std/mean` **< 0.6** (tu peux ajuster)

3) bonus : la moyenne suit à peu près la formule attendue (sans être trop stricte)


>
> Test déterministe : RNG seedé, 120 tirages par tier.
>
>
>


---


## `tests/RichGoldScalingAndVarianceTest.gd`


```
extends Node
class\_name RichGoldScalingAndVarianceTest

func \_ready() -> void:
 \_test\_rich\_gold\_scales\_with\_tier\_and\_variance\_is\_controlled()
 print("\n✅ RichGoldScalingAndVarianceTest: OK\n")
 get\_tree().quit()

func \_test\_rich\_gold\_scales\_with\_tier\_and\_variance\_is\_controlled() -> void:
 \_assert(ClassDB.class\_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

 var econ\_rich := {
 "wealth\_level": &"RICH",
 "liquidity": 0.90,
 "prestige": 0.80
 }

 var action := &"arc.raid"
 var n := 120

 var s2 := \_gold\_stats\_for\_tier(econ\_rich, 2, action, n, 33002)
 var s3 := \_gold\_stats\_for\_tier(econ\_rich, 3, action, n, 33003)
 var s4 := \_gold\_stats\_for\_tier(econ\_rich, 4, action, n, 33004)
 var s5 := \_gold\_stats\_for\_tier(econ\_rich, 5, action, n, 33005)

# 1) scaling

 \_assert(s5.mean > s2.mean + 25.0, "avg gold should increase with tier (t2=%.1f t5=%.1f)" % [s2.mean, s5.mean])
 \_assert(s5.mean > s4.mean, "avg gold should be increasing (t4=%.1f t5=%.1f)" % [s4.mean, s5.mean])

# 2) variance control via coefficient of variation

 # (0.6 is generous; if you want tighter economy, drop to 0.4)
 \_assert(s2.cv < 0.6, "tier2 gold CV too high: %.3f (mean=%.1f std=%.1f)" % [s2.cv, s2.mean, s2.std])
 \_assert(s3.cv < 0.6, "tier3 gold CV too high: %.3f (mean=%.1f std=%.1f)" % [s3.cv, s3.mean, s3.std])
 \_assert(s4.cv < 0.6, "tier4 gold CV too high: %.3f (mean=%.1f std=%.1f)" % [s4.cv, s4.mean, s4.std])
 \_assert(s5.cv < 0.6, "tier5 gold CV too high: %.3f (mean=%.1f std=%.1f)" % [s5.cv, s5.mean, s5.std])

# 3) sanity bounds (avoid runaway inflation)

# base\_gold approx: tier2 ~34, tier5 ~84, rich mult ~1.3, plus selection probability.

 # We'll just enforce "not absurd"
 \_assert(s2.mean >= 15.0 and s2.mean <= 80.0, "tier2 mean gold out of bounds (%.1f)" % s2.mean)
 \_assert(s5.mean >= 35.0 and s5.mean <= 160.0, "tier5 mean gold out of bounds (%.1f)" % s5.mean)


class Stats:
 var mean: float
 var std: float
 var cv: float
 func \_init(m: float, s: float) -> void:
 mean = m
 std = s
 cv = (s / m) if m > 0.0001 else 999.0


func \_gold\_stats\_for\_tier(econ: Dictionary, tier: int, action: StringName, n: int, seed: int) -> Stats:
 var rng := RandomNumberGenerator.new()
 rng.seed = seed

 var xs: Array[float] = []
 xs.resize(0)

 for i in range(n):
 var b := RewardEconomyUtil.build\_reward\_bundle(econ, tier, action, rng)
 var g := float(int(b.get("gold", 0)))

# For rich test, we include 0 gold outcomes too: it’s part of the "style".

 xs.append(g)

 var m := \_mean(xs)
 var s := \_std(xs, m)
 return Stats.new(m, s)


func \_mean(xs: Array[float]) -> float:
 if xs.is\_empty(): return 0.0
 var sum := 0.0
 for x in xs: sum += x
 return sum / float(xs.size())


func \_std(xs: Array[float], mean: float) -> float:
 if xs.size() <= 1: return 0.0
 var acc := 0.0
 for x in xs:
 var d := x - mean
 acc += d * d
 return sqrt(acc / float(xs.size() - 1))


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


### Si ce test échoue (2 causes probables)


* ton `RewardEconomyUtil` donne trop souvent des “non-gold” même en RICH (w\_gold trop bas)
* ou tu as ajouté des multiplicateurs aléatoires trop forts (variance trop élevée)


Dans ce cas, la correction la plus simple est :


* augmenter `w_gold` pour RICH (ex: 0.85)
* ou rendre le gold moins “spiky” (ex: `gold = round(base_gold * mult * lerp(0.9,1.1,rng.randf()))` au lieu de grosses variations)


Si tu veux, prochaine brique logique : lier la “variance” à la **personnalité** (ex: greedy/chaotic => variance↑, bureaucratic => variance↓), tout en gardant ce test vert grâce à des bornes.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 16](#toc-detail-ch16)
<a id="moi-108"></a>
**Moi 108:**
Ok

prochaine brique logique : lier la “variance” à la personnalité (ex: greedy/chaotic => variance↑, bureaucratic => variance↓), tout en gardant ce test vert grâce à des bornes.


**ChatGPT:**
OK — on peut lier la **variance du gold** à la **personnalité** sans casser tes tests en :


* gardant une variance **bornée** (ex: ±4% à ±22%)
* appliquant la variance **uniquement quand la récompense est en gold** (pas sur le choix gold vs non-gold)
* laissant un **comportement par défaut** (profil = null) “sage” → tes tests actuels restent verts


---


## 1) Patch `RewardEconomyUtil.gd` : variance pilotée par personnalité


Modifs :


* `build_reward_bundle(..., profile := null)` (param optionnel)
* ajoute `_gold_variance_amp(profile)` basé sur `opportunism/aggression/discipline/honor`
* applique un bruit multiplicatif `uniform[1-amp, 1+amp]` **symétrique** (moyenne stable)


```
# RewardEconomyUtil.gd

class\_name RewardEconomyUtil
extends RefCounted

static func compute\_reward\_style(econ: Dictionary, tier: int) -> Dictionary:
 var wealth: StringName = StringName(econ.get("wealth\_level", &"MODEST"))
 var liquidity: float = float(econ.get("liquidity", 0.5))

 var rich := (wealth == &"RICH" or wealth == &"OPULENT")
 var poor := (wealth == &"POOR" or liquidity < 0.35)

 var w\_gold := 0.78 if rich else (0.12 if poor else 0.42)
 var w\_non := 1.0 - w\_gold

 var opportunism\_heat := 0.10 + (0.35 if rich else 0.0) + 0.05 * float(tier)
 opportunism\_heat = clampf(opportunism\_heat, 0.0, 1.0)

 return {"w\_gold": w\_gold, "w\_non": w\_non, "opportunism\_heat": opportunism\_heat}


# ✅ NOUVEAU: profile optionnel

static func build\_reward\_bundle(econ: Dictionary, tier: int, action\_type: StringName, rng: RandomNumberGenerator, profile := null) -> Dictionary:
 var style := compute\_reward\_style(econ, tier)
 var base\_gold := int(round(25.0 * pow(1.35, float(tier - 1))))

 var bundle := {
 "gold": 0,
 "influence": 0,
 "access": [],
 "treaty\_clauses": [],
 "favor\_debt": 0,
 "artifact\_id": "",
 "intel\_tags": [],
 "opportunism\_heat": float(style.opportunism\_heat)
 }

 if rng.randf() < float(style.w\_gold):
 var wealth: StringName = StringName(econ.get("wealth\_level", &"MODEST"))
 var mult := 1.0 + (0.30 if (wealth == &"RICH" or wealth == &"OPULENT") else 0.0)

# ✅ variance bornée par personnalité

 var amp := \_gold\_variance\_amp(profile)

# 0.04 .. 0.22

 var noise := rng.randf\_range(1.0 - amp, 1.0 + amp)
 bundle.gold = int(round(float(base\_gold) * mult * noise))

# debug optionnel

 bundle["gold\_var\_amp"] = amp
 return bundle

 # non-gold
 var points := base\_gold
 bundle.influence = int(round(points * 0.35))

 if rng.randf() < 0.55:
 bundle.access.append("ACCESS\_" + String(action\_type).to\_upper())
 if rng.randf() < 0.40:
 bundle.treaty\_clauses.append("OPEN\_TRADE")
 if rng.randf() < 0.30:
 bundle.favor\_debt = 1
 if rng.randf() < 0.20:
 bundle.intel\_tags.append("RUMOR\_LEAD")

 var prestige: float = float(econ.get("prestige", 0.5))
 if rng.randf() < 0.03 and prestige > 0.6:
 bundle.artifact\_id = "artifact\_roll\_me"

 return bundle


static func is\_non\_gold(bundle: Dictionary) -> bool:
 if int(bundle.get("gold", 0)) > 0:
 return false
 return (
 int(bundle.get("influence", 0)) > 0
 or int(bundle.get("favor\_debt", 0)) > 0
 or String(bundle.get("artifact\_id", "")) != ""
 or (bundle.get("access", []) as Array).size() > 0
 or (bundle.get("treaty\_clauses", []) as Array).size() > 0
 or (bundle.get("intel\_tags", []) as Array).size() > 0
 )

# -----------------------

# ✅ Variance par personnalité

# -----------------------

static func \_gold\_variance\_amp(profile) -> float:
 # mapping: greedy/chaotic => opp/aggr ↑ ; bureaucratic => discipline/honor ↑
 # profile attendu: FactionProfile ou Dictionary {"personality":{...}} ou dict direct
 var opp := \_p(profile, &"opportunism", 0.5)
 var agr := \_p(profile, &"aggression", 0.5)
 var dis := \_p(profile, &"discipline", 0.5)
 var hon := \_p(profile, &"honor", 0.5)

# volatility 0..1 (bornée)

 var vol := 0.20 + 0.45*opp + 0.25*agr - 0.55*dis - 0.20*hon
 vol = clampf(vol, 0.0, 1.0)

# amplitude finale bornée => garde l'inflation contrôlée + tests verts

 return lerp(0.04, 0.22, vol)


static func \_p(profile, key: StringName, default\_val: float) -> float:
 if profile == null:
 return default\_val
 if profile.has\_method("get\_personality"):
 return float(profile.get\_personality(key, default\_val))
 if profile is Dictionary:
 if profile.has("personality"):
 return float(profile["personality"].get(key, default\_val))
 return float(profile.get(key, default\_val))
 return default\_val
```


✅ **Tes tests existants restent verts** parce que :


* ils appellent `build_reward_bundle(..., rng)` sans profil ⇒ profil `null` ⇒ amp modérée (≈ 8–10% en pratique avec vol ~0.2–0.3)


---


## 2) Nouveau test : variance greedy/chaotic > bureaucratic (mais bornée)


Ce test compare la variance **sur les tirages où `gold>0`** (sinon le mix gold/non-gold pollue la mesure).


### `tests/RichGoldVarianceByPersonalityTest.gd`


```
extends Node
class\_name RichGoldVarianceByPersonalityTest

func \_ready() -> void:
 \_test\_rich\_gold\_variance\_depends\_on\_personality\_but\_stays\_bounded()
 print("\n✅ RichGoldVarianceByPersonalityTest: OK\n")
 get\_tree().quit()

func \_test\_rich\_gold\_variance\_depends\_on\_personality\_but\_stays\_bounded() -> void:
 \_assert(ClassDB.class\_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

 var econ\_rich := {"wealth\_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}
 var tier := 4
 var action := &"arc.raid"
 var n := 220

 # “greedy/chaotic” => variance ↑
 var prof\_chaos := {"personality": {&"opportunism": 0.90, &"aggression": 0.80, &"discipline": 0.20, &"honor": 0.20}}
 # “bureaucratic” => variance ↓
 var prof\_bureau := {"personality": {&"opportunism": 0.20, &"aggression": 0.20, &"discipline": 0.90, &"honor": 0.70}}

 var s\_chaos := \_gold\_stats\_positive\_only(econ\_rich, tier, action, n, 77111, prof\_chaos)
 var s\_buro := \_gold\_stats\_positive\_only(econ\_rich, tier, action, n, 77112, prof\_bureau)

# variance chaotique > bureaucratique

 \_assert(s\_chaos.cv > s\_buro.cv + 0.05,
 "expected higher CV for chaotic profile (chaos=%.3f buro=%.3f)" % [s\_chaos.cv, s\_buro.cv])

# bornes “inflation contrôlée”

 \_assert(s\_chaos.cv < 0.25, "chaos CV too high: %.3f (mean=%.1f std=%.1f)" % [s\_chaos.cv, s\_chaos.mean, s\_chaos.std])
 \_assert(s\_buro.cv < 0.15, "buro CV too high: %.3f (mean=%.1f std=%.1f)" % [s\_buro.cv, s\_buro.mean, s\_buro.std])

# moyenne quasi inchangée (bruit symétrique)

 \_assert(abs(s\_chaos.mean - s\_buro.mean) / max(1.0, s\_buro.mean) < 0.12,
 "mean should stay roughly stable across personalities (chaos=%.1f buro=%.1f)" % [s\_chaos.mean, s\_buro.mean])


class Stats:
 var mean: float
 var std: float
 var cv: float
 func \_init(m: float, s: float) -> void:
 mean = m
 std = s
 cv = (s / m) if m > 0.0001 else 999.0


func \_gold\_stats\_positive\_only(econ: Dictionary, tier: int, action: StringName, n: int, seed: int, profile) -> Stats:
 var rng := RandomNumberGenerator.new()
 rng.seed = seed

 var xs: Array[float] = []
 for i in range(n):
 var b := RewardEconomyUtil.build\_reward\_bundle(econ, tier, action, rng, profile)
 var g := float(int(b.get("gold", 0)))
 if g > 0.0:
 xs.append(g)

 \_assert(xs.size() >= int(0.5 * n), "too few gold samples; check w\_gold for rich (got %d/%d)" % [xs.size(), n])

 var m := \_mean(xs)
 var s := \_std(xs, m)
 return Stats.new(m, s)


func \_mean(xs: Array[float]) -> float:
 var sum := 0.0
 for x in xs: sum += x
 return sum / float(xs.size())

func \_std(xs: Array[float], mean: float) -> float:
 var acc := 0.0
 for x in xs:
 var d := x - mean
 acc += d * d
 return sqrt(acc / float(xs.size() - 1))


func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


## 3) Où le brancher “pour de vrai”


Dans ton `OfferFactory.spawn_offer_*` (ou là où tu construis `reward_bundle`) :


* récupère le **FactionProfile** du giver (ou acteur)
* appelle `RewardEconomyUtil.build_reward_bundle(econ, tier, action_type, rng, giver_profile)`


Ça donne immédiatement :


* factions chaotiques/opportunistes → récompenses gold plus “spiky”
* factions bureaucratiques → gold plus stable, plus “prévisible”
* sans explosion de variance (tests bornés)


Si tu veux la brique suivante : faire dépendre **w\_gold** (pas juste la variance) de la personnalité aussi (ex: “greed” augmente la part monétaire), tout en gardant les tests statistiques stables.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 16](#toc-detail-ch16)
<a id="moi-109"></a>
**Moi 109:**
Ok

brique suivante : faire dépendre w\_gold (pas juste la variance) de la personnalité aussi (ex: “greed” augmente la part monétaire), tout en gardant les tests statistiques stables.


**ChatGPT:**
OK — on fait dépendre **`w_gold`** de la personnalité, mais de façon **bornée** pour ne pas casser tes tests “POOR majoritairement non-gold” / “RICH majoritairement gold”.


Principe :


* on calcule un `w_gold_base` à partir de l’économie (POOR/RICH/liquidité)
* on applique un **delta personality** `Δw` dans une fenêtre **petite et clampée** (ex: ±0.12)
* puis on **re-clamp** selon le wealth level (ex: POOR max 0.35, RICH min 0.60)


---


## 1) Patch `RewardEconomyUtil.compute_reward_style(...)` + helpers


### A) `compute_reward_style(econ, tier, profile := null)` (signature étendue)


```
# RewardEconomyUtil.gd

static func compute\_reward\_style(econ: Dictionary, tier: int, profile := null) -> Dictionary:
 var wealth: StringName = StringName(econ.get("wealth\_level", &"MODEST"))
 var liquidity: float = float(econ.get("liquidity", 0.5))

 var rich := (wealth == &"RICH" or wealth == &"OPULENT")
 var poor := (wealth == &"POOR" or liquidity < 0.35)

# base stable

 var w\_gold\_base := 0.78 if rich else (0.12 if poor else 0.42)

# --- personality delta (bounded) ---

 var dw := \_w\_gold\_personality\_delta(profile)

# [-0.12..+0.12]

 var w\_gold := clampf(w\_gold\_base + dw, 0.05, 0.95)

# --- guard rails to keep tests stable ---

 if poor:
 w\_gold = min(w\_gold, 0.35)

# poor ne paye presque jamais en or

 if rich:
 w\_gold = max(w\_gold, 0.60)

# rich paye souvent en or

 var w\_non := 1.0 - w\_gold

 # opportunism heat: econ-driven (peut aussi être affecté par personnalité mais pas obligé)
 var opportunism\_heat := 0.10 + (0.35 if rich else 0.0) + 0.05 * float(tier)
 opportunism\_heat = clampf(opportunism\_heat, 0.0, 1.0)

 return {"w\_gold": w\_gold, "w\_non": w\_non, "opportunism\_heat": opportunism\_heat, "w\_gold\_base": w\_gold\_base, "w\_gold\_dw": dw}


static func \_w\_gold\_personality\_delta(profile) -> float:
 # Greedy/mercantile/opportunist -> w\_gold ↑
 # Honor/discipline/idealist -> w\_gold ↓ (plus de faveurs/traités)
 var greed := \_p(profile, &"greed", 0.5)

# si tu n’as pas ce trait, laisse 0.5

 var opp := \_p(profile, &"opportunism", 0.5)
 var dis := \_p(profile, &"discipline", 0.5)
 var hon := \_p(profile, &"honor", 0.5)

# “greed” est dominant, sinon opportunism fait le job

 var raw := 0.60*(greed - 0.5) + 0.35*(opp - 0.5) - 0.25*(dis - 0.5) - 0.20*(hon - 0.5)

# Borné pour stabilité

 return clampf(raw, -0.12, 0.12)
```


### B) `build_reward_bundle` appelle `compute_reward_style(..., profile)`


```
static func build\_reward\_bundle(econ: Dictionary, tier: int, action\_type: StringName, rng: RandomNumberGenerator, profile := null) -> Dictionary:
 var style := compute\_reward\_style(econ, tier, profile)

# ...

 if rng.randf() < float(style.w\_gold):
 # gold ...
```


✅ Résultat :


* une faction “greedy” RICH tend vers 0.85–0.90 gold
* une faction “honorable/bureaucratic” RICH peut descendre vers 0.60–0.70 (mais jamais <0.60)
* une faction POOR peut monter un peu, mais jamais >0.35


---


## 2) Garder les tests verts (stabilité)

### Pourquoi ça ne casse pas tes tests existants


* **POOR** : `w_gold ≤ 0.35` ⇒ majoritairement non-gold reste vrai
* **RICH** : `w_gold ≥ 0.60` ⇒ majoritairement gold reste vrai
* ton test précédent utilisait `build_reward_bundle(econ, tier, action, rng)` sans profil ⇒ `dw≈0`, comportement inchangé.


---


## 3) Nouveau mini test : `w_gold` varie avec la personnalité mais reste dans les rails


Ce test vérifie :


* greedy > honor en `w_gold`
* poor clamp ≤ 0.35
* rich clamp ≥ 0.60


```
# tests/WGoldPersonalityClampedTest.gd

extends Node
class\_name WGoldPersonalityClampedTest

func \_ready() -> void:
 \_test\_w\_gold\_depends\_on\_personality\_but\_is\_clamped\_by\_economy()
 print("\n✅ WGoldPersonalityClampedTest: OK\n")
 get\_tree().quit()

func \_test\_w\_gold\_depends\_on\_personality\_but\_is\_clamped\_by\_economy() -> void:
 \_assert(ClassDB.class\_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

 var tier := 3

 var econ\_poor := {"wealth\_level": &"POOR", "liquidity": 0.20, "prestige": 0.40}
 var econ\_rich := {"wealth\_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}

 var prof\_greedy := {"personality": {&"greed": 0.95, &"opportunism": 0.85, &"discipline": 0.30, &"honor": 0.25}}
 var prof\_honorable := {"personality": {&"greed": 0.15, &"opportunism": 0.20, &"discipline": 0.85, &"honor": 0.85}}

 var s\_poor\_g := RewardEconomyUtil.compute\_reward\_style(econ\_poor, tier, prof\_greedy)
 var s\_poor\_h := RewardEconomyUtil.compute\_reward\_style(econ\_poor, tier, prof\_honorable)
 var s\_rich\_g := RewardEconomyUtil.compute\_reward\_style(econ\_rich, tier, prof\_greedy)
 var s\_rich\_h := RewardEconomyUtil.compute\_reward\_style(econ\_rich, tier, prof\_honorable)

 \_assert(float(s\_poor\_g.w\_gold) <= 0.35, "POOR greedy w\_gold must be clamped <= 0.35 (got %.3f)" % float(s\_poor\_g.w\_gold))
 \_assert(float(s\_poor\_h.w\_gold) <= 0.35, "POOR honorable w\_gold must be clamped <= 0.35 (got %.3f)" % float(s\_poor\_h.w\_gold))

 \_assert(float(s\_rich\_g.w\_gold) >= 0.60, "RICH greedy w\_gold must be clamped >= 0.60 (got %.3f)" % float(s\_rich\_g.w\_gold))
 \_assert(float(s\_rich\_h.w\_gold) >= 0.60, "RICH honorable w\_gold must be clamped >= 0.60 (got %.3f)" % float(s\_rich\_h.w\_gold))

# personality effect visible (within rails)

 \_assert(float(s\_rich\_g.w\_gold) > float(s\_rich\_h.w\_gold) + 0.05, "greedy should have higher w\_gold than honorable in RICH")
```


---


## 4) Petite note sur le trait “greed”


Si tu n’as pas (encore) un trait `greed`, tu peux :


* soit l’ajouter à tes templates de personnalité (recommandé, super utile pour economy),
* soit le mapper à `opportunism` (et laisser `greed` à 0.5 par défaut, comme dans le code).


---


Si tu veux la brique suivante : brancher `w_gold_dw` (le delta personnalité) dans ton **ArcNotebook** pour debug (“cette faction paye en or parce que greedy”), et faire un test statistique RICH greedy vs RICH honorable qui vérifie la proportion gold/non-gold.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 16](#toc-detail-ch16)
<a id="moi-110"></a>
**Moi 110:**
Ok

brique suivante : brancher w\_gold\_dw (le delta personnalité) dans ton
<a id="cite-arcnotebook-b751fa-11"></a>ArcNotebook pour debug (“cette faction paye en or parce que greedy”), et faire un test statistique RICH greedy vs RICH honorable qui vérifie la proportion gold/non-gold.


**ChatGPT:**
OK — on fait 2 choses :


1) **Brancher** `w_gold_dw` (et idéalement `w_gold_base`/`w_gold`) dans `ArcNotebook` au moment du spawn d’offre (debug/metrics).

2) Un **test statistique** déterministe : **RICH greedy** produit significativement plus de **gold offers** que **RICH honorable**.


---


## 1) Patch : logguer `w_gold_dw` dans ArcNotebook


### A) Dans ton `OfferFactory.spawn_offer_for_pair()` (ou l’endroit où tu construis `reward_bundle`)


Après `compute_reward_style(...)` / `build_reward_bundle(...)`, tu ajoutes les champs debug dans le `context` **et** tu enregistres un event.


```
# OfferFactory / ArcOfferFactory (extrait)

var style := RewardEconomyUtil.compute\_reward\_style(econ, tier, giver\_profile)
var reward := RewardEconomyUtil.build\_reward\_bundle(econ, tier, action\_type, rng, giver\_profile)

context["reward\_bundle"] = reward
context["reward\_style"] = {
 "w\_gold": float(style.w\_gold),
 "w\_gold\_base": float(style.w\_gold\_base),
 "w\_gold\_dw": float(style.w\_gold\_dw),
 "opportunism\_heat": float(style.opportunism\_heat)
}

# debug ArcNotebook (si dispo)

var arc\_notebook = \_get\_arc\_notebook()
if arc\_notebook != null and arc\_notebook.has\_method("record\_pair\_event"):
 arc\_notebook.record\_pair\_event(
 int(context.get("day", 0)),
 StringName(context.get("giver\_faction\_id", &"")),
 StringName(context.get("antagonist\_faction\_id", &"")),
 &"offer.reward\_style",
 &"NEUTRAL",
 {
 "w\_gold": float(style.w\_gold),
 "w\_gold\_base": float(style.w\_gold\_base),
 "w\_gold\_dw": float(style.w\_gold\_dw),
 "wealth\_level": StringName(econ.get("wealth\_level", &"")),
 "tier": tier
 }
 )
```


>
> Avantage : tu peux, en debug, afficher “**gold bias**” par faction, et expliquer au joueur/au log *pourquoi* une faction paye cash ou en faveurs.
>
>
>


### B) (Optionnel) Ajout d’une méthode dédiée `record_reward_style(...)`


Plus propre que détourner `record_pair_event`, mais pas obligatoire.


---


## 2) Test statistique : RICH greedy vs RICH honorable (gold proportion)


Ce test ne dépend pas de QuestPool/OfferFactory : il teste directement la logique reward (plus stable, rapide).

Il vérifie que sur 200 tirages :


* greedy => proportion gold **nettement** plus élevée
* honorable => plus de non-gold (mais RICH reste majoritairement gold)
* et que `w_gold_dw` a bien le signe attendu (greedy positif, honorable négatif)

### `tests/RichGreedyVsHonorableGoldProportionTest.gd`


```
extends Node
class\_name RichGreedyVsHonorableGoldProportionTest

func \_ready() -> void:
 \_test\_rich\_greedy\_has\_higher\_gold\_proportion\_than\_honorable()
 print("\n✅ RichGreedyVsHonorableGoldProportionTest: OK\n")
 get\_tree().quit()

func \_test\_rich\_greedy\_has\_higher\_gold\_proportion\_than\_honorable() -> void:
 \_assert(ClassDB.class\_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

 var econ\_rich := {"wealth\_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}
 var tier := 3
 var action := &"arc.truce\_talks"
 var n := 200

 var prof\_greedy := {"personality": {&"greed": 0.95, &"opportunism": 0.85, &"discipline": 0.30, &"honor": 0.25}}
 var prof\_honorable := {"personality": {&"greed": 0.10, &"opportunism": 0.20, &"discipline": 0.85, &"honor": 0.90}}

 # sanity: dw signs
 var s\_g := RewardEconomyUtil.compute\_reward\_style(econ\_rich, tier, prof\_greedy)
 var s\_h := RewardEconomyUtil.compute\_reward\_style(econ\_rich, tier, prof\_honorable)
 \_assert(float(s\_g.w\_gold\_dw) > 0.03, "expected greedy w\_gold\_dw positive (got %.3f)" % float(s\_g.w\_gold\_dw))
 \_assert(float(s\_h.w\_gold\_dw) < -0.03, "expected honorable w\_gold\_dw negative (got %.3f)" % float(s\_h.w\_gold\_dw))

 var rng := RandomNumberGenerator.new()
 rng.seed = 90901

 var greedy\_gold := 0
 var greedy\_non := 0

 for i in range(n):
 var b := RewardEconomyUtil.build\_reward\_bundle(econ\_rich, tier, action, rng, prof\_greedy)
 if int(b.get("gold", 0)) > 0:
 greedy\_gold += 1
 else:
 greedy\_non += 1

 # reset rng for fair comparison (same sequence shape)
 rng.seed = 90901

 var hon\_gold := 0
 var hon\_non := 0

 for i in range(n):
 var b := RewardEconomyUtil.build\_reward\_bundle(econ\_rich, tier, action, rng, prof\_honorable)
 if int(b.get("gold", 0)) > 0:
 hon\_gold += 1
 else:
 hon\_non += 1

 var p\_g := float(greedy\_gold) / float(n)
 var p\_h := float(hon\_gold) / float(n)

# RICH must stay mostly gold for both (guard rail)

 \_assert(p\_g >= 0.60, "RICH greedy should still be mostly gold (p=%.2f)" % p\_g)
 \_assert(p\_h >= 0.60, "RICH honorable should still be mostly gold (p=%.2f)" % p\_h)

# greedy significantly higher than honorable

 \_assert(p\_g >= p\_h + 0.08, "expected greedy gold proportion higher (greedy=%.2f honorable=%.2f)" % [p\_g, p\_h])

# optional: print-ish debug in log

 print("RICH gold proportions: greedy=%.2f honorable=%.2f (n=%d)" % [p\_g, p\_h, n])

func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


### Remarque importante


Le test est “robuste” parce que :


* delta `w_gold_dw` est clampé ±0.12
* RICH clamp min 0.60
* donc le résultat doit rester stable même si tu ajustes un peu les poids


---


Si tu veux la suite logique : faire un mini test d’intégration “OfferFactory + ArcNotebook” (vraie méthode spawn) qui assert que l’event `offer.reward_style` est bien écrit avec `w_gold_dw` pour une faction greedy.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 16](#toc-detail-ch16)
<a id="moi-111"></a>
**Moi 111:**
Ok

faire un mini test d’intégration “
<a id="cite-offerfactory-ecafbb-2"></a>OfferFactory +
<a id="cite-arcnotebook-b751fa-12"></a>ArcNotebook” (vraie méthode spawn) qui assert que l’event offer.reward\_style est bien écrit avec w\_gold\_dw pour une faction greedy


**ChatGPT:**
Voici un **mini test d’intégration “OfferFactory + ArcNotebook”** qui appelle **ta vraie méthode de spawn**, et vérifie que l’event **`offer.reward_style`** est bien écrit avec un `w_gold_dw` **positif** pour un profil **greedy**.


>
> Comme on ne connaît pas (encore) le nom exact de ton autoload factory, le test **le cherche dynamiquement** dans `/root` en trouvant un node qui expose une méthode `spawn_offer_for_pair` (ou `spawn_offer_for_pair_from_params`).
>
>  Idem, il patch temporairement `ArcManagerRunner.arc_notebook` avec un stub qui capture les events.
>
>
>


---


## `tests/Integration_OfferFactory_RewardStyleNotebook_Test.gd`


```
extends Node
class\_name Integration\_OfferFactory\_RewardStyleNotebook\_Test

class StubArcNotebook:
 extends RefCounted
 var pair\_events: Array = []

 func record\_pair\_event(day: int, a: StringName, b: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
 pair\_events.append({
 "day": day, "a": a, "b": b,
 "action": action, "choice": choice,
 "meta": meta
 })

func \_ready() -> void:
 \_test\_spawn\_logs\_reward\_style\_with\_w\_gold\_dw()
 print("\n✅ Integration\_OfferFactory\_RewardStyleNotebook\_Test: OK\n")
 get\_tree().quit()

func \_test\_spawn\_logs\_reward\_style\_with\_w\_gold\_dw() -> void:
 \_assert(ClassDB.class\_exists("RewardEconomyUtil"), "RewardEconomyUtil must exist")

 var arc\_mgr := get\_node\_or\_null("/root/ArcManagerRunner")
 \_assert(arc\_mgr != null, "Missing /root/ArcManagerRunner")
 \_assert(\_has\_prop(arc\_mgr, "arc\_notebook"), "ArcManagerRunner must have var arc\_notebook")

# Patch notebook

 var prev\_notebook = arc\_mgr.get("arc\_notebook")
 var notebook := StubArcNotebook.new()
 arc\_mgr.set("arc\_notebook", notebook)

# Find a factory that can spawn offers

 var factory := \_find\_root\_node\_with\_method(["spawn\_offer\_for\_pair", "spawn\_offer\_for\_pair\_from\_params"])
 \_assert(factory != null, "No OfferFactory found in /root with spawn\_offer\_for\_pair* method")

# Prepare deterministic inputs

 var rng := RandomNumberGenerator.new()
 rng.seed = 424242

 var giver := &"RICH\_GREEDY"
 var antagonist := &"TARGET"
 var day := 12
 var tier := 3
 var action\_type := &"arc.truce\_talks"

 var econ\_rich := {"wealth\_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}
 var prof\_greedy := {"personality": {&"greed": 0.95, &"opportunism": 0.85, &"discipline": 0.30, &"honor": 0.25}}

 # Spawn (vraie méthode)
 var spawned = null

 # Option A (recommandé): méthode “test-friendly”
 if factory.has\_method("spawn\_offer\_for\_pair\_from\_params"):
 spawned = factory.call("spawn\_offer\_for\_pair\_from\_params", {
 "giver\_faction\_id": giver,
 "antagonist\_faction\_id": antagonist,
 "arc\_action\_type": action\_type,
 "tier": tier,
 "day": day,
 "econ\_override": econ\_rich,
 "profile\_override": prof\_greedy,
 "rng": rng
 })
 else:
 # Option B: spawn\_offer\_for\_pair(...) – on passe les args “classiques”
 # 👉 Si ta signature diffère, adapte les paramètres ici une fois (le test reste utile).
 spawned = factory.call("spawn\_offer\_for\_pair",
 giver, antagonist, action\_type, tier, day,
 econ\_rich, prof\_greedy, rng
 )

# On ne force pas l’assert sur spawned si ta factory push direct dans QuestPool,

 # mais ça aide si tu retournes l’instance.
 # \_assert(spawned != null, "spawn\_offer\_for\_pair should return a QuestInstance (or at least not null)")

# Assert: ArcNotebook event exists with w\_gold\_dw > 0

 var found := false
 for e in notebook.pair\_events:
 if StringName(e.get("action", &"")) == &"offer.reward\_style":
 var meta: Dictionary = e.get("meta", {})
 \_assert(meta.has("w\_gold\_dw"), "offer.reward\_style must include meta.w\_gold\_dw")
 \_assert(meta.has("w\_gold"), "offer.reward\_style must include meta.w\_gold")
 \_assert(meta.has("w\_gold\_base"), "offer.reward\_style must include meta.w\_gold\_base")

 var dw := float(meta.get("w\_gold\_dw", 0.0))
 \_assert(dw > 0.0, "expected w\_gold\_dw > 0 for greedy profile (got %.4f)" % dw)

# Bonus: verify it matches RewardEconomyUtil.compute\_reward\_style(...)

 var style := RewardEconomyUtil.compute\_reward\_style(econ\_rich, tier, prof\_greedy)
 \_assert(abs(float(style.w\_gold\_dw) - dw) < 0.0001, "w\_gold\_dw mismatch vs compute\_reward\_style")
 found = true
 break

 \_assert(found, "expected ArcNotebook record\_pair\_event with action=offer.reward\_style")

# Restore notebook

 arc\_mgr.set("arc\_notebook", prev\_notebook)

# ---------------- helpers ----------------

func \_find\_root\_node\_with\_method(methods: Array) -> Node:
 var root := get\_tree().root
 for child in root.get\_children():
 for m in methods:
 if child != null and child.has\_method(m):
 return child
 return null

func \_has\_prop(obj: Object, prop: String) -> bool:
 for p in obj.get\_property\_list():
 if p.name == prop:
 return true
 return false

func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


## Petit micro-patch “facultatif mais conseillé” dans ta Factory (pour rendre le test plug-and-play)


Si tu n’as pas déjà une entrée stable, ajoute **sans changer le comportement prod** :


```
# ArcOfferFactory.gd (ou OfferFactory.gd)

func spawn\_offer\_for\_pair\_from\_params(p: Dictionary):
 # econ/profile overrides restent optionnels
 return spawn\_offer\_for\_pair(
 StringName(p.get("giver\_faction\_id", &"")),
 StringName(p.get("antagonist\_faction\_id", &"")),
 StringName(p.get("arc\_action\_type", &"arc.raid")),
 int(p.get("tier", 1)),
 int(p.get("day", 0)),
 p.get("econ\_override", null),
 p.get("profile\_override", null),
 p.get("rng", null)
 )
```


Ça te donne une signature **stable pour les tests**, et en prod tu continues à appeler `spawn_offer_for_pair(...)` comme avant.


---


Si tu me confirmes le **nom exact** de ton autoload factory (ex: `ArcOfferFactory` ou `QuestOfferSimRunner`), je te fais une version du test qui l’adresse directement (sans recherche dynamique).


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 16](#toc-detail-ch16)
<a id="moi-112"></a>
**Moi 112:**
<a id="cite-questoffersimrunner-664bb4-2"></a>QuestOfferSimRunner


**ChatGPT:**
Parfait — du coup on cible **directement** l’autoload **`/root/QuestOfferSimRunner`**.


Ci-dessous :


1) un **test d’intégration** qui appelle **QuestOfferSimRunner** (vraie chaîne spawn → log ArcNotebook)

2) un **micro-patch minimal** à ajouter dans `QuestOfferSimRunner.gd` si tu n’as pas encore une entrée “params dict” stable (ça ne change rien en prod : ça ne fait que forward).


---


## 1) Test d’intégration : `tests/Integration_QuestOfferSimRunner_RewardStyleNotebook_Test.gd`


```
extends Node
class\_name Integration\_QuestOfferSimRunner\_RewardStyleNotebook\_Test

class StubArcNotebook:
 extends RefCounted
 var pair\_events: Array = []

 func record\_pair\_event(day: int, a: StringName, b: StringName, action: StringName, choice: StringName, meta: Dictionary) -> void:
 pair\_events.append({"day": day, "a": a, "b": b, "action": action, "choice": choice, "meta": meta})

func \_ready() -> void:
 \_test\_spawn\_logs\_reward\_style\_w\_gold\_dw\_for\_greedy()
 print("\n✅ Integration\_QuestOfferSimRunner\_RewardStyleNotebook\_Test: OK\n")
 get\_tree().quit()

func \_test\_spawn\_logs\_reward\_style\_w\_gold\_dw\_for\_greedy() -> void:
 var sim := get\_node\_or\_null("/root/QuestOfferSimRunner")
 \_assert(sim != null, "Missing /root/QuestOfferSimRunner autoload")

 var arc\_mgr := get\_node\_or\_null("/root/ArcManagerRunner")
 \_assert(arc\_mgr != null, "Missing /root/ArcManagerRunner autoload")
 \_assert(\_has\_prop(arc\_mgr, "arc\_notebook"), "ArcManagerRunner must expose var arc\_notebook")

# Patch notebook (capture logs)

 var prev\_notebook = arc\_mgr.get("arc\_notebook")
 var notebook := StubArcNotebook.new()
 arc\_mgr.set("arc\_notebook", notebook)

 var rng := RandomNumberGenerator.new()
 rng.seed = 424242

 var giver := &"RICH\_GREEDY"
 var target := &"TARGET"
 var day := 12
 var tier := 3
 var arc\_action\_type := &"arc.ultimatum"

 # Overrides injectés uniquement pour le test (évite de dépendre de ton FactionManager)
 var econ\_override := {"wealth\_level": &"RICH", "liquidity": 0.90, "prestige": 0.80}
 var profile\_override := {"personality": {&"greed": 0.95, &"opportunism": 0.85, &"honor": 0.20, &"discipline": 0.30}}

 # Appel "vraie méthode spawn" via une entrée stable.
 \_assert(sim.has\_method("spawn\_offer\_for\_pair\_from\_params"),
 "QuestOfferSimRunner must expose spawn\_offer\_for\_pair\_from\_params(p: Dictionary). See micro-patch below.")
 var offer = sim.call("spawn\_offer\_for\_pair\_from\_params", {
 "giver\_faction\_id": giver,
 "antagonist\_faction\_id": target,
 "arc\_action\_type": arc\_action\_type,
 "tier": tier,
 "day": day,
 "rng": rng,
 "econ\_override": econ\_override,
 "profile\_override": profile\_override
 })

# (Optionnel) si tu retournes la QuestInstance

 # \_assert(offer != null, "spawn\_offer\_for\_pair\_from\_params should return the spawned QuestInstance")

# Assert: ArcNotebook a bien reçu l’event offer.reward\_style avec w\_gold\_dw > 0

 var found := false
 for e in notebook.pair\_events:
 if StringName(e.get("action", &"")) == &"offer.reward\_style":
 var meta: Dictionary = e.get("meta", {})
 \_assert(meta.has("w\_gold\_dw"), "offer.reward\_style meta must include w\_gold\_dw")
 \_assert(meta.has("w\_gold"), "offer.reward\_style meta must include w\_gold")
 \_assert(meta.has("tier"), "offer.reward\_style meta must include tier")

 var dw := float(meta.get("w\_gold\_dw", 0.0))
 \_assert(dw > 0.0, "Expected w\_gold\_dw > 0 for greedy profile (got %.4f)" % dw)
 found = true
 break

 \_assert(found, "Expected ArcNotebook record\_pair\_event(action=offer.reward\_style)")

# Restore

 arc\_mgr.set("arc\_notebook", prev\_notebook)

func \_has\_prop(obj: Object, prop: String) -> bool:
 for p in obj.get\_property\_list():
 if p.name == prop:
 return true
 return false

func \_assert(cond: bool, msg: String) -> void:
 if not cond:
 push\_error("TEST FAIL: " + msg)
 assert(false)
```


---


## 2) Micro-patch dans `QuestOfferSimRunner.gd` (entrée stable pour tests + prod inchangé)


Ajoute juste cette fonction (elle **forward** vers ta logique réelle de spawn ; adapte la ligne “CALL REAL” si besoin).


```
# QuestOfferSimRunner.gd

func spawn\_offer\_for\_pair\_from\_params(p: Dictionary):
 # Paramètres standardisés
 var giver: StringName = p.get("giver\_faction\_id", &"")
 var ant: StringName = p.get("antagonist\_faction\_id", &"")
 var action: StringName = p.get("arc\_action\_type", &"arc.raid")
 var tier: int = int(p.get("tier", 1))
 var day: int = int(p.get("day", 0))
 var rng: RandomNumberGenerator = p.get("rng", null)

 var econ\_override = p.get("econ\_override", null)
 var profile\_override = p.get("profile\_override", null)

# --- CALL REAL ---

 # 1) Si tu as déjà une méthode “réelle” style ArcOfferFactory.spawn\_offer\_for\_pair(...)

# var inst = ArcOfferFactory.spawn\_offer\_for\_pair(giver, ant, action, tier, day, econ\_override, profile\_override, rng)

# 2) Ou si ta “vraie” méthode est déjà dans QuestOfferSimRunner :

 # var inst = spawn\_offer\_for\_pair(giver, ant, action, tier, day, econ\_override, profile\_override, rng)

# 3) Sinon, appelle ton pipeline interne actuel (celle que ton ArcManager utilise déjà).

 var inst = \_spawn\_arc\_offer\_internal(giver, ant, action, tier, day, econ\_override, profile\_override, rng)

 return inst
```


### Si ton log “reward\_style” n’est pas encore écrit


Dans **la fonction réelle** (celle qui calcule `w_gold` / `w_gold_dw`), ajoute ce log (ou son équivalent) :


```
if ArcManagerRunner and ArcManagerRunner.arc\_notebook:
 ArcManagerRunner.arc\_notebook.record\_pair\_event(
 day, giver, ant,
 &"offer.reward\_style", &"NA",
 {
 "tier": tier,
 "w\_gold": w\_gold,
 "w\_gold\_dw": w\_gold\_dw
 }
 )
```


---


Si tu me colles la signature de ta méthode “réelle” (celle que ton ArcManager appelle déjà pour spawner les offers), je te remplace `_spawn_arc_offer_internal(...)` par **l’appel exact**, sans placeholders.


[↑ Sommaire général](#sommaire-general)•[↩ Sommaire détaillé — Chapitre 16](#toc-detail-ch16)
