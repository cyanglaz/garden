extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_morning_star.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.COMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.COLUMN)
	assert_eq(BALL_DATA.placement_rule_values, [2, 3])

func test_has_power_up_event() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	var bingo_space_data := BingoSpaceData.new()
	bingo_space_data.index = 0
	ball_data.ball_script.bingo_space_data = bingo_space_data
	assert_false(ball_data.ball_script._has_power_up(null))

	bingo_space_data.index = 2
	assert_true(ball_data.ball_script._has_power_up(null))

func test_enhance_attack() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	var bingo_space_data := BingoSpaceData.new()
	bingo_space_data.index = 0
	ball_data.ball_script.bingo_space_data = bingo_space_data
	var attack1 := Attack.new(null, 10)
	ball_data.ball_script.enhance_attack(null, attack1)
	assert_eq(attack1.damage, 10)

	bingo_space_data.index = 2
	var attack2 := Attack.new(null, 10)
	ball_data.ball_script.enhance_attack(null, attack2)
	assert_eq(attack2.damage, 10 + (ball_data.data["dmg"] as int))
