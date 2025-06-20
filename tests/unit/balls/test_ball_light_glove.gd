extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_light_glove.tres")
const ATTACK_BALL:BingoBallData = preload("res://data/balls/starting/bingo_ball_sword.tres")
const SKILL_BALL:BingoBallData = preload("res://data/balls/starting/bingo_ball_light_shield.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.SKILL)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.UNCOMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.COLUMN)
	assert_eq(BALL_DATA.placement_rule_values, [2, 3, 4])

func test_has_placement_events() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	assert_true(ball_data.ball_script._has_placement_events())

func test_handle_placement_events() -> void:
	var double_bingo_controller = autofree(double(BingoController).new())
	var game_main = autofree(GameMain.new())
	game_main._bingo_controller = double_bingo_controller
	Singletons.game_main = game_main

	var ball_data := BALL_DATA.get_duplicate()
	var ball_script = partial_double(BingoBallScriptLightGlove).new()
	stub(ball_script, "_update_moving_symbols").to_return(null)
	ball_script._bingo_ball_data = ball_data
	var bingo_board := BingoBoard.new()
	bingo_board.generate()
	ball_script.bingo_board = bingo_board
	ball_script.bingo_space_data = bingo_board.board[2]
	bingo_board.board[2].ball_data = ball_data
	
	bingo_board.board[7].ball_data = ATTACK_BALL.get_duplicate()
	bingo_board.board[12].ball_data = ATTACK_BALL.get_duplicate()
	bingo_board.board[17].ball_data = ATTACK_BALL.get_duplicate()
	bingo_board.board[22].ball_data = ATTACK_BALL.get_duplicate()
	ball_script._handle_placement_events()
	assert_called(double_bingo_controller, "handle_move_balls", [[7, 12, 17, 22], [6, 11, 16, 21]])
	assert_called(ball_script, "_update_moving_symbols", [[7, 12, 17, 22]])

func test_update_moved_symbols() -> void:
	var double_bingo_controller = autofree(double(BingoController).new())
	var game_main = autofree(GameMain.new())
	game_main._bingo_controller = double_bingo_controller
	Singletons.game_main = game_main

	var ball_data := BALL_DATA.get_duplicate()
	var bingo_board := BingoBoard.new()
	bingo_board.generate()
	ball_data.ball_script.bingo_board = bingo_board
	ball_data.ball_script.bingo_space_data = bingo_board.board[2]
	bingo_board.board[2].ball_data = ball_data
	
	bingo_board.board[7].ball_data = ATTACK_BALL.get_duplicate()
	bingo_board.board[12].ball_data = ATTACK_BALL.get_duplicate()
	bingo_board.board[17].ball_data = SKILL_BALL.get_duplicate()
	bingo_board.board[22].ball_data = SKILL_BALL.get_duplicate()

	ball_data.ball_script._update_moving_symbols([7, 12, 17, 22])
	
	assert_eq(bingo_board.board[7].ball_data.combat_dmg_boost, ball_data.data["dmg"] as int)
	assert_eq(bingo_board.board[7].ball_data.data["light_glove_move_damage"], ball_data.data["dmg"] as int)
	assert_true(bingo_board.board[7].ball_data.description.ends_with("{light_glove_move_damage_text}"))

		
	assert_eq(bingo_board.board[12].ball_data.combat_dmg_boost, ball_data.data["dmg"] as int)
	assert_eq(bingo_board.board[12].ball_data.data["light_glove_move_damage"], ball_data.data["dmg"] as int)
	assert_true(bingo_board.board[12].ball_data.description.ends_with("{light_glove_move_damage_text}"))

	assert_ne(bingo_board.board[17].ball_data.combat_dmg_boost, ball_data.data["dmg"] as int)
	assert_false(bingo_board.board[17].ball_data.data.has("light_glove_move_damage"))
	assert_false(bingo_board.board[17].ball_data.description.ends_with("{light_glove_move_damage_text}"))

	assert_ne(bingo_board.board[22].ball_data.combat_dmg_boost, ball_data.data["dmg"] as int)
	assert_false(bingo_board.board[22].ball_data.data.has("light_glove_move_damage"))
	assert_false(bingo_board.board[22].ball_data.description.ends_with("{light_glove_move_damage_text}"))
