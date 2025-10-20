class_name GUIMapView
extends Control

const MAP_NODE_SCENE := preload("res://scenes/GUI/map/gui_map_node.tscn")

var _layers:Array = []
var _node_positions:Dictionary = {} # {Vector2i: Vector2}

const LAYER_SPACING := 24
const ROW_SPACING := 18
const NODE_RADIUS := 3
const LINE_WIDTH := 1.0
const BACKGROUND_COLOR := Constants.COLOR_GREEN5

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func update_with_map(layers:Array) -> void:
	_layers = layers
	_recompute_positions()
	#_update_content_size()
	for layer_index in _layers.size():
		var layer_nodes:Array = _layers[layer_index]
		for node:MapNode in layer_nodes:
			var gui_node:GUIMapNode = MAP_NODE_SCENE.instantiate()
			add_child(gui_node)
			gui_node.update_with_node(node)
			gui_node.position = _get_node_position(node) - gui_node.size / 2.0
			#gui_node.update_with_node(node)
	queue_redraw()

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
			_node_positions[node.grid_coordinates] = Vector2(x, y)

func _draw() -> void:
	if _layers.is_empty():
		return
	# Background
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND_COLOR, true)
	# Draw connections first
	for layer_index in _layers.size():
		var layer_nodes:Array = _layers[layer_index]
		for node in layer_nodes:
			for nxt in node.next_nodes:
				var from_p := _get_node_position(node)
				var to_p := _get_node_position(nxt)
				draw_line(from_p, to_p, Color(0.5,0.5,0.5,1.0), LINE_WIDTH)

func _get_node_position(node:MapNode) -> Vector2:
	return _node_positions.get(node.grid_coordinates)

#func _update_content_size() -> void:
#	# Fit full map to viewport, left-to-right columns, vertically centered per column
#	if _rows.is_empty():
#		_content_size = size
#		custom_minimum_size = _content_size
#		return
#	var layers:int = _rows.size()
#	var max_cols:int = 0
#	for r in layers:
#		max_cols = max(max_cols, _rows[r].size())
#	var viewport_size:Vector2 = get_viewport_rect().size
#	# Store as content size; positions recompute with these spacings
#	_content_size = viewport_size
#	custom_minimum_size = _content_size
#	# recompute using local spacings via helper
#	_recompute_positions_with(col_spacing, row_spacing)

func _get_color_for_type(t:int) -> Color:
	match t:
		MapNode.NodeType.NORMAL:
			return Color(0.7, 0.8, 0.7)
		MapNode.NodeType.ELITE:
			return Color(0.95, 0.45, 0.45)
		MapNode.NodeType.BOSS:
			return Color(0.2, 0.2, 0.2)
		MapNode.NodeType.SHOP:
			return Color(0.3, 0.6, 0.95)
		MapNode.NodeType.TAVERN:
			return Color(0.85, 0.7, 0.4)
		MapNode.NodeType.CHEST:
			return Color(0.95, 0.85, 0.4)
		MapNode.NodeType.EVENT:
			return Color(0.7, 0.6, 0.95)
		_:
			return Color(0.8, 0.8, 0.8)

func _get_max_row(layer_index:int) -> int:
	var layer_nodes:Array = _layers[layer_index]
	return layer_nodes.size()

func _notification(what:int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		queue_redraw()
