extends GutTest

class FakeToolManager extends ToolManager:
	var moved_cards: Array = []

	func _init():
		super([], null)

	func move_hand_card_to_top_of_draw_pile(tool_data: ToolData, _combat_main: CombatMain) -> void:
		moved_cards.append(tool_data)
		await Util.await_for_tiny_time()


class FakeCombatMain extends CombatMain:
	func _init():
		tool_manager = FakeToolManager.new()


func _make_tool_data(cost: int) -> ToolData:
	var td := ToolData.new()
	var action := ActionData.new()
	td.actions.append(action)
	autofree(td)
	td.energy_cost = cost
	return td


func _make_combat_main() -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	return cm

func test_number_of_secondary_cards_to_select_is_one() -> void:
	assert_eq(ToolScriptStash.new().number_of_secondary_cards_to_select(), 1)


func test_apply_tool_sets_special_effect() -> void:
	var selected := _make_tool_data(2)
	var cm := _make_combat_main()
	await ToolScriptStash.new().apply_tool(cm, null, [selected])
	assert_true(selected.special_effects.has(ToolData.SpecialEffect.STASHED))


func test_apply_tool_stashes_zero_cost_card() -> void:
	var selected := _make_tool_data(0)
	var cm := _make_combat_main()
	await ToolScriptStash.new().apply_tool(cm, null, [selected])
	assert_true(selected.special_effects.has(ToolData.SpecialEffect.STASHED))


func test_apply_tool_final_cost_is_zero_after_stash() -> void:
	var selected := _make_tool_data(3)
	var cm := _make_combat_main()
	await ToolScriptStash.new().apply_tool(cm, null, [selected])
	assert_eq(selected.get_final_energy_cost(), 0)

func test_apply_tool_moves_card_to_draw_pile() -> void:
	var selected := _make_tool_data(1)
	var cm := _make_combat_main()
	await ToolScriptStash.new().apply_tool(cm, null, [selected])
	var fake_manager := cm.tool_manager as FakeToolManager
	assert_eq(fake_manager.moved_cards.size(), 1)
	assert_eq(fake_manager.moved_cards[0], selected)


func test_special_effect_survives_refresh_for_turn() -> void:
	var selected := _make_tool_data(2)
	selected.special_effects.append(ToolData.SpecialEffect.STASHED)
	selected.refresh_for_turn()
	assert_true(selected.special_effects.has(ToolData.SpecialEffect.STASHED))

func test_special_effect_cleared_by_refresh_for_level() -> void:
	var selected := _make_tool_data(2)
	selected.special_effects.append(ToolData.SpecialEffect.STASHED)
	selected.refresh_for_level()
	assert_false(selected.special_effects.has(ToolData.SpecialEffect.STASHED))
