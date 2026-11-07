class_name LootCachePanel
extends Control
## S03's R10 dock. It stores only presentation selection; RetrieverInventory
## remains the sole owner of placement, movement and sealing rules.

signal closed
signal item_placed(item: ItemInstance, target: StringName, anchor: Vector2i)

enum Session { CARD, PICKUP, VIEW, CLOSED }

var inventory: RetrieverInventory
var cache: LootCache
var session: Session = Session.CLOSED
var selected_index := 0
var selected_uid := 0
var pending_rotated := false

var _card: LootCacheCard
var _backpack: InventoryGridWidget
var _notary_box: InventoryGridWidget
var _status: Label
var _rotate: Button


func _ready() -> void:
	theme = UiTheme.create()
	if inventory != null and cache != null:
		open_card()


func configure(p_inventory: RetrieverInventory, p_cache: LootCache) -> void:
	inventory = p_inventory
	cache = p_cache
	selected_index = 0
	selected_uid = 0
	pending_rotated = false
	if is_inside_tree():
		open_card()


func open_card(index: int = 0) -> void:
	if cache == null or cache.cache_state() == &"empty":
		close_overlay()
		return
	selected_index = clampi(index, 0, cache.ordered_items().size() - 1)
	selected_uid = 0
	session = Session.CARD
	pending_rotated = false
	_clear()
	_card = LootCacheCard.new()
	_card.name = "LootCacheCard"
	_card.configure(inventory, cache)
	add_child(_card)
	_card.select_item(selected_index)
	_card.item_selected.connect(func(index: int) -> void: selected_index = index)
	_card.pickup_requested.connect(func(_item: ItemInstance) -> void: open_pickup())
	_card.skipped.connect(_on_skipped)
	_card.closed.connect(close_overlay)


func open_pickup() -> void:
	if _current_item() == null:
		open_card()
		return
	selected_uid = 0
	session = Session.PICKUP
	pending_rotated = false
	_clear()
	_build_grid()
	_refresh_grid_markers()


func open_view(p_inventory: RetrieverInventory = null) -> void:
	if p_inventory != null:
		inventory = p_inventory
	if inventory == null:
		return
	selected_uid = 0
	session = Session.VIEW
	pending_rotated = false
	_clear()
	_build_grid()
	_refresh_grid_markers()


func preview_cell(target: StringName, anchor: Vector2i) -> InventoryResult:
	var result := _preview_for(target, anchor)
	_show_preview(result, target, anchor)
	return result


func release_cell(target: StringName, anchor: Vector2i, inside: bool = true) -> InventoryResult:
	if not inside:
		_refresh_grid_markers()
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND)
	var preview := _preview_for(target, anchor)
	if not preview.ok:
		_show_preview(preview, target, anchor)
		return preview
	var result := _commit_for(target, anchor)
	if not result.ok:
		_show_preview(result, target, anchor)
		return result
	if session == Session.PICKUP:
		var item := _current_item()
		cache.remove_after_pickup(item.uid)
		item_placed.emit(item, target, anchor)
		if cache.cache_state() == &"empty":
			close_overlay()
		else:
			open_card(0)
	else:
		pending_rotated = false
		_refresh_grid_markers()
	return result


func toggle_rotate() -> void:
	var item := _selected_item()
	if item == null or not item.definition.rotatable or item.definition.is_square():
		return
	pending_rotated = not pending_rotated
	_refresh_grid_markers()


func close() -> void:
	if session == Session.PICKUP:
		open_card(selected_index)
	else:
		close_overlay()


