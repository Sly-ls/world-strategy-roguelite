extends RefCounted
class_name AttackData

# Structure pour stocker les informations d'une attaque
# avant de les appliquer simultanément

var attacker: UnitData
var targets: Array[UnitData]
var action: PowerEnums.PowerType
var phase: PowerEnums.PowerType
var damage: int
var player: bool = false

func _init(p_attacker: UnitData, p_targets: Array[UnitData], p_action_type: PowerEnums.PowerType, p_phase: PowerEnums.PowerType, p_damage: int, p_player:bool=false):
    attacker = p_attacker
    targets = p_targets
    action = p_action_type
    phase = p_phase
    damage = p_damage

# Applique les dégâts à la cible
func apply() -> Array[String]:
    var messages: Array[String] = []
    for target :UnitData in targets:
        var power:int = attacker.get_score(action)
        target.take_damage(action, power)
        var action_name :String = PowerEnums.POWER_ENUM[action].name
        var phase_name :String = PowerEnums.POWER_ENUM[phase].name
        var message: String = "%s (%s-%s) frappe %s pour %d dégâts (PV restants: %d)" % [
            attacker.name, action_name, phase_name, target.name, power, target.hp
        ]
        if target.hp <= 0:
            message += "\n%s meurt" % target.name
            if target.player:
                WorldState.allies_death.append(target)
            else :
                WorldState.ennemies_death.append(target)
        messages.append(message)
    return messages
            
                        
