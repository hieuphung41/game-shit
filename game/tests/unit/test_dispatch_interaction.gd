extends RefCounted


func test_dispatch_range_uses_horizontal_two_metre_radius(t) -> bool:
	var desk := Vector3(4.0, 0.0, -2.0)
	t.ok(DispatchInteraction.is_in_range(Vector3(6.0, 4.0, -2.0), desk), "vertical offset does not reject a retriever at the radius")
	t.ok(not DispatchInteraction.is_in_range(Vector3(6.01, 0.0, -2.0), desk), "retriever beyond the radius is out of range")
	return true


func test_proximity_zone_uses_the_anchor_position_and_a_sphere_shape(t) -> bool:
	var root := Node3D.new()
	var anchor := Node3D.new()
	anchor.position = Vector3(3.0, 0.0, -5.0)
	root.add_child(anchor)
	var zone := ProximityZone3D.new()
	root.add_child(zone)
	zone.configure(anchor, 2.0)
	t.tree.root.add_child(root)
	await t.tree.process_frame
	var collision := zone.get_node_or_null("CollisionShape3D") as CollisionShape3D
	var sphere := collision.shape as SphereShape3D if collision != null else null
	t.ok(zone.global_position.is_equal_approx(anchor.global_position), "zone follows its world anchor instead of a mesh child")
	t.ok(sphere != null and is_equal_approx(sphere.radius, 2.0), "zone has the configured interaction radius")
	t.eq(zone.collision_mask, 1, "zone detects the Retriever collision layer")
	root.queue_free()
	await t.tree.process_frame
	return true
