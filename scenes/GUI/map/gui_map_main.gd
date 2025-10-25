class_name GUIMapMain
extends CanvasLayer

signal node_button_pressed(node:MapNode)

@onready var gui_map_view: GUIMapView = %GUIMapView

func _ready() -> void:
	gui_map_view.node_button_pressed.connect(func(node:MapNode) -> void: node_button_pressed.emit(node))

func update_with_map(layers:Array) -> void:
	gui_map_view.update_with_map.call_deferred(layers)

func complete_node(node:MapNode) -> void:
	gui_map_view.complete_node(node)
