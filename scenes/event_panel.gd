extends Control
class_name EventPanel

signal choice_made(choice_id: String)

@onready var title_label: Label = $ColorRect/Panel/VBoxContainer/TitleLabel
@onready var body_label: RichTextLabel = $ColorRect/Panel/VBoxContainer/BodyLabel
@onready var primary_button: Button = $ColorRect/Panel/VBoxContainer/HBoxContainer/PrimaryButton
@onready var secondary_button: Button = $ColorRect/Panel/VBoxContainer/HBoxContainer/SecondaryButton

var current_choice_primary: String = ""
var current_choice_secondary: String = ""


func _ready() -> void:
    visible = false
    primary_button.pressed.connect(_on_primary_pressed)
    secondary_button.pressed.connect(_on_secondary_pressed)


func show_event(
    title: String,
    body: String,
    primary_text: String,
    primary_choice_id: String,
    secondary_text: String,
    secondary_choice_id: String
) -> void:
    title_label.text = title
    body_label.text = body

    primary_button.text = primary_text
    current_choice_primary = primary_choice_id

    secondary_button.text = secondary_text
    current_choice_secondary = secondary_choice_id

    visible = true


func hide_event() -> void:
    visible = false


func _on_primary_pressed() -> void:
    if current_choice_primary != "":
        choice_made.emit(current_choice_primary)
    hide_event()


func _on_secondary_pressed() -> void:
    if current_choice_secondary != "":
        choice_made.emit(current_choice_secondary)
    hide_event()
