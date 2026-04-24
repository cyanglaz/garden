extends GutTest

class FakeCombatMain extends CombatMain:
	pass

func _make_trinket() -> PlayerTrinketHummingbirdFeather:
	var t := PlayerTrinketHummingbirdFeather.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"threshold"] = "6"
	td.data[&"free_move"] = "1"
	t.data = td
	return t

# ----- has_tool_application_hook -----

func test_has_tool_application_hook_always_true() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	assert_true(t.has_tool_application_hook(cm, null))

# ----- stack increments and resets -----

func test_stack_increments_before_threshold() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	t._handle_tool_application_hook(cm, null)
	assert_eq((t.data as TrinketData).stack, 1)

func test_stack_resets_at_threshold() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	var player:Player = Player.new()
	autofree(player)
	cm.player = player
	var player_status_container := PlayerStatusContainer.new()
	autofree(player_status_container)
	cm.player.player_status_container = player_status_container
	(t.data as TrinketData).stack = 5
	t._handle_tool_application_hook(cm, null)
	assert_eq((t.data as TrinketData).stack, 0)
	assert_eq(t.data.state, TrinketData.TrinketState.NORMAL)

func test_stack_does_not_reset_before_threshold() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	var player:Player = Player.new()
	autofree(player)
	cm.player = player
	(t.data as TrinketData).stack = 4
	var player_status_container := PlayerStatusContainer.new()
	autofree(player_status_container)
	cm.player.player_status_container = player_status_container
	t._handle_tool_application_hook(cm, null)
	assert_eq((t.data as TrinketData).stack, 5)

func test_state_active_when_stack_reaches_threshold_minus_one() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	var player:Player = Player.new()
	autofree(player)
	cm.player = player
	var player_status_container := PlayerStatusContainer.new()
	autofree(player_status_container)
	cm.player.player_status_container = player_status_container
	(t.data as TrinketData).stack = 4
	t._handle_tool_application_hook(cm, null)
	assert_eq(t.data.state, TrinketData.TrinketState.ACTIVE)

# ----- other hooks absent -----

func test_has_no_start_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_start_turn_hook(null))

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))

func test_has_no_draw_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_draw_hook(null, []))

func test_has_no_discard_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_discard_hook(null, []))
