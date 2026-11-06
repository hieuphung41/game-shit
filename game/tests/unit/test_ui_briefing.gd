extends RefCounted

const BRIEFING_SCENE := preload("res://src/ui/briefing/briefing.tscn")


func test_ui_briefing_emits_loadout_and_valid_enter_once(t) -> bool:
	var briefing := BRIEFING_SCENE.instantiate() as BriefingScreen
	var loadout_requests: Array[RetrieverInventory] = []
	var enter_requests: Array[RetrieverInventory] = []
	briefing.loadout_requested.connect(func(requested_inventory: RetrieverInventory) -> void: loadout_requests.append(requested_inventory))
	briefing.enter_outer_pier_requested.connect(func(requested_inventory: RetrieverInventory) -> void: enter_requests.append(requested_inventory))
	t.tree.root.add_child(briefing)
	await t.tree.process_frame
	t.ok(briefing._input_guard_active(), "briefing guards touch immediately after opening")
	briefing._opened_at_msec = 0
	(briefing.get_node("EditLoadoutButton") as Button).pressed.emit()
	(briefing.get_node("EnterButton") as Button).pressed.emit()
	(briefing.get_node("EnterButton") as Button).pressed.emit()
	t.eq(loadout_requests.size(), 1, "briefing requests O1")
	t.eq(enter_requests.size(), 1, "valid enter emits exactly once")
	t.ok(briefing.get_node("Objective").text.contains(tr("BRIEFING_OBJECTIVE_MAIN")), "objective visible")
	briefing.queue_free()
	await t.tree.process_frame
	return true


func test_ui_briefing_disables_enter_for_invalid_inventory(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	inventory.load_snapshot({
		"backpack": [
			{"uid": 3, "def_id": &"starter_remedy", "quantity": 1, "anchor": Vector2i.ZERO, "rotated": false},
			{"uid": 4, "def_id": &"starter_remedy", "quantity": 1, "anchor": Vector2i.ZERO, "rotated": false},
		],
		"notary_box": [],
		"sling_pouch": [],
	})
	var briefing := BRIEFING_SCENE.instantiate() as BriefingScreen
	briefing.open_with_inventory(inventory)
	var enter_requests := 0
	briefing.enter_outer_pier_requested.connect(func(_inventory: RetrieverInventory) -> void: enter_requests += 1)
	t.tree.root.add_child(briefing)
	await t.tree.process_frame
	var enter_button := briefing.get_node("EnterButton") as Button
	t.ok(enter_button.disabled, "invalid loadout disables enter")
	briefing.request_enter()
	t.eq(enter_requests, 0, "invalid enter does not emit")
	t.ok(briefing.get_node("Status").text.contains(tr("BRIEFING_BUTTON_ENTER_BLOCKED")), "blocked reason visible")
	briefing.queue_free()
	await t.tree.process_frame
	return true


func test_ui_briefing_keeps_scene_load_error_and_tooltip_is_touchable(t) -> bool:
	var briefing := BRIEFING_SCENE.instantiate() as BriefingScreen
	briefing.open_with_inventory(StarterInventoryFactory.create())
	t.tree.root.add_child(briefing)
	await t.tree.process_frame
	briefing._opened_at_msec = 0
	briefing.show_scene_load_error()
	t.eq((briefing.get_node("Status") as Label).text, tr("UI_ERROR_SCENE_LOAD"), "load error remains visible")
	t.ok(not (briefing.get_node("EnterButton") as Button).disabled, "load error enables retry")
	var tooltip := briefing.get_node("Tooltip") as Button
	tooltip.visible = true
	tooltip.pressed.emit()
	t.ok(not tooltip.visible, "touching tooltip hides it")
	briefing.queue_free()
	await t.tree.process_frame
	return true
