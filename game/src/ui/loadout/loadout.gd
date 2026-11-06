class_name LoadoutScreen
extends Control
## Signals for the external flow controller (TASK-75):
## - finished(inventory): player kept same-grid loadout changes and returned to S1.
## - cancelled(inventory): snapshot from opening O1 was restored before returning to S1.

signal finished(inventory: RetrieverInventory)
signal cancelled(inventory: RetrieverInventory)

const UI_OPEN_GUARD_SECONDS := 0.3

var inventory: RetrieverInventory
var snapshot_open: Dictionary = {}
var selected_uid := 0
var _opened_at_msec := 0

var _backpack: InventoryGridWidget
var _notary_box: InventoryGridWidget
var _sling_pouch: InventoryGridWidget
var _status: Label


func _ready() -> void:
	theme = UiTheme.create()
	if inventory == null:
		inventory = StarterInventoryFactory.create()
	_open()


func open_with_inventory(p_inventory: RetrieverInventory) -> void:
	inventory = p_inventory
	if is_inside_tree():
		_open()


func select_item(uid: int) -> void:
	if selected_uid == uid:
		selected_uid = 0
		_status.text = tr("LOADOUT_HINT_SELECT")
	else:
		selected_uid = uid
		_status.text = _selection_text(uid)
	_refresh_grids()


func tap_cell(target: StringName, anchor: Vector2i) -> void:
	if selected_uid == 0:
		return
	var found := _find_item(selected_uid)
	if found.is_empty():
		_show_reason(InventoryReason.Value.ITEM_NOT_FOUND, [])
		return
	var source: InventoryGrid = found.grid
	if source.grid_kind != target or source.grid_kind == RetrieverInventory.SLING_POUCH:
		_show_cross_grid_locked()
		return
	var preview := inventory.preview_move(selected_uid, target, anchor, false)
	if not preview.ok:
		_show_result(preview)
		return
	if anchor == found.item.anchor:
		select_item(selected_uid)
		return
	var result := inventory.commit_move(selected_uid, target, anchor, false)
	if result.ok:
		selected_uid = 0
		_status.text = tr("LOADOUT_HINT_SELECT")
	else:
		_show_result(result)
	_refresh_grids()


func finish() -> void:
	finished.emit(inventory)


func cancel() -> void:
	inventory.load_snapshot(snapshot_open)
	selected_uid = 0
	cancelled.emit(inventory)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and not _input_guard_active():
		cancel()
		accept_event()


func _open() -> void:
	snapshot_open = inventory.snapshot()
	selected_uid = 0
	_build()
	_opened_at_msec = Time.get_ticks_msec()


func _build() -> void:
	for child in get_children():
		child.queue_free()
	var background := ColorRect.new()
	background.color = UiTheme.PAPER
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var title := _label("Title", "LOADOUT_TITLE", 32)
	title.position = Vector2(32, 24)
	title.size = Vector2(600, 64)
	add_child(title)
	var backpack_at := Vector2(64, 104)
	var notary_box_at := Vector2(448, 104)
	var sling_pouch_at := Vector2(448, 392)
	var summary_at := Vector2(736, 136)
	var summary_size := Vector2(512, 184)
	var status_at := Vector2(64, 540)
	var status_size := Vector2(896, 48)
	var actions_y := 600.0
	if _uses_compact_touch_layout():
		backpack_at = Vector2(64, 64)
		notary_box_at = Vector2(480, 64)
		sling_pouch_at = Vector2(480, 376)
		summary_at = Vector2(800, 96)
		summary_size = Vector2(448, 352)
		status_at = Vector2(800, 472)
		status_size = Vector2(448, 104)
		actions_y = 608.0
	_backpack = _grid_with_label("Backpack", "LOADOUT_LABEL_BACKPACK", RetrieverInventory.BACKPACK, backpack_at)
	_notary_box = _grid_with_label("NotaryBox", "LOADOUT_LABEL_NOTARY_BOX", RetrieverInventory.NOTARY_BOX, notary_box_at)
	_sling_pouch = _grid_with_label("SlingPouch", "LOADOUT_LABEL_SLING_POUCH", RetrieverInventory.SLING_POUCH, sling_pouch_at)
	var summary := _label("Summary", "LOADOUT_SUMMARY_DEFAULT_KIT", 20)
	summary.position = summary_at
	summary.size = summary_size
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(summary)
	_status = _label("Status", "LOADOUT_HINT_SELECT", 20)
	_status.position = status_at
	_status.size = status_size
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status)
	var cancel_button := _button("CancelButton", "LOADOUT_BUTTON_CANCEL", Vector2(32, actions_y), Vector2(240, 96))
	cancel_button.pressed.connect(_on_cancel_pressed)
	var done_button := _button("DoneButton", "LOADOUT_BUTTON_DONE", Vector2(968, actions_y), Vector2(280, 96))
	done_button.pressed.connect(_on_done_pressed)
	_refresh_grids()


