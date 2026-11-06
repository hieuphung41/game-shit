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
