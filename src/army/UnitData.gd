extends Resource
class_name UnitData

@export var id: String = ""
@export var name: String = ""

@export var max_hp: int = 100
var hp: int = 100

@export var max_morale: int = 100
var morale: int = 100

@export var count: int = 1

@export var attack_interval: float = 1.0

@export var tags: Array[String] = []
@export var powers: Dictionary[PowerEnums.PowerType, int] = {}
@export var icon: Texture2D
var player: bool = false

func clone_runtime(_player: bool = false) -> UnitData:
    # On ne veut jamais modifier le template .tres directement.
    var u := UnitData.new()
    u.id = id
    u.name = name

    u.max_hp = max_hp
    u.hp = max_hp

    u.max_morale = max_morale
    u.morale = max_morale

    u.count = count

    u.attack_interval = attack_interval
    
    u.tags = tags.duplicate()
    u.powers = powers.duplicate()
    u.icon = icon
    u.player = _player
    
    return u
    
func describe() -> String:
    var description: String = id + "\n"
    description +=  "id: " + id + "\n"
    description +=   "name: " + name + "\n"
    description +=   "hp: " + str(hp) + "/"+ str(max_hp) + "\n"
    description +=   "morale: " + str(morale) + "/"+ str(max_morale) + "\n"
    description +=   "count: " + str(count) + "\n"
    for key in powers.keys():
        description +=   key + str(powers[key]) + "\n"
    return description
    
func get_targets_order() -> Array[int] :
    var targets_order :Array[int] = []
    targets_order.resize(3)
    var power_rank :int = get_score(PowerEnums.PowerType.FLANKER)
    if power_rank > 0:
        targets_order[0] = 2
        targets_order[1] = 1
        targets_order[2] = 0
    else :
        targets_order[0] = 0
        targets_order[1] = 1
        targets_order[2] = 2

    return targets_order
    
func is_dead() -> bool:
    return hp <= 0
    
func is_ready() -> bool:
    return true
            
func get_targets(defender :ArmyData) -> Array[UnitData]:
    var targets_order :Array[int] = get_targets_order()
    var nbShot :int = 1 +  get_score(PowerEnums.PowerType.MULTISHOT) #pour l'instant sera toujours -1 car pas de pouvoir implementer
    var targets :Array[UnitData] = []
    if nbShot > 0:
        for index :int in targets_order.size():
            var target :UnitData = defender.get_unit_at_position(0, targets_order[index])
            if target!= null && !target.is_dead():
                targets.append(target)
                nbShot -= 1
                if nbShot <= 0:
                    break
    return targets;
  
func is_ready_for(action :PowerEnums.PowerType, phase: PowerEnums.PowerType) -> bool :
    var ready :bool = !is_dead() && is_ready()
    if ready:
        if phase == PowerEnums.PowerType.NORMAL:
            var phase_ok = get_score(PowerEnums.PowerType.INITIATIVE)
            phase_ok += get_score(PowerEnums.PowerType.SLOW)
            if phase_ok <= 0:
                ready=true
            else:
                ready=false
        elif  phase == PowerEnums.PowerType.INITIATIVE || phase == PowerEnums.PowerType.SLOW:
            var phase_ok = get_score(phase)
            if phase_ok > 0:
                ready=true
            else:
                ready=false
        
        if ready:
            ready = get_score(action) > 0
    return ready

func get_score(action :PowerEnums.PowerType) -> int :
    if powers.has(action):
        return int(powers[action])
    else :
        return 0
            
func get_protection(action :PowerEnums.PowerType) -> int :
    match action:
        PowerEnums.PowerType.MELEE:
            return get_score(PowerEnums.PowerType.ARMOR)
        PowerEnums.PowerType.RANGED:
            return get_score(PowerEnums.PowerType.DODGE)
        PowerEnums.PowerType.MAGIC:
            return get_score(PowerEnums.PowerType.MAGIC_RESISTANCE)
        _:
            return 0
    
func take_damage(action :PowerEnums.PowerType, damage :int) -> void :
    var protection :int = get_protection(action)
    hp -= clamp(damage - protection, 0, damage)
    if hp < 0:
        hp = 0
