class_name TownMain
extends Node2D

signal town_finished()

@onready var gui_town_main: GUITownMain = %GUITownMain

func _ready() -> void:
	gui_town_main.town_finished.connect(_on_town_finished)

func animate_show() -> void:
	gui_town_main.animate_show()

func _on_town_finished() -> void:
	town_finished.emit()
