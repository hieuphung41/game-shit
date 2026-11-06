class_name RetrieverInventory
extends RefCounted

const BACKPACK: StringName = &"backpack"
const NOTARY_BOX: StringName = &"notary_box"
const SLING_POUCH: StringName = &"sling_pouch"

signal item_placed(uid: int, location: StringName)
signal item_removed(uid: int, location: StringName)
signal evidence_carried_changed(def_id: StringName, carried: bool)

var registry: ItemRegistry
var backpack := InventoryGrid.new(BACKPACK, Vector2i(3, 4))
var notary_box := InventoryGrid.new(NOTARY_BOX, Vector2i(2, 2))
var sling_pouch := InventoryGrid.new(SLING_POUCH, Vector2i(1, 1))


func _init(p_registry: ItemRegistry = null) -> void:
	registry = p_registry if p_registry != null else ItemRegistry.new()


func preview_pickup(ground_item: ItemInstance, target: StringName, anchor: Vector2i, rotated: bool) -> InventoryResult:
	if ground_item == null or ground_item.item_location != &"ground":
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND)
	return _preview_ground_placement(ground_item, target, anchor, rotated)


func commit_pickup(ground_item: ItemInstance, target: StringName, anchor: Vector2i, rotated: bool) -> InventoryResult:
	var result := preview_pickup(ground_item, target, anchor, rotated)
	if not result.ok:
		return result
	var target_grid := _grid_for(target)
	_place(ground_item, target_grid, anchor, rotated)
	item_placed.emit(ground_item.uid, target)
	_emit_evidence_if_ground_entry(ground_item)
	return result


func preview_move(uid: int, target: StringName, anchor: Vector2i, rotated: bool) -> InventoryResult:
	var found := _find(uid)
	if found.is_empty():
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND, uid)
	var source: InventoryGrid = found.grid
	if target == SLING_POUCH:
		return InventoryResult.failure(InventoryReason.Value.WRONG_TARGET, uid)
	if source.grid_kind != target:
		return InventoryResult.failure(InventoryReason.Value.WRONG_TARGET, uid)
	return _preview_placement(found.item, source, anchor, rotated, [uid])


func commit_move(uid: int, target: StringName, anchor: Vector2i, rotated: bool) -> InventoryResult:
	var result := preview_move(uid, target, anchor, rotated)
	if result.ok:
		var found := _find(uid)
		_place(found.item, found.grid, anchor, rotated)
	return result


func preview_rotate(uid: int) -> InventoryResult:
	var found := _find(uid)
	if found.is_empty():
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND, uid)
	if found.grid.grid_kind == SLING_POUCH:
		return InventoryResult.failure(InventoryReason.Value.WRONG_SOURCE, uid)
	var item: ItemInstance = found.item
	if item.definition.is_square():
		return InventoryResult.success()
	if not item.definition.rotatable:
		return InventoryResult.failure(InventoryReason.Value.NOT_ROTATABLE, uid)
	return _preview_placement(item, found.grid, item.anchor, not item.rotated, [uid])


func commit_rotate(uid: int) -> InventoryResult:
	var result := preview_rotate(uid)
	if result.ok:
		var found := _find(uid)
		var item: ItemInstance = found.item
		if not item.definition.is_square():
			_place(item, found.grid, item.anchor, not item.rotated)
	return result


func preview_stack(source: Variant, target_uid: int) -> InventoryResult:
	var target_found := _find(target_uid)
	if target_found.is_empty():
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND, target_uid)
	if target_found.grid.grid_kind != BACKPACK:
		return InventoryResult.failure(InventoryReason.Value.WRONG_TARGET, target_uid)
	var source_item: ItemInstance = _stack_source(source)
	if source_item == null:
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND)
	if source_item.uid == target_uid:
		return InventoryResult.failure(InventoryReason.Value.STACK_INCOMPATIBLE, target_uid)
	var target_item: ItemInstance = target_found.item
	if not source_item.definition.stackable or not target_item.definition.stackable or source_item.def_id != target_item.def_id or source_item.definition.claim_id != target_item.definition.claim_id:
		return InventoryResult.failure(InventoryReason.Value.STACK_INCOMPATIBLE, target_uid)
	if source_item.quantity + target_item.quantity > target_item.definition.stack_max:
		return InventoryResult.failure(InventoryReason.Value.STACK_FULL, target_uid)
	return InventoryResult.success()


