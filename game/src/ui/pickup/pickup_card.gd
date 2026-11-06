class_name ManifestPickupCard
extends Control
## O2 card. It presents the Manifest only and leaves placement to its parent.

signal pickup_requested()
signal closed()
signal skipped()

const UI_OPEN_GUARD_SECONDS := 0.3

var _opened_at_msec := 0


func _ready() -> void:
	theme = UiTheme.create()
	_build()
	_opened_at_msec = Time.get_ticks_msec()


func request_pickup() -> void:
	if not _input_guard_active():
		pickup_requested.emit()


func close() -> void:
	if not _input_guard_active():
		closed.emit()


func skip() -> void:
	if not _input_guard_active():
		skipped.emit()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and not _input_guard_active():
		closed.emit()
		accept_event()


func _build() -> void:
	var panel := Panel.new()
	panel.name = "CardPanel"
	panel.position = Vector2(680, 128)
	panel.size = Vector2(584, 576)
	add_child(panel)
	var badge := _label("EvidenceBadge", "CARD_MANIFEST_R17_STATE_NOT_EXTRACTED", 20)
	badge.position = Vector2(340, 20)
	badge.size = Vector2(224, 48)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	panel.add_child(badge)
	var keys: Array[StringName] = [
		&"CARD_MANIFEST_R17_NAME",
		&"CARD_MANIFEST_R17_FOOTPRINT",
		&"CARD_MANIFEST_R17_USE",
		&"CARD_MANIFEST_R17_CLAIM",
		&"CARD_MANIFEST_R17_RARITY",
		&"CARD_MANIFEST_R17_LORE",
	]
	var y := 76.0
	for index in keys.size():
		var row := _label("Detail%d" % index, keys[index], 24)
		row.position = Vector2(24, y)
		row.size = Vector2(536, 58)
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		panel.add_child(row)
		y += 60.0
	var close_button := _button("CloseButton", "CARD_ACTION_CLOSE", Vector2(24, 456), Vector2(200, 96))
	close_button.pressed.connect(_on_close_pressed)
	panel.add_child(close_button)
	var skip_button := _button("SkipButton", "CARD_ACTION_SKIP", Vector2(224, 456), Vector2(72, 96))
	skip_button.pressed.connect(_on_skip_pressed)
	panel.add_child(skip_button)
	var pickup_button := _button("PickAndPlaceButton", "CARD_ACTION_PICK_AND_PLACE", Vector2(296, 456), Vector2(264, 96))
	pickup_button.pressed.connect(_on_pickup_pressed)
	panel.add_child(pickup_button)


func _input_guard_active() -> bool:
	return Time.get_ticks_msec() - _opened_at_msec < int(UI_OPEN_GUARD_SECONDS * 1000.0)


func _on_pickup_pressed() -> void:
	request_pickup()


func _on_close_pressed() -> void:
	close()


func _on_skip_pressed() -> void:
	skip()


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
