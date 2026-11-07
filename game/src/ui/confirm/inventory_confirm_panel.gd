class_name InventoryConfirmPanel
extends Control
## O5i presents a pending inventory mutation. The owner alone calls the
## RetrieverInventory commit method after this panel emits accepted.

signal accepted()
signal cancelled()

const UI_OPEN_GUARD_SECONDS := 0.3

var _item: ItemInstance
var _kind: StringName = &"drop"
var _anchor := Vector2i.ZERO
var _rotated := false
var _opened_at_msec := 0
var _confirmation_locked := false


func _ready() -> void:
	theme = UiTheme.create()
	_build()


func configure(item: ItemInstance, kind: StringName, anchor: Vector2i = Vector2i.ZERO, rotated: bool = false) -> void:
	_item = item
	_kind = kind
	_anchor = anchor
	_rotated = rotated
	if is_inside_tree():
		_build()


func confirm() -> void:
	if _confirmation_locked or _input_guard_active():
		return
	_confirmation_locked = true
	var accept_button := get_node_or_null("InventoryConfirmPanel/AcceptButton") as Button
	if accept_button != null:
		accept_button.disabled = true
	accepted.emit()


func cancel() -> void:
	if not _input_guard_active():
		cancelled.emit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and not _input_guard_active():
		cancelled.emit()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"ui_accept"):
		var accept_button := get_node_or_null("InventoryConfirmPanel/AcceptButton") as Button
		if accept_button != null and get_viewport().gui_get_focus_owner() == accept_button:
			confirm()
			get_viewport().set_input_as_handled()


func _build() -> void:
	_confirmation_locked = false
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var panel := Panel.new()
	panel.name = "InventoryConfirmPanel"
	panel.position = Vector2(312, 184)
	panel.size = Vector2(296, 392)
	add_child(panel)
	var is_withdraw := _kind == &"withdraw"
	var title_key: StringName = &"INVENTORY_CONFIRM_WITHDRAW_TITLE" if is_withdraw else &"INVENTORY_CONFIRM_DROP_TITLE"
	var title := _label("Title", title_key, 28)
	title.position = Vector2(16, 12)
	# O5i reserves y=196..260 for a two-line localized confirmation question.
	title.size = Vector2(264, 64)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.clip_text = true
	panel.add_child(title)
	var item_row := _static_label("ItemRow", _item_text(), 24)
	item_row.position = Vector2(16, 80)
	item_row.size = Vector2(264, 40)
	item_row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item_row.clip_text = true
	panel.add_child(item_row)
	var target := _static_label("TargetRow", _target_text(is_withdraw), 24)
	target.position = Vector2(16, 124)
	target.size = Vector2(264, 40)
	panel.add_child(target)
	if is_withdraw:
		var seal_change := _static_label("SealChange", _seal_change_text(), 24)
		seal_change.position = Vector2(16, 144)
		seal_change.size = Vector2(264, 20)
		panel.add_child(seal_change)
	var body_key := _body_key(is_withdraw)
	var body := _body_label("Body", body_key, 24)
	# O5i reserves global y=352..464 for the complete consequence copy.
	# The seal-change row sits above it, so withdraw does not reduce this space.
	body.position = Vector2(16, 168)
	body.size = Vector2(264, 112)
	panel.add_child(body)
	var cancel_button := _button("CancelButton", &"CONFIRM_BUTTON_CANCEL", Vector2(16, 288), Vector2(128, 96))
	cancel_button.pressed.connect(cancel)
	panel.add_child(cancel_button)
	var accept_key: StringName = &"INVENTORY_CONFIRM_WITHDRAW_ACCEPT" if is_withdraw else &"INVENTORY_CONFIRM_DROP_ACCEPT"
	var accept_button := _button("AcceptButton", accept_key, Vector2(160, 288), Vector2(120, 96))
	accept_button.pressed.connect(confirm)
	panel.add_child(accept_button)
	_opened_at_msec = Time.get_ticks_msec()
	# O5i can open from a grid touch, which leaves focus on the dock beneath it.
	# Defer until this control is in the viewport so ui_accept always targets O5i.
	accept_button.call_deferred("grab_focus")


func _body_key(is_withdraw: bool) -> StringName:
	if is_withdraw and _is_evidence():
		return &"INVENTORY_CONFIRM_WITHDRAW_EVIDENCE_BODY"
	if not is_withdraw and _is_evidence():
		return &"INVENTORY_CONFIRM_DROP_EVIDENCE_BODY"
	return &"INVENTORY_CONFIRM_WITHDRAW_BODY" if is_withdraw else &"INVENTORY_CONFIRM_DROP_BODY"


func _item_text() -> String:
	if _item == null or _item.definition == null:
		return ""
	var quantity := tr(&"CARD_QUANTITY_SUFFIX").format({"quantity": _item.quantity}) if _item.quantity > 1 else ""
	var footprint := _item.definition.size
	if _rotated and footprint.x != footprint.y:
		footprint = Vector2i(footprint.y, footprint.x)
	return "□ " + _item.definition.localized_display_name() + quantity + " · " + tr(&"INVENTORY_FOOTPRINT_CHIP").format({"w": footprint.x, "h": footprint.y})


func _target_text(is_withdraw: bool) -> String:
	if not is_withdraw:
		return tr(&"INVENTORY_CONFIRM_TARGET_GROUND")
	return tr(&"INVENTORY_CONFIRM_TARGET_BACKPACK_ANCHOR").format({"column": _anchor.x + 1, "row": _anchor.y + 1})


func _seal_change_text() -> String:
	var source_key: StringName = &"INVENTORY_SEAL_LABEL_SEALED_NOT_EXTRACTED" if _is_evidence() else &"INVENTORY_SEAL_LABEL_SEALED"
	var target_key: StringName = &"INVENTORY_SEAL_LABEL_NOT_EXTRACTED" if _is_evidence() else &"INVENTORY_SEAL_LABEL_UNSEALED"
	return "▣ " + tr(source_key) + " → " + tr(target_key)


func _is_evidence() -> bool:
	return _item != null and _item.definition != null and _item.definition.item_category == ItemDef.Category.EVIDENCE


func _input_guard_active() -> bool:
	return Time.get_ticks_msec() - _opened_at_msec < int(UI_OPEN_GUARD_SECONDS * 1000.0)


func _label(node_name: String, key: StringName, font_size: int) -> Label:
	return _static_label(node_name, tr(key), font_size)


## RichTextLabel does not expand to its unwrapped text minimum, so its fixed
## O5i rect can safely accommodate the four allowed body lines.
func _body_label(node_name: String, key: StringName, font_size: int) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.name = node_name
	label.text = tr(key)
	label.fit_content = false
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("normal_font_size", font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _static_label(node_name: String, value: String, font_size: int) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _button(node_name: String, key: StringName, at: Vector2, dimensions: Vector2) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = tr(key)
	button.position = at
	button.size = dimensions
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 24)
	return button
