extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_low_kick.tres")
const ENEMY_BALL:BingoBallData = preload("res://data/balls/enemy/bingo_ball_claw.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.UNCOMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.ROW)
	assert_eq(BALL_DATA.placement_rule_values, [2, 3])

func test_has_placement_events() -> void:
	var board := BingoBoard.new()
	board.generate()

	var ball_data := BALL_DATA.get_duplicate()
	ball_data.ball_script.bingo_board = board
	var enemy := Enemy.new(BingoBallTestUtil.ENEMY_DATA)

	# Enemy ball in row 5
	var enemy_ball1 := ENEMY_BALL.get_duplicate()
	enemy_ball1.owner = enemy
	board.display_one_ball(enemy_ball1, 22)
	assert_false(ball_data.ball_script._has_placement_events())

	# Has enemy ball in row 1
	var enemy_ball2 := ENEMY_BALL.get_duplicate()
	enemy_ball2.owner = enemy
	board.display_one_ball(enemy_ball2, 1)
	assert_true(ball_data.ball_script._has_placement_events())

func test_handle_placement_events() -> void:
	var double_bingo_controller = autofree(double(BingoController).new())
	var game_main = autofree(GameMain.new())
	game_main._bingo_controller = double_bingo_controller
	Singletons.game_main = game_main

	var board := BingoBoard.new()
	board.generate()

	var ball_data := BALL_DATA.get_duplicate()
	ball_data.ball_script.bingo_board = board
	var enemy := Enemy.new(BingoBallTestUtil.ENEMY_DATA)
	var enemy_ball2 := ENEMY_BALL.get_duplicate()
	enemy_ball2.owner = enemy
	board.display_one_ball(enemy_ball2, 1)

	ball_data.ball_script._handle_placement_events()
	assert_called(double_bingo_controller, "handle_move_balls")
