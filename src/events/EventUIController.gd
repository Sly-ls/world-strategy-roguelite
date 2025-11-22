extends ColorRect

@onready var panel: Panel = $EventPanel
@onready var title_label: Label = $EventPanel/VBoxContainer/TitleLabel
@onready var desc_label: Label = $EventPanel/VBoxContainer/DescriptionLabel
@onready var choice_a_button: Button = $EventPanel/VBoxContainer/HBoxContainer/ChoiceAButton
@onready var choice_b_button: Button = $EventPanel/VBoxContainer/HBoxContainer/ChoiceBButton

var current_event: EventData

func _ready() -> void:
    visible = false
    choice_a_button.pressed.connect(_on_choice_a)
    choice_b_button.pressed.connect(_on_choice_b)


func show_event(event: EventData) -> void:
    current_event = event
    title_label.text = event.title
    desc_label.text = event.description
    choice_a_button.text = event.choice_a_text

    if event.choice_b_text == "":
        choice_b_button.visible = false
    else:
        choice_b_button.visible = true
        choice_b_button.text = event.choice_b_text

    visible = true


func _on_choice_a() -> void:
    # TODO : appliquer les effets de choix A
    visible = false


func _on_choice_b() -> void:
    # TODO : appliquer les effets de choix B
    visible = false
