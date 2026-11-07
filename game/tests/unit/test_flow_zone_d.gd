extends RefCounted

const BOOT_SCENE := preload("res://src/boot/boot.tscn")


func test_flow_zone_d_cargo_route_uses_authored_areas_then_extracts(t) -> bool:
	var run := await _new_run_from_boot_through_loadout(t)
	if run == null:
		return true
	await _take_manifest_to_notary(t, run)
	await _open_d_route(t, run)
	await _enter(t, run, "CalmZoneB")
	await _leave_to(t, run, "CalmZoneB", "CalmZoneD")
	t.ok(not run._patrol_started, "walking B to D never fires the return patrol")
	await _enter(t, run, "CargoD/InteractArea")
	t.ok(bool(run._d_source_in_range.get(OuterPierRun.SOURCE_CARGO_D, false)), "CargoD Area3D marks its source in range")
	t.ok(run._overlay == null, "no prior overlay blocks CargoD interaction")
	run.request_d_source(OuterPierRun.SOURCE_CARGO_D)
	var panel := run._overlay as LootCachePanel
	t.ok(panel != null and panel.session == LootCachePanel.Session.CARD, "CargoD opens the shared S04 card only inside its authored Area3D")
	if panel == null:
		return true
	(panel.get_node("LootCacheCard/CacheCardPanel/Rows/Actions/PickAndPlaceButton") as Button).pressed.emit()
	t.ok(panel.release_cell(RetrieverInventory.BACKPACK, Vector2i.ZERO).ok, "cargo is placed through the real pickup dock")
	t.eq(run._cargo_cache.cache_state(), &"empty", "picked cargo leaves its one-item source empty")
	var cargo_block := run._zone_d.get_node("CargoD/ItemBlock") as StaticBody3D
	t.ok(not cargo_block.visible and cargo_block.collision_layer == 0, "empty CargoD hides and disables only its item block")
	await _leave_to(t, run, "CalmZoneD", "PatrolTriggerB")
	t.ok(run._patrol_started and run._patrol_director != null, "D to B return patrol starts at PatrolTriggerB exactly once")
	await _finish_extract(t, run)
	var summary := (run._overlay as ExtractSummaryScreen).summary
	t.ok(_contains(summary.kept, &"cargo_d_2x2"), "S10 keeps cargo selected at D")
	t.eq(summary.backpack_cells_used, 4, "S10 counts cargo's four occupied backpack cells")
	run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func test_flow_zone_d_stamp_rejection_withdraw_and_seal_uses_o5(t) -> bool:
	var run := await _new_run_from_boot_through_loadout(t)
	if run == null:
		return true
	await _take_manifest_to_notary(t, run)
	await _open_d_route(t, run)
	await _enter(t, run, "CalmZoneB")
	await _leave_to(t, run, "CalmZoneB", "CalmZoneD")
	await _enter(t, run, "TaxStampD/InteractArea")
	t.ok(bool(run._d_source_in_range.get(OuterPierRun.SOURCE_TAX_STAMP_D, false)), "TaxStampD Area3D marks its source in range")
	t.ok(run._overlay == null, "no prior overlay blocks TaxStampD interaction")
	run.request_d_source(OuterPierRun.SOURCE_TAX_STAMP_D)
	var panel := run._overlay as LootCachePanel
	if not t.ok(panel != null, "TaxStampD opens its source card from Area3D"):
		return true
	(panel.get_node("LootCacheCard/CacheCardPanel/Rows/Actions/PickAndPlaceButton") as Button).pressed.emit()
	var before := RunSession.inventory.snapshot()
	var denied := panel.release_cell(RetrieverInventory.NOTARY_BOX, Vector2i.ZERO)
	t.eq(denied.reason, InventoryReason.Value.CELLS_OCCUPIED, "full Notary Box rejects the Tax Stamp without an auto-swap")
	t.eq(RunSession.inventory.snapshot(), before, "rejected direct seal preserves the complete fixture snapshot")
	t.ok(panel.release_cell(RetrieverInventory.BACKPACK, Vector2i(2, 0)).ok, "Tax Stamp can instead enter the backpack")
	await t.tree.process_frame
	run._hud.inventory_requested.emit()
	await t.tree.process_frame
	var inventory_panel := run._overlay as LootCachePanel
	var remedy_button := inventory_panel.get_node_or_null("LootGridPanel/NotaryBox/Item_1") as Button
	if not t.ok(remedy_button != null, "run dock exposes the sealed starter remedy"):
		return true
	remedy_button.pressed.emit()
	inventory_panel.request_withdraw()
	t.ok(inventory_panel.release_cell(RetrieverInventory.BACKPACK, Vector2i(0, 0)).ok, "withdraw preview uses the offered backpack cells")
	t.ok(inventory_panel._confirmation != null, "withdraw opens the inventory O5 before mutation")
	inventory_panel._confirmation.accepted.emit()
	await t.tree.process_frame
	var stamp_button := inventory_panel.get_node_or_null("LootGridPanel/Backpack/Item_202") as Button
	if not t.ok(stamp_button != null, "confirmed pickup leaves Tax Stamp selected through the run dock"):
		return true
	stamp_button.pressed.emit()
	t.ok(inventory_panel.release_cell(RetrieverInventory.NOTARY_BOX, Vector2i.ZERO).ok, "only after O5 withdraw can Tax Stamp be sealed")
	t.ok(RunSession.inventory.notary_box.items.has(202), "Tax Stamp is sealed in the freed Notary Box column")
	(inventory_panel.get_node("CloseButton") as Button).pressed.emit()
	await t.tree.process_frame
	await _leave_to(t, run, "CalmZoneD", "PatrolTriggerB")
	t.ok(run._patrol_started, "sealed Tax Stamp route returns through the authored B patrol trigger")
	await _finish_extract(t, run)
	var summary := (run._overlay as ExtractSummaryScreen).summary
	t.ok(_contains(summary.kept, &"tax_stamp_d"), "S10 keeps the sealed Tax Stamp after the complete D to B to A return")
	t.eq(summary.backpack_cells_used, 2, "S10 reports the two backpack cells used by the withdrawn starter remedy")
	run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func test_flow_zone_d_death_resolves_s11_without_extract(t) -> bool:
	var run := await _new_run_from_boot_through_loadout(t)
	if run == null:
		return true
	await _take_manifest_to_notary(t, run)
	await _open_d_route(t, run)
	await _enter(t, run, "CargoD/InteractArea")
	run.request_d_source(OuterPierRun.SOURCE_CARGO_D)
	var panel := run._overlay as LootCachePanel
	if panel == null:
		return true
	(panel.get_node("LootCacheCard/CacheCardPanel/Rows/Actions/PickAndPlaceButton") as Button).pressed.emit()
	t.ok(panel.release_cell(RetrieverInventory.BACKPACK, Vector2i.ZERO).ok, "G17 carries cargo from D before HP reaches zero")
	run._retriever.combat.health.damage(run._retriever.combat.health.max_hp)
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.ENDED_DEATH, "HP zero ends extraction before any S10 transition")
	t.ok(run._overlay != null and run._overlay.name == "RecallSigilOverlay", "death starts the Recall Sigil overlay")
	await _wait_seconds(t, OuterPierRun.RECALL_SIGIL_SECONDS + 0.1)
	var screen := run._overlay as DeathSummaryScreen
	t.ok(screen != null, "Recall Sigil resolves into S11")
	if screen != null:
		t.eq(screen.summary.death_variant, &"after_manifest", "Manifest carried in the Notary Box selects G17")
		t.ok(_contains(screen.summary.kept, &"starter_remedy"), "sealed remedy is kept")
		t.ok(_contains(screen.summary.lost, &"cargo_d_2x2"), "unsealed cargo is lost")
		t.eq(screen.summary.unrecovered_evidence, [&"manifest_r17"], "Manifest is unrecovered, never kept or lost")
		t.eq(run.flow.contract_state, ExtractPierAFlow.ContractState.UNRECOVERED, "after-Manifest death updates the contract once")
	run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func test_flow_recall_sigil_absorbs_back_and_touch_until_completion(t) -> bool:
	var run := await _new_run_from_boot_through_loadout(t)
	if run == null:
		return true
	run._retriever.combat.health.damage(run._retriever.combat.health.max_hp)
	var recall := run._overlay as RecallSigilOverlay
	if not t.ok(recall != null, "HP zero opens the authored Recall Sigil overlay"):
		return true
	t.ok(recall.get_node_or_null("Sigil/Ring") is ProgressBar, "Recall Sigil presents its progress ring before S11")
	var back := InputEventAction.new()
	back.action = &"ui_cancel"
	back.pressed = true
	t.tree.root.get_viewport().push_input(back, true)
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.position = Vector2(640.0, 360.0)
	touch.pressed = true
	t.tree.root.get_viewport().push_input(touch, true)
	await t.tree.process_frame
	t.eq(t.tree.current_scene, run, "Back and touch during O7 do not change scene")
	t.eq(run._overlay, recall, "Back and touch during O7 do not bypass the Recall Sigil")
	t.ok(recall.is_inside_tree(), "Recall Sigil stays open until its completed signal")
	await _wait_seconds(t, RecallSigilOverlay.RECALL_SIGIL_SECONDS + 0.1)
	t.ok(run._overlay is DeathSummaryScreen, "only Recall Sigil completion opens S11")
	run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func test_flow_death_before_manifest_prepares_and_hold_and_boat_ready_deaths_never_extract(t) -> bool:
	var before_run := await _new_run_from_boot_through_loadout(t)
	if before_run == null:
		return true
	await _enter(t, before_run, "BEntryZone")
	t.eq(before_run._route_beat, OuterPierRun.RouteBeat.GUARD, "G16 enters B through its authored Area3D before Manifest pickup")
	before_run._retriever.combat.health.damage(before_run._retriever.combat.health.max_hp)
	await _wait_seconds(t, OuterPierRun.RECALL_SIGIL_SECONDS + 0.1)
	var before_screen := before_run._overlay as DeathSummaryScreen
	t.ok(before_screen != null and before_screen.summary.death_variant == &"before_manifest", "G16 sends HP zero before Manifest to the before-Manifest S11")
	if before_screen != null:
		await _wait_seconds(t, DeathSummaryScreen.SUMMARY_DEATH_BUTTON_LOCK_SECONDS + 0.1)
		before_screen.request_primary()
	await t.tree.process_frame
	await t.tree.process_frame
	t.ok(t.tree.current_scene is BriefingFlow and RunSession.inventory != null, "G16 Prepare creates a fresh briefing inventory")
	if is_instance_valid(before_run) and before_run.is_inside_tree():
		before_run.queue_free()
	RunSession.clear()
	await t.tree.process_frame

	var hold_run := await _new_run_from_boot_through_loadout(t)
	if hold_run == null:
		return true
	await _take_manifest_to_notary(t, hold_run)
	await _enter(t, hold_run, "BeaconZoneA")
	hold_run._hud.call_requested.emit()
	await t.tree.process_frame
	var dialog := hold_run._overlay as ConfirmDialog
	if dialog == null:
		return true
	_accept_dialog(dialog)
	await _advance_scene_seconds(t, ExtractPierAFlow.EXTRACT_CALL_ACK_SECONDS + 0.1)
	t.eq(hold_run.flow.extract_state, ExtractPierAFlow.ExtractState.S8_HOLD, "fixture enters the real hold before HP zero")
	hold_run._retriever.combat.health.damage(hold_run._retriever.combat.health.max_hp)
	t.eq(hold_run.flow.extract_state, ExtractPierAFlow.ExtractState.ENDED_DEATH, "HP zero during hold terminates extract")
	await _wait_seconds(t, OuterPierRun.RECALL_SIGIL_SECONDS + 0.1)
	var hold_screen := hold_run._overlay as DeathSummaryScreen
	t.ok(hold_screen != null and hold_screen.summary.death_variant == &"after_manifest", "hold death resolves the after-Manifest S11")
	t.ok(not (hold_run._overlay is ExtractSummaryScreen), "hold death never opens S10")
	hold_run.queue_free()
	RunSession.clear()
	await t.tree.process_frame

	var boat_ready_run := await _new_run_from_boot_through_loadout(t)
	if boat_ready_run == null:
		return true
	await _take_manifest_to_notary(t, boat_ready_run)
	var extract_successes := 0
	boat_ready_run.flow.extract_succeeded.connect(func(_summary: ExtractSummary) -> void: extract_successes += 1)
	await _enter(t, boat_ready_run, "BeaconZoneA")
	boat_ready_run._hud.call_requested.emit()
	await t.tree.process_frame
	var boat_dialog := boat_ready_run._overlay as ConfirmDialog
	if boat_dialog == null:
		return true
	_accept_dialog(boat_dialog)
	await _advance_scene_seconds(t, ExtractPierAFlow.EXTRACT_CALL_ACK_SECONDS + ExtractPierAFlow.EXTRACT_HOLD_SECONDS + 0.2)
	t.eq(boat_ready_run.flow.extract_state, ExtractPierAFlow.ExtractState.S9_BOAT_READY, "public call and engine frames reach boat-ready before boarding")
	await _enter(t, boat_ready_run, "BoardZoneA")
	t.ok(boat_ready_run.flow.can_board(), "S9 board zone allows boarding before HP reaches zero")
	boat_ready_run._retriever.combat.health.damage(boat_ready_run._retriever.combat.health.max_hp)
	t.eq(boat_ready_run.flow.extract_state, ExtractPierAFlow.ExtractState.ENDED_DEATH, "HP zero in S9 ends the run before boarding")
	t.eq(extract_successes, 0, "S9 death emits no extraction success")
	await _wait_seconds(t, OuterPierRun.RECALL_SIGIL_SECONDS + 0.1)
	var boat_ready_screen := boat_ready_run._overlay as DeathSummaryScreen
	t.ok(boat_ready_screen != null and boat_ready_screen.summary.death_variant == &"after_manifest", "S9 death resolves the after-Manifest S11")
	t.ok(not (boat_ready_run._overlay is ExtractSummaryScreen), "S9 death never completes boarding into S10")
	boat_ready_run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func test_flow_context_target_prefers_nearest_ground_drop_over_d_source(t) -> bool:
	var run := await _new_run_from_boot_through_loadout(t)
	if run == null:
		return true
	await _enter(t, run, "CargoD/InteractArea")
	await _drop_backpack_item(t, run, 301, Vector2i.ZERO)
	var drop := run._ground_drops.get(301) as GroundDrop
	if not t.ok(drop != null, "confirmed drop creates a candidate beside CargoD"):
		return true
	drop.global_position = run._retriever.global_position
	drop.retriever_entered.emit(drop)
	t.ok(run._ground_button.visible, "nearest GroundDrop is the only visible context target beside CargoD")
	t.ok(not run._cargo_button.visible, "CargoD context is hidden while a nearer GroundDrop is available")
	run.request_d_source(OuterPierRun.SOURCE_CARGO_D)
	t.ok(run._overlay == null, "hidden CargoD target cannot be opened directly while GroundDrop is nearer")
	run.request_ground_drop()
	t.ok(run._overlay is LootCachePanel, "nearest GroundDrop remains interactable through its public request")
	if run._overlay is LootCachePanel:
		(run._overlay.get_node("LootCacheCard/CloseButton") as Button).pressed.emit()
	run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func test_flow_rotated_tax_stamp_drop_creates_upright_ground_drop(t) -> bool:
	var run := await _new_run_from_boot_through_loadout(t)
	if run == null:
		return true
	var stamp := ItemInstance.new(202, RunSession.inventory.registry.get_def(&"tax_stamp_d"))
	t.ok(RunSession.inventory.commit_pickup(stamp, RetrieverInventory.BACKPACK, Vector2i.ZERO, false).ok, "Tax Stamp enters the backpack through the public pickup rule")
	t.ok(RunSession.inventory.commit_rotate(stamp.uid).ok, "Tax Stamp is rotated before its O5 drop")
	t.ok((RunSession.inventory.backpack.items[stamp.uid] as ItemInstance).rotated, "fixture confirms the carried Tax Stamp is rotated")
	run._hud.inventory_requested.emit()
	await t.tree.process_frame
	var panel := run._overlay as LootCachePanel
	if not t.ok(panel != null, "run dock opens for the rotated Tax Stamp"):
		return true
	var stamp_button := panel.get_node_or_null("LootGridPanel/Backpack/Item_202") as Button
	if not t.ok(stamp_button != null, "run dock exposes the rotated Tax Stamp"):
		return true
	stamp_button.pressed.emit()
	panel.request_drop()
	if not t.ok(panel._confirmation != null, "dropping the rotated Tax Stamp opens O5"):
		return true
	panel._confirmation.accepted.emit()
	await t.tree.process_frame
	var drop := run._ground_drops.get(stamp.uid) as GroundDrop
	t.ok(drop != null and drop.item != null, "confirmed O5 drop creates the world GroundDrop")
	if drop != null and drop.item != null:
		t.ok(not drop.item.rotated, "GroundDrop retains the Tax Stamp upright after a rotated drop")
	run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func test_flow_d_source_exit_preserves_pending_drop_confirmation(t) -> bool:
	var run := await _new_run_from_boot_through_loadout(t)
	if run == null:
		return true
	var coin := ItemInstance.new(303, RunSession.inventory.registry.get_def(&"scraped_tax_coin"))
	t.ok(RunSession.inventory.commit_pickup(coin, RetrieverInventory.BACKPACK, Vector2i.ZERO, false).ok, "drop fixture enters the backpack through the inventory rule")
	await _enter(t, run, "CargoD/InteractArea")
	run._hud.inventory_requested.emit()
	await t.tree.process_frame
	var panel := run._overlay as LootCachePanel
	if not t.ok(panel != null, "the public inventory request opens its dock inside CargoD"):
		return true
	var coin_button := panel.get_node_or_null("LootGridPanel/Backpack/Item_303") as Button
	if not t.ok(coin_button != null, "the run dock exposes the drop fixture"):
		return true
	coin_button.pressed.emit()
	panel.request_drop()
	if not t.ok(panel.has_pending_confirmation(), "drop opens O5 before any inventory mutation"):
		return true
	var before := RunSession.inventory.snapshot()
	await _leave_to(t, run, "CargoD/InteractArea", "CalmZoneD")
	t.ok(run._overlay == panel and panel.has_pending_confirmation(), "leaving CargoD keeps the pending drop O5 open")
	t.eq(RunSession.inventory.snapshot(), before, "leaving CargoD does not commit the pending drop")
	t.ok(not run._ground_drops.has(303), "leaving CargoD creates no GroundDrop")
	OS.delay_msec(350)
	(panel.get_node("InventoryConfirm") as InventoryConfirmPanel).confirm()
	await t.tree.process_frame
	t.ok(run._ground_drops.has(303), "the preserved O5 commits exactly once after its input guard")
	t.eq(run._ground_drops.size(), 1, "one accepted O5 creates exactly one GroundDrop")
	t.ok(not RunSession.inventory.backpack.items.has(303), "confirmed drop removes the item after source exit")
	run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func test_flow_d_source_exit_preserves_pending_withdraw_confirmation(t) -> bool:
	var run := await _new_run_from_boot_through_loadout(t)
	if run == null:
		return true
	await _enter(t, run, "TaxStampD/InteractArea")
	run._hud.inventory_requested.emit()
	await t.tree.process_frame
	var panel := run._overlay as LootCachePanel
	if not t.ok(panel != null, "the public inventory request opens its dock inside TaxStampD"):
		return true
	var remedy_button := panel.get_node_or_null("LootGridPanel/NotaryBox/Item_1") as Button
	if not t.ok(remedy_button != null, "the run dock exposes the sealed starter remedy"):
		return true
	remedy_button.pressed.emit()
	panel.request_withdraw()
	t.ok(panel.release_cell(RetrieverInventory.BACKPACK, Vector2i.ZERO).ok, "withdraw preview chooses a valid backpack destination")
	if not t.ok(panel.has_pending_confirmation(), "withdraw opens O5 before any inventory mutation"):
		return true
	var before := RunSession.inventory.snapshot()
	await _leave_to(t, run, "TaxStampD/InteractArea", "CalmZoneD")
	t.ok(run._overlay == panel and panel.has_pending_confirmation(), "leaving TaxStampD keeps the pending withdraw O5 open")
	t.eq(RunSession.inventory.snapshot(), before, "leaving TaxStampD does not commit the pending withdraw")
	OS.delay_msec(350)
	(panel.get_node("InventoryConfirm") as InventoryConfirmPanel).confirm()
	await t.tree.process_frame
	t.ok(RunSession.inventory.backpack.items.has(1), "the preserved withdraw O5 moves the remedy after its input guard")
	t.ok(not RunSession.inventory.notary_box.items.has(1), "confirmed withdraw removes the remedy from the Notary Box")
	run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func test_flow_ground_drop_is_hidden_and_rejected_during_hold(t) -> bool:
	var run := await _new_run_from_boot_through_loadout(t)
	if run == null:
		return true
	await _take_manifest_to_notary(t, run)
	await _drop_backpack_item(t, run, 301, Vector2i.ZERO)
	var drop := run._ground_drops.get(301) as GroundDrop
	if not t.ok(drop != null, "hold fixture creates a confirmed GroundDrop"):
		return true
	await _enter(t, run, "BeaconZoneA")
	drop.global_position = run._retriever.global_position
	drop.retriever_entered.emit(drop)
	run._hud.call_requested.emit()
	await t.tree.process_frame
	var dialog := run._overlay as ConfirmDialog
	if dialog == null:
		return true
	_accept_dialog(dialog)
	await _advance_scene_seconds(t, ExtractPierAFlow.EXTRACT_CALL_ACK_SECONDS + 0.1)
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.S8_HOLD, "fixture enters S8 while standing beside the GroundDrop")
	t.ok(not run._ground_button.visible, "GroundDrop context is hidden during extraction hold")
	run.request_ground_drop()
	t.ok(run._overlay == null, "GroundDrop request is rejected during extraction hold")
	run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func test_flow_ground_drop_overlap_reselects_and_skip_advances_by_distance_then_uid(t) -> bool:
	var run := await _new_run_from_boot_through_loadout(t)
	if run == null:
		return true
	await _drop_backpack_item(t, run, 302, Vector2i.ZERO)
	await _drop_backpack_item(t, run, 301, Vector2i(1, 0))
	var farther_lower_uid := run._ground_drops.get(301) as GroundDrop
	var nearer_higher_uid := run._ground_drops.get(302) as GroundDrop
	if not t.ok(farther_lower_uid != null and nearer_higher_uid != null, "two O5-confirmed drops create their authored GroundDrop areas"):
		return true
	nearer_higher_uid.global_position = Vector3.ZERO
	farther_lower_uid.global_position = Vector3(1.0, 0.0, 0.0)
	run._retriever.global_position = Vector3(0.25, 0.0, 0.0)
	nearer_higher_uid.retriever_entered.emit(nearer_higher_uid)
	farther_lower_uid.retriever_entered.emit(farther_lower_uid)
	t.eq(run._nearest_ground_drop.item.uid, 302, "nearer GroundDrop wins even when its UID is higher")
	run._retriever.global_position = Vector3(2.4, 0.0, 0.0)
	nearer_higher_uid.retriever_exited.emit(nearer_higher_uid)
	t.eq(run._nearest_ground_drop.item.uid, 301, "leaving one overlapping Area3D keeps the remaining GroundDrop interactable")
	t.ok(run._ground_button.visible, "remaining in-range GroundDrop keeps the interaction button visible")
	run._retriever.global_position = Vector3(0.25, 0.0, 0.0)
	nearer_higher_uid.retriever_entered.emit(nearer_higher_uid)
	run.request_ground_drop()
	var first_panel := run._overlay as LootCachePanel
	if not t.ok(first_panel != null and first_panel.cache.item_at(0).uid == 302, "GroundDrop card opens the nearest in-range source"):
		return true
	(first_panel.get_node("LootCacheCard/CacheCardPanel/Rows/Actions/SkipButton") as Button).pressed.emit()
	var second_panel := run._overlay as LootCachePanel
	t.ok(second_panel != null and second_panel.cache.item_at(0).uid == 301, "skipping a GroundDrop opens the next eligible source by distance")
	if second_panel != null:
		(second_panel.get_node("LootCacheCard/CacheCardPanel/Rows/Actions/SkipButton") as Button).pressed.emit()
	nearer_higher_uid.global_position = Vector3.ZERO
	farther_lower_uid.global_position = Vector3.ZERO
	nearer_higher_uid.retriever_exited.emit(nearer_higher_uid)
	farther_lower_uid.retriever_exited.emit(farther_lower_uid)
	nearer_higher_uid.retriever_entered.emit(nearer_higher_uid)
	farther_lower_uid.retriever_entered.emit(farther_lower_uid)
	run.request_ground_drop()
	var tied_panel := run._overlay as LootCachePanel
	t.ok(tied_panel != null and tied_panel.cache.item_at(0).uid == 301, "equal-distance GroundDrops choose the lower UID")
	if tied_panel != null:
		(tied_panel.get_node("LootCacheCard/CloseButton") as Button).pressed.emit()
	run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func test_flow_confirmed_ground_drop_left_behind_appears_in_s10_lost_group(t) -> bool:
	var run := await _new_run_from_boot_through_loadout(t)
	if run == null:
		return true
	await _take_manifest_to_notary(t, run)
	await _drop_backpack_item(t, run, 301, Vector2i.ZERO)
	t.ok(run._ground_drops.has(301), "an O5-confirmed drop remains in the world before extract")
	await _finish_extract(t, run)
	var screen := run._overlay as ExtractSummaryScreen
	if not t.ok(screen != null, "boarding after a confirmed GroundDrop opens S10"):
		return true
	var left_behind := _entry_for_uid(screen.summary.lost, 301)
	t.ok(not left_behind.is_empty(), "S10 records the exact UID of the uncollected GroundDrop as lost")
	t.eq(left_behind.get("def_id", &""), &"scraped_tax_coin", "S10 preserves the uncollected GroundDrop definition")
	var lost_reason := screen.get_node_or_null("LeftScroll/LeftGroups/LostGroup/Content/Line1") as Label
	t.ok(lost_reason != null, "S10 renders a lost-reason line for the uncollected GroundDrop")
	if lost_reason != null:
		t.eq(lost_reason.text, tr(&"SUMMARY_SUCCESS_LOST_LEFT_BEHIND"), "S10 labels the GroundDrop with the left-behind copy")
	run.queue_free()
	RunSession.clear()
	await t.tree.process_frame
	return true


