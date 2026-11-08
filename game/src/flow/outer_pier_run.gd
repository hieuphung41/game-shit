class_name OuterPierRun
extends Node3D
## Scene adapter for the playable Contract 1 loop. ExtractPierAFlow remains the
## source of truth for extraction; this node wires its authored A/B scene beats.

const BOOT_SCENE := "res://src/boot/boot.tscn"
const WORLD_SCENE := preload("res://src/world/zone_a_outer_pier.tscn")
const ZONE_D_SCENE := preload("res://src/world/zone_d_floating_warehouse.tscn")
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
const DEATH_SUMMARY_SCENE := preload("res://src/ui/death/death_summary_screen.tscn")
const RECALL_SIGIL_SCENE := preload("res://src/ui/death/recall_sigil_overlay.tscn")
const RECOVERY_CONTRACT_SCENE := preload("res://src/ui/recovery/recovery_contract_screen.tscn")

const BEACON_ZONE_RADIUS_M := 3.0
const BOARD_ZONE_RADIUS_M := 1.5
const CACHE_INTERACT_RADIUS_M := 1.5
const RECALL_SIGIL_SECONDS := RecallSigilOverlay.RECALL_SIGIL_SECONDS
const ZONE_D_WORLD_POSITION := Vector3(11.75, 0.0, -36.95)
const SOURCE_CARGO_D: StringName = &"source_cargo_d"
const SOURCE_TAX_STAMP_D: StringName = &"source_tax_stamp_d"

enum RouteBeat { A, GUARD, FOREMAN, CALM, D, RETURN }

var flow: ExtractPierAFlow
var _world: Node3D
var _zone_b: Node3D
var _zone_d: Node3D
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
var _cargo_cache: LootCache
var _stamp_cache: LootCache
var _cache_button: Button
var _cargo_button: Button
var _stamp_button: Button
var _ground_button: Button
var _desk_in_range := false
var _gate_open := false
var _calm_visited := false
var _calm_inside := false
var _d_calm_inside := false
var _cache_in_range := false
var _d_source_in_range: Dictionary = {}
var _ground_drops: Dictionary = {}
var _ground_drops_in_range: Dictionary = {}
var _skipped_ground_drop_uids: Dictionary = {}
var _pending_ground_items: Dictionary = {}
var _nearest_ground_drop: GroundDrop
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
	_refresh_route_ui()


func set_zone_d_calm_in_range(inside: bool) -> void:
	_d_calm_inside = inside
	if inside:
		_route_beat = RouteBeat.D
	_refresh_route_ui()


func set_cache_in_range(inside: bool) -> void:
	_cache_in_range = inside
	if not inside and _overlay is LootCachePanel:
		_close_overlay()
	_refresh_route_ui()


func request_dispatch() -> void:
	if flow.desk_state == ExtractPierAFlow.DeskState.HAS_MANIFEST and _desk_in_range and _dispatch_manifest_available():
		_open_dispatch_card()


func request_cache() -> void:
	if _overlay != null or not _is_context_target_active(&"cache") or _cache == null or _cache.cache_state() == &"empty":
		return
	var panel := CACHE_PANEL_SCENE.instantiate() as LootCachePanel
	_present_overlay(panel)
	panel.configure(RunSession.inventory, _cache)
	panel.closed.connect(_close_overlay)
	panel.item_placed.connect(_on_cache_item_placed)


func request_d_source(source_id: StringName) -> void:
	if _overlay != null or not _is_context_target_active(&"source", source_id):
		return
	var cache := _d_cache(source_id)
	if cache == null or cache.cache_state() == &"empty":
		return
	var panel := CACHE_PANEL_SCENE.instantiate() as LootCachePanel
	_present_overlay(panel)
	panel.configure_s04(RunSession.inventory, cache)
	panel.closed.connect(_close_overlay)
	panel.item_placed.connect(_on_dynamic_item_placed.bind(source_id))


func request_ground_drop() -> void:
	if _overlay != null or not _ground_drop_interaction_allowed() or not _is_context_target_active(&"ground") or _nearest_ground_drop == null or not is_instance_valid(_nearest_ground_drop):
		return
	_skipped_ground_drop_uids.clear()
	_open_ground_drop(_nearest_ground_drop)