func _uses_compact_touch_layout() -> bool:
	return InventoryGridWidget.logical_cell_size_for_window(DisplayServer.window_get_size()) > InventoryGridWidget.CELL_SIZE


func _grid_with_label(node_name: String, label_key: String, kind: StringName, at: Vector2) -> InventoryGridWidget:
	var label := _label(node_name + "Label", label_key, 20)
	label.position = at
	label.size = Vector2(288, 28)
	add_child(label)
	var grid := InventoryGridWidget.new()
	grid.name = node_name
	grid.position = at + Vector2(0, 32)
	grid.configure(inventory, kind)
	grid.item_pressed.connect(_on_item_pressed)
	grid.cell_pressed.connect(_on_cell_pressed)
	add_child(grid)
	return grid


func _refresh_grids() -> void:
	if _backpack == null:
		return
	for grid in [_backpack, _notary_box, _sling_pouch]:
		grid.show_selection(selected_uid, _preview_map(grid.grid_kind))


func _preview_map(target: StringName) -> Dictionary:
	var results: Dictionary = {}
	if selected_uid == 0:
		return results
	var found := _find_item(selected_uid)
	if found.is_empty():
		return results
	var grid := _grid_for(target)
	for y in grid.size.y:
		for x in grid.size.x:
			var anchor := Vector2i(x, y)
			if found.grid.grid_kind != target or target == RetrieverInventory.SLING_POUCH:
				results[anchor] = InventoryResult.failure(InventoryReason.Value.WRONG_TARGET, selected_uid)
			else:
				results[anchor] = inventory.preview_move(selected_uid, target, anchor, false)
	return results


func _show_cross_grid_locked() -> void:
	_status.text = tr("INVENTORY_REASON_CROSS_GRID_LOCKED")
	_refresh_grids()


func _show_result(result: InventoryResult) -> void:
	_status.text = _reason_text(result.reason)
	for grid in [_backpack, _notary_box, _sling_pouch]:
		grid.show_selection(selected_uid, _preview_map(grid.grid_kind), result.blocking_cells)


func _show_reason(reason: InventoryReason.Value, cells: Array[Vector2i]) -> void:
	var result := InventoryResult.failure(reason, selected_uid)
	result.blocking_cells = cells
	_show_result(result)


func _selection_text(uid: int) -> String:
	var found := _find_item(uid)
	if found.is_empty() or found.item.definition == null:
		return tr("LOADOUT_HINT_SELECT")
	var item: ItemInstance = found.item
	return "%s · %dx%d" % [_display_name(item), item.effective_size().x, item.effective_size().y]


func _reason_text(reason: InventoryReason.Value) -> String:
	return tr("INVENTORY_REASON_" + InventoryReason.Value.keys()[int(reason)])


func _display_name(item: ItemInstance) -> String:
	return item.definition.localized_display_name()


func _find_item(uid: int) -> Dictionary:
	for grid: InventoryGrid in [inventory.backpack, inventory.notary_box, inventory.sling_pouch]:
		var item := grid.items.get(uid) as ItemInstance
		if item != null:
			return {"grid": grid, "item": item}
	return {}


func _grid_for(kind: StringName) -> InventoryGrid:
	match kind:
		RetrieverInventory.BACKPACK:
			return inventory.backpack
		RetrieverInventory.NOTARY_BOX:
			return inventory.notary_box
		RetrieverInventory.SLING_POUCH:
			return inventory.sling_pouch
	return inventory.backpack


func _on_item_pressed(uid: int) -> void:
	if not _input_guard_active():
		select_item(uid)


func _on_cell_pressed(target: StringName, anchor: Vector2i) -> void:
	if not _input_guard_active():
		tap_cell(target, anchor)


func _on_cancel_pressed() -> void:
	if not _input_guard_active():
		cancel()


func _on_done_pressed() -> void:
	if not _input_guard_active():
		finish()


func _input_guard_active() -> bool:
	return Time.get_ticks_msec() - _opened_at_msec < int(UI_OPEN_GUARD_SECONDS * 1000.0)


func _label(node_name: String, key: String, font_size: int) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = tr(key)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", UiTheme.INK)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _button(node_name: String, key: String, at: Vector2, dimensions: Vector2) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = tr(key)
	button.position = at
	button.size = dimensions
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 24)
	add_child(button)
	return button
