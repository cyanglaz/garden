extends Node

#var item_database:ItemDatabase = ItemDatabase.new()
var weather_database:WeatherDatabase = WeatherDatabase.new()

func _ready() -> void:
	#add_child(item_database)
	add_child(weather_database)
