extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_dagger.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.COMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.PRIORITIZE_CORNER)

func test_has_power_up() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	assert_false(ball_data.ball_script._has_power_up(null))
	ball_data.ball_script.evaluate_for_description()
	assert_false(ball_data.highlight_description_keys["dmg"])
	assert_false(ball_data.highlight_description_keys["corner"])

	var space_data := BingoSpaceData.new()
	space_data.index = 1
	ball_data.ball_script.bingo_space_data = space_data
	assert_false(ball_data.ball_script._has_power_up(null))
	ball_data.ball_script.evaluate_for_description()
	assert_false(ball_data.highlight_description_keys["dmg"])
	assert_false(ball_data.highlight_description_keys["corner"])

	space_data.index = 0
	ball_data.ball_script.bingo_space_data = space_data
	assert_true(ball_data.ball_script._has_power_up(null))	
	ball_data.ball_script.evaluate_for_description()
	assert_true(ball_data.highlight_description_keys["dmg"])
	assert_true(ball_data.highlight_description_keys["corner"])

func test_enhance_attack() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	var attack := Attack.new(null, 10)
	ball_data.ball_script.enhance_attack(null, attack)
	assert_eq(attack.additional_damage, 0)

	var space_data := BingoSpaceData.new()
	space_data.index = 1
	ball_data.ball_script.bingo_space_data = space_data
	ball_data.ball_script.enhance_attack(null, attack)
	assert_eq(attack.additional_damage, 0)

	space_data.index = 0
	ball_data.ball_script.bingo_space_data = space_data
	ball_data.ball_script.enhance_attack(null, attack)
	assert_eq(attack.additional_damage, ball_data.data["dmg"] as int)
