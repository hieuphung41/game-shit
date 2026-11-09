class_name HudLayout
extends RefCounted
## Places HUD controls inside the platform safe area while retaining the 1280x720
## reference spacing from the UX specification.

const SAFE_MARGIN := 16.0
## All HUD measurements in the UX specs are authored against the usable part
## of a 1280x720 reference viewport (the outer 16 px safe inset is excluded).
const REFERENCE_SAFE_SIZE := Vector2(1248.0, 688.0)
const MAX_LAYOUT_SCALE := 1.5
const MIN_FONT_SIZE := 20
const SAFE_AREA_CONFIG_SECTION := "ui"
const SAFE_AREA_CONFIG_KEY := "use_display_safe_area"
const DANGER_CLOSE_OFFSET := Vector2(0, 176)
const DANGER_CLOSE_SIZE := Vector2(320, 128)


static func safe_rect(control: Control) -> Rect2:
	var viewport_size := control.get_viewport().get_visible_rect().size
	# Web builds on a notched phone must not be treated as desktop simply because
	# their feature tag is "web". The channel config owns that policy.
	if not bool(AppEnv.get_flag(SAFE_AREA_CONFIG_SECTION, SAFE_AREA_CONFIG_KEY, true)):
		return fallback_safe_rect(viewport_size)
	var window_size := Vector2(DisplayServer.window_get_size())
	if window_size.x <= 0.0 or window_size.y <= 0.0:
		return fallback_safe_rect(viewport_size)
	var window_rect := Rect2(Vector2(DisplayServer.window_get_position()), window_size)
	return safe_rect_from_display(viewport_size, window_rect, Rect2(DisplayServer.get_display_safe_area()))


static func fallback_safe_rect(viewport_size: Vector2) -> Rect2:
	return Rect2(Vector2(SAFE_MARGIN, SAFE_MARGIN), viewport_size - Vector2(SAFE_MARGIN * 2.0, SAFE_MARGIN * 2.0))


static func safe_rect_from_display(viewport_size: Vector2, window_rect: Rect2, display_safe_rect: Rect2) -> Rect2:
	var fallback := fallback_safe_rect(viewport_size)
	if window_rect.size.x <= 0.0 or window_rect.size.y <= 0.0:
		return fallback
	var safe_window_rect := display_safe_rect.intersection(window_rect)
	if safe_window_rect.size.x <= 0.0 or safe_window_rect.size.y <= 0.0:
		return fallback
	var scale := viewport_size / window_rect.size
	var safe_position := (safe_window_rect.position - window_rect.position) * scale
	var safe_end := (safe_window_rect.end - window_rect.position) * scale
	var safe := Rect2(safe_position, safe_end - safe_position)
	safe.position += Vector2(SAFE_MARGIN, SAFE_MARGIN)
	safe.size -= Vector2(SAFE_MARGIN * 2.0, SAFE_MARGIN * 2.0)
	return safe if safe.size.x > 0.0 and safe.size.y > 0.0 else fallback


## D1 is shared by CombatHud and full-screen overlays that must forward its
## one-tap cancel action. Keeping its safe-area geometry here prevents a
## visible button and its captured touch region from drifting apart.
static func danger_close_rect(control: Control) -> Rect2:
	var safe := safe_rect(control)
	var layout_scale := scale_for_safe(safe)
	return Rect2(safe.position + DANGER_CLOSE_OFFSET * layout_scale, DANGER_CLOSE_SIZE * layout_scale)


static func scale_for_safe(safe: Rect2) -> float:
	if safe.size.x <= 0.0 or safe.size.y <= 0.0:
		return 1.0
	# Fit is width-led on 4:3 and height-led on 20:9. The ceiling keeps the
	# hierarchy legible on very wide displays while preserving the same 4:3 fit.
	return minf(MAX_LAYOUT_SCALE, minf(safe.size.x / REFERENCE_SAFE_SIZE.x, safe.size.y / REFERENCE_SAFE_SIZE.y))


static func scale_for_control(control: Control) -> float:
	return scale_for_safe(safe_rect(control))


