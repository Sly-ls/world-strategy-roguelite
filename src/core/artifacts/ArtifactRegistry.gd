extends Node
class_name ArtifactRegistry

# état runtime
var specs: Dictionary = {}  # id -> ArtifactSpec

# ownership runtime (pour T3.3)
# owner_type: "PLAYER"|"HERO"|"ARMY"|"LOOT_SITE"|"LOST"
var owner_type: Dictionary = {}  # artifact_id -> String
var owner_id: Dictionary = {}    # artifact_id -> String

func register_spec(spec: ArtifactSpec) -> void:
    if spec == null or spec.id == "":
        return
    specs[spec.id] = spec
    if not owner_type.has(spec.id):
        owner_type[spec.id] = "LOST"
        owner_id[spec.id] = ""

func set_artifact_owner(artifact_id: String, p_type: String, p_id: String) -> void:
    owner_type[artifact_id] = p_type
    owner_id[artifact_id] = p_id

func mark_lost(artifact_id: String) -> void:
    set_artifact_owner(artifact_id, "LOST", "")

func is_lost(artifact_id: String) -> bool:
    return owner_type.get(artifact_id, "LOST") == "LOST"

func get_spec(artifact_id: String) -> ArtifactSpec:
    return specs.get(artifact_id, null)
