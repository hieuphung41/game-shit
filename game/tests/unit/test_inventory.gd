extends RefCounted

const BACKPACK: StringName = &"backpack"
const NOTARY_BOX: StringName = &"notary_box"
const SLING_POUCH: StringName = &"sling_pouch"


func _definition(id: StringName, size: Vector2i, category: ItemDef.Category, sealable: bool, rotatable: bool = false, stackable: bool = false, stack_max: int = 1, claim_id: StringName = &"") -> ItemDef:
	var definition := ItemDef.new()
	definition.id = id
	definition.display_name_vi = str(id)
	definition.size = size
	definition.item_category = category
	definition.sealable = sealable
	definition.rotatable = rotatable
	definition.stackable = stackable
	definition.stack_max = stack_max
	definition.claim_id = claim_id
	return definition


func _inventory() -> RetrieverInventory:
	var registry := ItemRegistry.new()
	registry.add(_definition(&"manifest_r17", Vector2i(1, 1), ItemDef.Category.EVIDENCE, true, false, false, 1, &"house_hac_thue"))
	registry.add(_definition(&"starter_remedy", Vector2i(1, 2), ItemDef.Category.CONSUMABLE, true, true))
	registry.add(_definition(&"fixture_b_small_1x1", Vector2i(1, 1), ItemDef.Category.VALUABLE, true, false, true, 3, &"house_hac_thue"))
	registry.add(_definition(&"fixture_b_small_1x2", Vector2i(1, 2), ItemDef.Category.VALUABLE, true, true, false, 1, &"house_hac_thue"))
	registry.add(_definition(&"tax_stamp_d", Vector2i(1, 2), ItemDef.Category.VALUABLE, true, true))
	registry.add(_definition(&"cargo_d_2x2", Vector2i(2, 2), ItemDef.Category.CARGO, false))
	registry.add(_definition(&"test_spare_weapon_1x2", Vector2i(1, 2), ItemDef.Category.WEAPON, false, true))
	registry.add(_definition(&"test_fixed_1x2", Vector2i(1, 2), ItemDef.Category.TOOL, true))
	registry.add(_definition(&"test_fixed_2x1", Vector2i(2, 1), ItemDef.Category.TOOL, true))
	registry.add(_definition(&"test_stack_other_claim_1x1", Vector2i(1, 1), ItemDef.Category.VALUABLE, true, false, true, 3, &"other_claim"))
	return RetrieverInventory.new(registry)


func _ground(inventory: RetrieverInventory, id: StringName, uid: int, quantity: int = 1) -> ItemInstance:
	return ItemInstance.new(uid, inventory.registry.get_def(id), quantity)


func _entry(uid: int, def_id: StringName, anchor: Vector2i, quantity: int = 1, rotated: bool = false) -> Dictionary:
	return {"uid": uid, "def_id": def_id, "quantity": quantity, "anchor": anchor, "rotated": rotated}


func _load(inventory: RetrieverInventory, backpack_entries: Array = [], box_entries: Array = [], pouch_entries: Array = []) -> void:
	inventory.load_snapshot({"backpack": backpack_entries, "notary_box": box_entries, "sling_pouch": pouch_entries})


func _filled_backpack_entries(first_uid: int = 1) -> Array:
	var entries: Array = []
	var uid := first_uid
	for y in 4:
		for x in 3:
			entries.append(_entry(uid, &"fixture_b_small_1x1", Vector2i(x, y)))
			uid += 1
	return entries


func test_inv_01_pickup_places_item_and_emits_signal(t) -> bool:
	var inventory := _inventory()
	var placed: Array = []
	inventory.item_placed.connect(func(_uid: int, _location: StringName) -> void: placed.append(true))
	var item := _ground(inventory, &"fixture_b_small_1x1", 1)
	var result := inventory.commit_pickup(item, BACKPACK, Vector2i.ZERO, false)
	t.ok(result.ok, "pickup succeeds")
	t.eq(item.item_location, BACKPACK, "item enters backpack")
	t.eq(item.anchor, Vector2i.ZERO, "anchor retained")
	t.eq(placed.size(), 1, "placed signal")
	return true


