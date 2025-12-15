extends Resource
class_name HeroAgent

@export var id: String = ""
@export var name: String = ""
@export var faction_id: String = "" # à qui il est affilié (ou "independent")
@export var aggressiveness: float = 0.5  # préfère COMBAT/TRAITOR
@export var greed: float = 0.5           # préfère NEUTRAL
@export var loyalty: float = 0.5         # préfère LOYAL
@export var competence: float = 0.7      # probabilité de réussite

func pick_resolution_choice(q: QuestInstance) -> String:
    # Heuristique simple (upgradeable plus tard via policy/profiles)
    var r := randf()
    var p_loyal := loyalty
    var p_neutral := greed * 0.6
    var p_traitor := aggressiveness * 0.7

    # normalisation basique
    var sum := p_loyal + p_neutral + p_traitor
    if sum <= 0.0:
        return "LOYAL"
    p_loyal /= sum
    p_neutral /= sum

    if r < p_loyal:
        return "LOYAL"
    elif r < p_loyal + p_neutral:
        return "NEUTRAL"
    return "TRAITOR"

func roll_success(q: QuestInstance) -> bool:
    return randf() <= competence
