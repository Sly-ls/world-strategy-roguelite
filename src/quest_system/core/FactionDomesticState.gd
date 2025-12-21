# FactionDomesticState.gd
class_name FactionDomesticState
extends RefCounted

var stability: int = 70        # 0..100 (ordre public / cohésion interne)
var war_support: int = 70      # 0..100 (acceptation sociale de la guerre)
var unrest: int = 10           # 0..100 (moteur de quests "maintenir l'ordre")


func _init(p_stability: int = 70, p_war_support: int = 70, p_unrest: int = 10):
    stability = p_stability
    war_support = p_war_support  # ✅ Corrigé
    unrest = p_unrest            # ✅ Corrigé


func pressure() -> float:
    # 0..1 (plus haut = plus fragile)
    # war_support bas + unrest haut = pression haute
    return clampf(0.55 * (1.0 - war_support / 100.0) + 0.45 * (unrest / 100.0), 0.0, 1.0)
