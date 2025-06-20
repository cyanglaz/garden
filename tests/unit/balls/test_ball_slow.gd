extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/status/bingo_ball_slow.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, BALL_DATA.damage)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.STATUS)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.COMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.ALL)

func test_has_self_bingo_events() -> void:
	assert_true(BALL_DATA.ball_script._has_self_bingo_events(null))

func test_has_self_bingo_event_trigger_animation() -> void:
	assert_true(BALL_DATA.ball_script._has_self_bingo_event_trigger_animation())

func test_handle_self_bingo_events() -> void:
	var player = double(Player).new(BingoBallTestUtil.PLAYER_DATA)
	var game_main = autofree(GameMain.new())
	game_main._player = player
	Singletons.game_main = game_main
	var double_status_effect_manager = autofree(double(StatusEffectManager).new())
	player.status_effect_manager = double_status_effect_manager

	var ball_data := BALL_DATA.get_duplicate()
	watch_signals(ball_data.ball_script)
	ball_data.ball_script._handle_self_bingo_events(null)
	assert_called(double_status_effect_manager, "add_status_effect", [BingoBallScriptSlow.INSIGHT_DATA, ball_data.data["stack"] as int])
	assert_signal_emitted(ball_data.ball_script, "_self_bingo_event_finished")
