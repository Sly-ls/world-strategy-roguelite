extends Node

@export var excluded_dirs: PackedStringArray = [
    "res://tests/combat",
    "res://tests/logger",
    "res://tests/quest",
	"res://tests/runners"
]
@export var root_dir: String = "res://tests"
@export var stop_on_failure: bool = false
@export var per_test_timeout_sec: float = 10.0

func _ready() -> void:
    
    print("====================================\n")
    print("Recherche des tests")
    print("====================================\n")
    var tests := _discover_tests(root_dir)
    tests.sort()

    if tests.is_empty():
        push_warning("TestRunner: aucun test trouvé dans %s (pattern: test_*.gd)" % root_dir)
        return

    print("\n== TestRunner: %d test(s) détecté(s) ==" % tests.size())
    for t in tests:
        print(" - ", t)
    print("====================================\n")

    var results := []
    for path in tests:
        var ok := await _run_one(path)
        results.append({ "path": path, "ok": ok })
        if stop_on_failure and not ok:
            break

    _print_summary(results)
func _is_excluded_dir(path: String) -> bool:
    var p := path.simplify_path()
    for ex in excluded_dirs:
        var e := String(ex).simplify_path()
        # exclude exact dir OR anything under it
        if p == e or p.begins_with(e + "/"):
            return true
    return false
func _discover_tests(dir_path: String) -> Array[String]:
    var out: Array[String] = []
    
    # ✅ stoppe la récursion si le répertoire est exclu
    if _is_excluded_dir(dir_path):    
        print("Tests dans le repertoire: %s", dir_path)
        return out
        
    var dir := DirAccess.open(dir_path)
    if dir == null:
        push_error("TestRunner: impossible d'ouvrir %s" % dir_path)
        return out

    dir.list_dir_begin()
    while true:
        var name := dir.get_next()
        if name == "":
            break
        if name.begins_with("."):
            continue

        var full := dir_path.path_join(name)
        if dir.current_is_dir():
            out.append_array(_discover_tests(full))
        else:
            # Pattern: test_*.gd (on exclut base_test.gd)
            if (name.begins_with("test_") or name.ends_with("Test.gd")):
                if name == "base_test.gd":
                    continue
                print("test ajouté : %s", name)
                out.append(full)

    dir.list_dir_end()
    return out
func _run_one(path: String) -> bool:
    print("\n--- RUN ", path, " ---")

    var scr := load(path)
    if scr == null:
        push_error("TestRunner: load() a échoué: " + path)
        return false

    var node := scr.new() as BaseTest
    if node == null:
        push_error("TestRunner: %s n'hérite pas de BaseTest (extends BaseTest manquant ?)" % path)
        return false

    var start_ms := Time.get_ticks_msec()
    var done_received := false
    var ok := false
    var details := ""

    # ✅ connect avant add_child (et test est bien un BaseTest)
    node.done.connect(func(p_ok: bool, p_details: String) -> void:
        done_received = true
        ok = p_ok
        details = p_details
    , CONNECT_ONE_SHOT)

    add_child(node)

    while not done_received:
        await get_tree().process_frame

        if (node is BaseTest) and (node as BaseTest).finished:
            done_received = true
            ok = (node as BaseTest).result_ok
            details = (node as BaseTest).result_details
            break

        var elapsed := (Time.get_ticks_msec() - start_ms) / 1000.0
        if elapsed > per_test_timeout_sec:
            ok = false
            details = "Timeout (> %.1fs)" % per_test_timeout_sec
            push_error("TestRunner: timeout sur " + path)
            break


    node.queue_free()
    print("--- RESULT ", ("OK" if ok else "FAIL"), ((" | " + details) if details != "" else ""), " ---")
    return ok

func _print_summary(results: Array) -> void:
    print("\n========== TEST SUMMARY ==========")
    var failures := 0
    for r in results:
        print("%s : %s" % [r["path"], "OK" if r["ok"] else "FAIL"])
        if not r["ok"]:
            failures += 1
    print("Failures:", failures)
    print("==================================\n")
