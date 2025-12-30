
#Utilisation (remplacer les print)
#Logger.info("Je démarre le jeu")  # pas de domaine => default_level
#Logger.debug("GET /players", LogTypes.Domain.NETWORK)
#Logger.warn("Save lente", LogTypes.Domain.SAVE, {"ms": 250})
#Logger.error("Impossible de charger texture", LogTypes.Domain.UI)

#Activer / couper des domaines (remplace tes booléens)
#Logger.set_domain_level(LogTypes.Domain.NETWORK, LogTypes.Level.INFO)
#Logger.disable_domain(LogTypes.Domain.AI)  # équivalent à boolean OFF

# Ajouter un “appender” Webhook (alertes temps réel)
#var wh := WebhookAppender.new("https://ton-webservice/logs", "TOKEN_OPTIONNEL")
#wh.min_level = LogTypes.Level.ERROR
#Logger.add_appender(wh)
extends Node
class_name MyLoggerClass

# ProjectSettings (optionnels)
const PS_MODE := "logging/mode"                 # "auto" | "dev" | "release"
const PS_CONFIG_PATH := "logging/config_path"   # ex: "res://logging/logger_config.json"
const PS_DOMAINS := "logging/domains"           # Dictionary { "WORLD":"DEBUG", ... }
const PS_APPENDERS := "logging/appenders"       # Dictionary (voir plus bas)

var default_level: int = LogTypes.Level.DEBUG
var default_domain_level: int = LogTypes.Level.DEBUG
var domain_levels: Dictionary = {} # domain(int) -> level(int)

var _appenders: Array[LogAppender] = []

var _reloading: bool = false

func _ready() -> void:
    var cfg := _load_config()
    _apply_config(cfg)
    _setup_appenders(cfg)

# ---------- API ----------
func debug(msg: String, domain: int = -1, ctx: Dictionary = {}) -> void:
    _log(LogTypes.Level.DEBUG, msg, domain, ctx)
func info(msg: String, domain: int = -1, ctx: Dictionary = {}) -> void:
    _log(LogTypes.Level.INFO, msg, domain, ctx)
func warn(msg: String, domain: int = -1, ctx: Dictionary = {}) -> void:
    _log(LogTypes.Level.WARNING, msg, domain, ctx)
func error(msg: String, domain: int = -1, ctx: Dictionary = {}) -> void:
    _log(LogTypes.Level.ERROR, msg, domain, ctx)
func critical(msg: String, domain: int = -1, ctx: Dictionary = {}) -> void:
    _log(LogTypes.Level.CRITICAL, msg, domain, ctx)

func set_domain_level(domain: int, level: int) -> void:
    domain_levels[domain] = level
func disable_domain(domain: int) -> void:
    domain_levels[domain] = LogTypes.Level.OFF

# ---------- Core ----------
func _log(level: int, message: String, domain: int, context: Dictionary) -> void:
    if _reloading:
        return
    var threshold := _threshold_for(domain)
    if threshold == LogTypes.Level.OFF or level < threshold:
        return

    var ts := Time.get_datetime_string_from_system()
    var domain_label := "GLOBAL" if domain == -1 else LogTypes.domain_name(domain)
    var level_label := LogTypes.level_name(level)

    var ctx_suffix := ""
    if not context.is_empty():
        ctx_suffix = " | " + JSON.stringify(context)

    # Format prod lisible
    var line_plain := "%s - [%s] [%s] - %s%s" % [ts, domain_label, level_label, message, ctx_suffix]
    var color := LogTypes.level_color(level)
    var line_rich := "%s - [%s] [color=%s][%s][/color] - %s%s" % [ts, domain_label, color, level_label, message, ctx_suffix]

    var record := {
        "ts": ts,
        "level": level,
        "level_name": level_label,
        "domain": domain_label,
        "message": message,
        "context": context,
        "line_plain": line_plain,
        "line_rich": line_rich,
    }

    for a in _appenders:
        a.append(record)

func _threshold_for(domain: int) -> int:
    if domain == -1:
        return default_level
    return int(domain_levels.get(domain, default_domain_level))

# ---------- Config loading ----------
func _load_config() -> Dictionary:
    # 1) Override testeurs : user://logger_config.json
    var user_override := "user://logger_config.json"
    if FileAccess.file_exists(ProjectSettings.globalize_path(user_override)):
        var c := _read_json(user_override)
        if not c.is_empty():
            return c

    # 2) Sinon ProjectSettings logging/config_path, sinon défaut res://
    var cfg_path := "res://logging/logger_config.json"
    if ProjectSettings.has_setting(PS_CONFIG_PATH):
        cfg_path = str(ProjectSettings.get_setting(PS_CONFIG_PATH))

    var c2 := _read_json(cfg_path)
    if not c2.is_empty():
        return c2

    # 3) Sinon fallback minimal (dev/release auto)
    return {}