func test_zone_b_item_registry_definitions_are_complete(t) -> bool:
	var registry := ItemRegistry.new()
	var coin := registry.get_def(&"scraped_tax_coin")
	var ledger := registry.get_def(&"waterlogged_stock_ledger")
	t.ok(registry.validate_defs().is_empty(), "default registry definitions validate")
	t.eq(coin.size, Vector2i.ONE, "coin footprint")
	t.ok(coin.stackable and coin.stack_max == 3 and coin.sealable, "coin stack and seal fields")
	t.eq(coin.claim_id, &"house_hac_thue", "coin claim")
	t.eq(coin.appraisal_class, 2, "coin appraisal class")
	t.eq(coin.item_category, ItemDef.Category.VALUABLE, "coin category")
	t.eq(ledger.size, Vector2i(1, 2), "ledger footprint")
	t.ok(ledger.rotatable and ledger.sealable and not ledger.stackable, "ledger placement fields")
	t.eq(ledger.appraisal_class, 3, "ledger appraisal class")
	t.ok(not ledger.lore_key.is_empty(), "ledger has a localization lore key")
	return true


func test_inv_02_pickup_out_of_bounds_keeps_ground_item(t) -> bool:
	var inventory := _inventory()
	var item := _ground(inventory, &"fixture_b_small_1x2", 1)
	var before := inventory.snapshot()
	var result := inventory.commit_pickup(item, BACKPACK, Vector2i(0, 3), false)
	t.eq(result.reason, InventoryReason.Value.OUT_OF_BOUNDS, "out of bounds")
	t.eq(result.reason_label_vi, "không vừa", "Vietnamese reason")
	t.eq(item.item_location, &"ground", "ground unchanged")
	t.eq(inventory.snapshot(), before, "inventory unchanged")
	return true


func test_inv_03_pickup_blocked_cell_keeps_state(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"cargo_d_2x2", Vector2i.ZERO)])
	var item := _ground(inventory, &"fixture_b_small_1x1", 2)
	var before := inventory.snapshot()
	var result := inventory.commit_pickup(item, BACKPACK, Vector2i(1, 1), false)
	t.eq(result.reason, InventoryReason.Value.CELLS_OCCUPIED, "occupied")
	t.ok(Vector2i(1, 1) in result.blocking_cells, "blocking cell reported")
	t.eq(inventory.snapshot(), before, "state unchanged")
	t.eq(item.item_location, &"ground", "item remains ground")
	return true


func test_inv_04_rotate_rotatable_item_in_place(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x2", Vector2i.ZERO)])
	var result := inventory.commit_rotate(1)
	t.ok(result.ok, "rotate succeeds")
	var item: ItemInstance = inventory.backpack.items[1]
	t.ok(item.rotated, "rotated")
	t.eq(item.cells(), [Vector2i(0, 0), Vector2i(1, 0)], "horizontal footprint")
	return true


func test_inv_05_rotate_out_of_bounds_is_atomic(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x2", Vector2i(2, 0))])
	var before := inventory.snapshot()
	var result := inventory.commit_rotate(1)
	t.eq(result.reason, InventoryReason.Value.OUT_OF_BOUNDS, "rotate does not fit")
	t.eq(inventory.snapshot(), before, "state unchanged")
	return true


func test_inv_06_fixed_item_cannot_rotate(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"test_fixed_1x2", Vector2i.ZERO)])
	var before := inventory.snapshot()
	var result := inventory.commit_rotate(1)
	t.eq(result.reason, InventoryReason.Value.NOT_ROTATABLE, "fixed footprint")
	t.eq(result.reason_label_vi, "không xoay", "Vietnamese reason")
	t.eq(inventory.snapshot(), before, "state unchanged")
	return true


