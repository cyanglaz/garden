class_name GUIDemoEndMain
extends Control

@onready var _gui_demo_end_container: GUIDemoEndContainer = %GUIDemoEndContainer

func animate_show() -> void:
	PauseManager.try_pause()
	show()
	_gui_demo_end_container.animate_show()
