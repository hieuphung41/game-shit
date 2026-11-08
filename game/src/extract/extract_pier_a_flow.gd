class_name ExtractPierAFlow
extends RefCounted

const EXTRACT_HOLD_SECONDS: float = 20.0
const EXTRACT_CALL_ACK_SECONDS: float = 1.5
const MAX_TICK_DELTA: float = 0.25
const MANIFEST_DEF_ID: StringName = &"manifest_r17"

enum ExtractState {
	E0_UNAVAILABLE,
	E1_CALLABLE,
	S7_CALL_ACCEPTED,
	S8_HOLD,
	S9_BOAT_READY,
	S10_SUCCESS,
	ENDED_DEATH,
}

enum ContractState {
	NOT_TAKEN,
	CARRYING,
	DROPPED,
	EXTRACTED,
	UNRECOVERED,
}

enum DeskState {
	HAS_MANIFEST,
	EMPTY,
}

signal extract_state_changed(from: int, to: int)
signal contract_state_changed(from: int, to: int)
signal desk_state_changed(to: int)
signal call_confirm_opened()
signal call_confirm_closed(confirmed: bool)
signal hold_started(duration: float)
signal hold_paused_changed(paused: bool, reason: StringName)
signal boat_ready()
signal extract_succeeded(summary: ExtractSummary)
signal death_resolved(summary: DeathSummary)

var extract_state: int = ExtractState.E0_UNAVAILABLE
var contract_state: int = ContractState.NOT_TAKEN
var desk_state: int = DeskState.HAS_MANIFEST
var manifest_carried: bool = false
var in_beacon_zone: bool = false
var in_board_zone: bool = false
var call_confirm_open: bool = false
var hold_remaining: float = 0.0
var hold_paused: bool = false
var hold_pause_reason: StringName = &""

var _inventory: RetrieverInventory
var _carried_ever: Dictionary = {}
var _call_ack_remaining: float = 0.0
var _death_summary_resolved := false
var _recovery_run := false


func setup(inventory: RetrieverInventory, recovery_run: bool = false) -> void:
	if _inventory != null:
		if _inventory.evidence_carried_changed.is_connected(on_evidence_carried_changed):
			_inventory.evidence_carried_changed.disconnect(on_evidence_carried_changed)
		if _inventory.item_placed.is_connected(_on_item_placed):
			_inventory.item_placed.disconnect(_on_item_placed)
		if _inventory.item_consumed.is_connected(_on_item_consumed):
			_inventory.item_consumed.disconnect(_on_item_consumed)
	_inventory = inventory
	_carried_ever.clear()
	_record_existing_carried_items()
	_inventory.evidence_carried_changed.connect(on_evidence_carried_changed)
	_inventory.item_placed.connect(_on_item_placed)
	_inventory.item_consumed.connect(_on_item_consumed)
	extract_state = ExtractState.E0_UNAVAILABLE
	contract_state = ContractState.NOT_TAKEN
	desk_state = DeskState.HAS_MANIFEST
	manifest_carried = false
	in_beacon_zone = false
	in_board_zone = false
	call_confirm_open = false
	hold_remaining = 0.0
	hold_paused = false
	hold_pause_reason = &""
	_call_ack_remaining = 0.0
	_death_summary_resolved = false
	_recovery_run = recovery_run


## Initializes the recovery tuple before the flow is exposed to a scene or HUD.
func initialize_unrecovered_at_dispatch() -> bool:
	if _inventory == null or _inventory_contains_manifest():
		return false
	extract_state = ExtractState.E0_UNAVAILABLE
	contract_state = ContractState.UNRECOVERED
	desk_state = DeskState.HAS_MANIFEST
	manifest_carried = false
	in_beacon_zone = false
	in_board_zone = false
	call_confirm_open = false
	hold_remaining = 0.0
	hold_paused = false
	hold_pause_reason = &""
	_call_ack_remaining = 0.0
	_death_summary_resolved = false
	return true


func can_recover_manifest() -> bool:
	return contract_state == ContractState.UNRECOVERED \
		and desk_state == DeskState.HAS_MANIFEST \
		and not manifest_carried \
		and extract_state == ExtractState.E0_UNAVAILABLE


func is_recovery_run() -> bool:
	return _recovery_run


func on_evidence_carried_changed(def_id: StringName, carried: bool) -> void:
	if _is_terminal() or def_id != MANIFEST_DEF_ID:
		return
	if carried == manifest_carried:
		return
	manifest_carried = carried
	if carried:
		_set_contract_state(ContractState.CARRYING)
		if desk_state == DeskState.HAS_MANIFEST:
			_set_desk_state(DeskState.EMPTY)
		if extract_state == ExtractState.E0_UNAVAILABLE:
			_set_extract_state(ExtractState.E1_CALLABLE)
	else:
		_set_contract_state(ContractState.DROPPED)
		if call_confirm_open:
			_close_call_confirm(false)
		if extract_state == ExtractState.E1_CALLABLE:
			_set_extract_state(ExtractState.E0_UNAVAILABLE)
	if extract_state == ExtractState.S8_HOLD:
		_refresh_hold_pause()


