class_name RetrieverCombatTuning
extends Resource
## Inspector-editable proposed S03 combat values. Runtime state stays in RetrieverCombat.

@export_range(1, 999, 1) var max_hp := 100
@export_range(0, 999, 1) var attack_damage := 20
@export_range(0.0, 2.0, 0.01) var attack_windup := 0.15
@export_range(0.0, 2.0, 0.01) var attack_active := 0.10
@export_range(0.0, 2.0, 0.01) var attack_recover := 0.25
@export_range(0.5, 4.0, 0.1) var attack_range := 1.6
@export_range(10.0, 360.0, 1.0) var attack_arc_deg := 120.0
@export_range(0.0, 6.0, 0.1) var assist_radius := 2.5
@export_range(0.0, 180.0, 1.0) var assist_half_arc_deg := 90.0
@export_range(0.1, 1.0, 0.01) var dodge_duration := 0.30
@export_range(0.5, 6.0, 0.1) var dodge_distance := 3.0
@export_range(0.0, 1.0, 0.01) var dodge_iframe := 0.25
@export_range(0.0, 5.0, 0.01) var dodge_cooldown := 0.8
@export_range(0.0, 1.0, 0.01) var guard_raise := 0.10
@export_range(0.0, 180.0, 1.0) var guard_half_arc_deg := 60.0
@export_range(0.0, 1.0, 0.01) var guard_move_ratio := 0.4
@export_range(0.0, 12.0, 0.1) var guard_track_radius := 6.0
@export_range(0, 999, 1) var remedy_heal := 40
@export_range(0.1, 5.0, 0.1) var remedy_use_seconds := 1.0
@export_range(0.0, 2.0, 0.01) var hitstun := 0.3
@export_range(0.0, 3.0, 0.01) var post_hit_invuln := 0.5
@export_range(0.0, 0.5, 0.01) var input_buffer := 0.15
@export_range(0.01, 0.1, 0.01) var max_tick_delta := 0.1


func is_valid() -> bool:
	return dodge_iframe <= dodge_duration
