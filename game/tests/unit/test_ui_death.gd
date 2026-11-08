extends RefCounted

const DEATH_SCENE := preload("res://src/ui/death/death_summary_screen.tscn")
const RECALL_SCENE := preload("res://src/ui/death/recall_sigil_overlay.tscn")


func test_ui_death_after_manifest_has_three_groups_and_recovery_only(t) -> bool:
	var registry := _registry_with_cargo()
	var summary := DeathSummary.new()
	summary.kept = [{"uid": 1, "def_id": &"starter_remedy"}]
	summary.lost = [{"uid": 2, "def_id": &"cargo_d_2x2", "lost_reason": &"unsealed"}]
	summary.unrecovered_evidence = [&"manifest_r17"]
	summary.death_variant = &"after_manifest"
	var screen := DEATH_SCENE.instantiate() as DeathSummaryScreen
	screen.show_summary(summary, registry)
	var recovery_requests: Array[bool] = []
	var prepare_requests: Array[bool] = []
	screen.recovery_requested.connect(func(_recovery: DeathSummary) -> void: recovery_requests.append(true))
	screen.prepare_requested.connect(func() -> void: prepare_requests.append(true))
	t.tree.root.add_child(screen)
	await t.tree.process_frame
	t.ok(screen.get_node_or_null("KeptScroll") != null, "sealed items retain their column")
	t.ok(screen.get_node_or_null("LostScroll") != null, "lost items retain their column")
	t.ok(screen.get_node_or_null("EvidenceScroll") != null, "unrecovered evidence retains its column")
	t.eq((screen.get_node("EvidenceScroll/Content/Heading") as Label).text, tr("SUMMARY_DEATH_GROUP_EVIDENCE_UNRECOVERED"), "after-manifest header names unrecovered evidence")
	t.ok((screen.get_node("LostScroll/Content/Line1") as Label).text.contains(tr("ITEM_CARGO_D_2X2_NAME")), "cargo is lost rather than kept")
	t.ok((screen.get_node("EvidenceScroll/Content/Line1") as Label).text.contains(tr("CARD_MANIFEST_R17_NAME")), "Manifest appears only as unrecovered evidence")
	t.ok(screen.get_node_or_null("RecoveryLine") == null, "after-manifest does not show the retired recovery-unavailable copy")
	t.eq((screen.get_node("PrimaryButton") as Button).text, tr("SUMMARY_DEATH_BUTTON_RECOVERY"), "after-manifest has the Recovery Contract action")
	screen._elapsed_seconds = 2.0
	screen.request_primary()
	screen.request_primary()
	t.eq(recovery_requests.size(), 1, "Recovery request is emitted once")
	t.eq(prepare_requests.size(), 0, "after-manifest never requests a new run directly")
	screen.queue_free()
	await t.tree.process_frame
	return true


func test_ui_death_before_manifest_hides_empty_kept_and_prepares(t) -> bool:
	var registry := _registry_with_cargo()
	var summary := DeathSummary.new()
	summary.kept = []
	summary.lost = [{"uid": 2, "def_id": &"cargo_d_2x2", "lost_reason": &"left_behind"}]
	summary.death_variant = &"before_manifest"
	var screen := DEATH_SCENE.instantiate() as DeathSummaryScreen
	screen.show_summary(summary, registry)
	var prepare_requests: Array[bool] = []
	screen.prepare_requested.connect(func() -> void: prepare_requests.append(true))
	t.tree.root.add_child(screen)
	await t.tree.process_frame
	t.ok(screen.get_node_or_null("KeptScroll") == null, "empty kept group is absent")
	t.ok(screen.get_node_or_null("RecoveryLine") == null, "before-manifest never offers recovery copy")
	t.eq((screen.get_node("EvidenceScroll/Content/Heading") as Label).text, tr("SUMMARY_GROUP_EVIDENCE"), "before-manifest retains the evidence header")
	t.ok((screen.get_node("EvidenceScroll/Content/Line0") as Label).text.contains(tr("SUMMARY_DEATH_EVIDENCE_AT_DESK")), "desk state remains clear before Manifest")
	t.ok((screen.get_node("LostScroll/Content/Line0") as Label).text.contains(tr("SUMMARY_DEATH_LOST_LEFT_BEHIND")), "dropped item is classified separately")
	t.ok((screen.get_node("LostScroll/Content/Line2") as Label).text.contains(tr("SUMMARY_DEATH_LOST_EQUIPPED")), "equipped gear is always explained")
	t.eq((screen.get_node("PrimaryButton") as Button).text, tr("SUMMARY_DEATH_BUTTON_PREPARE"), "before-manifest has the retry action")
	screen._elapsed_seconds = 2.0
	screen.request_primary()
	t.eq(prepare_requests.size(), 1, "prepare request is emitted once")
	screen.queue_free()
	await t.tree.process_frame
	return true