func _take_manifest_to_notary(t, run: OuterPierRun) -> void:
	await _enter(t, run, "DispatchZone")
	run.request_dispatch()
	var card := run._overlay as ManifestPickupCard
	if card == null:
		return
	card.pickup_requested.emit()
	await t.tree.process_frame
	var panel := run._overlay as ManifestPickupPanel
	if panel == null:
		return
	panel.tap_cell(RetrieverInventory.NOTARY_BOX, Vector2i(1, 0))
	panel.closed.emit(true)
	await t.tree.process_frame
	t.eq(run.flow.contract_state, ExtractPierAFlow.ContractState.CARRYING, "Manifest in the Notary Box is still carried")


func _drop_backpack_item(t, run: OuterPierRun, uid: int, anchor: Vector2i) -> void:
	var item := ItemInstance.new(uid, RunSession.inventory.registry.get_def(&"scraped_tax_coin"))
	t.ok(RunSession.inventory.commit_pickup(item, RetrieverInventory.BACKPACK, anchor, false).ok, "fixture item enters the backpack through the inventory rule")
	run._hud.inventory_requested.emit()
	await t.tree.process_frame
	var panel := run._overlay as LootCachePanel
	if panel == null:
		return
	var item_button := panel.get_node_or_null("LootGridPanel/Backpack/Item_%d" % uid) as Button
	if item_button == null:
		return
	item_button.pressed.emit()
	panel.request_drop()
	if panel._confirmation == null:
		return
	panel._confirmation.accepted.emit()
	await t.tree.process_frame
	t.ok(run._ground_drops.has(uid), "O5 confirmation creates the GroundDrop through the run signal")
	if uid == 301:
		(panel.get_node("CloseButton") as Button).pressed.emit()
		await t.tree.process_frame


