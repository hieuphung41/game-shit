class_name LootCachePanel
extends Control
## S03's R10 dock. It stores only presentation selection; RetrieverInventory
## remains the sole owner of placement, movement and sealing rules.

signal closed
signal item_placed(item: ItemInstance, target: StringName, anchor: Vector2i)
signal item_drop_confirmed(uid: int)
signal item_withdraw_confirmed(uid: int, anchor: Vector2i)

enum Session { CARD, PICKUP, VIEW, CLOSED }

var inventory: RetrieverInventory
var cache: LootCache
var session: Session = Session.CLOSED
var selected_index := 0
var selected_uid := 0
var pending_rotated := false
var s04_mode := false
var _withdraw_targeting := false
var _pending_confirmation: Dictionary = {}

var _card: LootCacheCard
var _backpack: InventoryGridWidget
var _notary_box: InventoryGridWidget
var _status: Label
var _rotate: Button
var _footprint_chip: Label
var _footprint_shape_cue: Control
var _notary_status: Label
var _drop_or_withdraw: Button
var _confirmation: InventoryConfirmPanel

const DOCK_RIGHT_INSET := 16.0
const GRID_DOCK_TOP := 176.0
const GRID_DOCK_SIZE := Vector2(560, 528)
const CLOSE_BUTTON_TOP := 16.0
const CLOSE_BUTTON_SIZE := Vector2(96, 96)
const INVENTORY_CONFIRM_SCENE := preload("res://src/ui/confirm/inventory_confirm_panel.tscn")


func _ready() -> void:
	theme = UiTheme.create()
	if inventory != null and cache != null:
		open_card()


func configure(p_inventory: RetrieverInventory, p_cache: LootCache) -> void:
	inventory = p_inventory
	cache = p_cache
	s04_mode = false
	selected_index = 0
	selected_uid = 0
	pending_rotated = false
	if is_inside_tree():
		open_card()


## S04 uses the same source/card dock but enables the explicit Notary Box actions.
func configure_s04(p_inventory: RetrieverInventory, p_cache: LootCache) -> void:
	inventory = p_inventory
	cache = p_cache
	s04_mode = true
	selected_index = 0
	selected_uid = 0
	pending_rotated = false
	_withdraw_targeting = false
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
	_withdraw_targeting = false
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
	_withdraw_targeting = false
	_clear()
	_build_grid()
	_refresh_grid_markers()


func preview_cell(target: StringName, anchor: Vector2i) -> InventoryResult:
	if _confirmation != null:
		return InventoryResult.failure(InventoryReason.Value.WRONG_TARGET, selected_uid)
	var result := _preview_for(target, anchor)
	_show_preview(result, target, anchor)
	return result


func release_cell(target: StringName, anchor: Vector2i, inside: bool = true) -> InventoryResult:
	if _confirmation != null:
		return InventoryResult.failure(InventoryReason.Value.WRONG_TARGET, selected_uid)
	if not inside:
		_refresh_grid_markers()
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND)
	var preview := _preview_for(target, anchor)
	if not preview.ok:
		_show_preview(preview, target, anchor)
		return preview
	if _should_open_withdraw_confirmation(target):
		_show_preview(preview, target, anchor)
		_open_confirmation(&"withdraw", anchor, pending_rotated)
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
	if _confirmation != null:
		return
	var item := _selected_item()
	if item == null or not item.definition.rotatable or item.definition.is_square():
		return
	pending_rotated = not pending_rotated
	_refresh_grid_markers()


func request_drop() -> void:
	if not s04_mode or session != Session.VIEW or selected_uid == 0 or _confirmation != null:
		return
	var preview := inventory.preview_drop(selected_uid)
	if not preview.ok:
		_show_preview(preview, RetrieverInventory.BACKPACK, Vector2i.ZERO)
		return
	var item := _selected_item()
	if item == null:
		return
	_show_preview(preview, RetrieverInventory.BACKPACK, item.anchor)
	_open_confirmation(&"drop", item.anchor, item.rotated)


func request_withdraw() -> void:
	if not s04_mode or session != Session.VIEW or selected_uid == 0 or _confirmation != null:
		return
	var found := _find_selected()
	if found.is_empty() or found.grid.grid_kind != RetrieverInventory.NOTARY_BOX:
		return
	if not _has_withdraw_fit():
		_refresh_grid_markers()
		_status.text = _reason_text(InventoryResult.failure(InventoryReason.Value.CELLS_OCCUPIED, selected_uid))
		return
	_withdraw_targeting = not _withdraw_targeting
	_refresh_grid_markers()


