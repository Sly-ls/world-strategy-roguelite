class_name WorldTargeting
extends RefCounted

static func _state_threat_mul(st: StringName) -> float:
    match st:
        &"WAR":      return 1.00
        &"CONFLICT": return 0.80
        &"RIVALRY":  return 0.55
        &"TRUCE":    return 0.30
        &"ALLIANCE": return 0.10
        _:           return 0.25

static func _state_opp_mul(st: StringName) -> float:
    match st:
        &"TRUCE":    return 1.00
        &"RIVALRY":  return 0.85
        &"CONFLICT": return 0.70
        &"WAR":      return 0.45
        &"ALLIANCE": return 0.10
        _:           return 0.35

static func _pair_threat(a: Dictionary, self_fatigue: float) -> float:
    var st: StringName = a.get("state", &"NEUTRAL")
    var rel := float(a.get("rel_mean", 0.0))
    var tens := float(a.get("tension_mean", 0.0)) / 100.0
    var griev := float(a.get("griev_mean", 0.0)) / 100.0
    var wear := float(a.get("wear_mean", 0.0)) / 100.0

    var host := clampf(max(0.0, -rel) / 100.0, 0.0, 1.0)
    var pressure := clampf(0.65 * tens + 0.35 * griev, 0.0, 1.0)
    var t := host * pressure * _state_threat_mul(st)
    t *= (1.0 + 0.35 * wear) * (1.0 + 0.20 * clampf(self_fatigue, 0.0, 1.0))
    return clampf(t, 0.0, 1.0)

static func _pair_opportunity(a: Dictionary, self_fatigue: float) -> float:
    var st: StringName = a.get("state", &"NEUTRAL")
    var rel := float(a.get("rel_mean", 0.0))
    var tens := float(a.get("tension_mean", 0.0)) / 100.0
    var griev := float(a.get("griev_mean", 0.0)) / 100.0

    var host := clampf(max(0.0, -rel - 20.0) / 80.0, 0.0, 1.0)
    var heat := clampf(0.70 * tens + 0.30 * griev, 0.0, 1.0)

    var o := host * heat * _state_opp_mul(st)
    o *= (1.0 - 0.60 * clampf(self_fatigue, 0.0, 1.0))
    return clampf(o, 0.0, 1.0)

static func compute_priority_targets(
    ctx: FactionWorldContext,
    notebook: ArcNotebook,
    self_id: StringName,
    decay_per_day: float = 0.93
) -> Dictionary:
    var best_enemy := &""
    var best_enemy_score := -1e9
    var best_ally := &""
    var best_ally_score := -1e9

    var enemy_rank: Array = []
    var ally_rank: Array = []

    for a in ctx.arcs:
        var other: StringName = StringName(a.get("other_id", &""))
        if other == &"":
            continue

        var rel := float(a.get("rel_mean", 0.0))
        var trust := float(a.get("trust_mean", 0.0))
        var st: StringName = a.get("state", &"NEUTRAL")

        var threat := _pair_threat(a, ctx.fatigue)
        var opp := _pair_opportunity(a, ctx.fatigue)

        # Historique (heat décadent) : ce que l’autre a fait envers nous
        var h := notebook.get_pair_heat(self_id, other, ctx.day, decay_per_day)
        var hostile_from := float(h["hostile_from_other"])
        var friendly_from := float(h["friendly_from_other"])

        # Normaliser heat -> 0..1 (soft cap)
        var hostile_n := 1.0 - exp(-0.35 * hostile_from)   # 0..~1
        var friendly_n := 1.0 - exp(-0.35 * friendly_from)

        # --- Score ennemi ---
        # menace + opportunité + hostilité récente de l’autre
        var enemy_score := 1.00*threat + 0.70*opp + 0.55*hostile_n - 0.35*friendly_n
        # si relation déjà positive, on pénalise (évite de choisir comme “ennemi” un allié)
        enemy_score -= 0.25 * clampf((rel) / 100.0, 0.0, 1.0)

        # --- Score allié ---
        # relation + trust + gestes amicaux récents, pénalise hostilité
        var rel_pos := clampf(rel / 100.0, 0.0, 1.0)
        var trust_pos := clampf(trust / 100.0, 0.0, 1.0)
        var ally_score := 0.70*rel_pos + 0.55*trust_pos + 0.70*friendly_n - 0.85*hostile_n
        # si on est en WAR/CONFLICT, on baisse un peu la probabilité “allié” avec cet autre
        if st == &"WAR" or st == &"CONFLICT":
            ally_score *= 0.55

        enemy_rank.append({"id": other, "score": enemy_score, "threat": threat, "opp": opp, "hostile": hostile_from, "friendly": friendly_from})
        ally_rank.append({"id": other, "score": ally_score, "rel": rel, "trust": trust, "hostile": hostile_from, "friendly": friendly_from})

        if enemy_score > best_enemy_score:
            best_enemy_score = enemy_score
            best_enemy = other

        if ally_score > best_ally_score:
            best_ally_score = ally_score
            best_ally = other

    # Évite best_enemy == best_ally : si collision, prend le 2ème meilleur ally
    if best_enemy != &"" and best_enemy == best_ally:
        ally_rank.sort_custom(func(x,y): return float(x["score"]) > float(y["score"]))
        for item in ally_rank:
            var oid: StringName = item["id"]
            if oid != best_enemy:
                best_ally = oid
                best_ally_score = float(item["score"])
                break

    # Tri debug/metrics
    enemy_rank.sort_custom(func(x,y): return float(x["score"]) > float(y["score"]))
    ally_rank.sort_custom(func(x,y): return float(x["score"]) > float(y["score"]))

    return {
        "best_enemy": best_enemy,
        "best_enemy_score": best_enemy_score,
        "best_ally": best_ally,
        "best_ally_score": best_ally_score,
        "enemy_rank": enemy_rank,
        "ally_rank": ally_rank
    }
