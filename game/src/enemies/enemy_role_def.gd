class_name EnemyRoleDef
extends Resource
## Immutable role data. A scene embeds one of these resources so every number is tunable.

@export var role_id: StringName = &"tax_guard"
@export_range(1, 999, 1) var max_hp := 60
@export_range(0.1, 8.0, 0.1) var move_speed := 1.6
@export_range(0.1, 20.0, 0.1) var perception_radius := 6.0
@export_range(0.0, 180.0, 1.0) var view_half_arc_deg := 60.0
@export_range(0.0, 10.0, 0.1) var leash_radius := 3.0
@export_range(0.6, 3.0, 0.05) var windup_seconds := 0.8
@export_range(0.0, 2.0, 0.05) var active_seconds := 0.15
@export_range(0.0, 3.0, 0.05) var recover_seconds := 0.9
@export_range(0.0, 8.0, 0.05) var min_attack_interval := 2.0
@export_range(0, 999, 1) var damage := 15
@export_range(0.0, 8.0, 0.1) var attack_range := 1.8
@export_range(0.0, 360.0, 1.0) var attack_arc_deg := 100.0
@export_range(0.0, 1.0, 0.05) var withdraw_hp_ratio := 0.34
@export_range(0.0, 180.0, 1.0) var shield_half_arc_deg := 60.0
@export_range(0.0, 16.0, 0.1) var charge_speed := 0.0
@export_range(0.0, 4.0, 0.1) var charge_hitbox_width := 0.0
@export_range(0.0, 4.0, 0.1) var lane_width := 0.0


func is_valid() -> bool:
	if role_id not in [&"tax_guard", &"foreman"]:
		return false
	if windup_seconds < 0.6 or max_hp < 1 or move_speed <= 0.0:
		return false
	if role_id == &"foreman":
		return charge_speed > 0.0 and charge_hitbox_width > 0.0 and lane_width > 0.0
	return true


static func tax_guard() -> EnemyRoleDef:
	return EnemyRoleDef.new()


static func foreman() -> EnemyRoleDef:
	var result := EnemyRoleDef.new()
	result.role_id = &"foreman"
	result.max_hp = 90
	result.move_speed = 1.8
	result.perception_radius = 9.0
	result.view_half_arc_deg = 70.0
	result.leash_radius = 1.5
	result.windup_seconds = 1.0
	result.active_seconds = 0.0
	result.recover_seconds = 1.5
	result.min_attack_interval = 2.5
	result.damage = 30
	result.attack_range = 0.0
	result.attack_arc_deg = 0.0
	result.shield_half_arc_deg = 0.0
	result.charge_speed = 9.0
	result.charge_hitbox_width = 1.2
	result.lane_width = 1.6
	return result
