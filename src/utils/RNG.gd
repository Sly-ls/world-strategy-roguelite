extends Node

var rng := RandomNumberGenerator.new()

func _ready():
    rng.randomize()

func seed(value: int):
    rng.seed = value

func randi_range(min_val: int, max_val: int) -> int:
    return rng.randi_range(min_val, max_val)

func randf() -> float:
    return rng.randf()
