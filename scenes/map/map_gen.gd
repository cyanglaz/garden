class_name MapGeneratorOld
extends RefCounted

const MapNodeScript := preload("res://scenes/map/map_node.gd")

const LAYER_COUNT := 10
const MIN_ROW:= 2
const MAX_ROW:= 5
const START_NODE_COUNT := 1

const ELITE_CHANCE := 0.15
const SHOP_CHANCE := 0.1
const TAVERN_CHANCE := 0.12
const EVENT_CHANCE := 0.15
const CHEST_CHANCE := 0.08

# Global path count constraints
const MIN_TOTAL_PATHS := 4
const MAX_TOTAL_PATHS := 6

# Configurable restrictions (now for all types)
const DEFAULT_MIN_LAYER := {
	MapNodeScript.NodeType.NORMAL: 0,
	MapNodeScript.NodeType.EVENT: 1,
	MapNodeScript.NodeType.ELITE: 3,
	MapNodeScript.NodeType.SHOP: 1,
	MapNodeScript.NodeType.TAVERN: 2,
	MapNodeScript.NodeType.CHEST: 3,
	MapNodeScript.NodeType.BOSS: 0,
}

var _min_layer_for_type:Dictionary = DEFAULT_MIN_LAYER.duplicate(true)

const DEFAULT_MAX_COUNT := {
	MapNodeScript.NodeType.NORMAL: 999999,
	MapNodeScript.NodeType.EVENT: 999999,
	MapNodeScript.NodeType.ELITE: 6,
	MapNodeScript.NodeType.SHOP: 4,
	MapNodeScript.NodeType.TAVERN: 5,
	MapNodeScript.NodeType.CHEST: 6,
	MapNodeScript.NodeType.BOSS: 1,
}

const DEFAULT_MIN_COUNT := {
	MapNodeScript.NodeType.NORMAL: 0,
	MapNodeScript.NodeType.EVENT: 0,
	MapNodeScript.NodeType.ELITE: 4,
	MapNodeScript.NodeType.SHOP: 3,
	MapNodeScript.NodeType.TAVERN: 4,
	MapNodeScript.NodeType.CHEST: 5,
	MapNodeScript.NodeType.BOSS: 1,
}

var _max_count_for_type:Dictionary = DEFAULT_MAX_COUNT.duplicate(true)
var _min_count_for_type:Dictionary = DEFAULT_MIN_COUNT.duplicate(true)

# Per-path constraints
const PER_PATH_MIN := {
	MapNodeScript.NodeType.NORMAL: 0,
	MapNodeScript.NodeType.EVENT: 0,
	MapNodeScript.NodeType.ELITE: 0,
	MapNodeScript.NodeType.SHOP: 1,
	MapNodeScript.NodeType.TAVERN: 1,
	MapNodeScript.NodeType.CHEST: 1,
}

const PER_PATH_MAX := {
	MapNodeScript.NodeType.NORMAL: 999999,
	MapNodeScript.NodeType.EVENT: 999999,
	MapNodeScript.NodeType.ELITE: 3,
	MapNodeScript.NodeType.SHOP: 2,
	MapNodeScript.NodeType.TAVERN: 3,
	MapNodeScript.NodeType.CHEST: 3,
}

var _per_path_min:Dictionary = PER_PATH_MIN.duplicate(true)
var _per_path_max:Dictionary = PER_PATH_MAX.duplicate(true)

# Smart constraints: types that cannot appear consecutively along any path
var _no_consecutive_types:Array = [MapNodeScript.NodeType.ELITE, MapNodeScript.NodeType.SHOP, MapNodeScript.NodeType.TAVERN, MapNodeScript.NodeType.CHEST]

var layers:Array = []