func _open_d_route(t, run: OuterPierRun) -> void:
	run._guard.brain.health.damage(run._guard.brain.health.max_hp)
	run._foreman.brain.health.damage(run._foreman.brain.health.max_hp)
	await t.tree.process_frame
	await t.tree.process_frame
	t.ok(run._gate_open, "resolving the B lane opens the D route")
	var planks := run._zone_b.get_node("RouteDPlanks") as StaticBody3D
	t.ok(planks.visible and planks.collision_layer == 2, "the public D route open state enables its authored planks")


func _finish_extract(t, run: OuterPierRun) -> void:
	await _enter(t, run, "BeaconZoneA")
	run._hud.call_requested.emit()
	await t.tree.process_frame
	var dialog := run._overlay as ConfirmDialog
	if dialog == null:
		return
	_accept_dialog(dialog)
	await _advance_scene_seconds(t, ExtractPierAFlow.EXTRACT_CALL_ACK_SECONDS + ExtractPierAFlow.EXTRACT_HOLD_SECONDS + 0.2)
	t.eq(run.flow.extract_state, ExtractPierAFlow.ExtractState.S9_BOAT_READY, "call acknowledgement and hold reach the public boarding state")
	await _enter(t, run, "BoardZoneA")
	run._hud.board_requested.emit()
	await t.tree.process_frame
	t.ok(run._overlay is ExtractSummaryScreen, "public board action presents S10")


