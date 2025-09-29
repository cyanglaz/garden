class_name BossData
extends ThingData

const LEVEL_SCRIPT_PATH := "res://scenes/main_game/contract/boss_scripts/boss_script_%s.gd"

var boss_script:BossScript: get = _get_boss_script

func _get_boss_script() -> BossScript:
	var script_path := LEVEL_SCRIPT_PATH % [id]
	if ResourceLoader.exists(script_path):
		var ls:BossScript = load(script_path).new()
		ls.boss_data = self
		return ls
	else:
		return null
