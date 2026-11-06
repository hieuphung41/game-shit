extends Node
## Owns the in-memory Contract 1 run between scene changes. S02 deliberately
## does not persist this data; returning to Boot clears it.

const MANIFEST_UID := 100

var inventory: RetrieverInventory
var extract_flow: ExtractPierAFlow
var ground_manifest: ItemInstance


func begin_briefing() -> RetrieverInventory:
	clear()
	inventory = StarterInventoryFactory.create()
	_ensure_manifest_definition()
	return inventory


func begin_run(p_inventory: RetrieverInventory) -> ExtractPierAFlow:
	inventory = p_inventory
	_ensure_manifest_definition()
	extract_flow = ExtractPierAFlow.new()
	extract_flow.setup(inventory)
	ground_manifest = ItemInstance.new(MANIFEST_UID, inventory.registry.get_def(ExtractPierAFlow.MANIFEST_DEF_ID))
	return extract_flow


func clear() -> void:
	inventory = null
	extract_flow = null
	ground_manifest = null


func _ensure_manifest_definition() -> void:
	if inventory == null or inventory.registry.get_def(ExtractPierAFlow.MANIFEST_DEF_ID) != null:
		return
	var manifest := ItemDef.new()
	manifest.id = ExtractPierAFlow.MANIFEST_DEF_ID
	manifest.display_name_key = &"CARD_MANIFEST_R17_NAME"
	manifest.size = Vector2i.ONE
	manifest.sealable = true
	manifest.item_category = ItemDef.Category.EVIDENCE
	manifest.claim_id = &"house_hac_thue"
	inventory.registry.add(manifest)
