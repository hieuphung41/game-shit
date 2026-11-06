extends RefCounted

const CHARACTER_SCENES := {
	&"retriever": "res://src/characters/retriever_model.tscn",
	&"tax_guard": "res://src/characters/tax_guard_model.tscn",
	&"foreman": "res://src/characters/foreman_model.tscn",
}

var logical_states := {
	&"retriever": PackedStringArray(["idle", "run", "attack", "guard", "guard_hit", "dodge", "hit", "use_remedy", "down"]),
	&"tax_guard": PackedStringArray(["idle", "walk", "alert", "windup", "strike", "recover", "block", "hit", "down"]),
	&"foreman": PackedStringArray(["idle", "walk", "alert", "windup", "charge", "recover", "stagger", "hit", "down"]),
}


func test_character_models_load_with_rig_and_library_materials(t) -> bool:
	for role: StringName in CHARACTER_SCENES:
		var scene := load(CHARACTER_SCENES[role]) as PackedScene
		if not t.ok(scene != null, "%s model scene loads" % role):
			continue
		var model := scene.instantiate() as Node3D
		t.tree.root.add_child(model)
		await t.tree.process_frame
		t.ok(not model.find_children("*", "Skeleton3D", true, false).is_empty(), "%s keeps the CC0 rig" % role)
		var animation_player := model.get_node_or_null("AnimationPlayer") as AnimationPlayer
		t.ok(animation_player != null, "%s provides an AnimationPlayer" % role)
		for surface: Node in model.find_children("*", "MeshInstance3D", true, false):
			var mesh := surface as MeshInstance3D
			var material := mesh.material_override as ShaderMaterial
			t.ok(material != null and material.next_pass is ShaderMaterial, "%s surface uses a matte library material with ink" % role)
		model.queue_free()
		await t.tree.process_frame
	return true


func test_play_state_accepts_every_combat_spec_name(t) -> bool:
	for role: StringName in CHARACTER_SCENES:
		var scene := load(CHARACTER_SCENES[role]) as PackedScene
		if scene == null:
			continue
		var model := scene.instantiate() as Node3D
		t.tree.root.add_child(model)
		await t.tree.process_frame
		var animation_player := model.get_node_or_null("AnimationPlayer") as AnimationPlayer
		for state: StringName in logical_states[role]:
			model.play_state(state)
			t.ok(animation_player != null and animation_player.is_playing(), "%s plays %s" % [role, state])
			var clip: StringName = model.state_clips.get(state, &"idle")
			var animation := animation_player.get_animation(clip) if animation_player != null else null
			t.ok(_has_skeleton_track(animation), "%s maps %s to CC0 Skeleton3D animation tracks" % [role, state])
		var skeleton := model.find_child("Skeleton3D", true, false) as Skeleton3D
		var upper_leg := skeleton.find_bone(&"LeftUpLeg") if skeleton != null else -1
		var pose_before := skeleton.get_bone_pose(upper_leg) if upper_leg >= 0 else Transform3D.IDENTITY
		animation_player.play(&"run")
		animation_player.seek(0.2, true)
		await t.tree.process_frame
		var pose_after := skeleton.get_bone_pose(upper_leg) if upper_leg >= 0 else Transform3D.IDENTITY
		t.ok(upper_leg >= 0 and pose_before != pose_after, "%s run changes a CC0 Skeleton3D bone pose" % role)
		model.queue_free()
		await t.tree.process_frame
	return true


func _has_skeleton_track(animation: Animation) -> bool:
	if animation == null or animation.get_track_count() == 0:
		return false
	for track_index: int in animation.get_track_count():
		var path := String(animation.track_get_path(track_index))
		if path.contains("Skeleton3D:bones/") and animation.track_get_key_count(track_index) > 1:
			return true
	return false
