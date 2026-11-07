class_name HoldWaveDef
extends Resource
## The fixed S8 schedule. Entries are data so a designer can retime them without code.

@export_range(2.0, 10.0, 0.1) var cue_lead_seconds := 3.0
@export var guard_enter_camera_at := 3.0
@export var foreman_cue_at := 7.0
@export var foreman_enter_camera_at := 10.0
# A zero value derives the pre-alert speed from the authored off-camera route
# and the entry timestamp. A positive value is an explicit designer override.
@export_range(0.0, 20.0, 0.1) var guard_approach_speed := 0.0
@export_range(0.0, 20.0, 0.1) var foreman_approach_speed := 0.0


func is_valid() -> bool:
	return cue_lead_seconds >= 2.0 \
		and guard_enter_camera_at >= cue_lead_seconds \
		and foreman_enter_camera_at >= foreman_cue_at + 2.0 \
		and foreman_enter_camera_at < ExtractPierAFlow.EXTRACT_HOLD_SECONDS \
		and guard_approach_speed >= 0.0 and foreman_approach_speed >= 0.0
