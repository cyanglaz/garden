extends GutTest


class FakeGUIToolCardContainer extends GUIToolCardContainer:
	var turn_modifiers_seen_during_discard: Array[int] = []

	func animate_discard(tool_datas: Array, _combat_main: CombatMain) -> void:
		for tool_data: ToolData in tool_datas:
			turn_modifiers_seen_during_discard.append(tool_data.turn_energy_modifier)
		await Util.await_for_tiny_time()

	func animate_exhaust(_tool_datas: Array, _combat_main: CombatMain) -> void:
		await Util.await_for_tiny_time()

	func animate_draw(_tool_datas: Array, _combat_main: CombatMain) -> void:
		await Util.await_for_tiny_time()

	func animate_shuffle(_discard_pile: Array, _combat_main: CombatMain) -> void:
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


func test_refresh_tools_refreshes_each_tool() -> void:
	var ctx := _setup_manager_with_hand(["a", "b", "c"])
	var manager: ToolManager = ctx["manager"]
	var container: FakeGUIToolCardContainer = ctx["container"]
	var pool_snapshot: Array = ctx["hand"].duplicate()
	for tool_data: ToolData in pool_snapshot:
		tool_data.turn_energy_modifier = 5
	manager.tool_deck.pool = pool_snapshot
	await manager.refresh_for_turn()

	for tool_data: ToolData in pool_snapshot:
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


func test_discard_defaults_to_explicit_true() -> void:
	var ctx := _setup_manager_with_hand(["a"])
	var manager: ToolManager = ctx["manager"]
	var container: FakeGUIToolCardContainer = ctx["container"]
	var hand_snapshot: Array = ctx["hand"].duplicate()

	var captured := {"explicitly": null}
	manager.tools_discarded.connect(
		func(_tool_datas: Variant, explicit: bool) -> void: captured["explicitly"] = explicit
	)

	await manager.discard_cards(hand_snapshot, null)

	assert_eq(captured["explicitly"], true, "discard_cards default `explicitly` should be true")
	container.free()


func test_discard_respects_explicit_false_flag() -> void:
	var ctx := _setup_manager_with_hand(["a"])
	var manager: ToolManager = ctx["manager"]
	var container: FakeGUIToolCardContainer = ctx["container"]
	var hand_snapshot: Array = ctx["hand"].duplicate()

	var captured := {"explicitly": null}
	manager.tools_discarded.connect(
		func(_tool_datas: Variant, explicit: bool) -> void: captured["explicitly"] = explicit
	)

	await manager.discard_cards(hand_snapshot, null, false)

	assert_eq(captured["explicitly"], false,
		"discard_cards should forward explicit=false (e.g. end-of-turn cleanup)")
	container.free()

#endregion


#region draw_cards

func test_draw_cards_emits_tools_drawn_with_results() -> void:
	var ctx := _setup_manager_with_hand([])
	var manager: ToolManager = ctx["manager"]
	var container: FakeGUIToolCardContainer = ctx["container"]
	var td := _make_tool_data("extra")
	manager.tool_deck.add_items_to_draw_pile([td], false)

	var emit_counter := {"value": 0, "size": -1}
	manager.tools_drawn.connect(func(tools: Array) -> void:
		emit_counter["value"] += 1
		emit_counter["size"] = tools.size())

	await manager.draw_cards(1, false, null)

	assert_eq(emit_counter["value"], 1, "tools_drawn should have fired once")
	assert_eq(emit_counter["size"], 1)
	container.free()

#endregion


#region exhaust_cards

func test_exhaust_cards_emits_tools_exhausted() -> void:
	var ctx := _setup_manager_with_hand(["a", "b"])
	var manager: ToolManager = ctx["manager"]
	var container: FakeGUIToolCardContainer = ctx["container"]
	var hand_snapshot: Array = ctx["hand"].duplicate()

	var emit_counter := {"value": 0, "size": -1}
	manager.tools_exhausted.connect(func(tools: Array) -> void:
		emit_counter["value"] += 1
		emit_counter["size"] = tools.size())

	await manager.exhaust_cards(hand_snapshot, null)

	assert_eq(emit_counter["value"], 1, "tools_exhausted should fire once via Deck re-emit")
	assert_eq(emit_counter["size"], 2)
	container.free()

#endregion
