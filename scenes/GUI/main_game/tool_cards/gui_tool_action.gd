class_name GUIToolAction
extends PanelContainer

const MAX_ACTION_TEXT := "MAX"

@onready var _gui_action_type_icon: GUIActionTypeIcon = %GUIActionTypeIcon
@onready var _value_label: Label = %ValueLabel
@onready var _time_length_icon: TextureRect = %TimeLengthIcon
@onready var _target_count_icon: TextureRect = %TargetCountIcon

func update_with_action(action_data:ActionData) -> void:
	if action_data.type != ActionData.ActionType.NONE:
		_gui_action_type_icon.update_with_action_type(action_data.ActionType)
		if action_data.value > 10:
			_value_label.text = MAX_ACTION_TEXT
		else:
			_value_label.text = str(action_data.value)
	
