class_name OuterPierRun
extends Node3D
## Scene adapter for the playable Contract 1 loop. ExtractPierAFlow remains the
## source of truth for extraction; this node wires its authored A/B scene beats.

const BOOT_SCENE := "res://src/boot/boot.tscn"
const WORLD_SCENE := preload("res://src/world/zone_a_outer_pier.tscn")
const RETRIEVER_SCENE := preload("res://src/player/retriever.tscn")
const TAX_GUARD_SCENE := preload("res://src/enemies/tax_guard.tscn")
const FOREMAN_SCENE := preload("res://src/enemies/foreman.tscn")
const TAX_GUARD_MODEL := preload("res://src/characters/tax_guard_model.tscn")
const FOREMAN_MODEL := preload("res://src/characters/foreman_model.tscn")
const HUD_SCENE := preload("res://src/ui/hud/extract_hud.tscn")
const COMBAT_HUD_SCENE := preload("res://src/ui/combat/combat_hud.tscn")
const PICKUP_CARD_SCENE := preload("res://src/ui/pickup/pickup_card.tscn")
const PICKUP_PANEL_SCENE := preload("res://src/ui/pickup/pickup_panel.tscn")
const CACHE_PANEL_SCENE := preload("res://src/ui/pickup/loot_cache_panel.tscn")
const CONFIRM_SCENE := preload("res://src/ui/confirm/confirm_dialog.tscn")
const SUMMARY_SCENE := preload("res://src/ui/summary/extract_summary_screen.tscn")

const BEACON_ZONE_RADIUS_M := 3.0
const BOARD_ZONE_RADIUS_M := 1.5
const CACHE_INTERACT_RADIUS_M := 1.5

enum RouteBeat { A, GUARD, FOREMAN, CALM, RETURN }

var flow: ExtractPierAFlow
var _world: Node3D
var _zone_b: Node3D
var _retriever: RetrieverController
var _hud: ExtractHud
var _combat_hud: CombatHud
var _hud_layer: CanvasLayer
var _overlay_layer: CanvasLayer
var _overlay: Control
var _manifest_placeholder: MeshInstance3D
var _guard: EnemyActor
var _foreman: EnemyActor
var _patrol: EnemyActor
var _patrol_director: PatrolReturn
var _hold_director: HoldLaneBDirector
var _cache: LootCache
var _cache_button: Button
var _desk_in_range := false
var _gate_open := false
var _calm_visited := false
var _calm_inside := false
var _cache_in_range := false
var _patrol_started := false
var _route_beat: RouteBeat = RouteBeat.A


func _ready() -> void:
	if RunSession.inventory == null:
		RunSession.begin_briefing()
	if RunSession.extract_flow == null:
		RunSession.begin_run(RunSession.inventory)
	flow = RunSession.extract_flow
	_create_world()
	_create_hud()
	_connect_flow()
	_refresh_route_ui()


func _process(delta: float) -> void:
	if flow == null:
		return
	flow.tick(delta)
	_stop_patrol_on_return_to_deck_a()
	_update_gate()
	_update_danger()


func set_dispatch_in_range(inside: bool) -> void:
	_desk_in_range = inside
	_hud.set_desk_in_range(inside)


func set_beacon_in_range(inside: bool) -> void:
	flow.set_in_beacon_zone(inside)
	_hud.refresh()


func set_board_in_range(inside: bool) -> void:
	flow.set_in_board_zone(inside)
	_hud.refresh()


func set_calm_zone_in_range(inside: bool) -> void:
	_calm_inside = inside
	if inside:
		_calm_visited = true
		_route_beat = RouteBeat.CALM
		_combat_hud.clear_warning()
		_refresh_route_ui()
		return
	if _calm_visited and not _patrol_started:
		_start_patrol_return()
	_refresh_route_ui()


func set_cache_in_range(inside: bool) -> void:
	_cache_in_range = inside
	if not inside and _overlay is LootCachePanel:
		_close_overlay()
	_refresh_route_ui()


func request_dispatch() -> void:
	if flow.desk_state == ExtractPierAFlow.DeskState.HAS_MANIFEST and _desk_in_range:
		_open_dispatch_card()