func generate(_chapter:int, _seed:int = 0, _restrictions:Dictionary = {}) -> void:
	# Minimal Cobalt Core-like generator: single start and boss, layered rows,
	# non-crossing monotone connections with light branching. Configs removed for now.
	layers.clear()
	var rng := RandomNumberGenerator.new()
	if _seed != 0:
		rng.seed = _seed

	var num_layers:int = LAYER_COUNT
	assert(num_layers >= 2)

	# 1) Decide simple layer rows: start=1, boss=1, gentle variation in between (1..4)
	var layer_rows:Array = []
	layer_rows.append(1)
	var prev := 1
	var planned_diverges:int = rng.randi_range(2, 3)
	for r in range(1, num_layers - 1):
		var next_w:int
		if r <= planned_diverges:
			# Force early divergence: 2, then 3, then 4 lanes (capped)
			next_w = mini(1 + r, 4)
		else:
			# Gentle variation afterward
			var delta := rng.randi_range(-1, 1)
			next_w = clamp(prev + delta, 1, 4)
		layer_rows.append(next_w)
		prev = next_w
	layer_rows.append(1)

	# 2) Create nodes; all NORMAL except final BOSS
	for layer_index in num_layers:
		var layer_nodes:Array = []
		var layer_row:int = layer_rows[layer_index]
		for row_index in layer_row:
			var node = MapNodeScript.new()
			node.layer = layer_index
			node.row = row_index
			node.type = MapNodeScript.NodeType.NORMAL
			layer_nodes.append(node)
		layers.append(layer_nodes)
	layers[num_layers - 1][0].type = MapNodeScript.NodeType.BOSS

	# 2.5) Fill node types with simple configurable weights
	_fill_types(layers, num_layers, rng)

	# 3) Connect layers with non-crossing monotone links and light branching
	for r in num_layers - 1:
		var curr:Array = layers[r]
		var nxt:Array = layers[r + 1]
		if curr.is_empty() || nxt.is_empty():
			continue
		var curr_len:int = curr.size()
		var nxt_len:int = nxt.size()
		var pairs:int = min(curr_len, nxt_len)
		# base i->i
		for i in pairs:
			curr[i].connect_to(nxt[i])
		# ensure all next nodes have incoming
		if nxt_len > curr_len:
			for j in range(curr_len, nxt_len):
				curr[curr_len - 1].connect_to(nxt[j])
		# merge extra current nodes into last next
		if curr_len > nxt_len:
			for i in range(nxt_len, curr_len):
				curr[i].connect_to(nxt[nxt_len - 1])
		# gentle branching i->i+1 with 40% chance
		var max_fwd:int = min(curr_len - 1, nxt_len - 1)
		for i in max_fwd:
			if rng.randf() < 0.4:
				if nxt[i + 1] not in curr[i].next_nodes:
					curr[i].connect_to(nxt[i + 1])

	# Enforce total path count within [MIN_TOTAL_PATHS, MAX_TOTAL_PATHS]
	_enforce_total_paths(layers, num_layers)
	# Ensure no dead ends (every non-last-layer node has at least one outgoing)
	_ensure_no_dead_ends(layers, num_layers)
	# Only one node leads to boss, and it must be TAVERN
	_enforce_single_boss_entry(layers, num_layers)

