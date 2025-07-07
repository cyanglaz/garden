class_name GUIPlantCardContainer
extends PanelContainer

signal plant_selected(index:int)

const PLANT_CARD_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_card.tscn")

@onready var _card_container: VBoxContainer = %CardContainer

func toggle_all_plant_cards(on:bool) -> void:
	for card:GUIPlantCard in _card_container.get_children():
		card.toggle_button(on)

func update_with_plant_datas(plant_datas:Array[PlantData]) -> void:
	Util.remove_all_children(_card_container)
	var index := 0
	for plant_data:PlantData in plant_datas:
		var card:GUIPlantCard = PLANT_CARD_SCENE.instantiate()
		_card_container.add_child(card)
		card.update_with_plant_data(plant_data)
		card.plant_button_action_evoked.connect(func(): plant_selected.emit(index))
		index += 1
