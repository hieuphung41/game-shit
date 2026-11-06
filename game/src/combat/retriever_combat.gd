class_name RetrieverCombat
extends RefCounted
## Pure player combat state machine. Scene adapters supply position, targets and input.

const TEAM_RETRIEVER: StringName = &"retriever"
const TEAM_ENEMY: StringName = &"enemy"
const STATE_FREE: StringName = &"free"
const STATE_ATTACKING: StringName = &"attacking"
const STATE_DODGING: StringName = &"dodging"
const STATE_GUARDING: StringName = &"guarding"
const STATE_USING_REMEDY: StringName = &"using_remedy"
const STATE_HITSTUN: StringName = &"hitstun"
const STATE_DEPLETED: StringName = &"depleted"

enum AttackPhase { WINDUP, ACTIVE, RECOVER }

signal state_changed(state: StringName)
signal attack_released(hit_targets: Array)
signal remedy_used(healed: int)
signal remedy_refused(reason: StringName)
signal dodge_cooldown_changed(remaining: float)
## Scene adapters apply this through CharacterBody3D motion so walls can stop it.
signal knockback_requested(displacement: Vector3)

var tuning: RetrieverCombatTuning
var health: Health
var inventory: RetrieverInventory
var position := Vector3.ZERO
var facing := Vector3.FORWARD
var state: StringName = STATE_FREE
var motion_delta := Vector3.ZERO

var _targets: Array = []
var _overlay_open := false
var _move_input := Vector2.ZERO
var _move_direction := Vector3.ZERO
var _attack_phase := AttackPhase.WINDUP
var _action_elapsed := 0.0
var _dodge_cooldown_remaining := 0.0
var _post_hit_remaining := 0.0
var _guard_held := false
var _buffered_action: StringName = &""
var _remedy_uid := 0
var _pending_displacement := Vector3.ZERO


func _init(p_tuning: RetrieverCombatTuning = null, p_inventory: RetrieverInventory = null) -> void:
	tuning = p_tuning if p_tuning != null else RetrieverCombatTuning.new()
	health = Health.new(tuning.max_hp)
	inventory = p_inventory
	health.depleted.connect(_on_depleted)


func tick(delta: float) -> void:
	if delta <= 0.0:
		return
	var step := minf(delta, tuning.max_tick_delta)
	motion_delta = _pending_displacement
	_pending_displacement = Vector3.ZERO
	position += motion_delta
	_dodge_cooldown_remaining = maxf(0.0, _dodge_cooldown_remaining - step)
	_post_hit_remaining = maxf(0.0, _post_hit_remaining - step)
	if state == STATE_DEPLETED:
		return
	match state:
		STATE_ATTACKING:
			tick_attack(step)
		STATE_DODGING:
			tick_dodge(step)
		STATE_GUARDING:
			_action_elapsed += step
			track_guard_target(step)
		STATE_USING_REMEDY:
			tick_remedy(step)
		STATE_HITSTUN:
			tick_hitstun(step)
	_apply_movement(step)


func press(action: StringName) -> void:
	if _overlay_open or state == STATE_DEPLETED:
		if action == &"use_remedy" and _overlay_open:
			remedy_refused.emit(&"overlay_open")
		return
	if action == &"combat_guard":
		_guard_held = true
	match action:
		&"combat_attack":
			if state == STATE_FREE:
				start_attack()
			elif state == STATE_ATTACKING and can_buffer_current_action():
				_buffered_action = action
		&"combat_dodge":
			if state == STATE_FREE or state == STATE_GUARDING or (state == STATE_ATTACKING and _attack_phase == AttackPhase.RECOVER):
				start_dodge()
			elif state == STATE_ATTACKING and can_buffer_current_action():
				_buffered_action = action
			elif state == STATE_USING_REMEDY:
				cancel_remedy(false)
				start_dodge()
		&"combat_guard":
			if state == STATE_FREE:
				start_guard()
			elif state == STATE_USING_REMEDY:
				cancel_remedy(false)
				start_guard()
		&"use_remedy":
			if state == STATE_FREE:
				start_remedy()


