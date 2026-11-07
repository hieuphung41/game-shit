class_name EnemyActor
extends CharacterBody3D
## Thin scene adapter: it supplies perception/collision and plays the pure brain's intent.

@export var role_def: EnemyRoleDef
@export var player_path: NodePath
@export var home_path: NodePath
@export var withdraw_path: NodePath
@export var lane_path: NodePath
var attack_tokens: AttackTokenPool

@onready var _visual: Node = get_node_or_null("Visual")
@onready var _hold_ring: Node = get_node_or_null("HoldRing")
@onready var _charge_stripe: Node = get_node_or_null("ChargeStripe")

var brain: EnemyBrain
var _perception_accumulator := 0.0
var _cached_los := false
var _player: Node


func _ready() -> void:
	if role_def == null or not role_def.is_valid():
		push_error("EnemyActor needs a valid EnemyRoleDef")
		return
	brain = EnemyBrain.new(role_def, attack_tokens, get_instance_id())
	brain.set_position(global_position)
	brain.set_anchor(_marker_position(home_path, global_position), _marker_position(withdraw_path, global_position))
	_configure_lane_from_scene()
	brain.state_changed.connect(_on_state_changed)
	brain.attack_released.connect(_on_attack_released)
	brain.alerted.connect(_on_alerted)
	brain.downed.connect(_on_downed)
	add_to_group(&"combat_targets")
	_refresh_hold_ring()


func _physics_process(delta: float) -> void:
	if brain == null:
		return
	_update_perception(delta)
	brain.tick(delta)
	velocity = brain.motion_delta / delta if delta > 0.0 else Vector3.ZERO
	velocity.y = 0.0
	move_and_slide()
	brain.set_position(global_position)
	if brain.state == EnemyBrain.STATE_CHARGE:
		_try_charge_hit()
		if is_on_wall() and brain.state == EnemyBrain.STATE_CHARGE:
			brain.charge_hit(false)
	_refresh_telegraph()


func configure_anchor(home: Vector3, withdraw: Vector3) -> void:
	if brain != null:
		brain.set_anchor(home, withdraw)


func configure_lane(end_a: Vector3, end_b: Vector3) -> void:
	if brain != null:
		brain.set_lane(end_a, end_b)
	if _charge_stripe != null:
		var direction := end_b - end_a
		_charge_stripe.call(&"set_lane", end_a, direction, direction.length(), role_def.lane_width)


func begin_patrol(points: Array[Vector3]) -> void:
	if brain != null:
		brain.start_patrol(points)


func force_withdraw() -> void:
	if brain != null:
		brain.stop_new_windups()


func is_lane_pressure_resolved() -> bool:
	return brain != null and brain.is_lane_pressure_resolved()


func receive_hit(hit: HitInfo) -> HitResult:
	return brain.receive_hit(hit) if brain != null else HitResult.new(0, false, &"depleted")


func get_team() -> StringName:
	return EnemyBrain.TEAM_ENEMY


func get_combat_position() -> Vector3:
	return global_position


func get_combat_state() -> StringName:
	return brain.get_combat_state() if brain != null else EnemyBrain.STATE_DOWN


func is_inside_camera_inset() -> bool:
	return _inside_camera_inset()


func _update_perception(delta: float) -> void:
	_player = get_node_or_null(player_path) if not player_path.is_empty() else _player_from_group()
	if _player == null or not _player.has_method(&"get_combat_position"):
		brain.set_player(global_position, false, false)
		return
	var player_position: Vector3 = _player.call(&"get_combat_position")
	_perception_accumulator += delta
	if _perception_accumulator >= 0.1:
		_perception_accumulator = 0.0
		_cached_los = _has_line_of_sight(player_position)
	var seen := brain.perception.tick(delta, global_position, brain.facing, player_position, _cached_los, role_def.perception_radius, role_def.view_half_arc_deg)
	brain.set_player(player_position, seen, _inside_camera_inset())


func _has_line_of_sight(player_position: Vector3) -> bool:
	var origin := global_position + Vector3.UP * 1.5
	var target := player_position + Vector3.UP
	if origin.distance_to(target) > role_def.perception_radius and origin.distance_to(target) > EnemyPerception.PROXIMITY_RADIUS:
		return false
	var query := PhysicsRayQueryParameters3D.create(origin, target, 2)
	query.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _inside_camera_inset() -> bool:
	var camera := get_viewport().get_camera_3d()
	if camera == null or camera.is_position_behind(global_position) or not camera.is_position_in_frustum(global_position):
		return false
	var rect := get_viewport().get_visible_rect()
	var inset := Rect2(rect.position + rect.size * 0.05, rect.size * 0.90)
	return inset.has_point(camera.unproject_position(global_position))


func _try_charge_hit() -> void:
	if _player == null or not _player.has_method(&"get_combat_position") or not _player.has_method(&"receive_hit"):
		return
	var target_position: Vector3 = _player.call(&"get_combat_position")
	if not brain.can_hit_player_at(target_position):
		return
	var blocked := _player_will_block_charge()
	var direction := brain.facing if blocked else _nearest_charge_lateral_direction(target_position)
	var knockback := 1.5 if blocked else 2.0
	var hit := HitInfo.new(get_instance_id(), &"foreman_charge", role_def.damage, global_position, direction, knockback, true)
	var result: HitResult = _player.call(&"receive_hit", hit)
	# I-frame, post-hit and depleted results do not stop a lane charge. A real hit
	# or a raised guard is the only player interaction that ends it early.
	if result.applied > 0 or result.blocked:
		brain.charge_hit(result.blocked)


