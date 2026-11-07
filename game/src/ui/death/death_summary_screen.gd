class_name DeathSummaryScreen
extends Control
## S11 is a projection of DeathSummary. The owner decides whether the primary
## request returns to S1 or Boot; this screen only emits the selected intent.

signal prepare_requested()
signal boot_requested()

const UI_OPEN_GUARD_SECONDS := 0.3
const SUMMARY_DEATH_BUTTON_LOCK_SECONDS := 1.0

var summary: DeathSummary
var registry: ItemRegistry
var _elapsed_seconds := 0.0
var _primary_locked := false
var _primary_sent := false
var _application_active := true
var _primary_status_key: StringName = &""


func _ready() -> void:
	theme = UiTheme.create()
	_build()


func show_summary(p_summary: DeathSummary, p_registry: ItemRegistry) -> void:
	summary = p_summary
	registry = p_registry
	_primary_locked = false
	_primary_sent = false
	_primary_status_key = &""
	if is_inside_tree():
		_build()


func request_primary() -> void:
	if _primary_sent or _button_lock_active() or _input_guard_active():
		return
	_primary_sent = true
	var button := get_node_or_null("PrimaryButton") as Button
	if button != null:
		button.disabled = true
		_primary_status_key = &"UI_LOADING"
		_refresh_primary_presentation(button)
	if _is_after_manifest():
		boot_requested.emit()
	else:
		prepare_requested.emit()


func show_scene_load_error() -> void:
	_primary_sent = false
	var button := get_node_or_null("PrimaryButton") as Button
	if button != null:
		button.disabled = false
		_primary_status_key = &"UI_ERROR_SCENE_LOAD"
		_refresh_primary_presentation(button)


func _process(delta: float) -> void:
	# Notification state rejects a catch-up delta after Web/Android refocus.
	if _application_active:
		_elapsed_seconds += maxf(delta, 0.0)
	var lock_progress := clampf(_elapsed_seconds / SUMMARY_DEATH_BUTTON_LOCK_SECONDS, 0.0, 1.0)
	_primary_locked = lock_progress < 1.0
	var progress := get_node_or_null("PrimaryButton/LockProgress") as ProgressBar
	if progress != null:
		progress.value = lock_progress * 100.0
		progress.visible = _primary_locked
	var primary := get_node_or_null("PrimaryButton") as Button
	if primary != null:
		_refresh_primary_presentation(primary)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		request_primary()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"ui_accept"):
		var primary := get_node_or_null("PrimaryButton") as Button
		if primary != null and get_viewport().gui_get_focus_owner() == primary:
			request_primary()
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"ui_up") or event.is_action_pressed(&"ui_down"):
		var focus_owner := get_viewport().gui_get_focus_owner()
		if focus_owner != null and focus_owner.name.ends_with("ScrollFrame"):
			var scroll_name := String(focus_owner.name).trim_suffix("Frame")
			var scroll := get_node_or_null(scroll_name) as ScrollContainer
			if scroll != null:
				var direction := -1 if event.is_action_pressed(&"ui_up") else 1
				scroll.scroll_vertical = clampi(scroll.scroll_vertical + direction * 64, 0, int(scroll.get_v_scroll_bar().max_value))
				get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_application_active = false
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_application_active = true


func _build() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var background := ColorRect.new()
	background.name = "Background"
	background.color = UiTheme.PAPER
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var sigil := _label("SigilMark", &"", 48)
	sigil.text = "◎"
	sigil.position = Vector2(32, 24)
	sigil.size = Vector2(56, 72)
	sigil.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sigil.add_theme_color_override("font_color", UiTheme.STAMP_RED)
	add_child(sigil)
	var title := _label("Title", &"SUMMARY_DEATH_TITLE", 32)
	title.position = Vector2(96, 24)
	title.size = Vector2(736, 72)
	add_child(title)
	var kept_entries := _safe_summary().kept
	var columns := _column_layout(not kept_entries.is_empty())
	if not kept_entries.is_empty():
		_add_column("KeptScroll", columns[0], &"SUMMARY_GROUP_KEPT", _kept_lines())
	_add_column("LostScroll", columns[1], &"SUMMARY_GROUP_LOST", _lost_lines())
	var evidence_key: StringName = &"SUMMARY_DEATH_GROUP_EVIDENCE_UNRECOVERED" if _is_after_manifest() else &"SUMMARY_GROUP_EVIDENCE"
	_add_column("EvidenceScroll", columns[2], evidence_key, _evidence_lines())
	if _is_after_manifest():
		var recovery := _label("RecoveryLine", &"SUMMARY_DEATH_RECOVERY_UNAVAILABLE", 20)
		recovery.position = Vector2(32, 552)
		recovery.size = Vector2(1216, 40)
		recovery.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		recovery.add_theme_color_override("font_color", UiTheme.MUTED)
		add_child(recovery)
	var primary := _button("PrimaryButton", _primary_key(), Vector2(440, 608), Vector2(400, 96))
	primary.pressed.connect(request_primary)
	_add_lock_feedback(primary)
	add_child(primary)
	_focus_columns(primary, not kept_entries.is_empty())
	_elapsed_seconds = 0.0
	_application_active = true
	_primary_locked = true
	_refresh_primary_presentation(primary)