func test_inv_07_square_rotate_is_silent_no_op(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"manifest_r17", Vector2i.ZERO)])
	var placed := 0
	inventory.item_placed.connect(func(_uid: int, _location: StringName) -> void: placed += 1)
	var before := inventory.snapshot()
	var result := inventory.commit_rotate(1)
	t.ok(result.ok, "square no-op is valid")
	t.ok(not inventory.backpack.items[1].rotated, "square stays unrotated")
	t.eq(inventory.snapshot(), before, "no state change")
	t.eq(placed, 0, "no signal")
	return true


func test_inv_08_move_can_overlap_its_own_old_cells(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x2", Vector2i.ZERO)])
	var result := inventory.commit_move(1, BACKPACK, Vector2i(0, 1), false)
	t.ok(result.ok, "move succeeds")
	t.eq(inventory.backpack.items[1].cells(), [Vector2i(0, 1), Vector2i(0, 2)], "new cells")
	return true


func test_inv_09_previews_never_mutate_or_emit(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x2", Vector2i.ZERO), _entry(2, &"fixture_b_small_1x1", Vector2i(2, 0))], [_entry(3, &"starter_remedy", Vector2i.ZERO)])
	var before := inventory.snapshot()
	var signals := 0
	inventory.item_placed.connect(func(_uid: int, _location: StringName) -> void: signals += 1)
	inventory.item_removed.connect(func(_uid: int, _location: StringName) -> void: signals += 1)
	inventory.evidence_carried_changed.connect(func(_id: StringName, _carried: bool) -> void: signals += 1)
	inventory.preview_move(1, BACKPACK, Vector2i(0, 1), false)
	inventory.preview_rotate(1)
	inventory.preview_seal(1, Vector2i.ZERO, false)
	inventory.preview_withdraw(3, Vector2i.ZERO, false)
	inventory.preview_drop(1)
	inventory.preview_sort()
	t.eq(inventory.snapshot(), before, "all previews pure")
	t.eq(signals, 0, "no preview signal")
	return true


func test_inv_10_swap_two_backpack_items(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x2", Vector2i(0, 0)), _entry(2, &"tax_stamp_d", Vector2i(1, 0))])
	var result := inventory.commit_swap(1, 2)
	t.ok(result.ok, "swap succeeds")
	t.eq(inventory.backpack.items[1].anchor, Vector2i(1, 0), "A gets B anchor")
	t.eq(inventory.backpack.items[2].anchor, Vector2i(0, 0), "B gets A anchor")
	return true


func test_inv_11_swap_across_grids_is_rejected(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x1", Vector2i.ZERO)], [_entry(2, &"starter_remedy", Vector2i.ZERO)])
	var before := inventory.snapshot()
	var result := inventory.commit_swap(1, 2)
	t.eq(result.reason, InventoryReason.Value.SWAP_NOT_ALLOWED, "cross-grid swap")
	t.eq(inventory.snapshot(), before, "state unchanged")
	return true


func test_inv_12_stack_compatible_backpack_items(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x1", Vector2i.ZERO, 2), _entry(2, &"fixture_b_small_1x1", Vector2i(1, 0), 1)])
	var result := inventory.commit_stack(1, 2)
	t.ok(result.ok, "stack succeeds")
	t.ok(not inventory.backpack.items.has(1), "source removed")
	t.eq(inventory.backpack.items[2].quantity, 3, "target total")
	return true


func test_inv_13_stack_full_is_atomic(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x1", Vector2i.ZERO, 2), _entry(2, &"fixture_b_small_1x1", Vector2i(1, 0), 2)])
	var before := inventory.snapshot()
	var result := inventory.commit_stack(1, 2)
	t.eq(result.reason, InventoryReason.Value.STACK_FULL, "full stack")
	t.eq(inventory.snapshot(), before, "state unchanged")
	return true


func test_inv_14_stack_incompatible_claim_is_atomic(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x1", Vector2i.ZERO), _entry(2, &"test_stack_other_claim_1x1", Vector2i(1, 0))])
	var before := inventory.snapshot()
	var result := inventory.commit_stack(1, 2)
	t.eq(result.reason, InventoryReason.Value.STACK_INCOMPATIBLE, "claim differs")
	t.eq(inventory.snapshot(), before, "state unchanged")
	return true


func test_inv_15_seal_manifest_only_marks_not_extracted(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"manifest_r17", Vector2i.ZERO)], [_entry(2, &"starter_remedy", Vector2i.ZERO)])
	var result := inventory.commit_seal(1, Vector2i(1, 0), false)
	t.ok(result.ok, "seal succeeds")
	t.eq(inventory.seal_label(1), &"sealed_not_extracted", "evidence seal label")
	t.ok(inventory.notary_box.items.has(1), "manifest in box")
	return true


func test_inv_16_full_box_never_displaces_existing_items(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(3, &"tax_stamp_d", Vector2i(2, 0))], [_entry(1, &"starter_remedy", Vector2i.ZERO), _entry(2, &"manifest_r17", Vector2i(1, 0))])
	var before := inventory.snapshot()
	for anchor in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
		for rotated in [false, true]:
			var result := inventory.commit_seal(3, anchor, rotated)
			t.ok(not result.ok, "every box placement fails")
			t.eq(inventory.snapshot(), before, "failure is atomic")
	return true


func test_inv_17_cargo_cannot_be_sealed(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"cargo_d_2x2", Vector2i.ZERO)])
	var before := inventory.snapshot()
	var result := inventory.commit_seal(1, Vector2i.ZERO, false)
	t.eq(result.reason, InventoryReason.Value.NOT_SEALABLE, "cargo excluded")
	t.eq(result.reason_label_vi, "không niêm phong được", "Vietnamese reason")
	t.eq(inventory.snapshot(), before, "state unchanged")
	return true


func test_inv_18_not_sealable_precedes_full_box(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"cargo_d_2x2", Vector2i.ZERO)], [_entry(2, &"starter_remedy", Vector2i.ZERO), _entry(3, &"fixture_b_small_1x2", Vector2i(1, 0))])
	var result := inventory.commit_seal(1, Vector2i.ZERO, false)
	t.eq(result.reason, InventoryReason.Value.NOT_SEALABLE, "type reason wins")
	return true


