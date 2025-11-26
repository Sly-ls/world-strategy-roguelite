extends VBoxContainer
class_name ArmyUIController

@export var army_data: ArmyData

var slots: Array = []

# Variables pour le drag & drop
var dragged_unit: UnitData = null
var dragged_from_index: int = -1
var drag_preview: Control = null
var is_dragging: bool = false

# Pour les indicateurs visuels
var original_modulates: Dictionary = {}


func _ready() -> void:
    # 1) S'il existe déjà une armée globale, on l'utilise
    if WorldState.player_army != null:
        army_data = WorldState.player_army
    else:
        # 2) Sinon, on crée l'armée de départ UNE SEULE FOIS
        if army_data == null:
            _create_test_army()
        WorldState.player_army = army_data

    # 3) On initialise l'UI avec l'armée courante
    var grid := $GridContainer as GridContainer
    slots = grid.get_children()
    
    # Setup drag & drop sur chaque slot
    for slot in slots:
        if slot is TextureRect:
            _setup_slot_for_drag(slot)
    
    _refresh_slots()


func _create_test_army() -> void:
    army_data = ArmyFactory.create_army("player_start_army", true)


func _process(delta: float) -> void:
    # Ne rafraîchir QUE si on ne drag pas (sinon on écrase les couleurs vertes)
    if not is_dragging:
        _refresh_slots()
    
    # Mettre à jour la position de la preview si elle existe
    if drag_preview != null and is_dragging:
        drag_preview.global_position = get_global_mouse_position() - drag_preview.size / 2


func _input(event: InputEvent) -> void:
    # Gérer le relâchement de la souris globalement
    if event is InputEventMouseButton:
        var mb = event as InputEventMouseButton
        if mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
            if is_dragging and dragged_unit != null:
                # Trouver sur quel slot on relâche
                var target_slot_index = _get_slot_under_mouse()
                if target_slot_index != -1:
                    _try_drop(target_slot_index)
                else:
                    # Relâché en dehors des slots, annuler
                    _end_drag()


func _setup_slot_for_drag(slot: TextureRect) -> void:
    # Permettre de recevoir des événements souris
    slot.mouse_filter = Control.MOUSE_FILTER_STOP
    
    # Connecter les signaux
    slot.gui_input.connect(_on_slot_gui_input.bind(slot))


func _on_slot_gui_input(event: InputEvent, slot: TextureRect) -> void:
    var slot_index := slots.find(slot)
    if slot_index == -1:
        return

    # Index UI -> (col, row) dans l'armée
    var coords: Vector2 = army_data.rc_from_index(slot_index)
    var combat_col := int(coords.x)
    var combat_row := int(coords.y)

    # Clic gauche pressé : commencer le drag
    if event is InputEventMouseButton:
        var mb := event as InputEventMouseButton

        if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
            # Utiliser get_unit_at_position avec l'ordre (row, col)
            var unit := army_data.get_unit_at_position(combat_row, combat_col)
            if unit != null and unit.hp > 0:
                _start_drag(unit, slot_index, slot)




func _get_slot_under_mouse() -> int:
    """Trouve quel slot est sous la souris"""
    var mouse_pos = get_global_mouse_position()
    
    for i in range(slots.size()):
        var slot = slots[i]
        if slot is TextureRect:
            var slot_rect = Rect2(slot.global_position, slot.size)
            if slot_rect.has_point(mouse_pos):
                return i
    
    return -1


func _start_drag(unit: UnitData, from_index: int, slot: TextureRect) -> void:
    dragged_unit = unit
    dragged_from_index = from_index
    is_dragging = true
    
    # Sauvegarder les modulates originaux
    original_modulates.clear()
    for i in range(slots.size()):
        if slots[i] is TextureRect:
            original_modulates[i] = slots[i].modulate
    
    # Créer une preview visuelle
    drag_preview = TextureRect.new()
    drag_preview.texture = unit.icon if unit.icon != null else null
    drag_preview.custom_minimum_size = Vector2(48, 48)
    drag_preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
    drag_preview.modulate = Color(1, 1, 1, 0.8)
    drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(drag_preview)
    
    # Mettre en évidence les cases valides
    _highlight_valid_slots()
    
    print("Début du drag : %s depuis l'index %d" % [unit.name, from_index])


