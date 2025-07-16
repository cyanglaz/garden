class_name GUIGeneralAction
extends GUIAction

const MAX_ACTION_TEXT := "MAX"

@onready var _gui_action_type_icon: GUIActionTypeIcon = %GUIActionTypeIcon
@onready var _value_label: Label = %ValueLabel

func update_with_action(action_data:ActionData) -> void:
	assert(action_data.action_category == ActionData.ActionCategory.FIELD || action_data.action_category == ActionData.ActionCategory.CARD, "Action is not a field action")
	_gui_action_type_icon.update_with_action_type(action_data.type)
	if action_data.value > 10:
		_value_label.text = MAX_ACTION_TEXT
	else:
		var text := str(action_data.value)
		if action_data.value > 0:
			text = str("+", text)
		_value_label.text = text
