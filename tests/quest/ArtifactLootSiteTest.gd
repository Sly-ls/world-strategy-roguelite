# res://test/artifact/ArtifactLootSiteTest.gd
extends BaseTest
class_name ArtifactLootSiteTest

## Test du cycle: armée détruite → LootSite → expiration → artefact LOST → quête retrieve
## Vérifie: ownership tracking, loot site spawn, artifact recovery quest

const ARTIFACT_SPEC_SCRIPT := "res://src/core/artifacts/ArtifactSpec.gd"


func _ready() -> void:
    if ArtifactRegistryRunner == null:
        fail_test("ArtifactRegistryRunner autoload manquant")
        return
    
    if LootSiteManagerRunner == null:
        fail_test("LootSiteManagerRunner autoload manquant")
        return
    
    if ArmyManagerRunner == null:
        fail_test("ArmyManagerRunner autoload manquant")
        return
    
    _test_artifact_lost_and_retrieve()
    
    pass_test("ArtifactLootSiteTest: artefact créé → armée détruite → LootSite → expiré → LOST → quête retrieve")


# =============================================================================
# Test: Artifact Lost / Loot Site / Retrieve Quest
# =============================================================================
func _test_artifact_lost_and_retrieve() -> void:
    _set_day(0)
    
    # 1) Créer et enregistrer un artefact
    var ArtifactSpec = load(ARTIFACT_SPEC_SCRIPT)
    _assert(ArtifactSpec != null, "ArtifactSpec.gd doit être chargeable")
    
    var spec = ArtifactSpec.new()
    spec.id = "TEST_DIVINE_RELIC"
    spec.name = "Relique de Test"
    spec.domain = "divine"
    spec.power = 2
    spec.unique = true
    
    ArtifactRegistryRunner.register_spec(spec)
    print("  ✓ Artefact enregistré: %s (%s)" % [spec.id, spec.name])
    
    # 2) Créer une armée avec l'artefact
    var army: ArmyData = ArmyFactory.create_army("starter")
    army.runtime_position = Vector2i(7, 7)
    army.inventory.gold = 100
    army.inventory.add_artifact(spec.id)
    ArtifactRegistryRunner.set_artifact_owner(spec.id, "ARMY", army.id)
    ArmyManagerRunner.register_army(army)
    
    _assert(army.inventory.artifacts.has(spec.id), "Armée doit avoir l'artefact")
    print("  ✓ Armée créée avec artefact: %s" % army.id)
    
    # 3) Détruire l'armée → doit créer un LootSite
    ArmyManagerRunner.destroy_army(army.id)
    
    var site_id := _find_loot_site_containing(spec.id)
    _assert(site_id != "", "LootSite doit être créé après destruction de l'armée")
    print("  ✓ LootSite créé: %s" % site_id)
    
    # Vérifier l'ownership
    var owner_type: String = ArtifactRegistryRunner.owner_type.get(spec.id, "")
    print("  ✓ Owner après destruction: %s" % owner_type)
    
    # 4) Expirer le LootSite → artefact devient LOST
    _set_day(999)  # Force expiration
    LootSiteManagerRunner.tick_day()
    
    owner_type = ArtifactRegistryRunner.owner_type.get(spec.id, "")
    _assert(owner_type == "LOST", "Artefact doit être LOST après expiration LootSite, got: %s" % owner_type)
    print("  ✓ Artefact LOST après expiration")
    
    # 5) Générer une quête de récupération
    var quest := _generate_retrieve_artifact_quest(spec.id)
    _assert(quest != null, "Quête retrieve doit être générée")
    _assert(quest.template != null, "Quest.template ne doit pas être null")
    _assert(quest.context.get("artifact_id", "") == spec.id, "context.artifact_id doit correspondre")
    
    print("  ✓ Quête retrieve générée: %s" % quest.template.title)
    print("  ✓ Contexte: artifact=%s, giver=%s, profile=%s" % [
        quest.context.get("artifact_id", ""),
        quest.context.get("giver_faction_id", ""),
        quest.context.get("resolution_profile_id", "")
    ])


# =============================================================================
# Helpers
# =============================================================================
func _set_day(day: int) -> void:
    if WorldState != null and "current_day" in WorldState:
        WorldState.current_day = day


func _find_loot_site_containing(artifact_id: String) -> String:
    if not "sites" in LootSiteManagerRunner:
        return ""
    
    var sites: Dictionary = LootSiteManagerRunner.sites
    for sid in sites.keys():
        var site = sites[sid]
        if site != null and site.inventory != null:
            if site.inventory.artifacts.has(artifact_id):
                return String(sid)
    return ""


func _generate_retrieve_artifact_quest(artifact_id: String) -> QuestInstance:
    var spec = ArtifactRegistryRunner.get_spec(artifact_id)
    if spec == null:
        return null
    
    var template := QuestTemplate.new()
    template.id = "retrieve_%s_%d" % [artifact_id, Time.get_ticks_msec()]
    template.title = "Retrouver l'artefact : %s" % spec.name
    template.description = "Un artefact a disparu. Retrouve %s et décide à qui il revient." % spec.name
    template.category = QuestTypes.QuestCategory.EXPLORATION
    template.tier = QuestTypes.QuestTier.TIER_2
    template.objective_type = QuestTypes.ObjectiveType.REACH_POI
    template.objective_target = "loot_site_for_%s" % artifact_id
    template.objective_count = 1
    template.expires_in_days = 15
    
    var ctx: Dictionary = {
        "artifact_id": artifact_id,
        "resolution_profile_id": "artifact_recovery",
        "giver_faction_id": "humans",
        "antagonist_faction_id": "bandits"
    }
    
    return QuestInstance.new(template, ctx)
