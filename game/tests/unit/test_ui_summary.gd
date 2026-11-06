extends RefCounted

const SUMMARY_SCENE := preload("res://src/ui/summary/extract_summary_screen.tscn")


func test_ui_summary_hides_empty_loss_and_emits_hub_once(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var summary := ExtractSummary.new()
	summary.kept = [{"uid": 1, "def_id": &"starter_remedy"}]
	summary.evidence = [&"manifest_r17"]
	summary.backpack_cells_used = 1
	summary.backpack_cells_total = 12
	var screen := SUMMARY_SCENE.instantiate() as ExtractSummaryScreen
	screen.show_summary(summary, inventory.registry)
	var hub_requests: Array[bool] = []
	screen.hub_requested.connect(func() -> void: hub_requests.append(true))
	t.tree.root.add_child(screen)
	await t.tree.process_frame
	t.ok(screen.get_node_or_null("LeftGroups/LostGroup") == null, "empty lost group is absent")
	t.ok(screen.get_node_or_null("RightGroups/NextGroup/Content/Contract2") != null, "contract 2 is informational")
	t.ok(screen.get_node_or_null("RightGroups/NextGroup/Content/Contract2Button") == null, "contract 2 has no start button")
	screen._opened_at_msec = -1000
	t.ok(not screen._input_guard_active(), "summary accepts input after the open guard")
	(screen.get_node("HubButton") as Button).pressed.emit()
	(screen.get_node("HubButton") as Button).pressed.emit()
	t.eq(hub_requests.size(), 1, "hub signal is protected from double press")
	t.ok((screen.get_node("LeftGroups/KeptGroup/Content/Line2") as Label).text.contains("1/12"), "used backpack cells shown")
	screen.queue_free()
	await t.tree.process_frame
	return true
