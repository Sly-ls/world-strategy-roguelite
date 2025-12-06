# res://src/ui/quests/QuestJournalUI.gd
extends Control

## Interface minimale du journal de quêtes
## Affiche les quêtes actives avec progression

# ========================================
# NODES
# ========================================

@onready var quest_list: VBoxContainer = %QuestList
@onready var no_quests_label: Label = %NoQuestsLabel
@onready var close_button: Button = %CloseButton

func refresh_display() -> void:
    # Vider la liste
    for child in quest_list.get_children():
        child.queue_free()
    
    # Afficher quêtes disponibles
    for quest in QuestPool.get_available_quests():
        var button := Button.new()
        button.text = quest.template.title
        button.pressed.connect(_on_quest_selected.bind(quest))
        quest_list.add_child(button)

func _on_quest_selected(quest: QuestInstance) -> void:
    # Activer la quête
    QuestPool.activate_quest(quest)
    refresh_display()

func _on_pool_refreshed(_quests: Array[QuestInstance]) -> void:
    refresh_display()
# ========================================
# TEMPLATES
# ========================================

const QUEST_ENTRY_SCENE := preload("res://scenes/QuestEntryUI.tscn")

# ========================================
# LIFECYCLE
# ========================================

func _ready() -> void:
    close_button.pressed.connect(_on_close_pressed)
    hide()
    
    QuestPool.pool_refreshed.connect(_on_pool_refreshed)
    refresh_display()
    # Connecter aux signaux du QuestManager
    QuestManager.quest_started.connect(_on_quest_changed)
    QuestManager.quest_completed.connect(_on_quest_changed)
    QuestManager.quest_failed.connect(_on_quest_changed)
    QuestManager.quest_expired.connect(_on_quest_changed)
    QuestManager.quest_progress_updated.connect(_on_progress_updated)

func _input(event: InputEvent) -> void:
    # Ouvrir/fermer avec J
    if event.is_action_pressed("toggle_journal"):  # À définir dans Input Map
        toggle()

# ========================================
# AFFICHAGE
# ========================================

func toggle() -> void:
    """Bascule l'affichage du journal"""
    visible = not visible
    if visible:
        refresh()

func refresh() -> void:
    """Rafraîchit l'affichage de toutes les quêtes"""
    _clear_list()
    
    var active_quests := QuestManager.get_active_quests()
    
    if active_quests.is_empty():
        no_quests_label.show()
        return
    
    no_quests_label.hide()
    
    # Trier par tier
    active_quests.sort_custom(_sort_by_tier)
    
    # Créer les entrées
    for quest in active_quests:
        _create_quest_entry(quest)

func _clear_list() -> void:
    """Vide la liste"""
    for child in quest_list.get_children():
        child.queue_free()

func _create_quest_entry(quest: QuestInstance) -> void:
    """Crée une entrée de quête"""
    var entry := QUEST_ENTRY_SCENE.instantiate()
    quest_list.add_child(entry)
    entry.setup(quest)

func _sort_by_tier(a: QuestInstance, b: QuestInstance) -> bool:
    """Tri par tier décroissant"""
    return a.template.tier > b.template.tier

# ========================================
# CALLBACKS
# ========================================

func _on_quest_changed(_quest: QuestInstance) -> void:
    """Quête ajoutée/supprimée"""
    if visible:
        refresh()

func _on_progress_updated(_quest: QuestInstance, _progress: int, _total: int) -> void:
    """Progression mise à jour"""
    if visible:
        refresh()

func _on_close_pressed() -> void:
    """Bouton fermer"""
    hide()