func release(action: StringName) -> void:
	if action != &"combat_guard":
		return
	_guard_held = false
	if state == STATE_GUARDING:
		set_state(STATE_FREE)


func set_overlay_open(open: bool) -> void:
	_overlay_open = open
	if not open:
		return
	_guard_held = false
	_buffered_action = &""
	if state == STATE_GUARDING:
		set_state(STATE_FREE)
	elif state == STATE_USING_REMEDY:
		cancel_remedy(false)


func set_move_input(value: Vector2) -> void:
	_move_input = value.limit_length()


func set_move_direction(value: Vector3) -> void:
	_move_direction = Vector3(value.x, 0.0, value.z).limit_length()
	if not is_zero_approx(_move_direction.length_squared()) and state == STATE_FREE:
		facing = _move_direction.normalized()


func set_combat_position(value: Vector3) -> void:
	position = value


func set_targets(value: Array) -> void:
	_targets = value


func get_team() -> StringName:
	return TEAM_RETRIEVER


func get_combat_position() -> Vector3:
	return position


func receive_hit(hit: HitInfo) -> HitResult:
	if health.is_depleted():
		return HitResult.new(0, false, &"depleted")
	if state == STATE_DODGING and _action_elapsed < tuning.dodge_iframe:
		return HitResult.new(0, false, &"iframe")
	if _post_hit_remaining > 0.0:
		return HitResult.new(0, false, &"post_hit")
	if state == STATE_GUARDING and _action_elapsed >= tuning.guard_raise and hit.blockable and is_in_front_arc(hit.origin, tuning.guard_half_arc_deg):
		var chip_ratio := 0.3 if hit.kind == &"foreman_charge" else 0.0
		var applied := health.damage(floori(hit.damage * chip_ratio))
		if applied > 0:
			_post_hit_remaining = tuning.post_hit_invuln
		if hit.kind == &"foreman_charge":
			queue_knockback(hit.direction, hit.knockback_m)
		return HitResult.new(applied, true)
	var applied := health.damage(hit.damage)
	if applied > 0:
		_post_hit_remaining = tuning.post_hit_invuln
		if state == STATE_USING_REMEDY:
			cancel_remedy(true)
		elif not health.is_depleted():
			set_state(STATE_HITSTUN)
			_action_elapsed = 0.0
	return HitResult.new(applied)


func is_in_front_arc(origin: Vector3, half_arc_deg: float) -> bool:
	var to_origin := Vector3(origin.x - position.x, 0.0, origin.z - position.z)
	if is_zero_approx(to_origin.length_squared()):
		return true
	var forward := Vector3(facing.x, 0.0, facing.z).normalized()
	return forward.dot(to_origin.normalized()) >= cos(deg_to_rad(half_arc_deg))


func movement_ratio() -> float:
	match state:
		STATE_GUARDING:
			return tuning.guard_move_ratio
		STATE_USING_REMEDY, STATE_ATTACKING:
			return 0.5 if state == STATE_USING_REMEDY or _attack_phase == AttackPhase.RECOVER else 0.0
		STATE_HITSTUN, STATE_DEPLETED, STATE_DODGING:
			return 0.0
	return 1.0


func start_attack() -> void:
	if state == STATE_GUARDING or state == STATE_USING_REMEDY:
		return
	var target: Variant = nearest_target(tuning.assist_radius, tuning.assist_half_arc_deg)
	if target != null:
		var target_position: Vector3 = target.get_combat_position()
		facing = Vector3(target_position.x - position.x, 0.0, target_position.z - position.z).normalized()
	set_state(STATE_ATTACKING)
	_attack_phase = AttackPhase.WINDUP
	_action_elapsed = 0.0


