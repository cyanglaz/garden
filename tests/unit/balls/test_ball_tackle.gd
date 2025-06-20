extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_tackle.tres")
const PLAYER_BALL:BingoBallData = preload("res://data/balls/starting/bingo_ball_sword.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.COMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.ROW)
	assert_eq(BALL_DATA.placement_rule_values, [3, 4])

func test_has_all_bingo_events() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	
	var bingo_balls := [PLAYER_BALL.get_duplicate(), PLAYER_BALL.get_duplicate(), PLAYER_BALL.get_duplicate(), PLAYER_BALL.get_duplicate(), PLAYER_BALL.get_duplicate()]
	var bingo_result := BingoBallTestUtil.create_bingo_result(bingo_balls, BingoResult.BingoType.ROW, [0, 1, 2, 3, 4])
	assert_false(ball_data.ball_script.has_all_bingo_events(bingo_result))

	bingo_result = BingoBallTestUtil.create_bingo_result(bingo_balls, BingoResult.BingoType.ROW, [20, 21, 22, 23,24])
	assert_true(ball_data.ball_script.has_all_bingo_events(bingo_result))

func test_handle_all_bingo_events() -> void:
	var double_bingo_controller = autofree(double(BingoController).new())
	var game_main = autofree(GameMain.new())
	game_main._bingo_controller = double_bingo_controller
	Singletons.game_main = game_main

	var ball_data := BALL_DATA.get_duplicate()
	var bingo_space_data := BingoSpaceData.new()
	ball_data.ball_script.bingo_space_data = bingo_space_data
	ball_data.ball_script._handle_all_bingo_events()
	assert_called(double_bingo_controller, "handle_one_space_bingo", [ball_data.ball_script.bingo_space_data, null])