func set_in_beacon_zone(inside: bool) -> void:
	if _is_terminal():
		return
	in_beacon_zone = inside
	if call_confirm_open and not in_beacon_zone:
		_close_call_confirm(false)
	if extract_state == ExtractState.S8_HOLD:
		_refresh_hold_pause()


func set_in_board_zone(inside: bool) -> void:
	if _is_terminal():
		return
	in_board_zone = inside


func can_call() -> bool:
	return extract_state == ExtractState.E1_CALLABLE and manifest_carried and in_beacon_zone and not call_confirm_open


func request_call() -> bool:
	if not can_call():
		return false
	call_confirm_open = true
	call_confirm_opened.emit()
	return true


func confirm_call() -> bool:
	if not call_confirm_open or not can_call_guard_without_prompt():
		if call_confirm_open:
			_close_call_confirm(false)
		return false
	_close_call_confirm(true)
	_call_ack_remaining = EXTRACT_CALL_ACK_SECONDS
	_set_extract_state(ExtractState.S7_CALL_ACCEPTED)
	return true


func cancel_call() -> void:
	if call_confirm_open:
		_close_call_confirm(false)


func tick(delta: float) -> void:
	if _is_terminal():
		return
	var bounded_delta := clampf(delta, 0.0, MAX_TICK_DELTA)
	if extract_state == ExtractState.S7_CALL_ACCEPTED:
		_call_ack_remaining = maxf(_call_ack_remaining - bounded_delta, 0.0)
		if _call_ack_remaining <= 0.0:
			hold_remaining = EXTRACT_HOLD_SECONDS
			_set_extract_state(ExtractState.S8_HOLD)
			hold_started.emit(EXTRACT_HOLD_SECONDS)
			_refresh_hold_pause()
		return
	if extract_state != ExtractState.S8_HOLD:
		return
	_refresh_hold_pause()
	if hold_paused:
		return
	hold_remaining = maxf(hold_remaining - bounded_delta, 0.0)
	if hold_remaining <= 0.0:
		_set_extract_state(ExtractState.S9_BOAT_READY)
		boat_ready.emit()


func hold_seconds_display() -> int:
	return ceili(maxf(hold_remaining, 0.0))


func can_board() -> bool:
	return extract_state == ExtractState.S9_BOAT_READY and in_board_zone and manifest_carried


func board() -> ExtractSummary:
	if not can_board() or _inventory == null:
		return null
	var used_cells := _used_backpack_cells()
	var total_cells := _inventory.backpack.size.x * _inventory.backpack.size.y
	var outcome := _inventory.resolve_extract()
	var summary := ExtractSummary.new()
	summary.kept = _item_entries(outcome.get("to_hub", []))
	summary.evidence = _string_names(outcome.get("to_archive", []))
	summary.lost = _lost_entries(summary)
	summary.backpack_cells_used = used_cells
	summary.backpack_cells_total = total_cells
	summary.contract_state = ContractState.EXTRACTED
	summary.run_kind = &"recovery" if _recovery_run else &"normal"
	_set_contract_state(ContractState.EXTRACTED)
	_set_extract_state(ExtractState.S10_SUCCESS)
	extract_succeeded.emit(summary)
	return summary


func notify_death() -> void:
	if _is_terminal():
		return
	if call_confirm_open:
		_close_call_confirm(false)
	_set_extract_state(ExtractState.ENDED_DEATH)


func resolve_death_summary() -> DeathSummary:
	if extract_state != ExtractState.ENDED_DEATH or _inventory == null or _death_summary_resolved:
		return null
	_death_summary_resolved = true
	var summary := DeathSummary.new()
	summary.contract_state_at_death = contract_state
	summary.death_variant = &"before_manifest" if contract_state == ContractState.NOT_TAKEN else &"after_manifest"
	var outcome := _inventory.resolve_death()
	summary.kept = _entries_with_reason(outcome.get("kept", []), &"")
	summary.lost = _entries_with_reason(outcome.get("lost", []), &"unsealed")
	var settled_uids: Dictionary = {}
	for entry: Dictionary in summary.kept + summary.lost:
		settled_uids[int(entry["uid"])] = true
	for uid: int in _carried_ever:
		if settled_uids.has(uid):
			continue
		var def_id: StringName = _carried_ever[uid]
		if def_id != MANIFEST_DEF_ID:
			summary.lost.append({"uid": uid, "def_id": def_id, "lost_reason": &"left_behind"})
	for evidence: Variant in outcome.get("unrecovered_evidence", []):
		var evidence_id := StringName(evidence)
		if not summary.unrecovered_evidence.has(evidence_id):
			summary.unrecovered_evidence.append(evidence_id)
	if contract_state != ContractState.NOT_TAKEN and not summary.unrecovered_evidence.has(MANIFEST_DEF_ID):
		summary.unrecovered_evidence.append(MANIFEST_DEF_ID)
	if contract_state != ContractState.NOT_TAKEN:
		_set_contract_state(ContractState.UNRECOVERED)
	summary.contract_state = contract_state
	summary.kept.sort_custom(_entry_uid_less)
	summary.lost.sort_custom(_entry_uid_less)
	death_resolved.emit(summary)
	return summary


