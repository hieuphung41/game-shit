extends RefCounted

const BOOT_SCENE := preload("res://src/boot/boot.tscn")


func test_fixture_menu_is_absent_when_debug_menu_is_disabled(t) -> bool:
	AppEnv.load_for("production")
	var boot := BOOT_SCENE.instantiate() as Control
	t.tree.root.add_child(boot)
	await t.tree.process_frame
	t.ok(boot.get_node_or_null("RecoveryFixtureMenu") == null, "production Boot exposes no fixture node or route")
	boot.queue_free()
	AppEnv.load_for("dev")
	await t.tree.process_frame
	return true


func test_fixture_menu_uses_localized_contract_labels_and_disables_recovery_before_s11(t) -> bool:
	AppEnv.load_for("dev")
	var boot := BOOT_SCENE.instantiate() as Control
	t.tree.root.add_child(boot)
	await t.tree.process_frame
	var menu := boot.get_node_or_null("RecoveryFixtureMenu") as RecoveryFixtureMenu
	t.ok(menu != null, "debug Boot creates the fixture menu only behind AppEnv.debug_menu")
	if menu != null:
		t.eq(menu.button_for(&"c1").text, tr("DEBUG_FIXTURE_C1_LABEL"), "C1 label resolves through its TASK-105 key")
		t.eq(menu.button_for(&"c2").text, tr("DEBUG_FIXTURE_C2_LABEL"), "C2 label resolves through its TASK-105 key")
		t.eq(menu.button_for(&"c3").text, tr("DEBUG_FIXTURE_C3_LABEL"), "C3 label resolves through its TASK-105 key")
		t.ok(menu.button_for(&"recovery").disabled, "Recovery alias cannot create a fake S11 before a real death")
	boot.queue_free()
	await t.tree.process_frame
	return true


func test_fixture_recovery_action_is_enabled_only_after_a_real_s11_result(t) -> bool:
	AppEnv.load_for("dev")
	RunSession.clear()
	RunSession.begin_briefing()
	var flow := RunSession.begin_run(RunSession.inventory)
	RunSession.inventory.commit_pickup(RunSession.ground_manifest, RetrieverInventory.BACKPACK, Vector2i.ZERO, false)
	flow.notify_death()
	var summary := flow.resolve_death_summary()
	t.ok(summary != null and summary.death_variant == &"after_manifest", "only a real after-Manifest death produces the recovery source")
	t.ok(RunSession.prepare_recovery_briefing(summary), "real S11 result creates the recovery briefing context")
	var boot := BOOT_SCENE.instantiate() as Control
	t.tree.root.add_child(boot)
	await t.tree.process_frame
	var menu := boot.get_node_or_null("RecoveryFixtureMenu") as RecoveryFixtureMenu
	t.ok(menu != null and not menu.button_for(&"recovery").disabled, "recovery fixture enables only after the real S11 result")
	if menu != null:
		menu.button_for(&"recovery").pressed.emit()
		await t.tree.process_frame
		t.ok(boot.get_node_or_null("RecoveryContractScreen") is RecoveryContractScreen, "recovery fixture routes through the real S12 screen")
		menu.button_for(&"recovery").pressed.emit()
		await t.tree.process_frame
		t.eq(RunSession.extract_flow, null, "recovery alias cannot synthesize an S2 flow or a fake S11")
	boot.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true
