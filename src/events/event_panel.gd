extends Control
class_name EventPanel

signal choice_made(choice_id: String)

@onready var title_label: Label = $ColorRect/Panel/VBoxContainer/TitleLabel
@onready var body_label: RichTextLabel = $ColorRect/Panel/VBoxContainer/BodyLabel
@onready var buttons_container: VBoxContainer = $ColorRect/Panel/VBoxContainer/ButtonsContainer

# Structure interne : chaque bouton garde un choice_id associé
const MAX_CHOICES := 10


func _ready() -> void:
    visible = false
    _clear_buttons()


func _clear_buttons() -> void:
    for child in buttons_container.get_children():
        child.queue_free()


func show_event(
    title: String,
    body: String,
    choices: Array[Dictionary]
) -> void:
    # choices = [ { "text": "Se reposer", "choice_id": "town_rest" }, ... ]

    _clear_buttons()

    title_label.text = title
    body_label.text = body

    # Sécurité : on limite à MAX_CHOICES
    var count :int = min(choices.size(), MAX_CHOICES)

    for i in count:
        var choice: Dictionary = choices[i]
        if not choice.has("text") or not choice.has("choice_id"):
            push_warning("EventPanel: choix invalide à l'index %d" % i)
            continue

        var btn := Button.new()
        btn.text = String(choice["text"])
        # On stocke le choice_id dans metadata pour le récupérer dans le callback
        btn.set_meta("choice_id", String(choice["choice_id"]))

        btn.pressed.connect(_on_choice_button_pressed.bind(btn))
        buttons_container.add_child(btn)

    visible = true
    mouse_filter = Control.MOUSE_FILTER_STOP  # bloque les clics derrière


func hide_event() -> void:
    visible = false
    mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_choice_button_pressed(button: Button) -> void:
    var choice_id := button.get_meta("choice_id") as String
    if choice_id == "":
        push_warning("EventPanel: bouton sans choice_id")
    else:
        choice_made.emit(choice_id)
    hide_event()
