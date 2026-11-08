extends RefCounted
## Chỉ tay: invariant 4 needs visual verification of non-colour signals; invariant 7
## needs an in-context visual/readability pass for HUD, telegraphs, and overlays.

const BOOT_SCENE := preload("res://src/boot/boot.tscn")


func test_readiness_c1_early_extract_requires_the_real_call_hold_board_chain(t) -> bool:
	var run := await _launch(t, &"c1")
	if run == null:
		return true
	t.eq(run.flow.contract_state, ExtractPierAFlow.ContractState.CARRYING, "C1 starts carrying the placed Manifest")
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.E1_CALLABLE, "C1 starts callable, never at success")
	t.ok(_item_at(RunSession.inventory.backpack, Vector2i.ZERO, &"manifest_r17"), "C1 keeps Manifest at backpack (0,0)")
	t.ok(run.flow.in_beacon_zone, "C1 launcher places Retriever in the authored BeaconZoneA")
	t.ok(run.flow.request_call() and run.flow.confirm_call(), "C1 enters the real call state from the BeaconZoneA signal")
	for _step in 86:
		run.flow.tick(0.25)
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.S9_BOAT_READY, "C1 must hold before boat-ready")
	var board := run.get_node_or_null("ZoneAOuterPier/BoardZoneA") as ProximityZone3D
	board.retriever_entered.emit()
	t.ok(run.flow.board() != null, "C1 requires an explicit board action")
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.S10_SUCCESS, "only board reaches C1 success")
	_cleanup(run)
	return true


