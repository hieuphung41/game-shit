extends RefCounted


func test_patrol_cue_waits_two_seconds_before_the_brain_is_started(t) -> bool:
	var patrol := PatrolReturn.new()
	t.tree.root.add_child(patrol)
	await t.tree.process_frame
	var cues: Array[int] = []
	patrol.patrol_cue_started.connect(func() -> void: cues.append(1))
	patrol.activate()
	patrol.tick(1.95)
	t.eq(cues.size(), 1, "patrol announces its cue immediately")
	patrol.tick(0.04)
	t.eq(cues.size(), 1, "the cue is not repeated while waiting")
	patrol.tick(0.01)
	t.eq(cues.size(), 1, "patrol cue has the authored two-second lead")
	var hitch_patrol := PatrolReturn.new()
	t.tree.root.add_child(hitch_patrol)
	await t.tree.process_frame
	hitch_patrol.activate()
	hitch_patrol.tick(2.1)
	t.eq(hitch_patrol._elapsed, EnemyBrain.MAX_TICK_DELTA, "a hitch advances the cue by at most one fixed step")
	hitch_patrol.queue_free()
	patrol.queue_free()
	await t.tree.process_frame
	return true


func test_hold_director_shares_one_token_pool_across_both_spawned_enemies(t) -> bool:
	var director := HoldLaneBDirector.new()
	t.tree.root.add_child(director)
	await t.tree.process_frame
	director.on_hold_started(20.0)
	t.eq(director._enemies.size(), 2, "hold prepares exactly its guard and foreman")
	var guard := director._enemies[0]
	var foreman := director._enemies[1]
	t.ok(guard.attack_tokens == foreman.attack_tokens, "both hold enemies receive the director-owned token pool before ready")
	for brain: EnemyBrain in [guard.brain, foreman.brain]:
		brain.set_position(Vector3.ZERO)
		brain.set_player(Vector3(0.0, 0.0, -1.5), true, true)
	guard.brain.facing = Vector3.FORWARD
	foreman.brain.set_lane(Vector3.ZERO, Vector3(0.0, 0.0, -9.0))
	guard.brain.tick(0.05)
	foreman.brain.tick(0.05)
	guard.brain.tick(0.05)
	foreman.brain.tick(0.05)
	var windups := 0
	for brain: EnemyBrain in [guard.brain, foreman.brain]:
		if brain.state == EnemyBrain.STATE_WINDUP:
			windups += 1
	t.eq(windups, 1, "one shared hold-wave token allows only one simultaneous windup")
	for enemy: EnemyActor in director._enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	director.queue_free()
	await t.tree.process_frame
	return true


func test_hold_director_emits_entry_only_after_actor_crosses_camera_inset(t) -> bool:
	var root := Node3D.new()
	var spawn := Marker3D.new()
	spawn.name = "Spawn"
	spawn.position = Vector3(0.0, 0.0, 2.0)
	root.add_child(spawn)
	var path := Node3D.new()
	path.name = "Path"
	var entry := Marker3D.new()
	entry.position = Vector3(0.0, 0.0, -1.0)
	path.add_child(entry)
	root.add_child(path)
	var post := Marker3D.new()
	post.name = "Post"
	post.position = Vector3(0.0, 0.0, -2.0)
	root.add_child(post)
	var lane := Node3D.new()
	lane.name = "Lane"
	var end_a := Marker3D.new()
	end_a.name = "end_a"
	end_a.position = Vector3(0.0, 0.0, -2.0)
	lane.add_child(end_a)
	var end_b := Marker3D.new()
	end_b.name = "end_b"
	end_b.position = Vector3(0.0, 0.0, -4.0)
	lane.add_child(end_b)
	root.add_child(lane)
	var director := HoldLaneBDirector.new()
	director.spawn_parent_path = NodePath("..")
	director.spawn_marker_path = NodePath("../Spawn")
	director.hold_path_root = NodePath("../Path")
	director.hold_guard_post_path = NodePath("../Post")
	director.hold_charge_lane_path = NodePath("../Lane")
	director.camera_entry_predicate = func(enemy: EnemyActor) -> bool: return enemy.global_position.z < 0.0
	root.add_child(director)
	t.tree.root.add_child(root)
	await t.tree.process_frame
	var entry_positions: Array[float] = []
	director.enemy_entered_camera.connect(func(_role_id: StringName) -> void: entry_positions.append(director._enemies[entry_positions.size()].global_position.z))
	director.on_hold_started(20.0)
	t.ok(director._enemies[0].global_position.z >= 0.0, "hold actor begins at the authored off-camera spawn marker")
	director._enemies[0].global_position = Vector3(0.0, 0.0, -0.1)
	director._enemies[0].brain.set_position(director._enemies[0].global_position)
	director.tick(0.1)
	t.ok(not entry_positions.is_empty(), "a hold enemy physically crosses the camera inset")
	for position_z: float in entry_positions:
		t.ok(position_z < 0.0, "entry signal is emitted only after the physical inset predicate becomes true")
	root.queue_free()
	await t.tree.process_frame
	return true


func test_enemy_scenes_have_visual_slots_and_load(t) -> bool:
	for path: String in ["res://src/enemies/tax_guard.tscn", "res://src/enemies/foreman.tscn"]:
		var scene := load(path) as PackedScene
		if not t.ok(scene != null, "%s loads" % path):
			continue
		var enemy := scene.instantiate() as EnemyActor
		t.tree.root.add_child(enemy)
		await t.tree.process_frame
		t.ok(enemy.get_node_or_null("Visual") is Node3D, "%s exposes an optional Visual slot" % path)
		t.ok(enemy.brain != null, "%s creates its pure brain" % path)
		enemy.queue_free()
		await t.tree.process_frame
	return true
