extends Node

#var item_database:ItemDatabase = ItemDatabase.new()
var weather_database:WeatherDatabase = WeatherDatabase.new()
var field_status_database:FieldStatusDatabase = FieldStatusDatabase.new()
var plant_database:PlantDatabase = PlantDatabase.new()
var tool_database:ToolDatabase = ToolDatabase.new()
var boss_database:BossDatabase = BossDatabase.new()
var power_database:PowerDatabase = PowerDatabase.new()
var plant_ability_database:PlantAbilityDatabase = PlantAbilityDatabase.new()

func _ready() -> void:
	#add_child(item_database)
	add_child(weather_database)
	add_child(field_status_database)
	add_child(plant_database)
	add_child(tool_database)
	add_child(boss_database)
	add_child(power_database)
	add_child(plant_ability_database)
