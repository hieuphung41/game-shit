class_name EnemyBrain
extends RefCounted
## Pure, fixed-step hostile state machine. Scene adapters provide perception and apply motion/VFX.

const TEAM_ENEMY: StringName = &"enemy"
const STATE_IDLE: StringName = &"idle"
const STATE_PATROL: StringName = &"patrol"
const STATE_ALERT: StringName = &"alert"
const STATE_WINDUP: StringName = &"windup"
const STATE_STRIKE: StringName = &"strike"
const STATE_CHARGE: StringName = &"charge"
const STATE_RECOVER: StringName = &"recover"
const STATE_WITHDRAW: StringName = &"withdraw"
const STATE_WITHDRAWN: StringName = &"withdrawn"
const STATE_DOWN: StringName = &"down"
const MAX_TICK_DELTA := 0.1
const FOREMAN_TRIGGER_MARGIN := 0.4

signal alerted
signal windup_started(attack_kind: StringName, duration: float)
signal attack_released(attack_kind: StringName)
signal withdrew
signal downed
signal role_first_seen(role_id: StringName)
signal state_changed(state: StringName)

var role: EnemyRoleDef
var health: Health
var perception := EnemyPerception.new()
var state: StringName = STATE_IDLE
var position := Vector3.ZERO
var facing := Vector3.FORWARD
var home_position := Vector3.ZERO
var withdraw_position := Vector3.ZERO
var player_position := Vector3.ZERO
var player_seen := false
var player_on_camera := false
var motion_delta := Vector3.ZERO
var lane_end_a := Vector3.ZERO
var lane_end_b := Vector3.ZERO
var _tokens: AttackTokenPool
var _enemy_id: int
var _elapsed := 0.0
var _attack_cooldown := 0.0
var _windup_facing := Vector3.FORWARD
var _charge_end := Vector3.ZERO
var _first_seen_emitted := false
var _patrol_route: Array[Vector3] = []
var _patrol_index := 0
var _patrol_forward := true
var _patrol_enabled := false
var _prevent_new_windups := false


func _init(p_role: EnemyRoleDef, p_tokens: AttackTokenPool = null, p_enemy_id: int = 0) -> void:
	role = p_role if p_role != null else EnemyRoleDef.tax_guard()
	health = Health.new(role.max_hp)
	_tokens = p_tokens if p_tokens != null else AttackTokenPool.new()
	_enemy_id = p_enemy_id
	health.depleted.connect(_on_depleted)


func set_anchor(home: Vector3, withdraw: Vector3) -> void:
	home_position = home
	withdraw_position = withdraw


func set_lane(end_a: Vector3, end_b: Vector3) -> void:
	lane_end_a = end_a
	lane_end_b = end_b
	if position.distance_to(end_b) < position.distance_to(end_a):
		facing = _flat_direction(end_a - end_b, facing)
	else:
		facing = _flat_direction(end_b - end_a, facing)


func set_player(value: Vector3, visible: bool, on_camera: bool) -> void:
	player_position = value
	player_seen = visible
	player_on_camera = on_camera


func set_position(value: Vector3) -> void:
	position = value


func start_patrol(route: Array[Vector3]) -> void:
	_patrol_route = route.duplicate()
	_patrol_index = 0
	_patrol_forward = true
	_patrol_enabled = not _patrol_route.is_empty()
	if _patrol_enabled and state == STATE_IDLE:
		_set_state(STATE_PATROL)


func set_patrol_enabled(enabled: bool) -> void:
	_patrol_enabled = enabled
	if enabled and state == STATE_IDLE:
		_set_state(STATE_PATROL)


func stop_new_windups() -> void:
	_prevent_new_windups = true
	if state in [STATE_IDLE, STATE_PATROL, STATE_ALERT]:
		begin_withdraw()


func begin_withdraw() -> void:
	if state in [STATE_DOWN, STATE_WITHDRAW, STATE_WITHDRAWN]:
		return
	_tokens.release(_enemy_id)
	_set_state(STATE_WITHDRAW)


func tick(delta: float) -> void:
	var step := clampf(delta, 0.0, MAX_TICK_DELTA)
	motion_delta = Vector3.ZERO
	if step <= 0.0 or state in [STATE_DOWN, STATE_WITHDRAWN]:
		return
	_attack_cooldown = maxf(0.0, _attack_cooldown - step)
	match state:
		STATE_IDLE:
			_tick_idle(step)
		STATE_PATROL:
			_tick_patrol(step)
		STATE_ALERT:
			_tick_alert(step)
		STATE_WINDUP:
			_tick_windup(step)
		STATE_STRIKE:
			_tick_strike(step)
		STATE_CHARGE:
			_tick_charge(step)
		STATE_RECOVER:
			_tick_recover(step)
		STATE_WITHDRAW:
			_tick_withdraw(step)


