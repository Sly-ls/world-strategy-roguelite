
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
class_name LoggerClass

@export var default_level: int = LogTypes.Level.INFO
@export var default_domain_level: int = LogTypes.Level.INFO
@export var file_path: String = "user://logs/app.log"

# domain -> level
var domain_levels: Dictionary = {}

var _appenders: Array[LogAppender] = []

func _ready() -> void:
    # Exemples de réglages par domaine (adapte)
    if domain_levels.is_empty():
        domain_levels[LogTypes.Domain.SYSTEM] = LogTypes.Level.DEBUG
        domain_levels[LogTypes.Domain.QUEST] = LogTypes.Level.DEBUG
        domain_levels[LogTypes.Domain.ARC] = LogTypes.Level.DEBUG
        domain_levels[LogTypes.Domain.QUEST] = LogTypes.Level.DEBUG
        domain_levels[LogTypes.Domain.WORLD] = LogTypes.Level.DEBUG
        domain_levels[LogTypes.Domain.ARMY] = LogTypes.Level.DEBUG
        domain_levels[LogTypes.Domain.TEST] = LogTypes.Level.DEBUG

    # Appendres par défaut
    if _appenders.is_empty():
        add_appender(ConsoleAppender.new())
        add_appender(FileAppender.new(file_path))

func add_appender(appender: LogAppender) -> void:
    _appenders.append(appender)
    if appender.get_parent() == null:
        add_child(appender)

func clear_appenders() -> void:
    for a in _appenders:
        if a.get_parent() == self:
            remove_child(a)
        a.queue_free()
    _appenders.clear()

func set_default_level(level: int) -> void:
    default_level = level

func set_domain_level(domain: int, level: int) -> void:
    domain_levels[domain] = level

func disable_domain(domain: int) -> void:
    domain_levels[domain] = LogTypes.Level.OFF

func log(level: int, message: String, domain: int = -1, context: Dictionary = {}) -> void:
    var threshold := _threshold_for(domain)
    if threshold == LogTypes.Level.OFF:
        return
    if level < threshold:
        return

    var ts := Time.get_datetime_string_from_system()
    var domain_label := "GLOBAL" if domain == -1 else LogTypes.domain_name(domain)
    var level_label := LogTypes.level_name(level)

    var ctx_suffix := ""
    if not context.is_empty():
        ctx_suffix = " | " + JSON.stringify(context)

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

    for appender in _appenders:
        appender.append(record)

func debug(message: String, domain: int = -1, context: Dictionary = {}) -> void:
    log(LogTypes.Level.DEBUG, message, domain, context)

func info(message: String, domain: int = -1, context: Dictionary = {}) -> void:
    log(LogTypes.Level.INFO, message, domain, context)

func warn(message: String, domain: int = -1, context: Dictionary = {}) -> void:
    log(LogTypes.Level.WARNING, message, domain, context)

func error(message: String, domain: int = -1, context: Dictionary = {}) -> void:
    log(LogTypes.Level.ERROR, message, domain, context)

func critical(message: String, domain: int = -1, context: Dictionary = {}) -> void:
    log(LogTypes.Level.CRITICAL, message, domain, context)

func _threshold_for(domain: int) -> int:
    # Si domaine NON fourni => default_level
    if domain == -1:
        return default_level
    # Si domaine fourni mais pas configuré => default_domain_level
    return int(domain_levels.get(domain, default_domain_level))
