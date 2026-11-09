extends RefCounted

const SCENE_PATH := "res://src/world/zone_b_flooded_market.tscn"
const PROBE_GROUP := &"zone_b_lookdev_probe"


func test_zone_b_has_spec_markers_at_local_coordinates(t) -> bool:
	var scene := load(SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Zone B scene loads"):
		return true
	var zone := scene.instantiate() as Node3D
	t.tree.root.add_child(zone)
	await t.tree.process_frame
	var expected := {
		"SeamAB": Vector3(0.0, 0.09, 0.0),
		"BEntry": Vector3(3.0, 0.09, -1.0),
		"GuardPost": Vector3(4.5, 0.09, -7.5),
		"WithdrawPointGuard": Vector3(1.5, 0.09, -9.75),
		"ForemanChargeLane/end_a": Vector3(4.5, 0.09, -22.5),
		"ForemanChargeLane/end_b": Vector3(4.5, 0.09, -13.5),
		"WithdrawPointForeman": Vector3(0.5, 0.09, -23.25),
		"PatrolReturnPath/P0": Vector3(7.0, 0.09, 1.0),
		"PatrolReturnPath/P1": Vector3(3.0, 0.09, -6.0),
		"PatrolReturnPath/P2": Vector3(3.0, 0.09, -19.0),
		"HoldLaneBSpawn": Vector3(7.0, 0.09, -24.5),
		"HoldLaneBPath/H1": Vector3(3.5, 0.09, -8.0),
		"HoldLaneBPath/H2": Vector3(2.0, 0.09, 0.0),
		"HoldLaneBPath/H3": Vector3(-0.8, 0.09, 0.0),
		"HoldLaneBPath/HG1": Vector3(-3.0, 0.09, -1.85),
		"HoldGuardPost": Vector3(-8.85, 0.09, -2.0),
		"HoldChargeLane/end_a": Vector3(-3.2, 0.09, 0.05),
		"HoldChargeLane/end_b": Vector3(-12.6, 0.09, 0.05),
		"LaneBAlertLamp": Vector3(-0.7, 0.0, -1.95),
	}
	for node_path: String in expected:
		var node := zone.get_node_or_null(node_path) as Node3D
		if t.ok(node != null, "%s exists" % node_path):
			t.ok(node.position.distance_to(expected[node_path]) <= 0.1, "%s remains within 0.1 m of TASK-81" % node_path)
	zone.queue_free()
	await t.tree.process_frame
	return true


func test_zone_b_cover_and_blocked_route_have_honest_collision(t) -> bool:
	var scene := load(SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Zone B scene loads for collision checks"):
		return true
	var zone := scene.instantiate() as Node3D
	t.tree.root.add_child(zone)
	await t.tree.process_frame
	for name: String in ["CoverB1", "CoverB2", "CoverB3", "CoverB4", "BlockedRouteD"]:
		var body := zone.get_node_or_null(name) as StaticBody3D
		t.ok(body != null, "%s is a solid world body" % name)
		if body != null:
			t.ok(body.get_node_or_null("CollisionShape3D") is CollisionShape3D, "%s supplies its collision proxy" % name)
	var blocked_route := zone.get_node_or_null("BlockedRouteD") as StaticBody3D
	if blocked_route != null:
		for part: String in ["FrameTop", "FrameBottom", "FramePostWest", "FramePostEast", "SlatWest", "Slat01", "Slat02", "Slat03", "Slat04", "Slat05", "Slat06", "Chain", "ChainCross", "TaxSealNotice", "TaxSeal", "TaxSealRibbon"]:
			t.ok(blocked_route.get_node_or_null(part) is MeshInstance3D, "Blocked D route has readable %s geometry" % part)
		var frame_top := blocked_route.get_node_or_null("FrameTop") as MeshInstance3D
		var top_mesh := frame_top.mesh as BoxMesh if frame_top != null else null
		t.ok(top_mesh != null and top_mesh.size.x >= 4.0, "Blocked D route keeps a wide closing-frame silhouette at phone scale")
		var crossed_chain := blocked_route.get_node_or_null("ChainCross") as MeshInstance3D
		t.ok(crossed_chain != null, "Blocked D route keeps a second chain for the closed X read")
	var water_gap := zone.get_node_or_null("MissingPlankWaterGapD") as MeshInstance3D
	t.ok(water_gap != null and water_gap.get_meta("greybox_role") == "route_d_missing_plank_water_gap_1_5m", "Blocked D route exposes the one-and-a-half-metre water gap")
	var water_mesh := water_gap.mesh as PlaneMesh if water_gap != null else null
	t.ok(water_mesh != null and water_mesh.size.x >= 4.0, "Blocked D water gap stays broad enough to read behind the frame")
	t.ok(zone.get_node_or_null("DistantWarehouseSilhouetteD") == null, "Distant D silhouette moves into the real Zone D cage landmark")
	t.ok(zone.get_node_or_null("RouteDLintel") is MeshInstance3D, "Blocked D route keeps the fixed red-canvas return lintel")
	t.ok(zone.get_node_or_null("RouteDPlanks") is StaticBody3D, "Blocked D route owns the open-state walkable planks")
	t.ok(zone.get_node_or_null("RouteDSideRails") is Node3D, "Blocked D route keeps low rails along both plank edges")
	t.ok(zone.get_node_or_null("RouteDOpenDebris") is Node3D, "Blocked D route has broken-chain debris for the open read")
	t.ok(zone.get_node_or_null("PatrolTriggerB") is Area3D, "B has the authored return patrol trigger beyond Gate B")
	var floor := zone.get_node_or_null("FloorCollision") as StaticBody3D
	t.ok(floor != null and floor.get_node_or_null("CollisionShape3D") is CollisionShape3D, "B floor collision continues the walkable seam")
	var edges := zone.get_node_or_null("PlayableEdgesB") as StaticBody3D
	t.ok(edges != null and edges.collision_layer == 2, "B has world-static water-edge collision")
	if edges != null:
		for edge_name: String in ["East", "EntrySouth", "EntryNorth"]:
			t.ok(edges.get_node_or_null(edge_name) is CollisionShape3D, "B edge %s leaves only the A seam open" % edge_name)
	zone.queue_free()
	await t.tree.process_frame
	return true


func test_zone_b_route_d_open_state_switches_honest_collision(t) -> bool:
	var scene := load(SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Zone B scene loads for route state checks"):
		return true
	var zone := scene.instantiate() as Node3D
	t.tree.root.add_child(zone)
	await t.tree.process_frame
	var blocked := zone.get_node_or_null("BlockedRouteD") as StaticBody3D
	var blocker := zone.get_node_or_null("BlockedRouteD/CollisionShape3D") as CollisionShape3D
	var planks := zone.get_node_or_null("RouteDPlanks") as StaticBody3D
	var plank_collision := zone.get_node_or_null("RouteDPlanks/CollisionShape3D") as CollisionShape3D
	var debris := zone.get_node_or_null("RouteDOpenDebris") as Node3D
	t.ok(blocked != null and blocker != null, "Closed D route has a full-width blocking collision")
	t.ok(planks != null and plank_collision != null, "Open D route has a separate plank collision")
	zone.call("set_route_d_open", false)
	await t.tree.process_frame
	if blocked != null and blocker != null and planks != null and plank_collision != null and debris != null:
		t.eq(blocked.collision_layer, 2, "Closed D route blocks the world-static layer")
		t.eq(blocker.disabled, false, "Closed D route collision is enabled")
		t.eq(planks.collision_layer, 0, "Closed D planks do not leave a collision bridge")
		t.eq(plank_collision.disabled, true, "Closed D plank collision is disabled")
		t.eq(planks.visible, false, "Closed D route hides the bridge geometry")
		t.eq(debris.visible, false, "Closed D route hides opened-chain debris")
	zone.call("set_route_d_open", true)
	await t.tree.process_frame
	if blocked != null and blocker != null and planks != null and plank_collision != null and debris != null:
		t.eq(blocked.collision_layer, 0, "Open D frame no longer blocks the world-static layer")
		t.eq(blocker.disabled, true, "Open D frame collision is disabled")
		t.eq(planks.collision_layer, 2, "Open D planks join the world-static layer")
		t.eq(plank_collision.disabled, false, "Open D plank collision is enabled")
		t.eq(planks.visible, true, "Open D route shows the plank bridge")
		t.eq(debris.visible, true, "Open D route shows broken-chain debris")
	zone.queue_free()
	await t.tree.process_frame
	return true


func test_zone_b_is_instanced_from_a_at_the_locked_offset(t) -> bool:
	var a_scene := load("res://src/world/zone_a_outer_pier.tscn") as PackedScene
	if not t.ok(a_scene != null, "Zone A scene loads with the B seam"):
		return true
	var world := a_scene.instantiate() as Node3D
	t.tree.root.add_child(world)
	await t.tree.process_frame
	var zone_b := world.get_node_or_null("ZoneBFloodedMarket") as Node3D
	t.ok(zone_b != null, "Zone A instances Zone B for a no-load transition")
	if zone_b != null:
		t.eq(zone_b.position, Vector3(7.0, 0.0, -2.45), "B root preserves the documented A-to-B offset")
		t.eq(zone_b.rotation_degrees, Vector3.ZERO, "B root remains unrotated at the seam")
		var seam := zone_b.get_node_or_null("SeamAB") as Marker3D
		if seam != null:
			t.ok(seam.global_position.distance_to(Vector3(7.0, 0.09, -2.45)) <= 0.1, "SeamAB meets A's east deck edge")
	world.queue_free()
	await t.tree.process_frame
	return true


func test_zone_ab_edge_collisions_block_former_water_gaps_without_closing_the_seam(t) -> bool:
	var a_scene := load("res://src/world/zone_a_outer_pier.tscn") as PackedScene
	if not t.ok(a_scene != null, "Zone A scene loads for physical A/B edge regression"):
		return true
	var world := a_scene.instantiate() as Node3D
	t.tree.root.add_child(world)
	await t.tree.physics_frame

	var a_east_gap := _create_edge_test_retriever()
	world.add_child(a_east_gap)
	a_east_gap.global_position = Vector3(6.0, 0.84, 0.5)
	await t.tree.physics_frame
	await _move_character_for_physics_frames(t, a_east_gap, Vector3(3.0, 0.0, 0.0), 60)
	t.ok(a_east_gap.global_position.x < 6.7, "CharacterBody3D cannot leave A through the former east water gap")
	a_east_gap.queue_free()

	var b_west_gap := _create_edge_test_retriever()
	world.add_child(b_west_gap)
	b_west_gap.global_position = Vector3(7.5, 0.84, -5.2)
	await t.tree.physics_frame
	await _move_character_for_physics_frames(t, b_west_gap, Vector3(-3.0, 0.0, 0.0), 60)
	t.ok(b_west_gap.global_position.x > 7.1, "CharacterBody3D cannot leave B through the former west facade gap")
	b_west_gap.queue_free()

	var seam_traversal := _create_edge_test_retriever()
	world.add_child(seam_traversal)
	seam_traversal.global_position = Vector3(6.0, 0.84, -2.45)
	await t.tree.physics_frame
	await _move_character_for_physics_frames(t, seam_traversal, Vector3(3.0, 0.0, 0.0), 60)
	t.ok(seam_traversal.global_position.x > 8.5, "CharacterBody3D still crosses the authored three-metre A-to-B seam")
	world.queue_free()
	await t.tree.process_frame
	return true


func _create_edge_test_retriever() -> CharacterBody3D:
	var retriever := CharacterBody3D.new()
	retriever.collision_layer = 1
	retriever.collision_mask = 2
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.30
	shape.height = 1.50
	collision.shape = shape
	retriever.add_child(collision)
	return retriever


func _move_character_for_physics_frames(t, character: CharacterBody3D, motion: Vector3, frame_count: int) -> void:
	for frame_index: int in frame_count:
		character.velocity = motion
		character.move_and_slide()
		await t.tree.physics_frame


func test_zone_b_probes_keep_visible_surfaces_and_signal_lane(t) -> bool:
	var scene := load(SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Zone B scene loads for probe checks"):
		return true
	var zone := scene.instantiate() as Node3D
	t.tree.root.add_child(zone)
	await t.tree.process_frame
	var names := ["ProbeZoneBFloorLit", "ProbeZoneBFloorShadow", "ProbeZoneBLaneFloor", "ProbeZoneBLaneDanger", "ProbeZoneBAwning", "ProbeZoneBBackground"]
	t.eq(t.tree.get_nodes_in_group(PROBE_GROUP).size(), names.size(), "Zone B owns its six look-dev probes")
	for name: String in names:
		var probe := zone.get_node_or_null(name) as Marker3D
		t.ok(probe != null and probe.is_in_group(PROBE_GROUP), "%s is isolated in the B probe group" % name)
	zone.call("_prepare_capture_camera")
	await t.tree.process_frame
	var camera := zone.get_node_or_null("CameraIsometric") as Camera3D
	t.ok(camera != null and camera.current, "B look-dev capture creates the documented current game camera")
	if camera != null:
		for name: String in ["ProbeZoneBFloorLit", "ProbeZoneBFloorShadow", "ProbeZoneBLaneFloor", "ProbeZoneBLaneDanger", "ProbeZoneBAwning"]:
			var probe := zone.get_node_or_null(name) as Marker3D
			if probe != null:
				t.ok(bool(zone.call("_probe_surface_is_visible", camera, probe)), "%s is not hidden by a nearer mesh" % name)
		var lit_probe := zone.get_node_or_null("ProbeZoneBFloorLit") as Marker3D
		var shadow_probe := zone.get_node_or_null("ProbeZoneBFloorShadow") as Marker3D
		var danger_probe := zone.get_node_or_null("ProbeZoneBLaneDanger") as Marker3D
		if lit_probe != null:
			t.eq(lit_probe.get_meta("placement"), "producer-approved visible floor surface", "Floor-lit probe follows the visible-surface producer decision")
		if shadow_probe != null:
			t.eq(shadow_probe.get_meta("placement"), "producer-approved visible cast-shadow surface", "Floor-shadow probe follows the visible-surface producer decision")
		if danger_probe != null:
			t.eq(danger_probe.get_meta("expected_hex"), "#E5482D", "Lane probe measures signal danger rather than the wood floor")
			t.eq(danger_probe.get_meta("surface_path"), "ChargeLaneTelegraph/LeftEdge", "Lane probe ray-checks the active signal edge")
			t.eq(danger_probe.get_meta("tolerance"), 5.0, "Lane probe allows at most DeltaE 5 on the opaque danger core")
		var blocked_route := zone.get_node_or_null("BlockedRouteD") as Node3D
		if blocked_route != null:
			blocked_route.position += Vector3(0.25, 0.0, -0.5)
			t.ok(bool(zone.call("_position_camera_at_blocked_route_d")), "Route D capture resolves the blocked-gate node")
			t.ok((camera.global_position - blocked_route.global_position).is_equal_approx(Vector3(7.35, 6.3, 5.65)), "Route D camera follows the actual blocked-gate transform and frames the closure beyond it")
			t.eq(camera.size, 7.0, "Route D capture gives the gate closure evidence readable phone-scale framing")
	var lane := zone.get_node_or_null("ChargeLaneTelegraph") as Node3D
	t.ok(lane != null and lane.get_meta("visual_role") == "signal_danger_floor_telegraph", "B lane uses the signal-only charge telegraph")
	zone.queue_free()
	await t.tree.process_frame
	return true


func test_zone_b_facade_cuts_stay_sparse_and_irregular(t) -> bool:
	var scene := load(SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Zone B scene loads for facade woodcut checks"):
		return true
	var zone := scene.instantiate() as Node3D
	t.tree.root.add_child(zone)
	await t.tree.process_frame
	var facade := zone.get_node_or_null("WestFacade/Wall") as MeshInstance3D
	var material := facade.material_override as ShaderMaterial if facade != null else null
	t.ok(material != null, "Zone B facade uses the sparse shadow-cut material")
	if material != null:
		t.eq(material.get_shader_parameter("hatch_density"), 2.4, "Facade makes only a few paper-coloured shadow gouges visible at game scale")
		t.eq(material.get_shader_parameter("hatch_line_width"), 0.1, "Facade cuts leave broad unmarked shadow between narrow strokes")
		t.eq(material.get_shader_parameter("hatch_strength"), 0.6, "Facade cuts remain restrained relief rather than a full pattern")
		t.eq(material.get_shader_parameter("hatch_irregularity"), 1.0, "Facade cuts retain varied hard-edged lengths")
		t.eq(material.get_shader_parameter("hatch_dash_frequency"), 0.33, "Facade cuts form isolated long marks instead of a repeated cadence")
		t.eq(material.get_shader_parameter("hatch_cluster_enabled"), true, "Facade alone opts into sparse world-space gouge clusters")
		t.eq(material.get_shader_parameter("hatch_cluster_coverage"), 0.18, "Facade clusters mark at most roughly one fifth of the shadow band")
		t.eq(material.get_shader_parameter("hatch_cluster_cell_size"), 2.4, "Facade clusters use metre-scale world cells")
	var awning := zone.get_node_or_null("WestFacade/AwningB") as MeshInstance3D
	var awning_material := awning.material_override as ShaderMaterial if awning != null else null
	t.ok(awning_material != null, "Zone B awning keeps its plain canvas material")
	if awning_material != null:
		t.eq(awning_material.get_shader_parameter("hatch_enabled"), false, "Awning remains plain so only the broad shadow facade carries sparse gouges")
	zone.queue_free()
	await t.tree.process_frame
	return true


func test_zone_b_cc0_market_props_keep_collision_and_use_matte_library_materials(t) -> bool:
	var scene := load(SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Zone B scene loads for CC0 prop checks"):
		return true
	var zone := scene.instantiate() as Node3D
	t.tree.root.add_child(zone)
	await t.tree.process_frame
	var replacements: Dictionary = {
		"KenneyMarketStalls": "structure-platform-small",
		"WestFacade/StallRoof": "structure-roof",
		"KenneyCargo": "crate",
		"GateB/KenneyTaxGate": "structure-fence-sides",
		"LandmarkEntryLantern/KenneyLanternMast": "mast",
	}
	for root_path: String in replacements:
		var replacement_root := zone.get_node_or_null(root_path) as Node3D
		if not t.ok(replacement_root != null, "%s keeps its CC0 visual root" % root_path):
			continue
		var expected_mesh_name: String = replacements[root_path]
		var imported_meshes := replacement_root.find_children(expected_mesh_name, "MeshInstance3D", true, false)
		t.ok(not imported_meshes.is_empty(), "%s contains the %s Kenney mesh" % [root_path, expected_mesh_name])
		for node: Node in imported_meshes:
			var mesh := node as MeshInstance3D
			t.ok(mesh.material_override is ShaderMaterial, "%s replaces the imported material with a matte library shader" % mesh.get_path())
	var counter_root := zone.get_node_or_null("KenneyMarketStalls") as Node3D
	var counter := zone.get_node_or_null("KenneyMarketStalls/StallCounter") as Node3D
	var roof := zone.get_node_or_null("WestFacade/StallRoof") as Node3D
	var gate := zone.get_node_or_null("GateB/KenneyTaxGate") as Node3D
	var cargo := zone.get_node_or_null("KenneyCargo/CoverTwo") as Node3D
	var facade := zone.get_node_or_null("WestFacade") as Node3D
	t.ok(counter != null and counter.scale.x >= 2.0, "Market counter keeps a readable phone-scale silhouette")
	t.ok(counter_root != null and counter_root.get_parent() == zone and facade != null and counter_root.global_position.distance_to(facade.global_position) >= 4.0, "Market counter is a visual-only root clear of the facade at phone scale")
	t.ok(roof != null and roof.scale.x >= 1.45 and roof.scale.y >= 0.95, "Market awning keeps a readable phone-scale silhouette")
	t.ok(gate != null and gate.scale.y >= 2.1 and gate.scale.x >= 1.5, "Tax gate keeps a tall readable phone-scale silhouette")
	t.ok(cargo != null and cargo.scale.x >= 1.9, "Market cargo keeps a readable phone-scale silhouette")
	for cover_name: String in ["CoverB1", "CoverB2", "CoverB3", "CoverB4"]:
		var collision := zone.get_node_or_null(cover_name) as StaticBody3D
		var placeholder := zone.get_node_or_null("%s/Mesh" % cover_name) as MeshInstance3D
		t.ok(collision != null and collision.collision_layer == 2, "%s retains authored collision under its CC0 visual" % cover_name)
		t.ok(placeholder != null and not placeholder.visible, "%s hides the old box visual" % cover_name)
	var floor := zone.get_node_or_null("FloorB") as MeshInstance3D
	t.ok(floor != null and floor.visible, "B keeps its continuous clear telegraph floor")
	zone.queue_free()
	await t.tree.process_frame
	return true