func _read_json(path: String) -> Dictionary:
    var abs := ProjectSettings.globalize_path(path)
    if not FileAccess.file_exists(abs):
        return {}
    var f := FileAccess.open(path, FileAccess.READ)
    if f == null:
        return {}
    var txt := f.get_as_text()
    var parsed = JSON.parse_string(txt)
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _apply_config(cfg: Dictionary) -> void:
    var mode := _resolve_mode(cfg.get("mode", null))

    # Defaults selon mode
    if mode == "release":
        default_level = LogTypes.Level.INFO
        default_domain_level = LogTypes.Level.INFO
    else:
        default_level = LogTypes.Level.DEBUG
        default_domain_level = LogTypes.Level.DEBUG

    # Override depuis JSON
    if cfg.has("default_level"):
        default_level = LogTypes.level_from(cfg["default_level"])
    if cfg.has("default_domain_level"):
        default_domain_level = LogTypes.level_from(cfg["default_domain_level"])

    # Domaines: d'abord JSON, sinon ProjectSettings, sinon tous DEBUG/INFO selon mode
    domain_levels.clear()

    var domains_dict: Dictionary = {}
    if cfg.has("domains") and typeof(cfg["domains"]) == TYPE_DICTIONARY:
        domains_dict = cfg["domains"]
    elif ProjectSettings.has_setting(PS_DOMAINS) and typeof(ProjectSettings.get_setting(PS_DOMAINS)) == TYPE_DICTIONARY:
        domains_dict = ProjectSettings.get_setting(PS_DOMAINS)

    if not domains_dict.is_empty():
        for k in domains_dict.keys():
            var d := LogTypes.domain_from(k)
            if d != -1:
                domain_levels[d] = LogTypes.level_from(domains_dict[k])
    else:
        # Fallback: tous au niveau de default_domain_level
        for d in LogTypes.Domain.values():
            domain_levels[d] = default_domain_level
            
func _resolve_mode(mode_value) -> String:
    # JSON > ProjectSettings > auto
    var mode := ""
    if typeof(mode_value) == TYPE_STRING:
        mode = String(mode_value).strip_edges().to_lower()

    if mode == "" and ProjectSettings.has_setting(PS_MODE):
        mode = String(ProjectSettings.get_setting(PS_MODE)).strip_edges().to_lower()

    if mode == "dev" or mode == "release":
        return mode

    # auto
    return "dev" if OS.is_debug_build() else "release"

# ---------- Appenders setup ----------
func _setup_appenders(cfg: Dictionary) -> void:
    _clear_appenders()

    var mode := _resolve_mode(cfg.get("mode", null))

    # JSON appenders > ProjectSettings appenders > fallback
    var app_cfg: Dictionary = {}
    if cfg.has("appenders") and typeof(cfg["appenders"]) == TYPE_DICTIONARY:
        app_cfg = cfg["appenders"]
    elif ProjectSettings.has_setting(PS_APPENDERS) and typeof(ProjectSettings.get_setting(PS_APPENDERS)) == TYPE_DICTIONARY:
        app_cfg = ProjectSettings.get_setting(PS_APPENDERS)

    # Console
    var console_enabled := (mode == "dev") # par défaut: console surtout en dev
    var console_min := (LogTypes.Level.DEBUG if mode == "dev" else LogTypes.Level.WARNING)
    var console_rich := (mode == "dev")

    if app_cfg.has("console"):
        var c = app_cfg["console"]
        if typeof(c) == TYPE_DICTIONARY:
            if c.has("enabled"): console_enabled = bool(c["enabled"])
            if c.has("min_level"): console_min = LogTypes.level_from(c["min_level"])
            if c.has("rich"): console_rich = bool(c["rich"])

    var ca := ConsoleAppender.new()
    ca.enabled = console_enabled
    ca.min_level = console_min
    ca.use_rich = console_rich
    add_appender(ca)

    # File
    var file_enabled := true
    var file_min := (LogTypes.Level.DEBUG if mode == "dev" else LogTypes.Level.INFO)
    var file_dir := "user://logs"
    var file_pattern := "app_{date}.log"
    var max_bytes := (2 * 1024 * 1024)
    var max_files := 5

    if app_cfg.has("file"):
        var f = app_cfg["file"]
        if typeof(f) == TYPE_DICTIONARY:
            if f.has("enabled"): file_enabled = bool(f["enabled"])
            if f.has("min_level"): file_min = LogTypes.level_from(f["min_level"])
            if f.has("dir"): file_dir = String(f["dir"])
            if f.has("pattern"): file_pattern = String(f["pattern"])
            if f.has("rotate_max_bytes"): max_bytes = int(f["rotate_max_bytes"])
            if f.has("rotate_max_files"): max_files = int(f["rotate_max_files"])

    var fa := FileAppender.new()
    fa.enabled = file_enabled
    fa.min_level = file_min
    fa.dir_path = file_dir
    fa.pattern = file_pattern
    fa.rotate_max_bytes = max_bytes
    fa.rotate_max_files = max_files
    add_appender(fa)

func add_appender(a: LogAppender) -> void:
    _appenders.append(a)
    add_child(a)

func _clear_appenders() -> void:
    for a in _appenders:
        if is_instance_valid(a):
            a.queue_free()
    _appenders.clear()

func reload() -> void:
    if _reloading:
        return
    _reloading = true

    # Important: si des logs arrivent pendant le reload, ils ne doivent pas crasher
    var old_appenders := _appenders.duplicate()
    _appenders = []

    # Recharge config + ré-applique
    var cfg := _load_config()
    _apply_config(cfg)
    _setup_appenders(cfg)

    # Nettoyage anciens appenders
    for a in old_appenders:
        if is_instance_valid(a):
            a.queue_free()

    _reloading = false
    info("Logger reloaded", LogTypes.Domain.SYSTEM)
