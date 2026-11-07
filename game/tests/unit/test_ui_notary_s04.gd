extends RefCounted

const RUN_PANEL := preload("res://src/ui/notary/notary_run_panel.tscn")


func test_ui_notary_withdraw_confirms_before_commit_and_unblocks_tax_stamp_seal(t) -> bool:
	var inventory := _inventory_with_box_fixture()
	var source := LootCache.new()
	var tax_stamp := ItemInstance.new(30, inventory.registry.get_def(&"tax_stamp_d"))
	source.load_single_ground_item(tax_stamp)
	var panel := RUN_PANEL.instantiate() as NotaryRunPanel
	panel.configure(inventory, source)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel.open_view()
	var notary_status := panel.get_node("LootGridPanel/NotaryStatus") as Label
	t.ok(notary_status.text.contains(tr("INVENTORY_SEAL_LABEL_SEALED_NOT_EXTRACTED")), "Manifest seal label remains visible in the S04 dock")
	var withdraw_button := panel.get_node("LootGridPanel/DropOrWithdrawButton") as Button
	t.eq(withdraw_button.get_global_rect(), Rect2(1144, 568, 104, 96), "withdraw uses the specified right-side touch region")
	var remedy := inventory.notary_box.items[1] as ItemInstance
	panel._on_item_pressed(remedy.uid)
	panel.request_withdraw()
	var before := inventory.snapshot()
	var preview := panel.release_cell(RetrieverInventory.BACKPACK, Vector2i(0, 0))
	t.ok(preview.ok, "withdraw target previews through RetrieverInventory")
	t.ok(panel._confirmation != null, "release opens O5i instead of committing withdraw")
	t.eq(inventory.snapshot(), before, "opening O5i keeps the fixture snapshot")
	panel._confirmation._opened_at_msec = -1000
	(panel._confirmation.get_node("InventoryConfirmPanel/AcceptButton") as Button).pressed.emit()
	await t.tree.process_frame
	t.ok(inventory.backpack.items.has(remedy.uid), "confirmed O5i commits the remedy withdraw")
	t.ok(inventory.commit_pickup(tax_stamp, RetrieverInventory.BACKPACK, Vector2i(2, 0), false).ok, "Dấu Thuế first enters the backpack by its public pickup API")
	panel._on_item_pressed(tax_stamp.uid)
	var before_move := inventory.snapshot()
	t.ok(panel.release_cell(RetrieverInventory.BACKPACK, Vector2i(1, 2)).ok, "panel commits a same-grid Tax Stamp move")
	t.ok(panel._confirmation == null, "same-grid move never opens O5i")
	t.ok(inventory.snapshot() != before_move, "same-grid move changes only through RetrieverInventory")
	panel.toggle_rotate()
	t.ok(panel.release_cell(RetrieverInventory.BACKPACK, Vector2i(1, 2)).ok, "panel commits the rotated Tax Stamp placement")
	t.ok(inventory.backpack.items[tax_stamp.uid].rotated, "Tax Stamp rotates through the panel")
	t.ok(panel._confirmation == null, "rotation never opens O5i")
	t.ok(panel.release_cell(RetrieverInventory.BACKPACK, Vector2i(1, 2)).ok, "panel restores the upright Tax Stamp placement")
	t.ok(not inventory.backpack.items[tax_stamp.uid].rotated, "Tax Stamp can return upright through the panel")
	t.ok(panel.release_cell(RetrieverInventory.NOTARY_BOX, Vector2i(0, 0)).ok, "withdrawing remedy creates the explicit panel-driven seal path for Dấu Thuế")
	t.ok(panel._confirmation == null, "backpack-to-Hộp sealing never opens O5i")
	t.ok(inventory.notary_box.items.has(tax_stamp.uid), "panel committed the Tax Stamp seal")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_notary_rejection_cancel_and_close_keep_snapshot_without_auto_swap(t) -> bool:
	var inventory := _inventory_with_box_fixture()
	var source := LootCache.new()
	var tax_stamp := ItemInstance.new(30, inventory.registry.get_def(&"tax_stamp_d"))
	source.load_single_ground_item(tax_stamp)
	var panel := RUN_PANEL.instantiate() as NotaryRunPanel
	panel.configure(inventory, source)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel.open_view()
	t.ok(inventory.commit_pickup(tax_stamp, RetrieverInventory.BACKPACK, Vector2i(2, 0), false).ok, "given tax stamp is carried")
	panel._on_item_pressed(tax_stamp.uid)
	var before_seal := inventory.snapshot()
	var rejection := panel.release_cell(RetrieverInventory.NOTARY_BOX, Vector2i(0, 0))
	t.eq(rejection.reason, InventoryReason.Value.CELLS_OCCUPIED, "full fixture rejects the Dấu Thuế with the public reason")
	t.eq(inventory.snapshot(), before_seal, "rejected seal does not auto-swap or drop either box item")
	panel.request_drop()
	t.ok(panel._confirmation != null, "drop opens O5i")
	var before_cancel := inventory.snapshot()
	panel._confirmation._opened_at_msec = -1000
	(panel._confirmation.get_node("InventoryConfirmPanel/CancelButton") as Button).pressed.emit()
	await t.tree.process_frame
	t.eq(inventory.snapshot(), before_cancel, "cancel O5i never calls commit_drop")
	panel.close()
	t.eq(inventory.snapshot(), before_cancel, "closing the run panel keeps inventory unchanged")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_notary_cargo_cannot_seal_and_only_confirmed_drop_emits_world_intent(t) -> bool:
	var inventory := _inventory_with_box_fixture()
	var source := LootCache.new()
	var cargo := ItemInstance.new(40, inventory.registry.get_def(&"cargo_d_2x2"))
	source.load_single_ground_item(cargo)
	var panel := RUN_PANEL.instantiate() as NotaryRunPanel
	panel.configure(inventory, source)
	var drops: Array[int] = []
	panel.item_drop_confirmed.connect(func(uid: int) -> void: drops.append(uid))
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	var card_details := panel._card.get_node("CacheCardPanel/Rows/Details") as VBoxContainer
	t.ok((card_details.get_node("FootprintCue") as Label).text.contains("□□□□"), "cargo card exposes a 2x2 footprint shape outside colour")
	panel.open_pickup()
	var before := inventory.snapshot()
	var rejection := panel.release_cell(RetrieverInventory.NOTARY_BOX, Vector2i(0, 0))
	t.eq(rejection.reason, InventoryReason.Value.NOT_SEALABLE, "cargo targets report NOT_SEALABLE")
	t.eq(inventory.snapshot(), before, "cargo rejection leaves inventory untouched")
	t.ok(inventory.commit_pickup(cargo, RetrieverInventory.BACKPACK, Vector2i(0, 0), false).ok, "given cargo later enters backpack")
	panel.open_view()
	panel._on_item_pressed(cargo.uid)
	panel.request_drop()
	t.ok(panel._confirmation != null, "drop needs O5i")
	t.eq(drops.size(), 0, "world drop signal waits for confirmation")
	panel._confirmation._opened_at_msec = -1000
	(panel._confirmation.get_node("InventoryConfirmPanel/AcceptButton") as Button).pressed.emit()
	await t.tree.process_frame
	t.eq(drops, [cargo.uid], "only the confirmed drop emits a world intent")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_notary_zone_d_cards_render_relative_values_and_tax_stamp_rotation_cue(t) -> bool:
	var inventory := _inventory_with_box_fixture()
	var tax_source := LootCache.new()
	var tax_stamp := ItemInstance.new(30, inventory.registry.get_def(&"tax_stamp_d"))
	tax_source.load_single_ground_item(tax_stamp)
	var tax_panel := RUN_PANEL.instantiate() as NotaryRunPanel
	tax_panel.configure(inventory, tax_source)
	t.tree.root.add_child(tax_panel)
	await t.tree.process_frame
	var tax_details := tax_panel._card.get_node("CacheCardPanel/Rows/Details") as VBoxContainer
	t.eq((tax_details.get_node("RelativeValues/ValueTotal") as Label).text, tr("CARD_VALUE_TOTAL").format({"value_total": "6"}), "Tax Stamp card shows its inventory total")
	t.eq((tax_details.get_node("RelativeValues/ValuePerCell") as Label).text, tr("CARD_VALUE_PER_CELL").format({"value_per_cell": "3"}), "Tax Stamp card shows Vietnamese per-cell value")
	t.ok((tax_details.get_node("FootprintCue") as Label).text.contains(tr("CARD_TAG_ROTATABLE")), "Tax Stamp card exposes its rotation cue outside colour")
	tax_panel.queue_free()
	await t.tree.process_frame
	var cargo_source := LootCache.new()
	var cargo := ItemInstance.new(40, inventory.registry.get_def(&"cargo_d_2x2"))
	cargo_source.load_single_ground_item(cargo)
	var cargo_panel := RUN_PANEL.instantiate() as NotaryRunPanel
	cargo_panel.configure(inventory, cargo_source)
	t.tree.root.add_child(cargo_panel)
	await t.tree.process_frame
	var cargo_details := cargo_panel._card.get_node("CacheCardPanel/Rows/Details") as VBoxContainer
	t.eq((cargo_details.get_node("RelativeValues/ValueTotal") as Label).text, tr("CARD_VALUE_TOTAL").format({"value_total": "8"}), "cargo card shows its inventory total")
	t.eq((cargo_details.get_node("RelativeValues/ValuePerCell") as Label).text, tr("CARD_VALUE_PER_CELL").format({"value_per_cell": "2"}), "cargo card shows Vietnamese per-cell value")
	cargo_panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_notary_view_and_close_never_open_o5_or_mutate_inventory(t) -> bool:
	var inventory := _inventory_with_box_fixture()
	var source := LootCache.new()
	source.load_single_ground_item(ItemInstance.new(30, inventory.registry.get_def(&"tax_stamp_d")))
	var panel := RUN_PANEL.instantiate() as NotaryRunPanel
	panel.configure(inventory, source)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	var before := inventory.snapshot()
	panel.open_view()
	panel._on_item_pressed(1)
	t.ok(panel._confirmation == null, "view and selection never open O5i")
	panel.close()
	t.ok(panel._confirmation == null, "close never opens O5i")
	t.eq(inventory.snapshot(), before, "view and close leave the inventory unchanged")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_notary_o5_blocks_grid_and_close_behind_fullscreen_capture(t) -> bool:
	var inventory := _inventory_with_box_fixture()
	var source := LootCache.new()
	source.load_single_ground_item(ItemInstance.new(30, inventory.registry.get_def(&"tax_stamp_d")))
	var panel := RUN_PANEL.instantiate() as NotaryRunPanel
	var closed: Array[bool] = []
	panel.closed.connect(func() -> void: closed.append(true))
	panel.configure(inventory, source)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel.open_view()
	var remedy := inventory.notary_box.items[1] as ItemInstance
	var manifest := inventory.notary_box.items[2] as ItemInstance
	panel._on_item_pressed(remedy.uid)
	t.ok(panel.release_cell(RetrieverInventory.BACKPACK, Vector2i(0, 0)).ok, "withdraw opens from a valid preview")
	await t.tree.process_frame
	var confirmation := panel._confirmation
	t.ok(confirmation != null, "withdraw is pending in O5i")
	t.eq(confirmation.get_global_rect(), t.tree.root.get_viewport().get_visible_rect(), "packed O5i root captures the full viewport")
	t.eq(confirmation.mouse_filter, Control.MOUSE_FILTER_STOP, "O5i root stops pointer input outside its inner panel")
	_push_touch(t.tree.root.get_viewport(), (panel.get_node("LootGridPanel/NotaryBox/Item_%d" % manifest.uid) as Control).get_global_rect().get_center(), true)
	_push_touch(t.tree.root.get_viewport(), (panel.get_node("LootGridPanel/NotaryBox/Item_%d" % manifest.uid) as Control).get_global_rect().get_center(), false)
	_push_touch(t.tree.root.get_viewport(), (panel.get_node("CloseButton") as Control).get_global_rect().get_center(), true)
	_push_touch(t.tree.root.get_viewport(), (panel.get_node("CloseButton") as Control).get_global_rect().get_center(), false)
	await t.tree.process_frame
	t.eq(panel.selected_uid, remedy.uid, "O5i blocks item selection in the dock behind it")
	t.eq(closed.size(), 0, "O5i blocks the dock close action behind it")
	t.ok(panel._confirmation == confirmation, "O5i remains pending after dock actions behind it are tapped")
	t.eq(panel.session, LootCachePanel.Session.VIEW, "O5i keeps the dock open until its own action resolves")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_notary_full_backpack_withdraw_shows_lock_cue_and_feedback(t) -> bool:
	var inventory := _inventory_with_full_backpack()
	var source := LootCache.new()
	source.load_single_ground_item(ItemInstance.new(30, inventory.registry.get_def(&"tax_stamp_d")))
	var panel := RUN_PANEL.instantiate() as NotaryRunPanel
	panel.configure(inventory, source)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel.open_view()
	var remedy := inventory.notary_box.items[1] as ItemInstance
	panel._on_item_pressed(remedy.uid)
	var withdraw_button := panel.get_node("LootGridPanel/DropOrWithdrawButton") as Button
	t.ok(withdraw_button.text.contains("⊘") and withdraw_button.text.contains("🔒"), "full backpack renders the crossed lock cue on Withdraw")
	t.ok(not withdraw_button.disabled, "Withdraw remains tappable to provide the specified no-fit feedback")
	var before := inventory.snapshot()
	panel.request_withdraw()
	t.ok(panel._confirmation == null, "full backpack opens no O5i")
	t.ok(panel._status.text.contains(tr("INVENTORY_REASON_CELLS_OCCUPIED")), "full backpack names CELLS_OCCUPIED after Withdraw")
	t.eq(inventory.snapshot(), before, "failed withdraw keeps the inventory snapshot unchanged")
	panel.queue_free()
	await t.tree.process_frame
	return true


