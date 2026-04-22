extends GutTest


class FakeGUIToolCardContainer extends GUIToolCardContainer:
	func animate_discard(_tool_datas: Array, _combat_main: CombatMain) -> void:
		await Util.await_for_tiny_time()


func _make_tool_data(id: String) -> ToolData:
	var tool_data := ToolData.new()
	tool_data.id = id
	var action := ActionData.new()
	action.action_category = ActionData.ActionCategory.PLAYER
	action.type = ActionData.ActionType.ENERGY
	action.value = 0
	tool_data.actions = [action]
	autofree(tool_data)
	return tool_data


func _setup_manager_with_hand(ids: Array) -> Dictionary:
	var initial_tools: Array = []
	for id: String in ids:
		initial_tools.append(_make_tool_data(id))
	var container := FakeGUIToolCardContainer.new()
	var manager := ToolManager.new(initial_tools, container)
	# Deck._init shuffles draw_pool; reset to deterministic order for assertions.
	manager.tool_deck.draw_pool = manager.tool_deck.pool.duplicate()
	var hand: Array = manager.tool_deck.draw(ids.size())
	return {"manager": manager, "container": container, "hand": hand}


#region discard_cards

func test_discard_single_card_moves_from_hand_to_discard_pool() -> void:
	var ctx := _setup_manager_with_hand(["only"])
	var manager: ToolManager = ctx["manager"]
	var container: FakeGUIToolCardContainer = ctx["container"]
	var tool_data: ToolData = ctx["hand"][0]

	await manager.discard_cards([tool_data], null)

	assert_eq(manager.tool_deck.hand.size(), 0, "hand should be empty after discard")
	assert_eq(manager.tool_deck.discard_pool, [tool_data], "discard pool should contain the discarded tool")
	container.free()


func test_discard_multiple_cards_moves_all_once_into_discard_pool() -> void:
	# Regression: previously tool_deck.discard(tools) was called inside the
	# for-loop, so the second iteration would trip Deck.discard's
	# assert(false, "discarding item not in hand") on a multi-card discard.
	var ctx := _setup_manager_with_hand(["a", "b", "c"])
	var manager: ToolManager = ctx["manager"]
	var container: FakeGUIToolCardContainer = ctx["container"]
	var hand_snapshot: Array = ctx["hand"].duplicate()

	await manager.discard_cards(hand_snapshot, null)

	assert_eq(manager.tool_deck.hand.size(), 0, "hand should be empty after multi-card discard")
	assert_eq(manager.tool_deck.discard_pool.size(), 3, "each tool should land in discard pool exactly once")
	for tool_data: ToolData in hand_snapshot:
		assert_eq(manager.tool_deck.discard_pool.count(tool_data), 1,
			"tool %s should appear in discard pool exactly once" % tool_data.id)
	container.free()


func test_discard_refreshes_each_tool_for_turn() -> void:
	var ctx := _setup_manager_with_hand(["a", "b", "c"])
	var manager: ToolManager = ctx["manager"]
	var container: FakeGUIToolCardContainer = ctx["container"]
	var hand_snapshot: Array = ctx["hand"].duplicate()
	for tool_data: ToolData in hand_snapshot:
		tool_data.turn_energy_modifier = 5

	await manager.discard_cards(hand_snapshot, null)

	for tool_data: ToolData in hand_snapshot:
		assert_eq(tool_data.turn_energy_modifier, 0,
			"refresh_for_turn should have reset turn_energy_modifier for %s" % tool_data.id)
	container.free()


func test_discard_emits_cards_removed_from_hand_once() -> void:
	var ctx := _setup_manager_with_hand(["a", "b", "c"])
	var manager: ToolManager = ctx["manager"]
	var container: FakeGUIToolCardContainer = ctx["container"]
	var hand_snapshot: Array = ctx["hand"].duplicate()

	var emit_counter := {"value": 0}
	manager.tools_discarded.connect(
		func(_tool_datas: Variant, _explicit:bool) -> void: emit_counter["value"] += 1
	)

	await manager.discard_cards(hand_snapshot, null)

	assert_eq(emit_counter["value"], 1, "tools_discarded should fire exactly once per discard batch")
	container.free()

#endregion
