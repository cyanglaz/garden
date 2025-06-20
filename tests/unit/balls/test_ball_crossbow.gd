extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_crossbow.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.UNCOMMON)
	
func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.COLUMN)
	assert_eq(BALL_DATA.placement_rule_values, [1, 2, 3])

func test_has_power_up_event() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	assert_false(ball_data.ball_script._has_power_up(null))


	var other_ball_1 := BALL_DATA.get_duplicate()
	var other_ball_2 := BALL_DATA.get_duplicate()
	var other_ball_3 := BALL_DATA.get_duplicate()
	var other_ball_4 := BALL_DATA.get_duplicate()

	# Row bingo
	var bingo_result := BingoBallTestUtil.create_bingo_result([ball_data, other_ball_1, other_ball_2, other_ball_3, other_ball_4], BingoResult.BingoType.ROW)
	assert_false(ball_data.ball_script._has_power_up(bingo_result))

	# Column bingo
	bingo_result.bingo_type = BingoResult.BingoType.COLUMN
	assert_false(ball_data.ball_script._has_power_up(bingo_result))

	# Diagonal bingo
	bingo_result.bingo_type = BingoResult.BingoType.DIAGONAL
	assert_true(ball_data.ball_script._has_power_up(bingo_result))

func _test_enhance_attack() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	var other_ball_1 := BALL_DATA.get_duplicate()
	var other_ball_2 := BALL_DATA.get_duplicate()
	var other_ball_3 := BALL_DATA.get_duplicate()
	var other_ball_4 := BALL_DATA.get_duplicate()

	# 1 corner space
	var bingo_result := BingoBallTestUtil.create_bingo_result([ball_data, other_ball_1, other_ball_2, other_ball_3, other_ball_4], BingoResult.BingoType.DIAGONAL)
	ball_data.ball_script.enhance_attack(bingo_result, Attack.new(null, 10))
	var attack := Attack.new(null, 10)
	assert_eq(attack.damage, 10 + (ball_data.data["dmg"] as int))
