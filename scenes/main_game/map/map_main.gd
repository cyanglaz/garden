class_name MapMain
extends Node2D

@onready var gui: GUIMapMain = %GUIMapMain

func update_with_map(layers:Array) -> void:
	gui.update_with_map(layers)
