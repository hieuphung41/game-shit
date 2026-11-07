class_name RecallSigilOverlay
extends Control
## O7 only presents the configured pause. It emits completion and never changes
## health, inventory, or flow state.

signal completed()

const RECALL_SIGIL_SECONDS := 2.5

var _elapsed_seconds := 0.0
var _completed := false
var _application_active := true


func _ready() -> void:
	theme = UiTheme.create()
	_build()


func finish_now() -> void:
	if _completed:
		return
	_completed = true
	completed.emit()


func _process(delta: float) -> void:
	# _process does not run while Godot pauses in the background, so the O7
	# interval measures only foreground time. The notification guard also rejects
	# a large catch-up delta delivered on Web/Android after focus returns.
	if _application_active:
		_elapsed_seconds += maxf(delta, 0.0)
	var progress := clampf(_elapsed_seconds / RECALL_SIGIL_SECONDS, 0.0, 1.0)
	var ring := get_node_or_null("Sigil/Ring") as ProgressBar
	if ring != null:
		ring.value = progress * 100.0
	if progress >= 1.0:
		finish_now()


func _input(event: InputEvent) -> void:
	# O7 intentionally absorbs every device while the depleted flow settles.
	get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_application_active = false
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_application_active = true


func _build() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dimmer := ColorRect.new()
	dimmer.name = "Dimmer"
	dimmer.color = UiTheme.INK.darkened(0.2)
	dimmer.modulate.a = 0.72
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dimmer)
	var sigil := PanelContainer.new()
	sigil.name = "Sigil"
	sigil.position = Vector2(368, 248)
	sigil.size = Vector2(544, 224)
	sigil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sigil)
	var mark := Label.new()
	mark.name = "Mark"
	mark.text = "◎"
	mark.position = Vector2(232, 20)
	mark.size = Vector2(80, 80)
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mark.add_theme_font_size_override("font_size", 64)
	mark.add_theme_color_override("font_color", UiTheme.STAMP_RED)
	sigil.add_child(mark)
	var ring := ProgressBar.new()
	ring.name = "Ring"
	ring.position = Vector2(176, 100)
	ring.size = Vector2(192, 12)
	ring.max_value = 100.0
	ring.show_percentage = false
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.add_theme_stylebox_override("background", _bar_style(UiTheme.MUTED))
	ring.add_theme_stylebox_override("fill", _bar_style(UiTheme.STAMP_RED))
	sigil.add_child(ring)
	var line := Label.new()
	line.name = "MomentLine"
	line.text = tr(&"RECALL_SIGIL_MOMENT_LINE")
	line.position = Vector2(32, 136)
	line.size = Vector2(480, 56)
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	line.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.add_theme_font_size_override("font_size", 24)
	line.add_theme_color_override("font_color", UiTheme.INK)
	sigil.add_child(line)
	_elapsed_seconds = 0.0
	_application_active = true


func _bar_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(6)
	return style
