extends RefCounted

const EXTRACT_HUD_SCENE := preload("res://src/ui/hud/extract_hud.tscn")
const COMBAT_HUD_SCENE := preload("res://src/ui/combat/combat_hud.tscn")
const OUTER_PIER_RUN_SCENE := preload("res://src/flow/outer_pier_run.tscn")
const SUPPORTED_SIZES: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(2400, 1080), Vector2i(1024, 768)]


func test_ui_hud_safe_area_uses_display_bounds_or_the_inset_fallback(t) -> bool:
	var viewport_size := Vector2(1280, 720)
	var window_rect := Rect2(Vector2.ZERO, viewport_size)
	t.eq(HudLayout.safe_rect_from_display(viewport_size, window_rect, Rect2()), HudLayout.fallback_safe_rect(viewport_size), "no reported display safe area uses the configured fallback inset")
	var platform_safe := HudLayout.safe_rect_from_display(viewport_size, window_rect, Rect2(Vector2(24, 0), Vector2(1232, 720)))
	t.eq(platform_safe, Rect2(Vector2(40, 16), Vector2(1200, 688)), "reported display safe area is inset in canvas coordinates")
	return true


func test_ui_hud_all_visible_states_stay_safe_and_non_overlapping_at_supported_aspect_ratios(t) -> bool:
	for size: Vector2i in SUPPORTED_SIZES:
		await _assert_all_hud_states(t, size)
	return true


func test_ui_hud_inventory_overlay_uses_the_production_overlay_layer_at_supported_aspect_ratios(t) -> bool:
	for size: Vector2i in SUPPORTED_SIZES:
		await _assert_production_inventory_overlay(t, size)
	return true


func test_ui_hud_beacon_panel_encloses_its_label_after_4_by_3_layout_settles(t) -> bool:
	var fixture := await _make_fixture(t, Vector2i(1024, 768))
	var extract_hud := fixture["extract"] as ExtractHud
	var beacon_panel := extract_hud.get_node("BeaconPanel") as Panel
	var beacon := extract_hud.get_node("BeaconPanel/BeaconMargins/Beacon") as Label
	t.ok(beacon_panel.visible and beacon.is_visible_in_tree(), "E0 beacon composition is visible after the 4:3 layout settles")
	t.ok(beacon_panel.get_global_rect().encloses(beacon.get_global_rect()), "settled 4:3 beacon label remains enclosed by its visible panel: panel=%s label=%s" % [beacon_panel.get_global_rect(), beacon.get_global_rect()])
	t.ok(not beacon.text.is_empty(), "a visible beacon panel always has visible content")
	await _free_fixture(t, fixture)
	return true


