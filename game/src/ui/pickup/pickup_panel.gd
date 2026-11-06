class_name ManifestPickupPanel
extends Control
## O3/O4 placement panel. Inventory mutations use only RetrieverInventory's
## public commit methods; the parent owns the world ground-item lifecycle.

signal closed(placed: bool)
signal manifest_placed(target: StringName, anchor: Vector2i)

enum Mode { PICKUP, VIEW }

const UI_OPEN_GUARD_SECONDS := 0.3

var inventory: RetrieverInventory
var ground_manifest: ItemInstance
var mode: Mode = Mode.PICKUP
var selected_uid := 0
var _opened_at_msec := 0

var _backpack: InventoryGridWidget
var _notary_box: InventoryGridWidget
var _status: Label
var _held_card: Label


func _ready() -> void:
	theme = UiTheme.create()
	if inventory != null:
		_build()


func open_pickup(p_inventory: RetrieverInventory, p_ground_manifest: ItemInstance) -> void:
	inventory = p_inventory
	ground_manifest = p_ground_manifest
	mode = Mode.PICKUP
	selected_uid = 0
	if is_inside_tree():
		_build()


func open_view(p_inventory: RetrieverInventory) -> void:
	inventory = p_inventory
	ground_manifest = null
	mode = Mode.VIEW
	selected_uid = 0
	if is_inside_tree():
		_build()


func tap_cell(target: StringName, anchor: Vector2i) -> void:
	if mode == Mode.PICKUP:
		_try_pickup(target, anchor)
		return
	if selected_uid == 0:
		return
	_try_view_move(target, anchor)


func select_item(uid: int) -> void:
	if mode != Mode.VIEW:
		return
	if selected_uid == uid:
		selected_uid = 0
		_status.text = tr("LOADOUT_HINT_SELECT")
	else:
		selected_uid = uid
		_status.text = _selection_text(uid)
	_refresh_grids()


func close() -> void:
	if not _input_guard_active():
		closed.emit(mode == Mode.VIEW)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and not _input_guard_active():
		closed.emit(mode == Mode.VIEW)
		get_viewport().set_input_as_handled()


func _build() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var panel := Panel.new()
	panel.name = "PickupPanel"
	panel.position = Vector2(296, 128)
	panel.size = Vector2(968, 576)
	add_child(panel)
	var title_key: StringName = &"INVENTORY_PICKUP_SOURCE_DESK" if mode == Mode.PICKUP else &"INVENTORY_PANEL_TITLE"
	var title := _label("Title", title_key, 28)
	title.position = Vector2(24, 16)
	title.size = Vector2(600, 46)
	panel.add_child(title)
	_held_card = _label("HeldManifest", "CARD_MANIFEST_R17_NAME", 20)
	_held_card.position = Vector2(24, 64)
	_held_card.size = Vector2(600, 40)
	panel.add_child(_held_card)
	if mode == Mode.PICKUP:
		var source := _label("Source", "INVENTORY_PICKUP_SOURCE_DESK", 20)
		source.position = Vector2(632, 64)
		source.size = Vector2(300, 40)
		source.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		panel.add_child(source)
		_status = _label("Status", "INVENTORY_PICKUP_HINT", 20)
	else:
		_held_card.visible = false
		_status = _label("Status", "LOADOUT_HINT_SELECT", 20)
	# Keep failure text above the grids; a cell must never cover its reason.
	_status.position = Vector2(24, 104)
	_status.size = Vector2(700, 24)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(_status)
	_backpack = _grid_with_label(panel, "Backpack", "LOADOUT_LABEL_BACKPACK", RetrieverInventory.BACKPACK, Vector2(24, 128))
	_notary_box = _grid_with_label(panel, "NotaryBox", "LOADOUT_LABEL_NOTARY_BOX", RetrieverInventory.NOTARY_BOX, Vector2(424, 128))
	var close_button := _button("CloseButton", "CARD_ACTION_CLOSE", Vector2(744, 456), Vector2(200, 96))
	close_button.pressed.connect(close)
	panel.add_child(close_button)
	_opened_at_msec = Time.get_ticks_msec()
	_refresh_grids()


func _grid_with_label(parent: Control, node_name: String, key: StringName, kind: StringName, at: Vector2) -> InventoryGridWidget:
	var label := _label(node_name + "Label", key, 20)
	label.position = at
	label.size = Vector2(288, 32)
	parent.add_child(label)
	var grid := InventoryGridWidget.new()
	grid.name = node_name
	grid.position = at + Vector2(0, 36)
	grid.configure(inventory, kind)
	grid.item_pressed.connect(_on_item_pressed)
	grid.cell_pressed.connect(_on_cell_pressed)
	parent.add_child(grid)
	return grid


func _try_pickup(target: StringName, anchor: Vector2i) -> void:
	if ground_manifest == null:
		_show_reason(InventoryReason.Value.ITEM_NOT_FOUND, [])
		return
	var preview := inventory.preview_pickup(ground_manifest, target, anchor, false)
	if not preview.ok:
		_show_result(preview)
		return
	var result := inventory.commit_pickup(ground_manifest, target, anchor, false)
	if not result.ok:
		_show_result(result)
		return
	mode = Mode.VIEW
	ground_manifest = null
	selected_uid = 0
	manifest_placed.emit(target, anchor)
	_build()
	_status.text = tr("PROMPT_SAFEBOX_SEAL_HINT")