func request_cache() -> void:
	if _overlay != null or not _calm_inside or not _cache_in_range or _cache == null or _cache.cache_state() == &"empty":
		return
	var panel := CACHE_PANEL_SCENE.instantiate() as LootCachePanel
	_present_overlay(panel)
	panel.configure(RunSession.inventory, _cache)
	panel.closed.connect(_close_overlay)
	panel.item_placed.connect(_on_cache_item_placed)


func request_call() -> void:
	flow.request_call()


func request_board() -> void:
	if flow.can_board():
		flow.board()


func _create_world() -> void:
	_world = WORLD_SCENE.instantiate() as Node3D
	_world.name = "ZoneAOuterPier"
	add_child(_world)
	_zone_b = _world.get_node_or_null("ZoneBFloodedMarket") as Node3D
	_retriever = RETRIEVER_SCENE.instantiate() as RetrieverController
	_world.add_child(_retriever)
	_retriever.add_to_group(&"retriever")
	_manifest_placeholder = _world.get_node_or_null("DispatchDesk/ManifestPlaceholder") as MeshInstance3D
	_create_zone("DispatchZone", _world.get_node("DispatchDesk") as Node3D, DispatchInteraction.DESK_INTERACT_RADIUS_M, _on_dispatch_entered, _on_dispatch_exited)
	_create_zone("BeaconZoneA", _world.get_node("BeaconA") as Node3D, BEACON_ZONE_RADIUS_M, _on_beacon_entered, _on_beacon_exited)
	_create_zone("BoardZoneA", _world.get_node("ExtractPierA") as Node3D, BOARD_ZONE_RADIUS_M, _on_board_entered, _on_board_exited)
	if _zone_b == null:
		return
	var calm_zone := _zone_b.get_node_or_null("CalmZoneB") as Area3D
	if calm_zone != null:
		calm_zone.body_entered.connect(_on_calm_body_entered)
		calm_zone.body_exited.connect(_on_calm_body_exited)
	var cache_anchor := _zone_b.get_node_or_null("CacheB") as Node3D
	if cache_anchor != null:
		_create_zone("CacheZoneB", cache_anchor, CACHE_INTERACT_RADIUS_M, _on_cache_entered, _on_cache_exited)
	var entry := _zone_b.get_node_or_null("BEntry") as Node3D
	if entry != null:
		_create_zone("BEntryZone", entry, 1.0, _on_b_entry_entered, _on_b_entry_exited)
	_cache = LootCache.new(RunSession.inventory.registry)
	_guard = _spawn_authored_enemy(TAX_GUARD_SCENE, TAX_GUARD_MODEL, "GuardPost", "WithdrawPointGuard")
	_foreman = _spawn_authored_enemy(FOREMAN_SCENE, FOREMAN_MODEL, "ForemanChargeLane/end_a", "WithdrawPointForeman")
	if _foreman != null:
		var lane := _zone_b.get_node_or_null("ForemanChargeLane") as Node3D
		if lane != null:
			var lane_start := lane.get_node_or_null("end_a") as Node3D
			var lane_end := lane.get_node_or_null("end_b") as Node3D
			if lane_start != null and lane_end != null:
				_foreman.configure_lane(lane_start.global_position, lane_end.global_position)


func _create_zone(zone_name: String, anchor: Node3D, radius_m: float, entered: Callable, exited: Callable) -> void:
	var zone := ProximityZone3D.new()
	zone.name = zone_name
	_world.add_child(zone)
	zone.configure(anchor, radius_m)
	zone.retriever_entered.connect(entered)
	zone.retriever_exited.connect(exited)


func _spawn_authored_enemy(scene: PackedScene, model_scene: PackedScene, home_path: String, withdraw_path: String) -> EnemyActor:
	if _zone_b == null:
		return null
	var home := _zone_b.get_node_or_null(home_path) as Node3D
	var withdraw := _zone_b.get_node_or_null(withdraw_path) as Node3D
	if home == null or withdraw == null:
		return null
	var enemy := scene.instantiate() as EnemyActor
	_world.add_child(enemy)
	enemy.global_position = home.global_position
	if enemy.brain != null:
		enemy.brain.set_position(enemy.global_position)
	enemy.configure_anchor(home.global_position, withdraw.global_position)
	_attach_model(enemy, model_scene)
	return enemy