static func scaled_font_size(reference_size: int, layout_scale: float) -> int:
	return maxi(MIN_FONT_SIZE, roundi(float(reference_size) * layout_scale))


static func apply_font_scale(control: Control, reference_size: int, layout_scale: float) -> void:
	control.add_theme_font_size_override("font_size", scaled_font_size(reference_size, layout_scale))


static func place_top_left(control: Control, safe: Rect2, at: Vector2, dimensions: Vector2, layout_scale: float = -1.0) -> void:
	var scale := scale_for_safe(safe) if layout_scale < 0.0 else layout_scale
	control.set_anchors_preset(Control.PRESET_TOP_LEFT, true)
	_set_scaled_size(control, dimensions * scale)
	control.position = safe.position + at * scale


static func place_top_right(control: Control, safe: Rect2, right: float, top: float, dimensions: Vector2, layout_scale: float = -1.0) -> void:
	var scale := scale_for_safe(safe) if layout_scale < 0.0 else layout_scale
	control.set_anchors_preset(Control.PRESET_TOP_LEFT, true)
	_set_scaled_size(control, dimensions * scale)
	control.position = Vector2(safe.end.x - right * scale - control.size.x, safe.position.y + top * scale)


static func place_bottom_left(control: Control, safe: Rect2, left: float, bottom: float, dimensions: Vector2, layout_scale: float = -1.0) -> void:
	var scale := scale_for_safe(safe) if layout_scale < 0.0 else layout_scale
	control.set_anchors_preset(Control.PRESET_TOP_LEFT, true)
	_set_scaled_size(control, dimensions * scale)
	control.position = Vector2(safe.position.x + left * scale, safe.end.y - bottom * scale - control.size.y)


static func place_bottom_right(control: Control, safe: Rect2, right: float, bottom: float, dimensions: Vector2, layout_scale: float = -1.0) -> void:
	var scale := scale_for_safe(safe) if layout_scale < 0.0 else layout_scale
	control.set_anchors_preset(Control.PRESET_TOP_LEFT, true)
	_set_scaled_size(control, dimensions * scale)
	control.position = Vector2(safe.end.x - right * scale - control.size.x, safe.end.y - bottom * scale - control.size.y)


static func place_top_center(control: Control, safe: Rect2, top: float, dimensions: Vector2, layout_scale: float = -1.0) -> void:
	var scale := scale_for_safe(safe) if layout_scale < 0.0 else layout_scale
	control.set_anchors_preset(Control.PRESET_TOP_LEFT, true)
	_set_scaled_size(control, dimensions * scale)
	control.position = Vector2(safe.get_center().x - control.size.x * 0.5, safe.position.y + top * scale)


## A reference-composed control keeps all of its child offsets, touch rects and
## font metrics in 1280x720 units. Scaling the composed root once prevents its
## children from mixing a safe-area rect with physical viewport pixels.
static func place_reference_top_left(control: Control, safe: Rect2, at: Vector2, dimensions: Vector2, layout_scale: float = -1.0) -> void:
	var scale := scale_for_safe(safe) if layout_scale < 0.0 else layout_scale
	control.set_anchors_preset(Control.PRESET_TOP_LEFT, true)
	control.custom_minimum_size = dimensions
	control.size = dimensions
	control.scale = Vector2.ONE * scale
	control.position = safe.position + at * scale


static func place_reference_top_right(control: Control, safe: Rect2, right: float, top: float, dimensions: Vector2, layout_scale: float = -1.0) -> void:
	var scale := scale_for_safe(safe) if layout_scale < 0.0 else layout_scale
	control.set_anchors_preset(Control.PRESET_TOP_LEFT, true)
	control.custom_minimum_size = dimensions
	control.size = dimensions
	control.scale = Vector2.ONE * scale
	control.position = Vector2(safe.end.x - right * scale - dimensions.x * scale, safe.position.y + top * scale)


static func _set_scaled_size(control: Control, dimensions: Vector2) -> void:
	# A Button's old reference custom minimum would otherwise prevent a 4:3
	# control from shrinking even when its explicit rect has been scaled.
	control.custom_minimum_size = dimensions
	control.size = dimensions
