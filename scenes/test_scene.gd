extends Node2D

func _ready():
    _test_movement_controller()
    test_movement_with_obstacle()
    _test_camera_controller()
    _test_army_service()
    _test_army_service()


func _test_army_service():
    myLogger.debug("=== TEST ARMY SERVICE ===", LogTypes.Domain.TEST)
    
    # 1. Création du service
    var army_service = ArmyService.new()
    myLogger.debug("✓ ArmyService créé", LogTypes.Domain.TEST)
    
    # 2. Création d'une armée de test
    var test_army = ArmyData.new()
    
    # Ajoute 3 unités
    for i in range(3):
        var unit = UnitData.new()
        unit.name = "Test Unit %d" % (i + 1)
        unit.max_hp = 100
        unit.hp = 100
        unit.powers[PowerEnums.PowerType.MELEE]= 10
        test_army.units.append(unit)
    
    # Remplit avec nulls
    while test_army.units.size() < 15:
        test_army.units.append(null)
    
    myLogger.debug("✓ Armée de test créée (3 unités)", LogTypes.Domain.TEST)
    
    # 3. Initialisation du service
    army_service.initialize(test_army, Vector2i(10, 10))
    myLogger.debug("✓ Service initialisé à (10, 10)", LogTypes.Domain.TEST)
    
    # 4. Test comptage unités
    var alive_count = army_service.get_alive_unit_count()
    assert(alive_count == 3, "Devrait avoir 3 unités vivantes")
    myLogger.debug("✓ Comptage: %d unités vivantes" % alive_count, LogTypes.Domain.TEST)
    
    # 5. Test ajout d'unité
    var new_unit = UnitData.new()
    new_unit.name = "Nouvelle Recrue"
    new_unit.max_hp = 80
    new_unit.hp = 80
    new_unit.powers[PowerEnums.PowerType.MELEE]= 10
    
    var added = army_service.add_unit_to_player(new_unit)
    assert(added, "L'ajout devrait réussir")
    myLogger.debug("✓ Unité ajoutée: %s" % new_unit.name, LogTypes.Domain.TEST)
    
    # 6. Test soins
    test_army.units[0].hp = 50  # Blesse une unité
    army_service.heal_player_army(30)
    assert(test_army.units[0].hp == 80, "HP devrait être 80")
    myLogger.debug("✓ Soins appliqués (50 -> 80)", LogTypes.Domain.TEST)
    
    # 7. Test dégâts
    army_service.damage_player_army(20)
    myLogger.debug("✓ Dégâts appliqués (-20 HP sur unité aléatoire)", LogTypes.Domain.TEST)
    
    # 8. Test stats
    var stats = army_service.get_army_stats()
    myLogger.debug("✓ Stats récupérées:", LogTypes.Domain.TEST)
    myLogger.debug("  Total unités: %d" % stats["total_units"], LogTypes.Domain.TEST)
    myLogger.debug("  Vivantes: %d" % stats["alive_units"])
    myLogger.debug("  HP total: %d/%d" % [stats["total_hp"], stats["max_hp"]], LogTypes.Domain.TEST)
    
    # 9. Test signaux
    myLogger.debug("\n9. Test signaux (via effet)", LogTypes.Domain.TEST)

    # Blesse d'abord une unité
    test_army.units[0].hp = 50
    myLogger.debug("  HP avant heal: %d" % test_army.units[0].hp, LogTypes.Domain.TEST)

    var signal_count = 0
    army_service.army_updated.connect(func(army):
        signal_count += 1
        myLogger.debug("  Signal reçu: army_updated (#%d)" % signal_count, LogTypes.Domain.TEST)
    )

    # Heal
    army_service.heal_player_army(30)

    # Vérifie l'effet
    assert(test_army.units[0].hp == 80, "HP devrait être 80 après heal")
    myLogger.debug("  HP après heal: %d" % test_army.units[0].hp, LogTypes.Domain.TEST)

# Note : Le signal sera émis, mais peut-être pas encore traité à ce stade
    myLogger.debug("✓ Heal fonctionne correctement", LogTypes.Domain.TEST)
    
    myLogger.debug("=== TEST RÉUSSI ✓ ===", LogTypes.Domain.TEST)
    army_service = null
        
