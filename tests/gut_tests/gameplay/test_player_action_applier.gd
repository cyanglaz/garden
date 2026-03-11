extends GutTest

# Tests for PlayerActionApplier — covers branches that only emit Events signals
# and do NOT require a real CombatMain instance:
#   ENERGY, UPDATE_HP, UPDATE_GOLD.
#
# PUSH_LEFT, PUSH_RIGHT, DRAW_CARD, DISCARD_CARD, STUN, MOMENTUM, and
# ADD_CARD_DISCARD_PILE all require CombatMain and are not covered here.
#
# NOTE: ENERGY and UPDATE_HP branches call Util.create_scaled_timer() internally.
# We do NOT await apply_action() for those — the Events signal is emitted
# synchronously before the timer, so it is detectable immediately.
# For action_application_completed (after the timer), we use GUT's
# wait_for_signal() which handles async properly.

func _make_action(
	type: ActionData.ActionType,
	value: int,
	op: ActionData.OperatorType = ActionData.OperatorType.INCREASE
) -> ActionData:
	var ad := ActionData.new()
	ad.type = type
	ad.value = value
	ad.value_type = ActionData.ValueType.NUMBER
	ad.operator_type = op
	return ad

# ----- ENERGY -----

func test_energy_increase_emits_request_energy_update() -> void:
	watch_signals(Events)
	var applier := PlayerActionApplier.new()
	var action := _make_action(ActionData.ActionType.ENERGY, 3, ActionData.OperatorType.INCREASE)
	applier.apply_action(action, null, [])  # no await — signal fires before the timer
	assert_signal_emitted_with_parameters(Events, "request_energy_update", [3, ActionData.OperatorType.INCREASE])

func test_energy_decrease_emits_request_energy_update() -> void:
	watch_signals(Events)
	var applier := PlayerActionApplier.new()
	var action := _make_action(ActionData.ActionType.ENERGY, 2, ActionData.OperatorType.DECREASE)
	applier.apply_action(action, null, [])  # no await
	assert_signal_emitted_with_parameters(Events, "request_energy_update", [2, ActionData.OperatorType.DECREASE])

func test_energy_emits_action_application_completed() -> void:
	var applier := PlayerActionApplier.new()
	watch_signals(applier)
	var action := _make_action(ActionData.ActionType.ENERGY, 1, ActionData.OperatorType.INCREASE)
	applier.apply_action(action, null, [])  # no await — completed signal fires after the timer
	await wait_for_signal(applier.action_application_completed, 1.0)
	assert_signal_emitted(applier, "action_application_completed")

# ----- UPDATE_HP -----

func test_update_hp_increase_emits_request_hp_update() -> void:
	watch_signals(Events)
	var applier := PlayerActionApplier.new()
	var action := _make_action(ActionData.ActionType.UPDATE_HP, 5, ActionData.OperatorType.INCREASE)
	applier.apply_action(action, null, [])  # no await — signal fires before the timer
	assert_signal_emitted_with_parameters(Events, "request_hp_update", [5, ActionData.OperatorType.INCREASE])

func test_update_hp_decrease_emits_request_hp_update() -> void:
	watch_signals(Events)
	var applier := PlayerActionApplier.new()
	var action := _make_action(ActionData.ActionType.UPDATE_HP, 4, ActionData.OperatorType.DECREASE)
	applier.apply_action(action, null, [])  # no await
	assert_signal_emitted_with_parameters(Events, "request_hp_update", [4, ActionData.OperatorType.DECREASE])

func test_update_hp_emits_action_application_completed() -> void:
	var applier := PlayerActionApplier.new()
	watch_signals(applier)
	var action := _make_action(ActionData.ActionType.UPDATE_HP, 1, ActionData.OperatorType.INCREASE)
	applier.apply_action(action, null, [])  # no await — completed signal fires after the timer
	await wait_for_signal(applier.action_application_completed, 1.0)
	assert_signal_emitted(applier, "action_application_completed")

# ----- UPDATE_GOLD -----

func test_update_gold_increase_emits_positive_value() -> void:
	watch_signals(Events)
	var applier := PlayerActionApplier.new()
	var action := _make_action(ActionData.ActionType.UPDATE_GOLD, 5, ActionData.OperatorType.INCREASE)
	await applier.apply_action(action, null, [])
	assert_signal_emitted_with_parameters(Events, "request_update_gold", [5, true])

func test_update_gold_decrease_emits_negative_value() -> void:
	watch_signals(Events)
	var applier := PlayerActionApplier.new()
	var action := _make_action(ActionData.ActionType.UPDATE_GOLD, 5, ActionData.OperatorType.DECREASE)
	await applier.apply_action(action, null, [])
	assert_signal_emitted_with_parameters(Events, "request_update_gold", [-5, true])

func test_update_gold_equal_to_emits_value() -> void:
	watch_signals(Events)
	var applier := PlayerActionApplier.new()
	var action := _make_action(ActionData.ActionType.UPDATE_GOLD, 10, ActionData.OperatorType.EQUAL_TO)
	await applier.apply_action(action, null, [])
	assert_signal_emitted_with_parameters(Events, "request_update_gold", [10, true])

func test_update_gold_emits_action_application_completed() -> void:
	var applier := PlayerActionApplier.new()
	watch_signals(applier)
	var action := _make_action(ActionData.ActionType.UPDATE_GOLD, 1, ActionData.OperatorType.INCREASE)
	await applier.apply_action(action, null, [])
	assert_signal_emitted(applier, "action_application_completed")
