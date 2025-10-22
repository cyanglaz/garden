class_name GUIMapMain
extends Control

@onready var gui_map_view: GUIMapView = %GUIMapView
@onready var gui_rich_text_button: GUIRichTextButton = %GUIRichTextButton

var map_generator = MapGenerator.new()

func _ready() -> void:
	randomize()
	var s := randi()
	print(s)
	map_generator.generate(s)
	map_generator.log()
	update_with_map(map_generator.layers)
	gui_rich_text_button.pressed.connect(generate)

func generate() -> void:
	randomize()
	var s := randi()
	print(s)
	map_generator.generate(s)
	map_generator.log()
	update_with_map(map_generator.layers)

func update_with_map(layers:Array) -> void:
	gui_map_view.update_with_map(layers)
