class_name InventoryGridWidget
extends Control
## Reusable inventory-grid view. It visualises inventory state and emits touch
## intent only; parents decide which public RetrieverInventory operation to call.

signal item_pressed(uid: int)
signal cell_pressed(grid_kind: StringName, anchor: Vector2i)
signal cell_touch_started(grid_kind: StringName, anchor: Vector2i)
signal cell_touch_released(grid_kind: StringName, anchor: Vector2i, inside: bool)

const CELL_SIZE := 96
const DESIGN_VIEWPORT := Vector2i(1280, 720)
const MIN_TOUCH_PIXELS := 64.0
const TOUCH_CANCEL_DISTANCE := 16.0
const MOUSE_POINTER_INDEX := -1

var inventory: RetrieverInventory
var grid_kind: StringName = RetrieverInventory.BACKPACK
var read_only := false
var cell_scale := 1.0
var selected_uid := 0
var preview_reasons: Dictionary = {}
var error_cells: Array[Vector2i] = []
var touch_preview_cells: Array[Vector2i] = []
var touch_preview_ok := false
var touch_preview_edge_direction := Vector2i.ZERO

var _grid: InventoryGrid
var _cells: Dictionary = {}
var _items: Dictionary = {}
var _pressed_cells: Dictionary = {}
var _touch_start_positions: Dictionary = {}
var _cancelled_touches: Dictionary = {}
var _pointer_cell_activations: Dictionary = {}
var _cell_size := CELL_SIZE


static func logical_cell_size_for_window(window_size: Vector2i) -> float:
	if window_size.x <= 0 or window_size.y <= 0:
		return CELL_SIZE
	var physical_scale := minf(
		float(window_size.x) / float(DESIGN_VIEWPORT.x),
		float(window_size.y) / float(DESIGN_VIEWPORT.y)
	)
	if physical_scale <= 0.0:
		return CELL_SIZE
	return maxf(CELL_SIZE, ceilf(MIN_TOUCH_PIXELS / physical_scale))


func current_cell_size() -> float:
	return _cell_size


func configure(p_inventory: RetrieverInventory, p_grid_kind: StringName, p_read_only: bool = false, p_cell_scale: float = 1.0) -> void:
	inventory = p_inventory
	grid_kind = p_grid_kind
	read_only = p_read_only
	cell_scale = p_cell_scale
	_cell_size = logical_cell_size_for_window(DisplayServer.window_get_size()) * cell_scale
	_grid = _grid_for_kind()
	_pressed_cells.clear()
	_touch_start_positions.clear()
	_cancelled_touches.clear()
	_pointer_cell_activations.clear()
	_render()


func show_selection(p_uid: int, p_preview_reasons: Dictionary = {}, p_error_cells: Array[Vector2i] = []) -> void:
	selected_uid = p_uid
	preview_reasons = p_preview_reasons
	error_cells = p_error_cells
	touch_preview_cells.clear()
	touch_preview_edge_direction = Vector2i.ZERO
	_render()


func show_touch_preview(item: ItemInstance, anchor: Vector2i, rotated: bool, result: InventoryResult) -> void:
	touch_preview_cells.clear()
	touch_preview_ok = result.ok
	touch_preview_edge_direction = Vector2i.ZERO
	if item != null and item.definition != null:
		var footprint := item.definition.size
		if rotated and footprint.x != footprint.y:
			footprint = Vector2i(footprint.y, footprint.x)
		for y in footprint.y:
			for x in footprint.x:
				var cell := anchor + Vector2i(x, y)
				if cell.x >= 0 and cell.y >= 0 and cell.x < _grid.size.x and cell.y < _grid.size.y:
					touch_preview_cells.append(cell)
				else:
					_record_touch_preview_edge(cell)
	error_cells = result.blocking_cells.duplicate()
	_render()


func press_item(uid: int) -> void:
	if not read_only:
		item_pressed.emit(uid)


func press_cell(anchor: Vector2i) -> void:
	if not read_only:
		cell_pressed.emit(grid_kind, anchor)


func is_pointer_cell_activation(anchor: Vector2i) -> bool:
	return _pointer_cell_activations.has(anchor)


func _grid_for_kind() -> InventoryGrid:
	if inventory == null:
		return null
	match grid_kind:
		RetrieverInventory.BACKPACK:
			return inventory.backpack
		RetrieverInventory.NOTARY_BOX:
			return inventory.notary_box
		RetrieverInventory.SLING_POUCH:
			return inventory.sling_pouch
	return null


