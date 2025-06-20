extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_lance.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.COLUMN)
	assert_eq(BALL_DATA.placement_rule_values, [1, 2, 3])
