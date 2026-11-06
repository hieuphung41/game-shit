class_name BriefingFlow
extends Node
## Thin scene adapter for S1/O1. RunSession retains the exact inventory object.

const BOOT_SCENE := "res://src/boot/boot.tscn"
const OUTER_PIER_RUN_SCENE := "res://src/flow/outer_pier_run.tscn"
const BRIEFING_SCENE := preload("res://src/ui/briefing/briefing.tscn")
const LOADOUT_SCENE := preload("res://src/ui/loadout/loadout.tscn")

var _briefing: BriefingScreen
var _loadout: LoadoutScreen


func _ready() -> void:
	if RunSession.inventory == null:
		RunSession.begin_briefing()
	_show_briefing()


func _show_briefing() -> void:
	_briefing = BRIEFING_SCENE.instantiate() as BriefingScreen
	add_child(_briefing)
	_briefing.open_with_inventory(RunSession.inventory)
	_briefing.loadout_requested.connect(_open_loadout)
	_briefing.enter_outer_pier_requested.connect(_enter_outer_pier)
	_briefing.back_requested.connect(_return_to_boot)


func _open_loadout(inventory: RetrieverInventory) -> void:
	if _loadout != null:
		return
	_loadout = LOADOUT_SCENE.instantiate() as LoadoutScreen
	add_child(_loadout)
	_loadout.open_with_inventory(inventory)
	_loadout.finished.connect(_close_loadout)
	_loadout.cancelled.connect(_close_loadout)


func _close_loadout(_inventory: RetrieverInventory) -> void:
	if _loadout == null:
		return
	_loadout.queue_free()
	_loadout = null
	_briefing.refresh()


func _enter_outer_pier(inventory: RetrieverInventory) -> void:
	RunSession.begin_run(inventory)
	get_tree().change_scene_to_file(OUTER_PIER_RUN_SCENE)


func _return_to_boot() -> void:
	RunSession.clear()
	get_tree().change_scene_to_file(BOOT_SCENE)
