extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_crossblade.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.RARE)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.PRIORITIZE_CENTER)

func test_has_power_up_event() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	assert_false(ball_data.ball_script._has_power_up(null))


	var other_ball_1 := BALL_DATA.get_duplicate()
	var other_ball_2 := BALL_DATA.get_duplicate()
	var other_ball_3 := BALL_DATA.get_duplicate()
	var other_ball_4 := BALL_DATA.get_duplicate()

	# No corner spaces
	var bingo_result := BingoBallTestUtil.create_bingo_result([ball_data, other_ball_1, other_ball_2, other_ball_3, other_ball_4], BingoResult.BingoType.ROW)
	bingo_result.spaces[0].index = 1
	bingo_result.spaces[1].index = 2
	bingo_result.spaces[2].index = 3
	bingo_result.spaces[3].index = 5
	bingo_result.spaces[4].index = 6
	assert_false(ball_data.ball_script._has_power_up(bingo_result))

	# Has corner spaces
	bingo_result.spaces[1].index = 0
	assert_true(ball_data.ball_script._has_power_up(bingo_result))

func _test_enhance_attack() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	assert_false(ball_data.ball_script._has_power_up(null))


	var other_ball_1 := BALL_DATA.get_duplicate()
	var other_ball_2 := BALL_DATA.get_duplicate()
	var other_ball_3 := BALL_DATA.get_duplicate()
	var other_ball_4 := BALL_DATA.get_duplicate()

	# 1 corner space
	var bingo_result := BingoBallTestUtil.create_bingo_result([ball_data, other_ball_1, other_ball_2, other_ball_3, other_ball_4], BingoResult.BingoType.ROW)
	bingo_result.spaces[0].index = 1
	bingo_result.spaces[1].index = 0
	bingo_result.spaces[2].index = 3
	bingo_result.spaces[3].index = 5
	bingo_result.spaces[4].index = 6
	var attack := Attack.new(null, 10)
	ball_data.ball_script.enhance_attack(bingo_result, attack)
	assert_eq(attack.damage, 10 + (ball_data.data["dmg"] as int))

	# 2 corner spaces
	bingo_result.spaces[0].index = 1
	bingo_result.spaces[1].index = 0
	bingo_result.spaces[2].index = 4
	bingo_result.spaces[3].index = 3
	bingo_result.spaces[4].index = 6
	ball_data.ball_script.enhance_attack(bingo_result, attack)
	assert_eq(attack.damage, 10 + (ball_data.data["dmg"] as int) * 2)

	# Self is corner space does not count
	bingo_result.spaces[0].index = 0
	bingo_result.spaces[1].index = 1
	bingo_result.spaces[2].index = 4
	bingo_result.spaces[3].index = 3
	bingo_result.spaces[4].index = 6
	ball_data.ball_script.enhance_attack(bingo_result, attack)
	assert_eq(attack.damage, 10 + (ball_data.data["dmg"] as int))
