class_name GUIGeneralAction
extends GUIAction

const VALUE_ICON_PATH := "res://resources/sprites/GUI/icons/cards/values/icon_"
const SIGN_ICON_PATH := "res://resources/sprites/GUI/icons/cards/signs/icon_"
const SPECIAL_ICON_PATH := "res://resources/sprites/GUI/icons/cards/specials/icon_"

const MAX_ACTION_TEXT := "MAX"

@onready var _gui_action_type_icon: GUIActionTypeIcon = %GUIActionTypeIcon
@onready var _field_application_icon: TextureRect = %FieldApplicationIcon
@onready var _gui_action_value_icon: GUIActionValueIcon = %GUIActionValueIcon

func update_with_action(action_data:ActionData) -> void:
	_field_application_icon.hide()
	_gui_action_type_icon.update_with_action_type(action_data.type)
	_gui_action_value_icon.update_with_action(action_data)

	for special:ActionData.Special in action_data.specials:
		match special:
			ActionData.Special.ALL_FIELDS:
				_field_application_icon.show()
				var path := SPECIAL_ICON_PATH + "all_fields.png"
				_field_application_icon.texture = load(path)
				
func update_for_x(x_value:int, x_value_type:ActionData.XValueType) -> void:
	_field_application_icon.hide()
	_gui_action_type_icon.update_with_action_type(ActionData.ActionType.UPDATE_X)
	_gui_action_value_icon.update_for_x(x_value, x_value_type)

func _get_value_id(value:int) -> String:
	var value_id := str(abs(value))
	if value > 10:
		value_id = "max"
	return value_id
