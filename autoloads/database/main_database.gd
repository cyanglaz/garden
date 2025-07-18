extends Node

#var item_database:ItemDatabase = ItemDatabase.new()
var weather_database:WeatherDatabase = WeatherDatabase.new()
var field_status_database:FieldStatusDatabase = FieldStatusDatabase.new()
var plant_database:PlantDatabase = PlantDatabase.new()

func _ready() -> void:
	#add_child(item_database)
	add_child(weather_database)
	add_child(field_status_database)
	add_child(plant_database)
