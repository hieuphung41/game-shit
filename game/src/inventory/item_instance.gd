class_name ItemInstance
extends RefCounted

var uid := 0
var def_id: StringName = &""
var quantity := 1
var item_location: StringName = &"ground"
var anchor := Vector2i.ZERO
var rotated := false
var definition: ItemDef


func _init(p_uid: int = 0, p_definition: ItemDef = null, p_quantity: int = 1) -> void:
	uid = p_uid
	definition = p_definition
	if definition != null:
		def_id = definition.id
	quantity = p_quantity


func effective_size() -> Vector2i:
	if definition == null:
		return Vector2i.ZERO
	if rotated and not definition.is_square():
		return Vector2i(definition.size.y, definition.size.x)
	return definition.size


func cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var footprint := effective_size()
	for y in footprint.y:
		for x in footprint.x:
			result.append(anchor + Vector2i(x, y))
	return result
