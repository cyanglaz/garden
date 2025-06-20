class_name BingoBoard
extends RefCounted

const SIZE := 5
const DISPLAY_BALL_DELAY := 0.1

var board:Array
var size:int = SIZE

func generate() -> void:
	board.clear()
	@warning_ignore("integer_division")
	for i in size:
		for j in size:
			var bingo_space_data := BingoSpaceData.new()
			bingo_space_data.bingo_board = self
			bingo_space_data.index = i * size + j
			board.append(bingo_space_data)

func get_duplicate() -> BingoBoard:
	var new_bingo_board := BingoBoard.new()
	for old_space_data:BingoSpaceData in board:
		var new_space_data := old_space_data.get_duplicate()
		new_bingo_board.board.append(new_space_data)
		new_space_data.bingo_board = new_bingo_board
	assert(new_bingo_board.board.size() == board.size(), "Board size mismatch")
	return new_bingo_board

func remove_ball(index:int) -> void:
	board[index].ball_data = null

func find_available_spaces(ball_data:BingoBallData) -> Array:
	var un_marked_spaces:Array = board.filter(func(bingo_space_data:BingoSpaceData) -> bool:
		return bingo_space_data.ball_data == null
	)
	var filtered_spaces := _filter_placement_rules(un_marked_spaces, ball_data)
	return filtered_spaces

func find_display_ball_space(ball_data:BingoBallData) -> int:
	var space:BingoSpaceData
	var available_spaces := find_available_spaces(ball_data)
	if available_spaces.is_empty():
		return -1
	available_spaces.shuffle()
	space = available_spaces.back()
	if !Constants.TEST_DISPLAYING_SEQUENCE.is_empty():
		var test_index = Constants.TEST_DISPLAYING_SEQUENCE.pop_front()
		if test_index >= 0:
			space = board[test_index]
	return space.index

func display_one_ball(ball:BingoBallData, index:int) -> void:
	var space:BingoSpaceData = board[index]
	space.ball_data = ball

func move_ball(from_index:int, to_index:int) -> void:
	var space_from:BingoSpaceData = board[from_index]
	var space_to:BingoSpaceData = board[to_index]
	space_to.ball_data = space_from.ball_data
	space_from.ball_data = null
	space_from.gui_bingo_space.refresh_with_data(space_from, false)
	space_to.gui_bingo_space.refresh_with_data(space_to, false)


func check_bingo() -> Array[BingoResult]:
	var results:Array[BingoResult] = []
	results.append_array(_check_rows())
	results.append_array(_check_columns())
	results.append_array(_check_diagonals())
	var index:int = 0
	for result:BingoResult in results:
		result.index = index
		index += 1
	return results

func _check_rows() -> Array[BingoResult]:
	var results:Array[BingoResult] = []
	for i in size:
		var row:Array[BingoSpaceData] = []
		for j in size:
			row.append(board[i * size + j])
		if row.all(func(bingo_space_data:BingoSpaceData) -> bool:
			return _space_can_bingo(bingo_space_data)
		):
			results.append(BingoResult.new(row, BingoResult.BingoType.ROW))
	return results
	
func _check_columns() -> Array[BingoResult]:
	var results:Array[BingoResult] = []
	for i in size:
		var column:Array[BingoSpaceData] = []
		for j in size:
			column.append(board[j * size + i])
		if column.all(func(bingo_space_data:BingoSpaceData) -> bool:
			return _space_can_bingo(bingo_space_data)
		):
			results.append(BingoResult.new(column, BingoResult.BingoType.COLUMN))
	return results

func _check_diagonals() -> Array[BingoResult]:
	var results:Array[BingoResult] = []
	var diagonal1:Array[BingoSpaceData] = []
	var diagonal2:Array[BingoSpaceData] = []
	for i in size:
		diagonal1.append(board[i * size + i])
		diagonal2.append(board[i * size + (size - 1 - i)])
	if diagonal1.all(func(bingo_space_data:BingoSpaceData) -> bool:
		return _space_can_bingo(bingo_space_data)
	):
		results.append(BingoResult.new(diagonal1, BingoResult.BingoType.DIAGONAL))
	if diagonal2.all(func(bingo_space_data:BingoSpaceData) -> bool:
		return _space_can_bingo(bingo_space_data)
	):
		results.append(BingoResult.new(diagonal2, BingoResult.BingoType.DIAGONAL))
	return results

#region placements
func _filter_placement_rules(space_datas:Array, bingo_ball_data:BingoBallData) -> Array:
	var filtered_space_datas:Array[BingoSpaceData] = []
	for space_data in space_datas:
		if check_space_data_fit_placement_rules(space_data, board, bingo_ball_data):
			filtered_space_datas.append(space_data)
	return filtered_space_datas

