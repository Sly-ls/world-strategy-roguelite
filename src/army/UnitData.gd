extends Resource
class_name UnitData

@export var name: String = "Unit"
@export var icon: Texture2D
@export var max_hp: int = 100
@export var hp: int = 100
@export var max_morale: int = 100
@export var morale: int = 100
@export var count: int = 10   # nombre de soldats dans l’unité


# Combat
@export var melee_power: int = 10      # note CàC
@export var ranged_power: int = 0      # note distance
@export var magic_power: int = 0       # note magie
@export var attack_interval: float = 1.5  # secondes entre deux frappes
@export var initiative: int = 0        # >0 = frappe plus tôt dans le tick
@export var is_slow: bool = false      # frappe en fin de phase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
