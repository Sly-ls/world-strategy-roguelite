extends Node

# Liste manuelle (simple et efficace)
@export var test_script_paths: PackedStringArray = [
    "res://tests/test_logger.gd",
    # "res://tests/test_faction_generation.gd",
    # "res://tests/test_relations_init.gd"
]

@export var stop_on_failure: bool = false

func _ready() -> void:
    var results := []
    for path in test_script_paths:
        var ok := await _run_one(path)
        results.append({ "path": path, "ok": ok })
        if stop_on_failure and not ok:
            break

    _print_summary(results)

func _run_one(path: String) -> bool:
    var scr := load(path)
    if scr == null:
        push_error("TestRunner: impossible de charger " + path)
        return false

    var node = scr.new()
    add_child(node)

    # Cas recommandé : le test émet signal done(ok, details)
    if node.has_signal("done"):
        var args = await node.done
        var ok := true
        if args is Array and args.size() >= 1:
            ok = bool(args[0])
        node.queue_free()
        return ok

    # Fallback si tu n'as pas encore ajouté de signal : on laisse _ready tourner 1 frame
    await get_tree().process_frame
    node.queue_free()
    return true

func _print_summary(results: Array) -> void:
    print("\n========== TEST SUMMARY ==========")
    var failures := 0
    for r in results:
        print("%s : %s" % [r["path"], "OK" if r["ok"] else "FAIL"])
        if not r["ok"]:
            failures += 1
    print("Failures:", failures)
    print("==================================\n")
