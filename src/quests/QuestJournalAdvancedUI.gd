# res://src/ui/quests/QuestJournalAdvancedUI.gd
extends Control

## Interface avancée pour journal de quêtes
## PALIER 3 : Affichage objectifs multiples, branches, filtres

# ========================================
# NODES
# ========================================

@onready var tab_container := %TabContainer  ## Onglets (Actives, Complétées, Échouées)
@onready var active_quests_list := %ActiveQuestsList
@onready var completed_quests_list := %CompletedQuestsList
@onready var failed_quests_list := %FailedQuestsList

@onready var quest_detail_panel := %QuestDetailPanel
@onready var quest_title_label := %QuestTitleLabel
@onready var quest_description_label := %QuestDescriptionLabel
@onready var objectives_container := %ObjectivesContainer
@onready var branch_panel := %BranchPanel
@onready var branch_choices_container := %BranchChoicesContainer

@onready var filter_panel := %FilterPanel
@onready var filter_tier := %FilterTier
@onready var filter_category := %FilterCategory
@onready var sort_by := %SortBy

@onready var close_button := %CloseButton

# ========================================
# PROPRIÉTÉS
# ========================================

var selected_quest: QuestInstanceAdvanced = null
var is_visible_state: bool = false

# ========================================
# LIFECYCLE
# ========================================

func _ready() -> void:
    print("🔵 _ready() démarré")
    
    if tab_container == null:
        print("❌ ERREUR: TabContainer manquant !")
        return
    if close_button == null:
        print("❌ ERREUR: CloseButton manquant !")
        return
    
    print("✅ Tous les nodes OK")
    process_mode = Node.PROCESS_MODE_ALWAYS
    set_process_unhandled_input(true)
    hide()
    _connect_signals()
    _setup_filters()

func _connect_signals() -> void:
    """Connecte les signaux"""
    close_button.pressed.connect(hide)
    
    # Signaux QuestManager
    if QuestManager:
        QuestManager.quest_started.connect(_on_quest_changed)
        QuestManager.quest_completed.connect(_on_quest_changed)
        QuestManager.quest_failed.connect(_on_quest_changed)
        QuestManager.quest_progress_updated.connect(_on_quest_progress_updated)
    
    # Filtres
    filter_tier.item_selected.connect(_on_filter_changed)
    filter_category.item_selected.connect(_on_filter_changed)
    sort_by.item_selected.connect(_on_filter_changed)

func _setup_filters() -> void:
    """Configure les filtres"""
    # Tiers
    filter_tier.add_item("Tous les tiers", -1)
    for tier in range(1, 6):
        filter_tier.add_item("Tier %d" % tier, tier)
    
    # Catégories
    filter_category.add_item("Toutes catégories", -1)
    filter_category.add_item("POI Local", QuestTypes.QuestCategory.LOCAL_POI)
    filter_category.add_item("Exploration", QuestTypes.QuestCategory.EXPLORATION)
    filter_category.add_item("Combat", QuestTypes.QuestCategory.COMBAT)
    filter_category.add_item("Survie", QuestTypes.QuestCategory.SURVIVAL)
    filter_category.add_item("Diplomatique", QuestTypes.QuestCategory.DIPLOMATIC)
    filter_category.add_item("Livraison", QuestTypes.QuestCategory.DELIVERY)
    
    # Tri
    sort_by.add_item("Par Tier", 0)
    sort_by.add_item("Par Progression", 1)
    sort_by.add_item("Par Expiration", 2)

# ========================================
# AFFICHAGE
# ========================================

func toggle() -> void:
    print("🟡 toggle() appelé")  # ✅ AJOUTE
    print("🟡 visible AVANT:", visible)  # ✅ AJOUTE
    
    is_visible_state = not is_visible_state
    visible = is_visible_state
    
    print("🟡 visible APRÈS:", visible)  # ✅ AJOUTE
    
    if visible:
        refresh()

func refresh() -> void:
    """Rafraîchit l'affichage"""
    _refresh_quest_lists()
    
    if selected_quest:
        _display_quest_details(selected_quest)

func _refresh_quest_lists() -> void:
    """Rafraîchit les listes de quêtes"""
    _clear_list(active_quests_list)
    _clear_list(completed_quests_list)
    _clear_list(failed_quests_list)
    
    # Récupérer les quêtes
    var active := _get_filtered_quests(QuestManager.get_active_quests())
    var completed := QuestManager.completed_quests
    var failed := QuestManager.failed_quests
    
    # Trier
    active = _sort_quests(active)
    
    # Afficher
    for quest in active:
        if quest is QuestInstanceAdvanced:
            _add_quest_to_list(active_quests_list, quest)
    
    for quest in completed:
        if quest is QuestInstanceAdvanced:
            _add_quest_to_list(completed_quests_list, quest)
    
    for quest in failed:
        if quest is QuestInstanceAdvanced:
            _add_quest_to_list(failed_quests_list, quest)

func _get_filtered_quests(quests: Array) -> Array:
    """Filtre les quêtes selon les filtres actifs"""
    var filtered := []
    
    var tier_filter: int = filter_tier.get_selected_id()
    var category_filter: int = filter_category.get_selected_id()
    
    for quest in quests:
        if not quest is QuestInstanceAdvanced:
            continue
        
        # Filtre tier
        if tier_filter != -1 and quest.template.tier != tier_filter:
            continue
        
        # Filtre catégorie
        if category_filter != -1 and quest.template.category != category_filter:
            continue
        
        filtered.append(quest)
    
    return filtered

