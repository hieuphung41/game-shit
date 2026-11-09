class_name CombatHud
extends Control
## S03 combat HUD. It projects Health/RetrieverCombat signals and converts touch
## into named InputMap actions; it never decides combat outcomes.

signal boot_requested
signal danger_close_requested

const STUB_END_MESSAGE_SECONDS := 2.5
const STATUS_MESSAGE_SECONDS := 3.0
const NO_GUARD_OWNER := -1
const MOUSE_GUARD_OWNER := -2
const API_GUARD_OWNER := -3

var combat: RetrieverCombat
var health: Health
var _objective_key: StringName = &"HUD_OBJECTIVE_DELIVER_PIER_A"
var _warning_key: StringName = &""
var _status_key: StringName = &""
var _overlay_open := false
var _stub_open := false
var _stub_elapsed := 0.0
var _status_remaining := 0.0
var _boot_loading := false
var _dodge_remaining := 0.0
var _guard_owner := NO_GUARD_OWNER
var _remedy_touch_owner := NO_GUARD_OWNER
var _remedy_channel_active := false
var _danger_near := false
var _danger_windup := false

var _objective: Label
var _health_panel: Panel
var _health_value: Label
var _health_segments: Label
var _health_low: Label
var _warning: Label
var _status: Label
var _danger: Button
var _attack: Button
var _dodge: Button
var _guard: Button
var _remedy: Button
var _stub_blocker: Control
var _stub: Panel
var _stub_button: Button


func _ready() -> void:
	theme = UiTheme.create()
	_build()
	resized.connect(_layout_hud)
	call_deferred("_layout_hud")
	var window := get_window()
	if window != null and not window.focus_exited.is_connected(_release_guard_owner):
		window.focus_exited.connect(_release_guard_owner)
	_refresh()


func set_combat(p_combat: RetrieverCombat) -> void:
	_disconnect_sources()
	combat = p_combat
	health = combat.health if combat != null else null
	if combat != null:
		combat.state_changed.connect(_on_combat_state_changed)
		combat.dodge_cooldown_changed.connect(_on_dodge_cooldown_changed)
		combat.remedy_refused.connect(_on_remedy_refused)
		combat.remedy_used.connect(_on_remedy_used)
	if health != null:
		health.changed.connect(_on_health_changed)
		health.depleted.connect(show_depleted)
	_refresh()


func set_objective(key: StringName) -> void:
	_objective_key = key
	if _objective != null:
		_objective.text = tr(key)
		_objective.visible = not _stub_open


func show_warning(key: StringName) -> void:
	_warning_key = key
	if _warning != null:
		_warning.text = "▲ " + tr(key)
		_warning.visible = not key.is_empty() and not _stub_open


func clear_warning() -> void:
	show_warning(&"")


func set_overlay_open(open: bool) -> void:
	_overlay_open = open
	if open:
		_release_guard_owner()
	if combat != null:
		combat.set_overlay_open(open)
	_refresh_danger()
	_refresh_buttons()


func set_danger_near(near: bool, windup: bool = false) -> void:
	_danger_near = near
	_danger_windup = windup
	_refresh_danger()


func show_status(key: StringName) -> void:
	_status_key = key
	_status_remaining = STATUS_MESSAGE_SECONDS if not key.is_empty() else 0.0
	_refresh_status()


func remedy_count() -> int:
	if combat == null or combat.inventory == null:
		return 0
	var count := 0
	for item: ItemInstance in combat.inventory.sling_pouch.all_items():
		if item.def_id == &"sling_remedy":
			count += item.quantity
	return count


func danger_text_fits() -> bool:
	return _button_text_fits(_danger)


