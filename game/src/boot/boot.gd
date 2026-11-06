extends Control
## Placeholder boot screen: title plus build/channel label.
## Replaced by the vertical-slice flow (briefing → run) in later sprints.

const OUTER_PIER_SCENE := preload("res://src/world/zone_a_outer_pier.tscn")
const RETRIEVER_SCENE := preload("res://src/player/retriever.tscn")

@onready var _env_badge: Label = $EnvBadge
@onready var _build_label: Label = $BuildLabel
@onready var _enter_outer_pier_button: Button = $EnterOuterPierButton


func _ready() -> void:
	_build_label.text = AppEnv.label()
	_env_badge.text = AppEnv.channel.to_upper()
	_env_badge.visible = bool(AppEnv.get_flag("app", "show_env_badge", false))
	_enter_outer_pier_button.pressed.connect(_on_enter_outer_pier_pressed)


func _on_enter_outer_pier_pressed() -> void:
	get_tree().change_scene_to_node(build_outer_pier_world())


func build_outer_pier_world() -> Node3D:
	var world := OUTER_PIER_SCENE.instantiate() as Node3D
	var retriever := RETRIEVER_SCENE.instantiate() as CharacterBody3D
	world.add_child(retriever)
	return world
