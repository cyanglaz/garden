class_name GUIGameOverMain
extends Control

@onready var _gui_game_over_container: GUIGameOverContainer = %GUIGameOverContainer

func animate_show() -> void:
	PauseManager.try_pause()
	show()
	_gui_game_over_container.animate_show()