func close() -> void:
	if _confirmation != null:
		return
	if session == Session.PICKUP:
		open_card(selected_index)
	else:
		close_overlay()


## D1 is deliberately exceptional while O5i owns pointer capture: it cancels
## the pending inventory action and then closes the entire dock in one tap.
func danger_close() -> void:
	if session == Session.CLOSED:
		return
	if _confirmation != null:
		_cancel_confirmation()
	close_overlay()


func close_overlay() -> void:
	session = Session.CLOSED
	selected_uid = 0
	pending_rotated = false
	_withdraw_targeting = false
	_pending_confirmation.clear()
	_clear()
	closed.emit()


func _input(event: InputEvent) -> void:
	if session == Session.CLOSED or get_viewport().is_input_handled():
		return
	if event.is_action_pressed(&"ui_cancel"):
		if _confirmation != null:
			# Let O5i own its guard and cancellation path before this dock may
			# consider closing itself.
			_confirmation.cancel()
		else:
			close()
		get_viewport().set_input_as_handled()


func _build_grid() -> void:
	var panel := Panel.new()
	panel.name = "LootGridPanel"
	_anchor_top_right(panel, DOCK_RIGHT_INSET, GRID_DOCK_TOP, GRID_DOCK_SIZE)
	add_child(panel)
	var source_key: StringName = _pickup_source_key() if session == Session.PICKUP else &"INVENTORY_PANEL_TITLE"
	var source := _label("Source", source_key, 24)
	source.position = Vector2(16, 6)
	source.size = Vector2(528, 24)
	panel.add_child(source)
	var item := _selected_item()
	var held_key: StringName = item.definition.display_name_key if item != null else &"INVENTORY_PANEL_TITLE"
	var held := _label("HeldItem", held_key, 24)
	held.position = Vector2(16, 40)
	held.size = Vector2(320, 28)
	panel.add_child(held)
	_footprint_shape_cue = Control.new()
	_footprint_shape_cue.name = "FootprintShapeCue"
	_footprint_shape_cue.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_footprint_shape_cue.position = Vector2(352, 34)
	_footprint_shape_cue.size = Vector2(48, 36)
	panel.add_child(_footprint_shape_cue)
	_footprint_chip = _label("FootprintChip", &"INVENTORY_FOOTPRINT_CHIP", 24)
	_footprint_chip.position = Vector2(408, 40)
	_footprint_chip.size = Vector2(120, 28)
	_footprint_chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	panel.add_child(_footprint_chip)
	_refresh_footprint_chip()
	_status = _label("Status", &"INVENTORY_PICKUP_HINT_ITEM" if session == Session.PICKUP else &"LOADOUT_HINT_SELECT", 24)
	# A 24 px label has a 34 px minimum Control height in the shared theme. Keep
	# the three strip rows and grid labels adjacent without overlapping their rects.
	_status.position = Vector2(16, 74)
	_status.size = Vector2(528, 24)
	_status.autowrap_mode = TextServer.AUTOWRAP_OFF
	_status.clip_text = true
	panel.add_child(_status)
	var grid_top := 92.0 if s04_mode else 108.0
	_backpack = _grid(panel, "Backpack", &"LOADOUT_LABEL_BACKPACK", RetrieverInventory.BACKPACK, Vector2(16, grid_top))
	_notary_box = _grid(panel, "NotaryBox", &"LOADOUT_LABEL_NOTARY_BOX", RetrieverInventory.NOTARY_BOX, Vector2(352, grid_top))
	if item != null and item.definition.rotatable and not item.definition.is_square():
		_rotate = _button("RotateButton", &"INVENTORY_BUTTON_ROTATE")
		_rotate.position = Vector2(320, 392) if s04_mode else Vector2(352, 328)
		_rotate.size = Vector2(104, 96) if s04_mode else Vector2(192, 96)
		_rotate.pressed.connect(toggle_rotate)
		panel.add_child(_rotate)
	if s04_mode:
		_notary_status = _static_label("NotaryStatus", "", 24)
		_notary_status.position = Vector2(320, 320)
		_notary_status.size = Vector2(224, 64)
		_notary_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		panel.add_child(_notary_status)
		_drop_or_withdraw = _button("DropOrWithdrawButton", &"INVENTORY_BUTTON_DROP")
		_drop_or_withdraw.position = Vector2(440, 392)
		_drop_or_withdraw.size = Vector2(104, 96)
		_drop_or_withdraw.pressed.connect(_on_drop_or_withdraw_pressed)
		panel.add_child(_drop_or_withdraw)
	var sling := _label("SlingPouch", &"LOADOUT_LABEL_SLING_POUCH", 24)
	sling.position = Vector2(320, 496) if s04_mode else Vector2(352, 440)
	sling.size = Vector2(192, 24)
	panel.add_child(sling)
	var sling_item := _sling_pouch_item()
	if sling_item != null:
		var sling_cue := _static_label("SlingPouchCue", "✚", 24)
		sling_cue.position = Vector2(320, 520) if s04_mode else Vector2(352, 464)
		sling_cue.size = Vector2(24, 24)
		panel.add_child(sling_cue)
		var sling_item_label := _static_label("SlingPouchItem", sling_item.definition.localized_display_name() + " " + tr(&"CARD_QUANTITY_SUFFIX").format({"quantity": sling_item.quantity}), 24)
		sling_item_label.position = Vector2(344, 520) if s04_mode else Vector2(376, 464)
		sling_item_label.size = Vector2(168, 24)
		panel.add_child(sling_item_label)
	var close_button := _button("CloseButton", &"CARD_ACTION_CLOSE")
	_anchor_top_right(close_button, DOCK_RIGHT_INSET, CLOSE_BUTTON_TOP, CLOSE_BUTTON_SIZE)
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
	grid.cell_pressed.connect(_on_grid_cell_pressed)
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
		_refresh_s04_controls(null)
		return
	_backpack.show_selection(selected_uid, _preview_map(RetrieverInventory.BACKPACK))
	_notary_box.show_selection(selected_uid, _preview_map(RetrieverInventory.NOTARY_BOX))
	if _rotate != null:
		_rotate.text = tr(&"INVENTORY_BUTTON_ROTATE") + (" ↻" if pending_rotated else "")
	_refresh_footprint_chip()
	if _status != null:
		if session == Session.PICKUP:
			_status.text = tr(&"INVENTORY_PICKUP_HINT_ITEM")
		else:
			_status.text = tr(&"INVENTORY_WITHDRAW_PICK_CELL_HINT") if _withdraw_targeting else _view_hint(item)
	_refresh_s04_controls(item)


