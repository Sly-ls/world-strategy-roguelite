# res://src/quests/generation/QuestPool.gd
extends Node

## Pool dynamique de quêtes disponibles
## PALIER 2 : Refresh périodique, conditions d'apparition

# ========================================
# CONFIGURATION
# ========================================
const MAX_OFFERS_GLOBAL := 20
const MAX_OFFERS_PER_GIVER := 6
const MAX_OFFERS_PER_SIGNATURE := 1
@export var pool_size: int = 5  ## Nombre de quêtes dans le pool
@export var refresh_days: int = 3  ## Refresh tous les N jours
@export var auto_start_quests: bool = false  ## Démarrer automatiquement

# ========================================
# PROPRIÉTÉS
# ========================================
var offers: Array[QuestInstance] = []
var _count_by_giver: Dictionary = {}      # giver_id -> int
var _count_by_signature: Dictionary = {}  # signature -> int

var available_quests: Array[QuestInstance] = []  ## Quêtes disponibles
var last_refresh_day: int = 0

# ========================================
# SIGNAUX
# ========================================

signal pool_refreshed(new_quests: Array[QuestInstance])
signal quest_available(quest: QuestInstance)
signal quest_expired(quest: QuestInstance)

# ========================================
# LIFECYCLE
# ========================================

func _ready() -> void:
    _initial_generation()
    print("✓ QuestPool initialisé (%d quêtes)" % available_quests.size())

func _initial_generation() -> void:
    """Génère le pool initial"""
    refresh_pool()
    last_refresh_day = WorldState.current_day

# ========================================
# GESTION DU POOL
# ========================================
func try_add_offer(o: QuestInstance) -> bool:
    if o == null:
        return false

    # 1) Validité
    var day := WorldState.current_day if WorldState != null else 0
    if not o.is_offer_valid(day):
        if DebugConstants.ARC_LOG: print("[OFFER] reject invalid: %s" % o.template.title)
        return false

    # 2) Cap global
    if offers.size() >= MAX_OFFERS_GLOBAL:
        if DebugConstants.ARC_LOG: print("[OFFER] reject global cap: %d/%d" % [offers.size(), MAX_OFFERS_GLOBAL])
        return false

    # 3) Cap par signature
    var sig := o.get_offer_signature()
    var sig_count := int(_count_by_signature.get(sig, 0))
    if sig_count >= MAX_OFFERS_PER_SIGNATURE:
        if DebugConstants.ARC_LOG: print("[OFFER] reject signature cap: sig=%s count=%d/%d" % [sig, sig_count, MAX_OFFERS_PER_SIGNATURE])
        return false

    # 4) Cap par giver
    var giver := String(o.context.get("giver_faction_id", ""))
    if giver != "":
        var giver_count := int(_count_by_giver.get(giver, 0))
        if giver_count >= MAX_OFFERS_PER_GIVER:
            if DebugConstants.ARC_LOG: print("[OFFER] reject giver cap: giver=%s count=%d/%d" % [giver, giver_count, MAX_OFFERS_PER_GIVER])
            return false

    # OK -> insert + index update
    offers.append(o)
    _count_by_signature[sig] = sig_count + 1
    if giver != "":
        _count_by_giver[giver] = int(_count_by_giver.get(giver, 0)) + 1

    return true

func _rebuild_indexes() -> void:
    _count_by_giver.clear()
    _count_by_signature.clear()

    for o in offers:
        if o == null:
            continue
        var giver := String(o.context.get("giver_faction_id", ""))
        var sig := o.get_offer_signature()

        _count_by_signature[sig] = int(_count_by_signature.get(sig, 0)) + 1
        if giver != "":
            _count_by_giver[giver] = int(_count_by_giver.get(giver, 0)) + 1

func refresh_pool() -> void:
    """Régénère complètement le pool"""
    print("\n🔄 Régénération du pool de quêtes (jour %d)" % WorldState.current_day)
    
    # Retirer les quêtes expirées/complétées
    _cleanup_expired_quests()
    
    # Générer nouvelles quêtes
    var needed := pool_size - available_quests.size()
    
    for i in range(needed):
        var quest := QuestGenerator.generate_random_quest()
        if quest and _check_quest_conditions(quest):
            available_quests.append(quest)
            quest_available.emit(quest)
            
            # Auto-start si activé
            if auto_start_quests:
                QuestManager.start_quest(quest.template.id, quest.context)
    
    last_refresh_day = WorldState.current_day
    pool_refreshed.emit(available_quests)
    
    print("✓ Pool regénéré : %d quêtes disponibles" % available_quests.size())

func refresh_if_needed() -> void:
    """Refresh automatique si intervalle écoulé"""
    var current_day := WorldState.current_day
    
    if current_day - last_refresh_day >= refresh_days:
        refresh_pool()
func cleanup_offers() -> void:
    var day := WorldState.current_day if WorldState != null else 0

    var kept: Array[QuestInstance] = []
    for o in offers:
        if o == null:
            continue
        if o.is_offer_valid(day):
            kept.append(o)

    offers = kept
    _rebuild_indexes()
func remove_offer_by_runtime_id(runtime_id: String) -> void:
    var kept: Array[QuestInstance] = []
    for o in offers:
        if o != null and o.runtime_id != runtime_id:
            kept.append(o)
    offers = kept
    _rebuild_indexes()

