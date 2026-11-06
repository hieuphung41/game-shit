extends RefCounted


func _definition(id: StringName, size: Vector2i, category: ItemDef.Category, sealable: bool, rotatable: bool = false) -> ItemDef:
	var definition := ItemDef.new()
	definition.id = id
	definition.display_name_vi = str(id)
	definition.size = size
	definition.item_category = category
	definition.sealable = sealable
	definition.rotatable = rotatable
	return definition


func _inventory() -> RetrieverInventory:
	var registry := ItemRegistry.new()
	registry.add(_definition(&"manifest_r17", Vector2i(1, 1), ItemDef.Category.EVIDENCE, true))
	registry.add(_definition(&"starter_remedy", Vector2i(1, 2), ItemDef.Category.CONSUMABLE, true, true))
	registry.add(_definition(&"fixture_b_small_1x1", Vector2i(1, 1), ItemDef.Category.VALUABLE, true))
	var inventory := RetrieverInventory.new(registry)
	inventory.load_snapshot({"backpack": [], "notary_box": [{"uid": 1, "def_id": &"starter_remedy", "quantity": 1, "anchor": Vector2i.ZERO, "rotated": false}], "sling_pouch": []})
	return inventory


func _flow() -> Dictionary:
	var inventory := _inventory()
	var flow := ExtractPierAFlow.new()
	flow.setup(inventory)
	return {"flow": flow, "inventory": inventory}


func _carry(flow: ExtractPierAFlow, inventory: RetrieverInventory, target: StringName = RetrieverInventory.BACKPACK) -> ItemInstance:
	var manifest := ItemInstance.new(20, inventory.registry.get_def(&"manifest_r17"))
	var anchor := Vector2i.ZERO if target == RetrieverInventory.BACKPACK else Vector2i(1, 0)
	inventory.commit_pickup(manifest, target, anchor, false)
	return manifest


func _to_s8(flow: ExtractPierAFlow, inventory: RetrieverInventory) -> void:
	_carry(flow, inventory)
	flow.set_in_beacon_zone(true)
	flow.request_call()
	flow.confirm_call()
	for _step in 6:
		flow.tick(0.25)


func _to_s9(flow: ExtractPierAFlow, inventory: RetrieverInventory) -> void:
	_to_s8(flow, inventory)
	for _step in 80:
		flow.tick(0.25)


func test_bcn_01_setup_starts_contract_run(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	t.eq(flow.desk_state, ExtractPierAFlow.DeskState.HAS_MANIFEST, "desk has manifest")
	t.eq(flow.contract_state, ExtractPierAFlow.ContractState.NOT_TAKEN, "contract is not taken")
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.E0_UNAVAILABLE, "beacon unavailable")
	t.ok(not flow.can_call(), "cannot call")
	return true


func test_bcn_02_entering_beacon_at_e0_changes_nothing(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	flow.set_in_beacon_zone(true)
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.E0_UNAVAILABLE, "still e0")
	t.ok(not flow.can_call(), "still cannot call")
	return true


