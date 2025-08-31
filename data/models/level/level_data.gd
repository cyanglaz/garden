class_name LevelData
extends ThingData

const ICON_PATH_PREFIX := "res://resources/sprites/icons/characters/icon_"

enum Type {
	MINION,
	BOSS
}

@export var type:Type
@export var appearance:Array[String]
@export var plants:Array[PlantData]
@export var shuffle_plants:bool = false
@export var weathers:Array[WeatherData]
@export var number_of_days:int

var portrait_icon:Texture2D: get = _get_portrait_icon

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_level: LevelData = other as LevelData
	type = other_level.type
	appearance = other_level.appearance.duplicate()
	plants = other_level.plants.duplicate()
	shuffle_plants = other_level.shuffle_plants
	weathers = other_level.weathers.duplicate()
	number_of_days = other_level.number_of_days
	

func get_duplicate() -> LevelData:
	var dup:LevelData = LevelData.new()
	dup.copy(self)
	return dup

func _get_portrait_icon() -> Texture2D:
	if !ResourceLoader.exists(ICON_PATH_PREFIX + id + ".png"):
		return null
	return load(ICON_PATH_PREFIX + id + ".png")
