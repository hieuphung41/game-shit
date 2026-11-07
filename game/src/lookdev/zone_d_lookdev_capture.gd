extends Node3D
## Captures the D greybox and the B-to-D route only for the look-dev gate.

const PHONE_WIDTH := 640
const PHONE_HEIGHT := 360
const PROBE_GROUP := &"zone_d_lookdev_probe"
const PROBE_SURFACE_OFFSET := 0.04
const TRIANGLE_EPSILON := 0.00001
const CAPTURE_CAMERA_OFFSET := Vector3(15.45, 13.05, 11.6)
const D_ENTRY_PATH := ^"DEntry"
const B_ROOT_OFFSET := Vector3(-4.75, 0.0, 34.5)
const B_CALM_ZONE_POSITION := Vector3(4.5, 0.95, -28.75)
const ZONE_B_SCENE := preload("res://src/world/zone_b_flooded_market.tscn")
const RETRIEVER_SCENE := preload("res://src/player/retriever.tscn")
const ENVIRONMENT := preload("res://art/env_default.tres")
const BACKGROUND_PROBE_PIXEL := Vector2(96.0, 96.0)

var _camera: Camera3D
var _zone_b: Node3D


func _ready() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-zone-d="):
			_prepare_capture_camera()
			call_deferred("_capture", argument.trim_prefix("--capture-zone-d="))
			return


func _prepare_capture_camera() -> void:
	var environment := WorldEnvironment.new()
	environment.environment = ENVIRONMENT
	add_child(environment)
	RenderingServer.set_default_clear_color(ENVIRONMENT.background_color)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -34.0, 0.0)
	sun.light_energy = 0.8
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70.0
	add_child(sun)
	_zone_b = ZONE_B_SCENE.instantiate() as Node3D
	_zone_b.position = B_ROOT_OFFSET
	add_child(_zone_b)
	_zone_b.call("set_route_d_open", false)
	_camera = Camera3D.new()
	_camera.name = "CameraIsometric"
	_camera.rotation_degrees = Vector3(-30.0, 45.0, 0.0)
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = 20.0
	_camera.near = 0.1
	_camera.far = 90.0
	_camera.current = true
	add_child(_camera)
	var entry := get_node_or_null(D_ENTRY_PATH) as Node3D
	if entry == null:
		push_error("Zone D look-dev capture requires DEntry")
		return
	_camera.global_position = entry.global_position + Vector3(0.0, 0.86, 0.0) + CAPTURE_CAMERA_OFFSET
	var retriever := RETRIEVER_SCENE.instantiate() as CharacterBody3D
	retriever.position = Vector3(0.0, 0.95, -1.0)
	add_child(retriever)


func _capture(capture_directory: String) -> void:
	if DirAccess.make_dir_recursive_absolute(capture_directory) != OK:
		push_error("Could not create Zone D capture directory: %s" % capture_directory)
		get_tree().quit(1)
		return
	await get_tree().process_frame
	await get_tree().process_frame
	RenderingServer.force_sync()
	var game_image := get_viewport().get_texture().get_image()
	if game_image == null:
		push_error("Zone D capture needs an active rendering viewport")
		get_tree().quit(1)
		return
	var result := game_image.save_png(capture_directory.path_join("zone_d_game.png"))
	if result == OK:
		result = _write_projected_probe(game_image, capture_directory)
	if result == OK:
		result = _grayscale(game_image).save_png(capture_directory.path_join("zone_d_gray.png"))
	if result == OK:
		var phone_image := game_image.duplicate()
		phone_image.resize(PHONE_WIDTH, PHONE_HEIGHT, Image.INTERPOLATE_NEAREST)
		result = phone_image.save_png(capture_directory.path_join("zone_d_phone.png"))
	if result == OK:
		result = await _capture_b_route_states(capture_directory)
	if result != OK:
		push_error("Could not save Zone D capture(s): %s" % error_string(result))
	get_tree().quit(0 if result == OK else 1)


func _capture_b_route_states(capture_directory: String) -> Error:
	if _zone_b == null:
		return ERR_DOES_NOT_EXIST
	_camera.size = 20.0
	_camera.global_position = _zone_b.global_position + B_CALM_ZONE_POSITION + CAPTURE_CAMERA_OFFSET
	_camera.make_current()
	_camera.force_update_transform()
	_zone_b.call("set_route_d_open", false)
	await get_tree().process_frame
	await get_tree().process_frame
	RenderingServer.force_sync()
	var closed_image := get_viewport().get_texture().get_image()
	if closed_image == null:
		return ERR_UNAVAILABLE
	var result := closed_image.save_png(capture_directory.path_join("zone_b_route_d_closed_game.png"))
	if result == OK:
		var closed_phone := closed_image.duplicate()
		closed_phone.resize(PHONE_WIDTH, PHONE_HEIGHT, Image.INTERPOLATE_NEAREST)
		result = closed_phone.save_png(capture_directory.path_join("zone_b_route_d_closed_phone.png"))
	if result != OK:
		return result
	_zone_b.call("set_route_d_open", true)
	await get_tree().process_frame
	await get_tree().process_frame
	RenderingServer.force_sync()
	var open_image := get_viewport().get_texture().get_image()
	if open_image == null:
		return ERR_UNAVAILABLE
	result = open_image.save_png(capture_directory.path_join("zone_b_route_d_open_game.png"))
	if result == OK:
		var open_phone := open_image.duplicate()
		open_phone.resize(PHONE_WIDTH, PHONE_HEIGHT, Image.INTERPOLATE_NEAREST)
		result = open_phone.save_png(capture_directory.path_join("zone_b_route_d_open_phone.png"))
	return result


func _write_projected_probe(image: Image, capture_directory: String) -> Error:
	var samples: Array[Dictionary] = []
	for node: Node in get_tree().get_nodes_in_group(PROBE_GROUP):
		var point := node as Marker3D
		if point == null:
			continue
		if str(point.get_meta("role", "")) == "background":
			point.global_position = _camera.project_position(BACKGROUND_PROBE_PIXEL, 30.0)
		var screen := _camera.unproject_position(point.global_position)
		var projected := not _camera.is_position_behind(point.global_position)
		projected = projected and screen.x >= 1.0 and screen.x < image.get_width() - 1.0
		projected = projected and screen.y >= 1.0 and screen.y < image.get_height() - 1.0
		var visible_surface := _probe_surface_is_visible(_camera, point) if projected else false
		var measured := Color.BLACK
		if projected and visible_surface:
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
	var output := FileAccess.open(capture_directory.path_join("zone_d_probe-raw.json"), FileAccess.WRITE)
	if output == null:
		push_error("Could not write Zone D probe samples")
		return ERR_CANT_CREATE
	output.store_string(JSON.stringify({"camera": _camera.name, "samples": samples}, "\t"))
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
	return _first_mesh_on_camera_ray(view_camera.global_position, ray / ray_length, ray_length + PROBE_SURFACE_OFFSET) == expected_surface


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
	var output := source.duplicate()
	for y: int in output.get_height():
		for x: int in output.get_width():
			var color: Color = output.get_pixel(x, y)
			var value: float = color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
			output.set_pixel(x, y, Color(value, value, value, color.a))
	return output
