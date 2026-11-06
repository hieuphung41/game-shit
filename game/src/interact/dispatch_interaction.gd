class_name DispatchInteraction
extends RefCounted
## Pure dispatch-desk range rule. The scene adapter owns Area3D lifecycle.

const DESK_INTERACT_RADIUS_M := 2.0


static func is_in_range(retriever_position: Vector3, desk_position: Vector3, radius: float = DESK_INTERACT_RADIUS_M) -> bool:
	var horizontal_delta := retriever_position - desk_position
	horizontal_delta.y = 0.0
	return horizontal_delta.length_squared() <= radius * radius
