extends RefCounted
## Library resources must keep the matte contract when later scenes reuse them.

const MATERIAL_PATHS := [
	"res://art/materials/env_wood.tres",
	"res://art/materials/env_wood_dark.tres",
	"res://art/materials/env_stone.tres",
	"res://art/materials/env_canvas_red.tres",
	"res://art/materials/env_iron.tres",
	"res://art/materials/env_rope.tres",
	"res://art/materials/env_paper.tres",
	"res://art/materials/water_wet.tres",
	"res://art/materials/signal_beacon.tres",
	"res://art/materials/signal_danger.tres",
	"res://art/materials/light_lamp_warm.tres",
]
const PRIORITY_OUTLINE_WIDTH := 0.04


func test_art_material_library_is_matte(t) -> bool:
	for path: String in MATERIAL_PATHS:
		var material := load(path) as StandardMaterial3D
		if not t.ok(material != null, "%s loads" % path):
			continue
		t.eq(material.metallic, 0.0, "%s has no metallic" % path)
		t.ok(material.roughness >= 0.85 or path.ends_with("water_wet.tres"), "%s is matte" % path)
		var expected_specular := BaseMaterial3D.SPECULAR_TOON if path.ends_with("water_wet.tres") else BaseMaterial3D.SPECULAR_DISABLED
		t.eq(material.specular_mode, expected_specular, "%s has allowed specular mode" % path)
	return true


func test_art_shaders_load_from_library(t) -> bool:
	for path: String in ["res://art/shaders/toon_matte.gdshader", "res://art/shaders/ink_outline.gdshader"]:
		var shader := load(path) as Shader
		t.ok(shader != null, "%s loads" % path)
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
	var target_paths := [
		"Cargo2x2",
		"TaxStall/Counter",
		"TaxStall/SlopedRoof",
		"Beacon/Stem",
		"Beacon/Signal",
		"DispatchTable/Table",
		"RetrieverStandin",
	]
	for path: String in target_paths:
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
		t.eq(outline.get_shader_parameter("outline_width"), PRIORITY_OUTLINE_WIDTH, "%s shares the phone-readable ink width" % path)
	lookdev.queue_free()
	await t.tree.process_frame
	return true
