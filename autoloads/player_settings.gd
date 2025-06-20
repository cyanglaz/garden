extends Node

enum AudioBus {
	MASTER = 0,
	MUSIC = 1,
	SFX = 2,
}

signal setting_loaded()

var setting_data:SettingData

func _ready() -> void:
	load_setings_from_save()

func update_volume(bus:AudioBus, volume:float) -> void:
	# Mute bus if volume is less than -50
	# FIXIE: avoid the hard coded -50
	AudioServer.set_bus_mute(bus, volume <= Constants.MINIMUM_AUDIO)
	AudioServer.set_bus_volume_db(bus, volume)
	match bus:
		AudioBus.MASTER:
			setting_data.master_volume = volume
		AudioBus.MUSIC:
			setting_data.music_volume = volume
		AudioBus.SFX:
			setting_data.sfx_volume = volume
	Save.save_settings(setting_data)

func update_game_speed(game_speed:int) -> void:
	print_debug("update_game_speed: ", game_speed)
	setting_data.game_speed = game_speed
	Save.save_settings(setting_data)
	
func load_setings_from_save() -> void:
	setting_data = Save.load_settings()
	_load_settings()
	
func load_default_settings() -> void:
	setting_data = Save.get_default_setting()
	_load_settings()
	
func get_setting_data() -> SettingData:
	return setting_data
	
func _load_settings():
	update_volume(AudioBus.MASTER, setting_data.master_volume)
	update_volume(AudioBus.MUSIC, setting_data.music_volume)
	update_volume(AudioBus.SFX, setting_data.sfx_volume)
	update_game_speed(setting_data.game_speed)
	setting_loaded.emit()
	# TODO: signal settings need to be initialized inside the receiving nodes.
	# 
	# Mouse sense, autoaim, bloom, brightness, fps display
	
