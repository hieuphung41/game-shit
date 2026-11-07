class_name DeathSummary
extends RefCounted
## Read-only presentation model for S11. ExtractPierAFlow owns construction and
## transition state; this object deliberately contains no rules or UI state.

var kept: Array[Dictionary] = []
var lost: Array[Dictionary] = []
var equipped_gear_lost := true
var unrecovered_evidence: Array[StringName] = []
var contract_state_at_death := 0
var contract_state := 0
var death_variant: StringName = &"before_manifest"


func to_dict() -> Dictionary:
	return {
		"kept": kept.duplicate(true),
		"lost": lost.duplicate(true),
		"equipped_gear_lost": equipped_gear_lost,
		"unrecovered_evidence": unrecovered_evidence.duplicate(),
		"contract_state_at_death": contract_state_at_death,
		"contract_state": contract_state,
		"death_variant": death_variant,
	}