func _roll_node_type(r:int, num_layers:int, rng:RandomNumberGenerator, type_counts:Dictionary) -> int:
	# layer 0 is always NORMAL regardless of restrictions
	if r == 0:
		return MapNodeScript.NodeType.NORMAL
	# Last layer is always BOSS regardless of restrictions
	if r == num_layers - 1:
		return MapNodeScript.NodeType.BOSS
	var roll := rng.randf()
	if roll < ELITE_CHANCE:
		if _can_place_type(MapNodeScript.NodeType.ELITE, r, type_counts):
			return MapNodeScript.NodeType.ELITE
	roll -= ELITE_CHANCE
	if roll < SHOP_CHANCE:
		if _can_place_type(MapNodeScript.NodeType.SHOP, r, type_counts):
			return MapNodeScript.NodeType.SHOP
	roll -= SHOP_CHANCE
	if roll < TAVERN_CHANCE:
		if _can_place_type(MapNodeScript.NodeType.TAVERN, r, type_counts):
			return MapNodeScript.NodeType.TAVERN
	roll -= TAVERN_CHANCE
	if roll < EVENT_CHANCE:
		if _can_place_type(MapNodeScript.NodeType.EVENT, r, type_counts):
			return MapNodeScript.NodeType.EVENT
	roll -= EVENT_CHANCE
	if roll < CHEST_CHANCE:
		if _can_place_type(MapNodeScript.NodeType.CHEST, r, type_counts):
			return MapNodeScript.NodeType.CHEST
	# Fallbacks honoring restrictions when possible
	if _can_place_type(MapNodeScript.NodeType.NORMAL, r, type_counts):
		return MapNodeScript.NodeType.NORMAL
	if _can_place_type(MapNodeScript.NodeType.EVENT, r, type_counts):
		return MapNodeScript.NodeType.EVENT
	# If everything is exhausted, default to NORMAL to keep map viable
	return MapNodeScript.NodeType.NORMAL

func _can_place_type(t:int, layer:int, type_counts:Dictionary) -> bool:
	var min_layer := int(_min_layer_for_type.get(t, 0))
	if layer < min_layer:
		return false
	var current := int(type_counts.get(t, 0))
	var max_count := int(_max_count_for_type.get(t, 999999))
	return current < max_count

func _satisfy_min_counts(_layers:Array, type_counts:Dictionary, num_layers:int) -> void:
	for t in _min_count_for_type.keys():
		var needed := int(_min_count_for_type[t]) - int(type_counts.get(t, 0))
		if needed <= 0:
			continue
		_needed_promote_type(t, needed, _layers, type_counts, num_layers)

func _needed_promote_type(t:int, needed:int, _layers:Array, type_counts:Dictionary, num_layers:int) -> void:
	if needed <= 0:
		return
	for r in _layers.size():
		if needed <= 0:
			break
		if r == 0:
			continue
		if r == num_layers - 1:
			continue
		for node in _layers[r]:
			if needed <= 0:
				break
			if !_can_place_type(t, r, type_counts):
				continue
			var src:int = node.type
			if src == t:
				continue
			# prefer converting NORMAL/EVENT first
			var prefer:bool = (src == MapNodeScript.NodeType.NORMAL || src == MapNodeScript.NodeType.EVENT)
			if !prefer:
				# only convert other types if they exceed their min_count
				var src_min := int(_min_count_for_type.get(src, 0))
				var src_count := int(type_counts.get(src, 0))
				if src_count - 1 < src_min:
					continue
			# apply conversion
			node.type = t
			type_counts[t] = int(type_counts.get(t, 0)) + 1
			type_counts[src] = int(type_counts.get(src, 0)) - 1
			needed -= 1

func _enforce_per_path_constraints(_layers:Array, type_counts:Dictionary, num_layers:int) -> void:
	var safety:int = 100
	while safety > 0:
		safety -= 1
		var adjusted:bool = false
		var paths := _get_all_paths(_layers, num_layers)
		for path in paths:
			# For each type with per-path constraints
			for t in _per_path_min.keys():
				var min_needed:int = int(_per_path_min.get(t, 0))
				var max_allowed:int = int(_per_path_max.get(t, 999999))
				if min_needed == 0 && max_allowed >= 999999:
					continue
				var count:int = 0
				for node in path:
					if node.type == t:
						count += 1
				# underflow -> promote
				if count < min_needed:
					var promoted:bool = _promote_on_path_to_type(path, t, min_needed - count, type_counts, num_layers)
					if promoted:
						adjusted = true
						break
				# overflow -> demote
				if count > max_allowed:
					var demoted:bool = _demote_on_path_from_type(path, t, count - max_allowed, type_counts)
					if demoted:
						adjusted = true
						break
			# Smart constraint: break disallowed consecutive types (skip penultimate layer)
			if _no_consecutive_types.size() > 0:
				for i in range(1, path.size()):
					var prev = path[i - 1]
					var cur = path[i]
					if prev.layer == num_layers - 2 || cur.layer == num_layers - 2:
						continue
					if prev.type == cur.type && _no_consecutive_types.has(cur.type):
						# Try to modify the current node to break the consecutive
						var fixed:bool = _break_consecutive_at(path, i, type_counts, num_layers)
						if !fixed:
							# Fallback: try modify previous if possible
							fixed = _break_consecutive_at(path, i - 1, type_counts, num_layers)
						if fixed:
							adjusted = true
							break
			if adjusted:
				break
		if !adjusted:
			break

