class_name GUIMapView
extends Control

var _rows:Array = []
var _node_positions:Array = [] # same shape as _rows: positions by [row][col]
var _content_size:Vector2 = Vector2.ZERO

const MARGIN := 24
const ROW_SPACING := 30
const COL_SPACING := 30
const NODE_RADIUS := 3
const LINE_WIDTH := 1.0
const BACKGROUND_COLOR := Color(0.1, 0.12, 0.14)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func update_with_map(rows:Array) -> void:
	_rows = rows
	_update_content_size()
	queue_redraw()

func _recompute_positions() -> void:
	_node_positions.clear()
	if _rows.is_empty():
		return
	_recompute_positions_with(COL_SPACING, ROW_SPACING)

func _recompute_positions_with(col_spacing:float, row_spacing:float) -> void:
	_node_positions.clear()
	if _rows.is_empty():
		return
	var layers:int = _rows.size()
	var available_h:float = _content_size.y - 2.0 * MARGIN
	for r in layers:
		var row_nodes:Array = _rows[r]
		var row_positions:Array = []
		if row_nodes.is_empty():
			_node_positions.append(row_positions)
			continue
		var num_cols:int = row_nodes.size()
		var total_height:float = max(0, num_cols - 1) * row_spacing
		var start_y:float = MARGIN + max(0.0, (available_h - total_height) * 0.5)
		var x := MARGIN + r * col_spacing
		for c in num_cols:
			row_positions.append(Vector2(x, start_y + c * row_spacing))
		_node_positions.append(row_positions)

func _draw() -> void:
	if _rows.is_empty():
		return
	# Background
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND_COLOR, true)
	# Draw connections first
	for r in _rows.size():
		var row_nodes:Array = _rows[r]
		for node in row_nodes:
			for nxt in node.next_nodes:
				var from_p := _get_node_position(node)
				var to_p := _get_node_position(nxt)
				draw_line(from_p, to_p, Color(0.5,0.5,0.5,1.0), LINE_WIDTH)
	# Draw nodes on top
	for r in _rows.size():
		var row_nodes:Array = _rows[r]
		for node in row_nodes:
			var p := _get_node_position(node)
			var color := _get_color_for_type(node.type)
			draw_circle(p, NODE_RADIUS, color)
			# outline
			draw_arc(p, NODE_RADIUS, 0, TAU, 32, Color(0,0,0,0.6), 2.0)

func _get_node_position(node) -> Vector2:
	var r:int = node.row
	var c:int = node.column
	if r >= 0 && r < _node_positions.size():
		var row_positions:Array = _node_positions[r]
		if c >= 0 && c < row_positions.size():
			return row_positions[c]
	return Vector2.ZERO

func _update_content_size() -> void:
	# Fit full map to viewport, left-to-right columns, vertically centered per column
	if _rows.is_empty():
		_content_size = get_viewport_rect().size
		custom_minimum_size = _content_size
		return
	var layers:int = _rows.size()
	var max_cols:int = 0
	for r in layers:
		max_cols = max(max_cols, _rows[r].size())
	var viewport_size:Vector2 = get_viewport_rect().size
	var needed_cols:int = max(1, layers - 1)
	var needed_rows:int = max(1, max_cols - 1)
	var col_spacing:float = minf(COL_SPACING, (viewport_size.x - 2.0 * MARGIN) / float(needed_cols))
	var row_spacing:float = minf(ROW_SPACING, (viewport_size.y - 2.0 * MARGIN) / float(needed_rows))
	# Store as content size; positions recompute with these spacings
	_content_size = viewport_size
	custom_minimum_size = _content_size
	# recompute using local spacings via helper
	_recompute_positions_with(col_spacing, row_spacing)

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

func _notification(what:int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		queue_redraw()
