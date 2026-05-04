extends GutTest


class FakeCombatMain extends CombatMain:
	func _init(hand: Array) -> void:
		tool_manager = ToolManager.new([], null)
		tool_manager.tool_deck.hand = hand


func _make_tool(id: String) -> ToolData:
	var tool := ToolData.new()
	tool.id = id
	autofree(tool)
	return tool


func _make_solar_battery(modified_x_value: int) -> ToolData:
	var tool := _make_tool("solar_battery")
	var light_action := ActionData.new()
	light_action.type = ActionData.ActionType.LIGHT
	light_action.modified_x_value = modified_x_value
	tool.actions = [light_action]
	return tool


func _make_combat_main(hand: Array) -> FakeCombatMain:
	var cm := FakeCombatMain.new(hand)
	autofree(cm)
	return cm


func test_recharge_resets_solar_battery_light_action_modified_x_value() -> void:
	var solar_battery := _make_solar_battery(-2)
	var cm := _make_combat_main([solar_battery])

	ToolScriptRecharge.new().apply_tool(cm, null, [])

	assert_eq(solar_battery.actions[0].modified_x_value, 0)


func test_recharge_refreshes_changed_solar_battery_ui() -> void:
	var solar_battery := _make_solar_battery(-1)
	var cm := _make_combat_main([solar_battery])
	var refresh_calls := [0]
	solar_battery.request_refresh.connect(func(_combat_main: CombatMain) -> void: refresh_calls[0] += 1)

	ToolScriptRecharge.new().apply_tool(cm, null, [])

	assert_eq(refresh_calls[0], 1)


func test_recharge_applies_to_all_solar_batteries_in_hand() -> void:
	var first := _make_solar_battery(-1)
	var second := _make_solar_battery(-3)
	var cm := _make_combat_main([first, second])

	ToolScriptRecharge.new().apply_tool(cm, null, [])

	assert_eq(first.actions[0].modified_x_value, 0)
	assert_eq(second.actions[0].modified_x_value, 0)


func test_recharge_ignores_non_solar_battery_cards() -> void:
	var other_tool := _make_tool("light_pistol")
	var light_action := ActionData.new()
	light_action.type = ActionData.ActionType.LIGHT
	light_action.modified_x_value = -2
	other_tool.actions = [light_action]
	var cm := _make_combat_main([other_tool])

	ToolScriptRecharge.new().apply_tool(cm, null, [])

	assert_eq(other_tool.actions[0].modified_x_value, -2)
