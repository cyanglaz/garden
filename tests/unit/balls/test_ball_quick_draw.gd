extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_quick_draw.tres")
const BALL_DATA_PLUS:BingoBallData = preload("res://data/balls/upgrades/bingo_ball_quick_draw+1.tres")
const LONG_BOW_BALL:BingoBallData = preload("res://data/balls/player/bingo_ball_long_bow.tres")
const WAR_BOW_BALL:BingoBallData = preload("res://data/balls/player/bingo_ball_war_bow.tres")
const CROSS_BOW_BALL:BingoBallData = preload("res://data/balls/player/bingo_ball_crossbow.tres")


func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.SKILL)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.UNCOMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.ALL)

func test_has_self_bingo_events() -> void:

	var bingo_board := BingoBoard.new()
	bingo_board.generate()

	var ball_data := BALL_DATA.get_duplicate()
	ball_data.ball_script.bingo_board = bingo_board

	var long_bow := LONG_BOW_BALL.duplicate()
	bingo_board.board[15].ball_data = long_bow

	assert_true(ball_data.ball_script._has_self_bingo_events(null))
	
func test_self_bingo_events() -> void:
	var double_bingo_controller = autofree(double(BingoController).new())
	var game_main = autofree(GameMain.new())
	game_main._bingo_controller = double_bingo_controller
	Singletons.game_main = game_main
	var bingo_board := BingoBoard.new()
	bingo_board.generate()
	var ball_data := BALL_DATA.get_duplicate()
	ball_data.ball_script.bingo_board = bingo_board
	watch_signals(ball_data.ball_script)

	var long_bow := LONG_BOW_BALL.duplicate()
	bingo_board.board[15].ball_data = long_bow

	ball_data.ball_script._handle_self_bingo_events(null)
	assert_called(double_bingo_controller, "handle_one_space_bingo", [bingo_board.board[15], null])
	assert_signal_emitted(ball_data.ball_script, "_self_bingo_event_finished")

func test_plus() -> void:
	var double_bingo_controller = autofree(double(BingoController).new())
	var game_main = autofree(GameMain.new())
	game_main._bingo_controller = double_bingo_controller
	Singletons.game_main = game_main
	var bingo_board := BingoBoard.new()
	bingo_board.generate()
	var ball_data := BALL_DATA_PLUS.get_duplicate()
	ball_data.ball_script.bingo_board = bingo_board

	var long_bow := LONG_BOW_BALL.duplicate()
	bingo_board.board[15].ball_data = long_bow

	ball_data.ball_script._handle_self_bingo_events(null)
	assert_call_count(double_bingo_controller, "handle_one_space_bingo", 2, [bingo_board.board[15], null])
