class_name ItemRegistry
extends RefCounted

var _definitions: Dictionary = {}


func _init() -> void:
	_add_zone_b_loot_definitions()
	_add_zone_d_loot_definitions()


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


func _add_zone_d_loot_definitions() -> void:
	var cargo := ItemDef.new()
	cargo.id = &"cargo_d_2x2"
	cargo.display_name_key = &"ITEM_CARGO_D_2X2_NAME"
	cargo.lore_key = &"CARD_CARGO_D_2X2_LORE"
	cargo.display_name_vi = "Vải Cứu Trợ Đổi Nhãn"
	cargo.size = Vector2i(2, 2)
	cargo.sealable = false
	cargo.item_category = ItemDef.Category.CARGO
	cargo.claim_id = &"house_hac_thue"
	cargo.appraisal_class = 1
	cargo.relative_value_total = 8
	cargo.set_meta(&"relative_value_total", cargo.relative_value_total)
	add(cargo)

	var stamp := ItemDef.new()
	stamp.id = &"tax_stamp_d"
	stamp.display_name_key = &"ITEM_TAX_STAMP_D_NAME"
	stamp.lore_key = &"CARD_TAX_STAMP_D_LORE"
	stamp.display_name_vi = "Dấu Thuế"
	stamp.size = Vector2i(1, 2)
	stamp.rotatable = true
	stamp.sealable = true
	stamp.item_category = ItemDef.Category.VALUABLE
	stamp.claim_id = &"house_hac_thue"
	stamp.appraisal_class = 1
	stamp.relative_value_total = 6
	stamp.set_meta(&"relative_value_total", stamp.relative_value_total)
	add(stamp)
