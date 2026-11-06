class_name InventoryResult
extends RefCounted

var ok := false
var reason: InventoryReason.Value = InventoryReason.Value.OK
var reason_label_vi := ""
var blocking_cells: Array[Vector2i] = []
var moved: Array[Dictionary] = []
var uid := 0
var plan: Dictionary = {}


static func success() -> InventoryResult:
	var result := InventoryResult.new()
	result.ok = true
	result.reason = InventoryReason.Value.OK
	result.reason_label_vi = InventoryReason.label_vi(result.reason)
	return result


static func failure(p_reason: InventoryReason.Value, p_uid: int = 0) -> InventoryResult:
	var result := InventoryResult.new()
	result.reason = p_reason
	result.reason_label_vi = InventoryReason.label_vi(p_reason)
	result.uid = p_uid
	return result
