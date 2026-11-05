extends Node3D
## Writes deterministic review captures only when --capture-dir=<absolute path> is supplied.

const PHONE_WIDTH := 640
const PHONE_HEIGHT := 360
const PROBE_GROUP := &"lookdev_probe"

@onready var detail_camera: Camera3D = $DetailCamera3D
@onready var world_environment: WorldEnvironment = $WorldEnvironment


func _ready() -> void:
	# GL Compatibility's clear target is the reliable background behind the
	# orthographic look-dev scene.  Keep its value in env_default.tres so the
	# resource remains the single declared source for sea_bluegrey.
	RenderingServer.set_default_clear_color(world_environment.environment.background_color)
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			call_deferred("_capture", argument.trim_prefix("--capture-dir="))
			return


func _capture(capture_directory: String) -> void:
	if DirAccess.make_dir_recursive_absolute(capture_directory) != OK:
		push_error("Could not create look-dev capture directory: %s" % capture_directory)
		get_tree().quit(1)
		return
	await get_tree().process_frame
	await get_tree().process_frame
	RenderingServer.force_sync()
	var game_image: Image = get_viewport().get_texture().get_image()
	if game_image == null:
		push_error("Look-dev capture needs an active rendering viewport")
		get_tree().quit(1)
		return
	var game_path := capture_directory.path_join("lookdev_game.png")
	var gray_path := capture_directory.path_join("lookdev_gray.png")
	var phone_path := capture_directory.path_join("lookdev_phone.png")
	var detail_path := capture_directory.path_join("lookdev_detail.png")
	var result := game_image.save_png(game_path)
	if result == OK:
		result = _write_projected_probe(game_image, capture_directory)
	if result == OK:
		var gray_image := _grayscale(game_image)
		result = gray_image.save_png(gray_path)
	if result == OK:
		var phone_image: Image = game_image.duplicate()
		phone_image.resize(PHONE_WIDTH, PHONE_HEIGHT, Image.INTERPOLATE_NEAREST)
		result = phone_image.save_png(phone_path)
	if result == OK:
		detail_camera.make_current()
		await get_tree().process_frame
		await get_tree().process_frame
		RenderingServer.force_sync()
		var detail_image: Image = get_viewport().get_texture().get_image()
		if detail_image == null:
			result = ERR_CANT_ACQUIRE_RESOURCE
		else:
			result = detail_image.save_png(detail_path)
	if result != OK:
		push_error("Could not save look-dev capture(s): %s" % error_string(result))
	get_tree().quit(0 if result == OK else 1)


func _write_projected_probe(image: Image, capture_directory: String) -> Error:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		push_error("Look-dev probe needs the game camera")
		return ERR_CANT_ACQUIRE_RESOURCE
	var samples: Array[Dictionary] = []
	var failed_projection := false
	for node: Node in get_tree().get_nodes_in_group(PROBE_GROUP):
		var point := node as Marker3D
		if point == null:
			continue
		var screen := camera.unproject_position(point.global_position)
		var valid := not camera.is_position_behind(point.global_position)
		valid = valid and screen.x >= 1.0 and screen.x < image.get_width() - 1.0
		valid = valid and screen.y >= 1.0 and screen.y < image.get_height() - 1.0
		var measured := Color.BLACK
		if valid:
			measured = _sample_pixel_cross(image, Vector2i(roundi(screen.x), roundi(screen.y)))
		else:
			failed_projection = true
		samples.append({
			"name": point.name,
			"role": str(point.get_meta("role", "unknown")),
			"expected": str(point.get_meta("expected_hex", "")),
			"tolerance": float(point.get_meta("tolerance", 0.0)),
			"pixel": {"x": roundi(screen.x), "y": roundi(screen.y)},
			"measured": "#%s" % measured.to_html(false).to_upper(),
			"projected": valid,
		})
	var payload := {"camera": camera.name, "samples": samples}
	var output := FileAccess.open(capture_directory.path_join("probe-raw.json"), FileAccess.WRITE)
	if output == null:
		push_error("Could not write look-dev probe samples")
		return ERR_CANT_CREATE
	output.store_string(JSON.stringify(payload, "\t"))
	output.close()
	return ERR_CANT_ACQUIRE_RESOURCE if failed_projection else OK


func _sample_pixel_cross(image: Image, center: Vector2i) -> Color:
	var total := Color.BLACK
	for offset: Vector2i in [Vector2i.ZERO, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		total += image.get_pixelv(center + offset)
	return total / 5.0


func _grayscale(source: Image) -> Image:
	var output: Image = source.duplicate()
	for y: int in output.get_height():
		for x: int in output.get_width():
			var color := output.get_pixel(x, y)
			var value := color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
			output.set_pixel(x, y, Color(value, value, value, color.a))
	return output
