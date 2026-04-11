extends GutTest

# ----- Stubs -----

class FakeToolManager extends ToolManager:
	func _init() -> void:
		tool_deck = Deck.new([])

class FakeCombatMain extends CombatMain:
	pass

# ----- Helpers -----

func _make_free_water_tool() -> ToolData:
	var td := ToolData.new()
	td.id = "free_water"
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
	var s := PlayerStatusSustainability.new()
	add_child_autofree(s)
	s.data = StatusData.new()
	s.stack = stack_count
	return s

# ----- has_card_added_to_hand_hook -----

func test_has_hand_hook_true_with_free_water() -> void:
	var s := PlayerStatusSustainability.new()
	add_child_autofree(s)
	assert_true(s.has_card_added_to_hand_hook([_make_free_water_tool()]))

func test_has_hand_hook_false_without_free_water() -> void:
	var s := PlayerStatusSustainability.new()
	add_child_autofree(s)
	assert_false(s.has_card_added_to_hand_hook([_make_tool("watering_can")]))

func test_has_hand_hook_false_for_empty_array() -> void:
	var s := PlayerStatusSustainability.new()
	add_child_autofree(s)
	assert_false(s.has_card_added_to_hand_hook([]))

# ----- has_activation_hook -----

func test_has_activation_hook_true_with_free_water_in_hand() -> void:
	var s := PlayerStatusSustainability.new()
	add_child_autofree(s)
	var cm := FakeCombatMain.new()
	autofree(cm)
	var fake_tm := FakeToolManager.new()
	autofree(fake_tm)
	cm.tool_manager = fake_tm
	fake_tm.tool_deck.hand = [_make_free_water_tool()]
	assert_true(s.has_activation_hook(cm))

func test_has_activation_hook_false_with_empty_hand() -> void:
	var s := PlayerStatusSustainability.new()
	add_child_autofree(s)
	var cm := FakeCombatMain.new()
	autofree(cm)
	var fake_tm := FakeToolManager.new()
	autofree(fake_tm)
	cm.tool_manager = fake_tm
	fake_tm.tool_deck.hand = []
	assert_false(s.has_activation_hook(cm))

# ----- handle_card_added_to_hand_hook -----

func test_handle_card_added_sets_sustainability_modifier_on_free_water() -> void:
	var s := _make_status(3)
	var free_water := _make_free_water_tool()
	await s.handle_card_added_to_hand_hook([free_water], null)
	assert_eq(free_water.data["sustainability"], 3)

func test_handle_card_added_updates_free_water_water_action_modified_value() -> void:
	var s := _make_status(3)
	var free_water := _make_free_water_tool()
	await s.handle_card_added_to_hand_hook([free_water], null)
	assert_eq(free_water.actions[0].modified_value, 3)

func test_handle_card_added_does_not_modify_non_free_water() -> void:
	var s := _make_status(3)
	var other := _make_tool("watering_can")
	var free_water := _make_free_water_tool()
	await s.handle_card_added_to_hand_hook([other, free_water], null)
	assert_false(other.data.has("sustainability"))

func test_handle_card_added_increments_on_second_call() -> void:
	var s := _make_status(3)
	var free_water := _make_free_water_tool()
	await s.handle_card_added_to_hand_hook([free_water], null)
	# Update stack and apply again — modifier should reflect new stack, not accumulate blindly
	s.stack = 5
	await s.handle_card_added_to_hand_hook([free_water], null)
	assert_eq(free_water.data["sustainability"], 5)
	assert_eq(free_water.actions[0].modified_value, 5)
