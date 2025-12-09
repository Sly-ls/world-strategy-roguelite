# scripts/tests/test_army_service.gd
extends Node

func _ready():
    test_army_service()

func test_army_service():
    print("\n=== TEST ARMY SERVICE ===")
    
    # 1. Création du service
    var army_service = ArmyService.new()
    print("✓ ArmyService créé")
    
    # 2. Création d'une armée de test
    var test_army = ArmyData.new()
    test_army.faction_id = 0
    test_army.max_units = 15
    test_army.units = []
    
    # Ajoute 3 unités
    for i in range(3):
        var unit = UnitData.new()
        unit.unit_name = "Test Unit %d" % (i + 1)
        unit.unit_type = GameEnums.UnitType.INFANTRY
        unit.max_hp = 100
        unit.current_hp = 100
        unit.attack = 10
        unit.defense = 5
        unit.speed = 5
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
    new_unit.unit_name = "Nouvelle Recrue"
    new_unit.max_hp = 80
    new_unit.current_hp = 80
    new_unit.attack = 8
    
    var added = army_service.add_unit_to_player(new_unit)
    assert(added, "L'ajout devrait réussir")
    print("✓ Unité ajoutée: %s" % new_unit.unit_name)
    
    # 6. Test soins
    test_army.units[0].current_hp = 50  # Blesse une unité
    army_service.heal_player_army(30)
    assert(test_army.units[0].current_hp == 80, "HP devrait être 80")
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
    var signal_received = false
    army_service.army_updated.connect(func(army):
        signal_received = true
        print("  Signal reçu: army_updated")
    )
    
    army_service.heal_player_army(10)
    assert(signal_received, "Signal devrait être émis")
    print("✓ Signaux fonctionnent")
    
    print("=== TEST RÉUSSI ✓ ===\n")
    army_service.free()