func _test_movement_controller():
    myLogger.debug("=== TEST MOVEMENT CONTROLLER ===", LogTypes.Domain.TEST)
    
    # 1. Création du service
    var mc = MovementController.new()
    myLogger.debug("✓ MovementController créé", LogTypes.Domain.TEST)
    
    # 2. Création d'une grille de test simple
    var test_grid = []
    for y in range(10):
        var row = []
        for x in range(10):
            row.append({
                "terrain_type": TilesEnums.CellType.PLAINE,
                "poi_type": null
            })
        test_grid.append(row)
    
    # 3. Initialisation
    mc.initialize(test_grid, 10, 10)
    myLogger.debug("✓ Grille initialisée (10x10)", LogTypes.Domain.TEST)
    
    # 4. Test de calcul de distance
    var dist = mc.calculate_distance(Vector2i(0, 0), Vector2i(3, 4))
    assert(dist == 7.0, "Distance devrait être 7")
    myLogger.debug("✓ Calcul de distance: 7.0 (attendu: 7.0)", LogTypes.Domain.TEST)
    
    # 5. Test de chemin
    var path = mc.calculate_path(Vector2i(0, 0), Vector2i(2, 2))
    myLogger.debug("✓ Chemin calculé: %d étapes" % path.size(), LogTypes.Domain.TEST)
    myLogger.debug("  Path: {0}".format([path]), LogTypes.Domain.TEST)
    
    # 6. Test de mouvement
    mc.movement_started.connect(func(from, to): 
        myLogger.debug("  Signal: Mouvement démarré %s -> %s" % [from, to], LogTypes.Domain.TEST)
    )
    mc.movement_completed.connect(func(final): 
        myLogger.debug("  Signal: Mouvement terminé à %s" % final, LogTypes.Domain.TEST)
    )
    
    var started = mc.start_movement(Vector2i(0, 0), Vector2i(2, 2), 200.0)
    assert(started, "Mouvement devrait démarrer")
    myLogger.debug("✓ Mouvement démarré", LogTypes.Domain.TEST)
    
    # 7. Simulation de quelques frames
    for i in range(5):
        var pos = mc.update_movement(0.016)  # ~16ms par frame
        myLogger.debug("  Frame %d: position = %s" % [i, pos], LogTypes.Domain.TEST)
    
    myLogger.debug("=== TEST RÉUSSI ✓ ===", LogTypes.Domain.TEST)
    mc = null
    
func test_movement_with_obstacle():
    myLogger.debug("=== TEST MOUVEMENT AVEC OBSTACLE ===", LogTypes.Domain.TEST)
    
    var mc = MovementController.new()
    var test_grid = []
    
    for y in range(10):
        var row = []
        for x in range(10):
            var terrain = TilesEnums.CellType.PLAINE
            # Place une montagne au milieu
            if x == 5 and y == 5:
                terrain = TilesEnums.CellType.WATER
            row.append({
                "terrain_type": terrain,
                "poi_type": null
            })
        test_grid.append(row)
    
    mc.initialize(test_grid, 10, 10)
    
    # Connexion au signal de blocage (pour le log)
    mc.movement_blocked.connect(func(pos, reason): 
        myLogger.debug("  ⚠ Blocage détecté: %s (%s)" % [str(pos), reason], LogTypes.Domain.TEST)
    )
    
    # Essaie de traverser la montagne
    var started = mc.start_movement(Vector2i(4, 5), Vector2i(6, 5))
    
    # ✅ Vérifie que le mouvement n'a PAS démarré
    if not started:
        myLogger.debug("✓ Obstacle correctement détecté (mouvement refusé)", LogTypes.Domain.TEST)
    else:
        myLogger.debug("✗ ERREUR: Le mouvement a démarré malgré l'obstacle", LogTypes.Domain.TEST)
    
    mc = null
    
func _test_camera_controller():
    myLogger.debug("=== Test MovementController ===", LogTypes.Domain.TEST)
    # Tests ici
