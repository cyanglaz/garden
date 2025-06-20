extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_war_bow.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.COMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.PRIORITIZE_BOTTOM)

func test_enhance_attack() -> void:
	var board := BingoBoard.new()
	board.generate()

	var ball_data := BALL_DATA.get_duplicate()
	ball_data.ball_script.bingo_board = board
	ball_data.ball_script.bingo_space_data = board.board[20]

	var attack := Attack.new(null, 10)
	ball_data.ball_script._enhance_attack(null, attack)
	assert_eq(attack.additional_damage, (ball_data.data["dmg"] as int) * 4)
	
	# Block one space
	var attack2 := Attack.new(null, 10)
	board.board[10].ball_data = BALL_DATA.get_duplicate()
	ball_data.ball_script._enhance_attack(null, attack2)
	assert_eq(attack2.additional_damage, (ball_data.data["dmg"] as int) * 1)

	