func test_ui_death_builds_frame_without_preconfigured_model_and_recall_completes_once(t) -> bool:
	var screen := DEATH_SCENE.instantiate() as DeathSummaryScreen
	t.tree.root.add_child(screen)
	await t.tree.process_frame
	t.ok(screen.get_node_or_null("Title") != null, "S11 always builds its frame in ready")
	t.ok(screen.get_node_or_null("LostScroll") != null, "S11 has a loss column without injected data")
	screen.queue_free()
	await t.tree.process_frame
	var overlay := RECALL_SCENE.instantiate() as RecallSigilOverlay
	var completions: Array[bool] = []
	overlay.completed.connect(func() -> void: completions.append(true))
	t.tree.root.add_child(overlay)
	await t.tree.process_frame
	t.ok((overlay.get_node("Sigil/MomentLine") as Label).text == tr("RECALL_SIGIL_MOMENT_LINE"), "O7 uses its localization key")
	overlay.finish_now()
	overlay.finish_now()
	t.eq(completions.size(), 1, "O7 completion is emitted once")
	overlay.queue_free()
	await t.tree.process_frame
	return true


func test_ui_death_lock_and_recall_use_foreground_process_time(t) -> bool:
	var screen := DEATH_SCENE.instantiate() as DeathSummaryScreen
	var summary := DeathSummary.new()
	screen.show_summary(summary, _registry_with_cargo())
	var prepare_requests: Array[bool] = []
	screen.prepare_requested.connect(func() -> void: prepare_requests.append(true))
	t.tree.root.add_child(screen)
	await t.tree.process_frame
	screen._elapsed_seconds = 0.99
	screen.request_primary()
	t.eq(prepare_requests.size(), 0, "S11 remains locked before one foreground second")
	screen._notification(screen.NOTIFICATION_APPLICATION_FOCUS_OUT)
	screen._process(10.0)
	t.eq(screen._elapsed_seconds, 0.99, "S11 ignores a background catch-up delta")
	screen._notification(screen.NOTIFICATION_APPLICATION_FOCUS_IN)
	screen._elapsed_seconds = 1.0
	screen.request_primary()
	t.eq(prepare_requests.size(), 1, "S11 unlocks after one foreground second")
	screen.queue_free()
	await t.tree.process_frame
	var overlay := RECALL_SCENE.instantiate() as RecallSigilOverlay
	var completions: Array[bool] = []
	overlay.completed.connect(func() -> void: completions.append(true))
	t.tree.root.add_child(overlay)
	await t.tree.process_frame
	overlay._elapsed_seconds = 2.49
	overlay._process(0.0)
	t.eq(completions.size(), 0, "O7 does not complete without foreground process time")
	overlay._notification(overlay.NOTIFICATION_APPLICATION_FOCUS_OUT)
	overlay._process(10.0)
	t.eq(overlay._elapsed_seconds, 2.49, "O7 ignores a background catch-up delta")
	overlay._notification(overlay.NOTIFICATION_APPLICATION_FOCUS_IN)
	overlay._process(0.01)
	t.eq(completions.size(), 1, "O7 completes after its remaining foreground time")
	overlay.queue_free()
	await t.tree.process_frame
	return true


func test_ui_death_hides_short_scroll_cues_and_scrolls_focused_column(t) -> bool:
	var summary := DeathSummary.new()
	for index in 24:
		summary.lost.append({"uid": index, "def_id": &"cargo_d_2x2", "lost_reason": &"unsealed"})
	var screen := DEATH_SCENE.instantiate() as DeathSummaryScreen
	screen.show_summary(summary, _registry_with_cargo())
	t.tree.root.add_child(screen)
	await t.tree.process_frame
	await t.tree.process_frame
	var lost_scroll := screen.get_node("LostScroll") as ScrollContainer
	var lost_cue_frame := screen.get_node("LostScrollCueFrame") as PanelContainer
	var evidence_cue_frame := screen.get_node("EvidenceScrollCueFrame") as PanelContainer
	t.ok(lost_scroll.get_v_scroll_bar().max_value > 0.0, "long loss list overflows")
	t.ok(lost_cue_frame.visible, "long loss list shows a framed overflow cue before its scroll limit")
	t.ok(lost_cue_frame.get_node_or_null("Cue") is Label, "overflow cue has an arrow inside its frame")
	t.eq(evidence_cue_frame.visible, screen._scroll_overflows(screen.get_node("EvidenceScroll") as ScrollContainer), "scroll cue reflects actual evidence overflow")
	(screen.get_node("LostScrollFrame") as Control).grab_focus()
	var down := InputEventAction.new()
	down.action = &"ui_down"
	down.pressed = true
	t.tree.root.get_viewport().push_input(down)
	await t.tree.process_frame
	t.ok(lost_scroll.scroll_vertical > 0, "ui_down scrolls the focused loss column")
	screen.queue_free()
	await t.tree.process_frame
	return true