func receive_hit(hit: HitInfo) -> HitResult:
	if state == STATE_DOWN:
		return HitResult.new(0, false, &"depleted")
	if role.shield_half_arc_deg > 0.0 and state in [STATE_IDLE, STATE_ALERT, STATE_WINDUP] and hit.blockable and _is_in_front_arc(hit.origin, role.shield_half_arc_deg):
		return HitResult.new(0, true)
	var applied := health.damage(hit.damage)
	if applied > 0:
		perception.notify_hit_by_player()
	return HitResult.new(applied)


func get_team() -> StringName:
	return TEAM_ENEMY


func get_combat_position() -> Vector3:
	return position


func get_combat_state() -> StringName:
	return state


func windup_progress() -> float:
	return clampf(_elapsed / role.windup_seconds, 0.0, 1.0) if state == STATE_WINDUP else 0.0


func is_lane_pressure_resolved() -> bool:
	return state in [STATE_WITHDRAWN, STATE_DOWN]


func can_hit_player_at(target_position: Vector3) -> bool:
	if state == STATE_STRIKE:
		var offset := Vector3(target_position.x - position.x, 0.0, target_position.z - position.z)
		return offset.length() <= role.attack_range and _is_in_arc(_windup_facing, offset, role.attack_arc_deg * 0.5)
	if state == STATE_CHARGE:
		var local := _charge_local(target_position)
		return absf(local.x) <= role.charge_hitbox_width * 0.5 and local.z >= 0.0 and local.z <= 0.8
	return false


func charge_hit(direction_was_blocked: bool) -> void:
	if state != STATE_CHARGE:
		return
	if direction_was_blocked:
		# The scene selected a legal collision point. The pure state machine only changes phase.
		pass
	_finish_charge()


func _tick_idle(_step: float) -> void:
	if player_seen:
		_enter_alert()
	elif _patrol_enabled:
		_set_state(STATE_PATROL)


func _tick_patrol(step: float) -> void:
	if player_seen:
		home_position = position
		_enter_alert()
		return
	if not _patrol_enabled or _patrol_route.is_empty():
		_set_state(STATE_IDLE)
		return
	var target := _patrol_route[_patrol_index]
	_move_toward(target, role.move_speed, step)
	if position.distance_to(target) <= 0.05:
		if _patrol_forward:
			_patrol_index += 1
			if _patrol_index >= _patrol_route.size():
				_patrol_index = maxi(0, _patrol_route.size() - 2)
				_patrol_forward = false
		else:
			_patrol_index -= 1
			if _patrol_index < 0:
				_patrol_index = mini(1, _patrol_route.size() - 1)
				_patrol_forward = true


func _tick_alert(step: float) -> void:
	if _should_withdraw():
		begin_withdraw()
		return
	if not player_seen:
		if _patrol_enabled:
			_set_state(STATE_PATROL)
		else:
			_move_toward(home_position, role.move_speed, step)
			if position.distance_to(home_position) <= 0.05:
				_set_state(STATE_IDLE)
		return
	if role.role_id == &"foreman":
		_tick_foreman_alert(step)
	else:
		_tick_guard_alert(step)


func _tick_guard_alert(step: float) -> void:
	var to_player := Vector3(player_position.x - position.x, 0.0, player_position.z - position.z)
	if to_player.length() <= role.leash_radius:
		facing = _flat_direction(to_player, facing)
	else:
		_move_toward(home_position, role.move_speed, step)
	if _can_start_guard_attack(to_player):
		_start_windup(&"guard_strike")


func _tick_foreman_alert(step: float) -> void:
	var near_end := _nearest_lane_end(position)
	if position.distance_to(near_end) > 0.05:
		_move_toward(near_end, role.move_speed, step)
		return
	var destination := _opposite_lane_end(near_end)
	facing = _flat_direction(destination - near_end, facing)
	if _player_in_charge_lane() and _can_start_attack():
		_charge_end = destination
		_start_windup(&"foreman_charge")


func _tick_windup(step: float) -> void:
	_elapsed += step
	if _elapsed < role.windup_seconds:
		return
	_elapsed = 0.0
	if role.role_id == &"foreman":
		_set_state(STATE_CHARGE)
	else:
		_set_state(STATE_STRIKE)
		attack_released.emit(&"guard_strike")


func _tick_strike(step: float) -> void:
	_elapsed += step
	if _elapsed >= role.active_seconds:
		_start_recover()