func _assert_all_hud_states(t, size: Vector2i) -> void:
	var fixture := await _make_fixture(t, size)
	var extract_hud := fixture["extract"] as ExtractHud
	var combat_hud := fixture["combat"] as CombatHud
	var flow := fixture["flow"] as ExtractPierAFlow
	var inventory := fixture["inventory"] as RetrieverInventory

	extract_hud.set_desk_in_range(true)
	_assert_visible_controls(t, size, &"e0_dispatch", extract_hud, combat_hud)
	_assert_beacon_composition(t, size, extract_hud)

	_carry_manifest(t, inventory)
	flow.set_in_beacon_zone(true)
	t.ok(flow.request_call() and flow.confirm_call(), "S7 setup confirms the real call state at %s" % size)
	await t.tree.process_frame
	_assert_visible_controls(t, size, &"s7", extract_hud, combat_hud)

	for _tick in 6:
		flow.tick(0.25)
	await t.tree.process_frame
	_assert_visible_controls(t, size, &"s8_hold", extract_hud, combat_hud)

	flow.set_in_beacon_zone(false)
	await t.tree.process_frame
	_assert_visible_controls(t, size, &"s8_paused", extract_hud, combat_hud)
	_assert_paused_banner_text_fits(t, size, extract_hud)

	flow.set_in_beacon_zone(true)
	flow.hold_remaining = 0.0
	flow.tick(0.25)
	flow.set_in_board_zone(true)
	await t.tree.process_frame
	_assert_visible_controls(t, size, &"s9_board", extract_hud, combat_hud)

	extract_hud.set_overlay_open(true)
	combat_hud.set_overlay_open(true)
	combat_hud.set_danger_near(true, true)
	await t.tree.process_frame
	var danger := combat_hud.get_node("DangerClose") as Button
	t.ok(danger.visible, "danger close is visible while an overlay is open at %s" % size)
	t.eq(danger.text, "▲ " + tr("HUD_DANGER_WINDUP") + "\n" + tr("HUD_DANGER_CLOSE_HINT"), "danger close shows the full windup instruction at %s" % size)
	t.ok(danger.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART and not danger.clip_text and combat_hud.danger_text_fits(), "danger close renders both instruction lines without clipping at %s: rect=%s" % [size, danger.get_global_rect()])
	t.ok(not (extract_hud.get_node("InventoryButton") as Button).visible, "inventory trigger hides while its overlay is open at %s" % size)
	_assert_visible_controls(t, size, &"danger_overlay", extract_hud, combat_hud)

	combat_hud.set_danger_near(false)
	extract_hud.set_overlay_open(false)
	combat_hud.set_overlay_open(false)
	await t.tree.process_frame
	t.ok((extract_hud.get_node("InventoryButton") as Button).visible, "inventory trigger restores after its overlay closes at %s" % size)
	_assert_visible_controls(t, size, &"overlay_closed", extract_hud, combat_hud)

	combat_hud.health.damage(70)
	combat_hud.show_warning(&"HUD_ALERT_PATROL_B")
	combat_hud.show_status(&"COMBAT_REMEDY_REFUSED_HP_FULL")
	await t.tree.process_frame
	_assert_visible_controls(t, size, &"low_health_warning_status", extract_hud, combat_hud)

	extract_hud.show_prompt(&"PROMPT_ROUTE_EXTRACT_NOW")
	await t.tree.process_frame
	_assert_visible_controls(t, size, &"prompt", extract_hud, combat_hud)
	extract_hud.clear_prompt()

	extract_hud.visible = false
	combat_hud.show_depleted()
	await t.tree.process_frame
	var boot := combat_hud.get_node("DepletedStub/BootButton") as Button
	t.ok(boot.visible and combat_hud.stub_button_has_rendered_label(), "depleted wait control is visible and has a readable rendered label at %s: text=%s rect=%s" % [size, boot.text, boot.get_global_rect()])
	_assert_visible_controls(t, size, &"depleted", extract_hud, combat_hud)

	await _free_fixture(t, fixture)


func _make_fixture(t, size: Vector2i) -> Dictionary:
	var viewport := SubViewport.new()
	viewport.name = "HudLayoutViewport"
	viewport.size = size
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	t.tree.root.add_child(viewport)
	var inventory := StarterInventoryFactory.create()
	var flow := ExtractPierAFlow.new()
	flow.setup(inventory)
	var extract_hud := EXTRACT_HUD_SCENE.instantiate() as ExtractHud
	var combat_hud := COMBAT_HUD_SCENE.instantiate() as CombatHud
	extract_hud.set_flow(flow)
	combat_hud.set_combat(RetrieverCombat.new(null, inventory))
	viewport.add_child(extract_hud)
	viewport.add_child(combat_hud)
	await t.tree.process_frame
	await t.tree.process_frame
	return {"viewport": viewport, "inventory": inventory, "flow": flow, "extract": extract_hud, "combat": combat_hud}


func _free_fixture(t, fixture: Dictionary) -> void:
	var viewport := fixture["viewport"] as SubViewport
	if viewport != null:
		viewport.queue_free()
	RunSession.clear()
	await t.tree.process_frame