func start_dodge() -> void:
	if _dodge_cooldown_remaining > 0.0:
		return
	set_state(STATE_DODGING)
	_action_elapsed = 0.0
	_dodge_cooldown_remaining = tuning.dodge_duration + tuning.dodge_cooldown
	dodge_cooldown_changed.emit(_dodge_cooldown_remaining)
	if not is_zero_approx(_move_direction.length_squared()) and _move_input.length() > 0.2:
		facing = _move_direction.normalized()


func start_guard() -> void:
	set_state(STATE_GUARDING)
	_action_elapsed = 0.0


func start_remedy() -> void:
	if _overlay_open:
		remedy_refused.emit(&"overlay_open")
		return
	_remedy_uid = find_sling_remedy_uid()
	if _remedy_uid == 0:
		remedy_refused.emit(&"no_remedy")
		return
	if health.hp == health.max_hp:
		remedy_refused.emit(&"hp_full")
		return
	set_state(STATE_USING_REMEDY)
	_action_elapsed = 0.0


func find_sling_remedy_uid() -> int:
	if inventory == null:
		return 0
	for item: ItemInstance in inventory.sling_pouch.all_items():
		if item.def_id == &"sling_remedy":
			return item.uid
	return 0


func nearest_target(radius: float, half_arc_deg: float) -> Variant:
	var nearest: Variant = null
	var nearest_distance := INF
	for target: Variant in _targets:
		if target == null or not target.has_method(&"get_team") or target.get_team() != TEAM_ENEMY or not target.has_method(&"get_combat_position"):
			continue
		var offset: Vector3 = target.get_combat_position() - position
		var distance := Vector2(offset.x, offset.z).length()
		if distance > radius or not is_in_front_arc(target.get_combat_position(), half_arc_deg):
			continue
		if distance < nearest_distance:
			nearest = target
			nearest_distance = distance
	return nearest


func can_buffer_current_action() -> bool:
	if state != STATE_ATTACKING:
		return false
	return attack_remaining_seconds() <= tuning.input_buffer + 0.00001


func attack_remaining_seconds() -> float:
	match _attack_phase:
		AttackPhase.WINDUP:
			return maxf(0.0, tuning.attack_windup - _action_elapsed) + tuning.attack_active + tuning.attack_recover
		AttackPhase.ACTIVE:
			return maxf(0.0, tuning.attack_active - _action_elapsed) + tuning.attack_recover
		AttackPhase.RECOVER:
			return maxf(0.0, tuning.attack_recover - _action_elapsed)
	return 0.0


func track_guard_target(step: float) -> void:
	if _action_elapsed < tuning.guard_raise:
		return
	var target: Variant = nearest_guard_tracking_target()
	if target == null:
		return
	var target_position: Vector3 = target.get_combat_position()
	var desired := Vector3(target_position.x - position.x, 0.0, target_position.z - position.z).normalized()
	if is_zero_approx(desired.length_squared()):
		return
	var from_angle := atan2(facing.x, facing.z)
	var target_angle := atan2(desired.x, desired.z)
	var next_angle := rotate_toward(from_angle, target_angle, deg_to_rad(360.0) * step)
	facing = Vector3(sin(next_angle), 0.0, cos(next_angle))


func nearest_guard_tracking_target() -> Variant:
	var nearest: Variant = null
	var nearest_distance := INF
	for target: Variant in _targets:
		if not is_guard_tracking_target(target):
			continue
		var target_position: Vector3 = target.get_combat_position()
		var distance := Vector2(target_position.x - position.x, target_position.z - position.z).length()
		if distance > tuning.guard_track_radius or distance >= nearest_distance:
			continue
		nearest = target
		nearest_distance = distance
	return nearest


func is_guard_tracking_target(target: Variant) -> bool:
	if target == null or not target.has_method(&"get_team") or target.get_team() != TEAM_ENEMY:
		return false
	if not target.has_method(&"get_combat_position") or not target.has_method(&"get_combat_state"):
		return false
	var target_state: StringName = target.get_combat_state()
	return target_state in [&"alert", &"windup", &"strike", &"charge", &"attacking"]


