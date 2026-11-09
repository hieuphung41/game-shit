extends RefCounted

const BOOT_SCENE_PATH := "res://src/boot/boot.tscn"
const PLAYER_SCENE_PATH := "res://src/player/retriever.tscn"
const TOUCH_JOYSTICK_SCENE_PATH := "res://src/ui/touch/touch_joystick.tscn"
const WORLD_SCENE_PATH := "res://src/world/zone_a_outer_pier.tscn"
const ZONE_D_SCENE_PATH := "res://src/world/zone_d_floating_warehouse.tscn"
const FLOOR_SAFETY_SCRIPT := preload("res://src/world/world_floor_safety.gd")
const ZONE_D_WORLD_POSITION := Vector3(11.75, 0.0, -36.95)
const FLOOR_SAFETY_MOVE_FRAMES := 16


func test_retriever_movement_converts_input_to_isometric_camera_axes(t) -> bool:
	var camera_basis := Basis.from_euler(Vector3(deg_to_rad(-30.0), deg_to_rad(45.0), 0.0))
	var forward := RetrieverMovement.camera_relative_direction(Vector2(0.0, -1.0), camera_basis)
	var right := RetrieverMovement.camera_relative_direction(Vector2.RIGHT, camera_basis)
	t.ok(is_zero_approx(forward.y), "forward input stays on the ground plane")
	t.ok(absf(forward.length() - 1.0) < 0.001, "full joystick input keeps full movement magnitude")
	t.ok(forward.x < -0.69 and forward.z < -0.69, "upward joystick movement follows the isometric camera forward")
	t.ok(right.x > 0.69 and right.z < -0.69, "rightward joystick movement follows the isometric camera right")
	for stick_direction: Vector2 in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2(1.0, -1.0).normalized(), Vector2(1.0, 1.0).normalized(), Vector2(-1.0, 1.0).normalized(), Vector2(-1.0, -1.0).normalized()]:
		var world_direction := RetrieverMovement.camera_relative_direction(stick_direction, camera_basis)
		var screen_direction := RetrieverMovement.screen_direction_for_world_direction(world_direction, camera_basis)
		t.ok(_matches_screen_direction(screen_direction, stick_direction), "joystick %s moves in the same screen direction" % stick_direction)
	return true


func test_touch_joystick_logic_has_a_deadzone_and_clamped_range(t) -> bool:
	var region := Vector2(260.0, 260.0)
	var resting := TouchJoystickLogic.direction_for_local_position(Vector2(130.0, 130.0), region)
	var edge := TouchJoystickLogic.direction_for_local_position(Vector2(390.0, 130.0), region)
	t.eq(resting, Vector2.ZERO, "joystick center is inside the deadzone")
	t.ok(absf(edge.length() - 1.0) < 0.001, "joystick direction is capped at one")
	t.ok(edge.x > 0.99 and is_zero_approx(edge.y), "joystick direction preserves touch direction")
	return true


func test_touch_joystick_screen_coordinates_match_across_viewports(t) -> bool:
	var relative_drag := Vector2(92.0, -68.0)
	var direction_16_9 := await _touch_direction_for_viewport(t.tree, Vector2i(1280, 720), Vector2(1280.0, 720.0), Vector2.ONE, relative_drag)
	var direction_20_9 := await _touch_direction_for_viewport(t.tree, Vector2i(2400, 1080), Vector2(1600.0, 720.0), Vector2(1.5, 1.5), relative_drag)
	var direction_4_3 := await _touch_direction_for_viewport(t.tree, Vector2i(960, 720), Vector2(960.0, 720.0), Vector2.ONE, relative_drag)
	var expected := TouchJoystickLogic.direction_for_local_position(Vector2(130.0, 130.0) + relative_drag, Vector2(260.0, 260.0))
	t.ok(direction_16_9.is_equal_approx(expected), "a real joystick Control receives the expected relative drag at 1280x720")
	t.ok(direction_16_9.is_equal_approx(direction_20_9), "the same relative drag has the same direction at 2400x1080 with expanded canvas scaling")
	t.ok(direction_16_9.is_equal_approx(direction_4_3), "the same relative drag has the same direction at 960x720 (4:3)")
	t.ok(direction_16_9.x > 0.0 and direction_16_9.y < 0.0, "the transformed drag remains up-right")
	return true


