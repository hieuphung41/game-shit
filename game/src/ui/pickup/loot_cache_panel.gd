class_name LootCachePanel
extends Control
## O2B/O3B coordinator. It owns presentation state only; all placement checks
## and mutations pass through RetrieverInventory and LootCache's public API.

signal closed
signal item_placed(item: ItemInstance, target: StringName, anchor: Vector2i)

enum Session { CARD, PICKUP, CLOSED }

var inventory: RetrieverInventory
var cache: LootCache
var session: Session = Session.CLOSED
var selected_index := 0
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
	pending_rotated = false
	if is_inside_tree():
		open_card()


func open_card(index: int = 0) -> void:
	if cache == null or cache.cache_state() == &"empty":
		close_overlay()
		return
	selected_index = clampi(index, 0, cache.ordered_items().size() - 1)
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
	session = Session.PICKUP
	pending_rotated = false
	_clear()
	_build_grid()
	_refresh_previews()


func preview_cell(target: StringName, anchor: Vector2i) -> InventoryResult:
	var item := _current_item()
	if item == null:
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND)
	var result := inventory.preview_pickup(item, target, anchor, pending_rotated)
	_show_preview(result, target)
	return result


func release_cell(target: StringName, anchor: Vector2i, inside: bool = true) -> InventoryResult:
	if not inside:
		_refresh_previews()
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND)
	var item := _current_item()
	if item == null:
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND)
	var preview := inventory.preview_pickup(item, target, anchor, pending_rotated)
	if not preview.ok:
		_show_preview(preview, target)
		return preview
	var result := inventory.commit_pickup(item, target, anchor, pending_rotated)
	if not result.ok:
		_show_preview(result, target)
		return result
	cache.remove_after_pickup(item.uid)
	item_placed.emit(item, target, anchor)
	if cache.cache_state() == &"empty":
		close_overlay()
	else:
		open_card(0)
	return result


func toggle_rotate() -> void:
	var item := _current_item()
	if item == null or not item.definition.rotatable or item.definition.is_square():
		return
	pending_rotated = not pending_rotated
	if _rotate != null:
		_rotate.disabled = false
	_refresh_previews()


func close() -> void:
	if session == Session.PICKUP:
		open_card(selected_index)
	else:
		close_overlay()


func close_overlay() -> void:
	session = Session.CLOSED
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
	panel.position = Vector2(304, 120)
	panel.size = Vector2(960, 584)
	add_child(panel)
	var title := _label("Source", &"INVENTORY_PICKUP_SOURCE_CACHE", 24)
	title.position = Vector2(24, 16)
	title.size = Vector2(680, 40)
	panel.add_child(title)
	var item := _current_item()
	var held := _label("HeldItem", item.definition.display_name_key, 20)
	held.position = Vector2(24, 56)
	held.size = Vector2(500, 34)
	panel.add_child(held)
	_status = _label("Status", &"INVENTORY_PICKUP_HINT_ITEM", 18)
	_status.position = Vector2(24, 94)
	_status.size = Vector2(680, 40)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(_status)
	_backpack = _grid(panel, "Backpack", &"LOADOUT_LABEL_BACKPACK", RetrieverInventory.BACKPACK, Vector2(24, 144))
	_notary_box = _grid(panel, "NotaryBox", &"LOADOUT_LABEL_NOTARY_BOX", RetrieverInventory.NOTARY_BOX, Vector2(424, 144))
	if item.definition.rotatable and not item.definition.is_square():
		_rotate = _button("RotateButton", &"INVENTORY_BUTTON_ROTATE")
		_rotate.position = Vector2(736, 144)
		_rotate.size = Vector2(200, 96)
		_rotate.pressed.connect(toggle_rotate)
		panel.add_child(_rotate)
	var close_button := _button("CloseButton", &"CARD_ACTION_CLOSE")
	close_button.position = Vector2(736, 456)
	close_button.size = Vector2(200, 96)
	close_button.pressed.connect(close)
	panel.add_child(close_button)


func _grid(parent: Control, node_name: String, key: StringName, kind: StringName, at: Vector2) -> InventoryGridWidget:
	var label := _label(node_name + "Label", key, 20)
	label.position = at
	label.size = Vector2(288, 32)
	parent.add_child(label)
	var grid := InventoryGridWidget.new()
	grid.name = node_name
	grid.position = at + Vector2(0, 36)
	grid.configure(inventory, kind)
	grid.cell_touch_started.connect(_on_grid_touch_started)
	grid.cell_touch_released.connect(_on_grid_touch_released)
	grid.cell_pressed.connect(func(target: StringName, anchor: Vector2i) -> void: release_cell(target, anchor))
	parent.add_child(grid)
	return grid


func _refresh_previews() -> void:
	if _backpack == null:
		return
	var item := _current_item()
	if item == null:
		return
	_backpack.show_selection(0, _preview_map(item, RetrieverInventory.BACKPACK))
	_notary_box.show_selection(0, _preview_map(item, RetrieverInventory.NOTARY_BOX))
	if _rotate != null:
		_rotate.text = tr("INVENTORY_BUTTON_ROTATE") + (" ↻" if pending_rotated else "")
	if _status != null:
		_status.text = tr("INVENTORY_PICKUP_HINT_ITEM")


func _preview_map(item: ItemInstance, target: StringName) -> Dictionary:
	var output: Dictionary = {}
	var grid := inventory.backpack if target == RetrieverInventory.BACKPACK else inventory.notary_box
	for y in grid.size.y:
		for x in grid.size.x:
			output[Vector2i(x, y)] = inventory.preview_pickup(item, target, Vector2i(x, y), pending_rotated)
	return output


func _show_preview(result: InventoryResult, target: StringName) -> void:
	if _status == null:
		return
	if result.ok:
		_status.text = tr("INVENTORY_PREVIEW_FITS_BACKPACK") if target == RetrieverInventory.BACKPACK else tr("INVENTORY_PREVIEW_FITS_NOTARY_BOX")
	else:
		_status.text = tr("INVENTORY_REASON_" + InventoryReason.Value.keys()[int(result.reason)])
	var widget := _backpack if target == RetrieverInventory.BACKPACK else _notary_box
	widget.show_selection(0, _preview_map(_current_item(), target), result.blocking_cells)


func _on_grid_touch_started(target: StringName, anchor: Vector2i) -> void:
	preview_cell(target, anchor)


func _on_grid_touch_released(target: StringName, anchor: Vector2i, inside: bool) -> void:
	release_cell(target, anchor, inside)


func _on_skipped(_item: ItemInstance) -> void:
	var next := selected_index + 1
	if cache.item_at(next) == null:
		close_overlay()
	else:
		open_card(next)


func _current_item() -> ItemInstance:
	return cache.item_at(selected_index) if cache != null else null


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
	button.add_theme_font_size_override("font_size", 22)
	return button
