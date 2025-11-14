class_name MapNodeContainer
extends Node2D

signal node_button_pressed(node:MapNode)
signal node_hovered(hovered:bool, node:MapNode)

const MAP_LINE_SCENE := preload("res://scenes/main_game/map/map_line.tscn")

@onready var lines_container: Node2D = %LinesContainer
@onready var nodes_container: Node2D = %NodesContainer

const LAYER_SPACING := 24
const ROW_SPACING := 22
const NODE_POSITION_NOISE := 1.0
const NODE_RADIUS := 3
const LINE_WIDTH := 1.0
const MAP_Y_OFFSET := 16 # Offset to center the map vertically, this is the height of the top bar.

var _node_positions:Dictionary = {} # {Vector2i: Vector2}

func _ready() -> void:
	lines_container.y_sort_enabled = true
	nodes_container.y_sort_enabled = true


func update_with_map_nodes(layers:Array) -> void:
	_recompute_positions(layers)
	_initialize_nodes(layers)

func update_nodes(layers:Array) -> void:
	for layer_index in layers.size():
		var layer_nodes:Array = layers[layer_index]
		for node in layer_nodes:
			node.update_button()
	Util.remove_all_children(lines_container)
	_draw_lines(layers)

func _initialize_nodes(layers:Array) -> void:
	_draw_lines(layers)
	_draw_nodes(layers)

func _recompute_positions(layers:Array) -> void:
	_node_positions.clear()
	if layers.is_empty():
		return
	var layer_count:int = layers.size()
	var total_width := (layer_count-1) * LAYER_SPACING
	var starting_x := - total_width / 2.0
	var total_height := MapGenerator.MAX_ROWS * ROW_SPACING
	var starting_y := - total_height / 2.0 + MAP_Y_OFFSET
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
			nodes_container.add_child(node)
			node.pressed.connect(_on_node_pressed.bind(node))
			node.hovered.connect(_on_node_hovered.bind(node))
			node.update_button()
			node.global_position = _get_node_position(node)

func _draw_lines(layers:Array) -> void:
	for layer_index in layers.size():
		var layer_nodes:Array = layers[layer_index]
		for node in layer_nodes:
			for nxt in node.next_nodes:
				var from_p := _get_node_position(node)
				var to_p := _get_node_position(nxt)
				_draw_line(from_p, to_p, node.node_state, nxt.node_state)

func _draw_line(from_p:Vector2, to_p:Vector2, from_node_state:MapNode.NodeState, to_node_state:MapNode.NodeState) -> void:
	var gui_line:MapLine = MAP_LINE_SCENE.instantiate()
	lines_container.add_child(gui_line)
	gui_line.update_with_line(from_p, to_p, from_node_state, to_node_state)

func _get_node_position(node:MapNode) -> Vector2:
	return _node_positions.get(node.grid_coordinates)

func _on_node_pressed(node:MapNode) -> void:
	if node.node_state in [MapNode.NodeState.COMPLETED, MapNode.NodeState.UNREACHABLE, MapNode.NodeState.CURRENT, MapNode.NodeState.NORMAL]:
		return
	node_button_pressed.emit(node)

func _on_node_hovered(hovered:bool, node:MapNode) -> void:
	node_hovered.emit(hovered, node)