func _refresh_footprint_chip() -> void:
	if _footprint_chip == null or _footprint_shape_cue == null:
		return
	var item := _selected_item()
	var visible := item != null and item.definition != null
	_footprint_chip.visible = visible
	_footprint_shape_cue.visible = visible
	if not visible:
		return
	var footprint := item.definition.size
	if pending_rotated and footprint.x != footprint.y:
		footprint = Vector2i(footprint.y, footprint.x)
	_footprint_chip.text = tr(&"INVENTORY_FOOTPRINT_CHIP").format({"w": footprint.x, "h": footprint.y})
	for child in _footprint_shape_cue.get_children():
		_footprint_shape_cue.remove_child(child)
		child.queue_free()
	for y in footprint.y:
		for x in footprint.x:
			var footprint_cell := _static_label("Cell_%d_%d" % [x, y], "□", 18)
			footprint_cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
			footprint_cell.position = Vector2(x * 20, y * 18)
			footprint_cell.size = Vector2(20, 18)
			_footprint_shape_cue.add_child(footprint_cell)


func _preview_map(target: StringName) -> Dictionary:
	var output: Dictionary = {}
	var grid := inventory.backpack if target == RetrieverInventory.BACKPACK else inventory.notary_box
	for y in grid.size.y:
		for x in grid.size.x:
			var anchor := Vector2i(x, y)
			# Direct touch on a backpack cell is a valid S04 withdraw entry, but
			# only the explicit Rút state paints every valid anchor in advance.
			# A direct touch still receives its own preview in preview_cell().
			if _selected_notary_item() and target == RetrieverInventory.BACKPACK and not _withdraw_targeting:
				output[anchor] = InventoryResult.failure(InventoryReason.Value.WRONG_TARGET, selected_uid)
			else:
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
		if not _can_withdraw_to(target):
			return InventoryResult.failure(InventoryReason.Value.WRONG_TARGET, selected_uid)
		return inventory.preview_withdraw(selected_uid, anchor, pending_rotated)
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
	if found.grid.grid_kind == RetrieverInventory.NOTARY_BOX and target == RetrieverInventory.BACKPACK:
		return InventoryResult.failure(InventoryReason.Value.WRONG_TARGET, selected_uid)
	if found.grid.grid_kind == RetrieverInventory.BACKPACK and target == RetrieverInventory.NOTARY_BOX:
		return inventory.commit_seal(selected_uid, anchor, pending_rotated)
	return inventory.commit_move(selected_uid, target, anchor, pending_rotated)


