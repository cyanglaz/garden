extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_war_hook.tres")
const ENEMY_BALL:BingoBallData = preload("res://data/balls/enemy/bingo_ball_claw.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.UNCOMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.COLUMN)
	assert_eq(BALL_DATA.placement_rule_values, [2])

func test_has_placement_events() -> void:
	var board := BingoBoard.new()
	board.generate()

	var ball_data := BALL_DATA.get_duplicate()
	ball_data.ball_script.bingo_board = board
	ball_data.ball_script.bingo_space_data = board.board[0]

	# No other balls
	assert_false(ball_data.ball_script._has_placement_events())

	# One other ball in the same column
	board.display_one_ball(ENEMY_BALL, 5)
	assert_false(ball_data.ball_script._has_placement_events())

	# One other ball in a different column
	board.display_one_ball(ENEMY_BALL, 4)
	assert_true(ball_data.ball_script._has_placement_events())

func test_placement_events() -> void:
	var double_bingo_controller = autofree(double(BingoController).new())
	var game_main = autofree(GameMain.new())
	game_main._bingo_controller = double_bingo_controller
	Singletons.game_main = game_main
	var board := BingoBoard.new()
	board.generate()
	
	var ball_data := BALL_DATA.get_duplicate()
	ball_data.ball_script.bingo_board = board
	ball_data.ball_script.bingo_space_data = board.board[0]

	# One other ball in a different column
	board.display_one_ball(ENEMY_BALL, 4)
	assert_true(ball_data.ball_script._has_placement_events())

	ball_data.ball_script._handle_placement_events()
	assert_called(double_bingo_controller, "handle_move_balls")
