extends SceneTree
## Headless test runner. Usage (from repo root):
##   godot --headless --path game --script res://tests/run_tests.gd
## Discovers res://tests/unit/test_*.gd. Each suite extends RefCounted and
## declares `func test_<name>(t) -> bool` returning true at the end; `t` is a
## TestContext. A test that errors out (returns non-true) counts as failed.
## Exit code: 0 only if every test passed and at least one test ran.

const TEST_DIR := "res://tests/unit"
const TestContext := preload("res://tests/test_context.gd")

var passed := 0
var failed := 0


func _initialize() -> void:
	await process_frame
	for path in _test_files():
		await _run_suite(path)
	print("Results: %d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 or passed == 0 else 0)


func _run_suite(path: String) -> void:
	var script: GDScript = load(path)
	if script == null or not script.can_instantiate():
		failed += 1
		push_error("FAIL %s: cannot load suite" % path)
		return
	var suite: Object = script.new()
	for method in suite.get_method_list():
		var name: String = method["name"]
		if not name.begins_with("test_"):
			continue
		var t := TestContext.new()
		t.tree = self
		var result: Variant = await suite.call(name, t)
		if result == true and t.failures.is_empty():
			passed += 1
			print("PASS %s::%s" % [path.get_file(), name])
		else:
			failed += 1
			var why := "; ".join(t.failures) if not t.failures.is_empty() else "did not finish (runtime error?)"
			push_error("FAIL %s::%s — %s" % [path.get_file(), name, why])
	if suite is Node:
		suite.free()


func _test_files() -> PackedStringArray:
	var files := PackedStringArray()
	var dir := DirAccess.open(TEST_DIR)
	if dir == null:
		push_error("No test dir %s" % TEST_DIR)
		return files
	for file in dir.get_files():
		if file.begins_with("test_") and file.ends_with(".gd"):
			files.append("%s/%s" % [TEST_DIR, file])
	files.sort()
	return files