func commit_stack(source: Variant, target_uid: int) -> InventoryResult:
	var result := preview_stack(source, target_uid)
	if not result.ok:
		return result
	var source_item: ItemInstance = _stack_source(source)
	var target_item: ItemInstance = _find(target_uid).item
	target_item.quantity += source_item.quantity
	if source is int:
		backpack.remove(source_item.uid)
	else:
		result.moved.append({
			"uid": source_item.uid,
			"from_location": &"ground",
			"to_location": BACKPACK,
			"target_uid": target_uid,
			"source_consumed": true,
			"item": source_item,
		})
	return result


func preview_swap(uid_a: int, uid_b: int) -> InventoryResult:
	var found_a := _find(uid_a)
	var found_b := _find(uid_b)
	if found_a.is_empty() or found_b.is_empty():
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND, uid_a if found_a.is_empty() else uid_b)
	if found_a.grid.grid_kind != BACKPACK or found_b.grid.grid_kind != BACKPACK:
		return InventoryResult.failure(InventoryReason.Value.SWAP_NOT_ALLOWED)
	var item_a: ItemInstance = found_a.item
	var item_b: ItemInstance = found_b.item
	var ignore: Array[int] = [uid_a, uid_b]
	var a_fit := _preview_placement(item_a, backpack, item_b.anchor, item_a.rotated, ignore)
	if not a_fit.ok:
		return a_fit
	var b_fit := _preview_placement(item_b, backpack, item_a.anchor, item_b.rotated, ignore)
	if not b_fit.ok:
		return b_fit
	var planned_a := _planned_item(item_a, item_b.anchor, item_a.rotated)
	var planned_b := _planned_item(item_b, item_a.anchor, item_b.rotated)
	for cell in planned_a.cells():
		if cell in planned_b.cells():
			var collision := InventoryResult.failure(InventoryReason.Value.CELLS_OCCUPIED)
			collision.blocking_cells.append(cell)
			return collision
	var result := InventoryResult.success()
	result.moved = [_movement(item_a, BACKPACK, item_b.anchor, item_a.rotated), _movement(item_b, BACKPACK, item_a.anchor, item_b.rotated)]
	return result


func commit_swap(uid_a: int, uid_b: int) -> InventoryResult:
	var result := preview_swap(uid_a, uid_b)
	if result.ok:
		var item_a: ItemInstance = _find(uid_a).item
		var item_b: ItemInstance = _find(uid_b).item
		var anchor_a := item_a.anchor
		_place(item_a, backpack, item_b.anchor, item_a.rotated)
		_place(item_b, backpack, anchor_a, item_b.rotated)
	return result


func preview_seal(uid: int, anchor: Vector2i, rotated: bool) -> InventoryResult:
	var found := _find(uid)
	if found.is_empty():
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND, uid)
	if found.grid.grid_kind != BACKPACK:
		return InventoryResult.failure(InventoryReason.Value.WRONG_SOURCE, uid)
	return _preview_seal(found.item, anchor, rotated, [uid])


func commit_seal(uid: int, anchor: Vector2i, rotated: bool) -> InventoryResult:
	var result := preview_seal(uid, anchor, rotated)
	if result.ok:
		var item: ItemInstance = _find(uid).item
		backpack.remove(uid)
		_place(item, notary_box, anchor, rotated)
	return result


func preview_withdraw(uid: int, anchor: Vector2i, rotated: bool) -> InventoryResult:
	var found := _find(uid)
	if found.is_empty():
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND, uid)
	if found.grid.grid_kind != NOTARY_BOX:
		return InventoryResult.failure(InventoryReason.Value.WRONG_SOURCE, uid)
	return _preview_placement(found.item, backpack, anchor, rotated)


func commit_withdraw(uid: int, anchor: Vector2i, rotated: bool) -> InventoryResult:
	var result := preview_withdraw(uid, anchor, rotated)
	if result.ok:
		var item: ItemInstance = _find(uid).item
		notary_box.remove(uid)
		_place(item, backpack, anchor, rotated)
	return result


