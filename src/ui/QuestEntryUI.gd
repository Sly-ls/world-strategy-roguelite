# res://src/ui/quests/QuestEntryUI.gd
extends PanelContainer

## Une entrée de quête dans le journal
## Affiche titre, progression, tier, expiration

# ========================================
# NODES
# ========================================

@onready var tier_label: Label = %TierLabel
@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_label: Label = %ProgressLabel
@onready var objective_label: Label = %ObjectiveLabel
@onready var expiration_label: Label = %ExpirationLabel
@onready var rewards_label: Label = %RewardsLabel

# ========================================
# PROPRIÉTÉS
# ========================================

var quest: QuestInstance = null

# ========================================
# SETUP
# ========================================

func setup(p_quest: QuestInstance) -> void:
    """Configure l'entrée avec une quête"""
    quest = p_quest
    _update_display()

func _update_display() -> void:
    """Met à jour l'affichage"""
    if quest == null:
        return
    
    var template := quest.template
    
    # Tier
    tier_label.text = "Tier %d" % template.tier
    tier_label.add_theme_color_override("font_color", QuestTypes.get_tier_color(template.tier))
    
    # Titre
    title_label.text = template.title
    
    # Description
    description_label.text = template.description
    
    # Objectif
    objective_label.text = "→ " + template.get_objective_description()
    
    # Progression
    var percent := quest.get_progress_percent()
    progress_bar.value = percent
    progress_label.text = "%d / %d" % [quest.progress, template.objective_count]
    
    # Coloration de la barre
    if percent >= 100.0:
        progress_bar.add_theme_color_override("fill", Color(0.3, 0.8, 0.3))
    elif percent >= 50.0:
        progress_bar.add_theme_color_override("fill", Color(0.8, 0.8, 0.3))
    else:
        progress_bar.add_theme_color_override("fill", Color(0.3, 0.5, 1.0))
    
    # Expiration
    var days_left := quest.get_days_remaining()
    if days_left < 0:
        expiration_label.text = ""
        expiration_label.hide()
    else:
        expiration_label.text = "⏰ %d jour%s restant%s" % [
            days_left,
            "s" if days_left > 1 else "",
            "s" if days_left > 1 else ""
        ]
        expiration_label.show()
        
        # Couleur selon urgence
        if days_left <= 1:
            expiration_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
        elif days_left <= 3:
            expiration_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
    
    # Récompenses
    var rewards_text := "Récompenses : "
    var reward_strings: Array[String] = []
    for reward in template.rewards:
        reward_strings.append(reward.get_readable_description())
    rewards_label.text = rewards_text + ", ".join(reward_strings)
