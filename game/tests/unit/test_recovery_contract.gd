extends RefCounted

const BOOT_SCENE := preload("res://src/boot/boot.tscn")
const OUTER_PIER_RUN_SCENE := preload("res://src/flow/outer_pier_run.tscn")


func test_recovery_initializer_rejects_invalid_inputs_and_exposes_only_unrecovered_tuple(t) -> bool:
	RunSession.clear()
	RunSession.begin_briefing()
	var normal := RunSession.begin_run(RunSession.inventory)
	normal.notify_death()
	var summary := normal.resolve_death_summary()
	summary.death_variant = &"after_manifest"
	summary.unrecovered_evidence = [&"manifest_r17"]
	t.ok(RunSession.prepare_recovery_briefing(summary), "an after-Manifest death builds recovery briefing state")
	var recovery_inventory := RunSession.inventory
	t.ok(recovery_inventory != null and recovery_inventory.validate().is_empty(), "recovery briefing has a valid basic kit")
	var rejected := RunSession.begin_recovery_run(null, RunSession.recovery_retained)
	t.eq(rejected, null, "missing recovery inventory cannot expose a half flow")
	var flow := RunSession.begin_recovery_run(recovery_inventory, RunSession.recovery_retained)
	t.ok(flow != null, "valid recovery inventory starts a flow")
	if flow != null:
		t.eq(flow.contract_state, ExtractPierAFlow.ContractState.UNRECOVERED, "first observed recovery contract state is unrecovered")
		t.eq(flow.desk_state, ExtractPierAFlow.DeskState.HAS_MANIFEST, "Manifest source is dispatch A")
		t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.E0_UNAVAILABLE, "recovery cannot call before retrieval")
		t.ok(not flow.manifest_carried and RunSession.ground_manifest != null, "Manifest remains exactly at the source")
	RunSession.clear()
	return true


