class_name TouchJoystickLogic
extends RefCounted
## Pure touch-region math shared by the virtual joystick and its tests.

const DEADZONE_RATIO := 0.15


static func direction_for_local_position(local_position: Vector2, region_size: Vector2) -> Vector2:
	var radius := minf(region_size.x, region_size.y) * 0.5
	if is_zero_approx(radius):
		return Vector2.ZERO
	var raw_direction := (local_position - region_size * 0.5) / radius
	if raw_direction.length() <= DEADZONE_RATIO:
		return Vector2.ZERO
	return raw_direction.limit_length()
