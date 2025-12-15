extends Node
class_name LootSiteManager

var sites: Dictionary = {} # id -> LootSite

func spawn_site(p_pos: Vector2i, inv: Inventory, expires: int = 20) -> LootSite:
    var s := LootSite.new()
    s.id = "loot_%d_%d_%d" % [p_pos.x, p_pos.y, Time.get_ticks_msec()]
    s.pos = p_pos
    s.created_day = WorldState.current_day
    s.expires_in_days = expires
    s.inventory = Inventory.new()
    s.inventory.merge_from(inv)

    sites[s.id] = s

    # ownership artefacts => LOOT_SITE
    for a in s.inventory.artifacts:
        if ArtifactRegistryRunner:
            ArtifactRegistryRunner.set_artifact_owner(String(a), "LOOT_SITE", s.id)

    print("💰 LootSite spawned:", s.id, "pos=", s.pos, "artifacts=", s.inventory.artifacts.size())
    return s

func take_all(site_id: String) -> Inventory:
    var s: LootSite = sites.get(site_id, null)
    if s == null:
        return null
    sites.erase(site_id)

    # owner artefacts => LOST (jusqu'à ce que quelqu'un les ajoute à son inventaire et set_owner)
    for a in s.inventory.artifacts:
        if ArtifactRegistryRunner:
            ArtifactRegistryRunner.mark_lost(String(a))

    return s.inventory

func tick_day() -> void:
    var to_remove: Array[String] = []
    for id in sites.keys():
        var s: LootSite = sites[id]
        if s.is_expired(WorldState.current_day):
            to_remove.append(id)
    for id in to_remove:
        print("🕳️ LootSite expired:", id)
        # artefacts redeviendront LOST
        var inv := take_all(id)
        # inv peut être null si déjà pris