func _break_consecutive_at(path:Array, index:int, type_counts:Dictionary, num_layers:int) -> bool:
	if index < 0 || index >= path.size():
		return false
	var node = path[index]
	var r:int = node.layer
	if r == 0 || r == num_layers - 1 || r == num_layers - 2:
		return false
	var src:int = node.type
	# ensure we can reduce count of src if needed
	var src_min := int(_min_count_for_type.get(src, 0))
	if int(type_counts.get(src, 0)) - 1 < src_min:
		return false
	var prev_type := src
	var next_type := -1
	if index + 1 < path.size():
		next_type = path[index + 1].type
	var before_type := -1
	if index - 1 >= 0:
		before_type = path[index - 1].type
	# Try candidates in priority order
	var candidates:Array = [
		MapNodeScript.NodeType.NORMAL,
		MapNodeScript.NodeType.EVENT,
		MapNodeScript.NodeType.CHEST,
		MapNodeScript.NodeType.TAVERN,
		MapNodeScript.NodeType.SHOP,
		MapNodeScript.NodeType.ELITE,
	]
	for target in candidates:
		if target == prev_type:
			continue
		if target == MapNodeScript.NodeType.BOSS:
			continue
		# Avoid creating new consecutive of a disallowed type
		if _no_consecutive_types.has(target):
			if target == before_type || target == next_type:
				continue
		# Respect min_layer and global max_count
		if !_can_place_type(target, r, type_counts):
			continue
		# Apply
		node.type = target
		type_counts[target] = int(type_counts.get(target, 0)) + 1
		type_counts[src] = int(type_counts.get(src, 0)) - 1
		return true
	return false

func _promote_on_path_to_type(path:Array, t:int, need:int, type_counts:Dictionary, num_layers:int) -> bool:
	var changed:bool = false
	for node in path:
		if need <= 0:
			break
		var r:int = node.layer
		if r == 0 || r == num_layers - 1 || r == num_layers - 2:
			continue
		if !_can_place_type(t, r, type_counts):
			continue
		var src:int = node.type
		if src == t:
			continue
		# Prefer converting NORMAL/EVENT first
		var prefer:bool = (src == MapNodeScript.NodeType.NORMAL || src == MapNodeScript.NodeType.EVENT)
		if !prefer:
			var src_min := int(_min_count_for_type.get(src, 0))
			var src_count := int(type_counts.get(src, 0))
			if src_count - 1 < src_min:
				continue
		node.type = t
		type_counts[t] = int(type_counts.get(t, 0)) + 1
		type_counts[src] = int(type_counts.get(src, 0)) - 1
		need -= 1
		changed = true
	return changed

func _demote_on_path_from_type(path:Array, t:int, excess:int, type_counts:Dictionary) -> bool:
	var changed:bool = false
	for node in path:
		if excess <= 0:
			break
		if node.type != t:
			continue
		# ensure we keep global min_count for t and keep penultimate layer taverns
		if node.layer == LAYER_COUNT - 2 && t == MapNodeScript.NodeType.TAVERN:
			continue
		var t_min := int(_min_count_for_type.get(t, 0))
		var t_count := int(type_counts.get(t, 0))
		if t_count - 1 < t_min:
			continue
		# demote to NORMAL
		node.type = MapNodeScript.NodeType.NORMAL
		type_counts[MapNodeScript.NodeType.NORMAL] = int(type_counts.get(MapNodeScript.NodeType.NORMAL, 0)) + 1
		type_counts[t] = int(type_counts.get(t, 0)) - 1
		excess -= 1
		changed = true
	return changed