func _attach_model(enemy: EnemyActor, model_scene: PackedScene) -> void:
	var visual := enemy.get_node_or_null("Visual") as Node3D
	if visual == null or visual.get_child_count() > 0:
		return
	var body := enemy.get_node_or_null("Body") as MeshInstance3D
	if body != null:
		body.visible = false
	visual.add_child(model_scene.instantiate())


func _create_hud() -> void:
	_hud_layer = CanvasLayer.new()
	_hud_layer.name = "HudLayer"
	_hud_layer.layer = 10
	add_child(_hud_layer)
	_hud = HUD_SCENE.instantiate() as ExtractHud
	_hud_layer.add_child(_hud)
	_hud.set_flow(flow)
	_hud.dispatch_requested.connect(request_dispatch)
	_hud.call_requested.connect(request_call)
	_hud.board_requested.connect(request_board)
	_hud.inventory_requested.connect(_open_inventory_view)
	_cache_button = Button.new()
	_cache_button.name = "CacheButton"
	_cache_button.text = tr(&"WORLD_INTERACT_CACHE_B")
	_cache_button.position = Vector2(1024, 448)
	_cache_button.size = Vector2(240, 96)
	_cache_button.add_theme_font_size_override("font_size", 24)
	_cache_button.visible = false
	_cache_button.pressed.connect(request_cache)
	_hud.add_child(_cache_button)
	_combat_hud = COMBAT_HUD_SCENE.instantiate() as CombatHud
	_hud_layer.add_child(_combat_hud)
	_combat_hud.set_combat(_retriever.combat)
	_combat_hud.boot_requested.connect(_return_to_boot)
	_combat_hud.danger_close_requested.connect(_close_danger_overlay)
	_retriever.combat.health.depleted.connect(_on_retriever_depleted)
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.name = "OverlayLayer"
	_overlay_layer.layer = 20
	add_child(_overlay_layer)


func _connect_flow() -> void:
	flow.call_confirm_opened.connect(_on_call_confirm_opened)
	flow.call_confirm_closed.connect(_on_call_confirm_closed)
	flow.desk_state_changed.connect(_on_desk_state_changed)
	flow.extract_succeeded.connect(_on_extract_succeeded)
	flow.hold_started.connect(_on_hold_started)


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
	var panel := CACHE_PANEL_SCENE.instantiate() as LootCachePanel
	_present_overlay(panel)
	panel.open_view(RunSession.inventory)
	panel.closed.connect(_close_overlay)


func _on_manifest_placed(_target: StringName, _anchor: Vector2i) -> void:
	RunSession.ground_manifest = null


func _on_pickup_panel_closed(_placed: bool) -> void:
	_close_overlay()


func _on_cache_item_placed(_item: ItemInstance, _target: StringName, _anchor: Vector2i) -> void:
	if _cache != null and _cache.cache_state() == &"empty":
		var cache_mesh := _zone_b.get_node_or_null("CacheB/Mesh") as MeshInstance3D
		if cache_mesh != null:
			cache_mesh.visible = false
	_refresh_route_ui()


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


func _on_hold_started(_duration: float) -> void:
	_route_beat = RouteBeat.RETURN
	_refresh_route_ui()
	_start_hold_director()


func _start_hold_director() -> void:
	if _hold_director != null or _zone_b == null:
		return
	_hold_director = HoldLaneBDirector.new()
	_hold_director.spawn_parent_path = NodePath("..")
	_hold_director.spawn_marker_path = NodePath("../ZoneBFloodedMarket/HoldLaneBSpawn")
	_hold_director.hold_path_root = NodePath("../ZoneBFloodedMarket/HoldLaneBPath")
	_hold_director.hold_guard_post_path = NodePath("../ZoneBFloodedMarket/HoldGuardPost")
	_hold_director.hold_charge_lane_path = NodePath("../ZoneBFloodedMarket/HoldChargeLane")
	_hold_director.alert_lamp_path = NodePath("../ZoneBFloodedMarket/LaneBAlertLamp")
	_world.add_child(_hold_director)
	_hold_director.enemy_spawned.connect(_on_hold_enemy_spawned)
	_hold_director.lane_alert_started.connect(func() -> void: _combat_hud.show_warning(&"HUD_ALERT_LANE_B"))
	_hold_director.bind_flow(flow)
	_hold_director.on_hold_started(ExtractPierAFlow.EXTRACT_HOLD_SECONDS)