func test_readiness_c2_runs_manifest_b_card_d_cargo_and_the_real_extract_chain(t) -> bool:
	var run := await _launch_c2_through_briefing(t)
	if run == null:
		return true
	t.eq(run.flow.contract_state, ExtractPierAFlow.ContractState.NOT_TAKEN, "C2 uses the normal run initializer")
	t.eq(run.flow.desk_state, ExtractPierAFlow.DeskState.HAS_MANIFEST, "C2 leaves Manifest at dispatch")
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.E0_UNAVAILABLE, "C2 cannot call before a valid placement")
	t.eq(RunSession.inventory.backpack.all_items().size(), 0, "C2 backpack is empty")
	var dispatch := run.get_node_or_null("ZoneAOuterPier/DispatchZone") as ProximityZone3D
	var hud := run.get_node_or_null("HudLayer/ExtractHud") as ExtractHud
	dispatch.retriever_entered.emit()
	hud.dispatch_requested.emit()
	await t.tree.process_frame
	var manifest_card := _overlay(run) as ManifestPickupCard
	t.ok(manifest_card != null, "C2 opens the standard dispatch card")
	if manifest_card == null:
		_cleanup(run)
		return true
	manifest_card.pickup_requested.emit()
	await t.tree.process_frame
	var manifest_panel := _overlay(run) as ManifestPickupPanel
	t.ok(manifest_panel != null, "C2 opens the standard Manifest placement panel")
	if manifest_panel == null:
		_cleanup(run)
		return true
	manifest_panel.tap_cell(RetrieverInventory.NOTARY_BOX, Vector2i(1, 0))
	if is_instance_valid(manifest_panel):
		manifest_panel.closed.emit(true)
		await t.tree.process_frame
	t.eq(run.flow.contract_state, ExtractPierAFlow.ContractState.CARRYING, "C2 takes Manifest through its normal placement flow")
	var calm_zone := run.get_node_or_null("ZoneAOuterPier/ZoneBFloodedMarket/CalmZoneB") as Area3D
	t.ok(calm_zone != null, "C2 reaches the authored B calm Area3D before its cache")
	if calm_zone == null:
		_cleanup(run)
		return true
	var retriever := run.get_node_or_null("ZoneAOuterPier/Retriever") as RetrieverController
	t.ok(retriever != null, "C2 resolves the authored Retriever through its public scene path")
	if retriever == null:
		_cleanup(run)
		return true
	calm_zone.body_entered.emit(retriever)
	var cache_zone := run.get_node_or_null("ZoneAOuterPier/CacheZoneB") as ProximityZone3D
	t.ok(cache_zone != null, "C2 reaches the authored B cache Area3D")
	if cache_zone == null:
		_cleanup(run)
		return true
	cache_zone.retriever_entered.emit()
	run.request_cache()
	await t.tree.process_frame
	var cache_panel := _overlay(run) as LootCachePanel
	t.ok(cache_panel != null and cache_panel.session == LootCachePanel.Session.CARD, "C2 reaches the authored B cache card")
	if cache_panel != null:
		cache_panel.closed.emit()
		await t.tree.process_frame
	var guard := run.get_node_or_null("ZoneAOuterPier/TaxGuard") as EnemyActor
	var foreman := run.get_node_or_null("ZoneAOuterPier/Foreman") as EnemyActor
	t.ok(guard != null and guard.brain != null, "C2 resolves the authored tax guard through its public scene path")
	t.ok(foreman != null and foreman.brain != null, "C2 resolves the authored foreman through its public scene path")
	if guard == null or guard.brain == null or foreman == null or foreman.brain == null:
		_cleanup(run)
		return true
	guard.brain.health.damage(guard.brain.health.max_hp)
	foreman.brain.health.damage(foreman.brain.health.max_hp)
	await t.tree.process_frame
	await t.tree.process_frame
	var cargo_area := run.get_node_or_null("ZoneAOuterPier/ZoneDFloatingWarehouse/CargoD/InteractArea") as Area3D
	t.ok(cargo_area != null, "C2 reaches the authored D cargo Area3D")
	if cargo_area == null:
		_cleanup(run)
		return true
	retriever.global_position = cargo_area.global_position
	await t.tree.physics_frame
	cargo_area.body_entered.emit(retriever)
	run.request_d_source(OuterPierRun.SOURCE_CARGO_D)
	await t.tree.process_frame
	var cargo_panel := _overlay(run) as LootCachePanel
	t.ok(cargo_panel != null and cargo_panel.session == LootCachePanel.Session.CARD, "C2 reaches the authored D cargo card")
	if cargo_panel == null:
		_cleanup(run)
		return true
	(cargo_panel.get_node("LootCacheCard") as LootCacheCard).pickup_requested.emit(cargo_panel.cache.item_at(0))
	await t.tree.process_frame
	cargo_panel.release_cell(RetrieverInventory.BACKPACK, Vector2i.ZERO)
	t.ok(_item_at(RunSession.inventory.backpack, Vector2i.ZERO, &"cargo_d_2x2"), "C2 places D cargo through the normal cache panel")
	var beacon := run.get_node_or_null("ZoneAOuterPier/BeaconZoneA") as ProximityZone3D
	beacon.retriever_entered.emit()
	hud.call_requested.emit()
	await t.tree.process_frame
	var confirm := _overlay(run) as ConfirmDialog
	t.ok(confirm != null, "C2 returns to A and opens the normal call confirmation")
	if confirm == null:
		_cleanup(run)
		return true
	await _wait_seconds(t, 0.35)
	confirm.accepted.emit()
	for _step in 86:
		run.flow.tick(0.25)
	var board := run.get_node_or_null("ZoneAOuterPier/BoardZoneA") as ProximityZone3D
	board.retriever_entered.emit()
	hud.board_requested.emit()
	await t.tree.process_frame
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.S10_SUCCESS, "C2 reaches S10 only after Manifest, B, D, return, call, hold, and board")
	_cleanup(run)
	return true


