extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/powers/bingo_ball_the_finisher.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.ALL)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.RARE)

func test_has_placement_event() -> void:
	var ball_data := BALL_DATA.duplicate()
	var bingo_board := BingoBoard.new()
	bingo_board.generate()

	ball_data.ball_script.bingo_board = bingo_board

	assert_false(ball_data.ball_script._has_placement_events())

	bingo_board.display_one_ball(BALL_DATA.get_duplicate(), 0)
	bingo_board.display_one_ball(BALL_DATA.get_duplicate(), 1)
	bingo_board.display_one_ball(BALL_DATA.get_duplicate(), 2)
	bingo_board.display_one_ball(BALL_DATA.get_duplicate(), 3)
	bingo_board.display_one_ball(ball_data, 4)

	assert_true(ball_data.ball_script._has_placement_events())

func test_has_power_up() -> void:
	var ball_data := BALL_DATA.duplicate()
	var bingo_board := BingoBoard.new()
	bingo_board.generate()

	ball_data.ball_script.bingo_board = bingo_board

	assert_false(ball_data.ball_script._has_power_up(null))

	assert_false(ball_data.ball_script._has_placement_events())

	bingo_board.display_one_ball(BALL_DATA.get_duplicate(), 0)
	bingo_board.display_one_ball(BALL_DATA.get_duplicate(), 1)
	bingo_board.display_one_ball(BALL_DATA.get_duplicate(), 2)
	bingo_board.display_one_ball(BALL_DATA.get_duplicate(), 3)
	bingo_board.display_one_ball(ball_data, 4)

	ball_data.ball_script._handle_placement_events()
	assert_true(ball_data.ball_script._has_power_up(null))

func test_enhance_attack() -> void:
	var ball_data := BALL_DATA.duplicate()

	ball_data.ball_script._formed_bingo = false

	var attack := Attack.new(null, 10)
	ball_data.ball_script._enhance_attack(null, attack)
	assert_eq(attack.additional_damage, 0)

	ball_data.ball_script._formed_bingo = true
	ball_data.ball_script._enhance_attack(null, attack)
	assert_eq(attack.additional_damage, (ball_data.data["dmg"] as int))
