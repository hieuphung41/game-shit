extends RefCounted

const LOADOUT_SCENE := preload("res://src/ui/loadout/loadout.tscn")


func test_ui_loadout_moves_only_in_same_grid_and_restores_cancel(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var before := inventory.snapshot()
	var loadout := LOADOUT_SCENE.instantiate() as LoadoutScreen
	loadout.open_with_inventory(inventory)
	t.tree.root.add_child(loadout)
	await t.tree.process_frame
	loadout.select_item(1)
	loadout.tap_cell(RetrieverInventory.NOTARY_BOX, Vector2i(1, 0))
	t.eq(inventory.notary_box.items[1].anchor, Vector2i(1, 0), "valid touch moves remedy")
	var after_move := inventory.snapshot()
	loadout.select_item(1)
	loadout.tap_cell(RetrieverInventory.NOTARY_BOX, Vector2i(0, 1))
	t.eq(inventory.snapshot(), after_move, "invalid touch is atomic")
	t.ok(loadout.get_node("Status").text.contains(tr("INVENTORY_REASON_OUT_OF_BOUNDS")), "invalid reason uses translation")
	loadout.cancel()
	t.eq(inventory.snapshot(), before, "cancel restores open snapshot")
	loadout.queue_free()
	await t.tree.process_frame
	return true


func test_ui_loadout_marks_cross_grid_as_locked(t) -> bool:
	var loadout := LOADOUT_SCENE.instantiate() as LoadoutScreen
	t.tree.root.add_child(loadout)
	await t.tree.process_frame
	loadout.select_item(1)
	loadout.tap_cell(RetrieverInventory.BACKPACK, Vector2i.ZERO)
	t.ok(loadout.get_node("Status").text.contains(tr("INVENTORY_REASON_CROSS_GRID_LOCKED")), "cross-grid move is locked")
	loadout.queue_free()
	await t.tree.process_frame
	return true
