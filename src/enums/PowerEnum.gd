extends Resource
class_name PowerEnums

enum PowerType {
    #ATTACK/DAMAGE POWER
    MELEE, #1
    RANGED,#2
    MAGIC,#3
    #ATTACK PHASE
    INITIATIVE,#4
    SLOW,#5
    NORMAL,#6
    #POWER
    FLANKER, 
    MULTISHOT, 
    ARMOR, 
    DODGE, 
    MAGIC_RESISTANCE
}

enum PowerCategory {
    ATTACK_POWER,
    ATTACK_PHASE,
    COMBAT_POWER
}
class PowerInfo:
    var type: PowerType
    var category: PowerCategory
    var id: int
    var name: String
    var icon: Texture2D
    var max: int

    func _init(_type: PowerType,_category: PowerCategory, _id: int, _name: String, _icon: Texture2D, _max: int):
        type = _type
        category = _category
        id = _id
        name = _name
        icon = _icon
        max =_max

static var POWER_ENUM := {
    PowerType.MELEE: PowerInfo.new(PowerType.MELEE, PowerCategory.ATTACK_POWER, 0, "MELEE", null, 10000),
    PowerType.RANGED: PowerInfo.new(PowerType.RANGED, PowerCategory.ATTACK_POWER, 0, "RANGED", null, 10000),
    PowerType.MAGIC: PowerInfo.new(PowerType.MAGIC, PowerCategory.ATTACK_POWER, 0, "MAGIC", null, 10000),
    PowerType.INITIATIVE: PowerInfo.new(PowerType.INITIATIVE, PowerCategory.ATTACK_PHASE, 0, "INITIATIVE", null, 1),
    PowerType.SLOW: PowerInfo.new(PowerType.SLOW, PowerCategory.ATTACK_PHASE, 0, "SLOW", null, 1),
    PowerType.NORMAL: PowerInfo.new(PowerType.NORMAL, PowerCategory.ATTACK_PHASE, 0, "NORMAL", null, 1),
    PowerType.FLANKER: PowerInfo.new(PowerType.FLANKER, PowerCategory.COMBAT_POWER, 0, "FLANKER", null, 1),
    PowerType.MULTISHOT: PowerInfo.new(PowerType.MULTISHOT, PowerCategory.COMBAT_POWER, 0, "MULTISHOT", null, 3),
    PowerType.ARMOR: PowerInfo.new(PowerType.ARMOR, PowerCategory.COMBAT_POWER, 0, "ARMOR", null, 10000),
    PowerType.DODGE: PowerInfo.new(PowerType.DODGE, PowerCategory.COMBAT_POWER, 0, "DODGE", null, 10000),
    PowerType.MAGIC_RESISTANCE: PowerInfo.new(PowerType.MAGIC_RESISTANCE, PowerCategory.COMBAT_POWER, 0, "MAGIC_RESISTANCE", null, 10000)
}


#exemple d'utilisation
#var info := GameEnums.CELL_ENUM[GameEnums.CellType.TOWN]
#print(info.name)        # "Ville"
#print(info.move_cost)   # 2.0
#print(info.id)          # 1
#print(info.type)        # 1 (le CellType.TOWN)
