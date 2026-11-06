class_name ExtractSummary
extends RefCounted

var kept: Array[Dictionary] = []
var lost: Array[Dictionary] = []
var evidence: Array[StringName] = []
var next: Array[Dictionary] = [{"contract_id": &"contract_2", "playable": false}]
var backpack_cells_used: int = 0
var backpack_cells_total: int = 0
var contract_state: int = 0


func to_dict() -> Dictionary:
	return {
		"kept": kept.duplicate(true),
		"lost": lost.duplicate(true),
		"evidence": evidence.duplicate(),
		"next": next.duplicate(true),
		"backpack_cells_used": backpack_cells_used,
		"backpack_cells_total": backpack_cells_total,
		"contract_state": contract_state,
	}
