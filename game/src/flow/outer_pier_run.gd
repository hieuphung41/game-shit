class_name OuterPierRun
extends Node3D
## Scene adapter for the playable Contract 1 loop. ExtractPierAFlow remains the
## source of truth for run state; this node only translates zones and UI intent.

const BOOT_SCENE := "res://src/boot/boot.tscn"
const WORLD_SCENE := preload("res://src/world/zone_a_outer_pier.tscn")
const RETRIEVER_SCENE := preload("res://src/player/retriever.tscn")
const HUD_SCENE := preload("res://src/ui/hud/extract_hud.tscn")
const PICKUP_CARD_SCENE := preload("res://src/ui/pickup/pickup_card.tscn")
const PICKUP_PANEL_SCENE := preload("res://src/ui/pickup/pickup_panel.tscn")
const CONFIRM_SCENE := preload("res://src/ui/confirm/confirm_dialog.tscn")
const SUMMARY_SCENE := preload("res://src/ui/summary/extract_summary_screen.tscn")

const BEACON_ZONE_RADIUS_M := 3.0
const BOARD_ZONE_RADIUS_M := 1.5

var flow: ExtractPierAFlow
var _world: Node3D
var _retriever: CharacterBody3D
var _hud: ExtractHud
var _hud_layer: CanvasLayer
var _overlay_layer: CanvasLayer
var _overlay: Control
var _desk_in_range := false
var _manifest_placeholder: MeshInstance3D


func _ready() -> void:
	if RunSession.inventory == null:
		RunSession.begin_briefing()
	if RunSession.extract_flow == null:
		RunSession.begin_run(RunSession.inventory)
	flow = RunSession.extract_flow
	_create_world()
	_create_hud()
	flow.call_confirm_opened.connect(_on_call_confirm_opened)
	flow.call_confirm_closed.connect(_on_call_confirm_closed)
	flow.desk_state_changed.connect(_on_desk_state_changed)
	flow.extract_succeeded.connect(_on_extract_succeeded)


func _process(delta: float) -> void:
	flow.tick(delta)


func set_dispatch_in_range(inside: bool) -> void:
	_desk_in_range = inside
	_hud.set_desk_in_range(inside)


func set_beacon_in_range(inside: bool) -> void:
	flow.set_in_beacon_zone(inside)
	_hud.refresh()


func set_board_in_range(inside: bool) -> void:
	flow.set_in_board_zone(inside)
	_hud.refresh()


func request_dispatch() -> void:
	if _desk_in_range and flow.desk_state == ExtractPierAFlow.DeskState.HAS_MANIFEST:
		_open_dispatch_card()


func request_call() -> void:
	flow.request_call()


func request_board() -> void:
	if flow.can_board():
		flow.board()


func _create_world() -> void:
	_world = WORLD_SCENE.instantiate() as Node3D
	_world.name = "ZoneAOuterPier"
	add_child(_world)
	_retriever = RETRIEVER_SCENE.instantiate() as CharacterBody3D
	_world.add_child(_retriever)
	_manifest_placeholder = _world.get_node_or_null("DispatchDesk/ManifestPlaceholder") as MeshInstance3D
	_create_zone("DispatchZone", _world.get_node("DispatchDesk") as Node3D, DispatchInteraction.DESK_INTERACT_RADIUS_M, _on_dispatch_entered, _on_dispatch_exited)
	_create_zone("BeaconZoneA", _world.get_node("BeaconA") as Node3D, BEACON_ZONE_RADIUS_M, _on_beacon_entered, _on_beacon_exited)
	_create_zone("BoardZoneA", _world.get_node("ExtractPierA") as Node3D, BOARD_ZONE_RADIUS_M, _on_board_entered, _on_board_exited)


func _create_zone(zone_name: String, anchor: Node3D, radius_m: float, entered: Callable, exited: Callable) -> void:
	var zone := ProximityZone3D.new()
	zone.name = zone_name
	_world.add_child(zone)
	zone.configure(anchor, radius_m)
	zone.retriever_entered.connect(entered)
	zone.retriever_exited.connect(exited)


