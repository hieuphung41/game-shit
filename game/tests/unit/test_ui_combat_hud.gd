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
	var requested := 0
	hud.boot_requested.connect(func() -> void: requested += 1)
	hud.request_boot()
	t.eq(requested, 1, "boot remains a single UI navigation request")
	hud.queue_free()
	await t.tree.process_frame
	return true
