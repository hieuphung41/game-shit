class_name ItemRegistry
extends RefCounted

var _definitions: Dictionary = {}


func add(definition: ItemDef) -> void:
	_definitions[definition.id] = definition


func get_def(id: StringName) -> ItemDef:
	return _definitions.get(id) as ItemDef


func validate_defs() -> Array[String]:
	var errors: Array[String] = []
	for definition: ItemDef in _definitions.values():
		var error := definition.validation_error()
		if not error.is_empty():
			errors.append("%s: %s" % [definition.id, error])
	return errors