func _inventory_with_box_fixture() -> RetrieverInventory:
	var inventory := StarterInventoryFactory.create()
	var manifest := ItemDef.new()
	manifest.id = &"manifest_r17"
	manifest.display_name_key = &"CARD_MANIFEST_R17_NAME"
	manifest.size = Vector2i.ONE
	manifest.sealable = true
	manifest.item_category = ItemDef.Category.EVIDENCE
	inventory.registry.add(manifest)
	var tax_stamp := ItemDef.new()
	tax_stamp.id = &"tax_stamp_d"
	tax_stamp.display_name_key = &"ITEM_TAX_STAMP_D_NAME"
	tax_stamp.size = Vector2i(1, 2)
	tax_stamp.rotatable = true
	tax_stamp.sealable = true
	tax_stamp.item_category = ItemDef.Category.VALUABLE
	tax_stamp.set_meta(&"relative_value_total", 6)
	inventory.registry.add(tax_stamp)
	var cargo := ItemDef.new()
	cargo.id = &"cargo_d_2x2"
	cargo.display_name_key = &"ITEM_CARGO_D_2X2_NAME"
	cargo.size = Vector2i(2, 2)
	cargo.item_category = ItemDef.Category.CARGO
	cargo.set_meta(&"relative_value_total", 8)
	inventory.registry.add(cargo)
	inventory.load_snapshot({
		"backpack": [],
		"notary_box": [
			{"uid": 1, "def_id": &"starter_remedy", "quantity": 1, "anchor": Vector2i.ZERO, "rotated": false},
			{"uid": 2, "def_id": &"manifest_r17", "quantity": 1, "anchor": Vector2i(1, 0), "rotated": false},
		],
		"sling_pouch": [],
	})
	return inventory


func _inventory_with_full_backpack() -> RetrieverInventory:
	var inventory := _inventory_with_box_fixture()
	var filler := ItemDef.new()
	filler.id = &"full_backpack_filler"
	filler.display_name_key = &"ITEM_SCRAP_COIN_NAME"
	filler.size = Vector2i.ONE
	inventory.registry.add(filler)
	var backpack: Array[Dictionary] = []
	for y in 4:
		for x in 3:
			var uid := 100 + y * 3 + x
			backpack.append({"uid": uid, "def_id": &"full_backpack_filler", "quantity": 1, "anchor": Vector2i(x, y), "rotated": false})
	inventory.load_snapshot({
		"backpack": backpack,
		"notary_box": [
			{"uid": 1, "def_id": &"starter_remedy", "quantity": 1, "anchor": Vector2i.ZERO, "rotated": false},
			{"uid": 2, "def_id": &"manifest_r17", "quantity": 1, "anchor": Vector2i(1, 0), "rotated": false},
		],
		"sling_pouch": [],
	})
	return inventory


func _push_touch(viewport: Viewport, position: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = position
	event.pressed = pressed
	viewport.push_input(event, true)
