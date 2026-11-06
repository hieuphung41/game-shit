extends RefCounted


func test_charge_lane_clamps_progress_and_reveals_chevrons(t) -> bool:
	var scene := load("res://src/vfx/telegraph_charge_lane.tscn") as PackedScene
	if not t.ok(scene != null, "Charge lane scene loads"):
		return true
	var lane := scene.instantiate()
	t.tree.root.add_child(lane)
	await t.tree.process_frame
	lane.set_lane(Vector3(2, 0.1, 3), Vector3(0, 0, 1), 8.0, 1.6)
	lane.set_active(true)
	lane.set_progress(-1.0)
	t.eq(lane.progress, 0.0, "Charge lane clamps negative progress")
	lane.set_progress(2.0)
	t.eq(lane.progress, 1.0, "Charge lane clamps progress above one")
	t.eq(lane.get_node("Chevrons").get_child_count(), 8, "Charge lane has a readable finite chevron sequence")
	lane.queue_free()
	await t.tree.process_frame
	return true


func test_hold_ring_exposes_idempotent_guard_api(t) -> bool:
	var scene := load("res://src/vfx/telegraph_hold_ring.tscn") as PackedScene
	if not t.ok(scene != null, "Hold ring scene loads"):
		return true
	var ring := scene.instantiate()
	t.tree.root.add_child(ring)
	await t.tree.process_frame
	ring.set_radius(2.5)
	for mode: StringName in [&"off", &"patrol", &"hold"]:
		ring.set_mode(mode)
		t.eq(ring.mode, mode, "Hold ring accepts %s mode" % mode)
	ring.show_strike_arc(100.0, 1.8)
	ring.set_strike_progress(0.5)
	t.eq(ring.strike_progress, 0.5, "Hold ring stores clamped strike progress")
	t.ok(ring.get_node("StrikeWedge").visible, "Hold ring fills its strike wedge without blinking")
	ring.hide_strike_arc()
	t.ok(not ring.get_node("StrikeWedge").visible, "Hold ring hides only the strike wedge")
	ring.queue_free()
	await t.tree.process_frame
	return true


func test_lane_alert_counts_three_physical_segments(t) -> bool:
	var scene := load("res://src/vfx/lane_b_alert_lamp.tscn") as PackedScene
	if not t.ok(scene != null, "Lane alert lamp scene loads"):
		return true
	var lamp := scene.instantiate()
	t.tree.root.add_child(lamp)
	await t.tree.process_frame
	lamp.set_state(&"armed")
	lamp.set_progress(0.34)
	t.eq(lamp.opened_segments(), 1, "Armed lamp opens one shutter at progress 0.34")
	lamp.set_progress(1.0)
	t.eq(lamp.opened_segments(), 3, "Armed lamp opens all shutters at progress one")
	lamp.set_state(&"active")
	t.eq(lamp.opened_segments(), 3, "Active lamp holds all three shutters open")
	lamp.queue_free()
	await t.tree.process_frame
	return true
