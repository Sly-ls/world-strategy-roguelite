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

    return u