func _open_ground_drop(drop: GroundDrop) -> void:
	if drop == null or not is_instance_valid(drop) or drop.item == null:
		return
	var cache := LootCache.new()
	cache.load_single_ground_item(drop.item, StringName("ground_drop_%d" % drop.item.uid))
	var panel := CACHE_PANEL_SCENE.instantiate() as LootCachePanel
	_present_overlay(panel)
	panel.configure_s04(RunSession.inventory, cache)
	panel.closed.connect(_close_overlay)
	panel.item_placed.connect(_on_dynamic_item_placed.bind(cache.cache_id))
	var card := panel.get_node_or_null("LootCacheCard") as LootCacheCard
	if card != null:
		card.skipped.connect(_on_ground_drop_skipped.bind(drop))


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
	_zone_d = ZONE_D_SCENE.instantiate() as Node3D
	_zone_d.position = ZONE_D_WORLD_POSITION
	_world.add_child(_zone_d)
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
	var patrol_trigger := _zone_b.get_node_or_null("PatrolTriggerB") as Area3D
	if patrol_trigger != null:
		patrol_trigger.body_entered.connect(_on_patrol_trigger_body_entered)
	_cache = LootCache.new(RunSession.inventory.registry)
	_cargo_cache = _single_item_cache(201, &"cargo_d_2x2", SOURCE_CARGO_D)
	_stamp_cache = _single_item_cache(202, &"tax_stamp_d", SOURCE_TAX_STAMP_D)
	_connect_zone_d()
	RunSession.inventory.item_dropped.connect(_on_inventory_item_dropped)
	_guard = _spawn_authored_enemy(TAX_GUARD_SCENE, TAX_GUARD_MODEL, "GuardPost", "WithdrawPointGuard")
	_foreman = _spawn_authored_enemy(FOREMAN_SCENE, FOREMAN_MODEL, "ForemanChargeLane/end_a", "WithdrawPointForeman")
	if _foreman != null:
		var lane := _zone_b.get_node_or_null("ForemanChargeLane") as Node3D
		if lane != null:
			var lane_start := lane.get_node_or_null("end_a") as Node3D
			var lane_end := lane.get_node_or_null("end_b") as Node3D
			if lane_start != null and lane_end != null:
				_foreman.configure_lane(lane_start.global_position, lane_end.global_position)


func _connect_zone_d() -> void:
	if _zone_d == null:
		return
	var calm_zone := _zone_d.get_node_or_null("CalmZoneD") as Area3D
	if calm_zone != null:
		calm_zone.body_entered.connect(_on_zone_d_calm_body_entered)
		calm_zone.body_exited.connect(_on_zone_d_calm_body_exited)
	_connect_d_source(SOURCE_CARGO_D, "CargoD")
	_connect_d_source(SOURCE_TAX_STAMP_D, "TaxStampD")


func _connect_d_source(source_id: StringName, node_name: String) -> void:
	var area := _zone_d.get_node_or_null("%s/InteractArea" % node_name) as Area3D
	if area == null:
		return
	area.body_entered.connect(_on_d_source_body_entered.bind(source_id))
	area.body_exited.connect(_on_d_source_body_exited.bind(source_id))


func _single_item_cache(uid: int, def_id: StringName, source_id: StringName) -> LootCache:
	var cache := LootCache.new()
	cache.load_single_ground_item(ItemInstance.new(uid, RunSession.inventory.registry.get_def(def_id)), source_id)
	return cache


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
	_cargo_button = _create_context_button("CargoDButton", &"WORLD_INTERACT_CARGO_D", Vector2(1024, 336))
	_cargo_button.pressed.connect(request_d_source.bind(SOURCE_CARGO_D))
	_stamp_button = _create_context_button("TaxStampDButton", &"WORLD_INTERACT_TAX_STAMP_D", Vector2(1024, 448))
	_stamp_button.pressed.connect(request_d_source.bind(SOURCE_TAX_STAMP_D))
	_ground_button = _create_context_button("GroundDropButton", &"WORLD_INTERACT_GROUND_DROP", Vector2(1024, 560))
	_ground_button.pressed.connect(request_ground_drop)
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


func _create_context_button(node_name: String, key: StringName, at: Vector2) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = tr(key)
	button.position = at
	button.size = Vector2(240, 96)
	button.add_theme_font_size_override("font_size", 24)
	button.visible = false
	_hud.add_child(button)
	return button


func _connect_flow() -> void:
	flow.call_confirm_opened.connect(_on_call_confirm_opened)
	flow.call_confirm_closed.connect(_on_call_confirm_closed)
	flow.desk_state_changed.connect(_on_desk_state_changed)
	flow.extract_succeeded.connect(_on_extract_succeeded)
	flow.hold_started.connect(_on_hold_started)


