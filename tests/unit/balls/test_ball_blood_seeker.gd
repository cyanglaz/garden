extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_blood_seeker.tres")
const BLEED_BALL_DATA := preload("res://data/balls/status/bingo_ball_bleed.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.UNCOMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.COLUMN)
	assert_eq(BALL_DATA.placement_rule_values, [1, 2, 3])

func test_has_power_up() -> void:
	var bingo_board := BingoBoard.new()
	bingo_board.generate()

	var ball_data := BALL_DATA.get_duplicate()
	ball_data.ball_script.bingo_board = bingo_board

	# No bleed balls
	assert_false(ball_data.ball_script._has_power_up(null))

	# Has bleed balls
	var bleed_ball := BLEED_BALL_DATA.duplicate()
	bingo_board.board[15].ball_data = bleed_ball
	assert_true(ball_data.ball_script._has_power_up(null))

func test_enhance_attack() -> void:	
	var bingo_board := BingoBoard.new()
	bingo_board.generate()

	var ball_data := BALL_DATA.get_duplicate()
	ball_data.ball_script.bingo_board = bingo_board

	# No bleed balls
	var attack := Attack.new(null, 10)
	ball_data.ball_script._enhance_attack(null, attack)
	assert_eq(attack.additional_damage, 0)
	
	# 1 bleed ball
	bingo_board.board[15].ball_data = BLEED_BALL_DATA.duplicate()
	attack.additional_damage = 0
	ball_data.ball_script._enhance_attack(null, attack)
	assert_eq(attack.additional_damage, ball_data.data["dmg"] as int)

	# 2 bleed balls
	bingo_board.board[16].ball_data = BLEED_BALL_DATA.duplicate()
	attack.additional_damage = 0
	ball_data.ball_script._enhance_attack(null, attack)
	assert_eq(attack.additional_damage, (ball_data.data["dmg"] as int) * 2)