func test_recovery_flow_covers_full_inventory_cancel_drop_repeat_deaths_and_memory_reset(t) -> bool:
	var files_before := _save_files()
	var normal_run := await _new_normal_run(t)
	if normal_run == null:
		return true
	var normal_dispatch := normal_run.get_node_or_null("ZoneAOuterPier/DispatchZone") as ProximityZone3D
	var normal_hud := normal_run.get_node_or_null("HudLayer/ExtractHud") as ExtractHud
	t.ok(normal_dispatch != null and normal_hud != null, "ordinary run exposes dispatch interaction")
	if normal_dispatch != null and normal_hud != null:
		normal_dispatch.retriever_entered.emit()
		normal_hud.dispatch_requested.emit()
		await _wait_seconds(t, 0.35)
		var normal_card := _overlay(normal_run) as ManifestPickupCard
		var normal_action := normal_card.get_node_or_null("CardPanel/PickAndPlaceButton") as Button if normal_card != null else null
		t.ok(normal_card != null and normal_action != null and normal_action.text == tr("CARD_ACTION_PICK_AND_PLACE"), "ordinary dispatch never exposes recovery action")
	if is_instance_valid(normal_run):
		normal_run.queue_free()
	await t.tree.process_frame

	var full_retained := _full_notary_retained()
	var full_summary := _after_manifest_summary(full_retained)
	RunSession.clear()
	t.ok(RunSession.prepare_recovery_briefing(full_summary), "recovery context accepts sealed non-evidence retention")
	var full_inventory := RunSession.inventory
	t.ok(full_inventory != null, "recovery briefing creates an inventory for retained Notary items")
	if full_inventory == null:
		RunSession.clear()
		return true
	t.eq(full_inventory.notary_box.all_items().size(), full_retained.size(), "recovery restores all four retained Notary items")
	for expected: Dictionary in full_retained:
		var anchor: Vector2i = expected.get("anchor", Vector2i.ZERO)
		var retained_item := full_inventory.notary_box.item_at(anchor)
		t.ok(retained_item != null, "recovery restores retained item at Notary Box %s" % anchor)
		if retained_item != null:
			t.eq(retained_item.uid, int(expected.get("uid", -1)), "recovery preserves retained item UID at Notary Box %s" % anchor)
			t.eq(retained_item.def_id, StringName(expected.get("def_id", &"")), "recovery preserves retained item definition at Notary Box %s" % anchor)
			t.eq(retained_item.anchor, anchor, "recovery preserves retained item anchor at Notary Box %s" % anchor)
			t.eq(retained_item.item_location, RetrieverInventory.NOTARY_BOX, "recovery keeps retained item sealed in the Notary Box at %s" % anchor)
	t.eq(full_inventory.notary_box.free_cell_count(), 0, "recovery Notary Box has no free cells before Manifest pickup")
	_fill_backpack(full_inventory)
	var full_flow := RunSession.begin_recovery_run(full_inventory, RunSession.recovery_retained)
	t.ok(full_flow != null and full_flow.can_recover_manifest(), "full inventory recovery begins at the unrecovered dispatch tuple")
	if full_flow != null:
		var source := RunSession.ground_manifest
		var before_snapshot := full_inventory.snapshot()
		var failed := full_inventory.commit_pickup(source, RetrieverInventory.BACKPACK, Vector2i.ZERO, false)
		t.ok(not failed.ok, "full recovery inventory rejects Manifest placement")
		t.eq(full_inventory.snapshot(), before_snapshot, "failed placement does not sort, swap, or move retained items")
		t.eq(full_flow.contract_state, ExtractPierAFlow.ContractState.UNRECOVERED, "failed placement keeps the Manifest unrecovered")
		t.eq(full_flow.desk_state, ExtractPierAFlow.DeskState.HAS_MANIFEST, "failed placement keeps the Manifest at dispatch")
		t.eq(full_flow.extract_state, ExtractPierAFlow.ExtractState.E0_UNAVAILABLE, "failed placement never enables E1")
		var before_backpack_pickup: Dictionary = full_inventory.snapshot()
		var backpack_item := full_inventory.backpack.remove(400)
		t.ok(backpack_item != null, "test frees one backpack cell without altering the Notary Box")
		var picked := full_inventory.commit_pickup(source, RetrieverInventory.BACKPACK, Vector2i.ZERO, false)
		t.ok(picked.ok, "Manifest can recover into a free backpack cell while Notary Box stays full")
		t.eq(full_inventory.snapshot().get("notary_box", []), before_backpack_pickup.get("notary_box", []), "recovery pickup never auto-withdraws or modifies retained Notary items")
		t.eq(full_flow.contract_state, ExtractPierAFlow.ContractState.CARRYING, "valid recovery pickup transitions exactly to carrying")
		t.eq(full_flow.extract_state, ExtractPierAFlow.ExtractState.E1_CALLABLE, "valid recovery pickup enables E1, not success")
		var manifest_uid := source.uid
		var dropped := full_inventory.commit_drop(manifest_uid)
		t.ok(dropped.ok and full_flow.contract_state == ExtractPierAFlow.ContractState.DROPPED, "dropping recovered Manifest returns flow to DROPPED")
		t.eq(full_flow.extract_state, ExtractPierAFlow.ExtractState.E0_UNAVAILABLE, "dropped Manifest disables E1")
		var dropped_manifest := dropped.moved[0].get("item") as ItemInstance if not dropped.moved.is_empty() else null
		var repicked := full_inventory.commit_pickup(dropped_manifest, RetrieverInventory.BACKPACK, Vector2i.ZERO, false)
		t.ok(repicked.ok and full_flow.contract_state == ExtractPierAFlow.ContractState.CARRYING, "dropped Manifest can be legally picked up again")
		t.eq(full_flow.desk_state, ExtractPierAFlow.DeskState.EMPTY, "repickup never turns the same recovery desk into a normal source")
		_assert_recovery_death(t, full_flow, &"after_pickup")

	var before_pickup_flow := _new_recovery_flow(t, _starter_remedy_retained())
	if before_pickup_flow != null:
		before_pickup_flow.notify_death()
		var before_pickup_summary := before_pickup_flow.resolve_death_summary()
		t.ok(before_pickup_summary != null and before_pickup_summary.death_variant == &"after_manifest", "recovery death before pickup remains an after-Manifest death")
		if before_pickup_summary != null:
			t.ok(_summary_has(before_pickup_summary.kept, &"starter_remedy"), "recovery death before pickup keeps sealed remedy")
			t.ok(_summary_has(before_pickup_summary.lost, &"sling_remedy"), "recovery death before pickup loses basic unsealed sling remedy")
			t.eq(before_pickup_summary.unrecovered_evidence, [&"manifest_r17"], "recovery death before pickup reports one unrecovered Manifest")
			t.ok(RunSession.prepare_recovery_briefing(before_pickup_summary), "recovery death before pickup returns to the next S12 briefing")

	for state_name: StringName in [&"s7", &"s8", &"s9"]:
		var state_flow := _new_recovery_flow(t)
		if state_flow == null:
			continue
		var state_manifest := RunSession.ground_manifest
		t.ok(RunSession.inventory.commit_pickup(state_manifest, RetrieverInventory.BACKPACK, Vector2i.ZERO, false).ok, "%s setup carries Manifest" % state_name)
		state_flow.set_in_beacon_zone(true)
		t.ok(state_flow.request_call() and state_flow.confirm_call(), "%s setup accepts a real call" % state_name)
		if state_name == &"s8" or state_name == &"s9":
			for _step in 6:
				state_flow.tick(0.25)
		if state_name == &"s9":
			for _step in 80:
				state_flow.tick(0.25)
		var expected_state := ExtractPierAFlow.ExtractState.S7_CALL_ACCEPTED if state_name == &"s7" else ExtractPierAFlow.ExtractState.S8_HOLD if state_name == &"s8" else ExtractPierAFlow.ExtractState.S9_BOAT_READY
		t.eq(state_flow.extract_state, expected_state, "%s death coverage reaches the real extract state" % state_name)
		_assert_recovery_death(t, state_flow, state_name)

	RunSession.begin_briefing()
	var reset_flow := RunSession.begin_run(RunSession.inventory)
	t.ok(not RunSession.recovery_active and RunSession.recovery_retained.is_empty(), "new normal briefing clears in-memory recovery data")
	t.eq(reset_flow.contract_state, ExtractPierAFlow.ContractState.NOT_TAKEN, "new normal run returns to the ordinary dispatch state")
	t.eq(reset_flow.desk_state, ExtractPierAFlow.DeskState.HAS_MANIFEST, "new normal run places Manifest only at normal dispatch")
	t.eq(_save_files(), files_before, "recovery branches never write a user save file")
	RunSession.clear()
	return true