func _open_dispatch_card() -> void:
	if not _dispatch_manifest_available():
		return
	var card := PICKUP_CARD_SCENE.instantiate() as ManifestPickupCard
	card.configure(flow.can_recover_manifest())
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
	panel.s04_mode = true
	panel.open_view(RunSession.inventory)
	panel.closed.connect(_close_overlay)
	panel.item_drop_confirmed.connect(_on_panel_item_drop_confirmed)


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


func _on_dynamic_item_placed(item: ItemInstance, _target: StringName, _anchor: Vector2i, source_id: StringName) -> void:
	if source_id == SOURCE_CARGO_D or source_id == SOURCE_TAX_STAMP_D:
		var cache := _d_cache(source_id)
		if cache != null and cache.cache_state() == &"empty":
			_set_d_source_visible(source_id, false)
	else:
		var drop := _ground_drops.get(item.uid) as GroundDrop
		if drop != null and is_instance_valid(drop):
			drop.queue_free()
		_ground_drops.erase(item.uid)
		_ground_drops_in_range.erase(item.uid)
		_recompute_nearest_ground_drop()
	_refresh_route_ui()


func _on_inventory_item_dropped(item: ItemInstance) -> void:
	if item == null:
		return
	_pending_ground_items[item.uid] = item


func _on_panel_item_drop_confirmed(uid: int) -> void:
	var item := _pending_ground_items.get(uid) as ItemInstance
	_pending_ground_items.erase(uid)
	if _world == null or _retriever == null or item == null:
		return
	var drop := GroundDrop.new()
	drop.name = "GroundDrop_%d" % item.uid
	_world.add_child(drop)
	drop.configure(item, Vector3(_retriever.global_position.x, 0.0, _retriever.global_position.z))
	drop.retriever_entered.connect(_on_ground_drop_entered)
	drop.retriever_exited.connect(_on_ground_drop_exited)
	_ground_drops[item.uid] = drop
	_refresh_route_ui()


func _on_ground_drop_entered(drop: GroundDrop) -> void:
	if drop != null and drop.item != null:
		_ground_drops_in_range[drop.item.uid] = drop
		_recompute_nearest_ground_drop()
	_refresh_route_ui()


func _on_ground_drop_exited(drop: GroundDrop) -> void:
	if drop != null and drop.item != null:
		_ground_drops_in_range.erase(drop.item.uid)
		_recompute_nearest_ground_drop()
	_refresh_route_ui()


func _on_ground_drop_skipped(_item: ItemInstance, skipped_drop: GroundDrop) -> void:
	if skipped_drop == null or skipped_drop.item == null:
		return
	_skipped_ground_drop_uids[skipped_drop.item.uid] = true
	_open_ground_drop(_nearest_ground_drop_in_range(_skipped_ground_drop_uids))


func _recompute_nearest_ground_drop() -> void:
	_nearest_ground_drop = _nearest_ground_drop_in_range()


func _nearest_ground_drop_in_range(excluded: Dictionary = {}) -> GroundDrop:
	var nearest: GroundDrop
	for value in _ground_drops_in_range.values():
		var candidate := value as GroundDrop
		if candidate == null or not is_instance_valid(candidate) or candidate.item == null:
			continue
		if excluded.has(candidate.item.uid) or _ground_drops.get(candidate.item.uid) != candidate:
			continue
		if nearest == null or _is_closer_drop(candidate, nearest):
			nearest = candidate
	return nearest


func _is_closer_drop(candidate: GroundDrop, current: GroundDrop) -> bool:
	if _retriever == null:
		return false
	var candidate_distance := candidate.global_position.distance_squared_to(_retriever.global_position)
	var current_distance := current.global_position.distance_squared_to(_retriever.global_position)
	return candidate_distance < current_distance or (is_equal_approx(candidate_distance, current_distance) and candidate.item.uid < current.item.uid)


func _ground_drop_interaction_allowed() -> bool:
	if flow == null:
		return false
	return flow.extract_state not in [
		ExtractPierAFlow.ExtractState.S8_HOLD,
		ExtractPierAFlow.ExtractState.S10_SUCCESS,
		ExtractPierAFlow.ExtractState.ENDED_DEATH,
	]


func _is_context_target_active(kind: StringName, source_id: StringName = &"") -> bool:
	var target := _active_context_target()
	return target.get(&"kind", &"") == kind and target.get(&"source_id", &"") == source_id


