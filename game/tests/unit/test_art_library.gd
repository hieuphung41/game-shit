extends RefCounted
## Library resources must keep the matte contract when later scenes reuse them.

const ENV_MATERIAL_PATHS := [
	"res://art/materials/env_wood.tres",
	"res://art/materials/env_wood_dark.tres",
	"res://art/materials/env_stone.tres",
	"res://art/materials/env_canvas_red.tres",
	"res://art/materials/env_iron.tres",
	"res://art/materials/env_rope.tres",
	"res://art/materials/env_paper.tres",
]
const SIGNAL_AND_WET_MATERIAL_PATHS := [
	"res://art/materials/water_wet.tres",
	"res://art/materials/signal_beacon.tres",
	"res://art/materials/signal_danger.tres",
	"res://art/materials/light_lamp_warm.tres",
]
const GRAIN_STRENGTH := 0.04
const PROP_OUTLINE_WIDTH := 0.035
const LANDMARK_OUTLINE_WIDTH := 0.045
const PRIORITY_OUTLINE_WIDTH := 0.055
const SEA_BLUEGREY := Color(0.305882, 0.396078, 0.439216, 1.0)


func test_art_material_library_is_matte(t) -> bool:
	for path: String in ENV_MATERIAL_PATHS:
		var material := load(path) as ShaderMaterial
		if not t.ok(material != null, "%s loads" % path):
			continue
		t.ok(material.shader != null, "%s uses the matte toon shader" % path)
		t.eq(material.get_shader_parameter("paper_grain_enabled"), true, "%s enables paper grain" % path)
		t.eq(material.get_shader_parameter("paper_grain_strength"), GRAIN_STRENGTH, "%s keeps visible 4 percent grain" % path)
		t.ok(material.get_shader_parameter("hatch_enabled") is bool, "%s exposes the hatch toggle" % path)
		t.ok(float(material.get_shader_parameter("hatch_density")) >= 2.0, "%s exposes hatch density" % path)
	for path: String in SIGNAL_AND_WET_MATERIAL_PATHS:
		var special_material := load(path) as StandardMaterial3D
		if not t.ok(special_material != null, "%s loads" % path):
			continue
		t.eq(special_material.metallic, 0.0, "%s has no metallic" % path)
		t.ok(special_material.roughness >= 0.85 or path.ends_with("water_wet.tres"), "%s is matte" % path)
		var expected_specular := BaseMaterial3D.SPECULAR_TOON if path.ends_with("water_wet.tres") else BaseMaterial3D.SPECULAR_DISABLED
		t.eq(special_material.specular_mode, expected_specular, "%s has allowed specular mode" % path)
	return true


func test_art_shaders_load_from_library(t) -> bool:
	for path: String in ["res://art/shaders/toon_matte.gdshader", "res://art/shaders/ink_outline.gdshader"]:
		var shader := load(path) as Shader
		t.ok(shader != null, "%s loads" % path)
	return true


func test_toon_shader_exposes_triplanar_paper_and_shadow_hatch(t) -> bool:
	var shader := load("res://art/shaders/toon_matte.gdshader") as Shader
	if not t.ok(shader != null, "toon shader loads for woodcut parameters"):
		return true
	var code := shader.code
	t.ok("triplanar_paper" in code, "paper grain is triplanar and world-space")
	t.ok("paper_fiber_scale" in code and "paper_speckle_density" in code, "paper grain has fibre and speckle controls")
	t.ok("hatch_enabled" in code and "hatch_density" in code and "hatch_line_width" in code and "hatch_gouge_colour" in code, "hatch can be enabled, coloured, and tuned per material")
	t.ok("along * 0.82" in code, "hatch uses long broken gouge segments instead of grain-sized dashes")
	t.ok("(1.0 - lit)" in code, "hatch is limited to the shadow band")
	t.ok("linear_to_srgb(mix(shadow_colour, ALBEDO, lit))" in code, "GL Compatibility capture encodes lit palette ink and indigo shadows")
	t.ok("ALBEDO * LIGHT_COLOR" not in code, "directional lamp colour cannot recolour printed palette ink")
	var outline_shader := load("res://art/shaders/ink_outline.gdshader") as Shader
	if outline_shader != null:
		t.ok("hint_range(0.03, 0.07)" in outline_shader.code, "ink width accepts the three outline ranks")
	return true


