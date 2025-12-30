extends Node
class_name HeroManager

var heroes: Dictionary = {} # String -> HeroAgent

func register_hero(h: HeroAgent) -> void:
    if h == null or h.id == "":
        return
    heroes[h.id] = h

func has_hero(hero_id: String) -> bool:
    return heroes.has(hero_id)

func get_hero_by_id(hero_id: String) -> HeroAgent:
    return heroes.get(hero_id, null)

func remove_hero(hero_id: String) -> void:
    heroes.erase(hero_id)

func destroy_hero(hero_id: String) -> void:
    var h: HeroAgent = get_hero_by_id(hero_id)
    if h == null:
        return

    if LootSiteManagerRunner != null:
        LootSiteManagerRunner.spawn_site(h.pos, h.inventory, 20)

    remove_hero(hero_id)
    myLogger.debug("💀 Hero destroyed: %s" % hero_id, LogTypes.Domain.COMBAT)
