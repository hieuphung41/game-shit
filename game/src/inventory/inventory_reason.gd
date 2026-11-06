class_name InventoryReason
extends RefCounted

enum Value {
	OK,
	ITEM_NOT_FOUND,
	WRONG_SOURCE,
	WRONG_TARGET,
	SWAP_NOT_ALLOWED,
	NOT_SEALABLE,
	NOT_ROTATABLE,
	OUT_OF_BOUNDS,
	CELLS_OCCUPIED,
	STACK_INCOMPATIBLE,
	STACK_FULL,
	SORT_NO_FIT,
}


static func label_vi(reason: Value) -> String:
	match reason:
		Value.OK:
			return "vừa"
		Value.ITEM_NOT_FOUND:
			return "không tìm thấy món"
		Value.WRONG_SOURCE:
			return "rút ra trước"
		Value.WRONG_TARGET:
			return "sai loại"
		Value.SWAP_NOT_ALLOWED:
			return "đổi từng món"
		Value.NOT_SEALABLE:
			return "không niêm phong được"
		Value.NOT_ROTATABLE:
			return "không xoay"
		Value.OUT_OF_BOUNDS:
			return "không vừa"
		Value.CELLS_OCCUPIED:
			return "thiếu ô"
		Value.STACK_INCOMPATIBLE:
			return "không xếp chồng"
		Value.STACK_FULL:
			return "chồng đã đầy"
		Value.SORT_NO_FIT:
			return "không sắp được"
	return ""