func test_recovery_end_to_end_follows_death_s12_briefing_dispatch_and_extract(t) -> bool:
	var files_before := _save_files()
	var run := await _new_normal_run(t)
	if run == null:
		return true
	var dispatch_zone := run.get_node_or_null("ZoneAOuterPier/DispatchZone") as ProximityZone3D
	var hud := run.get_node_or_null("HudLayer/ExtractHud") as ExtractHud
	t.ok(dispatch_zone != null and hud != null, "run exposes authored dispatch Area3D and HUD")
	if dispatch_zone == null or hud == null:
		run.queue_free()
		return true
	dispatch_zone.retriever_entered.emit()
	hud.dispatch_requested.emit()
	await _wait_seconds(t, 0.35)
	var card := _overlay(run) as ManifestPickupCard
	t.ok(card != null, "normal dispatch action opens the Manifest card")
	if card == null:
		run.queue_free()
		return true
	var normal_action := card.get_node_or_null("CardPanel/PickAndPlaceButton") as Button
	t.ok(normal_action != null and normal_action.text == tr("CARD_ACTION_PICK_AND_PLACE"), "normal run card has no recovery action")
	card.pickup_requested.emit()
	await t.tree.process_frame
	var pickup := _overlay(run) as ManifestPickupPanel
	t.ok(pickup != null, "Manifest card opens O3/O4")
	if pickup == null:
		run.queue_free()
		return true
	await _wait_seconds(t, 0.35)
	pickup.tap_cell(RetrieverInventory.NOTARY_BOX, Vector2i(1, 0))
	t.eq(run.flow.contract_state, ExtractPierAFlow.ContractState.CARRYING, "valid placement carries Manifest before death")
	var cargo := ItemInstance.new(201, RunSession.inventory.registry.get_def(&"cargo_d_2x2"))
	t.ok(RunSession.inventory.commit_pickup(cargo, RetrieverInventory.BACKPACK, Vector2i.ZERO, false).ok, "C3-equivalent unsealed cargo is carried before genuine death")
	var retriever := t.tree.get_first_node_in_group(&"retriever") as RetrieverController
	t.ok(retriever != null and retriever.combat != null, "live Retriever combat owns the real HP path")
	if retriever == null or retriever.combat == null:
		run.queue_free()
		return true
	retriever.combat.health.damage(retriever.combat.health.max_hp)
	await t.tree.process_frame
	var recall := _overlay(run) as RecallSigilOverlay
	t.ok(recall != null, "real HP depletion opens the Recall Sigil")
	if recall == null:
		run.queue_free()
		return true
	recall.finish_now()
	await t.tree.process_frame
	var death := _overlay(run) as DeathSummaryScreen
	t.ok(death != null and death.summary.death_variant == &"after_manifest", "Recall completion reaches after-Manifest S11")
	if death == null:
		run.queue_free()
		return true
	t.ok(_summary_has(death.summary.kept, &"starter_remedy"), "S11 keeps sealed non-evidence from the Notary Box")
	t.ok(_summary_has(death.summary.lost, &"cargo_d_2x2"), "S11 loses unsealed cargo instead of restoring it")
	await _wait_seconds(t, 1.05)
	var recovery_action := death.get_node_or_null("PrimaryButton") as Button
	t.ok(recovery_action != null, "S11 exposes the public recovery action")
	if recovery_action == null:
		run.queue_free()
		return true
	recovery_action.pressed.emit()
	await t.tree.process_frame
	var recovery := _overlay(run) as RecoveryContractScreen
	t.ok(recovery != null, "S11 recovery action opens the one-action S12")
	if recovery == null:
		run.queue_free()
		return true
	_assert_s12_controls(t, recovery)
	await _wait_seconds(t, 0.35)
	var briefing_action := recovery.get_node_or_null("BriefingButton") as Button
	if not t.ok(briefing_action != null, "S12 exposes the public briefing action"):
		run.queue_free()
		return true
	briefing_action.pressed.emit()
	await t.tree.process_frame
	await t.tree.process_frame
	var briefing_flow := t.tree.current_scene as BriefingFlow
	t.ok(briefing_flow != null and RunSession.is_recovery_briefing(), "S12 enters recovery briefing without clearing memory state")
	if briefing_flow == null:
		return true
	var briefing := briefing_flow.get_node_or_null("Briefing") as BriefingScreen
	t.ok(briefing != null and briefing.recovery_mode, "existing briefing renders its recovery variant")
	if briefing == null:
		return true
	var recovery_run := await _enter_run_through_cancelled_loadout(t, true)
	t.ok(recovery_run != null and recovery_run.flow.can_recover_manifest(), "recovery run starts at the dispatch availability tuple")
	if recovery_run == null:
		return true
	_assert_recovery_kit(t, RunSession.inventory)
	var recovery_dispatch := recovery_run.get_node_or_null("ZoneAOuterPier/DispatchZone") as ProximityZone3D
	var recovery_hud := recovery_run.get_node_or_null("HudLayer/ExtractHud") as ExtractHud
	recovery_dispatch.retriever_entered.emit()
	recovery_hud.dispatch_requested.emit()
	await _wait_seconds(t, 0.35)
	var recovery_card := _overlay(recovery_run) as ManifestPickupCard
	t.ok(recovery_card != null and (recovery_card.get_node("CardPanel/PickAndPlaceButton") as Button).text == tr("CARD_ACTION_RECOVER_MANIFEST"), "dispatch exposes recovery action only in recovery run")
	if recovery_card == null:
		return true
	recovery_card.close()
	await t.tree.process_frame
	t.ok(recovery_run.flow.can_recover_manifest() and RunSession.ground_manifest != null, "closing recovery card leaves Manifest at dispatch and E0")
	recovery_hud.dispatch_requested.emit()
	await _wait_seconds(t, 0.35)
	recovery_card = _overlay(recovery_run) as ManifestPickupCard
	if recovery_card == null:
		return true
	recovery_card.pickup_requested.emit()
	await t.tree.process_frame
	var recovery_pickup := _overlay(recovery_run) as ManifestPickupPanel
	await _wait_seconds(t, 0.35)
	recovery_pickup.tap_cell(RetrieverInventory.SLING_POUCH, Vector2i.ZERO)
	t.ok(recovery_run.flow.can_recover_manifest() and RunSession.ground_manifest != null, "invalid recovery placement leaves UNRECOVERED source and E0 intact")
	recovery_pickup.close()
	await t.tree.process_frame
	recovery_hud.dispatch_requested.emit()
	await _wait_seconds(t, 0.35)
	recovery_card = _overlay(recovery_run) as ManifestPickupCard
	if recovery_card == null:
		return true
	recovery_card.pickup_requested.emit()
	await t.tree.process_frame
	recovery_pickup = _overlay(recovery_run) as ManifestPickupPanel
	await _wait_seconds(t, 0.35)
	recovery_pickup.tap_cell(RetrieverInventory.BACKPACK, Vector2i.ZERO)
	t.eq(recovery_run.flow.extract_state, ExtractPierAFlow.ExtractState.E1_CALLABLE, "recovery placement enables E1 but not success")
	t.eq(recovery_run.flow.contract_state, ExtractPierAFlow.ContractState.CARRYING, "recovery placement transitions once to carrying")
	var beacon_zone := recovery_run.get_node_or_null("ZoneAOuterPier/BeaconZoneA") as ProximityZone3D
	var board_zone := recovery_run.get_node_or_null("ZoneAOuterPier/BoardZoneA") as ProximityZone3D
	beacon_zone.retriever_entered.emit()
	recovery_hud.call_requested.emit()
	await t.tree.process_frame
	var confirm := _overlay(recovery_run) as ConfirmDialog
	t.ok(confirm != null, "E1 opens call confirmation")
	if confirm == null:
		return true
	await _wait_seconds(t, 0.35)
	confirm.accepted.emit()
	for _step in 6:
		recovery_run.flow.tick(0.25)
	for _step in 80:
		recovery_run.flow.tick(0.25)
	t.eq(recovery_run.flow.extract_state, ExtractPierAFlow.ExtractState.S9_BOAT_READY, "recovery still requires call then hold before board")
	board_zone.retriever_entered.emit()
	recovery_hud.board_requested.emit()
	await t.tree.process_frame
	t.eq(recovery_run.flow.extract_state, ExtractPierAFlow.ExtractState.S10_SUCCESS, "only board reaches recovery S10")
	t.ok(not RunSession.recovery_active and RunSession.recovery_retained.is_empty(), "recovery-only session context clears when S10 summary opens, before hub navigation")
	t.eq(RunSession.recovery_source, &"", "S10 clears the recovery source after capturing its summary")
	t.eq(RunSession.extract_flow, null, "S10 clears the recovery flow from RunSession while the summary keeps its captured data")
	t.eq(RunSession.ground_manifest, null, "S10 clears the recovery dispatch source after pickup and extraction")
	if is_instance_valid(run):
		run.queue_free()
	if is_instance_valid(recovery_run):
		recovery_run.queue_free()
	await t.tree.process_frame
	RunSession.clear()
	t.eq(_save_files(), files_before, "end-to-end recovery path writes no user save file")
	return true