static func check_space_data_fit_placement_rules(space_data:BingoSpaceData, bingo_board:Array, bingo_ball_data:BingoBallData) -> bool:
	var values:Array = bingo_ball_data.placement_rule_values
	var fit := false
	match bingo_ball_data.placement_rule:
		BingoBallData.PlacementRule.ALL:
			fit = true
		BingoBallData.PlacementRule.ROW:
			if values.has(find_row(space_data.index)):
				fit = true
		BingoBallData.PlacementRule.COLUMN:
			if values.has(find_column(space_data.index)):
				fit = true
		BingoBallData.PlacementRule.DIAGONAL:
			if values.has(0) && is_left_diagonal(space_data.index):
				fit = true
			if values.has(1) && is_right_diagonal(space_data.index):
				fit = true
		BingoBallData.PlacementRule.CORNER:
			if is_corner(space_data.index):
				fit = true
		BingoBallData.PlacementRule.CENTER:
			if is_center(space_data.index):
				fit = true
		BingoBallData.PlacementRule.PRIORITIZE_BOTTOM:
			if is_lowest_available_row(space_data, bingo_board):
				fit = true
		BingoBallData.PlacementRule.PRIORITIZE_TOP:
			if is_highest_available_row(space_data, bingo_board):
				fit = true
		BingoBallData.PlacementRule.PRIORITIZE_CORNER:
			if has_corner_left(bingo_board):
				if is_corner(space_data.index):
					fit = true
			else:
				fit = true
		BingoBallData.PlacementRule.PRIORITIZE_EDGE:
			if has_edges_left(bingo_board):
				if is_edge(space_data.index):
					fit = true
			else:
				fit = true
		BingoBallData.PlacementRule.PRIORITIZE_CENTER:
			if has_center_left(bingo_board):
				if is_center(space_data.index):
					fit = true
			else:
				fit = true
		BingoBallData.PlacementRule.PRIORITIZE_LEFT:
			if is_left_most_column(space_data, bingo_board):
				fit = true
		BingoBallData.PlacementRule.PRIORITIZE_RIGHT:
			if is_right_most_column(space_data, bingo_board):
				fit = true
		_:
			assert(false, "Invalid placement rule")
	return fit
		

static func find_row(index:int) -> int:
	@warning_ignore("integer_division")
	return index / SIZE

static func find_column(index:int) -> int:
	return index % SIZE

static func is_left_diagonal(index:int) -> bool:
	return index % SIZE == find_row(index)

static func is_right_diagonal(index:int) -> bool:
	return index % SIZE == SIZE - 1 - find_row(index)

static func is_corner(index:int) -> bool:
	return index == 0\
		|| index == SIZE - 1\
		|| index == SIZE * (SIZE - 1)\
		|| index == SIZE * SIZE - 1

static func is_center(index:int) -> bool:
	@warning_ignore("integer_division")
	return index == SIZE * SIZE / 2

static func is_edge(index:int) -> bool:
	var row:int = find_row(index)
	var column:int = find_column(index)
	return row == 0\
		|| row == SIZE - 1\
		|| column == 0\
		|| column == SIZE - 1

static func has_corner_left(space_datas:Array) -> bool:
	for space_data in space_datas:
		if is_corner(space_data.index) && space_data.ball_data == null:
			return true
	return false

static func is_lowest_available_row(space_data:BingoSpaceData, all_spaces:Array) -> bool:
	var row:int = find_row(space_data.index)
	var lowest_row:int = SIZE - 1
	while lowest_row >= 0:
		var lowest_row_found := false
		for i in SIZE:
			var index := i + lowest_row*SIZE
			if all_spaces[index].ball_data == null:
				lowest_row_found = true
				break
		if lowest_row_found:
			break
		lowest_row -= 1
	return row == lowest_row

static func is_highest_available_row(space_data:BingoSpaceData, all_spaces:Array) -> bool:
	var row:int = find_row(space_data.index)
	if row == 0:
		return true
	for i in SIZE:
		if all_spaces[row * SIZE + i].ball_data == null:
			return false
	return true

static func is_left_most_column(space_data:BingoSpaceData, all_spaces:Array) -> bool:
	var col := find_column(space_data.index)
	if col == 0:
		return true
	for i in SIZE:
		for j in SIZE:
			var index := j * SIZE + i
			if all_spaces[index].ball_data == null:
				return false
	return true

static func is_right_most_column(space_data:BingoSpaceData, all_spaces:Array) -> bool:
	var col := find_column(space_data.index)
	if col == SIZE - 1:
		return true
	for i in SIZE:
		for j in SIZE:
			var index := j * SIZE + i
			if all_spaces[index].ball_data == null:
				return false
	return true

static func has_edges_left(all_spaces:Array) -> bool:
	for space_data in all_spaces:
		if is_edge(space_data.index) && space_data.ball_data == null:
			return true
	return false

static func has_center_left(all_spaces:Array) -> bool:
	@warning_ignore("integer_division")
	var center :BingoSpaceData = all_spaces[SIZE * SIZE / 2]
	return center.ball_data == null

func _space_can_bingo(space_data:BingoSpaceData) -> bool:
	return space_data.ball_data != null && !space_data.is_bingo_blocked_by_space_effect()


static func get_index(row:int, column:int) -> int:
	return row * SIZE + column

#endregion
