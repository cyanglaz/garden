class_name GUIPlantCardContainer
extends PanelContainer

const PLANT_CARD_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_card.tscn")

@onready var _card_container: VBoxContainer = %CardContainer

func update_with_plant_datas(plant_datas:Array[PlantData]) -> void:
	Util.remove_all_children(_card_container)
	for plant_data:PlantData in plant_datas:
		var card:GUIPlantCard = PLANT_CARD_SCENE.instantiate()
		_card_container.add_child(card)
		card.update_with_plant_data(plant_data)
