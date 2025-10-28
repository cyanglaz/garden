class_name TavernMain
extends Node2D

signal tavern_finished()

@onready var gui_tavern_main: GUITavernMain = %GUITavernMain

func _ready() -> void:
	gui_tavern_main.tavern_finished.connect(_on_tavern_finished)

func animate_show() -> void:
	gui_tavern_main.animate_show()

func _on_tavern_finished() -> void:
	tavern_finished.emit()