func test_inv_19_weapon_cannot_be_sealed(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"test_spare_weapon_1x2", Vector2i.ZERO)])
	var result := inventory.commit_seal(1, Vector2i.ZERO, false)
	t.eq(result.reason, InventoryReason.Value.NOT_SEALABLE, "weapon excluded")
	t.ok(inventory.backpack.items.has(1), "weapon remains")
	return true


func test_inv_20_withdraw_to_full_backpack_is_atomic(t) -> bool:
	var inventory := _inventory()
	_load(inventory, _filled_backpack_entries(), [_entry(20, &"starter_remedy", Vector2i.ZERO)])
	var before := inventory.snapshot()
	var result := inventory.commit_withdraw(20, Vector2i.ZERO, false)
	t.eq(result.reason, InventoryReason.Value.CELLS_OCCUPIED, "backpack full")
	t.eq(inventory.seal_label(20), &"sealed", "remedy stays sealed")
	t.eq(inventory.snapshot(), before, "state unchanged")
	return true


func test_inv_21_withdraw_then_seal_requires_two_explicit_steps(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(2, &"tax_stamp_d", Vector2i(2, 0))], [_entry(1, &"starter_remedy", Vector2i.ZERO)])
	var withdraw := inventory.commit_withdraw(1, Vector2i.ZERO, false)
	t.ok(withdraw.ok, "withdraw succeeds")
	t.eq(inventory.notary_box.free_cell_count(), 4, "box empty")
	var seal := inventory.commit_seal(2, Vector2i.ZERO, false)
	t.ok(seal.ok, "second explicit seal succeeds")
	return true