func queue_knockback(direction: Vector3, distance_m: float) -> void:
	var horizontal := Vector3(direction.x, 0.0, direction.z)
	if is_zero_approx(horizontal.length_squared()) or distance_m <= 0.0:
		return
	var displacement := horizontal.normalized() * distance_m
	_pending_displacement += displacement
	knockback_requested.emit(displacement)


func tick_attack(step: float) -> void:
	_action_elapsed += step
	if _attack_phase == AttackPhase.WINDUP and _action_elapsed >= tuning.attack_windup:
		_attack_phase = AttackPhase.ACTIVE
		_action_elapsed -= tuning.attack_windup
		release_attack()
	if _attack_phase == AttackPhase.ACTIVE and _action_elapsed >= tuning.attack_active:
		_attack_phase = AttackPhase.RECOVER
		_action_elapsed -= tuning.attack_active
	if _attack_phase == AttackPhase.RECOVER and _action_elapsed >= tuning.attack_recover:
		finish_action()


func release_attack() -> void:
	var hit_targets: Array = []
	for target: Variant in _targets:
		if target == null or not target.has_method(&"get_team") or target.get_team() != TEAM_ENEMY or not target.has_method(&"get_combat_position") or not target.has_method(&"receive_hit"):
			continue
		var target_position: Vector3 = target.get_combat_position()
		var horizontal := Vector2(target_position.x - position.x, target_position.z - position.z)
		if horizontal.length() > tuning.attack_range or not is_in_front_arc(target_position, tuning.attack_arc_deg * 0.5):
			continue
		var hit := HitInfo.new(0, &"retriever_slash", tuning.attack_damage, position, facing, 0.0, true)
		target.receive_hit(hit)
		hit_targets.append(target)
	attack_released.emit(hit_targets)


func tick_dodge(step: float) -> void:
	var dash_direction := _move_direction if not is_zero_approx(_move_direction.length_squared()) and _move_input.length() > 0.2 else -facing
	motion_delta = dash_direction.normalized() * (tuning.dodge_distance / tuning.dodge_duration) * step
	position += motion_delta
	_action_elapsed += step
	if _action_elapsed >= tuning.dodge_duration:
		set_state(STATE_GUARDING if _guard_held else STATE_FREE)
		_action_elapsed = 0.0


func tick_remedy(step: float) -> void:
	_action_elapsed += step
	if _action_elapsed + 0.00001 < tuning.remedy_use_seconds:
		return
	var result := inventory.commit_consume(_remedy_uid) if inventory != null else InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND)
	if result.ok:
		remedy_used.emit(health.heal(tuning.remedy_heal))
	else:
		remedy_refused.emit(&"no_remedy")
	set_state(STATE_FREE)
	_action_elapsed = 0.0


func tick_hitstun(step: float) -> void:
	_action_elapsed += step
	if _action_elapsed >= tuning.hitstun:
		set_state(STATE_GUARDING if _guard_held else STATE_FREE)
		_action_elapsed = 0.0


func finish_action() -> void:
	set_state(STATE_FREE)
	_action_elapsed = 0.0
	var buffered := _buffered_action
	_buffered_action = &""
	if buffered != &"":
		press(buffered)


func cancel_remedy(to_hitstun: bool) -> void:
	_remedy_uid = 0
	_action_elapsed = 0.0
	set_state(STATE_HITSTUN if to_hitstun else STATE_FREE)


func set_state(next_state: StringName) -> void:
	if state == next_state:
		return
	state = next_state
	state_changed.emit(state)


func _apply_movement(step: float) -> void:
	if state == STATE_DODGING or state == STATE_DEPLETED or not is_zero_approx(motion_delta.length_squared()):
		return
	if is_zero_approx(_move_direction.length_squared()):
		return
	var move := _move_direction * _move_input.length() * movement_ratio() * step
	position += move
	motion_delta += move


func _on_depleted() -> void:
	_buffered_action = &""
	_guard_held = false
	set_state(STATE_DEPLETED)