func _create_hud() -> void:
	_hud_layer = CanvasLayer.new()
	_hud_layer.name = "HudLayer"
	_hud_layer.layer = 10
	add_child(_hud_layer)
	_hud = HUD_SCENE.instantiate() as ExtractHud
	_hud_layer.add_child(_hud)
	_hud.set_flow(flow)
	_hud.set_desk_in_range(_desk_in_range)
	_hud.dispatch_requested.connect(request_dispatch)
	_hud.call_requested.connect(request_call)
	_hud.board_requested.connect(request_board)
	_hud.inventory_requested.connect(_open_inventory_view)
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.name = "OverlayLayer"
	_overlay_layer.layer = 20
	add_child(_overlay_layer)


func _open_dispatch_card() -> void:
	var card := PICKUP_CARD_SCENE.instantiate() as ManifestPickupCard
	_present_overlay(card)
	card.pickup_requested.connect(_open_pickup_panel)
	card.closed.connect(_close_overlay)
	card.skipped.connect(_close_overlay)


func _open_pickup_panel() -> void:
	if RunSession.ground_manifest == null:
		_close_overlay()
		return
	var panel := PICKUP_PANEL_SCENE.instantiate() as ManifestPickupPanel
	_present_overlay(panel)
	panel.open_pickup(RunSession.inventory, RunSession.ground_manifest)
	panel.manifest_placed.connect(_on_manifest_placed)
	panel.closed.connect(_on_pickup_panel_closed)


func _open_inventory_view() -> void:
	var panel := PICKUP_PANEL_SCENE.instantiate() as ManifestPickupPanel
	_present_overlay(panel)
	panel.open_view(RunSession.inventory)
	panel.closed.connect(_on_pickup_panel_closed)


func _on_manifest_placed(_target: StringName, _anchor: Vector2i) -> void:
	RunSession.ground_manifest = null


func _on_pickup_panel_closed(_placed: bool) -> void:
	_close_overlay()


func _on_call_confirm_opened() -> void:
	var dialog := CONFIRM_SCENE.instantiate() as ConfirmDialog
	dialog.configure(&"EXTRACT_CONFIRM_TITLE", &"EXTRACT_CONFIRM_BODY", &"EXTRACT_CONFIRM_ACCEPT", &"EXTRACT_CONFIRM_CANCEL", {"seconds": int(ExtractPierAFlow.EXTRACT_HOLD_SECONDS)})
	_present_overlay(dialog)
	dialog.accepted.connect(_confirm_call)
	dialog.cancelled.connect(_cancel_call)


func _confirm_call() -> void:
	flow.confirm_call()


func _cancel_call() -> void:
	flow.cancel_call()


func _on_call_confirm_closed(_confirmed: bool) -> void:
	if _overlay is ConfirmDialog:
		_close_overlay()


func _on_extract_succeeded(summary: ExtractSummary) -> void:
	_hud.visible = false
	var screen := SUMMARY_SCENE.instantiate() as ExtractSummaryScreen
	_present_overlay(screen)
	screen.show_summary(summary, RunSession.inventory.registry)
	screen.hub_requested.connect(_return_to_boot)


func _return_to_boot() -> void:
	RunSession.clear()
	var result := get_tree().change_scene_to_file(BOOT_SCENE)
	if result != OK and _overlay is ExtractSummaryScreen:
		(_overlay as ExtractSummaryScreen).show_scene_load_error()


func _on_desk_state_changed(state: int) -> void:
	if _manifest_placeholder != null:
		_manifest_placeholder.visible = state == ExtractPierAFlow.DeskState.HAS_MANIFEST
	_hud.refresh()


func _on_dispatch_entered() -> void:
	set_dispatch_in_range(true)


func _on_dispatch_exited() -> void:
	set_dispatch_in_range(false)


func _on_beacon_entered() -> void:
	set_beacon_in_range(true)


func _on_beacon_exited() -> void:
	set_beacon_in_range(false)


func _on_board_entered() -> void:
	set_board_in_range(true)


func _on_board_exited() -> void:
	set_board_in_range(false)


func _present_overlay(next_overlay: Control) -> void:
	_close_overlay(false)
	_overlay = next_overlay
	_overlay_layer.add_child(_overlay)
	_hud.set_overlay_open(true)
	_set_retriever_control_enabled(false)


func _close_overlay(restore_control: bool = true) -> void:
	if _overlay != null:
		_overlay.queue_free()
		_overlay = null
	_hud.set_overlay_open(false)
	if restore_control and flow.extract_state != ExtractPierAFlow.ExtractState.S10_SUCCESS:
		_set_retriever_control_enabled(true)


func _set_retriever_control_enabled(enabled: bool) -> void:
	if _retriever != null:
		_retriever.set_physics_process(enabled)