func test_inv_22_full_backpack_pickup_never_changes_other_grids(t) -> bool:
	var inventory := _inventory()
	_load(inventory, _filled_backpack_entries(), [_entry(20, &"starter_remedy", Vector2i.ZERO)], [_entry(21, &"fixture_b_small_1x1", Vector2i.ZERO)])
	var item := _ground(inventory, &"fixture_b_small_1x1", 30)
	var before := inventory.snapshot()
	for y in 4:
		for x in 3:
			var result := inventory.commit_pickup(item, BACKPACK, Vector2i(x, y), false)
			t.ok(not result.ok, "full backpack fails")
	t.eq(inventory.snapshot(), before, "no automatic transfer")
	t.eq(item.item_location, &"ground", "ground item retained")
	return true


func test_inv_23_sling_pouch_is_not_a_pickup_target(t) -> bool:
	var inventory := _inventory()
	var item := _ground(inventory, &"fixture_b_small_1x1", 1)
	var result := inventory.commit_pickup(item, SLING_POUCH, Vector2i.ZERO, false)
	t.eq(result.reason, InventoryReason.Value.WRONG_TARGET, "pouch rejected")
	t.eq(result.reason_label_vi, "sai loại", "Vietnamese reason")
	t.eq(item.item_location, &"ground", "item stays ground")
	return true


func test_sling_remedy_definition_is_a_sealable_1x1_consumable(t) -> bool:
	var definition := SlingRemedyDefinition.new()
	t.eq(definition.id, &"sling_remedy", "definition id")
	t.eq(definition.size, Vector2i.ONE, "sling remedy footprint")
	t.eq(definition.item_category, ItemDef.Category.CONSUMABLE, "sling remedy category")
	t.ok(definition.sealable, "sling remedy can be sealed")
	t.eq(definition.display_name_key, &"ITEM_SLING_REMEDY_NAME", "name remains localized")
	return true


func test_inv_24_drop_returns_item_to_ground_and_emits_removed(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x1", Vector2i.ZERO, 3)])
	var removed: Array = []
	inventory.item_removed.connect(func(_uid: int, _location: StringName) -> void: removed.append(true))
	var result := inventory.commit_drop(1)
	t.ok(result.ok, "drop succeeds")
	t.ok(not inventory.backpack.items.has(1), "backpack slot freed")
	t.eq(result.moved[0].to_location, &"ground", "ground movement returned")
	var dropped: ItemInstance = result.moved[0].item
	t.eq(dropped.def_id, &"fixture_b_small_1x1", "world receives original item definition")
	t.eq(dropped.quantity, 3, "world receives original quantity")
	t.eq(dropped.item_location, &"ground", "dropped item is ground loot")
	t.eq(removed.size(), 1, "removed signal")
	return true


func test_inv_25_drop_from_notary_box_is_rejected(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [], [_entry(1, &"starter_remedy", Vector2i.ZERO)])
	var before := inventory.snapshot()
	var result := inventory.commit_drop(1)
	t.eq(result.reason, InventoryReason.Value.WRONG_SOURCE, "withdraw first")
	t.eq(inventory.snapshot(), before, "state unchanged")
	return true


func test_inv_26_evidence_entry_signal_only_fires_from_ground(t) -> bool:
	var inventory := _inventory()
	var signals: Array = []
	inventory.evidence_carried_changed.connect(func(id: StringName, carried: bool) -> void: signals.append([id, carried]))
	var manifest := _ground(inventory, &"manifest_r17", 1)
	t.ok(inventory.commit_pickup(manifest, BACKPACK, Vector2i.ZERO, false).ok, "pickup")
	t.ok(inventory.commit_seal(1, Vector2i(1, 0), false).ok, "seal")
	t.eq(signals, [[&"manifest_r17", true]], "seal does not repeat carried signal")
	return true


func test_inv_27_death_separates_kept_lost_and_evidence(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(3, &"cargo_d_2x2", Vector2i.ZERO)], [_entry(1, &"starter_remedy", Vector2i.ZERO), _entry(2, &"manifest_r17", Vector2i(1, 0))], [_entry(4, &"fixture_b_small_1x1", Vector2i.ZERO)])
	var outcome := inventory.resolve_death()
	t.eq(outcome.kept.map(func(item: ItemInstance) -> StringName: return item.def_id), [&"starter_remedy"], "box non-evidence kept")
	t.ok(&"cargo_d_2x2" in outcome.lost.map(func(item: ItemInstance) -> StringName: return item.def_id), "cargo lost")
	t.ok(&"fixture_b_small_1x1" in outcome.lost.map(func(item: ItemInstance) -> StringName: return item.def_id), "pouch item lost")
	t.eq(outcome.unrecovered_evidence, [&"manifest_r17"], "evidence unrecovered")
	t.eq(inventory.snapshot(), {"backpack": [], "notary_box": [], "sling_pouch": []}, "run grids cleared")
	return true


