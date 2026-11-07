class_name GroundDrop
extends Area3D
## Runtime-only pickup created after an O5-confirmed inventory drop.

const INTERACT_RADIUS_M := 1.5
const DROP_MATERIAL := preload("res://art/materials/env_wood_dark.tres")

signal retriever_entered(drop: GroundDrop)
signal retriever_exited(drop: GroundDrop)

var item: ItemInstance


func configure(p_item: ItemInstance, floor_position: Vector3) -> void:
	item = p_item
	global_position = floor_position
	set_meta("greybox_role", "ground_drop_runtime_placeholder")
	var collision := CollisionShape3D.new()
	collision.name = "InteractionRange"
	var range := SphereShape3D.new()
	range.radius = INTERACT_RADIUS_M
	collision.shape = range
	add_child(collision)
	var visual := MeshInstance3D.new()
	visual.name = "ItemBlock"
	var mesh := BoxMesh.new()
	var footprint := item.effective_size() if item != null else Vector2i.ONE
	mesh.size = Vector3(maxf(0.35, float(footprint.x) * 0.35), 0.25, maxf(0.35, float(footprint.y) * 0.35))
	visual.mesh = mesh
	visual.position.y = 0.125
	visual.material_override = DROP_MATERIAL
	add_child(visual)


func _ready() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"retriever"):
		retriever_entered.emit(self)


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"retriever"):
		retriever_exited.emit(self)
