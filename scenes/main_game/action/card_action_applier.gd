class_name CardActionApplier
extends RefCounted

signal action_application_completed()

func apply_action(action:ActionData, all_actions:Array) -> void:
	assert(action.action_category == ActionData.ActionCategory.CARD)
	var calculated_value := action.get_calculated_value(null)
	match action.type:
		ActionData.ActionType.UPDATE_X:
			var x_action:ActionData
			for action_data:ActionData in all_actions:
				if action_data.value_type == ActionData.ValueType.X:
					x_action = action_data
					break
			match action.operator_type:
				ActionData.OperatorType.INCREASE:
					x_action.modified_x_value += calculated_value
				ActionData.OperatorType.DECREASE:
					x_action.modified_x_value -= calculated_value
				ActionData.OperatorType.EQUAL_TO:
					x_action.modified_x_value = calculated_value
		ActionData.ActionType.LOOP:
			pass
		_:
			assert(false, "Invalid card action type: %s" % action.type)
	action_application_completed.emit()
