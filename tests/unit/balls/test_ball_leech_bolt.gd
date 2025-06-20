extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/enemy/bingo_ball_leech_bolt.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.ENEMY)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.COLUMN)
	assert_eq(BALL_DATA.placement_rule_values, [3, 4])

func test_has_self_bingo_events() -> void:
	assert_true(BALL_DATA.ball_script._has_self_bingo_events(null))

func test_handle_self_bingo_events() -> void:
	var enemy = double(Enemy).new(BingoBallTestUtil.ENEMY_DATA)
	var ball_data := BALL_DATA.get_duplicate()
	ball_data.owner = enemy
	ball_data.ball_script._handle_self_bingo_events(null)
	assert_called(enemy, "animate_restore_hp", [ball_data.data["hp"] as int, 0.2, true])
