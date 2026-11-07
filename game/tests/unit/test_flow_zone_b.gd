extends RefCounted

const OUTER_PIER_RUN_SCENE := preload("res://src/flow/outer_pier_run.tscn")
const BOOT_SCRIPT := preload("res://src/boot/boot.gd")


func test_flow_zone_b_route_reaches_s10_with_cache_patrol_and_hold(t) -> bool:
	var run := await _new_run(t)
	if run == null:
		return true
	var world := run._world
	var zone_b := world.get_node_or_null("ZoneBFloodedMarket") as Node3D
	t.ok(zone_b != null, "gameplay instances the authored Zone B with Zone A")
	t.ok(run._guard.get_node_or_null("Visual/TaxGuardModel") != null, "guard uses the Task-86 model through Visual")
	t.ok(run._foreman.get_node_or_null("Visual/ForemanModel") != null, "foreman uses the Task-86 model through Visual")
	t.ok(run._retriever.get_node_or_null("Visual/RetrieverModel") != null, "Retriever scene uses its Task-86 model through Visual")
	await _pickup_manifest(t, run)
	await _enter_authored_zone(t, run, "BEntryZone")
	t.eq((run._hud.get_node("ObjectivePanel/Objective") as Label).text, tr(&"HUD_OBJECTIVE_CROSS_TAX_POST"), "B entry changes the objective to the tax post")
	run._guard.brain.set_player(run._guard.global_position + Vector3(0.0, 0.0, 1.0), true, true)
	run._guard.brain.tick(0.1)
	run._guard.brain.tick(0.1)
	t.eq(run._guard.brain.state, EnemyBrain.STATE_WINDUP, "guard simulation reaches its telegraph")
	run._foreman.brain.set_player(run._foreman.global_position + Vector3(0.0, 0.0, 1.0), true, true)
	run._foreman.brain.tick(0.1)
	run._foreman.brain.tick(0.1)
	run._retriever.combat.start_dodge()
	t.eq(run._retriever.combat.state, RetrieverCombat.STATE_DODGING, "Retriever can dodge during the foreman beat")
	run._guard.brain.health.damage(run._guard.brain.health.max_hp)
	run._foreman.brain.health.damage(run._foreman.brain.health.max_hp)
	run._update_gate()
	t.ok(run._gate_open, "Gate B opens after both lane roles withdraw or go down, without a kill counter")
	await _enter_authored_zone(t, run, "CalmZoneB")
	await _enter_authored_zone(t, run, "CacheZoneB")
	run.request_cache()
	var cache_panel := run._overlay as LootCachePanel
	t.ok(cache_panel != null, "Cache B opens only from the calm-zone interaction")
	if cache_panel == null:
		return true
	cache_panel.open_card(1)
	cache_panel.open_pickup()
	cache_panel.toggle_rotate()
	t.ok(cache_panel.release_cell(RetrieverInventory.BACKPACK, Vector2i(0, 3)).ok, "rotated 1x2 ledger is picked up through the real cache panel")
	cache_panel.open_card(0)
	cache_panel.open_pickup()
	t.ok(cache_panel.release_cell(RetrieverInventory.BACKPACK, Vector2i(1, 0)).ok, "1x1 coin stack is picked up through the real cache panel")
	t.eq(run._cache.cache_state(), &"empty", "cache removes only successfully placed items")
	await _leave_authored_zone_for(t, run, "CalmZoneB", "BEntryZone")
	t.ok(run._patrol_started and run._patrol_director != null, "leaving CalmZoneB starts the one-time patrol cue")
	t.eq(run._patrol_director._elapsed, 0.0, "patrol begins with its authored warning lead")
	await _enter_authored_zone(t, run, "BeaconZoneA")
	run.request_call()
	var dialog := run._overlay as ConfirmDialog
	t.ok(dialog != null, "returning to A allows the normal boat confirmation")
	run._confirm_call()
	for _step in 6:
		run._process(0.25)
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.S8_HOLD, "confirmed call enters the hold")
	t.ok(run._hold_director != null and run._hold_director._enemies.size() == 2, "hold director creates the warned lane-B guard and foreman")
	run._hold_director.tick(0.1)
	for _step in 80:
		run._process(0.25)
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.S9_BOAT_READY, "hold reaches boat-ready while lane enemies do not block it")
	await _enter_authored_zone(t, run, "BoardZoneA")
	run.request_board()
	await t.tree.process_frame
	var summary := run._overlay as ExtractSummaryScreen
	t.ok(summary != null, "boarding presents S10")
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.S10_SUCCESS, "Manifest extracts only after boarding")
	t.ok(summary.summary.evidence.has(&"manifest_r17"), "summary archives Manifest R-17")
	t.ok(_contains_kept(summary.summary.kept, &"scraped_tax_coin") and _contains_kept(summary.summary.kept, &"waterlogged_stock_ledger"), "summary keeps both successfully collected cache items")
	t.ok(run._patrol != null and not run._patrol.is_physics_processing(), "S10 disables the returning patrol before the summary is shown")
	for _step in 3:
		run._process(0.25)
	run._retriever.combat.health.damage(run._retriever.combat.health.max_hp)
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.S10_SUCCESS, "post-board patrol damage cannot replace completed extraction")
	t.ok(run._overlay == summary, "post-board depletion leaves the S10 summary visible")
	run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func test_flow_hp_zero_opens_stub_then_returns_to_boot_without_summary(t) -> bool:
	var run := await _new_run(t)
	if run == null:
		return true
	run._retriever.combat.health.damage(run._retriever.combat.health.max_hp)
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.ENDED_DEATH, "HP zero ends the run without extraction")
	t.ok(run._combat_hud._stub_open, "HP zero opens the blocking stub")
	t.ok(not (run._overlay is ExtractSummaryScreen), "HP zero never shows success summary")
	run._combat_hud._stub_elapsed = CombatHud.STUB_END_MESSAGE_SECONDS
	run._combat_hud.request_boot()
	await t.tree.process_frame
	await t.tree.process_frame
	t.ok(RunSession.inventory == null and t.tree.current_scene.get_script() == BOOT_SCRIPT, "stub boot resets RunSession and returns to Boot")
	run.queue_free()
	await t.tree.process_frame
	return true


