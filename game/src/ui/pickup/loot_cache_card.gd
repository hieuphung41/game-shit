class_name LootCacheCard
extends Control
## O2B presentation only. Its shape markers make claim, appraisal class and
## footprint distinguishable without relying on palette colour.

signal item_selected(index: int)
signal pickup_requested(item: ItemInstance)
signal skipped(item: ItemInstance)
signal closed

var inventory: RetrieverInventory
var cache: LootCache
var selected_index := 0
var _details: VBoxContainer

const CARD_DOCK_RIGHT_INSET := 16.0
const CARD_DOCK_TOP := 120.0
const CARD_DOCK_SIZE := Vector2(560, 584)
const CLOSE_BUTTON_TOP := 16.0
const CLOSE_BUTTON_SIZE := Vector2(96, 96)


func _ready() -> void:
	theme = UiTheme.create()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Only the dock controls receive pointer input; the full-screen card root must
	# leave the exposed R6 joystick available while the card is open.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if inventory != null and cache != null:
		_build()


func configure(p_inventory: RetrieverInventory, p_cache: LootCache) -> void:
	inventory = p_inventory
	cache = p_cache
	selected_index = 0
	if is_inside_tree():
		_build()


func select_item(index: int) -> void:
	if cache == null or cache.item_at(index) == null:
		return
	selected_index = index
	_render_details()
	item_selected.emit(index)


func request_pickup() -> void:
	var item := _selected_item()
	if item != null:
		pickup_requested.emit(item)


func skip() -> void:
	var item := _selected_item()
	if item != null:
		skipped.emit(item)


func _build() -> void:
	for child in get_children():
		child.queue_free()
	var panel := PanelContainer.new()
	panel.name = "CacheCardPanel"
	_anchor_top_right(panel, CARD_DOCK_RIGHT_INSET, CARD_DOCK_TOP, CARD_DOCK_SIZE)
	add_child(panel)
	var rows := VBoxContainer.new()
	rows.name = "Rows"
	rows.add_theme_constant_override("separation", 6)
	panel.add_child(rows)
	var chips := HBoxContainer.new()
	chips.name = "ItemChips"
	chips.custom_minimum_size = Vector2(0, 96)
	rows.add_child(chips)
	for index in cache.ordered_items().size():
		var item := cache.item_at(index)
		var chip := Button.new()
		chip.name = "ItemChip_%d" % index
		chip.custom_minimum_size = Vector2(256, 96)
		chip.text = _chip_text(item, index)
		chip.add_theme_font_size_override("font_size", 24)
		chip.pressed.connect(select_item.bind(index))
		chips.add_child(chip)
	_details = VBoxContainer.new()
	_details.name = "Details"
	_details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rows.add_child(_details)
	var actions := HBoxContainer.new()
	actions.name = "Actions"
	actions.custom_minimum_size = Vector2(0, 96)
	rows.add_child(actions)
	var skip_button := _button("SkipButton", &"CARD_ACTION_SKIP")
	skip_button.custom_minimum_size = Vector2(184, 96)
	skip_button.pressed.connect(skip)
	actions.add_child(skip_button)
	var pickup_button := _button("PickAndPlaceButton", &"CARD_ACTION_PICK_AND_PLACE")
	pickup_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pickup_button.pressed.connect(request_pickup)
	actions.add_child(pickup_button)
	var close_button := _button("CloseButton", &"CARD_ACTION_CLOSE")
	_anchor_top_right(close_button, CARD_DOCK_RIGHT_INSET, CLOSE_BUTTON_TOP, CLOSE_BUTTON_SIZE)
	add_child(close_button)
	close_button.pressed.connect(func() -> void: closed.emit())
	_render_details()


