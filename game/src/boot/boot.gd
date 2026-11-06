extends Control
## Entry point for the S02 loop. The button starts S1 briefing, not Zone A.

const BRIEFING_FLOW_SCENE := "res://src/flow/briefing_flow.tscn"

@onready var _env_badge: Label = $EnvBadge
@onready var _build_label: Label = $BuildLabel
@onready var _enter_outer_pier_button: Button = $EnterOuterPierButton


func _ready() -> void:
	_build_label.text = AppEnv.label()
	_env_badge.text = AppEnv.channel.to_upper()
	_env_badge.visible = bool(AppEnv.get_flag("app", "show_env_badge", false))
	_enter_outer_pier_button.pressed.connect(_on_enter_outer_pier_pressed)


func _on_enter_outer_pier_pressed() -> void:
	RunSession.begin_briefing()
	get_tree().change_scene_to_file(BRIEFING_FLOW_SCENE)
