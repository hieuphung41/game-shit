class_name Health
extends RefCounted
## Pure hit-point state shared by Retriever and enemy combat targets.

signal changed(hp: int, max_hp: int)
signal depleted

var max_hp: int
var hp: int


func _init(p_max_hp: int = 100) -> void:
	max_hp = maxi(1, p_max_hp)
	hp = max_hp


func damage(amount: int) -> int:
	if amount <= 0 or is_depleted():
		return 0
	var applied := mini(amount, hp)
	hp -= applied
	changed.emit(hp, max_hp)
	if hp == 0:
		depleted.emit()
	return applied


func heal(amount: int) -> int:
	if amount <= 0 or is_depleted() or hp == max_hp:
		return 0
	var healed := mini(amount, max_hp - hp)
	hp += healed
	changed.emit(hp, max_hp)
	return healed


func is_depleted() -> bool:
	return hp == 0
