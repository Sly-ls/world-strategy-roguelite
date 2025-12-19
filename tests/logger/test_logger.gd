extends BaseTest

func _ready() -> void:
    enable_test(false)
    var logger := get_node_or_null("/root/myLogger")
    if logger == null:
        push_error("Logger Autoload introuvable. Ajoute res://logging/logger.gd en Autoload (Name: Logger).")
        return

    # ---- (Optionnel) Forcer une rotation rapide pour le test ----
    # On cherche l'appender fichier et on réduit la taille max pour déclencher la rotation vite.
    for child in logger.get_children():
        if child is FileAppender:
            var fa := child as FileAppender
            fa.dir_path = "user://logs"
            fa.pattern = "test_{date}.log"
            fa.rotate_max_bytes = 4 * 1024  # 4 KB => rotation rapide
            fa.rotate_max_files = 3
            fa.min_level = LogTypes.Level.DEBUG

    logger.info("=== TEST LOGGER START ===", LogTypes.Domain.SYSTEM)

    # ---- Test 1: un message par domaine ----
    logger.debug("System OK", LogTypes.Domain.SYSTEM)
    logger.debug("Quest OK", LogTypes.Domain.QUEST)
    logger.debug("Arc OK", LogTypes.Domain.ARC)
    logger.debug("World OK", LogTypes.Domain.WORLD)
    logger.debug("Army OK", LogTypes.Domain.ARMY)
    logger.debug("Combat OK", LogTypes.Domain.COMBAT)

    # ---- Test 2: filtrage par domaine ----
    logger.set_domain_level(LogTypes.Domain.WORLD, LogTypes.Level.WARNING)
    logger.debug("World DEBUG (doit être filtré)", LogTypes.Domain.WORLD)
    logger.warn("World WARN (doit passer)", LogTypes.Domain.WORLD)
    logger.error("World ERROR (doit passer)", LogTypes.Domain.WORLD)

    logger.disable_domain(LogTypes.Domain.ARC)
    logger.error("Arc ERROR (doit être OFF)", LogTypes.Domain.ARC)

    # ---- Test 3: spam pour déclencher rotation ----
    for i in range(250):
        logger.debug("Spam line to trigger rotation", LogTypes.Domain.SYSTEM, {"i": i})
        if i % 25 == 0:
            await get_tree().process_frame

    logger.info("=== TEST LOGGER END ===", LogTypes.Domain.SYSTEM)

    # ---- Affiche les fichiers présents dans user://logs ----
    _print_log_dir("user://logs")


func _print_log_dir(dir_path: String) -> void:
    var abs := ProjectSettings.globalize_path(dir_path)
    var dir := DirAccess.open(dir_path)
    if dir == null:
        push_warning("Impossible d'ouvrir %s (%s)" % [dir_path, abs])
        return

    print("Log dir:", abs)
    dir.list_dir_begin()
    while true:
        var name := dir.get_next()
        if name == "":
            break
        if not dir.current_is_dir():
            print(" - ", name)
    dir.list_dir_end()
    pass_test()
