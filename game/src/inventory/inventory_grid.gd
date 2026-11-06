class_name InventoryGrid
extends RefCounted

var grid_kind: StringName
var size: Vector2i
var items: Dictionary = {}
var duplicate_items: Array[ItemInstance] = []


func _init(p_grid_kind: StringName = &"backpack", p_size: Vector2i = Vector2i.ZERO) -> void:
	grid_kind = p_grid_kind
	size = p_size


func item_at(cell: Vector2i) -> ItemInstance:
	for item: ItemInstance in all_items():
		if cell in item.cells():
			return item
	return null


func free_cell_count() -> int:
	var free := 0
	for y in size.y:
		for x in size.x:
			if item_at(Vector2i(x, y)) == null:
				free += 1
	return free


func check_fit(item_size: Vector2i, anchor: Vector2i, ignore_uids: Array[int] = []) -> InventoryResult:
	for y in item_size.y:
		for x in item_size.x:
			var cell := anchor + Vector2i(x, y)
			if cell.x < 0 or cell.y < 0 or cell.x >= size.x or cell.y >= size.y:
				return InventoryResult.failure(InventoryReason.Value.OUT_OF_BOUNDS)
	var result := InventoryResult.success()
	for y in item_size.y:
		for x in item_size.x:
			var cell := anchor + Vector2i(x, y)
			var occupied_by := item_at(cell)
			if occupied_by != null and not occupied_by.uid in ignore_uids:
				result.ok = false
				result.reason = InventoryReason.Value.CELLS_OCCUPIED
				result.reason_label_vi = InventoryReason.label_vi(result.reason)
				result.blocking_cells.append(cell)
	return result


func add(item: ItemInstance) -> void:
	items[item.uid] = item


func add_loaded(item: ItemInstance) -> void:
	if items.has(item.uid):
		duplicate_items.append(item)
		return
	items[item.uid] = item


func remove(uid: int) -> ItemInstance:
	var item := items.get(uid) as ItemInstance
	items.erase(uid)
	return item


func all_items() -> Array[ItemInstance]:
	var result: Array[ItemInstance] = []
	for item: ItemInstance in items.values():
		result.append(item)
	result.append_array(duplicate_items)
	return result


func clear() -> void:
	items.clear()
	duplicate_items.clear()
