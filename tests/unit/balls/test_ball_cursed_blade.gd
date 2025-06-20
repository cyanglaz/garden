extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_cursed_blade.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.COMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.COLUMN)
	assert_eq(BALL_DATA.placement_rule_values, [2, 3, 4])

func test_has_draw_events() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	assert_true(ball_data.ball_script._has_draw_events(0))
	assert_false(ball_data.ball_script._has_draw_events(1))
	assert_true(ball_data.ball_script._has_draw_events(2))

func test_draw_event() -> void:
	var ball_data := BALL_DATA.get_duplicate()

	var game_main = autofree(GameMain.new())
	var double_bingo_controller = autofree(double(BingoController).new())
	game_main._bingo_controller = double_bingo_controller
	Singletons.game_main = game_main

	var bingo_space := BingoSpaceData.new()
	bingo_space.index = 5
	ball_data.ball_script.bingo_space_data = bingo_space

	ball_data.ball_script._handle_draw_events()
	assert_called(double_bingo_controller, "summon_balls_from_space", [[BingoBallScriptCursedBlade.BLEED_BALL_DATA], 5, -1])
