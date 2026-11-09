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
	call_deferred("_capture", capture_viewport, run)


func _capture(capture_viewport: SubViewport, run: OuterPierRun) -> void:
	for _frame in 4:
		await get_tree().process_frame
	run.set_dispatch_in_range(true)
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
	var output := _capture_directory.path_join("ui_hud_%dx%d.png" % [_capture_size.x, _capture_size.y])
	var result := image.save_png(output)
	if result != OK:
		push_error("Could not write HUD capture: %s" % error_string(result))
	get_tree().quit(0 if result == OK else 1)


func _parse_size(value: String) -> Vector2i:
	var parts := value.split("x", false)
	if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
		return Vector2i.ZERO
	var width := parts[0].to_int()
	var height := parts[1].to_int()
	return Vector2i(width, height) if width > 0 and height > 0 else Vector2i.ZERO
