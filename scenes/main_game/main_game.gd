class_name MainGame
extends Node2D

@export var test_plant_datas:Array[PlantData]
@export var number_of_fields := 0

@onready var _field_container: FieldContainer = %FieldContainer
@onready var _gui_game_session: GUIMainGame = %GUIGameSession

func _ready() -> void:
	if !test_plant_datas.is_empty():
		_gui_game_session.update_with_plant_datas(test_plant_datas)
	_gui_game_session.plant_seed_deselected.connect(_on_plant_seed_deselected)
	_field_container.update_with_number_of_fields(number_of_fields)
	_field_container.field_hovered.connect(_on_field_hovered)
	_field_container.field_pressed.connect(_on_field_pressed)

func _on_field_hovered(hovered:bool, index:int) -> void:
	var selected_plant_seed_data:PlantData = _gui_game_session.selected_plant_seed_data
	if selected_plant_seed_data && !_field_container.is_field_occupied(index):
		_gui_game_session.toggle_following_plant_icon_visibility(!hovered)
		_field_container.toggle_plant_preview(hovered, selected_plant_seed_data, index)

func _on_plant_seed_deselected() -> void:
	_field_container.clear_previews()

func _on_field_pressed(index:int) -> void:
	var selected_plant_seed_data:PlantData = _gui_game_session.selected_plant_seed_data
	if selected_plant_seed_data && !_field_container.is_field_occupied(index):
		_gui_game_session._on_plant_seed_selected(null)
		_field_container.plant_seed(selected_plant_seed_data, index)