func test_inv_28_extract_routes_evidence_to_archive(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(3, &"cargo_d_2x2", Vector2i.ZERO)], [_entry(1, &"starter_remedy", Vector2i.ZERO), _entry(2, &"manifest_r17", Vector2i(1, 0))], [_entry(4, &"fixture_b_small_1x1", Vector2i.ZERO)])
	var outcome := inventory.resolve_extract()
	t.ok(&"starter_remedy" in outcome.to_hub.map(func(item: ItemInstance) -> StringName: return item.def_id), "remedy to hub")
	t.ok(&"cargo_d_2x2" in outcome.to_hub.map(func(item: ItemInstance) -> StringName: return item.def_id), "cargo to hub")
	t.ok(&"fixture_b_small_1x1" in outcome.to_hub.map(func(item: ItemInstance) -> StringName: return item.def_id), "pouch item to hub")
	t.eq(outcome.to_archive, [&"manifest_r17"], "manifest archived")
	return true


func test_inv_29_sort_matches_preview_without_touching_other_grids(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x1", Vector2i.ZERO), _entry(2, &"fixture_b_small_1x2", Vector2i(2, 0)), _entry(3, &"cargo_d_2x2", Vector2i(1, 2))], [_entry(4, &"starter_remedy", Vector2i.ZERO)], [_entry(5, &"fixture_b_small_1x1", Vector2i.ZERO)])
	var preview := inventory.preview_sort()
	var other_before := {"notary_box": inventory.snapshot().notary_box, "sling_pouch": inventory.snapshot().sling_pouch}
	var commit := inventory.commit_sort()
	t.ok(preview.ok and commit.ok, "sort succeeds")
	t.eq(inventory.backpack.items[3].anchor, Vector2i.ZERO, "cargo first")
	t.eq(inventory.backpack.items[2].anchor, Vector2i(2, 0), "1x2 next")
	t.eq(inventory.backpack.items[1].anchor, Vector2i(0, 2), "1x1 last")
	t.eq({"notary_box": inventory.snapshot().notary_box, "sling_pouch": inventory.snapshot().sling_pouch}, other_before, "other grids unchanged")
	return true


func test_inv_30_sort_no_fit_keeps_original_layout(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [
		_entry(1, &"test_fixed_2x1", Vector2i(0, 0)),
		_entry(2, &"tax_stamp_d", Vector2i(2, 0)),
		_entry(3, &"fixture_b_small_1x2", Vector2i(0, 1), 1, true),
		_entry(4, &"fixture_b_small_1x2", Vector2i(0, 2)),
		_entry(5, &"fixture_b_small_1x2", Vector2i(1, 2)),
		_entry(6, &"fixture_b_small_1x2", Vector2i(2, 2)),
	])
	var before := inventory.snapshot()
	var result := inventory.commit_sort()
	t.eq(result.reason, InventoryReason.Value.SORT_NO_FIT, "fixed item cannot fit after order")
	t.eq(inventory.snapshot(), before, "atomic sort failure")
	return true


func test_inv_31_every_failed_command_is_silent_and_atomic(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"test_fixed_1x2", Vector2i.ZERO)], [_entry(2, &"starter_remedy", Vector2i.ZERO)])
	var events := 0
	inventory.item_placed.connect(func(_uid: int, _location: StringName) -> void: events += 1)
	inventory.item_removed.connect(func(_uid: int, _location: StringName) -> void: events += 1)
	inventory.evidence_carried_changed.connect(func(_id: StringName, _carried: bool) -> void: events += 1)
	var before := inventory.snapshot()
	var ground := _ground(inventory, &"cargo_d_2x2", 3)
	for result in [inventory.commit_rotate(1), inventory.commit_swap(1, 2), inventory.commit_pickup(ground, SLING_POUCH, Vector2i.ZERO, false), inventory.commit_drop(2)]:
		t.ok(not result.ok, "failure expected")
	t.eq(inventory.snapshot(), before, "each failure leaves all grids unchanged")
	t.eq(events, 0, "failed operations emit nothing")
	return true


