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
	t.ok(screen.get_node_or_null("LeftScroll/LeftGroups/LostGroup") == null, "empty lost group is absent")
	t.ok(screen.get_node_or_null("RightScroll/RightGroups/NextGroup/Content/Contract2") != null, "contract 2 is informational")
	t.ok(screen.get_node_or_null("RightScroll/RightGroups/NextGroup/Content/Contract2Button") == null, "contract 2 has no start button")
	t.eq((screen.get_node("MentorSpeaker") as Label).text, tr("BRIEFING_MENTOR_SPEAKER"), "mentor speaker is labelled")
	t.eq((screen.get_node("MentorLine") as Label).text, tr("SUMMARY_SUCCESS_MENTOR_LINE"), "mentor response follows speaker")
	screen._opened_at_msec = -1000
	t.ok(not screen._input_guard_active(), "summary accepts input after the open guard")
	(screen.get_node("HubButton") as Button).pressed.emit()
	(screen.get_node("HubButton") as Button).pressed.emit()
	t.eq(hub_requests.size(), 1, "hub signal is protected from double press")
	t.ok((screen.get_node("LeftScroll/LeftGroups/KeptGroup/Content/Line2") as Label).text.contains("1/12"), "used backpack cells shown")
	screen.queue_free()
	await t.tree.process_frame
	return true


func test_ui_summary_renders_next_from_summary_data(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var empty_summary := ExtractSummary.new()
	empty_summary.next = []
	var empty_screen := SUMMARY_SCENE.instantiate() as ExtractSummaryScreen
	empty_screen.show_summary(empty_summary, inventory.registry)
	t.tree.root.add_child(empty_screen)
	await t.tree.process_frame
	var empty_content := empty_screen.get_node("RightScroll/RightGroups/NextGroup/Content") as VBoxContainer
	t.eq(empty_content.get_child_count(), 1, "empty next data has no fabricated contract card")
	empty_screen.queue_free()
	await t.tree.process_frame
	var future_summary := ExtractSummary.new()
	future_summary.next = [{"contract_id": &"contract_3", "playable": true}]
	var future_screen := SUMMARY_SCENE.instantiate() as ExtractSummaryScreen
	future_screen.show_summary(future_summary, inventory.registry)
	t.tree.root.add_child(future_screen)
	await t.tree.process_frame
	var future_content := future_screen.get_node("RightScroll/RightGroups/NextGroup/Content") as VBoxContainer
	t.ok(future_content.get_node_or_null("Contract3") != null, "next card uses its contract id")
	t.eq((future_content.get_node("Contract3") as Label).text, tr("SUMMARY_NEXT_CONTRACT3_TITLE"), "next card uses its contract translation key")
	t.ok(future_content.get_node_or_null("Contract3Locked") == null, "playable next contract has no unavailable tag")
	t.ok(future_content.get_node_or_null("Contract2") == null, "future data does not fabricate Contract 2")
	future_screen.queue_free()
	await t.tree.process_frame
	return true


func test_ui_summary_evidence_uses_summary_data(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var empty_summary := ExtractSummary.new()
	var empty_screen := SUMMARY_SCENE.instantiate() as ExtractSummaryScreen
	empty_screen.show_summary(empty_summary, inventory.registry)
	t.tree.root.add_child(empty_screen)
	await t.tree.process_frame
	var empty_content := empty_screen.get_node("RightScroll/RightGroups/EvidenceGroup/Content") as VBoxContainer
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
	var other_content := other_screen.get_node("RightScroll/RightGroups/EvidenceGroup/Content") as VBoxContainer
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


func test_ui_summary_scrolls_each_column_without_covering_footer(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var summary := ExtractSummary.new()
	for index in 24:
		summary.kept.append({"uid": index, "def_id": &"starter_remedy"})
	for index in 24:
		summary.next.append({"contract_id": StringName("contract_%d" % index), "playable": false})
	var screen := SUMMARY_SCENE.instantiate() as ExtractSummaryScreen
	screen.show_summary(summary, inventory.registry)
	t.tree.root.add_child(screen)
	await t.tree.process_frame
	await t.tree.process_frame
	var left_scroll := screen.get_node("LeftScroll") as ScrollContainer
	var right_scroll := screen.get_node("RightScroll") as ScrollContainer
	t.ok(left_scroll.get_v_scroll_bar().max_value > 0.0, "kept fixture overflows the left column")
	t.ok(right_scroll.get_v_scroll_bar().max_value > 0.0, "next fixture overflows the right column")
	left_scroll.scroll_vertical = int(left_scroll.get_v_scroll_bar().max_value)
	right_scroll.scroll_vertical = int(right_scroll.get_v_scroll_bar().max_value)
	t.ok(left_scroll.scroll_vertical > 0 and right_scroll.scroll_vertical > 0, "both columns can scroll vertically")
	var mentor := screen.get_node("MentorLine") as Label
	var hub := screen.get_node("HubButton") as Button
	t.ok(left_scroll.get_global_rect().end.y <= mentor.get_global_rect().position.y, "left scroll stops before mentor line")
	t.ok(right_scroll.get_global_rect().end.y <= hub.get_global_rect().position.y, "right scroll stops before hub button")
	screen.queue_free()
	await t.tree.process_frame
	return true


func test_ui_summary_focuses_hub_and_accept_activates_it(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var screen := SUMMARY_SCENE.instantiate() as ExtractSummaryScreen
	screen.show_summary(ExtractSummary.new(), inventory.registry)
	var hub_requests: Array[bool] = []
	screen.hub_requested.connect(func() -> void: hub_requests.append(true))
	t.tree.root.add_child(screen)
	await t.tree.process_frame
	var hub := screen.get_node("HubButton") as Button
	t.eq(t.tree.root.get_viewport().gui_get_focus_owner(), hub, "S10 opens with hub button focused")
	screen._opened_at_msec = -1000
	var accept := InputEventAction.new()
	accept.action = &"ui_accept"
	accept.pressed = true
	t.tree.root.get_viewport().push_input(accept, true)
	await t.tree.process_frame
	t.eq(hub_requests.size(), 1, "ui_accept reaches the focused hub button")
	screen.queue_free()
	await t.tree.process_frame
	return true


func test_ui_summary_shows_footprint_chip_and_left_behind_marker(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var cargo := ItemDef.new()
	cargo.id = &"cargo_d_2x2"
	cargo.display_name_key = &"ITEM_CARGO_D_2X2_NAME"
	cargo.size = Vector2i(2, 2)
	inventory.registry.add(cargo)
	var summary := ExtractSummary.new()
	summary.kept = [{"uid": 4, "def_id": &"cargo_d_2x2"}]
	summary.lost = [{"uid": 5, "def_id": &"starter_remedy"}]
	summary.backpack_cells_used = 4
	summary.backpack_cells_total = 12
	var screen := SUMMARY_SCENE.instantiate() as ExtractSummaryScreen
	screen.show_summary(summary, inventory.registry)
	t.tree.root.add_child(screen)
	await t.tree.process_frame
	var kept_line := screen.get_node("LeftScroll/LeftGroups/KeptGroup/Content/Line1") as Label
	var lost_line := screen.get_node("LeftScroll/LeftGroups/LostGroup/Content/Line0") as Label
	t.ok(kept_line.text.contains("2×2"), "S10 identifies the cargo footprint")
	t.ok(lost_line.text.contains("⌄"), "S10 marks left-behind items with a shape cue")
	screen.queue_free()
	await t.tree.process_frame
	return true
