class_name BriefingScreen
extends Control
## Signals for the external flow controller (TASK-75):
## - loadout_requested(inventory): show O1 using this exact inventory instance.
## - enter_outer_pier_requested(inventory): emitted once only after validate() is empty.
## - back_requested(): return to Boot without mutating inventory.

signal loadout_requested(inventory: RetrieverInventory)
signal enter_outer_pier_requested(inventory: RetrieverInventory)
signal back_requested()

const UI_OPEN_GUARD_SECONDS := 0.3

static var _tooltip_seen_this_session := false

var inventory: RetrieverInventory
var _enter_button: Button
var _tooltip: Button
var _status: Label
var _is_loading := false
var _scene_load_error := false
var _opened_at_msec := 0


func _ready() -> void:
	theme = UiTheme.create()
	if inventory == null:
		inventory = StarterInventoryFactory.create()
	_build()
	refresh()


func open_with_inventory(p_inventory: RetrieverInventory) -> void:
	inventory = p_inventory
	if is_inside_tree():
		_build()
		refresh()


func request_loadout() -> void:
	if _is_loading:
		return
	_scene_load_error = false
	_tooltip.visible = false
	_tooltip_seen_this_session = true
	loadout_requested.emit(inventory)


func request_enter() -> void:
	if _is_loading:
		return
	_scene_load_error = false
	var errors := inventory.validate()
	if not errors.is_empty():
		_show_invalid(errors[0])
		return
	_is_loading = true
	_status.text = ""
	_enter_button.text = tr("UI_LOADING")
	enter_outer_pier_requested.emit(inventory)


func request_back() -> void:
	if not _is_loading:
		back_requested.emit()


func show_scene_load_error() -> void:
	_is_loading = false
	_scene_load_error = true
	refresh()


func refresh() -> void:
	if _enter_button == null:
		return
	var errors := inventory.validate()
	_enter_button.disabled = not errors.is_empty() or _is_loading
	if not errors.is_empty():
		_show_invalid(errors[0])
	elif _scene_load_error:
		_status.text = tr("UI_ERROR_SCENE_LOAD")
		_enter_button.text = tr("BRIEFING_BUTTON_ENTER")
	elif not _is_loading:
		_status.text = ""
		_enter_button.text = tr("BRIEFING_BUTTON_ENTER")


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and not _input_guard_active():
		request_back()
		accept_event()