func _assert_production_inventory_overlay(t, size: Vector2i) -> void:
	RunSession.clear()
	var viewport := SubViewport.new()
	viewport.name = "HudInventoryOverlayViewport"
	viewport.size = size
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	t.tree.root.add_child(viewport)
	var run := OUTER_PIER_RUN_SCENE.instantiate() as OuterPierRun
	viewport.add_child(run)
	await t.tree.process_frame
	await t.tree.process_frame
	run._open_inventory_view()
	await t.tree.process_frame
	var overlay := run._overlay as LootCachePanel
	t.ok(overlay != null and overlay.session == LootCachePanel.Session.VIEW, "inventory opens the production LootCachePanel view at %s" % size)
	t.ok(overlay != null and overlay.get_parent() == run._overlay_layer and run._overlay_layer.layer == 20, "inventory panel is on OverlayLayer 20 above the HUD at %s" % size)
	t.ok(not (run._hud.get_node("InventoryButton") as Button).visible, "HUD inventory trigger hides below the opened production overlay at %s" % size)
	run.set_process(false)
	run._combat_hud.set_danger_near(true, true)
	await t.tree.process_frame
	var danger := run._combat_hud.get_node("DangerClose") as Button
	t.ok(danger.visible and run._combat_hud.danger_text_fits(), "production inventory overlay retains the readable danger escape at %s" % size)
	t.ok(run._overlay_layer.layer > run._hud_layer.layer, "inventory overlay renders above the HUD layer at %s" % size)
	_assert_inventory_overlay_controls(t, size, run, overlay)
	run.set_process(true)
	viewport.queue_free()
	RunSession.clear()
	await t.tree.process_frame


func _carry_manifest(t, inventory: RetrieverInventory) -> void:
	var definition := ItemDef.new()
	definition.id = &"manifest_r17"
	definition.display_name_key = &"CARD_MANIFEST_R17_NAME"
	definition.size = Vector2i.ONE
	definition.sealable = true
	definition.item_category = ItemDef.Category.EVIDENCE
	inventory.registry.add(definition)
	var pickup := inventory.commit_pickup(ItemInstance.new(9001, definition), RetrieverInventory.BACKPACK, Vector2i.ZERO, false)
	t.ok(pickup.ok, "manifest setup uses the public inventory pickup API")


func _assert_beacon_composition(t, size: Vector2i, extract_hud: ExtractHud) -> void:
	var beacon_panel := extract_hud.get_node("BeaconPanel") as Panel
	var beacon := extract_hud.get_node("BeaconPanel/BeaconMargins/Beacon") as Label
	t.ok(beacon_panel.visible and beacon.is_visible_in_tree(), "beacon state is visible at %s" % size)
	t.ok(beacon_panel.get_global_rect().encloses(beacon.get_global_rect()), "beacon label stays inside its panel at %s: panel=%s label=%s" % [size, beacon_panel.get_global_rect(), beacon.get_global_rect()])
	t.ok(not beacon.text.is_empty(), "visible beacon panel has text at %s" % size)


func _assert_paused_banner_text_fits(t, size: Vector2i, extract_hud: ExtractHud) -> void:
	var banner_panel := extract_hud.get_node("BannerPanel") as Panel
	var banner := extract_hud.get_node("BannerPanel/Banner") as Label
	t.ok(banner_panel.visible and banner.is_visible_in_tree(), "paused S8 banner is visible at %s" % size)
	t.ok(banner.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART and not banner.clip_text, "paused S8 banner wraps instead of clipping at %s" % size)
	t.ok(banner_panel.get_global_rect().encloses(banner.get_global_rect()), "paused S8 banner panel encloses its text at %s: panel=%s banner=%s" % [size, banner_panel.get_global_rect(), banner.get_global_rect()])
	t.ok(extract_hud.banner_text_fits(), "paused S8 banner has room for every rendered line at %s: lines=%d height=%.1f" % [size, banner.get_line_count(), banner.size.y])