func test_lookdev_environment_keeps_background_and_paper_fog_separate(t) -> bool:
	var environment := load("res://art/env_default.tres") as Environment
	if not t.ok(environment != null, "look-dev environment loads"):
		return true
	t.eq(environment.background_color, SEA_BLUEGREY, "background stays sea_bluegrey")
	t.eq(environment.background_mode, Environment.BG_CLEAR_COLOR, "look-dev uses the declared environment colour as its clear background")
	t.eq(environment.background_energy_multiplier, 1.0, "background renders at its declared palette value")
	t.eq(environment.ambient_light_energy, 0.0, "ambient light cannot wash printed palette ink")
	t.eq(environment.fog_sky_affect, 0.0, "paper fog cannot cover the declared background")
	t.ok(environment.fog_enabled and environment.fog_light_energy > 0.0, "paper fog remains enabled for depth separation")
	var lookdev_script := load("res://src/lookdev/lookdev.gd") as Script
	if lookdev_script != null:
		t.ok("RenderingServer.set_default_clear_color(world_environment.environment.background_color)" in lookdev_script.source_code, "GL Compatibility clear colour is read from env_default")
	return true


func test_lookdev_scene_has_fixed_isometric_camera(t) -> bool:
	var scene := load("res://src/lookdev/lookdev.tscn") as PackedScene
	if not t.ok(scene != null, "look-dev scene loads"):
		return true
	var lookdev := scene.instantiate()
	t.tree.root.add_child(lookdev)
	await t.tree.process_frame
	var camera := lookdev.get_node_or_null("Camera3D") as Camera3D
	t.ok(camera != null, "look-dev has camera")
	if camera != null:
		t.eq(camera.projection, Camera3D.PROJECTION_ORTHOGONAL, "camera is orthographic")
		t.eq(roundi(camera.rotation_degrees.x), -30, "camera pitch is -30 degrees")
		t.eq(roundi(camera.rotation_degrees.y), 45, "camera yaw is 45 degrees")
	t.ok(lookdev.get_node_or_null("DirectionalLight3D") is DirectionalLight3D, "look-dev has main directional light")
	t.eq(lookdev.find_children("*", "OmniLight3D", true, false).size(), 0, "beacon and lamp use emission without env-lighting pools")
	t.eq(lookdev.get_tree().get_nodes_in_group("lookdev_probe").size(), 7, "named projected colour probes cover background, palette faces, and shadow")
	for expected_probe: Dictionary in [
		{"name": "ProbeWood", "hex": "#7B5B40"},
		{"name": "ProbeWoodDark", "hex": "#4A3426"},
		{"name": "ProbeStone", "hex": "#7A756C"},
		{"name": "ProbeCanvas", "hex": "#7B2F27"},
		{"name": "ProbePaper", "hex": "#D8CDB4"},
		{"name": "ProbeFloorShadow", "hex": "#2C3142"},
	]:
		var probe := lookdev.get_node_or_null(str(expected_probe["name"])) as Marker3D
		if not t.ok(probe != null, "%s exists" % expected_probe["name"]):
			continue
		t.eq(probe.get_meta("expected_hex"), expected_probe["hex"], "%s locks its palette expectation" % expected_probe["name"])
	lookdev.queue_free()
	await t.tree.process_frame
	return true