func _build() -> void:
	for child in get_children():
		child.queue_free()
	var background := ColorRect.new()
	background.color = UiTheme.PAPER
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var title := _label("Title", "BRIEFING_HEADER_TITLE", 32)
	title.position = Vector2(32, 32)
	title.size = Vector2(688, 64)
	add_child(title)
	var objective := _label("Objective", "BRIEFING_OBJECTIVE_MAIN", 22)
	objective.position = Vector2(32, 104)
	objective.size = Vector2(688, 72)
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(objective)
	var rules := _label("Rules", "BRIEFING_RULES_LINE", 20)
	rules.position = Vector2(32, 184)
	rules.size = Vector2(616, 56)
	rules.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(rules)
	var info := _button("InfoButton", "ⓘ", Vector2(656, 176), Vector2(64, 64))
	info.pressed.connect(_on_info_pressed)
	_tooltip = Button.new()
	_tooltip.name = "Tooltip"
	_tooltip.text = tr("BRIEFING_TOOLTIP_UNSEALED_LOSS")
	_tooltip.flat = true
	_tooltip.focus_mode = Control.FOCUS_ALL
	_tooltip.add_theme_font_size_override("font_size", 20)
	_tooltip.add_theme_color_override("font_color", UiTheme.INK)
	_tooltip.position = Vector2(32, 248)
	_tooltip.size = Vector2(688, 72)
	_tooltip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tooltip.visible = not _tooltip_seen_this_session
	_tooltip.pressed.connect(_on_tooltip_pressed)
	add_child(_tooltip)
	var speaker := _label("MentorSpeaker", "BRIEFING_MENTOR_SPEAKER", 20)
	speaker.position = Vector2(32, 408)
	speaker.size = Vector2(688, 32)
	add_child(speaker)
	var mentor_line := _label("MentorLine", "BRIEFING_MENTOR_LINE", 20)
	mentor_line.position = Vector2(32, 444)
	mentor_line.size = Vector2(688, 112)
	mentor_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(mentor_line)
	var summary := _label("LoadoutSummary", "LOADOUT_SUMMARY_DEFAULT_KIT", 20)
	summary.position = Vector2(752, 32)
	summary.size = Vector2(496, 168)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(summary)
	_add_preview_grid("BackpackPreview", "LOADOUT_LABEL_BACKPACK", RetrieverInventory.BACKPACK, Vector2(752, 240), 0.5)
	_add_preview_grid("NotaryPreview", "LOADOUT_LABEL_NOTARY_BOX", RetrieverInventory.NOTARY_BOX, Vector2(928, 240), 0.5)
	_add_preview_grid("SlingPreview", "LOADOUT_LABEL_SLING_POUCH", RetrieverInventory.SLING_POUCH, Vector2(1088, 240), 0.5)
	var edit := _button("EditLoadoutButton", "BRIEFING_BUTTON_EDIT_LOADOUT", Vector2(928, 480), Vector2(320, 96))
	edit.pressed.connect(_on_loadout_pressed)
	var back := _button("BackButton", "BRIEFING_BUTTON_BACK", Vector2(32, 600), Vector2(240, 96))
	back.pressed.connect(_on_back_pressed)
	_enter_button = _button("EnterButton", "BRIEFING_BUTTON_ENTER", Vector2(968, 600), Vector2(280, 96))
	_enter_button.pressed.connect(_on_enter_pressed)
	_status = _label("Status", "", 20)
	_status.position = Vector2(752, 552)
	_status.size = Vector2(496, 40)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_status)
	_opened_at_msec = Time.get_ticks_msec()


func _add_preview_grid(node_name: String, label_key: String, kind: StringName, at: Vector2, scale: float) -> void:
	var label := _label(node_name + "Label", label_key, 20)
	label.position = at
	label.size = Vector2(156, 28)
	add_child(label)
	var grid := InventoryGridWidget.new()
	grid.name = node_name
	grid.position = at + Vector2(0, 32)
	grid.configure(inventory, kind, true, scale)
	add_child(grid)
	var touch := Button.new()
	touch.name = node_name + "Touch"
	touch.position = at
	touch.size = Vector2(156, 216)
	touch.flat = true
	touch.text = ""
	touch.pressed.connect(_on_loadout_pressed)
	add_child(touch)


func _toggle_tooltip() -> void:
	_tooltip.visible = not _tooltip.visible
	_tooltip_seen_this_session = true


func _on_info_pressed() -> void:
	if not _input_guard_active():
		_toggle_tooltip()


func _on_tooltip_pressed() -> void:
	if not _input_guard_active() and _tooltip.visible:
		_toggle_tooltip()


func _on_loadout_pressed() -> void:
	if not _input_guard_active():
		request_loadout()


func _on_back_pressed() -> void:
	if not _input_guard_active():
		request_back()


func _on_enter_pressed() -> void:
	if not _input_guard_active():
		request_enter()


func _input_guard_active() -> bool:
	return Time.get_ticks_msec() - _opened_at_msec < int(UI_OPEN_GUARD_SECONDS * 1000.0)


func _show_invalid(error: InventoryResult) -> void:
	var item_name := _invalid_item_name(error.uid)
	_status.text = "%s · %s · %s" % [tr("BRIEFING_BUTTON_ENTER_BLOCKED"), item_name, _reason_text(error.reason)]


func _invalid_item_name(uid: int) -> String:
	for grid: InventoryGrid in [inventory.backpack, inventory.notary_box, inventory.sling_pouch]:
		var item := grid.items.get(uid) as ItemInstance
		if item != null:
			return item.definition.localized_display_name()
	return ""


func _reason_text(reason: InventoryReason.Value) -> String:
	return tr("INVENTORY_REASON_" + InventoryReason.Value.keys()[int(reason)])


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