func stub_button_has_rendered_label() -> bool:
	if _stub_button == null or not _stub_button.visible or _stub_button.text.strip_edges().is_empty() or not _button_text_fits(_stub_button):
		return false
	if not _stub_button.disabled:
		return true
	var disabled_style := _stub_button.get_theme_stylebox("disabled")
	if not disabled_style is StyleBoxFlat:
		return false
	var disabled_text := _stub_button.get_theme_color("font_disabled_color")
	return not disabled_text.is_equal_approx((disabled_style as StyleBoxFlat).bg_color)


func show_depleted() -> void:
	if _stub_open:
		return
	_stub_open = true
	_stub_elapsed = 0.0
	_overlay_open = true
	_release_guard_owner()
	if combat != null:
		combat.set_overlay_open(true)
	_refresh()


func press_action(action: StringName) -> void:
	if _stub_open or _overlay_open or not InputMap.has_action(action):
		return
	if action == &"combat_guard":
		_begin_guard(API_GUARD_OWNER)
		return
	Input.action_press(action)
	call_deferred("release_action", action)


func release_action(action: StringName) -> void:
	if action == &"combat_guard":
		if _guard_owner == API_GUARD_OWNER:
			_release_guard_owner()
		return
	if InputMap.has_action(action):
		Input.action_release(action)


func request_boot() -> void:
	if not _stub_open or _stub_elapsed < STUB_END_MESSAGE_SECONDS or _boot_loading:
		return
	_boot_loading = true
	_stub_button.text = tr(&"UI_LOADING")
	_stub_button.disabled = true
	boot_requested.emit()


func _input(event: InputEvent) -> void:
	_handle_guard_input(event)
	_handle_combat_touch(event)
	if not _stub_open or _stub_elapsed < STUB_END_MESSAGE_SECONDS:
		return
	if event.is_action_pressed(&"ui_cancel"):
		request_boot()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _dodge_remaining > 0.0:
		_dodge_remaining = maxf(0.0, _dodge_remaining - maxf(0.0, delta))
		_refresh_buttons()
	if _stub_open:
		_stub_elapsed = minf(STUB_END_MESSAGE_SECONDS, _stub_elapsed + maxf(0.0, delta))
		_refresh_stub()
	if _status_remaining > 0.0:
		_status_remaining = maxf(0.0, _status_remaining - maxf(0.0, delta))
		_refresh_status()


func _exit_tree() -> void:
	_release_guard_owner()
	_disconnect_sources()


func _build() -> void:
	_stub_blocker = Control.new()
	_stub_blocker.name = "DepletedInputBlocker"
	_stub_blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_stub_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	_stub_blocker.visible = false
	add_child(_stub_blocker)
	_objective = _label("Objective", _objective_key, 24)
	add_child(_objective)
	_health_panel = Panel.new()
	_health_panel.name = "HealthPanel"
	add_child(_health_panel)
	_health_segments = _label("Segments", &"", 20)
	_health_segments.clip_text = true
	_health_panel.add_child(_health_segments)
	_health_value = _label("HealthValue", &"HUD_HEALTH_VALUE", 28)
	_health_value.clip_text = true
	_health_panel.add_child(_health_value)
	_health_low = _label("LowHealth", &"HUD_HEALTH_LOW", 24)
	_health_panel.add_child(_health_low)
	_warning = _label("Warning", &"", 24)
	_warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_warning)
	_status = _label("Status", &"", 24)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status)
	_danger = _button("DangerClose", &"HUD_DANGER_NEAR", Vector2.ZERO, Vector2(320, 128))
	# D1 always carries both the threat and its one-tap escape instruction.  A
	# fixed newline is not sufficient for every localized line length, so the
	# control gets a real two-line layout rather than clipping its second line.
	_danger.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_danger.clip_text = false
	_danger.visible = false
	_danger.pressed.connect(func() -> void: danger_close_requested.emit())
	add_child(_danger)
	_attack = _combat_button("AttackButton", &"HUD_BUTTON_ATTACK", &"combat_attack", 64, 16, Vector2(128, 128))
	_dodge = _combat_button("DodgeButton", &"HUD_BUTTON_DODGE", &"combat_dodge", 208, 16, Vector2(112, 112))
	_guard = _combat_button("GuardButton", &"HUD_BUTTON_GUARD", &"combat_guard", 336, 16, Vector2(112, 112))
	_remedy = _combat_button("RemedyButton", &"HUD_BUTTON_REMEDY", &"use_remedy", 464, 16, Vector2(96, 96))
	_stub = Panel.new()
	_stub.name = "DepletedStub"
	add_child(_stub)
	var stub_text := _label("Message", &"COMBAT_STUB_HP_ZERO", 24)
	stub_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stub_text.clip_text = true
	_stub.add_child(stub_text)
	_stub_button = _button("BootButton", &"COMBAT_STUB_BUTTON_BOOT", Vector2.ZERO, Vector2(464, 80))
	_stub_button.clip_text = false
	_stub_button.pressed.connect(request_boot)
	_stub.add_child(_stub_button)


