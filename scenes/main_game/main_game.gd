class_name MainGame
extends Node2D

@export var test_plant_datas:Array[PlantData]

@onready var _field_container: FieldContainer = %FieldContainer
@onready var _gui_game_session: GUIMainGame = %GUIGameSession

func _ready() -> void:
	if !test_plant_datas.is_empty():
		_gui_game_session.update_with_plant_datas(test_plant_datas)
