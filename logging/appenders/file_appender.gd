extends LogAppender
class_name FileAppender

@export var dir_path: String = "user://logs"
@export var pattern: String = "app_{date}.log" # {date} => YYYY-MM-DD
@export var rotate_max_bytes: int = 2 * 1024 * 1024  # 2MB
@export var rotate_max_files: int = 5                # backups .1 .. .(N-1)

var _file: FileAccess
var _current_date: String = ""

func _ready() -> void:
    _ensure_dir(dir_path)
    _open_for_today()

func _exit_tree() -> void:
    if _file:
        _file.flush()
        _file.close()

func append(record: Dictionary) -> void:
    if not _passes(record):
        return

    var today := Time.get_date_string_from_system() # "YYYY-MM-DD"
    if today != _current_date:
        _open_for_today()

    if _file == null:
        return

    var line := String(record.get("line_plain", ""))
    _rotate_if_needed(line)
    _file.store_line(line)
    _file.flush()

func _open_for_today() -> void:
    _current_date = Time.get_date_string_from_system()
    if _file:
        _file.flush()
        _file.close()
    _file = FileAccess.open(_path_for_base(), FileAccess.WRITE_READ)
    if _file == null:
        push_error("FileAppender: impossible d'ouvrir %s (err=%s)" % [_path_for_base(), str(FileAccess.get_open_error())])
        return
    _file.seek_end()

func _rotate_if_needed(next_line: String) -> void:
    if rotate_max_bytes <= 0:
        return
    var len_now := _file.get_length()
    # +1 pour le \n approximatif de store_line
    if len_now + next_line.length() + 1 < rotate_max_bytes:
        return

    _file.flush()
    _file.close()

    var base := _path_for_base()
    _shift_backups(base)
    # base -> base.1
    _rename_if_exists(base, base + ".1")

    _file = FileAccess.open(base, FileAccess.WRITE_READ)
    if _file:
        _file.seek_end()

func _shift_backups(base: String) -> void:
    # supprime le plus vieux
    if rotate_max_files <= 1:
        _remove_if_exists(base + ".1")
        return

    _remove_if_exists(base + "." + str(rotate_max_files - 1))
    for i in range(rotate_max_files - 2, 0, -1):
        var src := base + "." + str(i)
        var dst := base + "." + str(i + 1)
        _rename_if_exists(src, dst)

func _path_for_base() -> String:
    var name := pattern.replace("{date}", _current_date)
    if not dir_path.ends_with("/"):
        return dir_path + "/" + name
    return dir_path + name

func _ensure_dir(p: String) -> void:
    var abs := ProjectSettings.globalize_path(p)
    if not DirAccess.dir_exists_absolute(abs):
        var err := DirAccess.make_dir_recursive_absolute(abs)
        if err != OK:
            push_error("FileAppender: mkdir %s err=%s" % [abs, str(err)])

func _exists(path: String) -> bool:
    var abs := ProjectSettings.globalize_path(path)
    return FileAccess.file_exists(abs)

func _rename_if_exists(src: String, dst: String) -> void:
    if not _exists(src):
        return
    var a := ProjectSettings.globalize_path(src)
    var b := ProjectSettings.globalize_path(dst)
    var err := DirAccess.rename_absolute(a, b)
    if err != OK:
        push_warning("FileAppender: rename %s -> %s err=%s" % [a, b, str(err)])

func _remove_if_exists(path: String) -> void:
    if not _exists(path):
        return
    var abs := ProjectSettings.globalize_path(path)
    var err := DirAccess.remove_absolute(abs)
    if err != OK:
        push_warning("FileAppender: remove %s err=%s" % [abs, str(err)])
