extends Node
class_name BaseTest

signal done(ok: bool, details: String)

func pass_test() -> void:
    done.emit(true, "")

func fail_test(details: String) -> void:
    push_error(details)
    done.emit(false, details)
