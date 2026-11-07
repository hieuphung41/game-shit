class_name CombatHud
extends Control
## S03 combat HUD. It projects Health/RetrieverCombat signals and converts touch
## into named InputMap actions; it never decides combat outcomes.

signal boot_requested
signal danger_close_requested

const STUB_END_MESSAGE_SECONDS := 2.5

var combat: RetrieverCombat
var health: Health
var _objective_key: StringName = &"HUD_OBJECTIVE_DELIVER_PIER_A"
var _warning_key: StringName = &""
var _overlay_open := false
var _stub_open := false
var _stub_elapsed := 0.0
var _boot_loading := false

var _objective: Label
var _health_value: Label
var _health_segments: Label
var _health_low: Label
var _warning: Label
var _danger: Button
var _attack: Button
var _dodge: Button
var _guard: Button
var _remedy: Button
var _stub: Panel
var _stub_button: Button


func _ready() -> void:
	theme = UiTheme.create()
	_build()
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


func show_warning(key: StringName) -> void:
	_warning_key = key
	if _warning != null:
		_warning.text = "▲ " + tr(key)
		_warning.visible = not key.is_empty() and not _stub_open


func clear_warning() -> void:
	show_warning(&"")


func set_overlay_open(open: bool) -> void:
	_overlay_open = open
	if combat != null:
		combat.set_overlay_open(open)
	_refresh_buttons()


func set_danger_near(near: bool, windup: bool = false) -> void:
	if _danger == null:
		return
	_danger.visible = near and _overlay_open and not _stub_open
	_danger.text = "▲ " + tr(&"HUD_DANGER_WINDUP" if windup else &"HUD_DANGER_NEAR") + "\n" + tr(&"HUD_DANGER_CLOSE_HINT")


func remedy_count() -> int:
	if combat == null or combat.inventory == null:
		return 0
	var count := 0
	for item: ItemInstance in combat.inventory.sling_pouch.all_items():
		if item.def_id == &"sling_remedy":
			count += item.quantity
	return count


func show_depleted() -> void:
	if _stub_open:
		return
	_stub_open = true
	_stub_elapsed = 0.0
	_overlay_open = true
	if combat != null:
		combat.set_overlay_open(true)
	_refresh()


func press_action(action: StringName) -> void:
	if _stub_open or _overlay_open or not InputMap.has_action(action):
		return
	Input.action_press(action)
	if action != &"combat_guard":
		call_deferred("release_action", action)


func release_action(action: StringName) -> void:
	if InputMap.has_action(action):
		Input.action_release(action)


func request_boot() -> void:
	if not _stub_open or _stub_elapsed < STUB_END_MESSAGE_SECONDS or _boot_loading:
		return
	_boot_loading = true
	_stub_button.text = tr(&"UI_LOADING")
	_stub_button.disabled = true
	boot_requested.emit()


func _process(delta: float) -> void:
	if not _stub_open:
		return
	_stub_elapsed = minf(STUB_END_MESSAGE_SECONDS, _stub_elapsed + maxf(0.0, delta))
	_refresh_stub()


func _exit_tree() -> void:
	_disconnect_sources()


