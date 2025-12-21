extends RefCounted

class_name Utils

static func pair_key(a: String, b: String) -> String:
    if a <= b:
        return StringName("%s|%s" % [a, b])
    return StringName("%s|%s" % [b, a])

#old version kept for reference...for now, need to be deleted some day
func pair_key_1(a: String, b: String) -> String:
    if a <= b:
        return "%s|%s" % [a, b]
    return "%s|%s" % [b, a]
    
func _pair_key_2(a: String, b: String) -> String:
    return "%s|%s" % [a, b]

func _pair_key_3(a: StringName, b: StringName) -> StringName:
    return StringName((String(a) + "|" + String(b)) if (String(a) <= String(b)) else (String(b) + "|" + String(a)))

func _pair_key_4(a: StringName, b: StringName) -> StringName:
    var sa := String(a)
    var sb := String(b)
    return StringName((sa + "|" + sb) if (sa <= sb) else (sb + "|" + sa))

## Static version avec StringName, normalisée (a|b où a <= b)
func pair_key_5(a: StringName, b: StringName) -> StringName:
    var sa := String(a)
    var sb := String(b)
    return StringName(sa + "|" + sb) if sa <= sb else StringName(sb + "|" + sa)