func _on_hold_enemy_spawned(role_id: StringName, enemy: EnemyActor) -> void:
	_attach_model(enemy, TAX_GUARD_MODEL if role_id == &"tax_guard" else FOREMAN_MODEL)


func _on_extract_succeeded(summary: ExtractSummary) -> void:
	if _hold_director != null:
		_hold_director.on_run_ended()
	if _patrol_director != null:
		_patrol_director.stop()
	for enemy: EnemyActor in [_guard, _foreman, _patrol]:
		_deactivate_combat_actor(enemy)
	if _hold_director != null:
		for enemy: EnemyActor in _hold_director._enemies:
			_deactivate_combat_actor(enemy)
	_hud.visible = false
	_combat_hud.visible = false
	var screen := SUMMARY_SCENE.instantiate() as ExtractSummaryScreen
	_present_overlay(screen)
	screen.show_summary(summary, RunSession.inventory.registry)
	screen.hub_requested.connect(_return_to_boot)


func _on_retriever_depleted() -> void:
	if flow == null or flow.extract_state in [ExtractPierAFlow.ExtractState.S10_SUCCESS, ExtractPierAFlow.ExtractState.ENDED_DEATH]:
		return
	flow.notify_death()
	if _hold_director != null:
		_hold_director.on_run_ended()
	_close_overlay(false)
	_combat_hud.set_overlay_open(true)


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


func _on_calm_body_entered(body: Node3D) -> void:
	if body == _retriever:
		set_calm_zone_in_range(true)


func _on_calm_body_exited(body: Node3D) -> void:
	if body == _retriever:
		set_calm_zone_in_range(false)


func _on_cache_entered() -> void:
	set_cache_in_range(true)


func _on_cache_exited() -> void:
	set_cache_in_range(false)


func _on_b_entry_entered() -> void:
	if _route_beat == RouteBeat.A:
		_route_beat = RouteBeat.GUARD
		_refresh_route_ui()


func _on_b_entry_exited() -> void:
	pass


func _update_gate() -> void:
	if _gate_open or _guard == null or _foreman == null:
		return
	if not _guard.is_lane_pressure_resolved() or not _foreman.is_lane_pressure_resolved():
		return
	_gate_open = true
	var barrier := _zone_b.get_node_or_null("GateB/GateBBarrier") as StaticBody3D
	if barrier != null:
		var collision := barrier.get_node_or_null("CollisionShape3D") as CollisionShape3D
		if collision != null:
			collision.set_deferred(&"disabled", true)
		var tween := create_tween()
		tween.tween_property(barrier, "rotation:x", PI * 0.5, 1.0)
	_route_beat = RouteBeat.FOREMAN
	_refresh_route_ui()


func _start_patrol_return() -> void:
	if _patrol_started or _zone_b == null:
		return
	_patrol_started = true
	var spawn := _zone_b.get_node_or_null("PatrolReturnPath/P0") as Node3D
	var withdraw := _zone_b.get_node_or_null("WithdrawPointPatrolB") as Node3D
	if spawn == null or withdraw == null:
		return
	_patrol = TAX_GUARD_SCENE.instantiate() as EnemyActor
	_world.add_child(_patrol)
	_patrol.global_position = spawn.global_position
	if _patrol.brain != null:
		_patrol.brain.set_position(_patrol.global_position)
	_patrol.configure_anchor(spawn.global_position, withdraw.global_position)
	_attach_model(_patrol, TAX_GUARD_MODEL)
	_patrol_director = PatrolReturn.new()
	_world.add_child(_patrol_director)
	_patrol_director.guard_path = _patrol_director.get_path_to(_patrol)
	_patrol_director.path_root = _patrol_director.get_path_to(_zone_b.get_node("PatrolReturnPath"))
	_patrol_director.alert_lamp_path = _patrol_director.get_path_to(_zone_b.get_node("PatrolAlertLampB"))
	_patrol_director._guard = _patrol
	_patrol_director._lamp = _zone_b.get_node_or_null("PatrolAlertLampB")
	_patrol_director.patrol_cue_started.connect(func() -> void: _combat_hud.show_warning(&"HUD_ALERT_PATROL_B"))
	_patrol_director.activate()
	_route_beat = RouteBeat.RETURN
	_refresh_route_ui()


