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
	t.eq(inventory.snapshot(), before, "preview is pure")
	panel.toggle_rotate()
	t.ok(panel.pending_rotated, "rotate changes pending preview only")
	t.eq(inventory.snapshot(), before, "rotate does not mutate inventory")
	var placed := panel.release_cell(RetrieverInventory.BACKPACK, Vector2i(0, 3))
	t.ok(placed.ok, "rotated ledger commits at bottom row")
	t.ok(inventory.backpack.items.has(102), "ledger is in backpack")
	t.eq(inventory.backpack.items[102].cells(), [Vector2i(0, 3), Vector2i(1, 3)], "rotated cells are committed")
	t.eq(cache.cache_state(), &"partial", "only committed item leaves cache")
	panel.queue_free()
	await t.tree.process_frame
	return true
