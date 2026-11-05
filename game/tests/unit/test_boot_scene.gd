extends RefCounted
## Smoke test: the main scene instantiates and shows a build label.


func test_boot_scene_shows_build_label(t) -> bool:
	var scene: PackedScene = load(ProjectSettings.get_setting("application/run/main_scene"))
	if not t.ok(scene != null, "main scene loads"):
		return true
	var boot: Node = scene.instantiate()
	t.tree.root.add_child(boot)
	await t.tree.process_frame
	var label: Label = boot.get_node("BuildLabel")
	t.ok(label.text.length() > 0, "build label filled")
	t.ok(label.text.contains(AppEnv.version), "build label shows version")
	boot.queue_free()
	await t.tree.process_frame
	return true
