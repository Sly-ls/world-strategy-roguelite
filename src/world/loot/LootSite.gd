extends Resource
class_name LootSite

@export var id: String = ""
@export var pos: Vector2i = Vector2i.ZERO
@export var inventory: Inventory = Inventory.new()
@export var created_day: int = 0
@export var expires_in_days: int = 20

func is_expired(current_day: int) -> bool:
    if expires_in_days < 0:
        return false
    return current_day >= (created_day + expires_in_days)
