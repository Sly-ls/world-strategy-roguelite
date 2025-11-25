extends RefCounted
class_name AttackData

# Structure pour stocker les informations d'une attaque
# avant de les appliquer simultanément

var attacker: UnitData
var targets: Array[UnitData]
var action: String
var phase: String
var damage: int

func _init(p_attacker: UnitData, p_targets: Array[UnitData], p_action_type: String, p_phase: String, p_damage: int):
    attacker = p_attacker
    targets = p_targets
    action = p_action_type
    phase = p_phase
    damage = p_damage

# Applique les dégâts à la cible
func apply() -> void:
    for target in targets:
        var power:int = attacker.get_score(action)
        target.take_damage(action, power)
        print("%s (%s-%s) frappe %s pour %d dégâts (PV restants: %d)" % [
            attacker.name, action, phase, target.name, power, target.hp
        ])
                        