func _cleanup_expired_quests() -> void:
    """Retire les quêtes expirées du pool"""
    var to_remove: Array[QuestInstance] = []
    
    for quest in available_quests:
        if quest.check_expiration(WorldState.current_day):
            to_remove.append(quest)
            quest_expired.emit(quest)
    
    for quest in to_remove:
        available_quests.erase(quest)

# ========================================
# CONDITIONS D'APPARITION
# ========================================

func _check_quest_conditions(quest: QuestInstance) -> bool:
    """Vérifie si une quête peut apparaître"""
    
    # Conditions de base du template
    if not quest.template.can_appear():
        return false
    
    # Vérifier qu'elle n'est pas déjà active
    if QuestManager.has_active_quest(quest.template_id):
        return false
    
    # Vérifier qu'on n'a pas trop de quêtes du même tier
    var same_tier_count := _count_quests_by_tier(quest.template.tier)
    if same_tier_count >= 3:  # Max 3 quêtes du même tier
        return false
    
    return true

func _count_quests_by_tier(tier: QuestTypes.QuestTier) -> int:
    """Compte les quêtes actives d'un tier donné"""
    var count := 0
    for quest in QuestManager.get_active_quests():
        if quest.template.tier == tier:
            count += 1
    return count

# ========================================
# ACCÈS AU POOL
# ========================================

func get_available_quests() -> Array[QuestInstance]:
    """Retourne toutes les quêtes disponibles"""
    return available_quests.duplicate()

func get_available_quests_by_tier(tier: QuestTypes.QuestTier) -> Array[QuestInstance]:
    """Retourne les quêtes disponibles d'un tier donné"""
    var result: Array[QuestInstance] = []
    for quest in available_quests:
        if quest.template.tier == tier:
            result.append(quest)
    return result

func get_available_quests_by_category(category: QuestTypes.QuestCategory) -> Array[QuestInstance]:
    """Retourne les quêtes disponibles d'une catégorie donnée"""
    var result: Array[QuestInstance] = []
    for quest in available_quests:
        if quest.template.category == category:
            result.append(quest)
    return result

func pick_random_quest() -> QuestInstance:
    """Choisit une quête aléatoire du pool"""
    if available_quests.is_empty():
        return null
    
    var index := randi() % available_quests.size()
    return available_quests[index]

func pick_quest_by_tier(tier: QuestTypes.QuestTier) -> QuestInstance:
    """Choisit une quête aléatoire d'un tier donné"""
    var tier_quests := get_available_quests_by_tier(tier)
    if tier_quests.is_empty():
        return null
    
    var index := randi() % tier_quests.size()
    return tier_quests[index]

# ========================================
# ACTIVATION
# ========================================

func activate_quest(quest: QuestInstance) -> bool:
    """Active une quête du pool (la démarre)"""
    if not available_quests.has(quest):
        return false
    
    # Démarrer la quête
    var started := QuestManager.start_quest(quest.template.id, quest.context)
    
    if started:
        # Retirer du pool
        available_quests.erase(quest)
        return true
    
    return false

func activate_random_quest() -> QuestInstance:
    """Active une quête aléatoire du pool"""
    var quest := pick_random_quest()
    if quest and activate_quest(quest):
        return quest
    return null

# ========================================
# AJOUT MANUEL
# ========================================

func add_quest_to_pool(quest: QuestInstance) -> void:
    """Ajoute manuellement une quête au pool"""
    if not available_quests.has(quest):
        available_quests.append(quest)
        quest_available.emit(quest)

func remove_quest_from_pool(quest: QuestInstance) -> void:
    """Retire manuellement une quête du pool"""
    available_quests.erase(quest)

# ========================================
# QUERIES
# ========================================

func get_pool_size() -> int:
    """Retourne la taille actuelle du pool"""
    return available_quests.size()

func is_pool_full() -> bool:
    """Vérifie si le pool est plein"""
    return available_quests.size() >= pool_size

func is_pool_empty() -> bool:
    """Vérifie si le pool est vide"""
    return available_quests.is_empty()

# ========================================
# DEBUG
# ========================================

func print_pool() -> void:
    """Affiche le contenu du pool (debug)"""
    print("\n=== QUEST POOL ===")
    print("Taille : %d / %d" % [available_quests.size(), pool_size])
    print("Dernier refresh : Jour %d" % last_refresh_day)
    print("Prochain refresh : Jour %d" % (last_refresh_day + refresh_days))
    print("\nQuêtes disponibles :")
    
    for quest in available_quests:
        print("  - %s (Tier %d, %s)" % [
            quest.template.title,
            quest.template.tier,
            QuestTypes.get_category_name(quest.template.category)
        ])
    
    print("==================\n")

# ========================================
# GETTER
# ========================================

func get_offers() -> Array[QuestInstance]:
    return offers

# ========================================
# FOR TEST PURPOSE
# ========================================
func _test_snapshot_offers() -> Array:
    return offers.duplicate(true)

func _test_clear_offers() -> void:
    offers.clear()

func _test_restore_offers(prev: Array) -> void:
    offers.clear()
    for o in prev:
        offers.append(o)
