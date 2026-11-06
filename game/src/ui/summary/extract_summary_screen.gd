class_name ExtractSummaryScreen
extends Control
## S10 projection of ExtractSummary. Navigation is intentionally emitted to the
## owning scene; this screen never saves or changes the extract result.

signal hub_requested()

const UI_OPEN_GUARD_SECONDS := 0.3

var summary: ExtractSummary
var registry: ItemRegistry
var _opened_at_msec := 0
var _hub_locked := false


func _ready() -> void:
	theme = UiTheme.create()
	if summary != null:
		_build()


func show_summary(p_summary: ExtractSummary, p_registry: ItemRegistry) -> void:
	summary = p_summary
	registry = p_registry
	_hub_locked = false
	if is_inside_tree():
		_build()


func request_hub() -> void:
	if _hub_locked or _input_guard_active():
		return
	_hub_locked = true
	var button := get_node_or_null("HubButton") as Button
	if button != null:
		button.disabled = true
		button.text = tr("UI_LOADING")
	hub_requested.emit()


func show_scene_load_error() -> void:
	_hub_locked = false
	var button := get_node_or_null("HubButton") as Button
	if button != null:
		button.disabled = false
		button.text = tr("SUMMARY_BUTTON_HUB")
	var status := get_node_or_null("Status") as Label
	if status != null:
		status.text = tr("UI_ERROR_SCENE_LOAD")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		request_hub()
		get_viewport().set_input_as_handled()


func _build() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var background := ColorRect.new()
	background.color = UiTheme.PAPER
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var title := _label("Title", &"SUMMARY_SUCCESS_TITLE", 32)
	title.position = Vector2(368, 32)
	title.size = Vector2(544, 56)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	var left := VBoxContainer.new()
	left.name = "LeftGroups"
	left.position = Vector2(32, 112)
	left.size = Vector2(592, 464)
	left.add_theme_constant_override("separation", 12)
	add_child(left)
	_add_group(left, "KeptGroup", &"SUMMARY_GROUP_KEPT", _kept_lines())
	if not summary.lost.is_empty():
		_add_group(left, "LostGroup", &"SUMMARY_GROUP_LOST", _lost_lines())
	var right := VBoxContainer.new()
	right.name = "RightGroups"
	right.position = Vector2(656, 112)
	right.size = Vector2(592, 464)
	right.add_theme_constant_override("separation", 12)
	add_child(right)
	_add_group(right, "EvidenceGroup", &"SUMMARY_GROUP_EVIDENCE", _evidence_lines())
	_add_next_group(right)
	var mentor := _label("MentorLine", &"SUMMARY_SUCCESS_MENTOR_LINE", 20)
	mentor.position = Vector2(32, 584)
	mentor.size = Vector2(760, 56)
	mentor.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(mentor)
	var status := _label("Status", &"", 20)
	status.position = Vector2(800, 584)
	status.size = Vector2(152, 48)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(status)
	var hub := _button("HubButton", &"SUMMARY_BUTTON_HUB", Vector2(968, 600), Vector2(280, 96))
	hub.pressed.connect(_on_hub_pressed)
	add_child(hub)
	_opened_at_msec = Time.get_ticks_msec()


func _add_group(parent: Container, node_name: String, title_key: StringName, lines: Array[String]) -> void:
	var panel := PanelContainer.new()
	panel.name = node_name
	panel.custom_minimum_size = Vector2(0, 88)
	parent.add_child(panel)
	var content := VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 4)
	panel.add_child(content)
	var heading := _label("Heading", title_key, 24)
	content.add_child(heading)
	for index in lines.size():
		var line := Label.new()
		line.name = "Line%d" % index
		line.text = lines[index]
		line.add_theme_font_size_override("font_size", 20)
		line.add_theme_color_override("font_color", UiTheme.INK)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_child(line)


func _add_next_group(parent: Container) -> void:
	var panel := PanelContainer.new()
	panel.name = "NextGroup"
	panel.custom_minimum_size = Vector2(0, 112)
	parent.add_child(panel)
	var content := VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 4)
	panel.add_child(content)
	content.add_child(_label("Heading", &"SUMMARY_GROUP_NEXT", 24))
	var contract := _label("Contract2", &"SUMMARY_NEXT_CONTRACT2_TITLE", 20)
	content.add_child(contract)
	var tag := _label("Contract2Locked", &"SUMMARY_NEXT_CONTRACT2_TAG", 20)
	content.add_child(tag)


func _kept_lines() -> Array[String]:
	var lines: Array[String] = [tr("SUMMARY_SUCCESS_KEPT_LICENCE")]
	for entry: Dictionary in summary.kept:
		lines.append(_item_name(StringName(entry.get("def_id", &""))))
	lines.append(tr("SUMMARY_SUCCESS_KEPT_CELLS").format({
		"used": summary.backpack_cells_used,
		"total": summary.backpack_cells_total,
	}))
	return lines


func _lost_lines() -> Array[String]:
	var lines: Array[String] = []
	for entry: Dictionary in summary.lost:
		lines.append(_item_name(StringName(entry.get("def_id", &""))))
		lines.append(tr("SUMMARY_SUCCESS_LOST_LEFT_BEHIND"))
	return lines


func _evidence_lines() -> Array[String]:
	var lines: Array[String] = []
	for def_id: StringName in summary.evidence:
		if def_id == &"manifest_r17":
			lines.append(tr("SUMMARY_SUCCESS_EVIDENCE_MANIFEST"))
			lines.append(tr("SUMMARY_SUCCESS_EVIDENCE_LIMIT"))
			lines.append(tr("SUMMARY_SUCCESS_EVIDENCE_LEAD"))
			continue
		var definition := registry.get_def(def_id) if registry != null else null
		if definition != null:
			lines.append(definition.localized_display_name())
	return lines


func _item_name(def_id: StringName) -> String:
	if registry != null:
		var definition := registry.get_def(def_id)
		if definition != null:
			return definition.localized_display_name()
	return tr("CARD_MANIFEST_R17_NAME") if def_id == &"manifest_r17" else tr("ITEM_STARTER_REMEDY_NAME")


func _input_guard_active() -> bool:
	return Time.get_ticks_msec() - _opened_at_msec < int(UI_OPEN_GUARD_SECONDS * 1000.0)


func _on_hub_pressed() -> void:
	request_hub()


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