func test_lookdev_priority_props_use_toon_and_ink_pass(t) -> bool:
	var scene := load("res://src/lookdev/lookdev.tscn") as PackedScene
	if not t.ok(scene != null, "look-dev scene loads for material checks"):
		return true
	var lookdev := scene.instantiate()
	t.tree.root.add_child(lookdev)
	await t.tree.process_frame
	var outline_widths := {
		"Cargo2x2": PRIORITY_OUTLINE_WIDTH,
		"TaxStall/Counter": PRIORITY_OUTLINE_WIDTH,
		"TaxStall/SlopedRoof": LANDMARK_OUTLINE_WIDTH,
		"Beacon/Stem": LANDMARK_OUTLINE_WIDTH,
		"Beacon/Signal": PRIORITY_OUTLINE_WIDTH,
		"DispatchTable/Table": PRIORITY_OUTLINE_WIDTH,
		"RetrieverStandin": PRIORITY_OUTLINE_WIDTH,
		"Crate": PROP_OUTLINE_WIDTH,
	}
	for path: String in outline_widths:
		var mesh := lookdev.get_node_or_null(path) as MeshInstance3D
		if not t.ok(mesh != null, "%s exists" % path):
			continue
		var material := mesh.material_override as ShaderMaterial
		if not t.ok(material != null, "%s uses a toon ShaderMaterial" % path):
			continue
		t.ok(material.shader != null, "%s toon shader loads" % path)
		var outline := material.next_pass as ShaderMaterial
		if not t.ok(outline != null, "%s has ink next pass" % path):
			continue
		t.eq(outline.get_shader_parameter("outline_width"), outline_widths[path], "%s uses its silhouette outline rank" % path)
		t.eq(material.get_shader_parameter("paper_grain_enabled"), true, "%s keeps world-space paper grain enabled" % path)
	for path: String in ["Cargo2x2", "TaxStall/Counter", "TaxStall/SlopedRoof"]:
		var hatched_mesh := lookdev.get_node_or_null(path) as MeshInstance3D
		var hatched_material := hatched_mesh.material_override as ShaderMaterial
		t.eq(hatched_material.get_shader_parameter("hatch_enabled"), true, "%s enables sparse shadow hatching" % path)
		t.ok(float(hatched_material.get_shader_parameter("hatch_density")) >= 2.0, "%s has a material hatch density" % path)
	for path: String in ["Cargo2x2", "TaxStall/Counter"]:
		var repair_mesh := lookdev.get_node_or_null(path) as MeshInstance3D
		var repair_material := repair_mesh.material_override as ShaderMaterial
		t.ok(float(repair_material.get_shader_parameter("hatch_density")) <= 2.7, "%s spaces gouge rows far enough apart to read separately" % path)
		t.ok(float(repair_material.get_shader_parameter("hatch_line_width")) >= 0.20, "%s uses wide phone-readable gouge strokes" % path)
		t.ok(float(repair_material.get_shader_parameter("hatch_strength")) >= 0.90, "%s carries gouge strokes to ink contrast in shadow" % path)
	var dark_cargo := lookdev.get_node_or_null("Cargo2x2") as MeshInstance3D
	if dark_cargo != null:
		var dark_cargo_material := dark_cargo.material_override as ShaderMaterial
		var paper_light := Color(0.92549, 0.890196, 0.811765, 1)
		t.eq(dark_cargo_material.get_shader_parameter("hatch_gouge_colour"), paper_light, "Cargo2x2 cuts paper-light relief through its dark shadow band")
	var wood_counter := lookdev.get_node_or_null("TaxStall/Counter") as MeshInstance3D
	if wood_counter != null:
		var wood_counter_material := wood_counter.material_override as ShaderMaterial
		var ink := Color(0.121569, 0.101961, 0.090196, 1)
		t.eq(wood_counter_material.get_shader_parameter("hatch_gouge_colour"), ink, "TaxStall counter keeps ink gouges on lighter wood")
	var floor := lookdev.get_node_or_null("Floor") as MeshInstance3D
	if floor != null:
		var floor_material := floor.material_override as ShaderMaterial
		t.ok(floor_material.next_pass == null, "telegraph floor has no ink outline")
		t.eq(floor_material.get_shader_parameter("hatch_enabled"), false, "telegraph floor has no hatch")
	lookdev.queue_free()
	await t.tree.process_frame
	return true
