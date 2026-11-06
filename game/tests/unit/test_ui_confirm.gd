extends RefCounted

const CONFIRM_SCENE := preload("res://src/ui/confirm/confirm_dialog.tscn")


func test_ui_confirm_emits_accept_and_cancel_only_from_buttons(t) -> bool:
	var dialog := CONFIRM_SCENE.instantiate() as ConfirmDialog
	var accepted: Array[bool] = []
	var cancelled: Array[bool] = []
	dialog.accepted.connect(func() -> void: accepted.append(true))
	dialog.cancelled.connect(func() -> void: cancelled.append(true))
	t.tree.root.add_child(dialog)
	await t.tree.process_frame
	dialog._opened_at_msec = -1000
	t.ok(not dialog._input_guard_active(), "dialog accepts input after the open guard")
	(dialog.get_node("ConfirmPanel/AcceptButton") as Button).pressed.emit()
	(dialog.get_node("ConfirmPanel/CancelButton") as Button).pressed.emit()
	t.eq(accepted.size(), 1, "accept emits once")
	t.eq(cancelled.size(), 1, "cancel emits once")
	t.ok((dialog.get_node("ConfirmPanel/Body") as Label).text.contains("20"), "hold duration is formatted into body")
	dialog.queue_free()
	await t.tree.process_frame
	return true


func test_ui_confirm_keeps_r6_touch_and_cancel_available_without_focus(t) -> bool:
	var joystick := TouchJoystick.new()
	joystick.position = Vector2(0.0, 460.0)
	joystick.size = Vector2(260.0, 260.0)
	var directions: Array[Vector2] = []
	joystick.direction_changed.connect(func(direction: Vector2) -> void: directions.append(direction))
	var dialog := CONFIRM_SCENE.instantiate() as ConfirmDialog
	var cancelled: Array[bool] = []
	dialog.cancelled.connect(func() -> void: cancelled.append(true))
	t.tree.root.add_child(joystick)
	t.tree.root.add_child(dialog)
	await t.tree.process_frame
	dialog._opened_at_msec = -1000
	t.ok(joystick.get_global_rect().has_point(Vector2(130.0, 590.0)), "R6 point is inside the joystick")
	_push_touch(t.tree.root.get_viewport(), Vector2(130.0, 590.0), true)
	await t.tree.process_frame
	t.eq(directions.size(), 1, "O5 ignored backdrop passes R6 touch to the joystick")
	_push_cancel(t.tree.root.get_viewport())
	await t.tree.process_frame
	t.eq(cancelled.size(), 1, "O5 receives ui_cancel without GUI focus")
	dialog.queue_free()
	joystick.queue_free()
	await t.tree.process_frame
	return true


func _push_touch(viewport: Viewport, position: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = position
	event.pressed = pressed
	viewport.push_input(event, true)


func _push_cancel(viewport: Viewport) -> void:
	var event := InputEventAction.new()
	event.action = &"ui_cancel"
	event.pressed = true
	viewport.push_input(event)
