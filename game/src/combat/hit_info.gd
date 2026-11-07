class_name HitInfo
extends RefCounted
## Immutable-in-practice description of one combat hit.

var source_id := 0
var kind: StringName = &""
var damage := 0
var origin := Vector3.ZERO
var direction := Vector3.ZERO
var knockback_m := 0.0
var blockable := true


func _init(
	p_source_id: int = 0,
	p_kind: StringName = &"",
	p_damage: int = 0,
	p_origin: Vector3 = Vector3.ZERO,
	p_direction: Vector3 = Vector3.ZERO,
	p_knockback_m: float = 0.0,
	p_blockable: bool = true,
) -> void:
	source_id = p_source_id
	kind = p_kind
	damage = maxi(0, p_damage)
	origin = p_origin
	direction = p_direction
	knockback_m = maxf(0.0, p_knockback_m)
	blockable = p_blockable
