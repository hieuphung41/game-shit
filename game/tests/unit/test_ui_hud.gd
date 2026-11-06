extends RefCounted

const HUD_SCENE := preload("res://src/ui/hud/extract_hud.tscn")


func test_ui_hud_projects_e0_e1_s7_s8_s9_without_lane_alert(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var flow := ExtractPierAFlow.new()
	flow.setup(inventory)
	var hud := HUD_SCENE.instantiate() as ExtractHud
	hud.set_flow(flow)
	t.tree.root.add_child(hud)
	await t.tree.process_frame
	t.eq((hud.get_node("ObjectivePanel/Objective") as Label).text, tr("HUD_OBJECTIVE_TAKE_MANIFEST"), "e0 objective shown")
	hud.set_desk_in_range(true)
	t.ok((hud.get_node("ContextButton") as Button).visible, "dispatch action appears in range")
	var manifest := _manifest(inventory)
	var pickup := inventory.commit_pickup(manifest, RetrieverInventory.BACKPACK, Vector2i.ZERO, false)
	t.ok(pickup.ok, "setup pickup succeeds")
	t.eq(flow.desk_state, ExtractPierAFlow.DeskState.EMPTY, "manifest placement empties desk")
	hud.set_desk_in_range(false)
	flow.set_in_beacon_zone(true)
	t.ok(flow.can_call(), "e1 in beacon zone can call")
	hud.refresh()
	t.ok((hud.get_node("ContextButton") as Button).text.contains(tr("EXTRACT_E1_BUTTON_CALL")), "e1 action uses call key")
	t.ok(flow.request_call(), "flow opens confirm")
	t.ok(flow.confirm_call(), "flow confirms call")
	flow.tick(0.25)
	flow.tick(0.25)
	flow.tick(0.25)
	flow.tick(0.25)
	flow.tick(0.25)
	flow.tick(0.25)
	t.ok((hud.get_node("BannerPanel/Banner") as Label).text.contains("20"), "s8 timer uses seconds placeholder")
	t.ok(not (hud.get_node("BannerPanel/Banner") as Label).text.contains(tr("EXTRACT_S8_LANE_ALERT")), "s02 HUD hides lane alert")
	flow.hold_remaining = 0.0
	flow.tick(0.25)
	flow.set_in_board_zone(true)
	hud.refresh()
	t.eq((hud.get_node("ObjectivePanel/Objective") as Label).text, tr("HUD_OBJECTIVE_BOARD_BOAT"), "s9 objective shown")
	t.ok((hud.get_node("ContextButton") as Button).text.contains(tr("EXTRACT_S9_BUTTON_BOARD")), "board action appears only at ready state")
	hud.queue_free()
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
	return ItemInstance.new(18, definition)
