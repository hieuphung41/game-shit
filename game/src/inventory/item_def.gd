class_name ItemDef
extends Resource

enum Category {
	EVIDENCE,
	CONSUMABLE,
	TOOL,
	VALUABLE,
	SALVAGE,
	CARGO,
	GEAR,
	WEAPON,
	AMMO,
	KEY,
	CONTAINER,
}

@export var id: StringName = &""
@export var display_name_key: StringName = &""
@export var lore_key: StringName = &""
@export var display_name_vi := ""
@export var size := Vector2i.ONE
@export var rotatable := false
@export var sealable := false
@export var stackable := false
@export var stack_max := 1
@export var item_category: Category = Category.SALVAGE
@export var claim_id: StringName = &""
@export_range(1, 6) var appraisal_class := 1
@export var relative_value_total := 0


func is_square() -> bool:
	return size.x == size.y


func localized_display_name() -> String:
	return tr(display_name_key) if not display_name_key.is_empty() else display_name_vi


func relative_value_per_cell() -> float:
	var cell_count := size.x * size.y
	return float(relative_value_total) / float(cell_count) if cell_count > 0 else 0.0


func validation_error() -> String:
	if id.is_empty() or (display_name_key.is_empty() and display_name_vi.is_empty()):
		return "item definition needs id and Vietnamese display name"
	if size.x < 1 or size.x > 3 or size.y < 1 or size.y > 3:
		return "item definition size must be 1..3"
	if stack_max < 1 or (not stackable and stack_max != 1):
		return "item definition stack values are invalid"
	if item_category in [Category.GEAR, Category.WEAPON, Category.CARGO, Category.CONTAINER] and sealable:
		return "this item category cannot be sealed"
	if item_category == Category.EVIDENCE and stackable:
		return "evidence cannot stack"
	return ""