func can_call_guard_without_prompt() -> bool:
	return extract_state == ExtractState.E1_CALLABLE and manifest_carried and in_beacon_zone


func _on_item_placed(uid: int, _location: StringName) -> void:
	if _inventory == null:
		return
	var item := _find_item(uid)
	if item != null:
		_carried_ever[uid] = item.def_id


func _on_item_consumed(uid: int, _def_id: StringName) -> void:
	_carried_ever.erase(uid)


func _record_existing_carried_items() -> void:
	if _inventory == null:
		return
	for grid: InventoryGrid in [_inventory.backpack, _inventory.notary_box, _inventory.sling_pouch]:
		for item: ItemInstance in grid.all_items():
			_carried_ever[item.uid] = item.def_id


func _find_item(uid: int) -> ItemInstance:
	for grid: InventoryGrid in [_inventory.backpack, _inventory.notary_box, _inventory.sling_pouch]:
		var item := grid.items.get(uid) as ItemInstance
		if item != null:
			return item
	return null


func _refresh_hold_pause() -> void:
	if extract_state != ExtractState.S8_HOLD:
		return
	var reason: StringName = &""
	if not manifest_carried:
		reason = &"manifest_missing"
	elif not in_beacon_zone:
		reason = &"out_of_zone"
	var paused := not reason.is_empty()
	if paused == hold_paused and reason == hold_pause_reason:
		return
	hold_paused = paused
	hold_pause_reason = reason
	hold_paused_changed.emit(hold_paused, hold_pause_reason)


func _close_call_confirm(confirmed: bool) -> void:
	call_confirm_open = false
	call_confirm_closed.emit(confirmed)


func _set_extract_state(next_state: int) -> void:
	if extract_state == next_state:
		return
	var previous := extract_state
	extract_state = next_state
	extract_state_changed.emit(previous, next_state)


func _set_contract_state(next_state: int) -> void:
	if contract_state == next_state:
		return
	var previous := contract_state
	contract_state = next_state
	contract_state_changed.emit(previous, next_state)


func _set_desk_state(next_state: int) -> void:
	if desk_state == next_state:
		return
	desk_state = next_state
	desk_state_changed.emit(next_state)


func _used_backpack_cells() -> int:
	var used_cells := 0
	for item: ItemInstance in _inventory.backpack.all_items():
		used_cells += item.cells().size()
	return used_cells


func _item_entries(items: Array) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for item: ItemInstance in items:
		entries.append({"uid": item.uid, "def_id": item.def_id})
	return entries


func _string_names(values: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	for value: Variant in values:
		result.append(StringName(value))
	return result


func _lost_entries(summary: ExtractSummary) -> Array[Dictionary]:
	var extracted_uids: Dictionary = {}
	for entry: Dictionary in summary.kept:
		extracted_uids[entry["uid"]] = true
	var evidence_by_id: Dictionary = {}
	for def_id: StringName in summary.evidence:
		evidence_by_id[def_id] = true
	for uid: int in _carried_ever:
		var def_id: StringName = _carried_ever[uid]
		if evidence_by_id.has(def_id):
			extracted_uids[uid] = true
	var entries: Array[Dictionary] = []
	var uids: Array[int] = []
	for uid: int in _carried_ever:
		uids.append(uid)
	uids.sort()
	for uid in uids:
		if not extracted_uids.has(uid):
			entries.append({"uid": uid, "def_id": _carried_ever[uid]})
	return entries


func _entries_with_reason(items: Array, reason: StringName) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for item: ItemInstance in items:
		var entry := {
			"uid": item.uid,
			"def_id": item.def_id,
			"quantity": item.quantity,
			"anchor": item.anchor,
			"rotated": item.rotated,
		}
		if not reason.is_empty():
			entry["lost_reason"] = reason
		entries.append(entry)
	return entries


func _entry_uid_less(first: Dictionary, second: Dictionary) -> bool:
	return int(first["uid"]) < int(second["uid"])


func _is_terminal() -> bool:
	return extract_state == ExtractState.S10_SUCCESS or extract_state == ExtractState.ENDED_DEATH


func _inventory_contains_manifest() -> bool:
	for grid: InventoryGrid in [_inventory.backpack, _inventory.notary_box, _inventory.sling_pouch]:
		for item: ItemInstance in grid.all_items():
			if item.def_id == MANIFEST_DEF_ID:
				return true
	return false