func test_flow_patrol_lamp_turns_off_for_down_withdrawn_and_deck_return(t) -> bool:
	var down_run := await _new_run(t)
	if down_run == null:
		return true
	await _start_patrol_from_authored_zones(t, down_run)
	var down_lamp := down_run._zone_b.get_node_or_null("PatrolAlertLampB") as LaneBAlertLamp
	down_run._patrol.brain.health.damage(down_run._patrol.brain.health.max_hp)
	down_run._patrol_director.tick(0.1)
	t.eq(down_lamp.state, &"off", "PatrolAlertLampB turns off when the patrol is down")
	down_run.queue_free()
	RunSession.clear()
	await t.tree.process_frame

	var withdrawn_run := await _new_run(t)
	if withdrawn_run == null:
		return true
	await _start_patrol_from_authored_zones(t, withdrawn_run)
	var withdrawn_lamp := withdrawn_run._zone_b.get_node_or_null("PatrolAlertLampB") as LaneBAlertLamp
	var withdraw_point := withdrawn_run._zone_b.get_node("WithdrawPointPatrolB") as Node3D
	withdrawn_run._patrol.brain.begin_withdraw()
	withdrawn_run._patrol.brain.set_position(withdraw_point.global_position)
	withdrawn_run._patrol.brain.tick(0.1)
	withdrawn_run._patrol_director.tick(0.1)
	t.eq(withdrawn_lamp.state, &"off", "PatrolAlertLampB turns off when the patrol withdraws")
	withdrawn_run.queue_free()
	RunSession.clear()
	await t.tree.process_frame

	var deck_run := await _new_run(t)
	if deck_run == null:
		return true
	await _start_patrol_from_authored_zones(t, deck_run)
	var deck_lamp := deck_run._zone_b.get_node_or_null("PatrolAlertLampB") as LaneBAlertLamp
	deck_run._retriever.global_position = deck_run._zone_b.global_position + Vector3(-0.5, 0.95, 0.0)
	await t.tree.process_frame
	await t.tree.process_frame
	t.eq(deck_lamp.state, &"off", "PatrolAlertLampB turns off when the Retriever returns to deck A")
	deck_run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func _pickup_manifest(t, run: OuterPierRun) -> void:
	await _enter_authored_zone(t, run, "DispatchZone")
	run.request_dispatch()
	var card := run._overlay as ManifestPickupCard
	if not t.ok(card != null, "dispatch opens the Manifest pickup card"):
		return
	card._opened_at_msec = -1000
	card.pickup_requested.emit()
	await t.tree.process_frame
	var panel := run._overlay as ManifestPickupPanel
	if not t.ok(panel != null, "Manifest card opens its placement panel"):
		return
	panel._opened_at_msec = -1000
	panel.tap_cell(RetrieverInventory.BACKPACK, Vector2i.ZERO)
	panel.closed.emit(true)
	await t.tree.process_frame
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.E1_CALLABLE, "Manifest pickup makes extract callable")


