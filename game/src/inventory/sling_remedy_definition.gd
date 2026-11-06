class_name SlingRemedyDefinition
extends ItemDef
## S02 starter consumable for the sling pouch. Its player-facing name stays in
## the translation table so UI code never owns the text.


func _init() -> void:
	id = &"sling_remedy"
	display_name_key = &"ITEM_SLING_REMEDY_NAME"
	size = Vector2i.ONE
	rotatable = false
	sealable = true
	item_category = Category.CONSUMABLE