func _new_normal_run(t) -> OuterPierRun:
	RunSession.clear()
	t.tree.change_scene_to_packed(BOOT_SCENE)
	await t.tree.process_frame
	await t.tree.process_frame
	var boot := t.tree.current_scene as Control
	var enter_button := boot.get_node_or_null("EnterOuterPierButton") as Button if boot != null else null
	if not t.ok(enter_button != null, "Boot exposes the normal entry action for recovery coverage"):
		return null
	enter_button.pressed.emit()
	await t.tree.process_frame
	await t.tree.process_frame
	return await _enter_run_through_cancelled_loadout(t, false)


func _enter_run_through_cancelled_loadout(t, recovery_mode: bool) -> OuterPierRun:
	var briefing_flow := t.tree.current_scene as BriefingFlow
	if not t.ok(briefing_flow != null, "briefing flow opens through the public scene route"):
		return null
	var briefing := briefing_flow.get_node_or_null("Briefing") as BriefingScreen
	if not t.ok(briefing != null and briefing.recovery_mode == recovery_mode, "briefing shows the expected normal or recovery variant"):
		return null
	await _wait_seconds(t, 0.35)
	var edit_loadout := _button_for_key(briefing, &"BRIEFING_BUTTON_EDIT_LOADOUT")
	var enter_run := _button_for_key(briefing, &"BRIEFING_BUTTON_ENTER")
	if not t.ok(edit_loadout != null and enter_run != null, "briefing exposes loadout and enter actions"):
		return null
	briefing.loadout_requested.emit(briefing.inventory)
	await t.tree.process_frame
	await t.tree.process_frame
	var loadout := briefing_flow.get_node_or_null("Loadout") as LoadoutScreen
	if not t.ok(loadout != null, "briefing opens its loadout screen"):
		return null
	if not t.ok(loadout.recovery_mode == recovery_mode, "loadout preserves the matching normal or recovery variant"):
		return null
	await _wait_seconds(t, 0.35)
	var cancel_loadout := _button_for_key(loadout, &"LOADOUT_BUTTON_CANCEL")
	if not t.ok(cancel_loadout != null, "loadout exposes its public cancel action"):
		return null
	cancel_loadout.pressed.emit()
	await t.tree.process_frame
	t.ok(briefing_flow.get_node_or_null("Loadout") == null, "cancelling loadout returns to briefing before entering the run")
	enter_run.pressed.emit()
	await t.tree.process_frame
	await t.tree.process_frame
	var run := t.tree.current_scene as OuterPierRun
	if not t.ok(run != null, "briefing enters OuterPierRun through the public route"):
		return null
	return run