func _active_context_target() -> Dictionary:
	if _retriever == null:
		return {}
	var candidates: Array[Dictionary] = []
	if _calm_inside and _cache_in_range and _cache != null and _cache.cache_state() != &"empty":
		var cache_anchor := _zone_b.get_node_or_null("CacheB") as Node3D if _zone_b != null else null
		if cache_anchor != null:
			candidates.append(_context_candidate(&"cache", &"", cache_anchor.global_position, 0))
	for source_id: StringName in [SOURCE_CARGO_D, SOURCE_TAX_STAMP_D]:
		if not bool(_d_source_in_range.get(source_id, false)):
			continue
		var cache := _d_cache(source_id)
		var source_area := _d_source_area(source_id)
		if cache != null and cache.cache_state() != &"empty" and source_area != null:
			candidates.append(_context_candidate(&"source", source_id, source_area.global_position, 0))
	if _ground_drop_interaction_allowed() and _nearest_ground_drop != null and is_instance_valid(_nearest_ground_drop):
		candidates.append(_context_candidate(&"ground", &"", _nearest_ground_drop.global_position, _nearest_ground_drop.item.uid))
	var active: Dictionary = {}
	for candidate: Dictionary in candidates:
		if active.is_empty() or _is_closer_context_target(candidate, active):
			active = candidate
	return active


func _context_candidate(kind: StringName, source_id: StringName, position: Vector3, uid: int) -> Dictionary:
	return {
		&"kind": kind,
		&"source_id": source_id,
		&"position": position,
		&"uid": uid,
	}


func _is_closer_context_target(candidate: Dictionary, current: Dictionary) -> bool:
	var candidate_position := candidate.get(&"position", Vector3.ZERO) as Vector3
	var current_position := current.get(&"position", Vector3.ZERO) as Vector3
	var candidate_distance := candidate_position.distance_squared_to(_retriever.global_position)
	var current_distance := current_position.distance_squared_to(_retriever.global_position)
	if not is_equal_approx(candidate_distance, current_distance):
		return candidate_distance < current_distance
	var candidate_kind := candidate.get(&"kind", &"") as StringName
	var current_kind := current.get(&"kind", &"") as StringName
	if candidate_kind == &"ground" and current_kind == &"ground":
		return int(candidate.get(&"uid", 0)) < int(current.get(&"uid", 0))
	return "%s:%s" % [candidate_kind, candidate.get(&"source_id", &"")] < "%s:%s" % [current_kind, current.get(&"source_id", &"")]


func _d_source_area(source_id: StringName) -> Area3D:
	if _zone_d == null:
		return null
	var node_name := "CargoD" if source_id == SOURCE_CARGO_D else "TaxStampD"
	return _zone_d.get_node_or_null("%s/InteractArea" % node_name) as Area3D


func _d_cache(source_id: StringName) -> LootCache:
	if source_id == SOURCE_CARGO_D:
		return _cargo_cache
	if source_id == SOURCE_TAX_STAMP_D:
		return _stamp_cache
	return null


func _set_d_source_visible(source_id: StringName, visible: bool) -> void:
	if _zone_d == null:
		return
	var node_name := "CargoD" if source_id == SOURCE_CARGO_D else "TaxStampD"
	var item_block := _zone_d.get_node_or_null("%s/ItemBlock" % node_name) as StaticBody3D
	if item_block == null:
		return
	item_block.visible = visible
	item_block.collision_layer = 2 if visible else 0
	var collision := item_block.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision != null:
		collision.set_deferred(&"disabled", not visible)


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
	if summary.run_kind == &"recovery":
		RunSession.complete_recovery_run()


func _on_retriever_depleted() -> void:
	if flow == null or flow.extract_state in [ExtractPierAFlow.ExtractState.S10_SUCCESS, ExtractPierAFlow.ExtractState.ENDED_DEATH]:
		return
	flow.notify_death()
	if _hold_director != null:
		_hold_director.on_run_ended()
	if _patrol_director != null:
		_patrol_director.stop()
	for enemy: EnemyActor in [_guard, _foreman, _patrol]:
		_deactivate_combat_actor(enemy)
	_close_overlay(false)
	_hud.visible = false
	_combat_hud.visible = false
	_set_retriever_overlay_open(true)
	_present_recall_sigil()


func _present_recall_sigil() -> void:
	var recall := RECALL_SIGIL_SCENE.instantiate() as RecallSigilOverlay
	recall.completed.connect(_show_death_summary, CONNECT_ONE_SHOT)
	_present_overlay(recall)


