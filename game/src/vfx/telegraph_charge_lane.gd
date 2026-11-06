class_name TelegraphChargeLane
extends Node3D
## Static lane geometry with monotonically revealed chevrons; no combat state lives here.

const SIGNAL_MATERIAL := preload("res://art/materials/signal_danger.tres")
const CHEVRON_COUNT := 8

var progress := 0.0
var lane_length_m := 9.0
var lane_width_m := 1.6
var lane_active := false

@onready var _left_edge: MeshInstance3D = $LeftEdge
@onready var _right_edge: MeshInstance3D = $RightEdge
@onready var _chevrons: Node3D = $Chevrons


func _ready() -> void:
	for edge: MeshInstance3D in [_left_edge, _right_edge]:
		edge.material_override = SIGNAL_MATERIAL
	_build_chevrons()
	_refresh()


func set_lane(origin: Vector3, direction: Vector3, length_m: float, width_m: float) -> void:
	global_position = origin
	var flat_direction := Vector3(direction.x, 0.0, direction.z)
	if flat_direction.length_squared() > 0.0001:
		global_rotation.y = atan2(flat_direction.x, flat_direction.z)
	lane_length_m = maxf(length_m, 0.1)
	lane_width_m = maxf(width_m, 0.1)
	_refresh()


func set_progress(value: float) -> void:
	progress = clampf(value, 0.0, 1.0)
	_refresh()


func set_active(on: bool) -> void:
	lane_active = on
	visible = on
	_refresh()


func _build_chevrons() -> void:
	if not _chevrons.get_children().is_empty():
		return
	for index: int in CHEVRON_COUNT:
		var chevron := MeshInstance3D.new()
		chevron.name = "Chevron%02d" % index
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.58, 0.025, 0.11)
		chevron.mesh = mesh
		chevron.material_override = SIGNAL_MATERIAL
		chevron.rotation.y = 0.785398
		chevron.set_meta("lane_index", index)
		_chevrons.add_child(chevron)


func _refresh() -> void:
	if not is_node_ready():
		return
	var edge_mesh := _left_edge.mesh as BoxMesh
	if edge_mesh != null:
		edge_mesh.size = Vector3(0.18, 0.025, lane_length_m)
	var right_mesh := _right_edge.mesh as BoxMesh
	if right_mesh != null:
		right_mesh.size = Vector3(0.18, 0.025, lane_length_m)
	_left_edge.position = Vector3(-lane_width_m * 0.5, 0.02, lane_length_m * 0.5)
	_right_edge.position = Vector3(lane_width_m * 0.5, 0.02, lane_length_m * 0.5)
	var shown := floori(progress * float(CHEVRON_COUNT))
	if is_equal_approx(progress, 1.0):
		shown = CHEVRON_COUNT
	for child: Node in _chevrons.get_children():
		var chevron := child as MeshInstance3D
		if chevron == null:
			continue
		var index := int(chevron.get_meta("lane_index", 0))
		chevron.position = Vector3(0.0, 0.026, lane_length_m * (float(index) + 0.5) / float(CHEVRON_COUNT))
		chevron.visible = lane_active and index < shown