func close_overlay() -> void:
	session = Session.CLOSED
	selected_uid = 0
	pending_rotated = false
	_clear()
	closed.emit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _build_grid() -> void:
	var panel := Panel.new()
	panel.name = "LootGridPanel"
	panel.position = Vector2(704, 176)
	panel.size = Vector2(560, 528)
	add_child(panel)
	var source_key: StringName = &"INVENTORY_PICKUP_SOURCE_CACHE" if session == Session.PICKUP else &"INVENTORY_PANEL_TITLE"
	var source := _label("Source", source_key, 24)
	source.position = Vector2(16, 8)
	source.size = Vector2(528, 36)
	panel.add_child(source)
	var item := _selected_item()
	var held_key: StringName = item.definition.display_name_key if item != null else &"INVENTORY_PANEL_TITLE"
	var held := _label("HeldItem", held_key, 24)
	held.position = Vector2(16, 44)
	held.size = Vector2(528, 36)
	panel.add_child(held)
	_status = _label("Status", &"INVENTORY_PICKUP_HINT_ITEM" if session == Session.PICKUP else &"LOADOUT_HINT_SELECT", 24)
	_status.position = Vector2(16, 80)
	_status.size = Vector2(528, 32)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(_status)
	_backpack = _grid(panel, "Backpack", &"LOADOUT_LABEL_BACKPACK", RetrieverInventory.BACKPACK, Vector2(16, 92))
	_notary_box = _grid(panel, "NotaryBox", &"LOADOUT_LABEL_NOTARY_BOX", RetrieverInventory.NOTARY_BOX, Vector2(352, 92))
	if item != null and item.definition.rotatable and not item.definition.is_square():
		_rotate = _button("RotateButton", &"INVENTORY_BUTTON_ROTATE")
		_rotate.position = Vector2(352, 328)
		_rotate.size = Vector2(192, 96)
		_rotate.pressed.connect(toggle_rotate)
		panel.add_child(_rotate)
	var sling := _label("SlingPouch", &"LOADOUT_LABEL_SLING_POUCH", 24)
	sling.position = Vector2(352, 440)
	sling.size = Vector2(192, 48)
	panel.add_child(sling)
	var close_button := _button("CloseButton", &"CARD_ACTION_CLOSE")
	close_button.position = Vector2(1168, 16)
	close_button.size = Vector2(96, 96)
	close_button.pressed.connect(close)
	add_child(close_button)


func _grid(parent: Control, node_name: String, key: StringName, kind: StringName, at: Vector2) -> InventoryGridWidget:
	var label := _label(node_name + "Label", key, 24)
	label.position = at
	label.size = Vector2(288, 28)
	parent.add_child(label)
	var grid := InventoryGridWidget.new()
	grid.name = node_name
	grid.position = at + Vector2(0, 28)
	grid.configure(inventory, kind)
	grid.item_pressed.connect(_on_item_pressed)
	grid.cell_touch_started.connect(_on_grid_touch_started)
	grid.cell_touch_released.connect(_on_grid_touch_released)
	parent.add_child(grid)
	return grid


func _refresh_grid_markers() -> void:
	if _backpack == null or _notary_box == null:
		return
	var item := _selected_item()
	if item == null:
		_backpack.show_selection(0)
		_notary_box.show_selection(0)
		if _status != null:
			_status.text = tr(&"LOADOUT_HINT_SELECT")
		return
	_backpack.show_selection(selected_uid, _preview_map(RetrieverInventory.BACKPACK))
	_notary_box.show_selection(selected_uid, _preview_map(RetrieverInventory.NOTARY_BOX))
	if _rotate != null:
		_rotate.text = tr(&"INVENTORY_BUTTON_ROTATE") + (" ↻" if pending_rotated else "")
	if _status != null:
		_status.text = tr(&"INVENTORY_PICKUP_HINT_ITEM") if session == Session.PICKUP else _view_hint(item)


func _preview_map(target: StringName) -> Dictionary:
	var output: Dictionary = {}
	var grid := inventory.backpack if target == RetrieverInventory.BACKPACK else inventory.notary_box
	for y in grid.size.y:
		for x in grid.size.x:
			var anchor := Vector2i(x, y)
			output[anchor] = _preview_for(target, anchor)
	return output


