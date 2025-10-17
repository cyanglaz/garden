class_name MapGenerator
extends RefCounted

const MapNodeScript := preload("res://scenes/map/map_node.gd")

const ROW_COUNT := 10
const MIN_COLUMNS := 3
const MAX_COLUMNS := 5

const ELITE_CHANCE := 0.15
const SHOP_CHANCE := 0.1
const TAVERN_CHANCE := 0.12
const EVENT_CHANCE := 0.15
const CHEST_CHANCE := 0.08

# Configurable restrictions (now for all types)
const DEFAULT_MIN_ROW := {
	MapNodeScript.NodeType.NORMAL: 0,
	MapNodeScript.NodeType.EVENT: 1,
	MapNodeScript.NodeType.ELITE: 3,
	MapNodeScript.NodeType.SHOP: 1,
	MapNodeScript.NodeType.TAVERN: 2,
	MapNodeScript.NodeType.CHEST: 3,
	MapNodeScript.NodeType.BOSS: 0,
}

var _min_row_for_type:Dictionary = DEFAULT_MIN_ROW.duplicate(true)

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

var rows:Array = []

func generate(_chapter:int, _seed:int = 0, _restrictions:Dictionary = {}) -> void:
	rows.clear()
	var rng := RandomNumberGenerator.new()
	if _seed != 0:
		rng.seed = _seed

	# restrictions use constants in this script; _restrictions only carries seed/chapter here

	# rows/cols
	var num_rows:int = ROW_COUNT
	assert(num_rows >= 2)
	var num_cols := rng.randi_range(MIN_COLUMNS, MAX_COLUMNS)

	# track counts for all types
	var type_counts := {
		MapNodeScript.NodeType.NORMAL: 0,
		MapNodeScript.NodeType.EVENT: 0,
		MapNodeScript.NodeType.ELITE: 0,
		MapNodeScript.NodeType.SHOP: 0,
		MapNodeScript.NodeType.TAVERN: 0,
		MapNodeScript.NodeType.CHEST: 0,
		MapNodeScript.NodeType.BOSS: 0,
	}

	# create rows of nodes
	for r in num_rows:
		var row_nodes:Array = []
		var columns_this_row := num_cols
		if r == 0:
			columns_this_row = num_cols # start row
		elif r == num_rows - 1:
			columns_this_row = 1 # boss row
		else:
			columns_this_row = rng.randi_range(MIN_COLUMNS, num_cols)
		for c in columns_this_row:
			var node = MapNodeScript.new()
			node.row = r
			node.column = c
			node.type = _roll_node_type(r, num_rows, rng, type_counts)
			# increase count for restricted types
			if type_counts.has(node.type):
				type_counts[node.type] += 1
			row_nodes.append(node)
		rows.append(row_nodes)

	# ensure boss at last row
	rows[num_rows - 1][0].type = MapNodeScript.NodeType.BOSS

	# satisfy global minimum counts before connections (rough pass)
	_satisfy_min_counts(rows, type_counts, num_rows)

	# connect forward edges (each node connects to 1-2 nodes next row)
	for r in num_rows - 1:
		var current_row = rows[r]
		var next_row = rows[r + 1]
		for node in current_row:
			var targets = _pick_connections(next_row, rng)
			for t in targets:
				node.connect_to(t)

	# enforce per-path constraints by iterative adjustments
	_enforce_per_path_constraints(rows, type_counts, num_rows)

	# final global passes
	_satisfy_min_counts(rows, type_counts, num_rows)
	_enforce_global_max_counts(rows, type_counts, num_rows)

	# hard rule (path-aware): node on each path before boss is TAVERN
	_force_penultimate_row_tavern(rows, type_counts, num_rows)
	_enforce_global_max_counts(rows, type_counts, num_rows)

func _roll_node_type(r:int, num_rows:int, rng:RandomNumberGenerator, type_counts:Dictionary) -> int:
	# Row 0 is always NORMAL regardless of restrictions
	if r == 0:
		return MapNodeScript.NodeType.NORMAL
	# Last row is always BOSS regardless of restrictions
	if r == num_rows - 1:
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

func _can_place_type(t:int, row:int, type_counts:Dictionary) -> bool:
	var min_row := int(_min_row_for_type.get(t, 0))
	if row < min_row:
		return false
	var current := int(type_counts.get(t, 0))
	var max_count := int(_max_count_for_type.get(t, 999999))
	return current < max_count

func _satisfy_min_counts(_rows:Array, type_counts:Dictionary, num_rows:int) -> void:
	for t in _min_count_for_type.keys():
		var needed := int(_min_count_for_type[t]) - int(type_counts.get(t, 0))
		if needed <= 0:
			continue
		_needed_promote_type(t, needed, _rows, type_counts, num_rows)

func _needed_promote_type(t:int, needed:int, _rows:Array, type_counts:Dictionary, num_rows:int) -> void:
	if needed <= 0:
		return
	for r in _rows.size():
		if needed <= 0:
			break
		if r == 0:
			continue
		if r == num_rows - 1:
			continue
		for node in _rows[r]:
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

