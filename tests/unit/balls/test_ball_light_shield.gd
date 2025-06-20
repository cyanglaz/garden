extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/starting/bingo_ball_light_shield.tres")
const ENEMY_BALL_DATA:BingoBallData = preload("res://data/balls/enemy/bingo_ball_claw.tres")
const PLAYER_BALL_DATA:BingoBallData = preload("res://data/balls/starting/bingo_ball_sword.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, 0)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.SKILL)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.COMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.ALL)

func test_bingo_event_when_next_is_enemy_attack() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	watch_signals(ball_data.ball_script)
	var enemy_ball := ENEMY_BALL_DATA.duplicate()
	var enemy:= Enemy.new(BingoBallTestUtil.ENEMY_DATA)
	enemy_ball.owner = enemy
	var player:Player = Player.new(BingoBallTestUtil.PLAYER_DATA)
	var player_ball_data1 := PLAYER_BALL_DATA.get_duplicate()
	player_ball_data1.owner = player
	var player_ball_data2 := PLAYER_BALL_DATA.get_duplicate()
	player_ball_data2.owner = player
	var player_ball_data3 := PLAYER_BALL_DATA.get_duplicate()
	player_ball_data3.owner = player
	
	var bingo_result := BingoBallTestUtil.create_bingo_result([ball_data, enemy_ball, player_ball_data1, player_ball_data2, player_ball_data3], BingoResult.BingoType.ROW)
	assert_true(ball_data.ball_script._has_self_bingo_events(bingo_result))
	assert_true(ball_data.ball_script._has_self_bingo_event_trigger_animation())
	ball_data.ball_script._handle_self_bingo_events(bingo_result)
	assert_eq(enemy_ball.damage, ENEMY_BALL_DATA.damage - (ball_data.data["dmg"] as int))
	assert_ne(player_ball_data1.damage, PLAYER_BALL_DATA.damage - (ball_data.data["dmg"] as int))
	assert_ne(player_ball_data2.damage, PLAYER_BALL_DATA.damage - (ball_data.data["dmg"] as int))
	assert_ne(player_ball_data3.damage, PLAYER_BALL_DATA.damage - (ball_data.data["dmg"] as int))
	assert_signal_emitted(ball_data.ball_script, "_self_bingo_event_finished")

func test_bingo_event_when_a_player_ball_is_between_shild_and_enemy_ball() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	var enemy_ball := ENEMY_BALL_DATA.duplicate()
	var enemy:= Enemy.new(BingoBallTestUtil.ENEMY_DATA)
	enemy_ball.owner = enemy
	var player:Player = Player.new(BingoBallTestUtil.PLAYER_DATA)
	var player_ball_data1 := PLAYER_BALL_DATA.get_duplicate()
	player_ball_data1.owner = player
	var player_ball_data2 := PLAYER_BALL_DATA.get_duplicate()
	player_ball_data2.owner = player
	var player_ball_data3 := PLAYER_BALL_DATA.get_duplicate()
	player_ball_data3.owner = player
	
	var bingo_result := BingoBallTestUtil.create_bingo_result([ball_data, player_ball_data1, enemy_ball, player_ball_data2, player_ball_data3], BingoResult.BingoType.ROW)
	assert_true(ball_data.ball_script._has_self_bingo_events(bingo_result))
	assert_true(ball_data.ball_script._has_self_bingo_event_trigger_animation())
	ball_data.ball_script._handle_self_bingo_events(bingo_result)
	assert_eq(enemy_ball.damage, ENEMY_BALL_DATA.damage - (ball_data.data["dmg"] as int))
	assert_ne(player_ball_data1.damage, PLAYER_BALL_DATA.damage - (ball_data.data["dmg"] as int))
	assert_ne(player_ball_data2.damage, PLAYER_BALL_DATA.damage - (ball_data.data["dmg"] as int))
	assert_ne(player_ball_data3.damage, PLAYER_BALL_DATA.damage - (ball_data.data["dmg"] as int))
