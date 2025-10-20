class_name MapGenerator
extends RefCounted
# Generation algorithm: https://steamcommunity.com/sharedfiles/filedetails/?id=2830078257

const INTERNAL_LAYER_COUNT := 7
const MAX_ROWS := 5
const TOTAL_PATHS := 4

const ELITE_CHANCE := 0.15
const SHOP_CHANCE := 0.1
const TAVERN_CHANCE := 0.12
const EVENT_CHANCE := 0.15
const CHEST_CHANCE := 0.08

# Configurable restrictions (now for all types)
const DEFAULT_MIN_LAYER := {
	MapNode.NodeType.NORMAL: 0,
	MapNode.NodeType.EVENT: 1,
	MapNode.NodeType.ELITE: 3,
	MapNode.NodeType.SHOP: 1,
	MapNode.NodeType.TAVERN: 2,
	MapNode.NodeType.CHEST: 3,
	MapNode.NodeType.BOSS: 0,
}

var _min_layer_for_type:Dictionary = DEFAULT_MIN_LAYER.duplicate(true)

const DEFAULT_MAX_COUNT := {
	MapNode.NodeType.NORMAL: 999999,
	MapNode.NodeType.EVENT: 999999,
	MapNode.NodeType.ELITE: 6,
	MapNode.NodeType.SHOP: 4,
	MapNode.NodeType.TAVERN: 5,
	MapNode.NodeType.CHEST: 6,
	MapNode.NodeType.BOSS: 1,
}

const DEFAULT_MIN_COUNT := {
	MapNode.NodeType.NORMAL: 0,
	MapNode.NodeType.EVENT: 0,
	MapNode.NodeType.ELITE: 4,
	MapNode.NodeType.SHOP: 3,
	MapNode.NodeType.TAVERN: 4,
	MapNode.NodeType.CHEST: 5,
	MapNode.NodeType.BOSS: 1,
}

var _max_count_for_type:Dictionary = DEFAULT_MAX_COUNT.duplicate(true)
var _min_count_for_type:Dictionary = DEFAULT_MIN_COUNT.duplicate(true)

# Per-path constraints
const PER_PATH_MIN := {
	MapNode.NodeType.NORMAL: 0,
	MapNode.NodeType.EVENT: 0,
	MapNode.NodeType.ELITE: 0,
	MapNode.NodeType.SHOP: 1,
	MapNode.NodeType.TAVERN: 1,
	MapNode.NodeType.CHEST: 1,
}

const PER_PATH_MAX := {
	MapNode.NodeType.NORMAL: 999999,
	MapNode.NodeType.EVENT: 999999,
	MapNode.NodeType.ELITE: 3,
	MapNode.NodeType.SHOP: 2,
	MapNode.NodeType.TAVERN: 3,
	MapNode.NodeType.CHEST: 3,
}

var _per_path_min:Dictionary = PER_PATH_MIN.duplicate(true)
var _per_path_max:Dictionary = PER_PATH_MAX.duplicate(true)

# Smart constraints: types that cannot appear consecutively along any path
var _no_consecutive_types:Array = [MapNode.NodeType.ELITE, MapNode.NodeType.SHOP, MapNode.NodeType.TAVERN, MapNode.NodeType.CHEST]

var layers:Array = []

func generate(rand_seed:int = 0) -> void:
	# Minimal Cobalt Core-like generator: single start and boss, layered rows,
	# non-crossing monotone connections with light branching. Configs removed for now.
	layers.clear()
	var rng := RandomNumberGenerator.new()
	if rand_seed != 0:
		rng.seed = rand_seed

	_generate_nodes()
	_fill_rooms(rng)

func _generate_nodes() -> void:
	@warning_ignore("integer_division")
	var center_y := MAX_ROWS/2
	# Always has one starting node.
	var starting_node:MapNode = MapNode.new()
	starting_node.type = MapNode.NodeType.NORMAL
	starting_node.grid_coordinates = Vector2i(0, center_y)

	layers.append([starting_node])
	for i in TOTAL_PATHS:
		_generate_nodes_in_a_path(starting_node)

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


func _generate_nodes_in_a_path(starting_node:MapNode) -> void:
	var current_layer:int = 1
	var last_node:MapNode = starting_node
	while current_layer < INTERNAL_LAYER_COUNT + 1:
		var next_node:MapNode = null
		if layers.size() <= current_layer:
			layers.append([])
		var new_node_coordinate:Vector2i = _get_new_node_row_index(last_node)
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

func _fill_rooms(rng:RandomNumberGenerator) -> void:
	for layer in layers:
		for node in layer:
			node.type = MapNode.NodeType.NORMAL

func log() -> void:
	for r in layers.size():
		print("Layer r %s; size: %s:" % [r, layers[r].size()])
		for node in layers[r]:
			node.log()
