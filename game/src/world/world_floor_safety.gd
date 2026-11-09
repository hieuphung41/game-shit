class_name WorldFloorSafety
extends RefCounted
## Pure playable-floor containment and recovery rules for the vertical slice.

const RETRIEVER_FLOOR_Y := 0.95
const FALL_RECOVERY_Y := -0.50
const ROUTE_D_BRIDGE := Rect2(Vector2(10.5, -36.95), Vector2(2.5, 2.0))

var _walkable_regions: Array[Rect2] = []
var _last_safe_position := Vector3.ZERO
var _has_last_safe_position := false
var _route_d_open := false


static func create_vertical_slice() -> WorldFloorSafety:
	var safety := WorldFloorSafety.new()
	# A, B, and D deliberately overlap at their seams. The bridge is only floor once
	# the authored RouteDPlanks collision has opened.
	safety.add_walkable_region(Rect2(Vector2(-7.0, -5.0), Vector2(14.0, 10.0)))
	safety.add_walkable_region(Rect2(Vector2(7.0, -34.95), Vector2(9.0, 35.0)))
	safety.add_walkable_region(Rect2(Vector2(9.25, -39.95), Vector2(5.5, 3.0)))
	safety.add_walkable_region(Rect2(Vector2(6.75, -48.45), Vector2(9.5, 8.5)))
	safety.add_walkable_region(Rect2(Vector2(6.75, -49.45), Vector2(8.5, 1.0)))
	return safety


func add_walkable_region(region: Rect2) -> void:
	_walkable_regions.append(region)


func set_route_d_open(open: bool) -> void:
	_route_d_open = open


func is_safe(position: Vector3) -> bool:
	if position.y < FALL_RECOVERY_Y:
		return false
	return _contains_ground_point(Vector2(position.x, position.z))


func reconcile(position: Vector3) -> Vector3:
	if is_safe(position):
		_last_safe_position = position
		_has_last_safe_position = true
		return position
	if _has_last_safe_position:
		return _last_safe_position
	return _nearest_safe_position(position)


func last_safe_position() -> Vector3:
	return _last_safe_position


func _contains_ground_point(point: Vector2) -> bool:
	for region: Rect2 in _walkable_regions:
		if region.has_point(point):
			return true
	return _route_d_open and ROUTE_D_BRIDGE.has_point(point)


func _nearest_safe_position(position: Vector3) -> Vector3:
	var point := Vector2(position.x, position.z)
	var nearest := Vector2.ZERO
	var nearest_distance := INF
	for region: Rect2 in _walkable_regions:
		var candidate := Vector2(
			clampf(point.x, region.position.x, region.end.x),
			clampf(point.y, region.position.y, region.end.y)
		)
		var distance: float = candidate.distance_squared_to(point)
		if distance < nearest_distance:
			nearest = candidate
			nearest_distance = distance
	if _route_d_open:
		var bridge_candidate := Vector2(
			clampf(point.x, ROUTE_D_BRIDGE.position.x, ROUTE_D_BRIDGE.end.x),
			clampf(point.y, ROUTE_D_BRIDGE.position.y, ROUTE_D_BRIDGE.end.y)
		)
		if bridge_candidate.distance_squared_to(point) < nearest_distance:
			nearest = bridge_candidate
	return Vector3(nearest.x, RETRIEVER_FLOOR_Y, nearest.y)
