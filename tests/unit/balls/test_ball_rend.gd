extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/enemy/bingo_ball_rend.tres")
const BLEED_BALL_DATA := preload("res://data/balls/status/bingo_ball_bleed.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.ENEMY)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.ROW)
	assert_eq(BALL_DATA.placement_rule_values, [1, 2, 3])

func test_has_power_up() -> void:
	var ball_data := BALL_DATA.get_duplicate()

	var other_ball_1 := BALL_DATA.get_duplicate()
	var other_ball_2 := BALL_DATA.get_duplicate()
	var other_ball_3 := BALL_DATA.get_duplicate()
	var other_ball_4 := BALL_DATA.get_duplicate()

	# No bleed balls
	var bingo_result := BingoBallTestUtil.create_bingo_result([ball_data, other_ball_1, other_ball_2, other_ball_3, other_ball_4], BingoResult.BingoType.ROW)
	assert_false(ball_data.ball_script._has_power_up(bingo_result))

	# Has bleed balls
	bingo_result.spaces[1].ball_data = BLEED_BALL_DATA.get_duplicate()
	assert_true(ball_data.ball_script._has_power_up(bingo_result))

func test_enhance_attack() -> void:
	var ball_data := BALL_DATA.get_duplicate()

	var other_ball_1 := BALL_DATA.get_duplicate()
	var other_ball_2 := BALL_DATA.get_duplicate()
	var other_ball_3 := BALL_DATA.get_duplicate()
	var other_ball_4 := BALL_DATA.get_duplicate()

	# No bleed balls
	var bingo_result := BingoBallTestUtil.create_bingo_result([ball_data, other_ball_1, other_ball_2, other_ball_3, other_ball_4], BingoResult.BingoType.ROW)

	var attack := Attack.new(null, 10)
	ball_data.ball_script._enhance_attack(bingo_result, attack)
	assert_eq(attack.additional_damage, 0)

	# Has bleed balls
	bingo_result.spaces[1].ball_data = BLEED_BALL_DATA.get_duplicate()
	attack.additional_damage = 0
	ball_data.ball_script._enhance_attack(bingo_result, attack)
	assert_eq(attack.additional_damage, (ball_data.data["dmg"] as int) * 1)

	# 2 bleed balls
	bingo_result.spaces[2].ball_data = BLEED_BALL_DATA.get_duplicate()
	attack.additional_damage = 0
	ball_data.ball_script._enhance_attack(bingo_result, attack)
	assert_eq(attack.additional_damage, (ball_data.data["dmg"] as int) * 2)

	# 3 bleed balls
	bingo_result.spaces[3].ball_data = BLEED_BALL_DATA.get_duplicate()
	attack.additional_damage = 0
	ball_data.ball_script._enhance_attack(bingo_result, attack)
	assert_eq(attack.additional_damage, (ball_data.data["dmg"] as int) * 3)

	# 4 bleed balls
	bingo_result.spaces[4].ball_data = BLEED_BALL_DATA.get_duplicate()
	attack.additional_damage = 0
	ball_data.ball_script._enhance_attack(bingo_result, attack)
	assert_eq(attack.additional_damage, (ball_data.data["dmg"] as int) * 4)