func _column_layout(has_kept: bool) -> Array[Rect2]:
	if has_kept:
		return [Rect2(32, 112, 384, 432), Rect2(448, 112, 384, 432), Rect2(864, 112, 384, 432)]
	return [Rect2(), Rect2(32, 112, 592, 432), Rect2(656, 112, 592, 432)]


func _add_column(node_name: String, rect: Rect2, title_key: StringName, lines: Array[String]) -> void:
	var panel := PanelContainer.new()
	panel.name = "%sFrame" % node_name
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.focus_mode = Control.FOCUS_ALL
	add_child(panel)
	var scroll := ScrollContainer.new()
	scroll.name = node_name
	scroll.position = rect.position + Vector2(8, 8)
	scroll.size = rect.size - Vector2(16, 16)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.focus_mode = Control.FOCUS_NONE
	panel.focus_entered.connect(_set_column_focus.bind(panel, true))
	panel.focus_exited.connect(_set_column_focus.bind(panel, false))
	add_child(scroll)
	var content := VBoxContainer.new()
	content.name = "Content"
	content.custom_minimum_size = Vector2(scroll.size.x - 20, 0)
	content.add_theme_constant_override("separation", 6)
	scroll.add_child(content)
	var heading := _label("Heading", title_key, 24)
	heading.custom_minimum_size = Vector2(0, 40)
	content.add_child(heading)
	for index in lines.size():
		var line := Label.new()
		line.name = "Line%d" % index
		line.text = lines[index]
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_size_override("font_size", 20)
		line.add_theme_color_override("font_color", UiTheme.INK)
		content.add_child(line)
	var cue_frame := PanelContainer.new()
	cue_frame.name = "%sCueFrame" % node_name
	cue_frame.position = rect.position + Vector2(rect.size.x - 44, rect.size.y - 38)
	cue_frame.size = Vector2(32, 28)
	cue_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cue_frame.add_theme_stylebox_override("panel", _panel_style(2))
	var cue := _label("Cue", &"", 24)
	cue.text = "⌄"
	cue.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cue.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cue.add_theme_color_override("font_color", UiTheme.STAMP_RED)
	cue.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cue_frame.add_child(cue)
	cue_frame.visible = false
	add_child(cue_frame)
	scroll.get_v_scroll_bar().value_changed.connect(func(value: float) -> void:
		cue_frame.visible = _scroll_overflows(scroll) and value < _scroll_limit(scroll)
	)
	call_deferred("_refresh_scroll_cue", scroll, cue_frame)


func _refresh_scroll_cue(scroll: ScrollContainer, cue: Control) -> void:
	cue.visible = _scroll_overflows(scroll) and scroll.scroll_vertical < _scroll_limit(scroll)


func _scroll_overflows(scroll: ScrollContainer) -> bool:
	var content := scroll.get_node_or_null("Content") as Control
	return content != null and content.get_combined_minimum_size().y > scroll.size.y


func _scroll_limit(scroll: ScrollContainer) -> float:
	var bar := scroll.get_v_scroll_bar()
	return maxf(bar.max_value - bar.page, 0.0)


func _set_column_focus(panel: PanelContainer, focused: bool) -> void:
	panel.add_theme_stylebox_override("panel", _panel_style(5 if focused else 3))


func _focus_columns(primary: Button, has_kept: bool) -> void:
	var ordered: Array[Control] = [primary]
	if has_kept:
		ordered.append(get_node("KeptScrollFrame") as Control)
	ordered.append(get_node("LostScrollFrame") as Control)
	ordered.append(get_node("EvidenceScrollFrame") as Control)
	for index in ordered.size():
		var control := ordered[index]
		var next := ordered[(index + 1) % ordered.size()]
		var previous := ordered[(index - 1 + ordered.size()) % ordered.size()]
		control.focus_neighbor_right = control.get_path_to(next)
		control.focus_neighbor_left = control.get_path_to(previous)
		control.focus_next = control.get_path_to(next)
		control.focus_previous = control.get_path_to(previous)
	primary.grab_focus()


