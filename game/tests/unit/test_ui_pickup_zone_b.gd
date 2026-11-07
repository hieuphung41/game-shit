extends RefCounted

const CARD_SCENE := preload("res://src/ui/pickup/loot_cache_panel.tscn")


func test_ui_pickup_zone_b_card_has_non_colour_cues_and_skip_is_pure(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var cache := LootCache.new(inventory.registry)
	var panel := CARD_SCENE.instantiate() as LootCachePanel
	panel.configure(inventory, cache)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	var before := inventory.snapshot()
	var details := panel._card.get_node("CacheCardPanel/Rows/Details") as VBoxContainer
	t.ok(details.get_node_or_null("FootprintCue") != null, "footprint shape cue exists")
	t.ok(details.get_node_or_null("ClaimCue") != null, "claim flag cue exists")
	t.ok(details.get_node_or_null("RarityCue") != null, "rarity marks cue exists")
	(panel._card.get_node("CacheCardPanel/Rows/Actions/SkipButton") as Button).pressed.emit()
	await t.tree.process_frame
	t.eq(panel.selected_index, 1, "skip advances to the next ordered item")
	t.eq(inventory.snapshot(), before, "skip does not mutate inventory")
	t.eq(cache.cache_state(), &"full", "skip does not mutate cache")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_pickup_zone_b_grid_previews_rotates_and_commits_only_on_valid_release(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var cache := LootCache.new(inventory.registry)
	var panel := CARD_SCENE.instantiate() as LootCachePanel
	panel.configure(inventory, cache)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel.open_card(1)
	panel.open_pickup()
	var before := inventory.snapshot()
	var invalid := panel.preview_cell(RetrieverInventory.BACKPACK, Vector2i(0, 3))
	t.eq(invalid.reason, InventoryReason.Value.OUT_OF_BOUNDS, "vertical ledger preview reports bounds")
	t.eq((panel.get_node("LootGridPanel/Backpack/Cell_0_3") as Button).text, "╳", "invalid touch draws a crossed footprint ghost")
	var preview_grid := panel.get_node("LootGridPanel/Backpack") as InventoryGridWidget
	t.eq(preview_grid.touch_preview_edge_direction, Vector2i(0, 1), "vertical ledger records its bottom-edge overflow")
	var edge_indicator := preview_grid.get_node_or_null("TouchPreviewEdgeIndicator") as Label
	t.ok(edge_indicator != null, "out-of-bounds preview draws an edge indicator")
	t.eq(edge_indicator.text, "↓", "vertical ledger points to the bottom grid edge")
	t.eq(inventory.snapshot(), before, "preview is pure")
	var footprint_chip := panel.get_node("LootGridPanel/FootprintChip") as Label
	t.eq(footprint_chip.text, tr("INVENTORY_FOOTPRINT_CHIP").format({"w": 1, "h": 2}), "held ledger strip shows the unrotated footprint")
	t.ok((panel.get_node("LootGridPanel/FootprintShapeCue") as Control).get_child_count() == 2, "footprint chip includes one shape cell per vertical ledger cell")
	panel.toggle_rotate()
	t.ok(panel.pending_rotated, "rotate changes pending preview only")
	t.eq(footprint_chip.text, tr("INVENTORY_FOOTPRINT_CHIP").format({"w": 2, "h": 1}), "held ledger strip updates the footprint immediately after rotate")
	t.ok((panel.get_node("LootGridPanel/FootprintShapeCue") as Control).get_child_count() == 2, "rotated footprint keeps its two-cell shape cue")
	t.eq(inventory.snapshot(), before, "rotate does not mutate inventory")
	var valid := panel.preview_cell(RetrieverInventory.BACKPACK, Vector2i(0, 3))
	t.ok(valid.ok, "rotated preview fits before release")
	t.eq((panel.get_node("LootGridPanel/Backpack/Cell_0_3") as Button).text, "▣", "valid touch draws a solid footprint ghost")
	var placed := panel.release_cell(RetrieverInventory.BACKPACK, Vector2i(0, 3))
	t.ok(placed.ok, "rotated ledger commits at bottom row")
	t.ok(inventory.backpack.items.has(102), "ledger is in backpack")
	t.eq(inventory.backpack.items[102].cells(), [Vector2i(0, 3), Vector2i(1, 3)], "rotated cells are committed")
	t.eq(cache.cache_state(), &"partial", "only committed item leaves cache")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_pickup_zone_b_invalid_preview_status_does_not_cover_grid_labels_at_1280x720(t) -> bool:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	t.tree.root.add_child(viewport)
	var host := Control.new()
	viewport.add_child(host)
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var inventory := StarterInventoryFactory.create()
	var cache := LootCache.new(inventory.registry)
	var panel := CARD_SCENE.instantiate() as LootCachePanel
	panel.configure(inventory, cache)
	host.add_child(panel)
	await t.tree.process_frame
	panel.open_card(1)
	panel.open_pickup()
	var invalid := panel.preview_cell(RetrieverInventory.BACKPACK, Vector2i(0, 3))
	t.eq(invalid.reason, InventoryReason.Value.OUT_OF_BOUNDS, "given preview is invalid")
	await t.tree.process_frame
	var status := panel.get_node("LootGridPanel/Status") as Label
	var backpack_label := panel.get_node("LootGridPanel/BackpackLabel") as Label
	var notary_box_label := panel.get_node("LootGridPanel/NotaryBoxLabel") as Label
	t.ok(status.text.contains(tr("INVENTORY_REASON_OUT_OF_BOUNDS")), "status keeps the invalid-preview reason")
	t.ok(not status.get_global_rect().intersects(backpack_label.get_global_rect()), "status does not overlap the backpack label")
	t.ok(not status.get_global_rect().intersects(notary_box_label.get_global_rect()), "status does not overlap the Notary Box label")
	viewport.queue_free()
	await t.tree.process_frame
	return true


func test_ui_pickup_zone_b_dragging_outside_pressed_cell_cancels_pickup(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var cache := LootCache.new(inventory.registry)
	var panel := CARD_SCENE.instantiate() as LootCachePanel
	panel.configure(inventory, cache)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel.open_card(1)
	panel.open_pickup()
	panel.toggle_rotate()
	var backpack := panel.get_node("LootGridPanel/Backpack") as InventoryGridWidget
	var anchor := Vector2i(0, 3)
	var pressed_cell := backpack.get_node("Cell_0_3") as Button
	var before := inventory.snapshot()
	var press := InputEventScreenTouch.new()
	press.index = 3
	press.position = pressed_cell.get_global_rect().get_center()
	press.pressed = true
	backpack._on_cell_gui_input(press, anchor)
	var outside := backpack.get_global_rect().end + Vector2(8.0, 8.0)
	var drag := InputEventScreenDrag.new()
	drag.index = 3
	drag.position = outside
	backpack._on_cell_gui_input(drag, anchor)
	var release := InputEventScreenTouch.new()
	release.index = 3
	release.position = outside
	release.pressed = false
	backpack._on_cell_gui_input(release, anchor)
	t.eq(inventory.snapshot(), before, "releasing outside the pressed cell does not commit pickup")
	t.eq(cache.cache_state(), &"full", "releasing outside leaves the cache unchanged")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_pickup_zone_b_dragging_sixteen_pixels_or_button_pressed_cancels_pickup(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var cache := LootCache.new(inventory.registry)
	var panel := CARD_SCENE.instantiate() as LootCachePanel
	panel.configure(inventory, cache)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel.open_card(1)
	panel.open_pickup()
	panel.toggle_rotate()
	var backpack := panel.get_node("LootGridPanel/Backpack") as InventoryGridWidget
	var anchor := Vector2i(0, 3)
	var pressed_cell := backpack.get_node("Cell_0_3") as Button
	var before := inventory.snapshot()
	var press := InputEventScreenTouch.new()
	press.index = 4
	press.position = pressed_cell.get_global_rect().get_center()
	press.pressed = true
	backpack._on_cell_gui_input(press, anchor)
	pressed_cell.pressed.emit()
	t.eq(inventory.snapshot(), before, "Button.pressed after ScreenTouch cannot bypass touch release")
	t.eq(cache.cache_state(), &"full", "Button.pressed leaves cache unchanged")
	var drag := InputEventScreenDrag.new()
	drag.index = 4
	drag.position = press.position + Vector2(16.0, 0.0)
	backpack._on_cell_gui_input(drag, anchor)
	t.eq(backpack.touch_preview_cells.size(), 0, "sixteen-pixel drag clears the preview immediately")
	var release := InputEventScreenTouch.new()
	release.index = 4
	release.position = drag.position
	release.pressed = false
	backpack._on_cell_gui_input(release, anchor)
	t.eq(inventory.snapshot(), before, "sixteen-pixel drag cannot commit within the same cell")
	t.eq(cache.cache_state(), &"full", "cancelled touch leaves cache unchanged")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_pickup_zone_b_s03_text_uses_the_reference_font_floor(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var cache := LootCache.new(inventory.registry)
	var panel := CARD_SCENE.instantiate() as LootCachePanel
	panel.configure(inventory, cache)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	var details := panel._card.get_node("CacheCardPanel/Rows/Details") as VBoxContainer
	for detail: Label in details.get_children():
		t.ok(detail.get_theme_font_size("font_size") >= 24, "card detail %s meets the 24 px reference floor" % detail.name)
	panel.open_card(1)
	panel.open_pickup()
	for node_path in [NodePath("LootGridPanel/HeldItem"), NodePath("LootGridPanel/Status"), NodePath("LootGridPanel/BackpackLabel"), NodePath("LootGridPanel/NotaryBoxLabel")]:
		var label := panel.get_node(node_path) as Label
		t.ok(label.get_theme_font_size("font_size") >= 24, "%s meets the 24 px reference floor" % node_path)
	var rotate := panel.get_node("LootGridPanel/RotateButton") as Button
	t.ok(rotate.get_theme_font_size("font_size") >= 24, "rotate button meets the 24 px reference floor")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_pickup_zone_b_grid_renders_read_only_sling_remedy(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var cache := LootCache.new(inventory.registry)
	var panel := CARD_SCENE.instantiate() as LootCachePanel
	panel.configure(inventory, cache)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel.open_pickup()
	var sling_item := inventory.sling_pouch.all_items()[0] as ItemInstance
	var sling_label := panel.get_node("LootGridPanel/SlingPouch") as Label
	var sling_cue := panel.get_node("LootGridPanel/SlingPouchCue") as Label
	var sling_item_label := panel.get_node("LootGridPanel/SlingPouchItem") as Label
	t.eq(sling_label.text, tr("LOADOUT_LABEL_SLING_POUCH"), "grid identifies the read-only sling pouch")
	t.eq(sling_cue.text, "✚", "sling remedy has a non-colour recovery cue")
	t.eq(sling_item_label.text, sling_item.definition.localized_display_name() + " " + tr("CARD_QUANTITY_SUFFIX").format({"quantity": sling_item.quantity}), "grid reads sling remedy name and quantity from inventory")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_pickup_zone_b_view_rotates_only_through_inventory_and_locks_withdraw(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var cache := LootCache.new(inventory.registry)
	var ledger := cache.item_at(1)
	t.ok(inventory.commit_pickup(ledger, RetrieverInventory.BACKPACK, Vector2i(0, 0), false).ok, "given ledger is carried")
	cache.remove_after_pickup(ledger.uid)
	var panel := CARD_SCENE.instantiate() as LootCachePanel
	panel.configure(inventory, cache)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel.open_view()
	panel._on_item_pressed(ledger.uid)
	var before := inventory.snapshot()
	panel.toggle_rotate()
	t.ok(panel.pending_rotated, "view rotate changes preview before any commit")
	t.eq(inventory.snapshot(), before, "view rotate does not mutate inventory")
	t.ok(panel.release_cell(RetrieverInventory.BACKPACK, Vector2i(0, 0)).ok, "view commits same-grid rotated move through inventory")
	t.ok(inventory.backpack.items[ledger.uid].rotated, "ledger rotation is committed by RetrieverInventory")
	var sealed := inventory.notary_box.all_items()[0] as ItemInstance
	panel._on_item_pressed(sealed.uid)
	var locked_before := inventory.snapshot()
	var locked := panel.release_cell(RetrieverInventory.BACKPACK, Vector2i(2, 3))
	t.ok(not locked.ok, "sealed item cannot be withdrawn through the S03 dock")
	t.eq(inventory.snapshot(), locked_before, "locked withdraw keeps the inventory snapshot")
	t.ok(panel._status.text.contains(tr("INVENTORY_REASON_WITHDRAW_LOCKED")), "locked withdraw names the reason")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_pickup_zone_b_touching_selected_item_cancels_pending_rotation_without_commit(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var cache := LootCache.new(inventory.registry)
	var ledger := cache.item_at(1)
	t.ok(inventory.commit_pickup(ledger, RetrieverInventory.BACKPACK, Vector2i(0, 0), false).ok, "given ledger is carried")
	cache.remove_after_pickup(ledger.uid)
	var panel := CARD_SCENE.instantiate() as LootCachePanel
	panel.configure(inventory, cache)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel.open_view()
	panel._on_item_pressed(ledger.uid)
	panel.toggle_rotate()
	var before := inventory.snapshot()
	var item_button := panel.get_node("LootGridPanel/Backpack/Item_%d" % ledger.uid) as Button
	var viewport: Viewport = t.tree.root.get_viewport()
	_push_screen_touch(viewport, 8, item_button.get_global_rect().get_center(), true)
	await t.tree.process_frame
	_push_screen_touch(viewport, 8, item_button.get_global_rect().get_center(), false)
	await t.tree.process_frame
	t.eq(panel.selected_uid, 0, "touching the selected item deselects it")
	t.eq(inventory.snapshot(), before, "deselecting a rotated item does not commit the pending move")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_pickup_zone_b_focused_cell_activation_commits_selected_item(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var cache := LootCache.new(inventory.registry)
	var ledger := cache.item_at(1)
	t.ok(inventory.commit_pickup(ledger, RetrieverInventory.BACKPACK, Vector2i(0, 0), false).ok, "given ledger is carried")
	cache.remove_after_pickup(ledger.uid)
	var panel := CARD_SCENE.instantiate() as LootCachePanel
	panel.configure(inventory, cache)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel.open_view()
	panel._on_item_pressed(ledger.uid)
	panel.toggle_rotate()
	var destination := panel.get_node("LootGridPanel/Backpack/Cell_0_0") as Button
	destination.grab_focus()
	_push_action(t.tree.root.get_viewport(), &"ui_accept", true)
	await t.tree.process_frame
	_push_action(t.tree.root.get_viewport(), &"ui_accept", false)
	await t.tree.process_frame
	t.ok(inventory.backpack.items[ledger.uid].rotated, "focused-cell activation commits the rotated move")
	t.eq(inventory.backpack.items[ledger.uid].anchor, Vector2i(0, 0), "focused-cell activation uses the focused anchor")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_pickup_zone_b_dock_uses_the_specified_right_side_regions(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var cache := LootCache.new(inventory.registry)
	var panel := CARD_SCENE.instantiate() as LootCachePanel
	panel.configure(inventory, cache)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	var card_rect: Rect2 = (panel._card.get_node("CacheCardPanel") as Control).get_global_rect()
	t.eq(card_rect.position, Vector2(704, 120), "card dock starts at R10c")
	t.eq(card_rect.size, Vector2(560, 584), "card dock keeps R10c size")
	panel.open_pickup()
	var grid_rect: Rect2 = (panel.get_node("LootGridPanel") as Control).get_global_rect()
	t.eq(grid_rect.position, Vector2(704, 176), "grid dock starts at R10g")
	t.eq(grid_rect.size, Vector2(560, 528), "grid dock keeps R10g size")
	var close_rect: Rect2 = (panel.get_node("CloseButton") as Control).get_global_rect()
	t.eq(close_rect.position, Vector2(1168, 16), "dock close button occupies R3")
	panel.queue_free()
	await t.tree.process_frame
	return true


func _push_screen_touch(viewport: Viewport, index: int, position: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	viewport.push_input(event, true)


func _push_action(viewport: Viewport, action: StringName, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	viewport.push_input(event, true)


func test_ui_pickup_zone_b_dock_and_close_stay_right_inset_on_expanded_viewport(t) -> bool:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1600, 720)
	t.tree.root.add_child(viewport)
	var host := Control.new()
	viewport.add_child(host)
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var inventory := StarterInventoryFactory.create()
	var cache := LootCache.new(inventory.registry)
	var panel := CARD_SCENE.instantiate() as LootCachePanel
	panel.configure(inventory, cache)
	host.add_child(panel)
	await t.tree.process_frame
	var card_rect: Rect2 = (panel._card.get_node("CacheCardPanel") as Control).get_global_rect()
	t.eq(card_rect.position, Vector2(1024, 120), "card dock stays top-right at expanded width")
	t.eq(1600.0 - card_rect.end.x, 16.0, "card dock keeps its R10c right inset")
	var card_close_rect: Rect2 = (panel._card.get_node("CloseButton") as Control).get_global_rect()
	t.eq(card_close_rect.position, Vector2(1488, 16), "card close button stays in R3 at expanded width")
	t.eq(1600.0 - card_close_rect.end.x, 16.0, "card close button keeps its R3 right inset")
	panel.open_pickup()
	var grid_rect: Rect2 = (panel.get_node("LootGridPanel") as Control).get_global_rect()
	t.eq(grid_rect.position, Vector2(1024, 176), "grid dock stays top-right at expanded width")
	t.eq(1600.0 - grid_rect.end.x, 16.0, "grid dock keeps its R10g right inset")
	var grid_close_rect: Rect2 = (panel.get_node("CloseButton") as Control).get_global_rect()
	t.eq(grid_close_rect.position, Vector2(1488, 16), "grid close button stays in R3 at expanded width")
	t.eq(1600.0 - grid_close_rect.end.x, 16.0, "grid close button keeps its R3 right inset")
	viewport.queue_free()
	await t.tree.process_frame
	return true
