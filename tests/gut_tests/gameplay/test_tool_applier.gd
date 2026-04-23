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
		td.tool_script = tool_script
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
	applier.queue_tool_application(null, td)
	_disconnect_capture(capture)
	# Each action becomes its own CombatQueueRequest via ActionsApplier.queue_actions.
	assert_eq(capture.requests.size(), 2)

func test_queue_tool_application_skill_with_script_queues_one_request() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("scripted_skill", _ScriptNoSelection.new())
	var capture := _capture_queue_requests()
	applier.queue_tool_application(null, td)
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 1)
	assert_true((capture.requests[0] as CombatQueueRequest).callback.is_valid())

func test_queue_tool_application_power_queues_one_request() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("some_power", null, ToolData.Type.POWER)
	var capture := _capture_queue_requests()
	applier.queue_tool_application(null, td)
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 1)


# ----- queue_tool_application with enchant_data -----
#
# When a tool has enchant_data attached, the enchant's action_data should be
# queued as an additional CombatQueueRequest after the tool's own application.

func _make_enchant(action_type: ActionData.ActionType) -> EnchantData:
	var enchant := EnchantData.new()
	enchant.action_data = _make_action(action_type)
	return enchant

func test_queue_tool_application_skill_no_script_with_enchant_queues_extra_request() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("skill_enchanted", null)
	td.actions = [
		_make_action(ActionData.ActionType.ENERGY),
		_make_action(ActionData.ActionType.WATER),
	]
	td.enchant_data = _make_enchant(ActionData.ActionType.DEW)
	var capture := _capture_queue_requests()
	applier.queue_tool_application(null, td)
	_disconnect_capture(capture)
	# 2 for the tool's own actions + 1 for the enchant action.
	assert_eq(capture.requests.size(), 3)

func test_queue_tool_application_skill_no_script_no_enchant_queues_only_actions() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("skill_plain_no_enchant", null)
	td.actions = [_make_action(ActionData.ActionType.ENERGY)]
	# Explicitly leave enchant_data unset (null) — no extra request should be queued.
	var capture := _capture_queue_requests()
	applier.queue_tool_application(null, td)
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 1)

func test_queue_tool_application_skill_with_script_and_enchant_queues_both() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("scripted_enchanted", _ScriptNoSelection.new())
	td.enchant_data = _make_enchant(ActionData.ActionType.ENERGY)
	var capture := _capture_queue_requests()
	applier.queue_tool_application(null, td)
	_disconnect_capture(capture)
	# 1 for the tool_script callback + 1 for the enchant action.
	assert_eq(capture.requests.size(), 2)

func test_queue_tool_application_power_with_enchant_queues_both() -> void:
	var applier := ToolApplier.new()
	var td := _make_tool("power_enchanted", null, ToolData.Type.POWER)
	td.enchant_data = _make_enchant(ActionData.ActionType.WATER)
	var capture := _capture_queue_requests()
	applier.queue_tool_application(null, td)
	_disconnect_capture(capture)
	# 1 for the power upgrade callback + 1 for the enchant action.
	assert_eq(capture.requests.size(), 2)


# ----- _apply_tool_script -----
#
# Guards against the regression where `apply_tool` was accidentally indented
# inside the `if number_of_secondary_cards_to_select > 0` branch, which silently
# no-op'd every tool_script that doesn't select any secondary cards
# (bottled_water, collect, breaking_rules, energy_transfer).

class _ScriptNoSelectionCounting extends ToolScript:
	var apply_call_count: int = 0
	var last_secondary_card_datas: Array = []

	func number_of_secondary_cards_to_select() -> int:
		return 0

	func apply_tool(_combat_main: CombatMain, _tool_data: ToolData, secondary_card_datas: Array) -> void:
		apply_call_count += 1
		last_secondary_card_datas = secondary_card_datas

func test_apply_tool_script_calls_apply_tool_when_zero_secondary_cards_needed() -> void:
	var applier := ToolApplier.new()
	var script := _ScriptNoSelectionCounting.new()
	var td := _make_tool("no_selection_apply", script)
	await applier._apply_tool_script(null, td)
	assert_eq(script.apply_call_count, 1,
		"apply_tool must run for tool_scripts that don't select secondary cards")
	assert_eq(script.last_secondary_card_datas, [],
		"secondary_card_datas should be empty when the script doesn't need any")