func _touch_direction_for_viewport(tree: SceneTree, physical_size: Vector2i, canvas_size: Vector2, canvas_scale: Vector2, relative_drag: Vector2) -> Vector2:
	var viewport := SubViewport.new()
	viewport.size = physical_size
	tree.root.add_child(viewport)
	var canvas := Control.new()
	canvas.size = canvas_size
	canvas.scale = canvas_scale
	viewport.add_child(canvas)
	var joystick := (load(TOUCH_JOYSTICK_SCENE_PATH) as PackedScene).instantiate() as TouchJoystick
	canvas.add_child(joystick)
	joystick.position = Vector2(16.0, canvas_size.y - 276.0)
	joystick.size = Vector2(260.0, 260.0)
	await tree.process_frame
	var canvas_transform := joystick.get_global_transform_with_canvas()
	_send_joystick_touch(joystick, 7, canvas_transform * (joystick.size * 0.5), true)
	_send_joystick_drag(joystick, 7, canvas_transform * (joystick.size * 0.5 + relative_drag))
	var drag_direction := joystick._direction
	_send_joystick_touch(joystick, 7, canvas_transform * (joystick.size * 0.5 + relative_drag), false)
	viewport.queue_free()
	await tree.process_frame
	return drag_direction


func _send_joystick_touch(joystick: TouchJoystick, index: int, position: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	joystick._gui_input(event)


func _send_joystick_drag(joystick: TouchJoystick, index: int, position: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = position
	joystick._gui_input(event)


func test_touch_joystick_keeps_its_claimed_pointer(t) -> bool:
	var active_pointer := TouchJoystickLogic.claim_pointer(TouchJoystickLogic.NO_ACTIVE_POINTER, 4)
	t.eq(active_pointer, 4, "the first touch claims the joystick")
	active_pointer = TouchJoystickLogic.claim_pointer(active_pointer, TouchJoystickLogic.MOUSE_POINTER)
	t.eq(active_pointer, 4, "mouse emulation cannot replace a real touch drag")
	active_pointer = TouchJoystickLogic.release_pointer(active_pointer, TouchJoystickLogic.MOUSE_POINTER)
	t.eq(active_pointer, 4, "an unrelated mouse release cannot stop the touch drag")
	active_pointer = TouchJoystickLogic.release_pointer(active_pointer, 4)
	t.eq(active_pointer, TouchJoystickLogic.NO_ACTIVE_POINTER, "releasing the owning touch stops the joystick")
	return true


func test_retriever_scene_has_character_body_and_one_hand_touch_joystick(t) -> bool:
	var scene := load(PLAYER_SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "Retriever scene loads"):
		return true
	var retriever := scene.instantiate()
	t.ok(retriever is CharacterBody3D, "Retriever uses CharacterBody3D")
	t.eq(retriever.get_meta("greybox_status", ""), "placeholder", "Retriever is explicitly marked as a greybox placeholder")
	t.ok(retriever.get_node_or_null("CollisionShape3D") is CollisionShape3D, "Retriever has a collision shape")
	t.ok(retriever.get_node_or_null("Visual") is Node3D, "Retriever exposes the Visual animation slot")
	var body := retriever.get_node_or_null("Body") as MeshInstance3D
	var body_material := body.material_override as ShaderMaterial if body != null else null
	t.ok(body_material != null and body_material.next_pass is ShaderMaterial, "Retriever material includes the required ink outline pass")
	var joystick := retriever.get_node_or_null("TouchControls/TouchJoystick") as Control
	t.ok(joystick != null, "Retriever has a touch-first joystick")
	if joystick != null:
		t.ok(joystick.custom_minimum_size.x >= 240.0, "joystick touch region is large enough for one hand")
	retriever.queue_free()
	return true


func test_wasd_actions_keep_the_desktop_secondary_control(t) -> bool:
	t.ok(_action_has_physical_key(&"move_left", KEY_A), "move_left is bound to physical A")
	t.ok(_action_has_physical_key(&"move_right", KEY_D), "move_right is bound to physical D")
	t.ok(_action_has_physical_key(&"move_up", KEY_W), "move_up is bound to physical W")
	t.ok(_action_has_physical_key(&"move_down", KEY_S), "move_down is bound to physical S")
	return true


func test_combat_actions_have_required_keyboard_and_gamepad_bindings(t) -> bool:
	t.ok(_action_has_physical_key(&"combat_attack", KEY_J), "combat_attack is bound to physical J")
	t.ok(_action_has_physical_key(&"combat_dodge", KEY_SPACE), "combat_dodge is bound to physical Space")
	t.ok(_action_has_physical_key(&"combat_guard", KEY_K), "combat_guard is bound to physical K")
	t.ok(_action_has_physical_key(&"use_remedy", KEY_Q), "use_remedy is bound to physical Q")
	t.ok(_action_has_joy_button(&"combat_attack", JOY_BUTTON_X), "combat_attack has X")
	t.ok(_action_has_joy_button(&"combat_dodge", JOY_BUTTON_A), "combat_dodge has A")
	t.ok(_action_has_joy_button(&"combat_guard", JOY_BUTTON_RIGHT_SHOULDER), "combat_guard has RB")
	t.ok(_action_has_joy_button(&"use_remedy", JOY_BUTTON_Y), "use_remedy has Y")
	return true


func test_combat_motion_velocity_uses_the_actual_physics_delta(t) -> bool:
	var velocity := RetrieverController.motion_velocity_for(Vector3.RIGHT, 0.20)
	t.eq(velocity, Vector3(5.0, 0.0, 0.0), "a 1 m clamped displacement is spread over the real 0.2 second physics frame")
	t.eq(velocity * 0.20, Vector3.RIGHT, "the physics integration applies exactly the clamped displacement")
	return true


func test_retriever_floor_safety_keeps_eight_directions_inside_each_playable_zone(t) -> bool:
	var fixture := await _create_floor_safety_fixture(t)
	if fixture.is_empty():
		return true
	var world := fixture[&"world"] as Node3D
	var retriever := fixture[&"retriever"] as RetrieverController
	var safety := fixture[&"safety"] as WorldFloorSafety
	var directions := [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2(1.0, -1.0).normalized(), Vector2(1.0, 1.0).normalized(), Vector2(-1.0, 1.0).normalized(), Vector2(-1.0, -1.0).normalized()]
	var zone_centres := {
		"A": Vector3(0.0, 0.95, 0.0),
		"B": Vector3(11.5, 0.95, -18.0),
		"D": Vector3(11.5, 0.95, -44.0),
	}
	for zone_name: String in zone_centres:
		var start := zone_centres[zone_name] as Vector3
		for direction: Vector2 in directions:
			retriever.global_position = start
			retriever.enforce_floor_safety()
			retriever._on_touch_direction_changed(direction)
			for _frame in FLOOR_SAFETY_MOVE_FRAMES:
				await t.tree.physics_frame
			t.ok(safety.is_safe(retriever.global_position), "%s edge input %s keeps the moving Retriever inside a playable floor polygon" % [zone_name, direction])
		retriever._on_touch_direction_changed(Vector2.ZERO)
	world.queue_free()
	await t.tree.process_frame
	return true


func test_retriever_floor_safety_restores_last_safe_point_after_a_fall(t) -> bool:
	var fixture := await _create_floor_safety_fixture(t)
	if fixture.is_empty():
		return true
	var world := fixture[&"world"] as Node3D
	var retriever := fixture[&"retriever"] as RetrieverController
	var safety := fixture[&"safety"] as WorldFloorSafety
	var last_safe := Vector3(11.5, 0.95, -18.0)
	retriever.global_position = last_safe
	retriever.enforce_floor_safety()
	retriever.global_position = Vector3(11.75, 0.95, -36.0)
	t.ok(not safety.is_safe(retriever.global_position), "closed Route D bridge is water, not a safe floor polygon")
	t.ok(retriever.enforce_floor_safety(), "controller immediately recovers a forced position on the closed Route D bridge")
	t.eq(retriever.global_position, last_safe, "closed Route D bridge restores the prior safe market floor")
	retriever.global_position = Vector3(40.0, -1.0, 40.0)
	t.ok(retriever.enforce_floor_safety(), "controller recovers a forced fall within one physics update")
	t.eq(retriever.global_position, last_safe, "a fall or off-floor position returns to the most recent safe point without mutating run state")
	world.queue_free()
	await t.tree.process_frame
	return true


func _create_floor_safety_fixture(t) -> Dictionary:
	var world_scene := load(WORLD_SCENE_PATH) as PackedScene
	var zone_d_scene := load(ZONE_D_SCENE_PATH) as PackedScene
	var retriever_scene := load(PLAYER_SCENE_PATH) as PackedScene
	if not t.ok(world_scene != null and zone_d_scene != null and retriever_scene != null, "A, B, D, and Retriever scenes load for floor-safety integration"):
		return {}
	var world := world_scene.instantiate() as Node3D
	var zone_d := zone_d_scene.instantiate() as Node3D
	zone_d.position = ZONE_D_WORLD_POSITION
	world.add_child(zone_d)
	var retriever := retriever_scene.instantiate() as RetrieverController
	retriever.movement_speed = 80.0
	var safety := FLOOR_SAFETY_SCRIPT.create_vertical_slice() as WorldFloorSafety
	retriever.set_floor_safety(safety)
	world.add_child(retriever)
	t.tree.root.add_child(world)
	await t.tree.process_frame
	await t.tree.physics_frame
	return {&"world": world, &"retriever": retriever, &"safety": safety}


func test_outer_pier_overlay_bridge_cancels_guard_and_remedy(t) -> bool:
	var retriever := (load(PLAYER_SCENE_PATH) as PackedScene).instantiate() as RetrieverController
	var bridge := OuterPierRun.new()
	t.tree.root.add_child(retriever)
	await t.tree.process_frame
	bridge._retriever = retriever
	retriever.press_combat_action(&"combat_guard")
	retriever.combat.tick(0.10)
	bridge._set_retriever_overlay_open(true)
	t.eq(retriever.combat.state, RetrieverCombat.STATE_FREE, "opening an overlay through the run lowers guard")
	bridge._set_retriever_overlay_open(false)
	var inventory := _combat_inventory()
	retriever.set_inventory(inventory)
	retriever.combat.health.damage(20)
	retriever.press_combat_action(&"use_remedy")
	t.eq(retriever.combat.state, RetrieverCombat.STATE_USING_REMEDY, "remedy channel starts before overlay opens")
	bridge._set_retriever_overlay_open(true)
	t.eq(retriever.combat.state, RetrieverCombat.STATE_FREE, "opening an overlay through the run cancels remedy")
	t.ok(inventory.sling_pouch.items.has(1), "cancelled remedy remains in the sling pouch")
	retriever.queue_free()
	await t.tree.process_frame
	return true


func _combat_inventory() -> RetrieverInventory:
	var registry := ItemRegistry.new()
	registry.add(SlingRemedyDefinition.new())
	var inventory := RetrieverInventory.new(registry)
	inventory.load_snapshot({"backpack": [], "notary_box": [], "sling_pouch": [{"uid": 1, "def_id": &"sling_remedy", "quantity": 1, "anchor": Vector2i.ZERO, "rotated": false}]})
	return inventory


func test_retriever_follow_keeps_isometric_rotation_and_beacon_in_frame_at_dispatch(t) -> bool:
	var world_scene := load(WORLD_SCENE_PATH) as PackedScene
	var player_scene := load(PLAYER_SCENE_PATH) as PackedScene
	if not t.ok(world_scene != null and player_scene != null, "world and Retriever scenes load"):
		return true
	var world := world_scene.instantiate()
	var retriever := player_scene.instantiate() as CharacterBody3D
	world.add_child(retriever)
	t.tree.root.add_child(world)
	await t.tree.process_frame
	var camera := world.get_node_or_null("CameraIsometric") as Camera3D
	var dispatch := world.get_node_or_null("DispatchDesk") as Node3D
	var beacon := world.get_node_or_null("BeaconA") as Node3D
	if not t.ok(camera != null, "Zone A requires CameraIsometric"):
		world.queue_free()
		return true
	if not t.ok(dispatch != null, "Zone A requires DispatchDesk"):
		world.queue_free()
		return true
	if not t.ok(beacon != null, "Zone A requires BeaconA"):
		world.queue_free()
		return true
	var expected_offset := camera.global_position - retriever.global_position
	retriever.global_position = dispatch.global_position + Vector3(0.0, 0.95, 0.0)
	await t.tree.physics_frame
	await t.tree.process_frame
	t.ok(
		camera.global_position.is_equal_approx(retriever.global_position + expected_offset),
		"camera follows the Retriever by its original offset"
	)
	t.eq(roundi(camera.rotation_degrees.x), -30, "camera follow keeps fixed isometric pitch")
	t.eq(roundi(camera.rotation_degrees.y), 45, "camera follow keeps fixed isometric yaw")
	t.ok(camera.is_position_in_frustum(beacon.global_position), "beacon A remains visible from dispatch")
	world.queue_free()
	await t.tree.process_frame
	return true


func _action_has_physical_key(action: StringName, expected_key: Key) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == expected_key:
			return true
	return false


func _matches_screen_direction(actual: Vector2, expected: Vector2) -> bool:
	var epsilon := 0.001
	if absf(expected.x) <= epsilon:
		if absf(actual.x) > epsilon:
			return false
	elif signf(actual.x) != signf(expected.x):
		return false
	if absf(expected.y) <= epsilon:
		return absf(actual.y) <= epsilon
	return signf(actual.y) == signf(expected.y)


func _action_has_joy_button(action: StringName, expected_button: JoyButton) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and event.button_index == expected_button:
			return true
	return false


func test_boot_offers_outer_pier_entry(t) -> bool:
	var scene := load(BOOT_SCENE_PATH) as PackedScene
	if not t.ok(scene != null, "boot scene loads"):
		return true
	var original_channel := AppEnv.channel
	t.eq(AppEnv.load_for("staging"), OK, "staging configuration loads")
	var boot := scene.instantiate()
	t.tree.root.add_child(boot)
	await t.tree.process_frame
	var enter_button := boot.get_node_or_null("EnterOuterPierButton") as Button
	var env_badge := boot.get_node_or_null("EnvBadge") as Label
	t.ok(enter_button != null, "boot includes the outer-pier entry button")
	t.ok(env_badge != null and env_badge.visible, "staging keeps the environment badge visible")
	if env_badge != null:
		t.eq(env_badge.text, "STAGING", "staging badge identifies the build channel")
	if enter_button != null:
		t.eq(enter_button.text, "Vào Bến Ngoài (thử nghiệm)", "entry uses the approved Vietnamese label")
		enter_button.grab_focus()
		t.ok(enter_button.has_focus(), "desktop keyboard can focus the entry button")
		t.ok(enter_button.pressed.is_connected(Callable(boot, &"_on_enter_outer_pier_pressed")), "entry button is connected to the Zone A transition")
		enter_button.pressed.emit()
		await t.tree.process_frame
		var briefing_flow := t.tree.current_scene as BriefingFlow
		t.ok(briefing_flow != null, "entry button changes to the briefing flow")
		if briefing_flow != null:
			t.ok(briefing_flow.get_node_or_null("Briefing") is BriefingScreen, "briefing is shown before Zone A")
			var briefing := briefing_flow.get_node_or_null("Briefing") as BriefingScreen
			var enter := _button_with_text(briefing, "BRIEFING_BUTTON_ENTER")
			t.ok(enter != null and not enter.disabled, "briefing entry remains interactive after Boot creates the session")
			var edit_loadout := _button_with_text(briefing, "BRIEFING_BUTTON_EDIT_LOADOUT")
			t.ok(edit_loadout != null and not edit_loadout.disabled, "briefing includes an interactive loadout button")
			if edit_loadout != null:
				briefing._opened_at_msec = -1000
				edit_loadout.pressed.emit()
				await t.tree.process_frame
				var loadout := briefing_flow.get_node_or_null("Loadout") as LoadoutScreen
				var done := _button_with_text(loadout, "LOADOUT_BUTTON_DONE")
				t.ok(done != null and not done.disabled, "loadout opens with its completion button")
			briefing_flow.queue_free()
	if is_instance_valid(boot):
		boot.queue_free()
	await t.tree.process_frame
	RunSession.clear()
	AppEnv.load_for(original_channel)
	return true


func _button_with_text(parent: Control, key: String) -> Button:
	if parent == null:
		return null
	for child in parent.get_children():
		var button := child as Button
		if button != null and button.text == tr(key):
			return button
	return null