func preview_drop(uid: int) -> InventoryResult:
	var found := _find(uid)
	if found.is_empty():
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND, uid)
	if found.grid.grid_kind != BACKPACK:
		return InventoryResult.failure(InventoryReason.Value.WRONG_SOURCE, uid)
	var result := InventoryResult.success()
	result.moved.append(_movement(found.item, &"ground", Vector2i.ZERO, found.item.rotated))
	return result


func commit_drop(uid: int) -> InventoryResult:
	var result := preview_drop(uid)
	if result.ok:
		var item: ItemInstance = backpack.remove(uid)
		item.item_location = &"ground"
		result.moved[0]["item"] = item
		item_removed.emit(uid, BACKPACK)
		if item.definition.item_category == ItemDef.Category.EVIDENCE:
			evidence_carried_changed.emit(item.def_id, false)
	return result


func preview_consume(uid: int) -> InventoryResult:
	var found := _find(uid)
	if found.is_empty():
		return InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND, uid)
	var item: ItemInstance = found.item
	if found.grid.grid_kind != SLING_POUCH or item.definition.item_category != ItemDef.Category.CONSUMABLE:
		return InventoryResult.failure(InventoryReason.Value.WRONG_SOURCE, uid)
	return InventoryResult.success()


func commit_consume(uid: int) -> InventoryResult:
	var result := preview_consume(uid)
	if not result.ok:
		return result
	var item := sling_pouch.items.get(uid) as ItemInstance
	item.quantity -= 1
	if item.quantity == 0:
		sling_pouch.remove(uid)
		item_removed.emit(uid, SLING_POUCH)
	return result


func preview_sort() -> InventoryResult:
	var ordered: Array[ItemInstance] = []
	for item: ItemInstance in backpack.items.values():
		ordered.append(item)
	ordered.sort_custom(func(a: ItemInstance, b: ItemInstance) -> bool:
		var a_area := a.definition.size.x * a.definition.size.y
		var b_area := b.definition.size.x * b.definition.size.y
		if a_area != b_area:
			return a_area > b_area
		if a.def_id != b.def_id:
			return str(a.def_id) < str(b.def_id)
		return a.uid < b.uid
	)
	var result := InventoryResult.success()
	var survivors: Array[ItemInstance] = []
	for item in ordered:
		var working := _planned_item(item, item.anchor, item.rotated)
		for survivor in survivors:
			if _can_stack(working, survivor) and survivor.quantity < survivor.definition.stack_max:
				var transferred := mini(working.quantity, survivor.definition.stack_max - survivor.quantity)
				survivor.quantity += transferred
				working.quantity -= transferred
				if working.quantity == 0:
					result.plan[working.uid] = {"removed": true}
					break
		if working.quantity > 0:
			survivors.append(working)
	var planned := InventoryGrid.new(BACKPACK, backpack.size)
	for item in survivors:
		var placement := _first_fit(planned, item)
		if placement.is_empty():
			return InventoryResult.failure(InventoryReason.Value.SORT_NO_FIT, item.uid)
		planned.add(_planned_item(item, placement.anchor, placement.rotated))
		result.plan[item.uid] = {"anchor": placement.anchor, "rotated": placement.rotated, "quantity": item.quantity}
		result.moved.append(_movement(item, BACKPACK, placement.anchor, placement.rotated))
	return result


func commit_sort() -> InventoryResult:
	var result := preview_sort()
	if not result.ok:
		return result
	for uid_variant: Variant in result.plan:
		var removal: Dictionary = result.plan[uid_variant]
		if removal.get("removed", false):
			backpack.remove(int(uid_variant))
	for uid_variant: Variant in result.plan:
		var uid: int = uid_variant
		var placement: Dictionary = result.plan[uid]
		if placement.get("removed", false):
			continue
		var item: ItemInstance = backpack.items[uid]
		item.anchor = placement.anchor
		item.rotated = placement.rotated
		item.quantity = placement.quantity
	return result


