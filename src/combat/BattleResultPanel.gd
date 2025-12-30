extends Control
class_name BattleResultPanel

signal result_closed

@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var outcome_label: Label = $PanelContainer/VBoxContainer/OutcomeLabel

@onready var player_title_label: Label = $PanelContainer/VBoxContainer/HBoxContainer/PlayerBox/LossLabel
@onready var player_loss: GridContainer = $PanelContainer/VBoxContainer/HBoxContainer/PlayerBox/LossGrid

@onready var enemy_title_label: Label = $PanelContainer/VBoxContainer/HBoxContainer/EnemyBox/LossLabel
@onready var enemy_loss: GridContainer = $PanelContainer/VBoxContainer/HBoxContainer/EnemyBox/LossGrid

@onready var extra_log_label: RichTextLabel = $PanelContainer/VBoxContainer/ExtraLogLabel
@onready var continue_button: Button = $PanelContainer/VBoxContainer/ContinueButton


func _ready() -> void:
    visible = false
    continue_button.pressed.connect(_on_continue_button_pressed)

func show_result(result: String, player_units : Array[UnitData], enemy_units : Array[UnitData], extra_text: String = "") -> void:
    # result : { "victory": bool, "player_losses": int, "enemy_losses": int, ... }

    var victory := result == "victory"

    title_label.text = "Victoire !" if victory else "Défaite..."
    outcome_label.text = "Vous avez remporté la bataille." if victory else "Vos troupes ont été vaincues."

    player_title_label.text = "Vos troupes"
    place_loss(player_loss, player_units)

    enemy_title_label.text = "Ennemis"
    place_loss(enemy_loss, enemy_units)

    extra_log_label.clear()
    if extra_text != "":
        extra_log_label.append_text(extra_text)

    visible = true

func place_loss(gridContainer: GridContainer, loss : Array[UnitData]) -> void:
    var slots = gridContainer.get_children()
    for i in slots.size():
        if i >= loss.size():
            break
        var slot := slots[i] as TextureRect
        slot.mouse_filter = Control.MOUSE_FILTER_IGNORE

        var unit = loss[i]
        if unit == null:
            slot.modulate = Color(0.2, 0.2, 0.2)
            slot.tooltip_text = ""
            slot.texture = null
        else:
            slot.modulate = Color(1.0, 0.6, 0.6)
            slot.texture = unit.icon
            slot.tooltip_text = "%s\nPV: %d / %d" % [unit.name, unit.hp, unit.max_hp]

func _on_continue_button_pressed() -> void:
    get_tree().paused = false
    visible = false
    emit_signal("result_closed")
