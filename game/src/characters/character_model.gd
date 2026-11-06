extends Node3D
## CC0 model wrapper: combat code supplies only the logical state names from S03 §10.

const IDLE_SOURCE: PackedScene = preload("res://assets/third_party/kenney-animated-characters-protagonists/source_idle.glb")
const RUN_SOURCE: PackedScene = preload("res://assets/third_party/kenney-animated-characters-protagonists/source_run.glb")
const IDLE_SOURCE_CLIP := &"Root|Idle"
const RUN_SOURCE_CLIP := &"Root|Run"

@export var state_clips: Dictionary = {}

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	# The CC0 pack supplies the mesh rig and the two motions as separate FBXs.
	# Re-target their imported tracks by bone name so the clips animate this scene's Skeleton3D.
	_replace_placeholder_clip(&"idle", IDLE_SOURCE, IDLE_SOURCE_CLIP)
	_replace_placeholder_clip(&"run", RUN_SOURCE, RUN_SOURCE_CLIP)


func play_state(name: StringName) -> void:
	var clip: StringName = state_clips.get(name, &"idle")
	if not animation_player.has_animation(clip):
		clip = &"idle"
	animation_player.play(clip)


func supported_states() -> PackedStringArray:
	var states := PackedStringArray()
	for state: Variant in state_clips:
		states.append(StringName(state))
	states.sort()
	return states


func _replace_placeholder_clip(clip_name: StringName, source_scene: PackedScene, source_clip: StringName) -> void:
	var skeleton := find_child("Skeleton3D", true, false) as Skeleton3D
	if skeleton == null:
		push_error("CC0 character model is missing Skeleton3D")
		return
	var source_root := source_scene.instantiate() as Node3D
	var source_player := source_root.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if source_player == null or not source_player.has_animation(source_clip):
		push_error("CC0 source animation is missing %s" % source_clip)
		source_root.free()
		return
	add_child(source_root)
	var source_animation := source_player.get_animation(source_clip)
	var retargeted := Animation.new()
	retargeted.resource_name = String(clip_name)
	retargeted.length = source_animation.length
	retargeted.loop_mode = Animation.LOOP_LINEAR
	for source_track: int in source_animation.get_track_count():
		var source_bone := source_root.get_node_or_null(source_animation.track_get_path(source_track)) as Node3D
		if source_bone == null:
			continue
		var property := _bone_property(source_animation.track_get_type(source_track))
		var bone_index := skeleton.find_bone(source_bone.name)
		if property.is_empty() or bone_index < 0:
			continue
		var track := retargeted.add_track(Animation.TYPE_VALUE)
		# Skeleton3D exposes each pose component as bones/<index>/[position|rotation|scale].
		retargeted.track_set_path(track, NodePath("%s:bones/%d/%s" % [get_path_to(skeleton), bone_index, property]))
		for key: int in source_animation.track_get_key_count(source_track):
			retargeted.track_insert_key(track, source_animation.track_get_key_time(source_track, key), source_animation.track_get_key_value(source_track, key))
	source_root.free()
	var library := animation_player.get_animation_library(&"")
	library.remove_animation(clip_name)
	library.add_animation(clip_name, retargeted)
func _bone_property(track_type: Animation.TrackType) -> String:
	match track_type:
		Animation.TYPE_POSITION_3D:
			return "position"
		Animation.TYPE_ROTATION_3D:
			return "rotation"
		Animation.TYPE_SCALE_3D:
			return "scale"
	return ""
