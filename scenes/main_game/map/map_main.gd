class_name MapMain
extends Node2D

signal node_selected(node:MapNode)

@onready var gui: GUIMapMain = %GUIMapMain

func _ready() -> void:
	gui.node_button_pressed.connect(_on_node_selected)

func update_with_map(layers:Array) -> void:
	gui.update_with_map(layers)

func _on_node_selected(node:MapNode) -> void:
	node_selected.emit(node)
