extends RefCounted

const SCENE_PATH := "res://src/world/zone_a_outer_pier.tscn"


func test_zone_a_outer_pier_loads_with_fixed_isometric_camera(t) -> bool:
	var scene := load(SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Zone A outer-pier greybox scene loads"):
		return true
	var world := scene.instantiate()
	t.tree.root.add_child(world)
	await t.tree.process_frame
	var camera := world.get_node_or_null("CameraIsometric") as Camera3D
	t.ok(camera != null, "Zone A has the named fixed isometric camera")
	if camera != null:
		t.eq(camera.projection, Camera3D.PROJECTION_ORTHOGONAL, "Zone A camera is orthographic")
		t.eq(roundi(camera.rotation_degrees.x), -30, "Zone A camera pitch remains -30 degrees")
		t.eq(roundi(camera.rotation_degrees.y), 45, "Zone A camera yaw remains 45 degrees")
		t.eq(camera.size, 20.0, "Zone A camera keeps the documented 20 metre frame")
		t.eq(camera.get_meta("camera_mode"), "fixed_isometric_no_free_rotation", "Zone A camera documents no free rotation")
		for node_path: String in ["BeaconA", "DispatchDesk", "RouteToB"]:
			var landmark := world.get_node_or_null(node_path) as Node3D
			if landmark != null:
				t.ok(camera.is_position_in_frustum(landmark.global_position), "%s shares the fixed G3 camera frame" % node_path)
	world.queue_free()
	await t.tree.process_frame
	return true


func test_zone_a_outer_pier_has_g3_landmarks_and_backdrops_only(t) -> bool:
	var scene := load(SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Zone A scene loads for landmark checks"):
		return true
	var world := scene.instantiate()
	t.tree.root.add_child(world)
	await t.tree.process_frame
	for node_path: String in ["BeaconA", "DispatchDesk", "RouteToB"]:
		t.ok(world.get_node_or_null(node_path) is Node3D, "%s exists for G3 frame readability" % node_path)
	for node_path: String in ["SilhouetteC", "SilhouetteE"]:
		var backdrop := world.get_node_or_null(node_path) as Node3D
		t.ok(backdrop != null, "%s exists as a distant backdrop" % node_path)
		if backdrop != null:
			t.eq(backdrop.get_meta("greybox_role"), "non_interactive_backdrop", "%s is explicitly non-interactive" % node_path)
	t.eq(world.find_children("*", "CollisionObject3D", true, false).size(), 0, "Greybox A adds no interactive collision objects")
	t.eq(world.find_children("*", "Marker3D", true, false).size(), 0, "Greybox A adds no objective or interaction markers")
	world.queue_free()
	await t.tree.process_frame
	return true
