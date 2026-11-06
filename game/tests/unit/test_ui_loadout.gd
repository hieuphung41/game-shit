extends RefCounted

const LOADOUT_SCENE := preload("res://src/ui/loadout/loadout.tscn")


func test_ui_loadout_moves_only_in_same_grid_and_restores_cancel(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var before := inventory.snapshot()
	var loadout := LOADOUT_SCENE.instantiate() as LoadoutScreen
	loadout.open_with_inventory(inventory)
	t.tree.root.add_child(loadout)
	await t.tree.process_frame
	t.ok(loadout._input_guard_active(), "loadout guards touch immediately after opening")
	loadout._opened_at_msec = 0
	(loadout.get_node("NotaryBox/Item_1") as Button).pressed.emit()
	(loadout.get_node("NotaryBox/Cell_1_0") as Button).pressed.emit()
	t.eq(inventory.notary_box.items[1].anchor, Vector2i(1, 0), "valid touch moves remedy")
	var after_move := inventory.snapshot()
	(loadout.get_node("NotaryBox/Item_1") as Button).pressed.emit()
	(loadout.get_node("NotaryBox/Cell_0_1") as Button).pressed.emit()
	t.eq(inventory.snapshot(), after_move, "invalid touch is atomic")
	t.ok(loadout.get_node("Status").text.contains(tr("INVENTORY_REASON_OUT_OF_BOUNDS")), "invalid reason uses translation")
	(loadout.get_node("CancelButton") as Button).pressed.emit()
	t.eq(inventory.snapshot(), before, "cancel restores open snapshot")
	loadout.queue_free()
	await t.tree.process_frame
	return true


func test_ui_loadout_marks_cross_grid_as_locked(t) -> bool:
	var loadout := LOADOUT_SCENE.instantiate() as LoadoutScreen
	t.tree.root.add_child(loadout)
	await t.tree.process_frame
	loadout._opened_at_msec = 0
	(loadout.get_node("NotaryBox/Item_1") as Button).pressed.emit()
	(loadout.get_node("Backpack/Cell_0_0") as Button).pressed.emit()
	t.ok(loadout.get_node("Status").text.contains(tr("INVENTORY_REASON_CROSS_GRID_LOCKED")), "cross-grid move is locked")
	loadout.queue_free()
	await t.tree.process_frame
	return true


func test_ui_loadout_starter_sling_remedy_is_a_distinct_1x1_item(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var pouch_item := inventory.sling_pouch.items[2] as ItemInstance
	t.eq(pouch_item.def_id, &"sling_remedy", "sling pouch has its own remedy")
	t.eq(pouch_item.effective_size(), Vector2i.ONE, "sling remedy is 1x1")
	t.eq(pouch_item.definition.localized_display_name(), tr("ITEM_SLING_REMEDY_NAME"), "sling label uses translation")
	return true


func test_ui_loadout_grid_cells_keep_minimum_touch_size_at_small_window(t) -> bool:
	var design_cell := InventoryGridWidget.logical_cell_size_for_window(Vector2i(1280, 720))
	var small_cell := InventoryGridWidget.logical_cell_size_for_window(Vector2i(640, 360))
	t.eq(design_cell, 96.0, "design viewport retains 96 logical-pixel cells")
	t.eq(small_cell, 128.0, "small viewport enlarges cells before canvas scaling")
	t.ok(small_cell * 0.5 >= InventoryGridWidget.MIN_TOUCH_PIXELS, "small-window cell is at least 64 physical pixels")
	return true
