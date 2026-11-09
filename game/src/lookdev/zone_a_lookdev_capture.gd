extends Node3D
## Captures the playable Zone A scene only when invoked by the look-dev gate.

const PHONE_WIDTH := 640
const PHONE_HEIGHT := 360
const PROBE_GROUP := &"zone_a_lookdev_probe"
const PROBE_SURFACE_OFFSET := 0.04
const TRIANGLE_EPSILON := 0.00001
const RETRIEVER_SCENE := preload("res://src/player/retriever.tscn")
const BACKGROUND_PROBE_PIXEL := Vector2(96.0, 96.0)

@onready var camera: Camera3D = $CameraIsometric
@onready var world_environment: WorldEnvironment = $WorldEnvironment


func _ready() -> void:
	# GL Compatibility needs the viewport clear colour set explicitly for a
	# palette-correct PNG behind the orthographic world.
	RenderingServer.set_default_clear_color(world_environment.environment.background_color)
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-zone-a="):
			var retriever := RETRIEVER_SCENE.instantiate() as CharacterBody3D
			add_child(retriever)
			call_deferred("_capture", argument.trim_prefix("--capture-zone-a="))
			return


func _capture(capture_directory: String) -> void:
	if DirAccess.make_dir_recursive_absolute(capture_directory) != OK:
		push_error("Could not create Zone A capture directory: %s" % capture_directory)
		get_tree().quit(1)
		return
	# The Retriever's _ready records its authored spawn-to-camera offset.  Wait
	# for it and for the first shadow map before sampling the play camera.
	await get_tree().process_frame
	await get_tree().process_frame
	RenderingServer.force_sync()
	for debug_point: Vector3 in [Vector3(-6.5, 0.095, -4.5), Vector3(-5.5, 0.095, -2.5), Vector3(-4.5, 0.095, -1.5), Vector3(-3.5, 0.095, -0.5), Vector3(-2.5, 0.095, 0.5), Vector3(-1.5, 0.095, 1.5), Vector3(-0.5, 0.095, 2.5), Vector3(0.5, 0.095, 3.5), Vector3(1.5, 0.095, 4.5)]:
		print("SWEEP %s -> %s" % [debug_point, camera.unproject_position(debug_point)])
	var game_image: Image = get_viewport().get_texture().get_image()
	for grid_x: int in range(-6, 7):
		for grid_z: int in range(-4, 5):
			var debug_probe := Marker3D.new()
			add_child(debug_probe)
			debug_probe.position = Vector3(float(grid_x) + 0.25, 0.095, float(grid_z) + 0.25)
			debug_probe.set_meta("surface_path", "PierDeck")
			if _probe_surface_is_visible(camera, debug_probe):
				var debug_screen := camera.unproject_position(debug_probe.global_position)
				var debug_colour := _sample_pixel_cross(game_image, Vector2i(roundi(debug_screen.x), roundi(debug_screen.y)))
				if debug_colour.to_html(false).to_upper().begins_with("2C31"):
					print("DARK DECK %s %s" % [debug_probe.position, debug_colour.to_html(false).to_upper()])
			debug_probe.queue_free()
	if game_image == null:
		push_error("Zone A capture needs an active rendering viewport")
		get_tree().quit(1)
		return
	var result := game_image.save_png(capture_directory.path_join("zone_a_game.png"))
	if result == OK:
		result = _write_projected_probe(game_image, capture_directory)
	if result == OK:
		result = _grayscale(game_image).save_png(capture_directory.path_join("zone_a_gray.png"))
	if result == OK:
		var phone_image: Image = game_image.duplicate()
		phone_image.resize(PHONE_WIDTH, PHONE_HEIGHT, Image.INTERPOLATE_NEAREST)
		result = phone_image.save_png(capture_directory.path_join("zone_a_phone.png"))
	if result != OK:
		push_error("Could not save Zone A capture(s): %s" % error_string(result))
	get_tree().quit(0 if result == OK else 1)


