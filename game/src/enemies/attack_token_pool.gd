class_name AttackTokenPool
extends RefCounted
## One shared token prevents two hostile wind-ups from overlapping.

var _holder_id := 0


func try_acquire(enemy_id: int) -> bool:
	if enemy_id == 0 or (_holder_id != 0 and _holder_id != enemy_id):
		return false
	_holder_id = enemy_id
	return true


func release(enemy_id: int) -> void:
	if _holder_id == enemy_id:
		_holder_id = 0


func holder() -> int:
	return _holder_id
