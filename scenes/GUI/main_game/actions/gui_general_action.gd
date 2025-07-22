class_name GUIGeneralAction
extends GUIAction

const MAX_ACTION_TEXT := "MAX"

@onready var _gui_action_type_icon: GUIActionTypeIcon = %GUIActionTypeIcon
@onready var _value_label: Label = %ValueLabel
@onready var _all_target_icon: TextureRect = %AllTargetIcon

func _ready() -> void:
	_value_label.hide()
	_all_target_icon.hide()

func update_with_action(action_data:ActionData) -> void:
	_gui_action_type_icon.update_with_action_type(action_data.type)
	if action_data.value > 10:
		_value_label.show()
		_value_label.text = MAX_ACTION_TEXT
	else:
		if action_data.value == 0:
			return
		var text := str(action_data.value)
		if action_data.value > 0:
			text = str("+", text)
		_value_label.text = text
		_value_label.show()
	if action_data.target_count < 0:
		_all_target_icon.show()
	else:
		_all_target_icon.hide()
