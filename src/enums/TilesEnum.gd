extends Resource
class_name GameEnums

enum CellType {
    PLAINE,
    TOWN,
    FOREST_SHRINE,
    RUINS,
    MARAIS,
    MONTAGNE,
    WATER,
    DUNGEON,
    FORTRESS,
    VILLAGE 
}

class CellInfo:
    var type: CellType
    var id: int
    var name: String
    var color: Color
    var move_cost: float
    var rest_ratio: float
    var walkable: bool
    var event_id: String
    var rest_hp_ratio: float
    var rest_morale_ratio: float

    func _init(_type: CellType, _id: int, _name: String, _color: Color, _move_cost: float, _rest_ratio: float, _walkable: bool, _event_id: String, _rest_hp_ratio: float, _rest_morale_ratio: float):
        type = _type
        id = _id
        name = _name
        color = _color
        rest_ratio=_rest_ratio
        move_cost = _move_cost
        walkable = _walkable
        event_id = _event_id
        rest_hp_ratio = _rest_hp_ratio
        rest_morale_ratio = _rest_morale_ratio

static var CELL_ENUM := {
    CellType.PLAINE: CellInfo.new(CellType.PLAINE, 0, "Plaine", Color(0.0, 0.711, 0.0, 1.0), 1.0, 1.0, true, "", 1.0, 1.0),
    CellType.TOWN: CellInfo.new(CellType.TOWN, 1, "Ville", Color(0.646, 0.101, 0.141, 1.0), 1.2, 1.5, true, "town_arrival", 1.0, 1.0),
    CellType.FOREST_SHRINE: CellInfo.new(CellType.FOREST_SHRINE, 2, "Sanctuaire", Color(1.0, 1.0, 1.0, 1.0), 0.9, 1.2, true, "forest_shrine", 1.0, 1.0),
    CellType.RUINS: CellInfo.new(CellType.RUINS, 3, "Ruines", Color(0.169, 0.17, 0.162, 1.0), 0.7, 0.5, true, "ruins_ancient", 1.0, 1.0),
    CellType.MARAIS: CellInfo.new(CellType.MARAIS, 3, "Marais", Color(0.209, 0.434, 0.218, 1.0), 0.5, 0.3, true, "", 1.0, 1.0),
    CellType.MONTAGNE: CellInfo.new(CellType.MONTAGNE, 3, "Montagne", Color(0.391, 0.227, 0.251, 1.0), 0.3, 0.5, true, "", 1.0, 1.0),
    CellType.WATER: CellInfo.new(CellType.WATER, 3, "Water", Color(0.174, 0.37, 0.852, 1.0), 0.3, 1.0, false, "", 1.0, 1.0),
    CellType.DUNGEON: CellInfo.new(CellType.DUNGEON, 3, "Dungeon", Color(0.0, 0.0, 0.0, 1.0), 0.8, 1.0, true, "", 1.0, 1.0),
    CellType.FORTRESS: CellInfo.new(CellType.FORTRESS, 3, "Fortress", Color(0.439, 0.439, 0.439, 1.0), 0.8, 1.0, true, "", 1.0, 1.0),
    CellType.VILLAGE: CellInfo.new(CellType.FORTRESS, 3, "Village", Color(0.439, 0.247, 0.439, 1.0), 0.8, 1.0, true, "", 1.0, 1.0)
}

#exemple d'utilisation
#var info := GameEnums.CELL_ENUM[GameEnums.CellType.TOWN]
#print(info.name)        # "Ville"
#print(info.move_cost)   # 2.0
#print(info.id)          # 1
#print(info.type)        # 1 (le CellType.TOWN)
