extends RefCounted


class FakeEnemy:
	extends RefCounted

	var position := Vector3.ZERO
	var received: Array[HitInfo] = []
	var combat_state: StringName = &"idle"

	func get_team() -> StringName:
		return RetrieverCombat.TEAM_ENEMY

	func get_combat_position() -> Vector3:
		return position

	func get_combat_state() -> StringName:
		return combat_state

	func receive_hit(hit: HitInfo) -> HitResult:
		received.append(hit)
		return HitResult.new(hit.damage)


func _inventory(with_remedy: bool = false) -> RetrieverInventory:
	var registry := ItemRegistry.new()
	registry.add(SlingRemedyDefinition.new())
	registry.add(_definition(&"starter_remedy"))
	var inventory := RetrieverInventory.new(registry)
	if with_remedy:
		inventory.load_snapshot({"backpack": [], "notary_box": [], "sling_pouch": [{"uid": 1, "def_id": &"sling_remedy", "quantity": 1, "anchor": Vector2i.ZERO, "rotated": false}]})
	return inventory


func _definition(id: StringName) -> ItemDef:
	var definition := ItemDef.new()
	definition.id = id
	definition.size = Vector2i.ONE
	definition.item_category = ItemDef.Category.CONSUMABLE
	definition.sealable = true
	return definition


func _combat(inventory: RetrieverInventory = null) -> RetrieverCombat:
	var combat := RetrieverCombat.new(null, inventory)
	combat.facing = Vector3.FORWARD
	return combat


func test_health_damage_heal_clamp_and_depleted_once(t) -> bool:
	var health := Health.new(100)
	var changes: Array = []
	var depleted: Array = []
	health.changed.connect(func(hp: int, max_hp: int) -> void: changes.append([hp, max_hp]))
	health.depleted.connect(func() -> void: depleted.append(true))
	t.eq(health.damage(30), 30, "damage returns applied amount")
	t.eq(health.hp, 70, "damage changes HP")
	t.eq(health.heal(40), 30, "heal clamps to max")
	t.eq(health.hp, 100, "heal reaches max")
	t.eq(health.damage(100), 100, "lethal hit applies remaining HP")
	t.eq(health.damage(5), 0, "damage after depletion is ignored")
	t.eq(health.heal(5), 0, "heal never revives")
	t.eq(depleted.size(), 1, "depleted emits once")
	t.eq(changes.size(), 3, "only state changes emit")
	return true


func test_attack_assist_hits_once_and_ignores_enemy_behind(t) -> bool:
	var combat := _combat()
	var front := FakeEnemy.new()
	front.position = Vector3(0.0, 0.0, -1.2)
	var behind := FakeEnemy.new()
	behind.position = Vector3(0.0, 0.0, 1.2)
	combat.set_targets([front, behind])
	combat.press(&"combat_attack")
	combat.tick(0.10)
	combat.tick(0.10)
	t.eq(front.received.size(), 1, "front target receives one active-frame hit")
	t.eq(front.received[0].damage, 20, "attack uses tuning damage")
	t.eq(behind.received.size(), 0, "target behind the attack arc is not hit")
	combat.tick(0.10)
	combat.tick(0.10)
	combat.tick(0.10)
	t.eq(combat.state, RetrieverCombat.STATE_FREE, "attack returns to free after recover")
	return true


func test_dodge_iframe_guard_arc_and_chip_damage(t) -> bool:
	var combat := _combat()
	combat.set_move_input(Vector2.RIGHT)
	combat.set_move_direction(Vector3.RIGHT)
	combat.press(&"combat_dodge")
	combat.tick(0.10)
	var iframe := combat.receive_hit(HitInfo.new(4, &"foreman_charge", 30, Vector3(-1.0, 0.0, 0.0)))
	t.eq(iframe.ignored_reason, &"iframe", "dodge ignores hits during iframe")
	t.eq(combat.health.hp, 100, "iframe preserves HP")
	combat.tick(0.10)
	combat.tick(0.10)
	t.ok(absf(combat.position.x - 3.0) < 0.05, "dodge moves the configured distance")
	combat.press(&"combat_guard")
	t.eq(combat.state, RetrieverCombat.STATE_GUARDING, "guard press enters guarding")
	combat.tick(0.10)
	combat.tick(0.05)
	combat.facing = Vector3.FORWARD
	var front_origin := combat.position + Vector3.FORWARD
	var blocked := combat.receive_hit(HitInfo.new(4, &"guard_strike", 15, front_origin))
	t.ok(blocked.blocked, "guard blocks an attack from the front")
	t.eq(blocked.applied, 0, "tax guard strike has no chip damage")
	var knockbacks: Array[Vector3] = []
	combat.knockback_requested.connect(func(displacement: Vector3) -> void: knockbacks.append(displacement))
	var chip := combat.receive_hit(HitInfo.new(4, &"foreman_charge", 30, front_origin, Vector3.FORWARD, 1.5))
	t.ok(chip.blocked, "foreman charge is blockable")
	t.eq(chip.applied, 9, "foreman charge uses 30 percent chip")
	t.eq(knockbacks, [Vector3(0.0, 0.0, -1.5)], "blocked charge requests 1.5 m along charge direction")
	combat.tick(0.05)
	t.ok(absf(combat.position.z + 1.5) < 0.001, "blocked charge applies its displacement through combat motion")
	combat.press(&"combat_dodge")
	t.eq(combat.state, RetrieverCombat.STATE_GUARDING, "dodge remains on cooldown after it ends")
	for step in 8:
		combat.tick(0.10)
	combat.press(&"combat_dodge")
	t.eq(combat.state, RetrieverCombat.STATE_DODGING, "dodge is usable after its cooldown")
	var rear_combat := _combat()
	rear_combat.press(&"combat_guard")
	rear_combat.tick(0.10)
	var rear := rear_combat.receive_hit(HitInfo.new(4, &"guard_strike", 15, Vector3.BACK))
	t.ok(not rear.blocked, "guard does not block an attack from behind")
	t.eq(rear.applied, 15, "rear hit deals full damage")
	return true