func suggest_slot(def_id: StringName, quantity: int) -> Variant:
	var definition := registry.get_def(def_id)
	if definition == null or quantity < 1 or quantity > definition.stack_max:
		return null
	var probe := ItemInstance.new(-1, definition, quantity)
	var placement := _first_fit(backpack, probe)
	return placement if not placement.is_empty() else null


func seal_label(uid: int) -> StringName:
	var found := _find(uid)
	if found.is_empty() or found.grid.grid_kind != NOTARY_BOX:
		return &""
	return &"sealed_not_extracted" if found.item.definition.item_category == ItemDef.Category.EVIDENCE else &"sealed"


func resolve_death() -> Dictionary:
	var outcome := {"kept": [], "lost": [], "unrecovered_evidence": []}
	for grid: InventoryGrid in [backpack, sling_pouch, notary_box]:
		for item: ItemInstance in grid.all_items():
			if item.definition.item_category == ItemDef.Category.EVIDENCE:
				outcome.unrecovered_evidence.append(item.def_id)
			elif grid.grid_kind == NOTARY_BOX:
				outcome.kept.append(item)
			else:
				outcome.lost.append(item)
	_clear_grids()
	return outcome


func resolve_extract() -> Dictionary:
	var outcome := {"to_hub": [], "to_archive": []}
	for grid: InventoryGrid in [backpack, sling_pouch, notary_box]:
		for item: ItemInstance in grid.all_items():
			if item.definition.item_category == ItemDef.Category.EVIDENCE:
				outcome.to_archive.append(item.def_id)
			else:
				outcome.to_hub.append(item)
	return outcome


func validate() -> Array[InventoryResult]:
	var errors: Array[InventoryResult] = []
	var seen_uids: Dictionary = {}
	for grid: InventoryGrid in [backpack, notary_box, sling_pouch]:
		var occupied: Dictionary = {}
		for item: ItemInstance in grid.all_items():
			if seen_uids.has(item.uid):
				errors.append(InventoryResult.failure(InventoryReason.Value.CELLS_OCCUPIED, item.uid))
			seen_uids[item.uid] = true
			if item.definition == null:
				errors.append(InventoryResult.failure(InventoryReason.Value.ITEM_NOT_FOUND, item.uid))
				continue
			if grid.grid_kind == NOTARY_BOX and not item.definition.sealable:
				errors.append(InventoryResult.failure(InventoryReason.Value.NOT_SEALABLE, item.uid))
			for cell in item.cells():
				if cell.x < 0 or cell.y < 0 or cell.x >= grid.size.x or cell.y >= grid.size.y:
					errors.append(InventoryResult.failure(InventoryReason.Value.OUT_OF_BOUNDS, item.uid))
				elif occupied.has(cell):
					errors.append(InventoryResult.failure(InventoryReason.Value.CELLS_OCCUPIED, item.uid))
				else:
					occupied[cell] = item.uid
	return errors


func snapshot() -> Dictionary:
	return {
		"backpack": _grid_snapshot(backpack),
		"notary_box": _grid_snapshot(notary_box),
		"sling_pouch": _grid_snapshot(sling_pouch),
	}


func load_snapshot(data: Dictionary) -> void:
	_clear_grids()
	for grid: InventoryGrid in [backpack, notary_box, sling_pouch]:
		for entry: Dictionary in data.get(str(grid.grid_kind), []):
			var definition := registry.get_def(StringName(entry.get("def_id", "")))
			var item := ItemInstance.new(int(entry.get("uid", 0)), definition, int(entry.get("quantity", 1)))
			item.def_id = StringName(entry.get("def_id", ""))
			item.item_location = grid.grid_kind
			item.anchor = entry.get("anchor", Vector2i.ZERO)
			item.rotated = bool(entry.get("rotated", false)) and definition != null and not definition.is_square()
			grid.add_loaded(item)


func _preview_ground_placement(item: ItemInstance, target: StringName, anchor: Vector2i, rotated: bool) -> InventoryResult:
	if target == SLING_POUCH or _grid_for(target) == null:
		return InventoryResult.failure(InventoryReason.Value.WRONG_TARGET, item.uid)
	if target == NOTARY_BOX:
		return _preview_seal(item, anchor, rotated, [])
	return _preview_placement(item, backpack, anchor, rotated)