func test_ui_death_uses_the_specified_three_and_two_column_rectangles(t) -> bool:
	var three_column_summary := DeathSummary.new()
	three_column_summary.kept = [{"uid": 1, "def_id": &"starter_remedy"}]
	var three_column_screen := DEATH_SCENE.instantiate() as DeathSummaryScreen
	three_column_screen.show_summary(three_column_summary, _registry_with_cargo())
	t.tree.root.add_child(three_column_screen)
	await t.tree.process_frame
	t.eq((three_column_screen.get_node("KeptScrollFrame") as Control).get_global_rect(), Rect2(32, 112, 384, 432), "kept column uses the mandated S11 rectangle")
	t.eq((three_column_screen.get_node("LostScrollFrame") as Control).get_global_rect(), Rect2(448, 112, 384, 432), "lost column uses the mandated S11 rectangle")
	t.eq((three_column_screen.get_node("EvidenceScrollFrame") as Control).get_global_rect(), Rect2(864, 112, 384, 432), "evidence column uses the mandated S11 rectangle")
	three_column_screen.queue_free()
	await t.tree.process_frame
	var two_column_summary := DeathSummary.new()
	var two_column_screen := DEATH_SCENE.instantiate() as DeathSummaryScreen
	two_column_screen.show_summary(two_column_summary, _registry_with_cargo())
	t.tree.root.add_child(two_column_screen)
	await t.tree.process_frame
	t.eq((two_column_screen.get_node("LostScrollFrame") as Control).get_global_rect(), Rect2(32, 112, 592, 432), "empty kept state gives lost the mandated wide rectangle")
	t.eq((two_column_screen.get_node("EvidenceScrollFrame") as Control).get_global_rect(), Rect2(656, 112, 592, 432), "empty kept state gives evidence the mandated wide rectangle")
	two_column_screen.queue_free()
	await t.tree.process_frame
	return true


func test_ui_death_presents_loading_and_errors_inside_the_primary_button(t) -> bool:
	var before_summary := DeathSummary.new()
	before_summary.death_variant = &"before_manifest"
	var before_screen := DEATH_SCENE.instantiate() as DeathSummaryScreen
	before_screen.show_summary(before_summary, _registry_with_cargo())
	t.tree.root.add_child(before_screen)
	await t.tree.process_frame
	before_screen._elapsed_seconds = 1.0
	before_screen._process(0.0)
	var before_button := before_screen.get_node("PrimaryButton") as Button
	t.eq((before_button.get_node("ActionIcon") as Label).text, "↻", "prepare action replaces the lock with a retry icon")
	t.ok((before_button.get_node("ActionIcon") as Label).visible, "retry icon appears after the lock")
	before_screen.request_primary()
	t.eq((before_button.get_node("ActionStatus") as Label).text, tr("UI_LOADING"), "loading state is inside the primary button")
	t.ok((before_button.get_node("ActionStatus") as Label).visible, "loading state replaces the action icon")
	before_screen.show_scene_load_error()
	t.eq((before_button.get_node("ActionStatus") as Label).text, tr("UI_ERROR_SCENE_LOAD"), "scene error is inside the primary button")
	t.eq(before_button.text, "", "error state does not leave a second action label behind")
	t.ok(not (before_button.get_node("ActionIcon") as Label).visible, "scene error replaces the retry icon")
	before_screen.queue_free()
	await t.tree.process_frame
	var after_summary := DeathSummary.new()
	after_summary.death_variant = &"after_manifest"
	var after_screen := DEATH_SCENE.instantiate() as DeathSummaryScreen
	after_screen.show_summary(after_summary, _registry_with_cargo())
	t.tree.root.add_child(after_screen)
	await t.tree.process_frame
	after_screen._elapsed_seconds = 1.0
	after_screen._process(0.0)
	var after_button := after_screen.get_node("PrimaryButton") as Button
	t.eq((after_button.get_node("ActionIcon") as Label).text, "⇥", "Recovery action replaces the lock with a door icon")
	after_screen.show_scene_load_error()
	t.eq((after_button.get_node("ActionStatus") as Label).text, tr("UI_ERROR_SCENE_LOAD"), "Recovery scene error is also inside the primary button")
	after_screen.queue_free()
	await t.tree.process_frame
	return true


func _registry_with_cargo() -> ItemRegistry:
	var registry := ItemRegistry.new()
	var cargo := ItemDef.new()
	cargo.id = &"cargo_d_2x2"
	cargo.display_name_key = &"ITEM_CARGO_D_2X2_NAME"
	cargo.size = Vector2i(2, 2)
	registry.add(cargo)
	var remedy := ItemDef.new()
	remedy.id = &"starter_remedy"
	remedy.display_name_key = &"ITEM_STARTER_REMEDY_NAME"
	remedy.size = Vector2i(1, 2)
	registry.add(remedy)
	return registry
