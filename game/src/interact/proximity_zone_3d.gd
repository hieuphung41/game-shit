class_name ProximityZone3D
extends Area3D
## Area3D adapter for world anchors. Its owner supplies the ExtractPierAFlow
## setters, leaving the flow itself scene-free.

signal retriever_entered()
signal retriever_exited()

var radius_m := 1.0


func configure(anchor: Node3D, p_radius_m: float) -> void:
	radius_m = p_radius_m
	if anchor.is_inside_tree():
		global_position = anchor.global_position
	else:
		position = anchor.position
	var collision := get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision == null:
		collision = CollisionShape3D.new()
		collision.name = "CollisionShape3D"
		add_child(collision)
	var shape := SphereShape3D.new()
	shape.radius = radius_m
	collision.shape = shape


func _ready() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"retriever"):
		retriever_entered.emit()


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"retriever"):
		retriever_exited.emit()
