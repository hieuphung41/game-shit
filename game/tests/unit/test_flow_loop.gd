extends RefCounted

const BOOT_SCENE := preload("res://src/boot/boot.tscn")
const BOOT_SCRIPT := preload("res://src/boot/boot.gd")
const OUTER_PIER_RUN_SCENE := preload("res://src/flow/outer_pier_run.tscn")


func test_flow_loop_reaches_success_summary_through_context_signals(t) -> bool:
	var run := await _new_run(t)
	if run == null:
		return true
	var world := run.get_node_or_null("ZoneAOuterPier") as Node3D
	var dispatch := world.get_node_or_null("DispatchDesk") as Node3D if world != null else null
	var beacon := world.get_node_or_null("BeaconA") as Node3D if world != null else null
	var dispatch_zone := world.get_node_or_null("DispatchZone") as ProximityZone3D if world != null else null
	var beacon_zone := world.get_node_or_null("BeaconZoneA") as ProximityZone3D if world != null else null
	t.ok(dispatch_zone != null and dispatch_zone.global_position.is_equal_approx(dispatch.global_position), "dispatch zone is anchored to DispatchDesk")
	t.ok(beacon_zone != null and beacon_zone.global_position.is_equal_approx(beacon.global_position), "beacon zone is anchored to BeaconA")
	run.set_dispatch_in_range(true)
	run._hud.dispatch_requested.emit()
	var card := run._overlay as ManifestPickupCard
	t.ok(card != null, "dispatch context opens the Manifest card")
	if card == null:
		run.queue_free()
		return true
	card._opened_at_msec = -1000
	card.pickup_requested.emit()
	await t.tree.process_frame
	var panel := run._overlay as ManifestPickupPanel
	t.ok(panel != null, "Manifest card opens the placement panel")
	if panel == null:
		run.queue_free()
		return true
	panel._opened_at_msec = -1000
	panel.tap_cell(RetrieverInventory.BACKPACK, Vector2i.ZERO)
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.E1_CALLABLE, "placing Manifest enables beacon E1")
	t.eq(run.flow.desk_state, ExtractPierAFlow.DeskState.EMPTY, "dispatch desk empties after valid placement")
	var placeholder := world.get_node_or_null("DispatchDesk/ManifestPlaceholder") as MeshInstance3D
	t.ok(placeholder != null and not placeholder.visible, "world desk hides its Manifest after pickup")
	panel.closed.emit(true)
	await t.tree.process_frame
	run.set_beacon_in_range(true)
	run._hud.call_requested.emit()
	var dialog := run._overlay as ConfirmDialog
	t.ok(dialog != null, "E1 context opens call confirmation")
	if dialog == null:
		run.queue_free()
		return true
	dialog._opened_at_msec = -1000
	dialog.accepted.emit()
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.S7_CALL_ACCEPTED, "call confirmation starts S7")
	for _step in 6:
		run._process(0.25)
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.S8_HOLD, "delta ticking enters hold state")
	for _step in 80:
		run._process(0.25)
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.S9_BOAT_READY, "hold timer reaches boat-ready state")
	run.set_board_in_range(true)
	run._hud.board_requested.emit()
	await t.tree.process_frame
	var summary := run._overlay as ExtractSummaryScreen
	t.ok(summary != null, "boarding through the HUD opens S10 success summary")
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.S10_SUCCESS, "run is complete only after board")
	run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func test_flow_overlay_keeps_world_actions_running_but_blocks_new_combat_input(t) -> bool:
	var run := await _new_run(t)
	if run == null:
		return true
	run._retriever.combat.start_dodge()
	t.eq(run._retriever.combat.state, RetrieverCombat.STATE_DODGING, "given a dodge is already active")
	run.set_dispatch_in_range(true)
	run.request_dispatch()
	t.ok(run._retriever.is_physics_processing(), "an open overlay keeps Retriever physics running")
	run._retriever.combat.press(&"combat_attack")
	t.eq(run._retriever.combat.state, RetrieverCombat.STATE_DODGING, "overlay refuses a new combat action")
	for _step in 8:
		run._retriever.combat.tick(0.1)
	t.eq(run._retriever.combat.state, RetrieverCombat.STATE_FREE, "the in-flight dodge completes under the overlay")
	run._guard.brain.set_player(run._guard.global_position + Vector3(0.0, 0.0, 1.0), true, true)
	run._guard.brain.tick(0.1)
	t.eq(run._guard.brain.state, EnemyBrain.STATE_ALERT, "enemy simulation keeps ticking while an overlay is open")
	var card := run._overlay as ManifestPickupCard
	if card != null:
		card.closed.emit()
	await t.tree.process_frame
	run._retriever.combat.press(&"combat_attack")
	t.eq(run._retriever.combat.state, RetrieverCombat.STATE_ATTACKING, "closing the overlay restores combat input")
	run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func test_flow_boot_to_success_summary_with_preinjected_session(t) -> bool:
	RunSession.clear()
	var boot := BOOT_SCENE.instantiate()
	t.tree.root.add_child(boot)
	await t.tree.process_frame
	var boot_enter := boot.get_node_or_null("EnterOuterPierButton") as Button
	t.ok(boot_enter != null, "Boot exposes the Outer Pier entry action")
	if boot_enter == null:
		boot.queue_free()
		return true
	boot_enter.pressed.emit()
	await t.tree.process_frame
	await t.tree.process_frame
	var briefing_flow := t.tree.current_scene as BriefingFlow
	t.ok(briefing_flow != null, "Boot enters BriefingFlow after creating the session")
	if briefing_flow == null:
		return true
	var briefing := briefing_flow.get_node_or_null("Briefing") as BriefingScreen
	t.ok(briefing != null, "preinjected briefing session still builds the briefing screen")
	if briefing == null:
		briefing_flow.queue_free()
		return true
	var briefing_enter := _button_for_key(briefing, &"BRIEFING_BUTTON_ENTER")
	var edit_loadout := _button_for_key(briefing, &"BRIEFING_BUTTON_EDIT_LOADOUT")
	t.ok(briefing_enter != null and not briefing_enter.disabled, "briefing has an enabled Enter button")
	t.ok(edit_loadout != null, "briefing has a loadout action")
	if briefing_enter == null or edit_loadout == null:
		briefing_flow.queue_free()
		return true
	briefing._opened_at_msec = -1000
	edit_loadout.pressed.emit()
	await t.tree.process_frame
	var loadout := briefing_flow.get_node_or_null("Loadout") as LoadoutScreen
	t.ok(loadout != null, "loadout builds after the session inventory is injected")
	if loadout == null:
		briefing_flow.queue_free()
		return true
	t.ok(
		loadout._backpack != null and loadout._backpack.get_node_or_null("Cell_0_0") is Button,
		"loadout renders backpack grid cells"
	)
	var starter_remedy := RunSession.inventory.notary_box.items.get(1) as ItemInstance
	t.ok(starter_remedy != null and starter_remedy.def_id == &"starter_remedy", "loadout retains starter remedy in the Notary Box")
	loadout._opened_at_msec = -1000
	var done := _button_for_key(loadout, &"LOADOUT_BUTTON_DONE")
	t.ok(done != null, "loadout has a completion action")
	if done == null:
		briefing_flow.queue_free()
		return true
	done.pressed.emit()
	await t.tree.process_frame
	briefing._opened_at_msec = -1000
	briefing_enter.pressed.emit()
	await t.tree.process_frame
	await t.tree.process_frame
	var run := t.tree.current_scene as OuterPierRun
	t.ok(run != null, "briefing enters OuterPierRun with a preinjected run flow")
	if run == null:
		return true
	var world := run.get_node_or_null("ZoneAOuterPier") as Node3D
	t.ok(run.flow != null, "OuterPierRun always assigns the session flow")
	t.ok(world != null, "OuterPierRun always instances Zone A")
	t.ok(run._retriever != null, "OuterPierRun always instances the Retriever")
	t.ok(run._hud != null, "OuterPierRun always builds its HUD")
	if world == null or run.flow == null or run._hud == null:
		run.queue_free()
		RunSession.clear()
		return true
	var dispatch_zone := world.get_node_or_null("DispatchZone") as ProximityZone3D
	var beacon_zone := world.get_node_or_null("BeaconZoneA") as ProximityZone3D
	var board_zone := world.get_node_or_null("BoardZoneA") as ProximityZone3D
	t.ok(dispatch_zone != null and beacon_zone != null and board_zone != null, "Zone A creates dispatch, beacon, and boarding interaction zones")
	if dispatch_zone == null or beacon_zone == null or board_zone == null:
		run.queue_free()
		RunSession.clear()
		return true
	dispatch_zone.retriever_entered.emit()
	run._hud.dispatch_requested.emit()
	var card := run._overlay as ManifestPickupCard
	t.ok(card != null, "dispatch interaction opens the Manifest card")
	if card == null:
		run.queue_free()
		RunSession.clear()
		return true
	card._opened_at_msec = -1000
	card.pickup_requested.emit()
	await t.tree.process_frame
	var panel := run._overlay as ManifestPickupPanel
	t.ok(panel != null, "Manifest card opens a placement panel")
	if panel == null:
		run.queue_free()
		RunSession.clear()
		return true
	panel._opened_at_msec = -1000
	panel.tap_cell(RetrieverInventory.BACKPACK, Vector2i.ZERO)
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.E1_CALLABLE, "placing Manifest enables E1")
	panel.closed.emit(true)
	await t.tree.process_frame
	beacon_zone.retriever_entered.emit()
	run._hud.call_requested.emit()
	var dialog := run._overlay as ConfirmDialog
	t.ok(dialog != null, "E1 call action opens O5")
	if dialog == null:
		run.queue_free()
		RunSession.clear()
		return true
	dialog._opened_at_msec = -1000
	dialog.accepted.emit()
	for _step in 6:
		run._process(0.25)
	for _step in 80:
		run._process(0.25)
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.S9_BOAT_READY, "call acknowledgement and hold reach boat-ready")
	board_zone.retriever_entered.emit()
	run._hud.board_requested.emit()
	await t.tree.process_frame
	var summary := run._overlay as ExtractSummaryScreen
	t.ok(summary != null, "boarding presents S10 success summary")
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.S10_SUCCESS, "board commits the Contract 1 run")
	if summary != null:
		summary._opened_at_msec = -1000
		summary.hub_requested.emit()
		await t.tree.process_frame
		await t.tree.process_frame
		t.ok(
			t.tree.current_scene != null and t.tree.current_scene.get_script() == BOOT_SCRIPT,
			"summary returns to Boot"
		)
	RunSession.clear()
	return true


func _new_run(t) -> OuterPierRun:
	RunSession.begin_briefing()
	RunSession.begin_run(RunSession.inventory)
	var run := OUTER_PIER_RUN_SCENE.instantiate() as OuterPierRun
	if not t.ok(run != null, "OuterPierRun scene loads"):
		return null
	t.tree.root.add_child(run)
	await t.tree.process_frame
	return run


func _button_for_key(parent: Control, key: StringName) -> Button:
	if parent == null:
		return null
	for child in parent.get_children():
		var button := child as Button
		if button != null and button.text == tr(key):
			return button
	return null