func _overlay(run: OuterPierRun) -> Control:
	var layer := run.get_node_or_null("OverlayLayer") as CanvasLayer
	return layer.get_child(0) as Control if layer != null and layer.get_child_count() > 0 else null


func _button_for_key(parent: Control, key: StringName) -> Button:
	if parent == null:
		return null
	for child: Node in parent.get_children():
		var button := child as Button
		if button != null and button.text == tr(key):
			return button
	return null


func _wait_seconds(t, seconds: float) -> void:
	var timer: SceneTreeTimer = t.tree.create_timer(seconds)
	await timer.timeout


func _after_manifest_summary(kept: Array[Dictionary] = []) -> DeathSummary:
	var summary := DeathSummary.new()
	summary.death_variant = &"after_manifest"
	summary.unrecovered_evidence = [&"manifest_r17"]
	summary.kept = kept
	return summary


func _full_notary_retained() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for index in 4:
		entries.append({"uid": 300 + index, "def_id": &"scraped_tax_coin", "quantity": 1, "anchor": Vector2i(index % 2, index / 2), "rotated": false})
	return entries


func _fill_backpack(inventory: RetrieverInventory) -> void:
	var uid := 400
	for y in inventory.backpack.size.y:
		for x in inventory.backpack.size.x:
			var coin := ItemInstance.new(uid, inventory.registry.get_def(&"scraped_tax_coin"))
			inventory.commit_pickup(coin, RetrieverInventory.BACKPACK, Vector2i(x, y), false)
			uid += 1


