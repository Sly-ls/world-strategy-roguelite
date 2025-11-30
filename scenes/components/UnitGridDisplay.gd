extends VBoxContainer
class_name UnitGridDisplay

## Affiche une grille 3×5 d'unités avec une barre de progression en haut
## Les 15 UnitCards sont déjà présentes dans la scène pour un meilleur contrôle visuel

# Références UI
@onready var progress_bar: ProgressBar = $TopContainer/ProgressBar
@onready var progress_label: Label = $TopContainer/ProgressBar/ProgressLabel
@onready var grid_container: GridContainer = $GridContainer

# Références aux cartes d'unités (récupérées depuis la scène)
var unit_cards: Array[UnitCard] = []

# Armée à afficher
var army_data: ArmyData:
    set(value):
        army_data = value
        _refresh_display()


func _ready() -> void:
    # Récupérer les cartes depuis le GridContainer
    _collect_cards()
    
    if army_data != null:
        _refresh_display()


func _collect_cards() -> void:
    """Récupère toutes les UnitCards depuis le GridContainer"""
    unit_cards.clear()
    
    for child in grid_container.get_children():
        if child is UnitCard:
            unit_cards.append(child)
    
    print("✓ %d UnitCards trouvées dans la grille" % unit_cards.size())
    
    # Vérifier qu'on a bien 15 cartes
    if unit_cards.size() != 15:
        push_warning("Attention : %d cartes trouvées au lieu de 15" % unit_cards.size())


func set_army(army: ArmyData) -> void:
    """Définit l'armée à afficher"""
    army_data = army


func _refresh_display() -> void:
    """Met à jour l'affichage de toutes les cartes"""
    if not is_node_ready():
        return
    
    if unit_cards.is_empty():
        push_error("Aucune UnitCard trouvée dans le GridContainer !")
        return
    
    if army_data == null:
        _clear_all_cards()
        _update_progress(0, 15)
        return
    
    # Compter les unités vivantes
    var alive_count = 0
    var total_count = 0
    
    # Afficher chaque unité dans sa carte correspondante
    for i in range(min(unit_cards.size(), army_data.units.size())):
        var unit = army_data.units[i]
        
        if unit != null and unit.hp > 0:
            unit_cards[i].set_unit(unit)
            alive_count += 1
            total_count += 1
        elif unit != null:
            # Unité morte
            unit_cards[i].set_unit(unit)
            total_count += 1
        else:
            # Pas d'unité
            unit_cards[i].set_unit(null)
    
    # Cartes restantes vides si l'armée a moins de cartes
    for i in range(army_data.units.size(), unit_cards.size()):
        unit_cards[i].set_unit(null)
    
    # Mettre à jour la barre de progression
    _update_progress(alive_count, total_count)


func _clear_all_cards() -> void:
    """Efface toutes les cartes"""
    for card in unit_cards:
        card.set_unit(null)


func _update_progress(alive: int, total: int) -> void:
    """Met à jour la barre de progression"""
    if progress_bar:
        progress_bar.max_value = total if total > 0 else 15
        progress_bar.value = alive
        
        # Couleur selon le pourcentage
        var percent = float(alive) / float(total) if total > 0 else 0.0
        if percent > 0.6:
            progress_bar.modulate = Color(0.2, 0.8, 0.2)  # Vert
        elif percent > 0.3:
            progress_bar.modulate = Color(0.9, 0.9, 0.2)  # Jaune
        else:
            progress_bar.modulate = Color(0.9, 0.2, 0.2)  # Rouge
    
    if progress_label:
        progress_label.text = "Unités : %d / %d" % [alive, total]


func update_display() -> void:
    """Méthode publique pour forcer une mise à jour"""
    _refresh_display()


func get_card_at_index(index: int) -> UnitCard:
    """Récupère la carte à l'index donné"""
    if index >= 0 and index < unit_cards.size():
        return unit_cards[index]
    return null


func get_unit_at_index(index: int) -> UnitData:
    """Récupère l'unité à l'index donné"""
    var card = get_card_at_index(index)
    if card:
        return card.unit_data
    return null
