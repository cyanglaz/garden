extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/enemy/bingo_ball_chill_wave.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, 0)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.SKILL)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.ENEMY)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.COLUMN)
	assert_eq(BALL_DATA.placement_rule_values, [0, 1, 2])

func test_placement_event() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	assert_true(ball_data.ball_script._has_placement_events())

func test_add_disable_to_column_spaces() -> void:
	var bingo_board := BingoBoard.new()
	bingo_board.generate()

	var ball_data := BALL_DATA.get_duplicate()
	ball_data.ball_script.bingo_board = bingo_board
	ball_data.ball_script.bingo_space_data = bingo_board.board[7]

	ball_data.ball_script._handle_placement_events()
	
	var disabled_space_indexes := [2, 12, 17, 22]
	for space_index in disabled_space_indexes:
		assert_eq(bingo_board.board[space_index].space_effect_manager.get_space_effect("disabled").stack, 1)
	
	# Remove ball to remove disable from adjacent spaces
	ball_data.ball_script._handle_removed_from_board()
	for space_index in disabled_space_indexes:
		assert_null(bingo_board.board[space_index].space_effect_manager.get_space_effect("disabled"))
	
func test_draw_event() -> void:
	var bingo_controller = autofree(double(BingoController).new())
	var game_main = autofree(GameMain.new())
	game_main._bingo_controller = bingo_controller
	Singletons.game_main = game_main

	var ball_data := BALL_DATA.get_duplicate()
	var space_data := BingoSpaceData.new()
	ball_data.ball_script.bingo_space_data = space_data
	ball_data.ball_script.bingo_space_data.index = 10
	ball_data.ball_script._handle_draw_events()
	assert_called(bingo_controller, "handle_remove_balls_from_board", [[10]])
