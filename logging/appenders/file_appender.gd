extends LogAppender
class_name FileAppender

var file_path: String = "user://logs/app.log"
var _file: FileAccess

func _init(p_file_path: String = "user://logs/app.log") -> void:
    file_path = p_file_path

func _ready() -> void:
    _ensure_dir(file_path.get_base_dir())
    _open_file()

func _exit_tree() -> void:
    if _file:
        _file.flush()
        _file.close()

func append(record: Dictionary) -> void:
    if not _passes(record):
        return
    if _file == null:
        _open_file()
        if _file == null:
            return

    _file.store_line(record.get("line_plain", ""))
    _file.flush()

func _open_file() -> void:
    _file = FileAccess.open(file_path, FileAccess.WRITE_READ)
    if _file == null:
        push_error("FileAppender: impossible d'ouvrir %s (err=%s)" % [file_path, str(FileAccess.get_open_error())])
        return
    _file.seek_end()

func _ensure_dir(dir_path: String) -> void:
    var abs_dir := ProjectSettings.globalize_path(dir_path)
    if not DirAccess.dir_exists_absolute(abs_dir):
        var err := DirAccess.make_dir_recursive_absolute(abs_dir)
        if err != OK:
            push_error("FileAppender: impossible de créer le dossier %s (err=%s)" % [abs_dir, str(err)])