func test_inv_32_validate_reports_corrupt_save_without_repair(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x1", Vector2i.ZERO), _entry(2, &"fixture_b_small_1x1", Vector2i.ZERO)], [_entry(3, &"cargo_d_2x2", Vector2i.ZERO)])
	var before := inventory.snapshot()
	var errors := inventory.validate()
	t.ok(errors.any(func(result: InventoryResult) -> bool: return result.uid == 2 and result.reason == InventoryReason.Value.CELLS_OCCUPIED), "overlap identifies uid")
	t.ok(errors.any(func(result: InventoryResult) -> bool: return result.uid == 3 and result.reason == InventoryReason.Value.NOT_SEALABLE), "cargo box violation")
	t.eq(inventory.snapshot(), before, "validate does not repair")
	return true


func test_inv_33_ground_cargo_cannot_enter_notary_box(t) -> bool:
	var inventory := _inventory()
	var cargo := _ground(inventory, &"cargo_d_2x2", 1)
	var before := inventory.snapshot()
	var result := inventory.commit_pickup(cargo, NOTARY_BOX, Vector2i.ZERO, false)
	t.eq(result.reason, InventoryReason.Value.NOT_SEALABLE, "cargo not sealable")
	t.eq(cargo.item_location, &"ground", "cargo stays ground")
	t.eq(inventory.snapshot(), before, "grids unchanged")
	return true


func test_inv_34_pickup_never_auto_stacks_but_stack_can_merge_ground(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x1", Vector2i.ZERO)])
	var item := _ground(inventory, &"fixture_b_small_1x1", 2)
	var failed := inventory.commit_pickup(item, BACKPACK, Vector2i.ZERO, false)
	t.eq(failed.reason, InventoryReason.Value.CELLS_OCCUPIED, "pickup does not merge")
	t.eq(inventory.backpack.items[1].quantity, 1, "stack unchanged")
	var stacked := inventory.commit_stack(item, 1)
	t.ok(stacked.ok, "explicit stack merges")
	t.eq(inventory.backpack.items[1].quantity, 2, "merged quantity")
	t.eq(stacked.moved.size(), 1, "world receives one consumed ground source")
	t.ok(stacked.moved[0].source_consumed, "world is told to remove ground source")
	t.eq(stacked.moved[0].item, item, "world receives original ground item")
	t.eq(item.quantity, 1, "model leaves ground quantity intact until world removes it")
	return true


func test_inv_35_evidence_drop_and_repickup_emit_false_then_true(t) -> bool:
	var inventory := _inventory()
	var signals: Array = []
	inventory.evidence_carried_changed.connect(func(id: StringName, carried: bool) -> void: signals.append([id, carried]))
	var manifest := _ground(inventory, &"manifest_r17", 1)
	inventory.commit_pickup(manifest, BACKPACK, Vector2i.ZERO, false)
	signals.clear()
	inventory.commit_drop(1)
	inventory.commit_pickup(manifest, BACKPACK, Vector2i.ZERO, false)
	t.eq(signals, [[&"manifest_r17", false], [&"manifest_r17", true]], "ground transitions only")
	return true


func test_death_reports_evidence_from_every_carried_grid_as_unrecovered(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [], [], [_entry(1, &"manifest_r17", Vector2i.ZERO)])
	var outcome := inventory.resolve_death()
	t.eq(outcome.unrecovered_evidence, [&"manifest_r17"], "carried evidence is unrecovered")
	t.eq(outcome.lost, [], "evidence is never treated as ordinary lost loot")
	return true


func test_sort_merges_only_fully_compatible_stacks(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x1", Vector2i.ZERO, 1), _entry(2, &"fixture_b_small_1x1", Vector2i(1, 0), 2)])
	var result := inventory.commit_sort()
	t.ok(result.ok, "sort succeeds")
	t.ok(inventory.backpack.items.has(1), "first stack survives")
	t.ok(not inventory.backpack.items.has(2), "merged stack removed")
	t.eq(inventory.backpack.items[1].quantity, 3, "total quantity retained")
	return true


func test_sort_partially_merges_compatible_stacks(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x1", Vector2i.ZERO, 2), _entry(2, &"fixture_b_small_1x1", Vector2i(1, 0), 2)])
	var result := inventory.commit_sort()
	t.ok(result.ok, "sort succeeds")
	t.eq(inventory.backpack.items[1].quantity, 3, "first stack is filled to its cap")
	t.ok(inventory.backpack.items.has(2), "remainder stack survives")
	t.eq(inventory.backpack.items[2].quantity, 1, "remainder quantity is retained")
	t.eq(inventory.backpack.items[1].quantity + inventory.backpack.items[2].quantity, 4, "total quantity is retained")
	return true


func test_validate_preserves_duplicate_uid_in_loaded_grid(t) -> bool:
	var inventory := _inventory()
	_load(inventory, [_entry(1, &"fixture_b_small_1x1", Vector2i.ZERO), _entry(1, &"fixture_b_small_1x1", Vector2i(1, 0))])
	var before := inventory.snapshot()
	var errors := inventory.validate()
	t.eq(inventory.snapshot().backpack.size(), 2, "both duplicate entries remain loaded")
	t.ok(errors.any(func(result: InventoryResult) -> bool: return result.uid == 1 and result.reason == InventoryReason.Value.CELLS_OCCUPIED), "duplicate uid is reported")
	t.eq(inventory.snapshot(), before, "validate does not repair duplicate entries")
	return true


func test_consume_only_allows_sling_pouch_consumables_and_removes_final_item(t) -> bool:
	var inventory := _inventory()
	inventory.registry.add(SlingRemedyDefinition.new())
	_load(inventory, [], [_entry(1, &"starter_remedy", Vector2i.ZERO)], [_entry(2, &"sling_remedy", Vector2i.ZERO)])
	var removed: Array = []
	inventory.item_removed.connect(func(uid: int, location: StringName) -> void: removed.append([uid, location]))
	var wrong_source := inventory.commit_consume(1)
	t.eq(wrong_source.reason, InventoryReason.Value.WRONG_SOURCE, "sealed starter remedy cannot be consumed")
	var consumed := inventory.consume(2)
	t.ok(consumed.ok, "the public consume API consumes a sling pouch consumable")
	t.ok(not inventory.sling_pouch.items.has(2), "final quantity is removed")
	t.eq(removed, [[2, RetrieverInventory.SLING_POUCH]], "final consume emits item_removed once")
	return true
