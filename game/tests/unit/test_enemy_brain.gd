extends RefCounted


class FakeChargeTarget extends Node3D:
	var position_for_combat := Vector3.ZERO
	var next_result := HitResult.new()
	var received_hits: Array[HitInfo] = []
	var combat: RetrieverCombat

	func get_combat_position() -> Vector3:
		return position_for_combat

	func receive_hit(hit: HitInfo) -> HitResult:
		received_hits.append(hit)
		return next_result


func _guard(pool: AttackTokenPool = null, id: int = 1) -> EnemyBrain:
	var brain := EnemyBrain.new(EnemyRoleDef.tax_guard(), pool, id)
	brain.set_position(Vector3.ZERO)
	brain.set_anchor(Vector3.ZERO, Vector3(0.0, 0.0, 2.0))
	brain.facing = Vector3.FORWARD
	return brain


func _advance(brain: EnemyBrain, seconds: float, step: float = 0.05) -> void:
	var remaining := seconds
	while remaining > 0.0001:
		var delta := minf(step, remaining)
		brain.tick(delta)
		remaining -= delta


func test_perception_keeps_last_known_and_requires_arc_or_proximity(t) -> bool:
	var perception := EnemyPerception.new()
	var front := Vector3(0.0, 0.0, -5.0)
	t.ok(perception.tick(0.1, Vector3.ZERO, Vector3.FORWARD, front, true, 6.0, 60.0), "player in the guard sight cone is seen")
	t.eq(perception.last_known_position, front, "sight records a last-known position")
	var behind := Vector3(0.0, 0.0, 5.0)
	perception = EnemyPerception.new()
	t.ok(not perception.tick(0.1, Vector3.ZERO, Vector3.FORWARD, behind, true, 6.0, 60.0), "player behind the guard is not seen outside proximity")
	t.ok(perception.tick(0.1, Vector3.ZERO, Vector3.FORWARD, Vector3(0.0, 0.0, 1.8), true, 6.0, 60.0), "proximity sight bypasses the view arc but still needs LOS")
	perception.tick(4.0, Vector3.ZERO, Vector3.FORWARD, behind, false, 6.0, 60.0)
	t.ok(not perception.sees_player, "four seconds without sight clears tracking")
	return true


func test_guard_telegraphs_before_release_and_needs_camera(t) -> bool:
	var brain := _guard()
	var releases: Array[StringName] = []
	brain.attack_released.connect(func(kind: StringName) -> void: releases.append(kind))
	brain.set_player(Vector3(0.0, 0.0, -1.5), true, false)
	_advance(brain, 3.0)
	t.eq(brain.state, EnemyBrain.STATE_ALERT, "off-camera guard cannot begin windup")
	t.eq(releases.size(), 0, "off-camera guard cannot release a hit")
	brain.set_player(Vector3(0.0, 0.0, -1.5), true, true)
	brain.tick(0.05)
	t.eq(brain.state, EnemyBrain.STATE_WINDUP, "on-camera guard enters windup")
	_advance(brain, 0.75)
	t.eq(releases.size(), 0, "no hit releases before the full 0.8 second telegraph")
	brain.tick(0.05)
	t.eq(releases, [&"guard_strike"], "guard releases exactly after the telegraph")
	t.ok(brain.can_hit_player_at(Vector3(0.0, 0.0, -1.5)), "strike shape includes its declared forward range")
	return true


func test_guard_shield_blocks_front_but_not_side_or_recover(t) -> bool:
	var brain := _guard()
	brain.set_player(Vector3(0.0, 0.0, -4.0), true, true)
	brain.tick(0.05)
	var front := brain.receive_hit(HitInfo.new(3, &"retriever_slash", 20, Vector3(0.0, 0.0, -1.0)))
	t.ok(front.blocked, "guard shield blocks a hit from its front in alert")
	t.eq(front.applied, 0, "shielded front hit does not damage guard")
	var side := brain.receive_hit(HitInfo.new(3, &"retriever_slash", 20, Vector3.RIGHT))
	t.ok(not side.blocked, "shield does not block a side hit")
	t.eq(side.applied, 20, "side hit applies damage")
	brain.state = EnemyBrain.STATE_RECOVER
	var recover := brain.receive_hit(HitInfo.new(3, &"retriever_slash", 20, Vector3(0.0, 0.0, -1.0)))
	t.eq(recover.applied, 20, "recover leaves the front open")
	return true


func test_foreman_charge_locks_lane_and_does_not_hit_a_player_who_leaves(t) -> bool:
	var brain := EnemyBrain.new(EnemyRoleDef.foreman(), null, 2)
	brain.set_position(Vector3.ZERO)
	brain.set_anchor(Vector3.ZERO, Vector3.ZERO)
	brain.set_lane(Vector3.ZERO, Vector3(0.0, 0.0, 9.0))
	brain.set_player(Vector3(0.0, 0.0, 4.0), true, true)
	brain.tick(0.05)
	brain.tick(0.05)
	t.eq(brain.state, EnemyBrain.STATE_WINDUP, "foreman winds up only from an end while player is in lane")
	brain.set_player(Vector3(4.0, 0.0, 4.0), true, true)
	_advance(brain, 1.0)
	t.eq(brain.state, EnemyBrain.STATE_CHARGE, "charge continues along its locked lane after windup")
	t.ok(not brain.can_hit_player_at(Vector3(4.0, 0.0, 4.0)), "player who leaves the lane is outside the charge hitbox")
	_advance(brain, 1.1)
	t.eq(brain.state, EnemyBrain.STATE_RECOVER, "charge slides to its opposite lane endpoint then recovers")
	t.ok(brain.position.distance_to(Vector3(0.0, 0.0, 9.0)) <= 0.1, "foreman stops exactly at the authored opposite endpoint")
	return true