func _write_projected_probe(image: Image, capture_directory: String) -> Error:
	var samples: Array[Dictionary] = []
	for node: Node in get_tree().get_nodes_in_group(PROBE_GROUP):
		var point := node as Marker3D
		if point == null:
			continue
		if str(point.get_meta("role", "")) == "background":
			# Keep this named 3D probe in a clear portion of the actual game frame.
			# The position is calculated after the viewport has its capture resolution.
			point.global_position = camera.project_position(BACKGROUND_PROBE_PIXEL, 30.0)
		var screen := camera.unproject_position(point.global_position)
		var projected := not camera.is_position_behind(point.global_position)
		projected = projected and screen.x >= 1.0 and screen.x < image.get_width() - 1.0
		projected = projected and screen.y >= 1.0 and screen.y < image.get_height() - 1.0
		var visible_surface := _probe_surface_is_visible(camera, point) if projected else false
		var valid := projected and visible_surface
		var measured := Color.BLACK
		if valid:
			measured = _sample_pixel_cross(image, Vector2i(roundi(screen.x), roundi(screen.y)))
		samples.append({
			"name": point.name,
			"role": str(point.get_meta("role", "unknown")),
			"expected": _expected_probe_hex(point),
			"tolerance": float(point.get_meta("tolerance", 0.0)),
			"pixel": {"x": roundi(screen.x), "y": roundi(screen.y)},
			"measured": "#%s" % measured.to_html(false).to_upper(),
			"projected": projected,
			"occluded": projected and not visible_surface,
		})
	var output := FileAccess.open(capture_directory.path_join("zone_a_probe-raw.json"), FileAccess.WRITE)
	if output == null:
		push_error("Could not write Zone A probe samples")
		return ERR_CANT_CREATE
	output.store_string(JSON.stringify({"camera": camera.name, "samples": samples}, "\t"))
	output.close()
	return OK


func _expected_probe_hex(point: Marker3D) -> String:
	var declared := str(point.get_meta("expected_hex", ""))
	if not declared.is_empty():
		return declared
	var surface := get_node_or_null(NodePath(str(point.get_meta("surface_path", "")))) as MeshInstance3D
	var material := surface.material_override as ShaderMaterial if surface != null else null
	if material == null:
		return ""
	var shadow_colour := material.get_shader_parameter("shadow_indigo") as Color
	return "#%s" % shadow_colour.to_html(false).to_upper()


func _probe_surface_is_visible(view_camera: Camera3D, point: Marker3D) -> bool:
	if str(point.get_meta("role", "")) == "background":
		return true
	var expected_path := NodePath(str(point.get_meta("surface_path", "")))
	var expected_surface := get_node_or_null(expected_path) as MeshInstance3D
	if expected_surface == null:
		return false
	var ray := point.global_position - view_camera.global_position
	var ray_length := ray.length()
	if ray_length <= TRIANGLE_EPSILON:
		return false
	var hit_surface := _first_mesh_on_camera_ray(view_camera.global_position, ray / ray_length, ray_length + PROBE_SURFACE_OFFSET)
	return hit_surface == expected_surface


func _first_mesh_on_camera_ray(origin: Vector3, direction: Vector3, maximum_distance: float) -> MeshInstance3D:
	var closest_surface: MeshInstance3D = null
	var closest_distance := maximum_distance
	for node: Node in find_children("*", "MeshInstance3D", true, false):
		var surface := node as MeshInstance3D
		if surface == null or surface.mesh == null:
			continue
		var faces := surface.mesh.get_faces()
		for index: int in range(0, faces.size(), 3):
			var distance := _ray_triangle_distance(origin, direction, surface.global_transform * faces[index], surface.global_transform * faces[index + 1], surface.global_transform * faces[index + 2])
			if distance >= 0.0 and distance < closest_distance:
				closest_distance = distance
				closest_surface = surface
	return closest_surface


func _ray_triangle_distance(origin: Vector3, direction: Vector3, first: Vector3, second: Vector3, third: Vector3) -> float:
	var edge_a := second - first
	var edge_b := third - first
	var perpendicular := direction.cross(edge_b)
	var determinant := edge_a.dot(perpendicular)
	if absf(determinant) <= TRIANGLE_EPSILON:
		return -1.0
	var inverse_determinant := 1.0 / determinant
	var from_first := origin - first
	var u := from_first.dot(perpendicular) * inverse_determinant
	if u < 0.0 or u > 1.0:
		return -1.0
	var cross_edge := from_first.cross(edge_a)
	var v := direction.dot(cross_edge) * inverse_determinant
	if v < 0.0 or u + v > 1.0:
		return -1.0
	var distance := edge_b.dot(cross_edge) * inverse_determinant
	return distance if distance >= TRIANGLE_EPSILON else -1.0


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