func _on_attack_released(kind: StringName) -> void:
	if kind != &"guard_strike" or _player == null or not _player.has_method(&"get_combat_position") or not _player.has_method(&"receive_hit"):
		return
	if brain.can_hit_player_at(_player.call(&"get_combat_position")):
		_player.call(&"receive_hit", HitInfo.new(get_instance_id(), kind, role_def.damage, global_position, brain.facing, 0.0, true))


func _on_alerted() -> void:
	_refresh_hold_ring()
	if role_def.role_id == &"foreman" and _charge_stripe != null:
		_charge_stripe.call(&"set_active", true)
		_charge_stripe.call(&"set_progress", 0.0)


func _on_state_changed(state: StringName) -> void:
	_play_visual(state)
	_refresh_hold_ring()
	_refresh_telegraph()


func _on_downed() -> void:
	velocity = Vector3.ZERO
	remove_from_group(&"combat_targets")
	collision_layer = 0
	collision_mask = 0
	var body_shape := get_node_or_null("CollisionShape3D") as CollisionShape3D
	if body_shape != null:
		body_shape.set_deferred(&"disabled", true)


func _refresh_telegraph() -> void:
	if brain == null:
		return
	if _hold_ring != null:
		if brain.state == EnemyBrain.STATE_WINDUP and role_def.role_id == &"tax_guard":
			_hold_ring.call(&"show_strike_arc", role_def.attack_arc_deg, role_def.attack_range)
			_hold_ring.call(&"set_strike_progress", brain.windup_progress())
		elif role_def.role_id == &"tax_guard":
			_hold_ring.call(&"hide_strike_arc")
	if _charge_stripe != null and role_def.role_id == &"foreman":
		if brain.state == EnemyBrain.STATE_WINDUP:
			_charge_stripe.call(&"set_active", true)
			_charge_stripe.call(&"set_progress", brain.windup_progress())
		elif brain.state == EnemyBrain.STATE_CHARGE:
			_charge_stripe.call(&"set_active", true)
			_charge_stripe.call(&"set_progress", 1.0)
		elif brain.state in [EnemyBrain.STATE_RECOVER, EnemyBrain.STATE_WITHDRAW, EnemyBrain.STATE_DOWN, EnemyBrain.STATE_WITHDRAWN]:
			_charge_stripe.call(&"set_active", false)


func _refresh_hold_ring() -> void:
	if _hold_ring == null or role_def == null or role_def.role_id != &"tax_guard":
		return
	_hold_ring.call(&"set_radius", 2.5)
	_hold_ring.call(&"set_mode", &"patrol" if brain != null and brain.state == EnemyBrain.STATE_PATROL else &"hold")


func _play_visual(state: StringName) -> void:
	if _visual == null or not _visual.has_method(&"play_state"):
		return
	var logical := state
	if state == EnemyBrain.STATE_WINDUP:
		logical = &"windup"
	elif state == EnemyBrain.STATE_STRIKE:
		logical = &"strike"
	_visual.call(&"play_state", logical)


func _configure_lane_from_scene() -> void:
	var lane := get_node_or_null(lane_path) as Node3D
	if lane == null:
		return
	var end_a := lane.get_node_or_null("end_a") as Node3D
	var end_b := lane.get_node_or_null("end_b") as Node3D
	if end_a != null and end_b != null:
		configure_lane(end_a.global_position, end_b.global_position)


func _marker_position(path: NodePath, fallback: Vector3) -> Vector3:
	var marker := get_node_or_null(path) as Node3D
	return marker.global_position if marker != null else fallback


func _player_from_group() -> Node:
	var candidates := get_tree().get_nodes_in_group(&"retriever")
	return candidates.front() as Node if not candidates.is_empty() else null


func _player_will_block_charge() -> bool:
	# CombatTarget only reports block after applying a hit. The player controller
	# exposes its existing combat object, so choose the authored guard knockback
	# before dispatch without applying a second zero-damage hit.
	if _player == null:
		return false
	var combat: Variant = _player.get(&"combat")
	if not (combat is RetrieverCombat):
		return false
	var retriever_combat := combat as RetrieverCombat
	return retriever_combat.state == RetrieverCombat.STATE_GUARDING \
		and retriever_combat._action_elapsed >= retriever_combat.tuning.guard_raise \
		and retriever_combat.is_in_front_arc(global_position, retriever_combat.tuning.guard_half_arc_deg)


func _nearest_charge_lateral_direction(target_position: Vector3) -> Vector3:
	var lane_forward := Vector3(brain.lane_end_b.x - brain.lane_end_a.x, 0.0, brain.lane_end_b.z - brain.lane_end_a.z)
	if lane_forward.length_squared() <= 0.0001:
		lane_forward = brain.facing
	else:
		lane_forward = lane_forward.normalized()
	var lateral := Vector3(lane_forward.z, 0.0, -lane_forward.x)
	var offset := Vector3(target_position.x - brain.lane_end_a.x, 0.0, target_position.z - brain.lane_end_a.z)
	return lateral if offset.dot(lateral) >= 0.0 else -lateral
