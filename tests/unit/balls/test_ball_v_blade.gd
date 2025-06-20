extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_v_blade.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.UNCOMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.COLUMN)
	assert_eq(BALL_DATA.placement_rule_values, [2, 3, 4])

func test_handle_player_lost_hp() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	var damage := Damage.new(0, 0)
	ball_data.ball_script._handle_player_lost_hp(damage)
	assert_eq(ball_data.combat_dmg_boost, 0)

	damage.damage_received = 10
	ball_data.ball_script._handle_player_lost_hp(damage)
	assert_eq(ball_data.combat_dmg_boost, ball_data.data["dmg"] as int)

func test_evaluate_for_description() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	ball_data.ball_script.evaluate_for_description()
	assert_eq(ball_data.data["total"], "(+0)")
	assert_false(ball_data.highlight_description_keys["total"])

	ball_data.ball_script._number_increased = 1
	ball_data.ball_script.evaluate_for_description()
	assert_eq(ball_data.data["total"], str("(+",(ball_data.data["dmg"] as int) * ball_data.ball_script._number_increased,")"))
	assert_true(ball_data.highlight_description_keys["total"])
