class_name MapGenerator
extends RefCounted
# Generation algorithm: https://steamcommunity.com/sharedfiles/filedetails/?id=2830078257

const INTERNAL_LAYER_COUNT := 7
const MAX_ROWS := 5
const TOTAL_PATHS := 4
@warning_ignore("integer_division")
const CHEST_ROW := (INTERNAL_LAYER_COUNT + 1)/2
const NO_TAVERN_ROW := INTERNAL_LAYER_COUNT

const DEFAULT_TYPE_CHANGES := {
	MapNode.NodeType.NORMAL: 45,
	MapNode.NodeType.ELITE: 16,
	MapNode.NodeType.SHOP: 5,
	MapNode.NodeType.TAVERN: 12,
	MapNode.NodeType.EVENT: 22,
	MapNode.NodeType.CHEST: 0,
}
# Configurable restrictions (now for all types)
const DEFAULT_MIN_LAYER := {
	MapNode.NodeType.NORMAL: 0,
	MapNode.NodeType.EVENT: 0,
	MapNode.NodeType.ELITE: 5,
	MapNode.NodeType.SHOP: 0,
	MapNode.NodeType.TAVERN: 5,
	MapNode.NodeType.CHEST: 0,
	MapNode.NodeType.BOSS: 0,
}

# Smart constraints: types that cannot appear consecutively along any path
var _no_consecutive_types:Array = [MapNode.NodeType.ELITE, MapNode.NodeType.SHOP, MapNode.NodeType.CHEST, MapNode.NodeType.TAVERN]

var layers:Array = []

func generate(rand_seed:int = 0) -> void:
	# Minimal Cobalt Core-like generator: single start and boss, layered rows,
	# non-crossing monotone connections with light branching. Configs removed for now.
	layers.clear()
	var rng := RandomNumberGenerator.new()
	if rand_seed != 0:
		rng.seed = rand_seed

	_generate_nodes()
	_fill_rooms()

func _generate_nodes() -> void:
	@warning_ignore("integer_division")
	var center_y := MAX_ROWS/2
	# Always has one starting node.
	var starting_node:MapNode = MapNode.new()
	starting_node.type = MapNode.NodeType.NORMAL
	starting_node.grid_coordinates = Vector2i(0, center_y)

	layers.append([starting_node])
	for i in TOTAL_PATHS:
		_generate_nodes_in_a_path(starting_node, i)

	# Always has one tavern node before the boss node
	var last_before_boss_node:MapNode = MapNode.new()
	last_before_boss_node.type = MapNode.NodeType.TAVERN
	last_before_boss_node.grid_coordinates = Vector2i(INTERNAL_LAYER_COUNT + 1, center_y)
	layers.append([last_before_boss_node])
	for node in layers[INTERNAL_LAYER_COUNT]:
		node.connect_to(last_before_boss_node)


	# Always has one boss node
	var boss_node:MapNode = MapNode.new()
	boss_node.type = MapNode.NodeType.BOSS
	boss_node.grid_coordinates = Vector2i(INTERNAL_LAYER_COUNT + 2, center_y)
	layers.append([boss_node])
	last_before_boss_node.connect_to(boss_node)


func _generate_nodes_in_a_path(starting_node:MapNode, path_index:int) -> void:
	var current_layer:int = 1
	var last_node:MapNode = starting_node
	while current_layer < INTERNAL_LAYER_COUNT + 1:
		var next_node:MapNode = null
		if layers.size() <= current_layer:
			layers.append([])
		var new_node_coordinate:Vector2i = _get_new_node_row_index(last_node)

		# Ensure the path 0 and path 1 do not start with the same node
		if path_index == 1 && current_layer == 1:
			var path0_first_node:MapNode = layers[current_layer].front()
			var try_times := 500
			while(path0_first_node.grid_coordinates.y == new_node_coordinate.y && try_times > 0):
				try_times -= 1
				new_node_coordinate = _get_new_node_row_index(last_node)
		
		for node in layers[current_layer]:
			if node.grid_coordinates == new_node_coordinate:
				next_node = node
				break
		if !next_node:
			next_node = MapNode.new()
			next_node.grid_coordinates = new_node_coordinate
		if !layers[current_layer].has(next_node):
			layers[current_layer].append(next_node)
		if last_node:
			last_node.connect_to(next_node)
		last_node = next_node
		current_layer += 1

func _get_new_node_row_index(last_node:MapNode) -> Vector2i:
	var last_node_up_neighbor_coordinate:Vector2i = last_node.grid_coordinates + Vector2i.UP
	var last_node_down_neighbor_coordinate:Vector2i = last_node.grid_coordinates + Vector2i.DOWN
	var nodes_in_the_same_row:Array = layers[last_node.grid_coordinates.x - 1]
	var upper_node_exists:bool = false
	var lower_node_exists:bool = false
	for node in nodes_in_the_same_row:
		if node.grid_coordinates.y == last_node_up_neighbor_coordinate.y:
			upper_node_exists = true
		if node.grid_coordinates.y == last_node_down_neighbor_coordinate.y:
			lower_node_exists = true
	var can_go_up:bool = !upper_node_exists && last_node.grid_coordinates.y > 0
	var can_go_down:bool = !lower_node_exists && last_node.grid_coordinates.y < MAX_ROWS - 1

	var straight_path_coordinate = last_node.grid_coordinates + Vector2i.RIGHT
	var candidates:Array = [straight_path_coordinate]
	if can_go_up:
		candidates.append(straight_path_coordinate + Vector2i.UP)
	if can_go_down:
		candidates.append(straight_path_coordinate + Vector2i.DOWN)
	return Util.unweighted_roll(candidates, 1).front()

func _fill_rooms() -> void:
	for layer_index:int in range(1, INTERNAL_LAYER_COUNT):
		var row:Array = layers[layer_index]
		for node in row:
			if node.grid_coordinates.x == CHEST_ROW:
				node.type = MapNode.NodeType.CHEST
			else:
				node.type = MapNode.NodeType.NORMAL
			var candidates:Dictionary = _get_candidates(node)
			node.type = Util.weighted_roll(candidates.keys(), candidates.values())

func _get_candidates(node:MapNode) -> Dictionary:
	var candidates:Dictionary = DEFAULT_TYPE_CHANGES.duplicate()
	if _is_previous_node_of_type(node, MapNode.NodeType.TAVERN):
		candidates.erase(MapNode.NodeType.TAVERN)
	if _is_previous_node_of_type(node, MapNode.NodeType.ELITE):
		candidates.erase(MapNode.NodeType.ELITE)
	if node.grid_coordinates.x == NO_TAVERN_ROW:
		candidates.erase(MapNode.NodeType.TAVERN)

	var layer_index:int = node.grid_coordinates.x

	for type:MapNode.NodeType in candidates.keys():
		if layer_index < DEFAULT_MIN_LAYER[type]:
			candidates.erase(type)
	return candidates

func _is_previous_node_of_type(node:MapNode, type:MapNode.NodeType) -> bool:
	return node.parent_node.type == type

func log() -> void:
	for r in layers.size():
		print("Layer r %s; size: %s:" % [r, layers[r].size()])
		for node in layers[r]:
			node.log()