func _enforce_per_path_constraints(_rows:Array, type_counts:Dictionary, num_rows:int) -> void:
	var safety:int = 100
	while safety > 0:
		safety -= 1
		var adjusted:bool = false
		var paths := _get_all_paths(_rows, num_rows)
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
					var promoted:bool = _promote_on_path_to_type(path, t, min_needed - count, type_counts, num_rows)
					if promoted:
						adjusted = true
						break
				# overflow -> demote
				if count > max_allowed:
					var demoted:bool = _demote_on_path_from_type(path, t, count - max_allowed, type_counts)
					if demoted:
						adjusted = true
						break
			# Smart constraint: break disallowed consecutive types (skip penultimate row)
			if _no_consecutive_types.size() > 0:
				for i in range(1, path.size()):
					var prev = path[i - 1]
					var cur = path[i]
					if prev.row == num_rows - 2 || cur.row == num_rows - 2:
						continue
					if prev.type == cur.type && _no_consecutive_types.has(cur.type):
						# Try to modify the current node to break the consecutive
						var fixed:bool = _break_consecutive_at(path, i, type_counts, num_rows)
						if !fixed:
							# Fallback: try modify previous if possible
							fixed = _break_consecutive_at(path, i - 1, type_counts, num_rows)
						if fixed:
							adjusted = true
							break
			if adjusted:
				break
		if !adjusted:
			break

func _break_consecutive_at(path:Array, index:int, type_counts:Dictionary, num_rows:int) -> bool:
	if index < 0 || index >= path.size():
		return false
	var node = path[index]
	var r:int = node.row
	if r == 0 || r == num_rows - 1 || r == num_rows - 2:
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
		# Respect min_row and global max_count
		if !_can_place_type(target, r, type_counts):
			continue
		# Apply
		node.type = target
		type_counts[target] = int(type_counts.get(target, 0)) + 1
		type_counts[src] = int(type_counts.get(src, 0)) - 1
		return true
	return false

func _promote_on_path_to_type(path:Array, t:int, need:int, type_counts:Dictionary, num_rows:int) -> bool:
	var changed:bool = false
	for node in path:
		if need <= 0:
			break
		var r:int = node.row
		if r == 0 || r == num_rows - 1 || r == num_rows - 2:
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
		# ensure we keep global min_count for t and keep penultimate row taverns
		if node.row == ROW_COUNT - 2 && t == MapNodeScript.NodeType.TAVERN:
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

func _enforce_global_max_counts(_rows:Array, type_counts:Dictionary, num_rows:int) -> void:
	for t in _max_count_for_type.keys():
		var max_allowed := int(_max_count_for_type.get(t, 999999))
		var current := int(type_counts.get(t, 0))
		var excess := current - max_allowed
		if excess <= 0:
			continue
		for r in _rows.size():
			if excess <= 0:
				break
			for node in _rows[r]:
				if excess <= 0:
					break
				if node.type != t:
					continue
				if r == 0:
					continue
				if node.type == MapNodeScript.NodeType.BOSS:
					continue
				# keep taverns on penultimate row
				if r == num_rows - 2 && t == MapNodeScript.NodeType.TAVERN:
					continue
				var t_min := int(_min_count_for_type.get(t, 0))
				if int(type_counts.get(t, 0)) - 1 < t_min:
					continue
				node.type = MapNodeScript.NodeType.NORMAL
				type_counts[MapNodeScript.NodeType.NORMAL] = int(type_counts.get(MapNodeScript.NodeType.NORMAL, 0)) + 1
				type_counts[t] = int(type_counts.get(t, 0)) - 1
				excess -= 1

func _get_all_paths(_rows:Array, num_rows:int) -> Array:
	var paths:Array = []
	if _rows.is_empty():
		return paths
	var starts:Array = _rows[0]
	var end_node = _rows[num_rows - 1][0]
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

func _force_penultimate_row_tavern(_rows:Array, type_counts:Dictionary, num_rows:int) -> void:
	if num_rows < 2:
		return
	var row_index := num_rows - 2
	var _boss_row_index := num_rows - 1
	# Build quick set of nodes on any path at penultimate row
	var path_nodes := {}
	var paths := _get_all_paths(_rows, num_rows)
	for path in paths:
		if path.size() < 2:
			continue
		var penultimate = path[path.size() - 2]
		if penultimate.row == row_index:
			path_nodes[penultimate] = true
	# Force only path nodes on the penultimate row to TAVERN
	for node in _rows[row_index]:
		if !path_nodes.has(node):
			continue
		if node.type == MapNodeScript.NodeType.TAVERN:
			continue
		var src:int = node.type
		node.type = MapNodeScript.NodeType.TAVERN
		type_counts[MapNodeScript.NodeType.TAVERN] = int(type_counts.get(MapNodeScript.NodeType.TAVERN, 0)) + 1
		type_counts[src] = int(type_counts.get(src, 0)) - 1

func _pick_connections(next_row:Array, rng:RandomNumberGenerator) -> Array:
	var connections:Array = []
	if next_row.is_empty():
		return connections
	var first = next_row[rng.randi_range(0, next_row.size() - 1)]
	connections.append(first)
	# chance to add a second distinct connection
	if next_row.size() > 1 && rng.randf() < 0.5:
		var second = first
		var safety := 8
		while second == first && safety > 0:
			second = next_row[rng.randi_range(0, next_row.size() - 1)]
			safety -= 1
		if second != first:
			connections.append(second)
	return connections

func log() -> void:
	for r in rows.size():
		for node in rows[r]:
			node.log()

