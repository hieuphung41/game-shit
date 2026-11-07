extends RefCounted

const HUD_SCENE := preload("res://src/ui/combat/combat_hud.tscn")


func test_ui_combat_hud_projects_health_actions_warning_and_stub(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var combat := RetrieverCombat.new(null, inventory)
	var hud := HUD_SCENE.instantiate() as CombatHud
	hud.set_combat(combat)
	t.tree.root.add_child(hud)
	await t.tree.process_frame
	combat.health.damage(70)
	t.eq((hud.get_node("HealthPanel/HealthValue") as Label).text, tr("HUD_HEALTH_VALUE").format({"hp": 30, "max_hp": 100}), "health signal updates value")
	t.ok((hud.get_node("HealthPanel/LowHealth") as Label).visible, "low health gets label cue")
	hud.show_warning(&"HUD_ALERT_PATROL_B")
	t.ok((hud.get_node("Warning") as Label).visible, "warning is shown by command")
	hud.press_action(&"combat_attack")
	t.ok(Input.is_action_pressed(&"combat_attack"), "touch emits named InputMap action")
	await t.tree.process_frame
	t.ok(not Input.is_action_pressed(&"combat_attack"), "tap action releases after frame")
	combat.health.damage(30)
	await t.tree.process_frame
	t.ok((hud.get_node("DepletedStub") as Panel).visible, "depleted signal opens blocking stub")
	t.ok(not (hud.get_node("AttackButton") as Button).visible, "combat buttons hide in stub")
	t.ok(not (hud.get_node("Objective") as Label).visible, "depleted stub hides the objective")
	t.ok(not (hud.get_node("HealthPanel") as Panel).visible, "depleted stub hides the complete health panel")
	t.ok((hud.get_node("DepletedInputBlocker") as Control).visible, "depleted stub enables its dedicated input blocker")
	hud._stub_elapsed = CombatHud.STUB_END_MESSAGE_SECONDS + 0.1
	hud._refresh_stub()
	t.ok(hud._stub_open, "stub state is active")
	t.ok(hud._stub_elapsed >= CombatHud.STUB_END_MESSAGE_SECONDS, "stub wait elapsed")
	var requested: Array[bool] = []
	hud.boot_requested.connect(func() -> void: requested.append(true))
	hud.request_boot()
	t.eq(requested.size(), 1, "boot remains a single UI navigation request")
	hud.queue_free()
	await t.tree.process_frame
	return true


func test_ui_combat_hud_back_requests_boot_only_after_depleted_delay(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var combat := RetrieverCombat.new(null, inventory)
	var hud := HUD_SCENE.instantiate() as CombatHud
	hud.set_combat(combat)
	t.tree.root.add_child(hud)
	await t.tree.process_frame
	var requested: Array[bool] = []
	hud.boot_requested.connect(func() -> void: requested.append(true))
	combat.health.damage(combat.health.max_hp)
	var early_back := InputEventAction.new()
	early_back.action = &"ui_cancel"
	early_back.pressed = true
	hud._input(early_back)
	t.eq(requested.size(), 0, "Back is ignored until the depleted stub delay completes")
	hud._stub_elapsed = CombatHud.STUB_END_MESSAGE_SECONDS
	hud._refresh_stub()
	var ready_back := InputEventAction.new()
	ready_back.action = &"ui_cancel"
	ready_back.pressed = true
	hud._input(ready_back)
	t.eq(requested.size(), 1, "Back requests Boot after the depleted stub delay")
	hud.queue_free()
	await t.tree.process_frame
	return true


func test_ui_combat_hud_uses_s03_combat_regions_and_hold_input(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var hud := HUD_SCENE.instantiate() as CombatHud
	hud.set_combat(RetrieverCombat.new(null, inventory))
	t.tree.root.add_child(hud)
	await t.tree.process_frame
	var attack := hud.get_node("AttackButton") as Button
	var dodge := hud.get_node("DodgeButton") as Button
	var guard := hud.get_node("GuardButton") as Button
	var remedy := hud.get_node("RemedyButton") as Button
	t.eq(Vector2(attack.offset_left, attack.offset_top), Vector2(-192, -144), "attack is inset 64×16 from bottom-right C1")
	t.eq(Vector2(dodge.offset_left, dodge.offset_top), Vector2(-320, -128), "dodge is inset 208×16 from bottom-right C2")
	t.eq(Vector2(guard.offset_left, guard.offset_top), Vector2(-448, -128), "guard is inset 336×16 from bottom-right C3")
	t.eq(Vector2(remedy.offset_left, remedy.offset_top), Vector2(-560, -112), "remedy is inset 464×16 from bottom-right C4")
	var press_a := InputEventScreenTouch.new()
	press_a.index = 1
	press_a.position = guard.get_global_rect().get_center()
	press_a.pressed = true
	hud._input(press_a)
	t.ok(Input.is_action_pressed(&"combat_guard"), "first guard touch owns and holds the named action")
	var press_b := InputEventScreenTouch.new()
	press_b.index = 2
	press_b.position = press_a.position
	press_b.pressed = true
	hud._input(press_b)
	var release_b := InputEventScreenTouch.new()
	release_b.index = 2
	release_b.position = press_a.position
	release_b.pressed = false
	hud._input(release_b)
	t.ok(Input.is_action_pressed(&"combat_guard"), "second finger cannot release the first guard owner")
	var cancel_a := InputEventScreenTouch.new()
	cancel_a.index = 1
	cancel_a.position = press_a.position
	cancel_a.pressed = false
	cancel_a.canceled = true
	hud._input(cancel_a)
	t.ok(not Input.is_action_pressed(&"combat_guard"), "owner cancellation releases guard")
	hud._input(press_a)
	hud.get_window().focus_exited.emit()
	t.ok(not Input.is_action_pressed(&"combat_guard"), "focus loss releases guard")
	hud.queue_free()
	await t.tree.process_frame
	return true


func test_ui_combat_hud_s03_text_uses_the_reference_font_floor(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var hud := HUD_SCENE.instantiate() as CombatHud
	hud.set_combat(RetrieverCombat.new(null, inventory))
	t.tree.root.add_child(hud)
	await t.tree.process_frame
	for node_path in [NodePath("HealthPanel/LowHealth"), NodePath("Warning"), NodePath("DepletedStub/Message"), NodePath("AttackButton"), NodePath("DodgeButton"), NodePath("GuardButton"), NodePath("RemedyButton")]:
		var control := hud.get_node(node_path) as Control
		t.ok(control.get_theme_font_size("font_size") >= 24, "%s meets the 24 px reference floor" % node_path)
	hud.queue_free()
	await t.tree.process_frame
	return true


func test_ui_combat_hud_hides_danger_when_an_overlay_closes(t) -> bool:
	var hud := HUD_SCENE.instantiate() as CombatHud
	t.tree.root.add_child(hud)
	await t.tree.process_frame
	var danger := hud.get_node("DangerClose") as Button
	hud.set_overlay_open(true)
	hud.set_danger_near(true, true)
	t.ok(danger.visible, "danger close is visible for a windup while an overlay is open")
	hud.set_overlay_open(false)
	t.ok(not danger.visible, "danger close hides when its overlay closes")
	hud.queue_free()
	await t.tree.process_frame
	return true


func test_ui_combat_hud_remedy_refusals_show_localized_status_without_replacing_warning(t) -> bool:
	var full_inventory := StarterInventoryFactory.create()
	var full_combat := RetrieverCombat.new(null, full_inventory)
	var full_hud := HUD_SCENE.instantiate() as CombatHud
	full_hud.set_combat(full_combat)
	t.tree.root.add_child(full_hud)
	await t.tree.process_frame
	full_hud.show_warning(&"HUD_ALERT_PATROL_B")
	var full_remedy := full_hud.get_node("RemedyButton") as Button
	_tap_remedy_touch(full_hud, full_remedy)
	t.ok(Input.is_action_pressed(&"use_remedy"), "full-health screen touch emits the named C4 action")
	full_combat.press(&"use_remedy")
	t.eq((full_hud.get_node("Status") as Label).text, tr("COMBAT_REMEDY_REFUSED_HP_FULL"), "full-health refusal uses the localized status")
	t.ok((full_hud.get_node("Status") as Label).visible, "full-health refusal is visible")
	t.eq((full_hud.get_node("Warning") as Label).text, "▲ " + tr("HUD_ALERT_PATROL_B"), "remedy status preserves the lane warning")
	full_hud.queue_free()
	await t.tree.process_frame

	var empty_inventory := StarterInventoryFactory.create()
	empty_inventory.consume(2)
	var empty_combat := RetrieverCombat.new(null, empty_inventory)
	var empty_hud := HUD_SCENE.instantiate() as CombatHud
	empty_hud.set_combat(empty_combat)
	t.tree.root.add_child(empty_hud)
	await t.tree.process_frame
	var empty_remedy := empty_hud.get_node("RemedyButton") as Button
	t.ok(not empty_remedy.disabled, "empty-pouch C4 remains tappable to explain the refusal")
	_tap_remedy_touch(empty_hud, empty_remedy)
	t.ok(Input.is_action_pressed(&"use_remedy"), "empty-pouch screen touch emits the named C4 action")
	empty_combat.press(&"use_remedy")
	t.eq((empty_hud.get_node("Status") as Label).text, tr("COMBAT_REMEDY_REFUSED_NO_REMEDY"), "empty-pouch refusal uses the localized status")
	t.ok((empty_hud.get_node("Status") as Label).visible, "empty-pouch refusal is visible")
	empty_hud.queue_free()
	await t.tree.process_frame
	return true


func test_ui_combat_hud_normal_root_passes_r6_touch_drag_to_joystick(t) -> bool:
	var joystick := TouchJoystick.new()
	joystick.position = Vector2(0.0, 460.0)
	joystick.size = Vector2(260.0, 260.0)
	var directions: Array[Vector2] = []
	joystick.direction_changed.connect(func(direction: Vector2) -> void: directions.append(direction))
	var hud := HUD_SCENE.instantiate() as CombatHud
	t.tree.root.add_child(joystick)
	t.tree.root.add_child(hud)
	await t.tree.process_frame
	t.eq(hud.mouse_filter, Control.MOUSE_FILTER_IGNORE, "normal full-screen HUD root ignores touches outside its controls")
	_push_touch(t.tree.root.get_viewport(), Vector2(130.0, 590.0), true)
	await t.tree.process_frame
	directions.clear()
	_push_drag(t.tree.root.get_viewport(), Vector2(248.0, 590.0))
	await t.tree.process_frame
	t.eq(directions.size(), 1, "R6 drag reaches the joystick while CombatHud is present")
	hud.queue_free()
	joystick.queue_free()
	await t.tree.process_frame
	return true


func test_ui_combat_hud_remedy_channel_and_each_interruption_show_status(t) -> bool:
	for interruption in [&"damage", &"dodge", &"guard", &"overlay"]:
		var inventory := StarterInventoryFactory.create()
		var combat := RetrieverCombat.new(null, inventory)
		combat.health.damage(1)
		var hud := HUD_SCENE.instantiate() as CombatHud
		hud.set_combat(combat)
		t.tree.root.add_child(hud)
		await t.tree.process_frame
		combat.press(&"use_remedy")
		var remedy := hud.get_node("RemedyButton") as Button
		t.ok(remedy.text.contains("◌"), "%s displays the active remedy-channel indicator" % interruption)
		match interruption:
			&"damage":
				combat.receive_hit(HitInfo.new(0, &"test", 1, Vector3.FORWARD, Vector3.BACK, 0.0, true))
			&"dodge":
				combat.press(&"combat_dodge")
			&"guard":
				combat.press(&"combat_guard")
			&"overlay":
				hud.set_overlay_open(true)
		t.ok(not remedy.text.contains("◌"), "%s clears the active remedy-channel indicator" % interruption)
		var status := hud.get_node("Status") as Label
		t.eq(status.text, tr("COMBAT_REMEDY_INTERRUPTED"), "%s interruption shows the localized remedy toast" % interruption)
		t.ok(status.visible, "%s interruption makes the remedy toast visible" % interruption)
		hud.queue_free()
		await t.tree.process_frame
	return true


func _tap_remedy_touch(hud: CombatHud, remedy: Button) -> void:
	var press := InputEventScreenTouch.new()
	press.index = 0
	press.position = remedy.get_global_rect().get_center()
	press.pressed = true
	hud._input(press)
	var release := InputEventScreenTouch.new()
	release.index = 0
	release.position = press.position
	release.pressed = false
	hud._input(release)


func _push_touch(viewport: Viewport, position: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = position
	event.pressed = pressed
	viewport.push_input(event, true)


func _push_drag(viewport: Viewport, position: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = 0
	event.position = position
	viewport.push_input(event, true)
