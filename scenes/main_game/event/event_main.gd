class_name EventMain
extends Node2D

signal event_finished()

@warning_ignore("unused_variable")
@export var test_event_data:EventData

@onready var gui_event_main: GUIEventMain = %GUIEventMain

func _ready() -> void:
	gui_event_main.event_finished.connect(_on_event_finished)
	#if test_event_data:
		#start(test_event_data, null)

func start(event_data:EventData, main_game:MainGame) -> void:
	gui_event_main.update_with_event(event_data, main_game)

func _on_event_finished() -> void:
	event_finished.emit()