func _assert_visible_controls(t, size: Vector2i, state_name: StringName, extract_hud: ExtractHud, combat_hud: CombatHud) -> void:
	_assert_visible_controls_for_roots(t, size, state_name, [extract_hud, combat_hud])
	var inventory_button := extract_hud.get_node("InventoryButton") as Button
	if inventory_button.is_visible_in_tree():
		var font := inventory_button.get_theme_font("font")
		var font_size := inventory_button.get_theme_font_size("font_size")
		var text_width := font.get_string_size(inventory_button.text, HORIZONTAL_ALIGNMENT_CENTER, -1.0, font_size).x
		t.ok(not inventory_button.clip_text and text_width <= inventory_button.size.x - 24.0, "inventory label fits without clipping for %s at %s: text=%.1f button=%.1f" % [state_name, size, text_width, inventory_button.size.x])


func _assert_visible_controls_for_roots(t, size: Vector2i, state_name: StringName, roots: Array[Control]) -> void:
	var controls := _visible_leaves(roots)
	var safe := HudLayout.safe_rect(roots[0])
	for name: String in controls:
		var rect := controls[name] as Rect2
		t.ok(safe.encloses(rect), "%s stays in the safe area for %s at %s: safe=%s rect=%s" % [name, state_name, size, safe, rect])
	for first: String in controls:
		for second: String in controls:
			if first >= second:
				continue
			t.ok(not (controls[first] as Rect2).intersects(controls[second] as Rect2), "%s and %s do not overlap for %s at %s: %s / %s" % [first, second, state_name, size, controls[first], controls[second]])
	if size == Vector2i(1280, 720):
		for button: Button in _visible_buttons(roots):
			t.ok(minf(button.get_global_rect().size.x, button.get_global_rect().size.y) >= 64.0, "%s keeps the 64 px touch floor for %s" % [button.name, state_name])


func _visible_leaves(roots: Array[Control]) -> Dictionary:
	var leaves := {}
	for root: Control in roots:
		if root == null:
			continue
		for node: Node in _descendants(root):
			if node is Label or node is Button:
				var control := node as Control
				if control.is_visible_in_tree():
					leaves["%s/%s" % [root.name, control.get_path()]] = control.get_global_rect()
	return leaves


func _visible_buttons(roots: Array[Control]) -> Array[Button]:
	var buttons: Array[Button] = []
	for root: Control in roots:
		if root == null:
			continue
		for node: Node in _descendants(root):
			if node is Button and (node as Control).is_visible_in_tree():
				buttons.append(node as Button)
	return buttons


func _assert_inventory_overlay_controls(t, size: Vector2i, run: OuterPierRun, overlay: LootCachePanel) -> void:
	var safe := HudLayout.safe_rect(run._combat_hud)
	var controls: Array[Control] = [
		run._combat_hud.get_node("DangerClose") as Button,
		overlay.get_node("CloseButton") as Button,
		overlay.get_node("LootGridPanel/Source") as Label,
		overlay.get_node("LootGridPanel/HeldItem") as Label,
		overlay.get_node("LootGridPanel/Status") as Label,
		overlay.get_node("LootGridPanel/BackpackLabel") as Label,
		overlay.get_node("LootGridPanel/NotaryBoxLabel") as Label,
		overlay.get_node("LootGridPanel/SlingPouch") as Label,
		overlay.get_node("LootGridPanel/SlingPouchCue") as Label,
		overlay.get_node("LootGridPanel/SlingPouchItem") as Label,
	]
	for control: Control in controls:
		if control != null and control.is_visible_in_tree():
			t.ok(safe.encloses(control.get_global_rect()), "%s stays in the safe area for the production inventory overlay at %s: safe=%s rect=%s" % [control.name, size, safe, control.get_global_rect()])
	for first: Control in controls:
		for second: Control in controls:
			if first == null or second == null or first == second or not first.is_visible_in_tree() or not second.is_visible_in_tree() or String(first.get_path()) >= String(second.get_path()):
				continue
			t.ok(not first.get_global_rect().intersects(second.get_global_rect()), "%s and %s do not overlap in the production inventory overlay at %s" % [first.name, second.name, size])


func _descendants(root: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child: Node in root.get_children():
		result.append(child)
		result.append_array(_descendants(child))
	return result
