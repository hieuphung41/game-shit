extends RefCounted

const RUN_PANEL := preload("res://src/ui/notary/notary_run_panel.tscn")


func test_ui_notary_ground_drop_prefix_uses_ground_source_label(t) -> bool:
	var inventory := _inventory_with_box_fixture()
	var source := LootCache.new()
	source.load_single_ground_item(ItemInstance.new(301, inventory.registry.get_def(&"tax_stamp_d")), &"ground_drop_301")
	var panel := LootCachePanel.new()
	panel.configure_s04(inventory, source)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel.open_pickup()
	var source_label := panel.get_node_or_null("LootGridPanel/Source") as Label
	t.ok(source_label != null, "GroundDrop pickup dock exposes its source label")
	if source_label != null:
		t.eq(source_label.text, tr("INVENTORY_PICKUP_SOURCE_GROUND"), "unique GroundDrop IDs keep the ground-source label")
	panel.queue_free()
	await t.tree.process_frame
	return true


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
	var backpack_preview := panel.get_node("LootGridPanel/Backpack") as InventoryGridWidget
	t.eq(backpack_preview.touch_preview_cells, [Vector2i(0, 0), Vector2i(0, 1)], "withdraw O5i keeps the selected backpack footprint preview visible")
	t.ok(backpack_preview.touch_preview_ok, "withdraw O5i keeps its destination preview valid")
	t.ok((panel.get_node("LootGridPanel/NotaryBox/Item_%d" % remedy.uid) as Button).text.begins_with("┄🔓"), "withdraw O5i marks the sealed source as pending")
	var withdraw_target := panel._confirmation.get_node("InventoryConfirmPanel/TargetRow") as Label
	t.eq(withdraw_target.text, tr("INVENTORY_CONFIRM_TARGET_BACKPACK_ANCHOR").format({"column": 1, "row": 1}), "withdraw O5i names the selected backpack anchor")
	var confirm_panel := panel._confirmation.get_node("InventoryConfirmPanel") as Control
	var title := confirm_panel.get_node("Title") as Label
	var item_row := confirm_panel.get_node("ItemRow") as Label
	t.eq(title.get_global_rect(), Rect2(328, 196, 264, 64), "O5i title reserves two localized lines at the specified rect")
	t.eq(item_row.get_global_rect(), Rect2(328, 264, 264, 40), "O5i item row starts below the title at the specified rect")
	t.eq(withdraw_target.get_global_rect(), Rect2(328, 308, 264, 40), "O5i target row starts at the specified rect")
	var withdraw_body := panel._confirmation.get_node("InventoryConfirmPanel/Body") as Control
	t.eq(withdraw_body.get_global_rect(), Rect2(328, 352, 264, 112), "withdraw O5i reserves the required complete consequence-copy region")
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
	var drop_preview := panel.get_node("LootGridPanel/Backpack") as InventoryGridWidget
	t.eq(drop_preview.touch_preview_cells, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], "drop O5i keeps the source footprint preview visible")
	t.ok(drop_preview.touch_preview_ok, "drop O5i keeps its source preview valid")
	t.ok((panel.get_node("LootGridPanel/Backpack/Item_%d" % cargo.uid) as Button).text.begins_with("┄↓"), "drop O5i marks the source with the dotted ground cue")
	var drop_body := panel._confirmation.get_node("InventoryConfirmPanel/Body") as Control
	t.eq(drop_body.get_global_rect(), Rect2(328, 352, 264, 112), "drop O5i reserves the required complete consequence-copy region")
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
	var before_direct_target := inventory.snapshot()
	var backpack := panel.get_node("LootGridPanel/Backpack") as InventoryGridWidget
	var direct_anchor := Vector2i(0, 0)
	var direct_backpack_cell := backpack.get_node("Cell_0_0") as Control
	var press := InputEventScreenTouch.new()
	press.index = 0
	press.position = direct_backpack_cell.get_global_rect().get_center()
	press.pressed = true
	backpack._on_cell_gui_input(press, direct_anchor)
	var release := InputEventScreenTouch.new()
	release.index = 0
	release.position = press.position
	release.pressed = false
	backpack._on_cell_gui_input(release, direct_anchor)
	await t.tree.process_frame
	t.ok(backpack.touch_preview_ok, "a direct backpack touch previews the selected sealed item")
	t.eq(backpack.touch_preview_cells, [Vector2i(0, 0), Vector2i(0, 1)], "the direct touch preserves the pending withdraw footprint at its anchor")
	t.ok(panel._confirmation != null, "a direct valid backpack touch opens O5i without pressing Withdraw")
	t.eq(inventory.snapshot(), before_direct_target, "a direct target preview keeps the inventory snapshot unchanged")
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