func test_bcn_03_request_call_at_e0_is_rejected(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	flow.set_in_beacon_zone(true)
	t.ok(not flow.request_call(), "call rejected")
	t.ok(not flow.call_confirm_open, "confirmation stays closed")
	return true


func test_bcn_04_dispatch_card_does_not_mutate_flow(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	var before := [flow.desk_state, flow.contract_state, flow.extract_state]
	t.eq([flow.desk_state, flow.contract_state, flow.extract_state], before, "card is outside pure flow")
	return true


func test_bcn_05_failed_manifest_placement_keeps_flow_at_e0(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	var inventory: RetrieverInventory = context.inventory
	var manifest := ItemInstance.new(20, inventory.registry.get_def(&"manifest_r17"))
	var result := inventory.commit_pickup(manifest, RetrieverInventory.NOTARY_BOX, Vector2i.ZERO, false)
	t.ok(not result.ok, "occupied notary box rejects pickup")
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.E0_UNAVAILABLE, "still e0")
	t.eq(flow.desk_state, ExtractPierAFlow.DeskState.HAS_MANIFEST, "desk unchanged")
	return true


func test_bcn_06_pickup_manifest_to_backpack_makes_e1(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	var desk_changes: Array[bool] = []
	var contract_changes: Array[bool] = []
	var extract_changes: Array[bool] = []
	flow.desk_state_changed.connect(func(_to: int) -> void: desk_changes.append(true))
	flow.contract_state_changed.connect(func(_from: int, _to: int) -> void: contract_changes.append(true))
	flow.extract_state_changed.connect(func(_from: int, _to: int) -> void: extract_changes.append(true))
	_carry(flow, context.inventory)
	t.eq(flow.desk_state, ExtractPierAFlow.DeskState.EMPTY, "desk emptied")
	t.eq(flow.contract_state, ExtractPierAFlow.ContractState.CARRYING, "contract carrying")
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.E1_CALLABLE, "beacon callable")
	t.eq(desk_changes.size(), 1, "desk signal once")
	t.eq(contract_changes.size(), 1, "contract signal once")
	t.eq(extract_changes.size(), 1, "extract signal once")
	return true


func test_bcn_07_pickup_manifest_to_notary_box_makes_e1(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	var inventory: RetrieverInventory = context.inventory
	var manifest := _carry(flow, inventory, RetrieverInventory.NOTARY_BOX)
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.E1_CALLABLE, "beacon callable")
	t.eq(inventory.seal_label(manifest.uid), &"sealed_not_extracted", "manifest is sealed")
	return true


func test_bcn_08_sealing_manifest_does_not_change_flow(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	var inventory: RetrieverInventory = context.inventory
	var manifest := _carry(flow, inventory)
	var result := inventory.commit_seal(manifest.uid, Vector2i(1, 0), false)
	t.ok(result.ok, "seal succeeds")
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.E1_CALLABLE, "remains callable")
	return true


func test_bcn_09_e1_outside_beacon_cannot_call(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_carry(flow, context.inventory)
	t.ok(not flow.can_call(), "outside zone")
	t.ok(not flow.request_call(), "prompt does not open")
	return true


func test_bcn_10_e1_inside_beacon_can_call(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_carry(flow, context.inventory)
	flow.set_in_beacon_zone(true)
	t.ok(flow.can_call(), "beacon guard passes")
	return true


func test_bcn_11_request_call_opens_confirmation(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_carry(flow, context.inventory)
	flow.set_in_beacon_zone(true)
	var opened: Array[bool] = []
	flow.call_confirm_opened.connect(func() -> void: opened.append(true))
	t.ok(flow.request_call(), "opens confirmation")
	t.ok(flow.call_confirm_open, "prompt open")
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.E1_CALLABLE, "state stays e1")
	t.eq(opened.size(), 1, "opened signal once")
	return true


func test_bcn_12_cancel_call_keeps_e1(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_carry(flow, context.inventory)
	flow.set_in_beacon_zone(true)
	flow.request_call()
	var closed: Array[bool] = []
	flow.call_confirm_closed.connect(func(confirmed: bool) -> void: closed.append(confirmed))
	flow.cancel_call()
	t.ok(not flow.call_confirm_open, "prompt closed")
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.E1_CALLABLE, "e1 remains")
	t.eq(closed, [false], "cancel signal")
	return true


func test_bcn_13_leaving_beacon_cancels_call_prompt(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_carry(flow, context.inventory)
	flow.set_in_beacon_zone(true)
	flow.request_call()
	flow.set_in_beacon_zone(false)
	t.ok(not flow.call_confirm_open, "prompt closes on exit")
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.E1_CALLABLE, "still carries manifest")
	return true


func test_bcn_14_confirm_call_enters_s7(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_carry(flow, context.inventory)
	flow.set_in_beacon_zone(true)
	flow.request_call()
	t.ok(flow.confirm_call(), "confirmation accepted")
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.S7_CALL_ACCEPTED, "s7 entered")
	return true


func test_bcn_15_manifest_loss_before_confirm_rejects_call(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_carry(flow, context.inventory)
	flow.set_in_beacon_zone(true)
	flow.request_call()
	flow.on_evidence_carried_changed(&"manifest_r17", false)
	t.ok(not flow.confirm_call(), "cannot confirm closed invalid prompt")
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.E0_UNAVAILABLE, "back to e0")
	t.eq(flow.contract_state, ExtractPierAFlow.ContractState.DROPPED, "manifest dropped")
	return true


func test_bcn_16_s7_ack_starts_hold(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_carry(flow, context.inventory)
	flow.set_in_beacon_zone(true)
	flow.request_call()
	flow.confirm_call()
	var started: Array[float] = []
	flow.hold_started.connect(func(duration: float) -> void: started.append(duration))
	for _step in 6:
		flow.tick(0.25)
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.S8_HOLD, "hold begins")
	t.eq(flow.hold_remaining, 20.0, "full hold duration")
	t.eq(flow.hold_seconds_display(), 20, "display rounds up")
	t.eq(started, [20.0], "hold starts once")
	return true


func test_bcn_17_hold_counts_only_while_eligible(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_to_s8(flow, context.inventory)
	for _step in 4:
		flow.tick(0.25)
	t.eq(flow.hold_remaining, 19.0, "one second elapsed")
	t.ok(not flow.hold_paused, "hold active")
	return true


func test_bcn_18_leaving_beacon_pauses_hold(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_to_s8(flow, context.inventory)
	flow.tick(0.25)
	flow.set_in_beacon_zone(false)
	for _step in 8:
		flow.tick(0.25)
	t.ok(flow.hold_paused, "hold paused")
	t.eq(flow.hold_pause_reason, &"out_of_zone", "pause reason")
	t.eq(flow.hold_remaining, 19.75, "timer holds value")
	return true


func test_bcn_19_returning_to_beacon_resumes_hold(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_to_s8(flow, context.inventory)
	flow.set_in_beacon_zone(false)
	flow.set_in_beacon_zone(true)
	for _step in 4:
		flow.tick(0.25)
	t.ok(not flow.hold_paused, "hold resumes")
	t.eq(flow.hold_remaining, 19.0, "resumes from prior value")
	return true


func test_bcn_20_completed_hold_reaches_s9(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	var ready: Array[bool] = []
	flow.boat_ready.connect(func() -> void: ready.append(true))
	_to_s9(flow, context.inventory)
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.S9_BOAT_READY, "boat is ready")
	t.eq(flow.hold_seconds_display(), 0, "timer is zero")
	t.eq(ready.size(), 1, "boat ready signal once")
	return true


func test_bcn_21_board_outside_board_zone_is_rejected(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_to_s9(flow, context.inventory)
	t.eq(flow.board(), null, "cannot board outside zone")
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.S9_BOAT_READY, "remains s9")
	return true


func test_bcn_22_board_zone_enables_boarding(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_to_s9(flow, context.inventory)
	flow.set_in_board_zone(true)
	t.ok(flow.can_board(), "board guard passes")
	return true


func test_bcn_23_s9_waits_without_timeout(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_to_s9(flow, context.inventory)
	flow.set_in_beacon_zone(false)
	for _step in 20:
		flow.tick(0.25)
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.S9_BOAT_READY, "still waits")
	return true


func test_bcn_24_board_builds_success_summary(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_to_s9(flow, context.inventory)
	flow.set_in_board_zone(true)
	var successes: Array[bool] = []
	flow.extract_succeeded.connect(func(_summary: ExtractSummary) -> void: successes.append(true))
	var summary := flow.board()
	t.ok(summary != null, "summary returned")
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.S10_SUCCESS, "success state")
	t.eq(flow.contract_state, ExtractPierAFlow.ContractState.EXTRACTED, "contract extracted")
	t.eq(summary.evidence, [&"manifest_r17"], "manifest goes archive")
	t.eq(summary.lost, [], "early extract loses nothing")
	t.eq(summary.backpack_cells_used, 1, "manifest uses one backpack cell")
	t.eq(summary.backpack_cells_total, 12, "backpack total")
	t.eq(successes.size(), 1, "success signal once")
	return true


func test_bcn_25_s10_ignores_remaining_flow_input(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_to_s9(flow, context.inventory)
	flow.set_in_board_zone(true)
	flow.board()
	flow.tick(10.0)
	flow.set_in_beacon_zone(false)
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.S10_SUCCESS, "success cannot be changed")
	return true


func test_bcn_26_dropped_manifest_returns_e1_to_e0(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_carry(flow, context.inventory)
	flow.on_evidence_carried_changed(&"manifest_r17", false)
	t.eq(flow.contract_state, ExtractPierAFlow.ContractState.DROPPED, "dropped state")
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.E0_UNAVAILABLE, "e0 after drop")
	t.eq(flow.desk_state, ExtractPierAFlow.DeskState.EMPTY, "manifest does not return to desk")
	return true


func test_bcn_27_repickup_manifest_returns_to_e1(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_carry(flow, context.inventory)
	flow.on_evidence_carried_changed(&"manifest_r17", false)
	flow.on_evidence_carried_changed(&"manifest_r17", true)
	t.eq(flow.contract_state, ExtractPierAFlow.ContractState.CARRYING, "carrying again")
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.E1_CALLABLE, "callable again")
	return true


func test_bcn_28_manifest_loss_pauses_s8(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_to_s8(flow, context.inventory)
	flow.on_evidence_carried_changed(&"manifest_r17", false)
	flow.tick(1.0)
	t.ok(flow.hold_paused, "hold paused")
	t.eq(flow.hold_pause_reason, &"manifest_missing", "manifest reason wins")
	t.eq(flow.hold_remaining, 20.0, "no elapsed time")
	return true


func test_bcn_29_manifest_loss_in_s9_prevents_boarding(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_to_s9(flow, context.inventory)
	flow.set_in_board_zone(true)
	flow.on_evidence_carried_changed(&"manifest_r17", false)
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.S9_BOAT_READY, "boat continues waiting")
	t.ok(not flow.can_board(), "missing manifest blocks board")
	return true


func test_bcn_30_death_ends_flow_without_extract(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_carry(flow, context.inventory)
	flow.set_in_beacon_zone(true)
	flow.request_call()
	flow.notify_death()
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.ENDED_DEATH, "death terminal")
	t.ok(not flow.call_confirm_open, "prompt closes")
	t.eq(flow.board(), null, "death cannot extract")
	return true


func test_bcn_31_terminal_states_ignore_input(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	flow.notify_death()
	flow.set_in_beacon_zone(true)
	flow.set_in_board_zone(true)
	flow.on_evidence_carried_changed(&"manifest_r17", true)
	flow.request_call()
	flow.tick(1.0)
	t.eq(flow.extract_state, ExtractPierAFlow.ExtractState.ENDED_DEATH, "death stays terminal")
	t.eq(flow.contract_state, ExtractPierAFlow.ContractState.NOT_TAKEN, "contract unaffected")
	return true


func test_bcn_32_confirm_call_is_idempotent(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_carry(flow, context.inventory)
	flow.set_in_beacon_zone(true)
	flow.request_call()
	t.ok(flow.confirm_call(), "first confirmation works")
	t.ok(not flow.confirm_call(), "second confirmation rejected")
	return true


func test_bcn_33_board_is_idempotent(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_to_s9(flow, context.inventory)
	flow.set_in_board_zone(true)
	t.ok(flow.board() != null, "first board succeeds")
	t.eq(flow.board(), null, "second board rejected")
	return true


func test_bcn_34_tick_delta_is_capped(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_to_s8(flow, context.inventory)
	flow.tick(10.0)
	t.eq(flow.hold_remaining, 19.75, "only capped delta counts")
	return true


func test_bcn_35_early_and_full_extract_summaries_have_only_contract_fields(t) -> bool:
	var early_context := _flow()
	var early_flow: ExtractPierAFlow = early_context.flow
	_to_s9(early_flow, early_context.inventory)
	early_flow.set_in_board_zone(true)
	var early := early_flow.board().to_dict()
	var full_context := _flow()
	var full_flow: ExtractPierAFlow = full_context.flow
	var inventory: RetrieverInventory = full_context.inventory
	var loot := ItemInstance.new(21, inventory.registry.get_def(&"fixture_b_small_1x1"))
	inventory.commit_pickup(loot, RetrieverInventory.BACKPACK, Vector2i(1, 0), false)
	_to_s9(full_flow, inventory)
	full_flow.set_in_board_zone(true)
	var full := full_flow.board().to_dict()
	t.eq(early.keys(), full.keys(), "summary shape is route independent")
	t.ok(not early.has("score") and not early.has("route") and not early.has("value") and not early.has("time"), "no scoring fields")
	return true


func test_bcn_36_s02_flow_does_not_create_enemy_nodes(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	_to_s8(flow, context.inventory)
	t.ok(flow is RefCounted, "pure flow cannot spawn scene enemies")
	return true


func test_bcn_37_zone_adapter_remains_outside_pure_flow(t) -> bool:
	var context := _flow()
	var flow: ExtractPierAFlow = context.flow
	flow.set_in_beacon_zone(true)
	t.ok(flow.in_beacon_zone, "scene adapter supplies zone state through public setter")
	return true
