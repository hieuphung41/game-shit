class_name RetrieverController
extends CharacterBody3D
## Touch-first movement controller for the Retriever in the vertical-slice greybox.

const WorldFloorSafetyRule := preload("res://src/world/world_floor_safety.gd")

@export var movement_speed: float = 4.0
@export var combat_tuning: RetrieverCombatTuning

@onready var _camera: Camera3D = get_parent().get_node_or_null("CameraIsometric") as Camera3D
@onready var _touch_joystick: TouchJoystick = $TouchControls/TouchJoystick
@onready var _visual: Node = get_node_or_null("Visual")

var _camera_follow_offset := Vector3.ZERO
var _touch_direction := Vector2.ZERO
var _floor_safety: WorldFloorSafety
var combat: RetrieverCombat


func _ready() -> void:
	combat = RetrieverCombat.new(combat_tuning, RunSession.inventory, movement_speed)
	combat.state_changed.connect(_on_combat_state_changed)
	if _touch_joystick != null:
		_touch_joystick.direction_changed.connect(_on_touch_direction_changed)
	if _camera != null:
		_camera_follow_offset = _camera.global_position - global_position
	enforce_floor_safety()


func _physics_process(delta: float) -> void:
	if _camera == null or combat == null:
		return
	enforce_floor_safety()
	var input_direction := _active_direction()
	var direction := RetrieverMovement.camera_relative_direction(input_direction, _camera.global_transform.basis)
	combat.set_combat_position(global_position)
	combat.set_move_input(input_direction)
	combat.set_move_direction(direction)
	combat.set_targets(get_tree().get_nodes_in_group(&"combat_targets"))
	_read_combat_actions()
	combat.tick(delta)
	velocity = motion_velocity_for(combat.motion_delta, delta)
	velocity.y = 0.0
	move_and_slide()
	enforce_floor_safety()
	combat.set_combat_position(global_position)
	_follow_camera()


func _active_direction() -> Vector2:
	if not is_zero_approx(_touch_direction.length_squared()):
		return _touch_direction
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")


static func motion_velocity_for(displacement: Vector3, physics_delta: float) -> Vector3:
	return displacement / physics_delta if physics_delta > 0.0 else Vector3.ZERO


func _follow_camera() -> void:
	_camera.global_position = global_position + _camera_follow_offset


func _on_touch_direction_changed(direction: Vector2) -> void:
	_touch_direction = direction


func set_inventory(value: RetrieverInventory) -> void:
	if combat != null:
		combat.inventory = value


func set_floor_safety(safety: WorldFloorSafety) -> void:
	_floor_safety = safety


func set_route_d_open(open: bool) -> void:
	if _floor_safety != null:
		_floor_safety.set_route_d_open(open)


func enforce_floor_safety() -> bool:
	if _floor_safety == null:
		return false
	var safe_position := _floor_safety.reconcile(global_position)
	if safe_position.is_equal_approx(global_position):
		return false
	global_position = safe_position
	velocity = Vector3.ZERO
	return true


func set_overlay_open(open: bool) -> void:
	if combat != null:
		combat.set_overlay_open(open)


func press_combat_action(action: StringName) -> void:
	if combat != null:
		combat.press(action)


func release_combat_action(action: StringName) -> void:
	if combat != null:
		combat.release(action)


func receive_hit(hit: HitInfo) -> HitResult:
	return combat.receive_hit(hit) if combat != null else HitResult.new(0, false, &"depleted")


func get_team() -> StringName:
	return RetrieverCombat.TEAM_RETRIEVER


func get_combat_position() -> Vector3:
	return global_position


func _read_combat_actions() -> void:
	for action: StringName in [&"combat_attack", &"combat_dodge", &"combat_guard", &"use_remedy"]:
		if Input.is_action_just_pressed(action):
			combat.press(action)
		if action == &"combat_guard" and Input.is_action_just_released(action):
			combat.release(action)


func _on_combat_state_changed(state: StringName) -> void:
	if _visual != null and _visual.has_method(&"play_state"):
		_visual.call(&"play_state", _logical_visual_state(state))


func _logical_visual_state(state: StringName) -> StringName:
	match state:
		RetrieverCombat.STATE_ATTACKING:
			return &"attack"
		RetrieverCombat.STATE_DODGING:
			return &"dodge"
		RetrieverCombat.STATE_GUARDING:
			return &"guard"
		RetrieverCombat.STATE_USING_REMEDY:
			return &"use_remedy"
		RetrieverCombat.STATE_HITSTUN:
			return &"hit"
		RetrieverCombat.STATE_DEPLETED:
			return &"down"
	return &"idle"