func _new_recovery_flow(t, kept: Array[Dictionary] = []) -> ExtractPierAFlow:
	RunSession.clear()
	if not t.ok(RunSession.prepare_recovery_briefing(_after_manifest_summary(kept)), "recovery death fixture enters S12 context"):
		return null
	return RunSession.begin_recovery_run(RunSession.inventory, RunSession.recovery_retained)


func _starter_remedy_retained() -> Array[Dictionary]:
	return [{"uid": 1, "def_id": &"starter_remedy", "quantity": 1, "anchor": Vector2i.ZERO, "rotated": false}]


func _assert_recovery_death(t, flow: ExtractPierAFlow, state_name: StringName) -> void:
	flow.notify_death()
	var summary := flow.resolve_death_summary()
	t.ok(summary != null and summary.death_variant == &"after_manifest", "%s death returns the recovery S11 variant" % state_name)
	if summary != null:
		t.eq(summary.unrecovered_evidence, [&"manifest_r17"], "%s death reports exactly one unrecovered Manifest" % state_name)
	t.eq(flow.contract_state, ExtractPierAFlow.ContractState.UNRECOVERED, "%s death resets contract to unrecovered" % state_name)
	t.ok(flow.extract_state != ExtractPierAFlow.ExtractState.S10_SUCCESS, "%s death never completes extraction" % state_name)
	t.ok(RunSession.prepare_recovery_briefing(summary), "%s death can start the next recovery briefing" % state_name)


