class_name LevelData
extends ThingData

const ICON_PATH_PREFIX := "res://resources/sprites/icons/characters/icon_"
const LEVEL_SCRIPT_PATH := "res://scenes/main_game/levels/scripts/level_script_%s.gd"

enum Type {
	MINION,
	BOSS
}

signal finished()

@export var type:Type
@export var appearance:Array[String]
@export var plants:Array[PlantData]
@export var shuffle_plants:bool = false
@export var weathers:Array[WeatherData]
@export var number_of_days:int

var is_finished:bool = false: set = _set_is_finished
var portrait_icon:Texture2D: get = _get_portrait_icon
var level_script:LevelScript: get = _get_level_script

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_level: LevelData = other as LevelData
	type = other_level.type
	appearance = other_level.appearance.duplicate()
	plants = other_level.plants.duplicate()
	shuffle_plants = other_level.shuffle_plants
	weathers = other_level.weathers.duplicate()
	number_of_days = other_level.number_of_days
	is_finished = other_level.is_finished

func get_duplicate() -> LevelData:
	var dup:LevelData = LevelData.new()
	dup.copy(self)
	return dup

func _set_is_finished(value:bool) -> void:
	is_finished = value
	finished.emit()

func _get_portrait_icon() -> Texture2D:
	if !ResourceLoader.exists(ICON_PATH_PREFIX + id + ".png"):
		return null
	return load(ICON_PATH_PREFIX + id + ".png")

func _get_level_script() -> LevelScript:
	var script_path := LEVEL_SCRIPT_PATH % [id]
	if ResourceLoader.exists(script_path):
		var ls:LevelScript = load(script_path).new()
		ls.level_data = self
		return ls
	else:
		return null