func _enforce_global_max_counts(_layers:Array, type_counts:Dictionary, num_layers:int) -> void:
	for t in _max_count_for_type.keys():
		var max_allowed := int(_max_count_for_type.get(t, 999999))
		var current := int(type_counts.get(t, 0))
		var excess := current - max_allowed
		if excess <= 0:
			continue
		for r in _layers.size():
			if excess <= 0:
				break
			for node in _layers[r]:
				if excess <= 0:
					break
				if node.type != t:
					continue
				if r == 0:
					continue
				if node.type == MapNodeScript.NodeType.BOSS:
					continue
				# keep taverns on penultimate layer
				if r == num_layers - 2 && t == MapNodeScript.NodeType.TAVERN:
					continue
				var t_min := int(_min_count_for_type.get(t, 0))
				if int(type_counts.get(t, 0)) - 1 < t_min:
					continue
				node.type = MapNodeScript.NodeType.NORMAL
				type_counts[MapNodeScript.NodeType.NORMAL] = int(type_counts.get(MapNodeScript.NodeType.NORMAL, 0)) + 1
				type_counts[t] = int(type_counts.get(t, 0)) - 1
				excess -= 1

func _get_all_paths(_layers:Array, num_layers:int) -> Array:
	var paths:Array = []
	if _layers.is_empty():
		return paths
	var starts:Array = _layers[0]
	var end_node = _layers[num_layers - 1][0]
	for s in starts:
		var current:Array = []
		_current_paths_dfs(s, end_node, current, paths)
	return paths

func _current_paths_dfs(node, end_node, current:Array, paths:Array) -> void:
	current.append(node)
	if node == end_node:
		paths.append(current.duplicate())
		current.pop_back()
		return
	if node.next_nodes.is_empty():
		current.pop_back()
		return
	for nxt in node.next_nodes:
		_current_paths_dfs(nxt, end_node, current, paths)
	current.pop_back()

func _force_penultimate_layer_tavern(_layers:Array, type_counts:Dictionary, num_layers:int) -> void:
	if num_layers < 2:
		return
	var layer_index := num_layers - 2
	var _boss_layer_index := num_layers - 1
	# Build quick set of nodes on any path at penultimate layer
	var path_nodes := {}
	var paths := _get_all_paths(_layers, num_layers)
	for path in paths:
		if path.size() < 2:
			continue
		var penultimate = path[path.size() - 2]
		if penultimate.layer == layer_index:
			path_nodes[penultimate] = true
	# Force only path nodes on the penultimate layer to TAVERN
	for node in _layers[layer_index]:
		if !path_nodes.has(node):
			continue
		if node.type == MapNodeScript.NodeType.TAVERN:
			continue
		var src:int = node.type
		node.type = MapNodeScript.NodeType.TAVERN
		type_counts[MapNodeScript.NodeType.TAVERN] = int(type_counts.get(MapNodeScript.NodeType.TAVERN, 0)) + 1
		type_counts[src] = int(type_counts.get(src, 0)) - 1

func _pick_connections(next_layer:Array, rng:RandomNumberGenerator) -> Array:
	var connections:Array = []
	if next_layer.is_empty():
		return connections
	var first = next_layer[rng.randi_range(0, next_layer.size() - 1)]
	connections.append(first)
	# chance to add a second distinct connection
	if next_layer.size() > 1 && rng.randf() < 0.5:
		var second = first
		var safety := 8
		while second == first && safety > 0:
			second = next_layer[rng.randi_range(0, next_layer.size() - 1)]
			safety -= 1
		if second != first:
			connections.append(second)
	return connections