func _highlight_valid_slots() -> void:
    # Met en évidence les cases où on peut déposer l'unité :
    # - toutes les cases valides deviennent blanches
    # - celles déjà occupées sont teintées de vert (échange possible)
    if dragged_from_index < 0:
        return

    var from_coords: Vector2 = army_data.rc_from_index(dragged_from_index)
    var from_col := int(from_coords.x)
    var from_row := int(from_coords.y)

    for i in range(slots.size()):
        var slot :TextureRect = slots[i]
        if not (slot is TextureRect):
            continue

        var coords: Vector2 = army_data.rc_from_index(i)
        var to_col := int(coords.x)
        var to_row := int(coords.y)

        var is_valid := _is_valid_placement(to_col, to_row, from_col, from_row)

        if is_valid:
            # ATTENTION : get_unit_at_position(row, col)
            var unit_at_slot: UnitData = army_data.get_unit_at_position(to_row, to_col)

            if unit_at_slot != null and unit_at_slot.hp > 0:
                # Case valide MAIS déjà occupée → échange possible (vert)
                slot.modulate = Color(0.3, 1.0, 0.3, 1.0)
            else:
                # Case valide ET vide → blanche
                slot.texture = load("res://icon.svg")
                slot.modulate = Color(1, 1, 1, 1)
        else:
            # Case non valide : on laisse en “gris”
            if i == dragged_from_index:
                # La case d'origine reste visible, mais un peu fade
                slot.modulate = Color(1, 1, 1, 0.3)
            else:
                slot.modulate = Color(1, 1, 1, 0.15)


func _try_drop(to_index: int) -> void:
    if dragged_unit == null:
        return

    print("Tentative de drop à l'index %d" % to_index)

    # Coordonnées de départ et d'arrivée (col, row)
    var from_coords = army_data.rc_from_index(dragged_from_index)
    var to_coords = army_data.rc_from_index(to_index)

    var from_col := int(from_coords.x)
    var from_row := int(from_coords.y)
    var to_col := int(to_coords.x)
    var to_row := int(to_coords.y)

    # Vérifier si le placement est valide
    if _is_valid_placement(to_col, to_row, from_col, from_row):
        # Effectuer l'échange (swap)
        var target_unit = army_data.get_unit_at_position(to_row, to_col)

        # Échanger les unités (row, col)
        army_data.set_unit_rc(to_row, to_col, dragged_unit)
        army_data.set_unit_rc(from_row, from_col, target_unit)

        if target_unit != null:
            print("✓ Échange réussi : %s ↔ %s" % [dragged_unit.name, target_unit.name])
        else:
            print("✓ Déplacement réussi : %s vers (col=%d, row=%d), idx=%d" % [dragged_unit.name, to_col, to_row, army_data.index_from_rc(to_row, to_col)])

        # Appliquer le compactage "Puissance 4" après chaque déplacement
        _compact_army_columns()
    else:
        print("✗ Placement invalide à (col=%d, row=%d)" % [to_col, to_row])

    # Nettoyer
    _end_drag()


                
func _compact_army_columns() -> void:
    """
    Applique le compactage "Puissance 4" sur toutes les colonnes.
    Les unités descendent pour combler les trous.
    """
    if army_data != null:
        army_data.compact_columns()
        print("→ Compactage des colonnes effectué")


func _end_drag() -> void:
    if drag_preview != null:
        drag_preview.queue_free()
        drag_preview = null
    
    dragged_unit = null
    dragged_from_index = -1
    is_dragging = false
    
    # Restaurer les modulates originaux
    original_modulates.clear()
    
    # IMPORTANT : Rafraîchir immédiatement après le drop
    # Attendre 1 frame pour que compact_columns() soit bien terminé
    await get_tree().process_frame
    _refresh_slots()


func _is_valid_placement(to_col: int, to_row: int, from_col: int, from_row: int) -> bool:
    """
    Règles de placement :
    1. La ligne 0 (front) doit toujours être remplie en priorité
    2. On remplit Col 0 → Col 1 → Col 2 de la ligne 0
    3. Une fois ligne 0 pleine, on peut placer sur les autres lignes
    4. Maximum 5 lignes (0-4)
    """
    
    # Vérifier les limites
    if to_row < 0 or to_row >= ArmyData.ARMY_ROWS:
        return false
    if to_col < 0 or to_col >= ArmyData.ARMY_COLS:
        return false
    
    # Créer une copie temporaire pour simuler le déplacement + compactage
    var temp_army = _simulate_move_with_compact(from_col, from_row, to_col, to_row)
    
    # Vérifier que la ligne 0 est correctement remplie APRÈS compactage
    return _check_front_line_rule(temp_army)


func _simulate_move(from_col: int, from_row: int, to_col: int, to_row: int) -> Array:
    """Simule un déplacement et retourne une copie de l'état de l'armée"""
    var temp = []
    temp.resize(ArmyData.ARMY_SIZE)
    
    # Copier l'état actuel
    for row in range(ArmyData.ARMY_ROWS):
        for col in range(ArmyData.ARMY_COLS):
            var idx = army_data.index_from_rc(row, col)
            var unit = army_data.get_unit_at_position(row, col)
            temp[idx] = unit
    
    # Simuler le swap
    var from_idx = army_data.index_from_rc(from_row, from_col)
    var to_idx = army_data.index_from_rc(to_row, to_col)
    
    var temp_unit = temp[to_idx]
    temp[to_idx] = temp[from_idx]
    temp[from_idx] = temp_unit
    
    return temp


func _simulate_move_with_compact(from_col: int, from_row: int, to_col: int, to_row: int) -> Array:
    """Simule un déplacement + compactage et retourne l'état final"""
    var temp = _simulate_move(from_col, from_row, to_col, to_row)
    
    # Appliquer le compactage sur la copie
    temp = _compact_array(temp)
    
    return temp


