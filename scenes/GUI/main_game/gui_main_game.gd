class_name GUIMainGame
extends CanvasLayer

@onready var _gui_weather: GUIWeather = %GUIWeather
@onready var _gui_plant_card_container: GUIPlantCardContainer = %GUIPlantCardContainer

func update_with_plant_datas(plant_datas:Array[PlantData]) -> void:
	_gui_plant_card_container.update_with_plant_datas(plant_datas)