func test_ui_notary_o5_uses_real_input_guard_cancel_and_single_confirm(t) -> bool:
	var inventory := _inventory_with_box_fixture()
	var source := LootCache.new()
	source.load_single_ground_item(ItemInstance.new(30, inventory.registry.get_def(&"tax_stamp_d")))
	var panel := RUN_PANEL.instantiate() as NotaryRunPanel
	var withdrawals: Array[int] = []
	panel.item_withdraw_confirmed.connect(func(uid: int, _anchor: Vector2i) -> void: withdrawals.append(uid))
	panel.configure(inventory, source)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel.open_view()
	var remedy := inventory.notary_box.items[1] as ItemInstance
	panel._on_item_pressed(remedy.uid)
	var before := inventory.snapshot()
	var backpack := panel.get_node("LootGridPanel/Backpack") as InventoryGridWidget
	_tap_grid_cell(backpack, Vector2i(0, 0))
	await t.tree.process_frame
	var confirmation := panel._confirmation
	t.ok(confirmation != null, "a grid touch opens O5i for input-guard coverage")
	if confirmation == null:
		panel.queue_free()
		await t.tree.process_frame
		return false
	var accept := confirmation.get_node("InventoryConfirmPanel/AcceptButton") as Button
	t.eq(t.tree.root.get_viewport().gui_get_focus_owner(), accept, "a grid-opened O5i gives initial focus to AcceptButton")
	_push_action(t.tree.root.get_viewport(), &"ui_accept")
	_push_cancel(t.tree.root.get_viewport())
	await t.tree.process_frame
	t.ok(panel._confirmation == confirmation, "real accept and cancel touches during the 0.3-second guard are ignored")
	t.eq(inventory.snapshot(), before, "guarded O5 touches never mutate inventory")
	# Headless frames run faster than wall-clock milliseconds. Move past the
	# measured guard only after the real ui_accept/ui_cancel guard path above.
	confirmation._opened_at_msec = Time.get_ticks_msec() - 301
	_push_cancel(t.tree.root.get_viewport())
	await t.tree.process_frame
	t.ok(panel._confirmation == null, "ui_cancel after the guard closes O5i")
	t.eq(panel.session, LootCachePanel.Session.VIEW, "ui_cancel returns to the inventory view instead of closing its dock")
	t.eq(inventory.snapshot(), before, "ui_cancel closes O5i without a withdraw mutation")
	t.eq(withdrawals.size(), 0, "ui_cancel emits no withdraw confirmation")
	panel.request_withdraw()
	_tap_grid_cell(backpack, Vector2i(0, 0))
	await t.tree.process_frame
	confirmation = panel._confirmation
	t.ok(confirmation != null, "a grid touch reopens Withdraw after input-driven cancellation")
	if confirmation == null:
		panel.queue_free()
		await t.tree.process_frame
		return false
	accept = confirmation.get_node("InventoryConfirmPanel/AcceptButton") as Button
	t.eq(t.tree.root.get_viewport().gui_get_focus_owner(), accept, "reopened O5i accepts input through its initial confirmation focus")
	confirmation._opened_at_msec = Time.get_ticks_msec() - 301
	t.ok(not confirmation._input_guard_active(), "the O5i 0.3-second input guard expires before confirmation input")
	_push_action(t.tree.root.get_viewport(), &"ui_accept")
	await t.tree.process_frame
	_push_action(t.tree.root.get_viewport(), &"ui_accept")
	await t.tree.process_frame
	t.eq(withdrawals, [remedy.uid], "two real accept touches commit and emit withdraw exactly once")
	t.ok(inventory.backpack.items.has(remedy.uid), "the one accepted O5 input commits the withdraw")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_notary_o5_refocus_restarts_accept_guard(t) -> bool:
	var inventory := _inventory_with_box_fixture()
	var source := LootCache.new()
	source.load_single_ground_item(ItemInstance.new(30, inventory.registry.get_def(&"tax_stamp_d")))
	var panel := RUN_PANEL.instantiate() as NotaryRunPanel
	var withdrawals: Array[int] = []
	panel.item_withdraw_confirmed.connect(func(uid: int, _anchor: Vector2i) -> void: withdrawals.append(uid))
	panel.configure(inventory, source)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel.open_view()
	var remedy := inventory.notary_box.items[1] as ItemInstance
	panel._on_item_pressed(remedy.uid)
	var before := inventory.snapshot()
	_tap_grid_cell(panel.get_node("LootGridPanel/Backpack") as InventoryGridWidget, Vector2i(0, 0))
	await t.tree.process_frame
	var confirmation := panel._confirmation
	t.ok(confirmation != null, "given a pending O5i before application refocus")
	if confirmation == null:
		panel.queue_free()
		await t.tree.process_frame
		return false
	confirmation._opened_at_msec = Time.get_ticks_msec() - 301
	t.ok(not confirmation._input_guard_active(), "the original O5i guard has expired before refocus")
	confirmation.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	confirmation.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	t.ok(confirmation._input_guard_active(), "application refocus restarts the O5i accept guard")
	_push_action(t.tree.root.get_viewport(), &"ui_accept")
	await t.tree.process_frame
	t.ok(panel._confirmation == confirmation, "the immediate refocus accept leaves O5i open")
	t.eq(inventory.snapshot(), before, "the immediate refocus accept does not mutate inventory")
	t.eq(withdrawals.size(), 0, "the immediate refocus accept emits no withdrawal")
	confirmation._opened_at_msec = Time.get_ticks_msec() - 301
	_push_action(t.tree.root.get_viewport(), &"ui_accept")
	await t.tree.process_frame
	t.ok(panel._confirmation == null, "accept succeeds after the restarted refocus guard")
	t.ok(inventory.backpack.items.has(remedy.uid), "the post-guard accept commits the pending withdraw")
	t.eq(withdrawals, [remedy.uid], "the post-guard accept emits one withdrawal")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_notary_d1_input_cancels_o5_and_closes_dock_without_mutation(t) -> bool:
	var inventory := _inventory_with_box_fixture()
	var source := LootCache.new()
	source.load_single_ground_item(ItemInstance.new(30, inventory.registry.get_def(&"tax_stamp_d")))
	var panel := RUN_PANEL.instantiate() as NotaryRunPanel
	var closed: Array[bool] = []
	var withdrawals: Array[int] = []
	panel.closed.connect(func() -> void: closed.append(true))
	panel.item_withdraw_confirmed.connect(func(uid: int, _anchor: Vector2i) -> void: withdrawals.append(uid))
	panel.configure(inventory, source)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel.open_view()
	var remedy := inventory.notary_box.items[1] as ItemInstance
	panel._on_item_pressed(remedy.uid)
	var before := inventory.snapshot()
	var backpack := panel.get_node("LootGridPanel/Backpack") as InventoryGridWidget
	_tap_grid_cell(backpack, Vector2i(0, 0))
	await t.tree.process_frame
	var confirmation := panel._confirmation
	t.ok(confirmation != null, "given a pending withdraw O5i")
	if confirmation == null:
		panel.queue_free()
		await t.tree.process_frame
		return false
	var d1_rect := confirmation.danger_close_rect()
	t.eq(d1_rect.size, HudLayout.DANGER_CLOSE_SIZE, "O5i forwards the entire visible 320x128 D1 rect")
	var right_edge := Vector2(d1_rect.end.x - 1.0, d1_rect.get_center().y)
	var bottom_edge := Vector2(d1_rect.get_center().x, d1_rect.end.y - 1.0)
	t.ok(confirmation._is_danger_close_press(_screen_touch(right_edge, true)), "a tap at D1's right visible edge is forwarded through O5i")
	t.ok(confirmation._is_danger_close_press(_screen_touch(bottom_edge, true)), "a tap at D1's bottom visible edge is forwarded through O5i")
	var d1_center := d1_rect.get_center()
	_push_touch(t.tree.root.get_viewport(), d1_center, true)
	_push_touch(t.tree.root.get_viewport(), d1_center, false)
	await t.tree.process_frame
	t.ok(panel._confirmation == null, "a real D1 tap removes O5i despite its fullscreen pointer capture")
	t.eq(panel.session, LootCachePanel.Session.CLOSED, "the same D1 tap closes the dock to HUD")
	t.eq(closed.size(), 1, "D1 emits the dock-close intent exactly once")
	t.eq(inventory.snapshot(), before, "D1 cancels pending withdraw without inventory mutation")
	t.eq(withdrawals.size(), 0, "D1 emits no withdraw confirmation")
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
	viewport.push_input(_screen_touch(position, pressed), true)


func _screen_touch(position: Vector2, pressed: bool) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = position
	event.pressed = pressed
	return event


func _tap_grid_cell(grid: InventoryGridWidget, anchor: Vector2i) -> void:
	var cell := grid.get_node("Cell_%d_%d" % [anchor.x, anchor.y]) as Control
	var press := InputEventScreenTouch.new()
	press.index = 0
	press.position = cell.get_global_rect().get_center()
	press.pressed = true
	grid._on_cell_gui_input(press, anchor)
	var release := InputEventScreenTouch.new()
	release.index = 0
	release.position = press.position
	release.pressed = false
	grid._on_cell_gui_input(release, anchor)


func _push_cancel(viewport: Viewport) -> void:
	_push_action(viewport, &"ui_cancel")


func _push_action(viewport: Viewport, action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	viewport.push_input(event, true)
