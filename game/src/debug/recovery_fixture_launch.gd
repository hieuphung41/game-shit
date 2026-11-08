class_name RecoveryFixtureLaunch
extends Node
## Applies a fixture only after the real OuterPierRun has created its world.

const OUTER_PIER_RUN_SCENE := "res://src/flow/outer_pier_run.tscn"

var fixture_id: StringName


func launch(next_fixture_id: StringName) -> void:
	fixture_id = next_fixture_id
	RunSession.clear()
	RunSession.begin_briefing()
	get_tree().change_scene_to_file(OUTER_PIER_RUN_SCENE)
	call_deferred("_apply_after_run_ready")


func _apply_after_run_ready() -> void:
	for _frame in 8:
		await get_tree().process_frame
		var run := get_tree().current_scene as OuterPierRun
		if run == null or run.flow == null:
			continue
		RunSession.debug_fixture_id = fixture_id
		match fixture_id:
			&"c1": await _apply_c1(run)
			&"c2": pass
			&"c3": _apply_c3(run)
		queue_free()
		return
	push_error("RecoveryFixtureLaunch: OuterPierRun was not ready")
	queue_free()


func _apply_c1(run: OuterPierRun) -> void:
	RunSession.inventory.commit_pickup(RunSession.ground_manifest, RetrieverInventory.BACKPACK, Vector2i.ZERO, false)
	var beacon := run.get_node_or_null("ZoneAOuterPier/BeaconZoneA") as ProximityZone3D
	var retriever := run.get_node_or_null("ZoneAOuterPier/Retriever") as Node3D
	if beacon != null and retriever != null:
		retriever.global_position = beacon.global_position
		await get_tree().physics_frame
		beacon.retriever_entered.emit()


func _apply_c3(run: OuterPierRun) -> void:
	RunSession.inventory.commit_pickup(RunSession.ground_manifest, RetrieverInventory.NOTARY_BOX, Vector2i(1, 0), false)
	var cargo := ItemInstance.new(201, RunSession.inventory.registry.get_def(&"cargo_d_2x2"))
	RunSession.inventory.commit_pickup(cargo, RetrieverInventory.BACKPACK, Vector2i.ZERO, false)
	var guard_post := run.get_node_or_null("ZoneAOuterPier/ZoneBFloodedMarket/GuardPost") as Node3D
	var retriever := run.get_node_or_null("ZoneAOuterPier/Retriever") as Node3D
	if guard_post != null and retriever != null:
		retriever.global_position = guard_post.global_position
