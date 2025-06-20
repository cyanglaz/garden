extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_boost.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, 0)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.SKILL)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.RARE)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.ALL)

func test_has_other_symbol_placement_event() -> void:
	var game_main = autofree(GameMain.new())
	var player := Player.new(BingoBallTestUtil.PLAYER_DATA)
	Singletons.game_main = game_main
	game_main._player = player
	var ball_script:BingoBallScriptBoost = BALL_DATA.ball_script as BingoBallScriptBoost

	var displayed_space := BingoSpaceData.new()
	var boost_space := BingoSpaceData.new()
	ball_script.bingo_space_data = boost_space
	# When draw box is empty
	assert_eq(ball_script._has_other_symbol_placement_events(displayed_space), false)

	# When draw pile is not empty and displayed space is in the same row
	boost_space.index = 1
	displayed_space.index = 2
	player.draw_box.insert_ball(BALL_DATA.get_duplicate())
	assert_eq(ball_script._has_other_symbol_placement_events(displayed_space), true)

	# When dicard pile is not empty and displayed space is in the same row
	player.draw_box.draw(1)
	player.draw_box.discard()
	assert_eq(ball_script._has_other_symbol_placement_events(displayed_space), true)

	# When displayed space is not in the same row
	boost_space.index = 1
	displayed_space.index = 20
	assert_eq(ball_script._has_other_symbol_placement_events(displayed_space), false)

func test_placement_event() -> void:
	var game_main = autofree(GameMain.new())
	var player := Player.new(BingoBallTestUtil.PLAYER_DATA)
	var double_bingo_controller = autofree(double(BingoController).new())
	game_main._bingo_controller = double_bingo_controller
	Singletons.game_main = game_main
	game_main._player = player
	
	var bingo_ball_data := BALL_DATA.get_duplicate()
	var ball_script:BingoBallScriptBoost = bingo_ball_data.ball_script as BingoBallScriptBoost

	var displayed_space := BingoSpaceData.new()
	var boost_space := BingoSpaceData.new()
	ball_script.bingo_space_data = boost_space
	boost_space.index = 1
	displayed_space.index = 2
	player.draw_box.insert_ball(bingo_ball_data.get_duplicate())
	ball_script._handle_other_symbol_replacement_events()
	assert_called(double_bingo_controller, "start_other_draw", [bingo_ball_data.data["card"] as int])