func _start_patrol_from_authored_zones(t, run: OuterPierRun) -> void:
	await _enter_authored_zone(t, run, "CalmZoneB")
	await _leave_authored_zone_for(t, run, "CalmZoneB", "BEntryZone")
	t.ok(run._patrol_director != null and run._patrol != null, "CalmZoneB exit creates the patrol through its authored Area3D")


func _enter_authored_zone(t, run: OuterPierRun, zone_name: String) -> void:
	var zone := _authored_zone(run, zone_name)
	if not t.ok(zone != null, "%s is an authored Area3D interaction zone" % zone_name):
		return
	run._retriever.global_position = zone.global_position
	await t.tree.physics_frame
	await t.tree.physics_frame
	if zone is ProximityZone3D:
		(zone as ProximityZone3D).retriever_entered.emit()
	else:
		zone.body_entered.emit(run._retriever)


func _leave_authored_zone_for(t, run: OuterPierRun, source_name: String, destination_name: String) -> void:
	var source := _authored_zone(run, source_name)
	if not t.ok(source != null, "%s is an authored Area3D interaction zone" % source_name):
		return
	var destination := _authored_zone(run, destination_name)
	if not t.ok(destination != null, "%s is an authored Area3D interaction zone" % destination_name):
		return
	run._retriever.global_position = destination.global_position
	await t.tree.physics_frame
	await t.tree.physics_frame
	if source is ProximityZone3D:
		(source as ProximityZone3D).retriever_exited.emit()
	else:
		source.body_exited.emit(run._retriever)
	if destination is ProximityZone3D:
		(destination as ProximityZone3D).retriever_entered.emit()
	else:
		destination.body_entered.emit(run._retriever)


func _authored_zone(run: OuterPierRun, zone_name: String) -> Area3D:
	var zone := run._world.get_node_or_null(zone_name) as Area3D
	if zone == null and run._zone_b != null:
		zone = run._zone_b.get_node_or_null(zone_name) as Area3D
	return zone


func _new_run(t) -> OuterPierRun:
	RunSession.begin_briefing()
	RunSession.begin_run(RunSession.inventory)
	var run := OUTER_PIER_RUN_SCENE.instantiate() as OuterPierRun
	if not t.ok(run != null, "run scene loads"):
		return null
	t.tree.root.add_child(run)
	await t.tree.process_frame
	return run


func _contains_kept(entries: Array[Dictionary], def_id: StringName) -> bool:
	for entry: Dictionary in entries:
		if entry.get("def_id", &"") == def_id:
			return true
	return false
