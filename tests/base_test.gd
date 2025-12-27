extends Node
class_name BaseTest

var enable: bool = true

signal done(ok: bool, details: String)

# ✅ Etat "source de vérité"
var finished: bool = false
var result_ok: bool = false
var result_details: String = ""
var count_error :int = 0
func pass_test(details: String = "Passed") -> void:
    if count_error == 0:
        _mark_result(true, details)
        _end_test()
    else:
        var msg :String = "TEST FAILED | %d errors |" % count_error
        fail_test(msg)

func fail_test(details: String) -> void:
    push_error(details)
    _mark_result(false, details)
    _end_test()

func _end_test() -> void:
    count_error = 0
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
        count_error += 1


func _assert(cond: bool, msg: String) -> bool:
    if not cond:
        myLogger.debug("FAILED = %s " % msg, LogTypes.Domain.TEST)
        count_error += 1
    return cond
        
func enable_test(enable:bool):
    if !enable:
        pass_test("skip")