func _build() -> void:
	_objective = _label("Objective", _objective_key, 24)
	_objective.position = Vector2(16, 16)
	_objective.size = Vector2(640, 56)
	add_child(_objective)
	var health_panel := Panel.new()
	health_panel.name = "HealthPanel"
	health_panel.position = Vector2(16, 80)
	health_panel.size = Vector2(480, 96)
	add_child(health_panel)
	_health_segments = _label("Segments", &"", 26)
	_health_segments.position = Vector2(16, 8)
	_health_segments.size = Vector2(260, 42)
	health_panel.add_child(_health_segments)
	_health_value = _label("HealthValue", &"HUD_HEALTH_VALUE", 28)
	_health_value.position = Vector2(276, 8)
	_health_value.size = Vector2(180, 42)
	health_panel.add_child(_health_value)
	_health_low = _label("LowHealth", &"HUD_HEALTH_LOW", 18)
	_health_low.position = Vector2(16, 52)
	_health_low.size = Vector2(220, 32)
	health_panel.add_child(_health_low)
	_warning = _label("Warning", &"", 20)
	_warning.position = Vector2(16, 184)
	_warning.size = Vector2(320, 56)
	_warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_warning)
	_danger = _button("DangerClose", &"HUD_DANGER_NEAR", Vector2(16, 248), Vector2(288, 96))
	_danger.visible = false
	_danger.pressed.connect(func() -> void: danger_close_requested.emit())
	add_child(_danger)
	_attack = _combat_button("AttackButton", &"HUD_BUTTON_ATTACK", &"combat_attack", Vector2(1136, 424), Vector2(128, 128))
	_dodge = _combat_button("DodgeButton", &"HUD_BUTTON_DODGE", &"combat_dodge", Vector2(1016, 560), Vector2(112, 112))
	_guard = _combat_button("GuardButton", &"HUD_BUTTON_GUARD", &"combat_guard", Vector2(1136, 560), Vector2(112, 112))
	_remedy = _combat_button("RemedyButton", &"HUD_BUTTON_REMEDY", &"use_remedy", Vector2(912, 576), Vector2(96, 96))
	_stub = Panel.new()
	_stub.name = "DepletedStub"
	_stub.position = Vector2(368, 264)
	_stub.size = Vector2(544, 192)
	add_child(_stub)
	var stub_text := _label("Message", &"COMBAT_STUB_HP_ZERO", 20)
	stub_text.position = Vector2(20, 12)
	stub_text.size = Vector2(504, 72)
	stub_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stub.add_child(stub_text)
	_stub_button = _button("BootButton", &"COMBAT_STUB_BUTTON_BOOT", Vector2(40, 96), Vector2(464, 80))
	_stub_button.pressed.connect(request_boot)
	_stub.add_child(_stub_button)


func _combat_button(node_name: String, key: StringName, action: StringName, at: Vector2, dimensions: Vector2) -> Button:
	var button := _button(node_name, key, at, dimensions)
	button.button_down.connect(press_action.bind(action))
	if action == &"combat_guard":
		button.button_up.connect(release_action.bind(action))
	add_child(button)
	return button


func _refresh() -> void:
	if _objective != null:
		_objective.text = tr(_objective_key)
	if health != null and _health_value != null:
		_health_value.text = tr("HUD_HEALTH_VALUE").format({"hp": health.hp, "max_hp": health.max_hp})
		var total := ceili(float(health.max_hp) / 10.0)
		var filled := ceili(float(health.hp) / 10.0)
		_health_segments.text = "♥ " + "■".repeat(filled) + "□".repeat(total - filled)
		_health_low.visible = health.hp <= ceili(float(health.max_hp) * 0.3)
	if _warning != null:
		_warning.visible = not _warning_key.is_empty() and not _stub_open
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
		_dodge.disabled = combat.state == RetrieverCombat.STATE_DODGING
	if _guard != null:
		_guard.disabled = false
	if _remedy != null:
		_remedy.disabled = combat.state == RetrieverCombat.STATE_GUARDING or remedy_count() == 0
		_remedy.text = tr("HUD_BUTTON_REMEDY") + " " + str(remedy_count())


func _refresh_stub() -> void:
	if _stub == null:
		return
	_stub.visible = _stub_open
	if not _stub_open:
		return
	var ready := _stub_elapsed >= STUB_END_MESSAGE_SECONDS and not _boot_loading
	_stub_button.disabled = not ready
	if not _boot_loading:
		_stub_button.text = ("▣ " if not ready else "→ ") + tr("COMBAT_STUB_BUTTON_BOOT")


func _on_health_changed(_hp: int, _max_hp: int) -> void:
	_refresh()


func _on_combat_state_changed(_state: StringName) -> void:
	_refresh_buttons()


func _on_dodge_cooldown_changed(_remaining: float) -> void:
	_refresh_buttons()


func _on_remedy_refused(_reason: StringName) -> void:
	_refresh_buttons()


func _on_remedy_used(_healed: int) -> void:
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
	button.position = at
	button.size = dimensions
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 20)
	return button