func _connect_layers(current_layer:Array, next_layer:Array, _rng:RandomNumberGenerator) -> void:
	if current_layer.is_empty() || next_layer.is_empty():
		return
	# Sort both layers by row to create monotonic mapping to avoid crossings
	var sorted_current := current_layer.duplicate()
	sorted_current.sort_custom(Callable(self, "_compare_node_row"))
	var sorted_next := next_layer.duplicate()
	sorted_next.sort_custom(Callable(self, "_compare_node_row"))

	# First pass: one-to-one connections in order to ensure a base non-crossing skeleton
	var pairs:int = min(sorted_current.size(), sorted_next.size())
	for i in pairs:
		sorted_current[i].connect_to(sorted_next[i])

	# Ensure each next-layer node has at least one incoming edge
	var index_of_next := {}
	for j in sorted_next.size():
		index_of_next[sorted_next[j]] = j
	var has_incoming:Array = []
	for _j in sorted_next.size():
		has_incoming.append(false)
	for src in current_layer:
		for t in src.next_nodes:
			if index_of_next.has(t):
				var j:int = index_of_next[t]
				has_incoming[j] = true
	for j in sorted_next.size():
		if has_incoming[j]:
			continue
		var src_index:int = min(j, sorted_current.size() - 1)
		if src_index < 0:
			continue
		var src_node = sorted_current[src_index]
		var target = sorted_next[j]
		if target not in src_node.next_nodes:
			src_node.connect_to(target)

	# Second pass: allow forward edges i->i+1 and i->i+2, cap out-degree at 3
	var extra_limit:int = min(sorted_current.size(), sorted_next.size())
	for i in extra_limit:
		var node = sorted_current[i]
		for offset in 2:
			if node.next_nodes.size() >= 3:
				break
			var j:int = i + 1 + offset
			if j < 0 || j >= sorted_next.size():
				continue
			var extra_target = sorted_next[j]
			if extra_target in node.next_nodes:
				continue
			node.connect_to(extra_target)

func _enforce_total_paths(_layers:Array, num_layers:int) -> void:
	var safety:int = 400
	while safety > 0:
		safety -= 1
		var paths := _get_all_paths(_layers, num_layers)
		var count:int = paths.size()
		if count < MIN_TOTAL_PATHS:
			# try to add edges to increase paths
			if !_try_add_monotone_edge(_layers):
				break
			continue
		if count > MAX_TOTAL_PATHS:
			# use greedy removal of non-essential edges to reduce path count
			if !_greedy_remove_one_edge(_layers, num_layers, count):
				# fallback to simple removal
				if !_try_remove_monotone_extra(_layers):
					break
			continue
		break

func _try_add_monotone_edge(_layers:Array) -> bool:
	for r in _layers.size() - 1:
		var current_layer = _layers[r]
		var next_layer = _layers[r + 1]
		if current_layer.is_empty() || next_layer.is_empty():
			continue
		var sc:Array = current_layer.duplicate()
		sc.sort_custom(Callable(self, "_compare_node_row"))
		var sn:Array = next_layer.duplicate()
		sn.sort_custom(Callable(self, "_compare_node_row"))
		var pairs:int = min(sc.size(), sn.size())
		for i in pairs:
			var node = sc[i]
			var j:int = i + 1
			if j >= 0 && j < sn.size():
				var target = sn[j]
				if target not in node.next_nodes:
					node.connect_to(target)
					return true
	return false

func _try_remove_monotone_extra(_layers:Array) -> bool:
	for r in _layers.size() - 1:
		var current_layer = _layers[r]
		var next_layer = _layers[r + 1]
		if current_layer.is_empty() || next_layer.is_empty():
			continue
		var sc:Array = current_layer.duplicate()
		sc.sort_custom(Callable(self, "_compare_node_row"))
		var sn:Array = next_layer.duplicate()
		sn.sort_custom(Callable(self, "_compare_node_row"))
		var pairs:int = min(sc.size(), sn.size())
		for i in pairs:
			var node = sc[i]
			var j:int = i + 1
			if j >= 0 && j < sn.size():
				var target = sn[j]
				if target in node.next_nodes:
					node.next_nodes.erase(target)
					return true
	return false

