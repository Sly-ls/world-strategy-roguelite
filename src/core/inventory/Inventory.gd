extends Resource
class_name Inventory

@export var gold: int = 0
@export var food: int = 0
@export var resources: Dictionary = {}      # String -> int
@export var artifacts: Array[String] = []   # artifact_id uniques

func add_gold(amount: int) -> void:
    gold += amount

func remove_gold(amount: int) -> bool:
    if gold < amount:
        return false
    gold -= amount
    return true

func add_food(amount: int) -> void:
    food += amount

func remove_food(amount: int) -> bool:
    if food < amount:
        return false
    food -= amount
    return true

func add_resource(id: String, amount: int) -> void:
    var cur: int = int(resources.get(id, 0))
    resources[id] = cur + amount

func remove_resource(id: String, amount: int) -> bool:
    var cur: int = int(resources.get(id, 0))
    if cur < amount:
        return false
    resources[id] = cur - amount
    return true

func add_artifact(artifact_id: String) -> void:
    if not artifacts.has(artifact_id):
        artifacts.append(artifact_id)

func remove_artifact(artifact_id: String) -> bool:
    if not artifacts.has(artifact_id):
        return false
    artifacts.erase(artifact_id)
    return true

func merge_from(other: Inventory) -> void:
    if other == null:
        return
    gold += other.gold
    food += other.food
    for k in other.resources.keys():
        add_resource(String(k), int(other.resources[k]))
    for a in other.artifacts:
        add_artifact(String(a))
