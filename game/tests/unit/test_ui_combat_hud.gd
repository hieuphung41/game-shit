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
