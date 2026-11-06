extends RefCounted

const SCENE_PATH := "res://src/world/zone_a_outer_pier.tscn"
const ZONE_A_PROBE_GROUP := &"zone_a_lookdev_probe"


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
	for marker: Node in world.find_children("*", "Marker3D", true, false):
		t.ok(marker.is_in_group(ZONE_A_PROBE_GROUP), "Zone A Marker3D is capture-only, never an objective or interaction marker")
	world.queue_free()
	await t.tree.process_frame
	return true


func test_zone_a_lookdev_capture_uses_the_game_camera_and_visible_prt_probes(t) -> bool:
	var scene := load(SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Zone A scene loads for look-dev capture checks"):
		return true
	var world := scene.instantiate() as Node3D
	t.tree.root.add_child(world)
	await t.tree.process_frame
	var camera := world.get_node_or_null("CameraIsometric") as Camera3D
	t.ok(camera != null and camera.current, "Zone A capture uses the current gameplay camera")
	var names := ["ProbeZoneABackground", "ProbeZoneADeckLight", "ProbeZoneADeckShadow"]
	t.eq(t.tree.get_nodes_in_group(ZONE_A_PROBE_GROUP).size(), names.size(), "Zone A has only its named colour probes")
	for probe_name: String in names:
		var probe := world.get_node_or_null(probe_name) as Marker3D
		if not t.ok(probe != null, "%s exists for Zone A PRT-01" % probe_name):
			continue
		t.ok(probe.is_in_group(ZONE_A_PROBE_GROUP), "%s is isolated from look-dev probes" % probe_name)
		if camera != null:
			t.ok(bool(world.call("_probe_surface_is_visible", camera, probe)), "%s is not hidden by a nearer mesh" % probe_name)
	var background_probe := world.get_node_or_null("ProbeZoneABackground") as Marker3D
	if background_probe != null:
		t.eq(background_probe.get_meta("expected_hex"), "#4E6570", "Zone A background probe locks sea_bluegrey")
	var shadow_probe := world.get_node_or_null("ProbeZoneADeckShadow") as Marker3D
	if shadow_probe != null:
		t.eq(shadow_probe.position, Vector3(-4.58, 0.095, -3.6), "Zone A shadow probe remains on the PostTall shadow position")
		t.eq(shadow_probe.get_meta("surface_path"), "PierDeck", "Zone A shadow probe samples the continuous PierDeck")
	var capture_script := load("res://src/lookdev/zone_a_lookdev_capture.gd") as Script
	if capture_script != null:
		t.ok("zone_a_game.png" in capture_script.source_code, "Zone A capture writes the full gameplay frame")
		t.ok("zone_a_phone.png" in capture_script.source_code, "Zone A capture writes the phone frame")
		t.ok("_first_mesh_on_camera_ray" in capture_script.source_code, "Zone A probes ray-check their intended visible mesh")
	world.queue_free()
	await t.tree.process_frame
	return true


func test_zone_a_priority_fixtures_keep_phone_readable_ink_and_sparse_gouges(t) -> bool:
	var scene := load(SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Zone A scene loads for woodcut readability checks"):
		return true
	var world := scene.instantiate() as Node3D
	t.tree.root.add_child(world)
	await t.tree.process_frame
	var desk := world.get_node_or_null("DispatchDesk/DeskTop") as MeshInstance3D
	var desk_material := desk.material_override as ShaderMaterial if desk != null else null
	var deck := world.get_node_or_null("PierDeck") as MeshInstance3D
	var deck_material := deck.material_override as ShaderMaterial if deck != null else null
	t.ok(deck_material != null, "The broad pier deck uses a printed world material")
	if deck_material != null:
		t.eq(deck_material.get_shader_parameter("paper_grain_enabled"), true, "Pier deck keeps world-space paper grain")
		t.eq(deck_material.get_shader_parameter("paper_grain_strength"), 0.05, "Pier deck visibly modulates its broad lit face by five percent")
		t.eq(deck_material.get_shader_parameter("paper_fiber_scale"), 8.0, "Pier deck uses broad fibres readable at game scale")
	t.ok(desk_material != null, "Dispatch desk uses the matte toon material")
	if desk_material != null:
		t.eq(desk_material.get_shader_parameter("paper_grain_enabled"), true, "Dispatch desk keeps world-space paper grain")
		t.eq(desk_material.get_shader_parameter("paper_grain_strength"), 0.05, "Dispatch desk keeps the five percent printed modulation")
		t.eq(desk_material.get_shader_parameter("hatch_enabled"), true, "Dispatch desk carries sparse shadow gouges")
		t.eq(desk_material.get_shader_parameter("hatch_density"), 2.6, "Dispatch desk gouges remain spaced for a phone frame")
		t.eq(desk_material.get_shader_parameter("hatch_line_width"), 0.2, "Dispatch desk keeps its hand cuts narrow enough to read as long strokes")
		t.eq(desk_material.get_shader_parameter("hatch_irregularity"), 1.0, "Dispatch desk opts into irregular hand-cut gouges")
		t.eq(desk_material.get_shader_parameter("hatch_dash_frequency"), 0.33, "Dispatch desk uses long gouge strokes, not dot cadence")
		t.ok(desk_material.next_pass is ShaderMaterial, "Dispatch desk uses the priority ink outline")
	var tax_wall := world.get_node_or_null("SilhouetteE/TaxWall") as MeshInstance3D
	var tax_wall_material := tax_wall.material_override as ShaderMaterial if tax_wall != null else null
	t.ok(tax_wall_material != null, "Tax wall uses the shadow-gouge material")
	if tax_wall_material != null:
		t.eq(tax_wall_material.get_shader_parameter("paper_grain_strength"), 0.05, "Tax wall preserves visible paper grain")
		t.eq(tax_wall_material.get_shader_parameter("hatch_enabled"), true, "Tax wall restricts pale gouges to its indigo shadow")
		var gouge_colour := tax_wall_material.get_shader_parameter("hatch_gouge_colour") as Color
		t.eq(gouge_colour.to_html(false).to_upper(), "ECE3CF", "Tax wall gouges lift only the dark shadow band with paper colour")
		t.eq(tax_wall_material.get_shader_parameter("hatch_line_width"), 0.2, "Tax wall cuts remain narrow against their long run")
		t.eq(tax_wall_material.get_shader_parameter("hatch_irregularity"), 1.0, "Tax wall uses independent chisel cuts, not repeated hatch rows")
		t.eq(tax_wall_material.get_shader_parameter("hatch_dash_frequency"), 0.33, "Tax wall gouges stay long at game scale")
	t.ok(world.get_node_or_null("SilhouetteE/TaxWall/TaxWallEave") is MeshInstance3D, "Tax wall eave casts the broad shadow band for gouges")
	var beacon_stem := world.get_node_or_null("BeaconA/BeaconStem") as MeshInstance3D
	var beacon_lantern := world.get_node_or_null("BeaconA/BeaconLantern") as MeshInstance3D
	t.ok(beacon_stem != null and beacon_stem.material_override is ShaderMaterial, "Beacon stem uses matte inked world material")
	t.ok(beacon_lantern != null and beacon_lantern.material_overlay is ShaderMaterial, "Beacon signal keeps its priority ink silhouette")
	world.queue_free()
	await t.tree.process_frame
	return true


func test_zone_a_priority_fixture_transforms_remain_locked_for_task_75(t) -> bool:
	var scene := load(SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Zone A scene loads for priority-fixture transform locks"):
		return true
	var world := scene.instantiate() as Node3D
	t.tree.root.add_child(world)
	await t.tree.process_frame
	var dispatch_desk := world.get_node_or_null("DispatchDesk") as Node3D
	var beacon := world.get_node_or_null("BeaconA") as Node3D
	var extract_pier := world.get_node_or_null("ExtractPierA") as Node3D
	t.ok(dispatch_desk != null, "DispatchDesk remains named for TASK-75")
	t.ok(beacon != null, "BeaconA remains named for TASK-75")
	t.ok(extract_pier != null, "ExtractPierA remains named for TASK-75")
	if dispatch_desk != null:
		t.eq(dispatch_desk.position, Vector3(1.45, 0.0, 1.55), "DispatchDesk keeps the TASK-75 position")
		t.eq(Vector3(roundf(dispatch_desk.rotation_degrees.x), roundf(dispatch_desk.rotation_degrees.y), roundf(dispatch_desk.rotation_degrees.z)), Vector3(0.0, -3.0, 0.0), "DispatchDesk keeps the TASK-75 rotation")
	if beacon != null:
		t.eq(beacon.position, Vector3(-5.25, 0.0, -5.2), "BeaconA keeps the TASK-75 position")
		t.eq(Vector3(roundf(beacon.rotation_degrees.x), roundf(beacon.rotation_degrees.y), roundf(beacon.rotation_degrees.z)), Vector3(0.0, 3.0, -2.0), "BeaconA keeps the TASK-75 rotation")
	if extract_pier != null:
		t.eq(extract_pier.position, Vector3(-4.75, 0.0, -5.1), "ExtractPierA keeps the TASK-75 position")
		t.eq(extract_pier.rotation_degrees, Vector3.ZERO, "ExtractPierA keeps the TASK-75 rotation")
	world.queue_free()
	await t.tree.process_frame
	return true


func test_zone_a_uses_the_four_approved_kenney_models_with_library_materials(t) -> bool:
	var scene := load(SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Zone A scene loads for approved Kenney model checks"):
		return true
	var world := scene.instantiate() as Node3D
	t.tree.root.add_child(world)
	await t.tree.process_frame
	var replacements: Dictionary = {
		"ExtractPierA": "structure-platform-dock",
		"CrateStack": "crate",
		"MooringBarrels": "barrel",
		"KenneyDeckProps": "platform-planks",
	}
	for root_path: String in replacements:
		var replacement_root := world.get_node_or_null(root_path) as Node3D
		if not t.ok(replacement_root != null, "%s keeps its replacement root" % root_path):
			continue
		var expected_mesh_name: String = replacements[root_path]
		var imported_meshes := replacement_root.find_children(expected_mesh_name, "MeshInstance3D", true, false)
		t.ok(not imported_meshes.is_empty(), "%s contains the %s Kenney mesh" % [root_path, expected_mesh_name])
		for node: Node in imported_meshes:
			var mesh := node as MeshInstance3D
			t.ok(mesh.material_override is ShaderMaterial, "%s overrides imported material with a matte library shader" % mesh.get_path())
	var pier_deck := world.get_node_or_null("PierDeck") as MeshInstance3D
	t.ok(pier_deck != null and pier_deck.mesh is BoxMesh, "PierDeck keeps its continuous 14 by 10 metre walking surface")
	t.ok(world.get_node_or_null("ExtractPierA/DockProp") is Node3D, "ExtractPierA keeps its transform while only its visual child changes")
	t.eq(world.find_children("*", "CollisionObject3D", true, false).size(), 0, "Kenney visual replacements preserve Zone A's collision-free greybox state")
	world.queue_free()
	await t.tree.process_frame
	return true