func test_readiness_c3_dies_through_hp_zero_then_enters_recovery(t) -> bool:
	var run := await _launch(t, &"c3")
	if run == null:
		return true
	t.eq(run.flow.contract_state, ExtractPierAFlow.ContractState.CARRYING, "C3 begins after a real Manifest placement")
	t.ok(_item_at(RunSession.inventory.notary_box, Vector2i(1, 0), &"manifest_r17"), "C3 seals Manifest in the Notary Box")
	t.ok(_item_at(RunSession.inventory.backpack, Vector2i.ZERO, &"cargo_d_2x2"), "C3 carries unsealed cargo to prove loss")
	var retriever := run.get_node_or_null("ZoneAOuterPier/Retriever") as RetrieverController
	t.ok(retriever != null and retriever.combat != null, "C3 uses the live Retriever HP component")
	if retriever == null or retriever.combat == null:
		_cleanup(run)
		return true
	retriever.combat.health.damage(retriever.combat.health.max_hp)
	await t.tree.process_frame
	var recall := _overlay(run) as RecallSigilOverlay
	t.ok(recall != null, "HP zero opens the real Recall Sigil before S11")
	if recall == null:
		_cleanup(run)
		return true
	recall.finish_now()
	await t.tree.process_frame
	var summary := _overlay(run) as DeathSummaryScreen
	t.ok(summary != null and summary.summary.death_variant == &"after_manifest", "C3 reaches S11 from the genuine death path")
	if summary != null:
		t.ok(_summary_has(summary.summary.kept, &"starter_remedy"), "C3 S11 keeps sealed non-evidence")
		t.ok(_summary_has(summary.summary.lost, &"cargo_d_2x2"), "C3 S11 loses unsealed cargo")
		t.eq(summary.summary.unrecovered_evidence, [&"manifest_r17"], "C3 S11 marks Manifest unrecovered")
		await _wait_seconds(t, DeathSummaryScreen.SUMMARY_DEATH_BUTTON_LOCK_SECONDS + 0.1)
		summary.request_primary()
		await t.tree.process_frame
		var recovery := _overlay(run) as RecoveryContractScreen
		t.ok(recovery != null, "C3 S11 action reaches S12 rather than a fixture summary")
		if recovery == null:
			_cleanup(run)
			return true
		recovery.briefing_requested.emit()
		await t.tree.process_frame
		await t.tree.process_frame
	var briefing_flow := t.tree.current_scene as BriefingFlow
	var briefing := briefing_flow.get_node_or_null("Briefing") as BriefingScreen if briefing_flow != null else null
	t.ok(briefing != null and briefing.recovery_mode, "S12 leads to the real recovery briefing")
	if briefing == null:
		return true
	briefing.enter_outer_pier_requested.emit(briefing.inventory)
	await t.tree.process_frame
	await t.tree.process_frame
	var recovery_run := t.tree.current_scene as OuterPierRun
	t.ok(recovery_run != null and recovery_run.flow.can_recover_manifest(), "recovery briefing starts at the dispatch tuple")
	if recovery_run == null:
		return true
	var dispatch := recovery_run.get_node_or_null("ZoneAOuterPier/DispatchZone") as ProximityZone3D
	var hud := recovery_run.get_node_or_null("HudLayer/ExtractHud") as ExtractHud
	dispatch.retriever_entered.emit()
	hud.dispatch_requested.emit()
	await _wait_seconds(t, 0.35)
	var recovery_card := _overlay(recovery_run) as ManifestPickupCard
	t.ok(recovery_card != null, "recovery reaches the real dispatch card")
	if recovery_card == null:
		_cleanup(recovery_run)
		return true
	recovery_card.pickup_requested.emit()
	await t.tree.process_frame
	await _wait_seconds(t, 0.35)
	var pickup := _overlay(recovery_run) as ManifestPickupPanel
	t.ok(pickup != null, "recovery card reaches the public placement panel")
	if pickup == null:
		_cleanup(recovery_run)
		return true
	pickup.tap_cell(RetrieverInventory.BACKPACK, Vector2i.ZERO)
	t.eq(recovery_run.flow.extract_state, ExtractPierAFlow.ExtractState.E1_CALLABLE, "valid recovery placement enables E1")
	var beacon := recovery_run.get_node_or_null("ZoneAOuterPier/BeaconZoneA") as ProximityZone3D
	var board := recovery_run.get_node_or_null("ZoneAOuterPier/BoardZoneA") as ProximityZone3D
	beacon.retriever_entered.emit()
	hud.call_requested.emit()
	await t.tree.process_frame
	var confirm := _overlay(recovery_run) as ConfirmDialog
	t.ok(confirm != null, "recovery E1 opens its normal call confirmation")
	if confirm == null:
		_cleanup(recovery_run)
		return true
	await _wait_seconds(t, 0.35)
	confirm.accepted.emit()
	for _step in 86:
		recovery_run.flow.tick(0.25)
	board.retriever_entered.emit()
	hud.board_requested.emit()
	await t.tree.process_frame
	t.eq(recovery_run.flow.extract_state, ExtractPierAFlow.ExtractState.S10_SUCCESS, "C3 reaches S10 only after recovery, call, hold, and board")
	_cleanup(recovery_run)
	return true


