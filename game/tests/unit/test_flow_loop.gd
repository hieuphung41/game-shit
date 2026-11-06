extends RefCounted

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


func test_flow_overlay_pauses_and_restores_retriever_control(t) -> bool:
	var run := await _new_run(t)
	if run == null:
		return true
	run.set_dispatch_in_range(true)
	run.request_dispatch()
	t.ok(not run._retriever.is_physics_processing(), "an open overlay stops Retriever movement")
	var card := run._overlay as ManifestPickupCard
	if card != null:
		card.closed.emit()
	await t.tree.process_frame
	t.ok(run._retriever.is_physics_processing(), "closing the overlay returns Retriever control")
	run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
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
