class_name ItemRegistry
extends RefCounted

var _definitions: Dictionary = {}


func _init() -> void:
	_add_zone_b_loot_definitions()


func add(definition: ItemDef) -> void:
	_definitions[definition.id] = definition


func get_def(id: StringName) -> ItemDef:
	return _definitions.get(id) as ItemDef


func validate_defs() -> Array[String]:
	var errors: Array[String] = []
	for definition: ItemDef in _definitions.values():
		var error := definition.validation_error()
		if not error.is_empty():
			errors.append("%s: %s" % [definition.id, error])
	return errors


func _add_zone_b_loot_definitions() -> void:
	var coin := ItemDef.new()
	coin.id = &"scraped_tax_coin"
	coin.display_name_key = &"ITEM_SCRAPED_TAX_COIN_NAME"
	coin.lore_key = &"CARD_SCRAPED_TAX_COIN_LORE"
	coin.display_name_vi = "Đồng Thuế Cạo Mặt"
	coin.size = Vector2i.ONE
	coin.sealable = true
	coin.stackable = true
	coin.stack_max = 3
	coin.item_category = ItemDef.Category.VALUABLE
	coin.claim_id = &"house_hac_thue"
	coin.appraisal_class = 2
	add(coin)

	var ledger := ItemDef.new()
	ledger.id = &"waterlogged_stock_ledger"
	ledger.display_name_key = &"ITEM_WATERLOGGED_STOCK_LEDGER_NAME"
	ledger.lore_key = &"CARD_WATERLOGGED_STOCK_LEDGER_LORE"
	ledger.display_name_vi = "Sổ Kho Ngấm Nước"
	ledger.size = Vector2i(1, 2)
	ledger.rotatable = true
	ledger.sealable = true
	ledger.item_category = ItemDef.Category.VALUABLE
	ledger.claim_id = &"house_hac_thue"
	ledger.appraisal_class = 3
	add(ledger)
