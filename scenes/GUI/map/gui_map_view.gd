class_name GUIMapView
extends Control

const MAP_NODE_SCENE := preload("res://scenes/GUI/map/gui_map_node.tscn")
const MAP_LINE_SCENE := preload("res://scenes/GUI/map/gui_map_line.tscn")

var _layers:Array = []
var _node_positions:Dictionary = {} # {Vector2i: Vector2}

const LAYER_SPACING := 24
const ROW_SPACING := 22
const NODE_POSITION_NOISE := 1.0
const NODE_RADIUS := 3
const LINE_WIDTH := 1.0
const BACKGROUND_COLOR := Constants.COLOR_GREEN5

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func update_with_map(layers:Array) -> void:
	Util.remove_all_children(self)
	_layers = layers
	_recompute_positions()
	_draw_lines()
	_draw_nodes()

func _recompute_positions() -> void:
	_node_positions.clear()
	if _layers.is_empty():
		return
	var layers:int = _layers.size()
	var total_width := layers * LAYER_SPACING
	var starting_x := (size.x - total_width) / 2.0
	var starting_y := (size.y - MapGenerator.MAX_ROWS * ROW_SPACING) / 2.0
	for layer_nodes:Array in _layers:
		assert(layer_nodes.size() > 0)
		for node:MapNode in layer_nodes:
			var x := starting_x + node.grid_coordinates.x * LAYER_SPACING
			var y := starting_y + node.grid_coordinates.y * ROW_SPACING
			_node_positions[node.grid_coordinates] = Vector2(x, y) + Vector2.ONE * randf_range(-NODE_POSITION_NOISE, NODE_POSITION_NOISE)

func _draw_nodes() -> void:
	for layer_index in _layers.size():
		var layer_nodes:Array = _layers[layer_index]
		for node in layer_nodes:
			var gui_node:GUIMapNode = MAP_NODE_SCENE.instantiate()
			add_child(gui_node)
			gui_node.update_with_node(node)
			gui_node.position = _get_node_position(node) - gui_node.size / 2.0

func _draw_lines() -> void:
	for layer_index in _layers.size():
		var layer_nodes:Array = _layers[layer_index]
		for node in layer_nodes:
			for nxt in node.next_nodes:
				var from_p := _get_node_position(node)
				var to_p := _get_node_position(nxt)
				_draw_line(from_p, to_p)

func _draw_line(from_p:Vector2, to_p:Vector2) -> void:
	var gui_line:GUIMapLine = MAP_LINE_SCENE.instantiate()
	add_child(gui_line)
	gui_line.update_with_line(from_p, to_p)

func _get_node_position(node:MapNode) -> Vector2:
	return _node_positions.get(node.grid_coordinates)