func test_readiness_inv_1_route_stays_contract_1_easy_with_a_as_only_extract(t) -> bool:
	var flow := _normal_flow()
	t.eq(flow.contract_state, ExtractPierAFlow.ContractState.NOT_TAKEN, "normal readiness starts Contract 1 at dispatch")
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.E0_UNAVAILABLE, "A extract stays unavailable before Manifest")
	RunSession.clear()
	return true


func test_readiness_inv_2_flow_exposes_no_out_of_scope_completion_path(t) -> bool:
	var flow := _normal_flow()
	t.ok(not flow.request_call(), "no call path exists before carrying Manifest")
	t.ok(not flow.board(), "no board path skips A call and hold")
	RunSession.clear()
	return true


func test_readiness_inv_3_beacon_call_hold_and_board_are_distinct_states(t) -> bool:
	var flow := _carrying_flow()
	flow.set_in_beacon_zone(true)
	t.ok(flow.request_call(), "E1 opens call confirmation")
	t.ok(flow.confirm_call(), "confirmation enters S7")
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.S7_CALL_ACCEPTED, "call acceptance is distinct from hold")
	for _step in 6:
		flow.tick(0.25)
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.S8_HOLD, "S7 acknowledgement enters hold")
	t.ok(not flow.board(), "hold cannot auto-board")
	RunSession.clear()
	return true


func test_readiness_inv_5_invalid_placement_preserves_the_source_without_automation(t) -> bool:
	var flow := _normal_flow()
	var before := RunSession.inventory.snapshot()
	var result := RunSession.inventory.commit_pickup(RunSession.ground_manifest, RetrieverInventory.SLING_POUCH, Vector2i.ZERO, false)
	t.ok(not result.ok, "Manifest cannot enter the sling pouch")
	t.eq(RunSession.inventory.snapshot(), before, "invalid placement does not drop, swap, sort, or seal")
	t.eq(flow.contract_state, ExtractPierAFlow.ContractState.NOT_TAKEN, "invalid placement preserves the source state")
	RunSession.clear()
	return true


func test_readiness_inv_6_sealed_manifest_death_is_unrecovered_and_keeps_non_evidence(t) -> bool:
	var flow := _carrying_flow(RetrieverInventory.NOTARY_BOX, Vector2i(1, 0))
	flow.notify_death()
	var summary := flow.resolve_death_summary()
	t.eq(flow.contract_state, ExtractPierAFlow.ContractState.UNRECOVERED, "death after sealed Manifest becomes unrecovered")
	t.ok(_summary_has(summary.kept, &"starter_remedy"), "sealed non-evidence stays kept")
	t.eq(summary.unrecovered_evidence, [&"manifest_r17"], "Manifest is neither kept nor extracted")
	RunSession.clear()
	return true


