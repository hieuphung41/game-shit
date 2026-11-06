extends RefCounted

const CARD_SCENE := preload("res://src/ui/pickup/pickup_card.tscn")
const PANEL_SCENE := preload("res://src/ui/pickup/pickup_panel.tscn")


func test_ui_pickup_card_emits_only_explicit_actions(t) -> bool:
	var card := CARD_SCENE.instantiate() as ManifestPickupCard
	var pickups: Array[bool] = []
	var closes: Array[bool] = []
	var skips: Array[bool] = []
	card.pickup_requested.connect(func() -> void: pickups.append(true))
	card.closed.connect(func() -> void: closes.append(true))
	card.skipped.connect(func() -> void: skips.append(true))
	t.tree.root.add_child(card)
	await t.tree.process_frame
	card._opened_at_msec = -1000
	t.ok(not card._input_guard_active(), "card accepts input after the open guard")
	(card.get_node("CardPanel/PickAndPlaceButton") as Button).pressed.emit()
	(card.get_node("CardPanel/SkipButton") as Button).pressed.emit()
	(card.get_node("CardPanel/CloseButton") as Button).pressed.emit()
	t.eq(pickups.size(), 1, "card emits pickup intent")
	t.eq(skips.size(), 1, "card emits distinct skip intent")
	t.eq(closes.size(), 1, "card emits close intent")
	t.eq((card.get_node("CardPanel/Detail0") as Label).text, tr("CARD_MANIFEST_R17_NAME"), "name is first detail")
	t.eq((card.get_node("CardPanel/Detail5") as Label).text, tr("CARD_MANIFEST_R17_LORE"), "lore is last detail")
	card.queue_free()
	await t.tree.process_frame
	return true


func test_ui_pickup_overlays_keep_r6_touch_and_cancel_available_without_focus(t) -> bool:
	var card := CARD_SCENE.instantiate() as ManifestPickupCard
	var card_closed: Array[bool] = []
	card.closed.connect(func() -> void: card_closed.append(true))
	var card_directions := await _overlay_passes_r6_touch(t, card)
	card._opened_at_msec = -1000
	_push_cancel(t.tree.root.get_viewport())
	await t.tree.process_frame
	t.eq(card_directions.size(), 1, "O2 ignored backdrop passes R6 touch to the joystick")
	t.eq(card_closed.size(), 1, "O2 receives ui_cancel without GUI focus")
	card.queue_free()
	await t.tree.process_frame

	var inventory := StarterInventoryFactory.create()
	var panel := PANEL_SCENE.instantiate() as ManifestPickupPanel
	panel.open_pickup(inventory, _manifest(inventory))
	var panel_closed: Array[bool] = []
	panel.closed.connect(func(placed: bool) -> void: panel_closed.append(placed))
	var panel_directions := await _overlay_passes_r6_touch(t, panel)
	panel._opened_at_msec = -1000
	_push_cancel(t.tree.root.get_viewport())
	await t.tree.process_frame
	t.eq(panel_directions.size(), 1, "O3/O4 ignored backdrop passes R6 touch to the joystick")
	t.eq(panel_closed.size(), 1, "O3/O4 receives ui_cancel without GUI focus")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_pickup_panel_commits_only_valid_manifest_slot(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var manifest := _manifest(inventory)
	var before := inventory.snapshot()
	var panel := PANEL_SCENE.instantiate() as ManifestPickupPanel
	panel.open_pickup(inventory, manifest)
	var placements: Array[Dictionary] = []
	panel.manifest_placed.connect(func(target: StringName, anchor: Vector2i) -> void: placements.append({"target": target, "anchor": anchor}))
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel._opened_at_msec = -1000
	var occupied := inventory.notary_box.all_items()[0] as ItemInstance
	(panel.get_node("PickupPanel/NotaryBox/Item_%d" % occupied.uid) as Button).pressed.emit()
	t.eq(inventory.snapshot(), before, "occupied notary cell leaves inventory unchanged")
	var status := panel.get_node("PickupPanel/Status") as Label
	var backpack := panel.get_node("PickupPanel/Backpack") as InventoryGridWidget
	t.ok(status.text.contains(tr("INVENTORY_REASON_CELLS_OCCUPIED")), "occupied item touch routes to the pickup reason")
	t.ok(status.visible and not status.get_global_rect().intersects(backpack.get_global_rect()), "invalid reason is visible above the backpack grid")
	(panel.get_node("PickupPanel/Backpack/Cell_2_3") as Button).pressed.emit()
	t.eq(placements.size(), 1, "valid placement emits once")
	t.eq(placements[0]["target"], RetrieverInventory.BACKPACK, "signal names target grid")
	t.eq(placements[0]["anchor"], Vector2i(2, 3), "signal includes selected anchor")
	t.ok(inventory.backpack.items.has(manifest.uid), "manifest moved into backpack")
	t.eq(panel.mode, ManifestPickupPanel.Mode.VIEW, "panel changes to view after success")
	t.ok((panel.get_node("PickupPanel/Status") as Label).text.contains(tr("PROMPT_SAFEBOX_SEAL_HINT")), "view displays seal hint")
	panel.queue_free()
	await t.tree.process_frame
	return true


func test_ui_pickup_panel_localizes_selected_item_text(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var panel := PANEL_SCENE.instantiate() as ManifestPickupPanel
	panel.open_view(inventory)
	t.tree.root.add_child(panel)
	await t.tree.process_frame
	panel._opened_at_msec = -1000
	var item := inventory.notary_box.all_items()[0] as ItemInstance
	panel.select_item(item.uid)
	var expected := tr("INVENTORY_SELECTED_ITEM").format({
		"item": item.definition.localized_display_name(),
		"width": item.effective_size().x,
		"height": item.effective_size().y,
	})
	t.eq((panel.get_node("PickupPanel/Status") as Label).text, expected, "selected item uses a localized format key")
	panel.queue_free()
	await t.tree.process_frame
	return true


func _manifest(inventory: RetrieverInventory) -> ItemInstance:
	var definition := ItemDef.new()
	definition.id = &"manifest_r17"
	definition.display_name_key = &"CARD_MANIFEST_R17_NAME"
	definition.size = Vector2i.ONE
	definition.sealable = true
	definition.item_category = ItemDef.Category.EVIDENCE
	inventory.registry.add(definition)
	return ItemInstance.new(17, definition)


func _overlay_passes_r6_touch(t, overlay: Control) -> Array[Vector2]:
	var joystick := TouchJoystick.new()
	joystick.position = Vector2(0.0, 460.0)
	joystick.size = Vector2(260.0, 260.0)
	var directions: Array[Vector2] = []
	joystick.direction_changed.connect(func(direction: Vector2) -> void: directions.append(direction))
	t.tree.root.add_child(joystick)
	t.tree.root.add_child(overlay)
	await t.tree.process_frame
	t.ok(joystick.get_global_rect().has_point(Vector2(130.0, 590.0)), "R6 point is inside the joystick")
	_push_touch(t.tree.root.get_viewport(), Vector2(130.0, 590.0))
	await t.tree.process_frame
	joystick.queue_free()
	await t.tree.process_frame
	return directions


func _push_touch(viewport: Viewport, position: Vector2) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = position
	event.pressed = true
	viewport.push_input(event, true)


func _push_cancel(viewport: Viewport) -> void:
	var event := InputEventAction.new()
	event.action = &"ui_cancel"
	event.pressed = true
	viewport.push_input(event)