func _combat_button(node_name: String, key: StringName, action: StringName, right: float, bottom: float, dimensions: Vector2) -> Button:
	var button := _button(node_name, key, Vector2.ZERO, dimensions)
	button.set_meta(&"hud_right", right)
	button.set_meta(&"hud_bottom", bottom)
	if action == &"use_remedy":
		button.pressed.connect(press_action.bind(action))
	elif action != &"combat_guard":
		button.button_down.connect(press_action.bind(action))
	add_child(button)
	return button


func _handle_guard_input(event: InputEvent) -> void:
	if _guard == null:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if _guard.get_global_rect().has_point(event.position):
				_begin_guard(event.index)
		elif event.index == _guard_owner:
			_release_guard_owner()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _guard.get_global_rect().has_point(event.position):
				_begin_guard(MOUSE_GUARD_OWNER)
		elif _guard_owner == MOUSE_GUARD_OWNER:
			_release_guard_owner()


func _handle_combat_touch(event: InputEvent) -> void:
	if not event is InputEventScreenTouch:
		return
	if event.pressed:
		if _touches_combat_button(event.position, _attack):
			press_action(&"combat_attack")
		elif _touches_combat_button(event.position, _dodge):
			press_action(&"combat_dodge")
		elif _touches_combat_button(event.position, _remedy):
			_remedy_touch_owner = event.index
	elif event.index == _remedy_touch_owner:
		_remedy_touch_owner = NO_GUARD_OWNER
		if not event.canceled and _touches_combat_button(event.position, _remedy):
			press_action(&"use_remedy")


func _touches_combat_button(position: Vector2, button: Button) -> bool:
	return button != null and button.visible and not button.disabled and button.get_global_rect().has_point(position)


func _begin_guard(owner: int) -> void:
	if _guard_owner != NO_GUARD_OWNER or _stub_open or _overlay_open or not InputMap.has_action(&"combat_guard"):
		return
	_guard_owner = owner
	Input.action_press(&"combat_guard")


func _release_guard_owner() -> void:
	if _guard_owner == NO_GUARD_OWNER:
		return
	_guard_owner = NO_GUARD_OWNER
	if InputMap.has_action(&"combat_guard"):
		Input.action_release(&"combat_guard")


func _refresh() -> void:
	if _objective != null:
		_objective.text = tr(_objective_key)
		_objective.visible = not _stub_open
	if _health_panel != null:
		_health_panel.visible = not _stub_open
	if health != null and _health_value != null:
		_health_value.text = tr("HUD_HEALTH_VALUE").format({"hp": health.hp, "max_hp": health.max_hp})
		# Eight compact segments keep the labelled H2 row readable without entering
		# the adjacent exact numeric-health field.
		var total := 8
		var filled := ceili(float(health.hp) / float(health.max_hp) * float(total))
		_health_segments.text = ("⚠ " if health.hp <= ceili(float(health.max_hp) * 0.3) else "♥ ") + "■".repeat(filled) + "□".repeat(total - filled)
		var is_low := health.hp <= ceili(float(health.max_hp) * 0.3)
		# H2 is a single 40 px row. At low health the textual warning replaces
		# the segment row instead of extending into H5's warning region.
		_health_segments.visible = not is_low
		_health_low.visible = is_low
	if _warning != null:
		_warning.visible = not _warning_key.is_empty() and not _stub_open
	_refresh_status()
	_refresh_danger()
	_refresh_buttons()
	_refresh_stub()


