extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_soul_eater.tres")
const PLAYER_BALL:BingoBallData = preload("res://data/balls/starting/bingo_ball_sword.tres")
const ENEMY_BALL:BingoBallData = preload("res://data/balls/enemy/bingo_ball_claw.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.RARE)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.ALL)

func test_has_placement_events() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	
	var board := BingoBoard.new()
	board.generate()
	ball_data.ball_script.bingo_board = board
	ball_data.ball_script.bingo_space_data = board.board[2]
	assert_false(ball_data.ball_script._has_placement_events())

	var player := Player.new(BingoBallTestUtil.PLAYER_DATA)
	var enemy := Enemy.new(BingoBallTestUtil.ENEMY_DATA)
	_add_balls_to_the_board(ball_data, board, player, enemy)
	assert_true(ball_data.ball_script._has_placement_events())

func test_handle_placement_events() -> void:
	var double_bingo_controller = autofree(double(BingoController).new())
	var game_main = autofree(GameMain.new())
	game_main._bingo_controller = double_bingo_controller
	Singletons.game_main = game_main

	var ball_data := BALL_DATA.get_duplicate()
	var board := BingoBoard.new()
	board.generate()
	var player := Player.new(BingoBallTestUtil.PLAYER_DATA)
	var enemy := Enemy.new(BingoBallTestUtil.ENEMY_DATA)
	_add_balls_to_the_board(ball_data, board, player, enemy)
	ball_data.ball_script._handle_placement_events()
	assert_called(double_bingo_controller, "handle_remove_balls_from_board", [[3, 4]])

func test_update_self_after_placement_events() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	var removed_ball_count := 2
	ball_data.ball_script._update_self(removed_ball_count)
	var damage_per_removed_ball := ball_data.data["dmg"] as int
	assert_eq(ball_data.combat_dmg_boost, damage_per_removed_ball * removed_ball_count)
	assert_eq(ball_data.data["total"], str("(",damage_per_removed_ball * removed_ball_count,")"))
	assert_true(ball_data.highlight_description_keys["dmg"])
	assert_true(ball_data.highlight_description_keys["total"])

func test_update_self_after_placement_events_no_removal() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	var removed_ball_count := 0
	ball_data.ball_script._update_self(removed_ball_count)
	assert_eq(ball_data.combat_dmg_boost, 0)
	assert_eq(ball_data.data["total"], "")
	assert_false(ball_data.highlight_description_keys["dmg"])
	assert_false(ball_data.highlight_description_keys["total"])

func _add_balls_to_the_board(skybreaker:BingoBallData, bingo_board:BingoBoard, player:Player, enemy:Enemy) -> void:
	skybreaker.ball_script.bingo_board = bingo_board
	skybreaker.ball_script.bingo_space_data = bingo_board.board[2]
	bingo_board.board[2].ball_data = skybreaker
	
	bingo_board.board[0].ball_data = PLAYER_BALL.get_duplicate()
	bingo_board.board[0].ball_data.owner = player
	bingo_board.board[1].ball_data = PLAYER_BALL.get_duplicate()
	bingo_board.board[1].ball_data.owner = player
	bingo_board.board[3].ball_data = ENEMY_BALL.get_duplicate()
	bingo_board.board[3].ball_data.owner = enemy
	bingo_board.board[4].ball_data = ENEMY_BALL.get_duplicate()
	bingo_board.board[4].ball_data.owner = enemy
