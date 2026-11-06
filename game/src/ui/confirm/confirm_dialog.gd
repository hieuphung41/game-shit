class_name ConfirmDialog
extends Control
## Reusable O5 decision dialog. It exposes intent through signals and does not
## invoke gameplay state directly.

signal accepted()
signal cancelled()

const UI_OPEN_GUARD_SECONDS := 0.3

var _opened_at_msec := 0
var _title_key: StringName = &"EXTRACT_CONFIRM_TITLE"
var _body_key: StringName = &"EXTRACT_CONFIRM_BODY"
var _accept_key: StringName = &"EXTRACT_CONFIRM_ACCEPT"
var _cancel_key: StringName = &"EXTRACT_CONFIRM_CANCEL"
var _body_values: Dictionary = {"seconds": int(ExtractPierAFlow.EXTRACT_HOLD_SECONDS)}


func _ready() -> void:
	theme = UiTheme.create()
	_build()


func configure(title_key: StringName, body_key: StringName, accept_key: StringName, cancel_key: StringName, body_values: Dictionary = {}) -> void:
	_title_key = title_key
	_body_key = body_key
	_accept_key = accept_key
	_cancel_key = cancel_key
	_body_values = body_values.duplicate(true)
	if is_inside_tree():
		_build()


func confirm() -> void:
	if not _input_guard_active():
		accepted.emit()


func cancel() -> void:
	if not _input_guard_active():
		cancelled.emit()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and not _input_guard_active():
		cancelled.emit()
		accept_event()


func _build() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var panel := Panel.new()
	panel.name = "ConfirmPanel"
	panel.position = Vector2(368, 192)
	panel.size = Vector2(544, 336)
	add_child(panel)
	var title := _label("Title", _title_key, 28)
	title.position = Vector2(24, 24)
	title.size = Vector2(496, 56)
	panel.add_child(title)
	var body := _label("Body", _body_key, 24)
	body.text = tr(_body_key).format(_body_values)
	body.position = Vector2(24, 92)
	body.size = Vector2(496, 188)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(body)
	var cancel_button := _button("CancelButton", _cancel_key, Vector2(32, 216), Vector2(200, 96))
	cancel_button.pressed.connect(_on_cancel_pressed)
	panel.add_child(cancel_button)
	var accept_button := _button("AcceptButton", _accept_key, Vector2(312, 216), Vector2(200, 96))
	accept_button.pressed.connect(_on_accept_pressed)
	panel.add_child(accept_button)
	_opened_at_msec = Time.get_ticks_msec()


func _input_guard_active() -> bool:
	return Time.get_ticks_msec() - _opened_at_msec < int(UI_OPEN_GUARD_SECONDS * 1000.0)


func _on_accept_pressed() -> void:
	confirm()


func _on_cancel_pressed() -> void:
	cancel()


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
