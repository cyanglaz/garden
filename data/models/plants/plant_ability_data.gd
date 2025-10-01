class_name PlantAbilityData
extends ThingData

enum AbilityType {
	HARVEST,
	END_DAY,
	LIGHT_GAIN,
	WEATHER,
}


const PLANT_ABILITY_SCRIPT_PATH := "res://scenes/main_game/plants/abilities/plant_ability_%s.tscn"
const PLANT_ABILITY_ICON_PREFIX := "res://resources/sprites/GUI/icons/plants/abilities/icon_"

var icon:Texture2D: get = _get_icon_path
var _icon:Texture2D

func get_duplicate() -> PlantAbilityData:
	var dup:PlantAbilityData = PlantAbilityData.new()
	dup.copy(self)
	return dup

func get_ability() -> PlantAbility:
	var scene_path := PLANT_ABILITY_SCRIPT_PATH % [id]
	if ResourceLoader.exists(scene_path):
		return load(scene_path).instantiate()
	else:
		return null
	
func _get_icon_path() -> Texture2D:
	if _icon:
		return _icon
	var icon_path := str(PLANT_ABILITY_ICON_PREFIX, id, ".png")
	if ResourceLoader.exists(icon_path):
		_icon = load(icon_path)
		return _icon
	return null
