extends Node
class_name LogAppender

@export var min_level: int = LogTypes.Level.DEBUG

func append(_record: Dictionary) -> void:
    pass

func _passes(record: Dictionary) -> bool:
    return int(record.get("level", 0)) >= min_level
