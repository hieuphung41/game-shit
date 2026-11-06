class_name TouchJoystick
extends Control
## A one-hand virtual joystick. Mouse input follows the same path for desktop and web testing.

signal direction_changed(direction: Vector2)

const TRACK_COLOR := Color(0.541176, 0.505882, 0.450980, 0.72)
const HANDLE_COLOR := Color(0.913725, 0.878431, 0.796078, 0.88)
const OUTLINE_COLOR := Color(0.133333, 0.113725, 0.098039, 0.92)

var _active_pointer: int = -1
var _direction := Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _active_pointer == -1:
			_active_pointer = event.index
			_set_direction(_local_event_position(event.position))
		elif not event.pressed and event.index == _active_pointer:
			_active_pointer = -1
			_set_direction(Vector2.ZERO)
		accept_event()
	elif event is InputEventScreenDrag and event.index == _active_pointer:
		_set_direction(_local_event_position(event.position))
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_active_pointer = -2
			_set_direction(_local_event_position(event.position))
		elif _active_pointer == -2:
			_active_pointer = -1
			_set_direction(Vector2.ZERO)
		accept_event()
	elif event is InputEventMouseMotion and _active_pointer == -2:
		_set_direction(_local_event_position(event.position))
		accept_event()


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.5
	draw_circle(center, radius, TRACK_COLOR, false, 3.0, true)
	draw_circle(center + _direction * radius * 0.55, radius * 0.28, HANDLE_COLOR, true, -1.0, true)
	draw_arc(center, radius * 0.28, 0.0, TAU, 24, OUTLINE_COLOR, 2.0, true)


func _local_event_position(screen_position: Vector2) -> Vector2:
	return screen_position - global_position


func _set_direction(local_position: Vector2) -> void:
	var next_direction := TouchJoystickLogic.direction_for_local_position(local_position, size)
	if _direction.is_equal_approx(next_direction):
		return
	_direction = next_direction
	direction_changed.emit(_direction)
	queue_redraw()
