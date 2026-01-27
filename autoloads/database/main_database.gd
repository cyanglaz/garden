extends Node

#var item_database:ItemDatabase = ItemDatabase.new()
var weather_database:WeatherDatabase = WeatherDatabase.new()
var field_status_database:FieldStatusDatabase = FieldStatusDatabase.new()
var plant_database:PlantDatabase = PlantDatabase.new()
var tool_database:ToolDatabase = ToolDatabase.new()
var power_database:PowerDatabase = PowerDatabase.new()
var plant_ability_database:PlantAbilityDatabase = PlantAbilityDatabase.new()
var combat_database:CombatDatabase = CombatDatabase.new()
var player_status_database:PlayerStatusDatabase = PlayerStatusDatabase.new()

func _ready() -> void:
	#add_child(item_database)
	add_child(weather_database)
	add_child(field_status_database)
	add_child(plant_database)
	add_child(tool_database)
	add_child(power_database)
	add_child(plant_ability_database)
	add_child(combat_database)
	add_child(player_status_database)
