class_name UiTheme
extends RefCounted
## Shared S02 UI theme. Colours are from the palette's `ui` lane.

const PAPER := Color("e9e0cb")
const INK := Color("221d19")
const STAMP_RED := Color("a3362a")
const MUTED := Color("8a8173")


static func create() -> Theme:
	var theme := Theme.new()
	theme.set_default_font_size(20)
	theme.set_color("font_color", "Label", INK)
	theme.set_color("font_color", "Button", PAPER)
	# Disabled actions remain informational (not blank): the lock/progress icon
	# and localized label need the same paper-on-muted contrast as the panel.
	theme.set_color("font_disabled_color", "Button", PAPER)
	theme.set_stylebox("normal", "Button", _button_style(INK, PAPER, 2))
	theme.set_stylebox("hover", "Button", _button_style(STAMP_RED, PAPER, 3))
	theme.set_stylebox("pressed", "Button", _button_style(STAMP_RED.darkened(0.18), PAPER, 3))
	theme.set_stylebox("disabled", "Button", _button_style(MUTED, PAPER.darkened(0.22), 2))
	theme.set_stylebox("panel", "Panel", _panel_style())
	return theme


static func _button_style(background: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(2)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	return style


static func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PAPER
	style.border_color = INK
	style.set_border_width_all(3)
	style.set_corner_radius_all(2)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style
