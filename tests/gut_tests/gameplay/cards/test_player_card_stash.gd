extends GutTest

class FakeToolManager extends ToolManager:
	var moved_cards: Array = []

	func _init():
		super([], null)

	func move_hand_card_to_top_of_draw_pile(tool_data: ToolData) -> void:
		moved_cards.append(tool_data)
		await Util.await_for_tiny_time()


class FakeCombatMain extends CombatMain:
	func _init():
		tool_manager = FakeToolManager.new()


func _make_tool_data(cost: int) -> ToolData:
	var td := ToolData.new()
	autofree(td)
	td.energy_cost = cost
	return td


func _make_combat_main() -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	return cm


func test_need_select_field_is_false() -> void:
	assert_false(ToolScriptStash.new().need_select_field())


func test_has_field_action_is_false() -> void:
	assert_false(ToolScriptStash.new().has_field_action())


func test_number_of_secondary_cards_to_select_is_one() -> void:
	assert_eq(ToolScriptStash.new().number_of_secondary_cards_to_select(), 1)


func test_get_card_selection_type_is_restricted() -> void:
	assert_eq(ToolScriptStash.new().get_card_selection_type(), ActionData.CardSelectionType.RESTRICTED)


func test_apply_tool_sets_turn_energy_modifier_to_negate_cost() -> void:
	var selected := _make_tool_data(2)
	var cm := _make_combat_main()
	await ToolScriptStash.new().apply_tool(cm, null, [selected])
	assert_eq(selected.turn_energy_modifier, -2)


func test_apply_tool_zero_cost_card_modifier_stays_zero() -> void:
	var selected := _make_tool_data(0)
	var cm := _make_combat_main()
	await ToolScriptStash.new().apply_tool(cm, null, [selected])
	assert_eq(selected.turn_energy_modifier, 0)


func test_apply_tool_moves_card_to_draw_pile() -> void:
	var selected := _make_tool_data(1)
	var cm := _make_combat_main()
	await ToolScriptStash.new().apply_tool(cm, null, [selected])
	var fake_manager := cm.tool_manager as FakeToolManager
	assert_eq(fake_manager.moved_cards.size(), 1)
	assert_eq(fake_manager.moved_cards[0], selected)


func test_apply_tool_final_cost_is_zero_after_stash() -> void:
	var selected := _make_tool_data(3)
	var cm := _make_combat_main()
	await ToolScriptStash.new().apply_tool(cm, null, [selected])
	assert_eq(selected.get_final_energy_cost(), 3 + (-3))
