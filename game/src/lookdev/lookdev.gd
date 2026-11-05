extends Node3D
## Writes deterministic review captures only when --capture-dir=<absolute path> is supplied.

const PHONE_WIDTH := 640
const PHONE_HEIGHT := 360

@onready var detail_camera: Camera3D = $DetailCamera3D


func _ready() -> void:
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


func _grayscale(source: Image) -> Image:
	var output: Image = source.duplicate()
	for y: int in output.get_height():
		for x: int in output.get_width():
			var color := output.get_pixel(x, y)
			var value := color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
			output.set_pixel(x, y, Color(value, value, value, color.a))
	return output
