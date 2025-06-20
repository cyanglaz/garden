extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_health_potion.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.SKILL)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.COMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.ALL)

func test_has_self_bingo_events() -> void:
	assert_true(BALL_DATA.ball_script._has_self_bingo_events(null))

func test_handle_self_bingo_events() -> void:
	var player = double(Player).new(BingoBallTestUtil.PLAYER_DATA)
	var game_main = autofree(GameMain.new())
	game_main._player = player
	Singletons.game_main = game_main

	var ball_data := BALL_DATA.get_duplicate()
	watch_signals(ball_data.ball_script)
	ball_data.ball_script._handle_self_bingo_events(null)
	assert_called(player, "animate_restore_hp", [ball_data.data["hp"] as int, 0.2, true])
	assert_signal_emitted(ball_data.ball_script, "_self_bingo_event_finished")
