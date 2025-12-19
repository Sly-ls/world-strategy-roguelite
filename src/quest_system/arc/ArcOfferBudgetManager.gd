class_name ArcOfferBudgetManager
extends RefCounted

var budget_by_faction: Dictionary[StringName, FactionOfferBudget] = {}

func get_budget(faction_id: StringName) -> FactionOfferBudget:
    if not budget_by_faction.has(faction_id):
        budget_by_faction[faction_id] = FactionOfferBudget.new(faction_id)
    return budget_by_faction[faction_id]

func tick_day(faction_profiles: Dictionary, war_pressure_by_faction: Dictionary = {}) -> void:
    for fid in faction_profiles.keys():
        var b := get_budget(StringName(fid))
        var p: FactionProfile = faction_profiles[fid]
        var wp := float(war_pressure_by_faction.get(fid, 0.0))
        b.regen_daily(p, wp)
