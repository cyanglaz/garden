extends Node

const SETTING_FILE = "user://USERSETTING.tres"
var DEFAULT_SETTING_RES = load("res://data/settings/default_settings.tres")

func get_default_setting() -> SettingData:
	return DEFAULT_SETTING_RES.duplicate()
	
func save_settings(setting_data:SettingData) -> void:
	_save_data(setting_data)
	
func load_settings() -> SettingData:
	if not FileAccess.file_exists(SETTING_FILE):
		return get_default_setting()
	return ResourceLoader.load(SETTING_FILE).duplicate() as SettingData

func _save_data(setting_data:SettingData) -> void:
	assert(setting_data != null)
	setting_data.take_over_path(SETTING_FILE)
	var error = ResourceSaver.save(setting_data, SETTING_FILE)
	if error != OK:
		push_error("Failed to save user settings to %s. Error code: %d" % [SETTING_FILE, error])