func _try_view_move(target: StringName, anchor: Vector2i) -> void:
	var found := _find_item(selected_uid)
	if found.is_empty():
		_show_reason(InventoryReason.Value.ITEM_NOT_FOUND, [])
		return
	var source: InventoryGrid = found.grid
	if source.grid_kind == RetrieverInventory.NOTARY_BOX and target == RetrieverInventory.BACKPACK:
		_show_locked_withdraw()
		return
	var preview: InventoryResult
	if source.grid_kind == RetrieverInventory.BACKPACK and target == RetrieverInventory.NOTARY_BOX:
		preview = inventory.preview_seal(selected_uid, anchor, false)
	elif source.grid_kind == target:
		preview = inventory.preview_move(selected_uid, target, anchor, false)
	else:
		preview = InventoryResult.failure(InventoryReason.Value.WRONG_TARGET, selected_uid)
	if not preview.ok:
		_show_result(preview)
		return
	if anchor == found.item.anchor and source.grid_kind == target:
		select_item(selected_uid)
		return
	var result: InventoryResult
	if source.grid_kind == RetrieverInventory.BACKPACK and target == RetrieverInventory.NOTARY_BOX:
		result = inventory.commit_seal(selected_uid, anchor, false)
	else:
		result = inventory.commit_move(selected_uid, target, anchor, false)
	if result.ok:
		selected_uid = 0
		_status.text = tr("PROMPT_SAFEBOX_SEAL_HINT")
	else:
		_show_result(result)
	_refresh_grids()


func _refresh_grids() -> void:
	if _backpack == null:
		return
	_backpack.show_selection(selected_uid, _preview_map(RetrieverInventory.BACKPACK))
	_notary_box.show_selection(selected_uid, _preview_map(RetrieverInventory.NOTARY_BOX))


func _preview_map(target: StringName) -> Dictionary:
	var results: Dictionary = {}
	var grid := _grid_for(target)
	for y in grid.size.y:
		for x in grid.size.x:
			var anchor := Vector2i(x, y)
			if mode == Mode.PICKUP:
				if ground_manifest != null:
					results[anchor] = inventory.preview_pickup(ground_manifest, target, anchor, false)
			elif selected_uid != 0:
				var found := _find_item(selected_uid)
				if found.is_empty():
					results[anchor] = InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND, selected_uid)
				elif found.grid.grid_kind == RetrieverInventory.NOTARY_BOX and target == RetrieverInventory.BACKPACK:
					results[anchor] = InventoryResult.failure(InventoryReason.Value.WRONG_TARGET, selected_uid)
				elif found.grid.grid_kind == RetrieverInventory.BACKPACK and target == RetrieverInventory.NOTARY_BOX:
					results[anchor] = inventory.preview_seal(selected_uid, anchor, false)
				elif found.grid.grid_kind == target:
					results[anchor] = inventory.preview_move(selected_uid, target, anchor, false)
				else:
					results[anchor] = InventoryResult.failure(InventoryReason.Value.WRONG_TARGET, selected_uid)
	return results


func _show_result(result: InventoryResult) -> void:
	_status.text = _reason_text(result.reason)
	_backpack.show_selection(selected_uid, _preview_map(RetrieverInventory.BACKPACK), result.blocking_cells)
	_notary_box.show_selection(selected_uid, _preview_map(RetrieverInventory.NOTARY_BOX), result.blocking_cells)


func _show_reason(reason: InventoryReason.Value, cells: Array[Vector2i]) -> void:
	var result := InventoryResult.failure(reason, selected_uid)
	result.blocking_cells = cells
	_show_result(result)


func _show_locked_withdraw() -> void:
	_status.text = tr("INVENTORY_REASON_WITHDRAW_LOCKED")
	_refresh_grids()


func _reason_text(reason: InventoryReason.Value) -> String:
	return tr("INVENTORY_REASON_" + InventoryReason.Value.keys()[int(reason)])


func _selection_text(uid: int) -> String:
	var found := _find_item(uid)
	if found.is_empty() or found.item.definition == null:
		return tr("LOADOUT_HINT_SELECT")
	var item: ItemInstance = found.item
	return tr("INVENTORY_SELECTED_ITEM").format({
		"item": item.definition.localized_display_name(),
		"width": item.effective_size().x,
		"height": item.effective_size().y,
	})


func _find_item(uid: int) -> Dictionary:
	for grid: InventoryGrid in [inventory.backpack, inventory.notary_box]:
		var item := grid.items.get(uid) as ItemInstance
		if item != null:
			return {"grid": grid, "item": item}
	return {}


func _grid_for(kind: StringName) -> InventoryGrid:
	return inventory.notary_box if kind == RetrieverInventory.NOTARY_BOX else inventory.backpack


func _on_item_pressed(uid: int) -> void:
	if _input_guard_active():
		return
	if mode == Mode.PICKUP:
		var found := _find_item(uid)
		if not found.is_empty():
			tap_cell(found.grid.grid_kind, found.item.anchor)
		return
	select_item(uid)


func _on_cell_pressed(target: StringName, anchor: Vector2i) -> void:
	if not _input_guard_active():
		tap_cell(target, anchor)


func _input_guard_active() -> bool:
	return Time.get_ticks_msec() - _opened_at_msec < int(UI_OPEN_GUARD_SECONDS * 1000.0)


func _label(node_name: String, key: StringName, font_size: int) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = tr(key)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", UiTheme.INK)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _button(node_name: String, key: StringName, at: Vector2, dimensions: Vector2) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = tr(key)
	button.position = at
	button.size = dimensions
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 24)
	return button
