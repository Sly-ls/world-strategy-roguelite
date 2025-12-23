# DomesticPressureUtil.gd
class_name DomesticPressureUtil
extends RefCounted

static func tick_domestic(
    day: int,
    faction_id: StringName,
    dom: FactionDomesticState,
    profile: FactionProfile,                        # FactionProfile (optionnel)
    economy,                        # FactionEconomy (optionnel)
    arc_notebook,                   # pour compter jours de guerre / pertes proxy
    relations: Dictionary,          # relations[faction][other] -> FactionRelationScore
    world: Dictionary               # tags / crisis flags
) -> void:
    # ---- inputs/proxies ----
    
    var diplo :float = profile.get_personality(FactionProfile.PERS_DIPLOMACY)
    var bell :float = profile.get_personality(FactionProfile.PERS_BELLIGERENCE)
    var honor :float = profile.get_personality(FactionProfile.PERS_HONOR)
    var fear :float = profile.get_personality(FactionProfile.PERS_FEAR)

    var gold :int = (economy.gold if economy != null and economy.has_method("get") == false else (economy.gold if economy != null else 0))
    var poor :bool = (gold < 80) # TODO proxy simple (à remplacer par income/expenses si tu as)

    var war_days := 0
    if arc_notebook != null and arc_notebook.has_method("get_faction_counter"):
        war_days = int(arc_notebook.get_faction_counter(faction_id, &"war_days_rolling_30", 0))
    # fallback: approx via relations weariness (moyenne)
    if war_days == 0 and relations.has(faction_id):
        var w := 0.0
        var n := 0.0
        for other in relations[faction_id].keys():
            var r: FactionRelationScore = relations[faction_id][other]
            w += float(r.weariness)
            n += 1.0
        war_days = int(clampf((w/max(1.0, n)) / 4.0, 0.0, 30.0)) # grossier mais utile

    var crisis := bool(world.get("crisis_active", false))
    var crisis_sev := float(world.get("crisis_severity", 0.0))

    # ---- dynamics ----
    # guerre longue => war_support baisse, unrest monte
    var war_fatigue := clampf(float(war_days) / 30.0, 0.0, 1.0) # 0..1
    var support_drop := 1.2 + 2.5*war_fatigue + 0.8*bell - 0.9*diplo - 0.6*honor
    if poor: support_drop += 0.9
    if crisis: support_drop += 0.6*crisis_sev  # crise fatigue la population

    var unrest_rise := 0.6 + 1.8*war_fatigue + 0.8*fear - 0.6*diplo
    if poor: unrest_rise += 0.8
    if crisis: unrest_rise += 0.7*crisis_sev

    # petits amortisseurs (propagande/ordre) : ici on triche via stabilité actuelle
    support_drop *= (1.0 + 0.35*(1.0 - dom.stability/100.0))
    unrest_rise *= (1.0 - 0.25*(dom.stability/100.0))

    # ---- apply ----
    dom.war_support = int(clampi(dom.war_support - int(round(support_drop)), 0, 100))
    dom.unrest = int(clampi(dom.unrest + int(round(unrest_rise)), 0, 100))

    # stabilité suit l’unrest
    var stab_delta := -int(round(0.6*unrest_rise)) + int(round(0.25*diplo*2.0))
    dom.stability = int(clampi(dom.stability + stab_delta, 0, 100))
