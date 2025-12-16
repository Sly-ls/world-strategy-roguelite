# res://src/quests/narrative/NarrativeGenerator.gd
extends Node

## Générateur de narration procédurale avancée
## PALIER 4 : Histoires cohérentes avec personnages récurrents

# ========================================
# CONFIGURATION
# ========================================

const NARRATIVE_THEMES := {
    "heroic": ["héroïque", "noble", "courageux", "valeureux"],
    "dark": ["sombre", "maudit", "corrompu", "maléfique"],
    "mysterious": ["mystérieux", "énigmatique", "ancien", "oublié"],
    "epic": ["épique", "légendaire", "titanesque", "grandiose"]
}

# ========================================
# PERSONNAGES
# ========================================

var world_characters: Dictionary = {}  ## character_id -> Character

class Character:
    """Personnage récurrent"""
    var id: String = ""
    var name: String = ""
    var title: String = ""  ## Ex: "le Roi", "la Sorcière"
    var faction_id: String = ""
    var role: String = ""  ## "ally", "enemy", "neutral", "quest_giver"
    var personality: String = ""  ## "wise", "cruel", "mysterious", "brave"
    var appearance_count: int = 0
    var first_met_day: int = -1
    var last_seen_day: int = -1
    var relationship_level: int = 0  ## -100 à +100
    
    func get_full_name() -> String:
        if title.is_empty():
            return name
        return "%s %s" % [name, title]

# ========================================
# HISTORIQUE NARRATIF
# ========================================

var narrative_history: Array[NarrativeEvent] = []

class NarrativeEvent:
    """Événement narratif"""
    var day: int = 0
    var event_type: String = ""  ## "quest_completed", "crisis_started", "character_met"
    var description: String = ""
    var involved_characters: Array[String] = []
    var involved_factions: Array[String] = []
    var tags: Array[String] = []

# ========================================
# LIFECYCLE
# ========================================

func _ready() -> void:
    _initialize_world_characters()
    print("✓ NarrativeGenerator initialisé")

func _initialize_world_characters() -> void:
    """Initialise les personnages récurrents du monde"""
    
    # Personnages principaux des factions
    _create_character("king_aldric", "Aldric", "le Roi", "humans", "quest_giver", "wise")
    _create_character("queen_elena", "Elena", "la Reine", "humans", "ally", "brave")
    _create_character("arch_mage", "Thalorin", "l'Archimage", "humans", "quest_giver", "mysterious")
    
    _create_character("elf_lord", "Celeborn", "Seigneur des Elfes", "elves", "neutral", "wise")
    _create_character("elf_ranger", "Laerwen", "la Ranger", "elves", "ally", "brave")
    
    _create_character("orc_warchief", "Grok", "le Chef de Guerre", "orcs", "enemy", "cruel")
    _create_character("bandit_leader", "Scarface", "le Balafré", "bandits", "enemy", "cunning")

func _create_character(id: String, name: String, title: String, faction: String, role: String, personality: String) -> void:
    """Crée un personnage"""
    var character := Character.new()
    character.id = id
    character.name = name
    character.title = title
    character.faction_id = faction
    character.role = role
    character.personality = personality
    world_characters[id] = character

# ========================================
# GÉNÉRATION NARRATIVE
# ========================================

func generate_quest_narrative(quest_type: String, context: Dictionary = {}) -> Dictionary:
    """Génère une narration pour une quête"""
    var narrative := {
        "introduction": "",
        "hook": "",
        "characters": [],
        "theme": "",
        "twist": ""
    }
    
    # Choisir thème
    narrative["theme"] = _choose_theme(context)
    
    # Choisir personnages
    narrative["characters"] = _choose_characters_for_quest(quest_type, context)
    
    # Générer intro
    narrative["introduction"] = _generate_introduction(quest_type, narrative)
    
    # Générer hook
    narrative["hook"] = _generate_hook(quest_type, narrative)
    
    # Twist occasionnel
    if randf() < 0.3:  # 30% chance
        narrative["twist"] = _generate_twist(narrative)
    
    return narrative

