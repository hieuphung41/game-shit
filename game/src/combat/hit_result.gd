class_name HitResult
extends RefCounted
## Result returned by CombatTarget.receive_hit().

var applied := 0
var blocked := false
var ignored_reason: StringName = &""


func _init(p_applied: int = 0, p_blocked: bool = false, p_ignored_reason: StringName = &"") -> void:
	applied = maxi(0, p_applied)
	blocked = p_blocked
	ignored_reason = p_ignored_reason