func _show_preview(result: InventoryResult, target: StringName, anchor: Vector2i) -> void:
	if _status == null:
		return
	if result.ok:
		if _can_withdraw_to(target):
			_status.text = tr(&"INVENTORY_PREVIEW_WITHDRAW_BACKPACK")
		else:
			_status.text = tr(&"INVENTORY_PREVIEW_FITS_BACKPACK") if target == RetrieverInventory.BACKPACK else tr(&"INVENTORY_PREVIEW_SEAL_NOTARY_BOX") if s04_mode else tr(&"INVENTORY_PREVIEW_FITS_NOTARY_BOX")
	else:
		_status.text = _reason_text(result)
	var widget := _backpack if target == RetrieverInventory.BACKPACK else _notary_box
	widget.show_selection(selected_uid, _preview_map(target), result.blocking_cells)
	widget.show_touch_preview(_selected_item(), anchor, pending_rotated, result)


func _on_grid_touch_started(target: StringName, anchor: Vector2i) -> void:
	preview_cell(target, anchor)


func _on_grid_touch_released(target: StringName, anchor: Vector2i, inside: bool) -> void:
	release_cell(target, anchor, inside)


func _on_grid_cell_pressed(target: StringName, anchor: Vector2i) -> void:
	var grid := _backpack if target == RetrieverInventory.BACKPACK else _notary_box
	if grid != null and grid.is_pointer_cell_activation(anchor):
		return
	preview_cell(target, anchor)
	release_cell(target, anchor)


func _on_item_pressed(uid: int) -> void:
	if session != Session.VIEW or _confirmation != null:
		return
	selected_uid = 0 if selected_uid == uid else uid
	pending_rotated = false
	_withdraw_targeting = false
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


func _sling_pouch_item() -> ItemInstance:
	if inventory == null:
		return null
	for item: ItemInstance in inventory.sling_pouch.all_items():
		return item
	return null


func _find_selected() -> Dictionary:
	if inventory == null or selected_uid == 0:
		return {}
	for grid: InventoryGrid in [inventory.backpack, inventory.notary_box]:
		var item := grid.items.get(selected_uid) as ItemInstance
		if item != null:
			return {"grid": grid, "item": item}
	return {}


func _view_hint(item: ItemInstance) -> String:
	return item.definition.localized_display_name()


func _reason_text(result: InventoryResult) -> String:
	var item := _selected_item()
	var name := item.definition.localized_display_name() + " · " if item != null else ""
	if item != null and item.item_location == RetrieverInventory.NOTARY_BOX and session == Session.VIEW and not s04_mode:
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
	_footprint_chip = null
	_footprint_shape_cue = null
	_notary_status = null
	_drop_or_withdraw = null
	_confirmation = null


func _pickup_source_key() -> StringName:
	if not s04_mode:
		return &"INVENTORY_PICKUP_SOURCE_CACHE"
	return &"INVENTORY_PICKUP_SOURCE_GROUND" if cache != null and (cache.cache_id == &"ground_drop" or String(cache.cache_id).begins_with("ground_drop_")) else &"INVENTORY_PICKUP_SOURCE_D"


func _refresh_s04_controls(item: ItemInstance) -> void:
	if not s04_mode:
		return
	if _notary_status != null:
		_notary_status.text = ""
		if session == Session.PICKUP and item != null and not item.definition.sealable:
			_notary_status.text = "▣ " + tr(&"CARD_FIT_NOTARY_BOX_NOT_SEALABLE")
		else:
			for box_item: ItemInstance in inventory.notary_box.all_items():
				if box_item.definition.item_category == ItemDef.Category.EVIDENCE:
					_notary_status.text = "▣ " + tr(&"INVENTORY_SEAL_LABEL_SEALED_NOT_EXTRACTED")
					break
	if _drop_or_withdraw == null:
		return
	_drop_or_withdraw.visible = item != null and session == Session.VIEW
	if item == null or session != Session.VIEW:
		return
	var in_box := item.item_location == RetrieverInventory.NOTARY_BOX
	var no_withdraw_fit := in_box and not _has_withdraw_fit()
	_drop_or_withdraw.text = _withdraw_button_text(no_withdraw_fit) if in_box else tr(&"INVENTORY_BUTTON_DROP")
	_drop_or_withdraw.disabled = _confirmation != null


