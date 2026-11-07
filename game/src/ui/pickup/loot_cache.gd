class_name LootCache
extends RefCounted
## Runtime ownership for fixed cache B loot. UI only asks for its ordered ground
## items and removes an item after RetrieverInventory confirms a placement.

signal changed(state: StringName)

const CACHE_B: StringName = &"cache_b"

var cache_id: StringName = CACHE_B
var _items: Array[ItemInstance] = []


func _init(registry: ItemRegistry = null) -> void:
	if registry != null:
		load_cache_b(registry)


func load_cache_b(registry: ItemRegistry) -> void:
	_items.clear()
	cache_id = CACHE_B
	_add(101, registry.get_def(&"scraped_tax_coin"), 2)
	_add(102, registry.get_def(&"waterlogged_stock_ledger"), 1)
	changed.emit(cache_state())


## Generic one-source adapter for D and GroundDrop. World flow owns whether it
## should remove or respawn the source after the panel emits `item_placed`.
func load_single_ground_item(item: ItemInstance, source_id: StringName = &"zone_d") -> void:
	_items.clear()
	cache_id = source_id
	if item != null:
		item.item_location = &"ground"
		_items.append(item)
	changed.emit(cache_state())


func ordered_items() -> Array[ItemInstance]:
	return _items.duplicate()


func item_at(index: int) -> ItemInstance:
	return _items[index] if index >= 0 and index < _items.size() else null


func remove_after_pickup(uid: int) -> bool:
	for index in _items.size():
		if _items[index].uid == uid:
			_items.remove_at(index)
			changed.emit(cache_state())
			return true
	return false


func cache_state() -> StringName:
	if _items.is_empty():
		return &"empty"
	return &"full" if _items.size() == 2 else &"partial"


func _add(uid: int, definition: ItemDef, quantity: int) -> void:
	if definition == null:
		return
	var item := ItemInstance.new(uid, definition, quantity)
	item.item_location = &"ground"
	_items.append(item)
