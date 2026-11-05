extends Control
## Placeholder boot screen: title plus build/channel label.
## Replaced by the vertical-slice flow (briefing → run) in later sprints.

@onready var _env_badge: Label = $EnvBadge
@onready var _build_label: Label = $BuildLabel


func _ready() -> void:
	_build_label.text = AppEnv.label()
	_env_badge.text = AppEnv.channel.to_upper()
	_env_badge.visible = bool(AppEnv.get_flag("app", "show_env_badge", false))