func test_post_hit_blocks_repeat_and_remedy_consumes_after_channel(t) -> bool:
	var inventory := _inventory(true)
	var combat := _combat(inventory)
	combat.health.damage(50)
	var removed: Array = []
	inventory.item_removed.connect(func(_uid: int, location: StringName) -> void:
		if location == RetrieverInventory.SLING_POUCH:
			removed.append(true)
	)
	combat.press(&"use_remedy")
	t.eq(combat.state, RetrieverCombat.STATE_USING_REMEDY, "remedy starts its channel")
	for step in 10:
		combat.tick(0.10)
	t.eq(combat.health.hp, 90, "remedy heals after its full channel")
	t.ok(inventory.sling_pouch.items.is_empty(), "remedy is consumed from the sling pouch")
	t.eq(removed.size(), 1, "consuming final remedy emits one removal")
	var first := combat.receive_hit(HitInfo.new(5, &"guard_strike", 15, Vector3(0.0, 0.0, -1.0)))
	var repeated := combat.receive_hit(HitInfo.new(6, &"guard_strike", 15, Vector3(0.0, 0.0, -1.0)))
	t.eq(first.applied, 15, "first real hit applies damage")
	t.eq(repeated.ignored_reason, &"post_hit", "post-hit invulnerability rejects repeat hits")
	return true


func test_remedy_refuses_empty_or_full_without_mutating_inventory(t) -> bool:
	var empty := _combat(_inventory(false))
	var empty_reason: Array[StringName] = []
	empty.remedy_refused.connect(func(reason: StringName) -> void: empty_reason.append(reason))
	empty.press(&"use_remedy")
	t.eq(empty.state, RetrieverCombat.STATE_FREE, "empty remedy leaves combat free")
	t.eq(empty_reason, [&"no_remedy"], "empty pouch refuses remedy")
	var full_inventory := _inventory(true)
	var full := _combat(full_inventory)
	var full_reason: Array[StringName] = []
	full.remedy_refused.connect(func(reason: StringName) -> void: full_reason.append(reason))
	full.press(&"use_remedy")
	t.eq(full_reason, [&"hp_full"], "full HP refuses remedy")
	t.ok(full_inventory.sling_pouch.items.has(1), "failed remedy leaves item in pouch")
	return true


func test_overlay_lowers_guard_and_ignores_combat_actions(t) -> bool:
	var combat := _combat()
	combat.press(&"combat_guard")
	combat.tick(0.10)
	combat.set_overlay_open(true)
	t.eq(combat.state, RetrieverCombat.STATE_FREE, "opening an overlay lowers guard")
	combat.press(&"combat_guard")
	combat.press(&"combat_attack")
	t.eq(combat.state, RetrieverCombat.STATE_FREE, "overlay ignores held and tap combat actions")
	combat.set_overlay_open(false)
	combat.press(&"combat_dodge")
	for step in 3:
		combat.tick(0.10)
	t.eq(combat.state, RetrieverCombat.STATE_FREE, "ignored guard does not re-raise after dodge")
	return true


func test_attack_buffer_only_accepts_the_final_window(t) -> bool:
	var combat := _combat()
	combat.press(&"combat_attack")
	combat.tick(0.10)
	combat.press(&"combat_dodge")
	for step in 4:
		combat.tick(0.10)
	t.eq(combat.state, RetrieverCombat.STATE_FREE, "early dodge input is discarded instead of buffering")
	combat.press(&"combat_attack")
	for step in 4:
		combat.tick(0.10)
	combat.press(&"combat_attack")
	combat.tick(0.10)
	t.eq(combat.state, RetrieverCombat.STATE_ATTACKING, "late attack input starts when the current action ends")
	return true


func test_guard_tracks_only_nearby_hostiles_in_active_combat_states(t) -> bool:
	var combat := _combat()
	var alert_enemy := FakeEnemy.new()
	alert_enemy.position = Vector3.RIGHT * 2.0
	alert_enemy.combat_state = &"alert"
	var idle_enemy := FakeEnemy.new()
	idle_enemy.position = Vector3.LEFT
	idle_enemy.combat_state = &"idle"
	combat.set_targets([idle_enemy, alert_enemy])
	combat.press(&"combat_guard")
	combat.tick(0.10)
	t.ok(combat.facing.x > 0.58 and combat.facing.z < -0.80, "guard turns toward the nearest alert hostile at 360 degrees per second")
	var no_track := _combat()
	no_track.set_targets([idle_enemy])
	no_track.press(&"combat_guard")
	no_track.tick(0.10)
	t.eq(no_track.facing, Vector3.FORWARD, "idle hostile does not change guard facing")
	return true