func _preview_seal(item: ItemInstance, anchor: Vector2i, rotated: bool, ignored: Array[int]) -> InventoryResult:
	if not item.definition.sealable:
		return InventoryResult.failure(InventoryReason.Value.NOT_SEALABLE, item.uid)
	return _preview_placement(item, notary_box, anchor, rotated, ignored)


func _preview_placement(item: ItemInstance, target: InventoryGrid, anchor: Vector2i, rotated: bool, ignored: Array[int] = []) -> InventoryResult:
	if rotated and not item.definition.is_square() and not item.definition.rotatable:
		return InventoryResult.failure(InventoryReason.Value.NOT_ROTATABLE, item.uid)
	var effective_rotated := rotated and not item.definition.is_square()
	var footprint := item.definition.size
	if effective_rotated:
		footprint = Vector2i(footprint.y, footprint.x)
	return target.check_fit(footprint, anchor, ignored)


func _first_fit(grid: InventoryGrid, item: ItemInstance) -> Dictionary:
	for y in grid.size.y:
		for x in grid.size.x:
			var anchor := Vector2i(x, y)
			var regular := _preview_placement(item, grid, anchor, false)
			if regular.ok:
				return {"anchor": anchor, "rotated": false}
			if item.definition.rotatable and not item.definition.is_square():
				var rotated := _preview_placement(item, grid, anchor, true)
				if rotated.ok:
					return {"anchor": anchor, "rotated": true}
	return {}


func _place(item: ItemInstance, target: InventoryGrid, anchor: Vector2i, rotated: bool) -> void:
	item.anchor = anchor
	item.rotated = rotated and not item.definition.is_square()
	item.item_location = target.grid_kind
	target.add(item)


func _find(uid: int) -> Dictionary:
	for grid: InventoryGrid in [backpack, notary_box, sling_pouch]:
		var item := grid.items.get(uid) as ItemInstance
		if item != null:
			return {"grid": grid, "item": item}
	return {}


func _grid_for(kind: StringName) -> InventoryGrid:
	match kind:
		BACKPACK:
			return backpack
		NOTARY_BOX:
			return notary_box
		SLING_POUCH:
			return sling_pouch
	return null


func _stack_source(source: Variant) -> ItemInstance:
	if source is int:
		var found := _find(source)
		return found.item as ItemInstance if not found.is_empty() and found.grid.grid_kind == BACKPACK else null
	if source is ItemInstance and source.item_location == &"ground":
		return source
	return null


func _can_stack(source: ItemInstance, target: ItemInstance) -> bool:
	return source.definition.stackable and target.definition.stackable and source.def_id == target.def_id and source.definition.claim_id == target.definition.claim_id


func _movement(item: ItemInstance, target: StringName, anchor: Vector2i, rotated: bool) -> Dictionary:
	return {"uid": item.uid, "from_location": item.item_location, "from_anchor": item.anchor, "to_location": target, "to_anchor": anchor, "rotated": rotated}


func _planned_item(item: ItemInstance, anchor: Vector2i, rotated: bool) -> ItemInstance:
	var planned := ItemInstance.new(item.uid, item.definition, item.quantity)
	planned.anchor = anchor
	planned.rotated = rotated
	return planned


func _emit_evidence_if_ground_entry(item: ItemInstance) -> void:
	if item.definition.item_category == ItemDef.Category.EVIDENCE:
		evidence_carried_changed.emit(item.def_id, true)


func _clear_grids() -> void:
	backpack.clear()
	notary_box.clear()
	sling_pouch.clear()


func _grid_snapshot(grid: InventoryGrid) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var all_items := grid.all_items()
	all_items.sort_custom(func(a: ItemInstance, b: ItemInstance) -> bool:
		if a.uid != b.uid:
			return a.uid < b.uid
		if a.anchor != b.anchor:
			return a.anchor < b.anchor
		return str(a.def_id) < str(b.def_id)
	)
	for item: ItemInstance in all_items:
		result.append({"uid": item.uid, "def_id": item.def_id, "quantity": item.quantity, "anchor": item.anchor, "rotated": item.rotated})
	return result
