extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/enemy/bingo_ball_gaze.tres")
const PLAYER_BALL:BingoBallData = preload("res://data/balls/starting/bingo_ball_sword.tres")
const ENEMY_BALL:BingoBallData = preload("res://data/balls/enemy/bingo_ball_claw.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.SKILL)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.ENEMY)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.ALL)

func test_has_placement_events() -> void:
	var ball_data := BALL_DATA.get_duplicate()
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
	assert_called(double_bingo_controller, "handle_remove_balls_from_board", [[0, 1, 3, 4]])

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
