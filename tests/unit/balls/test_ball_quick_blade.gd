extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_quick_blade.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_trigger_times() -> void:
	assert_eq(BALL_DATA.trigger_times, BALL_DATA.trigger_times)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.COMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.COLUMN)
	assert_eq(BALL_DATA.placement_rule_values, [2, 3, 4])
