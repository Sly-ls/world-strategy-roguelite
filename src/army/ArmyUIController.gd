extends VBoxContainer

@export var army_data: ArmyData

var slots: Array = []  # contiendra les 20 TextureRect

func _ready() -> void:
    # récupérer le GridContainer et ses enfants
    var grid: GridContainer = $GridContainer
    slots = grid.get_children()

    if not army_data:
        _create_test_army()

    _refresh_slots()


func _create_test_army() -> void:
    army_data = ArmyData.new()

    # fabriquer quelques unités de test
    var unit1 := UnitData.new()
    unit1.name = "Chevaliers"
    unit1.max_hp = 600
    unit1.hp = 480
    unit1.max_morale = 100
    unit1.morale = 75
    unit1.count = 6
    # unit1.icon = preload("res://assets/icons/chevaliers.png")  # à mettre quand tu auras une icône

    var unit2 := UnitData.new()
    unit2.name = "Archers"
    unit2.max_hp = 300
    unit2.hp = 280
    unit2.max_morale = 100
    unit2.morale = 85
    unit2.count = 10

    var unit3 := UnitData.new()
    unit3.name = "Mages"
    unit3.max_hp = 200
    unit3.hp = 150
    unit3.max_morale = 120
    unit3.morale = 90
    unit3.count = 4

    # placer ces unités dans les 3 premières cases
    army_data.set_unit_at(0, unit1)
    army_data.set_unit_at(1, unit2)
    army_data.set_unit_at(2, unit3)


func _refresh_slots() -> void:
    if army_data == null:
        return

    var total_slots: int = min(slots.size(), army_data.ARMY_SIZE)

    for i in total_slots:
        var slot := slots[i] as TextureRect
        var unit: UnitData = army_data.get_unit_at(i)

        if unit == null:
            # Case vide : on garde la texture existante (logo Godot),
            # mais on la fonce un peu pour la différencier.
            slot.modulate = Color(0.3, 0.3, 0.3)
            slot.tooltip_text = "Vide"
        else:
            # Case occupée : on remet la couleur normale.
            slot.modulate = Color(1, 1, 1)

            # Tooltip avec les infos de l'unité
            slot.tooltip_text = "%s\nPV: %d / %d\nMoral: %d / %d\nEffectifs: %d" % [
                unit.name,
                unit.hp, unit.max_hp,
                unit.morale, unit.max_morale,
                unit.count
            ]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