func _add_lock_feedback(button: Button) -> void:
	var progress := ProgressBar.new()
	progress.name = "LockProgress"
	progress.position = Vector2(12, 76)
	progress.size = Vector2(376, 8)
	progress.max_value = 100.0
	progress.show_percentage = false
	progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress.add_theme_stylebox_override("background", _bar_style(UiTheme.MUTED))
	progress.add_theme_stylebox_override("fill", _bar_style(UiTheme.STAMP_RED))
	button.add_child(progress)
	var lock_icon := _label("LockIcon", &"", 20)
	lock_icon.text = "⌑"
	lock_icon.position = Vector2(12, 8)
	lock_icon.size = Vector2(32, 32)
	lock_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(lock_icon)
	var action_icon := _label("ActionIcon", &"", 28)
	action_icon.position = Vector2(12, 8)
	action_icon.size = Vector2(32, 48)
	action_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(action_icon)
	var status := _label("ActionStatus", &"", 20)
	status.position = Vector2(24, 8)
	status.size = Vector2(352, 64)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status.visible = false
	button.add_child(status)


func _refresh_primary_presentation(button: Button) -> void:
	var has_status := _primary_status_key != &""
	button.text = "" if has_status else tr(_primary_key())
	var lock_icon := button.get_node_or_null("LockIcon") as Label
	if lock_icon != null:
		lock_icon.visible = _primary_locked and not has_status
	var action_icon := button.get_node_or_null("ActionIcon") as Label
	if action_icon != null:
		action_icon.text = "⇥" if _is_after_manifest() else "↻"
		action_icon.visible = not _primary_locked and not has_status
	var status := button.get_node_or_null("ActionStatus") as Label
	if status != null:
		status.text = tr(_primary_status_key)
		status.visible = has_status


func _kept_lines() -> Array[String]:
	var lines: Array[String] = [tr(&"SUMMARY_DEATH_KEPT_SEALED")]
	for entry: Dictionary in _safe_summary().kept:
		lines.append("◇ %s" % _item_name(StringName(entry.get("def_id", &""))))
	return lines


func _lost_lines() -> Array[String]:
	var lines: Array[String] = []
	var unsealed := _entries_with_reason(&"unsealed")
	if not unsealed.is_empty():
		lines.append(tr(&"SUMMARY_DEATH_LOST_UNSEALED"))
		for entry: Dictionary in unsealed:
			lines.append("⌁ %s" % _item_name(StringName(entry.get("def_id", &""))))
	var left_behind := _entries_with_reason(&"left_behind")
	if not left_behind.is_empty():
		lines.append(tr(&"SUMMARY_DEATH_LOST_LEFT_BEHIND"))
		for entry: Dictionary in left_behind:
			lines.append("⌄ %s" % _item_name(StringName(entry.get("def_id", &""))))
	if _safe_summary().equipped_gear_lost:
		lines.append("⚔ %s" % tr(&"SUMMARY_DEATH_LOST_EQUIPPED"))
	return lines


func _evidence_lines() -> Array[String]:
	var lines: Array[String] = []
	if _is_after_manifest():
		lines.append(tr(&"SUMMARY_DEATH_EVIDENCE_UNRECOVERED"))
		for def_id: StringName in _safe_summary().unrecovered_evidence:
			lines.append("? %s" % _item_name(def_id))
	else:
		lines.append(tr(&"SUMMARY_DEATH_EVIDENCE_AT_DESK"))
	lines.append(tr(&"SUMMARY_DEATH_NOT_EXTRACTED"))
	return lines


func _entries_with_reason(reason: StringName) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for entry: Dictionary in _safe_summary().lost:
		if StringName(entry.get("lost_reason", &"unsealed")) == reason:
			entries.append(entry)
	return entries


func _item_name(def_id: StringName) -> String:
	if registry != null:
		var definition := registry.get_def(def_id)
		if definition != null:
			return definition.localized_display_name()
	if def_id == &"manifest_r17":
		return tr(&"CARD_MANIFEST_R17_NAME")
	return tr(&"ITEM_STARTER_REMEDY_NAME")


func _safe_summary() -> DeathSummary:
	return summary if summary != null else DeathSummary.new()


func _is_after_manifest() -> bool:
	return _safe_summary().death_variant == &"after_manifest"


func _primary_key() -> StringName:
	return &"SUMMARY_DEATH_BUTTON_BOOT" if _is_after_manifest() else &"SUMMARY_DEATH_BUTTON_PREPARE"


func _input_guard_active() -> bool:
	return _elapsed_seconds < UI_OPEN_GUARD_SECONDS


func _button_lock_active() -> bool:
	return _elapsed_seconds < SUMMARY_DEATH_BUTTON_LOCK_SECONDS


func _label(node_name: String, key: StringName, font_size: int) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = tr(key)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", UiTheme.INK)
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


func _panel_style(border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTheme.PAPER
	style.border_color = UiTheme.INK
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(2)
	return style


func _bar_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(4)
	return style
