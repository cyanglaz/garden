extends GutTest

# Tests for ToolApplier.can_tool_be_applied() and queue_tool_application().
# These cover the branch of tool_applier that was introduced to decide, before
# pushing anything on the combat queue, whether a RESTRICTED tool_script has
# enough candidate cards to run.


class _ScriptNoSelection extends ToolScript:
	func number_of_secondary_cards_to_select() -> int:
		return 0


class _ScriptRestrictedNeedsTwo extends ToolScript:
	func number_of_secondary_cards_to_select() -> int:
		return 2

	func get_card_selection_type() -> ActionData.CardSelectionType:
		return ActionData.CardSelectionType.RESTRICTED

	func secondary_card_selection_filter() -> Callable:
		return func(_tool_data: ToolData) -> bool:
			return true


class _ScriptNonRestrictedNeedsTwo extends ToolScript:
	func number_of_secondary_cards_to_select() -> int:
		return 2

	func get_card_selection_type() -> ActionData.CardSelectionType:
		return ActionData.CardSelectionType.NON_RESTRICTED


class _ScriptRestrictedWithFilter extends ToolScript:
	func number_of_secondary_cards_to_select() -> int:
		return 1

	func get_card_selection_type() -> ActionData.CardSelectionType:
		return ActionData.CardSelectionType.RESTRICTED

	func secondary_card_selection_filter() -> Callable:
		# Only tool ids that start with "keep_" pass
		return func(td: ToolData) -> bool:
			return td.id.begins_with("keep_")


func _make_tool(id: String, tool_script: ToolScript = null, type: ToolData.Type = ToolData.Type.SKILL) -> ToolData:
	var td := ToolData.new()
	td.id = id
	td.type = type
	if tool_script:
		# tool_script is exposed via a getter that lazily loads
		# res://.../tool_script_<id>.gd; write to the internal backing var so
		# the test can inject its own script.
		td._tool_script = tool_script
	return td


# ----- can_tool_be_applied -----

func test_can_tool_be_applied_true_when_no_tool_script() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("plain")
	assert_true(applier.can_tool_be_applied(td, []))

func test_can_tool_be_applied_true_when_script_not_restricted() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("non_restricted", _ScriptNonRestrictedNeedsTwo.new())
	# Empty hand but since selection is NON_RESTRICTED we return early with true.
	assert_true(applier.can_tool_be_applied(td, []))

func test_can_tool_be_applied_true_when_restricted_but_zero_cards_needed() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("no_selection", _ScriptNoSelection.new())
	# NoSelection returns RESTRICTED from default get_card_selection_type(), but
	# number_of_secondary_cards_to_select() == 0 → true.
	assert_true(applier.can_tool_be_applied(td, []))

func test_can_tool_be_applied_true_when_enough_candidates() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("needs_two", _ScriptRestrictedNeedsTwo.new())
	var hand: Array = [_make_tool("a"), _make_tool("b"), _make_tool("c")]
	assert_true(applier.can_tool_be_applied(td, hand))

func test_can_tool_be_applied_false_when_not_enough_candidates() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("needs_two", _ScriptRestrictedNeedsTwo.new())
	var hand: Array = [_make_tool("only_one")]
	assert_false(applier.can_tool_be_applied(td, hand))

func test_can_tool_be_applied_false_when_filter_excludes_candidates() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("restricted_keep", _ScriptRestrictedWithFilter.new())
	# Filter requires ids starting with "keep_" — none match.
	var hand: Array = [_make_tool("a"), _make_tool("b")]
	assert_false(applier.can_tool_be_applied(td, hand))

func test_can_tool_be_applied_true_when_filter_matches_candidates() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("restricted_keep", _ScriptRestrictedWithFilter.new())
	var hand: Array = [_make_tool("a"), _make_tool("keep_one")]
	assert_true(applier.can_tool_be_applied(td, hand))


# ----- queue_tool_application -----

func _capture_queue_requests() -> Dictionary:
	var capture := {"requests": []}
	var callable := func(request: CombatQueueRequest) -> void:
		capture.requests.append(request)
	if Events.request_combat_queue_push.is_connected(callable):
		Events.request_combat_queue_push.disconnect(callable)
	Events.request_combat_queue_push.connect(callable)
	capture["callable"] = callable
	return capture

func _disconnect_capture(capture: Dictionary) -> void:
	var callable: Callable = capture["callable"]
	if Events.request_combat_queue_push.is_connected(callable):
		Events.request_combat_queue_push.disconnect(callable)

func _make_action(action_type: ActionData.ActionType) -> ActionData:
	var a := ActionData.new()
	a.type = action_type
	a.value = 0
	a.value_type = ActionData.ValueType.NUMBER
	a.operator_type = ActionData.OperatorType.INCREASE
	a.action_category = ActionData.ActionCategory.PLAYER
	return a

func test_queue_tool_application_skill_no_script_queues_one_per_action() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("skill_plain", null)
	td.actions = [
		_make_action(ActionData.ActionType.ENERGY),
		_make_action(ActionData.ActionType.WATER),
	]
	var capture := _capture_queue_requests()
	applier.queue_tool_application(null, td, null, null)
	_disconnect_capture(capture)
	# Each action becomes its own CombatQueueRequest via ActionsApplier.queue_actions.
	assert_eq(capture.requests.size(), 2)

func test_queue_tool_application_skill_with_script_queues_one_request() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("scripted_skill", _ScriptNoSelection.new())
	var capture := _capture_queue_requests()
	applier.queue_tool_application(null, td, null, null)
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 1)
	assert_true((capture.requests[0] as CombatQueueRequest).callback.is_valid())

func test_queue_tool_application_power_queues_one_request() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("some_power", null, ToolData.Type.POWER)
	var capture := _capture_queue_requests()
	applier.queue_tool_application(null, td, null, null)
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 1)
