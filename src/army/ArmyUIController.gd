extends VBoxContainer
class_name ArmyUIController

@export var army_data: ArmyData


var slots: Array = []  # contiendra les 20 TextureRect

func _ready() -> void:
    # 1) S'il existe déjà une armée globale, on l'utilise
    if WorldState.player_army != null:
        army_data = WorldState.player_army
    else:
        # 2) Sinon, on crée l'armée de départ UNE SEULE FOIS
        if army_data == null:
            _create_test_army()
        WorldState.player_army = army_data

    # 3) On initialise l'UI avec l'armée courante
    var grid := $GridContainer as GridContainer
    slots = grid.get_children()
    _refresh_slots()


func get_army_data() -> ArmyData:
    return army_data

func _create_test_army() -> void:
    army_data = ArmyFactory.create_army("player_start")
    
func _refresh_slots() -> void:
    if army_data == null:
        return

    var total_slots: int = min(slots.size(), army_data.ARMY_SIZE)

    for i in slots.size():
        var slot := slots[i] as TextureRect
        var unit: UnitData = army_data.get_unit_at(i)

        if unit == null or unit.hp <= 0:
            # Case vide (ou unité morte) → on affiche un slot “empty”
            slot.modulate = Color(0.3, 0.3, 0.3)
            slot.tooltip_text = "Vide"
            continue

        # Case occupée par une unité vivante
        slot.modulate = Color(1, 1, 1)
        slot.tooltip_text = "%s\nPV: %d / %d\nMoral: %d / %d\nEffectifs: %d" % [
            unit.name,
            unit.hp, unit.max_hp,
            unit.morale, unit.max_morale,
            unit.count
        ]



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