func _refresh_buttons() -> void:
	var visible := not _overlay_open and not _stub_open
	for button: Button in [_attack, _dodge, _guard, _remedy]:
		if button != null:
			button.visible = visible
	if combat == null:
		return
	if _attack != null:
		_attack.disabled = combat.state in [RetrieverCombat.STATE_GUARDING, RetrieverCombat.STATE_USING_REMEDY]
	if _dodge != null:
		_dodge.disabled = combat.state == RetrieverCombat.STATE_DODGING or _dodge_remaining > 0.0
		_dodge.text = tr("HUD_BUTTON_DODGE") + (" ◔" if _dodge_remaining > 0.0 else "")
	if _guard != null:
		_guard.disabled = false
	if _remedy != null:
		_remedy.disabled = combat.state == RetrieverCombat.STATE_GUARDING
		_remedy.text = tr("HUD_BUTTON_REMEDY") + (" ◌" if _remedy_channel_active else "") + " ×" + str(remedy_count())


func _refresh_danger() -> void:
	if _danger == null:
		return
	_danger.visible = _danger_near and _overlay_open and not _stub_open
	_danger.text = "▲ " + tr(&"HUD_DANGER_WINDUP" if _danger_windup else &"HUD_DANGER_NEAR") + "\n" + tr(&"HUD_DANGER_CLOSE_HINT")


func _refresh_status() -> void:
	if _status == null:
		return
	_status.text = tr(_status_key)
	_status.visible = not _status_key.is_empty() and _status_remaining > 0.0 and not _stub_open


func _refresh_stub() -> void:
	if _stub == null:
		return
	if _stub_blocker != null:
		_stub_blocker.visible = _stub_open
	_stub.visible = _stub_open
	if not _stub_open:
		return
	var ready := _stub_elapsed >= STUB_END_MESSAGE_SECONDS and not _boot_loading
	_stub_button.visible = true
	_stub_button.disabled = not ready
	if not _boot_loading:
		_stub_button.text = ("▣ " if not ready else "→ ") + tr("COMBAT_STUB_BUTTON_BOOT")


func _on_health_changed(_hp: int, _max_hp: int) -> void:
	_refresh()



func _on_combat_state_changed(next_state: StringName) -> void:
	if next_state == RetrieverCombat.STATE_USING_REMEDY:
		_remedy_channel_active = true
	elif _remedy_channel_active:
		_remedy_channel_active = false
		show_status(&"COMBAT_REMEDY_INTERRUPTED")
	_refresh_buttons()


func _on_dodge_cooldown_changed(_remaining: float) -> void:
	_dodge_remaining = maxf(0.0, _remaining)
	_refresh_buttons()


func _on_remedy_refused(reason: StringName) -> void:
	if _remedy_channel_active:
		_remedy_channel_active = false
	match reason:
		&"no_remedy":
			show_status(&"COMBAT_REMEDY_REFUSED_NO_REMEDY")
		&"hp_full":
			show_status(&"COMBAT_REMEDY_REFUSED_HP_FULL")
	_refresh_buttons()


func _on_remedy_used(_healed: int) -> void:
	_remedy_channel_active = false
	_refresh()


