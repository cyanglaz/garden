class_name GUIPlantDeckBox
extends PanelContainer

enum Type {
	DRAW,
	DISCARD,
}

const PLANT_ICON_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_icon.tscn")

@export var type:Type

@onready var _next_container: VBoxContainer = %NextContainer
@onready var _gui_plant_icon: GUIPlantIcon = %GUIPlantIcon

func bind_deck(deck:Deck) -> void:
	match type:
		Type.DRAW:
			_on_pool_updated(deck.draw_pool)
			deck.draw_pool_updated.connect(_on_pool_updated)
		Type.DISCARD:
			_on_pool_updated(deck.discard_pool)
			deck.discard_pool_updated.connect(_on_pool_updated)
			_next_container.hide()

func _on_pool_updated(pool:Array) -> void:
	if pool.is_empty():
		_gui_plant_icon.update_with_plant_data(null)
	else:
		_gui_plant_icon.update_with_plant_data(pool[0])
	Util.remove_all_children(_next_container)
	for item in pool.slice(1, pool.size() - 1):
		var gui_plant_icon:GUIPlantIcon = PLANT_ICON_SCENE.instantiate()
		_next_container.add_child(gui_plant_icon)
		gui_plant_icon.update_with_plant_data(item)
		gui_plant_icon.custom_minimum_size = _gui_plant_icon.custom_minimum_size * 0.8
		gui_plant_icon.size = gui_plant_icon.custom_minimum_size
