extends PanelContainer
class_name UnitCard

## Composant réutilisable pour afficher les informations d'une unité

# Référence à l'unité
var unit_data: UnitData:
    set(value):
        unit_data = value
        _refresh_display()

# Références aux nodes UI
@onready var unit_icon: TextureRect = $MarginContainer/IconContainer/UnitIcon
@onready var unit_name_label: Label = $MarginContainer/UnitName
@onready var hp_bar: ProgressBar = $MarginContainer/StatsContainer/HPBar
@onready var hp_label: Label = $MarginContainer/StatsContainer/HPBar/HPLabel
@onready var morale_label: Label = $MarginContainer/StatsContainer/HBoxContainer/MoraleContainer/MoraleValue
@onready var attack_label: Label = $MarginContainer/StatsContainer/HBoxContainer/AttackContainer/AttackValue


func _ready() -> void:
    if unit_data != null:
        _refresh_display()


func set_unit(unit: UnitData) -> void:
    """Méthode publique pour définir l'unité à afficher"""
    unit_data = unit


func _refresh_display() -> void:
    """Met à jour l'affichage avec les données de l'unité"""
    if not is_node_ready():
        return
    
    if unit_data == null:
        _clear_display()
        return
    
    # Nom de l'unité
    if unit_name_label:
        unit_name_label.text = unit_data.name
    
    # Icône de l'unité
    if unit_icon:
        if unit_data.icon != null:
            unit_icon.texture = unit_data.icon
        else:
            unit_icon.texture = null
    
    # Barre de vie
    if hp_bar:
        hp_bar.max_value = unit_data.max_hp
        hp_bar.value = unit_data.hp
        
        # Couleur de la barre selon le pourcentage de vie
        var hp_percent = float(unit_data.hp) / float(unit_data.max_hp)
        if hp_percent > 0.6:
            hp_bar.modulate = Color(0.2, 0.8, 0.2)  # Vert
        elif hp_percent > 0.3:
            hp_bar.modulate = Color(0.9, 0.9, 0.2)  # Jaune
        else:
            hp_bar.modulate = Color(0.9, 0.2, 0.2)  # Rouge
    
    # Label de vie
    if hp_label:
        hp_label.text = "%d / %d" % [unit_data.hp, unit_data.max_hp]
    
    # Moral
    if morale_label:
        morale_label.text = "%d " % [unit_data.morale]
    
    # Attaque (selon le type d'unité)
    if attack_label:
        var attack_value = 0
        
        # Vérifier quel type d'attaque l'unité possède
        #FIX IT, il faut gérer le fait qu'il peut y avoir plusieurs valeur > 0
        if unit_data.get_score(PowerEnums.PowerType.MELEE) > 0:
            attack_value = unit_data.get_score(PowerEnums.PowerType.MELEE)
        elif unit_data.get_score(PowerEnums.PowerType.RANGED) > 0:
            attack_value = unit_data.get_score(PowerEnums.PowerType.RANGED)
        elif unit_data.get_score(PowerEnums.PowerType.MAGIC) > 0:
            attack_value = unit_data.get_score(PowerEnums.PowerType.MAGIC)
        
        attack_label.text = str(attack_value)


func _clear_display() -> void:
    """Efface l'affichage"""
    if unit_name_label:
        unit_name_label.text = ""
    if unit_icon:
        unit_icon.texture = null
    if hp_bar:
        hp_bar.value = 0
    if hp_label:
        hp_label.text = "0 / 0"
    if morale_label:
        morale_label.text = "0 / 0"
    if attack_label:
        attack_label.text = "0"


func update_display() -> void:
    """Méthode publique pour forcer une mise à jour de l'affichage"""
    _refresh_display()