func _compute_incoming_counts(_layers:Array) -> Dictionary:
	var incoming:Dictionary = {}
	for r in _layers.size():
		for node in _layers[r]:
			incoming[node] = 0
	for r in _layers.size():
		for node in _layers[r]:
			for t in node.next_nodes:
				incoming[t] = int(incoming.get(t, 0)) + 1
	return incoming

func _greedy_remove_one_edge(_layers:Array, num_layers:int, current_count:int) -> bool:
	# Prefer removing edges high in the graph to cut many combinations
	var incoming := _compute_incoming_counts(_layers)
	for r in range(0, num_layers - 1):
		for node in _layers[r]:
			# iterate over a copy to allow removal
			var targets:Array = node.next_nodes.duplicate()
			for t in targets:
				# keep at least one incoming for target
				if int(incoming.get(t, 0)) <= 1:
					continue
				# try remove
				node.next_nodes.erase(t)
				incoming[t] = int(incoming.get(t, 0)) - 1
				var new_count:int = _get_all_paths(_layers, num_layers).size()
				if new_count < current_count && new_count >= MIN_TOTAL_PATHS:
					return true
				# revert
				node.next_nodes.append(t)
				incoming[t] = int(incoming.get(t, 0)) + 1
	return false

func _ensure_no_dead_ends(_layers:Array, num_layers:int) -> void:
	for r in range(0, num_layers - 1):
		var curr:Array = _layers[r]
		var nxt:Array = _layers[r + 1]
		if curr.is_empty() || nxt.is_empty():
			continue
		# sorted by row to keep planarity assumptions
		var sorted_curr:Array = curr.duplicate()
		sorted_curr.sort_custom(Callable(self, "_compare_node_row"))
		for i in sorted_curr.size():
			var node = sorted_curr[i]
			if node.next_nodes.is_empty():
				# attach to nearest forward index
				var j:int = clamp(i, 0, nxt.size() - 1)
				if nxt[j] not in node.next_nodes:
					node.connect_to(nxt[j])

func _enforce_single_boss_entry(_layers:Array, num_layers:int) -> void:
	if num_layers < 2:
		return
	var boss_layer:Array = _layers[num_layers - 1]
	if boss_layer.is_empty():
		return
	var boss = boss_layer[0]
	var penultimate_layer:Array = _layers[num_layers - 2]
	if penultimate_layer.is_empty():
		return
	# Pick a single entry node in penultimate layer (prefer existing tavern, else first)
	var entry = null
	for node in penultimate_layer:
		if node.type == MapNodeScript.NodeType.TAVERN:
			entry = node
			break
	if entry == null:
		entry = penultimate_layer[0]
		entry.type = MapNodeScript.NodeType.TAVERN
	# Remove all edges to boss; then connect only entry -> boss
	for node in penultimate_layer:
		if boss in node.next_nodes:
			node.next_nodes.erase(boss)
	if boss not in entry.next_nodes:
		entry.connect_to(boss)
	# Collapse penultimate layer to only keep the entry tavern
	var new_penultimate:Array = []
	new_penultimate.append(entry)
	entry.row = 0
	_layers[num_layers - 2] = new_penultimate
	# Redirect all parents (pre-penultimate layer) to flow into the entry tavern
	if num_layers >= 3:
		var pre_layer:Array = _layers[num_layers - 3]
		for parent in pre_layer:
			# remove links to other penultimate nodes
			var to_remove:Array = []
			for t in parent.next_nodes:
				if t.layer == num_layers - 2 && t != entry:
					to_remove.append(t)
			for t in to_remove:
				parent.next_nodes.erase(t)
			# ensure link to entry
			if entry not in parent.next_nodes:
				parent.connect_to(entry)

