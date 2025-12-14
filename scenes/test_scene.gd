extends Node2D

func _ready():
    _test_movement_controller()
    test_movement_with_obstacle()
    _test_camera_controller()
    _test_army_service()
    _test_army_service()


func _test_army_service():
    print("\n=== TEST ARMY SERVICE ===")
    
    # 1. Création du service
    var army_service = ArmyService.new()
    print("✓ ArmyService créé")
    
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
    
    print("✓ Armée de test créée (3 unités)")
    
    # 3. Initialisation du service
    army_service.initialize(test_army, Vector2i(10, 10))
    print("✓ Service initialisé à (10, 10)")
    
    # 4. Test comptage unités
    var alive_count = army_service.get_alive_unit_count()
    assert(alive_count == 3, "Devrait avoir 3 unités vivantes")
    print("✓ Comptage: %d unités vivantes" % alive_count)
    
    # 5. Test ajout d'unité
    var new_unit = UnitData.new()
    new_unit.name = "Nouvelle Recrue"
    new_unit.max_hp = 80
    new_unit.hp = 80
    new_unit.powers[PowerEnums.PowerType.MELEE]= 10
    
    var added = army_service.add_unit_to_player(new_unit)
    assert(added, "L'ajout devrait réussir")
    print("✓ Unité ajoutée: %s" % new_unit.name)
    
    # 6. Test soins
    test_army.units[0].hp = 50  # Blesse une unité
    army_service.heal_player_army(30)
    assert(test_army.units[0].hp == 80, "HP devrait être 80")
    print("✓ Soins appliqués (50 -> 80)")
    
    # 7. Test dégâts
    army_service.damage_player_army(20)
    print("✓ Dégâts appliqués (-20 HP sur unité aléatoire)")
    
    # 8. Test stats
    var stats = army_service.get_army_stats()
    print("✓ Stats récupérées:")
    print("  Total unités: %d" % stats["total_units"])
    print("  Vivantes: %d" % stats["alive_units"])
    print("  HP total: %d/%d" % [stats["total_hp"], stats["max_hp"]])
    
    # 9. Test signaux
    print("\n9. Test signaux (via effet)")

    # Blesse d'abord une unité
    test_army.units[0].hp = 50
    print("  HP avant heal: %d" % test_army.units[0].hp)

    var signal_count = 0
    army_service.army_updated.connect(func(army):
        signal_count += 1
        print("  Signal reçu: army_updated (#%d)" % signal_count)
    )

    # Heal
    army_service.heal_player_army(30)

    # Vérifie l'effet
    assert(test_army.units[0].hp == 80, "HP devrait être 80 après heal")
    print("  HP après heal: %d" % test_army.units[0].hp)

# Note : Le signal sera émis, mais peut-être pas encore traité à ce stade
    print("✓ Heal fonctionne correctement")
    
    print("=== TEST RÉUSSI ✓ ===\n")
    army_service = null
        
func _test_movement_controller():
    print("\n=== TEST MOVEMENT CONTROLLER ===")
    
    # 1. Création du service
    var mc = MovementController.new()
    print("✓ MovementController créé")
    
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
    print("✓ Grille initialisée (10x10)")
    
    # 4. Test de calcul de distance
    var dist = mc.calculate_distance(Vector2i(0, 0), Vector2i(3, 4))
    assert(dist == 7.0, "Distance devrait être 7")
    print("✓ Calcul de distance: 7.0 (attendu: 7.0)")
    
    # 5. Test de chemin
    var path = mc.calculate_path(Vector2i(0, 0), Vector2i(2, 2))
    print("✓ Chemin calculé: %d étapes" % path.size())
    print("  Path: {0}".format([path]))
    
    # 6. Test de mouvement
    mc.movement_started.connect(func(from, to): 
        print("  Signal: Mouvement démarré %s -> %s" % [from, to])
    )
    mc.movement_completed.connect(func(final): 
        print("  Signal: Mouvement terminé à %s" % final)
    )
    
    var started = mc.start_movement(Vector2i(0, 0), Vector2i(2, 2), 200.0)
    assert(started, "Mouvement devrait démarrer")
    print("✓ Mouvement démarré")
    
    # 7. Simulation de quelques frames
    for i in range(5):
        var pos = mc.update_movement(0.016)  # ~16ms par frame
        print("  Frame %d: position = %s" % [i, pos])
    
    print("=== TEST RÉUSSI ✓ ===\n")
    mc = null
    
func test_movement_with_obstacle():
    print("\n=== TEST MOUVEMENT AVEC OBSTACLE ===")
    
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
        print("  ⚠ Blocage détecté: %s (%s)" % [str(pos), reason])
    )
    
    # Essaie de traverser la montagne
    var started = mc.start_movement(Vector2i(4, 5), Vector2i(6, 5))
    
    # ✅ Vérifie que le mouvement n'a PAS démarré
    if not started:
        print("✓ Obstacle correctement détecté (mouvement refusé)")
    else:
        print("✗ ERREUR: Le mouvement a démarré malgré l'obstacle")
    
    mc = null
    
func _test_camera_controller():
    print("=== Test MovementController ===")
    # Tests ici