func test_token_allows_only_one_windup_and_invalid_data_is_rejected(t) -> bool:
	var pool := AttackTokenPool.new()
	var first := _guard(pool, 10)
	var second := _guard(pool, 20)
	for brain: EnemyBrain in [first, second]:
		brain.set_player(Vector3(0.0, 0.0, -1.0), true, true)
		brain.tick(0.05)
		brain.tick(0.05)
	var windups := 0
	if first.state == EnemyBrain.STATE_WINDUP:
		windups += 1
	if second.state == EnemyBrain.STATE_WINDUP:
		windups += 1
	t.eq(windups, 1, "one shared attack token permits only one enemy windup")
	var invalid := EnemyRoleDef.tax_guard()
	invalid.windup_seconds = 0.5
	t.ok(not invalid.is_valid(), "role data rejects a windup shorter than the fairness minimum")
	return true


func test_charge_ignored_hits_continue_but_applied_or_blocked_hits_finish(t) -> bool:
	var actor := load("res://src/enemies/foreman.tscn").instantiate() as EnemyActor
	var target := FakeChargeTarget.new()
	t.tree.root.add_child(actor)
	t.tree.root.add_child(target)
	await t.tree.process_frame
	actor.global_position = Vector3.ZERO
	actor.brain.set_position(Vector3.ZERO)
	actor.brain.set_lane(Vector3.ZERO, Vector3(0.0, 0.0, 9.0))
	actor.brain._charge_end = Vector3(0.0, 0.0, 9.0)
	actor.brain.state = EnemyBrain.STATE_CHARGE
	target.position_for_combat = Vector3(0.0, 0.0, 0.2)
	actor._player = target
	for ignored: StringName in [&"iframe", &"post_hit"]:
		target.next_result = HitResult.new(0, false, ignored)
		actor._try_charge_hit()
		t.eq(actor.brain.state, EnemyBrain.STATE_CHARGE, "%s does not end a charge" % ignored)
	target.next_result = HitResult.new(30)
	actor._try_charge_hit()
	t.eq(actor.brain.state, EnemyBrain.STATE_RECOVER, "an applied charge hit ends at the collision")
	actor.queue_free()
	target.queue_free()
	await t.tree.process_frame
	return true


func test_charge_knockback_is_lateral_unblocked_and_forward_when_guarded(t) -> bool:
	var actor := load("res://src/enemies/foreman.tscn").instantiate() as EnemyActor
	var target := FakeChargeTarget.new()
	t.tree.root.add_child(actor)
	t.tree.root.add_child(target)
	await t.tree.process_frame
	actor.global_position = Vector3.ZERO
	actor.brain.set_position(Vector3.ZERO)
	actor.brain.set_lane(Vector3.ZERO, Vector3(0.0, 0.0, 9.0))
	actor.brain._charge_end = Vector3(0.0, 0.0, 9.0)
	actor.brain.state = EnemyBrain.STATE_CHARGE
	actor._player = target
	target.position_for_combat = Vector3(-0.2, 0.0, 0.2)
	target.next_result = HitResult.new(30)
	actor._try_charge_hit()
	var lateral: HitInfo = target.received_hits.back() as HitInfo
	t.eq(lateral.direction, Vector3.LEFT, "an unblocked charge pushes toward the nearest lane side")
	t.eq(lateral.knockback_m, 2.0, "an unblocked charge uses its two metre lateral knockback")
	actor.brain.state = EnemyBrain.STATE_CHARGE
	target.combat = RetrieverCombat.new()
	target.combat.position = target.position_for_combat
	target.combat.facing = Vector3(1.0, 0.0, -1.0).normalized()
	target.combat.state = RetrieverCombat.STATE_GUARDING
	target.combat._action_elapsed = target.combat.tuning.guard_raise
	target.next_result = HitResult.new(9, true)
	actor._try_charge_hit()
	var guarded: HitInfo = target.received_hits.back() as HitInfo
	t.eq(guarded.direction, Vector3.BACK, "a raised guard keeps the authored forward charge direction")
	t.eq(guarded.knockback_m, 1.5, "a guarded charge uses 1.5 metre forward knockback")
	actor.queue_free()
	target.queue_free()
	await t.tree.process_frame
	return true


func test_downed_actor_leaves_combat_target_group_and_disables_collision(t) -> bool:
	var actor := load("res://src/enemies/tax_guard.tscn").instantiate() as EnemyActor
	t.tree.root.add_child(actor)
	await t.tree.process_frame
	actor.brain.health.damage(999)
	await t.tree.process_frame
	t.eq(actor.collision_layer, 0, "downed enemy has no player collision layer")
	t.eq(actor.collision_mask, 0, "downed enemy no longer scans player collision")
	t.ok(not actor.is_in_group(&"combat_targets"), "downed enemy cannot be selected as a combat target")
	var shape := actor.get_node("CollisionShape3D") as CollisionShape3D
	t.ok(shape.disabled, "downed enemy body collision is disabled")
	actor.queue_free()
	await t.tree.process_frame
	return true