func _choose_theme(context: Dictionary) -> String:
    """Choisit un thème narratif"""
    var available_themes := ["heroic", "dark", "mysterious", "epic"]
    
    # Biais selon contexte
    if context.has("is_crisis"):
        available_themes.append("epic")
        available_themes.append("dark")
    
    return available_themes[randi() % available_themes.size()]

func _choose_characters_for_quest(quest_type: String, context: Dictionary) -> Array[String]:
    """Choisit des personnages pour une quête"""
    var chosen: Array[String] = []
    
    # Quest giver
    var quest_givers := _get_characters_by_role("quest_giver")
    if not quest_givers.is_empty():
        chosen.append(quest_givers[randi() % quest_givers.size()])
    
    # Antagoniste si combat
    if quest_type in ["combat", "ruins_clear", "town_defense"]:
        var enemies := _get_characters_by_role("enemy")
        if not enemies.is_empty():
            chosen.append(enemies[randi() % enemies.size()])
    
    # Allié occasionnel
    if randf() < 0.4:  # 40% chance
        var allies := _get_characters_by_role("ally")
        if not allies.is_empty():
            chosen.append(allies[randi() % allies.size()])
    
    return chosen

func _get_characters_by_role(role: String) -> Array[String]:
    """Retourne les IDs des personnages d'un rôle"""
    var chars: Array[String] = []
    for char_id in world_characters:
        var character: Character = world_characters[char_id]
        if character.role == role:
            chars.append(char_id)
    return chars

func _generate_introduction(quest_type: String, narrative: Dictionary) -> String:
    """Génère une introduction"""
    var theme: String = narrative["theme"]
    var characters: Array = narrative["characters"]
    
    var intro := ""
    
    # Intro avec personnage
    if not characters.is_empty():
        var char_id: String = characters[0]
        var character: Character = world_characters[char_id]
        
        intro = "%s vous convoque. " % character.get_full_name()
    else:
        intro = "Une opportunité se présente. "
    
    # Ajouter thème
    var theme_words: Array = NARRATIVE_THEMES.get(theme, [""])
    if not theme_words.is_empty():
        var adjective: String = theme_words[randi() % theme_words.size()]
        intro += "Une quête %s vous attend." % adjective
    
    return intro

func _generate_hook(quest_type: String, narrative: Dictionary) -> String:
    """Génère un hook narratif"""
    var hooks := {
        "combat": [
            "Des ennemis menacent la région.",
            "Un danger se profile à l'horizon.",
            "La bataille est inévitable."
        ],
        "exploration": [
            "Des ruines anciennes attendent d'être découvertes.",
            "Un mystère attend d'être résolu.",
            "L'aventure vous appelle."
        ],
        "diplomacy": [
            "Les tensions montent entre les factions.",
            "Une alliance pourrait changer le cours des événements.",
            "La diplomatie sera votre arme."
        ]
    }
    
    var hook_list: Array = hooks.get(quest_type, ["Une mission vous attend."])
    return hook_list[randi() % hook_list.size()]

func _generate_twist(narrative: Dictionary) -> String:
    """Génère un twist narratif"""
    var twists := [
        "Mais tout n'est pas ce qu'il semble...",
        "Une trahison pourrait être en jeu.",
        "Les véritables enjeux sont bien plus importants.",
        "Un pouvoir ancien se réveille.",
		"Le temps presse plus que vous ne le pensez."
    ]
    
    return twists[randi() % twists.size()]

# ========================================
# GESTION PERSONNAGES
# ========================================