func _render() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_cells.clear()
	_items.clear()
	if _grid == null:
		return
	var cell_size := _cell_size
	custom_minimum_size = Vector2(_grid.size.x * cell_size, _grid.size.y * cell_size)
	size = custom_minimum_size
	for y in _grid.size.y:
		for x in _grid.size.x:
			var anchor := Vector2i(x, y)
			var cell := Button.new()
			cell.name = "Cell_%d_%d" % [x, y]
			cell.position = Vector2(x * cell_size, y * cell_size)
			cell.size = Vector2(cell_size, cell_size)
			cell.focus_mode = Control.FOCUS_ALL
			cell.tooltip_text = ""
			var marker := _marker_for(anchor)
			cell.text = marker
			cell.add_theme_font_size_override("font_size", max(24, int(26 * cell_scale)))
			cell.pressed.connect(press_cell.bind(anchor))
			cell.gui_input.connect(_on_cell_gui_input.bind(anchor))
			add_child(cell)
			_cells[anchor] = cell
	for item: ItemInstance in _grid.all_items():
		_add_item(item, cell_size)
	_add_touch_preview_edge_indicator(cell_size)


func _record_touch_preview_edge(cell: Vector2i) -> void:
	if touch_preview_edge_direction != Vector2i.ZERO:
		return
	var direction := Vector2i.ZERO
	if cell.x < 0:
		direction.x = -1
	elif cell.x >= _grid.size.x:
		direction.x = 1
	if cell.y < 0:
		direction.y = -1
	elif cell.y >= _grid.size.y:
		direction.y = 1
	touch_preview_edge_direction = direction


func _add_touch_preview_edge_indicator(cell_size: float) -> void:
	if touch_preview_edge_direction == Vector2i.ZERO:
		return
	var indicator := Label.new()
	indicator.name = "TouchPreviewEdgeIndicator"
	indicator.text = _edge_indicator_text(touch_preview_edge_direction)
	indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	indicator.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	indicator.add_theme_font_size_override("font_size", max(24, int(24 * cell_scale)))
	var indicator_size := Vector2(24, 24)
	var grid_size := Vector2(_grid.size.x * cell_size, _grid.size.y * cell_size)
	indicator.position = Vector2(
		0.0 if touch_preview_edge_direction.x < 0 else grid_size.x - indicator_size.x if touch_preview_edge_direction.x > 0 else (grid_size.x - indicator_size.x) * 0.5,
		0.0 if touch_preview_edge_direction.y < 0 else grid_size.y - indicator_size.y if touch_preview_edge_direction.y > 0 else (grid_size.y - indicator_size.y) * 0.5
	)
	indicator.size = indicator_size
	add_child(indicator)


func _edge_indicator_text(direction: Vector2i) -> String:
	if direction == Vector2i(0, -1):
		return "↑"
	if direction == Vector2i(0, 1):
		return "↓"
	if direction == Vector2i(-1, 0):
		return "←"
	if direction == Vector2i(1, 0):
		return "→"
	if direction == Vector2i(-1, -1):
		return "↖"
	if direction == Vector2i(1, -1):
		return "↗"
	if direction == Vector2i(-1, 1):
		return "↙"
	return "↘"


func _marker_for(anchor: Vector2i) -> String:
	if error_cells.has(anchor):
		return "!"
	if touch_preview_cells.has(anchor):
		return "▣" if touch_preview_ok else "╳"
	if preview_reasons.has(anchor):
		var result: InventoryResult = preview_reasons[anchor]
		return "✓" if result.ok else "×"
	return ""


func _add_item(item: ItemInstance, cell_size: float) -> void:
	if item.definition == null:
		return
	var button := Button.new()
	button.name = "Item_%d" % item.uid
	button.position = Vector2(item.anchor.x * cell_size, item.anchor.y * cell_size)
	button.size = Vector2(item.effective_size().x * cell_size, item.effective_size().y * cell_size)
	button.focus_mode = Control.FOCUS_ALL
	button.text = _item_label(item)
	button.add_theme_font_size_override("font_size", max(24, int(24 * cell_scale)))
	if item.uid == selected_uid:
		button.text = "▣ " + button.text
		button.add_theme_color_override("font_color", UiTheme.STAMP_RED)
	if grid_kind == RetrieverInventory.NOTARY_BOX:
		button.text += "\n" + _seal_label(item.uid)
	button.pressed.connect(press_item.bind(item.uid))
	add_child(button)
	_items[item.uid] = button


