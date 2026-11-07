class_name HoldLaneBDirector
extends Node
## S8-only director. It observes ExtractPierAFlow and never changes extract state.

const TAX_GUARD_SCENE: PackedScene = preload("res://src/enemies/tax_guard.tscn")
const FOREMAN_SCENE: PackedScene = preload("res://src/enemies/foreman.tscn")

@export var wave: HoldWaveDef
@export var spawn_parent_path: NodePath
@export var spawn_marker_path: NodePath
@export var hold_path_root: NodePath
@export var hold_guard_post_path: NodePath
@export var hold_charge_lane_path: NodePath
@export var alert_lamp_path: NodePath

signal lane_alert_started
signal enemy_spawned(role_id: StringName, enemy: EnemyActor)
signal enemy_entered_camera(role_id: StringName)

# Test-only seam. Production uses each actor's viewport-inset predicate.
var camera_entry_predicate: Callable

var elapsed := 0.0
var _started := false
var _stopped := false
var _guard_spawned := false
var _foreman_spawned := false
var _enemies: Array[EnemyActor] = []
var _attack_tokens := AttackTokenPool.new()
var _camera_inside: Dictionary = {}
var _flow: ExtractPierAFlow
var _lamp: Node


func _ready() -> void:
	if wave == null:
		wave = HoldWaveDef.new()
	_lamp = get_node_or_null(alert_lamp_path)


func bind_flow(flow: ExtractPierAFlow) -> void:
	if _flow != null and _flow.hold_started.is_connected(on_hold_started):
		_flow.hold_started.disconnect(on_hold_started)
	if _flow != null and _flow.boat_ready.is_connected(on_boat_ready):
		_flow.boat_ready.disconnect(on_boat_ready)
	_flow = flow
	if _flow != null:
		_flow.hold_started.connect(on_hold_started)
		_flow.boat_ready.connect(on_boat_ready)


func on_hold_started(_seconds: float) -> void:
	if _started or _stopped:
		return
	if wave == null or not wave.is_valid():
		push_error("HoldLaneBDirector needs a valid HoldWaveDef")
		return
	_started = true
	elapsed = 0.0
	_arm_lamp()
	lane_alert_started.emit()
	# The authored spawn is outside the viewport. Begin traversal now; entry is
	# reported only when the actor physically crosses the camera inset.
	_guard_spawned = _spawn_guard()
	_foreman_spawned = _spawn_foreman()


func on_boat_ready() -> void:
	if not _started:
		return
	_stopped = true
	if _lamp != null:
		_lamp.call(&"set_state", &"off")
	for enemy: EnemyActor in _enemies:
		if is_instance_valid(enemy):
			enemy.force_withdraw()


func on_run_ended() -> void:
	_stopped = true
	if _lamp != null:
		_lamp.call(&"set_state", &"off")


func tick(delta: float) -> void:
	if not _started or _stopped:
		return
	elapsed += clampf(delta, 0.0, EnemyBrain.MAX_TICK_DELTA)
	_update_lamp()
	_observe_camera_entries()


func _process(delta: float) -> void:
	tick(delta)


func _arm_lamp() -> void:
	if _lamp != null:
		_lamp.call(&"set_state", &"armed")
		_lamp.call(&"set_progress", 0.0)


func _update_lamp() -> void:
	if _lamp == null:
		return
	var cue_start := 0.0 if elapsed < wave.foreman_cue_at else wave.foreman_cue_at
	var cue_end := wave.guard_enter_camera_at if cue_start == 0.0 else wave.foreman_enter_camera_at
	if elapsed < cue_end:
		_lamp.call(&"set_state", &"armed")
		_lamp.call(&"set_progress", clampf((elapsed - cue_start) / (cue_end - cue_start), 0.0, 1.0))
	else:
		_lamp.call(&"set_state", &"active")


func _spawn_guard() -> bool:
	var guard := _spawn(TAX_GUARD_SCENE, &"tax_guard")
	if guard == null:
		return false
	var route := _common_hold_path()
	var guard_post := _node_position(hold_guard_post_path, guard.global_position)
	route.append(guard_post)
	guard.configure_anchor(guard_post, _node_position(spawn_marker_path, guard.global_position))
	guard.begin_patrol(route)
	return true


func _spawn_foreman() -> bool:
	var foreman := _spawn(FOREMAN_SCENE, &"foreman")
	if foreman == null:
		return false
	var lane := get_node_or_null(hold_charge_lane_path) as Node3D
	if lane != null:
		var end_a := lane.get_node_or_null("end_a") as Node3D
		var end_b := lane.get_node_or_null("end_b") as Node3D
		if end_a != null and end_b != null:
			foreman.configure_lane(end_a.global_position, end_b.global_position)
			foreman.configure_anchor(end_a.global_position, _node_position(spawn_marker_path, foreman.global_position))
	var route := _common_hold_path()
	if lane != null:
		var lane_start := lane.get_node_or_null("end_a") as Node3D
		if lane_start != null:
			route.append(lane_start.global_position)
	foreman.begin_patrol(route)
	return true


func _spawn(scene: PackedScene, role_id: StringName) -> EnemyActor:
	var parent := get_node_or_null(spawn_parent_path) if not spawn_parent_path.is_empty() else get_parent()
	if parent == null:
		return null
	var enemy := scene.instantiate() as EnemyActor
	if enemy == null:
		return null
	# All S8 enemies share the director-owned token before _ready constructs
	# their brains, enforcing one concurrent windup across the wave.
	enemy.attack_tokens = _attack_tokens
	parent.add_child(enemy)
	enemy.global_position = _node_position(spawn_marker_path, Vector3.ZERO)
	if enemy.brain != null:
		enemy.brain.set_position(enemy.global_position)
	_enemies.append(enemy)
	_camera_inside[enemy.get_instance_id()] = false
	enemy_spawned.emit(role_id, enemy)
	return enemy


func _observe_camera_entries() -> void:
	for enemy: EnemyActor in _enemies:
		if not is_instance_valid(enemy):
			continue
		var instance_id := enemy.get_instance_id()
		var inside := _is_inside_camera_inset(enemy)
		var was_inside: bool = _camera_inside.get(instance_id, false)
		_camera_inside[instance_id] = inside
		if inside and not was_inside:
			enemy_entered_camera.emit(enemy.role_def.role_id)


func _is_inside_camera_inset(enemy: EnemyActor) -> bool:
	if camera_entry_predicate.is_valid():
		return bool(camera_entry_predicate.call(enemy))
	return enemy.is_inside_camera_inset()


func _common_hold_path() -> Array[Vector3]:
	var root := get_node_or_null(hold_path_root) as Node3D
	var points: Array[Vector3] = []
	if root == null:
		return points
	for child: Node in root.get_children():
		if child is Node3D:
			points.append((child as Node3D).global_position)
	return points


func _node_position(path: NodePath, fallback: Vector3) -> Vector3:
	var node := get_node_or_null(path) as Node3D
	return node.global_position if node != null else fallback
