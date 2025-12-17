extends Node
class_name BaseTest

var enable: bool = true

signal done(ok: bool, details: String)

# ✅ Etat "source de vérité"
var finished: bool = false
var result_ok: bool = false
var result_details: String = ""

func pass_test(details: String = "") -> void:
    _mark_result(true, details)
    # Signal en deferred (optionnel, utile si tu veux continuer à l’utiliser)
    call_deferred("_emit_done")

func fail_test(details: String) -> void:
    push_error(details)
    _mark_result(false, details)
    call_deferred("_emit_done")

func _mark_result(ok: bool, details: String) -> void:
    if finished:
        return
    finished = true
    result_ok = ok
    result_details = details

func _emit_done() -> void:
    # Peut être appelé plusieurs fois, on protège
    if not finished:
        return
    done.emit(result_ok, result_details)

func assert_true(cond: bool, message: String = "assert_true failed") -> void:
    if not cond:
        fail_test(message)

func enable_test(enable:bool):
    if !enable:
        pass_test("skip")
