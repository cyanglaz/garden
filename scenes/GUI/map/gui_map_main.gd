class_name GUIMapMain
extends Control

@onready var gui_map_view: GUIMapView = %GUIMapView

var map_generator = MapGenerator.new()

func _ready() -> void:
	randomize()
	var s := randi()
	print(s)
	map_generator.generate(s)
	map_generator.log()
	update_with_map(map_generator.layers)

func update_with_map(layers:Array) -> void:
	gui_map_view.update_with_map(layers)
