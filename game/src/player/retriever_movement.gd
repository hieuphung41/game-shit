class_name RetrieverMovement
extends RefCounted
## Pure movement rules for the Retriever's camera-relative ground movement.


static func camera_relative_direction(stick_direction: Vector2, camera_basis: Basis) -> Vector3:
	var clamped_stick := stick_direction.limit_length()
	if is_zero_approx(clamped_stick.length_squared()):
		return Vector3.ZERO
	var camera_right := Vector3(camera_basis.x.x, 0.0, camera_basis.x.z).normalized()
	var camera_forward := Vector3(-camera_basis.z.x, 0.0, -camera_basis.z.z).normalized()
	var world_direction := camera_right * clamped_stick.x - camera_forward * clamped_stick.y
	return world_direction.normalized() * clamped_stick.length()
