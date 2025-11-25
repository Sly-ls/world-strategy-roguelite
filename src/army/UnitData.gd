extends Resource
class_name UnitData

@export var id: String = ""
@export var name: String = ""

@export var max_hp: int = 100
var hp: int = 100

@export var max_morale: int = 100
var morale: int = 100

@export var count: int = 1

@export var melee_power: int = 0
@export var ranged_power: int = 0
@export var magic_power: int = 0

@export var attack_interval: float = 1.5

@export var tags: Array[String] = []
@export var icon: Texture2D

func clone_runtime() -> UnitData:
    # On ne veut jamais modifier le template .tres directement.
    var u := UnitData.new()
    u.id = id
    u.name = name

    u.max_hp = max_hp
    u.hp = max_hp

    u.max_morale = max_morale
    u.morale = max_morale

    u.count = count

    u.melee_power = melee_power
    u.ranged_power = ranged_power
    u.magic_power = magic_power

    u.attack_interval = attack_interval

    u.tags = tags.duplicate()
    u.icon = icon
    
    return u
    
func describe() -> String:
    var description: String = id + "\n"
    description +=  "id: " + id + "\n"
    description +=   "name: " + name + "\n"
    description +=   "hp: " + str(hp) + "/"+ str(max_hp) + "\n"
    description +=   "morale: " + str(morale) + "/"+ str(max_morale) + "\n"
    description +=   "count: " + str(count) + "\n"
    description +=   "melee_power: " + str(melee_power) + "\n"
    description +=   "ranged_power: " + str(ranged_power) + "\n"
    description +=   "magic_power: " + str(magic_power) + "\n"
    return description
