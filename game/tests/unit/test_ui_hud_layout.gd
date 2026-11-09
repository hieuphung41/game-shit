extends RefCounted

const EXTRACT_HUD_SCENE := preload("res://src/ui/hud/extract_hud.tscn")
const COMBAT_HUD_SCENE := preload("res://src/ui/combat/combat_hud.tscn")
const OUTER_PIER_RUN_SCENE := preload("res://src/flow/outer_pier_run.tscn")


func test_ui_hud_safe_area_uses_display_bounds_or_the_inset_fallback(t) -> bool:
	var viewport_size := Vector2(1280, 720)
	var window_rect := Rect2(Vector2.ZERO, viewport_size)
	t.eq(HudLayout.safe_rect_from_display(viewport_size, window_rect, Rect2()), HudLayout.fallback_safe_rect(viewport_size), "no reported display safe area uses the configured fallback inset")
	var platform_safe := HudLayout.safe_rect_from_display(viewport_size, window_rect, Rect2(Vector2(24, 0), Vector2(1232, 720)))
	t.eq(platform_safe, Rect2(Vector2(40, 16), Vector2(1200, 688)), "reported display safe area is inset in canvas coordinates")
	return true


func test_ui_hud_composition_stays_safe_and_non_overlapping_at_supported_aspect_ratios(t) -> bool:
	for size: Vector2i in [Vector2i(1280, 720), Vector2i(2400, 1080), Vector2i(1024, 768)]:
		await _assert_composed_hud_layout(t, size)
	return true


func test_ui_hud_scene_has_one_visible_objective_and_no_empty_banner(t) -> bool:
	var inventory := StarterInventoryFactory.create()
	var flow := ExtractPierAFlow.new()
	flow.setup(inventory)
	var extract_hud := EXTRACT_HUD_SCENE.instantiate() as ExtractHud
	var combat_hud := COMBAT_HUD_SCENE.instantiate() as CombatHud
	combat_hud.set_combat(RetrieverCombat.new(null, inventory))
	extract_hud.set_flow(flow)
	t.tree.root.add_child(extract_hud)
	t.tree.root.add_child(combat_hud)
	await t.tree.process_frame
	t.ok(not (extract_hud.get_node("ObjectivePanel") as Panel).visible, "ExtractHud keeps its compatibility objective projection hidden")
	t.ok((combat_hud.get_node("Objective") as Label).visible, "CombatHud is the sole visible objective source")
	t.ok(not (extract_hud.get_node("BannerPanel") as Panel).visible, "empty extract banner has no panel")
	t.ok((extract_hud.get_node("BeaconPanel") as Panel).visible, "beacon panel appears only with an E0 state label")
	extract_hud.queue_free()
	combat_hud.queue_free()
	await t.tree.process_frame
	return true


func _assert_composed_hud_layout(t, size: Vector2i) -> void:
	RunSession.begin_briefing()
	var viewport := SubViewport.new()
	viewport.name = "HudLayoutViewport"
	viewport.size = size
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	t.tree.root.add_child(viewport)
	var run := OUTER_PIER_RUN_SCENE.instantiate() as OuterPierRun
	viewport.add_child(run)
	await t.tree.process_frame
	await t.tree.process_frame
	run.set_dispatch_in_range(true)
	await t.tree.process_frame
	var extract_hud := run._hud
	var combat_hud := run._combat_hud
	t.ok(extract_hud != null and combat_hud != null, "OuterPierRun composes both HUDs at %s" % size)
	if extract_hud != null and combat_hud != null:
		var beacon_panel := extract_hud.get_node("BeaconPanel") as Panel
		var beacon := extract_hud.get_node("BeaconPanel/Beacon") as Label
		t.ok(beacon_panel.visible and beacon.is_visible_in_tree(), "beacon state is visible at %s" % size)
		t.ok(beacon_panel.get_global_rect().encloses(beacon.get_global_rect()), "beacon label stays inside its panel at %s: panel=%s label=%s" % [size, beacon_panel.get_global_rect(), beacon.get_global_rect()])
		_assert_visible_controls(t, size, extract_hud, combat_hud)
		if size == Vector2i(1280, 720):
			for button: Button in _visible_buttons(extract_hud, combat_hud):
				t.ok(minf(button.get_global_rect().size.x, button.get_global_rect().size.y) >= 64.0, "%s keeps the 64 px touch floor" % button.name)
	viewport.queue_free()
	RunSession.clear()
	await t.tree.process_frame


func _assert_visible_controls(t, size: Vector2i, extract_hud: ExtractHud, combat_hud: CombatHud) -> void:
	var controls := _visible_leaves(extract_hud, combat_hud)
	var safe := HudLayout.safe_rect(extract_hud)
	for name: String in controls:
		var rect := controls[name] as Rect2
		t.ok(safe.encloses(rect), "%s stays in the safe area at %s: safe=%s rect=%s" % [name, size, safe, rect])
	for first: String in controls:
		for second: String in controls:
			if first >= second:
				continue
			t.ok(not (controls[first] as Rect2).intersects(controls[second] as Rect2), "%s and %s do not overlap at %s: %s / %s" % [first, second, size, controls[first], controls[second]])


func _visible_leaves(extract_hud: ExtractHud, combat_hud: CombatHud) -> Dictionary:
	var leaves := {}
	for root: Control in [extract_hud, combat_hud]:
		for node: Node in _descendants(root):
			if node is Label or node is Button:
				var control := node as Control
				if control.is_visible_in_tree():
					leaves["%s/%s" % [root.name, control.get_path()]] = control.get_global_rect()
	return leaves


func _visible_buttons(extract_hud: ExtractHud, combat_hud: CombatHud) -> Array[Button]:
	var buttons: Array[Button] = []
	for root: Control in [extract_hud, combat_hud]:
		for node: Node in _descendants(root):
			if node is Button and (node as Control).is_visible_in_tree():
				buttons.append(node as Button)
	return buttons


func _descendants(root: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child: Node in root.get_children():
		result.append(child)
		result.append_array(_descendants(child))
	return result