func _disconnect_sources() -> void:
	if combat != null:
		if combat.state_changed.is_connected(_on_combat_state_changed):
			combat.state_changed.disconnect(_on_combat_state_changed)
		if combat.dodge_cooldown_changed.is_connected(_on_dodge_cooldown_changed):
			combat.dodge_cooldown_changed.disconnect(_on_dodge_cooldown_changed)
		if combat.remedy_refused.is_connected(_on_remedy_refused):
			combat.remedy_refused.disconnect(_on_remedy_refused)
		if combat.remedy_used.is_connected(_on_remedy_used):
			combat.remedy_used.disconnect(_on_remedy_used)
	if health != null:
		if health.changed.is_connected(_on_health_changed):
			health.changed.disconnect(_on_health_changed)
		if health.depleted.is_connected(show_depleted):
			health.depleted.disconnect(show_depleted)


func _label(node_name: String, key: StringName, font_size: int) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = tr(key)
	label.add_theme_font_size_override("font_size", font_size)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _button(node_name: String, key: StringName, at: Vector2, dimensions: Vector2) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = tr(key)
	button.clip_text = true
	button.custom_minimum_size = dimensions
	button.position = at
	button.size = dimensions
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 24)
	return button


func _button_text_fits(button: Button) -> bool:
	if button == null or button.clip_text:
		return false
	var font := button.get_theme_font("font")
	var font_size := button.get_theme_font_size("font_size")
	if font == null or font_size <= 0:
		return false
	# UiTheme gives buttons 12 px of horizontal content margin on both sides.
	var content_width := button.size.x - 24.0
	var line_count := 0
	for line: String in button.text.split("\n"):
		line_count += 1
		if font.get_string_size(line, HORIZONTAL_ALIGNMENT_CENTER, -1.0, font_size).x > content_width:
			return false
	return float(line_count) * font.get_height(font_size) <= button.size.y


func _anchor_bottom_right(control: Control, right: float, bottom: float, dimensions: Vector2) -> void:
	HudLayout.place_bottom_right(control, HudLayout.safe_rect(self), right, bottom, dimensions)


func _anchor_bottom_left(control: Control, left: float, bottom: float, dimensions: Vector2) -> void:
	HudLayout.place_bottom_left(control, HudLayout.safe_rect(self), left, bottom, dimensions)


func _layout_hud() -> void:
	var safe := HudLayout.safe_rect(self)
	HudLayout.place_top_left(_objective, safe, Vector2.ZERO, Vector2(640, 56))
	HudLayout.place_top_left(_health_panel, safe, Vector2(0, 64), Vector2(320, 40))
	HudLayout.place_top_left(_health_segments, Rect2(Vector2.ZERO, _health_panel.size), Vector2.ZERO, Vector2(164, 40))
	HudLayout.place_top_left(_health_value, Rect2(Vector2.ZERO, _health_panel.size), Vector2(180, 0), Vector2(140, 40))
	HudLayout.place_top_left(_health_low, Rect2(Vector2.ZERO, _health_panel.size), Vector2.ZERO, Vector2(164, 40))
	HudLayout.place_top_left(_warning, safe, Vector2(0, 112), Vector2(352, 48))
	HudLayout.place_top_left(_status, safe, Vector2(0, 320), Vector2(392, 96))
	HudLayout.place_top_left(_danger, safe, HudLayout.DANGER_CLOSE_OFFSET, HudLayout.DANGER_CLOSE_SIZE)
	for button: Button in [_attack, _dodge, _guard, _remedy]:
		HudLayout.place_bottom_right(button, safe, float(button.get_meta(&"hud_right")), float(button.get_meta(&"hud_bottom")), button.size)
	HudLayout.place_top_center(_stub, safe, 248.0, Vector2(544, 192))
	var stub_text := _stub.get_node_or_null("Message") as Label
	if stub_text != null:
		HudLayout.place_top_left(stub_text, Rect2(Vector2.ZERO, _stub.size), Vector2(20, 12), Vector2(504, 72))
	HudLayout.place_top_left(_stub_button, Rect2(Vector2.ZERO, _stub.size), Vector2(40, 96), Vector2(464, 80))
