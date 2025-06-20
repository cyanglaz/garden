extends GutTest

# small size
func test_generate_map():
	var map_width := 9
	var map_height := 9
	for x in 100:
		var arena = Arena.new()
		var tile_counts:Dictionary
		var param := RoomParams.new()
		param.map_width = map_width
		param.map_height = map_height
		param.cluster_range = Vector2i(3, 5)
		param.level = 1
		arena.generate_map(param)
		for key in arena.map:
			var j = key/100
			if !tile_counts.has(j):
				tile_counts[j] = 0
			tile_counts[j] += 1
		for row in tile_counts:
			var count:int = tile_counts[row]
			@warning_ignore("integer_division")
			if row <= map_width/2:
				@warning_ignore("integer_division")
				assert_eq(count, (map_width - 1) - (map_width/2 - row) + 1)
			else:
				@warning_ignore("integer_division")
				assert_eq(count, map_width - (row - map_width/2) - 1 + 1)

	#if j <= half_size:
		#min_i = half_size-j
		#max_i = size - 1
	#else:
		#min_i = 0
		#max_i = size - (j - half_size) - 1

func test_navigation():
	var map_width := 9
	var map_height := 5
	for x in 10:
		var arena = Arena.new()
		var param := RoomParams.new()
		param.map_width = map_width
		param.map_height = map_height
		param.cluster_range = Vector2i(3, 5)
		param.level = 1
		arena.generate_map(param)
		assert_true(arena._exam_navigation())

func test_get_distance():
	assert_eq(Arena.get_distance(100, 101), 1)
	assert_eq(Arena.get_distance(404, 605), 3)
	assert_eq(Arena.get_distance(304, 106), 2)
	assert_eq(Arena.get_distance(601, 301), 3)
	assert_eq(Arena.get_distance(406, 703), 3)
	assert_eq(Arena.get_distance(406, 603), 3)
	assert_eq(Arena.get_distance(307, 108), 2)
