extends Control
## Entry point for the S02 loop. The button starts S1 briefing, not Zone A.

const BRIEFING_FLOW_SCENE := "res://src/flow/briefing_flow.tscn"
const RECOVERY_FIXTURE_MENU := preload("res://src/debug/recovery_fixture_menu.gd")
const RECOVERY_FIXTURE_LAUNCH := preload("res://src/debug/recovery_fixture_launch.gd")
const RECOVERY_CONTRACT_SCENE := preload("res://src/ui/recovery/recovery_contract_screen.tscn")

@onready var _env_badge: Label = $EnvBadge
@onready var _build_label: Label = $BuildLabel
@onready var _enter_outer_pier_button: Button = $EnterOuterPierButton


func _ready() -> void:
	_build_label.text = AppEnv.label()
	_env_badge.text = AppEnv.channel.to_upper()
	_env_badge.visible = bool(AppEnv.get_flag("app", "show_env_badge", false))
	_enter_outer_pier_button.pressed.connect(_on_enter_outer_pier_pressed)
	if bool(AppEnv.get_flag("app", "debug_menu", false)):
		_add_fixture_menu()


func _on_enter_outer_pier_pressed() -> void:
	get_tree().change_scene_to_file(BRIEFING_FLOW_SCENE)


func _add_fixture_menu() -> void:
	var menu := RECOVERY_FIXTURE_MENU.new() as RecoveryFixtureMenu
	add_child(menu)
	menu.fixture_requested.connect(_on_fixture_requested)


func _on_fixture_requested(fixture_id: StringName) -> void:
	if fixture_id == &"recovery":
		_open_recovery_contract()
		return
	var launcher := RECOVERY_FIXTURE_LAUNCH.new() as RecoveryFixtureLaunch
	get_tree().root.add_child(launcher)
	launcher.launch(fixture_id)


## Debug alias of S11's recovery action; it only accepts the real in-memory S11 result.
func _open_recovery_contract() -> void:
	if not RunSession.is_recovery_briefing():
		return
	var screen := RECOVERY_CONTRACT_SCENE.instantiate() as RecoveryContractScreen
	add_child(screen)
	screen.briefing_requested.connect(_enter_recovery_briefing)


func _enter_recovery_briefing() -> void:
	get_tree().change_scene_to_file(BRIEFING_FLOW_SCENE)
