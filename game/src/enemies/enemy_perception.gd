class_name EnemyPerception
extends RefCounted
## Perception owns sight, proximity and last-known state; movement never queries it directly.

const PROXIMITY_RADIUS := 2.0
const LOSE_TRACK_SECONDS := 4.0

var last_known_position := Vector3.ZERO
var sees_player := false
var lost_for_seconds := 0.0
var _recently_hit := false


func notify_hit_by_player() -> void:
	_recently_hit = true


func tick(
	delta: float,
	observer_position: Vector3,
	facing: Vector3,
	player_position: Vector3,
	has_line_of_sight: bool,
	perception_radius: float,
	view_half_arc_deg: float,
) -> bool:
	var flat_offset := Vector3(player_position.x - observer_position.x, 0.0, player_position.z - observer_position.z)
	var distance := flat_offset.length()
	var in_proximity := distance <= PROXIMITY_RADIUS
	var in_view_arc := _is_in_arc(facing, flat_offset, view_half_arc_deg)
	var detected := _recently_hit or (has_line_of_sight and (in_proximity or (distance <= perception_radius and in_view_arc)))
	_recently_hit = false
	if detected:
		sees_player = true
		lost_for_seconds = 0.0
		last_known_position = player_position
	else:
		lost_for_seconds += maxf(delta, 0.0)
		if lost_for_seconds >= LOSE_TRACK_SECONDS:
			sees_player = false
	return sees_player


func _is_in_arc(facing: Vector3, offset: Vector3, half_arc_deg: float) -> bool:
	if offset.length_squared() <= 0.0001:
		return true
	var flat_facing := Vector3(facing.x, 0.0, facing.z)
	if flat_facing.length_squared() <= 0.0001:
		return true
	return flat_facing.normalized().dot(offset.normalized()) >= cos(deg_to_rad(half_arc_deg))
