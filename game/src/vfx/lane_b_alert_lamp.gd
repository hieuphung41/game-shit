class_name LaneBAlertLamp
extends Node3D
## Three physical shutters make the alert countable without relying on colour.

const SIGNAL_MATERIAL := preload("res://art/materials/signal_danger.tres")

var state: StringName = &"off"
var progress := 0.0
var arrow_target := Vector3.ZERO

@onready var _shutters: Node3D = $Shutters
@onready var _arrow: MeshInstance3D = $FloorArrow


func _ready() -> void:
	for shutter: Node in _shutters.get_children():
		(shutter as MeshInstance3D).material_override = SIGNAL_MATERIAL
	_arrow.material_override = SIGNAL_MATERIAL
	_refresh()


func set_state(value: StringName) -> void:
	state = value if value in [&"off", &"armed", &"active"] else &"off"
	_refresh()


func set_progress(value: float) -> void:
	progress = clampf(value, 0.0, 1.0)
	_refresh()


func set_arrow_target(world_pos: Vector3) -> void:
	arrow_target = world_pos
	var flat_target := Vector3(world_pos.x, global_position.y, world_pos.z)
	if flat_target.distance_squared_to(global_position) > 0.0001:
		_arrow.look_at(flat_target, Vector3.UP, true)


func opened_segments() -> int:
	if state == &"active":
		return 3
	if state != &"armed":
		return 0
	return mini(floori(progress * 3.0), 3)


func _refresh() -> void:
	if not is_node_ready():
		return
	var opened := opened_segments()
	for index: int in _shutters.get_child_count():
		_shutters.get_child(index).visible = index < opened
	_arrow.visible = state != &"off"
