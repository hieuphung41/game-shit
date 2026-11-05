extends RefCounted

const AppEnvScript := preload("res://src/autoload/app_env.gd")


func test_channel_from_features(t) -> bool:
	t.eq(AppEnvScript.channel_from_features(PackedStringArray()), "dev", "no tag → dev")
	t.eq(AppEnvScript.channel_from_features(PackedStringArray(["staging"])), "staging", "staging tag")
	t.eq(AppEnvScript.channel_from_features(PackedStringArray(["production"])), "production", "production tag")
	t.eq(AppEnvScript.channel_from_features(PackedStringArray(["staging", "production"])), "production", "production wins")
	return true


func test_every_channel_config_loads(t) -> bool:
	for channel in AppEnvScript.CHANNELS:
		var env: Node = AppEnvScript.new()
		t.eq(env.load_for(channel), OK, "load %s" % channel)
		t.ok(str(env.get_flag("save", "namespace", "")) != "", "%s has a save namespace" % channel)
		env.free()
	return true


func test_production_hides_debug_tools(t) -> bool:
	var env: Node = AppEnvScript.new()
	env.load_for("production")
	t.eq(env.get_flag("app", "debug_menu", true), false, "debug_menu off")
	t.eq(env.get_flag("app", "show_env_badge", true), false, "env badge off")
	t.ok(env.label().begins_with("v"), "production label is plain version")
	env.free()
	return true


func test_save_namespaces_are_distinct(t) -> bool:
	var seen := {}
	for channel in AppEnvScript.CHANNELS:
		var env: Node = AppEnvScript.new()
		env.load_for(channel)
		var dir: String = env.save_dir()
		t.ok(not seen.has(dir), "%s save dir %s unique" % [channel, dir])
		seen[dir] = true
		env.free()
	return true


func test_unknown_channel_falls_back_to_dev(t) -> bool:
	var env: Node = AppEnvScript.new()
	env.load_for("qa")
	t.eq(env.channel, "dev", "fallback channel")
	env.free()
	return true