func _tick_charge(step: float) -> void:
	var before := position
	_move_toward(_charge_end, role.charge_speed, step)
	if position.distance_to(_charge_end) <= 0.05 or position == before:
		_finish_charge()


func _tick_recover(step: float) -> void:
	_elapsed += step
	if _elapsed < role.recover_seconds:
		return
	_tokens.release(_enemy_id)
	if _should_withdraw() or _prevent_new_windups:
		begin_withdraw()
	else:
		_set_state(STATE_ALERT if player_seen else (STATE_PATROL if _patrol_enabled else STATE_IDLE))


func _tick_withdraw(step: float) -> void:
	_move_toward(withdraw_position, role.move_speed, step)
	if position.distance_to(withdraw_position) <= 0.05:
		_set_state(STATE_WITHDRAWN)
		withdrew.emit()


func _enter_alert() -> void:
	if state != STATE_ALERT:
		_set_state(STATE_ALERT)
		alerted.emit()
		if not _first_seen_emitted:
			_first_seen_emitted = true
			role_first_seen.emit(role.role_id)


func _can_start_guard_attack(to_player: Vector3) -> bool:
	return to_player.length() <= role.attack_range and _is_in_arc(facing, to_player, role.attack_arc_deg * 0.5) and _can_start_attack()


func _can_start_attack() -> bool:
	return not _prevent_new_windups and player_on_camera and _attack_cooldown <= 0.0 and _tokens.try_acquire(_enemy_id)


func _start_windup(kind: StringName) -> void:
	_windup_facing = facing
	_elapsed = 0.0
	_attack_cooldown = role.min_attack_interval
	_set_state(STATE_WINDUP)
	windup_started.emit(kind, role.windup_seconds)


func _start_recover() -> void:
	_elapsed = 0.0
	_set_state(STATE_RECOVER)


func _finish_charge() -> void:
	attack_released.emit(&"foreman_charge")
	_start_recover()


func _should_withdraw() -> bool:
	return health.hp <= ceili(float(health.max_hp) * role.withdraw_hp_ratio)


func _move_toward(target: Vector3, speed: float, step: float) -> void:
	var offset := Vector3(target.x - position.x, 0.0, target.z - position.z)
	if offset.length_squared() <= 0.0001:
		return
	var travel := minf(offset.length(), speed * step)
	var direction := offset.normalized()
	facing = direction
	motion_delta = direction * travel
	position += motion_delta


func _nearest_lane_end(value: Vector3) -> Vector3:
	return lane_end_a if value.distance_to(lane_end_a) <= value.distance_to(lane_end_b) else lane_end_b


func _opposite_lane_end(value: Vector3) -> Vector3:
	return lane_end_b if value.distance_to(lane_end_a) <= value.distance_to(lane_end_b) else lane_end_a


func _player_in_charge_lane() -> bool:
	var lane := lane_end_b - lane_end_a
	var length := lane.length()
	if length <= 0.0001:
		return false
	var direction := lane / length
	var offset := Vector3(player_position.x - lane_end_a.x, 0.0, player_position.z - lane_end_a.z)
	var longitudinal := offset.dot(direction)
	var lateral := absf(offset.cross(direction).y)
	return longitudinal >= 0.0 and longitudinal <= length and lateral <= role.lane_width * 0.5 + FOREMAN_TRIGGER_MARGIN


func _charge_local(world_position: Vector3) -> Vector3:
	var forward := _flat_direction(_charge_end - position, facing)
	var offset := Vector3(world_position.x - position.x, 0.0, world_position.z - position.z)
	return Vector3(forward.cross(Vector3.UP).dot(offset), 0.0, forward.dot(offset))


func _is_in_front_arc(origin: Vector3, half_arc_deg: float) -> bool:
	return _is_in_arc(facing, Vector3(origin.x - position.x, 0.0, origin.z - position.z), half_arc_deg)


func _is_in_arc(forward: Vector3, offset: Vector3, half_arc_deg: float) -> bool:
	if offset.length_squared() <= 0.0001:
		return true
	return _flat_direction(forward, Vector3.FORWARD).dot(offset.normalized()) >= cos(deg_to_rad(half_arc_deg))


func _flat_direction(value: Vector3, fallback: Vector3) -> Vector3:
	var flat := Vector3(value.x, 0.0, value.z)
	return flat.normalized() if flat.length_squared() > 0.0001 else fallback


func _set_state(value: StringName) -> void:
	if state == value:
		return
	state = value
	state_changed.emit(value)


func _on_depleted() -> void:
	_tokens.release(_enemy_id)
	_set_state(STATE_DOWN)
	downed.emit()
