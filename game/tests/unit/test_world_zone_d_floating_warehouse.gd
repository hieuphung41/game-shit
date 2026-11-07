extends RefCounted

const SCENE_PATH := "res://src/world/zone_d_floating_warehouse.tscn"
const PROBE_GROUP := &"zone_d_lookdev_probe"


func test_zone_d_has_locked_markers_sources_and_world_static_floor(t) -> bool:
	var scene := load(SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Zone D scene loads"):
		return true
	var zone := scene.instantiate() as Node3D
	t.tree.root.add_child(zone)
	await t.tree.process_frame
	t.eq(str(zone.name), "ZoneDFloatingWarehouse", "D root keeps its canonical name")
	t.eq(zone.get_meta("zone"), "zone_d_floating_warehouse", "D root carries its canonical zone id")
	t.eq(zone.get_meta("placement_contract"), "Parent at world (11.75, 0.0, -36.95), rotation zero.", "D root documents the exact B-to-D placement")
	var expected := {
		"DExitToB": Vector3(0.0, 0.09, 0.0),
		"DEntry": Vector3(0.0, 0.09, -1.0),
		"CalmZoneD": Vector3(-0.25, 1.0, -6.75),
		"CargoD": Vector3(-2.5, 0.0, -9.0),
		"TaxStampD": Vector3(2.0, 0.0, -6.5),
		"CageRowNorthD": Vector3(-1.5, 1.5, -11.75),
		"CageWestD": Vector3(-4.5, 1.3, -7.0),
	}
	for node_path: String in expected:
		var node := zone.get_node_or_null(node_path) as Node3D
		if t.ok(node != null, "%s exists" % node_path):
			t.ok(node.position.distance_to(expected[node_path]) <= 0.1, "%s remains within 0.1 m of the D spec" % node_path)
	var floor := zone.get_node_or_null("FloorCollisionD") as StaticBody3D
	t.ok(floor != null and floor.collision_layer == 2, "D walkable floor is world_static")
	t.ok(floor != null and floor.get_child_count() == 3, "D floor uses dock, main, and north collision pieces without a height step")
	var calm := zone.get_node_or_null("CalmZoneD") as Area3D
	t.ok(calm != null and calm.get_node_or_null("CollisionShape3D") is CollisionShape3D, "D calm zone is an authored Area3D")
	var cargo := zone.get_node_or_null("CargoD") as Node3D
	var stamp := zone.get_node_or_null("TaxStampD") as Node3D
	if cargo != null:
		t.eq(cargo.get_meta("source_id"), "cargo_d_2x2", "Cargo source keeps its authored id")
		t.ok(cargo.get_node_or_null("Pallet") is StaticBody3D and cargo.get_node_or_null("ItemBlock") is StaticBody3D, "Cargo uses a square pallet and separate item collision")
	if stamp != null:
		t.eq(stamp.get_meta("source_id"), "tax_stamp_d", "Tax Stamp source keeps its authored id")
		t.ok(stamp.get_node_or_null("Desk") is StaticBody3D and stamp.get_node_or_null("ItemBlock") is StaticBody3D, "Tax Stamp uses a desk and separate long item collision")
	zone.queue_free()
	await t.tree.process_frame
	return true


func test_zone_d_has_no_extract_grammar_and_its_probes_are_isolated(t) -> bool:
	var scene := load(SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Zone D scene loads for grammar checks"):
		return true
	var zone := scene.instantiate() as Node3D
	t.tree.root.add_child(zone)
	await t.tree.process_frame
	for node: Node in [zone] + zone.find_children("*", "", true, false):
		var lower_name := node.name.to_lower()
		for forbidden: String in ["extract", "beacon", "boat", "pier", "board"]:
			t.ok(forbidden not in lower_name, "D node %s does not introduce %s grammar" % [node.name, forbidden])
	var probe_names := ["ProbeZoneDFloorLit", "ProbeZoneDFloorShadow", "ProbeZoneDWater", "ProbeZoneDBackground"]
	t.eq(t.tree.get_nodes_in_group(PROBE_GROUP).size(), probe_names.size(), "D owns exactly four isolated look-dev probes")
	for probe_name: String in probe_names:
		var probe := zone.get_node_or_null(probe_name) as Marker3D
		t.ok(probe != null and probe.is_in_group(PROBE_GROUP), "%s remains a D-only probe" % probe_name)
	zone.queue_free()
	await t.tree.process_frame
	return true


func test_zone_d_west_cage_keeps_sparse_paper_gouges_in_its_shadow_band(t) -> bool:
	var scene := load(SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Zone D scene loads for west cage material checks"):
		return true
	var zone := scene.instantiate() as Node3D
	t.tree.root.add_child(zone)
	await t.tree.process_frame
	var west_cage := zone.get_node_or_null("CageWestD/Mesh") as MeshInstance3D
	var material := west_cage.material_override as ShaderMaterial if west_cage != null else null
	t.ok(material != null, "The broad west cage uses its D-local matte woodcut material")
	if material != null:
		t.eq(material.get_shader_parameter("hatch_enabled"), true, "West cage enables shadow-only gouges")
		t.eq(material.get_shader_parameter("hatch_density"), 2.4, "West cage leaves broad gaps between gouge rows")
		t.eq(material.get_shader_parameter("hatch_line_width"), 0.1, "West cage gouges remain narrow hard-edged strokes")
		t.eq(material.get_shader_parameter("hatch_strength"), 0.6, "West cage relief stays restrained")
		t.eq(material.get_shader_parameter("hatch_irregularity"), 1.0, "West cage gouges vary their hand-cut lengths")
		t.eq(material.get_shader_parameter("hatch_dash_frequency"), 0.33, "West cage gouges use long isolated marks")
		t.eq(material.get_shader_parameter("hatch_cluster_enabled"), true, "West cage uses sparse world-space gouge clusters")
		t.eq(material.get_shader_parameter("hatch_cluster_coverage"), 0.18, "West cage marks at most one fifth of its shadow band")
		var gouge_colour := material.get_shader_parameter("hatch_gouge_colour") as Color
		t.eq(gouge_colour.to_html(false).to_upper(), "ECE3CF", "West cage lifts only indigo shadow with paper colour")
	var gouges := zone.get_node_or_null("CageWestD/PaperGouges") as Node3D
	t.ok(gouges != null, "West cage has an authored paper-light gouge cluster for game-scale WC-02 readability")
	if gouges != null:
		t.eq(gouges.get_child_count(), 5, "West cage keeps exactly five sparse gouges with plain gaps")
		t.ok(gouges.position.x >= 0.56, "Paper gouges sit proud of the visible west-cage face instead of z-fighting it")
		for gouge: Node in gouges.get_children():
			var gouge_mesh := gouge as MeshInstance3D
			var gouge_material := gouge_mesh.material_override as ShaderMaterial if gouge_mesh != null else null
			t.ok(gouge_material != null and gouge_material.get_shader_parameter("paper_gouge_override") == true, "%s is a hard-edged paper-light gouge" % gouge.name)
			var gouge_plane := gouge_mesh.mesh as PlaneMesh if gouge_mesh != null else null
			t.ok(gouge_plane != null and gouge_plane.size.x >= 0.15, "%s keeps a phone-readable cut width" % gouge.name)
	zone.queue_free()
	await t.tree.process_frame
	return true


func test_route_d_bridge_and_dock_share_the_same_walkable_height(t) -> bool:
	var b_scene := load("res://src/world/zone_b_flooded_market.tscn") as PackedScene
	var d_scene := load(SCENE_PATH) as PackedScene
	if not t.ok(b_scene != null and d_scene != null, "B and D scenes load for the continuous bridge check"):
		return true
	var world := Node3D.new()
	t.tree.root.add_child(world)
	var zone_b := b_scene.instantiate() as Node3D
	zone_b.position = Vector3(7.0, 0.0, -2.45)
	world.add_child(zone_b)
	var zone_d := d_scene.instantiate() as Node3D
	zone_d.position = Vector3(11.75, 0.0, -36.95)
	world.add_child(zone_d)
	zone_b.call("set_route_d_open", true)
	await t.tree.process_frame
	await t.tree.physics_frame
	var b_floor := zone_b.get_node_or_null("FloorB") as MeshInstance3D
	var planks := zone_b.get_node_or_null("RouteDPlanks") as StaticBody3D
	var dock := zone_d.get_node_or_null("FloorD/Dock") as MeshInstance3D
	if b_floor != null and planks != null and dock != null:
		var b_top := b_floor.global_position.y + 0.09
		var plank_top := planks.global_position.y + 0.09
		var dock_top := dock.global_position.y + 0.09
		t.ok(is_equal_approx(b_top, plank_top) and is_equal_approx(plank_top, dock_top), "B floor, open bridge, and D dock share y = 0.09")
		var query := PhysicsRayQueryParameters3D.create(Vector3(11.75, 2.0, -35.95), Vector3(11.75, -1.0, -35.95), 2)
		var hit := world.get_world_3d().direct_space_state.intersect_ray(query)
		t.ok(not hit.is_empty(), "Open bridge has honest world-static collision between B and D")
	world.queue_free()
	await t.tree.process_frame
	return true
