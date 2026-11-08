class_name RecoveryFixtureMenu
extends PanelContainer
## Staging-only launcher for controlled Contract 1 readiness states.

signal fixture_requested(fixture_id: StringName)

const FIXTURES: Array[StringName] = [&"c1", &"c2", &"c3", &"recovery"]

var _buttons: Dictionary = {}


func _ready() -> void:
	name = "RecoveryFixtureMenu"
	var column := VBoxContainer.new()
	column.name = "Actions"
	add_child(column)
	var title := Label.new()
	title.text = tr("DEBUG_FIXTURE_MENU_TITLE")
	column.add_child(title)
	for fixture_id in FIXTURES:
		var button := Button.new()
		button.name = "%sButton" % String(fixture_id).to_upper()
		button.text = tr(_label_key(fixture_id))
		button.pressed.connect(_request_fixture.bind(fixture_id))
		column.add_child(button)
		_buttons[fixture_id] = button
	set_recovery_available(RunSession.is_recovery_briefing())


func set_recovery_available(available: bool) -> void:
	var button := _buttons.get(&"recovery") as Button
	if button != null:
		button.disabled = not available


func button_for(fixture_id: StringName) -> Button:
	return _buttons.get(fixture_id) as Button


func _request_fixture(fixture_id: StringName) -> void:
	if fixture_id == &"recovery" and not RunSession.is_recovery_briefing():
		return
	fixture_requested.emit(fixture_id)


func _label_key(fixture_id: StringName) -> StringName:
	match fixture_id:
		&"c1": return &"DEBUG_FIXTURE_C1_LABEL"
		&"c2": return &"DEBUG_FIXTURE_C2_LABEL"
		&"c3": return &"DEBUG_FIXTURE_C3_LABEL"
		_: return &"DEBUG_FIXTURE_RECOVERY_LABEL"
