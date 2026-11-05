extends Node
## Build channel and per-environment configuration.
##
## The channel comes from the export preset's custom feature tag:
## "staging" (deployed from main) or "production" (tagged release).
## Editor and other unexported runs are "dev".
## Config lives in res://config/env/<channel>.cfg; CI writes build metadata
## to res://config/build_info.cfg (absent locally).

const CHANNELS: PackedStringArray = ["dev", "staging", "production"]
const ENV_DIR := "res://config/env"
const BUILD_INFO_PATH := "res://config/build_info.cfg"

var channel: String = "dev"
var version: String = "0.0.0"
var commit: String = "local"
var built_at: String = ""

var _config := ConfigFile.new()


func _ready() -> void:
	load_for(channel_from_features(_active_features()))


## Pure mapping from feature tags to a channel; production wins over staging.
static func channel_from_features(features: PackedStringArray) -> String:
	if features.has("production"):
		return "production"
	if features.has("staging"):
		return "staging"
	return "dev"


## Loads the config for [param new_channel]. Unknown channels fall back to "dev".
func load_for(new_channel: String) -> Error:
	if not CHANNELS.has(new_channel):
		push_error("AppEnv: unknown channel '%s', using dev" % new_channel)
		new_channel = "dev"
	channel = new_channel
	_config = ConfigFile.new()
	var err := _config.load("%s/%s.cfg" % [ENV_DIR, channel])
	if err != OK:
		push_error("AppEnv: cannot load %s/%s.cfg (error %d)" % [ENV_DIR, channel, err])
	version = str(ProjectSettings.get_setting("application/config/version", "0.0.0"))
	var info := ConfigFile.new()
	if info.load(BUILD_INFO_PATH) == OK:
		version = str(info.get_value("build", "version", version))
		commit = str(info.get_value("build", "commit", commit))
		built_at = str(info.get_value("build", "built_at", built_at))
	return err


func get_flag(section: String, key: String, fallback: Variant = null) -> Variant:
	return _config.get_value(section, key, fallback)


func is_production() -> bool:
	return channel == "production"


## Saves are namespaced per channel so staging and production never share a slot.
func save_dir() -> String:
	return "user://%s" % str(get_flag("save", "namespace", channel))


func label() -> String:
	if is_production():
		return "v%s" % version
	return "%s v%s (%s)" % [channel.to_upper(), version, commit.left(7)]


func _active_features() -> PackedStringArray:
	var out := PackedStringArray()
	for tag in ["production", "staging"]:
		if OS.has_feature(tag):
			out.append(tag)
	return out
