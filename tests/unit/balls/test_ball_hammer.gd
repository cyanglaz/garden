extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_hammer.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.ATTACK)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.COMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.ALL)

func test_has_self_bingo_events() -> void:
	assert_true(BALL_DATA.ball_script._has_self_bingo_events(null))

func test_handle_self_bingo_events() -> void:
	var double_enemy_controller = autofree(double(EnemyController).new())
	var enemy = double(Enemy).new(BingoBallTestUtil.ENEMY_DATA)
	stub(double_enemy_controller, "get_current_enemy").to_return(enemy)
	var game_main = autofree(GameMain.new())
	game_main.enemy_controller = double_enemy_controller
	Singletons.game_main = game_main

	var ball_data := BALL_DATA.get_duplicate()
	ball_data.ball_script._handle_self_bingo_events(null)
	assert_called(enemy, "animate_decrease_attack_counters", [ball_data.data["energy"] as int, 0.2])
