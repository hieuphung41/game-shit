extends Node
## Captures the playable in-run HUD at the requested window size for review.

const OUTER_PIER_RUN_SCENE := preload("res://src/flow/outer_pier_run.tscn")

var _capture_directory := ""
var _capture_size := Vector2i.ZERO


func _ready() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-ui-hud="):
			_capture_directory = argument.trim_prefix("--capture-ui-hud=")
		elif argument.begins_with("--capture-ui-size="):
			_capture_size = _parse_size(argument.trim_prefix("--capture-ui-size="))
	if _capture_directory.is_empty() or _capture_size == Vector2i.ZERO:
		push_error("HUD capture requires --capture-ui-hud=DIR and --capture-ui-size=WIDTHxHEIGHT")
		get_tree().quit(1)
		return
	var capture_viewport := SubViewport.new()
	capture_viewport.name = "HudCaptureViewport"
	capture_viewport.size = _capture_size
	capture_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	capture_viewport.transparent_bg = false
	add_child(capture_viewport)
	var run := OUTER_PIER_RUN_SCENE.instantiate() as OuterPierRun
	capture_viewport.add_child(run)
	call_deferred("_capture_states", capture_viewport, run)


func _capture_states(capture_viewport: SubViewport, run: OuterPierRun) -> void:
	for _frame in 4:
		await get_tree().process_frame
	run.set_dispatch_in_range(true)
	await _capture(capture_viewport, &"")

	var inventory := RunSession.inventory
	var manifest := _manifest(inventory)
	if not inventory.commit_pickup(manifest, RetrieverInventory.BACKPACK, Vector2i.ZERO, false).ok:
		push_error("HUD capture could not put Manifest in the backpack")
		get_tree().quit(1)
		return
	run.set_beacon_in_range(true)
	if not run.flow.request_call() or not run.flow.confirm_call():
		push_error("HUD capture could not enter S7")
		get_tree().quit(1)
		return
	await _capture(capture_viewport, &"s7")
	for _tick in 6:
		run.flow.tick(0.25)
	await _capture(capture_viewport, &"s8")
	run.set_beacon_in_range(false)
	await _capture(capture_viewport, &"s8_paused")
	run.set_beacon_in_range(true)
	run.flow.hold_remaining = 0.0
	run.flow.tick(0.25)
	run.set_board_in_range(true)
	await _capture(capture_viewport, &"s9")

	run._open_inventory_view()
	_verify_inventory_overlay_capture(run)
	# The playable run refreshes danger from active enemies every frame. Freeze
	# only this deterministic look-dev fixture after its overlay is open so the
	# requested windup state remains visible for the rendered capture.
	run.set_process(false)
	run._combat_hud.set_danger_near(true, true)
	_verify_danger_capture(run._combat_hud)
	await _capture(capture_viewport, &"danger")
	run._combat_hud.set_danger_near(false)
	run.set_process(true)
	run._close_overlay()
	run._combat_hud.health.damage(70)
	run._combat_hud.show_warning(&"HUD_ALERT_PATROL_B")
	run._combat_hud.show_status(&"COMBAT_REMEDY_REFUSED_HP_FULL")
	await _capture(capture_viewport, &"warning_status_low_health")
	run._hud.show_prompt(&"PROMPT_ROUTE_EXTRACT_NOW")
	await _capture(capture_viewport, &"prompt")
	run._hud.clear_prompt()
	run._open_inventory_view()
	_verify_inventory_overlay_capture(run)
	await _capture(capture_viewport, &"inventory_overlay")
	run._close_overlay()
	run._hud.visible = false
	run._combat_hud.show_depleted()
	await _capture(capture_viewport, &"depleted")
	get_tree().quit(0)


func _capture(capture_viewport: SubViewport, state_name: StringName) -> void:
	await get_tree().process_frame
	RenderingServer.force_sync()
	var image := capture_viewport.get_texture().get_image()
	if image == null:
		push_error("HUD capture needs an active viewport")
		get_tree().quit(1)
		return
	if DirAccess.make_dir_recursive_absolute(_capture_directory) != OK:
		push_error("Could not create HUD capture directory: %s" % _capture_directory)
		get_tree().quit(1)
		return
	var filename := "ui_hud_%dx%d.png" % [_capture_size.x, _capture_size.y] if state_name.is_empty() else "ui_hud_%s_%dx%d.png" % [state_name, _capture_size.x, _capture_size.y]
	var output := _capture_directory.path_join(filename)
	var result := image.save_png(output)
	if result != OK:
		push_error("Could not write HUD capture: %s" % error_string(result))
		get_tree().quit(1)


func _verify_danger_capture(combat_hud: CombatHud) -> void:
	var danger := combat_hud.get_node_or_null("DangerClose") as Button
	var expected := "▲ " + tr("HUD_DANGER_WINDUP") + "\n" + tr("HUD_DANGER_CLOSE_HINT")
	if danger == null or not danger.visible or danger.text != expected:
		push_error("HUD danger capture requires the visible windup close control with its full text")
		get_tree().quit(1)
	if not combat_hud.danger_text_fits():
		push_error("HUD danger capture requires the complete two-line instruction to fit its visible control")
		get_tree().quit(1)


func _verify_inventory_overlay_capture(run: OuterPierRun) -> void:
	if not run._overlay is LootCachePanel or run._overlay.get_parent() != run._overlay_layer or run._overlay_layer.layer != 20:
		push_error("HUD inventory capture requires the production LootCachePanel on OverlayLayer 20")
		get_tree().quit(1)


func _manifest(inventory: RetrieverInventory) -> ItemInstance:
	var definition := ItemDef.new()
	definition.id = &"manifest_r17"
	definition.display_name_key = &"CARD_MANIFEST_R17_NAME"
	definition.size = Vector2i.ONE
	definition.sealable = true
	definition.item_category = ItemDef.Category.EVIDENCE
	inventory.registry.add(definition)
	return ItemInstance.new(9001, definition)


func _parse_size(value: String) -> Vector2i:
	var parts := value.split("x", false)
	if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
		return Vector2i.ZERO
	var width := parts[0].to_int()
	var height := parts[1].to_int()
	return Vector2i(width, height) if width > 0 and height > 0 else Vector2i.ZERO
