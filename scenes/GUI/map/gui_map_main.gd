class_name GUIMapMain
extends CanvasLayer

@onready var gui_map_view: GUIMapView = %GUIMapView

func update_with_map(layers:Array) -> void:
	gui_map_view.update_with_map.call_deferred(layers)

func complete_node(node:MapNode) -> void:
	gui_map_view.complete_node(node)