func _sort_quests(quests: Array) -> Array:
    """Trie les quêtes selon le critère sélectionné"""
    var sort_mode: int = sort_by.get_selected_id()
    
    match sort_mode:
        0:  # Par Tier
            quests.sort_custom(func(a, b): return a.template.tier < b.template.tier)
        1:  # Par Progression
            quests.sort_custom(func(a, b): return a.get_completion_ratio() > b.get_completion_ratio())
        2:  # Par Expiration
            quests.sort_custom(func(a, b): return a.expires_on_day < b.expires_on_day)
    
    return quests

func _clear_list(list: VBoxContainer) -> void:
    """Vide une liste"""
    for child in list.get_children():
        child.queue_free()

func _add_quest_to_list(list: VBoxContainer, quest: QuestInstanceAdvanced) -> void:
    """Ajoute une quête à une liste"""
    var button := Button.new()
    button.text = quest.template.title
    button.pressed.connect(_on_quest_selected.bind(quest))
    
    # Couleur selon tier
    var tier_color := QuestTypes.get_tier_color(quest.template.tier)
    button.modulate = tier_color
    
    list.add_child(button)

# ========================================
# DÉTAILS QUÊTE
# ========================================

func _display_quest_details(quest: QuestInstanceAdvanced) -> void:
    """Affiche les détails d'une quête"""
    selected_quest = quest
    quest_detail_panel.show()
    
    # Titre
    quest_title_label.text = quest.template.title
    quest_title_label.modulate = QuestTypes.get_tier_color(quest.template.tier)
    
    # Description
    quest_description_label.text = quest.template.description
    
    # Objectifs
    _display_objectives(quest)
    
    # Branches
    _display_branch(quest)

func _display_objectives(quest: QuestInstanceAdvanced) -> void:
    """Affiche les objectifs d'une quête"""
    # Vider
    for child in objectives_container.get_children():
        child.queue_free()
    
    var objectives := quest.get_all_objectives()
    
    for obj in objectives:
        var obj_panel := _create_objective_panel(obj)
        objectives_container.add_child(obj_panel)

func _create_objective_panel(obj: QuestObjective) -> PanelContainer:
    """Crée un panneau pour un objectif"""
    var panel := PanelContainer.new()
    var vbox := VBoxContainer.new()
    panel.add_child(vbox)
    
    # Titre
    var title_label := Label.new()
    title_label.text = obj.get_readable_description()
    
    # Couleur selon statut
    match obj.status:
        QuestObjective.ObjectiveStatus.LOCKED:
            title_label.modulate = Color.GRAY
        QuestObjective.ObjectiveStatus.ACTIVE:
            title_label.modulate = Color.WHITE
        QuestObjective.ObjectiveStatus.COMPLETED:
            title_label.modulate = Color.GREEN
        QuestObjective.ObjectiveStatus.FAILED:
            title_label.modulate = Color.RED
    
    vbox.add_child(title_label)
    
    # Barre de progression (si actif)
    if obj.is_active():
        var progress_bar := ProgressBar.new()
        progress_bar.max_value = obj.count
        progress_bar.value = obj.current_progress
        vbox.add_child(progress_bar)
        
        var progress_label := Label.new()
        progress_label.text = "%d / %d" % [obj.current_progress, obj.count]
        progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        vbox.add_child(progress_label)
    
    return panel

func _display_branch(quest: QuestInstanceAdvanced) -> void:
    """Affiche la branche active si présente"""
    var branch := quest.get_current_branch()
    
    if not branch or not branch.is_triggered or branch.chosen_option >= 0:
        branch_panel.hide()
        return
    
    branch_panel.show()
    
    # Vider choix
    for child in branch_choices_container.get_children():
        child.queue_free()
    
    # Titre branche
    var branch_title := Label.new()
    branch_title.text = branch.title
    branch_choices_container.add_child(branch_title)
    
    # Description
    var branch_desc := Label.new()
    branch_desc.text = branch.description
    branch_choices_container.add_child(branch_desc)
    
    # Choix
    var choices := branch.get_available_choices()
    for i in range(choices.size()):
        var choice: QuestBranch.BranchChoice = choices[i]
        var choice_button := Button.new()
        choice_button.text = choice.title
        choice_button.pressed.connect(_on_branch_choice_selected.bind(quest, branch.id, i))
        branch_choices_container.add_child(choice_button)

# ========================================
# CALLBACKS
# ========================================

func _on_quest_selected(quest: QuestInstanceAdvanced) -> void:
    """Quand une quête est sélectionnée"""
    _display_quest_details(quest)

func _on_branch_choice_selected(quest: QuestInstanceAdvanced, branch_id: String, choice_index: int) -> void:
    """Quand un choix de branche est fait"""
    quest.make_branch_choice(branch_id, choice_index)
    refresh()

func _on_filter_changed(_index: int) -> void:
    """Quand les filtres changent"""
    refresh()

func _on_quest_changed(_quest_id: String) -> void:
    """Quand une quête change"""
    refresh()

func _on_quest_progress_updated(_quest_id: String, _progress: int) -> void:
    """Quand la progression change"""
    if selected_quest:
        _display_objectives(selected_quest)

# ========================================
# INPUT
# ========================================
"""
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("toggle_journal"):
        print("🟢 Input J capturé !")  # ✅ AJOUTE
        print("🟢 visible AVANT:", visible)  # ✅ AJOUTE
        toggle()
        get_viewport().set_input_as_handled()
        print("🟢 visible APRÈS:", visible)  # ✅ AJOUTE
        """
# ✅ APRÈS (ajoute juste 3 prints)
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("toggle_journal_advanced"):
        print("🟢 Input J capturé !")  # ✅ AJOUTE
        print("🟢 visible AVANT:", visible)  # ✅ AJOUTE
        toggle()
        get_viewport().set_input_as_handled()
        print("🟢 visible APRÈS:", visible)