func _render_details() -> void:
	if _details == null:
		return
	var chips := get_node_or_null("CacheCardPanel/Rows/ItemChips") as HBoxContainer
	if chips != null:
		for index in chips.get_child_count():
			var chip := chips.get_child(index) as Button
			var chip_item := cache.item_at(index)
			if chip != null and chip_item != null:
				chip.text = _chip_text(chip_item, index)
	for child in _details.get_children():
		_details.remove_child(child)
		child.queue_free()
	var item := _selected_item()
	if item == null:
		return
	var definition := item.definition
	_add_detail("NameCue", "■ " + definition.localized_display_name() + _quantity(item))
	_add_detail("FootprintCue", _footprint_cue(definition) + " " + tr(_card_key(definition, "FOOTPRINT")) + "\n" + _fit_text(item))
	_add_detail("Use", tr(_card_key(definition, "USE")))
	_add_detail("ClaimCue", "⚑ " + tr(_card_key(definition, "CLAIM")))
	_add_detail("RarityCue", _rarity_marks(definition.appraisal_class) + " " + tr(_card_key(definition, "RARITY")))
	_add_detail("Lore", tr(definition.lore_key))


func _add_detail(node_name: String, value: String) -> void:
	var label := Label.new()
	label.name = node_name
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(0, 38)
	label.add_theme_font_size_override("font_size", 24)
	_details.add_child(label)


func _fit_text(item: ItemInstance) -> String:
	var backpack_key: StringName = _fit_key(item, RetrieverInventory.BACKPACK, "CARD_FIT_BACKPACK")
	var box_key: StringName = &"CARD_FIT_NOTARY_BOX_NOT_SEALABLE" if not item.definition.sealable else _fit_key(item, RetrieverInventory.NOTARY_BOX, "CARD_FIT_NOTARY_BOX")
	return "▣ " + tr("CARD_BACKPACK_FREE").format({"free": inventory.backpack.free_cell_count(), "total": 12}) + " · ✓ " + tr(backpack_key) + " · □ " + tr(box_key)


func _fit_key(item: ItemInstance, target: StringName, prefix: String) -> StringName:
	var normal := _has_fit(item, target, false)
	if normal:
		return StringName(prefix + "_FITS")
	var rotated := item.definition.rotatable and not item.definition.is_square() and _has_fit(item, target, true)
	if rotated and target == RetrieverInventory.BACKPACK:
		return &"CARD_FIT_BACKPACK_ROTATED_ONLY"
	return StringName(prefix + "_NO_FIT")


func _has_fit(item: ItemInstance, target: StringName, rotated: bool) -> bool:
	var grid := inventory.backpack if target == RetrieverInventory.BACKPACK else inventory.notary_box
	for y in grid.size.y:
		for x in grid.size.x:
			if inventory.preview_pickup(item, target, Vector2i(x, y), rotated).ok:
				return true
	return false


func _selected_item() -> ItemInstance:
	return cache.item_at(selected_index) if cache != null else null


func _card_key(definition: ItemDef, suffix: String) -> StringName:
	return StringName("CARD_" + str(definition.id).to_upper() + "_" + suffix)


func _quantity(item: ItemInstance) -> String:
	return tr("CARD_QUANTITY_SUFFIX").format({"quantity": item.quantity}) if item.quantity > 1 else ""


func _chip_text(item: ItemInstance, index: int) -> String:
	var selected_marker := "▼ " if index == selected_index else "□ "
	return selected_marker + tr("INVENTORY_FOOTPRINT_CHIP").format({
		"w": item.definition.size.x,
		"h": item.definition.size.y,
	}) + _quantity(item)


func _footprint_cue(definition: ItemDef) -> String:
	var result := ""
	for _y in definition.size.y:
		for _x in definition.size.x:
			result += "□"
	if definition.rotatable and not definition.is_square():
		result += " ↻ " + tr("CARD_TAG_ROTATABLE")
	if definition.stackable:
		result += " ≡ " + tr("CARD_TAG_STACKABLE")
	if definition.sealable:
		result += " ▣ " + tr("CARD_TAG_SEALABLE")
	return result


func _rarity_marks(value: int) -> String:
	return "●".repeat(value) + "○".repeat(6 - value)


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