func _compact_array(units_array: Array) -> Array:
    """
    Applique la même logique que ArmyData.compact_columns()
    mais sur un Array temporaire (simulation).
    """
    var compacted := []
    compacted.resize(ArmyData.ARMY_SIZE)

    # Init à null
    for i in range(compacted.size()):
        compacted[i] = null

    # Pour chaque colonne
    for col in range(ArmyData.ARMY_COLS):
        var stack: Array = []

        # On balaie les lignes de haut (0) vers bas (ARMY_ROWS-1)
        for row in range(ArmyData.ARMY_ROWS):
            var idx := army_data.index_from_rc(row, col)
            var unit: UnitData = units_array[idx]
            if unit != null and unit.hp > 0:
                stack.append(unit)

        # On repose les unités depuis row 0 vers le bas
        var row_index := 0
        for unit in stack:
            var idx := army_data.index_from_rc(row_index, col)
            compacted[idx] = unit
            row_index += 1

        # Le reste de la colonne est vide
        while row_index < ArmyData.ARMY_ROWS:
            var idx := army_data.index_from_rc(row_index, col)
            compacted[idx] = null
            row_index += 1

    return compacted


func _check_front_line_rule(temp_army: Array) -> bool:
    """
    Vérifie que la ligne 0 (front) respecte les règles APRÈS compactage
    """
    
    # Compter les unités totales
    var total_units = 0
    for unit in temp_army:
        if unit != null and unit.hp > 0:
            total_units += 1
    
    if total_units == 0:
        return true
    
    # Vérifier la ligne 0 (front)
    var front_line_units = []
    for col in range(ArmyData.ARMY_COLS):
        var idx = col
        var unit = temp_army[idx]
        front_line_units.append(unit)
    
    # Compter les unités dans la ligne 0
    var front_count = 0
    for unit in front_line_units:
        if unit != null and unit.hp > 0:
            front_count += 1
    
    # Si on a moins de 3 unités au total, elles doivent toutes être en ligne 0
    if total_units <= ArmyData.ARMY_COLS:
        if front_count != total_units:
            return false
        
        if not _check_no_gaps_in_front(front_line_units):
            return false
    else:
        if front_count < ArmyData.ARMY_COLS:
            return false
    
    return true


func _check_no_gaps_in_front(front_line: Array) -> bool:
    """Vérifie qu'il n'y a pas de trous dans la ligne de front"""
    var found_empty = false
    
    for i in range(front_line.size()):
        var unit = front_line[i]
        if unit == null or unit.hp <= 0:
            found_empty = true
        else:
            if found_empty:
                return false
    
    return true

func _refresh_slots() -> void:
    if army_data == null:
        for slot in slots:
            if slot is TextureRect:
                slot.visible = true
                slot.texture = null
                slot.modulate = Color(1, 1, 1, 0)
                slot.tooltip_text = ""
        return

    for i in range(slots.size()):
        var slot := slots[i] as TextureRect
        if slot == null:
            continue

        # On force le slot à être visible, même vide
        slot.visible = true

        # Index UI -> (col, row) dans l'armée
        var coords: Vector2 = army_data.rc_from_index(i) # x=col, y=row
        var col := int(coords.x)
        var row := int(coords.y)

        # --- Soulignement rouge de la première ligne (front) ---
        var underline: ColorRect = slot.get_node_or_null("FrontLineUnderline")
        if row == 0:
            if underline == null:
                underline = ColorRect.new()
                underline.name = "FrontLineUnderline"
                underline.color = Color(1, 0, 0, 1)
                underline.anchor_left = 0.0
                underline.anchor_right = 1.0
                underline.anchor_top = 1.0
                underline.anchor_bottom = 1.0
                underline.position = Vector2(0, -2)
                underline.custom_minimum_size = Vector2(0, 2)
                slot.add_child(underline)
            underline.visible = true
        else:
            if underline != null:
                underline.visible = false
        # --------------------------------------------------------

        # ATTENTION : get_unit_at_position(row, col)
        var unit: UnitData = army_data.get_unit_at_index(i)

        if unit != null and unit.hp > 0:
            # Affichage d'une unité
            slot.texture = unit.icon if unit.icon != null else load("res://icon.svg")
            slot.modulate = Color(1, 1, 1, 1)
            slot.tooltip_text = "%s\nPV : %d / %d\nMoral : %d / %d" % [
                unit.name,
                unit.hp, unit.max_hp,
                unit.morale, unit.max_morale
            ]
        else:
            # Slot vide
            slot.texture = null
            slot.tooltip_text = "[Case vide]\n\nDéposez une unité ici"

            if row == 0:
                # Emplacement vide sur la ligne de front → très visible
                slot.modulate = Color(1, 0.9, 0.9, 1.0)
            else:
                # Case vide normale
                slot.modulate = Color(1, 1, 1, 0.2)





func get_army_data() -> ArmyData:
    return army_data
