extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_cleaver.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, 6)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.COMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.ROW)
	assert_eq(BALL_DATA.placement_rule_values, [1, 2, 3])

func test_has_power_up_event() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	var other_ball_1 := BALL_DATA.get_duplicate()
	var other_ball_2 := BALL_DATA.get_duplicate()
	var other_ball_3 := BALL_DATA.get_duplicate()
	var other_ball_4 := BALL_DATA.get_duplicate()

	assert_false(ball_data.ball_script._has_power_up(null))

	var bingo_result := BingoBallTestUtil.create_bingo_result([ball_data, other_ball_1, other_ball_2, other_ball_3, other_ball_4], BingoResult.BingoType.ROW)
	assert_true(ball_data.ball_script._has_power_up(bingo_result))

func test_enhance_attack() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	var other_ball_1 := BALL_DATA.get_duplicate()
	var other_ball_2 := BALL_DATA.get_duplicate()
	var other_ball_3 := BALL_DATA.get_duplicate()
	var other_ball_4 := BALL_DATA.get_duplicate()

	var bingo_result := BingoBallTestUtil.create_bingo_result([ball_data, other_ball_1, other_ball_2, other_ball_3, other_ball_4], BingoResult.BingoType.ROW)
	var attack := Attack.new(null, 10)
	ball_data.ball_script.enhance_attack(bingo_result, attack)
	assert_eq(attack.damage, 10 + (ball_data.data["dmg"] as int))