func _ensure_all_paths_reach_boss(_layers:Array, num_layers:int) -> void:
	# Backward pass to ensure each node can reach some node in next layers up to boss
	var can_reach:Array = []
	for r in num_layers:
		can_reach.append([])
	# Boss layer can reach boss
	for node in _layers[num_layers - 1]:
		can_reach[num_layers - 1].append(true)
	# Other layers initially false
	for r in num_layers - 1:
		var layer:Array = _layers[r]
		for _n in layer:
			can_reach[r].append(false)
	# Backward propagate reachability
	for r in range(num_layers - 2, -1, -1):
		var layer:Array = _layers[r]
		for i in layer.size():
			var node = layer[i]
			var reachable := false
			for nxt in node.next_nodes:
				if can_reach[nxt.layer][nxt.row]:
					reachable = true
					break
			if !reachable:
				# add a monotone edge to a reachable next node if possible
				if !_connect_to_nearest_reachable(node, _layers[r + 1], can_reach, r + 1):
					# fallback: connect to nearest in next layer
					node.connect_to(_layers[r + 1][min(i, _layers[r + 1].size() - 1)])
					reachable = true
			# update this node's reachability
			can_reach[r][i] = reachable

func _connect_to_nearest_reachable(node, next_layer:Array, can_reach:Array, next_r:int) -> bool:
	if next_layer.is_empty():
		return false
	# try same row
	var j:int = clamp(node.row, 0, next_layer.size() - 1)
	if can_reach[next_r][j]:
		if next_layer[j] not in node.next_nodes:
			node.connect_to(next_layer[j])
		return true
	# try neighbors to the right only to preserve non-crossing
	var right:int = j + 1
	while right < next_layer.size():
		if can_reach[next_r][right]:
			if next_layer[right] not in node.next_nodes:
				node.connect_to(next_layer[right])
			return true
		right += 1
	return false

func _enforce_degree_cap(_layers:Array, max_out_degree:int) -> void:
	for r in _layers.size() - 1:
		for node in _layers[r]:
			if node.next_nodes.size() <= max_out_degree:
				continue
			# sort targets by row index (monotone left-to-right)
			var targets:Array = node.next_nodes.duplicate()
			targets.sort_custom(Callable(self, "_compare_node_row"))
			# keep the first max_out_degree
			var to_keep := targets.slice(0, max_out_degree)
			var new_next:Array = []
			for t in node.next_nodes:
				if t in to_keep:
					new_next.append(t)
			node.next_nodes = new_next

func _compare_node_row(a, b) -> bool:
	return a.row < b.row

func log() -> void:
	for r in layers.size():
		print("Layer r %s; size: %s:" % [r, layers[r].size()])
		for node in layers[r]:
			node.log()

func _fill_types(_layers:Array, num_layers:int, rng:RandomNumberGenerator) -> void:
	# Simple per-layer type fill with caps to avoid flooding and keep boss layer intact
	if num_layers <= 2:
		return
	# lightweight caps per run
	var max_elite:int = 3
	var max_shop:int = 3
	var max_tavern:int = 3
	var max_chest:int = 3
	var elite:=0
	var shop:=0
	var tavern:=0
	var chest:=0
	for r in range(1, num_layers - 1):
		for node in _layers[r]:
			var roll := rng.randf()
			if roll < ELITE_CHANCE && elite < max_elite:
				node.type = MapNodeScript.NodeType.ELITE
				elite += 1
				continue
			roll -= ELITE_CHANCE
			if roll < SHOP_CHANCE && shop < max_shop:
				node.type = MapNodeScript.NodeType.SHOP
				shop += 1
				continue
			roll -= SHOP_CHANCE
			if roll < TAVERN_CHANCE && tavern < max_tavern:
				node.type = MapNodeScript.NodeType.TAVERN
				tavern += 1
				continue
			roll -= TAVERN_CHANCE
			if roll < EVENT_CHANCE:
				node.type = MapNodeScript.NodeType.EVENT
				continue
			roll -= EVENT_CHANCE
			if roll < CHEST_CHANCE && chest < max_chest:
				node.type = MapNodeScript.NodeType.CHEST
				chest += 1
				continue
			node.type = MapNodeScript.NodeType.NORMAL
