class_name PatrolReturn
extends Node
## Adapter for the authored B-to-A patrol path. The guard brain retains its combat decisions.

const PATROL_CUE_LEAD := 2.0

@export var guard_path: NodePath
@export var path_root: NodePath
@export var alert_lamp_path: NodePath

signal patrol_cue_started

var _activated := false
var _elapsed := 0.0
var _guard: EnemyActor
var _lamp: Node


func _ready() -> void:
	_guard = get_node_or_null(guard_path) as EnemyActor
	_lamp = get_node_or_null(alert_lamp_path)


func activate() -> void:
	if _activated:
		return
	_activated = true
	_elapsed = 0.0
	patrol_cue_started.emit()
	if _lamp != null:
		_lamp.call(&"set_state", &"armed")
		_lamp.call(&"set_progress", 0.0)


func tick(delta: float) -> void:
	if not _activated:
		return
	_elapsed += clampf(delta, 0.0, EnemyBrain.MAX_TICK_DELTA)
	if _lamp != null and _elapsed <= PATROL_CUE_LEAD:
		_lamp.call(&"set_progress", clampf(_elapsed / PATROL_CUE_LEAD, 0.0, 1.0))
	if _elapsed < PATROL_CUE_LEAD:
		return
	if _lamp != null:
		_lamp.call(&"set_state", &"active")
	if _guard != null and _guard.brain != null and _guard.brain.state != EnemyBrain.STATE_PATROL:
		_guard.begin_patrol(_path_points())


func _process(delta: float) -> void:
	tick(delta)


func _path_points() -> Array[Vector3]:
	var root := get_node_or_null(path_root) as Node3D
	var points: Array[Vector3] = []
	if root == null:
		return points
	for child: Node in root.get_children():
		if child is Node3D:
			points.append((child as Node3D).global_position)
	return points
