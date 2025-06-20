extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/enemy/bingo_ball_devour.tres")
const PLAYER_BALL:BingoBallData = preload("res://data/balls/starting/bingo_ball_sword.tres")
const ENEMY_BALL:BingoBallData = preload("res://data/balls/enemy/bingo_ball_claw.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.ENEMY)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.COLUMN)
	assert_eq(BALL_DATA.placement_rule_values, [1, 2, 3])

func test_has_draw_events() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	assert_false(ball_data.ball_script._has_draw_events(1))
	assert_true(ball_data.ball_script._has_draw_events(2))
	assert_false(ball_data.ball_script._has_draw_events(3))
	assert_true(ball_data.ball_script._has_draw_events(4))

func test_handle_draw_events_remove_player_ball() -> void:
	var double_bingo_controller = autofree(double(BingoController).new())
	var game_main = autofree(GameMain.new())
	game_main._bingo_controller = double_bingo_controller
	Singletons.game_main = game_main

	var ball_data := BALL_DATA.get_duplicate()
	var board := BingoBoard.new()
	board.generate()
	ball_data.ball_script.bingo_board = board
	ball_data.ball_script.bingo_space_data = board.board[0]

	# test remove player ball
	var player := Player.new(BingoBallTestUtil.PLAYER_DATA)
	var player_ball := PLAYER_BALL.get_duplicate()
	player_ball.owner = player
	board.display_one_ball(player_ball, 2)
	ball_data.ball_script._handle_draw_events()
	assert_called(double_bingo_controller, "handle_remove_balls_from_board", [[2]])

func test_handle_draw_events_remove_enemy_ball() -> void:
	var double_bingo_controller = autofree(double(BingoController).new())
	var game_main = autofree(GameMain.new())
	game_main._bingo_controller = double_bingo_controller
	Singletons.game_main = game_main

	var ball_data := BALL_DATA.get_duplicate()
	var board := BingoBoard.new()
	board.generate()
	ball_data.ball_script.bingo_board = board
	ball_data.ball_script.bingo_space_data = board.board[0]

	# test remove enemy ball
	var enemy := Enemy.new(BingoBallTestUtil.ENEMY_DATA)
	var enemy_ball := ENEMY_BALL.get_duplicate()
	enemy_ball.owner = enemy
	board.display_one_ball(enemy_ball, 5)
	ball_data.ball_script._handle_draw_events()
	assert_called(double_bingo_controller, "handle_remove_balls_from_board", [[5]])

func test_power_up() -> void:
	var ball_data := BALL_DATA.get_duplicate()

	ball_data.ball_script._devoured_count = 1
	assert_true(ball_data.ball_script._has_power_up(null))

	ball_data.ball_script._devoured_count = 0
	assert_false(ball_data.ball_script._has_power_up(null))
	
func test_enhance_attack() -> void:
	var ball_data := BALL_DATA.get_duplicate()

	ball_data.ball_script._devoured_count = 0
	var attack := Attack.new(null, 10)
	ball_data.ball_script._enhance_attack(null, attack)
	assert_eq(attack.additional_damage, 0)

	attack.additional_damage = 0
	ball_data.ball_script._devoured_count = 1
	ball_data.ball_script._enhance_attack(null, attack)
	assert_eq(attack.additional_damage, ball_data.data["dmg"] as int)

	attack.additional_damage = 0
	ball_data.ball_script._devoured_count = 2
	ball_data.ball_script._enhance_attack(null, attack)
	assert_eq(attack.additional_damage, (ball_data.data["dmg"] as int) * 2)


func test_evaluate_for_description() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	ball_data.ball_script._devoured_count = 0
	ball_data.ball_script.evaluate_for_description()
	assert_eq(ball_data.data["total"], str("(", 0, ")"))
	assert_false(ball_data.highlight_description_keys["total"])

	ball_data.ball_script._devoured_count = 1
	ball_data.ball_script.evaluate_for_description()
	assert_eq(ball_data.data["total"], str("(", ball_data.data["dmg"] as int, ")"))
	assert_true(ball_data.highlight_description_keys["total"])

	ball_data.ball_script._devoured_count = 2
	ball_data.ball_script.evaluate_for_description()
	assert_eq(ball_data.data["total"], str("(", ball_data.data["dmg"] as int * 2, ")"))
