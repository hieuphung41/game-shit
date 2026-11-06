class_name RetrieverController
extends CharacterBody3D
## Touch-first movement controller for the Retriever in the vertical-slice greybox.

@export var movement_speed: float = 4.0

@onready var _camera: Camera3D = get_parent().get_node_or_null("CameraIsometric") as Camera3D
@onready var _touch_joystick: TouchJoystick = $TouchControls/TouchJoystick

var _camera_follow_offset := Vector3.ZERO
var _touch_direction := Vector2.ZERO


func _ready() -> void:
	_touch_joystick.direction_changed.connect(_on_touch_direction_changed)
	if _camera != null:
		_camera_follow_offset = _camera.global_position - global_position


func _physics_process(_delta: float) -> void:
	if _camera == null:
		return
	var direction := RetrieverMovement.camera_relative_direction(_active_direction(), _camera.global_transform.basis)
	velocity = Vector3(direction.x * movement_speed, 0.0, direction.z * movement_speed)
	move_and_slide()
	_follow_camera()


func _active_direction() -> Vector2:
	if not is_zero_approx(_touch_direction.length_squared()):
		return _touch_direction
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")


func _follow_camera() -> void:
	_camera.global_position = global_position + _camera_follow_offset


func _on_touch_direction_changed(direction: Vector2) -> void:
	_touch_direction = direction
