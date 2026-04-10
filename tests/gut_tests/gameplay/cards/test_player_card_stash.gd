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
	var action := ActionData.new()
	td.actions.append(action)
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
	assert_eq(ToolScriptStash.new().get_card_selection_type(), ActionData.CardSelectionType.NON_RESTRICTED)


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


func test_apply_tool_back_card_final_cost_is_zero_after_stash() -> void:
	var selected := _make_tool_data(3)
	selected.back_card = _make_tool_data(2)
	var cm := _make_combat_main()
	await ToolScriptStash.new().apply_tool(cm, null, [selected])
	assert_eq(selected.back_card.get_final_energy_cost(), 0)


func test_apply_tool_front_card_final_cost_is_zero_after_stash() -> void:
	var front := _make_tool_data(3)
	front.back_card = _make_tool_data(2)
	var back_card := front.back_card
	var cm := _make_combat_main()
	await ToolScriptStash.new().apply_tool(cm, null, [back_card])
	assert_eq(back_card.front_card.get_final_energy_cost(), 0)


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


func test_back_card_special_effect_survives_refresh_for_turn() -> void:
	var selected := _make_tool_data(2)
	selected.back_card = _make_tool_data(1)
	selected.special_effects.append(ToolData.SpecialEffect.STASHED)
	selected.back_card.special_effects.append(ToolData.SpecialEffect.STASHED)
	selected.refresh_for_turn()
	assert_true(selected.back_card.special_effects.has(ToolData.SpecialEffect.STASHED))


func test_special_effect_cleared_by_refresh_for_level() -> void:
	var selected := _make_tool_data(2)
	selected.special_effects.append(ToolData.SpecialEffect.STASHED)
	selected.refresh_for_level()
	assert_false(selected.special_effects.has(ToolData.SpecialEffect.STASHED))


func test_back_card_special_effect_cleared_by_refresh_for_level() -> void:
	var selected := _make_tool_data(2)
	selected.back_card = _make_tool_data(1)
	selected.back_card.special_effects.append(ToolData.SpecialEffect.STASHED)
	selected.refresh_for_level()
	assert_false(selected.back_card.special_effects.has(ToolData.SpecialEffect.STASHED))


func test_apply_tool_also_stashes_back_card() -> void:
	var selected := _make_tool_data(2)
	var back := _make_tool_data(1)
	selected.back_card = back  # _set_back_card duplicates back; sets back_card.front_card = selected
	var cm := _make_combat_main()
	await ToolScriptStash.new().apply_tool(cm, null, [selected])
	assert_true(selected.back_card.special_effects.has(ToolData.SpecialEffect.STASHED))


func test_apply_tool_also_stashes_front_card() -> void:
	var front := _make_tool_data(2)
	var back_val := _make_tool_data(1)
	front.back_card = back_val  # links front.back_card.front_card = front
	var back_card := front.back_card  # the actual duplicated back card
	var cm := _make_combat_main()
	await ToolScriptStash.new().apply_tool(cm, null, [back_card])
	assert_true(back_card.front_card.special_effects.has(ToolData.SpecialEffect.STASHED))
