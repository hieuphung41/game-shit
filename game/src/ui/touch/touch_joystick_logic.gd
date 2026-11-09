class_name TouchJoystickLogic
extends RefCounted
## Pure touch-region math shared by the virtual joystick and its tests.

const DEADZONE_RATIO := 0.15
const NO_ACTIVE_POINTER := -1
const MOUSE_POINTER := -2


static func direction_for_local_position(local_position: Vector2, region_size: Vector2) -> Vector2:
	var radius := minf(region_size.x, region_size.y) * 0.5
	if is_zero_approx(radius):
		return Vector2.ZERO
	var raw_direction := (local_position - region_size * 0.5) / radius
	if raw_direction.length() <= DEADZONE_RATIO:
		return Vector2.ZERO
	return raw_direction.limit_length()


static func direction_for_screen_position(screen_position: Vector2, screen_to_local: Transform2D, region_size: Vector2) -> Vector2:
	return direction_for_local_position(local_position_for_screen_position(screen_position, screen_to_local), region_size)


static func local_position_for_screen_position(screen_position: Vector2, screen_to_local: Transform2D) -> Vector2:
	return screen_to_local * screen_position


static func claim_pointer(active_pointer: int, candidate_pointer: int) -> int:
	return candidate_pointer if active_pointer == NO_ACTIVE_POINTER else active_pointer


static func release_pointer(active_pointer: int, released_pointer: int) -> int:
	return NO_ACTIVE_POINTER if active_pointer == released_pointer else active_pointer
