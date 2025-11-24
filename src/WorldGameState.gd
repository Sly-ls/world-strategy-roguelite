extends Node
class_name WorldGameState

var player_army: ArmyData = null
var enemy_army: ArmyData = null

var last_battle_result: String = ""  # "victory", "defeat", "draw", "retreat"

# --- Temps global ---

const SEASONS : Array[String] = ["Printemps", "Été", "Automne", "Hiver"]
const DAY_PHASES : Array[String] = ["Aube", "Jour", "Crépuscule", "Nuit"]

const DAYS_PER_SEASON := 15
const PHASES_PER_DAY := 4
const DAY_DURATION_SECONDS := 60.0  # 1 minute par jour
const PHASE_DURATION_SECONDS := DAY_DURATION_SECONDS / PHASES_PER_DAY  # 15s

var current_season: int = 0         # 0..3
var current_day: int = 1            # 1..15
var current_phase: int = 0          # 0..3
var _time_accumulator: float = 0.0  # temps cumulé dans la phase en cours

const REST_DURATION_PHASES := 1
const REST_DURATION_SECONDS := REST_DURATION_PHASES * PHASE_DURATION_SECONDS  # Un repos = 2 phases (ajustable)
const REST_HEAL_PERCENT := 0.15   # Soigne 15% des PV max
const REST_MORALE_GAIN := 10      # +10 moral

var resting: bool = false
var phase_elapsed: float = 0.0  
var rest_seconds_remaining: float = 0.0 

const MOVE_COST := {
    GameEnums.CellType.PLAINE: 3.0,        # Plaine
    GameEnums.CellType.TOWN: 2.0,         # Ville (routes)
    GameEnums.CellType.FOREST_SHRINE: 4.0,
    GameEnums.CellType.RUINS: 5.0,
    # rajoute les futurs biomes ici
}

const DEFAULT_MOVE_COST := 4.0   # Si jamais un biome ne figure pas dans le dictionnaire

func advance_time(delta: float) -> void:
    _time_accumulator += delta

    while _time_accumulator >= PHASE_DURATION_SECONDS:
        _time_accumulator -= PHASE_DURATION_SECONDS
        _increment_phase()


func _increment_phase() -> void:
    current_phase += 1
    if current_phase >= PHASES_PER_DAY:
        current_phase = 0
        _increment_day()


func _increment_day() -> void:
    current_day += 1
    if current_day > DAYS_PER_SEASON:
        current_day = 1
        _increment_season()


func _increment_season() -> void:
    current_season += 1
    if current_season >= SEASONS.size():
        current_season = 0  # on boucle sur l'année


func get_formatted_date() -> String:
    var season_name := SEASONS[current_season]
    var phase_name := DAY_PHASES[current_phase]
    return "%s %02d - %s" % [season_name, current_day, phase_name]
    
