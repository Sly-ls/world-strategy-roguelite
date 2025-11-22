extends Resource
class_name UnitData

@export var name: String = "Unit"
@export var icon: Texture2D
@export var max_hp: int = 100
@export var hp: int = 100
@export var max_morale: int = 100
@export var morale: int = 100
@export var count: int = 10   # nombre de soldats dans l’unité



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
