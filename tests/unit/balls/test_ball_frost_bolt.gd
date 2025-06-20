extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/enemy/bingo_ball_frost_bolt.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.ENEMY)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.COLUMN)
	assert_eq(BALL_DATA.placement_rule_values, [3, 4])

func test_has_self_bingo_events() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	assert_true(ball_data.ball_script._has_self_bingo_events(null))

func test_has_async_self_bingo_events() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	assert_true(ball_data.ball_script._has_async_self_bingo_events())

func test_handle_self_bingo_events() -> void:
	var game_main = autofree(GameMain.new())
	var double_bingo_controller = autofree(double(BingoController).new())
	game_main._bingo_controller = double_bingo_controller
	Singletons.game_main = game_main


	var ball_data := BALL_DATA.get_duplicate()
	var bingo_space := BingoSpaceData.new()
	bingo_space.index = 5
	ball_data.ball_script.bingo_space_data = bingo_space

	ball_data.ball_script._handle_self_bingo_events(null)
	assert_called(double_bingo_controller, "summon_balls_from_space", [[BingoBallScriptFrostBolt.SLOW_BALL_DATA], 5, -1])