func _enter(t, run: OuterPierRun, path: String) -> void:
	var zone := _zone(run, path)
	if not t.ok(zone != null, "%s is an authored Area3D" % path):
		return
	run._retriever.global_position = zone.global_position
	await t.tree.physics_frame
	await t.tree.physics_frame
	zone.body_entered.emit(run._retriever)


func _leave_to(t, run: OuterPierRun, from_path: String, to_path: String) -> void:
	var source := _zone(run, from_path)
	var destination := _zone(run, to_path)
	if not t.ok(source != null and destination != null, "route uses authored source and destination areas"):
		return
	run._retriever.global_position = destination.global_position
	await t.tree.physics_frame
	await t.tree.physics_frame
	source.body_exited.emit(run._retriever)
	destination.body_entered.emit(run._retriever)


func _zone(run: OuterPierRun, path: String) -> Area3D:
	for root: Node3D in [run._world, run._zone_b, run._zone_d]:
		if root == null:
			continue
		var zone := root.get_node_or_null(path) as Area3D
		if zone != null:
			return zone
	return null


func _new_run_from_boot_through_loadout(t) -> OuterPierRun:
	RunSession.clear()
	t.tree.change_scene_to_packed(BOOT_SCENE)
	await t.tree.process_frame
	var boot := t.tree.current_scene as Control
	var enter_button := boot.get_node_or_null("EnterOuterPierButton") as Button
	if not t.ok(enter_button != null, "Boot exposes the public entry action for G16"):
		return null
	enter_button.pressed.emit()
	await t.tree.process_frame
	await t.tree.process_frame
	var briefing_flow := t.tree.current_scene as BriefingFlow
	if not t.ok(briefing_flow != null, "Boot routes G16 through BriefingFlow"):
		return null
	var briefing := briefing_flow.get_node_or_null("Briefing") as BriefingScreen
	if not t.ok(briefing != null, "BriefingFlow builds the public briefing screen"):
		return null
	await _wait_for_ui_guard(t, 0.4)
	var loadout_button := _button_for_key(briefing, &"BRIEFING_BUTTON_EDIT_LOADOUT")
	var run_button := _button_for_key(briefing, &"BRIEFING_BUTTON_ENTER")
	if not t.ok(loadout_button != null and run_button != null, "briefing exposes loadout and run actions"):
		return null
	loadout_button.pressed.emit()
	await t.tree.process_frame
	var loadout := briefing_flow.get_node_or_null("Loadout") as LoadoutScreen
	if not t.ok(loadout != null, "G16 traverses the public loadout screen"):
		return null
	await _wait_for_ui_guard(t, 0.4)
	var done_button := _button_for_key(loadout, &"LOADOUT_BUTTON_DONE")
	if not t.ok(done_button != null, "loadout exposes its public completion action"):
		return null
	done_button.pressed.emit()
	await t.tree.process_frame
	run_button.pressed.emit()
	await t.tree.process_frame
	await t.tree.process_frame
	var run := t.tree.current_scene as OuterPierRun
	if not t.ok(run != null, "briefing enters OuterPierRun through the public route"):
		return null
	return run


