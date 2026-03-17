extends GutTest

# ----- Stubs -----

class FakeDeck:
	var hand: Array = []

class FakeToolManager:
	var tool_deck := FakeDeck.new()

class FakeCombatMain:
	var tool_manager := FakeToolManager.new()

# ----- Helpers -----

func _make_runoff_tool() -> ToolData:
	var td := ToolData.new()
	td.id = "runoff"
	var water_action := ActionData.new()
	water_action.type = ActionData.ActionType.WATER
	water_action.operator_type = ActionData.OperatorType.INCREASE
	water_action.value = 2
	td.actions.append(water_action)
	return td

func _make_tool(id: String, energy_cost: int = 1) -> ToolData:
	var td := ToolData.new()
	td.id = id
	td.energy_cost = energy_cost
	return td

func _make_status(stack_count: int) -> PlayerStatusSustainability:
	var s := add_child_autofree(PlayerStatusSustainability.new())
	s.data = StatusData.new()
	s.stack = stack_count
	return s

# ----- has_card_added_to_hand_hook -----

func test_has_hand_hook_true_with_runoff() -> void:
	var s := add_child_autofree(PlayerStatusSustainability.new())
	assert_true(s.has_card_added_to_hand_hook([_make_runoff_tool()]))

func test_has_hand_hook_false_without_runoff() -> void:
	var s := add_child_autofree(PlayerStatusSustainability.new())
	assert_false(s.has_card_added_to_hand_hook([_make_tool("watering_can")]))

func test_has_hand_hook_false_for_empty_array() -> void:
	var s := add_child_autofree(PlayerStatusSustainability.new())
	assert_false(s.has_card_added_to_hand_hook([]))

# ----- has_activation_hook -----

func test_has_activation_hook_true_with_runoff_in_hand() -> void:
	var s := add_child_autofree(PlayerStatusSustainability.new())
	var cm := FakeCombatMain.new()
	cm.tool_manager.tool_deck.hand = [_make_runoff_tool()]
	assert_true(s.has_activation_hook(cm))

func test_has_activation_hook_false_with_empty_hand() -> void:
	var s := add_child_autofree(PlayerStatusSustainability.new())
	var cm := FakeCombatMain.new()
	cm.tool_manager.tool_deck.hand = []
	assert_false(s.has_activation_hook(cm))

# ----- handle_card_added_to_hand_hook -----

func test_handle_card_added_sets_sustainability_modifier_on_runoff() -> void:
	var s := _make_status(3)
	var runoff := _make_runoff_tool()
	await s.handle_card_added_to_hand_hook([runoff])
	assert_eq(runoff.data["sustainability"], 3)

func test_handle_card_added_updates_runoff_water_action_modified_value() -> void:
	var s := _make_status(3)
	var runoff := _make_runoff_tool()
	await s.handle_card_added_to_hand_hook([runoff])
	assert_eq(runoff.actions[0].modified_value, 3)

func test_handle_card_added_does_not_modify_non_runoff() -> void:
	var s := _make_status(3)
	var other := _make_tool("watering_can")
	var runoff := _make_runoff_tool()
	await s.handle_card_added_to_hand_hook([other, runoff])
	assert_false(other.data.has("sustainability"))

func test_handle_card_added_increments_on_second_call() -> void:
	var s := _make_status(3)
	var runoff := _make_runoff_tool()
	await s.handle_card_added_to_hand_hook([runoff])
	# Update stack and apply again — modifier should reflect new stack, not accumulate blindly
	s.stack = 5
	await s.handle_card_added_to_hand_hook([runoff])
	assert_eq(runoff.data["sustainability"], 5)
	assert_eq(runoff.actions[0].modified_value, 5)
