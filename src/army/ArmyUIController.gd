extends VBoxContainer
class_name ArmyUIController

@export var army_data: ArmyData


var slots: Array = [TextureRect]  # contiendra les 20 TextureRect
            
func _ready() -> void:
    # 1) S'il existe déjà une armée globale, on l'utilise
    if WorldState.player_army != null:
        army_data = WorldState.player_army
    else:
        # 2) Sinon, on crée l'armée de départ UNE SEULE FOIS
        if army_data == null:
            print("create player_start_army")
            _create_test_army()
            army_data.describe()
        WorldState.player_army = army_data

    # 3) On initialise l'UI avec l'armée courante
    var grid := $GridContainer as GridContainer
    slots = grid.get_children()
    _refresh_slots()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    _refresh_slots()
    pass

func get_army_data() -> ArmyData:
    return army_data

func _create_test_army() -> void:
    army_data = ArmyFactory.create_army("player_start_army")
    
func _refresh_slots() -> void:
    if army_data == null:
        for slot in slots:
            slot.texture = null
            slot.modulate = Color(1, 1, 1, 0)
            slot.tooltip_text = ""
        return

    var cols_ui := ArmyData.ARMY_ROWS  # 5 colonnes UI
    var rows_ui := ArmyData.ARMY_COLS  # 3 lignes UI

    for i in range(slots.size()):
        var slot :TextureRect = slots[i]

        var ui_row := i / cols_ui    # 0..2
        var ui_col := i % cols_ui    # 0..4

        # Mapping demandé :
        #  - colonne UI = ligne de combat
        #  - ligne UI   = colonne de combat
        var combat_row := ui_col     # 0..4
        var combat_col := ui_row     # 0..2

        var unit :UnitData = army_data.get_unit_at_position(combat_row, combat_col)

        if unit != null and unit.hp > 0:
            if unit.icon != null:
                slot.texture = unit.icon
                slot.modulate = Color(1, 1, 1, 1)
            else:
                slot.texture = null
                slot.modulate = Color(1, 1, 1, 1)

            slot.tooltip_text = "%s\nPV : %d / %d\nMoral : %d / %d" % [
                unit.name,
                unit.hp, unit.max_hp,
                unit.morale, unit.max_morale
            ]
        else:
            slot.texture = null
            slot.modulate = Color(1, 1, 1, 0)  # transparent
            slot.tooltip_text = ""