func _stop_patrol_on_return_to_deck_a() -> void:
	if _patrol_director == null or _zone_b == null or _retriever == null:
		return
	if _retriever.global_position.x < _zone_b.global_position.x:
		_patrol_director.stop()


func _deactivate_combat_actor(enemy: EnemyActor) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	enemy.set_physics_process(false)
	enemy.collision_layer = 0
	enemy.collision_mask = 0
	enemy.remove_from_group(&"combat_targets")


func _update_danger() -> void:
	if _combat_hud == null or _retriever == null:
		return
	var near := false
	var windup := false
	for enemy: EnemyActor in [_guard, _foreman, _patrol]:
		if enemy == null or enemy.brain == null:
			continue
		if enemy.global_position.distance_to(_retriever.global_position) > 9.0:
			continue
		if enemy.brain.state in [EnemyBrain.STATE_ALERT, EnemyBrain.STATE_WINDUP, EnemyBrain.STATE_STRIKE, EnemyBrain.STATE_CHARGE, EnemyBrain.STATE_RECOVER]:
			near = true
			windup = windup or enemy.brain.state == EnemyBrain.STATE_WINDUP
	if _hold_director != null and not _hold_director._stopped:
		near = true
	_combat_hud.set_danger_near(near, windup)


func _present_overlay(next_overlay: Control) -> void:
	_close_overlay(false)
	_overlay = next_overlay
	_overlay_layer.add_child(_overlay)
	_hud.set_overlay_open(true)
	_set_retriever_overlay_open(true)
	_refresh_route_ui()


func _close_overlay(_restore_control: bool = true) -> void:
	if _overlay != null:
		_overlay.queue_free()
		_overlay = null
	if _hud != null:
		_hud.set_overlay_open(false)
	if _combat_hud != null and flow != null and flow.extract_state != ExtractPierAFlow.ExtractState.ENDED_DEATH:
		_combat_hud.set_overlay_open(false)
	_set_retriever_overlay_open(false)
	_refresh_route_ui()


func _close_danger_overlay() -> void:
	if _overlay is ConfirmDialog:
		_cancel_call()
	else:
		_close_overlay()


func _set_retriever_overlay_open(open: bool) -> void:
	if _retriever != null:
		_retriever.set_overlay_open(open)
	if _combat_hud != null:
		_combat_hud.set_overlay_open(open)


func _refresh_route_ui() -> void:
	if _hud == null or _combat_hud == null:
		return
	var key: StringName = &"HUD_OBJECTIVE_TAKE_MANIFEST"
	if _route_beat in [RouteBeat.GUARD, RouteBeat.FOREMAN]:
		key = &"HUD_OBJECTIVE_CROSS_TAX_POST"
	elif _route_beat in [RouteBeat.CALM, RouteBeat.RETURN]:
		key = &"HUD_OBJECTIVE_DELIVER_PIER_A"
	if flow != null and flow.extract_state == ExtractPierAFlow.ExtractState.S8_HOLD:
		key = &"HUD_OBJECTIVE_HOLD_PIER_A"
	var objective := _hud.get_node_or_null("ObjectivePanel/Objective") as Label
	if objective != null:
		objective.text = tr(key)
	_combat_hud.set_objective(key)
	if _cache_button != null:
		_cache_button.visible = _calm_inside and _cache_in_range and _cache != null and _cache.cache_state() != &"empty" and _overlay == null


func _is_near(path: String, radius: float) -> bool:
	var anchor := _world.get_node_or_null(path) as Node3D
	return anchor != null and _retriever != null and DispatchInteraction.is_in_range(_retriever.global_position, anchor.global_position, radius)