func _preview_for(target: StringName, anchor: Vector2i) -> InventoryResult:
	if inventory == null:
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND)
	if session == Session.PICKUP:
		return inventory.preview_pickup(_current_item(), target, anchor, pending_rotated)
	if session != Session.VIEW or selected_uid == 0:
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND)
	var found := _find_selected()
	if found.is_empty():
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND, selected_uid)
	var source: InventoryGrid = found.grid
	if source.grid_kind == RetrieverInventory.NOTARY_BOX and target == RetrieverInventory.BACKPACK:
		return InventoryResult.failure(InventoryReason.Value.WRONG_TARGET, selected_uid)
	if source.grid_kind == RetrieverInventory.BACKPACK and target == RetrieverInventory.NOTARY_BOX:
		return inventory.preview_seal(selected_uid, anchor, pending_rotated)
	if source.grid_kind == target:
		return inventory.preview_move(selected_uid, target, anchor, pending_rotated)
	return InventoryResult.failure(InventoryReason.Value.WRONG_TARGET, selected_uid)


func _commit_for(target: StringName, anchor: Vector2i) -> InventoryResult:
	if session == Session.PICKUP:
		return inventory.commit_pickup(_current_item(), target, anchor, pending_rotated)
	var found := _find_selected()
	if found.is_empty():
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND, selected_uid)
	if found.grid.grid_kind == RetrieverInventory.BACKPACK and target == RetrieverInventory.NOTARY_BOX:
		return inventory.commit_seal(selected_uid, anchor, pending_rotated)
	return inventory.commit_move(selected_uid, target, anchor, pending_rotated)


func _show_preview(result: InventoryResult, target: StringName, anchor: Vector2i) -> void:
	if _status == null:
		return
	if result.ok:
		_status.text = tr(&"INVENTORY_PREVIEW_FITS_BACKPACK") if target == RetrieverInventory.BACKPACK else tr(&"INVENTORY_PREVIEW_FITS_NOTARY_BOX")
	else:
		_status.text = _reason_text(result)
	var widget := _backpack if target == RetrieverInventory.BACKPACK else _notary_box
	widget.show_selection(selected_uid, _preview_map(target), result.blocking_cells)
	widget.show_touch_preview(_selected_item(), anchor, pending_rotated, result)


func _on_grid_touch_started(target: StringName, anchor: Vector2i) -> void:
	preview_cell(target, anchor)


func _on_grid_touch_released(target: StringName, anchor: Vector2i, inside: bool) -> void:
	release_cell(target, anchor, inside)


func _on_item_pressed(uid: int) -> void:
	if session != Session.VIEW:
		return
	selected_uid = 0 if selected_uid == uid else uid
	pending_rotated = false
	_refresh_grid_markers()


func _on_skipped(_item: ItemInstance) -> void:
	var next := selected_index + 1
	if cache.item_at(next) == null:
		close_overlay()
	else:
		open_card(next)


func _current_item() -> ItemInstance:
	return cache.item_at(selected_index) if cache != null else null


func _selected_item() -> ItemInstance:
	if session == Session.PICKUP:
		return _current_item()
	var found := _find_selected()
	return found.item as ItemInstance if not found.is_empty() else null


func _find_selected() -> Dictionary:
	if inventory == null or selected_uid == 0:
		return {}
	for grid: InventoryGrid in [inventory.backpack, inventory.notary_box]:
		var item := grid.items.get(selected_uid) as ItemInstance
		if item != null:
			return {"grid": grid, "item": item}
	return {}


func _view_hint(item: ItemInstance) -> String:
	return tr(&"INVENTORY_REASON_WITHDRAW_LOCKED") if item.item_location == RetrieverInventory.NOTARY_BOX else item.definition.localized_display_name()


func _reason_text(result: InventoryResult) -> String:
	var item := _selected_item()
	var name := item.definition.localized_display_name() + " · " if item != null else ""
	if item != null and item.item_location == RetrieverInventory.NOTARY_BOX and session == Session.VIEW:
		return name + tr(&"INVENTORY_REASON_WITHDRAW_LOCKED")
	return name + tr("INVENTORY_REASON_" + InventoryReason.Value.keys()[int(result.reason)])


func _clear() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_card = null
	_backpack = null
	_notary_box = null
	_status = null
	_rotate = null


func _label(node_name: String, key: StringName, font_size: int) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = tr(key)
	label.add_theme_font_size_override("font_size", font_size)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _button(node_name: String, key: StringName) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = tr(key)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 24)
	return button
