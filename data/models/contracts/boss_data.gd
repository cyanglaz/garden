class_name BossData
extends ThingData

const LEVEL_SCRIPT_PATH := "res://scenes/main_game/contract/boss_scripts/boss_script_%s.gd"

@export var primary_plant_id:String

var boss_script:BossScript: get = _get_boss_script

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_boss: BossData = other as BossData
	primary_plant_id = other_boss.primary_plant_id

func get_duplicate() -> BossData:
	var dup:BossData = BossData.new()
	dup.copy(self)
	return dup

func _get_boss_script() -> BossScript:
	var script_path := LEVEL_SCRIPT_PATH % [id]
	if ResourceLoader.exists(script_path):
		var ls:BossScript = load(script_path).new()
		ls.boss_data = self
		return ls
	else:
		return null
