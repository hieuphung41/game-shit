extends RefCounted
## Assertion helper handed to every test. Records failures instead of
## stopping, so the runner always reaches quit() with a real exit code.

var failures: PackedStringArray = []
var tree: SceneTree


func eq(actual: Variant, expected: Variant, label: String = "") -> bool:
	if typeof(actual) == typeof(expected) and actual == expected:
		return true
	failures.append("%s: expected %s, got %s" % [label, var_to_str(expected), var_to_str(actual)])
	return false


func ok(condition: bool, label: String = "") -> bool:
	if condition:
		return true
	failures.append("%s: expected true" % label)
	return false
