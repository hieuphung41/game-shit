class_name ExtractHud
extends Control
## HUD projection of ExtractPierAFlow. World interaction remains with the
## owning scene through contextual action signals.

signal dispatch_requested()
signal call_requested()
signal board_requested()
signal inventory_requested()

var flow: ExtractPierAFlow
var desk_in_range := false
var _overlay_open := false
var _objective: Label
var _beacon: Label
var _beacon_panel: Panel
var _banner: Label
var _prompt: Button
var _context_button: Button
var _inventory_button: Button


func _ready() -> void:
	theme = UiTheme.create()
	_build()
	resized.connect(_layout_hud)
	child_entered_tree.connect(_on_child_entered_tree)
	call_deferred("_layout_hud")
	_refresh()


func set_flow(p_flow: ExtractPierAFlow) -> void:
	if flow != null:
		_disconnect_flow()
	flow = p_flow
	if flow != null:
		flow.extract_state_changed.connect(_on_flow_changed)
		flow.desk_state_changed.connect(_on_desk_changed)
		flow.call_confirm_closed.connect(_on_call_confirm_closed)
		flow.hold_paused_changed.connect(_on_hold_paused_changed)
		flow.boat_ready.connect(_on_boat_ready)
	_refresh()


func set_desk_in_range(in_range: bool) -> void:
	desk_in_range = in_range
	_refresh()


func set_overlay_open(open: bool) -> void:
	_overlay_open = open
	if _inventory_button != null:
		_inventory_button.visible = not open
	if open:
		if _context_button != null:
			_context_button.visible = false
		return
	_refresh_context()


func show_prompt(key: StringName) -> void:
	if _prompt == null:
		return
	_prompt.text = tr(key)
	_prompt.visible = true


func clear_prompt() -> void:
	if _prompt != null:
		_prompt.visible = false


func refresh() -> void:
	_refresh()


func _process(_delta: float) -> void:
	if flow != null and flow.extract_state == ExtractPierAFlow.ExtractState.S8_HOLD:
		_refresh_banner()


func _exit_tree() -> void:
	_disconnect_flow()


func _build() -> void:
	var objective_panel := Panel.new()
	objective_panel.name = "ObjectivePanel"
	objective_panel.visible = false
	add_child(objective_panel)
	_objective = _label("Objective", &"HUD_OBJECTIVE_TAKE_MANIFEST", 24)
	_objective.clip_text = true
	objective_panel.add_child(_objective)
	var banner_panel := Panel.new()
	banner_panel.name = "BannerPanel"
	banner_panel.visible = false
	add_child(banner_panel)
	_banner = _label("Banner", &"", 24)
	_banner.clip_text = true
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_panel.add_child(_banner)
	_beacon_panel = Panel.new()
	_beacon_panel.name = "BeaconPanel"
	add_child(_beacon_panel)
	_beacon = _label("Beacon", &"BEACON_E0_STATE_LABEL", 20)
	_beacon.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_beacon.clip_text = true
	_beacon_panel.add_child(_beacon)
	_inventory_button = _button("InventoryButton", &"HUD_BUTTON_INVENTORY", Vector2.ZERO, Vector2(96, 96))
	_inventory_button.add_theme_font_size_override("font_size", 20)
	_inventory_button.pressed.connect(_on_inventory_pressed)
	add_child(_inventory_button)
	_context_button = _button("ContextButton", &"WORLD_INTERACT_DISPATCH_DESK", Vector2.ZERO, Vector2(224, 112))
	_context_button.pressed.connect(_on_context_pressed)
	add_child(_context_button)
	_prompt = _button("Prompt", &"PROMPT_ROUTE_EXTRACT_NOW", Vector2.ZERO, Vector2(392, 112))
	_prompt.flat = true
	_prompt.visible = false
	_prompt.pressed.connect(clear_prompt)
	add_child(_prompt)


func _refresh() -> void:
	if not is_inside_tree() or flow == null or _objective == null:
		return
	_objective.text = tr(_objective_key())
	_refresh_beacon()
	_refresh_banner()
	_refresh_context()


func _objective_key() -> StringName:
	match flow.extract_state:
		ExtractPierAFlow.ExtractState.E0_UNAVAILABLE:
			return &"HUD_OBJECTIVE_RECOVER_MANIFEST" if flow.can_recover_manifest() else &"HUD_OBJECTIVE_TAKE_MANIFEST"
		ExtractPierAFlow.ExtractState.E1_CALLABLE, ExtractPierAFlow.ExtractState.S7_CALL_ACCEPTED:
			return &"HUD_OBJECTIVE_DELIVER_PIER_A"
		ExtractPierAFlow.ExtractState.S8_HOLD:
			return &"HUD_OBJECTIVE_HOLD_PIER_A"
		ExtractPierAFlow.ExtractState.S9_BOAT_READY:
			return &"HUD_OBJECTIVE_BOARD_BOAT"
	return &"HUD_OBJECTIVE_TAKE_MANIFEST"


func _refresh_beacon() -> void:
	if flow.extract_state == ExtractPierAFlow.ExtractState.E0_UNAVAILABLE:
		_beacon.text = tr("BEACON_E0_STATE_LABEL")
		if flow.in_beacon_zone:
			_beacon.text += "\n" + tr("BEACON_E0_STATE_REASON")
		_beacon_panel.visible = true
		return
	if flow.extract_state == ExtractPierAFlow.ExtractState.E1_CALLABLE:
		_beacon.text = tr("BEACON_E1_STATE_LABEL")
		if not flow.in_beacon_zone:
			_beacon.text += "\n" + tr("BEACON_E1_OUT_OF_ZONE_REASON")
		_beacon_panel.visible = true
		return
	_beacon.text = ""
	_beacon_panel.visible = false


