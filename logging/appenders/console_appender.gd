extends LogAppender
class_name ConsoleAppender

@export var use_rich: bool = true
@export var use_push_for_warnings_and_errors: bool = true

func append(record: Dictionary) -> void:
    if not _passes(record):
        return

    var line_rich: String = record.get("line_rich", "")
    var line_plain: String = record.get("line_plain", "")
    var level := int(record.get("level", 0))

    if use_push_for_warnings_and_errors:
        if level >= LogTypes.Level.ERROR:
            push_error(line_plain)
        elif level >= LogTypes.Level.WARNING:
            push_warning(line_plain)

    if use_rich and line_rich != "":
        print_rich(line_rich)
    else:
        print(line_plain)
