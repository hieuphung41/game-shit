class_name TelegraphHoldRing
extends Node3D
## Floor-only guard telegraph. Combat owns timing; this node only renders it.

const SIGNAL_MATERIAL := preload("res://art/materials/signal_danger.tres")
const RING_THICKNESS := 0.055
const DASH_COUNT := 16

var radius_m := 2.5
var mode: StringName = &"off"
var strike_arc_deg := 100.0
var strike_range_m := 1.8
var strike_progress := 0.0
var _strike_arc_requested := false

@onready var _solid_ring: MeshInstance3D = $SolidRing
@onready var _strike_wedge: MeshInstance3D = $StrikeWedge
@onready var _dashes: Node3D = $DashedRing
@onready var _inward_ticks: Node3D = $InwardTicks


func _ready() -> void:
	_solid_ring.material_override = SIGNAL_MATERIAL
	_strike_wedge.material_override = SIGNAL_MATERIAL
	_build_dashes(_dashes, 0.16, 0.06)
	_build_dashes(_inward_ticks, 0.22, 0.045)
	_refresh()


func set_radius(value: float) -> void:
	radius_m = maxf(value, 0.1)
	_refresh()


func set_mode(value: StringName) -> void:
	mode = value if value in [&"off", &"patrol", &"hold"] else &"off"
	_refresh()


func show_strike_arc(arc_deg: float, range_m: float) -> void:
	strike_arc_deg = clampf(arc_deg, 1.0, 359.0)
	strike_range_m = maxf(range_m, 0.1)
	_strike_arc_requested = true
	_refresh_wedge()


func set_strike_progress(value: float) -> void:
	strike_progress = clampf(value, 0.0, 1.0)
	_refresh_wedge()


func hide_strike_arc() -> void:
	_strike_arc_requested = false
	_strike_wedge.visible = false


func _refresh() -> void:
	if not is_node_ready():
		return
	_solid_ring.visible = mode == &"hold"
	_dashes.visible = mode == &"patrol"
	_inward_ticks.visible = mode == &"hold"
	var torus := _solid_ring.mesh as TorusMesh
	if torus != null:
		torus.inner_radius = maxf(radius_m - RING_THICKNESS, 0.01)
		torus.outer_radius = radius_m + RING_THICKNESS
	for group: Node3D in [_dashes, _inward_ticks]:
		for child: Node in group.get_children():
			var dash := child as MeshInstance3D
			if dash == null:
				continue
			var angle := float(dash.get_meta("ring_angle", 0.0))
			var at_radius := radius_m if group == _dashes else radius_m - 0.22
			dash.position = Vector3(sin(angle) * at_radius, 0.025, cos(angle) * at_radius)
			dash.rotation.y = angle
	_refresh_wedge()


func _build_dashes(group: Node3D, length_m: float, width_m: float) -> void:
	for index: int in DASH_COUNT:
		var dash := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(width_m, 0.025, length_m)
		dash.mesh = mesh
		dash.material_override = SIGNAL_MATERIAL
		dash.set_meta("ring_angle", TAU * float(index) / float(DASH_COUNT))
		group.add_child(dash)


func _refresh_wedge() -> void:
	if not is_node_ready():
		return
	var visible_radius := strike_range_m * strike_progress
	_strike_wedge.mesh = _fan_mesh(visible_radius, strike_arc_deg)
	_strike_wedge.visible = _strike_arc_requested and visible_radius > 0.0


func _fan_mesh(radius: float, arc_deg: float) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segments := 18
	var half_arc := deg_to_rad(arc_deg) * 0.5
	for index: int in segments:
		var first := -half_arc + (2.0 * half_arc * float(index) / float(segments))
		var second := -half_arc + (2.0 * half_arc * float(index + 1) / float(segments))
		surface.set_uv(Vector2(0.5, 0.0))
		surface.add_vertex(Vector3(0.0, 0.028, 0.0))
		surface.set_uv(Vector2(0.0, 1.0))
		surface.add_vertex(Vector3(sin(first) * radius, 0.028, -cos(first) * radius))
		surface.set_uv(Vector2(1.0, 1.0))
		surface.add_vertex(Vector3(sin(second) * radius, 0.028, -cos(second) * radius))
	return surface.commit()