func _assert_s12_controls(t, recovery: RecoveryContractScreen) -> void:
	var body_count := 0
	var action_count := 0
	for child in recovery.get_children():
		if child is Label and String(child.name).begins_with("Body"):
			body_count += 1
		if child is Button:
			action_count += 1
	t.eq(body_count, 3, "S12 contains exactly three recovery body lines")
	t.eq(action_count, 1, "S12 exposes exactly one action")
	var action := recovery.get_node_or_null("BriefingButton") as Button
	t.ok(action != null and action.text == tr("RECOVERY_BUTTON_BRIEFING"), "S12 exposes only the briefing action, without Back or Cancel")


func _assert_recovery_kit(t, inventory: RetrieverInventory) -> void:
	var retained := inventory.notary_box.item_at(Vector2i.ZERO)
	var sling := inventory.sling_pouch.item_at(Vector2i.ZERO)
	t.ok(retained != null and retained.def_id == &"starter_remedy" and not retained.rotated, "recovery preserves sealed starter remedy at Notary Box (0,0)")
	t.ok(sling != null and sling.def_id == &"sling_remedy", "recovery applies exactly the basic sling remedy")
	t.eq(inventory.backpack.all_items().size(), 0, "recovery inventory has no restored unsealed cargo")
	t.ok(not _inventory_has(inventory, &"manifest_r17"), "recovery inventory never restores Manifest before dispatch pickup")


func _inventory_has(inventory: RetrieverInventory, def_id: StringName) -> bool:
	for grid: InventoryGrid in [inventory.backpack, inventory.notary_box, inventory.sling_pouch]:
		for item: ItemInstance in grid.all_items():
			if item.def_id == def_id:
				return true
	return false


func _summary_has(entries: Array[Dictionary], def_id: StringName) -> bool:
	for entry in entries:
		if StringName(entry.get("def_id", &"")) == def_id:
			return true
	return false


func _save_files() -> PackedStringArray:
	var directory := DirAccess.open(AppEnv.save_dir())
	if directory == null:
		return PackedStringArray()
	var files := directory.get_files()
	files.sort()
	return files
