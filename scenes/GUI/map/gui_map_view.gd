class_name GUIMapView
extends Control

signal node_button_pressed(node:MapNode)
signal node_mouse_entered(node:MapNode)
signal node_mouse_exited(node:MapNode)

const MAP_NODE_BUTTON_SCENE := preload("res://scenes/GUI/map/gui_map_node_button.tscn")
const MAP_LINE_SCENE := preload("res://scenes/GUI/map/gui_map_line.tscn")

var _node_positions:Dictionary = {} # {Vector2i: Vector2}

const LAYER_SPACING := 24
const ROW_SPACING := 22
const NODE_POSITION_NOISE := 1.0
const NODE_RADIUS := 3
const LINE_WIDTH := 1.0
const BACKGROUND_COLOR := Constants.COLOR_GREEN5

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func update_with_map(layers:Array) -> void:
	_recompute_positions(layers)
	redraw(layers)

func redraw(layers:Array) -> void:
	Util.remove_all_children(self)
	_draw_lines(layers)
	_draw_nodes(layers)

func _recompute_positions(layers:Array) -> void:
	_node_positions.clear()
	if layers.is_empty():
		return
	var layer_count:int = layers.size()
	var total_width := (layer_count-1) * LAYER_SPACING
	var starting_x := (size.x - total_width) / 2.0
	var total_height := MapGenerator.MAX_ROWS * ROW_SPACING
	var starting_y := (size.y - total_height) / 2.0
	for layer_nodes:Array in layers:
		assert(layer_nodes.size() > 0)
		for node:MapNode in layer_nodes:
			var x := starting_x + node.grid_coordinates.x * LAYER_SPACING
			var y := starting_y + node.grid_coordinates.y * ROW_SPACING
			_node_positions[node.grid_coordinates] = Vector2(x, y) + Vector2.ONE * randf_range(-NODE_POSITION_NOISE, NODE_POSITION_NOISE)

func _draw_nodes(layers:Array) -> void:
	for layer_index in layers.size():
		var layer_nodes:Array = layers[layer_index]
		for node in layer_nodes:
			var gui_node:GUIMapNodeButton = MAP_NODE_BUTTON_SCENE.instantiate()
			add_child(gui_node)
			gui_node.pressed.connect(_on_node_pressed.bind(node))
			gui_node.mouse_entered.connect(_on_node_mouse_entered.bind(node))
			gui_node.mouse_exited.connect(_on_node_mouse_exited.bind(node))
			gui_node.update_with_node(node)
			gui_node.position = _get_node_position(node) - gui_node.size / 2.0

func _draw_lines(layers:Array) -> void:
	for layer_index in layers.size():
		var layer_nodes:Array = layers[layer_index]
		for node in layer_nodes:
			for nxt in node.next_nodes:
				var from_p := _get_node_position(node)
				var to_p := _get_node_position(nxt)
				_draw_line(from_p, to_p, node.node_state, nxt.node_state)

func _draw_line(from_p:Vector2, to_p:Vector2, from_node_state:MapNode.NodeState, to_node_state:MapNode.NodeState) -> void:
	var gui_line:GUIMapLine = MAP_LINE_SCENE.instantiate()
	add_child(gui_line)
	gui_line.update_with_line(from_p, to_p, from_node_state, to_node_state)

func _get_node_position(node:MapNode) -> Vector2:
	return _node_positions.get(node.grid_coordinates)

func _on_node_pressed(node:MapNode) -> void:
	node_button_pressed.emit(node)

func _on_node_mouse_entered(node:MapNode) -> void:
	node_mouse_entered.emit(node)

func _on_node_mouse_exited(node:MapNode) -> void:
	node_mouse_exited.emit(node)
