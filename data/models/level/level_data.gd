class_name LevelData
extends ThingData

@export var chapter:int
@export var plants:Array[PlantData]
@export var weathers:Array[WeatherData]
@export var number_of_days:int

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_level: LevelData = other as LevelData
	chapter = other_level.chapter
	plants = other_level.plants.duplicate()
	weathers = other_level.weathers.duplicate()
	number_of_days = other_level.number_of_days

func get_duplicate() -> LevelData:
	var dup:LevelData = LevelData.new()
	dup.copy(self)
	return dup
