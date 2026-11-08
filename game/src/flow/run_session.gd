extends Node
## Owns the in-memory Contract 1 run between scene changes. S02 deliberately
## does not persist this data; returning to Boot clears it.

const MANIFEST_UID := 100

var inventory: RetrieverInventory
var extract_flow: ExtractPierAFlow
var ground_manifest: ItemInstance
var recovery_active := false
var recovery_source: StringName = &""
var recovery_retained: Array[Dictionary] = []
var recovery_basic_kit_applied := false
var run_kind: StringName = &"normal"
var debug_fixture_id: StringName = &""


func begin_briefing() -> RetrieverInventory:
	clear()
	inventory = StarterInventoryFactory.create()
	_ensure_manifest_definition()
	return inventory


func begin_run(p_inventory: RetrieverInventory) -> ExtractPierAFlow:
	_clear_recovery_context()
	inventory = p_inventory
	_ensure_manifest_definition()
	extract_flow = ExtractPierAFlow.new()
	extract_flow.setup(inventory)
	ground_manifest = ItemInstance.new(MANIFEST_UID, inventory.registry.get_def(ExtractPierAFlow.MANIFEST_DEF_ID))
	return extract_flow


## Converts an actual after-Manifest death into the in-memory S12/S1 recovery context.
func prepare_recovery_briefing(summary: DeathSummary) -> bool:
	if summary == null or summary.death_variant != &"after_manifest" or not summary.unrecovered_evidence.has(ExtractPierAFlow.MANIFEST_DEF_ID):
		return false
	recovery_active = true
	recovery_source = &"dispatch_a"
	run_kind = &"recovery"
	recovery_basic_kit_applied = false
	recovery_retained = _retained_snapshot(summary.kept)
	inventory = _create_recovery_inventory(recovery_retained)
	extract_flow = null
	ground_manifest = null
	return inventory.validate().is_empty()


## The only public recovery S2 initializer. It never returns a partially initialized flow.
func begin_recovery_run(p_inventory: RetrieverInventory, p_retained: Array[Dictionary], p_debug_fixture_id: StringName = &"") -> ExtractPierAFlow:
	if not recovery_active or recovery_source != &"dispatch_a" or run_kind != &"recovery":
		return null
	if p_inventory == null or not p_inventory.validate().is_empty() or _contains_manifest(p_inventory):
		return null
	for entry: Dictionary in p_retained:
		if StringName(entry.get("def_id", &"")) == ExtractPierAFlow.MANIFEST_DEF_ID:
			return null
	_ensure_manifest_definition_for(p_inventory)
	var candidate := ExtractPierAFlow.new()
	candidate.setup(p_inventory, true)
	if not candidate.initialize_unrecovered_at_dispatch():
		return null
	inventory = p_inventory
	extract_flow = candidate
	ground_manifest = ItemInstance.new(MANIFEST_UID, inventory.registry.get_def(ExtractPierAFlow.MANIFEST_DEF_ID))
	recovery_basic_kit_applied = true
	debug_fixture_id = p_debug_fixture_id
	return extract_flow


## Ends only the recovery context after S10 has captured its summary.
## The completed inventory and flow remain available to render that summary.
func complete_recovery_run() -> void:
	if not recovery_active:
		return
	extract_flow = null
	ground_manifest = null
	_clear_recovery_context()


func is_recovery_briefing() -> bool:
	return recovery_active and run_kind == &"recovery" and inventory != null and extract_flow == null


func clear() -> void:
	inventory = null
	extract_flow = null
	ground_manifest = null
	_clear_recovery_context()


func _ensure_manifest_definition() -> void:
	_ensure_manifest_definition_for(inventory)


func _ensure_manifest_definition_for(target_inventory: RetrieverInventory) -> void:
	if target_inventory == null or target_inventory.registry.get_def(ExtractPierAFlow.MANIFEST_DEF_ID) != null:
		return
	var manifest := ItemDef.new()
	manifest.id = ExtractPierAFlow.MANIFEST_DEF_ID
	manifest.display_name_key = &"CARD_MANIFEST_R17_NAME"
	manifest.size = Vector2i.ONE
	manifest.sealable = true
	manifest.item_category = ItemDef.Category.EVIDENCE
	manifest.claim_id = &"house_hac_thue"
	target_inventory.registry.add(manifest)


func _create_recovery_inventory(retained: Array[Dictionary]) -> RetrieverInventory:
	var result := StarterInventoryFactory.create()
	result.notary_box.remove(1)
	for entry: Dictionary in retained:
		var definition := result.registry.get_def(StringName(entry.get("def_id", &"")))
		if definition == null:
			continue
		var item := ItemInstance.new(int(entry.get("uid", 0)), definition, int(entry.get("quantity", 1)))
		item.anchor = entry.get("anchor", Vector2i.ZERO)
		item.rotated = bool(entry.get("rotated", false))
		item.item_location = RetrieverInventory.NOTARY_BOX
		result.notary_box.add_loaded(item)
	return result


func _retained_snapshot(entries: Array[Dictionary]) -> Array[Dictionary]:
	var retained: Array[Dictionary] = []
	for entry: Dictionary in entries:
		if StringName(entry.get("def_id", &"")) == ExtractPierAFlow.MANIFEST_DEF_ID:
			continue
		retained.append(entry.duplicate(true))
	return retained


func _contains_manifest(target_inventory: RetrieverInventory) -> bool:
	for grid: InventoryGrid in [target_inventory.backpack, target_inventory.notary_box, target_inventory.sling_pouch]:
		for item: ItemInstance in grid.all_items():
			if item.def_id == ExtractPierAFlow.MANIFEST_DEF_ID:
				return true
	return false


func _clear_recovery_context() -> void:
	recovery_active = false
	recovery_source = &""
	recovery_retained.clear()
	recovery_basic_kit_applied = false
	run_kind = &"normal"
	debug_fixture_id = &""
