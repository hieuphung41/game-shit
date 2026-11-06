extends Node3D
## Forces CC0 imported meshes through the approved matte material library.

@export var library_material: Material


func _ready() -> void:
	for node: Node in find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		mesh_instance.material_override = library_material