func test_readiness_inv_8_success_summary_only_exists_after_explicit_board(t) -> bool:
	var flow := _carrying_flow()
	flow.set_in_beacon_zone(true)
	flow.request_call()
	flow.confirm_call()
	for _step in 86:
		flow.tick(0.25)
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.S9_BOAT_READY, "S9 remains boat-ready rather than a success state before board")
	flow.set_in_board_zone(true)
	var summary := flow.board()
	t.ok(summary != null and flow.extract_state == ExtractPierAFlow.ExtractState.S10_SUCCESS, "board alone creates the success summary")
	RunSession.clear()
	return true


func _launch(t, fixture_id: StringName) -> OuterPierRun:
	AppEnv.load_for("dev")
	RunSession.clear()
	t.tree.change_scene_to_packed(BOOT_SCENE)
	await t.tree.process_frame
	var boot := t.tree.current_scene as Control
	var menu := boot.get_node_or_null("RecoveryFixtureMenu") as RecoveryFixtureMenu if boot != null else null
	if not t.ok(menu != null, "debug Boot exposes the controlled fixture menu"):
		return null
	var button := menu.button_for(fixture_id)
	if not t.ok(button != null, "%s fixture has a menu action" % fixture_id):
		return null
	button.pressed.emit()
	for _frame in 12:
		await t.tree.process_frame
	var run := t.tree.current_scene as OuterPierRun
	t.ok(run != null and run.flow != null, "%s enters a real OuterPierRun" % fixture_id)
	return run


func _launch_c2_through_briefing(t) -> OuterPierRun:
	AppEnv.load_for("dev")
	RunSession.clear()
	t.tree.change_scene_to_packed(BOOT_SCENE)
	await t.tree.process_frame
	var boot := t.tree.current_scene as Control
	var enter_port := boot.get_node_or_null("EnterOuterPierButton") as Button if boot != null else null
	if not t.ok(enter_port != null, "C2 starts from Boot's public enter-port action"):
		return null
	enter_port.pressed.emit()
	await t.tree.process_frame
	await t.tree.process_frame
	var briefing_flow := t.tree.current_scene as BriefingFlow
	var briefing := briefing_flow.get_node_or_null("Briefing") as BriefingScreen if briefing_flow != null else null
	if not t.ok(briefing != null and not briefing.recovery_mode, "C2 traverses the real normal S1 briefing before S2"):
		return null
	briefing.enter_outer_pier_requested.emit(briefing.inventory)
	for _frame in 4:
		await t.tree.process_frame
	var run := t.tree.current_scene as OuterPierRun
	t.ok(run != null and run.flow != null, "C2 enters the real S2 OuterPierRun from S1")
	return run


func _normal_flow() -> ExtractPierAFlow:
	RunSession.clear()
	RunSession.begin_briefing()
	return RunSession.begin_run(RunSession.inventory)


func _carrying_flow(grid: StringName = RetrieverInventory.BACKPACK, anchor: Vector2i = Vector2i.ZERO) -> ExtractPierAFlow:
	var flow := _normal_flow()
	RunSession.inventory.commit_pickup(RunSession.ground_manifest, grid, anchor, false)
	return flow


func _item_at(grid: InventoryGrid, anchor: Vector2i, def_id: StringName) -> bool:
	var item := grid.item_at(anchor)
	return item != null and item.def_id == def_id


func _summary_has(entries: Array[Dictionary], def_id: StringName) -> bool:
	for entry in entries:
		if StringName(entry.get("def_id", &"")) == def_id:
			return true
	return false


func _overlay(run: OuterPierRun) -> Control:
	var layer := run.get_node_or_null("OverlayLayer") as CanvasLayer
	return layer.get_child(0) as Control if layer != null and layer.get_child_count() > 0 else null


func _cleanup(run: OuterPierRun) -> void:
	if is_instance_valid(run):
		run.queue_free()
	RunSession.clear()


func _wait_seconds(t, seconds: float) -> void:
	await t.tree.create_timer(seconds).timeout