func _item_label(item: ItemInstance) -> String:
	return item.definition.localized_display_name()


func _seal_label(uid: int) -> String:
	var label_key := "INVENTORY_SEAL_LABEL_" + str(inventory.seal_label(uid)).to_upper()
	return tr(label_key)


func _on_cell_gui_input(event: InputEvent, anchor: Vector2i) -> void:
	if read_only:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_begin_touch(event.index, anchor, event.position)
		else:
			_finish_touch(event.index, event.position, event.canceled)
	elif event is InputEventScreenDrag:
		_update_touch(event.index, event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_begin_touch(MOUSE_POINTER_INDEX, anchor, event.position)
		else:
			_finish_touch(MOUSE_POINTER_INDEX, event.position)
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		_update_touch(MOUSE_POINTER_INDEX, event.position)


func _input(event: InputEvent) -> void:
	if read_only:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			var anchor := _anchor_at_position(event.position)
			if anchor.x >= 0 and not _item_at_position(event.position):
				_begin_touch(event.index, anchor, event.position)
		else:
			_finish_touch(event.index, event.position, event.canceled)
	elif event is InputEventScreenDrag:
		_update_touch(event.index, event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var mouse_anchor := _anchor_at_position(event.position)
			if mouse_anchor.x >= 0 and not _item_at_position(event.position):
				_begin_touch(MOUSE_POINTER_INDEX, mouse_anchor, event.position)
		else:
			_finish_touch(MOUSE_POINTER_INDEX, event.position)
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		_update_touch(MOUSE_POINTER_INDEX, event.position)


func _begin_touch(pointer_index: int, anchor: Vector2i, position: Vector2) -> void:
	if _pressed_cells.has(pointer_index):
		return
	_cancelled_touches.erase(pointer_index)
	_pressed_cells[pointer_index] = anchor
	_touch_start_positions[pointer_index] = position
	_pointer_cell_activations[anchor] = true
	cell_touch_started.emit(grid_kind, anchor)


func _update_touch(pointer_index: int, position: Vector2) -> void:
	if not _pressed_cells.has(pointer_index) or _cancelled_touches.has(pointer_index):
		return
	var start := _touch_start_positions.get(pointer_index, position) as Vector2
	if start.distance_to(position) < TOUCH_CANCEL_DISTANCE:
		return
	var anchor := _pressed_cells.get(pointer_index, Vector2i(-1, -1)) as Vector2i
	_pressed_cells.erase(pointer_index)
	_touch_start_positions.erase(pointer_index)
	_cancelled_touches[pointer_index] = true
	_pointer_cell_activations.erase(anchor)
	if anchor.x >= 0:
		cell_touch_released.emit(grid_kind, anchor, false)


func _finish_touch(pointer_index: int, position: Vector2, cancelled: bool = false) -> void:
	if _cancelled_touches.has(pointer_index):
		_cancelled_touches.erase(pointer_index)
		return
	var pressed_anchor := _pressed_cells.get(pointer_index, Vector2i(-1, -1)) as Vector2i
	var start := _touch_start_positions.get(pointer_index, position) as Vector2
	_pressed_cells.erase(pointer_index)
	_touch_start_positions.erase(pointer_index)
	if pressed_anchor.x < 0:
		return
	call_deferred("_clear_pointer_cell_activation", pressed_anchor)
	var pressed_cell := _cells.get(pressed_anchor) as Control
	var released_inside := not cancelled \
		and start.distance_to(position) < TOUCH_CANCEL_DISTANCE \
		and pressed_cell != null \
		and pressed_cell.get_global_rect().has_point(position)
	cell_touch_released.emit(grid_kind, pressed_anchor, released_inside)


func _clear_pointer_cell_activation(anchor: Vector2i) -> void:
	_pointer_cell_activations.erase(anchor)


func _item_at_position(position: Vector2) -> bool:
	for item_control: Control in _items.values():
		if item_control.get_global_rect().has_point(position):
			return true
	return false


func _anchor_at_position(position: Vector2) -> Vector2i:
	for anchor: Vector2i in _cells:
		var cell := _cells[anchor] as Control
		if cell != null and cell.get_global_rect().has_point(position):
			return anchor
	return Vector2i(-1, -1)