func _refresh_banner() -> void:
	if _banner == null or flow == null:
		return
	var panel := _banner.get_parent() as Panel
	match flow.extract_state:
		ExtractPierAFlow.ExtractState.S7_CALL_ACCEPTED:
			_banner.text = tr("EXTRACT_S7_CALL_ACCEPTED")
			_banner.visible = true
			panel.visible = true
		ExtractPierAFlow.ExtractState.S8_HOLD:
			_banner.text = tr("EXTRACT_S8_HOLD_TIMER").format({"seconds": flow.hold_seconds_display()})
			if flow.hold_paused and flow.hold_pause_reason == &"out_of_zone":
				_banner.text += "\n" + tr("EXTRACT_S8_HOLD_PAUSED")
			_banner.visible = true
			panel.visible = true
		ExtractPierAFlow.ExtractState.S9_BOAT_READY:
			_banner.text = tr("EXTRACT_S9_BOAT_READY")
			_banner.visible = true
			panel.visible = true
		_:
			_banner.text = ""
			_banner.visible = false
			panel.visible = false


func _refresh_context() -> void:
	if _context_button == null:
		return
	_context_button.visible = false
	if _overlay_open:
		return
	if flow.desk_state == ExtractPierAFlow.DeskState.HAS_MANIFEST and desk_in_range:
		_context_button.text = tr("WORLD_INTERACT_RECOVER_DISPATCH" if flow.can_recover_manifest() else "WORLD_INTERACT_DISPATCH_DESK")
		_context_button.visible = true
	elif flow.can_call():
		_context_button.text = tr("EXTRACT_E1_BUTTON_CALL")
		_context_button.visible = true
	elif flow.can_board():
		_context_button.text = tr("EXTRACT_S9_BUTTON_BOARD")
		_context_button.visible = true


func _on_context_pressed() -> void:
	if flow == null:
		return
	if flow.desk_state == ExtractPierAFlow.DeskState.HAS_MANIFEST and desk_in_range:
		dispatch_requested.emit()
	elif flow.can_call():
		call_requested.emit()
	elif flow.can_board():
		board_requested.emit()


func _on_inventory_pressed() -> void:
	inventory_requested.emit()


func _on_flow_changed(_from: int, _to: int) -> void:
	_refresh()


func _on_desk_changed(_state: int) -> void:
	_refresh()


func _on_call_confirm_closed(_confirmed: bool) -> void:
	_refresh()


func _on_hold_paused_changed(_paused: bool, _reason: StringName) -> void:
	_refresh()


func _on_boat_ready() -> void:
	_refresh()


func _on_child_entered_tree(child: Node) -> void:
	if child is Button and child != _context_button and child != _inventory_button and child != _prompt:
		_layout_context_button(child as Button)


func _layout_hud() -> void:
	var safe := HudLayout.safe_rect(self)
	var objective_panel := get_node_or_null("ObjectivePanel") as Panel
	if objective_panel != null:
		HudLayout.place_top_left(objective_panel, safe, Vector2.ZERO, Vector2(640, 56))
		HudLayout.place_top_left(_objective, Rect2(Vector2.ZERO, objective_panel.size), Vector2(16, 0), Vector2(608, 56))
	var banner_panel := get_node_or_null("BannerPanel") as Panel
	if banner_panel != null:
		HudLayout.place_top_center(banner_panel, safe, 68.0, Vector2(512, 80))
		HudLayout.place_top_left(_banner, Rect2(Vector2.ZERO, banner_panel.size), Vector2(16, 0), Vector2(480, 80))
	if _beacon_panel != null:
		HudLayout.place_top_right(_beacon_panel, safe, 16.0, 112.0, Vector2(348, 96))
		HudLayout.place_top_left(_beacon, Rect2(Vector2.ZERO, _beacon_panel.size), Vector2(12, 8), Vector2(324, 80))
	HudLayout.place_top_right(_inventory_button, safe, 0.0, 0.0, Vector2(96, 96))
	HudLayout.place_bottom_right(_context_button, safe, 48.0, 144.0, Vector2(224, 112))
	HudLayout.place_bottom_left(_prompt, safe, 280.0, 0.0, Vector2(392, 112))
	for child: Node in get_children():
		if child is Button and child != _context_button and child != _inventory_button and child != _prompt:
			_layout_context_button(child as Button)


func _layout_context_button(button: Button) -> void:
	HudLayout.place_bottom_right(button, HudLayout.safe_rect(self), 48.0, 144.0, Vector2(224, 112))


func _disconnect_flow() -> void:
	if flow == null:
		return
	if flow.extract_state_changed.is_connected(_on_flow_changed):
		flow.extract_state_changed.disconnect(_on_flow_changed)
	if flow.desk_state_changed.is_connected(_on_desk_changed):
		flow.desk_state_changed.disconnect(_on_desk_changed)
	if flow.call_confirm_closed.is_connected(_on_call_confirm_closed):
		flow.call_confirm_closed.disconnect(_on_call_confirm_closed)
	if flow.hold_paused_changed.is_connected(_on_hold_paused_changed):
		flow.hold_paused_changed.disconnect(_on_hold_paused_changed)
	if flow.boat_ready.is_connected(_on_boat_ready):
		flow.boat_ready.disconnect(_on_boat_ready)


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
	button.clip_text = true
	button.position = at
	button.size = dimensions
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 24)
	return button