func _wait_seconds(t, seconds: float) -> void:
	await _advance_scene_seconds(t, seconds)


func _wait_for_ui_guard(t, seconds: float) -> void:
	await t.tree.create_timer(seconds, true, false, true).timeout


func _advance_scene_seconds(t, seconds: float) -> void:
	var original_time_scale := Engine.time_scale
	# Keep each rendered delta below ExtractPierAFlow.MAX_TICK_DELTA so this
	# advances the real scene loop without losing hold time to clamping.
	Engine.time_scale = 8.0
	await t.tree.create_timer(seconds).timeout
	Engine.time_scale = original_time_scale


func _accept_dialog(dialog: ConfirmDialog) -> void:
	dialog.accepted.emit()


func _button_for_key(parent: Control, key: StringName) -> Button:
	if parent == null:
		return null
	for child: Node in parent.get_children():
		var button := child as Button
		if button != null and button.text == tr(key):
			return button
	return null


func _contains(entries: Array[Dictionary], def_id: StringName) -> bool:
	for entry: Dictionary in entries:
		if entry.get("def_id", &"") == def_id:
			return true
	return false


func _entry_for_uid(entries: Array[Dictionary], uid: int) -> Dictionary:
	for entry: Dictionary in entries:
		if int(entry.get("uid", 0)) == uid:
			return entry
	return {}
