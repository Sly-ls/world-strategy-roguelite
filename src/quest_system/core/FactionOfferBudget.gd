class_name FactionOfferBudget
extends RefCounted

var faction_id: StringName

# Points “politiques / opérationnels”
var points: float = 0.0
var points_per_week: float = 70.0  # base (tunable)

# Caps
var max_active_offers: int = 6
var max_active_offers_per_pair: int = 2

# Tracking
var reserved_points_by_quest: Dictionary[StringName, float] = {}  # runtime_id -> points
var active_offer_ids: Dictionary[StringName, bool] = {}           # runtime_id -> true
var active_count_by_pair: Dictionary[StringName, int] = {}        # "a|b" -> count

func _init(id: StringName = &"") -> void:
    faction_id = id

func regen_daily(profile: FactionProfile, war_pressure: float = 0.0) -> void:
    # war_pressure 0..1 (ex: proportion de paires en WAR)
    # Logistique/discipline => meilleure regen (si tu as ces traits)
    var org := profile.get_personality(FactionProfile.PERS_RISK_AVERSION, 0.5)
    var base := points_per_week / 7.0
    var mul := 0.85 + 0.50 * org
    mul *= (1.0 - 0.35 * clampf(war_pressure, 0.0, 1.0))
    points = min(points + base * mul, points_per_week)  # cap weekly

func _reserved_total() -> float:
    var s := 0.0
    for k in reserved_points_by_quest.keys():
        s += float(reserved_points_by_quest[k])
    return s

func available_points() -> float:
    return points - _reserved_total()

func can_open_offer(pair_key: StringName, cost_points: float) -> bool:
    if active_offer_ids.size() >= max_active_offers:
        return false
    if int(active_count_by_pair.get(pair_key, 0)) >= max_active_offers_per_pair:
        return false
    return available_points() >= cost_points

func reserve_for_offer(runtime_id: StringName, pair_key: StringName, cost_points: float) -> bool:
    if not can_open_offer(pair_key, cost_points):
        return false
    reserved_points_by_quest[runtime_id] = cost_points
    active_offer_ids[runtime_id] = true
    active_count_by_pair[pair_key] = int(active_count_by_pair.get(pair_key, 0)) + 1
    return true

func release_offer(runtime_id: StringName, pair_key: StringName, refund_ratio: float = 1.0) -> void:
    var reserved := float(reserved_points_by_quest.get(runtime_id, 0.0))
    reserved_points_by_quest.erase(runtime_id)
    active_offer_ids.erase(runtime_id)

    # décrémente pair count
    if active_count_by_pair.has(pair_key):
        active_count_by_pair[pair_key] = max(0, int(active_count_by_pair[pair_key]) - 1)

    # refund partiel (anti-spam): 1.0 = full refund, 0.8 = listing fee 20%
    refund_ratio = clampf(refund_ratio, 0.0, 1.0)
    points = min(points + reserved * refund_ratio, points_per_week)

func consume_on_resolution(runtime_id: StringName, pair_key: StringName) -> void:
    # à la résolution, on consomme 100%: on retire la réservation sans refund
    reserved_points_by_quest.erase(runtime_id)
    active_offer_ids.erase(runtime_id)
    if active_count_by_pair.has(pair_key):
        active_count_by_pair[pair_key] = max(0, int(active_count_by_pair[pair_key]) - 1)