func record_character_interaction(character_id: String) -> void:
    """Enregistre une interaction avec un personnage"""
    var character := world_characters.get(character_id) as Character
    if not character:
        return
    
    character.appearance_count += 1
    character.last_seen_day = WorldState.current_day
    
    if character.first_met_day < 0:
        character.first_met_day = WorldState.current_day
        print("🤝 Première rencontre : %s" % character.get_full_name())

func adjust_character_relationship(character_id: String, delta: int) -> void:
    """Ajuste la relation avec un personnage"""
    var character := world_characters.get(character_id) as Character
    if not character:
        return
    
    character.relationship_level = clampi(character.relationship_level + delta, -100, 100)

func get_character(character_id: String) -> Character:
    """Retourne un personnage"""
    return world_characters.get(character_id)

func get_character_status(character_id: String) -> String:
    """Retourne le statut d'un personnage"""
    var character := world_characters.get(character_id) as Character
    if not character:
        return "inconnu"
    
    if character.relationship_level >= 50:
        return "allié proche"
    elif character.relationship_level >= 25:
        return "allié"
    elif character.relationship_level >= 0:
        return "neutre"
    elif character.relationship_level >= -50:
        return "hostile"
    else:
        return "ennemi juré"

# ========================================
# HISTORIQUE
# ========================================

func record_narrative_event(event_type: String, description: String, characters: Array[String] = [], factions: Array[String] = [], tags: Array[String] = []) -> void:
    """Enregistre un événement narratif"""
    var event := NarrativeEvent.new()
    event.day = WorldState.current_day
    event.event_type = event_type
    event.description = description
    event.involved_characters = characters
    event.involved_factions = factions
    event.tags = tags
    
    narrative_history.append(event)
    
    # Limiter historique à 100 événements
    if narrative_history.size() > 100:
        narrative_history.pop_front()

func get_recent_events(count: int = 10) -> Array[NarrativeEvent]:
    """Retourne les N derniers événements"""
    var recent: Array[NarrativeEvent] = []
    var start := maxi(0, narrative_history.size() - count)
    
    for i in range(start, narrative_history.size()):
        recent.append(narrative_history[i])
    
    return recent

func generate_summary() -> String:
    """Génère un résumé narratif de l'aventure"""
    var summary := "=== CHRONIQUE DE VOTRE AVENTURE ===\n\n"
    
    # Événements majeurs
    summary += "Événements majeurs :\n"
    for event in get_recent_events(20):
        if event.event_type in ["quest_completed", "crisis_started", "campaign_completed"]:
            summary += "• Jour %d : %s\n" % [event.day, event.description]
    
    summary += "\nPersonnages rencontrés :\n"
    for char_id in world_characters:
        var character: Character = world_characters[char_id]
        if character.appearance_count > 0:
            summary += "• %s : %s (%d rencontres)\n" % [
                character.get_full_name(),
                get_character_status(char_id),
                character.appearance_count
            ]
    
    return summary

# ========================================
# PERSISTANCE
# ========================================

func save_state() -> Dictionary:
    var characters_state := {}
    for char_id in world_characters:
        var character: Character = world_characters[char_id]
        characters_state[char_id] = {
            "appearance_count": character.appearance_count,
            "first_met_day": character.first_met_day,
            "last_seen_day": character.last_seen_day,
            "relationship_level": character.relationship_level
        }
    
    var events_state := []
    for event in narrative_history:
        events_state.append({
            "day": event.day,
            "event_type": event.event_type,
            "description": event.description
        })
    
    return {
        "characters": characters_state,
        "events": events_state
    }

func load_state(data: Dictionary) -> void:
    var characters_state: Dictionary = data.get("characters", {})
    for char_id in characters_state:
        var character := world_characters.get(char_id) as Character
        if character:
            var state: Dictionary = characters_state[char_id]
            character.appearance_count = state.get("appearance_count", 0)
            character.first_met_day = state.get("first_met_day", -1)
            character.last_seen_day = state.get("last_seen_day", -1)
            character.relationship_level = state.get("relationship_level", 0)
