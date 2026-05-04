extends GutTest


class FakeToolManager extends ToolManager:
	var update_calls: Array = []

	func _init(hand: Array) -> void:
		super([], null)
		tool_deck.hand = hand

	func update_tool_card(tool_data: ToolData, new_tool_data: ToolData) -> void:
		update_calls.append([tool_data, new_tool_data.get_duplicate()])


class FakeCombatMain extends CombatMain:
	func _init(hand: Array) -> void:
		tool_manager = FakeToolManager.new(hand)


func _make_tool(id: String) -> ToolData:
	var tool := ToolData.new()
	tool.id = id
	autofree(tool)
	return tool


func _make_empty_bottle() -> ToolData:
	var tool := _make_tool("empty_bottle")
	tool.energy_cost = 1
	tool.actions = [ActionData.new()]
	tool.specials = [ToolData.Special.COMPOST]
	return tool


func _make_combat_main(hand: Array) -> FakeCombatMain:
	var cm := FakeCombatMain.new(hand)
	autofree(cm)
	return cm


func test_refill_turns_empty_bottle_into_bottled_water() -> void:
	var empty_bottle := _make_empty_bottle()
	var cm := _make_combat_main([empty_bottle])

	await ToolScriptRefill.new().apply_tool(cm, null, [])

	assert_eq(empty_bottle.id, "bottled_water")
	assert_eq(empty_bottle.energy_cost, 0)


func test_refill_updates_tool_card_for_each_empty_bottle() -> void:
	var first := _make_empty_bottle()
	var second := _make_empty_bottle()
	var cm := _make_combat_main([first, second])
	var fake_manager := cm.tool_manager as FakeToolManager

	await ToolScriptRefill.new().apply_tool(cm, null, [])

	assert_eq(fake_manager.update_calls.size(), 2)
	assert_eq((fake_manager.update_calls[0][0] as ToolData).id, "bottled_water")
	assert_eq((fake_manager.update_calls[1][0] as ToolData).id, "bottled_water")
	assert_eq((fake_manager.update_calls[0][1] as ToolData).id, "bottled_water")
	assert_eq((fake_manager.update_calls[1][1] as ToolData).id, "bottled_water")


func test_refill_ignores_non_empty_bottle_cards() -> void:
	var empty_bottle := _make_empty_bottle()
	var other_tool := _make_tool("solar_battery")
	var cm := _make_combat_main([empty_bottle, other_tool])
	var fake_manager := cm.tool_manager as FakeToolManager

	await ToolScriptRefill.new().apply_tool(cm, null, [])

	assert_eq(empty_bottle.id, "bottled_water")
	assert_eq(other_tool.id, "solar_battery")
	assert_eq(fake_manager.update_calls.size(), 1)


func test_refill_does_nothing_when_hand_has_no_empty_bottles() -> void:
	var other_tool := _make_tool("solar_battery")
	var cm := _make_combat_main([other_tool])
	var fake_manager := cm.tool_manager as FakeToolManager

	await ToolScriptRefill.new().apply_tool(cm, null, [])

	assert_eq(other_tool.id, "solar_battery")
	assert_eq(fake_manager.update_calls.size(), 0)
