extends Object
class_name LogTypes

enum Level { DEBUG = 10, INFO = 20, WARNING = 30, ERROR = 40, CRITICAL = 50, OFF = 100 }

enum Domain { SYSTEM, QUEST, ARC, WORLD, ARMY, COMBAT, TEST }

static func level_name(level: int) -> String:
    match level:
        Level.DEBUG: return "DEBUG"
        Level.INFO: return "INFO"
        Level.WARNING: return "WARNING"
        Level.ERROR: return "ERROR"
        Level.CRITICAL: return "CRITICAL"
        Level.OFF: return "OFF"
        _: return str(level)

static func level_from(value) -> int:
    if typeof(value) == TYPE_INT:
        return int(value)
    if typeof(value) == TYPE_STRING:
        var s := String(value).strip_edges().to_upper()
        match s:
            "DEBUG": return Level.DEBUG
            "INFO": return Level.INFO
            "WARN", "WARNING": return Level.WARNING
            "ERROR": return Level.ERROR
            "CRIT", "CRITICAL": return Level.CRITICAL
            "OFF": return Level.OFF
    return Level.INFO

static func domain_name(domain: int) -> String:
    return Domain.keys()[domain] if domain >= 0 and domain < Domain.size() else str(domain)

static func domain_from(value) -> int:
    if typeof(value) == TYPE_INT:
        return int(value)
    if typeof(value) == TYPE_STRING:
        var s := String(value).strip_edges().to_upper()
        var idx := Domain.keys().find(s)
        return idx if idx != -1 else -1
    return -1

static func level_color(level: int) -> String:
    match level:
        Level.DEBUG: return "#9aa0a6"
        Level.INFO: return "#34a853"
        Level.WARNING: return "#fbbc05"
        Level.ERROR: return "#ea4335"
        Level.CRITICAL: return "#ff1744"
        _: return "#ffffff"
