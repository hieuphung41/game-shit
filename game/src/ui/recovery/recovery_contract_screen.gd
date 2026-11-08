class_name RecoveryContractScreen
extends Control
## S12 read-only handoff between an actual S11 after-Manifest death and recovery S1.

signal briefing_requested()

const UI_OPEN_GUARD_SECONDS := 0.3

var _opened_at_msec := 0


func _ready() -> void:
	theme = UiTheme.create()
	_build()
	_opened_at_msec = Time.get_ticks_msec()


func request_briefing() -> void:
	if Time.get_ticks_msec() - _opened_at_msec < int(UI_OPEN_GUARD_SECONDS * 1000.0):
		return
	briefing_requested.emit()


func _build() -> void:
	var background := ColorRect.new()
	background.name = "Background"
	background.color = UiTheme.PAPER
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var title := _label("Title", &"RECOVERY_HEADER_TITLE", 32)
	title.position = Vector2(160, 112)
	title.size = Vector2(960, 72)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	var y := 232.0
	var keys: Array[StringName] = [&"RECOVERY_BODY_LOCATION", &"RECOVERY_BODY_RULE", &"RECOVERY_BODY_KIT"]
	for index in keys.size():
		var body := _label("Body%d" % index, keys[index], 22)
		body.position = Vector2(224, y)
		body.size = Vector2(832, 72)
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(body)
		y += 88.0
	var action := Button.new()
	action.name = "BriefingButton"
	action.text = tr(&"RECOVERY_BUTTON_BRIEFING")
	action.position = Vector2(440, 568)
	action.size = Vector2(400, 96)
	action.focus_mode = Control.FOCUS_ALL
	action.add_theme_font_size_override("font_size", 24)
	action.pressed.connect(request_briefing)
	add_child(action)
	action.grab_focus()


func _label(node_name: String, key: StringName, font_size: int) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = tr(key)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", UiTheme.INK)
	return label