func _on_drop_or_withdraw_pressed() -> void:
	var item := _selected_item()
	if item == null:
		return
	if item.item_location == RetrieverInventory.NOTARY_BOX:
		request_withdraw()
	else:
		request_drop()


func _selected_notary_item() -> bool:
	var found := _find_selected()
	return not found.is_empty() and found.grid.grid_kind == RetrieverInventory.NOTARY_BOX


func _can_withdraw_to(target: StringName) -> bool:
	if target != RetrieverInventory.BACKPACK or not s04_mode or session != Session.VIEW:
		return false
	return _selected_notary_item()


func _should_open_withdraw_confirmation(target: StringName) -> bool:
	return _can_withdraw_to(target)


func _has_withdraw_fit() -> bool:
	var item := _selected_item()
	if item == null:
		return false
	for y in inventory.backpack.size.y:
		for x in inventory.backpack.size.x:
			if inventory.preview_withdraw(item.uid, Vector2i(x, y), pending_rotated).ok:
				return true
	return false


func _withdraw_button_text(no_fit: bool) -> String:
	var label := tr(&"INVENTORY_BUTTON_WITHDRAW")
	return "⊘ 🔒 " + label if no_fit else label


func _open_confirmation(kind: StringName, anchor: Vector2i, rotated: bool) -> void:
	var item := _selected_item()
	if item == null:
		return
	_pending_confirmation = {"kind": kind, "uid": item.uid, "anchor": anchor, "rotated": rotated}
	_confirmation = INVENTORY_CONFIRM_SCENE.instantiate() as InventoryConfirmPanel
	if _confirmation == null:
		_pending_confirmation.clear()
		return
	_confirmation.name = "InventoryConfirm"
	_confirmation.configure(item, kind, anchor, rotated)
	_confirmation.accepted.connect(_commit_confirmation)
	_confirmation.cancelled.connect(_cancel_confirmation)
	_confirmation.danger_close_requested.connect(danger_close)
	add_child(_confirmation)
	_pending_source_widget(kind).show_pending_source(item.uid, kind)
	_refresh_s04_controls(item)


func _cancel_confirmation() -> void:
	if _confirmation == null:
		return
	_confirmation.queue_free()
	_confirmation = null
	_pending_confirmation.clear()
	_withdraw_targeting = false
	_clear_pending_confirmation_presentation()
	_refresh_grid_markers()


func _commit_confirmation() -> void:
	if _confirmation == null:
		return
	var kind := _pending_confirmation.get("kind", &"") as StringName
	var uid := int(_pending_confirmation.get("uid", 0))
	var anchor := _pending_confirmation.get("anchor", Vector2i.ZERO) as Vector2i
	var rotated := bool(_pending_confirmation.get("rotated", false))
	var result := inventory.commit_withdraw(uid, anchor, rotated) if kind == &"withdraw" else inventory.commit_drop(uid)
	_confirmation.queue_free()
	_confirmation = null
	_pending_confirmation.clear()
	_withdraw_targeting = false
	_clear_pending_confirmation_presentation()
	if not result.ok:
		_show_preview(result, RetrieverInventory.BACKPACK, anchor)
		return
	if kind == &"withdraw":
		item_withdraw_confirmed.emit(uid, anchor)
	else:
		item_drop_confirmed.emit(uid)
	selected_uid = 0
	pending_rotated = false
	_refresh_grid_markers()


func _pending_source_widget(kind: StringName) -> InventoryGridWidget:
	return _notary_box if kind == &"withdraw" else _backpack


func _clear_pending_confirmation_presentation() -> void:
	if _backpack != null:
		_backpack.clear_pending_source()
	if _notary_box != null:
		_notary_box.clear_pending_source()


func _label(node_name: String, key: StringName, font_size: int) -> Label:
	return _static_label(node_name, tr(key), font_size)


func _static_label(node_name: String, value: String, font_size: int) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _anchor_top_right(control: Control, right_inset: float, top: float, dimensions: Vector2) -> void:
	control.anchor_left = 1.0
	control.anchor_top = 0.0
	control.anchor_right = 1.0
	control.anchor_bottom = 0.0
	control.offset_left = -right_inset - dimensions.x
	control.offset_top = top
	control.offset_right = -right_inset
	control.offset_bottom = top + dimensions.y


func _button(node_name: String, key: StringName) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = tr(key)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 24)
	return button
