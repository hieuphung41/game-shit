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


func test_ui_summary_evidence_uses_summary_data(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var empty_summary := ExtractSummary.new()
	var empty_screen := SUMMARY_SCENE.instantiate() as ExtractSummaryScreen
	empty_screen.show_summary(empty_summary, inventory.registry)
	t.tree.root.add_child(empty_screen)
	await t.tree.process_frame
	var empty_content := empty_screen.get_node("RightGroups/EvidenceGroup/Content") as VBoxContainer
	t.eq(empty_content.get_child_count(), 1, "empty evidence has no fabricated manifest lines")
	empty_screen.queue_free()
	await t.tree.process_frame
	var other_definition := ItemDef.new()
	other_definition.id = &"test_evidence"
	other_definition.display_name_key = &"ITEM_STARTER_REMEDY_NAME"
	other_definition.item_category = ItemDef.Category.EVIDENCE
	inventory.registry.add(other_definition)
	var other_summary := ExtractSummary.new()
	other_summary.evidence = [&"test_evidence"]
	var other_screen := SUMMARY_SCENE.instantiate() as ExtractSummaryScreen
	other_screen.show_summary(other_summary, inventory.registry)
	t.tree.root.add_child(other_screen)
	await t.tree.process_frame
	var other_content := other_screen.get_node("RightGroups/EvidenceGroup/Content") as VBoxContainer
	t.eq(other_content.get_child_count(), 2, "non-manifest evidence renders one data-backed line")
	t.eq((other_content.get_node("Line0") as Label).text, tr("ITEM_STARTER_REMEDY_NAME"), "non-manifest evidence does not claim Manifest")
	other_screen.queue_free()
	await t.tree.process_frame
	return true


func test_ui_summary_routes_cancel_to_hub_without_gui_focus(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var screen := SUMMARY_SCENE.instantiate() as ExtractSummaryScreen
	screen.show_summary(ExtractSummary.new(), inventory.registry)
	var hub_requests: Array[bool] = []
	screen.hub_requested.connect(func() -> void: hub_requests.append(true))
	t.tree.root.add_child(screen)
	await t.tree.process_frame
	screen._opened_at_msec = -1000
	var event := InputEventAction.new()
	event.action = &"ui_cancel"
	event.pressed = true
	t.tree.root.get_viewport().push_input(event)
	await t.tree.process_frame
	t.eq(hub_requests.size(), 1, "S10 receives ui_cancel without GUI focus")
	screen.queue_free()
	await t.tree.process_frame
	return true
