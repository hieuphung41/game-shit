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

var inventory: RetrieverInventory
var grid_kind: StringName = RetrieverInventory.BACKPACK
var read_only := false
var cell_scale := 1.0
var selected_uid := 0
var preview_reasons: Dictionary = {}
var error_cells: Array[Vector2i] = []

var _grid: InventoryGrid
var _cells: Dictionary = {}
var _items: Dictionary = {}
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
	_render()


func show_selection(p_uid: int, p_preview_reasons: Dictionary = {}, p_error_cells: Array[Vector2i] = []) -> void:
	selected_uid = p_uid
	preview_reasons = p_preview_reasons
	error_cells = p_error_cells
	_render()


func press_item(uid: int) -> void:
	if not read_only:
		item_pressed.emit(uid)


func press_cell(anchor: Vector2i) -> void:
	if not read_only:
		cell_pressed.emit(grid_kind, anchor)


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
			cell.add_theme_font_size_override("font_size", max(20, int(26 * cell_scale)))
			cell.pressed.connect(press_cell.bind(anchor))
			cell.gui_input.connect(_on_cell_gui_input.bind(anchor))
			add_child(cell)
			_cells[anchor] = cell
	for item: ItemInstance in _grid.all_items():
		_add_item(item, cell_size)


func _marker_for(anchor: Vector2i) -> String:
	if error_cells.has(anchor):
		return "!"
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
	button.add_theme_font_size_override("font_size", max(20, int(22 * cell_scale)))
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
			cell_touch_started.emit(grid_kind, anchor)
		else:
			cell_touch_released.emit(grid_kind, anchor, true)
