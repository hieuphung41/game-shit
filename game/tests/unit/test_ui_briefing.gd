extends RefCounted

const BRIEFING_SCENE := preload("res://src/ui/briefing/briefing.tscn")


func test_ui_briefing_emits_loadout_and_valid_enter_once(t) -> bool:
	var briefing := BRIEFING_SCENE.instantiate() as BriefingScreen
	var loadout_requests := 0
	var enter_requests := 0
	briefing.loadout_requested.connect(func(_inventory: RetrieverInventory) -> void: loadout_requests += 1)
	briefing.enter_outer_pier_requested.connect(func(_inventory: RetrieverInventory) -> void: enter_requests += 1)
	t.tree.root.add_child(briefing)
	await t.tree.process_frame
	briefing.request_loadout()
	briefing.request_enter()
	briefing.request_enter()
	t.eq(loadout_requests, 1, "briefing requests O1")
	t.eq(enter_requests, 1, "valid enter emits exactly once")
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