func _show_death_summary() -> void:
	var summary := flow.resolve_death_summary()
	if summary == null:
		return
	if _overlay != null:
		_overlay.queue_free()
		_overlay = null
	var screen := DEATH_SUMMARY_SCENE.instantiate() as DeathSummaryScreen
	_present_overlay(screen)
	screen.show_summary(summary, RunSession.inventory.registry)
	screen.prepare_requested.connect(_return_to_briefing)
	screen.recovery_requested.connect(_open_recovery_contract)


func _open_recovery_contract(summary: DeathSummary) -> void:
	if not RunSession.prepare_recovery_briefing(summary):
		return
	if _overlay != null:
		_overlay.queue_free()
		_overlay = null
	var screen := RECOVERY_CONTRACT_SCENE.instantiate() as RecoveryContractScreen
	_present_overlay(screen)
	screen.briefing_requested.connect(_enter_recovery_briefing)


func _enter_recovery_briefing() -> void:
	var result := get_tree().change_scene_to_file("res://src/flow/briefing_flow.tscn")
	if result != OK and _overlay is RecoveryContractScreen:
		(_overlay as RecoveryContractScreen).get_node("BriefingButton").disabled = false


func _return_to_briefing() -> void:
	RunSession.clear()
	var result := get_tree().change_scene_to_file("res://src/flow/briefing_flow.tscn")
	if result != OK and _overlay is DeathSummaryScreen:
		(_overlay as DeathSummaryScreen).show_scene_load_error()


func _return_to_boot() -> void:
	RunSession.clear()
	var result := get_tree().change_scene_to_file(BOOT_SCENE)
	if result != OK and _overlay is ExtractSummaryScreen:
		(_overlay as ExtractSummaryScreen).show_scene_load_error()


func _on_desk_state_changed(state: int) -> void:
	if _manifest_placeholder != null:
		_manifest_placeholder.visible = state == ExtractPierAFlow.DeskState.HAS_MANIFEST
	_hud.refresh()


func _dispatch_manifest_available() -> bool:
	return flow.can_recover_manifest() or flow.contract_state == ExtractPierAFlow.ContractState.NOT_TAKEN


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


func _on_zone_d_calm_body_entered(body: Node3D) -> void:
	if body == _retriever:
		set_zone_d_calm_in_range(true)


func _on_zone_d_calm_body_exited(body: Node3D) -> void:
	if body == _retriever:
		set_zone_d_calm_in_range(false)


func _on_d_source_body_entered(body: Node3D, source_id: StringName) -> void:
	if body == _retriever:
		_d_source_in_range[source_id] = true
		_refresh_route_ui()


func _on_d_source_body_exited(body: Node3D, source_id: StringName) -> void:
	if body == _retriever:
		_d_source_in_range[source_id] = false
		var panel := _overlay as LootCachePanel
		if panel != null and panel.is_source_bound() and not panel.has_pending_confirmation():
			_close_overlay()
		_refresh_route_ui()


func _on_patrol_trigger_body_entered(body: Node3D) -> void:
	if body == _retriever and _calm_visited and not _patrol_started:
		_start_patrol_return()


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
	_zone_b.call(&"set_route_d_open", true)
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
	elif flow != null and flow.contract_state == ExtractPierAFlow.ContractState.DROPPED:
		key = &"HUD_OBJECTIVE_PICK_UP_MANIFEST"
	var objective := _hud.get_node_or_null("ObjectivePanel/Objective") as Label
	if objective != null:
		objective.text = tr(key)
	_combat_hud.set_objective(key)
	var active_context := _active_context_target()
	if _cache_button != null:
		_cache_button.visible = active_context.get(&"kind", &"") == &"cache" and _overlay == null
	if _cargo_button != null:
		_cargo_button.visible = active_context.get(&"kind", &"") == &"source" and active_context.get(&"source_id", &"") == SOURCE_CARGO_D and _overlay == null
	if _stamp_button != null:
		_stamp_button.visible = active_context.get(&"kind", &"") == &"source" and active_context.get(&"source_id", &"") == SOURCE_TAX_STAMP_D and _overlay == null
	if _ground_button != null:
		_ground_button.visible = active_context.get(&"kind", &"") == &"ground" and _overlay == null


func _is_near(path: String, radius: float) -> bool:
	var anchor := _world.get_node_or_null(path) as Node3D
	return anchor != null and _retriever != null and DispatchInteraction.is_in_range(_retriever.global_position, anchor.global_position, radius)
